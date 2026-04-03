module Imm_Gen (
    input  wire [31:0] instr,
    input  wire [1:0]  ImmSrc,
    output reg  [31:0] imm_out
);

always @(*) begin
    case (ImmSrc)
        2'b00: imm_out = {{20{instr[31]}}, instr[31:20]}; // I-type
        2'b01: imm_out = {{20{instr[31]}}, instr[31:25], instr[11:7]}; // S-type
        2'b10: imm_out = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}; // B-type
        default: imm_out = 32'b0;
    endcase
end

endmodule