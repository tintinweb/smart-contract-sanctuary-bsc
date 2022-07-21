pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract Stop {

    constructor () public {
        owner = payable(msg.sender);
        enterFees = 100;
        leaveFees = 200;
        deadline = 300000;
        wETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    }

    event OrderCalled(string, address, address, uint);
    event Approved(address, address, uint);
    event OrderSet(string, address, uint, uint, address);

    mapping(string => address) router;
    mapping(address => mapping(address => uint)) orders;

    address wETH;
    address payable owner;
    uint enterFees;
    uint leaveFees;
    uint deadline;

    /**
    * @dev modifier to owner access
     */

     modifier onlyOwner{
        require(msg.sender == owner, "Hey hey hey you can't use this function");
        _;
     }

    /**
    * @dev return the amount of an order
    * @param _trader the order setter
    * @param _token token address
     */

    function getOrder(address _trader, address _token) external view returns(uint){
        return orders[_trader][_token];
    } 

    /**
    * @dev function to pass ownership
    * @param _address address that should be the new owner
     */

    function transferOwnership(address payable _address) external returns(bool){
        owner = _address;
        return true;
    }

    /**
    * @dev function to set the enter fees
    * @param _fees value of the fees;
     */

    function setEnterFees(uint _fees) external onlyOwner returns(bool){
        enterFees = _fees;
        return true;
    }

    /**
    * @dev function to set the leave fees
    * @param _fees value of the fees;
     */

    function setLeaveFees(uint _fees) external onlyOwner returns(bool){
        leaveFees = _fees;
        return true;
    }

    /**
    * @dev set wETH address
    * @param _address address of wETH
    */

    function setWETH(address _address) external onlyOwner returns(bool){
        wETH = _address;
        return true;
    }

    /**
    * @dev set deadline
    * @param _deadline deadline as uint;
    */

    function setDeadline(uint _deadline) external onlyOwner returns(bool){
        deadline = _deadline;
        return true;
    }

    /**
    * @dev function to set the address of the router
    * @param _router string for the router
    * @param _address address of the router
     */

     function setRouter(string memory _router, address _address) external onlyOwner returns(bool){
        router[_router] = _address;
        return true;
     }    


    /**
    * @dev set order and pay the fees
    * @param _router string that represents the router to be called. For each string representing the router there's a address associdated
    * @param _token address of the token to be selled
    * @param _amount of the order
    * @param _trigger value to trigger the function  
     */

    function setOrder(string memory _router, address _token, uint _amount, uint _trigger) external {
        address[] memory path = new address[](2);
        path[0] = _token;
        path[1] = IUniswapV2Router02(router[_router]).WETH();        
        uint fees = (_amount / 10000) * enterFees;
        uint chargedAmount = _amount - fees;
        IERC20(_token).transferFrom(msg.sender, address(this), fees);
        IUniswapV2Router02(router[_router]).swapExactTokensForTokensSupportingFeeOnTransferTokens(fees, 0, path, address(this), deadline);
        orders[msg.sender][_token] = chargedAmount;
        emit OrderSet(_router, _token, chargedAmount, _trigger, msg.sender);
    } 

    /**
    * @dev function to trigger order to be called externaly from a backend script. Needs to be checked from block to block if the 
      params are fullfilled then should be triggered.
    * @param _router string that represents the router to be called. For each string representing the router there's a address associdated
    * @param _token address of the token to be selled
    * @param _trader address that will receive the ether from the order execution
    * @param _amount of the order  
     */ 

    function triggerOrder(string memory _router, address _token, address _trader, uint _amount) external onlyOwner {
        address[] memory path = new address[](2);
        path[0] = _token;
        path[1] = IUniswapV2Router02(router[_router]).WETH();
        uint fees = (_amount / 10000) * leaveFees;
        uint chargedAmount = _amount - fees;
        IUniswapV2Router02(router[_router]).swapExactTokensForTokensSupportingFeeOnTransferTokens(chargedAmount, 0, path, _trader, deadline);
        emit OrderCalled(_router, _token, _trader, _amount);
    }

    function withdrawn() external onlyOwner returns(bool){
        owner.transfer(address(this).balance);
        return true;
    }


}

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

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

pragma solidity >=0.6.2;

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