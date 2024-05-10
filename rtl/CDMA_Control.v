module CDMA_Control(
    input wire clk,
    input wire rst_n,
    input wire dma_en,
    input wire [31:0] read_addr,
    input wire [31:0] write_addr,
    input wire [31:0] byte_length,
    output wire dma_done,
    // AW channel
    input wire awready,
    output reg [9:0] awaddr,
    output reg awvalid,
    // B channel
    input wire [1:0] bresp,
    input wire bvalid,
    output wire bready,
    // W channel
    input wire wready,
    output reg [31:0] wdata,
    output reg wvalid
 
);
    parameter DEFAULT = 2'b00;
    parameter SET_READ_ADDR = 2'b01;
    parameter SET_WRITE_ADDR = 2'b10;
    parameter SET_BYTE_LENGTH = 2'b11;

    reg [1:0] state; // 00 - defaut, 01 - config read addr, 10 - config write addr, 11 - config byte length


    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= 2'b00;
        end
        else begin
            case(state)
                DEFAULT: begin
                    if(dma_en) state <= SET_READ_ADDR;
                    else state <= state;
                end
                SET_READ_ADDR: begin
                    if(awready & wready) state <= SET_WRITE_ADDR;
                    else state <= state;
                end
                SET_WRITE_ADDR: begin
                    if(awready & wready) state <= SET_BYTE_LENGTH;
                    else state <= state;
                end
                SET_BYTE_LENGTH: begin
                    if(awready & wready) state <= DEFAULT;
                end
                default: state <= DEFAULT;
            endcase
        end
    end

    always @(*) begin
        case(state)
            SET_READ_ADDR: begin
                awaddr = 10'h18;
                awvalid = 1'b1;
                wdata = read_addr;
                wvalid = 1'b1;
            end
            SET_WRITE_ADDR: begin
                awaddr = 10'h20;
                awvalid = 1'b1;
                wdata = write_addr;
                wvalid = 1'b1;
            end
            SET_BYTE_LENGTH: begin
                awaddr = 10'h28;
                awvalid = 1'b1;
                wdata = byte_length;
                wvalid = 1'b1;
            end
            default: begin
                awaddr = 10'd0;
                awvalid = 1'b0;
                wdata = 32'd0;
                wvalid = 1'b0;
            end
        endcase
    end


    assign bready = 1'b1;
    assign dma_done = ((state == SET_BYTE_LENGTH) & (awready & wready));
endmodule
// module CDMA_Control(
//     input clk,
//     input rst_n,
//     input start,
//     input [31:0]source_addr,
//     input [31:0]byte_length,
//     input m_axi_lite_awready,
//     input m_axi_lite_wready,
//     input m_axi_lite_bvalid,
//     input [1:0]m_axi_lite_bresp,
//     output reg [9:0]m_axi_lite_awaddr,
//     output reg m_axi_lite_awvalid,
//     output reg m_axi_lite_bready,
//     output reg [31:0]m_axi_lite_wdata,
//     output reg m_axi_lite_wvalid
//     );
    
//     reg [2:0]state = 3'b000;
//     reg [31:0]addr_source;
//     reg [31:0]length_byte;
    
//     always @(posedge clk or !rst_n)
//     begin
//     if (!rst_n) begin
//         state <= 3'b000;
//         m_axi_lite_awvalid <= 1'b0;
//         m_axi_lite_wvalid <= 1'b0;
//         m_axi_lite_bready <= 1'b0;
//         m_axi_lite_wdata <= 32'b0;
//         m_axi_lite_awaddr <= 32'b0;
//     end
//     else begin
//         case (state)
//         3'b000: begin
//             if (start) begin 
//                 state <= 3'b001;
//                 addr_source <= source_addr;
//                 length_byte <= byte_length;
//             end
//             else begin 
//                 state <= 3'b000;
//                 m_axi_lite_awvalid <= 1'b0;
//                 m_axi_lite_wvalid <= 1'b0;
//                 m_axi_lite_bready <= 1'b0;
//             end
//         end
        
//         3'b001: begin
//             if (m_axi_lite_awready && m_axi_lite_wready) begin
//                 m_axi_lite_awaddr <= 10'd0;
//                 m_axi_lite_awvalid <= 1'b0;
//                 m_axi_lite_wdata <= 32'b0;
//                 m_axi_lite_wvalid <= 1'b0;
//                 m_axi_lite_bready <= 1'b1;
//                 state <= 3'b010;
//             end
//             else begin
//                 m_axi_lite_awaddr <= 10'h18;
//                 m_axi_lite_awvalid <= 1'b1;
//                 m_axi_lite_wdata <= addr_source;
//                 m_axi_lite_wvalid <= 1'b1;
//             end
//         end
        
//         3'b010: begin        
//             if (m_axi_lite_bvalid) begin
//                 m_axi_lite_bready <= 1'b0;
//                 state <= 3'b011;
//             end
//             else m_axi_lite_bready <= 1'b1;
//         end
        
//         3'b011: begin
//             if (m_axi_lite_awready && m_axi_lite_wready) begin
//                 m_axi_lite_awaddr <= 10'h0;
//                 m_axi_lite_awvalid <= 1'b0;
//                 m_axi_lite_wdata <= 32'd0;
//                 m_axi_lite_wvalid <= 1'b0;
//                 m_axi_lite_bready <= 1'b1;
//                 state <= 3'b100;
//             end
//             else begin
//                 m_axi_lite_awaddr <= 10'h28;
//                 m_axi_lite_awvalid <= 1'b1;
//                 m_axi_lite_wdata <= length_byte;
//                 m_axi_lite_wvalid <= 1'b1;
//             end
//         end
        
//         3'b100: begin        
//             if (m_axi_lite_bvalid) begin
//                 m_axi_lite_bready <= 1'b0;
//                 state <= 3'b000;
//             end
//             else m_axi_lite_bready <= 1'b1;
//         end
        
//         default: state <= 3'b000;
//         endcase
//     end
//     end
// endmodule
