
`include "sizes.v"
`include "states.v"
`include "cmd_codes.v"

module Alu(
        clk,
		  clk_oe,
		  
        is_bus_busy,
        
        command,
        
        state,
        
        src1,
        src0,
        dst,
        dst_h,
        
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
  
  inout [`DATA_SIZE0:0] src1;
  inout [`DATA_SIZE0:0] src0;
  inout [`DATA_SIZE0:0] dst;
  output reg [`DATA_SIZE0:0] dst_h;

  reg [`DATA_SIZE0:0] src1_r;
  reg [`DATA_SIZE0:0] src0_r;
  reg [`DATA_SIZE0:0] dst_r;
  
  tri [`DATA_SIZE0:0] src1 = state == `ALU_RESULTS 
                                        ? src1_r 
                                        : `DATA_SIZE'h zzzzzzzz;
  tri [`DATA_SIZE0:0] src0 = state == `ALU_RESULTS 
                                        ? src0_r 
                                        : `DATA_SIZE'h zzzzzzzz;
  tri [`DATA_SIZE0:0] dst = state == `ALU_RESULTS 
                                        ? dst_r 
                                        : `DATA_SIZE'h zzzzzzzz;

  output next_state;
  reg next_state_r;
  tri next_state = next_state_r;
  
  input wire rst;
  
  
  wire [3:0] cmd_code = command[31:28];
  
  reg [1+2*`DATA_SIZE0:0] tmp64_r;
  reg [`DATA_SIZE0:0] tmp32_r;
  reg [3:0] mlt_state;
  
  
  //reg clk_oe;
        
  always @(posedge clk) begin
  
    //clk_oe = ~clk_oe;
	 if(clk_oe == 0) begin
	 
      next_state_r = 1'b 0;
//      next_state_r = 1'b z;
    
//      is_bus_busy_r = 1'b z;
		
	 end else begin

    if(rst == 1) begin
      src1_r = 0; //`DATA_SIZE'h zzzzzzzz;
      src0_r = 0; //`DATA_SIZE'h zzzzzzzz;
      dst_r =  0; //`DATA_SIZE'h zzzzzzzz;
      dst_h =  0; //`DATA_SIZE'h zzzzzzzz;
      
		mlt_state = 0;
		
		next_state_r = 1'b 0;
//		next_state_r = 1'b z;
		
//      is_bus_busy_r = 1'b z;
    end else begin
    
      case(state)
        `ALU_BEGIN: begin
          dst_h = 0;
          
          src1_r = src1;
          src0_r = src0;
          
          case(cmd_code)
            `CMD_MOV: begin
              {dst_r, src0_r} = {src0, src1};
              //src = src0;
              //src0_r = dst_h;
              
              next_state_r = 1;
            end
            
            `CMD_ADD: begin
              {dst_h, dst_r} = src0 + src1;
              
              next_state_r = 1;
            end
            
            `CMD_SUB: begin
              {dst_h, dst_r} = src0 - src1;
              
              next_state_r = 1;
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
              {dst_h, dst_r} = src0 * src1;
              
              next_state_r = 1;       
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
              dst_r = src0 / src1;
              dst_h = src0 % src1;
              
              next_state_r = 1;
            end
            
            `CMD_SHR: begin
              dst_r = src0 >> src1;
              
              next_state_r = 1;
            end
            
            `CMD_SHL: begin
              dst_r = src0 << src1;
              
              next_state_r = 1;
            end
            
            `CMD_XOR: begin
              dst_r = src0 ^ src1;
              
              next_state_r = 1;
            end
            
            `CMD_AND: begin
              dst_r = src0 & src1;
              
              next_state_r = 1;
            end
            
            `CMD_OR: begin
              dst_r = src0 | src1;
              
              next_state_r = 1;
            end
            
            default: begin
//              next_state_r = 1;       
            end
            
//            `: begin
//            end
            
//            `: begin
//            end
          
          endcase
          
//          next_state_r = 1;
        end
        
      endcase
    
    
    
    end
	 
	 end
  
  end
        
        
        
        
        
endmodule