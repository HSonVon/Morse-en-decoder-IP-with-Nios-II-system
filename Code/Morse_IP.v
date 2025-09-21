module Morse_IP
#( 
    parameter DOT_TIME = 25_000_000,  
    parameter WAIT_TIME = 50_000_000 
) (
    input clk,                 
    input reset_n, 
	 
    // Avalon Signal
    input write,              
    input read,                 
    input [1:0] address,        
    input [31:0] writedata,     
    output reg [31:0] readdata,
	 
    // Conduit
	 input [7:0] inital,
	 input MODE,
    output reg [7:0] ascii_out,
    output reg dot_t,           
    output reg wait_t           
);

    reg [4:0] morse_code;        
    reg [2:0] length;
	 reg [1:0] signal;       
    reg [25:0] timer, dot_cnt, wait_cnt; 
	// reg MODE;
	 

    // FSM states
    localparam IDLE = 2'b00, DETECT = 2'b01, RECORD = 2'b10;
    reg [1:0] state, next_state;
	 
    // Avalon read/write logic
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            readdata = 32'b0;
        end else begin
            if (read) begin
                case (address)
                    2'd0: readdata = {31'b0, MODE};
                    2'd1: readdata = {27'b0, morse_code};
                    2'd2: readdata = {29'b0, length};
                    2'd3: readdata = {24'b0, ascii_out};
                    default: readdata = 32'b0;
                endcase
            end
            if (write) begin
                case (address)
                    2'd0: signal = writedata ;
                    default: ;
                endcase
            end
        end
    end

    // Dot and wait timing logic
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            dot_t = 1'b0;
            wait_t = 1'b0;
            dot_cnt = 26'd0;
            wait_cnt = 26'd0;
        end else begin
            if (dot_cnt == DOT_TIME) begin
                dot_t = ~dot_t;
                dot_cnt = 26'b0;
            end else begin
                dot_cnt = dot_cnt + 1'b1;
            end
            if (wait_cnt == WAIT_TIME) begin
                wait_t = ~wait_t;
                wait_cnt = 26'd0;
            end else begin
                wait_cnt = wait_cnt + 1'b1;
            end
        end
    end

    // FSM Logic
    always @(posedge clk, negedge signal[1]) begin
        if (!signal[1]) begin
            state = IDLE;
            morse_code = 5'b0;
            length = 3'b0;
            timer = 26'b0;
        end else 
		  if(!MODE) begin
		  		morse_code <= inital[4:0] ;
				length <= inital[7:5];
         end else begin
                case (state)
                    IDLE: begin
                        timer = 26'b0;
                        if (!signal[0]) begin 
									 length = length + 1'b1;
                            next_state = DETECT;
                        end else
									 next_state = IDLE;
                    end
                    DETECT: begin
                        if (!signal[0]) begin
                            timer = timer + 1'b1;
                        end else begin
                            if (timer < DOT_TIME) begin
                                morse_code = {morse_code[3:0], 1'b0};  // Append dot (0)
                            end else begin
                                morse_code = {morse_code[3:0], 1'b1};  // Append dash (1)
                            end
                            next_state = RECORD;
                        end
                    end
                    RECORD: begin
                        if (timer > WAIT_TIME) begin
                            next_state = IDLE;
                        end else  begin
                            timer = timer + 1'b1;
                        end
                    end
                endcase
                state = next_state;
            end 
    end
	 
	always @(*) begin
		case (length)
			3'd1: begin
				case (morse_code[0])
					1'b0: ascii_out = 8'h45;    // . E
					1'b1: ascii_out = 8'h54;    // - T
				endcase
			end
			3'd2: begin
				case (morse_code[1:0])
					2'b00: ascii_out = 8'h49;   // .. I
					2'b01: ascii_out = 8'h41;   // .- A
					2'b10: ascii_out = 8'h4E;   // -. N
					2'b11: ascii_out = 8'h4D;   // -- M
				endcase
			end
			3'd3: begin
				case (morse_code[2:0])
					3'b000: ascii_out = 8'h53;  // ... S
					3'b001: ascii_out = 8'h55;  // ..- U
					3'b010: ascii_out = 8'h52;  // .-. R
					3'b011: ascii_out = 8'h57;  // .-- W
					3'b100: ascii_out = 8'h44;  // -.. D
					3'b101: ascii_out = 8'h4B;  // -.- K
					3'b110: ascii_out = 8'h47;  // --. G
					3'b111: ascii_out = 8'h4F;  // --- O
				endcase
			end
			3'd4: begin
				case (morse_code[3:0])
					4'b0000: ascii_out = 8'h48;  // .... H
					4'b0001: ascii_out = 8'h56;  // ...- V
					4'b0010: ascii_out = 8'h46;  // ..-. F
				   4'b0011: ascii_out = 8'h32;  // ..-- 2
					4'b0100: ascii_out = 8'h4C;  // .-.. L
					4'b0101: ascii_out = 8'h5E;  // .-.- ^
					4'b0110: ascii_out = 8'h50;  // .--. P
					4'b0111: ascii_out = 8'h4A;  // .--- J
					4'b1000: ascii_out = 8'h42;  // -... B
					4'b1001: ascii_out = 8'h58;  // -..- X
					4'b1010: ascii_out = 8'h43;  // -.-. C
					4'b1011: ascii_out = 8'h59;  // -.-- Y
					4'b1100: ascii_out = 8'h5A;  // --.. Z
					4'b1101: ascii_out = 8'h51;  // --.- Q
					4'b1110: ascii_out = 8'h2B;  // ---. +
					4'b1111: ascii_out = 8'h2D;  // ---- -
				endcase
			end
			3'd5: begin
			case (morse_code[4:0])
					5'b00000: ascii_out = 8'h35;  // ..... 5
					5'b00001: ascii_out = 8'h34;  // ....- 4
					5'b00010: ascii_out = 8'h2A;  // ...-. *
					5'b00011: ascii_out = 8'h33;  // ...-- 3
					5'b01010: ascii_out = 8'h2E;  // .-.-. .
					5'b01011: ascii_out = 8'h22;  // .-.-- ' (canh Enter)
					5'b01110: ascii_out = 8'h3F;  // .---. ?
					5'b01111: ascii_out = 8'h31;  // .---- 1
					5'b10000: ascii_out = 8'h36;  // -.... 6
					5'b10001: ascii_out = 8'h7E;  // -...- ~
					5'b11000: ascii_out = 8'h37;  // --... 7
					5'b11001: ascii_out = 8'h27;  // --..- ` (ko shift tren tab)
					5'b11100: ascii_out = 8'h38;  // ---.. 8
					5'b11101: ascii_out = 8'h2F;  // ---.- /
					5'b11110: ascii_out = 8'h39;  // ----. 9
					5'b11111: ascii_out = 8'h3A;  // ----- 0
					default: ascii_out = 8'h5F;   // Lowbar _
				endcase
			end
			default: ascii_out = 8'h5F;// Unsupported morse_code in_code
		endcase
	end
endmodule 