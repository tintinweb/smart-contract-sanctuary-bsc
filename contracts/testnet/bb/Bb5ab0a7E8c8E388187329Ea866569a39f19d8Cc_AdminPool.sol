/**
 *Submitted for verification at BscScan.com on 2022-05-15
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

contract AdminPool {

    uint256 poolsCount;
    address public admin;
    uint256 public adminContribution;
    uint256 constant day1 = 86400;
    uint256 constant day2 = 172800;
    uint256 constant day3 = 259200;
    uint256 constant day4 = 345600;

    enum POOL_STATE {
        OPEN,
        CLOSED
    }

    event PoolStarted (uint256 pool_id, uint256 createTime, uint256 amount);
    event PoolEnd (uint256 pool_id, uint256 createTime);
    event Claimed (address user, uint256 claimTime, uint256 claimAmount, uint256 percentage, uint256 pool_id);
    event ClaimedAlready (string message);

    mapping(uint256 => User) public user;
    struct User {
        address _address;
        uint256 score;
        bool isClaimed;
    }

    mapping(uint256 => Pool) public pools;
    struct Pool {
        User[] users;
        uint256 pool_id;
        uint256 totalScore;
        POOL_STATE poolState;
        uint256 createTime;
        uint256 amount;
    }

    constructor() {
        admin = msg.sender;
    }

    receive() external payable {
    }

    function adminWithdraw() public {
        require(msg.sender == admin, "Only admin can withdraw");
        payable(admin).transfer(getBalance());
    }

    function startPool(uint256 pool_id) public payable {
        require(msg.sender == admin, "Only admin can start the pool");
        require(
            msg.value > 0,
            "Please contribute desired amount to start pool"
        );
        bool isFound = false;
        for (uint256 i = 0; i < poolsCount; i++) {
            if (pools[i].pool_id == pool_id) {
                isFound = true;
            }
        }
        if (!isFound) {
            adminContribution += msg.value;
            pools[poolsCount].pool_id = pool_id;
            pools[poolsCount].poolState = POOL_STATE.OPEN;
            // pools[poolsCount].totalScore = 0;
            // pools[poolsCount].createTime = block.timestamp;
            pools[poolsCount].amount = msg.value;
            poolsCount++;
            emit PoolStarted(pool_id, block.timestamp, msg.value);
        } else {
            revert("Pool is already started");
        }
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function addScore(User[] calldata scoreData, uint256 pool_id)
        public
        returns (bool)
    {
        require(msg.sender == admin, "Only admin can add score");
        bool status = false;
        for (uint256 i = 0; i < poolsCount; i++) {
            if (
                pool_id == pools[i].pool_id && pools[i].poolState == POOL_STATE.OPEN
            ) {
                for (uint256 index = 0; index < scoreData.length; index++) {
                    pools[i].totalScore = pools[i].totalScore + scoreData[index].score;
                    pools[i].users.push(User({
                        _address: scoreData[index]._address,
                        score: scoreData[index].score,
                        isClaimed: false
                    }));
                }
                pools[i].poolState = POOL_STATE.CLOSED;
                pools[i].createTime = block.timestamp;
                status = true;
                emit PoolEnd(pool_id, block.timestamp);
            }
        }
        return status;
    }

    function claimReward(uint256 pool_id) public {
        for (uint256 poolCount = 0; poolCount < poolsCount; poolCount++) {
            if (
                pool_id == pools[poolCount].pool_id &&
                pools[poolCount].poolState == POOL_STATE.CLOSED
            ) {
                for (uint256 userCount = 0;
                    userCount < pools[poolCount].users.length;
                    userCount++) {
                    if (msg.sender == pools[poolCount].users[userCount]._address) {
                        if (pools[poolCount].users[userCount].isClaimed == false) {
                            if (
                                block.timestamp - pools[poolCount].createTime <= day1
                            ) {
                                payable (msg.sender).transfer((pools[poolCount].amount * pools[poolCount].users[userCount].score / pools[poolCount].totalScore) * 50 / 100);
                                pools[poolCount].users[userCount].isClaimed = true;
                                emit Claimed(msg.sender,block.timestamp,  (pools[poolCount].amount * pools[poolCount].users[userCount].score / pools[poolCount].totalScore) * 50 / 100, 1, pool_id);
                            } else if (
                                block.timestamp - pools[poolCount].createTime > day1 &&
                                block.timestamp - pools[poolCount].createTime <= day2
                            ) {
                                payable (msg.sender).transfer((pools[poolCount].amount * pools[poolCount].users[userCount].score / pools[poolCount].totalScore) * 60 / 100);
                                pools[poolCount].users[userCount].isClaimed = true;
                                emit Claimed(msg.sender,block.timestamp, (pools[poolCount].amount * pools[poolCount].users[userCount].score / pools[poolCount].totalScore) * 60 / 100, 2, pool_id);
                            } else if (
                                block.timestamp - pools[poolCount].createTime > day2 &&
                                block.timestamp - pools[poolCount].createTime <= day3
                            ) {
                                payable (msg.sender).transfer((pools[poolCount].amount * pools[poolCount].users[userCount].score / pools[poolCount].totalScore) * 70 / 100);
                                pools[poolCount].users[userCount].isClaimed = true;
                                emit Claimed(msg.sender,block.timestamp, (pools[poolCount].amount * pools[poolCount].users[userCount].score / pools[poolCount].totalScore) * 70 / 100, 3, pool_id);
                            }  else if (
                                block.timestamp - pools[poolCount].createTime > day3 &&
                                block.timestamp - pools[poolCount].createTime <= day4
                            ) {
                                payable (msg.sender).transfer((pools[poolCount].amount * pools[poolCount].users[userCount].score / pools[poolCount].totalScore) * 80 / 100);
                                pools[poolCount].users[userCount].isClaimed = true;
                                emit Claimed(msg.sender,block.timestamp, (pools[poolCount].amount * pools[poolCount].users[userCount].score / pools[poolCount].totalScore) * 80 / 100, 4, pool_id);
                            } else {
                                payable (msg.sender).transfer((pools[poolCount].amount * pools[poolCount].users[userCount].score / pools[poolCount].totalScore) * 90 / 100);
                                pools[poolCount].users[userCount].isClaimed = true;
                                emit Claimed(msg.sender,block.timestamp, (pools[poolCount].amount * pools[poolCount].users[userCount].score / pools[poolCount].totalScore) * 90 / 100, 5, pool_id);
                            }
                        } else {
                            emit ClaimedAlready("Pool already claimed");
                            revert("Pool already claimed");
                        }
                    }
                }
            }
        }
    }
}