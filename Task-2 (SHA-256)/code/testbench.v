`include "SHA-256.v"

module tb;
  
  reg clk;
  reg reset;
  reg start;
  reg [511:0]data_in;
  reg [64:0]data_size;
  reg [255:0]WORLD;
  reg [255:0]APPLE;
  
  wire [255:0]data_out;
  wire done;
  wire [31:0]word[0:63];
  
  integer i;
  
  sha_256 dut(clk,reset,start,data_in,data_out,done,word);
  
  
  initial clk = 0;

    always #5 clk = ~clk;
  
  initial begin
    WORLD = 256'hd7b0bbea3a935222c4198c38e30b2eb3e111d11dea87fa53547eac1c8a4ff03b;
    APPLE = 256'h3a7bd3e2360a3d29eea436fcfb7e44c735d117c42d1c1835420b6b9942dd4f1b;
    
    #4
    reset = 1;
    start = 0;
    data_in = 0;
    data_size = 64'h28;
    
    #4;
    reset = 0;
    
//     data_in = {8'h48, 8'h45, 8'h4C, 8'h4C, 8'h4F, 1'b1, 407'b0, data_size};
    data_in = 512'b01010111010011110101001001001100010001001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101000;
	
    #4;
    start = 1;
    #4 start = 0;
    $display("Expected output = %h",WORLD);
    $display("Actual output = %h",dut.data_out);
    #4;
    wait(done);
    if(data_out == WORLD) begin
      $display("WORLD testcase = PASSED"); end
    else 
      $display("WORLD testcase = FAILED");
    
    
    
   						 //SECOND TESTCASE
    
    
    
    
    #4
    reset = 1;
    start = 0;
    data_in = 0;
    
    #4;
    reset = 0;
data_in = 512'b01000001010100000101000001001100010001011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101000;

	
    #4;
    start = 1;
    #4 start = 0;
    $display("Expected output = %h",APPLE);
    $display("Actual output = %h",dut.data_out);
    #4;
    wait(done);
    if(data_out == APPLE) begin
      $display("APPLE testcase = PASSED"); end
    else 
      $display("APPLE testcase = FAILED");
      
    
//         $display("Displaying word array:");
//     for (i = 0; i < 64; i = i + 1) begin
//         $display("word[%0d] = %h", i, word[i]);
//     end
    
//     $display(" a=%h b=%h c=%h d=%h e=%h f=%h g=%h h=%h", 
//               dut.a, dut.b, dut.c, dut.d, dut.e, dut.f, dut.g, dut.h);
//     $display("H = %h %h %h %h %h %h %h %h", 
//           dut.H[0], dut.H[1], dut.H[2], dut.H[3], 
//           dut.H[4], dut.H[5], dut.H[6], dut.H[7]);
    
    #500;
    $finish;
    
  end
  
//   initial begin
//     $monitor("sha-256 value of hello is = %h",dut.word);
//   end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,tb);
  end
  
endmodule