`include "top.v"

module testbench;
  
reg clk,rst;
  
    top dut(clk,rst);
  
 initial begin
    clk = 0;
    forever #8 clk = ~clk; 
  end
  
  
//     //CHECKING DATA IS IN MEMORY OR NOT? 
//   initial begin 
//     $monitor("RAM[100] = %0d | RAM[101] = %0d",uut.dmem.RAM[100],uut.dmem.RAM[101]);
//     #30 $finish;
//     end
  
  
//   //CHECKING DATA CAME INTO REGISTER OR NOT? 
//   initial begin
// //     $monitor("R2 = %0d | R3 = %0d",uut.dp_unit.file_dut.loc[2],uut.dp_unit.file_dut.loc[3]);
//     $monitor("Value = %0d",uut.instr);
//   #5 $finish;
//   end
  
  
  initial begin
    rst = 1;
    #20 rst = 0;
//     $monitor("zero_flag = %d",dut.dp_unit.alu_dut.Flag[3]);
    $monitor("T=%0t   | PC: %d | Instr: %b | r1: %d, r2: %d, r3: %d | Memlocation[102] = %d",
             $time,
             dut.dp_unit.pc_out,        // Program Counter
             dut.dp_unit.instr,         // Current Instruction
             dut.dp_unit.file_dut.loc[1], // Value in Register 1
             dut.dp_unit.file_dut.loc[2], // Value in Register 2
             dut.dp_unit.file_dut.loc[3], // Value in Register 3
             dut.dp_unit.dmem_dut.RAM[102]
            );
  #200 $finish;
  end


  
//   initial begin
//     $monitor("mem = %0d",uut.dmem
  
//   initial begin
//   $monitor("Time=%0t ro1=%d", $time, uut.dp_unit.file_dut.loc[1]);
// end

    
endmodule