
`include "sizes.v"

`include "defines.v"



module FpuManager (
	clk,
	clk_oe,
	
	op,
	
	a,
	b,
	out,
	
	q,
	dn,
	busy,
	
	rst
);


	input wire clk;
	input wire clk_oe;
	
	input wire [2:0] op;
	
	input wire [`DATA_SIZE0:0] a;
	input wire [`DATA_SIZE0:0] b;
	output [`DATA_SIZE0:0] out;
	
	reg [`DATA_SIZE0:0] out_r;
	wire [`DATA_SIZE0:0] out =
	                           dn == 1
										? out_r
										: 0
                              ;
	wire [`DATA_SIZE0:0] out_int;

	
	input wire q;
	output reg dn;
	
	input wire rst;

	
	reg [2:0] op_r;
	
	reg [2:0] wait_cntr;
	
	wire [`DATA_SIZE0:0] out_flags_int;
	
	output wire busy = wait_cntr != 7;
	
/*

FPU Operations (fpu_op):
========================

0 = add
1 = sub
2 = mul
3 = div
4 =
5 =
6 =
7 =

Rounding Modes (rmode):
=======================

0 = round_nearest_even
1 = round_to_zero
2 = round_up
3 = round_down

*/


`ifdef IS_USE_FPU


/**/
	fpu fpu_1( 
		.clk(clk), 
		
		.rmode(0), 
		.fpu_op(op_r), 
		.opa(a), 
		.opb(b), 
		.out(out_int), 
		
		.inf			(out_flags_int[0]), 
		.snan			(out_flags_int[1]), 
		.qnan			(out_flags_int[2]), 
		.ine			(out_flags_int[3]), 
		.overflow	(out_flags_int[4]), 
		.underflow	(out_flags_int[5]), 
		.zero			(out_flags_int[6]), 
		.div_by_zero(out_flags_int[7])
	);
/**/

/*
input		clk;
input	[1:0]	rmode;
input	[2:0]	fpu_op;
input	[31:0]	opa, opb;
output	[31:0]	out;
output		inf, snan, qnan;
output		ine;
output		overflow, underflow;
output		zero;
output		div_by_zero;
*/
	
	
	always @(posedge clk) begin
	  if(clk_oe == 0) begin
	  
	  end else begin
	    if(rst == 1) begin
		   wait_cntr = 0;
			op_r = 0;
			
			out_r = 0;
			
			dn = 0;
       end else begin
		 
         if(q == 1) begin
           op_r = op;
			  
			  wait_cntr = 7;
			end else begin
			  case(wait_cntr)
			    0, 1, 2, 3: begin
				   wait_cntr = wait_cntr + 1;
             end
				 
				 4: begin
				   out_r = out_int;
					
				   dn = 1;
					wait_cntr = 5;
				 end
				 
				 5: begin
				   out_r = 0;
					
				   dn = 0;
					wait_cntr = 7;
				 end
				 
			  endcase
			end
			
		 end
     end
	end
	
`endif

endmodule


