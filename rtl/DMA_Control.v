// module DMA_Control(
//     input wire clk,
//     input wire rst_n,
//     input wire dma_en,
//     input wire [31:0] addr,
//     // AW channel
//     input wire awready,
//     output reg [9:0] awaddr,
//     output reg awvalid,
//     // B channel
//     input wire [1:0] bresp,
//     input wire bvalid,
//     output wire bready,
//     // W channel
//     input wire wready,
//     output reg [31:0] wdata,
//     output reg wvalid
 
// );

//     reg [1:0] state; // 00 - defaut, 01 - config address, 10 - config byte length


//     always @(posedge clk or negedge rst_n) begin
//         if(!rst_n) begin
//             state <= 2'b00;
//         end
//         else begin
//             case(state)
//                 2'b00: begin
//                     if(dma_en) state <= 2'b01;
//                     else state <= state;
//                 end
//                 2'b01: begin
//                     if(awready & wready) state <= 2'b10;
//                     else state <= state;
//                 end
//                 2'b10: begin
//                     if(awready & wready) state <= 2'b00;
//                     else state <= state;
//                 end
//                 default: state <= 3'b000;
//             endcase
//         end
//     end

//     always @(*) begin
//         case(state)
//             2'b01: begin
//                 awaddr = 10'h18;
//                 awvalid = 1'b1;
//                 wdata = addr;
//                 wvalid = 1'b1;
//             end
//             2'b10: begin
//                 awaddr = 10'h28;
//                 awvalid = 1'b1;
//                 wdata = 32'd16;
//                 wvalid = 1'b1;
//             end
//             default: begin
//                 awaddr = 10'd0;
//                 awvalid = 1'b0;
//                 wdata = 32'd0;
//                 wvalid = 1'b0;
//             end
//         endcase
//     end


//     assign bready = 1'b1;
// endmodule
module DMA_Control(
    input clk,
    input rst_n,
    input start,
    input [31:0]source_addr,
    input [31:0]byte_length,
    input m_axi_lite_awready,
    input m_axi_lite_wready,
    input m_axi_lite_bvalid,
    input [1:0]m_axi_lite_bresp,
    output reg [9:0]m_axi_lite_awaddr,
    output reg m_axi_lite_awvalid,
    output reg m_axi_lite_bready,
    output reg [31:0]m_axi_lite_wdata,
    output reg m_axi_lite_wvalid
    );
    
    reg [2:0]state = 3'b000;
    reg [31:0]addr_source;
    reg [31:0]length_byte;
    
    always @(posedge clk or !rst_n)
    begin
    if (!rst_n) begin
        state <= 3'b000;
        m_axi_lite_awvalid <= 1'b0;
        m_axi_lite_wvalid <= 1'b0;
        m_axi_lite_bready <= 1'b0;
        m_axi_lite_wdata <= 32'b0;
        m_axi_lite_awaddr <= 32'b0;
    end
    else begin
        case (state)
        3'b000: begin
            if (start) begin 
                state <= 3'b001;
                addr_source <= source_addr;
                length_byte <= byte_length;
            end
            else begin 
                state <= 3'b000;
                m_axi_lite_awvalid <= 1'b0;
                m_axi_lite_wvalid <= 1'b0;
                m_axi_lite_bready <= 1'b0;
            end
        end
        
        3'b001: begin
            if (m_axi_lite_awready && m_axi_lite_wready) begin
                m_axi_lite_awaddr <= 10'd0;
                m_axi_lite_awvalid <= 1'b0;
                m_axi_lite_wdata <= 32'b0;
                m_axi_lite_wvalid <= 1'b0;
                m_axi_lite_bready <= 1'b1;
                state <= 3'b010;
            end
            else begin
                m_axi_lite_awaddr <= 10'h18;
                m_axi_lite_awvalid <= 1'b1;
                m_axi_lite_wdata <= addr_source;
                m_axi_lite_wvalid <= 1'b1;
            end
        end
        
        3'b010: begin        
            if (m_axi_lite_bvalid) begin
                m_axi_lite_bready <= 1'b0;
                state <= 3'b011;
            end
            else m_axi_lite_bready <= 1'b1;
        end
        
        3'b011: begin
            if (m_axi_lite_awready && m_axi_lite_wready) begin
                m_axi_lite_awaddr <= 10'h0;
                m_axi_lite_awvalid <= 1'b0;
                m_axi_lite_wdata <= 32'd0;
                m_axi_lite_wvalid <= 1'b0;
                m_axi_lite_bready <= 1'b1;
                state <= 3'b100;
            end
            else begin
                m_axi_lite_awaddr <= 10'h28;
                m_axi_lite_awvalid <= 1'b1;
                m_axi_lite_wdata <= length_byte;
                m_axi_lite_wvalid <= 1'b1;
            end
        end
        
        3'b100: begin        
            if (m_axi_lite_bvalid) begin
                m_axi_lite_bready <= 1'b0;
                state <= 3'b000;
            end
            else m_axi_lite_bready <= 1'b1;
        end
        
        default: state <= 3'b000;
        endcase
    end
    end
endmodule
