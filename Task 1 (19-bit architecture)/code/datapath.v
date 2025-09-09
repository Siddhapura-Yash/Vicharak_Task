`include "flop.v"
`include "mux.v"
`include "imem.v"
`include "regfile.v"
`include "ALU.v"
`include "dmem.v"

//Complete Datapath

module datapath(clk,PCSrc,RegC,SBSC,RegWE,ALUctrl,CWE,MemWE,DC,DLDM,JMP,rst,instr,Flag,pc_dash,mux1_out,dmem_out);
  input clk,PCSrc,RegC,SBSC,RegWE,CWE,MemWE,DC,DLDM,JMP,rst;
  input [4:0]ALUctrl;
  inout [18:0]dmem_out;
  output [18:0]instr; //Whole instruction 19-bits long for decoder
  output [3:0]Flag; //for decoder
  output [18:0]pc_dash;
  output [18:0]mux1_out;
 
//   input [18:0]FMem;
//   output [18:0]SrcB;
  
//   wire [18:0]pc_dash,pc_out; //For PC
  wire [18:0]pc_out;
  wire [18:0]pc_one,ext_out; //Mux before PC
//   wire [18:0]instr; //Whole instruction 19-bits long 
  wire [3:0]ro1,ro2; //ouput of mux before Regfile
  wire [18:0]Fmem; //input to file from Dmem
  wire [18:0]SrcA,SrcB;//file output from register
  wire [18:0]ALUout; //output of ALU
//   reg [3:0]Flag; //flag for condition checking during branching
  wire [9:0]d_o; //input to dmem from mux
//   wire [18:0]dmem_out; //output from dmem
//   wire [18:0]mux1_out,mux2_out; //output of mux 1 and 2
  wire [18:0]mux2_out;
  
//   Logic for PC
  flop flp(pc_dash,clk,rst,pc_out);
  
//   MUX placed before PC  
  assign pc_one = pc_out + 1'b1; //Incrementing PC by 1
  mux #(10) pc_mux(ext_out,pc_one,PCSrc,pc_dash); //after changing from 19 to 10 we got proper output
  
  //Logic for imem
  imem imem_dut(pc_out[9:0],instr);
  
  //Mux before Regfile
  mux #(4) mux_a1(4'b0001,instr[9:6],RegC,ro1);
  mux #(4) mux_a2(instr[13:10],instr[5:2],SBSC,ro2);
  
  //Regfile
  regfile file_dut(ro1,ro2,instr[13:10],Fmem,SrcA,SrcB,clk,RegWE);
  
  //ALU
  ALU alu_dut(SrcA,SrcB,ALUout,ALUctrl,Flag);
  
  //MUX before dmem
  mux #(10) dmem_mux_dut(SrcB[9:0],instr[9:0],CWE,d_o);
  
  //Dmem
  dmem dmem_dut(clk,MemWE,d_o,mux1_out,dmem_out);
  
  //mux1
  mux #(19) mux1_dut(ALUout,SrcB,DC,mux1_out);
  //mux2 
  mux #(19) mux2_dut(dmem_out,ALUout,DLDM,Fmem);
 
  //mux3
  mux #(10) mux3_dut(instr[9:0],{4'b0000,instr[5:0]},JMP,ext_out[9:0]); 
  //using concatenation we don't need extra extender 
  
endmodule
  