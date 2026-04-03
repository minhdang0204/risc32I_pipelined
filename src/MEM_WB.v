module MEM_WB (
    input  wire        clk,
    input  wire        rst_n,

    input  wire [31:0] ReadDataM,
    input  wire [31:0] ALUResultM,
    input  wire [4:0]  RdM,

    input  wire        MemToRegM,
    input  wire        RegWriteM,

    output reg  [31:0] ReadDataW,
    output reg  [31:0] ALUResultW,
    output reg  [4:0]  RdW,

    output reg         MemToRegW,
    output reg         RegWriteW
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ReadDataW <= 32'b0;
            ALUResultW <= 32'b0;
            RdW <= 5'b0;
            MemToRegW <= 1'b0;
            RegWriteW <= 1'b0;
        end
        else begin
            ReadDataW <= ReadDataM;
            ALUResultW <= ALUResultM;
            RdW <= RdM;
            MemToRegW <= MemToRegM;
            RegWriteW <= RegWriteM;
        end
    end

endmodule