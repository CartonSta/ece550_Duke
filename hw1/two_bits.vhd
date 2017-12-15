library IEEE;
use IEEE.std_logic_misc.all;
use IEEE.std_logic_1164.all;

entity two_bits is
port(

  W : in std_logic_vector (1 downto 0);
  F : out std_logic_vector (6 downto 0);
  K : in std_logic
 );
end two_bits;

architecture arch of two_bits is

signal M: std_logic_vector(1 downto 0);

begin

with K select
M <= 
  W when '1',
  not(W) when '0';

with M select
 F<= 
 "0000001" when "00",
 "1001111" when "01",
 "0010010" when "10",
 "0000110" when "11";
 
end arch;
