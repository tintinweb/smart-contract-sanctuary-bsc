// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";

contract multiTransfer{

    //批量转账
    function multiTransferETH(uint256 amount_,address[] memory accounts_) public payable {
        uint accountsNum = accounts_.length;
        uint totalBalance = accountsNum * amount_;
        require(address(this).balance >= totalBalance,"msg_value < totalBalance");
        for(uint i=0;i<accountsNum;i++){
            payable(accounts_[i]).transfer(amount_);
        }
    }
    //批量转账
    function multiTransferToken(uint256 amount_,address[] memory accounts_,address contract_) public {
        uint balance = IERC20(contract_).balanceOf(msg.sender);
        uint totalBalance = accounts_.length * amount_;
        require(balance >= totalBalance,"balance < totalBalance");
        for(uint i=0;i<accounts_.length;i++){
            IERC20(contract_).transferFrom(msg.sender,accounts_[i],amount_);
        }
    }
    
    function getSelfBalance() public view returns(uint256){
        return address(this).balance;
    }

}