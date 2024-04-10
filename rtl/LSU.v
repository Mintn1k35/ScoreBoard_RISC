module LSU(
    input wire clk,
    input wire rst_n,
    input wire load,
    input wire [4:0] rd,
    input wire [32:0] data1,
    input wire [32:0] data2,
    input wire [32:0] imm_ex,
    input wire [32:0] alu_data,
    input wire [32:0] mul_data,
    input wire [5:0] ex_type,
    input wire [1:0] data1_depend,
    input wire [1:0] write_data_depend,
    input wire mem_done,
    input wire [31:0] DCache_data,
    output reg [1:0] state,
    output wire done,
    output wire [4:0] rd_out,
    output wire [31:0] result,
    output reg read_mem,
    output reg write_mem,
    output wire [31:0] addr,
    output wire addr_valid,
    output reg [31:0] write_data,
    output wire write_data_valid
);
    reg [32:0] operand1, write_data_tmp;
    reg [32:0] imm_ex_store;
    reg [32:0] data1_store, data2_store, alu_data_store, mul_data_store;
    reg [31:0] result_tmp;
    reg [5:0] ex_type_store;
    reg [4:0] rd_store;
    reg [1:0] data1_depend_store, write_data_depend_store;
    // reg [1:0] state; // 00 - ready, 01 - busy, 10 - wait mem, 11 - done

    wire data1_valid = operand1[32];

    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= 2'b00;
        end
        else begin
            case(state)
                2'b00: begin
                    if(load) state <= 2'b01;
                    else state <= state;
                end

                2'b01: begin
                    if(read_mem) begin
                        if(addr_valid) state <= 2'b10;
                        else state <= state;
                    end
                    else if(write_mem) begin
                        if(addr_valid & write_data_valid) state <= 2'b10;
                        else state <= state;
                    end
                end

                2'b10: begin
                    if(mem_done) state <= 2'b11;
                    else state <= state;
                end

                2'b11: begin
                    state <= 2'b00;
                end

                default: state <= 2'b00;
            endcase
        end
    end

    always @(*) begin
        case(data1_depend_store)
            2'b00: operand1 = data1_store;
            2'b01: operand1 = alu_data_store;
            2'b10: operand1 = mul_data_store;
            default: operand1 = 33'd0;
        endcase

        case(write_data_depend_store)
            2'b00: write_data_tmp = data2_store;
            2'b01: write_data_tmp = alu_data_store;
            2'b10: write_data_tmp =   mul_data_store;
            default: write_data_tmp = 33'd0;
        endcase
    end


    always @(*) begin
		case(ex_type_store)
			6'd21: begin
				result_tmp = {DCache_data[31], 23'd0, DCache_data[7:0]};
				read_mem = 1'b1;
			end
			6'd22: begin
				result_tmp = {DCache_data[31], 15'd0, DCache_data[15:0]};
				read_mem = 1'b1;
			end
			6'd23: begin
				result_tmp = DCache_data;
				read_mem = 1'b1;
			end
			6'd24: begin
				result_tmp = {24'd0, DCache_data[7:0]};
				read_mem = 1'b1;
			end
			6'd25: begin
				result_tmp = {16'd0, DCache_data[15:0]};
				read_mem = 1'b1;
			end
			default: begin
				result_tmp = 32'd0;
				read_mem = 1'b0;
			end
		endcase
    end

	always @(*) begin
		case(ex_type_store)
			6'd26: begin
				write_mem = 1'b1;
				write_data = {24'd0, write_data_tmp[7:0]};
			end
			6'd27: begin
				write_mem = 1'b1;
				write_data = {16'd0, write_data_tmp[15:0]};
			end
			6'd28: begin
				write_mem = 1'b1;
				write_data = write_data_tmp;
			end
			default: begin
				write_mem = 1'b0;
				write_data = 32'd0;
			end
		endcase
	end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            ex_type_store <= 6'd0;
            data1_depend_store <= 2'b00;
            write_data_depend_store <= 2'b00;
            rd_store <= 5'd0;
            alu_data_store <= 33'd0;
            mul_data_store <= 33'd0;
            data1_store <= 33'd0;
            data2_store <= 33'd0;
            imm_ex_store <= 33'd0;
        end
        else begin
            ex_type_store <= load ? ex_type : ex_type_store;
            data1_depend_store <= load ? data1_depend : data1_depend_store;
            write_data_depend_store <= load ? write_data_depend : write_data_depend_store;
            data1_store <= load ? data1 : data1_store;
            data2_store <= load ? data2 : data2_store;
            rd_store <= load ? rd : rd_store;
            alu_data_store <= load & alu_data[32] ? alu_data : alu_data_store;
            mul_data_store <= load & mul_data[32] ? mul_data : mul_data_store;
            imm_ex_store <= load ? imm_ex : imm_ex_store;
        end
    end

    assign done = (state == 2'b10 & mem_done) ? 1'b1 : 1'b0;
    assign result = (state == 2'b10) ? result_tmp : 32'd0;
    assign rd_out = (state == 2'b10 & mem_done) & read_mem ? rd_store : 5'd0;
    assign addr = operand1[31:0] + imm_ex_store[31:0];
    assign addr_valid = operand1[32] & imm_ex_store[32];
    assign write_data_valid = write_data_tmp[32] & write_mem;
endmodule