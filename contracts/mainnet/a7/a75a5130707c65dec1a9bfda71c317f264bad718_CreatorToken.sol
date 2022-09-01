/**
 *Submitted for verification at BscScan.com on 2022-09-01
*/

pragma solidity ^0.6.12;
// SPDX-License-Identifier: Unlicensed

//
// CREATOR 
//
// (fair launch utility token for use in creator enabled applications, communities and metaverse)
// Features include but not limited to burn down to minimum supply, optional liquidity, foundation, metaverseInfrastructure and charity deductions per transaction
// Controls to throttle, enable/disable and adjust deduction settings within locked in limits
// See code for details
//


//===========================================================
//
//  #####  ######  #######    #    ####### ####### ######  
// #     # #     # #         # #      #    #     # #     # 
// #       #     # #        #   #     #    #     # #     # 
// #       ######  #####   #     #    #    #     # ######  
// #       #   #   #       #######    #    #     # #   #   
// #     # #    #  #       #     #    #    #     # #    #  
//  #####  #     # ####### #     #    #    ####### #     # 
//
//===========================================================


//
// -- CREATE, SHARE, PLAY, CONNECT, ENGAGE                              
// -- WHERE CR38R'S FORGE THE FUTURE
//

//
// This started with an incredible desire to empower the creativity of
// an entire new generation of builders...   

// We are just a point... a spark...  in the darkness of space
// with all the potential to ignite and expand beyond our collective imagination
//
// We are CREATORS
//
// Let's BUILD
//
// Let's CREATE

interface IERC20 {

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
 
library SafeMath {
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by 0");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by 0");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function ceil(uint a, uint m) internal pure returns (uint r) {
        return (a + m - 1) / m * m;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


/**
 * @dev Collection of functions related to the address type
 */
library Address {
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
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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
contract Ownable is Context {
    address private     _owner;
    address private     _previousOwner;
    uint256 internal    _lockTime;
    uint256 internal    _lockDeductionsTime;
    uint256 internal    _lockWithdrawalsTime;
    bool private        _isRenounceSafetyEnabled=true;

    //
    // EVENTS
    //
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Lock(uint256);
    event Unlock();
    event SetRenounceSafety( bool isEnabled );
    event LockDeductions(uint256);
    event LockWithdrawals(uint256);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        require( _isRenounceSafetyEnabled == false, "CR38R: Renounce safety must be off");
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
        _previousOwner = address(0); // per certik and hashex audit, ensure lock/unlock cannot undo renounceownership
    }

    // preventive step to ensure owner/dao don't inadverently renounce
    function setRenounceSafety(bool isEnabled ) external onlyOwner() {
        require( _isRenounceSafetyEnabled != isEnabled, "CR38R: Renounce safety already set to this value");
        _isRenounceSafetyEnabled = isEnabled;
        emit SetRenounceSafety(isEnabled);
    }

    // return safety status
    function isRenounceSafetyEnabled() public view returns(bool) { return _isRenounceSafetyEnabled;}


    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the 0 address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    //
    // Lock / Unlock system (if needed)
    //

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    function getCurrentTime() public view returns (uint256) {
        return now;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _lockTime = now + time;
        emit OwnershipTransferred(_owner, address(0));
        emit Lock(_lockTime);
        _previousOwner = _owner;
        _owner = address(0);
    }
    
    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "No permission to unlock");
        require(now > _lockTime , "Contract is time locked");
        emit OwnershipTransferred(_owner, _previousOwner);
        emit Unlock();
        _owner = _previousOwner;
    }


    //
    // DEDUCTION DAO/OWNER CONTROLS (if needed)
    //
    function getLockDeductionsTime() public view returns (uint256) {
        return _lockDeductionsTime;
    }

    function lockDeductions(uint256 time) public virtual onlyOwner {
        _lockDeductionsTime = now + time;
        emit LockDeductions(_lockDeductionsTime);
    }
    
    // returns true if time locked
    function deductionsTimeLocked() public view returns(bool) {
        return now < _lockDeductionsTime;
    }

    //
    // WITHDRAWALS DAO/OWNER CONTROL (if needed)
    //
    function getLockWithdrawalsTime() public view returns (uint256) {
        return _lockWithdrawalsTime;
    }

    function lockWithdrawals(uint256 time) public virtual onlyOwner {
        _lockWithdrawalsTime = now + time;
        emit LockWithdrawals(_lockWithdrawalsTime);
    }
    
    // returns true if time locked
    function withdrawalsTimeLocked() public view returns(bool) {
        return now < _lockWithdrawalsTime;
    }

}

// pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


// pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// pragma solidity >=0.6.2;

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

// pragma solidity >=0.6.2;

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

//===========================================================
//
//  #####  ######  #######    #    ####### ####### ######  
// #     # #     # #         # #      #    #     # #     # 
// #       #     # #        #   #     #    #     # #     # 
// #       ######  #####   #     #    #    #     # ######  
// #       #   #   #       #######    #    #     # #   #   
// #     # #    #  #       #     #    #    #     # #    #  
//  #####  #     # ####### #     #    #    ####### #     # 
//   
//===========================================================

contract CreatorToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    // ACCOUNT BALANCES & ALLOWANCES
    mapping (address => uint256) private                        _balances;
    mapping (address => mapping (address => uint256)) private   _allowances;

    // ACCOUNTS THAT ARE EXCLUDED (ie, EXCHANGES, )
    mapping (address => bool) private                           _isExcludedFromFee;
    mapping(address => bool) private                            _isBlocked;


    // TOKEN INFO
    uint256 private                                             _totalSupply    = 1000 * 10**6 * 10**9;

    //================================================================
    // CREATOR (aka CR38R)
    // (this logo inspired by the 80's art scene coming out of skating)
    //================================================================
    //      ,╓╓,,      , ,,,,,,                    ,,,      ╔╗╦εε╓
    //   ╓▒╠╠╠╠╠╠╠▒╖   ╔φφ░▒▒▒░ ▒╠   └╝╝╝╝╝╝▀▀   ;;"^"╓ε    ╬╬``"╠╠ε
    //  ╬╠╠╬  ,,└╠╠╠▒  ╙▒▒╙    `╠╬ [        ░░   \\  .╙δ    ╠╠   ,▒╠
    // ]╠╠╠L ▓▓▓▓▓▓╬╠ε ╚╠╠╬, ,,φ╠╠▒  ╒φφφφφ#φ▒   =,=ⁿ=░=    ▓▓▓▓▓▓╬
    //  ╠╠╠▒ ▀╣▀╙╟▓▓▓⌐ ╚╠╠╠╩ ╠╠╠╠╙          ░░  [∩     ░▐   ╠╬   ╙╠▒
    //  `╬╠╠▒╗▄▄▓▓▓▓╜  ╚╠╠Γ  └╠╠╠▒          ░░  \\     ≡╔   ╠╠    ╠╠
    //   `╙╝╠╬╣▓▀╙    , ╠╠    ╚╠╠▒, ^╩╩╩╩╩╩╝╜   "="░"«"    ╚╩    ╝╩
    //================================================================


    string private                                              _name = "CREATOR";
    string private                                              _symbol = "CREATOR";
    uint8 private                                               _decimals = 9;
    



    //
    // DEDUCTIONS & FEES ON TRANSFERS RELATED TO BURN AND MIN SUPPLY 
    // 
    // 


    // never auto burn below 21 million (we start with 1B, can burn down) - enforced in code
    // once we reach 21M (unless our DAO )
    uint256 private constant                                    MIN_TOTAL_SUPPLY_FLOOR= 21 * 10**6 * 10**9;

    // burn down to this value (DAO/Foundation can adjust this - but we will stop at 21M like BitCoin)
    uint256 private                                             _minTotalSupplyThreshold =  MIN_TOTAL_SUPPLY_FLOOR;

    uint256 private constant                                    MAX_BURN_PERCENT = 10;
    uint256 private                                             _burnPercent = 1;

    //
    // DEDUCTIONS & FEES ON TRANSFERS
    // 
    bool private                                                _deductionsEnabled = true;

    uint256 private constant                                    MAX_METAVERSE_INFRASTRUCTURE_PERCENT = 10;
    uint256 private                                             _metaverseInfrastructurePercent = 1;
    address payable private                                     _metaverseInfrastructureAccount;


    uint256 private constant                                    MAX_FOUNDATION_PERCENT = 10;
    uint256 private                                             _foundationPercent = 1;
    address payable private                                     _foundationAccount;
    
    uint256 private constant                                    MAX_LIQUIDITY_PERCENT = 10;
    uint256 private                                              _liquidityPercent = 2;

    uint256 private constant                                    MAX_CHARITY_PERCENT = 5;
    uint256 private                                             _charityPercent = 0;
    address payable private                                     _charityAccount;


    // MAX IN AGGREAGATE (TO LIMIT UPPER BOUNDS)
    uint256 private constant                                    MAX_DEDUCTION_PERCENT = MAX_LIQUIDITY_PERCENT + MAX_FOUNDATION_PERCENT + MAX_BURN_PERCENT + MAX_METAVERSE_INFRASTRUCTURE_PERCENT + MAX_CHARITY_PERCENT;

    // LIQUIDITY
    IUniswapV2Router02 private                                   _uniswapV2Router;
    address private                                              _uniswapV2Pair;
    
    bool private                                                _inSwapAndLiquify;
    bool private                                                _swapAndLiquifyEnabled = true;

    uint256 private                                             _numTokensSellToAddToLiquidity = 1 * 10**6 * 10**9;

    // MAX TRANSFER/TRANSACTION AS % OF TOTAL SUPPLY
    uint256 private constant                                    MAX_TRANSFER_PERCENT = 100;
    uint256 private                                              _maxTransferAmount = 1 * 10**6 * 10**9;
    
    // EVENTS
    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);

    event MetaverseAccountSet(address indexed previousAccount, address indexed newAccount);
    event FoundationAccountSet(address indexed previousAccount, address indexed newAccount);
    event CharityAccountSet(address indexed previousAccount, address indexed newAccount);

    event ExcludeFromFee(address indexed account);
    event IncludeInFee(address indexed account);

    event SetDeductionsEnabled( bool enabled );

    event SetBurnPercent(uint256 amount);
    event SetCharityPercent(uint256 amount);
    event SetLiquidityPercent(uint256 amount);
    event SetMetaversePercent(uint256 amount);
    event SetFoundationPercent(uint256 amount);
    
    event SetMinTotalSupplyThreshold(uint256 amount);
    event SetMinTokensBeforeSwap(uint256 minOldAmount, uint256 minNewAmount);
    
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 bnbReceived,
        uint256 tokensIntoLiquidity
    );
    
    modifier lockTheSwap {
        _inSwapAndLiquify = true;
        _;
        _inSwapAndLiquify = false;
    }
    
    //
    // LET'S CREATE!
    //
    constructor () public {

        //
        // Initial tokens created (after which to be added to liquidity)
        //
        _balances[_msgSender()] = _totalSupply;
        
        //
        // default accounts to creator
        //
        setFoundationAccount( payable(_msgSender()) );
        setMetaverseInfrastructureAccount( payable(_msgSender()) );
        setCharityAccount( payable(_msgSender()) );

        //
        // Get our router
        // 
        _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);         // Binance Pancake V2
         
        //
        // Create a uniswap pair for this new token
        //
                
        _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        //exclude owner and this contract from fees
        excludeFromFee( owner() );
        excludeFromFee( address(this));
    
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    //
    // ERC20 FUNCTIONS
    //


    //
    // Needed to receive ETH from pancake/uniswapV2Router when swapping
    // The payable receive() function in makes it possible for the contract to receive ether/bnb, 
    // Moreover, addLiquidityETH() from UniswapV2Router returns any ETH/BNB leftovers back to sender
    // owner or governance dao can decide where to send (ie, to the foundation or metaverse ecoystem )
    // 
    receive() external payable {}

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

   function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(address(recipient) != address(0), "ERC20: Transfer to 0 address, use burn instead");
        require(_balances[_msgSender()] >= amount, "ERC20: Transfer amount exceeds balance");
        require(_balances[recipient] + amount >= _balances[recipient], "ERC20: Resulting transfer recipient amount incorrect");

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(amount <= _allowances[sender][_msgSender()], "ERC20: Transfer amount exceeds allowance");
        require(_balances[sender] >= amount ,"ERC20: Transfer amount exceeds balance");

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    //
    // EXPANDED FEATURES & CAPABILITIES
    //
    function metaverseInfrastructurePercent() public view returns (uint256) { return _metaverseInfrastructurePercent; }
    function foundationPercent() public view returns (uint256) { return _foundationPercent; }
    function liquidityPercent() public view returns (uint256) { return _liquidityPercent; }
    function burnPercent() public view returns (uint256) { return _burnPercent; }
    function charityPercent() public view returns (uint256) { return _charityPercent; }
    function numTokensSellToAddToLiquidity() public view returns (uint256) { return _numTokensSellToAddToLiquidity; }
    function maxTransferAmount() public view returns (uint256) { return _maxTransferAmount; }
    function minTotalSupplyThreshold() public view returns (uint256) { return _minTotalSupplyThreshold; }
    function minTotalSupplyFloor() public pure returns (uint256) { return MIN_TOTAL_SUPPLY_FLOOR; }
    function deductionsEnabled() public view returns(bool) { return _deductionsEnabled;}


    //
    // ADJUST ALLOWANCE (ALTERNATIVELY, CALL APPROVE DIRECTLY WITH NEW VALUE)
    //
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below 0"));

        return true;
    }

    // TO SUPPORT NEW ROUTER ADDRESS
    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(0), "CR38R: cannot be 0 address");
        require(newAddress != address(_uniswapV2Router), "CR38R: address is same");

        emit UpdateUniswapV2Router(newAddress, address(_uniswapV2Router));
        
        _uniswapV2Router = IUniswapV2Router02(newAddress);
                
        address pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        
        _uniswapV2Pair = pair;
        
    }

    //
    // FOR USE FOR EXCHANGES, FOUNDATION, LIQUIDITY, CHARITY, METAVERSE ADDRESSES
    //
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
        emit ExcludeFromFee(account);
    }
    
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
        emit IncludeInFee(account);
    }
    
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    //
    //  WALLET MANAGEMENT
    //
    function setMetaverseInfrastructureAccount(address payable theAccount) public onlyOwner() {
        require(theAccount != address(0), "CR38R: cannot be 0 address");
        emit MetaverseAccountSet( _metaverseInfrastructureAccount, theAccount );
        _metaverseInfrastructureAccount = theAccount;
    }
    function setFoundationAccount(address payable theAccount) public onlyOwner() {
        require(theAccount != address(0), "CR38R: cannot be 0 address");
        emit FoundationAccountSet( _foundationAccount, theAccount );
        _foundationAccount = theAccount;
    }
    function setCharityAccount(address payable theAccount) public onlyOwner() {
        emit CharityAccountSet( _charityAccount, theAccount );
        _charityAccount = theAccount;
    }

    //
    // DEDUCTION PERCENTAGE SETTERS ACCESSORS
    //
    function setDeductionsEnabled(bool isEnabled ) external onlyOwner() {
        require( deductionsTimeLocked() == false, "CR38R: Deduction controls time locked");
        require(_deductionsEnabled != isEnabled, "CR38R: already set");
        _deductionsEnabled = isEnabled;
        emit SetDeductionsEnabled(isEnabled);
    }

    function setMetaverseInfrastructurePercent(uint256 percent) external onlyOwner() {
        require( deductionsTimeLocked() == false, "CR38R: Deduction controls time locked");
        require(percent <= MAX_METAVERSE_INFRASTRUCTURE_PERCENT, "CR38R: exceeds MAX_METAVERSE_INFRASTRUCTURE_PERCENT limit");
        _metaverseInfrastructurePercent = percent;
        require( (_foundationPercent + _metaverseInfrastructurePercent + _burnPercent + _liquidityPercent + _charityPercent)  <= MAX_DEDUCTION_PERCENT, "CR38R: Sum of all deductions exceed acceptable limit");

        emit SetMetaversePercent(percent);
    }

    function setFoundationPercent(uint256 percent) external onlyOwner() {
        require( deductionsTimeLocked() == false, "CR38R: Deduction controls time locked");
        require(percent <= MAX_FOUNDATION_PERCENT, "CR38R: exceeds MAX_FOUNDATION_PERCENT limit");
        _foundationPercent = percent;

        require( (_foundationPercent + _metaverseInfrastructurePercent + _burnPercent + _liquidityPercent + _charityPercent)  <= MAX_DEDUCTION_PERCENT, "CR38R: Sum of all deductions exceed acceptable limit");

        emit SetFoundationPercent(percent);
    }
    
    function setLiquidityPercent(uint256 percent) external onlyOwner() {
        require( deductionsTimeLocked() == false, "CR38R: Deduction controls time locked");
        require(percent <= MAX_LIQUIDITY_PERCENT, "CR38R: exceeds MAX_LIQUIDITY_PERCENT limit");
        _liquidityPercent = percent;
        require( (_foundationPercent + _metaverseInfrastructurePercent + _burnPercent + _liquidityPercent + _charityPercent)  <= MAX_DEDUCTION_PERCENT, "CR38R: Sum of all deductions exceed acceptable limit");
        
        emit SetLiquidityPercent(percent);
    }

    function setCharityPercent(uint256 percent) external onlyOwner() {
        require( deductionsTimeLocked() == false, "CR38R: Deduction controls time locked");
        require(percent <= MAX_CHARITY_PERCENT, "CR38R: exceeds MAX_CHARITY_PERCENT limit");
        _charityPercent = percent;
        require( (_foundationPercent + _metaverseInfrastructurePercent + _burnPercent + _liquidityPercent + _charityPercent)  <= MAX_DEDUCTION_PERCENT, "CR38R: Sum of all deductions exceed acceptable limit");
        
        emit SetCharityPercent(percent);
    }

    //
    // AUTO BURN CONTROL & MIN TOKENS
    //
    function setBurnPercent(uint256 percent)  external onlyOwner()  {
        require( deductionsTimeLocked() == false, "CR38R: Deduction controls time locked");
        require(percent <= MAX_BURN_PERCENT, "CR38R: > MAX_BURN_PERCENT limit");
        _burnPercent = percent;
        require( (_foundationPercent + _metaverseInfrastructurePercent + _burnPercent + _liquidityPercent + _charityPercent)  <= MAX_DEDUCTION_PERCENT, "CR38R: Sum of all deductions exceed acceptable limit");
        
        emit SetBurnPercent(percent);
   }

   //
   // IF AUTO BURNING, STOP BURN WHEN TOTAL SUPPLY IS REDUCED TO THIS LIMIT
   //
    function setMinTokenSupplyThreshold(uint256 amount)  external onlyOwner()  {
        require(amount >= MIN_TOTAL_SUPPLY_FLOOR, "CR38R: amount below min floor");
        require(amount <= _totalSupply, "CR38R: not less than totalSupply");
        _minTotalSupplyThreshold = amount;
        
        emit SetMinTotalSupplyThreshold(amount);
   }

    //
    // maximum transaction size
    //
    function setMaxTransferPercent(uint256 maxTransferPercent) external onlyOwner() {
        require(maxTransferPercent <= MAX_TRANSFER_PERCENT, "CR38R: % exceeds MAX_TRANSFER_PERCENT limit");
        _maxTransferAmount = _totalSupply.mul(maxTransferPercent).div(
            10**2
        );
    }

    //
    // LIQUIDITY SWAP CONTROLS
    //
    function setMinTokensBeforeSwap(uint256 minTokens) external onlyOwner() {
        require( minTokens > 0, "CR38R: Must be greater than 0");
        require( minTokens <= _maxTransferAmount, "CR38R: Must be <= to maxTransferAmount");

        emit SetMinTokensBeforeSwap(_numTokensSellToAddToLiquidity, minTokens);
        _numTokensSellToAddToLiquidity= minTokens;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner() {
        require(_swapAndLiquifyEnabled != _enabled, "CR38R: already set");
        _swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    //
    // SECURITY
    //
    function blockAddress(address account, bool value) external onlyOwner{
        require(_isBlocked[account] != value, "CR38R: already set");
        _isBlocked[account] = value;
    }

    function isBlocked(address account) public view returns(bool) {
        return _isBlocked[account];
    }

    //
    // DEDUCTION HELPERS
    // 
    
    function calculateMetaverseInfrastructureAmount(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_metaverseInfrastructurePercent).div(
            10**2
        );
    }

    function calculateFoundationAmount(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_foundationPercent).div(
            10**2
        );
    }

    function calculateLiquidityAmount(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_liquidityPercent).div(
            10**2
        );
    }
    
    function calculateCharityAmount(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_charityPercent).div(
            10**2
        );
    }
    

    //
    // INTERNAL COMMON TOKEN TRANSFER/APPROVAL LOGIC
    //

    function _approve(address owner, address spender, uint256 amount) private {
        //require(owner != address(0), "ERC20: owner can't be 0 ");
        //require(spender != address(0), "ERC20: spender can't be 0");
        require(owner != address(0) && spender != address(0), "ERC20:  can't be 0 address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer( address from, address to, uint256 amount ) private {
        require(from != address(0) && to != address(0), "ERC20: transfer 0 address not allowed");
        require(!_isBlocked[from] && !_isBlocked[to], "Blocked address");

        if(from != owner() && to != owner())
            require(amount <= _maxTransferAmount, "ERC20: Transfer amount exceeds maxTxAmount");

        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is uniswap pair.
        uint256 contractTokenBalance = balanceOf(address(this));
        
        // limit to our max transaction if contract balance is greater
        if(contractTokenBalance >= _maxTransferAmount)
            contractTokenBalance = _maxTransferAmount;
        
        bool canSwap = contractTokenBalance >= _numTokensSellToAddToLiquidity;

        // trigger liquidity conversion on sells
        if (    canSwap &&
                !_inSwapAndLiquify &&
                (from != _uniswapV2Pair) &&
                _swapAndLiquifyEnabled )
        {
            // add liquidity
            swapAndLiquify(_numTokensSellToAddToLiquidity);
        }
        
        //indicates if fee should be deducted from transfer
        bool deductFees = true;
        
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to])
        {
            deductFees = false;
        }
        else
        {
            if( from != _uniswapV2Pair &&  // buy
                to != _uniswapV2Pair ) // sell
            {   
                // don't deduct fees if going wallet to wallet (or if excluded above)
                deductFees= false;
            }
        }
        // transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from,to,amount,deductFees);
    }

    function swapAndLiquify(uint256 tokenAmount) private lockTheSwap {
        // split the tokenAmount balance into halves
        uint256 half = tokenAmount.div(2);
        uint256 otherHalf = tokenAmount.sub(half);

        // capture the contract's current BNB balance.
        // this is so that we can capture exactly the amount of BNB that the
        // swap creates, and not make the liquidity event include any BNB that
        // has been manually sent to the contract 
        uint256 bnbInitialBalance = address(this).balance;

        // swap tokens for BNB        
        swapTokensForBNB(half); // residual balance may be left over
        

        // calculate how much BNB we just swapped into?
        uint256 bnbNewBalance = address(this).balance.sub(bnbInitialBalance);


        // add liquidity to uniswap (our token + the new BNB        
        addLiquidity(otherHalf, bnbNewBalance);
        

        emit SwapAndLiquify(half, bnbNewBalance, otherHalf);
    }

    function swapTokensForBNB(uint256 tokenAmount) private {
        require(address(_uniswapV2Router) != address(0), "CR38R: swapTokensForBNB router cannot be 0");

        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapV2Router.WETH();

        _approve(address(this), address(_uniswapV2Router), tokenAmount);

        // make the swap
        _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );

        // assumes it worked
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        require(address(_uniswapV2Router) != address(0), "CR38R: addLiquidity router cannot be 0");

        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(_uniswapV2Router), tokenAmount);

        // add the liquidity
        _uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this), // per certik, this contract should receive liquidity token
            block.timestamp
        );
    }

    // this method is responsible for taking all deductions, if deductFees is true
    function _tokenTransfer(address sender, address recipient, uint256 amount,bool deductFees) private {

        require(_metaverseInfrastructureAccount != address(0), "CR38R: Metaverse address not set");
        require(_foundationAccount != address(0), "CR38R: Foundation address not set");

        // if percent is zero, the account can be zero. at least one condition needs to be true
        require(_charityAccount != address(0) || (_charityPercent == 0)  , "CR38R: Charity address not set");

        uint256 tBurn = 0;
        uint256 tFoundation = 0;
        uint256 tLiquidity = 0;
        uint256 tMetaverse = 0;
        uint256 tCharity = 0;
        uint256 tTransferAmount = amount;

        if( deductFees && _deductionsEnabled )
        {
            tBurn       = calculateBurnAmount(amount);
            tFoundation = calculateFoundationAmount(amount);
            tLiquidity  = calculateLiquidityAmount(amount);
            tMetaverse  = calculateMetaverseInfrastructureAmount(amount);
            tCharity    = calculateCharityAmount(amount);

            // amount to transfer after deductions
            tTransferAmount = amount.sub(tFoundation).sub(tLiquidity).sub(tMetaverse).sub(tBurn);
            tTransferAmount = tTransferAmount.sub(tCharity);
        }


       require(tTransferAmount >= 0, "CR38R: Amount after transfer deductions must be >= 0");
       require(amount == (tTransferAmount+tBurn+tFoundation+tLiquidity+tMetaverse+tCharity), "CR38R: TokenTransfer amount check mismatch");

        // sender balance reduced by total amount
        _balances[sender]                             = _balances[sender].sub(amount);

        // recipient receives amount after deductions (if any)
        _balances[recipient]                          = _balances[recipient].add(tTransferAmount);   

        emit Transfer(sender, recipient, tTransferAmount);

        if( deductFees && _deductionsEnabled)
        {
            _balances[_foundationAccount]             = _balances[_foundationAccount].add(tFoundation);
            _balances[address(this)]                  = _balances[address(this)].add(tLiquidity);
            _balances[_metaverseInfrastructureAccount]= _balances[_metaverseInfrastructureAccount].add(tMetaverse);
            
            if( _charityAccount != address(0))
            {
                _balances[_charityAccount]                = _balances[_charityAccount].add(tCharity);
            }
            else
            {
                require( tCharity == 0);
            }

            if( tBurn > 0 )
                _burnTokens( tBurn );

            if( tMetaverse > 0 )
                emit Transfer(sender, address(_metaverseInfrastructureAccount), tMetaverse);
            if( tLiquidity > 0 )
                emit Transfer(sender, address(this), tLiquidity);
            if( tFoundation > 0 )
                emit Transfer(sender, address(_foundationAccount), tFoundation);
            if( tCharity > 0 )
                emit Transfer(sender, address(_charityAccount), tCharity);
        }
    }

  /**
     * @dev Burns a specific amount of tokens.
     * @param value The amount of lowest token units to be burned.
     */
    function burn(uint256 value) public {
      _burn(msg.sender, value);
    }


    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: invalid 0 address");

        _balances[account] = _balances[account].sub(amount, "ERC20: exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Destoys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See `_burn` and `_approve`.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
    }


    //
    // OVERFLOW, RESIDUAL TOKEN HELPERS
    //
    // Per Certik audit, need to withdraw residual amounts left over from swapAndLiquify 
    //

    function withdrawBNB(uint256 amount) public onlyOwner  {
        require( withdrawalsTimeLocked() == false, "CR38R: controls time locked");

        if(amount == 0)
            payable(owner()).transfer(address(this).balance);
        else
            payable(owner()).transfer(amount);
    }
    
    function withdrawForeignToken(address token) public onlyOwner  {
        require( withdrawalsTimeLocked() == false, "CR38R: controls time locked");
        require(address(this) != address(token), "CR38R: Cannot withdraw native token");

        IERC20(address(token)).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

    //
    // BALANCE HELPERS
    //

    function foundationBalance() public view returns (uint256) {
        require(_foundationAccount != address(0), "CR38R: Address not set");
        return balanceOf(_foundationAccount);
    }
    function foundationBalanceBNB() public view returns (uint256) {
        require(_foundationAccount != address(0), "CR38R: Address not set");
        return address(_foundationAccount).balance;
    }

    function metaverseBalance() public view returns (uint256) {
        require(_metaverseInfrastructureAccount != address(0), "CR38R: Address not set");
        return balanceOf(_metaverseInfrastructureAccount);
    }
    
    function metaverseBalanceBNB() public view returns (uint256) {
        require(_metaverseInfrastructureAccount != address(0), "CR38R: Address not set");
        return address(_metaverseInfrastructureAccount).balance;
    }

    function charityBalance() public view returns (uint256) {
        require(_charityAccount != address(0), "CR38R: Address not set");
        return balanceOf(_charityAccount);
    }

    function charityBalanceBNB() public view returns (uint256) {
        require(_charityAccount != address(0), "CR38R: Address not set");
        return address(_charityAccount).balance;
    }

    function contractBalance() public view returns (uint256) {
        return balanceOf(address(this));
    }

    function contractBalanceBNB() public view returns (uint256) {
        return address(this).balance;
    }


    //
    // BURN LOGIC (burns down to a threshold)
    //
    function calculateBurnAmount(uint256 tokens) private view returns(uint256){
        uint256 deduction = 0;
        
        // stop burn when we've reached our minimum number tokens  
        if(_totalSupply > _minTotalSupplyThreshold)
        {
            // calculate a nice round value to be deducted at the burn percent
            deduction = tokens.ceil(100).mul(100).div(100*10**uint(2))
                .mul(_burnPercent); 
        
            // if this deduction reduces below our min supply, just deduct the difference so we burn right down to the min supply)
            if( _totalSupply.sub(deduction) < _minTotalSupplyThreshold )
                deduction = _totalSupply.sub(_minTotalSupplyThreshold);
        }
        
        return deduction;
    }
    
    // Burn the ``value` amount of tokens from the `account`
    function _burnTokens(uint256 value) internal{
        require(_totalSupply >= value); // burn only unsold tokens

        _totalSupply = _totalSupply.sub(value);
        
        emit Transfer(msg.sender, address(0), value);
    }
}