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

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PattieSwap is Context, IERC20, Ownable {

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


    mapping (address => uint256) private _rOwned;  
    mapping (address => uint256) private _tOwned;   
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) public isWhitelisted;   
    mapping (address => bool) public isBlacklisted;   

    mapping (address => bool) public isExcluded;  
    address[] private _excluded;
   
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1_000_000_000_000_000 * 10 ** 18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));     
    uint256 private _tFeeTotal;

    string private _name = "PattieSwap";
    string private _symbol = "PATTIE";
    
    uint256 public burnFee = 1;
    uint256 private _previousBurnFee = burnFee;
    
    uint256 public distributionFee = 4;
    uint256 private _previousDistributionFee = distributionFee;
    
    uint256 public maxTxAmount = 100_000 * 10 ** 18;

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

    constructor(address account) {

        _rOwned[account] = _rTotal;
        
        //exclude owner and this contract from fee
        isWhitelisted[owner()] = true;
        isWhitelisted[address(this)] = true;
        
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
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
        return rAmount/currentRate;
    }

    function excludeFromReward(address account) external onlyOwner() {
        require(!isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        isExcluded[account] = true;
        _excluded.push(account);
        emit userExcludedFromReward(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(isExcluded[account], "Account is not excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
        emit userIncludedInReward(account);
    }
    
    function addWhitelist(address account) external onlyOwner {
        require(!isWhitelisted[account], "already Whitelisted");
        isWhitelisted[account] = true;
        emit userAddedWhitelist(account);
    }
    
    function removeWhitelist(address account) external onlyOwner {
        require(isWhitelisted[account], "user not Whitelisted");
        isWhitelisted[account] = false;
        emit userRemovedWhitelist(account);
    }

    function addBlacklist(address account) external onlyOwner {
        require(!isBlacklisted[account], "already Blacklisted");
        isBlacklisted[account] = true;
        emit userAddedBlacklist(account);
    }
    
    function removeBlacklist(address account) external onlyOwner {
        require(isBlacklisted[account], "user not Blacklisted");
        isBlacklisted[account] = false;
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

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal - rFee;
        _tFeeTotal = _tFeeTotal + tFee;
    }

    function _burn(uint256 _rBurn, uint256 _tBurn) private {
        _rTotal = _rTotal - _rBurn;
        _tTotal = _tTotal - _tBurn;
    }

    function _getValues(uint256 tAmount) private view returns (rValues memory , tValues memory) {
        tValues memory _tFee = _getTValues(tAmount);
        rValues memory _rFee = _getRValues(tAmount, _tFee, _getRate());
        return (_rFee, _tFee);
    }

    function _getTValues(uint256 tAmount) private view returns (tValues memory) {
        uint256 _tDistribution = calculateFee(tAmount, distributionFee);
        uint256 _tBurn = calculateFee(tAmount, burnFee);
        uint256 _tTransferAmount = (tAmount - _tBurn) - _tDistribution;
        return tValues(_tTransferAmount, _tDistribution, _tBurn);
    }

    function _getRValues( uint256 tAmount, tValues memory _tFee, uint256 currentRate) private pure returns (rValues memory) {
        uint256 _rAmount = tAmount * currentRate;
        uint256 _rDistribution = _tFee.tDistribution * currentRate;
        uint256 _rBurn = _tFee.tBurn * currentRate;
        uint256 _rTransferAmount = _rAmount - _rBurn - _rDistribution;
        return rValues(_rAmount, _rTransferAmount, _rDistribution, _rBurn);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply - _rOwned[_excluded[i]];
            tSupply = tSupply - _tOwned[_excluded[i]];
        }
        if (rSupply < _rTotal / _tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function calculateFee(uint256 _amount, uint256 _fee) private pure returns (uint256) {
        return (_amount * _fee) / (10**2);
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

    function _approve(address owner, address spender, uint256 amount) private returns(bool){
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
        return true;
    }

    function _transfer( address from, address to, uint256 amount ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!isBlacklisted[from], "Sender is Blacklisted");

        if(from != owner())
            require(amount <= maxTxAmount, "Transfer amount exceeds the maxTxAmount");
        
        //indicates if fee should be deducted from transfer
        bool takeFee = true;
        
        //if any account belongs to isWhitelisted account then remove the fee
        if(isWhitelisted[from]){
            takeFee = false;
        }
        
        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from,to,amount,takeFee);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
        if(!takeFee)
            removeAllFee();
        
        if (isExcluded[sender] && !isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!isExcluded[sender] && isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!isExcluded[sender] && !isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (isExcluded[sender] && isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
        
        if(!takeFee)
            restoreAllFee();
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (rValues memory _rFee, tValues memory _tFee) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - _rFee.rAmount;
        _rOwned[recipient] = _rOwned[recipient] + _rFee.rTransferAmount;
        _reflectFee(_rFee.rDistribution, _tFee.tDistribution);
        _burn(_rFee.rBurn, _tFee.tBurn);      
        emit Transfer(sender, recipient, _tFee.tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (rValues memory _rFee, tValues memory _tFee) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - _rFee.rAmount;
        _tOwned[recipient] = _tOwned[recipient] + _tFee.tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + _rFee.rTransferAmount;           
        _reflectFee(_rFee.rDistribution, _tFee.tDistribution);
        _burn(_rFee.rBurn, _tFee.tBurn); 
        emit Transfer(sender, recipient, _tFee.tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (rValues memory _rFee, tValues memory _tFee) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - _rFee.rAmount;
        _rOwned[recipient] = _rOwned[recipient] + _rFee.rTransferAmount;   
        _reflectFee(_rFee.rDistribution, _tFee.tDistribution);
        _burn(_rFee.rBurn, _tFee.tBurn); 
        emit Transfer(sender, recipient, _tFee.tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (rValues memory _rFee, tValues memory _tFee) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - _rFee.rAmount;
        _tOwned[recipient] = _tOwned[recipient] + _tFee.tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + _rFee.rTransferAmount;        
        _reflectFee(_rFee.rDistribution, _tFee.tDistribution);
        _burn(_rFee.rBurn, _tFee.tBurn);
        emit Transfer(sender, recipient, _tFee.tTransferAmount);
    }

    function burn(uint256 tAmount) public onlyOwner returns(bool) {
        uint256 currentRate =  _getRate();
        uint256 rBurn = tAmount * currentRate;
         _rOwned[msg.sender] = _rOwned[msg.sender] - rBurn;
        if(isExcluded[msg.sender])
            _tOwned[msg.sender] = _tOwned[msg.sender] - tAmount;

        _tTotal = _tTotal - tAmount;
        _rTotal = _rTotal - rBurn;
        emit amountBurned(tAmount);
        return true;
    }

    function transferOwnership(address newOwner) public override onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        isWhitelisted[owner()] = false;
        _transferOwnership(newOwner);
        isWhitelisted[owner()] = true;
    }

}