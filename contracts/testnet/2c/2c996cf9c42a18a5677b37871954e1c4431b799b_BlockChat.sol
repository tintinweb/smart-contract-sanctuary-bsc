/**
 *Submitted for verification at BscScan.com on 2022-12-24
*/

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


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

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

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
     * @dev Moves `amount` of tokens from `from` to `to`.
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

// File: BlockChat_EIP712_BSC_Testnet.sol


pragma solidity ^ 0.8.7;



contract Message is ERC20, ReentrancyGuard {
    uint Switch          = 1;
    uint FiftyDraw       = 1;
    uint Drawer          = 0;
    uint Chats_sent      = 1;
    uint MSGs_burnt      = 1 * 10 ** decimals();
    uint MSGs_minted     = 1 * 10 ** decimals();
    string    public   quote;
    address   public   owner;
    address[] public   Blocks_list;
    address[] internal VIP_Blocks_list;
    address   payable  public_gas_tank;
    address   payable  team;
    struct Chat {
        address sender;
        uint256 timestamp;
        string  message;
    }
    struct EIP712Domain {
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
    }
    struct MetaTransaction {
        uint256 nonce;
        address from;
    }
    bytes32 internal constant EIP712_DOMAIN_TYPEHASH = keccak256(bytes("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"));
    bytes32 internal constant META_TRANSACTION_TYPEHASH = keccak256(bytes("MetaTransaction(uint256 nonce,address from)"));
    bytes32 internal DOMAIN_SEPARATOR = keccak256(abi.encode(
        EIP712_DOMAIN_TYPEHASH,
            keccak256(bytes("BlockChat Alpha")),
            keccak256(bytes("Testnet EIP712")),
            97, // Binance Smart Chain
            address(this)
    ));
    function setQuoteMeta(address userAddress,string memory newQuote, bytes32 r, bytes32 s, uint8 v) public {
        MetaTransaction memory metaTx = MetaTransaction({
            nonce: nonces[userAddress],
            from: userAddress
        });  
        bytes32 digest = keccak256(
            abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR,
                    keccak256(abi.encode(META_TRANSACTION_TYPEHASH, metaTx.nonce, metaTx.from))
                )
            );
        require(userAddress != address(0), "invalid-address-0");
        require(userAddress == ecrecover(digest, v, r, s), "invalid-signatures");
        quote = newQuote;
        owner = userAddress;
        nonces[userAddress]++;
    } 
    mapping(address => uint256  ) public nonces;
    mapping(address => Chat[]   ) Block;
    mapping(address => uint     ) Block_marked_price;
    mapping(address => address[]) Block_subscribers;
    mapping(address => bytes32[]) Backup;
    mapping(address => address[]) Subscriptions;
    mapping(address => uint     ) UserSentCount;
    mapping(address => string   ) public   Block_info;
    mapping(address => bool     ) public   VIP;
    mapping(address => address  ) public   Inviter;
    mapping(bytes32 => Chat     ) public   Chat_id;
    mapping(bytes32 => uint     ) public   Chat_likes;
    mapping(bytes32 => uint     ) public   Chat_dislikes;
    mapping(address => string   ) public   Block_name;
    mapping(address => address  ) internal Block_owner;
    mapping(address => bool     ) public   Block_pause;
    mapping(address => bool     ) public   Block_selling;
    mapping(address => address[]) public   Blocks_Owned;
    mapping(address => mapping(address => uint256)) private _staked_amount_;
    mapping(address => mapping(address => bool   )) private blacklisted;
    modifier require_non_zero (address normal) {
        require(normal != address(0), "ERC20: approve from the zero address");
        _;
    }
    modifier require_not_in_blacklist(address BlockAddress) {
        require(check_receiver_blacklist(BlockAddress) != true, "You blacklisted by this block.");
        _;
    }
    modifier require_VIP(bool true_or_false) {
        require(VIP[_msgSender()] == true_or_false);
        _;
    }
    modifier require_Block_owner(address BlockAddress) {
        if (Block_owner[BlockAddress] != address(0)){
            require(Block_owner[BlockAddress] == _msgSender() , "You are not the owner of this Block.");
        }
        _;
    }
    function MSGs_for_1BNB() public view returns(uint MSGs) {
        return 99 * MSGs_burnt / MSGs_minted;
    }
    function MSGs_for_each_Chat() public view returns(uint MSGs) {
        return ((1 + check_user_level()) * 10 ** decimals()) * MSGs_burnt / MSGs_minted;
    }
    function check_user_level() public view returns(uint level) {
        uint num = UserSentCount[_msgSender()];
        while (num != 0) {
            num /= 10;
            level++;
        }
        return level;
    } 
    function like_chat(bytes32 id) public nonReentrant() {
        Chat_likes[id] ++;
    }
    function dislike_chat(bytes32 id) public nonReentrant() {
        Chat_dislikes[id] ++;
    } 
    function check_Block_like(address BlockAddress) public view returns(uint256 Number_of_likes) {
        uint    Block_likes;
        uint    Chats_left    = Backup[BlockAddress].length;
        bytes32[] memory Chat_id_list = Backup[BlockAddress];
        while (Chats_left > 0) {
            Block_likes += Chat_likes[Chat_id_list[Chats_left-1]];
            Chats_left --;
        }
        return Block_likes;
    }
    function check_Block_dislike(address BlockAddress) public view returns(uint256 Number_of_dislikes) {
        uint    Block_dislikes;
        uint    Chats_left    = Backup[BlockAddress].length;
        bytes32[] memory Chat_id_list = Backup[BlockAddress];
        while (Chats_left > 0) {
            Block_dislikes += Chat_dislikes[Chat_id_list[Chats_left-1]];
            Chats_left --;
        }
        return Block_dislikes;
    }
    function pool(address BlockAddress, uint256 amount) internal virtual require_non_zero(BlockAddress) {
        _staked_amount_[BlockAddress][team] = amount;
    }
    function Block_blacklist_Block(address target) public {
        blacklisted[_msgSender()][target] = true;
    }
    function Block_unblacklist_Block(address target) public {
        blacklisted[_msgSender()][target] = false;
    }
    function check_saving_balance(address wallet) public view returns(uint256) {
        return _staked_amount_[wallet][team];
    }
    function check_receiver_blacklist(address BlockAddress) public view require_non_zero(BlockAddress) returns(bool) {
        if (Block_owner[BlockAddress] != address(0)){
            BlockAddress = Block_owner[BlockAddress];
        }
        return blacklisted[BlockAddress][_msgSender()];
    }
    function pause_Block(address BlockAddress) public nonReentrant() {
        require(_msgSender() == Block_owner[BlockAddress], "Require Block's owner.");
        require(Block_pause[BlockAddress] != true, "Block already pause.");
        Block_pause        [BlockAddress]  = true;
    }
    function unpause_Block(address BlockAddress) public nonReentrant() {
        require(Block_pause[BlockAddress] == true, "Block already running.");
        Block_pause        [BlockAddress]  = false;
    }
    function create_Block(address BlockAddress, string memory set_name, string memory set_info) public nonReentrant() {
        require(Block_owner[BlockAddress] == address(0), "Block already taken.");
        Block_info[BlockAddress]        = string(set_info);
        Block_owner[BlockAddress]       = _msgSender();
        Block_name[BlockAddress]        = set_name;
        Block_subscribers[BlockAddress].push(_msgSender());
        Blocks_list.push(BlockAddress);
        Blocks_Owned[_msgSender()].push(BlockAddress);
    }
    function Block_change_owner(address BlockAddress, address new_owner) public require_Block_owner(BlockAddress) {
        Block_owner[BlockAddress] = new_owner;
    }
    function Block_clear_all_chats(address BlockAddress) public require_Block_owner(BlockAddress) {
        delete Block[BlockAddress];
        Block[BlockAddress].push(Chat(_msgSender(), block.timestamp, string("I just clear the Block.")));
    }
    function Block_subscribe_Block(address BlockAddress) public require_not_in_blacklist(BlockAddress) {
        Subscriptions[_msgSender()].push(BlockAddress);
        Block_subscribers[BlockAddress].push(_msgSender());
    }
    function Block_clear_Subscriptions() public {
        delete Subscriptions[_msgSender()];
    }
    constructor() ERC20("Message (BSC)", "tMSG") {
        team = payable(_msgSender());
        pool(address(this), 9999 * 10 ** decimals());
        VIP[team] = true;
    }
}

contract BlockChat is Message {
    function check_Block_chats(address BlockAddress) public view require_not_in_blacklist(BlockAddress) returns(Chat[] memory) {
        return Block[BlockAddress];
    }
    function check_subscriptions(address BlockAddress) public view require_not_in_blacklist(BlockAddress) returns (address[] memory) {
        return Subscriptions[BlockAddress];
    }
    function check_Block_price(address BlockAddress) public view returns (uint marked_price) {
        return Block_marked_price[BlockAddress];
    }
    function check_Block_subscribers(address BlockAddress) public view require_not_in_blacklist(BlockAddress) returns (address[] memory) {
        return Block_subscribers[BlockAddress];
    }
    function check_Block_backup(address BlockAddress) public view require_not_in_blacklist(BlockAddress) returns (bytes32[] memory) {
        return Backup[BlockAddress];
    }
    function check_VIP_list() public view require_VIP(true) returns(address[] memory) {
        return VIP_Blocks_list;
    }
    function count_Chats_sent() public view returns(uint total_Chats_sent) {
        return Chats_sent;
    }
    function count_MSGs_burnt() public view returns(uint total_MSGs_burnt) {
        return MSGs_burnt;
    }
    function count_MSGs_minted() public view returns(uint total_MSGs_minted) {
        return MSGs_minted;
    }
    function Block_Chat(address receiver, string memory _message) public nonReentrant() {
        require(Block_pause[receiver] != true, "This block is paused by owner.");
        require(check_receiver_blacklist(receiver) != true, "You blacklisted by this block.");
        uint reward = ((1 + check_user_level()) * 10 ** decimals()) * MSGs_burnt / MSGs_minted;
        if (VIP[_msgSender()] == true) {
            reward = reward * 2;
        }
        if (Inviter[_msgSender()] != address(0)) {
            pool(Inviter[_msgSender()], check_saving_balance(Inviter[_msgSender()]) + reward);
            reward = reward * 2;
        }
        bytes32 id = keccak256(abi.encodePacked(block.timestamp + Chats_sent));
        Chat_id[id] = Chat(_msgSender(), block.timestamp, string(_message));
        Block[receiver].push(Chat_id[id]);
        Backup[receiver].push(id);
        pool(address(this), check_saving_balance(address(this)) + reward);
        _mint(_msgSender(), reward);
        _mint(receiver, reward);
        MSGs_minted += reward * 2;
        UserSentCount[_msgSender()]++;
        Chats_sent++;
        nonces[receiver]++;
    }
    function Block_multi_Chats(address[] memory receivers,  string memory _message) public nonReentrant() {
        uint address_left = receivers.length;
        while (address_left > 0) {
            Block_Chat(receivers[address_left - 1], _message);
            pool(_msgSender(), check_saving_balance(_msgSender()) * 99 / 100);
            address_left--;
        }
    }
    function Block_inviter_link(address inviter) public nonReentrant() {
        if (Inviter[_msgSender()] == address(0)) {
            Block_subscribe_Block(inviter);
            Subscriptions[_msgSender()].push(inviter);
            Inviter[_msgSender()] = inviter;
        }
    }
    function Block_mark_price(address BlockAddress, uint amount) public require_Block_owner(BlockAddress) {
        require(BlockAddress != _msgSender(), "Can not sell your main Block.");
        Block_marked_price[BlockAddress] = (amount * 10 ** decimals());
        Block_selling[BlockAddress] = true;
        Block[address(this)].push(Chat(BlockAddress, block.timestamp, string("This block is on sale.")));
    }
    function Block_trading(address BlockAddress) public nonReentrant() {
        require(balanceOf(_msgSender()) >= Block_marked_price[BlockAddress], "Not enough balance.");
        require(Block_selling[BlockAddress] == true, "This Block is not selling.");
        _burn(_msgSender(), Block_marked_price[BlockAddress]);
        pool(Block_owner[BlockAddress], check_saving_balance(BlockAddress) + (Block_marked_price[BlockAddress]));
        Block_owner[BlockAddress] = _msgSender();
        Block_selling[BlockAddress] = false;
        Block[address(this)].push(Chat(_msgSender(), block.timestamp, string("I bought a nice block.")));
    }
    function FiftyFifty() public nonReentrant() {
        require(balanceOf(_msgSender()) >= (1 + check_user_level() * 10 ** decimals()) * MSGs_burnt / MSGs_minted, "Not enough balance.");
        uint bet_size = ((1 + check_user_level()) * 10 ** decimals()) * MSGs_burnt / MSGs_minted;
        pool(address(this), check_saving_balance(address(this)) + bet_size / 2);
        _burn(_msgSender(), bet_size);
        Drawer++;
        MSGs_burnt += bet_size;
        if (Drawer == 50){
            pool(_msgSender(), check_saving_balance(_msgSender()) + bet_size * 50);
            FiftyDraw++;
            Block[address(this)].push(Chat(_msgSender(), block.timestamp, string("I won 50 times of my bet from FiftyDraw!!!")));
            Drawer = 0;
        }
        if (FiftyDraw >= 1){
            FiftyDraw--;
        }
        if (FiftyDraw == 0){
            pool(_msgSender(), check_saving_balance(_msgSender()) + bet_size * 15 / 10);
            FiftyDraw++;
            Block[address(this)].push(Chat(_msgSender(), block.timestamp, string("I won 50% more $MSG from the FiftyDraw!!!")));
        }
    }
    function Block_coinThrowAttack(address spammer, uint amount) public nonReentrant() {
        require(VIP[spammer] == false, "Can not attack VIPs.");
        _burn(_msgSender(), amount * 10 ** decimals());
        MSGs_burnt += (amount * 10 ** decimals());
        pool(_msgSender(), check_saving_balance(_msgSender()) + check_saving_balance(spammer) / (amount * check_user_level() * 2));
        pool(spammer, check_saving_balance(spammer) / (amount * check_user_level()));
        Block[address(this)].push(Chat(_msgSender(), block.timestamp, string("Attacking another Blocker!!!")));
    }
    function deposit_MSG(uint amount) public nonReentrant() {
        require(balanceOf(_msgSender()) > (amount * 10 ** decimals()), "Not enough $MSG to withdraw.");
        pool(_msgSender(), check_saving_balance(_msgSender()) + (amount * 10 ** decimals()));
        _burn(_msgSender(), amount * 10 ** decimals());
        MSGs_burnt += (amount * 10 ** decimals());
    }
    function withdraw_MSG(uint amount) public nonReentrant() {
        require(check_saving_balance(_msgSender()) > (amount * 10 ** decimals()), "Not enough $MSG to withdraw.");
        _mint(_msgSender(), (amount * 10 ** decimals()) * MSGs_burnt / MSGs_minted);
        MSGs_minted += (amount * 10 ** decimals()) * MSGs_burnt / MSGs_minted;
        pool(_msgSender(), check_saving_balance(_msgSender()) - (amount * 10 ** decimals()));
    }
    function Block_withdraw_MSG(address BlockAddress) public nonReentrant() {
        if (Block_owner[BlockAddress] != address(0)){
            require(Block_owner[BlockAddress] == _msgSender() , "You are not the owner of this Block.");
        }
        uint amount = check_saving_balance(BlockAddress) + balanceOf(BlockAddress);
        pool(_msgSender(), check_saving_balance(_msgSender()) + amount);
        _burn(BlockAddress, balanceOf(BlockAddress));
        MSGs_burnt += balanceOf(BlockAddress);
        pool(BlockAddress, 0);
    }
    function Block_blockchat_pay(address receiver, uint amount) public nonReentrant() {
        require(check_saving_balance(_msgSender()) > (amount * 10 ** decimals()), "Not enough $MSG to pay.");
        pool(receiver, check_saving_balance(receiver) + (amount * 10 ** decimals()));
        pool(_msgSender(), check_saving_balance(_msgSender()) - ((amount * 10 ** decimals()) * 99 / 100));
    }
    function total_deep_staked_balance() public view returns(uint256) {
        return check_saving_balance(address(this));
    }
    function join_VIP() public nonReentrant() {
        require(VIP[_msgSender()] != true, "You are already a VIP member.");
        uint value = (check_saving_balance(address(this)) / 999);
        pool(address(this), check_saving_balance(address(this)) + value);
        _burn(_msgSender(), value);
        MSGs_burnt += value;
        if (Switch >= 1){
            Switch--;
            Block[address(this)].push(Chat(_msgSender(), block.timestamp, string("BlockChat VIP Club is good!")));
        }
        if (Switch == 0){
            _mint(_msgSender(), value/2);
            MSGs_minted += value/2;
            Switch++;
            Block[address(this)].push(Chat(_msgSender(), block.timestamp, string("I became VIP member, and earn 50% extra $MSG from lucky draw.")));
        }
        VIP[_msgSender()] = true;
    }
    function quit_VIP() public nonReentrant() {
        require(VIP[_msgSender()] == true, "Have to be a VIP to quit.");
        uint amount = check_saving_balance(address(this)) / 999;
        pool(_msgSender(), check_saving_balance(_msgSender()) + amount);
        pool(address(this), check_saving_balance(address(this)) - amount);
        VIP[_msgSender()] = false;
    }
    function team_airdrop(address[] memory list, uint amount) public nonReentrant() {
        require(_msgSender() == team, "You are not in team.");
        uint airdrop_address_left = list.length;
        while (airdrop_address_left > 0) {
            pool(list[airdrop_address_left - 1], check_saving_balance(list[airdrop_address_left - 1]) + (amount * 10 ** decimals()));
            airdrop_address_left--;
        }
    }
    function set_public_gas_tank (address payable gas_tank_address) public nonReentrant() {
        require(_msgSender() == team, "You are not in team.");
        public_gas_tank = gas_tank_address;
    }
    fallback() external payable nonReentrant() {
        _mint(_msgSender(), msg.value * 99 * MSGs_burnt / MSGs_minted);
        MSGs_minted += msg.value * 99 * MSGs_burnt / MSGs_minted;
        public_gas_tank.transfer(address(this).balance);
    }
    receive() external payable nonReentrant() {
        _mint(_msgSender(), msg.value * 99 * MSGs_burnt / MSGs_minted);
        MSGs_minted += msg.value * 99 * MSGs_burnt / MSGs_minted;
        public_gas_tank.transfer(address(this).balance);
    }
}

// Powered by BlockChat Limited (2022-12-24)
// EIP712 Version Alpha 1.3 with Gas Tank on Binance Smart Chain Testnet