LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY brickmaker IS
    PORT (
        v_sync : IN STD_LOGIC;
        pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        left_b : IN INTEGER;
        right_b : IN INTEGER;
        top_b : IN INTEGER;
        bottom_b : IN INTEGER;
        ball_x : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        ball_y : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        ball_bounce_bottom : OUT STD_LOGIC;
        ball_bounce_top : OUT STD_LOGIC;
        ball_bounce_right : OUT STD_LOGIC;
        ball_bounce_left : OUT STD_LOGIC;
        serve : IN STD_LOGIC;
        game_on : IN STD_LOGIC;
        ball_speed : IN STD_LOGIC_VECTOR (10 DOWNTO 0);
        brick_on : OUT STD_LOGIC;
        ball_x_motion_test : IN STD_LOGIC_VECTOR ( 10 downto 0);
        ball_y_motion_test : IN STD_LOGIC_VECTOR ( 10 downto 0)
    );
END brickmaker;

ARCHITECTURE Behavioral of brickmaker IS
    SIGNAL brick_active : STD_LOGIC := '0';
    SIGNAL once : STD_LOGIC := '0';
    BEGIN
    brickdraw : PROCESS(pixel_col, pixel_row) IS
    BEGIN
        IF (pixel_col >= left_b) AND 
           (pixel_col < right_b) AND 
           (pixel_row >= top_b) AND 
           (pixel_row < bottom_b) AND
           (brick_active = '1') THEN
            brick_on <= '1';
        ELSE
            brick_on <= '0';
        END IF;
    END PROCESS;

    collision : PROCESS
    BEGIN
        WAIT UNTIL rising_edge(v_sync);
        IF serve = '1' AND game_on = '0' THEN -- Start game
            brick_active <= '1';
            ball_bounce_bottom <= '0';
            ball_bounce_top <= '0';
            ball_bounce_right <= '0';
            ball_bounce_left <= '0';
            once <= '0';
            ELSIF once = '1' then
            ball_bounce_bottom <= '0'; 
            ball_bounce_top <= '0'; 
            ball_bounce_right <= '0';  
            ball_bounce_left <= '0';
               -- if ball_y_motion_test > "0" then
                --   ball_bounce_bottom <= '0'; 
               -- elsif ball_y_motion_test < "0" then 
               --    ball_bounce_top <= '0';   
              --  elsif ball_x_motion_test > "0" then
               --    ball_bounce_right <= '0';   
               -- elsif ball_x_motion_test < "0" then
                --   ball_bounce_left <= '0';
                 --END IF;  
            ELSIF (ball_x+8 >= right_b-5 AND ball_x-8 <= right_b+5) AND
                  (ball_y-8 >= top_b AND ball_y+8 <= (bottom_b)) THEN
                   ball_bounce_right <= '1';
                   once <= '1';
                   brick_active <= '0';
                   
              ELSIF (ball_x+8 >= left_b-5 AND ball_x-8 <= left_b+5) AND
                  (ball_y-8 >= top_b AND ball_y+8 <= (bottom_b)) THEN
                   ball_bounce_left <= '1';
                   once <= '1';
                   brick_active <= '0';
                   
            ELSIF (ball_x+8 >= left_b AND ball_x-8 <= right_b) AND
                  (ball_y+8 >= top_b-5 AND ball_y-8 <= (bottom_b)) 
                  AND (ball_y_motion_test > "0") THEN -- Bounce off bottom side
                   ball_bounce_bottom <= '1';
                   once <= '1';
                   brick_active <= '0';
            
            ELSIF (ball_x+8 >= left_b AND ball_x-8 <= right_b) AND
                  (ball_y+8 <= top_b AND ball_y-8 >= (top_b+5)) 
                  AND (ball_y_motion_test < "0") THEN
                   ball_bounce_top <= '1';
                   once <= '1';
                   brick_active <= '0';
                   
             
        END IF;
    END PROCESS;
END Behavioral;
