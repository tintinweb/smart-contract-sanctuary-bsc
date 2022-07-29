/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

// SPDX-License-Identifier: MIT

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


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

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

// File: contracts/ElefGold.sol



pragma solidity >=0.8.9 <0.9.0;



contract ElefGold is ERC20, Ownable {

    address public elefAddress;
    address public elefTeamAddress;
    address public mrkAddress;
    address public attyAddress;

    uint256 public elefPrice;
    uint256 public elefGoldReward50;
    uint256 public elefGoldReward100;
    uint256 public elefGoldReward200;
    uint256 public elefGoldReward300;
    uint256 public elefGoldReward400;
    uint256 public elefGoldReward500;

    uint256 public maxSupply;

    bool public paused;

    mapping(address => uint256) public userStakedAt50;
    mapping(address => uint256) public userStakedAt100;
    mapping(address => uint256) public userStakedAt200;
    mapping(address => uint256) public userStakedAt300;
    mapping(address => uint256) public userStakedAt400;
    mapping(address => uint256) public userStakedAt500;

    mapping(address => address) public referralAddress;

    mapping(address => bool) public stakedAt50;
    mapping(address => bool) public stakedAt100;
    mapping(address => bool) public stakedAt200;
    mapping(address => bool) public stakedAt300;
    mapping(address => bool) public stakedAt400;
    mapping(address => bool) public stakedAt500;

    constructor() ERC20("ElefGold", "EGOLD") {
        elefAddress = 0xB9Ca307a74a6E4c114B3170B38C470c95b20f376; // Change
        mrkAddress = 0xddFA1B09892D4aaC67FbC7a47FBE07fDe196e19c; // Change
        elefTeamAddress = 0xef2073ED2fb67DEB71b8B10f488219F0267e6234; // Change
        attyAddress = 0x229A2aEa386c4BE6EdeB50C9d588377FF133654d; // Change
        maxSupply = 1000000000 ether;
        elefPrice = 7400000 ether;
        elefGoldReward50 = 0.25 ether;
        elefGoldReward100 = 0.5 ether;
        elefGoldReward200 = 1 ether;
        elefGoldReward300 = 1.5 ether;
        elefGoldReward400 = 2 ether;
        elefGoldReward500 = 3 ether;
        _mint(mrkAddress, 10000000 ether);
    }

    function togglePause() public onlyOwner {
        paused = !paused;
    }

    function setElefPrice(uint256 newPrice) public onlyOwner {
        elefPrice = newPrice;
    }

    function setReferralAddress(address newAddress) public {
        referralAddress[msg.sender] = newAddress;
    }

    function release(uint256 reward) internal {
        uint256 team = reward * 5 / 100;
        uint256 mrk = reward * 5 / 100;
        uint256 user = reward * 90 / 100;
        _mint(msg.sender, user);
        _mint(mrkAddress, mrk);
        _mint(elefTeamAddress, team);
    }

    function pendingRewards50(address owner) public view returns (uint256 balance) {
        uint256 timeStarted = userStakedAt50[owner];
        uint256 timeNow = block.timestamp;
        uint256 timePassed = timeNow - timeStarted;
        

        if (timeNow != timePassed) {
            uint256 result = (1 * elefGoldReward50 * timePassed) / 86400;
                if (result <= 0) {
                return 0;
                } else {
                return result;
            }
        }
    }

    function pendingRewards100(address owner) public view returns (uint256 balance) {
        uint256 timeStarted = userStakedAt100[owner];
        uint256 timeNow = block.timestamp;
        uint256 timePassed = timeNow - timeStarted;
        if (timeNow != timePassed) {
            uint256 result = (1 * elefGoldReward100 * timePassed) / 86400;
                if (result <= 0) {
                return 0;
                } else {
                return result;
            }
        }
    }

    function pendingRewards200(address owner) public view returns (uint256 balance) {
        uint256 timeStarted = userStakedAt200[owner];
        uint256 timeNow = block.timestamp;
        uint256 timePassed = timeNow - timeStarted;
        if (timeNow != timePassed) {
            uint256 result = (1 * elefGoldReward200 * timePassed) / 86400;
                if (result <= 0) {
                return 0;
                } else {
                return result;
            }
        }
    }

    function pendingRewards300(address owner) public view returns (uint256 balance) {
        uint256 timeStarted = userStakedAt300[owner];
        uint256 timeNow = block.timestamp;
        uint256 timePassed = timeNow - timeStarted;
        if (timeNow != timePassed) {
            uint256 result = (1 * elefGoldReward300 * timePassed) / 86400;
                if (result <= 0) {
                return 0;
                } else {
                return result;
            }
        }
    }

    function pendingRewards400(address owner) public view returns (uint256 balance) {
        uint256 timeStarted = userStakedAt400[owner];
        uint256 timeNow = block.timestamp;
        uint256 timePassed = timeNow - timeStarted;
        if (timeNow != timePassed) {
            uint256 result = (1 * elefGoldReward400 * timePassed) / 86400;
                if (result <= 0) {
                return 0;
                } else {
                return result;
            }
        }
    }

    function pendingRewards500(address owner) public view returns (uint256 balance) {
        uint256 timeStarted = userStakedAt500[owner];
        uint256 timeNow = block.timestamp;
        uint256 timePassed = timeNow - timeStarted;
        if (timeNow != timePassed) {
            uint256 result = (1 * elefGoldReward500 * timePassed) / 86400;
                if (result <= 0) {
                return 0;
                } else {
                return result;
            }
        }
    }

    function stake50() public {
        require(!paused, "The contract is paused");
        require(!stakedAt50[msg.sender], "You already staked at 50!");
        if (referralAddress[msg.sender] == address(0)) {
            uint256 mrk = elefPrice * 45 / 100;
            uint256 team = elefPrice * 50 / 100;
            uint256 atty = elefPrice * 5 / 100;
            IERC20(elefAddress).transferFrom(msg.sender, mrkAddress, mrk);
            IERC20(elefAddress).transferFrom(msg.sender, elefTeamAddress, team);
            IERC20(elefAddress).transferFrom(msg.sender, attyAddress, atty);
        } else {
            uint256 mrk = elefPrice * 40 / 100;
            uint256 team = elefPrice * 45 / 100;
            uint256 atty = elefPrice * 5 / 100;
            uint256 ref = elefPrice * 10 / 100;
            IERC20(elefAddress).transferFrom(msg.sender, mrkAddress, mrk);
            IERC20(elefAddress).transferFrom(msg.sender, elefTeamAddress, team);
            IERC20(elefAddress).transferFrom(msg.sender, attyAddress, atty);
            IERC20(elefAddress).transferFrom(msg.sender, referralAddress[msg.sender], ref);
        }
        userStakedAt50[msg.sender] = block.timestamp;
        stakedAt50[msg.sender] = true;
    }

    function stake100() public {
        require(!paused, "The contract is paused");
        require(!stakedAt100[msg.sender], "You already staked at 100!");
        if (referralAddress[msg.sender] == address(0)) {
            uint256 mrk = elefPrice * 90 / 100;
            uint256 team = elefPrice * 100 / 100;
            uint256 atty = elefPrice * 10 / 100;
            IERC20(elefAddress).transferFrom(msg.sender, mrkAddress, mrk);
            IERC20(elefAddress).transferFrom(msg.sender, elefTeamAddress, team);
            IERC20(elefAddress).transferFrom(msg.sender, attyAddress, atty);
        } else {
            uint256 mrk = elefPrice * 80 / 100;
            uint256 team = elefPrice * 90 / 100;
            uint256 atty = elefPrice * 10 / 100;
            uint256 ref = elefPrice * 20 / 100;
            IERC20(elefAddress).transferFrom(msg.sender, mrkAddress, mrk);
            IERC20(elefAddress).transferFrom(msg.sender, elefTeamAddress, team);
            IERC20(elefAddress).transferFrom(msg.sender, attyAddress, atty);
            IERC20(elefAddress).transferFrom(msg.sender, referralAddress[msg.sender], ref);
        }
        userStakedAt100[msg.sender] = block.timestamp;
        stakedAt100[msg.sender] = true;
    }

    function stake200() public {
        require(!paused, "The contract is paused");
        require(!stakedAt200[msg.sender], "You already staked at 200!");
        if (referralAddress[msg.sender] == address(0)) {
            uint256 mrk = elefPrice * 180 / 100;
            uint256 team = elefPrice * 200 / 100;
            uint256 atty = elefPrice * 20 / 100;
            IERC20(elefAddress).transferFrom(msg.sender, mrkAddress, mrk);
            IERC20(elefAddress).transferFrom(msg.sender, elefTeamAddress, team);
            IERC20(elefAddress).transferFrom(msg.sender, attyAddress, atty);
        } else {
            uint256 mrk = elefPrice * 160 / 100;
            uint256 team = elefPrice * 180 / 100;
            uint256 atty = elefPrice * 20 / 100;
            uint256 ref = elefPrice * 40 / 100;
            IERC20(elefAddress).transferFrom(msg.sender, mrkAddress, mrk);
            IERC20(elefAddress).transferFrom(msg.sender, elefTeamAddress, team);
            IERC20(elefAddress).transferFrom(msg.sender, attyAddress, atty);
            IERC20(elefAddress).transferFrom(msg.sender, referralAddress[msg.sender], ref);
        }
        userStakedAt200[msg.sender] = block.timestamp;
        stakedAt200[msg.sender] = true;
    }

    function stake300() public {
        require(!paused, "The contract is paused");
        require(!stakedAt300[msg.sender], "You already staked at 300!");
        if (referralAddress[msg.sender] == address(0)) {
            uint256 mrk = elefPrice * 270 / 100;
            uint256 team = elefPrice * 300 / 100;
            uint256 atty = elefPrice * 30 / 100;
            IERC20(elefAddress).transferFrom(msg.sender, mrkAddress, mrk);
            IERC20(elefAddress).transferFrom(msg.sender, elefTeamAddress, team);
            IERC20(elefAddress).transferFrom(msg.sender, attyAddress, atty);
        } else {
            uint256 mrk = elefPrice * 240 / 100;
            uint256 team = elefPrice * 270 / 100;
            uint256 atty = elefPrice * 30 / 100;
            uint256 ref = elefPrice * 60 / 100;
            IERC20(elefAddress).transferFrom(msg.sender, mrkAddress, mrk);
            IERC20(elefAddress).transferFrom(msg.sender, elefTeamAddress, team);
            IERC20(elefAddress).transferFrom(msg.sender, attyAddress, atty);
            IERC20(elefAddress).transferFrom(msg.sender, referralAddress[msg.sender], ref);
        }
        userStakedAt300[msg.sender] = block.timestamp;
        stakedAt300[msg.sender] = true;
    }

    function stake400() public {
        require(!paused, "The contract is paused");
        require(!stakedAt400[msg.sender], "You already staked at 400!");
        if (referralAddress[msg.sender] == address(0)) {
            uint256 mrk = elefPrice * 360 / 100;
            uint256 team = elefPrice * 400 / 100;
            uint256 atty = elefPrice * 40 / 100;
            IERC20(elefAddress).transferFrom(msg.sender, mrkAddress, mrk);
            IERC20(elefAddress).transferFrom(msg.sender, elefTeamAddress, team);
            IERC20(elefAddress).transferFrom(msg.sender, attyAddress, atty);
        } else {
            uint256 mrk = elefPrice * 320 / 100;
            uint256 team = elefPrice * 360 / 100;
            uint256 atty = elefPrice * 40 / 100;
            uint256 ref = elefPrice * 80 / 100;
            IERC20(elefAddress).transferFrom(msg.sender, mrkAddress, mrk);
            IERC20(elefAddress).transferFrom(msg.sender, elefTeamAddress, team);
            IERC20(elefAddress).transferFrom(msg.sender, attyAddress, atty);
            IERC20(elefAddress).transferFrom(msg.sender, referralAddress[msg.sender], ref);
        }
        userStakedAt400[msg.sender] = block.timestamp;
        stakedAt400[msg.sender] = true;
    }

    function stake500() public {
        require(!paused, "The contract is paused");
        require(!stakedAt500[msg.sender], "You already staked at 500!");
        if (referralAddress[msg.sender] == address(0)) {
            uint256 mrk = elefPrice * 450 / 100;
            uint256 team = elefPrice * 500 / 100;
            uint256 atty = elefPrice * 50 / 100;
            IERC20(elefAddress).transferFrom(msg.sender, mrkAddress, mrk);
            IERC20(elefAddress).transferFrom(msg.sender, elefTeamAddress, team);
            IERC20(elefAddress).transferFrom(msg.sender, attyAddress, atty);
        } else {
            uint256 mrk = elefPrice * 400 / 100;
            uint256 team = elefPrice * 450 / 100;
            uint256 atty = elefPrice * 50 / 100;
            uint256 ref = elefPrice * 100 / 100;
            IERC20(elefAddress).transferFrom(msg.sender, mrkAddress, mrk);
            IERC20(elefAddress).transferFrom(msg.sender, elefTeamAddress, team);
            IERC20(elefAddress).transferFrom(msg.sender, attyAddress, atty);
            IERC20(elefAddress).transferFrom(msg.sender, referralAddress[msg.sender], ref);
        }
        userStakedAt500[msg.sender] = block.timestamp;
        stakedAt500[msg.sender] = true;
    }

    function claim50() public {
        require(!paused, "The contract is paused");
        require(stakedAt50[msg.sender], "You did not staked");
        require(pendingRewards50(msg.sender) >= 20 ether, "Pending reward must be greater than 20 EGOLD");
        uint256 reward = pendingRewards50(msg.sender);
        userStakedAt50[msg.sender] = 0;
        stakedAt50[msg.sender] = false;
        release(reward);
    }

    function claim100() public {
        require(!paused, "The contract is paused");
        require(stakedAt100[msg.sender], "You did not staked");
        require(pendingRewards100(msg.sender) >= 20 ether, "Pending reward must be greater than 20 EGOLD");
        uint256 reward = pendingRewards100(msg.sender);
        userStakedAt100[msg.sender] = 0;
        stakedAt100[msg.sender] = false;
        release(reward);
    }

    function claim200() public {
        require(!paused, "The contract is paused");
        require(stakedAt200[msg.sender], "You did not staked");
        require(pendingRewards200(msg.sender) >= 20 ether, "Pending reward must be greater than 20 EGOLD");
        uint256 reward = pendingRewards200(msg.sender);
        userStakedAt200[msg.sender] = 0;
        stakedAt200[msg.sender] = false;
        release(reward);
    }

    function claim300() public {
        require(!paused, "The contract is paused");
        require(stakedAt300[msg.sender], "You did not staked");
        require(pendingRewards300(msg.sender) >= 20 ether, "Pending reward must be greater than 20 EGOLD");
        uint256 reward = pendingRewards300(msg.sender);
        userStakedAt300[msg.sender] = 0;
        stakedAt300[msg.sender] = false;
        release(reward);
    }

    function claim400() public {
        require(!paused, "The contract is paused");
        require(stakedAt400[msg.sender], "You did not staked");
        require(pendingRewards400(msg.sender) >= 20 ether, "Pending reward must be greater than 20 EGOLD");
        uint256 reward = pendingRewards400(msg.sender);
        userStakedAt400[msg.sender] = 0;
        stakedAt400[msg.sender] = false;
        release(reward);
    }

    function claim500() public {
        require(!paused, "The contract is paused");
        require(stakedAt500[msg.sender], "You did not staked");
        require(pendingRewards500(msg.sender) >= 20 ether, "Pending reward must be greater than 20 EGOLD");
        uint256 reward = pendingRewards500(msg.sender);
        userStakedAt500[msg.sender] = 0;
        stakedAt500[msg.sender] = false;
        release(reward);
    }
}