`timescale 1ns / 1ps

module matrix_handler_4x4 (
    input clk,
    input rst,
    input start,
    output reg done
);
    reg signed [31:0] result_2d [3:0][3:0]; // 4x4 result matrix
    reg signed [15:0] matrix_a [15:0];      // 4x4 matrix A as 1D array
    reg signed [15:0] matrix_b [15:0];      // 4x4 matrix B as 1D array
    wire submatrix_done [3:0];   
    // 2D arrays to convert 1D input matrices
    reg signed [15:0] matrix_a_2d [3:0][3:0]; 
    reg signed [15:0] matrix_b_2d [3:0][3:0];
	// reg signed [15:0] result_2d [3:0][3:0];

    integer f, cl;
    reg [1:0] k, d;
    reg [1:0] count, n;
    reg first_time;

    // Convert 1D array to 2D array only on reset
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (f = 0; f < 4; f = f + 1) begin
                for (cl = 0; cl < 4; cl = cl + 1) begin
                    matrix_a_2d[f][cl] <= matrix_a[f*4 + cl];
                    matrix_b_2d[f][cl] <= matrix_b[f*4 + cl];
                end
            end
        end 
    end

    always @(posedge clk or posedge rst) begin
    if (rst) begin
        k <= 0;
        d <= 0;
        first_time <= 1;
        count <= 0;
        n <= 0;
  end else begin
        if (k == 3) begin
            k <= 0;
            count <= count + 1;
            d <= d + 1;
            if (d == 1)
                d <= 0;
            if (count == 1) begin
                n <= 1;
            end
				else if(count ==3)begin
					n<=0;
				end
        end else begin
            k <= k + 1;
        end
    end
end

	reg [1:0]index_a,index_b;
	wire res_ack;
	reg [2:0] ack_count;
	always@(posedge clk or posedge rst)begin
		if(rst)begin
			index_a<=0;
			index_b<=0;
			ack_count<=0;
		end
		else begin
			if(res_ack)begin
				ack_count<=ack_count+1;
			end
			if(ack_count == 2)begin
				index_b<=1;
			end
			if(index_b==1)begin
				ack_count<=0;
				index_b<=0;
			end
		end
	end
 genvar r, c;
generate
    for (r = 0; r < 2; r = r + 1) begin: row_gen
        for (c = 0; c < 2; c = c + 1) begin: col_gen
            

            handler handler_inst (
                .clk(clk),
                .rst(rst),
                .start(start),
                .a_in(matrix_a_2d[2*r + n][k]),
                .b_in(matrix_b_2d[k][2*c + d]),
                .done(submatrix_done[r*2 + c]),
		 .result(),
                .res_i(),
	        .res_j(),
		 .res_ack()
            );
	end
 end
            
endgenerate
    initial begin
        $readmemh("matrix_a.txt", matrix_a);
        $readmemh("matrix_b.txt", matrix_b);
    end

endmodule
