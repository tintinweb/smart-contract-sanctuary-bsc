/**
 *Submitted for verification at BscScan.com on 2022-06-06
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function symbol() external view returns(string memory);
    
    function name() external view returns(string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    
    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
    Invests Funds Into A Specific Yield Source
 */
interface IYieldSource {

    /**
        Iterates through all sources and recalls all of their 
        Funds back to the Strategy
     */
    function recallAll() external;

    /**
        Recall `amount` of funds associated with a particular SourceID
     */
    function recallAmountByID(uint256 sourceID, uint256 amount) external;

    /**
        Recall all the funds associated with a particular SourceID
     */
    function recallByID(uint256 sourceID) external;

    /**
        Claims Reward From Source
     */
    function claimAllRewards() external returns (uint256);

    /**
        Iterates Through Sources And Claims All Rewards
     */
    function claimByID(uint256 sourceID) external returns (uint256);

    /**
        Distributes All Available Funds To All Yield Sources
     */
    function distribute() external;

    /**
        Delivers Funding Back To Strategy To Be Given To Beneficiaries
     */
    function deliverEarnings() external;

    /**
        Updates Strategy To A New Version
            Can Only Be Called By Existing Strategy
     */
    function updateStrategy(address newStrategy) external;

    /**
        Total Value Locked Inside Yield Source
     */
    function totalValueLocked() external view returns (uint256);

}

/**
    Invests Funds Allocated By Treasury Into Yield Sources
    Allocates Yield Generated To List Of Benefactors
    Most Benefactors should include a 10% Treasury Royalty
    Some Strategies May Host A Large List Of Benefactors
        - annuity deal
        - smart contract utilizing Analysts
        - These should also include a Royalty back to the Treasury
    Most Will Have Few Benefactors Including
        - Treasury 10%
        - XUSD     28-40%
        - XGOV     45-57%
        - UTIL     5%
    Can Be Independant Of Treasury In Terms Of Funding
 */
interface IStrategy {

    /**
        Iterates through all sources and recalls all of their 
        Funds back to the Strategy
     */
    function recallAll() external;

    /**
        Recall all the funds associated with a particular Source
     */
    function recall(address source) external;

    /**
        Recall A Specific Source By A Set Amount
        the Source should handle what this request does
     */
    function recallAmount(address source, uint256 sourceID, uint256 amount) external;

     /**
        Recall A Specific Source By Its ID Number
     */
    function recallByID(address source,  uint256 sourceID) external;

    /**
        Claims Reward From Source
     */
    function claimRewards(address source) external;

    /**
        Iterates Through Sources And Claims All Rewards
     */
    function claimAll() external;

    /**
        Claim Rewards For Particular Yield Source ID
    */
    function claimRewardsByID(address source, uint256 sourceID) external;

    /**
        Distributes All Available Funds In Strategy To All Yield Sources
     */
    function distribute() external;

    /**
        Delivers Funding To All Beneficiaries Based On Allocation
     */
    function distributeRewards() external;

    /**
        Updates The Treasury To A New Version, Can Only Be Called
        By The Treasury Itself
     */
    function updateTreasury(address newTreasury) external;

    /**
        Total Value Locked Inside Yield Source
     */
    function totalValueLocked() external view returns (uint256);

}

/**
    XUSD Treasury Manages All Yield Aggregation Associated With XUSD's Yield Taxation
    Including Setting New Yield Management Contracts (such as the PancakeFarm or Elipsis Farm)
 */
contract Strategy is IStrategy {

    // Yield Source Data
    struct YieldSource {
        bool isSource;
        uint256 allocation;
        uint256 index;
    }

    // Beneficiary Data
    struct Beneficiary {
        bool isBeneficiary;
        uint256 allocation;
        uint256 index;
        uint256 rewardsReceived;
    }

    // Governance Data
    struct Permissions {
        bool isManager;
        bool isClaimer;
    }
    // Address => Governance
    mapping ( address => Permissions ) permissions;

    // Governance Modifiers
    modifier onlyManager() {
        require(permissions[msg.sender].isManager || msg.sender == TREASURY, 'Only Approved Callers');
        _;
    }
    modifier onlyClaimer() {
        require(permissions[msg.sender].isClaimer || permissions[msg.sender].isManager || msg.sender == TREASURY, 'Only Approved Callers');
        _;
    }

    // List Of Beneficiaries
    mapping ( address => Beneficiary ) public beneficiaries;
    address[] public allBeneficiaries;

    // List Of Sources
    mapping ( address => YieldSource ) public sources;
    address[] public allYieldSources;

    // total allocation points to all yield sources
    uint256 public totalAllocation;

    // total allocation points to all beneficiaries
    uint256 public totalBeneficiaryAllocation;

    // total rewards delivered to XUSD
    uint256 public totalRewardsDelivered;

    // total yield sent to aggregators
    uint256 public totalFundsAllocated;

    // Treasury
    address public TREASURY;

    constructor() {
        permissions[msg.sender].isManager = true;
        permissions[msg.sender].isClaimer = true;
        TREASURY = 0x208D864Ef3852eF7DD0A41564A306f0b1D954163;
    }
    
    event YieldSourceAdded(address source, uint256 allocation);
    event YieldSourceRemoved(address source);
    event YieldSourceAllocationUpdated(uint256 allocation);

    event TreasuryUpdated(address newTreasury);
    event FundsDistributed(address yieldSource, uint256 allocation);
    event RewardsDistributed(address beneficiary, uint256 reward);

    event BeneficiaryAllocationUpdated(address beneficiary, uint256 allocation);
    event BeneficiaryAdded(address beneficiary, uint256 allocation);
    event BeneficiaryRemoved(address beneficiary);


    ////////////////////////////////////////////////
    //////////    RESTRICTED FUNCTIONS    //////////
    ////////////////////////////////////////////////

    function setIsManager(address manager, bool isManager) external onlyManager {
        permissions[manager].isManager = isManager;
    }

    function setIsClaimer(address claimer, bool isClaimer) external onlyClaimer {
        permissions[claimer].isClaimer = isClaimer;
    }

    function withdrawToken(address token) external onlyManager {
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

    function updateTreasury(address newTreasury) external override {
        require(msg.sender == TREASURY, 'Only Treasury');
        TREASURY = newTreasury;
        emit TreasuryUpdated(newTreasury);
    }

    /**
        Updates the funding allocation for a given Yield Source
     */
    function updateAllocation(address source, uint256 newAllocation) external onlyManager {
        require(sources[source].isSource, 'Not Source');

        totalAllocation = totalAllocation - sources[source].allocation + newAllocation;
        sources[source].allocation = newAllocation;

        emit YieldSourceAllocationUpdated(newAllocation);
    }

    /**
        Adds a new Yield Source To Distribution
     */
    function addYieldSource(address source, uint256 allocation) external onlyManager {
        require(!sources[source].isSource, 'Already Source');

        // source data
        sources[source].isSource = true;
        sources[source].allocation = allocation;
        sources[source].index = allYieldSources.length;

        // increment total allocation
        totalAllocation += allocation;

        // push to array
        allYieldSources.push(source);
        emit YieldSourceAdded(source, allocation);
    }

    /**
        Removes A Yield Source From Distribution
     */
    function removeYieldSource(address source) external onlyManager {
        require(sources[source].isSource, 'Not Yield Source');
        
        // set index of last element to be removed index
        sources[
            allYieldSources[allYieldSources.length - 1]
        ].index = sources[source].index;

        // remove from array
        allYieldSources[
            sources[source].index
        ] = allYieldSources[
            allYieldSources.length - 1
        ];
        allYieldSources.pop();

        // reduce total allocation
        totalAllocation -= sources[source].allocation;

        // delete source data
        delete sources[source].isSource;
        delete sources[source].allocation;
        delete sources[source].index;

        emit YieldSourceRemoved(source);
    }

    /**
        Updates the funding allocation for a given Yield Source
     */
    function updateBeneficiaryAllocation(address beneficiary, uint256 newAllocation) external onlyManager {
        require(beneficiaries[beneficiary].isBeneficiary, 'Not Beneficiary');

        totalBeneficiaryAllocation = totalBeneficiaryAllocation - beneficiaries[beneficiary].allocation + newAllocation;
        beneficiaries[beneficiary].allocation = newAllocation;

        emit BeneficiaryAllocationUpdated(beneficiary, newAllocation);
    }

    /**
        Adds a new Yield Source To Distribution
     */
    function addBeneficiary(address beneficiary, uint256 allocation) external onlyManager {
        require(!beneficiaries[beneficiary].isBeneficiary, 'Already Beneficiary');

        // source data
        beneficiaries[beneficiary].isBeneficiary = true;
        beneficiaries[beneficiary].allocation = allocation;
        beneficiaries[beneficiary].index = allBeneficiaries.length;

        // increment total allocation
        totalBeneficiaryAllocation += allocation;

        // push to array
        allBeneficiaries.push(beneficiary);
        emit BeneficiaryAdded(beneficiary, allocation);
    }

    /**
        Removes A Beneficiary From Distribution
     */
    function removeBeneficiary(address beneficiary) external onlyManager {
        require(beneficiaries[beneficiary].isBeneficiary, 'Not Beneficiary');

        // set index of last element to be removed index
        beneficiaries[
            allBeneficiaries[allBeneficiaries.length - 1]
        ].index = beneficiaries[beneficiary].index;

        // remove from array
        allBeneficiaries[
            beneficiaries[beneficiary].index
        ] = allBeneficiaries[
            allBeneficiaries.length - 1
        ];
        allBeneficiaries.pop();

        // reduce total allocation
        totalBeneficiaryAllocation -= beneficiaries[beneficiary].allocation;

        // remove storage
        delete beneficiaries[beneficiary];
        emit BeneficiaryRemoved(beneficiary);
    }


    ////////////////////////////////////////////////
    //////////      RECALL FUNCTIONS      //////////
    ////////////////////////////////////////////////

    /**
        Iterates through all sources and recalls all of their 
        Funds back to the Strategy
     */
    function recallAll() external override onlyManager {
        for (uint i = 0; i < allYieldSources.length; i++) {
            IYieldSource(allYieldSources[i]).recallAll();
        }
    }

    /**
        Updates Strategy Address Across All Known Yield Sources
     */
    function updateStrategy(address newStrategy) external onlyManager {
        for (uint i = 0; i < allYieldSources.length; i++) {
            IYieldSource(allYieldSources[i]).updateStrategy(newStrategy);
        }
    }

    /**
        Recall all the funds associated with a particular Source
     */
    function recall(address source) external override onlyManager {
        IYieldSource(source).recallAll();
    }

    /**
        Recall A Specific Source By A Set Amount
        the Source should handle what this request does
     */
    function recallByID(address source, uint256 sourceID) external override onlyManager {
        IYieldSource(source).recallByID(sourceID);
    }

    /**
        Recall A Specific Source By A Set Amount
        the Source should handle what this request does
     */
    function recallAmount(address source, uint256 sourceID, uint256 amount) external override onlyManager {
        IYieldSource(source).recallAmountByID(sourceID, amount);
    }



    ////////////////////////////////////////////////
    //////////      CLAIM FUNCTIONS       //////////
    ////////////////////////////////////////////////

    /**
        Claims Reward From Source
     */
    function claimRewards(address source) external override onlyClaimer {
        _claimRewards(source);
    }

    /**
        Iterates Through Sources And Claims All Rewards
     */
    function claimAll() external override onlyClaimer {
        for (uint i = 0; i < allYieldSources.length; i++) {
            _claimRewards(allYieldSources[i]);
            _claimYield(allYieldSources[i]);
        }
    }

    function claimAllWithoutYield() external onlyClaimer {
        for (uint i = 0; i < allYieldSources.length; i++) {
            _claimRewards(allYieldSources[i]);
        }
    }

    function claimRewardsByID(address source, uint256 sourceID) external override onlyClaimer {
        IYieldSource(source).claimByID(sourceID);
    }

    function claimYield(address source) external onlyClaimer {
        _claimYield(source);
    }

    function claimAllYield() external onlyClaimer {
        for (uint i = 0; i < allYieldSources.length; i++) {
            _claimYield(allYieldSources[i]);
        }
    }

    ////////////////////////////////////////////////
    //////////   DISTRIBUTION FUNCTIONS   //////////
    ////////////////////////////////////////////////

    /**
        Distributes Rewards to Beneficiaries
     */
    function distributeRewards() external override onlyClaimer {
        _distributeRewards();
    }

    /**
        Distributes BNB Yield Sources Based On Weight
     */
    function distribute() external override onlyClaimer{
        _distribute();
    }

    /**
        Distributes BNB Yield Sources Based On Weight And Triggers Them
     */
    function distributeAndTrigger() external onlyClaimer{
        _distribute();
        triggerAllYieldSources();
    }

    function donateToSource(address source, uint256 amount) external onlyClaimer {
        require(sources[source].isSource, 'Not Source');
        _deliverFunding(source, amount);
    }

    function triggerYieldSource(address source) external onlyClaimer {
        _triggerYieldSource(source);
    }

    function triggerAllYieldSources() public onlyClaimer {
        for (uint i = 0; i < allYieldSources.length; i++) {
            _triggerYieldSource(allYieldSources[i]);
        }
    }

    receive() external payable {}
    
    ////////////////////////////////////////////////
    //////////     INTERNAL FUNCTIONS     //////////
    ////////////////////////////////////////////////


    function _claimRewards(address source) internal {
        IYieldSource(source).claimAllRewards();
    }

    function _claimYield(address source) internal {
        try IYieldSource(source).deliverEarnings() {} catch {}
    }

    /**
        Distributes BUSD To Yield Sources Based On Weight
     */
    function _distribute() internal {

        // increment total funds allocated
        totalFundsAllocated += address(this).balance;

        // fetch distribution amounts based on balance
        uint256[] memory distributions = _fetchDistribution(address(this).balance);

        // distribute allocations to yield sources
        for (uint i = 0; i < distributions.length; i++) {
            _deliverFunding(allYieldSources[i], distributions[i]);
        }
    }

    /**
        Triggers Yield Source Fund distribution
     */
    function _triggerYieldSource(address source) internal {
        IYieldSource(source).distribute();
    }
    /**
        Distributes BUSD To Beneficiaries Based On Weight
     */
    function _distributeRewards() internal {

        // increment total funds allocated
        totalRewardsDelivered += address(this).balance;

        // fetch distribution amounts based on balance
        uint256[] memory distributions = _fetchDistributionForBeneficiaries(address(this).balance);
        // distribute allocations to yield sources
        for (uint i = 0; i < distributions.length; i++) {
            _deliverReward(allBeneficiaries[i], distributions[i]);
        }
    }

    function _deliverFunding(address source, uint256 allocation) internal {
        
        if (allocation > 0) {
            (bool s,) = payable(source).call{value: allocation}("");
            require(s);
            emit FundsDistributed(source, allocation);
        }

    }

    function _deliverReward(address benefactor, uint256 allocation) internal {

        if (allocation > 0) {
            (bool s,) = payable(benefactor).call{value: allocation}("");
            require(s);
            beneficiaries[benefactor].rewardsReceived += allocation;

            emit RewardsDistributed(benefactor, allocation);
        }
    }


    /**
        Iterates through yield sources and fractions out amount
        Between them based on their allocation score
     */
    function _fetchDistribution(uint256 amount) internal view returns (uint256[] memory) {
        uint256[] memory distributions = new uint256[](allYieldSources.length);
        for (uint i = 0; i < allYieldSources.length; i++) {
            if (sources[allYieldSources[i]].allocation > 0) {
                distributions[i] = ( amount * sources[allYieldSources[i]].allocation / totalAllocation ) - 1;
            } else {
                distributions[i] = 0;
            }
        }
        return distributions;
    }

    /**
        Iterates through beneficiaries and fractions out amount
        Between them based on their allocation score
     */
    function _fetchDistributionForBeneficiaries(uint256 amount) internal view returns (uint256[] memory) {
        uint256[] memory distributions = new uint256[](allBeneficiaries.length);
        for (uint i = 0; i < allBeneficiaries.length; i++) {
            distributions[i] = ( amount * beneficiaries[allBeneficiaries[i]].allocation / totalBeneficiaryAllocation ) - 1;
        }
        return distributions;
    }

    function totalValueLocked() external view override returns (uint256 total) {
        for (uint i = 0; i < allYieldSources.length; i++) {
            total += IYieldSource(allYieldSources[i]).totalValueLocked();
        }
    }

    function getAllYieldSources() external view returns (address[] memory) {
        return allYieldSources;
    }

    function getAllBeneficiaries() external view returns (address[] memory) {
        return allBeneficiaries;
    }
}