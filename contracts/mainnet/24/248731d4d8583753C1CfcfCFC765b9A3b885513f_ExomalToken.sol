/**
 *Submitted for verification at BscScan.com on 2023-04-01
*/

// File: @openzeppelin\contracts\token\ERC20\IERC20.sol

// SPDX-License-Identifier: MIT
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

// File: @openzeppelin\contracts\token\ERC20\extensions\IERC20Metadata.sol

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

// File: @openzeppelin\contracts\utils\Context.sol

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

// File: @openzeppelin\contracts\token\ERC20\ERC20.sol

// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;



/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
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
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

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
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
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
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

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

// File: @openzeppelin\contracts\access\Ownable.sol

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

// File: contracts\ExomalToken.sol

pragma solidity ^0.8.0;
/**
 * @title ExomalToken
 * @dev EXML token is a share in Exomal project. By owning it you can participate
 * in staking and you receive dividends.
 * Token value is backed by mobile application and many products
 */
/**
 :!7?7!:                                                         :!777!:
  ^???????:                                                       ^???????:
  ~???????~                                                       !???????^
  ^???????!                                                       7???????:
  :???????7.                                                     :???????7.
   7???????~                                                     !???????~
   ^????????:                                                   ^???????7.
    !???????7:                                                 :7???????^
    .7???????7:                                               ^7???????~
     .7????????~                                            .~????????!
      .!????????7^                                         ^7????????~
       .~?????????!^.                                   .^7????????7:
         :7?????????7~:                              .:~7?????????~.
           ^7??????????7~^.                       .^~7??????????!:
             ^!???????????77!~^:....     ...::^~!7???????????7~:
               :~7???????????????77777777777??????????????7!^.
                  :^!7?????????????????????????????????7~:.
                  .^!7?????????????????????????????????7~:.
               .^!7???????????????777777777???????????????7!^.
             :!7???????????7!~^^:..........::^~!77???????????7~.
           :!??????????7!^:.                     .:~!7??????????!:
         :!?????????7~:.                             .^!?????????7~.
        ~?????????!^.                                   :~7????????7:
      .!????????7^                                        .~?????????~
     .7????????~                                            :!????????~
    .7???????7:                                               ~????????~
    !???????7.                                                 ~????????^
   ^???????7:                                                   ~???????7.
  .7???????^                                                    .7???????~
  :???????7.         ....                         .....          ^???????7.
  ^???????~       .~77??77^.                    :!77?77!:        .7???????:
  ~???????^      .7????????7.                  ^?????????^        7???????:
  ~??????7:      :??????????:                  !?????????!        ~???????:
  .~!777!:        ~???????7~                   :7???????7:         ^!777!:
     ..            :~!77!~.                     .^~!7!!^.            ...
*/
contract ExomalToken is ERC20, Ownable {
    // Initial supply of the token is set to 100,000,000.
    uint256 public initialSupply = 100000000;

    /**
    @dev Constructor for the DevToken contract.
    */
    constructor() ERC20("ExomalToken", "EXML") {
        // The contract creator gets the initial supply of tokens.
        _mint(msg.sender, initialSupply * 10 ** decimals());
        // Initialize the stakeholders array with an empty stakeholder to
        // prevent a user with index 0 being considered as non-staker.
        stakeholders.push();
    }

    // Structure to store the summary of all stakes for a user.
    struct StakingSummary {
        uint256 total_amount; // Total amount staked by the user.
        Stake[] stakes;       // Array of individual stakes.
    }

    // Structure to represent an individual stake.
    struct Stake {
        address user;         // Address of the user who staked the tokens.
        uint256 amount;       // Amount of tokens staked.
        uint256 since;        // Timestamp when the stake was made.
        uint256 claimable;    // Amount of tokens claimable as a reward.
    }

    // Structure to represent a stakeholder (user with active stakes).
    struct Stakeholder {
        address user;         // Address of the stakeholder.
        Stake[] address_stakes;// Array of individual stakes for the stakeholder.
    }

    uint256 public stakeStartDate = 0;   // The date when staking starts.
    Stakeholder[] internal stakeholders; // Array of all stakeholders.
    // Mapping to store the index of each stakeholder in the stakeholders array.
    mapping(address => uint256) internal stakes;
    // Event emitted when a user stakes tokens.
    event Staked(address indexed user, uint256 amount, uint256 index, uint256 timestamp);

    /**
    * @dev Sets the staking start date to control when users can start staking.
    * @param _timestamp The Unix timestamp to set as the staking start date.
    */
    function setStakeStartDate(uint256 _timestamp) public onlyOwner {
        require(block.timestamp < _timestamp, "Stake start date must be in the future");
        stakeStartDate = _timestamp;
    }

    /**
    * @dev Adds the given address as a stakeholder, assigns a new index to the address, and updates the mapping.
    * @param staker The address of the user to be added as a stakeholder.
    * @return The newly assigned index for the stakeholder.
    */
    function _addStakeholder(address staker) internal returns (uint256){
        // Add a new empty stakeholder to the stakeholders array.
        stakeholders.push();
        // Set the user index as the last element in the stakeholders array.
        uint256 userIndex = stakeholders.length - 1;
        // Assign the staker's address to the new stakeholder.
        stakeholders[userIndex].user = staker;
        // Update the stakes mapping with the new user index for the staker.
        stakes[staker] = userIndex;
        // Return the newly assigned index for the stakeholder.
        return userIndex;
    }

    /**
    * @dev Internal function that handles the actual staking process.
    * It checks if the user is already a stakeholder or adds them as one, creates a new stake, and emits the Staked event.
    * @param _amount The amount of tokens to be staked by the sender.
    */
    function _stake(uint256 _amount) internal {
        require(_amount > 0, "Cannot stake nothing");
        // Get the user index from the stakes mapping.
        uint256 index = stakes[msg.sender];
        // Get the current block timestamp.
        uint256 timestamp = block.timestamp;
        // If the user index is 0, add the sender as a new stakeholder and update the index.
        if (index == 0) {
            index = _addStakeholder(msg.sender);
        }
        // Create a new Stake struct and push it to the sender's address_stakes array.
        stakeholders[index].address_stakes.push(Stake(msg.sender, _amount, timestamp, 0));
        // Emit the Staked event with the sender's address, staking amount, user index, and timestamp.
        emit Staked(msg.sender, _amount, index, timestamp);
    }

    /**
    * @dev Public function that Allows users to stake a specified amount of tokens, provided the staking period is active and they have enough tokens to stake.
    *      Calls the internal '_stake' function to update the staking data, and burns the staked tokens to remove them from the staker's
    *      balance during the staking period.
    * @param _amount The amount of tokens in wai to be staked. One token == (1 x 10^18 wei) == 1 000 000 000 000 000 000 wei.
    */
    function stake(uint256 _amount) public {
        require(stakeStartDate > 0, "Staking has not started yet");
        require(stakeStartDate < block.timestamp, "Staking has not started yet");
        require(block.timestamp < (stakeStartDate + 365 days), "Staking has ended");
        require(_amount <= balanceOf(msg.sender), "Cannot stake more than you own");
        // Call the internal _stake function to update the staking data.
        _stake(_amount);
        // Burn the staked tokens to remove them from the staker's balance during the staking period.
        _burn(msg.sender, _amount);
    }

    /**
    * @dev Checks if the given address has any stakes, calculates rewards for each stake, and returns a StakingSummary struct.
    * @param _staker Address of the staker to check for stakes
    * @return StakingSummary struct containing the updated claimable rewards and total stake amount for the given staker
    */
    function hasStake(address _staker) public view returns (StakingSummary memory){
        uint256 totalStakeAmount;
        // Check if the staker has any stakes in the contract.
        require(stakeholders[stakes[_staker]].address_stakes.length > 0, "No stakes found for this staker");
        // Initialize a StakingSummary struct with the staker's stakes.
        StakingSummary memory summary = StakingSummary(0, stakeholders[stakes[_staker]].address_stakes);
        for (uint256 s = 0; s < summary.stakes.length; s += 1) {
            // Calculate the available reward for each stake based on the staking period.
            uint256 availableReward = calculateStakeReward(summary.stakes[s]);
            // Set the claimable field of each stake with the calculated reward.
            summary.stakes[s].claimable = availableReward;
            // Update the total stake amount.
            totalStakeAmount = totalStakeAmount + summary.stakes[s].amount;
        }
        // Set the total_amount field of the StakingSummary struct.
        summary.total_amount = totalStakeAmount;
        // Return the StakingSummary struct.
        return summary;
    }

    /**
    * @dev Function that allows users to withdraw their stakes and rewards after the staking period has ended.
    * Mints the total tokens (stakes and rewards) to the user's balance and clears their staking data.
    */
    function withdrawStakes() public {
        // Check if the staking start date is not zero, ensuring that staking has started
        require(stakeStartDate != 0, "Withdrawing is not allowed yet");
        // Ensure that the current block timestamp is greater than the sum of the staking start date and the staking duration (365 days)
        require(stakeStartDate + (365 days) < block.timestamp, "Withdrawing is not allowed yet");
        // Calculate the total tokens to be minted (stakes and rewards) by calling the internal _withdrawStakes function
        uint256 amount_to_mint = _withdrawStakes();
        // Mint the calculated amount to the user's balance
        _mint(msg.sender, amount_to_mint);
    }

    /**
    * @dev Internal function to handle the withdrawal of stakes and rewards for the sender by calculating the total tokens and clearing staking data.
    * @return totalTokens Total tokens to be minted for the sender, including their original stakes and calculated rewards.
    */
    function _withdrawStakes() internal returns (uint256){
        // Get the index of the staker in the stakeholders array.
        uint256 user_index = stakes[msg.sender];
        // Check if the user has any stakes
        require(stakeholders[user_index].address_stakes.length > 0, "Withdrawing not possible. --Reason: no stakes");
        // Initialize a variable to store the total tokens to be withdrawn.
        uint256 totalTokens = 0;
        // Loop through all the stakes of the staker.
        for (uint256 index = 0; index < stakeholders[user_index].address_stakes.length; index += 1) {
            // Get the current stake.
            Stake memory current_stake = stakeholders[user_index].address_stakes[index];
            // Get the staked amount of the current stake.
            uint256 amount = current_stake.amount;
            // Calculate the reward for the current stake.
            uint256 reward = calculateStakeReward(current_stake);
            // Update the total tokens to be withdrawn.
            totalTokens = totalTokens + amount + reward;
        }
        // Delete the 'address_stakes' array to remove all the stakes.
        delete stakeholders[user_index].address_stakes;
        // Return the total tokens to be withdrawn.
        return totalTokens;
    }

    /**
    * @dev Calculates the reward for the given stake based on the staking duration and the stake amount.
    * @param _current_stake Stake struct containing the stake information for which the reward will be calculated.
    * @return reward Calculated reward for the given stake.
    */
    function calculateStakeReward(Stake memory _current_stake) internal view returns (uint256) {
        // Get the start date of the stake from the input stake struct.
        uint256 startDate = _current_stake.since;
        // Calculate the end date of the staking period, which is 365 days after the staking start date.
        uint256 endDate = stakeStartDate + 365 days;
        // Calculate the number of days the stake has been staked, based on the stake start date and the staking end date.
        // 86399 (seconds in a day) to make sure we round up to the next whole day, so even a short time counts as a day.
        uint256 daysStaked = (endDate - startDate + 86399) / 86400;
        // Calculate the reward for the given stake by multiplying the stake amount, days staked, and the reward rate (11%).
        // The reward rate of 0.11111111 is converted to 11111111, which is then scaled down by a factor of (10 ** 8) in the second part of the equation.
        uint256 reward = (_current_stake.amount * daysStaked * 11111111) / (365 * 10 ** 8);
        // Return the calculated reward for the given stake.
        return reward;
    }

}