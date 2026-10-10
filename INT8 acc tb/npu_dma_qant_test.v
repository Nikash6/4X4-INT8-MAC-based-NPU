`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.10.2026 11:41:14
// Design Name: 
// Module Name: npu_dma_qant_test
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

module npu_dma_quant_tb;

    reg clk;
    reg rst;
    reg start;

    reg [5:0] out_rd_addr;
    wire signed [7:0] out_rd_data;

    wire dma_done;
    wire npu_done;
    wire busy;
    wire done;

    // External memory interface
    wire mem_req;
    wire [15:0] mem_addr;
    wire mem_valid;
    wire [7:0] mem_rdata;

    reg [7:0] ext_mem [0:127];

    integer i, j;
    integer row, col;
    integer product_value;
    integer expected_val;
    integer error_count;

    reg signed [7:0] a_row_val [0:7];
    reg signed [7:0] b_diag_val [0:7];

    // Integrated DMA + NPU
    npu_dma_system dut (
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
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // Test data and external memory
    initial begin
        // A: each row contains one repeated signed value
        a_row_val[0] =  20;
        a_row_val[1] = -20;
        a_row_val[2] =  12;
        a_row_val[3] = -12;
        a_row_val[4] =   5;
        a_row_val[5] =  -5;
        a_row_val[6] =   0;
        a_row_val[7] =   1;

        // B: diagonal matrix values
        b_diag_val[0] =  10;
        b_diag_val[1] =  10;
        b_diag_val[2] = -12;
        b_diag_val[3] =  12;
        b_diag_val[4] =  30;
        b_diag_val[5] =  30;
        b_diag_val[6] =   1;
        b_diag_val[7] =   1;

        // Clear all 128 bytes
        for (i = 0; i < 128; i = i + 1)
            ext_mem[i] = 8'd0;

        // Load matrix A into addresses 0-63
        for (i = 0; i < 8; i = i + 1)
            for (j = 0; j < 8; j = j + 1)
                ext_mem[i*8+j] = a_row_val[i];

        // Load matrix B into addresses 64-127
        for (i = 0; i < 8; i = i + 1)
            for (j = 0; j < 8; j = j + 1)
                if (i == j)
                    ext_mem[64+i*8+j] = b_diag_val[j];
    end

    // Combinational external memory model
    assign mem_valid = mem_req;
    assign mem_rdata = ext_mem[mem_addr[6:0]];

    // Reset, start, and verification
    initial begin
        rst = 1'b1;
        start = 1'b0;
        out_rd_addr = 6'd0;
        error_count = 0;

        repeat (5) @(posedge clk);
        @(negedge clk);
        rst = 1'b0;

        repeat (2) @(posedge clk);
        @(negedge clk);
        start = 1'b1;

        @(negedge clk);
        start = 1'b0;

        // Wait for the integrated operation to finish
        wait (done === 1'b1);
        @(negedge clk);

        $display("------------------------------------");
        $display("DMA + NPU SATURATION TEST");
        $display("------------------------------------");

        // Verify every output with QUANT_SHIFT = 0
        for (row = 0; row < 8; row = row + 1) begin
            for (col = 0; col < 8; col = col + 1) begin
                out_rd_addr = row*8 + col;
                #1;

                // Because B is diagonal and each A row is constant:
                // Y[row][col] = A[row][0] * B[col][col]
                product_value =
                    $signed(a_row_val[row]) *
                    $signed(b_diag_val[col]);

                // Expected INT8 saturation
                if (product_value > 127)
                    expected_val = 127;
                else if (product_value < -128)
                    expected_val = -128;
                else
                    expected_val = product_value;

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
            $display("PASS: All 64 saturated outputs are correct.");
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
