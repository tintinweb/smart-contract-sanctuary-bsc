// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "ERC20.sol";

contract TestTransfer {


  function transferTokens(address token, address to, uint amount)
        public returns (bool success)
    {
        if (amount > 0) {
            //require(tokenTransferProxy.transferFrom(token, from, to, amount));
            return ERC20(token).transferFrom(msg.sender, to, amount);
        }
    } 



}