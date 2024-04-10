module MUL(
    input wire clk,
    input wire rst_n,
    input wire load,
    input wire [4:0] rd,
    input wire [32:0] data1,
    input wire [32:0] data2,
    input wire [32:0] alu_data,
    input wire [32:0] lsu_data,
    input wire [5:0] ex_type,
    input wire [1:0] data1_depend,
    input wire [1:0] data2_depend,
    output reg [1:0] state,
    output wire done,
    output wire [31:0] result,
    output wire [4:0] rd_out
);

    reg [32:0] operand1, operand2;
    wire [63:0] result_tmp = operand1[31:0] * operand2[31:0];
    reg [31:0] result_ex;
    reg [32:0] data1_store, data2_store, alu_data_store, lsu_data_store;
    reg [5:0] ex_type_store;
    reg [1:0] data1_depend_store, data2_depend_store;
    reg [4:0] rd_store;
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
            2'b01: operand1 = alu_data_store;
            2'b11: operand1 = lsu_data_store;
            default: operand1 = 33'd0;
        endcase

        case(data2_depend_store)
            2'b00: operand2 = data2_store;
            2'b01: operand2 = alu_data_store;
            2'b11: operand2 = lsu_data_store; 
            default: operand2 = 33'd0;
        endcase
	end


    always @(*) begin
		case(ex_type_store)
			6'd29: result_ex = result_tmp[31:0];
			6'd30: result_ex = result_tmp[63:32];
			6'd31: result_ex = operand1[31:0] / operand2[31:0];
			6'd32: result_ex = operand1[31:0] % operand2[31:0];
			default: result_ex = 33'd0;
		endcase
	end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            ex_type_store <= ex_type;
            data1_store <= 33'd0;
            data2_store <= 33'd0;
            data1_depend_store <= 2'b00;
            data2_depend_store <= 2'b00;
            alu_data_store <= 33'd0;
            lsu_data_store <= 33'd0;
            rd_store <= 5'd0;
        end
        else begin
            ex_type_store <= load ? ex_type : ex_type_store;
            data1_depend_store <= load ? data1_depend : data1_depend_store;
            data2_depend_store <= load ? data2_depend : data2_depend_store;
            data1_store <= load ? data1 : data1_store;
            data2_store <= load ? data2 : data2_store;
            alu_data_store <= load | alu_data[32] ? alu_data :  alu_data_store;
            lsu_data_store <= load | lsu_data[32] ? lsu_data : lsu_data_store;
            rd_store <= load ? rd : rd_store;
        end
    end

    assign done = (state == 2'b10) ? 1'b1 : 1'b0;
    assign result = (state == 2'b10) ? result_ex : 32'd0;
    assign rd_out = (state == 2'b10) ? rd_store : 5'd0;
endmodule