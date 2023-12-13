library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity UART_RX is
Port (
        clk:        in STD_LOGIC;         -- Clock
        reset:      in STD_LOGIC;       -- reset
        r_data:     out STD_LOGIC_VECTOR (7 downto 0);
        rx_flag:    out STD_LOGIC;
        rx:         in STD_LOGIC           -- Receive Data Pin
    );
end UART_RX;

architecture Behavioral of UART_RX is

constant CLOCK_FREQ: integer := 100000000;  -- 100 MHz Clock
constant BAUD_RATE: integer := 115200;        --115200 bps Baud Rate

signal rx_busy: STD_LOGIC := '0';           --receive data busy flag

signal received: STD_LOGIC_VECTOR (7 downto 0) := "00000000";

signal rx_bit_counter: integer range 0 to 8 := 0; --send/receive bit counter
signal rx_baud_counter: integer range 0 to (CLOCK_FREQ / BAUD_RATE) := 0;  --Baud Counter
signal rx_baud_flag: STD_LOGIC :='0';

type state_type is (rx_idle, rx_start, rx_data, rx_stop);
signal rx_next_state : state_type;
signal rx_current_state : state_type := rx_idle;

begin
---------------------------------------------------------------------------------
receive_work: process(rx_current_state,rx_baud_counter)
begin
if (rx_current_state = rx_idle) then
    rx_busy <= '0';
    rx_flag <= '0';
    rx_bit_counter <= 0;
elsif (rx_current_state = rx_start) then
    rx_busy <= '1';
elsif (rx_current_state = rx_data) then
    if rx_baud_counter = (CLOCK_FREQ / BAUD_RATE)/2 then
    received(rx_bit_counter) <= rx;
    rx_bit_counter <= rx_bit_counter + 1;
    end if;
elsif (rx_current_state = rx_stop) then
    rx_flag <= '1';
    r_data <= received;
end if;
end process receive_work;
---------------------------------------------------------------------------------
rx_state_process: process(rx_baud_flag,rx)
begin
if (rx_current_state = rx_idle) and (rx = '0') then
    rx_next_state <= rx_start;
elsif (rx_current_state = rx_start) and (rx_baud_flag = '1') then
    rx_next_state <= rx_data;
elsif (rx_current_state = rx_data) and (rx_bit_counter = 8) and (rx_baud_flag = '1') then
    rx_next_state <= rx_stop;
elsif (rx_current_state = rx_stop) and (rx = '1')and (rx_baud_flag = '1') then
    rx_next_state <= rx_idle;
end if;
end process rx_state_process;
rx_current_state <= rx_next_state;
---------------------------------------------------------------------------------
rx_baud_process: process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                rx_baud_counter <= 0;
            elsif rx_busy = '1' then
                if rx_baud_counter = (CLOCK_FREQ / BAUD_RATE - 1) then
                    rx_baud_counter <= 0;
                    rx_baud_flag <= '1';
                else
                    rx_baud_counter <= rx_baud_counter + 1;
                    rx_baud_flag <= '0';
                end if;
            else
                rx_baud_counter <= 0;
                rx_baud_flag <= '0';
            end if;
        end if;
    end process rx_baud_process;
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
end Behavioral;
