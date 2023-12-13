----------------------------------------------------------------------------------
-- Company: Yildiz Technical University
-- Engineer: Denizhan Yerel
-- 
-- Create Date: 12/04/2023 05:11:03 AM
-- Design Name: 
-- Module Name: uartRx - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity uartRx is
    generic (
        clkfreq_p       : integer := 1e8;
        baudrate_p      : integer := 115200
    );
    Port (
        clk_in          : in    std_logic;
        uartRx_in       : in    std_logic;
        data_out        : out   std_logic_vector(7 downto 0);
        rxDone_out      : out   std_logic
    );
end uartRx;

architecture Behavioral of uartRx is

    type uartstate_t is (S_IDLE, S_START, S_RECEIVE, S_STOP);

    constant bittimer_c         : integer                           := clkfreq_p / baudrate_p;
    constant bittimerLim_c      : integer                           := bittimer_c - 1;
    constant bittimeHalfLim_c   : integer                           := (bittimer_c / 2) - 1;
    
    signal state_s              : uartstate_t                       := S_IDLE;
    signal bittimer_s           : integer range 0 to bittimer_c     := 0;
    signal bitcounter_s         : integer                           := 0;
    signal buffer_s             : std_logic_vector(7 downto 0)      := (others => '0');


begin

    statecntrl : process (clk_in)
    begin
        if rising_edge(clk_in) then
            case state_s is
                when S_IDLE =>
                    rxDone_out              <= '0';
                    bittimer_s              <= 0;

                    if uartRx_in = '0' then
                        state_s             <= S_START;
                    end if;

                when S_START =>
                    if (bittimer_s = bittimeHalfLim_c) then
                        state_s             <= S_RECEIVE;
                        bittimer_s          <= 0;
                    else
                        bittimer_s          <= bittimer_s + 1;
                    end if;

                when S_RECEIVE =>
                    if (bittimer_s = bittimerLim_c) then
                        buffer_s            <= uartRx_in & buffer_s(7 downto 1);
                        bittimer_s          <= 0;
                        if bitcounter_s = 7 then
                            bitcounter_s    <= 0;
                            state_s         <= S_STOP;
                        else
                            bitcounter_s    <= bitcounter_s + 1;
                        end if;
                    else
                        bittimer_s          <= bittimer_s + 1;
                    end if;

                when S_STOP =>
                    if (bittimer_s = bittimerLim_c) then
                        bittimer_s          <= 0;
                        state_s             <= S_IDLE;
                        rxDone_out          <= '1';
                        data_out            <= buffer_s;
                    else
                        bittimer_s          <= bittimer_s + 1;
                    end if;
                    
                when others =>
                    null;

            end case;
        end if;
    end process;


end Behavioral;
