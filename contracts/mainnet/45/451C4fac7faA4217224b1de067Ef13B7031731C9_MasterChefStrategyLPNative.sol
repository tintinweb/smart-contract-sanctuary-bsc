// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./MasterChefStrategy.sol";

contract MasterChefStrategyLPNative is MasterChefStrategy {
    IERC20 private token0;
    IERC20 private token1;
    IPair public depositToken;

    constructor(
        address _WETH,
        address _depositToken,
        address _rewardToken,
        address _masterChefContract,
        address _router,
        uint256 _pid,
        address _ops,
        address _treasury
    ) {
        ops = _ops;
        treasury = _treasury;
        WETH = _WETH;
        depositToken = IPair(_depositToken);
        rewardToken = IERC20(_rewardToken);
        stakingContract = IMasterChef(_masterChefContract);
        router = IRouter(_router);

        PID = _pid;

        address _token0 = IPair(_depositToken).token0();
        address _token1 = IPair(_depositToken).token1();

        address tokenA = _token0 != WETH ? _token0 : _token1;//Token
        address tokenB = _token1 == WETH ? _token1 : _token0;//WETH

        token0 = IERC20(tokenA);
        token1 = IERC20(tokenB);

        name = string(
            abi.encodePacked(
                "Autocompound: ",
                depositToken.symbol(),
                " ",
                IERC20(_token0).symbol(),
                "-",
                IERC20(_token1).symbol()
            )
        );

        setAllowances();
        emit Reinvest(0, 0);
    }

    /**
     * @notice Deposit tokens to receive receipt tokens
     * @param amount Amount of tokens to deposit
     */
    function deposit(uint256 amount) external override nonReentrant {
        _deposit(amount, false);
    }

    /**
     * @notice Deposit tokens to receive receipt tokens
     * @param amount0 Amount of tokens1 to deposit
     */

    function dualTokenDeposit(uint256 amount0, uint256 slippage)
        external
        payable
        nonReentrant
    {
        require(
            amount0 > 0 && msg.value > 0,
            "MasterChefStrategyLPNative::dualTokenDeposit: Can not deposit zero amount"
        );
        require(
            slippage >= 1 && slippage < 500,
            "MasterChefStrategyLPNative::dualTokenDeposit: Invalid slippage"
        );

        TransferHelper.safeTransferFrom(
            address(token0),
            msg.sender,
            address(this),
            amount0
        );

        _dualTokenDeposit(amount0, msg.value, slippage);
    }

    /**
     * @notice Deposit tokens to receive receipt tokens
     * @param amount Amount of tokens to deposit
     * @param _token address of token
     */

    function singleTokenDeposit(
        uint256 amount,
        address _token,
        uint256 slippage
    ) external payable nonReentrant {
        require(
            slippage >= 1 && slippage < 500,
            "MasterChefStrategyLPNative::singleTokenDeposit: Invalid slippage"
        );
        require(
            _token == address(token0) || _token == address(token1),
            "MasterChefStrategyLPNative::singleTokenDeposit: Invalid token address"
        );
        if (_token == address(token1)) {
            require(
                msg.value > 0,
                "MasterChefStrategyLPNative::singleTokenDeposit: Insufficient investment"
            );
            amount = msg.value;
        } else {
            require(
                amount > 0,
                "MasterChefStrategyLPNative::singleTokenDeposit: Insufficient tokens to deposit"
            );

            TransferHelper.safeTransferFrom(
                address(token0),
                msg.sender,
                address(this),
                amount
            );
        }

        uint256 amountIn = amount / 2;

        address[] memory path0 = new address[](2);
        path0[0] = _token;
        path0[1] = path0[0] == address(token0)
            ? address(token1)
            : address(token0);

        uint256[] memory amountsOutToken0 = router.getAmountsOut(
            amountIn,
            path0
        );

        uint256 amountOutToken0 = amountsOutToken0[amountsOutToken0.length - 1];

        if (_token == address(token0)) {
            router.swapExactTokensForETH(
                amountIn,
                amountOutToken0,
                path0,
                address(this),
                block.timestamp + 1800
            );
            _dualTokenDeposit(amountIn, amountOutToken0, slippage);
        } else {
            router.swapExactETHForTokens{value: amountIn}(
                amountOutToken0,
                path0,
                address(this),
                block.timestamp + 1800
            );
            _dualTokenDeposit(amountOutToken0, amountIn, slippage);
        }
    }

    /**
     * @notice Withdraw LP tokens by redeeming receipt tokens
     * @param amount Amount of receipt tokens to redeem
     */

    function withdraw(uint256 amount) external override nonReentrant {
        _withdraw(amount, false);
    }

    /**
     * @notice Withdraw tokens by redeeming receipt tokens
     * @param amount Amount of LP to redeem in terms of tokens
     * @param _token Address of token
     */
    function singleWithdraw(uint256 amount, address _token)
        external
        payable
        nonReentrant
    {
        require(
            _token == address(token0) || _token == address(token1),
            "MasterChefStrategyLPNative::singleWithdraw: Invalid token address"
        );
        uint256 depositTokenAmount = getDepositTokensForShares(amount);
        _withdraw(amount, true);

        (uint256 amountToken, uint256 amountETH) = router.removeLiquidityETH(
            address(token0),
            depositTokenAmount,
            0,
            0,
            address(this),
            block.timestamp + 1800
        );
        address[] memory path0 = new address[](2);

        uint256 amountIN;
        uint256 amountOUT;
        if (_token == address(token0)) {
            amountIN = amountETH;
            amountOUT = amountToken;
            path0[0] = address(token1);
            path0[1] = address(token0);
        } else {
            amountIN = amountToken;
            amountOUT = amountETH;
            path0[0] = address(token0);
            path0[1] = address(token1);
        }
        uint256[] memory amountsOutToken0 = router.getAmountsOut(
            amountIN,
            path0
        );
        uint256 amountOutToken0 = amountsOutToken0[amountsOutToken0.length - 1];
        if (_token == address(token0)) {
            router.swapExactETHForTokens{value: amountIN}(
                amountOutToken0,
                path0,
                address(this),
                block.timestamp + 1800
            );
            TransferHelper.safeTransfer(
                _token,
                msg.sender,
                amountOutToken0 + amountOUT
            );
        } else {
            router.swapExactTokensForETH(
                amountIN,
                amountOutToken0,
                path0,
                address(this),
                block.timestamp + 1800
            );
            TransferHelper.safeTransferETH(
                payable(msg.sender),
                amountOutToken0 + amountOUT
            );
        }
    }

    /**
     * @notice Withdraw tokens by redeeming receipt tokens
     * @param amount Amount of LP to redeem in terms of tokens
     */
    function dualWithdraw(uint256 amount) external nonReentrant {
        uint256 depositTokenAmount = getDepositTokensForShares(amount);
        _withdraw(amount, true);
        router.removeLiquidityETH(
            address(token0),
            depositTokenAmount,
            0,
            0,
            msg.sender,
            block.timestamp + 1800
        );
    }

    /**
     * @notice Estimate reinvest reward for caller
     * @return Estimated rewards tokens earned for calling `reinvest()`
     */
    function estimateReinvestReward() external view returns (uint256) {
        uint256 unclaimedRewards = checkReward();
        if (unclaimedRewards >= MIN_TOKENS_TO_REINVEST) {
            return (unclaimedRewards * REINVEST_REWARD_BIPS) / BIPS_DIVISOR;
        }
        return 0;
    }

    /**
     * @notice Reward token balance that can be reinvested
     * @dev Staking rewards accurue to contract on each deposit/withdrawal
     * @return Unclaimed rewards, plus contract balance
     */
    function checkReward() public view returns (uint256) {
        uint256 pendingReward = stakingContract.pendingCake(PID, address(this));
        uint256 contractBalance = rewardToken.balanceOf(address(this));
        return pendingReward + contractBalance;
    }

    /**
     * @notice Reinvest rewards from staking contract to deposit tokens
     * @dev This external function requires minimum tokens to be met
     */
    function reinvest() external onlyEOA nonReentrant {
        uint256 unclaimedRewards = checkReward();
        require(
            unclaimedRewards >= MIN_TOKENS_TO_REINVEST,
            "MasterChefStrategyLPNative::reinvest: MIN_TOKENS_TO_REINVEST"
        );
        _reinvest(unclaimedRewards, msg.sender);
    }

    /**
     * @notice Reinvest rewards from staking contract to deposit tokens
     * @dev This external function requires minimum tokens to be met
     */
    function reinvestOps() external onlyOps nonReentrant {
        uint256 unclaimedRewards = checkReward();
        require(
            unclaimedRewards >= MIN_TOKENS_TO_REINVEST,
            "MasterChefStrategyLPNative::reinvestOps: MIN_TOKENS_TO_REINVEST"
        );
        _reinvest(unclaimedRewards, treasury);
    }

    /**
     * @notice Approve tokens for use in Strategy
     * @dev Restricted to avoid griefing attacks
     */
    function setAllowances() public onlyOwner {
        TransferHelper.safeApprove(
            address(depositToken),
            address(stakingContract),
            UINT_MAX
        );
        TransferHelper.safeApprove(
            address(depositToken),
            address(router),
            UINT_MAX
        );
        TransferHelper.safeApprove(
            address(rewardToken),
            address(router),
            UINT_MAX
        );
        TransferHelper.safeApprove(address(token0), address(router), UINT_MAX);
    }

    function _deposit(uint256 amount, bool check) internal {
        require(
            totalDeposits >= totalSupply,
            "MasterChefStrategyLPNative::_deposit: deposit failed"
        );
        if (REQUIRE_REINVEST_BEFORE_DEPOSIT) {
            uint256 unclaimedRewards = checkReward();
            if (unclaimedRewards >= MIN_TOKENS_TO_REINVEST_BEFORE_DEPOSIT) {
                _reinvest(unclaimedRewards, msg.sender);
            }
        }
        if (!check) {
            TransferHelper.safeTransferFrom(
                address(depositToken),
                msg.sender,
                address(this),
                amount
            );
        }
        _stakeDepositTokens(amount);
        _mint(msg.sender, getSharesForDepositTokens(amount));
        totalDeposits += amount;
        emit Deposit(msg.sender, amount);
    }

    function _dualTokenDeposit(
        uint256 amount0,
        uint256 valueETH,
        uint256 slippage
    ) internal {
        uint256 amountAmin = (amount0 * slippage) / SLIPPAGE_DIVISOR;
        uint256 amountBmin = (valueETH * slippage) / SLIPPAGE_DIVISOR;
        (, , uint256 liquidity) = router.addLiquidityETH{value: valueETH}(
            address(token0),
            amount0,
            amountAmin,
            amountBmin,
            address(this),
            block.timestamp + 1800
        );
        _deposit(liquidity, true);
    }

    function _withdraw(uint256 amount, bool check) internal {
        uint256 depositTokenAmount = getDepositTokensForShares(amount);
        if (depositTokenAmount > 0) {
            _withdrawDepositTokens(depositTokenAmount);

            if (!check) {
                TransferHelper.safeTransfer(
                    address(depositToken),
                    msg.sender,
                    depositTokenAmount
                );
            }

            _burn(msg.sender, amount);
            totalDeposits -= depositTokenAmount;
            emit Withdraw(msg.sender, depositTokenAmount);
        } else {
            require(
                false,
                "MasterChefStrategyLPNative::_withdraw: withdraw amount can,t be zero"
            );
        }
    }

    function _reinvest(uint256 amount, address recipient) internal {
        stakingContract.deposit(PID, 0);
        uint256 stakingFunds = (amount * ADMIN_FEE_BIPS) / BIPS_DIVISOR;
        if (stakingFunds > 0) {
            TransferHelper.safeTransfer(
                address(rewardToken),
                treasury,
                stakingFunds
            );
        }

        uint256 reinvestFee = (amount * REINVEST_REWARD_BIPS) / BIPS_DIVISOR;
        if (reinvestFee > 0) {
            TransferHelper.safeTransfer(
                address(rewardToken),
                recipient,
                reinvestFee
            );
        }

        uint256 lpTokenAmount = _convertRewardTokensToDepositTokens(
            amount - stakingFunds - reinvestFee
        );
        _stakeDepositTokens(lpTokenAmount);
        totalDeposits += lpTokenAmount;

        emit Reinvest(totalDeposits, totalSupply);
    }

    function _convertRewardTokensToDepositTokens(uint256 amount)
        internal
        returns (uint256)
    {
        uint256 amountIn = amount / 2;
        require(
            amountIn > 0,
            "MasterChefStrategyLPNative::_convertRewardTokensToDepositTokens: amount too low"
        );

        address[] memory path0 = new address[](2);
        path0[0] = address(rewardToken);
        path0[1] = WETH;

        uint256[] memory amountsOutToken0 = router.getAmountsOut(
            amountIn,
            path0
        );
        uint256 amountOutToken0 = amountsOutToken0[amountsOutToken0.length - 1];
        router.swapExactTokensForETH(
            amountIn,
            amountOutToken0,
            path0,
            address(this),
            block.timestamp + 1800
        );

        address[] memory path1 = new address[](3);
        path1[0] = path0[0];
        path1[1] = WETH;
        path1[2] = address(token0);

        uint256[] memory amountsOutToken1 = router.getAmountsOut(
            amountIn,
            path1
        );
        uint256 amountOutToken1 = amountsOutToken1[amountsOutToken1.length - 1];
        router.swapExactTokensForTokens(
            amountIn,
            amountOutToken1,
            path1,
            address(this),
            block.timestamp + 1800
        );

        (, , uint256 liquidity) = router.addLiquidityETH{
            value: amountOutToken0
        }(
            address(token0),
            amountOutToken1,
            0,
            0,
            address(this),
            block.timestamp + 1800
        );

        return liquidity;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../libraries/TransferHelper.sol";
import "./interfaces/IMasterChef.sol";
import "./interfaces/IRouter.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IPair.sol";
import "./interfaces/IMasterChefStrategy.sol";

abstract contract MasterChefStrategy is
    Ownable,
    IMasterChefStrategy,
    ReentrancyGuard
{
    IRouter public router;
    IERC20 public rewardToken;
    IMasterChef public stakingContract;
    address public WETH;
    address public ops;
    address public treasury;

    uint256 public PID;
    uint256 public MIN_TOKENS_TO_REINVEST = 20000;
    uint256 public REINVEST_REWARD_BIPS = 300;
    uint256 public ADMIN_FEE_BIPS = 500;
    uint256 internal constant BIPS_DIVISOR = 10000;
    uint256 internal constant SLIPPAGE_DIVISOR = 1000;
    uint256 internal constant UINT_MAX = type(uint256).max;

    bool public REQUIRE_REINVEST_BEFORE_DEPOSIT;
    uint256 public MIN_TOKENS_TO_REINVEST_BEFORE_DEPOSIT = 20;

    string public name = "AutocompoundStrategy";
    string public symbol = "ACS";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    uint256 public totalDeposits;

    mapping(address => mapping(address => uint256)) internal allowances;
    mapping(address => uint256) internal balances;

    mapping(address => uint256) public nonces;

    constructor() {}

    /**
     * @notice Get the number of tokens `spender` is approved to spend on behalf of `account`
     * @param account The address of the account holding the funds
     * @param spender The address of the account spending the funds
     * @return The number of tokens approved
     */
    function allowance(address account, address spender)
        external
        view
        returns (uint256)
    {
        return allowances[account][spender];
    }

    /**
     * @notice Approve `spender` to transfer up to `amount` from `src`
     * @dev This will overwrite the approval amount for `spender`
     * and is subject to issues noted [here](https://eips.ethereum.org/EIPS/eip-20#approve)
     * It is recommended to use increaseAllowance and decreaseAllowance instead
     * @param spender The address of the account which may transfer tokens
     * @param amount The number of tokens that are approved (2^256-1 means infinite)
     * @return Whether or not the approval succeeded
     */
    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /**
     * @notice Get the number of tokens held by the `account`
     * @param account The address of the account to get the balance of
     * @return The number of tokens held
     */
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    /**
     * @notice Transfer `amount` tokens from `msg.sender` to `dst`
     * @param dst The address of the destination account
     * @param amount The number of tokens to transfer
     * @return Whether or not the transfer succeeded
     */
    function transfer(address dst, uint256 amount) external returns (bool) {
        _transferTokens(msg.sender, dst, amount);
        return true;
    }

    /**
     * @notice Transfer `amount` tokens from `src` to `dst`
     * @param src The address of the source account
     * @param dst The address of the destination account
     * @param amount The number of tokens to transfer
     * @return Whether or not the transfer succeeded
     */
    function transferFrom(
        address src,
        address dst,
        uint256 amount
    ) external returns (bool) {
        address spender = msg.sender;
        uint256 spenderAllowance = allowances[src][spender];

        if (spender != src && spenderAllowance != type(uint256).max) {
            require(
                spenderAllowance >= amount,
                "MasterChefStrategy::transferFrom: transfer amount exceeds allowance"
            );
            uint256 newAllowance = spenderAllowance - amount;
            allowances[src][spender] = newAllowance;

            emit Approval(src, spender, newAllowance);
        }

        _transferTokens(src, dst, amount);
        return true;
    }

    /**
     * @notice Allows exit from Staking Contract without additional logic
     * @dev Reward tokens are not automatically collected
     * @dev New deposits will be effectively disabled
     */
    function emergencyWithdraw() external onlyOwner {
        stakingContract.emergencyWithdraw(PID);
        totalDeposits = 0;
    }

    /**
     * @notice Revoke token allowance
     * @dev Restricted to avoid griefing attacks
     * @param token address
     * @param spender address
     */
    function revokeAllowance(address token, address spender)
        external
        onlyOwner
    {
        TransferHelper.safeApprove(token, spender, 0);
    }

    /**
     * @notice Update reinvest minimum threshold for external callers
     * @param newValue min threshold in wei
     */
    function updateMinTokensToReinvest(uint256 newValue) external onlyOwner {
        emit UpdateMinTokensToReinvest(MIN_TOKENS_TO_REINVEST, newValue);
        MIN_TOKENS_TO_REINVEST = newValue;
    }

    /**
     * @notice Update admin fee
     * @dev Total fees cannot be greater than BIPS_DIVISOR (100%)
     * @param newValue specified in BIPS
     */
    function updateAdminFee(uint256 newValue) external onlyOwner {
        require(
            newValue + REINVEST_REWARD_BIPS <= BIPS_DIVISOR,
            "MasterChefStrategy::updateAdminFee: admin fee too high"
        );
        emit UpdateAdminFee(ADMIN_FEE_BIPS, newValue);
        ADMIN_FEE_BIPS = newValue;
    }

    /**
     * @notice Update reinvest reward
     * @dev Total fees cannot be greater than BIPS_DIVISOR (100%)
     * @param newValue specified in BIPS
     */
    function updateReinvestReward(uint256 newValue) external onlyOwner {
        require(
            newValue + ADMIN_FEE_BIPS <= BIPS_DIVISOR,
            "MasterChefStrategy::updateReinvestReward: reinvest reward too high"
        );
        emit UpdateReinvestReward(REINVEST_REWARD_BIPS, newValue);
        REINVEST_REWARD_BIPS = newValue;
    }

    /**
     * @notice Toggle requirement to reinvest before deposit
     */
    function updateRequireReinvestBeforeDeposit() external onlyOwner {
        REQUIRE_REINVEST_BEFORE_DEPOSIT = !REQUIRE_REINVEST_BEFORE_DEPOSIT;
        emit UpdateRequireReinvestBeforeDeposit(
            REQUIRE_REINVEST_BEFORE_DEPOSIT
        );
    }

    /**
     * @notice Update reinvest minimum threshold before a deposit
     * @param newValue min threshold in wei
     */
    function updateMinTokensToReinvestBeforeDeposit(uint256 newValue)
        external
        onlyOwner
    {
        emit UpdateMinTokensToReinvestBeforeDeposit(
            MIN_TOKENS_TO_REINVEST_BEFORE_DEPOSIT,
            newValue
        );
        MIN_TOKENS_TO_REINVEST_BEFORE_DEPOSIT = newValue;
    }

    /**
     * @notice Recover ERC20 from contract
     * @param tokenAddress token address
     * @param tokenAmount amount to recover
     */
    function recoverERC20(address tokenAddress, uint256 tokenAmount)
        external
        onlyOwner
    {
        require(
            tokenAmount > 0,
            "MasterChefStrategy::recoverERC20: amount too low"
        );
        TransferHelper.safeTransfer(tokenAddress, msg.sender, tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }

    /**
     * @notice Recover recoverNativeAsset from contract
     * @param amount amount
     */
    function recoverNativeAsset(uint256 amount) external onlyOwner {
        require(
            amount > 0,
            "MasterChefStrategy::recoverNativeAsset: amount too low"
        );
        TransferHelper.safeTransferETH(payable(msg.sender), amount);
        emit Recovered(address(0), amount);
    }

    /**
     * @notice Deposit tokens to receive receipt tokens
     * @param amount Amount of tokens to deposit
     */

    function deposit(uint256 amount) external virtual {}

    /**
     * @notice Withdraw LP tokens by redeeming receipt tokens
     * @param amount Amount of receipt tokens to redeem
     */

    function withdraw(uint256 amount) external virtual {}

    /**
     * @notice Function to receive recoverNativeAsset
     */

    receive() external payable {}

    /**
     * @notice Calculate receipt tokens for a given amount of deposit tokens
     * @dev If contract is empty, use 1:1 ratio
     * @dev Could return zero shares for very low amounts of deposit tokens
     * @param amount deposit tokens
     * @return receipt tokens
     */
    function getSharesForDepositTokens(uint256 amount)
        public
        view
        returns (uint256)
    {
        if (totalSupply * totalDeposits == 0) {
            return amount;
        }
        return (amount * totalSupply) / totalDeposits;
    }

    /**
     * @notice Calculate deposit tokens for a given amount of receipt tokens
     * @param amount receipt tokens
     * @return deposit tokens
     */
    function getDepositTokensForShares(uint256 amount)
        public
        view
        returns (uint256)
    {
        if (totalSupply * totalDeposits == 0) {
            return 0;
        }
        return (amount * totalDeposits) / totalSupply;
    }

    /**
     * @dev Throws if called by smart contract
     */
    modifier onlyEOA() {
        require(
            tx.origin == msg.sender,
            "MasterChefStrategy::onlyEOA: onlyEOA"
        );
        _;
    }

    /**
     * @dev Throws if called by smart contract
     */
    modifier onlyOps() {
        require(msg.sender == ops, "MasterChefStrategy::onlyOps: onlyOps");
        _;
    }

    /**
     * @notice Stakes deposit tokens in Staking Contract
     * @param amount deposit tokens to stake
     */
    function _stakeDepositTokens(uint256 amount) internal {
        require(
            amount > 0,
            "MasterChefStrategy::_stakeDepositTokens: amount too low"
        );
        stakingContract.deposit(PID, amount);
    }

    /**
     * @notice Withdraws deposit tokens from Staking Contract
     * @dev Reward tokens are automatically collected
     * @dev Reward tokens are not automatically reinvested
     * @param amount deposit tokens to remove
     */
    function _withdrawDepositTokens(uint256 amount) internal {
        require(
            amount > 0,
            "MasterChefStrategy::_withdrawDepositTokens: amount too low"
        );
        stakingContract.withdraw(PID, amount);
    }

    /**
     * @notice Approval implementation
     * @param owner The address of the account which owns tokens
     * @param spender The address of the account which may transfer tokens
     * @param amount The number of tokens that are approved (2^256-1 means infinite)
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(
            owner != address(0),
            "MasterChefStrategy::_approve: owner zero address"
        );
        require(
            spender != address(0),
            "MasterChefStrategy::_approve: spender zero address"
        );
        allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @notice Transfer implementation
     * @param from The address of the account which owns tokens
     * @param to The address of the account which is receiving tokens
     * @param value The number of tokens that are being transferred
     */
    function _transferTokens(
        address from,
        address to,
        uint256 value
    ) internal {
        require(
            to != address(0),
            "MasterChefStrategy:: _transferTokens: cannot transfer to the zero address"
        );

        require(
            balances[from] >= value,
            "MasterChefStrategy::_transferTokens: transfer exceeds from balance"
        );

        balances[from] -= value;
        balances[to] += value;
        emit Transfer(from, to, value);
    }

    function _mint(address to, uint256 value) internal {
        totalSupply += value;
        balances[to] += value;
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint256 value) internal {
        require(
            balances[from] >= value,
            "MasterChefStrategy::_burn: burn amount exceeds from balance"
        );
        balances[from] = balances[from] - value;
        require(
            totalSupply >= value,
            "MasterChefStrategy::_burn: burn amount exceeds total supply"
        );
        totalSupply = totalSupply - value;
        emit Transfer(from, address(0), value);
    }

    /**
     * @notice Current id of the chain where this contract is deployed
     * @return Chain id
     */
    function _getChainId() internal view returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
abstract contract ReentrancyGuard {
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

    constructor() {
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
pragma solidity ^0.8.13;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeApprove: approve failed"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeTransfer: transfer failed"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::transferFrom: transferFrom failed"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(
            success,
            "TransferHelper::safeTransferETH: ETH transfer failed"
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IMasterChef {
    function cake() external view returns (address);

    function cakePerBlock() external view returns (uint256);

    function poolLength() external view returns (uint256);

    function add(
        uint256 _allocPoint,
        address _lpToken,
        bool _withUpdate
    ) external;

    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) external;

    function getMultiplier(uint256 _from, uint256 _to)
        external
        view
        returns (uint256);

    function pendingCake(uint256 _pid, address _user)
        external
        view
        returns (uint256);

    function massUpdatePools() external;

    function updatePool(uint256 _pid) external;

    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function emergencyWithdraw(uint256 _pid) external;

    function dev(address _devaddr) external;

    function poolInfo(uint256 pid)
        external
        view
        returns (
            address lpToken,
            uint256 allocPoint,
            uint256 lastRewardBlock,
            uint256 acccakePerShare
        );

    function userInfo(uint256 pid, address user)
        external
        view
        returns (uint256 amount, uint256 rewardDebt);

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


interface IRouter {
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

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
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
    ) external returns (uint256 amountETH);

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

    function getAmountsOut(uint256 amountIn, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "./IERC20.sol";


interface IPair is IERC20 {
    function token0() external pure returns (address);

    function token1() external pure returns (address);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function mint(address to) external returns (uint256 liquidity);

    function sync() external;
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

interface IMasterChefStrategy {
    event Deposit(address indexed account, uint256 amount);
    event Withdraw(address indexed account, uint256 amount);
    event Reinvest(uint256 newTotalDeposits, uint256 newTotalSupply);
    event Recovered(address token, uint256 amount);
    event UpdateAdminFee(uint256 oldValue, uint256 newValue);
    event UpdateReinvestReward(uint256 oldValue, uint256 newValue);
    event UpdateMinTokensToReinvest(uint256 oldValue, uint256 newValue);
    event UpdateRequireReinvestBeforeDeposit(bool newValue);
    event UpdateMinTokensToReinvestBeforeDeposit(
        uint256 oldValue,
        uint256 newValue
    );
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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