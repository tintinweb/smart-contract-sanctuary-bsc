pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "./interfaces/IUniswapV2Router.sol";
import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IMasterChef.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/ITokiePool.sol";
import "./libs/UserInfo.sol";
import "./libs/SwapMath.sol";
import "./libs/ITokieReferral.sol";

/*
A vault that helps users stake in TOKIE farms and pools more simply.
Supporting auto compound in Single Staking Pool.
*/

contract CompoundTokieVault is Initializable, ReentrancyGuardUpgradeable, OwnableUpgradeable {
    using SafeMath for uint256;
    using UserInfo for UserInfo.Data;

    // MAINNET
    IERC20 public tokie;
    IERC20 public token1;
    IUniswapV2Router02 public router;
    IUniswapV2Factory public factory;
    IMasterChef public masterchef;
    ITokieReferral public tokieReferral;
    uint256 public farmPid;

    uint256 public constant MAX_INT = 115792089237316195423570985008687907853269984665640564039457584007913129639935;

    mapping(address => UserInfo.Data) public userInfo;
    uint256 public totalSupply;
    uint256 public pendingRewardPerTokenStored;
    uint256 public lastUpdatePoolPendingReward;
    uint256 public lastCompoundRewardPerToken;

    uint256 public referralCommissionRate;
    uint256 public percentFeeForCompounding;

    ITokiePool public vaultReferralTreasury;

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

    function initialize(
        uint256 _farmPid,
        address _tokie,
        address _token1,
        address _router,
        address _factory,
        address _masterchef,
        address _vaultReferralTreasury
    ) public initializer {
        __ReentrancyGuard_init();
        __Ownable_init();
        farmPid = _farmPid;
        tokie = IERC20(_tokie);
        token1 = IERC20(_token1);
        router = IUniswapV2Router02(_router);
        factory = IUniswapV2Factory(_factory);
        masterchef = IMasterChef(_masterchef);
        vaultReferralTreasury = ITokiePool(_vaultReferralTreasury);
        percentFeeForCompounding = 10; //default 1%
    }

    function canCompound() public view returns (bool) {
        return masterchef.canHarvest(farmPid, address(this)) && pendingTokieNextCompound() > 0;
    }

    function nearestCompoundingTime() public view returns (uint256 time) {
        (,,,time) = masterchef.userInfo(farmPid, address(this));
    }

    function balanceOf(address user) public view returns (uint256) {
        return getReserveInAmount1ByLP(userInfo[user].amount);
    }

    function lpOf(address user) public view returns (uint256) {
        return userInfo[user].amount;
    }


    function totalPoolPendingRewards() public view returns (uint256) {
        (,,uint256 rewardLockedUp,) = masterchef.userInfo(farmPid, address(this));
        return masterchef.pendingTokie(farmPid, address(this)).add(rewardLockedUp);
    }

    function totalPoolAmount() public view returns (uint256 amount) {
        (amount,,,) = masterchef.userInfo(farmPid, address(this));
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
            factory.getPair(address(tokie), address(token1))
        );
    }

    function updateReferralTreasury(ITokiePool _treasury) external onlyOwner {
        vaultReferralTreasury = _treasury;
    }

    function updateTokieReferral(ITokieReferral _tokieReferral) external onlyOwner {
        tokieReferral = _tokieReferral;
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
        tokie.approve(address(masterchef), MAX_INT);
        tokie.approve(address(router), MAX_INT);
        token1.approve(address(router), MAX_INT);
        getSwappingPair().approve(address(masterchef), MAX_INT);
        getSwappingPair().approve(address(router), MAX_INT);
    }

    function getReserveInAmount1ByLP(uint256 lp) public view returns (uint256 amount) {
        IUniswapV2Pair pair = getSwappingPair();
        uint256 balance0 = tokie.balanceOf(address(pair));
        uint256 balance1 = token1.balanceOf(address(pair));
        uint256 _totalSupply = pair.totalSupply();
        uint256 amount0 = lp.mul(balance0) / _totalSupply;
        uint256 amount1 = lp.mul(balance1) / _totalSupply;
        // convert amount0 -> amount1
        amount = amount1.add(amount0.mul(balance1).div(balance0));
    }

    /**
    * return lp Needed to get back total amount in amount 1
    * exp. amount = 1000 token1
    * lpNeeded returns 10
    * once remove liquidity, 10 LP will get back 500 token1 and an amount in TOKIE corresponding to 500 token1
    */
    function getLPTokenByAmount1(uint256 amount) internal view returns (uint256 lpNeeded) {
        (, uint256 res1) = getPairReserves();
        lpNeeded = amount.mul(getSwappingPair().totalSupply()).div(res1).div(2);
    }

    /**
    * return lp Needed to get back total amount in amount 0
    * exp. amount = 1000 TOKIE
    * lpNeeded returns 10
    * once remove liquidity, 10 LP will get back 500 TOKIE and an amount in token1 corresponding to 500 TOKIE
    */
    function getLPTokenByAmount0(uint256 amount) internal view returns (uint256 lpNeeded) {
        (uint256 res0,) = getPairReserves();
        lpNeeded = amount.mul(getSwappingPair().totalSupply()).div(res0).div(2);
    }

    function deposit(uint256 amount, address referrer) external updateReward(msg.sender) nonReentrant noCallFromContract waitForCompound {
        // function to deposit token1
        token1.transferFrom(msg.sender, address(this), amount);
        (, uint256 res1) = getPairReserves();
        uint256 amountToSwap = SwapMath.calculateSwapInAmount(res1, amount);
        uint256 tokieOut = swapToken1ToTokie(amountToSwap);
        uint256 amountLeft = amount.sub(amountToSwap);
        (,uint256 token1Added,uint256 liquidityAmount) = router.addLiquidity(
            address(tokie),
            address(token1),
            tokieOut,
            amountLeft,
            0,
            0,
            address(this),
            block.timestamp
        );
        _depositLP(msg.sender, liquidityAmount, referrer);
        // trasnfer back amount left
        if(amount > token1Added+amountToSwap){
            token1.transfer(msg.sender, amount - (token1Added + amountToSwap));
        }
    }

    function depositTokenPair(
        uint256 amountTokie,
        uint256 amountToken1,
        address referrer
    ) external updateReward(msg.sender) nonReentrant noCallFromContract waitForCompound {
        token1.transferFrom(msg.sender, address(this), amountToken1);
        uint256 balanceOfTokieBeforeTrasnfer = tokie.balanceOf(address(this));
        tokie.transferFrom(msg.sender, address(this), amountTokie);
        uint256 balanceOfTokieAfterTransfer = tokie.balanceOf(address(this));
        uint256 amountTokieReceived = balanceOfTokieAfterTransfer - balanceOfTokieBeforeTrasnfer;
        // note tokieAdded is might reduced by ~1%
        (uint256 tokieAdded, uint256 token1Added, uint256 liquidityAmount) = router.addLiquidity(
            address(tokie),
            address(token1),
            amountTokieReceived,
            amountToken1,
            0,
            0,
            address(this),
            block.timestamp
        );
        // transfer back amount that didn't add to the pool
        if(amountTokieReceived.mul(99).div(100) > tokieAdded){
            uint256 amountLeft = amountTokieReceived.mul(99).div(100) - tokieAdded;
            if(tokie.balanceOf(address(this)) >= amountLeft)
                tokie.transfer(msg.sender, amountLeft);
        }
        if(amountToken1 > token1Added){
            token1.transfer(msg.sender, amountToken1 - token1Added);
        }
        _depositLP(msg.sender, liquidityAmount, referrer);
    }

    function depositLP(uint256 amount, address referrer) external updateReward(msg.sender) nonReentrant noCallFromContract waitForCompound {
        getSwappingPair().transferFrom(msg.sender, address(this), amount);
        _depositLP(msg.sender, amount, referrer);
    }

    function _depositLP(address account, uint256 liquidityAmount, address referrer) internal {
        if (
            address(tokieReferral) != address(0) &&
            referrer != address(0) &&
            referrer != account
        ) {
            tokieReferral.recordReferral(account, referrer);
        }
        //stake in farms
        depositStakingPool(liquidityAmount);
        //set state
        userInfo[account].deposit(liquidityAmount);
        totalSupply = totalSupply.add(liquidityAmount);
        emit Deposit(account, liquidityAmount);
    }

    function withdraw(uint256 amount, bool isReceiveToken1) external updateReward(msg.sender) nonReentrant noCallFromContract waitForCompound {
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
        masterchef.withdraw(farmPid, lpAmountNeeded);
        (uint256 amountA,uint256 amountB) = removeLiquidity(lpAmountNeeded);
        if(isReceiveToken1){
            // send as much as we can
            // doesn't guarantee enough $amount
            token1.transfer(msg.sender, swapTokieToToken1(amountA).add(amountB));
        }else{
            tokie.transfer(msg.sender, amountA);
            token1.transfer(msg.sender, amountB);
        }
        // update state
        userInfo[msg.sender].withdraw(lpAmountNeeded);
        totalSupply = totalSupply.sub(lpAmountNeeded);
        emit Withdraw(msg.sender, lpAmountNeeded);
    }

    function withdrawLP(uint256 lpAmount) external updateReward(msg.sender) nonReentrant waitForCompound {
        require(userInfo[msg.sender].amount >= lpAmount, "INSUFFICIENT_LP");
        masterchef.withdraw(farmPid, lpAmount);
        getSwappingPair().transfer(msg.sender, lpAmount);
        userInfo[msg.sender].withdraw(lpAmount);
        emit Withdraw(msg.sender, lpAmount);
    }

    // emergency only! withdraw don't care about rewards
    function emergencyWithdraw(uint256 lpAmount) external nonReentrant waitForCompound {
        require(userInfo[msg.sender].amount >= lpAmount, "INSUFFICIENT_LP");
        masterchef.withdraw(farmPid, lpAmount);
        getSwappingPair().transfer(msg.sender, lpAmount);
        userInfo[msg.sender].withdraw(lpAmount);
        emit Withdraw(msg.sender, lpAmount);
    }

    function harvest(bool isReceiveToken1) external updateReward(msg.sender) nonReentrant noCallFromContract waitForCompound {
        // function to harvest rewards
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            userInfo[msg.sender].harvest(block.number);
            //get corresponding amount in LP
            uint256 lpNeeded = getLPTokenByAmount0(reward);
            masterchef.withdraw(farmPid, lpNeeded);
            (uint256 amountTokie,uint256 amountToken1) = removeLiquidity(lpNeeded);
            if(isReceiveToken1) {
                router.swapExactTokensForTokens(
                    amountTokie,
                    0,
                    getTokieToken1Route(),
                    msg.sender,
                    block.timestamp
                );
                token1.transfer(msg.sender, amountToken1);
            }else{
                router.swapExactTokensForTokens(
                    amountToken1,
                    0,
                    getToken1TokieRoute(),
                    msg.sender,
                    block.timestamp
                );
                tokie.transfer(msg.sender, amountTokie);
            }
            payReferralCommission(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function compound() external updateReward(address(0)) nonReentrant {
        // function to compound for pool
        bool _canCompound = canCompound();
        if (_canCompound) {
            lastCompoundRewardPerToken = pendingRewardPerToken();
            // harvesting by deposit 0
            depositStakingPool(0);
            uint256 amountCollected = tokie.balanceOf(address(this));
            uint256 rewardForCaller = amountCollected.mul(percentFeeForCompounding).div(1000);
            uint256 rewardForPool = amountCollected.sub(rewardForCaller);
            // swap -> add liquidity -> stake back to pool
            (uint256 res0,) = getPairReserves();
            uint256 tokieAmountToSwap = SwapMath.calculateSwapInAmount(res0, rewardForPool);
            uint256 token1Out = swapTokieToToken1(tokieAmountToSwap);
            (,, uint256 liquidityAmount) = router.addLiquidity(
                address(tokie),
                address(token1),
                rewardForPool.sub(tokieAmountToSwap),
                token1Out,
                0,
                0,
                address(this),
                block.timestamp
            );
            depositStakingPool(liquidityAmount);
            tokie.transfer(msg.sender, rewardForCaller);
            lastUpdatePoolPendingReward = 0;
            emit Compound(msg.sender, rewardForPool);
        }
    }

    function resetUpdatePoolReward() external onlyOwner {
        lastUpdatePoolPendingReward = 0;
    }

    function pendingTokieNextCompound() public view returns (uint256){
        (,,uint256 rewardLockedUp,) = masterchef.userInfo(farmPid, address(this));
        return masterchef.pendingTokie(farmPid, address(this)).add(rewardLockedUp);
    }

    function rewardForCompounder() external view returns (uint256){
        return pendingTokieNextCompound().mul(percentFeeForCompounding).div(1000);
    }

    function payReferralCommission(address _user, uint256 _pending) internal {
        if (
            address(tokieReferral) != address(0)
            && referralCommissionRate > 0
        ) {
            address referrer = tokieReferral.getReferrer(_user);
            uint256 commissionAmount = _pending.mul(referralCommissionRate).div(
                10000
            );
            if (referrer != address(0) && commissionAmount > 0) {
                vaultReferralTreasury.safeTransfer(referrer, commissionAmount);
                emit ReferralCommissionPaid(_user, referrer, commissionAmount);
            }
        }
    }

    function swapToken1ToTokie(uint256 amountToSwap) internal returns (uint256 amountOut) {
        uint256 tokieBalanceBefore = tokie.balanceOf(address(this));
        router.swapExactTokensForTokens(
            amountToSwap,
            0,
            getToken1TokieRoute(),
            address(this),
            block.timestamp
        );
        amountOut = tokie.balanceOf(address(this)).sub(tokieBalanceBefore);
    }

    function swapTokieToToken1(uint256 amountToSwap) internal returns (uint256 amountOut) {
        uint256 token1BalanceBefore = token1.balanceOf(address(this)); // remove for testing
        router.swapExactTokensForTokens(
            amountToSwap,
            0,
            getTokieToken1Route(),
            address(this),
            block.timestamp
        );
        amountOut = token1.balanceOf(address(this)).sub(token1BalanceBefore);
    }

    function removeLiquidity(uint256 lpAmount) internal returns (uint256 amountTokie, uint256 amountToken1){
        uint256 tokieBalanceBefore = tokie.balanceOf(address(this));
        (,amountToken1) = router.removeLiquidity(
            address(tokie),
            address(token1),
            lpAmount,
            0,
            0,
            address(this),
            block.timestamp
        );
        amountTokie = tokie.balanceOf(address(this)).sub(tokieBalanceBefore);
    }

    function depositStakingPool(uint256 amount) internal {
        masterchef.deposit(farmPid, amount, address(vaultReferralTreasury));
    }

    function getPairReserves() internal view returns (uint reserveA, uint reserveB) {
        address token0 = address(tokie) < address(token1) ? address(tokie) : address(token1);
        (uint reserve0, uint reserve1, ) = getSwappingPair().getReserves();
        (reserveA, reserveB) = address(tokie) == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    function getToken1TokieRoute() private view returns (address[] memory paths) {
        paths = new address[](2);
        paths[0] = address(token1);
        paths[1] = address(tokie);
    }

    function getTokieToken1Route() private view returns (address[] memory paths) {
        paths = new address[](2);
        paths[0] = address(tokie);
        paths[1] = address(token1);
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
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

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
        bool isTopLevelCall = _setInitializedVersion(1);
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
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
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
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IMasterChef {
    function pendingTokie(uint256 _pid, address _user)
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



}

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

pragma solidity ^0.8.0;

interface ITokiePool {
    function safeTransfer(address _to, uint256 _amount) external;
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
        if(data.amount == 0){
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
    function calculateSwapInAmount(uint256 reserveIn, uint256 userIn)
    internal
    pure
    returns (uint256)
    {
        return
        sqrt(
            reserveIn.mul(userIn.mul(3988000) + reserveIn.mul(3988009))
        )
        .sub(reserveIn.mul(1997)) / 1994;
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

pragma solidity ^0.8.0;

interface ITokieReferral {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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