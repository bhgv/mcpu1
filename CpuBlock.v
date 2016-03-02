
`include "sizes.v"
`include "states.v"
`include "inter_cpu_msgs.v"

`include "defines.v"


/**
`define MEM_CTLR_WAIT               0

`define MEM_CTLR_READ_SET_ADDRESS   1
`define MEM_CTLR_READ_DATA_GET      2
`define MEM_CTLR_READ_FINISH        3

`define MEM_CTLR_WRITE_SET_ADDRESS  4
`define MEM_CTLR_WRITE_SET_WE       5
`define MEM_CTLR_WRITE_FINISH       6
/**/


module CpuBlock(
    clk,
    clk_oe,

    addr_in,
    addr_out,
  
    data_in,
    data_out,

    read_q, //read_q),
    write_q, //write_q),
  
    read_dn,
    write_dn,
	 
	 halt_q,
    rw_halt_in,
	 rw_halt_out,

    rst
);

parameter CPU_QUANTITY = `CPU_QUANTITY;
parameter PROC_QUANTITY = `PROC_QUANTITY;

parameter UNMODIFICABLE_ADDR_B = `UNMODIFICABLE_ADDR_B;

  
	input wire clk;
	input wire rst;
	
	output wire clk_oe;



   wire [`ADDR_SIZE0:0] mem_addr_out;
   wire [`DATA_SIZE0:0] mem_data_out;

   wire ext_read_q;
   wire ext_write_q;

	
	input wire [`ADDR_SIZE0:0] addr_in;
   output wire [`ADDR_SIZE0:0] addr_out = mem_addr_out;
//   wire [`ADDR_SIZE0:0] addr_out = mem_addr_out;
  
   input wire [`DATA_SIZE0:0] data_in;
   output wire [`DATA_SIZE0:0] data_out = mem_data_out;
//   wire [`DATA_SIZE0:0] data_out = mem_data_out;
//   wire [`DATA_SIZE0:0] data_out = mem_data_out;

   output wire read_q = ext_read_q;
   output wire write_q = ext_write_q;
  
   input wire read_dn;
   input wire write_dn;
	 
	output /*wire*/ halt_q;
   input wire rw_halt_in;
	output /*wire*/ rw_halt_out;
	
	//-----------------------------------------------------

  
  trior [`DATA_SIZE0:0] cpu_cell_data_in; // = data_wire_r;
  wire [`DATA_SIZE0:0] cpu_cell_data_out; // = data_wire_r;  
  
  
//  wire [`ADDR_SIZE0:0] mem_addr_out;
//  wire [`DATA_SIZE0:0] mem_data_out;

  wire [`ADDR_SIZE0:0] mem_addr_in = addr_in
//                                    int_mem_addr_out 
//												| ext_mem_addr_out
												; //tmp_addr; 
												
  wire [`DATA_SIZE0:0] mem_data_in = data_in
//                                    int_mem_data_out 
//												| ext_mem_data_out
												; //tmp_data; 
  

  wire mem_read_dn = read_dn
//                     int_mem_read_dn 
//							| ext_mem_read_dn
							; //ext_read_dn_r;
							
  wire mem_write_dn = write_dn
//                     int_mem_write_dn 
//							| ext_mem_write_dn
							; //ext_write_dn_r;  
  
  
  wire DOC_rw_halt_out;
  
  wire DOC_ext_rw_halt_out;
  wire DOC_ext_rw_halt_in = 
                            rw_halt_in
									 ;
  
  

  wire bus_busy; // = bus_busy_r;
  

  wire [`DATA_SIZE0:0] ext_cpu_index; // = ext_cpu_index_r;
  
  tri0 ext_cpu_q; // = cpu_q_r;
  trior ext_cpu_e;
    
  trior dispatcher_q;
   
 
//  wire ext_read_q;
//  wire ext_write_q;	

  wire ext_rst_b; // = rst;
  wire ext_rst_e; // = ext_rst_e_r;
  
  wire init;


  
wire [`ADDR_SIZE0:0] addr_unmodificable_b = UNMODIFICABLE_ADDR_B;


wire [CPU_QUANTITY-1:0] rst_w_e_a;
wire [CPU_QUANTITY-1:0] rst_w_b_a;


assign rst_w_b_a = {rst_w_e_a[CPU_QUANTITY-2:0], ext_rst_b};
assign ext_rst_e = rst_w_e_a[CPU_QUANTITY-1];


  wire [CPU_QUANTITY-1:0] disp_online;

  trior [`CPU_MSG_SIZE0:0] cpu_msg_in;
  wire [`CPU_MSG_SIZE0:0] cpu_msg_dispatcher_out;
  
  wire [`CPU_MSG_SIZE0:0] cpu_msg_out = cpu_msg_in | cpu_msg_dispatcher_out;
						

//wire [`ADDR_SIZE*CPU_QUANTITY-1:0] addr_in_a;
//wire [`DATA_SIZE*CPU_QUANTITY-1:0] data_in_a;

  wire [`ADDR_SIZE0:0] cpu_cell_addr_out;
  trior [`ADDR_SIZE0:0] cpu_cell_addr_in;


  wire [CPU_QUANTITY-1:0] read_q_a;
  wire cpu_cell_read_q = |read_q_a;

  wire [CPU_QUANTITY-1:0] write_q_a;
  wire cpu_cell_write_q = |write_q_a;
  



wire [CPU_QUANTITY-1:0] rw_halt_a;
wire cpu_cell_rw_halt_in = (|rw_halt_a) | DOC_rw_halt_out;

wire [CPU_QUANTITY-1:0] halt_q_a;
wire cpu_cell_halt_q_in = |halt_q_a;

//wire ext_rw_halt;


wire [CPU_QUANTITY-1:0] bus_busy_in_a;
wire bus_busy_out = ( |bus_busy_in_a ) | bus_busy;


wire [CPU_QUANTITY-1:0] want_write_out_a;
wire want_write_in = |want_write_out_a;



wire cpu_cell_read_dn;
wire cpu_cell_write_dn;




/**/
Cpu cpu_cell [CPU_QUANTITY-1:0] (
            .clk(clk),
				.clk_oe(clk_oe),
            
            .halt_q_in(cpu_cell_halt_q_in),
            .halt_q_out(halt_q_a),
            .rw_halt_in(cpu_cell_rw_halt_in),
            .rw_halt_out(rw_halt_a),
            
            .want_write_in(want_write_in),
            .want_write_out(want_write_out_a),
				
				.addr_unmodificable_b(addr_unmodificable_b),
            
            .addr_in(cpu_cell_addr_out),
            .addr_out(cpu_cell_addr_in),
            .data_in(cpu_cell_data_out),
            .data_out(cpu_cell_data_in),
            
            .read_q(read_q_a),
            .write_q(write_q_a),
            .read_dn(cpu_cell_read_dn),
            .write_dn(cpu_cell_write_dn),
            
            .bus_busy_in(bus_busy_out),
				.bus_busy_out(bus_busy_in_a),
            
				.init(init),
            .ext_rst_b(rst_w_b_a),
            .ext_rst_e(rst_w_e_a),    //ext_rst_e),
            
            .ext_cpu_index(ext_cpu_index),
            
            .ext_cpu_q(ext_cpu_q),
            .ext_cpu_e(ext_cpu_e),
            
            .cpu_msg(cpu_msg_in), //_a),
				.cpu_msg_in(cpu_msg_out),
				
				.disp_online(disp_online),
            
            .dispatcher_q(dispatcher_q)
          );
/**/


/**/
DispatcherOfCpus disp_1(
            .clk(clk),
				.clk_oe(clk_oe),
				
            .rst(rst),
            
            .halt_q(cpu_cell_halt_q_in),
            .rw_halt_in(cpu_cell_rw_halt_in),
            .rw_halt_out(DOC_rw_halt_out),
				
				.addr_unmodificable_b(addr_unmodificable_b),
            
            .addr_in(cpu_cell_addr_in),
            .addr_out(cpu_cell_addr_out),
            .data_in(cpu_cell_data_in),
            .data_out(cpu_cell_data_out),
            
            .read_q(cpu_cell_read_q),
            .write_q(cpu_cell_write_q),
            .read_dn(cpu_cell_read_dn),
            .write_dn(cpu_cell_write_dn),
            
            .bus_busy(bus_busy),
            
				.init(init),
            .ext_rst_b(ext_rst_b),
            .ext_rst_e(ext_rst_e),
            
            .ext_cpu_index(ext_cpu_index),
            
            .ext_cpu_q(ext_cpu_q),
            .ext_cpu_e(ext_cpu_e),
             
            .ext_mem_addr_in(mem_addr_in),
            .ext_mem_addr_out(mem_addr_out),				
				
            .ext_mem_data_in(mem_data_in),
            .ext_mem_data_out(mem_data_out),
				
				.ext_rw_halt_in(DOC_ext_rw_halt_in),
				.ext_rw_halt_out(DOC_ext_rw_halt_out), //ext_rw_halt),
            
            .ext_read_q(ext_read_q),
            .ext_write_q(ext_write_q),
				
            .ext_read_dn(mem_read_dn),
            .ext_write_dn(mem_write_dn),
            
            .cpu_msg_in(cpu_msg_out), //cpu_msg_in),
            .cpu_msg_out(cpu_msg_dispatcher_out),
            
            .dispatcher_q(dispatcher_q)
          );
          
defparam disp_1.CPU_QUANTITY = CPU_QUANTITY;
defparam disp_1.PROC_QUANTITY = PROC_QUANTITY;

/**/


wire halt_q = cpu_cell_halt_q_in;
wire rw_halt_out = DOC_ext_rw_halt_out;

/**
InternalStartupRAM int_ram(
	.clk(clk_int),
	.clk_oe(clk_oe),
	
	.data_in(mem_data_out),
	.data_out(int_mem_data_out), //mem_data_in), //
	
	.addr_in(mem_addr_out),
	.addr_out(int_mem_addr_out), //mem_addr_in), //
	
	.read_q(ext_read_q), //read_q),
	.write_q(ext_write_q), //write_q),
	
	.read_dn(int_mem_read_dn), //mem_read_dn), //
	.write_dn(int_mem_write_dn), //mem_write_dn), //
	
   .rw_halt(DOC_ext_rw_halt_out),//ext_rw_halt),
	
	.rst(~rst)
);
defparam int_ram.INTERNAL_MEM_VALUE = INTERNAL_MEM_VALUE;
defparam int_ram.INTERNAL_MEM_FILE = INTERNAL_MEM_FILE;
/**/


       
endmodule
