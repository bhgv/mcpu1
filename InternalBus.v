

`include "sizes.v"
`include "states.v"
`include "cmd_codes.v"



module InternalBus(
        clk,
		  clk_oe,
		  
        //    state,
        bus_busy,
        
        base_addr,
        base_addr_data,
        
        command,
        
        state,
        
        halt_q,
        rw_halt,
        cpu_ind_rel,
        
//        want_write_in,
//		  want_write_out,
        
            addr_in,
				addr_out,
            data_in,
            data_out,
            
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
		  
  input wire clk_oe;
        
  input wire clk;
  
  input bus_busy;
//  reg bus_busy_r;
  wire bus_busy; // = bus_busy_r;
  
  output wire [31:0] command;
    
  input wire rst;
  
  inout tri halt_q;
  inout tri rw_halt;
  input tri [1:0] cpu_ind_rel;
  
//  input wire want_write_in;
//  output wire want_write_out;
  

//  reg [`ADDR_SIZE0:0] addr_out_r;
  input wire [`ADDR_SIZE0:0] addr_in; //= addr_out_r;
  
  output [`ADDR_SIZE0:0] addr_out;
  
  wire [`ADDR_SIZE0:0] addr_out_m;
  wire [`ADDR_SIZE0:0] addr_out_t;
  
  wire [`ADDR_SIZE0:0] addr_out = 
                                 addr_out_m[`ADDR_SIZE0:0]
                                 | addr_out_t[`ADDR_SIZE0:0]
                                 ;

		
  output wire read_q;
  output wire write_q;
  input tri read_dn;
  input tri write_dn;
//  output wire read_e;
//  output wire write_e;
  
  
//  reg [`DATA_SIZE0:0] data_r;
  input wire [`DATA_SIZE0:0] data_in; // = data_r;
  output [`DATA_SIZE0:0] data_out; // = data_r;
  wire [`DATA_SIZE0:0] data_out_s; // = data_r;
  wire [`DATA_SIZE0:0] data_out_m; // = data_r;
  wire [`DATA_SIZE0:0] data_out_t; // = data_r;
  wire [`DATA_SIZE0:0] data_out = 
                                 data_out_m
                                 | data_out_t
                                 | data_out_s
                                 ;
  

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
  
  
  input next_state;
  wire next_state;
  
  wire next_state_m, next_state_a, next_state_s, next_state_t;
  
  wire next_state_rslt = 
								next_state
								| next_state_m
								| next_state_a
								| next_state_s
								| next_state_t
								;
 
                    
  input wire [`ADDR_SIZE0:0] base_addr;
  input wire [`ADDR_SIZE0:0] base_addr_data;
  
  
  input wire disp_online;
  
  
  inout tri [`CPU_MSG_SIZE0:0] cpu_msg;
  
  
//	reg [31:0] mem [0:100]; 
//  initial $readmemh("mem.txt", mem);
  

//parameter STEP = 20;

/*
  tri [`DATA_SIZE0:0] data_inout = 
						 disp_online == 1 && (read_q === 1 || write_q === 1) 
						 ? data_out
						 : (bus_busy === 1)
						 ? data_in
						 : `DATA_SIZE'h zzzz_zzzz_zzzz_zzzz
						;
*/

/**/
  StartManager start_mng(
            .clk(clk), 
 				.clk_oe(clk_oe),

				.state(state),
            
            .base_addr(base_addr),
            .command(command),
            
            .cpu_ind_rel(cpu_ind_rel),
            .halt_q(halt_q),
            .rw_halt(rw_halt),
            
            .is_bus_busy(bus_busy),
            .addr_in(addr_in),
//            .addr_out(addr_out),

//            .read_q(read_q),
//            .write_q(write_q),
            .data_in(data_in),
            .data_out(data_out_s),
            .read_dn(read_dn),
            .write_dn(write_dn),
//            .read_e(read_e),
//            .write_e(write_e),

            .cmd_ptr(cmd_ptr),
            
            .disp_online(disp_online),
            
            .next_state(next_state_s),
            
            .rst(rst)
            );
/**/

/**

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
/**/

  StateManager states_mng(
            .clk(clk),
				.clk_oe(clk_oe),

            .state(state),

            .command(command),
            
            .cond(cond),
            
            .next_state(next_state_rslt),
            
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
				.clk_oe(clk_oe),

            .state(state),
            .base_addr(base_addr),
            .base_addr_data(base_addr_data),
            
            .command_word(command),
            
            .cpu_ind_rel(cpu_ind_rel),
            .halt_q(halt_q),
            .rw_halt(rw_halt),
            
//            .want_write_in(want_write_in),
//            .want_write_out(want_write_out),
            
            .is_bus_busy(bus_busy),
            .addr_in(addr_in),
            .addr_out(addr_out_m),
            .read_q(read_q),
            .write_q(write_q),
            .data_in(data_in),
            .data_out(data_out_m),
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
            
            .next_state(next_state_m),
            
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
			.clk_oe(clk_oe),

			.is_bus_busy(bus_busy),
        
        .command(command),
        
        .state(state),
        
        .src1(src1),
        .src0(src0),
        .dst(dst),
        .dst_h(dst_h),
        
        .next_state(next_state_a),
        
        .rst(rst)
        );
/**/

/**/
  ThreadCtlr thrd_1 (
        .clk(clk),
 				.clk_oe(clk_oe),

			.is_bus_busy(bus_busy),
        
        .base_addr(base_addr),
        .base_addr_data(base_addr_data),
        
        .command(command),
        
        .state(state),
        
        .src1(src1),
        .src0(src0),
        .dst(dst),
        .dst_h(dst_h),
        
        .data_in(data_in),
        .data_out(data_out_t),
            .addr_in(addr_in),
            .addr_out(addr_out_t),
        
        .disp_online(disp_online),
        
        .cpu_msg(cpu_msg),
        
        .next_state(next_state_t),
        
        .rst(rst)
        );
/**/



  always @(posedge clk) begin
    
//      bus_busy_r = 1'b z;

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








