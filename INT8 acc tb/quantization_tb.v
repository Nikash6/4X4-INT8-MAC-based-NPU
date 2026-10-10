`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.10.2026 11:36:19
// Design Name: 
// Module Name: quantization_tb
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

module quantization_tb;

    reg signed [31:0] data_in;
    reg [4:0] shift;
    wire signed [7:0] data_out;

    integer errors;

    quantization dut (
        .data_in(data_in),
        .shift(shift),
        .data_out(data_out)
    );

    task check_result;
        input signed [31:0] test_input;
        input [4:0] test_shift;
        input signed [7:0] expected;
        begin
            data_in = test_input;
            shift = test_shift;
            #10;

            if (data_out !== expected) begin
                $display(
                    "FAIL: input=%0d shift=%0d expected=%0d got=%0d",
                    test_input, test_shift, expected, data_out
                );
                errors = errors + 1;
            end else begin
                $display(
                    "PASS: input=%0d shift=%0d output=%0d",
                    test_input, test_shift, data_out
                );
            end
        end
    endtask

    initial begin
        errors = 0;
        data_in = 0;
        shift = 0;

        $display("------------------------------------");
        $display("QUANTIZATION AND SATURATION TEST");
        $display("------------------------------------");

        // No shift: normal signed values
        check_result(32'sd25,    0,  8'sd25);
        check_result(-32'sd25,   0, -8'sd25);
        check_result(32'sd127,   0,  8'sd127);
        check_result(-32'sd128,  0, -8'sd128);

        // Saturation limits
        check_result(32'sd128,    0,  8'sd127);
        check_result(32'sd500,    0,  8'sd127);
        check_result(-32'sd129,   0, -8'sd128);
        check_result(-32'sd500,   0, -8'sd128);

        // Arithmetic right shift by 2
        check_result(32'sd100,    2,  8'sd25);
        check_result(32'sd508,    2,  8'sd127);
        check_result(32'sd600,    2,  8'sd127);
        check_result(-32'sd100,   2, -8'sd25);
        check_result(-32'sd512,   2, -8'sd128);
        check_result(-32'sd600,   2, -8'sd128);

        // Arithmetic right shift rounds negative values downward
        check_result(-32'sd7,     2, -8'sd2);
        check_result(32'sd7,      2,  8'sd1);

        $display("------------------------------------");

        if (errors == 0)
            $display("PASS: All quantization tests passed.");
        else
            $display("FAIL: %0d quantization errors.", errors);

        $display("------------------------------------");
        $finish;
    end

endmodule
