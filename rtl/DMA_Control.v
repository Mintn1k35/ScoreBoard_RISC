module DMA_Control(
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire dma_rst_done,
    input wire [31:0] source_addr,
    input wire [31:0] byte_length,

    // AW channel of AXI-lite
    input wire awready,
    output reg [9:0] awaddr,
    output reg awvalid,
    // W channel of AXI-lite
    input wire wready,
    output reg [31:0] wdata,
    output reg wvalid,
    // AR channel
    input wire arready,
    output wire [9:0] araddr,
    output wire arvalid,
    // B channel
    input wire [1:0] bresp,
    input wire bvalid,
    output wire bready,
    // R channel
    input wire [31:0] rdata,
    input wire [1:0] rresp,
    input wire rvalid,
    output wire rready
);
    parameter DEFAUT = 2'b00;
    parameter SET_RUN_BIT = 2'b01;
    parameter SET_SOURCE_ADDR = 2'b10;
    parameter SET_BYTE_LENGTH = 2'b11;
    reg [1:0] mm2s_state; // 00 - default, 01 - config bit run, 10 config source_addr, 11 - config byte-length
    reg [1:0] s2mm_state;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            mm2s_state <= 2'b00;
        end
        else begin
            case(mm2s_state)
                DEFAUT: begin
                    if(start & dma_rst_done) mm2s_state <= SET_RUN_BIT;
                    else mm2s_state <= mm2s_state;
                end
                SET_RUN_BIT: begin
                    if(awready) mm2s_state <= SET_SOURCE_ADDR;
                    else mm2s_state <= mm2s_state;
                end
                SET_SOURCE_ADDR: begin
                    if(awready) mm2s_state <= SET_BYTE_LENGTH;
                    else mm2s_state <= mm2s_state;
                end
                SET_BYTE_LENGTH: begin
                    if(awready) mm2s_state <= DEFAUT;
                    else mm2s_state <= mm2s_state;
                end
                default: mm2s_state <= DEFAUT;
            endcase
        end
    end

    always @(*) begin
        case(mm2s_state)
            DEFAUT: begin
                awaddr = 10'd0;
                awvalid = 1'b0;
                wdata = 32'd0;
                wvalid = 1'b0;
            end
            SET_RUN_BIT: begin
                awaddr = 10'd0;
                awvalid = 1'b1;
                wdata = 32'd1;
                wvalid = 1'b1;
            end
            SET_SOURCE_ADDR: begin
                awaddr = 10'h18;
                awvalid = 1'b1;
                wdata = source_addr;
                wvalid = 1'b1;
            end
            SET_BYTE_LENGTH: begin
                awaddr = 10'h28;
                awvalid = 1'b1;
                wdata = 32'd20;
                wvalid = 1'b1;
            end
            default: begin
                awaddr = 10'h0;
                awvalid = 1'b0;
                wdata = 32'd0;
                wvalid = 1'b0;
            end
        endcase
    end

endmodule