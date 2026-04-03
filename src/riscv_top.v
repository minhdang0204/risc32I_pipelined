module riscv_pipeline_top (
    input wire clk,
    input wire rst_n
);

    // =========================
    // IF stage
    // =========================
    wire [31:0] PCF;
    wire [31:0] PCPlus4F;
    wire [31:0] InstructionF;

    // =========================
    // IF/ID
    // =========================
    wire [31:0] PCD;
    wire [31:0] PCPlus4D;
    wire [31:0] InstructionD;

    // =========================
    // ID stage
    // =========================
    wire [4:0]  Rs1D;
    wire [4:0]  Rs2D;
    wire [4:0]  RdD;
    wire [2:0]  funct3D;
    wire [6:0]  funct7D;

    wire [31:0] RD1D;
    wire [31:0] RD2D;
    wire [31:0] ImmD;
    wire [31:0] PCD_out;
    wire [31:0] PCPlus4D_out;

    wire        BranchD;
    wire        MemReadD;
    wire        MemToRegD;
    wire        MemWriteD;
    wire        ALUSrcD;
    wire        RegWriteD;
    wire [1:0]  ALUOpD;
    wire [1:0]  ImmSrcD;

    // =========================
    // ID/EX
    // =========================
    wire [31:0] PCE;
    wire [31:0] PCPlus4E;
    wire [31:0] RD1E;
    wire [31:0] RD2E;
    wire [31:0] ImmExtE;

    wire [4:0]  Rs1E;
    wire [4:0]  Rs2E;
    wire [4:0]  RdE;
    wire [2:0]  funct3E;
    wire [6:0]  funct7E;

    wire        BranchE;
    wire        MemReadE;
    wire        MemToRegE;
    wire        MemWriteE;
    wire        ALUSrcE;
    wire        RegWriteE;
    wire [1:0]  ALUOpE;

    // =========================
    // EX stage
    // =========================
    wire [31:0] PCTargetE;
    wire [31:0] ALUResultE;
    wire [31:0] WriteDataE;
    wire        ZeroE;
    wire        PCSrcE;

    wire [4:0]  RdE_out;
    wire        MemReadE_out;
    wire        MemToRegE_out;
    wire        MemWriteE_out;
    wire        RegWriteE_out;

    // =========================
    // EX/MEM
    // =========================
    wire [31:0] PCPlus4M;
    wire [31:0] ALUResultM;
    wire [31:0] WriteDataM;
    wire [4:0]  RdM;
    wire        MemReadM;
    wire        MemToRegM;
    wire        MemWriteM;
    wire        RegWriteM;

    // =========================
    // MEM stage
    // =========================
    wire [31:0] ReadDataM;
    wire [31:0] ALUResultM_out;
    wire [4:0]  RdM_out;
    wire        MemToRegM_out;
    wire        RegWriteM_out;

    // =========================
    // MEM/WB
    // =========================
    wire [31:0] ReadDataW;
    wire [31:0] ALUResultW;
    wire [4:0]  RdW;
    wire        MemToRegW;
    wire        RegWriteW;

    // =========================
    // WB stage
    // =========================
    wire [31:0] ResultW;
    wire [4:0]  RdW_out;
    wire        RegWriteOutW;

    // =========================
    // Hazard / Forwarding
    // =========================
    wire        StallF;
    wire        StallD;
    wire        FlushD;
    wire        FlushE;
    wire [1:0]  ForwardAE;
    wire [1:0]  ForwardBE;

    // load-use hazard
    wire lwStall;
    assign lwStall = MemReadE && (RdE != 5'b0) &&
                     ((RdE == Rs1D) || (RdE == Rs2D));

    // branch + load-use control
    assign FlushD = PCSrcE;
    assign FlushE = lwStall | PCSrcE;

    // =========================
    // IF
    // =========================
    IF u_if (
        .clk         (clk),
        .rst_n       (rst_n),
        .en          (~StallF),
        .PCTargetE   (PCTargetE),
        .PCSrcE      (PCSrcE),
        .PCF         (PCF),
        .PCPlus4F    (PCPlus4F),
        .InstructionF(InstructionF)
    );

    // =========================
    // IF/ID
    // =========================
    IF_ID u_if_id (
        .clk         (clk),
        .rst_n       (rst_n),
        .en          (~StallD),
        .flush       (FlushD),
        .PCF         (PCF),
        .PCPlus4F    (PCPlus4F),
        .InstructionF(InstructionF),
        .PCD         (PCD),
        .PCPlus4D    (PCPlus4D),
        .InstructionD(InstructionD)
    );

    // =========================
    // ID
    // =========================
    ID u_id (
        .clk         (clk),
        .rst_n       (rst_n),
        .PCD         (PCD),
        .PCPlus4D    (PCPlus4D),
        .InstructionD(InstructionD),

        .RegWriteW   (RegWriteOutW),
        .rdW         (RdW_out),
        .ResultW     (ResultW),

        .Rs1D        (Rs1D),
        .Rs2D        (Rs2D),
        .RdD         (RdD),
        .funct3D     (funct3D),
        .funct7D     (funct7D),

        .RD1D        (RD1D),
        .RD2D        (RD2D),

        .Imm         (ImmD),
        .PCD_out     (PCD_out),
        .PCPlus4D_out(PCPlus4D_out),

        .BranchD     (BranchD),
        .MemReadD    (MemReadD),
        .MemToRegD   (MemToRegD),
        .MemWriteD   (MemWriteD),
        .ALUSrcD     (ALUSrcD),
        .RegWriteD   (RegWriteD),
        .ALUOpD      (ALUOpD),
        .ImmSrcD     (ImmSrcD)
    );

    // =========================
    // ID/EX
    // =========================
    ID_EX u_id_ex (
        .clk         (clk),
        .rst_n       (rst_n),
        .flush       (FlushE),

        .PCD         (PCD_out),
        .PCPlus4D    (PCPlus4D_out),
        .RD1D        (RD1D),
        .RD2D        (RD2D),
        .ImmExtD     (ImmD),

        .Rs1D        (Rs1D),
        .Rs2D        (Rs2D),
        .RdD         (RdD),
        .funct3D     (funct3D),
        .funct7D     (funct7D),

        .BranchD     (BranchD),
        .MemReadD    (MemReadD),
        .MemToRegD   (MemToRegD),
        .MemWriteD   (MemWriteD),
        .ALUSrcD     (ALUSrcD),
        .RegWriteD   (RegWriteD),
        .ALUOpD      (ALUOpD),

        .PCE         (PCE),
        .PCPlus4E    (PCPlus4E),
        .RD1E        (RD1E),
        .RD2E        (RD2E),
        .ImmExtE     (ImmExtE),

        .Rs1E        (Rs1E),
        .Rs2E        (Rs2E),
        .RdE         (RdE),
        .funct3E     (funct3E),
        .funct7E     (funct7E),

        .BranchE     (BranchE),
        .MemReadE    (MemReadE),
        .MemToRegE   (MemToRegE),
        .MemWriteE   (MemWriteE),
        .ALUSrcE     (ALUSrcE),
        .RegWriteE   (RegWriteE),
        .ALUOpE      (ALUOpE)
    );

    // =========================
    // Hazard Detection
    // =========================
    Hazard_Detection_Unit u_hdu (
        .Rs1D        (Rs1D),
        .Rs2D        (Rs2D),
        .RdE         (RdE),
        .MemReadE    (MemReadE),
        .StallF      (StallF),
        .StallD      (StallD),
        .FlushE      ()         // không dùng trực tiếp, vì đang tự OR với PCSrcE ở top
    );

    // =========================
    // Forwarding Unit
    // =========================
    Forwarding_Unit u_fwd (
        .Rs1E        (Rs1E),
        .Rs2E        (Rs2E),
        .RdM         (RdM),
        .RdW         (RdW),
        .RegWriteM   (RegWriteM),
        .RegWriteW   (RegWriteW),
        .ForwardAE   (ForwardAE),
        .ForwardBE   (ForwardBE)
    );

    // =========================
    // EX
    // =========================
    EX u_ex (
        .PCE         (PCE),
        .RD1E        (RD1E),
        .RD2E        (RD2E),
        .ImmExtE     (ImmExtE),
        .RdE         (RdE),
        .funct3E     (funct3E),
        .funct7E     (funct7E),
        .BranchE     (BranchE),
        .MemReadE    (MemReadE),
        .MemToRegE   (MemToRegE),
        .MemWriteE   (MemWriteE),
        .ALUSrcE     (ALUSrcE),
        .RegWriteE   (RegWriteE),
        .ALUOpE      (ALUOpE),

        .ForwardAE   (ForwardAE),
        .ForwardBE   (ForwardBE),
        .ALUResultM  (ALUResultM),
        .ResultW     (ResultW),

        .PCTargetE   (PCTargetE),
        .ALUResultE  (ALUResultE),
        .WriteDataE  (WriteDataE),
        .ZeroE       (ZeroE),
        .PCSrcE      (PCSrcE),

        .RdE_out     (RdE_out),
        .MemReadE_out(MemReadE_out),
        .MemToRegE_out(MemToRegE_out),
        .MemWriteE_out(MemWriteE_out),
        .RegWriteE_out(RegWriteE_out)
    );

    // =========================
    // EX/MEM
    // =========================
    EX_MEM u_ex_mem (
        .clk         (clk),
        .rst_n       (rst_n),

        .PCPlus4E    (PCPlus4E),
        .ALUResultE  (ALUResultE),
        .WriteDataE  (WriteDataE),
        .RdE         (RdE_out),

        .MemReadE    (MemReadE_out),
        .MemToRegE   (MemToRegE_out),
        .MemWriteE   (MemWriteE_out),
        .RegWriteE   (RegWriteE_out),

        .PCPlus4M    (PCPlus4M),
        .ALUResultM  (ALUResultM),
        .WriteDataM  (WriteDataM),
        .RdM         (RdM),

        .MemReadM    (MemReadM),
        .MemToRegM   (MemToRegM),
        .MemWriteM   (MemWriteM),
        .RegWriteM   (RegWriteM)
    );

    // =========================
    // MEM
    // =========================
    MEM u_mem (
        .clk         (clk),
        .rst_n       (rst_n),

        .ALUResultM  (ALUResultM),
        .WriteDataM  (WriteDataM),
        .RdM         (RdM),

        .MemReadM    (MemReadM),
        .MemToRegM   (MemToRegM),
        .MemWriteM   (MemWriteM),
        .RegWriteM   (RegWriteM),

        .ReadDataM   (ReadDataM),
        .ALUResultM_out(ALUResultM_out),
        .RdM_out     (RdM_out),
        .MemToRegM_out(MemToRegM_out),
        .RegWriteM_out(RegWriteM_out)
    );

    // =========================
    // MEM/WB
    // =========================
    MEM_WB u_mem_wb (
        .clk         (clk),
        .rst_n       (rst_n),

        .ReadDataM   (ReadDataM),
        .ALUResultM  (ALUResultM_out),
        .RdM         (RdM_out),

        .MemToRegM   (MemToRegM_out),
        .RegWriteM   (RegWriteM_out),

        .ReadDataW   (ReadDataW),
        .ALUResultW  (ALUResultW),
        .RdW         (RdW),

        .MemToRegW   (MemToRegW),
        .RegWriteW   (RegWriteW)
    );

    // =========================
    // WB
    // =========================
    WB u_wb (
        .ReadDataW   (ReadDataW),
        .ALUResultW  (ALUResultW),
        .RdW         (RdW),
        .MemToRegW   (MemToRegW),
        .RegWriteW   (RegWriteW),

        .ResultW     (ResultW),
        .RdW_out     (RdW_out),
        .RegWriteOutW(RegWriteOutW)
    );

endmodule 