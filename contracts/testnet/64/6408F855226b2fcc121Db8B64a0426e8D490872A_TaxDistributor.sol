// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "./interfaces/IPancakeRouter02.sol";
import "./interfaces/IGymMLM.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TaxDistributor is Ownable{

    /// @dev Use SafeERC20 library for ERC20 tokens
    using SafeERC20 for IERC20;

    /**
     * @dev minHoldingAmount: required minimum amount to join a pool with this level
     *                        stores amount in BNB format
     *      percentage: share of the pool from the whole sell tax reward
     */
    struct SellRewardPoolInfo {
        uint minHoldingAmount;
        // Percentage 1000 = 100%
        uint8 percentage;
    }

    /**
     * @dev totalPoolRewards: total amount of rewards that pool has
     *      totalPoolHoldings: total amount of tokens that pool participants hold
     *                         stores amount in BNB format
     */
    struct SellRewardPool{
        uint totalPoolRewards;
        uint totalPoolHoldings;
    }

    /**
     * @dev both buy and sell pool reward amounts are stored in BNB format
     *      buyReward: total amount of buy rewards that interval has
     *      sellRewardPools: information about all of the sell pools in the interval
     */
    struct Rewards {
        uint buyReward;
        SellRewardPool[7] sellRewardPools;
    }

    /**
     * @dev startTS: timestamp of interval start time
     *      endTS: timestamp of interval end time
     *      totalTokensHeld: total amount of the tokens that interval participants hold
     *      rewards: information about interval's buy rewards and sell pools rewards
     *               both buy and sell pool reward amounts are stored in BNB format
     *      users: addresses of interval's participants
     *      holdings: record of each participant's holdings at the creation time of the interval
     */   
    struct Interval {
        uint startTS;
        uint endTS;
        uint totalTokensHeld;
        Rewards rewards;
        mapping(address => uint) holdings;
    }

    /// @notice Record of the interval index when user made it's last claim
    mapping(address => uint) public addressToIndexOfLastClaimMapping;

    /// @notice Record of wallet addresses' which are allowed to call certain functions
    mapping(address => bool) public addressToWhitelistMapping;

    /// @notice Record of wallet addresses' which are not allowed to participate in the distribution
    mapping(address => bool) public addressToBlacklistMapping;

    /// @notice Refelection of interval index to information about the interval
    mapping(uint => Interval) public intervals;

    /// @dev Timestamp of reward distribution start time
    uint rewardDistributionStartTS;

    /// @notice Interval's size (unix)
    uint public intervalSize = 1 hours;

    /// @notice current interval's index    
    uint public currentIntervalIndex;

    /// @notice Wallet address which will recieve commissions form buy/sell taxation
    address public companyWalletAddress;

    /// @notice Wallet address of Gym's MLM tree's root
    address public rootAddress;

    /// @notice Token by which BuySellTaxDistributor contract will receive tax (GYM Token)
    IERC20 public taxToken;

    /// @notice Token which will be sent out to the participants and company wallet during reward distribution    
    IERC20 public WBNBToken;

    /// @notice Pancakeswap's contract
    IPancakeRouter02 public routerContract;

    /// @notice Gym MLM contract
    IGymMLM public gymMLMContract;

    /// @notice Information about each pool level 
    SellRewardPoolInfo[7] public sellRewardPoolsInfo;    

    /**
     * @notice Event that is emitted when new interval size is set
     * @param intervalSize new interval size 
     * @param intervalIndex Index of the interval starting from which intervals whill have new size
     */
    event intervalSizeSet(uint indexed intervalSize, uint indexed intervalIndex);

    /**
     * @notice Event that is emitted when interval changes
     * @param intervalIndex interval index that started
     */
    event CurrentIntervalUpdated(uint indexed intervalIndex);

    /**
     * @notice Event that is emitted when buy tax amount increases
     * @param amount amount of the tokens added to interval's buy rewards
     * @dev Amount parameter shows reward amount in BNB format
     * @param intervalIndex index of the interval to which tokens were added
     */
    event BuyTaxAdded(uint amount, uint indexed intervalIndex);

    /**
     * @notice Event that is emitted when sell tax amount increses
     * @param amount amount of the tokens added to interval's sell rewards
     * @dev Amount parameter shows reward amount in BNB format
     * @param intervalIndex index of the interval to which tokens were added 
     */
    event SellTaxAdded(uint amount, uint indexed intervalIndex);

    /**
     * @notice Event that is emitted when reward is claimed
     * @param userAddress address of the user who claimed reward
     * @param intervalIndex index of the interval till which the user has claimed their rewards
     * @param amount amount of the rewards the user has claimed
     * @dev Amount parameter shows rewards amount in BNB format
     */
    event RewardClaimed(address indexed userAddress, uint indexed intervalIndex, uint amount);

    /**
     * @notice Event that is emitted when an address is whitelisted
     * @param walletAddress address of the user who was whitelisted
     * @param intervalIndex index of the interval when user got whitelisted
     */
    event AddressWhitelisted(address indexed walletAddress, uint indexed intervalIndex);

    /**
     * @notice Event that is emitted when an address is removed from the whitelist
     * @param walletAddress address of the user who was removed from the whitelist
     * @param intervalIndex index of the interval when user got removed from the whitelist
     */
    event AddressRemovedFromWhitelist(address indexed walletAddress, uint indexed intervalIndex);

    /**
     * @notice Event that is emitted when an address is blacklisted
     * @param userAddress address of the user who was blacklisted
     * @param intervalIndex index of the interval when user got blacklisted
     */
    event UserBlacklisted(address userAddress, uint indexed intervalIndex);

    /**
     * @notice Event that is emitted when an address is removed from the blacklist    
     * @param userAddress address of the user who was removed from the blacklist
     * @param intervalIndex index of the interval when user got removed from the blacklist
     */
    event UserRemovedFromBlacklist(address userAddress, uint indexed intervalIndex);

    /**
     * @notice Event that is emitted when company's commission is sent    
     * @param amount amount of the tokens that were sent as a commisson to company
     * @param intervalIndex index of the interval when commission was sent
     */
    event CompanyTaxSent(uint amount, uint intervalIndex);

    /**
     * @notice Event that is emitted when interval changes
     * @param intervalIndex index of the new interval
     */
    event NewIntervalStarted(uint intervalIndex);  

    /**
     * @notice Event that is emitted when interval end time changes
     * @param endTS current intervals new end timestamp
    * @param intervalIndex index of interval whos end time changed
     */
    event CurrentIntervalEndTimeChanged(uint endTS, uint intervalIndex);
   
    /**
     * @notice Event that is emitted at the creation of the BuySellTaxDistributor contract
     * @param taxTokenAddress address of the token by which BuySellTaxDistributor contract will receive tax 
     *                        tax token is GYM token
     * @param routerContractAddress address of the PancakeSwap Contract
     * @param gymMLMContractAddress address of the GYM MLM Contract
     * @param rootAddress address of the highest positioned user in the Gym MLM heirarchy 
     * @param companyWalletAddress Wallet address which will recieve commissions form buy/sell taxation
     * @param rewardDistributionStart Timestamp of reward distribution start time
     */
    event ContractCreated(address taxTokenAddress, address routerContractAddress, address gymMLMContractAddress, address rootAddress, address companyWalletAddress, uint rewardDistributionStart);

    /**
     * @dev Modifier that reverts if caller is not whitelisted
     */
    modifier isWhitelisted() {
        require(addressToWhitelistMapping[_msgSender()], "TaxDistributor: You are not authorized to call this function");
        _;
    }

    /**
     * @dev Modifier that reverts if caller is blacklisted
     */    
    modifier isNotBlacklisted() {
        require(!addressToBlacklistMapping[_msgSender()], "TaxDistributor: You have been blacklisted");
        _;
    } 

    /**
     * @dev Does all the necessary checks and prepares everything for the distribution
     * @param _taxToken address of the token by which BuySellTaxDistributor contract will receive tax
     *                  tax token is GYM token
     * @param _routerContract address of the PancakeSwap Contract
     * @param _GymMLMContract address of the Gym's MLM heirarchy
     * @param _rootAddress address of the highest positioned user in the Gym MLM heirarchy 
     * @param _companyWalletAddress wallet address which will recieve commissions form buy/sell taxation
     * @param _rewardDistributionStartTS timestamp of reward distribution start time
     */ 
    constructor(IERC20 _taxToken, IPancakeRouter02 _routerContract, IGymMLM _GymMLMContract, address _rootAddress, address _companyWalletAddress, uint  _rewardDistributionStartTS) {
        require(address(_taxToken) != address(0), "TaxDistributor: Reward token address can not be set to address 0");
        require(address(_routerContract) != address(0), "TaxDistributor: Router contract address can not be set to address 0");
        require(address(_GymMLMContract) != address(0), "TaxDistributor: Gym MLM contract address can not be set to address 0");
        require(_rootAddress != address(0), "TaxDistributor: Gym MLM heirarchy's root address can not be set to address 0");
        require(_companyWalletAddress != address(0), "TaxDistributor: Company wallet address can not be set to address 0");
        require(_rewardDistributionStartTS > block.timestamp, "TaxDistributor: Reward Distribution time must be greater than block timestamp");
        taxToken = _taxToken;
        routerContract = _routerContract;
        gymMLMContract = _GymMLMContract;
        rootAddress = _rootAddress;
        companyWalletAddress = _companyWalletAddress;
        WBNBToken = IERC20(routerContract.WETH());
        rewardDistributionStartTS = _rewardDistributionStartTS;
        addressToWhitelistMapping[_msgSender()] = true;
        blacklistCompanyWalletAddresses();
        setSellRewardPoolsInfo();
        createFirstInterval();
        emit ContractCreated(address(taxToken), address(routerContract), address(gymMLMContract), rootAddress, companyWalletAddress, rewardDistributionStartTS);
    }

    /// @notice This function is called when contract recives BNB
    receive() external payable {}

    /// @notice This function is called when function identifier does not match any of the contract's functions identifiers 
    fallback() external payable {}

    /**
     * @notice Sets tax token's new contract
     *         Only the owner of the contract can call this function
     * @param _taxToken address of the new taxt token contract
     */ 
    function setTaxToken(IERC20 _taxToken) public onlyOwner {
        taxToken = _taxToken;
    }

    /**
     * @notice Sets pancake router's new contract
     *         Only the owner of the contract can call this function
     * @param _routerContract address of the new router contract
     */ 
    function setPancakeRouter(IPancakeRouter02 _routerContract) public onlyOwner {
        routerContract = _routerContract;
    }

    /**
     * @notice Sets GYM MLM's new contract
     *         Only the owner of the contract can call this function
     * @param _GymMLMContract address of the new Gym MLM contract
     */ 
    function setGymMLMContract(IGymMLM _GymMLMContract) public onlyOwner {
        gymMLMContract = _GymMLMContract;
    }

    /**
     * @notice Sets Gym MLM heirarch's highest positioned user's address
     *         Only the owner of the contract can call this function
     * @param _rootAddress address of the Gym MLM heirarch's highest positioned user
     */
    function setMLMRootAddress(address _rootAddress) public onlyOwner {
        rootAddress = _rootAddress;
    }

    /**
     * @notice Sets address to which tax commissions will be sent
     *         Only the owner of the contract can call this function
     * @param _companyWalletAddress wallet address which will recieve commissions form buy/sell taxation
     */
    function setCompanyWalletAddress(address _companyWalletAddress) public onlyOwner {
        companyWalletAddress = _companyWalletAddress;
    }

    /**
     * @notice Sets interval size of the next interval
     *         Only the owner of the contract can call this function
     * @param _intervalSize size of the next interval
     */ 
    function setIntervalSize(uint _intervalSize) public onlyOwner {
        require(_intervalSize >= 1 hours, "TaxDistributor: The interval size must be at least an hour");
        require(intervalSize != _intervalSize, "TaxDistributor: The interval size is already set to this value");
        // TBD: Check with Vlad/Rafayel the max available value as well
        intervalSize = _intervalSize;
        emit intervalSizeSet(intervalSize, currentIntervalIndex + 1);
    }

    /**
     * @notice Blacklists a user
     *         Blacklisted users are unbale to participate in the distribution
     *         Only the owner of the contract can call this function
     * @param _walletAddress address of the user who will be blacklisted
     */     
    function addUserToBlacklist(address _walletAddress) public onlyOwner {
        require(!addressToBlacklistMapping[_walletAddress], "TaxDistributor: User is already blacklisted");
        addressToBlacklistMapping[_walletAddress] = true;
        emit UserBlacklisted(_walletAddress, currentIntervalIndex);
    }

    /**
     * @notice Removes a user from Blacklist
     *         Blacklisted users are unable to participate in the distribution
     *         Only the owner of the contract can call this function
     * @param _walletAddress address of the user who will be remmoved from the blacklist
     */ 
    function removeUserFromBlacklist(address _walletAddress) public onlyOwner {
        require(addressToBlacklistMapping[_walletAddress], "TaxDistributor: User is not blacklisted");
        addressToBlacklistMapping[_walletAddress] = false;
        emit UserRemovedFromBlacklist(_walletAddress, currentIntervalIndex);
    }

    /**
     * @notice Whitelists a new address
     *         Whitelisted addresses are able to call certain functionality which are restricted for ordinary users
     *         Only the owner of the contract can call this function
     * @param _walletAddress address of the user who will be whitelisted
     */ 
    function addWalletAddressToWhitelist(address _walletAddress) public onlyOwner {
        require(!addressToWhitelistMapping[_walletAddress], "TaxDistributor: User is already whitelisted");
        addressToWhitelistMapping[_walletAddress] = true;
        emit AddressWhitelisted(_walletAddress, currentIntervalIndex);
    }

    /**
     * @notice Removes address from the whitelist
     *         Whitelisted addresses are able to call certain functionality which are restricted for ordinary users
     *         Only the owner of the contract can call this function
     * @param _walletAddress address of the user who will be removed from the whitelist
     */ 
    function removeWalletAddressFromWhitelist(address _walletAddress) public onlyOwner {
        require(addressToWhitelistMapping[_walletAddress], "TaxDistributor: User is not whitelisted");
        addressToWhitelistMapping[_walletAddress] = false;
        emit AddressRemovedFromWhitelist(_walletAddress, currentIntervalIndex);
    }
    
    /**
     * @notice Changes current interval's end time
     *         Only the owner of the contract can call this function
     * @param _endTS new end timestamp of current interval
     */
    function changeCurrentIntervalEndTimestamp(uint _endTS) public onlyOwner {
        require(intervals[currentIntervalIndex].startTS < _endTS, "TaxDistributor: Interval's end timestamp can't be smaller than start timestamp");
        require(block.timestamp < _endTS, "TaxDistributor: Can't change current interval's end timestamp to value from past");
        intervals[currentIntervalIndex].endTS = _endTS;
        emit CurrentIntervalEndTimeChanged(_endTS, currentIntervalIndex); 
    }

    /**
     * @notice Distributes buy rewards
     *         Tax tokens should be approved before calling this function
     *         Only addresses which have been whitelisted can call this function
     * @param _taxAmount amount that was taxed
     */
    function distributeBuyTax(uint _taxAmount) public isWhitelisted {
        require(currentIntervalIndex > 0, "TaxDistributor: Reward distribution has not started yet");
        taxToken.safeTransferFrom(_msgSender(), address(this), _taxAmount);
        uint taxAmountInBNB = swapTaxTokenToBNB(_taxAmount);
        uint companyTaxAmount = taxAmountInBNB * 6 / 7;
        sendCompanyTax(companyTaxAmount);
        uint buyTaxRewardAmount = taxAmountInBNB - companyTaxAmount;
        intervals[currentIntervalIndex].rewards.buyReward += buyTaxRewardAmount;
        emit BuyTaxAdded(buyTaxRewardAmount, currentIntervalIndex);
    }

    /**
     * @notice Distributes sell rewards
     *         Tax tokens should be approved before calling this function
     *         Only addresses which have been whitelisted can call this function
     * @param _taxAmount amount that was taxed
     */
    function distributeSellTax(uint _taxAmount) public isWhitelisted {
        require(currentIntervalIndex > 0, "TaxDistributor: Reward distribution has not started yet");
        taxToken.safeTransferFrom(_msgSender(), address(this), _taxAmount);
        uint taxAmountInBNB = swapTaxTokenToBNB(_taxAmount);
        uint companyTaxAmount = taxAmountInBNB * 6 / 10;
        sendCompanyTax(companyTaxAmount);
        uint sellTaxRewardAmount = taxAmountInBNB - companyTaxAmount;
        distributeRewardToPools(sellTaxRewardAmount);
        emit SellTaxAdded(sellTaxRewardAmount, currentIntervalIndex);
    } 

    /**
     * @notice Changes the interval
     *         Only addresses which have been whitelisted can call this function
     */
    function startNextInterval() public isWhitelisted {
        require(intervals[currentIntervalIndex].endTS < block.timestamp, "TaxDistributor: Current interval has not finished yet");
        createNextInterval();       
        addUserAndPartnersHoldings(rootAddress, currentIntervalIndex); 
    }

    /**
     * @notice Sends all available unclaimed rewards of the caller to it's address
     *         Blacklisted users can not call this function
     */
    function claimRewards() public isNotBlacklisted {
        require(currentIntervalIndex > 1, "TaxDistributor: Reward distribution has not started yet");
        address walletAddress = _msgSender();
        require(addressToIndexOfLastClaimMapping[walletAddress] < currentIntervalIndex - 1, "TaxDistributor: You have claimed all your available Rewards");
        uint totalRewards = calculateAvailableRewards(walletAddress);
        addressToIndexOfLastClaimMapping[walletAddress] = currentIntervalIndex - 1;
        WBNBToken.safeTransfer(walletAddress, totalRewards);
        emit RewardClaimed(walletAddress, currentIntervalIndex -1, totalRewards);
    }

    /**
     * @notice Calculates all the available unclaimed rewards of the given user
     * @param _walletAddress wallet address whos abailable unclaimed rewards will be callculated
     * @return totalRewards all available unclaimed rewards of the given user 
     */  
    function calculateAvailableRewards(address _walletAddress) public view returns(uint totalRewards) {
        uint buyRewards = calculateWalletAvailableBuyRewards(_walletAddress);
        uint sellRewards = calculateWalletAvailableSellRewards(_walletAddress);
        totalRewards = buyRewards + sellRewards;
    }

    /**
     * @notice Calculates the available unclaimed buy rewards of the given user
     * @param _walletAddress wallet address whos abailable unclaimed rewards will be callculated
     * @return buyRewards available unclaimed buy rewards of the given user 
     */ 
    function calculateWalletAvailableBuyRewards(address _walletAddress) public view returns(uint buyRewards) {
        for(uint intervalIndex = addressToIndexOfLastClaimMapping[_walletAddress] + 1; intervalIndex < currentIntervalIndex; intervalIndex++) {
            if(intervals[intervalIndex - 1].holdings[_walletAddress] > 0)
            {
                buyRewards += intervals[intervalIndex].rewards.buyReward * intervals[intervalIndex].holdings[_walletAddress] / intervals[intervalIndex].totalTokensHeld;
            }
        }
    }

    /**
     * @notice Calculates the buy rewards share of the given user in the given interval
     * @param _walletAddress wallet address whos share will be calculated
     * @param _intervalIndex index of the interval where user's share will be calculated
     * @return walletShare buy rewards share of the given user in the given interval
     *         percentage rounded to 2 decimal places
     */     
    function calculateWalletIntervalBuyRewardShare(address _walletAddress, uint _intervalIndex) public view returns(uint walletShare) {
        walletShare = 10000 * intervals[_intervalIndex].holdings[_walletAddress] / intervals[_intervalIndex].totalTokensHeld;
    }

    /**
     * @notice Calculates the available unclaimed sell rewards of the given user
     * @param _walletAddress wallet address whos abailable unclaimed rewards will be callculated
     * @return sellRewards available unclaimed sell rewards of the given user 
     */ 
    function calculateWalletAvailableSellRewards(address _walletAddress) public view returns(uint sellRewards) {
        for(uint intervalIndex = addressToIndexOfLastClaimMapping[_walletAddress] + 1; intervalIndex < currentIntervalIndex; intervalIndex++) {   
            if(intervals[intervalIndex - 1].holdings[_walletAddress] > 0)
            {
                sellRewards += calculateWalletIntervalSellRewards(_walletAddress, intervalIndex);  
            }       
        }
    }

    /**
     * @notice Calculates the sell rewards share of the given user in the given interval
     * @param _walletAddress wallet address whos share will be calculated
     * @param _intervalIndex index of the interval where user's share will be calculated
     * @return walletShare sell rewards share of the given user in the given interval
     *         percentage rounded to 2 decimal places
     */     
    function calculateWalletIntervalSellRewardShare(address _walletAddress, uint _intervalIndex) public view returns(uint[7] memory walletShare) {
        uint walletHolding = intervals[_intervalIndex].holdings[_walletAddress];
        for(uint poolIndex; poolIndex < sellRewardPoolsInfo.length; poolIndex++){
            if(walletHolding >= sellRewardPoolsInfo[poolIndex].minHoldingAmount){
                uint totalPoolHoldings = intervals[_intervalIndex].rewards.sellRewardPools[_intervalIndex].totalPoolHoldings;
                walletShare[poolIndex] = 10000 * walletHolding / totalPoolHoldings;
            } else {
                break;
            }
        }
    }

    /**
     * @notice Calculates time left till the end of the last interval
     * @return timeLeft time left till the end of the last interval
     */ 
    function calculateTimeLeft() public view returns(uint timeLeft) {
        timeLeft = intervals[currentIntervalIndex].endTS - block.timestamp;
    }

    /**
     * @dev Distributes sell rewards to interval pools according to their share of the sell taxation
     * @param _sellTaxRewardAmount amount of the tax
     */ 
    function distributeRewardToPools(uint _sellTaxRewardAmount) private {
        for(uint poolIndex; poolIndex < sellRewardPoolsInfo.length; poolIndex++) {
            uint poolRewardAmount = _sellTaxRewardAmount * sellRewardPoolsInfo[poolIndex].percentage / 1000;
            intervals[currentIntervalIndex].rewards.sellRewardPools[poolIndex].totalPoolRewards += poolRewardAmount;
        }
    }

    /**
     * @dev Sets all of the minimum required amounts to join the pool and its share from sell taxation
     */ 
    function setSellRewardPoolsInfo() private {
        sellRewardPoolsInfo[0] = SellRewardPoolInfo(  2500 * 1e18, 125);
        sellRewardPoolsInfo[1] = SellRewardPoolInfo(  5000 * 1e18, 125);
        sellRewardPoolsInfo[2] = SellRewardPoolInfo( 12500 * 1e18, 125);
        sellRewardPoolsInfo[3] = SellRewardPoolInfo( 25000 * 1e18, 125);
        sellRewardPoolsInfo[4] = SellRewardPoolInfo( 50000 * 1e18, 125);
        sellRewardPoolsInfo[5] = SellRewardPoolInfo( 99000 * 1e18, 125);
        sellRewardPoolsInfo[6] = SellRewardPoolInfo(166000 * 1e18, 250);
    }

    /**
     * @dev Blacklists all company wallets which will not participating in the distribution
     */
    function blacklistCompanyWalletAddresses() private {
        addressToBlacklistMapping[0x03ac9DE519e006E0f9e173392B4b8657E57fc683] = true;  // NetGymFarming contract address
        addressToBlacklistMapping[0x82917471d087bf0b4E3AB7a4C9c4DFe3a1E495DE] = true;  // GymVaultsBank contract address
        addressToBlacklistMapping[0x627F27705c8C283194ee9A85709f7BD9E38A1663] = true;  // PancakePair contract address
        addressToBlacklistMapping[0x9fAb63Fc64E7A6D7792Bcd995C734dc762DDB5b4] = true;  // PurchaseTax address
        addressToBlacklistMapping[0x7E8413065775E50b0B0717c46118b2E6C87E960A] = true;  // Managment address
        addressToBlacklistMapping[0xeF6afbb3e43A1289Bd6B96252D372058106042f6] = true;  // SellTax address
        addressToBlacklistMapping[0xF0aFdc445E098834886eA29A4EBE1CFD4aCD3A6B] = true;  // Trasury address
        addressToBlacklistMapping[0xC08d6d75fdd67005FA21933bd281B1E6180184b2] = true;  // Owner address
    }

    /**
     * @dev Calculates the sell rewards of the given user in the given interval
     * @param _walletAddress wallet address whos sell rewards will be calculated
     * @param _intervalIndex index of the interval where user's rewards will be calculated
     * @return intervalSellRewards available sell rewards of the given user in the given interval
     */    
    function calculateWalletIntervalSellRewards(address _walletAddress, uint _intervalIndex) private view returns(uint intervalSellRewards) {
        uint walletHolding = intervals[_intervalIndex].holdings[_walletAddress];
        for(uint poolIndex; poolIndex < sellRewardPoolsInfo.length; poolIndex++){
            if(walletHolding >= sellRewardPoolsInfo[poolIndex].minHoldingAmount){
                uint totalPoolRewards = intervals[_intervalIndex].rewards.sellRewardPools[_intervalIndex].totalPoolRewards;
                uint totalPoolHoldings = intervals[_intervalIndex].rewards.sellRewardPools[_intervalIndex].totalPoolHoldings;
                intervalSellRewards += totalPoolRewards * walletHolding / totalPoolHoldings;
            } else {
                break;
            }
        }
    }

    /**
     * @dev Creates the inital interval
     */      
    function createFirstInterval() private {
        intervals[1].startTS = rewardDistributionStartTS;
        intervals[1].endTS = rewardDistributionStartTS + intervalSize;
    }

    /**
     * @dev Increments current interval index
     *      Sets start time, end time and participants of the new interval
     *      Sets the total holdings and individual participants holdings for the new interval
     */   
    function createNextInterval() private {
        currentIntervalIndex++;
        intervals[currentIntervalIndex].startTS = intervals[currentIntervalIndex - 1].endTS;
        intervals[currentIntervalIndex].endTS = intervals[currentIntervalIndex].startTS + intervalSize;
        emit NewIntervalStarted(currentIntervalIndex);  
    }

    /**
     * @dev Adds given user's and it's partner's holdings inside given interval
     * @param _userAddress address of the user whoes holdings will be set inside given interval
     * @param _intervalIndex index of the interval where given users' holdings will be set
     */   
    function addUserAndPartnersHoldings(address _userAddress, uint _intervalIndex) private {
        if(!addressToBlacklistMapping[_userAddress]) {
            uint userHolding = taxToken.balanceOf(_userAddress);
            intervals[_intervalIndex].holdings[_userAddress] = userHolding;
            intervals[_intervalIndex].totalTokensHeld += userHolding;

            for(uint poolIndex; poolIndex < sellRewardPoolsInfo.length; poolIndex++) {
                if(userHolding >= sellRewardPoolsInfo[poolIndex].minHoldingAmount) {
                    intervals[_intervalIndex].rewards.sellRewardPools[poolIndex].totalPoolHoldings += userHolding;
                }else{
                    break;
                }
            }
        }

        uint partnerIndex;
        (bool success, bytes memory returnData) = address(gymMLMContract).call(abi.encodePacked(gymMLMContract.directPartners.selector,abi.encode(_userAddress, partnerIndex)));
        while(success) {
            address partner = address(uint160(uint256(bytes32(returnData))));
            addUserAndPartnersHoldings(partner, _intervalIndex);
            partnerIndex++;
            (success, returnData) = address(gymMLMContract).call(abi.encodePacked(gymMLMContract.directPartners.selector,abi.encode(_userAddress, partnerIndex)));
            partner = address(uint160(uint256(bytes32(returnData))));
        }
    }

    /**
     * @dev Swaps given amount of tax tokens from contract's balance to BNB tokens through pancakeswap contract
     *      Tax token is GYM token
     * @param _amount amount of the tax tokens that will be swaped to BNB tokens
     * @return wbnbAmount returns amount of BNB that the contract has received from pancakeswap contract
     */
    function swapTaxTokenToBNB(uint256 _amount) private returns (uint256 wbnbAmount)
    {
        address[] memory path = new address[](2);
        path[0] = address(taxToken);
        path[1] = address(routerContract.WETH());
        taxToken.approve(address(routerContract), _amount);
        routerContract.swapExactTokensForETHSupportingFeeOnTransferTokens(_amount, 0, path, address(this), block.timestamp + (30 minutes));
        wbnbAmount =  address(this).balance;
    }

    /**
     * @dev Sends to company wallet address given amount of BNB tokens from contract's balance
     * @param _amount amount of BNB tokens that will be sent to company address
     */
    function sendCompanyTax(uint _amount) private {
        WBNBToken.safeTransfer(companyWalletAddress, _amount);
        emit CompanyTaxSent(_amount, currentIntervalIndex);
    }
    
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "./IPancakeRouter01.sol";

interface IPancakeRouter02 is IPancakeRouter01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

interface IGymMLM {
    function isOnGymMLM(address) external view returns (bool);

    function addGymMLM(address, uint256) external;

    function distributeRewards(
        uint256,
        address,
        address
    ) external;

    function updateInvestment(address _user, uint256 _newInvestment) external;

    function investment(address _user) external view returns (uint256);

    function directPartners(address, uint) external returns(address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}