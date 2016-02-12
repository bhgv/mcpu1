
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
	clk,
	
	ext_mem_addr,
	ext_mem_data,
	
	ext_read_q,
   ext_write_q,
	
	ext_read_dn,
	ext_write_dn,

	rst
);

//  reg  clk;
//  reg RESET_r;
//  wire rst = RESET_r;

	input wire clk;
	input wire rst;

  
//  reg [`ADDR_SIZE0:0] addr_out_r;
//  inout 
  tri [`ADDR_SIZE0:0] addr_in; // = addr_out_r;
  tri [`ADDR_SIZE0:0] addr_out; // = addr_out_r;
  
//  reg read_dn_r;
  //output 
  wire read_dn; // = read_dn_r;
  
//  reg write_dn_r;
  //output 
  wire write_dn; // = write_dn_r;
  
//  wire read_e;
//  wire write_e;
  
  
 // inout [`DATA_SIZE0:0] data_wire; // = data_wire_r;
  reg [`DATA_SIZE0:0] data_wire_r;
  tri [`DATA_SIZE0:0] data_in; // = data_wire_r;
  tri [`DATA_SIZE0:0] data_out; // = data_wire_r;
  
   
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
  tri bus_busy; // = bus_busy_r;
  
  
 
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
//  wire ext_rst_b; // = rst;
//  wire ext_rst_e; // = ext_rst_e_r;
  
//  reg [`DATA_SIZE0:0] ext_cpu_index_r;
  tri [`DATA_SIZE0:0] ext_cpu_index; // = ext_cpu_index_r;
  
//  reg cpu_q_r;
  tri0 ext_cpu_q; // = cpu_q_r;
  trior ext_cpu_e;
  
//  reg cpu_running;
  
//  wire ext_bus_busy;
  
  trior dispatcher_q;
  
//  tri [`CPU_MSG_SIZE0:0] cpu_msg;
 
 

  reg bus_director;
  

  output trior ext_read_q;
  output trior ext_write_q;
  
  inout ext_read_dn;
  inout ext_write_dn;
  
  reg ext_read_dn_r;
  reg ext_write_dn_r;

  tri0 ext_read_dn = ext_read_dn_r == 1 ? 1 : 1'b z;
  tri0 ext_write_dn = ext_write_dn_r == 1 ? 1 : 1'b z;
  
  reg ext_rw_busy;


  // tri [`ADDR_SIZE0:0] int_mem_addr;
 // tri [`DATA_SIZE0:0] int_mem_data;

  
  inout [`ADDR_SIZE0:0] ext_mem_addr; 
  reg [`ADDR_SIZE0:0] ext_mem_addr_r;
//  tri [`ADDR_SIZE0:0] ext_mem_addr; 
  
  tri [`ADDR_SIZE0:0] ext_mem_addr = //ext_mem_addr_r
/**/
                                     (
                                      ext_read_dn_r == 1
                                      || ext_write_dn_r == 1
                                     ) 
												 //&& 0
//                                     && (
//												     bus_director == 1
//												   )
												 ? ext_mem_addr_r 
                                     : `ADDR_SIZE'h zzzz_zzzz_zzzz_zzzz
/**/
                                     ;
	
/**	
  assign ext_mem_addr = 
/** /
                                     ! (
                                      ext_read_dn === 1
                                      || ext_write_dn === 1
                                     ) 
                                     ? int_mem_addr 
                                     : `DATA_SIZE'h zzzz_zzzz_zzzz_zzzz
/** /
                                     ;
/**/
  
  inout [`DATA_SIZE0:0] ext_mem_data; 
  reg [`DATA_SIZE0:0] ext_mem_data_r;
//  tri [`DATA_SIZE0:0] ext_mem_data; 
  
  tri [`DATA_SIZE0:0] ext_mem_data = //ext_mem_data_r
/**/
                                     (
                                      ext_read_dn_r == 1
                                      || ext_write_dn_r == 1
                                     ) 
												 && 0
//                                     && (
//												   bus_director == 1
//												 )
												 ? ext_mem_data_r 
                                     : `DATA_SIZE'h zzzz_zzzz_zzzz_zzzz
/**/
                                     ;
												 
/**
  assign ext_mem_data = 
/** /
                                     ! (
                                      ext_read_dn === 1
                                      || ext_write_dn === 1
                                     ) 
                                     ? int_mem_data 
                                     : `DATA_SIZE'h zzzz_zzzz_zzzz_zzzz
/** /
                                     ;
/**/
  
  
  
  
  
  reg [`ADDR_SIZE0:0] tmp_addr;
  reg [`DATA_SIZE0:0] tmp_data;
  
  reg [2:0] mem_wrk_state;
  
  
 
  
	reg [`DATA_SIZE:0] mem [0:50]; 
   initial $readmemh("mem.txt", mem);
  
//  reg [7:0] stage;

//parameter STEP = 20;


  wire ext_rst_b; // = rst;
  wire ext_rst_e; // = ext_rst_e_r;



parameter CPU_QUANTITY = 2;


wire [CPU_QUANTITY-1:0] rst_w_b;
wire [CPU_QUANTITY-1:0] rst_w_e;

assign rst_w_b = {rst_w_e[CPU_QUANTITY-2:0], ext_rst_b};
assign ext_rst_e = rst_w_e[CPU_QUANTITY-1];


  wire [CPU_QUANTITY-1:0] disp_online;
//  tri [(`CPU_MSG_SIZE*CPU_QUANTITY)-1:0] cpu_msg_in_a ;
  trior [`CPU_MSG_SIZE0:0] cpu_msg_in // = cpu_msg_in_a[7:0]
//						disp_online[0] == 1
//						? cpu_msg_in_a[7:0]
//						: cpu_msg_in_a[15:8]
						;
  wire [`CPU_MSG_SIZE0:0] cpu_msg_out = cpu_msg_in;
						

tri [`ADDR_SIZE*CPU_QUANTITY-1:0] addr_in_a;
tri [`DATA_SIZE*CPU_QUANTITY-1:0] data_in_a;


  //output 
  wire [CPU_QUANTITY-1:0] read_q_a;
  wire read_q = |read_q_a;
  //output 
  wire [CPU_QUANTITY-1:0] write_q_a;
  wire write_q = |write_q_a;
  



trior rw_halt;
tri0 halt_q;

tri want_write;

wire clk_oe;

/**/
Cpu cpu1 [CPU_QUANTITY-1:0] (
            .clk(clk),
				.clk_oe(clk_oe),
            
            .halt_q(halt_q),
            .rw_halt(rw_halt),
            
            .want_write(want_write),
            
            .addr_in(addr_out),
            .addr_out(addr_in),
            .data_in(data_out),
            .data_out(data_in),
            
            .read_q(read_q_a),
            .write_q(write_q_a),
            .read_dn(read_dn),
            .write_dn(write_dn),
            
            .bus_busy(bus_busy),
            
            .ext_rst_b(rst_w_b),
            .ext_rst_e(rst_w_e),    //ext_rst_e),
            
            .ext_cpu_index(ext_cpu_index),
            
            .ext_cpu_q(ext_cpu_q),
            .ext_cpu_e(ext_cpu_e),
            
            .cpu_msg(cpu_msg_in), //_a),
				.cpu_msg_in(cpu_msg_out),
				
				.disp_online(disp_online),
            
            .dispatcher_q(dispatcher_q)
          );
/**/


/**
wire rst_w1;

Cpu cpu0 (
            .clk(clk),
            
            .halt_q(halt_q),
            .rw_halt(rw_halt),
            
            .want_write(want_write),
            
            .addr_in(addr_in),
            .addr_out(addr_out),
            .data_in(data_out),
            .data_out(data_in),
            
            .read_q(read_q),
            .write_q(write_q),
            .read_dn(read_dn),
            .write_dn(write_dn),
            
            .bus_busy(bus_busy),
            
            .ext_rst_b(ext_rst_b),
            .ext_rst_e(rst_w1),    //ext_rst_e),
            
            .ext_cpu_index(ext_cpu_index),
            
            .ext_cpu_q(ext_cpu_q),
            .ext_cpu_e(ext_cpu_e),
            
            .cpu_msg(cpu_msg_a[0]),
				.disp_online(disp_online[0]),
            
            .dispatcher_q(dispatcher_q)
          );
			 
//assign ext_rst_e = rst_w1;

/**
Cpu cpu1 (
            .clk(clk),
            
            .halt_q(halt_q),
            .rw_halt(rw_halt),
            
            .want_write(want_write),
            
            .addr_in(addr_in),
            .addr_out(addr_out),
            .data_in(data_out),
            .data_out(data_in),
            
            .read_q(read_q),
            .write_q(write_q),
            .read_dn(read_dn),
            .write_dn(write_dn),
            
            .bus_busy(bus_busy),
            
            .ext_rst_b(rst_w1),
            .ext_rst_e(ext_rst_e),    //ext_rst_e),
            
            .ext_cpu_index(ext_cpu_index),
            
            .ext_cpu_q(ext_cpu_q),
            .ext_cpu_e(ext_cpu_e),
            
            .cpu_msg(cpu_msg_a[1]),
				.disp_online(disp_online[1]),
            
            .dispatcher_q(dispatcher_q)
          );
/**/




/**/
DispatcherOfCpus disp_1(
            .clk(clk),
				.clk_oe(clk_oe),
            .rst(rst),
            
            .halt_q(halt_q),
            .rw_halt(rw_halt),
            
            .addr_in(addr_in),
            .addr_out(addr_out),
            .data_in(data_in),
            .data_out(data_out),
            
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

            .cpu_msg_in(cpu_msg_in),
            
            .dispatcher_q(dispatcher_q)
          );
          
defparam disp_1.CPU_QUANTITY = CPU_QUANTITY;

/**/



always @(posedge clk) begin
//  ext_write_dn = 0;
//  ext_read_dn = 0;

  if(clk_oe == 0) begin
  
    ext_read_dn_r  = 0;
    ext_write_dn_r = 0;

    ext_mem_data_r = `DATA_SIZE'h zzzz_zzzz_zzzz_zzzz;
    ext_mem_addr_r = `ADDR_SIZE'h zzzz_zzzz_zzzz_zzzz;

  end else begin
  
  if(rst == 1) begin
    data_wire_r = `DATA_SIZE'h zzzz_zzzz_zzzz_zzzz;
	 
    mem_wrk_state = `MEM_CTLR_WAIT;
    
    ext_rw_busy = 0;
	 
	 bus_director = 0;
	 
	 ext_read_dn_r = 0;
	 ext_write_dn_r = 0;
	 
	 ext_mem_data_r = `DATA_SIZE'h zzzz_zzzz_zzzz_zzzz;
	 ext_mem_addr_r = `ADDR_SIZE'h zzzz_zzzz_zzzz_zzzz;
  end else
  begin

/**/
    case(mem_wrk_state)
    
      `MEM_CTLR_WAIT: begin
		  
//		  assign ext_mem_addr = `ADDR_SIZE'h zzzz_zzzz_zzzz_zzzz;
//		  assign ext_mem_data = `DATA_SIZE'h zzzz_zzzz_zzzz_zzzz;
		
        if(ext_read_q === 1) begin
          if(ext_mem_addr < 50) begin
			 
          tmp_addr = ext_mem_addr;
          mem_wrk_state = `MEM_CTLR_READ;
//          ext_mem_data_r = mem[ext_mem_addr];
//          ext_read_dn = 1;

          bus_director = 1;
			 
			 end
        end
        else
        if(ext_write_q === 1) begin
          if(ext_mem_addr < 50) begin
			 
          tmp_addr = ext_mem_addr;
          tmp_data = ext_mem_data;
          mem_wrk_state = `MEM_CTLR_WRITE;
//          mem[ext_mem_addr] = ext_mem_data;
//          ext_write_dn = 1;

          bus_director = 1;
			 
			 end
        end
      end

      `MEM_CTLR_READ: begin
        if(bus_director == 1) begin
          ext_mem_data_r = mem[tmp_addr];
          ext_mem_addr_r = tmp_addr;
          ext_read_dn_r = 1;
          
          //ext_rw_busy = 
          
          mem_wrk_state = `MEM_CTLR_WAIT;
			 
			 bus_director = 0;
			 
//			 assign ext_mem_addr = ext_mem_addr_r;
//			 assign ext_mem_data = ext_mem_data_r;
        end
      end
          
      `MEM_CTLR_WRITE: begin
        if(bus_director == 1) begin
		  
          mem[tmp_addr] = tmp_data;
          ext_mem_data_r = tmp_data;
          ext_mem_addr_r = tmp_addr;
          ext_write_dn_r = 1;
          
          //ext_rw_busy = 
          
          mem_wrk_state = `MEM_CTLR_WAIT;
			 
			 bus_director = 0;

//			 assign ext_mem_addr = ext_mem_addr_r;
//			 assign ext_mem_data = ext_mem_data_r;
        end
      end
          
    endcase
/**/

  end
  
  end
          
end






//always @(posedge clk) begin
//          Q = Q+1;
          
//       end


/*
always @(negedge clk) begin

//    addr_out_r = 32'h zzzzzzzz;
//    data_wire_r = 32'h zzzzzzzz;
    
    ext_rst_b = 0;
    
    read_dn_r = 1'b z;
    write_dn_r = 1'b z;
    bus_busy_r = 1'b z;
    
//    ext_rst_e_r = 1'b z;
    cpu_q_r = 0;
//    ext_cpu_index_r = 32'h zzzzzzzz;
    
  if(rst == 1) begin 
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


//always @(negedge rst) begin
//  data_wire_r = 32'h zzzzzzzz;
//  addr_out_r = 32'h zzzzzzzz;
//  bus_busy_r = 1'b z;
//end
       
endmodule
