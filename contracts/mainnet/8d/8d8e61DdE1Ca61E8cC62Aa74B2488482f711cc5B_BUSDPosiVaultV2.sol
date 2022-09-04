pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@positionex/posi-token/contracts/VestingScheduleLogic.sol";
import "./interfaces/IUniswapV2Router.sol";
import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IPosiStakingManager.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./library/UserInfo.sol";
import "./library/SwapMath.sol";
import "./library/TwapLogic.sol";
import "./interfaces/IPositionReferral.sol";
import "./interfaces/IVaultReferralTreasury.sol";
import "./interfaces/ISpotHouse.sol";

/*
A vault that helps users stake in POSI farms and pools more simply.
Supporting auto compound in Single Staking Pool.
*/

contract BUSDPosiVaultV2 is Initializable, ReentrancyGuardUpgradeable, OwnableUpgradeable, VestingScheduleLogic {
    using SafeMath for uint256;
    using UserInfo for UserInfo.Data;
    using TwapLogic for TwapLogic.ReserveSnapshot[];

    // MAINNET
    IERC20 public posi;
    IERC20 public busd;
    IUniswapV2Router02 public router;
    IUniswapV2Factory public factory;
    IPosiStakingManager public posiStakingManager;
    IPositionReferral public positionReferral;
    uint256 public constant POSI_BUSD_PID = 0;
    //
    //    // TESTNET
    //    IERC20 public posi = IERC20(0xb228359B5D83974F47655Ee41f17F3822A1fD0DD);
    //    IERC20 public busd = IERC20(0x787cF64b9F6E3d9E120270Cb84e8Ba1Fe8C1Ae09);
    //    IUniswapV2Router02 public router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
    //    IUniswapV2Factory public factory = IUniswapV2Factory(0x6725F303b657a9451d8BA641348b6761A6CC7a17);
    //    IPosiStakingManager public posiStakingManager = IPosiStakingManager(0xD0A6C46316f789Ba3bdC320ebCC9AFdaE752fd73);
    //    IPositionReferral public positionReferral;
    //    uint256 public constant POSI_BUSD_PID = 2;

    uint256 public constant MAX_INT = 115792089237316195423570985008687907853269984665640564039457584007913129639935;

    mapping(address => UserInfo.Data) public userInfo;
    uint256 public totalSupply;
    uint256 public pendingRewardPerTokenStored;
    uint256 public lastUpdatePoolPendingReward;
    uint256 public lastCompoundRewardPerToken;

    uint256 public referralCommissionRate;
    uint256 public percentFeeForCompounding;

    IVaultReferralTreasury public vaultReferralTreasury;

    ISpotHouse public spotHouse;
    IPairManager public pairManager;
    mapping (address => mapping(VestingFrequencyHelper.Frequency => VestingData[])) public vestingSchedule;
    TwapLogic.ReserveSnapshot[] public reserveSnapshots;
    TwapLogic.ReserveSnapshot[] public res0Snapshots;

    event Deposit(address account, uint256 amount);
    event Withdraw(address account, uint256 amount);
    event Harvest(address account, uint256 amount);
    event Compound(address caller, uint256 reward);
    event RewardPaid(address account, uint256 reward);
    event ReferralCommissionPaid(
        address indexed user,
        address indexed referrer,
        uint256 commissionAmount
    );

    modifier noCallFromContract {
        // due to flashloan attack
        // we don't like contract calls to our vault
        require(tx.origin == msg.sender, "no contract call");
        _;
    }

    modifier updateReward(address account) {

        pendingRewardPerTokenStored = pendingRewardPerToken();
        if(pendingRewardPerTokenStored != 0){
            lastUpdatePoolPendingReward = totalPoolPendingRewards();
        }

        if(account != address(0)){
            if(lastCompoundRewardPerToken >= userInfo[account].pendingRewardPerTokenPaid){
                // set user earned
                userInfo[account].updateEarnedRewards(earned(account));
            }
            userInfo[account].updatePendingReward(
                pendingEarned(account),
                pendingRewardPerTokenStored
            );
        }
        _;
    }

    modifier waitForCompound {
        require(!canCompound(), "Call compound first");
        _;
    }

    function initialize(address _posi, address _busd, address _router, address _factory, address _posiStakingManager, address _vaultReferralTreasury) public initializer {
        __ReentrancyGuard_init();
        __Ownable_init();
        /*
        MAINNET
        posi = IERC20(0x5CA42204cDaa70d5c773946e69dE942b85CA6706);
        busd = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        factory = IUniswapV2Factory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);
        posiStakingManager = IPosiStakingManager(0x0C54B0b7d61De871dB47c3aD3F69FEB0F2C8db0B);
        */
        posi = IERC20(_posi);
        busd = IERC20(_busd);
        router = IUniswapV2Router02(_router);
        factory = IUniswapV2Factory(_factory);
        posiStakingManager = IPosiStakingManager(_posiStakingManager);
        vaultReferralTreasury = IVaultReferralTreasury(_vaultReferralTreasury);
        percentFeeForCompounding = 50; //default 5%
    }

    function canCompound() public view returns (bool) {
        return posiStakingManager.canHarvest(POSI_BUSD_PID, address(this));
    }

    function nearestCompoundingTime() public view returns (uint256 time) {
        (,,,time) = posiStakingManager.userInfo(POSI_BUSD_PID, address(this));
    }

    function balanceOf(address user) public view returns (uint256) {
        return getReserveInAmount1ByLP(userInfo[user].amount);
    }

    function lpOf(address user) public view returns (uint256) {
        return userInfo[user].amount;
    }


    function totalPoolPendingRewards() public view returns (uint256) {
        return posiStakingManager.pendingPosition(POSI_BUSD_PID, address(this));
    }

    // total user's rewards: pending + earned
    function pendingEarned(address account) public view returns (uint256) {
        UserInfo.Data memory _userInfo = userInfo[account];
        uint256 _pendingRewardPerToken = pendingRewardPerToken();
        if(lastCompoundRewardPerToken >= _userInfo.pendingRewardPerTokenPaid){
            // only count for the next change
            return lpOf(account).mul(
                _pendingRewardPerToken
                .sub(lastCompoundRewardPerToken)
            )
            .div(1e18);
        }else{
            return lpOf(account).mul(
                _pendingRewardPerToken
                .sub(_userInfo.pendingRewardPerTokenPaid)
            )
            .div(1e18)
            .add(_userInfo.pendingRewards);
        }

    }

    // total user's rewards ready to withdraw
    function earned(address account) public view returns (uint256) {
        UserInfo.Data memory _userInfo = userInfo[account]; // save gas
        if(lastCompoundRewardPerToken < _userInfo.pendingRewardPerTokenPaid) return _userInfo.rewards;
        return lpOf(account).mul(
            lastCompoundRewardPerToken
            .sub(_userInfo.pendingRewardPerTokenPaid)
        )
        .div(1e18)
        .add(_userInfo.pendingRewards)
        .add(_userInfo.rewards);
    }

    function pendingRewardPerToken() public view returns (uint256) {
        if (totalSupply == 0) {
            return 0;
        }
        return pendingRewardPerTokenStored.add(
            totalPoolPendingRewards()
            .sub(lastUpdatePoolPendingReward)
            .mul(1e18)
            .div(totalSupply)
        );
    }

    function getSwappingPair() internal view returns (IUniswapV2Pair) {
        return IUniswapV2Pair(
            factory.getPair(address(posi), address(busd))
        );
    }

    function updatePositionReferral(IPositionReferral _positionReferral) external onlyOwner {
        positionReferral = _positionReferral;
    }

    function updateReferralCommissionRate(uint256 _rate) external onlyOwner {
        require(_rate <= 2000, "max 20%");
        referralCommissionRate = _rate;
    }

    function updatePercentFeeForCompounding(uint256 _rate) external onlyOwner {
        require(_rate <= 100, "max 10%");
        percentFeeForCompounding = _rate;
    }


    function approve() public {
        posi.approve(address(posiStakingManager), MAX_INT);
        posi.approve(address(router), MAX_INT);
        busd.approve(address(router), MAX_INT);
        getSwappingPair().approve(address(posiStakingManager), MAX_INT);
        getSwappingPair().approve(address(router), MAX_INT);
        IERC20 _rewardToken = pairManager.getBaseAsset();
        _rewardToken.approve(address(spotHouse), type(uint256).max);
    }

    function rewardToken() public view returns (IERC20){
        return pairManager.getBaseAsset();
    }

    function getReserveInAmount1ByLP(uint256 lp) public view returns (uint256 amount) {
        IUniswapV2Pair pair = getSwappingPair();
        uint256 balance0 = posi.balanceOf(address(pair));
        uint256 balance1 = busd.balanceOf(address(pair));
        uint256 _totalSupply = pair.totalSupply();
        uint256 amount0 = lp.mul(balance0) / _totalSupply;
        uint256 amount1 = lp.mul(balance1) / _totalSupply;
        // convert amount0 -> amount1
        amount = amount1.add(amount0.mul(balance1).div(balance0));
    }

    /**
    * return lp Needed to get back total amount in amount 1
    * exp. amount = 1000 BUSD
    * lpNeeded returns 10
    * once remove liquidity, 10 LP will get back 500 BUSD and an amount in POSI corresponding to 500 BUSD
    */
    function getLPTokenByAmount1(uint256 amount) internal view returns (uint256 lpNeeded) {
        (, uint256 res1,) = getSwappingPair().getReserves();
        lpNeeded = amount.mul(getSwappingPair().totalSupply()).div(res1).div(2);
    }

    /**
    * return lp Needed to get back total amount in amount 0
    * exp. amount = 1000 POSI
    * lpNeeded returns 10
    * once remove liquidity, 10 LP will get back 500 POSI and an amount in BUSD corresponding to 500 POSI
    */
    function getLPTokenByAmount0(uint256 amount) internal view returns (uint256 lpNeeded) {
        uint256 res0 = res0Snapshots.getReserveTwapPrice(3 days);
        lpNeeded = amount.mul(getSwappingPair().totalSupply()).div(res0).div(2);
    }

    function deposit(uint256 amount, address referrer) external updateReward(msg.sender) nonReentrant noCallFromContract waitForCompound {
        // function to deposit BUSD
        busd.transferFrom(msg.sender, address(this), amount);
        (, uint256 res1,) = getSwappingPair().getReserves();
        uint256 amountToSwap = SwapMath.calculateSwapInAmount(res1, amount);
        uint256 posiOut = swapBusdToPosi(amountToSwap);
        uint256 amountLeft = amount.sub(amountToSwap);
        (,uint256 busdAdded,uint256 liquidityAmount) = router.addLiquidity(
            address(posi),
            address(busd),
            posiOut,
            amountLeft,
            0,
            0,
            address(this),
            block.timestamp
        );
        _depositLP(msg.sender, liquidityAmount, referrer);
        // trasnfer back amount left
        if(amount > busdAdded+amountToSwap){
            busd.transfer(msg.sender, amount - (busdAdded + amountToSwap));
        }
    }

    function depositTokenPair(uint256 amountPosi, uint256 amountBusd, address referrer) external updateReward(msg.sender) nonReentrant noCallFromContract waitForCompound {
        busd.transferFrom(msg.sender, address(this), amountBusd);
        uint256 balanceOfPosiBeforeTrasnfer = posi.balanceOf(address(this));
        posi.transferFrom(msg.sender, address(this), amountPosi);
        uint256 balanceOfPosiAfterTransfer = posi.balanceOf(address(this));
        uint256 amountPosiReceived = balanceOfPosiAfterTransfer - balanceOfPosiBeforeTrasnfer;
        // note posiAdded is might reduced by ~1%
        (uint256 posiAdded, uint256 busdAdded, uint256 liquidityAmount) = router.addLiquidity(
            address(posi),
            address(busd),
            amountPosiReceived,
            amountBusd,
            0,
            0,
            address(this),
            block.timestamp
        );
        // transfer back amount that didn't add to the pool
        if(amountPosiReceived.mul(99).div(100) > posiAdded){
            uint256 amountLeft = amountPosiReceived.mul(99).div(100) - posiAdded;
            if(posi.balanceOf(address(this)) >= amountLeft)
                posi.transfer(msg.sender, amountLeft);
        }
        if(amountBusd > busdAdded){
            busd.transfer(msg.sender, amountBusd - busdAdded);
        }
        _depositLP(msg.sender, liquidityAmount, referrer);
    }

    function depositLP(uint256 amount, address referrer) external updateReward(msg.sender) nonReentrant noCallFromContract waitForCompound {
        getSwappingPair().transferFrom(msg.sender, address(this), amount);
        _depositLP(msg.sender, amount, referrer);
    }

    function _depositLP(address account, uint256 liquidityAmount, address referrer) internal {
        if (
            address(positionReferral) != address(0) &&
            referrer != address(0) &&
            referrer != account
        ) {
            positionReferral.recordReferral(account, referrer);
        }
        //stake in farms
        depositStakingPool(liquidityAmount);
        //set state
        userInfo[account].deposit(liquidityAmount);
        totalSupply = totalSupply.add(liquidityAmount);
        emit Deposit(account, liquidityAmount);
    }

    function withdraw(uint256 amount, bool isReceiveBusd) external updateReward(msg.sender) nonReentrant noCallFromContract waitForCompound {
        uint256 lpAmountNeeded;
        if(amount >= balanceOf(msg.sender)){
            // withdraw all
            lpAmountNeeded = lpOf(msg.sender);
        }else{
            //calculate LP needed that corresponding with amount
            lpAmountNeeded = getLPTokenByAmount1(amount);
            if(lpAmountNeeded >= lpOf(msg.sender)){
                // if >= current lp, use all lp
                lpAmountNeeded = lpOf(msg.sender);
            }
        }
        //withdraw from farm then remove liquidity
        posiStakingManager.withdraw(POSI_BUSD_PID, lpAmountNeeded);
        (uint256 amountA,uint256 amountB) = removeLiquidity(lpAmountNeeded);
        if(isReceiveBusd){
            // send as much as we can
            // doesn't guarantee enough $amount
            busd.transfer(msg.sender, swapPosiToBusd(amountA).add(amountB));
        }else{
            posi.transfer(msg.sender, amountA);
            busd.transfer(msg.sender, amountB);
        }
        // update state
        userInfo[msg.sender].withdraw(lpAmountNeeded);
        totalSupply = totalSupply.sub(lpAmountNeeded);
        emit Withdraw(msg.sender, lpAmountNeeded);
    }

    function withdrawLP(uint256 lpAmount) external updateReward(msg.sender) nonReentrant waitForCompound {
        require(userInfo[msg.sender].amount >= lpAmount, "INSUFFICIENT_LP");
        posiStakingManager.withdraw(POSI_BUSD_PID, lpAmount);
        getSwappingPair().transfer(msg.sender, lpAmount);
        userInfo[msg.sender].withdraw(lpAmount);
        emit Withdraw(msg.sender, lpAmount);
    }

    // emergency only! withdraw don't care about rewards
    function emergencyWithdraw(uint256 lpAmount) external nonReentrant waitForCompound {
        require(userInfo[msg.sender].amount >= lpAmount, "INSUFFICIENT_LP");
        posiStakingManager.withdraw(POSI_BUSD_PID, lpAmount);
        getSwappingPair().transfer(msg.sender, lpAmount);
        userInfo[msg.sender].withdraw(lpAmount);
        emit Withdraw(msg.sender, lpAmount);
    }

    function getLpNeeded(address user) public view returns (uint256) {
        uint256 reward = earned(user);
        reward = _convertEarnedTokenToPOSI(reward);
        return getLPTokenByAmount0(reward);
    }

    function harvest(bool isReceiveBusd) external updateReward(msg.sender) nonReentrant noCallFromContract waitForCompound {
        // function to harvest rewards
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            userInfo[msg.sender].harvest(block.number);
            // convert reward token to POSI
            reward = _convertEarnedTokenToPOSI(reward);
            //get corresponding amount in LP
            uint256 lpNeeded = getLPTokenByAmount0(reward);
            posiStakingManager.withdraw(POSI_BUSD_PID, lpNeeded);
            if(isReceiveBusd){
                // send 5% only
                // then lock 95%
                _addSchedules(msg.sender, lpNeeded.mul(95).div(100));
                lpNeeded = lpNeeded.mul(5).div(100);
            }
            (uint256 amountPosi,uint256 amountBusd) = removeLiquidity(lpNeeded);
            if(isReceiveBusd) {
                router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    amountPosi,
                    0,
                    getPosiBusdRoute(),
                    msg.sender,
                    block.timestamp
                );
                busd.transfer(msg.sender, amountBusd);
            }else{
                router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    amountBusd,
                    0,
                    getBusdPosiRoute(),
                    msg.sender,
                    block.timestamp
                );
                posi.transfer(msg.sender, amountPosi);
            }
            payReferralCommission(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function compound() external updateReward(address(0)) nonReentrant {
        // function to compound for pool
        bool _canCompound  = canCompound();
        if (_canCompound) {
            lastCompoundRewardPerToken = pendingRewardPerToken();
            // harvesting by deposit 0
            depositStakingPool(0);
            uint256 amountCollected = rewardToken().balanceOf(address(this));
            uint256 rewardForCaller = amountCollected.mul(percentFeeForCompounding).div(1000);
            // burn %
            uint256 rewardForPool = amountCollected.sub(rewardForCaller);
            // swap -> add liquidity -> stake back to pool
            // convert Reward Token -> POSI
            uint256 posiRewardForPool = _convertRewardTokenToPosi(rewardForPool);
            if(posiRewardForPool > 0){
                (uint256 res0,,) = getSwappingPair().getReserves();
                uint256 posiAmountToSwap = SwapMath.calculateSwapInAmount(res0, posiRewardForPool);
                uint256 busdOut = swapPosiToBusd(posiAmountToSwap);
                (res0,,) = getSwappingPair().getReserves();
                res0Snapshots.addReserveSnapshot(uint128(res0));
                (,, uint256 liquidityAmount) = router.addLiquidity(
                    address(posi),
                    address(busd),
                    posiRewardForPool.sub(posiAmountToSwap),
                    busdOut,
                    0,
                    0,
                    address(this),
                    block.timestamp
                );
                depositStakingPool(liquidityAmount);
            }
            if(rewardForCaller > 0)
                posi.transfer(msg.sender, rewardForCaller);
            lastUpdatePoolPendingReward = 0;
            emit Compound(msg.sender, posiRewardForPool);
        }else{
            revert("not time to compound");
        }
    }

    function resetUpdatePoolReward() external onlyOwner {
        lastUpdatePoolPendingReward = 0;
    }

    function pendingPositionNextCompound() public view returns (uint256){
        return posiStakingManager.pendingPosition(POSI_BUSD_PID, address(this)).mul(5).div(100);
    }

    function rewardForCompounder() external view returns (uint256){
        // only 5%
        return pendingPositionNextCompound().mul(percentFeeForCompounding).div(1000);
    }

    function payReferralCommission(address _user, uint256 _pending) internal {
        if (
            address(positionReferral) != address(0)
            && referralCommissionRate > 0
        ) {
            address referrer = positionReferral.getReferrer(_user);
            uint256 commissionAmount = _pending.mul(referralCommissionRate).div(
                10000
            );
            if (referrer != address(0) && commissionAmount > 0) {
                if(vaultReferralTreasury.payReferralCommission(referrer, commissionAmount))
                    emit ReferralCommissionPaid(_user, referrer, commissionAmount);
            }
        }
    }

    function swapBusdToPosi(uint256 amountToSwap) internal returns (uint256 amountOut) {
        uint256 posiBalanceBefore = posi.balanceOf(address(this));
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            getBusdPosiRoute(),
            address(this),
            block.timestamp
        );
        amountOut = posi.balanceOf(address(this)).sub(posiBalanceBefore);
    }

    function swapPosiToBusd(uint256 amountToSwap) internal returns (uint256 amountOut) {
        uint256 busdBalanceBefore = busd.balanceOf(address(this)); // remove for testing
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            getPosiBusdRoute(),
            address(this),
            block.timestamp
        );
        amountOut = busd.balanceOf(address(this)).sub(busdBalanceBefore);
    }

    function removeLiquidity(uint256 lpAmount) internal returns (uint256 amountPosi, uint256 amountBusd){
        uint256 posiBalanceBefore = posi.balanceOf(address(this));
        (,amountBusd) = router.removeLiquidity(
            address(posi),
            address(busd),
            lpAmount,
            0,
            0,
            address(this),
            block.timestamp
        );
        amountPosi = posi.balanceOf(address(this)).sub(posiBalanceBefore);
    }

    function depositStakingPool(uint256 amount) internal {
        posiStakingManager.deposit(POSI_BUSD_PID, amount, address(vaultReferralTreasury));
    }


    function getBusdPosiRoute() private view returns (address[] memory paths) {
        paths = new address[](2);
        paths[0] = address(busd);
        paths[1] = address(posi);
    }

    function getPosiBusdRoute() private view returns (address[] memory paths) {
        paths = new address[](2);
        paths[0] = address(posi);
        paths[1] = address(busd);
    }


    function getTwapPip(uint256 itv) public view returns (uint256){
        return reserveSnapshots.getReserveTwapPrice(itv);
    }

    function getTwapRes0(uint256 itv) public view returns (uint256){
        return res0Snapshots.getReserveTwapPrice(itv);
    }

    function __SpotManagerModule_init(address _spotHouse, address _pairManager) internal {
        spotHouse = ISpotHouse(_spotHouse);
        pairManager = IPairManager(_pairManager);
    }

    function _sellRewardTokenForPOSI(uint256 _amount) internal returns (uint256 posiAmount) {
        IERC20 _posi = pairManager.getQuoteAsset();
        uint256 _balanceBefore = _posi.balanceOf(address(this));
        spotHouse.openMarketOrder(pairManager, ISpotHouse.Side.SELL, _amount);
        uint128 _pipAfter = pairManager.getCurrentPip();
        reserveSnapshots.addReserveSnapshot(10000);
        uint256 _balanceAfter = _posi.balanceOf(address(this));
        posiAmount = _balanceAfter - _balanceBefore;
    }


    function _convertRewardTokenToPosi(uint256 rewardAmount) private returns (uint256 posiAmount) {
        if(rewardAmount == 0) return 0;
        // sell market reward token for posi
        return _sellRewardTokenForPOSI(rewardAmount);
    }

    function _transferLockedToken(address _to, uint192 _amount) internal override {
        (uint256 amountPosi,uint256 amountBusd) = removeLiquidity(_amount);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountPosi,
            0,
            getPosiBusdRoute(),
            _to,
            block.timestamp
        );
        busd.transfer(_to, amountBusd);
    }

    function _getVestingSchedules(address user, VestingFrequencyHelper.Frequency freq) internal view override returns (VestingData[] memory) {
        return  vestingSchedule[user][freq];
    }

    // override by convert amount to token 1
    function getVestingSchedules(address user, VestingFrequencyHelper.Frequency freq) public override view returns (VestingData[] memory) {
        VestingData[] memory data = vestingSchedule[user][freq];
        for(uint i = 0; i < data.length; i++) {
            data[i].amount = uint192(getReserveInAmount1ByLP(uint256(data[i].amount)));
        }
        return data;
    }

    function init_v2(address newSpotHouse, address newSpotManager, address newStakingManager) public onlyOwner {
        __SpotManagerModule_init(newSpotHouse, newSpotManager);
        IPosiStakingManager oldStakingManager = posiStakingManager;
        posiStakingManager = IPosiStakingManager(newStakingManager);
        approve();
        reserveSnapshots.add(pairManager.getCurrentPip(), uint64(block.timestamp), uint64(block.number));
        (uint256 res0,,) = getSwappingPair().getReserves();
        res0Snapshots.add(uint128(res0), uint64(block.timestamp), uint64(block.number));
        (uint256 stakingAmount,,,) = oldStakingManager.userInfo(POSI_BUSD_PID, address(this));
        // withdraw old one
        oldStakingManager.withdraw(POSI_BUSD_PID, stakingAmount);
        // deposit new one
        posiStakingManager.deposit(POSI_BUSD_PID, stakingAmount, address(vaultReferralTreasury));
    }

    function correctReserves(uint256 fromIndex, uint256 toIndex, uint256[] memory pips) public onlyOwner {
        uint256 j = 0;
        for(uint256 i = fromIndex; i < toIndex; i++){
            reserveSnapshots[i].pip = uint128(pips[j]);
            j++;
        }
    }

    // Vesting override

    function _removeFirstSchedule(address user, VestingFrequencyHelper.Frequency freq) internal override {
        _popFirstSchedule(vestingSchedule[user][freq]);
    }

    function _lockVestingSchedule(address _to, VestingFrequencyHelper.Frequency _freq, uint256 _amount) internal override {
        vestingSchedule[_to][_freq].push(_newVestingData(_amount, _freq));
    }
    // use for mocking test
    function _setVestingTime(address user, uint8 freq, uint256 index, uint256 timestamp) internal {
        vestingSchedule[user][VestingFrequencyHelper.Frequency(freq)][index].vestingTime = uint64(timestamp);
    }

    function _convertEarnedTokenToPOSI(uint256 _baseAmount) private view returns (uint256){
        (,uint128 _basisPoint) = pairManager.getCurrentPipAndBasisPoint();
        // Twap 3 days
        uint256 _twapPip = getTwapPip(259200);
        return uint256(uint128(_baseAmount) * uint128(_twapPip) / _basisPoint);
    }
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
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

pragma solidity ^0.8.0;

import "./library/VestingFrequencyHelper.sol";

abstract contract VestingScheduleLogic {
    using VestingFrequencyHelper for VestingFrequencyHelper.Frequency;
    struct VestingData {
        uint64 vestingTime;
        uint192 amount;
    }

    event WhiteListVestingChanged(address indexed _address, bool _isWhiteListVesting);

    function getVestingSchedules(address user, VestingFrequencyHelper.Frequency freq) public virtual view returns (VestingData[] memory){
        return _getVestingSchedules(user, freq);
    }
    function _getVestingSchedules(address user, VestingFrequencyHelper.Frequency freq) internal virtual view returns (VestingData[] memory);

    function claimVesting(VestingFrequencyHelper.Frequency freq, uint256 index) public virtual {
        bool success = _claimVesting(msg.sender, freq, index);
        require(success, "claimVesting: failed");
    }

    function claimVestingBatch(VestingFrequencyHelper.Frequency[] memory freqs, uint256[] memory index) public virtual {
        for(uint256 i = 0; i < freqs.length; i++) {
            _claimVesting(msg.sender, freqs[i], index[i]);
        }
    }

    function _claimVesting(address user, VestingFrequencyHelper.Frequency freq, uint256 index) internal returns (bool success) {
        VestingData[] memory vestingSchedules = _getVestingSchedules(user, freq);
        require(index < vestingSchedules.length, "claimVesting: index out of range");
        for (uint256 i = 0; i <= index; i++) {
            VestingData memory schedule = vestingSchedules[i];
            if(block.timestamp >= schedule.vestingTime){
                // remove the vesting schedule
                _removeFirstSchedule(user, freq);
                // transfer locked token
                _transferLockedToken(user, schedule.amount);
            }else{
                // don't need to shift to the next schedule
                // because the vesting schedule is sorted by timestamp
                return false;
            }
        }
        return true;
    }

    function _addSchedules(address _to, uint256 _amount) internal virtual {
        // receive 5% after 1 day
        _lockVestingSchedule(_to, VestingFrequencyHelper.Frequency.Daily, _amount * 5 / 100);
        // receive 10% after 7 days
        _lockVestingSchedule(_to, VestingFrequencyHelper.Frequency.Weekly, _amount * 10 / 100);
        // receive 10% after 30 days
        _lockVestingSchedule(_to, VestingFrequencyHelper.Frequency.Monthly, _amount * 10 / 100);
        // receive 20% after 60 days
        _lockVestingSchedule(_to, VestingFrequencyHelper.Frequency.Bimonthly, _amount * 20 / 100);
        // receive 20% after 90 days
        _lockVestingSchedule(_to, VestingFrequencyHelper.Frequency.Quarterly, _amount * 20 / 100);
        // receive 30% after 180 days
        _lockVestingSchedule(_to, VestingFrequencyHelper.Frequency.Biannually, _amount * 30 / 100);
    }

    function _popFirstSchedule(VestingData[] storage schedules) internal {
        for (uint256 i = 0; i < schedules.length-1; i++) {
            schedules[i] = schedules[i + 1];
        }
        schedules.pop();
    }

    function _newVestingData(uint256 _amount, VestingFrequencyHelper.Frequency _freq) internal view returns (VestingData memory) {
        return VestingData({
            amount: uint192(_amount),
            vestingTime: uint64(_freq.toTimestamp())
        });
    }

    function _removeFirstSchedule(address user, VestingFrequencyHelper.Frequency freq) internal virtual;
    function _lockVestingSchedule(address _to, VestingFrequencyHelper.Frequency _freq, uint256 _amount) internal virtual;
    function _transferLockedToken(address _to, uint192 _amount) internal virtual;
}

pragma solidity 0.8.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IPosiStakingManager {
    function setDevAddress(address _devAddress) external;
    function pendingPosition(uint256 _pid, address _user)
    external
    view
    returns (uint256);

    function canHarvest(uint256 _pid, address _user)
    external
    view
    returns (bool);

    function deposit(
        uint256 _pid,
        uint256 _amount,
        address _referrer
    ) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function emergencyWithdraw(uint256 _pid) external;

    function poolInfo(uint256 _pid) external view returns (
        address lpToken,
        uint256 allocPoint,
        uint256 lastRewardBlock,
        uint256 accPositionPerShare,
        uint16 depositFeeBP,
        uint256 harvestInterval
    );

    function userInfo(uint256 _pid, address _user) external view returns (
        uint256 amount,
        uint256 rewardDebt,
        uint256 rewardLockedUp,
        uint256 nextHarvestUntil
    );

    function totalAllocPoint() external view returns (uint256);

    function positionPerBlock() external view returns (uint256);



}

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

library UserInfo {
    using SafeMath for uint256;
    struct Data {
        uint256 amount;
        // packing slot
        uint128 rewards;
        uint128 latestHarvestBlockNumber;
        uint128 pendingRewardPerTokenPaid;
        uint128 pendingRewards;
    }

    function deposit(
        UserInfo.Data storage data,
        uint256 amount
    ) internal {
        if(data.amount < 1e14){
            // mean no deposit token yet
            data.latestHarvestBlockNumber = uint128(block.number);
        }
        data.amount = data.amount.add(amount);
    }

    function withdraw(
        UserInfo.Data storage data,
        uint256 amount
    ) internal {
        data.amount = data.amount.sub(amount);
    }

    function updateEarnedRewards(
        UserInfo.Data storage data,
        uint256 amount
    ) internal {
        data.rewards = uint128(amount);
    }

    function harvest(
        UserInfo.Data storage data,
        uint256 blockNumber
    ) internal {
        data.rewards = 0;
        data.latestHarvestBlockNumber = uint128(blockNumber);
    }

    function updatePendingReward(
        UserInfo.Data storage data,
        uint256 rewards,
        uint256 rewardPerTokenPaid
    ) internal {
        data.pendingRewards = uint128(rewards);
        data.pendingRewardPerTokenPaid = uint128(rewardPerTokenPaid);
    }

}

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

library  SwapMath {
    using SafeMath for uint256;
    // following: https://blog.alphafinance.io/onesideduniswap/
    // applying f = 0.25% in PancakeSwap
    // we got these numbers
    function calculateSwapInAmount(uint256 reserveIn, uint256 userIn)
    internal
    pure
    returns (uint256)
    {
        return
        sqrt(
            reserveIn.mul(userIn.mul(399000000) + reserveIn.mul(399000625))
        )
        .sub(reserveIn.mul(19975)) / 19950;
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
        // else z = 0
    }
}

pragma solidity 0.8.2;

library TwapLogic {
    enum TwapCalcOption {
        RESERVE_ASSET,
        INPUT_ASSET
    }

    struct TwapPriceCalcParams {
        TwapCalcOption opt;
        uint256 snapshotIndex;
    }
    struct ReserveSnapshot {
        uint128 pip;
        uint64 timestamp;
        uint64 blockNumber;
    }

    function add(ReserveSnapshot[] storage reserveSnapshots, uint128 pip, uint64 timestamp, uint64 blockNumber) internal {
        reserveSnapshots.push(ReserveSnapshot({
            pip: pip,
            timestamp: timestamp,
            blockNumber: blockNumber
        }));
    }

    function addReserveSnapshot(ReserveSnapshot[] storage reserveSnapshots, uint128 pip) internal {
        uint64 currentBlock = uint64(block.number);
        ReserveSnapshot memory latestSnapshot = reserveSnapshots[
            reserveSnapshots.length - 1
        ];
        if (currentBlock == latestSnapshot.blockNumber) {
            reserveSnapshots[reserveSnapshots.length - 1].pip = pip;
        } else {
            reserveSnapshots.push(
                ReserveSnapshot(pip, _now(), currentBlock)
            );
        }
    }

    function getReserveTwapPrice(ReserveSnapshot[] storage reserveSnapshots, uint256 _intervalInSeconds)
    internal
    view
    returns (uint256)
    {
        TwapPriceCalcParams memory params;
        // Can remove this line
        params.opt = TwapCalcOption.RESERVE_ASSET;
        params.snapshotIndex = reserveSnapshots.length - 1;
        return calcTwap(reserveSnapshots, params, _intervalInSeconds);
    }

    function calcTwap(
        ReserveSnapshot[] storage reserveSnapshots,
        TwapPriceCalcParams memory _params,
        uint256 _intervalInSeconds
    ) public view returns (uint256) {
        uint256 currentPrice = _getPriceWithSpecificSnapshot(reserveSnapshots, _params);
        if (_intervalInSeconds == 0) {
            return currentPrice;
        }

        uint256 baseTimestamp = _now() - _intervalInSeconds;
        ReserveSnapshot memory currentSnapshot = reserveSnapshots[
            _params.snapshotIndex
        ];
        // return the latest snapshot price directly
        // if only one snapshot or the timestamp of latest snapshot is earlier than asking for
        if (
            reserveSnapshots.length == 1 ||
            currentSnapshot.timestamp <= baseTimestamp
        ) {
            return currentPrice;
        }

        uint256 previousTimestamp = currentSnapshot.timestamp;
        // period same as cumulativeTime
        uint256 period = _now() - previousTimestamp;
        uint256 weightedPrice = currentPrice * period;
        while (true) {
            // if snapshot history is too short
            if (_params.snapshotIndex == 0) {
                return weightedPrice / period;
            }

            _params.snapshotIndex = _params.snapshotIndex - 1;
            currentSnapshot = reserveSnapshots[_params.snapshotIndex];
            currentPrice = _getPriceWithSpecificSnapshot(reserveSnapshots, _params);

            // check if current snapshot timestamp is earlier than target timestamp
            if (currentSnapshot.timestamp <= baseTimestamp) {
                // weighted time period will be (target timestamp - previous timestamp). For example,
                // now is 1000, _intervalInSeconds is 100, then target timestamp is 900. If timestamp of current snapshot is 970,
                // and timestamp of NEXT snapshot is 880, then the weighted time period will be (970 - 900) = 70,
                // instead of (970 - 880)
                weightedPrice =
                weightedPrice +
                (currentPrice * (previousTimestamp - baseTimestamp));
                break;
            }

            uint256 timeFraction = previousTimestamp -
            currentSnapshot.timestamp;
            weightedPrice = weightedPrice + (currentPrice * timeFraction);
            period = period + timeFraction;
            previousTimestamp = currentSnapshot.timestamp;
        }
        return weightedPrice / _intervalInSeconds;
    }

    function _now() private view returns (uint64) {
        return uint64(block.timestamp);
    }

    function _getPriceWithSpecificSnapshot(ReserveSnapshot[] storage reserveSnapshots, TwapPriceCalcParams memory _params)
        internal
        view
        returns (uint256)
    {
        return (reserveSnapshots[_params.snapshotIndex].pip);
    }
}

pragma solidity >=0.6.0 <=0.8.4;

interface IPositionReferral{

    /**
     * @dev Record referral.
     */
    function recordReferral(address user, address referrer) external;

    /**
     * @dev Record referral commission.
     */
    function recordReferralCommission(address referrer, uint256 commission) external;

    /**
     * @dev Get the referrer address that referred the user.
     */
    function getReferrer(address user) external view returns (address);
}

pragma solidity ^0.8.0;

interface IVaultReferralTreasury {
    function payReferralCommission(address _address, uint256 _rewards) external returns (bool);
}

import "./IPairManager.sol";
interface ISpotHouse {
    enum Side {
        BUY,
        SELL
    }
    function openLimitOrder(
        IPairManager _spotManager,
        Side _side,
        uint256 _quantity,
        uint128 _pip
    ) external payable;

    function openBuyLimitOrderExactInput(
        IPairManager pairManager,
        Side side,
        uint256 quantity,
        uint128 pip
    ) external payable;

    function openMarketOrder(
        IPairManager _spotManager,
        Side _side,
        uint256 _quantity
    ) external payable;

    function openMarketOrderWithQuote(
        IPairManager _pairManager,
        Side _side,
        uint256 _quoteAmount
    ) external payable;

    function cancelLimitOrder(
        IPairManager _spotManager,
        uint64 _orderIdx,
        uint128 _pip
    ) external;

    function claimAsset(IPairManager _spotManager) external;

    function getAmountClaimable(IPairManager _spotManager, address _trader)
    external
    view
    returns (
        uint256 quoteAsset,
        uint256 baseAsset
    //            uint256 feeQuoteAmount,
    //            uint256 feeBaseAmount
    );

    function cancelAllLimitOrder(IPairManager _spotManager) external;

    function setFactory(address _factoryAddress) external;

    function updateFee(uint16 _fee) external;

    function openMarketOrder(
        IPairManager _pairManager,
        Side _side,
        uint256 _quantity,
        address _payer,
        address _recipient
    ) external payable returns (uint256[] memory);

    function openMarketOrderWithQuote(
        IPairManager _pairManager,
        Side _side,
        uint256 _quoteAmount,
        address _payer,
        address _recipient
    ) external payable returns (uint256[] memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
                /// @solidity memory-safe-assembly
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
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

library VestingFrequencyHelper {
    enum Frequency {
        Daily, // 1 days
        Weekly, // 7 days
        Monthly, // 30 days
        Bimonthly, // 2 months
        Quarterly, // 3 months
        Biannually // 6 months
    }

    function toTimestamp(Frequency _freq) internal view returns (uint256) {
        if (_freq == Frequency.Daily) {
            return block.timestamp + 86400;
        } else if (_freq == Frequency.Weekly) {
            return block.timestamp + 604800;
        } else if (_freq == Frequency.Monthly) {
            return block.timestamp + 2592000;
        } else if (_freq == Frequency.Bimonthly) {
            return block.timestamp + 5184000;
        } else if (_freq == Frequency.Quarterly) {
            return block.timestamp + 7776000;
        } else if (_freq == Frequency.Biannually) {
            return block.timestamp + 182 days;
        }
        return 0;
    }

}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IPairManager {
    event MarketFilled(
        bool isBuy,
        uint256 indexed amount,
        uint128 toPip,
        uint256 startPip,
        uint128 remainingLiquidity,
        uint64 filledIndex
    );
    event LimitOrderCreated(
        uint64 orderId,
        uint128 pip,
        uint128 size,
        bool isBuy
    );

    event PairManagerInitialized(

        address quoteAsset,
        address baseAsset,
        address counterParty,
        uint256 basisPoint,
        uint256 BASE_BASIC_POINT,
        uint128 maxFindingWordsIndex,
        uint128 initialPip,
        uint64 expireTime,
        address owner
    );
    event LimitOrderCancelled(
        bool isBuy,
        uint64 orderId,
        uint128 pip,
        uint256 size
    );

    event UpdateMaxFindingWordsIndex(
        address spotManager,
        uint128 newMaxFindingWordsIndex
    );

    event MaxWordRangeForLimitOrderUpdated(
        uint128 newMaxWordRangeForLimitOrder
    );
    event MaxWordRangeForMarketOrderUpdated(
        uint128 newMaxWordRangeForMarketOrder
    );
    event UpdateBasisPoint(address spotManager, uint256 newBasicPoint);
    event UpdateBaseBasicPoint(address spotManager, uint256 newBaseBasisPoint);
    event ReserveSnapshotted(uint128 pip, uint256 timestamp);
    event LimitOrderUpdated(
        address spotManager,
        uint64 orderId,
        uint128 pip,
        uint256 size
    );
    event UpdateExpireTime(address spotManager, uint64 newExpireTime);
    event UpdateCounterParty(address spotManager, address newCounterParty);
    event LiquidityPoolAllowanceUpdate(address liquidityPool, bool value);
    //    event Swap(
    //        address account,
    //        uint256 indexed amountIn,
    //        uint256 indexed amountOut
    //    );

    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    struct ExchangedData {
        uint256 baseAmount;
        uint256 quoteAmount;
        uint256 feeQuoteAmount;
        uint256 feeBaseAmount;
    }

    struct AccPoolExchangedDataParams {
        bytes32 orderId;
        int128 baseAdjust;
        int128 quoteAdjust;
        //        int128 baseFilledCurrentPip;
        uint128 currentPip;
        uint256 basisPoint;
        //        // cumulative price*quantity buy orders
        //        uint128 cumPQ;
        //        // cumulative quantity
        //        uint128 cumQ;
    }

    function initializeFactory(
        address _quoteAsset,
        address _baseAsset,
        address _counterParty,
        uint256 _basisPoint,
        uint256 _BASE_BASIC_POINT,
        uint128 _maxFindingWordsIndex,
        uint128 _initialPip,
        uint64 _expireTime,
        address _owner,
        address _liquidityPool
    ) external;

    function openLimit(
        uint128 pip,
        uint128 size,
        bool isBuy,
        address trader,
        uint256 quoteDeposited
    )
        external
        returns (
            uint64 orderId,
            uint256 sizeOut,
            uint256 openNotional
        );

    function calculatingQuoteAmount(uint256 quantity, uint128 pip)
        external
        view
        returns (uint256);

    function cancelLimitOrder(uint128 pip, uint64 orderId)
        external
        returns (uint256 size, uint256 partialFilled);

    function updatePartialFilledOrder(uint128 pip, uint64 orderId) external;

    function getPendingOrderDetail(uint128 pip, uint64 orderId)
        external
        view
        returns (
            bool isFilled,
            bool isBuy,
            uint256 size,
            uint256 partialFilled
        );

    function getBasisPoint() external view returns (uint256);

    //    function isExpired() external returns (bool);

    function getBaseBasisPoint() external returns (uint256);

    function getCurrentPipAndBasisPoint()
        external
        view
        returns (uint128 currentPip, uint128 basisPoint);

    function getCurrentPip() external view returns (uint128);

    function getCurrentSingleSlot() external view returns (uint128, uint8);

    function getPrice() external view returns (uint256);

    function getQuoteAsset() external view returns (IERC20);

    function getBaseAsset() external view returns (IERC20);

    function pipToPrice(uint128 pip) external view returns (uint256);

    function getLiquidityInCurrentPip() external view returns (uint128);

    function hasLiquidity(uint128 pip) external view returns (bool);

    function updateMaxFindingWordsIndex(uint128 _newMaxFindingWordsIndex)
        external;

    //    function updateBasisPoint(uint256 _newBasisPoint) external;
    //
    //    function updateBaseBasicPoint(uint256 _newBaseBasisPoint) external;

    //    function updateExpireTime(uint64 _expireTime) external;

    function openMarket(
        uint256 size,
        bool isBuy,
        address _trader
    ) external returns (uint256 sizeOut, uint256 quoteAmount);

    function openMarketWithQuoteAsset(
        uint256 quoteAmount,
        bool isBuy,
        address trader
    ) external returns (uint256 sizeOutQuote, uint256 baseAmount);

    function getFee()
        external
        view
        returns (uint256 baseFeeFunding, uint256 quoteFeeFunding);

    function resetFee(uint256 baseFee, uint256 quoteFee) external;

    function increaseBaseFeeFunding(uint256 baseFee) external;

    function increaseQuoteFeeFunding(uint256 quoteFee) external;

    function decreaseBaseFeeFunding(uint256 baseFee) external;

    function decreaseQuoteFeeFunding(uint256 quoteFee) external;

    function quoteToBase(uint256 quoteAmount, uint128 pip)
        external
        view
        returns (uint256);

    function accumulatePoolExchangedData(
        bytes32[256] memory _orderIds,
        uint16 feeShareRatio,
        uint128 feeBase,
        int128 soRemovablePosBuy,
        int128 soRemovablePosSell
    ) external view returns (int128 quoteAdjust, int128 baseAdjust);

    function accumulateClaimableAmount(
        uint128 _pip,
        uint64 _orderId,
        IPairManager.ExchangedData memory exData,
        uint256 basisPoint,
        uint16 fee,
        uint128 feeBasis
    ) external view returns (IPairManager.ExchangedData memory);

    function accumulatePoolLiquidityClaimableAmount(
        uint128 _pip,
        uint64 _orderId,
        IPairManager.ExchangedData memory exData,
        uint256 basisPoint,
        uint16 fee,
        uint128 feeBasis
    ) external returns (IPairManager.ExchangedData memory, bool isFilled);

    //    function claimAmountFromLiquidityPool(
    //        uint256 quoteAmount,
    //        uint256 baseAmount,
    //        address user
    //    ) external;

    function collectFund(
        IERC20 token,
        address to,
        uint256 amount
    ) external;

    function updateSpotHouse(address _newSpotHouse) external;

    function getAmountEstimate(
        uint256 size,
        bool isBuy,
        bool isBase
    ) external view returns (uint256 sizeOut, uint256 openOtherSide);
//
//    function receiveBNB() external payable ;
//    function withdrawBNB(address recipient, uint256 amount) external payable;


}