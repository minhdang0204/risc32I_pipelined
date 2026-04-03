`timescale 1ns/1ps

module riscv32I_tb;

    reg clk;
    reg rst_n;
    integer i;

    integer pass_count;
    integer fail_count;

    reg saw_fwd_exmem_ab;
    reg saw_load_use_stall;
    reg saw_fwd_from_wb_after_lw;
    reg saw_branch_flush;
    reg saw_store_data_forward;

    // DUT
    riscv_pipeline_top dut (
        .clk   (clk),
        .rst_n (rst_n)
    );

    // =========================
    // Clock
    // =========================
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // =========================
    // Instruction encoders
    // =========================
    function [31:0] R_TYPE;
        input [6:0] funct7;
        input [4:0] rs2;
        input [4:0] rs1;
        input [2:0] funct3;
        input [4:0] rd;
        input [6:0] opcode;
        begin
            R_TYPE = {funct7, rs2, rs1, funct3, rd, opcode};
        end
    endfunction

    function [31:0] I_TYPE;
        input [11:0] imm;
        input [4:0]  rs1;
        input [2:0]  funct3;
        input [4:0]  rd;
        input [6:0]  opcode;
        begin
            I_TYPE = {imm, rs1, funct3, rd, opcode};
        end
    endfunction

    function [31:0] S_TYPE;
        input [11:0] imm;
        input [4:0]  rs2;
        input [4:0]  rs1;
        input [2:0]  funct3;
        input [6:0]  opcode;
        begin
            S_TYPE = {imm[11:5], rs2, rs1, funct3, imm[4:0], opcode};
        end
    endfunction

    function [31:0] B_TYPE;
        input [12:0] imm;
        input [4:0]  rs2;
        input [4:0]  rs1;
        input [2:0]  funct3;
        input [6:0]  opcode;
        begin
            B_TYPE = {
                imm[12],
                imm[10:5],
                rs2,
                rs1,
                funct3,
                imm[4:1],
                imm[11],
                opcode
            };
        end
    endfunction

    // =========================
    // Utility tasks
    // =========================
    task init_flags;
    begin
        saw_fwd_exmem_ab         = 1'b0;
        saw_load_use_stall       = 1'b0;
        saw_fwd_from_wb_after_lw = 1'b0;
        saw_branch_flush         = 1'b0;
        saw_store_data_forward   = 1'b0;
        pass_count               = 0;
        fail_count               = 0;
    end
    endtask

    task init_imem;
    begin
        for (i = 0; i < 64; i = i + 1)
            dut.u_if.IM.Imem[i] = 32'h00000013; // NOP
    end
    endtask

    task init_dmem;
    begin
        for (i = 0; i < 64; i = i + 1)
            dut.u_mem.u_dmem.Dmem[i] = 32'd0;
    end
    endtask

    task load_program;
    begin
        dut.u_if.IM.Imem[0] = I_TYPE(12'd5,   5'd0, 3'b000, 5'd1, 7'b0010011); // addi x1,x0,5
        dut.u_if.IM.Imem[1] = R_TYPE(7'b0000000, 5'd1, 5'd1, 3'b000, 5'd2, 7'b0110011); // add x2,x1,x1
        dut.u_if.IM.Imem[2] = R_TYPE(7'b0000000, 5'd1, 5'd2, 3'b000, 5'd3, 7'b0110011); // add x3,x2,x1
        dut.u_if.IM.Imem[3] = I_TYPE(12'd0,   5'd0, 3'b010, 5'd4, 7'b0000011); // lw x4,0(x0)
        dut.u_if.IM.Imem[4] = R_TYPE(7'b0000000, 5'd1, 5'd4, 3'b000, 5'd5, 7'b0110011); // add x5,x4,x1
        dut.u_if.IM.Imem[5] = B_TYPE(13'd8,   5'd1, 5'd1, 3'b000, 7'b1100011); // beq x1,x1,+8
        dut.u_if.IM.Imem[6] = I_TYPE(12'd123, 5'd0, 3'b000, 5'd6, 7'b0010011); // flush
        dut.u_if.IM.Imem[7] = I_TYPE(12'd77,  5'd0, 3'b000, 5'd7, 7'b0010011); // addi x7,x0,77
        dut.u_if.IM.Imem[8] = S_TYPE(12'd4,   5'd7, 5'd0, 3'b010, 7'b0100011); // sw x7,4(x0)
        dut.u_if.IM.Imem[9] = I_TYPE(12'd1,   5'd0, 3'b110, 5'd8, 7'b0010011); // ori x8,x0,1
    end
    endtask

    task do_reset;
    begin
        rst_n = 1'b0;
        repeat (3) @(posedge clk);
        rst_n = 1'b1;
    end
    endtask

    task check_equal;
        input [255:0] name;
        input [31:0] actual;
        input [31:0] expected;
    begin
        if (actual === expected) begin
            $display("[PASS] %0s = %0d", name, actual);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] %0s wrong, got %0d, expected %0d", name, actual, expected);
            fail_count = fail_count + 1;
        end
    end
    endtask

    task check_flag;
        input [255:0] name;
        input actual;
    begin
        if (actual) begin
            $display("[PASS] %0s detected", name);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] %0s NOT detected", name);
            fail_count = fail_count + 1;
        end
    end
    endtask

    // =========================
    // Monitor forwarding / hazard / flush
    // =========================
    always @(posedge clk) begin
        if (rst_n) begin
            if ((dut.ForwardAE == 2'b10) &&
                (dut.ForwardBE == 2'b10) &&
                (dut.Rs1E == 5'd1) &&
                (dut.Rs2E == 5'd1)) begin
                saw_fwd_exmem_ab = 1'b1;
            end

            if ((dut.StallF   == 1'b1) &&
                (dut.StallD   == 1'b1) &&
                (dut.FlushE   == 1'b1) &&
                (dut.MemReadE == 1'b1) &&
                (dut.RdE      == 5'd4)) begin
                saw_load_use_stall = 1'b1;
            end

            if ((dut.ForwardAE == 2'b01) &&
                (dut.Rs1E == 5'd4)) begin
                saw_fwd_from_wb_after_lw = 1'b1;
            end

            if ((dut.PCSrcE == 1'b1) &&
                (dut.FlushD == 1'b1) &&
                (dut.FlushE == 1'b1)) begin
                saw_branch_flush = 1'b1;
            end

            if ((dut.MemWriteE == 1'b1) &&
                (dut.ForwardBE == 2'b10) &&
                (dut.Rs2E == 5'd7)) begin
                saw_store_data_forward = 1'b1;
            end
        end
    end

    // =========================
    // Wave dump
    // =========================
    initial begin
        $dumpfile("tb_riscv_pipeline_top.vcd");
        $dumpvars(0, tb_riscv_pipeline_top);
    end

    // =========================
    // Timeout
    // =========================
    initial begin
        #2000;
        $display("[FAIL] TIMEOUT");
        $finish;
    end

    // =========================
    // Main test
    // =========================
    initial begin
        init_flags();
        init_imem();
        init_dmem();
        load_program();

        do_reset();
      
      	// preload data before release reset
        dut.u_mem.u_dmem.Dmem[0] = 32'd7;

        // đợi PC đi qua chương trình rồi thêm vài cycle để WB xong
        wait (dut.PCF >= 32'h00000028);
        repeat (6) @(posedge clk);

        $display("\n================ RESULT CHECK ================\n");

        // event / micro-architectural checks
        check_flag("Forwarding EX/MEM on A and B", saw_fwd_exmem_ab);
        check_flag("Load-use hazard stall", saw_load_use_stall);
        check_flag("Forwarding from WB after lw", saw_fwd_from_wb_after_lw);
        check_flag("Branch flush", saw_branch_flush);
        check_flag("Store-data forwarding", saw_store_data_forward);

        // architectural checks
        check_equal("x1", dut.u_id.Register.Registers[1], 32'd5);
        check_equal("x2", dut.u_id.Register.Registers[2], 32'd10);
        check_equal("x3", dut.u_id.Register.Registers[3], 32'd15);
        check_equal("x4", dut.u_id.Register.Registers[4], 32'd7);
        check_equal("x5", dut.u_id.Register.Registers[5], 32'd12);
        check_equal("x6", dut.u_id.Register.Registers[6], 32'd0);
        check_equal("x7", dut.u_id.Register.Registers[7], 32'd77);
        check_equal("x8", dut.u_id.Register.Registers[8], 32'd1);
        check_equal("Dmem[1]", dut.u_mem.u_dmem.Dmem[1], 32'd77);

        $display("\n==============================================");
        $display("TOTAL PASS = %0d", pass_count);
        $display("TOTAL FAIL = %0d", fail_count);
        $display("==============================================\n");

        if (fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $finish;
    end

endmodule