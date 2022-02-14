//SPDX-License-Identifier: MIT 

pragma solidity ^0.8.0;

import "IERC20.sol";
import "Ownable.sol";

contract AirdropReward is Ownable {
    uint[] reward = [50, 25, 10];
    uint public unlockTime = 1645660800; ////Thursday, February 24, 2022 12:00:00 AM(GMT)

    mapping(address => bool) public account;
    mapping(address => uint) public accountType;
    mapping(uint256 => uint) public amountReward;

    address public contractAKSToken = 0x0D1CeB4a0718d43785b169Ddf644E13ED86b94Ad;

    event WithdrawAirdropReward(address indexed _from, address indexed _to, uint256 _amount);
    
    function withdrawAirdropReward() external
    {
        require(block.timestamp > unlockTime, "Not available.");
        require(accountType[msg.sender] == 1 || accountType[msg.sender] == 2 || accountType[msg.sender] == 3, "The account is not in whitelist.");
        require(account[msg.sender] == false, "Account has already received the coins.");

        IERC20 _tokenAKS = IERC20(contractAKSToken);

        _tokenAKS.transfer(msg.sender, amountReward[accountType[msg.sender]]);
        account[msg.sender] = true;

        emit WithdrawAirdropReward(address(this), msg.sender, amountReward[accountType[msg.sender]]);
    }

    function importAirdropAccount(address[] memory _accounts, uint8 airdropType) external onlyOwner
    {
        require(airdropType == 1 || airdropType == 2 || airdropType == 3, "Invalid request");
        for(uint i = 0; i < _accounts.length; i++) 
        {
            accountType[_accounts[i]] = airdropType;
            amountReward[airdropType] = reward[airdropType-1] * 10**18;
        }
    }
    
    function setContractAKSToken(address _contractAKSToken) external onlyOwner 
    {
        contractAKSToken = _contractAKSToken;
    }

    function setUnlockTime(uint _unlockTime) external onlyOwner {
        unlockTime = _unlockTime;
    }
}