/**
 *Submitted for verification at BscScan.com on 2022-11-06
*/

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: BabyMinaDoge.sol

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;



interface ISwapper {
    function buy(address recipient) external payable;
    function sell(address recipient) external;
}

contract BMD is IERC20, Ownable {

    // total supply
    uint256 private _totalSupply;

    // token data
    string private constant _name = "BabyMinaDoge";
    string private constant _symbol = "BMD";
    uint8  private constant _decimals = 18;

    // balances
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    // Taxation on transfers
    uint256 public buyFee             = 300;
    uint256 public sellFee            = 300;
    uint256 public transferFee        = 500;
    uint256 public constant TAX_DENOM = 10000;

    // Max Transaction Limit
    uint256 public max_sell_transaction_limit;
    uint256 public MAX_WALLET;

    // permissions
    struct Permissions {
        bool isFeeExempt;
        bool isLiquidityPool;
        bool isBlacklisted;
        bool isMaxWalletExempt;
        bool isMaxSellExempt;
        bool isTradePausedExempt;
    }
    mapping ( address => Permissions ) public permissions;

    // Fee Recipients
    address public sellFeeRecipient;
    address public buyFeeRecipient;
    address public transferFeeRecipient;

    // Trading Paused
    bool public tradingPaused;

    // events
    event TradingPaused();
    event TradingResumed();
    event SetBuyFeeRecipient(address recipient);
    event SetSellFeeRecipient(address recipient);
    event SetTransferFeeRecipient(address recipient);
    event SetBlacklist(address addr, bool isBlacklisted);
    event SetFeeExemption(address account, bool isFeeExempt);
    event SetAutomatedMarketMaker(address account, bool isMarketMaker);
    event SetFees(uint256 buyFee, uint256 sellFee, uint256 transferFee);

    constructor() {

        // set initial starting supply
        _totalSupply = 10**7 * 10**_decimals;

        // set max wallet size
        MAX_WALLET = _totalSupply;

        // max transaction
        max_sell_transaction_limit = _totalSupply / 100;

        // exempt sender for tax-free initial distribution
        permissions[msg.sender].isFeeExempt = true;
        permissions[msg.sender].isMaxWalletExempt = true;
        permissions[msg.sender].isMaxSellExempt = true;
        permissions[msg.sender].isTradePausedExempt = true;

        // initial supply allocation
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    
    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /** Transfer Function */
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        if (recipient == msg.sender) {
            return _sell(msg.sender, amount);
        } else {
            return _transferFrom(msg.sender, recipient, amount);
        }
    }

    /** Transfer Function */
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        require(
            _allowances[sender][msg.sender] >= amount,
            'Insufficient Allowance'
        );
        _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        return _transferFrom(sender, recipient, amount);
    }

    function sell(uint256 amount) external returns (bool) {
        return _sell(msg.sender, amount);
    }

    function burn(uint256 amount) external returns (bool) {
        return _burn(msg.sender, amount);
    }

    function burnFrom(address account, uint256 amount) external returns (bool) {
        require(
            _allowances[account][msg.sender] >= amount,
            'Insufficient Allowance'
        );
        _allowances[account][msg.sender] = _allowances[account][msg.sender] - amount;
        return _burn(account, amount);
    }
    
    /** Internal Transfer */
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(
            recipient != address(0),
            'Zero Recipient'
        );
        require(
            recipient != address(this),
            'Cannot Send To MBD Itself'
        );
        require(
            amount > 0,
            'Zero Amount'
        );
        require(
            amount <= _balances[sender],
            'Insufficient Balance'
        );
        require(
            !permissions[sender].isBlacklisted &&
            !permissions[recipient].isBlacklisted,
            'Blacklisted Address'
        );
        if (!permissions[sender].isTradePausedExempt) {
            require(
                !tradingPaused,
                'Trading Is Paused'
            );
        }
        
        // decrement sender balance
        _balances[sender] = _balances[sender] - amount;
        // fee for transaction
        (uint256 fee, address feeDestination) = getTax(sender, recipient, amount);

        // allocate fee
        if (fee > 0) {
            address feeRecipient = feeDestination == address(0) ? address(this) : feeDestination;
            if (feeRecipient == sellFeeRecipient && !permissions[sender].isMaxSellExempt) {
                require(
                    amount <= max_sell_transaction_limit,
                    'Amount Exceeds Max Transaction Limit'
                );
            }
            _balances[feeRecipient] += fee;
            emit Transfer(sender, feeRecipient, fee);
        }

        // give amount to recipient
        uint256 sendAmount = amount - fee;
        _balances[recipient] = _balances[recipient] + sendAmount;

        // ensure max wallet is protected
        if (!permissions[recipient].isMaxWalletExempt) {
            require(
                _balances[recipient] <= MAX_WALLET,
                'Balance Exceeds Max Wallet Size'
            );
        }

        // emit transfer
        emit Transfer(sender, recipient, sendAmount);
        return true;
    }

    function setMaxSellTransactionLimit(uint256 maxSellTransactionLimit) external onlyOwner {
        require(
            maxSellTransactionLimit >= _totalSupply / 1000,
            'Max Sell Tx Limit Too Low'
        );
        max_sell_transaction_limit = maxSellTransactionLimit;
    }

    function withdraw(address token) external onlyOwner {
        require(token != address(0), 'Zero Address');
        bool s = IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
        require(s, 'Failure On Token Withdraw');
    }

    function withdrawBNB() external onlyOwner {
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s);
    }

    function setTransferFeeRecipient(address recipient) external onlyOwner {
        require(recipient != address(0), 'Zero Address');
        transferFeeRecipient = recipient;
        permissions[recipient].isFeeExempt = true;
        permissions[recipient].isMaxWalletExempt = true;
        permissions[recipient].isMaxSellExempt = true;
        emit SetTransferFeeRecipient(recipient);
    }

    function setBuyFeeRecipient(address recipient) external onlyOwner {
        require(recipient != address(0), 'Zero Address');
        buyFeeRecipient = recipient;
        permissions[recipient].isFeeExempt = true;
        permissions[recipient].isMaxWalletExempt = true;
        permissions[recipient].isMaxSellExempt = true;
        emit SetBuyFeeRecipient(recipient);
    }

    function setSellFeeRecipient(address recipient) external onlyOwner {
        require(recipient != address(0), 'Zero Address');
        sellFeeRecipient = recipient;
        permissions[recipient].isFeeExempt = true;
        permissions[recipient].isMaxWalletExempt = true;
        permissions[recipient].isMaxSellExempt = true;
        emit SetSellFeeRecipient(recipient);
    }

    function registerAutomatedMarketMaker(address account) external onlyOwner {
        require(account != address(0), 'Zero Address');
        require(!permissions[account].isLiquidityPool, 'Already An AMM');
        permissions[account].isLiquidityPool = true;
        permissions[account].isMaxWalletExempt = true;
        permissions[account].isMaxSellExempt = true;
        emit SetAutomatedMarketMaker(account, true);
    }

    function unRegisterAutomatedMarketMaker(address account) external onlyOwner {
        require(account != address(0), 'Zero Address');
        require(permissions[account].isLiquidityPool, 'Not An AMM');
        permissions[account].isLiquidityPool = false;
        emit SetAutomatedMarketMaker(account, false);
    }

    function setBlacklist(address addr, bool isBlacklisted) external onlyOwner {
        require(addr != address(0), 'Zero Address');
        permissions[addr].isBlacklisted = isBlacklisted;
        emit SetBlacklist(addr, isBlacklisted);
    }

    function pauseTrading() external onlyOwner {
        tradingPaused = true;
        emit TradingPaused();
    }

    function resumeTrading() external onlyOwner {
        tradingPaused = false;
        emit TradingResumed();
    }

    function setFees(uint _buyFee, uint _sellFee, uint _transferFee) external onlyOwner {
        require(
            _buyFee <= 2500,
            'Buy Fee Too High'
        );
        require(
            _sellFee <= 2500,
            'Sell Fee Too High'
        );
        require(
            _transferFee <= 2500,
            'Transfer Fee Too High'
        );

        buyFee = _buyFee;
        sellFee = _sellFee;
        transferFee = _transferFee;

        emit SetFees(_buyFee, _sellFee, _transferFee);
    }

    function setFeeExempt(address account, bool isExempt) external onlyOwner {
        require(account != address(0), 'Zero Address');
        permissions[account].isFeeExempt = isExempt;
        emit SetFeeExemption(account, isExempt);
    }

    function setMaxSellExempt(address account, bool isExempt) external onlyOwner {
        require(account != address(0), 'Zero Address');
        permissions[account].isMaxSellExempt = isExempt;
    }

    function setMaxWalletExempt(address account, bool isExempt) external onlyOwner {
        require(account != address(0), 'Zero Address');
        permissions[account].isMaxWalletExempt = isExempt;
    }
    
    function setMaxWalletSize(uint256 newMaxWallet) external onlyOwner {
        require(
            newMaxWallet >= _totalSupply / 1000,
            'Max Wallet Too Small'
        );
        MAX_WALLET = newMaxWallet;
    }

    function setTradePausedExempt(address user, bool isExempt) external onlyOwner {
        permissions[user].isTradePausedExempt = isExempt;
    }

    function getTax(address sender, address recipient, uint256 amount) public view returns (uint256, address) {
        if ( permissions[sender].isFeeExempt || permissions[recipient].isFeeExempt ) {
            return (0, address(0));
        }
        return permissions[sender].isLiquidityPool ? 
               ((amount * buyFee) / TAX_DENOM, buyFeeRecipient) : 
               permissions[recipient].isLiquidityPool ? 
               ((amount * sellFee) / TAX_DENOM, sellFeeRecipient) :
               ((amount * transferFee) / TAX_DENOM, transferFeeRecipient);
    }

    function _burn(address account, uint256 amount) internal returns (bool) {
        require(
            account != address(0),
            'Zero Address'
        );
        require(
            amount > 0,
            'Zero Amount'
        );
        require(
            amount <= balanceOf(account),
            'Insufficient Balance'
        );
        _balances[account] = _balances[account] - amount;
        _totalSupply = _totalSupply - amount;
        emit Transfer(account, address(0), amount);
        return true;
    }

    function _sell(address recipient, uint256 amount) internal returns (bool) {
        require(
            !permissions[recipient].isBlacklisted,
            'Blacklisted User'
        );
        require(
            amount > 0,
            'Zero Amount'
        );
        require(
            amount <= _balances[recipient],
            'Insufficient Balance'
        );

    }

}