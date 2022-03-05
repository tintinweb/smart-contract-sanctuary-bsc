/**
 *Submitted for verification at BscScan.com on 2022-03-05
*/

// File: contracts/ITrustedPayToken.sol


pragma solidity ^0.8.0;

// Interfaces of ERC20 USD Tokens
interface ITrustedPayToken {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: contracts/Context.sol


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

// File: contracts/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// File: contracts/Pausable.sol


// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: contracts/IERC20.sol


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
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// File: contracts/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


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
}

// File: contracts/ERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;




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
    constructor() {
        _name = "Wrapped OXO Coin";
        _symbol = "wOXO";
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
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
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
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
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
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
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
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
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
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );

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

    function _mintFromSales(address account, uint256 amount) internal virtual {
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
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

    function _burnForBuyBack(address account, uint256 amount) internal virtual {
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
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
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
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
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
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

// File: contracts/ERC20Burnable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.0;



/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}

// File: contracts/WrappedOXO.sol


pragma solidity ^0.8.7;






contract WrappedOXO is ERC20, ERC20Burnable, Pausable, Ownable {
    uint256 public _version = 4;

    address private SAFE_WALLET = 0x3edF93dc2e32fD796c108118f73fa2ae585C66B6;

    uint256 private _transferableByFoundation;
    uint256 public buyBackFund;
    uint256 private _totalTranferredToFoundation;

    mapping(address => bool) private contractManagers;

    struct TransferChain {
        address user;
        uint256 chainId;
        uint256 amount;
        uint256 nonce;
    }

    TransferChain[] public TransferToChain;
    uint256 public TransferToChainLatest = 0;

    // User Info
    struct UserInfo {
        address user;
        bool buyBackGuarantee;
        uint256 totalCoinsFromSales;
        uint256 totalBuyBackCoins;
        uint256 totalBuyBackUSD;
        uint256 balanceUSD;
        uint256 totalDeposits;
        uint256 totalPurchases;
        uint256 totalWithdrawns;
    }

    address[] private allUsers;

    mapping(address => uint256) private _userIndex;

    mapping(address => UserInfo) public _userInfoByAddress;

    struct Deposit {
        address user;
        address payToken;
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => Deposit[]) private _userDeposits;

    // Total Deposit Amount
    uint256 private _totalDepositedUSD;

    // PayTokens
    struct PayToken {
        string name;
        address contractAddress;
        uint256 totalDeposit;
        uint256 totalWithdrawn;
        bool valid;
    }

    PayToken[] public _payTokens;

    mapping(address => uint256) private _payTokenIndex;

    // Sales Information
    struct PreSale {
        uint256 price;
        uint256 totalCoins;
        uint256 min;
        uint256 max;
        uint256 saleStartTime;
        uint256 saleEndTime;
        uint256 unlockTime;
        uint256 totalSales;
    }

    PreSale[] public preSales;

    struct PublicSale {
        uint256 price;
        uint256 totalCoins;
        uint256 min;
        uint256 max;
        uint256 saleStartTime;
        uint256 saleEndTime;
        uint256 unlockTime;
        uint256 totalSales;
    }

    PublicSale[] public publicSales;

    enum SalesType {
        PRESALE,
        PUBLIC
    }

    // Purchases
    struct Purchase {
        address user;
        uint256 userPurchaseNonce;
        uint256 orderTime;
        uint256 orderBlock;
        SalesType salesType;
        uint8 stage;
        uint256 coinPrice;
        uint256 totalCoin;
        uint256 totalUSD;
        bool buyBack;
        uint256 unlockTime;
    }

    mapping(address => Purchase[]) private _userPurchases;

    mapping(address => mapping(SalesType => mapping(uint256 => uint256)))
        public _purchasedAtThisStage;

    struct UserSummary {
        address user;
        Deposit[] userDeposits;
        Purchase[] userPurchases;
        BuyBack[] userBuyBacks;
        Withdrawn[] userWithdrawns;
    }

    // Buy Back Records
    struct BuyBack {
        address user;
        uint256 buyBackTime;
        uint256 orderTime;
        SalesType salesType;
        uint8 stage;
        uint256 totalCoin;
        uint256 totalUSD;
    }

    mapping(address => BuyBack[]) private _userBuyBacks;

    // Withdrawns
    struct Withdrawn {
        address user;
        uint256 withdrawnTime;
        address payToken;
        uint256 amount;
    }
    mapping(address => Withdrawn[]) private _userWithdrawns;

    constructor() {
        //_initPayTokens();
        _payTokens.push();
        TransferToChain.push();
        contractManagers[msg.sender] = true;
    }

    modifier onlyContractManagers() {
        require(contractManagers[msg.sender], "?");
        _;
    }

    function setManager(address managerAddress, bool status)
        public
        onlyOwner
        returns (bool)
    {
        require(managerAddress != msg.sender, "??");
        contractManagers[managerAddress] = status;
        return true;
    }

    function setPayToken(
        address tokenAddress,
        string memory name,
        bool valid
    ) external onlyContractManagers returns (bool) {
        require(_isContract(address(tokenAddress)), "!!!");

        ITrustedPayToken trustedPayToken = ITrustedPayToken(
            address(tokenAddress)
        );
        require(trustedPayToken.decimals() == 18, "1e18");

        uint256 ptIndex = _payTokenIndex[tokenAddress];
        if (ptIndex == 0) {
            _payTokens.push(PayToken(name, tokenAddress, 0, 0, valid));
            _payTokenIndex[tokenAddress] = _payTokens.length - 1;
        } else {
            _payTokens[ptIndex].name = name;
            _payTokens[ptIndex].valid = valid;
        }
        return true;
    }

    function getPayTokens() public view returns (PayToken[] memory) {
        return _payTokens;
    }

    struct ActiveStageSummary {
        uint256 timestamp;
        bool preSale;
        bool publicSale;
        uint256 totalCoins;
        uint256 totalSales;
    }

    function getActiveStageSummary()
        public
        view
        returns (ActiveStageSummary memory)
    {
        bool _preSale = false;
        bool _publicSale = false;
        uint256 _stage = 0;
        uint256 _totalCoinsInSale = 0;
        uint256 _totalSalesInSale = 0;

        if (
            preSales[0].saleStartTime <= getBlockTimeStamp() &&
            getBlockTimeStamp() <= preSales[2].saleEndTime
        ) {
            _preSale = true;
            for (uint256 i = 0; i <= 2; i++) {
                _totalCoinsInSale += preSales[i].totalCoins;
                _totalSalesInSale += preSales[i].totalSales;
            }
        }

        if (
            publicSales[0].saleStartTime <= getBlockTimeStamp() &&
            getBlockTimeStamp() <= publicSales[20].saleEndTime
        ) {
            _publicSale = true;
            for (uint256 i = 0; i <= 20; i++) {
                if (
                    publicSales[i].saleStartTime <= getBlockTimeStamp() &&
                    getBlockTimeStamp() <= publicSales[i].saleEndTime
                ) {
                    _stage = i;
                }
                _totalCoinsInSale += publicSales[i].totalCoins;
                _totalSalesInSale += publicSales[i].totalSales;
            }
        }

        ActiveStageSummary memory ass = ActiveStageSummary(
            getBlockTimeStamp(),
            _preSale,
            _publicSale,
            _totalCoinsInSale,
            _totalSalesInSale
        );

        return ass;
    }

    function setPreSaleDetails(uint256 _startTime) public onlyOwner {
        require(preSales.length == 0, "Already");

        uint256 _endTime = _startTime + 30 days;
        //if (totalCoins == 0) totalCoins = 4_800_000;
        uint256 totalCoins = 4_800_000;

        preSales.push(
            PreSale(
                0.040 * 1e18,
                totalCoins * 1e18,
                20_000 * 1e18,
                400_000 * 1e18,
                _startTime,
                _endTime - 1,
                _endTime + 360 days,
                0
            )
        );

        preSales.push(
            PreSale(
                0.055 * 1e18,
                totalCoins * 1e18,
                5_000 * 1e18,
                200_000 * 1e18,
                _startTime,
                _endTime - 1,
                _endTime + 270 days,
                0
            )
        );

        preSales.push(
            PreSale({
                price: 0.070 * 1e18,
                totalCoins: totalCoins * 1e18,
                min: 2_000 * 1e18,
                max: 100_000 * 1e18,
                saleStartTime: _startTime,
                saleEndTime: _endTime - 1,
                unlockTime: _endTime + 180 days,
                totalSales: 0
            })
        );
    }

    function setPublicSaleDetails(uint256 _startTime) public onlyOwner {
        require(publicSales.length == 0, "Already");

        uint256 stage0Coins = 9_600_000;
        uint256 stage1Coins = 5_000_000;

        publicSales.push(
            PublicSale({
                price: 0.10 * 1e18,
                totalCoins: stage0Coins * 1e18,
                min: 500 * 1e18,
                max: 500_000 * 1e18,
                saleStartTime: _startTime,
                saleEndTime: _startTime + 14 days - 1,
                unlockTime: 0, //_startTime + 161 days,
                totalSales: 0
            })
        );

        // stage 1-20
        for (uint256 i = 1; i <= 20; i++) {
            uint256 _totalCoins = stage1Coins * 1e18; //_totalCoins = (stage1Coins - ((i - 1) * coinReduction)) *  1e18;
            uint256 _price = (0.13 * 1e18) + ((i - 1) * (0.02 * 1e18));

            if (i >= 5) {
                _price += (0.02 * 1e18);
            }

            if (i >= 9) {
                _price += (0.03 * 1e18);
            }

            if (i >= 13) {
                _price += (0.04 * 1e18);
            }

            if (i >= 17) {
                _price += (0.05 * 1e18);
            }

            uint256 startTime = _startTime + ((i + 1) * 7 days);

            publicSales.push(
                PublicSale(
                    _price,
                    _totalCoins,
                    100 * 1e18,
                    500_000 * 1e18,
                    startTime,
                    startTime + 7 days - 1,
                    0,
                    0
                )
            );
        }

        uint256 stage20EndTime = publicSales[20].saleEndTime;
        for (uint8 i = 0; i <= 20; i++) {
            publicSales[i].unlockTime = stage20EndTime + ((21 - i) * 1 days);
        }
    }

    function setEndTimeOfStage(uint8 stage, uint256 endTime)
        public
        onlyContractManagers
    {
        _setEndTimeOfStage(stage, endTime);
    }

    function _setEndTimeOfStage(uint8 _stage, uint256 _endTime) internal {
        require(0 <= _stage && _stage <= 20, "invalid");
        require(
            publicSales[_stage].saleEndTime < _endTime &&
                _endTime > publicSales[_stage].saleStartTime,
            "Wrong!"
        );
        publicSales[_stage].saleEndTime = _endTime;
        if (_stage != 20) _setStageTime(_stage + 1);
    }

    // Set stage start and end time after stage 2
    function _setStageTime(uint8 _stage) internal {
        require(_stage >= 1 && _stage <= 20, "invalid");

        uint256 previousStageStartTime = publicSales[_stage - 1].saleStartTime;
        uint256 previousStageEndTime = publicSales[_stage - 1].saleEndTime;

        uint256 previousStageDays = 7 days;
        if (_stage == 1) previousStageDays = 14 days;

        uint256 fixStageTime = previousStageDays -
            (previousStageEndTime - previousStageStartTime);

        fixStageTime -= 1 minutes; // 1 minutes break time :)

        for (uint8 i = _stage; i <= 20; i++) {
            // change start time
            publicSales[i].saleStartTime =
                publicSales[i].saleStartTime -
                fixStageTime;

            // change end time
            publicSales[i].saleEndTime =
                publicSales[i].saleEndTime -
                fixStageTime;
        }
    }

    function depositMoney(uint256 amount, address tokenAddress) external {
        require(_userDeposits[msg.sender].length < 20, "20");
        uint256 blockTimeStamp = getBlockTimeStamp();
        require(blockTimeStamp < publicSales[20].saleEndTime, "??");
        uint256 ptIndex = _payTokenIndex[tokenAddress];
        require(_payTokens[ptIndex].valid, "Dont accept!");

        ITrustedPayToken trustedPayToken = ITrustedPayToken(
            address(tokenAddress)
        );

        require(
            trustedPayToken.allowance(msg.sender, address(this)) >= amount,
            "Allowance!"
        );

        uint256 tokenBalance = trustedPayToken.balanceOf(msg.sender);

        require(tokenBalance >= amount, "no money!");

        trustedPayToken.transferFrom(msg.sender, address(this), amount);

        _getUserIndex(msg.sender); // Get (or Create) UserId

        _totalDepositedUSD += amount; //  All USD token Deposits

        _payTokens[ptIndex].totalDeposit += amount;

        _userInfoByAddress[msg.sender].totalDeposits += amount;

        _userInfoByAddress[msg.sender].balanceUSD += amount; // User USD Balance

        _userDeposits[msg.sender].push(
            Deposit({
                user: msg.sender,
                payToken: tokenAddress,
                amount: amount,
                timestamp: blockTimeStamp
            })
        );
    }

    function buyCoins(
        SalesType salesType,
        uint8 stage,
        uint256 totalUSD
    ) public {
        require(_userInfoByAddress[msg.sender].totalDeposits != 0, "Deposit");
        require(_userPurchases[msg.sender].length < 20, "20");
        require(totalUSD > 1 * 1e18, "Airdrop?");
        require(
            _userInfoByAddress[msg.sender].balanceUSD >= totalUSD,
            "Balance!"
        );

        uint256 blockTimeStamp = getBlockTimeStamp();
        uint256 requestedCoins = 0;
        uint256 coinPrice = 0;
        uint256 unlockTime = 0;
        uint256 purchasedAtThisStage = _purchasedAtThisStage[msg.sender][
            salesType
        ][stage];

        if (salesType == SalesType.PRESALE) {
            // 0 - 1 - 2
            require(0 <= stage && stage <= 2, "wrong");

            PreSale memory pss = preSales[stage];

            // is stage active?
            require(
                pss.saleStartTime <= blockTimeStamp &&
                    blockTimeStamp <= pss.saleEndTime,
                "not active"
            );

            // calculate OXOs for that USD
            // requestedCoins = ((totalUSD * 1e4) / p.price) * 1e14;
            requestedCoins = ((totalUSD) / pss.price) * 1e18;

            totalUSD = (requestedCoins * pss.price) / 1e18;
            // is there enough OXOs?
            require(
                pss.totalCoins - pss.totalSales >= requestedCoins,
                "Not enough"
            );

            // check user's purchases for min/max limits
            require(
                pss.min <= purchasedAtThisStage + requestedCoins &&
                    pss.max >= purchasedAtThisStage + requestedCoins,
                "limits"
            );

            // update preSales Stage purchased OXOs
            preSales[stage].totalSales += requestedCoins;

            coinPrice = pss.price;
            unlockTime = pss.unlockTime;

            _transferableByFoundation += totalUSD;
            buyBackFund += (totalUSD * 80) / 100;
        }

        if (salesType == SalesType.PUBLIC) {
            require(0 <= stage && stage <= 20, "Wrong");

            PublicSale memory pss = publicSales[stage];

            // is stage active?
            require(
                pss.saleStartTime <= blockTimeStamp &&
                    blockTimeStamp <= pss.saleEndTime,
                "not active"
            );

            // calculate OXOs for that USD
            //requestedCoins = ((totalUSD * 1e2) / p.price) * 1e16;
            requestedCoins = ((totalUSD) / pss.price) * 1e18;
            totalUSD = (requestedCoins * pss.price) / 1e18;

            // is there enough OXOs?
            require(
                pss.totalCoins - pss.totalSales >= requestedCoins,
                "Not enough"
            );

            // check user's purchases for min/max limits
            require(
                pss.min <= purchasedAtThisStage + requestedCoins &&
                    purchasedAtThisStage + requestedCoins <= pss.max,
                "limits"
            );

            // update preSales Stage purchased OXOs
            publicSales[stage].totalSales += requestedCoins;

            coinPrice = pss.price;
            unlockTime = pss.unlockTime;

            // %80 for BuyBack - %20 Transferable
            _transferableByFoundation += (totalUSD * 20) / 100;
            buyBackFund += (totalUSD * 80) / 100;
        }

        // Get User Purchases Count
        uint256 userPurchaseCount = _userPurchases[msg.sender].length;

        /// New Purchase Record
        _userPurchases[msg.sender].push(
            Purchase({
                user: msg.sender,
                userPurchaseNonce: userPurchaseCount,
                orderTime: blockTimeStamp,
                orderBlock: block.number,
                salesType: salesType,
                stage: stage,
                coinPrice: coinPrice,
                totalCoin: requestedCoins,
                totalUSD: totalUSD,
                buyBack: false,
                unlockTime: unlockTime
            })
        );

        //_totalSales += totalUSD;

        _userInfoByAddress[msg.sender].totalCoinsFromSales += requestedCoins;

        // UserBalance change
        _userInfoByAddress[msg.sender].balanceUSD -= totalUSD;

        _userInfoByAddress[msg.sender].totalPurchases += totalUSD;

        // Update user's OXOs count for stage
        _purchasedAtThisStage[msg.sender][salesType][stage] =
            purchasedAtThisStage +
            requestedCoins;

        // Mint Tokens
        _mintFromSales(msg.sender, requestedCoins);

        // check available coin amount for stage
        if (salesType == SalesType.PUBLIC) {
            if (
                publicSales[stage].totalCoins - publicSales[stage].totalSales <
                publicSales[stage].min
            ) {
                _setEndTimeOfStage(stage, (blockTimeStamp + 1));
            }
        }

        //emit Purchased(msg.sender, salesType, stage, requestedCoins, totalUSD);

        //return true;
    }

    function requestBuyBack(uint256 userPurchaseNonce) public {
        require(
            _userInfoByAddress[msg.sender].buyBackGuarantee,
            "can not BuyBack!"
        );

        uint256 blockTimeStamp = getBlockTimeStamp();

        require(
            publicSales[20].unlockTime <= blockTimeStamp &&
                blockTimeStamp <= publicSales[20].unlockTime + 90 days,
            "wrong dates!"
        );

        require(
            !_userPurchases[msg.sender][userPurchaseNonce].buyBack &&
                _userPurchases[msg.sender][userPurchaseNonce].totalUSD > 0,
            "???"
        );

        uint256 totalBuyBackCoins = _userPurchases[msg.sender][
            userPurchaseNonce
        ].totalCoin;

        // Calculate USD
        uint256 totalBuyBackUSD = (_userPurchases[msg.sender][userPurchaseNonce]
            .totalUSD * 80) / 100;

        // BuyBacks for User
        _userBuyBacks[msg.sender].push(
            BuyBack({
                user: msg.sender,
                buyBackTime: blockTimeStamp,
                orderTime: _userPurchases[msg.sender][userPurchaseNonce]
                    .orderTime,
                salesType: _userPurchases[msg.sender][userPurchaseNonce]
                    .salesType,
                stage: _userPurchases[msg.sender][userPurchaseNonce].stage,
                totalCoin: totalBuyBackCoins,
                totalUSD: totalBuyBackUSD
            })
        );

        _userPurchases[msg.sender][userPurchaseNonce].buyBack = true;

        _userInfoByAddress[msg.sender].totalBuyBackUSD += totalBuyBackUSD;

        _userInfoByAddress[msg.sender].balanceUSD += totalBuyBackUSD;

        _userInfoByAddress[msg.sender].totalCoinsFromSales -= totalBuyBackCoins;

        _userInfoByAddress[msg.sender].totalBuyBackCoins += totalBuyBackCoins;

        _burnForBuyBack(msg.sender, totalBuyBackCoins);
    }

    function withdrawnMoney() public returns (bool) {
        uint256 amount = _userInfoByAddress[msg.sender].balanceUSD;
        require(amount > 0, "can not Withdrawn!");

        uint256 blockTimeStamp = getBlockTimeStamp();
        bool transfered = false;
        for (uint256 i = 1; i < _payTokens.length; i++) {
            if (!transfered && _payTokens[i].valid) {
                ITrustedPayToken trustedPayToken = ITrustedPayToken(
                    address(_payTokens[i].contractAddress)
                );
                uint256 tokenBalance = trustedPayToken.balanceOf(address(this));
                if (tokenBalance >= amount) {
                    _userInfoByAddress[msg.sender].balanceUSD -= amount;

                    _userInfoByAddress[msg.sender].totalWithdrawns += amount;

                    _userWithdrawns[msg.sender].push(
                        Withdrawn({
                            user: msg.sender,
                            withdrawnTime: blockTimeStamp,
                            payToken: _payTokens[i].contractAddress,
                            amount: amount
                        })
                    );

                    uint256 ptIndex = _payTokenIndex[
                        _payTokens[i].contractAddress
                    ];

                    _payTokens[ptIndex].totalWithdrawn += amount;

                    trustedPayToken.transfer(msg.sender, amount);

                    transfered = true;

                    break;
                }
            }
        }
        return transfered;
    }

    function getUserSummary(address user)
        public
        view
        returns (UserSummary memory)
    {
        UserSummary memory userSummary = UserSummary({
            user: user,
            userDeposits: _userDeposits[user],
            userPurchases: _userPurchases[user],
            userBuyBacks: _userBuyBacks[user],
            userWithdrawns: _userWithdrawns[user]
        });
        return userSummary;
    }

    function _blockTimeStamp() public view returns (uint256) {
        return block.timestamp;
    }

    uint256 private testingTimeStamp = 0;

    // function forTesting_BlockTimeStamp(uint256 _testingTimeStamp)
    //     public
    //     onlyContractManagers
    // {
    //     testingTimeStamp = _testingTimeStamp;
    // }

    function getBlockTimeStamp() public view returns (uint256) {
        if (testingTimeStamp != 0) return testingTimeStamp;
        return block.timestamp;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function transferToChain(uint256 chainId, uint256 amount) public {
        uint256 balance = balanceOf(msg.sender);
        require(amount <= balance, "Houston!");
        _burn(msg.sender, amount);
        uint256 nonce = TransferToChain.length;
        TransferToChain.push(
            TransferChain({
                user: msg.sender,
                chainId: chainId,
                amount: amount,
                nonce: nonce
            })
        );
        TransferToChainLatest = nonce;
    }

    function mint(address to, uint256 amount) public onlyContractManagers {
        _mint(to, amount);
    }

    function transfer(address to, uint256 amount)
        public
        override
        returns (bool)
    {
        // Check Locked Coins
        require(amount <= balanceOf(msg.sender), "Houston!");
        _cancelBuyBackGuarantee();
        return super.transfer(to, amount);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        // Check Locked Coins
        require(amount <= balanceOf(from), "Houston!");
        _cancelBuyBackGuarantee();
        return super.transferFrom(from, to, amount);
    }

    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal override whenNotPaused {
        require(balanceOf(_from) >= _amount, "balance is not enough!");
        super._beforeTokenTransfer(_from, _to, _amount);
    }

    function _cancelBuyBackGuarantee() internal {
        if (_userInfoByAddress[msg.sender].buyBackGuarantee) {
            _userInfoByAddress[msg.sender].buyBackGuarantee = false;

            if (
                publicSales[20].unlockTime < getBlockTimeStamp() &&
                getBlockTimeStamp() <= publicSales[20].unlockTime + 90 days
            ) {
                Purchase[] memory up = _userPurchases[msg.sender];
                for (uint256 i = 0; i < up.length; i++) {
                    if (up[i].salesType == SalesType.PUBLIC && !up[i].buyBack) {
                        _transferableByFoundation +=
                            (up[i].totalUSD * 80) /
                            100;
                        buyBackFund -= (up[i].totalUSD * 80) / 100;
                    }
                }
            }
        }
    }

    function balanceOf(address who) public view override returns (uint256) {
        return
            super.balanceOf(who) - _checkLockedCoins(who, getBlockTimeStamp());
    }

    function balanceOfAt(address who, uint256 blockTimeStamp)
        public
        view
        returns (uint256)
    {
        return super.balanceOf(who) - _checkLockedCoins(who, blockTimeStamp);
    }

    /** Calculate */
    function _checkLockedCoins(address _who, uint256 blockTimeStamp)
        internal
        view
        returns (uint256)
    {
        uint256 uIndex = _userIndex[_who];
        if (uIndex == 0) {
            return 0;
        }

        // /// All coins free
        if (preSales[0].unlockTime + 10 days < blockTimeStamp) {
            return 0;
        }

        // /// All coins locked before end of Public Sales
        if (blockTimeStamp <= publicSales[20].unlockTime) {
            return _userInfoByAddress[_who].totalCoinsFromSales;
        }

        // Check user purchases history
        Purchase[] memory userPurchases = _userPurchases[_who];
        uint256 lockedCoins = 0;
        for (uint256 i = 0; i < userPurchases.length; i++) {
            if (!userPurchases[i].buyBack) {
                // unlock time has not pass
                if (
                    userPurchases[i].salesType == SalesType.PRESALE &&
                    blockTimeStamp < preSales[userPurchases[i].stage].unlockTime
                ) {
                    lockedCoins += userPurchases[i].totalCoin;
                }

                // unlock time has not pass
                if (
                    userPurchases[i].salesType == SalesType.PUBLIC &&
                    blockTimeStamp <
                    publicSales[userPurchases[i].stage].unlockTime
                ) {
                    lockedCoins += userPurchases[i].totalCoin;
                }

                // 10 days vesting for PreSale
                if (
                    userPurchases[i].salesType == SalesType.PRESALE &&
                    (preSales[userPurchases[i].stage].unlockTime <
                        blockTimeStamp &&
                        blockTimeStamp <
                        preSales[userPurchases[i].stage].unlockTime + 10 days)
                ) {
                    lockedCoins += _vestingCalculator(
                        preSales[userPurchases[i].stage].unlockTime,
                        userPurchases[i].totalCoin,
                        10,
                        blockTimeStamp
                    );
                }

                // 25 days vesting for PublicSale
                if (
                    userPurchases[i].salesType == SalesType.PUBLIC &&
                    (publicSales[userPurchases[i].stage].unlockTime <
                        blockTimeStamp &&
                        blockTimeStamp <
                        publicSales[userPurchases[i].stage].unlockTime +
                            25 days)
                ) {
                    lockedCoins += _vestingCalculator(
                        publicSales[userPurchases[i].stage].unlockTime,
                        userPurchases[i].totalCoin,
                        25,
                        blockTimeStamp
                    );
                }
            }
        }

        return lockedCoins;
    }

    function _vestingCalculator(
        uint256 _unlockTime,
        uint256 _totalCoin,
        uint256 _vestingDays,
        uint256 blockTimeStamp
    ) internal pure returns (uint256) {
        uint256 pastDays = 0;
        uint256 _lockedCoins = 0;
        uint256 pastTime = blockTimeStamp - _unlockTime;

        if (pastTime <= 1 days) {
            pastDays = 1;
        } else {
            pastDays = ((pastTime - (pastTime % 1 days)) / 1 days) + 1;
            if (pastTime % 1 days == 0) {
                pastDays -= 1;
            }
        }

        if (pastDays >= 1 && pastDays <= _vestingDays) {
            _lockedCoins +=
                (_totalCoin * (_vestingDays - pastDays)) /
                _vestingDays;
        }

        return _lockedCoins;
    }

    function changeSafeWallet(address walletAddress) public onlyOwner {
        SAFE_WALLET = walletAddress;
    }

    function transferTokensToSafeWallet(address tokenAddress)
        external
        onlyContractManagers
    {
        require(_isContract(address(tokenAddress)), "Houston!");

        uint256 blockTimeStamp = getBlockTimeStamp();

        ITrustedPayToken trustedPayToken = ITrustedPayToken(
            address(tokenAddress)
        );

        uint256 tokenBalance = trustedPayToken.balanceOf(address(this));

        uint256 transferable = tokenBalance;
        uint256 ptIndex = _payTokenIndex[tokenAddress];

        if (_payTokens[ptIndex].valid) {
            transferable =
                _transferableByFoundation -
                _totalTranferredToFoundation;

            if (publicSales[20].unlockTime + 90 days < blockTimeStamp) {
                transferable = tokenBalance;
            }

            if (tokenBalance < transferable) transferable = tokenBalance;
            _totalTranferredToFoundation += transferable;

            _payTokens[ptIndex].totalWithdrawn =
                _payTokens[ptIndex].totalWithdrawn +
                transferable;
        }

        trustedPayToken.transfer(SAFE_WALLET, transferable);
    }

    function transferCoinsToSafeWallet() external onlyContractManagers {
        payable(SAFE_WALLET).transfer(address(this).balance);
    }

    function _getUserIndex(address _user) internal returns (uint256) {
        uint256 uIndex = _userIndex[_user];
        if (uIndex == 0) {
            allUsers.push(_user);
            uIndex = allUsers.length;
            _userIndex[_user] = uIndex;
            _userInfoByAddress[_user].user = _user;
            _userInfoByAddress[_user].buyBackGuarantee = true;
        }
        return uIndex;
    }

    function _isContract(address _account) internal view returns (bool) {
        return _account.code.length > 0;
    }
}