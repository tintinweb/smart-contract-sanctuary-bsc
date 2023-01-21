/**
 *Submitted for verification at BscScan.com on 2023-01-21
*/

/**
Baked Bull official links:
Website: https://bakedbull.co
Telegram: https://t.me/bakedbulls

Original contract (Baked Beans 2.0) was written by FrostFlakes Dev JackT: https://t.me/JackTripperz.
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

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

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
    constructor () {
      address msgSender = _msgSender();
      _owner = msgSender;
      emit OwnershipTransferred(address(0), msgSender);
    }

    /**
    * @dev Returns the address of the current owner.
    */
    function owner() public view returns (address) {
      return _owner;
    }

    
    modifier onlyOwner() {
      require(_owner == _msgSender(), "Ownable: caller is not the owner");
      _;
    }

    function renounceOwnership() public onlyOwner {
      emit OwnershipTransferred(_owner, address(0));
      _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
      _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
      require(newOwner != address(0), "Ownable: new owner is the zero address");
      emit OwnershipTransferred(_owner, newOwner);
      _owner = newOwner;
    }
}
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

contract BakedBull is Context, Ownable {

    using Math for uint256;
    address public OWNER_ADDRESS;
    bool private initialized = false;
    address BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public DEV_ADDRESS = 0x0112c40F0a4A3aa84F5974652222638bA0BaaF0C;
    address public MARKETING_ADDRESS = 0xcAADADdc443ff450C58A08c205Dd9849EDBE6231;
    address public CEO_ADDRESS = 0xc22f21821B6B8c3269c9eB7949760A5F50136304;
    address public GIVEAWAY_ADDRESS = 0x1a52775bBA302E6E464072b6Dfe1301Cb857461E;
    address _dev = DEV_ADDRESS;
    address _marketing = MARKETING_ADDRESS;
    address _ceo = CEO_ADDRESS;
    address _giveAway = GIVEAWAY_ADDRESS;
    address _owner = OWNER_ADDRESS;
    uint136 BNB_PER_BEAN = 1000000000000;
    uint32 SECONDS_PER_DAY = 86400;
    uint8 DEPOSIT_FEE = 1;
    uint8 AIRDROP_FEE = 1;
    uint8 WITHDRAWAL_FEE = 5;
    uint16 DEV_FEE = 10;
    uint16 MARKETING_FEE = 19;
    uint8 CEO_FEE = 66;
    uint8 REF_BONUS = 5;
    uint8 FIRST_DEPOSIT_REF_BONUS = 5;
    uint256 MIN_DEPOSIT = 10 ether; // 10 BUSD
    uint256 MIN_BAKE = 1 ether; // 1 BUSD
    uint256 MAX_WALLET_TVL_IN_BNB = 100000 ether; // 100000 BUSD
    uint256 MAX_DAILY_REWARDS_IN_BNB = 6500 ether; // 6500 BUSD
    uint256 MIN_REF_DEPOSIT_FOR_BONUS = 150 ether; // 150 BUSD

    mapping(uint256 => address) public bakerAddress;
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

        constructor() {
        OWNER_ADDRESS=msg.sender;
    }

    function user(address adr) public view returns (Baker memory) {
        return bakers[adr];
    }

    function buyBeans(address ref, uint256 _amount) public {
        require(initialized);
        Baker storage baker = bakers[msg.sender];
        Baker storage upline = bakers[ref];
        require(
            _amount >= MIN_DEPOSIT,
            "Deposit doesn't meet the minimum requirements"
        );
        require(
            Math.add(baker.totalDeposit, _amount) <= MAX_WALLET_TVL_IN_BNB,
            "Max total deposit reached"
        );
        require(
            ref == address(0) || ref == msg.sender || hasInvested(upline.adr),
            "Ref must be investor to set as upline"
        );
        IERC20(BUSD).transferFrom(msg.sender, address(this), _amount);
        baker.adr = msg.sender;
        uint256 beansFrom = baker.beans;

        uint256 totalBnbFee = percentFromAmount(_amount, DEPOSIT_FEE);
        uint256 bnbValue = Math.sub(_amount, totalBnbFee);
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
                    bnbToBeans(_amount),
                    FIRST_DEPOSIT_REF_BONUS
                );
                upline.beans = addBeans(upline.adr, refBonus);
            }
        }

        if (hasInvested(baker.adr) == false) {
            baker.firstDeposit = block.timestamp;
            bakerAddress[totalBakers] = baker.adr;
            totalBakers++;
        }

        baker.totalDeposit = Math.add(baker.totalDeposit, _amount);
        if (
            baker.hasReferred &&
            baker.totalDeposit >= MIN_REF_DEPOSIT_FOR_BONUS &&
            refExists(baker.adr, baker.upline) == false
        ) {
            upline.bonusEligibleReferrals.push(msg.sender);
        }

        sendFees(totalBnbFee, 0);
        handleBake(false);

        emit EmitBoughtBeans(msg.sender, ref, _amount, beansFrom, baker.beans);
    }

    function refExists(
        address ref,
        address upline
    ) private view returns (bool) {
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

        IERC20(BUSD).transfer(_dev, dev);
        IERC20(BUSD).transfer(_marketing, marketing);
        IERC20(BUSD).transfer(_ceo, ceo);

        if (giveAway > 0) {
            IERC20(BUSD).transfer(_giveAway, giveAway);
        }
    }

    function handleBake(bool onlyRebaking) private {
        Baker storage baker = bakers[msg.sender];
        require(maxTvlReached(baker.adr) == false, "Total wallet TVL reached");
        require(hasInvested(baker.adr), "Must be invested to bake");
        if (onlyRebaking == true) {
            require(
                beansToBnb(rewardedBeans(baker.adr)) >= MIN_BAKE,
                "Rewards must be equal or higher than 1 BUSD to bake"
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
        IERC20(BUSD).transfer(msg.sender, bnbToEat);

        emit EmitAte(msg.sender, bnbToEat, beansBeforeFee);
    }

    function maxPayoutReached(address adr) public view returns (bool) {
        return bakers[adr].totalPayout >= maxPayout(adr);
    }

    function maxPayout(address adr) public view returns (uint256) {
        return Math.mul(bakers[adr].totalDeposit, 3);
    }

    function addWithdrawalTaxes(
        address adr,
        uint256 bnbWithdrawalAmount
    ) private view returns (uint256) {
        return
            percentFromAmount(
                bnbWithdrawalAmount,
                Math.sub(100, hasBeanTaxed(adr))
            );
    }

    function calcGiveAwayAmount(
        address adr,
        uint256 bnbWithdrawalAmount
    ) private view returns (uint256) {
        return (percentFromAmount(bnbWithdrawalAmount, hasBeanTaxed(adr)));
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

    function userBonusEligibleReferrals(
        address adr
    ) public view returns (address[] memory) {
        return bakers[adr].bonusEligibleReferrals;
    }

    function userReferrals(address adr) public view returns (address[] memory) {
        return bakers[adr].referrals;
    }

    function daysSinceLastEat(address adr) private view returns (uint256) {
        uint256 secondsPassed = secondsSinceLastEat(adr);
        return Math.div(secondsPassed, SECONDS_PER_DAY);
    }

    function addBeans(
        address adr,
        uint256 beansToAdd
    ) private view returns (uint256) {
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

    function percentFromAmount(
        uint256 amount,
        uint256 fee
    ) private pure returns (uint256) {
        return Math.div(Math.mul(amount, fee), 100);
    }

    function contractBalance() public view returns (uint256) {
        return IERC20(BUSD).balanceOf(address(this));
    }

    function dailyReward(address adr) public view returns (uint256) {
        uint256 referralsCount = bakers[adr].bonusEligibleReferrals.length;
        if (referralsCount < 10) return 35000;
        if (referralsCount < 25) return (40000);
        if (referralsCount < 50) return (45000);
        if (referralsCount < 100) return (50000);
        if (referralsCount < 150) return (55000);
        if (referralsCount < 250) return (60000);
        return 65000;
    }

    function secondsSinceLastAction(
        address adr
    ) private view returns (uint256) {
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

    function initializeContract() public onlyOwner {
        initialized = true;
    }
}