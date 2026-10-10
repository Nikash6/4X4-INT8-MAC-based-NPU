`timescale 1ns / 1ps

module npu_controller (

    input wire clk,
    input wire rst,
    input wire start,

    output reg enable,
    output reg clear,
    output reg done,

    output reg [1:0] k
);

    localparam IDLE    = 2'd0;
    localparam CLEAR_S = 2'd1;
    localparam COMPUTE = 2'd2;
    localparam DONE_S  = 2'd3;

    reg [1:0] state;
    reg [1:0] next_state;
    reg [1:0] next_k;


    // =========================================================
    // STATE REGISTER
    // =========================================================

    always @(posedge clk) begin

        if (rst) begin
            state <= IDLE;
            k     <= 2'd0;
        end

        else begin
            state <= next_state;
            k     <= next_k;
        end

    end


    // =========================================================
    // NEXT STATE + K
    // =========================================================

    always @(*) begin

        next_state = state;
        next_k     = k;

        case (state)

            IDLE: begin

                next_k = 2'd0;

                if (start)
                    next_state = CLEAR_S;

            end


            CLEAR_S: begin

                next_k     = 2'd0;
                next_state = COMPUTE;

            end


            COMPUTE: begin

                if (k == 2'd3) begin

                    next_state = DONE_S;
                    next_k     = 2'd3;

                end

                else begin

                    next_k = k + 1'b1;

                end

            end


            DONE_S: begin

                if (!start)
                    next_state = IDLE;

            end


            default: begin

                next_state = IDLE;
                next_k     = 2'd0;

            end

        endcase

    end


    // =========================================================
    // CONTROL SIGNALS
    // =========================================================

    always @(*) begin

        enable = 1'b0;
        clear  = 1'b0;
        done   = 1'b0;

        case (state)

            IDLE: begin

                enable = 1'b0;
                clear  = 1'b0;
                done   = 1'b0;

            end


            CLEAR_S: begin

                enable = 1'b0;
                clear  = 1'b1;
                done   = 1'b0;

            end


            COMPUTE: begin

                enable = 1'b1;
                clear  = 1'b0;
                done   = 1'b0;

            end


            DONE_S: begin

                enable = 1'b0;
                clear  = 1'b0;
                done   = 1'b1;

            end

        endcase

    end

endmodule