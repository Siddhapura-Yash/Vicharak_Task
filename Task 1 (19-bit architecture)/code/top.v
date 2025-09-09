//datapath	clk,PCSrc,RegC,SBSC,RegWE,ALUctrl,CWE,MemWE,DC,DLDM,JMP,rst,instr,flag
//decoder	PCSrc,PCSRC,RegC,SBSC,RegWE,CWE,MemWE,DC,DLDM,JMP

`include "datapath.v"
`include "decoder.v"

module top(input clk,rst);
  
  wire pc_src,reg_c,sbsc,reg_we,cwe,mem_we,dc,dldm,jmp;
  wire [4:0]alu_ctrl;
  wire [18:0]instr,pc,mux1_out,dmem_out;
  wire [3:0]flag;
  
//   //imem 
//   imem imem(pc[9:0],instr);
  
//   //dmem
//   dmem dmem(clk,mem_we,instr[9:0],mux1_out,dmem_out);
  
  //instantiate datapath
  datapath dp_unit(
    .clk(clk),
    .PCSrc(pc_src),
    .RegC(reg_c),
    .SBSC(sbsc),
    .RegWE(reg_we),
    .ALUctrl(alu_ctrl),
    .CWE(cwe),
    .MemWE(mem_we),
    .DC(dc),
    .DLDM(dldm),
    .JMP(jmp),
    .rst(rst),
    .instr(instr),
    .Flag(flag),
    .pc_dash(pc),
    .mux1_out(mux1_out),
    .dmem_out(dmem_out)
  );
  
  
  //decoder	PCSrc,RegC,SBSC,RegWE,CWE,MemWE,DC,DLDM,JMP,instr,flag,ALUcontrol
  decoder dec_unit(
	.PCSrc(pc_src),
    .RegC(reg_c),
    .SBSC(sbsc),
    .RegWE(reg_we),
    .CWE(cwe),
    .MemWE(mem_we),
    .DC(dc),
    .DLDM(dldm),
    .JMP(jmp),
    .instr(instr),
    .flag(flag),
    .ALUcontrol(alu_ctrl));
  

endmodule
  