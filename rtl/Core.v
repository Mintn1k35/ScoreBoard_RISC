module Core(
    input wire clk,
    input wire rst_n,
    // Signal for ICache_Controller
    input wire [63:0] fetch_instr_pc,
    output wire stop,
    output wire stop_fetch,
    output wire ecall,
    output wire j_accept,
    output wire [31:0] j_addr,
    // Signal for DCache_Controller
    output wire read_mem,
    output wire write_mem,
    output wire [31:0] addr,
    output wire addr_valid,
    output wire [31:0] write_data,
    output wire write_data_valid,
    input wire mem_done,
    input wire [31:0] DCache_data
    // Signal for CDMA_Control,
    // input wire dma_done,
    // output wire dma_en,
    // output wire [31:0] read_addr,
    // output wire [31:0] write_addr,
    // output wire [31:0] byte_length
);

    wire [32:0] data1_alu, data2_alu;
    wire [31:0] rs1_data, rs2_data, imm_extend, alu_result, pc4, fifo_data, mul_result, lsu_result;
    wire [5:0] ex_type, count;
    wire [4:0] rs1, rs2, rd, rd1_wb, rd2_wb, rd3_wb;
    wire [1:0] alu_state, mul_state, lsu_state, data1_depend, data2_depend;
    wire store_mem, alu, mul, lsu, jal, jalr, branch, auipc, imm, lui, write_en1, write_en2, write_en3, alu_done,
    mul_done, lsu_done, full, empty, read_en, j_accept_tmp, j_wait_tmp, alu_load, mul_load, lsu_load;

    wire [31:0] pc = fetch_instr_pc[63:32];
    wire [31:0] instr = fetch_instr_pc[31:0];
    assign pc4 = pc + 32'd4;
    assign stop = j_wait_tmp;
    assign j_accept = j_accept_tmp & !j_wait_tmp;


    Instr_Decode Instr_Decode_Instance(instr, rs1, rs2, rd, alu, mul, lsu, jal, jalr, branch, 
    auipc, imm, lui, ecall, store_mem, ex_type);

    Imm_Extend Imm_Extend_Instance(instr, imm_extend);

    Register_File Register_File_Instance(clk, rst_n, rs1, rs2, rd1_wb, rd2_wb, rd3_wb, alu_result, mul_result, lsu_result, 
    alu_done, mul_done, lsu_done, rs1_data, rs2_data);

    Branch_Excute Branch_Excute_Instance(instr, imm_extend, rs1_data, rs2_data, pc, data1_depend, data2_depend, j_accept_tmp, j_wait_tmp, j_addr);

    ScoreBoard ScoreBoard_Instance(clk, rst_n, rs1, rs2, rd, alu, mul, lsu, alu_state, mul_state, lsu_state, alu_done,
    mul_done, lsu_done, rd1_wb, rd2_wb, rd3_wb, store_mem, stop_fetch, alu_load, mul_load, lsu_load, data1_depend, data2_depend);

    assign data1_alu = auipc ? {1'b1, pc} : lui ? {1'b1, 32'd0} : {1'b1, rs1_data};
    assign data2_alu = (auipc | lui | imm) ? {1'b1, imm_extend} : (jal | jalr) ? {1'b1, pc4} : {1'b1, rs2_data}; 

    ALU ALU_Instance(clk, rst_n, alu_load, rd, data1_alu, data2_alu, {mul_done, mul_result}, {lsu_done, lsu_result}, ex_type, data1_depend, 
    data2_depend, alu_state, alu_done, rd1_wb, alu_result);

    MUL MUL_Instance(clk, rst_n, mul_load, rd, {data1_depend == 2'b00, rs1_data}, {data2_depend == 2'b00, rs2_data}, {alu_done, alu_result}, {lsu_done, lsu_result}, ex_type, 
    data1_depend, data2_depend, mul_state, mul_done, mul_result, rd2_wb);

    LSU LSU_Instance(clk, rst_n, lsu_load, rd, {data1_depend == 2'b00, rs1_data}, {data2_depend == 2'b00, rs2_data}, {1'b1, imm_extend}, {alu_done, alu_result}, {mul_done, mul_result}, 
    ex_type, data1_depend, data2_depend, mem_done, DCache_data, lsu_state, lsu_done, rd3_wb, lsu_result, read_mem, write_mem, addr, addr_valid, write_data, write_data_valid);

endmodule