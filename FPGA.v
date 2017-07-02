/******************************************************
*
* 	NAME:	CSR_traversal
*
* 	DESCRIPTION:   
*	Implementing the CSR NFA traversal by 
*	traversing in BFS fashion and reading 
*	the CSR stored in the Block memory.
*  
* 	REVISION HISTORY:
*	Date		Programmer		Description/Version
*	05/03/17	Kunal Buch		Version 1.0 [Parallel Traversal]
*	05/13/17	Kunal Buch		Version 1.1 [Parallel Traversal of vector length = 8 and clean read with read.tcl]
*	05/27/17	Kunal Buch		Version 1.2 [Parallel Traversal of vector length = 16]
*	06/07/27	Kunal Buch		Version 1.3	[Parallel Traversal of vector length = 128]
*
********************************************************/
`timescale 1 ns/1 ps

module CSR_traversal (clk, reset, size, rd_address, rd_bus, input_char_flag, input_char);

	// interface signals
	input	[23:0]		size;
	input 	[4095:0]	rd_bus;
	input 				clk;
	input 				reset;
	input	[7:0]		input_char;
	
	output 	[16:0]		rd_address;
	output 				input_char_flag;

	reg 	[16:0]		rd_address;
	reg 				input_char_flag;
	
	
	integer iter;
	parameter size_range = 7;
	
	// internal signals local to the block
	reg	[24:0]		offset;
	reg [9:0]		flag;
	reg [23:0]		first;
	// reg [9:0]		last;
	reg [size_range - 1:0]			next;
	reg [size_range - 1:0]			current;
	
	reg	[7:0]		block_mem_state_info_transition		[127:0];
	reg	[23:0]		block_mem_state_info_target_state	[127:0];
	reg [23:0]		range;
	reg [23:0]		range_last;
	reg [23:0]		range_int;
	reg [23:0]		up_counter;
	reg [23:0]		up_counter_int;
	// reg [7:0]		input_char;
	reg [2:0]		state;
	reg [24:0]		rd_address_int;
	reg 			flag_iter_check;
	reg 			flag_check;
	reg [23:0]		active 	[size_range - 1:0];
	// reg 			flag_state_reset;
	reg 			range_2_state;
	reg 			range_1_state;
	
	reg [23:0]		i;
	
	// adding parallel part for caching
	
	// starting params
	parameter mem0 = 31;
	parameter mem1 = mem0 + 32;  	//63;
	parameter mem2 = mem1 + 32;  	//95;
	parameter mem3 = mem2 + 32;  	//127;
	parameter mem4 = mem3 + 32;  	//159;
	parameter mem5 = mem4 + 32;  	//191;
	parameter mem6 = mem5 + 32;  	//223;
	parameter mem7 = mem6 + 32;  	//255;
	parameter mem8 = mem7 + 32;  	//287;
	parameter mem9 = mem8 + 32;  	//319;
	parameter mem10 = mem9 + 32;  	//351;
	parameter mem11 = mem10 + 32;  	//383;
	parameter mem12 = mem11 + 32;  	//415;
	parameter mem13 = mem12 + 32;  	//447;
	parameter mem14 = mem13 + 32;  	//469;
	parameter mem15 = mem14 + 32;  	//511;
	parameter mem16 = mem15 + 32;
	parameter mem17 = mem16 + 32;  	//63;
	parameter mem18 = mem17 + 32;  	//95;
	parameter mem19 = mem18 + 32;  	//127;
	parameter mem20 = mem19 + 32;  	//159;
	parameter mem21 = mem20 + 32;  	//191;
	parameter mem22 = mem21 + 32;  	//223;
	parameter mem23 = mem22 + 32;  	//255;
	parameter mem24 = mem23 + 32;  	//287;
	parameter mem25 = mem24 + 32;  	//319;
	parameter mem26 = mem25 + 32;  	//351;
	parameter mem27 = mem26 + 32;  	//383;
	parameter mem28 = mem27 + 32;  	//415;
	parameter mem29 = mem28 + 32;  	//447;
	parameter mem30 = mem29 + 32;  	//469;
	parameter mem31 = mem30 + 32;  	//511;
	parameter mem32 = mem31 + 32;
	parameter mem33 = mem32 + 32;  	//63;
	parameter mem34 = mem33 + 32;  	//95;
	parameter mem35 = mem34 + 32;  	//127;
	parameter mem36 = mem35 + 32;  	//159;
	parameter mem37 = mem36 + 32;  	//191;
	parameter mem38 = mem37 + 32;  	//223;
	parameter mem39 = mem38 + 32;  	//255;
	parameter mem40 = mem39 + 32;  	//287;
	parameter mem41 = mem40 + 32;  	//319;
	parameter mem42 = mem41 + 32;  	//351;
	parameter mem43 = mem42 + 32;  	//383;
	parameter mem44 = mem43 + 32;  	//415;
	parameter mem45 = mem44 + 32;  	//447;
	parameter mem46 = mem45 + 32;  	//469;
	parameter mem47 = mem46 + 32;  	//511;
	parameter mem48 = mem47 + 32;
	parameter mem49 = mem48 + 32;  	//63;
	parameter mem50 = mem49 + 32;  	//95;
	parameter mem51 = mem50 + 32;  	//127;
	parameter mem52 = mem51 + 32;  	//159;
	parameter mem53 = mem52 + 32;  	//191;
	parameter mem54 = mem53 + 32;  	//223;
	parameter mem55 = mem54 + 32;  	//255;
	parameter mem56 = mem55 + 32;  	//287;
	parameter mem57 = mem56 + 32;  	//319;
	parameter mem58 = mem57 + 32;  	//351;
	parameter mem59 = mem58 + 32;  	//383;
	parameter mem60 = mem59 + 32;  	//415;
	parameter mem61 = mem60 + 32;  	//447;
	parameter mem62 = mem61 + 32;  	//469;
	parameter mem63 = mem62 + 32;  	//511;
	parameter mem64 = mem63 + 32;
	parameter mem65 = mem64 + 32;  	//95;
	parameter mem66 = mem65 + 32;  	//127;
	parameter mem67 = mem66 + 32;  	//159;
	parameter mem68 = mem67 + 32;  	//191;
	parameter mem69 = mem68 + 32;  	//223;
	parameter mem70 = mem69 + 32;  	//255;
	parameter mem71 = mem70 + 32;  	//287;
	parameter mem72 = mem71 + 32;  	//319;
	parameter mem73 = mem72 + 32;  	//351;
	parameter mem74 = mem73 + 32;  	//383;
	parameter mem75 = mem74 + 32;  	//415;
	parameter mem76 = mem75 + 32;  	//447;
	parameter mem77 = mem76 + 32;  	//469;
	parameter mem78 = mem77 + 32;  	//511;
	parameter mem79 = mem78 + 32;
	parameter mem80 = mem79 + 32;  	//63;
	parameter mem81 = mem80 + 32;  	//95;
	parameter mem82 = mem81 + 32;  	//127;
	parameter mem83 = mem82 + 32;  	//159;
	parameter mem84 = mem83 + 32;  	//191;
	parameter mem85 = mem84 + 32;  	//223;
	parameter mem86 = mem85 + 32;  	//255;
	parameter mem87 = mem86 + 32;  	//287;
	parameter mem88 = mem87 + 32;  	//319;
	parameter mem89 = mem88 + 32;  	//351;
	parameter mem90 = mem89 + 32;  	//383;
	parameter mem91 = mem90 + 32;  	//415;
	parameter mem92 = mem91 + 32;  	//447;
	parameter mem93 = mem92 + 32;  	//469;
	parameter mem94 = mem93 + 32;  	//511;
	parameter mem95 = mem94 + 32;
	parameter mem96 = mem95 + 32;  	//63;
	parameter mem97 = mem96 + 32;  	//95;
	parameter mem98 = mem97 + 32;  	//127;
	parameter mem99 = mem98 + 32;  	//159;
	parameter mem100 = mem99 + 32;  	//191;
	parameter mem101 = mem100 + 32;  	//223;
	parameter mem102 = mem101 + 32;  	//255;
	parameter mem103 = mem102 + 32;  	//287;
	parameter mem104 = mem103 + 32;  	//319;
	parameter mem105 = mem104 + 32;  	//351;
	parameter mem106 = mem105 + 32;  	//383;
	parameter mem107 = mem106 + 32;  	//415;
	parameter mem108 = mem107 + 32;  	//447;
	parameter mem109 = mem108 + 32;  	//469;
	parameter mem110 = mem109 + 32;  	//511;
	parameter mem111 = mem110 + 32;
	parameter mem112 = mem111 + 32;  	//63;
	parameter mem113 = mem112 + 32;  	//95;
	parameter mem114 = mem113 + 32;  	//127;
	parameter mem115 = mem114 + 32;  	//159;
	parameter mem116 = mem115 + 32;  	//191;
	parameter mem117 = mem116 + 32;  	//223;
	parameter mem118 = mem117 + 32;  	//255;
	parameter mem119 = mem118 + 32;  	//287;
	parameter mem120 = mem119 + 32;  	//319;
	parameter mem121 = mem120 + 32;  	//351;
	parameter mem122 = mem121 + 32;  	//383;
	parameter mem123 = mem122 + 32;  	//415;
	parameter mem124 = mem123 + 32;  	//447;
	parameter mem125 = mem124 + 32;  	//469;
	parameter mem126 = mem125 + 32;  	//511;
	parameter mem127 = mem126 + 32;  	//63;
	
	
	//ending params
	parameter mem1_e = 32;
	parameter mem2_e = mem1_e + 32;  	//64;
	parameter mem3_e = mem2_e + 32;  	//96;
	parameter mem4_e = mem3_e + 32;  	//128;
	parameter mem5_e = mem4_e + 32;  	//160;
	parameter mem6_e = mem5_e + 32;  	//192;
	parameter mem7_e = mem6_e + 32;  	//224;
	parameter mem8_e = mem7_e + 32;  	//256;
	parameter mem9_e = mem8_e + 32;  	//288;
	parameter mem10_e = mem9_e + 32;  	//320;
	parameter mem11_e = mem10_e + 32;  	//352;
	parameter mem12_e = mem11_e + 32;  	//384;
	parameter mem13_e = mem12_e + 32;  	//416;
	parameter mem14_e = mem13_e + 32;  	//448;
	parameter mem15_e = mem14_e + 32;  	//480;
	parameter mem16_e = mem15_e + 32;
	parameter mem17_e = mem16_e + 32;  	//64;
	parameter mem18_e = mem17_e + 32;  	//96;
	parameter mem19_e = mem18_e + 32;  	//128;
	parameter mem20_e = mem19_e + 32;  	//160;
	parameter mem21_e = mem20_e + 32;  	//192;
	parameter mem22_e = mem21_e + 32;  	//224;
	parameter mem23_e = mem22_e + 32;  	//256;
	parameter mem24_e = mem23_e + 32;  	//288;
	parameter mem25_e = mem24_e + 32;  	//320;
	parameter mem26_e = mem25_e + 32;  	//352;
	parameter mem27_e = mem26_e + 32;  	//384;
	parameter mem28_e = mem27_e + 32;  	//416;
	parameter mem29_e = mem28_e + 32;  	//448;
	parameter mem30_e = mem29_e + 32;  	//480;
	parameter mem31_e = mem30_e + 32;
	parameter mem32_e = mem31_e + 32;  	//64;
	parameter mem33_e = mem32_e + 32;  	//96;
	parameter mem34_e = mem33_e + 32;  	//128;
	parameter mem35_e = mem34_e + 32;  	//160;
	parameter mem36_e = mem35_e + 32;  	//192;
	parameter mem37_e = mem36_e + 32;  	//224;
	parameter mem38_e = mem37_e + 32;  	//256;
	parameter mem39_e = mem38_e + 32;  	//288;
	parameter mem40_e = mem39_e + 32;  	//320;
	parameter mem41_e = mem40_e + 32;  	//352;
	parameter mem42_e = mem41_e + 32;  	//384;
	parameter mem43_e = mem42_e + 32;  	//416;
	parameter mem44_e = mem43_e + 32;  	//448;
	parameter mem45_e = mem44_e + 32;  	//480;
	parameter mem46_e = mem45_e + 32;
	parameter mem47_e = mem46_e + 32;  	//64;
	parameter mem48_e = mem47_e + 32;  	//96;
	parameter mem49_e = mem48_e + 32;  	//128;
	parameter mem50_e = mem49_e + 32;  	//160;
	parameter mem51_e = mem50_e + 32;  	//192;
	parameter mem52_e = mem51_e + 32;  	//224;
	parameter mem53_e = mem52_e + 32;  	//256;
	parameter mem54_e = mem53_e + 32;  	//288;
	parameter mem55_e = mem54_e + 32;  	//320;
	parameter mem56_e = mem55_e + 32;  	//352;
	parameter mem57_e = mem56_e + 32;  	//384;
	parameter mem58_e = mem57_e + 32;  	//416;
	parameter mem59_e = mem58_e + 32;  	//448;
	parameter mem60_e = mem59_e + 32;  	//480;
	parameter mem61_e = mem60_e + 32;  	//416;
	parameter mem62_e = mem61_e + 32;  	//448;
	parameter mem63_e = mem62_e + 32;  	//480;
	parameter mem64_e = mem63_e + 32;
	parameter mem65_e = mem64_e + 32;  	//95;
	parameter mem66_e = mem65_e + 32;  	//127;
	parameter mem67_e = mem66_e + 32;  	//159;
	parameter mem68_e = mem67_e + 32;  	//191;
	parameter mem69_e = mem68_e + 32;  	//223;
	parameter mem70_e = mem69_e + 32;  	//255;
	parameter mem71_e = mem70_e + 32;  	//287;
	parameter mem72_e = mem71_e + 32;  	//319;
	parameter mem73_e = mem72_e + 32;  	//351;
	parameter mem74_e = mem73_e + 32;  	//383;
	parameter mem75_e = mem74_e + 32;  	//415;
	parameter mem76_e = mem75_e + 32;  	//447;
	parameter mem77_e = mem76_e + 32;  	//469;
	parameter mem78_e = mem77_e + 32;  	//511;
	parameter mem79_e = mem78_e + 32;
	parameter mem80_e = mem79_e + 32;  	//63;
	parameter mem81_e = mem80_e + 32;  	//95;
	parameter mem82_e = mem81_e + 32;  	//127;
	parameter mem83_e = mem82_e + 32;  	//159;
	parameter mem84_e = mem83_e + 32;  	//191;
	parameter mem85_e = mem84_e + 32;  	//223;
	parameter mem86_e = mem85_e + 32;  	//255;
	parameter mem87_e = mem86_e + 32;  	//287;
	parameter mem88_e = mem87_e + 32;  	//319;
	parameter mem89_e = mem88_e + 32;  	//351;
	parameter mem90_e = mem89_e + 32;  	//383;
	parameter mem91_e = mem90_e + 32;  	//415;
	parameter mem92_e = mem91_e + 32;  	//447;
	parameter mem93_e = mem92_e + 32;  	//469;
	parameter mem94_e = mem93_e + 32;  	//511;
	parameter mem95_e = mem94_e + 32;
	parameter mem96_e = mem95_e + 32;  	//63;
	parameter mem97_e = mem96_e + 32;  	//95;
	parameter mem98_e = mem97_e + 32;  	//127;
	parameter mem99_e = mem98_e + 32;  	//159;
	parameter mem100_e = mem99_e + 32;  	//191;
	parameter mem101_e = mem100_e + 32;  	//223;
	parameter mem102_e = mem101_e + 32;  	//255;
	parameter mem103_e = mem102_e + 32;  	//287;
	parameter mem104_e = mem103_e + 32;  	//319;
	parameter mem105_e = mem104_e + 32;  	//351;
	parameter mem106_e = mem105_e + 32;  	//383;
	parameter mem107_e = mem106_e + 32;  	//415;
	parameter mem108_e = mem107_e + 32;  	//447;
	parameter mem109_e = mem108_e + 32;  	//469;
	parameter mem110_e = mem109_e + 32;  	//511;
	parameter mem111_e = mem110_e + 32;
	parameter mem112_e = mem111_e + 32;  	//63;
	parameter mem113_e = mem112_e + 32;  	//95;
	parameter mem114_e = mem113_e + 32;  	//127;
	parameter mem115_e = mem114_e + 32;  	//159;
	parameter mem116_e = mem115_e + 32;  	//191;
	parameter mem117_e = mem116_e + 32;  	//223;
	parameter mem118_e = mem117_e + 32;  	//255;
	parameter mem119_e = mem118_e + 32;  	//287;
	parameter mem120_e = mem119_e + 32;  	//319;
	parameter mem121_e = mem120_e + 32;  	//351;
	parameter mem122_e = mem121_e + 32;  	//383;
	parameter mem123_e = mem122_e + 32;  	//415;
	parameter mem124_e = mem123_e + 32;  	//447;
	parameter mem125_e = mem124_e + 32;  	//469;
	parameter mem126_e = mem125_e + 32;  	//511;
	parameter mem127_e = mem126_e + 32;  	//63;
	
	
	reg [31:0]		cache	[127:0];
	reg [31:0]		cache_temp;
	reg 			range_next;
	reg [24:0]		cache_line_no;
	reg [5:0]		current_cached;
	reg [7:0]		block_offset;
	reg [7:0]		block_offset_flag_0;
	reg [7:0]		block_offset_plus_one;
	reg [7:0]		block_offset_plus_one_reg;
	reg [7:0]		block_offset_reg;
	reg [1:0]		flag_1_or_2;
	reg [7:0]		no_cached_blocks;
	reg [7:0]		no_cached_blocks_int;
	reg [7:0]		no_cached_blocks_flag_0;
	reg [7:0]		no_cached_blocks_flag_1;
	reg [7:0]		no_cached_blocks_flag_2;
	reg [7:0]		no_cached_blocks_flag_2_prev;
	reg [1:0]		flag_2;
	
	reg check;
	
	always@(posedge clk)
	begin
		if(reset)
		begin
			
			i <= 0;
			state <= 0;
			//flag <= 0;
			input_char_flag <= 1;
			
			range_2_state <= 0;
			range_1_state <= 0;
			range_next <= 0;
			
			
			current[size_range - 1:1] <= 0;
			next <= 0;
			
			for(iter = 1; iter < size_range; iter = iter + 1)
			begin
				active[iter] <= 0;
			end
			
			current[0] <= 1;
			//next[0] <= 0;
			active[0] <= 1;
			
			
			range <= 0;
			flag_check <= 0;			
		end
		else
		begin
		
			if(current[i] == 1 && state == 0)
			begin
				input_char_flag <= 0;
				rd_address <= cache_line_no;
				block_offset_reg <= block_offset;
				block_offset_plus_one_reg <= block_offset_plus_one;
				state <= 1;
			end
			else if(state == 1)
			begin
				if(block_offset_reg == 127)
				begin
					rd_address <= cache_line_no + 1;
				end
				state <= 2;
			end
			else if(state == 2)
			begin
				if(block_offset_reg != 127)
				begin
					range <= cache[block_offset_plus_one_reg] - cache[block_offset_reg];
					up_counter <= cache[block_offset_reg];
					flag <= 0;
					state <= 3;
				end
				else 
				begin
					if(range_next == 0)
					begin
						range_next <= 1;
						cache_temp <= cache[127];
					end
					else if(range_next == 1)
					begin
						range_next <= 0;
						
						range <= cache[0] - cache_temp;
						up_counter <= cache_temp;
						flag <= 0;
						state <= 3;
						
					end
				end
				check <= 0;
			end
			else if(state == 3)
			begin
				
				if(range > 0)
				begin
					if(flag == 0)
					begin
						rd_address <= cache_line_no;
						flag_1_or_2 <= 0;
						block_offset_flag_0 <= block_offset;
						no_cached_blocks_flag_0 <= no_cached_blocks;
						//range_last <= range;
						range <= range_int;
						up_counter <= up_counter_int;
						
						flag <= 1;
					end
					else if(flag == 1)
					begin
						flag <= 2;
						rd_address <= cache_line_no;
						flag_1_or_2 <= 1;
						no_cached_blocks_flag_1 <= no_cached_blocks;
						range_last <= range;
						range <= range_int;
						up_counter <= up_counter_int;
						flag_2 <= 0;
						
					end
					else if(flag == 2)
					begin
						
						if(flag_2 == 0)
						begin
							
							if(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 1)
							begin
								if(block_mem_state_info_transition[0] == input_char)
									next[block_mem_state_info_target_state[0]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[1] == input_char)
									next[block_mem_state_info_target_state[1]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[2] == input_char)
									next[block_mem_state_info_target_state[2]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[3] == input_char)
									next[block_mem_state_info_target_state[3]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 1)
							)							
							begin
								if(block_mem_state_info_transition[4] == input_char)
									next[block_mem_state_info_target_state[4]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 1)
							)							
							begin
								if(block_mem_state_info_transition[5] == input_char)
									next[block_mem_state_info_target_state[5]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 1)
							)							
							begin
								if(block_mem_state_info_transition[6] == input_char)
									next[block_mem_state_info_target_state[6]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[7] == input_char)
									next[block_mem_state_info_target_state[7]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[8] == input_char)
									next[block_mem_state_info_target_state[8]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[9] == input_char)
									next[block_mem_state_info_target_state[9]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[10] == input_char)
									next[block_mem_state_info_target_state[10]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[11] == input_char)
									next[block_mem_state_info_target_state[11]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[12] == input_char)
									next[block_mem_state_info_target_state[12]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[13] == input_char)
									next[block_mem_state_info_target_state[13]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[14] == input_char)
									next[block_mem_state_info_target_state[14]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[15] == input_char)
									next[block_mem_state_info_target_state[15]] <= 1;
							end
							
							/********* First one till 15*******/
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 1)
							)							
							begin
								if(block_mem_state_info_transition[16] == input_char)
									next[block_mem_state_info_target_state[16]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[17] == input_char)
									next[block_mem_state_info_target_state[17]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[18] == input_char)
									next[block_mem_state_info_target_state[18]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[19] == input_char)
									next[block_mem_state_info_target_state[19]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[20] == input_char)
									next[block_mem_state_info_target_state[20]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[21] == input_char)
									next[block_mem_state_info_target_state[21]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[22] == input_char)
									next[block_mem_state_info_target_state[22]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[23] == input_char)
									next[block_mem_state_info_target_state[23]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[24] == input_char)
									next[block_mem_state_info_target_state[24]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[25] == input_char)
									next[block_mem_state_info_target_state[25]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[26] == input_char)
									next[block_mem_state_info_target_state[26]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[27] == input_char)
									next[block_mem_state_info_target_state[27]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[28] == input_char)
									next[block_mem_state_info_target_state[28]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[29] == input_char)
									next[block_mem_state_info_target_state[29]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[30] == input_char)
									next[block_mem_state_info_target_state[30]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[31] == input_char)
									next[block_mem_state_info_target_state[31]] <= 1;
							end
							
							/********* second one till 31*******/
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[32] == input_char)
									next[block_mem_state_info_target_state[32]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[33] == input_char)
									next[block_mem_state_info_target_state[33]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[34] == input_char)
									next[block_mem_state_info_target_state[34]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[35] == input_char)
									next[block_mem_state_info_target_state[35]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[36] == input_char)
									next[block_mem_state_info_target_state[36]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[37] == input_char)
									next[block_mem_state_info_target_state[37]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[38] == input_char)
									next[block_mem_state_info_target_state[38]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[39] == input_char)
									next[block_mem_state_info_target_state[39]] <= 1;
							end
						
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[40] == input_char)
									next[block_mem_state_info_target_state[40]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[41] == input_char)
									next[block_mem_state_info_target_state[41]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[42] == input_char)
									next[block_mem_state_info_target_state[42]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[43] == input_char)
									next[block_mem_state_info_target_state[43]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[44] == input_char)
									next[block_mem_state_info_target_state[44]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 46) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 45 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[45] == input_char)
									next[block_mem_state_info_target_state[45]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 47) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 46) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 45 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 46 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[46] == input_char)
									next[block_mem_state_info_target_state[46]] <= 1;
							end
						
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 48) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 47) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 46) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 45 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 46 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 47 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[47] == input_char)
									next[block_mem_state_info_target_state[47]] <= 1;
							end
							
							/********* third one till 47*******/
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 49) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 48) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 47) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 46) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 45 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 46 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 47 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 48 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[48] == input_char)
									next[block_mem_state_info_target_state[48]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 50) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 49) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 48) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 47) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 46) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 45 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 46 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 47 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 48 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 49 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[49] == input_char)
									next[block_mem_state_info_target_state[49]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 51) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 50) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 49) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 48) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 47) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 46) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 45 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 46 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 47 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 48 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 49 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 50 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[50] == input_char)
									next[block_mem_state_info_target_state[50]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 52) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 51) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 50) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 49) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 48) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 47) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 46) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 45 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 46 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 47 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 48 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 49 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 50 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 51 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[51] == input_char)
									next[block_mem_state_info_target_state[51]] <= 1;
							end
						
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 53) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 52) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 51) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 50) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 49) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 48) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 47) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 46) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 45 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 46 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 47 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 48 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 49 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 50 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 51 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 52 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[52] == input_char)
									next[block_mem_state_info_target_state[52]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 54) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 53) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 52) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 51) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 50) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 49) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 48) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 47) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 46) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 45 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 46 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 47 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 48 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 49 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 50 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 51 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 52 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 53 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[53] == input_char)
									next[block_mem_state_info_target_state[53]] <= 1;
							end
						
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 55) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 54) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 53) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 52) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 51) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 50) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 49) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 48) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 47) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 46) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 45 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 46 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 47 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 48 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 49 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 50 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 51 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 52 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 53 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 54 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[54] == input_char)
									next[block_mem_state_info_target_state[54]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 56) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 55) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 54) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 53) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 52) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 51) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 50) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 49) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 48) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 47) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 46) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 45 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 46 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 47 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 48 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 49 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 50 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 51 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 52 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 53 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 54 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 55 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[55] == input_char)
									next[block_mem_state_info_target_state[55]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 57) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 56) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 55) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 54) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 53) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 52) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 51) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 50) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 49) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 48) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 47) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 46) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 45 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 46 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 47 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 48 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 49 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 50 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 51 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 52 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 53 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 54 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 55 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 56 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[56] == input_char)
									next[block_mem_state_info_target_state[56]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 58) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 57) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 56) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 55) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 54) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 53) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 52) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 51) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 50) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 49) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 48) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 47) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 46) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 45 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 46 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 47 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 48 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 49 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 50 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 51 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 52 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 53 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 54 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 55 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 56 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 57 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[57] == input_char)
									next[block_mem_state_info_target_state[57]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 59) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 58) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 57) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 56) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 55) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 54) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 53) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 52) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 51) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 50) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 49) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 48) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 47) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 46) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 45 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 46 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 47 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 48 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 49 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 50 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 51 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 52 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 53 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 54 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 55 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 56 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 57 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 58 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[58] == input_char)
									next[block_mem_state_info_target_state[58]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 60) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 59) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 58) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 57) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 56) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 55) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 54) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 53) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 52) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 51) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 50) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 49) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 48) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 47) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 46) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 45 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 46 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 47 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 48 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 49 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 50 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 51 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 52 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 53 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 54 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 55 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 56 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 57 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 58 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 59 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[59] == input_char)
									next[block_mem_state_info_target_state[59]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 61) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 60) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 59) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 58) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 57) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 56) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 55) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 54) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 53) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 52) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 51) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 50) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 49) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 48) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 47) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 46) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 45 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 46 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 47 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 48 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 49 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 50 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 51 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 52 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 53 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 54 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 55 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 56 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 57 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 58 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 59 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 60 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[60] == input_char)
									next[block_mem_state_info_target_state[60]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 62) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 61) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 60) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 59) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 58) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 57) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 56) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 55) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 54) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 53) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 52) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 51) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 50) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 49) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 48) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 47) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 46) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 45 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 46 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 47 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 48 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 49 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 50 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 51 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 52 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 53 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 54 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 55 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 56 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 57 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 58 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 59 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 60 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 61 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[61] == input_char)
									next[block_mem_state_info_target_state[61]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 63) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 62) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 61) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 60) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 59) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 58) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 57) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 56) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 55) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 54) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 53) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 52) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 51) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 50) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 49) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 48) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 47) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 46) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 45 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 46 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 47 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 48 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 49 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 50 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 51 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 52 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 53 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 54 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 55 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 56 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 57 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 58 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 59 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 60 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 61 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 62 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[62] == input_char)
									next[block_mem_state_info_target_state[62]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 64) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 63) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 62) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 61) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 60) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 59) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 58) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 57) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 56) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 55) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 54) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 53) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 52) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 51) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 50) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 49) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 48) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 47) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 46) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 45 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 46 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 47 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 48 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 49 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 50 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 51 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 52 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 53 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 54 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 55 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 56 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 57 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 58 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 59 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 60 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 61 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 62 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 63 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[63] == input_char)
									next[block_mem_state_info_target_state[63]] <= 1;
							end
							
							/**----------------------------**/
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 65) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 64) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 63) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 62) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 61) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 60) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 59) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 58) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 57) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 56) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 55) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 54) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 53) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 52) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 51) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 50) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 49) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 48) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 47) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 46) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 45 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 46 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 47 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 48 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 49 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 50 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 51 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 52 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 53 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 54 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 55 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 56 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 57 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 58 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 59 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 60 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 61 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 62 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 63 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 64 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[64] == input_char)
									next[block_mem_state_info_target_state[64]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 66) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 65) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 64) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 63) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 62) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 61) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 60) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 59) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 58) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 57) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 56) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 55) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 54) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 53) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 52) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 51) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 50) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 49) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 48) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 47) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 46) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 45 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 46 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 47 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 48 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 49 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 50 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 51 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 52 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 53 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 54 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 55 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 56 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 57 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 58 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 59 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 60 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 61 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 62 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 63 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 64 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 65 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[65] == input_char)
									next[block_mem_state_info_target_state[65]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 67) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 66) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 65) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 64) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 63) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 62) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 61) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 60) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 59) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 58) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 57) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 56) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 55) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 54) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 53) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 52) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 51) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 50) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 49) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 48) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 47) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 46) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 45 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 46 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 47 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 48 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 49 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 50 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 51 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 52 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 53 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 54 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 55 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 56 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 57 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 58 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 59 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 60 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 61 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 62 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 63 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 64 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 65 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 66 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[66] == input_char)
									next[block_mem_state_info_target_state[66]] <= 1;
							end
						
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 68) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 67) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 66) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 65) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 64) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 63) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 62) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 61) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 60) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 59) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 58) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 57) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 56) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 55) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 54) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 53) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 52) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 51) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 50) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 49) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 48) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 47) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 46) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 45 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 46 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 47 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 48 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 49 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 50 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 51 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 52 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 53 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 54 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 55 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 56 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 57 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 58 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 59 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 60 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 61 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 62 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 63 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 64 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 65 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 66 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 67 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[67] == input_char)
									next[block_mem_state_info_target_state[67]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 69) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 68) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 67) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 66) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 65) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 64) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 63) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 62) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 61) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 60) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 59) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 58) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 57) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 56) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 55) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 54) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 53) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 52) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 51) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 50) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 49) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 48) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 47) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 46) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 45 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 46 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 47 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 48 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 49 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 50 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 51 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 52 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 53 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 54 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 55 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 56 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 57 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 58 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 59 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 60 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 61 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 62 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 63 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 64 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 65 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 66 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 67 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 68 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[68] == input_char)
									next[block_mem_state_info_target_state[68]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 70) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 69) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 68) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 67) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 66) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 65) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 64) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 63) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 62) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 61) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 60) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 59) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 58) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 57) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 56) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 55) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 54) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 53) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 52) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 51) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 50) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 49) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 48) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 47) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 46) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 45 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 46 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 47 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 48 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 49 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 50 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 51 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 52 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 53 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 54 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 55 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 56 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 57 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 58 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 59 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 60 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 61 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 62 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 63 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 64 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 65 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 66 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 67 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 68 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 69 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[69] == input_char)
									next[block_mem_state_info_target_state[69]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 71) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 70) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 69) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 68) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 67) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 66) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 65) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 64) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 63) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 62) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 61) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 60) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 59) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 58) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 57) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 56) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 55) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 54) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 53) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 52) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 51) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 50) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 49) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 48) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 47) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 46) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 45 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 46 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 47 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 48 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 49 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 50 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 51 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 52 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 53 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 54 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 55 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 56 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 57 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 58 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 59 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 60 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 61 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 62 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 63 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 64 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 65 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 66 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 67 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 68 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 69 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 70 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[70] == input_char)
									next[block_mem_state_info_target_state[70]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 72) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 71) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 70) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 69) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 68) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 67) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 66) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 65) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 64) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 63) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 62) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 61) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 60) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 59) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 58) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 57) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 56) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 55) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 54) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 53) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 52) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 51) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 50) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 49) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 48) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 47) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 46) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 45 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 46 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 47 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 48 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 49 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 50 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 51 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 52 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 53 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 54 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 55 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 56 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 57 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 58 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 59 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 60 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 61 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 62 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 63 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 64 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 65 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 66 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 67 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 68 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 69 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 70 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 71 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[71] == input_char)
									next[block_mem_state_info_target_state[71]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 73) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 72) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 71) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 70) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 69) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 68) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 67) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 66) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 65) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 64) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 63) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 62) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 61) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 60) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 59) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 58) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 57) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 56) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 55) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 54) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 53) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 52) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 51) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 50) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 49) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 48) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 47) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 46) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 45 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 46 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 47 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 48 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 49 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 50 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 51 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 52 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 53 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 54 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 55 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 56 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 57 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 58 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 59 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 60 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 61 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 62 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 63 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 64 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 65 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 66 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 67 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 68 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 69 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 70 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 71 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 72 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[72] == input_char)
									next[block_mem_state_info_target_state[72]] <= 1;
							end
						
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 74) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 73) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 72) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 71) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 70) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 69) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 68) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 67) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 66) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 65) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 64) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 63) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 62) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 61) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 60) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 59) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 58) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 57) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 56) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 55) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 54) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 53) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 52) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 51) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 50) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 49) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 48) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 47) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 46) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 45 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 46 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 47 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 48 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 49 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 50 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 51 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 52 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 53 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 54 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 55 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 56 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 57 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 58 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 59 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 60 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 61 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 62 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 63 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 64 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 65 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 66 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 67 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 68 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 69 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 70 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 71 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 72 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 73 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[73] == input_char)
									next[block_mem_state_info_target_state[73]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 75) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 74) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 73) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 72) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 71) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 70) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 69) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 68) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 67) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 66) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 65) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 64) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 63) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 62) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 61) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 60) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 59) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 58) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 57) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 56) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 55) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 54) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 53) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 52) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 51) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 50) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 49) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 48) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 47) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 46) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 45 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 46 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 47 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 48 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 49 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 50 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 51 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 52 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 53 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 54 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 55 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 56 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 57 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 58 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 59 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 60 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 61 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 62 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 63 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 64 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 65 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 66 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 67 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 68 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 69 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 70 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 71 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 72 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 73 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 74 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[74] == input_char)
									next[block_mem_state_info_target_state[74]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 76) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 75) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 74) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 73) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 72) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 71) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 70) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 69) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 68) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 67) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 66) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 65) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 64) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 63) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 62) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 61) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 60) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 59) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 58) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 57) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 56) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 55) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 54) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 53) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 52) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 51) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 49) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 48) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 47) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 46) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 45 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 46 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 47 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 48 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 49 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 50 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 51 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 52 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 53 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 54 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 55 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 56 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 57 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 58 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 59 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 60 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 61 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 62 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 63 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 64 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 65 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 66 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 67 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 68 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 69 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 70 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 71 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 72 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 73 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 74 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 75 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[75] == input_char)
									next[block_mem_state_info_target_state[75]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 77) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 76) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 75) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 74) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 73) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 72) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 71) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 70) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 69) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 68) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 67) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 66) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 65) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 64) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 63) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 62) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 61) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 60) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 59) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 58) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 57) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 56) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 55) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 54) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 53) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 52) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 51) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 50) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 49) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 48) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 47) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 46) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 45 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 46 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 47 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 48 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 49 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 50 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 51 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 52 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 53 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 54 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 55 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 56 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 57 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 58 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 59 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 60 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 61 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 62 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 63 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 64 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 65 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 66 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 67 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 68 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 69 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 70 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 71 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 72 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 73 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 74 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 75 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 76 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[76] == input_char)
									next[block_mem_state_info_target_state[76]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 78) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 77) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 76) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 75) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 74) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 73) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 72) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 71) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 70) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 69) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 68) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 67) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 66) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 65) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 64) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 63) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 62) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 61) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 60) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 59) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 58) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 57) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 56) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 55) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 54) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 53) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 52) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 51) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 50) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 49) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 48) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 47) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 46) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 45 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 46 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 47 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 48 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 49 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 50 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 51 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 52 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 53 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 54 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 55 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 56 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 57 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 58 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 59 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 60 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 61 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 62 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 63 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 64 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 65 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 66 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 67 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 68 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 69 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 70 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 71 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 72 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 73 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 74 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 75 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 76 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 77 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[77] == input_char)
									next[block_mem_state_info_target_state[77]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 79) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 78) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 77) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 76) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 75) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 74) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 73) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 72) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 71) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 70) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 69) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 68) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 67) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 66) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 65) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 64) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 63) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 62) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 61) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 60) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 59) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 58) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 57) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 56) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 55) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 54) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 53) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 52) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 51) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 50) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 49) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 48) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 47) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 46) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 45 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 46 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 47 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 48 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 49 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 50 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 51 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 52 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 53 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 54 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 55 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 56 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 57 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 58 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 59 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 60 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 61 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 62 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 63 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 64 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 65 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 66 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 67 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 68 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 69 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 70 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 71 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 72 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 73 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 74 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 75 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 76 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 77 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 78 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[78] == input_char)
									next[block_mem_state_info_target_state[78]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 80) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 79) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 78) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 77) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 76) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 75) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 74) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 73) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 72) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 71) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 70) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 69) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 68) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 67) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 66) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 65) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 64) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 63) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 62) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 61) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 60) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 59) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 58) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 57) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 56) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 55) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 54) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 53) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 52) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 51) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 50) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 49) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 48) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 47) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 46) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 45 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 46 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 47 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 48 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 49 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 50 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 51 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 52 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 53 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 54 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 55 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 56 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 57 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 58 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 59 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 60 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 61 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 62 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 63 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 64 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 65 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 66 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 67 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 68 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 69 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 70 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 71 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 72 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 73 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 74 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 75 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 76 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 77 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 78 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 79 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[79] == input_char)
									next[block_mem_state_info_target_state[79]] <= 1;
							end
							
							/********* First one till 15*******/
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 81) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 80) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 79) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 78) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 77) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 76) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 75) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 74) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 73) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 72) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 71) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 70) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 69) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 68) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 67) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 66) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 65) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 64) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 63) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 62) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 61) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 60) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 59) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 58) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 57) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 56) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 55) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 54) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 53) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 52) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 51) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 50) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 49) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 48) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 47) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 46) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 45 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 46 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 47 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 48 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 49 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 50 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 51 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 52 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 53 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 54 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 55 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 56 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 57 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 58 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 59 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 60 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 61 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 62 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 63 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 64 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 65 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 66 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 67 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 68 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 69 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 70 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 71 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 72 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 73 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 74 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 75 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 76 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 77 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 78 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 79 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 80 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[80] == input_char)
									next[block_mem_state_info_target_state[80]] <= 1;
							end
						
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 82) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 81) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 80) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 79) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 78) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 77) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 76) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 75) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 74) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 73) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 72) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 71) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 70) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 69) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 68) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 67) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 66) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 65) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 64) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 63) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 62) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 61) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 60) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 59) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 58) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 57) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 56) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 55) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 54) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 53) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 52) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 51) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 50) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 49) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 48) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 47) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 46) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 45 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 46 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 47 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 48 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 49 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 50 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 51 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 52 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 53 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 54 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 55 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 56 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 57 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 58 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 59 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 60 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 61 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 62 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 63 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 64 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 65 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 66 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 67 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 68 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 69 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 70 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 71 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 72 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 73 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 74 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 75 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 76 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 77 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 78 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 79 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 80 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 81 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[81] == input_char)
									next[block_mem_state_info_target_state[81]] <= 1;
							end
							
							if(	(block_offset_flag_0 == 0 && no_cached_blocks_flag_0 >= 83) ||
								(block_offset_flag_0 == 1 && no_cached_blocks_flag_0 >= 82) ||
								(block_offset_flag_0 == 2 && no_cached_blocks_flag_0 >= 81) ||
								(block_offset_flag_0 == 3 && no_cached_blocks_flag_0 >= 80) ||
								(block_offset_flag_0 == 4 && no_cached_blocks_flag_0 >= 79) ||
								(block_offset_flag_0 == 5 && no_cached_blocks_flag_0 >= 78) ||
								(block_offset_flag_0 == 6 && no_cached_blocks_flag_0 >= 77) ||
								(block_offset_flag_0 == 7 && no_cached_blocks_flag_0 >= 76) ||
								(block_offset_flag_0 == 8 && no_cached_blocks_flag_0 >= 75) ||
								(block_offset_flag_0 == 9 && no_cached_blocks_flag_0 >= 74) ||
								(block_offset_flag_0 == 10 && no_cached_blocks_flag_0 >= 73) ||
								(block_offset_flag_0 == 11 && no_cached_blocks_flag_0 >= 72) ||
								(block_offset_flag_0 == 12 && no_cached_blocks_flag_0 >= 71) ||
								(block_offset_flag_0 == 13 && no_cached_blocks_flag_0 >= 70) ||
								(block_offset_flag_0 == 14 && no_cached_blocks_flag_0 >= 69) ||
								(block_offset_flag_0 == 15 && no_cached_blocks_flag_0 >= 68) ||
								(block_offset_flag_0 == 16 && no_cached_blocks_flag_0 >= 67) ||
								(block_offset_flag_0 == 17 && no_cached_blocks_flag_0 >= 66) ||
								(block_offset_flag_0 == 18 && no_cached_blocks_flag_0 >= 65) ||
								(block_offset_flag_0 == 19 && no_cached_blocks_flag_0 >= 64) ||
								(block_offset_flag_0 == 20 && no_cached_blocks_flag_0 >= 63) ||
								(block_offset_flag_0 == 21 && no_cached_blocks_flag_0 >= 62) ||
								(block_offset_flag_0 == 22 && no_cached_blocks_flag_0 >= 61) ||
								(block_offset_flag_0 == 23 && no_cached_blocks_flag_0 >= 60) ||
								(block_offset_flag_0 == 24 && no_cached_blocks_flag_0 >= 59) ||
								(block_offset_flag_0 == 25 && no_cached_blocks_flag_0 >= 58) ||
								(block_offset_flag_0 == 26 && no_cached_blocks_flag_0 >= 57) ||
								(block_offset_flag_0 == 27 && no_cached_blocks_flag_0 >= 56) ||
								(block_offset_flag_0 == 28 && no_cached_blocks_flag_0 >= 55) ||
								(block_offset_flag_0 == 29 && no_cached_blocks_flag_0 >= 54) ||
								(block_offset_flag_0 == 30 && no_cached_blocks_flag_0 >= 53) ||
								(block_offset_flag_0 == 31 && no_cached_blocks_flag_0 >= 52) ||
								(block_offset_flag_0 == 32 && no_cached_blocks_flag_0 >= 51) ||
								(block_offset_flag_0 == 33 && no_cached_blocks_flag_0 >= 50) ||
								(block_offset_flag_0 == 34 && no_cached_blocks_flag_0 >= 49) ||
								(block_offset_flag_0 == 35 && no_cached_blocks_flag_0 >= 48) ||
								(block_offset_flag_0 == 36 && no_cached_blocks_flag_0 >= 47) ||
								(block_offset_flag_0 == 37 && no_cached_blocks_flag_0 >= 46) ||
								(block_offset_flag_0 == 38 && no_cached_blocks_flag_0 >= 45) ||
								(block_offset_flag_0 == 39 && no_cached_blocks_flag_0 >= 44) ||
								(block_offset_flag_0 == 40 && no_cached_blocks_flag_0 >= 43) ||
								(block_offset_flag_0 == 41 && no_cached_blocks_flag_0 >= 42) ||
								(block_offset_flag_0 == 42 && no_cached_blocks_flag_0 >= 41) ||
								(block_offset_flag_0 == 43 && no_cached_blocks_flag_0 >= 40) ||
								(block_offset_flag_0 == 44 && no_cached_blocks_flag_0 >= 39) ||
								(block_offset_flag_0 == 45 && no_cached_blocks_flag_0 >= 38) ||
								(block_offset_flag_0 == 46 && no_cached_blocks_flag_0 >= 37) ||
								(block_offset_flag_0 == 47 && no_cached_blocks_flag_0 >= 36) ||
								(block_offset_flag_0 == 48 && no_cached_blocks_flag_0 >= 35) ||
								(block_offset_flag_0 == 49 && no_cached_blocks_flag_0 >= 34) ||
								(block_offset_flag_0 == 50 && no_cached_blocks_flag_0 >= 33) ||
								(block_offset_flag_0 == 51 && no_cached_blocks_flag_0 >= 32) ||
								(block_offset_flag_0 == 52 && no_cached_blocks_flag_0 >= 31) ||
								(block_offset_flag_0 == 53 && no_cached_blocks_flag_0 >= 30) ||
								(block_offset_flag_0 == 54 && no_cached_blocks_flag_0 >= 29) ||
								(block_offset_flag_0 == 55 && no_cached_blocks_flag_0 >= 28) ||
								(block_offset_flag_0 == 56 && no_cached_blocks_flag_0 >= 27) ||
								(block_offset_flag_0 == 57 && no_cached_blocks_flag_0 >= 26) ||
								(block_offset_flag_0 == 58 && no_cached_blocks_flag_0 >= 25) ||
								(block_offset_flag_0 == 59 && no_cached_blocks_flag_0 >= 24) ||
								(block_offset_flag_0 == 60 && no_cached_blocks_flag_0 >= 23) ||
								(block_offset_flag_0 == 61 && no_cached_blocks_flag_0 >= 22) ||
								(block_offset_flag_0 == 62 && no_cached_blocks_flag_0 >= 21) ||
								(block_offset_flag_0 == 63 && no_cached_blocks_flag_0 >= 20) ||
								(block_offset_flag_0 == 64 && no_cached_blocks_flag_0 >= 19) ||
								(block_offset_flag_0 == 65 && no_cached_blocks_flag_0 >= 18) ||
								(block_offset_flag_0 == 66 && no_cached_blocks_flag_0 >= 17) ||
								(block_offset_flag_0 == 67 && no_cached_blocks_flag_0 >= 16) ||
								(block_offset_flag_0 == 68 && no_cached_blocks_flag_0 >= 15) ||
								(block_offset_flag_0 == 69 && no_cached_blocks_flag_0 >= 14) ||
								(block_offset_flag_0 == 70 && no_cached_blocks_flag_0 >= 13) ||
								(block_offset_flag_0 == 71 && no_cached_blocks_flag_0 >= 12) ||
								(block_offset_flag_0 == 72 && no_cached_blocks_flag_0 >= 11) ||
								(block_offset_flag_0 == 73 && no_cached_blocks_flag_0 >= 10) ||
								(block_offset_flag_0 == 74 && no_cached_blocks_flag_0 >= 9) ||
								(block_offset_flag_0 == 75 && no_cached_blocks_flag_0 >= 8) ||
								(block_offset_flag_0 == 76 && no_cached_blocks_flag_0 >= 7) ||
								(block_offset_flag_0 == 77 && no_cached_blocks_flag_0 >= 6) ||
								(block_offset_flag_0 == 78 && no_cached_blocks_flag_0 >= 5) ||
								(block_offset_flag_0 == 79 && no_cached_blocks_flag_0 >= 4) ||
								(block_offset_flag_0 == 80 && no_cached_blocks_flag_0 >= 3) ||
								(block_offset_flag_0 == 81 && no_cached_blocks_flag_0 >= 2) ||
								(block_offset_flag_0 == 82 && no_cached_blocks_flag_0 >= 1)
							)
							begin
								if(block_mem_state_info_transition[82] == input_char)
									next[block_mem_state_info_target_state[82]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 84 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[83] == input_char)
									next[block_mem_state_info_target_state[83]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 85 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[84] == input_char)
									next[block_mem_state_info_target_state[84]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 86 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[85] == input_char)
									next[block_mem_state_info_target_state[85]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 87 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[86] == input_char)
									next[block_mem_state_info_target_state[86]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 88 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[87] == input_char)
									next[block_mem_state_info_target_state[87]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 89 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[88] == input_char)
									next[block_mem_state_info_target_state[88]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 90 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[89] == input_char)
									next[block_mem_state_info_target_state[89]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 91 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[90] == input_char)
									next[block_mem_state_info_target_state[90]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 92 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[91] == input_char)
									next[block_mem_state_info_target_state[91]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 93 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[92] == input_char)
									next[block_mem_state_info_target_state[92]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 94 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[93] == input_char)
									next[block_mem_state_info_target_state[93]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 95 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[94] == input_char)
									next[block_mem_state_info_target_state[94]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 96 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[95] == input_char)
									next[block_mem_state_info_target_state[95]] <= 1;
							end
							
							/********* second one till 31*******/
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 97 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[96] == input_char)
									next[block_mem_state_info_target_state[96]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 98 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[97] == input_char)
									next[block_mem_state_info_target_state[97]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 99 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[98] == input_char)
									next[block_mem_state_info_target_state[98]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 100 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[99] == input_char)
									next[block_mem_state_info_target_state[99]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 101 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[100] == input_char)
									next[block_mem_state_info_target_state[100]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 102 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[101] == input_char)
									next[block_mem_state_info_target_state[101]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 103 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[102] == input_char)
									next[block_mem_state_info_target_state[102]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 104 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[103] == input_char)
									next[block_mem_state_info_target_state[103]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 105 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[104] == input_char)
									next[block_mem_state_info_target_state[104]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 106 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[105] == input_char)
									next[block_mem_state_info_target_state[105]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 107 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[106] == input_char)
									next[block_mem_state_info_target_state[106]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 108 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[107] == input_char)
									next[block_mem_state_info_target_state[107]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 109 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[108] == input_char)
									next[block_mem_state_info_target_state[108]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 110 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[109] == input_char)
									next[block_mem_state_info_target_state[109]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 111 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[110] == input_char)
									next[block_mem_state_info_target_state[110]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 112 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[111] == input_char)
									next[block_mem_state_info_target_state[111]] <= 1;
							end
							
							/********* third one till 47*******/
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 113 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[112] == input_char)
									next[block_mem_state_info_target_state[112]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 114 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[113] == input_char)
									next[block_mem_state_info_target_state[113]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 115 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[114] == input_char)
									next[block_mem_state_info_target_state[114]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 116 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[115] == input_char)
									next[block_mem_state_info_target_state[115]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 117 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[116] == input_char)
									next[block_mem_state_info_target_state[116]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 118 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[117] == input_char)
									next[block_mem_state_info_target_state[117]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 119 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[118] == input_char)
									next[block_mem_state_info_target_state[118]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 120 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[119] == input_char)
									next[block_mem_state_info_target_state[119]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 121 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[120] == input_char)
									next[block_mem_state_info_target_state[120]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 122 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[121] == input_char)
									next[block_mem_state_info_target_state[121]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 123 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[122] == input_char)
									next[block_mem_state_info_target_state[122]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 124 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[123] == input_char)
									next[block_mem_state_info_target_state[123]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 125 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[124] == input_char)
									next[block_mem_state_info_target_state[124]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 126 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[125] == input_char)
									next[block_mem_state_info_target_state[125]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 127 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[126] == input_char)
									next[block_mem_state_info_target_state[126]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 128 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[127] == input_char)
									next[block_mem_state_info_target_state[127]] <= 1;
							end
							
							flag_2 <= 1;
						end
						else if(flag_2 <= 1)
						begin
							
							if(no_cached_blocks_flag_1 > 0)
							begin
								if(block_mem_state_info_transition[0] == input_char)
									next[block_mem_state_info_target_state[0]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 1)
							begin
								if(block_mem_state_info_transition[1] == input_char)
									next[block_mem_state_info_target_state[1]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 2)
							begin
								if(block_mem_state_info_transition[2] == input_char)
									next[block_mem_state_info_target_state[2]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 3)
							begin
								if(block_mem_state_info_transition[3] == input_char)
									next[block_mem_state_info_target_state[3]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 4)
							begin
								if(block_mem_state_info_transition[4] == input_char)
									next[block_mem_state_info_target_state[4]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 5)
							begin
								if(block_mem_state_info_transition[5] == input_char)
									next[block_mem_state_info_target_state[5]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 6)
							begin
								if(block_mem_state_info_transition[6] == input_char)
									next[block_mem_state_info_target_state[6]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 7)
							begin
								if(block_mem_state_info_transition[7] == input_char)
									next[block_mem_state_info_target_state[7]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 8)
							begin
								if(block_mem_state_info_transition[8] == input_char)
									next[block_mem_state_info_target_state[8]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 9)
							begin
								if(block_mem_state_info_transition[9] == input_char)
									next[block_mem_state_info_target_state[9]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 10)
							begin
								if(block_mem_state_info_transition[10] == input_char)
									next[block_mem_state_info_target_state[10]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 11)
							begin
								if(block_mem_state_info_transition[11] == input_char)
									next[block_mem_state_info_target_state[11]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 12)
							begin
								if(block_mem_state_info_transition[12] == input_char)
									next[block_mem_state_info_target_state[12]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 13)
							begin
								if(block_mem_state_info_transition[13] == input_char)
									next[block_mem_state_info_target_state[13]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 14)
							begin
								if(block_mem_state_info_transition[14] == input_char)
									next[block_mem_state_info_target_state[14]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 15)
							begin
								if(block_mem_state_info_transition[15] == input_char)
									next[block_mem_state_info_target_state[15]] <= 1;
							end
							
							/********* First one till 15*******/
							
							if(no_cached_blocks_flag_1 > 16)
							begin
								if(block_mem_state_info_transition[16] == input_char)
									next[block_mem_state_info_target_state[16]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 17)
							begin
								if(block_mem_state_info_transition[17] == input_char)
									next[block_mem_state_info_target_state[17]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 18)
							begin
								if(block_mem_state_info_transition[18] == input_char)
									next[block_mem_state_info_target_state[18]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 19)
							begin
								if(block_mem_state_info_transition[19] == input_char)
									next[block_mem_state_info_target_state[19]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 20)
							begin
								if(block_mem_state_info_transition[20] == input_char)
									next[block_mem_state_info_target_state[20]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 21)
							begin
								if(block_mem_state_info_transition[21] == input_char)
									next[block_mem_state_info_target_state[21]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 22)
							begin
								if(block_mem_state_info_transition[22] == input_char)
									next[block_mem_state_info_target_state[22]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 23)
							begin
								if(block_mem_state_info_transition[23] == input_char)
									next[block_mem_state_info_target_state[23]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 24)
							begin
								if(block_mem_state_info_transition[24] == input_char)
									next[block_mem_state_info_target_state[24]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 25)
							begin
								if(block_mem_state_info_transition[25] == input_char)
									next[block_mem_state_info_target_state[25]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 26)
							begin
								if(block_mem_state_info_transition[26] == input_char)
									next[block_mem_state_info_target_state[26]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 27)
							begin
								if(block_mem_state_info_transition[27] == input_char)
									next[block_mem_state_info_target_state[27]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 28)
							begin
								if(block_mem_state_info_transition[28] == input_char)
									next[block_mem_state_info_target_state[28]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 29)
							begin
								if(block_mem_state_info_transition[29] == input_char)
									next[block_mem_state_info_target_state[29]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 30)
							begin
								if(block_mem_state_info_transition[30] == input_char)
									next[block_mem_state_info_target_state[30]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 31)
							begin
								if(block_mem_state_info_transition[31] == input_char)
									next[block_mem_state_info_target_state[31]] <= 1;
							end
							
							/********* second one till 31*******/
							
							if(no_cached_blocks_flag_1 > 32)
							begin
								if(block_mem_state_info_transition[32] == input_char)
									next[block_mem_state_info_target_state[32]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 33)
							begin
								if(block_mem_state_info_transition[33] == input_char)
									next[block_mem_state_info_target_state[33]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 34)
							begin
								if(block_mem_state_info_transition[34] == input_char)
									next[block_mem_state_info_target_state[34]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 35)
							begin
								if(block_mem_state_info_transition[35] == input_char)
									next[block_mem_state_info_target_state[35]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 36)
							begin
								if(block_mem_state_info_transition[36] == input_char)
									next[block_mem_state_info_target_state[36]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 37)
							begin
								if(block_mem_state_info_transition[37] == input_char)
									next[block_mem_state_info_target_state[37]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 38)
							begin
								if(block_mem_state_info_transition[38] == input_char)
									next[block_mem_state_info_target_state[38]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 39)
							begin
								if(block_mem_state_info_transition[39] == input_char)
									next[block_mem_state_info_target_state[39]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 40)
							begin
								if(block_mem_state_info_transition[40] == input_char)
									next[block_mem_state_info_target_state[40]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 41)
							begin
								if(block_mem_state_info_transition[41] == input_char)
									next[block_mem_state_info_target_state[41]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 42)
							begin
								if(block_mem_state_info_transition[42] == input_char)
									next[block_mem_state_info_target_state[42]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 43)
							begin
								if(block_mem_state_info_transition[43] == input_char)
									next[block_mem_state_info_target_state[43]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 44)
							begin
								if(block_mem_state_info_transition[44] == input_char)
									next[block_mem_state_info_target_state[44]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 45)
							begin
								if(block_mem_state_info_transition[45] == input_char)
									next[block_mem_state_info_target_state[45]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 46)
							begin
								if(block_mem_state_info_transition[46] == input_char)
									next[block_mem_state_info_target_state[46]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 47)
							begin
								if(block_mem_state_info_transition[47] == input_char)
									next[block_mem_state_info_target_state[47]] <= 1;
							end
							
							/********* third one till 47*******/
							
							if(no_cached_blocks_flag_1 > 48)
							begin
								if(block_mem_state_info_transition[48] == input_char)
									next[block_mem_state_info_target_state[48]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 49)
							begin
								if(block_mem_state_info_transition[49] == input_char)
									next[block_mem_state_info_target_state[49]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 50)
							begin
								if(block_mem_state_info_transition[50] == input_char)
									next[block_mem_state_info_target_state[50]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 51)
							begin
								if(block_mem_state_info_transition[51] == input_char)
									next[block_mem_state_info_target_state[51]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 52)
							begin
								if(block_mem_state_info_transition[52] == input_char)
									next[block_mem_state_info_target_state[52]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 53)
							begin
								if(block_mem_state_info_transition[53] == input_char)
									next[block_mem_state_info_target_state[53]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 54)
							begin
								if(block_mem_state_info_transition[54] == input_char)
									next[block_mem_state_info_target_state[54]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 55)
							begin
								if(block_mem_state_info_transition[55] == input_char)
									next[block_mem_state_info_target_state[55]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 56)
							begin
								if(block_mem_state_info_transition[56] == input_char)
									next[block_mem_state_info_target_state[56]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 57)
							begin
								if(block_mem_state_info_transition[57] == input_char)
									next[block_mem_state_info_target_state[57]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 58)
							begin
								if(block_mem_state_info_transition[58] == input_char)
									next[block_mem_state_info_target_state[58]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 59)
							begin
								if(block_mem_state_info_transition[59] == input_char)
									next[block_mem_state_info_target_state[59]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 60)
							begin
								if(block_mem_state_info_transition[60] == input_char)
									next[block_mem_state_info_target_state[60]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 61)
							begin
								if(block_mem_state_info_transition[61] == input_char)
									next[block_mem_state_info_target_state[61]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 62)
							begin
								if(block_mem_state_info_transition[62] == input_char)
									next[block_mem_state_info_target_state[62]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 63)
							begin
								if(block_mem_state_info_transition[63] == input_char)
									next[block_mem_state_info_target_state[63]] <= 1;
							end
							
							/**----------------------------**/
							if(no_cached_blocks_flag_1 > 64)
							begin
								if(block_mem_state_info_transition[64] == input_char)
									next[block_mem_state_info_target_state[64]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 65)
							begin
								if(block_mem_state_info_transition[65] == input_char)
									next[block_mem_state_info_target_state[65]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 66)
							begin
								if(block_mem_state_info_transition[66] == input_char)
									next[block_mem_state_info_target_state[66]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 67)
							begin
								if(block_mem_state_info_transition[67] == input_char)
									next[block_mem_state_info_target_state[67]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 68)
							begin
								if(block_mem_state_info_transition[68] == input_char)
									next[block_mem_state_info_target_state[68]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 69)
							begin
								if(block_mem_state_info_transition[69] == input_char)
									next[block_mem_state_info_target_state[69]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 70)
							begin
								if(block_mem_state_info_transition[70] == input_char)
									next[block_mem_state_info_target_state[70]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 71)
							begin
								if(block_mem_state_info_transition[71] == input_char)
									next[block_mem_state_info_target_state[71]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 72)
							begin
								if(block_mem_state_info_transition[72] == input_char)
									next[block_mem_state_info_target_state[72]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 73)
							begin
								if(block_mem_state_info_transition[73] == input_char)
									next[block_mem_state_info_target_state[73]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 74)
							begin
								if(block_mem_state_info_transition[74] == input_char)
									next[block_mem_state_info_target_state[74]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 75)
							begin
								if(block_mem_state_info_transition[75] == input_char)
									next[block_mem_state_info_target_state[75]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 76)
							begin
								if(block_mem_state_info_transition[76] == input_char)
									next[block_mem_state_info_target_state[76]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 77)
							begin
								if(block_mem_state_info_transition[77] == input_char)
									next[block_mem_state_info_target_state[77]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 78)
							begin
								if(block_mem_state_info_transition[78] == input_char)
									next[block_mem_state_info_target_state[78]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 79)
							begin
								if(block_mem_state_info_transition[79] == input_char)
									next[block_mem_state_info_target_state[79]] <= 1;
							end
							
							/********* First one till 15*******/
							
							if(no_cached_blocks_flag_1 > 80)
							begin
								if(block_mem_state_info_transition[80] == input_char)
									next[block_mem_state_info_target_state[80]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 81)
							begin
								if(block_mem_state_info_transition[81] == input_char)
									next[block_mem_state_info_target_state[81]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 82)
							begin
								if(block_mem_state_info_transition[82] == input_char)
									next[block_mem_state_info_target_state[82]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 83)
							begin
								if(block_mem_state_info_transition[83] == input_char)
									next[block_mem_state_info_target_state[83]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 84)
							begin
								if(block_mem_state_info_transition[84] == input_char)
									next[block_mem_state_info_target_state[84]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 85)
							begin
								if(block_mem_state_info_transition[85] == input_char)
									next[block_mem_state_info_target_state[85]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 86)
							begin
								if(block_mem_state_info_transition[86] == input_char)
									next[block_mem_state_info_target_state[86]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 87)
							begin
								if(block_mem_state_info_transition[87] == input_char)
									next[block_mem_state_info_target_state[87]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 88)
							begin
								if(block_mem_state_info_transition[88] == input_char)
									next[block_mem_state_info_target_state[88]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 89)
							begin
								if(block_mem_state_info_transition[89] == input_char)
									next[block_mem_state_info_target_state[89]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 90)
							begin
								if(block_mem_state_info_transition[90] == input_char)
									next[block_mem_state_info_target_state[90]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 91)
							begin
								if(block_mem_state_info_transition[91] == input_char)
									next[block_mem_state_info_target_state[91]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 92)
							begin
								if(block_mem_state_info_transition[92] == input_char)
									next[block_mem_state_info_target_state[92]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 93)
							begin
								if(block_mem_state_info_transition[93] == input_char)
									next[block_mem_state_info_target_state[93]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 94)
							begin
								if(block_mem_state_info_transition[94] == input_char)
									next[block_mem_state_info_target_state[94]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 95)
							begin
								if(block_mem_state_info_transition[95] == input_char)
									next[block_mem_state_info_target_state[95]] <= 1;
							end
							
							/********* second one till 31*******/
							
							if(no_cached_blocks_flag_1 > 96)
							begin
								if(block_mem_state_info_transition[96] == input_char)
									next[block_mem_state_info_target_state[96]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 97)
							begin
								if(block_mem_state_info_transition[97] == input_char)
									next[block_mem_state_info_target_state[97]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 98)
							begin
								if(block_mem_state_info_transition[98] == input_char)
									next[block_mem_state_info_target_state[98]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 99)
							begin
								if(block_mem_state_info_transition[99] == input_char)
									next[block_mem_state_info_target_state[99]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 100)
							begin
								if(block_mem_state_info_transition[100] == input_char)
									next[block_mem_state_info_target_state[100]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 101)
							begin
								if(block_mem_state_info_transition[101] == input_char)
									next[block_mem_state_info_target_state[101]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 102)
							begin
								if(block_mem_state_info_transition[102] == input_char)
									next[block_mem_state_info_target_state[102]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 103)
							begin
								if(block_mem_state_info_transition[103] == input_char)
									next[block_mem_state_info_target_state[103]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 104)
							begin
								if(block_mem_state_info_transition[104] == input_char)
									next[block_mem_state_info_target_state[104]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 105)
							begin
								if(block_mem_state_info_transition[105] == input_char)
									next[block_mem_state_info_target_state[105]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 106)
							begin
								if(block_mem_state_info_transition[106] == input_char)
									next[block_mem_state_info_target_state[106]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 107)
							begin
								if(block_mem_state_info_transition[107] == input_char)
									next[block_mem_state_info_target_state[107]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 108)
							begin
								if(block_mem_state_info_transition[108] == input_char)
									next[block_mem_state_info_target_state[108]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 109)
							begin
								if(block_mem_state_info_transition[109] == input_char)
									next[block_mem_state_info_target_state[109]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 110)
							begin
								if(block_mem_state_info_transition[110] == input_char)
									next[block_mem_state_info_target_state[110]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 111)
							begin
								if(block_mem_state_info_transition[111] == input_char)
									next[block_mem_state_info_target_state[111]] <= 1;
							end
							
							/********* third one till 47*******/
							
							if(no_cached_blocks_flag_1 > 112)
							begin
								if(block_mem_state_info_transition[112] == input_char)
									next[block_mem_state_info_target_state[112]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 113)
							begin
								if(block_mem_state_info_transition[113] == input_char)
									next[block_mem_state_info_target_state[113]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 114)
							begin
								if(block_mem_state_info_transition[114] == input_char)
									next[block_mem_state_info_target_state[114]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 115)
							begin
								if(block_mem_state_info_transition[115] == input_char)
									next[block_mem_state_info_target_state[115]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 116)
							begin
								if(block_mem_state_info_transition[116] == input_char)
									next[block_mem_state_info_target_state[116]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 117)
							begin
								if(block_mem_state_info_transition[117] == input_char)
									next[block_mem_state_info_target_state[117]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 118)
							begin
								if(block_mem_state_info_transition[118] == input_char)
									next[block_mem_state_info_target_state[118]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 119)
							begin
								if(block_mem_state_info_transition[119] == input_char)
									next[block_mem_state_info_target_state[119]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 120)
							begin
								if(block_mem_state_info_transition[120] == input_char)
									next[block_mem_state_info_target_state[120]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 121)
							begin
								if(block_mem_state_info_transition[121] == input_char)
									next[block_mem_state_info_target_state[121]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 122)
							begin
								if(block_mem_state_info_transition[122] == input_char)
									next[block_mem_state_info_target_state[122]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 123)
							begin
								if(block_mem_state_info_transition[123] == input_char)
									next[block_mem_state_info_target_state[123]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 124)
							begin
								if(block_mem_state_info_transition[124] == input_char)
									next[block_mem_state_info_target_state[124]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 125)
							begin
								if(block_mem_state_info_transition[125] == input_char)
									next[block_mem_state_info_target_state[125]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 126)
							begin
								if(block_mem_state_info_transition[126] == input_char)
									next[block_mem_state_info_target_state[126]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 127)
							begin
								if(block_mem_state_info_transition[127] == input_char)
									next[block_mem_state_info_target_state[127]] <= 1;
							end
							
							flag_2 <= 2;
						end
						else if(flag_2 <= 2)
						begin
							if(no_cached_blocks_flag_2 > 0)
							begin
								if(block_mem_state_info_transition[0] == input_char)
									next[block_mem_state_info_target_state[0]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 1)
							begin
								if(block_mem_state_info_transition[1] == input_char)
									next[block_mem_state_info_target_state[1]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 2)
							begin
								if(block_mem_state_info_transition[2] == input_char)
									next[block_mem_state_info_target_state[2]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 3)
							begin
								if(block_mem_state_info_transition[3] == input_char)
									next[block_mem_state_info_target_state[3]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 4)
							begin
								if(block_mem_state_info_transition[4] == input_char)
									next[block_mem_state_info_target_state[4]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 5)
							begin
								if(block_mem_state_info_transition[5] == input_char)
									next[block_mem_state_info_target_state[5]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 6)
							begin
								if(block_mem_state_info_transition[6] == input_char)
									next[block_mem_state_info_target_state[6]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 7)
							begin
								if(block_mem_state_info_transition[7] == input_char)
									next[block_mem_state_info_target_state[7]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 8)
							begin
								if(block_mem_state_info_transition[8] == input_char)
									next[block_mem_state_info_target_state[8]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 9)
							begin
								if(block_mem_state_info_transition[9] == input_char)
									next[block_mem_state_info_target_state[9]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 10)
							begin
								if(block_mem_state_info_transition[10] == input_char)
									next[block_mem_state_info_target_state[10]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 11)
							begin
								if(block_mem_state_info_transition[11] == input_char)
									next[block_mem_state_info_target_state[11]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 12)
							begin
								if(block_mem_state_info_transition[12] == input_char)
									next[block_mem_state_info_target_state[12]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 13)
							begin
								if(block_mem_state_info_transition[13] == input_char)
									next[block_mem_state_info_target_state[13]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 14)
							begin
								if(block_mem_state_info_transition[14] == input_char)
									next[block_mem_state_info_target_state[14]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 15)
							begin
								if(block_mem_state_info_transition[15] == input_char)
									next[block_mem_state_info_target_state[15]] <= 1;
							end
							
							/********* First one till 15*******/
							
							if(no_cached_blocks_flag_2 > 16)
							begin
								if(block_mem_state_info_transition[16] == input_char)
									next[block_mem_state_info_target_state[16]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 17)
							begin
								if(block_mem_state_info_transition[17] == input_char)
									next[block_mem_state_info_target_state[17]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 18)
							begin
								if(block_mem_state_info_transition[18] == input_char)
									next[block_mem_state_info_target_state[18]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 19)
							begin
								if(block_mem_state_info_transition[19] == input_char)
									next[block_mem_state_info_target_state[19]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 20)
							begin
								if(block_mem_state_info_transition[20] == input_char)
									next[block_mem_state_info_target_state[20]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 21)
							begin
								if(block_mem_state_info_transition[21] == input_char)
									next[block_mem_state_info_target_state[21]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 22)
							begin
								if(block_mem_state_info_transition[22] == input_char)
									next[block_mem_state_info_target_state[22]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 23)
							begin
								if(block_mem_state_info_transition[23] == input_char)
									next[block_mem_state_info_target_state[23]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 24)
							begin
								if(block_mem_state_info_transition[24] == input_char)
									next[block_mem_state_info_target_state[24]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 25)
							begin
								if(block_mem_state_info_transition[25] == input_char)
									next[block_mem_state_info_target_state[25]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 26)
							begin
								if(block_mem_state_info_transition[26] == input_char)
									next[block_mem_state_info_target_state[26]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 27)
							begin
								if(block_mem_state_info_transition[27] == input_char)
									next[block_mem_state_info_target_state[27]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 28)
							begin
								if(block_mem_state_info_transition[28] == input_char)
									next[block_mem_state_info_target_state[28]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 29)
							begin
								if(block_mem_state_info_transition[29] == input_char)
									next[block_mem_state_info_target_state[29]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 30)
							begin
								if(block_mem_state_info_transition[30] == input_char)
									next[block_mem_state_info_target_state[30]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 31)
							begin
								if(block_mem_state_info_transition[31] == input_char)
									next[block_mem_state_info_target_state[31]] <= 1;
							end
							
							/********* second one till 31*******/
							
							if(no_cached_blocks_flag_2 > 32)
							begin
								if(block_mem_state_info_transition[32] == input_char)
									next[block_mem_state_info_target_state[32]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 33)
							begin
								if(block_mem_state_info_transition[33] == input_char)
									next[block_mem_state_info_target_state[33]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 34)
							begin
								if(block_mem_state_info_transition[34] == input_char)
									next[block_mem_state_info_target_state[34]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 35)
							begin
								if(block_mem_state_info_transition[35] == input_char)
									next[block_mem_state_info_target_state[35]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 36)
							begin
								if(block_mem_state_info_transition[36] == input_char)
									next[block_mem_state_info_target_state[36]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 37)
							begin
								if(block_mem_state_info_transition[37] == input_char)
									next[block_mem_state_info_target_state[37]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 38)
							begin
								if(block_mem_state_info_transition[38] == input_char)
									next[block_mem_state_info_target_state[38]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 39)
							begin
								if(block_mem_state_info_transition[39] == input_char)
									next[block_mem_state_info_target_state[39]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 40)
							begin
								if(block_mem_state_info_transition[40] == input_char)
									next[block_mem_state_info_target_state[40]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 41)
							begin
								if(block_mem_state_info_transition[41] == input_char)
									next[block_mem_state_info_target_state[41]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 42)
							begin
								if(block_mem_state_info_transition[42] == input_char)
									next[block_mem_state_info_target_state[42]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 43)
							begin
								if(block_mem_state_info_transition[43] == input_char)
									next[block_mem_state_info_target_state[43]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 44)
							begin
								if(block_mem_state_info_transition[44] == input_char)
									next[block_mem_state_info_target_state[44]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 45)
							begin
								if(block_mem_state_info_transition[45] == input_char)
									next[block_mem_state_info_target_state[45]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 46)
							begin
								if(block_mem_state_info_transition[46] == input_char)
									next[block_mem_state_info_target_state[46]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 47)
							begin
								if(block_mem_state_info_transition[47] == input_char)
									next[block_mem_state_info_target_state[47]] <= 1;
							end
							
							/********* third one till 47*******/
							
							if(no_cached_blocks_flag_2 > 48)
							begin
								if(block_mem_state_info_transition[48] == input_char)
									next[block_mem_state_info_target_state[48]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 49)
							begin
								if(block_mem_state_info_transition[49] == input_char)
									next[block_mem_state_info_target_state[49]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 50)
							begin
								if(block_mem_state_info_transition[50] == input_char)
									next[block_mem_state_info_target_state[50]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 51)
							begin
								if(block_mem_state_info_transition[51] == input_char)
									next[block_mem_state_info_target_state[51]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 52)
							begin
								if(block_mem_state_info_transition[52] == input_char)
									next[block_mem_state_info_target_state[52]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 53)
							begin
								if(block_mem_state_info_transition[53] == input_char)
									next[block_mem_state_info_target_state[53]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 54)
							begin
								if(block_mem_state_info_transition[54] == input_char)
									next[block_mem_state_info_target_state[54]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 55)
							begin
								if(block_mem_state_info_transition[55] == input_char)
									next[block_mem_state_info_target_state[55]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 56)
							begin
								if(block_mem_state_info_transition[56] == input_char)
									next[block_mem_state_info_target_state[56]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 57)
							begin
								if(block_mem_state_info_transition[57] == input_char)
									next[block_mem_state_info_target_state[57]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 58)
							begin
								if(block_mem_state_info_transition[58] == input_char)
									next[block_mem_state_info_target_state[58]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 59)
							begin
								if(block_mem_state_info_transition[59] == input_char)
									next[block_mem_state_info_target_state[59]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 60)
							begin
								if(block_mem_state_info_transition[60] == input_char)
									next[block_mem_state_info_target_state[60]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 61)
							begin
								if(block_mem_state_info_transition[61] == input_char)
									next[block_mem_state_info_target_state[61]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 62)
							begin
								if(block_mem_state_info_transition[62] == input_char)
									next[block_mem_state_info_target_state[62]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 63)
							begin
								if(block_mem_state_info_transition[63] == input_char)
									next[block_mem_state_info_target_state[63]] <= 1;
							end
							
							/**----------------------------**/
							if(no_cached_blocks_flag_2 > 64)
							begin
								if(block_mem_state_info_transition[64] == input_char)
									next[block_mem_state_info_target_state[64]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 65)
							begin
								if(block_mem_state_info_transition[65] == input_char)
									next[block_mem_state_info_target_state[65]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 66)
							begin
								if(block_mem_state_info_transition[66] == input_char)
									next[block_mem_state_info_target_state[66]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 67)
							begin
								if(block_mem_state_info_transition[67] == input_char)
									next[block_mem_state_info_target_state[67]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 68)
							begin
								if(block_mem_state_info_transition[68] == input_char)
									next[block_mem_state_info_target_state[68]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 69)
							begin
								if(block_mem_state_info_transition[69] == input_char)
									next[block_mem_state_info_target_state[69]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 70)
							begin
								if(block_mem_state_info_transition[70] == input_char)
									next[block_mem_state_info_target_state[70]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 71)
							begin
								if(block_mem_state_info_transition[71] == input_char)
									next[block_mem_state_info_target_state[71]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 72)
							begin
								if(block_mem_state_info_transition[72] == input_char)
									next[block_mem_state_info_target_state[72]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 73)
							begin
								if(block_mem_state_info_transition[73] == input_char)
									next[block_mem_state_info_target_state[73]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 74)
							begin
								if(block_mem_state_info_transition[74] == input_char)
									next[block_mem_state_info_target_state[74]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 75)
							begin
								if(block_mem_state_info_transition[75] == input_char)
									next[block_mem_state_info_target_state[75]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 76)
							begin
								if(block_mem_state_info_transition[76] == input_char)
									next[block_mem_state_info_target_state[76]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 77)
							begin
								if(block_mem_state_info_transition[77] == input_char)
									next[block_mem_state_info_target_state[77]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 78)
							begin
								if(block_mem_state_info_transition[78] == input_char)
									next[block_mem_state_info_target_state[78]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 79)
							begin
								if(block_mem_state_info_transition[79] == input_char)
									next[block_mem_state_info_target_state[79]] <= 1;
							end
							
							/********* First one till 15*******/
							
							if(no_cached_blocks_flag_2 > 80)
							begin
								if(block_mem_state_info_transition[80] == input_char)
									next[block_mem_state_info_target_state[80]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 81)
							begin
								if(block_mem_state_info_transition[81] == input_char)
									next[block_mem_state_info_target_state[81]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 82)
							begin
								if(block_mem_state_info_transition[82] == input_char)
									next[block_mem_state_info_target_state[82]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 83)
							begin
								if(block_mem_state_info_transition[83] == input_char)
									next[block_mem_state_info_target_state[83]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 84)
							begin
								if(block_mem_state_info_transition[84] == input_char)
									next[block_mem_state_info_target_state[84]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 85)
							begin
								if(block_mem_state_info_transition[85] == input_char)
									next[block_mem_state_info_target_state[85]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 86)
							begin
								if(block_mem_state_info_transition[86] == input_char)
									next[block_mem_state_info_target_state[86]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 87)
							begin
								if(block_mem_state_info_transition[87] == input_char)
									next[block_mem_state_info_target_state[87]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 88)
							begin
								if(block_mem_state_info_transition[88] == input_char)
									next[block_mem_state_info_target_state[88]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 89)
							begin
								if(block_mem_state_info_transition[89] == input_char)
									next[block_mem_state_info_target_state[89]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 90)
							begin
								if(block_mem_state_info_transition[90] == input_char)
									next[block_mem_state_info_target_state[90]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 91)
							begin
								if(block_mem_state_info_transition[91] == input_char)
									next[block_mem_state_info_target_state[91]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 92)
							begin
								if(block_mem_state_info_transition[92] == input_char)
									next[block_mem_state_info_target_state[92]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 93)
							begin
								if(block_mem_state_info_transition[93] == input_char)
									next[block_mem_state_info_target_state[93]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 94)
							begin
								if(block_mem_state_info_transition[94] == input_char)
									next[block_mem_state_info_target_state[94]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 95)
							begin
								if(block_mem_state_info_transition[95] == input_char)
									next[block_mem_state_info_target_state[95]] <= 1;
							end
							
							/********* second one till 31*******/
							
							if(no_cached_blocks_flag_2 > 96)
							begin
								if(block_mem_state_info_transition[96] == input_char)
									next[block_mem_state_info_target_state[96]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 97)
							begin
								if(block_mem_state_info_transition[97] == input_char)
									next[block_mem_state_info_target_state[97]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 98)
							begin
								if(block_mem_state_info_transition[98] == input_char)
									next[block_mem_state_info_target_state[98]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 99)
							begin
								if(block_mem_state_info_transition[99] == input_char)
									next[block_mem_state_info_target_state[99]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 100)
							begin
								if(block_mem_state_info_transition[100] == input_char)
									next[block_mem_state_info_target_state[100]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 101)
							begin
								if(block_mem_state_info_transition[101] == input_char)
									next[block_mem_state_info_target_state[101]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 102)
							begin
								if(block_mem_state_info_transition[102] == input_char)
									next[block_mem_state_info_target_state[102]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 103)
							begin
								if(block_mem_state_info_transition[103] == input_char)
									next[block_mem_state_info_target_state[103]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 104)
							begin
								if(block_mem_state_info_transition[104] == input_char)
									next[block_mem_state_info_target_state[104]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 105)
							begin
								if(block_mem_state_info_transition[105] == input_char)
									next[block_mem_state_info_target_state[105]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 106)
							begin
								if(block_mem_state_info_transition[106] == input_char)
									next[block_mem_state_info_target_state[106]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 107)
							begin
								if(block_mem_state_info_transition[107] == input_char)
									next[block_mem_state_info_target_state[107]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 108)
							begin
								if(block_mem_state_info_transition[108] == input_char)
									next[block_mem_state_info_target_state[108]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 109)
							begin
								if(block_mem_state_info_transition[109] == input_char)
									next[block_mem_state_info_target_state[109]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 110)
							begin
								if(block_mem_state_info_transition[110] == input_char)
									next[block_mem_state_info_target_state[110]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 111)
							begin
								if(block_mem_state_info_transition[111] == input_char)
									next[block_mem_state_info_target_state[111]] <= 1;
							end
							
							/********* third one till 47*******/
							
							if(no_cached_blocks_flag_2 > 112)
							begin
								if(block_mem_state_info_transition[112] == input_char)
									next[block_mem_state_info_target_state[112]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 113)
							begin
								if(block_mem_state_info_transition[113] == input_char)
									next[block_mem_state_info_target_state[113]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 114)
							begin
								if(block_mem_state_info_transition[114] == input_char)
									next[block_mem_state_info_target_state[114]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 115)
							begin
								if(block_mem_state_info_transition[115] == input_char)
									next[block_mem_state_info_target_state[115]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 116)
							begin
								if(block_mem_state_info_transition[116] == input_char)
									next[block_mem_state_info_target_state[116]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 117)
							begin
								if(block_mem_state_info_transition[117] == input_char)
									next[block_mem_state_info_target_state[117]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 118)
							begin
								if(block_mem_state_info_transition[118] == input_char)
									next[block_mem_state_info_target_state[118]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 119)
							begin
								if(block_mem_state_info_transition[119] == input_char)
									next[block_mem_state_info_target_state[119]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 120)
							begin
								if(block_mem_state_info_transition[120] == input_char)
									next[block_mem_state_info_target_state[120]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 121)
							begin
								if(block_mem_state_info_transition[121] == input_char)
									next[block_mem_state_info_target_state[121]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 122)
							begin
								if(block_mem_state_info_transition[122] == input_char)
									next[block_mem_state_info_target_state[122]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 123)
							begin
								if(block_mem_state_info_transition[123] == input_char)
									next[block_mem_state_info_target_state[123]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 124)
							begin
								if(block_mem_state_info_transition[124] == input_char)
									next[block_mem_state_info_target_state[124]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 125)
							begin
								if(block_mem_state_info_transition[125] == input_char)
									next[block_mem_state_info_target_state[125]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 126)
							begin
								if(block_mem_state_info_transition[126] == input_char)
									next[block_mem_state_info_target_state[126]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 127)
							begin
								if(block_mem_state_info_transition[127] == input_char)
									next[block_mem_state_info_target_state[127]] <= 1;
							end
						end
						
						flag_1_or_2 <= 2;
						no_cached_blocks_flag_2_prev <= no_cached_blocks_flag_2;
						no_cached_blocks_flag_2 <= no_cached_blocks;
					
						range_last <= range;
						range <= range_int;
						up_counter <= up_counter_int;
						rd_address <= cache_line_no;	
					end
				end
				else if(range == 0)
				begin
					
					if(flag == 1 && range_1_state == 0)
					begin
						range_1_state <= 1;
					end
					else if(flag == 1 && range_1_state == 1)
					begin
						if(flag_1_or_2 == 0)
						begin
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 1 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[0] == input_char)
									next[block_mem_state_info_target_state[0]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 2 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[1] == input_char)
									next[block_mem_state_info_target_state[1]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 3 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[2] == input_char)
									next[block_mem_state_info_target_state[2]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 4 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[3] == input_char)
									next[block_mem_state_info_target_state[3]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 5 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[4] == input_char)
									next[block_mem_state_info_target_state[4]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 6 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[5] == input_char)
									next[block_mem_state_info_target_state[5]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 7 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[6] == input_char)
									next[block_mem_state_info_target_state[6]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 8 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[7] == input_char)
									next[block_mem_state_info_target_state[7]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 9 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[8] == input_char)
									next[block_mem_state_info_target_state[8]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 10 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[9] == input_char)
									next[block_mem_state_info_target_state[9]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 11 && no_cached_blocks_flag_0 != 0)
							begin
							check <= 1;
								if(block_mem_state_info_transition[10] == input_char)
									next[block_mem_state_info_target_state[10]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 12 && no_cached_blocks_flag_0 != 0)
							begin
								//check <= 1;
								if(block_mem_state_info_transition[11] == input_char)
									next[block_mem_state_info_target_state[11]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 13 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[12] == input_char)
									next[block_mem_state_info_target_state[12]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 14 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[13] == input_char)
									next[block_mem_state_info_target_state[13]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 15 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[14] == input_char)
									next[block_mem_state_info_target_state[14]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 16 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[15] == input_char)
									next[block_mem_state_info_target_state[15]] <= 1;
							end
							
							/********* First one till 15*******/
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 17 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[16] == input_char)
									next[block_mem_state_info_target_state[16]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 18 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[17] == input_char)
									next[block_mem_state_info_target_state[17]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 19 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[18] == input_char)
									next[block_mem_state_info_target_state[18]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 20 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[19] == input_char)
									next[block_mem_state_info_target_state[19]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 21 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[20] == input_char)
									next[block_mem_state_info_target_state[20]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 22 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[21] == input_char)
									next[block_mem_state_info_target_state[21]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 23 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[22] == input_char)
									next[block_mem_state_info_target_state[22]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 24 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[23] == input_char)
									next[block_mem_state_info_target_state[23]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 25 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[24] == input_char)
									next[block_mem_state_info_target_state[24]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 26 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[25] == input_char)
									next[block_mem_state_info_target_state[25]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 27 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[26] == input_char)
									next[block_mem_state_info_target_state[26]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 28 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[27] == input_char)
									next[block_mem_state_info_target_state[27]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 29 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[28] == input_char)
									next[block_mem_state_info_target_state[28]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 30 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[29] == input_char)
									next[block_mem_state_info_target_state[29]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 31 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[30] == input_char)
									next[block_mem_state_info_target_state[30]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 32 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[31] == input_char)
									next[block_mem_state_info_target_state[31]] <= 1;
							end
							
							/********* second one till 31*******/
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 33 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[32] == input_char)
									next[block_mem_state_info_target_state[32]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 34 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[33] == input_char)
									next[block_mem_state_info_target_state[33]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 35 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[34] == input_char)
									next[block_mem_state_info_target_state[34]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 36 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[35] == input_char)
									next[block_mem_state_info_target_state[35]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 37 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[36] == input_char)
									next[block_mem_state_info_target_state[36]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 38 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[37] == input_char)
									next[block_mem_state_info_target_state[37]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 39 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[38] == input_char)
									next[block_mem_state_info_target_state[38]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 40 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[39] == input_char)
									next[block_mem_state_info_target_state[39]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 41 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[40] == input_char)
									next[block_mem_state_info_target_state[40]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 42 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[41] == input_char)
									next[block_mem_state_info_target_state[41]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 43 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[42] == input_char)
									next[block_mem_state_info_target_state[42]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 44 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[43] == input_char)
									next[block_mem_state_info_target_state[43]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 45 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[44] == input_char)
									next[block_mem_state_info_target_state[44]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 46 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[45] == input_char)
									next[block_mem_state_info_target_state[45]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 47 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[46] == input_char)
									next[block_mem_state_info_target_state[46]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 48 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[47] == input_char)
									next[block_mem_state_info_target_state[47]] <= 1;
							end
							
							/********* third one till 47*******/
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 49 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[48] == input_char)
									next[block_mem_state_info_target_state[48]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 50 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[49] == input_char)
									next[block_mem_state_info_target_state[49]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 51 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[50] == input_char)
									next[block_mem_state_info_target_state[50]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 52 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[51] == input_char)
									next[block_mem_state_info_target_state[51]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 53 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[52] == input_char)
									next[block_mem_state_info_target_state[52]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 54 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[53] == input_char)
									next[block_mem_state_info_target_state[53]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 55 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[54] == input_char)
									next[block_mem_state_info_target_state[54]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 56 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[55] == input_char)
									next[block_mem_state_info_target_state[55]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 57 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[56] == input_char)
									next[block_mem_state_info_target_state[56]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 58 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[57] == input_char)
									next[block_mem_state_info_target_state[57]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 59 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[58] == input_char)
									next[block_mem_state_info_target_state[58]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 60 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[59] == input_char)
									next[block_mem_state_info_target_state[59]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 61 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[60] == input_char)
									next[block_mem_state_info_target_state[60]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 62 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[61] == input_char)
									next[block_mem_state_info_target_state[61]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 63 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[62] == input_char)
									next[block_mem_state_info_target_state[62]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 64 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[63] == input_char)
									next[block_mem_state_info_target_state[63]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 65 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[64] == input_char)
									next[block_mem_state_info_target_state[64]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 66 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[65] == input_char)
									next[block_mem_state_info_target_state[65]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 67 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[66] == input_char)
									next[block_mem_state_info_target_state[66]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 68 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[67] == input_char)
									next[block_mem_state_info_target_state[67]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 69 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[68] == input_char)
									next[block_mem_state_info_target_state[68]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 70 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[69] == input_char)
									next[block_mem_state_info_target_state[69]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 71 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[70] == input_char)
									next[block_mem_state_info_target_state[70]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 72 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[71] == input_char)
									next[block_mem_state_info_target_state[71]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 73 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[72] == input_char)
									next[block_mem_state_info_target_state[72]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 74 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[73] == input_char)
									next[block_mem_state_info_target_state[73]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 75 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[74] == input_char)
									next[block_mem_state_info_target_state[74]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 76 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[75] == input_char)
									next[block_mem_state_info_target_state[75]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 77 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[76] == input_char)
									next[block_mem_state_info_target_state[76]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 78 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[77] == input_char)
									next[block_mem_state_info_target_state[77]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 79 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[78] == input_char)
									next[block_mem_state_info_target_state[78]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 80 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[79] == input_char)
									next[block_mem_state_info_target_state[79]] <= 1;
							end
							
							/********* First one till 15*******/
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 81 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[80] == input_char)
									next[block_mem_state_info_target_state[80]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 82 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[81] == input_char)
									next[block_mem_state_info_target_state[81]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 83 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[82] == input_char)
									next[block_mem_state_info_target_state[82]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 84 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[83] == input_char)
									next[block_mem_state_info_target_state[83]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 85 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[84] == input_char)
									next[block_mem_state_info_target_state[84]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 86 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[85] == input_char)
									next[block_mem_state_info_target_state[85]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 87 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[86] == input_char)
									next[block_mem_state_info_target_state[86]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 88 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[87] == input_char)
									next[block_mem_state_info_target_state[87]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 89 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[88] == input_char)
									next[block_mem_state_info_target_state[88]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 90 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[89] == input_char)
									next[block_mem_state_info_target_state[89]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 91 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[90] == input_char)
									next[block_mem_state_info_target_state[90]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 92 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[91] == input_char)
									next[block_mem_state_info_target_state[91]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 93 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[92] == input_char)
									next[block_mem_state_info_target_state[92]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 94 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[93] == input_char)
									next[block_mem_state_info_target_state[93]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 95 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[94] == input_char)
									next[block_mem_state_info_target_state[94]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 96 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[95] == input_char)
									next[block_mem_state_info_target_state[95]] <= 1;
							end
							
							/********* second one till 31*******/
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 97 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[96] == input_char)
									next[block_mem_state_info_target_state[96]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 98 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[97] == input_char)
									next[block_mem_state_info_target_state[97]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 99 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[98] == input_char)
									next[block_mem_state_info_target_state[98]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 100 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[99] == input_char)
									next[block_mem_state_info_target_state[99]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 101 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[100] == input_char)
									next[block_mem_state_info_target_state[100]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 102 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[101] == input_char)
									next[block_mem_state_info_target_state[101]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 103 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[102] == input_char)
									next[block_mem_state_info_target_state[102]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 104 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[103] == input_char)
									next[block_mem_state_info_target_state[103]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 105 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[104] == input_char)
									next[block_mem_state_info_target_state[104]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 106 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[105] == input_char)
									next[block_mem_state_info_target_state[105]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 107 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[106] == input_char)
									next[block_mem_state_info_target_state[106]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 108 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[107] == input_char)
									next[block_mem_state_info_target_state[107]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 109 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[108] == input_char)
									next[block_mem_state_info_target_state[108]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 110 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[109] == input_char)
									next[block_mem_state_info_target_state[109]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 111 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[110] == input_char)
									next[block_mem_state_info_target_state[110]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 112 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[111] == input_char)
									next[block_mem_state_info_target_state[111]] <= 1;
							end
							
							/********* third one till 47*******/
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 113 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[112] == input_char)
									next[block_mem_state_info_target_state[112]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 114 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[113] == input_char)
									next[block_mem_state_info_target_state[113]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 115 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[114] == input_char)
									next[block_mem_state_info_target_state[114]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 116 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[115] == input_char)
									next[block_mem_state_info_target_state[115]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 117 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[116] == input_char)
									next[block_mem_state_info_target_state[116]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 118 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[117] == input_char)
									next[block_mem_state_info_target_state[117]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 119 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[118] == input_char)
									next[block_mem_state_info_target_state[118]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 120 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[119] == input_char)
									next[block_mem_state_info_target_state[119]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 121 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[120] == input_char)
									next[block_mem_state_info_target_state[120]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 122 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[121] == input_char)
									next[block_mem_state_info_target_state[121]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 123 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[122] == input_char)
									next[block_mem_state_info_target_state[122]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 124 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[123] == input_char)
									next[block_mem_state_info_target_state[123]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 125 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[124] == input_char)
									next[block_mem_state_info_target_state[124]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 126 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[125] == input_char)
									next[block_mem_state_info_target_state[125]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 127 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[126] == input_char)
									next[block_mem_state_info_target_state[126]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 128 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[127] == input_char)
									next[block_mem_state_info_target_state[127]] <= 1;
							end
						end
	
						range_1_state <= 0;
						state <= 4;
						flag <= 0;
					end
					else if(flag == 2 && range_2_state == 0)
					begin
					
						if(flag_2 == 2)
						begin
					
							if(no_cached_blocks_flag_2_prev > 0)
							begin
								if(block_mem_state_info_transition[0] == input_char)
									next[block_mem_state_info_target_state[0]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 1)
							begin
								if(block_mem_state_info_transition[1] == input_char)
									next[block_mem_state_info_target_state[1]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 2)
							begin
								if(block_mem_state_info_transition[2] == input_char)
									next[block_mem_state_info_target_state[2]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 3)
							begin
								if(block_mem_state_info_transition[3] == input_char)
									next[block_mem_state_info_target_state[3]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 4)
							begin
								if(block_mem_state_info_transition[4] == input_char)
									next[block_mem_state_info_target_state[4]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 5)
							begin
								if(block_mem_state_info_transition[5] == input_char)
									next[block_mem_state_info_target_state[5]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 6)
							begin
								if(block_mem_state_info_transition[6] == input_char)
									next[block_mem_state_info_target_state[6]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 7)
							begin
								if(block_mem_state_info_transition[7] == input_char)
									next[block_mem_state_info_target_state[7]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 8)
							begin
								if(block_mem_state_info_transition[8] == input_char)
									next[block_mem_state_info_target_state[8]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 9)
							begin
								if(block_mem_state_info_transition[9] == input_char)
									next[block_mem_state_info_target_state[9]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 10)
							begin
								if(block_mem_state_info_transition[10] == input_char)
									next[block_mem_state_info_target_state[10]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 11)
							begin
								if(block_mem_state_info_transition[11] == input_char)
									next[block_mem_state_info_target_state[11]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 12)
							begin
								if(block_mem_state_info_transition[12] == input_char)
									next[block_mem_state_info_target_state[12]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 13)
							begin
								if(block_mem_state_info_transition[13] == input_char)
									next[block_mem_state_info_target_state[13]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 14)
							begin
								if(block_mem_state_info_transition[14] == input_char)
									next[block_mem_state_info_target_state[14]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 15)
							begin
								if(block_mem_state_info_transition[15] == input_char)
									next[block_mem_state_info_target_state[15]] <= 1;
							end
							
							/********* First one till 15*******/
							
							if(no_cached_blocks_flag_2_prev > 16)
							begin
								if(block_mem_state_info_transition[16] == input_char)
									next[block_mem_state_info_target_state[16]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 17)
							begin
								if(block_mem_state_info_transition[17] == input_char)
									next[block_mem_state_info_target_state[17]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 18)
							begin
								if(block_mem_state_info_transition[18] == input_char)
									next[block_mem_state_info_target_state[18]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 19)
							begin
								if(block_mem_state_info_transition[19] == input_char)
									next[block_mem_state_info_target_state[19]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 20)
							begin
								if(block_mem_state_info_transition[20] == input_char)
									next[block_mem_state_info_target_state[20]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 21)
							begin
								if(block_mem_state_info_transition[21] == input_char)
									next[block_mem_state_info_target_state[21]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 22)
							begin
								if(block_mem_state_info_transition[22] == input_char)
									next[block_mem_state_info_target_state[22]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 23)
							begin
								if(block_mem_state_info_transition[23] == input_char)
									next[block_mem_state_info_target_state[23]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 24)
							begin
								if(block_mem_state_info_transition[24] == input_char)
									next[block_mem_state_info_target_state[24]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 25)
							begin
								if(block_mem_state_info_transition[25] == input_char)
									next[block_mem_state_info_target_state[25]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 26)
							begin
								if(block_mem_state_info_transition[26] == input_char)
									next[block_mem_state_info_target_state[26]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 27)
							begin
								if(block_mem_state_info_transition[27] == input_char)
									next[block_mem_state_info_target_state[27]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 28)
							begin
								if(block_mem_state_info_transition[28] == input_char)
									next[block_mem_state_info_target_state[28]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 29)
							begin
								if(block_mem_state_info_transition[29] == input_char)
									next[block_mem_state_info_target_state[29]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 30)
							begin
								if(block_mem_state_info_transition[30] == input_char)
									next[block_mem_state_info_target_state[30]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 31)
							begin
								if(block_mem_state_info_transition[31] == input_char)
									next[block_mem_state_info_target_state[31]] <= 1;
							end
							
							/********* second one till 31*******/
							
							if(no_cached_blocks_flag_2_prev > 32)
							begin
								if(block_mem_state_info_transition[32] == input_char)
									next[block_mem_state_info_target_state[32]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 33)
							begin
								if(block_mem_state_info_transition[33] == input_char)
									next[block_mem_state_info_target_state[33]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 34)
							begin
								if(block_mem_state_info_transition[34] == input_char)
									next[block_mem_state_info_target_state[34]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 35)
							begin
								if(block_mem_state_info_transition[35] == input_char)
									next[block_mem_state_info_target_state[35]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 36)
							begin
								if(block_mem_state_info_transition[36] == input_char)
									next[block_mem_state_info_target_state[36]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 37)
							begin
								if(block_mem_state_info_transition[37] == input_char)
									next[block_mem_state_info_target_state[37]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 38)
							begin
								if(block_mem_state_info_transition[38] == input_char)
									next[block_mem_state_info_target_state[38]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 39)
							begin
								if(block_mem_state_info_transition[39] == input_char)
									next[block_mem_state_info_target_state[39]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 40)
							begin
								if(block_mem_state_info_transition[40] == input_char)
									next[block_mem_state_info_target_state[40]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 41)
							begin
								if(block_mem_state_info_transition[41] == input_char)
									next[block_mem_state_info_target_state[41]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 42)
							begin
								if(block_mem_state_info_transition[42] == input_char)
									next[block_mem_state_info_target_state[42]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 43)
							begin
								if(block_mem_state_info_transition[43] == input_char)
									next[block_mem_state_info_target_state[43]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 44)
							begin
								if(block_mem_state_info_transition[44] == input_char)
									next[block_mem_state_info_target_state[44]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 45)
							begin
								if(block_mem_state_info_transition[45] == input_char)
									next[block_mem_state_info_target_state[45]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 46)
							begin
								if(block_mem_state_info_transition[46] == input_char)
									next[block_mem_state_info_target_state[46]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 47)
							begin
								if(block_mem_state_info_transition[47] == input_char)
									next[block_mem_state_info_target_state[47]] <= 1;
							end
							
							/********* third one till 47*******/
							
							if(no_cached_blocks_flag_2_prev > 48)
							begin
								if(block_mem_state_info_transition[48] == input_char)
									next[block_mem_state_info_target_state[48]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 49)
							begin
								if(block_mem_state_info_transition[49] == input_char)
									next[block_mem_state_info_target_state[49]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 50)
							begin
								if(block_mem_state_info_transition[50] == input_char)
									next[block_mem_state_info_target_state[50]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 51)
							begin
								if(block_mem_state_info_transition[51] == input_char)
									next[block_mem_state_info_target_state[51]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 52)
							begin
								if(block_mem_state_info_transition[52] == input_char)
									next[block_mem_state_info_target_state[52]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 53)
							begin
								if(block_mem_state_info_transition[53] == input_char)
									next[block_mem_state_info_target_state[53]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 54)
							begin
								if(block_mem_state_info_transition[54] == input_char)
									next[block_mem_state_info_target_state[54]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 55)
							begin
								if(block_mem_state_info_transition[55] == input_char)
									next[block_mem_state_info_target_state[55]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 56)
							begin
								if(block_mem_state_info_transition[56] == input_char)
									next[block_mem_state_info_target_state[56]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 57)
							begin
								if(block_mem_state_info_transition[57] == input_char)
									next[block_mem_state_info_target_state[57]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 58)
							begin
								if(block_mem_state_info_transition[58] == input_char)
									next[block_mem_state_info_target_state[58]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 59)
							begin
								if(block_mem_state_info_transition[59] == input_char)
									next[block_mem_state_info_target_state[59]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 60)
							begin
								if(block_mem_state_info_transition[60] == input_char)
									next[block_mem_state_info_target_state[60]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 61)
							begin
								if(block_mem_state_info_transition[61] == input_char)
									next[block_mem_state_info_target_state[61]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 62)
							begin
								if(block_mem_state_info_transition[62] == input_char)
									next[block_mem_state_info_target_state[62]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 63)
							begin
								if(block_mem_state_info_transition[63] == input_char)
									next[block_mem_state_info_target_state[63]] <= 1;
							end
							
							/**----------------------------**/
							if(no_cached_blocks_flag_2_prev > 64)
							begin
								if(block_mem_state_info_transition[64] == input_char)
									next[block_mem_state_info_target_state[64]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 65)
							begin
								if(block_mem_state_info_transition[65] == input_char)
									next[block_mem_state_info_target_state[65]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 66)
							begin
								if(block_mem_state_info_transition[66] == input_char)
									next[block_mem_state_info_target_state[66]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 67)
							begin
								if(block_mem_state_info_transition[67] == input_char)
									next[block_mem_state_info_target_state[67]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 68)
							begin
								if(block_mem_state_info_transition[68] == input_char)
									next[block_mem_state_info_target_state[68]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 69)
							begin
								if(block_mem_state_info_transition[69] == input_char)
									next[block_mem_state_info_target_state[69]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 70)
							begin
								if(block_mem_state_info_transition[70] == input_char)
									next[block_mem_state_info_target_state[70]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 71)
							begin
								if(block_mem_state_info_transition[71] == input_char)
									next[block_mem_state_info_target_state[71]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 72)
							begin
								if(block_mem_state_info_transition[72] == input_char)
									next[block_mem_state_info_target_state[72]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 73)
							begin
								if(block_mem_state_info_transition[73] == input_char)
									next[block_mem_state_info_target_state[73]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 74)
							begin
								if(block_mem_state_info_transition[74] == input_char)
									next[block_mem_state_info_target_state[74]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 75)
							begin
								if(block_mem_state_info_transition[75] == input_char)
									next[block_mem_state_info_target_state[75]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 76)
							begin
								if(block_mem_state_info_transition[76] == input_char)
									next[block_mem_state_info_target_state[76]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 77)
							begin
								if(block_mem_state_info_transition[77] == input_char)
									next[block_mem_state_info_target_state[77]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 78)
							begin
								if(block_mem_state_info_transition[78] == input_char)
									next[block_mem_state_info_target_state[78]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 79)
							begin
								if(block_mem_state_info_transition[79] == input_char)
									next[block_mem_state_info_target_state[79]] <= 1;
							end
							
							/********* First one till 15*******/
							
							if(no_cached_blocks_flag_2_prev > 80)
							begin
								if(block_mem_state_info_transition[80] == input_char)
									next[block_mem_state_info_target_state[80]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 81)
							begin
								if(block_mem_state_info_transition[81] == input_char)
									next[block_mem_state_info_target_state[81]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 82)
							begin
								if(block_mem_state_info_transition[82] == input_char)
									next[block_mem_state_info_target_state[82]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 83)
							begin
								if(block_mem_state_info_transition[83] == input_char)
									next[block_mem_state_info_target_state[83]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 84)
							begin
								if(block_mem_state_info_transition[84] == input_char)
									next[block_mem_state_info_target_state[84]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 85)
							begin
								if(block_mem_state_info_transition[85] == input_char)
									next[block_mem_state_info_target_state[85]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 86)
							begin
								if(block_mem_state_info_transition[86] == input_char)
									next[block_mem_state_info_target_state[86]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 87)
							begin
								if(block_mem_state_info_transition[87] == input_char)
									next[block_mem_state_info_target_state[87]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 88)
							begin
								if(block_mem_state_info_transition[88] == input_char)
									next[block_mem_state_info_target_state[88]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 89)
							begin
								if(block_mem_state_info_transition[89] == input_char)
									next[block_mem_state_info_target_state[89]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 90)
							begin
								if(block_mem_state_info_transition[90] == input_char)
									next[block_mem_state_info_target_state[90]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 91)
							begin
								if(block_mem_state_info_transition[91] == input_char)
									next[block_mem_state_info_target_state[91]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 92)
							begin
								if(block_mem_state_info_transition[92] == input_char)
									next[block_mem_state_info_target_state[92]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 93)
							begin
								if(block_mem_state_info_transition[93] == input_char)
									next[block_mem_state_info_target_state[93]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 94)
							begin
								if(block_mem_state_info_transition[94] == input_char)
									next[block_mem_state_info_target_state[94]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 95)
							begin
								if(block_mem_state_info_transition[95] == input_char)
									next[block_mem_state_info_target_state[95]] <= 1;
							end
							
							/********* second one till 31*******/
							
							if(no_cached_blocks_flag_2_prev > 96)
							begin
								if(block_mem_state_info_transition[96] == input_char)
									next[block_mem_state_info_target_state[96]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 97)
							begin
								if(block_mem_state_info_transition[97] == input_char)
									next[block_mem_state_info_target_state[97]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 98)
							begin
								if(block_mem_state_info_transition[98] == input_char)
									next[block_mem_state_info_target_state[98]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 99)
							begin
								if(block_mem_state_info_transition[99] == input_char)
									next[block_mem_state_info_target_state[99]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 100)
							begin
								if(block_mem_state_info_transition[100] == input_char)
									next[block_mem_state_info_target_state[100]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 101)
							begin
								if(block_mem_state_info_transition[101] == input_char)
									next[block_mem_state_info_target_state[101]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 102)
							begin
								if(block_mem_state_info_transition[102] == input_char)
									next[block_mem_state_info_target_state[102]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 103)
							begin
								if(block_mem_state_info_transition[103] == input_char)
									next[block_mem_state_info_target_state[103]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 104)
							begin
								if(block_mem_state_info_transition[104] == input_char)
									next[block_mem_state_info_target_state[104]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 105)
							begin
								if(block_mem_state_info_transition[105] == input_char)
									next[block_mem_state_info_target_state[105]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 106)
							begin
								if(block_mem_state_info_transition[106] == input_char)
									next[block_mem_state_info_target_state[106]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 107)
							begin
								if(block_mem_state_info_transition[107] == input_char)
									next[block_mem_state_info_target_state[107]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 108)
							begin
								if(block_mem_state_info_transition[108] == input_char)
									next[block_mem_state_info_target_state[108]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 109)
							begin
								if(block_mem_state_info_transition[109] == input_char)
									next[block_mem_state_info_target_state[109]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 110)
							begin
								if(block_mem_state_info_transition[110] == input_char)
									next[block_mem_state_info_target_state[110]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 111)
							begin
								if(block_mem_state_info_transition[111] == input_char)
									next[block_mem_state_info_target_state[111]] <= 1;
							end
							
							/********* third one till 47*******/
							
							if(no_cached_blocks_flag_2_prev > 112)
							begin
								if(block_mem_state_info_transition[112] == input_char)
									next[block_mem_state_info_target_state[112]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 113)
							begin
								if(block_mem_state_info_transition[113] == input_char)
									next[block_mem_state_info_target_state[113]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 114)
							begin
								if(block_mem_state_info_transition[114] == input_char)
									next[block_mem_state_info_target_state[114]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 115)
							begin
								if(block_mem_state_info_transition[115] == input_char)
									next[block_mem_state_info_target_state[115]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 116)
							begin
								if(block_mem_state_info_transition[116] == input_char)
									next[block_mem_state_info_target_state[116]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 117)
							begin
								if(block_mem_state_info_transition[117] == input_char)
									next[block_mem_state_info_target_state[117]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 118)
							begin
								if(block_mem_state_info_transition[118] == input_char)
									next[block_mem_state_info_target_state[118]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 119)
							begin
								if(block_mem_state_info_transition[119] == input_char)
									next[block_mem_state_info_target_state[119]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 120)
							begin
								if(block_mem_state_info_transition[120] == input_char)
									next[block_mem_state_info_target_state[120]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 121)
							begin
								if(block_mem_state_info_transition[121] == input_char)
									next[block_mem_state_info_target_state[121]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 122)
							begin
								if(block_mem_state_info_transition[122] == input_char)
									next[block_mem_state_info_target_state[122]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 123)
							begin
								if(block_mem_state_info_transition[123] == input_char)
									next[block_mem_state_info_target_state[123]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 124)
							begin
								if(block_mem_state_info_transition[124] == input_char)
									next[block_mem_state_info_target_state[124]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 125)
							begin
								if(block_mem_state_info_transition[125] == input_char)
									next[block_mem_state_info_target_state[125]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 126)
							begin
								if(block_mem_state_info_transition[126] == input_char)
									next[block_mem_state_info_target_state[126]] <= 1;
							end
							
							if(no_cached_blocks_flag_2_prev > 127)
							begin
								if(block_mem_state_info_transition[127] == input_char)
									next[block_mem_state_info_target_state[127]] <= 1;
							end
						end
						
						if(flag_2 == 1)
						begin
							if(no_cached_blocks_flag_1 > 0)
							begin
								if(block_mem_state_info_transition[0] == input_char)
									next[block_mem_state_info_target_state[0]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 1)
							begin
								if(block_mem_state_info_transition[1] == input_char)
									next[block_mem_state_info_target_state[1]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 2)
							begin
								if(block_mem_state_info_transition[2] == input_char)
									next[block_mem_state_info_target_state[2]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 3)
							begin
								if(block_mem_state_info_transition[3] == input_char)
									next[block_mem_state_info_target_state[3]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 4)
							begin
								if(block_mem_state_info_transition[4] == input_char)
									next[block_mem_state_info_target_state[4]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 5)
							begin
								if(block_mem_state_info_transition[5] == input_char)
									next[block_mem_state_info_target_state[5]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 6)
							begin
								if(block_mem_state_info_transition[6] == input_char)
									next[block_mem_state_info_target_state[6]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 7)
							begin
								if(block_mem_state_info_transition[7] == input_char)
									next[block_mem_state_info_target_state[7]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 8)
							begin
								if(block_mem_state_info_transition[8] == input_char)
									next[block_mem_state_info_target_state[8]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 9)
							begin
								if(block_mem_state_info_transition[9] == input_char)
									next[block_mem_state_info_target_state[9]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 10)
							begin
								if(block_mem_state_info_transition[10] == input_char)
									next[block_mem_state_info_target_state[10]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 11)
							begin
								if(block_mem_state_info_transition[11] == input_char)
									next[block_mem_state_info_target_state[11]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 12)
							begin
								if(block_mem_state_info_transition[12] == input_char)
									next[block_mem_state_info_target_state[12]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 13)
							begin
								if(block_mem_state_info_transition[13] == input_char)
									next[block_mem_state_info_target_state[13]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 14)
							begin
								if(block_mem_state_info_transition[14] == input_char)
									next[block_mem_state_info_target_state[14]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 15)
							begin
								if(block_mem_state_info_transition[15] == input_char)
									next[block_mem_state_info_target_state[15]] <= 1;
							end
							
							/********* First one till 15*******/
							
							if(no_cached_blocks_flag_1 > 16)
							begin
								if(block_mem_state_info_transition[16] == input_char)
									next[block_mem_state_info_target_state[16]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 17)
							begin
								if(block_mem_state_info_transition[17] == input_char)
									next[block_mem_state_info_target_state[17]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 18)
							begin
								if(block_mem_state_info_transition[18] == input_char)
									next[block_mem_state_info_target_state[18]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 19)
							begin
								if(block_mem_state_info_transition[19] == input_char)
									next[block_mem_state_info_target_state[19]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 20)
							begin
								if(block_mem_state_info_transition[20] == input_char)
									next[block_mem_state_info_target_state[20]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 21)
							begin
								if(block_mem_state_info_transition[21] == input_char)
									next[block_mem_state_info_target_state[21]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 22)
							begin
								if(block_mem_state_info_transition[22] == input_char)
									next[block_mem_state_info_target_state[22]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 23)
							begin
								if(block_mem_state_info_transition[23] == input_char)
									next[block_mem_state_info_target_state[23]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 24)
							begin
								if(block_mem_state_info_transition[24] == input_char)
									next[block_mem_state_info_target_state[24]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 25)
							begin
								if(block_mem_state_info_transition[25] == input_char)
									next[block_mem_state_info_target_state[25]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 26)
							begin
								if(block_mem_state_info_transition[26] == input_char)
									next[block_mem_state_info_target_state[26]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 27)
							begin
								if(block_mem_state_info_transition[27] == input_char)
									next[block_mem_state_info_target_state[27]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 28)
							begin
								if(block_mem_state_info_transition[28] == input_char)
									next[block_mem_state_info_target_state[28]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 29)
							begin
								if(block_mem_state_info_transition[29] == input_char)
									next[block_mem_state_info_target_state[29]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 30)
							begin
								if(block_mem_state_info_transition[30] == input_char)
									next[block_mem_state_info_target_state[30]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 31)
							begin
								if(block_mem_state_info_transition[31] == input_char)
									next[block_mem_state_info_target_state[31]] <= 1;
							end
							
							/********* second one till 31*******/
							
							if(no_cached_blocks_flag_1 > 32)
							begin
								if(block_mem_state_info_transition[32] == input_char)
									next[block_mem_state_info_target_state[32]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 33)
							begin
								if(block_mem_state_info_transition[33] == input_char)
									next[block_mem_state_info_target_state[33]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 34)
							begin
								if(block_mem_state_info_transition[34] == input_char)
									next[block_mem_state_info_target_state[34]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 35)
							begin
								if(block_mem_state_info_transition[35] == input_char)
									next[block_mem_state_info_target_state[35]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 36)
							begin
								if(block_mem_state_info_transition[36] == input_char)
									next[block_mem_state_info_target_state[36]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 37)
							begin
								if(block_mem_state_info_transition[37] == input_char)
									next[block_mem_state_info_target_state[37]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 38)
							begin
								if(block_mem_state_info_transition[38] == input_char)
									next[block_mem_state_info_target_state[38]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 39)
							begin
								if(block_mem_state_info_transition[39] == input_char)
									next[block_mem_state_info_target_state[39]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 40)
							begin
								if(block_mem_state_info_transition[40] == input_char)
									next[block_mem_state_info_target_state[40]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 41)
							begin
								if(block_mem_state_info_transition[41] == input_char)
									next[block_mem_state_info_target_state[41]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 42)
							begin
								if(block_mem_state_info_transition[42] == input_char)
									next[block_mem_state_info_target_state[42]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 43)
							begin
								if(block_mem_state_info_transition[43] == input_char)
									next[block_mem_state_info_target_state[43]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 44)
							begin
								if(block_mem_state_info_transition[44] == input_char)
									next[block_mem_state_info_target_state[44]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 45)
							begin
								if(block_mem_state_info_transition[45] == input_char)
									next[block_mem_state_info_target_state[45]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 46)
							begin
								if(block_mem_state_info_transition[46] == input_char)
									next[block_mem_state_info_target_state[46]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 47)
							begin
								if(block_mem_state_info_transition[47] == input_char)
									next[block_mem_state_info_target_state[47]] <= 1;
							end
							
							/********* third one till 47*******/
							
							if(no_cached_blocks_flag_1 > 48)
							begin
								if(block_mem_state_info_transition[48] == input_char)
									next[block_mem_state_info_target_state[48]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 49)
							begin
								if(block_mem_state_info_transition[49] == input_char)
									next[block_mem_state_info_target_state[49]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 50)
							begin
								if(block_mem_state_info_transition[50] == input_char)
									next[block_mem_state_info_target_state[50]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 51)
							begin
								if(block_mem_state_info_transition[51] == input_char)
									next[block_mem_state_info_target_state[51]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 52)
							begin
								if(block_mem_state_info_transition[52] == input_char)
									next[block_mem_state_info_target_state[52]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 53)
							begin
								if(block_mem_state_info_transition[53] == input_char)
									next[block_mem_state_info_target_state[53]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 54)
							begin
								if(block_mem_state_info_transition[54] == input_char)
									next[block_mem_state_info_target_state[54]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 55)
							begin
								if(block_mem_state_info_transition[55] == input_char)
									next[block_mem_state_info_target_state[55]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 56)
							begin
								if(block_mem_state_info_transition[56] == input_char)
									next[block_mem_state_info_target_state[56]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 57)
							begin
								if(block_mem_state_info_transition[57] == input_char)
									next[block_mem_state_info_target_state[57]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 58)
							begin
								if(block_mem_state_info_transition[58] == input_char)
									next[block_mem_state_info_target_state[58]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 59)
							begin
								if(block_mem_state_info_transition[59] == input_char)
									next[block_mem_state_info_target_state[59]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 60)
							begin
								if(block_mem_state_info_transition[60] == input_char)
									next[block_mem_state_info_target_state[60]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 61)
							begin
								if(block_mem_state_info_transition[61] == input_char)
									next[block_mem_state_info_target_state[61]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 62)
							begin
								if(block_mem_state_info_transition[62] == input_char)
									next[block_mem_state_info_target_state[62]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 63)
							begin
								if(block_mem_state_info_transition[63] == input_char)
									next[block_mem_state_info_target_state[63]] <= 1;
							end
							
							/**----------------------------**/
							if(no_cached_blocks_flag_1 > 64)
							begin
								if(block_mem_state_info_transition[64] == input_char)
									next[block_mem_state_info_target_state[64]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 65)
							begin
								if(block_mem_state_info_transition[65] == input_char)
									next[block_mem_state_info_target_state[65]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 66)
							begin
								if(block_mem_state_info_transition[66] == input_char)
									next[block_mem_state_info_target_state[66]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 67)
							begin
								if(block_mem_state_info_transition[67] == input_char)
									next[block_mem_state_info_target_state[67]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 68)
							begin
								if(block_mem_state_info_transition[68] == input_char)
									next[block_mem_state_info_target_state[68]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 69)
							begin
								if(block_mem_state_info_transition[69] == input_char)
									next[block_mem_state_info_target_state[69]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 70)
							begin
								if(block_mem_state_info_transition[70] == input_char)
									next[block_mem_state_info_target_state[70]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 71)
							begin
								if(block_mem_state_info_transition[71] == input_char)
									next[block_mem_state_info_target_state[71]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 72)
							begin
								if(block_mem_state_info_transition[72] == input_char)
									next[block_mem_state_info_target_state[72]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 73)
							begin
								if(block_mem_state_info_transition[73] == input_char)
									next[block_mem_state_info_target_state[73]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 74)
							begin
								if(block_mem_state_info_transition[74] == input_char)
									next[block_mem_state_info_target_state[74]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 75)
							begin
								if(block_mem_state_info_transition[75] == input_char)
									next[block_mem_state_info_target_state[75]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 76)
							begin
								if(block_mem_state_info_transition[76] == input_char)
									next[block_mem_state_info_target_state[76]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 77)
							begin
								if(block_mem_state_info_transition[77] == input_char)
									next[block_mem_state_info_target_state[77]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 78)
							begin
								if(block_mem_state_info_transition[78] == input_char)
									next[block_mem_state_info_target_state[78]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 79)
							begin
								if(block_mem_state_info_transition[79] == input_char)
									next[block_mem_state_info_target_state[79]] <= 1;
							end
							
							/********* First one till 15*******/
							
							if(no_cached_blocks_flag_1 > 80)
							begin
								if(block_mem_state_info_transition[80] == input_char)
									next[block_mem_state_info_target_state[80]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 81)
							begin
								if(block_mem_state_info_transition[81] == input_char)
									next[block_mem_state_info_target_state[81]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 82)
							begin
								if(block_mem_state_info_transition[82] == input_char)
									next[block_mem_state_info_target_state[82]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 83)
							begin
								if(block_mem_state_info_transition[83] == input_char)
									next[block_mem_state_info_target_state[83]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 84)
							begin
								if(block_mem_state_info_transition[84] == input_char)
									next[block_mem_state_info_target_state[84]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 85)
							begin
								if(block_mem_state_info_transition[85] == input_char)
									next[block_mem_state_info_target_state[85]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 86)
							begin
								if(block_mem_state_info_transition[86] == input_char)
									next[block_mem_state_info_target_state[86]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 87)
							begin
								if(block_mem_state_info_transition[87] == input_char)
									next[block_mem_state_info_target_state[87]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 88)
							begin
								if(block_mem_state_info_transition[88] == input_char)
									next[block_mem_state_info_target_state[88]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 89)
							begin
								if(block_mem_state_info_transition[89] == input_char)
									next[block_mem_state_info_target_state[89]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 90)
							begin
								if(block_mem_state_info_transition[90] == input_char)
									next[block_mem_state_info_target_state[90]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 91)
							begin
								if(block_mem_state_info_transition[91] == input_char)
									next[block_mem_state_info_target_state[91]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 92)
							begin
								if(block_mem_state_info_transition[92] == input_char)
									next[block_mem_state_info_target_state[92]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 93)
							begin
								if(block_mem_state_info_transition[93] == input_char)
									next[block_mem_state_info_target_state[93]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 94)
							begin
								if(block_mem_state_info_transition[94] == input_char)
									next[block_mem_state_info_target_state[94]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 95)
							begin
								if(block_mem_state_info_transition[95] == input_char)
									next[block_mem_state_info_target_state[95]] <= 1;
							end
							
							/********* second one till 31*******/
							
							if(no_cached_blocks_flag_1 > 96)
							begin
								if(block_mem_state_info_transition[96] == input_char)
									next[block_mem_state_info_target_state[96]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 97)
							begin
								if(block_mem_state_info_transition[97] == input_char)
									next[block_mem_state_info_target_state[97]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 98)
							begin
								if(block_mem_state_info_transition[98] == input_char)
									next[block_mem_state_info_target_state[98]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 99)
							begin
								if(block_mem_state_info_transition[99] == input_char)
									next[block_mem_state_info_target_state[99]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 100)
							begin
								if(block_mem_state_info_transition[100] == input_char)
									next[block_mem_state_info_target_state[100]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 101)
							begin
								if(block_mem_state_info_transition[101] == input_char)
									next[block_mem_state_info_target_state[101]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 102)
							begin
								if(block_mem_state_info_transition[102] == input_char)
									next[block_mem_state_info_target_state[102]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 103)
							begin
								if(block_mem_state_info_transition[103] == input_char)
									next[block_mem_state_info_target_state[103]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 104)
							begin
								if(block_mem_state_info_transition[104] == input_char)
									next[block_mem_state_info_target_state[104]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 105)
							begin
								if(block_mem_state_info_transition[105] == input_char)
									next[block_mem_state_info_target_state[105]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 106)
							begin
								if(block_mem_state_info_transition[106] == input_char)
									next[block_mem_state_info_target_state[106]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 107)
							begin
								if(block_mem_state_info_transition[107] == input_char)
									next[block_mem_state_info_target_state[107]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 108)
							begin
								if(block_mem_state_info_transition[108] == input_char)
									next[block_mem_state_info_target_state[108]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 109)
							begin
								if(block_mem_state_info_transition[109] == input_char)
									next[block_mem_state_info_target_state[109]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 110)
							begin
								if(block_mem_state_info_transition[110] == input_char)
									next[block_mem_state_info_target_state[110]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 111)
							begin
								if(block_mem_state_info_transition[111] == input_char)
									next[block_mem_state_info_target_state[111]] <= 1;
							end
							
							/********* third one till 47*******/
							
							if(no_cached_blocks_flag_1 > 112)
							begin
								if(block_mem_state_info_transition[112] == input_char)
									next[block_mem_state_info_target_state[112]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 113)
							begin
								if(block_mem_state_info_transition[113] == input_char)
									next[block_mem_state_info_target_state[113]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 114)
							begin
								if(block_mem_state_info_transition[114] == input_char)
									next[block_mem_state_info_target_state[114]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 115)
							begin
								if(block_mem_state_info_transition[115] == input_char)
									next[block_mem_state_info_target_state[115]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 116)
							begin
								if(block_mem_state_info_transition[116] == input_char)
									next[block_mem_state_info_target_state[116]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 117)
							begin
								if(block_mem_state_info_transition[117] == input_char)
									next[block_mem_state_info_target_state[117]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 118)
							begin
								if(block_mem_state_info_transition[118] == input_char)
									next[block_mem_state_info_target_state[118]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 119)
							begin
								if(block_mem_state_info_transition[119] == input_char)
									next[block_mem_state_info_target_state[119]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 120)
							begin
								if(block_mem_state_info_transition[120] == input_char)
									next[block_mem_state_info_target_state[120]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 121)
							begin
								if(block_mem_state_info_transition[121] == input_char)
									next[block_mem_state_info_target_state[121]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 122)
							begin
								if(block_mem_state_info_transition[122] == input_char)
									next[block_mem_state_info_target_state[122]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 123)
							begin
								if(block_mem_state_info_transition[123] == input_char)
									next[block_mem_state_info_target_state[123]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 124)
							begin
								if(block_mem_state_info_transition[124] == input_char)
									next[block_mem_state_info_target_state[124]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 125)
							begin
								if(block_mem_state_info_transition[125] == input_char)
									next[block_mem_state_info_target_state[125]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 126)
							begin
								if(block_mem_state_info_transition[126] == input_char)
									next[block_mem_state_info_target_state[126]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 127)
							begin
								if(block_mem_state_info_transition[127] == input_char)
									next[block_mem_state_info_target_state[127]] <= 1;
							end
						end
				
						if(flag_1_or_2 == 1)
						begin
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 1 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[0] == input_char)
									next[block_mem_state_info_target_state[0]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 2 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[1] == input_char)
									next[block_mem_state_info_target_state[1]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 3 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[2] == input_char)
									next[block_mem_state_info_target_state[2]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 4 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[3] == input_char)
									next[block_mem_state_info_target_state[3]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 5 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[4] == input_char)
									next[block_mem_state_info_target_state[4]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 6 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[5] == input_char)
									next[block_mem_state_info_target_state[5]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 7 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[6] == input_char)
									next[block_mem_state_info_target_state[6]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 8 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[7] == input_char)
									next[block_mem_state_info_target_state[7]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 9 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[8] == input_char)
									next[block_mem_state_info_target_state[8]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 10 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[9] == input_char)
									next[block_mem_state_info_target_state[9]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 11 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[10] == input_char)
									next[block_mem_state_info_target_state[10]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 12 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[11] == input_char)
									next[block_mem_state_info_target_state[11]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 13 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[12] == input_char)
									next[block_mem_state_info_target_state[12]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 14 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[13] == input_char)
									next[block_mem_state_info_target_state[13]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 15 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[14] == input_char)
									next[block_mem_state_info_target_state[14]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 16 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[15] == input_char)
									next[block_mem_state_info_target_state[15]] <= 1;
							end
							
							/********* First one till 15*******/
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 17 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[16] == input_char)
									next[block_mem_state_info_target_state[16]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 18 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[17] == input_char)
									next[block_mem_state_info_target_state[17]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 19 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[18] == input_char)
									next[block_mem_state_info_target_state[18]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 20 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[19] == input_char)
									next[block_mem_state_info_target_state[19]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 21 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[20] == input_char)
									next[block_mem_state_info_target_state[20]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 22 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[21] == input_char)
									next[block_mem_state_info_target_state[21]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 23 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[22] == input_char)
									next[block_mem_state_info_target_state[22]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 24 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[23] == input_char)
									next[block_mem_state_info_target_state[23]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 25 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[24] == input_char)
									next[block_mem_state_info_target_state[24]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 26 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[25] == input_char)
									next[block_mem_state_info_target_state[25]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 27 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[26] == input_char)
									next[block_mem_state_info_target_state[26]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 28 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[27] == input_char)
									next[block_mem_state_info_target_state[27]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 29 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[28] == input_char)
									next[block_mem_state_info_target_state[28]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 30 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[29] == input_char)
									next[block_mem_state_info_target_state[29]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 31 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[30] == input_char)
									next[block_mem_state_info_target_state[30]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 32 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[31] == input_char)
									next[block_mem_state_info_target_state[31]] <= 1;
							end
							
							/********* second one till 31*******/
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 33 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[32] == input_char)
									next[block_mem_state_info_target_state[32]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 34 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[33] == input_char)
									next[block_mem_state_info_target_state[33]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 35 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[34] == input_char)
									next[block_mem_state_info_target_state[34]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 36 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[35] == input_char)
									next[block_mem_state_info_target_state[35]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 37 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[36] == input_char)
									next[block_mem_state_info_target_state[36]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 38 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[37] == input_char)
									next[block_mem_state_info_target_state[37]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 39 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[38] == input_char)
									next[block_mem_state_info_target_state[38]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 40 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[39] == input_char)
									next[block_mem_state_info_target_state[39]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 41 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[40] == input_char)
									next[block_mem_state_info_target_state[40]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 42 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[41] == input_char)
									next[block_mem_state_info_target_state[41]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 43 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[42] == input_char)
									next[block_mem_state_info_target_state[42]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 44 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[43] == input_char)
									next[block_mem_state_info_target_state[43]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 45 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[44] == input_char)
									next[block_mem_state_info_target_state[44]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 46 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[45] == input_char)
									next[block_mem_state_info_target_state[45]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 47 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[46] == input_char)
									next[block_mem_state_info_target_state[46]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 48 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[47] == input_char)
									next[block_mem_state_info_target_state[47]] <= 1;
							end
							
							/********* third one till 47*******/
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 49 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[48] == input_char)
									next[block_mem_state_info_target_state[48]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 50 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[49] == input_char)
									next[block_mem_state_info_target_state[49]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 51 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[50] == input_char)
									next[block_mem_state_info_target_state[50]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 52 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[51] == input_char)
									next[block_mem_state_info_target_state[51]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 53 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[52] == input_char)
									next[block_mem_state_info_target_state[52]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 54 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[53] == input_char)
									next[block_mem_state_info_target_state[53]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 55 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[54] == input_char)
									next[block_mem_state_info_target_state[54]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 56 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[55] == input_char)
									next[block_mem_state_info_target_state[55]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 57 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[56] == input_char)
									next[block_mem_state_info_target_state[56]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 58 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[57] == input_char)
									next[block_mem_state_info_target_state[57]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 59 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[58] == input_char)
									next[block_mem_state_info_target_state[58]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 60 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[59] == input_char)
									next[block_mem_state_info_target_state[59]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 61 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[60] == input_char)
									next[block_mem_state_info_target_state[60]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 62 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[61] == input_char)
									next[block_mem_state_info_target_state[61]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 63 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[62] == input_char)
									next[block_mem_state_info_target_state[62]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 64 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[63] == input_char)
									next[block_mem_state_info_target_state[63]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 65 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[64] == input_char)
									next[block_mem_state_info_target_state[64]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 66 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[65] == input_char)
									next[block_mem_state_info_target_state[65]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 67 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[66] == input_char)
									next[block_mem_state_info_target_state[66]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 68 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[67] == input_char)
									next[block_mem_state_info_target_state[67]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 69 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[68] == input_char)
									next[block_mem_state_info_target_state[68]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 70 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[69] == input_char)
									next[block_mem_state_info_target_state[69]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 71 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[70] == input_char)
									next[block_mem_state_info_target_state[70]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 72 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[71] == input_char)
									next[block_mem_state_info_target_state[71]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 73 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[72] == input_char)
									next[block_mem_state_info_target_state[72]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 74 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[73] == input_char)
									next[block_mem_state_info_target_state[73]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 75 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[74] == input_char)
									next[block_mem_state_info_target_state[74]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 76 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[75] == input_char)
									next[block_mem_state_info_target_state[75]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 77 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[76] == input_char)
									next[block_mem_state_info_target_state[76]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 78 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[77] == input_char)
									next[block_mem_state_info_target_state[77]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 79 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[78] == input_char)
									next[block_mem_state_info_target_state[78]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 80 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[79] == input_char)
									next[block_mem_state_info_target_state[79]] <= 1;
							end
							
							/********* First one till 15*******/
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 81 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[80] == input_char)
									next[block_mem_state_info_target_state[80]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 82 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[81] == input_char)
									next[block_mem_state_info_target_state[81]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 83 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[82] == input_char)
									next[block_mem_state_info_target_state[82]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 84 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[83] == input_char)
									next[block_mem_state_info_target_state[83]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 85 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[84] == input_char)
									next[block_mem_state_info_target_state[84]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 86 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[85] == input_char)
									next[block_mem_state_info_target_state[85]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 87 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[86] == input_char)
									next[block_mem_state_info_target_state[86]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 88 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[87] == input_char)
									next[block_mem_state_info_target_state[87]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 89 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[88] == input_char)
									next[block_mem_state_info_target_state[88]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 90 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[89] == input_char)
									next[block_mem_state_info_target_state[89]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 91 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[90] == input_char)
									next[block_mem_state_info_target_state[90]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 92 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[91] == input_char)
									next[block_mem_state_info_target_state[91]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 93 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[92] == input_char)
									next[block_mem_state_info_target_state[92]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 94 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[93] == input_char)
									next[block_mem_state_info_target_state[93]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 95 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[94] == input_char)
									next[block_mem_state_info_target_state[94]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 96 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[95] == input_char)
									next[block_mem_state_info_target_state[95]] <= 1;
							end
							
							/********* second one till 31*******/
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 97 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[96] == input_char)
									next[block_mem_state_info_target_state[96]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 98 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[97] == input_char)
									next[block_mem_state_info_target_state[97]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 99 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[98] == input_char)
									next[block_mem_state_info_target_state[98]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 100 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[99] == input_char)
									next[block_mem_state_info_target_state[99]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 101 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[100] == input_char)
									next[block_mem_state_info_target_state[100]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 102 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[101] == input_char)
									next[block_mem_state_info_target_state[101]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 103 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[102] == input_char)
									next[block_mem_state_info_target_state[102]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 104 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[103] == input_char)
									next[block_mem_state_info_target_state[103]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 105 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[104] == input_char)
									next[block_mem_state_info_target_state[104]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 106 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[105] == input_char)
									next[block_mem_state_info_target_state[105]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 107 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[106] == input_char)
									next[block_mem_state_info_target_state[106]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 108 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[107] == input_char)
									next[block_mem_state_info_target_state[107]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 109 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[108] == input_char)
									next[block_mem_state_info_target_state[108]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 110 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[109] == input_char)
									next[block_mem_state_info_target_state[109]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 111 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[110] == input_char)
									next[block_mem_state_info_target_state[110]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 112 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[111] == input_char)
									next[block_mem_state_info_target_state[111]] <= 1;
							end
							
							/********* third one till 47*******/
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 113 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[112] == input_char)
									next[block_mem_state_info_target_state[112]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 114 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[113] == input_char)
									next[block_mem_state_info_target_state[113]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 115 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[114] == input_char)
									next[block_mem_state_info_target_state[114]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 116 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[115] == input_char)
									next[block_mem_state_info_target_state[115]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 117 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[116] == input_char)
									next[block_mem_state_info_target_state[116]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 118 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[117] == input_char)
									next[block_mem_state_info_target_state[117]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 119 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[118] == input_char)
									next[block_mem_state_info_target_state[118]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 120 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[119] == input_char)
									next[block_mem_state_info_target_state[119]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 121 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[120] == input_char)
									next[block_mem_state_info_target_state[120]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 122 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[121] == input_char)
									next[block_mem_state_info_target_state[121]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 123 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[122] == input_char)
									next[block_mem_state_info_target_state[122]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 124 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[123] == input_char)
									next[block_mem_state_info_target_state[123]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 125 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[124] == input_char)
									next[block_mem_state_info_target_state[124]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 126 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[125] == input_char)
									next[block_mem_state_info_target_state[125]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 127 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[126] == input_char)
									next[block_mem_state_info_target_state[126]] <= 1;
							end
							
							if(block_offset_flag_0+no_cached_blocks_flag_0 >= 128 && no_cached_blocks_flag_0 != 0)
							begin
								if(block_mem_state_info_transition[127] == input_char)
									next[block_mem_state_info_target_state[127]] <= 1;
							end
						end
						
						range_2_state <= 1;
					end
					else if(flag == 2 && range_2_state == 1)
					begin
						
						if(flag_1_or_2 == 1)
						begin
							if(no_cached_blocks_flag_1 > 0)
							begin
								if(block_mem_state_info_transition[0] == input_char)
									next[block_mem_state_info_target_state[0]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 1)
							begin
								if(block_mem_state_info_transition[1] == input_char)
									next[block_mem_state_info_target_state[1]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 2)
							begin
								if(block_mem_state_info_transition[2] == input_char)
									next[block_mem_state_info_target_state[2]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 3)
							begin
								if(block_mem_state_info_transition[3] == input_char)
									next[block_mem_state_info_target_state[3]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 4)
							begin
								if(block_mem_state_info_transition[4] == input_char)
									next[block_mem_state_info_target_state[4]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 5)
							begin
								if(block_mem_state_info_transition[5] == input_char)
									next[block_mem_state_info_target_state[5]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 6)
							begin
								if(block_mem_state_info_transition[6] == input_char)
									next[block_mem_state_info_target_state[6]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 7)
							begin
								if(block_mem_state_info_transition[7] == input_char)
									next[block_mem_state_info_target_state[7]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 8)
							begin
								if(block_mem_state_info_transition[8] == input_char)
									next[block_mem_state_info_target_state[8]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 9)
							begin
								if(block_mem_state_info_transition[9] == input_char)
									next[block_mem_state_info_target_state[9]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 10)
							begin
								if(block_mem_state_info_transition[10] == input_char)
									next[block_mem_state_info_target_state[10]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 11)
							begin
								if(block_mem_state_info_transition[11] == input_char)
									next[block_mem_state_info_target_state[11]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 12)
							begin
								if(block_mem_state_info_transition[12] == input_char)
									next[block_mem_state_info_target_state[12]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 13)
							begin
								if(block_mem_state_info_transition[13] == input_char)
									next[block_mem_state_info_target_state[13]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 14)
							begin
								if(block_mem_state_info_transition[14] == input_char)
									next[block_mem_state_info_target_state[14]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 15)
							begin
								if(block_mem_state_info_transition[15] == input_char)
									next[block_mem_state_info_target_state[15]] <= 1;
							end
							
							/********* First one till 15*******/
							
							if(no_cached_blocks_flag_1 > 16)
							begin
								if(block_mem_state_info_transition[16] == input_char)
									next[block_mem_state_info_target_state[16]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 17)
							begin
								if(block_mem_state_info_transition[17] == input_char)
									next[block_mem_state_info_target_state[17]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 18)
							begin
								if(block_mem_state_info_transition[18] == input_char)
									next[block_mem_state_info_target_state[18]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 19)
							begin
								if(block_mem_state_info_transition[19] == input_char)
									next[block_mem_state_info_target_state[19]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 20)
							begin
								if(block_mem_state_info_transition[20] == input_char)
									next[block_mem_state_info_target_state[20]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 21)
							begin
								if(block_mem_state_info_transition[21] == input_char)
									next[block_mem_state_info_target_state[21]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 22)
							begin
								if(block_mem_state_info_transition[22] == input_char)
									next[block_mem_state_info_target_state[22]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 23)
							begin
								if(block_mem_state_info_transition[23] == input_char)
									next[block_mem_state_info_target_state[23]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 24)
							begin
								if(block_mem_state_info_transition[24] == input_char)
									next[block_mem_state_info_target_state[24]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 25)
							begin
								if(block_mem_state_info_transition[25] == input_char)
									next[block_mem_state_info_target_state[25]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 26)
							begin
								if(block_mem_state_info_transition[26] == input_char)
									next[block_mem_state_info_target_state[26]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 27)
							begin
								if(block_mem_state_info_transition[27] == input_char)
									next[block_mem_state_info_target_state[27]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 28)
							begin
								if(block_mem_state_info_transition[28] == input_char)
									next[block_mem_state_info_target_state[28]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 29)
							begin
								if(block_mem_state_info_transition[29] == input_char)
									next[block_mem_state_info_target_state[29]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 30)
							begin
								if(block_mem_state_info_transition[30] == input_char)
									next[block_mem_state_info_target_state[30]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 31)
							begin
								if(block_mem_state_info_transition[31] == input_char)
									next[block_mem_state_info_target_state[31]] <= 1;
							end
							
							/********* second one till 31*******/
							
							if(no_cached_blocks_flag_1 > 32)
							begin
								if(block_mem_state_info_transition[32] == input_char)
									next[block_mem_state_info_target_state[32]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 33)
							begin
								if(block_mem_state_info_transition[33] == input_char)
									next[block_mem_state_info_target_state[33]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 34)
							begin
								if(block_mem_state_info_transition[34] == input_char)
									next[block_mem_state_info_target_state[34]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 35)
							begin
								if(block_mem_state_info_transition[35] == input_char)
									next[block_mem_state_info_target_state[35]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 36)
							begin
								if(block_mem_state_info_transition[36] == input_char)
									next[block_mem_state_info_target_state[36]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 37)
							begin
								if(block_mem_state_info_transition[37] == input_char)
									next[block_mem_state_info_target_state[37]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 38)
							begin
								if(block_mem_state_info_transition[38] == input_char)
									next[block_mem_state_info_target_state[38]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 39)
							begin
								if(block_mem_state_info_transition[39] == input_char)
									next[block_mem_state_info_target_state[39]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 40)
							begin
								if(block_mem_state_info_transition[40] == input_char)
									next[block_mem_state_info_target_state[40]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 41)
							begin
								if(block_mem_state_info_transition[41] == input_char)
									next[block_mem_state_info_target_state[41]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 42)
							begin
								if(block_mem_state_info_transition[42] == input_char)
									next[block_mem_state_info_target_state[42]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 43)
							begin
								if(block_mem_state_info_transition[43] == input_char)
									next[block_mem_state_info_target_state[43]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 44)
							begin
								if(block_mem_state_info_transition[44] == input_char)
									next[block_mem_state_info_target_state[44]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 45)
							begin
								if(block_mem_state_info_transition[45] == input_char)
									next[block_mem_state_info_target_state[45]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 46)
							begin
								if(block_mem_state_info_transition[46] == input_char)
									next[block_mem_state_info_target_state[46]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 47)
							begin
								if(block_mem_state_info_transition[47] == input_char)
									next[block_mem_state_info_target_state[47]] <= 1;
							end
							
							/********* third one till 47*******/
							
							if(no_cached_blocks_flag_1 > 48)
							begin
								if(block_mem_state_info_transition[48] == input_char)
									next[block_mem_state_info_target_state[48]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 49)
							begin
								if(block_mem_state_info_transition[49] == input_char)
									next[block_mem_state_info_target_state[49]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 50)
							begin
								if(block_mem_state_info_transition[50] == input_char)
									next[block_mem_state_info_target_state[50]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 51)
							begin
								if(block_mem_state_info_transition[51] == input_char)
									next[block_mem_state_info_target_state[51]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 52)
							begin
								if(block_mem_state_info_transition[52] == input_char)
									next[block_mem_state_info_target_state[52]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 53)
							begin
								if(block_mem_state_info_transition[53] == input_char)
									next[block_mem_state_info_target_state[53]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 54)
							begin
								if(block_mem_state_info_transition[54] == input_char)
									next[block_mem_state_info_target_state[54]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 55)
							begin
								if(block_mem_state_info_transition[55] == input_char)
									next[block_mem_state_info_target_state[55]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 56)
							begin
								if(block_mem_state_info_transition[56] == input_char)
									next[block_mem_state_info_target_state[56]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 57)
							begin
								if(block_mem_state_info_transition[57] == input_char)
									next[block_mem_state_info_target_state[57]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 58)
							begin
								if(block_mem_state_info_transition[58] == input_char)
									next[block_mem_state_info_target_state[58]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 59)
							begin
								if(block_mem_state_info_transition[59] == input_char)
									next[block_mem_state_info_target_state[59]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 60)
							begin
								if(block_mem_state_info_transition[60] == input_char)
									next[block_mem_state_info_target_state[60]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 61)
							begin
								if(block_mem_state_info_transition[61] == input_char)
									next[block_mem_state_info_target_state[61]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 62)
							begin
								if(block_mem_state_info_transition[62] == input_char)
									next[block_mem_state_info_target_state[62]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 63)
							begin
								if(block_mem_state_info_transition[63] == input_char)
									next[block_mem_state_info_target_state[63]] <= 1;
							end
							
							/**----------------------------**/
							if(no_cached_blocks_flag_1 > 64)
							begin
								if(block_mem_state_info_transition[64] == input_char)
									next[block_mem_state_info_target_state[64]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 65)
							begin
								if(block_mem_state_info_transition[65] == input_char)
									next[block_mem_state_info_target_state[65]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 66)
							begin
								if(block_mem_state_info_transition[66] == input_char)
									next[block_mem_state_info_target_state[66]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 67)
							begin
								if(block_mem_state_info_transition[67] == input_char)
									next[block_mem_state_info_target_state[67]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 68)
							begin
								if(block_mem_state_info_transition[68] == input_char)
									next[block_mem_state_info_target_state[68]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 69)
							begin
								if(block_mem_state_info_transition[69] == input_char)
									next[block_mem_state_info_target_state[69]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 70)
							begin
								if(block_mem_state_info_transition[70] == input_char)
									next[block_mem_state_info_target_state[70]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 71)
							begin
								if(block_mem_state_info_transition[71] == input_char)
									next[block_mem_state_info_target_state[71]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 72)
							begin
								if(block_mem_state_info_transition[72] == input_char)
									next[block_mem_state_info_target_state[72]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 73)
							begin
								if(block_mem_state_info_transition[73] == input_char)
									next[block_mem_state_info_target_state[73]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 74)
							begin
								if(block_mem_state_info_transition[74] == input_char)
									next[block_mem_state_info_target_state[74]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 75)
							begin
								if(block_mem_state_info_transition[75] == input_char)
									next[block_mem_state_info_target_state[75]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 76)
							begin
								if(block_mem_state_info_transition[76] == input_char)
									next[block_mem_state_info_target_state[76]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 77)
							begin
								if(block_mem_state_info_transition[77] == input_char)
									next[block_mem_state_info_target_state[77]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 78)
							begin
								if(block_mem_state_info_transition[78] == input_char)
									next[block_mem_state_info_target_state[78]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 79)
							begin
								if(block_mem_state_info_transition[79] == input_char)
									next[block_mem_state_info_target_state[79]] <= 1;
							end
							
							/********* First one till 15*******/
							
							if(no_cached_blocks_flag_1 > 80)
							begin
								if(block_mem_state_info_transition[80] == input_char)
									next[block_mem_state_info_target_state[80]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 81)
							begin
								if(block_mem_state_info_transition[81] == input_char)
									next[block_mem_state_info_target_state[81]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 82)
							begin
								if(block_mem_state_info_transition[82] == input_char)
									next[block_mem_state_info_target_state[82]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 83)
							begin
								if(block_mem_state_info_transition[83] == input_char)
									next[block_mem_state_info_target_state[83]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 84)
							begin
								if(block_mem_state_info_transition[84] == input_char)
									next[block_mem_state_info_target_state[84]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 85)
							begin
								if(block_mem_state_info_transition[85] == input_char)
									next[block_mem_state_info_target_state[85]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 86)
							begin
								if(block_mem_state_info_transition[86] == input_char)
									next[block_mem_state_info_target_state[86]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 87)
							begin
								if(block_mem_state_info_transition[87] == input_char)
									next[block_mem_state_info_target_state[87]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 88)
							begin
								if(block_mem_state_info_transition[88] == input_char)
									next[block_mem_state_info_target_state[88]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 89)
							begin
								if(block_mem_state_info_transition[89] == input_char)
									next[block_mem_state_info_target_state[89]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 90)
							begin
								if(block_mem_state_info_transition[90] == input_char)
									next[block_mem_state_info_target_state[90]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 91)
							begin
								if(block_mem_state_info_transition[91] == input_char)
									next[block_mem_state_info_target_state[91]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 92)
							begin
								if(block_mem_state_info_transition[92] == input_char)
									next[block_mem_state_info_target_state[92]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 93)
							begin
								if(block_mem_state_info_transition[93] == input_char)
									next[block_mem_state_info_target_state[93]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 94)
							begin
								if(block_mem_state_info_transition[94] == input_char)
									next[block_mem_state_info_target_state[94]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 95)
							begin
								if(block_mem_state_info_transition[95] == input_char)
									next[block_mem_state_info_target_state[95]] <= 1;
							end
							
							/********* second one till 31*******/
							
							if(no_cached_blocks_flag_1 > 96)
							begin
								if(block_mem_state_info_transition[96] == input_char)
									next[block_mem_state_info_target_state[96]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 97)
							begin
								if(block_mem_state_info_transition[97] == input_char)
									next[block_mem_state_info_target_state[97]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 98)
							begin
								if(block_mem_state_info_transition[98] == input_char)
									next[block_mem_state_info_target_state[98]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 99)
							begin
								if(block_mem_state_info_transition[99] == input_char)
									next[block_mem_state_info_target_state[99]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 100)
							begin
								if(block_mem_state_info_transition[100] == input_char)
									next[block_mem_state_info_target_state[100]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 101)
							begin
								if(block_mem_state_info_transition[101] == input_char)
									next[block_mem_state_info_target_state[101]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 102)
							begin
								if(block_mem_state_info_transition[102] == input_char)
									next[block_mem_state_info_target_state[102]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 103)
							begin
								if(block_mem_state_info_transition[103] == input_char)
									next[block_mem_state_info_target_state[103]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 104)
							begin
								if(block_mem_state_info_transition[104] == input_char)
									next[block_mem_state_info_target_state[104]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 105)
							begin
								if(block_mem_state_info_transition[105] == input_char)
									next[block_mem_state_info_target_state[105]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 106)
							begin
								if(block_mem_state_info_transition[106] == input_char)
									next[block_mem_state_info_target_state[106]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 107)
							begin
								if(block_mem_state_info_transition[107] == input_char)
									next[block_mem_state_info_target_state[107]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 108)
							begin
								if(block_mem_state_info_transition[108] == input_char)
									next[block_mem_state_info_target_state[108]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 109)
							begin
								if(block_mem_state_info_transition[109] == input_char)
									next[block_mem_state_info_target_state[109]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 110)
							begin
								if(block_mem_state_info_transition[110] == input_char)
									next[block_mem_state_info_target_state[110]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 111)
							begin
								if(block_mem_state_info_transition[111] == input_char)
									next[block_mem_state_info_target_state[111]] <= 1;
							end
							
							/********* third one till 47*******/
							
							if(no_cached_blocks_flag_1 > 112)
							begin
								if(block_mem_state_info_transition[112] == input_char)
									next[block_mem_state_info_target_state[112]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 113)
							begin
								if(block_mem_state_info_transition[113] == input_char)
									next[block_mem_state_info_target_state[113]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 114)
							begin
								if(block_mem_state_info_transition[114] == input_char)
									next[block_mem_state_info_target_state[114]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 115)
							begin
								if(block_mem_state_info_transition[115] == input_char)
									next[block_mem_state_info_target_state[115]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 116)
							begin
								if(block_mem_state_info_transition[116] == input_char)
									next[block_mem_state_info_target_state[116]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 117)
							begin
								if(block_mem_state_info_transition[117] == input_char)
									next[block_mem_state_info_target_state[117]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 118)
							begin
								if(block_mem_state_info_transition[118] == input_char)
									next[block_mem_state_info_target_state[118]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 119)
							begin
								if(block_mem_state_info_transition[119] == input_char)
									next[block_mem_state_info_target_state[119]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 120)
							begin
								if(block_mem_state_info_transition[120] == input_char)
									next[block_mem_state_info_target_state[120]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 121)
							begin
								if(block_mem_state_info_transition[121] == input_char)
									next[block_mem_state_info_target_state[121]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 122)
							begin
								if(block_mem_state_info_transition[122] == input_char)
									next[block_mem_state_info_target_state[122]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 123)
							begin
								if(block_mem_state_info_transition[123] == input_char)
									next[block_mem_state_info_target_state[123]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 124)
							begin
								if(block_mem_state_info_transition[124] == input_char)
									next[block_mem_state_info_target_state[124]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 125)
							begin
								if(block_mem_state_info_transition[125] == input_char)
									next[block_mem_state_info_target_state[125]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 126)
							begin
								if(block_mem_state_info_transition[126] == input_char)
									next[block_mem_state_info_target_state[126]] <= 1;
							end
							
							if(no_cached_blocks_flag_1 > 127)
							begin
								if(block_mem_state_info_transition[127] == input_char)
									next[block_mem_state_info_target_state[127]] <= 1;
							end
						end
						
						if(flag_1_or_2 == 2)
						begin
							if(no_cached_blocks_flag_2 > 0)
							begin
								if(block_mem_state_info_transition[0] == input_char)
									next[block_mem_state_info_target_state[0]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 1)
							begin
								if(block_mem_state_info_transition[1] == input_char)
									next[block_mem_state_info_target_state[1]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 2)
							begin
								if(block_mem_state_info_transition[2] == input_char)
									next[block_mem_state_info_target_state[2]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 3)
							begin
								if(block_mem_state_info_transition[3] == input_char)
									next[block_mem_state_info_target_state[3]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 4)
							begin
								if(block_mem_state_info_transition[4] == input_char)
									next[block_mem_state_info_target_state[4]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 5)
							begin
								if(block_mem_state_info_transition[5] == input_char)
									next[block_mem_state_info_target_state[5]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 6)
							begin
								if(block_mem_state_info_transition[6] == input_char)
									next[block_mem_state_info_target_state[6]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 7)
							begin
								if(block_mem_state_info_transition[7] == input_char)
									next[block_mem_state_info_target_state[7]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 8)
							begin
								if(block_mem_state_info_transition[8] == input_char)
									next[block_mem_state_info_target_state[8]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 9)
							begin
								if(block_mem_state_info_transition[9] == input_char)
									next[block_mem_state_info_target_state[9]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 10)
							begin
								if(block_mem_state_info_transition[10] == input_char)
									next[block_mem_state_info_target_state[10]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 11)
							begin
								if(block_mem_state_info_transition[11] == input_char)
									next[block_mem_state_info_target_state[11]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 12)
							begin
								if(block_mem_state_info_transition[12] == input_char)
									next[block_mem_state_info_target_state[12]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 13)
							begin
								if(block_mem_state_info_transition[13] == input_char)
									next[block_mem_state_info_target_state[13]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 14)
							begin
								if(block_mem_state_info_transition[14] == input_char)
									next[block_mem_state_info_target_state[14]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 15)
							begin
								if(block_mem_state_info_transition[15] == input_char)
									next[block_mem_state_info_target_state[15]] <= 1;
							end
							
							/********* First one till 15*******/
							
							if(no_cached_blocks_flag_2 > 16)
							begin
								if(block_mem_state_info_transition[16] == input_char)
									next[block_mem_state_info_target_state[16]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 17)
							begin
								if(block_mem_state_info_transition[17] == input_char)
									next[block_mem_state_info_target_state[17]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 18)
							begin
								if(block_mem_state_info_transition[18] == input_char)
									next[block_mem_state_info_target_state[18]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 19)
							begin
								if(block_mem_state_info_transition[19] == input_char)
									next[block_mem_state_info_target_state[19]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 20)
							begin
								if(block_mem_state_info_transition[20] == input_char)
									next[block_mem_state_info_target_state[20]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 21)
							begin
								if(block_mem_state_info_transition[21] == input_char)
									next[block_mem_state_info_target_state[21]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 22)
							begin
								if(block_mem_state_info_transition[22] == input_char)
									next[block_mem_state_info_target_state[22]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 23)
							begin
								if(block_mem_state_info_transition[23] == input_char)
									next[block_mem_state_info_target_state[23]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 24)
							begin
								if(block_mem_state_info_transition[24] == input_char)
									next[block_mem_state_info_target_state[24]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 25)
							begin
								if(block_mem_state_info_transition[25] == input_char)
									next[block_mem_state_info_target_state[25]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 26)
							begin
								if(block_mem_state_info_transition[26] == input_char)
									next[block_mem_state_info_target_state[26]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 27)
							begin
								if(block_mem_state_info_transition[27] == input_char)
									next[block_mem_state_info_target_state[27]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 28)
							begin
								if(block_mem_state_info_transition[28] == input_char)
									next[block_mem_state_info_target_state[28]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 29)
							begin
								if(block_mem_state_info_transition[29] == input_char)
									next[block_mem_state_info_target_state[29]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 30)
							begin
								if(block_mem_state_info_transition[30] == input_char)
									next[block_mem_state_info_target_state[30]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 31)
							begin
								if(block_mem_state_info_transition[31] == input_char)
									next[block_mem_state_info_target_state[31]] <= 1;
							end
							
							/********* second one till 31*******/
							
							if(no_cached_blocks_flag_2 > 32)
							begin
								if(block_mem_state_info_transition[32] == input_char)
									next[block_mem_state_info_target_state[32]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 33)
							begin
								if(block_mem_state_info_transition[33] == input_char)
									next[block_mem_state_info_target_state[33]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 34)
							begin
								if(block_mem_state_info_transition[34] == input_char)
									next[block_mem_state_info_target_state[34]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 35)
							begin
								if(block_mem_state_info_transition[35] == input_char)
									next[block_mem_state_info_target_state[35]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 36)
							begin
								if(block_mem_state_info_transition[36] == input_char)
									next[block_mem_state_info_target_state[36]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 37)
							begin
								if(block_mem_state_info_transition[37] == input_char)
									next[block_mem_state_info_target_state[37]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 38)
							begin
								if(block_mem_state_info_transition[38] == input_char)
									next[block_mem_state_info_target_state[38]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 39)
							begin
								if(block_mem_state_info_transition[39] == input_char)
									next[block_mem_state_info_target_state[39]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 40)
							begin
								if(block_mem_state_info_transition[40] == input_char)
									next[block_mem_state_info_target_state[40]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 41)
							begin
								if(block_mem_state_info_transition[41] == input_char)
									next[block_mem_state_info_target_state[41]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 42)
							begin
								if(block_mem_state_info_transition[42] == input_char)
									next[block_mem_state_info_target_state[42]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 43)
							begin
								if(block_mem_state_info_transition[43] == input_char)
									next[block_mem_state_info_target_state[43]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 44)
							begin
								if(block_mem_state_info_transition[44] == input_char)
									next[block_mem_state_info_target_state[44]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 45)
							begin
								if(block_mem_state_info_transition[45] == input_char)
									next[block_mem_state_info_target_state[45]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 46)
							begin
								if(block_mem_state_info_transition[46] == input_char)
									next[block_mem_state_info_target_state[46]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 47)
							begin
								if(block_mem_state_info_transition[47] == input_char)
									next[block_mem_state_info_target_state[47]] <= 1;
							end
							
							/********* third one till 47*******/
							
							if(no_cached_blocks_flag_2 > 48)
							begin
								if(block_mem_state_info_transition[48] == input_char)
									next[block_mem_state_info_target_state[48]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 49)
							begin
								if(block_mem_state_info_transition[49] == input_char)
									next[block_mem_state_info_target_state[49]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 50)
							begin
								if(block_mem_state_info_transition[50] == input_char)
									next[block_mem_state_info_target_state[50]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 51)
							begin
								if(block_mem_state_info_transition[51] == input_char)
									next[block_mem_state_info_target_state[51]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 52)
							begin
								if(block_mem_state_info_transition[52] == input_char)
									next[block_mem_state_info_target_state[52]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 53)
							begin
								if(block_mem_state_info_transition[53] == input_char)
									next[block_mem_state_info_target_state[53]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 54)
							begin
								if(block_mem_state_info_transition[54] == input_char)
									next[block_mem_state_info_target_state[54]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 55)
							begin
								if(block_mem_state_info_transition[55] == input_char)
									next[block_mem_state_info_target_state[55]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 56)
							begin
								if(block_mem_state_info_transition[56] == input_char)
									next[block_mem_state_info_target_state[56]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 57)
							begin
								if(block_mem_state_info_transition[57] == input_char)
									next[block_mem_state_info_target_state[57]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 58)
							begin
								if(block_mem_state_info_transition[58] == input_char)
									next[block_mem_state_info_target_state[58]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 59)
							begin
								if(block_mem_state_info_transition[59] == input_char)
									next[block_mem_state_info_target_state[59]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 60)
							begin
								if(block_mem_state_info_transition[60] == input_char)
									next[block_mem_state_info_target_state[60]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 61)
							begin
								if(block_mem_state_info_transition[61] == input_char)
									next[block_mem_state_info_target_state[61]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 62)
							begin
								if(block_mem_state_info_transition[62] == input_char)
									next[block_mem_state_info_target_state[62]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 63)
							begin
								if(block_mem_state_info_transition[63] == input_char)
									next[block_mem_state_info_target_state[63]] <= 1;
							end
							
							/**----------------------------**/
							if(no_cached_blocks_flag_2 > 64)
							begin
								if(block_mem_state_info_transition[64] == input_char)
									next[block_mem_state_info_target_state[64]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 65)
							begin
								if(block_mem_state_info_transition[65] == input_char)
									next[block_mem_state_info_target_state[65]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 66)
							begin
								if(block_mem_state_info_transition[66] == input_char)
									next[block_mem_state_info_target_state[66]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 67)
							begin
								if(block_mem_state_info_transition[67] == input_char)
									next[block_mem_state_info_target_state[67]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 68)
							begin
								if(block_mem_state_info_transition[68] == input_char)
									next[block_mem_state_info_target_state[68]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 69)
							begin
								if(block_mem_state_info_transition[69] == input_char)
									next[block_mem_state_info_target_state[69]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 70)
							begin
								if(block_mem_state_info_transition[70] == input_char)
									next[block_mem_state_info_target_state[70]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 71)
							begin
								if(block_mem_state_info_transition[71] == input_char)
									next[block_mem_state_info_target_state[71]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 72)
							begin
								if(block_mem_state_info_transition[72] == input_char)
									next[block_mem_state_info_target_state[72]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 73)
							begin
								if(block_mem_state_info_transition[73] == input_char)
									next[block_mem_state_info_target_state[73]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 74)
							begin
								if(block_mem_state_info_transition[74] == input_char)
									next[block_mem_state_info_target_state[74]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 75)
							begin
								if(block_mem_state_info_transition[75] == input_char)
									next[block_mem_state_info_target_state[75]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 76)
							begin
								if(block_mem_state_info_transition[76] == input_char)
									next[block_mem_state_info_target_state[76]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 77)
							begin
								if(block_mem_state_info_transition[77] == input_char)
									next[block_mem_state_info_target_state[77]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 78)
							begin
								if(block_mem_state_info_transition[78] == input_char)
									next[block_mem_state_info_target_state[78]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 79)
							begin
								if(block_mem_state_info_transition[79] == input_char)
									next[block_mem_state_info_target_state[79]] <= 1;
							end
							
							/********* First one till 15*******/
							
							if(no_cached_blocks_flag_2 > 80)
							begin
								if(block_mem_state_info_transition[80] == input_char)
									next[block_mem_state_info_target_state[80]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 81)
							begin
								if(block_mem_state_info_transition[81] == input_char)
									next[block_mem_state_info_target_state[81]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 82)
							begin
								if(block_mem_state_info_transition[82] == input_char)
									next[block_mem_state_info_target_state[82]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 83)
							begin
								if(block_mem_state_info_transition[83] == input_char)
									next[block_mem_state_info_target_state[83]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 84)
							begin
								if(block_mem_state_info_transition[84] == input_char)
									next[block_mem_state_info_target_state[84]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 85)
							begin
								if(block_mem_state_info_transition[85] == input_char)
									next[block_mem_state_info_target_state[85]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 86)
							begin
								if(block_mem_state_info_transition[86] == input_char)
									next[block_mem_state_info_target_state[86]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 87)
							begin
								if(block_mem_state_info_transition[87] == input_char)
									next[block_mem_state_info_target_state[87]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 88)
							begin
								if(block_mem_state_info_transition[88] == input_char)
									next[block_mem_state_info_target_state[88]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 89)
							begin
								if(block_mem_state_info_transition[89] == input_char)
									next[block_mem_state_info_target_state[89]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 90)
							begin
								if(block_mem_state_info_transition[90] == input_char)
									next[block_mem_state_info_target_state[90]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 91)
							begin
								if(block_mem_state_info_transition[91] == input_char)
									next[block_mem_state_info_target_state[91]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 92)
							begin
								if(block_mem_state_info_transition[92] == input_char)
									next[block_mem_state_info_target_state[92]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 93)
							begin
								if(block_mem_state_info_transition[93] == input_char)
									next[block_mem_state_info_target_state[93]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 94)
							begin
								if(block_mem_state_info_transition[94] == input_char)
									next[block_mem_state_info_target_state[94]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 95)
							begin
								if(block_mem_state_info_transition[95] == input_char)
									next[block_mem_state_info_target_state[95]] <= 1;
							end
							
							/********* second one till 31*******/
							
							if(no_cached_blocks_flag_2 > 96)
							begin
								if(block_mem_state_info_transition[96] == input_char)
									next[block_mem_state_info_target_state[96]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 97)
							begin
								if(block_mem_state_info_transition[97] == input_char)
									next[block_mem_state_info_target_state[97]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 98)
							begin
								if(block_mem_state_info_transition[98] == input_char)
									next[block_mem_state_info_target_state[98]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 99)
							begin
								if(block_mem_state_info_transition[99] == input_char)
									next[block_mem_state_info_target_state[99]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 100)
							begin
								if(block_mem_state_info_transition[100] == input_char)
									next[block_mem_state_info_target_state[100]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 101)
							begin
								if(block_mem_state_info_transition[101] == input_char)
									next[block_mem_state_info_target_state[101]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 102)
							begin
								if(block_mem_state_info_transition[102] == input_char)
									next[block_mem_state_info_target_state[102]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 103)
							begin
								if(block_mem_state_info_transition[103] == input_char)
									next[block_mem_state_info_target_state[103]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 104)
							begin
								if(block_mem_state_info_transition[104] == input_char)
									next[block_mem_state_info_target_state[104]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 105)
							begin
								if(block_mem_state_info_transition[105] == input_char)
									next[block_mem_state_info_target_state[105]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 106)
							begin
								if(block_mem_state_info_transition[106] == input_char)
									next[block_mem_state_info_target_state[106]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 107)
							begin
								if(block_mem_state_info_transition[107] == input_char)
									next[block_mem_state_info_target_state[107]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 108)
							begin
								if(block_mem_state_info_transition[108] == input_char)
									next[block_mem_state_info_target_state[108]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 109)
							begin
								if(block_mem_state_info_transition[109] == input_char)
									next[block_mem_state_info_target_state[109]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 110)
							begin
								if(block_mem_state_info_transition[110] == input_char)
									next[block_mem_state_info_target_state[110]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 111)
							begin
								if(block_mem_state_info_transition[111] == input_char)
									next[block_mem_state_info_target_state[111]] <= 1;
							end
							
							/********* third one till 47*******/
							
							if(no_cached_blocks_flag_2 > 112)
							begin
								if(block_mem_state_info_transition[112] == input_char)
									next[block_mem_state_info_target_state[112]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 113)
							begin
								if(block_mem_state_info_transition[113] == input_char)
									next[block_mem_state_info_target_state[113]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 114)
							begin
								if(block_mem_state_info_transition[114] == input_char)
									next[block_mem_state_info_target_state[114]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 115)
							begin
								if(block_mem_state_info_transition[115] == input_char)
									next[block_mem_state_info_target_state[115]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 116)
							begin
								if(block_mem_state_info_transition[116] == input_char)
									next[block_mem_state_info_target_state[116]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 117)
							begin
								if(block_mem_state_info_transition[117] == input_char)
									next[block_mem_state_info_target_state[117]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 118)
							begin
								if(block_mem_state_info_transition[118] == input_char)
									next[block_mem_state_info_target_state[118]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 119)
							begin
								if(block_mem_state_info_transition[119] == input_char)
									next[block_mem_state_info_target_state[119]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 120)
							begin
								if(block_mem_state_info_transition[120] == input_char)
									next[block_mem_state_info_target_state[120]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 121)
							begin
								if(block_mem_state_info_transition[121] == input_char)
									next[block_mem_state_info_target_state[121]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 122)
							begin
								if(block_mem_state_info_transition[122] == input_char)
									next[block_mem_state_info_target_state[122]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 123)
							begin
								if(block_mem_state_info_transition[123] == input_char)
									next[block_mem_state_info_target_state[123]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 124)
							begin
								if(block_mem_state_info_transition[124] == input_char)
									next[block_mem_state_info_target_state[124]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 125)
							begin
								if(block_mem_state_info_transition[125] == input_char)
									next[block_mem_state_info_target_state[125]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 126)
							begin
								if(block_mem_state_info_transition[126] == input_char)
									next[block_mem_state_info_target_state[126]] <= 1;
							end
							
							if(no_cached_blocks_flag_2 > 127)
							begin
								if(block_mem_state_info_transition[127] == input_char)
									next[block_mem_state_info_target_state[127]] <= 1;
							end
						end
						
						range_2_state <= 0;
						state <= 4;
						flag <= 0;
					end
					else
					begin
					//----------------------accepting state-------------------
						state <= 4;
						flag <= 0;
					end
					
				end
			
			end
			else if(state == 4)
			begin
				
				flag_2 <= 0;
				state <= 0;
			
				if(i<size-1)
				begin
					i <= i + 1;
					//state <= 0;
				end				
				else
				begin
					current <= ~(~next);
					
					/*if(next[iter] == 1)
					begin
						active[iter] <= active[iter] + 1;
					end*/
					
					for(iter = 0; iter < size_range; iter = iter+1)
						if(next[iter] == 1)
						begin
							active[iter] <= active[iter] + 1;
						end
					
					next <= 0;
					i <= 0;
					input_char_flag <= 1; 
				end
				
			end
			else if(current[i] != 1 && state == 0)
			begin
				if(i<size-1)
				begin
					input_char_flag <= 0;
					i <= i + 1;
				end				
				else
				begin
					current <= ~(~next);
				
					/*if(next[iter] == 1)
					begin
						active[iter] <= active[iter] + 1;
					end*/
					
					for(iter = 0; iter < size_range; iter = iter+1)
						if(next[iter] == 1)
						begin
							active[iter] <= active[iter] + 1;
						end
						
					next <= 0;
					
					i <= 0;
					input_char_flag <= 1; 
					
				end
			end
			
		end
	end


	always@(*)
	begin		
		offset =  size + 1;
		
		rd_address_int = 32'bz;
		block_offset = 7'bz;
		block_offset_plus_one = 7'bz;
		cache_line_no = 19'bz;
		
		if(current[i] == 1 && state ==0)
		begin
			rd_address_int = i;
			block_offset = rd_address_int[7:0];
			block_offset_plus_one = block_offset + 1'b1;
			cache_line_no = rd_address_int >> 7;
		end
		
		if(flag == 0 && state == 3 && range > 0)
		begin
			
			//fetching next line and extarcting the useful blocks
			
			rd_address_int = offset + up_counter;
			block_offset = rd_address_int[7:0];
			cache_line_no = rd_address_int >> 7;
			
			//checking if the no of useful blocks >==< range
			no_cached_blocks_int = 128 - block_offset;
			
			if(range>no_cached_blocks_int)
				no_cached_blocks = no_cached_blocks_int;
			else
				no_cached_blocks = range;
				
			//updating the upcounter according to no of useful cached blocks
			if(range > no_cached_blocks)
				up_counter_int = up_counter + no_cached_blocks;
			else
				up_counter_int = up_counter + range;
				
			//updating the range according to no of useful cached blocks
			if(range > no_cached_blocks)
				range_int = range - no_cached_blocks;
			else
				range_int = range - range;
				
		end
		else if(flag == 1 && state == 3 && range > 0)
		begin
			//fetching next line and extarcting the useful blocks
			cache_line_no = rd_address + 1;
			
			//no_cached_blocks_int = 8 - block_offset;
			
			//checking if the no of useful blocks >==< range
			if(range > 128)
				no_cached_blocks = 128;
			else
				no_cached_blocks = range;
				
			//updating the upcounter according to no of useful cached blocks
			if(range > 128)
				up_counter_int = up_counter + 128;
			else
				up_counter_int = up_counter + range;
			
			//updating the range according to no of useful cached blocks
			if(range > 128)
				range_int = range - 128;
			else
				range_int = range - range;
				
		end
		else if(flag == 2 && state == 3 && range > 0)
		begin
			//fetching next line and extarcting the useful blocks
			cache_line_no = rd_address + 1;
			
			//checking if the no of useful blocks >==< range
			if(range > 128)
				no_cached_blocks = 128;
			else
				no_cached_blocks = range;
				
			//updating the upcounter according to no of useful cached blocks
			if(range > 128)
				up_counter_int = up_counter + 128;
			else
				up_counter_int = up_counter + range;
			
			//updating the range according to no of useful cached blocks
			if(range > 128)
				range_int = range - 128;
			else
				range_int = range - range;
				
		end
		else
		begin
			no_cached_blocks = 7'bz;
			up_counter_int = 24'bz;
			range_int = 24'bz;
		end
	end
	
	always@(*)
	begin
		
		//reading bus into cache
		// lot 1
		cache[127] = rd_bus[mem0:0];
		cache[126] = rd_bus[mem1:mem1_e];
		cache[125] = rd_bus[mem2:mem2_e];
		cache[124] = rd_bus[mem3:mem3_e];
		cache[123] = rd_bus[mem4:mem4_e];
		cache[122] = rd_bus[mem5:mem5_e];
		cache[121] = rd_bus[mem6:mem6_e];
		cache[120] = rd_bus[mem7:mem7_e];
		cache[119] = rd_bus[mem8:mem8_e]; 
		cache[118] = rd_bus[mem9:mem9_e];
		cache[117] = rd_bus[mem10:mem10_e];
		cache[116] = rd_bus[mem11:mem11_e];
		cache[115] = rd_bus[mem12:mem12_e];
		cache[114] = rd_bus[mem13:mem13_e];
		cache[113] = rd_bus[mem14:mem14_e];
		cache[112] = rd_bus[mem15:mem15_e];
		
		// lot 2
		cache[111] = rd_bus[mem16:mem16_e];
		cache[110] = rd_bus[mem17:mem17_e];
		cache[109] = rd_bus[mem18:mem18_e];
		cache[108] = rd_bus[mem19:mem19_e];
		cache[107] = rd_bus[mem20:mem20_e];
		cache[106] = rd_bus[mem21:mem21_e];
		cache[105] = rd_bus[mem22:mem22_e];
		cache[104] = rd_bus[mem23:mem23_e];
		cache[103] = rd_bus[mem24:mem24_e]; 
		cache[102] = rd_bus[mem25:mem25_e];
		cache[101] = rd_bus[mem26:mem26_e];
		cache[100] = rd_bus[mem27:mem27_e];
		cache[99] = rd_bus[mem28:mem28_e];
		cache[98] = rd_bus[mem29:mem29_e];
		cache[97] = rd_bus[mem30:mem30_e];
		cache[96] = rd_bus[mem31:mem31_e];
		
		// lot 3
		cache[95] = rd_bus[mem32:mem32_e];
		cache[94] = rd_bus[mem33:mem33_e];
		cache[93] = rd_bus[mem34:mem34_e];
		cache[92] = rd_bus[mem35:mem35_e];
		cache[91] = rd_bus[mem36:mem36_e];
		cache[90] = rd_bus[mem37:mem37_e];
		cache[89] = rd_bus[mem38:mem38_e];
		cache[88] = rd_bus[mem39:mem39_e];
		cache[87] = rd_bus[mem40:mem40_e]; 
		cache[86] = rd_bus[mem41:mem41_e];
		cache[85] = rd_bus[mem42:mem42_e];
		cache[84] = rd_bus[mem43:mem43_e];
		cache[83] = rd_bus[mem44:mem44_e];
		cache[82] = rd_bus[mem45:mem45_e];
		cache[81] = rd_bus[mem46:mem46_e];
		cache[80] = rd_bus[mem47:mem47_e];
		
		// lot 4
		cache[79] = rd_bus[mem48:mem48_e];
		cache[78] = rd_bus[mem49:mem49_e];
		cache[77] = rd_bus[mem50:mem50_e];
		cache[76] = rd_bus[mem51:mem51_e];
		cache[75] = rd_bus[mem52:mem52_e];
		cache[74] = rd_bus[mem53:mem53_e];
		cache[73] = rd_bus[mem54:mem54_e];
		cache[72] = rd_bus[mem55:mem55_e];
		cache[71] = rd_bus[mem56:mem56_e]; 
		cache[70] = rd_bus[mem57:mem57_e];
		cache[69] = rd_bus[mem58:mem58_e];
		cache[68] = rd_bus[mem59:mem59_e];
		cache[67] = rd_bus[mem60:mem60_e];
		cache[66] = rd_bus[mem61:mem61_e];
		cache[65] = rd_bus[mem62:mem62_e];
		cache[64] = rd_bus[mem63:mem63_e];
		
		// lot 5
		cache[63] = rd_bus[mem64:mem64_e];
		cache[62] = rd_bus[mem65:mem65_e];
		cache[61] = rd_bus[mem66:mem66_e];
		cache[60] = rd_bus[mem67:mem67_e];
		cache[59] = rd_bus[mem68:mem68_e];
		cache[58] = rd_bus[mem69:mem69_e];
		cache[57] = rd_bus[mem70:mem70_e];
		cache[56] = rd_bus[mem71:mem71_e];
		cache[55] = rd_bus[mem72:mem72_e]; 
		cache[54] = rd_bus[mem73:mem73_e];
		cache[53] = rd_bus[mem74:mem74_e];
		cache[52] = rd_bus[mem75:mem75_e];
		cache[51] = rd_bus[mem76:mem76_e];
		cache[50] = rd_bus[mem77:mem77_e];
		cache[49] = rd_bus[mem78:mem78_e];
		cache[48] = rd_bus[mem79:mem79_e];
		
		// lot 6
		cache[47] = rd_bus[mem80:mem80_e];
		cache[46] = rd_bus[mem81:mem81_e];
		cache[45] = rd_bus[mem82:mem82_e];
		cache[44] = rd_bus[mem83:mem83_e];
		cache[43] = rd_bus[mem84:mem84_e];
		cache[42] = rd_bus[mem85:mem85_e];
		cache[41] = rd_bus[mem86:mem86_e];
		cache[40] = rd_bus[mem87:mem87_e];
		cache[39] = rd_bus[mem88:mem88_e]; 
		cache[38] = rd_bus[mem89:mem89_e];
		cache[37] = rd_bus[mem90:mem90_e];
		cache[36] = rd_bus[mem91:mem91_e];
		cache[35] = rd_bus[mem92:mem92_e];
		cache[34] = rd_bus[mem93:mem93_e];
		cache[33] = rd_bus[mem94:mem94_e];
		cache[32] = rd_bus[mem95:mem95_e];
		
		// lot 7
		cache[31] = rd_bus[mem96:mem96_e];
		cache[30] = rd_bus[mem97:mem97_e];
		cache[29] = rd_bus[mem98:mem98_e];
		cache[28] = rd_bus[mem99:mem99_e];
		cache[27] = rd_bus[mem100:mem100_e];
		cache[26] = rd_bus[mem101:mem101_e];
		cache[25] = rd_bus[mem102:mem102_e];
		cache[24] = rd_bus[mem103:mem103_e];
		cache[23] = rd_bus[mem104:mem104_e]; 
		cache[22] = rd_bus[mem105:mem105_e];
		cache[21] = rd_bus[mem106:mem106_e];
		cache[20] = rd_bus[mem107:mem107_e];
		cache[19] = rd_bus[mem108:mem108_e];
		cache[18] = rd_bus[mem109:mem109_e];
		cache[17] = rd_bus[mem110:mem110_e];
		cache[16] = rd_bus[mem111:mem111_e];
		
		// lot 8
		cache[15] = rd_bus[mem112:mem112_e];
		cache[14] = rd_bus[mem113:mem113_e];
		cache[13] = rd_bus[mem114:mem114_e];
		cache[12] = rd_bus[mem115:mem115_e];
		cache[11] = rd_bus[mem116:mem116_e];
		cache[10] = rd_bus[mem117:mem117_e];
		cache[9] = rd_bus[mem118:mem118_e];
		cache[8] = rd_bus[mem119:mem119_e];
		cache[7] = rd_bus[mem120:mem120_e]; 
		cache[6] = rd_bus[mem121:mem121_e];
		cache[5] = rd_bus[mem122:mem122_e];
		cache[4] = rd_bus[mem123:mem123_e];
		cache[3] = rd_bus[mem124:mem124_e];
		cache[2] = rd_bus[mem125:mem125_e];
		cache[1] = rd_bus[mem126:mem126_e];
		cache[0] = rd_bus[mem127:mem127_e];
		
		// target states
		// lot 1
		block_mem_state_info_target_state[0] = cache[0][23:0];
		block_mem_state_info_target_state[1] = cache[1][23:0];
		block_mem_state_info_target_state[2] = cache[2][23:0];
		block_mem_state_info_target_state[3] = cache[3][23:0];
		block_mem_state_info_target_state[4] = cache[4][23:0];
		block_mem_state_info_target_state[5] = cache[5][23:0];
		block_mem_state_info_target_state[6] = cache[6][23:0];
		block_mem_state_info_target_state[7] = cache[7][23:0];
		block_mem_state_info_target_state[8] = cache[8][23:0];
		block_mem_state_info_target_state[9] = cache[9][23:0];
		block_mem_state_info_target_state[10] = cache[10][23:0];
		block_mem_state_info_target_state[11] = cache[11][23:0];
		block_mem_state_info_target_state[12] = cache[12][23:0];
		block_mem_state_info_target_state[13] = cache[13][23:0];
		block_mem_state_info_target_state[14] = cache[14][23:0];
		block_mem_state_info_target_state[15] = cache[15][23:0];
		
		// lot 2
		block_mem_state_info_target_state[16] = cache[16][23:0];
		block_mem_state_info_target_state[17] = cache[17][23:0];
		block_mem_state_info_target_state[18] = cache[18][23:0];
		block_mem_state_info_target_state[19] = cache[19][23:0];
		block_mem_state_info_target_state[20] = cache[20][23:0];
		block_mem_state_info_target_state[21] = cache[21][23:0];
		block_mem_state_info_target_state[22] = cache[22][23:0];
		block_mem_state_info_target_state[23] = cache[23][23:0];
		block_mem_state_info_target_state[24] = cache[24][23:0];
		block_mem_state_info_target_state[25] = cache[25][23:0];
		block_mem_state_info_target_state[26] = cache[26][23:0];
		block_mem_state_info_target_state[27] = cache[27][23:0];
		block_mem_state_info_target_state[28] = cache[28][23:0];
		block_mem_state_info_target_state[29] = cache[29][23:0];
		block_mem_state_info_target_state[30] = cache[30][23:0];
		block_mem_state_info_target_state[31] = cache[31][23:0];
		
		// lot 3
		block_mem_state_info_target_state[32] = cache[32][23:0];
		block_mem_state_info_target_state[33] = cache[33][23:0];
		block_mem_state_info_target_state[34] = cache[34][23:0];
		block_mem_state_info_target_state[35] = cache[35][23:0];
		block_mem_state_info_target_state[36] = cache[36][23:0];
		block_mem_state_info_target_state[37] = cache[37][23:0];
		block_mem_state_info_target_state[38] = cache[38][23:0];
		block_mem_state_info_target_state[39] = cache[39][23:0];
		block_mem_state_info_target_state[40] = cache[40][23:0];
		block_mem_state_info_target_state[41] = cache[41][23:0];
		block_mem_state_info_target_state[42] = cache[42][23:0];
		block_mem_state_info_target_state[43] = cache[43][23:0];
		block_mem_state_info_target_state[44] = cache[44][23:0];
		block_mem_state_info_target_state[45] = cache[45][23:0];
		block_mem_state_info_target_state[46] = cache[46][23:0];
		block_mem_state_info_target_state[47] = cache[47][23:0];
		
		// lot 4
		block_mem_state_info_target_state[48] = cache[48][23:0];
		block_mem_state_info_target_state[49] = cache[49][23:0];
		block_mem_state_info_target_state[50] = cache[50][23:0];
		block_mem_state_info_target_state[51] = cache[51][23:0];
		block_mem_state_info_target_state[52] = cache[52][23:0];
		block_mem_state_info_target_state[53] = cache[53][23:0];
		block_mem_state_info_target_state[54] = cache[54][23:0];
		block_mem_state_info_target_state[55] = cache[55][23:0];
		block_mem_state_info_target_state[56] = cache[56][23:0];
		block_mem_state_info_target_state[57] = cache[57][23:0];
		block_mem_state_info_target_state[58] = cache[58][23:0];
		block_mem_state_info_target_state[59] = cache[59][23:0];
		block_mem_state_info_target_state[60] = cache[60][23:0];
		block_mem_state_info_target_state[61] = cache[61][23:0];
		block_mem_state_info_target_state[62] = cache[62][23:0];
		block_mem_state_info_target_state[63] = cache[63][23:0];
		
		// lot 5
		block_mem_state_info_target_state[64] = cache[64][23:0];
		block_mem_state_info_target_state[65] = cache[65][23:0];
		block_mem_state_info_target_state[66] = cache[66][23:0];
		block_mem_state_info_target_state[67] = cache[67][23:0];
		block_mem_state_info_target_state[68] = cache[68][23:0];
		block_mem_state_info_target_state[69] = cache[69][23:0];
		block_mem_state_info_target_state[70] = cache[70][23:0];
		block_mem_state_info_target_state[71] = cache[71][23:0];
		block_mem_state_info_target_state[72] = cache[72][23:0];
		block_mem_state_info_target_state[73] = cache[73][23:0];
		block_mem_state_info_target_state[74] = cache[74][23:0];
		block_mem_state_info_target_state[75] = cache[75][23:0];
		block_mem_state_info_target_state[76] = cache[76][23:0];
		block_mem_state_info_target_state[77] = cache[77][23:0];
		block_mem_state_info_target_state[78] = cache[78][23:0];
		block_mem_state_info_target_state[79] = cache[79][23:0];
		
		// lot 6
		block_mem_state_info_target_state[80] = cache[80][23:0];
		block_mem_state_info_target_state[81] = cache[81][23:0];
		block_mem_state_info_target_state[82] = cache[82][23:0];
		block_mem_state_info_target_state[83] = cache[83][23:0];
		block_mem_state_info_target_state[84] = cache[84][23:0];
		block_mem_state_info_target_state[85] = cache[85][23:0];
		block_mem_state_info_target_state[86] = cache[86][23:0];
		block_mem_state_info_target_state[87] = cache[87][23:0];
		block_mem_state_info_target_state[88] = cache[88][23:0];
		block_mem_state_info_target_state[89] = cache[89][23:0];
		block_mem_state_info_target_state[90] = cache[90][23:0];
		block_mem_state_info_target_state[91] = cache[91][23:0];
		block_mem_state_info_target_state[92] = cache[92][23:0];
		block_mem_state_info_target_state[93] = cache[93][23:0];
		block_mem_state_info_target_state[94] = cache[94][23:0];
		block_mem_state_info_target_state[95] = cache[95][23:0];
		
		// lot 7
		block_mem_state_info_target_state[96] = cache[96][23:0];
		block_mem_state_info_target_state[97] = cache[97][23:0];
		block_mem_state_info_target_state[98] = cache[98][23:0];
		block_mem_state_info_target_state[99] = cache[99][23:0];
		block_mem_state_info_target_state[100] = cache[100][23:0];
		block_mem_state_info_target_state[101] = cache[101][23:0];
		block_mem_state_info_target_state[102] = cache[102][23:0];
		block_mem_state_info_target_state[103] = cache[103][23:0];
		block_mem_state_info_target_state[104] = cache[104][23:0];
		block_mem_state_info_target_state[105] = cache[105][23:0];
		block_mem_state_info_target_state[106] = cache[106][23:0];
		block_mem_state_info_target_state[107] = cache[107][23:0];
		block_mem_state_info_target_state[108] = cache[108][23:0];
		block_mem_state_info_target_state[109] = cache[109][23:0];
		block_mem_state_info_target_state[110] = cache[110][23:0];
		block_mem_state_info_target_state[111] = cache[111][23:0];
		
		// lot 8
		block_mem_state_info_target_state[112] = cache[112][23:0];
		block_mem_state_info_target_state[113] = cache[113][23:0];
		block_mem_state_info_target_state[114] = cache[114][23:0];
		block_mem_state_info_target_state[115] = cache[115][23:0];
		block_mem_state_info_target_state[116] = cache[116][23:0];
		block_mem_state_info_target_state[117] = cache[117][23:0];
		block_mem_state_info_target_state[118] = cache[118][23:0];
		block_mem_state_info_target_state[119] = cache[119][23:0];
		block_mem_state_info_target_state[120] = cache[120][23:0];
		block_mem_state_info_target_state[121] = cache[121][23:0];
		block_mem_state_info_target_state[122] = cache[122][23:0];
		block_mem_state_info_target_state[123] = cache[123][23:0];
		block_mem_state_info_target_state[124] = cache[124][23:0];
		block_mem_state_info_target_state[125] = cache[125][23:0];
		block_mem_state_info_target_state[126] = cache[126][23:0];
		block_mem_state_info_target_state[127] = cache[127][23:0];
		
		
		//transitions
		// lot 1
		block_mem_state_info_transition[0] = cache[0][31:24];
		block_mem_state_info_transition[1] = cache[1][31:24];
		block_mem_state_info_transition[2] = cache[2][31:24];
		block_mem_state_info_transition[3] = cache[3][31:24];
		block_mem_state_info_transition[4] = cache[4][31:24];
		block_mem_state_info_transition[5] = cache[5][31:24];
		block_mem_state_info_transition[6] = cache[6][31:24];
		block_mem_state_info_transition[7] = cache[7][31:24];
		block_mem_state_info_transition[8] = cache[8][31:24];
		block_mem_state_info_transition[9] = cache[9][31:24];
		block_mem_state_info_transition[10] = cache[10][31:24];
		block_mem_state_info_transition[11] = cache[11][31:24];
		block_mem_state_info_transition[12] = cache[12][31:24];
		block_mem_state_info_transition[13] = cache[13][31:24];
		block_mem_state_info_transition[14] = cache[14][31:24];
		block_mem_state_info_transition[15] = cache[15][31:24];
		
		// lot 2
		block_mem_state_info_transition[16] = cache[16][31:24];
		block_mem_state_info_transition[17] = cache[17][31:24];
		block_mem_state_info_transition[18] = cache[18][31:24];
		block_mem_state_info_transition[19] = cache[19][31:24];
		block_mem_state_info_transition[20] = cache[20][31:24];
		block_mem_state_info_transition[21] = cache[21][31:24];
		block_mem_state_info_transition[22] = cache[22][31:24];
		block_mem_state_info_transition[23] = cache[23][31:24];
		block_mem_state_info_transition[24] = cache[24][31:24];
		block_mem_state_info_transition[25] = cache[25][31:24];
		block_mem_state_info_transition[26] = cache[26][31:24];
		block_mem_state_info_transition[27] = cache[27][31:24];
		block_mem_state_info_transition[28] = cache[28][31:24];
		block_mem_state_info_transition[29] = cache[29][31:24];
		block_mem_state_info_transition[30] = cache[30][31:24];
		block_mem_state_info_transition[31] = cache[31][31:24];
		
		// lot 3
		block_mem_state_info_transition[32] = cache[32][31:24];
		block_mem_state_info_transition[33] = cache[33][31:24];
		block_mem_state_info_transition[34] = cache[34][31:24];
		block_mem_state_info_transition[35] = cache[35][31:24];
		block_mem_state_info_transition[36] = cache[36][31:24];
		block_mem_state_info_transition[37] = cache[37][31:24];
		block_mem_state_info_transition[38] = cache[38][31:24];
		block_mem_state_info_transition[39] = cache[39][31:24];
		block_mem_state_info_transition[40] = cache[40][31:24];
		block_mem_state_info_transition[41] = cache[41][31:24];
		block_mem_state_info_transition[42] = cache[42][31:24];
		block_mem_state_info_transition[43] = cache[43][31:24];
		block_mem_state_info_transition[44] = cache[44][31:24];
		block_mem_state_info_transition[45] = cache[45][31:24];
		block_mem_state_info_transition[46] = cache[46][31:24];
		block_mem_state_info_transition[47] = cache[47][31:24];
		
		// lot 4
		block_mem_state_info_transition[48] = cache[48][31:24];
		block_mem_state_info_transition[49] = cache[49][31:24];
		block_mem_state_info_transition[50] = cache[50][31:24];
		block_mem_state_info_transition[51] = cache[51][31:24];
		block_mem_state_info_transition[52] = cache[52][31:24];
		block_mem_state_info_transition[53] = cache[53][31:24];
		block_mem_state_info_transition[54] = cache[54][31:24];
		block_mem_state_info_transition[55] = cache[55][31:24];
		block_mem_state_info_transition[56] = cache[56][31:24];
		block_mem_state_info_transition[57] = cache[57][31:24];
		block_mem_state_info_transition[58] = cache[58][31:24];
		block_mem_state_info_transition[59] = cache[59][31:24];
		block_mem_state_info_transition[60] = cache[60][31:24];
		block_mem_state_info_transition[61] = cache[61][31:24];
		block_mem_state_info_transition[62] = cache[62][31:24];
		block_mem_state_info_transition[63] = cache[63][31:24];
		
		// lot 5
		block_mem_state_info_transition[64] = cache[64][31:24];
		block_mem_state_info_transition[65] = cache[65][31:24];
		block_mem_state_info_transition[66] = cache[66][31:24];
		block_mem_state_info_transition[67] = cache[67][31:24];
		block_mem_state_info_transition[68] = cache[68][31:24];
		block_mem_state_info_transition[69] = cache[69][31:24];
		block_mem_state_info_transition[70] = cache[70][31:24];
		block_mem_state_info_transition[71] = cache[71][31:24];
		block_mem_state_info_transition[72] = cache[72][31:24];
		block_mem_state_info_transition[73] = cache[73][31:24];
		block_mem_state_info_transition[74] = cache[74][31:24];
		block_mem_state_info_transition[75] = cache[75][31:24];
		block_mem_state_info_transition[76] = cache[76][31:24];
		block_mem_state_info_transition[77] = cache[77][31:24];
		block_mem_state_info_transition[78] = cache[78][31:24];
		block_mem_state_info_transition[79] = cache[79][31:24];
		
		// lot 6
		block_mem_state_info_transition[80] = cache[80][31:24];
		block_mem_state_info_transition[81] = cache[81][31:24];
		block_mem_state_info_transition[82] = cache[82][31:24];
		block_mem_state_info_transition[83] = cache[83][31:24];
		block_mem_state_info_transition[84] = cache[84][31:24];
		block_mem_state_info_transition[85] = cache[85][31:24];
		block_mem_state_info_transition[86] = cache[86][31:24];
		block_mem_state_info_transition[87] = cache[87][31:24];
		block_mem_state_info_transition[88] = cache[88][31:24];
		block_mem_state_info_transition[89] = cache[89][31:24];
		block_mem_state_info_transition[90] = cache[90][31:24];
		block_mem_state_info_transition[91] = cache[91][31:24];
		block_mem_state_info_transition[92] = cache[92][31:24];
		block_mem_state_info_transition[93] = cache[93][31:24];
		block_mem_state_info_transition[94] = cache[94][31:24];
		block_mem_state_info_transition[95] = cache[95][31:24];
		
		// lot 7
		block_mem_state_info_transition[96] = cache[96][31:24];
		block_mem_state_info_transition[97] = cache[97][31:24];
		block_mem_state_info_transition[98] = cache[98][31:24];
		block_mem_state_info_transition[99] = cache[99][31:24];
		block_mem_state_info_transition[100] = cache[100][31:24];
		block_mem_state_info_transition[101] = cache[101][31:24];
		block_mem_state_info_transition[102] = cache[102][31:24];
		block_mem_state_info_transition[103] = cache[103][31:24];
		block_mem_state_info_transition[104] = cache[104][31:24];
		block_mem_state_info_transition[105] = cache[105][31:24];
		block_mem_state_info_transition[106] = cache[106][31:24];
		block_mem_state_info_transition[107] = cache[107][31:24];
		block_mem_state_info_transition[108] = cache[108][31:24];
		block_mem_state_info_transition[109] = cache[109][31:24];
		block_mem_state_info_transition[110] = cache[110][31:24];
		block_mem_state_info_transition[111] = cache[111][31:24];
		
		// lot 8
		block_mem_state_info_transition[112] = cache[112][31:24];
		block_mem_state_info_transition[113] = cache[113][31:24];
		block_mem_state_info_transition[114] = cache[114][31:24];
		block_mem_state_info_transition[115] = cache[115][31:24];
		block_mem_state_info_transition[116] = cache[116][31:24];
		block_mem_state_info_transition[117] = cache[117][31:24];
		block_mem_state_info_transition[118] = cache[118][31:24];
		block_mem_state_info_transition[119] = cache[119][31:24];
		block_mem_state_info_transition[120] = cache[120][31:24];
		block_mem_state_info_transition[121] = cache[121][31:24];
		block_mem_state_info_transition[122] = cache[122][31:24];
		block_mem_state_info_transition[123] = cache[123][31:24];
		block_mem_state_info_transition[124] = cache[124][31:24];
		block_mem_state_info_transition[125] = cache[125][31:24];
		block_mem_state_info_transition[126] = cache[126][31:24];
		block_mem_state_info_transition[127] = cache[127][31:24];
	
	end
	
	//assign offset =  size + 1;
endmodule