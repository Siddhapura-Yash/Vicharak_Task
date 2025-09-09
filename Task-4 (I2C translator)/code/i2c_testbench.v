`include "top.v"

module i2c_tb;
  
  reg clk;
  reg areset;
  reg enable;
  reg rw;
  reg [6:0]addr;
  reg [7:0]data_in;
  
  wire busy;
  
  top top_module(clk,areset,enable,rw,addr,data_in,busy);
  
  always begin
    #5 clk = ~clk;
  end
  
  initial begin
    clk = 0;
    areset = 1;
    
    #1000;
    areset = 0;
    addr = 7'b1111111;	//slave addres
    data_in = 8'b10000001;	//data to send
    rw = 0; 	//write
    enable = 1;
    
    #20000;
    enable = 0;
    
    wait(!busy);	//wait untill done
    #2000;
    $monitor($time,"Write on : Slave Address = %b and received data in slave = %b",top_module.translator.addr,top_module.slave2.data_in);


    
    addr = 7'b1111000;	//same slave addres
    rw = 1;		//read
    enable = 1;
    #2000;
    enable = 0;
    
    wait(!busy);
    #2000;
    $monitor($time, "Read complete : Master received = %b",top_module.master.data_out);
    
	#5000;
    $finish;
    
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,i2c_tb);
  end
  
endmodule
