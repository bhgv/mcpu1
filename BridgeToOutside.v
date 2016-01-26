


`include "sizes.v"
`include "states.v"
`include "inter_cpu_msgs.v"
`include "misc_codes.v"



module BridgeToOutside (
            clk, 
            state,
            
            base_addr,
            command,
            
            halt_q,
            cpu_ind_rel,
            rw_halt,
            
            bus_busy,
            addr,
            data,
            read_q,
            write_q,
            read_dn,
            write_dn,
//            read_e,
//            write_e,
            
            src1,
            src0,
            dst,
            dst_h,
            cond,
            
            disp_online,
            
            next_state,
            
            rst,
            
            ext_rst_b,
            ext_rst_e,
            
            ext_cpu_index,
            
            ext_next_cpu_q,
            ext_next_cpu_e,
            
            ext_bus_busy,
            
            ext_dispatcher_q,
            
            ext_rw_halt,
            
            int_cpu_msg,
            ext_cpu_msg,
            
            ext_read_q,
            ext_write_q
            
            );
  input wire clk;
  input wire [`STATE_SIZE0:0] state;
  input wire [31:0] command;
  
  wire [3:0] cmd_code = command[31:28];
  

  output [`ADDR_SIZE0:0] base_addr;
  reg [`ADDR_SIZE0:0] base_addr_r;
  wire [`ADDR_SIZE0:0] base_addr = base_addr_r;
  
  inout halt_q;
  reg halt_q_r;
  tri halt_q; // = halt_q_r;
//  reg halt_q; // = (ext_read_q == 1 || ext_write_q == 1) ?
//                1 : 1'bz;
  /*
                (read_q | write_q | read_dn | write_dn ) == 1 ?
                0 :
                ext_read_q == 1 ?
                1 :
                ext_write_q == 1 ?
                1 :
                0;
  */
  
  inout tri rw_halt;
  
  output reg [1:0] cpu_ind_rel;
  
  
  inout [`ADDR_SIZE0:0] addr;
  reg [`ADDR_SIZE0:0] addr_r;
  tri [`ADDR_SIZE0:0] addr; // = addr_r;
  
  input tri read_q;
  input tri  write_q;

  inout bus_busy;
  reg bus_busy_r;
  tri bus_busy = bus_busy_r;
  
  inout [`DATA_SIZE0:0] data;
  reg [`DATA_SIZE0:0] data_r;
  tri [`DATA_SIZE0:0] data = data_r;
//  assign data = write_q==1 ? dst_r : 32'h z;
  
  input  read_dn;
//  reg read_dn_r;
//  wire read_dn = read_dn_r;
  
  input  wire write_dn;
//  output reg read_e;
//  output reg write_e;
  

  input  wire [`DATA_SIZE0:0] src1;
  input  wire [`DATA_SIZE0:0] src0;
  input  wire [`DATA_SIZE0:0] dst;
  input wire [`DATA_SIZE0:0] dst_h;

  input  wire [`DATA_SIZE0:0] cond;
  
  
  output reg disp_online;
  
  
  output reg next_state;
  
  output reg rst;
  reg [2:0] rst_state;
  
  
  inout ext_rw_halt;
  tri ext_rw_halt; // = rw_halt; // = cpu_index_r > ext_cpu_index ?
//                     (
//                      (read_q == 1 && ext_cpu_index < cpu_index_r) ||
//                      (write_q == 1 && ext_cpu_index > cpu_index_r)
//                     ) ?
//                     rw_halt
//                     : 1'bz
//                        ;
  
  input wire ext_rst_b;
  output reg ext_rst_e = 0;
  
  inout [`DATA_SIZE0:0] ext_cpu_index;
  reg [`DATA_SIZE0:0] cpu_index_itf;
  tri [`DATA_SIZE0:0] ext_cpu_index = 
//                              (
//                                read_q == 1 ||
//                                write_q == 1
//                              ) ?
//                              cpu_index_r :
                              cpu_index_itf;
  reg [`DATA_SIZE0:0] cpu_index_r;
  
  input tri ext_next_cpu_q;
  inout ext_next_cpu_e;
  reg ext_next_cpu_e_r;
  tri ext_next_cpu_e = ext_next_cpu_e_r;
  
  inout ext_bus_busy;
  reg ext_bus_busy_r;
  tri ext_bus_busy = ext_bus_busy_r;
  
  output reg ext_dispatcher_q;
  
  
  inout [7:0] int_cpu_msg;
  
  reg [7:0] cpu_msg_tmp;
  
  inout [7:0] ext_cpu_msg;
  reg [7:0] cpu_msg_r;
  tri [7:0] ext_cpu_msg = 
                          (
                            state === `ALU_BEGIN 
                            && 
                            int_cpu_msg === `CPU_R_FORK_THRD
                          ) 
                          ? int_cpu_msg 
                          : 
                          cpu_msg_r
                          ;
  
  tri [7:0] int_cpu_msg = 
                          (
                            state === `ALU_BEGIN 
                            && 
                            ext_cpu_msg === `CPU_R_FORK_DONE
                          ) 
                          ? ext_cpu_msg 
                          : 
                          8'h zzzz
                        ;

  
  inout ext_read_q;
  tri ext_read_q    = (state == `READ_COND ||
                        state == `READ_COND_P ||
                        state == `READ_SRC1 ||
                        state == `READ_SRC1_P ||
                        state == `READ_SRC0 ||
                        state == `READ_SRC0_P ||
                        state == `READ_DST ||
                        state == `START_READ_CMD ||
                        state == `START_READ_CMD_P
                        ) &&
                        disp_online == 1 
//                        && (!ext_next_cpu_e === 1)
                        ? read_q 
                        : 1'bz;
  inout ext_write_q;
  tri ext_write_q   = (state == `WRITE_REG_IP ||
                        state == `WRITE_DST    ||
                        state == `WRITE_DST_P  ||
                        state == `WRITE_SRC1   ||
                        state == `WRITE_SRC0   ||
                        state == `WRITE_COND
                        ) &&
                        disp_online == 1 
//                        && (!ext_next_cpu_e === 1)
                        ? write_q 
                        : 1'bz;



  always @(posedge clk) begin
    addr_r = 32'h zzzzzzzz;
    data_r = 32'h zzzzzzzz;
    next_state = 1'b z;
    ext_rst_e = 0;
  
    //read_dn_r = 1'b z;
    
    bus_busy_r = 1'b z;
    
    cpu_index_itf = 32'h zzzzzzzz;
    
    
    halt_q_r = 1'bz;
    
    cpu_msg_r = 8'hzz;

  

    if(ext_rst_b == 1) begin  // begin of RESET
      rst_state = 0;
      cpu_ind_rel = 0;
      cpu_msg_tmp = 0;
      
      base_addr_r = 0;
      
    end else if(rst_state < 5) begin // == 1) begin
      ext_next_cpu_e_r = 1'b z;
      rst = 0;

      if(ext_next_cpu_q === 1 && ext_cpu_index === cpu_index_r) begin
        ext_next_cpu_e_r = 1;
      end 

      
      case(rst_state)
        0: begin
          ext_dispatcher_q = 1'b z;
          
          disp_online = 0;
          
          rst_state = 1;
        end
        
        1: begin
          if(state == `FINISH_END) begin
            rst_state = 3;
          end else begin
            rst_state = 2;
          end
        end
        
        2: begin
          cpu_index_r = ext_cpu_index; //data;
          //read_dn_r = 1;
          cpu_msg_r = `CPU_R_RESET;
          
          rst_state = 3;
        end
        
        3: begin
          //read_dn_r = 1'b z;
          
          rst = 1;

          bus_busy_r = 1'b 1;
          
          if(state == `FINISH_END) begin
          end else begin
            ext_rst_e = 1;
          end
          
          rst_state = 4;
        end
        
        4: begin
          ext_dispatcher_q = 1;
          
          rst_state = 5;
        end
        
      endcase

    end else begin      // end of RESET
    
    
//      if(read_q == 1 || write_q == 1) begin
//        halt_q_r = 1;
//      end else begin
//        halt_q_r = 1'bz;
//      end



//        cpu_ind_rel = 0;

//      if(rw_halt == 1) begin
//        $monitor("cpu_index_r = %b, ext_cpu_index = %b", cpu_index_r, ext_cpu_index);
//        if(cpu_index_r != ext_cpu_index) begin
//          ext_rw_halt = 1;
//        end else begin
//          ext_rw_halt = 1'bz;
//        end
//      end 
//      else begin
//        ext_rw_halt = 1'bz;
//      end



//        if(ext_next_cpu_q == 1 && 
//           ext_cpu_index == cpu_index_r
//        ) begin
      

        if(ext_next_cpu_q === 1) begin
        
          if(ext_cpu_index < cpu_index_r) begin
            cpu_ind_rel = 2'b01;
          end else
          if(ext_cpu_index > cpu_index_r) begin
            cpu_ind_rel = 2'b10;
          end else
          if(ext_cpu_index == cpu_index_r) begin
            cpu_ind_rel = 2'b11;
//          end else begin
//            cpu_ind_rel = 0;
          end


/*
//      if(ext_next_cpu_q == 1) begin 
          if(ext_cpu_index == cpu_index_r) begin
//          ext_next_cpu_e_r = 1;
          end else if(ext_cpu_index == `CPU_NONACTIVE) begin
        
            if((cpu_index_r & `CPU_ACTIVE) == `CPU_ACTIVE) begin
              cpu_index_r = cpu_index_r + 1;
            end else begin
              cpu_index_r = cpu_index_r - 1;
            end
          end  
//      end
*/
          
        end else if(ext_next_cpu_e === 1) begin
          cpu_ind_rel = 0;
        end


      
      if(bus_busy !== 1) begin
//      end else begin

        if(disp_online == 1) begin
        
        
          if(
            read_q == 1 ||
            write_q == 1
          ) begin
            ext_next_cpu_e_r = 1;
//            disp_online = 0;
          end 
          else if(ext_next_cpu_e_r === 1) begin
            ext_next_cpu_e_r = 1'bz;
            disp_online = 0;
          end
        end
        else if(ext_next_cpu_e_r === 1'b 1) begin
          ext_next_cpu_e_r = 1'b z;
        end
      
        if(ext_next_cpu_q === 1 && 
           ext_cpu_index === cpu_index_r
        ) begin
          disp_online = 1;
          
          base_addr_r = addr + 1;
          
          case(state)
            `WAIT_FOR_START: begin
              //data_r
              cpu_msg_r = `CPU_R_START;
//              cpu_index_r = `CPU_ACTIVE;
              cpu_index_itf = cpu_index_r;
//              base_addr_r = addr + 1;
              ext_dispatcher_q = 1'b z;
//              disp_online = 1;
              
//              cpu_index_r = cpu_index_r | `CPU_ACTIVE;
              
//              ext_next_cpu_e_r = 1;
              
              next_state = 1;
              ext_next_cpu_e_r = 1;
            end
            
            `READ_COND, 
            `READ_COND_P,
            `READ_SRC1,
            `READ_SRC1_P,
            `READ_SRC0,
            `READ_SRC0_P,
            `START_READ_CMD,
            `START_READ_CMD_P: begin
                ext_dispatcher_q = 1;
            end
            
            `WRITE_REG_IP,
            `WRITE_DST,
            `WRITE_SRC1,
            `WRITE_SRC0,
            `WRITE_COND: begin
              ext_dispatcher_q = 1;
            end
            
            /**
            `ALU_BEGIN: begin
              if(
                ext_cpu_msg === `CPU_R_FORK_DID
              ) begin
                cpu_msg_r = int_cpu_msg;
                cpu_index_itf = cpu_index_r;
                
//                next_state = 1;
                ext_next_cpu_e_r = 1;
              end
            end
            **/
            
            `FINISH_BEGIN: begin
              //data_r
              cpu_msg_r = `CPU_R_END;
              cpu_index_itf = cpu_index_r;
//              cpu_index_r = `CPU_NONACTIVE;
//              rst_state = 0; // = 1;
              ext_next_cpu_e_r = 1;
              next_state = 1;
            end
            
            default: begin
              if(read_q == 1) begin
//                ext_read_q = 1;
              end else begin
//                data_r = `CPU_R_VOID;
              end
            end

          endcase
          
        end else
        begin
          case(state)
            `START_BEGIN: begin
//              cpu_index_r = cpu_index_r | `CPU_ACTIVE;
            
              data_r = base_addr_r - 1;
              //read_dn_r = 1;
            end
            
            `READ_COND, 
            `READ_COND_P,
            `READ_SRC1,
            `READ_SRC1_P,
            `READ_SRC0,
            `READ_SRC0_P,
            `START_READ_CMD,
            `START_READ_CMD_P: begin
              ext_dispatcher_q = 1;
            end
            
            /**/
            `ALU_BEGIN: begin
              if(
                ext_cpu_msg === `CPU_R_FORK_DONE
//                && ext_next_cpu_e_r !== 1
              ) begin
//                cpu_msg_r = int_cpu_msg;
//                cpu_index_itf = cpu_index_r;
                
//                next_state = 1;
                ext_next_cpu_e_r = 1;
              end

            end
            /**/
            
            `WRITE_REG_IP,
            `WRITE_DST,
            `WRITE_SRC1,
            `WRITE_SRC0,
            `WRITE_COND: begin
              ext_dispatcher_q = 1;
            end
            
            `FINISH_END: begin
              rst_state = 0; // = 1;
              cpu_index_r = `CPU_NONACTIVE;
            end
            
            default: begin
              cpu_index_itf = 32'h zzzzzzzz;
              ext_dispatcher_q = 1'b z;
            end
            
          endcase
          
        end
      end
    end
    
/*
    if(ext_next_cpu_q == 1) begin 
      if(ext_cpu_index == cpu_index_r) begin
//          ext_next_cpu_e_r = 1;
      end else if(ext_cpu_index == `CPU_NONACTIVE) begin
      
        if((cpu_index_r & `CPU_ACTIVE) == `CPU_ACTIVE) begin
          cpu_index_r = cpu_index_r + 1;
        end else begin
          cpu_index_r = cpu_index_r - 1;
        end
      end
    end
*/
    
    if(ext_next_cpu_e === 1) begin 
      if(ext_cpu_index == cpu_index_r) begin
        if(
            cpu_index_r == 0 && 
            state == `START_BEGIN &&
            //data
            ext_cpu_msg === `CPU_R_START
        ) begin
          cpu_index_r = `CPU_ACTIVE;
        end
      end else begin
        if((ext_cpu_index & `CPU_ACTIVE) == `CPU_ACTIVE) begin
          if((cpu_index_r & `CPU_ACTIVE) == `CPU_ACTIVE) begin
            if(ext_cpu_index < cpu_index_r) begin
              case(ext_cpu_msg) //data)
                `CPU_R_END: begin
                  cpu_index_r = cpu_index_r - 1;
                end
            
                `CPU_R_START: begin
//                  cpu_index_r = cpu_index_r + 1;
                end
            
              endcase
            end
          end
        end
 
        else if((ext_cpu_index & `CPU_ACTIVE) == `CPU_NONACTIVE) begin
          case(ext_cpu_msg) //data)
            `CPU_R_END: begin
//              cpu_index_r = cpu_index_r + 1;
            end
          
            `CPU_R_START: begin
              if((cpu_index_r & `CPU_ACTIVE) == `CPU_ACTIVE) begin
                cpu_index_r = cpu_index_r + 1;
              end else begin
                cpu_index_r = cpu_index_r - 1;
              end
            end
            
          endcase
        end

      end
    end
   

  end

endmodule

