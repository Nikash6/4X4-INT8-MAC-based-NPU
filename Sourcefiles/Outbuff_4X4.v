`timescale 1ns / 1ps

module output_buffer (

    input wire clk,
    input wire rst,

    // Write interface
    input wire        wr_en,
    input wire [3:0]  wr_addr,
    input wire signed [31:0] wr_data,

    // Read interface
    input wire [3:0]  rd_addr,
    output reg signed [31:0] rd_data

);

    // 16 x 32-bit memory
    reg signed [31:0] mem [0:15];

    integer i;

    // ---------------------------------------------------------
    // Write
    // ---------------------------------------------------------

    always @(posedge clk) begin

        if (rst) begin

            for (i = 0; i < 16; i = i + 1)
                mem[i] <= 32'sd0;

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