/**
 *Submitted for verification at BscScan.com on 2022-05-23
*/

//SPDX-License-Identifier:UNLICENSE
pragma solidity 0.8.4;

contract caller {
    uint public a;    
    address public b;
    string public c;
    bytes32 public d;
    bool public e;
    uint public f;

    
    function setA(uint _a) public {
        a = _a;
    }

    function setB(address _b) public {
        b = _b;
    }

    function setC(string memory _c) public {
        c = _c;
    }

    function setD(bytes32 _d) public {
        d = _d;
    }

    function setE(bool _e) public {
        e = _e;
    }

    function setF(uint _f) public {
        f = _f;
    }


    function _implementation() public view returns (uint impl) {
        bytes32 slot = 0;
        assembly {
        impl := sload(slot)
        }
    }

    function _implementationAddress() public view returns (address impl) {
        bytes32 slot = 0x0000000000000000000000000000000000000000000000000000000000000001;
        assembly {
        impl := sload(slot)
        }
    }

    function _implementationString() public view returns (string memory impl) {
        bytes32 slot = 0x0000000000000000000000000000000000000000000000000000000000000002;
        assembly {
        impl := sload(slot)
        }
    }

    function _implementationBytes32() public view returns (bytes32 impl) {
        bytes32 slot = 0x0000000000000000000000000000000000000000000000000000000000000003;
        assembly {
        impl := sload(slot)
        }
    }
}