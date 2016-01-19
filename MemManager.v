

`include "sizes.v"
`include "states.v"
`include "misc_codes.v"

`include "cmd_codes.v"


module MemManager (
            clk, 
            state,
            
            base_addr,
            command_word,
            
            cpu_ind_rel,
            halt_q,
            rw_halt,
            
            is_bus_busy,
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
            
            cmd_ptr,
            
            disp_online,
            
            next_state,
            
            isIpSaveAllowed,
            isDSaveAllowed,
            isDSavePtrAllowed,
            isCndSaveAllowed,
            isCndSavePtrAllowed,
            isS1SaveAllowed,
            isS1SavePtrAllowed,
            isS0SaveAllowed,
            isS0SavePtrAllowed,
            
            rst
            );
            
  input wire disp_online;
  
  input wire [`DATA_SIZE0:0] cmd_ptr;
  
  output tri0 next_state;
  
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
//  reg [`ADDR_SIZE0:0] base_addr_r;

  input wire [1:0] cpu_ind_rel;
  inout tri halt_q;
//  reg halt_q_r;
//  tri halt_q = halt_q_r;
  
  inout tri rw_halt;
//  reg rw_halt_r;
//  tri rw_halt = rw_halt_r;
  
  inout [`ADDR_SIZE0:0] addr;
//  reg [`ADDR_SIZE0:0] addr_r;
  tri [`ADDR_SIZE0:0] addr;
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

  output /*reg*/ tri read_q;
  output /*reg*/ tri write_q;

  inout is_bus_busy;
  reg is_bus_busy_r;
  tri is_bus_busy = is_bus_busy_r;
  
  inout [`DATA_SIZE0:0] data;
  
//  tri [`DATA_SIZE0:0] data_int;
  
//  reg [`DATA_SIZE0:0] data_r;
  tri [`DATA_SIZE0:0] data; // = data_r;
//  assign data = write_q === 1 ? data_int : 32'h zzzzzzzz;
  
  input  wire read_dn;
  input  wire write_dn;
//  output reg read_e;
//  output reg write_e;


  
  inout [`DATA_SIZE0:0] cond;
  inout [`DATA_SIZE0:0] src1;
  inout [`DATA_SIZE0:0] src0;
  inout [`DATA_SIZE0:0] dst;



  tri [`DATA_SIZE0:0] cond_ptr;


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
                                  
  tri [`DATA_SIZE0:0] ip_ptr;
  
  input wire isIpSaveAllowed;
  
  RegisterManager cmd_dev (
            .clk(clk), 
            .state(state),
            
            .base_addr(base_addr),
            .reg_op(cmd_op),
            
            .cpu_ind_rel(cpu_ind_rel),
            .halt_q(halt_q),
            .rw_halt(rw_halt),
            
            .is_bus_busy(is_bus_busy),
            .addr(addr),
            .data(data),
            
            .register(command_word),
            .reg_ptr(ip_ptr),
            
            .isRegPtr(1),      //ip is ptr of cmd
            .regFlags(2'b 01), //post-increment
            .regNum(`REG_IP), //0xf is the number of ip reg
            
            .isNeedSave(1'b 1),
            .isDinamic(1'b 0),
            .isSaveAllowed(isIpSaveAllowed),
            .isSavePtrAllowed(1'b 0),
            
            .read_q(read_q),
            .write_q(write_q),
            .read_dn(read_dn),
            .write_dn(write_dn),
            
            .cmd_ptr(cmd_ptr),
            
            .disp_online(disp_online),
            
            .next_state(next_state),
            
            .rst(rst)
            );





//  reg [`DATA_SIZE0:0] src1_r_adr;
//  reg [`DATA_SIZE0:0] src1_r;
//  wire [`DATA_SIZE0:0] src1 = src1_r;
//  reg src1_waiting;
//  reg src1ptr_waiting;
//  reg src1w_waiting;
  
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
                                    : `REG_OP_NULL
                                  ;
  
  tri [`DATA_SIZE0:0] src1_ptr = (src1_op == `REG_OP_CATCH_DATA) 
                                              ? ( regNumS1 == `REG_IP 
                                                            ? ip_ptr 
                                                            : ( regNumS1 == regNumCnd
                                                                          ? cond_ptr
                                                                          : `ADDR_SIZE'h zzzzzzzz 
                                                              )
                                                )
                                              : `ADDR_SIZE'h zzzzzzzz
                                              ;
                                              
  tri [`DATA_SIZE0:0] src1 = (state == `FILL_SRC1) 
                                  ? (regNumS1 == regNumCnd
                                       ? cond
                                       : `ADDR_SIZE'h zzzzzzzz
                                    )
                                  : `ADDR_SIZE'h zzzzzzzz
                                  ;
  
  input wire isS1SaveAllowed;
  input wire isS1SavePtrAllowed;
  
  RegisterManager src1_dev (
            .clk(clk), 
            .state(state),
            
            .base_addr(base_addr),
            .reg_op(src1_op),
            
            .cpu_ind_rel(cpu_ind_rel),
            .halt_q(halt_q),
            .rw_halt(rw_halt),
            
            .is_bus_busy(is_bus_busy),
            .addr(addr),
            .data(data),
            
            .register(src1),
            .reg_ptr(src1_ptr),
            
            .isRegPtr(isRegS1Ptr),
            .regFlags(regS1Flags),
            .regNum(regNumS1),
            
            .isNeedSave(1'b 0),
            .isDinamic(1'b 0),
            .isSaveAllowed(isS1SaveAllowed),
            .isSavePtrAllowed(isS1SavePtrAllowed),
            
            .read_q(read_q),
            .write_q(write_q),
            .read_dn(read_dn),
            .write_dn(write_dn),
            
            .cmd_ptr(cmd_ptr),
            
            .disp_online(disp_online),
            
            .next_state(next_state),
            
            .rst(rst)
            );


//  reg [`DATA_SIZE0:0] src0_r_adr;
//  reg [`DATA_SIZE0:0] src0_r;
//  wire [`DATA_SIZE0:0] src0 = src0_r;
//  reg src0_waiting;
//  reg src0ptr_waiting;
//  reg src0w_waiting;
  
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

  tri [`DATA_SIZE0:0] src0_ptr = (src0_op == `REG_OP_CATCH_DATA) 
                                              ? ( regNumS0 == `REG_IP 
                                                            ? ip_ptr 
                                                            : ( regNumS0 == regNumCnd
                                                                          ? cond_ptr
                                                                          : (regNumS0 == regNumS1 
                                                                                       ? src1_ptr
                                                                                       : `ADDR_SIZE'h zzzzzzzz 
                                                                            )
                                                              )
                                                )
                                              : `ADDR_SIZE'h zzzzzzzz
                                              ;

  tri [`DATA_SIZE0:0] src0 =  (src0_op == `REG_OP_CATCH_DATA) 
                                   ? (regNumS0 == regNumCnd
                                         ? cond
                                         : (regNumS0 == regNumS1)
                                                   ? src1 
                                                   : `ADDR_SIZE'h zzzzzzzz
                                     )
                                   : `ADDR_SIZE'h zzzzzzzz
                              ;
 
  input wire isS0SaveAllowed;
  input wire isS0SavePtrAllowed;
  
  RegisterManager src0_dev (
            .clk(clk), 
            .state(state),
            
            .base_addr(base_addr),
            .reg_op(src0_op),
            
            .cpu_ind_rel(cpu_ind_rel),
            .halt_q(halt_q),
            .rw_halt(rw_halt),
            
            .is_bus_busy(is_bus_busy),
            .addr(addr),
            .data(data),
            
            .register(src0),
            .reg_ptr(src0_ptr),
            
            .isRegPtr(isRegS0Ptr),
            .regFlags(regS0Flags),
            .regNum(regNumS0),
            
            .isNeedSave(1'b 0),  //cmd_code == `CMD_MOV),
            .isDinamic(1'b 0),
            .isSaveAllowed(isS0SaveAllowed),
            .isSavePtrAllowed(isS0SavePtrAllowed),
            
            .read_q(read_q),
            .write_q(write_q),
            .read_dn(read_dn),
            .write_dn(write_dn),
            
            .cmd_ptr(cmd_ptr),
            
            .disp_online(disp_online),
            
            .next_state(next_state),
            
            .rst(rst)
            );


//  reg [`DATA_SIZE0:0] dst_r_adr;
//  reg [`DATA_SIZE0:0] dst_r;
//  wire [`DATA_SIZE0:0] dst = dst_r;
//  reg dst_waiting;
//  reg dstptr_waiting;
//  reg dstw_waiting;
  
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
                                  
  tri [`DATA_SIZE0:0] dst_ptr = (dst_op == `REG_OP_CATCH_DATA) 
                                              ? ( regNumD == `REG_IP 
                                                            ? ip_ptr 
                                                            : (regNumD == regNumCnd
                                                                        ? cond_ptr
                                                                        : (regNumD == regNumS1 
                                                                                    ? src1_ptr
                                                                                    : (regNumD == regNumS0 
                                                                                                ? src0_ptr
                                                                                                : `ADDR_SIZE'h zzzzzzzz 
                                                                                      )
                                                                          )
                                                              )
                                                )
                                              : `ADDR_SIZE'h zzzzzzzz
                                              ;
                                              
  tri [`DATA_SIZE0:0] dst;
  
  input wire isDSaveAllowed;
  input wire isDSavePtrAllowed;
  
  RegisterManager dst_dev (
            .clk(clk), 
            .state(state),
            
            .base_addr(base_addr),
            .reg_op(dst_op),
            
            .cpu_ind_rel(cpu_ind_rel),
            .halt_q(halt_q),
            .rw_halt(rw_halt),
            
            .is_bus_busy(is_bus_busy),
            .addr(addr),
            .data(data),
            
            .register(dst),
            .reg_ptr(dst_ptr),
            
            .isRegPtr(isRegDPtr),
            .regFlags(regDFlags),
            .regNum(regNumD),
            
            .isNeedSave(1),
            .isDinamic(1'b 0),
            .isSaveAllowed(isDSaveAllowed),
            .isSavePtrAllowed(isDSavePtrAllowed),
            
            .read_q(read_q),
            .write_q(write_q),
            .read_dn(read_dn),
            .write_dn(write_dn),
            
            .cmd_ptr(cmd_ptr),
            
            .disp_online(disp_online),
            
            .next_state(next_state),
            
            .rst(rst)
            );
  
  
  input wire [`DATA_SIZE0:0] dst_h;
  reg [`DATA_SIZE0:0] dst_h_r;



//  inout tri [`DATA_SIZE0:0] cond;
//  reg [`DATA_SIZE0:0] cond_r_adr;
//  reg [`DATA_SIZE0:0] cond_r;
//  wire [`DATA_SIZE0:0] cond = cond_r;
//  reg cond_waiting;
//  reg condptr_waiting;
//  reg condw_waiting;
  
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

    assign cond_ptr = (cond_op == `REG_OP_CATCH_DATA) 
                                              ? ( regNumCnd == `REG_IP ? ip_ptr : `ADDR_SIZE'h zzzzzzzz )
                                              : `ADDR_SIZE'h zzzzzzzz
                                              ;
                                              
  tri [`DATA_SIZE0:0] cond;
  
  input wire isCndSaveAllowed;
  input wire isCndSavePtrAllowed;
  
  RegisterManager cond_dev (
            .clk(clk), 
            .state(state),
            
            .base_addr(base_addr),
            .reg_op(cond_op),
            
            .cpu_ind_rel(cpu_ind_rel),
            .halt_q(halt_q),
            .rw_halt(rw_halt),
            
            .is_bus_busy(is_bus_busy),
            .addr(addr),
            .data(data),
            
            .register(cond),
            .reg_ptr(cond_ptr),
            
            .isRegPtr(isRegCondPtr),
            .regFlags(regCondFlags),
            .regNum(regNumCnd),
            
            .isNeedSave(1'b 0),
            .isDinamic(1'b 1),
            .isSaveAllowed(isCndSaveAllowed),
            .isSavePtrAllowed(isCndSavePtrAllowed),
            
            .read_q(read_q),
            .write_q(write_q),
            .read_dn(read_dn),
            .write_dn(write_dn),
            
            .cmd_ptr(cmd_ptr),
            
            .disp_online(disp_online),
            
            .next_state(next_state),
            
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
  
  

  always @(posedge clk) begin
//.    addr_r = 32'h zzzzzzzz;
//    data_r = 32'h zzzzzzzz;
    
    is_bus_busy_r = 1'b z;
    
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
  end
  else begin
          
      case(state)
//        `ALU_BEGIN: begin
//          cmd_op = `REG_OP_NULL;
//        end
      
        `START_BEGIN: begin
//          cmd_op = `REG_OP_PREEXECUTE;
        end

        `START_READ_CMD: begin
//          cmd_op = `REG_OP_READ;
        end
        
        `START_READ_CMD_P: begin
//          cmd_op = `REG_OP_READ_P;
        end
        
        `WRITE_REG_IP: begin
//          cmd_op = `REG_OP_WRITE_P;
        end
        
        `ALU_RESULTS: begin
//            src0_op = `REG_OP_CATCH_DATA;
//            src1_op = `REG_OP_CATCH_DATA;
//            dst_op = `REG_OP_CATCH_DATA;
//            cond_op = `REG_OP_CATCH_DATA;
            
//            next_state = 1;
        end
        
        
//        `START_READ_CMD: begin
//          dst_waiting = 1;
//        end
        
        `PREEXECUTE: begin
//          dst_waiting = 1;
//          cond_r_adr = /*base_addr +*/ regNumCnd /* `DATA_SIZE*/;
//          src1_r_adr = /*base_addr +*/ regNumS1 /* `DATA_SIZE*/;
//          src0_r_adr = /*base_addr +*/ regNumS0 /* `DATA_SIZE*/;
//          
//          if(&regDFlags == 0) dstw_waiting = 1;
//          if(^regCondFlags == 1) condw_waiting = 1;
//          if(^regS1Flags == 1) src1w_waiting = 1;
//          if(^regS0Flags == 1) src0w_waiting = 1;
//            src0_op = `REG_OP_PREEXECUTE;
//            src1_op = `REG_OP_PREEXECUTE;
//            dst_op = `REG_OP_PREEXECUTE;
//            cond_op = `REG_OP_PREEXECUTE;
//            cmd_op = `REG_OP_PREEXECUTE;

//            cmd_op = `REG_OP_WRITE_PREP;
          
//          next_state = 1;
        end
        
        `FILL_COND: begin
//          cond_op = `REG_OP_CATCH_DATA;
        end
        
        `READ_COND: begin
//          cond_op = `REG_OP_READ;
        end
          
        `READ_COND_P: begin
//          cond_op = `REG_OP_READ_P;
        end

        `FILL_SRC1: begin
//          src1_op = `REG_OP_CATCH_DATA;
        end
        
        `READ_SRC1: begin
//          src1_op = `REG_OP_READ;
        end
          
        `READ_SRC1_P: begin
//          src1_op = `REG_OP_READ_P;
        end

        `FILL_SRC0: begin
//          src0_op = `REG_OP_CATCH_DATA;
        end
        
        `READ_SRC0: begin
//          src0_op = `REG_OP_READ;
        end
         
        `READ_SRC0_P: begin
//          src0_op = `REG_OP_READ_P;
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
            
//            src1_op = `REG_OP_WRITE_PREP;
//            src0_op = `REG_OP_WRITE_PREP;
//            dst_op = `REG_OP_WRITE_PREP;
//            cond_op = `REG_OP_WRITE_PREP;
            
//            next_state = 1;
        end

        `WRITE_DST: begin
//          dst_op = `REG_OP_WRITE;
        end

        `WRITE_COND: begin
        end
        
        `WRITE_SRC1: begin
        end
        
        `WRITE_SRC0: begin
        end
        
        `FINISH_BEGIN: begin
          //dst_op = `REG_OP_FINISH_BEGIN;
          //cond_op = `REG_OP_FINISH_BEGIN;
          //src1_op = `REG_OP_FINISH_BEGIN;
          //src0_op = `REG_OP_FINISH_BEGIN;
//          dstw_waiting = 0;
//          condw_waiting = 0;
//          src1w_waiting = 0;
//          src0w_waiting = 0;
        end

      endcase
      
  end
  
  end

  
endmodule

