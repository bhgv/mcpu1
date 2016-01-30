
/**
 * format
      --------
 * 00 - 
 * 01 - src
 * 02 - 1
 * 03 - 
      --------
 * 04 - 
 * 05 - src
 * 06 - 0
 * 07 - 
      --------
 * 08 - 
 * 09 - dst
 * 10 - 
 * 11 - 
      --------
 * 12 - 
 * 13 - cond
 * 14 - 
 * 15 - 
      --------
 * 16 - 
 * 17 - 
 * 18 - 
 * 19 - 
      --------
 * 20 - 
 * 21 - 
 * 22 - 
 * 23 - 
 * 24 - 
 * 25 - 
 * 26 - 
 * 27 - 
 * 28 - 
 * 29 - 
 * 30 - 
 * 31 - 
*/ 




`include "sizes.v"
`include "states.v"
`include "inter_cpu_msgs.v"


`define MEM_CTLR_WAIT  0
`define MEM_CTLR_READ  1
`define MEM_CTLR_WRITE 2
//`define MEM_CTLR_NULL  3



module Top(
	CLK,
	
	addr_out,
	data_wire,
	
	read_q,
   write_q,
	
	read_dn,
	write_dn,

	RESET
);

//  reg  CLK;
//  reg RESET_r;
//  wire RESET = RESET_r;

	input wire CLK;
	input wire RESET;

  
//  reg [`ADDR_SIZE0:0] addr_out_r;
  inout tri [`ADDR_SIZE0:0] addr_out; // = addr_out_r;
  
  output tri0 read_q;
  output tri0 write_q;
  
//  reg read_dn_r;
  output wire read_dn; // = read_dn_r;
  
//  reg write_dn_r;
  output wire write_dn; // = write_dn_r;
  
//  wire read_e;
//  wire write_e;
  
  
//  reg [`DATA_SIZE0:0] data_wire_r;
  inout tri [`DATA_SIZE0:0] data_wire; // = data_wire_r;
  
   
/*
  wire [`DATA_SIZE0:0] src1;
  wire [`DATA_SIZE0:0] src0;
  wire [`DATA_SIZE0:0] dst;
  wire [`DATA_SIZE0:0] dst_h;
  wire [`DATA_SIZE0:0] cond;
  
  wire [`STATE_SIZE0:0] state;
  wire nxt_state;
*/

//  reg bus_busy_r;
  tri0 bus_busy; // = bus_busy_r;
  
  
 
//  wire [31:0] command 
                    /*= {
                    4'h 0,  //command code
                    
                    2'b 00,    //flags Cond: 00 - as is, 01 - post inc, 10 - post dec, 11 - unused
                    2'b 00,    //flags D   : 00 - as is, 01 - post inc, 10 - post dec, 11 - unused 
                    2'b 01,    //flags S0  : 00 - as is, 01 - post inc, 10 - post dec, 11 - unused
                    2'b 10,    //flags S1  : 00 - as is, 01 - post inc, 10 - post dec, 11 - unused
                    
                    1'b 1,      //isRegCondPtr
                    1'b 1,      //isRegDPtr
                    1'b 1,      //isRegS0Ptr
                    1'b 1,      //isRegS1Ptr
                    
                    4'b 0111,   //cond
                    4'b 0011,   //dst
                    4'b 0100,   //src0
                    4'b 0010    //src1
                    }*/
//                    ;

/*
  wire [`ADDR_SIZE0:0] base_addr;
  
  wire rst;
  
  
  reg ext_rst_e_r;
*/

  //reg
  wire ext_rst_b; // = RESET;
  wire ext_rst_e; // = ext_rst_e_r;
  
//  reg [`DATA_SIZE0:0] ext_cpu_index_r;
  tri [`DATA_SIZE0:0] ext_cpu_index; // = ext_cpu_index_r;
  
//  reg cpu_q_r;
  tri0 ext_cpu_q; // = cpu_q_r;
  tri0 ext_cpu_e;
  
//  reg cpu_running;
  
//  wire ext_bus_busy;
  
  trior dispatcher_q;
  
  tri [7:0] cpu_msg;
  
  
 
  
  
  wire ext_read_q;
  wire ext_write_q;
  reg ext_read_dn;
  reg ext_write_dn;
  
  reg ext_rw_busy;


  reg [`ADDR_SIZE0:0] ext_mem_addr_r;
  tri [`ADDR_SIZE0:0] ext_mem_addr = 
                                     (
                                      ext_read_dn == 1
                                      || ext_write_dn == 1
                                     ) 
                                     ? ext_mem_addr_r 
                                     : `DATA_SIZE'h zzzz_zzzz_zzzz_zzzz
                                     ;
  
  reg [`DATA_SIZE0:0] ext_mem_data_r;
  tri [`DATA_SIZE0:0] ext_mem_data = 
                                     (
                                      ext_read_dn == 1
                                     ) 
                                     ? ext_mem_data_r 
                                     : `DATA_SIZE'h zzzz_zzzz_zzzz_zzzz
                                     ;
  
  
  reg [`ADDR_SIZE0:0] tmp_addr;
  reg [`DATA_SIZE0:0] tmp_data;
  
  reg [2:0] mem_wrk_state;
  
  
 
  
	reg [31:0] mem [0:400]; 
//   initial $readmemh("mem.txt", mem);
  
//  reg [7:0] stage;

//parameter STEP = 20;



parameter CPU_QUANTITY = 2;

wire [CPU_QUANTITY-1:0] rst_w_b;
wire [CPU_QUANTITY-1:0] rst_w_e;

assign rst_w_b = {rst_w_e[CPU_QUANTITY-2:0], ext_rst_b};
assign ext_rst_e = rst_w_e[CPU_QUANTITY-1];


trior rw_halt;
tri0 halt_q;

tri want_write;


/**/
Cpu cpu1 [CPU_QUANTITY-1:0] (
            .clk(CLK),
            
            .halt_q(halt_q),
            .rw_halt(rw_halt),
            
            .want_write(want_write),
            
            .addr(addr_out),
            .data(data_wire),
            
            .read_q(read_q),
            .write_q(write_q),
            .read_dn(read_dn),
            .write_dn(write_dn),
            
            .bus_busy(bus_busy),
            
            .ext_rst_b(rst_w_b),
            .ext_rst_e(rst_w_e),    //ext_rst_e),
            
            .ext_cpu_index(ext_cpu_index),
            
            .ext_cpu_q(ext_cpu_q),
            .ext_cpu_e(ext_cpu_e),
            
            .cpu_msg(cpu_msg),
            
            .dispatcher_q(dispatcher_q)
          );
/**/


wire rst_w1;


/**/
DispatcherOfCpus disp_1(
            .clk(CLK),
            .rst(RESET),
            
            .halt_q(halt_q),
            .rw_halt(rw_halt),
            
            .addr_out(addr_out),
            .data_wire(data_wire),
            
            .read_q(read_q),
            .write_q(write_q),
            .read_dn(read_dn),
            .write_dn(write_dn),
            
            .bus_busy(bus_busy),
            
            .ext_rst_b(ext_rst_b),
            .ext_rst_e(ext_rst_e),
            
            .ext_cpu_index(ext_cpu_index),
            
            .ext_cpu_q(ext_cpu_q),
            .ext_cpu_e(ext_cpu_e),
            

            .ext_mem_addr(ext_mem_addr),
            .ext_mem_data(ext_mem_data),
            
            .ext_read_q(ext_read_q),
            .ext_write_q(ext_write_q),
            .ext_read_dn(ext_read_dn),
            .ext_write_dn(ext_write_dn),
            
            .ext_rw_busy(ext_rw_busy),

            .cpu_msg(cpu_msg),
            
            .dispatcher_q(dispatcher_q)
          );
          
defparam disp_1.CPU_QUANTITY = CPU_QUANTITY;

/**/



always @(posedge CLK) begin
  ext_write_dn = 0;
  ext_read_dn = 0;
  
  if(RESET == 1) begin
    mem_wrk_state = `MEM_CTLR_WAIT;
    
    ext_rw_busy = 0;
  end else
  begin
  
    case(mem_wrk_state)
    
      `MEM_CTLR_WAIT: begin
        if(ext_read_q == 1) begin
          tmp_addr = ext_mem_addr;
          mem_wrk_state = `MEM_CTLR_READ;
//          ext_mem_data_r = mem[ext_mem_addr];
//          ext_read_dn = 1;
        end
          
        if(ext_write_q == 1) begin
          tmp_addr = ext_mem_addr;
          tmp_data = ext_mem_data;
          mem_wrk_state = `MEM_CTLR_WRITE;
//          mem[ext_mem_addr] = ext_mem_data;
//          ext_write_dn = 1;
        end
      end

      `MEM_CTLR_READ: begin
          ext_mem_data_r = mem[tmp_addr];
          ext_mem_addr_r = tmp_addr;
          ext_read_dn = 1;
          
          //ext_rw_busy = 
          
          mem_wrk_state = `MEM_CTLR_WAIT;
        end
          
      `MEM_CTLR_WRITE: begin
          mem[tmp_addr] = tmp_data;
          ext_mem_data_r = tmp_data;
          ext_mem_addr_r = tmp_addr;
          ext_write_dn = 1;
          
          //ext_rw_busy = 
          
          mem_wrk_state = `MEM_CTLR_WAIT;
        end
          
    endcase
  
  end
          
end






//always @(posedge CLK) begin
//          Q = Q+1;
          
//       end


/*
always @(negedge CLK) begin

//    addr_out_r = 32'h zzzzzzzz;
//    data_wire_r = 32'h zzzzzzzz;
    
    ext_rst_b = 0;
    
    read_dn_r = 1'b z;
    write_dn_r = 1'b z;
    bus_busy_r = 1'b z;
    
//    ext_rst_e_r = 1'b z;
    cpu_q_r = 0;
//    ext_cpu_index_r = 32'h zzzzzzzz;
    
  if(RESET == 1) begin 
    cpu_num = 0;
    data_wire_r = cpu_num; //Q;
    bus_busy_r  = 1'bz;
    
    state_ctl = `CTL_RESET_WAIT;
    
        //read_dn = 1;

    //addr_out_r = 32'h zzzzzzzz;
    //bus_busy_r = 1'b z;
    //read_dn = 0;
    //write_dn = 0;
    
    ext_cpu_index_r = 32'h zzzzzzzz;
    cpu_q_r = 0;
    
//    cpu_running = 0;
    
    //stage = 0;
    
    ext_rst_b = 1;
    
//    ext_rst_e_r = 1;
  end else begin
  
//    data_wire_r = 32'h zzzzzzzz;
//    addr_out_r  = 32'h zzzzzzzz;

    case(state_ctl)
      `CTL_RESET_WAIT: begin
        if(read_dn == 1) begin
          data_wire_r = 32'h zzzzzzzz;
          addr_out_r  = 32'h zzzzzzzz;
        end
          
        if(bus_busy == 1) begin
          cpu_tbl[data_wire] = 0; //32'h ffffffff;
        end
        
        if(ext_rst_e == 1) begin
          ext_rst_b = 0;
          
          state_ctl = `CTL_CPU_LOOP;
        end
      end
      
      `CTL_CPU_LOOP: begin
        if(cpu_num == CPU_QUANTITY) begin
          cpu_num = 0;
        end
        ext_cpu_index_r = cpu_num;
        
        cpu_num = cpu_num + 1;
        
        addr_out_r = cpu_tbl[cpu_num];
        
        cpu_q_r = 1;
        
        state_ctl = `CTL_CPU_CMD;
      end
      
      `CTL_CPU_CMD: begin
        if(cpu_q_r == 1) begin
          cpu_q_r = 0;
        end
        if(ext_cpu_e == 1) begin
          //cpu_running = 1;
          addr_out_r = 32'h zzzzzzzz;
          ext_cpu_index_r = 32'h zzzzzzzz;
          
          case(data_wire)
            `CPU_R_START: begin
            end
            
            `CPU_R_END: begin
            end
            
          endcase
          
          state_ctl = `CTL_MEM_WORK;
        end
      end
      
      `CTL_MEM_WORK: begin

        data_wire_r = 32'h zzzzzzzz;
        addr_out_r  = 32'h zzzzzzzz;
        

//    if(stage < 3) stage = stage + 1;
//  
//    if(stage == 2) begin
//    
//      addr_out_r = 0;
//      ext_cpu_index_r = cpu_num;
//      cpu_q_r = 1;
    
//    end else if( cpu_q_r == 1) begin
//      cpu_q_r = 0;
//    end else if(ext_cpu_e == 1) begin
//      cpu_running = 1;
//    end else 

//    if(cpu_running == 1) begin

          data_wire_r = 32'h zzzzzzzz;
//      case(state)
/*
        `FINISH_END: begin
          state_ctl = `CTL_CPU_LOOP;
        end
        
        `READ_COND, 
        `READ_DATA, 
        `START_READ_CMD: begin
          if(read_q == 1) begin
            //addr_out_r = 32'h zzzzzzzz;
            addr_out_r = addr_out;
            data_wire_r = mem[addr_out];
            read_dn_r = 1;
            bus_busy_r = 1;
         // end else begin
         //            data_wire_r = 32'h zzzzzzzz;
          end
        end
*/

/*
        
//        default: begin
          if(read_q == 1) begin
            //addr_out_r = 32'h zzzzzzzz;
            addr_out_r = addr_out;
            data_wire_r = mem[addr_out];
            read_dn_r = 1;
            bus_busy_r = 1;
          end else begin
         //            data_wire_r = 32'h zzzzzzzz;
          end

          if(write_q == 1) begin
            addr_out_r = addr_out;
            mem[addr_out] = data_wire;
            //$monitor("wrote mem[ %x ] = %x",addr_out,mem[addr_out]);
            write_dn_r = 1;
          end
          
          if(dispatcher_q == 1) begin
            state_ctl = `CTL_CPU_LOOP;
          end
          
//        end
//      endcase
      
    end
    
    
      //end
    endcase
    
    
    
  end
  
end
*/


//always @(negedge RESET) begin
//  data_wire_r = 32'h zzzzzzzz;
//  addr_out_r = 32'h zzzzzzzz;
//  bus_busy_r = 1'b z;
//end
       
endmodule
