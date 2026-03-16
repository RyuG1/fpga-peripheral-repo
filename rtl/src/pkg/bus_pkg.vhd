-- rtl/src/pkg/bus_pkg.vhd
library ieee;
use ieee.std_logic_1164.all;

package bus_pkg is
    -- 마스터(CPU/Top)에서 슬레이브(Peripheral)로 가는 신호
    type bus_m2s is record
        addr : std_logic_vector(31 downto 0);
        data : std_logic_vector(31 downto 0);
        we   : std_logic; -- Write Enable
        re   : std_logic; -- Read Enable
    end record;

    -- 슬레이브에서 마스터로 오는 신호
    type bus_s2m is record
        data : std_logic_vector(31 downto 0);
        ack  : std_logic; -- 작업 완료 응답 (선택 사항)
    end record;
end package;