/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: StakingARTR.sol


pragma solidity ^0.8.9;


interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval( address indexed owner, address indexed spender, uint value);

    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address to, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function increaseAllowance(address owner, address spender, uint addedValue) external returns (bool);
    function transferFrom(address from, address to, uint amount) external returns (bool);
    function burn(address account, uint amount) external;
}

interface IPromo {
    function addPromo(string[] memory _promo, uint[] memory coins, uint amount) external;
    function deactivatePromo(string memory _promo) external;
    function checkPromo(string memory _promo) external view returns (uint);
}

contract StakingARTR is Ownable {
    IERC20 public ARTR;
    IPromo promo;
    address public founder;

    struct StakeStruct {
        uint amount;
        uint date;
        uint month;
        uint stakeFinishTime;
        uint freezedAmount;
        uint freezedFinishTime;
        bool finished;
    }

    struct Holder {
        address refferral;
        uint virtualCoins;
        uint tier;
        uint timeCf;
        uint tierCf;
        uint earned;
        uint unstaked;

        uint dailyReward;
        uint saveDailyReward;
        uint numOfPayments;
        bool rewardFinished;
    }

    mapping(address => Holder) holders;
    mapping(address => StakeStruct) public stakeDetails;

    mapping(uint => uint) percents;
    mapping(uint => uint) timeCfs;
    mapping(uint => uint) stakeMonths;
    mapping(uint => uint) public tiers;
    mapping(uint => uint) tierCfs;

    uint totalStaked;

    event Staked(address indexed holderAddress, uint indexed amount, uint indexed time);
    event Unstaked(address indexed holderAddress, uint indexed amount);
    event FreezedTokenGotten(address indexed holderAddress, uint indexed amount);
    event PromoActivated(address indexed holderAddress, uint indexed amount);

    constructor(address _stakingToken) {
        founder = _msgSender();
        ARTR = IERC20(_stakingToken);
        setValues();
        holders[0x503aA536d9DCF986c5644F082C066Ca32e8D442f].tier = 5;
    }

    ///@notice Basic

    function Stake(uint months, uint amount, address holder, address refferral, uint tier) external {
        require(holder != address(0), "invalid address");
        require(amount > 0, "invalid amount");
        require(months == stakeMonths[1] || months == stakeMonths[2] || months == stakeMonths[3] || months == stakeMonths[4], "invalid time");
        require(amount >= (tiers[tier]/100)*30 && holders[holder].virtualCoins >= tiers[tier] - amount,"Not enough amount");
        if (stakeDetails[holder].amount != 0)
            require(months >= stakeDetails[holder].month,"Time of new stake should be longer, then remainder of old stake");
        
        ARTR.increaseAllowance(holder, address(this), amount);
        ARTR.transferFrom(holder, address(this), amount);
        totalStaked += amount;

        holders[holder].tier = tier;
        holders[holder].timeCf = timeCfs[months];
        holders[holder].tierCf = tierCfs[tier];
        holders[holder].virtualCoins -= tiers[tier] - amount;
        holders[holder].refferral = refferral;

        stakeDetails[holder].date = block.timestamp;
        stakeDetails[holder].month = months;
        stakeDetails[holder].stakeFinishTime = block.timestamp + months * 10;//2629743
        stakeDetails[holder].amount += amount;

        if (months > stakeMonths[1]) {
            holders[holder].dailyReward = ((stakeDetails[holder].amount/100)*(percents[months]/10))/30;
            if (months == stakeMonths[2])
                holders[refferral].virtualCoins += (amount/100)*5;
            else if (months == stakeMonths[3])
                holders[refferral].virtualCoins += (amount/100)*10;
            else holders[refferral].virtualCoins += (amount/100)*20;
        }

        emit Staked(holder, amount, months);
    }

    function Unstake(address holder) external  {
        require(holder != address(0), "invalid address");
        uint amount = stakeDetails[holder].amount;
        require(amount != 0, "you don't have stake");

        stakeDetails[holder].amount = 0;
        stakeDetails[holder].month = 0;
        //!!!
        stakeDetails[holder].freezedFinishTime = block.timestamp + 40;

        holders[holder].unstaked += amount;
        uint burnValue = (amount*5)/100;
        ARTR.burn(address(this), burnValue);
        if (stakeDetails[holder].freezedFinishTime >= stakeDetails[holder].stakeFinishTime)
            stakeDetails[holder].freezedAmount = amount;
        else {
            stakeDetails[holder].freezedAmount = (amount / 100) * 75;
            holders[holder].saveDailyReward = countReward(holder);
            holders[holder].dailyReward = 0;
            holders[holder].rewardFinished = true;
            holders[holder].tier = 0;
            holders[holder].timeCf = 0;
            holders[holder].tierCf = 0;
            }

        emit Unstaked(holder, amount);
    }

    function getFreezedTokens(address holder) external {
        require(holder != address(0), "invalid address");
        require(stakeDetails[holder].freezedAmount > 0, "You don't have freezed money");
        require(block.timestamp >= stakeDetails[holder].freezedFinishTime, "too early");
        uint value = stakeDetails[holder].freezedAmount;
        stakeDetails[holder].freezedFinishTime = 0;
        stakeDetails[holder].freezedAmount = 0;
        ARTR.transfer(holder, value);
        emit FreezedTokenGotten(holder, value);
    }

    ///@notice Rewards

    function getReward(address holder) external {
        require(holder != address(0), "invalid address");
        uint rewardValue = countReward(holder);
        require(rewardValue != 0, "You don't have reward");
        holders[holder].earned += rewardValue;
        ARTR.transfer(holder, rewardValue);
    }

    function countReward(address holder) internal returns (uint) {
        uint _rewardValue;
        if (!holders[holder].rewardFinished) {
            //!!!
            uint readyRewards = (block.timestamp - stakeDetails[holder].date)/20 - holders[holder].numOfPayments;
            uint _dailyReward = holders[holder].dailyReward;
            if (stakeDetails[holder].freezedFinishTime > 0) {
                uint stakeDays = (stakeDetails[holder].freezedFinishTime-stakeDetails[holder].date)/20;
                if (holders[holder].numOfPayments + readyRewards >= stakeDays) {
                    readyRewards = stakeDays - holders[holder].numOfPayments;
                    holders[holder].dailyReward = 0;
                    holders[holder].rewardFinished = true;
                }
            }
            _rewardValue = readyRewards * _dailyReward;
            holders[holder].numOfPayments += readyRewards;
        } else {
            _rewardValue = holders[holder].saveDailyReward;
            if (_rewardValue != 0)
                holders[holder].saveDailyReward = 0;
        }

        return _rewardValue;
    }

    ///@notice Promo

    function activatePromo(string memory _promo, address holder) external returns(uint) {
        uint coins = promo.checkPromo(_promo);
        require (coins > 0, "invalid promocode");
        promo.deactivatePromo(_promo);
        holders[holder].virtualCoins += coins*10**18;

        emit FreezedTokenGotten(holder, coins);
        return coins;
    }

    ///@notice Info

    function holderData(address holder) external view returns 
    (address refferral,
     uint virtualCoins,
     uint tier,
     uint timeCf,
     uint tierCf,
     uint earned,
     uint unstakedAmount,
     uint dailyReward,
     uint saveDailyReward,
     uint numOfPayments,
     bool rewardFinished
     ) {
        address _holder = holder;
        uint _tier;
        uint _timeCf;
        uint _tierCf;
        if (stakeDetails[_holder].freezedFinishTime > 0 && block.timestamp > stakeDetails[_holder].freezedFinishTime) {
            _tier = 0;
            _timeCf = 0;
            _tierCf = 0;
        } else {
            _tier = holders[_holder].tier;
            _timeCf = holders[_holder].timeCf;
            _tierCf = holders[_holder].tierCf;
        }
        return (
            holders[_holder].refferral,
            holders[_holder].virtualCoins,
            _tier,
            _timeCf,
            _tierCf,
            holders[_holder].earned,
            holders[_holder].unstaked,
            holders[_holder].dailyReward,
            holders[_holder].saveDailyReward,
            holders[_holder].numOfPayments,
            holders[_holder].rewardFinished
        );
    }

    function getRewardAmount(address holder) external view returns (uint) {
        uint _rewardValue;
        if (!holders[holder].rewardFinished) {
            //!!!
            uint readyRewards = (block.timestamp - stakeDetails[holder].date)/20 - holders[holder].numOfPayments;
            if (stakeDetails[holder].freezedFinishTime > 0) {
                uint stakeDays = (stakeDetails[holder].freezedFinishTime-stakeDetails[holder].date)/20;
                if (holders[holder].numOfPayments + readyRewards >= stakeDays) {
                    readyRewards = stakeDays - holders[holder].numOfPayments;
                }
            }
            _rewardValue = readyRewards * holders[holder].dailyReward;
        } else {
            _rewardValue = holders[holder].saveDailyReward;
        }

        return _rewardValue;
    } 

    function getContractBalance() external view returns (uint balance) {
        return ARTR.balanceOf(address(this));
    }

    function getTotalStaked() external view returns (uint) {
        return totalStaked;
    }

    function getHolderTier(address holder) external view returns (uint) {
        uint tier = holders[holder].tier;
        if (stakeDetails[holder].freezedFinishTime > 0 && block.timestamp > stakeDetails[holder].freezedFinishTime)
            tier = 0;
        return tier;
    }

    function getHolderTimeCf(address holder) external view returns (uint) {
        uint timeCf = holders[holder].timeCf;
        if (stakeDetails[holder].freezedFinishTime > 0 && block.timestamp > stakeDetails[holder].freezedFinishTime)
            timeCf = 0;
        return timeCf;
    }

    function getHolderTierCf(address holder) external view returns (uint) {
        uint tierCf = holders[holder].tierCf;
        if (stakeDetails[holder].freezedFinishTime > 0 && block.timestamp > stakeDetails[holder].freezedFinishTime)
            tierCf = 0;
        return tierCf;
    }

    function getHolderAmount(address holder) external view returns (uint) {
        return stakeDetails[holder].amount;
    }

    function getHolderStakingTime(address holder) external view returns (uint) {
        return stakeDetails[holder].month;
    }

    function getHolderEarned(address holder) external view returns (uint) {
        return holders[holder].earned;
    }

    function getHolderUnstaked(address holder) external view returns (uint) {
        return holders[holder].unstaked;
    }

    function getHolderStakeInfo(address holder) external view returns 
    (uint date,
     uint months,
     uint stakeFinishTime,
     uint amount,
     uint freezedAmount,
     uint freezeFinishTime) {
        return (
            stakeDetails[holder].date,
            stakeDetails[holder].month,
            stakeDetails[holder].stakeFinishTime,
            stakeDetails[holder].amount,
            stakeDetails[holder].freezedAmount,
            stakeDetails[holder].freezedFinishTime
            );
    }

    function getPromoCheck(string memory _promo) external view onlyOwner returns(uint) {
        return promo.checkPromo(_promo);
    }

    ///@notice Settings

    function changeTierValues(uint tier, uint newBorder, uint newTierCF) public onlyOwner {
        tiers[tier] = newBorder;
        tierCfs[tier] = newTierCF;
    }

    function changePeriodValues(uint numOfPeriod, uint newMonths, uint newCF, uint newPercent) public onlyOwner {
        stakeMonths[numOfPeriod] = newMonths;
        timeCfs[newMonths] = newCF;
        percents[newMonths] = newPercent;
    }

    function setPromoAdd(address _promo) public onlyOwner {
        promo = IPromo(_promo);
    }

    function addPromo(string[] memory _promos, uint[] memory coins, uint amount) external  onlyOwner {
        promo.addPromo(_promos, coins, amount);
    }

    function changeFounder(address _founder) external onlyOwner {
        founder = _founder;
    }

    function setValues() private {
        percents[1] = 0;
        percents[4] = 10;
        percents[6] = 15;
        percents[12] = 20;

        timeCfs[1] = 10;
        timeCfs[4] = 11;
        timeCfs[6] = 12;
        timeCfs[12] = 13;

        stakeMonths[1] = 1;
        stakeMonths[2] = 4;
        stakeMonths[3] = 6;
        stakeMonths[4] = 12;

        tiers[1] = 2500*10**18;
        tiers[2] = 5000*10**18;
        tiers[3] = 7000*10**18;
        tiers[4] = 10000*10**18;
        tiers[5] = 25000*10**18;
        tiers[6] = 50000*10**18;
        tiers[7] = 100000*10**18;
        tiers[8] = 250000*10**18;
        tiers[9] = 325000*10**18;
        tiers[10] = 575000*10**18;

        tierCfs[1] = 10;
        tierCfs[2] = 10;
        tierCfs[3] = 10;
        tierCfs[4] = 10;
        tierCfs[5] = 25;
        tierCfs[6] = 50;
        tierCfs[7] = 110;
        tierCfs[8] = 280;
        tierCfs[9] = 360;
        tierCfs[10] = 700;
    }
}