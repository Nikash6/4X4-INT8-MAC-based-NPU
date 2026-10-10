`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.10.2026 11:06:14
// Design Name: 
// Module Name: Quantization_4x4
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

module quantization (
    input wire signed [31:0] data_in,
    input wire [4:0] shift,
    output reg signed [7:0] data_out
);

    reg signed [31:0] scaled;

    always @(*) begin
        scaled = data_in >>> shift;

        if (scaled > 32'sd127)
            data_out = 8'sd127;
        else if (scaled < -32'sd128)
            data_out = -8'sd128;
        else
            data_out = scaled[7:0];
    end

endmodule
