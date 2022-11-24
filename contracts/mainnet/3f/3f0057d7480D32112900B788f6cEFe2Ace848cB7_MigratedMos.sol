//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
// import "hardhat/console.sol";

contract MigratedMos is ERC20, Ownable{
    uint256 public constant maxSupply = 136000000000 * 10 ** 18;

    /* Time of contract launch (Wednesday, August 25, 2021 12:00:00 PM UTC) */
    uint256 internal immutable LAUNCH_TIME;

    uint256 internal constant MIN_STAKE_DAYS = 10;
    uint256 internal constant MAX_STAKE_DAYS = 6666;

    uint256 internal constant EARLY_PENALTY_MIN_DAYS = 90;
    uint256 internal constant LATE_PENALTY_GRACE_DAYS = 2 * 7;
    uint256 internal constant LATE_PENALTY_SCALE_DAYS = 100 * 7;

    uint256 internal constant LPB = 364 * 100 / 20;
    uint256 internal constant LPB_MAX_DAYS = LPB * 200 / 100;

    uint256 internal constant BPB_MAX_HEARTS = 80 * 1e6 * 10 ** 18;
    uint256 internal constant BPB = BPB_MAX_HEARTS * 100 / 10;
    
    uint256 internal claimed = 2;


    struct GlobalsStore {
        uint256 lockedHeartsTotal;
        uint256 latestStakeId;
    }

    struct StakeCache {
        uint256 _stakeId;
        uint256 _stakedHearts;
        uint256 _lockedDay;
        uint256 _stakedDays;
        uint256 _unlockedDay;
    }

    struct StakeStore {
        uint256 stakeId;
        uint256 stakedHearts;
        uint256 lockedDay;
        uint256 stakedDays;
        uint256 unlockedDay;
    }

    GlobalsStore public globals;
    mapping(address => StakeStore[]) public stakeLists;

    constructor() ERC20 ("MOS Token","MOS") {
        LAUNCH_TIME = block.timestamp;
    }

    event StakeStart(uint256 amount, uint256 stakeDays, address indexed stakerAddr, uint256 stakeId, uint256 stakeOnDay);
    event StakeEnd(uint256 payout, address indexed stakerAddr, uint256 stakeId, uint256 endDay);

    function currentDay() public view returns (uint256) {   
        return (block.timestamp - LAUNCH_TIME) / 1 days + 1;
    }

    function stakeStart(uint256 amtToStake, uint256 dayToStake) external {
        require(amtToStake > 0, "MOS: Invalid staking amount");
        require(dayToStake >= MIN_STAKE_DAYS, "MOS: Staking day lower than minimum");
        require(dayToStake <= MAX_STAKE_DAYS, "MOS: Staking day higher than maximum");

        uint256 bonusHearts = _stakeStartBonusHearts(amtToStake, dayToStake);
        uint256 totalStakes = amtToStake + bonusHearts;
        uint256 newLockedDay = currentDay() < 1 ? 1 + 1: currentDay() + 1;
        uint256 newStakeId = ++globals.latestStakeId;
        _stakeAdd(stakeLists[msg.sender], newStakeId, amtToStake, newLockedDay, dayToStake);
        emit StakeStart(amtToStake, dayToStake, msg.sender, newStakeId, newLockedDay);
        globals.lockedHeartsTotal += totalStakes;
        _burn(msg.sender, amtToStake);
    }

    function _stakeStartBonusHearts(uint256 amtToStake, uint256 dayToStake) internal pure returns (uint256 bonusHearts) {
        uint256 cappedExtraDays = 0;
        if (dayToStake > 1) {
            cappedExtraDays = dayToStake <= LPB_MAX_DAYS ? dayToStake - 1 : LPB_MAX_DAYS;
        }
        uint256 cappedStakedHearts = amtToStake <= BPB_MAX_HEARTS ? amtToStake : BPB_MAX_HEARTS;
        uint256 bonus = cappedExtraDays * BPB + cappedStakedHearts * LPB;
        bonusHearts = amtToStake * bonus / (LPB * BPB);
        return bonusHearts;
    }

    function _stakeAdd(StakeStore[] storage stakeListRef, uint256 newStakeId, uint256 newStakedHearts, uint256 newLockedDay, uint256 newStakedDays) internal {
        stakeListRef.push(StakeStore(newStakeId, uint256(newStakedHearts), uint256(newLockedDay), uint256(newStakedDays),uint256(0)));
    }

    function stakeEnd(uint256 stakeIndex, uint256 stakeIdParam) external {
        StakeStore[] storage slr = stakeLists[msg.sender];

        /* require() is more informative than the default assert() */
        require(slr.length != 0, "MOS: Empty stake list");
        require(stakeIndex < slr.length, "MOS: stakeIndex invalid");

        StakeCache memory st;
        _stakeLoad(slr[stakeIndex], stakeIdParam, st);
        uint256 servedDays = 0;
        bool prevUnlocked = (st._unlockedDay != 0);
        uint256 stakeReturn;
        uint256 payout = 0;
        uint256 penalty = 0;
        uint256 cappedPenalty = 0;

        if (currentDay() >= st._lockedDay) {
            if (prevUnlocked) {
                servedDays = st._stakedDays;
            } else {
                st._unlockedDay = currentDay();
                servedDays = currentDay() - st._lockedDay;
                if (servedDays > st._stakedDays) {
                    servedDays = st._stakedDays;
                }
            }
            (stakeReturn, payout, penalty, cappedPenalty) = _stakePerformance(st, servedDays);
        } else {
            stakeReturn = st._stakedHearts;
        }

        if (stakeReturn != 0) {
            _mint(msg.sender, stakeReturn);
        }
        emit StakeEnd(stakeReturn, msg.sender, stakeIdParam, currentDay());
        globals.lockedHeartsTotal -= st._stakedHearts;
        _stakeRemove(slr, stakeIndex);
    }

    function _stakeLoad(StakeStore storage stRef, uint256 stakeIdParam, StakeCache memory st) internal view {
        require(stakeIdParam == stRef.stakeId, "MOS: stakeIdParam not in stake");

        st._stakeId = stRef.stakeId;
        st._stakedHearts = stRef.stakedHearts;
        st._lockedDay = stRef.lockedDay;
        st._stakedDays = stRef.stakedDays;
        st._unlockedDay = stRef.unlockedDay;
    }

    function _stakePerformance(StakeCache memory st, uint256 servedDays) internal view returns (uint256 stakeReturn, uint256 payout, uint256 penalty, uint256 cappedPenalty) {
        if (servedDays < st._stakedDays) {
            (payout, penalty) = _calcPayoutAndEarlyPenalty(
                st._stakedDays,
                servedDays,
                st._stakedHearts
            );
            stakeReturn = st._stakedHearts + payout;
        } else {
            payout = (st._stakedHearts * st._stakedDays * 20 / 2920 / 100) + (st._stakedHearts * st._stakedHearts * 10 / 80000000e18 / 100) * 78 / 1000;
            stakeReturn = st._stakedHearts + payout;

            penalty = _calcLatePenalty(st._lockedDay, st._stakedDays, st._unlockedDay, stakeReturn);
        }
        if (penalty != 0) {
            if (penalty > stakeReturn) {
                cappedPenalty = stakeReturn;
                stakeReturn = 0;
            } else {
                cappedPenalty = penalty;
                stakeReturn -= cappedPenalty;
            }
        }
        return (stakeReturn, payout, penalty, cappedPenalty);
    }

    function _calcPayoutAndEarlyPenalty(uint256 stakedDaysParam, uint256 servedDays, uint256 stakeAmt ) internal view returns (uint256 payout, uint256 penalty){
        uint256 penaltyDays = (stakedDaysParam + 1) / 2;
        if (penaltyDays < EARLY_PENALTY_MIN_DAYS) {
            penaltyDays = EARLY_PENALTY_MIN_DAYS;
        }

        if (servedDays == 0) {
            uint256 expected = _estimatePayoutRewardsDay(stakeAmt);
            penalty = expected * penaltyDays;
            return (payout, penalty); // Actual payout was 0
        }

        payout = (stakeAmt * stakedDaysParam * 20 / 2920 / 100) + (stakeAmt * stakeAmt * 10 / 80000000e18 / 100) * 78 / 1000;

        if (penaltyDays > servedDays) {
            penalty = (stakeAmt * servedDays * 20 / 2920 / 100) + (stakeAmt * stakeAmt * 10 / 80000000e18 / 100) * 78 / 1000;
            payout = (stakeAmt * stakedDaysParam * 20 / 2920 / 100) + (stakeAmt * stakeAmt * 10 / 80000000e18 / 100) * 78 / 1000;
            return (payout, penalty);
        }
        return (payout, penalty);
    }

    function _estimatePayoutRewardsDay(uint256 stakeAmt) internal view returns (uint256 payout) {
        /*
        Calculate payout round

        Inflation of 7.80% inflation per 364 days (approx 1 year)
        dailyInterestRate   = 7.8% / 364
                            = 0.078 / 364
                            = 0.00021428571428571427 (approx)

        payout  = allocSupply * dailyInterestRate
                = allocSupply / (1 / dailyInterestRate)
                = allocSupply / (1 / 0.00021428571428571427)
                = allocSupply / 4692.307692307692(approx)
                = allocSupply * 10000 / 46923076 (* 10000/10000 for int precision)
        */
        payout = totalSupply() + globals.lockedHeartsTotal * stakeAmt / 46666666;
        return payout;
    }

    function _stakeRemove(StakeStore[] storage stakeListRef, uint256 stakeIndex) internal {
        uint256 lastIndex = stakeListRef.length - 1;

        /* Skip the copy if element to be removed is already the last element */
        if (stakeIndex != lastIndex) {
            /* Copy last element to the requested element's "hole" */
            stakeListRef[stakeIndex] = stakeListRef[lastIndex];
        }
        /*
            Reduce the array length now that the array is contiguous.
            Surprisingly, 'pop()' uses less gas than 'stakeListRef.length = lastIndex'
        */
        stakeListRef.pop();
    }

    function migrateMint(uint256 _amount) external onlyOwner {
        _mint(msg.sender, _amount);
    }

    function stakeCount(address stakerAddr) external view returns (uint256) {
        return stakeLists[stakerAddr].length;
    }

    function _calcLatePenalty(uint256 lockedDayParam, uint256 stakedDaysParam, uint256 unlockedDayParam, uint256 rawStakeReturn) private pure returns (uint256) {
        /* Allow grace time before penalties accrue */
        uint256 maxUnlockedDay = lockedDayParam + stakedDaysParam + LATE_PENALTY_GRACE_DAYS;
        if (unlockedDayParam <= maxUnlockedDay) {
            return 0;
        }

        /* Calculate penalty as a percentage of stake return based on time */
        return rawStakeReturn * (unlockedDayParam - maxUnlockedDay) / LATE_PENALTY_SCALE_DAYS;
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