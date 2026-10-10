`timescale 1ns / 1ps

module input_buffer (

    input wire clk,
    input wire rst,

    // Write interface
    input wire        wr_en,
    input wire [4:0]  wr_addr,
    input wire signed [7:0] wr_data,

    // Read interface
    input wire [4:0]  rd_addr,
    output reg signed [7:0] rd_data

);

    // 32 x 8-bit memory
    reg signed [7:0] mem [0:31];

    integer i;

    // ---------------------------------------------------------
    // Write
    // ---------------------------------------------------------

    always @(posedge clk) begin

        if (rst) begin

            for (i = 0; i < 32; i = i + 1)
                mem[i] <= 8'sd0;

        end

        else if (wr_en) begin

            mem[wr_addr] <= wr_data;

        end

    end


    // ---------------------------------------------------------
    // Read
    // ---------------------------------------------------------

    always @(*) begin

        rd_data = mem[rd_addr];

    end

endmodule