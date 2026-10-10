`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.10.2026 10:22:35
// Design Name: 
// Module Name: tbint8
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

module npu_tb;

    // Clock and control
    reg clk;
    reg rst;
    reg start;

    // Matrix A
    reg signed [7:0] a00, a01, a02, a03;
    reg signed [7:0] a10, a11, a12, a13;
    reg signed [7:0] a20, a21, a22, a23;
    reg signed [7:0] a30, a31, a32, a33;

    // Matrix B
    reg signed [7:0] b00, b01, b02, b03;
    reg signed [7:0] b10, b11, b12, b13;
    reg signed [7:0] b20, b21, b22, b23;
    reg signed [7:0] b30, b31, b32, b33;

    // Output matrix
    wire signed [31:0] y00, y01, y02, y03;
    wire signed [31:0] y10, y11, y12, y13;
    wire signed [31:0] y20, y21, y22, y23;
    wire signed [31:0] y30, y31, y32, y33;

    wire done;

    // =========================================================
    // DUT
    // =========================================================

    npu_top uut (

        .clk(clk),
        .rst(rst),
        .start(start),

        // Matrix A
        .a00(a00), .a01(a01), .a02(a02), .a03(a03),
        .a10(a10), .a11(a11), .a12(a12), .a13(a13),
        .a20(a20), .a21(a21), .a22(a22), .a23(a23),
        .a30(a30), .a31(a31), .a32(a32), .a33(a33),

        // Matrix B
        .b00(b00), .b01(b01), .b02(b02), .b03(b03),
        .b10(b10), .b11(b11), .b12(b12), .b13(b13),
        .b20(b20), .b21(b21), .b22(b22), .b23(b23),
        .b30(b30), .b31(b31), .b32(b32), .b33(b33),

        // Output
        .y00(y00), .y01(y01), .y02(y02), .y03(y03),
        .y10(y10), .y11(y11), .y12(y12), .y13(y13),
        .y20(y20), .y21(y21), .y22(y22), .y23(y23),
        .y30(y30), .y31(y31), .y32(y32), .y33(y33),

        .done(done)
    );


    // =========================================================
    // CLOCK
    // 100 MHz clock = 10 ns period
    // =========================================================

    always #5 clk = ~clk;


    // =========================================================
    // TEST
    // =========================================================

    initial begin

        // Initialize
        clk   = 1'b0;
        rst   = 1'b1;
        start = 1'b0;

        // Matrix A
        a00 = 1;
        a01 = 2;
        a02 = 3;
        a03 = 4;

        a10 = 5;
        a11 = 6;
        a12 = 7;
        a13 = 8;

        a20 = 1;
        a21 = 2;
        a22 = 1;
        a23 = 2;

        a30 = 3;
        a31 = 4;
        a32 = 3;
        a33 = 4;


        // Matrix B
        b00 = 1;
        b01 = 0;
        b02 = 1;
        b03 = 0;

        b10 = 0;
        b11 = 1;
        b12 = 0;
        b13 = 1;

        b20 = 1;
        b21 = 1;
        b22 = 1;
        b23 = 1;

        b30 = 2;
        b31 = 2;
        b32 = 2;
        b33 = 2;


        // Reset
        #20;
        rst = 1'b0;

        // Start NPU
        #10;
        start = 1'b1;

        #10;
        start = 1'b0;


        // Wait for computation
        wait(done == 1'b1);

        #10;

        // Display result
        $display("-----------------------------------------");
        $display("        4x4 INT8 NPU RESULT");
        $display("-----------------------------------------");

        $display("Y =");
        $display("[%0d  %0d  %0d  %0d]",
                 y00, y01, y02, y03);

        $display("[%0d  %0d  %0d  %0d]",
                 y10, y11, y12, y13);

        $display("[%0d  %0d  %0d  %0d]",
                 y20, y21, y22, y23);

        $display("[%0d  %0d  %0d  %0d]",
                 y30, y31, y32, y33);

        $display("-----------------------------------------");

        #20;

        $finish;

    end

endmodule