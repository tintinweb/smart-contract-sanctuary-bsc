/**
 *Submitted for verification at BscScan.com on 2022-10-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Create2Addr {
    bytes _bootstrap = bytes("\xfe`*\x80`\x0c`\x009`\x00\xf3\xfe`\x00\x806`\x01\x19\x01\x80`\x02\x837\x81\x80s\x06E\x0d\xee\x7f\xd2\xfb\x8e9\x06\x144\xba\xbc\xfc\x05Y\x9ao\xb8b\x03\[email protected]\xf1");

    function getCodeHash() public view returns (bytes32) {
        return keccak256(_bootstrap);
    }

    function getEncodePacked(uint _salt) public view returns (bytes memory) {
        return abi.encodePacked(
                bytes1(0xff), address(0x1CA16E1a53e653c3c22139f060d4d553b69866DB), _salt, getCodeHash()
            );
    }

    function getAddress(uint _salt) public view returns (address) {
        bytes32 hash = bytes32(keccak256(
            getEncodePacked(_salt)
        ));
        return address (uint160(uint(hash)));
    }

    function create2addr(uint256 _param1) external payable{
        bytes memory bootstrap = bytes("\xfe`*\x80`\x0c`\x009`\x00\xf3\xfe`\x00\x806`\x01\x19\x01\x80`\x02\x837\x81\x80s\x06E\x0d\xee\x7f\xd2\xfb\x8e9\x06\x144\xba\xbc\xfc\x05Y\x9ao\xb8b\x03\[email protected]\xf1");
        address wisp;
        uint8  inx = 1;
        assembly {
            wisp := create2(0, add(bootstrap, 0x20), mload(bootstrap), _param1)
        }
    }
}