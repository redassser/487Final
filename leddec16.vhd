LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY leddec16 IS
    PORT (
   	 dig : IN STD_LOGIC_VECTOR (2 DOWNTO 0); -- which digit to currently display
   	 data : IN STD_LOGIC_VECTOR (7 DOWNTO 0); -- 8-bit data
   	 anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- which anode to turn on
   	 seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)); -- segment code for current digit
   	 
END leddec16;

ARCHITECTURE Behavioral OF leddec16 IS
SIGNAL data4 : STD_LOGIC;
BEGIN
   data4 <= data(0) WHEN dig = "000" ELSE -- digit 0
         	data(1) WHEN dig = "001" ELSE -- digit 1
         	data(2) WHEN dig = "010" ELSE -- digit 2
         	data(3) WHEN dig = "011" ELSE -- digit 3
         	data(4) WHEN dig = "100" ELSE -- digit 4
         	data(5) WHEN dig = "101" ELSE -- digit 5
            data(6) WHEN dig = "111" ELSE -- digit 6
         	data(7);
    
        -- Turn on segments corresponding to 4-bit data word
    seg <= "0000001" WHEN data4 = '0' ELSE -- 0
       	   "1001111" WHEN data4 = '1' ELSE -- 1
       	   "1111111";
    -- Turn on anode of 7-segment display addressed by 3-bit digit selector dig
    anode <= "11111110" WHEN dig = "000" ELSE -- 0
         	"11111101" WHEN dig = "001" ELSE -- 1
         	"11111011" WHEN dig = "010" ELSE -- 2
         	"11110111" WHEN dig = "011" ELSE -- 3
           	"11101111" WHEN dig = "100" ELSE -- 4
           	"11011111" WHEN dig = "101" ELSE -- 5
           	"10111111" WHEN dig = "110" ELSE -- 6
           	"01111111" WHEN dig = "111" ELSE -- 7
         	"11111111";
END Behavioral;
