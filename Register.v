

`include "sizes.v"
`include "states.v"
`include "misc_codes.v"



module RegisterManager (
            clk, 
				clk_oe,
            state,        // processor cicle state (in)
            
            base_addr,    // base addres of process (in)
            reg_op,      // reg op  (in)
            
            cpu_ind_rel,
            halt_q,
            rw_halt,
            want_write,
            
            is_bus_busy,
            addr_in,
            addr_out,
            data_in,
            data_out,
            
            register,
            reg_ptr,
            
            isRegPtr,
            regFlags,
            regNum,
            
            isNeedSave,
            isDinamic,
            isSaveAllowed,
            isSavePtrAllowed,
            
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
  
  
  input wire isRegPtr;  
  
  input wire [1:0] regFlags;
  
  input wire isNeedSave;
  
  input wire isDinamic;
  
  input wire isSaveAllowed;
  
  input wire isSavePtrAllowed;
  
  input wire [`ADDR_SIZE0:0] base_addr;
//  reg [`ADDR_SIZE0:0] base_addr_r;



  inout [`DATA_SIZE0:0] register;
  inout [`DATA_SIZE0:0] reg_ptr;
  wire [`DATA_SIZE0:0] register_r_adr = base_addr + regNum /* `DATA_SIZE*/;
  reg [`DATA_SIZE0:0] register_r_ptr;
  reg [`DATA_SIZE0:0] register_r;
  tri [`DATA_SIZE0:0] register = (reg_op == `REG_OP_CATCH_DATA) 
                                              ? `ADDR_SIZE'h zzzzzzzz
                                              : register_r
                                              ;  // tri or wire ??

  tri is_data_not_ptr_to_data = (isRegPtr == 0 && reg_op == `REG_OP_WRITE)
                                 || (isRegPtr == 1 && reg_op == `REG_OP_WRITE_P)
                                 ;
                                              
  tri [`DATA_SIZE0:0] data_to_save = ( is_data_not_ptr_to_data ) 
                                              ? register_r
                                              : register_r_ptr
                                              ;
// dst(reg:0, op:4, res:3(+)), src0(p:1, op:4, r:11h(+)), src0(p:1, op:4, r:11h(+))?, ip(p:1, op:6, r:12h(+))

  tri [`DATA_SIZE0:0] data_post_inc_dec = (reg_op == `REG_OP_WRITE_P)
                                           ? data_to_save
                                            : 
                                            (regFlags == 2'b 01) // && reg_op === `REG_OP_WRITE)
                                              ? data_to_save + 1
                                              : (regFlags == 2'b 10) // && reg_op === `REG_OP_WRITE)
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



  input [`ADDR_SIZE0:0] addr_in;
  output [`ADDR_SIZE0:0] addr_out;
  reg [`ADDR_SIZE0:0] addr_r;
  tri [`ADDR_SIZE0:0] addr_in;
  tri [`ADDR_SIZE0:0] addr_out  = (
                        reg_op == `REG_OP_READ ||
                        reg_op == `REG_OP_READ_P ||
                        reg_op == `REG_OP_WRITE ||
                        reg_op == `REG_OP_WRITE_P
                        ) &&
                        disp_online == 1 
//                        && (!ext_next_cpu_e == 1)
                        ? addr_r
                        : `ADDR_SIZE'h zzzz_zzzz_zzzz_zzzz
                        ;
  
  wire [`ADDR_SIZE0:0] addr_to_save = ((/*isRegPtr &&*/ reg_op == `REG_OP_WRITE_P) ? register_r_ptr : regNum) + base_addr;

 // dst(p:0, op:4, r:8(+)), src0(p:1, op:4, r:fh(+)), src0(p:1, op:4, r:fh(+))?, ip(p:1, op:6, 12:fh(-))

  input wire [1:0] cpu_ind_rel;
  inout halt_q;
  reg halt_q_r;
  tri halt_q = disp_online == 1 ? halt_q_r : 1'b z;
  
  inout rw_halt;
  reg rw_halt_r;
  tri rw_halt = rw_halt_r;
  
  tri rw_halt_stim =
              (
               halt_q === 1
               && cpu_ind_rel === 2'b01
               && (registerw_waiting == 1'b 1
                 && (
                   (/*reg_op == `REG_OP_READ*/ /*isRegPtr == 1 &&*/ addr_in === register_r_adr)
                   || (isRegPtr == 1 && isNeedSave == 1 && addr_in === register_r_ptr)
                 )
               )
              )
            ? 1'b 1
            : 1'b z
            ;
            
            
  inout want_write;
  reg want_write_r;
  tri want_write = disp_online == 1 ? want_write_r : 1'b z;

  
  output read_q;
  output write_q;

  reg read_q_r;
  reg write_q_r;

  tri read_q = read_q_r;
  tri write_q = write_q_r;

  inout is_bus_busy;
  reg is_bus_busy_r;
  tri is_bus_busy = is_bus_busy_r;
  
  input [`DATA_SIZE0:0] data_in;
  output [`DATA_SIZE0:0] data_out;
  reg [`DATA_SIZE0:0] data_r;
  tri [`DATA_SIZE0:0] data_in;
  tri [`DATA_SIZE0:0] data_out =  (
                                reg_op == `REG_OP_WRITE 
                                || reg_op == `REG_OP_WRITE_P
                                //&& write_q === 1'b 1 
                              ) &&
                                disp_online == 1 
                                        ? data_r
//                                        : (
//                                            reg_op == `REG_OP_OUT_TO_DATA 
//                                            && disp_online == 1
//                                          )
//                                            ? register_r
                                            : `DATA_SIZE'h zzzz_zzzz_zzzz_zzzz
                              ;
//  assign data = write_q==1 ? dst_r : 32'h z;
  
  input  wire read_dn;
  input  wire write_dn;
//  output reg read_e;
//  output reg write_e;
  
    
  input wire [`DATA_SIZE0:0] cmd_ptr;

  
//  input wire disp_online;
  
  output reg next_state;
  
  input wire rst;
  
  reg single;
  
  reg catched;
  
  reg isTopR;
  reg isTopP;
 
  input wire clk_oe; 

  always @(posedge clk) begin
  
//    clk_oe = ~clk_oe;
	 if(clk_oe == 0) begin
	 
//    addr_r = 32'h zzzzzzzz;
//    data_r = 32'h zzzzzzzz;
    
    is_bus_busy_r = 1'b z;
    
    
    next_state = 1'b z;
    
    
    halt_q_r = 1'bz;
    
    
    rw_halt_r = rw_halt_stim;
	 
    read_q_r = 1'b z;
    write_q_r = 1'b z;
    
        addr_r = `ADDR_SIZE'h zzzz_zzzz_zzzz_zzzz;
    
	 
//    if(rw_halt_stim === 1)
//    $display("%f) %m, regw_wt = %b, rw_hlt = %b", ($realtime/1000), registerw_waiting, rw_halt_stim);

//    rw_halt_r = 1'bz;


/*
  if(
    is_bus_busy == 1 &&
    write_dn == 1 && 
    addr === addr_to_save
  ) begin
      registerw_waiting = 0;
  end
*/
  
/*
  if
  (rw_halt === 1 && addr === 15)
//  (halt_q === 1 && cpu_ind_rel == 2'b01) 
  begin
            catched = catched & 1;
  end
*/

//     $monitor("state=%b  nxt=%b  progr=%b S0ptr=%b",state,next_state,progress,isRegS0Ptr);

  end else begin

  if(rst == 1) begin
    read_q_r = 1'b z;
    write_q_r = 1'b z;

    //addr_r = 32'h zzzzzzzz;

//    next_state = 1'b z;
    
    register_r = 0; //32'h zzzzzzzz;
          register_r_ptr = 0;

    data_r = 0;

			 
    register_waiting = 0;
    registerptr_waiting = 0;
    registerw_waiting = 0;
    
    single = 0;
    
    catched = 0;
    
    isTopR = 0;
    isTopP = 0;
    
    want_write_r = 1'b z;
	 
	 rw_halt_r = 1'b z;
  end
//  else if(state == `ALU_RESULTS) begin
//    register_r = register;
//    
//    next_state = 1'b 1;
//  end
  else begin
     
//    next_state = 1'b z;

//    read_q_r = 1'b z;
//    write_q_r = 1'b z;
//    
//        addr_r = `ADDR_SIZE'h zzzz_zzzz_zzzz_zzzz;
    
    if(disp_online == 0) single = 1;
    
          

      if(reg_op != `REG_OP_CATCH_DATA) catched = 0;
           
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
          //if(
          //    ^regFlags == 1
          //    || isNeedSave == 1
          //) begin
            registerw_waiting = isSaveAllowed;
          //end
//          if(^regS0Flags == 1) src0w_waiting = 1;
          
          next_state = 1;
        end

        `REG_OP_READ: begin
            if(is_bus_busy == 1) begin
            
              if(
                  (read_dn == 1 && register_waiting == 1) 
                  || (write_dn && register_waiting == 0 && isTopR == 1) 
              ) begin
                  if(addr_in === register_r_adr) begin
                    register_r = data_in;
                    register_r_ptr = data_in;
                    /*if(! isDinamic )*/ register_waiting = 0;
                    next_state = 1;
                    
                    want_write_r = 1'b z;
                  end
              end
              
            end else begin
            
              if(rw_halt === 1) begin
                register_waiting = 0;
                single = 1;

                addr_r = `ADDR_SIZE'h zzzz_zzzz_zzzz_zzzz;
                read_q_r = 1'bz;
                
                want_write_r = 1'b z;
                
                // VV thinking if it possible to make read in time of write
                if(cpu_ind_rel === 2'b10 && want_write === 1) begin
                  isTopR = 0;
                end else 
//                if(cpu_ind_rel === 2'b01) 
                begin
                  isTopR = 1;
//                  register_waiting = 1;
                end
                // AA
                
//                $display(cpu_ind_rel, ", ", isTopR);
              end else
              if(read_q_r === 1) begin
                addr_r = `ADDR_SIZE'h zzzz_zzzz_zzzz_zzzz;
                read_q_r = 1'bz;
              end else 
              if(disp_online == 1 && single == 1) begin
                addr_r = register_r_adr;
                read_q_r = 1;
                halt_q_r = 1;
                
                if(^regFlags == 1) registerptr_waiting = 1;
                register_waiting = 1;
                
                want_write_r = isSaveAllowed;
    
                single = 0;
              end
              
            end
        end
          
        `REG_OP_READ_P: begin
          if(is_bus_busy == 1) begin
            if(
                (read_dn == 1 && registerptr_waiting == 1)
                || (write_dn && registerptr_waiting == 0 && isTopP == 1) 
            ) begin
                if(addr_in === register_r_ptr + base_addr) begin
//                  register_r_ptr = register_r;
                  register_r = data_in;
                  /*if(! isDinamic )*/ registerptr_waiting = 0;
                  next_state = 1;
                  
                  want_write_r = 1'b z;
                end
            end
          end else begin
          
            if(rw_halt === 1) begin
              registerptr_waiting = 0;
              single = 1;

              addr_r = `ADDR_SIZE'h zzzz_zzzz_zzzz_zzzz;
              read_q_r = 1'bz;
              
              want_write_r = 1'b z;
                
              // VV thinking if it possible to make read in time of write
              if(cpu_ind_rel === 2'b10 && want_write === 1) begin
                isTopP = 0;
              end else 
//              if(cpu_ind_rel === 2'b01) 
              begin
                isTopP = 1;
//                register_waiting = 1;
              end
                // AA
            end else
            if(read_q_r === 1) begin
              addr_r = `ADDR_SIZE'h zzzz_zzzz_zzzz_zzzz;
              read_q_r = 1'bz;
            end else
            if(disp_online == 1 && single == 1) begin
//              register_r_ptr = register_r;
              addr_r = register_r_ptr + base_addr; //register_r; //cond_r_aux;
//              register_r_adr = register_r;
              read_q_r = 1;
              halt_q_r = 1;
              registerptr_waiting = 1;
              
              want_write_r = isSavePtrAllowed;
    
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
            
            registerw_waiting = isSaveAllowed;

            next_state = 1;
        end

        
        `REG_OP_WRITE, `REG_OP_WRITE_P: begin
          if(is_bus_busy == 1) begin
            if(
                write_dn == 1 && 
                addr_in === addr_to_save
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
              
//              registerw_waiting = 1;
              
              single = 0;
            end
          end
        end
                
//        `REG_OP_FINISH_BEGIN: begin
//          registerw_waiting = 0;
//        end

      endcase
      
//    end
    
  end
  
  end //clk_oe
  
  
  end

  
endmodule

