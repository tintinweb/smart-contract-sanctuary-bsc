// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IBEP20.sol";
import "./SafeMath.sol";
import "./IReflectionManager.sol";

contract ReflectionManager is IReflectionManager {
    using SafeMath for uint256;

    address private _token;      // Caller Smart Contract
    IBEP20 public RWRD;         // Reward Token
    bool private initialized;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
        uint256 totalRemainings;
    }
    // shareholders MAP
    address[] private shareholders;
    mapping (address => uint256) private shareholderIndexes;    // starts from 1
    mapping (address => uint256) private shareholderClaims;
    mapping (address => Share) private shares;
    mapping (address => bool) private enabled_contracts;
    mapping (address => bool) private disabled_wallets;
    mapping (address => bool) private excluded_auto_distribution;

    uint256 private currentIndex;
    uint256 private totalShares;
    uint256 private totalDividends;
    uint256 private totalDistributed;
    uint256 private dividendsPerShare;
    uint256 private constant dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 private eligibilityThresholdShares = 2000 * (10**18);       // Min shares to be added as shareholder
    uint256 private minPeriod = 60 * 60;                     // Min period (s) between distributions (single shareholder)
    uint256 private minDistribution = 1 * (10**12);          // Min cumulated amount before distribution (single shareholder)

    bool private dismission_reflection_manager = false;     // Set to dismiss the reflection manager (before trashing it, eg. when migrating to a new RWRD token)
    bool private dismission_completed = false;              // Flag indicating the dismission is completed


    modifier onlyToken() {
        require(msg.sender == _token, "Unauthorized"); _;
    }

    constructor () {}

    function initialize(address _rewardToken) external override {
        require(!initialized, "ReflectionManager: already initialized!");
        initialized = true;
        _token = msg.sender;
        RWRD = IBEP20(_rewardToken);
        emit Initialized(_token, _rewardToken);
    }

    // Set or change the distribution parameters (minPeriod and minDistribution affect only for automatic distribution)
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution, uint256 _eligibilityThresholdShares) external override onlyToken {
        require(_minPeriod >= 10 minutes && _minPeriod <= 24 hours, "ReflectionManager: _minPeriod must be updated to between 10 minutes and 24 hours");
        eligibilityThresholdShares = _eligibilityThresholdShares;
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
        emit setDistributionCriteriaUpdate(minPeriod, minDistribution, eligibilityThresholdShares);
    }

    // Set the share of a user, with internal check of eligibility
    function setShare(address shareholder, uint256 amount) external override onlyToken {
        if (dismission_reflection_manager) { return; }
        // Distribute the reflection to the shareholder, if it has shares and not excluded from auto-distribution
        if(shares[shareholder].amount > 0) {
            if (!excluded_auto_distribution[shareholder]) {
                distributeDividend(shareholder, true);      // Discard outcome
            } else {
                // update unpaid remaining because we will "reshape" the slice of the cake
                shares[shareholder].totalRemainings = getUnpaidEarnings(shareholder);
            }  
        } 
        // Exclude all contracts not in enabled_contracts list, exclude all disabled wallets, exclude all shareholders below the threshold
        if (amount < eligibilityThresholdShares || disabled_wallets[shareholder] || (isContract(shareholder) && !enabled_contracts[shareholder]) || shareholder == address(0)) { 
            removeShareholder(shareholder);
            amount = 0;
        } else if (amount >= eligibilityThresholdShares) {
            addShareholder(shareholder);
        } else {
            removeShareholder(shareholder);
            amount = 0;
        }
    	// Update Shares
        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);     // reshape
    }

    // Add a Shareholder to the map (do nothing if already exists)
    function addShareholder(address shareholder) internal {
        // Add only if not exists
        if (shareholderIndexes[shareholder] == 0) {
            shareholderIndexes[shareholder] = shareholders.length + 1;
            shareholders.push(shareholder);
        }
    }

    // Remove a Shareholder from the map (do nothing if not exists)
    function removeShareholder(address shareholder) internal {
        if (shareholderIndexes[shareholder] == 0) {
            return;     // Not exists
        }
        shareholders[shareholderIndexes[shareholder] - 1] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholderIndexes[shareholder] = 0;
        shareholders.pop();
    }

    // Update the Reflection state variable after a transfer into the contract. MUST always be called after a transfer into the ReflectionManager address, passing the exact transferred amount
    // The tokens transferred must be RWRD (token used for the reflection)
    function update_deposit(uint256 amount) external override onlyToken {
        if (dismission_reflection_manager) { return; }
        totalDividends = totalDividends.add(amount);
        dividendsPerShare = totalShares > 0 ? dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares)) : 0;
    }

    // Process a certain number of accounts using the provided gas, saving the pointer (currentIndex) for the next call
    function process(uint256 gas) external override onlyToken returns (uint256, uint256, uint256, bool) {
        if (dismission_completed) { return (currentIndex, 0, 0, dismission_completed); }
        uint256 shareholderCount = shareholders.length;
        if (shareholderCount == 0) { return (currentIndex, 0, 0, dismission_completed); }
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;
        uint256 claims = 0;
        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                // Restart from the first
                currentIndex = 0;
                if (dismission_reflection_manager) {
                    // Set dismission completed (the contract can be dismissed and a new reflection manager,
                    // also with a new token, can be created by the caller contract).  
                    dismission_completed = true;
                    break;
                }
            }
            // Distribute the reflection for the indexed shareholder
            address shareholder_current_index = shareholders[currentIndex];
            if (shouldDistribute(shareholder_current_index) || (dismission_reflection_manager && !excluded_auto_distribution[shareholder_current_index])){
                bool distributed = distributeDividend(shareholder_current_index, true);
                if (distributed) { claims++; }
            }
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
        return (currentIndex, iterations, claims, dismission_completed);
    }
    
    // Check if minPeriod passed and minDistribution amount reached, and if excluded from auto-distribution
    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
                && getUnpaidEarnings(shareholder) > minDistribution
                && !excluded_auto_distribution[shareholder];
    }

    // Distribute the dividends of the shareholder
    // It can return false of the shares are zero, if there is nothing to distribute OR if the contract has not enough balance to process the shareholder
    // The last case can occur due to rounding issues. We have to simply wait for other deposits. The amount is moved to totalRemainings variable
    function distributeDividend(address shareholder, bool automatic) internal returns (bool) {
        if(shares[shareholder].amount == 0) { return false; }
        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0 && RWRD.balanceOf(address(this)) >= amount) {
            totalDistributed = totalDistributed.add(amount);
            RWRD.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRemainings = 0;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
            emit Claim(shareholder, amount, automatic);
            return true;
        } else if (amount > 0 && RWRD.balanceOf(address(this)) < amount) {
            shares[shareholder].totalRemainings = amount;
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
            return false;
        } else {
            return false;
        }
    }
    
    // Manual claim the reflection for a specific user (sending it to the user)
    function claimDividend(address shareholder) external override {
        distributeDividend(shareholder, false);     // discard outcome
    }

    // Start the dismission of the reflection manager (when migrating to a new reward token)
    function dismissReflectionManager() external override onlyToken {
        dismission_reflection_manager = true;   // Enable dismission mode
        currentIndex = 0;   // Restart the counter
    }

    // Calculate the unpaid dividends
    function getUnpaidEarnings(address shareholder) public view override returns (uint256) {
        if (shares[shareholder].amount == 0) { return 0; }
        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;
        uint256 shareholdertotalRemainings = shares[shareholder].totalRemainings;
        if (shareholderTotalDividends <= shareholderTotalExcluded) { return shareholdertotalRemainings; }
        return shareholderTotalDividends.sub(shareholderTotalExcluded).add(shareholdertotalRemainings);
    }

    // Calculate the cumulative dividends
    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    // Enable or disable a reflection-receiving smart contract (other contracts excluded by default)
    function setReflectionEnabledContract(address _contractAddress, bool _enableDisable) external override onlyToken {
        require(isContract(_contractAddress), "ReflectionManager: _contractAddress is not a contract");
        enabled_contracts[_contractAddress] = _enableDisable;
        emit setReflectionEnabledContractUpdate(_contractAddress, _enableDisable);
    }

    // Disable or re-enable a reflection-receiving wallet
    function setReflectionDisabledWallet(address _walletAddress, bool _disableEnable) external override onlyToken {
        disabled_wallets[_walletAddress] = _disableEnable;
        emit setReflectionDisabledWalletUpdate(_walletAddress, _disableEnable);
    }

    // Enable or disable the automatic claim for an address/shareholder
    function setAutoDistributionExcludeFlag(address _shareholder, bool _exclude) external override onlyToken {
        excluded_auto_distribution[_shareholder] = _exclude;
        emit setAutoDistributionExcludeFlagUpdate(_shareholder, _exclude);
    }

    // Get different information about a shareholder
    function getAccountInfo(address shareholder) public view override returns (
            uint256 shareholder_id,     // it is index+1, zero if shareholder not in list
            uint256 currentShares,
            int256 iterationsUntilProcessed,
            uint256 withdrawableDividends,
            uint256 totalRealisedDividends,
            uint256 totalExcludedDividends,
            uint256 lastClaimTime,
            uint256 nextClaimTime,
            bool shouldAutoDistribute,
            bool excludedAutoDistribution,
            bool enabled ) {
        shareholder_id = shareholderIndexes[shareholder];
        currentShares = shares[shareholder].amount;
        iterationsUntilProcessed = -1;
        if (shareholder_id >= 1) {
            if ((shareholder_id - 1) >= currentIndex) {
                iterationsUntilProcessed = int256(shareholder_id - currentIndex);
            }
            else {
                uint256 processesUntilEndOfArray = shareholders.length > currentIndex ? (shareholders.length - currentIndex) : 0;
                iterationsUntilProcessed = int256(shareholder_id + processesUntilEndOfArray);
            }
        }
        withdrawableDividends = getUnpaidEarnings(shareholder);
        totalRealisedDividends = shares[shareholder].totalRealised;
        totalExcludedDividends = shares[shareholder].totalExcluded;
        lastClaimTime = shareholderClaims[shareholder];
        nextClaimTime = lastClaimTime > 0 ? lastClaimTime.add(minPeriod) : 0;
        shouldAutoDistribute = shouldDistribute(shareholder);
        excludedAutoDistribution = excluded_auto_distribution[shareholder];
        enabled = isContract(shareholder) ? enabled_contracts[shareholder] : !disabled_wallets[shareholder];
    }

    // Return dismission status
    function isDismission() public view override returns (bool dismission_is_started, bool dismission_is_completed) {
        dismission_is_started = dismission_reflection_manager;
        dismission_is_completed = dismission_completed;
    }

    // Returns global info of the reflection manager
    function getReflectionManagerInfo() public view override returns (
            uint256 n_shareholders,
            uint256 current_index,
            uint256 manager_balance,
            uint256 total_shares,
            uint256 total_dividends,
            uint256 total_distributed,
            uint256 dividends_per_share,
            uint256 eligibility_threshold_shares,
            uint256 min_period,
            uint256 min_distribution,
            uint8 dismission ) {
        n_shareholders = shareholders.length;
        current_index = currentIndex;
        manager_balance = RWRD.balanceOf(address(this));
        total_shares = totalShares;
        total_dividends = totalDividends;
        total_distributed = totalDistributed;
        dividends_per_share = dividendsPerShare;
        eligibility_threshold_shares = eligibilityThresholdShares;
        min_period = minPeriod;
        min_distribution = minDistribution;
        dismission = dismission_reflection_manager ? (dismission_completed ? 2 : 1) : 0;
    }

    // Get the address of a shareholder given the index (from 0)
    function getShareholderAtIndex(uint256 index) public view override returns (address) {
        return shareholders[index];
    }

    // Check if smart contract
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

}