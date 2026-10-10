`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.10.2026 11:48:07
// Design Name: 
// Module Name: npu_dma_shift_tb
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

module npu_dma_shift_tb;

    reg clk, rst, start;
    reg [5:0] out_rd_addr;
    wire signed [7:0] out_rd_data;

    wire dma_done, npu_done, busy, done;
    wire mem_req;
    wire [15:0] mem_addr;
    wire mem_valid;
    wire [7:0] mem_rdata;

    reg [7:0] ext_mem [0:127];

    integer i, j, row, col;
    integer product_value;
    integer expected_val;
    integer error_count;

    reg signed [7:0] a_row_val [0:7];
    reg signed [7:0] b_diag_val [0:7];

    // DUT: integrated system with shift = 2
    npu_dma_system #(
        .QUANT_SHIFT(2)
    ) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .out_rd_addr(out_rd_addr),
        .out_rd_data(out_rd_data),
        .dma_done(dma_done),
        .npu_done(npu_done),
        .busy(busy),
        .done(done),
        .mem_req(mem_req),
        .mem_addr(mem_addr),
        .mem_valid(mem_valid),
        .mem_rdata(mem_rdata)
    );

    // 100 MHz clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test matrices and external memory
    initial begin
        a_row_val[0] =  100;
        a_row_val[1] = -100;
        a_row_val[2] =   12;
        a_row_val[3] =  -12;
        a_row_val[4] =    5;
        a_row_val[5] =   -5;
        a_row_val[6] =    0;
        a_row_val[7] =    1;

        b_diag_val[0] = 100;
        b_diag_val[1] = 100;
        b_diag_val[2] = -12;
        b_diag_val[3] =  12;
        b_diag_val[4] =  30;
        b_diag_val[5] =  30;
        b_diag_val[6] =   1;
        b_diag_val[7] =   1;

        for (i = 0; i < 128; i = i + 1)
            ext_mem[i] = 8'd0;

        // Matrix A: repeated values in each row
        for (i = 0; i < 8; i = i + 1)
            for (j = 0; j < 8; j = j + 1)
                ext_mem[i*8+j] = a_row_val[i];

        // Matrix B: diagonal matrix
        for (i = 0; i < 8; i = i + 1)
            for (j = 0; j < 8; j = j + 1)
                if (i == j)
                    ext_mem[64+i*8+j] = b_diag_val[j];
    end

    // Combinational external memory
    assign mem_valid = mem_req;
    assign mem_rdata = ext_mem[mem_addr[6:0]];

    // Reset, start and verification
    initial begin
        rst = 1;
        start = 0;
        out_rd_addr = 0;
        error_count = 0;

        repeat (5) @(posedge clk);
        @(negedge clk);
        rst = 0;

        repeat (2) @(posedge clk);
        @(negedge clk);
        start = 1;

        @(negedge clk);
        start = 0;

        wait (done === 1'b1);
        @(negedge clk);

        $display("------------------------------------");
        $display("DMA + NPU QUANT_SHIFT=2 TEST");
        $display("------------------------------------");

        for (row = 0; row < 8; row = row + 1) begin
            for (col = 0; col < 8; col = col + 1) begin
                out_rd_addr = row*8 + col;
                #1;

                // Expected matrix product
                product_value =
                    $signed(a_row_val[row]) *
                    $signed(b_diag_val[col]);

                // Signed arithmetic right shift by 2
                expected_val = product_value >>> 2;

                // Saturate to signed INT8 range
                if (expected_val > 127)
                    expected_val = 127;
                else if (expected_val < -128)
                    expected_val = -128;

                if ($signed(out_rd_data) !== expected_val) begin
                    $display(
                        "FAIL Y[%0d][%0d]: expected %0d, got %0d",
                        row, col, expected_val, $signed(out_rd_data)
                    );
                    error_count = error_count + 1;
                end
            end
        end

        if (error_count == 0)
            $display("PASS: All 64 shifted outputs are correct.");
        else
            $display("FAIL: %0d output errors.", error_count);

        $display("------------------------------------");
        $finish;
    end

    // Timeout
    initial begin
        #200000;
        $display("ERROR: Simulation timed out.");
        $finish;
    end

endmodule
