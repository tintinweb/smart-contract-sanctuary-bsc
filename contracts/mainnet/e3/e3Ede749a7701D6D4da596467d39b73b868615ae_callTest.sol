/**
 *Submitted for verification at BscScan.com on 2022-05-11
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract callTest {

    address public filToke;

    constructor(address _filToken) {
        filToke = _filToken;
    }
    // address public hecoFilToken = "";

    function transfer(address to, uint256 amount) public {
        (bool success,) = filToke.call(abi.encodeWithSignature("transfer(address, uint256)", to, amount));
        require(success, "transfer token failed");
    }

    function balanceOf() public returns(bytes memory) {
        (bool success, bytes memory returndata) = filToke.call(abi.encodeWithSignature("balanceOf(address)", address(this)));
        require(success, "call failed");
        return returndata;
    }
}