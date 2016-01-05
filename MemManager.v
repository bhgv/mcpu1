

`include "sizes.v"
`include "states.v"
`include "misc_codes.v"



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
            
            rst
            );
            
  input wire disp_online;
  
  input wire [`DATA_SIZE0:0] cmd_ptr;
  
  output tri0 next_state;
  
  input wire rst;

            
  input wire clk;
  input wire [`STATE_SIZE0:0] state;
  input wire [31:0] command_word;

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
  

  inout tri [`DATA_SIZE0:0] src1;
//  reg [`DATA_SIZE0:0] src1_r_adr;
//  reg [`DATA_SIZE0:0] src1_r;
//  wire [`DATA_SIZE0:0] src1 = src1_r;
//  reg src1_waiting;
//  reg src1ptr_waiting;
//  reg src1w_waiting;
  
  reg [`SIZE_REG_OP-1:0] src1_op;
  
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
            
            .isRegPtr(isRegS1Ptr),
            .regFlags(regS1Flags),
            .regNum(regNumS1),
            
            .isNeedSave(1'b 0),
            
            .read_q(read_q),
            .write_q(write_q),
            .read_dn(read_dn),
            .write_dn(write_dn),
            
            .cmd_ptr(cmd_ptr),
            
            .disp_online(disp_online),
            
            .next_state(next_state),
            
            .rst(rst)
            );


  inout tri [`DATA_SIZE0:0] src0;
//  reg [`DATA_SIZE0:0] src0_r_adr;
//  reg [`DATA_SIZE0:0] src0_r;
//  wire [`DATA_SIZE0:0] src0 = src0_r;
//  reg src0_waiting;
//  reg src0ptr_waiting;
//  reg src0w_waiting;
  
  reg [`SIZE_REG_OP-1:0] src0_op;
  
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
            
            .isRegPtr(isRegS0Ptr),
            .regFlags(regS0Flags),
            .regNum(regNumS0),
            
            .isNeedSave(1'b 0),
            
            .read_q(read_q),
            .write_q(write_q),
            .read_dn(read_dn),
            .write_dn(write_dn),
            
            .cmd_ptr(cmd_ptr),
            
            .disp_online(disp_online),
            
            .next_state(next_state),
            
            .rst(rst)
            );


  inout tri [`DATA_SIZE0:0] dst;
//  reg [`DATA_SIZE0:0] dst_r_adr;
//  reg [`DATA_SIZE0:0] dst_r;
//  wire [`DATA_SIZE0:0] dst = dst_r;
//  reg dst_waiting;
//  reg dstptr_waiting;
//  reg dstw_waiting;
  
  reg [`SIZE_REG_OP-1:0] dst_op;
  
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
            
            .isRegPtr(isRegDPtr),
            .regFlags(regDFlags),
            .regNum(regNumD),
            
            .isNeedSave(1'b 1),
            
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



  inout tri [`DATA_SIZE0:0] cond;
//  reg [`DATA_SIZE0:0] cond_r_adr;
//  reg [`DATA_SIZE0:0] cond_r;
//  wire [`DATA_SIZE0:0] cond = cond_r;
//  reg cond_waiting;
//  reg condptr_waiting;
//  reg condw_waiting;
  
  reg [`SIZE_REG_OP-1:0] cond_op;
  
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
            
            .isRegPtr(isRegCondPtr),
            .regFlags(regCondFlags),
            .regNum(regNumCnd),
            
            .isNeedSave(1'b 0),
            
            .read_q(read_q),
            .write_q(write_q),
            .read_dn(read_dn),
            .write_dn(write_dn),
            
            .cmd_ptr(cmd_ptr),
            
            .disp_online(disp_online),
            
            .next_state(next_state),
            
            .rst(rst)
            );
  
  
//  input wire [`DATA_SIZE0:0] cmd_ptr;
  
  
//  input wire disp_online;
  
//  output reg next_state;
  
//  input wire rst;
  
//  reg single;
  
  

  always @(posedge clk) begin
//.    addr_r = 32'h zzzzzzzz;
//    data_r = 32'h zzzzzzzz;
    
    is_bus_busy_r = 1'b z;
    
    src0_op = `REG_OP_NULL; src1_op = `REG_OP_NULL; dst_op = `REG_OP_NULL; cond_op = `REG_OP_NULL; 

    
//    halt_q_r = 1'bz;

//    rw_halt_r = 1'bz;
//    if(halt_q === 1) begin
//      if(cpu_ind_rel == 2'b01) begin

/*
        if(condw_waiting == 1 && rw_halt_r !== 1) begin
//          if(isRegCondPtr == 0) begin
            rw_halt_r = addr === (/ *base_addr +* / regNumCnd) ? 1 : 1'bz;
//          end else begin
//            rw_halt_r = addr == cond_r_adr ? 1 : 1'bz;
//          end
          cond_waiting = 0;
        end
      
        if(src1w_waiting == 1 && rw_halt_r !== 1) begin
//          if(isRegS1Ptr == 0) begin
            rw_halt_r = addr === (/ *base_addr +* / regNumS1) ? 1 : 1'bz;
//          end else begin
//            rw_halt_r = addr == src1_r_adr ? 1 : 1'bz;
//          end
          src1_waiting = 0;
        end 
      
        if(src0w_waiting == 1 && rw_halt_r !== 1) begin
//          if(isRegS0Ptr == 0) begin
            rw_halt_r = addr === (base_addr + regNumS0) ? 1 : 1'bz;
//          end else begin
//            rw_halt_r = addr == src0_r_adr ? 1 : 1'bz;
//          end
          src0_waiting = 0;
        end 

        if(dstw_waiting == 1 && rw_halt_r !== 1) begin
//          if(isRegDPtr == 0) begin
            rw_halt_r = addr === (/ *base_addr +* / regNumD) ? 1 : 1'bz;
//          end else begin
//            rw_halt_r = addr == dst_r_adr ? 1 : 1'bz;
//          end
//          dst_waiting = 0;
        end 
*/

//      end
//    end
    
    
//    if(rw_halt == 1) begin
//      ip_addr_to_read = 0;
//    end
     
    

//     $monitor("state=%b  nxt=%b  progr=%b S0ptr=%b",state,next_state,progress,isRegS0Ptr);

  if(rst == 1) begin
//    read_q = 1'b z;
//    write_q = 1'b z;

//    addr_r = 32'h zzzzzzzz;

//    next_state = 1'b z;
    
//    cond_r = 1; //32'h zzzzzzzz;
//    src1_r = 1; //32'h zzzzzzzz;
//    src0_r = 1; //32'h zzzzzzzz;
//    dst_r = 32'h zzzzzzzz;
   
//    src1_waiting = 0; src0_waiting = 0; dst_waiting = 0; cond_waiting = 0; 
//    src1ptr_waiting = 0; src0ptr_waiting = 0; dstptr_waiting = 0; condptr_waiting = 0; 
//    src1w_waiting = 0; src0w_waiting = 0; dstw_waiting = 0; condw_waiting = 0;
    
//    single = 0;
    
//    src0_op = `REG_OP_NULL; src1_op = `REG_OP_NULL; dst_op = `REG_OP_NULL; cond_op = `REG_OP_NULL; 
  end
  else begin
     
//    next_state = 1'b z;

//    read_q = 1'b z;
//    write_q = 1'b z;
    
    
//    if(disp_online == 0) single = 1;
    
    
    if(is_bus_busy == 1) begin
      
//        addr_r = `ADDR_SIZE'h zzzzzzzz;
        
        case(state)
          `READ_COND: begin
            cond_op = `REG_OP_READ;
            /*
            if(read_dn == 1 && cond_waiting == 1) begin
                if(addr == cond_r_adr) begin
                  cond_r = data;
////                  cond_waiting = 0;
//                  next_state = 1;
                end
            end
            */
          end
        
          `READ_COND_P: begin
            cond_op = `REG_OP_READ_P;
            /*
            if(read_dn == 1) begin
                if(addr == cond_r) begin
                  cond_r = data;
                  condptr_waiting = 0;
//                  next_state = 1;
                end
            end
            */
          end

          `READ_SRC1: begin
            src1_op = `REG_OP_READ;
            /*
            if(read_dn == 1 && src1_waiting == 1) begin
                if(addr == src1_r_adr) begin
                  src1_r = data;
////                  src1_waiting = 0;
//                  next_state = 1;
                end
            end
            */
          end
        
          `READ_SRC1_P: begin
            src1_op = `REG_OP_READ_P;
            /*
            if(read_dn == 1) begin
                if(addr == src1_r) begin
                  src1_r = data;
                  src1ptr_waiting = 0;
//                  next_state = 1;
                end
            end
            */
          end
        
          `READ_SRC0: begin
            src0_op = `REG_OP_READ;
            /*
            if(read_dn == 1 && src0_waiting == 1) begin
                if(addr == src0_r_adr) begin
                  src0_r = data;
////                  src0_waiting = 0;
//                  next_state = 1;
                end
            end
            */
          end
        
          `READ_SRC0_P: begin
            src0_op = `REG_OP_READ_P;
            /*
            if(read_dn == 1) begin
                if(addr == src0_r) begin
                  src0_r = data;
                  src0ptr_waiting = 0;
//                  next_state = 1;
                end
            end
            */
          end
          
          `WRITE_PREP: begin
//            next_state = 1;
          end

          `WRITE_DST: begin
            dst_op = `REG_OP_WRITE;
            /*
            if(write_dn == 1 && addr == (/ *base_addr +* / regNumD)) begin
              dstw_waiting = 0;
//              next_state = 1;
            end
            */
          end
           
          `WRITE_COND: begin
            cond_op = `REG_OP_WRITE;
            /*
            if(write_dn == 1 && addr == (/ *base_addr +* / regNumCnd)) begin
              condw_waiting = 0;
//              next_state = 1;
            end
            */
          end
           
          `WRITE_SRC1: begin
            src1_op = `REG_OP_WRITE;
            /*
            if(write_dn == 1 && addr == (/ *base_addr +* / regNumS1)) begin
              src1w_waiting = 0;
//              next_state = 1;
            end
            */
          end
           
          `WRITE_SRC0: begin
            src0_op = `REG_OP_WRITE;
            /*
            if(write_dn == 1 && addr == (/ *base_addr +* / regNumS0)) begin
              src0w_waiting = 0;
//              next_state  = 1;
            end
            */
          end
          
          endcase
        
/*
        if(src1_waiting == 1) begin if(
              (src1ptr_waiting == 0 && addr == src1_r_adr) || 
              (src1ptr_waiting == 1 && addr == src1_r)
        ) begin
          src1_r = data;
          
          src1_waiting = 0;
          if(isRegS1Ptr==1 && src1ptr_waiting==0) begin
            src1ptr_waiting = 1;
          end else begin
            src1ptr_waiting = 0;
          end
          
          next_state = 1;

        end end
        ... ... ...
*/
/*
      end
      else
      if(
          write_dn == 1  && 
          (
          (state == `WRITE_DST  && addr == base_addr + regNumD) ||
          (state == `WRITE_SRC1 && addr == base_addr + regNumS1) ||
          (state == `WRITE_SRC0 && addr == base_addr + regNumS0) ||
          (state == `WRITE_COND && addr == base_addr + regNumCnd)
          )
      ) begin
        addr_r = 32'h zzzzzzzz;
        data_r = 32'h zzzzzzzz;
        next_state = 1;
      end
*/
    end else begin
     
      case(state)
//        `START_READ_CMD: begin
//          dst_waiting = 1;
//        end
        
        //`WRITE_REG_IP
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
            src0_op = `REG_OP_PREEXECUTE;
            src1_op = `REG_OP_PREEXECUTE;
            dst_op = `REG_OP_PREEXECUTE;
            cond_op = `REG_OP_PREEXECUTE;
          
//          next_state = 1;
        end
        
        `READ_COND: begin
          cond_op = `REG_OP_READ;
          /*
          if(read_q == 1) begin
            addr_r = `ADDR_SIZE'h zzzzzzzz;
//            read_q = 1'bz;
          end else
          if(cond_r_adr == 15) begin // 4'h f <- ip reg
            cond_r = cmd_ptr;
//            next_state = 1;
          end else 
          if(disp_online == 1 && single == 1) begin
            addr_r = cond_r_adr;
//            read_q = 1;
            halt_q_r = 1;
            if(^regCondFlags == 1) condptr_waiting = 1;
            cond_waiting = 1;
                
            single = 0;
          end
          */
        end
          
        `READ_COND_P: begin
          cond_op = `REG_OP_READ_P;
          /*
          if(read_q == 1) begin
            addr_r = `ADDR_SIZE'h zzzzzzzz;
//            read_q = 1'bz;
          end else
          if(cond_r == 15) begin // 4'h f <- ip reg
            cond_r_adr = cond_r;
            cond_r = cmd_ptr;
//            next_state = 1;
          end else 
          if(disp_online == 1 && single == 1) begin
            addr_r = cond_r; //cond_r_aux;
            cond_r_adr = cond_r;
//            read_q = 1;
            halt_q_r = 1;
//            condptr_waiting = 1;
            
            single = 0;
          end
          */
        end

        `READ_SRC1: begin
          src1_op = `REG_OP_READ;
          /*
          if(read_q == 1) begin
            addr_r = `ADDR_SIZE'h zzzzzzzz;
//            read_q = 1'bz;
          end else 
          if(src1_r_adr == 15) begin // 4'h f <- ip reg
            src1_r = cmd_ptr;
//            next_state = 1;
          end else 
          if(disp_online == 1 && single == 1) begin
            addr_r = src1_r_adr;
//            read_q = 1;
            halt_q_r = 1;
            
            if(^regS1Flags == 1) src1ptr_waiting = 1;
            src1_waiting = 1;

            single = 0;
          end
          */
        end
          
        `READ_SRC1_P: begin
          src1_op = `REG_OP_READ_P;
          /*
          if(read_q == 1) begin
            addr_r = `ADDR_SIZE'h zzzzzzzz;
//            read_q = 1'bz;
          end else
          if(src1_r == 15) begin // 4'h f <- ip reg
            src1_r_adr = src1_r;
            src1_r = cmd_ptr;
//            next_state = 1;
          end else 
          if(disp_online == 1 && single == 1) begin
            addr_r = src1_r; //cond_r_aux;
            src1_r_adr = src1_r;
//            read_q = 1;
            halt_q_r = 1;
//            src1ptr_waiting = 1;
            
            single = 0;
          end
          */
        end

        `READ_SRC0: begin
          src0_op = `REG_OP_READ;
          /*
          if(read_q == 1) begin
            addr_r = `ADDR_SIZE'h zzzzzzzz;
//            read_q = 1'bz;
          end else //begin
          if(src0_r_adr == 15) begin // 4'h f <- ip reg
            src0_r = cmd_ptr;
//            next_state = 1;
          end else 
          if(disp_online == 1 && single == 1) begin
            addr_r = src0_r_adr;
//            read_q = 1;
            halt_q_r = 1;
            
            if(^regS0Flags == 1) src0ptr_waiting = 1;
            src0_waiting = 1;

            single = 0;
          end
          */
        end
         
        `READ_SRC0_P: begin
          src0_op = `REG_OP_READ_P;
          /*
          if(read_q == 1) begin
            addr_r = `ADDR_SIZE'h zzzzzzzz;
//            read_q = 1'bz;
          end else
          if(src0_r == 15) begin // 4'h f <- ip reg
            src0_r_adr = src0_r;
            src0_r = cmd_ptr;
//            next_state = 1;
          end else 
          if(disp_online == 1 && single == 1) begin
            addr_r = src0_r; //cond_r_aux;
            src0_r_adr = src0_r;
//            read_q = 1;
            halt_q_r = 1;
//            src0ptr_waiting = 1;
            
            single = 0;
          end
          */
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
            
//            next_state = 1;
        end

        `WRITE_DST: begin
          dst_op = `REG_OP_WRITE;
          /*
          if(write_q == 1) begin
//            write_q = 1'bz;
          end else
          if(disp_online == 1 && single == 1) begin
            data_r = dst_r;
            addr_r = / *base_addr +* / regNumD / * ((`DATA_SIZE0+1)/8)* /;
//            write_q = 1;
            
            single = 0;
          end
          */
        end

        `WRITE_COND: begin
//          dstw_waiting = 0;
        
          cond_op = `REG_OP_WRITE;
          /*
          if(write_q == 1) begin
//            write_q = 1'bz;
          end else
          if(disp_online == 1 && single == 1) begin
            data_r = cond_r;
            addr_r = / *base_addr +* / regNumCnd;
//            write_q = 1;
            
            single = 0;
          end
          */
        end
        
        `WRITE_SRC1: begin
//          dstw_waiting = 0;
//          condw_waiting = 0;
          
          src1_op = `REG_OP_WRITE;
          /*
          if(write_q == 1) begin
//            write_q = 1'bz;
          end else
          if(disp_online == 1 && single == 1) begin
            data_r = src1_r;
            addr_r = / *base_addr +* / regNumS1;
//            write_q = 1;
            
            single = 0;
          end
          */
        end
        
        `WRITE_SRC0: begin
//          dstw_waiting = 0;
//          condw_waiting = 0;
//          src1w_waiting = 0;

          src0_op = `REG_OP_WRITE;
          /*
          if(write_q == 1) begin
//            write_q = 1'bz;
          end else
          if(disp_online == 1 && single == 1) begin
            data_r = src0_r;
            addr_r = / *base_addr +* / regNumS0;
//            write_q = 1;
            
            single = 0;
          end
          */
        end
        
        `FINISH_BEGIN: begin
          dst_op = `REG_OP_FINISH_BEGIN;
          cond_op = `REG_OP_FINISH_BEGIN;
          src1_op = `REG_OP_FINISH_BEGIN;
          src0_op = `REG_OP_FINISH_BEGIN;
//          dstw_waiting = 0;
//          condw_waiting = 0;
//          src1w_waiting = 0;
//          src0w_waiting = 0;
        end

      endcase
      
    end
    
  end
  
  end

  
endmodule

