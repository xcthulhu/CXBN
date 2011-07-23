library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.common_decs.all;

package intercon_decs is
  -- Addressing
  ---- Address channel broken into two components: 
  ------ (1) the device (top 8 bits)
  ------ (2) the subsystem (bottom 4 bits)
  ------ Note: Because of the restriction above, 
  ------       in practice IT IS IMPOSSIBLE to assign 
  ------       subsystems odd addresses
  constant device_bits    : natural := 8;
  subtype dev_addr is std_logic_vector(device_bits-1 downto 0);
  constant subsystem_bits : natural := 4;
  subtype subsys_addr is std_logic_vector(subsystem_bits-1 downto 0);
  -- Access subroutines
  function dev(address    : addr) return dev_addr;
  function subsys(address : addr) return subsys_addr;

  -- The device addresses of the modules
  -- on the wishbone bus
  constant priority_a : dev_addr := x"AA";
  constant pwmx_a     : dev_addr := x"B1";
  constant pwmy_a     : dev_addr := x"B2";
  constant pwmz_a     : dev_addr := x"B3";
  constant temp_a     : dev_addr := x"10";
  constant suncss_a   : dev_addr := x"C1";
  constant sunmss_a   : dev_addr := x"C2";
  constant sunfss_a   : dev_addr := x"C3";
  constant wbrst_a    : dev_addr := x"FF";
end package;

package body intercon_decs is
  function dev(address : addr) return dev_addr is
  begin return address(addr'length - 1
                       downto (addr'length - dev_addr'length));
  end;

  function subsys(address : addr) return subsys_addr is
  begin return address(subsystem_bits - 1 downto 0);
  end;
end package body;
