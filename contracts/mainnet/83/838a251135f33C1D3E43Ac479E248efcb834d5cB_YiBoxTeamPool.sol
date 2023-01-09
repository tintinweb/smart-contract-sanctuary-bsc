// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Owner.sol";

interface IPay {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract YiBoxTeamPool is Ownable {
    uint256 public originalTime;
    uint256 public constant  MINT_INTERVAL = 365 days;
    uint256 public transfered;
    uint256[9] public maxMintOfYears;
    IPay public constant IYiBoxToken = IPay(address(0x433Bc749CE58015A46780b88f013a3EF10Ad7747));

    constructor () {
        uint256 decimal = 10 ** 18;

        maxMintOfYears[0] = 0;
        maxMintOfYears[1] = 32000000 * decimal;
        maxMintOfYears[2] = 74000000 * decimal;
        maxMintOfYears[3] = 117500000 * decimal;
        maxMintOfYears[4] = 155000000 * decimal;
        maxMintOfYears[5] = 180000000 * decimal;
        maxMintOfYears[6] = 193000000 * decimal;
        maxMintOfYears[7] = 198500000 * decimal;
        maxMintOfYears[8] = 200000000 * decimal;
        originalTime = block.timestamp;
    }

    function getBalance() public view returns (uint256 res) { 
        res = IYiBoxToken.balanceOf(address(this));
    }

    function transfer(address target, uint256 bal) public onlyOwner {
        require(getBalance() >= bal, "Insufficient balance");
        require(bal > 0, "amount error");
        uint256 nowTime = block.timestamp;
        uint256 beTran = transfered + bal;
        uint256 DelayTime = nowTime - originalTime;
        if (DelayTime > 9 * MINT_INTERVAL) {
            transfered = beTran;
            IYiBoxToken.transfer(target, bal);
        } else if (DelayTime > 8 * MINT_INTERVAL) {
            require(maxMintOfYears[8] >= beTran, "Unlock Insufficient balance");
            transfered = beTran;
            IYiBoxToken.transfer(target, bal);
        } else if (DelayTime > 7 * MINT_INTERVAL) {
            require(maxMintOfYears[7] >= beTran, "Unlock Insufficient balance");
            transfered = beTran;
            IYiBoxToken.transfer(target, bal);
        } else if (DelayTime > 6 * MINT_INTERVAL) {
            require(maxMintOfYears[6] >= beTran, "Unlock Insufficient balance");
            transfered = beTran;
            IYiBoxToken.transfer(target, bal);
        } else if (DelayTime > 5 * MINT_INTERVAL) {
            require(maxMintOfYears[5] >= beTran, "Unlock Insufficient balance");
            transfered = beTran;
            IYiBoxToken.transfer(target, bal);
        } else if (DelayTime > 4 * MINT_INTERVAL) {
            require(maxMintOfYears[4] >= beTran, "Unlock Insufficient balance");
            transfered = beTran;
            IYiBoxToken.transfer(target, bal);
        } else if (DelayTime > 3 * MINT_INTERVAL) {
            require(maxMintOfYears[3] >= beTran, "Unlock Insufficient balance");
            transfered = beTran;
            IYiBoxToken.transfer(target, bal);
        } else if (DelayTime > 2 * MINT_INTERVAL) {
            require(maxMintOfYears[2] >= beTran, "Unlock Insufficient balance");
            transfered = beTran;
            IYiBoxToken.transfer(target, bal);
        } else if (DelayTime > MINT_INTERVAL) {
            require(maxMintOfYears[1] >= beTran, "Unlock Insufficient balance");
            transfered = beTran;
            IYiBoxToken.transfer(target, bal);
        } else {
            require(maxMintOfYears[0] >= beTran, "Unlock Insufficient balance");
        }
    } 
}