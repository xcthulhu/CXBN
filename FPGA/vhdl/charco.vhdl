library ieee;
use ieee.std_logic_1164.all;
use work.common_decs.all;
use work.charc_decs.all;

---- Converts a STD_LOGIC array to a character
entity charco is
  port(
    char_out : out char;
    logic_in : in std_logic_vector (B-1 downto 0)
    );
end;

architecture arc of charco is
begin
  char_out <= logic_in;
end architecture;
