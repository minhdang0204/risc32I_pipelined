module Instruction_Mem (
	input 	wire		clk,
	input	wire		rst_n,
	input	wire	[31:0]	read_address,
	output	wire 	[31:0]	instruction_out
);
	reg [31:0] Imem [63:0];
	
	assign instruction_out = rst_n ? Imem[read_address[7:2]] : 32'b0;
endmodule			