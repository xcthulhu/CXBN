----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:44:37 05/17/2011 
-- Design Name: 
-- Module Name:    spi_loopback - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;
 
-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
 
--library WORK;
--use WORK.ALL;
 
entity spi_loopback is
    Generic (   
        N : positive := 32;                                         -- 32bit serial word length is default
        CPOL : std_logic := '0';                                    -- SPI mode selection (mode 0 default)
        CPHA : std_logic := '1';                                    -- CPOL = clock polarity, CPHA = clock phase.
        PREFETCH : positive := 2                                    -- prefetch lookahead cycles
        );                                  
    Port(
        ----------------MASTER-----------------------
        m_spi_2x_clk_i : IN std_logic;
        m_clk_i : IN std_logic;
        m_rst_i : IN std_logic;
        m_spi_ssel_o : OUT std_logic;
        m_spi_sck_o : OUT std_logic;
        m_spi_mosi_o : OUT std_logic;
        m_spi_miso_i : IN std_logic;
        m_di_req_o : OUT std_logic;
        m_di_i : IN std_logic_vector(N-1 downto 0);
        m_wren_i : IN std_logic;          
        m_do_valid_o : OUT std_logic;
        m_do_o : OUT std_logic_vector(N-1 downto 0);
        ----- debug -----
        m_do_transfer_o : OUT std_logic;
        m_wren_o : OUT std_logic;
        m_wren_ack_o : OUT std_logic;
        m_rx_bit_reg_o : OUT std_logic;
        m_state_dbg_o : OUT std_logic_vector(5 downto 0);
        m_core_clk_o : OUT std_logic;
        m_core_n_clk_o : OUT std_logic;
        m_sh_reg_dbg_o : OUT std_logic_vector(N-1 downto 0);
        ----------------SLAVE-----------------------
        s_clk_i : IN std_logic;
        s_spi_ssel_i : IN std_logic;
        s_spi_sck_i : IN std_logic;
        s_spi_mosi_i : IN std_logic;
        s_spi_miso_o : OUT std_logic;
        s_di_req_o : OUT std_logic;                                         -- preload lookahead data request line
        s_di_i : IN std_logic_vector (N-1 downto 0) := (others => 'X');     -- parallel load data in (clocked in on rising edge of clk_i)
        s_wren_i : IN std_logic := 'X';                                     -- user data write enable
        s_do_valid_o : OUT std_logic;                                       -- do_o data valid strobe, valid during one clk_i rising edge.
        s_do_o : OUT std_logic_vector (N-1 downto 0);                       -- parallel output (clocked out on falling clk_i)
        ----- debug -----
        s_do_transfer_o : OUT std_logic;                                    -- debug: internal transfer driver
        s_wren_o : OUT std_logic;
        s_wren_ack_o : OUT std_logic;
        s_rx_bit_reg_o : OUT std_logic;
        s_state_dbg_o : OUT std_logic_vector (5 downto 0)                   -- debug: internal state register
--      s_sh_reg_dbg_o : OUT std_logic_vector (N-1 downto 0)                -- debug: internal shift register
        );
end spi_loopback;
 
architecture Structural of spi_loopback is
 
    COMPONENT spi_master
    GENERIC (   
        N : positive := 32;
        CPOL : std_logic := '0';
        CPHA : std_logic := '1';
        PREFETCH : positive := 2
        );
    PORT(
        spi_2x_clk_i : IN std_logic;
        clk_i : IN std_logic;
        rst_i : IN std_logic;
        spi_ssel_o : OUT std_logic;
        spi_sck_o : OUT std_logic;
        spi_mosi_o : OUT std_logic;
        spi_miso_i : IN std_logic;
        di_req_o : OUT std_logic;
        di_i : IN std_logic_vector(N-1 downto 0);
        wren_i : IN std_logic;          
        do_valid_o : OUT std_logic;
        do_o : OUT std_logic_vector(N-1 downto 0);
        ----- debug -----
        do_transfer_o : OUT std_logic;
        wren_o : OUT std_logic;
        wren_ack_o : OUT std_logic;
        rx_bit_reg_o : OUT std_logic;
        state_dbg_o : OUT std_logic_vector(5 downto 0);
        core_clk_o : OUT std_logic;
        core_n_clk_o : OUT std_logic;
        sh_reg_dbg_o : OUT std_logic_vector(N-1 downto 0)
        );
    END COMPONENT;
 
    COMPONENT spi_slave
    GENERIC (   
        N : positive := 32;
        CPOL : std_logic := '0';
        CPHA : std_logic := '1';
        PREFETCH : positive := 2
        );
    PORT(
        clk_i : IN std_logic;
        spi_ssel_i : IN std_logic;
        spi_sck_i : IN std_logic;
        spi_mosi_i : IN std_logic;
        spi_miso_o : OUT std_logic;
        di_req_o : OUT std_logic;
        di_i : IN std_logic_vector(N-1 downto 0);
        wren_i : IN std_logic;          
        do_valid_o : OUT std_logic;
        do_o : OUT std_logic_vector(N-1 downto 0);
        ----- debug -----
        do_transfer_o : OUT std_logic;
        wren_o : OUT std_logic;
        wren_ack_o : OUT std_logic;
        rx_bit_reg_o : OUT std_logic;
        state_dbg_o : OUT std_logic_vector(5 downto 0)
--		sh_reg_dbg_o : OUT std_logic_vector(N-1 downto 0)
        );
    END COMPONENT;
 
begin
 
    Inst_spi_master: spi_master 
    GENERIC MAP (
        N => N,
        CPOL => CPOL,
        CPHA => CPHA,
        PREFETCH => PREFETCH)
    PORT MAP(
        spi_2x_clk_i => m_spi_2x_clk_i,
        clk_i => m_clk_i,
        rst_i => m_rst_i,
        spi_ssel_o => m_spi_ssel_o,
        spi_sck_o => m_spi_sck_o,
        spi_mosi_o => m_spi_mosi_o,
        spi_miso_i => m_spi_miso_i,
        di_req_o => m_di_req_o,
        di_i => m_di_i,
        wren_i => m_wren_i,
        do_valid_o => m_do_valid_o,
        do_o => m_do_o,
        ----- debug -----
        do_transfer_o => m_do_transfer_o,
        wren_o => m_wren_o,
        wren_ack_o => m_wren_ack_o,
        rx_bit_reg_o => m_rx_bit_reg_o,
        state_dbg_o => m_state_dbg_o,
        core_clk_o => m_core_clk_o,
        core_n_clk_o => m_core_n_clk_o,
        sh_reg_dbg_o => m_sh_reg_dbg_o
    );
 
    Inst_spi_slave: spi_slave 
    GENERIC MAP (
        N => N,
        CPOL => CPOL,
        CPHA => CPHA,
        PREFETCH => PREFETCH)
    PORT MAP(
        clk_i => s_clk_i,
        spi_ssel_i => s_spi_ssel_i,
        spi_sck_i => s_spi_sck_i,
        spi_mosi_i => s_spi_mosi_i,
        spi_miso_o => s_spi_miso_o,
        di_req_o => s_di_req_o,
        di_i => s_di_i,
        wren_i => s_wren_i,
        do_valid_o => s_do_valid_o,
        do_o => s_do_o,
        ----- debug -----
        do_transfer_o => s_do_transfer_o,
        wren_o => s_wren_o,
        wren_ack_o => s_wren_ack_o,
        rx_bit_reg_o => s_rx_bit_reg_o,
        state_dbg_o => s_state_dbg_o
--		sh_reg_dbg_o => s_sh_reg_dbg_o
    );
 
end Structural;
