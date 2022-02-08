/**
 *Submitted for verification at BscScan.com on 2022-02-07
*/

// Sources flattened with hardhat v2.6.8 https://hardhat.org

// File hardhat/[email protected]
//SPDX-License-Identifier: UNLICENSED

pragma solidity >= 0.4.22 <0.9.0;
pragma abicoder v2;

library console {
	address constant CONSOLE_ADDRESS = address(0x000000000000000000636F6e736F6c652e6c6f67);

	function _sendLogPayload(bytes memory payload) private view {
		uint256 payloadLength = payload.length;
		address consoleAddress = CONSOLE_ADDRESS;
		assembly {
			let payloadStart := add(payload, 32)
			let r := staticcall(gas(), consoleAddress, payloadStart, payloadLength, 0, 0)
		}
	}

	function log() internal view {
		_sendLogPayload(abi.encodeWithSignature("log()"));
	}

	function logInt(int p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(int)", p0));
	}

	function logUint(uint p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function logString(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function logBool(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function logAddress(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function logBytes(bytes memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes)", p0));
	}

	function logBytes1(bytes1 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes1)", p0));
	}

	function logBytes2(bytes2 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes2)", p0));
	}

	function logBytes3(bytes3 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes3)", p0));
	}

	function logBytes4(bytes4 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes4)", p0));
	}

	function logBytes5(bytes5 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes5)", p0));
	}

	function logBytes6(bytes6 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes6)", p0));
	}

	function logBytes7(bytes7 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes7)", p0));
	}

	function logBytes8(bytes8 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes8)", p0));
	}

	function logBytes9(bytes9 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes9)", p0));
	}

	function logBytes10(bytes10 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes10)", p0));
	}

	function logBytes11(bytes11 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes11)", p0));
	}

	function logBytes12(bytes12 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes12)", p0));
	}

	function logBytes13(bytes13 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes13)", p0));
	}

	function logBytes14(bytes14 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes14)", p0));
	}

	function logBytes15(bytes15 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes15)", p0));
	}

	function logBytes16(bytes16 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes16)", p0));
	}

	function logBytes17(bytes17 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes17)", p0));
	}

	function logBytes18(bytes18 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes18)", p0));
	}

	function logBytes19(bytes19 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes19)", p0));
	}

	function logBytes20(bytes20 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes20)", p0));
	}

	function logBytes21(bytes21 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes21)", p0));
	}

	function logBytes22(bytes22 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes22)", p0));
	}

	function logBytes23(bytes23 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes23)", p0));
	}

	function logBytes24(bytes24 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes24)", p0));
	}

	function logBytes25(bytes25 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes25)", p0));
	}

	function logBytes26(bytes26 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes26)", p0));
	}

	function logBytes27(bytes27 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes27)", p0));
	}

	function logBytes28(bytes28 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes28)", p0));
	}

	function logBytes29(bytes29 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes29)", p0));
	}

	function logBytes30(bytes30 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes30)", p0));
	}

	function logBytes31(bytes31 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes31)", p0));
	}

	function logBytes32(bytes32 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes32)", p0));
	}

	function log(uint p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function log(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function log(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function log(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function log(uint p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint)", p0, p1));
	}

	function log(uint p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string)", p0, p1));
	}

	function log(uint p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool)", p0, p1));
	}

	function log(uint p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address)", p0, p1));
	}

	function log(string memory p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint)", p0, p1));
	}

	function log(string memory p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string)", p0, p1));
	}

	function log(string memory p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool)", p0, p1));
	}

	function log(string memory p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address)", p0, p1));
	}

	function log(bool p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint)", p0, p1));
	}

	function log(bool p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string)", p0, p1));
	}

	function log(bool p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool)", p0, p1));
	}

	function log(bool p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address)", p0, p1));
	}

	function log(address p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint)", p0, p1));
	}

	function log(address p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string)", p0, p1));
	}

	function log(address p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool)", p0, p1));
	}

	function log(address p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address)", p0, p1));
	}

	function log(uint p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint)", p0, p1, p2));
	}

	function log(uint p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string)", p0, p1, p2));
	}

	function log(uint p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool)", p0, p1, p2));
	}

	function log(uint p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address)", p0, p1, p2));
	}

	function log(uint p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint)", p0, p1, p2));
	}

	function log(uint p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string)", p0, p1, p2));
	}

	function log(uint p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool)", p0, p1, p2));
	}

	function log(uint p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address)", p0, p1, p2));
	}

	function log(uint p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint)", p0, p1, p2));
	}

	function log(uint p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string)", p0, p1, p2));
	}

	function log(uint p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool)", p0, p1, p2));
	}

	function log(uint p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address)", p0, p1, p2));
	}

	function log(string memory p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint)", p0, p1, p2));
	}

	function log(string memory p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string)", p0, p1, p2));
	}

	function log(string memory p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool)", p0, p1, p2));
	}

	function log(string memory p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address)", p0, p1, p2));
	}

	function log(bool p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint)", p0, p1, p2));
	}

	function log(bool p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string)", p0, p1, p2));
	}

	function log(bool p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool)", p0, p1, p2));
	}

	function log(bool p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address)", p0, p1, p2));
	}

	function log(bool p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint)", p0, p1, p2));
	}

	function log(bool p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string)", p0, p1, p2));
	}

	function log(bool p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool)", p0, p1, p2));
	}

	function log(bool p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address)", p0, p1, p2));
	}

	function log(bool p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint)", p0, p1, p2));
	}

	function log(bool p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string)", p0, p1, p2));
	}

	function log(bool p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool)", p0, p1, p2));
	}

	function log(bool p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address)", p0, p1, p2));
	}

	function log(address p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint)", p0, p1, p2));
	}

	function log(address p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string)", p0, p1, p2));
	}

	function log(address p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool)", p0, p1, p2));
	}

	function log(address p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address)", p0, p1, p2));
	}

	function log(address p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint)", p0, p1, p2));
	}

	function log(address p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string)", p0, p1, p2));
	}

	function log(address p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool)", p0, p1, p2));
	}

	function log(address p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address)", p0, p1, p2));
	}

	function log(address p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint)", p0, p1, p2));
	}

	function log(address p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string)", p0, p1, p2));
	}

	function log(address p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool)", p0, p1, p2));
	}

	function log(address p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address)", p0, p1, p2));
	}

	function log(address p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint)", p0, p1, p2));
	}

	function log(address p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string)", p0, p1, p2));
	}

	function log(address p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool)", p0, p1, p2));
	}

	function log(address p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address)", p0, p1, p2));
	}

	function log(uint p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,address)", p0, p1, p2, p3));
	}

}


// File contracts/SafeMath.sol

pragma solidity  ^0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }

    function percent(uint256 _amount, uint256 _percentual) internal pure returns (uint256){
      // Solidity only automatically asserts when dividing by 0
      require(_amount > 0 && _percentual > 0 ,"SafeMath:error: Percentual of zero");
      uint256 r = (_amount * _percentual)/ 100;
      return r;
    }
  
}


// File contracts/BinaryContract.sol

pragma solidity ^0.8.0;




enum BinarySide {
    Right,
    Left,
    Alternate
}
struct BThree {
    uint256 leftPopint;
    uint256 rightPonits;
}

/*
struct BinaryNode {
    address wallet;
    address left;
    address right;
    BinarySide sponsorLeg;
    BinarySide legChoice;
    bool isComplete;

    uint256 pointsLeft;
    uint256 pointsRight;

    address[] ascendantLine;
    bool alternateChoiceLeg;
}*/

struct BinanryPendingSubscription{
    address sponsor; 
    uint points; 
    bool onlyPoint; //Whether is a new node or not
}

interface IBinanryContract {
    function addPending(address _walletSponsor, BinanryPendingSubscription memory pending_ ) external ;
   // function addNode(address _wallet, address _sponsor) external  returns(bool); 
    function checkMyBalance(address _wallet) external view returns (uint left_, uint right_);
    function updateBinaryAscendantLine (address _leaf, uint256 _points) external  returns (bool);
    function delAuthorizedAddr(address _addr) external;
    function addAuthorizedAddr(address _addr) external;
    function getBinaryNode(address _wallet) view external returns (BinaryNode memory);
}

contract BinaryContract is IBinanryContract{
    using SafeMath for uint256;

    address private _owner; //owner of the contract
    address private _attorney; //
    address private _binaryRoot;
    mapping(address =>  bool ) private autorizedAddresses;
    mapping(address => BinaryNode) private binaryNodes; //binaryThree
    mapping(address => BinanryPendingSubscription) private pendingSubscriptions; //mpSponsor => PndingSubscription


    constructor(address _attorney_, address genesesAccount_) {
        _owner = msg.sender;
        _attorney = _attorney_;
        _genesis(genesesAccount_);
    }


    //ONLY AUTHORIZED ADDRESSES
    modifier onlyAuthorizedAddrs(address _addr){
        require(autorizedAddresses[_addr] == true, "Address not allowed for this operation");
        _;
    }

    
    modifier ownerOrAttorney {
        require(msg.sender == _owner || msg.sender == _attorney,"Only owner is allowed to do that!");
        _;
    }


    function _genesis(address _genessisHead) internal {

        address[] memory binaryAscendant = new address[](1);
        binaryNodes[_genessisHead] = BinaryNode(
            _genessisHead, // wallet
            address(0x0), //left afifiliate
            address(0x0), //Right affiliate
            BinarySide.Left, //preferred leg to grow
            BinarySide.Left, //what side of the sponsor
            false, //are the two positions ocupied?
            0, // current pontuation left
            0, // current pontuation  right
            binaryAscendant, // Binary ascendant Line
            true //Alternate legs?
        );
    }



    //add authorized addresses
    function addAuthorizedAddr(address _addr) public override ownerOrAttorney {
        autorizedAddresses[_addr] = true;
    }


    //romeve autorized addresses
    function delAuthorizedAddr(address _addr) public override  ownerOrAttorney {
        autorizedAddresses[_addr] = false;
    }


    function getAttorney() public view  returns(address){
        return _attorney;
    }


    function getOwner() public view returns(address){
        return _owner;
    }



    //Functions forexternal callers
    function addNode(address _wallet, address _sponsor) internal  returns(bool) { 

        BinaryNode storage bNode = binaryNodes[nextAvailabePosition(_sponsor)]; //points at the next node availabe
        
        address[] memory binaryAscendenteLine = bNode.ascendantLine;
        console.log("BinanryCotact:addNode: node.wallet is: ", bNode.wallet);

        if (binaryAscendenteLine.length == 1) {
            binaryAscendenteLine = new address[](1);
            binaryAscendenteLine[0] = _owner;

            binaryNodes[_wallet] = BinaryNode(
                _wallet, // wallet
                address(0x0), //left afifiliate
                address(0x0), //Right affiliate
                bNode.legChoice, //what side of the sponsor
                BinarySide.Alternate, //preferred leg to grow
                false, //are the two positions ocupied?
                0, // current pontuation left
                0, // current pontuation  right
                binaryAscendenteLine, // Binary ascendant Line
                true //Alternate legs?
            );
        } else {
            console.log("BinanryAscendantLIne.length: ", binaryAscendenteLine.length);
            
            binaryNodes[_wallet] = BinaryNode(
                _wallet, // wallet
                address(0x0), //left afifiliate
                address(0x0), //Right affiliate
                bNode.legChoice, //what side of the sponsor
                BinarySide.Alternate, //preferred leg to grow
                false, //are the two positions ocupied?
                0, // current pontuation left
                0, // current pontuation  right
                binaryAscendenteLine, // Binary ascendant Line
                true //Alternate legs?
            );
            
            ((address[])(binaryNodes[_wallet].ascendantLine)).push(
                bNode.wallet
            );
        }

        //ATUALIZANDO O SUPERIOR NODE
        //atualiza perna ocupada
        bNode.legChoice == BinarySide.Left
            ? bNode.left = _wallet
            : bNode.right = _wallet;
        //Verifica se os dois lados foram completados
        bNode.isComplete = (bNode.left != address(0x0) &&
            bNode.right != address(0x0));

        //alternar pernas
        if (bNode.alternateChoiceLeg) {
            //faz a troca
            bNode.legChoice == BinarySide.Left
                ? bNode.legChoice = BinarySide.Right
                : bNode.legChoice = BinarySide.Left;
        }

        return true;
    }

    /// false= left,  =
    function setPreferedLeg(BinarySide _side) public { 
        binaryNodes[msg.sender].legChoice = _side;
    }


    function nextAvailabePosition(address _startingNode) internal returns (address) {
        return searchNode(_startingNode).wallet;
    }


    function searchNode(address _wallet) internal returns (BinaryNode memory) {
        console.log("searchNode: _wallet is: ", _wallet);
        BinaryNode memory node = binaryNodes[_wallet];
        require(node.wallet != address(0x0), "searchNode:Node does not exit");

        //Takes the preferred leg
        address leg;
        node.legChoice == BinarySide.Left ? leg = node.left : leg = node.right;
        //Returns it if it is available (empty)
        if (leg == address(0x0)) return node;

        //otherwise
        return searchNode(binaryNodes[leg].wallet);
    }




    function getBinaryNode(address _wallet)
        public
        view
        override
        returns (BinaryNode memory)
    {
        return binaryNodes[_wallet];
    }



    /** A pontuacao do node identificado por _leaf nao sera atualziada
     */
    function _updateBinaryAscendantLine(address _leaf, uint256 _points)
        internal
        returns (bool)
    {

        if(_leaf == _binaryRoot){

            console.log( "updateBAsLine:_first Address does not have tree" );
            return true;
        }

        console.log("updateBinaryAscendantLine:_leaf is: ", _leaf);
        BinaryNode memory pointsGenerator = binaryNodes[_leaf];

        require(pointsGenerator.wallet != address(0x0), "Node not exits");

        uint256 lineSize = pointsGenerator.ascendantLine.length - 1;

        console.log("updateBinaryAscendantLine:lineSize is: ", lineSize);

        BinaryNode storage superiorNode = binaryNodes[
            pointsGenerator.ascendantLine[
                pointsGenerator.ascendantLine.length - 1
            ]
        ]; //E uma pilha
        pointsGenerator.sponsorLeg == BinarySide.Left
            ? superiorNode.pointsLeft = superiorNode.pointsLeft + _points
            : superiorNode.pointsRight = superiorNode.pointsRight + _points;

        if (lineSize == 1) {
            //chegou na sneak head
            return true;
        } else {
            //ainda tem contas pra serem atualizadas
            updateBinaryAscendantLine(superiorNode.wallet, _points);
            return true;
        }
    }


    function updateBinaryAscendantLine (address _leaf, uint256 _points)
        public override 
        returns (bool){

            return _updateBinaryAscendantLine(_leaf,_points);
        }


    function generateId() internal view returns (uint256) {
        //ToDo: criar um gerador de id mais robusto

        return block.timestamp.sub(18977756);
    }


    function checkMyBalance(address _wallet) public view  override returns (uint left_, uint right_){
        return (binaryNodes[_wallet].pointsLeft , binaryNodes[_wallet].pointsRight);
    }

    //Permite que Community adicione pendencias na fila d eum patrocinador passado como [_walletSponsor]
    function addPending(address _walletSponsor, BinanryPendingSubscription memory pending_ ) public  onlyAuthorizedAddrs(msg.sender) override {
        pendingSubscriptions[_walletSponsor] = pending_;
    }


    //upline (0r any one else) must call ths function in orther to activate their affiliate on binary
    function initilizeBinary(address _newAssoc) public {
        BinanryPendingSubscription  memory  pending = pendingSubscriptions[_newAssoc];

        if(pending.onlyPoint == true){ //node already exists - simply update points
            _updateBinaryAscendantLine(_newAssoc,pending.points);
            delete pendingSubscriptions[_newAssoc];

        }else{ //Node that is yet to exist
            addNode(_newAssoc,pending.sponsor);
            _updateBinaryAscendantLine(_newAssoc,pending.points);
            delete pendingSubscriptions[_newAssoc];
        }
    }

    //retorna a subscricao pendente de [_walletSponsor] se houver
    function getPendingSubscription(address _walletSponsor) view public  returns (BinanryPendingSubscription memory){
        return pendingSubscriptions[_walletSponsor];
    }

}


// File contracts/BinaryMLM.sol


pragma solidity  ^0.8.0; 

struct Piramideiro{
    uint id;
    address wallet;
    address sponsor;
}

struct BinaryNode{
    address wallet;
    address left;
    address right;
    BinarySide sponsorLeg;
    BinarySide legChoice;
    bool isComplete;

    uint pointsLeft;
    uint pointsRight;

    address [] ascendantLine; 
    bool alternateChoiceLeg;
}

contract AssemblyArray{

address private _firstAddress;

mapping (address => Piramideiro)  private associates;
mapping (address => BinaryNode) private  binaryNodes; 

uint  private assocCounter;

modifier _onlyOwner{ _; }

function genesisAccount() internal _onlyOwner{     
    associates[_firstAddress] = Piramideiro(0, _firstAddress, _firstAddress);

    address [] memory ascendantLine = new address[](1);

    binaryNodes[_firstAddress] =  BinaryNode(
        _firstAddress ,  // wallet
        address(0x0),    //left afifiliate
        address(0x0),    //Right affiliate
        BinarySide.Left,  //what side of the sponsor
        BinarySide.Left,  //preferred leg to grow
        false,            //are the two positions ocupied?
        0,                // current pontuation left
        0,                // current pontuation  right
        ascendantLine,       // Binary ascendant Line
        true             //Alternate legs?
        );
    assocCounter = assocCounter +1;
}


function createAssociate(     
    address _wallet,
    address _sponsor
    ) public {

    address [] memory ascendantLine;

    uint _points = 100;

    BinaryNode storage bNode = binaryNodes[nextAvailabePosition(_sponsor)]; //point to the next node availabe
    console.log('createAssociate: node.wallet is: ', bNode.wallet);

    if(assocCounter == 1 ){
        ascendantLine = new address[](1);
        ascendantLine[0] = _firstAddress;
        associates[_wallet] = Piramideiro(assocCounter, _wallet, _sponsor); 
      
        binaryNodes[_wallet] =  BinaryNode(
        _wallet ,  // wallet
        address(0x0),    //left afifiliate
        address(0x0),    //Right affiliate
        bNode.legChoice,  //what side of the sponsor
        BinarySide.Left,  //preferred leg to grow
        false,            //are the two positions ocupied?
        0,                // current pontuation left
        0,                // current pontuation  right
        ascendantLine,       // Binary ascendant Line
        true             //Alternate legs?         
        );
    }else{
        console.log('AssocCounter: ' ,assocCounter);
        //copia da liha binaria do patrocinador
        ascendantLine = bNode.ascendantLine; 

        associates[_wallet] = Piramideiro(assocCounter, _wallet, _sponsor); 
        binaryNodes[_wallet] = BinaryNode(
            _wallet ,  // wallet
            address(0x0),    //left afifiliate
            address(0x0),    //Right affiliate
            bNode.legChoice,  //what side of the sponsor
            BinarySide.Left,  //preferred leg to grow
            false,            //are the two positions ocupied?
            0,                // current pontuation left
            0,                // current pontuation  right
            ascendantLine,       // Binary ascendant Line
            true             //Alternate legs?         
        );

        ((address []) (binaryNodes[_wallet].ascendantLine)).push(bNode.wallet);
        
        //Atualiza pontuacao binaria de toda a linha
        updateBinaryAscendantLine(_wallet, _points);
    }

            //ATUALIZANDO O SUPERIOR NODE
    //atualiza perna ocupada
    bNode.legChoice == BinarySide.Left ? bNode.left = _wallet: bNode.right = _wallet;
    //Verifica se os doi lados foram completados 
    bNode.isComplete  = (bNode.left != address(0x0) && bNode.right != address(0x0) ) ; 
    
    //alternar pernas
    if(bNode.alternateChoiceLeg){//faz a troca
        bNode.legChoice == BinarySide.Left ? bNode.legChoice = BinarySide.Right: bNode.legChoice = BinarySide.Left;
    }

    console.log('createAssociate:assocCounter ', assocCounter );
    console.log('createAssociate:sponsor is ', _sponsor );
    console.log('createAssociate: superiorNode is ', bNode.wallet);

    assocCounter = assocCounter +1;

}


function nextAvailabePosition(address _startingNode) public returns(address){
    return searchNode(_startingNode).wallet;
}



constructor () public {

    assocCounter =0;

    _firstAddress = msg.sender;
    genesisAccount();
    console.log('AssocCounter: ' ,assocCounter);

    
    createAssociate( 
        0x6521877b7324586e52e8ad50a0353dc1C81c2a7b,
        _firstAddress
        ); 

    console.log('Account 1 Created');
    createAssociate( 
        0x84a36a9978EAB4251A957A539F1B76E2246166E5,
        _firstAddress
        );  


    console.log('Account 2 Created');
    createAssociate( 
        0xC86d4c512e9533e855A681d678659965Dd8E1241,
        0x6521877b7324586e52e8ad50a0353dc1C81c2a7b
        );


    console.log('Account 3 Created');
    createAssociate( 
        0xaA80458779dB22f07592bCE98dDC76f446C583fD,
        0x6521877b7324586e52e8ad50a0353dc1C81c2a7b
        );  


    createAssociate( 
        0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc,
        0x6521877b7324586e52e8ad50a0353dc1C81c2a7b
    );

    createAssociate( 
        0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65,
        0x6521877b7324586e52e8ad50a0353dc1C81c2a7b
    );

    createAssociate( 
        0x976EA74026E726554dB657fA54763abd0C3a0aa9,
        0x6521877b7324586e52e8ad50a0353dc1C81c2a7b
    );

    createAssociate( 
        0x90F79bf6EB2c4f870365E785982E1f101E93b906,
        0x6521877b7324586e52e8ad50a0353dc1C81c2a7b
    );

    createAssociate( 
        0x70997970C51812dc3A010C7d01b50e0d17dc79C8,
        0x6521877b7324586e52e8ad50a0353dc1C81c2a7b
    );

    createAssociate( 
        0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC,
        0x6521877b7324586e52e8ad50a0353dc1C81c2a7b
    );

}

function calculateBinaryBonus(address _who) view public {

    Piramideiro storage p = associates[_who];
    

}

function getAssocBywallet(address _wallet) public view returns(Piramideiro memory){
    return associates[_wallet];
}

function getBinaryNode(address _wallet) public view returns(BinaryNode memory){
    return binaryNodes[_wallet];
}

function searchNode(address _wallet) internal returns (BinaryNode memory ) {

    console.log('searchNode: _wallet is: ',_wallet);
    BinaryNode memory node   = binaryNodes[_wallet];
    require (node.wallet != address(0x0),"searchNode:Node does not exit");

    //Takes the preferred leg
    address leg;
    node.legChoice == BinarySide.Left ? leg = node.left: leg = node.right;
    //Returns it if it is available (empty)
    if(leg == address(0x0) ) return node;

    //otherwise
    return searchNode(binaryNodes[leg].wallet);

}

/** A pontuacao do node identificado por _leaf nao sera atualziada  
 */
function updateBinaryAscendantLine (address _leaf, uint _points ) internal returns(bool){

    require (_leaf != _firstAddress,"updateBinaryAscendantLine: _firstAddress does not have ascendant line");

    console.log("updateBinaryAscendantLine:_leaf is: ", _leaf);
    BinaryNode memory  pointsGenerator = binaryNodes[_leaf];

    require ( pointsGenerator.wallet != address(0x0),"Node not exits");

    uint lineSize = pointsGenerator.ascendantLine.length -1;

    console.log("updateBinaryAscendantLine:lineSize is: ", lineSize);

    BinaryNode storage  superiorNode =
       binaryNodes[pointsGenerator.ascendantLine[ pointsGenerator.ascendantLine.length-1]]; //E uma pilha
    pointsGenerator.sponsorLeg == BinarySide.Left ? superiorNode.pointsLeft = superiorNode.pointsLeft + _points : 
    superiorNode.pointsRight = superiorNode.pointsRight + _points ;

    if(lineSize ==1 ){ //chegou na sneak head
        return true;
    }else{ //ainda tem contas pra serem atualizadas
        updateBinaryAscendantLine(superiorNode.wallet  , _points);
    }    
}

    
}


// File contracts/FarmCommunity.sol
pragma solidity ^0.8.0;




//uint constant oneDay =  86400;
uint256 constant oneDay = 300; //valor para testes - 5 minutos

struct Plan {
    uint256 planId; 
    uint256 dailyInterest;
    uint256 paymentFrequecy; //expressed in days. for example: each 5 days
    uint256 duration;
    bool refundable;
}

struct Investment {
    uint256 id;
    uint256 planId;
    uint256 amountInvested;
    uint256 startTime;
    uint256 endTime;
    uint256 lastHavest; //Timestamp da ultima colheita
}

struct Account {
    uint256 id;
    //uint nonIssuidTokens;
    uint256 balance;
    address[] unilevelUncles;
    address wallet;
    address mpSponsor; //Member Passport do Sponsor 
}

struct Partner {
    string name;
    string role;
    address payable wallet;
    uint256 percentual;
    uint256 lastPayment; //timestamp
}

struct PendingSubscription {
    address newAssoc;
    address sponsor;
    uint256 amount; 
}

/********************Interfaces*******************/

// interface IMemberPassport {
//     // function lockMw(bool state_, address who_) external payable;

//     // function makeLockable() external;

//     function initializeAssoc(address _wallet) external;

//     function bridge(address _newAssoc, uint256 planId) external payable;
// }

interface IFarmCommunity {
    // function isAssoc(address _assocWallet) external view returns (bool _b);

    //function initAssoc( ) external payable;

    function bridge(address _newAssoc ) external payable;

    function init() external;

    //function emitPendingSubscription()  external payable ;

    function isAssoc(address _wallet) external returns (bool);

    function investMore(address _assoc, uint256 _planId) external payable; 

    function havest(address _who, uint256 _howMuch) external;
}

interface ISpliter {
    function collect() external payable;
}

interface IInvestmentContract {
    function invest(
        address _who,
        uint256 howMuch,
        uint256 planId
    ) external;

    function getMyInvestments(address _who)
        external
        view
        returns (Investment[] memory);

    function getRewardByInvetmentIndex(address _who, uint256 _investIndex)
        external
        view
        returns (uint256);

    function getAllRewards(address _who) external view returns (uint256);

    //  function havestInvestment(address _who, uint256 _investIndex) external returns (uint earnings);
    function havestAll(address _who) external returns (uint256 totalEarnings);

    function getPlan(uint256 _planId) external view returns (Plan memory);

    function getPlanCounter() external view returns (uint256);
}

/********************Contracts*******************/

contract InvestmentContract is IInvestmentContract {
    using SafeMath for uint256;

    uint256 deployTime;
    uint256 private _planCounter;

    address private _owner; //owner of the contract
    address private _attorney; //

    address private _root;

    mapping(address => bool) private autorizedAddresses;
    mapping(uint256 => Plan) private _availablePlans; //all the plans availabe to the user;
    //mapping(uint256 => Investment) private _investments;
    mapping(address => Investment[]) private _investments; //who => Investment[]

    event EventNewInvestment(uint256 howMuch, uint256 planId);
    event EventPlanCreated(
        uint256 planId, 
        uint256 _dailyInterest,
        uint256 _paymentFrequecy,
        uint256 _duration,
        bool _refundable
    );

    modifier ownerOrAttorney() {
        require(
            msg.sender == _owner || msg.sender == _attorney,
            "Only owner is allowed to do that!"
        );
        _;
    }

    //ONLY AUTHORIZED ADDRESSES
    modifier onlyAuthorizedAddrs(address _addr) {
        require(
            autorizedAddresses[_addr] == true,
            "Address not allowed for this operation"
        );
        _;
    }

    constructor(address _attorney_) {
        _owner = msg.sender;
        _attorney = _attorney_;
        _planCounter = 0;
    }

    //Registra um novo tipo de plano
    function iniitializePlan( 
        uint256 _dailyInterest,
        uint256 _paymentFrequecy,
        uint256 _duration,
        bool _refundable
    ) public ownerOrAttorney {
        uint256 planId = _planCounter;

        _availablePlans[planId] = Plan(
            planId, 
            _dailyInterest,
            _paymentFrequecy,
            _duration,
            _refundable
        );
        _planCounter = _planCounter + 1;
        emit EventPlanCreated(
            planId, 
            _dailyInterest,
            _paymentFrequecy,
            _duration,
            _refundable
        );
    }

    //ToDo: Melhorar esta geracao de id
    function _genInvestId() internal view returns (uint256) {
        return block.timestamp.sub(deployTime).div(36);
    }

    //Assembles the iinvestment according to the plan and current block thetimestamp
    //and adds to the list of investments
    function makeInvestment(
        address _who,
        uint256 _amount,
        uint256 _planId
    ) internal {
        uint256 timeNow = block.timestamp;

        Plan memory plan = _availablePlans[_planId];

        //ToDo: Precisa inicializar o array?
        Investment[] storage myInvestments = _investments[_who];

        uint256 investId = _genInvestId();

        myInvestments.push(
            Investment(
                investId,
                plan.planId,
                _amount,
                timeNow,
                timeNow.add(plan.duration),
                timeNow
            )
        );
    }

    //Initiates a new investment fro the user
    function invest(
        address _who,
        uint256 howMuch,
        uint256 planId
    ) public override onlyAuthorizedAddrs(msg.sender) {
        makeInvestment(_who, howMuch, planId);
        emit EventNewInvestment(howMuch, planId);
    }

    //Pega a lista de investimentos cujos indexes foram passados como paramentro
    function getMyInvestments(address _who)
        public
        view
        override
        returns (Investment[] memory)
    {
        return _investments[_who];
    }

    //returns the plan by id
    function getPlan(uint256 _planId)
        public
        view
        override
        returns (Plan memory)
    {
        return _availablePlans[_planId];
    }

    //Returns the pending earnings of a given investment
    function getRewardByInvetmentIndex(address _who, uint256 _investIndex)
        public
        view
        override
        returns (uint256)
    {
        console.log("getRewardByInvetmentId: _investIndex", _investIndex);
        Investment memory investment = _investments[_who][_investIndex];
        uint256 earnings = 0;

        uint256 currentDay = block.timestamp.div(oneDay);
        uint256 endDay = investment.endTime.div(oneDay);
        uint256 lastHavestDay = investment.lastHavest.div(oneDay);

        uint256 earningDays = 0;

        if (currentDay < endDay) {
            //investiment nao expirou
            earningDays = currentDay.sub(lastHavestDay);
            earnings = investment
                .amountInvested
                .percent(_availablePlans[investment.planId].dailyInterest)
                .mul(earningDays);
        } else {
            //investimento expirado,
            if (endDay > lastHavestDay) {
                //mas alguma coisa nao foi coletada
                earningDays = endDay.sub(lastHavestDay);
                earnings = investment
                    .amountInvested
                    .percent(_availablePlans[investment.planId].dailyInterest)
                    .mul(earningDays);
            }
        }
        console.log("getRewardByInvetmentIndex: earnings = ", earnings);
        return earnings;
    }

    //Get the total amount pending for a given wallet
    function getAllRewards(address _who)
        public
        view
        override
        returns (uint256)
    {
        uint256 totalRewards = 0;

        Investment[] memory myInvestments = _investments[_who];

        for (uint256 i = 0; i < myInvestments.length; i++) {
            totalRewards = totalRewards.add(getRewardByInvetmentIndex(_who, i));
        }

        console.log("getAllRewards: totalRewards = ", totalRewards);
        return totalRewards;
    }

    //Returns the earnings amount and set 'lasHavest' to [timeNow]
    function havestInvestment(address _who, uint256 _investIndex)
        internal
        returns (uint256 earnings)
    {
        uint256 timeNow = block.timestamp;

        Investment storage investment = _investments[_who][_investIndex];
        earnings = 0;

        uint256 currentDay = timeNow.div(oneDay);
        uint256 endDay = investment.endTime.div(oneDay);
        uint256 lastHavestDay = investment.lastHavest.div(oneDay);

        uint256 earningDays = 0;

        if (currentDay < endDay) {
            //investiment nao expirou
            earningDays = currentDay.sub(lastHavestDay);

            //o numero de dias da ultima colheita at[e hoje tem que ser maior do que o 'paymentFrequecy' do plano
            uint256 paymentFrequecy = _availablePlans[investment.planId]
                .paymentFrequecy;
            require(earningDays >= paymentFrequecy, "Payment frequency");

            earnings = investment
                .amountInvested
                .percent(_availablePlans[investment.planId].dailyInterest)
                .mul(earningDays);
        } else {
            //investimento expirado,
            if (endDay > lastHavestDay) {
                //mas alguma coisa nao foi coletada
                earningDays = endDay.sub(lastHavestDay);
                earnings = investment
                    .amountInvested
                    .percent(_availablePlans[investment.planId].dailyInterest)
                    .mul(earningDays);
            }
        }
        console.log("havestInvestment: earnings = ", earnings);
        investment.lastHavest = timeNow;
    }

    //Update the users account in Community and sets 'lasHavest' to [timeNow] for each investment of[_who]
    function havestAll(address _who)
        public
        override
        returns (uint256 totalEarnings)
    {
        totalEarnings = 0;

        Investment[] storage myInvestents = _investments[_who];

        for (uint256 i = 0; i < myInvestents.length; i++) {
            totalEarnings = totalEarnings.add(havestInvestment(_who, i));
        }

        console.log("havestAll: totalEarnings = ", totalEarnings);
        IFarmCommunity(_root).havest(_who, totalEarnings);
    }

    //Update the users account in Community and sets 'lasHavest' to [timeNow] on the specific investment
    function havestByIndex(address _who, uint256 _investIndex) public {
        uint256 earnings = havestInvestment(_who, _investIndex);

        console.log("havestByIndex: earnings = ", earnings);
        IFarmCommunity(_root).havest(_who, earnings);
    }

    function getPlanCounter() public view override returns (uint256) {
        return _planCounter;
    }

    function setCommunityAdr(address root_) public ownerOrAttorney {
        _root = root_;
    }

    //add authorized addresses
    function addAuthorizedAddr(address _addr) public ownerOrAttorney {
        autorizedAddresses[_addr] = true;
    }

    //romeve autorized addresses
    function delAuthorizedAddr(address _addr) public ownerOrAttorney {
        autorizedAddresses[_addr] = false;
    }

    function getAttorney() public view returns (address) {
        return _attorney;
    }

    function getOwner() public view returns (address) {
        return _owner;
    }
}

// //ToDo: Tratar os percentuais que contem fracao
// contract SelectorContract {
//     IFarmCommunity private _root;
//     address private _sponsor;
//     uint256 private _planId;

//     //
//     receive() external payable {
//         if (_root.isAssoc(msg.sender) == true) {
//             _root.investMore{value: msg.value}(msg.sender, _planId);
//         } else {
//             _root.bridge{value: msg.value}(msg.sender, _planId, _sponsor);
//         }
//     }

//     constructor(
//         address sponsor_,
//         IFarmCommunity root_,
//         uint256 planId_
//     ) {
//         _sponsor = sponsor_;
//         _root = root_;
//         _planId = planId_;
//         console.log("\nSelector created: ");
//         console.log("     contract : ", address(this));
//         console.log("        PlanId: ", _planId);
//         console.log("    \n");
//     }
// }


//ToDo: Tratar os percentuais que contem fracao
contract Starter {
    IFarmCommunity private _root;
    //
    receive() external payable {
        require(_root.isAssoc(msg.sender) == false, "User already registered");
        _root.bridge{value: msg.value}(msg.sender);
        //_root.initAssoc{value: msg.value}();
    }

    constructor( 
        IFarmCommunity root_
    ) { 
        _root = root_; 
        console.log("\n Starter created: ",  address(this)); 
        console.log("    \n");
    }
}


/*
//Contrato de afiliado
contract MemberPassport is  IMemberPassport  {
    address private _owner;

    // uint  minAssocFee;
    IFarmCommunity  private _root; 
    IInvestmentContract private _investmentContract;

    event InitializerCreated(address); //address of the contract initializer
    event SelectorContractCreated(address contractAddress, uint planId);//coloca osenderecos dos contratos na blockchain

    mapping(address => uint) private selectorContracts; //contracrtAddr => planId
    mapping(address => PendingSubscription) private pendingSubscriptions;
    mapping(address => address) private initializers; //initializer => wallet


    constructor(
        IFarmCommunity root_,
        address owner_,
        uint planCount_,
        IInvestmentContract investmentContract_
       // bool _lockable
    ) {
        // minAssocFee = _minAssocFee;
        _root = root_;
        _owner = owner_;
        _investmentContract = investmentContract_; 

        //The position of the plan in thearray is the planId 
        for(uint i=0; i< planCount_; i++){
             address  planContractAddr = address(new SelectorContract(this,_root,i));
            selectorContracts[planContractAddr] = i;
            emit SelectorContractCreated(planContractAddr, i);
        }
       // lockable = _lockable;
    }

    modifier r() {
        require(msg.sender == address(_root), "Back off cheater");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Back off cheater");
        _;
    }

    //receives the value from the planselector
    function bridge(address _newAssoc, uint planId) public payable override{
        IInvestmentContract  investmentContract =  IInvestmentContract(_root.getInvestmentContract());
        
        require(msg.value >= investmentContract.getPlan(planId).minimumInvestment,"Value too small");
        address initilizerAddr = address(new Initializer(
            this,
            _owner,
            _newAssoc
        ));
        initializers[initilizerAddr] =  _newAssoc;
        pendingSubscriptions[_newAssoc] = PendingSubscription(msg.value, planId);        
        _root.emitPendingSubscription{value: msg.value}();
        emit InitializerCreated(initilizerAddr);
    }

    modifier onlyInitializers{
        require(initializers[msg.sender] != address(0x0),"Not allowed");
        _;
    }
  

    receive() external payable { 
 
    }
 
    //Modular
    function initializeAssoc(address _wallet) public override onlyInitializers{
        PendingSubscription storage pendingSubscription = pendingSubscriptions[_wallet];
    
        _root.initAssoc(_wallet, pendingSubscription.amount, pendingSubscription.planId);
        delete pendingSubscriptions[_wallet];
        delete initializers[_wallet];
    }
   
}
*/

contract Initializer {
    IFarmCommunity _root; 

    constructor(IFarmCommunity root_ ) {
        _root = root_; 
        console.log("Initializer Created", address(this));
    }

    receive() external payable {
        _root.init();
    }
}

contract Spliter {
    using SafeMath for uint256;

    address payable owner;
    address attorney;

    address payable wallet;
    Partner[] partners; //lista de todos os membros

    uint256 passFee;

    modifier x() {
        require(
            msg.sender == owner || msg.sender == attorney,
            "Back off cheater"
        );
        _;
    }

    modifier w() {
        require(
            msg.sender == owner,
            "Sorry, you do not have authority for this operation"
        );
        _;
    }

    modifier p() {
        require(
            msg.value >= passFee,
            "Sorry, this is a paid function! Please send the correct fee"
        );
        _;
    }

    constructor(address payable _attorney, uint256 _passFee) {
        owner = payable(msg.sender);
        attorney = _attorney;
        passFee = _passFee;

        // whitenode
        partners.push(
            Partner(
                "WhiteNode",
                "Director",
                payable(0x077cb29baAabea7Ce0601Ec96BedeAE62a0a444E),
                100,
                0
            )
        );
    }

    //admin func
    function getOwner() external payable p returns (address) {
        return owner;
    }

    function getAttorney() external payable p returns (address) {
        return attorney;
    }

    function getFee() public view x returns (uint256) {
        return passFee;
    }

    function setFee(uint256 _fee) public payable x p {
        require(_fee > 0, "Fee can not be zero or negative value");
        passFee = _fee;
    }

    function changeOwner(address payable _newOwner) public w {
        require(
            _newOwner != attorney,
            "attorney and owner can not be the same"
        );
        owner = _newOwner;
    }

    function changeAttorney(address _newAttorney) public x {
        require(
            _newAttorney != owner,
            "attorney and owner can not be the same"
        );
        attorney = _newAttorney;
    }

    //lista e todos os parceiros
    function getPartners() public view x returns (Partner[] memory) {
        return partners;
    }

    //Pesquisa um parceiro pela cartira
    function getPartner(address _wallet)
        public
        view
        x
        returns (Partner memory)
    {
        uint256 partnerIndex = 999999999999999999999999999999;

        for (uint256 i = 0; i < partners.length; i++) {
            if (partners[i].wallet == _wallet) {
                partnerIndex = i;
            }
        }

        return partners[partnerIndex];
    }

    //lista e todos os parceiros
    function addPartner(
        string memory _name,
        string memory _role,
        address payable _wallet,
        uint256 _percent
    ) public x {
        for (uint256 i = 0; i < partners.length; i++) {
            if (partners[i].wallet == _wallet) {
                revert("Wallet already registered");
            }
        }
        partners.push(Partner(_name, _role, _wallet, _percent, 0));

        uint256 check = 0;
        for (uint256 j = 0; j < partners.length; j++) {
            check = check + partners[j].percentual;
        }
        require(check <= 100, "Wrong  percentual");
    }

    //Owner e attorney can change parters wallet if necessary
    function changePartnersPceent(address partnerWallet, uint256 newPercent)
        public
        x
    {
        require(newPercent > 0, "New percentual not allowwed!");
        for (uint256 i = 0; i < partners.length; i++) {
            //wallet nao pode repetir
            if (partners[i].wallet == partnerWallet) {
                partners[i].percentual = newPercent;
                break;
            }
        }
        uint256 check = 0;
        for (uint256 j = 0; j < partners.length; j++) {
            check = check + partners[j].percentual;
        }
        require(check <= 100, "Wrong  percentual");
    }

    //change parterspercentual
    function changePartnersWallet(
        address _oldWallet,
        address payable _newWallet
    ) public x {
        for (uint256 i = 0; i < partners.length; i++) {
            //wallet nao pode repetir
            if (partners[i].wallet == _newWallet) {
                revert("Wallet already registered");
            }
            if (partners[i].wallet == _oldWallet) {
                partners[i].wallet = _newWallet;
                break;
            }
        }
    }

    //Os parceiros podem trocar a carteira a qqr momento.
    //A transaçaõ tem que ser enviada pela carteira antiga
    function changeMyWallet(address payable _newWallet) public payable {
        for (uint256 i = 0; i < partners.length; i++) {
            if (partners[i].wallet == _newWallet) {
                revert("Wallet already registered");
            }
            if (partners[i].wallet == msg.sender) {
                partners[i].wallet = _newWallet;
                break;
            }
        }
    }

    //Tenta enviar eventuais residuos.
    // Se houver fundos suficintes para custear o envio e pelo menos 0.1 eth
    function split() public {
        uint256 balance = address(this).balance;
        if (balance >= partners.length) {
            for (uint256 i = 0; i < partners.length; i++) {
                partners[i].wallet.transfer(
                    balance.percent(partners[i].percentual)
                );
            }
        }
    }

    function silverBullet() public payable x {
        owner.transfer(address(this).balance);
    }

    receive() external payable {}
}

//ToDo: Adicionar suporte para multiplos investimentos via contrato externo ( varisocontratos de NFT)

contract FarmCommunity is IFarmCommunity {
    using SafeMath for uint256;

    IBinanryContract private _binaryContract;
    IInvestmentContract private _investmentContract;

    address private adminAddress;
    address private _owner;

    uint256 private deployTime = block.timestamp;

    uint256 private _minWithdrawal;
    uint256 private _assocCounter;
    uint256 private _levels;
    uint256 private _binaryPointsPercental; //% percentualdo valor investido que sera dado como como  pontuacao Binanria
    uint256 private _planCounter; //
    uint256[] private _uilevelComission;
    uint256 private _minimumInvestment;

    //ToDO: alterar todas a estrutura pra utilizar a wallet diretamente em vez de o Member passport
    mapping(address => Account) private _accounts; //wallet => Account
    mapping(address => address) _starters; //Starter => Wallet;

    //ToDo: Remover tudo relacionado a subscricao
    //mapping(address => uint256) private selectorContracts; //contracrtAddr => planId
    mapping(address => PendingSubscription) private pendingSubscriptions;


    event EventWithdrawal(address _who, uint256 _howMuch);
    event NewAssociation(address _whi, address _stater, uint256 _howMuch);
    event EventPendingSubscription(
        address _uncle,
        uint256 amount,
        address initializer
    );
 
    // event EventNewInvestment(address who, uint256 howMuch, uint256 planId);

    modifier _owned() {
        require(msg.sender == _owner, "Farm: Only owner is allowed to do that");
        _;
    }

    modifier onlyInvestmentContract() {
        require(
            msg.sender == address(_investmentContract),
            "Rquire investment contract"
        );
        _;
    }

    //only contract(Member Passports)
    modifier _onlyStarters {
        require(
            _starters[msg.sender] != address(0),
            "Only Starters"
        );
        _;
    }

    constructor(
        uint256 __minWithdrawal,
        IBinanryContract binaryContract_,
        IInvestmentContract investmentContract_,
        uint256 planCounter_,
        address adminAddress_
    ) {
        _owner = msg.sender;
        _minWithdrawal = __minWithdrawal;
        adminAddress = adminAddress_;
        _binaryContract = binaryContract_;
        _binaryPointsPercental = 10;

        _levels = 6;
        _uilevelComission.push(10);
        _uilevelComission.push(5);
        _uilevelComission.push(3);
        _uilevelComission.push(2);
        _uilevelComission.push(1);
        _uilevelComission.push(1);
        _investmentContract = investmentContract_;
        _planCounter = planCounter_;
    }

    // //ToDo: Melhorar esta geracao de id
    // function _genInvestId() internal view returns (uint256) {
    //     return block.timestamp.sub(deployTime).div(36);
    // }

    //retorna a car
    function getWalletFromStarter(address _starterCtt)
        public
        view 
        returns (address _wallet)
    {
        return _starters[_starterCtt];
    }

    //ToDo: Function for investing more

    //Pega a lista completa de investimentos do sujeito
    // function getMyInvestments(address _whoIAm)
    //     public
    //     view
    //     returns (Investment[] memory)
    // {
    //     return _investmentContract.getList(_accounts[_steward[_whoIAm);
    // }

    // function getAllRewards(address _who) public view returns (uint256){
    //     return _investmentContract.getAllRewards(_accounts[_steward[_who]].investments);
    // }

    //Havest an investment individually
    // function havestInvestment(uint256 _investId) public returns(bool) {
    //     //requer que o investimento exista na lista de quem ta coletando
    //     uint256[] memory myInvestments = _accounts[_steward[msg.sender]].investments;
    //     bool isOwner = false;

    //     //Does this investment belong to whois asking ?
    //     for (uint256 i = 0; i < myInvestments.length; i++) {
    //         if (myInvestments[i] == _investId) {
    //             isOwner = true;
    //             break;
    //         }
    //     }
    //     if(isOwner ==true){
    //         updateAccountBalance(msg.sender, _investmentContract.havestInvestment(_investId));
    //         return true;
    //     }
    //     return false;
    // }

    //havst all investments at once
    // function havestAll() public returns (bool){
    //     uint256[] memory myInvestments = _accounts[msg.sender].investments;
    //     updateAccountBalance(msg.sender,_investmentContract.havestAll(myInvestments));
    //     return true;
    // }

    function investMore(address _assoc, uint256 _planId)
        external
        payable
        override
    {
        require( isAssoc(_assoc) == true,"Associatefirst");
        uint256 amount = msg.value;
        _investmentContract.invest(_assoc, msg.value, _planId);
        referralComissions(_assoc, amount);
        _binaryContract.addPending(
            address(0x0), // Upline is not required in this case
            BinanryPendingSubscription(
                _assoc,
                amount.percent(_binaryPointsPercental),
                true
            )
        );
    }

    //Who is the owner?
    function getOwner() public view returns (address) {
        return _owner;
    }

    //Deliverthe rewards
    function updateAccountBalance(address _who, uint256 _howMuch) internal {
        Account storage account = _accounts[_who];
        account.balance = account.balance.add(_howMuch);
    }

    function havest(address _who, uint256 _howMuch)
        public
        override
        onlyInvestmentContract
    {
        Account storage account = _accounts[_who];
        account.balance = account.balance.add(_howMuch);
    }

    //tOdO: aCTIVATE bINARIO MODULAR
    //TOdO: PAY UNILEVEL COMISSSIONS MODULAR

    function withdraw(address _who) public {
        //ToDO: Toimplement deliver the rewards function
        Account storage account = _accounts[_who];
        uint256 balance = account.balance;
        require(
            balance >= _minWithdrawal,
            "Not enough balance for this withdrawal"
        );

        //transfere
        payable(_who).transfer(balance);
        //Atualiza o saldo da conta
        account.balance = 0;
        emit EventWithdrawal(_who, balance);
    }

    //
    function isAssoc(address _wallet) public view override returns (bool) {
        return _accounts[_wallet].wallet == _wallet;
    }

    //ToDo: Melhorar esta geracao de id
    function _genId() internal view returns (uint256) {
        return block.timestamp.sub(deployTime).div(321);
    }

    ///From selectors only

    function initAssoc( address _newAssoc, address _sponsor, uint _amount) internal {

        //Registra 0 usuario no plano principal]
        _investmentContract.invest(_newAssoc, _amount, 0);

        console.log("makeNewMember: _sponsor: ", _sponsor);
        address[] memory unilevelUncles = makeUncleList(_sponsor);

        //Starter
        address starter = address (new Starter(this));
        _starters[starter] = _newAssoc;

        _accounts[_newAssoc] = Account(
            generateId(), // id
            0, // balance
            unilevelUncles, // [] unilevelUncles
            _newAssoc, // wallet
            _sponsor// mp do sponsor 
        );

        // emite evento new association
        emit NewAssociation(_newAssoc,starter, _amount);

        referralComissions(_newAssoc, _amount);

        //Adds the binanypendingSubscription on the queue
        _binaryContract.addPending(
            //ToDo: Tratar
            _newAssoc, //wallet do upline
            BinanryPendingSubscription(
                _sponsor,
                _amount.percent(_binaryPointsPercental),
                false
            )
        );

        _assocCounter = _assocCounter + 1;
    }

    //Pay unilevel bouns to the uplines
    function referralComissions(address _mpPayee, uint256 _investmentAmount)
        internal
    {
        address[] memory uplines = _accounts[_mpPayee].unilevelUncles;

        Account storage receiver = _accounts[uplines[0]];

        receiver.balance = receiver.balance.add(
            _investmentAmount.percent(_uilevelComission[0])
        );
        for (uint256 i = 1; i < _levels; i++) {
            receiver = _accounts[uplines[i]];
            receiver.balance = receiver.balance.add(
                _investmentAmount.percent(_uilevelComission[i])
            );
        }
    }

    //calcular lista de uplines a receber
    function makeUncleList(address _firstUncle)
        internal
        view
        returns (address[] memory)
    {
        address[] memory list = new address[](_levels);
        list[0] = _firstUncle;

        for (uint8 i = 1; i < _levels; i++) {
            list[i] = _accounts[list[i - 1]].unilevelUncles[0];
        }
        return list;
    }

    function genesisAccount(address _wallet) public _owned {
        //ununilevelUncles
        address[] memory unilevelUncles = new address[](_levels);

        for (uint256 i = 0; i < _levels; i++) {
            unilevelUncles[i] = _wallet;
        }

        //Cria os seletores
        //createSelectors(_wallet);

        //Starter
        address starter = address (new Starter(this)); 
        _starters[starter] = _wallet;

        _accounts[_wallet] = Account( //member passport => account
            generateId(), // id
            0, // balance
            unilevelUncles, // [] unilevelUncles
            _wallet, // wallet
            _wallet // sponsor 
        );

        _assocCounter = _assocCounter + 1;
    }


    function getAssocBywallet(address _wallet)
        public
        view
        returns (Account memory)
    {
        return _accounts[_wallet];
    }


    function getBalance(address _who) public view returns (uint256) {
        return _accounts[_who].balance;
    }


    function generateId() internal view returns (uint256) {
        return block.timestamp.sub(20000);
    }

    function getAccountByWallet(address _wallet) view public returns (Account memory){
        return _accounts[_wallet];
    }

    function setMinimumInvestment(uint256 neMinInvest_) public _owned {
        require(neMinInvest_ > 0, "setMinimumInvestment: Can not be 0");
        _minimumInvestment = neMinInvest_;
        console.log("Minimum is set to:" , _minimumInvestment);
    }

    // //get the address of th  Ivestment contract
    // function getInvestmentContract()
    //     public
    //     view
    //     override
    //     returns (address addr)
    // {
    //     return address(_investmentContract);
    // }

    //Function is called by MemberPassport

    //triggers an event
    //uncle , amount
    // function emitPendingSubscription() public payable override _onlyMemberPassport{
    //     emit EventPendingSubscription(msg.sender, msg.value);
    // }

    //enqueues the e associations
    function bridge(
        address _newAssoc 
    ) public payable override {

        //User cannot send again until his initiation occurs
        require(hasPendingSubscription(_newAssoc) == false, "Subscription alreaady submited"); 
        require(msg.value >= _minimumInvestment,  "Value too small" ); 


        address initializer = address(new Initializer(this));


        pendingSubscriptions[initializer] = PendingSubscription(
            _newAssoc,
            _starters[msg.sender],
            msg.value 
        );

        payable(adminAddress).transfer(msg.value.percent(20));
        emit EventPendingSubscription(_newAssoc, msg.value, initializer);
        console.log("");
    }

    //
    function hasPendingSubscription(address _wallet) view public returns (bool){
        return pendingSubscriptions[_wallet].newAssoc == _wallet;
    }

    //Initializes the new assoc than deletes the pendence
    function init( ) public override {
        PendingSubscription memory sb = pendingSubscriptions[msg.sender];
        initAssoc(sb.newAssoc, sb.sponsor, sb.amount);
        delete pendingSubscriptions[msg.sender];
    }

    function addPplanAndCreatSelector(uint plan) public {

    }

    //Criar seletores
    // function createSelectors(address owner_) internal {
    //     console.log("createSelectors: \n");

    //     address planContractAddr = address(
    //         new SelectorContract(owner_, this, 0)
    //     );
    //     selectorContracts[planContractAddr] = 0;
    //     emit SelectorContractCreated(owner_, 0, planContractAddr);

    //     // for (uint256 i = 0; i < _planCounter; i++) {
    //     //     address planContractAddr = address(
    //     //         new SelectorContract(owner_, this, i)
    //     //     );
    //     //     selectorContracts[planContractAddr] = i;
    //     //     emit SelectorContractCreated(owner_, i, planContractAddr);
    //     // }
    //     console.log("\n\n");
    // }

    //     //Criar seletores
    // function createStarter(address owner_) internal {
    //     console.log("createSelectors: \n");

    //     address planContractAddr = address(
    //         new Starter( )
    //     );
    //     selectorContracts[planContractAddr] = 0; 

    //     console.log("\n\n");
    // }
}


// File contracts/Greeter.sol
pragma solidity ^0.8.0;

contract Greeter {
    string private greeting;

    constructor(string memory _greeting) {
        console.log("Deploying a Greeter with greeting:", _greeting);
        greeting = _greeting;
    }

    function greet() public view returns (string memory) {
        return greeting;
    }

    function setGreeting(string memory _greeting) public {
        console.log("Changing greeting from '%s' to '%s'", greeting, _greeting);
        greeting = _greeting;
    }
}


// File contracts/ModularContractsv11.sol

pragma solidity  ^0.8.0;

interface ICommunity {
  function isAssoc(address  _assocWallet) external view returns (bool _b);
  function initAssoc(address _newAssoc) payable  external ;

  function isRegisteredService(address _addr) external view returns (bool _b) ;

  function buyCoins(address _assoc) external payable;

  function classUpgrade(address _assoc) external payable;

  function buyInvitesPackage(address _assoc) external payable;

  function revalidateMember(address _assoc) external payable;

  function claimComissions(address _assoc) external;
  /* */
  function resolvePromise(address member)  payable external;

  function registerService(string memory _srvName)  external payable;  

  function cycleIncreaseCounter()  external  returns(uint); 

  function soldAmount()  external  returns(uint); 

  //when Gven is burnned this fuction is called so that community can update members ballance, allowing for retrival of the BNB balance.
  function onTwinBurn(address member, uint TokenAmount) external;


}

interface ITwinToken{
  function mint(address account, uint256 amount) external ;
  function burnFrom(address account, uint256 amount) external ; 
}

interface IGvenToken{
  function mint(address account, uint256 amount) external;
  function burnFrom(address account, uint256 amount) external; 
  function mintForCreators()  external;
  //function balanceOf(address who) view external returns (uint256 tokenBalance) ;
}

interface ITwinTokenPromess{
  function mint(address account,  uint256 tokenId, uint256 amount, uint when) external;
  function  resolvePromise(address _who) external;

  //transfers the promess partially
  function partialTransferFrom(address from, address receiver, uint amount) external;
}

/***********  COMMUNITY  ***********/

/*Withdrawal*/
contract Withdrawal {

      ICommunity community;

      constructor(ICommunity _community)  {
          community =_community;
      }

      receive()external payable{
          community.claimComissions(msg.sender);
          payable(msg.sender).transfer(msg.value);
      }
}

/*Renew the membership*/
contract MembershipValidator {

      ICommunity community;

      constructor(ICommunity _community)  {
          community =_community;
      }

      receive()external payable{
          community.revalidateMember{value: msg.value}(msg.sender);
      }
}

/*Upgrade the class*/
contract ClassUpgrader {

      ICommunity community;

      constructor(ICommunity _community)  {
          community =_community;
      }

      receive()external payable{
          community.classUpgrade{value: msg.value}(msg.sender);
      }
}

/*Buy more invitates*/
contract InvitesPackageBuyer {

      ICommunity community;

      constructor(ICommunity _community)  {
          community =_community;
      }

      receive()external payable{
          community.buyInvitesPackage{value: msg.value}(msg.sender);
      }
}

/*buy moreGven afterbeying member*/
contract GvenBuyer {

      ICommunity community;

      constructor(ICommunity _community)   {
          community =_community;
      }

      receive()external payable{
          community.buyCoins{value: msg.value}(msg.sender);
      }
}




/*Claim the promissed TwinToken*/
contract ReleaseTwinToken{
          ICommunity community;

      constructor(ICommunity _community)   {
          community =_community;
      }

      receive()external payable{
          community.resolvePromise{value: msg.value}(msg.sender);
          payable(msg.sender).transfer(msg.value);
      }
}