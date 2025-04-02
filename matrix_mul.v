
`timescale 1ns / 1ps

module matrix_mul #(parameter r_a=2,r_b=4,c_a=4,c_b=2)
(
    input clk,
    input rst,
    input start,
    input signed [15:0] a_in,
    input signed [15:0] b_in,
    output reg done,
    output reg res_ack,
    output reg [31:0] result,
    output [31:0] a_i, a_j, b_i, b_j, res_i, res_j,
    output acknow
);
    reg signed [31:0] sum;
    reg [31:0] k, i, j;
    reg [31:0] prev_i, prev_j;  // Registers to hold previous values of i and j
    reg signed [15:0] a_val, b_val;
    reg [2:0] state;
    reg first_input_load;

    assign a_i = i;
    assign a_j = k;
    assign b_i = k;
    assign b_j = j;
    assign res_i = prev_i;  // Output previous i value
    assign res_j = prev_j;  // Output previous j value

    reg mul_num1_stb, mul_num2_stb, add_num1_stb, add_num2_stb;
    wire mul_num1_ack, mul_num2_ack, add_num1_ack, add_num2_ack;
    wire signed [31:0] mul_result, add_result;
    assign acknow = add_result_ack;

    multiplier mul (
        .clk(clk),
        .rst(rst),
        .num1(a_val),
        .num2(b_val),
        .num1_stb(mul_num1_stb),
        .num2_stb(mul_num2_stb),
        .num1_ack(mul_num1_ack),
        .num2_ack(mul_num2_ack),
        .result_ack(mul_result_ack),
        .result(mul_result)
    );

    adder add (
        .clk(clk),
        .rst(rst),
        .num1_stb(add_num1_stb),
        .num2_stb(add_num2_stb),
        .num1(sum),
        .num2(mul_result),
        .result(add_result),
        .result_ack(add_result_ack),
        .num1_ack(add_num1_ack),
        .num2_ack(add_num2_ack)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            i <= 0;
            j <= 0;
            k <= 0;
            sum <= 0;
            done <= 0;
            state <= 3'b001;
            first_input_load <= 1;
            prev_i <= 0;  // Initialize prev_i
            prev_j <= 0;  // Initialize prev_j
        end else begin
            // Update prev_i and prev_j with the current i and j values
            prev_i <= i;
            prev_j <= j;

            case(state)
                3'b001: begin
                    if (start) begin
                        if (first_input_load) begin
                            first_input_load <= 0;
                            state <= 3'b001;
                                
                        end else begin
                            if (k < c_a) begin
                                a_val <= a_in;
                                b_val <= b_in;
                                k <= k + 1;
                                mul_num1_stb <= 1;
                                mul_num2_stb <= 1;
                                state <= 3'b010;
                                res_ack <= 0;
                            end else begin
                                result <= sum;
                                res_ack <= 1;
                                sum <= 0;
                                k <= 0;
                                if (j < c_b-1) begin
                                    j <= j + 1;
                                end else if (i < r_a-1) begin
                                    j <= 0;
                                    i <= i + 1;
                                end else begin
                                    done <= 1;
                                    state <= 3'b111;
                                end
                                state <= 3'b001;
                            end
                        end
                    end
                end

                3'b010: begin
                    if (mul_num1_ack && mul_num2_ack) begin
                        mul_num1_stb <= 0;
                        mul_num2_stb <= 0;
                        state <= 3'b011;
                    end
                end

                3'b011: begin
                    if (mul_result_ack) begin
                        add_num1_stb <= 1;
                        add_num2_stb <= 1;
                        state <= 3'b100;
                    end
                end

                3'b100: begin
                    if (add_num1_ack && add_num2_ack) begin
                        add_num1_stb <= 0;
                        add_num2_stb <= 0;
                    end
                    if (add_result_ack) begin
                        sum <= add_result;
                        state <= 3'b001;
                    end
                end

                3'b111: begin
                    done <= 0;
                    state <= 3'b001;
                end

                default: state <= 3'b001;
            endcase
        end
    end
endmodule
