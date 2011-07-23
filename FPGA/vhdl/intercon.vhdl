library IEEE;
use ieee.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;
use work.intercon_decs.all;
use work.common_decs.all;

entity intercon is
  port
    (
      -- Slaves
      priority_wbr : in  wbrs;          -- Priority Arbiter (read)
      priority_wbw : out wbws;          -- Priority Arbiter (write)

      wbrst_wbr : in  wbrs;             -- FPGA Reset (read)
      wbrst_wbw : out wbws;             -- FPGA Reset (write)

      pwmx_wbr : in  wbrs;              -- X-Axis PWM (read)
      pwmx_wbw : out wbws;              -- X-Axis PWM (write)

      pwmy_wbr : in  wbrs;              -- Y-Axis PWM (read)
      pwmy_wbw : out wbws;              -- Y-Axis PWM (write)

      pwmz_wbr : in  wbrs;              -- Z-Axis PWM (read)
      pwmz_wbw : out wbws;              -- Z-Axis PWM (write)

      temp_wbr : in  wbrs;              -- Temperature sensors (read)
      temp_wbw : out wbws;              -- Temperature sensors (write)

      suncss_wbr : in  wbrs;            -- Coarse sun sensor (read)
      suncss_wbw : out wbws;            -- Coarse sun sensor (write)

      sunmss_wbr : in  wbrs;            -- Medium sun sensor (read)
      sunmss_wbw : out wbws;            -- Medium sun sensor (write)

      sunfss_wbr : in  wbrs;            -- Fine sun sensor (read)
      sunfss_wbw : out wbws;            -- Fine sun sensor (write)

      -- Master: The Wishbone Wrapper
      ---- These are what we are multiplexing
      wwbr : out wbrs;
      wwbw : in  wbws
      );
end entity;

architecture RTL of intercon is
  -- DEAD signal
  signal dead : wbrs := (readdata => x"DEAD", ack => '0');
  signal wba  : addr;
begin

  wba <= wwbw.c.address;

  -- Gate write bus to slaves
  priority_wbw <= wwbw when priority_a = dev(wba) else
                  null_wbw;
  wbrst_wbw <= wwbw when wbrst_a = dev(wba) else
               null_wbw;
  
  pwmx_wbw <= wwbw when pwmx_a = dev(wba) else
              null_wbw;
  pwmy_wbw <= wwbw when pwmy_a = dev(wba) else
              null_wbw;
  pwmz_wbw <= wwbw when pwmz_a = dev(wba) else
              null_wbw;

  temp_wbw <= wwbw when temp_a = dev(wba) else
              null_wbw;
  
  suncss_wbw <= wwbw when suncss_a = dev(wba) else
                null_wbw;
  sunmss_wbw <= wwbw when sunmss_a = dev(wba) else
                null_wbw;
  sunfss_wbw <= wwbw when sunfss_a = dev(wba) else
                null_wbw;

  -- Dead signal (ack depends on cycle)
  dead.ack <= wwbw.cycle;

  -- Multiplex data and ack from slaves.
  -- Respond with 0xdead if no slave selected.
  wwbr <= priority_wbr when priority_a = dev(wba) else
          wbrst_wbr  when wbrst_a = dev(wba) else
          pwmx_wbr   when pwmx_a = dev(wba) else
          pwmy_wbr   when pwmy_a = dev(wba) else
          pwmz_wbr   when pwmz_a = dev(wba) else
          temp_wbr   when temp_a = dev(wba) else
          suncss_wbr when suncss_a = dev(wba) else
          sunmss_wbr when sunmss_a = dev(wba) else
          sunfss_wbr when sunfss_a = dev(wba) else
          dead;

end architecture;
