library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;

library C;
use C.stdio_h.all;
use C.strings_h.all;

library CXBN;
use CXBN.common_decs.all;
use CXBN.intercon_decs.all;

--  A testbench has no ports
entity pwm_mod_tb is end;

architecture behav of pwm_mod_tb is
  signal clk, reset : std_logic := '0';
  signal WBR                 : wbrs      := null_wbr;
  signal WBW                 : wbws      := null_wbw;
  signal pulse, sign         : std_logic := '0';
  signal running             : boolean   := true;
begin
  dut1 : entity CXBN.pwm_mod(arc)
    generic map (id => x"5555")
    port map (
      CLK => CLK,
      WBR     => WBR,
      WBW     => WBW,
      pulse   => pulse,
      sign    => sign,
      PWM_CLK => CLK,
      reset   => reset
      );

  clk <= not clk after 1 ns when running;

  reset <= '1' after 0 ns,
           '0' after 5 ns;

  process(clk)
    -- Input file
    variable fin  : CFILE := fopen("pwm_commands.txt", "r");
    -- Log file
    variable flog : CFILE := fopen("pwm.log", "w");

    -- Command character(s)
    variable cs : string(1 to 2);

    -- Machine state
    type machine_state is (idle, reading, writing, waiting);
    variable mode : machine_state := idle;

    -- Timeout duration
    variable tmout : integer;

    -- Address and value handling
    variable ar  : addr       := x"BAD";
    variable val : write_chan := x"DEAD";

    -- Log message handling
    variable msg : string(1 to 128);
    variable i   : integer;
  begin
    if rising_edge(clk) then
      WBW <= null_wbw;
      if (not feof(fin) or mode /= idle) then
        case mode is
          when idle =>
            -- Read a command from input file
            fscanf(fin, "%s ", cs);
            -- Interpret command
            case cs(1) is
              when 'R' =>               -- Read instruction
                fscanf(fin, "%x", ar);
                WBW  <= read_wbw(ar);
                fprintf(flog, "R %3.x - ", ar);
                fprintf(flog, "Dev: %2.x ", dev(ar));
                fprintf(flog, "Sub: %1.x ", subsys(ar));
                mode := reading;
              when 'T' =>               -- Wait instruction
                fscanf(fin, "%d", tmout);
                fprintf(flog, "Wait for %i clock cycles... ", tmout);
                mode := waiting;
              when 'M' =>               -- Write a log message
                i := 1; msg := (others => NUL);

                msg(i)   := getc(fin);
                while (i <= msg'length and msg(i) /= LF) loop
                  i      := i + 1;
                  msg(i) := getc(fin);
                end loop;
                fprintf(flog, "%s", msg);
              when 'W' =>               -- Write instruction
                fscanf(fin, "%x", ar);
                fscanf(fin, "%x", val);
                WBW  <= write_wbw(ar, val);
                fprintf(flog, "W %3.x - ", ar);
                fprintf(flog, "Dev: %2.x ", dev(ar));
                fprintf(flog, "Sub: %1.x - ", subsys(ar));
                fprintf(flog, "Value: %d", val);
                fprintf(flog, "/%x ... ", val);
                mode := writing;
              when others =>
                fprintf(flog, "Unrecognized command: %s", cs);
            end case;
          when waiting =>
            -- Wait until the timeout is over
            if (tmout > 0) then
              tmout := tmout - 1;
            else
              fprintf(flog, "done\n");
              mode := idle;
            end if;
          when reading =>
            -- Keep on reading until we get an acknowledge signal
            if (WBR.ack = '1') then
              fprintf(flog, "=> %d", WBR.readdata);
              fprintf(flog, "/%x\n", WBR.readdata);
              mode := idle;
            end if;
          when writing =>
            if (WBR.ack = '1') then
              fprintf(flog, "done\n");
              mode := idle;
            end if;
          when others => null;
        end case;
      else
        -- EOF; nothing more to read (so quit)
        fclose(fin);
        fclose(flog);
        running <= false;
      end if;
    end if;
  end process;
end;
