LIBRARY ieee;
USE ieee.std_logic_1164.all;
library altera;
use altera.altera_primitives_components.all;


-- The core of the Duke 550 processor
-- Author: zhiyao <INSERT YOUR NAME HERE!!!!>

ENTITY processor IS
    PORT (	clock, reset	: IN STD_LOGIC;
			keyboard_in	: IN STD_LOGIC_VECTOR(31 downto 0);
			keyboard_ack, lcd_write	: OUT STD_LOGIC;
			lcd_data	: OUT STD_LOGIC_VECTOR(31 downto 0);
			PCs : OUT STD_LOGIC_VECTOR (0 to 27);
			PCbits : OUT STD_LOGIC_VECTOR (7 downto 0));
END processor;

ARCHITECTURE Structure OF processor IS
	COMPONENT imem IS
		PORT (	address	: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
				clken	: IN STD_LOGIC ;
				clock	: IN STD_LOGIC ;
				q	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0) );
	END COMPONENT;
	
	COMPONENT dmem IS
		PORT (	address	: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
				clock	: IN STD_LOGIC ;
				data	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
				wren	: IN STD_LOGIC ;
				q	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0) );
	END COMPONENT;
	
	COMPONENT regfile IS
		PORT (	clock, wren, clear	: IN STD_LOGIC;
				regD, regA, regB	: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
				valD	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
				valA, valB	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0) );
	END COMPONENT;
	
	COMPONENT alu IS
		PORT (	A, B	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);	-- 32bit inputs
				op	: IN STD_LOGIC_VECTOR(2 DOWNTO 0);	-- 3bit ALU opcode
				R	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);	-- 32bit output
				isEqual : OUT STD_LOGIC; -- true if A=B
				isLessThan	: OUT STD_LOGIC ); -- true if A<B
	END COMPONENT;
	
	COMPONENT control IS
	PORT (	op	: IN STD_LOGIC_VECTOR(4 DOWNTO 0);	-- instruction opcode
			--TODO: Figure out what control signals you need here
				bTD : OUT STD_LOGIC;
				wren: OUT STD_LOGIC;
				ALUinB : OUT STD_LOGIC;
				DMwe	: OUT STD_LOGIC;
				Rwd	: OUT STD_LOGIC;
				BR	: OUT STD_LOGIC;
				JP	: OUT STD_LOGIC;
				input_ack : OUT STD_LOGIC;
				out_en	: OUT STD_LOGIC
			);
	END COMPONENT;
	
	
	--Zhiyao	
	
	COMPONENT mux IS
	GENERIC (n: integer:=16);
	PORT (	A, B	: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
				s	: IN STD_LOGIC;	-- select (NOT A / B)
				F	: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
			);
	END COMPONENT;
	
	component f_bits is
	port(
			W : in std_logic_vector (3 downto 0);
			F : out std_logic_vector (6 downto 0)
		);
	end component;
	
	signal instruction : STD_LOGIC_VECTOR(31 downto 0);
	signal rstn: std_logic;
	signal valA, valB, valD	: STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	signal valB2	: STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	signal R	: STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal dmemOut	: STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal writeBack, writeBack2, writeBack3 : STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	signal bTD, wren, ALUinB, DMwe, Rwd, BR, JP	: STD_LOGIC;
	signal isEqual, isLessThan	: STD_LOGIC;
	
	signal dummy0, dummy1 : STD_LOGIC;
	signal brLogic, jrLogic, jalLogic, input_ack, out_en	: STD_LOGIC;
	
	
	signal twenty_zeros : STD_LOGIC_VECTOR(19 downto 0) := (others => '0');
	signal thirty_one_zeros : STD_LOGIC_VECTOR(30 downto 0) := (others => '0');
	
	signal extend_I : STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	
	signal PC : STD_LOGIC_VECTOR(11 DOWNTO 0) := "111111111111";
	signal PCnext : STD_LOGIC_VECTOR(11 DOWNTO 0) := "000000000000";
	
	
	signal PC3 : STD_LOGIC_VECTOR(11 DOWNTO 0)  := (others => '0');
	signal PC0, PC1, PC2 : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
	
	
	--signal testingPC	: STD_LOGIC_VECTOR(11 DOWNTO 0);
	signal  nextInstruction, constInstruction, c_1_constInstruction, c_3_constInstruction, c_0_constInstruction	: STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	signal regB0, regD0 :	STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
	
	signal alu1A, alu1B : STD_LOGIC_VECTOR(31 DOWNTO 0) ;
	signal mux2s : STD_LOGIC;
	
	signal op1 : STD_LOGIC_VECTOR (2 DOWNTO 0);
	
	signal firstClock  : STD_LOGIC := '0';
	signal notClock	: STD_LOGIC;
	-- TODO: Likely need other components here (register/adder for PC?, muxes for the data path?, etc.) 
	
BEGIN

	
---- FETCH Stage
	
	imem0: imem port map(
		address	=> PCnext,
		clken	=> rstn,	--'1' not sure
		clock	=>	clock,
		q	=>	instruction
	);
	
	
	
	--record the first clock
	fir_clk_dff : dff port map (
			clk => clock,
			clrn => rstn,
			prn => '0',
			d => '1',
			q => firstClock
		);
		
		
	-- bit leds
	PCbits <= PC(7 downto 0);
	
--	PCs <= "00000000000000";
	start: for i in 2 downto 0 generate
	f_bitsi : f_bits port map (
			W => PC(i*4+3 downto i*4),
			F => PCs(i*7 to i*7 + 6)
	);
	end generate start;
	
	f_bits3 : f_bits port map (
			W => "0000",
			F => PCs(3*7 to 3*7 + 6)
	);
---------	
	
	
	rstn <= not (reset);
	PCloop: for i in 11 downto 0 generate
		PC_dff : dff port map (
			clk => clock,
			clrn => rstn,
			prn => firstClock,
			d => PCnext(i),
			q => PC(i)
		);
	end generate PCloop;
	
	
	
---- DECODE Stage
	control0: control port map(
		--resume here
		op => instruction(31 downto 27),
		bTD => bTD,
		wren => wren,
		ALUinB => ALUinB,
		DMwe => DMwe,
		Rwd => Rwd, 
		BR => BR,
		JP => JP,
		input_ack => input_ack,
		out_en => out_en
	);
	
	
---- EXECUTE Stage	
	
-- EXCUTE: Regfile reading
	mux_bTD: mux GENERIC MAP(n=>5) port map (A=>instruction(16 downto 12), B=>instruction(26 downto 22), s=>bTD, F => regB0);

	
	jalLogic	<= '1' when instruction(31 downto 27) = "01101" else --jal
					'0';
					
	mux_jal: mux GENERIC MAP(n=>5) port map (A=>instruction(26 downto 22), B=>"11111", s=>jalLogic, F => regD0);
	
	
	regfile0: regfile port map(	
		clock => clock, wren => wren, clear => reset,
		regD => regD0, --rd or $31, depending in jalLogic
		regA => instruction(21 downto 17),	--rs
		regB => regB0,	--rt/rd, depending on bTD
		valD => valD, valA => valA, valB => valB
	);
	 
	 
-- EXCUTE: major ALU
	--sign extension
	extend_I <= "000000000000000" & instruction(16 downto 0) when (instruction(16) = '0') else
					"111111111111111" & instruction(16 downto 0);
			
	mux0: mux GENERIC MAP(n=>32) port map(A=>valB, B=>extend_I, s=>ALUinB, F=>valB2);

	
	op1 <= "001" when instruction(31 downto 27) = "01010" else  -- bgt
			 "000" when instruction(31 downto 27) = "00110" else  -- addi
			 "000" when instruction(31 downto 27) = "00111" else --lw, sw (000 already)
			  instruction(29 downto 27);
	
	alu0: alu port map(
		A => valA, B => valB2, op => op1,
		R => R, isEqual => isEqual, isLessThan => isLessThan
	);
	

-- EXCUTE: branch, PC to PC2

	alu1A <= twenty_zeros & PC;
	alu1B <= thirty_one_zeros & "1";
	alu1: alu port map(	--PC + 1
		A => alu1A, B => alu1B, op => "000",
		R => PC0, isEqual => dummy0, isLessThan => dummy1
	);
	
	alu2: alu port map(	--PC + immediate
		A => PC0, B => extend_I, op => "000",
		R => PC1, isEqual => dummy0, isLessThan => dummy1
	);	
	
	brLogic <= '1' when instruction(31 downto 27) = "01001" and isEqual = '1'	  else -- beq
				  '1' when instruction(31 downto 27) = "01010" and isLessThan = '1' else -- bgt rs(A) < rd(B)
				  '0';
	
	
	mux2s <= BR and brLogic;
	mux2: mux GENERIC MAP(n=>32) port map(A=>PC0, B=>PC1, s=>mux2s, F=>PC2); -- BR & R


-- EXCUTE: jump, PC2 to PCnext
	
	mux3: mux GENERIC MAP(n=>12) port map(A=>PC2(11 downto 0), B=>instruction(11 downto 0), s=>JP, F=>PC3); -- J, Jal
	jrLogic <= '1' when instruction(31 downto 27) = "01011" else		-- jr
				  '0';
	mux6: mux GENERIC MAP(n=>12) port map(A=>PC3, B=>valB(11 downto 0), s=>JrLogic, F=>PCnext);	--jr
	
	
-- EXCUTE: read keyboard input, out lcd
	keyboard_ack <= input_ack;
	lcd_write <= out_en;
	
	lcd_data <= valB;	-- valB from "regD" ins[26 o 22]

	
---- MEMORY WRITE Stage

	notClock <= not clock;
	dmem0	:	dmem port map(
		address => R(11 downto 0),
		clock => notClock,
		data => valB,	-- write into mem, for sw only, valB from "regD" ins[26 o 22]
		wren => DMwe,
		q => dmemOut	-- read, for lw only
	);
	
	
---- WRITEBACK Stage
	mux1: mux GENERIC MAP(n=>32) port map(A=>R, B=>dmemOut, s=>Rwd, F=>writeBack);	--Rwd '1' only for lw
	mux7: mux GENERIC MAP(n=>32) port map(A=>writeBack, B=>keyboard_in, s=>input_ack, F=>writeBack2); -- input '1'
	
	mux_jal2: mux GENERIC MAP(n=>32) port map (A=>writeBack2, B=>PC0, s=>jalLogic, F => writeBack3); -- jal, $31 = pc+1
	
	valD <= writeBack3;
	
		
END Structure;





