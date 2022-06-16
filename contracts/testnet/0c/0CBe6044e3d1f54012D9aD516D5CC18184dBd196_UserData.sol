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
    Invest memory invest
  ) public override onlyContract returns (bool) {
    require(register(user, ref), "RFA");
    return investment(user, invest);
  }

  function register(address user, address ref)
    public
    override
    onlyContract
    returns (bool)
  {
    require(!exist(user), "USE");
    require(exist(ref), "REF");
    users[user].latestWithdraw = block.timestamp.toUint64();
    users[user].referrer = ref;
    userList.push(user);
    emit Register(user, ref);
    return true;
  }

  function investment(address user, Invest memory invest)
    public
    override
    onlyContract
    returns (bool)
  {
    users[user].invest.push(invest);
    if (exist(user)) addTotalAmount(user, invest.amount);
    else changeTotalAmount(user, invest.amount);
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
  function addTotalAmount(address user, uint256 value)
    public
    override
    onlyContract
  {
    require(exist(user), "USN");
    changeTotalAmount(user, users[user].totalAmount.add(value));
  }

  function addGiftAmount(address user, uint256 value)
    external
    override
    onlyContract
  {
    require(exist(user), "USN");
    changeGiftAmount(user, users[user].giftAmount.add(value));
    emit GiftReceived(user, value);
  }

  function addRefAmount(address user, uint256 value)
    external
    override
    onlyContract
  {
    require(exist(user), "USN");
    changeRefAmount(user, users[user].refAmount.add(value));
    emit ReferralReceived(user, value);
  }

  function changeTotalAmount(address user, uint256 value)
    public
    override
    onlyContract
  {
    users[user].totalAmount = value.toUint64();
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

  function deleteUser(address user) external override onlyContract {
    require(exist(user), "USN");
    delete users[user];
  }

  function deleteUserInvest(address user) external override onlyContract {
    require(exist(user), "USN");
    changeTotalAmount(user, 0);
    delete users[user].invest;
  }

  // User Details ----------------------------------------------------------
  function exist(address user) public view override returns (bool) {
    return users[user].referrer != address(0);
  }

  function referrer(address user) external view override returns (address) {
    return users[user].referrer;
  }

  function refAmount(address user) external view override returns (uint256) {
    return users[user].refAmount;
  }

  function giftAmount(address user) external view override returns (uint256) {
    return users[user].giftAmount;
  }

  function totalAmount(address user) external view override returns (uint256) {
    return users[user].totalAmount;
  }

  function latestWithdraw(address user)
    external
    view
    override
    returns (uint256)
  {
    return users[user].latestWithdraw;
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

  function expireTime(address user)
    public
    view
    override
    returns (uint256 latestTime)
  {
    uint256 userIvestLength = depositNumber(user);
    if (userIvestLength > 0) {
      for (uint256 i = 0; i < userIvestLength; i++) {
        uint256 investExp = investExpireTime(user, i);
        if (latestTime < investExp) latestTime = investExp;
      }
    }
  }

  function isExpired(address user) public view override returns (bool) {
    uint256 userIvestLength = depositNumber(user);
    if (userIvestLength > 0) {
      for (uint256 i = 0; i < userIvestLength; i++) {
        if (investIsExpired(user, i)) return true;
      }
      return false;
    } else return true;
  }

  function userListLength() external view override returns (uint256) {
    return userList.length;
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

  bool internal locked;

  mapping(address => bool) public blacklist;
  mapping(address => bool) public contracts;

  bytes4 private constant TRANSFER =
    bytes4(keccak256(bytes("transfer(address,uint256)")));

  modifier onlyContract() {
    require(contracts[_msgSender()], "ONC");
    _;
  }

  function _safeTransferETH(address to, uint256 value) internal {
    (bool success, ) = to.call{ gas: 23000, value: value }("");

    require(success, "ETH");
  }

  function _safeTransfer(
    address token,
    address to,
    uint256 value
  ) internal {
    (bool success, bytes memory data) = token.call(
      abi.encodeWithSelector(TRANSFER, to, value)
    );
    require(success && (data.length == 0 || abi.decode(data, (bool))), "TTF");
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
  event Register(address indexed user, address ref);
  event Investment(address indexed user, uint256 value);
  event GiftReceived(address indexed user, uint256 value);
  event ReferralReceived(address indexed user, uint256 value);

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
    uint64 totalAmount;
    uint64 latestWithdraw;
  }

  // Registeration functions ----------------------------------------------------------
  function registerAndInvest(
    address user,
    address referrer,
    Invest memory invest
  ) external returns (bool);

  function register(address user, address referrer) external returns (bool);

  function investment(address user, Invest memory invest)
    external
    returns (bool);

  function payReferrer(
    address lastRef,
    uint64 value,
    uint8 level
  ) external returns (bool);

  // Modifier functions ----------------------------------------------------------
  function changeLatestWithdraw(address user, uint256 latestWithdraw) external;

  function changeReferrer(address user, address referrer) external;

  function changeTotalAmount(address user, uint256 value) external;

  function changeGiftAmount(address user, uint256 value) external;

  function changeRefAmount(address user, uint256 value) external;

  function addTotalAmount(address user, uint256 value) external;

  function addGiftAmount(address user, uint256 value) external;

  function addRefAmount(address user, uint256 value) external;

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
      uint64 totalAmount,
      uint64 latestWithdraw
    );

  function userList(uint256 index) external view returns (address);

  function exist(address user) external view returns (bool);

  function referrer(address user) external view returns (address);

  function refAmount(address user) external view returns (uint256);

  function totalAmount(address user) external view returns (uint256);

  function giftAmount(address user) external view returns (uint256);

  function latestWithdraw(address user) external view returns (uint256);

  function depositNumber(address user) external view returns (uint256);

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

  function investExpireTime(address user, uint256 index)
    external
    view
    returns (uint256);

  function investIsExpired(address user, uint256 index)
    external
    view
    returns (bool);

  function expireTime(address user) external view returns (uint256);

  function isExpired(address user) external view returns (bool);

  function userListLength() external view returns (uint256);
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