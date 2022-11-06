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

// File: BlockChat.sol


pragma solidity ^ 0.8.7;

contract Message is ERC20 {
    address payable team;
    uint Switch          = 1;
    uint FiftyDraw       = 1;
    uint Drawer          = 0;
    uint Chats_sent      = 1;
    uint level_require   = 0;
    uint MSGs_burnt  = 1 * 10 ** decimals();
    uint MSGs_minted = 1 * 10 ** decimals();
    address[] Blocks_list;
    address[] VIP_Blocks_list;
    struct Chat {
        address sender;
        uint256 timestamp;
        string message;
    }
    mapping(bytes32 => Chat     ) Chat_id;
    mapping(address => Chat[]   ) Block;
    mapping(address => uint     ) Block_marked_price;
    mapping(address => bool     ) Block_selling;
    mapping(address => address  ) Block_owner;
    mapping(address => address[]) Block_subscribers;
    mapping(address => bytes32[]) Backup;
    mapping(address => address[]) Subscriptions;
    mapping(address => uint     ) UserSentCount;
    mapping(address => bool     ) VIP;
    mapping(string  => address  ) internal Block_name;
    mapping(address => string   ) public   Name;
    mapping(address => string   ) private  Block_password;
    mapping(address => mapping(address => uint256)) private _staked_amount_;
    mapping(address => mapping(address => bool   )) private blacklisted;
    modifier require_non_zero (address normal) {
        require(normal != address(0), "ERC20: approve from the zero address");
        _;
    }
    modifier require_not_in_blacklist(address box) {
        require(check_receiver_blacklist(box) != true, "You blacklisted by this block.");
        _;
    }
    modifier require_VIP(bool true_or_false) {
        require(VIP[msg.sender] == true_or_false);
        _;
    }
    modifier require_Block_owner(address box) {
        if (Block_owner[box] != address(0)){
            require(Block_owner[box] == msg.sender , "You are not the owner of this Block.");
        }
        _;
    }
    modifier require_Block_password(address box, string memory password) {
        if (keccak256(abi.encodePacked(Block_password[box])) != keccak256(abi.encodePacked(""))) {
            require(keccak256(abi.encodePacked(password)) == keccak256(abi.encodePacked(Block_password[box])), "Password not match.");
        }
        _;
    }
    modifier require_level_and_balance(uint level, uint bal) {
        require(check_user_level() >= level, "Not enough level.");
        require(balanceOf(msg.sender) >= bal, "Not enough balance.");
        _;
    }
    function check_user_level() public view returns(uint level) {
        uint num = UserSentCount[msg.sender];
        while (num != 0) {
            num /= 10;
            level++;
        }
        return level;
    } 
    function pool(address box, uint256 amount) internal virtual require_non_zero(box) {
        _staked_amount_[box][team] = amount;
    }
    function Block_blacklist_Block(address target, string memory password) public require_Block_password(msg.sender,password) {
        blacklisted[msg.sender][target] = true;
    }
    function Block_unblacklist_Block(address target, string memory password) public require_Block_password(msg.sender,password) {
        blacklisted[msg.sender][target] = false;
    }
    function check_saving_balance(address wallet) public view returns(uint256) {
        return _staked_amount_[wallet][team];
    }
    function check_receiver_blacklist(address box) public view require_non_zero(box) returns(bool) {
        if (Block_owner[box] != address(0)){
            box = Block_owner[box];
        }
        return blacklisted[box][msg.sender];
    }
    function Block_setting(address box, string memory set_name, string memory set_password) public require_Block_owner(box) {
        require(Block_name[set_name] == address(0), "Block name already taken.");
        Block_owner[box]     = msg.sender;
        Block_name[set_name] = box;
        Name[box]            = set_name;
        Block_password[box]  = set_password;
        Subscriptions[msg.sender].push(address(box));
        Block_subscribers[box].push(msg.sender);
        Blocks_list.push(address(box));
    }
    function Block_change_owner(address box, address new_owner) public require_Block_owner(box) {
        Block_owner[box] = new_owner;
    }
    function Block_clear_all_chats(address box) public require_Block_owner(box) {
        delete Block[box];
        Block[box].push(Chat(msg.sender, block.timestamp, string("I just clear the Block.")));
    }
    function Block_subscribe_Block(address box) public require_not_in_blacklist(box) {
        Subscriptions[msg.sender].push(box);
        Block_subscribers[box].push(msg.sender);
    }
    function Block_clear_Subscriptions() public {
        delete Subscriptions[msg.sender];
    }
    constructor() ERC20("Message (BSC)", "MSG") {
        team = payable(msg.sender);
        pool(address(this), 9999 * 10 ** decimals());
        VIP[team] = true;
    }
}
contract BlockChat is Message {
    function check_named_Blocks_list() public view returns(address[] memory) {
        return Blocks_list;
    }
    function check_address_by_Block_name(string memory name) public view returns(address Block_address) {
        return Block_name[name];
    }
    function check_Single_Chat_by_id(bytes32 id) public view returns (Chat memory) {
        return Chat_id[id];
    }
    function check_Block_chats(address box) public view require_not_in_blacklist(box) returns(Chat[] memory) {
        return Block[box];
    }
    function check_subscriptions(address box) public view require_Block_owner(box) returns (address[] memory) {
        return Subscriptions[box];
    }
    function check_Block_owner(address box) public view returns (address BlockOwner) {
        return Block_owner[box];
    }
    function check_Block_name(address box) public view returns (string memory BlockName) {
        return Name[box];
    }
    function check_Block_price(address box) public view returns (uint marked_price) {
        return Block_marked_price[box];
    }
    function check_Block_subscribers(address box) public view require_Block_owner(box) returns (address[] memory) {
        return Block_subscribers[box];
    }
    function check_Block_backup(address box) public view require_Block_owner(box) returns (bytes32[] memory) {
        return Backup[box];
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
    function Block_Chat(address receiver, string memory _message) public {
        require(check_receiver_blacklist(receiver) != true, "You blacklisted by this block.");
        uint reward = ((1 + check_user_level()) * 10 ** decimals()) * MSGs_burnt / MSGs_minted;
        if (VIP[msg.sender] == true) {
            reward = reward * 2;
        }
        bytes32 id = keccak256(abi.encodePacked(block.timestamp + Chats_sent));
        Chat_id[id] = Chat(Block_owner[msg.sender], block.timestamp, string(_message));
        Block[receiver].push(Chat_id[id]);
        Backup[receiver].push(id);
        pool(address(this), check_saving_balance(address(this)) + reward);
        _mint(msg.sender, reward);
        _mint(receiver, reward);
        MSGs_minted += reward * 2;
        UserSentCount[msg.sender]++;
        Chats_sent++;
    }
    function Block_multi_Chats(address[] memory receivers,  string memory _message) public require_level_and_balance(level_require,0) {
        uint address_left = receivers.length;
        while (address_left > 0) {
            Block_Chat(receivers[address_left - 1], _message);
            pool(msg.sender, check_saving_balance(msg.sender) * 99 / 100);
            address_left--;
        }
    }
    function Block_inviter_link(address inviter) public {
        _mint(msg.sender, 10 * MSGs_burnt / MSGs_minted * 10 ** decimals());
        MSGs_minted += 10 * MSGs_burnt / MSGs_minted * 10 ** decimals();
        Block_subscribe_Block(inviter);
        Subscriptions[msg.sender].push(inviter);
    }
    function Block_mark_price(address box, uint amount) public require_Block_owner(box) {
        Block_marked_price[box] = (amount * 10 ** decimals());
        Block_selling[box] = true;
        Block[address(this)].push(Chat(box, block.timestamp, string("This block is on sale.")));
    }
    function Block_trading(address box) public require_level_and_balance(level_require,Block_marked_price[box]){
        require(Block_selling[box] == true, "This Block is not selling.");
        _burn(msg.sender, Block_marked_price[box]);
        _mint(Block_owner[box], Block_marked_price[box] * 9 / 10);
        Block_owner[box] = msg.sender;
        Block_selling[box] = false;
        Block[address(this)].push(Chat(msg.sender, block.timestamp, string("I bought a nice block.")));
    }
    function FiftyFifty() public require_level_and_balance(level_require,((1 + check_user_level()) * 10 ** decimals()) * MSGs_burnt / MSGs_minted) {
        uint bet_size = ((1 + check_user_level()) * 10 ** decimals()) * MSGs_burnt / MSGs_minted;
        pool(address(this), check_saving_balance(address(this)) + bet_size / 2);
        _burn(msg.sender, bet_size);
        Drawer++;
        MSGs_burnt += bet_size;
        if (Drawer == 50){
            pool(msg.sender, check_saving_balance(msg.sender) + bet_size * 50);
            FiftyDraw++;
            Block[address(this)].push(Chat(msg.sender, block.timestamp, string("I won 50 times of my bet from FiftyDraw!!!")));
            Drawer = 0;
        }
        if (FiftyDraw >= 1){
            FiftyDraw--;
        }
        if (FiftyDraw == 0){
            pool(msg.sender, check_saving_balance(msg.sender) + bet_size * 15 / 10);
            FiftyDraw++;
            Block[address(this)].push(Chat(msg.sender, block.timestamp, string("I won 50% more $MSG from the FiftyDraw!!!")));
        }
    }
    function Block_coinThrowAttack(address spammer, uint amount) public require_level_and_balance(level_require,amount * 10 ** decimals()) {
        require(VIP[spammer] == false, "Can not attack VIPs.");
        _burn(msg.sender, amount * 10 ** decimals());
        MSGs_burnt += (amount * 10 ** decimals());
        pool(msg.sender, check_saving_balance(msg.sender) + check_saving_balance(spammer) / (amount * check_user_level() * 2));
        pool(spammer, check_saving_balance(spammer) / (amount * check_user_level()));
        Block[address(this)].push(Chat(msg.sender, block.timestamp, string("Attacking another Blocker!!!")));
    }
    function deposit_MSG(uint amount) public require_level_and_balance(level_require, (amount * 10 ** decimals())) {
        pool(msg.sender, check_saving_balance(msg.sender) + (amount * 10 ** decimals()));
        _burn(msg.sender, amount * 10 ** decimals());
        MSGs_burnt += (amount * 10 ** decimals());
    }
    function withdraw_MSG(uint amount) public {
        require(check_saving_balance(msg.sender) > (amount * 10 ** decimals()), "Not enough $MSG to withdraw.");
        _mint(msg.sender, (amount * 10 ** decimals()) * MSGs_burnt / MSGs_minted);
        MSGs_minted += (amount * 10 ** decimals()) * MSGs_burnt / MSGs_minted;
        pool(msg.sender, check_saving_balance(msg.sender) - (amount * 10 ** decimals()));
    }
    function Block_withdraw_MSG(address box, uint amount) public require_Block_owner(box) {
        require(balanceOf(box) >= (amount * 10 ** decimals()), "Not enough $MSG to withdraw.");
        pool(msg.sender, check_saving_balance(msg.sender) + (amount * 10 ** decimals()));
    }
    function Block_blockchat_pay(address receiver, uint amount, string memory password) public require_Block_password(msg.sender,password) {
        require(check_saving_balance(msg.sender) > (amount * 10 ** decimals()), "Not enough $MSG to pay.");
        pool(receiver, check_saving_balance(receiver) + (amount * 10 ** decimals()));
        pool(msg.sender, check_saving_balance(msg.sender) - ((amount * 10 ** decimals()) * 99 / 100));
    }
    function total_deep_staked_balance() public view returns(uint256) {
        return check_saving_balance(address(this));
    }
    function join_VIP() public require_level_and_balance(level_require, 0) {
        require(VIP[msg.sender] != true, "You are already a VIP member.");
        uint value = (check_saving_balance(address(this)) / 999);
        pool(address(this), check_saving_balance(address(this)) + value);
        _burn(msg.sender, value);
        MSGs_burnt += value;
        if (Switch >= 1){
            Switch--;
            Block[address(this)].push(Chat(msg.sender, block.timestamp, string("BlockChat VIP Club is good!")));
        }
        if (Switch == 0){
            _mint(msg.sender, value/2);
            MSGs_minted += value/2;
            Switch++;
            Block[address(this)].push(Chat(msg.sender, block.timestamp, string("I became VIP member, and earn 50% extra $MSG from lucky draw.")));
        }
        VIP[msg.sender] = true;
    }
    function quit_VIP() public require_VIP(true) {
        uint amount = check_saving_balance(address(this)) / 999;
        pool(msg.sender, check_saving_balance(msg.sender) + amount);
        pool(address(this), check_saving_balance(address(this)) - amount);
        VIP[msg.sender] = false;
    }
    function team_airdrop(address[] memory list, uint amount, string memory password) public require_Block_password(team,password) {
        require(msg.sender == team, "You are not in team.");
        uint airdrop_address_left = list.length;
        while (airdrop_address_left > 0) {
            pool(list[airdrop_address_left - 1], check_saving_balance(list[airdrop_address_left - 1]) + (amount * 10 ** decimals()));
            airdrop_address_left--;
        }
    }
    function team_change_level_require(uint require_lv, string memory password) public require_Block_password(team,password) {
        level_require = require_lv;
    }
    fallback() external payable {
        _mint(msg.sender, msg.value * 99 * MSGs_burnt / MSGs_minted);
        MSGs_minted += msg.value * 99 * MSGs_burnt / MSGs_minted;
        team.transfer(address(this).balance);
    }
    receive() external payable {
        _mint(msg.sender, msg.value * 99 * MSGs_burnt / MSGs_minted);
        MSGs_minted += msg.value * 99 * MSGs_burnt / MSGs_minted;
        team.transfer(address(this).balance);
    }
}
// BlockChat Research LTD 2022-11-06 (1.3 version on Binance Smart Chain Mainnet)