module processing_unit(button_clock, clock_50, switches, display_0,
  display_1, display_2, display_3, display_4,
  display_5, display_6, display_7, reset, test0, test1, test2, test3);
  
  input reset, button_clock, clock_50;
  input [17:0] switches;
  output wire [6:0] display_0, display_1, display_2, display_3, display_4, display_5, display_6, display_7;
  output wire [31:0] test0, test1, test2, test3;
  wire clocks;
  wire [1:0] alu_mem_output_selector;
  wire pc_selector, halt, register_destiny_selector, register_write_enabled;
  wire alu_input2_selector, memory_write_enabled, output_write_enabled;
  wire [3:0] aluop_selector;
  wire [31:0] pc;
  wire [31:0] jump_address, signal_extended, alu_input2, memory_data_output, output_data_output;
  wire zero_alu;
  wire [31:0] register_write_data, register_output1, register_output2, instruction, alu_output;
  wire [5:0] register_destiny;
  
  assign clocks = button_clock;/*
  DeBounce md_debounce(
  .clk(clock_50),
  .n_reset(1),
  .button_in(button_clock),
  .DB_out(clocks));*/

  control_unit md_control_unit(
  .opcode(instruction[31:27]),
  .pc_selector(pc_selector),
  .halt(halt),
  .register_destiny_selector(register_destiny_selector),
  .register_write_enabled(register_write_enabled),
  .alu_input2_selector(alu_input2_selector),
  .aluop_selector(aluop_selector),
  .memory_write_enabled(memory_write_enabled),
  .output_write_enabled(output_write_enabled),
  .alu_mem_output_selector(alu_mem_output_selector),
  .zero_alu(zero_alu),
  .reset(reset));
  
  program_counter md_pc(
  .clock(clocks),
  .pc(pc),
  .jump_address(signal_extended),
  .pc_selector(pc_selector),
  .halt(halt));
  
  instruction_data md_instruction_data(
  .clock(clocks),
  .instruction_address(pc),
  .instruction_data_output(instruction));
  
  extender md_extender(
  .immediate(instruction[16:0]),
  .extended(signal_extended));
  
  mux_2 md_mux_register_destiny(
  .selector(register_destiny_selector),
  .in1(instruction[16:12]),//reg_destiny
  .in2(instruction[26:22]),//reg_source2
  .out(register_destiny));
  
  register_base md_register_base(
  .register_destiny(register_destiny),
  .register_source1(instruction[21:17]),
  .register_source2(instruction[26:22]),
  .clock(clocks),
  .write_enabled(register_write_enabled),
  .write_data(register_write_data),
  .register_base_out1(register_output1),
  .register_base_out2(register_output2));
  
  mux_2 md_mux_alu_input2(
  .selector(alu_input2_selector),
  .in1(register_output2),
  .in2(signal_extended),
  .out(alu_input2));
  
  alu md_alu(
  .aluop_selector(aluop_selector),
  .shamt(instruction[11:7]),
  .data_in1(register_output1),
  .data_in2(alu_input2),
  .data_out(alu_output),
  .zero(zero_alu));
  
  memory_data md_memory_data(
  .data_in(register_output1),
  .data_out(memory_data_output),
  .memory_address(alu_output),
  .write_enabled(memory_write_enabled),
  .clock(clocks));
  
  output_data md_output_data(
  .clock(clocks),
  .output_data_in(register_output2),
  .write_enabled(output_write_enabled),
  .data_output(output_data_output),
  .switches(switches),
  .input_ready(reset),
  .display_0(display_0),
  .display_1(display_1),
  .display_2(display_2),
  .display_3(display_3),
  .display_4(display_4),
  .display_5(display_5),
  .display_6(display_6),
  .display_7(display_7));
  
  mux_4 md_alu_mem_output(
  .selector(alu_mem_output_selector),
  .in1(alu_output),
  .in2(memory_data_output),
  .in3(output_data_output),
  .in4(0),
  .out(register_write_data));
  
  assign test0 = pc;
  assign test1 = alu_output;
  assign test2 = register_output2;
  assign test3 = signal_extended;
  
endmodule