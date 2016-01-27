


`include "sizes.v"
`include "states.v"
`include "inter_cpu_msgs.v"
`include "misc_codes.v"




module DispatcherOfCpus(
            clk,
            rst,
            
            halt_q,
            rw_halt,
            
            addr_out,
            data_wire,
            
            read_q,
            write_q,
            read_dn,
            write_dn,
            
            bus_busy,
            
            ext_rst_b,
            ext_rst_e,
            
            ext_cpu_index,
            
            ext_cpu_q,
            ext_cpu_e,
            
            cpu_msg,
            
            dispatcher_q
          );
          
parameter CPU_QUANTITY = 2;
parameter PROC_QUANTITY = 8;


  input wire clk;
  input wire rst;

  input tri halt_q;
  inout tri rw_halt;
  
  inout [`ADDR_SIZE0:0] addr_out;
  reg [`ADDR_SIZE0:0] addr_out_r;
  tri [`ADDR_SIZE0:0] addr_out = addr_out_r;
  
  input tri0 read_q;
  input tri0 write_q;
  
  output read_dn;
  reg read_dn_r;
  tri read_dn = read_dn_r;
  
  output write_dn;
  reg write_dn_r;
  tri write_dn = write_dn_r;
  
  
  inout [`DATA_SIZE0:0] data_wire;
  reg [`DATA_SIZE0:0] data_wire_r;
//  tri [`DATA_SIZE0:0] data_wire = data_wire_r;
  
  inout bus_busy;
  reg bus_busy_r;
  tri bus_busy = bus_busy_r;
  
  

  output reg ext_rst_b; // = RESET;
  input wire ext_rst_e; // = ext_rst_e_r;
  
  inout [`DATA_SIZE0:0] ext_cpu_index;
  reg [`DATA_SIZE0:0] ext_cpu_index_r;
  tri [`DATA_SIZE0:0] ext_cpu_index = ext_cpu_index_r;
  
  output ext_cpu_q;
  reg cpu_q_r;
  wire ext_cpu_q = cpu_q_r;

  input tri ext_cpu_e;
  
  inout [7:0] cpu_msg;
  reg [7:0] cpu_msg_r;
  tri [7:0] cpu_msg = cpu_msg_r;
  
  input tri dispatcher_q;
  
  
  
  
  reg [31:0] mem_addr_tmp;
  reg [31:0] mem_data_tmp;
  reg mem_rd;
  reg mem_wr;
  
	reg [31:0] mem [0:100]; 
  initial $readmemh("mem.txt", mem);
  



  reg [7:0] state_ctl;
  




  reg [3:0] thrd_cmd_r;
  wire [1:0] thrd_rslt;
  
  wire [`DATA_SIZE0:0] next_proc;
  wire [`DATA_SIZE0:0] proc;
  
  reg [`ADDR_SIZE0:0] addr_thread_to_op_r;
  reg [`DATA_SIZE0:0] addr_chan_to_op_r;
  wire [`DATA_SIZE0:0] addr_chan_to_op =
                                        (cpu_msg === `CPU_R_FORK_DONE)
                                        ? `DATA_SIZE'h zzzz_zzzz_zzzz_zzzz
                                        : addr_chan_to_op_r
                                        ;
  
  tri [`DATA_SIZE0:0] data_wire = 
                                  (cpu_msg === `CPU_R_FORK_DONE)
                                  ? addr_chan_to_op
                                  : data_wire_r
                                  ;

  ThreadsManager trds_mngr (
                    .clk(clk),
                    
                    .ctl_state(state_ctl),
                    
                    .cpu_msg(cpu_msg),
                    
                    .proc(proc),

                    .next_proc(next_proc),
                    
                    .thrd_cmd(thrd_cmd_r),
                    .thrd_rslt(thrd_rslt),
                    
                    .addr(addr_thread_to_op_r),
                    .data(addr_chan_to_op),
                    
                    .rst(rst)
                      );


//  reg [`DATA_SIZE0:0] proc_num;
//  reg [`DATA_SIZE0:0] proc_num_t;
//
//  reg [`DATA_SIZE0:0] proc_tbl [0:PROC_QUANTITY];

//  reg [`ADDR_SIZE0:0] cpu_tbl [0:CPU_QUANTITY + 1];
//  reg [7:0] cpu_tbl_i;

  reg [`DATA_SIZE0:0] cpu_num_a;
  reg [`DATA_SIZE0:0] cpu_num_na;
  
  reg [`DATA_SIZE0:0] cpu_num;

//  reg [7:0] state_ctl;
  
  reg new_cpu_restarted;



always @(negedge clk) begin
    
    ext_rst_b = 0;
    
    read_dn_r = 1'b z;
    write_dn_r = 1'b z;
//    bus_busy_r = 1'b z;
    
    cpu_q_r = 0;
    
    cpu_msg_r = 8'hzz;
    
//    halt_q = 0; //1'bz;
    
  if(rst == 1) begin 
    bus_busy_r = 1'b z;
    
//    proc_num = 0;
//    proc_num_t = 1;
//    proc_tbl[0] = 0;
    
    cpu_num = 0;
    cpu_num_a = 0;
    cpu_num_na = CPU_QUANTITY;
    
    data_wire_r = 32'h zzzzzzzz; //cpu_num; //Q;
    bus_busy_r  = 1'bz;
    
    state_ctl = `CTL_RESET_WAIT;
    
    ext_cpu_index_r = 0; //32'h zzzzzzzz;
    cpu_q_r = 0;
    
    ext_rst_b = 1;
    
    mem_addr_tmp = 0;
    mem_rd = 0;
    mem_wr = 0;
    
    new_cpu_restarted = 0;
    
    cpu_msg_r = 8'hzz;
    
    thrd_cmd_r = `THREAD_CMD_NULL;
//    thrd_cmd_r = `THREAD_CMD_GET_NEXT_STATE;
    
//    cpu_tbl[0] = 0;
//    cpu_tbl_i = 0;
    
  end else /*if(ext_rst_e == 1)*/ begin
//    if(read_q == 1 || write_q == 1)
//      halt_q = 1;


          if(mem_rd == 1 || mem_wr == 1) begin
            if(rw_halt == 1) begin
              mem_rd = 0;
              mem_wr = 0;
              state_ctl = `CTL_CPU_LOOP;
            end else begin
              state_ctl = `CTL_MEM_WORK;
            end
          end 
          
//          else
//          if(dispatcher_q == 1) begin
//            
//          end else begin
//            state_ctl = `CTL_MEM_WORK;
//          end


          if(thrd_cmd_r == `THREAD_CMD_GET_NEXT_STATE) begin
            thrd_cmd_r = `THREAD_CMD_NULL;
          end


    case(state_ctl)
      `CTL_RESET_WAIT: begin
        if(cpu_msg === `CPU_R_RESET) begin //read_dn == 1) begin
          //data_wire_r = data_wire_r + 1;
//          proc_tbl[ext_cpu_index_r] = 0; //32'h ffffffff;
          ext_cpu_index_r = ext_cpu_index_r + 1;
          //data_wire_r = 32'h zzzzzzzz;
          addr_out_r  = 32'h zzzzzzzz;
        end
          
//        if(bus_busy === 1) begin
          //proc_tbl[data_wire] = 0; //32'h ffffffff;
        
//        end
        ext_rst_b = 0;
        if(ext_rst_e == 1) begin
          //ext_rst_b = 0;
          ext_cpu_index_r = 32'h zzzzzzzz;
          data_wire_r = 32'h zzzzzzzz;
          state_ctl = `CTL_CPU_LOOP;
        end
      end
      
      `CTL_CPU_LOOP: begin
//        bus_busy_r  = 1;
        if(bus_busy !== 1) begin
          if(cpu_num_na > 0 && new_cpu_restarted == 0) begin
            ext_cpu_index_r = `CPU_NONACTIVE;
            new_cpu_restarted = 1;
          end else begin
            cpu_num = cpu_num + 1;
            if(cpu_num >= cpu_num_a) begin
              cpu_num = 0;
            end
            ext_cpu_index_r = cpu_num | `CPU_ACTIVE;
            new_cpu_restarted = 0;
          end
        
//        proc_num = proc_num + 1;
//        if(proc_num >= proc_num_t) begin
//          proc_num = 0;
//        end

//          if(ext_cpu_index === 0) begin
            addr_out_r = next_proc; //cpu_tbl[cpu_tbl_i - (ext_cpu_index_r & ~`CPU_ACTIVE)]; //next_proc;   //proc_tbl[proc_num];
//          end
        
//        cpu_num = cpu_num + 1;
//        if(cpu_num >= CPU_QUANTITY) begin
//          cpu_num = 0;
//        end
        
//        cpu_num = cpu_num + 1;
        
//        addr_out_r = proc_tbl[cpu_num];
        
          cpu_q_r = 1;
          
//          $display("cpu_ind= %x, proc = %x", ext_cpu_index_r, addr_out_r);
        
          state_ctl = `CTL_CPU_CMD;
        end
      end
      
      `CTL_CPU_CMD: begin
          addr_out_r = `ADDR_SIZE'h zzzzzzzz;
        if(cpu_q_r == 1) begin
          cpu_q_r = 0;
        end
        
        if(
          read_q == 1 &&
          mem_rd == 0 &&
          mem_wr == 0
        ) begin
          mem_addr_tmp = addr_out;
          mem_rd = 1;
          mem_wr = 0;
        end else 
        if(
          write_q == 1 &&
          mem_rd == 0 &&
          mem_wr == 0
        ) begin
          mem_addr_tmp = addr_out;
          mem_data_tmp = data_wire;
          mem_rd = 0;
          mem_wr = 1;
        end else 
        if(ext_cpu_e === 1) begin
            //cpu_running = 1;
            //addr_out_r = `ADDR_SIZE'h zzzzzzzz;
          ext_cpu_index_r = `DATA_SIZE'h zzzzzzzz;
          
//          data_wire_r = mem_addr_tmp;
          
            case(cpu_msg) //data_wire)
              `CPU_R_START: begin
                cpu_num_na = cpu_num_na - 1;
                cpu_num_a = cpu_num_a + 1;
          
                cpu_num = cpu_num + 1;

                new_cpu_restarted = 0;

                thrd_cmd_r = `THREAD_CMD_GET_NEXT_STATE;
                
//                cpu_tbl_i = cpu_tbl_i +1;
//                cpu_tbl[cpu_tbl_i /*ext_cpu_index_r & ~`CPU_ACTIVE*/] = next_proc;
                
              end
            
              `CPU_R_END: begin
                cpu_num_a = cpu_num_a - 1;
                cpu_num_na = cpu_num_na + 1;
                
//                thrd_cmd_r = `THREAD_CMD_GET_NEXT_STATE;
              end
            
              `CPU_R_FORK_DONE: begin
                thrd_cmd_r = `THREAD_CMD_GET_NEXT_STATE;
                
                cpu_msg_r = 8'h zz;
              end
            
            endcase
//          if(mem_rd == 1 || mem_wr == 1) begin
//            state_ctl = `CTL_MEM_WORK;
//          end else

          if(dispatcher_q == 1) begin
            state_ctl = `CTL_CPU_LOOP;
          end else begin
            state_ctl = `CTL_MEM_WORK;
          
//            bus_busy_r  = 1'bz;
          end
          
        end
        
        else begin
//          ext_cpu_index_r = `DATA_SIZE'h zzzzzzzz;
          
//          data_wire_r = mem_addr_tmp;

            if(thrd_cmd_r == `THREAD_CMD_NULL) begin
              case(cpu_msg) //data_wire)              
                `CPU_R_STOP_THRD: begin
//                  proc_tbl[proc_num_t] = proc_num_t << 4;
//                  proc_num_t = proc_num_t + 1;
                end
              
                `CPU_R_FORK_THRD: begin
                  addr_thread_to_op_r = addr_out;
                  addr_chan_to_op_r = data_wire;
                  
                  thrd_cmd_r = `THREAD_CMD_RUN;
                end
                
//                `CPU_R_FORK_DID: begin
//                  cpu_msg_r = 8'h zz;
//                end
            
              endcase
            end else
            if(thrd_cmd_r == `THREAD_CMD_RUN) begin
              cpu_msg_r = `CPU_R_FORK_DONE;
              
              thrd_cmd_r = `THREAD_CMD_NULL;
            end
        end
        
      end
      
      `CTL_MEM_WORK: begin

        data_wire_r = 32'h zzzzzzzz;
        addr_out_r  = 32'h zzzzzzzz;
        
//        data_wire_r = 32'h zzzzzzzz;

          if(mem_rd == 1 || mem_wr == 1) begin
            if(bus_busy_r === 1) begin
              bus_busy_r = 1'b z;
              mem_rd = 0;
              mem_wr = 0;
//              halt_q = 0;
              if(dispatcher_q == 1) begin
                state_ctl = `CTL_CPU_LOOP;
              end
            end
          end else begin
              if(dispatcher_q == 1) begin
                state_ctl = `CTL_CPU_LOOP;
              end
          end

          if(mem_rd == 1) begin
            //addr_out_r = 32'h zzzzzzzz;
            addr_out_r = mem_addr_tmp;
            data_wire_r = mem[mem_addr_tmp];
            read_dn_r = 1;
            bus_busy_r = 1;
//            halt_q = 1;
//            mem_rd = 0;

            $display("%m) Read: addr = %x (%d), data = %x (%d)", addr_out_r, addr_out_r, data_wire_r, data_wire_r);
          end 
//          else begin
//         //            data_wire_r = 32'h zzzzzzzz;
//          end

          if(mem_wr == 1) begin
            addr_out_r = mem_addr_tmp;
            mem[mem_addr_tmp] = mem_data_tmp; // data_wire;
            data_wire_r = mem_data_tmp;
            //$monitor("wrote mem[ %x ] = %x",addr_out,mem[addr_out]);
            write_dn_r = 1;
            bus_busy_r = 1;
//            halt_q = 1;
//            mem_wr = 0;

            $display("%m) Write: addr = %x (%d), data = %x (%d)", addr_out_r, addr_out_r, data_wire_r, data_wire_r);
          end
          
          if(dispatcher_q == 1) begin
        //    state_ctl = `CTL_CPU_LOOP;
          end
      
      end
    
    endcase
    
  end
  
end


endmodule