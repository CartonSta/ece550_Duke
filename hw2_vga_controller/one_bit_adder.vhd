--ONE BIT ADDER

library ieee,work;
use ieee.std_logic_1164.all;
use work.all;

entity one_bit_adder is 
port (
	cin	: in std_logic; 	-- carry in
	b1	: in std_logic;		-- bit one
	b2	: in std_logic; 	-- bit two
	sum	: out std_logic;	-- sum
	cout	: out std_logic	-- carry out
);
end entity;

architecture arch of one_bit_adder is

begin 
	sum <= b1 xor b2 xor cin;
	cout <= (b1 and b2) or (b2 and cin) or (b1 and cin);
end arch;
	