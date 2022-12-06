/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

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

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
   
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library DateTime {
    uint256 constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint256 constant SECONDS_PER_HOUR = 60 * 60;
    uint256 constant SECONDS_PER_MINUTE = 60;
    int256 constant OFFSET19700101 = 2440588;

    uint256 constant DOW_MON = 1;
    uint256 constant DOW_TUE = 2;
    uint256 constant DOW_WED = 3;
    uint256 constant DOW_THU = 4;
    uint256 constant DOW_FRI = 5;
    uint256 constant DOW_SAT = 6;
    uint256 constant DOW_SUN = 7;

    // ------------------------------------------------------------------------
    // Calculate the number of days from 1970/01/01 to year/month/day using
    // the date conversion algorithm from
    //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
    // and subtracting the offset 2440588 so that 1970/01/01 is day 0
    //
    // days = day
    //      - 32075
    //      + 1461 * (year + 4800 + (month - 14) / 12) / 4
    //      + 367 * (month - 2 - (month - 14) / 12 * 12) / 12
    //      - 3 * ((year + 4900 + (month - 14) / 12) / 100) / 4
    //      - offset
    // ------------------------------------------------------------------------
    function _daysFromDate(uint256 year, uint256 month, uint256 day) internal pure returns (uint256 _days) {
        require(year >= 1970);
        int256 _year = int256(year);
        int256 _month = int256(month);
        int256 _day = int256(day);

        int256 __days = _day - 32075 + (1461 * (_year + 4800 + (_month - 14) / 12)) / 4
            + (367 * (_month - 2 - ((_month - 14) / 12) * 12)) / 12
            - (3 * ((_year + 4900 + (_month - 14) / 12) / 100)) / 4 - OFFSET19700101;

        _days = uint256(__days);
    }

    // ------------------------------------------------------------------------
    // Calculate year/month/day from the number of days since 1970/01/01 using
    // the date conversion algorithm from
    //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
    // and adding the offset 2440588 so that 1970/01/01 is day 0
    //
    // int L = days + 68569 + offset
    // int N = 4 * L / 146097
    // L = L - (146097 * N + 3) / 4
    // year = 4000 * (L + 1) / 1461001
    // L = L - 1461 * year / 4 + 31
    // month = 80 * L / 2447
    // dd = L - 2447 * month / 80
    // L = month / 11
    // month = month + 2 - 12 * L
    // year = 100 * (N - 49) + year + L
    // ------------------------------------------------------------------------
    function _daysToDate(uint256 _days) internal pure returns (uint256 year, uint256 month, uint256 day) {
        unchecked {
            int256 __days = int256(_days);

            int256 L = __days + 68569 + OFFSET19700101;
            int256 N = (4 * L) / 146097;
            L = L - (146097 * N + 3) / 4;
            int256 _year = (4000 * (L + 1)) / 1461001;
            L = L - (1461 * _year) / 4 + 31;
            int256 _month = (80 * L) / 2447;
            int256 _day = L - (2447 * _month) / 80;
            L = _month / 11;
            _month = _month + 2 - 12 * L;
            _year = 100 * (N - 49) + _year + L;

            year = uint256(_year);
            month = uint256(_month);
            day = uint256(_day);
        }
    }

    function timestampFromDate(uint256 year, uint256 month, uint256 day) internal pure returns (uint256 timestamp) {
        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY;
    }

    function timestampFromDateTime(
        uint256 year,
        uint256 month,
        uint256 day,
        uint256 hour,
        uint256 minute,
        uint256 second
    )
        internal
        pure
        returns (uint256 timestamp)
    {
        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + hour * SECONDS_PER_HOUR
            + minute * SECONDS_PER_MINUTE + second;
    }

    function timestampToDate(uint256 timestamp) internal pure returns (uint256 year, uint256 month, uint256 day) {
        unchecked {
            (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        }
    }

    function timestampToDateTime(uint256 timestamp)
        internal
        pure
        returns (uint256 year, uint256 month, uint256 day, uint256 hour, uint256 minute, uint256 second)
    {
        unchecked {
            (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
            uint256 secs = timestamp % SECONDS_PER_DAY;
            hour = secs / SECONDS_PER_HOUR;
            secs = secs % SECONDS_PER_HOUR;
            minute = secs / SECONDS_PER_MINUTE;
            second = secs % SECONDS_PER_MINUTE;
        }
    }

    function isValidDate(uint256 year, uint256 month, uint256 day) internal pure returns (bool valid) {
        if (year >= 1970 && month > 0 && month <= 12) {
            uint256 daysInMonth = _getDaysInMonth(year, month);
            if (day > 0 && day <= daysInMonth) {
                valid = true;
            }
        }
    }

    function isValidDateTime(uint256 year, uint256 month, uint256 day, uint256 hour, uint256 minute, uint256 second)
        internal
        pure
        returns (bool valid)
    {
        if (isValidDate(year, month, day)) {
            if (hour < 24 && minute < 60 && second < 60) {
                valid = true;
            }
        }
    }

    function isLeapYear(uint256 timestamp) internal pure returns (bool leapYear) {
        (uint256 year,,) = _daysToDate(timestamp / SECONDS_PER_DAY);
        leapYear = _isLeapYear(year);
    }

    function _isLeapYear(uint256 year) internal pure returns (bool leapYear) {
        leapYear = ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);
    }

    function isWeekDay(uint256 timestamp) internal pure returns (bool weekDay) {
        weekDay = getDayOfWeek(timestamp) <= DOW_FRI;
    }

    function isWeekEnd(uint256 timestamp) internal pure returns (bool weekEnd) {
        weekEnd = getDayOfWeek(timestamp) >= DOW_SAT;
    }

    function getDaysInMonth(uint256 timestamp) internal pure returns (uint256 daysInMonth) {
        (uint256 year, uint256 month,) = _daysToDate(timestamp / SECONDS_PER_DAY);
        daysInMonth = _getDaysInMonth(year, month);
    }

    function _getDaysInMonth(uint256 year, uint256 month) internal pure returns (uint256 daysInMonth) {
        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
            daysInMonth = 31;
        } else if (month != 2) {
            daysInMonth = 30;
        } else {
            daysInMonth = _isLeapYear(year) ? 29 : 28;
        }
    }

    // 1 = Monday, 7 = Sunday
    function getDayOfWeek(uint256 timestamp) internal pure returns (uint256 dayOfWeek) {
        uint256 _days = timestamp / SECONDS_PER_DAY;
        dayOfWeek = ((_days + 3) % 7) + 1;
    }

    function getYear(uint256 timestamp) internal pure returns (uint256 year) {
        (year,,) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function getMonth(uint256 timestamp) internal pure returns (uint256 month) {
        (, month,) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function getDay(uint256 timestamp) internal pure returns (uint256 day) {
        (,, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function getHour(uint256 timestamp) internal pure returns (uint256 hour) {
        uint256 secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
    }

    function getMinute(uint256 timestamp) internal pure returns (uint256 minute) {
        uint256 secs = timestamp % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
    }

    function getSecond(uint256 timestamp) internal pure returns (uint256 second) {
        second = timestamp % SECONDS_PER_MINUTE;
    }

    function addYears(uint256 timestamp, uint256 _years) internal pure returns (uint256 newTimestamp) {
        (uint256 year, uint256 month, uint256 day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        year += _years;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + (timestamp % SECONDS_PER_DAY);
        require(newTimestamp >= timestamp);
    }

    function addMonths(uint256 timestamp, uint256 _months) internal pure returns (uint256 newTimestamp) {
        (uint256 year, uint256 month, uint256 day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        month += _months;
        year += (month - 1) / 12;
        month = ((month - 1) % 12) + 1;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + (timestamp % SECONDS_PER_DAY);
        require(newTimestamp >= timestamp);
    }

    function addDays(uint256 timestamp, uint256 _days) internal pure returns (uint256 newTimestamp) {
        newTimestamp = timestamp + _days * SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }

    function addHours(uint256 timestamp, uint256 _hours) internal pure returns (uint256 newTimestamp) {
        newTimestamp = timestamp + _hours * SECONDS_PER_HOUR;
        require(newTimestamp >= timestamp);
    }

    function addMinutes(uint256 timestamp, uint256 _minutes) internal pure returns (uint256 newTimestamp) {
        newTimestamp = timestamp + _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp >= timestamp);
    }

    function addSeconds(uint256 timestamp, uint256 _seconds) internal pure returns (uint256 newTimestamp) {
        newTimestamp = timestamp + _seconds;
        require(newTimestamp >= timestamp);
    }

    function subYears(uint256 timestamp, uint256 _years) internal pure returns (uint256 newTimestamp) {
        (uint256 year, uint256 month, uint256 day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        year -= _years;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + (timestamp % SECONDS_PER_DAY);
        require(newTimestamp <= timestamp);
    }

    function subMonths(uint256 timestamp, uint256 _months) internal pure returns (uint256 newTimestamp) {
        (uint256 year, uint256 month, uint256 day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint256 yearMonth = year * 12 + (month - 1) - _months;
        year = yearMonth / 12;
        month = (yearMonth % 12) + 1;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + (timestamp % SECONDS_PER_DAY);
        require(newTimestamp <= timestamp);
    }

    function subDays(uint256 timestamp, uint256 _days) internal pure returns (uint256 newTimestamp) {
        newTimestamp = timestamp - _days * SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }

    function subHours(uint256 timestamp, uint256 _hours) internal pure returns (uint256 newTimestamp) {
        newTimestamp = timestamp - _hours * SECONDS_PER_HOUR;
        require(newTimestamp <= timestamp);
    }

    function subMinutes(uint256 timestamp, uint256 _minutes) internal pure returns (uint256 newTimestamp) {
        newTimestamp = timestamp - _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp <= timestamp);
    }

    function subSeconds(uint256 timestamp, uint256 _seconds) internal pure returns (uint256 newTimestamp) {
        newTimestamp = timestamp - _seconds;
        require(newTimestamp <= timestamp);
    }

    function diffYears(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _years) {
        require(fromTimestamp <= toTimestamp);
        (uint256 fromYear,,) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint256 toYear,,) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _years = toYear - fromYear;
    }

    function diffMonths(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _months) {
        require(fromTimestamp <= toTimestamp);
        (uint256 fromYear, uint256 fromMonth,) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint256 toYear, uint256 toMonth,) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _months = toYear * 12 + toMonth - fromYear * 12 - fromMonth;
    }

    function diffDays(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _days) {
        require(fromTimestamp <= toTimestamp);
        _days = (toTimestamp - fromTimestamp) / SECONDS_PER_DAY;
    }

    function diffHours(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _hours) {
        require(fromTimestamp <= toTimestamp);
        _hours = (toTimestamp - fromTimestamp) / SECONDS_PER_HOUR;
    }

    function diffMinutes(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _minutes) {
        require(fromTimestamp <= toTimestamp);
        _minutes = (toTimestamp - fromTimestamp) / SECONDS_PER_MINUTE;
    }

    function diffSeconds(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _seconds) {
        require(fromTimestamp <= toTimestamp);
        _seconds = toTimestamp - fromTimestamp;
    }
}

contract FarmarokRefferal is Ownable {
    using Address for address payable;
    using Address for address;

    uint256 public bonusRate;
    bool public bonusActive;
    uint256 public bonusLimitperUser;
    uint256 public withdrawEpoch;
    uint256 public epoch;

    IUniswapV2Router02 public router;
    address public frokToken;
    address public poolContract;

    struct Refferal{
        address referrer;
        string refferalCode;
        address[] user;
    }

    struct AmountInformation{
        uint256 claimedBonus;
        uint256 bonusAmount;
        uint256 numberOfWithdraw;
    }

    mapping(address => Refferal) public refferals;
    mapping(bytes32 => address) public refferalCodes;
    mapping(uint256 => mapping(address => AmountInformation)) public bonusClaim;
    uint256 public vestingNumber;
    uint256 public limitToken;
    constructor () {   
        // address newOwner = msg.sender;
        // transferOwnership(newOwner);
        
        frokToken=0xDD451Fb4b6359e2d669675E1DC974604B7bCe9dC;

        if (block.chainid == 56) {
            router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); // BSC Pancake Mainnet Router
        } else if (block.chainid == 97) {
            router =  IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); // BSC Pancake Testnet Router
        } else if (block.chainid == 1 || block.chainid == 5) {
            router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); // ETH Uniswap Mainnet % Testnet
        } else {
            revert();
        }
   
        withdrawEpoch=type(uint256).max;
        epoch=0;
        bonusRate = 50;
        vestingNumber = 5;
        bonusLimitperUser=1e25;
        limitToken=100e18;
        poolContract=0x62d787264F038bDE269D5fa46e337B4F2B3C966c;
    }

    receive() external payable {}

  	function setSpecial(bool isActive,uint256 _bonusRate,uint256 _bonusLimitperUser, uint256 _limitToken) public onlyOwner {
        bonusRate = _bonusRate;
        bonusActive = isActive;
        bonusLimitperUser = _bonusLimitperUser;
        limitToken=_limitToken;
    }

    function start(uint256 year,uint256 month,uint256 day) public onlyOwner {
        withdrawEpoch=DateTime.timestampFromDate(year, month, day);
        bonusActive = true;
    }

    function setPoolContract(address _poolContract) public onlyOwner{
        poolContract = _poolContract;
    }
    
    function claimStuckTokens(address token) external onlyOwner {
        updateWithdrawEpoch();
        if (token == address(0x0)) {
            payable(msg.sender).sendValue(address(this).balance);
            return;
        }
        IERC20 ERC20token = IERC20(token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(msg.sender, balance);
    }

    function buyToken(string memory refferreCode, uint256 slippageRate) external payable {
        require(msg.value>0,"Value must be greater than 0");
        updateWithdrawEpoch();
        bytes32 encodedRefferreCode=bytes32(keccak256(abi.encodePacked(refferreCode)));
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(frokToken);

        uint256 initialBalance = IERC20(frokToken).balanceOf(address(this));
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            getSlippage(slippageRate, msg.value),
            path,
            address(this),
            block.timestamp
        );

        uint256 newBalance = IERC20(frokToken).balanceOf(address(this)) - initialBalance;

        
        IERC20(frokToken).transfer(msg.sender, newBalance);

        if(refferalCodes[encodedRefferreCode]!=address(0x0) && refferals[refferalCodes[encodedRefferreCode]].referrer!=address(msg.sender)){
            uint256 bonus=0;
            address referralOwner = refferalCodes[encodedRefferreCode];
            if(bonusActive){
                bonus = newBalance * bonusRate / 100;
                if(earnedBonus(referralOwner) + bonus > bonusLimitperUser){
                    bonus = bonusLimitperUser - earnedBonus(referralOwner);
                }
                uint256 balance = IERC20(frokToken).balanceOf(poolContract);
                if(balance < bonus){
                    bonus = balance;
                }

                if(bonus>0){
                    AmountInformation storage bonusClaimer = bonusClaim[epoch][referralOwner];
                    bonusClaimer.bonusAmount += bonus;
                    refferals[refferalCodes[encodedRefferreCode]].user.push(msg.sender);
                }
            }
        }
    }

    function withdrawableBonus(address _holder) public view returns(uint256){
        uint256 sum=0;
        (uint256 _withdrawEpoch,uint256 _epoch) = viewWithdrawEpoch();
        uint256 rightNow = block.timestamp;
        if(_epoch==0)
            return 0;

        for(uint256 i=0;i<_epoch-1;i++){
            sum+= bonusClaim[i][_holder].bonusAmount;  
        }

        if(bonusClaim[_epoch-1][_holder].bonusAmount>0){
            uint256 count=bonusClaim[_epoch-1][_holder].numberOfWithdraw;
            while(count<vestingNumber){
                if((DateTime.addDays(_withdrawEpoch, count*7)) < rightNow){
                    sum+= (bonusClaim[_epoch-1][_holder].bonusAmount+bonusClaim[_epoch-1][_holder].claimedBonus) / vestingNumber;
                }
                count+=1;
            }
        }
        return sum;
    }

    function claimedBonus(address _holder) public view returns(uint256){
        uint256 sum=0;

        for(uint256 i=0;i<epoch;i++){
            sum+= bonusClaim[i][_holder].claimedBonus;  
        }
        return sum;
    }

    function pendingBonus(address _holder) public view returns(uint256[] memory){
        (uint256 _withdrawEpoch,uint256 _epoch) = viewWithdrawEpoch();
        uint256 rightNow = block.timestamp;

        uint256[] memory information = new uint256[](vestingNumber*4);
        information[1]=(DateTime.addMonths(_withdrawEpoch,1));
        uint256 index=0;
        if(_epoch!=0){
            if(bonusClaim[_epoch-1][_holder].bonusAmount>0){
                uint256 count=bonusClaim[_epoch-1][_holder].numberOfWithdraw;
                while(count < vestingNumber){
                    if((DateTime.addDays(_withdrawEpoch, count*7))> rightNow){
                        information[index*2+1] = (DateTime.addDays(_withdrawEpoch, count*7));
                        information[index*2] = (bonusClaim[_epoch-1][_holder].bonusAmount+bonusClaim[_epoch-1][_holder].claimedBonus) / vestingNumber;
                        index+=1;
                    }
                    count+=1;
                }
            }
        }

        _withdrawEpoch=(DateTime.addMonths(_withdrawEpoch,1));
        if(bonusClaim[_epoch][_holder].bonusAmount>0){
            uint256 count=bonusClaim[_epoch][_holder].numberOfWithdraw;
            while(count < vestingNumber){
                if((DateTime.addDays(_withdrawEpoch, count*7))> rightNow){
                    information[index*2+1] = (DateTime.addDays(_withdrawEpoch, count*7));
                    information[index*2] = (bonusClaim[_epoch][_holder].bonusAmount+bonusClaim[_epoch][_holder].claimedBonus) / vestingNumber;
                    index+=1;
                }
                count+=1;
            }
        }
        return information;
    }

    function bonusGetter(address _holder) public view returns(uint256,uint256,uint256[] memory,uint256){
        
        return (refferals[_holder].user.length,claimedBonus(_holder),pendingBonus(_holder),withdrawableBonus(_holder));
    }

    function earnedBonus(address _holder) internal view returns(uint256){
        uint256 sum=0;

        for(uint256 i=0;i<=epoch;i++){
            sum+= bonusClaim[i][_holder].claimedBonus; 
            sum+= bonusClaim[i][_holder].bonusAmount;
        }
        return sum;
    }

    function withdrawBonusOwner(address _holder) external onlyOwner{
        updateWithdrawEpoch();
        uint256 sumOld=0;
        uint256 rightNow=block.timestamp;
        for(uint256 i=0;i<epoch-1;i++){
            if(bonusClaim[i][_holder].bonusAmount>0){
                sumOld+= bonusClaim[i][_holder].bonusAmount;  
                bonusClaim[i][_holder].claimedBonus=bonusClaim[i][_holder].bonusAmount;
                bonusClaim[i][_holder].bonusAmount=0;
            }
        }
        uint256 sumNew;
        if(bonusClaim[epoch-1][_holder].bonusAmount>0){
            uint256 count=bonusClaim[epoch-1][_holder].numberOfWithdraw;
            uint256 index=count;
            while(count<vestingNumber){
                if((DateTime.addDays(withdrawEpoch, count*7))< rightNow){
                    sumNew+= (bonusClaim[epoch-1][_holder].bonusAmount+bonusClaim[epoch-1][_holder].claimedBonus) / vestingNumber;
                    index=count+1;
                }
                count+=1;
            }
            bonusClaim[epoch-1][_holder].claimedBonus+=sumNew;
            bonusClaim[epoch-1][_holder].bonusAmount-=sumNew;
            bonusClaim[epoch-1][_holder].numberOfWithdraw=index;
        }
        uint256 sum=sumOld+sumNew;
        bool success=IERC20(frokToken).transferFrom(poolContract, msg.sender, sum);
        if(!success) {
            revert();
        }
    }

    function withdrawBonus() external {
        updateWithdrawEpoch();
        uint256 sumOld=0;
        uint256 rightNow=block.timestamp;
        for(uint256 i=0;i<epoch-1;i++){
            if(bonusClaim[i][msg.sender].bonusAmount>0){
                sumOld+= bonusClaim[i][msg.sender].bonusAmount;  
                bonusClaim[i][msg.sender].claimedBonus=bonusClaim[i][msg.sender].bonusAmount;
                bonusClaim[i][msg.sender].bonusAmount=0;
            }
        }
        uint256 sumNew;
        if(bonusClaim[epoch-1][msg.sender].bonusAmount>0){
            uint256 count=bonusClaim[epoch-1][msg.sender].numberOfWithdraw;
            uint256 index=count;
            while(count<vestingNumber){
                if((DateTime.addDays(withdrawEpoch, count*7))< rightNow){
                    sumNew+= (bonusClaim[epoch-1][msg.sender].bonusAmount+bonusClaim[epoch-1][msg.sender].claimedBonus) / vestingNumber;
                    index=count+1;
                }
                count+=1;
            }
            bonusClaim[epoch-1][msg.sender].claimedBonus+=sumNew;
            bonusClaim[epoch-1][msg.sender].bonusAmount-=sumNew;
            bonusClaim[epoch-1][msg.sender].numberOfWithdraw=index;
        }
        uint256 sum=sumOld+sumNew;
        bool success=IERC20(frokToken).transferFrom(poolContract, msg.sender, sum);
        if(!success) {
            revert();
        }
    }

    function updateWithdrawEpoch() public {
        while((DateTime.addMonths(withdrawEpoch, 1)) <= block.timestamp){
            withdrawEpoch= DateTime.addMonths(withdrawEpoch, 1);
            epoch++;
        }
    }

    function viewWithdrawEpoch() public view returns(uint256,uint256){
        uint256 _epoch=epoch;
        uint256 _withdrawEpoch=withdrawEpoch;
        while((DateTime.addMonths(withdrawEpoch, 1)) <= block.timestamp){
            _withdrawEpoch= DateTime.addMonths(withdrawEpoch, 1);
            _epoch++;
        }
        return (_withdrawEpoch,_epoch);
    }

    function getSlippage(uint256 slippageRate,uint256 amount) public view returns (uint256) {
         if(address(router) == address(0)||slippageRate >= 100) {
            return 0;
        }
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(frokToken);

        uint256 amounts = (router.getAmountsOut(amount, path)[1]*(100-slippageRate))/100;

        return amounts;
    }

    function getPrice(uint256 amountIn,bool isBNB) public view returns(uint256){
        if(address(router) == address(0)) {
            return 0;
        }
        address[] memory path = new address[](2);
        if(isBNB){
            path[0] = router.WETH();
            path[1] = address(frokToken);
        }else{
            path[0] = address(frokToken);
            path[1] = router.WETH();
        }

        return router.getAmountsOut(amountIn, path)[1];
    }

    function setRefferalCode(string memory refferalCode) public {
        uint256 holderBalance = IERC20(frokToken).balanceOf(msg.sender);
        require(bytes32(keccak256(abi.encodePacked(refferalCode))) != bytes32(keccak256(abi.encodePacked("A"))), "You need to hold some tokens to set refferal code");
        require(holderBalance >= limitToken, "You need to hold 100,000 FROK to set refferal code");
        bytes32 encodedRefferalCode=bytes32(keccak256(abi.encodePacked(refferalCode)));
        require(refferalCodes[encodedRefferalCode]==address(0x0),"Refferal code already exists");
        refferalCodes[encodedRefferalCode]=msg.sender;
        refferals[msg.sender].refferalCode=refferalCode;
        refferals[msg.sender].referrer=msg.sender;   
        updateWithdrawEpoch();
    }

     function setRefferalCode(string[] memory refferalCode,address[] memory ownerRefferal) external onlyOwner {
        bytes32 encodedRefferalCode;
        for(uint256 i=0;i<refferalCode.length;i++){
            encodedRefferalCode=bytes32(keccak256(abi.encodePacked(refferalCode[i])));
            require(refferalCodes[encodedRefferalCode]==address(0x0),"Refferal code already exists");
            refferalCodes[encodedRefferalCode]=ownerRefferal[i];
            refferals[ownerRefferal[i]].refferalCode=refferalCode[i];
            refferals[ownerRefferal[i]].referrer=ownerRefferal[i];   
        }
        updateWithdrawEpoch();
    }

    function getRefferalCode() public view returns(string memory){
        return refferals[msg.sender].refferalCode;
    }
    
    function getRefferalCodeFromAddress(address _user) public view returns(string memory){
        return refferals[_user].refferalCode;
    }
}