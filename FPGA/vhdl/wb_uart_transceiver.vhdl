library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use IEEE.numeric_std.all;
use work.common_decs.all;
use work.intercon_decs.all;

--------- UART TRANSCEIVER ---------

entity WB_UART_TRANSCEIVER is
  generic (
    -- id = some pi
    id : device_id := x"3141";
    -- Size of fifo buffers (make sure they all match!)
    A  : integer   := 5
    );
  port
    (
      -- Component external signals
      clk, reset : in std_logic;

      -- Wishbone interface signals
      wbw : in  wbws;
      wbr : out wbrs;

      -- Input from UART RX
      UART_in : in  char;               -- From UART_RX
      rd_uart : out std_logic;          -- Data Recieved handshake Flag

      -- Output from UART TX
      UART_out : out char;              -- To UART_TX
      tx_uart  : out std_logic;         -- Data Transmit handshake Flag

      -- Status Flags & Info
      RX_RDY      : in std_logic;       -- Read data waiting?
      RX_OVERFLOW : in std_logic;       -- Read buffer overflow?
      RX_COUNT    : in std_logic_vector(A-1 downto 0);  -- Read data count?
      TX_IDLE     : in std_logic;       -- Write data fifo busy?
      TX_OVERFLOW : in std_logic;       -- Write buffer overflow?
      TX_COUNT    : in std_logic_vector(A-1 downto 0);  -- Write data count?

      -- RESET flags
      RX_RESET    : out std_logic;
      TX_RESET    : out std_logic;
      
      -- Data Ready Flag for Arbiter
      UART_RX_RDY : out std_logic;      -- Relays RX_RDY
      UART_ERROR  : out std_logic;      -- Error flag

      -- Set the baudrate
      baudrate : out write_chan
      );
end entity;

architecture RTL of WB_UART_TRANSCEIVER is
  signal saddr          : subsys_addr;
  signal readdata       : read_chan;
  signal RD_ACK, WR_ACK : std_logic;
  signal brate          : write_chan;
  signal rx_rst, tx_rst : std_logic;
begin
  saddr <= subsys(wbw.c.address);

  --  Register reading logic
  read_logic : process(clk, reset)
  begin
    if(reset = '1') then
      RD_ACK   <= '0';
      readdata <= (others => '0');
      rd_uart  <= '0';
    elsif(rising_edge(clk)) then
      rd_uart <= '0';
      RD_ACK  <= '0';
      if master_is_reading(wbw) then
        RD_ACK <= '1';
        case saddr is
          -- ALL SUBSYSTEM ADDRESSES MUST BE EVEN!!!! 
          -- Explanation: 
          -- http://www.armadeus.com/wiki/index.php?title=APF27_FPGA-IMX_interface_description
          
          -- Get the ID
          when x"0" =>
            readdata <= id;
          -- Report Baudrate
          when x"2" =>
            readdata <= brate;
          -- Read RX buffer
          when x"4" =>
            if (RX_RDY = '1') then
              readdata <= std_logic_vector(resize(unsigned(UART_in), readdata'length));
              rd_uart  <= '1';
            else
              readdata <= x"EEEE";
            end if;
          -- Cannot read the TX buffer
          when x"6" =>
            readdata <= x"9009";        -- POOP         
          -- #Num Waiting in RX Buffer
          when x"8" =>
            readdata <= std_logic_vector(resize(unsigned(RX_COUNT), readdata'length));
          -- #Num Waiting in TX Buffer
          when x"A" =>
            readdata <= std_logic_vector(resize(unsigned(TX_COUNT), readdata'length));
          -- Get the Statuses
          when x"C" =>
            readdata <= (0      => RX_RDY,
                         1      => RX_OVERFLOW,
                         2      => TX_IDLE,
                         3      => TX_OVERFLOW,
                         others => '0');
          -- Nothing else is addressed
          when others =>
            readdata <= x"BAD2";
        end case;
      end if;
    end if;
  end process;

  -- We can write the baudrate and to the TX fifo
  write_logic : process(clk, reset)
  begin
    if (reset = '1') then
      brate  <= (others => '0');
      TX_UART <= '0';
      WR_ACK <= '0';
      rx_rst <= '0';
      tx_rst <= '0';
    elsif(rising_edge(clk)) then
      TX_UART <= '0';
      WR_ACK  <= '0';
      rx_rst <= '0';
      tx_rst <= '0';
      if master_is_writing(wbw) then
        WR_ACK <= '1';
        case saddr is
          -- Write the baudrate
          when x"2" => brate <= wbw.c.writedata;
          -- Write to the UART
          when x"6" =>
            -- Only keep least significant bits
            UART_out <= wbw.c.writedata(UART_out'length-1 downto 0);
            TX_UART  <= '1';
          -- If we try to zero the buffer counts, reset
          -- Reset the reader
          when x"8" =>
            if (wbw.c.writedata = x"0000") then
              rx_rst <= '1';
            end if;
          -- Reset the writer
          when x"A" =>
            if (wbw.c.writedata = x"0000") then
              tx_rst <= '1';
            end if;
          when others   => null;
        end case;
      end if;
    end if;
  end process;

  wbr.ack      <= RD_ACK or WR_ACK;
  wbr.readdata <= readdata when (master_is_reading(wbw))
                  else (others => '0');
  RX_RESET <= rx_rst;
  TX_RESET <= tx_rst;
  baudrate    <= brate;
  UART_RX_RDY <= RX_RDY;
  -- Throw an error if we have an overflow 
  UART_ERROR  <= RX_OVERFLOW or TX_OVERFLOW;
  
end architecture RTL;
