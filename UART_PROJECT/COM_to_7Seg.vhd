
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity COM_to_7Seg is
    Port(
    clock_100Mhz: in STD_LOGIC;
    reset: in STD_LOGIC;
    rx_pin: in STD_LOGIC;
    AN: out STD_LOGIC_VECTOR(7 downto 0);
    SEG: out STD_LOGIC_VECTOR(7 downto 0)
    );
end COM_to_7Seg;

architecture Behavioral of COM_to_7Seg is
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
signal rx_flag: STD_LOGIC;
signal rx_error: STD_LOGIC;
signal received_byte: STD_LOGIC_VECTOR (7 downto 0);
signal incoming_byte_counter : integer range 0 to 8 :=0;

signal rx_enable: STD_LOGIC :='1';
signal enable: STD_LOGIC;
signal data: STD_LOGIC_VECTOR (63 downto 0):=(others=>'0');
signal word_received_flag :STD_LOGIC;

begin

U1:UART_RX Port Map(clk => clock_100Mhz, reset => reset,rx_enable => rx_enable,r_data => received_byte, rx_flag => rx_flag, rx => rx_pin);
U2:SevenSegmentDriver Port Map(clk => clock_100Mhz, reset => reset, enable => enable, data => data, AN => AN, SEG => SEG);

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
--process(rx_flag)
--begin
--    if rising_edge(rx_flag) then
--    case incoming_byte_counter is
--        when 0 => data(64-1-incoming_byte_counter downto 56-incoming_byte_counter) <= received_byte; incoming_byte_counter <= incoming_byte_counter + 1;enable <= '0';word_received_flag <= '0';
--        when 0 => data(63 downto 56) <= received_byte; incoming_byte_counter <= incoming_byte_counter + 1;enable <= '0';word_received_flag <= '0';
--        when 1 => data(55 downto 48) <= received_byte; incoming_byte_counter <= incoming_byte_counter + 1;enable <= '0';word_received_flag <= '0';
--        when 2 => data(47 downto 40) <= received_byte; incoming_byte_counter <= incoming_byte_counter + 1;enable <= '0';word_received_flag <= '0';
--        when 3 => data(39 downto 32) <= received_byte; incoming_byte_counter <= incoming_byte_counter + 1;enable <= '0';word_received_flag <= '0';
--        when 4 => data(31 downto 24) <= received_byte; incoming_byte_counter <= incoming_byte_counter + 1;enable <= '0';word_received_flag <= '0';
--        when 5 => data(23 downto 16) <= received_byte; incoming_byte_counter <= incoming_byte_counter + 1;enable <= '0';word_received_flag <= '0';
--        when 6 => data(15 downto 8) <= received_byte; incoming_byte_counter <= incoming_byte_counter + 1;enable <= '0';word_received_flag <= '0';
--        when 7 => data(7 downto 0) <= received_byte; incoming_byte_counter <= incoming_byte_counter + 1;enable <= '0';word_received_flag <= '0';
--        when 8 => incoming_byte_counter <= 0; enable <= '1';word_received_flag <= '1';
--    end case;
--    if received_byte = x"21" then incoming_byte_counter <= 0;word_received_flag <= '1';enable <= '1';end if;
--    end if;
--end process;
------------------------------------------------
------------------------------------------------
end Behavioral;
