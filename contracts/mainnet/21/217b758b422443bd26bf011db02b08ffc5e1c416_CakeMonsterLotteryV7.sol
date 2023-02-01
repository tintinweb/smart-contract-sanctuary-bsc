/**
 *Submitted for verification at BscScan.com on 2023-02-01
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

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
    _sendLogPayload(abi.encodeWithSignature('log()'));
  }

  function logInt(int p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(int)', p0));
  }

  function logUint(uint p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint)', p0));
  }

  function logString(string memory p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string)', p0));
  }

  function logBool(bool p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool)', p0));
  }

  function logAddress(address p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address)', p0));
  }

  function logBytes(bytes memory p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bytes)', p0));
  }

  function logBytes1(bytes1 p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bytes1)', p0));
  }

  function logBytes2(bytes2 p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bytes2)', p0));
  }

  function logBytes3(bytes3 p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bytes3)', p0));
  }

  function logBytes4(bytes4 p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bytes4)', p0));
  }

  function logBytes5(bytes5 p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bytes5)', p0));
  }

  function logBytes6(bytes6 p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bytes6)', p0));
  }

  function logBytes7(bytes7 p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bytes7)', p0));
  }

  function logBytes8(bytes8 p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bytes8)', p0));
  }

  function logBytes9(bytes9 p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bytes9)', p0));
  }

  function logBytes10(bytes10 p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bytes10)', p0));
  }

  function logBytes11(bytes11 p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bytes11)', p0));
  }

  function logBytes12(bytes12 p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bytes12)', p0));
  }

  function logBytes13(bytes13 p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bytes13)', p0));
  }

  function logBytes14(bytes14 p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bytes14)', p0));
  }

  function logBytes15(bytes15 p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bytes15)', p0));
  }

  function logBytes16(bytes16 p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bytes16)', p0));
  }

  function logBytes17(bytes17 p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bytes17)', p0));
  }

  function logBytes18(bytes18 p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bytes18)', p0));
  }

  function logBytes19(bytes19 p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bytes19)', p0));
  }

  function logBytes20(bytes20 p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bytes20)', p0));
  }

  function logBytes21(bytes21 p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bytes21)', p0));
  }

  function logBytes22(bytes22 p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bytes22)', p0));
  }

  function logBytes23(bytes23 p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bytes23)', p0));
  }

  function logBytes24(bytes24 p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bytes24)', p0));
  }

  function logBytes25(bytes25 p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bytes25)', p0));
  }

  function logBytes26(bytes26 p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bytes26)', p0));
  }

  function logBytes27(bytes27 p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bytes27)', p0));
  }

  function logBytes28(bytes28 p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bytes28)', p0));
  }

  function logBytes29(bytes29 p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bytes29)', p0));
  }

  function logBytes30(bytes30 p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bytes30)', p0));
  }

  function logBytes31(bytes31 p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bytes31)', p0));
  }

  function logBytes32(bytes32 p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bytes32)', p0));
  }

  function log(uint p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint)', p0));
  }

  function log(string memory p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string)', p0));
  }

  function log(bool p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool)', p0));
  }

  function log(address p0) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address)', p0));
  }

  function log(uint p0, uint p1) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,uint)', p0, p1));
  }

  function log(uint p0, string memory p1) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,string)', p0, p1));
  }

  function log(uint p0, bool p1) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,bool)', p0, p1));
  }

  function log(uint p0, address p1) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,address)', p0, p1));
  }

  function log(string memory p0, uint p1) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,uint)', p0, p1));
  }

  function log(string memory p0, string memory p1) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,string)', p0, p1));
  }

  function log(string memory p0, bool p1) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,bool)', p0, p1));
  }

  function log(string memory p0, address p1) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,address)', p0, p1));
  }

  function log(bool p0, uint p1) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,uint)', p0, p1));
  }

  function log(bool p0, string memory p1) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,string)', p0, p1));
  }

  function log(bool p0, bool p1) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,bool)', p0, p1));
  }

  function log(bool p0, address p1) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,address)', p0, p1));
  }

  function log(address p0, uint p1) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,uint)', p0, p1));
  }

  function log(address p0, string memory p1) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,string)', p0, p1));
  }

  function log(address p0, bool p1) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,bool)', p0, p1));
  }

  function log(address p0, address p1) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,address)', p0, p1));
  }

  function log(uint p0, uint p1, uint p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,uint,uint)', p0, p1, p2));
  }

  function log(uint p0, uint p1, string memory p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,uint,string)', p0, p1, p2));
  }

  function log(uint p0, uint p1, bool p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,uint,bool)', p0, p1, p2));
  }

  function log(uint p0, uint p1, address p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,uint,address)', p0, p1, p2));
  }

  function log(uint p0, string memory p1, uint p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,string,uint)', p0, p1, p2));
  }

  function log(uint p0, string memory p1, string memory p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,string,string)', p0, p1, p2));
  }

  function log(uint p0, string memory p1, bool p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,string,bool)', p0, p1, p2));
  }

  function log(uint p0, string memory p1, address p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,string,address)', p0, p1, p2));
  }

  function log(uint p0, bool p1, uint p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,bool,uint)', p0, p1, p2));
  }

  function log(uint p0, bool p1, string memory p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,bool,string)', p0, p1, p2));
  }

  function log(uint p0, bool p1, bool p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,bool,bool)', p0, p1, p2));
  }

  function log(uint p0, bool p1, address p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,bool,address)', p0, p1, p2));
  }

  function log(uint p0, address p1, uint p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,address,uint)', p0, p1, p2));
  }

  function log(uint p0, address p1, string memory p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,address,string)', p0, p1, p2));
  }

  function log(uint p0, address p1, bool p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,address,bool)', p0, p1, p2));
  }

  function log(uint p0, address p1, address p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,address,address)', p0, p1, p2));
  }

  function log(string memory p0, uint p1, uint p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,uint,uint)', p0, p1, p2));
  }

  function log(string memory p0, uint p1, string memory p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,uint,string)', p0, p1, p2));
  }

  function log(string memory p0, uint p1, bool p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,uint,bool)', p0, p1, p2));
  }

  function log(string memory p0, uint p1, address p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,uint,address)', p0, p1, p2));
  }

  function log(string memory p0, string memory p1, uint p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,string,uint)', p0, p1, p2));
  }

  function log(string memory p0, string memory p1, string memory p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,string,string)', p0, p1, p2));
  }

  function log(string memory p0, string memory p1, bool p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,string,bool)', p0, p1, p2));
  }

  function log(string memory p0, string memory p1, address p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,string,address)', p0, p1, p2));
  }

  function log(string memory p0, bool p1, uint p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,bool,uint)', p0, p1, p2));
  }

  function log(string memory p0, bool p1, string memory p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,bool,string)', p0, p1, p2));
  }

  function log(string memory p0, bool p1, bool p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,bool,bool)', p0, p1, p2));
  }

  function log(string memory p0, bool p1, address p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,bool,address)', p0, p1, p2));
  }

  function log(string memory p0, address p1, uint p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,address,uint)', p0, p1, p2));
  }

  function log(string memory p0, address p1, string memory p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,address,string)', p0, p1, p2));
  }

  function log(string memory p0, address p1, bool p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,address,bool)', p0, p1, p2));
  }

  function log(string memory p0, address p1, address p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,address,address)', p0, p1, p2));
  }

  function log(bool p0, uint p1, uint p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,uint,uint)', p0, p1, p2));
  }

  function log(bool p0, uint p1, string memory p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,uint,string)', p0, p1, p2));
  }

  function log(bool p0, uint p1, bool p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,uint,bool)', p0, p1, p2));
  }

  function log(bool p0, uint p1, address p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,uint,address)', p0, p1, p2));
  }

  function log(bool p0, string memory p1, uint p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,string,uint)', p0, p1, p2));
  }

  function log(bool p0, string memory p1, string memory p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,string,string)', p0, p1, p2));
  }

  function log(bool p0, string memory p1, bool p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,string,bool)', p0, p1, p2));
  }

  function log(bool p0, string memory p1, address p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,string,address)', p0, p1, p2));
  }

  function log(bool p0, bool p1, uint p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,bool,uint)', p0, p1, p2));
  }

  function log(bool p0, bool p1, string memory p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,bool,string)', p0, p1, p2));
  }

  function log(bool p0, bool p1, bool p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,bool,bool)', p0, p1, p2));
  }

  function log(bool p0, bool p1, address p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,bool,address)', p0, p1, p2));
  }

  function log(bool p0, address p1, uint p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,address,uint)', p0, p1, p2));
  }

  function log(bool p0, address p1, string memory p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,address,string)', p0, p1, p2));
  }

  function log(bool p0, address p1, bool p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,address,bool)', p0, p1, p2));
  }

  function log(bool p0, address p1, address p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,address,address)', p0, p1, p2));
  }

  function log(address p0, uint p1, uint p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,uint,uint)', p0, p1, p2));
  }

  function log(address p0, uint p1, string memory p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,uint,string)', p0, p1, p2));
  }

  function log(address p0, uint p1, bool p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,uint,bool)', p0, p1, p2));
  }

  function log(address p0, uint p1, address p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,uint,address)', p0, p1, p2));
  }

  function log(address p0, string memory p1, uint p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,string,uint)', p0, p1, p2));
  }

  function log(address p0, string memory p1, string memory p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,string,string)', p0, p1, p2));
  }

  function log(address p0, string memory p1, bool p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,string,bool)', p0, p1, p2));
  }

  function log(address p0, string memory p1, address p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,string,address)', p0, p1, p2));
  }

  function log(address p0, bool p1, uint p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,bool,uint)', p0, p1, p2));
  }

  function log(address p0, bool p1, string memory p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,bool,string)', p0, p1, p2));
  }

  function log(address p0, bool p1, bool p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,bool,bool)', p0, p1, p2));
  }

  function log(address p0, bool p1, address p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,bool,address)', p0, p1, p2));
  }

  function log(address p0, address p1, uint p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,address,uint)', p0, p1, p2));
  }

  function log(address p0, address p1, string memory p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,address,string)', p0, p1, p2));
  }

  function log(address p0, address p1, bool p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,address,bool)', p0, p1, p2));
  }

  function log(address p0, address p1, address p2) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,address,address)', p0, p1, p2));
  }

  function log(uint p0, uint p1, uint p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,uint,uint,uint)', p0, p1, p2, p3));
  }

  function log(uint p0, uint p1, uint p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,uint,uint,string)', p0, p1, p2, p3));
  }

  function log(uint p0, uint p1, uint p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,uint,uint,bool)', p0, p1, p2, p3));
  }

  function log(uint p0, uint p1, uint p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,uint,uint,address)', p0, p1, p2, p3));
  }

  function log(uint p0, uint p1, string memory p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,uint,string,uint)', p0, p1, p2, p3));
  }

  function log(uint p0, uint p1, string memory p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,uint,string,string)', p0, p1, p2, p3));
  }

  function log(uint p0, uint p1, string memory p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,uint,string,bool)', p0, p1, p2, p3));
  }

  function log(uint p0, uint p1, string memory p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,uint,string,address)', p0, p1, p2, p3));
  }

  function log(uint p0, uint p1, bool p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,uint,bool,uint)', p0, p1, p2, p3));
  }

  function log(uint p0, uint p1, bool p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,uint,bool,string)', p0, p1, p2, p3));
  }

  function log(uint p0, uint p1, bool p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,uint,bool,bool)', p0, p1, p2, p3));
  }

  function log(uint p0, uint p1, bool p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,uint,bool,address)', p0, p1, p2, p3));
  }

  function log(uint p0, uint p1, address p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,uint,address,uint)', p0, p1, p2, p3));
  }

  function log(uint p0, uint p1, address p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,uint,address,string)', p0, p1, p2, p3));
  }

  function log(uint p0, uint p1, address p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,uint,address,bool)', p0, p1, p2, p3));
  }

  function log(uint p0, uint p1, address p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,uint,address,address)', p0, p1, p2, p3));
  }

  function log(uint p0, string memory p1, uint p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,string,uint,uint)', p0, p1, p2, p3));
  }

  function log(uint p0, string memory p1, uint p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,string,uint,string)', p0, p1, p2, p3));
  }

  function log(uint p0, string memory p1, uint p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,string,uint,bool)', p0, p1, p2, p3));
  }

  function log(uint p0, string memory p1, uint p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,string,uint,address)', p0, p1, p2, p3));
  }

  function log(uint p0, string memory p1, string memory p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,string,string,uint)', p0, p1, p2, p3));
  }

  function log(uint p0, string memory p1, string memory p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,string,string,string)', p0, p1, p2, p3));
  }

  function log(uint p0, string memory p1, string memory p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,string,string,bool)', p0, p1, p2, p3));
  }

  function log(uint p0, string memory p1, string memory p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,string,string,address)', p0, p1, p2, p3));
  }

  function log(uint p0, string memory p1, bool p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,string,bool,uint)', p0, p1, p2, p3));
  }

  function log(uint p0, string memory p1, bool p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,string,bool,string)', p0, p1, p2, p3));
  }

  function log(uint p0, string memory p1, bool p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,string,bool,bool)', p0, p1, p2, p3));
  }

  function log(uint p0, string memory p1, bool p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,string,bool,address)', p0, p1, p2, p3));
  }

  function log(uint p0, string memory p1, address p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,string,address,uint)', p0, p1, p2, p3));
  }

  function log(uint p0, string memory p1, address p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,string,address,string)', p0, p1, p2, p3));
  }

  function log(uint p0, string memory p1, address p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,string,address,bool)', p0, p1, p2, p3));
  }

  function log(uint p0, string memory p1, address p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,string,address,address)', p0, p1, p2, p3));
  }

  function log(uint p0, bool p1, uint p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,bool,uint,uint)', p0, p1, p2, p3));
  }

  function log(uint p0, bool p1, uint p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,bool,uint,string)', p0, p1, p2, p3));
  }

  function log(uint p0, bool p1, uint p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,bool,uint,bool)', p0, p1, p2, p3));
  }

  function log(uint p0, bool p1, uint p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,bool,uint,address)', p0, p1, p2, p3));
  }

  function log(uint p0, bool p1, string memory p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,bool,string,uint)', p0, p1, p2, p3));
  }

  function log(uint p0, bool p1, string memory p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,bool,string,string)', p0, p1, p2, p3));
  }

  function log(uint p0, bool p1, string memory p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,bool,string,bool)', p0, p1, p2, p3));
  }

  function log(uint p0, bool p1, string memory p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,bool,string,address)', p0, p1, p2, p3));
  }

  function log(uint p0, bool p1, bool p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,bool,bool,uint)', p0, p1, p2, p3));
  }

  function log(uint p0, bool p1, bool p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,bool,bool,string)', p0, p1, p2, p3));
  }

  function log(uint p0, bool p1, bool p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,bool,bool,bool)', p0, p1, p2, p3));
  }

  function log(uint p0, bool p1, bool p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,bool,bool,address)', p0, p1, p2, p3));
  }

  function log(uint p0, bool p1, address p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,bool,address,uint)', p0, p1, p2, p3));
  }

  function log(uint p0, bool p1, address p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,bool,address,string)', p0, p1, p2, p3));
  }

  function log(uint p0, bool p1, address p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,bool,address,bool)', p0, p1, p2, p3));
  }

  function log(uint p0, bool p1, address p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,bool,address,address)', p0, p1, p2, p3));
  }

  function log(uint p0, address p1, uint p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,address,uint,uint)', p0, p1, p2, p3));
  }

  function log(uint p0, address p1, uint p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,address,uint,string)', p0, p1, p2, p3));
  }

  function log(uint p0, address p1, uint p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,address,uint,bool)', p0, p1, p2, p3));
  }

  function log(uint p0, address p1, uint p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,address,uint,address)', p0, p1, p2, p3));
  }

  function log(uint p0, address p1, string memory p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,address,string,uint)', p0, p1, p2, p3));
  }

  function log(uint p0, address p1, string memory p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,address,string,string)', p0, p1, p2, p3));
  }

  function log(uint p0, address p1, string memory p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,address,string,bool)', p0, p1, p2, p3));
  }

  function log(uint p0, address p1, string memory p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,address,string,address)', p0, p1, p2, p3));
  }

  function log(uint p0, address p1, bool p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,address,bool,uint)', p0, p1, p2, p3));
  }

  function log(uint p0, address p1, bool p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,address,bool,string)', p0, p1, p2, p3));
  }

  function log(uint p0, address p1, bool p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,address,bool,bool)', p0, p1, p2, p3));
  }

  function log(uint p0, address p1, bool p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,address,bool,address)', p0, p1, p2, p3));
  }

  function log(uint p0, address p1, address p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,address,address,uint)', p0, p1, p2, p3));
  }

  function log(uint p0, address p1, address p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,address,address,string)', p0, p1, p2, p3));
  }

  function log(uint p0, address p1, address p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,address,address,bool)', p0, p1, p2, p3));
  }

  function log(uint p0, address p1, address p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(uint,address,address,address)', p0, p1, p2, p3));
  }

  function log(string memory p0, uint p1, uint p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,uint,uint,uint)', p0, p1, p2, p3));
  }

  function log(string memory p0, uint p1, uint p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,uint,uint,string)', p0, p1, p2, p3));
  }

  function log(string memory p0, uint p1, uint p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,uint,uint,bool)', p0, p1, p2, p3));
  }

  function log(string memory p0, uint p1, uint p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,uint,uint,address)', p0, p1, p2, p3));
  }

  function log(string memory p0, uint p1, string memory p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,uint,string,uint)', p0, p1, p2, p3));
  }

  function log(string memory p0, uint p1, string memory p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,uint,string,string)', p0, p1, p2, p3));
  }

  function log(string memory p0, uint p1, string memory p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,uint,string,bool)', p0, p1, p2, p3));
  }

  function log(string memory p0, uint p1, string memory p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,uint,string,address)', p0, p1, p2, p3));
  }

  function log(string memory p0, uint p1, bool p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,uint,bool,uint)', p0, p1, p2, p3));
  }

  function log(string memory p0, uint p1, bool p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,uint,bool,string)', p0, p1, p2, p3));
  }

  function log(string memory p0, uint p1, bool p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,uint,bool,bool)', p0, p1, p2, p3));
  }

  function log(string memory p0, uint p1, bool p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,uint,bool,address)', p0, p1, p2, p3));
  }

  function log(string memory p0, uint p1, address p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,uint,address,uint)', p0, p1, p2, p3));
  }

  function log(string memory p0, uint p1, address p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,uint,address,string)', p0, p1, p2, p3));
  }

  function log(string memory p0, uint p1, address p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,uint,address,bool)', p0, p1, p2, p3));
  }

  function log(string memory p0, uint p1, address p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,uint,address,address)', p0, p1, p2, p3));
  }

  function log(string memory p0, string memory p1, uint p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,string,uint,uint)', p0, p1, p2, p3));
  }

  function log(string memory p0, string memory p1, uint p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,string,uint,string)', p0, p1, p2, p3));
  }

  function log(string memory p0, string memory p1, uint p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,string,uint,bool)', p0, p1, p2, p3));
  }

  function log(string memory p0, string memory p1, uint p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,string,uint,address)', p0, p1, p2, p3));
  }

  function log(string memory p0, string memory p1, string memory p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,string,string,uint)', p0, p1, p2, p3));
  }

  function log(
    string memory p0,
    string memory p1,
    string memory p2,
    string memory p3
  ) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,string,string,string)', p0, p1, p2, p3));
  }

  function log(string memory p0, string memory p1, string memory p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,string,string,bool)', p0, p1, p2, p3));
  }

  function log(string memory p0, string memory p1, string memory p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,string,string,address)', p0, p1, p2, p3));
  }

  function log(string memory p0, string memory p1, bool p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,string,bool,uint)', p0, p1, p2, p3));
  }

  function log(string memory p0, string memory p1, bool p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,string,bool,string)', p0, p1, p2, p3));
  }

  function log(string memory p0, string memory p1, bool p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,string,bool,bool)', p0, p1, p2, p3));
  }

  function log(string memory p0, string memory p1, bool p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,string,bool,address)', p0, p1, p2, p3));
  }

  function log(string memory p0, string memory p1, address p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,string,address,uint)', p0, p1, p2, p3));
  }

  function log(string memory p0, string memory p1, address p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,string,address,string)', p0, p1, p2, p3));
  }

  function log(string memory p0, string memory p1, address p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,string,address,bool)', p0, p1, p2, p3));
  }

  function log(string memory p0, string memory p1, address p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,string,address,address)', p0, p1, p2, p3));
  }

  function log(string memory p0, bool p1, uint p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,bool,uint,uint)', p0, p1, p2, p3));
  }

  function log(string memory p0, bool p1, uint p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,bool,uint,string)', p0, p1, p2, p3));
  }

  function log(string memory p0, bool p1, uint p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,bool,uint,bool)', p0, p1, p2, p3));
  }

  function log(string memory p0, bool p1, uint p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,bool,uint,address)', p0, p1, p2, p3));
  }

  function log(string memory p0, bool p1, string memory p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,bool,string,uint)', p0, p1, p2, p3));
  }

  function log(string memory p0, bool p1, string memory p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,bool,string,string)', p0, p1, p2, p3));
  }

  function log(string memory p0, bool p1, string memory p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,bool,string,bool)', p0, p1, p2, p3));
  }

  function log(string memory p0, bool p1, string memory p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,bool,string,address)', p0, p1, p2, p3));
  }

  function log(string memory p0, bool p1, bool p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,bool,bool,uint)', p0, p1, p2, p3));
  }

  function log(string memory p0, bool p1, bool p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,bool,bool,string)', p0, p1, p2, p3));
  }

  function log(string memory p0, bool p1, bool p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,bool,bool,bool)', p0, p1, p2, p3));
  }

  function log(string memory p0, bool p1, bool p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,bool,bool,address)', p0, p1, p2, p3));
  }

  function log(string memory p0, bool p1, address p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,bool,address,uint)', p0, p1, p2, p3));
  }

  function log(string memory p0, bool p1, address p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,bool,address,string)', p0, p1, p2, p3));
  }

  function log(string memory p0, bool p1, address p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,bool,address,bool)', p0, p1, p2, p3));
  }

  function log(string memory p0, bool p1, address p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,bool,address,address)', p0, p1, p2, p3));
  }

  function log(string memory p0, address p1, uint p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,address,uint,uint)', p0, p1, p2, p3));
  }

  function log(string memory p0, address p1, uint p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,address,uint,string)', p0, p1, p2, p3));
  }

  function log(string memory p0, address p1, uint p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,address,uint,bool)', p0, p1, p2, p3));
  }

  function log(string memory p0, address p1, uint p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,address,uint,address)', p0, p1, p2, p3));
  }

  function log(string memory p0, address p1, string memory p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,address,string,uint)', p0, p1, p2, p3));
  }

  function log(string memory p0, address p1, string memory p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,address,string,string)', p0, p1, p2, p3));
  }

  function log(string memory p0, address p1, string memory p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,address,string,bool)', p0, p1, p2, p3));
  }

  function log(string memory p0, address p1, string memory p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,address,string,address)', p0, p1, p2, p3));
  }

  function log(string memory p0, address p1, bool p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,address,bool,uint)', p0, p1, p2, p3));
  }

  function log(string memory p0, address p1, bool p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,address,bool,string)', p0, p1, p2, p3));
  }

  function log(string memory p0, address p1, bool p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,address,bool,bool)', p0, p1, p2, p3));
  }

  function log(string memory p0, address p1, bool p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,address,bool,address)', p0, p1, p2, p3));
  }

  function log(string memory p0, address p1, address p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,address,address,uint)', p0, p1, p2, p3));
  }

  function log(string memory p0, address p1, address p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,address,address,string)', p0, p1, p2, p3));
  }

  function log(string memory p0, address p1, address p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,address,address,bool)', p0, p1, p2, p3));
  }

  function log(string memory p0, address p1, address p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(string,address,address,address)', p0, p1, p2, p3));
  }

  function log(bool p0, uint p1, uint p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,uint,uint,uint)', p0, p1, p2, p3));
  }

  function log(bool p0, uint p1, uint p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,uint,uint,string)', p0, p1, p2, p3));
  }

  function log(bool p0, uint p1, uint p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,uint,uint,bool)', p0, p1, p2, p3));
  }

  function log(bool p0, uint p1, uint p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,uint,uint,address)', p0, p1, p2, p3));
  }

  function log(bool p0, uint p1, string memory p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,uint,string,uint)', p0, p1, p2, p3));
  }

  function log(bool p0, uint p1, string memory p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,uint,string,string)', p0, p1, p2, p3));
  }

  function log(bool p0, uint p1, string memory p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,uint,string,bool)', p0, p1, p2, p3));
  }

  function log(bool p0, uint p1, string memory p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,uint,string,address)', p0, p1, p2, p3));
  }

  function log(bool p0, uint p1, bool p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,uint,bool,uint)', p0, p1, p2, p3));
  }

  function log(bool p0, uint p1, bool p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,uint,bool,string)', p0, p1, p2, p3));
  }

  function log(bool p0, uint p1, bool p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,uint,bool,bool)', p0, p1, p2, p3));
  }

  function log(bool p0, uint p1, bool p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,uint,bool,address)', p0, p1, p2, p3));
  }

  function log(bool p0, uint p1, address p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,uint,address,uint)', p0, p1, p2, p3));
  }

  function log(bool p0, uint p1, address p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,uint,address,string)', p0, p1, p2, p3));
  }

  function log(bool p0, uint p1, address p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,uint,address,bool)', p0, p1, p2, p3));
  }

  function log(bool p0, uint p1, address p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,uint,address,address)', p0, p1, p2, p3));
  }

  function log(bool p0, string memory p1, uint p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,string,uint,uint)', p0, p1, p2, p3));
  }

  function log(bool p0, string memory p1, uint p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,string,uint,string)', p0, p1, p2, p3));
  }

  function log(bool p0, string memory p1, uint p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,string,uint,bool)', p0, p1, p2, p3));
  }

  function log(bool p0, string memory p1, uint p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,string,uint,address)', p0, p1, p2, p3));
  }

  function log(bool p0, string memory p1, string memory p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,string,string,uint)', p0, p1, p2, p3));
  }

  function log(bool p0, string memory p1, string memory p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,string,string,string)', p0, p1, p2, p3));
  }

  function log(bool p0, string memory p1, string memory p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,string,string,bool)', p0, p1, p2, p3));
  }

  function log(bool p0, string memory p1, string memory p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,string,string,address)', p0, p1, p2, p3));
  }

  function log(bool p0, string memory p1, bool p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,string,bool,uint)', p0, p1, p2, p3));
  }

  function log(bool p0, string memory p1, bool p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,string,bool,string)', p0, p1, p2, p3));
  }

  function log(bool p0, string memory p1, bool p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,string,bool,bool)', p0, p1, p2, p3));
  }

  function log(bool p0, string memory p1, bool p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,string,bool,address)', p0, p1, p2, p3));
  }

  function log(bool p0, string memory p1, address p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,string,address,uint)', p0, p1, p2, p3));
  }

  function log(bool p0, string memory p1, address p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,string,address,string)', p0, p1, p2, p3));
  }

  function log(bool p0, string memory p1, address p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,string,address,bool)', p0, p1, p2, p3));
  }

  function log(bool p0, string memory p1, address p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,string,address,address)', p0, p1, p2, p3));
  }

  function log(bool p0, bool p1, uint p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,bool,uint,uint)', p0, p1, p2, p3));
  }

  function log(bool p0, bool p1, uint p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,bool,uint,string)', p0, p1, p2, p3));
  }

  function log(bool p0, bool p1, uint p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,bool,uint,bool)', p0, p1, p2, p3));
  }

  function log(bool p0, bool p1, uint p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,bool,uint,address)', p0, p1, p2, p3));
  }

  function log(bool p0, bool p1, string memory p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,bool,string,uint)', p0, p1, p2, p3));
  }

  function log(bool p0, bool p1, string memory p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,bool,string,string)', p0, p1, p2, p3));
  }

  function log(bool p0, bool p1, string memory p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,bool,string,bool)', p0, p1, p2, p3));
  }

  function log(bool p0, bool p1, string memory p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,bool,string,address)', p0, p1, p2, p3));
  }

  function log(bool p0, bool p1, bool p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,bool,bool,uint)', p0, p1, p2, p3));
  }

  function log(bool p0, bool p1, bool p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,bool,bool,string)', p0, p1, p2, p3));
  }

  function log(bool p0, bool p1, bool p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,bool,bool,bool)', p0, p1, p2, p3));
  }

  function log(bool p0, bool p1, bool p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,bool,bool,address)', p0, p1, p2, p3));
  }

  function log(bool p0, bool p1, address p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,bool,address,uint)', p0, p1, p2, p3));
  }

  function log(bool p0, bool p1, address p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,bool,address,string)', p0, p1, p2, p3));
  }

  function log(bool p0, bool p1, address p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,bool,address,bool)', p0, p1, p2, p3));
  }

  function log(bool p0, bool p1, address p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,bool,address,address)', p0, p1, p2, p3));
  }

  function log(bool p0, address p1, uint p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,address,uint,uint)', p0, p1, p2, p3));
  }

  function log(bool p0, address p1, uint p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,address,uint,string)', p0, p1, p2, p3));
  }

  function log(bool p0, address p1, uint p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,address,uint,bool)', p0, p1, p2, p3));
  }

  function log(bool p0, address p1, uint p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,address,uint,address)', p0, p1, p2, p3));
  }

  function log(bool p0, address p1, string memory p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,address,string,uint)', p0, p1, p2, p3));
  }

  function log(bool p0, address p1, string memory p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,address,string,string)', p0, p1, p2, p3));
  }

  function log(bool p0, address p1, string memory p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,address,string,bool)', p0, p1, p2, p3));
  }

  function log(bool p0, address p1, string memory p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,address,string,address)', p0, p1, p2, p3));
  }

  function log(bool p0, address p1, bool p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,address,bool,uint)', p0, p1, p2, p3));
  }

  function log(bool p0, address p1, bool p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,address,bool,string)', p0, p1, p2, p3));
  }

  function log(bool p0, address p1, bool p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,address,bool,bool)', p0, p1, p2, p3));
  }

  function log(bool p0, address p1, bool p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,address,bool,address)', p0, p1, p2, p3));
  }

  function log(bool p0, address p1, address p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,address,address,uint)', p0, p1, p2, p3));
  }

  function log(bool p0, address p1, address p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,address,address,string)', p0, p1, p2, p3));
  }

  function log(bool p0, address p1, address p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,address,address,bool)', p0, p1, p2, p3));
  }

  function log(bool p0, address p1, address p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(bool,address,address,address)', p0, p1, p2, p3));
  }

  function log(address p0, uint p1, uint p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,uint,uint,uint)', p0, p1, p2, p3));
  }

  function log(address p0, uint p1, uint p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,uint,uint,string)', p0, p1, p2, p3));
  }

  function log(address p0, uint p1, uint p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,uint,uint,bool)', p0, p1, p2, p3));
  }

  function log(address p0, uint p1, uint p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,uint,uint,address)', p0, p1, p2, p3));
  }

  function log(address p0, uint p1, string memory p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,uint,string,uint)', p0, p1, p2, p3));
  }

  function log(address p0, uint p1, string memory p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,uint,string,string)', p0, p1, p2, p3));
  }

  function log(address p0, uint p1, string memory p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,uint,string,bool)', p0, p1, p2, p3));
  }

  function log(address p0, uint p1, string memory p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,uint,string,address)', p0, p1, p2, p3));
  }

  function log(address p0, uint p1, bool p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,uint,bool,uint)', p0, p1, p2, p3));
  }

  function log(address p0, uint p1, bool p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,uint,bool,string)', p0, p1, p2, p3));
  }

  function log(address p0, uint p1, bool p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,uint,bool,bool)', p0, p1, p2, p3));
  }

  function log(address p0, uint p1, bool p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,uint,bool,address)', p0, p1, p2, p3));
  }

  function log(address p0, uint p1, address p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,uint,address,uint)', p0, p1, p2, p3));
  }

  function log(address p0, uint p1, address p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,uint,address,string)', p0, p1, p2, p3));
  }

  function log(address p0, uint p1, address p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,uint,address,bool)', p0, p1, p2, p3));
  }

  function log(address p0, uint p1, address p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,uint,address,address)', p0, p1, p2, p3));
  }

  function log(address p0, string memory p1, uint p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,string,uint,uint)', p0, p1, p2, p3));
  }

  function log(address p0, string memory p1, uint p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,string,uint,string)', p0, p1, p2, p3));
  }

  function log(address p0, string memory p1, uint p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,string,uint,bool)', p0, p1, p2, p3));
  }

  function log(address p0, string memory p1, uint p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,string,uint,address)', p0, p1, p2, p3));
  }

  function log(address p0, string memory p1, string memory p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,string,string,uint)', p0, p1, p2, p3));
  }

  function log(address p0, string memory p1, string memory p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,string,string,string)', p0, p1, p2, p3));
  }

  function log(address p0, string memory p1, string memory p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,string,string,bool)', p0, p1, p2, p3));
  }

  function log(address p0, string memory p1, string memory p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,string,string,address)', p0, p1, p2, p3));
  }

  function log(address p0, string memory p1, bool p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,string,bool,uint)', p0, p1, p2, p3));
  }

  function log(address p0, string memory p1, bool p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,string,bool,string)', p0, p1, p2, p3));
  }

  function log(address p0, string memory p1, bool p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,string,bool,bool)', p0, p1, p2, p3));
  }

  function log(address p0, string memory p1, bool p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,string,bool,address)', p0, p1, p2, p3));
  }

  function log(address p0, string memory p1, address p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,string,address,uint)', p0, p1, p2, p3));
  }

  function log(address p0, string memory p1, address p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,string,address,string)', p0, p1, p2, p3));
  }

  function log(address p0, string memory p1, address p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,string,address,bool)', p0, p1, p2, p3));
  }

  function log(address p0, string memory p1, address p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,string,address,address)', p0, p1, p2, p3));
  }

  function log(address p0, bool p1, uint p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,bool,uint,uint)', p0, p1, p2, p3));
  }

  function log(address p0, bool p1, uint p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,bool,uint,string)', p0, p1, p2, p3));
  }

  function log(address p0, bool p1, uint p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,bool,uint,bool)', p0, p1, p2, p3));
  }

  function log(address p0, bool p1, uint p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,bool,uint,address)', p0, p1, p2, p3));
  }

  function log(address p0, bool p1, string memory p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,bool,string,uint)', p0, p1, p2, p3));
  }

  function log(address p0, bool p1, string memory p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,bool,string,string)', p0, p1, p2, p3));
  }

  function log(address p0, bool p1, string memory p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,bool,string,bool)', p0, p1, p2, p3));
  }

  function log(address p0, bool p1, string memory p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,bool,string,address)', p0, p1, p2, p3));
  }

  function log(address p0, bool p1, bool p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,bool,bool,uint)', p0, p1, p2, p3));
  }

  function log(address p0, bool p1, bool p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,bool,bool,string)', p0, p1, p2, p3));
  }

  function log(address p0, bool p1, bool p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,bool,bool,bool)', p0, p1, p2, p3));
  }

  function log(address p0, bool p1, bool p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,bool,bool,address)', p0, p1, p2, p3));
  }

  function log(address p0, bool p1, address p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,bool,address,uint)', p0, p1, p2, p3));
  }

  function log(address p0, bool p1, address p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,bool,address,string)', p0, p1, p2, p3));
  }

  function log(address p0, bool p1, address p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,bool,address,bool)', p0, p1, p2, p3));
  }

  function log(address p0, bool p1, address p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,bool,address,address)', p0, p1, p2, p3));
  }

  function log(address p0, address p1, uint p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,address,uint,uint)', p0, p1, p2, p3));
  }

  function log(address p0, address p1, uint p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,address,uint,string)', p0, p1, p2, p3));
  }

  function log(address p0, address p1, uint p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,address,uint,bool)', p0, p1, p2, p3));
  }

  function log(address p0, address p1, uint p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,address,uint,address)', p0, p1, p2, p3));
  }

  function log(address p0, address p1, string memory p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,address,string,uint)', p0, p1, p2, p3));
  }

  function log(address p0, address p1, string memory p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,address,string,string)', p0, p1, p2, p3));
  }

  function log(address p0, address p1, string memory p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,address,string,bool)', p0, p1, p2, p3));
  }

  function log(address p0, address p1, string memory p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,address,string,address)', p0, p1, p2, p3));
  }

  function log(address p0, address p1, bool p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,address,bool,uint)', p0, p1, p2, p3));
  }

  function log(address p0, address p1, bool p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,address,bool,string)', p0, p1, p2, p3));
  }

  function log(address p0, address p1, bool p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,address,bool,bool)', p0, p1, p2, p3));
  }

  function log(address p0, address p1, bool p2, address p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,address,bool,address)', p0, p1, p2, p3));
  }

  function log(address p0, address p1, address p2, uint p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,address,address,uint)', p0, p1, p2, p3));
  }

  function log(address p0, address p1, address p2, string memory p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,address,address,string)', p0, p1, p2, p3));
  }

  function log(address p0, address p1, address p2, bool p3) internal view {
    _sendLogPayload(abi.encodeWithSignature('log(address,address,address,bool)', p0, p1, p2, p3));
  }

  function log(address p0, address p1, address p2, address p3) internal view {
    _sendLogPayload(
      abi.encodeWithSignature('log(address,address,address,address)', p0, p1, p2, p3)
    );
  }
}

// File @openzeppelin/contracts-upgradeable/proxy/utils/[email protected]

// OpenZeppelin Contracts v4.4.0 (proxy/utils/Initializable.sol)

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private _initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private _initializing;

  /**
   * @dev Modifier to protect an initializer function from being invoked twice.
   */
  modifier initializer() {
    require(_initializing || !_initialized, 'Initializable: contract is already initialized');

    bool isTopLevelCall = !_initializing;
    if (isTopLevelCall) {
      _initializing = true;
      _initialized = true;
    }

    _;

    if (isTopLevelCall) {
      _initializing = false;
    }
  }
}

// File @openzeppelin/contracts-upgradeable/utils/[email protected]

// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

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
abstract contract ContextUpgradeable is Initializable {
  function __Context_init() internal initializer {
    __Context_init_unchained();
  }

  function __Context_init_unchained() internal initializer {}

  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
    return msg.data;
  }

  uint256[50] private __gap;
}

// File @openzeppelin/contracts-upgradeable/access/[email protected]

// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  function __Ownable_init() internal initializer {
    __Context_init_unchained();
    __Ownable_init_unchained();
  }

  function __Ownable_init_unchained() internal initializer {
    _transferOwnership(_msgSender());
  }

  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view virtual returns (address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(owner() == _msgSender(), 'Ownable: caller is not the owner');
    _;
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
    require(newOwner != address(0), 'Ownable: new owner is the zero address');
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

  uint256[49] private __gap;
}

// File @openzeppelin/contracts/token/ERC20/[email protected]

// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address owner, address spender) external view returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   * Emits an {Approval} event.
   */
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Emitted when `value` tokens are moved from one account (`from`) to
   * another (`to`).
   *
   * Note that `value` may be zero.
   */
  event Transfer(address indexed from, address indexed to, uint256 value);

  /**
   * @dev Emitted when the allowance of a `spender` for an `owner` is set by
   * a call to {approve}. `value` is the new allowance.
   */
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File @openzeppelin/contracts/utils/introspection/[email protected]

// OpenZeppelin Contracts v4.4.0 (utils/introspection/IERC165.sol)

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
  /**
   * @dev Returns true if this contract implements the interface defined by
   * `interfaceId`. See the corresponding
   * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
   * to learn more about how these ids are created.
   *
   * This function call must use less than 30 000 gas.
   */
  function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File @openzeppelin/contracts/token/ERC721/[email protected]

// OpenZeppelin Contracts v4.4.0 (token/ERC721/IERC721.sol)

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
  /**
   * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
   */
  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

  /**
   * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
   */
  event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

  /**
   * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
   */
  event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

  /**
   * @dev Returns the number of tokens in ``owner``'s account.
   */
  function balanceOf(address owner) external view returns (uint256 balance);

  /**
   * @dev Returns the owner of the `tokenId` token.
   *
   * Requirements:
   *
   * - `tokenId` must exist.
   */
  function ownerOf(uint256 tokenId) external view returns (address owner);

  /**
   * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
   * are aware of the ERC721 protocol to prevent tokens from being forever locked.
   *
   * Requirements:
   *
   * - `from` cannot be the zero address.
   * - `to` cannot be the zero address.
   * - `tokenId` token must exist and be owned by `from`.
   * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
   * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
   *
   * Emits a {Transfer} event.
   */
  function safeTransferFrom(address from, address to, uint256 tokenId) external;

  /**
   * @dev Transfers `tokenId` token from `from` to `to`.
   *
   * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
   *
   * Requirements:
   *
   * - `from` cannot be the zero address.
   * - `to` cannot be the zero address.
   * - `tokenId` token must be owned by `from`.
   * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address from, address to, uint256 tokenId) external;

  /**
   * @dev Gives permission to `to` to transfer `tokenId` token to another account.
   * The approval is cleared when the token is transferred.
   *
   * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
   *
   * Requirements:
   *
   * - The caller must own the token or be an approved operator.
   * - `tokenId` must exist.
   *
   * Emits an {Approval} event.
   */
  function approve(address to, uint256 tokenId) external;

  /**
   * @dev Returns the account approved for `tokenId` token.
   *
   * Requirements:
   *
   * - `tokenId` must exist.
   */
  function getApproved(uint256 tokenId) external view returns (address operator);

  /**
   * @dev Approve or remove `operator` as an operator for the caller.
   * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
   *
   * Requirements:
   *
   * - The `operator` cannot be the caller.
   *
   * Emits an {ApprovalForAll} event.
   */
  function setApprovalForAll(address operator, bool _approved) external;

  /**
   * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
   *
   * See {setApprovalForAll}
   */
  function isApprovedForAll(address owner, address operator) external view returns (bool);

  /**
   * @dev Safely transfers `tokenId` token from `from` to `to`.
   *
   * Requirements:
   *
   * - `from` cannot be the zero address.
   * - `to` cannot be the zero address.
   * - `tokenId` token must exist and be owned by `from`.
   * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
   * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
   *
   * Emits a {Transfer} event.
   */
  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes calldata data
  ) external;
}

// File @openzeppelin/contracts/token/ERC721/extensions/[email protected]

// OpenZeppelin Contracts v4.4.0 (token/ERC721/extensions/IERC721Enumerable.sol)

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
  /**
   * @dev Returns the total amount of tokens stored by the contract.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
   * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
   */
  function tokenOfOwnerByIndex(
    address owner,
    uint256 index
  ) external view returns (uint256 tokenId);

  /**
   * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
   * Use along with {totalSupply} to enumerate all tokens.
   */
  function tokenByIndex(uint256 index) external view returns (uint256);
}

// File @chainlink/contracts/src/v0.8/interfaces/[email protected]

interface LinkTokenInterface {
  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success);

  function transferFrom(address from, address to, uint256 value) external returns (bool success);
}

// File @chainlink/contracts/src/v0.8/[email protected]

contract VRFRequestIDBase {
  /**
   * @notice returns the seed which is actually input to the VRF coordinator
   *
   * @dev To prevent repetition of VRF output due to repetition of the
   * @dev user-supplied seed, that seed is combined in a hash with the
   * @dev user-specific nonce, and the address of the consuming contract. The
   * @dev risk of repetition is mostly mitigated by inclusion of a blockhash in
   * @dev the final seed, but the nonce does protect against repetition in
   * @dev requests which are included in a single block.
   *
   * @param _userSeed VRF seed input provided by user
   * @param _requester Address of the requesting contract
   * @param _nonce User-specific nonce at the time of the request
   */
  function makeVRFInputSeed(
    bytes32 _keyHash,
    uint256 _userSeed,
    address _requester,
    uint256 _nonce
  ) internal pure returns (uint256) {
    return uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));
  }

  /**
   * @notice Returns the id for this request
   * @param _keyHash The serviceAgreement ID to be used for this request
   * @param _vRFInputSeed The seed to be passed directly to the VRF
   * @return The id for this request
   *
   * @dev Note that _vRFInputSeed is not the seed passed by the consuming
   * @dev contract, but the one generated by makeVRFInputSeed
   */
  function makeRequestId(bytes32 _keyHash, uint256 _vRFInputSeed) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
  }
}

// File @chainlink/contracts/src/v0.8/[email protected]

/** ****************************************************************************
 * @notice Interface for contracts using VRF randomness
 * *****************************************************************************
 * @dev PURPOSE
 *
 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness
 * @dev to Vera the verifier in such a way that Vera can be sure he's not
 * @dev making his output up to suit himself. Reggie provides Vera a public key
 * @dev to which he knows the secret key. Each time Vera provides a seed to
 * @dev Reggie, he gives back a value which is computed completely
 * @dev deterministically from the seed and the secret key.
 *
 * @dev Reggie provides a proof by which Vera can verify that the output was
 * @dev correctly computed once Reggie tells it to her, but without that proof,
 * @dev the output is indistinguishable to her from a uniform random sample
 * @dev from the output space.
 *
 * @dev The purpose of this contract is to make it easy for unrelated contracts
 * @dev to talk to Vera the verifier about the work Reggie is doing, to provide
 * @dev simple access to a verifiable source of randomness.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constuctor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator, _link) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash), and have told you the minimum LINK
 * @dev price for VRF service. Make sure your contract has sufficient LINK, and
 * @dev call requestRandomness(keyHash, fee, seed), where seed is the input you
 * @dev want to generate randomness from.
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomness method.
 *
 * @dev The randomness argument to fulfillRandomness is the actual random value
 * @dev generated from your seed.
 *
 * @dev The requestId argument is generated from the keyHash and the seed by
 * @dev makeRequestId(keyHash, seed). If your contract could have concurrent
 * @dev requests open, you can use the requestId to track which seed is
 * @dev associated with which randomness. See VRFRequestIDBase.sol for more
 * @dev details. (See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.)
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ. (Which is critical to making unpredictable randomness! See the
 * @dev next section.)
 *
 * *****************************************************************************
 * @dev SECURITY CONSIDERATIONS
 *
 * @dev A method with the ability to call your fulfillRandomness method directly
 * @dev could spoof a VRF response with any random value, so it's critical that
 * @dev it cannot be directly called by anything other than this base contract
 * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).
 *
 * @dev For your users to trust that your contract's random behavior is free
 * @dev from malicious interference, it's best if you can write it so that all
 * @dev behaviors implied by a VRF response are executed *during* your
 * @dev fulfillRandomness method. If your contract must store the response (or
 * @dev anything derived from it) and use it later, you must ensure that any
 * @dev user-significant behavior which depends on that stored value cannot be
 * @dev manipulated by a subsequent VRF request.
 *
 * @dev Similarly, both miners and the VRF oracle itself have some influence
 * @dev over the order in which VRF responses appear on the blockchain, so if
 * @dev your contract could have multiple VRF requests in flight simultaneously,
 * @dev you must ensure that the order in which the VRF responses arrive cannot
 * @dev be used to manipulate your contract's user-significant behavior.
 *
 * @dev Since the ultimate input to the VRF is mixed with the block hash of the
 * @dev block in which the request is made, user-provided seeds have no impact
 * @dev on its economic security properties. They are only included for API
 * @dev compatability with previous versions of this contract.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request.
 */
abstract contract VRFConsumerBase is VRFRequestIDBase {
  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBase expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomness the VRF output
   */
  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal virtual;

  /**
   * @dev In order to keep backwards compatibility we have kept the user
   * seed field around. We remove the use of it because given that the blockhash
   * enters later, it overrides whatever randomness the used seed provides.
   * Given that it adds no security, and can easily lead to misunderstandings,
   * we have removed it from usage and can now provide a simpler API.
   */
  uint256 private constant USER_SEED_PLACEHOLDER = 0;

  /**
   * @notice requestRandomness initiates a request for VRF output given _seed
   *
   * @dev The fulfillRandomness method receives the output, once it's provided
   * @dev by the Oracle, and verified by the vrfCoordinator.
   *
   * @dev The _keyHash must already be registered with the VRFCoordinator, and
   * @dev the _fee must exceed the fee specified during registration of the
   * @dev _keyHash.
   *
   * @dev The _seed parameter is vestigial, and is kept only for API
   * @dev compatibility with older versions. It can't *hurt* to mix in some of
   * @dev your own randomness, here, but it's not necessary because the VRF
   * @dev oracle will mix the hash of the block containing your request into the
   * @dev VRF seed it ultimately uses.
   *
   * @param _keyHash ID of public key against which randomness is generated
   * @param _fee The amount of LINK to send with the request
   *
   * @return requestId unique ID for this request
   *
   * @dev The returned requestId can be used to distinguish responses to
   * @dev concurrent requests. It is passed as the first argument to
   * @dev fulfillRandomness.
   */
  function requestRandomness(bytes32 _keyHash, uint256 _fee) internal returns (bytes32 requestId) {
    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, USER_SEED_PLACEHOLDER));
    // This is the seed passed to VRFCoordinator. The oracle will mix this with
    // the hash of the block containing this request to obtain the seed/input
    // which is finally passed to the VRF cryptographic machinery.
    uint256 vRFSeed = makeVRFInputSeed(
      _keyHash,
      USER_SEED_PLACEHOLDER,
      address(this),
      nonces[_keyHash]
    );
    // nonces[_keyHash] must stay in sync with
    // VRFCoordinator.nonces[_keyHash][this], which was incremented by the above
    // successful LINK.transferAndCall (in VRFCoordinator.randomnessRequest).
    // This provides protection against the user repeating their input seed,
    // which would result in a predictable/duplicate output, if multiple such
    // requests appeared in the same block.
    nonces[_keyHash] = nonces[_keyHash] + 1;
    return makeRequestId(_keyHash, vRFSeed);
  }

  LinkTokenInterface internal immutable LINK;
  address private immutable vrfCoordinator;

  // Nonces for each VRF key from which randomness has been requested.
  //
  // Must stay in sync with VRFCoordinator[_keyHash][this]
  mapping(bytes32 /* keyHash */ => uint256 /* nonce */) private nonces;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   * @param _link address of LINK token contract
   *
   * @dev https://docs.chain.link/docs/link-token-contracts
   */
  constructor(address _vrfCoordinator, address _link) {
    vrfCoordinator = _vrfCoordinator;
    LINK = LinkTokenInterface(_link);
  }

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomness(bytes32 requestId, uint256 randomness) external {
    require(msg.sender == vrfCoordinator, 'Only VRFCoordinator can fulfill');
    fulfillRandomness(requestId, randomness);
  }
}

// File contracts/main/Keeper/KeeperBase.sol

contract KeeperBase {
  /**
   * @notice method that allows it to be simulated via eth_call by checking that
   * the sender is the zero address.
   */
  function preventExecution() internal view {
    require(tx.origin == address(0), 'only for simulated backend');
  }

  /**
   * @notice modifier that allows it to be simulated via eth_call by checking
   * that the sender is the zero address.
   */
  modifier cannotExecute() {
    preventExecution();
    _;
  }
}

// File contracts/main/Keeper/KeeperCompatibleInterface.sol

interface KeeperCompatibleInterface {
  /**
   * @notice method that is simulated by the keepers to see if any work actually
   * needs to be performed. This method does does not actually need to be
   * executable, and since it is only ever simulated it can consume lots of gas.
   * @dev To ensure that it is never called, you may want to add the
   * cannotExecute modifier from KeeperBase to your implementation of this
   * method.
   * @param checkData specified in the upkeep registration so it is always the
   * same for a registered upkeep. This can easilly be broken down into specific
   * arguments using `abi.decode`, so multiple upkeeps can be registered on the
   * same contract and easily differentiated by the contract.
   * @return upkeepNeeded boolean to indicate whether the keeper should call
   * performUpkeep or not.
   * @return performData bytes that the keeper should call performUpkeep with, if
   * upkeep is needed. If you would like to encode data to decode later, try
   * `abi.encode`.
   */
  function checkUpkeep(
    bytes calldata checkData
  ) external returns (bool upkeepNeeded, bytes memory performData);

  /**
   * @notice method that is actually executed by the keepers, via the registry.
   * The data returned by the checkUpkeep simulation will be passed into
   * this method to actually be executed.
   * @dev The input to this method should not be trusted, and the caller of the
   * method should not even be restricted to any single registry. Anyone should
   * be able call it, and the input should be validated, there is no guarantee
   * that the data passed in is the performData returned from checkUpkeep. This
   * could happen due to malicious keepers, racing keepers, or simply a state
   * change while the performUpkeep transaction is waiting for confirmation.
   * Always validate the data passed in.
   * @param performData is the data which was passed back from the checkData
   * simulation. If it is encoded, it can easily be decoded into other types by
   * calling `abi.decode`. This data should not be trusted, and should be
   * validated against the contract's current state.
   */
  function performUpkeep(bytes calldata performData) external;
}

// File contracts/main/Keeper/KeeperCompatible.sol

abstract contract KeeperCompatible is KeeperBase, KeeperCompatibleInterface {

}

// File contracts/main/VRFConsumerBaseUpgradeable.sol

/** ****************************************************************************
 * @notice Interface for contracts using VRF randomness
 * *****************************************************************************
 * @dev PURPOSE
 *
 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness
 * @dev to Vera the verifier in such a way that Vera can be sure he's not
 * @dev making his output up to suit himself. Reggie provides Vera a public key
 * @dev to which he knows the secret key. Each time Vera provides a seed to
 * @dev Reggie, he gives back a value which is computed completely
 * @dev deterministically from the seed and the secret key.
 *
 * @dev Reggie provides a proof by which Vera can verify that the output was
 * @dev correctly computed once Reggie tells it to her, but without that proof,
 * @dev the output is indistinguishable to her from a uniform random sample
 * @dev from the output space.
 *
 * @dev The purpose of this contract is to make it easy for unrelated contracts
 * @dev to talk to Vera the verifier about the work Reggie is doing, to provide
 * @dev simple access to a verifiable source of randomness.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constuctor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator, _link) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash), and have told you the minimum LINK
 * @dev price for VRF service. Make sure your contract has sufficient LINK, and
 * @dev call requestRandomness(keyHash, fee, seed), where seed is the input you
 * @dev want to generate randomness from.
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomness method.
 *
 * @dev The randomness argument to fulfillRandomness is the actual random value
 * @dev generated from your seed.
 *
 * @dev The requestId argument is generated from the keyHash and the seed by
 * @dev makeRequestId(keyHash, seed). If your contract could have concurrent
 * @dev requests open, you can use the requestId to track which seed is
 * @dev associated with which randomness. See VRFRequestIDBase.sol for more
 * @dev details. (See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.)
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ. (Which is critical to making unpredictable randomness! See the
 * @dev next section.)
 *
 * *****************************************************************************
 * @dev SECURITY CONSIDERATIONS
 *
 * @dev A method with the ability to call your fulfillRandomness method directly
 * @dev could spoof a VRF response with any random value, so it's critical that
 * @dev it cannot be directly called by anything other than this base contract
 * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).
 *
 * @dev For your users to trust that your contract's random behavior is free
 * @dev from malicious interference, it's best if you can write it so that all
 * @dev behaviors implied by a VRF response are executed *during* your
 * @dev fulfillRandomness method. If your contract must store the response (or
 * @dev anything derived from it) and use it later, you must ensure that any
 * @dev user-significant behavior which depends on that stored value cannot be
 * @dev manipulated by a subsequent VRF request.
 *
 * @dev Similarly, both miners and the VRF oracle itself have some influence
 * @dev over the order in which VRF responses appear on the blockchain, so if
 * @dev your contract could have multiple VRF requests in flight simultaneously,
 * @dev you must ensure that the order in which the VRF responses arrive cannot
 * @dev be used to manipulate your contract's user-significant behavior.
 *
 * @dev Since the ultimate input to the VRF is mixed with the block hash of the
 * @dev block in which the request is made, user-provided seeds have no impact
 * @dev on its economic security properties. They are only included for API
 * @dev compatability with previous versions of this contract.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request.
 */
abstract contract VRFConsumerBaseUpgradeable is Initializable, VRFRequestIDBase {
  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBase expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomness the VRF output
   */
  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal virtual;

  /**
   * @dev In order to keep backwards compatibility we have kept the user
   * seed field around. We remove the use of it because given that the blockhash
   * enters later, it overrides whatever randomness the used seed provides.
   * Given that it adds no security, and can easily lead to misunderstandings,
   * we have removed it from usage and can now provide a simpler API.
   */
  uint256 private constant USER_SEED_PLACEHOLDER = 0;

  /**
   * @notice requestRandomness initiates a request for VRF output given _seed
   *
   * @dev The fulfillRandomness method receives the output, once it's provided
   * @dev by the Oracle, and verified by the vrfCoordinator.
   *
   * @dev The _keyHash must already be registered with the VRFCoordinator, and
   * @dev the _fee must exceed the fee specified during registration of the
   * @dev _keyHash.
   *
   * @dev The _seed parameter is vestigial, and is kept only for API
   * @dev compatibility with older versions. It can't *hurt* to mix in some of
   * @dev your own randomness, here, but it's not necessary because the VRF
   * @dev oracle will mix the hash of the block containing your request into the
   * @dev VRF seed it ultimately uses.
   *
   * @param _keyHash ID of public key against which randomness is generated
   * @param _fee The amount of LINK to send with the request
   *
   * @return requestId unique ID for this request
   *
   * @dev The returned requestId can be used to distinguish responses to
   * @dev concurrent requests. It is passed as the first argument to
   * @dev fulfillRandomness.
   */
  function requestRandomness(bytes32 _keyHash, uint256 _fee) internal returns (bytes32 requestId) {
    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, USER_SEED_PLACEHOLDER));
    // This is the seed passed to VRFCoordinator. The oracle will mix this with
    // the hash of the block containing this request to obtain the seed/input
    // which is finally passed to the VRF cryptographic machinery.
    uint256 vRFSeed = makeVRFInputSeed(
      _keyHash,
      USER_SEED_PLACEHOLDER,
      address(this),
      nonces[_keyHash]
    );
    // nonces[_keyHash] must stay in sync with
    // VRFCoordinator.nonces[_keyHash][this], which was incremented by the above
    // successful LINK.transferAndCall (in VRFCoordinator.randomnessRequest).
    // This provides protection against the user repeating their input seed,
    // which would result in a predictable/duplicate output, if multiple such
    // requests appeared in the same block.
    nonces[_keyHash] = nonces[_keyHash] + 1;
    return makeRequestId(_keyHash, vRFSeed);
  }

  LinkTokenInterface internal LINK;
  address private vrfCoordinator;

  // Nonces for each VRF key from which randomness has been requested.
  //
  // Must stay in sync with VRFCoordinator[_keyHash][this]
  mapping(bytes32 /* keyHash */ => uint256 /* nonce */) private nonces;

  /**
   *
   * @dev https://docs.chain.link/docs/link-token-contracts
   */

  function __VRFConsumerBaseUpgradeable_initialize(
    address _vrfCoordinator,
    address _link
  ) internal initializer {
    vrfCoordinator = _vrfCoordinator;
    LINK = LinkTokenInterface(_link);
  }

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomness(bytes32 requestId, uint256 randomness) external {
    require(msg.sender == vrfCoordinator, 'Only VRFCoordinator can fulfill');
    fulfillRandomness(requestId, randomness);
  }
}

// File contracts/main/TicketProviderV7.sol

interface ILotteryTicketNFT {
  function mint(address to, uint256 tokenId) external;

  function setBaseURI(string memory uri) external;
}

interface ICakeMonsterDiamondClawNFT {
  function getTokenWithHighestLevel(
    address account
  ) external view returns (uint256 tokenId, uint256 tokenLevel);

  function level(uint256 tokenId) external view returns (uint256);

  function isActive(uint256 tokenId) external view returns (bool);
}

abstract contract TicketProviderV7 is Initializable, OwnableUpgradeable {
  address public cakeMonsterContract;
  address public dcContract;
  address public lotteryTicketNftContract;

  mapping(address => uint256) public userToDiamondClawMap;
  mapping(uint256 => bool) public diamondClawClaimed;
  mapping(uint256 => uint256) public ticketNumberToTokenMap;

  uint256 public lastMintedTokenId;

  uint256 public maxSupply;
  uint256 public winningChance;

  /*
    Ticket number rules:
    - Lowest ticket # = 11000
    - Highest ticket # = 99999
    - Max range = 99999 - 11000 = 88999 tickets
    - Max tickets to be minted = 8000 tickets
    - Max chance factor = 10 (meaning 1 out of 10)
*/

  uint256 public constant TICKET_NUMBER_MIN = 11000;
  uint256 public constant TICKET_NUMBER_MAX = 99999;
  uint256 public constant TICKET_NUMBER_RANGE = 88999;
  uint256 public constant TICKET_NUMBER_PRIME = 27487;
  uint256 public constant TICKET_HARD_LIMIT = 8000;

  struct ClaimEligibility {
    uint256 noOfTickets;
    uint256 dcTokenId;
    string error;
  }

  function __TicketProvider_init(
    address _cakeMonsterContract,
    address _dcContract,
    address _lotteryTicketNftContract
  ) internal initializer {
    __Ownable_init();

    cakeMonsterContract = _cakeMonsterContract;
    dcContract = _dcContract;
    lotteryTicketNftContract = _lotteryTicketNftContract;

    maxSupply = 50;
    winningChance = 10;
  }

  function increaseSupply(uint256 extraAmount) external onlyOwner {
    require(extraAmount > 0, 'Extra is invalid');
    require(maxSupply + extraAmount <= TICKET_HARD_LIMIT, 'Exceeds ticket hard limit');
    maxSupply += extraAmount;
  }

  function limitSupply() external onlyOwner {
    maxSupply = lastMintedTokenId;
  }

  function setWinningChance(uint256 chance) external onlyOwner {
    require(chance > 0 && chance <= 10, 'Chance is invalid');
    winningChance = chance;
  }

  /// @notice Users having Diamond Claw NFT can claim ticket NFT using this method
  /// @notice if they meet Monsta Threshold according to DC Level
  function claimNFT() external {
    require(false, 'Claiming expired');
  }

  /// @notice Get claimable tickets by the User having DC NFT.
  /// @dev Defensive programming. Return all error cases first
  /// @return object of ClaimEligibility
  function getClaimEligibility() public view returns (ClaimEligibility memory) {
    return ClaimEligibility(0, 0, 'Claiming expired');
  }

  function mint(address to, uint256 amount) public onlyOwner {
    require(lastMintedTokenId + amount <= maxSupply, 'Supply is not enough');
    for (uint256 i = 0; i < amount; ++i) {
      _doMint(to);
    }
  }

  function _doMint(address to) internal {
    uint256 newTokenId = ++lastMintedTokenId;
    ILotteryTicketNFT(lotteryTicketNftContract).mint(to, newTokenId);

    // Map ticketnumber to tokenId
    ticketNumberToTokenMap[getTicketNumber(newTokenId)] = newTokenId;
  }

  function getTicketsOfUser(address _user) public view returns (uint256[] memory tickets) {
    if (_user != address(0)) {
      uint256 totalTickets = IERC721Enumerable(lotteryTicketNftContract).balanceOf(_user);

      tickets = new uint256[](totalTickets);
      for (uint256 i = 0; i < totalTickets; ++i) {
        uint256 ticketId = IERC721Enumerable(lotteryTicketNftContract).tokenOfOwnerByIndex(
          _user,
          i
        );

        tickets[i] = getTicketNumber(ticketId);
      }
    }
    return tickets;
  }

  function getTicketNumber(uint256 ticketId) public pure returns (uint256) {
    return ((ticketId * TICKET_NUMBER_PRIME) % TICKET_NUMBER_RANGE) + TICKET_NUMBER_MIN;
  }

  function setBaseURI(string memory uri) external onlyOwner {
    ILotteryTicketNFT(lotteryTicketNftContract).setBaseURI(uri);
  }
}

// File contracts/main/CakeMonsterLotteryV7.sol

/// @title CakeMonsterLottery
/// @author EresDev
/// @notice This is a partner contract to CakeMonsterDiamondClaw (DC) and CakeMonsterDiamondClawRewards.
/// @notice It allows participants of DC contract to win unclaimed prizes in the lottery.
contract CakeMonsterLotteryV7 is TicketProviderV7, VRFConsumerBaseUpgradeable {
  address public cakeContract;

  mapping(uint256 => Round) private rounds;
  uint256 public currentRound; // starts from 1

  // config
  uint256 public roundsInterval;
  uint256 public rewardInterval;

  //vrf
  bytes32 internal vrfKeyHash;
  uint256 internal vrfFee;
  mapping(uint256 => bytes32) public roundToVrfRequestMap;
  mapping(bytes32 => uint256) public vrfRequestToRoundMap;

  struct Round {
    uint256 startTime;
    uint256 prizeAmount;
    uint256 winnerTicketNumber;
    address winnerAddress;
    bool isPrizeClaimed;
  }

  struct FullView {
    uint256 currentRoundNumber;
    Round currentRound;
    Round previousRound;
    uint256 roundsInterval;
    uint256 rewardInterval;
    uint256 lastMintedTokenId;
    uint256 maxSupply;
    uint256[] ticketsOfUser;
  }

  event RoundStarted(address indexed byUser, uint256 indexed roundNumber);
  event WinnerPicked(address indexed requestBy, uint256 indexed roundNumber, uint256 ticketNumber);
  event PrizeClaimed(
    address indexed byUser,
    uint256 indexed ticketNumber,
    uint256 indexed prizeAmount,
    uint256 roundNumber
  );

  // V7
  uint256 public TICKET_PRICE;

  function initialize(
    address _cakeMonsterContract,
    address _cakeContract,
    address _dcContract,
    address _lotteryTicketNftContract,
    address _vrfCoordinator,
    address _link,
    bytes32 _keyHash,
    uint256 _fee,
    // sync with DC Rewards if required
    uint256[] memory intervals //[startTime, roundsInterval, rewardInterval] / to prevent stack too deep
  ) public initializer {
    __TicketProvider_init(_cakeMonsterContract, _dcContract, _lotteryTicketNftContract);
    __VRFConsumerBaseUpgradeable_initialize(_vrfCoordinator, _link);

    vrfKeyHash = _keyHash;
    vrfFee = _fee;

    cakeContract = _cakeContract;

    roundsInterval = intervals[1];
    setRewardInterval(intervals[2]);

    //set up first round
    currentRound++;
    rounds[currentRound] = Round(intervals[0], 0, 0, address(0), false);

    // Mint first ticket NFT to owner so that totalSupply of NFT Ticket is never 0
    // mint(_msgSender());
  }

  function upgrade(
    uint256 _startTime,
    uint256 _roundsInterval,
    uint256 _rewardInterval
  ) external onlyOwner {
    rounds[currentRound].startTime = _startTime;
    roundsInterval = _roundsInterval;
    rewardInterval = _rewardInterval;
  }

  /// @notice Get the winner address of previous round
  function getLastWinner() public view returns (address) {
    return rounds[currentRound - 1].winnerAddress;
  }

  function _getOwnerOf(uint256 ticketNumber) private view returns (address) {
    uint256 winnerTokenId = ticketNumberToTokenMap[ticketNumber];
    uint256 totalSupply = IERC721Enumerable(lotteryTicketNftContract).totalSupply();
    if (winnerTokenId > totalSupply || winnerTokenId == 0) {
      return address(0);
    }

    address _winner = IERC721Enumerable(lotteryTicketNftContract).ownerOf(winnerTokenId);
    return _winner;
  }

  /// @notice This function allows the winner of previous round to claim their prize
  function claimPrize() external {
    uint256 previousRound = currentRound - 1;

    uint256 claimableTill = rounds[previousRound].startTime + roundsInterval + rewardInterval;
    require(block.timestamp <= claimableTill, 'You are too late');

    require(rounds[previousRound].winnerAddress == _msgSender(), 'You are not winner');
    require(
      _getOwnerOf(rounds[previousRound].winnerTicketNumber) == _msgSender(),
      'You do not own winner ticket'
    );

    require(rounds[previousRound].prizeAmount > 0, 'Cannot claim 0 prize');
    require(rounds[previousRound].isPrizeClaimed != true, 'Already claimed');

    uint256 cakeBalance = IERC20(cakeContract).balanceOf(address(this));
    require(cakeBalance >= rounds[currentRound - 1].prizeAmount, 'Not enough cake in lottery');

    rounds[previousRound].isPrizeClaimed = true;
    IERC20(cakeContract).transfer(
      rounds[previousRound].winnerAddress,
      rounds[currentRound - 1].prizeAmount
    );

    emit PrizeClaimed(
      rounds[previousRound].winnerAddress,
      rounds[previousRound].winnerTicketNumber,
      rounds[previousRound].prizeAmount,
      previousRound
    );
  }

  function pickWinnerAndStartNewRound() public {
    rounds[currentRound].prizeAmount = getCurrentRoundPrize();

    _sendVrfRequest();
    _startNextRound();
  }

  /** Config/GamesRules Updating Functions **/

  /// @notice Set a duration in seconds in which a winner must claim their reward.
  /// @notice After that they cannot claim their reward.
  /// @dev It affects current round and all future rounds.
  function setRewardInterval(uint256 _seconds) public onlyOwner {
    require(_seconds > 0, 'Minimum 1 allowed');
    require(_seconds < roundsInterval, 'Duration too long');
    rewardInterval = _seconds;
  }

  /// @notice Manage Cake token balance of the contract.
  /// @notice It does not affect the prize amount.
  /// @notice If win amount is more than the balance, claimPrize will fail.
  /// @notice Make sure to leave cake for current and previous rounds
  function withdrawTokens(address _tokenAddress) external onlyOwner {
    uint256 amount = IERC20(_tokenAddress).balanceOf(address(this));
    require(amount > 0, 'Token balance is 0');
    IERC20(_tokenAddress).transfer(owner(), amount);
  }

  function withdrawBNB() external onlyOwner {
    uint256 amount = address(this).balance;

    (bool success, ) = owner().call{ value: amount }('');
    require(success, 'Failed to send Ether');
  }

  /** Query Functions **/

  function getCurrentRoundPrize() public view returns (uint256) {
    uint256 cakeBalance = IERC20(cakeContract).balanceOf(address(this));

    if (rounds[currentRound - 1].isPrizeClaimed) {
      return cakeBalance;
    }

    if (hasRewardIntervalPassed() || rounds[currentRound - 1].winnerAddress == address(0)) {
      return cakeBalance;
    } else {
      uint256 prize = 0;
      if (cakeBalance > rounds[currentRound - 1].prizeAmount) {
        prize = cakeBalance - rounds[currentRound - 1].prizeAmount;
      }
      return prize;
    }
  }

  function hasRewardIntervalPassed() internal view returns (bool) {
    return (rounds[currentRound].startTime + rewardInterval) < block.timestamp;
  }

  function getRoundInfo(uint256 _roundNumber) external view returns (Round memory) {
    require(_roundNumber > 0 && _roundNumber <= currentRound, 'Invalid Round Number');

    Round memory roundInfo = rounds[_roundNumber];
    if (_roundNumber == currentRound) {
      roundInfo.prizeAmount = getCurrentRoundPrize();
    }

    return roundInfo;
  }

  /// @notice It returns everything that frontend needs in a single request.
  /// @notice It should be preferred over separate calls to each attribute.
  /// @notice lastMintedTokenId can serve as totalSupply of TicketNFTs
  function getFullView() external view returns (FullView memory) {
    Round memory currentRoundUpdated = rounds[currentRound];
    currentRoundUpdated.prizeAmount = getCurrentRoundPrize();

    FullView memory fullView = FullView(
      currentRound,
      currentRoundUpdated,
      rounds[currentRound - 1],
      roundsInterval,
      rewardInterval,
      lastMintedTokenId,
      maxSupply,
      getTicketsOfUser(_msgSender())
    );

    return fullView;
  }

  /// @notice If rounds are less than 10, returns only those rounds, otherwise last 10 rounds are given
  /// @notice Current round is not included
  /// @notice Returned array is in ascending order by Round Number, newest round at index 0
  function getLast10RoundsHistory() external view returns (Round[] memory) {
    uint256 startRound = currentRound - 1;

    uint256 arraySize = startRound < 10 ? startRound : 10;
    Round[] memory _rounds = new Round[](arraySize);

    uint256 finalRound = startRound < 10 ? 0 : (startRound - 10);
    for (uint256 i = startRound; i > finalRound; --i) {
      uint256 index = startRound - i;
      _rounds[index] = rounds[i];
    }

    return _rounds;
  }

  /// @notice if for some reason (e.g. out of link tokens for VRF), rounds stop to move ahead
  /// @notice to keep the lottery  in sync with current time, owner can call this function
  /// @notice Call to this may cost a lot of gas depending on how far behind we are
  /// @notice To save gas, this method does not call VRF, therefore winner is not picked for these rounds
  /// @notice It will not be of any use to pick a winner for these past rounds when rewardInterval has already passed
  function syncRounds() external onlyOwner {
    require(getCurrentRoundEndTime() < block.timestamp, 'No need to sync');
    while (getCurrentRoundEndTime() < block.timestamp) {
      rounds[currentRound].prizeAmount = getCurrentRoundPrize();
      _startNextRound();
    }
  }

  /** Ticket buying */

  function setTicketPrice(uint256 price) external onlyOwner {
    TICKET_PRICE = price;
  }

  function buy(uint256 amount) external payable {
    require(TICKET_PRICE > 0, 'Ticket price must be set');
    require(amount > 0 && amount <= 5, 'Invalid amount');
    require(lastMintedTokenId + amount <= maxSupply, 'Max ticket supply reached');
    require(msg.value == (amount * TICKET_PRICE), 'Insufficient BNB amount');
    for (uint256 i = 0; i < amount; ++i) {
      _doMint(_msgSender());
    }
  }

  /* private and internal functions and their modifiers */

  modifier roundCloseable() {
    require(getCurrentRoundEndTime() < block.timestamp, 'Too early for result');
    _;
  }

  function _sendVrfRequest() private roundCloseable {
    require(LINK.balanceOf(address(this)) >= vrfFee, 'Not enough VRF LINK token');

    require(roundToVrfRequestMap[currentRound] == 0, 'Already requested');

    bytes32 requestId = requestRandomness(vrfKeyHash, vrfFee);

    roundToVrfRequestMap[currentRound] = requestId;
    vrfRequestToRoundMap[requestId] = currentRound;
  }

  /// @notice Used by Chainlink VRF callback
  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
    require(vrfRequestToRoundMap[requestId] != 0, 'Invalid Request ID');

    uint256 aRound = vrfRequestToRoundMap[requestId];
    require(rounds[aRound].winnerTicketNumber == 0, 'Winner already picked');

    require(aRound > 0, 'Not requested');

    uint256 totalTicketSupply = IERC721Enumerable(lotteryTicketNftContract).totalSupply();

    // Generate winning ticket number
    uint256 winnerTicketId = (randomness % (totalTicketSupply * winningChance)) + 1;
    uint256 winnerTicketNumber = getTicketNumber(winnerTicketId);

    rounds[aRound].winnerTicketNumber = winnerTicketNumber;
    rounds[aRound].winnerAddress = _getOwnerOf(winnerTicketNumber);

    emit WinnerPicked(_msgSender(), aRound, winnerTicketNumber);
  }

  function getCurrentRoundEndTime() internal view returns (uint256) {
    return rounds[currentRound].startTime + roundsInterval;
  }

  function _startNextRound() internal {
    uint256 previousRoundEndTime = getCurrentRoundEndTime();
    currentRound++;
    rounds[currentRound].startTime = previousRoundEndTime;

    emit RoundStarted(_msgSender(), currentRound);
  }
}