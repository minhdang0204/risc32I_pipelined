module ALU (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [3:0]  alu_control,
    output wire [31:0] alu_result,
    output wire        zero
);
    assign alu_result = (alu_control == 4'b0000) ? (A & B) :
                        (alu_control == 4'b0001) ? (A | B) :
                        (alu_control == 4'b0010) ? (A + B) :
                        (alu_control == 4'b0110) ? (A - B) :
                        32'b0;

    assign zero = (alu_result == 32'b0);
endmodule