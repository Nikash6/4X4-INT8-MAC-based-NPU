`timescale 1ns / 1ps

module npu_dma_system #(
    parameter QUANT_SHIFT = 0
)(
    input wire clk,
    input wire rst,
    input wire start,

    // External memory read interface
    output wire mem_req,
    output wire [15:0] mem_addr,
    input wire mem_valid,
    input wire [7:0] mem_rdata,

    // NPU output read interface
    input wire [5:0] out_rd_addr,
    output wire signed [7:0] out_rd_data,

    output wire dma_done,
    output wire npu_done,
    output wire busy,
    output wire done
);

    reg dma_start;
    reg npu_start;

    wire dma_busy;

    wire local_wr_en;
    wire [15:0] local_wr_addr;
    wire [7:0] local_wr_data;

    localparam IDLE     = 2'd0;
    localparam DMA_WAIT = 2'd1;
    localparam NPU_WAIT = 2'd2;
    localparam FINISH   = 2'd3;

    reg [1:0] state;

    // DMA copies 128 bytes:
    // external address 0-63   -> matrix A
    // external address 64-127 -> matrix B
    dma_interface #(
        .ADDR_WIDTH(16),
        .DATA_WIDTH(8)
    ) dma_inst (
        .clk(clk),
        .rst(rst),

        .start(dma_start),
        .src_addr(16'd0),
        .dst_addr(16'd0),
        .transfer_len(16'd128),

        .mem_req(mem_req),
        .mem_addr(mem_addr),
        .mem_valid(mem_valid),
        .mem_rdata(mem_rdata),

        .local_wr_en(local_wr_en),
        .local_wr_addr(local_wr_addr),
        .local_wr_data(local_wr_data),

        .busy(dma_busy),
        .done(dma_done)
    );

    // DMA destination address 0-127 maps to NPU load address.
    npu_8x8_top #(
        .QUANT_SHIFT(QUANT_SHIFT)
    ) npu_inst (
        .clk(clk),
        .rst(rst),

        .load_en(local_wr_en),
        .load_addr(local_wr_addr[6:0]),
        .load_data(local_wr_data),

        .start(npu_start),

        .out_rd_addr(out_rd_addr),
        .out_rd_data(out_rd_data),

        .done(npu_done)
    );

    always @(posedge clk) begin
        if (rst) begin
            state     <= IDLE;
            dma_start <= 1'b0;
            npu_start <= 1'b0;
        end else begin
            dma_start <= 1'b0;
            npu_start <= 1'b0;

            case (state)
                IDLE: begin
                    if (start) begin
                        dma_start <= 1'b1;
                        state <= DMA_WAIT;
                    end
                end

                DMA_WAIT: begin
                    if (dma_done) begin
                        npu_start <= 1'b1;
                        state <= NPU_WAIT;
                    end
                end

                NPU_WAIT: begin
                    if (npu_done)
                        state <= FINISH;
                end

                FINISH: begin
                    if (!start)
                        state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

    assign busy = (state == DMA_WAIT) || (state == NPU_WAIT);
    assign done = (state == FINISH);

endmodule