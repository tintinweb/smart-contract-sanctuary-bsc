// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Token is Context, IERC20, Ownable {
    string private constant _name = "Gather Token";
    string private constant _symbol = "GT";
    uint8 private constant _decimals = 18;

    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 10000000 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    address[] private _excluded;
    address public referralFeeReceiver;
    address public genesisNodeFeeReceiver;
    address public liquidityFeeReceiver;

    uint256 public referralFee = 5; 
    uint256 public genesisNodeFee = 2; 
    uint256 public liquidityFee = 2;  
    uint256 public taxFee = 1; // reflection

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    constructor (address _referralFeeReceiver, address _genesisNodeFeeReceiver, address _liquidityFeeReceiver) {
        _rOwned[_msgSender()] = _rTotal;
        
        // exclude system contracts
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_referralFeeReceiver] = true;
        _isExcludedFromFee[_genesisNodeFeeReceiver] = true;
        _isExcludedFromFee[_liquidityFeeReceiver] = true;

        referralFeeReceiver = _referralFeeReceiver;
        genesisNodeFeeReceiver = _genesisNodeFeeReceiver;
        liquidityFeeReceiver = _liquidityFeeReceiver;
        
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() external pure returns (string memory) {
        return _name;
    }

    function symbol() external pure returns (string memory) {
        return _symbol;
    }

    function decimals() external pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() external pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        bool takeFee = true;
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }
        tokenTransfer(from, to, amount, takeFee);
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");

        uint256 currentRate = getRate();
        return rAmount / currentRate;
    }

    function tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) internal {
        uint256 previousTaxFee = taxFee;
        uint256 previousLiquidityFee = liquidityFee;
        uint256 previousReferralFee = referralFee;
        uint256 previousGenesisNodeFee = genesisNodeFee;
        
        if (!takeFee) {
            taxFee = 0;
            liquidityFee = 0;
            referralFee = 0;
            genesisNodeFee = 0;
        }
        
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            transferToExcluded(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            transferBothExcluded(sender, recipient, amount);
        } else {
            transferStandard(sender, recipient, amount);
        }
        
        if (!takeFee) {
            taxFee = previousTaxFee;
            liquidityFee = previousLiquidityFee;
            referralFee = previousReferralFee;
            genesisNodeFee = previousGenesisNodeFee;
        }
    }

    function transferStandard(address sender, address recipient, uint256 tAmount) internal {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tReferral, uint256 tSuperNode) = getTValues(tAmount);
        uint256 currentRate = getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee,,) = getRValues(tAmount, tFee, tReferral, tSuperNode, tLiquidity, currentRate);

        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;

        takeTransactionFee(liquidityFeeReceiver, tLiquidity, currentRate);
        takeTransactionFee(referralFeeReceiver, tReferral, currentRate);
        takeTransactionFee(genesisNodeFeeReceiver, tSuperNode, currentRate);
        reflectFee(rFee, tFee);

        emit Transfer(sender, recipient, tTransferAmount);
    }

    function transferBothExcluded(address sender, address recipient, uint256 tAmount) internal {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tReferral, uint256 tSuperNode) = getTValues(tAmount);
        uint256 currentRate = getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee,,) = getRValues(tAmount, tFee, tReferral, tSuperNode, tLiquidity, currentRate);

        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;

        reflectFee(rFee, tFee);

        emit Transfer(sender, recipient, tTransferAmount);
    }

    function transferToExcluded(address sender, address recipient, uint256 tAmount) internal {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tReferral, uint256 tSuperNode) = getTValues(tAmount);
        uint256 currentRate = getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee,,) = getRValues(tAmount, tFee, tReferral, tSuperNode, tLiquidity, currentRate);

        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;

        reflectFee(rFee, tFee);

        emit Transfer(sender, recipient, tTransferAmount);
    }

    function transferFromExcluded(address sender, address recipient, uint256 tAmount) internal {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tReferral, uint256 tSuperNode) = getTValues(tAmount);
        uint256 currentRate = getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee,,) = getRValues(tAmount, tFee, tReferral, tSuperNode, tLiquidity, currentRate);

        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        
        reflectFee(rFee, tFee);

        emit Transfer(sender, recipient, tTransferAmount);
    }

    function reflectFee(uint256 rFee, uint256 tFee) internal {
        _rTotal    = _rTotal - rFee;
        _tFeeTotal = _tFeeTotal + tFee;
    }

    function takeTransactionFee(address to, uint256 tAmount, uint256 currentRate) internal {
        if (tAmount <= 0) { return; }

        uint256 rAmount = tAmount * currentRate;
        _rOwned[to] = _rOwned[to] + rAmount;
        if (_isExcluded[to]) {
            _tOwned[to] = _tOwned[to] + tAmount;
        }

        emit Transfer(address(this), to, tAmount);
    }
    
    function calculateFee(uint256 amount, uint256 fee) internal pure returns (uint256) {
        return amount * fee / 100;
    }

    function totalFees() external view returns (uint256) {
        return _tFeeTotal;
    }
    
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function isExcludedFromReward(address account) external view returns (bool) {
        return _isExcluded[account];
    }

    function rescueToken(address tokenAddress, address to) external onlyOwner {
        uint256 contractBalance = IERC20(tokenAddress).balanceOf(address(this));
        IERC20(tokenAddress).transfer(to, contractBalance);
    }

    receive() external payable {}

    // ===================================================================
    // GETTERS
    // ===================================================================

    function getTValues(uint256 tAmount) internal view returns (uint256, uint256, uint256, uint256, uint256) {
        uint256 tFee = calculateFee(tAmount, taxFee);
        uint256 tLiquidity = calculateFee(tAmount, liquidityFee);
        uint256 tReferral = calculateFee(tAmount, referralFee);
        uint256 tSuperNode = calculateFee(tAmount, genesisNodeFee);
        uint256 tTransferAmount = tAmount - (tFee + tLiquidity + tReferral + tSuperNode);
        return (tTransferAmount, tFee, tLiquidity, tReferral, tSuperNode);
    }

    function getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 tReferral, uint256 tSuperNode, uint256 currentRate) 
    internal pure returns (uint256, uint256, uint256, uint256, uint256) {
        uint256 rAmount = tAmount * currentRate;
        uint256 rFee = tFee * currentRate;
        uint256 rLiquidity = tLiquidity * currentRate;
        uint256 rReferral = tReferral * currentRate;
        uint256 rSuperNode = tSuperNode * currentRate;
        uint256 rTransferAmount = rAmount - (rFee + rLiquidity + rReferral + rSuperNode);
        return (rAmount, rTransferAmount, rFee, rReferral, rSuperNode);
    }

    function getRate() internal view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = getCurrentSupply();
        return rSupply / tSupply;
    }

    function getCurrentSupply() internal view returns(uint256, uint256) {
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

    // ===================================================================
    // SETTERS
    // ===================================================================

    function setExcludeFromReward(address account) external onlyOwner {
        require(account != address(0), "Address zero");
        require(!_isExcluded[account], "Account is already excluded");

        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);

        emit SetExcludeFromReward(account);
    }

    function setIncludeInReward(address account) external onlyOwner {
        require(account != address(0), "Address zero");
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

        emit SetIncludeInReward(account);
    }

    function setReferralFeeReceiver(address _newAddress) external onlyOwner {
        require(_newAddress != address(0), "Address zero");
        referralFeeReceiver = _newAddress;

        emit SetReferralFeeReceiver(_newAddress);
    }

    function setGenesisNodeFeeReceiver(address _newAddress) external onlyOwner {
        require(_newAddress != address(0), "Address zero");
        genesisNodeFeeReceiver = _newAddress;

        emit SetGenesisNodeFeeReceiver(_newAddress);
    }

    function setLiquidityFeeReceiver(address _newAddress) external onlyOwner {
        require(_newAddress != address(0), "Address zero");
        liquidityFeeReceiver = _newAddress;

        emit SetLiquidityFeeReceiver(_newAddress);
    }

    function setExcludedFromFee(address addr, bool e) external onlyOwner {
        require(addr != address(0), "Address zero");
        _isExcludedFromFee[addr] = e;

        emit SetExcludedFromFee(addr, e);
    }
    
    function setTaxFeePercent(uint256 newTaxFee) external onlyOwner {
        require(newTaxFee <= 5, "Exceeded 5 percent");
        taxFee = newTaxFee;

        emit SetTaxFeePercent(newTaxFee);
    }

    function setLiquidityFeePercent(uint256 newLiquidityFee) external onlyOwner {
        require(newLiquidityFee <= 5, "Exceeded 5 percent");
        liquidityFee = newLiquidityFee;

        emit SetLiquidityFeePercent(newLiquidityFee);
    }

    function setReferralFeePercent(uint256 newReferralFee) external onlyOwner {
        require(newReferralFee <= 5, "Exceeded 5 percent");
        referralFee = newReferralFee;

        emit SetReferralFeePercent(newReferralFee);
    }

    function setGenesisNodeFeePercent(uint256 newGenesisNodeFee) external onlyOwner {
        require(newGenesisNodeFee <= 5, "Exceeded 5 percent");
        genesisNodeFee = newGenesisNodeFee;

        emit SetGenesisNodeFeePercent(newGenesisNodeFee);
    }

    // ===================================================================
    // EVENTS
    // ===================================================================

    event Deliver(uint256 tAmount);
    event SetExcludeFromReward(address account);
    event SetIncludeInReward(address account);
    event SetReferralFeeReceiver(address newAddress);
    event SetGenesisNodeFeeReceiver(address newAddress);
    event SetLiquidityFeeReceiver(address newAddress);
    event SetExcludedFromFee(address account, bool e);
    event SetTaxFeePercent(uint256 taxFee);
    event SetLiquidityFeePercent(uint256 liquidityFee);
    event SetReferralFeePercent(uint256 referralFee);
    event SetGenesisNodeFeePercent(uint256 genesisNodeFee);
    event SetSwapThreshold(uint256 swapThreshold);
    event SetExcludedFromAutoLiquidity(address a, bool b);
    event RescueToken(address tokenAddress, address to);
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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