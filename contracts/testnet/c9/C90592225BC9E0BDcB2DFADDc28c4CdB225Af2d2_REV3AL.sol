// SPDX-License-Identifier: MIT

// Imports -------------------------------------

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// Solidity version -------------------------------------

pragma solidity 0.8.10;

contract REV3AL is ERC20, Ownable, ReentrancyGuard {

    // Using SafeMath library for uint256 operations
    using SafeMath for uint256;

    // Variables -------------------------------------

    // Total supply for rewards
    uint256 public stakingSupply = 500000000000000000000000000;

    // Initial supply
    uint256 public initialSupply = 1000000000000000000000000000;

    // How many tokens an user staked
    mapping ( address => uint256 ) public stakedTokensByUser;

    // Total staked tokens
    uint256 public totalStakedRightNow;

    // Given rewards
    uint256 public givenRewards;

    // Start staking
    bool public startStaking = true;

    // APR
    uint256 public apr30Days = 10; // 10% per year
    uint256 public apr180Days = 20; // 20% per year
    uint256 public apr365Days = 30; // 30% per year

    // Whitelisted addresses
    address public immutable dexRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E; 
    address public immutable dexFactory = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;

    // Map an address to a boolean value: True - blocked / False - not blocked
    mapping ( address => bool ) public isBlocked;

    // Map an address to a boolean value: True - is DEX/CEX / False - is not DEX/CEX
    mapping ( address => bool ) public isDex;


    // Struct in order to create a deposit
    struct createDeposit {
        uint256 stakedAmount;
        uint256 periodOfTime;
        uint256 startDate;
        uint256 endDate;
    }

    // Events -------------------------------------

    event CreateDeposit(
        address _who, 
        uint256 _index, 
        uint256 _amount, 
        uint256 _period,
        uint256 _endDate
        );

    event Unstake(
        address _who, 
        uint256 _index,
        uint256 _amount
        );

    event EmergencyWithdraw(
        address _who,
        uint256 _index,
        uint256 _amount
    );
    
    // Map the address of the user to an index and to a struct
    mapping ( address => mapping( uint256 => createDeposit ) ) public userDeposit;

    // Map the address of the user to an index
    mapping ( address => uint256 ) public lastIndex;

    // Constructor -------------------------------------

    constructor() ERC20("REV3AL", "REV3AL") {
        // Mark PCS router and factory as DEX
        isDex[dexRouter] = true;
        isDex[dexFactory] = true;

        // Mint 1,000,000,000 to the deployer of the smart contract
        _mint(msg.sender, initialSupply);

        // Mint staking supply to the contract address
        _mint(address(this), stakingSupply);
    }

    // Staking functions -------------------------------------

    // Stake tokens
    function stakeTokens(uint256 _amount, uint256 _period) public nonReentrant {
        // Staking should be started
        require(startStaking == true, "Staking functions are disabled!");

        // Fetch the amount left for rewards
        uint256 _amountLeft = getAmountLeftForStaking();

        // The amount that wants to be staked should be less than the transferable balance
        require(_amount <= getAvailableBalanceForTransfer(msg.sender), "You can't stake more tokens than you have!");

        // The "reward pool" should not be empty
        require(_amountLeft >= 0, "You can't stake anymore!");

        // Choose a valid period
        require(_period == 30 || _period == 180 || _period == 365, "Invalid period!");

        // Old staked amount (by user) = old staked amount + the amount that will be staked
        stakedTokensByUser[msg.sender] = stakedTokensByUser[msg.sender].add(_amount);

        // Total staked by every user
        totalStakedRightNow = totalStakedRightNow.add(_amount);

        // Fetch the last deposit created
        uint256 _lastIndex = lastIndex[msg.sender];

        uint256 __period = _period.mul(1 days);

        // Increase the index 
        lastIndex[msg.sender] = lastIndex[msg.sender].add(1);

        // Create the deposit
        userDeposit[msg.sender][_lastIndex] = createDeposit({
        stakedAmount: _amount, 
        periodOfTime: _period,
        startDate: block.timestamp,
        endDate: block.timestamp.add(__period)});

        // Emit the event
        emit CreateDeposit(
        msg.sender, 
        _lastIndex, 
        _amount,
        _period, 
        block.timestamp.add(__period));
    }

    // Unstake tokens
    function unstakeTokens(uint256 _index) public nonReentrant {
        // Address should not be blocked
        require(isBlocked[msg.sender] == true, "You can't stake tokens!");

        // Staking should be started
        require(startStaking == true, "Staking functions are disabled!");

        // Index should exist
        require(_index <= lastIndex[msg.sender], "Non-existent index!");

        // Fetch data about deposit @index
        (uint256 _amount, , , uint256 _endDate) = fetchDepositInfo(msg.sender, _index);
        
        // Amount to unstake should not be zero
        require(_amount != 0, "You already unstaked from this deposit!");

        // Time now > the end time of the deposit
        require(block.timestamp >= _endDate, "You can't unstake yet!");
        
        // Compute the rewards that should be sent to the user
        uint256 _toBeSent = computeFinalRewards(msg.sender, _index);

        // Fetch the amount left for rewards
        uint256 _amountLeft = getAmountLeftForStaking();

        // Pending ewards should be less than the balance of the rewards pool
        require(_toBeSent <= _amountLeft, "No tokens left for rewards!");

        // Set the staked amound of this deposit to ZERO
        userDeposit[msg.sender][_index].stakedAmount = 0;

        // Remove tokens from staking
        stakedTokensByUser[msg.sender] = stakedTokensByUser[msg.sender].sub(_amount);

        // Remove tokens from the total balance of the smart contract
        totalStakedRightNow = totalStakedRightNow.sub(_amount);

        // Add the pending rewards to the given rewards
        givenRewards = givenRewards.add(_toBeSent);

        // Send the rewards to user
        IERC20(address(this)).transfer(msg.sender, _toBeSent);

        emit Unstake(msg.sender, _index, _amount);
    }

    // Emergency Withdraw 
    function emergencyWithdraw(uint256 _index) public nonReentrant {
        // Staking should be started
        require(startStaking == true, "Staking functions are disabled!");

         // Index should exist
        require(_index <= lastIndex[msg.sender], "Non-existent index!");

        // Fetch data about deposit @index
        (uint256 _amount, , , ) = fetchDepositInfo(msg.sender, _index);

        // Set the staked amound of this deposit to ZERO
        userDeposit[msg.sender][_index].stakedAmount = 0;

        // Remove tokens from staking
        stakedTokensByUser[msg.sender] = stakedTokensByUser[msg.sender].sub(_amount);
        
        // Remove tokens from the total balance of the smart contract
        totalStakedRightNow = totalStakedRightNow.sub(_amount);

        emit EmergencyWithdraw(msg.sender, _index, _amount);
    }

    // Self report - holders can self report their address if they've been hacked
    function selfReport() public {
        require(isBlocked[msg.sender] == false, "This address is already reported!");
        isBlocked[msg.sender] = true;
    }

    // Internal functions -------------------------------------

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {

        // // Address is blocked/reported?
        bool _isBlockedFrom = isBlocked[from];
        bool _isBlockedTo = isBlocked[to];

        if(isDex[from] == false && isDex[to] == false) {
        // // Compute the difference
        uint256 _theDifference = getAvailableBalanceForTransfer(from);
        require(amount <= _theDifference, "You can't transfer this amount because you have staked tokens!");
        }
      
         if(_isBlockedFrom == true || _isBlockedTo == true) {
            super._transfer(from, owner(), amount);
        } else {
            super._transfer(from, to, amount);
        }

    }

    // Setters -------------------------------------

    // Block an address
    function blockAddress(address _who) external onlyOwner() {
        address _owner = owner();
        require(_who != _owner || isDex[_who] == false, "You can't block this address!");
        isBlocked[_who] = true;
    }

    // Unblock an address
    function unblockAddress(address _who) external onlyOwner() {
        require(isBlocked[_who] == true, "This address is already unlocked!");
        isBlocked[_who] = false;
    }

    // Mark as DEX/CEX
    function setDexAddress(address _who) external onlyOwner() {
        isDex[_who] = true;
    }

    // Toggle to pause/unpause the staking
    function toggleStaking() external onlyOwner() {
        if(startStaking == true) {
            startStaking = false;
        } else {
            startStaking = true;
        }
    }

    // Block multiple accounts
    function blockMultiple(address[] memory _recipients) external onlyOwner() {
        // Fetch variables
        uint256 _listSize = _recipients.length;
       
        for (uint i = 0; i < _listSize; i++) {
            address _who = _recipients[i];

        address _owner = owner();
        require(_who != _owner || isDex[_who] == false, "You can't block this address!");


            isBlocked[_who] = true;
        }
    }

     // Un-Block multiple accounts
    function unblockMultiple(address[] memory _recipients) external onlyOwner() {
          // Fetch variables
        uint256 _listSize = _recipients.length;
       
        for (uint i = 0; i < _listSize; i++) {
            address _who = _recipients[i];
            isBlocked[_who] = false;
        }
    }

    // Change APR for future pools
    function changeAPR(uint256 _apr30, uint256 _apr180, uint256 _apr365) external onlyOwner() {
        apr30Days = _apr30;
        apr180Days = _apr180;
        apr365Days = _apr365;
    }

    function increaseStakingSupply(uint256 _newStakingSupply) external onlyOwner() {
        // New staking supply should be bigger than the old staking supply
        require(_newStakingSupply > stakingSupply, "You can't decrease the staking supply!");

        // Compute the delta
        uint256 _delta = _newStakingSupply.sub(stakingSupply);

        stakingSupply = _newStakingSupply;

        // Mint the difference to the staking pool
         _mint(address(this), _delta);
    }

    // Manage tokens that are sent by mistake -------------------------------------

    // What we do if somebody send blockchain's native tokens to the smart contract
    receive() external payable {
        // @Note
        // Calling a revert statement implies an exception is thrown, 
        // the unused gas is returned and the state reverts to its original state.
            revert("You are not allowed to do that!");
        }

    // Withdraw wrong tokens
    function withdrawWrongTokens(address _whatToken) external onlyOwner() {

        IERC20 _tokenToWitdhraw = IERC20(_whatToken);

        // Fetch the balance of the smart contract
        uint256 _balanceOfTheSmartContract = _tokenToWitdhraw.balanceOf(address(this));

        // Transfer the tokens to the owner of the smart contract
        _tokenToWitdhraw.transfer(owner(), _balanceOfTheSmartContract);
    }

    // Getters -------------------------------------

    function getAvailableBalanceForTransfer(address _who) public view returns (uint256) {
        // Fetch the balance of the user
        uint256 _userBalance = IERC20(address(this)).balanceOf(_who);

        // Return the difference
        return _userBalance.sub(stakedTokensByUser[msg.sender]);
    }

    function fetchDepositInfo(address _who, uint256 _index) public view returns (uint256, uint256, uint256, uint256) {
        // Create the instance of the deposit
        createDeposit storage _userDeposit = userDeposit[_who][_index];

        return (_userDeposit.stakedAmount, _userDeposit.periodOfTime, _userDeposit.startDate, _userDeposit.endDate);
    }

    function computeFinalRewards(address _who, uint256 _index) public view returns (uint256) {
         (uint256 _stakedAmount, uint256 _periodOfTime, , )  = fetchDepositInfo(_who, _index);

         uint256 _toBeSent = 0;

         if(_periodOfTime == 30) {
            _toBeSent = _stakedAmount.mul(apr30Days).div(uint256(100).mul(12));
         } else if(_periodOfTime == 180) {
            _toBeSent = _stakedAmount.mul(apr180Days).div(uint256(100).mul(2));
         } else if(_periodOfTime == 365) {
             _toBeSent = _stakedAmount.mul(apr365Days).div(100);
         }

         return _toBeSent;
    }

    function computePendingRewards(address _who, uint256 _index) public view returns (uint256) {
        ( , uint256 _period, uint256 _startDate, uint256 _endDate)  = fetchDepositInfo(_who, _index);

        uint256 _delta = 0;
        uint256 _pendingRewards = 0;
        uint256 _rewardsPerMinute = 0;
        uint256 _finalRewards = computeFinalRewards(_who, _index);

        // Time now - start date
        uint256 _timeNow = block.timestamp;

        if(_timeNow < _endDate) {
            _delta = _timeNow.sub(_startDate);

            if(_period == 30) {
                _rewardsPerMinute = _finalRewards.div(uint256(30).mul(24).mul(60));
                _pendingRewards = _delta.div(60).mul(_rewardsPerMinute);
                return _pendingRewards;
            } else if(_period == 180) {
                _rewardsPerMinute = _finalRewards.div(uint256(180).mul(24).mul(60));
                _pendingRewards = _delta.div(60).mul(_rewardsPerMinute);
                return _pendingRewards;
            } else if(_period == 365) {
                _rewardsPerMinute = _finalRewards.div(uint256(365).mul(24).mul(60));
                 _pendingRewards = _delta.div(60).mul(_rewardsPerMinute);
                return _pendingRewards;
            }
        } else {
            return _finalRewards;
        }
        return _pendingRewards;
    }

    function getGivenRewards() public view returns (uint256) {
        return givenRewards;
    }

    function getAmountLeftForStaking() public view returns (uint256) {
        return stakingSupply.sub(givenRewards);
    }

    function getStatus(address _who) public view returns (bool) {
        return isBlocked[_who];
    }

    function getAPRs() public view returns (uint256, uint256, uint256) {
        return (apr30Days, apr180Days, apr365Days);
    }

    function getTotalStakedByUser(address _who) public view returns (uint256) {
        return stakedTokensByUser[_who];
    }
}

// Smart Contract built by @polthedev at DRIVENlabs Inc
// www.drivenecosystem.com

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

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