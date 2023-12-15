LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY brick IS
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
        ball_x_motion : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        ball_y_motion : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        serve : IN STD_LOGIC;
        game_on : IN STD_LOGIC;
        ball_speed : IN STD_LOGIC_VECTOR (10 DOWNTO 0);
        brick_on : OUT STD_LOGIC
    );
END brick;

ARCHITECTURE Behavioral of brick IS
    SIGNAL brick_active : STD_LOGIC := '0';
    brickdraw : PROCESS (pixel_col, pixel_row) IS
    BEGIN
        IF (pixel_col >= left_b)  AND 
           (pixel_col < right_b)  AND 
           (pixel_row >= top_b)   AND 
           (pixel_row < bottom_b) AND
           (brick_active = '1')   THEN
            -- do nothing
        ELSE
            brick_on <= '1';
        END IF;
    END PROCESS;

    collision : PROCESS
    BEGIN
        WAIT UNTIL rising_edge(v_sync);
        IF serve = '1' AND game_on = '0' THEN -- Start game
            brick_active <= '1';
        ELSIF (ball_x >= left_b AND ball_x <= right_b)
              (ball_y >= top_b AND ball_y <= (bottom_b + 5)) THEN -- Bounce off bottom side
            ball_y_motion <= ball_speed;
        --ELSIF () -- Bounce off top side
        --ELSIF () -- Bounce off left side
        --ELSIF () -- Bounce off right side
        END IF;
    END PROCESS;
END Behavioral;