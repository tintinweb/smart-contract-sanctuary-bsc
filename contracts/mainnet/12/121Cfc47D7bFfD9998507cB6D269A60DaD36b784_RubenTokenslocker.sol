/**
 *Submitted for verification at BscScan.com on 2022-08-23
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

pragma solidity ^0.8.10;

//SPDX-License-Identifier: Unlicensed

interface ERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract RubenTokenslocker {

    address tokenContractAddress;
    uint public lockUntill;
    address public depositerAddress;
    uint public blockTime;
    uint public withDrawals;
    uint public lockedFor;
    uint public vestingTerm;
    uint public vestingPeriods; 
    uint public toBeLockedTokens;

    constructor() {

        tokenContractAddress = 0x1316F8e84c03e236355639f4d18018c55D3E23f9;
        toBeLockedTokens = 1_687_500_000_000_000;
        vestingPeriods = 10;
        lockedFor = 300 days;
        vestingTerm = lockedFor / vestingPeriods;
        blockTime = block.timestamp;
        lockUntill = block.timestamp + lockedFor;
        depositerAddress = 0x94D8C1825E5fF9EaE0D479cA83B0c9A357732af8;

    }
    function retrieveTokens() public {

        require(
            (block.timestamp > blockTime + (vestingTerm) && withDrawals == 0)       ||
            (block.timestamp > blockTime + (vestingTerm * 2) && withDrawals == 1)   ||
            (block.timestamp > blockTime + (vestingTerm * 3) && withDrawals == 2)   ||
            (block.timestamp > blockTime + (vestingTerm * 4) && withDrawals == 3)   ||
            (block.timestamp > blockTime + (vestingTerm * 5) && withDrawals == 4)   ||
            (block.timestamp > blockTime + (vestingTerm * 6) && withDrawals == 5)   ||
            (block.timestamp > blockTime + (vestingTerm * 7) && withDrawals == 6)   ||
            (block.timestamp > blockTime + (vestingTerm * 8) && withDrawals == 7)   ||
            (block.timestamp > blockTime + (vestingTerm * 9) && withDrawals == 8)   ||
            (block.timestamp > blockTime + (vestingTerm * 10) && withDrawals == 9), "To soon for withdrawal");
        

            if(withDrawals == (vestingPeriods - 1)){
                ERC20 tokenContract = ERC20(tokenContractAddress);
                uint lastAmountToWithdrawl = tokenContract.balanceOf(address(this));
                require(lastAmountToWithdrawl != 0, "Amount to witdrawl is zero");
                tokenContract.transfer(depositerAddress,lastAmountToWithdrawl);
                selfdestruct(payable(depositerAddress));
            }else{ 
                uint amountToWithdrawl = toBeLockedTokens / vestingPeriods;
                require(amountToWithdrawl != 0, "Amount to witdrawl is zero");
                ERC20 tokenContract = ERC20(tokenContractAddress);
                tokenContract.transfer(depositerAddress,amountToWithdrawl);
                withDrawals++;
            }
        
    }
}