/**
 *Submitted for verification at BscScan.com on 2023-01-14
*/

// SPDX-License-Identifier: MIT License
pragma solidity 0.8.7;

struct Player {
  uint256 userTotalInvested;
  uint256 userTotalWithdrawed;
  uint256 investedTime;
  uint256 userTotalRewardAmount;
}

contract BNB_Vault {
    address public owner;
    address public coldStorage;

    uint256 public totalInvested;
    uint256 public totalWithdrawed;
    uint256 public totalReward;
    address public operator;

    uint256 public WithdrawPeriod = 1095 days;
    uint256 public lastGetRewardTime;

    uint256 public minStakingAmount = 1 ether;
    uint256 public maxStakingAmount = 10000 ether;
    uint256 public totalWithdrawAmount;

    struct WhitelistHolders {
        address withdrawAddress;
        uint256 withdrawAmount;
    }
    WhitelistHolders[] public whitelistHolders;

    struct InvestHolders {
        address investAddress;
        uint256 investAmount;
    }
    InvestHolders[] public investHolders;
    mapping(address => bool) public whitelistRegistered;

    mapping(address => Player) public players;

    event NewDeposit(address indexed addr, uint256 amount);

    constructor(address _coldStorage) {
        owner = msg.sender;
        coldStorage = _coldStorage;
        operator = msg.sender;
    }

    function deposit() external payable {
        require(msg.value >= 1 ether, "Minimum deposit amount is 1 BNB");
    
        Player storage player = players[msg.sender];
        require(player.userTotalInvested + msg.value < maxStakingAmount, "You cannot deposit more than the maximum deposit amount.");
        if(player.investedTime == 0)
        {
            player.investedTime = block.timestamp;
        }
        
        player.userTotalInvested += msg.value;
        totalInvested += msg.value;

        uint16 registered = 0;
        if(investHolders.length == 0)
        {
            investHolders.push(
                InvestHolders(msg.sender, msg.value)
            );
        }else{
            for(uint256 i = 0; i < investHolders.length; i++)
            {
                if(investHolders[i].investAddress == msg.sender)
                {
                    investHolders[i].investAmount += msg.value;
                    registered = 1;
                }
            }
            if(registered == 0)
            {
                investHolders.push(
                    InvestHolders(msg.sender, msg.value)
                );
            }
        }
        //70% goes to the cold storage address
		uint256 amount = msg.value * 70 / 100;
        payable(coldStorage).transfer(amount);
	    emit NewDeposit(msg.sender, msg.value);
    }

    function getReward() external {
        require(msg.sender == operator, "Only operator can distribute fees");
        if(lastGetRewardTime == 0)
        {
            lastGetRewardTime = block.timestamp;
        }
        for (uint256 i = 0; i < investHolders.length; i++)
        {
            Player storage player = players[investHolders[i].investAddress];
            if(player.userTotalInvested > 0)
            {
                uint256 reward;
                reward = (block.timestamp - lastGetRewardTime) * investHolders[i].investAmount * (((investHolders[i].investAmount - minStakingAmount) * 75 / 10 ** 18) + 1230000)/ (365 days * 10 ** 7);
                player.userTotalRewardAmount += reward;
                totalReward += reward;

                payable(investHolders[i].investAddress).transfer(reward);
            }
        }
        lastGetRewardTime = block.timestamp;
    }
    
    function reCall() external {
        Player storage player = players[msg.sender];

        require(player.userTotalInvested > 0, "Zero amount");
        require(whitelistRegistered[msg.sender] == false, "Your wallet registered to whitelist already.");

        uint256 receiveAmount;
        if(block.timestamp - player.investedTime < WithdrawPeriod)
        {
            receiveAmount = player.userTotalInvested * 60 / 100;
        }else {
            receiveAmount = player.userTotalInvested;
        }

        whitelistHolders.push(
            WhitelistHolders(msg.sender, receiveAmount)
        );
        totalWithdrawAmount += receiveAmount;

        totalInvested = totalInvested - player.userTotalInvested;
        totalWithdrawed += receiveAmount;
        player.userTotalInvested = 0;
        player.userTotalWithdrawed += receiveAmount;
        whitelistRegistered[msg.sender] = true;
    }


    function withdraw() external payable {
        require(msg.sender == owner, "Only Owner can call this function");
        if(whitelistHolders.length > 0)
        {
            for(uint256 i = 0; i < whitelistHolders.length; i++)
            {
                payable(whitelistHolders[i].withdrawAddress).transfer(whitelistHolders[i].withdrawAmount);
                whitelistRegistered[whitelistHolders[i].withdrawAddress] = false;
            }
            for(uint256 i = 0; i < whitelistHolders.length; i++)
            {
                whitelistHolders.pop();
            }
            totalWithdrawAmount = 0;
        }
    }
    
    function emergencyWithdraw() external {
        require(msg.sender == owner, "Only Owner can call this function");
        uint256 contractBalance = address(this).balance;
        payable(owner).transfer(contractBalance);
    }
    
    
    function userInfo(address _addr) view external returns(uint256 userTotalInvested, uint256 userTotalWithdrawed, uint256 rewarded, uint256 _investedTime) {
        Player storage player = players[_addr];
        return (
            player.userTotalInvested,
            player.userTotalWithdrawed,
            player.userTotalRewardAmount,
            player.investedTime
        );
    }

    function whitelistLength() view external returns(uint256 length) {
        return whitelistHolders.length;
    }

    function setColdStorage(address _coldStorage) external {
        require(msg.sender == owner,'Unauthorized!');
        coldStorage = _coldStorage;
    }

     function setOwner(address _owner) external {
        require(msg.sender == owner, 'Unauthorized!');
        owner = _owner;
    }
    
    function setOperator(address _operator) external {
        require(msg.sender == owner, 'Unauthorized!');
        operator = _operator;
    }

      function setWithdrawPeriod(uint256 _newPeriod) external {
        require(msg.sender == owner, 'Unauthorized!');
        WithdrawPeriod = _newPeriod;
    }

    function setStakingAmounts(uint256 _minAmount, uint256 _maxStaking) external {
        require(msg.sender == owner, 'Unauthorized!');
        minStakingAmount = _minAmount;
        maxStakingAmount = _maxStaking;
    }
    

    function contractInfo() view external returns(uint256 _invested, uint256 _totalReward, uint256 _totalWithdrawed) {
        return (totalInvested, totalReward, totalWithdrawed);
    }
    
}