`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.10.2026 11:12:23
// Design Name: 
// Module Name: dma_interface_tb
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

module dma_interface_tb;

    reg clk, rst, start;
    reg [15:0] src_addr, dst_addr, transfer_len;

    wire mem_req;
    wire [15:0] mem_addr;
    reg mem_valid;
    reg [7:0] mem_rdata;

    wire local_wr_en;
    wire [15:0] local_wr_addr;
    wire [7:0] local_wr_data;
    wire busy, done;

    reg [7:0] ext_mem [0:31];
    reg [7:0] local_mem [0:31];

    integer i;
    integer errors;

    dma_interface #(
        .ADDR_WIDTH(16),
        .DATA_WIDTH(8)
    ) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .src_addr(src_addr),
        .dst_addr(dst_addr),
        .transfer_len(transfer_len),

        .mem_req(mem_req),
        .mem_addr(mem_addr),
        .mem_valid(mem_valid),
        .mem_rdata(mem_rdata),

        .local_wr_en(local_wr_en),
        .local_wr_addr(local_wr_addr),
        .local_wr_data(local_wr_data),

        .busy(busy),
        .done(done)
    );

    always #5 clk = ~clk;

    // One-cycle read response from external memory.
    // Combinational external-memory response
always @(*) begin
    mem_valid = mem_req;
    mem_rdata = ext_mem[mem_addr];
end

    // Capture DMA writes into simulated local memory.
    always @(posedge clk) begin
        if (!rst && local_wr_en)
            local_mem[local_wr_addr] <= local_wr_data;
    end

    initial begin
        clk = 0;
        rst = 1;
        start = 0;
        src_addr = 0;
        dst_addr = 8;
        transfer_len = 8;
        errors = 0;

        for (i = 0; i < 32; i = i + 1) begin
            ext_mem[i] = i + 10;
            local_mem[i] = 0;
        end

        repeat (4) @(negedge clk);
        rst = 0;

        @(negedge clk);
        start = 1;

        @(negedge clk);
        start = 0;

        wait(done == 1'b1);
        @(negedge clk);

        for (i = 0; i < 8; i = i + 1) begin
            if (local_mem[8+i] !== ext_mem[i]) begin
                $display("FAIL: address %0d", 8+i);
                errors = errors + 1;
            end
        end

        if (errors == 0)
            $display("DMA TEST PASS: 8 bytes copied correctly.");
        else
            $display("DMA TEST FAIL: %0d errors.", errors);

        $finish;
    end

    initial begin
        #10000;
        $display("DMA TEST TIMEOUT");
        $finish;
    end

endmodule
