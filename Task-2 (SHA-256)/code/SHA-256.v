module sha_256(input clk,
               input reset,
               input start,
               input [511:0]data_in,
               output reg [255:0]data_out,
              output reg done,
               output reg [31:0]word[0:63]); //for debugging
  
  reg [31:0]W[63:0];
  reg [31:0]a,b,c,d,e,f,g,h,temp0,temp1;
  integer i;
  
  //initialize hash
  reg [31:0]H[0:7];
  reg [31:0]K[0:63];
  
initial begin
  		H[0] = 32'h6a09e667;
        H[1] = 32'hbb67ae85;
        H[2] = 32'h3c6ef372;
        H[3] = 32'ha54ff53a;
        H[4] = 32'h510e527f;
        H[5] = 32'h9b05688c;
        H[6] = 32'h1f83d9ab;
        H[7] = 32'h5be0cd19;
end
  //initialize constants
  initial begin
  		K[0] = 32'h428a2f98; K[1] = 32'h71374491; K[2] = 32'hb5c0fbcf; K[3] = 32'he9b5dba5;
        K[4] = 32'h3956c25b; K[5] = 32'h59f111f1; K[6] = 32'h923f82a4; K[7] = 32'hab1c5ed5;
        K[8] = 32'hd807aa98; K[9] = 32'h12835b01; K[10] = 32'h243185be; K[11] = 32'h550c7dc3;
        K[12] = 32'h72be5d74; K[13] = 32'h80deb1fe; K[14] = 32'h9bdc06a7; K[15] = 32'hc19bf174;
        K[16] = 32'he49b69c1; K[17] = 32'hefbe4786; K[18] = 32'h0fc19dc6; K[19] = 32'h240ca1cc;
        K[20] = 32'h2de92c6f; K[21] = 32'h4a7484aa; K[22] = 32'h5cb0a9dc; K[23] = 32'h76f988da;
        K[24] = 32'h983e5152; K[25] = 32'ha831c66d; K[26] = 32'hb00327c8; K[27] = 32'hbf597fc7;
        K[28] = 32'hc6e00bf3; K[29] = 32'hd5a79147; K[30] = 32'h06ca6351; K[31] = 32'h14292967;
        K[32] = 32'h27b70a85; K[33] = 32'h2e1b2138; K[34] = 32'h4d2c6dfc; K[35] = 32'h53380d13;
        K[36] = 32'h650a7354; K[37] = 32'h766a0abb; K[38] = 32'h81c2c92e; K[39] = 32'h92722c85;
        K[40] = 32'ha2bfe8a1; K[41] = 32'ha81a664b; K[42] = 32'hc24b8b70; K[43] = 32'hc76c51a3;
        K[44] = 32'hd192e819; K[45] = 32'hd6990624; K[46] = 32'hf40e3585; K[47] = 32'h106aa070;
        K[48] = 32'h19a4c116; K[49] = 32'h1e376c08; K[50] = 32'h2748774c; K[51] = 32'h34b0bcb5;
        K[52] = 32'h391c0cb3; K[53] = 32'h4ed8aa4a; K[54] = 32'h5b9cca4f; K[55] = 32'h682e6ff3;
        K[56] = 32'h748f82ee; K[57] = 32'h78a5636f; K[58] = 32'h84c87814; K[59] = 32'h8cc70208;
        K[60] = 32'h90befffa; K[61] = 32'ha4506ceb; K[62] = 32'hbef9a3f7; K[63] = 32'hc67178f2;
  end
  
  //Rotate Right function
  function [31:0]ROTR;//return value
    input [31:0]x;
    input [4:0]n;
    begin
      ROTR = (x >> n) | (x << (32-n));
    end
  endfunction
	
  //Sigma0
  function [31:0]sigma0;
    input [31:0]x;
    begin
      sigma0 = ROTR(x,7) ^ ROTR(x,18) ^ (x>>3);
    end
  endfunction
  
  //Sigma1
  function [31:0]sigma1;
    input [31:0]x;
    begin
      sigma1 = ROTR(x,17) ^ ROTR(x,19) ^ (x>>10);
    end
  endfunction
  
  //Summation0
  function [31:0]summation0;
    input [31:0]x;
    begin
      summation0 = ROTR(x,2) ^ ROTR(x,13) ^ ROTR(x,22);
    end
  endfunction
  
    //Summation1
  function [31:0]summation1;
    input [31:0]x;
    begin
      summation1 = ROTR(x,6) ^ ROTR(x,11) ^ ROTR(x,25);
    end
  endfunction
  
  //CH function
  function [31:0]ch;
    input [31:0]x,y,z;
    begin
      ch = (x & y) ^ (~x & z);
    end
  endfunction
  
  //Maj function
  function [31:0]maj;
    input [31:0]x,y,z;
    begin
      maj = (x & y) ^ (x & z) ^ (y & z);
    end
  endfunction
  
  
  always@(posedge clk) begin
    if(reset) begin
      data_out <= 0;
      done <= 0; end
    else if(start) begin	
      
      for(i=0;i<16;i++) begin
        W[i] = data_in[511 - 32*i -:32];	//sliced into 16 blocks each having 32-bits
        word[i] = W[i];
      end
      
      for(i=16;i<64;i++) begin
        W[i] = sigma1(W[i-2]) + W[i-7] + sigma0(W[i-15]) + W[i-16];
        word[i] = W[i];
      end
      
      //initalize all working variables
      a = H[0]; b = H[1]; c = H[2]; d = H[3]; e = H[4]; f = H[5]; g = H[6]; h = H[7];
      
      //compression total 64 rounds
      for(i=0;i<64;i++) begin
      temp0 = h + summation1(e) + ch(e,f,g) + K[i] + W[i];
      temp1 = summation0(a) + maj(a,b,c);
        h = g;
        g = f;
        f = e;
        e = d + temp0;
        d = c;
        c = b;
        b = a;
        a = temp0 + temp1;
        
//            $display("Round %0d: a=%h b=%h c=%h d=%h e=%h f=%h g=%h h=%h", 
//              i, a, b, c, d, e, f, g, h);
      end
      
      //add with initial value

      H[0] = H[0] + a;
      H[1] = H[1] + b;
      H[2] = H[2] + c;
      H[3] = H[3] + d;
      H[4] = H[4] + e;
      H[5] = H[5] + f;
      H[6] = H[6] + g;
      H[7] = H[7] + h;
//           $display("H = %h %h %h %h %h %h %h %h", 
//           dut.H[0], dut.H[1], dut.H[2], dut.H[3], 
//           dut.H[4], dut.H[5], dut.H[6], dut.H[7]);
      
      data_out = {H[0],H[1],H[2],H[3],H[4],H[5],H[6],H[7]};
		done = 1;  
    end
    else done <= 0;
  end
    
  
    endmodule