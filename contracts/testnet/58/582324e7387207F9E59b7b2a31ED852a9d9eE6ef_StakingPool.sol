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

pragma solidity ^0.8.4;

struct UserInfo {
	uint256 id;
	uint256 level;
	//index in level
	uint256 levelIndex;
	uint256 firstIdoTime;
	uint256 memberPoints;
	//=0 not initialized
	address parent;
}

interface IVNSCPD {
	function mint(address to, uint256 amount) external;
}

interface IVNSToken {
	function mint(address to, uint256 amount) external;

	function lockIdoAmount(address user, uint256 amount) external;

	function lockAirdropAmount(address user, uint256 amount) external;
}

interface IVNSNFT {
	function mintTo(address to, uint256 num) external returns (uint256);

	function blindBoxTo(address to) external returns (uint256);
}

interface IVNSMemberShip {
	function getUserInfo(address user) external view returns (UserInfo memory);

	function addUser(address user) external;

	function firstIdo(address user, address parent) external;

	function addMemberPoints(address user, uint256 points) external;

	function updateLevel(address user) external;
    function getLevelLength(uint256 level) external returns(uint256);

}

interface INFTStakingPool {
	function getStakedNft(address user) external returns (uint256[] memory);
}

interface IStakingPool {
	function stake(
		uint256 poolId,
		uint256 amount,
		address to
	) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IVNS.sol";

contract StakingPool is IStakingPool, Ownable {
  enum StakeType {
    Single, //vns
    LP //vns cpd usdt
  }
  struct ERC20Staker {
    uint256 amount; // How many tokens the user has provided.
    uint256 claimedVNS; // total rewarded token amount
    uint256 claimedCPD;
    uint256 claimedUSDT;
    uint256 lastClaimTime; // User's last claim time.
    uint256 lastDepositTime; //last deposit time
  }

  struct Pool {
    uint256 lockTime; // Lock-up time
    uint256 rewardRate; // daily interest multiplied by 1000
    uint256 stakedAmount; //current total staked amount;
    uint256 totalRewardVNS; //current pool total reward vns;
    uint256 totalRewardCPD; //current pool total reward cpd, only lp
    uint256 totalRewardUSDT; //current pool total reward usdt, onlp lp
  }

  address public immutable VNS;
  address public immutable CPD;
  address public immutable USDT; //vns swap fee
  address public immutable STAKED_TOKEN;
  StakeType public immutable STAKE_TYPE;

  address public nftStakingPool;
  uint256 public usdtClaimColdTime = 1 days;
  uint256 public totalStaked; //all pools total staked amount;

  Pool[] public pools; // Staking pools
  bool public isOpen = true;

  // Mapping poolId => staker address => ERC20Staker
  mapping(uint256 => mapping(address => ERC20Staker)) public stakers;

  event Stake(uint256 poolId, address indexed user, uint256 amount);
  event Withdraw(address indexed user, uint256 amount);
  event RewardTokenTransfer(address indexed user, address indexed token, uint256 amount);
  error NotEnoughBalance(address token, uint256 balance);
  event PoolCreated(uint256 poolId);

  constructor(
    address _rewardVNS,
    address _rewardCPD,
    address _rewardUSDT,
    address _stakedToken,
    StakeType _stakeType
  ) {
    VNS = _rewardVNS;
    CPD = _rewardCPD;
    USDT = _rewardUSDT;
    STAKED_TOKEN = _stakedToken;
    STAKE_TYPE = _stakeType;
  }

  function toggleSwitch() external onlyOwner {
    isOpen = !isOpen;
  }

  function createPool(uint256 _lockDays, uint256 _rewardRate) public onlyOwner {
    Pool memory pool;
    pool.lockTime = _lockDays * 1 days;
    pool.rewardRate = _rewardRate;
    pools.push(pool);

    uint256 poolId = pools.length - 1;
    emit PoolCreated(poolId);
  }

  function setNftStakingPool(address addr) external onlyOwner {
    nftStakingPool = addr;
  }

  function setUsdtClaimColdTime(uint256 coldtime) external onlyOwner {
    require(coldtime > 1 days, "minimum 1 days");
    usdtClaimColdTime = coldtime;
  }

  function sweepToken(IERC20 token) external onlyOwner {
    uint256 sweepAmount = token.balanceOf(address(this));

    if (address(token) == address(STAKED_TOKEN)) sweepAmount -= totalStaked;

    token.transfer(msg.sender, sweepAmount);
  }

  function stake(
    uint256 poolId,
    uint256 amount,
    address to
  ) public override {
    require(isOpen, "closed");
    require(amount > 0, "Stake: cannot stake 0");
    require(poolId < pools.length, "invalid id");

    if (msg.sender == to) claim(poolId);
    else require(msg.sender == nftStakingPool, "invalid caller");

    IERC20(STAKED_TOKEN).transferFrom(msg.sender, address(this), amount);

    ERC20Staker storage user = stakers[poolId][to];
    user.amount += amount;
    user.lastDepositTime = block.timestamp;

    pools[poolId].stakedAmount += amount;
    totalStaked += amount;
    emit Stake(poolId, to, amount);
  }

  function stake(uint256 poolId, uint256 amount) public {
    stake(poolId, amount, msg.sender);
  }

  function withdraw(uint256 poolId, uint256 amount) external {
    require(isOpen, "closed");
    require(poolId < pools.length, "invalid id");

    Pool storage pool = pools[poolId];
    ERC20Staker storage user = stakers[poolId][msg.sender];

    require(amount <= user.amount, "invalid amount");
    require(block.timestamp > user.lastDepositTime + pool.lockTime, "too early to withdraw");

    claim(poolId);

    user.amount -= amount;

    pool.stakedAmount -= amount;
    totalStaked -= amount;
    IERC20(STAKED_TOKEN).transfer(msg.sender, amount);

    emit Withdraw(msg.sender, amount);
  }

  function claim() public {
    for (uint256 i; i < pools.length; i++) {
      claim(i);
    }
  }

  function claim(uint256 poolId) public {
    require(isOpen, "closed");

    Pool storage pool = pools[poolId];
    ERC20Staker storage user = stakers[poolId][msg.sender];
    if(user.amount==0)return;

    (uint256 pendingVNS, uint256 pedingCPD, uint256 pendingUSDT) = pending(poolId);

    if (pendingVNS > 0) {
      rewardVNSTransfer(msg.sender, pendingVNS);
      user.claimedVNS += pendingVNS;
      pool.totalRewardVNS += pendingVNS;
    }

    if (pedingCPD > 0) {
      rewardCPDTransfer(msg.sender, pedingCPD);
      user.claimedCPD += pedingCPD;
      pool.totalRewardCPD += pedingCPD;
    }

    if (pendingUSDT > 0) {
      rewardUSDTTransfer(msg.sender, pendingUSDT);
      user.claimedUSDT += pendingUSDT;
      pool.totalRewardUSDT += pendingUSDT;
    }

    user.lastClaimTime = block.timestamp;
  }

  function pending(uint256 poolId)
    public
    view
    returns (
      uint256 pendingVNS,
      uint256 pendingCPD,
      uint256 pendingUSDT
    )
  {
    return pending(poolId,msg.sender);
  }
  function pending(uint256 poolId,address _user)
    public
    view
    returns (
      uint256 pendingVNS,
      uint256 pendingCPD,
      uint256 pendingUSDT
    )
  {
    Pool memory pool = pools[poolId];
    ERC20Staker memory user = stakers[poolId][_user];

    //vns
    pendingVNS = (user.amount * pool.rewardRate * (block.timestamp - user.lastClaimTime)) / 1000 / 1 days;

    if (STAKE_TYPE == StakeType.LP) {
      //cpd
      pendingCPD = pendingVNS;

      //usdt
      if (block.timestamp > user.lastClaimTime + usdtClaimColdTime) {
        uint256 usdtBalance = IERC20(USDT).balanceOf(address(this));
        pendingUSDT = (user.amount * usdtBalance) / totalStaked;
      }
    }
  }

  function rewardVNSTransfer(address to, uint256 amount) internal {
    emit RewardTokenTransfer(to, VNS, amount);

    uint256 balance = IERC20(VNS).balanceOf(address(this));
    if (balance < amount) {
      revert NotEnoughBalance(VNS, balance);
    }
    IERC20(VNS).transfer(to, amount);
  }

  function rewardCPDTransfer(address to, uint256 amount) internal {
    emit RewardTokenTransfer(to, CPD, amount);

    uint256 balance = IERC20(CPD).balanceOf(address(this));
    if (balance < amount) {
      revert NotEnoughBalance(CPD, balance);
    }
    IERC20(CPD).transfer(to, amount);
  }

  function rewardUSDTTransfer(address to, uint256 amount) internal {
    emit RewardTokenTransfer(to, USDT, amount);

    uint256 balance = IERC20(USDT).balanceOf(address(this));
    if (balance < amount) {
      amount = balance;
    }
    IERC20(USDT).transfer(to, amount);
  }
}