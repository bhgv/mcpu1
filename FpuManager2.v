
`include "defines.v"

`include "sizes.v"




module FpuManager2 (
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
	
//	reg [2:0] wait_cntr;
	
	wire [`DATA_SIZE0:0] out_flags_int;
	
	reg busy_r;
	
	output busy;
	wire busy = busy_r;
	
	
	reg [1:0] state;


	
`ifdef IS_USE_FPU

	
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

*/


reg 
   stb_a_add, stb_b_add, 
	stb_a_mlt, stb_b_mlt, 
	stb_a_div, stb_b_div 
;

reg 
   ack_z_add,
   ack_z_mlt,
   ack_z_div
;

wire
   ack_a_add, ack_b_add,
   ack_a_mlt, ack_b_mlt,
   ack_a_div, ack_b_div
;

wire 
   stb_z_add,
   stb_z_mlt,
   stb_z_div
;

wire [`DATA_SIZE0:0] 
                  out_int_add,
                  out_int_mlt,
                  out_int_div
;

/*
assign out_int = 
                 stb_z_add == 1
					? out_int_add
					: stb_z_mlt == 1
					? out_int_mlt
					: stb_z_div == 1
					? out_int_div
					: 0
;
*/


adder add_1(
        .input_a(a),
        .input_b(op_r == 1 ? -b : b),
        .input_a_stb(stb_a_add),
        .input_b_stb(stb_b_add),
        .output_z_ack(ack_z_add),
        .clk(clk),
        .rst(rst),
        .output_z(out_int_add),
        .output_z_stb(stb_z_add),
        .input_a_ack(ack_a_add),
        .input_b_ack(ack_b_add)
		  );

multiplier mlt_1(
        .input_a(a),
        .input_b(b),
        .input_a_stb(stb_a_mlt),
        .input_b_stb(stb_b_mlt),
        .output_z_ack(ack_z_mlt),
        .clk(clk),
        .rst(rst),
        .output_z(out_int_mlt),
        .output_z_stb(stb_z_mlt),
        .input_a_ack(ack_a_mlt),
        .input_b_ack(ack_b_mlt)
		  );
	
divider div_1(
        .input_a(a),
        .input_b(b),
        .input_a_stb(stb_a_div),
        .input_b_stb(stb_b_div),
        .output_z_ack(ack_z_div),
        .clk(clk),
        .rst(rst),
        .output_z(out_int_div),
        .output_z_stb(stb_z_div),
        .input_a_ack(ack_a_div),
        .input_b_ack(ack_b_div)
		  );
	
`endif	

	
	
	
	always @(posedge clk) begin
	  if(clk_oe == 0) begin
	  
	  end else begin
	    if(rst == 1) begin
//		   wait_cntr = 0;
			op_r = 0;
			
			out_r = 0;
			
			dn = 0;
			
			busy_r = 0;

`ifdef IS_USE_FPU
			stb_a_add = 0;
			stb_b_add = 0;
			ack_z_add = 0;
			
			stb_a_mlt = 0;
			stb_b_mlt = 0;
			ack_z_mlt = 0;
			
			stb_a_div = 0;
			stb_b_div = 0;
			ack_z_div = 0;
`endif

			state = 0;
       end else begin

`ifdef IS_USE_FPU
         if(q == 1 && busy_r == 0) begin
           op_r = op;
			  
			  busy_r = 1;
			  
			  state = 0;
			end else if(busy_r == 1) begin
			  case(op_r)
			    // ADD/SUB
			    0, 1: begin // add/sub
				   case(state)
					  0: begin //set a
					    if(ack_a_add == 1) begin
						   stb_a_add = 1;
						 end else begin
						   stb_a_add = 0;
							
							state = 1;
						 end
					  end
					  
					  1: begin //set b
					    if(ack_b_add == 1) begin
						   stb_b_add = 1;
						 end else begin
						   stb_b_add = 0;
							
							state = 2;
						 end
					  end
					  
					  2: begin //get out
					    if(stb_z_add == 1) begin
						   out_r = out_int_add;
						   ack_z_add = 1;
							dn = 1;
						 end else begin
						   ack_z_add = 0;
							out_r = 0;
							dn = 0;
							busy_r = 0;
							
							state = 0;
						 end
					  end
					  
					endcase
				 end

/**
			    // SUB
			    1: begin // sub
				   case(state)
					  0: begin //set a
					    if(ack_a_add == 1) begin
						   stb_a_add = 1;
						 end else begin
						   stb_a_add = 0;
							
							state = 1;
						 end
					  end
					  
					  1: begin //set b
					    if(ack_b_add == 1) begin
						   stb_b_add = 1;
						 end else begin
						   stb_b_add = 0;
							
							state = 2;
						 end
					  end
					  
					  2: begin //get out
					    if(stb_z_add == 1) begin
						   out_r = out_int_add;
						   ack_z_add = 1;
							dn = 1;
						 end else begin
						   ack_z_add = 0;
							out_r = 0;
							dn = 0;
							busy_r = 0;
							
							state = 0;
						 end
					  end
					  
					endcase
				 end
/**/

			    // MLT
			    2: begin // mlt
				   case(state)
					  0: begin //set a
					    if(ack_a_mlt == 1) begin
						   stb_a_mlt = 1;
						 end else begin
						   stb_a_mlt = 0;
							
							state = 1;
						 end
					  end
					  
					  1: begin //set b
					    if(ack_b_mlt == 1) begin
						   stb_b_mlt = 1;
						 end else begin
						   stb_b_mlt = 0;
							
							state = 2;
						 end
					  end
					  
					  2: begin //get out
					    if(stb_z_mlt == 1) begin
						   out_r = out_int_mlt;
						   ack_z_mlt = 1;
							dn = 1;
						 end else begin
						   ack_z_mlt = 0;
							out_r = 0;
							dn = 0;
							busy_r = 0;
							
							state = 0;
						 end
					  end
					  
					endcase
				 end
			
			    // DIV
			    3: begin // div
				   case(state)
					  0: begin //set a
					    if(ack_a_div == 1) begin
						   stb_a_div = 1;
						 end else begin
						   stb_a_div = 0;
							
							state = 1;
						 end
					  end
					  
					  1: begin //set b
					    if(ack_b_div == 1) begin
						   stb_b_div = 1;
						 end else begin
						   stb_b_div = 0;
							
							state = 2;
						 end
					  end
					  
					  2: begin //get out
					    if(stb_z_div == 1) begin
						   out_r = out_int_div;
						   ack_z_div = 1;
							dn = 1;
						 end else begin
						   ack_z_div = 0;
							out_r = 0;
							dn = 0;
							busy_r = 0;
							
							state = 0;
						 end
					  end
					  
					endcase
				 end
			
			  endcase

			end
`endif
			
		 end
     end
	end
	

endmodule


