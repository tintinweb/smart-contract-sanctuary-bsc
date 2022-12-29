// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract PattieSwap is Context, IERC20, Ownable {

    event tokenDelivered(uint256 tAmount);
    event userExcludedFromReward(address account);
    event userIncludedInReward(address account);
    event userAddedWhitelist(address account);
    event userRemovedWhitelist(address account);
    event userAddedBlacklist(address account);
    event userRemovedBlacklist(address account);
    event maxTransactionAmountSet(uint256 maxTxAmount);
    event burnFeePercentageSet(uint256 burnFee);
    event distributionFeePercentage(uint256 distributionFee);
    event amountBurned(uint256 tAmount);


    using SafeMath for uint256;

    mapping (address => uint256) private _rOwned;   // reflection owned
    mapping (address => uint256) private _tOwned;   // token owned 
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) public whiteListed;   // No fee for this users
    mapping (address => bool) public blackListed;   // Not able to send token

    mapping (address => bool) public _isExcluded;   // excluded from reflection reward
    address[] private _excluded;
   
    uint256 private constant MAX = ~uint256(0);
    // uint256 private _tTotal = 1000000000000000 * 10**18;
    uint256 private _tTotal = 10000;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));     
    uint256 private _tFeeTotal;

    string private _name = "PattieSwap";
    string private _symbol = "PATTIE";
    uint8 private _decimals = 18;
    
    uint256 public burnFee = 1;
    uint256 private _previousBurnFee = burnFee;
    
    uint256 public distributionFee = 4;
    uint256 private _previousDistributionFee = distributionFee;
    
    // uint256 public maxTxAmount = 100000 * 10**18;
    uint256 public maxTxAmount = 1000;

    struct rValues {
        uint256 rAmount; 
        uint256 rTransferAmount;
        uint256 rDistribution;
        uint256 rBurn;
    }

    struct tValues {
        uint256 tTransferAmount;
        uint256 tDistribution;
        uint256 tBurn;
    }

    constructor() {

        _rOwned[_msgSender()] = _rTotal;
        
        //exclude owner and this contract from fee
        whiteListed[owner()] = true;
        whiteListed[address(this)] = true;
        
    }

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
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function deliver(uint256 tAmount) external {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (rValues memory _rFee,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(_rFee.rAmount);
        _rTotal = _rTotal.sub(_rFee.rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
        emit tokenDelivered(tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
             (rValues memory _rFee,) = _getValues(tAmount);
            return _rFee.rAmount;
        } else {
            (rValues memory _rFee,) = _getValues(tAmount);
            return _rFee.rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
        emit userExcludedFromReward(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is not excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
        emit userIncludedInReward(account);
    }
    
    function addWhitelist(address account) public onlyOwner {
        require(!whiteListed[account], "already whitelisted");
        whiteListed[account] = true;
        emit userAddedWhitelist(account);
    }
    
    function removeWhitelist(address account) public onlyOwner {
        require(whiteListed[account], "user not whitelisted");
        whiteListed[account] = false;
        emit userRemovedWhitelist(account);
    }

    function addBlacklist(address account) public onlyOwner {
        require(!blackListed[account], "already blacklisted");
        blackListed[account] = true;
        emit userAddedBlacklist(account);
    }
    
    function removeBlacklist(address account) public onlyOwner {
        require(blackListed[account], "user not blacklisted");
        blackListed[account] = false;
        emit userRemovedBlacklist(account);
    }
    
    function setMaxTxAmount(uint256 _maxTxAmount) external onlyOwner() {
        maxTxAmount = _maxTxAmount;
        emit maxTransactionAmountSet(maxTxAmount);
    }

    function setBurnFeePercent(uint256 _burnFee) external onlyOwner() {
        _previousBurnFee = burnFee;
        burnFee = _burnFee;
        emit burnFeePercentageSet(burnFee);
    }

    function setDistributionFeePercent(uint256 _distributionFee) external onlyOwner() {
        _previousDistributionFee = distributionFee;
        distributionFee = _distributionFee;
        emit distributionFeePercentage(distributionFee);
    }
    
    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _burn(uint256 _rBurn, uint256 _tBurn) private {
        _rTotal = _rTotal.sub(_rBurn);
        _tTotal = _tTotal.sub(_tBurn);
    }

    function _getValues(uint256 tAmount) private view returns (rValues memory , tValues memory) {
        tValues memory _tFee = _getTValues(tAmount);
        rValues memory _rFee = _getRValues(tAmount, _tFee, _getRate());
        return (_rFee, _tFee);
    }

    function _getTValues(uint256 tAmount) private view returns (tValues memory) {
        uint256 _tDistribution = calculateFee(tAmount, distributionFee);
        uint256 _tBurn = calculateFee(tAmount, burnFee);
        uint256 _tTransferAmount = tAmount.sub(_tBurn).sub(_tDistribution);
        return tValues(_tTransferAmount, _tDistribution, _tBurn);
    }

    function _getRValues( uint256 tAmount, tValues memory _tFee, uint256 currentRate) private pure returns (rValues memory) {
        uint256 _rAmount = tAmount.mul(currentRate);
        uint256 _rDistribution = _tFee.tDistribution.mul(currentRate);
        uint256 _rBurn = _tFee.tBurn.mul(currentRate);
        uint256 _rTransferAmount = _rAmount.sub(_rBurn).sub(_rDistribution);
        return rValues(_rAmount, _rTransferAmount, _rDistribution, _rBurn);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
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

    function calculateFee(uint256 _amount, uint256 _fee) private pure returns (uint256) {
        return _amount.mul(_fee).div(10**2);
    }
    
    function removeAllFee() private {
        if(burnFee == 0 && distributionFee == 0) return;
        
        _previousBurnFee = burnFee;
        _previousDistributionFee = distributionFee;
        
        burnFee = 0;
        distributionFee = 0;

    }
    
    function restoreAllFee() private {
        burnFee = _previousBurnFee;
        distributionFee = _previousDistributionFee;
    }
    
    function isWhiteListed(address account) public view returns(bool) {
        return whiteListed[account];
    }

    function isBlackListed(address account) public view returns(bool) {
        return blackListed[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer( address from, address to, uint256 amount ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!blackListed[from], "Sender is blacklisted");

        if(from != owner() && to != owner())
            require(amount <= maxTxAmount, "Transfer amount exceeds the maxTxAmount");
        
        //indicates if fee should be deducted from transfer
        bool takeFee = true;
        bool takeBurnFee = true;
        
        //if any account belongs to whiteListed account then remove the fee
        if(whiteListed[from] || whiteListed[to]){
            takeFee = false;
            takeBurnFee = false;
        }
        
        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from,to,amount,takeFee,takeBurnFee);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee, bool takeBurnFee) private {
        if(!takeFee && !takeBurnFee)
            removeAllFee();
        
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
        
        if(!takeFee && !takeBurnFee)
            restoreAllFee();
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (rValues memory _rFee, tValues memory _tFee) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(_rFee.rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(_rFee.rTransferAmount);
        _reflectFee(_rFee.rDistribution, _tFee.tDistribution);
        _burn(_rFee.rBurn, _tFee.tBurn);      
        emit Transfer(sender, recipient, _tFee.tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (rValues memory _rFee, tValues memory _tFee) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(_rFee.rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(_tFee.tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(_rFee.rTransferAmount);           
        _reflectFee(_rFee.rDistribution, _tFee.tDistribution);
        _burn(_rFee.rBurn, _tFee.tBurn); 
        emit Transfer(sender, recipient, _tFee.tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (rValues memory _rFee, tValues memory _tFee) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(_rFee.rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(_rFee.rTransferAmount);   
        _reflectFee(_rFee.rDistribution, _tFee.tDistribution);
        _burn(_rFee.rBurn, _tFee.tBurn); 
        emit Transfer(sender, recipient, _tFee.tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (rValues memory _rFee, tValues memory _tFee) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(_rFee.rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(_tFee.tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(_rFee.rTransferAmount);        
        _reflectFee(_rFee.rDistribution, _tFee.tDistribution);
        _burn(_rFee.rBurn, _tFee.tBurn);
        emit Transfer(sender, recipient, _tFee.tTransferAmount);
    }

    function burn(uint256 tAmount) public onlyOwner returns(bool) {
        uint256 currentRate =  _getRate();
        uint256 rBurn = tAmount.mul(currentRate);
         _rOwned[msg.sender] = _rOwned[msg.sender].sub(rBurn);
        if(_isExcluded[msg.sender])
            _tOwned[msg.sender] = _tOwned[msg.sender].sub(tAmount);

        _tTotal = _tTotal.sub(tAmount);
        _rTotal = _rTotal.sub(rBurn);
        emit amountBurned(tAmount);
        return true;
    } 

}