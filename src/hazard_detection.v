module Hazard_Detection_Unit (
    input  wire [4:0] Rs1D,
    input  wire [4:0] Rs2D,
    input  wire [4:0] RdE,
    input  wire       MemReadE,

    output wire       StallF,
    output wire       StallD,
    output wire       FlushE
);

    wire lwStall;

    assign lwStall = MemReadE && (RdE != 5'b0) &&
                     ((RdE == Rs1D) || (RdE == Rs2D));

    assign StallF = lwStall;
    assign StallD = lwStall;
    assign FlushE = lwStall;

endmodule