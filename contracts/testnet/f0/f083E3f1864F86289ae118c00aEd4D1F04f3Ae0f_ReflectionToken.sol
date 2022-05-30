pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract ReflectionToken is Context, IERC20, Ownable {
    using Address for address;

    string private _name = "Positivity";
    string private _symbol = "+VE";
    uint8 private _decimals = 18;

    uint256 private _simpleTokenTotal = 5000000000 * (10**_decimals); // 5 billion tokens
    uint256 private MAX_UINT = type(uint256).max;
    uint256 private _initialReflectionPool = MAX_UINT; // (MAX_UINT - (MAX_UINT % _simpleTokenTotal));//type(uint256).max;
    uint256 private _reflectionPoolTotal = _initialReflectionPool;
    uint16 private _taxRate = 300; // Tax rate, represented as hundreds of a percent, e.g 100 = 1%
    uint256 private _totalFeesDeducted;
    uint256 private _totalReflectionFeesDeducted;

    mapping(address => uint256) private _reflectionPoolBalances;
    mapping(address => uint256) private _simpleTokenBalances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcluded;
    address[] private _excluded;

    event TaxRateChange(uint8 newTaxRate);

    constructor() {
        _reflectionPoolBalances[_msgSender()] = _reflectionPoolTotal;
        emit Transfer(address(0), _msgSender(), _simpleTokenTotal);
    }

    /** @dev Return the tokens allowed to be spent by `spender` on behalf of `tokenOwner`
     * @param tokenOwner The owner of the tokens to be spent
     * @param spender The address that is allowed to spend the tokens
     */
    function allowance(address tokenOwner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[tokenOwner][spender];
    }

    /** @dev Give permission for `spender` to spend tokens on behalf of the caller
     * @param spender The address that is allowed to spend the tokens
     * @param amount The amount of tokens to be allowed to be spent. Passing max `uint256` value will allow unlimited tokens to be spent.
     */
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /** @dev Calculate the balance of the given address
    * @param account The address holding the tokens
    * @return The balance of the given address
    If an excluded account, simply return a balance from the simple token balances
    Otherwise, calculate the token balance based on the account's reflection pool balance    
    */
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        if (_isExcluded[account]) return _simpleTokenBalances[account];
        return
            tokenFromReflection(_reflectionPoolBalances[account], _getRate());
    }

    /** @dev Return the number of decimals used to get its user representation. */
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    /** @dev Returns the name of the token. */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /** @dev Returns the symbol of the token. */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /** @dev Returns the total number of tokens. 
        Note that this may differ from the sum of calls to getBalance() for all accounts,
        since reflection will cause individual balances for included accounts to increase.
    */
    function totalSupply() public view virtual override returns (uint256) {
        return _simpleTokenTotal;
    }

    /** @dev Sends `amount` tokens to `recipient`.
     * @param recipient The address of the recipient
     * @param amount The amount of tokens to send
     */
    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /** @dev Moves amount tokens from sender to recipient using the allowance mechanism. amount is then deducted from the caller’s allowance.    
    Returns a boolean value indicating whether the operation succeeded.
    Emits a Transfer event.
    * @param from The address of the sender
    * @param recipient The address of the recipient
    * @param amount The amount of tokens to send
    */
    function transferFrom(
        address from,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, recipient, amount);
        return true;
    }

    /** @dev Update `tokenOwner`s allowance for `spender` based on spent `amount`.
     * @param tokenOwner The address of the owner
     * @param spender The address of the spender
     * @param amount The amount of tokens to spend
     */
    function _spendAllowance(
        address tokenOwner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(tokenOwner, spender);
        if (currentAllowance != type(uint256).max) {
            // Infinite allowance represented by max `uint256`
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(tokenOwner, spender, currentAllowance - amount);
            }
        }
    }

    function _approve(
        address tokenOwner,
        address spender,
        uint256 amount
    ) private {
        require(
            tokenOwner != address(0),
            "ERC20: approve from the zero address"
        );
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[tokenOwner][spender] = amount;
        emit Approval(tokenOwner, spender, amount);
    }

    /** @dev Increase allowance by `addedValue` amount.
     * @param spender The address of the spender
     * @param addedValue The amount by which to to increase the allowance
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address msgSender = _msgSender();
        _approve(
            msgSender,
            spender,
            allowance(msgSender, spender) + addedValue
        );
        return true;
    }

    /** @dev Decrease allowance by `subtractedValue` amount.
     * @param spender The address of the spender
     * @param subtractedValue The amount by which to to decrease the allowance
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address msgSender = _msgSender();
        uint256 currentAllowance = allowance(msgSender, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(msgSender, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    /** @dev Return true if the `account` is excluded from the reflection tax system
     * @param account The address of the account
     */
    function isExcluded(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    /** @dev Return the initial reflection pool amount */
    function initialReflectionPool() public view returns (uint256) {
        return _initialReflectionPool;
    }

    function reflectionPoolTotal() public view returns (uint256) {
        return _reflectionPoolTotal;
    }

    /** @dev Return the total of tokens deducted as fees */
    function totalFeesDeducted() public view returns (uint256) {
        return _totalFeesDeducted;
    }

    /** @dev Return the total reflection deducted as fees */
    function totalReflectionFeesDeducted() public view returns (uint256) {
        return _totalReflectionFeesDeducted;
    }

    /** @dev Given a reflection amount, return the equivalent token amount
     * @param reflectionAmount The amount of reflection to be converted to tokens
     * @param currentRate The current exchange rate
     */
    function tokenFromReflection(uint256 reflectionAmount, uint256 currentRate)
        public
        view
        returns (uint256)
    {
        require(
            reflectionAmount <= _reflectionPoolTotal,
            "Amount must be less than reflection pool total"
        );
        return reflectionAmount / currentRate;
    }

    /** @dev Given a token amount, return the equivalent reflection amount
     * @param tokenAmount The amount of tokens to be converted to reflection
     * @param currentRate The current exchange rate
     */
    function reflectionFromToken(uint256 tokenAmount, uint256 currentRate)
        public
        view
        returns (uint256)
    {
        require(
            tokenAmount <= _simpleTokenTotal,
            "Amount must be less than simple token total"
        );
        return tokenAmount * currentRate;
    }

    /** @dev Exclude an account from participating in the reflection system.
     * Transfers to or from accounts marked as excluded will not be charged a transfer fee, and will not receive reflection tax.
     * Their reflection balance is converted to a simple token balance.
     * @param account The address of the account to be excluded
     */
    function excludeAccount(address account) external onlyOwner {
        require(!_isExcluded[account], "Account is already excluded");

        // If the account has a reflection balance, transfer it to the simple token balance
        if (_reflectionPoolBalances[account] > 0) {
            _simpleTokenBalances[account] = tokenFromReflection(
                _reflectionPoolBalances[account],
                _getRate()
            );
            _reflectionPoolBalances[account] = 0; // Remove the reflection balance so that no reflections are lost to excluded accounts
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    /** @dev Include a previously excluded account in the reflection system.
     * Their simple token balance is converted to reflection balance.
     * @param account The address of the account to be excluded
     */
    function includeAccount(address account) external onlyOwner {
        require(_isExcluded[account], "Account is already excluded");

        // Update the lookup
        _isExcluded[account] = false;

        // If the account has a simple token balance, move it back to the reflection pool
        uint256 currentSimpleTokenBalance = _simpleTokenBalances[account];
        if (currentSimpleTokenBalance > 0) {
            _reflectionPoolBalances[account] = reflectionFromToken(
                currentSimpleTokenBalance,
                _getRate()
            ); //Restore the reflection balance
            _simpleTokenBalances[account] = 0; // Zero out the simple token balance
        }

        // Remove from excluded accounts list
        uint256 length = _excluded.length;
        for (uint256 i = 0; i < length; i++) {
            if (_excluded[i] == account) {
                // Copy the last item to the current index, then delete the last item
                _excluded[i] = _excluded[_excluded.length - 1];
                _excluded.pop();
                break;
            }
        }
    }

    /** @dev Transfer an amount of tokens from `from` to `recipient`.
     * @param from The address of the sender
     * @param recipient The address of the recipient
     * @param tokenAmount The amount of tokens to send
     * A fee will be charged depending on whether the sender or the recipient are excluded from the reflection system.
     */
    /*function _wrong_transfer(
        address from,
        address recipient,
        uint256 tokenAmount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(tokenAmount > 0, "ERC20: transfer amount must be greater than 0");

        uint256 rate = _getRate();
        uint256 reflectionAmount = reflectionFromToken(tokenAmount, rate);
        // If either the sender or the recipient are excluded, no fee is charged
        if (_isExcluded[from] || _isExcluded[recipient]) {
            // Don't charge any fee
            _moveTokens(from, recipient, tokenAmount, reflectionAmount);    
        } 
        else {
            // Charge fee
            ( uint256 tokenFee, uint256 reflectionFee) = _calculateTransferFees(tokenAmount, rate);
            _reflectFee(reflectionFee, tokenFee);

            // Update balances
            // BUG: The recipient should be deducted the whole amount!
            _moveTokens(from, recipient, tokenAmount - tokenFee, reflectionAmount - reflectionFee);    
        }
    }*/

    function _transfer(
        address from,
        address recipient,
        uint256 tokenAmount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(
            tokenAmount > 0,
            "ERC20: transfer amount must be greater than 0"
        );

        uint256 rate = _getRate();
        uint256 reflectionAmount = reflectionFromToken(tokenAmount, rate);

        uint256 tokenFee;
        uint256 reflectionFee;
        // If neither are excluded, a fee is charged
        if (!_isExcluded[from] && !_isExcluded[recipient]) {
            (tokenFee, reflectionFee) = _calculateTransferFees(
                tokenAmount,
                rate
            );
            _addToBalance(
                recipient,
                reflectionAmount - reflectionFee,
                tokenAmount - tokenFee
            );
            _deductFromBalance(from, reflectionAmount, tokenAmount);
            _reflectFee(reflectionFee, tokenFee);
        } else {
            // If either are excluded, no fee is charged
            _addToBalance(recipient, reflectionAmount, tokenAmount);
            _deductFromBalance(from, reflectionAmount, tokenAmount);
        }
    }

    function _addToBalance(
        address account,
        uint256 reflectionAmount,
        uint256 tokenAmount
    ) internal {
        if (_isExcluded[account]) {
            _simpleTokenBalances[account] += tokenAmount;
        } else {
            _reflectionPoolBalances[account] += reflectionAmount;
        }
    }

    function _deductFromBalance(
        address account,
        uint256 reflectionAmount,
        uint256 tokenAmount
    ) internal {
        if (_isExcluded[account]) {
            _simpleTokenBalances[account] -= tokenAmount;
        } else {
            _reflectionPoolBalances[account] -= reflectionAmount;
        }
    }

    /** @dev Deduct the fee from the reflection pool, and add to the total fees deducted
    @param reflectionFeeAmount The amount of reflection to deduct from the reflection pool
    @param tokenFeeAmount The amount of tokens to deduct
     */
    function _reflectFee(uint256 reflectionFeeAmount, uint256 tokenFeeAmount)
        private
    {
        _reflectionPoolTotal -= reflectionFeeAmount;
        _totalFeesDeducted += tokenFeeAmount;
        _totalReflectionFeesDeducted += reflectionFeeAmount;
    }

    // Given a token amount, return the token and reflection fee amounts
    function _calculateTransferFees(uint256 tokenAmount, uint256 currentRate)
        private
        view
        returns (uint256 tokenFee, uint256 reflectionFee)
    {
        //uint256 reflectionAmount = reflectionFromToken(tokenAmount, currentRate);
        tokenFee = _calculateTransferFee(tokenAmount);
        reflectionFee = reflectionFromToken(tokenFee, currentRate);
    }

    // Given a token amount, calculate the fee
    function _calculateTransferFee(uint256 tokenAmount)
        private
        view
        returns (uint256)
    {
        //TODO: Prevent overflow
        uint256 tokenFee = (tokenAmount * _taxRate) / 10000; // Calculate fee based on tax rate expessed as tenths of a percent
        return tokenFee;
    }

    // Get the current exchange rate: reflections per token
    function _getRate() private view returns (uint256) {
        return _reflectionPoolTotal / _simpleTokenTotal;
    }

    // New tax rate, expressed as hundredths of a percent
    function _setTaxRate(uint8 newRate) external onlyOwner {
        require(newRate <= 100 * 100 * 100, "Tax rate must be less than 100%");
        _taxRate = newRate;
        emit TaxRateChange(newRate);
    }

    modifier onlyIncludedAccounts() {
        require(!_isExcluded[_msgSender()]);
        _;
    }

    function getReflectionBalance(address account)
        public
        view
        returns (uint256)
    {
        return _reflectionPoolBalances[account];
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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