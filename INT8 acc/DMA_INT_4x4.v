`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.10.2026 11:05:13
// Design Name: 
// Module Name: DMA_INT_4x4
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

module dma_interface #(
    parameter ADDR_WIDTH = 16,
    parameter DATA_WIDTH = 8
)(
    input wire clk,
    input wire rst,

    input wire start,
    input wire [ADDR_WIDTH-1:0] src_addr,
    input wire [ADDR_WIDTH-1:0] dst_addr,
    input wire [15:0] transfer_len,

    // External memory read interface
    output reg mem_req,
    output reg [ADDR_WIDTH-1:0] mem_addr,
    input wire mem_valid,
    input wire [DATA_WIDTH-1:0] mem_rdata,

    // Local memory write interface
    output reg local_wr_en,
    output reg [ADDR_WIDTH-1:0] local_wr_addr,
    output reg [DATA_WIDTH-1:0] local_wr_data,

    output reg busy,
    output reg done
);

    localparam IDLE  = 2'd0;
    localparam READ  = 2'd1;
    localparam WRITE = 2'd2;
    localparam FINISH = 2'd3;

    reg [1:0] state;
    reg [ADDR_WIDTH-1:0] src_ptr, dst_ptr;
    reg [15:0] count;
    reg [DATA_WIDTH-1:0] data_reg;
    reg [15:0] length_reg;

    always @(posedge clk) begin
        if (rst) begin
            state         <= IDLE;
            src_ptr       <= 0;
            dst_ptr       <= 0;
            count         <= 0;
            length_reg    <= 0;
            data_reg      <= 0;
            mem_req       <= 0;
            mem_addr      <= 0;
            local_wr_en   <= 0;
            local_wr_addr <= 0;
            local_wr_data <= 0;
            busy          <= 0;
            done          <= 0;
        end else begin
            // Default pulse signals
            mem_req     <= 0;
            local_wr_en <= 0;
            done        <= 0;

            case (state)
                IDLE: begin
                    busy <= 0;

                    if (start && transfer_len != 0) begin
                        src_ptr    <= src_addr;
                        dst_ptr    <= dst_addr;
                        count      <= 0;
                        length_reg <= transfer_len;
                        busy       <= 1;
                        state      <= READ;
                    end
                end

                READ: begin
                    mem_req  <= 1;
                    mem_addr <= src_ptr;

                    if (mem_valid) begin
                        data_reg <= mem_rdata;
                        state    <= WRITE;
                    end
                end

                WRITE: begin
                    local_wr_en   <= 1;
                    local_wr_addr <= dst_ptr;
                    local_wr_data <= data_reg;

                    if (count == length_reg - 1'b1) begin
                        state <= FINISH;
                    end else begin
                        count   <= count + 1'b1;
                        src_ptr <= src_ptr + 1'b1;
                        dst_ptr <= dst_ptr + 1'b1;
                        state   <= READ;
                    end
                end

                FINISH: begin
                    busy  <= 0;
                    done  <= 1;
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
