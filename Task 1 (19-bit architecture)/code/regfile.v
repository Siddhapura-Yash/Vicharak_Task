module regfile(input [3:0]a1,a2,a3,
               input [18:0]d3,
               output [18:0]d1,d2,
               input clk,we);
  
  reg [18:0]loc[15:0];

  
  always@(posedge clk) begin
//     loc[2] = 2;
//     loc[4] = 4;
//     loc[8] = 8;
//     loc[5] = 5;
//     loc[10] = 10;
    if(we)  loc[a3] <= d3;
      end
  
assign d1 = loc[a1];
assign d2 = loc[a2];

  endmodule
    