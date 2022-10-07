pragma solidity ^0.8.0;

import "../interfaces/IStandardTokenMock.sol";
import "../../interfaces/wombat/IMasterWombat.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "./IMultiRewarder.sol";

contract MasterWombatMockRewardPersec is IMasterWombat {

    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 available; // in case of locking
    }

    // Info of each pool.
    struct PoolInfo {
        address lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. MGPs to distribute per second.
        uint256 lastRewardTimestamp; // Last timestamp that MGPs distribution occurs.
        uint256 accRewardPerShare; // Accumulated MGPs per share, times 1e12. See below.

        // storage slot 2
        IMultiRewarder rewarder;
    }

    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    mapping(uint256 => PoolInfo) public pidToPoolInfo;
    // amount everytime deposit or withdraw will get

    mapping (address => uint256) public lpToPid;

    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint;
    address public rewardToken;
    // MGP tokens created per second.
    uint256 public rewardPerSec;
    // Info of each pool.
    PoolInfo[] public poolInfo;
    // reward upon each deposit and withdraw call;
    

    // The timestamp when MGP mining starts.
    uint256 public startTimestamp;    

    constructor(address _rewardToken,
                uint256 _rewardPerSec
    ) {
        rewardToken = _rewardToken;
        rewardPerSec = _rewardPerSec;
        startTimestamp = block.timestamp;
        totalAllocPoint = 0;
    }

    function getAssetPid(address lp) override external view returns(uint256) {
        return lpToPid[lp];
    }

    /// @notice Deposit LP tokens to Master Magpie for MGP allocation.
    /// @dev it is possible to call this function with _amount == 0 to claim current rewards
    function depositFor(uint256 _pid, uint256 _amount, address _account) override external {
        _deposit(_pid, _amount, _account);
    }

    function deposit(uint256 _pid, uint256 _amount) override external returns (uint256, uint256) {
        _deposit(_pid, _amount, msg.sender);
    }

    function _deposit(uint256 _pid, uint256 _amount, address _account) internal {
        updatePool(_pid);
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_account];
        
        IERC20 poolLpToken = IERC20(pool.lpToken);        
        
        poolLpToken.transferFrom(address(msg.sender), address(this), _amount);

        if (user.amount > 0) {
            _harvest(_pid, _account);            
        }

        user.amount += _amount;
        user.rewardDebt = (user.amount * pool.accRewardPerShare) / 1e12;
    }
 
    function withdraw(uint256 _pid, uint256 _amount) override external returns (uint256, uint256) {
        updatePool(_pid);
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount && user.amount > 0,  'withdraw: not good');
        
        _harvest(_pid, msg.sender);
        user.amount = user.amount - _amount;
        user.rewardDebt = (user.amount * pool.accRewardPerShare) / 1e12;

        IERC20 poolLpToken = IERC20(pool.lpToken);
        poolLpToken.transfer(address(msg.sender), _amount);
    }

    function multiClaim(uint256[] memory _pids) override external returns (
        uint256,
        uint256[] memory,
        uint256[] memory
    ) {
        uint256[] memory amounts = new uint256[](_pids.length);
        uint256[] memory additionalRewards= new uint256[](_pids.length);

        for (uint256 i = 0; i < _pids.length; i++) {            
            PoolInfo storage pool = poolInfo[_pids[i]];
            UserInfo storage user = userInfo[_pids[i]][msg.sender];
            updatePool(_pids[i]);
            if (user.amount > 0)
                _harvest(_pids[i], msg.sender);
            user.rewardDebt = (user.amount * pool.accRewardPerShare) / 1e12;
        }
        
        return (0, amounts, additionalRewards); // return value is wrong
    }


    function safeWOMTransfer(address payable to, uint256 _amount) internal {
        IStandardTokenMock(rewardToken).mint(to, _amount);
    }

    function addPool(address lp, uint256 _allocpoint, address _rewarder) external returns (uint256) {
        PoolInfo memory newPool = PoolInfo(lp, _allocpoint, block.timestamp, 0, IMultiRewarder(_rewarder));
        poolInfo.push(newPool);
        uint256 poolId = poolInfo.length - 1;
        pidToPoolInfo[poolId] = newPool;        
        lpToPid[lp] = poolId;
        totalAllocPoint = totalAllocPoint + _allocpoint;
        return poolId;
    }

    function setPool(address lp, uint256 _allocpoint, IMultiRewarder _rewarder) external {
        require(lpToPid[lp] != 0);

        PoolInfo storage pool = pidToPoolInfo[lpToPid[lp]];
        pool.allocPoint = _allocpoint;
        pool.rewarder = _rewarder;
    }

    function pendingTokens(uint256 _pid, address _user) public override view
        returns (
            uint256 pendingRewards,
            IERC20[] memory bonusTokenAddresses,
            string[] memory bonusTokenSymbols,
            uint256[] memory pendingBonusRewards
        ) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accRewardPerShare = pool.accRewardPerShare;
        uint256 lpSupply = IERC20(pool.lpToken).balanceOf(address(this));
        
        if (block.timestamp > pool.lastRewardTimestamp && lpSupply != 0) {
            uint256 multiplier = block.timestamp - pool.lastRewardTimestamp;
            uint256 rewards = (multiplier * accRewardPerShare * pool.allocPoint) /
            totalAllocPoint;
            accRewardPerShare = accRewardPerShare + (rewards * 1e12) / lpSupply;
        }

        pendingRewards = (user.amount * accRewardPerShare) / 1e12 - user.rewardDebt;

        // If it's a double reward farm, we return info about the bonus token
        if (address(pool.rewarder) != address(0)) {
            (bonusTokenAddresses, bonusTokenSymbols) = rewarderBonusTokenInfo(_pid);
            pendingBonusRewards = pool.rewarder.pendingTokens(_user);
        }
    }

    /// @notice Get bonus token info from the rewarder contract for a given pool, if it is a double reward farm
    /// @param _pid the pool id
    function rewarderBonusTokenInfo(uint256 _pid)
        public
        view
        returns (IERC20[] memory bonusTokenAddresses, string[] memory bonusTokenSymbols)
    {
        PoolInfo storage pool = poolInfo[_pid];
        if (address(pool.rewarder) == address(0)) {
            return (bonusTokenAddresses, bonusTokenSymbols);
        }

        bonusTokenAddresses = pool.rewarder.rewardTokens();
        uint256 len = bonusTokenAddresses.length;
        bonusTokenSymbols = new string[](len);
        for (uint256 i; i < len; ++i) {
            if (address(bonusTokenAddresses[i]) == address(0)) {
                bonusTokenSymbols[i] = 'BNB';
            } else {
                bonusTokenSymbols[i] = IERC20Metadata(address(bonusTokenAddresses[i])).symbol();
            }
        }
    }

    /// @notice Harvest MGP for an account
    function _harvest(uint256 _pid, address _account) internal {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_account]; 
        // Harvest MGP
        uint256 pending = (user.amount * pool.accRewardPerShare) /
            1e12 -
            user.rewardDebt;
        IStandardTokenMock(rewardToken).mint(_account, pending);
    }

    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.timestamp <= pool.lastRewardTimestamp) {
            return;
        }
        uint256 lpSupply = IERC20(pool.lpToken).balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardTimestamp = block.timestamp;
            return;
        }
        uint256 multiplier = block.timestamp - pool.lastRewardTimestamp;
        uint256 mgpReward = (multiplier * rewardPerSec * pool.allocPoint) /
            totalAllocPoint;
        
        pool.accRewardPerShare = pool.accRewardPerShare + ((mgpReward * 1e12) / lpSupply);
        pool.lastRewardTimestamp = block.timestamp;
    }
}

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IStandardTokenMock is IERC20 {

    function mint(address _to, uint256 _amount) external;

    function burn(address _from, uint256 _amount) external;
}

pragma solidity ^0.8.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IMasterWombat {

    function getAssetPid(address lp) external view returns(uint256);
    
    function depositFor(uint256 pid, uint256 amount, address account) external;

    function deposit(uint256 _pid, uint256 _amount) external returns (uint256, uint256);

    function withdraw(uint256 _pid, uint256 _amount) external returns (uint256, uint256);

    function multiClaim(uint256[] memory _pids) external returns (
        uint256 transfered,
        uint256[] memory amounts,
        uint256[] memory additionalRewards
    );

    function pendingTokens(uint256 _pid, address _user) external view
        returns (
            uint256 pendingRewards,
            IERC20[] memory bonusTokenAddresses,
            string[] memory bonusTokenSymbols,
            uint256[] memory pendingBonusRewards
    );
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

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

interface IMultiRewarder {
    function onReward(address _user, uint256 _lpAmount) external returns (uint256[] memory rewards);

    function pendingTokens(address _user) external view returns (uint256[] memory rewards);

    function rewardTokens() external view returns (IERC20[] memory tokens);

    function rewardLength() external view returns (uint256);
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