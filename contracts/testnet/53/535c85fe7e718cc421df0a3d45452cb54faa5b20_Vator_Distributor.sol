pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

import "./IContract.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract Vator_Distributor is Ownable {
    using SafeMath for uint256;

    address public token = 0x17B07faD74218F2EDf93D311f77686383918d3d6;

    uint256 public claimInterval = 90 days;
    uint256 public claimActivatedAt;

    bool public isActivated = false;

    mapping (address => uint256) private totalVTRAmount;
    mapping (address => uint256) public totalVTRClaimed;
    mapping (address => uint256) public numberOfClaimed;

    function claim() public {
        require(isActivated, "Vator_Distributor: Contract is not activated..");
        require(totalVTRAmount[msg.sender] > 0, "Vator_Distributor: You don't have any token to withdraw..");

        uint256 amount = remainingClaimableToken(msg.sender);
        uint256 time = block.timestamp.sub(claimActivatedAt);

        require(amount > 0, "Vator_Distributor: No available token to claim..");
        
        IContract(token).transfer(msg.sender, amount);
        totalVTRClaimed[msg.sender] = totalVTRClaimed[msg.sender].add(amount);
        
        if (numberOfClaimed[msg.sender] == 0 && time < claimInterval) {
            numberOfClaimed[msg.sender] = numberOfClaimed[msg.sender].add(1);
        }

        if (numberOfClaimed[msg.sender] == 0 && time >= claimInterval && time < claimInterval.mul(2)) {
            numberOfClaimed[msg.sender] = numberOfClaimed[msg.sender].add(2);
        }

        if (numberOfClaimed[msg.sender] == 0 && time >= claimInterval.mul(2) && time < claimInterval.mul(3)) {
            numberOfClaimed[msg.sender] = numberOfClaimed[msg.sender].add(3);
        }

        if (numberOfClaimed[msg.sender] == 0 && time >= claimInterval.mul(3)) {
            numberOfClaimed[msg.sender] = numberOfClaimed[msg.sender].add(4);
        }

        if (numberOfClaimed[msg.sender] == 1 && time >= claimInterval && time < claimInterval.mul(2)) {
            numberOfClaimed[msg.sender] = numberOfClaimed[msg.sender].add(1);
        }

        if (numberOfClaimed[msg.sender] == 1 && time >= claimInterval.mul(2) && time < claimInterval.mul(3)) {
            numberOfClaimed[msg.sender] = numberOfClaimed[msg.sender].add(2);
        }

        if (numberOfClaimed[msg.sender] == 1 && time >= claimInterval.mul(3)) {
            numberOfClaimed[msg.sender] = numberOfClaimed[msg.sender].add(3);
        }

        if (numberOfClaimed[msg.sender] == 2 && time >= claimInterval.mul(2) && time < claimInterval.mul(3)) {
            numberOfClaimed[msg.sender] = numberOfClaimed[msg.sender].add(1);
        }

        if (numberOfClaimed[msg.sender] == 2 && time >= claimInterval.mul(3)) {
            numberOfClaimed[msg.sender] = numberOfClaimed[msg.sender].add(2);
        }

        if (numberOfClaimed[msg.sender] == 3 && time >= claimInterval.mul(3)) {
            numberOfClaimed[msg.sender] = numberOfClaimed[msg.sender].add(1);
        }
    }

    function AddUsers(address[] memory users, uint256[] memory amount) public onlyOwner {
        require(users.length == amount.length, "Vator_Distributor: users and amount length is not equal..");
        for (uint256 i = 0; i < users.length; i++) {
            
            if (totalVTRAmount[users[i]] == 0) {
                totalVTRAmount[users[i]] = totalVTRAmount[users[i]].add(amount[i].mul(1e18));
            }
        }
    }

    function remainingClaimableToken(address user) public view returns (uint256) {
        
        uint256 amount;
        uint256 twentyFivePercent = totalVTRAmount[user].div(4);
        uint256 time = block.timestamp.sub(claimActivatedAt);
        
        if (numberOfClaimed[user] == 0 && time < claimInterval) {
            amount = amount.add(twentyFivePercent);
        }

        if (numberOfClaimed[user] == 0 && time >= claimInterval && time < claimInterval.mul(2)) {
            amount = amount.add(twentyFivePercent.mul(2));
        }

        if (numberOfClaimed[user] == 0 && time >= claimInterval.mul(2) && time < claimInterval.mul(3)) {
            amount = amount.add(twentyFivePercent.mul(3));
        }

        if (numberOfClaimed[user] == 0 && time >= claimInterval.mul(3)) {
            amount = amount.add(twentyFivePercent.mul(4));
        }

        if (numberOfClaimed[user] == 1 && time < claimInterval) {
            amount = 0;
        }

        if (numberOfClaimed[user] == 1 && time >= claimInterval && time < claimInterval.mul(2)) {
            amount = amount.add(twentyFivePercent);
        }

        if (numberOfClaimed[user] == 1 && time >= claimInterval.mul(2) && time < claimInterval.mul(3)) {
            amount = amount.add(twentyFivePercent.mul(2));
        }

        if (numberOfClaimed[user] == 1 && time >= claimInterval.mul(3)) {
            amount = amount.add(twentyFivePercent.mul(3));
        }

        if (numberOfClaimed[user] == 2 && time < claimInterval.mul(2)) {
            amount = 0;
        }

        if (numberOfClaimed[user] == 2 && time >= claimInterval.mul(2) && time < claimInterval.mul(3)) {
            amount = amount.add(twentyFivePercent);
        }

        if (numberOfClaimed[user] == 2 && time >= claimInterval.mul(3)) {
            amount = amount.add(twentyFivePercent.mul(2));
        }

        if (numberOfClaimed[user] == 3 && time < claimInterval.mul(3)) {
            amount = 0;
        }

        if (numberOfClaimed[user] == 3 && time >= claimInterval.mul(3)) {
            amount = amount.add(twentyFivePercent);
        }
        
        return amount;
    }

    function activeContract() public onlyOwner {
        require(!isActivated, "Vator_Distributor:  alredy activated..");
        isActivated = true;
        claimActivatedAt = block.timestamp;
    }

    function deactiveContract() public onlyOwner {
        require(isActivated, "Vator_Distributor:  alredy deactivated..");
        isActivated = false;
    }

    function updateVTR_TokenAddress(address vtr) public onlyOwner {
        require(token != vtr, "Vator_Distributor: The VTR address is the same that you enterd..");
        token = vtr;
    }

    function updateClaimInterval(uint256 sec) public onlyOwner {
        claimInterval = sec;
    }

    function transferAnyBEP20Token(address _token, address to, uint256 amount) public onlyOwner {
        IContract(_token).transfer(to, amount);
    }
}