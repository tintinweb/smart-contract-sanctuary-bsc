/**
 *Submitted for verification at BscScan.com on 2022-12-09
*/

// SPDX-License-Identifier: MIT;

pragma solidity ^0.8.0;
contract OwnerTest {   
    Test[] public addressList;

    function newTestAddress() public {
        addressList.push(new Test());
    }

    function newTestAddress2(bytes32 saltUser) public {
        addressList.push(new Test{salt:saltUser}());
    }

    function setA(uint256 num) public {
        addressList[0].setA(num);
    }

    function setAWithCall(uint256 num) public {
        address(addressList[0]).call(abi.encodeWithSignature("setA(uint256)", num));
    }
}

contract Test {
    uint256 public _a0;

    function setA(uint256 b) public {
        _a0 = b;
    }
}