`include "i2c_master.v"
`include "i2c_slave.v"
`include "i2c_translator.v"


module top(input clk,
           input areset,
           input enable,
           input rw,
           input [6:0]addr,	//slave address
           input [7:0]data_in,	//data to be send);
           output busy);
  

  reg [7:0]data_out;//incoming data
  
  wire sda;
  wire i2c_clk;
  wire slave1_data_line; 	//for translator
  wire slave2_data_line;
  wire slave1_clk;
  wire slave2_clk;
  
  //instantiate master
  i2c_master master(.clk(clk),
   					.areset(areset),
                    .addr(addr),
                    .data_in(data_in),
                    .enable(enable),
                    .rw(rw),
                    .data_out(data_out),
                    .busy(busy),
                    .scl(i2c_clk),//common for all
                    .sda(sda));
  
  //instantiate slave
  i2c_slave slave1(.scl(slave1_clk),.sda(slave1_data_line));
  i2c_slave slave2(.scl(slave2_clk),.sda(slave2_data_line));
  
  //instantiate translator
  i2c_translator translator(.master_clk(i2c_clk),.i2c_clk(i2c_clk),.master_sda(sda),.slave1_clk(slave1_clk),.slave1_data(slave1_data_line),.slave2_clk(slave2_clk),.slave2_data(slave2_data_line));
    
endmodule               
