`default_nettype none

module uareloaded_top (
	input         CLOCK_27,
`ifdef USE_CLOCK_50
	input         CLOCK_50,
`endif

	output        LED,
	output [VGA_BITS-1:0] VGA_R,
	output [VGA_BITS-1:0] VGA_G,
	output [VGA_BITS-1:0] VGA_B,
	output        VGA_HS,
	output        VGA_VS,
	output        VGA_BLANK,
	output        VGA_CLOCK,

	output [12:0] SDRAM_A,
	inout  [15:0] SDRAM_DQ,
	output        SDRAM_DQML,
	output        SDRAM_DQMH,
	output        SDRAM_nWE,
	output        SDRAM_nCAS,
	output        SDRAM_nRAS,
	output        SDRAM_nCS,
	output  [1:0] SDRAM_BA,
	output        SDRAM_CLK,
	output        SDRAM_CKE,
	
	output        SD_CS,
	output        SD_SCK,
	output        SD_MOSI,
	input         SD_MISO,
	
	inout 		 PS2_KEYBOARD_CLK,
	inout	       PS2_KEYBOARD_DAT,
	inout	       PS2_MOUSE_CLK,
	inout	       PS2_MOUSE_DAT,
	
	input  [5:0] JOYSTICK1,
	input  [5:0] JOYSTICK2,
	output       JOY_SELECT,

	output        I2S_BCK,
	output        I2S_LRCK,
	output        I2S_DATA,
	
	output        STM_RST = 1'b0,
	
	output        AUDIO_L,
	output        AUDIO_R,
	input         AUDIO_IN,
	input         UART_RX,
	output        UART_TX
);


`ifdef VGA_8BIT
localparam VGA_BITS = 8;
`else
localparam VGA_BITS = 6;
`endif


`ifndef NO_DIRECT_UPLOAD
wire         SPI_SS4,
`endif

wire SPI_SCK,SPI_DO,SPI_DI,SPI_SS2,SPI_SS3,CONF_DATA0;


pll_vga pll_vga
(
  .inclk0 (CLOCK_50),
  .c0     (VGA_CLOCK)
);



guest_top guest
(
 .CLOCK_27 (CLOCK_50),
 .SPI_SCK (spi_clk_int),
 .LED(tmp_led),
 .*
);

wire reset_n;
wire tmp_led;
wire ps2_keyboard_clk_in = PS2_KEYBOARD_CLK;
wire ps2_keyboard_clk_out;
wire ps2_keyboard_dat_in = PS2_KEYBOARD_DAT ;
wire ps2_keyboard_dat_out;
wire ps2_mouse_clk_in = PS2_MOUSE_CLK;
wire ps2_mouse_clk_out;
wire ps2_mouse_dat_in = PS2_MOUSE_DAT;
wire ps2_mouse_dat_out;

assign PS2_KEYBOARD_CLK = !ps2_keyboard_clk_out ? 1'b0 : 1'bZ;
assign PS2_KEYBOARD_DAT = !ps2_keyboard_dat_out ? 1'b0 : 1'bZ;
assign PS2_MOUSE_CLK    = !ps2_mouse_clk_out ? 1'b0 : 1'bZ;
assign PS2_MOUSE_DAT    = !ps2_mouse_dat_out ? 1'b0 : 1'bZ;

assign VGA_BLANK=1'b1;
assign LED=~tmp_led;

wire joy1={2'b1, JOYSTICK1[5],JOYSTICK1[4],JOYSTICK1[0],JOYSTICK1[1],JOYSTICK1[2],JOYSTICK1[3]};
wire joy2={2'b1, JOYSTICK2[5],JOYSTICK2[4],JOYSTICK2[0],JOYSTICK2[1],JOYSTICK2[2],JOYSTICK2[3]};
wire joy3=8'b1;
wire joy4=8'b1;


wire spi_clk_int;
assign SD_SCK = spi_clk_int;
 
substitute_mcu #(.sysclk_frequency(500)) controller
(
 .clk (CLOCK_50),
 .reset_in(1'b1),
 .reset_out(reset_n),
 
 .spi_miso(SD_MISO),
 .spi_mosi(SD_MOSI),
 .spi_clk(spi_clk_int),
 .spi_cs(SD_CS),
 .spi_fromguest(SPI_DO),
 .spi_toguest  (SPI_DI),
 .spi_ss2      (SPI_SS2),
 .spi_ss3      (SPI_SS3),
`ifndef NO_DIRECT_UPLOAD 
 .spi_ss4      (SPI_SS4),
`endif
 .conf_data0   (CONF_DATA0),
 
 .ps2k_clk_in  ( ps2_keyboard_clk_in),
 .ps2k_dat_in  ( ps2_keyboard_dat_in),
 .ps2k_clk_out ( ps2_keyboard_clk_out),
 .ps2k_dat_out ( ps2_keyboard_dat_out),
 .ps2m_clk_in  ( ps2_mouse_clk_in),
 .ps2m_dat_in  (ps2_mouse_dat_in),
 .ps2m_clk_out (ps2_mouse_clk_out),
 .ps2m_dat_out (ps2_mouse_dat_out),
 
 .joy1         (joy1),
 .joy2         (joy2),
 .joy3         (joy3),
 .joy4         (joy4),
 
 .buttons(4'b1111)
);
endmodule
