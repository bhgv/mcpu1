
`include "sizes.v"
`include "states.v"
`include "inter_cpu_msgs.v"
`include "misc_codes.v"


module CpuIndexManager (
  clk,
  clk_oe,
  
  cpu_index_in,
  cpu_index_out,
  
  bus_busy_in,
  ext_next_cpu_q,
  ext_cpu_msg_in,
  ext_cpu_index,
  state,
  
  cpu_index_set,
  
  rst
);

  input wire clk;
  input wire clk_oe;
  input wire rst;
  
  input wire cpu_index_set;

  input wire bus_busy_in;
  
  input wire ext_next_cpu_q;
  input wire [`CPU_MSG_SIZE0:0] ext_cpu_msg_in;

  input wire [`DATA_SIZE0:0] ext_cpu_index;
  
  input wire [`STATE_SIZE0:0] state;

  input wire [`DATA_SIZE0:0] cpu_index_in;
  output [`DATA_SIZE0:0] cpu_index_out;
  reg [`DATA_SIZE0:0] cpu_index_r;
  wire [`DATA_SIZE0:0] cpu_index_out = cpu_index_r;



  always @(posedge clk) begin
	 if(clk_oe == 0) begin
	 
	 
	 
	 
		  /**
          if(ext_cpu_index != cpu_index_r) begin
			   case(state)
              `START_BEGIN: begin
                cpu_index_r = cpu_index_r | `CPU_ACTIVE;
              end
            
              `FINISH_END: begin
                cpu_index_r = `CPU_NONACTIVE;
              end
            
				endcase
			 end
        /**/

	 
	 
	 
/**/
//    if(ext_next_cpu_e === 1) begin 
      if(
		   ext_cpu_index == cpu_index_r
//			cpu_ind_rel == 2'b11
      ) begin
		
        if(
            cpu_index_r == 0 
            && state == `START_BEGIN 
        ) begin
          cpu_index_r = `CPU_ACTIVE;
        end
        
      end 
      else // if(ext_next_cpu_e_r === 1)

//      if(
////        cpu_ind_rel != 2'b11
//        ext_cpu_index !== cpu_index_r
//      )
      begin // ext_cpu_index !== cpu_index_r

/**/
              if(
                 (ext_cpu_index & `CPU_ACTIVE) != 0 //=== `CPU_ACTIVE
//                 (ext_cpu_index[31]) == 1 //=== `CPU_ACTIVE
//					  is_ext_cpu_index_active
//                   |(ext_cpu_index & `CPU_ACTIVE) == 1'b 1
              ) begin
				  
				    if(
                  ext_cpu_msg_in == `CPU_R_END //: begin
						&& (cpu_index_r & `CPU_ACTIVE) != 0 //=== `CPU_ACTIVE
//						&& (cpu_index_r[31]) == 1
//						&& is_cpu_index_active

//						&& (ext_cpu_index & `CPU_ACTIVE) === `CPU_ACTIVE
//						&& (ext_cpu_index & ~`CPU_ACTIVE) < (cpu_index_r & ~`CPU_ACTIVE)

						&& ext_cpu_index[30:0] < cpu_index_r[30:0]
//						&& cpu_ind_rel == 2'b01
//						&& is_ext_cpu_index_lt
                ) begin
                  cpu_index_r[30:0] = cpu_index_r[30:0] - 1;
                end
            
				 end else begin // (ext_cpu_index & `CPU_ACTIVE) !== `CPU_ACTIVE
				 
					if(
						 ext_cpu_msg_in == `CPU_R_START //: begin
	//					 && (ext_cpu_index & `CPU_ACTIVE) === `CPU_NONACTIVE
					) begin
					
	//              cpu_index_r[30:0] = cpu_index_r[30:0] + (cpu_index_r[31] ? 1 : -1);
					  if( 
                    (cpu_index_r & `CPU_ACTIVE) != 0 //=== `CPU_ACTIVE 
//                    cpu_index_r[31] == 1
	//					  is_cpu_index_active
					  ) begin
						 cpu_index_r[30:0] = cpu_index_r[30:0] + 1;
					  end else begin
						 cpu_index_r[30:0] = cpu_index_r[30:0] - 1;
					  end
					  
					end
				 end // (ext_cpu_index & `CPU_ACTIVE) ==/!= `CPU_ACTIVE
/**/

//        end //if(ext_next_cpu_e_r === 1)

			end // ext_cpu_index ==/!= cpu_index_r		
		
		
    end //clk_oe == 0
    else begin
	 
	   if(cpu_index_set == 1) begin  //(rst == 1) begin
		  cpu_index_r = cpu_index_in; //0;
		end else begin
		
//		  if(cpu_index_set == 1) begin
//		    cpu_index_r = cpu_index_in;
//		  end else 
		  begin
		  
		  /**/
//        if( bus_busy_in != 1 ) 
		  begin
          if(
			       ext_next_cpu_q == 0
			    || ext_cpu_index != cpu_index_r
          ) begin
			 
			   case(state)
              `START_BEGIN: begin
                cpu_index_r = cpu_index_r | `CPU_ACTIVE;
              end
            
              `FINISH_END: begin
                cpu_index_r = `CPU_NONACTIVE;
              end
            
				endcase
			 end
        end
        /**/

		  end // !cpu_index_set
		end //!rst
		
    end // clk_oe == 1

  end //always
  
endmodule
