<<<<<<< HEAD
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
=======
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
>>>>>>> 3de807a8631c185695a645c74706bf840139402c

entity FM_CY6S_TOP is
    port (
        SysClk		: in  std_logic;
<<<<<<< HEAD
		FpgaLed		: out std_logic_vector(7 downto 0);
		
		-- uart
		uart_rx_i   : in  std_logic;
        uart_tx_o   : out std_logic
=======
		FpgaLed		: out std_logic_vector(7 downto 0);
		
		-- uart
		uart_rx_i   : in  std_logic;
        uart_tx_o   : out std_logic
>>>>>>> 3de807a8631c185695a645c74706bf840139402c
        
    );
end entity;


architecture top of FM_CY6S_TOP is
<<<<<<< HEAD
--------------------------------------------------------------------------
component uart_if
	port(
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
end component;

=======
--------------------------------------------------------------------------
component uart_if
	port(
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
end component;

>>>>>>> 3de807a8631c185695a645c74706bf840139402c
--------------------------------------------------------------------------
	-- Top Info
	constant Year		: std_logic_vector(19 downto 0) := x"02026";
	constant Date		: std_logic_vector(19 downto 0) := x"00315";
	constant Model		: std_logic_vector(19 downto 0) := x"00FB6";
<<<<<<< HEAD
	constant BlockVer	: std_logic_vector(19 downto 0) := x"10101";
						-- Model : FB_CY6_KIT
						-- Version 1.01.01 (2026, 03, 15)
						
	signal LedCnt  		: std_logic_vector(31 downto 0);
	
	-- uart
	signal u_rx_dv		: std_logic;
	signal u_rx_byte	: std_logic_vector(7 downto 0);
	signal u_tx_start	: std_logic;
	signal u_tx_byte	: std_logic_vector(7 downto 0);
	signal u_tx_active	: std_logic;
	signal u_tx_done	: std_logic;
	
	

begin
--------------------------------------------------------------------------
process(SysClk)
begin
	if SysClk'event and SysClk = '1' then
		LedCnt <= LedCnt + '1';
	end if;
end process;

FpgaLed(7) <= not LedCnt(24);
FpgaLed(6 downto 0) <= (others => '1');


u_uart0 : uart_if
	port map(
		clk      	=> SysClk,      
        rst_n    	=> '1',  
        uart_rx_i	=> uart_rx_i,
        uart_tx_o	=> uart_tx_o,
        rx_dv    	=> u_rx_dv,
        rx_byte  	=> u_rx_byte,
        tx_start 	=> LedCnt(28),
        tx_byte  	=> x"C3", 
        tx_active	=> u_tx_active,
        tx_done  	=> u_tx_done
		);




=======
	constant BlockVer	: std_logic_vector(19 downto 0) := x"10101";
						-- Model : FB_CY6_KIT
						-- Version 1.01.01 (2026, 03, 15)
						
	signal LedCnt  		: std_logic_vector(31 downto 0);
	
	-- uart
	signal u_rx_dv		: std_logic;
	signal u_rx_byte	: std_logic_vector(7 downto 0);
	signal u_tx_start	: std_logic;
	signal u_tx_byte	: std_logic_vector(7 downto 0);
	signal u_tx_active	: std_logic;
	signal u_tx_done	: std_logic;
	
	

begin
--------------------------------------------------------------------------
process(SysClk)
begin
	if SysClk'event and SysClk = '1' then
		LedCnt <= LedCnt + '1';
	end if;
end process;

FpgaLed(7) <= not LedCnt(24);
FpgaLed(6 downto 0) <= (others => '1');


u_uart0 : uart_if
	port map(
		clk      	=> SysClk,      
        rst_n    	=> '1',  
        uart_rx_i	=> uart_rx_i,
        uart_tx_o	=> uart_tx_o,
        rx_dv    	=> u_rx_dv,
        rx_byte  	=> u_rx_byte,
        tx_start 	=> LedCnt(28),
        tx_byte  	=> x"C3", 
        tx_active	=> u_tx_active,
        tx_done  	=> u_tx_done
		);




>>>>>>> 3de807a8631c185695a645c74706bf840139402c
end top;