module Core_State(
    input wire clk,
    input wire start,
    input wire restart,
    input wire load_os_done,
    output wire loading_os,
);

    parameter OFF = 2'b00;
    parameter LOAD_OS = 2'b01;
    parameter ON = 2'b10;

    reg [1:0] cpu_state;

    always @(posedge clk or negedge rst_n) begin
        case(cpu_state)
            OFF: begin
                if(start | restart) cpu_state <= LOAD_OS;
                else cpu_state <= cpu_state;
            end
            LOAD_OS: begin
                if(load_os_done) cpu_state <= ON;
                else cpu_state <= cpu_state;
            end
            ON: begin
                if(restart) cpu_state <= LOAD_OS;
                else if(start) cpu_state <= OFF;
                else cpu_state <= cpu_state;
            end
            default: cpu_state <= OFF;
        endcase
    end

    assign reset_signal = (cpu_state == INITIAL_ON) ? 1'b1 : 1'b0;

endmodule