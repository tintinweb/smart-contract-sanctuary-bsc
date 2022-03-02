/**
 *Submitted for verification at BscScan.com on 2022-03-02
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.8.7;

contract AscentLock {
    constructor() {
        owner = 0x10B7C5D7DB5A6383035558972a34C23514b1eBEd;
        tokenContractAddress = 0x7A66eBFD6Ef9e74213119717A3d03758A4A5891e;
        stakeholders.push();
    }

    receive() payable external {
        
    }

    address owner;
    address tokenContractAddress;

    struct Stake {
        address user;
        uint256 amount;
        uint8 tier;
        uint256 since;
    }

    struct Stakeholder {
        address user;
        Stake[] address_stakes;
    }

    Stakeholder[] public stakeholders;

    mapping(address => uint256) internal stakes;

    event Staked(address indexed user, uint256 amount, uint8 tier, uint256 index, uint256 timestamp);
    event Withdraw(address indexed user, uint256 amount, uint256 reward, uint8 tier, uint256 index, uint256 since, uint256 timestamp);

    function _addStakeholder(address _user) private returns (uint256) {
        stakeholders.push();
        uint256 userIndex = stakeholders.length - 1;
        stakeholders[userIndex].user = _user;
        stakes[_user] = userIndex;
        return userIndex; 
    }

    function stake(uint256 _amount) public payable returns (bool) {
        uint8 _tier;
        if(_amount == 100000) {
            _tier = 5;
        } else if(_amount == 5000000) {
            _tier = 4;
        } else if(_amount == 10000000) {
            _tier = 3;
        } else if(_amount == 25000000) {
            _tier = 2;
        } else if(_amount == 100000000) {
            _tier = 1;
        } else {
            _tier = 0;
        }

        require(_tier != 0, "Invalid stake amount");

        uint256 index = stakes[msg.sender];
        if(index != 0 && stakeholders[index].address_stakes[0].since != 0) {
            revert("You already have an active stake now");
        }
        
        if(_getDeposit(msg.sender, _amount) == true) {
            _stake(msg.sender, _amount, _tier);
            return true;
        } else {
            revert("Transaction is failed");
        }
    }

    function _getDeposit(address _from, uint256 _amount) private returns (bool) {
        IERC20 token = IERC20(tokenContractAddress);
        return token.transferFrom(_from, address(this), _amount);
    }

    function _stake(address _sender, uint256 _amount, uint8 _tier) private {
        uint256 index = stakes[_sender];
        if(index == 0) {
            index = _addStakeholder(_sender);
            uint256 timestamp = block.timestamp;
            stakeholders[index].address_stakes.push(Stake(_sender, _amount, _tier, timestamp));
            emit Staked(_sender, _amount, _tier, index, timestamp);
        } else {
            uint256 timestamp = block.timestamp;
            stakeholders[index].address_stakes[0].user = _sender;
            stakeholders[index].address_stakes[0].amount = _amount;
            stakeholders[index].address_stakes[0].tier = _tier;
            stakeholders[index].address_stakes[0].since = timestamp;
            emit Staked(_sender, _amount, _tier, index, timestamp);
        }
    }



    function withdrawStake() public payable returns (bool) {
        return _withdrawStake(msg.sender);
    }

    function _withdrawStake(address _sender) private returns (bool) {
        uint256 userIndex = stakes[_sender];
        Stake memory currentStake = stakeholders[userIndex].address_stakes[0];
        require(currentStake.since > 0, "Stake is not found");
        if(((block.timestamp - currentStake.since) / 60) < 3) {
            revert("Stake not completed");
        } else {
            uint256 reward = _getStakeReward(currentStake.amount, currentStake.since);
            emit Withdraw(_sender, currentStake.amount, reward, currentStake.tier, userIndex, currentStake.since, block.timestamp);
            delete stakeholders[userIndex].address_stakes[0];

            IERC20 token = IERC20(tokenContractAddress);
            token.transfer(_sender, reward);

            return true;
        }
    }

    function _getStakeReward(uint256 _amount, uint256 _timestamp) private view returns (uint256) {
        uint256 reward;
        uint256 get_minutes = (block.timestamp - _timestamp) / 60;

        reward = _amount + get_minutes * _amount / 1000000 * 1369;
        return reward;
    }



    function withdrawTokens(uint256 amount) public payable returns (bool) {
        IERC20 token = IERC20(tokenContractAddress);

        if(msg.sender != owner) {
            revert("You are not an owner of this contract");
        } else if(token.balanceOf(address(this)) < amount) {
            revert("Balance of this contract is less then amount of withdraw");
        } else {
            _withdrawTokens(amount);
            return true;
        }
    }

    function _withdrawTokens(uint256 amount) private {
        IERC20 token = IERC20(tokenContractAddress);
        token.transfer(owner, amount);
    }



}