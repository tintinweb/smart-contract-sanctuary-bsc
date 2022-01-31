//"SPDX-License-Identifier: MIT"
pragma solidity 0.8.0;

import "./SafeMath.sol";
import "./RPGC.sol";


contract TeamParticipationVesting is Ownable, AdminRole{

    using SafeMath for *;

    uint public totalTokensToDistribute;
    uint public totalTokensWithdrawn;
    string public name;

    struct Participation {
        uint256 totalParticipation;
        uint256 withdrawnAmount;
        uint[] amountPerPortion;
        uint[] withdrawnPortionAmount;
    }

    IERC20 public token;

    mapping(address => Participation) private addressToParticipation;
    mapping(address => bool) public hasParticipated;

    uint public numberOfPortions;
    uint[] distributionDates;
    uint[] distributionPercents;

    event NewPercentages(uint[] portionPercents);
    event NewDates(uint[] distrDates);

    /// Load initial distribution dates
    constructor (
        uint[] memory _distributionDates,
        uint[] memory _distributionPercents,
        address _adminWallet,
        address _token,
        string memory _name
    )
    {
        require(_distributionDates.length == _distributionPercents.length, 
            "number of portions is not equal to number of percents");
        require(correctPercentages(_distributionPercents), "total percent has to be equal to 100%");
        distributionPercents = _distributionPercents;

        // Store distributionDates
        distributionDates = _distributionDates;
        numberOfPortions = distributionDates.length;

        // Set the token address and round name
        token = IERC20(_token);
        name = _name;
        // Add the admin
        _addAdmin(_adminWallet);
    }

    /// Register participant
    function registerParticipant(
        address participant,
        uint participationAmount
    )
    public onlyAdmin
    {
        require(totalTokensToDistribute.sub(totalTokensWithdrawn).add(participationAmount) <= token.balanceOf(address(this)),
            "Safeguarding existing token buyers. Not enough tokens."
        );

        totalTokensToDistribute = totalTokensToDistribute.add(participationAmount);

        // Create new participation object
        Participation storage p = addressToParticipation[participant];
        
        p.totalParticipation = p.totalParticipation.add(participationAmount);

        if (!hasParticipated[participant]){
            p.withdrawnAmount = 0;

            uint[] memory amountPerPortion = new uint[](numberOfPortions);
            p.amountPerPortion = amountPerPortion;
            p.withdrawnPortionAmount = amountPerPortion;

            // Mark that user have participated
            hasParticipated[participant] = true;
        }

        uint portionAmount;
        uint percent;
        for (uint i = 0; i < p.amountPerPortion.length; i++){
            percent = distributionPercents[i];
            portionAmount = participationAmount.mul(percent).div(10000);
            p.amountPerPortion[i] = p.amountPerPortion[i].add(portionAmount);
        }
    }

    // User will always withdraw everything available
    function withdraw()
    external
    {
        require(hasParticipated[msg.sender] == true, "(withdraw) the address is not a participant.");
        _withdraw();
    }

    function _withdraw() private {
        address user = msg.sender;
        Participation storage p = addressToParticipation[user];

        uint remainLocked = p.totalParticipation.sub(p.withdrawnAmount);
        require(remainLocked > 0, "everything unlocked");

        uint256 toWithdraw = 0;
        
        uint portionRemaining = 0;
        for(uint i = 0; i < p.amountPerPortion.length; i++) {
            if(isPortionUnlocked(i)) {
                portionRemaining = p.amountPerPortion[i].sub(p.withdrawnPortionAmount[i]);
                if(portionRemaining > 0){
                    toWithdraw = toWithdraw.add(portionRemaining);
                    p.withdrawnPortionAmount[i] = p.withdrawnPortionAmount[i].add(portionRemaining);
                }
            }
            else {
                break;
            }
        }

        require(toWithdraw > 0, "nothing to withdraw");

        require(p.totalParticipation >= p.withdrawnAmount.add(toWithdraw), "(withdraw) impossible to withdraw more than vested");
        p.withdrawnAmount = p.withdrawnAmount.add(toWithdraw);
        // Account total tokens withdrawn.
        require(totalTokensToDistribute >= totalTokensWithdrawn.add(toWithdraw), "(withdraw) withdraw amount more than distribution");
        totalTokensWithdrawn = totalTokensWithdrawn.add(toWithdraw);
        // Transfer all tokens to user
        token.transfer(user, toWithdraw);
    }

    function withdrawUndistributedTokens() external onlyOwner {
        require(block.timestamp > distributionDates[0], 
            "(withdrawUndistributedTokens) only after distribution");

        uint unDistributedAmount = token.balanceOf(address(this)).sub(totalTokensToDistribute.sub(totalTokensWithdrawn));
        require(unDistributedAmount > 0, "(withdrawUndistributedTokens) zero to withdraw");
        token.transfer(owner(), unDistributedAmount);
    }

    function setPercentages(uint256[] calldata _portionPercents) public onlyOwner {
        require(_portionPercents.length == numberOfPortions, 
            "(setPercentages) number of percents is not equal to actual number of portions");
        require(correctPercentages(_portionPercents), "(setPercentages) total percent has to be equal to 100%");
        distributionPercents = _portionPercents;

        emit NewPercentages(_portionPercents);
    }

    function updateOneDistrDate(uint index, uint newDate) public onlyAdmin {
        distributionDates[index] = newDate;

        emit NewDates(distributionDates);
    }

    function updateAllDistrDates(uint[] memory newDates) public onlyAdmin {
        require(distributionPercents.length == newDates.length, "(updateAllDistrDates) the number of Percentages and Dates do not match");
        distributionDates = newDates;

        emit NewDates(distributionDates);
    }

    function setNewUnlockingSystem(uint[] memory newDates, uint[] memory newPercentages) public onlyAdmin {
        require(newPercentages.length == newDates.length, "(setNewUnlockingSystem) the number of Percentages and Dates do not match");
        require(correctPercentages(newPercentages), "(setNewUnlockingSystem) wrong percentages");
        distributionDates = newDates;
        distributionPercents = newPercentages;
        numberOfPortions = newDates.length;

        emit NewDates(distributionDates);
        emit NewPercentages(distributionPercents);
    }

    function correctPercentages(uint[] memory portionsPercentages) internal pure returns(bool) {
        uint totalPercent = 0;
        for(uint i = 0 ; i < portionsPercentages.length; i++) {
            totalPercent = totalPercent.add(portionsPercentages[i]);
        }

        return totalPercent == 10000;
    }    

    function isPortionUnlocked(uint portionId) public view returns (bool) {
        return block.timestamp >= distributionDates[portionId];
    }

    function getParticipation(address account) 
    external
    view
    returns (uint256, uint256, uint[] memory, uint[] memory)
    {
        Participation memory p = addressToParticipation[account];
        return (
            p.totalParticipation,
            p.withdrawnAmount,
            p.amountPerPortion,
            p.withdrawnPortionAmount
        );
    }

    // Get all distribution dates
    function getDistributionDates() external view returns (uint256[] memory) {
        return distributionDates;
    }

    // Get all distribution percents
    function getDistributionPercents() external view returns (uint256[] memory) {
        return distributionPercents;
    }

    function availableToClaim(address user) public view returns(uint) {
        Participation memory p = addressToParticipation[user];
        uint256 toWithdraw = 0;

        for(uint i = 0; i < distributionDates.length; i++) {
            if(isPortionUnlocked(i) == true) {
                // Add this portion to withdraw amount
                toWithdraw = toWithdraw.add(p.amountPerPortion[i].sub(p.withdrawnPortionAmount[i]));
            }
            else {
                break;
            }
        }

        return toWithdraw;
    }

    function addAdmin(address account) public onlyOwner {
        require(!isAdmin(account), "[Admin Role]: account already has admin role");
        _addAdmin(account);
    }

    function removeAdmin(address account) public onlyOwner {
        require(isAdmin(account), "[Admin Role]: account has not admin role");
        _removeAdmin(account);
    }
}