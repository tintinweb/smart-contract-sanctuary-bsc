// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Math.sol";
import "./Secure.sol";
import "./IUserData.sol";

contract UserData is IUserData, Secure {
  using Math for uint64;
  using Math for uint256;

  address[] public override userList;
  mapping(address => UserStruct) public override users;

  constructor() {
    authorizeContract(_msgSender());
    users[_msgSender()].referrer = address(1);
    userList.push(_msgSender());
  }

  // Registeration functions ----------------------------------------------------------
  function registerAndInvest(
    address user,
    address ref,
    uint256 gift,
    Invest memory invest
  ) public override onlyContract returns (bool) {
    require(register(user, ref, gift), "USER::RFA");
    return investment(user, invest);
  }

  function register(
    address user,
    address ref,
    uint256 gift
  ) public override onlyContract returns (bool) {
    require(!exist(user), "USER::USE");
    require(exist(ref), "USER::REF");
    users[user].referrer = ref;
    userList.push(user);
    emit Register(user, ref, gift);
    return true;
  }

  function investment(address user, Invest memory invest)
    public
    override
    onlyContract
    returns (bool)
  {
    users[user].invest.push(invest);
    emit Investment(user, invest.amount);
    return true;
  }

  function payReferrer(
    address lastRef,
    uint64 value,
    uint8 level
  ) public override onlyContract returns (bool) {
    for (uint8 i = 0; i < level; i++) {
      address refParent = users[lastRef].referrer;
      if (refParent == address(0)) break;
      if (exist(refParent))
        changeRefAmount(refParent, users[refParent].refAmount.add(value));
      lastRef = refParent;
    }
    return true;
  }

  // Modifier functions ----------------------------------------------------------
  function addGiftAmount(address user, uint256 value)
    external
    override
    onlyContract
  {
    changeGiftAmount(user, users[user].giftAmount.add(value));
    emit GiftReceived(user, value);
  }

  function addRefAmount(address user, uint256 value)
    external
    override
    onlyContract
  {
    changeRefAmount(user, users[user].refAmount.add(value));
    emit ReferralReceived(user, tx.origin, value);
  }

  function changeInvestIndex(
    address user,
    uint256 index,
    Invest memory invest
  ) external override onlyContract returns (bool) {
    users[user].invest[index] = invest;
    return users[user].invest[index].reward == invest.reward;
  }

  function changeInvestIndexReward(
    address user,
    uint256 index,
    uint256 value
  ) external override onlyContract returns (bool) {
    users[user].invest[index].reward = value.toUint64();
    return users[user].invest[index].reward == value;
  }

  function changeGiftAmount(address user, uint256 value)
    public
    override
    onlyContract
  {
    users[user].giftAmount = value.toUint64();
  }

  function changeRefAmount(address user, uint256 value)
    public
    override
    onlyContract
  {
    users[user].refAmount = value.toUint64();
  }

  function changeLatestWithdraw(address user, uint256 time)
    external
    override
    onlyContract
  {
    users[user].latestWithdraw = time.toUint64();
  }

  function changeReferrer(address user, address ref)
    external
    override
    onlyContract
  {
    users[user].referrer = ref;
  }

  function changeUserData(
    address user,
    uint256 ref,
    uint256 gift,
    uint256 lw
  ) external override onlyContract {
    users[user].refAmount = ref.toUint64();
    users[user].giftAmount = gift.toUint64();
    users[user].latestWithdraw = lw.toUint64();
  }

  function deleteUser(address user) external override onlyContract {
    delete users[user];
  }

  function deleteUserInvest(address user) external override onlyContract {
    delete users[user].invest;
  }

  function deleteUserInvestIndex(address user, uint256 index)
    external
    override
    onlyContract
  {
    delete users[user].invest[index];
  }

  // User Details ----------------------------------------------------------
  function calculateHourly(address user, uint256 time)
    public
    view
    override
    returns (uint256 rewards)
  {
    uint256 userIvestLength = depositNumber(user);
    for (uint8 i = 0; i < userIvestLength; i++) {
      uint256 reward = users[user].invest[i].reward;
      if (reward > 0) {
        uint256 startTime = users[user].invest[i].startTime;
        uint256 lw = latestWithdraw(user);
        if (lw < startTime) lw = startTime;
        if (time >= lw.addHour()) {
          uint256 hour = time.sub(lw).toHours();
          rewards = rewards.add(hour.mul(reward));
        }
      }
    }
  }

  function exist(address user) public view override returns (bool) {
    return users[user].referrer != address(0);
  }

  function referrer(address user) external view override returns (address) {
    return users[user].referrer;
  }

  function latestWithdraw(address user) public view override returns (uint256) {
    return users[user].latestWithdraw;
  }

  function investDetails(address user)
    public
    view
    override
    returns (Invest[] memory)
  {
    return users[user].invest;
  }

  function depositNumber(address user) public view override returns (uint256) {
    return users[user].invest.length;
  }

  function depositDetail(address user, uint256 index)
    public
    view
    override
    returns (
      uint256 amount,
      uint256 period,
      uint256 reward,
      uint256 startTime,
      uint256 endTime
    )
  {
    amount = users[user].invest[index].amount;
    period = users[user].invest[index].period;
    reward = users[user].invest[index].reward;
    startTime = users[user].invest[index].startTime;
    endTime = startTime.add(period);
  }

  function maxPeriod(address user)
    public
    view
    override
    returns (uint256 maxTime)
  {
    uint256 userIvestLength = depositNumber(user);
    if (userIvestLength > 0) {
      for (uint256 i = 0; i < userIvestLength; i++) {
        uint256 periodTime = users[user].invest[i].period;
        if (maxTime < periodTime) maxTime = periodTime;
      }
    }
  }

  function investExpireTime(address user, uint256 index)
    public
    view
    override
    returns (uint256 endTime)
  {
    uint256 userIvestLength = depositNumber(user);
    if (userIvestLength > 0 && index < userIvestLength) {
      (, , , , endTime) = depositDetail(user, index);
    }
  }

  function investIsExpired(address user, uint256 index)
    public
    view
    override
    returns (bool)
  {
    return investExpireTime(user, index) <= block.timestamp;
  }

  function userListLength() external view override returns (uint256) {
    return userList.length;
  }

  function getUserList() external view override returns (address[] memory) {
    return userList;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// CAUTION
// This version of Math should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.
library Math {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    return a + b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return a - b;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    return a * b;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return a % b;
  }

  function addHour(uint256 a) internal pure returns (uint256) {
    return add(a, 1 hours);
  }

  function toHours(uint256 a) internal pure returns (uint256) {
    return div(a, 1 hours);
  }

  function toUint64(uint256 value) internal pure returns (uint64) {
    require(value <= type(uint64).max, "Math: OVERFLOW");
    return uint64(value);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract Secure is Ownable {
  event AddBlacklist(address indexed user);
  event RemoveBlacklist(address indexed user);
  event AuthorizeContract(address indexed smartContract);
  event DeauthorizeContract(address indexed smartContract);

  mapping(address => bool) public blacklist;
  mapping(address => bool) public contracts;

  bytes4 private constant TRANSFER =
    bytes4(keccak256(bytes("transfer(address,uint256)")));

  modifier onlyContract() {
    require(contracts[_msgSender()], "USER::ONC");
    _;
  }

  function _safeTransferETH(address to, uint256 value) internal {
    (bool success, ) = to.call{ gas: 23000, value: value }("");

    require(success, "USER::ETH");
  }

  function _safeTransfer(
    address token,
    address to,
    uint256 value
  ) internal {
    (bool success, bytes memory data) = token.call(
      abi.encodeWithSelector(TRANSFER, to, value)
    );
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      "USER::TTF"
    );
  }

  function addListBlacklist(address[] memory users) external onlyContract {
    for (uint8 i = 0; i < users.length; i++) {
      address user = users[i];
      blacklist[user] = true;
    }
  }

  function removeListBlacklist(address[] memory users) external onlyContract {
    for (uint8 i = 0; i < users.length; i++) {
      address user = users[i];
      blacklist[user] = false;
    }
  }

  function addBlacklist(address user) external onlyContract {
    blacklist[user] = true;
    emit AddBlacklist(user);
  }

  function removeBlacklist(address user) external onlyContract {
    blacklist[user] = false;
    emit RemoveBlacklist(user);
  }

  function authorizeContract(address smartContract) public onlyOwner {
    contracts[smartContract] = true;
    emit AuthorizeContract(smartContract);
  }

  function deauthorizeContract(address smartContract) public onlyOwner {
    contracts[smartContract] = false;
    emit DeauthorizeContract(smartContract);
  }

  function withdrawToken(address token, uint256 value) external onlyContract {
    _safeTransfer(token, owner(), value);
  }

  function withdrawBnb(uint256 value) external onlyContract {
    payable(owner()).transfer(value);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUserData {
  event Register(
    address indexed user,
    address indexed ref,
    uint256 indexed gift
  );
  event Investment(address indexed user, uint256 value);
  event GiftReceived(address indexed user, uint256 value);
  event ReferralReceived(address indexed user, address from, uint256 value);

  struct Invest {
    uint64 amount;
    uint64 period;
    uint64 reward;
    uint64 startTime;
  }

  struct UserStruct {
    Invest[] invest;
    address referrer;
    uint64 refAmount;
    uint64 giftAmount;
    uint64 latestWithdraw;
  }

  // Registeration functions ----------------------------------------------------------
  function registerAndInvest(
    address user,
    address referrer,
    uint256 gift,
    Invest memory invest
  ) external returns (bool);

  function register(
    address user,
    address referrer,
    uint256 gift
  ) external returns (bool);

  function investment(address user, Invest memory invest)
    external
    returns (bool);

  function payReferrer(
    address lastRef,
    uint64 value,
    uint8 level
  ) external returns (bool);

  // Modifier functions ----------------------------------------------------------
  function changeInvestIndex(
    address user,
    uint256 index,
    Invest memory invest
  ) external returns (bool);

  function changeInvestIndexReward(
    address user,
    uint256 index,
    uint256 value
  ) external returns (bool);

  function changeLatestWithdraw(address user, uint256 latestWithdraw) external;

  function changeReferrer(address user, address referrer) external;

  function changeGiftAmount(address user, uint256 value) external;

  function changeRefAmount(address user, uint256 value) external;

  function addGiftAmount(address user, uint256 value) external;

  function addRefAmount(address user, uint256 value) external;

  function changeUserData(
    address user,
    uint256 ref,
    uint256 gift,
    uint256 lw
  ) external;

  function deleteUserInvestIndex(address user, uint256 index) external;

  function deleteUserInvest(address user) external;

  function deleteUser(address user) external;

  // User Details ----------------------------------------------------------
  function users(address user)
    external
    view
    returns (
      address referrer,
      uint64 refAmount,
      uint64 giftAmount,
      uint64 latestWithdraw
    );

  function calculateHourly(address user, uint256 time)
    external
    view
    returns (uint256 rewards);

  function userList(uint256 index) external view returns (address);

  function exist(address user) external view returns (bool);

  function referrer(address user) external view returns (address);

  function latestWithdraw(address user) external view returns (uint256);

  function depositNumber(address user) external view returns (uint256);

  function investDetails(address user) external view returns (Invest[] memory);

  function depositDetail(address user, uint256 index)
    external
    view
    returns (
      uint256 amount,
      uint256 period,
      uint256 reward,
      uint256 startTime,
      uint256 endTime
    );

  function maxPeriod(address user) external view returns (uint256);

  function investExpireTime(address user, uint256 index)
    external
    view
    returns (uint256);

  function investIsExpired(address user, uint256 index)
    external
    view
    returns (bool);

  function userListLength() external view returns (uint256);

  function getUserList() external view returns (address[] memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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