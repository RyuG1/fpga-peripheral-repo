library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_uart_if_bridge is
    generic (
        CLKS_PER_BIT : integer := 434
    );
    port (
        clk         : in    std_logic;
        rst_n       : in    std_logic;

        uart_rx_i   : in    std_logic;
        uart_tx_o   : out   std_logic;

        IfClk       : out   std_logic;
        IfAle       : out   std_logic;
        IfRd        : out   std_logic;
        IfWr        : out   std_logic;
        IfData      : inout std_logic_vector(19 downto 0)
    );
end entity;

architecture rtl of top_uart_if_bridge is

    signal rx_dv        : std_logic;
    signal rx_byte      : std_logic_vector(7 downto 0);

    signal tx_start     : std_logic;
    signal tx_byte      : std_logic_vector(7 downto 0);
    signal tx_active    : std_logic;
    signal tx_done      : std_logic;

    signal cmd_valid    : std_logic;
    signal cmd_wr       : std_logic;
    signal cmd_rd       : std_logic;
    signal cmd_addr     : std_logic_vector(19 downto 0);
    signal cmd_wdata    : std_logic_vector(19 downto 0);

    signal if_data_o    : std_logic_vector(19 downto 0);
    signal if_data_i    : std_logic_vector(19 downto 0);
    signal if_data_oe   : std_logic;

    signal rd_valid     : std_logic;
    signal rd_data      : std_logic_vector(19 downto 0);

    type tx_state_t is (ST_TX_IDLE, ST_TX_B0, ST_TX_B1, ST_TX_B2);
    signal tx_state     : tx_state_t;
    signal reg_tx_data  : std_logic_vector(19 downto 0);

begin

    IfData   <= if_data_o when if_data_oe = '1' else (others => 'Z');
    if_data_i <= IfData;

    u_uart_if : entity work.uart_if
        generic map (
            CLKS_PER_BIT => CLKS_PER_BIT
        )
        port map (
            clk       => clk,
            rst_n     => rst_n,
            uart_rx_i => uart_rx_i,
            uart_tx_o => uart_tx_o,
            rx_dv     => rx_dv,
            rx_byte   => rx_byte,
            tx_start  => tx_start,
            tx_byte   => tx_byte,
            tx_active => tx_active,
            tx_done   => tx_done
        );

    u_uart_cmd_parser : entity work.uart_cmd_parser
        port map (
            clk       => clk,
            rst_n     => rst_n,
            rx_dv     => rx_dv,
            rx_byte   => rx_byte,
            cmd_valid => cmd_valid,
            cmd_wr    => cmd_wr,
            cmd_rd    => cmd_rd,
            cmd_addr  => cmd_addr,
            cmd_wdata => cmd_wdata
        );

    u_if_master_ctrl : entity work.if_master_ctrl
        port map (
            clk        => clk,
            rst_n      => rst_n,
            cmd_valid  => cmd_valid,
            cmd_wr     => cmd_wr,
            cmd_rd     => cmd_rd,
            cmd_addr   => cmd_addr,
            cmd_wdata  => cmd_wdata,
            if_clk     => IfClk,
            if_ale     => IfAle,
            if_rd      => IfRd,
            if_wr      => IfWr,
            if_data_o  => if_data_o,
            if_data_i  => if_data_i,
            if_data_oe => if_data_oe,
            rd_valid   => rd_valid,
            rd_data    => rd_data
        );

    process(clk, rst_n)
    begin
        if rst_n = '0' then
            tx_state    <= ST_TX_IDLE;
            tx_start    <= '0';
            tx_byte     <= (others => '0');
            reg_tx_data <= (others => '0');
        elsif rising_edge(clk) then
            tx_start <= '0';

            case tx_state is
                when ST_TX_IDLE =>
                    if rd_valid = '1' then
                        reg_tx_data <= rd_data;
                        tx_state    <= ST_TX_B0;
                    end if;

                when ST_TX_B0 =>
                    if tx_active = '0' then
                        tx_byte  <= "0000" & reg_tx_data(19 downto 16);
                        tx_start <= '1';
                        tx_state <= ST_TX_B1;
                    end if;

                when ST_TX_B1 =>
                    if tx_done = '1' then
                        tx_byte  <= reg_tx_data(15 downto 8);
                        tx_start <= '1';
                        tx_state <= ST_TX_B2;
                    end if;

                when ST_TX_B2 =>
                    if tx_done = '1' then
                        tx_byte  <= reg_tx_data(7 downto 0);
                        tx_start <= '1';
                        tx_state <= ST_TX_IDLE;
                    end if;
            end case;
        end if;
    end process;

end architecture;