// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./TokenLockForDividendsAndReflections.sol";
import "./VestingLockForDividendsAndReflections.sol";
import "./LiquidityLock.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ArborSwapDeps/IUniswapV2Pair.sol";
import "./ArborSwapDeps/IUniswapV2Factory.sol";

interface IAdmin {
  function isAdmin(address user) external view returns (bool);
}

contract LockFactory is Ownable {
  
  struct FeeInfo {
    uint256 liquidityFee;
    uint256 normalFee;
    uint256 vestingFee;
    uint256 rewardFee;
    uint256 rewardVestingFee;
    address payable feeReceiver;
  }

  IAdmin public admin;
  FeeInfo public fee;

  address[] public tokenLock;
  address[] public liquidityLock;

  mapping(address => address[]) public tokenLockOwner;
  mapping(address => address[]) public liquidityLockOwner;
  mapping(uint256 => address) public liquidityLockIdToAddress;
  mapping(uint256 => address) public tokenLockIdToAddress;

  event LogSetFee(string feeType, uint256 newFee);
  event LogSetFeeReceiver(address newFeeReceiver);
  event LogCreateTokenLock(address lock, address owner);
  event LogCreateLiquidityLock(address lock, address owner);

  constructor(address _adminContract) {
    require(_adminContract != address(0), "ADDRESS_ZERO");
    admin = IAdmin(_adminContract);
  }

  modifier onlyAdmin() {
    require(admin.isAdmin(msg.sender), "NOT_ADMIN");
    _;
  }

  function createTokenLock(
    address _owner,
    address _token,
    uint256 _amount,
    uint256 _unlockDate,
    string memory _logoImage
  ) external payable {
    require(_owner != address(0), "ADDRESS_ZERO");
    require(msg.value >= fee.normalFee, "BAD_FEE");
    require(IERC20(_token).balanceOf(msg.sender) >= _amount, "NOT_ENOUGH_TOKEN");
    require(IERC20(_token).allowance(msg.sender, address(this)) >= _amount, "BAD_ALLOWANCE");

    TokenLockDividendsAndReflections lock = new TokenLockDividendsAndReflections(_owner, _unlockDate, _amount, _token, _logoImage, false);
    address createdLock = address(lock);

    uint256 id = tokenLock.length;
    tokenLockIdToAddress[id] = createdLock;
    tokenLockOwner[_owner].push(createdLock);
    tokenLock.push(createdLock);
    _safeTransferExactAmount(_token, msg.sender, createdLock, _amount);
    fee.feeReceiver.transfer(msg.value);
    emit LogCreateTokenLock(createdLock, _owner);
  }

  function createRewardTokenLock(
    address _owner,
    address _token,
    uint256 _amount,
    uint256 _unlockDate,
    string memory _logoImage
  ) external payable {
    require(_owner != address(0), "ADDRESS_ZERO");
    require(msg.value >= fee.rewardFee, "BAD_FEE");
    require(IERC20(_token).balanceOf(msg.sender) >= _amount, "NOT_ENOUGH_TOKEN");
    require(IERC20(_token).allowance(msg.sender, address(this)) >= _amount, "BAD_ALLOWANCE");

    TokenLockDividendsAndReflections lock = new TokenLockDividendsAndReflections(_owner, _unlockDate, _amount, _token, _logoImage, true);
    address createdLock = address(lock);

    uint256 id = tokenLock.length;
    tokenLockIdToAddress[id] = createdLock;
    tokenLockOwner[_owner].push(createdLock);
    tokenLock.push(createdLock);
    _safeTransferExactAmount(_token, msg.sender, createdLock, _amount);
    fee.feeReceiver.transfer(msg.value);
    emit LogCreateTokenLock(createdLock, _owner);
  }

  function createVestingLock(
    address _owner,
    address _token,
    uint256 _amount,
    uint256 _unlockDate,
    uint256 _tgePercent,
    uint256 _cycle,
    uint256 _cyclePercent,
    string memory _logoImage
  ) external payable {
    require(_owner != address(0), "ADDRESS_ZERO");
    require(msg.value >= fee.vestingFee, "BAD_FEE");
    require(IERC20(_token).balanceOf(msg.sender) >= _amount, "NOT_ENOUGH_TOKEN");
    require(IERC20(_token).allowance(msg.sender, address(this)) >= _amount, "BAD_ALLOWANCE");
    require(_isValidVested(_tgePercent, _cyclePercent), "NOT_VALID_VESTED");

    VestingLockDividendsAndReflections lock = new VestingLockDividendsAndReflections(
      _owner,
      _unlockDate,
      _amount,
      _token,
      _tgePercent,
      _cycle,
      _cyclePercent,
      _logoImage,
      false
    );
    address createdLock = address(lock);

    uint256 id = tokenLock.length;
    tokenLockIdToAddress[id] = createdLock;
    tokenLockOwner[_owner].push(createdLock);
    tokenLock.push(createdLock);
    _safeTransferExactAmount(_token, msg.sender, createdLock, _amount);
    fee.feeReceiver.transfer(msg.value);
    emit LogCreateTokenLock(createdLock, _owner);
  }

  function createRewardVestingLock(
    address _owner,
    address _token,
    uint256 _amount,
    uint256 _unlockDate,
    uint256 _tgePercent,
    uint256 _cycle,
    uint256 _cyclePercent,
    string memory _logoImage
  ) external payable {
    require(_owner != address(0), "ADDRESS_ZERO");
    require(msg.value >= fee.rewardVestingFee, "BAD_FEE");
    require(IERC20(_token).balanceOf(msg.sender) >= _amount, "NOT_ENOUGH_TOKEN");
    require(IERC20(_token).allowance(msg.sender, address(this)) >= _amount, "BAD_ALLOWANCE");
    require(_isValidVested(_tgePercent, _cyclePercent), "NOT_VALID_VESTED");

    VestingLockDividendsAndReflections lock = new VestingLockDividendsAndReflections(
      _owner,
      _unlockDate,
      _amount,
      _token,
      _tgePercent,
      _cycle,
      _cyclePercent,
      _logoImage,
      true
    );
    address createdLock = address(lock);

    uint256 id = tokenLock.length;
    tokenLockIdToAddress[id] = createdLock;
    tokenLockOwner[_owner].push(createdLock);
    tokenLock.push(createdLock);
    _safeTransferExactAmount(_token, msg.sender, createdLock, _amount);
    fee.feeReceiver.transfer(msg.value);
    emit LogCreateTokenLock(createdLock, _owner);
  }

  function createLiquidityLock(
    address _owner,
    address _token,
    uint256 _amount,
    uint256 _unlockDate,
    string memory _logoImage
  ) external payable {
    require(_owner != address(0), "ADDRESS_ZERO");
    address lpFactory = _parseFactoryAddress(_token);
    require(_isValidLpToken(_token, lpFactory), "NOT_VALID_LP_TOKEN");
    require(msg.value >= fee.liquidityFee, "BAD_FEE");
    require(IERC20(_token).balanceOf(msg.sender) >= _amount, "NOT_ENOUGH_TOKEN");
    require(IERC20(_token).allowance(msg.sender, address(this)) >= _amount, "BAD_ALLOWANCE");

    LiquidityLock lock = new LiquidityLock(_owner, _unlockDate, _amount, _token, _logoImage);
    address createdLock = address(lock);

    uint256 id = liquidityLock.length;
    liquidityLockIdToAddress[id] = createdLock;
    liquidityLockOwner[_owner].push(createdLock);
    liquidityLock.push(createdLock);
    _safeTransferExactAmount(_token, msg.sender, createdLock, _amount);
    fee.feeReceiver.transfer(msg.value);
    emit LogCreateLiquidityLock(createdLock, _owner);
  }

  function setNormalFee(uint256 _fee) public onlyAdmin {
    require(fee.normalFee != _fee, "BAD_INPUT");
    fee.normalFee = _fee;
    emit LogSetFee("Normal Fee", _fee);
  }

  function setLiquidityFee(uint256 _fee) public onlyAdmin {
    require(fee.liquidityFee != _fee, "BAD_INPUT");
    fee.liquidityFee = _fee;
    emit LogSetFee("Liquidity Fee", _fee);
  }

  function setVestingFee(uint256 _fee) public onlyAdmin {
    require(fee.vestingFee != _fee, "BAD_INPUT");
    fee.vestingFee = _fee;
    emit LogSetFee("Vesting Fee", _fee);
  }

  function setRewardFee(uint256 _fee) public onlyAdmin {
    require(fee.rewardFee != _fee, "BAD_INPUT");
    fee.rewardFee = _fee;
    emit LogSetFee("Reward Fee", _fee);
  }

  function setRewardVestingFee(uint256 _fee) public onlyAdmin {
    require(fee.rewardVestingFee != _fee, "BAD_INPUT");
    fee.rewardVestingFee = _fee;
    emit LogSetFee("Reward Vesting Fee", _fee);
  }

  function setFeeReceiver(address payable _receiver) public onlyAdmin {
    require(_receiver != address(0), "ADDRESS_ZERO");
    require(fee.feeReceiver != _receiver, "BAD_INPUT");
    fee.feeReceiver = _receiver;
    emit LogSetFeeReceiver(_receiver);
  }

  // GETTER FUNCTION

  function getTokenLock(uint256 startIndex, uint256 endIndex) external view returns (address[] memory) {
    require(endIndex > startIndex, "BAD_INPUT");
    require(endIndex <= tokenLock.length, "OUT_OF_RANGE");

    address[] memory tempLock = new address[](endIndex - startIndex);
    uint256 index = 0;

    for (uint256 i = startIndex; i < endIndex; i++) {
      tempLock[index] = tokenLock[i];
      index++;
    }

    return tempLock;
  }

  function getLiquidityLock(uint256 startIndex, uint256 endIndex) external view returns (address[] memory) {
    require(endIndex > startIndex, "BAD_INPUT");
    require(endIndex <= liquidityLock.length, "OUT_OF_RANGE");

    address[] memory tempLock = new address[](endIndex - startIndex);
    uint256 index = 0;

    for (uint256 i = startIndex; i < endIndex; i++) {
      tempLock[index] = liquidityLock[i];
      index++;
    }

    return tempLock;
  }

  function getTotalTokenLock() external view returns (uint256) {
    return tokenLock.length;
  }

  function getTotalLiquidityLock() external view returns (uint256) {
    return liquidityLock.length;
  }

  function getTokenLockAddress(uint256 id) external view returns (address) {
    return tokenLockIdToAddress[id];
  }

  function getLiquidityLockAddress(uint256 id) external view returns (address) {
    return liquidityLockIdToAddress[id];
  }

  function getLastTokenLock() external view returns (address) {
    if (tokenLock.length > 0) {
      return tokenLock[tokenLock.length - 1];
    }
    return address(0);
  }

  function getLastLiquidityLock() external view returns (address) {
    if (liquidityLock.length > 0) {
      return liquidityLock[liquidityLock.length - 1];
    }
    return address(0);
  }

  // UTILITY

  function _safeTransferExactAmount(
    address token,
    address sender,
    address recipient,
    uint256 amount
  ) internal {
    uint256 oldRecipientBalance = IERC20(token).balanceOf(recipient);
    IERC20(token).transferFrom(sender, recipient, amount);
    uint256 newRecipientBalance = IERC20(token).balanceOf(recipient);
    require(newRecipientBalance - oldRecipientBalance == amount, "NOT_EQUAL_TRANFER");
  }

  function _parseFactoryAddress(address token) internal view returns (address) {
    address possibleFactoryAddress;
    try IUniswapV2Pair(token).factory() returns (address factory) {
      possibleFactoryAddress = factory;
    } catch {
      revert("NOT_LP_TOKEN");
    }
    require(possibleFactoryAddress != address(0) && _isValidLpToken(token, possibleFactoryAddress), "NOT_LP_TOKEN.");
    return possibleFactoryAddress;
  }

  function _isValidLpToken(address token, address factory) private view returns (bool) {
    IUniswapV2Pair pair = IUniswapV2Pair(token);
    address factoryPair = IUniswapV2Factory(factory).getPair(pair.token0(), pair.token1());
    return factoryPair == token;
  }

  function _isValidVested(uint256 tgePercent, uint256 cyclePercent) internal pure returns (bool) {
    return tgePercent + cyclePercent <= 100;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;


import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract TokenLockDividendsAndReflections {

  bool public isReward;

  struct LockInfo {
    IERC20 token;
    uint256 amount;
    uint256 lockDate;
    uint256 unlockDate;
    string logoImage;
    bool isWithdrawn;
    bool isVesting;
  }

  LockInfo public lockInfo;

  address public owner;
  address public lockFactory;

  modifier onlyOwner() {
    require(msg.sender == owner, "ONLY_OWNER");
    _;
  }
  modifier onlyRewardLock() {
    require(isReward == true, "ONLY_REWARDLOCK");
    _;
  }
  modifier onlyOwnerOrFactory() {
    require(msg.sender == owner || msg.sender == lockFactory, "ONLY_OWNER_OR_FACTORY");
    _;
  }

  event LogExtendLockTime(uint256 oldUnlockTime, uint256 newUnlockTime);
  event LogWithdraw(address to, uint256 lockedAmount);
  event LogWithdrawReflections(address to, uint256 amount);
  event LogWithdrawDividends(address to, uint256 dividends);
  event LogWithdrawNative(address to, uint256 dividends);
  event LogReceive(address from, uint256 value);

  constructor(
    address _owner,
    uint256 _unlockDate,
    uint256 _amount,
    address _token,
    string memory _logoImage,
    bool _isReward
  ) {
    require(_owner != address(0), "ADDRESS_ZERO");
    owner = _owner;
    lockInfo.lockDate = block.timestamp;
    lockInfo.unlockDate = _unlockDate;
    lockInfo.amount = _amount;
    lockInfo.token = IERC20(_token);
    lockInfo.logoImage = _logoImage;
    lockInfo.isVesting = false;
    isReward = _isReward;
    lockFactory = msg.sender;
  }

  function extendLockTime(uint256 newUnlockDate) external onlyOwner {
    require(lockInfo.isWithdrawn == false, "ALREADY_UNLOCKED");
    uint256 oldDate = lockInfo.unlockDate;

    require(newUnlockDate >= lockInfo.unlockDate && newUnlockDate > block.timestamp, "BAD_TIME_INPUT");
    lockInfo.unlockDate = newUnlockDate;

    emit LogExtendLockTime(oldDate, newUnlockDate);
  }

  function updateLogo(string memory newLogoImage) external onlyOwner {
    require(lockInfo.isWithdrawn == false, "ALREADY_UNLOCKED");
    lockInfo.logoImage = newLogoImage;
  }

  function unlock() external onlyOwner {
    require(block.timestamp >= lockInfo.unlockDate, "WRONG_TIME");
    require(lockInfo.isWithdrawn == false, "ALREADY_UNLOCKED");

    lockInfo.isWithdrawn = true;

    lockInfo.token.transfer(owner, lockInfo.amount);

    emit LogWithdraw(owner, lockInfo.amount);
  }

  function withdrawReflections() external onlyRewardLock onlyOwner {
    if (lockInfo.isWithdrawn) {
      uint256 reflections = lockInfo.token.balanceOf(address(this));
      if (reflections > 0) {
        lockInfo.token.transfer(owner, reflections);
      }
      emit LogWithdrawReflections(owner, reflections);
    } else {
      uint256 contractBalanceWReflections = lockInfo.token.balanceOf(address(this));
      uint256 reflections = contractBalanceWReflections - lockInfo.amount;
      if (reflections > 0) {
        lockInfo.token.transfer(owner, reflections);
      }
      emit LogWithdrawReflections(owner, reflections);
    }
  }

  function withdrawDividends(address _token) external onlyRewardLock onlyOwner {
    require(_token != address(lockInfo.token), "CANT_WITHDRAW_LOCKED_ASSETS");
    uint256 dividends = IERC20(_token).balanceOf(address(this));
    if (dividends > 0) {
      IERC20(_token).transfer(owner, dividends);
    }
    emit LogWithdrawDividends(owner, dividends);
  }

  function withdrawBNB() external onlyOwner {
    uint256 amount = address(this).balance;
    payable(owner).transfer(amount);
    emit LogWithdrawNative(owner, amount);
  }

  /**
   * for receive dividend
   */
  receive() external payable {
    emit LogReceive(msg.sender, msg.value);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/interfaces/IERC20.sol";


contract VestingLockDividendsAndReflections{

  bool public isReward;

  struct LockInfo {
    IERC20 token;
    uint256 amount;
    uint256 lockDate;
    uint256 unlockDate;
    string logoImage;
    bool isWithdrawn;
    bool isVesting;
  }

  struct VestingInfo {
    uint256 amount;
    uint256 unlockDate;
    bool isWithdrawn;
  }

  LockInfo public lockInfo;
  VestingInfo[] public vestingInfo;

  address public owner;
  address public lockFactory;

  modifier onlyOwner() {
    require(msg.sender == owner, "ONLY_OWNER");
    _;
  }
  modifier onlyRewardLock() {
    require(isReward == true, "ONLY_REWARDLOCK");
    _;
  }
  modifier onlyOwnerOrFactory() {
    require(msg.sender == owner || msg.sender == lockFactory, "ONLY_OWNER_OR_FACTORY");
    _;
  }
  event LogWithdraw(address to, uint256 lockedAmount);
  event LogWithdrawReflections(address to, uint256 amount);
  event LogWithdrawDividends(address to, uint256 dividends);
  event LogWithdrawNative(address to, uint256 dividends);
  event LogReceive(address from, uint256 value);

  constructor(
    address _owner,
    uint256 _unlockDate,
    uint256 _amount,
    address _token,
    uint256 _tgePercent,
    uint256 _cycle,
    uint256 _cyclePercent,
    string memory _logoImage,
    bool _isReward
  ) {
    require(_owner != address(0), "ADDRESS_ZERO");
    require(_isValidVested(_tgePercent, _cyclePercent), "NOT_VALID_VESTED");
    owner = _owner;
    lockInfo.lockDate = block.timestamp;
    lockInfo.unlockDate = _unlockDate;
    lockInfo.amount = _amount;
    lockInfo.token = IERC20(_token);
    lockInfo.logoImage = _logoImage;
    lockInfo.isVesting = true;
    lockFactory = msg.sender;
    isReward = _isReward;

    _initializeVested(_amount, _unlockDate, _tgePercent, _cycle, _cyclePercent);
  }

  function _isValidVested(uint256 tgePercent, uint256 cyclePercent) internal pure returns (bool) {
    return tgePercent + cyclePercent <= 100;
  }

  function _initializeVested(
    uint256 amount,
    uint256 unlockDate,
    uint256 tgePercent,
    uint256 cycle,
    uint256 cyclePercent
  ) internal {
    uint256 tgeValue = (amount * tgePercent) / 100;
    uint256 cycleValue = (amount * cyclePercent) / 100;
    uint256 tempAmount = amount - tgeValue;
    uint256 tempUnlock = unlockDate;

    VestingInfo memory vestInfo;

    vestInfo.amount = tgeValue;
    vestInfo.unlockDate = unlockDate;
    vestInfo.isWithdrawn = false;
    vestingInfo.push(vestInfo);

    while (tempAmount > 0) {
      uint256 vestCycleValue = tempAmount > cycleValue ? cycleValue : tempAmount;
      tempUnlock = tempUnlock + cycle;
      vestInfo.amount = vestCycleValue;
      vestInfo.unlockDate = tempUnlock;
      vestInfo.isWithdrawn = false;
      vestingInfo.push(vestInfo);
      tempAmount = tempAmount - vestCycleValue;
    }
  }

  function updateLogo(string memory newLogoImage) external onlyOwner {
    require(lockInfo.isWithdrawn == false, "ALREADY_UNLOCKED");
    lockInfo.logoImage = newLogoImage;
  }

  function unlock() external onlyOwner {
    require(block.timestamp >= lockInfo.unlockDate, "WRONG_TIME");
    require(lockInfo.isWithdrawn == false, "ALREADY_UNLOCKED");

    uint256 unlocked = 0;
    for (uint256 i = 0; i < vestingInfo.length; i++) {
      if (!vestingInfo[i].isWithdrawn && vestingInfo[i].unlockDate < block.timestamp) {
        unlocked = unlocked + vestingInfo[i].amount;
        vestingInfo[i].isWithdrawn = true;
      }
    }
    if (unlocked == lockInfo.amount) {
      lockInfo.isWithdrawn = true;
    }

    lockInfo.token.transfer(owner, unlocked);

    emit LogWithdraw(owner, unlocked);
  }

  function getLockedValue() public view returns (uint256) {
    uint256 locked = 0;
    for (uint256 i = 0; i < vestingInfo.length; i++) {
      if (!vestingInfo[i].isWithdrawn) {
        locked = locked + vestingInfo[i].amount;
      }
    }
    return locked;
  }

  function withdrawReflections() external onlyRewardLock onlyOwner {
    if (lockInfo.isWithdrawn) {
      uint256 reflections = lockInfo.token.balanceOf(address(this));
      if (reflections > 0) {
        lockInfo.token.transfer(owner, reflections);
      }
      emit LogWithdrawReflections(owner, reflections);
    } else {
      uint256 contractBalanceWReflections = lockInfo.token.balanceOf(address(this));
      uint256 lockedValue = getLockedValue();
      uint256 reflections = contractBalanceWReflections - lockedValue;
      if (reflections > 0) {
        lockInfo.token.transfer(owner, reflections);
      }
      emit LogWithdrawReflections(owner, reflections);
    }
  }

  function withdrawDividends(address _token) external onlyRewardLock onlyOwner {
    require(_token != address(lockInfo.token), "CANT_WITHDRAW_LOCKED_ASSETS");
    uint256 dividends = IERC20(_token).balanceOf(address(this));
    if (dividends > 0) {
      IERC20(_token).transfer(owner, dividends);
    }
    emit LogWithdrawDividends(owner, dividends);
  }

  function withdrawBNB() external onlyOwner {
    uint256 amount = address(this).balance;
    payable(owner).transfer(amount);
    emit LogWithdrawNative(owner, amount);
  }

  function getVestingInfo() external view returns(VestingInfo[] memory) {
    return vestingInfo;
  }

  /**
   * for receive dividend
   */
  receive() external payable {
    emit LogReceive(msg.sender, msg.value);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;


import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "./ArborSwapDeps/IUniswapV2Pair.sol";
import "./ArborSwapDeps/IUniswapV2Factory.sol";

contract LiquidityLock {

  struct LockInfo {
    IUniswapV2Pair token;
    uint256 amount;
    uint256 lockDate;
    uint256 unlockDate;
    string logoImage;
    bool isWithdrawn;
  }

  LockInfo public lockInfo;

  address public owner;
  address public lockFactory;

  modifier onlyOwner() {
    require(msg.sender == owner, "ONLY_OWNER");
    _;
  }
  modifier onlyOwnerOrFactory() {
    require(msg.sender == owner || msg.sender == lockFactory, "ONLY_OWNER_OR_FACTORY");
    _;
  }

  event LogExtendLockTime(uint256 oldUnlockTime, uint256 newUnlockTime);
  event LogWithdraw(address to, uint256 lockedAmount);
  event LogWithdrawNative(address to, uint256 dividends);
  event LogReceive(address from, uint256 value);

  constructor(
    address _owner,
    uint256 _unlockDate,
    uint256 _amount,
    address _token,
    string memory _logoImage
  ) {
    require(_owner != address(0), "ADDRESS_ZERO");
    owner = _owner;
    lockInfo.lockDate = block.timestamp;
    lockInfo.unlockDate = _unlockDate;
    lockInfo.amount = _amount;
    lockInfo.token = IUniswapV2Pair(_token);
    lockInfo.logoImage = _logoImage;
    lockFactory = msg.sender;
  }

  function extendLockTime(uint256 newUnlockDate) external onlyOwner {
    require(lockInfo.isWithdrawn == false, "ALREADY_UNLOCKED");
    uint256 oldDate = lockInfo.unlockDate;

    require(newUnlockDate >= lockInfo.unlockDate && newUnlockDate > block.timestamp, "BAD_TIME_INPUT");
    lockInfo.unlockDate = newUnlockDate;

    emit LogExtendLockTime(oldDate, newUnlockDate);
  }

  function updateLogo(string memory newLogoImage) external onlyOwner {
    require(lockInfo.isWithdrawn == false, "ALREADY_UNLOCKED");
    lockInfo.logoImage = newLogoImage;
  }

  function unlock() external onlyOwner {
    require(block.timestamp >= lockInfo.unlockDate, "WRONG_TIME");
    require(lockInfo.isWithdrawn == false, "ALREADY_UNLOCKED");

    lockInfo.isWithdrawn = true;

    lockInfo.token.transfer(owner, lockInfo.amount);

    emit LogWithdraw(owner, lockInfo.amount);
  }

  function withdrawBNB() external onlyOwner {
    uint256 amount = address(this).balance;
    payable(owner).transfer(amount);
    emit LogWithdrawNative(owner, amount);
  }

  /**
   * for receive dividend
   */
  receive() external payable {
    emit LogReceive(msg.sender, msg.value);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
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
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";

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