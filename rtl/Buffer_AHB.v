module Buffer_APB(
    input wire clk,
    input wire rst_n,
    input wire [31:0] s_apb_paddr,
    input wire s_apb_penable,
    input wire [2:0] s_apb_pprot,
    output reg [31:0] s_apb_prdata,
    output wire s_apb_pready,
    input wire s_apb_psel,
    output wire s_apb_pslverr,
    input wire [3:0] s_apb_pstrb,
    input wire [31:0] s_apb_pwdata,
    input wire s_apb_pwrite
);

    reg [31:0] ram[0:255];

    initial begin
        $readmemh("Test.mem", ram);
    end
    wire [7:0] byte0 = s_apb_pstrb[0] ? s_apb_pwdata[7:0] : 8'd0;
    wire [7:0] byte1 = s_apb_pstrb[1] ? s_apb_pwdata[15:8] : 8'd0;
    wire [7:0] byte2 = s_apb_pstrb[2] ? s_apb_pwdata[23:16] : 8'd0;
    wire [7:0] byte3 = s_apb_pstrb[3] ? s_apb_pwdata[31:24] : 8'd0; 
    wire [31:0] write_data = {byte3, byte2, byte1, byte0};
    // reg [31:0] current_addr;
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            s_apb_prdata <= 32'd0;
            // current_addr <= 32'd0;
        end
        else begin
            if(s_apb_pwrite & s_apb_penable) begin
                ram[s_apb_pwrite] <= write_data;
            end
            else if(s_apb_penable) begin
                s_apb_prdata <= ram[s_apb_pwrite];
            end
            else begin
                s_apb_prdata <= 32'd0;
            end
        end
    end

    assign s_apb_pslverr = 1'b1;
    assign s_apb_pready = 1'b1;
endmodule