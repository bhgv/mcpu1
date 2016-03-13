

`include "sizes.v"
`include "states.v"
`include "misc_codes.v"

`include "cmd_codes.v"


module MemManager (
            clk, 
				clk_oe,
            state,
            
            base_addr,
            base_addr_data,
				
				addr_unmodificable_b,

            command_word,
            
            cpu_ind_rel,
            halt_q_in,
            halt_q_out,
            rw_halt_in,
            rw_halt_out,

            want_write_in,
            want_write_out,
            
            is_bus_busy,
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
            
            src1_in,
            src0_in,
            dst_in,
            dst_h_in,
            cond_in,
            
            src1_out,
            src0_out,
            dst_out,
//            dst_h_out,
            cond_out,
            
            cmd_ptr,
            
            disp_online,
            
            next_state,
				next_state_dn,
            
            isIpSaveAllowed,
            isDSaveAllowed,
            isDSavePtrAllowed,
            isCndSaveAllowed,
            isCndSavePtrAllowed,
            isS1SaveAllowed,
            isS1SavePtrAllowed,
            isS0SaveAllowed,
            isS0SavePtrAllowed,
				
				is_ip_read,
				is_ip_read_ptr,
				is_cnd_read,
				is_cnd_read_ptr,
				is_s1_read,
				is_s1_read_ptr,
				is_s0_read,
				is_s0_read_ptr,
				is_d_read,
            
            rst
            );
				
	input wire clk_oe;
            
  input wire disp_online;
  
  input wire [`DATA_SIZE0:0] cmd_ptr;
  
  input wire next_state_dn;
  
  wire next_state_ip, next_state_s1, next_state_s0, next_state_d, next_state_c, next_state_mem1sz;
  output next_state;
  wire next_state = 
									  next_state_ip 
									| next_state_s1
									| next_state_s0
									| next_state_d
									| next_state_c
									| next_state_mem1sz
									;
  
  input wire rst;

            
  input wire clk;
  input wire [`STATE_SIZE0:0] state;
  
  output wire [31:0] command_word;

  wire [3:0] regNumS1;
  assign regNumS1 = command_word[3:0];

  wire [3:0] regNumS0;
  assign regNumS0 = command_word[7:4];

  wire [3:0] regNumD;
  assign regNumD = command_word[11:8];

  wire [3:0] regNumCnd;
  assign regNumCnd = command_word[15:12];
  
  
  wire isRegS1Ptr;
  assign isRegS1Ptr = command_word[16];
  
  wire isRegS0Ptr;
  assign isRegS0Ptr = command_word[17];
  
  wire isRegDPtr;
  assign isRegDPtr = command_word[18];
  
  wire isRegCondPtr;
  assign isRegCondPtr = command_word[19];
  
  
  wire [1:0] regS1Flags;
  assign regS1Flags = command_word[21:20];
  
  wire [1:0] regS0Flags;
  assign regS0Flags = command_word[23:22];
  
  wire [1:0] regDFlags;
  assign regDFlags = command_word[25:24];
  
  wire [1:0] regCondFlags;
  assign regCondFlags = command_word[27:26];
  
  
  wire [3:0] cmd_code = command_word[31:28];
  
  
//  wire ifPtr;
  
  input wire [`ADDR_SIZE0:0] base_addr;
  input wire [`ADDR_SIZE0:0] base_addr_data;
//  reg [`ADDR_SIZE0:0] base_addr_r;

  
  input wire [`ADDR_SIZE0:0] addr_unmodificable_b;
  

  input wire [1:0] cpu_ind_rel;
  
  wire halt_q_ip, halt_q_s1, halt_q_s0, halt_q_d, halt_q_c, halt_q_mem1sz;
  
  input wire halt_q_in;
  output halt_q_out;
  wire halt_q_out = 
                      halt_q_ip 
							 | halt_q_s1
							 | halt_q_s0
							 | halt_q_d
							 | halt_q_c
							 | halt_q_mem1sz
//							 | halt_q_in
							 ;
//  reg halt_q_r;
//  tri halt_q = halt_q_r;

  wire rw_halt_ip, rw_halt_s1, rw_halt_s0, rw_halt_d, rw_halt_c, rw_halt_mem1sz;
  
  input wire rw_halt_in;
  output rw_halt_out;
  wire rw_halt_out = 
                     rw_halt_ip
							| rw_halt_s1
							| rw_halt_s0
							| rw_halt_d
							| rw_halt_c
//							| rw_halt_mem1sz
							;
//  reg rw_halt_r;
//  tri rw_halt = rw_halt_r;
  
  input [`ADDR_SIZE0:0] addr_in;
  output [`ADDR_SIZE0:0] addr_out;
//  reg [`ADDR_SIZE0:0] addr_r;
  wire [`ADDR_SIZE0:0] addr_in;
//  wire [`ADDR_SIZE0:0] addr_out;
  
  wire [`ADDR_SIZE0:0] addr_out_ip;
  wire [`ADDR_SIZE0:0] addr_out_s1;
  wire [`ADDR_SIZE0:0] addr_out_s0;
  wire [`ADDR_SIZE0:0] addr_out_d;
  wire [`ADDR_SIZE0:0] addr_out_c;
  wire [`ADDR_SIZE0:0] addr_out_mem1sz;
//			[`ADDR_SIZE0:0] addr_out_ip,
			
  wire [`ADDR_SIZE0:0] addr_out =
                 addr_out_ip[`ADDR_SIZE0:0]
					  | addr_out_s1[`ADDR_SIZE0:0]
					  | addr_out_s0[`ADDR_SIZE0:0]
					  | addr_out_d[`ADDR_SIZE0:0]
					  | addr_out_c[`ADDR_SIZE0:0]
					  | addr_out_mem1sz[`ADDR_SIZE0:0]
					  ;
					  
/*
    = (
                        state == `READ_COND ||
                        state == `READ_COND_P ||
                        state == `READ_SRC1 ||
                        state == `READ_SRC1_P ||
                        state == `READ_SRC0 ||
                        state == `READ_SRC0_P ||
                        
                        state == `WRITE_DST    ||
                        state == `WRITE_SRC1   ||
                        state == `WRITE_SRC0   ||
                        state == `WRITE_COND
                        ) &&
                        disp_online == 1 
//                        && (!ext_next_cpu_e == 1)
                        ? addr_r
                        : `ADDR_SIZE'h zzzzzzzz;
*/

  wire read_q_ip, read_q_s1, read_q_s0, read_q_d, read_q_c, read_q_mem1sz;
  wire write_q_ip, write_q_s1, write_q_s0, write_q_d, write_q_c, write_q_mem1sz;

  output read_q;
  wire read_q =
										read_q_ip
										| read_q_s1
										| read_q_s0
										| read_q_d
										| read_q_c
										| read_q_mem1sz
										;
  output write_q;
  wire write_q =
										write_q_ip
										| write_q_s1
										| write_q_s0
										| write_q_d
										| write_q_c
//										| write_q_mem1sz
										;

  input is_bus_busy;
//  reg is_bus_busy_r;
  wire is_bus_busy; // = is_bus_busy_r;
  
  input [`DATA_SIZE0:0] data_in;
  output [`DATA_SIZE0:0] data_out;
  
//  tri [`DATA_SIZE0:0] data_int;
  
//  reg [`DATA_SIZE0:0] data_r;
  wire [`DATA_SIZE0:0] data_in; // = data_r;
  
  wire [`DATA_SIZE0:0] data_out_ip; // = data_r;
  wire [`DATA_SIZE0:0] data_out_s1; // = data_r;
  wire [`DATA_SIZE0:0] data_out_s0; // = data_r;
  wire [`DATA_SIZE0:0] data_out_d; // = data_r;
  wire [`DATA_SIZE0:0] data_out_c; // = data_r;
  wire [`DATA_SIZE0:0] data_out_mem1sz; // = data_r;
  
  wire [`DATA_SIZE0:0] data_out =
                 data_out_ip[`DATA_SIZE0:0]
					  | data_out_s1[`DATA_SIZE0:0]
					  | data_out_s0[`DATA_SIZE0:0]
					  | data_out_d[`DATA_SIZE0:0]
					  | data_out_c[`DATA_SIZE0:0]
//					  | data_out_mem1sz[`DATA_SIZE0:0]
					  ;
//  assign data = write_q === 1 ? data_int : 32'h zzzzzzzz;
  
  input  wire read_dn;
  input  wire write_dn;
//  output reg read_e;
//  output reg write_e;



  wire want_write_out_ip, want_write_out_s1, want_write_out_s0, want_write_out_d, want_write_out_c, want_write_out_mem1sz;
  
  input wire want_write_in;
  output want_write_out;
  
  wire want_write_out = 
                       want_write_out_ip
							  | want_write_out_s1
							  | want_write_out_s0
							  | want_write_out_d
							  | want_write_out_c
//							  | want_write_out_mem1sz
							  ;
  
  
  output wire
            is_ip_read,
				is_ip_read_ptr,
				is_cnd_read,
				is_cnd_read_ptr,
				is_s1_read,
				is_s1_read_ptr,
				is_s0_read,
				is_s0_read_ptr,
				is_d_read
            ;
				
 wire is_mem1sz_read;

  
  
/**  
  inout  [`DATA_SIZE0:0] cond;
  inout  [`DATA_SIZE0:0] src1;
  inout  [`DATA_SIZE0:0] src0;
  inout  [`DATA_SIZE0:0] dst;
/**/

  input wire [`DATA_SIZE0:0] cond_in;
  input wire [`DATA_SIZE0:0] src1_in;
  input wire [`DATA_SIZE0:0] src0_in;
  input  [`DATA_SIZE0:0] dst_in;

  output  [`DATA_SIZE0:0] cond_out;
  output  [`DATA_SIZE0:0] src1_out;
  output  [`DATA_SIZE0:0] src0_out;
  output  [`DATA_SIZE0:0] dst_out;
  
  wire  [`DATA_SIZE0:0] cond_out;
//  wire  [`DATA_SIZE0:0] src1_out;
//  wire  [`DATA_SIZE0:0] src0_out;
//  wire  [`DATA_SIZE0:0] dst_out;



  wire [`DATA_SIZE0:0] cond_ptr_in;
  wire [`DATA_SIZE0:0] cond_ptr_out;
  
  
  wire [`DATA_SIZE0:0] mem1sz;


  reg [`SIZE_REG_OP-1:0] cmd_op;
  /**
  wire [`SIZE_REG_OP-1:0] cmd_op = (state == `START_READ_CMD)
                                    ? `REG_OP_READ
                                    : (state == `START_READ_CMD_P)
                                    ? `REG_OP_READ_P
                                    
//                                    : (state == `WRITE_PREP)
//                                    ? `REG_OP_WRITE_PREP
                                    
                                    : (state == `WRITE_REG_IP)
                                    ? `REG_OP_WRITE
                                    
                                    : (
                                        state == `PREEXECUTE ||
                                        state == `START_BEGIN
                                      )
                                    ? `REG_OP_PREEXECUTE
                                    : `REG_OP_NULL
                                  ;
  /**/
                                  
  wire [`DATA_SIZE0:0] ip_ptr_in;
  wire [`DATA_SIZE0:0] ip_ptr_out;
  
  input wire isIpSaveAllowed;
  
  RegisterManager cmd_dev (
            .clk(clk), 
				.clk_oe(clk_oe),
            .state(state),
            
            .base_addr(base_addr), //(state == `START_READ_CMD_P) ? base_addr : base_addr_data),
            .base_addr_data(base_addr_data), //(state == `START_READ_CMD_P) ? base_addr : base_addr_data),
				
				.addr_unmodificable_b(addr_unmodificable_b),
				
				.mem1sz(mem1sz),
				
            .reg_op(cmd_op),
            
            .cpu_ind_rel(cpu_ind_rel),
				
            .halt_q_in(halt_q_in),
            .halt_q_out(halt_q_ip),
            .rw_halt_in(rw_halt_in),
            .rw_halt_out(rw_halt_ip),
            
            .want_write_in(want_write_in),
            .want_write_out(want_write_out_ip),
            
            .is_bus_busy(is_bus_busy),
            .addr_in(addr_in),
            .addr_out(addr_out_ip),
            .data_in(data_in),
            .data_out(data_out_ip),
            
            .register_out(command_word),
            .reg_ptr_in(ip_ptr_in),
            .reg_ptr_out(ip_ptr_out),
            
            .isRegPtr(1),      //ip is ptr of cmd
            .regFlags(2'b 01), //post-increment
            .regNum(`REG_IP), //0xf is the number of ip reg
            
            .isNeedSave(1'b 1),
            .isDinamic(1'b 0),
            .isSaveAllowed(isIpSaveAllowed),
            .isSavePtrAllowed(1'b 0),
            
            .read_q(read_q_ip),
            .write_q(write_q_ip),
            .read_dn(read_dn),
            .write_dn(write_dn),
				
				.is_read(is_ip_read),
				.is_read_ptr(is_ip_read_ptr),
            
            .cmd_ptr(cmd_ptr),
            
            .disp_online(disp_online),
            
            .next_state(next_state_ip),
            
            .rst(rst)
            );





//  reg [`DATA_SIZE0:0] src1_r_adr;
//  reg [`DATA_SIZE0:0] src1_r;
//  wire [`DATA_SIZE0:0] src1 = src1_r;
//  reg src1_waiting;
//  reg src1ptr_waiting;
//  reg src1w_waiting;
  
  reg [`SIZE_REG_OP-1:0] src1_op;
  /**
  wire [`SIZE_REG_OP-1:0] src1_op = (state == `FILL_SRC1)
                                    ? `REG_OP_CATCH_DATA
                                    : (state == `READ_SRC1)
                                    ? `REG_OP_READ
                                    : (state == `READ_SRC1_P)
                                    ? `REG_OP_READ_P
                                    : (state == `WRITE_PREP)
                                    ? `REG_OP_WRITE_PREP
                                    : (state == `WRITE_SRC1)
                                    ? `REG_OP_WRITE
                                    : (state == `PREEXECUTE)
                                    ? `REG_OP_PREEXECUTE
//                                    : (state == `ALU_BEGIN && cmd_code == `CMD_FORK)
//                                    ? `REG_OP_OUT_TO_DATA
                                    : `REG_OP_NULL
                                  ;
  /**/
  
  wire [`DATA_SIZE0:0] src1_ptr_out;
  wire [`DATA_SIZE0:0] src1_ptr_in = (src1_op == `REG_OP_CATCH_DATA) 
                                              ? ( regNumS1 == `REG_IP 
                                                            ? ip_ptr_out 
                                                            : ( regNumS1 == regNumCnd
                                                                          ? cond_ptr_out
                                                                          : 0 //`ADDR_SIZE'h zzzzzzzz 
                                                              )
                                                )
                                              : 0 //`ADDR_SIZE'h zzzzzzzz
                                              ;
                                              
  wire [`DATA_SIZE0:0] src1_out;
  wire [`DATA_SIZE0:0] int_src1_in = (state == `FILL_SRC1) 
                                  ? (regNumS1 == regNumCnd
                                       ? cond_out
                                       : src1_in //0 //`ADDR_SIZE'h zzzzzzzz
                                    )
                                  : src1_in //0 //`ADDR_SIZE'h zzzzzzzz
                                  ;
  
  input wire isS1SaveAllowed;
  input wire isS1SavePtrAllowed;
  
  RegisterManager src1_dev (
            .clk(clk), 
				.clk_oe(clk_oe),
            .state(state),
            
            .base_addr(base_addr), //(regNumS1 == `REG_IP && state == `READ_SRC1_P) ? base_addr : base_addr_data),
				.base_addr_data(base_addr_data),
				
				.addr_unmodificable_b(addr_unmodificable_b),
				
				.mem1sz(mem1sz),
				
            .reg_op(src1_op),
            
            .cpu_ind_rel(cpu_ind_rel),
				
            .halt_q_in(halt_q_in),
            .halt_q_out(halt_q_s1),
            .rw_halt_in(rw_halt_in),
            .rw_halt_out(rw_halt_s1),
            
            .want_write_in(want_write_in),
            .want_write_out(want_write_out_s1),
            
            .is_bus_busy(is_bus_busy),
            .addr_in(addr_in),
            .addr_out(addr_out_s1),
            .data_in(data_in),
            .data_out(data_out_s1),
            
            .register_in(int_src1_in),
            .register_out(src1_out),
            .reg_ptr_in(src1_ptr_in),
            .reg_ptr_out(src1_ptr_out),
            
            .isRegPtr(isRegS1Ptr),
            .regFlags(regS1Flags),
            .regNum(regNumS1),
            
            .isNeedSave(1'b 0),
            .isDinamic(1'b 0),
            .isSaveAllowed(isS1SaveAllowed),
            .isSavePtrAllowed(isS1SavePtrAllowed),
            
            .read_q(read_q_s1),
            .write_q(write_q_s1),
            .read_dn(read_dn),
            .write_dn(write_dn),
				
				.is_read(is_s1_read),
				.is_read_ptr(is_s1_read_ptr),
            
            .cmd_ptr(cmd_ptr),
            
            .disp_online(disp_online),
            
            .next_state(next_state_s1),
            
            .rst(rst)
            );


//  reg [`DATA_SIZE0:0] src0_r_adr;
//  reg [`DATA_SIZE0:0] src0_r;
//  wire [`DATA_SIZE0:0] src0 = src0_r;
//  reg src0_waiting;
//  reg src0ptr_waiting;
//  reg src0w_waiting;
  
  reg [`SIZE_REG_OP-1:0] src0_op;
  /**
  wire [`SIZE_REG_OP-1:0] src0_op = (state == `FILL_SRC0)
                                    ? `REG_OP_CATCH_DATA
                                    : (state == `READ_SRC0)
                                    ? `REG_OP_READ
                                    : (state == `READ_SRC0_P)
                                    ? `REG_OP_READ_P
                                    : (state == `WRITE_PREP)
                                    ? `REG_OP_WRITE_PREP
                                    : (state == `WRITE_SRC0)
                                    ? `REG_OP_WRITE
                                    : (state == `PREEXECUTE)
                                    ? `REG_OP_PREEXECUTE
                                    : `REG_OP_NULL
                                  ;
  /**/
  
  wire [`DATA_SIZE0:0] src0_ptr_out;
  wire [`DATA_SIZE0:0] src0_ptr_in = (src0_op == `REG_OP_CATCH_DATA) 
                                              ? ( regNumS0 == `REG_IP 
                                                            ? ip_ptr_out
                                                            : ( regNumS0 == regNumCnd
                                                                          ? cond_ptr_out
                                                                          : (regNumS0 == regNumS1 
                                                                                       ? src1_ptr_out
                                                                                       : 0 //`ADDR_SIZE'h zzzzzzzz 
                                                                            )
                                                              )
                                                )
                                              : 0 //`ADDR_SIZE'h zzzzzzzz
                                              ;

  wire [`DATA_SIZE0:0] src0_out;
  wire [`DATA_SIZE0:0] int_src0_in =  (src0_op == `REG_OP_CATCH_DATA) 
                                   ? (regNumS0 == regNumCnd
                                         ? cond_out
                                         : (regNumS0 == regNumS1)
                                                   ? src1_out 
                                                   : src0_in //0 //`ADDR_SIZE'h zzzzzzzz
                                     )
                                   : src0_in //0 //`ADDR_SIZE'h zzzzzzzz
                              ;
 
  input wire isS0SaveAllowed;
  input wire isS0SavePtrAllowed;
  
  RegisterManager src0_dev (
            .clk(clk), 
				.clk_oe(clk_oe),
            .state(state),
            
            .base_addr(base_addr), //(regNumS0 == `REG_IP && state == `READ_SRC0_P) ? base_addr : base_addr_data),
				.base_addr_data(base_addr_data),
				
				.addr_unmodificable_b(addr_unmodificable_b),
				
				.mem1sz(mem1sz),
				
            .reg_op(src0_op),
            
            .cpu_ind_rel(cpu_ind_rel),
				
            .halt_q_in(halt_q_in),
            .halt_q_out(halt_q_s0),
            .rw_halt_in(rw_halt_in),
            .rw_halt_out(rw_halt_s0),
            
            .want_write_in(want_write_in),
            .want_write_out(want_write_out_s0),
            
            .is_bus_busy(is_bus_busy),
            .addr_in(addr_in),
            .addr_out(addr_out_s0),
            .data_in(data_in),
            .data_out(data_out_s0),
            
            .register_in(int_src0_in),
            .register_out(src0_out),
            .reg_ptr_in(src0_ptr_in),
            .reg_ptr_out(src0_ptr_out),
            
            .isRegPtr(isRegS0Ptr),
            .regFlags(regS0Flags),
            .regNum(regNumS0),
            
            .isNeedSave(1'b 0),  //cmd_code == `CMD_MOV),
            .isDinamic(1'b 0),
            .isSaveAllowed(isS0SaveAllowed),
            .isSavePtrAllowed(isS0SavePtrAllowed),
            
            .read_q(read_q_s0),
            .write_q(write_q_s0),
            .read_dn(read_dn),
            .write_dn(write_dn),
				
				.is_read(is_s0_read),
				.is_read_ptr(is_s0_read_ptr),
            
            .cmd_ptr(cmd_ptr),
            
            .disp_online(disp_online),
            
            .next_state(next_state_s0),
            
            .rst(rst)
            );


//  reg [`DATA_SIZE0:0] dst_r_adr;
//  reg [`DATA_SIZE0:0] dst_r;
//  wire [`DATA_SIZE0:0] dst = dst_r;
//  reg dst_waiting;
//  reg dstptr_waiting;
//  reg dstw_waiting;
  
  reg [`SIZE_REG_OP-1:0] dst_op;
  /**
  wire [`SIZE_REG_OP-1:0] dst_op = (state == `ALU_RESULTS)
                                    ? `REG_OP_CATCH_DATA
                                    :(state == `FILL_DST_P)
                                    ? `REG_OP_CATCH_DATA
                                    : (state == `READ_DST)
                                    ? `REG_OP_READ
//                                    : (state == `READ_DST_P)
//                                    ? `REG_OP_READ_P
                                    :(state == `WRITE_PREP)
                                    ? `REG_OP_WRITE_PREP
                                    : (state == `WRITE_DST)
                                    ? `REG_OP_WRITE
                                    : (state == `WRITE_DST_P)
                                    ? `REG_OP_WRITE_P
                                    : (state == `PREEXECUTE)
                                    ? `REG_OP_PREEXECUTE
                                    : `REG_OP_NULL
                                  ;
  /**/
  
  wire [`DATA_SIZE0:0] dst_ptr_out;
  wire [`DATA_SIZE0:0] dst_ptr_in = (dst_op == `REG_OP_CATCH_DATA) 
                                              ? ( regNumD == `REG_IP 
                                                            ? ip_ptr_out 
                                                            : (regNumD == regNumCnd
                                                                        ? cond_ptr_out
                                                                        : (regNumD == regNumS1 
                                                                                    ? src1_ptr_out
                                                                                    : (regNumD == regNumS0 
                                                                                                ? src0_ptr_out
                                                                                                : 0 //`ADDR_SIZE'h zzzzzzzz 
                                                                                      )
                                                                          )
                                                              )
                                                )
                                              : 0 //`ADDR_SIZE'h zzzzzzzz
                                              ;
                                              
  wire [`DATA_SIZE0:0] dst_in;
  wire [`DATA_SIZE0:0] dst_out;
  
  input wire isDSaveAllowed;
  input wire isDSavePtrAllowed;
  
  RegisterManager dst_dev (
            .clk(clk), 
				.clk_oe(clk_oe),
            .state(state),
            
            .base_addr(base_addr),
/**
				(
//                      (regNumD == `REG_IP && state == `READ_DST) 
//                              ? base_addr 
//                              : 
                              base_addr_data
                      ),
/**/
            .base_addr_data(base_addr_data),
				
				.addr_unmodificable_b(addr_unmodificable_b),
				
				.mem1sz(mem1sz),
				
            .reg_op(dst_op),
            
            .cpu_ind_rel(cpu_ind_rel),
				
            .halt_q_in(halt_q_in),
            .halt_q_out(halt_q_d),
            .rw_halt_in(rw_halt_in),
            .rw_halt_out(rw_halt_d),
            
            .want_write_in(want_write_in),
            .want_write_out(want_write_out_d),
            
            .is_bus_busy(is_bus_busy),
            .addr_in(addr_in),
            .addr_out(addr_out_d),
            .data_in(data_in),
            .data_out(data_out_d),
            
            .register_in(dst_in),
            .register_out(dst_out),
            .reg_ptr_in(dst_ptr_in),
            .reg_ptr_out(dst_ptr_out),
            
            .isRegPtr(isRegDPtr),
            .regFlags(regDFlags),
            .regNum(regNumD),
            
            .isNeedSave(1),
            .isDinamic(1'b 0),
            .isSaveAllowed(isDSaveAllowed),
            .isSavePtrAllowed(isDSavePtrAllowed),
            
            .read_q(read_q_d),
            .write_q(write_q_d),
            .read_dn(read_dn),
            .write_dn(write_dn),
				
				.is_read(is_d_read),
//				.is_read_ptr(1'b z), //is_d_read_ptr),
            
            .cmd_ptr(cmd_ptr),
            
            .disp_online(disp_online),
            
            .next_state(next_state_d),
            
            .rst(rst)
            );
  
  
  input wire [`DATA_SIZE0:0] dst_h_in;
  reg [`DATA_SIZE0:0] dst_h_r;



//  inout tri [`DATA_SIZE0:0] cond;
//  reg [`DATA_SIZE0:0] cond_r_adr;
//  reg [`DATA_SIZE0:0] cond_r;
//  wire [`DATA_SIZE0:0] cond = cond_r;
//  reg cond_waiting;
//  reg condptr_waiting;
//  reg condw_waiting;
  
  reg [`SIZE_REG_OP-1:0] cond_op;
  /**
  wire [`SIZE_REG_OP-1:0] cond_op = (state == `FILL_COND)
                                    ? `REG_OP_CATCH_DATA
                                    : (state == `READ_COND)
                                    ? `REG_OP_READ
                                    : (state == `READ_COND_P)
                                    ? `REG_OP_READ_P
                                    : (state == `WRITE_PREP)
                                    ? `REG_OP_WRITE_PREP
                                    : (state == `WRITE_COND)
                                    ? `REG_OP_WRITE
                                    : (state == `PREEXECUTE)
                                    ? `REG_OP_PREEXECUTE
                                    : `REG_OP_NULL
                                  ;
  /**/
  
  assign cond_ptr_in = (cond_op == `REG_OP_CATCH_DATA) 
                                              ? ( regNumCnd == `REG_IP ? ip_ptr_out : 0 /*`ADDR_SIZE'h zzzzzzzz*/ )
                                              : 0 //`ADDR_SIZE'h zzzzzzzz
                                              ;
                                              
//  wire [`DATA_SIZE0:0] cond;
  
  input wire isCndSaveAllowed;
  input wire isCndSavePtrAllowed;
  
  RegisterManager cond_dev (
            .clk(clk), 
				.clk_oe(clk_oe),
            .state(state),
            
            .base_addr(base_addr), //(regNumCnd == `REG_IP && state == `READ_COND_P) ? base_addr : base_addr_data),
				.base_addr_data(base_addr_data),
				
				.addr_unmodificable_b(addr_unmodificable_b),
				
				.mem1sz(mem1sz),
				
            .reg_op(cond_op),
            
            .cpu_ind_rel(cpu_ind_rel),
				
            .halt_q_in(halt_q_in),
            .halt_q_out(halt_q_c),
            .rw_halt_in(rw_halt_in),
            .rw_halt_out(rw_halt_c),
            
            .want_write_in(want_write_in),
            .want_write_out(want_write_out_c),
            
            .is_bus_busy(is_bus_busy),
            .addr_in(addr_in),
            .addr_out(addr_out_c),
            .data_in(data_in),
            .data_out(data_out_c),
            
            .register_in(cond_in),
            .register_out(cond_out),
            .reg_ptr_in(cond_ptr_in),
            .reg_ptr_out(cond_ptr_out),
            
            .isRegPtr(isRegCondPtr),
            .regFlags(regCondFlags),
            .regNum(regNumCnd),
            
            .isNeedSave(1'b 0),
            .isDinamic(1'b 1),
            .isSaveAllowed(isCndSaveAllowed),
            .isSavePtrAllowed(isCndSavePtrAllowed),
            
            .read_q(read_q_c),
            .write_q(write_q_c),
            .read_dn(read_dn),
            .write_dn(write_dn),
				
				.is_read(is_cnd_read),
				.is_read_ptr(is_cnd_read_ptr),
            
            .cmd_ptr(cmd_ptr),
            
            .disp_online(disp_online),
            
            .next_state(next_state_c),
            
            .rst(rst)
            );
  
  
/*
  assign isIpSaveAllowed = ~(
            (&regDFlags == 0 && regNumD == `REG_IP) ||
            (^regCondFlags && regNumCnd == `REG_IP) ||
            (^regS1Flags && regNumS1 == `REG_IP) ||
            (^regS0Flags && regNumS0 == `REG_IP)
          )
          ;
  
  assign isDSaveAllowed = (
            (regNumCnd != regNumD || ^regCondFlags == 0) &&
            (regNumS1  != regNumD || ^regS1Flags == 0) &&
            (regNumS0  != regNumD || ^regS0Flags == 0)
          )
          ;
  assign isDSavePtrAllowed = (
            (regNumCnd != regNumD || ^regCondFlags == 0) &&
            (regNumS1  != regNumD || ^regS1Flags == 0) &&
            (regNumS0  != regNumD || ^regS0Flags == 0) &&
            isRegDPtr == 1'b 1
          )
          ;
  
  assign isCndSaveAllowed = (
            ^regCondFlags == 1 && 
            (regNumS1  != regNumCnd || ^regS1Flags == 0) &&
            (regNumS0  != regNumCnd || ^regS0Flags == 0)
          )
          ;
  assign isCndSavePtrAllowed = 0 ;
  
  assign isS1SaveAllowed = (
            ^regS1Flags == 1 && 
            (regNumS0  != regNumS1 || ^regS0Flags == 0)
          )
          ;
  assign isS1SavePtrAllowed = 0 ;
  
  assign isS0SaveAllowed = (
            ^regS0Flags == 1
          )
          ;
  assign isS0SavePtrAllowed = 0 ;
*/

  
//  input wire [`DATA_SIZE0:0] cmd_ptr;
  
  
//  input wire disp_online;
  
//  output reg next_state;
  
//  input wire rst;
  
//  reg single;
  

  
  
  
  
    
  reg [`SIZE_REG_OP-1:0] mem1sz_op;
  
  RegisterManager mem1sz_dev (
            .clk(clk), 
				.clk_oe(clk_oe),
            .state(state),
            
            .base_addr(base_addr - `THREAD_HEADER_SPACE),
				.base_addr_data(base_addr_data - `THREAD_HEADER_SPACE),
				
				.addr_unmodificable_b(addr_unmodificable_b),
				
				.mem1sz(0),
				
            .reg_op(mem1sz_op),
            
            .cpu_ind_rel(cpu_ind_rel),
				
            .halt_q_in(halt_q_in),
            .halt_q_out(halt_q_mem1sz),
            .rw_halt_in(rw_halt_in),
//            .rw_halt_out(rw_halt_mem1sz),
            
            .want_write_in(want_write_in),
//            .want_write_out(want_write_out_mem1sz),
            
            .is_bus_busy(is_bus_busy),
				
            .addr_in(addr_in),
            .addr_out(addr_out_mem1sz),
            .data_in(data_in),
//            .data_out(data_out_mem1sz),
            
            .register_out(mem1sz),
//            .reg_ptr_in(ip_ptr_in),
//            .reg_ptr_out(ip_ptr_out),
            
            .isRegPtr(0),      //mem1sz not ptr
            .regFlags(2'b 00), //not inc/dec
            .regNum(0), //0 is the addr of mem1sz
            
            .isNeedSave(1'b 0),
            .isDinamic(1'b 0),
            .isSaveAllowed(1'b 0),
            .isSavePtrAllowed(1'b 0),
            
            .read_q(read_q_mem1sz),
//            .write_q(write_q_mem1sz),
            .read_dn(read_dn),
            .write_dn(write_dn),
				
				.is_read(is_mem1sz_read),
//				.is_read_ptr(is_mem1sz_read_ptr),
            
            .cmd_ptr(cmd_ptr),
            
            .disp_online(disp_online),
            
            .next_state(next_state_mem1sz),
            
            .rst(rst)
            );

  
  
  

  always @(negedge clk) begin //negedge next_state) begin //
//.    addr_r = 32'h zzzzzzzz;
//    data_r = 32'h zzzzzzzz;
    
//    is_bus_busy_r = 1'b z;
    
    /*src0_op = `REG_OP_NULL; src1_op = `REG_OP_NULL; dst_op = `REG_OP_NULL; cond_op = `REG_OP_NULL;* / cmd_op = `REG_OP_NULL; */
    
    
//    if(rw_halt == 1) begin
//      ip_addr_to_read = 0;
//    end
     
    

//     $monitor("state=%b  nxt=%b  progr=%b S0ptr=%b",state,next_state,progress,isRegS0Ptr);

  if(rst == 1) begin
//    read_q = 1'b z;
//    write_q = 1'b z;

//    addr_r = 32'h zzzzzzzz;

//    next_state = 1'b z;
        
//    single = 0;

//!!!    cmd_op = `REG_OP_NULL;
  end
  else begin
  
//    cmd_op = `REG_OP_NULL;
//    src1_op = `REG_OP_NULL;
//    src0_op = `REG_OP_NULL;
//    dst_op = `REG_OP_NULL;
//    cond_op = `REG_OP_NULL;

      case(state)
		  `START_BEGIN: begin
		    mem1sz_op = `REG_OP_PREEXECUTE;

          cmd_op = `REG_OP_NULL;
          src1_op = `REG_OP_NULL;
          src0_op = `REG_OP_NULL;
          dst_op = `REG_OP_NULL;
          cond_op = `REG_OP_NULL;
		  end
		  
		  `READ_MEM_SIZE_1: begin
		    mem1sz_op = `REG_OP_READ;

          cmd_op = `REG_OP_NULL;
          src1_op = `REG_OP_NULL;
          src0_op = `REG_OP_NULL;
          dst_op = `REG_OP_NULL;
          cond_op = `REG_OP_NULL;
		  end
		
        `AFTER_MEM_SIZE_READ: begin	
		    mem1sz_op = `REG_OP_NULL;
//          cmd_op = `REG_OP_NULL;
          src1_op = `REG_OP_NULL;
          src0_op = `REG_OP_NULL;
          dst_op = `REG_OP_NULL;
          cond_op = `REG_OP_NULL;

          cmd_op = `REG_OP_PREEXECUTE;
		  end
		
        `ALU_BEGIN: begin
          cmd_op = `REG_OP_NULL;

		    mem1sz_op = `REG_OP_NULL;
//          cmd_op = `REG_OP_NULL;
          src1_op = `REG_OP_NULL;
          src0_op = `REG_OP_NULL;
          dst_op = `REG_OP_NULL;
          cond_op = `REG_OP_NULL;
        end
      
//        `START_BEGIN: begin
//          cmd_op = `REG_OP_PREEXECUTE;
//        end

        `START_READ_CMD: begin
          cmd_op = `REG_OP_READ;

		    mem1sz_op = `REG_OP_NULL;
//          cmd_op = `REG_OP_NULL;
          src1_op = `REG_OP_NULL;
          src0_op = `REG_OP_NULL;
          dst_op = `REG_OP_NULL;
          cond_op = `REG_OP_NULL;
        end
        
        `START_READ_CMD_P: begin
          cmd_op = `REG_OP_READ_P;

		    mem1sz_op = `REG_OP_NULL;
//          cmd_op = `REG_OP_NULL;
          src1_op = `REG_OP_NULL;
          src0_op = `REG_OP_NULL;
          dst_op = `REG_OP_NULL;
          cond_op = `REG_OP_NULL;
        end
        
        `WRITE_REG_IP: begin
          cmd_op = `REG_OP_WRITE;

		    mem1sz_op = `REG_OP_NULL;
//          cmd_op = `REG_OP_NULL;
          src1_op = `REG_OP_NULL;
          src0_op = `REG_OP_NULL;
          dst_op = `REG_OP_NULL;
          cond_op = `REG_OP_NULL;
        end
        
        `ALU_RESULTS: begin
            src0_op = `REG_OP_CATCH_DATA;
            src1_op = `REG_OP_CATCH_DATA;
            dst_op = `REG_OP_CATCH_DATA;
            //???? it needs to do something. it catches 0 to cond reg ???//  cond_op = `REG_OP_CATCH_DATA;
           
		    mem1sz_op = `REG_OP_NULL;
          cmd_op = `REG_OP_NULL;
//          src1_op = `REG_OP_NULL;
//          src0_op = `REG_OP_NULL;
//          dst_op = `REG_OP_NULL;
          cond_op = `REG_OP_NULL;
//            next_state = 1;
        end
		  
		  
        `FILL_DST_P: begin
          dst_op = `REG_OP_CATCH_DATA;

		    mem1sz_op = `REG_OP_NULL;
          cmd_op = `REG_OP_NULL;
          src1_op = `REG_OP_NULL;
          src0_op = `REG_OP_NULL;
//          dst_op = `REG_OP_NULL;
          cond_op = `REG_OP_NULL;
        end

        `READ_DST: begin
          dst_op = `REG_OP_READ;

		    mem1sz_op = `REG_OP_NULL;
          cmd_op = `REG_OP_NULL;
          src1_op = `REG_OP_NULL;
          src0_op = `REG_OP_NULL;
//          dst_op = `REG_OP_NULL;
          cond_op = `REG_OP_NULL;
        end

        `WRITE_DST_P: begin
          dst_op = `REG_OP_WRITE_P;

		    mem1sz_op = `REG_OP_NULL;
          cmd_op = `REG_OP_NULL;
          src1_op = `REG_OP_NULL;
          src0_op = `REG_OP_NULL;
//          dst_op = `REG_OP_NULL;
          cond_op = `REG_OP_NULL;
        end
        
        
//        `START_READ_CMD: begin
//          dst_waiting = 1;
//        end
        
        `PREEXECUTE: begin
//          cmd_op = `REG_OP_PREEXECUTE;

//          dst_waiting = 1;
//          cond_r_adr = /*base_addr +*/ regNumCnd /* `DATA_SIZE*/;
//          src1_r_adr = /*base_addr +*/ regNumS1 /* `DATA_SIZE*/;
//          src0_r_adr = /*base_addr +*/ regNumS0 /* `DATA_SIZE*/;
//          
//          if(&regDFlags == 0) dstw_waiting = 1;
//          if(^regCondFlags == 1) condw_waiting = 1;
//          if(^regS1Flags == 1) src1w_waiting = 1;
//          if(^regS0Flags == 1) src0w_waiting = 1;
            src0_op = `REG_OP_PREEXECUTE;
            src1_op = `REG_OP_PREEXECUTE;
            dst_op = `REG_OP_PREEXECUTE;
            cond_op = `REG_OP_PREEXECUTE;
            cmd_op = `REG_OP_PREEXECUTE;


		    mem1sz_op = `REG_OP_NULL;
//          cmd_op = `REG_OP_NULL;
//          src1_op = `REG_OP_NULL;
//          src0_op = `REG_OP_NULL;
//          dst_op = `REG_OP_NULL;
//          cond_op = `REG_OP_NULL;

//            cmd_op = `REG_OP_WRITE_PREP;
          
//          next_state = 1;
        end
        
        `FILL_COND: begin
          cond_op = `REG_OP_CATCH_DATA;

		    mem1sz_op = `REG_OP_NULL;
          cmd_op = `REG_OP_NULL;
          src1_op = `REG_OP_NULL;
          src0_op = `REG_OP_NULL;
          dst_op = `REG_OP_NULL;
//          cond_op = `REG_OP_NULL;
        end
        
        `READ_COND: begin
          cond_op = `REG_OP_READ;

		    mem1sz_op = `REG_OP_NULL;
          cmd_op = `REG_OP_NULL;
          src1_op = `REG_OP_NULL;
          src0_op = `REG_OP_NULL;
          dst_op = `REG_OP_NULL;
//          cond_op = `REG_OP_NULL;
        end
          
        `READ_COND_P: begin
          cond_op = `REG_OP_READ_P;

		    mem1sz_op = `REG_OP_NULL;
          cmd_op = `REG_OP_NULL;
          src1_op = `REG_OP_NULL;
          src0_op = `REG_OP_NULL;
          dst_op = `REG_OP_NULL;
//          cond_op = `REG_OP_NULL;
        end

        `FILL_SRC1: begin
          src1_op = `REG_OP_CATCH_DATA;

		    mem1sz_op = `REG_OP_NULL;
          cmd_op = `REG_OP_NULL;
//          src1_op = `REG_OP_NULL;
          src0_op = `REG_OP_NULL;
          dst_op = `REG_OP_NULL;
          cond_op = `REG_OP_NULL;
        end
        
        `READ_SRC1: begin
          src1_op = `REG_OP_READ;

		    mem1sz_op = `REG_OP_NULL;
          cmd_op = `REG_OP_NULL;
//          src1_op = `REG_OP_NULL;
          src0_op = `REG_OP_NULL;
          dst_op = `REG_OP_NULL;
          cond_op = `REG_OP_NULL;
        end
          
        `READ_SRC1_P: begin
          src1_op = `REG_OP_READ_P;

		    mem1sz_op = `REG_OP_NULL;
          cmd_op = `REG_OP_NULL;
//          src1_op = `REG_OP_NULL;
          src0_op = `REG_OP_NULL;
          dst_op = `REG_OP_NULL;
          cond_op = `REG_OP_NULL;
        end

        `FILL_SRC0: begin
          src0_op = `REG_OP_CATCH_DATA;

		    mem1sz_op = `REG_OP_NULL;
          cmd_op = `REG_OP_NULL;
          src1_op = `REG_OP_NULL;
//          src0_op = `REG_OP_NULL;
          dst_op = `REG_OP_NULL;
          cond_op = `REG_OP_NULL;
        end
        
        `READ_SRC0: begin
          src0_op = `REG_OP_READ;

		    mem1sz_op = `REG_OP_NULL;
          cmd_op = `REG_OP_NULL;
          src1_op = `REG_OP_NULL;
//          src0_op = `REG_OP_NULL;
          dst_op = `REG_OP_NULL;
          cond_op = `REG_OP_NULL;
        end
         
        `READ_SRC0_P: begin
          src0_op = `REG_OP_READ_P;

		    mem1sz_op = `REG_OP_NULL;
          cmd_op = `REG_OP_NULL;
          src1_op = `REG_OP_NULL;
//          src0_op = `REG_OP_NULL;
          dst_op = `REG_OP_NULL;
          cond_op = `REG_OP_NULL;
        end
        
        `WRITE_PREP: begin
/*
            dst_r = (regDFlags == 2'b 01 ? dst+1 : 
                     regDFlags == 2'b 10 ? dst-1 : 
                                           dst );
            
            if(regNumCnd == regNumD) cond_r = dst_r;
            if(regNumS1  == regNumD) src1_r = dst_r;
            if(regNumS0  == regNumD) src0_r = dst_r;
*/

//            if(regCondFlags == 2'b 01) begin
//              cond_r = (isRegCondPtr==1 ? cond_r_adr : cond_r)+1;
//            end else if(regCondFlags == 2'b 10) begin
//              cond_r = (isRegCondPtr==1 ? cond_r_adr : cond_r)-1;
//            end
//            if(regS1Flags == 2'b 01) begin
//              src1_r = (isRegS1Ptr==1 ? src1_r_adr : src1_r)+1;
//            end else if(regS1Flags == 2'b 10) begin
//              src1_r = (isRegS1Ptr==1 ? src1_r_adr : src1_r)-1;
//            end
//            if(regS0Flags == 2'b 01) begin
//              src0_r = (isRegS0Ptr==1 ? src0_r_adr : src0_r)+1;
//            end else if(regS0Flags == 2'b 10) begin
//              src0_r = (isRegS0Ptr==1 ? src0_r_adr : src0_r)-1;
//            end
            
            src1_op = `REG_OP_WRITE_PREP;
            src0_op = `REG_OP_WRITE_PREP;
            dst_op = `REG_OP_WRITE_PREP;
            cond_op = `REG_OP_WRITE_PREP;

		    mem1sz_op = `REG_OP_NULL;
          cmd_op = `REG_OP_NULL;
//          src1_op = `REG_OP_NULL;
//          src0_op = `REG_OP_NULL;
//          dst_op = `REG_OP_NULL;
//          cond_op = `REG_OP_NULL;
            
//            next_state = 1;
        end

        `WRITE_DST: begin
          dst_op = `REG_OP_WRITE;

		    mem1sz_op = `REG_OP_NULL;
          cmd_op = `REG_OP_NULL;
          src1_op = `REG_OP_NULL;
          src0_op = `REG_OP_NULL;
//          dst_op = `REG_OP_NULL;
          cond_op = `REG_OP_NULL;
        end

        `WRITE_COND: begin
          cond_op = `REG_OP_WRITE;

		    mem1sz_op = `REG_OP_NULL;
          cmd_op = `REG_OP_NULL;
          src1_op = `REG_OP_NULL;
          src0_op = `REG_OP_NULL;
          dst_op = `REG_OP_NULL;
//          cond_op = `REG_OP_NULL;
        end
        
        `WRITE_SRC1: begin
          src1_op = `REG_OP_WRITE;

		    mem1sz_op = `REG_OP_NULL;
          cmd_op = `REG_OP_NULL;
//          src1_op = `REG_OP_NULL;
          src0_op = `REG_OP_NULL;
          dst_op = `REG_OP_NULL;
          cond_op = `REG_OP_NULL;
        end
        
        `WRITE_SRC0: begin
          src0_op = `REG_OP_WRITE;

		    mem1sz_op = `REG_OP_NULL;
          cmd_op = `REG_OP_NULL;
          src1_op = `REG_OP_NULL;
//          src0_op = `REG_OP_NULL;
          dst_op = `REG_OP_NULL;
          cond_op = `REG_OP_NULL;
        end


//        `FINISH_BEGIN: begin
          //dst_op = `REG_OP_FINISH_BEGIN;
          //cond_op = `REG_OP_FINISH_BEGIN;
          //src1_op = `REG_OP_FINISH_BEGIN;
          //src0_op = `REG_OP_FINISH_BEGIN;
//          dstw_waiting = 0;
//          condw_waiting = 0;
//          src1w_waiting = 0;
//          src0w_waiting = 0;
//        end

        default: begin
		    mem1sz_op = `REG_OP_NULL;
          cmd_op = `REG_OP_NULL;
          src1_op = `REG_OP_NULL;
          src0_op = `REG_OP_NULL;
          dst_op = `REG_OP_NULL;
          cond_op = `REG_OP_NULL;
		  end

      endcase
      
  end
  
  end

  
endmodule

