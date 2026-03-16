library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is
    generic (
        CLKS_PER_BIT : integer := 434
    );
    port (
        clk         : in  std_logic;
        rst_n       : in  std_logic;
        tx_start    : in  std_logic;
        tx_byte     : in  std_logic_vector(7 downto 0);
        tx_active   : out std_logic;
        tx_done     : out std_logic;
        tx          : out std_logic
    );
end entity;

architecture rtl of uart_tx is
    type state_t is (ST_IDLE, ST_START, ST_DATA, ST_STOP, ST_DONE);
    signal state       : state_t;
    signal reg_clk_cnt : integer range 0 to CLKS_PER_BIT-1;
    signal reg_bit_idx : integer range 0 to 7;
    signal reg_tx_data : std_logic_vector(7 downto 0);
    signal reg_tx      : std_logic;
begin

    tx <= reg_tx;

    process(clk, rst_n)
    begin
        if rst_n = '0' then
            state       <= ST_IDLE;
            reg_clk_cnt <= 0;
            reg_bit_idx <= 0;
            reg_tx_data <= (others => '0');
            reg_tx      <= '1';
            tx_active   <= '0';
            tx_done     <= '0';
        elsif rising_edge(clk) then
            tx_done <= '0';

            case state is
                when ST_IDLE =>
                    reg_tx      <= '1';
                    tx_active   <= '0';
                    reg_clk_cnt <= 0;
                    reg_bit_idx <= 0;

                    if tx_start = '1' then
                        reg_tx_data <= tx_byte;
                        tx_active   <= '1';
                        state       <= ST_START;
                    end if;

                when ST_START =>
                    reg_tx <= '0';
                    if reg_clk_cnt = CLKS_PER_BIT-1 then
                        reg_clk_cnt <= 0;
                        state <= ST_DATA;
                    else
                        reg_clk_cnt <= reg_clk_cnt + 1;
                    end if;

                when ST_DATA =>
                    reg_tx <= reg_tx_data(reg_bit_idx);
                    if reg_clk_cnt = CLKS_PER_BIT-1 then
                        reg_clk_cnt <= 0;
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
                    reg_tx <= '1';
                    if reg_clk_cnt = CLKS_PER_BIT-1 then
                        reg_clk_cnt <= 0;
                        state <= ST_DONE;
                    else
                        reg_clk_cnt <= reg_clk_cnt + 1;
                    end if;

                when ST_DONE =>
                    tx_done   <= '1';
                    tx_active <= '0';
                    state     <= ST_IDLE;
            end case;
        end if;
    end process;

end architecture;