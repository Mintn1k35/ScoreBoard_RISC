module ALU (
    input wire clk,
    input wire rst_n,
    input wire load,
    input wire [4:0] rd,
    input wire [32:0] data1,
    input wire [32:0] data2,
    input wire [32:0] mul_data,
    input wire [32:0] lsu_data,
    input wire [5:0] ex_type,
    input wire [1:0] data1_depend,
    input wire [1:0] data2_depend,
    output reg [1:0] state,
    output wire done,
    output wire [4:0] rd_out,
    output wire [31:0] result
);
    reg [32:0] operand1, operand2;
    reg [32:0] data1_store, data2_store, mul_data_store, lsu_data_store;
    reg [31:0] result_tmp;
    reg [5:0] ex_type_store;
    reg [4:0] rd_store;
    reg [1:0] data1_depend_store, data2_depend_store;
    // reg [1:0] state; // 00 - ready, 01 - busy, 10 - done
    wire data1_valid = operand1[32];
    wire data2_valid = operand2[32]; 

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
                    if(data1_valid & data2_valid) state <= 2'b10;
                    else state <= state;
                end
                2'b10: begin
                    state <= 2'b00;
                end
                default: state <= 2'b00;
            endcase
            
        end
    end


    always @(*) begin
        case(data1_depend_store)
            2'b00: operand1 = data1_store;
            2'b10: operand1 = mul_data_store;
            2'b11: operand1 = lsu_data_store;
            default: operand1 = 33'd0;
        endcase


        case(data2_depend_store)
            2'b00: operand2 = data2_store;
            2'b10: operand2 = mul_data_store;
            2'b11: operand2 = lsu_data_store;
            default: operand2 = 33'd0;
        endcase
    end


    always @(*) begin
		case(ex_type_store) 
			6'd0: result_tmp = operand1[31:0] + operand2[31:0]; // add
			6'd1: result_tmp = operand1[31:0] + operand2[31:0]; // addi
			6'd2: result_tmp = operand1[31:0] - operand2[31:0]; // sub
			6'd3: result_tmp = operand1[31:0] & operand2[31:0]; // and
			6'd4: result_tmp = operand1[31:0] & operand2[31:0]; // andi
			6'd5: result_tmp = operand1[31:0] | operand2[31:0]; // or
			6'd6: result_tmp = operand1[31:0] | operand2[31:0]; // ori
			6'd7: result_tmp = operand1[31:0] ^ operand2[31:0]; // xor
			6'd8: result_tmp = operand1[31:0] ^ operand2[31:0]; // xori
			6'd9: result_tmp = operand1[31:0] << operand2[31:0]; // sll
			6'd10: result_tmp = operand1[31:0] << operand2[31:0]; // slli
			6'd11: result_tmp = operand1[31:0] >> operand2[31:0]; // srl
			6'd12: result_tmp = operand1[31:0] >> operand2[31:0]; // srli
			6'd13: result_tmp = $signed(operand1[31:0]) >>> operand2[31:0]; // sra
			6'd14: result_tmp = $signed(operand1[31:0]) >>> operand2[31:0]; // srai
			6'd15: result_tmp = ($signed(operand1[31:0]) < $signed(operand2[31:0])) ? 32'd1 : 32'd0; //slt
			6'd16: result_tmp = ($signed(operand1[31:0]) < $signed(operand2[31:0])) ? 32'd1 : 32'd0; //slti
			6'd17: result_tmp = (operand1[31:0] < operand2[31:0]) ? 32'd1 : 32'd0; // sltu
			6'd18: result_tmp = (operand1[31:0] < operand2[31:0]) ? 32'd1 : 32'd0; // sltiu
			6'd19: result_tmp = operand2[31:0];
			6'd20: result_tmp = operand1[31:0] + operand2[31:0];
			default:  result_tmp = 32'd0;
		endcase	
	end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            ex_type_store <= 6'd0;
            data1_depend_store <= 2'b00;
            data2_depend_store <= 2'b00;
            data1_store <= 33'd0;
            data2_store <= 33'd0;
            rd_store <= 5'd0;
            mul_data_store <= 33'd0;
            lsu_data_store <= 33'd0;
        end
        else begin
            ex_type_store <= load ? ex_type : ex_type_store;
            data1_depend_store <= load ? data1_depend : data1_depend_store;
            data2_depend_store <= load ? data2_depend : data2_depend_store;
            data1_store <= load ? data1 : data1_store;
            data2_store <= load ? data2 : data2_store;
            rd_store <= load ? rd : rd_store;
            mul_data_store <= load | mul_data[32] ? mul_data : mul_data_store;
            lsu_data_store <= load | lsu_data[32] ? lsu_data : lsu_data_store;
        end
    end

    assign done = (state == 2'b10) ? 1'b1 : 1'b0;
    assign result = (state == 2'b10) ? result_tmp : 32'd0;
    assign rd_out = (state == 2'b10) ? rd_store : 5'd0;
endmodule