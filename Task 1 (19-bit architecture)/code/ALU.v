module ALU(input [18:0]d1,d2,
           output reg [18:0]ALUout,
           input [4:0]ALUctrl,
           output reg [3:0]Flag);
  
  reg zero,carry,overflow,negative;
  parameter [18:0] KEY = 19'b1011011101001101011;
  
  always@(*) begin
	// default
    ALUout   = 19'd0;
    carry    = 1'b0;
    overflow = 1'b0;
    zero = 1'b0;
    negative = 1'b0;
  case(ALUctrl)
    5'b00000 : {carry,ALUout} = d1 + d2;
    5'b00001 : ALUout = d1 - d2;
    5'b00010 : ALUout = d1 * d2;
    5'b00011 : ALUout = d1 / d2;
     
    5'b00100 : ALUout = d2 + 1'b1; 
    5'b00101 : ALUout = d2 - 1'b1; 
    
    5'b00110 : ALUout = d1 & d2;
    5'b00111 : ALUout = d1 | d2;
    5'b01000 : ALUout = d1 ^ d2;
    5'b01001 : ALUout = ~ d1;
    
    5'b01011 : ALUout = (d1==d2) ? 0 : 1;
    
    5'b10001 : ALUout = d1 + d2; //FFT
    5'b10010 : ALUout = d1 ^ KEY; //Encoding
    5'b10011 : ALUout = d2 ^ KEY; //Decoding
    default : ALUout = 0;
    
  endcase
    zero = (ALUout == 0);
    negative = ALUout[18];
    
    Flag = {zero,carry,overflow,negative};
  end
  
//   assign zero = (ALUout == 0 || (d1==d2));
//   assign negative = (ALUout[18] == 1'b1);
  
endmodule