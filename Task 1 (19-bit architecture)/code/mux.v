module mux #(parameter WIDTH = 8)
  (input [WIDTH-1 : 0]in1,in2,
   input sel,
   output [WIDTH-1:0] out);

  assign out = sel ? in1 : in2;
  
endmodule