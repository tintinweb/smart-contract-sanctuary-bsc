/**
 *Submitted for verification at BscScan.com on 2022-06-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract Guess {
    address public owner;
    uint result;
    
    // struct Player {
    //     address account;
    //     uint amount;
    // }
    mapping(address => uint) mappingAmountGreaterThan;
    mapping(address => uint) mappingAmountLessThan;
    address[] listPlayerGreaterThan;
    address[] listPlayerLessThan;

    // User[] listChooseGreater;
    // User[] listChooseLess;

    constructor() {
        owner = msg.sender;
    }

    modifier checkOwner() {
        require(msg.sender == owner, "Sorry, you are not owner");
        _;
    }

    modifier checkBetAmount() {
        require(msg.value >= 10 ** 15, "Sorry, minimum BNB is 0.001");
        _;
    }


    // For player
    function guessGreaterThan() public payable checkBetAmount {
        uint amount = mappingAmountGreaterThan[msg.sender];
        if(amount == 0) {
            listPlayerGreaterThan.push(msg.sender);
        }
        mappingAmountGreaterThan[msg.sender] = amount + msg.value;
    }

    function guessLessThan() public payable checkBetAmount {
        uint amount = mappingAmountLessThan[msg.sender];
        if(amount == 0) {
            listPlayerLessThan.push(msg.sender);
        }
        mappingAmountLessThan[msg.sender] = amount + msg.value;
    }

    // For admin
    function publishTheResult(uint rs) public checkOwner {
        result = rs;

        
        if(rs == 1) { // Greater Than win
            uint rewardTotal = _sumReward(mappingAmountLessThan, listPlayerLessThan);
            uint betTotal = _sumReward(mappingAmountGreaterThan, listPlayerGreaterThan);

            // Admin get 2%
            uint ownerReward = rewardTotal * 2 / 100;
            payable(owner).transfer(ownerReward);

            rewardTotal -= ownerReward;
            for (uint i = 0 ; i < listPlayerGreaterThan.length; i++) {
                uint betAmount = mappingAmountGreaterThan[listPlayerGreaterThan[i]];
                // Refund bet money + reward distribution
                payable(listPlayerGreaterThan[i]).transfer((rewardTotal * (betAmount * 100 / betTotal) / 100) + mappingAmountGreaterThan[listPlayerGreaterThan[i]]);
            }
        } else { // Less Than win
            uint rewardTotal = _sumReward(mappingAmountGreaterThan, listPlayerGreaterThan);
            uint betTotal = _sumReward(mappingAmountLessThan, listPlayerLessThan);

            // Admin get 2%
            uint ownerReward = rewardTotal * 2 / 100;
            payable(owner).transfer(ownerReward);

            rewardTotal -= ownerReward;
            for (uint i = 0 ; i < listPlayerLessThan.length; i++) {
                uint betAmount = mappingAmountLessThan[listPlayerLessThan[i]];
                // Refund bet money + reward distribution
                payable(listPlayerLessThan[i]).transfer((rewardTotal * (betAmount * 100 / betTotal) / 100) + mappingAmountLessThan[listPlayerLessThan[i]]);
            }
        }

        
    }


    function _sumReward(mapping(address => uint) storage mappingAddrToAmount, address[] memory listPlayers) internal view returns (uint){
        uint rewardTotal;
        for (uint i = 0 ; i < listPlayers.length; i++) {
            rewardTotal += mappingAddrToAmount[listPlayers[i]];
        }
        return rewardTotal;
    }
}