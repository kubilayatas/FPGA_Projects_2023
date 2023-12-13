
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SevenSegmentDriver is
Port(
    clk: in STD_LOGIC;
    reset: in STD_LOGIC;
    enable: in STD_LOGIC;
    data: in STD_LOGIC_VECTOR(63 downto 0);
    AN: out STD_LOGIC_VECTOR(7 downto 0);
    SEG: out STD_LOGIC_VECTOR(7 downto 0)
    );
end SevenSegmentDriver;

architecture Behavioral of SevenSegmentDriver is
signal ascii: STD_LOGIC_VECTOR(7 downto 0);
signal sevseg: STD_LOGIC_VECTOR(7 downto 0) :="11111100";

constant CLOCK_FREQ :integer := 100000000; --100 MHz
constant REFRESH_FREQ :integer :=60; --Hz

signal count_time: integer :=0;
signal digit: integer range 0 to 8 :=0;
begin
------------------------------------------------------
work: process(clk,enable)
begin
if rising_edge(clk) then
    if reset ='1' then
        count_time <= 0;
        digit <= 0;
    elsif enable='1' then
        if (count_time = (CLOCK_FREQ / REFRESH_FREQ) -1) then
            count_time <= 0;
            digit <= digit + 1;
        else
            count_time <= count_time + 1;
        end if;
        if digit = 8 then digit <= 0; end if;
    else
        count_time <= 0;
        digit <= 0;
    end if;
end if;
end process;
-------------------------------------------------------
digitwork: process(digit)
begin
        case digit is
            when 0 => AN<="00000001"; ascii <= data(7 downto 0);
            when 1 => AN<="00000010"; ascii <= data(15 downto 8);
            when 2 => AN<="00000100"; ascii <= data(23 downto 16);
            when 3 => AN<="00001000"; ascii <= data(31 downto 24);
            when 4 => AN<="00010000"; ascii <= data(39 downto 32);
            when 5 => AN<="00100000"; ascii <= data(47 downto 40);
            when 6 => AN<="01000000"; ascii <= data(55 downto 48);
            when 7 => AN<="10000000"; ascii <= data(63 downto 56);
            when others => AN<="00000000";
        end case;
end process;
-------------------------------------------------------
SevSegConvert:process(ascii) is
begin
case ascii is
-----------------------------ABCDEFGp
-----------------------------||||||||
when x"20" => sevseg <=     "11111111"; --space
when x"30" => sevseg <=     "00000011"; --0
when x"31" => sevseg <=     "10011111"; --1
when x"32" => sevseg <=     "00100101"; --2
when x"33" => sevseg <=     "00001101"; --3
when x"34" => sevseg <=     "10011001"; --4
when x"35" => sevseg <=     "01001001"; --5
when x"36" => sevseg <=     "01000001"; --6
when x"37" => sevseg <=     "00011111"; --7
when x"38" => sevseg <=     "00000001"; --8
when x"39" => sevseg <=     "00001001"; --9
when x"41" => sevseg <=     "00010001"; --A
when x"42" => sevseg <=     "11000001"; --B
when x"43" => sevseg <=     "01100011"; --C
when x"44" => sevseg <=     "10000101"; --D
when x"45" => sevseg <=     "01100001"; --E
when x"46" => sevseg <=     "01110001"; --F
when x"47" => sevseg <=     "00001001"; --G
when x"48" => sevseg <=     "10010001"; --H
when x"49" => sevseg <=     "10011111"; --I
when x"4A" => sevseg <=     "10001111"; --J
when x"4C" => sevseg <=     "11100011"; --L
when x"4E" => sevseg <=     "00010011"; --N
when x"4F" => sevseg <=     "00000011"; --O
when x"50" => sevseg <=     "00110001"; --P
when x"52" => sevseg <=     "01110011"; --R
when x"53" => sevseg <=     "01001001"; --S
when x"54" => sevseg <=     "10011101"; --T
when x"55" => sevseg <=     "10000011"; --U
when x"59" => sevseg <=     "10011001"; --Y
when x"61" => sevseg <=     "00010001"; --a
when x"62" => sevseg <=     "11000001"; --b
when x"63" => sevseg <=     "01100011"; --c
when x"64" => sevseg <=     "10000101"; --d
when x"65" => sevseg <=     "01100001"; --e
when x"66" => sevseg <=     "01110001"; --f
when x"67" => sevseg <=     "00001001"; --g
when x"68" => sevseg <=     "10010001"; --h
when x"69" => sevseg <=     "10011111"; --i
when x"6A" => sevseg <=     "10001111"; --j
when x"6C" => sevseg <=     "11100011"; --l
when x"6E" => sevseg <=     "00010011"; --n
when x"6F" => sevseg <=     "00000011"; --o
when x"70" => sevseg <=     "00110001"; --p
when x"72" => sevseg <=     "01110011"; --r
when x"73" => sevseg <=     "01001001"; --s
when x"74" => sevseg <=     "10011101"; --t
when x"75" => sevseg <=     "10000011"; --u
when x"79" => sevseg <=     "10011001"; --y
when others => sevseg <=    "11111101"; --others
end case;
end process;
SEG <= sevseg;
---------------------------------------------------------
end Behavioral;
