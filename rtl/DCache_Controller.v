module DCache_Controller(
	// Input signals
	input wire clk,
	input wire rst_n,
	input wire read_mem,
	input wire write_mem,
	input wire [31:0] addr,
	input wire addr_valid,
	input wire [31:0] write_data,
	input wire write_data_valid,
	input wire awready,
	input wire [1:0] bresp,
	input wire bvalid,
	input wire wready,
	input wire arready,
	input wire [31:0] rdata,
	input wire rlast,
	input wire rvalid,
	input wire cache_rst_done,
	// Output signals
	output wire mem_done,
	output wire [31:0] result,
	output wire [31:0] awaddr,
	output wire [1:0] awburst,
	output wire [3:0] awcache,
	output wire [7:0] awlen,
	output wire [2:0] awsize,
	output reg awvalid,
	output reg bready,
	output wire [31:0]	wdata,
	output reg wlast,
	output reg [3:0] wstrb,
	output reg wvalid,
	output wire [31:0] araddr,
	output wire [1:0] arburst,
	output wire [3:0] arcache,
	output wire [7:0] arlen,
	output wire [2:0] arsize,
	output reg arvalid,
	output reg rready
);

    reg [1:0] write_state = 2'b00; 	
    reg [1:0] pre_state, pre_state1;
    reg [1:0] read_state = 2'b00;

	assign awaddr = addr;
	assign wdata = write_data;
	assign araddr = addr;
	assign result = rdata;
	assign awburst = (rst_n & write_mem) ? 2'b00 : 2'bz;
	assign awlen = (rst_n & write_mem) ? 8'd0 : 8'bz;
	assign awcache = (rst_n & write_mem) ? 4'd11 : 4'bz;
	assign awsize = (rst_n & write_mem) ? 3'd2 : 3'bz;
	assign arburst = (rst_n & !write_mem) ? 2'b00 : 2'bz;
	assign arlen = (rst_n & !write_mem) ? 8'd0 : 8'bz;
	assign arcache = (rst_n & !write_mem) ? 4'd7 : 4'bz;
	assign arsize = (rst_n & !write_mem) ? 3'd2 : 3'bz;
	
	always @(posedge clk)
	begin
		if (!rst_n)
			begin
				arvalid = 1'b0;
				awvalid = 1'b0;
				rready = 1'b0;
				wvalid = 1'b0;
			end
		else begin
			if (write_mem)
			begin
			    case(write_state)
			    2'b00: begin
			         if (pre_state == 2'b11) awvalid = 1'b0;
			         else awvalid = addr_valid;
			         pre_state=2'b00;
			         if (awready) begin awvalid = 1'b0; write_state = 2'b01; end
			    end
			    2'b01: begin
			         wvalid = write_data_valid;
			         wlast = 1'b1;
			         wstrb = 4'b1111;
			         pre_state = 2'b01;
			         if (wready) begin 
			             write_state = 2'b10;
			         end
			    end
			    2'b10: begin
			         wlast = 1'b0;
			         wstrb = 4'b0000;
			         wvalid = 1'b0;
			         bready = 1'b1;
			         pre_state = 2'b10;
			         if (bvalid) begin bready = 1'b0; write_state = 2'b11; end
			    end 
			    2'b11: begin
			         pre_state = 2'b11;
			         if (mem_done) write_state = 2'b00; 
			    end
			    endcase         
			end
			if (read_mem == 1'b1)
			begin
			    case(read_state)
			    2'b00: begin
			         if (pre_state1 == 2'b10) arvalid = 1'b0;
			         else arvalid = addr_valid;
			         pre_state1 = 2'b00;
			         if (arready) begin arvalid = 1'b0; read_state = 2'b01; end
			    end
			    2'b01: begin
			         rready = 1'b1;
			         if (rvalid) read_state = 2'b10;
			    end
			    2'b10: begin
			         pre_state1 = 2'b10;
			         rready = 1'b0;
			         if (mem_done) read_state = 2'b00;
			    end  
			    endcase
			end
		end
	end
	assign mem_done = ((rlast == 1'b1) | ((bvalid == 1'b1) & (bresp == 2'b00)));
endmodule