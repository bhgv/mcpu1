
`include "sizes.v"
`include "states.v"
`include "cmd_codes.v"
`include "inter_cpu_msgs.v"


module ThreadCtlr(
        clk,
		  clk_oe,
		  
        is_bus_busy,
        
        command,
        cmd_code,
        
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
  
//  wire [`CMD_BITS_PER_CMD_CODE0:0] cmd_code = command[31:28];
  input wire [`CMD_BITS_PER_CMD_CODE0:0] cmd_code;
  
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
//                                      cpu_msg_in_r == 0 
//												  ? cpu_msg_r 
//												  : 0;//`CPU_MSG_SIZE'h zzzz_zzzz;


  input [`DATA_SIZE0:0] data_in;
  output [`DATA_SIZE0:0] data_out;
  reg [`DATA_SIZE0:0] data_r;
  wire [`DATA_SIZE0:0] data_in;
  wire [`DATA_SIZE0:0] data_out = 
//                           (
//                              disp_online == 1 
//                              && state == `ALU_BEGIN 
//                              && (
//                                cpu_msg_r == `CPU_R_FORK_THRD
//                                || cpu_msg_r == `CPU_R_STOP_THRD
//                                )
//                             )
									  cpu_msg_pulse == 1
                             ? data_r 
                             : 0 
                             ;
  
  input [`ADDR_SIZE0:0] addr_in;
  output [`ADDR_SIZE0:0] addr_out;
  reg [`ADDR_SIZE0:0] addr_r;
  wire [`ADDR_SIZE0:0] addr_in;
  wire [`ADDR_SIZE0:0] addr_out = 
//                             (
//                              disp_online == 1
//                              && state == `ALU_BEGIN 
//                              && (
//                                cpu_msg_r == `CPU_R_FORK_THRD
//                                || cpu_msg_r == `CPU_R_STOP_THRD
//                                )
//                             )
									  cpu_msg_pulse == 1
                             ? addr_r 
                             : 0 
                             ;
  

  output next_state;
  reg next_state_r;
  wire next_state = next_state_r;
  
  input wire rst;
  
  
//  wire [`CMD_BITS_PER_CMD_CODE0:0] cmd_code = command[31:28];
  
  reg signal_sent;
  
  
  wire [`DATA_SIZE0:0] data_for_stop_msg =
						        src1 == 0 
								  ? src0 + base_addr_data //- `THREAD_HEADER_SPACE // 0 // ?????
								  : src1 + base_addr_data //- `THREAD_HEADER_SPACE
								  ;
  
  //reg clk_oe;
  
  
  

  always @(/*neg*/ posedge clk) begin
   
	 if(clk_oe == 0) begin
	 
      next_state_r <= 1'b 0;
	 
	 end else begin

    if(rst == 1) begin
//      src1_r = 0;//`DATA_SIZE'h zzzzzzzz;
//      src0_r = 0; //`DATA_SIZE'h zzzzzzzz;
      dst_r <=  0;//`DATA_SIZE'h zzzzzzzz;
      dst_h <=  0;//`DATA_SIZE'h zzzzzzzz;
      
      cpu_msg_r <= 0; //8'h 00;
      
      signal_sent <= 0;
      
 //     cpu_msg_in_r = 0;
//      is_bus_busy_r = 1'b z;

      cpu_msg_pulse <= 0;
		
		next_state_r <= 1'b 0;
//		next_state_r = 1'b z;
    end else begin

//      cpu_msg_r = 0; //`CPU_MSG_SIZE'h zzzz;
    
      case(state)
		  default: begin
		    cpu_msg_r <= 0;
			 
			 dst_r <= 0;
        end
		  
//		  `ALU_RESULTS: begin
//		    cpu_msg_r <= 0;
//		  end
		  
        `ALU_BEGIN: begin
          dst_h <= 0;
          
          case(cmd_code)
		      default: begin
		        cpu_msg_r <= 0;
				  
				  dst_r <= 0;
            end
		  
            `CMD_FORK: begin
              if(disp_online == 1) begin
                if(
//                  cpu_msg_r !== `CPU_R_FORK_THRD && 
                  signal_sent == 0
                ) begin
                  addr_r <= src0 + base_addr_data; //base_addr;
                  data_r <= ( src1 == 0 ? src0 : src1 ) + base_addr_data;
                
                  cpu_msg_r <= `CPU_R_FORK_THRD;
                  
						cpu_msg_pulse <= 1;
						
                  signal_sent <= 1;
                end
                else begin
//                  if(signal_sent == 0) begin
//                    signal_sent = 1;
//                  end
//                  else begin
                    cpu_msg_pulse <= 0;
						  
                    cpu_msg_r <= 0; //8'h 00;
 //                   cpu_msg_in_r = 1;
                  
                    if(cpu_msg_in == `CPU_R_FORK_DONE) begin
                      dst_r <= data_in;
							 
                      signal_sent <= 0;
                      next_state_r <= 1;
                    end
//                  end
                end
              end
              else begin
                cpu_msg_r <= 0; //8'h00;
              end
            end
            
            
            `CMD_STOP: begin
//              cpu_msg_r = `CPU_R_STOP_THRD;
              if(disp_online == 1) begin
                if(
//                  cpu_msg_r !== `CPU_R_FORK_THRD && 
                  signal_sent == 0
                ) begin
                  addr_r <= src0 + base_addr_data; //base_addr - `THREAD_HEADER_SPACE;
                  data_r <= 
						        data_for_stop_msg
//						        src1 == 0 
//								  ? base_addr_data - `THREAD_HEADER_SPACE // 0 // ?????
//								  : src1 + base_addr_data - `THREAD_HEADER_SPACE
								  ;
                
                  cpu_msg_r <= `CPU_R_STOP_THRD;
						
						cpu_msg_pulse <= 1;
                  
                  signal_sent <= 1;
                end
                else begin
					   addr_r <= 0;
						data_r <= 0;
						
//                  if(signal_sent == 0) begin
//                    signal_sent = 1;
//                  end
//                  else begin
                  cpu_msg_pulse <= 0;
						
                  cpu_msg_r <= 0; //8'h 00;
     //               cpu_msg_in_r = 1;
                  
                  if(cpu_msg_in == `CPU_R_STOP_DONE) begin
						  dst_r <= data_in;
						  
                    signal_sent <= 0;
                    next_state_r <= 1;
                  end
//                end
                end
              end
              else begin
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

