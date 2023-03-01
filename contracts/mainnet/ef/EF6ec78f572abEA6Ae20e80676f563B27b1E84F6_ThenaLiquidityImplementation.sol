/**
 *Submitted for verification at BscScan.com on 2023-03-01
*/

// Sources flattened with hardhat v2.12.7 https://hardhat.org

// File @openzeppelin/contracts/token/ERC20/[email protected]
//SPDX-License-Identifier: UNLICENSED

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^ 0.8.0;

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
function totalSupply() external view returns(uint256);

/**
 * @dev Returns the amount of tokens owned by `account`.
 */
function balanceOf(address account) external view returns(uint256);

/**
 * @dev Moves `amount` tokens from the caller's account to `to`.
 *
 * Returns a boolean value indicating whether the operation succeeded.
 *
 * Emits a {Transfer} event.
 */
function transfer(address to, uint256 amount) external returns(bool);

/**
 * @dev Returns the remaining number of tokens that `spender` will be
 * allowed to spend on behalf of `owner` through {transferFrom}. This is
 * zero by default.
 *
 * This value changes when {approve} or {transferFrom} are called.
 */
function allowance(address owner, address spender) external view returns(uint256);

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
function approve(address spender, uint256 amount) external returns(bool);

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
) external returns(bool);
}


// File @openzeppelin/contracts/token/ERC20/extensions/[email protected]


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^ 0.8.0;

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns(string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns(string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns(uint8);
}


// File contracts/Interfaces/ILiquidityImplementation.sol

 
pragma solidity ^ 0.8.17;

interface ILiquidityImplementation {
    function getSwapRouter(address lpToken) external view returns(address);

    struct AddLiquidityInput {
        address lpToken;
        uint256 amountToken0;
        uint256 amountToken1;
        uint256 minAmountToken0;
        uint256 minAmountToken1;
        address to;
        uint256 deadline;
}

    struct RemoveLiquidityInput {
        address lpToken;
        uint256 lpAmount;
        uint256 minAmountToken0;
        uint256 minAmountToken1;
        address to;
        uint256 deadline;
}

    struct AddLiquidityOutput {
        uint256 unusedToken0;
        uint256 unusedToken1;
        uint256 lpToken;
}

    struct RemoveLiquidityOutput {
        uint256 received0;
        uint256 received1;
}

// Interface function to add liquidity to the implementation DEX
function addLiquidity(AddLiquidityInput calldata addLiquidityInput)
external
payable
returns(AddLiquidityOutput memory);

// Interface function to remove liquidity to the implementation DEX
function removeLiquidity(RemoveLiquidityInput calldata removeLiquidityInput)
external
returns(RemoveLiquidityOutput memory);

// Gets token0 for an lp token for the implementation DEX
function token0(address lpToken) external view returns(address);

// Gets token1 for an lp token for the implementation DEX
function token1(address lpToken) external view returns(address);

// Estimate the swap share
function estimateSwapShare(uint256 amount, address lpToken)
external
view
returns(uint256 share0, uint256 share1);

// Estimate the out share
function estimateOutShare(uint256 amount, address lpToken)
external
view
returns(uint256 share0, uint256 share1);
}


// File contracts/Interfaces/IThenaPair.sol

 
pragma solidity ^ 0.8.17;

interface IThenaPair {
    function token0() external view returns(address);

function token1() external view returns(address);

function reserve0() external view returns(uint256);

function reserve1() external view returns(uint256);

function stable() external view returns(bool);

function getReserves() external view returns(uint256, uint256);

function totalSupply() external view returns(uint256);
}


// File contracts/Interfaces/IThenaSwapRouter.sol

 
pragma solidity ^ 0.8.17;

interface IThenaSwapRouter {
    function addLiquidity(
    address tokenA,
    address tokenB,
    bool stable,
    uint256 amountADesired,
    uint256 amountBDesired,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
)
external
returns(
    uint256 amountA,
    uint256 amountB,
    uint256 liquidity
);

function removeLiquidity(
    address tokenA,
    address tokenB,
    bool stable,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
) external returns(uint256 amountA, uint256 amountB);

function quoteRemoveLiquidity(
    address tokenA,
    address tokenB,
    bool stable,
    uint256 liquidity
) external view returns(uint256 amountA, uint256 amountB);
}


// File contracts/LiquidityImplamentations/ThenaLiquidityImplementation.sol

 
pragma solidity ^ 0.8.17;
contract ThenaLiquidityImplementation is ILiquidityImplementation {
    IThenaSwapRouter immutable SwapRouter;

    constructor(address swapRouterAddress) {
        SwapRouter = IThenaSwapRouter(swapRouterAddress);
    }

    function addLiquidity(AddLiquidityInput calldata liquidityInput)
    external
    payable
    returns(AddLiquidityOutput memory)
    {
        IThenaPair thenaPair = IThenaPair(liquidityInput.lpToken);
        (
            uint256 usedToken0,
                uint256 usedToken1,
                    uint256 receivedLpValue
        ) = SwapRouter.addLiquidity(
                        thenaPair.token0(),
                        thenaPair.token1(),
                        thenaPair.stable(),
                        liquidityInput.amountToken0,
                        liquidityInput.amountToken1,
                        liquidityInput.minAmountToken0,
                        liquidityInput.minAmountToken1,
                        liquidityInput.to,
                        liquidityInput.deadline
                    );
        return
        AddLiquidityOutput(
            liquidityInput.amountToken0 - usedToken0,
            liquidityInput.amountToken1 - usedToken1,
            receivedLpValue
        );
    }

    function removeLiquidity(
        RemoveLiquidityInput calldata removeLiquidityOutput
    ) external returns(RemoveLiquidityOutput memory) {
        IThenaPair thenaPair = IThenaPair(removeLiquidityOutput.lpToken);
        (uint256 amount0, uint256 amount1) = SwapRouter.removeLiquidity(
            thenaPair.token0(),
            thenaPair.token1(),
            thenaPair.stable(),
            removeLiquidityOutput.lpAmount,
            removeLiquidityOutput.minAmountToken0,
            removeLiquidityOutput.minAmountToken1,
            removeLiquidityOutput.to,
            removeLiquidityOutput.deadline
        );
        return RemoveLiquidityOutput(amount0, amount1);
    }

    function token0(address lpToken) external view returns(address) {
        return IThenaPair(lpToken).token0();
    }

    function token1(address lpToken) external view returns(address) {
        return IThenaPair(lpToken).token1();
    }

    function getSwapRouter(address lpToken) external view returns(address) {
        return address(SwapRouter);
    }

    function estimateSwapShare(uint256 amount, address lpToken)
    external
    view
    returns(uint256 share0, uint256 share1)
    {
        if (IThenaPair(lpToken).stable()) {
            uint256 reserve0 = IThenaPair(lpToken).reserve0();
            uint256 reserve1 = IThenaPair(lpToken).reserve1();
            address token0 = IThenaPair(lpToken).token0();
            address token1 = IThenaPair(lpToken).token1();
            share0 =
                (amount * _tokenTo18Decimals(token0, reserve0)) /
                (_tokenTo18Decimals(token0, reserve0) +
                    _tokenTo18Decimals(token1, reserve1));
            share1 = amount - share0;
        } else {
            share0 = amount / 2;
            share1 = amount / 2;
        }
    }

    function estimateOutShare(uint256 amount, address lpToken)
    external
    view
    returns(uint256 share0, uint256 share1)
    {
        address token0 = IThenaPair(lpToken).token0();
        address token1 = IThenaPair(lpToken).token1();
        return
        SwapRouter.quoteRemoveLiquidity(
            token0,
            token1,
            IThenaPair(lpToken).stable(),
            amount
        );
    }

    function _tokenTo18Decimals(address token, uint256 amount)
    internal
    view
    returns(uint256)
    {
        uint256 tokenDecimals = IERC20Metadata(token).decimals();
        return (amount * 1 ether) / 10**tokenDecimals;
    }
}