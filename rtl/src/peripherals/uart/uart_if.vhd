library ieee;
use ieee.std_logic_1164.all;

entity uart_if is
    generic (
		CLK_FREQ	: integer := 50000000; -- 50MHz
		BAUD_RATE	: integer := 115200
    );
    port (
        clk         : in  std_logic;
        rst_n       : in  std_logic;

        uart_rx_i   : in  std_logic;
        uart_tx_o   : out std_logic;

        rx_dv       : out std_logic;
        rx_byte     : out std_logic_vector(7 downto 0);

        tx_start    : in  std_logic;
        tx_byte     : in  std_logic_vector(7 downto 0);
        tx_active   : out std_logic;
        tx_done     : out std_logic
    );
end entity;

architecture rtl of uart_if is

constant CLKS_PER_BIT : integer := CLK_FREQ / BAUD_RATE;

begin

    u_uart_rx : entity work.uart_rx
        generic map (
            CLKS_PER_BIT => CLKS_PER_BIT
        )
        port map (
            clk     => clk,
            rst_n   => rst_n,
            rx      => uart_rx_i,
            rx_dv   => rx_dv,
            rx_byte => rx_byte
        );

    u_uart_tx : entity work.uart_tx
        generic map (
            CLKS_PER_BIT => CLKS_PER_BIT
        )
        port map (
            clk       => clk,
            rst_n     => rst_n,
            tx_start  => tx_start,
            tx_byte   => tx_byte,
            tx_active => tx_active,
            tx_done   => tx_done,
            tx        => uart_tx_o
        );

end architecture;