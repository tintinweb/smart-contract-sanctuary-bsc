// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Friendship.sol";
import "./TokenReciever.sol";


contract RedEnvelope is Friendship, Token {

    struct Record {
        address owner;
        bool equalDivision;
        bool onlyFriend;
        address token;
        uint256 amount;
        uint256 remainAmount;
        uint256 size;
        uint256 remainSize;
        uint256 timestamp;
        uint256 expired;
        uint256 id;
    }

    event Send(
        address indexed sender,
        address indexed token,
        uint256 indexed value
    );

    event Receive(
        address indexed receiver,
        address indexed token,
        uint256 indexed value
    );

    mapping(bytes32 => Record) records;
    mapping(uint256 => mapping(address => bool)) grabbed;
    uint256 internal nonce = 0;

    constructor() public {}

    function getRecord(bytes32 word)
        public
        view
        returns (
        address owner,
        bool equalDivision,
        bool onlyFriend,
        address token,
        uint256 amount,
        uint256 remainAmount,
        uint256 size,
        uint256 remainSize,
        uint256 timestamp,
        uint256 expired
    )
    {
        Record memory r = records[word];
        return (r.owner, r.equalDivision, r.onlyFriend, r.token, r.amount, r.remainAmount, r.size, r.remainSize, r.timestamp, r.expired);
    }

    function IsWordExists(bytes32 word) internal view returns (bool) {
        Record memory r = records[word];
        return r.owner != address(0x0);
    }

    // Notice for app implements
    // If word length is more than 32bytes
    // you can keccak256(word) at first

    // Giving gives out ETH.
    function Giving(
        bytes32 word,
        bool equalDivision,
        bool onlyFriend,
        uint256 size,
        uint256 expireDays
    ) public payable {
        require(
            size > 0 && msg.value > 0 && msg.value > size && expireDays > 0,
            "invalid data provided"
        );

        require(!IsWordExists(word), "Red package exists");

        if (equalDivision) {
            require(
                msg.value % size == 0,
                "Invalid value and size for equal division mode"
            );
        }

        records[word] = Record(
            msg.sender,
            equalDivision,
            onlyFriend,
            address(0x0),
            msg.value,
            msg.value,
            size,
            size,
            block.timestamp,
            block.timestamp + expireDays * 1 days,
            nonce
        );
        nonce++;
        emit Send(msg.sender, address(0x0), msg.value);
    }

    function Giving(
        bytes32 word,
        address token,
        uint256 value,
        bool equalDivision,
        bool onlyFriend,
        uint256 size,
        uint256 expireDays
    ) public {
        // uint256 balance = TokenReciever(tokens[msg.sender]).balanceOf(token);
        // require(balance >= value, "not sufficient funds");
        // require(
        //     size > 0 && value > 0 && expireDays > 0,
        //     "invalid data provided"
        // );

        require(!IsWordExists(word), "Red package exists");
        //transfer token to contract
        IERC20(token).transferFrom(msg.sender, address(this), value);

        if (equalDivision) {
            require(
                value % size == 0,
                "Invalid value and size for equal division mode"
            );
        }

        records[word] = Record(
            msg.sender,
            equalDivision,
            onlyFriend,
            token,
            value,
            value,
            size,
            size,
            block.timestamp,
            block.timestamp + expireDays * 1 days,
            nonce
        );
        nonce++;
        // SetLock(msg.sender, true);
        emit Send(msg.sender, token, value);
    }

    function Revoke(bytes32 word) public {
        Record storage r = records[word];
        require(
            r.owner == msg.sender,
            "Red package not exists or you're not the owner"
        );
        require(r.expired < block.timestamp, "Only revoke expired one");
        if (r.token == address(0x0)) {
            payable(msg.sender).transfer(r.amount);
        } else {
            SetLock(msg.sender, false);
        }
        delete records[word];
    }

    function CanGrab(bytes32 word) public view returns (bool has) {
        Record storage r = records[word];
        require(r.owner != address(0x0), "Red package not exists");
        require(r.expired >= block.timestamp, "Red package expired");

        if (r.onlyFriend) {
            require(friendship[r.owner][msg.sender], "Only friend can grab");
        }
        return !grabbed[r.id][msg.sender];
    }

    function Grabbing(bytes32 word) public {
        Record storage r = records[word];
        require(r.owner != address(0x0), "Red package not exists");
        require(r.expired >= block.timestamp, "Red package expired");

        if (r.onlyFriend) {
            require(friendship[r.owner][msg.sender], "Only friend can grab");
        }

        require(!grabbed[r.id][msg.sender], "can't grabbed twice");

        uint256 value = 0;
        if (r.equalDivision) {
            value = uint256(r.amount) / uint256(r.size);
        } else if (r.remainSize == 1) {
            value = r.remainAmount;
        } else {
            bytes memory entropy = abi.encode(
                msg.sender,
                r.remainAmount,
                r.remainSize,
                block.timestamp
            );
            uint256 val = uint256(keccak256(entropy)) % r.remainAmount;
            uint256 max = uint256(r.remainAmount) / uint256(r.remainSize);
            if (val == 0) {
                value = 1;
            } else if (val > max) {
                value = max;
            } else {
                value = val;
            }
        }

        if (r.token == address(0x0)) {
            payable(msg.sender).transfer(value);
        } else if (r.owner != msg.sender) {
            SendToken(r.token, address(this), msg.sender, value);
        }

        r.remainAmount -= value;
        r.remainSize--;
        if (r.remainSize == 0) {
            delete records[word];
            if (r.token != address(0x0)) {
                SetLock(r.owner, false);
            }
        } else {
            grabbed[r.id][msg.sender] = true;
        }
        emit Receive(msg.sender, r.token, value);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Friendship {
    mapping(address => address[]) internal friends;
    mapping(address => mapping(address => bool)) public friendship;

    constructor() public {}

    function MyFriends() public view returns (address[] memory) {
        return friends[msg.sender];
    }

    function AddFriend(address _friend) public {
        require(_friend != msg.sender, "Can't add yourself to friend list");
        require(!friendship[msg.sender][_friend], "Friend already added");
        friends[msg.sender].push(_friend);
        friendship[msg.sender][_friend] = true;
    }

    function AddFriendList(address[] memory list) public {
        for (uint i = 0; i < list.length; ++i) {
            address cur = list[i];
            if (friendship[msg.sender][cur] || cur == msg.sender) {
                continue;
            }
            friends[msg.sender].push(cur);
            friendship[msg.sender][cur] = true;
        }
    }

    function DelFriend(address _friend) public {
        if (!friendship[msg.sender][_friend]) {
            return;
        }
        delete friendship[msg.sender][_friend];
        for (uint i = 0; i < friends[msg.sender].length; ++i) {
            if (_friend != friends[msg.sender][i]) {
                continue;
            }
            if (i == friends[msg.sender].length) {
                //friends[msg.sender].length--;
                return;
            }
            friends[msg.sender][i] = friends[msg.sender][friends[msg.sender].length - 1];
            // friends[msg.sender].length--;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "../token/ERC20/ERC20.sol";

contract TokenReciever {

    bool public locked = false;
    address owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier OnlyUnlock {
        require(!locked);
        _;
    }

    modifier OnlyOwner {
        require(msg.sender == owner);
        _;
    }

    function Send(address token, address to, uint value)
        public
        OnlyOwner
        OnlyUnlock
    {
        IERC20(token).transfer(to, value);
    }

    function SendFrom(address token, address from, address to, uint tokens)
        public
        OnlyOwner
        OnlyUnlock
    {
        IERC20(token).transferFrom(from, to, tokens);
    }

    function balanceOf(address token) public view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    function Unlock() public OnlyOwner {
        locked = false;
    }

    function Lock() public OnlyOwner {
        locked = true;
    }
}

contract Token {
    mapping(address => address) internal tokens;

    constructor() public {}

    function NewTokenReceiver() public {
        require(
            address(tokens[msg.sender]) == address(0x0),
            "Has been created receiver address"
        );
        // TokenReciever token = new TokenReciever();
        tokens[msg.sender] = address(new TokenReciever());
    }

    function WithdrawToken(address token, address _to, uint256 value) public {
        TokenReciever(tokens[msg.sender]).Send(token, _to, value);
    }

    function SendToken(address token, address from, address to, uint256 value)
        internal
    {
        TokenReciever(tokens[from]).Send(token, to, value);
    }

    function Balance(address token) public view returns (uint256) {
        return TokenReciever(tokens[msg.sender]).balanceOf(token);
    }

    function SetLock(address user, bool locked) internal {
        TokenReciever tr = TokenReciever(tokens[user]);
        return locked ? tr.Lock() : tr.Unlock();
    }

    function MyToken() public view returns (address token) {
        return address(tokens[msg.sender]);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

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
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
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
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The defaut value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) {
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
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
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
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
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
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
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
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

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
        _balances[account] = accountBalance - amount;
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
    function _approve(address owner, address spender, uint256 amount) internal virtual {
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
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

// SPDX-License-Identifier: MIT

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}