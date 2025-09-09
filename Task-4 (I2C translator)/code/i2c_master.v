module i2c_master(input clk,	//system clk
                  input areset,	
                  input [6:0]addr,	//slave address
                  input [7:0]data_in,
                  input enable,		//to start transaction
                  input rw,			//1 = read 0 = write
                  output reg[7:0]data_out,	//received data
                  output busy,	//to indicate data is transferring
                  output scl,
//                   output out_i2c_clk =0,
                  inout sda);
  
  parameter IDLE=3'b000,START=3'b001,ADDR=3'b010,READ_ACK_1=3'b011,DATA_TRANS=3'b100,WRITE_ACK=3'b101,READ_ACK_2=3'b110,STOP=3'b111;
  
  reg [2:0]state = IDLE;
  reg [2:0]count = 0;
  reg [7:0]count_2 = 0;			//for i2c_clk from main clk
  reg i2c_clk = 0;
  reg scl_en_clk = 0;
  reg [7:0] count_3 = 0;
  reg scl_enable = 0;	//enable SCL toggle
  reg sda_enable = 0;	//  enable SDA drive 
  						//  1 → Master is driving SDA.
						//  0 → Master leaves SDA free for Slave.
  reg sda_out;
  reg [7:0] saved_addr;
  reg [7:0] saved_data;
  
  //clk for i2c from main clk 400khz
  always@(posedge clk) begin
    if(count_2 == 124) begin
      i2c_clk <= ~i2c_clk;
      count_2 <= 0;
    end
    else
      count_2 <= count_2 + 1;
  end
  
  //800khz scl_en clk
  always@(posedge clk) begin
    if(count_3 == 62) begin
      scl_en_clk <= ~scl_en_clk;
      count_3 = 0;
    end
    else
      count_3 <= count_3 + 1;
  end
  
  
  //scl logic 
  always@(negedge scl_en_clk or posedge areset) begin
    if(areset)
      scl_enable <= 1'b0;
    else begin
      if((state == IDLE) || (state == START) || (state == STOP))
        scl_enable <= 1'b0;
      else 
        scl_enable <= 1'b1;
    end
  end
  
  //FSM logic
  always@(posedge i2c_clk or posedge areset) begin
    if(areset)
      state <= IDLE;
    else begin
      case(state)
       
        IDLE : begin
          if(enable) begin
            state <= START;
            saved_addr <= {addr,rw};
            saved_data <= data_in;
          end
          else
            state <= IDLE;
        end
        
        START : begin
          state <= ADDR;
          count <= 7;
        end
        
        ADDR : begin
          if(count == 0)
            state <= READ_ACK_1;	//after sending address
          else
            count <= count - 1;
        end
        
        READ_ACK_1 : begin
          if(sda == 0) begin	//if slave ack
            count <= 7;
            state <= DATA_TRANS;
          end
          else
            state <= STOP;
        end
        
        DATA_TRANS : begin
          if(saved_addr[0]) begin	//read
            data_out[count] <= sda;	//write into data_out from sda line
            if(count == 0)
              state <= WRITE_ACK;
            else 
              count <= count - 1;
          end
          else begin		//write
            if(count == 0)
              state <= READ_ACK_2;
            else
              count <= count - 1;
          end
        end
        
        WRITE_ACK : state <= STOP;		//after read stop
        
        READ_ACK_2 : begin
          if(sda == 0 && enable == 1)
            state <= IDLE;
          else
            state <= STOP;
        end
        
        STOP : state <= IDLE;
        
      endcase
    end
  end
  
  
  //SDA driving logic
  
  always@(negedge i2c_clk or posedge areset) begin
    
    if(areset) begin
      sda_out <= 1;		//idle line high
      sda_enable <= 1;
    end
    else begin
      case(state)
        
        IDLE : begin
         sda_out <= 1;     // SDA high
         sda_enable <= 1;  // actively drive HIGH
		end
        
        START : begin 	//start condition
          sda_out<=0;
          sda_enable<=1;
        end
        
        ADDR : begin
          sda_out <= saved_addr[count];
          sda_enable <= 1;
        end
        
        READ_ACK_1 : begin	//release line
          sda_enable <= 0;
        end
        
        DATA_TRANS : begin
          if(saved_addr[0])		//if read,release
            sda_enable <= 0;
          else begin			//if write send bit
            sda_out <= saved_data[count];
            sda_enable <= 1;
          end
        end
        
        WRITE_ACK : begin
          sda_out <= 0;
          sda_enable <= 1;
        end
        
        READ_ACK_2 : begin
          sda_enable<=0;
        end
        
        STOP : begin
          sda_out <= 1;
          sda_enable <=1;
        end
        
      endcase
    end
  end
  
  assign scl = (scl_enable) ? i2c_clk : 1'b1;	//toggle scl only when enabled
  assign sda = (sda_enable) ? sda_out : 'bz;	//either drive or floating (high impedance)
  assign busy = (state == IDLE) ? 0 : 1;		//busy when not idle
//   assign out_i2c_clk = i2c_clk;
  
  
endmodule
