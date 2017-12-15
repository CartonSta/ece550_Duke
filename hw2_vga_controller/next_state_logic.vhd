 library IEEE;
use IEEE.std_logic_1164.all;


entity next_state_logic is port (
		count_in_row	: in std_logic_vector (9 downto 0);
		rst				: in std_logic;
		present_state	: in std_logic_vector(3 downto 0);
		next_state		: out std_logic_vector(3 downto 0)
		);
end entity;


architecture arch of next_state_logic is

	constant ACTIVE_VIDEO 	: std_logic_vector(3 downto 0)	:= "0001";
	constant FRONT_PORCH		: std_logic_vector(3 downto 0) 	:= "0010";
	constant SYNC_PULSE 		: std_logic_vector(3 downto 0) 	:= "0100";
	constant BACK_PORCH		: std_logic_vector(3 downto 0) 	:= "1000";


begin
	--rst = '1'
	next_state <= 	ACTIVE_VIDEO when (rst = '1' or (count_in_row < "1010000000") ) else --640
						FRONT_PORCH  when (count_in_row > "1001111111" and count_in_row < "1010010000") else --639, 656
						SYNC_PULSE when (count_in_row > "1010001111" and count_in_row < "1011110000") else --655, 752
						BACK_PORCH when (count_in_row > "1011101111" and count_in_row < "1100100000"); --751, 800


end arch;