`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/28/2022 04:35:24 PM
// Design Name: 
// Module Name: bit32ALU_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bit32ALU_tb();
reg [31:0] A = 0;
reg sel = 0;
reg [5:0] adr = 0;
reg [3:0] opcode = 0;
reg [1:0] bsel = 0;
wire [31:0] out;
integer i;
reg clk;
bit32ALU bit32ALU_uut(A,sel,clk,adr,opcode,bsel,out);
initial begin
clk = 1'b0;
forever begin
#10 clk = !clk;
end
end
//fill memory with doubles, we are going to use add immediate to put a value into regB and then store it;
//first location is filled with 2, then each location is 2 + previous memory location
initial begin
sel = 1;
A = 2'b10;
for (i = 0; i <64; i = i + 1) begin
    //memory address set and add 2 to whatever is in register;
    adr = i;
    opcode = 4'b0111;
    #10;
    //save double to current adr;
    opcode = 4'b1110;
    #10;
    end
//test load double;
sel = 0;
adr = 45; //just a random number 
opcode = 4'b0110;
#10;
//test add,sub.mult, all ieee754 format using whatever values are in memory
//outputs of these are stored in the selected register, so a value will be carried along all of the operations instead of testing the same number across the board;
opcode = 4'b0000;
#10;
opcode = 4'b0001;
#10;
opcode = 4'b0010;
#10;
//testing and,or,STL,stl uses the memory adr set above;
opcode = 4'b0011;
#10;
opcode = 4'b0100;
#10;
opcode = 4'b0101;
#10;
//test store byte, lsb of regA;
opcode = 4'b1001;
#10;
//test load byte, into other register lsb;
sel = 1;
opcode = 4'b1010;
#10;
//shift left regB
opcode = 4'b1101;
#10;
//shift right arith regB
opcode = 4'b1111;
#10;
//set low immediate regA;
sel = 0;
opcode = 4'b1000;
#10;
//store word from A, then load into B;
opcode = 4'b1100;
#10;
sel = 1;
opcode = 4'b1011;
#10;
end

endmodule
