/**
 *Submitted for verification at BscScan.com on 2022-05-11
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

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

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

library Math {
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b + (a % b == 0 ? 0 : 1);
    }
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

interface ITokenomicsStrategy {
    function process() external;
}

interface IVoting {
    function createProposal(
        address recipient,
        uint256 amount,
        uint256 endsAt
    ) external;

    function voteFor() external;

    function voteAgainst() external;

    function canTransfer(address sender) external view returns (bool);

    function complete() external;
}

interface ITokenomicsToken is IERC20, IERC20Metadata {
    function feeDenominator() external view returns (uint16);

    function maxSellBuyFee() external view returns (uint8);

    function sellBuyBurnFee() external view returns (uint8);

    function sellBuyCharityFee() external view returns (uint8);

    function sellBuyOperatingFee() external view returns (uint8);

    function sellBuyMarketingFee() external view returns (uint8);

    function sellBuyTotalFee() external view returns (uint8);

    function setSellBuyFee(
        uint8 sellBuyCharityFee_,
        uint8 sellBuyOperatingFee_,
        uint8 sellBuyMarketingFee_
    ) external;

    function maxTransferFee() external view returns (uint8);

    function transferBurnFee() external view returns (uint8);

    function transferCharityFee() external view returns (uint8);

    function transferOperatingFee() external view returns (uint8);

    function transferMarketingFee() external view returns (uint8);

    function transferTotalFee() external view returns (uint8);

    function setTransferFee(
        uint8 transferCharityFee_,
        uint8 transferOperatingFee_,
        uint8 transferMarketingFee_
    ) external;

    function process() external;

    function isFeeExempt(address account) external view returns (bool);

    function setFeeExempt(address account, bool exempt) external;

    function strategy() external view returns (ITokenomicsStrategy strategy_);

    function setStrategy(ITokenomicsStrategy strategy_) external;

    function dexPair() external view returns (address);

    function setDexPair(address dexPair_) external;

    function burn(uint256 amount) external;

    function burnFrom(address account, uint256 amount) external;

    event FeePayment(address indexed payer, uint256 fee);

    event Burnt(address indexed account, uint256 amount);
}

interface IFCKToken is ITokenomicsToken {
    function teamAndAdvisorsCap() external view returns (uint256);

    function marketingReserveCap() external view returns (uint256);

    function platformReserveCap() external view returns (uint256);

    function launchedAt() external view returns (uint256);

    function launched() external view returns (bool);

    function launch() external returns (bool);

    function mint(address account, uint256 amount) external;

    function pause() external;

    function unpause() external;

    function maxTxAmount() external view returns (uint256);

    function setMaxTxAmount(uint256 maxTxAmount_) external;

    function maxWalletBalance() external view returns (uint256);

    function setMaxWalletBalance(uint256 maxWalletBalance_) external;

    function isTxLimitExempt(address account) external view returns (bool);

    function setIsTxLimitExempt(address recipient, bool exempt) external;

    event Minted(address indexed account, uint256 amount);

    event Launched(uint256 launchedAt);

    event FeePayment(address indexed sender, uint256 balance, uint256 fee);
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
contract ERC20 is IERC20, IERC20Metadata {
    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) internal _allowances;

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
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, msg.sender, currentAllowance - amount);
        }

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
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender] + addedValue
        );
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
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(msg.sender, spender, currentAllowance - subtractedValue);
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
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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
        _totalSupply += amount;
        _balances[account] += amount;
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

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;
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

contract TokenomicsToken is ITokenomicsToken, ERC20, Ownable {
    mapping(address => bool) private _isFeeExempt;
    ITokenomicsStrategy private _strategy;
    address private _dexPair;

    uint8 constant FEE_EXEMPT = 0;
    uint8 constant TRANSFER = 1;
    uint8 constant BUY = 2;
    uint8 constant SELL = 3;

    uint16 private _feeDenominator = 1000;
    uint256 private _minTokenomicsBurnAmount = 9 * (10**12) * (10**decimals()); // 9 000 000 000 000

    uint8 private _maxSellBuyFee = 55; // 5.5%
    uint8 private _sellBuyBurnFee = 35; // 3.5%
    uint8 private _sellBuyCharityFee = 5; // 0.5%
    uint8 private _sellBuyOperatingFee = 30; // 3%
    uint8 private _sellBuyMarketingFee = 20; // 2%

    uint8 private _maxTransferFee = 110; // 11%
    uint8 private _transferBurnFee = 70; // 7%
    uint8 private _transferCharityFee = 10; // 1%
    uint8 private _transferOperatingFee = 60; // 6%
    uint8 private _transferMarketingFee = 40; // 4%

    constructor(string memory name_, string memory symbol_)
        ERC20(name_, symbol_)
    {
        _isFeeExempt[address(this)] = true;
    }

    function feeDenominator() external view override returns (uint16) {
        return _feeDenominator;
    }

    function maxSellBuyFee() external view override returns (uint8) {
        return _maxSellBuyFee;
    }

    function sellBuyBurnFee() external view override returns (uint8) {
        return totalSupply() > _minTokenomicsBurnAmount ? _sellBuyBurnFee : 0;
    }

    function sellBuyCharityFee() external view override returns (uint8) {
        return _sellBuyCharityFee;
    }

    function sellBuyOperatingFee() external view override returns (uint8) {
        return _sellBuyOperatingFee;
    }

    function sellBuyMarketingFee() external view override returns (uint8) {
        return _sellBuyMarketingFee;
    }

    function sellBuyTotalFee() external view override returns (uint8) {
        return
            this.sellBuyBurnFee() +
            _sellBuyCharityFee +
            _sellBuyOperatingFee +
            _sellBuyMarketingFee;
    }

    function setSellBuyFee(
        uint8 sellBuyCharityFee_,
        uint8 sellBuyOperatingFee_,
        uint8 sellBuyMarketingFee_
    ) external override onlyOwner {
        uint8 total = sellBuyCharityFee_ +
            sellBuyOperatingFee_ +
            sellBuyMarketingFee_;
        require(
            total <= _maxSellBuyFee,
            "TokenomicsToken: Total fee should be less or equal max fee"
        );
        _sellBuyCharityFee = sellBuyCharityFee_;
        _sellBuyOperatingFee = sellBuyOperatingFee_;
        _sellBuyMarketingFee = sellBuyMarketingFee_;
    }

    function maxTransferFee() external view override returns (uint8) {
        return _maxTransferFee;
    }

    function transferBurnFee() external view override returns (uint8) {
        return totalSupply() > _minTokenomicsBurnAmount ? _transferBurnFee : 0;
    }

    function transferCharityFee() external view override returns (uint8) {
        return _transferCharityFee;
    }

    function transferOperatingFee() external view override returns (uint8) {
        return _transferOperatingFee;
    }

    function transferMarketingFee() external view override returns (uint8) {
        return _transferMarketingFee;
    }

    function transferTotalFee() external view override returns (uint8) {
        return
            this.transferBurnFee() +
            _transferCharityFee +
            _transferOperatingFee +
            _transferMarketingFee;
    }

    function setTransferFee(
        uint8 transferCharityFee_,
        uint8 transferOperatingFee_,
        uint8 transferMarketingFee_
    ) external override onlyOwner {
        uint8 total = 
            transferCharityFee_ +
            transferOperatingFee_ +
            transferMarketingFee_;
        require(
            total <= _maxTransferFee,
            "TokenomicsToken: Total fee should be less or equal max fee"
        );
        _transferCharityFee = transferCharityFee_;
        _transferOperatingFee = transferOperatingFee_;
        _transferMarketingFee = transferMarketingFee_;
    }

    function process() external override {
        _strategy.process();
    }

    function isFeeExempt(address account)
        external
        view
        override
        returns (bool)
    {
        return _isFeeExempt[account];
    }

    function setFeeExempt(address account, bool exempt) external override {
        _isFeeExempt[account] = exempt;
    }

    function dexPair() external view override returns (address) {
        return _dexPair;
    }

    function setDexPair(address dexPair_) external override onlyOwner {
        _dexPair = dexPair_;
    }

    function strategy()
        external
        view
        override
        returns (ITokenomicsStrategy strategy_)
    {
        return _strategy;
    }

    function setStrategy(ITokenomicsStrategy strategy_)
        external
        override
        onlyOwner
    {
        require(
            address(strategy_) != address(0),
            "TokenomicsToken: Wrong strategy contract address"
        );
        if (address(_strategy) != address(0)) {
            _approve(address(this), address(_strategy), 0);
        }
        _strategy = strategy_;
        _approve(address(this), address(_strategy), type(uint256).max);
    }

    function burn(uint256 amount) external override {
        _burn(msg.sender, amount);
        emit Burnt(msg.sender, amount);
    }

    function burnFrom(address account, uint256 amount) external override {
        uint256 currentAllowance = allowance(account, msg.sender);
        require(
            currentAllowance >= amount,
            "ERC20: burn amount exceeds allowance"
        );
        unchecked {
            _approve(account, msg.sender, currentAllowance - amount);
        }
        _burn(account, amount);
        emit Burnt(account, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];

        uint8 transferType = _transferFeeType(sender, recipient);
        uint256 fee = _calcFee(transferType, amount);
        uint256 totalAmount = amount;
        if (transferType == TRANSFER || transferType == SELL) {
            totalAmount += fee;
            _balances[address(this)] += fee;
            emit FeePayment(sender, fee);
        }

        require(
            senderBalance >= totalAmount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - totalAmount;
        }

        totalAmount = amount;
        if (transferType == BUY) {
            totalAmount -= fee;
            _balances[address(this)] += fee;
            emit FeePayment(sender, fee);
        }

        _balances[recipient] += totalAmount;
        emit Transfer(sender, recipient, amount);

        _burnFee(transferType, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _transferFeeType(address from, address to)
        internal
        view
        returns (uint8)
    {
        if (_isFeeExempt[from] || _isFeeExempt[to]) return FEE_EXEMPT;
        if (from == _dexPair) return BUY;
        if (to == _dexPair) return SELL;
        return TRANSFER;
    }

    function _calcFee(uint8 transferType, uint256 amount)
        internal
        view
        returns (uint256)
    {
        uint256 fee = 0;
        if (transferType == TRANSFER) {
            fee = Math.ceilDiv(
                amount * this.transferTotalFee(),
                _feeDenominator
            );
        } else if (transferType == BUY || transferType == SELL) {
            fee = Math.ceilDiv(
                amount * this.sellBuyTotalFee(),
                _feeDenominator
            );
        }
        return fee;
    }

    function _burnFee(uint8 transferType, uint256 amount) internal {
        uint256 fee = 0;
        if (transferType == TRANSFER) {
            fee = Math.ceilDiv(
                amount * this.transferBurnFee(),
                _feeDenominator
            );
        } else if (transferType == BUY || transferType == SELL) {
            fee = Math.ceilDiv(amount * this.sellBuyBurnFee(), _feeDenominator);
        }
        if (fee > 0) this.burn(fee);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
        require(
            address(_strategy) != address(0),
            "TokenomicsToken: Tokenomics distribution strategy is not set"
        );
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._afterTokenTransfer(from, to, amount);
        _strategy.process();
    }
}


contract FCKToken is IFCKToken, TokenomicsToken, Pausable {
    uint256 private _launchedAt;
    uint256 private _startTime;
    uint256 public cap;

    uint256 private _teamAndAdvisorsCap;
    uint256 private _marketingReserveCap;
    uint256 private _platformReserveCap;
    uint256 private _minted;

    uint256 private _maxTxAmount;
    uint256 private _maxWalletBalance;
    mapping(address => bool) private _isTxLimitExempt;

    IVoting private _voting;

    constructor(uint256 startTime) TokenomicsToken("Fat Cat Killer", "$KILLER") {
        cap = 900 * (10**12) * (10**decimals()); // 900 000 000 000 000
        _teamAndAdvisorsCap = 288 * (10**12) * (10**decimals()); // 288 000 000 000 000
        _marketingReserveCap = 162 * (10**12) * (10**decimals()); // 162 000 000 000 000
        _platformReserveCap = 450 * (10**12) * (10**decimals()); // 450 000 000 000 000
        _maxTxAmount = 100 * (10**6) * (10**decimals()); // 100 000 000;
        _maxWalletBalance = 100 * (10**6) * (10**decimals()); // 100 000 000;
        _startTime = startTime;
    }

    function teamAndAdvisorsCap() external view override returns (uint256) {
        return _teamAndAdvisorsCap;
    }

    function marketingReserveCap() external view override returns (uint256) {
        return _marketingReserveCap;
    }

    function platformReserveCap() external view override returns (uint256) {
        return _platformReserveCap;
    }

    function launchedAt() external view override returns (uint256) {
        return _launchedAt;
    }

    function launched() external view override returns (bool) {
        return _launchedAt > 0;
    }

    function launch() external override returns (bool) {
        if (_launchedAt == 0 && block.timestamp >= _startTime) {
            _launchedAt = block.timestamp;
            emit Launched(_launchedAt);
            return true;
        }
        return false;
    }

    function mint(address account, uint256 amount) external override onlyOwner {
        require(_minted + amount <= cap, "It's impossible mint more than cap");
        _mint(account, amount);
        _minted += amount;
        emit Minted(account, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        super._beforeTokenTransfer(from, to, amount);
        require(this.launched(), "FCKToken: Not yet launched");
        require(!paused(), "ERC20Pausable: token transfer while paused");

        if (address(_voting) != address(0)) {
            require(
                _voting.canTransfer(from),
                "Voting: there is no possibility for the participant to transfer tokens while voting is in progress"
            );
        }

        require(amount <= _maxTxAmount || _isTxLimitExempt[from], "FCKToken: TX Limit Exceeded");
        require(
                (balanceOf(to) + amount) <= _maxWalletBalance || this.isFeeExempt(from),
                "FCKToken: Total Holding is currently limited, you can not buy that much."
            );
    }

    function pause() external override onlyOwner {
        _pause();
    }

    function unpause() external override onlyOwner {
        _unpause();
    }

    function setVoting(IVoting voting) external onlyOwner {
        _voting = voting;
        _isTxLimitExempt[address(voting)] = true;
    }

    function maxTxAmount() external view override returns (uint256) {
        return _maxTxAmount;
    }

    function setMaxTxAmount(uint256 maxTxAmount_) external override onlyOwner {
        _maxTxAmount = maxTxAmount_;
    }

    function maxWalletBalance() external view override returns (uint256) {
        return _maxWalletBalance;
    }

    function setMaxWalletBalance(uint256 maxWalletBalance_)
        external
        override
        onlyOwner
    {
        _maxWalletBalance = maxWalletBalance_;
    }

    function isTxLimitExempt(address account)
        external
        view
        override
        returns (bool)
    {
        return _isTxLimitExempt[account];
    }

    function setIsTxLimitExempt(address recipient, bool exempt)
        external
        override
        onlyOwner
    {
        _isTxLimitExempt[recipient] = exempt;
    }
}