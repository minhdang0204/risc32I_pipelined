module PC_next (
    input  wire [31:0] pc_current,
    input  wire [31:0] imm_ext,
    input  wire        branch,
    input  wire        zero,
    output wire [31:0] pc_next
);

wire [31:0] pc_plus4;
wire [31:0] pc_branch;
wire        pc_src;

assign pc_plus4  = pc_current + 32'd4;
assign pc_branch = pc_current + imm_ext;
assign pc_src    = branch & zero;

assign pc_next = (pc_src) ? pc_branch : pc_plus4;

endmodule