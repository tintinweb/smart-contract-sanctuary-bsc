/**
 *Submitted for verification at BscScan.com on 2023-01-28
*/

// SPDX-License-Identifier: NONE

/*
 * Elysian Code
 *
 * Elysian Code (cryptonym 'endjourney') is a simple yet one of a kind smart contract conceived by mathematician [α]³ and developed by solidity-coder NS.
 *
 * All rights reserved.
 *
 * https://www.endjourney.org
 *
 * https://twitter.com/openendjourney (open to everyone) - an initiative in semi-decentralized account operation.
 *
 * https://t.me/elysiancode (open to no one) - a journey of thought and experiment in expanding endjourney.
 *
 * Contact: [email protected]
 *
 * Part of the base code architecture was inspired by the EIP-20: Token Standard and OpenZeppelin.
 */

pragma solidity 0.8.17;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed keeper, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address keeper, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 */
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}






interface IDexFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IDexRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}




/**
 * @dev Provides information about the current execution context, including the sender of the transaction and its data.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

/**
 * @dev The contract created by [α]³ and NS starts here.
 */
contract endjourney is Context, IERC20, IERC20Metadata {
    IDexRouter public dexRouter;
    address public liquidityPoolPair;

    mapping(address => bool) private _untaxed;
    mapping(address => bool) private _unlocked;
    mapping(address => bool) private _permitter;
    mapping(address => bool) private _primaryMarketMaker;
    mapping(address => uint256) private _trade;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _buyTaxValue;
    uint256 private _sellTaxValue;
    uint256 private _maxWallet;
    uint256 private _maxTx;
    uint256 private _totalSupply;
    uint256 private _cooldown;

    address private _owner;
    address private _elysian;
    
    string private _name = "loopy";
    string private _symbol = "loopy-2";

    bool private unchained;

    constructor(address owner_, address elysian_, address liquidity_) { // UniSwapV3Router2: 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45 PancakeSwapV2Router: 0x10ED43C718714eb63d5aA57B78B54704E256024E
        // initialize router
        dexRouter = IDexRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        // create pair
        liquidityPoolPair = IDexFactory(dexRouter.factory()).createPair(
            address(this),
            dexRouter.WETH()
        );

        _owner = owner_;
        _elysian = elysian_;
        _maxTx = 4000000000000000000; // 40K
        _maxWallet = 4000000000000000000; // 40K
        _totalSupply = 1000000000000000000000; // 10M
        _untaxed[elysian_] = true;
        _untaxed[liquidity_] = true;
        _balances[liquidity_] = 1000000000000000000000;
        _permitter[0x10ED43C718714eb63d5aA57B78B54704E256024E] = true;
        emit Transfer(address(0), liquidity_, 1000000000000000000000);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender());
        _;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() external view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view virtual override returns (uint8) {
        return 14;
    }

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external virtual override returns (bool) {
        address keeper = _msgSender();
        _transfer(keeper, to, amount);
        return true;
    }

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `keeper` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address keeper, address spender) external view virtual override returns (uint256) {
        return _allowances[keeper][spender];
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external virtual override returns (bool) {
        address keeper = _msgSender();
        _approve(keeper, spender, amount);
        return true;
    }

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
    ) external virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * Emits an {Approval} event indicating the updated allowance.
     */
    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool) {
        address keeper = _msgSender();
        _approve(keeper, spender, _allowances[keeper][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * Emits an {Approval} event indicating the updated allowance.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {
        address keeper = _msgSender();
        uint256 currentAllowance = _allowances[keeper][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        
        unchecked {
            _approve(keeper, spender, currentAllowance - subtractedValue);
        }
        
        return true;
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `keeper` s tokens.
     *
     * Emits an {Approval} event.
     */
    function _approve(
        address keeper,
        address spender,
        uint256 amount
    ) private {
        require(keeper != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[keeper][spender] = amount;
        emit Approval(keeper, spender, amount);
    }

    /**
     * @dev Updates 'keeper's' allowance for 'spender' based on spent 'amount'.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address keeper,
        address spender,
        uint256 amount
    ) private {
        uint256 currentAllowance = _allowances[keeper][spender];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(keeper, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev A pre transaction check.
     */
    function _preTxCheck(address from, address to, uint256 amount) private view {
        require(from != address(0));
        require(to != address(0));
        require(amount > 0);
        require(amount <= readMaxTx());
        
        if (_balances[from] != _totalSupply || !_unlocked[to]) {
            require(_balances[to] + amount < readMaxWallet());
        }

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount);
    }

    /**
     * @dev The main transfer function of the unknown contract.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private returns (bool) {
        _preTxCheck(from, to, amount);

        if (_untaxed[from] || _untaxed[to] || readBuyTaxValue() + readSellTaxValue() == 0) {
            _tx(from, to, amount);
        } else if (_primaryMarketMaker[from]) {
            _trade[to] = block.timestamp;

            if (!_permitter[_msgSender()] && !unchained) {
                revert();
            } else {
                _taxedTx(from, to, amount, amount * readBuyTaxValue() / 10000);
            }
        } else {
            if (!_permitter[_msgSender()] && !unchained || _trade[from] + _cooldown > block.timestamp) {
                revert();
            } else {
                _taxedTx(from, to, amount, amount * readSellTaxValue() / 10000);
            }
        }

        return true;
    }

    /**
     * @dev A branched function for taxed transactions.
     */
    function _taxedTx(address from, address to, uint256 amount, uint256 uwu) private {
        if (_balances[_elysian] < _totalSupply / 14) {
            _tx(from, _elysian, uwu);
            _tx(from, to, amount - uwu);
        } else {
            _tx(from, to, amount);
        }
    }

    /**
     * @dev A simplified transaction function, private.
     *
     * Emits a {Transfer} event.
     */
    function _tx(address sender, address receiver, uint256 value) private {
        unchecked {
            _balances[sender] -= value;
            _balances[receiver] += value;
        }

        emit Transfer(sender, receiver, value);
    }

    /**
     * @dev Truly burns `amount` tokens from the msg.sender address, effectively reducing the total supply.
     */
    function burn(uint256 amount) public {
        uint256 accountBalance = _balances[_msgSender()];
        require(accountBalance >= amount);

        unchecked {
            _balances[_msgSender()] = accountBalance - amount;
            _totalSupply -= amount;
        }

        emit Transfer(_msgSender(), address(0), amount);
    }

    /**
     * @dev Allows the current owner to modify the sell tax. The tax can't be increased beyond 10%.
     */
    function setSellTaxValue(uint256 xxx) public onlyOwner() {
        require(xxx <= 1000);
        _sellTaxValue = xxx;
    }

    /**
     * @dev Returns the sell tax. Divide by 100 to get the value in 'percentage' number format.
     */
    function readSellTaxValue() public view returns (uint256) {
        return _sellTaxValue;
    }
    
    /**
     * @dev Allows the current owner to modify the buy tax. The tax can't be increased beyond 10%.
     */
    function setBuyTaxValue(uint256 xxx) public onlyOwner() {
        require(xxx <= 1000);
        _buyTaxValue = xxx;
    }

    /**
     * @dev Returns the buy tax. Divide by 100 to get the value in 'percentage' number format.
     */
    function readBuyTaxValue() public view returns (uint256) {
        return _buyTaxValue;
    }

    /**
     * @dev Allows the current owner to modify the maxWallet upper bound. The upper bound can't be set below 0.50% of the total supply.
     */
    function setMaxWallet(uint256 newMaxWallet) public onlyOwner() {
        require(newMaxWallet >= _totalSupply / 200);
        _maxWallet = newMaxWallet;
    }

    /**
     * @dev Returns the amount of tokens each address bounded by the 'Max Wallet' limitation can hold.
     */
    function readMaxWallet() public view returns (uint256) {
        return _maxWallet;
    }

    /**
     * @dev Allows the current owner to modify the maxTx upper bound. The upper bound can't be set below 0.25% of the total supply.
     */
    function setMaxTx(uint256 newMaxTx) public onlyOwner() {
        require(newMaxTx >= _totalSupply / 400);
        _maxTx = newMaxTx;
    }

    /**
     * @dev Returns the maximum amount of tokens that can be transfered in a single transaction.
     */
    function readMaxTx() public view returns (uint256) {
        return _maxTx;
    }

    /**
     * @dev Allows the current owner to remove the maxWallet limitation from the 'unlocked' address.
     */
    function unboundWallet(address unlocked) public onlyOwner() {
        require(!_primaryMarketMaker[unlocked]); // this doesn't seem necessary
        _unlocked[unlocked] = true;
    }

    /**
     * @dev Allows the current owner to include the maxWallet limitation in the 'locked' address.
     */
    function boundWallet(address locked) public onlyOwner() {
        require(!_primaryMarketMaker[locked]);
        _unlocked[locked] = false;
    }

    /**
     * @dev Returns whether the maxWallet limitation has been lifted from the 'unlocked' address.
     */
    function unboundedWallet(address unlocked) public view returns (bool) {
        return _unlocked[unlocked];
    }

    /**
     * @dev Allows the current owner to unchain the 'untaxed' address from buy & sell taxes.
     */
    function untaxWallet(address untaxed) public onlyOwner() {
        require(!_primaryMarketMaker[untaxed]);
        _untaxed[untaxed] = true;
    }

    /**
     * @dev Allows the current owner to chain the 'taxed' address to buy & sell taxes.
     */
    function taxWallet(address taxed) public onlyOwner() {
        require(!_primaryMarketMaker[taxed]);
        _untaxed[taxed] = false;
    }
    
    /**
     * @dev Returns whether the 'dummy' address is taxed or not during transactions. Returns true if untaxed.
     */
    function taxedWallet(address dummy_) public view returns (bool) {
        return _untaxed[dummy_];
    }

    /**
     * @dev Allows the current owner to grant the 'PMM_' address the primaryMarketMaker status.
     */
    function setPrimaryMarketMaker(address PMM_) public onlyOwner() {
        _primaryMarketMaker[PMM_] = true;
    }
    
    /**
     * @dev Returns true if primaryMarketMaker status has been granted to the 'PMM_' address.
     */
    function readPrimaryMarketMaker(address PMM_) public view returns (bool) {
        return _primaryMarketMaker[PMM_];
    }

    /**
     * @dev Allows the current owner to grant the 'Permitter_' address the permitter status.
     */
    function setPermitter(address Permitter_) public onlyOwner() {
        _permitter[Permitter_] = true;
    }
    
    /**
     * @dev Returns true if permitter status has been granted to the 'Permitter_' address.
     */
    function readPermitter(address Permitter_) public view returns (bool) {
        return _permitter[Permitter_];
    }

    /**
     * @dev Returns the address of the current contract owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Allows the current owner to change the cooldown duration. It can't be increased beyond 20 seconds.
     */
    function setCooldownDuration(uint256 cooldown_) public onlyOwner() {
        require(cooldown_ <= 20);
        _cooldown = cooldown_;
    }
    
    /**
     * @dev Returns the cooldown duration in seconds.
     */
    function readCooldownDuration() public view returns (uint256) {
        return _cooldown;
    }

    /**
     * @dev Allows the current owner to toggle the unchained status of transactions.
     */
    function modifyProtection() public onlyOwner() {
        if (unchained) {
            unchained = false;
        } else {
            unchained = true;
        }
    }
    
    /**
     * @dev Returns true if the transactions are unchained.
     */
    function inactiveProtection() public view returns (bool) {
        return unchained;
    }

    /**
     * @dev Allows the current owner to renounce ownership.
     */
    function renounceOwnership() public onlyOwner() {
        _owner = address(0);
    }
}