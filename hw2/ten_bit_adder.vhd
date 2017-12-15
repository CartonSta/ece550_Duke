--TEN BIT ADDER

library ieee,work;
use ieee.std_logic_1164.all;
use work.all;

entity ten_bit_adder is 
port (
	cin	: in std_logic;
	b1	: in std_logic_vector (9 downto 0);
	b2	: in std_logic_vector (9 downto 0);
	sum : out std_logic_vector (10 downto 0)
	);
end entity;

architecture arch of ten_bit_adder is 

signal carry : std_logic_vector (9 downto 0);

component one_bit_adder port (
	cin : in std_logic;
	b1	: in std_logic;
	b2	: in std_logic;
	sum	: out std_logic;
	cout	: out std_logic
	);
end component;

begin

one_bit_adder_0 : one_bit_adder port map(
	cin	=> cin,
	b1	=> b1(0),
	b2	=> b2(0),
	sum	=> sum(0),
	cout	=> carry(0)
	);
 
add_bits: for i in 1 to 9 generate
	one_bit_adder_i : one_bit_adder port map(
		cin => carry(i-1),
		b1 => b1(i),
		b2 => b2(i),
		sum => sum(i),
		cout => carry(i)
	);
end generate add_bits;

sum(10) <= carry(9);
end arch;
