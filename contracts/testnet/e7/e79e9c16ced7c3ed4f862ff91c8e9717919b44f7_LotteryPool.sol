// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Lottery.sol";

contract LotteryPool {

    struct lotteryStruct {
        Lottery lotteryContract;
        address manager;
        uint256 endedTimeStamp;
    }

    // map lottery address to lottery info
    mapping(address => lotteryStruct) public lotteriesMapping;

    uint256 public totalLotteries = 0;

    event LotteryCreated(address lotteryAddress);

    address[] public lotteriesContractsAddresses;

    address public manager;

    constructor() {
        manager = msg.sender;
    }

    modifier isOwner {
        require(manager == msg.sender, "action requires Owner/manager");
        _;
    }

    function createLottery(uint256 _timeInMinutes) public {
        // create lottery instance & send the sender's address
        Lottery localLottery = new Lottery(msg.sender);

        // start the lottery
        localLottery.start(_timeInMinutes);

        // save the lottery in lotteries
        lotteriesMapping[address(localLottery)] = lotteryStruct(localLottery, msg.sender, block.timestamp+(_timeInMinutes*60));

        // increase lottery count.
        totalLotteries += 1;

        emit LotteryCreated(address(localLottery));

        // save lottery address
        lotteriesContractsAddresses.push(address(localLottery));
    } 

    // will return all lotteries
    function getLotteryContractDetails() public view returns (lotteryStruct[] memory){
        lotteryStruct[] memory ret = new lotteryStruct[](totalLotteries);

        for (uint i = 0; i < totalLotteries; i++) {
            ret[i] = lotteriesMapping[lotteriesContractsAddresses[i]];
        }

        return ret;
    }

    // get lotteries
    function getLotteries() public view returns(address[] memory) {
        return lotteriesContractsAddresses;
    }

}