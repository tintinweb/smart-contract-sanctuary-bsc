// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./OwnableUpgradeable.sol";
import "./UUPSUpgradeable.sol";
import "./SafeERC20Upgradeable.sol";
import './IWETH.sol';
import './IPancakeRouter02.sol';
import './IPancakePair.sol';
import './IPancakeFactory.sol';

// PCSFeeHandler_V2
contract PCSFeeHandler is UUPSUpgradeable, OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    struct RemoveLiquidityInfo {
        IPancakePair pair;
        uint amount;
        uint amountAMin;
        uint amountBMin;
    }

    struct SwapInfo {
        uint amountIn;
        uint amountOutMin;
        address[] path;
    }

    struct LPData {
        address lpAddress;
        address token0;
        uint256 token0Amt;
        address token1;
        uint256 token1Amt;
        uint256 userBalance;
        uint256 totalSupply;
    }

    event SwapFailure(uint amountIn, uint amountOutMin, address[] path);
    event RmoveLiquidityFailure(IPancakePair pair, uint amount, uint amountAMin, uint amountBMin);
    event NewPancakeSwapRouter(address indexed sender, address indexed router);
    event NewOperatorAddress(address indexed sender, address indexed operator);
    event NewCakeBurnAddress(address indexed sender, address indexed burnAddress);
    event NewCakeVaultAddress(address indexed sender, address indexed vaultAddress);
    event NewCakeBurnRate(address indexed sender, uint cakeBurnRate);

    address public cake;
    IPancakeRouter02 public pancakeSwapRouter;
    address public operatorAddress; // address of the operator
    address public cakeBurnAddress;
    address public cakeVaultAddress;
    uint public cakeBurnRate; // rate for burn (e.g. 718750 means 71.875%)
    uint constant public RATE_DENOMINATOR = 1000000;
    uint constant UNLIMITED_APPROVAL_AMOUNT = type(uint256).max;
    mapping(address => bool) public validDestination;
    IWETH WETH;

    // Maximum amount of BNB to top-up operator
    uint public operatorTopUpLimit;

    modifier onlyOwnerOrOperator() {
        require(msg.sender == owner() || msg.sender == operatorAddress, "Not owner/operator");
        _;
    }

    function initialize(
        address _cake,
        address _pancakeSwapRouter,
        address _operatorAddress,
        address _cakeBurnAddress,
        address _cakeVaultAddress,
        uint _cakeBurnRate,
        address[] memory destinations
    )
        external
        initializer
    {
        __Ownable_init();
        __UUPSUpgradeable_init();
        cake = _cake;
        pancakeSwapRouter = IPancakeRouter02(_pancakeSwapRouter);
        operatorAddress = _operatorAddress;
        cakeBurnAddress = _cakeBurnAddress;
        cakeVaultAddress = _cakeVaultAddress;
        cakeBurnRate = _cakeBurnRate;
        for (uint256 i = 0; i < destinations.length; ++i)
        {
            validDestination[destinations[i]] = true;
        }
        WETH = IWETH(pancakeSwapRouter.WETH());
        operatorTopUpLimit = 100 ether;
    }

    /**
     * @notice Sell LP token, buy back $CAKE. The amount can be specified by the caller.
     * @dev Callable by owner/operator
     */
    function processFee(
        RemoveLiquidityInfo[] calldata liquidityList,
        SwapInfo[] calldata swapList,
        bool ignoreError
    )
        external
        onlyOwnerOrOperator
    {
        for (uint256 i = 0; i < liquidityList.length; ++i) {
            removeLiquidity(liquidityList[i], ignoreError);
        }
        for (uint256 i = 0; i < swapList.length; ++i) {
            swap(swapList[i].amountIn, swapList[i].amountOutMin, swapList[i].path, ignoreError);
        }
    }

    function removeLiquidity(
        RemoveLiquidityInfo calldata info,
        bool ignoreError
    )
        internal
    {
        uint allowance = info.pair.allowance(address(this), address(pancakeSwapRouter));
        if (allowance < info.amount) {
            IERC20Upgradeable(address(info.pair)).safeApprove(address(pancakeSwapRouter), UNLIMITED_APPROVAL_AMOUNT);
        }
        address token0 = info.pair.token0();
        address token1 = info.pair.token1();
        try pancakeSwapRouter.removeLiquidity(
                token0,
                token1,
                info.amount,
                info.amountAMin,
                info.amountBMin,
                address(this),
                block.timestamp
            )
        {
            // do nothing here
        } catch {
            emit RmoveLiquidityFailure(info.pair, info.amount, info.amountAMin, info.amountBMin);
            require(ignoreError, "remove liquidity failed");
            // if one of the swap fails, we do NOT revert and carry on
        }
    }

    /**
     * @notice Swap tokens for $CAKE
     */
    function swap(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        bool ignoreError
    )
        internal
    {
        require(path.length > 1, "invalid path");
        require(validDestination[path[path.length - 1]], "invalid path");
        address token = path[0];
        uint tokenBalance = IERC20Upgradeable(token).balanceOf(address(this));
        amountIn = (amountIn > tokenBalance) ? tokenBalance : amountIn;
        // TODO: need to adjust `token0AmountOutMin` ?
        uint allowance = IERC20Upgradeable(token).allowance(address(this), address(pancakeSwapRouter));
        if (allowance < amountIn) {
            IERC20Upgradeable(token).safeApprove(address(pancakeSwapRouter), UNLIMITED_APPROVAL_AMOUNT);
        }
        try pancakeSwapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                amountIn,
                amountOutMin,
                path,
                address(this),
                block.timestamp
            )
        {
            // do nothing here
        } catch {
            emit SwapFailure(amountIn, amountOutMin, path);
            require(ignoreError, "swap failed");
            // if one of the swap fails, we do NOT revert and carry on
        }
    }

    /**
     * @notice Send $CAKE tokens to specified wallets(burn and vault)
     * @dev Callable by owner/operator
     */
    function sendCake(uint amount)
        external
        onlyOwnerOrOperator
    {
        require (amount > 0, "invalid amount");
        uint burnAmount = amount * cakeBurnRate / RATE_DENOMINATOR;
        // The rest goes to the vault wallet.
        uint vaultAmount = amount - burnAmount;
        IERC20Upgradeable(cake).safeTransfer(cakeBurnAddress, burnAmount);
        IERC20Upgradeable(cake).safeTransfer(cakeVaultAddress, vaultAmount);
    }

    /**
     * @notice Deposit ETH for WETH
     * @dev Callable by owner/operator
     */
    function depositETH(uint amount)
        external
        onlyOwnerOrOperator
    {
        WETH.deposit{value: amount}();
    }

    /**
     * @notice Set PancakeSwapRouter
     * @dev Callable by owner
     */
    function setPancakeSwapRouter(address _pancakeSwapRouter) external onlyOwner {
        pancakeSwapRouter = IPancakeRouter02(_pancakeSwapRouter);
        emit NewPancakeSwapRouter(msg.sender, _pancakeSwapRouter);
    }

    /**
     * @notice Set operator address
     * @dev Callable by owner
     */
    function setOperator(address _operatorAddress) external onlyOwner {
        operatorAddress = _operatorAddress;
        emit NewOperatorAddress(msg.sender, _operatorAddress);
    }

    /**
     * @notice Set address for `cake burn`
     * @dev Callable by owner
     */
    function setCakeBurnAddress(address _cakeBurnAddress) external onlyOwner {
        cakeBurnAddress = _cakeBurnAddress;
        emit NewCakeBurnAddress(msg.sender, _cakeBurnAddress);
    }

    /**
     * @notice Set vault address
     * @dev Callable by owner
     */
    function setCakeVaultAddress(address _cakeVaultAddress) external onlyOwner {
        cakeVaultAddress = _cakeVaultAddress;
        emit NewCakeVaultAddress(msg.sender, _cakeVaultAddress);
    }

    /**
     * @notice Set percentage of $CAKE being sent for burn
     * @dev Callable by owner
     */
    function setCakeBurnRate(uint _cakeBurnRate) external onlyOwner {
        require(_cakeBurnRate < RATE_DENOMINATOR, "invalid rate");
        cakeBurnRate = _cakeBurnRate;
        emit NewCakeBurnRate(msg.sender, _cakeBurnRate);
    }

    /**
     * @notice transfer some BNB to the operator as gas fee
     * @dev Callable by owner
     */
    function topUpOperator(uint256 amount) external onlyOwner {
        require(amount <= operatorTopUpLimit, "too much");
        uint256 bnbBalance = address(this).balance;
        if (amount > bnbBalance) {
            // BNB not enough, get some BNB from WBNB
            // If WBNB balance is not enough, `withdraw` will `revert`.
            WETH.withdraw(amount - bnbBalance);
        }
        payable(operatorAddress).transfer(amount);
    }

    /**
     * @notice Set top-up limit
     * @dev Callable by owner
     */
    function setOperatorTopUpLimit(uint256 _operatorTopUpLimit) external onlyOwner {
        operatorTopUpLimit = _operatorTopUpLimit;
    }

    function addDestination(address addr) external onlyOwner {
        validDestination[addr] = true;
    }

    function removeDestination(address addr) external onlyOwner {
        validDestination[addr] = false;
    }

    function getPairAddress(
        address factory,
        uint256 cursor,
        uint256 size
    )
        external
        view
        returns (
            address[] memory pairs,
            uint256 nextCursor
        )
    {
        IPancakeFactory pcsFactory = IPancakeFactory(factory);
        uint256 maxLength = pcsFactory.allPairsLength();
        uint256 length = size;
        if (cursor >= maxLength) {
            address[] memory emptyList;
            return (emptyList, maxLength);
        }
        if (length > maxLength - cursor) {
            length = maxLength - cursor;
        }

        address[] memory values = new address[](length);
        for (uint256 i = 0; i < length; ++i) {
            address tempAddr = address(pcsFactory.allPairs(cursor+i));
            values[i] = tempAddr;
        }

        return (values, cursor + length);
    }

    function getPairTokens(
        address[] calldata lps,
        address account
    )
        external
        view
        returns (
            LPData[] memory
        )
    {
        LPData[] memory lpListData = new LPData[](lps.length);
        for (uint256 i = 0; i < lps.length; ++i) {
            IPancakePair pair = IPancakePair(lps[i]);
            lpListData[i].lpAddress = lps[i];
            lpListData[i].token0 = pair.token0();
            lpListData[i].token1 = pair.token1();
            (lpListData[i].token0Amt, lpListData[i].token1Amt, ) = pair.getReserves();
            lpListData[i].userBalance = pair.balanceOf(account);
            lpListData[i].totalSupply = pair.totalSupply();
        }
        return lpListData;
    }

    receive() external payable {}
    fallback() external payable {}
    function _authorizeUpgrade(address) internal override onlyOwner {}
}