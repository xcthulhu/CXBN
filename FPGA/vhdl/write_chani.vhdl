library ieee;
use ieee.std_logic_1164.all;
use work.common_decs.all;
use work.write_chanc_decs.all;

--Converts a character to STD_LOGIC array
entity write_chani is
  port(
    write_chan_in   : in write_chan;
    logic_out : out std_logic_vector (A-1 downto 0)
    );
end;

architecture arc of write_chani is
begin
  logic_out <= write_chan_in;
end architecture;
