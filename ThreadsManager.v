



`include "sizes.v"
`include "states.v"
`include "inter_cpu_msgs.v"
`include "misc_codes.v"



`define APROC_STATE_NULL					0
`define APROC_STATE_ACTIVATE_PROC		1
`define APROC_STATE_GET_NEXT_PROC		2
`define APROC_STATE_GNP_E_TO_I_FROM		11
`define APROC_STATE_GNP_E_TO_I_TO		4
`define APROC_STATE_FILL_NEXT_PROC		5
`define APROC_STATE_RST						6
`define APROC_STATE_MARK_PROC_TO_STOP	7
//`define APROC_STATE_NULL		0
//`define APROC_STATE_NULL		0
//`define APROC_STATE_NULL		0



module ThreadsManager(
                    clk,
						  clk_oe,
                    
                    ctl_state,
                    
                    cpu_msg_in,
                    cpu_msg_out,
                    
                    proc,

                    next_proc,
                    
                    thrd_cmd,
                    thrd_rslt,
                    
                    data_in,
                    data_out,
						  
                    addr_in,
                    
                    cpu_q,
                    
                    rst
                      );
                      
parameter PROC_QUANTITY = 8;

                      
  input wire clk;
  
  input wire clk_oe;

  inout [`DATA_SIZE0:0] proc;
  reg [`DATA_SIZE0:0] proc_r;
  wire [`DATA_SIZE0:0] proc = proc_r;
  
  input wire [7:0] ctl_state;
  reg [7:0] ctl_state_int;
  
  input wire [7:0] cpu_msg_in;
  output wire [7:0] cpu_msg_out;

  reg [`DATA_SIZE0:0] next_proc_tmp_r;
  
  output [`DATA_SIZE0:0] next_proc;
  reg [`DATA_SIZE0:0] next_proc_r;
  wire [`DATA_SIZE0:0] next_proc = 
                                    aproc_state == `APROC_STATE_ACTIVATE_PROC
											 ? next_proc_tmp_r
                                  : next_proc_r
											 ;
  
  reg [`DATA_SIZE0:0] proc_to_remove_r;


  input wire [3:0] thrd_cmd;
  
  output [1:0] thrd_rslt;
  reg [1:0] thrd_rslt_r;
  wire [1:0] thrd_rslt = thrd_rslt_r;
  
  
  input wire cpu_q;
  

  reg [`DATA_SIZE0:0] data_aproc_r;
  
  input wire [`DATA_SIZE0:0] data_in;
  output [`DATA_SIZE0:0] data_out;
  reg [`DATA_SIZE0:0] data_r;
  wire [`DATA_SIZE0:0] data_out =
/**/
                             (
                               (ctl_state == `CTL_CPU_CMD && cpu_msg_in == `CPU_R_FORK_DONE)
                               || (ctl_state == `CTL_CPU_CMD && cpu_msg_in == `CPU_R_STOP_DONE)
//                               || (ctl_state == `CTL_CPU_LOOP)
                             )
                             || cpu_q == 1
                             ? (
									        aproc_state == `APROC_STATE_GET_NEXT_PROC
											? data_aproc_r
									      : data_r
									    )
                             : 0 //`DATA_SIZE'h zzzz_zzzz_zzzz_zzzz
/**/
                             ;
  
  input wire [`ADDR_SIZE0:0] addr_in;
  

  input wire rst;
  
  
  
  reg [(`DATA_SIZE0 + `ADDR_SIZE + 1):0] aproc_tbl [0:PROC_QUANTITY];
  reg [(`DATA_SIZE0 + `ADDR_SIZE):0] pproc_tbl [0:PROC_QUANTITY];
  reg [(`DATA_SIZE0 + `ADDR_SIZE):0] sproc_tbl [0:PROC_QUANTITY];

  reg aproc_cpy_tmp_is_need_stop_thrd;
  reg [`DATA_SIZE0:0] aproc_cpy_tmp_data_aproc_r;
  reg [`ADDR_SIZE0:0] aproc_cpy_tmp_next_proc_r;
//  reg [(`DATA_SIZE0 + `ADDR_SIZE + 1):0] aproc_tbl_tmp_r;
  
  reg [7:0] aproc_state;
  reg aproc_clk;
  reg [`DATA_SIZE0:0] aproc_i_from;
  reg [`DATA_SIZE0:0] aproc_i_to;

  reg [`DATA_SIZE0:0] aproc_b;
  reg [`DATA_SIZE0:0] aproc_e;
  reg [`DATA_SIZE0:0] aproc_i;
  
  reg [`DATA_SIZE0:0] pproc_b;
  reg [`DATA_SIZE0:0] pproc_e;
  

  reg [`DATA_SIZE0:0] sproc_e;
//  reg [`DATA_SIZE0:0] sproc_i;

  
//  wire [`ADDR_SIZE0:0] aproc_addrs[0:PROC_QUANTITY]; // = aproc_tbl[`ADDR_SIZE0:0][0:PROC_QUANTITY];
//  assign aproc_addrs [`ADDR_SIZE0:0] = aproc_tbl[`ADDR_SIZE0:0];
//  wire aproc_tst[0:PROC_QUANTITY]; // = (aproc_tbl[0:PROC_QUANTITY]) === addr;
//  assign aproc_tst[0:PROC_QUANTITY] = (aproc_tbl[0:PROC_QUANTITY] === addr);

  reg [7:0] i;
  
  
  
  reg [`DATA_SIZE0:0] new_proc_cntr;

  reg ready_to_fork_thread;
  
  reg is_need_stop_thrd;

  reg proc_to_remove_flag;
  
  
  
  always @(posedge aproc_clk)begin
    case(aproc_state)
	   `APROC_STATE_ACTIVATE_PROC: begin
		  aproc_tbl[aproc_e] = {1'b 0, data_r, next_proc_tmp_r};
		  next_proc_r = next_proc_tmp_r;
		end
		
		`APROC_STATE_GET_NEXT_PROC: begin
		  if(
		    proc_to_remove_flag == 1
			 && aproc_tbl[aproc_i][`ADDR_SIZE0:0] == proc_to_remove_r 
		  ) begin
			 {/*aproc_cpy_tmp_is_need_stop_thrd,*/ data_aproc_r, next_proc_r} = aproc_tbl[aproc_i];
		    is_need_stop_thrd = 1'b 1;
			 proc_to_remove_flag = 0;
		  end else begin
          {is_need_stop_thrd, data_aproc_r, next_proc_r} = aproc_tbl[aproc_i];
        end
		end
		
		`APROC_STATE_GNP_E_TO_I_FROM: begin
//		  {aproc_tbl_tmp_r} = aproc_tbl[aproc_i_from];
/**
        {
		    //aproc_cpy_tmp_is_need_stop_thrd, 
			 aproc_cpy_tmp_data_aproc_r, 
			 aproc_cpy_tmp_next_proc_r
        } 
/**/
		  {is_need_stop_thrd, data_aproc_r, next_proc_r}
		  = aproc_tbl[aproc_e]; //i_from];
		end
		
		`APROC_STATE_GNP_E_TO_I_TO: begin
		  aproc_tbl[aproc_i/*_to*/] = 
		  {is_need_stop_thrd, data_aproc_r, next_proc_r}
/**
        {
		    1'b 0, //aproc_cpy_tmp_is_need_stop_thrd, 
			 aproc_cpy_tmp_data_aproc_r, 
			 aproc_cpy_tmp_next_proc_r
        }
/**/
		  ;
		end
		
//		`APROC_STATE_FILL_NEXT_PROC: begin
//		  next_proc_r = next_proc_tmp_r;
//		end
		
		`APROC_STATE_RST: begin
		  next_proc_r = 0;
		  data_aproc_r = 0;
		  
//		  aproc_tbl_tmp_r = 0;
		  
//		  proc_to_remove_flag = 0;
		end
		
		`APROC_STATE_MARK_PROC_TO_STOP: begin
//              for(i = 0; i < PROC_QUANTITY; i = i+1 ) begin
//                if( aproc_tbl[i][`ADDR_SIZE0:0] == proc_to_remove_r ) begin
//                  aproc_tbl[i][(`DATA_SIZE0 + `ADDR_SIZE + 1)] = 1'b 1;
//                end
//              end
				  
        proc_to_remove_flag = 1;
      end

	 
	 endcase
  end
  
  
  always @(posedge clk) begin
    if(clk_oe == 0) begin
	   aproc_clk = 0;
	 end else begin
	 
    if(rst == 1) begin
      proc_r = 0; //32'h zzzzzzzz;
//      next_proc = 0; // 32'h zzzzzzzz;
      /*next_proc_tmp_r = 0;*/ aproc_state = `APROC_STATE_RST; aproc_clk = 1;
      
      aproc_b = 0;
      aproc_e = 0;
      aproc_i = 0;
      
      pproc_b = 0;
      pproc_e = 1;
      
      pproc_tbl[0] = 0;
      
      new_proc_cntr = 1;
      
      thrd_rslt_r = 0;
      
      ready_to_fork_thread = 1;
      
      sproc_e = 0;
		
		aproc_state = `APROC_STATE_NULL;
		aproc_clk = 0;
		
		ctl_state_int = `CTL_CPU_LOOP;
		
//		proc_to_remove_flag = 0;
    end else 
	 begin


      if(thrd_cmd == `THREAD_CMD_GET_NEXT_STATE) begin
        ready_to_fork_thread = 1;
      end
      
      
		
      case(thrd_cmd)
        `THREAD_CMD_RUN: begin
          if(pproc_e < PROC_QUANTITY) begin
            pproc_tbl[pproc_e] = {data_in, addr_in};
            pproc_e = pproc_e + 1;
            
            data_r = -1;
            thrd_rslt_r = 1;
          end else
          begin
            data_r = 0;
            thrd_rslt_r = 0;
          end
        end
        
        `THREAD_CMD_STOP: begin
          data_r = 0;
          thrd_rslt_r = 0;
          
//              for(i = aproc_b; i != aproc_e; i = (i < (PROC_QUANTITY - 1)) ? i+1 : 0 ) begin
          if(proc_to_remove_flag == 0) begin
            proc_to_remove_r = addr_in;
				aproc_state = `APROC_STATE_MARK_PROC_TO_STOP; aproc_clk = 1;
          end

//              for(i = 0; i < PROC_QUANTITY; i = i+1 ) begin
//                if( aproc_tbl[i][`ADDR_SIZE0:0] == addr_in ) begin
//                  aproc_tbl[i][(`DATA_SIZE0 + `ADDR_SIZE + 1)] = 1'b 1;
//
//                  data_r = -1;
//                  thrd_rslt_r = 1;
//                end
//              end

          data_r = -1;
          thrd_rslt_r = 1;
              /*
              if(pproc_e < PROC_QUANTITY) begin
                pproc_tbl[pproc_e] = addr;
                pproc_e = pproc_e + 1;
                
                data_r = -1;
                thrd_rslt_r = 1;
              end else
              begin
                data_r = 0;
                thrd_rslt_r = 0;
              end
              */
        end
        
		  
        default: begin
		
          case(ctl_state_int)
            `CTL_CPU_LOOP_ACTIVATE_PROC_SAVE_TO_APROC: begin
              aproc_state = `APROC_STATE_ACTIVATE_PROC; aproc_clk = 1;
			 
			     ctl_state_int = `CTL_CPU_LOOP_ACTIVATE_PROC_NEW_APROC_E;
		      end
		  
		  
            `CTL_CPU_LOOP_ACTIVATE_PROC_NEW_APROC_E: begin
              aproc_e = aproc_e + 1;
              if(aproc_e >= PROC_QUANTITY) begin
                aproc_e = 0;
              end
              
              ready_to_fork_thread = 0;
				  
				  ctl_state_int = `CTL_CPU_LOOP;
		      end
		  
		  
            `CTL_CPU_LOOP: begin
		        if(ctl_state == `CTL_CPU_LOOP) begin
                if(ready_to_fork_thread) begin
          
                  if(
                    pproc_b != pproc_e
  //                  && ready_to_fork_thread
                  ) begin
//                    {data_r, next_proc} = pproc_tbl[pproc_b];
                    {data_r, next_proc_tmp_r} = pproc_tbl[pproc_b];
              
				        ctl_state_int = `CTL_CPU_LOOP_ACTIVATE_PROC_SAVE_TO_APROC;
              
                    pproc_b = pproc_b + 1;
                    if(pproc_b >= PROC_QUANTITY) begin
                      pproc_b = 0;
                    end
/**
              //aproc_tbl[aproc_e] = {1'b 0, data_r, next_proc};
				  aproc_state = `APROC_STATE_ACTIVATE_PROC; aproc_clk = 1;
              aproc_e = aproc_e + 1;
              if(aproc_e >= PROC_QUANTITY) begin
                aproc_e = 0;
              end
              
              ready_to_fork_thread = 0;
/**/
                  end else begin
  //            ready_to_fork_thread = 0;
              
				        aproc_state = `APROC_STATE_GET_NEXT_PROC; aproc_clk = 1;
              //{is_need_stop_thrd, data_r, next_proc} = aproc_tbl[aproc_i];
              
				        ctl_state_int = `CTL_CPU_LOOP_GNP_IF_NEED_STOP;
				  
/**
              if(is_need_stop_thrd) begin
//                aproc_tbl[aproc_i] = aproc_tbl[aproc_e];
                if(aproc_e != aproc_b) begin
                  if(aproc_e == 0) begin
                    aproc_e = PROC_QUANTITY - 1;
                  end 
                  else begin
                    aproc_e = aproc_e - 1;
                  end
                end

                if(aproc_i == aproc_e) begin
                  aproc_i = aproc_b;
                end else begin
                  aproc_tbl[aproc_i] = aproc_tbl[aproc_e];
                end
              end
              else begin
                aproc_i = aproc_i + 1;
                if(aproc_i >= PROC_QUANTITY) begin
                  aproc_i = 0;
                end
                
                if(aproc_i == aproc_e) begin
                  aproc_i = aproc_b;
                end
              
                ready_to_fork_thread = 0;
              end
            end
          
          end
/**/
                  end
			       end
              end
		      end
		  
		  
		      `CTL_CPU_LOOP_GNP_IF_NEED_STOP: begin
              data_r = data_aproc_r;
			 
              if(is_need_stop_thrd) begin
//XXXXXXXXXXXX                aproc_tbl[aproc_i] = aproc_tbl[aproc_e];
                if(aproc_e != aproc_b) begin
                  if(aproc_e == 0) begin
                    aproc_e = PROC_QUANTITY - 1;
                  end 
                  else begin
                    aproc_e = aproc_e - 1;
                  end
                end
					 
					 ctl_state_int = `CTL_CPU_LOOP_GNP_NEED_STOP_CORR_I_FROM;
/**
                if(aproc_i == aproc_e) begin
                  aproc_i = aproc_b;
                end else begin
                  aproc_tbl[aproc_i] = aproc_tbl[aproc_e];
                end
/**/
              end
              else begin
                if(aproc_i < PROC_QUANTITY - 1) begin
                  aproc_i = aproc_i + 1;
					 end else begin
                  aproc_i = 0;
                end
                
					 ctl_state_int = `CTL_CPU_LOOP_GNP_NO_NEED_STOP_CORR_I;
/**
                if(aproc_i == aproc_e) begin
                  aproc_i = aproc_b;
                end
              
                ready_to_fork_thread = 0;
/**/
              end
//            end
            end
		  
		  
		      `CTL_CPU_LOOP_GNP_NEED_STOP_CORR_I_FROM: begin
		        if(aproc_i == aproc_e) begin
                aproc_i = aproc_b;
			 
			       ctl_state_int = `CTL_CPU_LOOP;
              end else begin
			       //aproc_i_from = aproc_e;
			       aproc_state = `APROC_STATE_GNP_E_TO_I_FROM; aproc_clk = 1;
                //aproc_tbl[aproc_i] = aproc_tbl[aproc_e];
			 
			       ctl_state_int = `CTL_CPU_LOOP_GNP_NEED_STOP_CORR_I_TO;
              end
            end
		  
		  
		      `CTL_CPU_LOOP_GNP_NEED_STOP_CORR_I_TO: begin
		        //aproc_i_to = aproc_i;
			     aproc_state = `APROC_STATE_GNP_E_TO_I_TO; aproc_clk = 1;
			 
			     ctl_state_int = `CTL_CPU_LOOP;
            end
		  
		  
		      `CTL_CPU_LOOP_GNP_NO_NEED_STOP_CORR_I: begin
              if(aproc_i == aproc_e) begin
                aproc_i = aproc_b;
              end
              
              ready_to_fork_thread = 0;
			 
			     ctl_state_int = `CTL_CPU_LOOP;
		      end
		  
/**
        `CTL_CPU_CMD: begin
        
          case(thrd_cmd)
            `THREAD_CMD_RUN: begin
              if(pproc_e < PROC_QUANTITY) begin
                pproc_tbl[pproc_e] = {data_in, addr_in};
                pproc_e = pproc_e + 1;
                
                data_r = -1;
                thrd_rslt_r = 1;
              end else
              begin
                data_r = 0;
                thrd_rslt_r = 0;
              end
            end
            
            `THREAD_CMD_STOP: begin
              data_r = 0;
              thrd_rslt_r = 0;
              
//              for(i = aproc_b; i != aproc_e; i = (i < (PROC_QUANTITY - 1)) ? i+1 : 0 ) begin
              if(proc_to_remove_flag == 0) begin
                proc_to_remove_r = addr_in;
				    aproc_state = `APROC_STATE_MARK_PROC_TO_STOP; aproc_clk = 1;
              end

//              for(i = 0; i < PROC_QUANTITY; i = i+1 ) begin
//                if( aproc_tbl[i][`ADDR_SIZE0:0] == addr_in ) begin
//                  aproc_tbl[i][(`DATA_SIZE0 + `ADDR_SIZE + 1)] = 1'b 1;
//
//                  data_r = -1;
//                  thrd_rslt_r = 1;
//                end
//              end

              data_r = -1;
              thrd_rslt_r = 1;
            end
            
          endcase
          
        end
/**/
      
          endcase
	     end
	 
      endcase
    
    end // !rst
	 end // clk_oe

  end
                      
endmodule


