/**
 *Submitted for verification at BscScan.com on 2023-03-10
*/

// SPDX-License-Identifier: MIT


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


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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








library Math {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function pow(uint256 a, uint256 b) internal pure returns (uint256) {
        return a ** b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}





pragma solidity 0.8.17;

contract CryptoForge is Context, Ownable {
   
    
    
    constructor()  {
       
        
        DEV_ADDRESS = 0x7a9fB4C9bb3eE8A01f9C0a8702E623CD8F94f81F;
        MARKETING_ADDRESS = 0xFE114d87DCABbAa60D8c0F28604F4a69F703C598;
        CEO_ADDRESS = 0xd56126cfa24d23500E09cA55D56f9d51a97b7D36;
        GIVEAWAY_ADDRESS = 0x2b6E5B5C79E15E34A86b397f907B5e77CE365CD0;
        OWNER_ADDRESS = _msgSender();
        _dev = payable(DEV_ADDRESS);
        _marketing = payable(MARKETING_ADDRESS);
        _ceo = payable(CEO_ADDRESS);
        _giveAway = payable(GIVEAWAY_ADDRESS);
        _owner = payable(OWNER_ADDRESS);
        BNB_PER_BEAN = 1000000000000;
        SECONDS_PER_DAY = 86400;
        DEPOSIT_FEE = 5;
        AIRDROP_FEE = 1;
        WITHDRAWAL_FEE = 5;
        DEV_FEE = 10;
        MARKETING_FEE = 19;
        CEO_FEE = 66;
        REF_BONUS = 5;
        FIRST_DEPOSIT_REF_BONUS = 5;
        MIN_DEPOSIT = 10000000000000000; // 0.01 BNB
        MIN_BAKE = 10000000000000000; // 0.01 BNB
        MAX_WALLET_TVL_IN_BNB = 200000000000000000000; // 200 BNB
        MAX_DAILY_REWARDS_IN_BNB = 5000000000000000000; // 5 BNB
        MIN_REF_DEPOSIT_FOR_BONUS = 250000000000000000; // 0.25 BNB
    }

    
   

    using Math for uint256;

    address private DEV_ADDRESS;
    address private MARKETING_ADDRESS;
    address private CEO_ADDRESS;
    address private GIVEAWAY_ADDRESS;
    address private OWNER_ADDRESS;
    address payable internal _dev;
    address payable internal _marketing;
    address payable internal _ceo;
    address payable internal _giveAway;
    address payable internal _owner;

    uint136 private BNB_PER_BEAN;
    uint32 private SECONDS_PER_DAY;
    uint8 private DEPOSIT_FEE;
    uint8 private AIRDROP_FEE;
    uint8 private CEO_FEE;
    uint8 private WITHDRAWAL_FEE;
    uint16 private DEV_FEE;
    uint16 private MARKETING_FEE;
    uint8 private REF_BONUS;
    uint8 private FIRST_DEPOSIT_REF_BONUS;
    uint256 private MIN_DEPOSIT;
    uint256 private MIN_BAKE;
    uint256 private MAX_WALLET_TVL_IN_BNB;
    uint256 private MAX_DAILY_REWARDS_IN_BNB;
    uint256 private MIN_REF_DEPOSIT_FOR_BONUS;

    uint256 public totalBakers;

    struct Baker {
        address adr;
        uint256 beans;
        uint256 bakedAt;
        uint256 ateAt;
        address upline;
        bool hasReferred;
        address[] referrals;
        address[] bonusEligibleReferrals;
        uint256 firstDeposit;
        uint256 totalDeposit;
        uint256 totalPayout;
        bool blacklisted;
    }

    mapping(address => Baker) internal bakers;

    event EmitBoughtBeans(
        address indexed adr,
        address indexed ref,
        uint256 bnbamount,
        uint256 beansFrom,
        uint256 beansTo
    );
    event EmitBaked(
        address indexed adr,
        address indexed ref,
        uint256 beansFrom,
        uint256 beansTo
    );
    event EmitAte(
        address indexed adr,
        uint256 bnbToEat,
        uint256 beansBeforeFee
    );

    function user(address adr) public view returns (Baker memory) {
        return bakers[adr];
    }

    function buyBeans(address ref) public payable {
        Baker storage baker = bakers[msg.sender];
        Baker storage upline = bakers[ref];
        require(
            msg.value >= MIN_DEPOSIT,
            "Deposit doesn't meet the minimum requirements"
        );
        require(
            Math.add(baker.totalDeposit, msg.value) <= MAX_WALLET_TVL_IN_BNB,
            "Max total deposit reached"
        );
       

        baker.adr = msg.sender;
        uint256 beansFrom = baker.beans;

        uint256 totalBnbFee = percentFromAmount(msg.value, DEPOSIT_FEE);
        uint256 bnbValue = Math.sub(msg.value, totalBnbFee);
        uint256 beansBought = bnbToBeans(bnbValue);

        uint256 totalBeansBought = addBeans(baker.adr, beansBought);
        baker.beans = totalBeansBought;

        if (
            !baker.hasReferred &&
            ref != msg.sender &&
            ref != address(0) &&
            baker.upline != msg.sender
        ) {
            baker.upline = ref;
            baker.hasReferred = true;

            upline.referrals.push(msg.sender);
            if (hasInvested(baker.adr) == false) {
                uint256 refBonus = percentFromAmount(
                    bnbToBeans(msg.value),
                    FIRST_DEPOSIT_REF_BONUS
                );
                upline.beans = addBeans(upline.adr, refBonus);
            }
        }

        if (hasInvested(baker.adr) == false) {
            baker.firstDeposit = block.timestamp;
            totalBakers++;
        }

        baker.totalDeposit = Math.add(baker.totalDeposit, msg.value);
        if (
            baker.hasReferred &&
            baker.totalDeposit >= MIN_REF_DEPOSIT_FOR_BONUS &&
            refExists(baker.adr, baker.upline) == false
        ) {
            upline.bonusEligibleReferrals.push(msg.sender);
        }

        sendFees(totalBnbFee, 0);
        handleBake(false);

        emit EmitBoughtBeans(
            msg.sender,
            ref,
            msg.value,
            beansFrom,
            baker.beans
        );
    }

    function refExists(address ref, address upline)
        private
        view
        returns (bool)
    {
        for (
            uint256 i = 0;
            i < bakers[upline].bonusEligibleReferrals.length;
            i++
        ) {
            if (bakers[upline].bonusEligibleReferrals[i] == ref) {
                return true;
            }
        }

        return false;
    }

    function sendFees(uint256 totalFee, uint256 giveAway) private {
        uint256 dev = percentFromAmount(totalFee, DEV_FEE);
        uint256 marketing = percentFromAmount(totalFee, MARKETING_FEE);
        uint256 ceo = percentFromAmount(totalFee, CEO_FEE);

        _dev.transfer(dev);
        _marketing.transfer(marketing);
        _ceo.transfer(ceo);

        if (giveAway > 0) {
            _giveAway.transfer(giveAway);
        }
    }

     function handleBake(bool onlyRebaking) private {
        Baker storage baker = bakers[msg.sender];
        require(maxTvlReached(baker.adr) == false, "Total wallet TVL reached");
        require(hasInvested(baker.adr), "Must be invested to bake");
        if (onlyRebaking == true) {
            require(
                beansToBnb(rewardedBeans(baker.adr)) >= MIN_BAKE,
                "Rewards must be equal or higher than 0.01 BNB to bake"
            );
        }

        uint256 beansFrom = baker.beans;
        uint256 beansFromRewards = rewardedBeans(baker.adr);

        uint256 totalBeans = addBeans(baker.adr, beansFromRewards);
        baker.beans = totalBeans;
        baker.bakedAt = block.timestamp;

        emit EmitBaked(msg.sender, baker.upline, beansFrom, baker.beans);
    }

    function bake() public {
        handleBake(true);
    }

    function eat() public {
        Baker storage baker = bakers[msg.sender];
        require(hasInvested(baker.adr), "Must be invested to eat");
        require(
            maxPayoutReached(baker.adr) == false,
            "You have reached max payout"
        );

        uint256 beansBeforeFee = rewardedBeans(baker.adr);
        uint256 beansInBnbBeforeFee = beansToBnb(beansBeforeFee);

        uint256 totalBnbFee = percentFromAmount(
            beansInBnbBeforeFee,
            WITHDRAWAL_FEE
        );

        uint256 bnbToEat = Math.sub(beansInBnbBeforeFee, totalBnbFee);
        uint256 forGiveAway = calcGiveAwayAmount(baker.adr, bnbToEat);
        bnbToEat = addWithdrawalTaxes(baker.adr, bnbToEat);

        if (
            Math.add(beansInBnbBeforeFee, baker.totalPayout) >=
            maxPayout(baker.adr)
        ) {
            bnbToEat = Math.sub(maxPayout(baker.adr), baker.totalPayout);
            baker.totalPayout = maxPayout(baker.adr);
        } else {
            uint256 afterTax = addWithdrawalTaxes(
                baker.adr,
                beansInBnbBeforeFee
            );
            baker.totalPayout = Math.add(baker.totalPayout, afterTax);
        }

        baker.ateAt = block.timestamp;
        baker.bakedAt = block.timestamp;

        sendFees(totalBnbFee, forGiveAway);
        payable(msg.sender).transfer(bnbToEat);

        emit EmitAte(msg.sender, bnbToEat, beansBeforeFee);
    }

    function maxPayoutReached(address adr) public view returns (bool) {
        return bakers[adr].totalPayout >= maxPayout(adr);
    }

    function maxPayout(address adr) public view returns (uint256) {
        return Math.mul(bakers[adr].totalDeposit, 3);
    }

    function addWithdrawalTaxes(address adr, uint256 bnbWithdrawalAmount)
        private
        view
        returns (uint256)
    {
        return
            percentFromAmount(
                bnbWithdrawalAmount,
                Math.sub(100, hasBeanTaxed(adr))
            );
    }

    function calcGiveAwayAmount(address adr, uint256 bnbWithdrawalAmount)
        private
        view
        returns (uint256)
    {
        return (percentFromAmount(bnbWithdrawalAmount, hasBeanTaxed(adr)) / 2);
    }

    function hasBeanTaxed(address adr) public view returns (uint256) {
        uint256 daysPassed = daysSinceLastEat(adr);
        uint256 lastDigit = daysPassed % 10;

        if (lastDigit <= 0) return 90;
        if (lastDigit <= 1) return 80;
        if (lastDigit <= 2) return 70;
        if (lastDigit <= 3) return 60;
        if (lastDigit <= 4) return 50;
        if (lastDigit <= 5) return 40;
        if (lastDigit <= 6) return 30;
        if (lastDigit <= 7) return 20;
        if (lastDigit <= 8) return 10;
        return 0;
    }

    function secondsSinceLastEat(address adr) public view returns (uint256) {
        uint256 lastAteOrFirstDeposit = bakers[adr].ateAt;
        if (bakers[adr].ateAt == 0) {
            lastAteOrFirstDeposit = bakers[adr].firstDeposit;
        }

        uint256 secondsPassed = Math.sub(
            block.timestamp,
            lastAteOrFirstDeposit
        );

        return secondsPassed;
    }

    function userBonusEligibleReferrals(address adr) public view returns (address[] memory) {
        return bakers[adr].bonusEligibleReferrals;
    }

    function userReferrals(address adr) public view returns (address[] memory) {
        return bakers[adr].referrals;
    }

    function daysSinceLastEat(address adr) private view returns (uint256) {
        uint256 secondsPassed = secondsSinceLastEat(adr);
        return Math.div(secondsPassed, SECONDS_PER_DAY);
    }

    function addBeans(address adr, uint256 beansToAdd)
        private
        view
        returns (uint256)
    {
        uint256 totalBeans = Math.add(bakers[adr].beans, beansToAdd);
        uint256 maxBeans = bnbToBeans(MAX_WALLET_TVL_IN_BNB);
        if (totalBeans >= maxBeans) {
            return maxBeans;
        }
        return totalBeans;
    }

    function maxTvlReached(address adr) public view returns (bool) {
        return bakers[adr].beans >= bnbToBeans(MAX_WALLET_TVL_IN_BNB);
    }

    function hasInvested(address adr) public view returns (bool) {
        return bakers[adr].firstDeposit != 0;
    }

    function bnbRewards(address adr) public view returns (uint256) {
        uint256 beansRewarded = rewardedBeans(adr);
        uint256 bnbinWei = beansToBnb(beansRewarded);
        return bnbinWei;
    }

    function bnbTvl(address adr) public view returns (uint256) {
        uint256 bnbinWei = beansToBnb(bakers[adr].beans);
        return bnbinWei;
    }

    function beansToBnb(uint256 beansToCalc) private view returns (uint256) {
        uint256 bnbInWei = Math.mul(beansToCalc, BNB_PER_BEAN);
        return bnbInWei;
    }

    function bnbToBeans(uint256 bnbInWei) private view returns (uint256) {
        uint256 beansFromBnb = Math.div(bnbInWei, BNB_PER_BEAN);
        return beansFromBnb;
    }

    function percentFromAmount(uint256 amount, uint256 fee)
        private
        pure
        returns (uint256)
    {
        return Math.div(Math.mul(amount, fee), 100);
    }

    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function dailyReward(address adr) public view returns (uint256) {
        uint256 referralsCount = bakers[adr].bonusEligibleReferrals.length;
        if (referralsCount < 5) return 30000;
        if (referralsCount < 15) return (35000);
        if (referralsCount < 25) return (40000);
        if (referralsCount < 50) return (45000);
        if (referralsCount < 100) return (50000);
        if (referralsCount < 200) return (55000);
        return 60000;
    }

    function secondsSinceLastAction(address adr)
        private
        view
        returns (uint256)
    {
        uint256 lastTimeStamp = bakers[adr].bakedAt;
        if (lastTimeStamp == 0) {
            lastTimeStamp = bakers[adr].ateAt;
        }

        if (lastTimeStamp == 0) {
            lastTimeStamp = bakers[adr].firstDeposit;
        }

        return Math.sub(block.timestamp, lastTimeStamp);
    }

    function rewardedBeans(address adr) private view returns (uint256) {
        uint256 secondsPassed = secondsSinceLastAction(adr);
        uint256 dailyRewardFactor = dailyReward(adr);
        uint256 beansRewarded = calcBeansReward(
            secondsPassed,
            dailyRewardFactor,
            adr
        );

        if (beansRewarded >= bnbToBeans(MAX_DAILY_REWARDS_IN_BNB)) {
            return bnbToBeans(MAX_DAILY_REWARDS_IN_BNB);
        }

        return beansRewarded;
    }

    function calcBeansReward(
        uint256 secondsPassed,
        uint256 dailyRewardFactor,
        address adr
    ) private view returns (uint256) {
        uint256 rewardsPerDay = percentFromAmount(
            Math.mul(bakers[adr].beans, 100000000),
            dailyRewardFactor
        );
        uint256 rewardsPerSecond = Math.div(rewardsPerDay, SECONDS_PER_DAY);
        uint256 beansRewarded = Math.mul(rewardsPerSecond, secondsPassed);
        beansRewarded = Math.div(beansRewarded, 1000000000000);
        return beansRewarded;
    }
}