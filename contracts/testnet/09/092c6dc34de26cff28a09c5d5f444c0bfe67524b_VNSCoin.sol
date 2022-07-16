/**
 *Submitted for verification at BscScan.com on 2022-07-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-14
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
/// @custom:security-contact [email protected]


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
/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}



/// @custom:security-contact [email protected]
contract VNSCoin is ERC20, Ownable {
    string constant _name = "ETOKEN";
    string constant _symbol = "ET";
    uint8 constant _decimals = 18;
    address[] _balanceKeys;
    //换成usdt的合约地址
    address constant public _usdt = 0x33B28c697Ad6b0685db05eD8A1aB806f0577AcFC;
    struct CoinConfig {
        //用于储存用于ido的余额
        uint256 _idoBalanceSupply;
        //用于储存每人ido的限额
        uint256 _idoLimit;
        //用于储存价格，每个IC值多少BNB
        //想办法整个整数
        uint256 _rate_numerator;
        uint256 _rate_denominator;
        //ido结束时间
        uint256 _idoEndtime;
        //限制交易的最大最小值
        uint256 _bnbValueMin;
        uint256 _bnbValueMax;
        //airDrop结束时间
        uint256 _airDropEndtime;
        //限制交易的最大最小值
        uint256 _commonValueMin;
    }
    
    mapping (address => bool)  Wallets;


    function setWallet(address _wallet) internal{
        Wallets[_wallet]=true;
    }

    function _contains(address _wallet)  internal view returns (bool){
        return Wallets[_wallet];
    }
    CoinConfig _coinConfig;

    struct CoinNumber {
        uint256 _value;
    }
    mapping(address => CoinNumber[]) _idoBalances;
    mapping(address => CoinNumber[]) _airDropBalances;

    constructor() ERC20(_name, _symbol) {
        //默认值
        setCoinConfig(
            0,
            100000 * 10**18,
            1,
            10 * 10 ,
            0,
            10 * 10**15,
            50 * 10 * 10**15,
            0,
            10 * 10**15
        );
    }

    //挖矿 --关闭
    // function mint(address to, uint256 amount) public onlyOwner {
    //     _mint(to, amount);
    // }

    function setCoinConfig(
        uint256 idoBalanceSupply,
        uint256 idoLimit,
        uint256 rate_numerator,
        uint256 rate_denominator,
        uint256 idoEndtime,
        uint256 bnbValueMin,
        uint256 bnbValueMax,
        uint256 airDropEndtime,
        uint256 commonValueMin
    ) public onlyOwner {
        if (idoBalanceSupply > 0) {
            _coinConfig._idoBalanceSupply = idoBalanceSupply;
        }
        if (idoLimit > 0) {
            _coinConfig._idoLimit = idoLimit;
        }
        if (rate_numerator > 0) {
            _coinConfig._rate_numerator = rate_numerator;
        }
        if (rate_denominator > 0) {
            _coinConfig._rate_denominator = rate_denominator;
        }
        if (idoEndtime > 0) {
            _coinConfig._idoEndtime = idoEndtime;
        }
        if (bnbValueMin > 0) {
            _coinConfig._bnbValueMin = bnbValueMin;
        }
        if (bnbValueMax > 0) {
            _coinConfig._bnbValueMax = bnbValueMax;
        }
        if (airDropEndtime > 0) {
            _coinConfig._airDropEndtime = airDropEndtime;
        }
        if (commonValueMin > 0) {
            _coinConfig._commonValueMin = commonValueMin;
        }
    }


    // //调整ido的余额
    // function adjustIdoBalanceSupply(uint256 amount) public onlyOwner {
    //     //设置ido金额 直接转到合约地址  
    //     _mint(address(this), amount);
    //     _coinConfig._idoBalanceSupply += amount;
    //     //设置生息金额 ido 6倍
    //     _mint(address(this), amount * 6);
    // }

    // //调整ido的余额
    // function adjustIdoBalanceSupply(uint256 amount) public onlyOwner {
    //     //设置ido金额 直接转到合约地址  
    //     _mint(address(this), amount);
    //     _transfer(msg.sender, address(this), amount);
    //     _coinConfig._idoBalanceSupply += amount;
    // }

    // //执行IDO，扣BNB，获得IC
    // function ido() external payable {
    //     require(msg.value >= _coinConfig._bnbValueMin, "bnb amount need > min");
    //     require(msg.value <= _coinConfig._bnbValueMax, "bnb amount need < max");
    //     require(
    //         _coinConfig._idoBalanceSupply > 0,
    //         "_idoBalanceSupply need greater than 0"
    //     );
    //     uint256 amount = msg.value *
    //         (_coinConfig._rate_denominator/_coinConfig._rate_numerator);

    //     require(
    //         _coinConfig._idoBalanceSupply > amount,
    //         "_idoBalanceSupply need greater than amount"
    //     );
    //     uint256 availableIdo = _coinConfig._idoLimit - _idoBalanceOf(msg.sender);
    //     require(
    //         availableIdo > msg.value,
    //         "availableIdo need  greater than amount"
    //     );
    //     _transfer(address(this), msg.sender, amount);
    //     _coinConfig._idoBalanceSupply = _coinConfig._idoBalanceSupply - amount;
    //     _idoBalances[msg.sender].push(CoinNumber(amount));
    // }

//    //执行IDO，扣usdt，获得    todo 加上完整校验 
//     function idoUSDT(address pid,uint256 amount) external  {
//         require(amount >= _coinConfig._commonValueMin, "amount need > min");
//         require(
//             _coinConfig._idoBalanceSupply > 0,
//             "_idoBalanceSupply need greater than 0"
//         );
//         uint256 idoAmount = amount *
//             (_coinConfig._rate_denominator/_coinConfig._rate_numerator);

//         require(
//             _coinConfig._idoBalanceSupply > idoAmount,
//             "_idoBalanceSupply need greater than amount"
//         );
//         //比例建议写成配置
//         uint256 s1 = 90;
//         uint256 s2 = 10;
//         uint256 s3 = 100;
//         uint256 idoAmountUsdt  = amount / s3 * s1  ;
//         uint256 PidAmountUsdt  = amount / s3 * s2  ;
//         IERC20(_usdt).transferFrom(msg.sender, address(this), idoAmountUsdt);
//         IERC20(_usdt).transferFrom(msg.sender, address(pid), PidAmountUsdt);
//         _transfer(address(this), msg.sender, idoAmount);
//         _coinConfig._idoBalanceSupply = _coinConfig._idoBalanceSupply - idoAmount;
//         _idoBalances[msg.sender].push(CoinNumber(idoAmount));
//     }

    //执行IDO，扣usdt，获得    todo 加上完整校验 
    function idoUSDT(address pid,uint256 amount) external  {
        require(amount >= _coinConfig._commonValueMin, "amount need > min");
        // require(
        //     _coinConfig._idoBalanceSupply > 0,
        //     "_idoBalanceSupply need greater than 0"
        // );
        uint256 idoAmount = amount *
            (_coinConfig._rate_denominator/_coinConfig._rate_numerator);

        // require(
        //     _coinConfig._idoBalanceSupply > idoAmount,
        //     "_idoBalanceSupply need greater than amount"
        // );
        //比例建议写成配置
        uint256 s1 = 90;
        uint256 s2 = 10;
        uint256 s3 = 100;
        uint256 idoAmountUsdt  = amount / s3 * s1  ;
        uint256 PidAmountUsdt  = amount / s3 * s2  ;
        IERC20(_usdt).transferFrom(msg.sender, address(this), idoAmountUsdt);
        IERC20(_usdt).transferFrom(msg.sender, address(pid), PidAmountUsdt);
        //先铸币给用户
        _mint( msg.sender, idoAmount);
        _mint( address(this) , idoAmount * 5);
        // _transfer(address(this), msg.sender, idoAmount);
        // _coinConfig._idoBalanceSupply = _coinConfig._idoBalanceSupply - idoAmount;
        _idoBalances[msg.sender].push(CoinNumber(idoAmount));
    }

    //Ido了多次，余额是多少
    function _idoBalanceOf(address _address) internal view returns (uint256) {
        uint256 total;
        CoinNumber[] memory _b = _idoBalances[_address];
        for (uint256 i = 0; i < _b.length; i++) {
            total = total + _b[i]._value;
        }
        return total;
    }

    //空投余额
    function _airDropBalanceOf(address _address) internal view returns (uint256) {
        uint256 total;
        CoinNumber[] memory _b = _airDropBalances[_address];
        for (uint256 i = 0; i < _b.length; i++) {
            total = total + _b[i]._value;
        }
        return total;
    }

    function idoBalanceOf() public view returns (uint256) {
        uint256 total;
        CoinNumber[] memory _b = _idoBalances[msg.sender];
        for (uint256 i = 0; i < _b.length; i++) {
            total = total + _b[i]._value;
        }
        return total;
    }

    function airDropBalanceOf() public view returns (uint256) {
        uint256 total;
        CoinNumber[] memory _b = _airDropBalances[msg.sender];
        for (uint256 i = 0; i < _b.length; i++) {
            total = total + _b[i]._value;
        }
        return total;
    }


    function coinConfigView() public view returns (CoinConfig memory) {
        return _coinConfig;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
        if (address(from) != address(0)) {
            uint256 lockNumber = 0;
            if (block.timestamp <= _coinConfig._idoEndtime) {
                uint256 idoLockNumber = _idoBalanceOf(msg.sender);
                lockNumber+=idoLockNumber;
            }
            if (block.timestamp <= _coinConfig._airDropEndtime) {
                uint256 airLockNumber = _airDropBalanceOf(msg.sender);
                lockNumber+=airLockNumber;
            }
            lockNumber+=amount;
            require(balanceOf(from) >= lockNumber,
            "cannot transfer more than ido/airdrop number during ido/airdrop time"
            );
        }
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._afterTokenTransfer(from, to, amount);
        if(!_contains(from))
        {
            setWallet(from);
            _balanceKeys.push(from);
        }
        if(!_contains(to))
        {
            setWallet(to);
            _balanceKeys.push(to);
        }
        
    }

    //提取bnb
    function sendBNB(uint256 amount) public onlyOwner {
        payable(msg.sender).transfer(amount);
    }

    //空投
    function airDrop(address[] memory _address_list, uint256 _amount_token) external onlyOwner {
        for (uint256 i = 0; i < _address_list.length; i++) {
            address user = _address_list[i];
            if (_amount_token > 0) {
                _transfer(address(this),user,_amount_token);
                _airDropBalances[msg.sender].push(CoinNumber(_amount_token));
            }
        }
    }

    //提取当前代币
    function sendCoin(uint256 amount) public onlyOwner {
         _transfer(address(this), msg.sender, amount);
    }

    //提取其他币种
    function sendCoin(address token ,uint256 amount) public onlyOwner {
        IERC20(token).transferFrom(address(this), msg.sender,  amount);
    }
    //持币生息
    function payInterest() public onlyOwner {
        uint256 a = 1000;
        uint256 b = 208;
        address[] memory _b = _balanceKeys;
        for (uint256 i = 0; i < _b.length; i++) {
            address _address = _b[i];
            uint256 _bal = balanceOf(_address);
            //余额大于0并且不是黑名单,进行发息
            if(_bal > 0&&!isInterestBlackList(_address)){
                uint256 amount = _bal/a*b;
                _transfer(address(this), _address, amount);
            }
        }
    }

    //持币生息黑名单  
    mapping (address => bool)  interestBlackList;

    //增加黑名单-生息
    function addInterestBlackList(address _addr) public onlyOwner{
        interestBlackList[_addr]=true;
    }

    //移除黑名单-生息
    function removeInterestBlackList(address _addr)  public onlyOwner{
        interestBlackList[_addr]=false;
    }
    //查询是否生息黑名单
    function isInterestBlackList(address _addr)  public view returns (bool){
        return interestBlackList[_addr];
    }

    //税费白名单  
    mapping (address => bool)  transferFromWL;

    //增加税费白名单 
    function addTransferFromWL(address _addr)  public onlyOwner{
        transferFromWL[_addr]=true;
    }

    //移除税费白名单 
    function removeTransferFromWL(address _addr)  public onlyOwner{
        transferFromWL[_addr]=false;
    }
    //查询是否税费白名单 
    function isTransferFromWL(address _addr)  public view returns (bool){
        return transferFromWL[_addr];
    }

    //重写划转方法
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        //super.transfer(from, to, amount);
        address owner = _msgSender();
        require(
            !isTransferFromBL(owner),
            "account in blackList"
        );
        require(
            !isTransferToBL(to),
            "account in blackList"
        );
        //增加15%税费 开始
        uint256 a = 100;
        uint256 b = 15; 
        uint256 fee =0 ;
        //转出白名单不需要支付税费
        if(!isTransferFromWL(owner)){
            fee = amount / a * b;
            //税费逻辑 需要分三份来处理  回收地址/nft均分/lp均分
            _transfer(owner, address(this), fee);
        }

        _transfer(owner, to, amount - fee);
        return true;
    }
    //重写划转方法
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        require(
            !isTransferFromBL(from),
            "account in blackList"
        );
        require(
            !isTransferToBL(to),
            "account in blackList"
        );
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        //增加15%税费 开始
        uint256 a = 100;
        uint256 b = 15; 
        uint256 fee =0 ;
        //转出白名单不需要支付税费
        if(!isTransferFromWL(from)){
            fee = amount / a * b;
            //税费逻辑 需要分三份来处理  回收地址/nft均分/lp均分
            _transfer(from, address(this), fee);
        }

        _transfer(from, to, amount - fee);
        return true;
    }


    //  转出黑名单
    mapping (address => bool)  transferFromBL;

    //增加转出转出黑名单
    function addTransferFromBL(address _addr)  public onlyOwner{
        transferFromBL[_addr]=true;
    }

    //移除转出转出黑名单
    function removeTransferFromBL(address _addr)  public onlyOwner{
        transferFromBL[_addr]=false;
    }
    //查询是否转出转出黑名单
    function isTransferFromBL(address _addr)  public view returns (bool){
        return transferFromBL[_addr];
    }
           
    //  转入黑名单
    mapping (address => bool)  transferToBL;

    //增加转入黑名单
    function addTransferToBL(address _addr)  public onlyOwner{
        transferToBL[_addr]=true;
    }

    //移除转入黑名单
    function removeTransferToBL(address _addr)  public onlyOwner{
        transferToBL[_addr]=false;
    }
    //查询是否转入黑名单
    function isTransferToBL(address _addr)  public view returns (bool){
        return transferToBL[_addr];
    }
 

}