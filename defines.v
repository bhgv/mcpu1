

`define CPU_QUANTITY		2
`define PROC_QUANTITY	7

`define MAIN_CLK_FREQ		1 * 50000000

//`define IS_USE_PLL	



`define INTERNAL_MEM_ADDR_BITS		8 //7
`define INTERNAL_MEM_VALUE		(2**`INTERNAL_MEM_ADDR_BITS) //256 //128 //200
`define INTERNAL_MEM_FILE		"mem.txt"

`define EXTERNAL_PRG_ADDR_E	524288

`define VIDEO1_ADDR_B			`EXTERNAL_PRG_ADDR_E
`define VIDEO1_ADDR_E			`VIDEO1_ADDR_B + 524288  //`VIDEO1_ADDR_B + (640*480)
  
  
`define RAM_TOTAL					`VIDEO1_ADDR_E
  


`define UNMODIFICABLE_ADDR_B	`VIDEO1_ADDR_B





  `define RS232_DATA_ADDR		'h fffffff0

  `define RS232_BAUD_RATE	9600
