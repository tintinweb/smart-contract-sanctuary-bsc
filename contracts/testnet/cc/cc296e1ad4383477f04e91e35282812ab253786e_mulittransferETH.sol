// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./IERC20.sol"; 
contract mulittransferETH {
    function mulitTransfer(uint256 amount_,address[]memory accounts_) public payable {
        uint accountsNum=accounts_.length ;
        uint totalBlance = accountsNum*amount_;
        require(msg.value >= totalBlance,"you have no enough ether");
        for (uint i=0;i<accountsNum;i++){
            payable (accounts_[i]).transfer(amount_);
        }
    }
}