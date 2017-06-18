
`include "sizes.v"

`include "defines.v"


`define UART_WAIT_CMD  0
`define UART_SEND_BYTE 1
`define UART_RECEIVE_BYTE 2
`define UART_NODATA_RESET 3


module Rs232 (
  clk,
  clk_oe,

  addr_in,
  addr_out,
  
  data_in,
  data_out,

  read_q,
  write_q,
  
  read_dn,
  write_dn,
  
 				ext_chan_no_in,
				ext_chan_no_out,
				ext_chan_data_in,
				ext_chan_data_out,
				ext_chan_r_q,
				ext_chan_w_q,
				ext_chan_r_dn,
				ext_chan_w_dn,
				ext_chan_nodata_in,
				ext_chan_nodata_out,
  
  halt_q,
  rw_halt_out,

  RxD,
  TxD,
  
  rx_received,

  rst
);

  parameter RS232_DATA_ADDR = `RS232_DATA_ADDR;

  parameter ClkFrequency = `MAIN_CLK_FREQ;//50000000;
  parameter Baud = `RS232_BAUD_RATE; //115200;

  
  
  input wire clk;
  input wire clk_oe;
  
  input wire rst;

  
  input wire ext_chan_r_q;
  input wire ext_chan_w_q;
  output reg ext_chan_r_dn;
  output reg ext_chan_w_dn;
  
  input wire [`ADDR_SIZE0:0] ext_chan_no_in;
  output reg [`ADDR_SIZE0:0] ext_chan_no_out;
  input wire [`DATA_SIZE0:0] ext_chan_data_in;
  output reg [`DATA_SIZE0:0] ext_chan_data_out;
  
  input wire ext_chan_nodata_in;
  output reg ext_chan_nodata_out;
  
  
  reg read_dn_r;
  output wire read_dn = read_dn_r;
  reg write_dn_r;
  output wire write_dn = write_dn_r;
  

  input wire [`ADDR_SIZE0:0] addr_in;
  output [`ADDR_SIZE0:0] addr_out;
  reg [`ADDR_SIZE0:0] addr_r;
  wire [`ADDR_SIZE0:0] addr_out = 
//											(
                                   //read_dn_r == 1
											  //|| write_dn_r == 1
//											  ext_chan_r_dn == 1
//											  || ext_chan_w_dn == 1
//											)
//											? addr_r
//											: 
											  0
											;
  
  input wire [`DATA_SIZE0:0] data_in;
  output [`DATA_SIZE0:0] data_out;
  reg [`DATA_SIZE0:0] data_r;
  wire [`DATA_SIZE0:0] data_out = 
//											(
                                   //read_dn_r == 1
											  //|| write_dn_r == 1
//											  ext_chan_r_dn == 1
//											  || ext_chan_w_dn == 1
//											)
//											? data_r
//											: 
											  0
											;
  
  input wire read_q;
  input wire write_q;
  
  
  output rw_halt_out;
  reg rw_halt_r;
  wire rw_halt_out = rw_halt_r;
  
  input wire halt_q;
  
  
  output wire TxD;
  input wire RxD;
  
  
//  reg [7:0] tmp_data;
  reg tx_start;// = state == `UART_SEND_BYTE;
  wire is_tx_busy;
  reg [7:0] tx_data;
  
  reg [3:0] state;
  
//  reg [`ADDR_SIZE0:0] tmp_addr;
//  reg [`DATA_SIZE0:0] tmp_data;

  
  /**/
  async_transmitter tx(
    .clk(clk_oe),
    .TxD_start(tx_start),
    .TxD_data(tx_data),
    .TxD(TxD),
    .TxD_busy(is_tx_busy)
  );
  defparam tx.ClkFrequency = ClkFrequency/2;
  defparam tx.Baud = Baud; //115200;
  /**/
  
  
  reg rst_uart;
  
  
  wire is_rx_ready;
  wire [7:0] rx_data;
  
  wire rx_idle;        //only for packets
  wire rx_endofpacket; //only for packets
  
  reg [7:0] rx_buf;
  reg is_rx_buf;

/**/
async_receiver rx(
	.clk(clk_oe),
	.RxD(RxD),
	.RxD_data_ready(is_rx_ready),
	.RxD_data(rx_data),  // data received, valid only (for one clock cycle) when RxD_data_ready is asserted

	// We also detect if a gap occurs in the received stream of characters
	// That can be useful if multiple characters are sent in burst
	//  so that multiple characters can be treated as a "packet"
	.RxD_idle(rx_idle),  // asserted when no data has been received for a while
	.RxD_endofpacket(rx_endofpacket)  // asserted for one clock cycle when a packet has been detected (i.e. RxD_idle is going high)
);
  defparam rx.ClkFrequency = ClkFrequency/2;
  defparam rx.Baud = Baud; //115200;
/**/


  wire is_receiving, is_transmitting, recv_error;

/**
    uart 
//	 #(
//        .baud_rate(baud_rate),            // default is 9600
//        .sys_clk_freq(sys_clk_freq)       // default is 100000000
//     )
    rs232(
        .clk(clk_oe),                        // The master clock for this module
        .rst(rst_uart),                        // Synchronous reset
        .rx(RxD),                          // Incoming serial line
        .tx(TxD),                          // Outgoing serial line
        .transmit(tx_start),              // Signal to transmit
        .tx_byte(tx_data),                // Byte to transmit       
        .received(is_rx_ready),              // Indicated that a byte has been received
        .rx_byte(rx_data),                // Byte received
        .is_receiving(is_receiving),      // Low when receive line is idle
        .is_transmitting(is_transmitting),// Low when transmit line is idle
        .recv_error(recv_error)           // Indicates error in receiving packet.
      //.recv_state(recv_state),          // for test bench
      //.tx_state(tx_state)               // for test bench
    );
	 defparam rs232.baud_rate = Baud;
	 defparam rs232.sys_clk_freq = ClkFrequency/2;
/**/
	 
	 wire is_rs232_busy = 
	                      is_tx_busy == 1
								 //|| rx_idle == 0
//	                    (
//									  is_receiving == 1
//								  || is_transmitting == 1
//								)
								;

//  output wire rx_received = is_rx_buf;
	 
/**
  always @(negedge clk) begin
    if(clk_oe == 1) begin
	 
	   if(halt_q == 1) begin
		  if(
		     read_q == 1 
			  && addr_in == RX_ADDR 
			  && is_rx_buf == 0
		  ) begin
		    rw_halt_r = 1;
		  end else
		  if(
		     write_q == 1 
			  && addr_in == TX_ADDR 
			  && is_tx_busy == 1
		  ) begin
		    rw_halt_r = 1;
		  end else
		    rw_halt_r = 0;
		end
		else
		  rw_halt_r =0;
		  
	 end
  end  
/**/  
  
/**  
  always @(posedge is_rx_ready) begin
		    rx_buf = rx_data;
			 is_rx_buf = 1;
  end
/**/


/**/
  wire rw_halt_stim = (
		                  state == `UART_WAIT_CMD
			               && addr_in == RS232_DATA_ADDR
								&& 
								(
								     (
									    read_q == 1
										 && (
//										      is_receiving == 1 //
//												is_rs232_busy == 1
//												|| 
												is_rx_buf == 0
										 )
									  )
									  || (
									    write_q == 1
										 && is_tx_busy == 1
									  )
								)
			             )
							 ;
/**/


  output wire rx_received = rw_halt_stim;

  
  
/**
  always @(negedge clk) begin
    if(rst == 1)
	   rw_halt_r = 0;
    else
	   if(clk_oe == 1)
        rw_halt_r = rw_halt_stim;
  end
/**/

  
  always @(posedge clk) begin
/**/
        if(
		    is_rx_ready == 1
			 //&& is_rs232_busy == 0
			 && state == `UART_WAIT_CMD
		  ) begin
		    rx_buf <= rx_data;
			 is_rx_buf <= 1;
			 
//			 rw_halt_r = 0;
		  end
/**/
//  end

  
//  always @(posedge clk) begin

    if(clk_oe == 0) begin

//	   if(rst == 1) begin
//		  rst_uart = 1;
//		end else begin

/**
        if(
		    is_rx_ready == 1
			 //&& is_rs232_busy == 0
//			 && state == `UART_WAIT_CMD
		  ) begin
		    rx_buf = rx_data;
			 is_rx_buf = 1;
			 
//			 rw_halt_r = 0;
		  end
/**/


//        rw_halt_r <= rw_halt_stim;
		  
//      end // rst
							 
    end else begin //clk_oe
	 
	   if(rst == 1) begin
		  tx_start <= 0;
		  tx_data <= 0;
//		  tmp_data <= 0;
		  
		  addr_r <= 0;
		  data_r <= 0;
		  
		  read_dn_r <= 0;
		  write_dn_r <= 0;
		  
		  state <= `UART_WAIT_CMD;
		  
		  is_rx_buf <= 0;
		  
		  rst_uart <= 1;
		  
		  ext_chan_nodata_out <= 0;
			ext_chan_r_dn <= 0;
			ext_chan_w_dn <= 0;
  
			ext_chan_no_out <= 0;
			ext_chan_data_out <= 0;

		  rw_halt_r = 0;
		  
		end else begin //rst
		  //tx_start = 0;
		  //rw_halt_r = 0;
		  
		  
//		  read_dn_r = 0;
//		  write_dn_r = 0;

		  case(state)
		    `UART_WAIT_CMD: begin
			   rst_uart <= 0;
				
//		      read_dn_r <= 0;
//		      write_dn_r <= 0;

		      if(
/*
				  addr_in == RS232_DATA_ADDR 
//				  && rw_halt_r != 1
				  && (read_q == 1 || write_q == 1)
*/
					ext_chan_no_in == RS232_DATA_ADDR &&
					(ext_chan_r_q == 1 || ext_chan_w_q == 1)
				) begin
			     //data_r = data_in;
//				  addr_r <= /*addr_in*/ ext_chan_no_in;
				  ext_chan_no_out <= ext_chan_no_in;
		        
				  if(/*write_q == 1*/ ext_chan_w_q == 1) begin  
					 if(/*is_tx_busy == 0*/ is_tx_busy == 0 /*rw_halt_stim == 0*/) begin
					   tx_data <= /*data_r*/ /*data_in[7:0]*/ ext_chan_data_in[7:0];
			         tx_start <= 1;
						
//						data_r <= /*data_in*/ ext_chan_data_in;
						
						ext_chan_w_dn <= 1;
						//ext_chan_no_out <= ext_chan_no_in;

//			         write_dn_r = 1;

				      state <= `UART_SEND_BYTE;
				    end else begin
					   ext_chan_nodata_out <= 1;
				      state <= `UART_NODATA_RESET;
					 end
				  end else if(/*read_q == 1*/ ext_chan_r_q == 1) begin
				    if(is_rx_buf == 1) begin
//			         data_r = data_in;
			         
						/*data_r*/ ext_chan_data_out <= {`DATA_SIZE'h 0000000000000000, rx_buf};
			 
                  is_rx_buf <= 0;
						
						ext_chan_r_dn <= 1;
						//ext_chan_no_out <= ext_chan_no_in;

						//read_dn_r = 1;

				      state <= `UART_RECEIVE_BYTE;
				    end else begin
					   ext_chan_nodata_out <= 1;
				      state <= `UART_NODATA_RESET;
				    end
				  end
				  
				end else begin
		        addr_r <= 0;
		        data_r <= 0;
				end

          end
			 
			 `UART_SEND_BYTE: begin
//		      if(is_rs232_busy == 0) begin

              //tx_data = data_r[7:0];
			     //tx_start = 1;

//			     addr_r = tmp_addr;
//			     data_r = tmp_data;

//              tx_data = data_r[7:0];

						ext_chan_w_dn <= 0;
						ext_chan_no_out <= 0;
						ext_chan_data_out <= 0;

		        tx_start <= 0;
//				  tx_data = 0;
			 
//			     /*if(rw_halt_r == 0)*/ write_dn_r <= 1;
				  
				  state <= `UART_WAIT_CMD;
//				end else begin
//				  //rw_halt_r = 1;
//				  state = `UART_WAIT_CMD;
//				end
			 end
			 
			 `UART_RECEIVE_BYTE: begin
//		      if(is_rx_buf == 1) begin			 
//			     addr_r = tmp_addr;
			  //   data_r = {`DATA_SIZE'h0000000000000000, rx_buf};
           //   is_rx_buf = 0;
				  
//			     /*if(rw_halt_r == 0)*/ read_dn_r <= 1;
				  
				  ext_chan_no_out <= 0;
				  ext_chan_data_out <= 0;
				  ext_chan_r_dn <= 0;
				  
				  state <= `UART_WAIT_CMD;
//				end else begin
//				  rw_halt_r = 1;
//				  state = `UART_WAIT_CMD;
//				end
			 end
			 
			 `UART_NODATA_RESET: begin				  
				  ext_chan_nodata_out <= 0;
				  state <= `UART_WAIT_CMD;
			 end
			 
		  endcase
		
		end // !rst

    end //clk_oe
  end

endmodule
