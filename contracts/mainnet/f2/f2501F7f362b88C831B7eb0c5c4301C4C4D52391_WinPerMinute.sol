// SPDX-License-Identifier: PROPRIETARY - Lameni

pragma solidity ^0.8.11;

import "./ContractData.sol";

contract WinPerMinute is ContractData {
  constructor() {
    address ref = owner();
    accounts[ref].unlockedLevel = 20;
    accounts[ref].registered = true;
    accounts[mainNode].up = ref;
    accounts[mainNode].unlockedLevel = 20;
    accounts[mainNode].registered = true;
    accountsRefs[ref].push(mainNode);
    emit ReferralRegistration(mainNode, ref);

    networkSize += 1;
  }

  // --------------------- PUBLIC METHODS ---------------------------
  receive() external payable {
    makeDeposit();
  }

  function leaderRegisterAcount(address target, address ref) external payable isAuthorized(1) {
    address sender = target;
    require(sender != ref && accounts[sender].up == address(0) && accounts[ref].registered == true, "Invalid Referral");

    accounts[sender].up = ref;
    accounts[sender].registered = true;
    accountsRefs[ref].push(sender);
    emit ReferralRegistration(sender, ref);
    accountsFlow[ref].push(buildOperation(1, accountsRefs[ref].length));

    networkSize += 1;
    if (msg.value > 0) {
      _registerDeposit(sender, msg.value);
      _payCumulativeNetworkFee();
    }
  }

  function registerAccount(address ref) external payable {
    address sender = msg.sender;
    require(sender != ref && accounts[sender].up == address(0) && accounts[ref].registered == true, "Invalid Referral");

    accounts[sender].up = ref;
    accounts[sender].registered = true;
    accountsRefs[ref].push(sender);
    emit ReferralRegistration(sender, ref);
    accountsFlow[ref].push(buildOperation(1, accountsRefs[ref].length));

    networkSize += 1;
    _registerDeposit(sender, msg.value);
    _payCumulativeNetworkFee();
  }

  function addShareWallet(address toBeShared) external {
    address target = msg.sender;
    require(accounts[target].registered == true, "Account not registered on platform");
    require(toBeShared != address(0) && toBeShared != target, "Invalid account to be shared");

    address[] memory shared = accountsShared[target];
    for(uint i = 0; i < shared.length; i++ ) {
      if (shared[i] == toBeShared) revert("Already been shared with this wallet");
    }

    accountsShared[target].push(toBeShared);
    accountsInShare[toBeShared].push(target);
  }

  function makeDeposit() public payable {
    _registerDeposit(msg.sender, msg.value);
    _payCumulativeNetworkFee();
  }

  function withdrawAndDeposit() public payable {
    _withdraw(0);
    _registerDeposit(msg.sender, msg.value);
    _payCumulativeNetworkFee();
  }

  function directBonusDeposit(address receiver) public payable isAuthorized(1) {
    uint amount = msg.value;
    require(amount > 0, "Invalid amount");
    require(accounts[receiver].registered == true, "Invalid receiver");

    address directBonusReceiver = receiver;
    accounts[directBonusReceiver].directBonusAmount += amount; // DIRECT EXTERNAL BONUS
    accounts[directBonusReceiver].directBonusAmountTotal += amount;

    emit DirectBonus(directBonusReceiver, msg.sender, amount);

    networkDeposits += amount;
    _payNetworkFee(amount, true);
    _payCumulativeNetworkFee();
  }

  function makeDonation(string memory message) public payable {
    uint amount = msg.value;
    address sender = msg.sender;
    require(amount > 0, "Invalid amount");

    emit NewDonationDeposit(sender, amount, message);
    accountsFlow[sender].push(buildOperation(2, amount));

    networkDeposits += amount;
    _payNetworkFee(amount, true);
    _payCumulativeNetworkFee();
  }

  function withdraw() external {
    _withdraw(0);
    _payCumulativeNetworkFee();
  }

  function withdrawPartial(uint amount) external {
    require(amount > 0, "Invalid amount");
    _withdraw(amount);
    _payCumulativeNetworkFee();
  }

  function _withdraw(uint amount) private {
    address sender = msg.sender;

    uint allowedWithdraw = accounts[sender].depositMin;
    uint receivedTotalAmount = accounts[sender].receivedTotalAmount;

    uint depositTime = accounts[sender].depositTime;
    uint receivedPassiveAmount = accounts[sender].receivedPassiveAmount;
    uint directBonusAmount = accounts[sender].directBonusAmount;
    uint levelBonusAmount = accounts[sender].levelBonusAmount;

    uint passive = calculatePassive(depositTime, allowedWithdraw, receivedTotalAmount, receivedPassiveAmount);

    uint remainingWithdraw = ((allowedWithdraw * maxPercentToWithdraw) / 100) - receivedTotalAmount; // MAX WITHDRAW
    require(remainingWithdraw > 0, "No remaining withdraws");

    if (amount > 0) {
      require(amount <= remainingWithdraw, "Amount exceed remaining amount to be withdrawn");
      remainingWithdraw = amount;
    }

    uint toWithdrawPassive = passive >= remainingWithdraw ? remainingWithdraw : passive;

    if (directBonusAmount > remainingWithdraw - toWithdrawPassive) directBonusAmount = remainingWithdraw - toWithdrawPassive;
    if (levelBonusAmount > remainingWithdraw - (toWithdrawPassive + directBonusAmount)) levelBonusAmount = remainingWithdraw - (toWithdrawPassive + directBonusAmount);
    
    uint totalToWithdraw = toWithdrawPassive + directBonusAmount + levelBonusAmount;

    if (directBonusAmount > 0) accounts[sender].directBonusAmount -= directBonusAmount;
    if (levelBonusAmount > 0) accounts[sender].levelBonusAmount -= levelBonusAmount;

    accounts[sender].receivedPassiveAmount += toWithdrawPassive;
    accounts[sender].receivedTotalAmount += totalToWithdraw;

    if (totalToWithdraw >= remainingWithdraw && (amount == 0 || amount == remainingWithdraw)) emit WithdrawLimitReached(sender, receivedTotalAmount + totalToWithdraw);

    uint feeAmount = _payNetworkFee(totalToWithdraw, false);
    networkWithdraw += totalToWithdraw + feeAmount;
    
    _distributeLevelBonus(sender, toWithdrawPassive);
    
    emit Withdraw(sender, totalToWithdraw);
    accountsFlow[sender].push(buildOperation(3, totalToWithdraw));
    
    _payWithdrawAmount(totalToWithdraw);
  }

  function _payWithdrawAmount(uint totalToWithdraw) private {
    address sender = msg.sender;
    uint shareCount = accountsShared[sender].length;
    if (shareCount == 0) {
      payable(sender).transfer(totalToWithdraw);
      return;
    }
    uint parcial = totalToWithdraw / (shareCount + 1);
    payable(sender).transfer(parcial);

    for(uint i = 0; i < shareCount; i++) {
      payable(accountsShared[sender][i]).transfer(parcial);
    }
  }

  // --------------------- PRIVATE METHODS ---------------------------
  function _distributeLevelBonus(address sender, uint amount) private {
    address up = accounts[sender].up;
    address contractOwner = owner();
    address contractMainNome = mainNode;
    uint minToGetBonus = minAmountToGetBonus;
    for(uint8 i = 0; i < _passiveBonusLevel.length; i++) {
      if(up == address(0)) break;

      uint currentUnlockedLevel = accounts[up].unlockedLevel;
      uint lockLevel = accounts[up].depositMin >= minToGetBonus ? 20 : 0;
      if (lockLevel < currentUnlockedLevel) currentUnlockedLevel = lockLevel;

      if (currentUnlockedLevel > i || up == contractOwner || up == contractMainNome) {
        uint256 bonus = (amount * _passiveBonusLevel[i]) / 1000;
        accounts[up].levelBonusAmount += bonus;
        accounts[up].levelBonusAmountTotal += bonus;

        emit LevelBonus(up, sender, bonus);
      }
      up = accounts[up].up;
    }
  }

  function _proccessRenewOrUpgrade(address sender, uint depositMin) private returns(uint) {
    uint receivedTotalAmount = accounts[sender].receivedTotalAmount;
    require(receivedTotalAmount >= (depositMin * maxPercentToWithdraw) / 100, "Pending earnings to be withdrawn");

    uint depositTime = accounts[sender].depositTime;
    uint receivedPassiveAmount = accounts[sender].receivedPassiveAmount;
    uint directBonusAmount = accounts[sender].directBonusAmount;
    uint levelBonusAmount = accounts[sender].levelBonusAmount;

    uint passive = calculatePassive(depositTime, depositMin, receivedTotalAmount, receivedPassiveAmount);
    require(passive + directBonusAmount + levelBonusAmount + receivedTotalAmount >= (depositMin * maxPercentToReceive) / 100, "Not reached maximum earning amount");

    if (passive >= depositMin) passive = depositMin;
    if (directBonusAmount > depositMin - passive) directBonusAmount = depositMin - passive;
    if (levelBonusAmount > depositMin - (passive + directBonusAmount)) levelBonusAmount = depositMin - (passive + directBonusAmount);
    
    if (directBonusAmount > 0) accounts[sender].directBonusAmount -= directBonusAmount;
    if (levelBonusAmount > 0) accounts[sender].levelBonusAmount -= levelBonusAmount;

    uint feeAmount = _payNetworkFee(depositMin, false);
    networkWithdraw += depositMin + feeAmount;

    _distributeLevelBonus(sender, passive);
    return depositMin;
  }

  function _registerDeposit(address sender, uint iniAmount) private {
    address mainOwner = owner();
    address referral = accounts[sender].up;
    uint depositMin = accounts[sender].depositMin;

    uint amount = iniAmount;
    uint depositCounter = accounts[sender].depositCounter;
    if (depositCounter > 0) {
      amount += _proccessRenewOrUpgrade(sender, depositMin);
    }

    require(referral != address(0) || sender == mainOwner, "Registration is required");
    require(amount >= minAllowedDeposit, "Min amount not reached");
    require(depositMin <= amount, "Deposit to low");

    // Check up ref to unlock levels
    if (depositMin < minAmountToLvlUp && amount >= minAmountToLvlUp) {
      // unlocks a level to direct referral
      uint currentUnlockedLevel = accounts[referral].unlockedLevel;
      if (currentUnlockedLevel < _passiveBonusLevel.length) {
        accounts[referral].unlockedLevel = currentUnlockedLevel + 1;
      }
    }
    
    accounts[sender].depositMin = amount;
    accounts[sender].depositTotal += amount;
    accounts[sender].depositCounter = depositCounter + 1;
    accounts[sender].depositTime = block.timestamp;
    accounts[sender].receivedTotalAmount = 0;
    accounts[sender].receivedPassiveAmount = 0;
    
    emit NewDeposit(sender, amount);
    if (iniAmount == amount) {
      accountsFlow[sender].push(buildOperation(4, amount));
    } else if (iniAmount == 0) {
      accountsFlow[sender].push(buildOperation(5, amount));
    } else {
      accountsFlow[sender].push(buildOperation(6, amount));
    }

    networkDeposits += amount;

    // Pays the direct bonus
    uint directBonusAmount = (amount * directBonus) / 1000; // DIRECT BONUS
    address directBonusReceiver = accounts[sender].up;
    if (directBonusReceiver == address(0)) directBonusReceiver = mainOwner;
    accounts[directBonusReceiver].directBonusAmount += directBonusAmount;
    accounts[directBonusReceiver].directBonusAmountTotal += directBonusAmount;

    emit DirectBonus(directBonusReceiver, sender, directBonusAmount);

    _payNetworkFee(amount, true);
  }

  uint cumulativeNetworkFee = 0;
  function _payNetworkFee(uint amount, bool registerWithdrawOperation) private returns(uint) {
    uint networkFee = (amount * networkFeePercent) / 1000;
    cumulativeNetworkFee += networkFee;
    if (registerWithdrawOperation) networkWithdraw += networkFee;
    return networkFee;
  }

  function _payCumulativeNetworkFee() private {
    uint networkFee = cumulativeNetworkFee;
    if (networkFee <= 0) return;
    payable(networkReceiverA).transfer((networkFee * 375) / 1000 );
    payable(networkReceiverB).transfer((networkFee * 375) / 1000 );
    payable(networkReceiverC).transfer((networkFee * 250) / 1000 );
    cumulativeNetworkFee = 0;
  }

  function collectMainFee() external {
    address sender = owner();
    {
      uint directBonusAmount = accounts[sender].directBonusAmount;
      uint levelBonusAmount = accounts[sender].levelBonusAmount;

      uint totalToWithdraw = directBonusAmount + levelBonusAmount;

      if (directBonusAmount > 0) accounts[sender].directBonusAmount = 0;
      if (levelBonusAmount > 0) accounts[sender].levelBonusAmount = 0;

      accounts[sender].receivedTotalAmount += totalToWithdraw;
      networkWithdraw += totalToWithdraw;

      payable(networkReceiverA).transfer((totalToWithdraw * 375) / 1000 );
      payable(networkReceiverB).transfer((totalToWithdraw * 375) / 1000 );
      payable(networkReceiverC).transfer((totalToWithdraw * 250) / 1000 );
    }
    sender = mainNode;
    {
      uint directBonusAmount = accounts[sender].directBonusAmount;
      uint levelBonusAmount = accounts[sender].levelBonusAmount;

      uint totalToWithdraw = directBonusAmount + levelBonusAmount;

      accounts[sender].receivedTotalAmount += totalToWithdraw;
      networkWithdraw += totalToWithdraw;

      if (directBonusAmount > 0) accounts[sender].directBonusAmount = 0;
      if (levelBonusAmount > 0) accounts[sender].levelBonusAmount = 0;

      payable(networkReceiverA).transfer((totalToWithdraw * 500) / 1000 );
      payable(networkReceiverB).transfer((totalToWithdraw * 500) / 1000 );
    }
  }
}

// SPDX-License-Identifier: PROPRIETARY - Lameni

pragma solidity ^0.8.11;

import "./Authorized.sol";

contract ContractData is Authorized {

  string public constant name = "Win Per Minute Now";
  string public constant url = "www.winperminutenow.io";

  struct Account {
    address up;

    uint receivedPassiveAmount;
    uint receivedTotalAmount;

    uint directBonusAmount;
    uint directBonusAmountTotal;
    uint levelBonusAmount;
    uint levelBonusAmountTotal;
    uint unlockedLevel;

    uint depositMin;
    uint depositTotal;
    uint depositCounter;
    uint depositTime;
    bool registered;
  }

  struct MoneyFlow {
    uint passive;
    uint direct;
    uint bonus;
  }

  struct NetworkCheck {
    uint count;
    uint deposits;
    uint depositTotal;
    uint depositCounter;
  }

  mapping(address => Account) public accounts;
  mapping(address => address[]) public accountsRefs;
  mapping(address => uint[]) public accountsFlow;

  mapping(address => address[]) public accountsShared;
  mapping(address => address[]) public accountsInShare;

  uint16[] _passiveBonusLevel = new uint16[](20);

  uint public minAllowedDeposit = 0.03 ether; // editable

  uint public minAmountToLvlUp = 0.15 ether;  // editable
  uint public minAmountToGetBonus = 0.15 ether;  // editable

  uint public dailyRentability = 15;

  uint public directBonus = 70;
  uint public networkFeePercent = 20;
  
  uint public maxPercentToWithdraw = 200;
  uint public maxPercentToReceive = 300;

  uint public networkSize = 0;
  uint public networkDeposits = 0;
  uint public networkWithdraw = 0;

  address networkReceiverA;
  address networkReceiverB;
  address networkReceiverC;

  address mainNode = 0xb83816d0a1E72f81991193dDb7d8d083cf54e6d5;

  constructor() {
    _passiveBonusLevel[0]  = 150;
    _passiveBonusLevel[1]  = 100;
    _passiveBonusLevel[2]  = 100;
    _passiveBonusLevel[3]  = 100;
    _passiveBonusLevel[4]  = 100;
    _passiveBonusLevel[5]  = 100;
    _passiveBonusLevel[6]  = 70;
    _passiveBonusLevel[7]  = 70;
    _passiveBonusLevel[8]  = 70;
    _passiveBonusLevel[9]  = 70;
    _passiveBonusLevel[10] = 70;
    _passiveBonusLevel[11] = 40;
    _passiveBonusLevel[12] = 40;
    _passiveBonusLevel[13] = 40;
    _passiveBonusLevel[14] = 40;
    _passiveBonusLevel[15] = 40;
    _passiveBonusLevel[16] = 30;
    _passiveBonusLevel[17] = 30;
    _passiveBonusLevel[18] = 30;
    _passiveBonusLevel[19] = 30;
  }

  event WithdrawLimitReached(address indexed addr, uint256 amount);
  event Withdraw(address indexed addr, uint256 amount);
  event NewDeposit(address indexed addr, uint256 amount);
  event DirectBonus(address indexed addr, address indexed from, uint256 amount);
  event LevelBonus(address indexed addr, address indexed from, uint256 amount);
  event ReferralRegistration(address indexed addr, address indexed referral);
  event NewDonationDeposit(address indexed addr, uint256 amount, string message);


  function setMinAllowedDeposit(uint minValue) external isAuthorized(1) { minAllowedDeposit = minValue; }
  function setMinAmountToLvlUp(uint minValue) external isAuthorized(1) { minAmountToLvlUp = minValue; }
  function setMinAmountToGetBonus(uint minValue) external isAuthorized(1) { minAmountToGetBonus = minValue; }
  function setNetworkReceiverA(address receiver) external isAuthorized(0) { networkReceiverA = receiver; }
  function setNetworkReceiverB(address receiver) external isAuthorized(0) { networkReceiverB = receiver; }
  function setNetworkReceiverC(address receiver) external isAuthorized(0) { networkReceiverC = receiver; }
  
  function buildOperation(uint8 opType, uint value) view internal returns(uint res) {
    assembly {
      let entry := mload(0x40)
      mstore(entry, add(shl(200, opType), add(add(shl(160, timestamp()), shl(120, number())), value)))
      res := mload(entry)
    }
  }

  function getShares(address target) view external returns(address[] memory shared, address[] memory inShare) {
    shared = accountsShared[target];
    inShare = accountsInShare[target];
  }

  function getFlow(address target, uint limit, bool asc) view external returns(uint[] memory flow) {
    uint[] memory list = accountsFlow[target];
    if (limit == 0) limit = list.length;
    if (limit > list.length) limit = list.length;
    flow = new uint[](limit);
    if (asc) {
      for(uint i = 0; i < limit; i++) flow[i] = list[i];
    } else {
      for(uint i = 0; i < limit; i++) flow[i] = list[(limit - 1) - i];
    }
  }
  function getMaxLevel(address sender) view public returns(uint) {
    uint currentUnlockedLevel = accounts[sender].unlockedLevel;
    uint lockLevel = accounts[sender].depositMin >= minAmountToGetBonus ? 20 : 0;
    if (lockLevel < currentUnlockedLevel) return lockLevel;
    return currentUnlockedLevel;
  }

  function calculatePassive(uint depositTime, uint depositMin, uint receivedTotalAmount, uint receivedPassiveAmount) view public returns(uint){
    if (depositTime == 0 || depositMin == 0) return 0;
    uint timeFrame = 1 days;
    uint passive = (( (depositMin * dailyRentability) / 1000 ) * (block.timestamp - depositTime) / timeFrame ) - receivedPassiveAmount;
    uint remainingAllowed = ((depositMin * maxPercentToReceive) / 100) - receivedTotalAmount; // MAX TO RECEIVE
    return passive >= remainingAllowed ? remainingAllowed : passive;
  }
  
  function getAccountNetwork(address sender, uint maxLevel) view external returns(NetworkCheck[] memory) {
    maxLevel = maxLevel > _passiveBonusLevel.length || maxLevel == 0 ? _passiveBonusLevel.length : maxLevel;
    NetworkCheck[] memory network = new NetworkCheck[](maxLevel);
    for(uint i = 0; i < accountsRefs[sender].length; i++) {
      _getAccountNetworkInner(accountsRefs[sender][i], 0, maxLevel, network);
    }
    return network;
  }

  function _getAccountNetworkInner(address sender, uint level, uint maxLevel, NetworkCheck[] memory network) view internal {
    network[level].count += 1;
    network[level].deposits += accounts[sender].depositMin;
    network[level].depositTotal += accounts[sender].depositTotal;
    network[level].depositCounter += accounts[sender].depositCounter;
    if (level + 1 >= maxLevel) return;
    for(uint i = 0; i < accountsRefs[sender].length; i++) {
      _getAccountNetworkInner(accountsRefs[sender][i], level + 1, maxLevel, network);
    }
  }

  function getAccountEarnings(address sender) view external returns(Account memory account, MoneyFlow memory total, MoneyFlow memory toWithdraw, MoneyFlow memory toMaxEarning, MoneyFlow memory toReceiveOverMax, uint level, uint directs, uint time) {
    account = accounts[sender];

    address localSender = sender;
    uint depositMin = accounts[localSender].depositMin;
    uint directBonusAmount = accounts[localSender].directBonusAmount;
    uint levelBonusAmount = accounts[localSender].levelBonusAmount;
    uint receivedTotalAmount = accounts[localSender].receivedTotalAmount;

    uint passive = calculatePassive(accounts[localSender].depositTime, depositMin, receivedTotalAmount, accounts[localSender].receivedPassiveAmount);
    total = MoneyFlow(passive, directBonusAmount, levelBonusAmount);
    

    if (localSender == owner() || localSender == mainNode) depositMin = type(uint).max / 10000;

    uint remainingWithdraw = ((depositMin * maxPercentToWithdraw) / 100) - receivedTotalAmount; // MAX WITHDRAW
    uint toRegisterPassive = passive >= remainingWithdraw ? remainingWithdraw : passive;

    remainingWithdraw = remainingWithdraw - toRegisterPassive;
    uint toRegisterDirect = directBonusAmount >= remainingWithdraw ? remainingWithdraw : directBonusAmount;

    remainingWithdraw = remainingWithdraw - toRegisterDirect;
    uint toRegisterBonus = levelBonusAmount >= remainingWithdraw ? remainingWithdraw : levelBonusAmount;

    passive -= toRegisterPassive;
    directBonusAmount -= toRegisterDirect;
    levelBonusAmount -= toRegisterBonus;
    
    toWithdraw = MoneyFlow(toRegisterPassive, toRegisterDirect, toRegisterBonus);

    remainingWithdraw = ((depositMin * maxPercentToReceive) / 100) - (receivedTotalAmount + toRegisterPassive + toRegisterDirect + toRegisterBonus); // MAX TO RECEIVE
    toRegisterPassive = passive >= remainingWithdraw ? remainingWithdraw : passive;
    remainingWithdraw = remainingWithdraw - toRegisterPassive;
    toRegisterDirect = directBonusAmount >= remainingWithdraw ? remainingWithdraw : directBonusAmount;
    remainingWithdraw = remainingWithdraw - toRegisterDirect;
    toRegisterBonus = levelBonusAmount >= remainingWithdraw ? remainingWithdraw : levelBonusAmount;

    passive -= toRegisterPassive;
    directBonusAmount -= toRegisterDirect;
    levelBonusAmount -= toRegisterBonus;

    toMaxEarning = MoneyFlow(toRegisterPassive, toRegisterDirect, toRegisterBonus);
    toReceiveOverMax = MoneyFlow(passive, directBonusAmount, levelBonusAmount);

    level = getMaxLevel(localSender);
    directs = accountsRefs[localSender].length;
    time = block.timestamp;
  }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Authorized is Ownable {
  mapping(uint8 => mapping(address => bool)) private permissions;

  constructor() {
    permissions[0][_msgSender()] = true; // admin
    permissions[1][_msgSender()] = true; // controller
  }

  modifier isAuthorized(uint8 index) { require(permissions[index][_msgSender()] == true, "Account does not have permission"); _; }
  function safeApprove(address token, address spender, uint256 amount) external isAuthorized(0) { IERC20(token).approve(spender, amount); }
  function safeTransfer(address token, address receiver, uint256 amount) external isAuthorized(0) { IERC20(token).transfer(receiver, amount); }
  function grantPermission(address operator, uint8 typed) external isAuthorized(0) { permissions[typed][operator] = true; }
  function revokePermission(address operator, uint8 typed) external isAuthorized(0) { permissions[typed][operator] = false; }
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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