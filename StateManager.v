
`include "sizes.v"
`include "states.v"


module StateManager(
            clk,
				clk_oe,
				
            state,
            
            command,

            cond,
            
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
  input wire clk_oe;
  
  input wire clk;
  output reg [`STATE_SIZE0:0] state;
  

  input wire [31:0] command;  
  
 
  wire [3:0] regNumS1;
  assign regNumS1 = command[3:0];

  wire [3:0] regNumS0;
  assign regNumS0 = command[7:4];

  wire [3:0] regNumD;
  assign regNumD = command[11:8];

  wire [3:0] regNumCnd;
  assign regNumCnd = command[15:12];
  
  
  wire isRegS1Ptr;
  assign isRegS1Ptr = command[16];
  
  wire isRegS0Ptr;
  assign isRegS0Ptr = command[17];
  
  wire isRegDPtr;
  assign isRegDPtr = command[18];
  
  wire isRegCondPtr;
  assign isRegCondPtr = command[19];
  
  
  wire [1:0] regS1Flags;
  assign regS1Flags = command[21:20];
  
  wire [1:0] regS0Flags;
  assign regS0Flags = command[23:22];
  
  wire [1:0] regDFlags;
  assign regDFlags = command[25:24];
  
  wire [1:0] regCondFlags;
  assign regCondFlags = command[27:26];


  input tri [`DATA_SIZE0:0] cond;
  
  input wire next_state;
  
  input wire rst;
  
  
  
  
  output isDSaveAllowed;
  wire isDSaveAllowed = (
             &regDFlags == 1'b 0 &&
//            (regNumCnd != regNumD || ^regCondFlags == 0) &&
//            (regNumS1  != regNumD || ^regS1Flags == 0) &&
//            (regNumS0  != regNumD || ^regS0Flags == 0) &&
            ((&regCondFlags == 0 && cond != 0) || &regCondFlags == 1 ) 
          )
          ;
  output isDSavePtrAllowed;
  wire isDSavePtrAllowed = (
             &regDFlags != 1'b 0 &&
//            (regNumCnd != regNumD || ^regCondFlags == 0) &&
//            (regNumS1  != regNumD || ^regS1Flags == 0) &&
//            (regNumS0  != regNumD || ^regS0Flags == 0) &&
            isRegDPtr == 1'b 1 &&
            ((&regCondFlags == 0 && cond != 0) || &regCondFlags == 1)
          )
          ;
  
  
  output isIpSaveAllowed;
  wire isIpSaveAllowed = ~(
            (regNumD == `REG_IP && isDSaveAllowed) ||
            (^regCondFlags && regNumCnd == `REG_IP) ||
            (^regS1Flags && regNumS1 == `REG_IP) ||
            (^regS0Flags && regNumS0 == `REG_IP)
          )
          ;
  

  output isCndSaveAllowed;
  wire isCndSaveAllowed = (
            ^regCondFlags == 1 && 
            (regNumD   != regNumCnd || ~isDSaveAllowed) &&
            (regNumS1  != regNumCnd || ^regS1Flags == 0) &&
            (regNumS0  != regNumCnd || ^regS0Flags == 0)
          )
          ;
  output isCndSavePtrAllowed;
  wire isCndSavePtrAllowed = 0 ;
  
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

  
  
  reg anti_continuous;
  
  reg condIsReaden;
  reg ipIsWriten;
  
  always @(negedge clk) begin
    if( rst == 1 ) begin
      state = `WAIT_FOR_START;
      
      condIsReaden = 0;
      ipIsWriten = 0;
      
      anti_continuous = 1;
    end
    else if(next_state !== 1) begin
      anti_continuous = 1;
    end
    else if(
      next_state === 1 && 
      (
        anti_continuous == 1
        || state == `WAIT_FOR_START
        || state == `PREEXECUTE
        || state == `START_BEGIN
        || state == `ALU_BEGIN
        || state == `ALU_RESULTS
        || state == `WRITE_PREP
        || state == `FILL_COND
        || state == `FILL_SRC1
        || state == `FILL_SRC0
      )
    ) begin
    
    
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
        anti_continuous = 0;
      
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
        
        `PREEXECUTE: begin
          if(
              ~isIpSaveAllowed
          ) begin
            if(&regCondFlags == 0) 
              state = (regNumCnd == `REG_IP) ? `FILL_COND : `READ_COND;
            else if(&regS1Flags == 0) 
              state = (
				            regNumS1 == `REG_IP 
								|| (&regCondFlags == 0 && regNumS1 == regNumCnd)
                      ) ? `FILL_SRC1 : `READ_SRC1;
            else if(&regS0Flags == 0) 
              state = (
				            regNumS0 == `REG_IP 
								|| (&regCondFlags == 0 && regNumS0 == regNumCnd)
								|| (&regS1Flags == 0 && regNumS0 == regNumS1)
							 ) ? `FILL_SRC0 : `READ_SRC0;
            else if(isRegDPtr == 1) 
              state = (
				            regNumD == `REG_IP 
								|| (&regCondFlags == 0 && regNumD == regNumCnd) 
								|| (&regS1Flags == 0 && regNumD == regNumS1) 
								|| (&regS0Flags == 0 && regNumD == regNumS0)
							 ) ? `FILL_DST_P : `READ_DST;
            else
              state = `ALU_BEGIN;
          end else begin
            state = `WRITE_REG_IP;
          end
        end
        
/**/
        `WRITE_REG_IP: begin
          ipIsWriten = 1;
          
          if(&regCondFlags == 0 && ~condIsReaden) 
            state = (regNumCnd == `REG_IP) ? `FILL_COND : `READ_COND;
          else if(&regS1Flags == 0) 
            state = (
				          regNumS1 == `REG_IP 
							 || (&regCondFlags == 0 && regNumS1 == regNumCnd)
						  ) ? `FILL_SRC1 : `READ_SRC1;
          else if(isRegDPtr == 1) 
            state = (
				          regNumD == `REG_IP 
							 || (&regCondFlags == 0 && regNumD == regNumCnd) 
							 || (&regS1Flags == 0 && regNumD == regNumS1) 
							 || (&regS0Flags == 0 && regNumD == regNumS0)
						  ) ? `FILL_DST_P : `READ_DST;
          else
            state = `ALU_BEGIN;
        end
/**/
        
        `READ_COND, `FILL_COND: begin
          condIsReaden = 1;
          
          if(isRegCondPtr == 1) begin
            state = `READ_COND_P;
          end else 
          if(isIpSaveAllowed && cond == 0 && ~ipIsWriten) begin
            state = `WRITE_REG_IP;
          end else
              
          if(&regS1Flags == 0) 
            state = (
				          regNumS1 == `REG_IP 
							 || (&regCondFlags == 0 && regNumS1 == regNumCnd)
						  ) ? `FILL_SRC1 : `READ_SRC1;
          else if(&regS0Flags == 0) 
            state = (
				          regNumS0 == `REG_IP 
							 || (&regCondFlags == 0 && regNumS0 == regNumCnd)
							 || (&regS1Flags == 0 && regNumS0 == regNumS1)
						  ) ? `FILL_SRC0 : `READ_SRC0;
//          else if(&regS0Flags == 0) 
//            state = (
//				          regNumS0 == `REG_IP 
//							 || (&regCondFlags == 0 && regNumS0 == regNumCnd) 
//							 || (&regS1Flags == 0 && regNumS0 == regNumS1)
//						  ) ? `FILL_SRC0 : `READ_SRC0;
          else if(isRegDPtr == 1) 
            state = (
				          regNumD == `REG_IP 
							 || (&regCondFlags == 0 && regNumD == regNumCnd) 
							 || (&regS1Flags == 0 && regNumD == regNumS1) 
							 || (&regS0Flags == 0 && regNumD == regNumS0)
						  ) ? `FILL_DST_P : `READ_DST;
          else
            state = `ALU_BEGIN;
        
/*
//          if(&regCondFlags == 0) begin
            if(isRegCondPtr == 0 && cond == 0 && ~ipIsWriten) begin
              state = `WRITE_REG_IP; //FINISH_BEGIN; //WRITE_DATA;
            end else if(isRegCondPtr == 1) begin
              state = `READ_COND_P;
//            end else begin
//              state = `ALU_BEGIN;
            end
*/
        end
        
        `READ_COND_P: begin
          if(isIpSaveAllowed && cond == 0 && ~ipIsWriten) begin
            state = `WRITE_REG_IP;
          end else
              
          if(&regS1Flags == 0) 
            state = (
				          regNumS1 == `REG_IP 
							 || (&regCondFlags == 0 && regNumS1 == regNumCnd)
						  ) ? `FILL_SRC1 : `READ_SRC1;
          else if(&regS0Flags == 0) 
            state = (
				          regNumS0 == `REG_IP 
							 || (&regCondFlags == 0 && regNumS0 == regNumCnd) 
							 || (&regS1Flags == 0 && regNumS0 == regNumS1)
						  ) ? `FILL_SRC0 : `READ_SRC0;
          else if(isRegDPtr == 1) 
            state = (
				          regNumD == `REG_IP 
							 || (&regCondFlags == 0 && regNumD == regNumCnd) 
							 || (&regS1Flags == 0 && regNumD == regNumS1) 
							 || (&regS0Flags == 0 && regNumD == regNumS0)
						  ) ? `FILL_DST_P : `READ_DST;
          else
            state = `ALU_BEGIN;

/*        
          if(cond == 0) begin
            state = `WRITE_REG_IP; //FINISH_BEGIN; //WRITE_DATA;
//          end else begin
          end
*/
        end
        
        `READ_SRC1, `FILL_SRC1: begin
          if(&regS0Flags == 0) 
            state = (
				          regNumS0 == `REG_IP 
							 || (&regCondFlags == 0 && regNumS0 == regNumCnd) 
							 || (&regS1Flags == 0 && regNumS0 == regNumS1)
						  ) ? `FILL_SRC0 : `READ_SRC0;
          else if(isRegDPtr == 1) 
            state = (
				          regNumD == `REG_IP 
							 || (&regCondFlags == 0 && regNumD == regNumCnd) 
							 || (&regS1Flags == 0 && regNumD == regNumS1) 
							 || (&regS0Flags == 0 && regNumD == regNumS0)
						  ) ? `FILL_DST_P : `READ_DST;
          else
            state = `ALU_BEGIN;

          if(
//            &regS1Flags == 0 &&
            isRegS1Ptr == 1
          ) begin
            state = `READ_SRC1_P;
          end
        end

        `READ_SRC1_P: begin
          if(&regS0Flags == 0) 
            state = (
				          regNumS0 == `REG_IP 
							 || (&regCondFlags == 0 && regNumS0 == regNumCnd) 
							 || (&regS1Flags == 0 && regNumS0 == regNumS1)
						  ) ? `FILL_SRC0 : `READ_SRC0;
          else if(isRegDPtr == 1) 
            state = (
				          regNumD == `REG_IP 
							 || (&regCondFlags == 0 && regNumD == regNumCnd) 
							 || (&regS1Flags == 0 && regNumD == regNumS1) 
							 || (&regS0Flags == 0 && regNumD == regNumS0)
						  ) ? `FILL_DST_P : `READ_DST;
          else
            state = `ALU_BEGIN;
        end

        `READ_SRC0, `FILL_SRC0: begin
          if(
//            &regS0Flags == 0 &&
            isRegS0Ptr == 1
          ) begin
            state = `READ_SRC0_P;
          end
          else if(isRegDPtr == 1) begin
            state = (
				          regNumD == `REG_IP 
							 || (&regCondFlags == 0 && regNumD == regNumCnd) 
							 || (&regS1Flags == 0 && regNumD == regNumS1) 
							 || (&regS0Flags == 0 && regNumD == regNumS0)
						  ) ? `FILL_DST_P : `READ_DST;
          end else begin
            state = `ALU_BEGIN;
          end
        end

        `READ_SRC0_P: begin
          if(isRegDPtr == 1) 
            state = (
				          regNumD == `REG_IP 
							 || (&regCondFlags == 0 && regNumD == regNumCnd) 
							 || (&regS1Flags == 0 && regNumD == regNumS1) 
							 || (&regS0Flags == 0 && regNumD == regNumS0)
						  ) ? `FILL_DST_P : `READ_DST;
          else
            state = `ALU_BEGIN;
        end
        
        `FILL_DST_P, `READ_DST: begin
//          if(regNumD == `REG_IP)
//            state = `READ_DST_P;
//          else
            state = `ALU_BEGIN;
        end
        
//        `READ_DST_P: begin
//          state = `ALU_BEGIN;
//        end

        `ALU_BEGIN: begin
            state = `ALU_RESULTS;
        end
        
        `ALU_RESULTS: begin
            state = `WRITE_PREP;
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
            state = isRegDPtr ? `WRITE_DST_P : `WRITE_DST;
          end else
          if(
            isDSavePtrAllowed
          ) begin
            state = `WRITE_DST_P;
          end else
          if(
              isCndSaveAllowed
          ) begin
            state = `WRITE_COND;
          end else
          if(
              isS1SaveAllowed
          ) begin
            state = `WRITE_SRC1;
          end else
          if(
              isS0SaveAllowed
          ) begin
            state = `WRITE_SRC0;
          end else
          begin
            state = `FINISH_BEGIN;
          end
        end
        
        `WRITE_DST, `WRITE_DST_P: begin
          if(
//            isRegDPtr == 1 && 
//            ^regDFlags == 1 && 
              state == `WRITE_DST_P
              && ^regDFlags == 1
          ) begin
            state = `WRITE_DST;
          end else
          if(
              isCndSaveAllowed
          ) begin
            state = `WRITE_COND;
          end else
          if(
              isS1SaveAllowed
          ) begin
            state = `WRITE_SRC1;
          end else
          if(
              isS0SaveAllowed
          ) begin
            state = `WRITE_SRC0;
          end else
          begin
            state = `FINISH_BEGIN;
          end
        end

        `WRITE_COND: begin
          if(
              isS1SaveAllowed
          ) begin
            state = `WRITE_SRC1;
          end else
          if(
              isS0SaveAllowed
          ) begin
            state = `WRITE_SRC0;
          end else
          begin
            state = `FINISH_BEGIN;
          end
        end
        
        `WRITE_SRC1: begin
          if(
              isS0SaveAllowed
          ) begin
            state = `WRITE_SRC0;
          end else
          begin
            state = `FINISH_BEGIN;
          end
        end

        `WRITE_SRC0: begin
            state = `FINISH_BEGIN;
        end

        default: begin
          state = state + 1;
        end

      endcase
      
    end 
//    else if(state == 0) begin
//      state = 1;
//    end
  end
endmodule
