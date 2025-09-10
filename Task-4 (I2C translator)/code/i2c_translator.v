module i2c_translator(input master_clk,
                  inout master_sda,
                  input i2c_clk,
                  //slave 1
                  output slave1_clk,
                  inout slave1_data,
                  //slave 2
                  output slave2_clk,
                  inout slave2_data,
                    output reg busy = 0);
  
  localparam SLAVE1_ADDR = 7'b1111000;
  localparam SLAVE2_ADDR = 7'b1111000;
  
  localparam LOGICAL_ADDR = 7'b1111111; //for slave 2
  
  //FSM States
  parameter READ_ADDR = 4'd0,SEND_ACK_1 = 4'd1, LOGICAL_DATA_TRANS = 4'd2, SEND_ACK_2 = 4'd3, DATA_TRANS = 4'd4, SEND_DATA_TO_SLAVE = 4'd5, SLAVE_START = 4'd6, SEND_ADDR = 4'd7, RECEIVE_ACK = 4'd8, DATA_SEND_TO_SLAVE2 = 4'd9,RECEIVE_ACK_2 = 4'd10,READ_ACK_2 = 4'd11,SEND_ACK = 4'd12, WRITE_TO_MASTER = 4'd13,SEND_TRANS_ACK_2 = 4'd14;
  
  reg slave_choose = 0;
  reg [7:0]normal_data_in = 0;
  reg [7:0]master_sda_data;
  reg master_slave = 0;
  reg slave1_sda;
  reg slave1_sda_enable;
  reg slave2_sda;
  reg slave2_sda_enable;
  
  reg start = 0;
  reg stop = 0;
  reg [3:0] state = READ_ADDR;
  reg rw;
  reg [6:0]addr;
  reg [3:0]count = 7;
  reg [7:0]data_in = 0;	//incoming data
  reg [7:0]data_out = 0; //data to be send from slave should be here
  reg sda_enable = 0;
  reg sda_enable_2 = 0;
  reg sda_out;
  
  reg [7:0]saved_addr = 0;
  
  reg scl_enable = 0;
  
  always@(negedge master_clk ) begin
    if( state == SEND_DATA_TO_SLAVE || state == SLAVE_START)
        scl_enable <= 1'b0;
      else 
        scl_enable <= 1'b1;
  end
      
  
  //   start stop detection
  always@(master_sda) begin
    if(master_sda == 0 && master_clk == 1) begin	//start condition
      start <= 1;
      stop <= 0;
    end
    
    if(master_sda == 1 && master_clk == 1) begin	//stop condition
      start <= 0;
      stop <= 1;
    end
    
  end

  

  always@(posedge master_clk) begin
    if(start) begin
      
      case(state) 
        
        READ_ADDR : begin 
          if(count == 0) begin
            sda_enable_2 <= 1;
            rw <= master_sda;	//last bit is R/W
            state <= SEND_ACK_1;
          end
          
          else begin
            addr[count-1] <= master_sda;	//count - 1 used cuz addr have 7 bits
            count <= count - 1;
          end
        end
        
        SEND_ACK_1 : begin
          if(addr == LOGICAL_ADDR) begin
            saved_addr <= {SLAVE2_ADDR,rw};
            state <= LOGICAL_DATA_TRANS;	//if match then go 
            count <= 7;
          end
          else if(addr == SLAVE1_ADDR)begin
            state <= DATA_TRANS;
            saved_addr <= {SLAVE2_ADDR,rw};
            count <=7;
            slave_choose <= 1;
          end
        end
        
        //In normal operation translator should become transparent
        DATA_TRANS : begin
          if(!rw) begin		//if master writing
//             slave1_sda <= master_sda; //receive data
            normal_data_in[count] <= master_sda;
            if(count == 0) begin
              state <= SEND_ACK_2;
            count <= 7;
            end
            else
              count <= count - 1;
          end
          else begin	//if master reading and slave writing
            if(count == 0)
              state <= READ_ADDR;
            else
              count <= count - 1;
          end
        end
        
        LOGICAL_DATA_TRANS : begin
          if(!rw) begin		//if master writing
            data_in[count] <= master_sda; //receive data
            if(count == 0) begin
               state <= SEND_ACK_2; 
//               $monitor(" [119] received data in translator = %b",data_in);	//Store data in buffer 
            end
            else
              count <= count - 1;
          end
          else begin	//if master reading and slave writing
            state <= SEND_DATA_TO_SLAVE;
                      master_slave <= 1;

          end
        end
        
        SEND_ACK_2 : begin
          state <= SEND_DATA_TO_SLAVE;	//after receving byte
          sda_enable_2 <= 1;
          count <= 7;
          master_slave <= 1;
        end
        
        
        
        
        //After this master will send data to slave2 for logical address
        SEND_DATA_TO_SLAVE : begin 		//in this state scl and sda should be high of slave2
          if(master_slave == 1) begin
            state <= SLAVE_START;
            master_slave <= 0;
          end
        end
        
        SLAVE_START : begin		//in this state start signal should be send to the slave2
          if(slave_choose == 1) begin		//satisfies during normal operation
            state <= SEND_ADDR;
           slave1_sda <=0;
          slave1_sda_enable<=1;
          count <= 7;
          end
          else begin
            state <= SEND_ADDR;
           slave2_sda <=0;
          slave2_sda_enable<=1;
          count <= 7;
            end
        end
        
        SEND_ADDR : begin		//send addre to the slave2
          if(count == 0) begin
            state <= RECEIVE_ACK;
            count <= 7;
          end
          else begin
            count <= count - 1; end
        end
        
        RECEIVE_ACK : begin
          if(slave_choose == 1) begin
            if(slave1_data == 0) begin //receive ACK from slave2 
//             $display("[168] Receiving ACK after addr matching = %b",slave2_data);		//getting ACK = 0 means address match
          state <= DATA_SEND_TO_SLAVE2;
          count <= 7; end
          else
            state <= SEND_DATA_TO_SLAVE; end
         
          else begin
            if(slave2_data == 0) begin //receive ACK from slave2 
          state <= DATA_SEND_TO_SLAVE2;
          count <= 7; end
          else
            state <= SEND_DATA_TO_SLAVE;
          end
        end
        
        DATA_SEND_TO_SLAVE2 : begin		//in this data should be send to slave2 if ack is 0
          if(saved_addr[0]) begin 		//master reading
            master_sda_data[count] <= slave2_data; 
            if(count == 0)
                state <= SEND_TRANS_ACK_2;
              else 
                count <= count - 1;
            
          end
            else begin 			//writing
              if(count == 0) begin			//program stuck here count not getting equal to 0
                state <= RECEIVE_ACK_2;
              end
              else begin
				count <= count - 1;
                
              end
              end
          
        end
        
        SEND_TRANS_ACK_2 : begin
          state <= WRITE_TO_MASTER;
          count <= 7;
        end
        
        WRITE_TO_MASTER : begin
           if(count == 0)
                state <= SEND_ACK;
              else 
                count <= count - 1;
        end
        
        
        SEND_ACK : begin
          state <= READ_ADDR; 
        end
        
        
        RECEIVE_ACK_2 : begin	//in this ACK should be receive from slave2 then jump to read adder from master
          if(slave_choose == 1) begin
            if(slave1_data == 0) begin
          state <= SEND_DATA_TO_SLAVE;
          end
          else
            state <= SEND_DATA_TO_SLAVE; end
          
          else begin
            if(slave2_data == 0) begin
          state <= READ_ADDR;
          end
          else
            state <= SEND_DATA_TO_SLAVE; 
          end
          
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
  always@(negedge master_clk) begin
    case(state)
      READ_ADDR : sda_enable <= 0; //release line
      
      SEND_ACK_1 : begin
        if(addr == LOGICAL_ADDR) begin
          sda_out <= 0;
          sda_enable <= 1;	//send ACK
        end
        else 
          sda_enable <= 1;
          sda_out <= 0; 	//else NACK
      end
      
       DATA_TRANS : begin
        if(!rw) sda_enable <= 0;	//receiving means master is writing
        else begin
          sda_out <= data_out[count];	//send data bit to master
          sda_enable <= 1;
        end
      end
      
      LOGICAL_DATA_TRANS : begin
        if(!rw) sda_enable <= 0;	//receiving means master is writing
        else begin
          sda_out <= slave2_sda;	//send data bit to master
          sda_enable <= 1;
            sda_enable_2 <= 1;
        end
      end
      
      SEND_ACK_2 : begin	//final ACK after receiving data
        sda_out <= 0;
        slave2_sda_enable <= 1;
      end
      
      
        
      
      
      
      
      SEND_DATA_TO_SLAVE : begin
        if(slave_choose == 1) begin
        slave1_sda_enable <= 1;
          slave1_sda <= 1; end
        else begin
          slave2_sda_enable <= 1;
          slave2_sda <= 1; end
      end
      
      SLAVE_START : begin
        if(slave_choose == 1) begin
        sda_enable <= 1;
          slave2_sda <= 0; end
        else begin
          sda_enable <= 1;
          slave2_sda <= 0;
        end
      end
      
      SEND_ADDR : begin		//send addre to the slave2
        if(slave_choose == 1) begin
        slave1_sda <= saved_addr[count];
          slave1_sda_enable <= 1; end
        else begin
            slave2_sda <= saved_addr[count];
          slave2_sda_enable <= 1;
        end
        end
      
      RECEIVE_ACK : begin
        if(slave_choose == 1) 
        slave1_sda_enable <= 0;
        else 
          slave2_sda_enable <= 0;
      end
      
       DATA_SEND_TO_SLAVE2 : begin
         if(slave_choose == 1) begin
         if(saved_addr[0]) begin
           slave1_sda_enable <= 0;
         end
         else begin
           slave1_sda_enable <= 1;
           slave1_sda <= normal_data_in[count];
         end end
         
         else begin
            if(saved_addr[0]) begin
           slave2_sda_enable <= 0;
         end
         else begin
           slave2_sda_enable <= 1;
           slave2_sda <= data_in[count];
         end
         end
      end
      
      WRITE_TO_MASTER : begin
        sda_out <= master_sda_data[count];
        sda_enable <= 1;
        sda_enable_2 <= 1;
      end
      
      SEND_ACK : begin
                  slave2_sda <= 0;
            slave2_sda_enable <= 1; 
        busy <= 1;
      end
      
      SEND_ACK_2 : begin
        slave2_sda <= 0;
        slave2_sda_enable <= 1;
      end
      
      
      RECEIVE_ACK_2 : begin
        if(slave_choose == 1) begin
        slave1_sda_enable <= 0;
          busy <= 1; end
        else begin
          begin
        slave2_sda_enable <= 0;
          busy <= 1; end
        end
      end
        

      
    endcase
  end
  
      assign master_sda = (sda_enable && sda_enable_2) ? sda_out : 'bz;	//drive otherwise float
      assign slave1_data =  (slave1_sda_enable)? slave1_sda : 'bz;
      assign slave2_data = (slave2_sda_enable)? slave2_sda : 'bz;
  assign slave1_clk = (scl_enable) ? i2c_clk : 1'b1;
  assign slave2_clk = (scl_enable) ? i2c_clk : 1'b1;
    
  
endmodule
