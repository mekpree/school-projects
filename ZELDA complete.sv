module ZELDA (input logic [1:0]KEY,  

input logic [3:0]SW, // 4 bit switches 

output logic [0:0]LEDG,  

output logic [6:0]HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0); 

logic CLOCK, RESET;

assign CLOCK = ~KEY[0];
assign RESET = ~KEY[1];

assign LEDG[0] = HMS; 

logic [2:0]LOC_STATE; // Establishing internal nodes
logic [1:0]MS_STATE;
logic WIN, LOSE, GMS, LMS, HMS;


// Module instantiation using FSM and DEC modules 
LOC_FSM module1(SW[3],SW[2],SW[1],SW[0],CLOCK,RESET,HMS,GMS,LMS, WIN, LOSE, LOC_STATE);
MS_FSM module2(CLOCK, RESET, GMS, LMS, MS_STATE[1:0], HMS);
LOC_DEC module3(LOC_STATE, HEX6, HEX7);
OUT_DEC module4(WIN, LOSE, GMS, LMS, HEX0[6:0], HEX1[6:0], HEX2[6:0], HEX3[6:0]);
MS_DEC module5(MS_STATE[1:0], HEX4[6:0], HEX5[6:0]);
    
endmodule
  

module MS_DEC(input logic[1:0]MS_STATE, // 2 bit MS_STATE input 

output logic[6:0] HEX4, HEX5); // HEX4 & HEX5 both 7 bit 

  

always_comb 

case (MS_STATE) 

2'b00: 
begin 

HEX5 = 7'b0101011; // Displays n 
HEX4 = 7'b0010010; // Displays S 

end 

2'b01: 
begin 

HEX5 = 7'b0001001; // Displays H 
HEX4 = 7'b0010010; // Displays S 

end 

2'b10: 
begin 

HEX5 = 7'b1000111; // Displays L 
HEX4 = 7'b0010010; // Displays S 

end 

default: // Displays all active low
	begin  

HEX5 = 7'b1111111; 
HEX4 = 7'b1111111; 

	end 

endcase 
 

  

endmodule 

  

module LOC_DEC(input logic [2:0]LOC_STATE, // Defines LOC_STATE as 3 bit 

output logic [6:0]HEX6, HEX7); // Defines HEX6 and HEX7 as 7 bit outputs 

  

always_comb 

case (LOC_STATE) 

3'b000: 
begin // S0: JA 

HEX7 = 7'b1110001;  
HEX6 = 7'b0001000; 

end	 

3'b001: 
begin // S1: dd 

HEX7 = 7'b0100001; 
HEX6 = 7'b0100001; 

end 

3'b010: 
begin // S2: md 

HEX7 = 7'b0101010; 
HEX6 = 7'b0100001; 

end	 

3'b011: 
begin // S3: ZL 

HEX7 = 7'b1100100; 
HEX6 = 7'b1000111; 

end 

3'b100: 
begin // S4: UP 

HEX7 = 7'b1000001; 
HEX6 = 7'b0001100; 

end 

3'b101: 
begin // S5: HC 

HEX7 = 7'b0001001; 
HEX6 = 7'b1000110; 

end 

3'b110: 
begin // S6: dl 

HEX7 = 7'b0100001; 
HEX6 = 7'b1001111; 

end 

3'b111: 
begin // S7: ES 

HEX7 = 7'b0000110; 
HEX6 = 7'b0010010; 

end 

default: 
begin // Turns all 7 segments off for HEX7 and HEX6 

HEX7 = 7'b1111111; 
HEX6 = 7'b1111111; 

end 

endcase 
 

  

endmodule   

  

module OUT_DEC(input logic WIN,LOSE,GMS,LMS, 

output logic [6:0] HEX0,HEX1,HEX2,HEX3); // Defining inputs and outputs of module OUT_DEC 

  

always_comb begin 

case ({WIN, LOSE, GMS, LMS}) 

4'b0001: 
begin // State 0 LMS 

HEX3 = 7'b1000111; 

         HEX2 = 7'b1001100; 
         HEX1 = 7'b1011000; 
         HEX0 = 7'b0010010; 

      end 

      4'b0010: 
		begin // State 3 GMS 
         HEX3 = 7'b1000010; 
         HEX2 = 7'b1001100; 
         HEX1 = 7'b1011000; 
         HEX0 = 7'b0010010; 

      end 

      4'b0100: 
		begin // State 6 LOSE 

         HEX3 = 7'b1000111; 
         HEX2 = 7'b1000000; 
         HEX1 = 7'b0010010; 
         HEX0 = 7'b0000110; 
      end 

      4'b1000: 
		begin // State 7 WIN - Escape 

         HEX3 = 7'b1000011; 
         HEX2 = 7'b1100001; 
         HEX1 = 7'b1111001; 
         HEX0 = 7'b1001000; 

      end 

      default: 
		begin // Active-LOW states for S0,S1,S2,S3 
          HEX3 = 7'b1111111; 
          HEX2 = 7'b1111111; 
          HEX1 = 7'b1111111; 
          HEX0 = 7'b1111111; 

end 

endcase 

end 

  

endmodule 

  

module MS_FSM(input logic CLOCK,RESET,GMS,LMS, 

output logic [1:0]MS_STATE, 

output logic HMS); // Defining MS_FSM module 

logic [1:0] state, next_state; // Creating internal nodes for module

always_ff@(posedge CLOCK, posedge RESET) // Creating asynchronous flip flop
	if (RESET)
		begin 
			state <= 2'b00; // Reset leading back to state 0
		end
	else
		begin
		state <= next_state; // state gets next state 
		end

always_comb
	begin
	next_state = state;
	case (state)
		2'b00: // State 0, (No MS)
			begin 
				if (GMS)
					next_state = 2'b01;
				else
					next_state = 2'b00;
			end
		2'b01: // State 1: (Has MS)
			begin 
				if (LMS)
					next_state = 2'b10;
				else
					next_state = 2'b01;
			end
		2'b10: // State 2: Lost Sword 
			begin
				next_state = 2'b10; // Sword can't be recovered - stays in State 2
			end
		default:
			begin
				next_state = 2'b00;
			end
	endcase
	end
 assign MS_STATE = state;
 
 assign HMS = (state == 2'b01);
 
 endmodule
 

 // Location FSM
 module LOC_FSM(input logic UP,DOWN,LEFT,RIGHT,CLOCK,RESET,HMS,
 output logic GMS, LMS, WIN, LOSE,
 output logic[2:0]LOC_STATE);
 
 
 typedef enum logic [2:0] {J = 3'b000, DD = 3'b001, MD = 3'b010, Z = 3'b011 , UT = 3'b100, HC = 3'b101, D = 3'b110, E = 3'b111}
 statetype; 
 
 statetype state, next_state;
 
always_ff@(posedge CLOCK, posedge RESET)
	begin 
		if (RESET)
			state <= DD;
		else
			state <= next_state;
	end
	
always_comb // always_comb for next state 
	begin
		next_state = state;
		
	case(state)
		J: // Jail State
			begin
				if (RIGHT)
					next_state = DD;
				else 
					next_state = J;
			end
		DD: // Deep Dungeon 
			begin 
				if (UP)
					next_state = MD;
				else if (LEFT)
						next_state = J;
			end
		MD: // Mid Dungeon
			begin
				if (UP)
					next_state = UT;
					else if (RIGHT)
								next_state = Z;
					else if (DOWN)
								next_state = DD;
			end
		Z: // Zelda
			begin
				if (LEFT)
					next_state = MD;
			end
		UT: // Up Top
			begin
				if (UP)
					next_state = HC;
				else if (LEFT)
					next_state = J;
				else if (DOWN)
					next_state = MD;
			end
		HC: // Hyrule Castle
			begin 
				if (HMS)
					next_state = E;
				else
					next_state = D;
			end
		E: // Escape
			begin
				next_state = E;
			end
		D: // Die
			begin
				next_state = D;
			end
		endcase
	end
	
always_comb // Moore output logic
	begin
			GMS = 1'b0;
			LMS = 1'b0;
			WIN = 1'b0;
			LOSE = 1'b0;
			
			case (state) 
				J: // Jail, LMS
					LMS = 1'b1;
				Z: // Link gets mastersword
					GMS = 1'b1;
				D: // Link Dies, loses
					LOSE = 1'b1;
				E: // Link Escapes, Wins
					WIN = 1'b1;
				default:
					begin
						GMS = 1'b0;
						LMS = 1'b0;
						WIN = 1'b0;
						LOSE = 1'b0;
					end
			endcase
	end
		
	assign LOC_STATE = state;
endmodule
			
								
	
 
		
 

 

 

 