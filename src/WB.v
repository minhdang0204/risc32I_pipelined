module WB (
    input  wire [31:0] ReadDataW,
    input  wire [31:0] ALUResultW,
    input  wire [4:0]  RdW,
    input  wire        MemToRegW,
    input  wire        RegWriteW,

    output wire [31:0] ResultW,
    output wire [4:0]  RdW_out,
    output wire        RegWriteOutW
);

    assign ResultW      = (MemToRegW) ? ReadDataW : ALUResultW;
    assign RdW_out    = RdW;
    assign RegWriteOutW = RegWriteW;

endmodule