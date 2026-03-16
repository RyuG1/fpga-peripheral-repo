library ieee;
use ieee.std_logic_1164.all;


entity addr_decoder is
    generic (
        BASE_ADDR : std_logic_vector(31 downto 0)
    );
    port (
        addr_bus : in  std_logic_vector(31 downto 0);
        sel_out  : out std_logic
    );
end entity;

architecture rtl of addr_decoder is
begin
	-- 상위 16비트만 비교하여 모듈 선택 (0x4000_XXXX 인지 확인)
    sel_out <= '1' when addr_bus(31 downto 16) = BASE_ADDR(31 downto 16) else '0';
end rtl;