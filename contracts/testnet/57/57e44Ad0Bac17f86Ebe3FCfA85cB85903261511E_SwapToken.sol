// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IUniswap {
    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external ;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function WETH() external pure returns (address);
}

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

contract SwapToken {
    IUniswap uniswap;

    constructor (address _uniswap) {
        uniswap = IUniswap(_uniswap); // Router adress
    }

    function swapExactETHForTokens(
        address tokenToSwap,
        uint256 amountOutMin //slip page
    ) external payable {
        address[] memory path = new address[](2);
        path[0] = uniswap.WETH();
        path[1] = tokenToSwap;
        uniswap.swapExactETHForTokens{value: msg.value}(amountOutMin, path, msg.sender, block.timestamp + (1000 * 60 *60 * 100));
    }
    // Supporting fee transfer token
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        address tokenToSwap,
        uint256 amountOutMin //slip page
    ) external payable{
        address[] memory path = new address[](2);
        path[0] = uniswap.WETH();
        path[1] = tokenToSwap;
        uniswap.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(amountOutMin, path, msg.sender, block.timestamp + (1000 * 60 *60 * 100));
    }

    function swapExactTokensForETH(
        address token,
        uint256 amountIn,
        uint256 amountOutMin //Slip page
    ) external {
        // Transfer value to this contract
        // IERC20(token).transferFrom(msg.sender, address(this), amountIn);
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = uniswap.WETH();
        IERC20(token).transferFrom(msg.sender, address(this), amountIn);
    
        //next we need to allow the uniswapv2 router to spend the token we just sent to this contract
        //by calling IERC20 approve you allow the uniswap contract to spend the tokens in this contract 
        IERC20(token).approve(address(uniswap), amountIn);
        uniswap.swapExactTokensForETH(amountIn, amountOutMin, path, msg.sender, block.timestamp + (1000 * 60 *60 * 100));
    }

    // Supporting fee transfer token
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        address token,
        uint256 amountIn,
        uint256 amountOutMin //Slip page
    ) external {
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = uniswap.WETH();
        IERC20(token).transferFrom(msg.sender, address(this), amountIn);
    
        //next we need to allow the uniswapv2 router to spend the token we just sent to this contract
        //by calling IERC20 approve you allow the uniswap contract to spend the tokens in this contract 
        IERC20(token).approve(address(uniswap), amountIn);
        uniswap.swapExactTokensForETHSupportingFeeOnTransferTokens(amountIn, amountOutMin, path, msg.sender, block.timestamp + (1000 * 60 *60 * 100));
    }
    
    function wethAddress() public view returns (address)  {
        return uniswap.WETH();
    }

    function contractAddress() public view returns (address)  {
        return address(this);
    }
}