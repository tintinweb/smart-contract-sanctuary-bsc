/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-04
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/Context.sol

pragma solidity ^0.8.9;

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

// File: @openzeppelin/contracts/security/Pausable.sol




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

// File: @openzeppelin/contracts/access/Ownable.sol





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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol





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
    function transferFrom(
        address sender,
        address recipient,
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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)


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

// File: contracts/artifacts/hub.sol





/**
 * @title ERC20 Token for ScoutHUB
 * @author 0xVeliUysal, 0xfunTalia, Dozcan, ScoutHUB and Deneth
 */
contract ScoutHUBToken is Context, IERC20, IERC20Metadata, Ownable, Pausable {
    string public constant name = "ScoutHUB Token"; //  ScoutHUB Project
    string public constant symbol = "HUB"; // our ticker is HUB
    uint8 public constant decimals = 18;
    uint256 public totalSupply = 1_000_000_000 ether; // total supply is 1,000,000,000
    uint256 private maxSupply = 1_250_000_000 ether; // maximum supply is 1,250,000,000

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;

    // This is a map of addresses to cooldown times and is triggered on every transfer.
    mapping(address => uint32) private cooldowns;
    // Some addresses should never have a cooldown, such as exchange addresses. Those can be added here.
    mapping(address => bool) private cooldownWhitelist;
    uint256 public MEV_COOLDOWN_TIME = 3 minutes;

    event Mint(address indexed minter, address indexed account, uint256 amount);
    event Burn(address indexed burner, address indexed account, uint256 amount);

    constructor() {
        balances[msg.sender] = totalSupply;
    }

    /**
     * @notice toggle pause
     * This method using for toggling pause for contract
     */
    function togglePause() external onlyOwner {
        paused() ? _unpause() : _pause();
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 value)
        external
        whenNotPaused
        returns (bool)
    {
        require(to != address(0), "ERC20: to address is not valid");
        require(value <= balances[msg.sender], "ERC20: insufficient balance");

        beforeTokenTransfer(msg.sender);

        balances[msg.sender] = balances[msg.sender] - value;
        balances[to] = balances[to] + value;

        emit Transfer(msg.sender, to, value);

        afterTokenTransfer(to);

        return true;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account)
        external
        view
        returns (uint256 balance)
    {
        return balances[account];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value)
        external
        whenNotPaused
        returns (bool)
    {
        allowed[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

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
        address from,
        address to,
        uint256 value
    ) external whenNotPaused returns (bool) {
        require(from != address(0), "ERC20: from address is not valid");
        require(to != address(0), "ERC20: to address is not valid");
        require(value <= balances[from], "ERC20: insufficient balance");
        require(value <= allowed[from][msg.sender], "ERC20: from not allowed");

        balances[from] = balances[from] - value;
        balances[to] = balances[to] + value;
        allowed[from][msg.sender] = allowed[from][msg.sender] - value;

        emit Transfer(from, to, value);

        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address account, address spender)
        external
        view
        whenNotPaused
        returns (uint256)
    {
        return allowed[account][spender];
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
    function increaseApproval(address spender, uint256 addedValue)
        external
        whenNotPaused
        returns (bool)
    {
        allowed[msg.sender][spender] =
            allowed[msg.sender][spender] +
            addedValue;

        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);

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
    function decreaseApproval(address spender, uint256 subtractedValue)
        external
        whenNotPaused
        returns (bool)
    {
        uint256 oldValue = allowed[msg.sender][spender];

        if (subtractedValue > oldValue) {
            allowed[msg.sender][spender] = 0;
        } else {
            allowed[msg.sender][spender] = oldValue - subtractedValue;
        }

        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);

        return true;
    }

    /**
     * @notice mint method
     * This method using to mint new hub tokens.
     */
    function mint(address to, uint256 amount) external whenNotPaused onlyOwner {
        require(to != address(0), "ERC20: to address is not valid");
        require(amount > 0, "ERC20: amount is not valid");

        uint256 totalAmount = totalSupply + amount;
        require(totalAmount <= maxSupply, "ERC20: unsufficient max supply");

        totalSupply = totalAmount;
        balances[to] = balances[to] + amount;

        emit Mint(msg.sender, to, amount);
    }

    /**
     * @notice burn method
     * This method is implemented for future business rules.
     */
    function burn(address account, uint256 amount) external whenNotPaused {
        require(account != address(0), "ERC20: from address is not valid");
        require(msg.sender == account, "ERC20: only your address");
        require(balances[account] >= amount, "ERC20: insufficient balance");

        balances[account] = balances[account] - amount;
        totalSupply = totalSupply - amount;
        maxSupply = maxSupply - amount;

        emit Burn(msg.sender, account, amount);
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
     */
    function beforeTokenTransfer(
        address from
    ) internal virtual {
        // If the from address is not in the cooldown whitelist, verify it is not in the cooldown
        // period. If it is, prevent the transfer.
        if (!cooldownWhitelist[from]) {
            // Change the error message according to the customized cooldown time.
            require(
                cooldowns[from] <= uint32(block.timestamp),
                "Please wait 3 minutes before transferring or selling your tokens."
            );
        }
    }

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
     */
    function afterTokenTransfer(
        address to
    ) internal virtual {
        // If the to address is not in the cooldown whitelist, add a cooldown to it.
        if (!cooldownWhitelist[to]) {
            // Add a cooldown to the address receiving the tokens.
            cooldowns[to] = uint32(block.timestamp + MEV_COOLDOWN_TIME);
        }
    }

    /**
     * Pass in an address to add it to the cooldown whitelist.
     */
    function addCooldownWhitelist(address whitelistAddy) external onlyOwner {
        cooldownWhitelist[whitelistAddy] = true;
    }

    /**
     * Pass in an address to remove it from the cooldown whitelist.
     */
    function removeCooldownWhitelist(address whitelistAddy) external onlyOwner {
        cooldownWhitelist[whitelistAddy] = false;
    }
    
    function setMevCooldown(uint256 cooldown) external onlyOwner {
           MEV_COOLDOWN_TIME = cooldown;
    }

    /*
     * @notice fallback method
     *
     * executed when the `data` field is empty or starts with an unknown function signature
     */
    fallback() external {
        revert("Something bad happened");
    }
}