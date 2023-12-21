# Final Project for CPE 487 : Brick Breaker

The objective of this project was to create an analog of the classic brick breaker game.
- Use the potentiometer to control the bat, which bounces that ball up on collision.
- Create a set of bricks at the top of the screen that break and bounce the ball down on collision with the ball.
  - 32 bricks as 4 rows of 8 with a width of 100 pixels and height of 40 pixels. 
- The game end when the ball hits the bottom wall.
- The game can be reset at the press of a button.

![Cool Icon](https://i.imgur.com/W8SYu7n.png)

![potentiometer](https://raw.githubusercontent.com/kevinwlu/dsd/master/Nexys-A7/Lab-6/knob.jpg)

## Structure

- The **brick** module is the top level module
  - The btn0 button starts the serve and activates the bricks.

- The **brickmaker** module is the individual brick component.
  - The *collision* process checks every frame if the ball is within the bounds of the brick.
    - If collision occurs, the brick is deactivated and the ball is bounced.
    - If the ball is being served, all the bricks are reactivated. 
  - The *brickdraw* process checks if the current pixel is within the bounds of the brick and sets the brick_on of that pixel. 
 
- The **bat_n_ball** module draws all the features on the screen
  - The *balldraw* process sets the ball_on of each pixel dependant on the ball's position and size.
  - The *batdraw* process sets the bat_on of each pixel dependant on the bat's position and size.
  - The *brickset* generator sets the initial properties and instatiates each of the 32 brick components.
    - The boundaries of each brick are determined at instatiation using the known heights and widths.
    - The bricks are given the position of the ball and current pixel. 

## Process

### 1. Create a new RTL project *brick* in Vivado Quick Start
 - Create eight new source files of file type VHDL called adc_if, bat_n_ball, brick, brickmaker, clk_wiz_0, clk_wiz_0_clk_wiz, leddec16, and vga_sync.

 - Create a new constraint file of file type XDC called brick

 - Choose Nexys A7-100T board for the project

 - Click 'Finish'

 - Click design sources and copy the VHDL code from adc_if.vhd, bat_n_ball.vhd, brick.vhd, brickmaker.vhd, clk_wiz_0.vhd, clk_wiz_0_clk_wiz.vhd, leddec16.vhd, and vga_sync.vhd.

 - Click constraints and copy the code from hexcalc.xdc

### 2. Run synthesis

### 3. Run implementation and open implemented design

### 4. Generate bitstream, open hardware manager, and program device

 - Click 'Generate Bitstream'

 - Click 'Open Hardware Manager' and click 'Open Target' then 'Auto Connect'

 - Click 'Program Device' then xc7a100t_0 to download hexcalc.bit to the Nexys A7-100T board

### 5. After successfully programming device, the screen should match the image below:
![Brick Breaker Running Successfully](brickbreaker_Layout.jpg)

## Modifications

This project was based off of Lab 6.

A) The *brickmaker* component is a completely new addition, and was added at the suggestion of Professor Yett.

B) The *bat_n_ball* component was modified to generate all of the bricks, and the coloring was modified to check for any of the bricks. 

C) The *leddec16* component is a modified version of the leddec.vhd file included in several labs, modified to display the score of the game in binary.

## Summary

The process itself was mostly a syntax and bugfixing challenge (as it usually is), since the concept and design was decided early on. 

Bryan Feighner - 
El Taylor - 
Ryan Piedrahita - 
