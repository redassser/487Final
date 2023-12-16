LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY bat_n_ball IS
    PORT (
        v_sync : IN STD_LOGIC;
        pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        bat_x : IN STD_LOGIC_VECTOR (10 DOWNTO 0); -- current bat x position set by adc
        serve : IN STD_LOGIC; -- down button initiates serve
        red : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        green : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        blue : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
    );
END bat_n_ball;

ARCHITECTURE Behavioral OF bat_n_ball IS
    CONSTANT bsize : INTEGER := 8; -- ball size in pixels
    CONSTANT bat_w : INTEGER := 20; -- bat width in pixels
    CONSTANT bat_h : INTEGER := 3; -- bat height in pixels

    CONSTANT brickcols : INTEGER := 8; -- columns of bricks
    CONSTANT brickrows : INTEGER := 4; -- rows of bricks
    CONSTANT bricknums : INTEGER := 32;
    CONSTANT brickw : INTEGER := 100;
    CONSTANT brickh : INTEGER := 40;

    CONSTANT ball_speed : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR (6, 11); -- distance ball moves each frame
    SIGNAL ball_on : STD_LOGIC; -- indicates whether ball is at current pixel position
    SIGNAL bat_on : STD_LOGIC; -- indicates whether bat at over current pixel position
    SIGNAL brick_on : STD_LOGIC := '0';
    SIGNAL game_on : STD_LOGIC := '0'; -- indicates whether ball is in play

    -- current ball position - intitialized to center of screen
    SIGNAL ball_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11);
    SIGNAL ball_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);

    -- bat vertical position
    CONSTANT bat_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(500, 11);

    -- current ball motion - initialized to (+ ball_speed) pixels/frame in both X and Y directions
    SIGNAL ball_x_motion, ball_y_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := ball_speed;

    SIGNAL colorcode : STD_LOGIC_VECTOR(11 DOWNTO 0);
    CONSTANT ball_color : STD_LOGIC_VECTOR(11 DOWNTO 0) := "111100000000";
    CONSTANT bat_color : STD_LOGIC_VECTOR(11 DOWNTO 0) := "000000001111";
    CONSTANT brick_color : STD_LOGIC_VECTOR(11 DOWNTO 0) := "000011110000";
    CONSTANT bg_color : STD_LOGIC_VECTOR(11 DOWNTO 0) := "000000000000";


    component brick is 
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
            brick_on : OUT STD_LOGIC;
            brick_color : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
        );
    end component brick;
BEGIN
    -- color setup for red ball and cyan bat on white background
    red <= colorcode(11 DOWNTO 8);
    green <= colorcode(7 DOWNTO 4);
    blue <= colorcode(3 DOWNTO 0);

    colors : PROCESS (pixel_row, pixel_col) IS
    BEGIN
        IF ball_on = '1' THEN
            colorcode <= ball_color;
        ELSIF bat_on = '1' THEN
            colorcode <= bat_color;
        ELSIF brick_on = '1' THEN
            colorcode <= brick_color;
        ELSE 
            colorcode <= bg_color;
        END IF;
    END PROCESS;

    -- BEGIN Drawing round ball
    balldraw : PROCESS (ball_x, ball_y, pixel_row, pixel_col) IS
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    BEGIN
        IF pixel_col <= ball_x THEN -- vx = |ball_x - pixel_col|
            vx := ball_x - pixel_col;
        ELSE
            vx := pixel_col - ball_x;
        END IF;
        IF pixel_row <= ball_y THEN -- vy = |ball_y - pixel_row|
            vy := ball_y - pixel_row;
        ELSE
            vy := pixel_row - ball_y;
        END IF;
        IF ((vx * vx) + (vy * vy)) < (bsize * bsize) THEN -- test if radial distance < bsize
            ball_on <= game_on;
        ELSE
            ball_on <= '0';
        END IF;
    END PROCESS;
    -- END  Drawing round ball
    
    -- BEGIN Drawing bat
    batdraw : PROCESS (bat_x, pixel_row, pixel_col) IS
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    BEGIN
        IF ((pixel_col >= bat_x - bat_w) OR (bat_x <= bat_w)) AND
         pixel_col <= bat_x + bat_w AND
             pixel_row >= bat_y - bat_h AND
             pixel_row <= bat_y + bat_h THEN
                bat_on <= '1';
        ELSE
            bat_on <= '0';
        END IF;
    END PROCESS;
    -- END  Drawing bats

    brickset: for i in 0 to bricknums generate
    BEGIN
        bricks: brick
        port map(
            v_sync => v_sync;
            pixel_row => pixel_row;
            pixel_col => pixel_col;
            ball_x => ball_x;
            ball_y => ball_y;
            ball_x_motion => ball_x_motion;
            ball_y_motion => ball_y_motion;
            serve => serve;
            ball_speed => ball_speed;
            ball_on => ball_on;
            game_on => game_on;
            brick_on => brick_on;
            left_b => brickw * i;
            right_b => brickw * (i+1);
            top_b => brickh * i;
            bottom_b => brickg * (i+1)
        );
    end generate brickset;

    -- BEGIN Moving ball and detecting collisions
    mball : PROCESS
        VARIABLE temp : STD_LOGIC_VECTOR (11 DOWNTO 0);
    BEGIN
        WAIT UNTIL rising_edge(v_sync);

        IF serve = '1' AND game_on = '0' THEN -- test for new serve
            game_on <= '1';
            ball_y_motion <= (NOT ball_speed) + 1; 
            -- set vspeed to (- ball_speed) pixels
        ELSIF ball_y <= bsize THEN -- bounce off top wall
            ball_y_motion <= ball_speed; 
            -- set vspeed to (+ ball_speed) pixels
        ELSIF ball_y + bsize >= 600 THEN -- end game on bottom wall
            ball_y_motion <= (NOT ball_speed) + 1; 
            -- set vspeed to (- ball_speed) pixels
            game_on <= '0'; -- end game
        END IF;
        
        -- allow for bounce off left or right of screen
        IF ball_x + bsize >= 800 THEN -- bounce off right wall
            ball_x_motion <= (NOT ball_speed) + 1; 
            -- set hspeed to (- ball_speed) pixels
        ELSIF ball_x <= bsize THEN -- bounce off left wall
            ball_x_motion <= ball_speed; 
            -- set hspeed to (+ ball_speed) pixels
        END IF;

        -- allow for bounce off bat
        IF (ball_x + bsize/2) >= (bat_x - bat_w) AND
         (ball_x - bsize/2) <= (bat_x + bat_w) AND
             (ball_y + bsize/2) >= (bat_y - bat_h) AND
             (ball_y - bsize/2) <= (bat_y + bat_h) THEN
                ball_y_motion <= (NOT ball_speed) + 1; -- set vspeed to (- ball_speed) pixels
        END IF;

        -- compute next ball vertical position
        -- variable temp adds one more bit to calculation to fix unsigned underflow problems
        -- when ball_y is close to zero and ball_y_motion is negative
        temp := ('0' & ball_y) + (ball_y_motion(10) & ball_y_motion);
        IF game_on = '0' THEN
            ball_y <= CONV_STD_LOGIC_VECTOR(440, 11);
        ELSIF temp(11) = '1' THEN
            ball_y <= (OTHERS => '0');
        ELSE ball_y <= temp(10 DOWNTO 0); -- 9 downto 0
        END IF;

        -- compute next ball horizontal position
        -- variable temp adds one more bit to calculation to fix unsigned underflow problems
        -- when ball_x is close to zero and ball_x_motion is negative
        temp := ('0' & ball_x) + (ball_x_motion(10) & ball_x_motion);
        IF temp(11) = '1' THEN
            ball_x <= (OTHERS => '0');
        ELSE ball_x <= temp(10 DOWNTO 0);
        END IF;
    END PROCESS;
    -- END  Moving ball and detecting collisions
END Behavioral;
