# UART Loopback Implementation on Xilinx FPGA

This is a simple application where a UART transmitter and a UART receiver are implemented on the FPGA fabric, using PL clocks to feed a baud rate generator.

The top level module has a user / control side (left-hand side interface) that can be connected to a UART to USB module to send and receive messages from a PC. The transmit / receive side (right-hand side interface) is inside the PL of the FPGA and in this application TX is conneceted to RX creating a loopback.

The current architecture is designed to work with a 100MHz PL clock and a 182500 Baud Rate. It was tested on the Digilent Zedboard. 