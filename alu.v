
`include "sizes.v"
`include "states.v"
`include "cmd_codes.v"

module Alu(
        clk,
		  clk_oe,
		  
        is_bus_busy,
        
        command,
        
        state,
        
        src1_in,
        src0_in,
//        dst_in,
		  
        src1_out,
        src0_out,
        dst_out,
        dst_h_out,
        
        next_state,
        
        rst
        );
        
  input wire clk;
  input wire clk_oe;
  
  input is_bus_busy;
//  reg is_bus_busy_r;
  wire is_bus_busy; // = is_bus_busy_r;
  
  input wire [31:0] command;
  
  input wire [`STATE_SIZE0:0] state;
  
  input [`DATA_SIZE0:0] src1_in;
  input [`DATA_SIZE0:0] src0_in;

  output [`DATA_SIZE0:0] src1_out;
  output [`DATA_SIZE0:0] src0_out;
  output [`DATA_SIZE0:0] dst_out;

  reg [`DATA_SIZE0:0] dst_h;
  output [`DATA_SIZE0:0] dst_h_out;
  wire [`DATA_SIZE0:0] dst_h_out = dst_h;

  reg [`DATA_SIZE0:0] src1_r;
  reg [`DATA_SIZE0:0] src0_r;
  reg [`DATA_SIZE0:0] dst_r;
  
  wire [`DATA_SIZE0:0] src1_out = state == `ALU_RESULTS 
                                        ? src1_r 
                                        : 0; //`DATA_SIZE'h zzzzzzzz;
  wire [`DATA_SIZE0:0] src0_out = state == `ALU_RESULTS 
                                        ? src0_r 
                                        : 0; //`DATA_SIZE'h zzzzzzzz;
  wire [`DATA_SIZE0:0] dst_out = state == `ALU_RESULTS 
                                        ? dst_r 
                                        : 0; //`DATA_SIZE'h zzzzzzzz;

  output next_state;
  reg next_state_r;
  wire next_state = next_state_r;
  
  input wire rst;
  
  
  wire [3:0] cmd_code = command[31:28];
  
  reg [1+2*`DATA_SIZE0:0] tmp64_r;
  reg [`DATA_SIZE0:0] tmp32_r;
  reg [3:0] mlt_state;
  
  
  
  reg [2:0] fpu_op;
  wire [`DATA_SIZE0:0] fpu_out_int;
  reg fpu_q;
  wire fpu_dn;
  wire fpu_busy;
  
  
  FpuManager2 fpu_1(
	.clk(clk),
	.clk_oe(clk_oe),
	
	.op(fpu_op),
	
	.a(src0_in),
	.b(src1_in),
	.out(fpu_out_int),
	
	.q(fpu_q),
	.dn(fpu_dn),
	.busy(fpu_busy),
	
	.rst(rst)
  );

  
  
  //reg clk_oe;
        
  always @(posedge clk) begin
  
    //clk_oe = ~clk_oe;
	 if(clk_oe == 0) begin
	 
      next_state_r <= 1'b 0;
//      next_state_r = 1'b z;
    
//      is_bus_busy_r = 1'b z;
		
	 end else begin

    if(rst == 1) begin
      src1_r <= 0; //`DATA_SIZE'h zzzzzzzz;
      src0_r <= 0; //`DATA_SIZE'h zzzzzzzz;
      dst_r <=  0; //`DATA_SIZE'h zzzzzzzz;
      dst_h <=  0; //`DATA_SIZE'h zzzzzzzz;
      
		mlt_state <= 0;
		
		next_state_r <= 1'b 0;
		
//      is_bus_busy_r = 1'b z;
    end else begin
    
      case(state)
        default: begin
          dst_h <= 0;
          dst_r <= 0;
        end

        `ALU_BEGIN: begin
          
          case(cmd_code)
/**
            `CMD_CHN: begin
              {dst_r, src0_r} <= {src0_in, src1_in};
              //src = src0;
              //src0_r = dst_h;
              
              next_state_r <= 1;
            end
/**/

            `CMD_ADD: begin
              {dst_h, dst_r} <= src0_in + src1_in;
              
              next_state_r <= 1;
            end
            
            `CMD_SUB: begin
              {dst_h, dst_r} <= src0_in - src1_in;
              
              next_state_r <= 1;
            end
            
            `CMD_MUL: begin
/*
				  if(mlt_state == 0) begin
				    {dst_h, dst_r} = 0;
				    tmp64_r = src0; //{`DATA_SIZE{1'b 0}, src0};
					 tmp32_r = src1;
					 
				    mlt_state = 1;
				  end else begin
			       if(tmp32_r == 0) begin
				      next_state_r = 1;
						mlt_state = 0;
					 end else begin
					   if(tmp32_r[0] == 1'b 1) begin
						  {dst_h, dst_r} = {dst_h, dst_r} + tmp64_r;
						end
						
						tmp64_r = tmp64_r << 1;
						tmp32_r = tmp32_r >> 1;
			       end
				  end
*/
              {dst_h, dst_r} <= src0_in * src1_in;
              
              next_state_r <= 1;
            end
            
            `CMD_DIV: begin
/*
				  if(mlt_state == 0) begin
				    {dst_h, dst_r} = 0;
				    tmp64_r = src0; //{`DATA_SIZE'{0}, src0};
					 tmp32_r = src1;
					 
				    mlt_state = 1;
				  end else begin
			       if(tmp32_r == 0) begin
				      next_state_r = 1;
						mlt_state = 0;
					 end else begin
					   if(tmp32_r[0] == 1'b 1) begin
						  {dst_h, dst_r} = {dst_h, dst_r} + tmp64_r;
						end
						
						tmp64_r = tmp64_r << 1;
						tmp32_r = tmp32_r >> 1;
			       end
				  end
*/
              dst_r <= src0_in / src1_in;
              dst_h <= src0_in % src1_in;
              
              next_state_r <= 1;
            end
            
				// Shifts
            `CMD_SHR: begin
              dst_r <= src0_in >> src1_in;
              
              next_state_r <= 1;
            end
            
            `CMD_SHL: begin
              dst_r <= src0_in << src1_in;
              
              next_state_r <= 1;
            end
            
				// Boolean
            `CMD_XOR: begin
              dst_r <= src0_in ^ src1_in;
              
              next_state_r <= 1;
            end
            
            `CMD_AND: begin
              dst_r <= src0_in & src1_in;
              
              next_state_r <= 1;
            end
            
            `CMD_OR: begin
              dst_r <= src0_in | src1_in;
              
              next_state_r <= 1;
            end
            
				// FPU
/**/
            `CMD_FADD: begin
              if(fpu_busy == 0) begin
				    fpu_op <= 0;
					 fpu_q <= 1;
				  end else begin 
				    fpu_q <= 0;
				    if(fpu_dn == 1) begin
					   dst_r <= fpu_out_int;
						
                  next_state_r <= 1;
					 end
				  end
            end
            
            `CMD_FSUB: begin
              if(fpu_busy == 0) begin
				    fpu_op <= 1;
					 fpu_q <= 1;
				  end else begin 
				    fpu_q <= 0;
				    if(fpu_dn == 1) begin
					   dst_r <= fpu_out_int;
						
                  next_state_r <= 1;
					 end
				  end
            end
            
            `CMD_FMUL: begin
              if(fpu_busy == 0) begin
				    fpu_op <= 2;
					 fpu_q <= 1;
				  end else begin 
				    fpu_q <= 0;
				    if(fpu_dn == 1) begin
					   dst_r <= fpu_out_int;
						
                  next_state_r <= 1;
					 end
				  end
            end
            
            `CMD_FDIV: begin
              if(fpu_busy == 0) begin
				    fpu_op <= 3;
					 fpu_q <= 1;
				  end else begin 
				    fpu_q <= 0;
				    if(fpu_dn == 1) begin
					   dst_r <= fpu_out_int;
						
                  next_state_r <= 1;
					 end
				  end
            end
/**/

            default: begin
				  dst_h <= 0;
				  dst_r <= 0;
//              next_state_r = 1;       
            end
            
//            `: begin
//            end
            
//            `: begin
//            end
          
          endcase
          
        end
        
      endcase
    
    
    
    end
	 
	 end
  
  end
        
        
        
        
        
endmodule