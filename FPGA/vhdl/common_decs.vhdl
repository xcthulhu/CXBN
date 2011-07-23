library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package common_decs is
  -- Different synonyms we use for data channels
  constant chan_size : natural := 16;
  subtype chan is std_logic_vector(chan_size-1 downto 0);
  subtype device_id is chan;
  subtype read_chan is chan;
  subtype write_chan is chan;
  subtype imx_chan is chan;

  -- Address channel
  -- From armadeus documentation:
  ---- http://www.armadeus.com/wiki/index.php?title=APF27_FPGA-IMX_interface_description
  ---- "ADDR[12]: 12 bits address bus, least significant bit (ADDR[0]) is not used because only word access are done."
  constant addr_size : natural := 12;
  subtype addr is std_logic_vector(addr_size-1 downto 0);  

  -- A "Character" is just a byte
  constant char_size : natural := 8;
  subtype char is std_logic_vector(char_size-1 downto 0);

  -- Wishbone Interface Signals
  type wbrs is                          -- Wishbone read system
  record
    readdata : read_chan;               -- Data bus read by wishbone
    ack      : std_logic;               -- Acknowledge
  end record;

  ---- Common part of the wishbone write system
  type wbws_common is
  record
    strobe    : std_logic;              -- Data Strobe
    writing   : std_logic;              -- Busy writing
    address   : addr;                   -- Address bus
    writedata : write_chan;             -- Data bus written by wishbone    
  end record;

  type wbws is                          -- Wishbone write system
  record
    c     : wbws_common;
    cycle : std_logic;                  -- Bus cycle in progress
  end record;

  -- Empty bus signals
  constant null_wbr : wbrs := (readdata => (others => '0'), ack => '0');
  constant null_wbw : wbws := (cycle => '0',
                               c => (address => (others => '0'),
                                     writedata => (others => '0'),
                                     strobe => '0',
                                     writing => '0'));

  
  -- Create wishbone bus signals
  function write_wbr (rdata : read_chan) return wbrs;
  function write_wbw (addrs : addr; wdata : write_chan) return wbws;
  function read_wbw (addrs : addr) return wbws;

  -- Access protocols for wishbone slave
  ---- Checks if the master is reading 
  function master_is_reading(wbw : wbws) return boolean;
  ---- Checks if the master is writing
  function master_is_writing(wbw : wbws) return boolean;

  -- IMX signals are very similar to Wishbone
  type imx_in is
  record
    address : addr;                     -- LSB not used 
    cs_n    : std_logic;
    oe_n    : std_logic;
    eb3_n   : std_logic;
  end record;
  
end package;

package body common_decs is

  function write_wbr (rdata : read_chan) return wbrs is
  begin return (readdata => rdata, ack => '1');
  end;

  function write_wbw (addrs : addr; wdata : write_chan) return wbws is
  begin return (cycle => '1',
                c => (address => addrs,
                      writedata => wdata,
                      strobe => '1',
                      writing => '1'));
  end;

  function read_wbw (addrs : addr) return wbws is
  begin return (cycle => '1',
                c => (address => addrs,
                      writedata => (others => '0'),
                      strobe => '1',
                      writing => '0'));
  end;

  function master_is_reading(wbw : wbws) return boolean is
  begin return (wbw.c.strobe = '1' and wbw.cycle = '1' and wbw.c.writing = '0');
  end;

  function master_is_writing(wbw : wbws) return boolean is
  begin return (wbw.c.strobe = '1' and wbw.cycle = '1' and wbw.c.writing = '1');
  end;

end package body common_decs;
