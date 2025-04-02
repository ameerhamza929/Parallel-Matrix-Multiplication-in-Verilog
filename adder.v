`timescale 1ns / 1ps

module adder(
    input wire clk,
    input wire rst,
    input wire num1_stb,
    input wire num2_stb,
    input signed [31:0] num1,
    input signed [31:0] num2,
    output reg signed [31:0] result,
    output reg result_ack,
    output reg num1_ack,
    output reg num2_ack
);
    reg signed [31:0] temp_result;
    reg [1:0] state;

    // Sequential logic block for addition, saturation, and acknowledgment
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset all outputs and internal registers
            result <= 32'b0;            // Adjusted for 16-bit result
            temp_result <= 32'b0;
            result_ack <= 1'b0;
            num1_ack <= 1'b0;
            num2_ack <= 1'b0;
            state <= 2'b01;             // Initial state
        end else begin
            case(state)
                2'b01: begin
                    if (num1_stb && num2_stb) begin
                        temp_result <= num1 + num2;
                        num1_ack <= 1'b1;
                        num2_ack <= 1'b1;
                        state <= 2'b11;  // Move to next state
                    end else begin
                        // If strobe signals are not asserted, clear the acknowledgment signals
                        num1_ack <= 1'b0;
                        num2_ack <= 1'b0;
                        result_ack <= 1'b0;
                        state <= 2'b01;
                    end
                end
                
                2'b11: begin
                    // Saturation logic
                    if (num1[31] == num2[31]) begin
                        if (temp_result[31] != num1[31]) begin
                            if (num1[31] == 0)
                                result <= 31'b0111_1111_1111_1111_1111_1111_1111_1111; // Max positive value
                            else
                                result <= 16'b1000_0000_0000_0000_0000_0000_0000_0000; // Min negative value
                        end else begin
                            result <= temp_result[31:0]; // No overflow, normal result
                        end
                    end else begin
                        result <= temp_result[31:0]; // No overflow, normal result
                    end
                    result_ack <= 1'b1;
                    state <= 2'b01;  // Reset state machine
                end
                
                default: state <= 2'b01; // Default state
            endcase
        end
    end
endmodule
