`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2022 05:45:26 PM
// Design Name: 
// Module Name: bit32ALU
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


module bit32ALU(A,sel,clk,adr, opcode,bsel,out);
input clk;
input [31:0] A;
input [3:0] opcode;
input [1:0] bsel;
output reg [31:0] out = 0;
input sel; //register select, 1 bit because only 2 register locations;
reg write,read,reset;
reg [31:0] write_d;
wire [31:0] read_d;
reg [31:0] tempreg[0:1]; //working register of 2 locations;
wire [31:0] multout,orout,andout,STLOut,STLOut2,sumout;
input [5:0] adr;
wire [31:0] sl,srl,sra;
Byte64Memory memreg(adr,clk,write,read,reset,write_d,read_d);
IEEEFPM mult1(tempreg[0],tempreg[1],multout);
AndMode and1(tempreg[0],tempreg[1],andout);
OrMode or1(tempreg[0],tempreg[1],orout);
SetOnLessThan stl(tempreg[0],tempreg[1],STLOut1);
SetOnLessThan stli(tempreg[sel],A,STLOut2);
IEEE754_Add add1(tempreg[0],tempreg[1],sumout);
ShiftLeft Sl(tempreg[0], tempreg[1], sl);
ShiftRightLogic S2(tempreg[0], tempreg[1], srl);
ShiftRightArithmatic S3(tempreg[0], tempreg[1], sra);
always @(clk) begin
case(opcode)
 //sum opcode
 4'b0000: begin
   out <= sumout;
   tempreg[sel] <= out;
   end
  //sub opcode
 4'b0001: begin
    tempreg[1][31] <= ~tempreg[1][31];
    out <= sumout;
    tempreg[sel] <= out;
    end
 //mult opcode
 4'b0010: begin
    out <= multout;
    tempreg[sel] <= out;
    end
 //and opcode
 4'b0011: begin
    out <= andout;  
    tempreg[sel] <= out;
    end
 //or opcode;
 4'b0100: begin
    out <= orout;
    tempreg[sel] <= out;
    end
 //STL opcode
 4'b0101: begin
    out <= 0;
    write <= 1;
    write_d <= STLOut1;
    write <= 0;
    end
  //loaddouble
 4'b0110: begin   
 read = 1;
 out <=  read_d[31:0];
 read = 0;
 end
 //addi, integer only
 4'b0111: begin
   out <= A + tempreg[sel];
   tempreg[sel] <= out;
   end
   //set on less than immediate;
4'b1000: begin
    out <= 0;
    write <= 1;
    write_d <= STLOut2;
    write <= 0;
    end
 //store byte
4'b1001: begin
    out <= 0;
    case(bsel)
    2'b00: begin
        write <= 1;
        write_d <= tempreg[sel][7:0];
        end
    2'b01: begin
        write <= 1;
        write_d <= tempreg[sel][15:8];
        end
    2'b10: begin
        write <= 1;
        write_d <= tempreg[sel][23:16];
        end
    2'b11: begin
        write <= 1;
        write_d <= tempreg[sel][31:23];
        end
        endcase
       write <= 0;
       end
 //load byte;
 4'b1010: begin
     out <= 0;
    case(bsel)
    2'b00: begin
        read <= 1;
        tempreg[sel][7:0] <= read_d;
        end
    2'b01: begin
        read <= 1;
        tempreg[sel][15:8] <= read_d;
        end
    2'b10: begin
        read <= 1;
        tempreg[sel][23:16] <= read_d;
        end
    2'b11: begin
        read <= 1;
        tempreg[sel][31:23] <= read_d;
        end
        endcase
        read <= 0;
       end
 //load word
4'b1011: begin
    read <= 1;
    tempreg[sel][15:0] <= read_d;
    read <= 0;
    end
//save word;
4'b1100:    begin
    write <= 1;
    write_d <= tempreg[sel][15:0];
    write <= 0;
    end
//shift left, shifts the selected register by the value in regB;
4'b1101: begin
    tempreg[sel] <= sl;
    end
 //savedouble
  4'b1110: begin   
 write <= 1;
 write_d <= tempreg[sel];
 write <= 0;
 end
//shift right arith, shifts the selected register by the value in regB;
4'b1111: begin
    tempreg[sel] <= sra;
    end
endcase
end   
endmodule
module IEEEFPM(A,B,prod);
input [31:0] A,B;
output reg [31:0] prod;
reg sign;
reg [23:0] manta,mantb;
reg [47:0] mantresult;
reg [23:0] mantres;
reg [7:0] expona,exponb,exponres;
reg As,Bs;
//sign bit;
always @(*)begin
    As = A[31];
    Bs = B[31];
     sign = As ^ Bs;
//get mantissas;
     manta = A[22:0];
     mantb = B[22:0];
     manta[23] = 1'b1;
     mantb[23] = 1'b1;
     mantresult = manta * mantb;
//get exponents;
     expona = A[30:23];
     exponb = B[30:23];
     exponres = (expona - 127) + (exponb - 127) + 127;
    if (~mantresult[47]) begin
         mantres = mantresult[45:23];
        end
    else begin
         mantres = mantresult[46:24];
         exponres = exponres + 1;
         end
     prod[30:23] = exponres;
     prod[22:0] = mantres;
     prod[31] = sign;
end
endmodule
module OrMode(A,B,Out);
//bitwise OR, or'ing each bit individually!
input [31:0] A,B;
output reg [31:0] Out =0;
always@(*) begin
    Out <= A | B;
    end
 endmodule
 
module AndMode(A,B,Out);
input [31:0] A,B;
output reg [31:0] Out =0;
always@(*) begin
    //bitwise AND;
    Out <= A & B;
    end
endmodule

module Byte64Memory(adr,clk,write_en,read_en,reset,write_data,read_data);
input [5:0] adr;
input clk;
input write_en;
input read_en;
input reset;
input [31:0] write_data;
output  reg[31:0] read_data = 0;
reg [31:0] memory [0:63]; //32 bit wide register, 64locations
integer i;
always@(posedge clk) begin
    if(reset) begin
    for(i=0; i <64; i=i+1) begin
        memory[i] <= 0;
        end
    end
    else begin
        if(write_en == 1 && read_en == 1) begin //prefer reading if both read and write asserted
        read_data = memory[adr];
        end
        //write to selected address
        else if(write_en == 1) begin
        memory[adr] = write_data;
        end
        //read from selected address
        else if (read_en == 1) begin
        read_data = memory[adr];
        end
    end
end
endmodule
module SetOnLessThan(A,B,out);
input [31:0] A,B;
output reg [31:0] out;
always @(*) begin
if (A < B) begin
out <= 1;
end
else begin
out <= 0;
end
end
endmodule
module IEEE754_Add(A,B,Sum);
input [31:0] A,B;
output reg [31:0] Sum;
reg [30:0] AbsA,AbsB;
reg [31:0] swap;
reg [7:0] expA,expB;
reg [7:0] expSum;
reg [7:0] Expdiff;
reg sigA,sigB;
reg [22:0] MA,MB;
reg [23:0] MSum;
reg [31:0] Ah,Bh;
always @(*) begin
AbsA = A[30:0];
AbsB = B[30:0];
Ah = A;
Bh = B;
//swap if A > B;
if (AbsA > AbsB) begin
swap = Ah;
Ah = Bh;
Bh = swap;
end
expA = A[30:23];
expB = B[30:23];
Expdiff = expA - expB;

sigA = A[31];
sigB = B[31];
MA = A[22:0];
MB = B[22:0];
MB = MB >> Expdiff;
if( sigA == sigB) begin
MSum = MA + MB;
end
else begin
MSum = MA - MB;
end
//need normalize?;
if(MSum[23] == 1) begin
expSum = expA + 1;
end
else begin
expSum = expA;
end
Sum[22:0] = MSum[22:0];
Sum[30:23] = expSum;
Sum[31] = sigA;
end
endmodule
module ShiftLeft(A,B,out);
input [31:0] A,B;
output reg [31:0] out = 0;
always @(*) begin
    out <= A << B;
    end
endmodule
module ShiftRightLogic(A,B,out);
input [31:0] A,B;
output reg [31:0] out = 0;
always @(*) begin
    out <= A >> B;
    end
endmodule
module ShiftRightArithmatic(A,B,out);
input [31:0] A,B;
output reg [31:0] out = 0;
always @(*) begin
    out <= A >>> B;
    end
endmodule

