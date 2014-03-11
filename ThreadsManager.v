



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
                    
                    rst
                      );
                      
parameter PROC_QUANTITY = 8;

                      
  input wire clk;                      

  inout [`DATA_SIZE0:0] proc;
  reg [`DATA_SIZE0:0] proc_r;
  wire [`DATA_SIZE0:0] proc = proc_r;
  
  input wire [7:0] ctl_state;
  
  input wire [7:0] cpu_msg;

  output reg [`DATA_SIZE0:0] next_proc;
  
  input wire rst;
  
  
  
  reg [`DATA_SIZE0:0] aproc_tbl [0:PROC_QUANTITY];
  reg [`DATA_SIZE0:0] pproc_tbl [0:PROC_QUANTITY];

  reg [`DATA_SIZE0:0] aproc_b;
  reg [`DATA_SIZE0:0] aproc_e;
  reg [`DATA_SIZE0:0] aproc_i;
  
  reg [`DATA_SIZE0:0] pproc_b;
  reg [`DATA_SIZE0:0] pproc_e;
  
  reg [`DATA_SIZE0:0] new_proc_cntr;

  

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
    end else begin
    
      case(ctl_state)
        `CTL_CPU_LOOP: begin
          if(pproc_b != pproc_e) begin
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
            
          end else begin
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
      
      endcase
    
    end

  end
                      
endmodule


