library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_cmd_parser is
    port (
        clk         : in  std_logic;
        rst_n       : in  std_logic;

        rx_dv       : in  std_logic;
        rx_byte     : in  std_logic_vector(7 downto 0);

        cmd_valid   : out std_logic;
        cmd_wr      : out std_logic;
        cmd_rd      : out std_logic;
        cmd_addr    : out std_logic_vector(19 downto 0);
        cmd_wdata   : out std_logic_vector(19 downto 0)
    );
end entity;

architecture rtl of uart_cmd_parser is
    constant CMD_WRITE : std_logic_vector(7 downto 0) := x"57"; -- 'W'
    constant CMD_READ  : std_logic_vector(7 downto 0) := x"52"; -- 'R'

    type state_t is (
        ST_IDLE,
        ST_WR_ADDR_H,
        ST_WR_ADDR_M,
        ST_WR_ADDR_L,
        ST_WR_DATA_H,
        ST_WR_DATA_M,
        ST_WR_DATA_L,
        ST_RD_ADDR_H,
        ST_RD_ADDR_M,
        ST_RD_ADDR_L
    );

    signal state       : state_t;
    signal reg_cmd_wr  : std_logic;
    signal reg_cmd_rd  : std_logic;
    signal reg_addr    : std_logic_vector(19 downto 0);
    signal reg_wdata   : std_logic_vector(19 downto 0);
begin

    cmd_addr  <= reg_addr;
    cmd_wdata <= reg_wdata;

    process(clk, rst_n)
    begin
        if rst_n = '0' then
            state      <= ST_IDLE;
            reg_cmd_wr <= '0';
            reg_cmd_rd <= '0';
            reg_addr   <= (others => '0');
            reg_wdata  <= (others => '0');
            cmd_valid  <= '0';
            cmd_wr     <= '0';
            cmd_rd     <= '0';
        elsif rising_edge(clk) then
            cmd_valid <= '0';
            cmd_wr    <= '0';
            cmd_rd    <= '0';

            if rx_dv = '1' then
                case state is
                    when ST_IDLE =>
                        reg_cmd_wr <= '0';
                        reg_cmd_rd <= '0';

                        if rx_byte = CMD_WRITE then
                            reg_cmd_wr <= '1';
                            state <= ST_WR_ADDR_H;
                        elsif rx_byte = CMD_READ then
                            reg_cmd_rd <= '1';
                            state <= ST_RD_ADDR_H;
                        end if;

                    when ST_WR_ADDR_H =>
                        reg_addr(19 downto 16) <= rx_byte(3 downto 0);
                        state <= ST_WR_ADDR_M;

                    when ST_WR_ADDR_M =>
                        reg_addr(15 downto 8) <= rx_byte;
                        state <= ST_WR_ADDR_L;

                    when ST_WR_ADDR_L =>
                        reg_addr(7 downto 0) <= rx_byte;
                        state <= ST_WR_DATA_H;

                    when ST_WR_DATA_H =>
                        reg_wdata(19 downto 16) <= rx_byte(3 downto 0);
                        state <= ST_WR_DATA_M;

                    when ST_WR_DATA_M =>
                        reg_wdata(15 downto 8) <= rx_byte;
                        state <= ST_WR_DATA_L;

                    when ST_WR_DATA_L =>
                        reg_wdata(7 downto 0) <= rx_byte;
                        cmd_valid <= '1';
                        cmd_wr    <= '1';
                        state     <= ST_IDLE;

                    when ST_RD_ADDR_H =>
                        reg_addr(19 downto 16) <= rx_byte(3 downto 0);
                        state <= ST_RD_ADDR_M;

                    when ST_RD_ADDR_M =>
                        reg_addr(15 downto 8) <= rx_byte;
                        state <= ST_RD_ADDR_L;

                    when ST_RD_ADDR_L =>
                        reg_addr(7 downto 0) <= rx_byte;
                        cmd_valid <= '1';
                        cmd_rd    <= '1';
                        state     <= ST_IDLE;
                end case;
            end if;
        end if;
    end process;

end architecture;