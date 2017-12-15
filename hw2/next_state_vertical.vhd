library IEEE;
use IEEE.std_logic_1164.all;


entity next_state_vertical is port (
		count_in_vertical	: in std_logic_vector	(9 downto 0);
		rst				: in std_logic;
		V_present_state	: in std_logic_vector(3 downto 0);
		V_next_state		: out std_logic_vector(3 downto 0)
		);
end entity;


architecture arch of next_state_vertical is

	constant V_ACTIVE_VIDEO 	: std_logic_vector(3 downto 0)	:= "0001";
	constant V_FRONT_PORCH		: std_logic_vector(3 downto 0) 	:= "0010";
	constant V_SYNC_PULSE 		: std_logic_vector(3 downto 0) 	:= "0100";
	constant V_BACK_PORCH		: std_logic_vector(3 downto 0) 	:= "1000";


begin
	--rst = '1'
	V_next_state <=  V_ACTIVE_VIDEO when (rst = '1' or (count_in_vertical < "0111100000") ) else 
						  V_FRONT_PORCH  when (count_in_vertical > "0111011111" and count_in_vertical < "0111101011") else
						  V_SYNC_PULSE when (count_in_vertical > "0111101010" and count_in_vertical < "0111101101") else
						  V_BACK_PORCH when (count_in_vertical > "0111101100" and count_in_vertical < "1000001100");


end arch;