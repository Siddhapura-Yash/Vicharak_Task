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
    
    		//WRITE DATA USING LOGICAL ADDRESS
    
    addr = 7'b1111111;	//slave addres
    data_in = 8'b10000001;	//data to send
    rw = 0; 	//write
    
    enable = 1;
    #2000;

    wait(busy);	//wait untill done
    #2000;
    $display($time," Write on : Logical Slave Address = %b and received data in slave2 = %b",addr,top_module.slave2.data_in);


    
    
    //WRITE DATA USING PHYSICAL ADDRESS	

    
//     addr = 7'b1111000;	//physical address
//      data_in = 8'b10101010;	//data to send
//     rw = 0;		
   
//     enable = 1;
//     #20000;
    
//     wait(busy);
//     #2000;
 
//     $display($time, " Write on : Physical Slave Address = %b and received data in slave1 = %b",addr,top_module.slave1.data_in);
    
    
    
//     NOTE : (ONLY ONE OPERATION AT ONCE SO MAKE COMMENT ANOTHER BLCOK)
    
	#1000;
    $finish;  
  end

  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,i2c_tb);
  end
  
endmodule
