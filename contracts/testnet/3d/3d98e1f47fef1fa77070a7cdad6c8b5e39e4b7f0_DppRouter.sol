/**
 *Submitted for verification at BscScan.com on 2022-09-05
*/

// Sources flattened with hardhat v2.9.9 https://hardhat.org

// File @openzeppelin/contracts-upgradeable/token/ERC20/[email protected]


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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


// File @openzeppelin/contracts-upgradeable/utils/[email protected]



/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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


// File @openzeppelin/contracts-upgradeable/token/ERC20/utils/[email protected]




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


// File contracts/dppHelper/lib/Adminable.sol



abstract contract Adminable {
    event AdminUpdated(address indexed user, address indexed newAdmin);

    address public admin;

    modifier onlyAdmin() virtual {
        require(msg.sender == admin, "UNAUTHORIZED");

        _;
    }

    function setAdmin(address newAdmin) public virtual onlyAdmin {
        _setAdmin(newAdmin);
    }

    function _setAdmin(address newAdmin) internal {
        require(newAdmin != address(0), "Can not set admin to zero address");
        admin = newAdmin;

        emit AdminUpdated(msg.sender, newAdmin);
    }
}


// File contracts/dppHelper/lib/SafeMath.sol



/**
 * @title SafeMath
 * @author DODO Breeder
 *
 * @notice Math operations with safety checks that revert on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "MUL_ERROR");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "DIVIDING_ERROR");
        return a / b;
    }

    function divCeil(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 quotient = div(a, b);
        uint256 remainder = a - quotient * b;
        if (remainder > 0) {
            return quotient + 1;
        } else {
            return quotient;
        }
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SUB_ERROR");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "ADD_ERROR");
        return c;
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = x / 2 + 1;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}


// File contracts/dppHelper/lib/DecimalMath.sol



/**
 * @title DecimalMath
 * @author DODO Breeder
 *
 * @notice Functions for fixed point number with 18 decimals
 */
library DecimalMath {
    using SafeMath for uint256;

    uint256 constant ONE = 10**18;

    function mul(uint256 target, uint256 d) internal pure returns (uint256) {
        return target.mul(d) / ONE;
    }

    function mulCeil(uint256 target, uint256 d) internal pure returns (uint256) {
        return target.mul(d).divCeil(ONE);
    }

    function divFloor(uint256 target, uint256 d) internal pure returns (uint256) {
        return target.mul(ONE).div(d);
    }

    function divCeil(uint256 target, uint256 d) internal pure returns (uint256) {
        return target.mul(ONE).divCeil(d);
    }
}


// File contracts/dppHelper/external/Storage.sol




/**
 * @title Storage
 * @author DODO Breeder
 *
 * @notice Local Variables
 */
contract Storage {
    using SafeMath for uint256;
    enum RStatus {
        ONE,
        ABOVE_ONE,
        BELOW_ONE
    }

    address public _BASE_TOKEN_;
    address public _QUOTE_TOKEN_;

    // ============ Variables for PMM Algorithm ============

    uint256 public _LP_FEE_RATE_;
    uint256 public _MT_FEE_RATE_;
    uint256 public _K_;
    uint256 public _R_;

    RStatus public _R_STATUS_;
    uint256 public _TARGET_BASE_TOKEN_AMOUNT_;
    uint256 public _TARGET_QUOTE_TOKEN_AMOUNT_;
    uint256 public _BASE_BALANCE_;
    uint256 public _QUOTE_BALANCE_;
    uint256 public _I_;

    // ============ Helper Functions ============

    function _checkDODOParameters() internal view returns (uint256) {
        require(_K_ < DecimalMath.ONE, "K>=1");
        require(_K_ > 0, "K=0");
        require(_LP_FEE_RATE_.add(_MT_FEE_RATE_) < DecimalMath.ONE, "FEE_RATE>=1");
    }

    function getOraclePrice() public view returns (uint256) {
        return _I_;
    }
}


// File contracts/dppHelper/lib/DODOMath.sol



/**
 * @title DODOMath
 * @author DODO Breeder
 *
 * @notice Functions for complex calculating. Including ONE Integration and TWO Quadratic solutions
 */
library DODOMath {
    using SafeMath for uint256;

    /*
        Integrate dodo curve fron V1 to V2
        require V0>=V1>=V2>0
        res = (1-k)i(V1-V2)+ikV0*V0(1/V2-1/V1)
        let V1-V2=delta
        res = i*delta*(1-k+k(V0^2/V1/V2))
    */
    function _GeneralIntegrate(
        uint256 V0,
        uint256 V1,
        uint256 V2,
        uint256 i,
        uint256 k
    ) internal pure returns (uint256) {
        uint256 fairAmount = DecimalMath.mul(i, V1.sub(V2)); // i*delta
        uint256 V0V0V1V2 = DecimalMath.divCeil(V0.mul(V0).div(V1), V2);
        uint256 penalty = DecimalMath.mul(k, V0V0V1V2); // k(V0^2/V1/V2)
        return DecimalMath.mul(fairAmount, DecimalMath.ONE.sub(k).add(penalty));
    }

    /*
        The same with integration expression above, we have:
        i*deltaB = (Q2-Q1)*(1-k+kQ0^2/Q1/Q2)
        Given Q1 and deltaB, solve Q2
        This is a quadratic function and the standard version is
        aQ2^2 + bQ2 + c = 0, where
        a=1-k
        -b=(1-k)Q1-kQ0^2/Q1+i*deltaB
        c=-kQ0^2
        and Q2=(-b+sqrt(b^2+4(1-k)kQ0^2))/2(1-k)
        note: another root is negative, abondan
        if deltaBSig=true, then Q2>Q1
        if deltaBSig=false, then Q2<Q1
    */
    function _SolveQuadraticFunctionForTrade(
        uint256 Q0,
        uint256 Q1,
        uint256 ideltaB,
        bool deltaBSig,
        uint256 k
    ) internal pure returns (uint256) {
        // calculate -b value and sig
        // -b = (1-k)Q1-kQ0^2/Q1+i*deltaB
        uint256 kQ02Q1 = DecimalMath.mul(k, Q0).mul(Q0).div(Q1); // kQ0^2/Q1
        uint256 b = DecimalMath.mul(DecimalMath.ONE.sub(k), Q1); // (1-k)Q1
        bool minusbSig = true;
        if (deltaBSig) {
            b = b.add(ideltaB); // (1-k)Q1+i*deltaB
        } else {
            kQ02Q1 = kQ02Q1.add(ideltaB); // i*deltaB+kQ0^2/Q1
        }
        if (b >= kQ02Q1) {
            b = b.sub(kQ02Q1);
            minusbSig = true;
        } else {
            b = kQ02Q1.sub(b);
            minusbSig = false;
        }

        // calculate sqrt
        uint256 squareRoot = DecimalMath.mul(DecimalMath.ONE.sub(k).mul(4), DecimalMath.mul(k, Q0).mul(Q0)); // 4(1-k)kQ0^2
        squareRoot = b.mul(b).add(squareRoot).sqrt(); // sqrt(b*b+4(1-k)kQ0*Q0)

        // final res
        uint256 denominator = DecimalMath.ONE.sub(k).mul(2); // 2(1-k)
        uint256 numerator;
        if (minusbSig) {
            numerator = b.add(squareRoot);
        } else {
            numerator = squareRoot.sub(b);
        }

        if (deltaBSig) {
            return DecimalMath.divFloor(numerator, denominator);
        } else {
            return DecimalMath.divCeil(numerator, denominator);
        }
    }

    /*
        Start from the integration function
        i*deltaB = (Q2-Q1)*(1-k+kQ0^2/Q1/Q2)
        Assume Q2=Q0, Given Q1 and deltaB, solve Q0
        let fairAmount = i*deltaB
    */
    function _SolveQuadraticFunctionForTarget(
        uint256 V1,
        uint256 k,
        uint256 fairAmount
    ) internal pure returns (uint256 V0) {
        // V0 = V1+V1*(sqrt-1)/2k
        uint256 sqrt = DecimalMath.divCeil(DecimalMath.mul(k, fairAmount).mul(4), V1);
        sqrt = sqrt.add(DecimalMath.ONE).mul(DecimalMath.ONE).sqrt();
        uint256 premium = DecimalMath.divCeil(sqrt.sub(DecimalMath.ONE), k.mul(2));
        // V0 is greater than or equal to V1 according to the solution
        return DecimalMath.mul(V1, DecimalMath.ONE.add(premium));
    }
}


// File contracts/dppHelper/external/Pricing.sol






/**
 * @title Pricing
 * @author DODO Breeder
 *
 * @notice DODO Pricing model
 */
contract Pricing is Storage {
    using SafeMath for uint256;

    // ============ R = 1 cases ============

    function _ROneSellBaseToken(uint256 amount, uint256 targetQuoteTokenAmount)
        internal
        view
        returns (uint256 receiveQuoteToken)
    {
        uint256 i = getOraclePrice();
        uint256 Q2 = DODOMath._SolveQuadraticFunctionForTrade(
            targetQuoteTokenAmount,
            targetQuoteTokenAmount,
            DecimalMath.mul(i, amount),
            false,
            _K_
        );
        // in theory Q2 <= targetQuoteTokenAmount
        // however when amount is close to 0, precision problems may cause Q2 > targetQuoteTokenAmount
        return targetQuoteTokenAmount.sub(Q2);
    }

    function _ROneBuyBaseToken(uint256 amount, uint256 targetBaseTokenAmount)
        internal
        view
        returns (uint256 payQuoteToken)
    {
        require(amount < targetBaseTokenAmount, "DODO_BASE_BALANCE_NOT_ENOUGH");
        uint256 B2 = targetBaseTokenAmount.sub(amount);
        payQuoteToken = _RAboveIntegrate(targetBaseTokenAmount, targetBaseTokenAmount, B2);
        return payQuoteToken;
    }

    // ============ R < 1 cases ============

    function _RBelowSellBaseToken(
        uint256 amount,
        uint256 quoteBalance,
        uint256 targetQuoteAmount
    ) internal view returns (uint256 receieQuoteToken) {
        uint256 i = getOraclePrice();
        uint256 Q2 = DODOMath._SolveQuadraticFunctionForTrade(
            targetQuoteAmount,
            quoteBalance,
            DecimalMath.mul(i, amount),
            false,
            _K_
        );
        return quoteBalance.sub(Q2);
    }

    function _RBelowBuyBaseToken(
        uint256 amount,
        uint256 quoteBalance,
        uint256 targetQuoteAmount
    ) internal view returns (uint256 payQuoteToken) {
        // Here we don't require amount less than some value
        // Because it is limited at upper function
        // See Trader.queryBuyBaseToken
        uint256 i = getOraclePrice();
        uint256 Q2 = DODOMath._SolveQuadraticFunctionForTrade(
            targetQuoteAmount,
            quoteBalance,
            DecimalMath.mulCeil(i, amount),
            true,
            _K_
        );
        return Q2.sub(quoteBalance);
    }

    function _RBelowBackToOne() internal view returns (uint256 payQuoteToken) {
        // important: carefully design the system to make sure spareBase always greater than or equal to 0
        uint256 spareBase = _BASE_BALANCE_.sub(_TARGET_BASE_TOKEN_AMOUNT_);
        uint256 price = getOraclePrice();
        uint256 fairAmount = DecimalMath.mul(spareBase, price);
        uint256 newTargetQuote = DODOMath._SolveQuadraticFunctionForTarget(_QUOTE_BALANCE_, _K_, fairAmount);
        return newTargetQuote.sub(_QUOTE_BALANCE_);
    }

    // ============ R > 1 cases ============

    function _RAboveBuyBaseToken(
        uint256 amount,
        uint256 baseBalance,
        uint256 targetBaseAmount
    ) internal view returns (uint256 payQuoteToken) {
        require(amount < baseBalance, "DODO_BASE_BALANCE_NOT_ENOUGH");
        uint256 B2 = baseBalance.sub(amount);
        return _RAboveIntegrate(targetBaseAmount, baseBalance, B2);
    }

    function _RAboveSellBaseToken(
        uint256 amount,
        uint256 baseBalance,
        uint256 targetBaseAmount
    ) internal view returns (uint256 receiveQuoteToken) {
        // here we don't require B1 <= targetBaseAmount
        // Because it is limited at upper function
        // See Trader.querySellBaseToken
        uint256 B1 = baseBalance.add(amount);
        return _RAboveIntegrate(targetBaseAmount, B1, baseBalance);
    }

    function _RAboveBackToOne() internal view returns (uint256 payBaseToken) {
        // important: carefully design the system to make sure spareBase always greater than or equal to 0
        uint256 spareQuote = _QUOTE_BALANCE_.sub(_TARGET_QUOTE_TOKEN_AMOUNT_);
        uint256 price = getOraclePrice();
        uint256 fairAmount = DecimalMath.divFloor(spareQuote, price);
        uint256 newTargetBase = DODOMath._SolveQuadraticFunctionForTarget(_BASE_BALANCE_, _K_, fairAmount);
        return newTargetBase.sub(_BASE_BALANCE_);
    }

    // ============ Helper functions ============

    function getExpectedTarget() public view returns (uint256 baseTarget, uint256 quoteTarget) {
        uint256 Q = _QUOTE_BALANCE_;
        uint256 B = _BASE_BALANCE_;
        if (_R_STATUS_ == RStatus.ONE) {
            return (_TARGET_BASE_TOKEN_AMOUNT_, _TARGET_QUOTE_TOKEN_AMOUNT_);
        } else if (_R_STATUS_ == RStatus.BELOW_ONE) {
            uint256 payQuoteToken = _RBelowBackToOne();
            return (_TARGET_BASE_TOKEN_AMOUNT_, Q.add(payQuoteToken));
        } else if (_R_STATUS_ == RStatus.ABOVE_ONE) {
            uint256 payBaseToken = _RAboveBackToOne();
            return (B.add(payBaseToken), _TARGET_QUOTE_TOKEN_AMOUNT_);
        }
    }

    function getMidPrice() public view returns (uint256 midPrice) {
        (uint256 baseTarget, uint256 quoteTarget) = getExpectedTarget();
        if (_R_STATUS_ == RStatus.BELOW_ONE) {
            uint256 R = DecimalMath.divFloor(quoteTarget.mul(quoteTarget).div(_QUOTE_BALANCE_), _QUOTE_BALANCE_);
            R = DecimalMath.ONE.sub(_K_).add(DecimalMath.mul(_K_, R));
            return DecimalMath.divFloor(getOraclePrice(), R);
        } else {
            uint256 R = DecimalMath.divFloor(baseTarget.mul(baseTarget).div(_BASE_BALANCE_), _BASE_BALANCE_);
            R = DecimalMath.ONE.sub(_K_).add(DecimalMath.mul(_K_, R));
            return DecimalMath.mul(getOraclePrice(), R);
        }
    }

    function _RAboveIntegrate(
        uint256 B0,
        uint256 B1,
        uint256 B2
    ) internal view returns (uint256) {
        uint256 i = getOraclePrice();
        return DODOMath._GeneralIntegrate(B0, B1, B2, i, _K_);
    }

    // function _RBelowIntegrate(
    //     uint256 Q0,
    //     uint256 Q1,
    //     uint256 Q2
    // ) internal view returns (uint256) {
    //     uint256 i = getOraclePrice();
    //     i = DecimalMath.divFloor(DecimalMath.ONE, i); // 1/i
    //     return DODOMath._GeneralIntegrate(Q0, Q1, Q2, i, _K_);
    // }
}


// File contracts/dppHelper/external/Trader.sol






/**
 * @title Trader
 * @author DODO Breeder
 *
 * @notice Functions for trader operations
 */
contract QueryTrader is Storage, Pricing{
    using SafeMath for uint256;

    function _querySellBaseToken(uint256 amount)
        internal
        view
        returns (
            uint256 receiveQuote,
            uint256 lpFeeQuote,
            uint256 mtFeeQuote,
            RStatus newRStatus,
            uint256 newQuoteTarget,
            uint256 newBaseTarget
        )
    {
        (newBaseTarget, newQuoteTarget) = getExpectedTarget();

        uint256 sellBaseAmount = amount;

        if (_R_STATUS_ == RStatus.ONE) {
            // case 1: R=1
            // R falls below one
            receiveQuote = _ROneSellBaseToken(sellBaseAmount, newQuoteTarget);
            newRStatus = RStatus.BELOW_ONE;
        } else if (_R_STATUS_ == RStatus.ABOVE_ONE) {
            uint256 backToOnePayBase = newBaseTarget.sub(_BASE_BALANCE_);
            uint256 backToOneReceiveQuote = _QUOTE_BALANCE_.sub(newQuoteTarget);
            // case 2: R>1
            // complex case, R status depends on trading amount
            if (sellBaseAmount < backToOnePayBase) {
                // case 2.1: R status do not change
                receiveQuote = _RAboveSellBaseToken(sellBaseAmount, _BASE_BALANCE_, newBaseTarget);
                newRStatus = RStatus.ABOVE_ONE;
                if (receiveQuote > backToOneReceiveQuote) {
                    // [Important corner case!] may enter this branch when some precision problem happens. And consequently contribute to negative spare quote amount
                    // to make sure spare quote>=0, mannually set receiveQuote=backToOneReceiveQuote
                    receiveQuote = backToOneReceiveQuote;
                }
            } else if (sellBaseAmount == backToOnePayBase) {
                // case 2.2: R status changes to ONE
                receiveQuote = backToOneReceiveQuote;
                newRStatus = RStatus.ONE;
            } else {
                // case 2.3: R status changes to BELOW_ONE
                receiveQuote = backToOneReceiveQuote.add(
                    _ROneSellBaseToken(sellBaseAmount.sub(backToOnePayBase), newQuoteTarget)
                );
                newRStatus = RStatus.BELOW_ONE;
            }
        } else {
            // _R_STATUS_ == Types.RStatus.BELOW_ONE
            // case 3: R<1
            receiveQuote = _RBelowSellBaseToken(sellBaseAmount, _QUOTE_BALANCE_, newQuoteTarget);
            newRStatus = RStatus.BELOW_ONE;
        }

        // count fees
        lpFeeQuote = DecimalMath.mul(receiveQuote, _LP_FEE_RATE_);
        mtFeeQuote = DecimalMath.mul(receiveQuote, _MT_FEE_RATE_);
        receiveQuote = receiveQuote.sub(lpFeeQuote).sub(mtFeeQuote);

        return (receiveQuote, lpFeeQuote, mtFeeQuote, newRStatus, newQuoteTarget, newBaseTarget);
    }

    function _queryBuyBaseToken(uint256 amount)
        internal
        view
        returns (
            uint256 payQuote,
            uint256 lpFeeBase,
            uint256 mtFeeBase,
            RStatus newRStatus,
            uint256 newQuoteTarget,
            uint256 newBaseTarget
        )
    {
        (newBaseTarget, newQuoteTarget) = getExpectedTarget();

        // charge fee from user receive amount
        lpFeeBase = DecimalMath.mul(amount, _LP_FEE_RATE_);
        mtFeeBase = DecimalMath.mul(amount, _MT_FEE_RATE_);
        uint256 buyBaseAmount = amount.add(lpFeeBase).add(mtFeeBase);

        if (_R_STATUS_ == RStatus.ONE) {
            // case 1: R=1
            payQuote = _ROneBuyBaseToken(buyBaseAmount, newBaseTarget);
            newRStatus = RStatus.ABOVE_ONE;
        } else if (_R_STATUS_ == RStatus.ABOVE_ONE) {
            // case 2: R>1
            payQuote = _RAboveBuyBaseToken(buyBaseAmount, _BASE_BALANCE_, newBaseTarget);
            newRStatus = RStatus.ABOVE_ONE;
        } else if (_R_STATUS_ == RStatus.BELOW_ONE) {
            uint256 backToOnePayQuote = newQuoteTarget.sub(_QUOTE_BALANCE_);
            uint256 backToOneReceiveBase = _BASE_BALANCE_.sub(newBaseTarget);
            // case 3: R<1
            // complex case, R status may change
            if (buyBaseAmount < backToOneReceiveBase) {
                // case 3.1: R status do not change
                // no need to check payQuote because spare base token must be greater than zero
                payQuote = _RBelowBuyBaseToken(buyBaseAmount, _QUOTE_BALANCE_, newQuoteTarget);
                newRStatus = RStatus.BELOW_ONE;
            } else if (buyBaseAmount == backToOneReceiveBase) {
                // case 3.2: R status changes to ONE
                payQuote = backToOnePayQuote;
                newRStatus = RStatus.ONE;
            } else {
                // case 3.3: R status changes to ABOVE_ONE
                payQuote = backToOnePayQuote.add(
                    _ROneBuyBaseToken(buyBaseAmount.sub(backToOneReceiveBase), newBaseTarget)
                );
                newRStatus = RStatus.ABOVE_ONE;
            }
        }

        return (payQuote, lpFeeBase, mtFeeBase, newRStatus, newQuoteTarget, newBaseTarget);
    }
}


// File contracts/dppHelper/lib/PMMPricing.sol





/**
 * @title Pricing
 * @author DODO Breeder
 *
 * @notice DODO Pricing model
 */

library PMMPricing {
    using SafeMath for uint256;

    enum RState {
        ONE,
        ABOVE_ONE,
        BELOW_ONE
    }

    struct PMMState {
        uint256 i;
        uint256 K;
        uint256 B;
        uint256 Q;
        uint256 B0;
        uint256 Q0;
        RState R;
    }

    /*
    // ============ buy & sell ============

    function sellBaseToken(PMMState memory state, uint256 payBaseAmount)
        internal
        pure
        returns (uint256 receiveQuoteAmount, RState newR)
    {
        if (state.R == RState.ONE) {
            // case 1: R=1
            // R falls below one
            receiveQuoteAmount = _ROneSellBaseToken(state, payBaseAmount);
            newR = RState.BELOW_ONE;
        } else if (state.R == RState.ABOVE_ONE) {
            uint256 backToOnePayBase = state.B0.sub(state.B);
            uint256 backToOneReceiveQuote = state.Q.sub(state.Q0);
            // case 2: R>1
            // complex case, R status depends on trading amount
            if (payBaseAmount < backToOnePayBase) {
                // case 2.1: R status do not change
                receiveQuoteAmount = _RAboveSellBaseToken(state, payBaseAmount);
                newR = RState.ABOVE_ONE;
                if (receiveQuoteAmount > backToOneReceiveQuote) {
                    // [Important corner case!] may enter this branch when some precision problem happens. And consequently contribute to negative spare quote amount
                    // to make sure spare quote>=0, mannually set receiveQuote=backToOneReceiveQuote
                    receiveQuoteAmount = backToOneReceiveQuote;
                }
            } else if (payBaseAmount == backToOnePayBase) {
                // case 2.2: R status changes to ONE
                receiveQuoteAmount = backToOneReceiveQuote;
                newR = RState.ONE;
            } else {
                // case 2.3: R status changes to BELOW_ONE
                receiveQuoteAmount = backToOneReceiveQuote.add(
                    _ROneSellBaseToken(state, payBaseAmount.sub(backToOnePayBase))
                );
                newR = RState.BELOW_ONE;
            }
        } else {
            // state.R == RState.BELOW_ONE
            // case 3: R<1
            receiveQuoteAmount = _RBelowSellBaseToken(state, payBaseAmount);
            newR = RState.BELOW_ONE;
        }
    }

    function sellQuoteToken(PMMState memory state, uint256 payQuoteAmount)
        internal
        pure
        returns (uint256 receiveBaseAmount, RState newR)
    {
        if (state.R == RState.ONE) {
            receiveBaseAmount = _ROneSellQuoteToken(state, payQuoteAmount);
            newR = RState.ABOVE_ONE;
        } else if (state.R == RState.ABOVE_ONE) {
            receiveBaseAmount = _RAboveSellQuoteToken(state, payQuoteAmount);
            newR = RState.ABOVE_ONE;
        } else {
            uint256 backToOnePayQuote = state.Q0.sub(state.Q);
            uint256 backToOneReceiveBase = state.B.sub(state.B0);
            if (payQuoteAmount < backToOnePayQuote) {
                receiveBaseAmount = _RBelowSellQuoteToken(state, payQuoteAmount);
                newR = RState.BELOW_ONE;
                if (receiveBaseAmount > backToOneReceiveBase) {
                    receiveBaseAmount = backToOneReceiveBase;
                }
            } else if (payQuoteAmount == backToOnePayQuote) {
                receiveBaseAmount = backToOneReceiveBase;
                newR = RState.ONE;
            } else {
                receiveBaseAmount = backToOneReceiveBase.add(
                    _ROneSellQuoteToken(state, payQuoteAmount.sub(backToOnePayQuote))
                );
                newR = RState.ABOVE_ONE;
            }
        }
    }

    // ============ R = 1 cases ============

    function _ROneSellBaseToken(PMMState memory state, uint256 payBaseAmount)
        internal
        pure
        returns (
            uint256 // receiveQuoteToken
        )
    {
        // in theory Q2 <= targetQuoteTokenAmount
        // however when amount is close to 0, precision problems may cause Q2 > targetQuoteTokenAmount
        return DODOMath._SolveQuadraticFunctionForTrade(state.Q0, state.Q0, payBaseAmount, state.i, state.K);
    }

    function _ROneSellQuoteToken(PMMState memory state, uint256 payQuoteAmount)
        internal
        pure
        returns (
            uint256 // receiveBaseToken
        )
    {
        return
            DODOMath._SolveQuadraticFunctionForTrade(
                state.B0,
                state.B0,
                payQuoteAmount,
                DecimalMath.reciprocalFloor(state.i),
                state.K
            );
    }

    // ============ R < 1 cases ============

    function _RBelowSellQuoteToken(PMMState memory state, uint256 payQuoteAmount)
        internal
        pure
        returns (
            uint256 // receiveBaseToken
        )
    {
        return
            DODOMath._GeneralIntegrate(
                state.Q0,
                state.Q.add(payQuoteAmount),
                state.Q,
                DecimalMath.reciprocalFloor(state.i),
                state.K
            );
    }

    function _RBelowSellBaseToken(PMMState memory state, uint256 payBaseAmount)
        internal
        pure
        returns (
            uint256 // receiveQuoteToken
        )
    {
        return DODOMath._SolveQuadraticFunctionForTrade(state.Q0, state.Q, payBaseAmount, state.i, state.K);
    }

    // ============ R > 1 cases ============

    function _RAboveSellBaseToken(PMMState memory state, uint256 payBaseAmount)
        internal
        pure
        returns (
            uint256 // receiveQuoteToken
        )
    {
        return DODOMath._GeneralIntegrate(state.B0, state.B.add(payBaseAmount), state.B, state.i, state.K);
    }

    function _RAboveSellQuoteToken(PMMState memory state, uint256 payQuoteAmount)
        internal
        pure
        returns (
            uint256 // receiveBaseToken
        )
    {
        return
            DODOMath._SolveQuadraticFunctionForTrade(
                state.B0,
                state.B,
                payQuoteAmount,
                DecimalMath.reciprocalFloor(state.i),
                state.K
            );
    }

    // ============ Helper functions ============

    function adjustedTarget(PMMState memory state) internal pure {
        if (state.R == RState.BELOW_ONE) {
            state.Q0 = DODOMath._SolveQuadraticFunctionForTarget(state.Q, state.B.sub(state.B0), state.i, state.K);
        } else if (state.R == RState.ABOVE_ONE) {
            state.B0 = DODOMath._SolveQuadraticFunctionForTarget(
                state.B,
                state.Q.sub(state.Q0),
                DecimalMath.reciprocalFloor(state.i),
                state.K
            );
        }
    }

    function getMidPrice(PMMState memory state) internal pure returns (uint256) {
        if (state.R == RState.BELOW_ONE) {
            uint256 R = DecimalMath.divFloor(state.Q0.mul(state.Q0).div(state.Q), state.Q);
            R = DecimalMath.ONE.sub(state.K).add(DecimalMath.mulFloor(state.K, R));
            return DecimalMath.divFloor(state.i, R);
        } else {
            uint256 R = DecimalMath.divFloor(state.B0.mul(state.B0).div(state.B), state.B);
            R = DecimalMath.ONE.sub(state.K).add(DecimalMath.mulFloor(state.K, R));
            return DecimalMath.mulFloor(state.i, R);
        }
    }
    */
}


// File contracts/dppHelper/interfaces/IDODOV2.sol



interface IDODOV2 {
    //========== Common ==================

    function sellBase(address to) external returns (uint256 receiveQuoteAmount);

    function sellQuote(address to) external returns (uint256 receiveBaseAmount);

    function querySellQuote(address trader, uint256 payQuoteAmount)
        external
        view
        returns (
            uint256 receiveBaseAmount,
            uint256 mtFee,
            PMMPricing.RState newRState,
            uint256 newQuoteTarget
        );

    function querySellBase(address trader, uint256 payBaseAmount)
        external
        view
        returns (
            uint256 receiveQuoteAmount,
            uint256 mtFee,
            PMMPricing.RState newRState,
            uint256 newBaseTarget
        );

    function getVaultReserve() external view returns (uint256 baseReserve, uint256 quoteReserve);

    function _BASE_TOKEN_() external view returns (address);

    function _QUOTE_TOKEN_() external view returns (address);

    function getPMMStateForCall()
        external
        view
        returns (
            uint256 i,
            uint256 K,
            uint256 B,
            uint256 Q,
            uint256 B0,
            uint256 Q0,
            uint256 R
        );

    function getUserFeeRate(address user) external view returns (uint256 lpFeeRate, uint256 mtFeeRate);

    function getDODOPoolBidirection(address token0, address token1)
        external
        view
        returns (address[] memory, address[] memory);

    //========== DODOVendingMachine ========

    function createDODOVendingMachine(
        address baseToken,
        address quoteToken,
        uint256 lpFeeRate,
        uint256 i,
        uint256 k,
        bool isOpenTWAP
    ) external returns (address newVendingMachine);

    function buyShares(address to)
        external
        returns (
            uint256,
            uint256,
            uint256
        );

    //========== DODOPrivatePool ===========

    function createDODOPrivatePool() external returns (address newPrivatePool);

    function initDODOPrivatePool(
        address dppAddress,
        address creator,
        address baseToken,
        address quoteToken,
        uint256 lpFeeRate,
        uint256 k,
        uint256 i,
        bool isOpenTwap
    ) external;

    function reset(
        address operator,
        uint256 newLpFeeRate,
        uint256 newI,
        uint256 newK,
        uint256 baseOutAmount,
        uint256 quoteOutAmount,
        uint256 minBaseReserve,
        uint256 minQuoteReserve
    ) external returns (bool);

    function _OWNER_() external returns (address);

    //========== CrowdPooling ===========

    function createCrowdPooling() external returns (address payable newCrowdPooling);

    function initCrowdPooling(
        address cpAddress,
        address creator,
        address[] memory tokens,
        uint256[] memory timeLine,
        uint256[] memory valueList,
        bool[] memory switches,
        int256 globalQuota
    ) external;

    function bid(address to) external;
}


// File contracts/dppHelper/dppRouter.sol
// SPDX-License-Identifier: Apache-2.0

pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;





contract DppRouter is QueryTrader, Adminable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    mapping(address => mapping(address => address)) public availablePools;
    mapping(address => bool) public availableBaseToken;

    struct PoolInfo {
        address baseToken;
        address quoteToken;
        address pairAddress;
    }

    // ============ modifier ============

    modifier judgeExpired(uint256 deadLine) {
        require(deadLine >= block.timestamp, "dppRouter: expired");
        _;
    }

    constructor(address _admin) public {
        _setAdmin(_admin);
    }

    function setAvailablePools(PoolInfo[] memory _pools) public onlyAdmin {
        for (uint256 i = 0; i < _pools.length; ++i) {
            availablePools[_pools[i].baseToken][_pools[i].quoteToken] = _pools[i].pairAddress;
        }
    }

    function setAvailableBaseTokens(address[] calldata _newBaseTokens) public onlyAdmin {
        for(uint256 i = 0 ; i < _newBaseTokens.length; ++i) {
            availableBaseToken[_newBaseTokens[i]] = true;
        }
    }

    function delBaseTokens(address[] calldata _delBaseTokens) public onlyAdmin {
        for(uint256 i = 0 ; i < _delBaseTokens.length; ++i) {
            availableBaseToken[_delBaseTokens[i]] = false;
        }
    }

    function setOneAvailablePool(
        address _baseToken,
        address _quoteToken,
        address _pairAddress
    ) public onlyAdmin {
        availablePools[_baseToken][_quoteToken] = _pairAddress;
    }

    //need out token must be baseToken, busd,usdc
    function swapTokensForExactTokens(
        uint256 _amountOut,
        uint256 _amountInMax,
        address[] calldata _path,
        address _to,
        uint256 _deadline
    ) external judgeExpired(_deadline) returns (uint256[] memory amounts) {
        address V2pair = _getPairAddr(_path[0], _path[1]);
        // insure base token must be stable coins
        require(availableBaseToken[IDODOV2(V2pair)._BASE_TOKEN_()], "dppRouter: illegel base token query buy base");

        uint256 quoteInAmount = queryBuyBaseToken(_amountOut, V2pair);
        require(quoteInAmount <= _amountInMax, "dppRouter: amount in exceed");

        IERC20Upgradeable(_path[0]).safeTransferFrom(msg.sender, address(this), quoteInAmount);
        IERC20Upgradeable(_path[0]).safeTransfer(V2pair, quoteInAmount);
        IDODOV2(V2pair).sellQuote(_to);
        amounts[0] = quoteInAmount;
    }

    function swapExactTokensForTokens(
        uint256 _amountIn,
        uint256 _amountOutMin,
        address[] calldata _path,
        address _to,
        uint256 _deadline
    ) external judgeExpired(_deadline) returns (uint256[] memory amounts) {
        address V2pair = _getPairAddr(_path[0], _path[1]);

        if (_path[0] == IDODOV2(V2pair)._BASE_TOKEN_()) {
            // sell base
            uint256 QuoteOutAmount = querySellBaseToken(_amountIn, V2pair);
            require(QuoteOutAmount >= _amountOutMin, "dppRouter: receive amount not enough");

            IERC20Upgradeable(_path[0]).safeTransferFrom(msg.sender, address(this), _amountIn);
            IERC20Upgradeable(_path[0]).safeTransfer(V2pair, _amountIn);
            IDODOV2(V2pair).sellBase(_to);
        } else if (_path[0] == IDODOV2(V2pair)._QUOTE_TOKEN_()) {
            uint256 BaseOutAmount = querySellQuoteToken(_amountIn, V2pair);
            require(BaseOutAmount >= _amountOutMin, "dppRouter: receive amount not enough");

            IERC20Upgradeable(_path[0]).safeTransferFrom(msg.sender, address(this), _amountIn);
            IERC20Upgradeable(_path[0]).safeTransfer(V2pair, _amountIn);
            IDODOV2(V2pair).sellQuote(_to);
        }
    }

    // ============ Query Functions ============

    function querySellBaseToken(uint256 _amount, address _pair) public view returns (uint256 receiveQuote) {
       (receiveQuote, , , ) =  IDODOV2(_pair).querySellBase(address(this), _amount);
    }

    function querySellQuoteToken(uint256 _amount, address _pair) public view returns (uint256 receiveBase) {
        (receiveBase, , , ) = IDODOV2(_pair).querySellQuote(address(this), _amount);
    }

    function queryBuyBaseToken(uint256 _amount, address _pair) public returns (uint256 payQuote) {
        _updatePairDetails(_pair);
        (payQuote, , , , , ) = _queryBuyBaseToken(_amount);
        return payQuote;
    }

    // =========== internal ===============

    function _updatePairDetails(address _V2pair) internal {
        //uint256 _R_;
        {
        (
            _I_,
            _K_,
            _BASE_BALANCE_,
            _QUOTE_BALANCE_,
            _TARGET_BASE_TOKEN_AMOUNT_,
            _TARGET_QUOTE_TOKEN_AMOUNT_,
            _R_
        ) = IDODOV2(_V2pair).getPMMStateForCall();
        _R_STATUS_ = RStatus(uint32(_R_));
        }

        (_LP_FEE_RATE_, _MT_FEE_RATE_) = IDODOV2(_V2pair).getUserFeeRate(address(this));
        _BASE_TOKEN_ = IDODOV2(_V2pair)._BASE_TOKEN_();
        _QUOTE_TOKEN_ = IDODOV2(_V2pair)._QUOTE_TOKEN_();
    }

    function _getPairAddr(address _sellToken, address _buyToken) internal returns (address V2Pair) {
        V2Pair = availablePools[_sellToken][_buyToken] != address(0)
            ? availablePools[_sellToken][_buyToken]
            : availablePools[_buyToken][_sellToken];
        require(V2Pair != address(0), "dppRouter: no pair");
        return V2Pair;
    }
}