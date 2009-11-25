////////////////////////////////////////////////////////////////////////////////
//		
//	The MIT License
//
//	Copyright (c) 2009 Oscar Valdez
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
////////////////////////////////////////////////////////////////////////////////

package com.ozipi.cpu
{
	import com.ozipi.input.Input;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/**
	 * Class that emulates the intel8080   
	 * 
	 */
	public class Intel8080 implements IVram
	{
		//----------------------------------------------------------------------
		//
		//  Attributes
		//
		//----------------------------------------------------------------------
		protected var opcodeTable:Vector.<Function> = new Vector.<Function>(0x100,true);
		protected var _memory:ByteArray;
		
		protected var PC:int;
		protected var SP:int;
		protected var A:int;
		protected var B:int;
		protected var C:int;
		protected var D:int;
		protected var E:int;
		protected var H:int;
		protected var L:int;
		protected var BC:int;
		protected var DE:int;
		protected var HL:int;
		protected var SIGN:int;
		protected var ZERO:int;
		protected var HALFCARRY:int;
		protected var PARITY:int;
		protected var CARRY:int;
		protected var INTERRUPT:int;
		protected var CRASHED:int;
		
		private var BIT0:int = 1;
		private var BIT1:int = 2;
		private var BIT2:int = 4;
		private var BIT3:int = 8;
		private var BIT4:int = 16;
		private var BIT5:int = 32;
		private var BIT6:int = 64;
		private var BIT7:int = 128;
		private var BIT8:int = 255;
		
		protected var current_inst:int;
		
		protected var disassembly_pc:int;
		protected var debug_output:int;
		protected var debug_block:int = 0;
		
		//interrupt handling
		protected var interrupt_alternate:int;
		protected var count_instructions:int;
		
		//the input class handler
		protected var io:Input;

		//----------------------------------------------------------------------
		//
		//  Properties
		//
		//----------------------------------------------------------------------
		/** 
		 * Getter method for the memory property
		 **/
		public function get memory():ByteArray
		{
			return _memory;
		}
		
		//----------------------------------------------------------------------
		//
		//  Constructor
		//
		//----------------------------------------------------------------------
		public function Intel8080()
		{
		}
		
		//----------------------------------------------------------------------
		//
		//  Control methods
		//
		//----------------------------------------------------------------------
		/**
		 * Initalizes the instruction table and reset the registers 
		 * 
		 */
		public function initRegisters():void
		{
			Reset();
			InitTables();
		}
		
		/**
		 * Fetchs a byte var from memory
		 * @return 
		 * 
		 */
		protected function FetchRomByte():int
		{
			var b:int = _memory[PC];
			PC += 1;
			return b;
		}
		
		/**
		 * Fetchs a short var from memory
		 * @return 
		 * 
		 */
		protected function FetchRomShort():int
		{
			var s:int = _memory[PC+1] << 8 | _memory[PC];
			PC +=2;
			return s;
		}
		
		/**
		 * Reads a byte var from memory
		 *  
		 **/
		private function ReadByte(inAddress:int):int
		{
			return _memory[inAddress];	
		}
		
		/**
		 * Reads a short var from memory
		 *  
		 **/
		private function ReadShort(inAddress:int):int
		{
			return _memory[inAddress + 1] << 8 | _memory[inAddress];	
		}
		
		/**
		 * Writes a byte to memory
		 *  
		 **/
		private function WriteByte(inAddress:int, inByte:int):void
		{
			_memory[inAddress] = inByte;
		}
		
		/**
		 * Writes a byte to memory
		 *  
		 **/
		private function WriteShort(inAddress:int, inWord:int):void
		{
			_memory[inAddress+1] = inWord >> 8;
			_memory[inAddress] = inWord;
		}
		
		/**
		 * Push a value to the stack
		 *  
		 **/
		private function StackPush(inValue:int):void
		{
			SP -= 2;
			WriteShort(SP,inValue);
		}

		/**
		 * Pops a value to the stack
		 *  
		 **/
		private function StackPop():int
		{
			var temp:int = ReadShort(SP);
			SP += 2;
			return temp;
		}
		
		/**
		 * Interrup handling 
		 * @param inAddress
		 * 
		 */
		protected function CallInterrupt(inAddress:int):void
		{
			INTERRUPT = 0;
			StackPush(PC);
			PC = inAddress;
		}
		
		/**
		 * Resets all registers 
		 * 
		 */
		public function Reset():void
		{
			PC = 0;
			A = 0;
			BC = 0;
			DE = 0;
			HL = 0;
			SIGN = 0;
			ZERO = 0;
			HALFCARRY = 0;
			PARITY = 0;
			CARRY = 0;
			INTERRUPT = 0;
		}
		
		/**
		 * Sets all the instructions to the corresponding opcodes 
		 * 
		 */		
		protected function InitTables():void
		{
			opcodeTable[0x00] = Instruction_NOP;
			opcodeTable[0x01] = Instruction_LXI;
			opcodeTable[0x02] = Instruction_STA;
			opcodeTable[0x03] = Instruction_INX;
			opcodeTable[0x04] = Instruction_INC;
			opcodeTable[0x05] = Instruction_DEC;
			opcodeTable[0x06] = Instruction_MVI;
			opcodeTable[0x07] = Instruction_RLC;
			opcodeTable[0x09] = Instruction_DAD;
			opcodeTable[0x0A] = Instruction_LDA;
			opcodeTable[0x0B] = Instruction_DCX;
			opcodeTable[0x0C] = Instruction_INC;
			opcodeTable[0x0D] = Instruction_DEC;
			opcodeTable[0x0E] = Instruction_MVI;
			opcodeTable[0x0F] = Instruction_RRC;
			opcodeTable[0x11] = Instruction_LXI;
			opcodeTable[0x12] = Instruction_STA;
			opcodeTable[0x13] = Instruction_INX;
			opcodeTable[0x14] = Instruction_INC;
			opcodeTable[0x15] = Instruction_DEC;
			opcodeTable[0x16] = Instruction_MVI;
			opcodeTable[0x17] = Instruction_RAL;
			opcodeTable[0x19] = Instruction_DAD;
			opcodeTable[0x1A] = Instruction_LDA;
			opcodeTable[0x1B] = Instruction_DCX;
			opcodeTable[0x1C] = Instruction_INC;
			opcodeTable[0x1D] = Instruction_DEC;
			opcodeTable[0x1E] = Instruction_MVI;
			opcodeTable[0x1F] = Instruction_RAR;
			opcodeTable[0x21] = Instruction_LXI;
			opcodeTable[0x22] = Instruction_SHLD;
			opcodeTable[0x23] = Instruction_INX;
			opcodeTable[0x24] = Instruction_INC;
			opcodeTable[0x25] = Instruction_DEC;
			opcodeTable[0x26] = Instruction_MVI
			opcodeTable[0x27] = Instruction_DAA;
			opcodeTable[0x29] = Instruction_DAD;
			opcodeTable[0x2A] = Instruction_LHLD;
			opcodeTable[0x2B] = Instruction_DCX;
			opcodeTable[0x2C] = Instruction_INC;
			opcodeTable[0x2D] = Instruction_DEC;
			opcodeTable[0x2E] = Instruction_MVI;
			opcodeTable[0x2F] = Instruction_CMA;
			opcodeTable[0x31] = Instruction_LXI;
			opcodeTable[0x32] = Instruction_STA;
			opcodeTable[0x33] = Instruction_INX;
			opcodeTable[0x34] = Instruction_INC;
			opcodeTable[0x35] = Instruction_DEC;
			opcodeTable[0x36] = Instruction_MVI;
			opcodeTable[0x37] = Instruction_STC;
			opcodeTable[0x39] = Instruction_DAD;
			opcodeTable[0x3A] = Instruction_LDA;
			opcodeTable[0x3B] = Instruction_DCX;
			opcodeTable[0x3C] = Instruction_INC;
			opcodeTable[0x3D] = Instruction_DEC;
			opcodeTable[0x3E] = Instruction_MVI;
			opcodeTable[0x3F] = Instruction_CMC;
			opcodeTable[0x40] = Instruction_MOV;
			opcodeTable[0x41] = Instruction_MOV;
			opcodeTable[0x42] = Instruction_MOV;
			opcodeTable[0x43] = Instruction_MOV;
			opcodeTable[0x44] = Instruction_MOV;
			opcodeTable[0x45] = Instruction_MOV;
			opcodeTable[0x46] = Instruction_MOV;
			opcodeTable[0x47] = Instruction_MOV;
			opcodeTable[0x48] = Instruction_MOV;
			opcodeTable[0x49] = Instruction_MOV;
			opcodeTable[0x4A] = Instruction_MOV;
			opcodeTable[0x4B] = Instruction_MOV;
			opcodeTable[0x4C] = Instruction_MOV;
			opcodeTable[0x4D] = Instruction_MOV;
			opcodeTable[0x4E] = Instruction_MOV;
			opcodeTable[0x4F] = Instruction_MOV;
			opcodeTable[0x50] = Instruction_MOV;
			opcodeTable[0x51] = Instruction_MOV;
			opcodeTable[0x52] = Instruction_MOV;
			opcodeTable[0x53] = Instruction_MOV;
			opcodeTable[0x54] = Instruction_MOV;
			opcodeTable[0x55] = Instruction_MOV;
			opcodeTable[0x56] = Instruction_MOV;
			opcodeTable[0x57] = Instruction_MOV;
			opcodeTable[0x58] = Instruction_MOV;
			opcodeTable[0x59] = Instruction_MOV;
			opcodeTable[0x5A] = Instruction_MOV;
			opcodeTable[0x5B] = Instruction_MOV;
			opcodeTable[0x5C] = Instruction_MOV;
			opcodeTable[0x5D] = Instruction_MOV;
			opcodeTable[0x5E] = Instruction_MOV;
			opcodeTable[0x5F] = Instruction_MOV;
			opcodeTable[0x60] = Instruction_MOV;
			opcodeTable[0x61] = Instruction_MOV;
			opcodeTable[0x62] = Instruction_MOV;
			opcodeTable[0x63] = Instruction_MOV;
			opcodeTable[0x64] = Instruction_MOV;
			opcodeTable[0x65] = Instruction_MOV;
			opcodeTable[0x66] = Instruction_MOV;
			opcodeTable[0x67] = Instruction_MOV;
			opcodeTable[0x68] = Instruction_MOV;
			opcodeTable[0x69] = Instruction_MOV;
			opcodeTable[0x6A] = Instruction_MOV;
			opcodeTable[0x6B] = Instruction_MOV;
			opcodeTable[0x6C] = Instruction_MOV;
			opcodeTable[0x6D] = Instruction_MOV;
			opcodeTable[0x6E] = Instruction_MOV;
			opcodeTable[0x6F] = Instruction_MOV;
			opcodeTable[0x70] = Instruction_MOVHL;
			opcodeTable[0x71] = Instruction_MOVHL;
			opcodeTable[0x72] = Instruction_MOVHL;
			opcodeTable[0x73] = Instruction_MOVHL;
			opcodeTable[0x74] = Instruction_MOVHL;
			opcodeTable[0x75] = Instruction_MOVHL;
			opcodeTable[0x77] = Instruction_MOVHL;
			opcodeTable[0x78] = Instruction_MOV;
			opcodeTable[0x79] = Instruction_MOV;
			opcodeTable[0x7A] = Instruction_MOV;
			opcodeTable[0x7B] = Instruction_MOV;
			opcodeTable[0x7C] = Instruction_MOV;
			opcodeTable[0x7D] = Instruction_MOV;
			opcodeTable[0x7E] = Instruction_MOV;
			opcodeTable[0x7F] = Instruction_MOV;
			opcodeTable[0x80] = Instruction_ADD;
			opcodeTable[0x81] = Instruction_ADD;
			opcodeTable[0x82] = Instruction_ADD;
			opcodeTable[0x83] = Instruction_ADD;
			opcodeTable[0x84] = Instruction_ADD;
			opcodeTable[0x85] = Instruction_ADD;
			opcodeTable[0x86] = Instruction_ADD;
			opcodeTable[0x87] = Instruction_ADD;
			opcodeTable[0x88] = Instruction_ADC;
			opcodeTable[0x89] = Instruction_ADC;
			opcodeTable[0x8A] = Instruction_ADC;
			opcodeTable[0x8B] = Instruction_ADC;
			opcodeTable[0x8C] = Instruction_ADC;
			opcodeTable[0x8D] = Instruction_ADC;
			opcodeTable[0x8E] = Instruction_ADC;
			opcodeTable[0x8F] = Instruction_ADC;
			opcodeTable[0x90] = Instruction_SUB;
			opcodeTable[0x91] = Instruction_SUB;
			opcodeTable[0x92] = Instruction_SUB;
			opcodeTable[0x93] = Instruction_SUB;
			opcodeTable[0x94] = Instruction_SUB;
			opcodeTable[0x95] = Instruction_SUB;
			opcodeTable[0x96] = Instruction_SUB;
			opcodeTable[0x97] = Instruction_SUB;
			opcodeTable[0xA0] = Instruction_AND;
			opcodeTable[0xA1] = Instruction_AND;
			opcodeTable[0xA2] = Instruction_AND;
			opcodeTable[0xA3] = Instruction_AND;
			opcodeTable[0xA4] = Instruction_AND;
			opcodeTable[0xA5] = Instruction_AND;
			opcodeTable[0xA6] = Instruction_AND;
			opcodeTable[0xA7] = Instruction_AND;
			opcodeTable[0xA8] = Instruction_XOR;
			opcodeTable[0xA9] = Instruction_XOR;
			opcodeTable[0xAA] = Instruction_XOR;
			opcodeTable[0xAB] = Instruction_XOR;
			opcodeTable[0xAC] = Instruction_XOR;
			opcodeTable[0xAD] = Instruction_XOR;
			opcodeTable[0xAE] = Instruction_XOR;
			opcodeTable[0xAF] = Instruction_XOR;
			opcodeTable[0xB0] = Instruction_OR;
			opcodeTable[0xB1] = Instruction_OR;
			opcodeTable[0xB2] = Instruction_OR;
			opcodeTable[0xB3] = Instruction_OR;
			opcodeTable[0xB4] = Instruction_OR;
			opcodeTable[0xB5] = Instruction_OR;
			opcodeTable[0xB6] = Instruction_OR;
			opcodeTable[0xB7] = Instruction_OR;
			opcodeTable[0xB8] = Instruction_CMP;
			opcodeTable[0xB9] = Instruction_CMP;
			opcodeTable[0xBA] = Instruction_CMP;
			opcodeTable[0xBB] = Instruction_CMP;
			opcodeTable[0xBC] = Instruction_CMP;
			opcodeTable[0xBD] = Instruction_CMP;
			opcodeTable[0xBE] = Instruction_CMP;
			opcodeTable[0xBF] = Instruction_CMP;
			opcodeTable[0xC0] = Instruction_RET;
			opcodeTable[0xC1] = Instruction_POP;
			opcodeTable[0xC2] = Instruction_JMP;
			opcodeTable[0xC3] = Instruction_JMP;
			opcodeTable[0xC4] = Instruction_CALL;
			opcodeTable[0xC5] = Instruction_PUSH;
			opcodeTable[0xC6] = Instruction_ADD;
			opcodeTable[0xC7] = Instruction_RST;
			opcodeTable[0xC8] = Instruction_RET;
			opcodeTable[0xC9] = Instruction_RET;
			opcodeTable[0xCA] = Instruction_JMP;
			opcodeTable[0xCC] = Instruction_CALL;
			opcodeTable[0xCD] = Instruction_CALL;
			opcodeTable[0xCE] = Instruction_ADC;
			opcodeTable[0xCF] = Instruction_RST;
			opcodeTable[0xD0] = Instruction_RET;
			opcodeTable[0xD1] = Instruction_POP;
			opcodeTable[0xD2] = Instruction_JMP;
			opcodeTable[0xD3] = Instruction_OUTP;
			opcodeTable[0xD4] = Instruction_CALL;
			opcodeTable[0xD5] = Instruction_PUSH;
			opcodeTable[0xD6] = Instruction_SUB;
			opcodeTable[0xD7] = Instruction_RST;
			opcodeTable[0xD8] = Instruction_RET;
			opcodeTable[0xDA] = Instruction_JMP;
			opcodeTable[0xDB] = Instruction_INP;
			opcodeTable[0xDC] = Instruction_CALL;
			opcodeTable[0xDE] = Instruction_SBBI;
			opcodeTable[0xDF] = Instruction_RST;
			opcodeTable[0xE1] = Instruction_POP;
			opcodeTable[0xE3] = Instruction_XTHL;
			opcodeTable[0xE5] = Instruction_PUSH;
			opcodeTable[0xE6] = Instruction_AND;
			opcodeTable[0xE7] = Instruction_RST;
			opcodeTable[0xE9] = Instruction_PCHL;
			opcodeTable[0xEB] = Instruction_XCHG;
			opcodeTable[0xEE] = Instruction_XOR;
			opcodeTable[0xEF] = Instruction_RST;
			opcodeTable[0xF1] = Instruction_POP;
			opcodeTable[0xF2] = Instruction_JMP;
			opcodeTable[0xF3] = Instruction_DI;
			opcodeTable[0xF5] = Instruction_PUSH;
			opcodeTable[0xF6] = Instruction_OR;
			opcodeTable[0xF7] = Instruction_RST;
			opcodeTable[0xFA] = Instruction_JMP;
			opcodeTable[0xFB] = Instruction_EI;
			opcodeTable[0xFE] = Instruction_CMP;
			opcodeTable[0xFF] = Instruction_RST;
		}
		
		//----------------------------------------------------------------------
		//
		//  Instructions Methods
		//
		//----------------------------------------------------------------------
		protected function Instruction_NOP():void
		{
		}
		
		protected function Instruction_LXI():void
		{
			var data16:int = FetchRomShort();
			
			switch (current_inst)
			{
				case 0x01:
					SetBC(data16);
					break;
				case 0x11:
					SetDE(data16);
					break;
				case 0x21:
					SetHL(data16);
					break;
				case 0x31:
					SetSP(data16);
					break;		
			}	
		}
		
		protected function Instruction_JMP():void
		{
			var condition:Boolean = true;
			var data16:int = FetchRomShort();
			
			switch (current_inst)
			{
				case 0xC3:
					break;
				case 0xC2:
					condition = !ZERO;
					break;
				case 0xCA:
					condition = Boolean(ZERO);
					break;
				case 0xD2:
					condition = !CARRY;
					break;
				case 0xDA:
					condition = Boolean(CARRY);
					break;
				case 0xF2:
					condition = !SIGN;
					break;
				case 0xFA:
					condition = Boolean(SIGN);
					break;
			}
			
			if ( condition )
				PC = data16;
			
			//Disassembly(name + " " +current_inst.toString(16));
		}
		
		protected function Instruction_MVI():void
		{
			var data8:int = FetchRomByte();
			
			switch (current_inst)
			{
				case 0x3E:
					SetA(data8);
					break;
				case 0x06:
					SetB(data8);
					break;
				case 0x0E:
					SetC(data8);
					break;
				case 0x16:
					SetD(data8);
					break;
				case 0x1E:
					SetE(data8);
					break;
				case 0x26:
					SetH(data8);
					break;
				case 0x2E:
					SetL(data8);
					break;
				case 0x36:
					WriteByte(HL, data8);
					break;
			}
		}
		
		protected function Instruction_CALL():void
		{
			var condition:Boolean = true;
			var data16:int = FetchRomShort();
			
			switch (current_inst)
			{
				case 0xCD:
					
					break;
				case 0xC4:
					condition = !ZERO;
					break;
				case 0xCC:
					condition = Boolean(ZERO);
					break;
				case 0xD4:
					condition = !CARRY;
					break;
				case 0xDC:
					condition = Boolean(CARRY);
					break;		
			}	
			
			if (condition)
			{
				StackPush(PC);
				PC = data16;
			}
			
		}
		
		protected function Instruction_LDA():void
		{
			var source:int;
			
			switch (current_inst)
			{
				case 0x0A:
					source = BC;
					break;
				case 0x1A:
					source = DE;
					break;
				case 0x3A:
					source = FetchRomShort();
					break;
			}	
			
			SetA(ReadByte(source));
		}
		
		protected function Instruction_MOVHL():void
		{
			switch (current_inst)
			{
				case 0x77:
					WriteByte(HL,A);
					break;
				case 0x70:
					WriteByte(HL,B);
					break;
				case 0x71:
					WriteByte(HL,C);
					break;
				case 0x72:
					WriteByte(HL,D);
					break;		
				case 0x73:
					WriteByte(HL,E);
					break;
				case 0x74:
					WriteByte(HL,H);
					break;
				case 0x75:
					WriteByte(HL,L);
					break;
			}	
		}
		
		protected function Instruction_INX():void
		{
			switch (current_inst)
			{
				case 0x03:
					SetBC(BC+1);	
					break;
				case 0x13:
					SetDE(DE+1);
					break;
				case 0x23:
					SetHL(HL+1);
					break;
				case 0x33:
					SetSP(SP+1);
					break;		
			}	
		}
		
		protected function Instruction_DCX():void
		{
			switch (current_inst)
			{
				case 0x0B:
					SetBC(BC-1);
					break;
				case 0x1B:
					SetDE(DE-1);
					break;
				case 0x2B:
					SetHL(HL-1);
					break;
				case 0x3B:
					SetSP(SP-1);
					break;		
			}	
		}
		
		protected function Instruction_DEC():void
		{
			switch (current_inst)
			{
				case 0x3D:
					SetA(PerformDec(A));
					break;
				case 0x05:
					SetB(PerformDec(B));
					break;
				case 0x0D:
					SetC(PerformDec(C));
					break;
				case 0x15:
					SetD(PerformDec(D));
					break;		
				case 0x1D:
					SetE(PerformDec(E));
					break;
				case 0x25:
					SetH(PerformDec(H));
					break;
				case 0x2D:
					SetL(PerformDec(L));
					break;
				case 0x35:
					var data8:int = ReadByte(HL);
					WriteByte(HL, PerformDec(data8));
					break;		
				
			}	
		}
		
		protected function Instruction_INC():void
		{
			switch (current_inst)
			{
				case 0x3C:
					SetA(PerformInc(A));
					break;
				case 0x04:
					SetB(PerformInc(B));
					break;
				case 0x0C:
					SetC(PerformInc(C));
					break;
				case 0x14:
					SetD(PerformInc(D));
					break;		
				case 0x1C:
					SetE(PerformInc(E));
					break;
				case 0x24:
					SetH(PerformInc(H));
					break;
				case 0x2C:
					SetL(PerformInc(L));
					break;
				case 0x34:
					var data8:int = ReadByte(HL);
					WriteByte(HL, PerformInc(data8));
					break;		
				
			}	
		}
		
		protected function Instruction_RET():void
		{
			var condition:Boolean = true;
			switch (current_inst)
			{
				case 0xC9:
					
					break;
				case 0xC0:
					condition = !ZERO;
					break;
				case 0xC8:
					condition = Boolean(ZERO);
					break;
				case 0xD0:
					condition = !CARRY;
					break;
				case 0xD8:
					condition = Boolean(CARRY);
					break;
			}	
			
			if (condition) 
				PC = StackPop();
			
		}
		
		protected function Instruction_MOV():void
		{
			switch (current_inst)
			{
				//A
				case 0x7F:
					SetA(A);
					break;
				case 0x78:
					SetA(B);
					break;
				case 0x79:
					SetA(C);
					break;
				case 0x7A:
					SetA(D);
					break;
				case 0x7B:
					SetA(E);	
					break;
				case 0x7C:
					SetA(H);
					break;
				case 0x7D:
					SetA(L);
					break;
				case 0x7E:
					SetA(ReadByte(HL));
					break;
				
				//B	
				case 0x47:
					SetB(A);
					break;
				case 0x40:
					SetB(B);
					break;
				case 0x41:
					SetB(C);
					break;
				case 0x42:
					SetB(D);
					break;
				case 0x43:
					SetB(E);	
					break;
				case 0x44:
					SetB(H);
					break;
				case 0x45:
					SetB(L);
					break;
				case 0x46:
					SetB(ReadByte(HL));
					break;	
				
				//C
				case 0x4F:
					SetC(A);
					break;
				case 0x48:
					SetC(B);
					break;
				case 0x49:
					SetC(C);
					break;
				case 0x4A:
					SetC(D);
					break;
				case 0x4B:
					SetC(E);	
					break;
				case 0x4C:
					SetC(H);
					break;
				case 0x4D:
					SetC(L);
					break;
				case 0x4E:
					SetC(ReadByte(HL));
					break;
				
				//D	
				case 0x57:
					SetD(A);
					break;
				case 0x50:
					SetD(B);
					break;
				case 0x51:
					SetD(C);
					break;
				case 0x52:
					SetD(D);
					break;
				case 0x53:
					SetD(E);	
					break;
				case 0x54:
					SetD(H);
					break;
				case 0x55:
					SetD(L);
					break;
				case 0x56:
					SetD(ReadByte(HL));
					break;	
				
				//E	
				case 0x5F:
					SetE(A);
					break;
				case 0x58:
					SetE(B);
					break;
				case 0x59:
					SetE(C);
					break;
				case 0x5A:
					SetE(D);
					break;
				case 0x5B:
					SetE(E);	
					break;
				case 0x5C:
					SetE(H);
					break;
				case 0x5D:
					SetE(L);
					break;
				case 0x5E:
					SetE(ReadByte(HL));
					break;	
				
				//H
				case 0x67:
					SetH(A);
					break;
				case 0x60:
					SetH(B);
					break;
				case 0x61:
					SetH(C);
					break;
				case 0x62:
					SetH(D);
					break;
				case 0x63:
					SetH(E);	
					break;
				case 0x64:
					SetH(H);
					break;
				case 0x65:
					SetH(L);
					break;
				case 0x66:
					SetH(ReadByte(HL));
					break;
				
				//L	
				case 0x6F:
					SetL(A);
					break;
				case 0x68:
					SetL(B);
					break;
				case 0x69:
					SetL(C);
					break;
				case 0x6A:
					SetL(D);
					break;
				case 0x6B:
					SetL(E);	
					break;
				case 0x6C:
					SetL(H);
					break;
				case 0x6D:
					SetL(L);
					break;
				case 0x6E:
					SetL(ReadByte(HL));
					break;	
				
			}
		}
		
		protected function Instruction_CMP():void
		{
			var value:int = 0;
			
			switch (current_inst)
			{
				case 0xBF:
					value = A;
					break;
				case 0xB8:
					value = B;
					break;
				case 0xB9:
					value = C;
					break;
				case 0xBA:
					value = D;
					break;	
				case 0xBB:
					value = E;
					break;
				case 0xBC:
					value = H;
					break;
				case 0xBD:
					value = L;
					break;
				case 0xBE:
					value = ReadByte(HL);
					break;	
				case 0xFE:
					value = FetchRomByte();
					break;
			}	
			
			PerformCompSub(value);
		}
		
		protected function Instruction_PUSH():void
		{
			var value:int;
			
			switch (current_inst)
			{
				case 0xC5:
					value = BC;
					break;
				case 0xD5:
					value = DE;
					break;
				case 0xE5:
					value = HL;
					break;
				case 0xF5:
					value = (A << 8);
					if ( SIGN ) value |= 0x80;
					if ( ZERO ) value |= 0x40;
					if ( INTERRUPT ) value |= 0x20;
					if ( HALFCARRY ) value |= 0x10;
					if ( CARRY ) value |= 0x1;
					break;		
			}	
			
			StackPush(value);
		}
		
		protected function Instruction_POP():void
		{
			var value:int = StackPop();
			
			switch (current_inst)
			{
				case 0xC1:
					SetBC(value);
					break;
				case 0xD1:
					SetDE(value);
					break;
				case 0xE1:
					SetHL(value);
					break;
				case 0xF1:
					A = (value >> 8);
					SIGN = (value & 0x80);
					ZERO = (value & 0x40);
					INTERRUPT = (value & 0x20);
					HALFCARRY = (value & 0x10);
					CARRY = (value & 0x1);
					break;		
			}	
		}
		
		protected function Instruction_DAD():void
		{
			switch (current_inst)
			{
				case 0x09:
					AddHL(BC);
					break;
				case 0x19:
					AddHL(DE);
					break;
				case 0x29:
					AddHL(HL);
					break;
				case 0x39:
					AddHL(SP);
					break;		
			}	
		}
		
		protected function Instruction_XCHG():void
		{
			var temp:int = DE;
			SetDE(HL);
			SetHL(temp);
		}
		
		protected function Instruction_XTHL():void
		{
			var temp:int = H;
			SetH(ReadByte(SP+1));
			WriteByte(SP+1,temp);
			
			temp = L;
			SetL(ReadByte(SP));
			WriteByte(SP,temp);
			
		}
		
		protected function Instruction_OUTP():void
		{
			var port:int = FetchRomByte();
			//TODO add io support
			io.OutPutPort(port,A);
			
		}
		
		protected function Instruction_INP():void
		{
			var port:int = FetchRomByte();
			SetA(io.InputPort(port));
		}
		
		protected function Instruction_PCHL():void
		{
			PC = HL;
		}
		
		protected function Instruction_RST():void
		{
			var address:int;
			
			switch (current_inst)
			{
				case 0xC7:
					address = 0x0;
					break;
				case 0xCF:
					address = 0x8;
					break;
				case 0xD7:
					address = 0x10;
					break;
				case 0xDF:
					address = 0x18;
					break;
				case 0xE7:
					address = 0x20;
					break;
				case 0xEF:
					address = 0x28;
					break;
				case 0xF7:
					address = 0x30;
					break;
				case 0xFF:
					address = 0x38;
					break;
			}
			
			StackPush(PC);
			PC = address;
		}
		
		protected function Instruction_RLC():void
		{
			SetA((A << 1) | (A >> 7));
			CARRY = (A & 1);
		}
		
		protected function Instruction_RAL():void
		{
			var temp:int = A;
			SetA(A << 1);
			if(CARRY) SetA(A | 1);
			CARRY = (temp & 0x80);
			
		}
		
		protected function Instruction_RRC():void
		{
			SetA((A >> 1 ) | (A << 7 ));
			CARRY = (A & 0x80);
		}
		
		protected function Instruction_RAR():void
		{
			var temp:int = A & 0xFF;
			SetA( A >> 1 );
			if (CARRY) SetA( A | 0x80 );
			CARRY = (temp & 1);
		}
		
		protected function Instruction_AND():void
		{
			switch (current_inst)
			{
				case 0xA7:
					PerformAnd(A);
					break;
				case 0xA0:
					PerformAnd(B);
					break;
				case 0xA1:
					PerformAnd(C);
					break;
				case 0xA2:
					PerformAnd(D);
					break;
				case 0xA3:
					PerformAnd(E);
					break;
				case 0xA4:
					PerformAnd(H);
					break;
				case 0xA5:
					PerformAnd(L);
					break;
				case 0xA6:
					PerformAnd(ReadByte(HL));
					break;
				case 0xE6:
					var immediate:int = FetchRomByte();
					PerformAnd(immediate);
					break;
			}	
		}
		
		protected function Instruction_ADD():void
		{
			switch (current_inst)
			{
				case 0x87:
					PerformByteAdd(A);
					break;
				case 0x80:
					PerformByteAdd(B);
					break;
				case 0x81:
					PerformByteAdd(C);
					break;
				case 0x82:
					PerformByteAdd(D);
					break;
				case 0x83:
					PerformByteAdd(E);
					break;
				case 0x84:
					PerformByteAdd(H);
					break;
				case 0x85:
					PerformByteAdd(L);
					break;
				case 0x86:
					PerformByteAdd(ReadByte(HL));
					break;
				case 0xC6:
					var immediate:int = FetchRomByte();
					PerformByteAdd(immediate);
					break;
			}	
		}
		
		protected function Instruction_STA():void
		{
			switch (current_inst)
			{
				case 0x02:
					WriteByte(BC, A);
					break;
				case 0x12:
					WriteByte(DE, A);
					break;
				case 0x32:
					var inmediate:int = FetchRomShort();
					WriteByte(inmediate, A);
					break;
			}	
		}
		
		protected function Instruction_XOR():void
		{
			switch (current_inst)
			{
				case 0xAF:
					PerformXor(A);
					break;
				case 0xA8:
					PerformXor(B);
					break;
				case 0xA9:
					PerformXor(C);
					break;
				case 0xAA:
					PerformXor(D);
					break;
				case 0xAB:
					PerformXor(E);
					break;
				case 0xAC:
					PerformXor(H);
					break;
				case 0xAD:
					PerformXor(L);
					break;
				case 0xAE:
					PerformXor(ReadByte(HL));
					break;
				case 0xEE:
					var immediate:int = FetchRomByte();
					PerformXor(immediate);
					break;
			}				
		}
		
		protected function Instruction_DI():void
		{
			INTERRUPT = 0;
		}
		
		protected function Instruction_EI():void
		{
			INTERRUPT = 1;
		}
		
		protected function Instruction_STC():void
		{
			CARRY = 1;			
		}
		
		protected function Instruction_CMC():void
		{
			CARRY = int(!CARRY);	
		}
		
		protected function Instruction_OR():void
		{
			switch (current_inst)
			{
				case 0xB7:
					PerformOr(A);
					break;
				case 0xB0:
					PerformOr(B);
					break;
				case 0xB1:
					PerformOr(C);
					break;
				case 0xB2:
					PerformOr(D);
					break;
				case 0xB3:
					PerformOr(E);
					break;
				case 0xB4:
					PerformOr(H);
					break;
				case 0xB5:
					PerformOr(L);
					break;
				case 0xB6:
					PerformOr(ReadByte(HL));
					break;
				case 0xF6:
					var immediate:int = FetchRomByte();
					PerformOr(immediate);
					break;
			}				
		}
		
		protected function Instruction_SUB():void
		{
			switch (current_inst)
			{
				case 0x97:
					PerformByteSub(A);
					break;
				case 0x90:
					PerformByteSub(B);
					break;
				case 0x91:
					PerformByteSub(C);
					break;
				case 0x92:
					PerformByteSub(D);
					break;
				case 0x93:
					PerformByteSub(E);
					break;
				case 0x94:
					PerformByteSub(H);
					break;
				case 0x95:
					PerformByteSub(L);
					break;
				case 0x96:
					PerformByteSub(ReadByte(HL));
					break;
				case 0xD6:
					var immediate:int = FetchRomByte();
					PerformByteSub(immediate);
					break;
			}					
		}
		
		protected function Instruction_ADC():void
		{
			var carryvalue:int = 0;
			if ( CARRY ) carryvalue = 1;
			
			switch (current_inst)
			{
				case 0x8F:
					PerformByteAdd(A, carryvalue);
					break;
				case 0x88:
					PerformByteAdd(B, carryvalue);
					break;
				case 0x89:
					PerformByteAdd(C, carryvalue);
					break;
				case 0x8A:
					PerformByteAdd(D, carryvalue);
					break;
				case 0x8B:
					PerformByteAdd(E, carryvalue);
					break;
				case 0x8C:
					PerformByteAdd(H, carryvalue);
					break;
				case 0x8D:
					PerformByteAdd(L, carryvalue);
					break;
				case 0x8E:
					PerformByteAdd(ReadByte(HL), carryvalue);
					break;
				case 0xCE:
					var immediate:int = FetchRomByte();
					PerformByteAdd(immediate, carryvalue);
					break;
			}						
		}
		
		protected function Instruction_LHLD():void
		{
			var immediate:int = FetchRomShort();
			SetHL(ReadShort(immediate));
		}
		
		protected function Instruction_SHLD():void
		{
			var immediate:int = FetchRomShort();
			WriteShort(immediate, HL);			
		}
		
		protected function Instruction_SBBI():void
		{
			var immediate:int = FetchRomByte();
			var carryValue:int = 0;
			
			if (CARRY) carryValue = 1;
			PerformByteSub(immediate, carryValue);
		}
		
		protected function Instruction_DAA():void
		{
			if ( ((A & 0x0F) > 9 ) || (HALFCARRY))
			{
				A += 0x06;
				HALFCARRY = 1;
			}
			else
			{
				HALFCARRY = 0;
			}
			
			if ( (A > 0x9F) || (CARRY))
			{
				A += 0x06;
				CARRY = 1;
			}
			else
			{
				CARRY = 0;
			}
			
			setFlagZeroSign();
		}
		
		protected function Instruction_CMA():void
		{
			SetA(A ^ 0xFF);
		}
		
		//----------------------------------------------------------------------
		//
		//  Register Accessors
		//
		//----------------------------------------------------------------------
		/**
		 * When setting any register we use the & 0xFF operation to check
		 * the byte bounds and & 0xFFFF for the short types
		 **/
		protected function SetA(inByte:int):void
		{
			A = inByte & 0xFF;
		}
		protected function SetB(inByte:int):void
		{
			B = inByte & 0xFF;
			BC = (B << 8) | C;
		}
		protected function SetC(inByte:int):void
		{
			C = inByte & 0xFF;
			BC = (B << 8) | C;
		}
		protected function SetD(inByte:int):void
		{
			D = inByte & 0xFF;
			DE = (D << 8) | E;
		}
		protected function SetE(inByte:int):void
		{
			E = inByte & 0xFF;
			DE = (D << 8) | E;
		}
		protected function SetH(inByte:int):void
		{
			H = inByte & 0xFF;
			HL = (H << 8) | L;
		}
		protected function SetL(inByte:int):void
		{
			L = inByte & 0xFF;
			HL = (H << 8) | L;
		}
		protected function SetBC(inShort:int):void
		{
			BC = inShort & 0xFFFF;
			B = (BC >> 8);
			C = BC & 0xFF;
		}
		protected function SetDE(inShort:int):void
		{
			DE = inShort & 0xFFFF;
			D = (DE >> 8);
			E = DE & 0xFF;
		}
		protected function SetHL(inShort:int):void
		{
			HL = inShort & 0xFFFF;
			H = (HL >> 8);
			L = HL & 0xFF;
		}
		protected function SetSP(inShort:int):void
		{
			SP = inShort & 0xFFFF;
		}
		
		//----------------------------------------------------------------------
		//
		//  Helpers
		//
		//----------------------------------------------------------------------	
		protected function AddHL(inValue:int):void
		{
			var value:int = (HL + inValue);
			SetHL(value);
			
			CARRY = int(value > 0xFFFF);
		}		
		
		protected function PerformInc(inSource:int):int
		{
			var value:int = (inSource + 1) & 0xFF;
			HALFCARRY = int(((value & 0xF) != 0));
			ZERO = int((value & 255) == 0);
			SIGN = (value & 128) & 0xFF;
			return value;	
		}
		
		protected function PerformDec(inSource:int):int
		{
			var value:int = (inSource - 1) & 0xFF;
			HALFCARRY = int((value & 0xF) == 0);
			ZERO = int((value & 255) == 0);
			SIGN = (value & 128);
			return value;	
		}	
		
		protected function PerformCompSub(inValue:int):void
		{
			var value:int = (A - inValue) & 0xFF;
			CARRY = int(((value >= A) && (inValue)));
			HALFCARRY = ((A ^ inValue ^ value) & 0x10);
			ZERO = int((value == 0));
			SIGN = (value & 128);
		}
		
		protected function PerformAnd(inValue:int):void
		{
			SetA(A & inValue);
			CARRY = 0;
			HALFCARRY = 0;
			setFlagZeroSign();
		}
		
		protected function PerformOr(inValue:int):void
		{
			SetA(A | inValue);
			CARRY = 0;
			HALFCARRY = 0;
			setFlagZeroSign();
		}
		
		protected function PerformByteAdd(inValue:int, inCarryValue:int=0):void
		{
			var value:int = (A + inValue + inCarryValue) & 0xFF;
			HALFCARRY = ((A ^ inValue ^ value) & 0x10);
			SetA(value);
			CARRY = int(value > 255);
			setFlagZeroSign()
		}
		
		protected function PerformXor(inValue:int):void
		{
			SetA(A ^ inValue);
			CARRY = 0;
			HALFCARRY = 0;
			setFlagZeroSign();
			
		}
		
		protected function PerformByteSub(inValue:int, inCarryValue:int=0):void
		{
			var value:int = (A - inValue - inCarryValue) & 0xFF;
			
			CARRY = int((value >= A) && (inValue | inCarryValue));
			HALFCARRY = ((A ^ inValue ^ value) & 0x10);
			SetA(value);
			setFlagZeroSign();
		}
		
		protected function setFlagZeroSign():void
		{
			ZERO = int(A == 0);
			SIGN = (A & 0x80);
		}
	}
}