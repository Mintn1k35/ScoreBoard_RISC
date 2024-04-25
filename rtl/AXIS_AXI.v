module AXIS_AXI(
    input wire clk,
    input wire rst_n,
    input wire [31:0] des_addr,
    input wire addr_valid,
    // AXIS interface
    input wire [31:0] tdata,
    input wire [3:0] tkeep,
    input wire tlast,
    input wire tvalid,
    output reg tready,
    // AW channel
    input wire awready,
    output reg [31:0] awaddr,
    output wire [1:0] awburst,
    output wire [3:0] awcache,
    output wire [7:0] awlen,
    output wire [2:0] awsize,
    output reg awvalid,
    // W channel
    input wire wready,
    output reg [31:0] wdata,
    output reg wlast,
    output reg wvalid,
    output wire [3:0] wstrb,
    // B channel
    input wire bvalid,
    input wire [1:0] bresp,
    output wire bready,
    // AR channel
    input wire arready,
    output wire [31:0] araddr,
    output wire [1:0] arburst,
    output wire [3:0] arcache,
    output wire [7:0] arlen,
    output wire [2:0] arsize,
    output wire arvalid,
    // // R channel
    input wire [31:0] rdata,
    input wire rlast,
    input wire rvalid,
    output wire rready
);

    parameter DEFAULT = 2'b00;
    parameter SET_AWADDR_OR_ARADDR = 2'b01;
    parameter SET_DATA_OR_RREADY = 2'b10;
    parameter WRITE_READ_DONE = 2'b11;
    reg [1:0] state;
    // reg [32:0] max_addr;
    // reg read_en;
    // always @(posedge clk or negedge rst_n) begin
    //     if(!rst_n) begin
    //         max_addr <= 32'd0;
    //     end
    //     else begin
    //         if(des_addr >= max_addr) begin
    //             max_addr <= des_addr;
    //             read_en = 1'b0;
    //         end
    //         else begin
    //             max_addr <= max_addr;
    //             if(state == WRITE_READ_DONE) read_en = 1'b1;
    //             else read_en = 1'b0;
    //         end
    //     end
    // end


    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= DEFAULT;
            // read_en <= 1'b0;
        end
        else begin
            // if(read_en) begin
            //     case(state)
            //         DEFAULT: begin
            //             if(read_en) state <= SET_AWADDR_OR_ARADDR;
            //             else state <= state;
            //         end
            //         SET_AWADDR_OR_ARADDR: begin
            //             if(arready) state <= SET_DATA_OR_RREADY;
            //             else state <= state;
            //         end
            //         SET_DATA_OR_RREADY: begin
            //             if(rvalid & rlast) state <= WRITE_READ_DONE;
            //         end
            //         WRITE_READ_DONE: begin
            //             state <= DEFAULT;
            //         end
            //         default: state <= DEFAULT;
            //     endcase
            // end
            // else begin
                case(state)
                    DEFAULT: begin
                        if(tvalid) state <= SET_AWADDR_OR_ARADDR;
                        else state <= state;
                    end
                    SET_AWADDR_OR_ARADDR: begin
                        if(awready) state <= SET_DATA_OR_RREADY;
                        else state <= state;
                    end
                    SET_DATA_OR_RREADY: begin
                        if(tlast) state <= WRITE_READ_DONE;
                        else state <= state;
                    end
                    WRITE_READ_DONE: begin
                        if(bvalid) state <= DEFAULT;
                        else state <= state;
                    end
                    default: state <= DEFAULT;
                endcase
            end
        // end
    end

    always @(*) begin
        // if(read_en) begin
        //     case(state)
        //         DEFAULT: begin
        //             awaddr = 32'd0;
        //             awvalid = 1'b0;
        //             wdata = 32'd0;
        //             wvalid = 1'b0;
        //             wlast = 1'b0;
        //             tready = 1'b0;
        //             araddr = 32'd0;
        //             arvalid = 1'b0;
        //             rready = 1'b0;
        //         end
        //         SET_AWADDR_OR_ARADDR: begin
        //             awaddr = 32'd0;
        //             awvalid = 1'b0;
        //             wdata = 32'd0;
        //             wvalid = 1'b0;
        //             wlast = 1'b0;
        //             tready = 1'b0;
        //             araddr = 32'd0;
        //             arvalid = 1'b1;
        //             rready = 1'b0;
        //         end
        //         SET_DATA_OR_RREADY: begin
        //             awvalid = 1'b0;
        //             wdata = 32'd0;
        //             wvalid = 1'b0;
        //             wlast = 1'b0;
        //             tready = 1'b0;
        //             araddr = 32'd0;
        //             arvalid = 1'b0;
        //             rready = 1'b1;
        //         end
        //         default: begin
        //             awaddr = 32'd0;
        //             awvalid = 1'b0;
        //             wdata = 32'd0;
        //             wvalid = 1'b0;
        //             wlast = 1'b0;
        //             tready = 1'b0;
        //             araddr = 32'd0;
        //             arvalid = 1'b0;
        //             rready = 1'b0;
        //         end
        //     endcase        
        // end
        // else begin
            case(state)
                DEFAULT: begin
                    awaddr = 32'd0;
                    awvalid = 1'b0;
                    wdata = 32'd0;
                    wvalid = 1'b0;
                    wlast = 1'b0;
                    tready = 1'b0;
                    // araddr = 32'd0;
                    // arvalid = 1'b0;
                    // rready = 1'b0;
                end
                SET_AWADDR_OR_ARADDR: begin
                    awaddr = des_addr;
                    awvalid = 1'b1;
                    wdata = 32'd0;
                    wvalid = 1'b0;
                    wlast = 1'b0;
                    tready = 1'b0;
                    // araddr = 32'd0;
                    // arvalid = 1'b0;
                    // rready = 1'b0;
                end
                SET_DATA_OR_RREADY: begin
                    awvalid = 1'b0;
                    wdata = tdata;
                    wvalid = 1'b1;
                    wlast = tlast;
                    tready = 1'b1;
                    // araddr = 32'd0;
                    // arvalid = 1'b0;
                    // rready = 1'b0;
                end
                default: begin
                    awaddr = 32'd0;
                    awvalid = 1'b0;
                    wdata = 32'd0;
                    wvalid = 1'b0;
                    wlast = 1'b0;
                    tready = 1'b0;
                    // araddr = 32'd0;
                    // arvalid = 1'b0;
                    // rready = 1'b0;
                end
            endcase
        // end
        
    end

    assign awburst = 2'b1;
    assign awcache = 4'd11;
    assign awlen = 8'd4;
    assign awsize = 3'd2;
    assign wstrb = 4'hf;
    assign bready = 1'b1;
    assign arburst = 2'd1;
    assign arcache = 4'd7;
    assign arlen = 8'd0;
    assign arsize = 3'd2;
    assign arvalid = addr_valid;
    assign rready = 1'b1;
    assign araddr = des_addr;
endmodule