
`include "sizes.v"


`define UART_WAIT_CMD  0
`define UART_SEND_BYTE 1
`define UART_RECEIVE_BYTE 2


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

  RxD,
  TxD,

  rst
);

  parameter TX_ADDR = `ADDR_SIZE'h f000_0000;
  parameter RX_ADDR = `ADDR_SIZE'h f000_0001;

  parameter ClkFrequency = 50_000_000;
  parameter Baud = 9600; //115200;

  
  
  input wire clk;
  input wire clk_oe;
  
  input wire rst;

  
  reg read_dn_r;
  output wire read_dn = read_dn_r;
  reg write_dn_r;
  output wire write_dn = write_dn_r;
  

  input wire [`ADDR_SIZE0:0] addr_in;
  output [`ADDR_SIZE0:0] addr_out;
  reg [`ADDR_SIZE0:0] addr_r;
  wire [`ADDR_SIZE0:0] addr_out = (
                                   read_dn_r == 1
											  || write_dn_r == 1
											)
											? addr_r
											: 0
											;
  
  input wire [`DATA_SIZE0:0] data_in;
  output [`DATA_SIZE0:0] data_out;
  reg [`DATA_SIZE0:0] data_r;
  wire [`DATA_SIZE0:0] data_out = (
                                   read_dn_r == 1
											  || write_dn_r == 1
											)
											? data_r
											: 0
											;
  
  input wire read_q;
  input wire write_q;
  
  
  output wire TxD;
  input wire RxD;
  
  
//  reg [7:0] tmp_data;
  reg tx_start;
  wire is_tx_busy;
  reg [7:0] tx_data;
  
  reg [2:0] state;
  
//  reg [`ADDR_SIZE0:0] tmp_addr;
//  reg [`DATA_SIZE0:0] tmp_data;

  
  async_transmitter tx(
    .clk(clk),
    .TxD_start(tx_start),
    .TxD_data(tx_data),
    .TxD(TxD),
    .TxD_busy(is_tx_busy)
  );
  defparam tx.ClkFrequency = ClkFrequency;
  defparam tx.Baud = Baud; //115200;
  
  
  
  wire is_rx_ready;
  wire [7:0] rx_data;
  
  wire rx_idle;        //only for packets
  wire rx_endofpacket; //only for packets

async_receiver rx(
	.clk(clk),
	.RxD(RxD),
	.RxD_data_ready(is_rx_ready),
	.RxD_data(rx_data),  // data received, valid only (for one clock cycle) when RxD_data_ready is asserted

	// We also detect if a gap occurs in the received stream of characters
	// That can be useful if multiple characters are sent in burst
	//  so that multiple characters can be treated as a "packet"
	.RxD_idle(rx_idle),  // asserted when no data has been received for a while
	.RxD_endofpacket(rx_endofpacket)  // asserted for one clock cycle when a packet has been detected (i.e. RxD_idle is going high)
);
  defparam rx.ClkFrequency = ClkFrequency;
  defparam rx.Baud = Baud; //115200;


  
  always @(posedge clk) begin
  
    if(clk_oe == 0) begin

    end else begin //clk_oe
	 
	   if(rst == 1) begin
		  tx_start = 0;
//		  tmp_data = 0;
		  
		  addr_r = 0;
		  data_r = 0;
		  
		  read_dn_r = 0;
		  write_dn_r = 0;
		  
		  state = `UART_WAIT_CMD;
		  
		end else begin //rst
		  tx_start = 0;
		  
		  read_dn_r = 0;
		  write_dn_r = 0;

//		  addr_r = 0;
//		  data_r = 0;
		  
		  case(state)
		    `UART_WAIT_CMD: begin
		      if(write_q == 1 && addr_in == TX_ADDR) begin
			     data_r = data_in;
				  addr_r = addr_in;
				
				  state = `UART_SEND_BYTE;
				end else
		      if(read_q == 1 && addr_in == RX_ADDR) begin
//			     data_r = data_in;
				  addr_r = addr_in;
				
				  state = `UART_RECEIVE_BYTE;
				end

          end
			 
			 `UART_SEND_BYTE: begin
		      if(is_tx_busy == 0) begin
			     tx_start = 1;
			 
//			     addr_r = tmp_addr;
//			     data_r = tmp_data;

              tx_data = data_r[7:0];
			 
			     write_dn_r = 1;
				  
				  state = `UART_WAIT_CMD;
				end
			 end
			 
			 `UART_RECEIVE_BYTE: begin
		      if(is_rx_ready == 1) begin
//			     tx_start = 1;
			 
//			     addr_r = tmp_addr;
			     data_r = {`DATA_SIZE'h 0000_0000_0000_0000, rx_data};
			 
			     read_dn_r = 1;
				  
				  state = `UART_WAIT_CMD;
				end
			 end
			 
		  endcase
		
		end // !rst

    end //clk_oe
  end

endmodule