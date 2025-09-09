module extend(input [9:0]in,
              input sel,
              output [9:0]out);
  
  assign out = sel ? in : {4'b0,in[5:0]};
  
endmodule