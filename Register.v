

`include "sizes.v"
`include "states.v"
`include "misc_codes.v"



module RegisterManager (
            clk, 
				clk_oe,
            state,        // processor cicle state (in)
            
            base_addr,    // base addres of process (in)
				base_addr_data,
				
				addr_unmodificable_b,
				
				mem1sz,
				
            reg_op,      // reg op  (in)
            
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
            
            register_in,
            register_out,
            reg_ptr_in,
            reg_ptr_out,
            
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

            is_read,
				is_read_ptr,
				
				no_data_new,
				no_data_tick,
				
            cmd_ptr,
            
            disp_online,
            
            next_state,
            
            rst
            );
            
  input wire disp_online;
            
            
  input wire clk;
  input wire [`STATE_SIZE0:0] state;
  input wire [`SIZE_REG_OP-1:0] reg_op;

  input wire [`CMD_BITS_PER_REG0:0] regNum;
  
  
  input wire isRegPtr;  
  
  input wire [1:0] regFlags;
  
  input wire isNeedSave;
  
  input wire isDinamic;
  
  input wire isSaveAllowed;
  
  input wire isSavePtrAllowed;
  
  input wire [`ADDR_SIZE0:0] base_addr;
  input wire [`ADDR_SIZE0:0] base_addr_data;
  
  input wire [`ADDR_SIZE0:0] addr_unmodificable_b;
  
  input wire [`DATA_SIZE0:0] mem1sz;
//  reg [`ADDR_SIZE0:0] base_addr_r;



  input wire [`DATA_SIZE0:0] register_in;
  output [`DATA_SIZE0:0] register_out;
  input wire [`DATA_SIZE0:0] reg_ptr_in;
  output [`DATA_SIZE0:0] reg_ptr_out;
  wire [`DATA_SIZE0:0] register_r_adr = base_addr_data + regNum; //base_addr + regNum /* `DATA_SIZE*/;
  reg [`DATA_SIZE0:0] register_r_ptr;
  reg [`DATA_SIZE0:0] register_r;
  wire [`DATA_SIZE0:0] register_out = //(reg_op == `REG_OP_CATCH_DATA) 
//                                              ? `ADDR_SIZE'h zzzz_zzzz_zzzz_zzzz
//                                              : 
															 register_r
                                              ;  // tri or wire ??

  wire is_data_not_ptr_to_data = (isRegPtr == 0 && reg_op == `REG_OP_WRITE)
                                 || (isRegPtr == 1 && reg_op == `REG_OP_WRITE_P)
                                 ;
                       
  wire [`DATA_SIZE0:0] data_to_save = ( is_data_not_ptr_to_data ) 
                                              ? register_r
                                              : register_r_ptr
                                              ;
// dst(reg:0, op:4, res:3(+)), src0(p:1, op:4, r:11h(+)), src0(p:1, op:4, r:11h(+))?, ip(p:1, op:6, r:12h(+))

  wire [`DATA_SIZE0:0] data_post_inc_dec = (reg_op == `REG_OP_WRITE_P)
                                           ? data_to_save
                                            : 
                                            (regFlags == 2'b 01) // && reg_op === `REG_OP_WRITE)
                                              ? data_to_save + 1
                                              : (regFlags == 2'b 10) // && reg_op === `REG_OP_WRITE)
                                                  ? data_to_save - 1
                                                  : data_to_save
                                              ;


  wire [`DATA_SIZE0:0] reg_ptr_out = //(reg_op == `REG_OP_CATCH_DATA) 
//                                              ? `ADDR_SIZE'h zzzzzzzz
//                                              : 
															 data_post_inc_dec
                                              ;  // tri or wire ??
                                              
  
  reg register_waiting;
  reg registerptr_waiting;
  reg registerw_waiting;
  
  output is_read;
  reg is_read_r;
  wire is_read = is_read_r;
  
  output is_read_ptr;
  reg is_read_ptr_r;
  wire is_read_ptr = is_read_ptr_r;


 
  reg addr_out_pulse;

  input [`ADDR_SIZE0:0] addr_in;
  output [`ADDR_SIZE0:0] addr_out;
  reg [`ADDR_SIZE0:0] addr_r;
  wire [`ADDR_SIZE0:0] addr_in;
  wire [`ADDR_SIZE0:0] addr_out  = 
/**
                        (
                        reg_op == `REG_OP_READ ||
                        reg_op == `REG_OP_READ_P ||
                        reg_op == `REG_OP_WRITE ||
                        reg_op == `REG_OP_WRITE_P
                        ) &&
                        disp_online == 1 
//                        && (!ext_next_cpu_e == 1)
/**/
                        addr_out_pulse == 1
                        ? addr_r
                        : 0 //`ADDR_SIZE'h zzzz_zzzz_zzzz_zzzz
                        ;
  
  wire [`ADDR_SIZE0:0] addr_to_save_without_base = 
                             (/*isRegPtr &&*/ reg_op == `REG_OP_WRITE_P) 
									  ? register_r_ptr 
									  : regNum
									  ;
									  
  wire [`ADDR_SIZE0:0] addr_to_save = 
//                             ((/*isRegPtr &&*/ reg_op == `REG_OP_WRITE_P) ? register_r_ptr : regNum) 
                             addr_to_save_without_base +
									  (
									    addr_to_save_without_base >= addr_unmodificable_b
										 ? 0 
									    : (
										     addr_to_save_without_base >= mem1sz 
											  ? base_addr_data 
											  : base_addr
											)
									  )
									  ;

  wire [`ADDR_SIZE0:0] base_addr_to_read_ptr = 
									    register_r_ptr >= addr_unmodificable_b
										 ? 0 
									    : (
										     register_r_ptr >= mem1sz 
											  ? base_addr_data 
											  : base_addr
											)
									  ;

 // dst(p:0, op:4, r:8(+)), src0(p:1, op:4, r:fh(+)), src0(p:1, op:4, r:fh(+))?, ip(p:1, op:6, 12:fh(-))

  input wire [1:0] cpu_ind_rel;
  input halt_q_in;
  output halt_q_out;
  reg halt_q_r;
  wire halt_q_out = disp_online == 1 ? halt_q_r : 1'b 0; //z;
  
  input rw_halt_in;
  output rw_halt_out;
  reg rw_halt_r;
  wire rw_halt_out = rw_halt_r;
  
  wire rw_halt_stim =
              (
               halt_q_in == 1
               && cpu_ind_rel == 2'b01
               && (registerw_waiting == 1'b 1
                 && (
                   (/*reg_op == `REG_OP_READ*/ /*isRegPtr == 1 &&*/ addr_in == register_r_adr)
                   || (isRegPtr == 1 && isNeedSave == 1 && addr_in == register_r_ptr)
                 )
               )
              )
//            ? 1'b 1
//            : 1'b 0 //z
            ;
            
            
  input want_write_in;
  output want_write_out;
  reg want_write_r;
  reg want_write_ptr_r;
  wire want_write_out = want_write_r | want_write_ptr_r; //disp_online == 1 ? want_write_r : 1'b z;
  wire want_write_in; // = want_write_r;

  
  output read_q;
  output write_q;

  reg read_q_r;
  reg write_q_r;

  wire read_q = disp_online == 1 ? read_q_r : 0;
  wire write_q = disp_online == 1 ? write_q_r : 0;

  input is_bus_busy;
//  reg is_bus_busy_r;
  wire is_bus_busy; // = is_bus_busy_r;
  
  input [`DATA_SIZE0:0] data_in;
  output [`DATA_SIZE0:0] data_out;
  reg [`DATA_SIZE0:0] data_r;
  wire [`DATA_SIZE0:0] data_in;
  wire [`DATA_SIZE0:0] data_out =  
/**
                              (
                                reg_op == `REG_OP_WRITE 
                                || reg_op == `REG_OP_WRITE_P
                                //&& write_q === 1'b 1 
                              ) &&
                                disp_online == 1 
/**/
                              addr_out_pulse == 1
                              ? data_r
//                                        : (
//                                            reg_op == `REG_OP_OUT_TO_DATA 
//                                            && disp_online == 1
//                                          )
//                                            ? register_r
                              : 0
                              ;
//  assign data = write_q==1 ? dst_r : 32'h z;
  
  input  wire read_dn;
  input  wire write_dn;
//  output reg read_e;
//  output reg write_e;
  
    
  input wire [`DATA_SIZE0:0] cmd_ptr;

  
//  input wire disp_online;
  
  output next_state;
  reg next_state_r;
  wire next_state = next_state_r;
  
  input wire rst;
  
  reg single;
  
  reg catched;
  
  reg isTopR;
  reg isTopP;
 
  input wire clk_oe; 
  
  reg is_can_read;
  
  
  output reg no_data_new;
  output reg no_data_tick;
  
  reg first_read;
  reg first_read_p;
  reg first_write_p;
  

  always @(posedge clk) begin
  
	 if(clk_oe == 0) begin
	     
	 
	   is_can_read <= ~(want_write_in ^ (want_write_r | want_write_ptr_r));
	 
    
      next_state_r <= 1'b 0;
        
      rw_halt_r <= rw_halt_stim;
		
		no_data_new <= 0;
		no_data_tick <= 0;

      if(disp_online == 0) begin single <= 1; end 

      if(reg_op != `REG_OP_CATCH_DATA) begin catched <= 0; end
		

  end else begin

  if(rst == 1) begin
    read_q_r <= 1'b 0; //z;
    write_q_r <= 1'b 0; //z;

    next_state_r <= 1'b 0;
    
    register_r <= 0; //32'h zzzzzzzz;
    register_r_ptr <= 0;

    data_r <= 0;

			 
    register_waiting <= 0;
    registerptr_waiting <= 0;
    registerw_waiting <= 0;
    
    single <= 0;
    
    catched <= 0;
    
    isTopR <= 0;
    isTopP <= 0;
    
    want_write_r <= 1'b 0; //z;
    want_write_ptr_r <= 1'b 0; //z;
	 
	 rw_halt_r <= 1'b 0; //z;
	 
	 is_read_r <= 0;
	 is_read_ptr_r <= 0;
	 
	 addr_out_pulse <= 0;

		no_data_new <= 0;
		no_data_tick <= 0;
		
		first_read <= 0;
		first_read_p <= 0;
		first_write_p <= 0;
	 
  end
//  else if(state == `ALU_RESULTS) begin
//    register_r <= register;
//    
//    next_state_r <= 1'b 1;
//  end
  else begin

//!!!  rw_halt_r <= rw_halt_stim;

// test!  halt_q_r <= 0;
  
//    read_q_r <= 1'b 0; //z;
//    write_q_r <= 1'b 0; //z;

  
//    next_state_r <= 1'b z;

//    read_q_r <= 1'b z;
//    write_q_r <= 1'b z;
//    
//        addr_r <= `ADDR_SIZE'h zzzz_zzzz_zzzz_zzzz;
    
      //!!! if(disp_online == 0) single <= 1;    

      //!!! if(reg_op != `REG_OP_CATCH_DATA) catched <= 0;
           
      case(reg_op)
      
        `REG_OP_CATCH_DATA: begin
		    halt_q_r <= 0;
			 
          if(catched == 0) begin
            register_r <= state == `ALU_RESULTS ? register_in : reg_ptr_in;
				is_read_r <= 1;
            
            if(state != `ALU_RESULTS) begin
              register_r_ptr <= reg_ptr_in;
				  is_read_ptr_r <= 1;
            end
            catched <= 1;
          end
            
          next_state_r <= 1;
        end

        `REG_OP_PREEXECUTE: begin
		    halt_q_r <= 0;
			 
//          dst_waiting <= 1;
          //register_r_adr <= /*base_addr +*/ regNum /* `DATA_SIZE*/;
                    
//          if(&regDFlags == 0) dstw_waiting <= 1;
//          if(^regCondFlags == 1) condw_waiting <= 1;
          //if(
          //    ^regFlags == 1
          //    || isNeedSave == 1
          //) begin
            registerw_waiting <= isSaveAllowed;
          //end
//          if(^regS0Flags == 1) src0w_waiting <= 1;

		    first_read <= 1;
		    first_read_p <= 1;
			 first_write_p <= 1;
          
          next_state_r <= 1;
        end

        `REG_OP_READ: begin
            if(is_bus_busy == 1) begin
              addr_out_pulse <= 0;
           
              if(
                  (read_dn == 1 /**/&& register_waiting == 1/**/ && is_can_read == 1 /*(want_write_in ^ want_write_r) == 0*/) 
                  || (write_dn == 1 && register_waiting == 0 && isTopR == 1) 
              ) begin
                  if(addr_in == register_r_adr) begin
                    register_r <= data_in;
                    register_r_ptr <= data_in;
                    /*if(! isDinamic )*/ register_waiting <= 0;
                    next_state_r <= 1;
						  
						  is_read_r <= 1;
						  
						  halt_q_r <= 0;
						  
                    want_write_r <= 1'b 0; //z;
                  end
              end
            
            end else begin // if(is_bus_busy === 1)
            
/**/
              if(rw_halt_in == 1) begin
                register_waiting <= 0;
                single <= 1;

                addr_r <= 0; 
                read_q_r <= 1'b 0; //z;
					 
					 addr_out_pulse <= 0;

                want_write_r <= 1'b 0; //z;
                
                // VV thinking if it possible to make read in time of write
                if(cpu_ind_rel == 2'b10 && (want_write_in == 1 /* || want_write_r == 1 */) ) begin
                  isTopR <= 0;
                end else 
//                if(cpu_ind_rel === 2'b01) 
                begin
                  isTopR <= 1;
//                  register_waiting <= 1;
                end
                // AA
                
					 halt_q_r <= 0;
					 
					 if(register_waiting == 1'b 1) begin
					   no_data_tick <= 1;
					 end
//                $display(cpu_ind_rel, ", ", isTopR);
              end else 
/**/
				  begin
                if(read_q_r == 1) begin
                  addr_r <= 0; 
                  read_q_r <= 1'b 0; //z;
						
						addr_out_pulse <= 0;
						
						halt_q_r <= 0;
//		want_write_r <= 0; //!!!
                end else
//					 begin 
                  if(disp_online == 1 /**/&& single == 1/**/) begin
                    addr_r <= register_r_adr;
						  data_r <= 0;
						  
						  if(first_read == 1'b 1) begin
						    no_data_new <= 1;
							 
							 first_read <= 1'b 0;
						  end
						  
                    read_q_r <= 1;
                    halt_q_r <= 1;
						  
                    addr_out_pulse <= 1;
                
                    if(^regFlags == 1) registerptr_waiting <= 1;

                    register_waiting <= 1;
                
                    want_write_r <= isSaveAllowed;
    
                    single <= 0;
		            end
						else begin
						  halt_q_r <= 0;
						  addr_out_pulse <= 0;
                end // if(read_q_r !=/== 1)
              end // if(rw_halt !=/== 1) 
              
            end
        end
        
        `REG_OP_READ_P: begin
          if(is_bus_busy == 1) begin
            addr_out_pulse <= 0;
						
            if(
                (read_dn == 1 && registerptr_waiting == 1 && is_can_read == 1 /*(want_write_in ^ want_write_r) == 0*/)
                || (write_dn == 1 && registerptr_waiting == 0 && isTopP == 1) 
            ) begin
                if(addr_in == (register_r_ptr + base_addr_to_read_ptr) ) begin
//                  register_r_ptr <= register_r;
                  register_r <= data_in;
                  /*if(! isDinamic )*/ registerptr_waiting <= 0;
                  next_state_r <= 1;
						
						is_read_ptr_r <= 1;
						
						halt_q_r <= 0;
                  
                  want_write_ptr_r <= 1'b 0; //z;
                end
            end
			 
          end else begin
          
            if(rw_halt_in == 1) begin
              registerptr_waiting <= 0;
              single <= 1;

              addr_r <= 0; 
              read_q_r <= 1'b 0; //z;
				  
				  addr_out_pulse <= 0;
              
              want_write_ptr_r <= 1'b 0; //z;

              // VV thinking if it possible to make read in time of write
              if(cpu_ind_rel == 2'b10 && (want_write_in == 1 /* || want_write_r == 1 */) ) begin
                isTopP <= 0;
              end else 
//              if(cpu_ind_rel === 2'b01) 
              begin
                isTopP <= 1;
//                register_waiting <= 1;
              end
                // AA
					 
				  halt_q_r <= 0;
				  
				  if(registerptr_waiting == 1'b 1) begin
				    no_data_tick <= 1;
				  end
				  
            end else
            if(read_q_r == 1) begin
              addr_r <= 0; 
              read_q_r <= 1'b 0; 
				  
				  addr_out_pulse <= 0;
				  
				  halt_q_r <= 0;
//		want_write_r <= 0; //!!!
            end else
            if(disp_online == 1 && single == 1) begin
//              register_r_ptr <= register_r;
              addr_r <= register_r_ptr + base_addr_to_read_ptr; //register_r; //cond_r_aux;
				  data_r <= 0;
				  
				  if(first_read_p == 1'b 1) begin
				    no_data_new <= 1;
				  
				    first_read_p <= 1'b 0;
              end
				  
//              register_r_adr <= register_r;
              read_q_r <= 1;
              halt_q_r <= 1;
              registerptr_waiting <= 1;
				  
				  addr_out_pulse <= 1;
              
              want_write_ptr_r <= isSavePtrAllowed;
    
              single <= 0;
            end
				else begin
				  halt_q_r <= 0;
				  addr_out_pulse <= 0;
				end
          end
        end

        
        `REG_OP_WRITE_PREP: begin
//            dst_r <= (regDFlags == 2'b 01 ? dst+1 : 
//                     regDFlags == 2'b 10 ? dst-1 : 
//                                           dst );
            
//            if(regNumCnd == regNumD) cond_r <= dst_r;
//            if(regNumS1  == regNumD) register_r <= dst_r;
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
            
				halt_q_r <= 0;
				
            registerw_waiting <= isSaveAllowed;

            next_state_r <= 1;
        end

        
        `REG_OP_WRITE, `REG_OP_WRITE_P: begin
//		    if(is_read_r == 0 /*&& reg_op == `REG_OP_WRITE*/) begin
//			   next_state_r <= 1;
//			 end else
          if(is_bus_busy == 1) begin
			   halt_q_r <= 0;
				
				addr_out_pulse <= 0;
				
            if(
                write_dn == 1 && 
                addr_in == addr_to_save
            ) begin
              registerw_waiting <= 0;
              next_state_r <= 1;
				  
				  if(reg_op == `REG_OP_WRITE) begin //!! VV
				    want_write_r <= 0;
				  end else begin
				    want_write_ptr_r <= 0; 
				  end                               //!! AA
				  
            end
          end else begin
			   halt_q_r <= 0;
				
			   if(rw_halt_in == 1) begin //!! VV
				  addr_r <= 0;
				  data_r <= 0;
				  
				  addr_out_pulse <= 0;
				  
//				  halt_q_r <= 0;
				  
				  //if(registerw_waiting == 1) begin
				  //  no_data_tick <= 1;
				  //end
				  
              write_q_r <= 1'b 0; //z;
				end else                  //!! AA
            if(write_q_r == 1) begin
				  addr_r <= 0;    //!! VV
				  data_r <= 0;
				  
				  addr_out_pulse <= 0;
				  
//				  halt_q_r <= 0;  //!! AA
				  
              write_q_r <= 1'b 0; //z;
            end else //if(write_dn == 0) 
            if(disp_online == 1 && single == 1) begin
              data_r <= /*reg_op == `REG_OP_WRITE_P ?*/ data_post_inc_dec; // : register_r; //register_r;
              addr_r <= addr_to_save;
              write_q_r <= 1;
				  
				  addr_out_pulse <= 1;
				  
				  if(first_write_p == 1 && reg_op == `REG_OP_WRITE_P) begin
				    no_data_new <= 1;
					 first_write_p <= 0;

                registerw_waiting <= isSaveAllowed;
				  end
				  
//				  halt_q_r <= 0;
//				  halt_q_r <= 1; //!!
              
//              registerw_waiting <= 1;
              
              single <= 0;
            end else begin
				  addr_out_pulse <= 0;
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

