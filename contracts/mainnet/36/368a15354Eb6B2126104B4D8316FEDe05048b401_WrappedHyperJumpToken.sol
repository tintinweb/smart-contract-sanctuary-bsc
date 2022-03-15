// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./HyperJumpStation.sol";

contract WrappedHyperJumpToken is Ownable, ERC20("Wrapped HyperJump Token", "xJUMP") {  
  address public hyperJumpToken;
  address public farm;
  uint256 public pid;

  function initWrappedHyperJumpToken(address _jump, address _farm, uint256 _pid) public onlyOwner {
     require(hyperJumpToken == address(0), "Wrapped HyperJumpToken already configured!");
     hyperJumpToken = _jump;
     farm = _farm;
     pid = _pid;
  }

  function wrap(uint256 _amount) public {
     require(IERC20(hyperJumpToken).allowance(_msgSender(), address(this)) >= _amount, "Not allowed to transfer JUMP!");
     require(IERC20(hyperJumpToken).balanceOf(_msgSender()) >= _amount, "Not enough JUMP balance available!");
     IERC20(hyperJumpToken).transferFrom(_msgSender(), address(this), _amount);
     _mint(_msgSender(), _amount);
  }

  function unwrap(uint256 _amount) public {
    _burn(_msgSender(), _amount);
    IERC20(hyperJumpToken).transfer(_msgSender(), _amount);
  }
 
  function deposit(uint256 _amount) public {
     require(IERC20(hyperJumpToken).allowance(_msgSender(), address(this)) >= _amount, "Not allowed to transfer JUMP!");
     require(IERC20(hyperJumpToken).balanceOf(_msgSender()) >= _amount, "Not enough JUMP balance available!");
     IERC20(hyperJumpToken).transferFrom(_msgSender(), address(this), _amount);
     _mint(address(this), _amount);
     IERC20(this).approve(farm, _amount);
     HyperJumpStation(farm).depositFor(pid, _amount, _msgSender());
  }

  function withdraw(uint256 _amount) public {
     HyperJumpStation(farm).withdrawFor(pid, _amount, _msgSender());
     _burn(_msgSender(), _amount);
     IERC20(hyperJumpToken).transfer(_msgSender(), _amount);
  }

}

// SPDX-License-Identifier: MIT

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

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
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
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
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./IFarmActionInitiators.sol";
import "./IHyperswapBreakLP.sol";
import "./IHyperswapPair.sol";
import "./IHyperJumpTokenDistributor.sol";

contract HyperJumpStation is Ownable, ReentrancyGuard {
  using SafeERC20 for IERC20;

  uint256 public constant TRANSACTION_DEADLINE = 20 * 60 * 1000; // 20 minutes transaction deadline (same default as in UI)
  uint256 public constant MAX_TRADE_EMISSION_PERCENTAGE = 2000; // 20.00% maximum configurable trade emission percentage
  uint256 public constant MAX_PCT = 10000; // max percentage is  100.00%

  // Info of each user.
  struct UserInfo {
    uint256 amount; // How many tokens the user has provided.
    uint256 rewardDebt; // Reward debt. See explanation below.
    uint256 tradeAmount;
    uint256 tradeRewardDebt;
    //
    // We do some fancy math here. Basically, any point in time, the amount of ALLOY
    // entitled to a user but is pending to be distributed is:
    //
    //  pending reward = (user.amount * pool.accRewardPerShare) - user.rewardDebt
    //
    // Whenever a user deposits or withdraws tokens to a pool. Here's what happens:
    //   1. The pool's `accRewardPerShare` (and `lastRewardTime`) gets updated.
    //   2. User receives the pending reward sent to his/her address.
    //   3. User's `amount` gets updated.
    //   4. User's `rewardDebt` gets updated.
  }
  // Info of each user that stakes tokens.
  mapping(uint256 => mapping(address => UserInfo)) public userInfo;

  // Info of each pool.
  struct PoolInfo {
    address token; // Address of staked token contract.
    uint256 totalTradeAmount; // the total of user trade amounts
    uint256 totalTradeAmountFloor; // the total of user trade amounts when last claimed
    uint256 allocPoint; // How many allocation points assigned to this pool. reward token to distribute per second.
    uint256 lastRewardTime; // Last timestamp that reward distribution occured.
    uint256 accRewardPerShare; // Accumulated reward per share, times claimable_precision. See below.
    uint256 accRewardPerTrade; // Accumulated reward per trade, times claimable_precision. See below.
    uint256 startTime; // first time when the pool starts emitting rewards
    uint256 endTime; // last time when the pool emits rewards
    uint256 claimable_precision; // claimable precision which is 1e12 for a token with 18 decimals, it is 1e24 for a token with 6 decimals and 1e30 for a token with no decimals
  }
  // Info of each pool.
  PoolInfo[] public poolInfo;
  // Total allocation points. Must be the sum of all allocation points in all pools.
  uint256 public totalAllocPoint = 0;

  // Info of each emission receiver.
  struct ReceiverInfo {
    address receiver; // Address of receiver contract.
    uint256 percentage; // percentage of emission assigned to this receiver.
  }
  // List of emission receivers.
  ReceiverInfo[] public receiverInfo;
  // Total distribution points. Must be the sum of all distribution points in all pools.
  uint256 public totalRecieverPercentage = 0;

  IERC20 public hyperJumpToken;
  IHyperJumpTokenDistributor public hyperJumpTokenDistributor;

  // farm parameters
  uint256 public emission_per_second; // emission per second. bsc = 3 sec/block ftm = 1 sec/block
  uint256 public minFarmEmissionPercentage;
  uint256 public tradeEmissionPercentage;

  // pair corresponding pid
  mapping(address => uint256) public pidByPair;

  // routers which are allowed to mint
  mapping(address => bool) public swapminter;
  // routers for LP token
  mapping(address => address) public lpRouter;

  address public burn_contract;
  IFarmActionInitiators public actionInitiators;

  event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
  event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
  event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

  event DepositFor(address indexed user, uint256 indexed pid, uint256 amount, address indexed ultimateBeneficialOwner);
  event WithdrawFor(address indexed user, uint256 indexed pid, uint256 amount, address indexed ultimateBeneficialOwner);
  event EmergencyWithdrawFor(address indexed user, uint256 indexed pid, uint256 amount, address indexed ultimateBeneficialOwner);
  event BreakLpFor(address indexed user, uint256 indexed pid, uint256 amount, address indexed ultimateBeneficialOwner);

  event Claimed(address indexed user, uint256 indexed pid, uint256 amount, uint256 timestamp);
  event TradeDeposit(address indexed user, uint256 indexed pid, uint256 amount);
  event SyncedEmission(uint256 timestamp, uint256 amount, uint256 seconds_in_period);

  function initStation(
    IERC20 _hyperJumpToken,
    IHyperJumpTokenDistributor _hyperJumpTokenDistributor,
    uint256 _emission_per_second,
    uint256 _minFarmPercentage,
    uint256 _trade_emission_percentage,
    uint256 _burn_percentage,
    address _burn_contract,
    IFarmActionInitiators _actionInitiators
  ) external onlyOwner {
    require(address(hyperJumpToken) == address(0), "!reinit");
    hyperJumpToken = _hyperJumpToken;
    hyperJumpTokenDistributor = _hyperJumpTokenDistributor;
    emission_per_second = _emission_per_second;
    minFarmEmissionPercentage = _minFarmPercentage;
    tradeEmissionPercentage = _trade_emission_percentage;

    // add receiver BURN_CONTRACT = 20.00% burn percentage as per vote. can be changed later
    burn_contract = _burn_contract;
    addReceiver(_burn_percentage, burn_contract);
    
    actionInitiators = _actionInitiators;
  }

  function poolLength() public view returns (uint256) {
    return poolInfo.length;
  }

  function receiverLength() public view returns (uint256) {
    return receiverInfo.length;
  }

  // we check for dupe pool
  function checkForDuplicate(address _token) internal view {
    uint256 length = poolInfo.length;
    for (uint256 _pid = 0; _pid < length; _pid++) {
      require(poolInfo[_pid].token != _token, "!duplicate pool");
    }
  }

  // we check for dupe receiver
  function checkForDuplicateReceiver(address _receiver) internal view {
    uint256 length = receiverInfo.length;
    for (uint256 _rid = 0; _rid < length; _rid++) {
      require(receiverInfo[_rid].receiver != _receiver, "addReceiver: !duplicate");
    }
  }

  // Add a new lp to the pool. Can only be called by the owner.
  function add(uint256 _allocPoint, address _token, uint256 _start_time, uint256 _end_time, bool _withUpdate) public onlyOwner {
    if (_withUpdate) {
      massUpdatePools();
    }
    
    // check for duplicate pool
    checkForDuplicate(_token);
    
    uint256 lastRewardTime = (block.timestamp > _start_time) ? block.timestamp : _start_time;
    totalAllocPoint = totalAllocPoint + _allocPoint;
    uint256 claimable_precision = 10**(30 - IERC20Metadata(_token).decimals());
    poolInfo.push(
      PoolInfo({
        token: _token,
        totalTradeAmount: 0,
        totalTradeAmountFloor: 0,
        allocPoint: _allocPoint,
        lastRewardTime: lastRewardTime,
        accRewardPerShare: 0,
        accRewardPerTrade: 0,
        startTime: _start_time,
        endTime: _end_time,
        claimable_precision: claimable_precision
      })
    );
    pidByPair[_token] = poolLength() - 1;
  }

  // configure LP router to be able to automate breaking LP on hitting stop loss
  function configureLpRouter(address _lp_token, address _lp_router) external onlyOwner {
    require(lpRouter[_lp_token] == address(0), "LP router already configured!");
    lpRouter[_lp_token] = _lp_router;
    IERC20(_lp_token).approve(_lp_router, type(uint256).max);
  }

  // update the tradeEmissionPercentage
  function updateTradeEmissionPercentage(uint256 _new_percentage) external onlyOwner {
     require(_new_percentage >= 0 && _new_percentage <= MAX_TRADE_EMISSION_PERCENTAGE, "!allowed trade emission percentage");
     massUpdatePools();
     tradeEmissionPercentage = _new_percentage;
  }
  
  // Update the given pool's ALLOY allocation point. Can only be called by the owner.
  function set(uint256 _pid, uint256 _allocPoint, uint256 _start_time, uint256 _end_time, bool _withUpdate) external onlyOwner {
    if (_withUpdate) {
      massUpdatePools();
    }
    totalAllocPoint = totalAllocPoint - poolInfo[_pid].allocPoint + _allocPoint;
    poolInfo[_pid].allocPoint = _allocPoint;
    poolInfo[_pid].startTime = _start_time;
    poolInfo[_pid].endTime = _end_time;
  }

  /// @dev has a check for dupe receivers. Can only be called by the owner.
  function addReceiver(uint256 _percentage, address _receiver) public onlyOwner {
    checkForDuplicateReceiver(_receiver);
    require(_percentage > 0, "addReceiver: percentage must be more than 0");
    require(totalRecieverPercentage + _percentage + minFarmEmissionPercentage <= MAX_PCT, "addReceiver: percentage exceeds 100.00% !");
    receiverInfo.push(ReceiverInfo({ receiver: _receiver, percentage: _percentage }));
    totalRecieverPercentage += _percentage;
  }

  // Update the given pool's reward allocation point. Can only be called by the owner.
  function setReceiver(uint256 _rid, uint256 _percentage) external onlyOwner {
    require(totalRecieverPercentage - receiverInfo[_rid].percentage + _percentage + minFarmEmissionPercentage <= MAX_PCT, "addReceiver: percentage too high!");
    totalRecieverPercentage = totalRecieverPercentage - receiverInfo[_rid].percentage + _percentage;
    receiverInfo[_rid].percentage = _percentage;
  }

  // View functions to see pending rewards on frontend.
  function pending(uint256 _pid, address _user) public view returns (uint256 pending_farm, uint256 pending_trade) {
    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_pid][_user];
    uint256 total_staked = IERC20(pool.token).balanceOf(address(this));
    uint256 accumulatedRewardsPerShare = pool.accRewardPerShare;
    uint256 accumulatedRewardsPerTrade = pool.accRewardPerTrade;
    uint256 trades_since_last_claim = pool.totalTradeAmount - pool.totalTradeAmountFloor;
    if (block.timestamp > pool.lastRewardTime && (total_staked != 0 || trades_since_last_claim != 0)) {
      uint256 nr_of_seconds = getRewardableSeconds(pool.lastRewardTime, pool.startTime, pool.endTime);
      uint256 total_emission = (totalAllocPoint > 0) ? (emission_per_second * nr_of_seconds * pool.allocPoint) / totalAllocPoint : 0;
      uint256 claimable_farm_emission = (total_emission * (MAX_PCT - totalRecieverPercentage - tradeEmissionPercentage)) / MAX_PCT;
      uint256 claimable_trade_emission = (total_emission * tradeEmissionPercentage) / MAX_PCT;
      if (total_staked != 0) {
         accumulatedRewardsPerShare = accumulatedRewardsPerShare + ((claimable_farm_emission * pool.claimable_precision) / total_staked);
      }
      if (trades_since_last_claim != 0) {
         accumulatedRewardsPerTrade = accumulatedRewardsPerTrade + ((claimable_trade_emission * pool.claimable_precision) / trades_since_last_claim);
      }
    }
    pending_farm = ((user.amount * accumulatedRewardsPerShare) / pool.claimable_precision) - user.rewardDebt;
    pending_trade = ((user.tradeAmount * accumulatedRewardsPerTrade) / pool.claimable_precision) - user.tradeRewardDebt;
  }

  // View function to see pending rewards on frontend.
  function pendingReward(uint256 _pid, address _user) public view returns (uint256) {
    (uint256 pending_farm, uint256 pending_trade) = pending(_pid, _user);
    return pending_farm + pending_trade;
  }

  // check if pid exists
  function pidExists(uint256 _pid) public view returns (bool) {
    bool exists = 0 <= _pid && _pid < poolLength();
    return exists;
  }

  // Return number of rewardable seconds over the given period.
  function getRewardableSeconds(uint256 _from, uint256 _start_time, uint256 _end_time) public view returns (uint256) {
    uint256 from_time = (_from > _start_time) ? _from : _start_time;
    uint256 to_time = (block.timestamp < _end_time) ? block.timestamp : _end_time;
    return (from_time <= _end_time) ? to_time - from_time : 0;
  }

  function claimPoolRewards(uint256 _pid) internal {
    require(pidExists(_pid), "handling non-existing pool!");
    PoolInfo storage pool = poolInfo[_pid];
    if (block.timestamp <= pool.lastRewardTime) {
      return;
    }
    uint256 total_staked = IERC20(pool.token).balanceOf(address(this));
    uint256 trades_since_last_claim = pool.totalTradeAmount - pool.totalTradeAmountFloor;
    if (total_staked == 0 && trades_since_last_claim == 0) {
      pool.lastRewardTime = block.timestamp;
      return;
    }
    uint256 nr_of_seconds = getRewardableSeconds(pool.lastRewardTime, pool.startTime, pool.endTime);
    uint256 total_emission = (totalAllocPoint > 0) ? (emission_per_second * nr_of_seconds * pool.allocPoint) / totalAllocPoint : 0;
    uint256 claimable_farm_emission = total_emission;

    // mint to traders
    uint256 trade_rewards = (total_emission * tradeEmissionPercentage) / MAX_PCT;
    if (trades_since_last_claim != 0) {
      pool.totalTradeAmountFloor = pool.totalTradeAmount;
      pool.accRewardPerTrade = pool.accRewardPerTrade + ((trade_rewards * pool.claimable_precision) / trades_since_last_claim);
    } else {
      // we will "collect" to a BurnContract, which will burn via the token's burn function
      // token has a totalBurned method which registers the amount burned, but only when using the burn function
      hyperJumpTokenDistributor.collectTo(burn_contract, trade_rewards);
    }
    claimable_farm_emission = claimable_farm_emission - trade_rewards; // subtract trade reward emission from claimable emission

    // mint to emission receivers
    uint256 numReceivers = receiverLength();
    for (uint256 _rid = 0; _rid < numReceivers; _rid++) {
      uint256 emission_percentage = receiverInfo[_rid].percentage;
      uint256 receiver_reward = (total_emission * emission_percentage) / MAX_PCT;
      hyperJumpTokenDistributor.collectTo(payable(receiverInfo[_rid].receiver), receiver_reward ); // Mint to receiver address.
      claimable_farm_emission = claimable_farm_emission - receiver_reward; // subtract receiver emission from claimable emission
    }

    // mint claimable emission to farm
    uint256 need_to_mint = claimable_farm_emission + trade_rewards;
    hyperJumpTokenDistributor.collectTo(payable(address(this)), need_to_mint);
    if (total_staked != 0) {
       pool.accRewardPerShare = pool.accRewardPerShare + ((claimable_farm_emission * pool.claimable_precision) / total_staked);
    }
    pool.lastRewardTime = block.timestamp;
  }

  function transferClaimableRewards(uint256 _pid, address _ultimateBeneficialOwner) internal {
    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_pid][_ultimateBeneficialOwner];
    if (user.amount > 0) {
      uint256 claimable_farm_rewards = ((user.amount * poolInfo[_pid].accRewardPerShare) / pool.claimable_precision) - user.rewardDebt;
      uint256 claimable_trade_rewards = ((user.tradeAmount * poolInfo[_pid].accRewardPerTrade) / pool.claimable_precision) - user.tradeRewardDebt;
      uint256 claimable = claimable_farm_rewards + claimable_trade_rewards;
      if (claimable > 0) {
        // Check available rewards, just in case if rounding error causes pool to not have enough balance.
        uint256 available_rewards = hyperJumpToken.balanceOf(address(this));
        uint256 claiming = (claimable < available_rewards) ? claimable : available_rewards;
        hyperJumpToken.transfer(address(_ultimateBeneficialOwner), claiming);
        emit Claimed(_ultimateBeneficialOwner, _pid, claiming, block.timestamp);
      }
    }
  }

  function before_handlePoolRewards(uint256 _pid, address _ultimateBeneficialOwner) internal {
    claimPoolRewards(_pid);
    transferClaimableRewards(_pid, _ultimateBeneficialOwner);
  }
  
  function after_handlePoolRewards(uint256 _pid, address _ultimateBeneficialOwner) internal {
    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_pid][_ultimateBeneficialOwner];
    // update allocation points when pool ends
    if (pool.allocPoint > 0 && block.timestamp > pool.endTime) {
        totalAllocPoint -= pool.allocPoint;
        pool.allocPoint = 0;
    }
    user.rewardDebt = (user.amount * pool.accRewardPerShare) / pool.claimable_precision;
    user.tradeRewardDebt = (user.tradeAmount * pool.accRewardPerTrade) / pool.claimable_precision;
  }

  // Update reward variables for a pool
  function updatePool(uint256 _pid) public {
    before_handlePoolRewards(_pid, msg.sender);
    after_handlePoolRewards(_pid, msg.sender);
  }

  // Update reward variables for all pools. Be careful of gas spending!
  function massUpdatePools() public {
    uint256 length = poolInfo.length;
    for (uint256 pid = 0; pid < length; ++pid) {
      updatePool(pid);
    }
  }

  // orchestrator can calls syncEmission when the emission changes because of changes in the main distributor's weights
  function syncEmission(uint256 _total_amount, uint256 _seconds_in_period) external onlyOwner {
     massUpdatePools();
     emission_per_second = _total_amount / _seconds_in_period;
     emit SyncedEmission(block.timestamp, _total_amount, _seconds_in_period);
  }

  // internal deposit function
  function internal_deposit(uint256 _pid, uint256 _amount, address _depositor, address _ultimateBeneficialOwner) internal returns (uint256 tokens_deposited) {
    before_handlePoolRewards(_pid, _ultimateBeneficialOwner);
    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_pid][address(_ultimateBeneficialOwner)];
    tokens_deposited = 0;
    if (_amount > 0) {
      // do check for deflationary tokens
      uint256 _before = IERC20(pool.token).balanceOf(address(this));
      IERC20(pool.token).transferFrom(address(_depositor), address(this), _amount);
      tokens_deposited = IERC20(pool.token).balanceOf(address(this)) - _before;
      user.amount = user.amount + tokens_deposited;
    }
    after_handlePoolRewards(_pid, _ultimateBeneficialOwner);
    return tokens_deposited;
  }

  // internal withdraw function
  function internal_withdraw(uint256 _pid, uint256 _amount, address _ultimateBeneficialOwner) internal nonReentrant {
    before_handlePoolRewards(_pid, _ultimateBeneficialOwner);
    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_pid][address(_ultimateBeneficialOwner)];
    require(user.amount >= _amount, "Withdraw: amount exceeds balance!");
    if (_amount > 0) {
      user.amount = user.amount - _amount;
      IERC20(pool.token).transfer(address(_ultimateBeneficialOwner), _amount);
    }
    after_handlePoolRewards(_pid, _ultimateBeneficialOwner);
  }

  // Withdraw without caring about rewards. EMERGENCY ONLY.
  function internal_emergencyWithdraw(uint256 _pid, address _ultimateBeneficialOwner) internal nonReentrant returns (uint256 user_amount) {
    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_pid][address(_ultimateBeneficialOwner)];
    user_amount = user.amount;
    IERC20(pool.token).transfer(address(_ultimateBeneficialOwner), user.amount);
    user.amount = 0;
    user.rewardDebt = 0;
    return user_amount;
  }

  // internal break LP function
  function internal_break_LP(uint256 _pid, uint256 _amount, address _initiator, address _ultimateBeneficialOwner) internal nonReentrant {
    before_handlePoolRewards(_pid, _ultimateBeneficialOwner);
    PoolInfo storage pool = poolInfo[_pid];
    require(lpRouter[pool.token] != address(0), "!lpRouterConfigured");
    UserInfo storage user = userInfo[_pid][address(_ultimateBeneficialOwner)];
    require(user.amount >= _amount, "Break LP: amount exceeds balance!");
    if (_amount > 0) {
      user.amount = user.amount - _amount;
      uint256 fee = actionInitiators.calculateBreakLpFee(_initiator, _amount);
      UserInfo storage break_lp_fee_receiver = userInfo[_pid][actionInitiators.break_lp_fee_wallet()];
      break_lp_fee_receiver.amount += fee;
      uint256 lp_to_break = _amount - fee;
      address token0 = IHyperswapPair(pool.token).token0();
      address token1 = IHyperswapPair(pool.token).token1();
      address ubo = _ultimateBeneficialOwner;
      uint256 deadline = block.timestamp + TRANSACTION_DEADLINE;
      IHyperswapBreakLP(lpRouter[pool.token]).removeLiquidity(
        token0,
        token1,
        lp_to_break,
        0,
        0,
        ubo,
        deadline
      );
    }
    after_handlePoolRewards(_pid, _ultimateBeneficialOwner);
  }

  // Deposit tokens
  function deposit(uint256 _pid, uint256 _amount) external nonReentrant {
    uint256 _tokens_deposited = internal_deposit(_pid, _amount, msg.sender,msg.sender);
    emit Deposit(msg.sender, _pid, _tokens_deposited);
  }

  // Withdraw tokens
  function withdraw(uint256 _pid, uint256 _amount) external {
    internal_withdraw(_pid, _amount, msg.sender);
    emit Withdraw(msg.sender, _pid, _amount);
  }

  // Claim yield
  function claim(uint256 _pid) external {
    internal_withdraw(_pid, 0, msg.sender);
  }

  // Deposit for someone else
  function depositFor(uint256 _pid, uint256 _amount, address _ultimateBeneficialOwner) external nonReentrant {
    uint256 _tokens_deposited = internal_deposit(_pid, _amount, msg.sender, _ultimateBeneficialOwner);
    emit DepositFor(msg.sender, _pid, _tokens_deposited, _ultimateBeneficialOwner);
  }

  // Initiate withdraw tokens for someone else (funds are never transfered to the initiator, but always to the ultimate beneficial owner)
  function withdrawFor(uint256 _pid, uint256 _amount, address _ultimateBeneficialOwner) external {
    require(actionInitiators.withdrawInitiator(msg.sender, _ultimateBeneficialOwner),"!withdrawInitiatorPermission");
    internal_withdraw(_pid, _amount, _ultimateBeneficialOwner);
    emit WithdrawFor(msg.sender, _pid, _amount, _ultimateBeneficialOwner);
  }

  // Withdraw without caring about rewards. EMERGENCY ONLY.
  function emergencyWithdraw(uint256 _pid) external {
    uint256 _user_amount = internal_emergencyWithdraw(_pid, msg.sender);
    emit EmergencyWithdraw(msg.sender, _pid, _user_amount);
  }

  // Initiate withdraw and break LP tokens for someone else (funds are never transfered to the initiator, but always to the ultimate beneficial owner)
  function breakLpFor(uint256 _pid, uint256 _amount, address _ultimateBeneficialOwner) external {
    require(actionInitiators.breakLpInitiator(msg.sender, _ultimateBeneficialOwner), "!breakLpInitiatorPermission");
    internal_break_LP(_pid, _amount, msg.sender, _ultimateBeneficialOwner);
    emit BreakLpFor(msg.sender, _pid, _amount, _ultimateBeneficialOwner);
  }

  // Initiate emergencyWithdraw without caring about rewards for someone else. EMERGENCY ONLY. (funds are never transfered to the initiator, but always to the ultimate beneficial owner)
  function emergencyWithdrawFor(uint256 _pid, address _ultimateBeneficialOwner) external {
    require(actionInitiators.emergencyWithdrawInitiator(msg.sender, _ultimateBeneficialOwner), "!emergencyWithdrawPermission");
    uint256 _user_amount = internal_emergencyWithdraw(_pid, _ultimateBeneficialOwner);
    emit EmergencyWithdrawFor(msg.sender, _pid, _user_amount, _ultimateBeneficialOwner);
  }

  function setSwapMinterAllowed(address _router, bool _allowed) external onlyOwner {
    swapminter[_router] = _allowed;
  }

  function swapMint(address _user, address _pair, uint256 _amount) external {
    if (!swapminter[msg.sender]) return;
    uint256 pid = pidByPair[_pair];
    if (pid == 0 || _amount == 0) return;
    PoolInfo storage pool = poolInfo[pid];
    UserInfo storage user = userInfo[pid][_user];
    pool.totalTradeAmount = pool.totalTradeAmount + _amount;
    user.tradeAmount = user.tradeAmount + _amount;
  }

  function recoverUnsupported(IERC20 _token, uint256 amount, address to) external onlyOwner {
     require(_token != hyperJumpToken, "!JUMP");
     uint256 length = poolInfo.length;
     for (uint256 pid = 0; pid < length; ++pid) {
         PoolInfo storage pool = poolInfo[pid];
         require(address(_token) != address(pool.token), "pool.token");
     }
     _token.transfer(to, amount);
  }
  
  // end of contract
}

// SPDX-License-Identifier: MIT

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

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

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
     * by making the `nonReentrant` function external, and make it call a
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
pragma solidity ^0.8.9;

interface IFarmActionInitiators {
   function withdrawInitiator(address initiator, address ultimate_beneficial_owner) external view returns (bool);
   function emergencyWithdrawInitiator(address initiator, address ultimate_beneficial_owner) external view returns (bool);
   function breakLpInitiator(address initiator, address ultimate_beneficial_owner) external view returns (bool);
   function breakLpFee(address) external view returns (uint256);
   function break_lp_fee_wallet() external view returns (address);
   function calculateBreakLpFee(address _initiator, uint256 _amount) external view returns (uint256);

   function registerWithdrawInitiator(address _initiator, bool _allowed) external;
   function registerEmergencyWithdrawInitiator(address _initiator, bool _allowed) external;
   function registerBreakLpInitiator(address _initiator, bool _allowed) external;
   function registerZapContract(address _zap_contract) external;
   
   function registerBreakLpFeeWallet(address _break_lp_fee_wallet) external;
   function registerBreakLpFee(address _initiator, uint256 _fee_percentage) external;   
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IHyperswapBreakLP {
  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountA, uint256 amountB);
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.5.0;

interface IHyperswapPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IHyperJumpTokenDistributor {
  function hyperJumpToken() external view returns (address);

  function hyperJumpToken_collector() external view returns (address);

  function collect(uint256 _amount) external;

  function collectTo(address _destination, uint256 _amount) external;

  function collected() external view returns (uint256);

  function availableInDistributor() external view returns (uint256);

  function availableInCollector() external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}