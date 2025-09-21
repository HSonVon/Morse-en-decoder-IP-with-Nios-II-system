module Morse_top(
	input CLOCK_50,
	input [9:0] SW,
	input [3:0] KEY,
	output [15:0] GPIO,
	output [9:0] LEDR
);
Morse_hw sys(
		.button_external_connection_export(KEY[3:1]), // button_external_connection.export[1:0]
		.clk_clk(CLOCK_50),                            //                         clk.clk
		.gpio_external_connection_export(GPIO[15:0]),    //    gpio_external_connection.export
		.morse_hw_0_ascii_out_export(LEDR[7:0]),        //        morse_hw_0_ascii_out.export[7:0]
		.morse_hw_0_dot_time_export(LEDR[8]),         //         morse_hw_0_dot_time.export
		.morse_hw_0_mode_export(SW[9]),            //            morse_hw_0_mode.export
		.morse_hw_0_setup_export(SW[7:0]),           //           morse_hw_0_setup.export
		.morse_hw_0_wait_time_export(LEDR[9]),        //        morse_hw_0_wait_time.export
		.reset_reset_n(KEY[0]),                      //                       reset.reset_n
	);
endmodule 