/**
 *Submitted for verification at BscScan.com on 2022-06-29
*/

/** 
 *  SourceUnit: /Users/twy/Projects/gyro-contracts-v2/contracts/GyroBondV3.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity 0.8.11;

library BitMath {
    // solhint-disable-next-line code-complexity
    function mostSignificantBit(uint x) internal pure returns (uint8 r) {
        require(x > 0, "BitMath::mostSignificantBit: zero");

        if (x >= 0x100000000000000000000000000000000) {
            x >>= 128;
            r += 128;
        }
        if (x >= 0x10000000000000000) {
            x >>= 64;
            r += 64;
        }
        if (x >= 0x100000000) {
            x >>= 32;
            r += 32;
        }
        if (x >= 0x10000) {
            x >>= 16;
            r += 16;
        }
        if (x >= 0x100) {
            x >>= 8;
            r += 8;
        }
        if (x >= 0x10) {
            x >>= 4;
            r += 4;
        }
        if (x >= 0x4) {
            x >>= 2;
            r += 2;
        }
        if (x >= 0x2) r += 1;
    }
}




/** 
 *  SourceUnit: /Users/twy/Projects/gyro-contracts-v2/contracts/GyroBondV3.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity 0.8.11;

library Babylonian {
    // solhint-disable-next-line code-complexity
    function sqrt(uint x) internal pure returns (uint) {
        if (x == 0) return 0;

        uint xx = x;
        uint r = 1;
        if (xx >= 0x100000000000000000000000000000000) {
            xx >>= 128;
            r <<= 64;
        }
        if (xx >= 0x10000000000000000) {
            xx >>= 64;
            r <<= 32;
        }
        if (xx >= 0x100000000) {
            xx >>= 32;
            r <<= 16;
        }
        if (xx >= 0x10000) {
            xx >>= 16;
            r <<= 8;
        }
        if (xx >= 0x100) {
            xx >>= 8;
            r <<= 4;
        }
        if (xx >= 0x10) {
            xx >>= 4;
            r <<= 2;
        }
        if (xx >= 0x8) {
            r <<= 1;
        }
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1; // Seven iterations should be enough
        uint r1 = x / r;
        return (r < r1 ? r : r1);
    }
}




/** 
 *  SourceUnit: /Users/twy/Projects/gyro-contracts-v2/contracts/GyroBondV3.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity 0.8.11;

library FullMath {
    // solhint-disable-next-line use-forbidden-name
    function fullMul(uint x, uint y) private pure returns (uint l, uint h) {
        uint mm = mulmod(x, y, type(uint).max);
        l = x * y;
        h = mm - l;
        if (mm < l) h -= 1;
    }

    function fullDiv(
        uint l, // solhint-disable-line use-forbidden-name
        uint h,
        uint d
    ) private pure returns (uint) {
        uint pow2 = d & (~d + 1);
        d /= pow2;
        l /= pow2;
        l += h * ((~pow2 + 1) / pow2 + 1);
        uint r = 1;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        return l * r;
    }

    function mulDiv(
        uint x,
        uint y,
        uint d
    ) internal pure returns (uint) {
        (uint l, uint h) = fullMul(x, y); // solhint-disable-line use-forbidden-name
        uint mm = mulmod(x, y, d);
        if (mm > l) h -= 1;
        l -= mm;
        require(h < d, "FullMath::mulDiv: overflow");
        return fullDiv(l, h, d);
    }
}




/** 
 *  SourceUnit: /Users/twy/Projects/gyro-contracts-v2/contracts/GyroBondV3.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity 0.8.11;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [////IMPORTANT]
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

        uint size;
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
     * ////IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint amount) internal {
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
        uint value
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
        uint value,
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




/** 
 *  SourceUnit: /Users/twy/Projects/gyro-contracts-v2/contracts/GyroBondV3.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity 0.8.11;

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
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
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
    function sub(uint a, uint b) internal pure returns (uint) {
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
    function sub(
        uint a,
        uint b,
        string memory errorMessage
    ) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

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
    function mul(uint a, uint b) internal pure returns (uint) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
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
    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
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
    function div(
        uint a,
        uint b,
        string memory errorMessage
    ) internal pure returns (uint) {
        require(b > 0, errorMessage);
        uint c = a / b;
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
    function mod(uint a, uint b) internal pure returns (uint) {
        return mod(a, b, "SafeMath: modulo by zero");
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
    function mod(
        uint a,
        uint b,
        string memory errorMessage
    ) internal pure returns (uint) {
        require(b != 0, errorMessage);
        return a % b;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrrt(uint a) internal pure returns (uint c) {
        if (a > 3) {
            c = a;
            uint b = add(div(a, 2), 1);
            while (b < c) {
                c = b;
                b = div(add(div(a, b), b), 2);
            }
        } else if (a != 0) {
            c = 1;
        }
    }

    /*
     * Expects percentage to be trailed by 00,
     */
    function percentageAmount(uint total_, uint8 percentage_) internal pure returns (uint percentAmount_) {
        return div(mul(total_, percentage_), 1000);
    }

    /*
     * Expects percentage to be trailed by 00,
     */
    function substractPercentage(uint total_, uint8 percentageToSub_) internal pure returns (uint result_) {
        return sub(total_, div(mul(total_, percentageToSub_), 1000));
    }

    function percentageOfTotal(uint part_, uint total_) internal pure returns (uint percent_) {
        return div(mul(part_, 100), total_);
    }

    /**
     * Taken from Hypersonic https://github.com/M2629/HyperSonic/blob/main/Math.sol
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint a, uint b) internal pure returns (uint) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }

    function quadraticPricing(uint payment_, uint multiplier_) internal pure returns (uint) {
        return sqrrt(mul(multiplier_, payment_));
    }

    function bondingCurve(uint supply_, uint multiplier_) internal pure returns (uint) {
        return mul(multiplier_, supply_);
    }
}




/** 
 *  SourceUnit: /Users/twy/Projects/gyro-contracts-v2/contracts/GyroBondV3.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity 0.8.11;

interface IERC20 {
    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);

    event Approval(address indexed owner, address indexed spender, uint value);
}




/** 
 *  SourceUnit: /Users/twy/Projects/gyro-contracts-v2/contracts/GyroBondV3.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity 0.8.11;

interface IERC2612Permit {
    /**
     * @dev Sets `amount` as the allowance of `spender` over `owner`'s tokens,
     * given `owner`'s signed approval.
     *
     * ////IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint amount,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current ERC2612 nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint);
}




/** 
 *  SourceUnit: /Users/twy/Projects/gyro-contracts-v2/contracts/GyroBondV3.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity 0.8.11;

////import "./IERC20.sol";
////import "./SafeMath.sol";

abstract contract ERC20 is IERC20 {
    using SafeMath for uint;

    // TODO comment actual hash value.
    bytes32 private constant ERC20TOKEN_ERC1820_INTERFACE_ID = keccak256("ERC20Token");

    mapping(address => uint) internal _balances;

    mapping(address => mapping(address => uint)) internal _allowances;

    uint internal _totalSupply;

    string internal _name;

    string internal _symbol;

    uint8 internal _decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint) {
        return _balances[account];
    }

    function transfer(address recipient, uint amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account_, uint ammount_) internal virtual {
        require(account_ != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(this), account_, ammount_);
        _totalSupply = _totalSupply.add(ammount_);
        _balances[account_] = _balances[account_].add(ammount_);
        emit Transfer(address(this), account_, ammount_);
    }

    function _burn(address account, uint amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from_,
        address to_,
        uint amount_
    ) internal virtual {} // solhint-disable-line no-empty-blocks
}




/** 
 *  SourceUnit: /Users/twy/Projects/gyro-contracts-v2/contracts/GyroBondV3.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: AGPL-3.0-or-later
pragma solidity 0.8.11;

interface IOwnable {
    function owner() external view returns (address);

    function renounceOwnership() external;

    function transferOwnership(address newOwner_) external;
}




/** 
 *  SourceUnit: /Users/twy/Projects/gyro-contracts-v2/contracts/GyroBondV3.sol
*/
            
//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IReservoir {
    function bondDeposit(uint amount, uint profit) external returns (uint);

    function deposit(
        address tokenIn,
        uint amount,
        uint profit
    ) external returns (uint);

    function mintRewards(address recipient, uint amount) external returns (uint);
}




/** 
 *  SourceUnit: /Users/twy/Projects/gyro-contracts-v2/contracts/GyroBondV3.sol
*/
            

pragma solidity 0.8.11;

interface IBondCalculator {
    function valuation(address pair_, uint amount_) external view returns (uint value_);

    function markdown(address pair_, address gyro_) external view returns (uint);
}




/** 
 *  SourceUnit: /Users/twy/Projects/gyro-contracts-v2/contracts/GyroBondV3.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity 0.8.11;

interface IUniswapV2Pair {
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function token0() external view returns (address);

    function token1() external view returns (address);

    function totalSupply() external view returns (uint);
}




/** 
 *  SourceUnit: /Users/twy/Projects/gyro-contracts-v2/contracts/GyroBondV3.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity 0.8.11;

////import "./FullMath.sol";
////import "./Babylonian.sol";
////import "./BitMath.sol";

library FixedPoint {
    // range: [0, 2**112 - 1]
    // resolution: 1 / 2**112
    // solhint-disable-next-line contract-name-camelcase
    struct uq112x112 {
        uint224 _x;
    }

    // range: [0, 2**144 - 1]
    // resolution: 1 / 2**112
    // solhint-disable-next-line contract-name-camelcase
    struct uq144x112 {
        uint _x;
    }

    uint8 private constant RESOLUTION = 112;
    uint private constant Q112 = 0x10000000000000000000000000000;
    uint private constant Q224 = 0x100000000000000000000000000000000000000000000000000000000;
    uint private constant LOWER_MASK = 0xffffffffffffffffffffffffffff; // decimal of UQ*x112 (lower 112 bits)

    // decode a UQ112x112 into a uint112 by truncating after the radix point
    function decode(uq112x112 memory self) internal pure returns (uint112) {
        return uint112(self._x >> RESOLUTION);
    }

    // decode a uq112x112 into a uint with 18 decimals of precision
    function decode112with18(uq112x112 memory self) internal pure returns (uint) {
        return uint(self._x) / 5192296858534827;
    }

    // decode a UQ144x112 into a uint144 by truncating after the radix point
    function decode144(uq144x112 memory self) internal pure returns (uint144) {
        return uint144(self._x >> RESOLUTION);
    }

    // multiply a UQ112x112 by a uint256, returning a UQ144x112
    // reverts on overflow
    function mul(uq112x112 memory self, uint y) internal pure returns (uq144x112 memory) {
        uint z = 0;
        require(y == 0 || (z = self._x * y) / y == self._x, "FixedPoint::mul: overflow");
        return uq144x112(z);
    }

    function fraction(uint numerator, uint denominator) internal pure returns (uq112x112 memory) {
        require(denominator > 0, "FixedPoint::fraction: division by zero");
        if (numerator == 0) return FixedPoint.uq112x112(0);

        if (numerator <= type(uint144).max) {
            uint result = (numerator << RESOLUTION) / denominator;
            require(result <= type(uint224).max, "FixedPoint::fraction: overflow");
            return uq112x112(uint224(result));
        } else {
            uint result = FullMath.mulDiv(numerator, Q112, denominator);
            require(result <= type(uint224).max, "FixedPoint::fraction: overflow");
            return uq112x112(uint224(result));
        }
    }

    // square root of a UQ112x112
    // lossy between 0/1 and 40 bits
    function sqrt(uq112x112 memory self) internal pure returns (uq112x112 memory) {
        if (self._x <= type(uint144).max) {
            return uq112x112(uint224(Babylonian.sqrt(uint(self._x) << 112)));
        }

        uint8 safeShiftBits = 255 - BitMath.mostSignificantBit(self._x);
        safeShiftBits -= safeShiftBits % 2;
        return uq112x112(uint224(Babylonian.sqrt(uint(self._x) << safeShiftBits) << ((112 - safeShiftBits) / 2)));
    }
}




/** 
 *  SourceUnit: /Users/twy/Projects/gyro-contracts-v2/contracts/GyroBondV3.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity 0.8.11;

////import "./IERC20.sol";
////import "./SafeMath.sol";
////import "./Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0), "SafeERC20: approve from non-zero to non-zero allowance");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint value
    ) internal {
        uint newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint value
    ) internal {
        uint newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}




/** 
 *  SourceUnit: /Users/twy/Projects/gyro-contracts-v2/contracts/GyroBondV3.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity 0.8.11;

////import "./ERC20.sol";
////import "./IERC2612Permit.sol";

library Counters {
    using SafeMath for uint;

    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        // The {SafeMath} overflow check can be skipped here, see the comment at the top
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}

abstract contract ERC20Permit is ERC20, IERC2612Permit {
    using Counters for Counters.Counter;

    mapping(address => Counters.Counter) private _nonces;

    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    // solhint-disable-next-line var-name-mixedcase
    bytes32 public DOMAIN_SEPARATOR;

    constructor() {
        uint chainID;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            chainID := chainid()
        }

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name())),
                keccak256(bytes("1")), // Version
                chainID,
                address(this)
            )
        );
    }

    /**
     * @dev See {IERC2612Permit-permit}.
     *
     */
    function permit(
        address owner,
        address spender,
        uint amount,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        require(block.timestamp <= deadline, "Permit: expired deadline");

        bytes32 hashStruct = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, amount, _nonces[owner].current(), deadline));

        bytes32 _hash = keccak256(abi.encodePacked(uint16(0x1901), DOMAIN_SEPARATOR, hashStruct));

        address signer = ecrecover(_hash, v, r, s);
        require(signer != address(0) && signer == owner, "ERC20Permit: Invalid signature");

        _nonces[owner].increment();
        _approve(owner, spender, amount);
    }

    /**
     * @dev See {IERC2612Permit-nonces}.
     */
    function nonces(address owner) public view override returns (uint) {
        return _nonces[owner].current();
    }
}




/** 
 *  SourceUnit: /Users/twy/Projects/gyro-contracts-v2/contracts/GyroBondV3.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity 0.8.11;

////import "./IOwnable.sol";

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
contract Ownable is IOwnable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view override returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual override onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner_) public virtual override onlyOwner {
        require(newOwner_ != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner_);
        _owner = newOwner_;
    }
}


/** 
 *  SourceUnit: /Users/twy/Projects/gyro-contracts-v2/contracts/GyroBondV3.sol
*/


pragma solidity 0.8.11;

////import "./libs/Ownable.sol";
////import "./libs/Address.sol";
////import "./libs/ERC20Permit.sol";
////import "./libs/SafeERC20.sol";
////import "./libs/FixedPoint.sol";
////import "./libs/IUniswapV2Pair.sol";
////import "./interfaces/IBondCalculator.sol";
////import "./interfaces/IReservoir.sol";

interface IReferral {
    function calcRewards(
        bytes32 code_,
        uint payout_,
        address depositor_
    ) external view returns (uint, uint);

    function depositRewards(bytes32 code_, uint rewards_) external;
}

interface IUniswapV2Router02 {
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

contract GyroBondV3 is Ownable {
    using FixedPoint for *;
    using SafeERC20 for IERC20;

    /* ======== EVENTS ======== */

    event LogBondCreated(address indexed account, uint deposit, uint realDeposit, uint indexed payout, uint indexed expires, uint priceInUSD);
    event LogBondRedeemed(address indexed recipient, uint payout, uint remaining);
    event LogBondPriceChanged(uint indexed priceInUSD, uint indexed internalPrice, uint indexed debtRatio);
    event LogControlVariableAdjustment(uint initialBCV, uint newBCV, uint adjustment, bool addition);

    /* ======== STATE VARIABLES ======== */

    address public immutable gyro; // gyro system reward token
    address public immutable tokenIn; // token used to create bond
    address public immutable gyroToken; // token given as payment for bond
    address public immutable router; //pancake router
    address public immutable reservoir; // mints gyro when receives principle

    bool public immutable isLiquidityBond; // LP and Reserve bonds are treated slightly different
    address public immutable bondCalculator; // calculates value of LP tokens

    address public treasury; // receives profit share from bond

    Terms public terms; // stores terms for new bonds
    Adjust public adjustment; // stores adjustment to BCV data

    mapping(address => Bond) public bondInfo; // stores bond information for depositors

    uint public totalDebt; // total value of outstanding bonds; used for pricing
    uint public lastDecay; // reference block for debt decay

    address public referral; // referral manager

    mapping(address => uint) public balanceOf; // user total deposit lp amount
    uint public totalFee; //total withdrawable fee(lp)

    /* ======== STRUCTS ======== */

    // Info for creating new bonds
    struct Terms {
        uint controlVariable; // scaling variable for price
        uint period; // in blocks
        uint minPrice; // vs principle value
        uint maxPayout; // in thousandths of a %. i.e. 500 = 0.5%
        uint fee; // as % of bond payout, in hundreths. ( 500 = 5% = 0.05 for every 1 paid)
        uint maxDebt; // 9 decimal debt ratio, max % total supply created as debt
    }

    // Info for bond holder
    struct Bond {
        uint payout; // gyro remaining to be paid
        uint period; // Blocks left to vest
        uint lastBlock; // Last interaction
        uint pricePaid; // In usd, for front end viewing
    }

    // Info for incremental adjustments to control variable
    struct Adjust {
        bool add; // addition or subtraction
        uint rate; // increment
        uint target; // BCV when adjustment finished
        uint buffer; // minimum length (in blocks) between adjustments
        uint lastBlock; // block when last adjustment made
    }

    struct DepositVars {
        uint bondPrice;
        uint bondPriceInUSD;
        uint value;
        uint payout;
        uint fee;
        uint profit;
        uint referrerRewards;
        uint depositorRewards;
    }

    modifier onlyTreasury() {
        require(treasury == msg.sender, "not auth");
        _;
    }

    enum PARAMETER {
        VESTING,
        PAYOUT,
        FEE,
        DEBT
    }

    /* ======== INITIALIZATION ======== */

    constructor(
        address gyro_,
        address gyroToken_,
        address tokenIn_,
        address router_,
        address reservoir_,
        address bondCalculator_
    ) {
        require(gyro_ != address(0));
        gyro = gyro_;
        require(tokenIn_ != address(0));
        tokenIn = tokenIn_;
        require(gyroToken_ != address(0));
        gyroToken = gyroToken_;
        require(router_ != address(0));
        router = router_;
        require(reservoir_ != address(0));
        reservoir = reservoir_;
        // bondCalculator should be address(0) if not LP bond
        bondCalculator = bondCalculator_;
        isLiquidityBond = (bondCalculator_ != address(0));
    }

    /**
     *  @notice initializes bond parameters
     *  @param controlVariable_ uint
     *  @param period_ uint
     *  @param minPrice_ uint
     *  @param maxPayout_ uint
     *  @param fee_ uint
     *  @param maxDebt_ uint
     *  @param initialDebt_ uint
     */
    function initializeBondTerms(
        uint controlVariable_,
        uint period_,
        uint minPrice_,
        uint maxPayout_,
        uint fee_,
        uint maxDebt_,
        uint initialDebt_
    ) external onlyOwner {
        require(terms.controlVariable == 0, "Bonds must be initialized from 0");
        terms = Terms({controlVariable: controlVariable_, period: period_, minPrice: minPrice_, maxPayout: maxPayout_, fee: fee_, maxDebt: maxDebt_});
        totalDebt = initialDebt_;
        lastDecay = block.number;
    }

    /* ======== POLICY FUNCTIONS ======== */

    /**
     *  @notice set parameters for new bonds
     *  @param parameter_ PARAMETER
     *  @param input_ uint
     */
    function setBondTerms(PARAMETER parameter_, uint input_) external onlyOwner {
        if (parameter_ == PARAMETER.VESTING) {
            // 0
            require(input_ >= 40000, "Vesting must be longer than 36 hours"); // assuming, 3s block time
            terms.period = input_;
        } else if (parameter_ == PARAMETER.PAYOUT) {
            // 1
            require(input_ <= 1000, "Payout cannot be above 1 percent");
            terms.maxPayout = input_;
        } else if (parameter_ == PARAMETER.FEE) {
            // 2
            require(input_ <= 10000, "Treasury fee cannot exceed payout");
            terms.fee = input_;
        } else if (parameter_ == PARAMETER.DEBT) {
            // 3
            terms.maxDebt = input_;
        }
    }

    /**
     *  @notice set control variable adjustment
     *  @param addition_ bool
     *  @param increment_ uint
     *  @param target_ uint
     *  @param buffer_ uint
     */
    function setAdjustment(
        bool addition_,
        uint increment_,
        uint target_,
        uint buffer_
    ) external onlyOwner {
        adjustment = Adjust({add: addition_, rate: increment_, target: target_, buffer: buffer_, lastBlock: block.number});
    }

    function setTreasury(address treasury_) external onlyOwner {
        require(treasury == address(0), "can only set once");
        require(treasury_ != address(0), "not zero address");
        treasury = treasury_;
    }

    /**
     *  @notice set contract for referrals
     *  @param referral_ address
     */
    function setReferral(address referral_) external onlyOwner {
        referral = referral_;
    }

    /* ======== USER FUNCTIONS ======== */

    /**
     *  @notice deposit bond
     *  @param amount_ uint
     *  @param maxPrice_ uint
     *  @param depositor_ address
     *  @param referralCode_ address
     *  @return uint
     */
    function deposit(
        uint amount_,
        uint maxPrice_,
        address depositor_,
        bytes32 referralCode_
    ) external returns (uint) {
        require(depositor_ != address(0), "Invalid address");

        _decayDebt();

        require(totalDebt <= terms.maxDebt, "Max capacity reached");

        // slither-disable-next-line uninitialized-local
        DepositVars memory vars;

        require(maxPrice_ >= bondPrice(), "Slippage limit: more than max price"); // slippage protection

        require(terms.fee >= 0 && terms.fee <= 10000, "fee error");
        vars.fee = (amount_ * terms.fee) / 10000;
        uint realAmount = amount_ - vars.fee;

        (vars.payout, vars.value) = payoutFor(realAmount); // payout to bonder is computed

        require(vars.payout >= 10000000, "Bond too small"); // must be > 0.01 gyro ( underflow protection )
        require(vars.payout <= maxPayout(), "Bond too large"); // size protection because there is no slippage

        vars.referrerRewards = 0;
        vars.depositorRewards = 0;
        if (referral != address(0) && referralCode_ != bytes32("")) {
            (vars.referrerRewards, vars.depositorRewards) = IReferral(referral).calcRewards(referralCode_, vars.payout, depositor_);
        }

        // profits are calculated
        vars.profit = 0;
        if (vars.value > vars.payout + vars.referrerRewards + vars.depositorRewards) {
            // only payout referral rewards if there's enough profit
            vars.profit = vars.value - vars.payout - vars.referrerRewards - vars.depositorRewards;
        } else if (vars.value > vars.payout) {
            vars.profit = vars.value - vars.payout;
            vars.referrerRewards = 0;
            vars.depositorRewards = 0;
        } else {
            vars.profit = vars.value - vars.payout;
            vars.fee = 0;
            vars.referrerRewards = 0;
            vars.depositorRewards = 0;
        }

        // total debt is increased
        totalDebt += vars.value;

        vars.bondPriceInUSD = bondPriceInUSD();

        // depositor info is stored
        bondInfo[depositor_] = Bond({
            payout: bondInfo[depositor_].payout + vars.payout + vars.depositorRewards,
            period: terms.period,
            lastBlock: block.number,
            pricePaid: vars.bondPriceInUSD
        });

        _adjust(); // control variable is adjusted

        vars.bondPrice = _updateBondPrice();

        /**
            principle is transferred in
            approved and
            deposited into the reservoir
         */
        IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amount_);
        IERC20(tokenIn).safeIncreaseAllowance(address(reservoir), realAmount);
        uint gyroMinted = IReservoir(reservoir).bondDeposit(realAmount, vars.profit);

        require(gyroMinted >= vars.value - vars.profit, "Deposit failed");

        balanceOf[depositor_] += realAmount;
        totalFee += vars.fee;

        if (vars.referrerRewards > 0) {
            IERC20(gyroToken).safeIncreaseAllowance(referral, vars.referrerRewards);
            IReferral(referral).depositRewards(referralCode_, vars.referrerRewards);
        }

        // indexed events are emitted
        emit LogBondCreated(depositor_, amount_, realAmount, vars.payout, block.number + terms.period, vars.bondPriceInUSD);
        emit LogBondPriceChanged(vars.bondPriceInUSD, vars.bondPrice, debtRatio());

        return vars.payout;
    }

    /**
     *  @notice redeem bond for user
     *  @param recipient_ address
     *  @return uint
     */
    function redeem(address recipient_) external returns (uint) {
        Bond memory info = bondInfo[recipient_];
        uint percentVested = percentVestedFor(recipient_); // (blocks since last interaction / vesting period remaining)

        if (percentVested >= 10000) {
            // if fully vested
            delete bondInfo[recipient_]; // delete user info
            emit LogBondRedeemed(recipient_, info.payout, 0); // emit bond data
            return _stakeOrSend(recipient_, info.payout); // pay user everything due
        } else {
            // if unfinished
            // calculate payout vested
            uint payout = (info.payout * percentVested) / 10000;

            // store updated deposit info
            bondInfo[recipient_] = Bond({
                payout: info.payout - payout,
                period: info.period - (block.number - info.lastBlock),
                lastBlock: block.number,
                pricePaid: info.pricePaid
            });

            emit LogBondRedeemed(recipient_, payout, bondInfo[recipient_].payout);
            return _stakeOrSend(recipient_, payout);
        }
    }

    /* ======== INTERNAL HELPER FUNCTIONS ======== */

    /**
     *  @notice allow user to stake payout automatically
     *  @param recipient_ address
     *  @param amount_ uint
     *  @return uint
     */
    function _stakeOrSend(address recipient_, uint amount_) internal returns (uint) {
        IERC20(gyroToken).safeTransfer(recipient_, amount_); // send payout
        return amount_;
    }

    /**
     *  @notice makes incremental adjustment to control variable
     */
    function _adjust() internal {
        uint blockCanAdjust = adjustment.lastBlock + adjustment.buffer;
        if (adjustment.rate != 0 && block.number >= blockCanAdjust) {
            uint initial = terms.controlVariable;
            if (adjustment.add) {
                terms.controlVariable += adjustment.rate;
                if (terms.controlVariable >= adjustment.target) {
                    adjustment.rate = 0;
                }
            } else {
                terms.controlVariable -= adjustment.rate;
                if (terms.controlVariable <= adjustment.target) {
                    adjustment.rate = 0;
                }
            }
            adjustment.lastBlock = block.number;
            emit LogControlVariableAdjustment(initial, terms.controlVariable, adjustment.rate, adjustment.add);
        }
    }

    /**
     *  @notice reduce total debt
     */
    function _decayDebt() internal {
        totalDebt -= debtDecay();
        lastDecay = block.number;
    }

    /* ======== VIEW FUNCTIONS ======== */

    /**
     *  @notice determine maximum bond size
     *  @return uint
     */
    function maxPayout() public view returns (uint) {
        return (IERC20(gyroToken).totalSupply() * terms.maxPayout) / 100000;
    }

    /**
     *  @notice calculate interest due for new bond
     *  @param amount_ uint
     *  @return payout_ uint, value_ uint
     */
    function payoutFor(uint amount_) public view returns (uint payout_, uint value_) {
        (value_, ) = gyroValue(amount_);
        payout_ = FixedPoint.fraction(value_, bondPrice()).decode112with18() / 1e16;
    }

    /**
     *  @notice calculate current bond premium
     *  @return price_ uint
     */
    function bondPrice() public view returns (uint price_) {
        price_ = (terms.controlVariable * debtRatio() + 1000000000) / 1e7;
        if (price_ < terms.minPrice) {
            price_ = terms.minPrice;
        }
    }

    /**
     *  @notice calculate current bond price and remove floor if above
     *  @return price_ uint
     */
    function _updateBondPrice() internal returns (uint price_) {
        price_ = (terms.controlVariable * debtRatio() + 1000000000) / 1e7;
        if (price_ < terms.minPrice) {
            price_ = terms.minPrice;
        } else if (terms.minPrice != 0) {
            terms.minPrice = 0;
        }
    }

    /**
     *  @notice converts bond price to usd value
     *  @return price_ uint
     */
    function bondPriceInUSD() public view returns (uint price_) {
        if (isLiquidityBond) {
            price_ = (bondPrice() * IBondCalculator(bondCalculator).markdown(tokenIn, gyroToken)) / 100;
        } else {
            price_ = (bondPrice() * (10**IERC20(tokenIn).decimals())) / 100;
        }
    }

    /**
     *  @notice returns gyro valuation of asset
     *  @param amount_ uint
     *   @return value_ uint
     */
    function gyroValue(uint amount_) public view returns (uint value_, address token_) {
        if (isLiquidityBond) {
            value_ = IBondCalculator(bondCalculator).valuation(tokenIn, amount_);
        } else {
            // convert amount to match gyro decimals
            value_ = (amount_ * (10**IERC20(gyroToken).decimals())) / (10**IERC20(tokenIn).decimals());
        }
        token_ = tokenIn;
    }

    /**
     *  @notice calculate current ratio of debt to gyro supply
     *  @return debtRatio_ uint
     */
    function debtRatio() public view returns (uint debtRatio_) {
        uint supply = IERC20(gyroToken).totalSupply();
        debtRatio_ = FixedPoint.fraction(currentDebt() * 1e9, supply).decode112with18() / 1e18;
    }

    /**
     *  @notice debt ratio in same terms for reserve or liquidity bonds
     *  @return uint
     */
    function standardizedDebtRatio() external view returns (uint) {
        if (isLiquidityBond) {
            return (debtRatio() * (IBondCalculator(bondCalculator).markdown(tokenIn, gyroToken))) / 1e9;
        } else {
            return debtRatio();
        }
    }

    /**
     *  @notice calculate debt factoring in decay
     *  @return uint
     */
    function currentDebt() public view returns (uint) {
        return totalDebt - debtDecay();
    }

    /**
     *  @notice amount to decay total debt by
     *  @return decay_ uint
     */
    function debtDecay() public view returns (uint decay_) {
        uint blocksSinceLast = block.number - lastDecay;
        decay_ = (totalDebt * blocksSinceLast) / terms.period;
        if (decay_ > totalDebt) {
            decay_ = totalDebt;
        }
    }

    /**
     *  @notice calculate how far into vesting a depositor is
     *  @param depositor_ address
     *  @return percentVested_ uint
     */
    function percentVestedFor(address depositor_) public view returns (uint percentVested_) {
        Bond memory bond = bondInfo[depositor_];
        uint blocksSinceLast = block.number - bond.lastBlock;
        uint period = bond.period;

        if (period > 0) {
            percentVested_ = (blocksSinceLast * 10000) / period;
        } else {
            percentVested_ = 0;
        }
    }

    /**
     *  @notice calculate amount of gyro available for claim by depositor
     *  @param depositor_ address
     *  @return pendingPayout_ uint
     */
    function pendingPayoutFor(address depositor_) external view returns (uint pendingPayout_) {
        uint percentVested = percentVestedFor(depositor_);
        uint payout = bondInfo[depositor_].payout;

        if (percentVested >= 10000) {
            pendingPayout_ = payout;
        } else {
            pendingPayout_ = (payout * percentVested) / 10000;
        }
    }

    function _sell() private {
        uint amount;
        uint bal = IERC20(tokenIn).balanceOf(address(this));
        if (bal > totalFee) {
            amount = totalFee;
        } else {
            amount = bal;
        }
        totalFee = 0;

        address token0 = IUniswapV2Pair(tokenIn).token0();
        address token1 = IUniswapV2Pair(tokenIn).token1();
        require(token0 == gyro || token1 == gyro, "reward token address error");
        address sellToken = token0 == gyro ? token1 : token0;
        uint balBefore = IERC20(sellToken).balanceOf(address(this));
        IERC20(tokenIn).safeIncreaseAllowance(router, amount);
        IUniswapV2Router02(router).removeLiquidity(token0, token1, amount, 0, 0, address(this), block.timestamp);
        uint balAfter = IERC20(sellToken).balanceOf(address(this));
        uint amountSwap = balAfter > balBefore ? balAfter - balBefore : 0;
        address[] memory path_ = new address[](2);
        path_[0] = sellToken;
        path_[1] = gyro;
        IERC20(sellToken).safeIncreaseAllowance(router, amountSwap);
        IUniswapV2Router02(router).swapExactTokensForTokens(amountSwap, 0, path_, address(this), block.timestamp);
    }

    function claimFees() external onlyTreasury {
        uint balBeffore = IERC20(gyro).balanceOf(address(this));
        if (isLiquidityBond) _sell();
        uint balAfter = IERC20(gyro).balanceOf(address(this));
        if (balAfter > balBeffore) {
            uint transferAmount = balAfter - balBeffore;
            IERC20(gyro).safeTransfer(treasury, transferAmount);
        }
    }

    /* ======= AUXILLIARY ======= */
    function recoverLostToken(address token_) external onlyOwner returns (bool) {
        require(token_ != gyroToken);
        require(token_ != tokenIn);
        IERC20(token_).safeTransfer(msg.sender, IERC20(token_).balanceOf(address(this)));
        return true;
    }
}