/**
 *Submitted for verification at BscScan.com on 2022-05-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/*
█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗
╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝
                                                                                    
                                                                                    
                                                                                    
██╗     ███████╗██████╗ ██████╗ ███████╗ ██████╗██╗  ██╗ █████╗ ██╗   ██╗███╗   ██╗ 
██║     ██╔════╝██╔══██╗██╔══██╗██╔════╝██╔════╝██║  ██║██╔══██╗██║   ██║████╗  ██║ 
██║     █████╗  ██████╔╝██████╔╝█████╗  ██║     ███████║███████║██║   ██║██╔██╗ ██║ 
██║     ██╔══╝  ██╔═══╝ ██╔══██╗██╔══╝  ██║     ██╔══██║██╔══██║██║   ██║██║╚██╗██║ 
███████╗███████╗██║     ██║  ██║███████╗╚██████╗██║  ██║██║  ██║╚██████╔╝██║ ╚████║ 
╚══════╝╚══════╝╚═╝     ╚═╝  ╚═╝╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝ 
                                                                                    
███████╗██╗███╗   ██╗ █████╗ ███╗   ██╗ ██████╗███████╗                             
██╔════╝██║████╗  ██║██╔══██╗████╗  ██║██╔════╝██╔════╝                             
█████╗  ██║██╔██╗ ██║███████║██╔██╗ ██║██║     █████╗                               
██╔══╝  ██║██║╚██╗██║██╔══██║██║╚██╗██║██║     ██╔══╝                               
██║     ██║██║ ╚████║██║  ██║██║ ╚████║╚██████╗███████╗                             
╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚══════╝    

                         .-. .-.
                        (   |   )
                      .-.:  |  ;,-.
                     (_ __`.|.'__ _)
                     (    .'|`.    )
                      `-'/  |  \`-'
                        (   !   )
                         `-' `-'\
                                 \
                                  )
                                                                                    
                                                                                    
                                                                                    
█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗
╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝

Welcome to the wonderful world of leprechauns!
We have the horde, we have all the gold and we will share it with you!
Join us with our fantastic tokenomics, lottery and much more!

Just to mention some key functions:
- Anti-Whale system (tax brackets for big spenders!)
- Anti-Bot system
- Lottery every 7 days
- 5 staking pools, one free for all and four time locked with fantastic APY
- Yearly lottery for special holidays
- All contracts locked, no changes, no tricks, no scams, no honeypots
- Project Lead doxxed with personal information public available
- Project doxxed and run by a registered company from Switzerland, no shady figures

Our developers have commented the shit out of our code, to give you, the user
some clear insight what's going on, and if you're an audit team, you'll thank us!


Web: https://leprechaun.finance
Telegram: https://leprechaun.finance/telegram (https://t.me/LeprechaunFinance)
Discord: https://leprechaun.finance/discord (https://discord.gg/2JqX9UxA4K)
Twitter: https://leprechaun.finance/twitter (https://twitter.com/LeprechaunFin/)
Reddit: https://leprechaun.finance/reddit (https://www.reddit.com/r/leprechaun_finance/)
Youtube: https://leprechaun.finance/youtube (https://www.youtube.com/channel/UCm3slwz9TH6GI6pH5sl_f7g/)
TikTok: https://leprechaun.finance/tiktok (https://www.tiktok.com/@lepfinance)
*/

// #############################################################################################################################
// ####################################### I M P O R T - E X T E R N A L - L I B R A R Y #######################################
 
// We are using an external library to secure/optimize the contract, please check the github release for further information
// this code is not provided by us, but deemed secure by the community
 
// source: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol

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
// #################################################### I M P O R T - E N D ####################################################
// #############################################################################################################################
 
// #############################################################################################################################
// ####################################### I M P O R T - E X T E R N A L - L I B R A R Y #######################################
 
// We are using an external library to secure/optimize the contract, please check the github release for further information
// this code is not provided by us, but deemed secure by the community
 
// source: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol
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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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
// #################################################### I M P O R T - E N D ####################################################
// #############################################################################################################################
 
// #############################################################################################################################
// ####################################### I M P O R T - E X T E R N A L - L I B R A R Y #######################################
 
// We are using an external library to secure/optimize the contract, please check the github release for further information
// this code is not provided by us, but deemed secure by the community
 
// source: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol

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
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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
// #################################################### I M P O R T - E N D ####################################################
// #############################################################################################################################
 
// #############################################################################################################################
// ####################################### I M P O R T - E X T E R N A L - L I B R A R Y #######################################
 
// We are using an external library to secure/optimize the contract, please check the github release for further information
// this code is not provided by us, but deemed secure by the community
 
// source: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/proxy/Proxy.sol
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
        require(owner() == _msgSender(), "[error][ownable] caller is not the owner");
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
        require(newOwner != address(0), "[error][ownable] new owner is the zero address");
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
// #################################################### I M P O R T - E N D ####################################################
// #############################################################################################################################
 
// #############################################################################################################################
// ####################################### I M P O R T - E X T E R N A L - L I B R A R Y #######################################
 
// We are using an external library to secure/optimize the contract, please check the github release for further information
// this code is not provided by us, but deemed secure by the community
 
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
// #################################################### I M P O R T - E N D ####################################################
// #############################################################################################################################
 
// #############################################################################################################################
// ####################################### I M P O R T - E X T E R N A L - L I B R A R Y #######################################
 
// We are using an external library to secure/optimize the contract, please check the github release for further information
// this code is not provided by us, but deemed secure by the community
 
// source: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol
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
/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
// #################################################### I M P O R T - E N D ####################################################
// #############################################################################################################################
 
// #############################################################################################################################
// ####################################### I M P O R T - E X T E R N A L - L I B R A R Y #######################################
 
// We are using an external library to secure/optimize the contract, please check the github release for further information
// this code is not provided by us, but deemed secure by the community
 
// source: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol
/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
abstract contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
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
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
// #################################################### I M P O R T - E N D ####################################################
// #############################################################################################################################
 
// #############################################################################################################################
// ####################################### I M P O R T - E X T E R N A L - L I B R A R Y #######################################
 
// We are using an external library to secure/optimize the contract, please check the github release for further information
// this code is not provided by us, but deemed secure by the community
 
// source: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol
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
// #################################################### I M P O R T - E N D ####################################################
// #############################################################################################################################
 
// #############################################################################################################################
// ####################################### I M P O R T - E X T E R N A L - L I B R A R Y #######################################
 
// We are using an external library to secure/optimize the contract, please check the github release for further information
// this code is not provided by us, but deemed secure by the community
 
// source: https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.8/VRFRequestIDBase.sol

contract VRFRequestIDBase {
  /**
   * @notice returns the seed which is actually input to the VRF coordinator
   *
   * @dev To prevent repetition of VRF output due to repetition of the
   * @dev user-supplied seed, that seed is combined in a hash with the
   * @dev user-specific nonce, and the address of the consuming contract. The
   * @dev risk of repetition is mostly mitigated by inclusion of a blockhash in
   * @dev the final seed, but the nonce does protect against repetition in
   * @dev requests which are included in a single block.
   *
   * @param _userSeed VRF seed input provided by user
   * @param _requester Address of the requesting contract
   * @param _nonce User-specific nonce at the time of the request
   */
  function makeVRFInputSeed(
    bytes32 _keyHash,
    uint256 _userSeed,
    address _requester,
    uint256 _nonce
  ) internal pure returns (uint256) {
    return uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));
  }

  /**
   * @notice Returns the id for this request
   * @param _keyHash The serviceAgreement ID to be used for this request
   * @param _vRFInputSeed The seed to be passed directly to the VRF
   * @return The id for this request
   *
   * @dev Note that _vRFInputSeed is not the seed passed by the consuming
   * @dev contract, but the one generated by makeVRFInputSeed
   */
  function makeRequestId(bytes32 _keyHash, uint256 _vRFInputSeed) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
  }
}

// source: https://raw.githubusercontent.com/smartcontractkit/chainlink/develop/contracts/src/v0.8/interfaces/LinkTokenInterface.sol

interface LinkTokenInterface {
  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool success);
}


// source: https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.8/VRFConsumerBase.sol

/** ****************************************************************************
 * @notice Interface for contracts using VRF randomness
 * *****************************************************************************
 * @dev PURPOSE
 *
 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness
 * @dev to Vera the verifier in such a way that Vera can be sure he's not
 * @dev making his output up to suit himself. Reggie provides Vera a public key
 * @dev to which he knows the secret key. Each time Vera provides a seed to
 * @dev Reggie, he gives back a value which is computed completely
 * @dev deterministically from the seed and the secret key.
 *
 * @dev Reggie provides a proof by which Vera can verify that the output was
 * @dev correctly computed once Reggie tells it to her, but without that proof,
 * @dev the output is indistinguishable to her from a uniform random sample
 * @dev from the output space.
 *
 * @dev The purpose of this contract is to make it easy for unrelated contracts
 * @dev to talk to Vera the verifier about the work Reggie is doing, to provide
 * @dev simple access to a verifiable source of randomness.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constuctor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator, _link) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash), and have told you the minimum LINK
 * @dev price for VRF service. Make sure your contract has sufficient LINK, and
 * @dev call requestRandomness(keyHash, fee, seed), where seed is the input you
 * @dev want to generate randomness from.
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomness method.
 *
 * @dev The randomness argument to fulfillRandomness is the actual random value
 * @dev generated from your seed.
 *
 * @dev The requestId argument is generated from the keyHash and the seed by
 * @dev makeRequestId(keyHash, seed). If your contract could have concurrent
 * @dev requests open, you can use the requestId to track which seed is
 * @dev associated with which randomness. See VRFRequestIDBase.sol for more
 * @dev details. (See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.)
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ. (Which is critical to making unpredictable randomness! See the
 * @dev next section.)
 *
 * *****************************************************************************
 * @dev SECURITY CONSIDERATIONS
 *
 * @dev A method with the ability to call your fulfillRandomness method directly
 * @dev could spoof a VRF response with any random value, so it's critical that
 * @dev it cannot be directly called by anything other than this base contract
 * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).
 *
 * @dev For your users to trust that your contract's random behavior is free
 * @dev from malicious interference, it's best if you can write it so that all
 * @dev behaviors implied by a VRF response are executed *during* your
 * @dev fulfillRandomness method. If your contract must store the response (or
 * @dev anything derived from it) and use it later, you must ensure that any
 * @dev user-significant behavior which depends on that stored value cannot be
 * @dev manipulated by a subsequent VRF request.
 *
 * @dev Similarly, both miners and the VRF oracle itself have some influence
 * @dev over the order in which VRF responses appear on the blockchain, so if
 * @dev your contract could have multiple VRF requests in flight simultaneously,
 * @dev you must ensure that the order in which the VRF responses arrive cannot
 * @dev be used to manipulate your contract's user-significant behavior.
 *
 * @dev Since the ultimate input to the VRF is mixed with the block hash of the
 * @dev block in which the request is made, user-provided seeds have no impact
 * @dev on its economic security properties. They are only included for API
 * @dev compatability with previous versions of this contract.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request.
 */
abstract contract VRFConsumerBase is VRFRequestIDBase {
  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBase expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomness the VRF output
   */
  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal virtual;

  /**
   * @dev In order to keep backwards compatibility we have kept the user
   * seed field around. We remove the use of it because given that the blockhash
   * enters later, it overrides whatever randomness the used seed provides.
   * Given that it adds no security, and can easily lead to misunderstandings,
   * we have removed it from usage and can now provide a simpler API.
   */
  uint256 private constant USER_SEED_PLACEHOLDER = 0;

  /**
   * @notice requestRandomness initiates a request for VRF output given _seed
   *
   * @dev The fulfillRandomness method receives the output, once it's provided
   * @dev by the Oracle, and verified by the vrfCoordinator.
   *
   * @dev The _keyHash must already be registered with the VRFCoordinator, and
   * @dev the _fee must exceed the fee specified during registration of the
   * @dev _keyHash.
   *
   * @dev The _seed parameter is vestigial, and is kept only for API
   * @dev compatibility with older versions. It can't *hurt* to mix in some of
   * @dev your own randomness, here, but it's not necessary because the VRF
   * @dev oracle will mix the hash of the block containing your request into the
   * @dev VRF seed it ultimately uses.
   *
   * @param _keyHash ID of public key against which randomness is generated
   * @param _fee The amount of LINK to send with the request
   *
   * @return requestId unique ID for this request
   *
   * @dev The returned requestId can be used to distinguish responses to
   * @dev concurrent requests. It is passed as the first argument to
   * @dev fulfillRandomness.
   */
  function requestRandomness(bytes32 _keyHash, uint256 _fee) internal returns (bytes32 requestId) {
    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, USER_SEED_PLACEHOLDER));
    // This is the seed passed to VRFCoordinator. The oracle will mix this with
    // the hash of the block containing this request to obtain the seed/input
    // which is finally passed to the VRF cryptographic machinery.
    uint256 vRFSeed = makeVRFInputSeed(_keyHash, USER_SEED_PLACEHOLDER, address(this), nonces[_keyHash]);
    // nonces[_keyHash] must stay in sync with
    // VRFCoordinator.nonces[_keyHash][this], which was incremented by the above
    // successful LINK.transferAndCall (in VRFCoordinator.randomnessRequest).
    // This provides protection against the user repeating their input seed,
    // which would result in a predictable/duplicate output, if multiple such
    // requests appeared in the same block.
    nonces[_keyHash] = nonces[_keyHash] + 1;
    return makeRequestId(_keyHash, vRFSeed);
  }

  LinkTokenInterface internal immutable LINK;
  address private immutable vrfCoordinator;

  // Nonces for each VRF key from which randomness has been requested.
  //
  // Must stay in sync with VRFCoordinator[_keyHash][this]
  mapping(bytes32 => uint256) /* keyHash */ /* nonce */
    private nonces;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   * @param _link address of LINK token contract
   *
   * @dev https://docs.chain.link/docs/link-token-contracts
   */
  constructor(address _vrfCoordinator, address _link) {
    vrfCoordinator = _vrfCoordinator;
    LINK = LinkTokenInterface(_link);
  }

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomness(bytes32 requestId, uint256 randomness) external {
    require(msg.sender == vrfCoordinator, "Only VRFCoordinator can fulfill");
    fulfillRandomness(requestId, randomness);
  }
}


interface ChainLinkBSCSwap {
    function swap(uint256, address, address) external;
}

// #################################################### I M P O R T - E N D ####################################################
// #############################################################################################################################
 


abstract contract RoleBasedAccessControl is Context, Ownable{
    mapping(string => mapping(address => bool)) private _roleToAddress;
    mapping(string => bool) private _role;
    string[] _roles;

    // modifiers
        modifier onlyRole(string memory pRole){
            require(_roleToAddress[pRole][_msgSender()], "[error][role based access control] only addresses assigned this role can access this function!");
            _;
        }

        modifier onlyRoles(string[] memory pRoles){
            for(uint256 i=0; i<pRoles.length; i++){
                require(_roleToAddress[pRoles[i]][_msgSender()], "[error][role based access control] only addresses assigned this role can access this function!");
            }
            _;
        }

        modifier onlyRolesOr(string[] memory pRoles){
            bool rolePresent = false;
            for(uint256 i=0; i<pRoles.length; i++){
                rolePresent = rolePresent || _roleToAddress[pRoles[i]][_msgSender()];
            }
            require(rolePresent, "[error][role based access control] only addresses assigned this role can access this function!");
            _;
        }

        modifier onlyRoleOrOwner(string memory pRole){
            require(_roleToAddress[pRole][_msgSender()] || owner() == _msgSender(), "[error][role based access control] only addresses assigned this role or the owner can access this function!");
            _;
        }

    // register new roles

        function registerRole(string memory pRole) public virtual onlyRoleOrOwner("root"){
            _addRole(pRole);
        }

        function registerRoleAddresses(string memory pRole, address[] memory pMembers) public virtual onlyRoleOrOwner("root"){
            _addRole(pRole);
            for(uint256 i=0; i<pMembers.length; i++){
                _roleToAddress[pRole][pMembers[i]] = true;
            }
        }

        function registerRoleAddress(string memory pRole, address pMember) public virtual onlyRoleOrOwner("root"){
            _addRole(pRole);
            _roleToAddress[pRole][pMember] = true;
        }

        function removeRoleAddress(string memory pRole, address pMember) public virtual onlyRoleOrOwner("root"){
            _addRole(pRole);
            _roleToAddress[pRole][pMember] = false;
        }

    // add

        function addRoleAddress(string memory pRole, address pMember) public virtual onlyRoleOrOwner("root"){
            _addRole(pRole);
            _roleToAddress[pRole][pMember] = true;
        }

    // get
    
        function hasRoleAddress(string memory pRole, address pAddress) public virtual returns(bool){
            return(_roleToAddress[pRole][pAddress]);
        }

    // privates

    function _addRole(string memory pRole) private{
        if(!_role[pRole]){
            _role[pRole] = true;
            _roles.push(pRole);
        }
    }
}


library Array256{
    using Array256 for uint256[];
    function del(uint256[] storage self, uint256 i) internal{
        self[i] = self[self.length - 1];
        self.pop();
    }

    function delval(uint256[] storage self, uint256 v) internal{
        for(uint256 i=0; i<self.length; i++){
            if(self[i] == v){
                self.del(i);
            }
        }
    }

    function max(uint256[] storage self) internal view returns(uint256){
        uint256 _max = (
            (self.length > 0) ? self[0] : 0
        );
        for(uint256 i=0; i<self.length; i++){
            if(self[i] > _max){
                _max = self[i];
            }
        }
        return(_max);
    }

    function min(uint256[] storage self) internal view returns(uint256){
        uint256 _min = (
            (self.length > 0) ? self[0] : 0
        );
        for(uint256 i=0; i<self.length; i++){
            if(self[i] < _min){
                _min = self[i];
            }
        }
        return(_min);
    }

    function includes(uint256[] storage self, uint256 x) internal view returns(bool){
        for(uint256 i=0; i<self.length; i++){
            if(self[i] == x){
                return(true);
            }
        }
        return(false);
    }

    function fisherYatesShuffle(uint256[] storage self, uint256 r) internal{
        uint256 n; uint256 c; uint256 e;
        for(uint256 i=self.length-1; i>0; i--){
            n = r % (self.length - 1);
            c = self[i]; e = self[n];
            self[i] = e; self[n] = c;
        }
    }

    function _sort(uint256[] memory _self, uint256 left, uint256 right) private{
        uint256 i = left;
        uint256 j = right;  
        if(i == j){
            return;
        }
        uint256 n = _self[uint256(left + (right - left) / 2)];
        while(i <= j){
            while(_self[uint256(i)] < n) i++;
            while (n < _self[uint256(j)]) j--;
            if(i <= j){
                (_self[uint256(i)], _self[uint256(j)]) = (_self[uint256(j)], _self[uint256(i)]);
                i++;
                j--;
            }
        }
        if(left < j){
            _sort(_self, left, j);
        }
        if(i < right){
            _sort(_self, i, right);
        }
    }

    function sort(uint256[] storage self) internal{
        uint256[] memory _self = self;
        _sort(_self, 0, _self.length);
        for(uint l=0; l<_self.length; l++){
            self[l] = _self[l];
        }
    }
}

library ArrayAddress{
    using ArrayAddress for address[];
    function del(address[] storage self, uint256 i) internal{
        self[i] = self[self.length - 1];
        self.pop();
    }

    function delval(address[] storage self, address v) internal{
        for(uint256 i=0; i<self.length; i++){
            if(self[i] == v){
                self.del(i);
            }
        }
    }

    function includes(address[] storage self, address x) internal view returns(bool){
        for(uint256 i=0; i<self.length; i++){
            if(self[i] == x){
                return(true);
            }
        }
        return(false);
    }
}


contract Util is RoleBasedAccessControl{
    // interfaces
        ERC20 private _token;

    // storage
        mapping(string => mapping(address => bool)) private _paramForAddressIsBool;
        mapping(string => bytes32) private _stringCompare;
        mapping(string => bool) private _stringCompareList;

    // constants
        uint256 private _floatingPointPrecision = 10**16;
    

    constructor(address pContract){
        // set burn addresses
            _paramForAddressIsBool['burn'][address(0)] = true;
            _paramForAddressIsBool['burn'][address(0xdEaD)] = true;

        // set privileges
            registerRoleAddress("util", _msgSender());
            registerRoleAddress("util", pContract);
    }

    // privileged
    // ███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗
    // ╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝
    
    function setParamForAddressBool(string memory pParam, address pAddress, bool pBool) public onlyRole("util"){
        _paramForAddressIsBool[pParam][pAddress] = pBool;
    }

    function setParamForAddressesBool(string memory pParam, address[] memory pAddress, bool pBool) public onlyRole("util"){
        for(uint256 i=0; i<pAddress.length; i++){
            _paramForAddressIsBool[pParam][pAddress[i]] = pBool;
        }
    }

    function addStringCompare(string memory pString) public onlyRole("util") returns(bytes32){
        _stringCompare[pString] = keccak256(bytes(pString));
        _stringCompareList[pString] = true;
        return(_stringCompare[pString]);
    }

    function stringEq(string memory pA, string memory pB) public onlyRole("util") returns(bool){
        bytes32 a = (
            (_stringCompareList[pA]) ? _stringCompare[pA] : addStringCompare(pA)
        );

        bytes32 b = (
            (_stringCompareList[pB]) ? _stringCompare[pB] : addStringCompare(pB)
        );

        if(a == b && b == a){
            return(true);
        }
        return(false);
    }

    // public
    // ███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗
    // ╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝

    function isAddressBurn(address pAddress) public view returns(bool){
        if(_paramForAddressIsBool['burn'][pAddress]){
            return(true);
        }
        return(false);
    }

    function isAddressParam(string memory pParam, address pAddress) public view returns(bool){
        if(_paramForAddressIsBool[pParam][pAddress]){
            return(true);
        }
        return(false);
    }

    function percent() public view returns(uint256){

    }
}



contract ILeprechaunStats{
    function totalBalanceOf(address) public view returns(uint256){}
    function liquidity() public view returns(uint256){}
    function price() public view returns(uint256){}
    function tier(address) public view returns(string memory){}
}


contract ILeprechaun{
    address public ADDRESS_BURN;
    address public ADDRESS_LIQUIDITY;
    address public ADDRESS_PAIR;
    address public ADDRESS_PRESALE;
    address public ADDRESS_PRESALE_VAULT;
    address public ADDRESS_LOTTERY;
    address public ADDRESS_STAKING;
    address public ADDRESS_PROJECT;
    address public ADDRESS_STAKING_DAYS30;
    address public ADDRESS_STAKING_DAYS90;
    address public ADDRESS_STAKING_DAYS180;
    address public ADDRESS_STAKING_DAYS365;
    function balanceOf(address) public view returns(uint256){}
    function totalBalanceOf(address) public view returns(uint256){}
    function price() public view returns(uint256){}
    function totalSupply() public view returns(uint256) {}
    function decimals() public view returns (uint8) {}
}


contract INewCycle{
    function cycle(uint256, uint256) public {}
}



abstract contract Dates{
    uint32[] private _dates = [1652040000,1652644800,1653249600,1653854400,1654459200,1655064000,1655668800,1656273600,1656878400,1657483200,1658088000,1658692800,1659902400,1660507200,1661112000,1661716800,1662321600,1662926400,1663531200,1664136000,1664740800,1665345600,1665950400,1666555200,1667160000,1667764800,1668369600,1668974400,1669579200,1670184000,1670788800,1671393600,1671998400,1672603200,1673208000,1673812800,1674417600,1675022400,1675627200,1676232000,1676836800,1677441600,1678046400,1678651200,1679256000,1679860800,1680465600,1681070400,1681675200,1682280000,1682884800,1683489600,1684094400,1684699200,1685304000,1685908800,1686513600,1687118400,1687723200,1688328000,1688932800,1689537600,1690142400,1690747200,1691352000,1691956800,1692561600,1693166400,1693771200,1694376000,1694980800,1695585600,1696190400,1696795200,1697400000,1698004800,1698609600,1699214400,1699819200,1700424000,1701028800,1701633600,1702238400,1702843200,1704657600,1705262400,1705867200,1706472000,1707076800,1707681600,1708286400,1708891200,1709496000,1710100800,1711310400,1712520000,1713124800,1713729600,1714334400,1714939200,1715544000,1716148800,1716753600,1717358400,1717963200,1718568000,1719172800,1719777600,1720382400,1720987200,1721592000,1722196800,1722801600,1723406400,1724011200,1724616000,1725220800,1725825600,1726430400,1727035200,1727640000,1728244800,1728849600,1729454400,1730059200,1730664000,1731268800,1731873600,1732478400,1733083200,1733688000,1734292800,1734897600,1735502400,1736107200,1736712000,1737316800,1737921600,1738526400,1739131200,1739736000,1740340800,1740945600,1741550400,1742155200,1742760000,1743969600,1744574400,1745179200,1745784000,1746388800,1746993600,1747598400,1748203200,1748808000,1749412800,1750017600,1750622400,1751227200,1751832000,1752436800,1753041600,1753646400,1754251200,1754856000,1755460800,1756065600,1756670400,1757275200,1757880000,1758484800,1759089600,1759694400,1760299200,1760904000,1761508800,1762113600,1762718400,1763323200,1763928000,1764532800,1765137600,1765742400,1766347200,1766952000,1767556800,1768161600,1768766400,1769371200,1769976000,1770580800,1771185600,1771790400,1772395200,1773000000,1773604800,1774209600,1775419200,1776024000,1776628800,1777233600,1777838400,1778443200,1779048000,1779652800,1780862400,1781467200,1782072000,1782676800,1783281600,1783886400,1784491200,1785096000,1785700800,1786305600,1786910400,1787515200,1788120000,1788724800,1789329600,1789934400,1790539200,1791144000,1791748800,1792353600,1792958400,1793563200,1794168000,1794772800,1795377600,1795982400,1796587200,1797192000,1797796800,1798401600,1799006400,1799611200,1800216000,1800820800,1801425600,1802030400,1802635200,1803240000,1803844800,1804449600,1805054400,1805659200,1806264000,1806868800,1807473600,1808078400,1808683200,1809288000,1809892800,1810497600,1811102400,1811707200,1812312000,1812916800,1813521600,1814126400,1814731200,1815336000,1815940800,1816545600,1817755200,1818360000,1818964800,1819569600,1820174400,1820779200,1821384000,1821988800,1822593600,1823198400,1823803200,1824408000,1825617600,1826222400,1826827200,1827432000,1828036800,1828641600,1829246400,1829851200,1830456000,1831060800,1831665600,1832270400,1832875200,1833480000,1834084800,1834689600,1835294400,1835899200,1836504000,1837108800,1837713600,1838318400,1838923200,1839528000,1840132800,1840737600,1841342400,1841947200,1842552000,1843156800,1843761600,1844366400,1844971200,1845576000,1846180800,1846785600,1847390400,1847995200,1848600000,1849204800,1849809600,1850414400,1851019200,1851624000,1852228800,1852833600,1853438400,1854043200,1854648000,1855252800,1855857600,1856462400,1857067200,1857672000,1858276800,1858881600,1859486400,1860091200,1860696000,1862510400,1863115200,1863720000,1864324800,1864929600,1865534400,1866139200,1866744000,1867348800,1867953600,1868558400,1869163200,1869768000,1870372800,1870977600,1871582400,1872187200,1872792000,1873396800,1874001600,1874606400,1875211200,1875816000,1876420800,1877025600,1877630400,1878235200,1878840000,1879444800,1880049600,1880654400,1881259200,1881864000,1882468800,1883073600,1883678400,1884283200,1884888000,1885492800,1886097600,1886702400,1887307200,1887912000,1888516800,1889121600,1889726400,1890331200,1890936000,1891540800,1892145600,1892750400,1893355200,1893960000,1894564800,1895169600,1895774400,1896379200,1896984000,1897588800,1898193600,1898798400,1899403200,1900612800,1901822400,1902427200,1903032000,1903636800,1904241600,1904846400,1905451200,1906056000,1906660800,1907265600,1907870400,1908475200,1909080000,1909684800,1910289600,1910894400,1911499200,1912104000,1912708800,1913313600,1913918400,1914523200,1915128000,1915732800,1916337600,1916942400,1917547200,1918152000,1918756800,1919361600,1919966400,1920571200,1921176000,1921780800,1922385600,1922990400,1923595200,1924200000,1924804800,1925409600,1926014400,1926619200,1927224000,1927828800,1928433600,1929038400,1929643200,1930248000,1930852800,1931457600,1932062400,1933272000,1933876800,1934481600,1935086400,1935691200,1936296000,1936900800,1937505600,1938110400,1938715200,1939320000,1939924800,1940529600,1941134400,1941739200,1942344000,1942948800,1943553600,1944158400,1944763200,1945368000,1945972800,1946577600,1947182400,1947787200,1948392000,1948996800,1949601600,1950206400,1950811200,1951416000,1952020800,1952625600,1953230400,1953835200,1954440000,1955044800,1955649600,1956254400,1956859200,1957464000,1958068800,1958673600,1959278400,1959883200,1960488000,1961092800,1961697600,1962302400,1962907200,1963512000,1964116800,1964721600,1965326400,1965931200,1966536000,1967140800,1967745600,1968350400,1968955200,1969560000,1970164800,1970769600,1971374400,1971979200,1972584000,1973188800,1973793600,1974398400,1975608000,1976212800,1976817600,1977422400,1978027200,1978632000,1979236800,1979841600,1980446400,1981051200,1981656000,1982260800,1983470400,1984075200,1984680000,1985284800,1985889600,1986494400,1987099200,1987704000,1988308800,1988913600,1989518400,1990123200,1990728000,1991332800,1991937600,1992542400,1993147200,1993752000,1994356800,1994961600,1995566400,1996171200,1996776000,1997380800,1997985600,1998590400,1999195200,1999800000,2000404800,2001009600,2001614400,2002219200,2002824000,2003428800,2004033600,2004638400,2005243200,2005848000,2007057600,2007662400,2008267200,2008872000,2009476800,2010081600,2010686400,2011291200,2011896000,2012500800,2013105600,2013710400,2014315200,2014920000,2015524800,2016129600,2016734400,2017339200,2017944000,2018548800,2019153600];

    function getDate(uint256 pIndex) public view returns(uint32){
        if(pIndex < _dates.length){
            return(_dates[pIndex]);
        }
        return(0);
    }

    function getDateLength() public view returns(uint256){
        return(_dates.length);
    }
}



// lottery cycle contract v2
/*
    This is a lottery cycle contract
        -	Gets all taxes from the main lottery interface
        -	Runs in cycles which are precalculated
        -	Uses Chainlink VRF 1.0
        -	Ticket sales get sent to the horde
        -	Uses our statistics contract for on-chain data
        -	Emits winners as events on the blockchain
*/
contract LeprechaunLotteryCycle is Dates, Context, Ownable, VRFConsumerBase, ReentrancyGuard, RoleBasedAccessControl{
    // lib
        using SafeMath for uint256; // more safe & secure uint256 operations
        using Address for address; // more safe & secure address operations
        using Array256 for uint256[]; // advanced uint256 array functions
        using ArrayAddress for address[]; // advanced address array functions

    // address
        address public ADDRESS_BURN = 0x000000000000000000000000000000000000dEaD; // burn baby, burn!
        address public ADDRESS_THE_HORDE; // project contract to store value
        address public ADDRESS_TOKEN; // address of the main token
        address public ADDRESS_LOTTERY; // address of the parent lottery contract
        address public ADDRESS_STATS; // address of the statistics contract
        address public ADDRESS_NEW_CYCLE; // address of the contract that will be called each new cycle
        address public ADDRESS_CHAINLINK_TOKEN = 0x404460C6A5EdE2D891e8297795264fDe62ADBB75; // chainlink token address
        address public ADDRESS_CHAINLINK_VRF = 0x747973a5A2a4Ae1D3a8fDF5479f1514F65Db9C31; // chainlink VRF address
        address public ADDRESS_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // address of the PancakeSwap router
        address public ADDRESS_STABLECOIN = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // address of the stablecoin BUSD

    // instance
        ILeprechaun private _main; // main token contract
        ERC20 private _token; // interface for parent token
        ERC20 private _stablecoin; // interface for stablecoin
        ERC20 private _link; // interface for link
        ILeprechaunStats private _stats; // interface for stats contract
        IUniswapV2Router02 private _router; // interface for PancakeSwap router
        INewCycle private _newCycle; // interface for new cycles

    // taxes
        uint256 public TAXES_IN_POOL;  // taxes collected in pool, but not distributed or used yet
        uint256 public TAXES_TOTAL; // the total amount of taxes ever received by this contract

    // lottery
        bool public LOTTERY_EOL; // will be true if we reached the lifecycle of this contract
        uint256 public CHAINLINK_FEE = 200000000000000000; // chainlink fee for random number
        bytes32 public CHAINLINK_KEY = 0xc251acd21ec4fb7f31bb8868288bfdbaeb4fbfec2df3735ddbd4f7dc8d60103c; // chainlink key
        uint256 public CHAINLINK_TIMEOUT = 600; // 10 minute timeout max for chainlink to respond
        uint256 public LOTTERY_TICKET_PRICE; // ticket price in USD
        uint256 public LOTTERY_MAX_WINNERS; // the maximum amount of winners per cycle
        uint256 public LOTTERY_MIN_STABLECOIN_FOR_100; // the minimum amount in stable coin value of tokens you need to have to win 100%

        struct Lottery{
            uint256 cycle; // the UID of the lottery
            uint256 end; // the end of the lottery
            uint256 taxes; // all the taxes in the current cycle
            uint256 sales; // all the sales of tickets in USD
            address[] tickets; // all the tickets bought
            address[] winners; // the winners of this lottery cycle
            bytes32 request; // the key for the answer from the chainlink oracle
            uint256 requestTime; // when we requested the random number
            uint256 requestDuration; // how long did it take to get a random number
            uint256 requestRandomNumber; // the random number provided by chainlink
        }

        mapping(uint256 => Lottery) public LOTTERIES;
        mapping(bytes32 => uint256) private _random;
        mapping(uint256 => mapping(address => bool)) private _tickets;
        uint256 public LOTTERY_CYCLE;
        uint256[] public LOTTERY_RUNNING;
        uint256[] public LOTTERY_HISTORY;

    // event
        event ContractCreation();
        event TokenSet(address token, uint256 balance);
        event TaxDeposit(address indexed from, address indexed to, uint256 amount, uint256 total, uint256 balance);
        event StartLottery(uint32 timestamp, uint256 cycle);
        event TicketBought(address indexed wallet, uint256 cycle, uint256 tickets, uint256 prize);
        event TicketGiveaway(address indexed wallet, uint256 cycle, uint256 tickets, uint256 prize);
        event VRFRequest(bytes32 id, uint256 cycle);
        event VRFFailRetry(uint256 cycle);
        event VRFCallback(address indexed caller, bytes32 id, uint256 random, uint256 cycle);
        event Winner(address indexed winner, uint256 cycle, uint256 tokens, bool oneHundred);

    // contract can be paid
    receive() external payable {}

    constructor(address pToken, address pLottery, address pStats, address pHorde, uint256 pPrice, uint256 pMaxWinners) VRFConsumerBase(ADDRESS_CHAINLINK_VRF, ADDRESS_CHAINLINK_TOKEN){
        if(ADDRESS_TOKEN == address(0) && pToken != address(0)){
            /* create token */
                ADDRESS_TOKEN = pToken; // set token address
                _token = ERC20(ADDRESS_TOKEN); // create token interface
                _main = ILeprechaun(ADDRESS_TOKEN);
                // event
                    emit TokenSet(ADDRESS_TOKEN, _token.balanceOf(address(this)));

            /* create lottery */
                ADDRESS_LOTTERY = pLottery; // set parent lottery contract for deposits
                LOTTERY_MAX_WINNERS = pMaxWinners;

            /* create stablecoin for tickets */
                _stablecoin = ERC20(ADDRESS_STABLECOIN);
                LOTTERY_TICKET_PRICE = pPrice * (10**_stablecoin.decimals());
                LOTTERY_MIN_STABLECOIN_FOR_100 = 1111 * (10**_stablecoin.decimals());

            /* PancakeSwap router */
                _router = IUniswapV2Router02(ADDRESS_ROUTER);   
                _token.approve(address(_router), 2**256 - 1);
                _stablecoin.approve(address(_router), 2**256 - 1);
                _newCycle = INewCycle(ADDRESS_NEW_CYCLE);
                ADDRESS_STATS = pStats;
                _stats = ILeprechaunStats(ADDRESS_STATS);
                ADDRESS_THE_HORDE = pHorde;

                // event
                    emit TokenSet(ADDRESS_STABLECOIN, _stablecoin.balanceOf(address(this)));

            /* set permissions */
                registerRoleAddress("root", _msgSender());
                registerRoleAddress("parent", ADDRESS_LOTTERY);
                renounceOwnership(); // appease to the general public although this function does not prevent anything!
        }

        // event
            emit ContractCreation();

        // go for it
            _start(0);
    }



    // privileged
    // ███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗
    // ╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝

    function init() public nonReentrant onlyRole("parent"){
        // nothing
    }

    function kill() public nonReentrant onlyRole("root"){
        // this will be executed when VRF 2.0 hits and we can change the interaction of the lottery with VRF in new contracts
        _token.transfer(ADDRESS_THE_HORDE, _token.balanceOf(address(this))); // send to the horde, lottery has ended and is replaced by v2
        LINK.transfer(ADDRESS_THE_HORDE, LINK.balanceOf(address(this))); // send remaining chainlink to the horde
        address payable payHorde = payable(ADDRESS_THE_HORDE);
        selfdestruct(payHorde); // bye bye ....
    }

    function deposit(address pFrom, address pTo, uint256 pAmount) public onlyRole("parent"){ // only parent contract can deposit tokens
        TAXES_TOTAL = TAXES_TOTAL.add(pAmount);
        uint256 contractBalance = _token.balanceOf(address(this));

        if(!LOTTERY_EOL){
            check(); // start new lottery cycle if needed

            uint32 timestamp = getDate(LOTTERY_CYCLE);
            LOTTERIES[timestamp].taxes = LOTTERIES[timestamp].taxes.add(pAmount); // add taxes to active cycle          

            // event
                emit TaxDeposit(pFrom, pTo, pAmount, LOTTERIES[timestamp].taxes, contractBalance);
        }else{
            _token.transfer(ADDRESS_THE_HORDE, contractBalance); // send to the horde, lottery has ended, maybe lottery v2?
        }
    }

    function burn() public nonReentrant onlyRole("root"){
         _burn();
    } 

    function setAddressStats(address pContract) public nonReentrant onlyRole("root"){ // only team can change the stats contract
        /*
            This function is needed to update the statistics contract in the future
            if we ever get staking v2 or any other token holding contracts we need to update
            the existing stats contract with a new one, therefore we have to be able to change
            the stats contract here too, otherwise the whole "you need x tokens to win 100%" does
            not work in the future!
        */
        require(!LOTTERY_EOL, "[error][lottery] this contract has reached its lifecycle and is end of life, no intractions possible anymore!");
        ADDRESS_STATS = pContract;
        _stats = ILeprechaunStats(ADDRESS_STATS);
    }

    function setAddressHorde(address pContract) public nonReentrant onlyRole("root"){
        /*
            This function is needed to change "the Horde" contract. This contract holds all value
            of the project, but its an open contract and might be updated and replaced in the future,
            therefore we need the ability to update the address here too!
        */
        ADDRESS_THE_HORDE = pContract;
    }

    function setMin100(uint256 pMinStablecoin) public nonReentrant onlyRole("root"){ // only team can change the minimum amount in $ of token
        /*
            This function is needed to update the minimum amount of stable coin value of your token holdings
            to win 100% of the pot. The reason for this is we want to have special lotteries where the minimum amount
            is lower than usual. The amount can never be higher than 111$
        */
        require(!LOTTERY_EOL, "[error][lottery] this contract has reached its lifecycle and is end of life, no intractions possible anymore!");
        require(pMinStablecoin <= 11111 * (10**_stablecoin.decimals()), "[error][lottery] you can't set the minimum stable coin balance higher than 11111 stablecoins!");
        LOTTERY_MIN_STABLECOIN_FOR_100 = pMinStablecoin;
    }

    function setAddressNewCycle(address pContract) public nonReentrant onlyRole("root"){
        /*
            This function is needed to change "the new cycle" contract. This contract will execute
            whenever a new cycle starts
        */
        require(!LOTTERY_EOL, "[error][lottery] this contract has reached its lifecycle and is end of life, no intractions possible anymore!");
        ADDRESS_NEW_CYCLE = pContract;
        _newCycle = INewCycle(ADDRESS_NEW_CYCLE);
    }

    function setTicketPrice(uint256 pPrice) public nonReentrant onlyRole("root"){
        /*
            This function is needed to change the ticket price if ever need be
        */
        require(!LOTTERY_EOL, "[error][lottery] this contract has reached its lifecycle and is end of life, no intractions possible anymore!");
        require(pPrice <= (100 * (10**_stablecoin.decimals())), "[error][lottery] ticket price cant be higher than 100$!");
        LOTTERY_TICKET_PRICE = pPrice;
    }

    function giveaway(address[] memory pWallets) public nonReentrant onlyRole("root"){
        /*
            This function can be used by the project to giveaway free lottery tickets
        */
        require(!LOTTERY_EOL, "[error][lottery] this contract has reached its lifecycle and is end of life, no intractions possible anymore!");
        
        uint32 timestamp = getDate(LOTTERY_CYCLE);

        for(uint256 i=0; i<pWallets.length; i++){
            if(!_tickets[LOTTERY_CYCLE][pWallets[i]]){
                LOTTERIES[timestamp].tickets.push(pWallets[i]); // add wallet to ticket list
                _tickets[LOTTERY_CYCLE][pWallets[i]] = true; // set wallet has ticket already

                // event
                    emit TicketGiveaway(pWallets[i], LOTTERY_CYCLE, LOTTERIES[timestamp].tickets.length,  LOTTERIES[timestamp].taxes);
            }
        }
    } 


    // public
    // ███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗
    // ╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝

    function min() public view returns(uint256){
        return(LOTTERY_MIN_STABLECOIN_FOR_100.div(((_main.price()).div(10**18))));
    }

    function balanceOf(address pWallet) public pure returns(uint256){
        /* all contracts have this function, regardless of utility, will always return 0 */
        if(pWallet != address(0)){
            return(0);
        }
        return(0);
    }

    function balanceOfLink() public view returns(uint256){
        return(LINK.balanceOf(address(this)));
    }

    function history() public view returns(uint256[] memory rHistory){
        return(LOTTERY_HISTORY);
    }

    function active() public view returns(uint256[] memory rActive){
        return(LOTTERY_RUNNING);
    }

    function lottery(uint256 pCycle) public view returns(
        uint256 rEnd,
        uint256 rTaxes,
        uint256 rSales,
        address[] memory rTickets,
        address[] memory rWinners,
        uint256 rRandomDuration,
        uint256 rRandom
    ){
        uint32 timestamp = getDate(pCycle);
        require(timestamp > 0, "[error][lottery] lottery cycle does not exist!");
        return(
            LOTTERIES[timestamp].end,
            LOTTERIES[timestamp].taxes,
            LOTTERIES[timestamp].sales,
            LOTTERIES[timestamp].tickets,
            LOTTERIES[timestamp].winners,
            LOTTERIES[timestamp].requestDuration,
            LOTTERIES[timestamp].requestRandomNumber
        );
    }

    function ticket(address pWallet, address pToken) public nonReentrant{
        require(!LOTTERY_EOL, "[error][lottery] this contract has reached its lifecycle and is end of life, no intractions possible anymore!");
        require(!_tickets[LOTTERY_CYCLE][pWallet], "[error][lottery] you can only buy one ticket for this wallet!");
        check(); // start new lottery cycle if needed

        if(pToken == ADDRESS_TOKEN){
            _payLEP(LOTTERY_TICKET_PRICE);
        }else{
            _payBUSD(LOTTERY_TICKET_PRICE);
        }

        uint32 timestamp = getDate(LOTTERY_CYCLE); address ticketRecipient;
        if(pWallet != address(0)){
            LOTTERIES[timestamp].tickets.push(pWallet); // add sender to ticket list
            _tickets[LOTTERY_CYCLE][pWallet] = true; // set sender bought ticket already
            ticketRecipient = pWallet;
        }else{
            LOTTERIES[timestamp].tickets.push(_msgSender()); // add sender to ticket list
            _tickets[LOTTERY_CYCLE][_msgSender()] = true; // set sender bought ticket already
            ticketRecipient = _msgSender();
        }

        // event
            emit TicketBought(ticketRecipient, LOTTERY_CYCLE, LOTTERIES[timestamp].tickets.length,  LOTTERIES[timestamp].taxes);
    }

    function tickets(address[] memory pWallets, address pToken) public nonReentrant{
        require(!LOTTERY_EOL, "[error][lottery] this contract has reached its lifecycle and is end of life, no intractions possible anymore!");
        check(); // start new lottery cycle if needed
        
        if(pToken == ADDRESS_TOKEN){
            _payLEP(LOTTERY_TICKET_PRICE.mul(pWallets.length));
        }else{
            _payBUSD(LOTTERY_TICKET_PRICE.mul(pWallets.length));
        }

        uint32 timestamp = getDate(LOTTERY_CYCLE);

        for(uint256 i=0; i<pWallets.length; i++){
            if(!_tickets[LOTTERY_CYCLE][pWallets[i]]){
                LOTTERIES[timestamp].tickets.push(pWallets[i]); // add wallet to ticket list
                _tickets[LOTTERY_CYCLE][pWallets[i]] = true; // set wallet bought ticket already

                // event
                    emit TicketBought(pWallets[i], LOTTERY_CYCLE, LOTTERIES[timestamp].tickets.length,  LOTTERIES[timestamp].taxes);
            }
        }
    }

    function draw(uint256 pCycle) public nonReentrant{
        require(!LOTTERY_EOL, "[error][lottery] this contract has reached its lifecycle and is end of life, no intractions possible anymore!");
        check(); // start new lottery cycle if needed
        uint32 timestamp = getDate(pCycle);

        if(LOTTERIES[timestamp].requestRandomNumber <= 0 && (block.timestamp - LOTTERIES[timestamp].requestTime) > CHAINLINK_TIMEOUT){
            // chainlink has taken too long to give a random number, try again
            LOTTERIES[timestamp].request = 0x0000000000000000000000000000000000000000000000000000000000000000;

            // event
                emit VRFFailRetry(pCycle);
        }

        require(LOTTERIES[timestamp].end <= block.timestamp, "[error][lottery] lottery has not ended yet!");
        require(LOTTERIES[timestamp].winners.length <= 0, "[error][lottery] lottery has winners already, no draw possible anymore!");
        require(LINK.balanceOf(address(this)) >= CHAINLINK_FEE, "[error][lottery] not enough LINK to get random number, add LINK please!");
        require(LOTTERIES[timestamp].request == 0x0000000000000000000000000000000000000000000000000000000000000000, "[error][lottery] lottery requested random number already, will not request again!");
        
        _requestRandomNumber(pCycle);
    }

    function check() public{
        uint32 timestamp = getDate(LOTTERY_CYCLE);
        uint256 oldCycle = LOTTERY_CYCLE;
        /* check if lottery has ended */
        if(LOTTERIES[timestamp].end <= block.timestamp){
            _start(LOTTERY_CYCLE.add(1)); // start new cycle
            if(ADDRESS_NEW_CYCLE != address(0)){
                _newCycle.cycle(oldCycle, LOTTERY_CYCLE);
            }
        }
    }

    function winner(uint256 pCycle) public nonReentrant{
        uint32 timestamp = getDate(pCycle);
        require(LOTTERIES[timestamp].requestRandomNumber > 0, "[error][lottery] lottery requested random number not yet present!");
        check(); // start new lottery cycle if needed
        _winner(pCycle); // check winner(s)
    }

    function fulfillRandomness(bytes32 pRequest, uint256 pRandom) internal override{
        uint32 timestamp = getDate(_random[pRequest]);
        LOTTERIES[timestamp].requestDuration = block.timestamp.sub(LOTTERIES[timestamp].requestTime);
        LOTTERIES[timestamp].requestRandomNumber = pRandom;

        // event
            emit VRFCallback(_msgSender(), pRequest, pRandom, _random[pRequest]);
    }

    function add(uint256 pAmount) public{
        uint256 allowance = _token.allowance(_msgSender(), address(this));
        uint256 balance = _token.balanceOf(_msgSender());
        require(allowance >= pAmount, "[error][lottery] you have to authorize the transfer of your $LEP first!");
        require(balance >= pAmount, "[error][lottery] you do not have enough $LEP!");
        require(_token.transferFrom(_msgSender(), address(this), pAmount), "[error][lottery] could not transfer your $LEP!");


        TAXES_TOTAL = TAXES_TOTAL.add(pAmount);
        uint256 contractBalance = _token.balanceOf(address(this));

        if(!LOTTERY_EOL){
            check(); // start new lottery cycle if needed

            uint32 timestamp = getDate(LOTTERY_CYCLE);
            LOTTERIES[timestamp].taxes = LOTTERIES[timestamp].taxes.add(pAmount); // add taxes to active cycle
        }else{
            _token.transfer(ADDRESS_THE_HORDE, contractBalance); // send to the horde, lottery has ended, maybe lottery v2?
        }
    }

    function priceStablecoin() public view returns(uint256){
        return(LOTTERY_TICKET_PRICE);
    }

    function priceToken() public view returns(uint256){
        return(_stablecoinToLEP(LOTTERY_TICKET_PRICE));
    }

    function hasTicket(address pWallet) public view returns(bool){
        if(_tickets[LOTTERY_CYCLE][pWallet]){
            return(true);
        }
        return(false);
    }



    // private
    // ███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗███████╗
    // ╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝

    function _requestRandomNumber(uint256 pCycle) private{
        uint32 timestamp = getDate(pCycle);
        bytes32 request = requestRandomness(CHAINLINK_KEY, CHAINLINK_FEE);
        LOTTERIES[timestamp].request = request; 
        LOTTERIES[timestamp].requestTime = block.timestamp;
        _random[request] = pCycle;

        // event
            emit VRFRequest(request, pCycle);
    }

    function _start(uint256 pCycle) private{
        if(LOTTERIES[getDate(pCycle)].end <= 0){
            LOTTERY_CYCLE = pCycle;
            uint32 _lotteryTimeStamp = getDate(pCycle);
            if(_lotteryTimeStamp == 0){
                /* we have reached the end of our precomputed date list */
                LOTTERY_EOL = true;
            }else{
                Lottery storage _lottery = LOTTERIES[_lotteryTimeStamp];
                _lottery.cycle = pCycle;
                _lottery.end = _lotteryTimeStamp;
                LOTTERY_RUNNING.push(pCycle);

                // event
                    emit StartLottery(_lotteryTimeStamp, pCycle);
            }
        }
    }   

    function _winner(uint256 pCycle) private{
        uint32 timestamp = getDate(pCycle);
        require(LOTTERIES[timestamp].end <= block.timestamp, "[error][lottery] lottery has not ended yet!");
        require(LOTTERIES[timestamp].winners.length <= 0, "[error][lottery] lottery has winners already!");

        if(LOTTERIES[timestamp].taxes > 0){
            uint256 cake = _token.balanceOf(address(this));
            uint256 slice;
            uint256 minTokenHoldings = (
                (LOTTERY_MIN_STABLECOIN_FOR_100 == 0) ? 0 :
                min()
            );
            uint32 timestampNext = getDate(LOTTERY_CYCLE);

            _getWinners(timestamp); // get the winners for this cycle

            if(LOTTERIES[timestamp].winners.length > 0){
                slice = LOTTERIES[timestamp].taxes.div(LOTTERIES[timestamp].winners.length);

                for(uint256 i=0; i<LOTTERIES[timestamp].winners.length; i++){
                    // check if slice is not bigger than the taxes
                    if(slice > LOTTERIES[timestamp].taxes){
                        slice = LOTTERIES[timestamp].taxes;
                    }

                    // check if slice is not bigger than the cake
                    if(slice > cake){
                        slice = cake;
                    }

                    LOTTERIES[timestamp].taxes = LOTTERIES[timestamp].taxes.sub(slice);
                    // check if the winner is entitled to 100% or 50%
                    if(_stats.totalBalanceOf(LOTTERIES[timestamp].winners[i]) >= minTokenHoldings){
                        _token.transfer(LOTTERIES[timestamp].winners[i], slice); // send tokens to winner wallet

                        // event
                            emit Winner(LOTTERIES[timestamp].winners[i], pCycle, slice, true); // announce winner on the blockchain
                    }else{
                        if(timestampNext > 0){
                            uint256 halfASlice = slice.div(2);
                            LOTTERIES[timestampNext].taxes = LOTTERIES[timestampNext].taxes.add(halfASlice);
                            slice = slice.sub(halfASlice);
                        }

                        _token.transfer(LOTTERIES[timestamp].winners[i], slice); // send tokens to winner wallet

                        // event
                            emit Winner(LOTTERIES[timestamp].winners[i], pCycle, slice, false); // announce winner on the blockchain
                    }             
                }
            }else{
                LOTTERIES[timestamp].winners.push(address(0)); // empty lottery
                if(timestampNext > 0){
                    LOTTERIES[timestampNext].taxes = LOTTERIES[timestampNext].taxes.add(LOTTERIES[timestamp].taxes);
                }
            }
        }else{
            LOTTERIES[timestamp].winners.push(address(0)); // empty lottery
        }

        LOTTERY_RUNNING.delval(pCycle); // delete index from active lottery
        LOTTERY_HISTORY.push(pCycle); // add lottery to history
    }

    function _getWinners(uint256 timestamp) private{
        if(LOTTERIES[timestamp].tickets.length <= LOTTERY_MAX_WINNERS){
            // okay, this is odd, we have less winners than max allowed, everyone wins
            for(uint256 i=0; i<LOTTERIES[timestamp].tickets.length; i++){
                LOTTERIES[timestamp].winners.push(LOTTERIES[timestamp].tickets[i]); // set winner N
            }
        }else{
            uint256 random;
            uint256[] memory randomN = _randomN(LOTTERIES[timestamp].requestRandomNumber, LOTTERY_MAX_WINNERS); // get n random numbers based on the initial random number
            for(uint256 i=0; i<randomN.length; i++){
                random = (randomN[i] % LOTTERIES[timestamp].tickets.length); // get a random number of the arrays length
                LOTTERIES[timestamp].winners.push(LOTTERIES[timestamp].tickets[random]); // set random winner
                if(randomN.length > 1){
                    LOTTERIES[timestamp].tickets.del(random); // remove winner from the tickets list so he can't win twice if more than 1 winner
                }
            }
        }
    }

    function _randomN(uint256 pRandom, uint256 pN) private pure returns(uint256[] memory){
        // generates n random numbers based on the input random number
        uint256[] memory randomN = new uint256[](pN);
        for(uint256 i=0; i<pN; i++){
            randomN[i] = uint256(keccak256(abi.encode(pRandom, i)));
        }
        return(randomN);
    }

    function _burn() private returns(bool){
        address[] memory pathTokenToBurn = new address[](3);
        pathTokenToBurn[0] = ADDRESS_STABLECOIN;
        pathTokenToBurn[1] = _router.WETH();
        pathTokenToBurn[2] = ADDRESS_TOKEN;

        uint256 balanceToken = _stablecoin.balanceOf(address(this));
        if(balanceToken > 0){
            _router.swapExactTokensForTokens(
                balanceToken,
                0,
                pathTokenToBurn,
                ADDRESS_BURN,
                block.timestamp
            );
        }

        return(true);
    }

    function _payBUSD(uint256 pPrice) private{
        uint256 allowance = _stablecoin.allowance(_msgSender(), address(this));
        uint256 balance = _stablecoin.balanceOf(_msgSender());
        require(allowance >= pPrice, "[error][lottery] you have to authorize the transfer of your BUSD first!");
        require(balance >= pPrice, "[error][lottery] you do not have enough BUSD!");
        require(_stablecoin.transferFrom(_msgSender(), address(this), pPrice), "[error][lottery] could not transfer your BUSD!");
        require(_burn(), "[error][lottery] could not burn your BUSD!");
    }

    function _payLEP(uint256 pPrice) private{
        uint256 priceLEP = _stablecoinToLEP(pPrice);
        uint256 allowance = _token.allowance(_msgSender(), address(this));
        uint256 balance = _token.balanceOf(_msgSender());
        require(allowance >= priceLEP, "[error][lottery] you have to authorize the transfer of your $LEP first!");
        require(balance >= priceLEP, "[error][lottery] you do not have enough $LEP!");
        require(_token.transferFrom(_msgSender(), address(this), priceLEP), "[error][lottery] could not transfer your $LEP!");
        require(_token.transfer(ADDRESS_BURN, priceLEP), "[error][lottery] could not burn your $LEP!");
    }

    function _stablecoinToLEP(uint256 pPrice) private view returns(uint256){
        address[] memory pathStablecoinToToken = new address[](3);
        pathStablecoinToToken[0] = ADDRESS_STABLECOIN;
        pathStablecoinToToken[1] = _router.WETH();
        pathStablecoinToToken[2] = ADDRESS_TOKEN;
        uint256[] memory priceStablecoinToToken = _router.getAmountsOut(pPrice, pathStablecoinToToken);
        return(priceStablecoinToToken[2]);
    }
}