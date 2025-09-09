module dmem(input clk,we,
            input [9:0]addr,
            input [18:0]data,
            output [18:0]out);
  
  reg [18:0]RAM[1023:0];
  
  assign out = RAM[addr];
  
  initial $readmemb("data.bin",RAM);
  
  always@(posedge clk)  
    if(we) RAM[addr] <= data;
endmodule