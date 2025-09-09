module imem(input [9:0]addr,
            output [18:0]data);
  
  reg [18:0]RAM[1023:0];
  
  initial $readmemb("memfile.bin",RAM);
  
  assign data = RAM[addr];
  
endmodule