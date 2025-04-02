`timescale 1ns / 1ps

module multiplier(
    input clk,
    input rst,
    input signed [15:0] num1,
    input signed [15:0] num2,
    input num1_stb,
    input num2_stb,
    output reg num1_ack,
    output reg num2_ack,
    output reg result_ack,
    output reg signed [31:0] result
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        // Reset all outputs and internal registers
        result <= 32'b0;  // Adjusted for 32-bit result
        result_ack <= 1'b0;
        num1_ack <= 1'b0;
        num2_ack <= 1'b0;
    end else begin
        if (num1_stb && num2_stb) begin
            // Perform multiplication when strobe signals are active
            result <= num1 * num2;
            num1_ack <= 1'b1;
            num2_ack <= 1'b1;
            result_ack <= 1'b1;
        end else begin
            // De-assert the acknowledgment signals when strobe signals are inactive
            num1_ack <= 1'b0;
            num2_ack <= 1'b0;
            result_ack <= 1'b0;
        end
    end
end

endmodule
