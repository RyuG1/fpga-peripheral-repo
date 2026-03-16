library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity if_master_ctrl is
    port (
        clk         : in  std_logic;
        rst_n       : in  std_logic;

        cmd_valid   : in  std_logic;
        cmd_wr      : in  std_logic;
        cmd_rd      : in  std_logic;
        cmd_addr    : in  std_logic_vector(19 downto 0);
        cmd_wdata   : in  std_logic_vector(19 downto 0);

        if_clk      : out std_logic;
        if_ale      : out std_logic;
        if_rd       : out std_logic;
        if_wr       : out std_logic;
        if_data_o   : out std_logic_vector(19 downto 0);
        if_data_i   : in  std_logic_vector(19 downto 0);
        if_data_oe  : out std_logic;

        rd_valid    : out std_logic;
        rd_data     : out std_logic_vector(19 downto 0)
    );
end entity;

architecture rtl of if_master_ctrl is
    type state_t is (ST_IDLE, ST_ALE, ST_WRITE, ST_READ, ST_DONE);
    signal state      : state_t;

    signal reg_cmd_wr   : std_logic;
    signal reg_cmd_rd   : std_logic;
    signal reg_addr     : std_logic_vector(19 downto 0);
    signal reg_wdata    : std_logic_vector(19 downto 0);
    signal reg_rd_data  : std_logic_vector(19 downto 0);
begin

    if_clk <= clk;

    process(clk, rst_n)
    begin
        if rst_n = '0' then
            state       <= ST_IDLE;
            reg_cmd_wr  <= '0';
            reg_cmd_rd  <= '0';
            reg_addr    <= (others => '0');
            reg_wdata   <= (others => '0');
            reg_rd_data <= (others => '0');

            if_ale      <= '0';
            if_rd       <= '0';
            if_wr       <= '0';
            if_data_o   <= (others => '0');
            if_data_oe  <= '0';

            rd_valid    <= '0';
            rd_data     <= (others => '0');

        elsif rising_edge(clk) then
            rd_valid <= '0';

            case state is
                when ST_IDLE =>
                    if_ale     <= '0';
                    if_rd      <= '0';
                    if_wr      <= '0';
                    if_data_oe <= '0';

                    if cmd_valid = '1' then
                        reg_cmd_wr <= cmd_wr;
                        reg_cmd_rd <= cmd_rd;
                        reg_addr   <= cmd_addr;
                        reg_wdata  <= cmd_wdata;
                        state      <= ST_ALE;
                    end if;

                when ST_ALE =>
                    if_ale     <= '1';
                    if_rd      <= '0';
                    if_wr      <= '0';
                    if_data_o  <= reg_addr;
                    if_data_oe <= '1';

                    if reg_cmd_wr = '1' then
                        state <= ST_WRITE;
                    else
                        state <= ST_READ;
                    end if;

                when ST_WRITE =>
                    if_ale     <= '0';
                    if_wr      <= '1';
                    if_rd      <= '0';
                    if_data_o  <= reg_wdata;
                    if_data_oe <= '1';
                    state      <= ST_DONE;

                when ST_READ =>
                    if_ale      <= '0';
                    if_wr       <= '0';
                    if_rd       <= '1';
                    if_data_oe  <= '0';
                    reg_rd_data <= if_data_i;
                    state       <= ST_DONE;

                when ST_DONE =>
                    if_ale     <= '0';
                    if_wr      <= '0';
                    if_rd      <= '0';
                    if_data_oe <= '0';

                    if reg_cmd_rd = '1' then
                        rd_valid <= '1';
                        rd_data  <= reg_rd_data;
                    end if;

                    state <= ST_IDLE;
            end case;
        end if;
    end process;

end architecture;