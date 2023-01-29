/**
 *Submitted for verification at BscScan.com on 2023-01-29
*/

// Sources flattened with hardhat v2.12.5 https://hardhat.org

// File contracts/chocolate.sol

/**
 *Submitted for verification at BscScan.com on 2023-01-08
*/

/**
Original contract (Baked Beans 2.0) was written by FrostFlakes Dev JackT: https://t.me/JackTripperz.

Subsequently modified by Dollar Beans https://dollarbeans.money

Fork by 0xThor for Kylie's Chocolate
*/

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

contract chocolatefactory is Context, Ownable {

    using Math for uint256;
    address public OWNER_ADDRESS;
    bool private initialized = false;

    address BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    // BSC testnet BUSD : 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee

    // ARB Mainnet USDC : 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8
    // Avax Mainnet USDC : 0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E
    // BSC Mainnet BUSD : 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
    // CRO Mainnet USDC : 0xc21223249CA28397B4B6541dfFaEcC539BfF0c59
    // FTM Mainnet USDC : 0x04068DA6C83AFCFA0e13ba15A6696662335D5B75
    // OPT Mainnet USDC : 0x7F5c764cBc14f9669B88837ca1490cCa17c31607
    // POLY Mainnet USDC : 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174

    //Deployment addresses
    address public DEV_ADDRESS = 0xd13901A5706E8D70937c45440A7a71fD297D360F;
    address public MARKETING_ADDRESS = 0x42071145D89952B1FB276A558D4E0F9509492cc9;
    address public CEO_ADDRESS = 0xE8DA9B1f02A0d9EcF6B71405d71573194c781327;
    address public GIVEAWAY_ADDRESS = 0x0BE699B2DaF3C5a21D87B85F42A4506b046370AE;

    //Development addresses
    //address public DEV_ADDRESS = 0x1c88ec52E4CA509e4B845A1bc5d095aC8c472a3A;
    //address public MARKETING_ADDRESS = 0xE8DA9B1f02A0d9EcF6B71405d71573194c781327;
    //address public CEO_ADDRESS = 0x0BE699B2DaF3C5a21D87B85F42A4506b046370AE;
    //address public GIVEAWAY_ADDRESS = 0xEc3CbF7047339742Cc21BB86276B0b6bB77c4b08;

    address _dev = DEV_ADDRESS;
    address _marketing = MARKETING_ADDRESS;
    address _ceo = CEO_ADDRESS;
    address _giveAway = GIVEAWAY_ADDRESS;
    address _owner = OWNER_ADDRESS;
    uint136 BNB_PER_BEAN = 1000000000000;
    uint32 SECONDS_PER_DAY = 86400;
    uint8 DEPOSIT_FEE = 3;
    uint8 AIRDROP_FEE = 1;
    uint8 WITHDRAWAL_FEE = 4;
    uint16 DEV_FEE = 20;
    uint16 MARKETING_FEE = 20;
    uint8 CEO_FEE = 60;
    uint8 REF_BONUS = 5;
    uint8 FIRST_DEPOSIT_REF_BONUS = 5;
    uint8 ADD_DEPOSIT_REF_BONUS = 1;
    uint256 MIN_DEPOSIT = 10 ether; // 10 BUSD
    uint256 MIN_BAKE = 1 ether; // 1 BUSD
    uint256 MAX_WALLET_TVL_IN_BNB = 100000000 ether; // 100000000 BUSD
    uint256 MAX_DAILY_REWARDS_IN_BNB = 6500000 ether; // 6500000 BUSD
    uint256 MIN_REF_DEPOSIT_FOR_BONUS = 50 ether; // 50 BUSD

    mapping(address => bool) whitelistedAddresses;
    
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
            verifyUser(ref) || hasInvested(upline.adr), 
            "Ref must be whitelisted or have existing upline"
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
                uint256 refBonus = percentFromAmount(bnbToBeans(_amount),FIRST_DEPOSIT_REF_BONUS);
                upline.beans = addBeans(upline.adr, refBonus);
            }

            address upline2 = upline.upline;

            uint8 counter = 0;

            while (counter < 4) {
                counter++;
                if (upline2 != address(0)) {
                    Baker storage upline3 = bakers[upline2];
                    uint256 refBonus2 = percentFromAmount(bnbToBeans(_amount),ADD_DEPOSIT_REF_BONUS);
                    upline3.beans = addBeans(upline3.adr, refBonus2);
                    upline2 = upline3.upline;
                }
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
        return Math.mul(bakers[adr].totalDeposit, 9);
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
        if (lastDigit <= 0) return 80;
        if (lastDigit <= 1) return 75;
        if (lastDigit <= 2) return 70;
        if (lastDigit <= 3) return 65;
        if (lastDigit <= 4) return 60;
        if (lastDigit <= 5) return 50;
        if (lastDigit <= 6) return 40;
        if (lastDigit <= 7) return 30;
        if (lastDigit <= 8) return 20;
        if (lastDigit <= 9) return 0;
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
        if (verifyUser(adr) || (bakers[adr].firstDeposit != 0)) {
            return true;
        } else {
            return false;
        }
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

        if (referralsCount < 1) return (30000);
        if (referralsCount < 5) return (35000);
        if (referralsCount < 10) return (36000);
        if (referralsCount < 15) return (37000);
        if (referralsCount < 20) return (39000);
        if (referralsCount < 30) return (41000);
        if (referralsCount < 40) return (44000);
        if (referralsCount < 50) return (47000);
        if (referralsCount < 100) return (52000);
        if (referralsCount < 150) return (55000);
        if (referralsCount < 200) return (60000);
        if (referralsCount < 250) return (65000);
        if (referralsCount < 300) return (71000);
        return (77000);
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

    function addUser(address _addressToWhitelist) public onlyOwner {
        Baker storage baker = bakers[_addressToWhitelist];
        whitelistedAddresses[_addressToWhitelist] = true;
        baker.adr = _addressToWhitelist;
    }

    function verifyUser(address _whitelistedAddress) public view returns(bool) {
        bool userIsWhitelisted = whitelistedAddresses[_whitelistedAddress];
    return userIsWhitelisted;
    }

    function showUpline(address ref) public view returns (address upline) {
        Baker storage baker = bakers[ref];
        return(baker.upline);
    }
}