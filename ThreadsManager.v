



`include "sizes.v"
`include "states.v"
`include "inter_cpu_msgs.v"
`include "misc_codes.v"





module ThreadsManager(
                    clk,
                    
                    ctl_state,
                    
                    cpu_msg,
                    
                    proc,

                    next_proc,
                    
                    thrd_cmd,
                    thrd_rslt,
                    
                    data,
                    addr,
                    
                    rst
                      );
                      
parameter PROC_QUANTITY = 8;

                      
  input wire clk;

  inout [`DATA_SIZE0:0] proc;
  reg [`DATA_SIZE0:0] proc_r;
  wire [`DATA_SIZE0:0] proc = proc_r;
  
  input wire [7:0] ctl_state;
  
  input tri [7:0] cpu_msg;

  output reg [`DATA_SIZE0:0] next_proc;
  
  input wire [3:0] thrd_cmd;
  
  output [1:0] thrd_rslt;
  reg [1:0] thrd_rslt_r;
  wire [1:0] thrd_rslt = thrd_rslt_r;
  
  
  inout [`DATA_SIZE0:0] data;
  reg [`DATA_SIZE0:0] data_r;
  tri [`DATA_SIZE0:0] data = (
                               cpu_msg === `CPU_R_FORK_DONE
                             )
                             ? data_r
                             : `DATA_SIZE'h zzzz_zzzz_zzzz_zzzz
                             ;
  
  input [`ADDR_SIZE0:0] addr;
  

  input wire rst;
  
  
  
  reg [`DATA_SIZE0:0] aproc_tbl [0:PROC_QUANTITY];
  reg [`DATA_SIZE0:0] pproc_tbl [0:PROC_QUANTITY];

  reg [`DATA_SIZE0:0] aproc_b;
  reg [`DATA_SIZE0:0] aproc_e;
  reg [`DATA_SIZE0:0] aproc_i;
  
  reg [`DATA_SIZE0:0] pproc_b;
  reg [`DATA_SIZE0:0] pproc_e;
  
  reg [`DATA_SIZE0:0] new_proc_cntr;

  reg ready_to_fork_thread;

  always @(posedge clk) begin
    if(rst == 1) begin
      proc_r = 32'h zzzzzzzz;
      next_proc = 32'h zzzzzzzz;
      
      aproc_b = 0;
      aproc_e = 0;
      aproc_i = 0;
      
      pproc_b = 0;
      pproc_e = 1;
      
      pproc_tbl[0] = 0;
      
      new_proc_cntr = 1;
      
      thrd_rslt_r = 0;
      
      ready_to_fork_thread = 1;
    end else begin


      if(thrd_cmd == `THREAD_CMD_READY_TO_FORK) begin
        ready_to_fork_thread = 1;
      end
      
      
      case(ctl_state)
        `CTL_CPU_LOOP: begin
          if(
              pproc_b != pproc_e
              && ready_to_fork_thread
          ) begin
            next_proc = pproc_tbl[pproc_b];
            
            pproc_b = pproc_b + 1;
            if(pproc_b >= PROC_QUANTITY) begin
              pproc_b = 0;
            end
            
            aproc_tbl[aproc_e] = next_proc;
            aproc_e = aproc_e + 1;
            if(aproc_e >= PROC_QUANTITY) begin
              aproc_e = 0;
            end
            
//            ready_to_fork_thread = 0;
            
          end else begin
            ready_to_fork_thread = 0;
            
            next_proc = aproc_tbl[aproc_i];
            
            aproc_i = aproc_i + 1;
            if(aproc_i >= PROC_QUANTITY) begin
              aproc_i = 0;
            end
            
            if(aproc_i == aproc_e) begin
              aproc_i = aproc_b;
            end
          end
        end
        
        `CTL_CPU_CMD: begin
        
          case(thrd_cmd)
            `THREAD_CMD_RUN: begin
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
            end
            
          endcase
          
        end
      
      endcase
    
    end

  end
                      
endmodule


