// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Miner {
    ERC20 public mainToken;
    ERC20 public busd = ERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7); // busd testnet
    address public owner;
    uint public totalMiners;
    uint public busdMinerRate;
    uint private minerTokenRate = 13; // 13% of tm == mainToken mined
    uint public busdDailyPercentage = 3;
    uint public minimumCompoundRequired = 7;
    uint public minimumDaysRequired = 7;
    uint public minimumDeposit = 10;
    uint public maximumDeposit = 500;
    uint public mineDuration = 86400; // 24 hours timestamp
    uint public referralPercentage = 10;
    address public devAddress; 
    address public taxAddress; 
    bool public isMinerRunning = false;
    struct userInfo {
        uint miners;
        uint totalDeposit;
        uint totalCompounded;
        uint compoundCount;
        uint lastWithdrawTime;
        uint lastCompoundTime;
        uint totalTokensMined;
        uint currentTokensMined;
        address referral;
        uint referralBonus;
    }
    mapping(address => userInfo) public user;

    constructor(ERC20 _mainToken) {
        mainToken = _mainToken;
        owner = msg.sender;
        devAddress = msg.sender;
        taxAddress = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Not authorized");
        _;
    }
    modifier isRunning() {
        require(isMinerRunning == true, "Miner has not launched yet");
        _;
    }
    modifier hasDeposit() {
        require(
            user[msg.sender].totalDeposit > 0,
            "No deposit has been made by this user"
        );
        _;
    }

    function launch(uint amount) public onlyOwner {
        require(isMinerRunning == false, "Miner already launched");
        busd.transferFrom(msg.sender, address(this), amount);
        totalMiners = (10 * busdBalance()) / 1e18;
        busdMinerRate = (totalMiners * 1e18) / busdBalance();
        isMinerRunning = true;
        user[msg.sender].miners = totalMiners;
        addDepositToUser(amount);
    }

    function deposit(uint amount, address ref) public isRunning {
        require(minimumDeposit <= amount && maximumDeposit >= amount,"Deposit amount out of specified range");
        busd.transferFrom(msg.sender, address(this), amount);
        
        uint currentMiners = ((amount / 1e18) * busdMinerRate) / 2;
        totalMiners += currentMiners;
        user[msg.sender].miners += currentMiners;
        addDepositToUser(amount);
        // check and transfer referral bonus
        transferReferralBonus(amount, msg.sender, ref);
        updateBusdMinerRate();
    }

    function transferReferralBonus(uint _amount, address _user, address ref) private {
        // if this is the user's first deposit then set his upline
        if(user[_user].totalDeposit == 0){
            user[_user].referral = ref != address(0) ? ref : devAddress;
        }
        // make the transfer
        uint _transferAmount = ((referralPercentage *1e18) * _amount) / (100 * 1e18);
        busd.transfer(ref, _transferAmount);

        // update the refs referral bonus
        user[ref].referralBonus += _transferAmount;

    }

    function mineTokens() public isRunning hasDeposit {
        // require(
        //     user[msg.sender].totalDeposit > 0,
        //     "No deposit has been made by this user"
        // );
        uint lastCompound = block.timestamp - user[msg.sender].lastCompoundTime;
        require(lastCompound >= mineDuration, "You cannot mine now");
        claimTokens(msg.sender);
        compound(msg.sender);
    }

    function withdraw(uint _amount) public isRunning hasDeposit {
        bool isRequirementMet = user[msg.sender].compoundCount >= minimumDaysRequired && user[msg.sender].compoundCount >= minimumCompoundRequired;
        require(isRequirementMet, "Withdrawal Requirements not met");

        uint maxWithdrawal = user[msg.sender].totalCompounded - user[msg.sender].totalDeposit;
        require(_amount <= maxWithdrawal, "Amount exceeds profit earned");

        // Transfer profit in stables
        busd.approve(address(this), _amount);
        busd.transferFrom(address(this), msg.sender, _amount);

        // Transfer token mined
        mainToken.approve(address(this), user[msg.sender].currentTokensMined);
        mainToken.transferFrom(address(this),msg.sender, user[msg.sender].currentTokensMined);

        // deduct stables from user
        user[msg.sender].totalCompounded -= _amount;

        // reset user compound count
        user[msg.sender].compoundCount = 0;

        // update last withdraw time and compound time
        user[msg.sender].lastWithdrawTime = user[msg.sender].lastCompoundTime = block.timestamp;

        // deduct tokens mined
        user[msg.sender].currentTokensMined = 0;

        updateBusdMinerRate();
    }

    function getDailyBusdRewards(address _user) public view returns (uint) {
        uint lastCompound = block.timestamp - user[_user].lastCompoundTime;
        if (lastCompound >= mineDuration) {
            return
                ((busdDailyPercentage * 1e18) * user[_user].totalCompounded) /
                (100 * 1e18);
        }
        return 0;
    }

    function compound(address _user) private {
        // compound rewards and update user's miners

        uint dailyBusdReward = getDailyBusdRewards(_user);
        uint currentMiners = ((dailyBusdReward / 1e18) * busdMinerRate) / 2;
        totalMiners += currentMiners;
        user[msg.sender].miners += currentMiners;
        user[msg.sender].totalCompounded += dailyBusdReward;
        user[msg.sender].compoundCount += 1;
        user[msg.sender].lastCompoundTime = block.timestamp;
        updateBusdMinerRate();
    }

    function claimTokens(address _user) private {
        // claim mined tokens
        // calculate the tokens mined based on the mining rate and multiply by mineDuration converted to hours
        uint tokenMined = ((minerTokenRate * user[_user].miners) / 100) * (mineDuration / 3600);
        user[_user].totalTokensMined += tokenMined;
        user[_user].currentTokensMined += tokenMined;
    }

    function addDepositToUser(uint _amount) private {
        user[msg.sender].totalDeposit += _amount;
        user[msg.sender].totalCompounded += _amount;
        user[msg.sender].lastCompoundTime = block.timestamp;
    }

    function updateBusdMinerRate() private {
        busdMinerRate = (totalMiners * 1e18) / busdBalance();
    }

    function transferOwnership(address _owner) public onlyOwner {
        owner = _owner;
    }

    function setBusdDailyPercentage(uint _busdDailyPercentage)
        public
        onlyOwner
    {
        busdDailyPercentage = _busdDailyPercentage;
    }

    function setMinerDuration(uint _mineDuration) public onlyOwner {
        mineDuration = _mineDuration;
    }

    function setMainToken(ERC20 _newMainToken) public onlyOwner {
        mainToken = _newMainToken;
    }

    function setMinimumRequirements(
        uint _minimumCompoundRequired,
        uint _minimumDaysRequired
    ) public onlyOwner {
        minimumCompoundRequired = _minimumCompoundRequired;
        minimumDaysRequired = _minimumDaysRequired;
    }

    function setDepositRange(uint _min, uint _max) public onlyOwner {
        minimumDeposit = _min;
        maximumDeposit = _max;
    }
    function setReferralPercentage(uint _referralPercentage) public onlyOwner {
        referralPercentage = _referralPercentage;
    }

    function setDevAddress(address _devAddress) public onlyOwner {
        devAddress = _devAddress;
    }
    function setTaxAddress(address _taxAddress) public onlyOwner {
        taxAddress = _taxAddress;
    }

    function mainTokenBalance() public view returns (uint) {
        return mainToken.balanceOf(address(this));
    }

    function busdBalance() public view returns (uint) {
        return busd.balanceOf(address(this));
    }
    /***
     *
     *      BATTERY DON DIE -- SOLIDITY, FEAR MY RETURN!!!!
     */
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