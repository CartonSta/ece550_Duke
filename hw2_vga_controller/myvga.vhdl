library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;
library altera;
use altera.altera_primitives_components.all;

entity myvga is
port (
    clk     : in std_logic;
    rst     : in std_logic;
    red     : out std_logic_vector (7 downto 0);
    green   : out std_logic_vector (7 downto 0);
    blue    : out std_logic_vector (7 downto 0);
    blank   : out std_logic;
    hsync   : out std_logic;
    vsync   : out std_logic);
end myvga;


architecture basic of myvga is

component vmem is
	port (
		address		: in std_logic_vector  (15 downto 0);
		clock		: in std_logic;
		q		    : out std_logic_vector (8 downto 0));
end component;


component next_state_logic is port (
	count_in_row	: in std_logic_vector	(9 downto 0);
	rst	: in std_logic;
	present_state	: in std_logic_vector(3 downto 0);
	next_state		: out std_logic_vector(3 downto 0));
end component;


component next_state_vertical is port (
	count_in_vertical	: in std_logic_vector	(9 downto 0);
	rst	: in std_logic;
	V_present_state	: in std_logic_vector(3 downto 0);
	V_next_state		: out std_logic_vector(3 downto 0));
end component;


component ten_bit_adder is port (
	cin	: in std_logic;
	b1	: in std_logic_vector (9 downto 0);
	b2	: in std_logic_vector (9 downto 0);
	sum : out std_logic_vector (10 downto 0));
end component;


component twenty_bit_adder is port (
	cin	: in std_logic;
	b1	: in std_logic_vector (19 downto 0);
	b2	: in std_logic_vector (19 downto 0);
	sum : out std_logic_vector (20 downto 0)
	);
end component;







signal countAddress	: std_logic_vector  (18 downto 0) := (others => '0');
signal countAddress_add	: std_logic_vector  (18 downto 0) := (others => '0');
signal countAddress_tmp	: std_logic_vector  (20 downto 0) := (others => '0');


signal inAddress		: std_logic_vector  (15 downto 0);
signal outPixel		: std_logic_vector  (8 downto 0);

signal present_state	: std_logic_vector(3 downto 0)	:= "0001";
signal next_state		: std_logic_vector(3 downto 0)	:= "0001";
signal V_present_state	: std_logic_vector(3 downto 0)	:= "0001";
signal V_next_state		: std_logic_vector(3 downto 0)	:= "0001";

signal rstn: std_logic;


constant ACTIVE_VIDEO 	: std_logic_vector(3 downto 0)	:= "0001";
constant FRONT_PORCH		: std_logic_vector(3 downto 0) 	:= "0010";
constant SYNC_PULSE 		: std_logic_vector(3 downto 0) 	:= "0100";
constant BACK_PORCH		: std_logic_vector(3 downto 0) 	:= "1000";

constant V_ACTIVE_VIDEO 	: std_logic_vector(3 downto 0)	:= "0001";
constant V_FRONT_PORCH		: std_logic_vector(3 downto 0) 	:= "0010";
constant V_SYNC_PULSE 		: std_logic_vector(3 downto 0) 	:= "0100";
constant V_BACK_PORCH		: std_logic_vector(3 downto 0) 	:= "1000";



signal count_in_row	: std_logic_vector	(9 downto 0) := (others => '0');
signal count_in_row_add	: std_logic_vector	(9 downto 0) := (others => '0');
signal count_in_row_tmp	: std_logic_vector	(10 downto 0) := (others => '0');
signal count_in_vertical	: std_logic_vector	(9 downto 0) := (others => '0');
signal count_in_vertical_add	: std_logic_vector	(9 downto 0) := (others => '0');
signal count_in_vertical_tmp	: std_logic_vector	(10 downto 0) := (others => '0');

signal cinZeroConst	:	std_logic := '0';
signal addOneConst	: std_logic_vector	(9 downto 0) := "0000000001";

begin

--- Replace this with your code ---

	
red   <= outPixel(8 downto 6) & "00000";
green <= outPixel(5 downto 3) & "00000"; 
blue  <= outPixel(2 downto 0) & "00000";



--800 columns each row
-- 800
count_in_row_add <= count_in_row_tmp (9 downto 0) when (count_in_row < "1100100000") else
					(others => '0');
				
--524 rows
--799, 524
--524
count_in_vertical_add <= count_in_vertical_tmp (9 downto 0) when (count_in_row = "1100011111" and count_in_vertical < "1000001100") else
						count_in_vertical when (count_in_vertical < "1000001100") else
						(others => '0');


--countAddress_add <= (countAddress_tmp2(8 downto 0) & countAddress_tmp1 (9 downto 0)) when (present_state=ACTIVE_VIDEO) else

countAddress_add <= (countAddress_tmp(18 downto 0)) when (present_state=ACTIVE_VIDEO) else
					countAddress when (V_present_state = V_ACTIVE_VIDEO) else
					(others => '0');
					

blank <= '1' when (present_state = ACTIVE_VIDEO and V_present_state = V_ACTIVE_VIDEO) else
				 '0';

hsync <= '0' when (present_state = SYNC_PULSE) else
				 '1';

vsync <= '0' when (V_present_state = V_SYNC_PULSE) else
				 '1';





inAddress <= countAddress(18 downto 3);
	
	
	

vmem0: vmem port map (
	address => inAddress,
	clock => clk,
	q => outPixel);
	


next_state_logic_inst :  next_state_logic port map(
	count_in_row   => count_in_row,
	rst				=> rst,
	present_state	=> present_state,
	next_state		=> next_state
);
		

next_state_vertical_inst :  next_state_vertical port map(
	count_in_vertical   => count_in_vertical,
	rst				=> rst,
	V_present_state	=> V_present_state,
	V_next_state		=> V_next_state
); 



----adding--
ten_bit_adder_i: ten_bit_adder port map (
	cin => cinZeroConst,
	b1 => count_in_row,
	b2 => addOneConst,
	sum => count_in_row_tmp
);
	
ten_bit_adder_i2: ten_bit_adder port map (
	cin => cinZeroConst,
	b1 => count_in_vertical,
	b2 => addOneConst,
	sum => count_in_vertical_tmp
);



twenty_bit_adder_i2: twenty_bit_adder port map (
	cin => cinZeroConst,
	b1 => "0" & countAddress,
	b2 => "0000000000" & addOneConst,
	sum => countAddress_tmp
);




-----FSM-----

rstn <= not (rst);
FSM: for i in 3 downto 0 generate
	FSM_dff: dff port map (
			clk => clk,
			clrn => rstn,
			prn => '1',
			d => next_state(i),
			q => present_state(i)
	);
end generate FSM;


FSM2: for i in 3 downto 0 generate
	FSM_dff2: dff port map (
			clk => clk,
			clrn => rstn,
			prn => '1',
			d => V_next_state(i),
			q => V_present_state(i)
	);
end generate FSM2;



FSM3: for i in 9 downto 0 generate
	FSM_dff3: dff port map (
			clk => clk,
			clrn => rstn,
			prn => '1',
			d => count_in_row_add(i),
			q => count_in_row(i)
	);
end generate FSM3;


FSM4: for i in 9 downto 0 generate
	FSM_dff4: dff port map (
			clk => clk,
			clrn => rstn,
			prn => '1',
			d => count_in_vertical_add(i),
			q => count_in_vertical(i)
	);
end generate FSM4;


FSM5: for i in 18 downto 0 generate
	FSM_dff5: dff port map (
			clk => clk,
			clrn => rstn,
			prn => '1',
			d => countAddress_add(i),
			q => countAddress(i)
	);
end generate FSM5;


end basic;