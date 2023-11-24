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
        red : OUT STD_LOGIC;
        green : OUT STD_LOGIC;
        blue : OUT STD_LOGIC
    );
END bat_n_ball;

ARCHITECTURE Behavioral OF bat_n_ball IS
    CONSTANT bsize : INTEGER := 8; -- ball size in pixels
    CONSTANT bat_w : INTEGER := 20; -- bat width in pixels
    CONSTANT bat_h : INTEGER := 3; -- bat height in pixels

    CONSTANT brickheight : INTEGER := 100;
    CONSTANT brickcols : INTEGER := 8; -- columns of bricks
    CONSTANT brickrows : INTEGER := 4; -- rows of bricks
    CONSTANT bricknums : INTEGER := 32;
    CONSTANT brickred : STD_LOGIC_VECTOR (31 DOWNTO 0) := "11100100101010100011000011011010";
    CONSTANT brickblu : STD_LOGIC_VECTOR (31 DOWNTO 0) := "10010111001001010111000001000101";
    CONSTANT brickgrn : STD_LOGIC_VECTOR (31 DOWNTO 0) := "00100001110100011001100111110100";
    SIGNAL brickon : STD_LOGIC_VECTOR (31 DOWNTO 0) := "11111111111111111111111111111111";

    CONSTANT ball_speed : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR (6, 11); -- distance ball moves each frame
    SIGNAL ball_on : STD_LOGIC; -- indicates whether ball is at current pixel position
    SIGNAL bat_on : STD_LOGIC; -- indicates whether bat at over current pixel position
    SIGNAL game_on : STD_LOGIC := '0'; -- indicates whether ball is in play

    -- current ball position - intitialized to center of screen
    SIGNAL ball_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11);
    SIGNAL ball_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);

    -- bat vertical position
    CONSTANT bat_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(500, 11);

    -- current ball motion - initialized to (+ ball_speed) pixels/frame in both X and Y directions
    SIGNAL ball_x_motion, ball_y_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := ball_speed;
    
BEGIN
    -- color setup for red ball and cyan bat on white background
    red <= NOT bat_on;
    green <= NOT ball_on;
    blue <= NOT ball_on;

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

    -- BEGIN Drawing bricks
    bricks : PROCESS (pixel_row, pixel_col) IS
        VARIABLE row : INTEGER := 0;
        VARIABLE col : INTEGER := 1;
        VARIABLE brk : INTEGER := 0;
    BEGIN
        row <= 0 when pixel_row < 25;
        row <= 1 when pixel_row < 50;
        row <= 2 when pixel_row < 75;
        row <= 3 when pixel_row < 100;
        col <= 0 when pixel_col < 100;
        col <= 1 when pixel_col < 200;
        col <= 2 when pixel_col < 300;
        col <= 3 when pixel_col < 400;
        col <= 4 when pixel_col < 500;
        col <= 5 when pixel_col < 600;
        col <= 6 when pixel_col < 700;
        col <= 7 when pixel_col < 800;
        brk <= row * 8 + col;
        IF (brickon(brk) = "1") THEN
            red <= brickred(brk);
            blue <= brickblu(brk);
            green <= brickgrn(brk);
        END IF
    END PROCESS
    -- END   Drawing bricks

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