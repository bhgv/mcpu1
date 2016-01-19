

`include "sizes.v"
`include "states.v"
`include "cmd_codes.v"



module InternalBus(
        clk,
        //    state,
        bus_busy,
        
//        command,
        
        state,
        
        halt_q,
        rw_halt,
        cpu_ind_rel,
        
        want_write,
        
            addr,
            data,
            
            read_q,
            write_q,
            read_dn,
            write_dn,
//            read_e,
//            write_e,
            
//        src1,
//        src0,
//        dst,
        //dst_h,
        
        cpu_msg,
        
        disp_online,
        
        next_state,
        
        rst
        );
        
  input wire clk;
  inout bus_busy;
  reg bus_busy_r;
  tri bus_busy = bus_busy_r;
  
  //output 
  tri0 [31:0] command;
    
  input wire rst;
  
  inout tri halt_q;
  inout tri rw_halt;
  input tri [1:0] cpu_ind_rel;
  
  inout tri want_write;
  

//  reg [`ADDR_SIZE0:0] addr_out_r;
  inout tri [`ADDR_SIZE0:0] addr; //= addr_out_r;
  
  output tri read_q;
  output tri write_q;
  input tri read_dn;
  input tri write_dn;
//  output wire read_e;
//  output wire write_e;
  
  
//  reg [`DATA_SIZE0:0] data_r;
  inout tri [`DATA_SIZE0:0] data; // = data_r;
  

  //inout 
  tri [`DATA_SIZE0:0] src1;
  //inout 
  tri [`DATA_SIZE0:0] src0;
  //inout 
  tri [`DATA_SIZE0:0] dst;
  //output 
  wire [`DATA_SIZE0:0] dst_h;
  /*output*/ wire [`DATA_SIZE0:0] cond;
  
  wire [`DATA_SIZE0:0] cmd_ptr;
  
  output wire [`STATE_SIZE0:0] state;
  inout next_state;
  tri0 next_state;
 
                    
  wire [`ADDR_SIZE0:0] base_addr;
  
  
  input wire disp_online;
  
  
  output tri [7:0] cpu_msg;
  
  
//	reg [31:0] mem [0:100]; 
//  initial $readmemh("mem.txt", mem);
  

//parameter STEP = 20;


/**/
  StartManager start_mng(
            .clk(clk), 
            .state(state),
            
            .base_addr(base_addr),
            .command(command),
            
            .cpu_ind_rel(cpu_ind_rel),
            .halt_q(halt_q),
            .rw_halt(rw_halt),
            
            .is_bus_busy(bus_busy),
            .addr(addr),
            .read_q(read_q),
            .write_q(write_q),
            .data(data),
            .read_dn(read_dn),
            .write_dn(write_dn),
//            .read_e(read_e),
//            .write_e(write_e),

            .cmd_ptr(cmd_ptr),
            
            .disp_online(disp_online),
            
            .next_state(next_state),
            
            .rst(rst)
            );
/**/

  FinishManager finish_mng(
            .clk(clk), 
            .state(state),
            
            .base_addr(base_addr),
            .command(command),
            
            .is_bus_busy(bus_busy),
            .addr(addr),
            .data(data),
            
            .next_state(next_state),
            
            .rst(rst)
            );


  StateManager states_mng(
            .clk(clk),
            .state(state),

            .command(command),
            
            .cond(cond),
            
            .next_state(next_state),
            
            .isIpSaveAllowed(isIpSaveAllowed),
            .isDSaveAllowed(isDSaveAllowed),
            .isDSavePtrAllowed(isDSavePtrAllowed),
            .isCndSaveAllowed(isCndSaveAllowed),
            .isCndSavePtrAllowed(isCndSavePtrAllowed),
            .isS1SaveAllowed(isS1SaveAllowed),
            .isS1SavePtrAllowed(isS1SavePtrAllowed),
            .isS0SaveAllowed(isS0SaveAllowed),
            .isS0SavePtrAllowed(isS0SavePtrAllowed),

            .rst(rst)
            );
            

/**/
  MemManager mem_mng (
            .clk(clk), 
            .state(state),
            .base_addr(base_addr),
            .command_word(command),
            
            .cpu_ind_rel(cpu_ind_rel),
            .halt_q(halt_q),
            .rw_halt(rw_halt),
            
            .want_write(want_write),
            
            .is_bus_busy(bus_busy),
            .addr(addr),
            .read_q(read_q),
            .write_q(write_q),
            .data(data),
            .read_dn(read_dn),
            .write_dn(write_dn),
//            .read_e(read_e),
//            .write_e(write_e),
            
            .src1(src1),
            .src0(src0),
            .dst(dst),
            .dst_h(dst_h),
            .cond(cond),
            
            .cmd_ptr(cmd_ptr),
            
            .disp_online(disp_online),
            
            .next_state(next_state),
            
            .isIpSaveAllowed(isIpSaveAllowed),
            .isDSaveAllowed(isDSaveAllowed),
            .isDSavePtrAllowed(isDSavePtrAllowed),
            .isCndSaveAllowed(isCndSaveAllowed),
            .isCndSavePtrAllowed(isCndSavePtrAllowed),
            .isS1SaveAllowed(isS1SaveAllowed),
            .isS1SavePtrAllowed(isS1SavePtrAllowed),
            .isS0SaveAllowed(isS0SaveAllowed),
            .isS0SavePtrAllowed(isS0SavePtrAllowed),
            
            .rst(rst)
            );
/**/

/**/
  Alu alu_1 (
        .clk(clk),
        .is_bus_busy(bus_busy),
        
        .command(command),
        
        .state(state),
        
        .src1(src1),
        .src0(src0),
        .dst(dst),
        .dst_h(dst_h),
        
        .next_state(next_state),
        
        .rst(rst)
        );
/**/

/**/
  ThreadCtlr thrd_1 (
        .clk(clk),
        .is_bus_busy(bus_busy),
        
        .command(command),
        
        .state(state),
        
        .src1(src1),
        .src0(src0),
        .dst(dst),
        .dst_h(dst_h),
        
        .cpu_msg(cpu_msg),
        
        .next_state(next_state),
        
        .rst(rst)
        );
/**/



  always @(posedge clk) begin
    
      bus_busy_r = 1'b z;

    if(rst == 1) begin
//      bus_busy_r = 1'b z;
    end //else begin

/*
      case(state)
        `START_BEGIN: begin
          data_tri_r = 0; //Q;
          read_dn = 1;
        end
        
      endcase
*/

  end
  
  
endmodule








