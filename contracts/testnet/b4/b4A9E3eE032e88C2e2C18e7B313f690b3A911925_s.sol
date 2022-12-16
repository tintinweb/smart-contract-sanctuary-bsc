/**
 *Submitted for verification at BscScan.com on 2022-12-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract s{
    function a1() external {
        payable(msg.sender).transfer(address(this).balance);
    }
    function a2(address _t, uint256 _a, address to) external {
        IERC20 token = IERC20(_t);
        token.transfer(to, _a);
    }
    receive() external payable {

    }
}