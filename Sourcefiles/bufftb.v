`timescale 1ns / 1ps

module npu_buffer_tb;

    reg clk;
    reg rst;

    // Input buffer write interface
    reg        load_en;
    reg [4:0]  load_addr;
    reg signed [7:0] load_data;

    // Start
    reg start;

    // Output buffer read interface
    reg [3:0] out_rd_addr;
    wire signed [31:0] out_rd_data;

    wire done;

    // ============================================================
    // DUT
    // ============================================================

    npu_buffered_top dut (

        .clk(clk),
        .rst(rst),

        .load_en(load_en),
        .load_addr(load_addr),
        .load_data(load_data),

        .start(start),

        .out_rd_addr(out_rd_addr),
        .out_rd_data(out_rd_data),

        .done(done)
    );

    // ============================================================
    // CLOCK
    // ============================================================

    always #5 clk = ~clk;

    // ============================================================
    // TASK TO LOAD ONE VALUE
    // ============================================================

    task load_value;

        input [4:0] addr;
        input signed [7:0] data;

        begin

            @(negedge clk);

            load_en   = 1'b1;
            load_addr = addr;
            load_data = data;

            @(negedge clk);

            load_en = 1'b0;

        end

    endtask

    // ============================================================
    // TEST
    // ============================================================

    initial begin

        clk = 0;
        rst = 1;

        load_en   = 0;
        load_addr = 0;
        load_data = 0;

        start = 0;

        out_rd_addr = 0;

        // --------------------------------------------------------
        // RESET
        // --------------------------------------------------------

        #20;
        rst = 0;

        // ========================================================
        // LOAD MATRIX A
        // ========================================================

        // A =
        // [1 2 3 4
        //  5 6 7 8
        //  1 2 1 2
        //  3 4 3 4]

        load_value(5'd0,  8'sd1);
        load_value(5'd1,  8'sd2);
        load_value(5'd2,  8'sd3);
        load_value(5'd3,  8'sd4);

        load_value(5'd4,  8'sd5);
        load_value(5'd5,  8'sd6);
        load_value(5'd6,  8'sd7);
        load_value(5'd7,  8'sd8);

        load_value(5'd8,  8'sd1);
        load_value(5'd9,  8'sd2);
        load_value(5'd10, 8'sd1);
        load_value(5'd11, 8'sd2);

        load_value(5'd12, 8'sd3);
        load_value(5'd13, 8'sd4);
        load_value(5'd14, 8'sd3);
        load_value(5'd15, 8'sd4);

        // ========================================================
        // LOAD MATRIX B
        // ========================================================

        // B =
        // [1 0 1 0
        //  0 1 0 1
        //  1 1 1 1
        //  2 2 2 2]

        load_value(5'd16, 8'sd1);
        load_value(5'd17, 8'sd0);
        load_value(5'd18, 8'sd1);
        load_value(5'd19, 8'sd0);

        load_value(5'd20, 8'sd0);
        load_value(5'd21, 8'sd1);
        load_value(5'd22, 8'sd0);
        load_value(5'd23, 8'sd1);

        load_value(5'd24, 8'sd1);
        load_value(5'd25, 8'sd1);
        load_value(5'd26, 8'sd1);
        load_value(5'd27, 8'sd1);

        load_value(5'd28, 8'sd2);
        load_value(5'd29, 8'sd2);
        load_value(5'd30, 8'sd2);
        load_value(5'd31, 8'sd2);

        // ========================================================
        // START NPU
        // ========================================================

        @(negedge clk);
        start = 1'b1;

        @(negedge clk);
        start = 1'b0;

        // ========================================================
        // WAIT FOR DONE
        // ========================================================

        wait(done == 1'b1);

        $display("----------------------------------------");
        $display("NPU COMPUTATION COMPLETE");
        $display("----------------------------------------");

        // ========================================================
        // READ OUTPUT BUFFER
        // ========================================================

        #10;

        out_rd_addr = 4'd0;
        #2;
        $display("Y00 = %0d", out_rd_data);

        out_rd_addr = 4'd1;
        #2;
        $display("Y01 = %0d", out_rd_data);

        out_rd_addr = 4'd2;
        #2;
        $display("Y02 = %0d", out_rd_data);

        out_rd_addr = 4'd3;
        #2;
        $display("Y03 = %0d", out_rd_data);


        out_rd_addr = 4'd4;
        #2;
        $display("Y10 = %0d", out_rd_data);

        out_rd_addr = 4'd5;
        #2;
        $display("Y11 = %0d", out_rd_data);

        out_rd_addr = 4'd6;
        #2;
        $display("Y12 = %0d", out_rd_data);

        out_rd_addr = 4'd7;
        #2;
        $display("Y13 = %0d", out_rd_data);


        out_rd_addr = 4'd8;
        #2;
        $display("Y20 = %0d", out_rd_data);

        out_rd_addr = 4'd9;
        #2;
        $display("Y21 = %0d", out_rd_data);

        out_rd_addr = 4'd10;
        #2;
        $display("Y22 = %0d", out_rd_data);

        out_rd_addr = 4'd11;
        #2;
        $display("Y23 = %0d", out_rd_data);


        out_rd_addr = 4'd12;
        #2;
        $display("Y30 = %0d", out_rd_data);

        out_rd_addr = 4'd13;
        #2;
        $display("Y31 = %0d", out_rd_data);

        out_rd_addr = 4'd14;
        #2;
        $display("Y32 = %0d", out_rd_data);

        out_rd_addr = 4'd15;
        #2;
        $display("Y33 = %0d", out_rd_data);

        $display("----------------------------------------");

        #20;

        $finish;

    end

endmodule