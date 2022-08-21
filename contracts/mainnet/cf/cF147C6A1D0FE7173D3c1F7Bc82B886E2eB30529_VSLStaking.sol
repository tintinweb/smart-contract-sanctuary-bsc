/**
 *Submitted for verification at BscScan.com on 2022-08-21
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.14;

interface IERC20
{
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

abstract contract Context
{
    function _msgSender() internal view virtual returns (address payable)
    {
        return payable(msg.sender);
    }
}

contract Ownable is Context
{
    address private _owner;
    address private _newOwner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor()
    {
        address msgSender = _msgSender();
        _owner = msgSender;
        _newOwner = address(0);
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address)
    {
        return _owner;
    }

    function isOwner(address who) public view returns (bool)
    {
        return _owner == who;
    }

    modifier onlyOwner()
    {
        require(isOwner(_msgSender()), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner
    {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        require(newOwner != _owner, "Ownable: new owner is already the owner");
        _newOwner = newOwner;
    }

    function acceptOwnership() public
    {
        require(_msgSender() == _newOwner);
        emit OwnershipTransferred(_owner, _newOwner);
        _owner = _newOwner;
        _newOwner = address(0);
    }

    function getTime() public view returns (uint256)
    {
        return block.timestamp;
    }

    function convertToTime(uint256 _numDays, uint256 _numHours, uint256 _numMinutes, uint256 _numSeconds) public pure returns(uint256)
    {
        return (_numDays * 1 days) + (_numHours * 1 hours) + (_numMinutes * 1 minutes) + (_numSeconds * 1 seconds);
    }
}

contract VetterToken
{
    function _getWalletTier(address who) view public returns(uint256) {}
}

// VSL Staking Contract Use - Setup Order:
//  1) Create Contract
//  2) Set VSL Token Contract
//  3) Set Vetter Token Contract
//  4) Make This Contract Tax Free on VSL and Set as Staking Contract
//  5) Setup allowed contract addresses as needed
//      0xd6b36ce79b498ceE55d090165B89A3928FA84603
contract VSLStaking is Ownable
{
    address private constant DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    address private _vslContract;
    VetterToken private _vetterToken;
    address private _vetterContract;

    mapping(address => bool) private _allowedContract;
    uint256 private allowedCount;
    mapping(uint256 => address) private _allowedByID;

    modifier onlyAllowedContract()
    {
        require(isOwner(_msgSender()) || _allowedContract[_msgSender()], "caller is not allowed or owner");
        _;
    }

    // Needed to remove the 9 decimals on the base token and get to the right number of shares
    // Note: 1 tps per 1 token, but we show it to the user as 1 Token = 0.00001 shares
    // Dividing by 100K gives us actual shares since it should be 1 per 100K and we just don't want decimals
    uint256 private constant tokensPerShare = 1000000000;       // Tokens Needed Per Share (need to include 9 decimal digits)

    // Decided not to make these adjustable due to re-basing issues...just use smaller packages if the price gets too high
    mapping(uint256 => uint256) private multiplierList;         // This list of multipliers per tier...
    //      Tier ID     Multiplier (Factor) --> 5 = 5X multiplier

    // These are adjustable over time...
    uint256 private earlyUnstakeTime = 3 days;                  // Configurable time before unstake has a penalty
    uint256 private earlyUnstakePenalty = 20;                   // Percent lost/burned on early unstake
    uint256 private oldAfterTime = 30 days;                     // Configurable time before a distribution ages out and can't be collected (tokens burned)
    uint256 private stakingTransferFee = 0.1 ether;             // Configurable cost of transferring wallets (to keep staking lockups)
    uint256 private claimRewardAmount = 100000000000;           // Configurable token amount for rewards (starts at 100 VSL tokens)

    uint256 private totalTokensDistributed;                     // Tokens EVER Distributed (summary kept up to date for easy reference)
    uint256 private totalTokensUncollected;                     // Tokens Currently Uncollected - In Distributions (summary kept up to date for easy reference)
    uint256 private totalTokensPenalized;                       // Summary kept up to date for easy reference...
    uint256 private totalTokensStaked;                          // Summary kept up to date for easy reference...
    uint256 private totalSharesInStaking;                       // Summary kept up to date for easy reference...
    uint256 private currentStakerCount;                         // Running total of the wallets in staking currently

    struct Distribution
    {
        uint256 timeDistributed;        // Used to compare collections...the collection had to exist prior to the distribution
        uint256 originalDistribution;   // Initial Amount of tokens in this distribution...needed?
        uint256 amountRemaining;        // Every successful collection lowers the remaining amount
        uint256 tokensPerShare;         // Used when collecting the distribution...uses totalSharesAtTime
    }
    mapping(uint256 => Distribution) private distributionList;  // The various distributions for as long as they exist
    uint256 private numDistributions;                           // Starts at 0, first distribution is 1
    uint256 private startingDistribution = 1;                   // Starts at first possible distribution (then moves as they are used up)

    struct Staker
    {
        address wallet;                 // Wallet = User ID for this staking pool
        uint256 firstChange;            // Points to the beginning of the list of changes to their account
        uint256 lastChange;             // Points to the end of the list of changes to their account
        uint256 lockupCount;            // Number of locks they have active at this time (acts as ID of lockup list as well)
        uint256 penaltyCount;           // Number of penalties they have active at this time (acts as ID of penalty list as well)
        uint256 bonusShares;            // Current bonus shares (before tier multiplication)
        uint256 currentTier;            // Used to multiply the final shares
        uint256 tokensCollected;        // Amount ever collected to date
        uint256 tokensLocked;           // Tokens currently locked up
        uint256 tokensStaked;           // Tokens in staking contract in general
        uint256 lastDistributionID;     // Track the last collected distribution
        uint256 lastCollectedOn;        // date of the last collect process run
    }

    mapping(uint256 => Staker) private stakerList;                  // ID to Staker Data
    mapping(address => uint256) private walletList;                     // Address to Wallet
    uint256 private numStakers;                                         // Starts at 0, first staker/wallet is 1

    struct Change
    {
        uint256 timeofChange;           // Needed to determine whether it was before a distribution or not
        uint256 totalShares;            // Number of tokens that were staked at this time
    }

    mapping(uint256 => mapping(uint256 => Change)) private listOfChanges; // The list of changes per wallet/staker
    //      stakerID           changeID    actual change record

    struct Penalty
    {
        uint256 tokenAmount;            // Number of tokens waiting before unstake penalty
        uint256 noPenaltyAfter;         // Block/Time this penalty period expires
    }

    mapping(uint256 => mapping(uint256 => Penalty)) private listOfPenalties; // The list of penalties per wallet/staker
    //      stakerID           penaltyID    actual penalty record

    struct Lockup
    {
        uint256 packageID;              // The package used to lock up their stake
        uint256 unlockTime;             // Block/Time this lock can be unlocked
    }

    mapping(uint256 => mapping(uint256 => Lockup)) private listOfLockups; // The list of lockups per wallet/staker
    //      stakerID           lockupID    actual lockup record

    bool allowAllUnlock;                // Used to flag that anyone can unlock all locks (needed for migration)

    struct Package
    {
        uint256 startAfter;             // Block/Time this package becomes available (0 = start immediately)
        uint256 endAfter;               // Block/Time this package can no longer be selected (0 = does not end)
        uint256 amountToLock;           // Number of Tokens the package will lock up
        uint256 lockPeriod;             // Number of days the lock will be active for when used
        uint16 minTier;                 // Must be a certain tier to participate in this bonus package (0 = available to all)
        uint32 minPackages;             // Must own a certain number of packages (0 = available to all)
        uint64 maxLocks;                // Maximum times this package can be used in a lock (0 = unlimited)
        uint128 lockCount;              // If it has been used in a Lock this tracks by how many users...we can't change anything other than dates if != 0
        uint256 bonusShares;            // Number of bonus shares granted for locking in this package (can be multiplied)
        uint256 dbID;                   // Needed to handshake to the DB
    }

    mapping(uint256 => Package) private packageList;
    uint256 private packageCount;                       // Starts at 0, first package is ID = 1

    event Staked(address indexed wallet, uint256 tokens);
    event Locked(address indexed wallet, uint256 packageID);
    event UnLocked(address indexed wallet, uint256 packageID);
    event Unstaked(address indexed wallet, uint256 tokens);
    event Collected(uint256 indexed dbID, uint256 limitOnDistributions);
    event CollectedByWallet(address indexed wallet, uint256 limitOnDistributions);
    event Distributed(uint256 indexed distributionID, uint256 totalTokens, uint256 tokensPerShare, uint256 totalShares);
    event PackageUpdated(uint256 indexed packageID, uint256 indexed dbID);
    event ChangeReceived(uint256 indexed dbID);
    event StakingTransferred(address indexed from, address indexed to);
    event ConsolidateAndBurn(uint256 tokens);

    error InvalidParameter(uint8 parameter);
    error UnknownPackage();
    error MissingTokenContract();
    error NoShareHolders();
    error NoPackagesAvailable();
    error NoTokensAvailable();
    error BalanceLow();
    error InvalidStaker();
    error AlreadyHasPackage();
    error MissingPackage();
    error PackageCriteriaMissing(uint8 which);
    error UnlockingTooEarly();

    constructor() payable
    {
        // Set up the initial multipliers for owners of Vetter...
        multiplierList[0] = 1;
        multiplierList[1] = 2;
        multiplierList[2] = 3;
        multiplierList[3] = 4;
        multiplierList[4] = 5;
        multiplierList[5] = 10;
        multiplierList[6] = 15;
        multiplierList[7] = 20;
    }

    // To receive ETH from uniswapV2Router when swapping
    receive() external payable {}

    // SECTION: Control Code for handling changes to everything

    // Called to set up a distribution for Collection
    // Emits event Distributed(uint256 totalTokens, uint256 tokensPerShare, uint256 totalShares);
    function DistributeStakingRewards(uint256 maxToProcess) external onlyAllowedContract
    {
        // Will need this to check the token balance to be distributed...
        if(_vslContract == address(0x0)) revert MissingTokenContract();

        // Can't distribute with no stakers...
        if(totalSharesInStaking == 0) revert NoShareHolders();

        // Calculate the number of tokens available to distribute [Cap at Up To: (Contract Balance - Staked - Uncollected - Penalized)]
        // Use the contract address to check for the current total tokens on the contract
        uint256 toDistribute = GetTokensToDistribute();
        if(maxToProcess != 0 && toDistribute > maxToProcess) toDistribute = maxToProcess;

        // Make sure there were tokens (and the variable passed was not 0)
        if(toDistribute == 0) revert NoTokensAvailable();

        // Calculate the tokens per share value (and remember for later)
        uint256 tps = toDistribute / totalSharesInStaking;

        // Deal with rounding errors by limiting to the correct number here...
        toDistribute = tps * totalSharesInStaking;

        // Create a Distribution
        _newDistribution(toDistribute, tps);
    }

    // Function used to burn any uncollected tokens that have been distributed...
    // startAt can be 0 to process from the start or a higher ID to process a batch
    // maxToProcess can be any ID lower than the end of the distribution list
    // Note: The distribution list will shrink as this processes
    function ConsolidateAndBurnDistributions(uint256 startAt, uint256 maxToProcess) external onlyAllowedContract
    {
        // Will need this to check the token balance to be distributed...
        if(_vslContract == address(0x0)) revert MissingTokenContract();

        // If 0 was passed in or an ID lower than the beginning of the list, then we start at the beginning of the list
        // Otherwise we try to start at the desired ID
        uint256 current = (startAt == 0 || startAt < startingDistribution) ? startingDistribution : startAt;
        uint256 endAt = (maxToProcess > numDistributions) ? numDistributions : maxToProcess;

        // Prep a variable for what time before which a timeDistributed has to be to be considered old
        uint256 pastTime = getTime() - oldAfterTime;

        uint256 tokensToBurn;
        while(current <= endAt)
        {
            // Check whether the Distribution is past the cut off period and there are tokens left
            if(distributionList[current].amountRemaining != 0 && distributionList[current].timeDistributed < pastTime)
            {
                // Add to burn total and adjust all other variables as needed
                tokensToBurn += distributionList[current].amountRemaining;
                distributionList[current].amountRemaining = 0;
            }
            current++;
        }
        if(tokensToBurn != 0)
        {
            totalTokensUncollected -= tokensToBurn;
            // Burn them, but make sure we don't try to burn more than we have some how...
            uint256 amount = IERC20(_vslContract).balanceOf(address(this));
            if(tokensToBurn > amount) tokensToBurn = amount;
            if(tokensToBurn != 0)
            {
                IERC20(_vslContract).transfer(DEAD_ADDRESS, tokensToBurn);
                emit ConsolidateAndBurn(tokensToBurn);
            }
        }

        // Move the pointer past any cleaned out distributions
        // Note: We can't do this above since the burn may be in the middle of the list for some reason...
        _bumpStartingDistribution();
    }

    function GetNumberOfBurnableDistributions() external view onlyAllowedContract returns(uint256 numberToBurn, uint256 tokensToBurn)
    {
        // Start at the beginning...
        uint256 current = startingDistribution;

        // Prep a variable for what time before which a timeDistributed has to be to be considered old
        uint256 pastTime = getTime() - oldAfterTime;
        while(current <= numDistributions)
        {
            // Check whether the Distribution is past the cut off period and there are tokens left
            if(distributionList[current].amountRemaining != 0 && distributionList[current].timeDistributed < pastTime)
            {
                // Add to burn total
                numberToBurn++;
                tokensToBurn += distributionList[current].amountRemaining;
            }
            current++;
        }
    }

    // Called to add tokens into the staking contract for a wallet
    // Note: They need to already Approve this contract from the UI side before this is called...
    //      - Approve THIS contract address to stake the number of tokens they are transferring
    function StakeTokens(uint256 _numTokens) external
    {
        // Will need this to check the token balance to be staked...
        if(_vslContract == address(0x0)) revert MissingTokenContract();
        // Will need this to check the tier of Vetter for the wallet
        if(_vetterContract == address(0x0)) revert MissingTokenContract();

        // Make sure they have that many tokens in their wallet to move to the contract
        address _wallet = _msgSender();
        if(IERC20(_vslContract).balanceOf(_wallet) < _numTokens) revert BalanceLow();

        // Determine the number of tokens we are holding before this transfer...
        // Note: People may have sent right to us...we do not want to include those and give the tokens away
        uint256 contractStart = IERC20(_vslContract).balanceOf(address(this));

        // We need to transfer the tokens to this contract to stake...
        // They need to already Approve this from the UI side before this is called...
        //      - Approve THIS contract address to stake the number of tokens they are transferring
        IERC20(_vslContract).transferFrom(_wallet, address(this), _numTokens);

        // Now getting the balance after the transfer tells us how many tokens to stake (what is left after any tax, etc.)
        // This takes a bit of extra gas, but better to verify the tokens were received and it was the correct amount
        uint256 contractEnd = IERC20(_vslContract).balanceOf(address(this));
        uint256 numTokens = contractEnd - contractStart;
        if(numTokens == 0) revert NoTokensAvailable();

        // See if the wallet is already a staker or not (If not - Make a Staker entry to track them)
        // The wallet tier is needed for a new staker as well as later calculations
        uint256 _currentTier = _vetterToken._getWalletTier(_wallet);
        uint256 stakerID = _addOrFindStaker(_wallet, _currentTier);

        // Update main currentStakerCount once they actually complete the stake...
        // IF this is a new user or if they ever unstake all, then we add them now to the count
        if(stakerList[stakerID].tokensStaked == 0) currentStakerCount++;

        // Compute the beginning totals we need to compute the differences later...
        uint256 stakerTotalSharesBefore = (stakerList[stakerID].lastChange != 0) ? listOfChanges[stakerID][stakerList[stakerID].lastChange].totalShares : 0;

        // Update [Staked Tokens, Tier] on Staker
        stakerList[stakerID].tokensStaked += numTokens;
        stakerList[stakerID].currentTier = _currentTier;

        // Now Compute the difference in totals we need to update the contract...
        uint256 stakerTotalSharesAfter =
            (
                (stakerList[stakerID].tokensStaked / tokensPerShare)
                + stakerList[stakerID].bonusShares
            )
            * multiplierList[_currentTier];

        // Update [Total Tokens Staked, Total Shares] on main contract
        // Also...create the Unstake Penalty and Tier Change for the staker if needed
        totalTokensStaked += numTokens;
        _cleanPenalties(stakerID);
        _addPenalty(stakerID, numTokens);

        // Main: Shares
        if(stakerTotalSharesAfter > stakerTotalSharesBefore)
        {
            totalSharesInStaking += (stakerTotalSharesAfter - stakerTotalSharesBefore);
            _addChange(stakerID, stakerTotalSharesAfter);
        }
        else if(stakerTotalSharesAfter < stakerTotalSharesBefore)
        {
            totalSharesInStaking -= (stakerTotalSharesBefore - stakerTotalSharesAfter);
            _addChange(stakerID, stakerTotalSharesAfter);
        }

        // Let's auto stake any collectible tokens as well
        if(_collectByWallet(stakerID,_currentTier,0) != 0) emit CollectedByWallet(_wallet, 0);

        // Let the listener(s) know it happened...
        emit Staked(_wallet, _numTokens);
    }

    // Called to add staked tokens into a package to lock them up
    function LockTokens(uint256 _packageID) external
    {
        // Will need this to check the tier of Vetter for the wallet
        if(_vetterContract == address(0x0)) revert MissingTokenContract();

        // We have to have packages to begin with...
        if(packageCount == 0) revert NoPackagesAvailable();

        // And we have to be sure the package exists...
        if(_packageID < 1 || _packageID > packageCount) revert InvalidParameter(1);

        // Make sure we have a staker calling the function...
        address _wallet = _msgSender();
        uint256 ID = walletList[_wallet];
        if(ID == 0) revert InvalidStaker();

        // Make sure they do not already have this package...
        if(HasPackage(_wallet, _packageID)) revert AlreadyHasPackage();

        // Validate this package is accessible to this user and has not been used yet by them
        uint256 curTime = getTime();
        if(packageList[_packageID].startAfter != 0 && curTime < packageList[_packageID].startAfter) revert PackageCriteriaMissing(1);
        if(packageList[_packageID].endAfter != 0 && curTime > packageList[_packageID].endAfter) revert PackageCriteriaMissing(2);
        if(stakerList[ID].currentTier < packageList[_packageID].minTier) revert PackageCriteriaMissing(3);
        if(stakerList[ID].lockupCount < packageList[_packageID].minPackages) revert PackageCriteriaMissing(4);
        if(packageList[_packageID].maxLocks != 0 && packageList[_packageID].lockCount >= packageList[_packageID].maxLocks) revert PackageCriteriaMissing(5);

        // Get any collectible tokens first...
        uint256 _currentTier = _vetterToken._getWalletTier(_wallet);
        if(_collectByWallet(ID,_currentTier,0) != 0) emit CollectedByWallet(_wallet, 0);

        // Make sure they can stake the number of tokens requested for that package
        // If Available < Needed then we have an issue
        if((stakerList[ID].tokensStaked - stakerList[ID].tokensLocked) < packageList[_packageID].amountToLock)
            revert PackageCriteriaMissing(6);

        // Everything seems to check out...so now we can proceed with setting it up...

        // Compute the beginning totals we need to compute the differences later...
        uint256 stakerTotalSharesBefore = listOfChanges[ID][stakerList[ID].lastChange].totalShares;

        // Perform the actual creation of the lock for this user
        _addLockup(ID, _packageID);
        packageList[_packageID].lockCount++; // Mark the package reference counter (lockCount) so we know it is in use

        // Update state variables as needed...
        // Staker: Shares, Locked Tokens
        stakerList[ID].tokensLocked += packageList[_packageID].amountToLock;
        stakerList[ID].bonusShares += packageList[_packageID].bonusShares;
        stakerList[ID].currentTier = _currentTier;

        // Now Compute the difference in totals we need to update the contract...
        uint256 stakerTotalSharesAfter =
            (
                (stakerList[ID].tokensStaked / tokensPerShare)
                + stakerList[ID].bonusShares
            )
            * multiplierList[_currentTier];

        // Main: Shares
        if(stakerTotalSharesAfter > stakerTotalSharesBefore)
        {
            totalSharesInStaking += (stakerTotalSharesAfter - stakerTotalSharesBefore);
            _addChange(ID, stakerTotalSharesAfter);
        }
        else if(stakerTotalSharesAfter < stakerTotalSharesBefore)
        {
            totalSharesInStaking -= (stakerTotalSharesBefore - stakerTotalSharesAfter);
            _addChange(ID, stakerTotalSharesAfter);
        }
        _cleanPenalties(ID);

        // Let the listener(s) know it happened...
        emit Locked(_wallet, _packageID);
    }

    // Called to unlock tokens from a package and back into staking
    // Emits event UnLocked(address indexed wallet, uint256 packageID);
    function UnlockTokens(uint256 _packageID) external
    {
        // Will need this to check the tier of Vetter for the wallet
        if(_vetterContract == address(0x0)) revert MissingTokenContract();

        // We have to be sure the package exists...
        if(_packageID < 1 || _packageID > packageCount) revert InvalidParameter(1);

        // Make sure this user actually has the package selected
        address _wallet = _msgSender();
        uint256 ID = walletList[_wallet];
        if(ID == 0) revert InvalidStaker();
        uint256 curLock = _getLockup(ID, _packageID);
        if(curLock == 0) revert MissingPackage();

        // Make sure the locking period is over and they are able to unlock
        if(!allowAllUnlock && (listOfLockups[ID][curLock].unlockTime < getTime())) revert UnlockingTooEarly();

        // Everything seems to check out...so now we can proceed with setting it up...

        // See if they have a collection first though...
        uint256 _currentTier = _vetterToken._getWalletTier(_wallet);
        if(_collectByWallet(ID,_currentTier,0) != 0) emit CollectedByWallet(_wallet, 0);

        // Compute the beginning totals we need to compute the differences later...
        uint256 stakerTotalSharesBefore = listOfChanges[ID][stakerList[ID].lastChange].totalShares;

        // Perform the actual removal of the lock for this user
        _removeLockup(ID, curLock);

        packageList[_packageID].lockCount--; // Remove one from the reference counter to signal this user is done with this package

        // Update state variables as needed...
        // Staker: Shares, Locked Tokens, Tier
        stakerList[ID].tokensLocked -= packageList[_packageID].amountToLock;
        stakerList[ID].bonusShares -= packageList[_packageID].bonusShares;
        stakerList[ID].currentTier = _currentTier;

        // Now Compute the difference in totals we need to update the contract...
        uint256 stakerTotalSharesAfter =
            (
                (stakerList[ID].tokensStaked / tokensPerShare)
                + stakerList[ID].bonusShares
            )
            * multiplierList[_currentTier];

        // Main: Shares
        if(stakerTotalSharesAfter > stakerTotalSharesBefore)
        {
            totalSharesInStaking += (stakerTotalSharesAfter - stakerTotalSharesBefore);
            _addChange(ID, stakerTotalSharesAfter);
        }
        else if(stakerTotalSharesAfter < stakerTotalSharesBefore)
        {
            totalSharesInStaking -= (stakerTotalSharesBefore - stakerTotalSharesAfter);
            _addChange(ID, stakerTotalSharesAfter);
        }
        _cleanPenalties(ID);

        // Let the listener(s) know it happened...
        emit UnLocked(_wallet, _packageID);
    }

    // Called to unstake tokens from the staking contract
    function UnstakeTokens(uint256 _numTokens, bool _okToTakePenalty) external
    {
        // Fail early if this is missing...costs less gas
        if(_vslContract == address(0x0)) revert MissingTokenContract();
        // Will need this to check the tier of Vetter for the wallet
        if(_vetterContract == address(0x0)) revert MissingTokenContract();

        address _wallet = _msgSender();
        uint256 ID = walletList[_wallet];
        if(ID == 0) revert InvalidStaker(); // Means they are not actually a staker so nothing to do...

        // Collect first to know what is available...
        uint256 _currentTier = _vetterToken._getWalletTier(_wallet);
        if(_collectByWallet(ID,_currentTier,0) != 0) emit CollectedByWallet(_wallet, 0);

        // Compute the beginning totals we need to compute the differences later...
        uint256 stakerTotalSharesBefore = listOfChanges[ID][stakerList[ID].lastChange].totalShares;

        // This is the total they can technically unstake...
        uint256 available = stakerList[ID].tokensStaked - stakerList[ID].tokensLocked;

        // This amount OF it would be at a penalty however
        uint256 penaltyCount = GetPenaltyTokens(_wallet);

        // Verify they can unstake as many as requested...based upon how many are in penalty or not
        uint256 numToDraw = (_numTokens > available) ? available : _numTokens;
        // We have to penalize their token draw...
        uint256 numPenalty;
        if(!_okToTakePenalty)
        {
            // Handle if there are none available
            if(penaltyCount > available) numToDraw = 0;
            // Hanlde reducing the amount we are pulling down to just what is available (if any)
            else if(numToDraw > (available - penaltyCount)) numToDraw = available - penaltyCount;
        }
        else
        {
            // otherwise we will handle drawing down penalized tokens later
            if(penaltyCount > available) numPenalty = available;
            else if(numToDraw > (available - penaltyCount)) numPenalty = numToDraw - (available - penaltyCount);
        }

        if(numToDraw != 0)
        {
            // Remove the tokens from the staker
            stakerList[ID].tokensStaked -= numToDraw;
            stakerList[ID].currentTier = _currentTier;

            // Update main currentStakerCount once they actually complete the unstake...
            // IF they unstaked all, then we remove them now from the count
            if(stakerList[ID].tokensStaked == 0) currentStakerCount--;

            // Let the listener(s) know it happened...
            emit Unstaked(_wallet, numToDraw);

            // Are they taking more than what was vested already...
            if(numPenalty != 0)
            {
                uint256 penaltyTokens = CalcEarlyUnstakePenalty(numPenalty);
                totalTokensPenalized += penaltyTokens;
                numToDraw -= penaltyTokens;

                // Kill the penalty objects as needed to resolve the first in first out...
                uint256 oldestID = _oldestPenalty(ID);
                while(oldestID != 0 && numPenalty != 0)
                {
                    if(listOfPenalties[ID][oldestID].tokenAmount >= numPenalty)
                    {
                        listOfPenalties[ID][oldestID].tokenAmount -= numPenalty;
                        numPenalty = 0;
                    }
                    else
                    {
                        numPenalty -= listOfPenalties[ID][oldestID].tokenAmount;
                        listOfPenalties[ID][oldestID].tokenAmount = 0;
                        oldestID = _oldestPenalty(ID);
                    }
                }
                _cleanPenalties(ID);
            }

            // Now Compute the difference in totals we need to update the contract...
            uint256 stakerTotalSharesAfter =
                (
                    (stakerList[ID].tokensStaked / tokensPerShare)
                    + stakerList[ID].bonusShares
                )
                * multiplierList[_currentTier];

            // Main: Shares
            if(stakerTotalSharesAfter > stakerTotalSharesBefore)
            {
                totalSharesInStaking += (stakerTotalSharesAfter - stakerTotalSharesBefore);
                _addChange(ID, stakerTotalSharesAfter);
            }
            else if(stakerTotalSharesAfter < stakerTotalSharesBefore)
            {
                totalSharesInStaking -= (stakerTotalSharesBefore - stakerTotalSharesAfter);
                _addChange(ID, stakerTotalSharesAfter);
            }

            // Now send their non-penalized tokens to their wallet...
            if(numToDraw != 0)
            {
                IERC20(_vslContract).transfer(_wallet, numToDraw);
                totalTokensStaked -= numToDraw;
            }
        }
        else revert NoTokensAvailable();
    }

    // Called to collect tokens for a range of wallets
    // Note:    isRandom = true, we deal with payout
    //          isRandom = false, we do not deal with payout
    // DB will come and walk the wallet list to update to new collected tokens amount (newTotal - oldTotal = collectedAmount)
    // Note: _limitDistributions can be 0 to pull them all...or a number to lower the amount of dist per wallet to process
    function CollectTokens(uint256 dbID, address[] memory wallets, bool isRandom, uint256 _limitDistributions) external
    {
        // Will need this to check the tier of Vetter for the wallet
        if(_vetterContract == address(0x0)) revert MissingTokenContract();

        // Step through the list of wallets to process each one
        uint256 processed;
        uint256 stakerID;
        uint256 numWallets = wallets.length;
        for(uint256 i = 0; i < numWallets; i++)
        {
            stakerID = walletList[wallets[i]];
            uint256 _currentTier = _vetterToken._getWalletTier(wallets[i]);
            if(stakerID != 0 && _collectByWallet(stakerID, _currentTier, _limitDistributions) != 0)
            {
                processed++;
                _cleanPenalties(stakerID);
            }
        }

        // Process the payout to the caller (if needed)
        if(isRandom && processed != 0 && totalTokensPenalized > claimRewardAmount)
        {
            uint256 factor = 100;
            uint256 rand = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, factor)));
            if((rand % factor) > 30) // 70 % chance of payout...
            {
                // Will need this to check the token balance to pay out...
                if(_vslContract == address(0x0)) revert MissingTokenContract();
                address _wallet = _msgSender();
                IERC20(_vslContract).transfer(_wallet, claimRewardAmount);
                totalTokensPenalized -= claimRewardAmount;
            }
        }
        emit Collected(dbID, _limitDistributions);
    }

    // Called to collect tokens for a specific wallet
    // Note: _limitDistributions can be 0 to pull them all...or a number to lower the amount of dist per wallet to process
    function CollectByWallet(uint256 _limitDistributions) external
    {
        // Will need this to check the tier of Vetter for the wallet
        if(_vetterContract == address(0x0)) revert MissingTokenContract();

        address _wallet = _msgSender();
        uint256 stakerID = walletList[_wallet];
        if(stakerID != 0)
        {
            // Simply call for the current user only...and let the listener(s) know it happened...
            uint256 _currentTier = _vetterToken._getWalletTier(_wallet);
            if(_collectByWallet(stakerID, _currentTier, _limitDistributions) != 0) emit CollectedByWallet(_wallet, _limitDistributions);
            _cleanPenalties(stakerID);
        }
    }

    // This is called externally by a tier change checker on the event listener
    // It should only be called when the tier actually changes, but we will verify in case it is called again for some reason
    // This WILL do nothing if they are not already a staker as we do not want to just add everyone to the staking contract who isn't in it
    // forceIt = use to make sure we get a change event (sel-healing = change multiplier or something)
    function CheckTierChange(address _wallet, uint256 _dbID, bool forceIt) external onlyAllowedContract
    {
        // Will need this to check the tier of Vetter for the wallet
        if(_vetterContract == address(0x0)) revert MissingTokenContract();

        // Verify they are actually a staker before we continue (or fail silently)
        uint256 stakerID = walletList[_wallet];
        if(stakerID == 0) return;

        // Verify the tier is actually different (or fail silently)
        uint256 _currentTier = _vetterToken._getWalletTier(_wallet);
        if(!forceIt && stakerList[stakerID].currentTier == _currentTier)
        {
            emit ChangeReceived(_dbID);
            return;
        }

        // Compute the beginning totals we need to compute the differences later...
        uint256 stakerTotalSharesBefore = listOfChanges[stakerID][stakerList[stakerID].lastChange].totalShares;

        // Update Tier on Staker
        stakerList[stakerID].currentTier = _currentTier;

        // Now Compute the difference in totals we need to update the contract...
        uint256 stakerTotalSharesAfter =
            (
                (stakerList[stakerID].tokensStaked / tokensPerShare)
                + stakerList[stakerID].bonusShares
            )
            * multiplierList[_currentTier];

        // Main: Shares
        if(stakerTotalSharesAfter > stakerTotalSharesBefore)
        {
            totalSharesInStaking += (stakerTotalSharesAfter - stakerTotalSharesBefore);
        }
        else if(stakerTotalSharesAfter < stakerTotalSharesBefore)
        {
            totalSharesInStaking -= (stakerTotalSharesBefore - stakerTotalSharesAfter);
        }

        // We made a change...so update or add a change as of this point in time
        _addChange(stakerID, stakerTotalSharesAfter);

        emit ChangeReceived(_dbID);
    }

    // SECTION: Transfer Functionality

    // Can be called for anyone after a fee for admin, etc. has been collected...
    function InternalTransfer(address _from, address _to) external onlyAllowedContract
    {
        _performTransfer(_from, _to);
        emit StakingTransferred(_from, _to);
    }

    // Can be called externally by anyone for a fee...
    function TransferStaking(address _to) external payable
    {
        if(msg.value < stakingTransferFee) revert BalanceLow(); // make sure they sent the money in to do this
        address _wallet = _msgSender();
        _performTransfer(_wallet, _to);
        emit StakingTransferred(_wallet, _to);
    }

    // Replace the address variables where _from shows up with _to address and correct the links/pointers
    function _performTransfer(address _from, address _to) internal
    {
        // Will need this to check the tier of Vetter for the wallet
        if(_vetterContract == address(0x0)) revert MissingTokenContract();

        if(_to == _from) revert InvalidParameter(1); // The addresses must be different
        if(_to == address(0x0)) revert InvalidParameter(2); // We can't burn a stake, they have to unstake and do that manually
        uint256 fromID = walletList[_from];
        if(fromID == 0) revert InvalidParameter(1); // The address from must exist already...
        uint256 toID = walletList[_to];
        if(toID != 0) revert InvalidParameter(2); // The address to can not already have staking...

        // Compute the beginning totals we need to compute the differences later...
        uint256 stakerTotalSharesBefore = listOfChanges[fromID][stakerList[fromID].lastChange].totalShares;

        stakerList[fromID].wallet = _to;
        walletList[_from] = 0;
        walletList[_to] = fromID;

        // Update Tier on Staker
        uint256 _currentTier = _vetterToken._getWalletTier(_to);
        stakerList[fromID].currentTier = _currentTier;

        // Now Compute the difference in totals we need to update the contract...
        uint256 stakerTotalSharesAfter =
            (
                (stakerList[fromID].tokensStaked / tokensPerShare)
                + stakerList[fromID].bonusShares
            )
            * multiplierList[_currentTier];

        // Main: Shares
        if(stakerTotalSharesAfter > stakerTotalSharesBefore)
        {
            totalSharesInStaking += (stakerTotalSharesAfter - stakerTotalSharesBefore);
        }
        else if(stakerTotalSharesAfter < stakerTotalSharesBefore)
        {
            totalSharesInStaking -= (stakerTotalSharesBefore - stakerTotalSharesAfter);
        }

        // We made a change...so update or add a change as of this point in time
        _addChange(fromID, stakerTotalSharesAfter);
    }

    // SECTION: Distribution Functionality

    // Add a distribution to the list
    function _newDistribution(uint256 _originalDistribution, uint256 _tokensPerShare) internal
    {
        // Add it to the Distribution List
        numDistributions += 1;
        distributionList[numDistributions].timeDistributed = getTime();
        distributionList[numDistributions].originalDistribution = _originalDistribution;
        distributionList[numDistributions].amountRemaining = _originalDistribution;
        distributionList[numDistributions].tokensPerShare = _tokensPerShare;

        // Update Tokens Distributed and Uncollected Tokens...
        // Make sure main contract stays up to date as a distribution is made
        totalTokensDistributed += _originalDistribution;
        totalTokensUncollected += _originalDistribution;

        emit Distributed(numDistributions, _originalDistribution, _tokensPerShare, totalSharesInStaking);
    }

    // Used to bump the starting pointer up if needed as distributions are collected or cleaned/burned
    // We are not actually deleting the distributions...so this will stop working once max uint256 is reached
    function _bumpStartingDistribution() internal
    {
        while(startingDistribution <= numDistributions)
        {
            if(distributionList[startingDistribution].amountRemaining != 0) break;
            startingDistribution++;
        }
    }

    // The ending point of the list of distributions
    // Also: The total number of distributions ever made
    function GetLastDistribution() view external returns(uint256)
    {
        return numDistributions;
    }

    // The starting point into the list of distributions
    function GetFirstDistribution() view external returns(uint256)
    {
        return startingDistribution;
    }

    // How many uncollected distributions remain
    function GetRemainingDistributions() view external returns(uint256)
    {
        if(startingDistribution > numDistributions) return 0;
        return (numDistributions - startingDistribution) + 1;
    }

    // Look at a specific distribution's details
    function GetDistribution(uint256 _distributionID) view external returns(Distribution memory)
    {
        return distributionList[_distributionID];
    }

    // Get Last Time a Distribution was Created
    function GetLastDistributionTime() view external returns(uint256 last)
    {
        last = distributionList[numDistributions].timeDistributed;
    }

    // SECTION: Staker Functionality

    // The total number of stakers ever staked
    function GetStakerCount() view external returns(uint256)
    {
        return numStakers;
    }

    // The ID for the wallet who has staked...
    function GetStakerID(address wallet) view external returns(uint256)
    {
        return walletList[wallet];
    }

    // The wallet for the ID who has staked...
    function GetStakerWallet(uint256 _stakerID) view external returns(address wallet)
    {
        return stakerList[_stakerID].wallet;
    }

    // The full Staker record for the wallet who has staked...
    function GetStakerByWallet(address wallet) view external returns(Staker memory)
    {
        return stakerList[walletList[wallet]];
    }

    // The full Staker record for the ID who has staked...
    function GetStakerByID(uint256 _stakerID) view external returns(Staker memory)
    {
        return stakerList[_stakerID];
    }

    // Called internally to create or find an existing staker record
    // If the wallet has a staker record already created, it will return it's ID
    // If not, then a blank staker record is set up for this wallet to use
    function _addOrFindStaker(address _wallet, uint256 _tier) internal returns(uint256)
    {
        // Find existing staker record if it exists...
        if(walletList[_wallet] != 0) return walletList[_wallet];

        // Otherwise we add a new one into the lists
        numStakers++;
        walletList[_wallet] = numStakers; // Needed to find this wallet later without running the list
        stakerList[numStakers] = Staker(_wallet,0,0,0,0,0,_tier,0,0,0,0,0); // Actual Staker List by ID

        // Note: We do not update main currentStakerCount until they actually complete the stake...
        return numStakers;
    }

    // Determine the Shares Details for a given wallet
    // total = final shares with bonuses and Vetter multiplier figured in
    // base = number of shares computed from the base staked token count and Per Share figures
    // bonus = sum of bonuses earned by lockups of this wallet's tokens
    // For reference, multiplier = the current tier of the wallet's multiple applied
    function GetShares(address _wallet) view external returns(uint256 total, uint256 base, uint256 bonus, uint256 multiplier)
    {
        uint256 ID = walletList[_wallet];
        if(ID != 0)
        {
            base = stakerList[ID].tokensStaked / tokensPerShare;
            bonus = stakerList[ID].bonusShares;
            multiplier = multiplierList[stakerList[ID].currentTier];
            total = (base + bonus) * multiplier;
        }
    }

    // Determine how many tokens are available for this wallet to collect
    // numTokens = number of tokens to return
    function GetCollectableTokens(address _wallet) view external returns(uint256 numTokens)
    {
        uint256 ID = walletList[_wallet];
        if(ID != 0)
        {
            uint256 dist = stakerList[ID].lastDistributionID + 1;
            if(dist < startingDistribution) dist = startingDistribution;

            // Step through the changes and see if there are future distributions we can collect from...
            // Note: This will not actually change the starting pointer to the changes like the collection function would
            uint256 earnedTokens;
            uint256 curChange = stakerList[ID].firstChange;
            uint256 nextChange = stakerList[ID].firstChange + 1;
            while(curChange <= stakerList[ID].lastChange && dist <= numDistributions)
            {
                // See if we have an older change and can move on to the next one...
                if(nextChange <= stakerList[ID].lastChange && listOfChanges[ID][nextChange].timeofChange < distributionList[dist].timeDistributed)
                {
                    curChange++;
                    nextChange++;
                }
                // See if the current change is before the next distribution...
                else if(listOfChanges[ID][curChange].timeofChange < distributionList[dist].timeDistributed)
                {
                    // See how many tokens they earned...
                    earnedTokens = distributionList[dist].tokensPerShare * listOfChanges[ID][curChange].totalShares;
                    if(earnedTokens > distributionList[numDistributions].amountRemaining) earnedTokens = distributionList[numDistributions].amountRemaining;
                    numTokens += earnedTokens;

                    dist++;
                }
                // Otherwise the distribution is before the current change so we can skip it...
                else dist++;
            }
        }
    }

    // Get the date/time of the last time this wallet has actually collected tokens
    // lastCollected = time of last collection
    function GetLastCollectedTime(address _wallet) view external returns(uint256 lastCollected)
    {
        uint256 ID = walletList[_wallet];
        if(ID != 0) lastCollected = stakerList[ID].lastCollectedOn;
    }

    // SECTION: Change Functionality

    // Called internally to perform the change creation
    // This will create a staker if one does not exist...so do not expect it to fail...ever
    function _addChange(uint256 _stakerID, uint256 _shares) internal returns(uint256 changeID)
    {
        // See if there are any changes at all first...
        if(stakerList[_stakerID].firstChange == 0)
        {
            // We start a new change in this case
            stakerList[_stakerID].lastChange = 1;
            stakerList[_stakerID].firstChange = 1;
            changeID = 1;
        }
        // See if the last change was after the last distribution
        else if(numDistributions == 0 || (numDistributions != 0 && (distributionList[numDistributions].timeDistributed < listOfChanges[_stakerID][stakerList[_stakerID].lastChange].timeofChange)))
        {
            // Just update the last one rather that adding a new one
            changeID = stakerList[_stakerID].lastChange;
        }
        else
        {
            // In this case...there has been another distribution since the last change, so we need to create a new change now
            stakerList[_stakerID].lastChange += 1;
            changeID = stakerList[_stakerID].lastChange;
        }
        listOfChanges[_stakerID][changeID].timeofChange = getTime();
        listOfChanges[_stakerID][changeID].totalShares = _shares;
    }

    // Called internally to perform the collect tokens action for a specific wallet
    // Will try to get ALL collections performed in one go...use CollectNextOnlyForWallet to
    //  get caught up if too much gas is needed for this
    function _collectByWallet(uint256 _stakerID, uint256 _currentTier, uint256 _limitDistributions) internal returns(uint256 numTokens)
    {
        // Will need this to check the tier of Vetter for the wallet
        if(_vetterContract == address(0x0)) revert MissingTokenContract();

        uint256 dist = stakerList[_stakerID].lastDistributionID + 1;
        if(dist < startingDistribution) dist = startingDistribution;

        // Compute the beginning totals we need to compute the differences later...
        uint256 stakerTotalSharesBefore = listOfChanges[_stakerID][stakerList[_stakerID].lastChange].totalShares;

        // Step through the changes and see if there are future distributions we can collect from...
        // Note: This will actually change the starting pointer to the changes (clean the list) as we go, until one is left
        uint256 earnedTokens;
        uint256 nextChange = stakerList[_stakerID].firstChange + 1;
        uint256 numFound;
        while(stakerList[_stakerID].firstChange <= stakerList[_stakerID].lastChange && dist <= numDistributions)
        {
            // See if we have an older change and can move on to the next one...
            if(nextChange <= stakerList[_stakerID].lastChange && listOfChanges[_stakerID][nextChange].timeofChange < distributionList[dist].timeDistributed)
            {
                stakerList[_stakerID].firstChange++;
                nextChange++;
            }
            // See if the current change is before the next distribution...
            else if(listOfChanges[_stakerID][stakerList[_stakerID].firstChange].timeofChange < distributionList[dist].timeDistributed)
            {
                // We collect this distribution...
                // See how many tokens they earned...
                earnedTokens = distributionList[dist].tokensPerShare * listOfChanges[_stakerID][stakerList[_stakerID].firstChange].totalShares;
                if(earnedTokens > distributionList[dist].amountRemaining) earnedTokens = distributionList[dist].amountRemaining;

                if(earnedTokens != 0)
                {
                    // Update the main contract figures as needed and track this earned amount
                    numTokens += earnedTokens;
                    distributionList[dist].amountRemaining -= earnedTokens;
                    numFound++;
                    if(_limitDistributions != 0 && numFound >= _limitDistributions) break;
                }

                dist++;
            }
            // Otherwise the distribution is before the first change so we can skip it...
            else
            {
                dist++;
            }
        }

        if(numTokens != 0)
        {
            // Actually move the tokens to the staker's balance...
            stakerList[_stakerID].tokensCollected += numTokens;
            stakerList[_stakerID].tokensStaked += numTokens;

            // Update Tier on Staker
            stakerList[_stakerID].currentTier = _currentTier;

            // Now Compute the difference in totals we need to update the contract...
            uint256 stakerTotalSharesAfter =
                (
                    (stakerList[_stakerID].tokensStaked / tokensPerShare)
                    + stakerList[_stakerID].bonusShares
                )
                * multiplierList[_currentTier];

            // Update [Total Tokens Staked, Total Shares] on main contract
            totalTokensStaked += numTokens;
            totalTokensUncollected -= numTokens;

            if(stakerTotalSharesAfter > stakerTotalSharesBefore)
            {
                totalSharesInStaking += (stakerTotalSharesAfter - stakerTotalSharesBefore);
                _addChange(_stakerID, stakerTotalSharesAfter);
            }
            else if(stakerTotalSharesAfter < stakerTotalSharesBefore)
            {
                totalSharesInStaking -= (stakerTotalSharesBefore - stakerTotalSharesAfter);
                _addChange(_stakerID, stakerTotalSharesAfter);
            }
        }

        // Update general collection details...
        stakerList[_stakerID].lastCollectedOn = getTime();
        stakerList[_stakerID].lastDistributionID = (dist <= numDistributions) ? dist : numDistributions;

        // Move the pointer past any cleaned out distributions
        _bumpStartingDistribution();
    }

    // SECTION: Lock Functionality

    // Check if a wallet already has a particular package locked...
    function HasPackage(address _wallet, uint256 _packageID) public view returns(bool)
    {
        uint256 ID = walletList[_wallet];
        if(ID != 0 && _getLockup(ID, _packageID) != 0) return true;
        return false;
    }

    // Get a particular package locked for a staker...
    function _getLockup(uint256 _stakerID, uint256 _packageID) internal view returns(uint256)
    {
        uint256 curLock = stakerList[_stakerID].lockupCount;
        while(curLock != 0)
        {
            // Return the ID of the specified lockup on this staker
            if(listOfLockups[_stakerID][curLock].packageID == _packageID) return curLock;
            curLock -= 1;
        }
        return 0;
    }

    // Called internally to perform the lockup creation
    // We are adding a new lock to the system for the specified staker (if they exist)
    function _addLockup(uint256 _stakerID, uint256 _packageID) internal
    {
        // This is an internal function and must already been established...
        //if(_stakerID == 0 || _stakerID > numStakers) revert InvalidStaker();

        stakerList[_stakerID].lockupCount += 1;
        uint256 lockID = stakerList[_stakerID].lockupCount;
        listOfLockups[_stakerID][lockID].packageID = _packageID;
        listOfLockups[_stakerID][lockID].unlockTime = getTime() + packageList[_packageID].lockPeriod;
    }

    // Get a particular package locked for a staker...
    function _removeLockup(uint256 _stakerID, uint256 _lockupID) internal
    {
        // This is an internal function and must already been established...
        //if(_stakerID == 0 || _stakerID > numStakers) revert InvalidStaker();
        //if(_lockupID == 0 || _lockupID > stakerList[_stakerID].lockupCount) revert InvalidStaker();

        if(_lockupID < stakerList[_stakerID].lockupCount)
        {
            // Move the last index to this spot
            // Do not need to if we are on the last one...we can just move the pointer only
            listOfLockups[_stakerID][_lockupID] = listOfLockups[_stakerID][stakerList[_stakerID].lockupCount];
        }
        stakerList[_stakerID].lockupCount -= 1;
    }

    // Get the count of lockups a staker has...
    function GetStakerLockupCount(address _wallet) external view returns(uint256 numLockups)
    {
        return stakerList[walletList[_wallet]].lockupCount;
    }

    // Get the details of a speific lockup a staker has...
    function GetStakerLockup(address _wallet, uint256 _lockupID) external view returns(Lockup memory)
    {
        return listOfLockups[walletList[_wallet]][_lockupID];
    }

    // SECTION: Penalty Functionality

    // Get Penalty Token count for a wallet...
    // We assume first in first out when we destroy penalties as people take those tokens out of the contract
    function GetPenaltyTokens(address _wallet) public view returns(uint256 numTokens)
    {
        uint256 ID = walletList[_wallet];
        if(ID != 0)
        {
            uint256 curPenalty = stakerList[ID].penaltyCount;
            uint256 curTime = getTime();
            while(curPenalty != 0)
            {
                // See if current time is still within the no Penalty After time...
                if(curTime <= listOfPenalties[ID][curPenalty].noPenaltyAfter)
                {
                    // We have to count this one...
                    numTokens += listOfPenalties[ID][curPenalty].tokenAmount;
                }
                curPenalty -= 1;
            }
        }
    }

    // Called internally to perform the penalty creation
    function _addPenalty(uint256 _stakerID, uint256 _numTokens) internal returns(uint256 penaltyID)
    {
        // This is an internal function and must already been established...
        //if(_stakerID == 0 || _stakerID > numStakers) revert InvalidStaker();

        // We are adding a new lock to the system
        stakerList[_stakerID].penaltyCount += 1;
        penaltyID = stakerList[_stakerID].penaltyCount;
        listOfPenalties[_stakerID][penaltyID].tokenAmount = _numTokens;
        listOfPenalties[_stakerID][penaltyID].noPenaltyAfter = getTime() + earlyUnstakeTime;
    }

    // Called internally to perform the penalty cleanup
    function _cleanPenalties(uint256 _stakerID) internal
    {
        // This is an internal function and must already been established...
        //if(_stakerID == 0 || _stakerID > numStakers) revert InvalidStaker();

        uint256 curPenalty = stakerList[_stakerID].penaltyCount;
        uint256 curTime = getTime();
        while(curPenalty != 0)
        {
            // See if current time is past the no Penalty After time...
            // Or the number of tokens has been reduced to zero from an unstake
            if(curTime > listOfPenalties[_stakerID][curPenalty].noPenaltyAfter || (listOfPenalties[_stakerID][curPenalty].tokenAmount == 0))
            {
                // We can get rid of this one...
                if(curPenalty < stakerList[_stakerID].penaltyCount)
                {
                    // Move the last index to this spot
                    // Do not need to if we are on the last one...we can just move the pointer only
                    listOfPenalties[_stakerID][curPenalty] = listOfPenalties[_stakerID][stakerList[_stakerID].penaltyCount];
                }
                stakerList[_stakerID].penaltyCount -= 1;
            }
            curPenalty -= 1;
        }
    }

    // Called internally to perform the penalty cleanup
    function _oldestPenalty(uint256 _stakerID) internal view returns(uint256 oldestID)
    {
        uint256 curPenalty = stakerList[_stakerID].penaltyCount;
        if(curPenalty == 0) return 0;

        uint256 curTime = getTime();
        uint256 oldestTime = 0;
        while(curPenalty != 0)
        {
            // See if current time is before the no Penalty After time...
            // And the number of tokens has been reduced to zero from an unstake
            if(curTime < listOfPenalties[_stakerID][curPenalty].noPenaltyAfter && (listOfPenalties[_stakerID][curPenalty].tokenAmount != 0))
            {
                // Found the first one...
                if(oldestTime == 0)
                {
                    oldestTime = listOfPenalties[_stakerID][curPenalty].noPenaltyAfter;
                    oldestID = curPenalty;
                }
                // See if this one is going to go away sooner...
                else if(listOfPenalties[_stakerID][curPenalty].noPenaltyAfter < oldestTime)
                {
                    oldestTime = listOfPenalties[_stakerID][curPenalty].noPenaltyAfter;
                    oldestID = curPenalty;
                }
            }
            curPenalty -= 1;
        }
        // At this point, oldestID is a pointer to the soonest to expire...
    }

    // Get the count of penalties a staker has...
    function GetStakerPenaltyCount(address _wallet) external view returns(uint256)
    {
        return stakerList[walletList[_wallet]].penaltyCount;
    }

    // Get the details of a speific penalty a staker has...
    function GetStakerPenalty(address _wallet, uint256 _penaltyID) external view returns(Penalty memory)
    {
        return listOfPenalties[walletList[_wallet]][_penaltyID];
    }

    // SECTION: Package Functionality

    // Add or Adjust a package in the list
    // Note: Pass ID of 0 to add a new package
    // Note: if adjusting and lockCount != 0...then all parameters other than dates will be ignored
    function AddOrAdjustPackage(
        uint256 _packageID,              // Which package to adjust
        uint256 _startAfter,             // Block/Time this package becomes available (0 = start immediately)
        uint256 _endAfter,               // Block/Time this package can no longer be selected (0 = does not end)
        uint256 _amountToLock,           // Number of Tokens the package will lock up
        uint256 _lockPeriod,             // Number of days the lock will be active for when used
        uint16 _minTier,                 // Must be a certain tier to participate in this bonus package (0 = available to all)
        uint32 _minPackages,             // Must own a certain number of packages (0 = available to all)
        uint64 _maxLocks,                // Maximum times this package can be used in a lock (0 = unlimited)
        uint256 _bonusShares,            // Number of bonus shares granted for locking in this package (can be multiplied)
        uint256 _dbID                    // To handshake later
    ) external onlyAllowedContract
    {
        if(_packageID > packageCount) revert UnknownPackage();

        if(_packageID == 0)
        {
            packageCount += 1;
            _packageID = packageCount;
        }
        packageList[_packageID].startAfter = _startAfter;
        packageList[_packageID].endAfter = _endAfter;

        if(packageList[_packageID].lockCount == 0)
        {
            if(_amountToLock == 0) revert InvalidParameter(4);
            if(_lockPeriod == 0) revert InvalidParameter(5);
            packageList[_packageID].amountToLock = _amountToLock;
            packageList[_packageID].lockPeriod = _lockPeriod;
            packageList[_packageID].minTier = _minTier;
            packageList[_packageID].minPackages = _minPackages;
            packageList[_packageID].bonusShares = _bonusShares;
            packageList[_packageID].maxLocks = _maxLocks;
            packageList[_packageID].dbID = _dbID;
        }
        emit PackageUpdated(_packageID, _dbID);
    }

    function GetPackageCount() view external returns(uint256)
    {
        return packageCount;
    }

    function GetPackage(uint256 _packageID) view external returns(Package memory)
    {
        return packageList[_packageID];
    }

    // SECTION: Contract Setup

    // Set up the pointer to the current token contract to use the reward function
    event VSLContractChange(address _contractAddress);
    function SetVSLContract(address _contractAddress) external onlyAllowedContract
    {
        _vslContract = _contractAddress;
        emit VSLContractChange(_contractAddress);
    }

    // Get the pointer to the current token contract to use the reward function
    function GetVSLContract() view external onlyAllowedContract returns(address _contractAddress)
    {
        _contractAddress = _vslContract;
    }

    // Set up the pointer to the current token contract to use the only Architect modifier
    event VetterContractChange(address _contractAddress);
    function SetVetterContract(address _contractAddress) external onlyAllowedContract
    {
        _vetterContract = _contractAddress;
        _vetterToken = VetterToken(_contractAddress);
        emit VetterContractChange(_contractAddress);
    }

    // Get the pointer to the current token contract to use the only Architect modifier
    function GetVetterContract() view external onlyAllowedContract returns(address _contractAddress)
    {
        _contractAddress = _vetterContract;
    }

    // SECTION: Allowed Caller List (Setup for DAO to control later)

    function GetAllowedID(address which) view external returns(uint256)
    {
        for(uint256 i = 1; i <= allowedCount; i++)
        {
            if(_allowedByID[i] == which) return i;
        }
        return 0;
    }

    event AllowedContractChange(address _contractAddress, bool _allowOrNot);
    function SetupAllowedContract(address _contractAddress, bool _allowOrNot) external onlyAllowedContract
    {
        _allowedContract[_contractAddress] = _allowOrNot;
        emit AllowedContractChange(_contractAddress, _allowOrNot);

        // Only add the address in if it is new...
        for(uint256 i = 1; i <= allowedCount; i++)
        {
            if(_allowedByID[i] == _contractAddress) return;
        }

        // Would have exited by now if it was used in the past...
        allowedCount++;
        _allowedByID[allowedCount] = _contractAddress;
    }

    function IsAddressInList(address which) view external returns(bool)
    {
        for(uint256 i = 1; i <= allowedCount; i++)
        {
            if(_allowedByID[i] == which) return true;
        }
        return false;
    }

    struct Allowed
    {
        address account;
        bool stillAllowed;
    }

    function GetAllAllowedAddresses() view external onlyOwner returns (Allowed [] memory)
    {
        Allowed[] memory entries = new Allowed[](allowedCount);
        uint256 elem = 0;
        for(uint256 i = 1; i <= allowedCount; i++)
        {
            entries[elem].account = _allowedByID[i];
            entries[elem].stillAllowed = _allowedContract[entries[elem].account];
            elem++;
        }
        return entries;
    }

    // SECTION: Multiplier Setup...

    // Get current multiplier for the specified tier
    function GetTierMultiplier(uint256 _tier) external view returns (uint256 multiplyBy)
    {
        multiplyBy = multiplierList[_tier];
    }

    // Set current multiplier for the specified tier
    event TierMultiplierSet(uint256 _tier, uint256 _multiplyBy);
    function SetTierMultiplier(uint256 _tier, uint256 _multiplyBy) external onlyAllowedContract
    {
        multiplierList[_tier] = _multiplyBy;
        emit TierMultiplierSet(_tier, _multiplyBy);
    }

    // SECTION: General Getters and Setters...

    // Getter for the Staking Transfer Fee
    function GetStakingTransferFee() external view returns (uint256)
    {
        return stakingTransferFee;
    }

    // Needed to adjust the fee...be sure to pass in the WEI amount (not 0.2 ether but the equivalent in ether/BNB)
    event StakingTransferFeeSet(uint256 _newTransferFee);
    function SetStakingTransferFee(uint256 _newTransferFee) external onlyAllowedContract
    {
        stakingTransferFee = _newTransferFee;
        emit StakingTransferFeeSet(_newTransferFee);
    }

    // Getter for the Penalty Reward Amount
    function GetClaimRewardAmount() external view returns (uint256)
    {
        return claimRewardAmount;
    }

    // Needed to adjust the reward amount...be sure to pass in the token amount (with the 9 digits)
    event ClaimRewardSet(uint256 _claimRewardAmount);
    function SetClaimRewardAmount(uint256 _claimRewardAmount) external onlyAllowedContract
    {
        claimRewardAmount = _claimRewardAmount;
        emit ClaimRewardSet(_claimRewardAmount);
    }

    // Needed to allow unlocking for migration purposes...
    function GetUnlockAllState() external view returns(bool allUnlocked)
    {
        allUnlocked = allowAllUnlock;
    }

    // Needed to allow unlocking for migration purposes...
    event UnlockAllSet(bool _allowUnlock);
    function SetUnlockAllFlag(bool _allowUnlock) external onlyAllowedContract
    {
        allowAllUnlock = _allowUnlock;
        emit UnlockAllSet(_allowUnlock);
    }

    // Uses the totalTokensUncollected and totalTokensStaked vs. contract balance
    // to determine the number of tokens available for the next distribution...
    function GetTokensToDistribute() public view returns (uint256)
    {
        if(_vslContract == address(0x0)) revert MissingTokenContract();
        return IERC20(_vslContract).balanceOf(address(this)) - totalTokensStaked - totalTokensUncollected - totalTokensPenalized;
    }

    // Getter for all of the main contract stats...
    // uint256 private totalTokensDistributed;                     // Tokens EVER Distributed (summary kept up to date for easy reference)
    // uint256 private totalTokensUncollected;                     // Tokens Currently Uncollected - In Distributions (summary kept up to date for easy reference)
    // uint256 private totalTokensPenalized;                       // Summary kept up to date for easy reference...
    // uint256 private totalTokensStaked;                          // Summary kept up to date for easy reference...
    // uint256 private totalSharesInStaking;                       // Summary kept up to date for easy reference...
    // uint256 private currentStakerCount;                         // Running total of the wallets in staking currently
    function GetContractDetails() external view returns(
        uint256 _totalTokensDistributed, uint256 _totalTokensUncollected, uint256 _totalTokensPenalized,
        uint256 _totalTokensStaked, uint256 _totalSharesInStaking, uint256 _currentStakerCount
    )
    {
        _totalTokensDistributed = totalTokensDistributed;
        _totalTokensUncollected = totalTokensUncollected;
        _totalTokensPenalized = totalTokensPenalized;
        _totalTokensStaked = totalTokensStaked;
        _totalSharesInStaking = totalSharesInStaking;
        _currentStakerCount = currentStakerCount;
    }

    // Getter for all of the adjustable contract stats...
    // uint256 private earlyUnstakeTime = 3 days;                  // Configurable time before unstake has a penalty
    // uint256 private earlyUnstakePenalty = 20;                   // Percent lost/burned on early unstake
    // uint256 private oldAfterTime = 30 days;                     // Configurable time before a distribution ages out and can't be collected (tokens burned)
    // uint256 private stakingTransferFee = 0.1 ether;             // Configurable cost of transferring wallets (to keep staking lockups)
    // uint256 private claimRewardAmount = 100000000000;         // Configurable token amount for rewards (starts at 100 VSL tokens)
    function GetAdjustableDetails() external view returns(
        uint256 _earlyUnstakeTime, uint256 _earlyUnstakePenalty, uint256 _oldAfterTime, uint256 _stakingTransferFee, uint256 _claimRewardAmount
    )
    {
        _earlyUnstakeTime = earlyUnstakeTime;
        _earlyUnstakePenalty = earlyUnstakePenalty;
        _oldAfterTime = oldAfterTime;
        _stakingTransferFee = stakingTransferFee;
        _claimRewardAmount = claimRewardAmount;
    }

    // Tokens EVER Distributed (summary kept up to date for easy reference)
    function GetTotalTokensEverDistributed() external view returns (uint256)
    {
        return totalTokensDistributed;
    }

    // Tokens Currently Uncollected - Still In Distributions
    function GetTotalTokensUncollected() external view returns (uint256)
    {
        return totalTokensUncollected;
    }

    // Tokens on the contract in the Currently Panalized pool
    function GetTotalTokensPenalized() external view returns (uint256)
    {
        return totalTokensPenalized;
    }

    // Number of Stakers with stakes still on the contract
    function GetCurrentStakerCount() external view returns (uint256)
    {
        return currentStakerCount;
    }

    // Used to see the total number of tokens in the staking pool currently
    function GetTotalTokensStaked() external view returns (uint256)
    {
        return totalTokensStaked;
    }

    // Used to see the total number of shares in the staking pool at any time...
    function GetTotalSharesInStaking() external view returns (uint256)
    {
        return totalSharesInStaking;
    }

    // Configurable time before unstake has a penalty (defaults to 3 days)
    function GetEarlyUnstakeTime() external view returns (uint256)
    {
        return earlyUnstakeTime;
    }

    // Used to set the number of days before a unstake can be pulled without triggering a penalty
    event EarlyUnstakeTimeSet(uint256 _unstakeTime);
    function SetEarlyUnstakeTime(uint256 _unstakeTime) external onlyAllowedContract
    {
        earlyUnstakeTime = _unstakeTime; // Should be the time equivalent of the number of days
        emit EarlyUnstakeTimeSet(_unstakeTime);
    }

    // See what the Percent lost/burned on early unstake is
    function GetEarlyUnstakePenalty() external view returns (uint256)
    {
        return earlyUnstakePenalty;
    }

    // Get the percentage of tokens to remove for early unstake (whether burned or used elsewhere)
    function CalcEarlyUnstakePenalty(uint256 numberOfTokens) public view returns (uint256)
    {
        return (earlyUnstakePenalty * numberOfTokens) / 100;
    }

    // Change the percentage lost on an early unstake
    event EarlyUnstakePenaltySet(uint256 _newPercentage);
    function SetEarlyUnstakePenalty(uint256 _newPercentage) external onlyAllowedContract
    {
        earlyUnstakePenalty = _newPercentage;
        emit EarlyUnstakePenaltySet(_newPercentage);
    }

    // Configurable time before a distribution ages out and can't be collected (tokens may be burned)
    function GetOldAfterTime() external view returns (uint256)
    {
        return oldAfterTime;
    }

    // Change the time for distributions to age to the point of being allowed to burn
    // default is 30 days...be sure the time passed in represents the correct number of days as time
    event OldAfterSet(uint256 _newTime);
    function SetOldAfterTime(uint256 _newTime) external onlyAllowedContract
    {
        oldAfterTime = _newTime;
        emit OldAfterSet(_newTime);
    }

    // SECTION: Token and BNB Transfers...

    // Used to get random tokens sent to this address out to a wallet...
    function TransferForeignTokens(address _token, address _to) external onlyAllowedContract returns (bool _sent)
    {
        // No back door to remove other people's VSL Tokens...they must collect, unlock and unstake their own
        if(_token == _vslContract) return false;

        // See what is available...
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));

        // Perform the send...
        if(_contractBalance != 0) _sent = IERC20(_token).transfer(_to, _contractBalance);
        else _sent = false;
    }

    // Used to get an amount of random tokens sent to this address out to a wallet...
    function TransferForeignAmount(address _token, address _to, uint256 _maxAmount) external onlyAllowedContract returns (bool _sent)
    {
        // No back door to remove other people's VSL Tokens...they must collect, unlock and unstake their own
        if(_token == _vslContract) return false;

        // See what we have available...
        uint256 amount = IERC20(_token).balanceOf(address(this));

        // Cap it at the max requested...
        if(amount > _maxAmount) amount = _maxAmount;

        // Perform the send...
        if(amount != 0) _sent = IERC20(_token).transfer(_to, amount);
        else _sent = false;
    }

    function TransferInternalAmount(address _to, uint256 _maxAmount) external onlyAllowedContract returns (bool _sent)
    {
        if(_vslContract == address(0x0)) revert MissingTokenContract();

        // See what we have available...
        uint256 amount = GetTokensToDistribute() + totalTokensPenalized;

        // Cap it at the max requested...
        if(amount > _maxAmount)
        {
            if((amount - totalTokensPenalized) > _maxAmount) totalTokensPenalized -= _maxAmount - (amount - totalTokensPenalized);
            amount = _maxAmount;
        }
        else totalTokensPenalized = 0;

        // Perform the send...
        if(amount != 0) _sent = IERC20(_vslContract).transfer(_to, amount);
        else _sent = false;
    }

    // Used to get BNB from the contract...
    function TransferBNBToAddress(address payable recipient, uint256 amount) external onlyAllowedContract
    {
        if(address(this).balance < amount) revert BalanceLow();
        if(amount != 0) recipient.transfer(amount);
    }

    // Used to get BNB from the contract...
    function TransferAllBNBToAddress(address payable recipient) external onlyAllowedContract
    {
        uint256 amount = address(this).balance;
        if(amount != 0) recipient.transfer(amount);
    }

    // SECTION: External Signaling Code

    // Returns number of tokens in a non-fractional manner (includes the decimal places...so 1 is actually a fraction of 1 token)
    function TokensInCirculation() external view returns(uint256 numTokens)
    {
        if(_vslContract == address(0x0)) revert MissingTokenContract();

        // See what was created...
        numTokens = IERC20(_vslContract).totalSupply();

        // See what has been burned...
        numTokens -= IERC20(_vslContract).balanceOf(DEAD_ADDRESS);

        // See what has been staked here...
        numTokens -= IERC20(_vslContract).balanceOf(address(this));

        // See what has been sent back to the contract...
        numTokens -= IERC20(_vslContract).balanceOf(_vslContract);
    }
}