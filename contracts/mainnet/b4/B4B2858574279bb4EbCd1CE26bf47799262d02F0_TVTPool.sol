// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAggregator {
  function latestAnswer() external view returns (int256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPool {
  function userDepositNumber(address user) external view returns (uint256);

  function userDepositDetails(
    address user,
    uint256 index
  ) external view returns (uint256 amount, uint256 startTime);

  function users(
    address user
  )
    external
    view
    returns (address referrer, uint8 percent, uint256 totalTree, uint256 latestWithdraw);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITVTPool {
  event WithdrawInterest(address indexed user, uint256 value);
  event WithdrawInvest(address indexed user, address indexed referrer, uint256 value);
  event WithdrawTree(address indexed user, address indexed referrer, uint256 value);
  event WithdrawToInvest(address indexed user, address indexed referrer, uint256 value);

  event UpdateUser(address indexed user, address indexed referrer, uint256 value);
  event RegisterUser(address indexed user, address indexed referrer, uint256 value);

  event UpdateUserTVT(address indexed user, address indexed referrer, uint256 value);
  event RegisterUserTVT(address indexed user, address indexed referrer, uint256 value);

  struct Invest {
    uint128 amount;
    uint128 startTime;
  }

  struct UserStruct {
    Invest[] invest;
    address referrer;
    uint8 percent;
    uint256 totalTree;
    uint256 latestWithdraw;
  }

  function BNBtoUSD(uint256 value) external view returns (uint256);

  function USDtoBNB(uint256 value) external view returns (uint256);

  function BNBPrice() external view returns (uint256);

  function TVTtoUSD(uint256 value) external view returns (uint256);

  function USDtoTVT(uint256 value) external view returns (uint256);

  function TVTPrice() external view returns (uint256);

  function BNBValue(address user) external view returns (uint256);

  function TVTValue(address user) external view returns (uint256);

  function mining(address referrer) external payable;

  function miningTVT(uint amount, address referrer) external;

  function withdrawInterest() external;

  function withdrawToInvest() external;

  function withdrawInvest(uint256 index) external;

  function totalInterest(address user) external view returns (uint256);

  function indexInterest(
    address sender,
    uint256 index
  ) external view returns (uint256 day, uint256 intrest);

  function calculateInterest(
    address sender
  ) external view returns (uint256[2][] memory rewards, uint256 timestamp);

  function userDepositNumber(address user) external view returns (uint256);

  function userTotalInvest(address user) external view returns (uint256);

  function userInvestDetails(address user) external view returns (Invest[] memory);

  function userDepositDetails(
    address user,
    uint256 index
  ) external view returns (uint256 amount, uint256 startTime);

  function users(
    address user
  )
    external
    view
    returns (address referrer, uint8 percent, uint256 totalTree, uint256 latestWithdraw);

  function tvtUsers(address user) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IUniswap {
  function getReserves()
    external
    view
    returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
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

  function mulDecimals(uint256 a, uint256 b) internal pure returns (uint256) {
    return mul(a, 10 ** b);
  }

  function divDecimals(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, 10 ** b);
  }

  function addDay(uint256 a) internal pure returns (uint256) {
    return add(a, 1 days);
  }

  function toDays(uint256 a) internal pure returns (uint256) {
    return div(a, 1 days);
  }

  function toUint128(uint256 value) internal pure returns (uint128) {
    require(value <= type(uint128).max, "Math: OVERFLOW");
    return uint128(value);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Math.sol";
import "./Secure.sol";
import "./ITVTPool.sol";

abstract contract Migration is ITVTPool, Secure {
  using Math for uint256;

  mapping(address => UserStruct) public override users;
  mapping(address => bool) public override tvtUsers;

  function migrateFromOldPool(
    address _oldPool,
    address user,
    bool _tvtUsers
  ) external onlyOwner {
    ITVTPool oldPool = ITVTPool(_oldPool);

    (address referrer, uint8 percent, uint256 totalTree, uint256 latestWithdraw) = oldPool
      .users(user);

    users[user].percent = percent;
    users[user].referrer = referrer;
    users[user].totalTree = totalTree;
    users[user].latestWithdraw = latestWithdraw;

    delete users[user].invest;

    for (uint256 l = 0; l < oldPool.userDepositNumber(user); l++) {
      (uint256 amount, uint256 startTime) = oldPool.userDepositDetails(user, l);
      users[user].invest.push(Invest(amount.toUint128(), startTime.toUint128()));
    }

    tvtUsers[user] = _tvtUsers;
  }

  function migrateByUser() external {
    _migrate(_msgSender(), true);
  }

  function migrateIntoTVT(address[] memory _users) external onlyOwner {
    for (uint256 i = 0; i < _users.length; i++) {
      address user = _users[i];
      migrateUser(user, true);
    }
  }

  function migrateIntoNormal(address[] memory _users) external onlyOwner {
    for (uint256 i = 0; i < _users.length; i++) {
      address user = _users[i];
      migrateUser(user, false);
    }
  }

  function deleteUsers(address[] memory _users) external onlyOwner {
    for (uint256 i = 0; i < _users.length; i++) {
      _deleteUser(_users[i]);
    }
  }

  function convertUsers(address[] memory _users, bool[] memory _tvtUsers)
    external
    onlyOwner
  {
    require(_users.length == _tvtUsers.length, "Invalid length");

    for (uint256 i = 0; i < _users.length; i++) {
      tvtUsers[_users[i]] = _tvtUsers[i];
    }
  }

  function intoTVT() external {
    tvtUsers[_msgSender()] = true;
  }

  function convertUser(address _user, bool _tvtUser) external onlyOwner {
    tvtUsers[_user] = _tvtUser;
  }

  function migrateUser(address user, bool isTVT) public onlyOwner {
    if (users[user].referrer == address(0)) {
      _migrate(user, isTVT);
    } else {
      tvtUsers[user] = isTVT;
    }
  }

  function _migrate(address user, bool _tvtUsers) internal {
    require(users[user].referrer == address(0), "ALE");

    (
      address referrer,
      uint8 percent,
      uint256 totalTree,
      uint256 latestWithdraw
    ) = OLD_POOL.users(user);

    require(referrer != address(0), "NOE");

    users[user].percent = percent;
    users[user].referrer = referrer;
    users[user].totalTree = totalTree;
    users[user].latestWithdraw = latestWithdraw;

    for (uint256 l = 0; l < OLD_POOL.userDepositNumber(user); l++) {
      (uint256 amount, uint256 startTime) = OLD_POOL.userDepositDetails(user, l);
      users[user].invest.push(Invest(amount.toUint128(), startTime.toUint128()));
    }

    tvtUsers[user] = _tvtUsers;
  }

  // View Functions
  function needMigrate(address user) public view returns (bool) {
    if (users[user].referrer != address(0)) return false;
    (address referrer, , , ) = OLD_POOL.users(user);

    return referrer != address(0);
  }

  function userTotalInvest(address user)
    public
    view
    override
    returns (uint256 totalAmount)
  {
    Invest[] storage userIvest = users[user].invest;
    for (uint8 i = 0; i < userIvest.length; i++) {
      if (userIvest[i].startTime > 0) totalAmount = totalAmount.add(userIvest[i].amount);
    }
  }

  // Modify User Functions
  function addGift(address user, uint256 amount) external onlyOwner {
    users[user].invest.push(Invest(amount.toUint128(), block.timestamp.toUint128()));
  }

  function changeUserPercent(address user, uint8 percent) external onlyOwner {
    users[user].percent = percent;
  }

  function changeUserInvest(
    address user,
    uint256 index,
    Invest memory invest
  ) external onlyOwner {
    users[user].invest[index] = invest;
  }

  function changeUserReferrer(address user, address referrer) external onlyOwner {
    users[user].referrer = referrer;
  }

  function changeUserLatestWithdraw(address user, uint256 latestWithdraw)
    external
    onlyOwner
  {
    users[user].latestWithdraw = latestWithdraw;
  }

  function changeUserTotalTree(address user, uint256 totalTree) external onlyOwner {
    users[user].totalTree = totalTree;
  }

  function changeSubTree(address user, uint256 value) external onlyOwner {
    _subTree(user, value);
  }

  function removeUserInvest(address user, uint256 index) external onlyOwner {
    _withdraw(user, index);
  }

  function resetUser(address user, uint256 value) external onlyOwner {
    _reset(user, value);
  }

  // Private Functions
  function _deposit(address user, uint256 value) internal {
    users[user].invest.push(Invest(value.toUint128(), block.timestamp.toUint128()));

    address referrer = users[user].referrer;
    for (uint8 i = 0; i < 50; i++) {
      if (users[referrer].percent == 0) break;
      users[referrer].totalTree = users[referrer].totalTree.add(value);
      referrer = users[referrer].referrer;
    }
  }

  function _withdraw(address user, uint256 index) internal returns (uint256 value) {
    users[user].invest[index].startTime = 0;

    value = users[user].invest[index].amount;

    if (userTotalInvest(user) < MINIMUM_INVEST) _reset(user, value);
    else _subTree(user, value);
  }

  function _subTree(address user, uint256 value) private {
    address referrer = users[user].referrer;
    for (uint8 i = 0; i < 50; i++) {
      if (users[referrer].totalTree < value) break;
      users[referrer].totalTree = users[referrer].totalTree.sub(value);
      referrer = users[referrer].referrer;
    }
  }

  function _reset(address user, uint256 value) private {
    uint256 treeValue = users[user].totalTree.add(value);
    _subTree(user, treeValue);

    emit WithdrawTree(user, users[user].referrer, treeValue);

    users[user].percent = 0;
    users[user].totalTree = 0;

    delete users[user].invest;
  }

  function _deleteUser(address user) internal {
    delete users[user];
    delete tvtUsers[user];
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IPool.sol";
import "./IUniswap.sol";
import "./IAggregator.sol";

abstract contract Secure {
  event AddedBlackList(address indexed user);
  event RemovedBlackList(address indexed user);

  bool internal locked;

  address public owner;

  address public admin;

  uint8 public BASE_PERCENT = 30;

  uint32 public FEE = 100000000;

  uint64 public MINIMUM_INVEST = 5000000000;

  bytes4 private constant BALANCE = bytes4(keccak256("balanceOf(address)"));

  bytes4 private constant TRANSFER = bytes4(keccak256("transfer(address,uint256)"));

  bytes4 private constant TRANSFER_FROM =
    bytes4(keccak256("transferFrom(address,address,uint256)"));

  address constant TVT_ADDRESS = 0x5b08969db7f8d6e3b353E2BdA9E8E41E76fE3dbB;

  IPool constant OLD_POOL = IPool(0xC256FEF3c0554A7DB8e01D9E795a1C867515a5B2);

  IUniswap constant TVT_USD = IUniswap(0x066B6bA67f512F808Ea15aF32E14CF95260d7058);

  IAggregator constant BNB_USD = IAggregator(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE);

  mapping(address => bool) public blacklist;

  modifier onlyOwner() {
    require(_msgSender() == owner, "OWN");
    _;
  }

  modifier onlyOwnerOrAdmin() {
    require(_msgSender() == owner || _msgSender() == admin, "OWN");
    _;
  }

  modifier secured() {
    require(!blacklist[_msgSender()], "BLK");
    require(!locked, "REN");
    locked = true;
    _;
    locked = false;
  }

  function _msgSender() internal view returns (address) {
    return msg.sender;
  }

  function _TVTBalance(address user) internal view returns (uint256) {
    (, bytes memory data) = TVT_ADDRESS.staticcall(abi.encodeWithSelector(BALANCE, user));

    return abi.decode(data, (uint256));
  }

  function _safeTransferTVT(address to, uint256 value) internal {
    (bool success, bytes memory data) = TVT_ADDRESS.call(
      abi.encodeWithSelector(TRANSFER, to, value)
    );

    require(success && (data.length == 0 || abi.decode(data, (bool))), "TVT");
  }

  function _safeDepositTVT(uint256 value) internal {
    (bool success, bytes memory data) = TVT_ADDRESS.call(
      abi.encodeWithSelector(TRANSFER_FROM, _msgSender(), address(this), value)
    );

    require(success && (data.length == 0 || abi.decode(data, (bool))), "TVT");
  }

  function _safeTransferBNB(address to, uint256 value) internal {
    (bool success, ) = to.call{gas: 23000, value: value}("");

    require(success, "ETH");
  }

  function lock() external onlyOwner {
    locked = true;
  }

  function unlock() external onlyOwner {
    locked = false;
  }

  function changeFee(uint32 fee) external onlyOwner {
    FEE = fee;
  }

  function changeBasePercent(uint8 percent) external onlyOwner {
    BASE_PERCENT = percent;
  }

  function addBlackList(address user) external onlyOwner {
    blacklist[user] = true;
    emit AddedBlackList(user);
  }

  function removeBlackList(address user) external onlyOwner {
    blacklist[user] = false;
    emit RemovedBlackList(user);
  }

  function changeMinimumInvest(uint64 amount) external onlyOwner {
    MINIMUM_INVEST = amount;
  }

  function changeOwner(address newOwner) external onlyOwner {
    owner = newOwner;
  }

  function changeAdmin(address newAdmin) external onlyOwner {
    admin = newAdmin;
  }

  function withdrawBNB(uint256 value) external onlyOwner {
    payable(owner).transfer(value);
  }

  function withdrawBNBAdmin(uint256 value) external onlyOwnerOrAdmin {
    payable(admin).transfer(value);
  }

  function withdrawTVT(uint256 value) external onlyOwner {
    _safeTransferTVT(owner, value);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Migration.sol";

contract TVTPool is Migration {
  using Math for uint256;

  constructor() {
    owner = _msgSender();
    admin = _msgSender();

    users[admin].referrer = owner;
    users[admin].percent = BASE_PERCENT;
  }

  receive() external payable {
    mining(owner);
  }

  // Price Calculation
  function BNBPrice() public view override returns (uint256) {
    int256 price = BNB_USD.latestAnswer();

    return uint256(price);
  }

  function TVTPrice() public view override returns (uint256) {
    (uint256 res0, uint256 res1, ) = TVT_USD.getReserves();

    return res1.mulDecimals(8).div(res0);
  }

  function BNBtoUSD(uint256 value) public view override returns (uint256) {
    return value.mul(BNBPrice()).divDecimals(18);
  }

  function TVTtoUSD(uint256 value) public view override returns (uint256) {
    return value.mul(TVTPrice()).divDecimals(18);
  }

  function USDtoBNB(uint256 value) public view override returns (uint256) {
    return value.mulDecimals(18).div(BNBPrice());
  }

  function USDtoTVT(uint256 value) public view override returns (uint256) {
    return value.mulDecimals(18).div(TVTPrice());
  }

  // Deposit function
  function mining(address referrer) public payable override {
    uint256 value = BNBtoUSD(msg.value);
    require(value >= MINIMUM_INVEST, "VAL");

    if (users[_msgSender()].referrer == address(0)) {
      require(userTotalInvest(referrer) >= MINIMUM_INVEST, "REF");

      users[_msgSender()].referrer = referrer;
      users[_msgSender()].percent = BASE_PERCENT;
      users[_msgSender()].latestWithdraw = block.timestamp;

      tvtUsers[_msgSender()] = tvtUsers[referrer];

      _deposit(_msgSender(), value);

      emit RegisterUser(_msgSender(), referrer, value);
    } else {
      require(users[_msgSender()].percent > 0, "UIW");

      _deposit(_msgSender(), value);

      emit UpdateUser(_msgSender(), users[_msgSender()].referrer, value);
    }

    users[admin].invest.push(Invest(value.toUint128(), block.timestamp.toUint128()));
  }

  function miningTVT(uint256 amount, address referrer) public override {
    uint256 value = TVTtoUSD(amount);
    require(value >= MINIMUM_INVEST, "VAL");
    require(TVTValue(_msgSender()) >= amount, "TVL");

    _safeDepositTVT(amount);

    if (users[_msgSender()].referrer == address(0)) {
      require(tvtUsers[referrer], "RNT");
      require(userTotalInvest(referrer) >= MINIMUM_INVEST, "REF");

      users[_msgSender()].referrer = referrer;
      users[_msgSender()].percent = BASE_PERCENT;
      users[_msgSender()].latestWithdraw = block.timestamp;

      tvtUsers[_msgSender()] = true;

      _deposit(_msgSender(), value);
      emit RegisterUserTVT(_msgSender(), referrer, value);
    } else {
      require(users[_msgSender()].percent > 0, "UIW");
      require(tvtUsers[_msgSender()], "NOT");

      _deposit(_msgSender(), value);

      emit UpdateUserTVT(_msgSender(), users[_msgSender()].referrer, value);
    }
  }

  // calculate rewards
  function totalInterest(address sender) public view override returns (uint256 rewards) {
    uint256 userPercent = users[sender].percent;

    Invest[] storage userIvest = users[sender].invest;

    for (uint8 i = 0; i < userIvest.length; i++) {
      uint256 startTime = userIvest[i].startTime;
      if (startTime == 0) continue;
      uint256 latestWithdraw = users[sender].latestWithdraw;

      if (latestWithdraw.addDay() <= block.timestamp) {
        if (startTime > latestWithdraw) latestWithdraw = startTime;
        uint256 reward = userPercent.mul(userIvest[i].amount).div(1000);
        uint256 day = block.timestamp.sub(latestWithdraw).toDays();
        rewards = rewards.add(day.mul(reward));
      }
    }
  }

  function calculateInterest(address sender)
    public
    view
    override
    returns (uint256[2][] memory rewards, uint256 requestTime)
  {
    rewards = new uint256[2][](users[sender].invest.length);
    requestTime = block.timestamp;

    for (uint8 i = 0; i < rewards.length; i++) {
      (uint256 day, uint256 interest) = indexInterest(sender, i);
      rewards[i][0] = day;
      rewards[i][1] = interest;
    }
  }

  function indexInterest(address sender, uint256 index)
    public
    view
    override
    returns (uint256 day, uint256 interest)
  {
    uint256 userPercent = users[sender].percent;
    uint256 latestWithdraw = users[sender].latestWithdraw;

    Invest storage userIvest = users[sender].invest[index];
    uint256 startTime = userIvest.startTime;
    if (startTime == 0) return (0, 0);

    if (latestWithdraw.addDay() <= block.timestamp) {
      if (startTime > latestWithdraw) latestWithdraw = startTime;
      uint256 reward = userPercent.mul(userIvest.amount).div(1000);
      day = block.timestamp.sub(latestWithdraw).toDays();
      interest = day.mul(reward);
    }
  }

  // Widthraw Funtions
  function withdrawToInvest() external override {
    uint256 daily = totalInterest(_msgSender());

    require(daily >= MINIMUM_INVEST, "VAL");

    users[_msgSender()].latestWithdraw = block.timestamp;

    _deposit(_msgSender(), daily);

    emit WithdrawToInvest(_msgSender(), users[_msgSender()].referrer, daily);
  }

  function withdrawInterest() public override secured {
    require(userTotalInvest(_msgSender()) >= MINIMUM_INVEST, "USR");
    uint256 daily = totalInterest(_msgSender());

    require(daily > 0, "VAL");

    users[_msgSender()].latestWithdraw = block.timestamp;

    if (tvtUsers[_msgSender()]) {
      _safeTransferTVT(_msgSender(), USDtoTVT(daily)); // Transfer TVT to user
    } else {
      _safeTransferBNB(_msgSender(), USDtoBNB(daily.sub(FEE))); // Transfer BNB to user
    }

    emit WithdrawInterest(_msgSender(), daily);
  }

  function withdrawInvest(uint256 index) external override secured {
    require(userTotalInvest(_msgSender()) >= MINIMUM_INVEST, "USR");
    require(users[_msgSender()].invest[index].startTime != 0, "VAL");

    (, uint256 daily) = indexInterest(_msgSender(), index);

    uint256 amount = _withdraw(_msgSender(), index);

    uint256 total = amount.add(daily);

    if (tvtUsers[_msgSender()]) {
      _safeTransferTVT(_msgSender(), USDtoTVT(total)); // Transfer TVT to user
    } else {
      _safeTransferBNB(_msgSender(), USDtoBNB(total.sub(FEE))); // Transfer BNB to user
    }

    emit WithdrawInterest(_msgSender(), daily);
    emit WithdrawInvest(_msgSender(), users[_msgSender()].referrer, amount);
  }

  // User API Functions
  function BNBValue(address user) external view override returns (uint256) {
    return user.balance;
  }

  function TVTValue(address user) public view override returns (uint256) {
    return _TVTBalance(user);
  }

  function userDepositNumber(address user) external view override returns (uint256) {
    return users[user].invest.length;
  }

  function userDepositDetails(address user, uint256 index)
    external
    view
    override
    returns (uint256 amount, uint256 startTime)
  {
    amount = users[user].invest[index].amount;
    startTime = users[user].invest[index].startTime;
  }

  function userInvestDetails(address user)
    external
    view
    override
    returns (Invest[] memory)
  {
    return users[user].invest;
  }
}