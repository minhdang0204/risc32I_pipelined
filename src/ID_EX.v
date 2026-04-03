module ID_EX (
    input  wire        clk,
    input  wire        rst_n,
    input  wire	       flush,

    input  wire [31:0] PCD,
    input  wire [31:0] PCPlus4D,
    input  wire [31:0] RD1D,
    input  wire [31:0] RD2D,
    input  wire [31:0] ImmExtD,

    input  wire [4:0]  Rs1D,
    input  wire [4:0]  Rs2D,
    input  wire [4:0]  RdD,
    input  wire [2:0]  funct3D,
    input  wire [6:0]  funct7D,

    input  wire        BranchD,
    input  wire        MemReadD,
    input  wire        MemToRegD,
    input  wire        MemWriteD,
    input  wire        ALUSrcD,
    input  wire        RegWriteD,
    input  wire [1:0]  ALUOpD,

    output reg  [31:0] PCE,
    output reg  [31:0] PCPlus4E,
    output reg  [31:0] RD1E,
    output reg  [31:0] RD2E,
    output reg  [31:0] ImmExtE,

    output reg  [4:0]  Rs1E,
    output reg  [4:0]  Rs2E,
    output reg  [4:0]  RdE,
    output reg  [2:0]  funct3E,
    output reg  [6:0]  funct7E,

    output reg         BranchE,
    output reg         MemReadE,
    output reg         MemToRegE,
    output reg         MemWriteE,
    output reg         ALUSrcE,
    output reg         RegWriteE,
    output reg  [1:0]  ALUOpE
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        PCE       <= 32'b0;
        PCPlus4E  <= 32'b0;
        RD1E      <= 32'b0;
        RD2E      <= 32'b0;
        ImmExtE   <= 32'b0;

        Rs1E      <= 5'b0;
        Rs2E      <= 5'b0;
        RdE       <= 5'b0;
        funct3E   <= 3'b0;
        funct7E   <= 7'b0;

        BranchE   <= 1'b0;
        MemReadE  <= 1'b0;
        MemToRegE <= 1'b0;
        MemWriteE <= 1'b0;
        ALUSrcE   <= 1'b0;
        RegWriteE <= 1'b0;
        ALUOpE    <= 2'b0;
    end
    else if (flush) begin
    	PCE       <= 32'b0;
    	PCPlus4E  <= 32'b0;
    	RD1E      <= 32'b0;
    	RD2E      <= 32'b0;
    	ImmExtE   <= 32'b0;

    	Rs1E      <= 5'b0;
    	Rs2E      <= 5'b0;
    	RdE       <= 5'b0;
    	funct3E   <= 3'b0;
    	funct7E   <= 7'b0;

    	BranchE   <= 1'b0;
    	MemReadE  <= 1'b0;
    	MemToRegE <= 1'b0;
    	MemWriteE <= 1'b0;
    	ALUSrcE   <= 1'b0;
    	RegWriteE <= 1'b0;
    	ALUOpE    <= 2'b0;	
    end
    else begin
        PCE       <= PCD;
        PCPlus4E  <= PCPlus4D;
        RD1E      <= RD1D;
        RD2E      <= RD2D;
        ImmExtE   <= ImmExtD;

        Rs1E      <= Rs1D;
        Rs2E      <= Rs2D;
        RdE       <= RdD;
        funct3E   <= funct3D;
        funct7E   <= funct7D;

        BranchE   <= BranchD;
        MemReadE  <= MemReadD;
        MemToRegE <= MemToRegD;
        MemWriteE <= MemWriteD;
        ALUSrcE   <= ALUSrcD;
        RegWriteE <= RegWriteD;
        ALUOpE    <= ALUOpD;
    end
end

endmodule