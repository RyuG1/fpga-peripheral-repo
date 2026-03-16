library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx is
    generic (
        CLKS_PER_BIT : integer := 434
    );
    port (
        clk         : in  std_logic;
        rst_n       : in  std_logic;
        rx          : in  std_logic;
        rx_dv       : out std_logic;
        rx_byte     : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of uart_rx is
    type state_t is (ST_IDLE, ST_START, ST_DATA, ST_STOP, ST_DONE);
    signal state       : state_t;
    signal reg_clk_cnt : integer range 0 to CLKS_PER_BIT-1;
    signal reg_bit_idx : integer range 0 to 7;
    signal reg_rx_byte : std_logic_vector(7 downto 0);
begin

    process(clk, rst_n)
    begin
        if rst_n = '0' then
            state       <= ST_IDLE;
            reg_clk_cnt <= 0;
            reg_bit_idx <= 0;
            reg_rx_byte <= (others => '0');
            rx_dv       <= '0';
            rx_byte     <= (others => '0');
        elsif rising_edge(clk) then
            rx_dv <= '0';

            case state is
                when ST_IDLE =>
                    reg_clk_cnt <= 0;
                    reg_bit_idx <= 0;
                    if rx = '0' then
                        state <= ST_START;
                    end if;

                when ST_START =>
                    if reg_clk_cnt = (CLKS_PER_BIT-1)/2 then
                        if rx = '0' then
                            reg_clk_cnt <= 0;
                            state <= ST_DATA;
                        else
                            state <= ST_IDLE;
                        end if;
                    else
                        reg_clk_cnt <= reg_clk_cnt + 1;
                    end if;

                when ST_DATA =>
                    if reg_clk_cnt = CLKS_PER_BIT-1 then
                        reg_clk_cnt <= 0;
                        reg_rx_byte(reg_bit_idx) <= rx;

                        if reg_bit_idx = 7 then
                            reg_bit_idx <= 0;
                            state <= ST_STOP;
                        else
                            reg_bit_idx <= reg_bit_idx + 1;
                        end if;
                    else
                        reg_clk_cnt <= reg_clk_cnt + 1;
                    end if;

                when ST_STOP =>
                    if reg_clk_cnt = CLKS_PER_BIT-1 then
                        reg_clk_cnt <= 0;
                        state <= ST_DONE;
                    else
                        reg_clk_cnt <= reg_clk_cnt + 1;
                    end if;

                when ST_DONE =>
                    rx_dv   <= '1';
                    rx_byte <= reg_rx_byte;
                    state   <= ST_IDLE;
            end case;
        end if;
    end process;

end architecture;