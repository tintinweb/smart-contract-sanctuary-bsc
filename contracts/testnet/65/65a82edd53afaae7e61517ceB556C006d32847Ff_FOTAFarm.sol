// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

import "./libs/fota/Auth.sol";
import "./libs/zeppelin/token/BEP20/IBEP20.sol";
import "./interfaces/IFOTAToken.sol";
import "./interfaces/ILPToken.sol";

contract FOTAFarm is Auth {
  struct Farmer {
    uint fotaDeposited;
    uint lpDeposited;
    uint point;
    mapping(uint => uint) pendingRewards;
    uint totalEarned;
    uint totalMissed;
    uint lastDayScanMissedClaim;
  }
  mapping (address => Farmer) public farmers;
  IFOTAToken public fotaToken;
  ILPToken public lpToken;
  uint public startTime;
  uint public totalFotaDeposited;
  uint public totalLPDeposited;
  uint public totalEarned;
  uint public rewardingDays;
  uint public lpBonus;
  uint public lastActiveDay;
  uint public secondInADay;
  uint constant decimal18 = 1e18;
  uint constant decimal9 = 1e9;

  mapping(uint => uint) public dailyReward;
  mapping(uint => uint) public dailyCheckinPoint;
  mapping(uint => uint) public dailyTotalPoint;
  mapping(uint => bool) public missProcessed;
  mapping(address => mapping (uint => bool)) public checkinTracker;

  event FOTADeposited(address indexed farmer, uint amount, uint point);
  event LPDeposited(address indexed farmer, uint amount, uint point);
  event RewardingDaysUpdated(uint rewardingDays);
  event LPBonusRateUpdated(uint rate);
  event FOTAFunded(uint amount, uint timestamp);
  event Claimed(address indexed farmer, uint day, uint amount, uint timestamp);
  event Missed(address indexed farmer, uint day, uint amount);
  event Withdrew(address indexed farmer, uint fotaDeposited, uint lpDeposited, uint timestamp);
  event CheckedIn(address indexed farmer, uint dayPassed, uint reward, uint timestamp);

  modifier initStartTime() {
    require(startTime > 0, "Please init startTime");
    _;
  }

  function initialize(address _mainAdmin) override public initializer {
    super.initialize(_mainAdmin);
    fotaToken = IFOTAToken(0x0A4E1BdFA75292A98C15870AeF24bd94BFFe0Bd4);
    lpToken = ILPToken(0x0A4E1BdFA75292A98C15870AeF24bd94BFFe0Bd4); // TODO
    rewardingDays = 3;
    lpBonus = 25e17;
    secondInADay = 86400; // 24 * 60 * 60
  }

  function depositFOTA(uint _amount) external initStartTime {
    _takeFundFOTA(_amount);
    Farmer storage farmer = farmers[msg.sender];
    farmer.fotaDeposited += _amount;
    farmer.point += _amount;
    uint dayPassed = getDaysPassed();
    _syncDailyTotalPoint(dayPassed);
    dailyTotalPoint[dayPassed] += _amount;
    totalFotaDeposited += _amount;
    _checkin(dayPassed, farmer);
    emit FOTADeposited(msg.sender, _amount, _amount);
  }

  function depositLP(uint _amount) external initStartTime {
    _takeFundLP(_amount);
    uint point = _getPointWhenDepositViaLP(_amount);
    Farmer storage farmer = farmers[msg.sender];
    farmer.lpDeposited += _amount;
    farmer.point += point;
    uint dayPassed = getDaysPassed();
    _syncDailyTotalPoint(dayPassed);
    dailyTotalPoint[dayPassed] += point;
    totalLPDeposited += _amount;
    _checkin(dayPassed, farmer);
    emit LPDeposited(msg.sender, _amount, point);
  }

  function checkin() external {
    Farmer storage farmer = farmers[msg.sender];
    require(farmer.point > 0, "FOTAFarm: please join the farm first");
    uint dayPassed = getDaysPassed();
    _syncDailyTotalPoint(dayPassed);
    _checkin(dayPassed, farmer);
  }

  function claim() external {
    require(farmers[msg.sender].point > 0, "FOTAFarm: please join the farm first");
    uint dayPassed = getDaysPassed();
    _checkClaim(dayPassed);
  }

  function withdraw() external {
    Farmer storage farmer = farmers[msg.sender];
    require(farmer.fotaDeposited > 0 || farmer.lpDeposited > 0, "404");
    uint dayPassed = getDaysPassed();
    _checkClaim(dayPassed);
    _movePendingRewardToFundFOTA(dayPassed, farmer);
    uint fotaDeposited = farmer.fotaDeposited;
    uint lpDeposited = farmer.lpDeposited;
    totalFotaDeposited -= farmer.fotaDeposited;
    totalLPDeposited -= farmer.lpDeposited;
    farmer.fotaDeposited = 0;
    farmer.lpDeposited = 0;
    if (dayPassed > rewardingDays + 1) {
      _checkMissedClaim(dayPassed, farmer);
    }
    if (checkinTracker[msg.sender][dayPassed]) {
      dailyCheckinPoint[dayPassed] -= farmer.point;
    }
    _syncDailyTotalPoint(dayPassed);
    dailyTotalPoint[dayPassed] -= farmer.point;
    farmer.point = 0;
    if (fotaDeposited > 0) {
      fotaToken.transfer(msg.sender, fotaDeposited);
    }
    if (lpDeposited > 0) {
      lpToken.transfer(msg.sender, lpDeposited);
    }
    emit Withdrew(msg.sender, fotaDeposited, lpDeposited, block.timestamp);
  }

  function fundFOTA(uint _amount) external initStartTime {
    _takeFundFOTA(_amount);
    uint dayPassed = getDaysPassed();
    _fundFOTA(_amount, dayPassed);
  }

  function getDaysPassed() public view returns (uint) {
    if (startTime == 0) {
      return 0;
    }
    uint timePassed = block.timestamp - startTime;
    return timePassed / secondInADay;
  }

  function getTodayReward() external view returns (uint) {
    uint dateToReward = getDaysPassed() - 1;
    if (dailyTotalPoint[dateToReward] == 0) {
      return 0;
    }
    return dailyReward[dateToReward] * dailyCheckinPoint[dateToReward] / dailyTotalPoint[dateToReward];
  }

  function getTotalRewarded() public view returns (uint) {
    uint totalRewarded = 0;
    uint dayPassed = getDaysPassed();
    for (uint i = 0; i < rewardingDays; i++) {
      totalRewarded += dailyReward[dayPassed + i];
    }
    return totalRewarded;
  }

  function getProfitRate() external view returns (uint) {
    uint dailyPoint = dailyTotalPoint[getDaysPassed()];
    if (dailyPoint == 0) {
      dailyPoint = dailyTotalPoint[lastActiveDay];
    }
    if (dailyPoint == 0) {
      return 0;
    }
    return getTotalRewarded() / dailyPoint / 1e18;
  }

  function getUserStats(address _user) external view returns (uint, uint) {
    uint pendingReward;
    uint dayPassed = getDaysPassed();
    for (uint i = 0; i <= rewardingDays; i++) {
      pendingReward += farmers[_user].pendingRewards[dayPassed - i];
    }
    return (pendingReward, farmers[msg.sender].pendingRewards[dayPassed - rewardingDays]);
  }

  // PRIVATE FUNCTIONS

  function _syncDailyTotalPoint(uint _dateToClaim) private {
    if (dailyTotalPoint[_dateToClaim] == 0 && _dateToClaim > lastActiveDay) {
      dailyTotalPoint[_dateToClaim] = dailyTotalPoint[lastActiveDay];
      lastActiveDay = _dateToClaim;
    }
  }

  function _checkin(uint _dayPassed, Farmer storage _farmer) private {
    require(!checkinTracker[msg.sender][_dayPassed], "FOTAFarm: checked in");
    checkinTracker[msg.sender][_dayPassed] = true;
    dailyCheckinPoint[_dayPassed] += farmers[msg.sender].point;
    if (_farmer.lastDayScanMissedClaim == 0) {
      _farmer.lastDayScanMissedClaim = _dayPassed - 1;
    }

    if (dailyTotalPoint[_dayPassed] == 0) {
      return;
    }
    uint reward = farmers[msg.sender].point * dailyReward[_dayPassed] / dailyTotalPoint[_dayPassed];
    if (reward > 0) {
      farmers[msg.sender].pendingRewards[_dayPassed] = reward;
      emit CheckedIn(msg.sender, _dayPassed, reward, block.timestamp);
    }
    if (_dayPassed > rewardingDays + 1) {
      _checkMissedClaim(_dayPassed, _farmer);
    }
  }

  function _checkMissedClaim(uint _dayPassed, Farmer storage _farmer) private {
    if (_farmer.lastDayScanMissedClaim < _dayPassed - rewardingDays) {
      uint missedAmount;
      for (uint i = _farmer.lastDayScanMissedClaim + 1; i < _dayPassed - rewardingDays; i++) {
        if (_farmer.pendingRewards[i] > 0) {
          emit Missed(msg.sender, i, _farmer.pendingRewards[i]);
          missedAmount += _farmer.pendingRewards[i];
          _farmer.pendingRewards[i] = 0;
        }
      }
      _farmer.lastDayScanMissedClaim = _dayPassed - rewardingDays - 1;
      if (missedAmount > 0) {
        _farmer.totalMissed += missedAmount;
        _fundFOTA(missedAmount, _dayPassed);
      }
    }
  }

  function _movePendingRewardToFundFOTA(uint _dayPassed, Farmer storage _farmer) private {
    uint missedAmount;
    for (uint i = _farmer.lastDayScanMissedClaim + 1; i <= _dayPassed; i++) {
      if (_farmer.pendingRewards[i] > 0) {
        emit Missed(msg.sender, i, _farmer.pendingRewards[i]);
        missedAmount += _farmer.pendingRewards[i];
        _farmer.pendingRewards[i] = 0;
      }
    }
    _farmer.totalMissed += missedAmount;
    _fundFOTA(missedAmount, _dayPassed);
  }

  function _checkClaim(uint _dayPassed) private {
    require(_dayPassed >= rewardingDays, "FOTAFarm: please wait for more time");
    uint index = _dayPassed - rewardingDays;
    uint reward = farmers[msg.sender].pendingRewards[index];
    farmers[msg.sender].pendingRewards[index] = 0;
    if (reward == 0) {
      return;
    }
    farmers[msg.sender].totalEarned += reward;
    require(fotaToken.balanceOf(address(this)) >= reward, "FOTAFarm: contract is insufficient balance");
    fotaToken.transfer(msg.sender, reward);
    totalEarned += reward;
    if (_dayPassed > rewardingDays + 1) {
      _checkMissedClaim(_dayPassed, farmers[msg.sender]);
    }
    emit Claimed(msg.sender, index, reward, block.timestamp);
  }

  function _fundFOTA(uint _amount, uint _dayPassed) private {
    uint restAmount = _amount;
    uint eachDayAmount = _amount / rewardingDays;
    for(uint i = 1; i < rewardingDays; i++) {
      dailyReward[_dayPassed + i] += eachDayAmount;
      restAmount -= eachDayAmount;
    }
    dailyReward[_dayPassed + rewardingDays] += restAmount;
    emit FOTAFunded(_amount, block.timestamp);
  }

//  function _getPointWhenDepositViaLP(uint _lpAmount) private view returns (uint) {
  function _getPointWhenDepositViaLP(uint _lpAmount) public view returns (uint) { // TODO
    (uint reserve0, uint reserve1) = lpToken.getReserves();
    uint rateInDecimal18 = reserve1 * decimal18 / reserve0;
    // n = _lpAmount / _sqrt(rate)
    // sqrt(1e18) = 1e9
    return _lpAmount * lpBonus / _sqrt(rateInDecimal18) / decimal9;
  }

  function _takeFundFOTA(uint _amount) private {
    require(fotaToken.allowance(msg.sender, address(this)) >= _amount, "FOTAFarm: please approve fota first");
    require(fotaToken.balanceOf(msg.sender) >= _amount, "FOTAFarm: insufficient balance");
    require(fotaToken.transferFrom(msg.sender, address(this), _amount), "FOTAFarm: transfer fota failed");
  }

  function _takeFundLP(uint _amount) private {
    require(lpToken.allowance(msg.sender, address(this)) >= _amount, "FOTAFarm: please approve LP token first");
    require(lpToken.balanceOf(msg.sender) >= _amount, "FOTAFarm: insufficient balance");
    require(lpToken.transferFrom(msg.sender, address(this), _amount), "FOTAFarm: transfer LP token failed");
  }

  function _sqrt(uint x) private pure returns (uint y) {
    uint z = (x + 1) / 2;
    y = x;
    while (z < y) {
      y = z;
      z = (x / z + z) / 2;
    }
  }

  // ADMIN FUNCTIONS
  function start(uint _startTime) external onlyMainAdmin {
    require(startTime == 0, "FOTAFarm: startTime had been initialized");
    require(_startTime >= 0 && _startTime < block.timestamp - secondInADay, "FOTAFarm: must be earlier yesterday");
    startTime = _startTime;
  }

  function updateRewardingDays(uint _days) external onlyMainAdmin {
    require(_days > 0, "FOTAFarm: days invalid");
    rewardingDays = _days;
    emit RewardingDaysUpdated(_days);
  }

  function updateLPBonusRate(uint _rate) external onlyMainAdmin {
    require(_rate > 0, "FOTAFarm: rate invalid");
    lpBonus = _rate;
    emit LPBonusRateUpdated(_rate);
  }

  function drainToken(address _tokenAddress) external onlyMainAdmin {
    IBEP20 token = IBEP20(_tokenAddress);
    token.transfer(msg.sender, token.balanceOf(address(this)));
  }

  function updateSecondInADay(uint _secondInDay) external onlyMainAdmin {
    secondInADay = _secondInDay;
  }

  function setContracts(address _fota, address _lp) external onlyMainAdmin {
    fotaToken = IFOTAToken(_fota);
    lpToken = ILPToken(_lp);
  }
}

// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

import "../libs/zeppelin/token/BEP20/IBEP20.sol";

interface IFOTAToken is IBEP20 {
  function releaseGameAllocation(address _gamerAddress, uint _amount) external returns (bool);
  function releasePrivateSaleAllocation(address _buyerAddress, uint _amount) external returns (bool);
  function releaseSeedSaleAllocation(address _buyerAddress, uint _amount) external returns (bool);
  function releaseStrategicSaleAllocation(address _buyerAddress, uint _amount) external returns (bool);
  function burn(uint _amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "../libs/zeppelin/token/BEP20/IBEP20.sol";

interface ILPToken is IBEP20 {
  function getReserves() external view returns (uint, uint);
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