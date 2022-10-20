// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "./BBD/interfaces/IWETH.sol";
import "./BBD/interfaces/IBabyDogeRouter.sol";
import "./BBD/interfaces/IBabyDogeFactory.sol";
import "./BBD/interfaces/IBabyDogePair.sol";
import "./IFarm.sol";

contract FarmZAP {
    struct TokensAddresses {
        address tokenIn;
        address token0;
        address token1;
        address lpToken;
    }

    struct LpData {
        address token0;
        address token1;
        uint256 reserveA;
        uint256 reserveB;
        uint256 totalSupply;
    }

    // remaining tokens after adding liquidity won't be returned
    // to users account if amount is below this threshold
    uint256 private constant THRESHOLD = 1e12;

    IWETH public immutable WBNB;
    IBabyDogeRouter public immutable router;
    IBabyDogeFactory public immutable factory;

    event LpBought (
        address account,
        address tokenIn,
        address lpToken,
        uint256 amountIn,
        uint256 amountOut,
        uint256 returnedAmount
    );

    event LpBoughtAndDeposited (
        address farm,
        address account,
        address tokenIn,
        address lpToken,
        uint256 amountIn,
        uint256 amountOut,
        uint256 returnedAmount
    );

    event TokensBoughtAndDeposited (
        address farm,
        address account,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOut
    );


    /*
     * @param _router Baby doge router address
     */
    constructor(
        IBabyDogeRouter _router
    ) {
        router = _router;
        WBNB = IWETH(_router.WETH());
        factory = IBabyDogeFactory(_router.factory());
    }

    // to receive BNB
    receive() payable external {}

    /*
     * @notice Swaps input token to LP token and returns remaining amount of tokens, swapped back to input token. Public function
     * @param amountIn Amount of input tokens
     * @param amountOutMin Minimum amount of LP tokens to receive
     * @param path0 Address path to swap to token0
     * @param path1 Address path to swap to token1
     * @return Received LP amount. Use for callStatic
     * @dev Last element of path0 must be token0. Last element of path1 must be token1
     * @dev If input token is token0, leave path0 empty
     * @dev If input token is token1, leave path1 empty
     * @dev First element of path0 and path1 must be input token (if not empty)
     * @dev Should be used for front end estimation with static call after input tokens approval
     */
    function buyLpTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path0,
        address[] calldata path1
    ) external payable returns(uint256) {
        (
            uint256 lpAmount,
            TokensAddresses memory tokens,
            uint256 returnedAmount
        ) = _buyLpTokens(
            amountIn,
            amountOutMin,
            path0,
            path1
        );

        IERC20(tokens.lpToken).transfer(msg.sender, lpAmount);

        emit LpBought (
            msg.sender,
            tokens.tokenIn,
            tokens.lpToken,
            amountIn,
            lpAmount,
            returnedAmount
        );

        return(lpAmount);
    }


    /*
     * @notice Swaps input token to LP token and deposits on behalf of msg.sender to specific farm
     * @param farm Farm address, where LP tokens should be deposited
     * @param amountIn Amount of input tokens
     * @param amountOutMin Minimum amount of LP tokens to receive
     * @param path0 Address path to swap to token0
     * @param path1 Address path to swap to token1
     * @return Received LP amount. Use for callStatic
     * @dev Last element of path0 must be token0. Last element of path1 must be token1
     * @dev If input token is token0, leave path0 empty
     * @dev If input token is token1, leave path1 empty
     * @dev First element of path0 and path1 must be input token (if not empty)
     * @dev Should be used for front end estimation with static call after input tokens approval
     */
    function buyLpTokensAndDepositOnBehalf(
        IFarm farm,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path0,
        address[] calldata path1
    ) external payable returns(uint256) {
        (
            uint256 lpAmount,
            TokensAddresses memory tokens,
            uint256 returnedAmount
        ) = _buyLpTokens(
            amountIn,
            amountOutMin,
            path0,
            path1
        );
        require(tokens.lpToken == farm.stakeToken(), "Not a stake token");

        _approveIfRequired(tokens.lpToken, address(farm), lpAmount);
        farm.depositOnBehalf(lpAmount, msg.sender);

        emit LpBoughtAndDeposited (
            address(farm),
            msg.sender,
            tokens.tokenIn,
            tokens.lpToken,
            amountIn,
            lpAmount,
            returnedAmount
        );

        return(lpAmount);
    }


    /*
     * @notice Swaps input token to ERC20 token and deposits on behalf of msg.sender to specified farm
     * @param farm Farm address, where tokens should be deposited
     * @param amountIn Amount of input tokens
     * @param amountOutMin Minimum amount of tokens to receive
     * @param path Address path to swap input token
     * @return Received token amount
     * @dev Last element of path must be stake token
     * @dev First element of path must be input token
     */
    function buyTokensAndDepositOnBehalf(
        IFarm farm,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path
    ) external payable returns(uint256) {
        if (msg.value > 0) {
            require(address(WBNB) == path[0], "Input token != WBNB");
            require(amountIn == msg.value, "Invalid msg.value");
            WBNB.deposit{value: amountIn}();
        } else {
            IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);
        }
        address tokenOut = path[path.length - 1];
        require(tokenOut == farm.stakeToken(), "Not a stake token");

        _approveIfRequired(path[0], address(router), amountIn);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountIn,
            amountOutMin,
            path,
            address(this),
            block.timestamp + 1200
        );
        uint256 received = IERC20(tokenOut).balanceOf(address(this));

        _approveIfRequired(tokenOut, address(farm), received);
        farm.depositOnBehalf(received, msg.sender);

        emit TokensBoughtAndDeposited (
            address(farm),
            msg.sender,
            path[0],
            tokenOut,
            amountIn,
            received
        );

        return received;
    }


    /*
     * @notice Estimates amount of Lp tokens based on input amount
     * @param amountIn Amount of input tokens
     * @param path0 Address path to swap to token0
     * @param path1 Address path to swap to token1
     * @dev Should be used for front end estimation before input tokens approval
     */
    function estimateAmountOfLpTokens(
        uint256 amountIn,
        address[] calldata path0,
        address[] calldata path1
    ) external view returns(uint256 lpAmount){
        LpData memory lpData = _getLpData(path0, path1);
        if (lpData.totalSupply == 0) {
            return 0;
        }
        uint256 amountIn0 = amountIn/2;
        uint256 amountIn1 = amountIn/2;

        uint256 amount0 = _getAmountOut(amountIn0, path0);
        uint256 amount1 = _getAmountOut(amountIn1, path1);

        lpAmount = _estimateLpAmount(
            amount0,
            amount1,
            lpData
        );
    }


    /*
     * @notice Swaps input token to LP token. Internal function
     * @param amountIn Amount of input tokens
     * @param amountOutMin Minimum amount of LP tokens to receive
     * @param path0 Address path to swap to token0
     * @param path1 Address path to swap to token1
     * @return lpAmount Amount of LP tokens received
     * @return tokens Addresses of input token, token0, token1, lpToken and WBNB
     * @return returnedAmount amount of input tokens returned to user
     */
    function _buyLpTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path0,
        address[] calldata path1
    ) internal returns (
        uint256 lpAmount,
        TokensAddresses memory tokens,
        uint256 returnedAmount
    ) {
        tokens = _checkBeforeGettingLp(amountIn, path0, path1);

        (uint256 amount0, uint256 amount1) = _swapInputToTokens(
            path0,
            path1
        );

        uint256 _lpAmount = _addLiquidity(
            tokens,
            amount0,
            amount1
        );
        require(_lpAmount >= amountOutMin, "Below amountOutMin");

        // return remaining tokens
        returnedAmount = _returnTokens(tokens, path0, path1);

        return (_lpAmount, tokens, returnedAmount);
    }


    /*
     * @notice Transfers input token to the contract and checks if paths are correct
     * @param amountIn Amount of input tokens
     * @param path0 Address path to swap to token0
     * @param path1 Address path to swap to token1
     * @return Addresses of input token, token0, token1, lpToken and WBNB
     */
    function _checkBeforeGettingLp(
        uint256 amountIn,
        address[] calldata path0,
        address[] calldata path1
    ) private returns(TokensAddresses memory) {
        address tokenIn;
        if (path0.length > 0) {
            tokenIn = path0[0];
        } else {
            tokenIn = path1[0];
        }

        if (msg.value > 0) {
            require(
                (path0.length == 0 || path0[0] == address(WBNB))
                && (path1.length == 0 || path1[0] == address(WBNB)),
                "Input token != WBNB"
            );
            require(amountIn == msg.value, "Invalid msg.value");
            WBNB.deposit{value: msg.value}();
        } else {
            IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        }

        require(
            (path0.length == 0 || path0.length >= 2)
            && (path1.length == 0 || path1.length >= 2),
            "Invalid path"
        );
        require(
            path0.length == 0 || path1.length == 0 || path0[0] == path1[0],
            "Invalid input token"
        );
        address token0 = path0.length > 0 ? path0[path0.length - 1] : path1[0];
        address token1 = path1.length > 0 ? path1[path1.length - 1] : path0[0];
        require(token0 != token1, "Same tokens");

        address lpAddress = factory.getPair(token0, token1);
        require(lpAddress != address(0), "Pair doesn't exist");
        {
            (uint112 reserve0, uint112 reserve1,) = IBabyDogePair(lpAddress).getReserves();
            require(reserve0 > 0 && reserve1 > 0, "Empty reserves");
        }

        return TokensAddresses({
            tokenIn: tokenIn,
            token0: token0,
            token1: token1,
            lpToken: lpAddress
        });
    }


    /*
     * @notice Adds liquidity, then balances remaining token to liquidity again
     * @param tokens Addresses of input token, token0, token1, lpToken and WBNB
     * @param amount0 Amount of token0 to add to liquidity
     * @param amount1 Amount of token1 to add to liquidity
     * @return liquidity Amount of LP tokens received
     */
    function _addLiquidity(
        TokensAddresses memory tokens,
        uint256 amount0,
        uint256 amount1
    ) private returns(uint256 liquidity) {
        _approveIfRequired(tokens.token0, address(router), amount0);
        _approveIfRequired(tokens.token1, address(router), amount1);

        (uint256 amountA, uint256 amountB,) = router.addLiquidity(
            tokens.token0,
            tokens.token1,
            amount0,
            amount1,
            0,
            0,
            address(this),
            block.timestamp + 1200
        );

        uint256 reserve0 = IERC20(tokens.token0).balanceOf(tokens.lpToken);
        uint256 reserve1 = IERC20(tokens.token1).balanceOf(tokens.lpToken);

        uint256 remaining;
        if (amount0 > amountA) {
            remaining = amount0 - amountA;
            uint256 amountIn = _getPerfectAmountIn(remaining, reserve0);
            amount0 = remaining - amountIn;

            address[] memory path = new address[](2);
            path[0] = tokens.token0;
            path[1] = tokens.token1;
            _approveIfRequired(tokens.token0, address(router), amountIn);
            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                amountIn,
                0,
                path,
                address(this),
                block.timestamp + 1200
            );
            amount1 = IERC20(tokens.token1).balanceOf(address(this));
        } else {
            remaining = amount1 - amountB;
            uint256 amountIn = _getPerfectAmountIn(remaining, reserve1);
            amount1 = remaining - amountIn;

            address[] memory path = new address[](2);
            path[0] = tokens.token1;
            path[1] = tokens.token0;
            _approveIfRequired(tokens.token1, address(router), amountIn);
            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                amountIn,
                0,
                path,
                address(this),
                block.timestamp + 1200
            );
            amount0 = IERC20(tokens.token0).balanceOf(address(this));
        }

        // add to liquidity remaining tokens after splitting amounts in perfect ratio
        router.addLiquidity(
            tokens.token0,
            tokens.token1,
            amount0,
            amount1,
            0,
            0,
            address(this),
            block.timestamp + 1200
        );

        liquidity = IERC20(tokens.lpToken).balanceOf(address(this));
    }


    /*
     * @notice Swaps input token to LP token
     * @param path0 Address path to swap to token0
     * @param path1 Address path to swap to token1
     * @return amount0 - Received amount of token0
     * @return amount1 - Received amount of token1
     * @dev Internal function without checks
     */
    function _swapInputToTokens(
        address[] calldata path0,
        address[] calldata path1
    ) internal returns (uint256 amount0, uint256 amount1) {
        uint256 amountIn = path0.length > 0
            ? IERC20(path0[0]).balanceOf(address(this))
            : IERC20(path1[0]).balanceOf(address(this));
        amount0 = amountIn / 2;
        amount1 = amountIn / 2;

        if (path0.length > 0) {
            _approveIfRequired(path0[0], address(router), amount0);
            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                amount0,
                0,
                path0,
                address(this),
                block.timestamp + 1200
            );

            amount0 = IERC20(path0[path0.length - 1]).balanceOf(address(this));
        }

        if (path1.length > 0) {
            _approveIfRequired(path1[0], address(router), amount1);
            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                amount1,
                0,
                path1,
                address(this),
                block.timestamp + 1200
            );

            amount1 = IERC20(path1[path1.length - 1]).balanceOf(address(this));
        }
    }


    /*
     * @notice Transfers remaining tokens back to user. Converts them back to input token
     * @param tokens Addresses of input token, token0, token1, lpToken and WBNB
     * @param path0 Swap path for token0
     * @param path1 Swap path for token1
     * @return toReturn Returned amount of input tokens
     * @dev Transfers tokens only above THRESHOLD value to save gas
     */
    function _returnTokens(
        TokensAddresses memory tokens,
        address[] calldata path0,
        address[] calldata path1
    ) private returns(uint256 toReturn) {
        uint256 remainingAmount0 = IERC20(tokens.token0).balanceOf(address(this));
        uint256 remainingAmount1 = IERC20(tokens.token1).balanceOf(address(this));

        if (remainingAmount0 > THRESHOLD && path0.length > 0) {
            address[] memory path = _reversePath(path0);
            _approveIfRequired(path[0], address(router), remainingAmount0);
            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                remainingAmount0,
                0,
                path,
                address(this),
                block.timestamp + 1200
            );
        }

        if (remainingAmount1 > THRESHOLD && path1.length > 0) {
            address[] memory path = _reversePath(path1);
            _approveIfRequired(path[0], address(router), remainingAmount1);
            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                remainingAmount1,
                0,
                path,
                address(this),
                block.timestamp + 1200
            );
        }

        toReturn = IERC20(tokens.tokenIn).balanceOf(address(this));
        if (toReturn > 0) {
            if (msg.value > 0) {
                _approveIfRequired(address(WBNB), address(WBNB), toReturn);
                WBNB.withdraw(toReturn);
                (bool success, ) = payable(msg.sender).call{value: toReturn}("");
                require(success, "Can't return BNB");
            } else {
                IERC20(tokens.tokenIn).transfer(msg.sender, toReturn);
            }
        }
    }


    /*
     * @notice Reverses address array
     * @param path Input path
     * @return Reversed path
     */
    function _reversePath(
        address[] calldata path
    ) private pure returns(address[] memory) {
        uint256 arrayLength = path.length;
        address[] memory reversedPath = new address[](arrayLength);

        for (uint i = 0; i < arrayLength; i++) {
            reversedPath[i] = path[arrayLength - 1 - i];
        }

        return reversedPath;
    }


    /*
     * @notice Approves token to router if required
     * @param token ERC20 token
     * @param spender Spender contract address
     * @param minAmount Minimum amount of tokens to spend
     */
    function _approveIfRequired(
        address token,
        address spender,
        uint256 minAmount
    ) private {
        if (IERC20(token).allowance(address(this), spender) < minAmount) {
            IERC20(token).approve(spender, type(uint256).max);
        }
    }


    /*
     * @notice Calculates amountIn in such way, so that remaining tokens would be split into
     * such amounts, that most of them would be added to liquidity
     * @param remaining Remaining amount of tokenA to be split between tokenA and tokenB and added to liquidity
     * @param reserveIn Current reserve of tokenA
     * @return Amount of tokenA to be swapped to tokenB in order to achieve perfect liquidity ratio
     * @dev Used for adding to liquidity remaining tokens instead of returning them to the user
     */
    function _getPerfectAmountIn(
        uint256 remaining,
        uint256 reserveIn
    ) private pure returns(uint256) {
        return Math.sqrt((3988009 * reserveIn + 3988000 * remaining)
        / 3976036 * reserveIn)
        - 1997 * reserveIn / 1994;
    }


    /****************************** Estimation functions helpers ******************************/
    /*
     * @notice Gets reserves and total supply of LP token
     * @param path0 Address path to swap to token0
     * @param path1 Address path to swap to token1
     * @return lpData Reserves and total supply of LP token
     * @dev Internal function for estimateAmountOfLpTokens
     */
    function _getLpData(
        address[] calldata path0,
        address[] calldata path1
    ) private view returns(LpData memory lpData) {
        address token0 = path0.length > 0 ? path0[path0.length - 1] : path1[0];
        address token1 = path1.length > 0 ? path1[path1.length - 1] : path0[0];
        address pairAddress = factory.getPair(token0, token1);
        if (pairAddress == address(0)) {
            return lpData;
        }

        lpData.token0 = token0;
        lpData.token1 = token1;
        lpData.reserveA = IERC20(token0).balanceOf(pairAddress);
        lpData.reserveB = IERC20(token1).balanceOf(pairAddress);
        lpData.totalSupply = IBabyDogePair(pairAddress).totalSupply();

        return lpData;
    }


    /*
     * @notice Calculate expected amount out of swap
     * @param amountIn Amount ot tokens to pe spent
     * @param path Address path to swap to token0
     * @return amountOut Expected amount of token0
     * @dev Internal function for estimateAmountOfLpTokens
     */
    function _getAmountOut(
        uint256 amountIn,
        address[] calldata path
    ) private view returns(uint256 amountOut) {
        if (path.length > 0) {
            (uint256[] memory amounts) = router.getAmountsOut(amountIn, path);
            amountOut = amounts[amounts.length - 1];
        } else {
            amountOut = amountIn;
        }
    }


    /*
     * @notice Estimates amount of minted LP tokens based on input amounts
     * @param amountADesired Amount of tokens A to add to liquidity
     * @param amountBDesired Amount of tokens B to add to liquidity
     * @param lpData Reserves and total supply of LP token
     * @return liquidity Amount of LP tokens expected to receive in return
     * @dev Internal function for estimateAmountOfLpTokens
     */
    function _estimateLpAmount(
        uint256 amountADesired,
        uint256 amountBDesired,
        LpData memory lpData
    ) private pure returns(uint256 liquidity) {
        uint256 amountBOptimal = amountADesired * lpData.reserveB / lpData.reserveA;

        uint256 amountA;
        uint256 amountB;
        if (amountBOptimal <= amountBDesired) {
            (amountA, amountB) = (amountADesired, amountBOptimal);
        } else {
            uint256 amountAOptimal = amountBDesired * lpData.reserveA / lpData.reserveB;
            (amountA, amountB) = (amountAOptimal, amountBDesired);
        }

        liquidity = Math.min(
            amountA * lpData.totalSupply / lpData.reserveA,
            amountB * lpData.totalSupply / lpData.reserveB
        );
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. It the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`.
        // We also know that `k`, the position of the most significant bit, is such that `msb(a) = 2**k`.
        // This gives `2**k < a <= 2**(k+1)` → `2**(k/2) <= sqrt(a) < 2 ** (k/2+1)`.
        // Using an algorithm similar to the msb conmputation, we are able to compute `result = 2**(k/2)` which is a
        // good first aproximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1;
        uint256 x = a;
        if (x >> 128 > 0) {
            x >>= 128;
            result <<= 64;
        }
        if (x >> 64 > 0) {
            x >>= 64;
            result <<= 32;
        }
        if (x >> 32 > 0) {
            x >>= 32;
            result <<= 16;
        }
        if (x >> 16 > 0) {
            x >>= 16;
            result <<= 8;
        }
        if (x >> 8 > 0) {
            x >>= 8;
            result <<= 4;
        }
        if (x >> 4 > 0) {
            x >>= 4;
            result <<= 2;
        }
        if (x >> 2 > 0) {
            result <<= 1;
        }

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        uint256 result = sqrt(a);
        if (rounding == Rounding.Up && result * result < a) {
            result += 1;
        }
        return result;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBabyDogeRouter {
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

  function transactionFee(address _tokenIn, address _tokenOut, address _msgSender)
    external
    view
    returns (uint256);
  function factory() external pure returns (address);

  function WETH() external pure returns (address);

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

  function quote(
    uint256 amountA,
    uint256 reserveA,
    uint256 reserveB
  ) external pure returns (uint256 amountB);

  function getAmountsOut(uint256 amountIn, address[] calldata path)
  external
  view
  returns (uint256[] memory amounts);

  function getAmountsIn(uint256 amountOut, address[] calldata path)
  external
  view
  returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBabyDogeFactory {
  function feeTo() external view returns (address);
  function feeToTreasury() external view returns (address);
  function feeToSetter() external view returns (address);

  function getPair(address tokenA, address tokenB)
    external
    view
    returns (address pair);

  function allPairs(uint256) external view returns (address pair);

  function allPairsLength() external view returns (uint256);

  function createPair(address tokenA, address tokenB)
    external
    returns (address pair);

  function setRouter(address) external;

  function setFeeTo(
    address _feeTo,
    address _feeToTreasury
  ) external;

  function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBabyDogePair {
  function totalSupply() external view returns (uint256);
  function balanceOf(address owner) external view returns (uint256);
  function allowance(address owner, address spender)
    external
    view
    returns (uint256);

  function approve(address spender, uint256 value) external returns (bool);

  function transfer(address to, uint256 value) external returns (bool);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool);

  function nonces(address owner) external view returns (uint256);

  function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;

  function factory() external view returns (address);
  function token0() external view returns (address);
  function token1() external view returns (address);

  function getReserves()
    external
    view
    returns (
      uint112 reserve0,
      uint112 reserve1,
      uint32 blockTimestampLast
    );

  function price0CumulativeLast() external view returns (uint256);
  function price1CumulativeLast() external view returns (uint256);
  function kLast() external view returns (uint256);
  function mint(address to) external returns (uint256 liquidity);
  function burn(address to) external returns (uint256 amount0, uint256 amount1);

  function swap(
    uint256 amount0Out,
    uint256 amount1Out,
    address to,
    bytes calldata data
  ) external;

  function skim(address to) external;

  function sync() external;

  function initialize(
    address,
    address,
    address
  ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFarm {
    function depositOnBehalf(uint256 amount, address account) external;
    function stakeToken() external returns(address);
}