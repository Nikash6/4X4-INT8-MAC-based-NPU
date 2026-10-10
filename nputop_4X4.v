`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.10.2026 10:18:24
// Design Name: 
// Module Name: nputop
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

module npu_top (

    input wire clk,
    input wire rst,
    input wire start,

    // Matrix A
    input signed [7:0] a00, a01, a02, a03,
    input signed [7:0] a10, a11, a12, a13,
    input signed [7:0] a20, a21, a22, a23,
    input signed [7:0] a30, a31, a32, a33,

    // Matrix B
    input signed [7:0] b00, b01, b02, b03,
    input signed [7:0] b10, b11, b12, b13,
    input signed [7:0] b20, b21, b22, b23,
    input signed [7:0] b30, b31, b32, b33,

    // Output
    output signed [31:0] y00, y01, y02, y03,
    output signed [31:0] y10, y11, y12, y13,
    output signed [31:0] y20, y21, y22, y23,
    output signed [31:0] y30, y31, y32, y33,

    output wire done
);

    wire enable;
    wire clear;

    wire [1:0] k;

    wire signed [31:0] c00, c01, c02, c03;
    wire signed [31:0] c10, c11, c12, c13;
    wire signed [31:0] c20, c21, c22, c23;
    wire signed [31:0] c30, c31, c32, c33;


    // ---------------------------------------------------------
    // Controller
    // ---------------------------------------------------------

    npu_controller controller (

        .clk(clk),
        .rst(rst),
        .start(start),

        .enable(enable),
        .clear(clear),
        .done(done),

        .k(k)

    );


    // ---------------------------------------------------------
    // 4x4 MAC Array
    // ---------------------------------------------------------

    mac_array mac_array_inst (

        .clk(clk),
        .rst(rst),
        .clear(clear),
        .enable(enable),

        .k(k),

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

        // Results
        .c00(c00), .c01(c01), .c02(c02), .c03(c03),
        .c10(c10), .c11(c11), .c12(c12), .c13(c13),
        .c20(c20), .c21(c21), .c22(c22), .c23(c23),
        .c30(c30), .c31(c31), .c32(c32), .c33(c33)

    );


    // ---------------------------------------------------------
    // ReLU
    // ---------------------------------------------------------

    relu r00 (.data_in(c00), .data_out(y00));
    relu r01 (.data_in(c01), .data_out(y01));
    relu r02 (.data_in(c02), .data_out(y02));
    relu r03 (.data_in(c03), .data_out(y03));

    relu r10 (.data_in(c10), .data_out(y10));
    relu r11 (.data_in(c11), .data_out(y11));
    relu r12 (.data_in(c12), .data_out(y12));
    relu r13 (.data_in(c13), .data_out(y13));

    relu r20 (.data_in(c20), .data_out(y20));
    relu r21 (.data_in(c21), .data_out(y21));
    relu r22 (.data_in(c22), .data_out(y22));
    relu r23 (.data_in(c23), .data_out(y23));

    relu r30 (.data_in(c30), .data_out(y30));
    relu r31 (.data_in(c31), .data_out(y31));
    relu r32 (.data_in(c32), .data_out(y32));
    relu r33 (.data_in(c33), .data_out(y33));

endmodule