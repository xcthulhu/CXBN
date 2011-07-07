library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.common_decs.all;

package intercon_decs is
  constant topb  : integer := 11;
  constant botb  : integer := 6;
  
  -- Addressing
  subtype idaddr is std_logic_vector(topb downto botb);
  constant priority_addr          : idaddr  := "000000";
  constant magnetometers_addr     : idaddr  := "000001";
  constant conopus_addr           : idaddr  := "000010";
  constant sun_addr               : idaddr  := "000011";
  constant magtorquer_addr        : idaddr  := "000100";
  constant gyros_addr             : idaddr  := "000101";
  constant czt_add                : idaddr  := "000110";

  -- Checks the wishbone bus to see if an address is selected
  function is_slctd (my_wbw : wbws; addr : idaddr) return boolean;
end package;

package body intercon_decs is
  function is_slctd (my_wbw : wbws; addr : idaddr) return boolean is
  begin return(my_wbw.c.address(topb downto botb) = addr); end;
end package body;
