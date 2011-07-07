library ieee;
use ieee.std_logic_1164.all;
use work.common_decs.all;
use work.charc_decs.all;

--Converts a character to STD_LOGIC array
entity charci is
  port(
    char_in   : in char;
    logic_out : out std_logic_vector (B-1 downto 0)
    );
end;

architecture arc of charci is
begin
  logic_out <= char_in;
end architecture;
