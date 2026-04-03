module Control_unit (
    input  wire [6:0] Opcode,
    output reg         branch,
    output reg         MemRead,
    output reg         MemToReg,
    output reg         MemWrite,
    output reg         ALUsrc,
    output reg         RegWrite,
    output reg  [1:0]  ALU_op,
    output reg  [1:0]  ImmSrc
);

always @(*) begin
    branch   = 1'b0;
    MemRead  = 1'b0;
    MemToReg = 1'b0;
    MemWrite = 1'b0;
    ALUsrc   = 1'b0;
    RegWrite = 1'b0;
    ALU_op   = 2'b00;
    ImmSrc   = 2'b00;

    case (Opcode)
        7'b0110011: begin // R-type
            RegWrite = 1'b1;
            ALUsrc   = 1'b0;
            ALU_op   = 2'b10;
            ImmSrc   = 2'b00;
        end

        7'b0000011: begin // load
            MemRead  = 1'b1;
            MemToReg = 1'b1;
            ALUsrc   = 1'b1;
            RegWrite = 1'b1;
            ALU_op   = 2'b00;
            ImmSrc   = 2'b00; // I-type
        end

        7'b0100011: begin // store
            MemWrite = 1'b1;
            ALUsrc   = 1'b1;
            ALU_op   = 2'b00;
            ImmSrc   = 2'b01; // S-type
        end

        7'b1100011: begin // branch
            branch   = 1'b1;
            ALUsrc   = 1'b0;
            ALU_op   = 2'b01;
            ImmSrc   = 2'b10; // B-type
        end

        7'b0010011: begin // I-type ALU
            ALUsrc   = 1'b1;
            RegWrite = 1'b1;
            ALU_op   = 2'b10;
            ImmSrc   = 2'b00; // I-type
        end
    endcase
end

endmodule