



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
                    
                    data_in,
                    data_out,
                    addr,
                    
                    cpu_q,
                    
                    rst
                      );
                      
parameter PROC_QUANTITY = 8;

                      
  input wire clk;

  inout [`DATA_SIZE0:0] proc;
  reg [`DATA_SIZE0:0] proc_r;
  wire [`DATA_SIZE0:0] proc = proc_r;
  
  input wire [7:0] ctl_state;
  
  inout tri [7:0] cpu_msg;

  output reg [`DATA_SIZE0:0] next_proc;
  
  input wire [3:0] thrd_cmd;
  
  output [1:0] thrd_rslt;
  reg [1:0] thrd_rslt_r;
  wire [1:0] thrd_rslt = thrd_rslt_r;
  
  
  input tri cpu_q;
  
  
  input tri [`DATA_SIZE0:0] data_in;
  output [`DATA_SIZE0:0] data_out;
  reg [`DATA_SIZE0:0] data_r;
  tri [`DATA_SIZE0:0] data_out =
/**/
                             (
                               (ctl_state == `CTL_CPU_CMD && cpu_msg === `CPU_R_FORK_DONE)
                               || (ctl_state == `CTL_CPU_CMD && cpu_msg === `CPU_R_STOP_DONE)
//                               || (ctl_state == `CTL_CPU_LOOP)
                             )
                             || cpu_q === 1
                             ? data_r
                             : `DATA_SIZE'h zzzz_zzzz_zzzz_zzzz
/**/
                             ;
  
  input [`ADDR_SIZE0:0] addr;
  

  input wire rst;
  
  
  
  reg [(`DATA_SIZE0 + `ADDR_SIZE + 1):0] aproc_tbl [0:PROC_QUANTITY];
  reg [(`DATA_SIZE0 + `ADDR_SIZE):0] pproc_tbl [0:PROC_QUANTITY];
  reg [(`DATA_SIZE0 + `ADDR_SIZE):0] sproc_tbl [0:PROC_QUANTITY];

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

  always @(posedge clk) begin
    if(rst == 1) begin
      proc_r = 32'h zzzzzzzz;
      next_proc = 0; // 32'h zzzzzzzz;
      
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
    end else begin


      if(thrd_cmd == `THREAD_CMD_GET_NEXT_STATE) begin
        ready_to_fork_thread = 1;
      end
      
      
      case(ctl_state)
        `CTL_CPU_LOOP: begin
          if(ready_to_fork_thread) begin
          
            if(
                pproc_b != pproc_e
  //              && ready_to_fork_thread
            ) begin
              {data_r, next_proc} = pproc_tbl[pproc_b];
              
              pproc_b = pproc_b + 1;
              if(pproc_b >= PROC_QUANTITY) begin
                pproc_b = 0;
              end
              
              aproc_tbl[aproc_e] = {1'b 0, data_r, next_proc};
              aproc_e = aproc_e + 1;
              if(aproc_e >= PROC_QUANTITY) begin
                aproc_e = 0;
              end
              
              ready_to_fork_thread = 0;
              
            end else begin
  //            ready_to_fork_thread = 0;
              
              {is_need_stop_thrd, data_r, next_proc} = aproc_tbl[aproc_i];
              
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
        
        end
        
        `CTL_CPU_CMD: begin
        
          case(thrd_cmd)
            `THREAD_CMD_RUN: begin
              if(pproc_e < PROC_QUANTITY) begin
                pproc_tbl[pproc_e] = {data_in, addr};
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
              for(i = 0; i < PROC_QUANTITY; i = i+1 ) begin
                if( aproc_tbl[i][`ADDR_SIZE0:0] === addr ) begin
                  aproc_tbl[i][(`DATA_SIZE0 + `ADDR_SIZE + 1)] = 1'b 1;

                  data_r = -1;
                  thrd_rslt_r = 1;
                end
              end
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
            
          endcase
          
        end
      
      endcase
    
    end

  end
                      
endmodule


