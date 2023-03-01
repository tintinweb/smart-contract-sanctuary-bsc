/**
 *Submitted for verification at BscScan.com on 2023-03-01
*/

// Sources flattened with hardhat v2.12.7 https://hardhat.org

// File @openzeppelin/contracts/token/ERC20/[email protected]
//SPDX-License-Identifier: UNLICENSED
 
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


// File contracts/Interfaces/ILiquidityImplementation.sol

 
pragma solidity ^0.8.17;

interface ILiquidityImplementation {
    function getSwapRouter(address lpToken) external view returns (address);

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
        returns (AddLiquidityOutput memory);

    // Interface function to remove liquidity to the implementation DEX
    function removeLiquidity(RemoveLiquidityInput calldata removeLiquidityInput)
        external
        returns (RemoveLiquidityOutput memory);

    // Gets token0 for an lp token for the implementation DEX
    function token0(address lpToken) external view returns (address);

    // Gets token1 for an lp token for the implementation DEX
    function token1(address lpToken) external view returns (address);

    // Estimate the swap share
    function estimateSwapShare(uint256 amount, address lpToken)
        external
        view
        returns (uint256 share0, uint256 share1);

    // Estimate the out share
    function estimateOutShare(uint256 amount, address lpToken)
        external
        view
        returns (uint256 share0, uint256 share1);
}


// File contracts/Interfaces/IPancakeStableSwap.sol

 
pragma solidity ^0.8.17;

interface IPancakeStableSwap {
    function coins(uint256 index) external view returns (address);

    function add_liquidity(uint256[2] calldata amounts, uint256 min_mint_amount)
        external;

    function remove_liquidity(uint256 _amount, uint256[2] calldata min_amounts)
        external;

    function balances(uint256 index) external view returns (uint256);
}


// File contracts/Interfaces/IPancakeStableSwapPair.sol

 
pragma solidity ^0.8.17;

interface IPancakeStableSwapPair {
    function minter() external view returns (address);

    function balanceOf(address account) external view returns (uint256);
}


// File contracts/LiquidityImplamentations/PancakeStableSwapLiquidityImplementation.sol

 
pragma solidity ^0.8.17;
contract PancakeStableSwapLiquidityImplementation is ILiquidityImplementation {
    constructor() {}

    function addLiquidity(AddLiquidityInput calldata liquidityInput)
        external
        payable
        returns (AddLiquidityOutput memory)
    {
        IPancakeStableSwapPair pair = IPancakeStableSwapPair(
            liquidityInput.lpToken
        );
        IPancakeStableSwap swap = IPancakeStableSwap(pair.minter());
        uint256 balanceBefore = pair.balanceOf(address(this));
        swap.add_liquidity(
            [liquidityInput.amountToken0, liquidityInput.amountToken1],
            1
        );
        uint256 balanceAfter = pair.balanceOf(address(this));

        return AddLiquidityOutput(0, 0, balanceAfter - balanceBefore);
    }

    function removeLiquidity(RemoveLiquidityInput calldata removeLiquidityInput)
        external
        returns (RemoveLiquidityOutput memory)
    {
        IPancakeStableSwapPair pair = IPancakeStableSwapPair(
            removeLiquidityInput.lpToken
        );
        IPancakeStableSwap swap = IPancakeStableSwap(pair.minter());
        uint256 balance0Before = IERC20(swap.coins(0)).balanceOf(address(this));
        uint256 balance1Before = IERC20(swap.coins(1)).balanceOf(address(this));
        swap.remove_liquidity(
            removeLiquidityInput.lpAmount,
            [uint256(1), uint256(1)]
        );
        return
            RemoveLiquidityOutput(
                IERC20(swap.coins(0)).balanceOf(address(this)) - balance0Before,
                IERC20(swap.coins(1)).balanceOf(address(this)) - balance1Before
            );
    }

    function token0(address lpToken) external view returns (address) {
        return
            IPancakeStableSwap(IPancakeStableSwapPair(lpToken).minter()).coins(
                0
            );
    }

    function token1(address lpToken) external view returns (address) {
        return
            IPancakeStableSwap(IPancakeStableSwapPair(lpToken).minter()).coins(
                1
            );
    }

    function getSwapRouter(address lpToken) external view returns (address) {
        return IPancakeStableSwapPair(lpToken).minter();
    }

    function estimateSwapShare(uint256 amount, address lpToken)
        external
        view
        returns (uint256 share0, uint256 share1)
    {
        share0 = amount / 2;
        share1 = amount / 2;
    }

    function estimateOutShare(uint256 amount, address lpToken)
        external
        view
        returns (uint256 share0, uint256 share1)
    {
        IPancakeStableSwap swap = IPancakeStableSwap(
            IPancakeStableSwapPair(lpToken).minter()
        );
        uint256 reserve0 = swap.balances(0);
        uint256 reserve1 = swap.balances(1);
        uint256 totalSupply = IERC20(lpToken).totalSupply();
        return (
            (reserve0 * amount) / totalSupply,
            (reserve1 * amount) / totalSupply
        );
    }
}