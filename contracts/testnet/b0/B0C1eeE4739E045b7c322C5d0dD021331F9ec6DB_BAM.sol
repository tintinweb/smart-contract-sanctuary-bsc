/**
 *Submitted for verification at BscScan.com on 2022-10-04
*/

// Sources flattened with hardhat v2.10.1 https://hardhat.org

// File hardhat/[email protected]

// 
pragma solidity >= 0.4.22 <0.9.0;

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


// File @openzeppelin/contracts/utils/[email protected]

// S
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


// File @openzeppelin/contracts/access/[email protected]

// S
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File @openzeppelin/contracts/security/[email protected]

// S
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


// File contracts/BAM.sol

// TODO: Suggest Ron to set a maximum transaction fee that can be set by the admin. Makes contract more trustable
// TODO: Make AddLiquidity only Ownable
//

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Import this file to use console.log


contract BAM is Ownable, ReentrancyGuard {
    uint256[5] public referralLevelCommission = [
        10 * 100,
        5 * 100,
        3 * 100,
        2 * 100,
        1 * 100
    ];

    /// @notice To check upto what level a user can get referral commisson based on staked amount
    /// @param _amount Staked amount
    /// @return 5  max level eligible for referral
    function maxEligibleLevelForReferralCommission(uint256 _amount)
        private
        pure
        returns (uint256)
    {
        if (_amount < 0.1 * 10**18) return 0;
        else if (_amount < 1 * 10**18) return 1;
        else if (_amount < 5 * 10**18) return 2;
        else if (_amount < 10 * 10**18) return 3;
        else return 4;
    }

    uint256 private constant percentageDivider = 10000;

    uint256 public minimumStakeValue;
    uint256 public maximumStakeValue;
    uint256 public maxStakedBalance;
    uint256 public maximumReturnPercentage;
    uint256 public minimumWithdrawalAmount;
    bool public isActive = true;

    address private nextOwner;

    uint256[] private pauseTime;
    uint256[] private resumeTime;
    // Indirect earnings to be updated as required. They will contribute to total earnings only if eligible
    struct Stake {
        bool isActive;
        uint256 stakedAmount; // amount staked
        uint256 activeStake; // amount after fee deduction
        uint256 dailyEarnings; // daily earnings per day
        uint256[5] referralEarning; // earnings from referral comissions that has been added to total earnings
        uint256[5] missedReferralEarnings; // referral earnings that has not contributed to total earnings
        uint256 withdrawalCommission;
        uint256 residualCommissionPerDay; // residual comission per day
        uint256 totalResidualCommission;
        uint256 totalEarnings; // total earnings
        uint256 lastUpdated; // time
        uint256 creationTime;
        uint256 dailyEarningRate;
        uint256 maxReferralLevel;
    }

    struct User {
        bool isRegistered;
        bool isSuspended;
        uint256 balance;
        uint256 withdrawalLimit;
        uint256[] withdrawals;
        uint256[] withdrawalTime;
        Stake activeStake;
        Stake[] previousStakes;
        address referredBy;
        uint256 downlineBalance;
        uint256[5] teamsize;
    }
    struct adminEarnings {
        uint256 totalEarnings;
        uint256 currentBalance;
        uint256 residualCommissionPerDay;
        uint256 lastUpdated;
    }

    struct Fee {
        uint256 fee;
        uint256 adminShare;
        uint256 liquidity;
        uint256 directSponsor;
        uint256 upline;
    }

    Fee depositFee =
        Fee({
            fee: 1000,
            adminShare: 2500,
            liquidity: 7500,
            directSponsor: 0,
            upline: 0
        });

    Fee withdrawalFee =
        Fee({
            fee: 1000,
            adminShare: 2500,
            liquidity: 6500,
            directSponsor: 1000,
            upline: 0
        });

    Fee performanceFee =
        Fee({
            fee: 1000,
            adminShare: 2500,
            liquidity: 6000,
            directSponsor: 0,
            upline: 1500
        });

    Fee referralCommissionFee =
        Fee({
            fee: 1000,
            adminShare: 2500,
            liquidity: 7500,
            directSponsor: 0,
            upline: 0
        });

    mapping(address => User) userDetails;

    event userRegisterd(address user, address referee);

    uint256 public totalBNBStaked;
    uint256 public totalBNBWithdrawan;
    uint256 public totalFeePaid;
    uint256 public startTime;
    uint256 public totalMembers;

    uint256 public dailyEarnings_A = 100; // Active Stake <= 100BNB
    uint256 public dailyEarnings_B = 125; //  100 BNB < Active Stake <= 250 BNB
    uint256 public dailyEarnings_C = 150; // 250BNB < Active Stake < 500BNB

    adminEarnings private AdminEarnings;

    event userSuspended(address user);
    event userReinstated(address user);
    event staked(address user, uint256 amount);

    constructor() {
        minimumStakeValue = 0.01 * (10**18); // 0.01 BNB
        maximumStakeValue = 500 * (10**18); // 500 BNB
        maxStakedBalance = 500 * (10**18); // 500 BNB
        minimumWithdrawalAmount = 0.01 * (10**18); // 0.01 BNB

        isActive = true;

        userDetails[msg.sender].isRegistered = true;
        AdminEarnings = adminEarnings({
            totalEarnings: 0,
            currentBalance: 0,
            residualCommissionPerDay: 0,
            lastUpdated: block.timestamp
        });
        startTime = block.timestamp;
        maximumReturnPercentage = 25000;
    }

    /// @notice To add additional liquidity to smart contract
    function AddLiquidity() external payable onlyOwner {}

    /// @notice To register new user under a referee
    /// @param _referee -> _referee address
    function registerUser(address _referee) external {
        require(
            userDetails[msg.sender].isRegistered == false,
            "B.A.M:User already registered"
        );
        require(
            userDetails[_referee].isRegistered,
            "B.A.M:Referee not a registered user"
        );
        require(
            userDetails[_referee].isSuspended == false,
            "B.A.M:Referee is Suspended"
        );
        require(isActive, "B.A.M:Project Paused");

        address origialReferee = _referee;
        userDetails[msg.sender].referredBy = _referee;
        userDetails[msg.sender].isRegistered = true;

        for (uint8 i = 0; i < 5; i++) {
            if (_referee == owner()) break;
            else {
                userDetails[_referee].teamsize[i] += 1;
                _referee = userDetails[_referee].referredBy;
            }
        }
        totalMembers += 1;
        emit userRegisterd(msg.sender, origialReferee);
    }

    /// @notice For owner to change deposit fee
    /// @param _fee:  % to deduct from transaction amount * 100
    /// @param _adminShare new admin's share in deducted fee * 100
    /// @param _liquidity new share of fee to be stored in smart contract *100
    function changeDepositFee(
        uint256 _fee,
        uint256 _adminShare,
        uint256 _liquidity
    ) external onlyOwner {
        require(_fee <= 2000, "B.A.M :Fees cannot exceed 20%");
        require(isActive, "B.A.M : Project Paused");
        uint256 total = _adminShare + _liquidity;
        require(total == 10000, "B.A.M : Incorrect Distribution");
        depositFee.fee = _fee * 100;
        depositFee.adminShare = _adminShare;
        depositFee.liquidity = _liquidity;
    }

    /// @notice For owner to change withdrawal fee
    /// @param _fee:  % to deduct from transaction amount
    /// @param _adminShare admin's share in deducted fee * 100
    /// @param _liquidity share of fee to be stored in smart contract *100
    /// @param _directSponsor share of fee to be sent to direct sponsor * 100
    function changeWithdrawalFee(
        uint256 _fee,
        uint256 _adminShare,
        uint256 _liquidity,
        uint256 _directSponsor
    ) external onlyOwner {
        require(_fee <= 2000, "B.A.M :Fees cannot exceed 20%");

        require(isActive, "B.A.M:Project Paused");

        uint256 total = _adminShare + _liquidity + _directSponsor;
        require(total == 10000, "B.A.M:Incorrect Distribution");
        withdrawalFee.fee = _fee;
        withdrawalFee.adminShare = _adminShare;
        withdrawalFee.liquidity = _liquidity;
        withdrawalFee.directSponsor = _directSponsor;
    }

    /// @notice For owner to change Performance fee
    /// @param _fee:  % to deduct from transaction amount * 100
    /// @param _adminShare admin's share in deducted fee * 100
    /// @param _liquidity share of fee to be stored in smart contract * 100
    /// @param _upline share of fee to be shared with upper levels * 100
    function changePerformanceFee(
        uint256 _fee,
        uint256 _adminShare,
        uint256 _liquidity,
        uint256 _upline
    ) external onlyOwner {
        require(_fee <= 2000, "B.A.M :Fees cannot exceed 20%");

        require(isActive, "B.A.M:Project Paused");

        require(
            _adminShare + _liquidity + _upline == 10000,
            "B.A.M:Incorrect Distribution"
        );
        performanceFee.fee = _fee;
        performanceFee.adminShare = _adminShare;
        performanceFee.liquidity = _liquidity;
        performanceFee.upline = _upline;
    }

    /// @notice For owner to change Referral Commission fee
    /// @param _fee:  % to deduct from transaction amount * 100
    /// @param _adminShare admin's share in deducted fee * 100
    /// @param _liquidity share of fee to be stored in smart contract * 100
    function changeReferralCommissionFee(
        uint256 _fee,
        uint256 _adminShare,
        uint256 _liquidity
    ) external onlyOwner {
        require(_fee <= 2000, "B.A.M :Fees cannot exceed 20%");

        require(isActive, "B.A.M:Project Paused");
        require(
            _adminShare + _liquidity == 10000,
            "B.A.M:Incorrect Distribution"
        );
        referralCommissionFee.fee = _fee;
        referralCommissionFee.adminShare = _adminShare;
        referralCommissionFee.liquidity = _liquidity;
    }

    /// @notice For owner to change daily earnings rate for :
    /// @param _rate_A:  new daily earnings percentage * 100 | Active Stake <= 100BNB
    /// @param _rate_B:  new daily earnings percentage * 100 | 100 BNB < Active Stake <= 250 BNB
    /// @param _rate_C:  new daily earnings percentage * 100 | 250BNB < Active Stake < 500BNB
    function ChangeEarningsRate(
        uint256 _rate_A,
        uint256 _rate_B,
        uint256 _rate_C
    ) external onlyOwner {
        require(_rate_A > 0, "B.A.M: Earning rate cannot be zero");
        require(_rate_B > 0, "B.A.M: Earning rate cannot be zero");
        require(_rate_C > 0, "B.A.M: Earning rate cannot be zero");

        require(isActive, "B.A.M:Project Paused");
        dailyEarnings_A = _rate_A;
        dailyEarnings_B = _rate_B;
        dailyEarnings_C = _rate_C;
    }

    /// @notice To change minimum staking amount
    /// @param _minStake - new minimum stake.
    function ChangeMinStake(uint256 _minStake) external onlyOwner {
        require(isActive, "B.A.M:Project Paused");
        minimumStakeValue = _minStake;
    }

    /// @notice To change maximum staking amount
    /// @param _maxStake - new maximum stake.
    function ChangeMaxStake(uint256 _maxStake) external onlyOwner {
        require(isActive, "B.A.M:Project Paused");
        maximumStakeValue = _maxStake;
    }

    function getEarningsRate(uint256 _amount) public view returns (uint256) {
        if (_amount <= 100 * (10**18)) {
            return dailyEarnings_A;
        } else if (_amount <= 250 * (10**18)) {
            return dailyEarnings_B;
        } else return dailyEarnings_C;
    }

    /// @notice To check if a user's active stake has reached it's theshold.
    /// @dev Presence of active stake must be checked before calling this function | Upadate earnings must be called before using this function
    /// @param _user address of user
    function checkBreakThrough(address _user) private {
        if (!isActive) return;

        if (userDetails[_user].activeStake.totalEarnings >= maxReturn(_user)) {
            uint256 activeStake = userDetails[_user].activeStake.activeStake;
            console.log("IN1");
            uint256 dailyEarnings = (getEarningsRate(activeStake) *
                activeStake) / percentageDivider;
            console.log("IN2");

            uint256 feeOnDailyEarnings = (performanceFee.fee * dailyEarnings) /
                percentageDivider;
            console.log("IN3");

            uint256 adminShare = (feeOnDailyEarnings *
                performanceFee.adminShare) / percentageDivider;
            console.log("IN4");

            uint256 uplineShare = (feeOnDailyEarnings * performanceFee.upline) /
                percentageDivider;
            console.log("IN5");

            updateAdminEarnings();
            console.log("IN6");

            AdminEarnings.residualCommissionPerDay = (
                AdminEarnings.residualCommissionPerDay < adminShare
                    ? 0
                    : AdminEarnings.residualCommissionPerDay - adminShare
            );
            console.log("IN7");

            uint256 perRefereeShare = uplineShare / 5;

            address referee = userDetails[_user].referredBy;
            console.log("IN8");

            for (uint8 i = 0; i < 5; i++) {
                if (referee == owner()) {
                    AdminEarnings.residualCommissionPerDay = (
                        AdminEarnings.residualCommissionPerDay < perRefereeShare
                            ? 0
                            : AdminEarnings.residualCommissionPerDay -
                                perRefereeShare
                    );

                    console.log("IN10");
                } else if (userDetails[referee].activeStake.isActive) {
                    updateUserEarnings(referee);

                    if (userDetails[referee].activeStake.isActive) {
                        if (
                            userDetails[_user].activeStake.activeStake >=
                            userDetails[referee].downlineBalance
                        ) {
                            userDetails[referee].downlineBalance -= userDetails[
                                _user
                            ].activeStake.activeStake;
                        }
                        userDetails[referee]
                            .activeStake
                            .residualCommissionPerDay = (
                            userDetails[referee]
                                .activeStake
                                .residualCommissionPerDay < perRefereeShare
                                ? 0
                                : userDetails[referee]
                                    .activeStake
                                    .residualCommissionPerDay - perRefereeShare
                        );
                    }
                }
                referee = userDetails[_user].referredBy;
            }

            userDetails[_user].activeStake.isActive = false;
            userDetails[_user].previousStakes.push(
                userDetails[_user].activeStake
            );
        }
    }

    /// @notice To deduct Deposit Fees
    /// @param _amount transaction amount
    /// @return amountAfterDeduction amount after deducting Fees
    function deductDepositFee(uint256 _amount) private returns (uint256) {
        uint256 fee = (_amount * depositFee.fee) / (percentageDivider);
        uint256 amountAfterDeduction = _amount - fee;

        uint256 adminShare = (fee * depositFee.adminShare) /
            (percentageDivider);

        totalFeePaid += fee;
        // No need to transfer liquidity share
        AdminEarnings.currentBalance += adminShare;
        AdminEarnings.totalEarnings += adminShare;

        return amountAfterDeduction;
    }

    /// @notice To deduct Performance Fees
    /// @param _amount transaction amount
    /// @param _user user's address
    /// @return amountAfterDeduction amount after deducting Fees
    function deductPerformanceFee(uint256 _amount, address _user)
        private
        returns (uint256)
    {
        uint256 fee = (_amount * performanceFee.fee) / (percentageDivider);
        uint256 amountAfterDeduction = _amount - fee;

        uint256 adminShare = (fee * performanceFee.adminShare) /
            (percentageDivider);

        uint256 uplineShare = (fee * performanceFee.upline) /
            (percentageDivider);
        uint256 perRefereeShare = uplineShare / 5;

        address referee = userDetails[_user].referredBy;

        AdminEarnings.residualCommissionPerDay += adminShare;

        for (uint8 i = 0; i < 5; i++) {
            if (referee == owner()) {
                AdminEarnings.residualCommissionPerDay += perRefereeShare;
                break;
            } else if (userDetails[referee].activeStake.isActive) {
                if (userDetails[referee].isSuspended) {
                    continue;
                }
                userDetails[referee]
                    .activeStake
                    .residualCommissionPerDay += perRefereeShare;
            }
            referee = userDetails[_user].referredBy;
        }

        totalFeePaid += fee;

        return amountAfterDeduction;
    }

    /// @notice To deduct Referral Fees
    /// @param _amount transaction amount
    /// @return amountAfterDeduction amount after deducting Fees
    function deductReferralFee(uint256 _amount) private returns (uint256) {
        uint256 fee = (_amount * referralCommissionFee.fee) /
            (percentageDivider);

        uint256 amountAfterDeduction = _amount - fee;

        uint256 adminShare = (fee * referralCommissionFee.adminShare) /
            (percentageDivider);

        AdminEarnings.currentBalance += adminShare;
        AdminEarnings.totalEarnings += adminShare;

        totalFeePaid += fee;

        return amountAfterDeduction;
    }

    /// @notice Deducts Anti-whale Tax
    /// @param _amount Transaction amount
    /// @return amountAfterDeduction Amount after tax deduction
    function deductAntiWhaleTax(uint256 _amount)
        private
        view
        returns (uint256)
    {
        uint256 contractBalance = address(this).balance;

        uint256 relativePercentage = (_amount * 100) / (contractBalance);

        if (relativePercentage > 10) relativePercentage = 10;

        uint256 taxPercentage = 5 * relativePercentage * 100;

        uint256 tax = (_amount * taxPercentage) / percentageDivider;

        uint256 amountAfterDeduction = _amount - tax;

        return amountAfterDeduction;
    }

    /// @notice To deduct withdrawal Fees
    /// @param _amount transaction amount
    /// @param _user user's address
    /// @return amountAfterDeduction amount after deducting Fees
    function deductWithdrawalFees(uint256 _amount, address _user)
        private
        returns (uint256)
    {
        uint256 fee = (_amount * withdrawalFee.fee) / percentageDivider;
        uint256 amountAfterDeduction = _amount - fee;

        uint256 adminShare = (fee * withdrawalFee.adminShare) /
            percentageDivider;

        uint256 directSponsorShare = (fee * withdrawalFee.directSponsor) /
            percentageDivider;

        address directSponsor = userDetails[_user].referredBy;

        AdminEarnings.currentBalance += adminShare;
        AdminEarnings.totalEarnings += adminShare;
        if (directSponsor == owner()) {
            AdminEarnings.currentBalance += directSponsorShare;
            AdminEarnings.totalEarnings += directSponsorShare;
        } else {
            updateUserEarnings(directSponsor);
            if (userDetails[directSponsor].activeStake.isActive) {
                uint256 maxAmountToAdd = maxReturn(directSponsor) -
                    userDetails[directSponsor].activeStake.totalEarnings;

                uint256 amountToAdd = min(directSponsorShare, maxAmountToAdd);

                userDetails[directSponsor]
                    .activeStake
                    .withdrawalCommission += amountToAdd;

                userDetails[directSponsor]
                    .activeStake
                    .totalEarnings += amountToAdd;

                userDetails[directSponsor].balance += amountToAdd;

                checkBreakThrough(directSponsor);
            }
        }

        amountAfterDeduction = deductAntiWhaleTax(amountAfterDeduction);

        totalFeePaid += fee;

        return amountAfterDeduction;
    }

    /// @notice To add a referee's referral commissions
    /// @param _amount referral commission amount
    /// @param _referee referee address
    function addReferralCommissionToReferee(
        uint256 _amount,
        address _referee,
        uint256 _referralLevel
    ) private {
        if (_referee == owner()) {
            AdminEarnings.totalEarnings += _amount;
            AdminEarnings.currentBalance += _amount;
        } else if (userDetails[_referee].activeStake.isActive) {
            uint256 amountAfterFee = deductReferralFee(_amount);
            // No update if referee is suspended

            if (userDetails[_referee].isSuspended) {
                return;
            }
            uint256 maxEligibleLevel = maxEligibleLevelForReferralCommission(
                userDetails[_referee].activeStake.stakedAmount
            );

            console.log("maxLEVEL", maxEligibleLevel);
            if (maxEligibleLevel >= _referralLevel) {
                uint256 maxAmountToAdd = maxReturn(_referee) -
                    userDetails[_referee].activeStake.totalEarnings;

                uint256 amountToAdd = min(_amount, maxAmountToAdd);

                userDetails[_referee].activeStake.referralEarning[
                        _referralLevel
                    ] += amountToAdd;

                userDetails[_referee].activeStake.totalEarnings += amountToAdd;

                userDetails[_referee].balance += amountToAdd;

                checkBreakThrough(_referee);
            } else {
                userDetails[_referee].activeStake.missedReferralEarnings[
                        _referralLevel
                    ] += amountAfterFee;
            }
        }
    }

    /// @notice To distribute referral commissions whenever a user stakes
    /// @param _amount Transaction Amount
    /// @param _user Staker's address
    function distributeReferralCommissions(uint256 _amount, address _user)
        private
    {
        address _referee = userDetails[_user].referredBy;
        for (uint8 i = 0; i < 5; i++) {
            uint256 referralCommission = (referralLevelCommission[i] *
                _amount) / (percentageDivider);
            addReferralCommissionToReferee(referralCommission, _referee, i);
            if (_referee == owner()) {
                break;
            }
            _referee = userDetails[_referee].referredBy;
        }
    }

    /// @notice To stake BNB
    /// @dev Checks for presence of active stake. If present adds BNB to it, else creates a new stake.
    function stakeBNB() external payable {
        require(msg.sender != owner(), "Owner cannot stake");
        require(userDetails[msg.sender].isRegistered, "Unregistered user");
        require(!userDetails[msg.sender].isSuspended, "User suspended");

        require(
            msg.value >= minimumStakeValue,
            "B.A.M:Amount less than minimun required"
        );

        require(
            msg.value <= maximumStakeValue,
            "B.A.M:Amount exceeds maximum allowed"
        );

        require(isActive, "B.A.M:Project paused");
        if (!userDetails[msg.sender].activeStake.isActive) {
            // No Active Stake Present

            Stake memory newStake;

            newStake.isActive = true;
            newStake.residualCommissionPerDay = 0;
            newStake.totalEarnings = 0;
            newStake.lastUpdated = block.timestamp;
            newStake.stakedAmount = 0;
            newStake.activeStake = 0;
            newStake.dailyEarnings = 0;
            newStake.maxReferralLevel = 0;
            newStake.withdrawalCommission = 0;
            newStake.dailyEarningRate = 0;
            newStake.creationTime = block.timestamp;
            // Reset arrays
            delete newStake.referralEarning;
            delete newStake.missedReferralEarnings;
            //Reset withdrawal limit
            userDetails[msg.sender].withdrawalLimit = 0;

            userDetails[msg.sender].activeStake = newStake;
        }

        uint256 amount = msg.value;

        uint256 currentStake = userDetails[msg.sender].activeStake.stakedAmount;
        require(
            currentStake + msg.value <= maxStakedBalance,
            "B.A.M:Total Stake exceeds maximum allowed"
        );

        // Previous stake present
        if (userDetails[msg.sender].activeStake.lastUpdated < block.timestamp) {
            updateUserEarnings(msg.sender);
        }

        address referee = userDetails[msg.sender].referredBy;

        uint256 amountAfterDeduction = deductDepositFee(amount);

        // update earnings for all referee to handle performance commission, referral commission
        for (uint8 i = 0; i < 5; i++) {
            {
                if (referee == owner()) {
                    updateAdminEarnings();
                    break;
                } else {
                    userDetails[referee]
                        .downlineBalance += amountAfterDeduction;
                    if (userDetails[referee].activeStake.isActive) {
                        updateUserEarnings(referee);
                    }
                    referee = userDetails[referee].referredBy;
                }
            }
        }

        uint256 additionalDailyEarnings = (getEarningsRate(
            amountAfterDeduction
        ) * amountAfterDeduction) / percentageDivider;

        uint256 additionalDailyEarningsAfterFeeDeduction = deductPerformanceFee(
            additionalDailyEarnings,
            msg.sender
        );

        // Update Referral Commissions
        distributeReferralCommissions(amount, msg.sender);

        userDetails[msg.sender].activeStake.stakedAmount += msg.value;
        userDetails[msg.sender].activeStake.activeStake += amountAfterDeduction;
        userDetails[msg.sender]
            .activeStake
            .dailyEarnings += additionalDailyEarningsAfterFeeDeduction;

        userDetails[msg.sender]
            .activeStake
            .maxReferralLevel = maxEligibleLevelForReferralCommission(
            userDetails[msg.sender].activeStake.stakedAmount
        );

        userDetails[msg.sender].activeStake.dailyEarningRate = getEarningsRate(
            userDetails[msg.sender].activeStake.stakedAmount
        );

        userDetails[msg.sender].withdrawalLimit += msg.value;

        totalBNBStaked += msg.value;

        emit staked(msg.sender, msg.value);
    }

    /// @notice For admin to suspend a user. A suspended user will not have any earnings after suspension.
    /// @param _user address of user to be suspended
    function suspendUser(address _user) external onlyOwner {
        require(isActive, "B.A.M:Project Paused");

        require(userDetails[_user].isRegistered, "B.A.M:Unregistered user");
        require(
            !userDetails[_user].isSuspended,
            "B.A.M:User already suspended"
        );

        updateUserEarnings(_user);
        userDetails[_user].isSuspended = true;
        emit userSuspended(_user);
    }

    /// @notice For admin to re-instate a suspended user. User will start recieving all earnings now.
    /// @param _user address of user to be suspended
    function reinstateUser(address _user) external onlyOwner {
        require(isActive, "B.A.M:Project Paused");
        require(userDetails[_user].isRegistered, "B.A.M:User not registered");
        require(userDetails[_user].isSuspended, "B.A.M:User already active");

        userDetails[_user].isSuspended = true;
        if (userDetails[_user].activeStake.isActive) {
            userDetails[_user].activeStake.lastUpdated = block.timestamp;
        }
        emit userReinstated(_user);
    }

    ///@notice To update user's earnings via private calls
    ///@dev presense of active stake should be checked before calling this function
    function updateUserEarnings(address _user) private {
        if (userDetails[_user].isSuspended) return;
        if (!isActive) return;

        if (userDetails[_user].activeStake.isActive) {
            uint256 timePassed;
            uint256 lastUpdated = userDetails[_user].activeStake.lastUpdated;
            uint256 pauseTimeLength = pauseTime.length;

            if (pauseTimeLength > 0) {
                for (uint256 i = 0; i < pauseTimeLength; i++) {
                    if (lastUpdated < pauseTime[i]) {
                        timePassed = pauseTime[i] - lastUpdated;
                        lastUpdated = resumeTime[i];
                    }
                }
            }

            timePassed += block.timestamp - lastUpdated;

            uint256 daysPassed = timePassed / (1 days);

            uint256 perDayEarnings = userDetails[_user]
                .activeStake
                .dailyEarnings;

            if (userDetails[_user].downlineBalance > 100 * 10**18)
                perDayEarnings += userDetails[_user]
                    .activeStake
                    .residualCommissionPerDay;

            uint256 earnings = (perDayEarnings * daysPassed);

            userDetails[_user].activeStake.totalResidualCommission +=
                userDetails[_user].activeStake.residualCommissionPerDay *
                daysPassed;
            uint256 maxAmountToAdd = maxReturn(_user) -
                userDetails[_user].activeStake.totalEarnings;
            uint256 amountToAdd = min(earnings, maxAmountToAdd);

            userDetails[_user].activeStake.totalEarnings += amountToAdd;
            userDetails[_user].balance += amountToAdd;
            userDetails[_user].activeStake.lastUpdated = block.timestamp;

            checkBreakThrough(_user);
        }
    }

    ///@notice To see user's maximum return
    ///@dev presense of active stake should be checked before calling this function
    ///@param _user user's address
    function maxReturn(address _user) private view returns (uint256) {
        return
            (userDetails[_user].activeStake.stakedAmount *
                maximumReturnPercentage) / percentageDivider;
    }

    /// @notice To update Admins Earnings
    function updateAdminEarnings() private {
        uint256 timePassed;
        uint256 lastUpdated = AdminEarnings.lastUpdated;
        uint256 pauseTimeLength = pauseTime.length;

        if (pauseTimeLength > 0) {
            for (uint256 i = 0; i < pauseTimeLength; i++) {
                if (lastUpdated < pauseTime[i]) {
                    timePassed = pauseTime[i] - lastUpdated;
                    lastUpdated = resumeTime[i];
                }
            }
        }

        timePassed += block.timestamp - lastUpdated;

        uint256 daysPassed = timePassed / (1 days);

        uint256 amountToAdd = (AdminEarnings.residualCommissionPerDay *
            daysPassed);
        AdminEarnings.totalEarnings += amountToAdd;
        AdminEarnings.currentBalance += amountToAdd;
    }

    /// @notice To see Admins Total Earnings
    function AdminTotalEarnings() public view returns (uint256) {
        uint256 timePassed;
        uint256 lastUpdated = AdminEarnings.lastUpdated;
        uint256 pauseTimeLength = pauseTime.length;

        if (pauseTimeLength > 0) {
            for (uint256 i = 0; i < pauseTimeLength; i++) {
                if (lastUpdated < pauseTime[i]) {
                    timePassed = pauseTime[i] - lastUpdated;
                    lastUpdated = resumeTime[i];
                }
            }
        }

        timePassed += block.timestamp - lastUpdated;

        uint256 daysPassed = timePassed / (1 days);
        uint256 amountToAdd = (AdminEarnings.residualCommissionPerDay *
            daysPassed);
        uint256 earnings = AdminEarnings.totalEarnings + amountToAdd;

        return earnings;
    }

    /// @notice To see Admins current Balance
    function AdminCurrentBalance() public view returns (uint256) {
        uint256 timePassed;
        uint256 lastUpdated = AdminEarnings.lastUpdated;
        uint256 pauseTimeLength = pauseTime.length;

        if (pauseTimeLength > 0) {
            for (uint256 i = 0; i < pauseTimeLength; i++) {
                if (lastUpdated < pauseTime[i]) {
                    timePassed = pauseTime[i] - lastUpdated;
                    lastUpdated = resumeTime[i];
                }
            }
        }

        timePassed += block.timestamp - lastUpdated;

        uint256 daysPassed = timePassed / (1 days);
        uint256 amountToAdd = (AdminEarnings.residualCommissionPerDay *
            daysPassed);
        uint256 earnings = AdminEarnings.currentBalance + amountToAdd;
        return earnings;
    }

    /// @notice For Admin to withdraw their earnings
    /// @param _amount amount to withdraw
    function WithdrawAdminEarnings(uint256 _amount)
        external
        onlyOwner
        nonReentrant
    {
        require(isActive, "B.A.M:Project Paused");
        updateAdminEarnings();
        require(
            AdminEarnings.currentBalance >= _amount,
            "B.A.M:Not enough admin earnings"
        );

        AdminEarnings.currentBalance -= _amount;
        (bool sent, bytes memory data) = payable(owner()).call{value: _amount}(
            ""
        );

        totalBNBWithdrawan += _amount;

        require(sent, "B.A.M:Failed to send BNB");
    }

    /// @notice To check amount user can withdraw considering 24 hour withdrawal limit
    /// @param _user user's address
    /// @return amount that can be withdrawan
    function maxAllowedWithdrawal(address _user) public view returns (uint256) {
        if (!isActive) return 0;
        uint256 _24HourWithdrawals;
        uint256 userWithdrawalLimit = userDetails[_user].withdrawalLimit;
        uint256[] memory withdrawals = userDetails[_user].withdrawals;
        uint256[] memory withdrawalTime = userDetails[_user].withdrawalTime;

        for (uint256 i = withdrawals.length - 1; i >= 0; i--) {
            if (withdrawalTime[i] <= (block.timestamp - 1 days)) {
                _24HourWithdrawals += withdrawals[i];
                if (_24HourWithdrawals >= userWithdrawalLimit) {
                    break;
                }
            } else {
                break;
            }
        }
        if (_24HourWithdrawals > userWithdrawalLimit) {
            return 0;
        }
        unchecked {
            return userWithdrawalLimit - _24HourWithdrawals;
        }
    }

    /// @notice For users to withdraw their earnings
    /// @param _amount amount to withdraw
    function withdrawEarnings(uint256 _amount) external nonReentrant {
        require(msg.sender != owner(), "B.A.M:Not for owner");
        require(isActive, "B.A.M:Project paused");

        require(
            userDetails[msg.sender].isRegistered,
            "B.A.M:Unregistered user"
        );
        require(!userDetails[msg.sender].isSuspended, "B.A.M:User Suspended");
        updateUserEarnings(msg.sender);
        require(
            _amount <= userDetails[msg.sender].balance,
            "Not enough earnings"
        );
        require(_amount <= address(this).balance, "B.A.M:Insufficient funds");

        require(
            _amount <= maxAllowedWithdrawal(msg.sender),
            "B.A.M:24 hour withdrawal limit exceeded"
        );

        uint256 amountAfterDeduction = deductWithdrawalFees(
            _amount,
            msg.sender
        );

        (bool sent, bytes memory data) = payable(msg.sender).call{
            value: amountAfterDeduction
        }("");

        totalBNBWithdrawan += _amount;

        require(sent, "B.A.M:Failed to send BNB");
    }

    /// @notice Overridding transferOwnership
    /// @param _newOwner _newOwner's address
    function transferOwnership(address _newOwner)
        public
        virtual
        override(Ownable)
        onlyOwner
    {
        require(
            _newOwner != address(0),
            "Ownable: new owner is the zero address"
        );

        require(isActive, "B.A.M:Project Paused");
        require(!userDetails[_newOwner].isRegistered, "B.A.M:Invalid user");
        require(nextOwner != owner(), "B.A.M:Next owner same as current owner");
        nextOwner = _newOwner;
    }

    /// @notice For new owner to accept ownership
    function acceptOwnerShip() external {
        require(msg.sender == nextOwner, "B.A.M : Not next owner");
        _transferOwnership(nextOwner);
        nextOwner = address(0);
    }

    /// @notice For Owner to pause contracts functionality
    function pauseContract() external onlyOwner {
        require(isActive == true, "B.A.M:Contract already paused");
        isActive = false;
        pauseTime.push(block.timestamp);
    }

    /// @notice For Owner to resume contracts functionality
    function resumeContract() external onlyOwner {
        require(isActive == false, "B.A.M:Contract already active");
        isActive = true;
        resumeTime.push(block.timestamp);
    }

    /// @notice To view details about a user's active stake
    /// @param _user user's address
    /// @return user's current active stake details
    function viewUserStake(address _user) external view returns (Stake memory) {
        Stake memory userStake;

        if (
            !userDetails[_user].activeStake.isActive ||
            userDetails[_user].isSuspended
        ) {
            return userStake;
        }
        userStake = userDetails[_user].activeStake;

        uint256 timePassed;
        uint256 lastUpdated = userDetails[_user].activeStake.lastUpdated;
        uint256 pauseTimeLength = pauseTime.length;

        if (pauseTimeLength > 0) {
            for (uint256 i = 0; i < pauseTimeLength; i++) {
                if (lastUpdated < pauseTime[i]) {
                    timePassed = pauseTime[i] - lastUpdated;
                    lastUpdated = resumeTime[i];
                }
            }
        }

        timePassed += block.timestamp - lastUpdated;

        uint256 daysPassed = timePassed / (1 days);

        uint256 perDayEarnings = userDetails[_user].activeStake.dailyEarnings;

        if (userDetails[_user].downlineBalance > 100 * 10**18)
            perDayEarnings += userDetails[_user]
                .activeStake
                .residualCommissionPerDay;

        uint256 earnings = (perDayEarnings * daysPassed);

        uint256 maxAmountToAdd = maxReturn(_user) -
            userDetails[_user].activeStake.totalEarnings;
        uint256 amountToAdd = min(earnings, maxAmountToAdd);

        userStake.totalEarnings += amountToAdd;
        userStake.lastUpdated += block.timestamp;
        return userStake;
    }

    /// @notice To view details about a user's active balance
    /// @param _user user's address
    /// @return user's current balance
    function viewUserBalance(address _user) external view returns (uint256) {
        Stake memory userStake;
        uint256 amountToAdd;
        userStake = userDetails[_user].activeStake;

        if (userStake.isActive) {
            uint256 timePassed;
            uint256 lastUpdated = userDetails[_user].activeStake.lastUpdated;
            uint256 pauseTimeLength = pauseTime.length;

            if (pauseTimeLength > 0) {
                for (uint256 i = 0; i < pauseTimeLength; i++) {
                    if (lastUpdated < pauseTime[i]) {
                        timePassed = pauseTime[i] - lastUpdated;
                        lastUpdated = resumeTime[i];
                    }
                }
            }

            timePassed += block.timestamp - lastUpdated;

            uint256 daysPassed = timePassed / (1 days);

            uint256 perDayEarnings = userDetails[_user]
                .activeStake
                .dailyEarnings;

            if (userDetails[_user].downlineBalance > 100 * 10**18)
                perDayEarnings += userDetails[_user]
                    .activeStake
                    .residualCommissionPerDay;

            uint256 earnings = (perDayEarnings * daysPassed);

            uint256 maxAmountToAdd = maxReturn(_user) -
                userDetails[_user].activeStake.totalEarnings;
            amountToAdd = min(earnings, maxAmountToAdd);
        }

        uint256 userBalance = userDetails[_user].balance;

        userBalance += amountToAdd;

        return userBalance;
    }

    /// @notice To view a user's team size
    /// @param _user user's address
    /// @return userDetails[_user].teamsize
    function seeTeamSize(address _user)
        external
        view
        returns (uint256[5] memory)
    {
        uint256[5] memory teamsize = userDetails[_user].teamsize;
        return teamsize;
    }

    // utility function
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a <= b ? a : b;
    }
}