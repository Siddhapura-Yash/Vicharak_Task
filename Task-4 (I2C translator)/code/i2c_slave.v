module i2c_slave(input scl,
                 inout sda,
                output done);
  
  parameter READ_ADDR = 2'b00, SEND_ACK_1=2'b01, DATA_TRANS = 2'b10, SEND_ACK_2 = 2'b11;
  
  localparam SLAVE_ADDRESS = 7'b1111000; 	//fixed addr
  
  reg success = 0;
  reg [1:0] state = READ_ADDR;
  reg [6:0] addr;
  reg rw;						//1 = read, 0 = write
  reg [7:0] data_in = 0 ;		//received data
  reg [7:0] data_out = 8'b11001101;	//stored data to be send to master
  reg sda_out = 0;
  reg sda_enable = 0;
  reg sda_enable_2 = 1;
  reg [2:0] count = 7;
  reg start = 0;
  reg stop = 1;
  
//   start stop detection
  always@(sda) begin
    if(sda == 0 && scl == 1) begin	//start condition
      start <= 1;
      stop <= 0;
    end
    
    if(sda == 1 && scl == 1) begin	//stop condition
      start <= 0;
      stop <= 1;
    end
    
  end
      
  always@(posedge scl) begin
    if(start) begin
      
      case(state) 
        
        READ_ADDR : begin
          if(count == 0) begin
            sda_enable_2 <= 1;
            rw <= sda;	//last bit is R/W
            state <= SEND_ACK_1;
          end
          
          else begin
            addr[count-1] <= sda;	//shift in addr bits
            count <= count - 1;
          end
        end
        
        SEND_ACK_1 : begin
          if(addr == SLAVE_ADDRESS) begin
            state <= DATA_TRANS;	//if match then go
            count <= 7;
          end
        end
        
        DATA_TRANS : begin
          if(!rw) begin		//if master writing
            data_in[count] <= sda; //receive data
            if(count == 0)
              state <= SEND_ACK_2;
            else
              count <= count - 1;
          end
          else begin	//if master reading and slave writing
            if(count == 0) begin
//               success <= 1;										//doubted here
              state <= READ_ADDR;
            end
            else
              count <= count - 1;
          end
        end
        
        SEND_ACK_2 : begin
          state <= READ_ADDR;	//after receving byte
          sda_enable_2 <= 1;
//           success <= 1;
//           count <= 7;
        end
      endcase
    end
    
    else if(stop) begin
      state <= READ_ADDR;	//reset on stop
      sda_enable_2 <= 1;
      count <= 7;
    end
  end
  
  
  //SDA driving logic
  always@(negedge scl) begin
    case(state)
      READ_ADDR : sda_enable <= 0; //release line
      
      SEND_ACK_1 : begin
        if(addr == SLAVE_ADDRESS) begin
          sda_out <= 0;
          sda_enable <= 1;	//send ACK
        end
        else 
          sda_enable <= 0;	//else NACK
      end
      
      DATA_TRANS : begin
        if(!rw) sda_enable <= 0;	//receiving means master is writing
        else begin
          sda_out <= data_out[count];	//send data bit to master
          sda_enable <= 1;
        end
      end
      
      SEND_ACK_2 : begin	//final ACK after receiving data
        sda_out <= 0;
        sda_enable <= 1;
      end
      
    endcase
  end
  
  
  assign sda = (sda_enable && sda_enable_2) ? sda_out : 'bz;	//drive otherwise float
//   assign data_in_out = data_in;
  assign done = success;
endmodule
      