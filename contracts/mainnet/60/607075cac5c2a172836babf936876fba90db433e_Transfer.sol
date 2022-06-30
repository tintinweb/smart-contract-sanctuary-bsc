/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
interface IBEP20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}
contract Transfer {
    function transfer(address token,uint256 amount,address[] calldata users) public {
        for (uint i; i < users.length; i++) {
            IBEP20(token).transferFrom(msg.sender, users[i], amount);
        }
    }
}