

`include "sizes.v"
`include "states.v"
`include "misc_codes.v"



module RegisterManager (
            clk, 
            state,        // processor cicle state (in)
            
            base_addr,    // base addres of process (in)
            reg_op,      // reg op  (in)
            
            cpu_ind_rel,
            halt_q,
            rw_halt,
            
            is_bus_busy,
            addr,
            data,
            
            register,
            reg_ptr,
            
            isRegPtr,
            regFlags,
            regNum,
            
            isNeedSave,
            isDinamic,
            
            read_q,
            write_q,
            read_dn,
            write_dn,
//            read_e,
//            write_e,
                        
            cmd_ptr,
            
            disp_online,
            
            next_state,
            
            rst
            );
            
  input wire disp_online;
            
            
  input wire clk;
  input wire [`STATE_SIZE0:0] state;
  input wire [`SIZE_REG_OP-1:0] reg_op;

  input wire [3:0] regNum;
/*
  assign regNumS1 = command_word[3:0];

  wire [3:0] regNumS0;
  assign regNumS0 = command_word[7:4];

  wire [3:0] regNumD;
  assign regNumD = command_word[11:8];

  wire [3:0] regNumCnd;
  assign regNumCnd = command_word[15:12];
*/  
  
  
  input wire isRegPtr;  
  
  input wire [1:0] regFlags;
  
  input wire isNeedSave;
  
  input wire isDinamic;
  
  input wire [`ADDR_SIZE0:0] base_addr;
//  reg [`ADDR_SIZE0:0] base_addr_r;



  inout [`DATA_SIZE0:0] register;
  inout [`DATA_SIZE0:0] reg_ptr;
  wire [`DATA_SIZE0:0] register_r_adr = /*base_addr +*/ regNum /* `DATA_SIZE*/;
  reg [`DATA_SIZE0:0] register_r_ptr;
  reg [`DATA_SIZE0:0] register_r;
  tri [`DATA_SIZE0:0] register = (reg_op == `REG_OP_CATCH_DATA) 
                                              ? `ADDR_SIZE'h zzzzzzzz
                                              : register_r
                                              ;  // tri or wire ??

                                              
  wire [`DATA_SIZE0:0] data_to_save = (isRegPtr == 0 || reg_op == `REG_OP_WRITE) 
                                              ? register_r
                                              : register_r_ptr
                                              ;
                                              
  wire [`DATA_SIZE0:0] data_post_inc_dec = (regFlags == 2'b 01)
                                              ? data_to_save + 1
                                              : (regFlags == 2'b 10)
                                                  ? data_to_save - 1
                                                  : data_to_save
                                              ;


  tri [`DATA_SIZE0:0] reg_ptr = (reg_op == `REG_OP_CATCH_DATA) 
                                              ? `ADDR_SIZE'h zzzzzzzz
                                              : data_post_inc_dec
                                              ;  // tri or wire ??
                                              
  
  reg register_waiting;
  reg registerptr_waiting;
  reg registerw_waiting;



  inout [`ADDR_SIZE0:0] addr;
  reg [`ADDR_SIZE0:0] addr_r;
  tri [`ADDR_SIZE0:0] addr  = (
                        reg_op == `REG_OP_READ ||
                        reg_op == `REG_OP_READ_P ||
                        reg_op == `REG_OP_WRITE ||
                        reg_op == `REG_OP_WRITE_P
/*                        
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
*/
                        ) &&
                        disp_online == 1 
//                        && (!ext_next_cpu_e == 1)
                        ? addr_r
                        : `ADDR_SIZE'h zzzzzzzz
                        ;
  
  wire [`ADDR_SIZE0:0] addr_to_save = (isRegPtr && reg_op == `REG_OP_WRITE) ? register_r_ptr : /*base_addr +*/ regNum;



  input wire [1:0] cpu_ind_rel;
  inout halt_q;
  reg halt_q_r;
  wire halt_q = halt_q_r;
  
  inout rw_halt;
//  reg rw_halt_r;
  tri rw_halt =
            halt_q === 1
            && registerw_waiting == 1'b 1
            && cpu_ind_rel == 2'b01
            && (
                (/*reg_op == `REG_OP_READ*/ /*isRegPtr == 1 &&*/ addr === register_r_adr)
                || (isRegPtr == 1 && isNeedSave == 1 && addr === register_r_ptr)
//                || (/*reg_op == `REG_OP_READ_P*/ isRegPtr == 0 && addr == register_r_ptr)
               )
                        ? 1'b 1
                        : 1'b z
            ;

  
  output read_q;
  output write_q;

  reg read_q_r;
  reg write_q_r;

  tri read_q = read_q_r;
  tri write_q = write_q_r;

  inout is_bus_busy;
  reg is_bus_busy_r;
  wire is_bus_busy = is_bus_busy_r;
  
  inout [`DATA_SIZE0:0] data;
  reg [`DATA_SIZE0:0] data_r;
  tri [`DATA_SIZE0:0] data =  (
                                reg_op == `REG_OP_WRITE 
                                || reg_op == `REG_OP_WRITE_P
                                //&& write_q === 1'b 1 
                              ) &&
                              disp_online == 1 
                                        ? data_r
                                        : `DATA_SIZE'h zzzzzzzz;
//  assign data = write_q==1 ? dst_r : 32'h z;
  
  input  wire read_dn;
  input  wire write_dn;
//  output reg read_e;
//  output reg write_e;
  
  
/*
  inout [`DATA_SIZE0:0] register;
  reg [`DATA_SIZE0:0] register_r_adr;
  reg [`DATA_SIZE0:0] register_r;
  tri [`DATA_SIZE0:0] register = state == `ALU_BEGIN 
                                              ? register_r
                                              : `ADDR_SIZE'h zzzzzzzz;  // tri or wire ??
  reg register_waiting;
  reg registerptr_waiting;
  reg registerw_waiting;
*/

/*
  inout [`DATA_SIZE0:0] src0;
  reg [`DATA_SIZE0:0] src0_r_adr;
  reg [`DATA_SIZE0:0] src0_r;
  wire [`DATA_SIZE0:0] src0 = src0_r;
  reg src0_waiting;
  reg src0ptr_waiting;
  reg src0w_waiting;

  inout [`DATA_SIZE0:0] dst;
  reg [`DATA_SIZE0:0] dst_r_adr;
  reg [`DATA_SIZE0:0] dst_r;
  wire [`DATA_SIZE0:0] dst = dst_r;
  reg dst_waiting;
  reg dstptr_waiting;
  reg dstw_waiting;
  
  input wire [`DATA_SIZE0:0] dst_h;
  reg [`DATA_SIZE0:0] dst_h_r;

  inout [`DATA_SIZE0:0] cond;
  reg [`DATA_SIZE0:0] cond_r_adr;
  reg [`DATA_SIZE0:0] cond_r;
  wire [`DATA_SIZE0:0] cond = cond_r;
  reg cond_waiting;
  reg condptr_waiting;
  reg condw_waiting;
*/
  
  input wire [`DATA_SIZE0:0] cmd_ptr;

  
//  input wire disp_online;
  
  output reg next_state;
  
  input wire rst;
  
  reg single;
  
  reg catched;
  

  always @(posedge clk) begin
    addr_r = 32'h zzzzzzzz;
    data_r = 32'h zzzzzzzz;
    
    is_bus_busy_r = 1'b z;
    
    
    next_state = 1'b z;
    
    
    halt_q_r = 1'bz;

//    rw_halt_r = 1'bz;
/**
    if(halt_q === 1) begin
      if(cpu_ind_rel == 2'b01) begin
      
        if(
          registerw_waiting == 1 
//          && rw_halt_r !== 1
//          && read_q_r !== 1 && write_q_r !== 1
        ) begin
//          if(isRegS1Ptr == 0) begin
            if(addr === (/ *base_addr +* / regNum)) begin
              rw_halt_r = 1'b 1;
            end else begin
              rw_halt_r = 1'b z;
            end
//            rw_halt_r = addr === (/ *base_addr +* / regNum) ? 1 : 1'bz;
//          end else begin
//            rw_halt_r = addr == register_r_adr ? 1 : 1'bz;
//          end
          //register_waiting = 0;
        end 

      end
    end
**/
        

//     $monitor("state=%b  nxt=%b  progr=%b S0ptr=%b",state,next_state,progress,isRegS0Ptr);

  if(rst == 1) begin
    read_q_r = 1'b z;
    write_q_r = 1'b z;

    //addr_r = 32'h zzzzzzzz;

//    next_state = 1'b z;
    
    register_r = 0; //32'h zzzzzzzz;
          register_r_ptr = 0;

   
    register_waiting = 0;
    registerptr_waiting = 0;
    registerw_waiting = 0;
    
    single = 0;
    
    catched = 0;
  end
//  else if(state == `ALU_RESULTS) begin
//    register_r = register;
//    
//    next_state = 1'b 1;
//  end
  else begin
     
//    next_state = 1'b z;

    read_q_r = 1'b z;
    write_q_r = 1'b z;
    
    
    if(disp_online == 0) single = 1;
    
    
//    if(is_bus_busy == 1) begin
      
        addr_r = `ADDR_SIZE'h zzzzzzzz;

/*        
        case(reg_op)
        
          `REG_OP_READ: begin
            if(read_dn == 1 && register_waiting == 1) begin
                if(addr === register_r_adr) begin
                  register_r = data;
                  register_waiting = 0;
                  next_state = 1;
                end
            end
          end
        
          `REG_OP_READ_P: begin
            if(read_dn == 1) begin
                if(addr === register_r) begin
                  register_r = data;
                  registerptr_waiting = 0;
                  next_state = 1;
                end
            end
          end

//          `WRITE_PREP: begin
//            next_state = 1;
//          end
           
          `REG_OP_WRITE: begin
            if(write_dn == 1 && addr === (/ *base_addr +* / regNum)) begin
              registerw_waiting = 0;
              next_state = 1;
            end
          end
           
//          `WRITE_SRC0: begin
//            if(write_dn == 1 && addr == (/ *base_addr +* / regNumS0)) begin
//              src0w_waiting = 0;
//              next_state = 1;
//            end
//          end
          
          endcase
*/
        

//    end else begin
      if(reg_op != `REG_OP_CATCH_DATA) catched = 0;
      
//      if(state == `ALU_BEGIN) begin
//        catched = 0;
//      end
     
      case(reg_op)
      
        `REG_OP_CATCH_DATA: begin
          if(catched == 0) begin
            register_r = state == `ALU_RESULTS ? register : reg_ptr;
            
            if(state != `ALU_RESULTS) begin
              register_r_ptr = reg_ptr;
            end
            catched = 1;
          end
            
          next_state = 1;
        end

        `REG_OP_PREEXECUTE: begin
//          dst_waiting = 1;
          //register_r_adr = /*base_addr +*/ regNum /* `DATA_SIZE*/;
                    
//          if(&regDFlags == 0) dstw_waiting = 1;
//          if(^regCondFlags == 1) condw_waiting = 1;
          if(
              ^regFlags == 1
              || isNeedSave == 1
          ) registerw_waiting = 1;
//          if(^regS0Flags == 1) src0w_waiting = 1;
          
          next_state = 1;
        end

        `REG_OP_READ: begin
            if(is_bus_busy == 1) begin
            
              if(read_dn == 1 && register_waiting == 1) begin
                  if(addr === register_r_adr) begin
                    register_r = data;
                    register_r_ptr = data;
                    /*if(! isDinamic )*/ register_waiting = 0;
                    next_state = 1;
                  end
              end
              
            end else begin
            
              if(rw_halt === 1) begin
                register_waiting = 0;
                single = 1;

                addr_r = `ADDR_SIZE'h zzzzzzzz;
                read_q_r = 1'bz;
              end else
              if(read_q_r === 1) begin
                addr_r = `ADDR_SIZE'h zzzzzzzz;
                read_q_r = 1'bz;
              end else 
              if(disp_online == 1 && single == 1) begin
                addr_r = register_r_adr;
                read_q_r = 1;
                halt_q_r = 1;
                
                if(^regFlags == 1) registerptr_waiting = 1;
                register_waiting = 1;
    
                single = 0;
              end
              
            end
        end
          
        `REG_OP_READ_P: begin
          if(is_bus_busy == 1) begin
            if(read_dn == 1 && registerptr_waiting == 1) begin
                if(addr === register_r_ptr) begin
//                  register_r_ptr = register_r;
                  register_r = data;
                  /*if(! isDinamic )*/ registerptr_waiting = 0;
                  next_state = 1;
                end
            end
          end else begin
          
            if(rw_halt === 1) begin
              registerptr_waiting = 0;
              single = 1;

              addr_r = `ADDR_SIZE'h zzzzzzzz;
              read_q_r = 1'bz;
            end else
            if(read_q_r === 1) begin
              addr_r = `ADDR_SIZE'h zzzzzzzz;
              read_q_r = 1'bz;
            end else
            if(disp_online == 1 && single == 1) begin
//              register_r_ptr = register_r;
              addr_r = register_r_ptr; //register_r; //cond_r_aux;
//              register_r_adr = register_r;
              read_q_r = 1;
              halt_q_r = 1;
              registerptr_waiting = 1;
              
              single = 0;
            end
          end
        end

        
        `REG_OP_WRITE_PREP: begin
//            dst_r = (regDFlags == 2'b 01 ? dst+1 : 
//                     regDFlags == 2'b 10 ? dst-1 : 
//                                           dst );
            
//            if(regNumCnd == regNumD) cond_r = dst_r;
//            if(regNumS1  == regNumD) register_r = dst_r;
//            if(regNumS0  == regNumD) src0_r = dst_r;

//            if(regCondFlags == 2'b 01) begin
//              cond_r = (isRegCondPtr==1 ? cond_r_adr : cond_r)+1;
//            end else if(regCondFlags == 2'b 10) begin
//              cond_r = (isRegCondPtr==1 ? cond_r_adr : cond_r)-1;
//            end

/**/
//            if(regFlags == 2'b 01) begin
/*
              register_r = (isRegPtr==1 ? register_r_ptr : register_r)+1;
            end else if(regFlags == 2'b 10) begin
              register_r = (isRegPtr==1 ? register_r_ptr : register_r)-1;
*/
//            end
/**/

//            if(regS0Flags == 2'b 01) begin
//              src0_r = (isRegS0Ptr==1 ? src0_r_adr : src0_r)+1;
//            end else if(regS0Flags == 2'b 10) begin
//              src0_r = (isRegS0Ptr==1 ? src0_r_adr : src0_r)-1;
//            end
            
            next_state = 1;
        end

        
        `REG_OP_WRITE, `REG_OP_WRITE_P: begin
          if(is_bus_busy == 1) begin
            if(
                write_dn == 1 && 
                addr === addr_to_save
            ) begin
              registerw_waiting = 0;
              next_state = 1;
            end
          end else begin
            if(write_q_r === 1) begin
              write_q_r = 1'bz;
            end else //if(write_dn == 0) 
            if(disp_online == 1 && single == 1) begin
              data_r = /*reg_op == `REG_OP_WRITE_P ?*/ data_post_inc_dec; // : register_r; //register_r;
              addr_r = addr_to_save;
              write_q_r = 1;
              
              single = 0;
              
              registerw_waiting = 1;
            end
          end
        end
                
//        `REG_OP_FINISH_BEGIN: begin
//          registerw_waiting = 0;
//        end

      endcase
      
//    end
    
  end
  
  end

  
endmodule

