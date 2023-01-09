// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Owner.sol";

interface IPay {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract YiBoxPartnerPool is Ownable {
    uint256 public originalTime;
    uint256 public constant  MINT_INTERVAL = 365 days;
    IPay public constant IYiBoxToken = IPay(address(0x433Bc749CE58015A46780b88f013a3EF10Ad7747));

    constructor () {
        originalTime = block.timestamp;
    }

    function getBalance() public view returns (uint256 res) { 
        res = IYiBoxToken.balanceOf(address(this));
    }

    function transfer(address target, uint256 bal) public onlyOwner {
        require(getBalance() >= bal, "Insufficient balance");
        require(bal > 0, "amount error");
        uint256 nowTime = block.timestamp;
        uint256 DelayTime = nowTime - originalTime;
        require(DelayTime > MINT_INTERVAL, "pool is lock");
        IYiBoxToken.transfer(target, bal);
    } 
}