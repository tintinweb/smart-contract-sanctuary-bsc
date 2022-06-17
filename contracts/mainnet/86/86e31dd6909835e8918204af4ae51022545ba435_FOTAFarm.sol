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
    mapping(uint => uint) dailyCheckinPoint;
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
  uint public fundingFOTADays;
  uint public lpBonus;
  uint public secondInADay;
  uint public totalPoint;
  uint constant decimal18 = 1e18;
  uint constant decimal9 = 1e9;

  mapping(uint => uint) public dailyReward;
  mapping(uint => uint) public dailyCheckinPoint;
  mapping(uint => bool) public missProcessed;
  mapping(address => mapping (uint => bool)) public checkinTracker;

  event FOTADeposited(address indexed farmer, uint amount, uint point);
  event LPDeposited(address indexed farmer, uint amount, uint point);
  event RewardingDaysUpdated(uint rewardingDays);
  event FundingFOTADaysUpdated(uint fundingFOTADays);
  event LPBonusRateUpdated(uint rate);
  event FOTAFunded(uint amount, uint[] fundedDays, uint timestamp);
  event Claimed(address indexed farmer, uint day, uint amount, uint timestamp);
  event Missed(address indexed farmer, uint day, uint amount);
  event Withdrew(address indexed farmer, uint fotaDeposited, uint lpDeposited, uint timestamp);
  event CheckedIn(address indexed farmer, uint dayPassed, uint checkinPoint, uint timestamp);

  modifier initStartTime() {
    require(startTime > 0, "Please init startTime");
    _;
  }

  function initialize(address _mainAdmin) override public initializer {
    super.initialize(_mainAdmin);
    fotaToken = IFOTAToken(0x0A4E1BdFA75292A98C15870AeF24bd94BFFe0Bd4);
    lpToken = ILPToken(0x0A4E1BdFA75292A98C15870AeF24bd94BFFe0Bd4); // TODO
    rewardingDays = 3;
    fundingFOTADays = 3;
    lpBonus = 25e17;
    secondInADay = 86400; // 24 * 60 * 60
  }

  function depositFOTA(uint _amount) external initStartTime {
    _takeFundFOTA(_amount);
    Farmer storage farmer = farmers[msg.sender];
    farmer.fotaDeposited += _amount;
    farmer.point += _amount;
    totalPoint += _amount;
    totalFotaDeposited += _amount;
    uint dayPassed = getDaysPassed();
    if (!checkinTracker[msg.sender][dayPassed]) {
      _checkin(dayPassed, farmer);
    }
    emit FOTADeposited(msg.sender, _amount, _amount);
  }

  function depositLP(uint _amount) external initStartTime {
    _takeFundLP(_amount);
    uint point = getPointWhenDepositViaLP(_amount);
    Farmer storage farmer = farmers[msg.sender];
    farmer.lpDeposited += _amount;
    farmer.point += point;
    totalPoint += point;
    totalLPDeposited += _amount;
    uint dayPassed = getDaysPassed();
    if (!checkinTracker[msg.sender][dayPassed]) {
      _checkin(dayPassed, farmer);
    }
    emit LPDeposited(msg.sender, _amount, point);
  }

  function checkin() external {
    Farmer storage farmer = farmers[msg.sender];
    require(farmer.point > 0, "FOTAFarm: please join the farm first");
    uint dayPassed = getDaysPassed();
    bool success = _checkin(dayPassed, farmer);
    require(success, "FOTAFarm: no reward today");
  }

  function claim() external {
    require(farmers[msg.sender].point > 0, "FOTAFarm: please join the farm first");
    uint dayPassed = getDaysPassed();
    _checkClaim(dayPassed, farmers[msg.sender]);
    _checkMissedClaim(dayPassed, farmers[msg.sender]);
  }

  function withdraw() external {
    Farmer storage farmer = farmers[msg.sender];
    require(farmer.point > 0, "404");
    uint dayPassed = getDaysPassed();
    _checkClaim(dayPassed, farmer);
    _checkMissedClaim(dayPassed, farmer);
    _movePendingRewardToFundFOTA(dayPassed, farmer);
    uint fotaDeposited = farmer.fotaDeposited;
    uint lpDeposited = farmer.lpDeposited;
    totalFotaDeposited -= farmer.fotaDeposited;
    totalLPDeposited -= farmer.lpDeposited;
    if (farmer.fotaDeposited > 0) {
      farmer.fotaDeposited = 0;
    }
    if (farmer.lpDeposited > 0) {
      farmer.lpDeposited = 0;
    }
    if (checkinTracker[msg.sender][dayPassed]) {
      dailyCheckinPoint[dayPassed] -= farmer.point;
    }
    totalPoint -= farmer.point;
    farmer.point = 0;
    for (uint i = 0; i <= rewardingDays; i++) {
      uint index = dayPassed - i;
      if (farmers[msg.sender].dailyCheckinPoint[index] > 0) {
        farmers[msg.sender].dailyCheckinPoint[index] = 0;
      }
    }
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

  function getTotalRewarded() public view returns (uint) {
    uint totalRewarded = 0;
    uint dayPassed = getDaysPassed();
    for (uint i = 0; i < fundingFOTADays; i++) {
      totalRewarded += dailyReward[dayPassed + i];
    }
    return totalRewarded;
  }

  function getProfitRate() external view returns (uint) {
    if (totalPoint == 0) {
      return 0;
    }
    return getTotalRewarded() * decimal18 / totalPoint;
  }

  function getUserStats(address _user) external view returns (uint, uint) {
    uint pendingReward;
    uint dayPassed = getDaysPassed();
    require(dayPassed >= rewardingDays, "FOTAFarm: please wait more time");
    for (uint i = 1; i <= rewardingDays; i++) {
      uint index = dayPassed - i;
      if (dailyCheckinPoint[index] > 0) {
        uint reward = farmers[_user].dailyCheckinPoint[index] * dailyReward[index] / dailyCheckinPoint[index];
        pendingReward += reward;
      }
    }
    uint todayClaimRewardIndex = dayPassed - rewardingDays;

    if (dailyCheckinPoint[todayClaimRewardIndex] > 0) {
      uint todayClaimReward = farmers[_user].dailyCheckinPoint[todayClaimRewardIndex] * dailyReward[todayClaimRewardIndex] / dailyCheckinPoint[todayClaimRewardIndex];
      return (pendingReward, todayClaimReward);
    }

    return (pendingReward, 0);
  }

  function getUserDailyCheckinPoint(address _user, uint _dayPassed) external view returns (uint) {
    return farmers[_user].dailyCheckinPoint[_dayPassed];
  }

  function getPointWhenDepositViaLP(uint _lpAmount) public view returns (uint) {
    uint fotaBalance = fotaToken.balanceOf(address(lpToken));
    uint lpSupply = lpToken.totalSupply();
    return fotaBalance * lpBonus * _lpAmount / lpSupply / decimal18;
  }

  // PRIVATE FUNCTIONS

  function _checkin(uint _dayPassed, Farmer storage _farmer) private returns (bool) {
    if (dailyReward[_dayPassed] == 0) {
      return false;
    }
    require(!checkinTracker[msg.sender][_dayPassed], "FOTAFarm: checked in");
    checkinTracker[msg.sender][_dayPassed] = true;
    dailyCheckinPoint[_dayPassed] += farmers[msg.sender].point;
    if (_farmer.lastDayScanMissedClaim == 0) {
      _farmer.lastDayScanMissedClaim = _dayPassed - 1;
    }

    farmers[msg.sender].dailyCheckinPoint[_dayPassed] = farmers[msg.sender].point;
    emit CheckedIn(msg.sender, _dayPassed, farmers[msg.sender].point, block.timestamp);
    if (_dayPassed > rewardingDays + 1) {
      _checkMissedClaim(_dayPassed, _farmer);
    }
    return true;
  }

  function _checkMissedClaim(uint _dayPassed, Farmer storage _farmer) private {
    if (_farmer.lastDayScanMissedClaim > 0 && _farmer.lastDayScanMissedClaim < _dayPassed - rewardingDays) {
      uint missedAmount;
      for (uint i = _farmer.lastDayScanMissedClaim + 1; i < _dayPassed - rewardingDays; i++) {
        if (_farmer.dailyCheckinPoint[i] > 0) {
          uint reward = _farmer.dailyCheckinPoint[i] * dailyReward[i] / dailyCheckinPoint[i];
          emit Missed(msg.sender, i, reward);
          missedAmount += reward;
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
    if (_farmer.lastDayScanMissedClaim == 0) return;
    uint missedAmount;
    for (uint i = _farmer.lastDayScanMissedClaim + 1; i < _dayPassed; i++) {
      if (_farmer.dailyCheckinPoint[i] > 0) {
        uint reward = _farmer.dailyCheckinPoint[i] * dailyReward[i] / dailyCheckinPoint[i];
        if (reward > 0) {
          emit Missed(msg.sender, i, reward);
          missedAmount += reward;
        }
        if (_farmer.dailyCheckinPoint[i] > 0) {
          _farmer.dailyCheckinPoint[i] = 0;
        }
      }
    }
    if (missedAmount > 0) {
      _farmer.totalMissed += missedAmount;
      _fundFOTA(missedAmount, _dayPassed);
    }
  }

  function _checkClaim(uint _dayPassed, Farmer storage _farmer) private returns (uint) {
    require(_dayPassed >= rewardingDays, "FOTAFarm: please wait for more time");
    uint index = _dayPassed - rewardingDays;
    if (dailyCheckinPoint[index] == 0 || _farmer.dailyCheckinPoint[index] == 0 || dailyReward[index] == 0) {
      return 0;
    }
    uint reward = _farmer.dailyCheckinPoint[index] * dailyReward[index] / dailyCheckinPoint[index];
    _farmer.dailyCheckinPoint[index] = 0;
    if (reward == 0) {
      return 0;
    }
    _farmer.totalEarned += reward;
    totalEarned += reward;
    require(fotaToken.balanceOf(address(this)) >= reward, "FOTAFarm: contract is insufficient balance");
    fotaToken.transfer(msg.sender, reward);
    emit Claimed(msg.sender, index, reward, block.timestamp);
    return reward;
  }

  function _fundFOTA(uint _amount, uint _dayPassed) private {
    uint restAmount = _amount;
    uint eachDayAmount = _amount / fundingFOTADays;
    uint[] memory fundedDays = new uint[](fundingFOTADays);
    for(uint i = 1; i < fundingFOTADays; i++) {
      dailyReward[_dayPassed + i] += eachDayAmount;
      fundedDays[i - 1] = _dayPassed + i;
      restAmount -= eachDayAmount;
    }
    dailyReward[_dayPassed + fundingFOTADays] += restAmount;
    fundedDays[fundingFOTADays - 1] = _dayPassed + fundingFOTADays;
    emit FOTAFunded(_amount, fundedDays, block.timestamp);
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

    uint timePassed = block.timestamp - _startTime;
    uint dayPassed = timePassed / secondInADay;
    require(_startTime >= 0 && dayPassed - 1 >= rewardingDays, "FOTAFarm: must be earlier rewardingDays");
    startTime = _startTime;
  }

  function updateRewardingDays(uint _days) external onlyMainAdmin {
    require(_days > 0, "FOTAFarm: days invalid");
    rewardingDays = _days;
    emit RewardingDaysUpdated(_days);
  }

  function updateFundingFOTADays(uint _days) external onlyMainAdmin {
    require(_days > 0, "FOTAFarm: days invalid");
    fundingFOTADays = _days;
    emit FundingFOTADaysUpdated(_days);
  }

  function updateLPBonusRate(uint _rate) external onlyMainAdmin {
    require(_rate > 0, "FOTAFarm: rate invalid");
    lpBonus = _rate;
    emit LPBonusRateUpdated(_rate);
  }

  function drainToken(address _tokenAddress, uint _amount) external onlyMainAdmin {
    IBEP20 token = IBEP20(_tokenAddress);
    require(_amount <= token.balanceOf(address(this)), "FOTAFarm: Contract is insufficient balance");
    token.transfer(msg.sender, _amount);
  }

  function updateSecondInADay(uint _secondInDay) external onlyMainAdmin {
    secondInADay = _secondInDay;
  }

  function setContracts(address _fota, address _lp) external onlyMainAdmin {
    fotaToken = IFOTAToken(_fota);
    lpToken = ILPToken(_lp);
  }

  function syncTime() external onlyMainAdmin {
    startTime = 1654819200;
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

import "../libs/zeppelin/token/BEP20/IBEP20.sol";

interface ILPToken is IBEP20 {
  function getReserves() external view returns (uint, uint);
  function totalSupply() external view returns (uint);
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

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
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}