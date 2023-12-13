library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_COM_to_7Seg is

end TB_COM_to_7Seg;

architecture Behavioral of TB_COM_to_7Seg is
--------------------------------------------------------
component SevenSegmentDriver is
Port(
    clk: in STD_LOGIC;
    reset: in STD_LOGIC;
    enable: in STD_LOGIC;
    data: in STD_LOGIC_VECTOR(63 downto 0);
    AN: out STD_LOGIC_VECTOR(7 downto 0);
    SEG: out STD_LOGIC_VECTOR(7 downto 0)
    );
end component;
--------------------------------------------------------
component UART_RX is
PORT(
    clk:        in STD_LOGIC;         -- Clock
    reset:      in STD_LOGIC;       -- reset
    rx_enable:      in STD_LOGIC;       -- enable
    r_data:     out STD_LOGIC_VECTOR (7 downto 0);
    rx_flag:    out STD_LOGIC;
    rx:         in STD_LOGIC 
    );          -- Receive Data Pin
end component;
--------------------------------------------------------
signal rx_busy: STD_LOGIC;
signal rx_flag: STD_LOGIC;
signal rx_error: STD_LOGIC;
signal received_byte: STD_LOGIC_VECTOR (7 downto 0);
signal incoming_byte_counter : integer range 0 to 8 :=0;

signal rx_enable: STD_LOGIC :='1';
signal enable: STD_LOGIC;
signal data: STD_LOGIC_VECTOR (63 downto 0);
signal word_received_flag :STD_LOGIC;

signal clock_100Mhz:  STD_LOGIC :='0';
signal reset:  STD_LOGIC :='0';
signal rx_pin:  STD_LOGIC :='1';
signal AN:  STD_LOGIC_VECTOR(7 downto 0) :=x"00";
signal SEG:  STD_LOGIC_VECTOR(7 downto 0) :=x"00";
signal baud: STD_LOGIC :='0';


begin
clock_100Mhz <= not clock_100Mhz After 1ps;
baud <= not baud After 868ps;

U1:UART_RX Port Map(clk => clock_100Mhz, reset => reset,rx_enable => rx_enable,r_data => received_byte, rx_flag => rx_flag, rx => rx_pin);
U2:SevenSegmentDriver Port Map(clk => clock_100Mhz, reset => reset, enable => enable, data => data, AN => AN, SEG => SEG);
------------------------------------------------
stimulus: process
begin
wait for 8680 ps;
-- x"46" --F   01000110
-- x"50" --P   01010000
-- x"47" --G   01000111
-- x"41" --A   01000001
-- x"21" --!   00100001

-- x"46" --F   01000110
rx_pin <= '0'; wait for 1736ps;--start
rx_pin <= '0'; wait for 1736ps;
rx_pin <= '1'; wait for 1736ps;
rx_pin <= '1'; wait for 1736ps;
rx_pin <= '0'; wait for 1736ps;
rx_pin <= '0'; wait for 1736ps;
rx_pin <= '0'; wait for 1736ps;
rx_pin <= '1'; wait for 1736ps;
rx_pin <= '0'; wait for 1736ps;
rx_pin <= '0'; wait for 1736ps;--stop

rx_pin <= '1'; wait for 2000ps; --idle

-- x"50" --P   01010000
rx_pin <= '0'; wait for 1736ps;--start
rx_pin <= '0'; wait for 1736ps;
rx_pin <= '0'; wait for 1736ps;
rx_pin <= '0'; wait for 1736ps;
rx_pin <= '0'; wait for 1736ps;
rx_pin <= '1'; wait for 1736ps;
rx_pin <= '0'; wait for 1736ps;
rx_pin <= '1'; wait for 1736ps;
rx_pin <= '0'; wait for 1736ps;
rx_pin <= '0'; wait for 1736ps;--stop

rx_pin <= '1'; wait for 2000ps; --idle

-- x"47" --G   01000111
rx_pin <= '0'; wait for 1736ps;--start
rx_pin <= '1'; wait for 1736ps;
rx_pin <= '1'; wait for 1736ps;
rx_pin <= '1'; wait for 1736ps;
rx_pin <= '0'; wait for 1736ps;
rx_pin <= '0'; wait for 1736ps;
rx_pin <= '0'; wait for 1736ps;
rx_pin <= '1'; wait for 1736ps;
rx_pin <= '0'; wait for 1736ps;
rx_pin <= '0'; wait for 1736ps;--stop

rx_pin <= '1'; wait for 2000ps; --idle

-- x"41" --A   01000001
rx_pin <= '0'; wait for 1736ps;--start
rx_pin <= '1'; wait for 1736ps;
rx_pin <= '0'; wait for 1736ps;
rx_pin <= '0'; wait for 1736ps;
rx_pin <= '0'; wait for 1736ps;
rx_pin <= '0'; wait for 1736ps;
rx_pin <= '0'; wait for 1736ps;
rx_pin <= '1'; wait for 1736ps;
rx_pin <= '0'; wait for 1736ps;
rx_pin <= '0'; wait for 1736ps;--stop

rx_pin <= '1'; wait for 2000ps; --idle

-- x"21" --!   00100001
rx_pin <= '0'; wait for 1736ps;--start
rx_pin <= '1'; wait for 1736ps;
rx_pin <= '0'; wait for 1736ps;
rx_pin <= '0'; wait for 1736ps;
rx_pin <= '0'; wait for 1736ps;
rx_pin <= '0'; wait for 1736ps;
rx_pin <= '1'; wait for 1736ps;
rx_pin <= '0'; wait for 1736ps;
rx_pin <= '0'; wait for 1736ps;
rx_pin <= '0'; wait for 1736ps;--stop

rx_pin <= '1'; wait for 2000ps; --idle

wait for 800000 ns;

end process;
------------------------------------------------
process(rx_flag)
begin
    if rising_edge(rx_flag) then
        if incoming_byte_counter < 8 then
            enable <= '0';
            word_received_flag <= '0';
            if not (received_byte = x"21") then
                data(64-1-incoming_byte_counter*8 downto 56-incoming_byte_counter*8) <= received_byte;
                incoming_byte_counter <= incoming_byte_counter + 1;
            else
                data(64-1-incoming_byte_counter*8 downto 0) <= (others=>'0');
                word_received_flag <= '1';
                enable <= '1';
                incoming_byte_counter <= 0;
            end if;
        else
            incoming_byte_counter <= 0;
            enable <= '1';
            word_received_flag <= '1';
        end if;
    end if;
end process;
------------------------------------------------
------------------------------------------------

end Behavioral;
