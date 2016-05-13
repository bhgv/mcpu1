
`include "sizes.v"
`include "states.v"
`include "cmd_codes.v"
`include "inter_cpu_msgs.v"


module ChannelCtlr(
        clk,
		  clk_oe,
		  
        is_bus_busy,
        
        command,
        
        base_addr,
        base_addr_data,
        
        state,
        
        src1,
        src0,
        dst,
        dst_h,
        
        data_in,
		  data_out,
        addr_in,
		  addr_out,
        
        disp_online,
        
        cpu_msg_in,
        cpu_msg_out,
		  
		  cpu_msg_pulse,
        
        next_state,
        
        rst
        );
        
  input wire clk;
  input wire clk_oe;
  
  input is_bus_busy;
//  reg is_bus_busy_r;
  wire is_bus_busy; // = is_bus_busy_r;
  
  input wire [31:0] command;
  
  
  
  wire [3:0] cmd_code = command[31:28];
  

  wire [1:0] regS1Flags;
  assign regS1Flags = command[21:20];
  
  wire [1:0] regS0Flags;
  assign regS0Flags = command[23:22];
  
  wire [1:0] regDFlags;
  assign regDFlags = command[25:24];
  
//  wire [1:0] regCondFlags;
//  assign regCondFlags = command[27:26];
  
  
  
  
  input wire [`ADDR_SIZE0:0] base_addr;
  input wire [`ADDR_SIZE0:0] base_addr_data;
  
  input wire [`STATE_SIZE0:0] state;
  
  input [`DATA_SIZE0:0] src1;
  input [`DATA_SIZE0:0] src0;
  output [`DATA_SIZE0:0] dst;
  output reg [`DATA_SIZE0:0] dst_h;

 // reg [`DATA_SIZE0:0] src1_r;
 // reg [`DATA_SIZE0:0] src0_r;
  reg [`DATA_SIZE0:0] dst_r;
  
  wire [`DATA_SIZE0:0] src1 /*= src1_r*/;
  wire [`DATA_SIZE0:0] src0 /*= src0_r*/;
  wire [`DATA_SIZE0:0] dst  = dst_r;
  
  
  input wire disp_online;
  
  
  output reg cpu_msg_pulse;
  
//  reg cpu_msg_in_r;
  
  input wire [`CPU_MSG_SIZE0:0] cpu_msg_in;
  output [`CPU_MSG_SIZE0:0] cpu_msg_out;
  
  reg [`CPU_MSG_SIZE0:0] cpu_msg_r;
  wire [`CPU_MSG_SIZE0:0] cpu_msg_out = cpu_msg_r;


  input [`DATA_SIZE0:0] data_in;
  output [`DATA_SIZE0:0] data_out;
  reg [`DATA_SIZE0:0] data_r;
  wire [`DATA_SIZE0:0] data_in;
  wire [`DATA_SIZE0:0] data_out = 
									  cpu_msg_pulse == 1
                             ? data_r 
                             : 0 
                             ;
  
  input [`ADDR_SIZE0:0] addr_in;
  output [`ADDR_SIZE0:0] addr_out;
  reg [`ADDR_SIZE0:0] addr_r;
  wire [`ADDR_SIZE0:0] addr_in;
  wire [`ADDR_SIZE0:0] addr_out = 
									  cpu_msg_pulse == 1
                             ? addr_r 
                             : 0 
                             ;
  

  output next_state;
  reg next_state_r;
  wire next_state = next_state_r;
  
  input wire rst;
  
  
//  wire [3:0] cmd_code = command[31:28];
  
  reg signal_sent;
  
 /* 
  wire [`DATA_SIZE0:0] data_for_stop_msg =
						        src1 == 0 
								  ? base_addr_data - `THREAD_HEADER_SPACE // 0 // ?????
								  : src1 + base_addr_data - `THREAD_HEADER_SPACE
								  ;
*/

  //reg clk_oe;
  
  
  
        
  always @(negedge clk) begin
   
	 if(clk_oe == 0) begin
	 
      next_state_r <= 1'b 0;
	 
	 end else begin

    if(rst == 1) begin
//      src1_r = 0;
//      src0_r = 0;
      dst_r <=  0;
      dst_h <=  0;
      
      cpu_msg_r <= 0; //8'h 00;
      
      signal_sent <= 0;
      
 //     cpu_msg_in_r = 0;
//      is_bus_busy_r = 1'b z;

      cpu_msg_pulse <= 0;
		
		next_state_r <= 1'b 0;
//		next_state_r = 1'b z;
    end else begin

//      cpu_msg_r = 0;
    
      case(state)
		  default: begin
		    cpu_msg_r <= 0;
			 
          dst_h <= 0;
			 dst_r <= 0;
        end
		  
//		  `ALU_RESULTS: begin
//		    cpu_msg_r <= 0;
//		  end
		  
        `ALU_BEGIN: begin
          
          case(cmd_code)
		      default: begin
		        cpu_msg_r <= 0;
				  
              dst_h <= 0;
				  dst_r <= 0;
            end

            `CMD_CHN: begin
              if(disp_online == 1) begin
                if(
                  signal_sent == 0
                ) begin
					 
/**
					   case({&regDFlags, &regS0Flags, &regS1Flags})
						  3'b 000: begin // r <- ch <- r 
						    data_r <= src1;
							 addr_r <= src0;
                      cpu_msg_r <= `CPU_R_CHAN_SET;
						  end
						
						  3'b 001: begin // r <- ch <- z // get from ch
						    //data_r <= 0;
                      addr_r <= src0;
							 cpu_msg_r <= `CPU_R_CHAN_GET;
						  end
						
						  3'b 010: begin // r <- z <- r  // test ch
                      addr_r <= src1;
							 cpu_msg_r <= `CPU_R_CHAN_TST;
						  end
						
						  3'b 011: begin // r <- z <- z  // cr ch
                      cpu_msg_r <= `CPU_R_CHAN_CRT;
						  end
						
						  3'b 100: begin // z <- ch <- r // set to ch
                      data_r <= src1;
							 addr_r <= src0;
							 cpu_msg_r <= `CPU_R_CHAN_SET;
						  end
						
						  3'b 101: begin // z <- ch <- z // ??? 
                      //cpu_msg_r <= `CPU_R_FORK_THRD;
						  end
						
						  3'b 110: begin // z <- z <- r  // del ch
                      addr_r <= src1;
							 cpu_msg_r <= `CPU_R_CHAN_DEL;
						  end
						
						  3'b 111: begin // z <- z <- z  // ???
                      //cpu_msg_r <= `CPU_R_FORK_THRD;
						  end
						
						endcase
                  
						cpu_msg_pulse <= 1;
						
                  signal_sent <= 1;
/**/
                end
                else begin
//                  if(signal_sent == 0) begin
//                    signal_sent = 1;
//                  end
//                  else begin
                    cpu_msg_pulse <= 0;
						  
                    cpu_msg_r <= 0; //8'h 00;
 //                   cpu_msg_in_r = 1;
                  
                    if(cpu_msg_in == `CPU_R_CHAN_DONE) begin
                    
/**
							 case({&regDFlags, &regS0Flags, &regS1Flags})
							   3'b 000: begin // r <- ch <- r 
								  //data_r <= src1;
								  addr_r <= src0;
								  cpu_msg_r <= `CPU_R_CHAN_GET;
							   end
							
							   3'b 001: begin // r <- ch <- z // get from ch
								  //data_r <= 0;
								  //addr_r <= src0;
								  //cpu_msg_r <= `CPU_R_CHAN_GET;
								  dst_r <= data_in;
							   end
							
							   3'b 010: begin // r <- z <- r  // test ch
								  dst_r <= data_in;
								  //addr_r <= src1;
								  //cpu_msg_r <= `CPU_R_CHAN_TST;
							   end
							
							   3'b 011: begin // r <- z <- z  // cr ch
								  dst_r <= data_in;
								  //cpu_msg_r <= `CPU_R_CHAN_CRT;
							   end
							
							   3'b 100: begin // z <- ch <- r // set to ch
								  //data_r <= src1;
								  //addr_r <= src0;
								  //cpu_msg_r <= `CPU_R_CHAN_SET;
							   end
							
							   3'b 101: begin // z <- ch <- z // ??? 
								  //cpu_msg_r <= `CPU_R_FORK_THRD;
							   end
							
							   3'b 110: begin // z <- z <- r  // del ch
								  //addr_r <= src1;
								  //cpu_msg_r <= `CPU_R_CHAN_DEL;
							   end
							
							   3'b 111: begin // z <- z <- z  // ???
								  //cpu_msg_r <= `CPU_R_FORK_THRD;
							   end
							
							 endcase
						  
                      signal_sent <= 0;
                      next_state_r <= 1;
/**/
                    end
//                  end
                end
              end
              else begin
                dst_h <= 0;
				    dst_r <= 0;

                cpu_msg_r <= 0; //8'h00;
              end
            end
            
          endcase
          
        end
 
      endcase
    
    
    
    end
	 
	 end
  
  end
        
endmodule

