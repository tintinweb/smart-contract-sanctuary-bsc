// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/IArborSwapRouter02.sol";
import "./interfaces/IArborSwapFactory.sol";

// found issue with transfer fee tokens
contract DEXManagement is Ownable, Pausable, ReentrancyGuard {
    
    //--------------------------------------
    // State variables
    //--------------------------------------

    address public TREASURY;                // Must be multi-sig wallet or Treasury contract
    uint256 public SWAP_FEE;                // Fee = SWAP_FEE / 10000
    uint256 public SWAP_FEE_EXTERNAL;             // Fee = SWAP_FEE_EXTERNAL / 10000

    IArborSwapRouter02 public defaultRouter;
    IArborSwapRouter02 public externalRouter;

    uint public constant DUST_VALUE = 1000;

    //-------------------------------------------------------------------------
    // EVENTS
    //-------------------------------------------------------------------------

    event LogReceived(address indexed, uint);
    event LogFallback(address indexed, uint);
    event LogSetTreasury(address indexed, address indexed);
    event LogSetSwapFee(address indexed, uint256);
    event LogSetSwapFeeExternal(address indexed, uint256);
    event LogSetDexRouter(address indexed, address indexed);
    event LogWithdraw(address indexed, uint256, uint256);
    event LogSwapExactTokensForTokens(address indexed, address indexed, uint256, uint256);
    event LogSwapExactETHForTokens(address indexed, uint256, uint256);
    event LogSwapExactTokenForETH(address indexed, uint256, uint256);
    event LogSwapTokenForExactETH(address indexed, uint256, uint256);
    event LogSwapTokenForExactToken(address indexed, address indexed, uint256, uint256);
    event LogSwapETHForExactToken(address indexed, uint256, uint256);

    //-------------------------------------------------------------------------
    // CONSTRUCTOR
    //-------------------------------------------------------------------------

    /**
     * @param   _defaultRouter: default Arbor router address
     * @param   _externalRouter: external router address, can be pcs or else
     * @param   _treasury: treasury address
     * @param   _swapFee: swap fee value
     * @param   _swapFeeExternal: swap fee for External value
     */
    constructor(
        address _defaultRouter,
        address _externalRouter, 
        address _treasury,
         uint256 _swapFee, 
         uint256 _swapFeeExternal 
    ) 
    {
        require(_treasury != address(0), "Zero address");
        defaultRouter = IArborSwapRouter02(_defaultRouter);
        externalRouter = IArborSwapRouter02(_externalRouter);
        TREASURY = _treasury;
        SWAP_FEE = _swapFee;
        SWAP_FEE_EXTERNAL = _swapFeeExternal;
    }

    /**
     * @param   _tokenA: tokenA contract address
     * @param   _tokenB: tokenB contract address
     * @return  bool: if pair is in Arbor, return true, else, return false.
     */
    function isPairExists(address _tokenA, address _tokenB, uint _type) public view returns(bool){ 
        if (_type == 0) {
            return IArborSwapFactory(defaultRouter.factory()).getPair(_tokenA, _tokenB) != address(0);
        }       
        return IArborSwapFactory(externalRouter.factory()).getPair(_tokenA, _tokenB) != address(0);
    }


    /**
     * @param   _tokenA: tokenA contract address
     * @param   _tokenB: tokenB contract address
     * @return  bool: if path is in DEX, return true, else, return false.
     */
    function isPathExists(address _tokenA, address _tokenB, uint _type) public view returns(bool){   
        if(_type == 0) {
            return IArborSwapFactory(defaultRouter.factory()).getPair(_tokenA, _tokenB) != address(0) || 
                (IArborSwapFactory(defaultRouter.factory()).getPair(_tokenA, defaultRouter.WETH()) != address(0) && 
                IArborSwapFactory(defaultRouter.factory()).getPair(defaultRouter.WETH(), _tokenB) != address(0));
        } else {
            return IArborSwapFactory(externalRouter.factory()).getPair(_tokenA, _tokenB) != address(0) || 
                (IArborSwapFactory(externalRouter.factory()).getPair(_tokenA, externalRouter.WETH()) != address(0) && 
                IArborSwapFactory(externalRouter.factory()).getPair(externalRouter.WETH(), _tokenB) != address(0));
        }     
    }

    /**
     * @param   tokenA: InputToken Address to swap on Arborswap
     * @param   tokenB: OutputToken Address to swap on Arborswap
     * @param   _amountIn: Amount of InputToken to swap on Arborswap
     * @param   _amountOutMin: The minimum amount of output tokens that must be received 
     *          for the transaction not to revert.
     * @param   to: Recipient of the output tokens.
     * @param   deadline: Deadline, Timestamp after which the transaction will revert.
     * @notice  Swap ERC20 token to ERC20 token on Arborswap
     */
    function swapExactTokensForTokens(
        address tokenA, 
        address tokenB, 
        uint256 _amountIn, 
        uint256 _amountOutMin, 
        address to, 
        uint deadline,
        uint _type
    ) external whenNotPaused nonReentrant {
        require(isPathExists(tokenA, tokenB, _type), "Invalid path");
        require(_amountIn > 0 , "Invalid amount");
        require(IERC20(tokenA).transferFrom(_msgSender(), address(this), _amountIn), "Failed TransferFrom");
        uint256 _swapAmountIn = _amountIn * (10000 - SWAP_FEE) / 10000;
        
        IArborSwapRouter02 selectedRouter = _type == 0 ? defaultRouter : externalRouter;

        require(IERC20(tokenA).approve(address(selectedRouter), _swapAmountIn), "Failed Approve");


        address[] memory path;
        if (isPairExists(tokenA, tokenB, _type)) 
        {
            path = new address[](2);
            path[0] = tokenA;
            path[1] = tokenB;
        }         
        else {
            path = new address[](3);
            path[0] = tokenA;
            path[1] = selectedRouter.WETH();
            path[2] = tokenB;
        }
        
        uint256 boughtAmount = IERC20(tokenB).balanceOf(to);
        selectedRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _swapAmountIn,
            _amountOutMin,  
            path,
            to,
            deadline
        );
        boughtAmount = IERC20(tokenB).balanceOf(to) - boughtAmount;

        require(IERC20(tokenA).transfer(TREASURY, _amountIn - _swapAmountIn), "Failed Transfer");

        emit LogSwapExactTokensForTokens(tokenA, tokenB, _amountIn, boughtAmount);
    }

    /**
     * @param   token: OutputToken Address to swap on Arborswap
     * @param   _amountOutMin: The minimum amount of output tokens that must be received 
     *          for the transaction not to revert.
     * @param   to: Recipient of the output tokens.
     * @param   deadline: Deadline, Timestamp after which the transaction will revert.
     * @notice  Swap ETH to ERC20 token on Arborswap
     */
    function swapExactETHForTokens(
        address token, 
        uint256 _amountOutMin, 
        address to, 
        uint deadline,
        uint _type
    ) external payable whenNotPaused nonReentrant {
        IArborSwapRouter02 selectedRouter = _type == 0 ? defaultRouter : externalRouter;
        require(isPathExists(token, selectedRouter.WETH(), _type), "Invalid path");
        require(msg.value > 0 , "Invalid amount");

        address[] memory path = new address[](2);
        path[0] = selectedRouter.WETH();
        path[1] = token;
        
        uint256 _swapAmountIn = msg.value * (10000 - SWAP_FEE) / 10000;

        uint256 boughtAmount = IERC20(token).balanceOf(to);
        selectedRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: _swapAmountIn}(                
            _amountOutMin,
            path,
            to,
            deadline
        );
        boughtAmount = IERC20(token).balanceOf(to) - boughtAmount;
        payable(TREASURY).transfer(msg.value - _swapAmountIn);
        emit LogSwapExactETHForTokens(token, msg.value, boughtAmount);
    }

    /**
     * @param   token: InputToken Address to swap on Arborswap
     * @param   _amountIn: Amount of InputToken to swap on Arborswap
     * @param   _amountOutMin: The minimum amount of output tokens that must be received 
     *          for the transaction not to revert.
     * @param   to: Recipient of the output tokens.
     * @param   deadline: Deadline, Timestamp after which the transaction will revert.
     * @notice  Swap ERC20 token to ETH on Arborswap
     */
    function swapExactTokenForETH(
        address token, 
        uint256 _amountIn, 
        uint256 _amountOutMin, 
        address to, 
        uint deadline,
        uint _type
    ) external whenNotPaused nonReentrant {
        IArborSwapRouter02 selectedRouter = _type == 0 ? defaultRouter : externalRouter;
        require(isPathExists(token, selectedRouter.WETH(), _type), "Invalid path");
        require(_amountIn > 0 , "Invalid amount");

        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = selectedRouter.WETH();
        
        require(IERC20(token).transferFrom(_msgSender(), address(this), _amountIn), "Failed TransferFrom");
        uint256 _swapAmountIn = _amountIn * (10000 -  SWAP_FEE) / 10000;
        
        require(IERC20(token).approve(address(selectedRouter), _swapAmountIn), "Failed Approve");
        
        uint256 boughtAmount = address(to).balance;
        selectedRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(   
            _swapAmountIn,         
            _amountOutMin,         
            path,
            to,
            deadline
        );
        boughtAmount = address(to).balance - boughtAmount;
        require(IERC20(token).transfer(TREASURY, _amountIn - _swapAmountIn), "Failed Transfer");
        emit LogSwapExactTokenForETH(token, _amountIn, boughtAmount);
    }

    function swapETHForExactTokens(
        address token,
        uint256 amountOut,
        address to,
        uint256 deadline,
        uint _type
    ) external payable whenNotPaused nonReentrant {
        IArborSwapRouter02 selectedRouter = _type == 0 ? defaultRouter : externalRouter;
        require(isPathExists(selectedRouter.WETH(), token, _type), "Invalid path");
        
        address[] memory path = new address[](2);
        path[0] = selectedRouter.WETH();
        path[1] = token;

        uint256[] memory amountInMins = selectedRouter.getAmountsIn(amountOut, path);

        uint256 _swapFee = amountInMins[0] * SWAP_FEE / 10000;
        uint256 totalInMin = amountInMins[0] + _swapFee + DUST_VALUE;
        require(msg.value >= totalInMin , "Invalid amount");

        selectedRouter.swapETHForExactTokens{value: amountInMins[0]}(                
            amountOut,
            path,
            to,
            deadline
        );

        payable(TREASURY).transfer(_swapFee);

        // refund dust if exist
        if(msg.value > totalInMin) {
            payable(msg.sender).transfer(msg.value - totalInMin);
        }
        emit LogSwapETHForExactToken(token, msg.value, amountOut);
    }

    function swapTokensForExactETH(
        address token, 
        uint256 _amountIn, 
        uint256 _amountOut, 
        address to,
        uint256 deadline,
        uint _type
    ) external payable whenNotPaused nonReentrant {
        IArborSwapRouter02 selectedRouter = _type == 0 ? defaultRouter : externalRouter;
        require(isPathExists(token, selectedRouter.WETH(), _type), "Invalid path");

        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = selectedRouter.WETH();

        uint256[] memory amountInMins = selectedRouter.getAmountsIn(_amountOut, path);

        uint256 _swapFee = amountInMins[0] * SWAP_FEE / 10000;
        uint256 amountToRouter = amountInMins[0] + DUST_VALUE;
        uint256 totalInMin = amountToRouter + _swapFee;

        require(_amountIn > totalInMin , "Invalid amount");
        
        require(IERC20(token).transferFrom(_msgSender(), address(this), totalInMin), "Failed TransferFrom");
        
        require(IERC20(token).approve(address(selectedRouter), totalInMin),"Failed Approve");

       selectedRouter.swapTokensForExactETH(   
            _amountOut,         
            amountToRouter,         
            path,
            to,
            deadline
        );

        require(IERC20(token).transfer(TREASURY, _swapFee), "Failed Transfer");

        emit LogSwapTokenForExactETH(token, totalInMin, _amountOut);
    }

    function swapTokensForExactTokens(
        address tokenA, 
        address tokenB, 
        uint256 _amountIn, 
        uint256 _amountOut, 
        address to,
        uint256 deadline,
        uint _type
    ) external payable whenNotPaused nonReentrant {
        IArborSwapRouter02 selectedRouter = _type == 0 ? defaultRouter : externalRouter;
        require(isPathExists(tokenA, tokenB, _type), "Invalid path");

        address[] memory path;
        if (isPairExists(tokenA, tokenB, _type)) 
        {
            path = new address[](2);
            path[0] = tokenA;
            path[1] = tokenB;
        }         
        else {
            path = new address[](3);
            path[0] = tokenA;
            path[1] = defaultRouter.WETH();
            path[2] = tokenB;
        }
        uint256[] memory amountInMins = selectedRouter.getAmountsIn(_amountOut, path);
        uint256 _swapFee = amountInMins[0] * SWAP_FEE / 10000;
        uint256 amountToRouter = amountInMins[0] + DUST_VALUE;
        uint256 totalInMin = amountToRouter + _swapFee;

        require(_amountIn > totalInMin , "Invalid amount");

        require(IERC20(tokenA).transferFrom(_msgSender(), address(this), totalInMin), "Failed TransferFrom");
        
        require(IERC20(tokenA).approve(address(selectedRouter), amountToRouter),"Failed Approve");

        
        selectedRouter.swapTokensForExactTokens(
            _amountOut,  
            amountToRouter,
            path,
            to,
            deadline
        );

        require(IERC20(tokenA).transfer(TREASURY, _swapFee), "Failed Transfer");

        emit LogSwapTokenForExactToken(tokenA, tokenB, totalInMin, _amountOut);
    }

    
    function withdraw(address token) external onlyOwner nonReentrant {
        require(IERC20(token).balanceOf(address(this)) > 0 || address(this).balance > 0, "Zero Balance!");

        if(address(this).balance > 0) {
            payable(_msgSender()).transfer(address(this).balance);
        }
        
        uint256 balance = IERC20(token).balanceOf(address(this));
        if(balance > 0) {
            require(IERC20(token).transfer(_msgSender(), balance), "Failed Transfer");
        }
        
        emit LogWithdraw(_msgSender(), balance, address(this).balance);
    }

    receive() external payable {
        emit LogReceived(_msgSender(), msg.value);
    }

    fallback() external payable { 
        emit LogFallback(_msgSender(), msg.value);
    }

    //-------------------------------------------------------------------------
    // set functions
    //-------------------------------------------------------------------------

    function setPause() external onlyOwner {
        _pause();
    }

    function setUnpause() external onlyOwner {
        _unpause();
    }

    function setTreasury(address _newTreasury) external onlyOwner whenNotPaused {
        require(TREASURY != _newTreasury, "Same address!");
        TREASURY = _newTreasury;

        emit LogSetTreasury(_msgSender(), TREASURY);
    }

    function setSwapFee(uint256 _newSwapFee) external onlyOwner whenNotPaused {
        require(SWAP_FEE != _newSwapFee, "Same value!");
        SWAP_FEE = _newSwapFee;

        emit LogSetSwapFee(_msgSender(), SWAP_FEE);
    }

    function setSwapFeeExternal(uint256 _newSwapFeeExternal) external onlyOwner whenNotPaused {
        require(SWAP_FEE_EXTERNAL != _newSwapFeeExternal, "Same value!");
        SWAP_FEE_EXTERNAL = _newSwapFeeExternal;

        emit LogSetSwapFeeExternal(_msgSender(), SWAP_FEE_EXTERNAL);
    }

    function setDefaultRouter(address _newRouter) external onlyOwner whenNotPaused {
        require(address(defaultRouter) != _newRouter, "Same router!");
        defaultRouter = IArborSwapRouter02(_newRouter);
        
        emit LogSetDexRouter(_msgSender(), address(defaultRouter));
    }

    function setExternalRouter(address _newRouter) external onlyOwner whenNotPaused {
        require(address(externalRouter) != _newRouter, "Same router!");
        externalRouter = IArborSwapRouter02(_newRouter);
        
        emit LogSetDexRouter(_msgSender(), address(externalRouter));
    }
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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.2;

import './IArborSwapRouter01.sol';

interface IArborSwapRouter02 is IArborSwapRouter01 {
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
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0;

interface IArborSwapFactory {
  event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

  function feeTo() external view returns (address);

  function feeToSetter() external view returns (address);

  function migrator() external view returns (address);

  function getPair(address tokenA, address tokenB) external view returns (address pair);

  function allPairs(uint256) external view returns (address pair);

  function allPairsLength() external view returns (uint256);

  function createPair(address tokenA, address tokenB) external returns (address pair);

  function setFeeTo(address) external;

  function setFeeToSetter(address) external;

  function setMigrator(address) external;
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.2;

interface IArborSwapRouter01 {
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

  function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

  function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}