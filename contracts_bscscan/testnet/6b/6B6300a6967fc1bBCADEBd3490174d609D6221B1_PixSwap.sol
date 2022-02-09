/**
 *Submitted for verification at BscScan.com on 2022-02-08
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
    
}

contract PixSwap {

    address private owner_;

    constructor() {    
        owner_ = msg.sender;
    }

    event WithdrawCompleted(address indexed to, uint256 amount, address tokenContract);

    function getEthBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    function withdrawToken(address tokenContract , address receiverWallet, uint256 amount) external{
        require(msg.sender == owner_,'only owner can withdraw');
        IERC20 token = IERC20(tokenContract);
        require(getTokenBalance(tokenContract) >= amount,'insufficient token balance');
        token.transfer(receiverWallet, amount);
        emit WithdrawCompleted(receiverWallet, amount, tokenContract);
    }

    function getTokenBalance(address tokenContract) public view returns (uint256) {
        IERC20 token = IERC20(tokenContract);
        return token.balanceOf(address(this));
    }
}