// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/ICarboToken.sol";
import "./interfaces/IDividendManager.sol";
import "./RecoverableFunds.sol";
import "./WithCallback.sol";

contract CarboToken is ICarboToken, Ownable, RecoverableFunds, WithCallback {

    using SafeMath for uint256;

    uint16 private constant PERCENT_RATE = 1000;
    uint256 private constant MAX = ~uint256(0);

    // -----------------------------------------------------------------------------------------------------------------
    // ERC20
    // -----------------------------------------------------------------------------------------------------------------

    mapping(address => mapping(address => uint256)) private _allowances;
    string private _name = "TESTCC";
    string private _symbol = "TESTCC";

    function name() override public view returns (string memory) {
        return _name;
    }

    function symbol() override public view returns (string memory) {
        return _symbol;
    }

    function decimals() override public pure returns (uint8) {
        return 18;
    }

    function totalSupply() override external view returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) override external view returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) override external returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) override external view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) override public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) override external returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) override external returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) override external returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function burn(uint256 amount) override external {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) override external  {
        uint256 currentAllowance = _allowances[account][_msgSender()];
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        uint256 rAmount = _getRAmount(amount, _getRate());
        require(_rOwned[account] >= rAmount, "ERC20: burn amount exceeds balance");
        _decreaseBalance(account, amount, rAmount);
        _decreaseTotalSupply(amount, rAmount);
        emit Transfer(account, address(0), amount);
    }

    // -----------------------------------------------------------------------------------------------------------------
    // FEES
    // -----------------------------------------------------------------------------------------------------------------

    mapping(FeeType => Fees) private _fees;
    mapping(FeeType => FeeAddresses) private _feeAddresses;
    address private _dividendsAddress;
    address private _buybackAddress;
    address private _treasuryAddress;
    address private _liquidityAddress;
    mapping(address => bool) private _isTaxable;
    mapping(address => bool) private _isTaxExempt;

    function getFees(FeeType feeType) override external view returns (Fees memory) {
        return _fees[feeType];
    }

    function setFees(FeeType feeType, uint rfi, uint dividends, uint buyback, uint treasury, uint liquidity) override external onlyOwner {
        require(feeType != FeeType.NONE, "CarboToken: Wrong FeeType");
        _fees[feeType] = Fees(rfi, dividends, buyback, treasury, liquidity);
    }

    function getFeeAddresses(FeeType feeType) override public view returns (FeeAddresses memory) {
        return _feeAddresses[feeType];
    }

    function setFeeAddresses(FeeType feeType, address dividends, address buyback, address treasury, address liquidity) override external onlyOwner {
        require(feeType != FeeType.NONE, "CarboToken: Wrong FeeType");
        _feeAddresses[feeType] = FeeAddresses(dividends, buyback, treasury, liquidity);
    }

    function setTaxable(address account, bool value) override external onlyOwner {
        require(_isTaxable[account] != value, "CarboToken: already set");
        _isTaxable[account] = value;
    }

    function setTaxExempt(address account, bool value) override external onlyOwner {
        require(_isTaxExempt[account] != value, "CarboToken: already set");
        _isTaxExempt[account] = value;
    }

    function _getFeeAmounts(uint256 amount, FeeType feeType) internal view returns (Fees memory) {
        Fees memory fees = _fees[feeType];
        Fees memory feeAmounts;
        feeAmounts.rfi = amount.mul(fees.rfi).div(PERCENT_RATE);
        feeAmounts.dividends = amount.mul(fees.dividends).div(PERCENT_RATE);
        feeAmounts.buyback = amount.mul(fees.buyback).div(PERCENT_RATE);
        feeAmounts.treasury = amount.mul(fees.treasury).div(PERCENT_RATE);
        feeAmounts.liquidity = amount.mul(fees.liquidity).div(PERCENT_RATE);
        return feeAmounts;
    }

    function _getFeeType(address sender, address recipient) internal view returns (FeeType) {
        if (_isTaxExempt[sender] || _isTaxExempt[recipient]) return FeeType.NONE;
        if (_isTaxable[sender]) return FeeType.BUY;
        if (_isTaxable[recipient]) return FeeType.SELL;
        return FeeType.NONE;
    }

    // -----------------------------------------------------------------------------------------------------------------
    // RFI
    // -----------------------------------------------------------------------------------------------------------------

    uint256 private _tTotal = 500_000_000 ether;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => bool) private _isExcluded;
    address[] private _excluded;

    constructor() {
        _rOwned[_msgSender()] = _rTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function getROwned(address account) override external view returns (uint256) {
        return _rOwned[account];
    }

    function getRTotal() override external view returns (uint256) {
        return _rTotal;
    }

    function excludeFromRFI(address account) override external onlyOwner {
        require(!_isExcluded[account], "CarboToken: account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInRFI(address account) override external onlyOwner {
        require(_isExcluded[account], "CarboToken: account is already included");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function reflect(uint256 tAmount) override external {
        address account = _msgSender();
        require(!_isExcluded[account], "CarboToken: excluded addresses cannot call this function");
        uint256 rAmount = _getRAmount(tAmount, _getRate());
        _decreaseBalance(account, tAmount, rAmount);
        _reflect(tAmount, rAmount);
    }

    function reflectionFromToken(uint256 tAmount) override external view returns (uint256) {
        require(tAmount <= _tTotal, "CarboToken: amount must be less than supply");
        return _getRAmount(tAmount, _getRate());
    }

    function tokenFromReflection(uint256 rAmount) override public view returns (uint256) {
        require(rAmount <= _rTotal, "CarboToken: amount must be less than total reflections");
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function _reflect(uint256 tAmount, uint256 rAmount) internal {
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
        _reflectCallback(tAmount, rAmount);
    }

    function _getCurrentSupply() internal view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _getRate() internal view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getRAmount(uint256 tAmount, uint256 currentRate) internal pure returns (uint256) {
        return tAmount.mul(currentRate);
    }

    function _getRAmounts(Amounts memory t, FeeType feeType, uint256 currentRate) internal pure returns (Amounts memory) {
        Amounts memory r;
        r.sum = _getRAmount(t.sum, currentRate);
        r.transfer = r.sum;
        if (feeType != FeeType.NONE) {
            r.rfi = _getRAmount(t.rfi, currentRate);
            r.dividends = _getRAmount(t.dividends, currentRate);
            r.buyback = _getRAmount(t.buyback, currentRate);
            r.treasury = _getRAmount(t.treasury, currentRate);
            r.liquidity = _getRAmount(t.liquidity, currentRate);
            r.transfer = r.transfer.sub(r.rfi).sub(r.dividends).sub(r.buyback).sub(r.treasury).sub(r.liquidity);
        }
        return r;
    }

    function _getTAmounts(uint256 tAmount, FeeType feeType) internal view returns (Amounts memory) {
        Amounts memory t;
        t.sum = tAmount;
        t.transfer = t.sum;
        if (feeType != FeeType.NONE) {
            Fees memory fees = _getFeeAmounts(tAmount, feeType);
            t.rfi = fees.rfi;
            t.dividends = fees.dividends;
            t.buyback = fees.buyback;
            t.treasury = fees.treasury;
            t.liquidity = fees.liquidity;
            t.transfer = t.transfer.sub(t.rfi).sub(t.dividends).sub(t.buyback).sub(t.treasury).sub(t.liquidity);
        }
        return t;
    }

    function _getAmounts(uint256 tAmount, FeeType feeType) internal view returns (Amounts memory r, Amounts memory t) {
        t = _getTAmounts(tAmount, feeType);
        r = _getRAmounts(t, feeType, _getRate());
    }

    function _increaseBalance(address account, uint256 tAmount, uint256 rAmount) internal {
        _rOwned[account] = _rOwned[account].add(rAmount);
        if (_isExcluded[account]) {
            _tOwned[account] = _tOwned[account].add(tAmount);
        }
        _increaseBalanceCallback(account, tAmount, rAmount);
    }

    function _decreaseBalance(address account, uint256 tAmount, uint256 rAmount) internal {
        _rOwned[account] = _rOwned[account].sub(rAmount);
        if (_isExcluded[account]) {
            _tOwned[account] = _tOwned[account].sub(tAmount);
        }
        _decreaseBalanceCallback(account, tAmount, rAmount);
    }

    function _decreaseTotalSupply(uint256 tAmount, uint256 rAmount) private {
        _tTotal = _tTotal.sub(tAmount);
        _rTotal = _rTotal.sub(rAmount);
        _decreaseTotalSupplyCallback(tAmount, rAmount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        FeeType feeType = _getFeeType(sender, recipient);
        (Amounts memory r, Amounts memory t) = _getAmounts(amount, feeType);
        require(_rOwned[sender] >= r.sum, "ERC20: transfer amount exceeds balance");
        _decreaseBalance(sender, t.sum, r.sum);
        _increaseBalance(recipient, t.transfer, r.transfer);
        emit Transfer(sender, recipient, t.transfer);
        if (t.sum != t.transfer) {
            FeeAddresses memory feeAddresses = getFeeAddresses(feeType);
            if (t.rfi > 0) {
                _reflect(t.rfi, r.rfi);
            }
            if (t.dividends > 0) {
                _increaseBalance(feeAddresses.dividends, t.dividends, r.dividends);
            }
            if (t.buyback > 0) {
                _increaseBalance(feeAddresses.buyback, t.buyback, r.buyback);
            }
            if (t.treasury > 0) {
                _increaseBalance(feeAddresses.treasury, t.treasury, r.treasury);
            }
            if (t.liquidity > 0) {
                _increaseBalance(feeAddresses.liquidity, t.liquidity, r.liquidity);
            }
            emit FeeTaken(t.rfi, t.dividends, t.buyback, t.treasury, t.liquidity);
        }
        _transferCallback(sender, recipient, t.sum, t.transfer, r.sum, r.transfer);
    }

}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

/**
 * @dev Interface of DividendManager
 */
interface IDividendManager {

    function distributeDividends(uint256 amount) external;

}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @dev Interface of CarboToken
 */
interface ICarboToken is IERC20 {

    struct Amounts {
        uint256 sum;
        uint256 transfer;
        uint256 rfi;
        uint256 dividends;
        uint256 buyback;
        uint256 treasury;
        uint256 liquidity;
    }

    struct Fees {
        uint256 rfi;
        uint256 dividends;
        uint256 buyback;
        uint256 treasury;
        uint256 liquidity;
    }

    struct FeeAddresses {
        address dividends;
        address buyback;
        address treasury;
        address liquidity;
    }

    enum FeeType { BUY, SELL, NONE}

    event FeeTaken(uint256 rfi, uint256 dividends, uint256 buyback, uint256 treasury, uint256 liquidity);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external pure returns (uint8);
    function burn(uint256 amount) external;
    function burnFrom(address account, uint256 amount) external;
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
    function getFees(FeeType feeType) external view returns (Fees memory);
    function setFees(FeeType feeType, uint rfi, uint dividends, uint buyback, uint treasury, uint liquidity) external;
    function getFeeAddresses(FeeType feeType) external view returns (FeeAddresses memory);
    function setFeeAddresses(FeeType feeType, address dividends, address buyback, address treasury, address liquidity) external;
    function setTaxable(address account, bool value) external;
    function setTaxExempt(address account, bool value) external;
    function getROwned(address account) external view returns (uint256);
    function getRTotal() external view returns (uint256);
    function excludeFromRFI(address account) external;
    function includeInRFI(address account) external;
    function reflect(uint256 tAmount) external;
    function reflectionFromToken(uint256 tAmount) external view returns (uint256);
    function tokenFromReflection(uint256 rAmount) external view returns (uint256);

}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

/**
 * @dev Interface of contract that can be invoked by a token contract during reflect or transfer.
 */
interface ICallbackContract {

    function reflectCallback(uint256 tAmount, uint256 rAmount) external;
    function increaseBalanceCallback(address account, uint256 tAmount, uint256 rAmount) external;
    function decreaseBalanceCallback(address account, uint256 tAmount, uint256 rAmount) external;
    function decreaseTotalSupplyCallback(uint256 tAmount, uint256 rAmount) external;
    function transferCallback(address from, address to, uint256 tFromAmount, uint256 rFromAmount, uint256 tToAmount, uint256 rToAmount) external;

}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/ICallbackContract.sol";

/**
 * @dev Allows the owner to register a callback contract that will be called after every call of the transfer or burn function
 */
contract WithCallback is Ownable {

    address public callback = address(0x0);

    function setCallback(address _callback) external onlyOwner {
        callback = _callback;
    }

    function _reflectCallback(uint256 tAmount, uint256 rAmount) internal {
        if (callback != address(0x0)) {
            ICallbackContract(callback).reflectCallback(tAmount, rAmount);
        }
    }

    function _increaseBalanceCallback(address account, uint256 tAmount, uint256 rAmount) internal {
        if (callback != address(0x0)) {
            ICallbackContract(callback).increaseBalanceCallback(account, tAmount, rAmount);
        }
    }

    function _decreaseBalanceCallback(address account, uint256 tAmount, uint256 rAmount) internal {
        if (callback != address(0x0)) {
            ICallbackContract(callback).decreaseBalanceCallback(account, tAmount, rAmount);
        }
    }

    function _decreaseTotalSupplyCallback(uint256 tAmount, uint256 rAmount) internal {
        if (callback != address(0x0)) {
            ICallbackContract(callback).decreaseTotalSupplyCallback(tAmount, rAmount);
        }
    }

    function _transferCallback(address from, address to, uint256 tFromAmount, uint256 rFromAmount, uint256 tToAmount, uint256 rToAmount) internal {
        if (callback != address(0x0)) {
            ICallbackContract(callback).transferCallback(from, to, tFromAmount, rFromAmount, tToAmount, rToAmount);
        }
    }

}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @dev Allows the owner to retrieve ETH or tokens sent to this contract by mistake.
 */
contract RecoverableFunds is Ownable {

    function retrieveTokens(address recipient, address tokenAddress) public virtual onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        token.transfer(recipient, token.balanceOf(address(this)));
    }

    function retriveETH(address payable recipient) public virtual onlyOwner {
        recipient.transfer(address(this).balance);
    }

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