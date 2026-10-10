`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.10.2026 11:06:51
// Design Name: 
// Module Name: Npu_8x8_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module npu_8x8_top #(
    parameter QUANT_SHIFT = 0
)(
    input wire clk,
    input wire rst,

    // Input matrix loader
    input wire load_en,
    input wire [6:0] load_addr,
    input wire signed [7:0] load_data,

    // Start computation
    input wire start,

    // Read quantized output
    input wire [5:0] out_rd_addr,
    output wire signed [7:0] out_rd_data,

    output wire done
);

    // ---------------------------------------------------------
    // Local input memories
    // ---------------------------------------------------------

    reg signed [7:0] a_mem [0:63];
    reg signed [7:0] b_mem [0:63];

    // Quantized output memory
    reg signed [7:0] c_mem [0:63];

    integer i;

    // ---------------------------------------------------------
    // Controller
    // ---------------------------------------------------------

    localparam IDLE    = 2'd0;
    localparam COMPUTE = 2'd1;
    localparam FINISH  = 2'd2;

    reg [1:0] state;

    reg [2:0] row;
    reg [2:0] col;
    reg [2:0] k;

    reg signed [31:0] acc;

    // Matrix indexing
    wire [5:0] a_index;
    wire [5:0] b_index;
    wire [5:0] c_index;

    assign a_index = {row, k};
    assign b_index = {k, col};
    assign c_index = {row, col};

    // ---------------------------------------------------------
    // MAC datapath
    // ---------------------------------------------------------

    wire signed [15:0] product;

    assign product =
        $signed(a_mem[a_index]) *
        $signed(b_mem[b_index]);

    wire signed [31:0] product_extended;

    assign product_extended =
        {{16{product[15]}}, product};

    wire signed [31:0] sum_next;

    assign sum_next = acc + product_extended;

    // ---------------------------------------------------------
    // INT32 to INT8 quantization
    // ---------------------------------------------------------

    wire signed [7:0] quantized_result;

    quantization quantizer (
        .data_in(sum_next),
        .shift(QUANT_SHIFT),
        .data_out(quantized_result)
    );

    // ---------------------------------------------------------
    // Input loading and computation
    // ---------------------------------------------------------

    always @(posedge clk) begin

        if (rst) begin

            state <= IDLE;
            row   <= 0;
            col   <= 0;
            k     <= 0;
            acc   <= 0;

            for (i = 0; i < 64; i = i + 1) begin
                a_mem[i] <= 0;
                b_mem[i] <= 0;
                c_mem[i] <= 0;
            end

        end else begin

            // Load matrices only when idle.
            if (load_en && state == IDLE) begin

                if (load_addr < 7'd64)
                    a_mem[load_addr[5:0]] <= load_data;
                else
                    b_mem[load_addr[5:0]] <= load_data;

            end

            case (state)

                // ---------------------------------------------
                // IDLE
                // ---------------------------------------------

                IDLE: begin

                    if (start) begin
                        row   <= 0;
                        col   <= 0;
                        k     <= 0;
                        acc   <= 0;
                        state <= COMPUTE;
                    end

                end

                // ---------------------------------------------
                // Compute one dot product at a time
                // ---------------------------------------------

                COMPUTE: begin

                    if (k == 3'd7) begin

                        // Include the final product.
                        c_mem[c_index] <= quantized_result;

                        // Prepare the next output.
                        acc <= 0;
                        k   <= 0;

                        if (col == 3'd7) begin

                            col <= 0;

                            if (row == 3'd7) begin
                                state <= FINISH;
                            end else begin
                                row <= row + 1'b1;
                            end

                        end else begin
                            col <= col + 1'b1;
                        end

                    end else begin

                        acc <= sum_next;
                        k   <= k + 1'b1;

                    end

                end

                // ---------------------------------------------
                // Finished
                // ---------------------------------------------

                FINISH: begin

                    if (!start)
                        state <= IDLE;

                end

                default: begin
                    state <= IDLE;
                end

            endcase

        end

    end

    // Asynchronous output-buffer read
    assign out_rd_data = c_mem[out_rd_addr];

    assign done = (state == FINISH);

endmodule
