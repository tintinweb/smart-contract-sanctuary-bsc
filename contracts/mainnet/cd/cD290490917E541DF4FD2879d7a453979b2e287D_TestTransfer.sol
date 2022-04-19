// SPDX-License-Identifier: MIT
//pragma solidity ^0.8.0;
pragma solidity >=0.5.10;
// import "ERC20.sol";
import "EDV.sol";


contract TestTransfer {
  metaEDuVerse public edv;

  function transferTokens(address to, uint amount)
        public returns (bool success)
    {
        if (amount > 0) {
            //require(tokenTransferProxy.transferFrom(token, from, to, amount));
            //return ERC20(token).transferFrom(msg.sender, to, amount);
            return edv.transfer(to, amount);
        }
    } 



}