//"SPDX-License-Identifier: MIT"
pragma solidity 0.8.0;

import "./SafeMath.sol";
import "./RPGC.sol";


contract MarketingProxy is Ownable, AdminRole{
    using SafeMath for *;
    
    uint public vestedAmount;
    uint public totalTokensWithdrawn;
    IERC20 public token;

    bool[] isVestedPortionWithdrawn;    

    uint[] distributionDates;
    uint[] distributionPercents;
    uint[] amountPerPortion;

    /// Load initial distribution dates
    constructor (
        uint[] memory _distributionDates,
        uint[] memory _distributionPercents,
        address _adminWallet,
        address _token
    )
    {
        require(_distributionDates.length > 0, "distribution dates are not set");
        require(_distributionDates.length == _distributionPercents.length, "the number of dates and percenages has to be equal");
        // Check distribution percents
        require(correctPercentages(_distributionPercents), "wrong percentages");

        distributionDates = _distributionDates;
        distributionPercents = _distributionPercents;

        // Set the token address
        token = IERC20(_token);
        _addAdmin(_adminWallet);
    }

    function registerVesting() public onlyOwner {
        require(vestedAmount == 0, "(registerVesing) vesting is registred");

        uint proxyBalance = token.balanceOf(address(this));
        require(proxyBalance > 0, "(registerVesting) zero proxy balance");
        vestedAmount = proxyBalance;

        uint perPortion;
        bool[] memory _isPortionWithdrawn = new bool[](distributionDates.length);
        for (uint i = 0; i < distributionDates.length; i++){
            perPortion = proxyBalance.mul(distributionPercents[i]).div(10000);
            amountPerPortion.push(perPortion);
            _isPortionWithdrawn[i] = false;
        }
        isVestedPortionWithdrawn = _isPortionWithdrawn;
    }

    // User will always withdraw everything available
    function withdraw() external onlyOwner {
        uint remainLocked = vestedAmount.sub(totalTokensWithdrawn);
        require(remainLocked > 0, "everything unlocked");

        _withdraw();
    }

    function _withdraw() private {
        uint256 toWithdraw = 0;

        for(uint i = 0; i < distributionDates.length; i++) {
            if(isPortionUnlocked(i) == true) {
                if(!isVestedPortionWithdrawn[i]) {
                    // Add this portion to withdraw amount
                    toWithdraw = toWithdraw.add(amountPerPortion[i]);

                    // Mark portion as withdrawn
                    isVestedPortionWithdrawn[i] = true;
                }
            }
            else {
                break;
            }
            
        }
        
        require(toWithdraw > 0, "nothing to withdraw");
        // Account total tokens withdrawn.
        totalTokensWithdrawn = totalTokensWithdrawn.add(toWithdraw);
        // Transfer all tokens to owner
        token.transfer(msg.sender, toWithdraw);
    }

    function withdrawExcess() external onlyOwner {
        uint outerBalance = token.balanceOf(address(this)).sub(remainUndistributed());
        require(outerBalance > 0, "(withdrawExcess) zero to withdraw");
        token.transfer(owner(), outerBalance);
    }

    function remainUndistributed() public view returns(uint total) {
        for (uint i = 0; i < amountPerPortion.length; i++) {
            if (!isVestedPortionWithdrawn[i]) {
                total = total.add(amountPerPortion[i]);
            }
        }
    }

    function availableToClaim() public view returns(uint) {
        uint256 toWithdraw = 0;

        for(uint i = 0; i < distributionDates.length; i++) {
            if(!isVestedPortionWithdrawn[i]) {
                if(isPortionUnlocked(i) == true) {
                    // Add this portion to withdraw amount
                    toWithdraw = toWithdraw.add(amountPerPortion[i]);
                }
                else {
                    break;
                }
            }
        }

        return toWithdraw;
    }

    function isPortionUnlocked(uint portionId)
    public
    view
    returns (bool)
    {
        return block.timestamp >= distributionDates[portionId];
    }


    // Get all distribution dates
    function getDistributionDates() external view returns (uint256[] memory) {
        return distributionDates;
    }

    // Get all distribution percents
    function getDistributionPercents() external view returns (uint256[] memory) {
        return distributionPercents;
    }

    function getAmountPerPortion() external view returns(uint256[] memory) {
        return amountPerPortion;
    }

    function addAdmin(address account) public onlyOwner {
        require(!isAdmin(account), "[Admin Role]: account already has admin role");
        _addAdmin(account);
    }

    function removeAdmin(address account) public onlyOwner {
        require(isAdmin(account), "[Admin Role]: account has not admin role");
        _removeAdmin(account);
    }

    function correctPercentages(uint[] memory percentages) internal pure returns(bool) {
        uint totalPercent = 0;
        for(uint i = 0 ; i < percentages.length; i++) {
            totalPercent = totalPercent.add(percentages[i]);
        }

        if (totalPercent == 10000)
            return true;
        return false;
    } 

    function updateOneDistrDate(uint index, uint newDate) public onlyAdmin {
        distributionDates[index] = newDate;
    }

    function updateAllDistrDates(uint[] memory newDates) public onlyAdmin {
        require(distributionPercents.length == newDates.length, "the number of Percentages and Dates do not match");
        distributionDates = newDates;
    }

    function updatePercentages(uint[] memory newPercentages) public onlyAdmin {
        require(newPercentages.length == distributionDates.length, "the number of Percentages and Dates do not match");
        require(correctPercentages(newPercentages), "wrong percentages");
        distributionPercents = newPercentages;
    }

    function setNewUnlockingSystem(uint[] memory newDates, uint[] memory newPercentages) public onlyAdmin {
        require(newPercentages.length == newDates.length, "the number of Percentages and Dates do not match");
        require(correctPercentages(newPercentages), "wrong percentages");
        distributionDates = newDates;
        distributionPercents = newPercentages;
    }
}