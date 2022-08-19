// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./libs/dgg/Auth.sol";
import "./libs/zeppelin/token/BEP20/IBEP20.sol";

contract LaunchPad is Auth {
  uint public poolIndex;
  uint constant public oneHundredPercentInDecimal3 = 100000;
  uint public totalAmountIncludingProfit;
  uint public totalAmountClaimed;

  IBEP20 public dggToken;

  mapping(uint => Pool) public pools;
  mapping(address => mapping(uint => Deposit)) public deposits;
  mapping(address => bool) public blockUsers;

  struct Pool {
    string name;
    uint minDeposit;
    uint interestRate;  // decimals 3
    uint lockingTime;   // seconds
    uint vestingTime;   // seconds
    uint startLockingTime;
    uint endVestingTime;
    bool isStaking;
    uint totalDepositAmount;
    address[] userAddresses;
    uint totalUserDeposit;
  }

  struct Deposit {
    uint amount;
    uint totalClaimed;
    uint latestClaimTime;
    uint amountClaimPerSeconds;
  }

  event PoolCreated(uint indexed poolId, string name, uint minDeposit, uint interestRate, uint lockingTime, uint vestingTime);
  event PoolNameUpdated(uint indexed poolId, string name);
  event PoolMinDepositUpdated(uint indexed poolId, uint amount);
  event PoolInterestRateUpdated(uint indexed poolId, uint interestRate);
  event PoolLockingTimeUpdated(uint indexed poolId, uint time);
  event PoolVestingTimeUpdated(uint indexed poolId, uint time);
  event PoolLockingStarted(uint indexed poolId, uint timestamp);
  event PoolStakingStatusUpdated(uint indexed poolId, bool status);
  event UserBlocked(address indexed userAddress, bool status);
  event Deposited(address indexed userAddress, uint poolId, uint amount);
  event Claimed(address indexed userAddress, uint amount);

  modifier poolExist(uint _poolId) {
    require(pools[_poolId].minDeposit > 0, "LaunchPad: invalid poolId.");
    _;
  }

  modifier notStartVesting(uint _poolId) {
    require(pools[_poolId].minDeposit > 0, "LaunchPad: invalid poolId.");
    require(pools[_poolId].startLockingTime == 0, "LaunchPad: can't update data.");
    _;
  }

  // ------------------------

  function initializeLaunchPad(address _dggTokenAddress) virtual public initializer {
    initialize(msg.sender);
    dggToken = IBEP20(0x94B06Be7b823451c5b60D97daFD26aEfb680028b);
    poolIndex = 1;
    totalAmountIncludingProfit = 0;
    totalAmountClaimed = 0;
  }

  // ----- Admin function

  function createPool(
    string calldata _name,
    uint _minDeposit,
    uint _interestRate,
    uint _lockingTime,
    uint _vestingTime
  ) external onlyMainAdmin {
    require(_minDeposit > 0, "LaunchPad: min deposit must be great than 0.");
    require(_interestRate <= oneHundredPercentInDecimal3, "LaunchPad: interest rate less than or equal 100000.");
    require(_lockingTime > 0, "LaunchPad: locking time must be great than 0.");
    require(_vestingTime > 0, "LaunchPad: vesting time must be great than 0.");

    Pool storage pool = pools[poolIndex];
    pool.name = _name;
    pool.minDeposit = _minDeposit;
    pool.interestRate = _interestRate;
    pool.lockingTime = _lockingTime;
    pool.vestingTime = _vestingTime;
    pool.isStaking = true;

    emit PoolCreated(poolIndex, _name, _minDeposit, _interestRate, _lockingTime, _vestingTime);
    poolIndex++;
  }

  function updatePoolName(uint _poolId, string calldata _name) external onlyMainAdmin notStartVesting(_poolId) {
    pools[_poolId].name = _name;
    emit PoolNameUpdated(_poolId, _name);
  }

  function updatePoolMinDeposit(uint _poolId, uint _amount) external onlyMainAdmin notStartVesting(_poolId) {
    require(_amount > 0, "LaunchPad: min deposit must be great than 0.");
    pools[_poolId].minDeposit = _amount;
    emit PoolMinDepositUpdated(_poolId, _amount);
  }

  function updatePoolInterestRate(uint _poolId, uint _percent) external onlyMainAdmin notStartVesting(_poolId) {
    require(_percent <= oneHundredPercentInDecimal3, "LaunchPad: interest rate less than or equal 100000.");
    pools[_poolId].interestRate = _percent;
    emit PoolInterestRateUpdated(_poolId, _percent);
  }

  function updatePoolLockingTime(uint _poolId, uint _seconds) external onlyMainAdmin notStartVesting(_poolId) {
    require(_seconds > 0, "LaunchPad: locking time must be great than 0.");
    pools[_poolId].lockingTime = _seconds;
    emit PoolLockingTimeUpdated(_poolId, _seconds);
  }

  function updatePoolVestingTime(uint _poolId, uint _seconds) external onlyMainAdmin notStartVesting(_poolId) {
    require(_seconds > 0, "LaunchPad: vesting time must be great than 0.");
    pools[_poolId].vestingTime = _seconds;
    emit PoolVestingTimeUpdated(_poolId, _seconds);
  }

  function updatePoolStakingStatus(uint _poolId, bool _status) external onlyMainAdmin notStartVesting(_poolId) {
    _updatePoolStakingStatus(_poolId, _status);
  }

  function startLocking(uint _poolId) external onlyMainAdmin poolExist(_poolId) {
    Pool storage pool = pools[_poolId];
    require(pool.startLockingTime == 0, "LaunchPad: locking had started.");

    if (!pool.isStaking) {
      _updatePoolStakingStatus(_poolId, true);
    }

    uint balanceOfContract = dggToken.balanceOf(address(this));
    require(balanceOfContract >= totalAmountIncludingProfit - totalAmountClaimed, "LaunchPad: balance of contract is low.");

    pool.startLockingTime = block.timestamp;
    pool.endVestingTime = block.timestamp + pool.lockingTime + pool.vestingTime;

    emit PoolLockingStarted(_poolId, block.timestamp);
  }

  function blockUser(address _userAddress, bool _status) external onlyMainAdmin {
    require(_userAddress != address(0), "LaunchPad: invalid address.");

    blockUsers[_userAddress] = _status;

    emit UserBlocked(_userAddress, _status);
  }

  // ----- User function

  function deposit(uint _poolId, uint _amount) external poolExist(_poolId) {
    Pool storage pool = pools[_poolId];

    require(pool.isStaking && pool.startLockingTime == 0, "LaunchPad: please wait more time.");
    require(_amount >= pool.minDeposit, "LaunchPad: invalid amount.");

    _takeFundDGG(_amount);

    Deposit storage depositDetail = deposits[msg.sender][_poolId];

    if (depositDetail.amount > 0) {
      depositDetail.amount += _amount;
      depositDetail.amountClaimPerSeconds = _calculateClaimAmountPerSeconds(pool, depositDetail.amount);
    } else {
      deposits[msg.sender][_poolId] = Deposit(_amount, 0, 0, 0);
      deposits[msg.sender][_poolId].amountClaimPerSeconds = _calculateClaimAmountPerSeconds(pool, deposits[msg.sender][_poolId].amount);
      pool.userAddresses.push(msg.sender);
      pool.totalUserDeposit ++;
    }

    pool.totalDepositAmount += _amount;
    totalAmountIncludingProfit += _amount * (oneHundredPercentInDecimal3 + pool.interestRate) / oneHundredPercentInDecimal3;

    emit Deposited(msg.sender, _poolId, _amount);
  }

  function claim(uint _poolId) external poolExist(_poolId) {
    Pool storage pool = pools[_poolId];

    require(pool.startLockingTime > 0, "LaunchPad: pool not start yet.");
    require(block.timestamp >= pool.startLockingTime + pool.lockingTime, "LaunchPad: please wait more time.");
    require(!blockUsers[msg.sender], "LaunchPad: account has been blocked.");

    Deposit storage userDeposit = deposits[msg.sender][_poolId];
    require(userDeposit.amountClaimPerSeconds > 0, "LaunchPad: please deposit first.");
    require(userDeposit.latestClaimTime < pool.endVestingTime, "LaunchPad: you have completed the claiming.");

    uint latestClaimTime = userDeposit.latestClaimTime > 0 ? userDeposit.latestClaimTime : (pool.startLockingTime + pool.lockingTime);
    uint claimableSeconds = block.timestamp < pool.endVestingTime
      ? block.timestamp - latestClaimTime
      : pool.endVestingTime - latestClaimTime;
    uint amount = claimableSeconds * userDeposit.amountClaimPerSeconds;

    userDeposit.totalClaimed += amount;
    require(userDeposit.totalClaimed <= userDeposit.amount * (oneHundredPercentInDecimal3 + pool.interestRate) / oneHundredPercentInDecimal3, "LaunchPad: invalid claim amount.");

    userDeposit.latestClaimTime = block.timestamp;
    totalAmountClaimed += amount;
    dggToken.transfer(msg.sender, amount);

    emit Claimed(msg.sender, amount);
  }

  // Private functions

  function _calculateClaimAmountPerSeconds(Pool memory _pool, uint _amount) private pure returns(uint) {
    return _amount * (oneHundredPercentInDecimal3 + _pool.interestRate) / oneHundredPercentInDecimal3 / _pool.vestingTime;
  }

  function _takeFundDGG(uint _amount) private {
    require(dggToken.allowance(msg.sender, address(this)) >= _amount, "LaunchPad: please approve dgg first.");
    require(dggToken.balanceOf(msg.sender) >= _amount, "LaunchPad: insufficient balance.");
    require(dggToken.transferFrom(msg.sender, address(this), _amount), "LaunchPad: transfer dgg failed.");
  }

  function _updatePoolStakingStatus(uint _poolId, bool _status) private {
    pools[_poolId].isStaking = _status;

    emit PoolStakingStatusUpdated(_poolId, _status);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

abstract contract Auth is Initializable {

  address public mainAdmin;
  address public contractAdmin;

  event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);
  event ContractAdminUpdated(address indexed _newOwner);

  function initialize(address _mainAdmin) virtual public initializer {
    mainAdmin = _mainAdmin;
    contractAdmin = _mainAdmin;
  }

  modifier onlyMainAdmin() {
    require(_isMainAdmin(), "onlyMainAdmin");
    _;
  }

  modifier onlyContractAdmin() {
    require(_isContractAdmin() || _isMainAdmin(), "onlyContractAdmin");
    _;
  }

  function transferOwnership(address _newOwner) onlyMainAdmin external {
    require(_newOwner != address(0x0));
    mainAdmin = _newOwner;
    emit OwnershipTransferred(msg.sender, _newOwner);
  }

  function updateContractAdmin(address _newAdmin) onlyMainAdmin external {
    require(_newAdmin != address(0x0));
    contractAdmin = _newAdmin;
    emit ContractAdminUpdated(_newAdmin);
  }

  function _isMainAdmin() public view returns (bool) {
    return msg.sender == mainAdmin;
  }

  function _isContractAdmin() public view returns (bool) {
    return msg.sender == contractAdmin;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
interface IBEP20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}