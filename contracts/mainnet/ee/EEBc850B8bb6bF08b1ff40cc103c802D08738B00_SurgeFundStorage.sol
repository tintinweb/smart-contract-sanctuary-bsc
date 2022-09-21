/**
 *Submitted for verification at BscScan.com on 2022-09-21
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IOldFund {
    function allVictims(uint i) external view returns (address);
    function victims(address victim) external view returns (
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        bool);
}

contract SurgeFundStorage {

    // Old Fund
    IOldFund private constant oldFund = IOldFund(0x0dC64c73eD08e683BDd80bb6b4F9E617BA7d3798);

    // Index In Iterating The Old Fund
    uint256 private oldFundIndex = 1;

    // List Of Victims, They're Total Claim And If They Have Been Repaid
    address[] public allVictims;
    address[] public remainingVictims;
    address[] public repaidVictims;
    mapping ( address => uint256 ) public victimOwed;
    mapping ( address => uint256 ) public victimTotalOwed;
    mapping ( address => uint256 ) public victimIndex;

    // Total BNB Owed And Total Repaid
    uint256 public totalOwed;
    uint256 public totalRepaid;

    // Tier Starting Points
    uint256[] public tierStart;
    uint256[] public tiers;

    // number of tiers
    uint256 public constant nTiers = 8;

    // Donation Event
    event Donation(address user, uint256 value);
    event Repaid(address user);
    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor() {

        // init starting tiers
        tierStart = new uint256[](nTiers);
        tierStart[0] = 0;
        tierStart[1] = 1000;
        tierStart[2] = 2000;
        tierStart[3] = 3000;
        tierStart[4] = 4000;
        tierStart[5] = 5000;
        tierStart[6] = 6000;
        tierStart[7] = 7000;

        // init current tiers
        tiers = new uint256[](nTiers);
        tiers[0] = tierStart[0];
        tiers[1] = tierStart[1];
        tiers[2] = tierStart[2];
        tiers[3] = tierStart[3];
        tiers[4] = tierStart[4];
        tiers[5] = tierStart[5];
        tiers[6] = tierStart[6];
        tiers[7] = tierStart[7];

        // init transfer
        emit Transfer(address(0), address(0), 0);
    }

    function updateVictims(uint nVictims) external {
        for (uint i = 0; i < nVictims;) {
            address victim_ = oldFund.allVictims(oldFundIndex);
            (,,uint claim,,,) = oldFund.victims(victim_);
            claim = claim / 420;
            if (victimOwed[victim_] == 0 && claim > 0) {
                victimIndex[victim_] = remainingVictims.length;
                allVictims.push(victim_);
                remainingVictims.push(victim_);
            }
            unchecked {
                victimTotalOwed[victim_] += claim;
                victimOwed[victim_] += claim;
                totalOwed += claim;

                ++i;
                ++oldFundIndex;
            }
            emit Transfer(address(0), victim_, claim);
        }
    }

    function reassign(address to, uint256 victimIndex_) external {
        require(
            victimOwed[msg.sender] > 0,
            'Not Victim'
        );
        require(
            allVictims[victimIndex_] == msg.sender,
            'Invalid Index'
        );

        if (victimOwed[to] == 0) {
            allVictims[victimIndex_] = to;
        }

        victimOwed[to] += victimOwed[msg.sender];
        victimTotalOwed[to] += victimTotalOwed[msg.sender];
        emit Transfer(msg.sender, to, victimOwed[msg.sender]);

        delete victimOwed[msg.sender];
        delete victimTotalOwed[msg.sender];
    }

    function distribute() external {
        _distribute();
    }

    function donate() external payable {
        emit Donation(msg.sender, msg.value);
        _distribute();
    }

    receive() external payable {
        emit Donation(msg.sender, msg.value);
        _distribute();
    }

    function optOut(uint256 amount) external {
        require(
            victimOwed[msg.sender] > 0,
            'Non Victim'
        );
        if (amount > victimOwed[msg.sender]) {
            amount = victimOwed[msg.sender];
        }
        victimOwed[msg.sender] -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

    function fetchAllVictims() external view returns (address[] memory) {
        return allVictims;
    }

    function fetchAllRemainingVictims() external view returns (address[] memory) {
        return remainingVictims;
    }

    function fetchAllRepaidVictims() external view returns (address[] memory) {
        return repaidVictims;
    }

    function nVictimsRepaid() external view returns (uint256) {
        return repaidVictims.length;
    }
    
    function nVictimsRemaining() external view returns (uint256) {
        return remainingVictims.length;
    }

    function nVictimsTotal() external view returns (uint256) {
        return allVictims.length;
    } 

    function balanceOf(address user) external view returns (uint256) {
        return victimOwed[user];
    }

    function totalSupply() external view returns (uint256) {
        return totalOwed - totalRepaid;
    }

    function name() external pure returns (string memory) {
        return 'SurgeFund Receipt';
    }

    function symbol() external pure returns (string memory) {
        return 'PendingBNB';
    }

    function decimals() external pure returns (uint8) {
        return 18;
    }

    function isValidTier(uint tier) public view returns (bool) {
        if (tiers[tier] >= allVictims.length) {
            return false;
        } else if (tier < nTiers -1 ){
            if (tiers[tier] >= tierStart[tier+1]) {
                return false;
            }
        }
        return true;
    }

    function numValidTiers() public view returns (uint256 total) {
        for (uint i = 0; i < nTiers;) {
            if (isValidTier(i)) {
                total++;
            }
            unchecked { ++i; }
        }
    }

    function _distribute() internal {

        uint256 each = address(this).balance / numValidTiers();

        for (uint i = 0; i < nTiers;) {
            
            uint currentAmount = each;
            while (currentAmount > 0) {

                if (!isValidTier(i)) {
                    break;
                }

                address victim = allVictims[tiers[i]];
                uint256 owed = victimOwed[victim];
                if (currentAmount >= owed) {

                    delete victimOwed[victim];
                    unchecked {
                        currentAmount -= owed;
                        totalRepaid += owed;
                    }
                    _send(victim, owed);
                    repaidVictims.push(victim);
                    emit Repaid(victim);

                    address lastVictim = remainingVictims[remainingVictims.length - 1];
                    remainingVictims[victimIndex[victim]] = lastVictim;
                    victimIndex[lastVictim] = victimIndex[victim];
                    remainingVictims.pop();
                    delete victimIndex[victim];

                    tiers[i]++;
                } else {

                    uint amt = currentAmount;
                    victimOwed[victim] -= amt;
                    unchecked {
                        totalRepaid += amt;
                    }
                    delete currentAmount;
                    _send(victim, amt);
                }

            }

            unchecked { ++i; }
        }

    }

    function _send(address to, uint amount) internal {
        if (!isContract(to) && amount > 0) {
            (bool s,) = payable(to).call{value: amount}("");
            if (s) {
                emit Transfer(to, address(0), amount);
            }
        }
    }

    function isContract(address account) public view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

}