### ở **IF** nó sẽ có 1 mux để tính toán xem địa chỉ nào được đưa vào PC sau



### 

### Khối **ID** có 4 việc chính:

### 

##### (1) Tách các field của instruction



Từ InstructionD, lấy ra:



* opcode



* rd



* funct3



* rs1



* rs2



* funct7



##### (2) Sinh control signals



Đưa opcode vào Control\_unit để tạo:



* BranchD



* MemReadD



* MemToRegD



* MemWriteD



* ALUSrcD



* RegWriteD



* ALUOpD



* ImmSrcD



##### (3) Đọc register file



Dùng:



* rs1



* rs2



để lấy:



* RD1D



* RD2D



##### (4) Sinh immediate



Đưa InstructionD + ImmSrcD vào Imm\_Gen để lấy:



* ImmExtD

