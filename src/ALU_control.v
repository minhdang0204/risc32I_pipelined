module ALU_control (
    input  wire [1:0] ALU_op,
    input  wire       ALUSrc,
    input  wire [6:0] funct7,
    input  wire [2:0] funct3,
    output reg  [3:0] ALU_control
);

always @(*) begin
    ALU_control = 4'b0010; // mặc định ADD

    case (ALU_op)
        2'b00: begin
            // load / store
            ALU_control = 4'b0010; // ADD
        end

        2'b01: begin
            // beq
            ALU_control = 4'b0110; // SUB
        end

        2'b10: begin
            case (funct3)
                3'b000: begin
                    // R-type: add/sub
                    // I-type: addi
                    if (ALUSrc)
                        ALU_control = 4'b0010; // ADDI
                    else if (funct7 == 7'b0100000)
                        ALU_control = 4'b0110; // SUB
                    else
                        ALU_control = 4'b0010; // ADD
                end

                3'b111: begin
                    // and / andi
                    ALU_control = 4'b0000;
                end

                3'b110: begin
                    // or / ori
                    ALU_control = 4'b0001;
                end

                default: begin
                    ALU_control = 4'b0010; // fallback ADD
                end
            endcase
        end

        default: begin
            ALU_control = 4'b0010;
        end
    endcase
end

endmodule