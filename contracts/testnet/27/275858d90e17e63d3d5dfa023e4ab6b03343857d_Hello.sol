/**
 *Submitted for verification at BscScan.com on 2022-03-25
*/

// SPDX-License-Identifier: GPL-3.0

// pragma solidity 0.8.13;
// pragma solidity >=0.8.0;
pragma solidity >=0.8.0 <=0.8.10;

contract Hello {
    
    // تعریف متغیرها - State Variables
    string public helloStr;

    // تعریف فانکشن ها  - Functions

    // سازنده - Constructor
    constructor() {
        // دستورات خاصی که فقط یک بار در مرحله دپلوی کانترکت باید انجام شوند
        // مثل گرفتن آدرس مالک یا همان دپلوی کننده کانترکت
        // یا مثل تعیین تعداد اولیه توکن یا مینت توکن

        // مقداردهی اولیه متغیرها
        helloStr = "Hello World!";
    }

    // فانکشن های دیگر
}

contract Hello2 {

}


// این خط از کد مربوط به ذخیره اطلاعات است

/*  
    این خط از کد 
    مربوط به 
    ذخیره اطلاعات است
*/



/*
    Access Modifiers:
        public:     دسترسی از خود کانترکت و خارج از کانترکت
        private:    دسترسی فقط از داخل کانترکت
        internal:   دسترسی از داخل کانترکت و کانترکت های دیگری که از این کانترکت ارث برده اند
        external:   فقط از خارج از کانترکت - فقط برای توابع کاربرد دارد
*/


/*
    بعد از دپلوی شدن کانترکت، برای اتصال به کانترکت و فراخوانی فانکشن های آن نیاز به موارد زیر داریم
        Address: 0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8
        ABI: 
                [
                    {
                        "inputs": [],
                        "stateMutability": "nonpayable",
                        "type": "constructor"
                    },
                    {
                        "inputs": [],
                        "name": "helloStr",
                        "outputs": [
                            {
                                "internalType": "string",
                                "name": "",
                                "type": "string"
                            }
                        ],
                        "stateMutability": "view",
                        "type": "function"
                    }
                ]

*/


/*
    Byte Code:
    
    {
	"functionDebugData": {
		"@_11": {
			"entryPoint": null,
			"id": 11,
			"parameterSlots": 0,
			"returnSlots": 0
		},
		"extract_byte_array_length": {
			"entryPoint": 308,
			"id": null,
			"parameterSlots": 1,
			"returnSlots": 1
		},
		"panic_error_0x22": {
			"entryPoint": 261,
			"id": null,
			"parameterSlots": 0,
			"returnSlots": 0
		}
	},
	"generatedSources": [
		{
			"ast": {
				"nodeType": "YulBlock",
				"src": "0:516:1",
				"statements": [
					{
						"body": {
							"nodeType": "YulBlock",
							"src": "35:152:1",
							"statements": [
								{
									"expression": {
										"arguments": [
											{
												"kind": "number",
												"nodeType": "YulLiteral",
												"src": "52:1:1",
												"type": "",
												"value": "0"
											},
											{
												"kind": "number",
												"nodeType": "YulLiteral",
												"src": "55:77:1",
												"type": "",
												"value": "35408467139433450592217433187231851964531694900788300625387963629091585785856"
											}
										],
										"functionName": {
											"name": "mstore",
											"nodeType": "YulIdentifier",
											"src": "45:6:1"
										},
										"nodeType": "YulFunctionCall",
										"src": "45:88:1"
									},
									"nodeType": "YulExpressionStatement",
									"src": "45:88:1"
								},
								{
									"expression": {
										"arguments": [
											{
												"kind": "number",
												"nodeType": "YulLiteral",
												"src": "149:1:1",
												"type": "",
												"value": "4"
											},
											{
												"kind": "number",
												"nodeType": "YulLiteral",
												"src": "152:4:1",
												"type": "",
												"value": "0x22"
											}
										],
										"functionName": {
											"name": "mstore",
											"nodeType": "YulIdentifier",
											"src": "142:6:1"
										},
										"nodeType": "YulFunctionCall",
										"src": "142:15:1"
									},
									"nodeType": "YulExpressionStatement",
									"src": "142:15:1"
								},
								{
									"expression": {
										"arguments": [
											{
												"kind": "number",
												"nodeType": "YulLiteral",
												"src": "173:1:1",
												"type": "",
												"value": "0"
											},
											{
												"kind": "number",
												"nodeType": "YulLiteral",
												"src": "176:4:1",
												"type": "",
												"value": "0x24"
											}
										],
										"functionName": {
											"name": "revert",
											"nodeType": "YulIdentifier",
											"src": "166:6:1"
										},
										"nodeType": "YulFunctionCall",
										"src": "166:15:1"
									},
									"nodeType": "YulExpressionStatement",
									"src": "166:15:1"
								}
							]
						},
						"name": "panic_error_0x22",
						"nodeType": "YulFunctionDefinition",
						"src": "7:180:1"
					},
					{
						"body": {
							"nodeType": "YulBlock",
							"src": "244:269:1",
							"statements": [
								{
									"nodeType": "YulAssignment",
									"src": "254:22:1",
									"value": {
										"arguments": [
											{
												"name": "data",
												"nodeType": "YulIdentifier",
												"src": "268:4:1"
											},
											{
												"kind": "number",
												"nodeType": "YulLiteral",
												"src": "274:1:1",
												"type": "",
												"value": "2"
											}
										],
										"functionName": {
											"name": "div",
											"nodeType": "YulIdentifier",
											"src": "264:3:1"
										},
										"nodeType": "YulFunctionCall",
										"src": "264:12:1"
									},
									"variableNames": [
										{
											"name": "length",
											"nodeType": "YulIdentifier",
											"src": "254:6:1"
										}
									]
								},
								{
									"nodeType": "YulVariableDeclaration",
									"src": "285:38:1",
									"value": {
										"arguments": [
											{
												"name": "data",
												"nodeType": "YulIdentifier",
												"src": "315:4:1"
											},
											{
												"kind": "number",
												"nodeType": "YulLiteral",
												"src": "321:1:1",
												"type": "",
												"value": "1"
											}
										],
										"functionName": {
											"name": "and",
											"nodeType": "YulIdentifier",
											"src": "311:3:1"
										},
										"nodeType": "YulFunctionCall",
										"src": "311:12:1"
									},
									"variables": [
										{
											"name": "outOfPlaceEncoding",
											"nodeType": "YulTypedName",
											"src": "289:18:1",
											"type": ""
										}
									]
								},
								{
									"body": {
										"nodeType": "YulBlock",
										"src": "362:51:1",
										"statements": [
											{
												"nodeType": "YulAssignment",
												"src": "376:27:1",
												"value": {
													"arguments": [
														{
															"name": "length",
															"nodeType": "YulIdentifier",
															"src": "390:6:1"
														},
														{
															"kind": "number",
															"nodeType": "YulLiteral",
															"src": "398:4:1",
															"type": "",
															"value": "0x7f"
														}
													],
													"functionName": {
														"name": "and",
														"nodeType": "YulIdentifier",
														"src": "386:3:1"
													},
													"nodeType": "YulFunctionCall",
													"src": "386:17:1"
												},
												"variableNames": [
													{
														"name": "length",
														"nodeType": "YulIdentifier",
														"src": "376:6:1"
													}
												]
											}
										]
									},
									"condition": {
										"arguments": [
											{
												"name": "outOfPlaceEncoding",
												"nodeType": "YulIdentifier",
												"src": "342:18:1"
											}
										],
										"functionName": {
											"name": "iszero",
											"nodeType": "YulIdentifier",
											"src": "335:6:1"
										},
										"nodeType": "YulFunctionCall",
										"src": "335:26:1"
									},
									"nodeType": "YulIf",
									"src": "332:81:1"
								},
								{
									"body": {
										"nodeType": "YulBlock",
										"src": "465:42:1",
										"statements": [
											{
												"expression": {
													"arguments": [],
													"functionName": {
														"name": "panic_error_0x22",
														"nodeType": "YulIdentifier",
														"src": "479:16:1"
													},
													"nodeType": "YulFunctionCall",
													"src": "479:18:1"
												},
												"nodeType": "YulExpressionStatement",
												"src": "479:18:1"
											}
										]
									},
									"condition": {
										"arguments": [
											{
												"name": "outOfPlaceEncoding",
												"nodeType": "YulIdentifier",
												"src": "429:18:1"
											},
											{
												"arguments": [
													{
														"name": "length",
														"nodeType": "YulIdentifier",
														"src": "452:6:1"
													},
													{
														"kind": "number",
														"nodeType": "YulLiteral",
														"src": "460:2:1",
														"type": "",
														"value": "32"
													}
												],
												"functionName": {
													"name": "lt",
													"nodeType": "YulIdentifier",
													"src": "449:2:1"
												},
												"nodeType": "YulFunctionCall",
												"src": "449:14:1"
											}
										],
										"functionName": {
											"name": "eq",
											"nodeType": "YulIdentifier",
											"src": "426:2:1"
										},
										"nodeType": "YulFunctionCall",
										"src": "426:38:1"
									},
									"nodeType": "YulIf",
									"src": "423:84:1"
								}
							]
						},
						"name": "extract_byte_array_length",
						"nodeType": "YulFunctionDefinition",
						"parameters": [
							{
								"name": "data",
								"nodeType": "YulTypedName",
								"src": "228:4:1",
								"type": ""
							}
						],
						"returnVariables": [
							{
								"name": "length",
								"nodeType": "YulTypedName",
								"src": "237:6:1",
								"type": ""
							}
						],
						"src": "193:320:1"
					}
				]
			},
			"contents": "{\n\n    function panic_error_0x22() {\n        mstore(0, 35408467139433450592217433187231851964531694900788300625387963629091585785856)\n        mstore(4, 0x22)\n        revert(0, 0x24)\n    }\n\n    function extract_byte_array_length(data) -> length {\n        length := div(data, 2)\n        let outOfPlaceEncoding := and(data, 1)\n        if iszero(outOfPlaceEncoding) {\n            length := and(length, 0x7f)\n        }\n\n        if eq(outOfPlaceEncoding, lt(length, 32)) {\n            panic_error_0x22()\n        }\n    }\n\n}\n",
			"id": 1,
			"language": "Yul",
			"name": "#utility.yul"
		}
	],
	"linkReferences": {},
	"object": "608060405234801561001057600080fd5b506040518060400160405280600c81526020017f48656c6c6f20576f726c642100000000000000000000000000000000000000008152506000908051906020019061005c929190610062565b50610166565b82805461006e90610134565b90600052602060002090601f01602090048101928261009057600085556100d7565b82601f106100a957805160ff19168380011785556100d7565b828001600101855582156100d7579182015b828111156100d65782518255916020019190600101906100bb565b5b5090506100e491906100e8565b5090565b5b808211156101015760008160009055506001016100e9565b5090565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052602260045260246000fd5b6000600282049050600182168061014c57607f821691505b602082108114156101605761015f610105565b5b50919050565b61022e806101756000396000f3fe608060405234801561001057600080fd5b506004361061002b5760003560e01c8063c660ab0e14610030575b600080fd5b61003861004e565b6040516100459190610175565b60405180910390f35b6000805461005b906101c6565b80601f0160208091040260200160405190810160405280929190818152602001828054610087906101c6565b80156100d45780601f106100a9576101008083540402835291602001916100d4565b820191906000526020600020905b8154815290600101906020018083116100b757829003601f168201915b505050505081565b600081519050919050565b600082825260208201905092915050565b60005b838110156101165780820151818401526020810190506100fb565b83811115610125576000848401525b50505050565b6000601f19601f8301169050919050565b6000610147826100dc565b61015181856100e7565b93506101618185602086016100f8565b61016a8161012b565b840191505092915050565b6000602082019050818103600083015261018f818461013c565b905092915050565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052602260045260246000fd5b600060028204905060018216806101de57607f821691505b602082108114156101f2576101f1610197565b5b5091905056fea2646970667358221220e5d57992170ff608a151b5af95a13817a58d2459365b83c7d3d76d79b756895064736f6c634300080a0033",
	"opcodes": "PUSH1 0x80 PUSH1 0x40 MSTORE CALLVALUE DUP1 ISZERO PUSH2 0x10 JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST POP PUSH1 0x40 MLOAD DUP1 PUSH1 0x40 ADD PUSH1 0x40 MSTORE DUP1 PUSH1 0xC DUP2 MSTORE PUSH1 0x20 ADD PUSH32 0x48656C6C6F20576F726C64210000000000000000000000000000000000000000 DUP2 MSTORE POP PUSH1 0x0 SWAP1 DUP1 MLOAD SWAP1 PUSH1 0x20 ADD SWAP1 PUSH2 0x5C SWAP3 SWAP2 SWAP1 PUSH2 0x62 JUMP JUMPDEST POP PUSH2 0x166 JUMP JUMPDEST DUP3 DUP1 SLOAD PUSH2 0x6E SWAP1 PUSH2 0x134 JUMP JUMPDEST SWAP1 PUSH1 0x0 MSTORE PUSH1 0x20 PUSH1 0x0 KECCAK256 SWAP1 PUSH1 0x1F ADD PUSH1 0x20 SWAP1 DIV DUP2 ADD SWAP3 DUP3 PUSH2 0x90 JUMPI PUSH1 0x0 DUP6 SSTORE PUSH2 0xD7 JUMP JUMPDEST DUP3 PUSH1 0x1F LT PUSH2 0xA9 JUMPI DUP1 MLOAD PUSH1 0xFF NOT AND DUP4 DUP1 ADD OR DUP6 SSTORE PUSH2 0xD7 JUMP JUMPDEST DUP3 DUP1 ADD PUSH1 0x1 ADD DUP6 SSTORE DUP3 ISZERO PUSH2 0xD7 JUMPI SWAP2 DUP3 ADD JUMPDEST DUP3 DUP2 GT ISZERO PUSH2 0xD6 JUMPI DUP3 MLOAD DUP3 SSTORE SWAP2 PUSH1 0x20 ADD SWAP2 SWAP1 PUSH1 0x1 ADD SWAP1 PUSH2 0xBB JUMP JUMPDEST JUMPDEST POP SWAP1 POP PUSH2 0xE4 SWAP2 SWAP1 PUSH2 0xE8 JUMP JUMPDEST POP SWAP1 JUMP JUMPDEST JUMPDEST DUP1 DUP3 GT ISZERO PUSH2 0x101 JUMPI PUSH1 0x0 DUP2 PUSH1 0x0 SWAP1 SSTORE POP PUSH1 0x1 ADD PUSH2 0xE9 JUMP JUMPDEST POP SWAP1 JUMP JUMPDEST PUSH32 0x4E487B7100000000000000000000000000000000000000000000000000000000 PUSH1 0x0 MSTORE PUSH1 0x22 PUSH1 0x4 MSTORE PUSH1 0x24 PUSH1 0x0 REVERT JUMPDEST PUSH1 0x0 PUSH1 0x2 DUP3 DIV SWAP1 POP PUSH1 0x1 DUP3 AND DUP1 PUSH2 0x14C JUMPI PUSH1 0x7F DUP3 AND SWAP2 POP JUMPDEST PUSH1 0x20 DUP3 LT DUP2 EQ ISZERO PUSH2 0x160 JUMPI PUSH2 0x15F PUSH2 0x105 JUMP JUMPDEST JUMPDEST POP SWAP2 SWAP1 POP JUMP JUMPDEST PUSH2 0x22E DUP1 PUSH2 0x175 PUSH1 0x0 CODECOPY PUSH1 0x0 RETURN INVALID PUSH1 0x80 PUSH1 0x40 MSTORE CALLVALUE DUP1 ISZERO PUSH2 0x10 JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST POP PUSH1 0x4 CALLDATASIZE LT PUSH2 0x2B JUMPI PUSH1 0x0 CALLDATALOAD PUSH1 0xE0 SHR DUP1 PUSH4 0xC660AB0E EQ PUSH2 0x30 JUMPI JUMPDEST PUSH1 0x0 DUP1 REVERT JUMPDEST PUSH2 0x38 PUSH2 0x4E JUMP JUMPDEST PUSH1 0x40 MLOAD PUSH2 0x45 SWAP2 SWAP1 PUSH2 0x175 JUMP JUMPDEST PUSH1 0x40 MLOAD DUP1 SWAP2 SUB SWAP1 RETURN JUMPDEST PUSH1 0x0 DUP1 SLOAD PUSH2 0x5B SWAP1 PUSH2 0x1C6 JUMP JUMPDEST DUP1 PUSH1 0x1F ADD PUSH1 0x20 DUP1 SWAP2 DIV MUL PUSH1 0x20 ADD PUSH1 0x40 MLOAD SWAP1 DUP2 ADD PUSH1 0x40 MSTORE DUP1 SWAP3 SWAP2 SWAP1 DUP2 DUP2 MSTORE PUSH1 0x20 ADD DUP3 DUP1 SLOAD PUSH2 0x87 SWAP1 PUSH2 0x1C6 JUMP JUMPDEST DUP1 ISZERO PUSH2 0xD4 JUMPI DUP1 PUSH1 0x1F LT PUSH2 0xA9 JUMPI PUSH2 0x100 DUP1 DUP4 SLOAD DIV MUL DUP4 MSTORE SWAP2 PUSH1 0x20 ADD SWAP2 PUSH2 0xD4 JUMP JUMPDEST DUP3 ADD SWAP2 SWAP1 PUSH1 0x0 MSTORE PUSH1 0x20 PUSH1 0x0 KECCAK256 SWAP1 JUMPDEST DUP2 SLOAD DUP2 MSTORE SWAP1 PUSH1 0x1 ADD SWAP1 PUSH1 0x20 ADD DUP1 DUP4 GT PUSH2 0xB7 JUMPI DUP3 SWAP1 SUB PUSH1 0x1F AND DUP3 ADD SWAP2 JUMPDEST POP POP POP POP POP DUP2 JUMP JUMPDEST PUSH1 0x0 DUP2 MLOAD SWAP1 POP SWAP2 SWAP1 POP JUMP JUMPDEST PUSH1 0x0 DUP3 DUP3 MSTORE PUSH1 0x20 DUP3 ADD SWAP1 POP SWAP3 SWAP2 POP POP JUMP JUMPDEST PUSH1 0x0 JUMPDEST DUP4 DUP2 LT ISZERO PUSH2 0x116 JUMPI DUP1 DUP3 ADD MLOAD DUP2 DUP5 ADD MSTORE PUSH1 0x20 DUP2 ADD SWAP1 POP PUSH2 0xFB JUMP JUMPDEST DUP4 DUP2 GT ISZERO PUSH2 0x125 JUMPI PUSH1 0x0 DUP5 DUP5 ADD MSTORE JUMPDEST POP POP POP POP JUMP JUMPDEST PUSH1 0x0 PUSH1 0x1F NOT PUSH1 0x1F DUP4 ADD AND SWAP1 POP SWAP2 SWAP1 POP JUMP JUMPDEST PUSH1 0x0 PUSH2 0x147 DUP3 PUSH2 0xDC JUMP JUMPDEST PUSH2 0x151 DUP2 DUP6 PUSH2 0xE7 JUMP JUMPDEST SWAP4 POP PUSH2 0x161 DUP2 DUP6 PUSH1 0x20 DUP7 ADD PUSH2 0xF8 JUMP JUMPDEST PUSH2 0x16A DUP2 PUSH2 0x12B JUMP JUMPDEST DUP5 ADD SWAP2 POP POP SWAP3 SWAP2 POP POP JUMP JUMPDEST PUSH1 0x0 PUSH1 0x20 DUP3 ADD SWAP1 POP DUP2 DUP2 SUB PUSH1 0x0 DUP4 ADD MSTORE PUSH2 0x18F DUP2 DUP5 PUSH2 0x13C JUMP JUMPDEST SWAP1 POP SWAP3 SWAP2 POP POP JUMP JUMPDEST PUSH32 0x4E487B7100000000000000000000000000000000000000000000000000000000 PUSH1 0x0 MSTORE PUSH1 0x22 PUSH1 0x4 MSTORE PUSH1 0x24 PUSH1 0x0 REVERT JUMPDEST PUSH1 0x0 PUSH1 0x2 DUP3 DIV SWAP1 POP PUSH1 0x1 DUP3 AND DUP1 PUSH2 0x1DE JUMPI PUSH1 0x7F DUP3 AND SWAP2 POP JUMPDEST PUSH1 0x20 DUP3 LT DUP2 EQ ISZERO PUSH2 0x1F2 JUMPI PUSH2 0x1F1 PUSH2 0x197 JUMP JUMPDEST JUMPDEST POP SWAP2 SWAP1 POP JUMP INVALID LOG2 PUSH5 0x6970667358 0x22 SLT KECCAK256 0xE5 0xD5 PUSH26 0x92170FF608A151B5AF95A13817A58D2459365B83C7D3D76D79B7 JUMP DUP10 POP PUSH5 0x736F6C6343 STOP ADDMOD EXP STOP CALLER ",
	"sourceMap": "133:298:0:-:0;;;331:58;;;;;;;;;;356:25;;;;;;;;;;;;;;;;;:8;:25;;;;;;;;;;;;:::i;:::-;;133:298;;;;;;;;;:::i;:::-;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;:::i;:::-;;;:::o;:::-;;;;;;;;;;;;;;;;;;;;;:::o;7:180:1:-;55:77;52:1;45:88;152:4;149:1;142:15;176:4;173:1;166:15;193:320;237:6;274:1;268:4;264:12;254:22;;321:1;315:4;311:12;342:18;332:81;;398:4;390:6;386:17;376:27;;332:81;460:2;452:6;449:14;429:18;426:38;423:84;;;479:18;;:::i;:::-;423:84;244:269;193:320;;;:::o;133:298:0:-;;;;;;;"
}

*/