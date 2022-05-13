/**
 *Submitted for verification at BscScan.com on 2022-05-13
*/

//SPDX-License-Identifier:UNLICENSE
pragma solidity 0.8.4;

contract caller {
    uint public a;
    address public b;
    string public c;
    bytes32 public d;
    bool public e;

    
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
}