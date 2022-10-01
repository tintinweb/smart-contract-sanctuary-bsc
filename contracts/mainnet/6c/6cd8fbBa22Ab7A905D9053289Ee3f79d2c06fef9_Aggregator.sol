// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "IERC20.sol";
import "IUniswapV2Router.sol";
import "Arrays.sol";

contract Aggregator {
    using Arrays for uint[];
    IUniswapV2Router[] public routers;
    address[] public connectors;

    /**
      * @dev Constructor of contract
      * @param _routers UniswapV2-like routers 
      * @param _connectors Connectors tokens 
      */
    constructor(
        IUniswapV2Router[] memory _routers, 
        address[] memory _connectors
    ) 
    {
        routers = _routers;
        connectors = _connectors;
    }

    /**
        @dev Gets router and path that give max output amount with input amount and tokens
        @param amountIn Input amount
        @param tokenIn Source token
        @param tokenOut Destination token
        @return amountOut Output amount
        @return router Uniswap-like router
        @return path Token list to swap
     */
    function quote(
        uint amountIn,
        address tokenIn,
        address tokenOut
    ) external view returns (uint amountOut, address router, address[] memory path) {
        require(tokenIn != tokenOut, "Aggregator::quote: tokenIn is tokenOut");
        
        for (uint i = 0; i < routers.length; i++) {
            address[] memory _path = Arrays.new2d(tokenIn, tokenOut);
            uint _amountOut = getAmountOutSafe(routers[i], _path, amountIn);
            if (_amountOut > amountOut) {
                amountOut = _amountOut;
                path = _path;
                router = address(routers[i]);
            }
            for (uint j = 0; j < connectors.length; j++) {
                if (tokenIn == connectors[j] || tokenOut == connectors[j]) {
                    continue;
                }
                _path = Arrays.new3d(tokenIn, connectors[j], tokenOut);                
                _amountOut = getAmountOutSafe(routers[i], _path, amountIn);
                if (_amountOut > amountOut) {
                    amountOut = _amountOut;
                    path = _path;
                    router = address(routers[i]);
                }
            }
        }
    }

    /**
        @dev Gets amount out for router and path, zero if route is incorrect
        @param router Uniswap-like router
        @param path Token list to swap
        @param amountIn Input amount
        @return amountOut Output amount
     */
    function getAmountOutSafe(
        IUniswapV2Router router,
        address[] memory path,
        uint amountIn
    ) public view returns (uint amountOut) {
        bytes memory payload = abi.encodeWithSelector(router.getAmountsOut.selector, amountIn, path);
        (bool success, bytes memory res) = address(router).staticcall(payload);
        if (success && res.length > 32) {
            amountOut = Arrays.getLastUint(res);
        }
    }
    
    /**
        Swaps tokens on router with path
        @param amountIn Input amount
        @param amountOutMin Minumum output amount
        @param router Uniswap-like router to swap tokens on
        @param path Tokens list to swap
        @return amountOut Actual output amount
     */
    function swap(
        uint amountIn,
        uint amountOutMin,
        IUniswapV2Router router,
        address[] memory path
    ) external returns (uint amountOut) {
        IERC20 tokenIn = IERC20(path[0]);
        tokenIn.transferFrom(msg.sender, address(this), amountIn);
        tokenIn.approve(address(router), amountIn);
        return router.swapExactTokensForTokens({
            amountIn: amountIn,
            amountOutMin: amountOutMin,
            path: path,
            to: msg.sender,
            deadline: block.timestamp
        }).last();
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IUniswapV2Router {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

library Arrays {
    function last(uint256[] memory a) internal pure returns (uint256) {
        return a[a.length - 1];
    }
    
    function new2d(address a0, address a1) internal pure returns (address[] memory) {
        address[] memory res = new address[](2);
        res[0] = a0;
        res[1] = a1;
        return res;
    }

    function new3d(address a0, address a1, address a2) internal pure returns (address[] memory) {
        address[] memory res = new address[](3);
        res[0] = a0;
        res[1] = a1;
        res[2] = a2;
        return res;
    }
    function getLastUint(bytes memory data) internal pure returns (uint res) {
        require(data.length >= 32, "Arrays::getLastUint: Cannot get last uint");
        uint i = data.length - 32;
        assembly {
            res := mload(add(data, add(0x20, i)))
        }
    }
}