LIBRARY ieee;
USE ieee.std_logic_1164.all;

-- Control logic for the Duke 550 processor
-- Author: Zhiyao~

ENTITY control IS
	PORT (	op	: IN STD_LOGIC_VECTOR(4 DOWNTO 0);	-- instruction opcode
				bTD : OUT STD_LOGIC;
				wren : OUT STD_LOGIC;
				ALUinB : OUT STD_LOGIC;
				DMwe	:	OUT STD_LOGIC;
				Rwd	:	OUT STD_LOGIC;
				BR	: OUT STD_LOGIC;
				JP	: OUT STD_LOGIC;
				input_ack : OUT STD_LOGIC;
				out_en  :	OUT STD_LOGIC);
END control;


ARCHITECTURE Behavior OF control IS

	signal sOp : STD_LOGIC_VECTOR(3 DOWNTO 0);
	
BEGIN
	-- TODO: implement behavior of control unit
	-- NOTE: Behavioral WHEN... ELSE statements may be used
	
	sOp <= op (3 downto 0);
	
	-- read rd as rt into ValB
	bTD <= '1' when (sOp = "1001" or sOp = "1010") else -- beq, blt, 
		    '1' when (sOp = "1000" or sOp = "1011" or sOp = "1111") else --sw, jr, output
		    '0'; -- others
	
	-- write to rd
	wren <= '1' when (op(4 downto 3) = "00") else	-- add, addi, lw
			  '1' when (sOp = "1101" or sOp = "1110") else	-- jal, input
			  '0'; -- others
			 
				 
	-- uses extend_i than rt 		 
	ALUinB <= '1' when (sOp = "0110" or sOp = "1000" or sOp = "0111")	else --addi, sw, lw			 
				 '0';
				 				  
	
	DMwe <= '1' when (sOp = "1000") else -- sw
			  '0'; -- add, addi, lw, beq, bgt
	
	
	-- write from mem
	Rwd <= '1' when (sOp = "0111") else	--lw
			  '0'; -- add, addi, input
	
	BR	<= '1' when (sOp = "1001" or sOp = "1010") else --beq, bgt
			'0';
	
	JP <= '1' when (sOp = "1100" or sOp = "1101") else --j, jal
			'0';

	input_ack <= '1' when (sOp = "1110") else	--input
					 '0';
	
	out_en <= '1' when (sOp = "1111") else --output
				 '0';
	
END Behavior;