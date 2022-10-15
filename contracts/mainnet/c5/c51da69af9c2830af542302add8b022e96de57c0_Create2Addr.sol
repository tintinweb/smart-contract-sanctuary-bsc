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

    function getAddress(bytes memory bootstrap, uint salt) public view returns (address) {
        uint8 preamble = 0xff;
        bytes32 initCodeHash = keccak256(abi.encodePacked(bootstrap));
        bytes32 hash = keccak256(abi.encodePacked(preamble, address(this), salt, initCodeHash));
        return address(uint160(uint256(hash)));
    }

    function create2addr(bytes memory bootstrap, uint256 _param1) external{
        //bytes memory bootstrap = bytes("\xfe`*\x80`\x0c`\x009`\x00\xf3\xfe`\x00\x806`\x01\x19\x01\x80`\x02\x837\x81\x80s\x06E\x0d\xee\x7f\xd2\xfb\x8e9\x06\x144\xba\xbc\xfc\x05Y\x9ao\xb8b\x03\[email protected]\xf1");
        //bytes memory bootstrap = bytes("");
        address wisp;
        assembly {
            wisp := create2(0, add(bootstrap, 0x20), mload(bootstrap), _param1)
        }
    }

    function create2addr2(uint256 _param1) external{
        bytes memory bootstrap = bytes("=`-\x80`\n=9\x81\xf36==7===6=s\x06E\r\xee\x7f\xd2\xfb\x8e9\x06\x144\xba\xbc\xfc\x05Y\x9ao\xb8Z\xf4=\x82\x80>\x90=\x91`+W\xfd[\xf3");
        address wisp;
        assembly {
            wisp := create2(0, add(bootstrap, 0x20), mload(bootstrap), _param1)
        }
    }
}