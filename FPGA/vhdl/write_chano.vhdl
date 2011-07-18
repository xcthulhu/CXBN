library ieee;
use ieee.std_logic_1164.all;
use work.common_decs.all;
use work.write_chanc_decs.all;

--Converts a character to STD_LOGIC array
entity write_chano is
  port(
    write_chan_out   : out write_chan;
    logic_in : in std_logic_vector (A-1 downto 0)
    );
end;

architecture arc of write_chano is
begin
   write_chan_out <= logic_in;
end architecture;
