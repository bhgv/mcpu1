
`include "sizes.v"
`include "states.v"


module StateManager(
            clk,
                clk_oe,

            state,

            command,

            cond,

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

                no_data_exit_and_wait_begin,

                thread_escape,
                chan_escape,

                chan_op,
                chan_wait_next_time,

    regNumS1,
    regNumS0,
    regNumD,
    regNumCnd,
    isRegS1Ptr,
    isRegS0Ptr,
    isRegDPtr,
    isRegCondPtr,
    regS1Flags,
    regS0Flags,
    regDFlags,
    regCondFlags,
    cmd,
    isCond,
    isCondTrue,

            rst
            );
  input wire clk_oe;

  input wire clk;
  output reg [`STATE_SIZE0:0] state;
  //reg [`STATE_SIZE0:0] state_old;

  input wire no_data_exit_and_wait_begin;
  //reg no_data_exit_way;
  //wire [`STATE_SIZE0:0] no_data_exit_nxt_state_after_msg =
  //                                   (no_data_exit_way == 1'b 1)
  //                                   ? `AFTER_MEM_SIZE_READ
  //                                   : `FINISH_BEGIN
  //                                   ;

  input wire thread_escape;
  input wire chan_escape;

  input wire chan_op;
  input wire chan_wait_next_time;

  input wire [31:0] command;  

/**/
  input wire [`CMD_BITS_PER_REG0:0] regNumS1;
  //assign regNumS1 = command[3:0];

  input wire [`CMD_BITS_PER_REG0:0] regNumS0;
  //assign regNumS0 = command[7:4];

  input wire [`CMD_BITS_PER_REG0:0] regNumD;
  //assign regNumD = command[11:8];

  input wire [`CMD_BITS_PER_REG0:0] regNumCnd;
  //assign regNumCnd = command[15:12];

  input wire isRegS1Ptr;
  //assign isRegS1Ptr = command[16];

  input wire isRegS0Ptr;
  //assign isRegS0Ptr = command[17];

  input wire isRegDPtr;
  //assign isRegDPtr = command[18];

  input wire isRegCondPtr;
  //assign isRegCondPtr = command[19];

  input wire [1:0] regS1Flags;
  //assign regS1Flags = command[21:20];

  input wire [1:0] regS0Flags;
  //assign regS0Flags = command[23:22];

  input wire [1:0] regDFlags;
  //assign regDFlags = command[25:24];

  input wire [1:0] regCondFlags;
  //assign regCondFlags = command[27:26];

  input wire [`CMD_BITS_PER_CMD_CODE0:0] cmd; // = command[31:28];
  /**/

  input wire isCond;
  input wire isCondTrue;

/**
 CommandWordParse cmd_wd_prc_2 (
    .command_word(command),
    .regNumS1(regNumS1),
    .regNumS0(regNumS0),
    .regNumD(regNumD),
    .regNumCnd(regNumCnd),
    .isRegS1Ptr(isRegS1Ptr),
    .isRegS0Ptr(isRegS0Ptr),
    .isRegDPtr(isRegDPtr),
    .isRegCondPtr(isRegCondPtr),
    .regS1Flags(regS1Flags),
    .regS0Flags(regS0Flags),
    .regDFlags(regDFlags),
    .regCondFlags(regCondFlags),
    .isCond(isCond),
    .isCondTrue(isCondTrue),
    .cmd_code(cmd)
    );
**/

  reg isCmdChanOp;

  input wire [`DATA_SIZE0:0] cond;

  input wire next_state;

  output next_state_dn;
  reg next_state_dn_r;
  wire next_state_dn = next_state_dn_r;

  input wire rst;

  wire isCondDontExecCmd =
  	isCond == 1 &&
  	&regCondFlags == 0 &&
  	(
  		(isCondTrue == 1 && cond == 0) ||
  		(isCondTrue == 0 && cond != 0) 
  	);

  output isDSaveAllowed;
  wire isDSaveAllowed = (
             &regDFlags == 1'b 0 &&
//            (regNumCnd != regNumD || ^regCondFlags == 0) &&
//            (regNumS1  != regNumD || ^regS1Flags == 0) &&
//            (regNumS0  != regNumD || ^regS0Flags == 0) &&
             ~isCondDontExecCmd
/* //{}
            ( 
                    isCond == 0 ||
                    &regCondFlags == 1 ||
                    (isCondTrue == 1 && |cond == 1) ||
                    (isCondTrue == 0 && |cond == 0) 
                )    
*/
          )
          ;
  output isDSavePtrAllowed;
  wire isDSavePtrAllowed = (
             &regDFlags != 1'b 0 &&
//            (regNumCnd != regNumD || ^regCondFlags == 0) &&
//            (regNumS1  != regNumD || ^regS1Flags == 0) &&
//            (regNumS0  != regNumD || ^regS0Flags == 0) &&
            isRegDPtr == 1'b 1 &&
            ( 
                    isCond == 0 ||
                    &regCondFlags == 1 ||
                    (isCondTrue == 1 && |cond == 1) ||
                    (isCondTrue == 0 && |cond == 0) 
                )    
          )
          ;


  output isIpSaveAllowed;
  wire isIpSaveAllowed = ~(
            (regNumD == `REG_IP && isDSaveAllowed) ||
            (^regCondFlags && regNumCnd == `REG_IP) ||
            (^regS1Flags && regNumS1 == `REG_IP) ||
            (^regS0Flags && regNumS0 == `REG_IP)
          ) 
//             || no_data_exit_and_wait_begin == 1'b 1
          ;


  output isCndSaveAllowed;
  wire isCndSaveAllowed = (
                (
                    (isCond == 0 && &regCondFlags == 0) ||
                    ^regCondFlags == 1 
                ) && 
            (regNumD   != regNumCnd || ~isDSaveAllowed) &&
            (regNumS1  != regNumCnd || ^regS1Flags == 0) &&
            (regNumS0  != regNumCnd || ^regS0Flags == 0)
          )
          ;
  output isCndSavePtrAllowed;
  wire isCndSavePtrAllowed = 
             (isCond == 0 && &regCondFlags == 0) &&
             isRegCondPtr == 1
             ;

  output isS1SaveAllowed;
  wire isS1SaveAllowed = (
            ^regS1Flags == 1 && 
            (regNumD   != regNumS1 || ~isDSaveAllowed) &&
            (regNumS0  != regNumS1 || ^regS0Flags == 0)
          )
          ;
  output isS1SavePtrAllowed ;
  wire isS1SavePtrAllowed = 0 ;

  output isS0SaveAllowed;
  wire isS0SaveAllowed = (
            ^regS0Flags == 1 &&
            (regNumD   != regNumS0 || ~isDSaveAllowed)
          )
          ;
  output isS0SavePtrAllowed;
  wire isS0SavePtrAllowed = 0 ;

  input wire 
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

  reg anti_continuous;

  reg condIsReaden;
  reg ipIsWriten;

  reg isChanAlu;

  //reg anyIsWriten;

/**
  wire isCndFillS1 = (&regCondFlags == 0 && regNumS1 == regNumCnd && is_cnd_read);
  wire isCndFillS0 = (&regCondFlags == 0 && regNumS0 == regNumCnd && is_cnd_read);
  wire isS1FillS0  = (&regS1Flags == 0 && regNumS0 == regNumS1 && is_s1_read);
  wire isCndFillD  = (&regCondFlags == 0 && regNumD == regNumCnd && is_cnd_read);
  wire isS1FillD   = (&regS1Flags == 0 && regNumD == regNumS1 && is_s1_read);
  wire isS0FillD   = (&regS0Flags == 0 && regNumD == regNumS0 && is_s0_read);
/**/



  always @( posedge next_state or posedge rst 
            //or posedge thread_escape 
                //or posedge no_data_exit_and_wait_begin
  ) begin //negedge clk) begin //

    if( rst == 1'b 1 ) begin
      state <= `WAIT_FOR_START;

      condIsReaden <= 0;
      ipIsWriten <= 0;

        //anyIsWriten <= 0;

      anti_continuous <= 1;

        //no_data_exit_way <= 1;

        isCmdChanOp <= 0;

        next_state_dn_r <= 0;

        isChanAlu <= 0;
    end
//    else if(next_state != 1) begin
//      anti_continuous = 1;
//    end
    else 
     /**
     if(
//      next_state == 1 && 
      (
//        anti_continuous == 1
//        || 
          state == `WAIT_FOR_START
        || state == `PREEXECUTE
        || state == `START_BEGIN
        || state == `ALU_BEGIN
        || state == `ALU_RESULTS
        || state == `WRITE_PREP
        || state == `FILL_COND
        || state == `FILL_SRC1
        || state == `FILL_SRC0
      )
    ) 
     /**/
     begin

      /*
      if(
        state == `WAIT_FOR_START
        || state == `START_BEGIN
        || state == `ALU_BEGIN
      ) begin
        anti_continuous = 1;
      end else begin
        anti_continuous = 0;
      end
      */
//        anti_continuous = 0;

/**/

/**/
`ifdef PAUSE_OR_CHAN_OP_TAIL_CUTOFF_ENABLE
    if(thread_escape == 1'b 1 && ipIsWriten == 1'b 0 && (isChanAlu == 1'b 0 || chan_escape == 1'b 1) /*&& anyIsWriten == 0*/) begin
       case(state)

/**
          `WAIT_FOR_START: begin
//           state <= state + 1;
            next_state_dn_r <= ~next_state_dn_r;
          end
/**/

          `WAIT_FOR_START,
          `FINISH_BEGIN,
          `FINISH_END
          : begin
           state <= state + 1;
            next_state_dn_r <= ~next_state_dn_r;
          end

/**
          //`FINISH_BEGIN,
          `FINISH_END
          : begin
           //state <= state + 1;
            next_state_dn_r <= ~next_state_dn_r;
          end
/**/

          default: begin
           state <= `FINISH_BEGIN;
            next_state_dn_r <= ~next_state_dn_r;
          end

        endcase
     end else
/**/
`ifdef PAUSE_PROC_ENABLE
    if(no_data_exit_and_wait_begin == 1'b 1) begin
       case(state)
//          `START_READ_CMD_P,
//          `READ_COND,
//          `READ_COND_P,
          `READ_SRC1,
          `READ_SRC1_P,
          `READ_SRC0,
          `READ_SRC0_P,
          `READ_DST,
          `READ_DST_P//,
//          `WRITE_DST_P //, 
          //`ALU_BEGIN,
          //`ALU_RESULTS
          : begin
            //no_data_exit_way <= 1'b 1;
            state <= `BREAK_THREAD_SAVE_IP_AND_WAIT; //`BREAK_THREAD_EXIT_AND_WAIT; //
             next_state_dn_r <= ~next_state_dn_r;
        end

        //`WAIT_FOR_START,
        //`START_BEGIN,
          `START_READ_CMD_P,
          `READ_COND,
          `READ_COND_P,
          `READ_MEM_SIZE_1,
          `START_READ_CMD
          : begin
            //no_data_exit_way <= 1'b 0;
            state <= `BREAK_THREAD_EXIT_AND_WAIT; //`BREAK_THREAD_SAVE_IP_AND_WAIT; //
             next_state_dn_r <= ~next_state_dn_r;
        end

          `BREAK_THREAD_SAVE_IP_AND_WAIT: begin
          state <= `AFTER_MEM_SIZE_READ;
             next_state_dn_r <= ~next_state_dn_r;
          end

          /**/
          `BREAK_THREAD_EXIT_AND_WAIT: begin
          state <= `AUX_PRE_FINISH_BEGIN;
             next_state_dn_r <= ~next_state_dn_r;
          end
          /**/

        `AFTER_MEM_SIZE_READ: begin
//            if(thread_escape == 1)
//               state <= `FINISH_BEGIN;
//             else
          //if(no_data_exit_way == 1) begin
               state <= `WRITE_REG_IP;
          //end else begin
          //  state <= `WRITE_REG_IP; //`FINISH_BEGIN;
          //end
          next_state_dn_r <= ~next_state_dn_r;
        end

        `WRITE_REG_IP: begin
          state <= `FINISH_BEGIN;
          next_state_dn_r <= ~next_state_dn_r;
        end

        `AUX_PRE_FINISH_BEGIN: begin
          state <= `FINISH_BEGIN;
          next_state_dn_r <= ~next_state_dn_r;
        end

/**
          `FINISH_BEGIN: begin
          state <= state + 1;

             next_state_dn_r <= ~next_state_dn_r;
        end
/**/

        default: begin
//            if(thread_escape == 1)
//               state <= `FINISH_BEGIN;
//             else
          state <= state + 1;
          next_state_dn_r <= ~next_state_dn_r;
        end

      endcase
    end else 
`endif
`endif // ifdef PAUSE_OR_CHAN_OP_TAIL_CUTOFF_ENABLE

/**/
//     begin

      case(state)
/**
        `START_READ_CMD: begin
          if(
            (&regDFlags == 0 && regNumD == 4'h f) ||
            (^regCondFlags && regNumCnd == 4'h f) ||
            (^regS1Flags && regNumS1 == 4'h f) ||
            (^regS0Flags && regNumS0 == 4'h f)
          ) begin
              state = `START_READ_CMD_P;
          end else begin
            state = `WRITE_REG_IP;
          end
        end

        `WRITE_REG_IP: begin
          state = `START_READ_CMD_P;
        end
/**/

/**
        `START_READ_CMD: begin
          if(no_data_exit_and_wait_begin == 1'b 1) begin
            state <= `BREAK_THREAD_AND_BEGIN_WAIT;
          end else begin
            state <= `START_READ_CMD_P;
          end

             next_state_dn_r <= ~next_state_dn_r;
        end

        `START_READ_CMD_P: begin
          if(no_data_exit_and_wait_begin == 1'b 1) begin
            state <= `BREAK_THREAD_AND_BEGIN_WAIT;
          end else begin
            state <= `PREEXECUTE;
          end

             next_state_dn_r <= ~next_state_dn_r;
        end

          `BREAK_THREAD_AND_BEGIN_WAIT: begin
             //state <= `FINISH_BEGIN;

             next_state_dn_r <= ~next_state_dn_r;
          end
/**/

        `START_BEGIN: begin
          state <= `READ_MEM_SIZE_1;
          next_state_dn_r <= ~next_state_dn_r;
        end

        `READ_MEM_SIZE_1: begin
          state <= `AFTER_MEM_SIZE_READ;
          next_state_dn_r <= ~next_state_dn_r;
        end

        `AFTER_MEM_SIZE_READ: begin
          state <= `START_READ_CMD;
          next_state_dn_r <= ~next_state_dn_r;
        end

        /*
        `START_READ_CMD: begin
          state <= `START_READ_CMD_P;
          next_state_dn_r <= ~next_state_dn_r;
        end
        */

        `START_READ_CMD_P: begin
        	isCmdChanOp <= (cmd == `CMD_CHN);

        	state <= `PREEXECUTE;
        	next_state_dn_r <= ~next_state_dn_r;
        end

        `PREEXECUTE: begin
          if(
              ~isIpSaveAllowed || isCmdChanOp //{} (isCmdChanOp && (regDFlags == 2'b 11)) //{} Dst == z
          ) begin
            if(&regCondFlags == 0) 
              state <= (regNumCnd == `REG_IP) ? `FILL_COND : `READ_COND;
            else if(&regS1Flags == 0) 
              state <= (
                            regNumS1 == `REG_IP 
                         || (&regCondFlags == 0 && regNumS1 == regNumCnd && is_cnd_read)
                      ) ? `FILL_SRC1 : `READ_SRC1;
            else if(&regS0Flags == 0) 
              state <= (
                            regNumS0 == `REG_IP 
                         || (&regCondFlags == 0 && regNumS0 == regNumCnd && is_cnd_read)
                         || (&regS1Flags == 0 && regNumS0 == regNumS1 && is_s1_read)
                       ) 
                       ? `FILL_SRC0 
                       : `READ_SRC0;
            else if(isRegDPtr == 1) 
              state <= (
                            regNumD == `REG_IP 
                                || (&regCondFlags == 0 && regNumD == regNumCnd && is_cnd_read)
                                || (&regS1Flags == 0 && regNumD == regNumS1 && is_s1_read) 
                                || (&regS0Flags == 0 && regNumD == regNumS0 && is_s0_read)
                             ) ? `FILL_DST_P : `READ_DST;
            else begin
              isChanAlu <= isCmdChanOp;
              state <= `ALU_BEGIN;
            end
          end else begin
            state <= `WRITE_REG_IP;

            ipIsWriten <= 1;
          end

             next_state_dn_r <= ~next_state_dn_r;
        end

/**/
        `WRITE_REG_IP: begin
          ipIsWriten <= 1; //{} ??
          /* //{}
          if(isCmdChanOp && (regDFlags != 2'b 11) //{} isCmdChanOp
          )
            state <= `WRITE_PREP;
          else 
          */
          if(
              isCondDontExecCmd
              /* //{}
              //{} isIpSaveAllowed &&
              (
                isCond == 1 &&
                &regCondFlags == 0 &&
                (
                  (isCondTrue == 1 && |cond == 0) ||
                  (isCondTrue == 0 && |cond == 1)
                )
              )
              //{} && ~ipIsWriten //{} && ~isCmdChanOp //{}!(isCmdChanOp && (regDFlags != 2'b 11)) //{}
              */
          ) begin
            state <= `FINISH_BEGIN;
          end else

          if(isCmdChanOp)
            state <= `WRITE_PREP;
          else

          if(&regCondFlags == 0 && ~condIsReaden) 
            state <= (regNumCnd == `REG_IP) ? `FILL_COND : `READ_COND;
          else if(&regS1Flags == 0) 
            state <= (
                          regNumS1 == `REG_IP 
                             || (&regCondFlags == 0 && regNumS1 == regNumCnd && is_cnd_read)
                          ) ? `FILL_SRC1 : `READ_SRC1;
          else if(&regS0Flags == 0) 
            state <= (
                          regNumS0 == `REG_IP 
                             || (&regCondFlags == 0 && regNumS0 == regNumCnd && is_cnd_read)
                             || (&regS1Flags == 0 && regNumD == regNumS1 && is_s1_read) 
                          ) ? `FILL_SRC0 : `READ_SRC0;
          else if(isRegDPtr == 1) 
            state <= (
                          regNumD == `REG_IP 
                             || (&regCondFlags == 0 && regNumD == regNumCnd && is_cnd_read) 
                             || (&regS1Flags == 0 && regNumD == regNumS1 && is_s1_read) 
                             || (&regS0Flags == 0 && regNumD == regNumS0 && is_s0_read)
                          ) ? `FILL_DST_P : `READ_DST;
          else begin
            state <= `ALU_BEGIN;
          end

             next_state_dn_r <= ~next_state_dn_r;
        end
/**/

        `READ_COND, `FILL_COND: begin
          condIsReaden <= 1;

//             if(no_data_exit_and_wait_begin == 1'b 1) begin
//               state <= `BREAK_THREAD_AND_BEGIN_WAIT;
//             end else

          if(isRegCondPtr == 1) begin
            state <= `READ_COND_P;
          end else 
            state <= `AFTER_READ_COND;
/* //{}
          if(
               isIpSaveAllowed &&
               isCondDontExecCmd
               //{} && ~ipIsWriten //{} && ~isCmdChanOp //{}!(isCmdChanOp && (regDFlags != 2'b 11)) //{}
          ) begin
            state <= ~ipIsWriten ? `WRITE_REG_IP : `FINISH_BEGIN;
            ipIsWriten <= 1;
          end else

          if(&regS1Flags == 0) 
            state <= (
                          regNumS1 == `REG_IP 
                             || (&regCondFlags == 0 && regNumS1 == regNumCnd && is_cnd_read)
                          ) ? `FILL_SRC1 : `READ_SRC1;
          else if(&regS0Flags == 0) 
            state <= (
                          regNumS0 == `REG_IP 
                             || (&regCondFlags == 0 && regNumS0 == regNumCnd && is_cnd_read)
                             || (&regS1Flags == 0 && regNumS0 == regNumS1 && is_s1_read)
                          ) ? `FILL_SRC0 : `READ_SRC0;
//          else if(&regS0Flags == 0) 
//            state <= (
//                          regNumS0 == `REG_IP 
//                             || (&regCondFlags == 0 && regNumS0 == regNumCnd) 
//                             || (&regS1Flags == 0 && regNumS0 == regNumS1)
//                          ) ? `FILL_SRC0 : `READ_SRC0;
          else if(isRegDPtr == 1) 
            state <= (
                          regNumD == `REG_IP 
                             || (&regCondFlags == 0 && regNumD == regNumCnd && is_cnd_read) 
                             || (&regS1Flags == 0 && regNumD == regNumS1 && is_s1_read) 
                             || (&regS0Flags == 0 && regNumD == regNumS0 && is_s0_read)
                          ) ? `FILL_DST_P : `READ_DST;
          else begin
            isChanAlu <= isCmdChanOp;
            state <= `ALU_BEGIN;
          end

*/

          next_state_dn_r <= ~next_state_dn_r;
        end

        `READ_COND_P: begin
//             if(no_data_exit_and_wait_begin == 1'b 1) begin
//               state <= `BREAK_THREAD_AND_BEGIN_WAIT;
//             end else
          state <= `AFTER_READ_COND;
          next_state_dn_r <= ~next_state_dn_r;
        end

        `AFTER_READ_COND: begin
          if(
            isCondDontExecCmd
          ) begin
            state <= ~ipIsWriten ? `WRITE_REG_IP : `FINISH_BEGIN;
            ipIsWriten <= 1;
          end else
          if(
            isIpSaveAllowed
            //{} && ~ipIsWriten 
            && ( //{}  isCondDontExecCmd ||
                 ~isCmdChanOp //{}!(isCmdChanOp && (regDFlags != 2'b 11)) //{}
               )
          ) begin
            state <= ~ipIsWriten ? `WRITE_REG_IP : `FINISH_BEGIN;
            ipIsWriten <= 1;
          end else

          if(&regS1Flags == 0) 
            state <= (
                          regNumS1 == `REG_IP 
                             || (&regCondFlags == 0 && regNumS1 == regNumCnd && is_cnd_read)
                          ) ? `FILL_SRC1 : `READ_SRC1;
          else if(&regS0Flags == 0) 
            state <= (
                          regNumS0 == `REG_IP 
                             || (&regCondFlags == 0 && regNumS0 == regNumCnd && is_cnd_read) 
                             || (&regS1Flags == 0 && regNumS0 == regNumS1 && is_s1_read)
                          ) ? `FILL_SRC0 : `READ_SRC0;
          else if(isRegDPtr == 1) 
            state <= (
                          regNumD == `REG_IP 
                             || (&regCondFlags == 0 && regNumD == regNumCnd && is_cnd_read) 
                             || (&regS1Flags == 0 && regNumD == regNumS1 && is_s1_read) 
                             || (&regS0Flags == 0 && regNumD == regNumS0 && is_s0_read)
                          ) ? `FILL_DST_P : `READ_DST;
          else begin
            isChanAlu <= isCmdChanOp;
            state <= `ALU_BEGIN;
          end

             next_state_dn_r <= ~next_state_dn_r;
        end

        `READ_SRC1, `FILL_SRC1: begin
//             if(no_data_exit_and_wait_begin == 1'b 1) begin
//               state <= `BREAK_THREAD_AND_BEGIN_WAIT;
//             end else

          if(&regS0Flags == 0) 
            state <= (
                          regNumS0 == `REG_IP 
                             || (&regCondFlags == 0 && regNumS0 == regNumCnd && is_cnd_read) 
                             || (&regS1Flags == 0 && regNumS0 == regNumS1 && is_s1_read)
                          ) ? `FILL_SRC0 : `READ_SRC0;
          else if(isRegDPtr == 1) 
            state <= (
                          regNumD == `REG_IP 
                             || (&regCondFlags == 0 && regNumD == regNumCnd && is_cnd_read) 
                             || (&regS1Flags == 0 && regNumD == regNumS1 && is_s1_read) 
                             || (&regS0Flags == 0 && regNumD == regNumS0 && is_s0_read)
                          ) ? `FILL_DST_P : `READ_DST;
          else begin
            isChanAlu <= isCmdChanOp;
            state <= `ALU_BEGIN;
          end

          if(
//            &regS1Flags == 0 &&
            isRegS1Ptr == 1
          ) begin
            state <= `READ_SRC1_P;
          end

             next_state_dn_r <= ~next_state_dn_r;
        end

        `READ_SRC1_P: begin
//             if(no_data_exit_and_wait_begin == 1'b 1) begin
//               state <= `BREAK_THREAD_AND_BEGIN_WAIT;
//             end else

          if(&regS0Flags == 0) 
            state <= (
                          regNumS0 == `REG_IP 
                             || (&regCondFlags == 0 && regNumS0 == regNumCnd && is_cnd_read) 
                             || (&regS1Flags == 0 && regNumS0 == regNumS1 && is_s1_read)
                          ) ? `FILL_SRC0 : `READ_SRC0;
          else if(isRegDPtr == 1) 
            state <= (
                          regNumD == `REG_IP 
                             || (&regCondFlags == 0 && regNumD == regNumCnd && is_cnd_read) 
                             || (&regS1Flags == 0 && regNumD == regNumS1 && is_s1_read) 
                             || (&regS0Flags == 0 && regNumD == regNumS0 && is_s0_read)
                          ) ? `FILL_DST_P : `READ_DST;
          else begin
            isChanAlu <= isCmdChanOp;
            state <= `ALU_BEGIN;
            end

             next_state_dn_r <= ~next_state_dn_r;
        end

        `READ_SRC0, `FILL_SRC0: begin
//             if(no_data_exit_and_wait_begin == 1'b 1) begin
//               state <= `BREAK_THREAD_AND_BEGIN_WAIT;
//             end else

          if(
//            &regS0Flags == 0 &&
            isRegS0Ptr == 1
          ) begin
            state <= `READ_SRC0_P;
          end
          else if(isRegDPtr == 1) begin
            state <= (
                          regNumD == `REG_IP 
                             || (&regCondFlags == 0 && regNumD == regNumCnd && is_cnd_read) 
                             || (&regS1Flags == 0 && regNumD == regNumS1 && is_s1_read) 
                             || (&regS0Flags == 0 && regNumD == regNumS0 && is_s0_read)
                          ) ? `FILL_DST_P : `READ_DST;
          end else begin
            isChanAlu <= isCmdChanOp;
            state <= `ALU_BEGIN;
          end

             next_state_dn_r <= ~next_state_dn_r;
        end

        `READ_SRC0_P: begin
//             if(no_data_exit_and_wait_begin == 1'b 1) begin
//               state <= `BREAK_THREAD_AND_BEGIN_WAIT;
//             end else

          if(isRegDPtr == 1) 
            state <= (
                          regNumD == `REG_IP 
                             || (&regCondFlags == 0 && regNumD == regNumCnd && is_cnd_read) 
                             || (&regS1Flags == 0 && regNumD == regNumS1 && is_s1_read) 
                             || (&regS0Flags == 0 && regNumD == regNumS0 && is_s0_read)
                          ) ? `FILL_DST_P : `READ_DST;
          else begin
            isChanAlu <= isCmdChanOp;
            state <= `ALU_BEGIN;
          end

             next_state_dn_r <= ~next_state_dn_r;
        end

        `FILL_DST_P, `READ_DST: begin
//             if(no_data_exit_and_wait_begin == 1'b 1) begin
//               state <= `BREAK_THREAD_AND_BEGIN_WAIT;
//             end else

//          if(regNumD == `REG_IP)
//            state = `READ_DST_P;
//          else
            isChanAlu <= isCmdChanOp;
            state <= `ALU_BEGIN;

             next_state_dn_r <= ~next_state_dn_r;
        end

//        `READ_DST_P: begin
//          state = `ALU_BEGIN;
//        end

        `ALU_BEGIN: begin
          //if(chan_op == 1) begin
          //  state <= `ALU_CHAN_THREAD_ADDR_OUT;
          //end else begin
/**/
          if(isCmdChanOp && (chan_wait_next_time || chan_escape)) begin
            state <= `FINISH_BEGIN;
          end else begin
/**/
        	state <= `ALU_RESULTS;
          end

             next_state_dn_r <= ~next_state_dn_r;
        end

        //`ALU_CHAN_THREAD_ADDR_OUT: begin
        //  state <= `ALU_BEGIN;
        //
        //  next_state_dn_r <= ~next_state_dn_r;
        //end

        `ALU_RESULTS: begin
/*
            if(isCmdChanOp //{} && (regDFlags != 2'b 11) //{}isCmdChanOp
               && chan_wait_next_time
            ) begin
              state <= `FINISH_BEGIN;
//              state <= `WRITE_REG_IP;
//              ipIsWriten <= 1;
              next_state_dn_r <= ~next_state_dn_r;
            end else 
*/
            begin
              state <= isCmdChanOp ? `WRITE_REG_IP : `WRITE_PREP;
              next_state_dn_r <= ~next_state_dn_r;
            end
        end

        `WRITE_PREP: begin
/*
          $display("%b, %b, %b = %b"
                    , ^regCondFlags
                    , regNumS1  != regNumCnd
                    , regNumS0  != regNumCnd
                    , ^regCondFlags == 1 && 
                      (regNumS1  != regNumCnd &&
                       regNumS0  != regNumCnd
                      )
                    );
*/
          if(
            isDSaveAllowed
          ) begin
            state <= isRegDPtr ? `WRITE_DST_P : `WRITE_DST;
          end else
          if(
            isDSavePtrAllowed
          ) begin
            state <= `WRITE_DST_P;
          end else
          if(
              isCndSaveAllowed
          ) begin
            state <= `WRITE_COND;
          end else
          if(
              isCndSavePtrAllowed
          ) begin
            state <= `WRITE_COND_P;
          end else
          if(
              isS1SaveAllowed
          ) begin
            state <= `WRITE_SRC1;
          end else
          if(
              isS0SaveAllowed
          ) begin
            state <= `WRITE_SRC0;
          end else
          begin
            state <= `FINISH_BEGIN;
          end

             next_state_dn_r <= ~next_state_dn_r;
        end

        `WRITE_DST, `WRITE_DST_P: begin
          if(
//            isRegDPtr == 1 && 
//            ^regDFlags == 1 && 
              state == `WRITE_DST_P
              && ^regDFlags == 1
          ) begin
            state <= `WRITE_DST;
          end else
          if(
              isCndSaveAllowed
          ) begin
            state <= `WRITE_COND;
          end else
          if(
              isCndSavePtrAllowed
          ) begin
            state <= `WRITE_COND_P;
          end else
          if(
              isS1SaveAllowed
          ) begin
            state <= `WRITE_SRC1;
          end else
          if(
              isS0SaveAllowed
          ) begin
            state <= `WRITE_SRC0;
          end else
          begin
            state <= `FINISH_BEGIN;
          end

             next_state_dn_r <= ~next_state_dn_r;
        end

        `WRITE_COND, `WRITE_COND_P: begin
          if(
              state == `WRITE_COND_P
              && ^regCondFlags == 1
          ) begin
            state <= `WRITE_COND;
          end else
          if(
              isS1SaveAllowed
          ) begin
            state <= `WRITE_SRC1;
          end else
          if(
              isS0SaveAllowed
          ) begin
            state <= `WRITE_SRC0;
          end else
          begin
            state <= `FINISH_BEGIN;
          end

             next_state_dn_r <= ~next_state_dn_r;
        end

        `WRITE_SRC1: begin
          if(
              isS0SaveAllowed
          ) begin
            state <= `WRITE_SRC0;
          end else
          begin
            state <= `FINISH_BEGIN;
          end

             next_state_dn_r <= ~next_state_dn_r;
        end

        `WRITE_SRC0: begin
            state <= `FINISH_BEGIN;

             next_state_dn_r <= ~next_state_dn_r;
        end

        default: begin
          state <= state + 1;

             next_state_dn_r <= ~next_state_dn_r;
        end

      endcase
//    end // if(no_data_exit_and_wait_begin ...

    end 
//    else if(state == 0) begin
//      state = 1;
//    end
  end
endmodule
