module decoder(input [18:0]instr,
               input[3:0]flag, //to check condition in branching operation
               output reg [4:0]ALUcontrol,
               output reg PCSrc,RegC,SBSC,RegWE,CWE,MemWE,DC,DLDM,JMP);
  
  always@(*) begin
    case(instr[18:14])
      
      //data processing instruction
      //For data processing CWE DC JMP doesn't matter cuz we are not dealing with memory so it will not gonna affect
      5'b00000 : begin 
        ALUcontrol = 5'b00000;
        PCSrc = 0; RegC = 0; SBSC = 0; RegWE = 1; MemWE = 0; DLDM = 0; CWE = 0; DC = 0; JMP = 0; 
      end
      
       5'b00001 : begin 
        ALUcontrol = 5'b00001;
        PCSrc = 0; RegC = 0; SBSC = 0; RegWE = 1; MemWE = 0; DLDM = 0; CWE = 0; DC = 0; JMP = 0; 
      end
      
      5'b00010 : begin 
        ALUcontrol = 5'b00010;
        PCSrc = 0; RegC = 0; SBSC = 0; RegWE = 1; MemWE = 0; DLDM = 0; CWE = 0; DC = 0; JMP = 0; 
      end
      
      5'b00011 : begin 
        ALUcontrol = 5'b00011;
        PCSrc = 0; RegC = 0; SBSC = 0; RegWE = 1; MemWE = 0; DLDM = 0; CWE = 0; DC = 0; JMP = 0; 
      end
      
      5'b00110 : begin 
        ALUcontrol = 5'b00110;
        PCSrc = 0; RegC = 0; SBSC = 0; RegWE = 1; MemWE = 0; DLDM = 0; CWE = 0; DC = 0; JMP = 0;  
      end
      
       5'b00111 : begin 
        ALUcontrol = 5'b00111;
        PCSrc = 0; RegC = 0; SBSC = 0; RegWE = 1; MemWE = 0; DLDM = 0; CWE = 0; DC = 0; JMP = 0;  
      end
      
       5'b01000 : begin 
        ALUcontrol = 5'b01000;
        PCSrc = 0; RegC = 0; SBSC = 0; RegWE = 1; MemWE = 0; DLDM = 0; CWE = 0; DC = 0; JMP = 0;  
      end
      
      
      
      //single register 
      //For single register CWE DC JMP doesn't matter cuz we are not dealing with memory so it will not gonna affect
      5'b00100 : begin 
        ALUcontrol = 5'b00100;
        PCSrc = 0; RegC = 1; SBSC = 1; RegWE = 1; MemWE = 0; DLDM = 0; CWE = 0; DC = 0; JMP = 0; 
      end
      
       5'b00101 : begin 
        ALUcontrol = 5'b00101;
        PCSrc = 0; RegC = 1; SBSC = 1; RegWE = 1; MemWE = 0; DLDM = 0; CWE = 0; DC = 0; JMP = 0; 
      end
      
      // NOT instruction  
      5'b01001 : begin
        ALUcontrol = 5'b01001;
        PCSrc = 0; RegC = 0; SBSC = 0; RegWE = 1; MemWE = 0; DLDM = 0; CWE = 0; DC = 0; JMP = 0; 
      end
        
      
      
      //memory instructions
      //ST
      5'b10000 : begin 
        ALUcontrol = 5'b10000;
        PCSrc = 0; RegC = 0; SBSC = 1; RegWE = 0; MemWE = 1; DLDM = 1; CWE = 0; DC = 0; JMP = 0; 
      end
      
       //LD
      5'b01111 : begin 
        ALUcontrol = 5'b01111;
        PCSrc = 0; RegC = 0; SBSC = 0; RegWE = 1; MemWE = 0; DLDM = 1; CWE = 0; DC = 0; JMP = 0; 
      end
      
      
      
      //Branch Instruction
      //BEQ
      5'b01011 : begin 
        ALUcontrol = 5'b01011;
        PCSrc = (flag[3]==1  ? 1 : 0); RegC = 0; SBSC = 1; RegWE = 0; MemWE = 0; DLDM = 1; CWE = 0; DC = 0; JMP = 0; 
      end
      
//       //BNE
      5'b01100 : begin 
        ALUcontrol = 5'b01011;
        PCSrc = (flag[3]== 1  ? 0 : 1); RegC = 0; SBSC = 1; RegWE = 0; MemWE = 0; DLDM = 1; CWE = 0; DC = 0; JMP = 0; 
      end
      
      //JMP
      5'b01010 : begin 
        ALUcontrol = 5'b01010;
        PCSrc = (1); RegC = 0; SBSC = 1; RegWE = 0; MemWE = 0; DLDM = 1; CWE = 0; DC = 0; JMP = 1; 
      end
      
    endcase
  end
  
endmodule