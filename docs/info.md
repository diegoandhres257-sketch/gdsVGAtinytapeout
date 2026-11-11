<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project generates five concentric rings on a VGA display using Verilog HDL.

Each ring is divided into eight equal angular sectors. One sector is highlighted at a time, creating a rotating animation.

The first, third, and fifth rings rotate clockwise, while the second and fourth rings rotate counterclockwise.

The rings use flat matte colors and a black background. Their circular geometry is generated from pixel coordinates.

The animation advances automatically using a frame counter synchronized with the VGA signal.

## How to test

Connect the design to a compatible VGA display or simulator.

Apply the required clock signal.

Release the active-low reset.

Verify that five concentric rings appear on the screen.

Check that the highlighted sectors move sequentially.

Verify that adjacent rings rotate in opposite directions.

Confirm that all eight sectors have equal angular dimensions and that the animation repeats continuously.

## External hardware

List external hardware used in your project (e.g. PMOD, LED display, etc), if any
