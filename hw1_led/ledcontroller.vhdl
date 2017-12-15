library IEEE;
use IEEE.std_logic_misc.all;
use IEEE.std_logic_1164.all;

entity ledcontroller is

port (
   switches : in std_logic_vector (17 downto 0);
   segments : out std_logic_vector (0 to 55);
	Key0 : in std_logic
);
end entity;



architecture basic of ledcontroller is


component f_bits port(
  W : in std_logic_vector (3 downto 0);
  F : out std_logic_vector (6 downto 0);
  K : in std_logic
);
end component;



component two_bits port(
  W : in std_logic_vector (1 downto 0);
  F : out std_logic_vector (6 downto 0);
  K : in std_logic
 );
end component;




begin 

start: for i in 3 downto 0 generate
  f_bits_i : f_bits port map (
    K => Key0,
    W => (switches((i*4 + 3) downto (i*4))),
    F => segments((i*7) to (i*7+6))
  ); 

end generate start;

two_bits_0 : two_bits port map (
  K => Key0,
  W => switches(17 downto 16),
  F => segments((4*7) to (4*7 + 6))
);


end basic;
