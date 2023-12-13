----------------------------------------------------------------------------------
-- Company: Yildiz Technical University
-- Engineer: Denizhan Yerel
-- 
-- Create Date: 12/04/2023 06:11:02 AM
-- Design Name: 
-- Module Name: tb_uartRx - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: uartRx
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity tb_uartRx is
    generic (
        clkfreq_p           : integer                       := 100_000_000;
        baudrate_p          : integer                       := 921600;
        bitduration_p       : time                          := 1.08 us
    );
end tb_uartRx;

architecture Behavioral of tb_uartRx is

    constant clkperiod_c	: time                          := 10 ns;
    constant payload0_c     : std_logic_vector(9 downto 0)  := '1' & x"AA" & '0';   
    constant payload1_c     : std_logic_vector(9 downto 0)  := '1' & x"DB" & '0';   
    constant payload2_c     : std_logic_vector(9 downto 0)  := '1' & x"75" & '0';   

    component uartRx is
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
    end component uartRx;

    signal clk_s            : std_logic                     := '0';
    signal uartRx_s         : std_logic                     := '1';
    signal dataout_s        : std_logic_vector(7 downto 0)  := (others => '0');
    signal rxDone_s         : std_logic                     := '0';

begin

    clk_gen : clk_s <= not clk_s after (clkperiod_c / 2);

    UUT : uartRx generic map (
        clkfreq_p       => clkfreq_p,
        baudrate_p      => baudrate_p
    )
    port map (
        clk_in          => clk_s,
        uartRx_in       => uartRx_s,
        data_out        => dataout_s,
        rxDone_out      => rxDone_s
    );

    stimuli : process begin

        wait for clkperiod_c * 10;
        for i in 0 to 9 loop
            uartRx_s <= payload0_c(i);
            wait for bitduration_p;
        end loop;

        wait for 10 us;
        for i in 0 to 9 loop
            uartRx_s <= payload1_c(i);
            wait for bitduration_p;
        end loop;

        wait for 20 us;
        for i in 0 to 9 loop
            uartRx_s <= payload2_c(i);
            wait for bitduration_p;
        end loop;

        wait for 30 us;
        report "Simulation complete" severity failure;
        
    end process;

end Behavioral;
