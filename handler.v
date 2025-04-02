`timescale 1ns / 1ps

module handler #(parameter r_a=2,r_b=4,c_a=4,c_b=2)( 
    input start,
    input clk,
    input rst,
    input signed [15:0] a_in,
    input signed [15:0] b_in,
	 output reg done,
	 output [31:0]result,
	 output [31:0]res_i,
	 output [31:0]res_j,
	 output res_ack
);
	
    reg signed [15:0] temp_a[((r_a*c_a)*2)-1:0];
    reg signed [15:0] temp_b[((r_b*c_b)*2)-1:0];
    reg [31:0] i;
    reg [31:0] j;
    
    wire mul_res_ack;
    wire [31:0] a_i;
    wire [31:0] a_j;
    wire [31:0] b_i;
    wire [31:0] b_j;
    wire [31:0] res_i;
    wire [31:0] res_j;
    reg [15:0] a_val;
    reg [15:0] b_val;
    reg ready;
    reg first_cycle;
	 reg [31:0]count_done;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            i <= 0;
            j <= 0;
            a_val <= 0;
            b_val <= 0;
            ready <= 0;
            first_cycle <= 1; // Flag to detect the first cycle after reset
        end else begin
            if (i < ((r_a*c_a)*2)) begin
                temp_a[i] <= a_in;
                temp_b[i] <= b_in;
                i <= i + 1;
                ready <= 1; // Set ready once valid data is loaded
            end
				if (first_cycle) begin
                        a_val <= a_in; // Load the first input value
                        b_val <= b_in;
                        first_cycle <= 0; // Clear the first cycle flag
								j<=j+1;
                    end 

            if (ready) begin
                if (acknow) begin
                   
                        a_val <= temp_a[j];
                        b_val <= temp_b[j];
                        j <= j + 1;
                    
                end

            end
        end
    end
	 always@(posedge clk or posedge rst)begin
		if(rst)begin
			count_done<=0;
			done<=0;
		end
		else begin
			if(res_ack)begin
				count_done<=count_done+1;
			end
			if(count_done==5)begin
				done<=1;
			end
		end		
	 end
	 

    matrix_mul MULL (
        .clk(clk), 
        .rst(rst), 
        .start(start && ready), // Ensure matrix_mul starts only when ready
        .a_in(a_val), 
        .b_in(b_val), 
        .done(done),
        .res_ack(res_ack),
		  .result(result),
        .a_i(a_i), 
        .a_j(a_j), 
        .b_i(b_i), 
        .b_j(b_j), 
        .res_i(res_i), 
        .res_j(res_j),
        .acknow(acknow)
    );
    
endmodule

