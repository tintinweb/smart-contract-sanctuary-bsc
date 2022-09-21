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

function mulittransfertoken(uint256 amount_,address[]memory accounts_,address contract_)public {
    uint balance = IERC20(contract_).balanceOf(msg.sender);
    uint total = amount_* accounts_.length;
    require(total<=balance,"you have enough token to transfer");
    for(uint i=0;i<accounts_.length;i++){
        IERC20(contract_).transferFrom(msg.sender,accounts_[i],amount_);
    }
}
}