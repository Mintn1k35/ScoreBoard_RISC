module Core_State(
    input wire clk,
    input wire start,
    input wire restart,
    input wire config_done,
    output wire reset_signal
);

    parameter OFF = 2'b00;
    parameter INITIAL_ON = 2'b01;
    parameter ON = 2'b10;

    reg [1:0] cpu_state;

    always @(posedge clk or negedge rst_n) begin
        case(cpu_state)
            OFF: begin
                if(start | restart) cpu_state <= INITIAL_ON;
                else cpu_state <= cpu_state;
            end
            INITIAL_ON: begin
                if(config_done) cpu_state <= ON;
                else cpu_state <= cpu_state;
            end
            ON: begin
                if(restart) cpu_state <= INITIAL_ON;
                else if(start) cpu_state <= OFF;
                else cpu_state <= cpu_state;
            end
            default: cpu_state <= OFF;
        endcase
    end

    assign reset_signal = (cpu_state == INITIAL_ON) ? 1'b0 : 1'b1;

endmodule