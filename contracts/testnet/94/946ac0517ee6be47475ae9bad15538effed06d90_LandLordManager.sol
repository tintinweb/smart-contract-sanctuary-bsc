// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "../libs/fota/Auth.sol";
import "../libs/zeppelin/token/BEP20/IBEP20.sol";
import "../interfaces/IFOTAGame.sol";
import "../interfaces/IFOTAToken.sol";
import "../interfaces/IMarketPlace.sol";
import "../interfaces/IFOTAPricer.sol";
import "../interfaces/ILandNFT.sol";
import "../interfaces/ICitizen.sol";
import "../libs/fota/Math.sol";
import "../libs/fota/StringUtil.sol";
import "../libs/fota/ArrayUtil.sol";

contract LandLordManager is Auth, PausableUpgradeable {
  using Math for uint;
  using ArrayUtil for uint[];
  struct Land {
    address landLord;
    uint landLordPercentage;
    uint pendingReward;
    uint totalRewarded;
    uint foundingPrice;
    address[] shareHolders;
    mapping (address => uint) shareHolderPercentage;
  }
  struct ShareOrder {
    uint mission;
    address maker;
    address taker;
    uint sharePercentage; // decimal 3
    uint price;
    bool active;
  }
  struct LandOrder {
    uint mission;
    uint nftId;
    address maker;
    address taker;
    uint price;
    bool active;
  }
  enum OrderType {
    land,
    shareHolder
  }
  IMarketPlace.PaymentType public paymentType;
  IFOTAGame public gameProxyContract;
  IFOTAToken public fotaToken;
  IFOTAPricer public fotaPricer;
  IBEP20 public busdToken;
  IBEP20 public usdtToken;
  ILandNFT public landNFT;
  ICitizen public citizen;
  mapping (uint => Land) public lands;
  mapping (uint => ShareOrder) public shareOrders;
  mapping (uint => LandOrder) public landOrders;
  mapping (address => uint[]) public ownerActiveShareOrders; // address -> orderId
  mapping (address => mapping (uint => bool)) public ownerActiveLandOrders; // address => mission
  uint private totalOrder;
  address public treasuryAddress;
  address public fundAdmin;
  uint public referralShare; // decimal 3
  uint public creativeShare; // decimal 3
  uint public treasuryShare; // decimal 3
  uint constant FULL_PERCENT_DECIMAL3 = 100000;
  uint public landMinPrice; // decimal 3
  uint public shareMinPrice; // decimal 3

  event Claimed(address indexed landLord, uint amount, uint landLordAmount, uint mission, uint percentage);
  event OrderCreated(uint _mission, OrderType orderType, address indexed maker, uint orderId, uint sharePercentage, uint price);
  event OrderTaken(address indexed taker, uint orderId, address maker, IMarketPlace.PaymentType paymentType, IMarketPlace.PaymentCurrency paymentCurrency);
  event OrderCanceled(uint orderId);
  event FoundingPriceUpdated(uint mission, uint price);
  event ShareHolderChanged(uint mission, address oldHolder, address newHolder);
  event PaymentTypeChanged(IMarketPlace.PaymentType newMethod);
  event LandLordGranted(uint mission, address landLord, uint price, IMarketPlace.PaymentType paymentType, IMarketPlace.PaymentCurrency paymentCurrency);
  event ReferralSent(address indexed inviter, address indexed invitee, uint referralSharingAmount, IMarketPlace.PaymentCurrency paymentCurrency);
  event MinPriceUpdated(uint landMinPrice, uint shareMinPrice, uint timestamp);
  event ShareHolderClaimed(address indexed landLord, uint mission, address indexed shareHolder, uint shareAmount, uint landLordAmount, uint percentage);
  event GiveReward(uint indexed mission, uint amount);

  modifier onlyLandLord(uint _mission) {
    require(_isLandLord(_mission, msg.sender) && landNFT.ownerOf(_mission) == msg.sender, "Only land lord");
    _;
  }

  function initialize(
    address _mainAdmin,
    address _fotaToken,
    address _fotaPricer,
    address _landNFT,
    address _treasuryAddress,
    address _gameProxy,
    address _citizen
  ) public initializer {
    super.initialize(_mainAdmin);
    busdToken = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    usdtToken = IBEP20(0x55d398326f99059fF775485246999027B3197955);
    fotaToken = IFOTAToken(_fotaToken);
    fotaPricer = IFOTAPricer(_fotaPricer);
    landNFT = ILandNFT(_landNFT);
    fundAdmin = _mainAdmin;
    treasuryAddress = _treasuryAddress;
    gameProxyContract = IFOTAGame(_gameProxy);
    citizen = ICitizen(_citizen);
    referralShare = 2000;
    creativeShare = 3000;
    treasuryShare = 5000;
  }

  function giveReward(uint _mission, uint _amount) external {
    _takeFundFOTA(_amount, address(this));
    lands[_mission].pendingReward += _amount;
    emit GiveReward(_mission, lands[_mission].pendingReward);
  }

  function claim(uint _mission) external onlyLandLord(_mission) whenNotPaused {
    uint pendingReward = lands[_mission].pendingReward;
    if (pendingReward > 0) {
      lands[_mission].pendingReward = 0;
      lands[_mission].totalRewarded += pendingReward;
      uint landLordPercentage = lands[_mission].landLordPercentage;
      uint landLordAmount = pendingReward * landLordPercentage / FULL_PERCENT_DECIMAL3;
      fotaToken.transfer(msg.sender, landLordAmount);
      for(uint i = 0; i < lands[_mission].shareHolders.length; i++) {
        address shareHolder = lands[_mission].shareHolders[i];
        uint percentage = lands[_mission].shareHolderPercentage[shareHolder];
        uint shareAmount = pendingReward * percentage / FULL_PERCENT_DECIMAL3;
        fotaToken.transfer(shareHolder, shareAmount);
        emit ShareHolderClaimed(msg.sender, _mission, shareHolder, shareAmount, landLordAmount, percentage);
      }
      emit Claimed(msg.sender, pendingReward, landLordAmount, _mission, landLordPercentage);
    }
  }

  function makeLandOrder(uint _mission, uint _price) external onlyLandLord(_mission) {
    require(landNFT.isApprovedForAll(msg.sender, address(this)) || landNFT.getApproved(_mission) == address(this), "Please call approve first");
    require(!ownerActiveLandOrders[msg.sender][_mission], 'This land is selling');
    require(_price >= landMinPrice, "LandLordManager: price invalid");
    landOrders[totalOrder] = LandOrder(_mission, _mission, msg.sender, address(0), _price, true);
    ownerActiveLandOrders[msg.sender][_mission] = true;
    landNFT.transferFrom(msg.sender, address(this), _mission);
    emit OrderCreated(_mission, OrderType.land, msg.sender, totalOrder, 0, _price);
    totalOrder += 1;
  }

  function makeShareOrder(uint _mission, uint _sharePercent, uint _price) external {
    _validateMaker(_mission, _sharePercent);
    require(_price >= shareMinPrice, "LandLordManager: price invalid");
    shareOrders[totalOrder] = ShareOrder(_mission, msg.sender, address(0), _sharePercent, _price, true);
    emit OrderCreated(_mission, OrderType.shareHolder, msg.sender, totalOrder, _sharePercent, _price);
    ownerActiveShareOrders[msg.sender].push(totalOrder);
    totalOrder += 1;
  }

  function cancelOrder(uint _id) external {
    ShareOrder storage shareOrder = shareOrders[_id];
    if (shareOrder.active) {
      require(shareOrder.maker == msg.sender || _isMainAdmin(), "401");
      shareOrder.active = false;
      _removeOwnerActiveShareOrders(shareOrder.maker, _id);
    } else {
      LandOrder storage landOrder = landOrders[_id];
      require(landOrder.maker == msg.sender || _isMainAdmin(), "401");
      require(landOrder.active, "Order invalid");
      landOrder.active = false;
      delete ownerActiveLandOrders[landOrder.maker][landOrder.mission];
      landNFT.transferFrom(address(this), landOrder.maker, landOrder.nftId);
    }
    emit OrderCanceled(_id);
  }

  function takeLandOrder(uint _id, IMarketPlace.PaymentCurrency _paymentCurrency) external whenNotPaused {
    _validatePaymentMethod(_paymentCurrency);
    LandOrder storage order = landOrders[_id];
    require(landNFT.isApprovedForAll(order.maker, address(this)) || landNFT.getApproved(order.nftId) == address(this), "Order is invalid");
    require(order.active && order.taker == address(0), "Order is invalid");
    order.taker = msg.sender;
    order.active = false;
    delete ownerActiveLandOrders[order.maker][order.mission];
    for(uint i = 0; i < ownerActiveShareOrders[order.maker].length; i++) {
      uint orderId = ownerActiveShareOrders[order.maker][i];
      shareOrders[orderId].active = false;
      emit OrderCanceled(orderId);
    }
    delete ownerActiveShareOrders[order.maker];
    landNFT.transferFrom(address(this), order.taker, order.nftId);
    lands[order.mission].landLord = msg.sender;
    uint paymentAmount = _getPaymentAmount(order.price, _paymentCurrency);
    _transferOrderValue(order.mission, order.maker, paymentAmount, _paymentCurrency);
    emit OrderTaken(msg.sender, _id, order.maker, paymentType, _paymentCurrency);
  }

  function takeShareOrder(uint _id, IMarketPlace.PaymentCurrency _paymentCurrency) external whenNotPaused {
    _validatePaymentMethod(_paymentCurrency);
    ShareOrder storage order = shareOrders[_id];
    require(order.active && order.taker == address(0), "Invalid order");
    require(order.sharePercentage > 0, "Invalid order");
    if(_isLandLord(order.mission, order.maker)) {
      lands[order.mission].landLordPercentage = lands[order.mission].landLordPercentage.sub(order.sharePercentage);
    } else {
      lands[order.mission].shareHolderPercentage[order.maker] = lands[order.mission].shareHolderPercentage[order.maker].sub(order.sharePercentage);
    }
    if (_isHolders(lands[order.mission], msg.sender)) {
      lands[order.mission].shareHolderPercentage[msg.sender] = lands[order.mission].shareHolderPercentage[msg.sender].add(order.sharePercentage);
    } else {
      lands[order.mission].shareHolderPercentage[msg.sender] = order.sharePercentage;
      lands[order.mission].shareHolders.push(msg.sender);
    }
    order.taker = msg.sender;
    order.active = false;
    _removeOwnerActiveShareOrders(order.maker, _id);
    uint paymentAmount = _getPaymentAmount(order.price, _paymentCurrency);
    _transferOrderValue(order.mission, order.maker, paymentAmount, _paymentCurrency);
    emit OrderTaken(msg.sender, _id, order.maker, paymentType, _paymentCurrency);
  }

  function takeFounding(uint _mission, IMarketPlace.PaymentCurrency _paymentCurrency) external whenNotPaused {
    require(lands[_mission].foundingPrice > 0, "Land is not available");
    require(lands[_mission].landLord == address(0), "Land has occupied");
    _validatePaymentMethod(_paymentCurrency);
    uint currentPrice = _getPaymentAmount(lands[_mission].foundingPrice, _paymentCurrency);
    _takeFund(currentPrice, _paymentCurrency, address(this));
    _transferFund(fundAdmin, currentPrice, _paymentCurrency);
    lands[_mission].landLord = msg.sender;
    lands[_mission].landLordPercentage = FULL_PERCENT_DECIMAL3;
    landNFT.mintLand(_mission, msg.sender);
    emit LandLordGranted(_mission, msg.sender, lands[_mission].foundingPrice, paymentType, _paymentCurrency);
  }

  function syncLandLord(uint _mission) public {
    address landLord = landNFT.ownerOf(_mission);
    if (lands[_mission].landLord == address(0) && landLord != address(0)) {
      lands[_mission].landLordPercentage = FULL_PERCENT_DECIMAL3;
    }
    lands[_mission].landLord = landLord;
  }

  function getShareHolderInfo(uint _mission, address _shareHolder) external view returns (uint, uint) {
    Land storage land = lands[_mission];
    return(
      land.shareHolders.length,
      land.shareHolderPercentage[_shareHolder]
    );
  }

  function getLandInfo(uint _mission) external view returns (address, address[] memory, uint[] memory) {
    Land storage land = lands[_mission];
    uint[] memory percentages = new uint[](land.shareHolders.length);
    for (uint i = 0; i < land.shareHolders.length; i++) {
      address holder = land.shareHolders[i];
      percentages[i] = land.shareHolderPercentage[holder];
    }
    return(
      land.landLord,
      land.shareHolders,
      percentages
    );
  }

  // ADMINS FUNCTIONS

  function updatePaymentType(IMarketPlace.PaymentType _type) external onlyMainAdmin {
    paymentType = _type;
    emit PaymentTypeChanged(_type);
  }

  function setFoundingPrice(uint _mission, uint _price) external onlyMainAdmin {
    require(lands[_mission].landLord == address(0), "Land have land lord already");
    lands[_mission].foundingPrice = _price;
    emit FoundingPriceUpdated(_mission, _price);
  }

  function updateShareHolder(uint _mission, address _old, address _new) external onlyMainAdmin {
    Land storage land = lands[_mission];
    require(land.shareHolderPercentage[_old] > 0, "Invalid old holder");
    land.shareHolderPercentage[_new] += land.shareHolderPercentage[_old];
    delete land.shareHolderPercentage[_old];
    uint newIndex = _indexOf(land, _new);
    uint oldIndex = _indexOf(land, _old);
    if (newIndex == type(uint).max) {
      land.shareHolders[oldIndex] = _new;
    } else {
      land.shareHolders[oldIndex] = land.shareHolders[land.shareHolders.length - 1];
      land.shareHolders.pop();
    }
    emit ShareHolderChanged(_mission, _old, _new);
  }

  function setContracts(
    address _fotaToken,
    address _busdToken,
    address _usdtToken,
    address _fotaPricer,
    address _landNFT,
    address _gameProxy,
    address _citizen
  ) external onlyMainAdmin {
    fotaToken = IFOTAToken(_fotaToken);
    busdToken = IBEP20(_busdToken);
    usdtToken = IBEP20(_usdtToken);
    fotaPricer = IFOTAPricer(_fotaPricer);
    landNFT = ILandNFT(_landNFT);
    gameProxyContract = IFOTAGame(_gameProxy);
    citizen = ICitizen(_citizen);
  }

  function setShares(uint _referralShare, uint _creatorShare, uint _treasuryShare) external onlyMainAdmin {
    require(_referralShare > 0 && _referralShare <= 10000);
    referralShare = _referralShare;
    require(_creatorShare > 0 && _creatorShare <= 10000);
    creativeShare = _creatorShare;
    require(_treasuryShare > 0 && _treasuryShare <= 10000);
    treasuryShare = _treasuryShare;
  }

  function updateFundAdmin(address _address) external onlyMainAdmin {
    require(_address != address(0));
    fundAdmin = _address;
  }

  function updateMinPrice(uint _landMinPrice, uint _shareMinPrice) external onlyMainAdmin {
    landMinPrice = _landMinPrice;
    shareMinPrice = _shareMinPrice;
    emit MinPriceUpdated(landMinPrice, shareMinPrice, block.timestamp);
  }

  function updatePauseStatus(bool _paused) external onlyMainAdmin {
    if(_paused) {
      _pause();
    } else {
      _unpause();
    }
  }

  // PRIVATE FUNCTIONS

  function _isFotaPayment(IMarketPlace.PaymentCurrency _paymentCurrency) private view returns (bool) {
    return paymentType == IMarketPlace.PaymentType.fota || (paymentType == IMarketPlace.PaymentType.all && _paymentCurrency == IMarketPlace.PaymentCurrency.fota);
  }

  function _validatePaymentMethod(IMarketPlace.PaymentCurrency _paymentCurrency) private view {
    if (paymentType == IMarketPlace.PaymentType.fota) {
      require(_paymentCurrency == IMarketPlace.PaymentCurrency.fota, "400");
    } else if (paymentType == IMarketPlace.PaymentType.usd) {
      require(_paymentCurrency != IMarketPlace.PaymentCurrency.fota, "400");
    }
  }

  function _takeFund(uint _amount, IMarketPlace.PaymentCurrency _paymentCurrency, address _to) private {
    if (paymentType == IMarketPlace.PaymentType.fota) {
      _takeFundFOTA(_amount, _to);
    } else if (paymentType == IMarketPlace.PaymentType.usd) {
      _takeFundUSD(_amount, _paymentCurrency, _to);
    } else if (_paymentCurrency == IMarketPlace.PaymentCurrency.fota) {
      _takeFundFOTA(_amount, _to);
    } else {
      _takeFundUSD(_amount, _paymentCurrency, _to);
    }
  }

  function _takeFundUSD(uint _amount, IMarketPlace.PaymentCurrency _paymentCurrency, address _to) private {
    require(_paymentCurrency != IMarketPlace.PaymentCurrency.fota, "Invalid payment currency");
    IBEP20 usdToken = _paymentCurrency == IMarketPlace.PaymentCurrency.busd ? busdToken : usdtToken;
    require(usdToken.allowance(msg.sender, address(this)) >= _amount, "Please call approve first");
    require(usdToken.balanceOf(msg.sender) >= _amount, "Insufficient balance");
    require(usdToken.transferFrom(msg.sender, _to, _amount), "Transfer USD failed");
  }

  function _takeFundFOTA(uint _amount, address _to) private {
    require(fotaToken.allowance(msg.sender, address(this)) >= _amount, "Please call approve first");
    require(fotaToken.balanceOf(msg.sender) >= _amount, "Insufficient balance");
    require(fotaToken.transferFrom(msg.sender, _to, _amount), "Transfer FOTA failed");
  }

  function _transferFund(address _receiver, uint _amount, IMarketPlace.PaymentCurrency _paymentCurrency) private {
    if (_receiver == address(this)) {
      _receiver = fundAdmin;
    }
    if (paymentType == IMarketPlace.PaymentType.usd) {
      _transferFundUSD(_receiver, _amount, _paymentCurrency);
    } else if (paymentType == IMarketPlace.PaymentType.fota) {
      _transferFundFOTA(_receiver, _amount);
    } else if (_paymentCurrency == IMarketPlace.PaymentCurrency.fota) {
      _transferFundFOTA(_receiver, _amount);
    } else {
      _transferFundUSD(_receiver, _amount, _paymentCurrency);
    }
  }

  function _transferFundUSD(address _receiver, uint _amount, IMarketPlace.PaymentCurrency _paymentCurrency) private {
    if (_paymentCurrency == IMarketPlace.PaymentCurrency.usdt) {
      require(usdtToken.transfer(_receiver, _amount), "Transfer USDT failed");
    } else {
      require(busdToken.transfer(_receiver, _amount), "Transfer BUSD failed");
    }
  }

  function _transferFundFOTA(address _receiver, uint _amount) private {
    require(fotaToken.transfer(_receiver, _amount), "Transfer FOTA failed");
  }

  function _validateMaker(uint _mission, uint _sharePercent) private view {
    require(_sharePercent <= FULL_PERCENT_DECIMAL3, "Share percentage invalid");
    if (_isLandLord(_mission, msg.sender)) {
      require(lands[_mission].landLordPercentage >= _sharePercent, "Maker invalid");
    } else {
      require(lands[_mission].shareHolderPercentage[msg.sender] >= _sharePercent, "Maker invalid");
    }
  }

  function _isLandLord(uint _mission, address _landLord) private view returns (bool) {
    return lands[_mission].landLord == _landLord;
  }

  function _isHolders(Land storage _land, address _address) private view returns (bool) {
    for(uint i = 0; i < _land.shareHolders.length; i++) {
      if (_land.shareHolders[i] == _address) {
        return true;
      }
    }
    return false;
  }

  function _indexOf(Land storage _land, address _address) private view returns (uint) {
    for(uint i = 0; i < _land.shareHolders.length; i++) {
      if (_land.shareHolders[i] == _address) {
        return i;
      }
    }
    return type(uint).max;
  }

  function _getPaymentAmount(uint _price, IMarketPlace.PaymentCurrency _paymentCurrency) private view returns (uint) {
    if (_isFotaPayment(_paymentCurrency)) {
      return _price * 1000 / fotaPricer.fotaPrice();
    }
    return _price;
  }

  function _transferOrderValue(uint _mission, address _receiver, uint _paymentAmount, IMarketPlace.PaymentCurrency _paymentCurrency) private {
    uint shareAmount = _paymentAmount * (referralShare + creativeShare + treasuryShare) / FULL_PERCENT_DECIMAL3;
    _takeFund(_paymentAmount, _paymentCurrency, address(this));
    _transferFund(_receiver, _paymentAmount - shareAmount, _paymentCurrency);
    _shareOrderValue(_mission, shareAmount, _paymentCurrency);
  }

  function _shareOrderValue(uint _tokenId, uint _totalShareAmount, IMarketPlace.PaymentCurrency _paymentCurrency) private {
    uint totalSharePercent = referralShare + creativeShare + treasuryShare;
    uint referralSharingAmount = referralShare * _totalShareAmount / totalSharePercent;
    uint treasurySharingAmount = treasuryShare * _totalShareAmount / totalSharePercent;
    uint creativeSharingAmount = creativeShare * _totalShareAmount / totalSharePercent;
    address inviter = citizen.getInviter(msg.sender);
    if (inviter == address(0)) {
      inviter = treasuryAddress;
    } else {
      bool validInviter = _validateInviter(inviter);
      if (!validInviter) {
        inviter = treasuryAddress;
      }
    }
    emit ReferralSent(inviter, msg.sender, referralSharingAmount, _paymentCurrency);
    _transferFund(inviter, referralSharingAmount, _paymentCurrency);

    address creator = landNFT.creators(_tokenId);
    if (creator == address(0)) {
      creator = fundAdmin;
    }
    _transferFund(creator, creativeSharingAmount, _paymentCurrency);

    _transferFund(treasuryAddress, treasurySharingAmount, _paymentCurrency);
  }

  function _validateInviter(address _inviter) private view returns (bool) {
    return gameProxyContract.validateInviter(_inviter);
  }

  function _removeOwnerActiveShareOrders(address _maker, uint _orderId) private {
    ownerActiveShareOrders[_maker].removeElementFromArray(_orderId);
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

library StringUtil {
  struct slice {
    uint _length;
    uint _pointer;
  }

  function validateUserName(string calldata _username)
  internal
  pure
  returns (bool)
  {
    uint8 len = uint8(bytes(_username).length);
    if ((len < 4) || (len > 21)) return false;

    // only contain A-Z 0-9
    for (uint8 i = 0; i < len; i++) {
      if (
        (uint8(bytes(_username)[i]) < 48) ||
        (uint8(bytes(_username)[i]) > 57 && uint8(bytes(_username)[i]) < 65) ||
        (uint8(bytes(_username)[i]) > 90)
      ) return false;
    }
    // First char != '0'
    return uint8(bytes(_username)[0]) != 48;
  }

  function toBytes24(string memory source)
  internal
  pure
  returns (bytes24 result)
  {
    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
      return 0x0;
    }

    assembly {
      result := mload(add(source, 24))
    }
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

library Math {

  function add(uint a, uint b) internal pure returns (uint) {
    unchecked {
      uint256 c = a + b;
      require(c >= a, "SafeMath: addition overflow");

      return c;
    }
  }

  function sub(uint a, uint b) internal pure returns (uint) {
    unchecked {
      require(b <= a, "Math: sub underflow");
      uint256 c = a - b;

      return c;
    }
  }

  function mul(uint a, uint b) internal pure returns (uint) {
    unchecked {
      if (a == 0) {
        return 0;
      }

      uint256 c = a * b;
      require(c / a == b, "SafeMath: multiplication overflow");

      return c;
    }
  }

  function div(uint a, uint b) internal pure returns (uint) {
    unchecked {
      require(b > 0, "SafeMath: division by zero");
      uint256 c = a / b;

      return c;
    }
  }

  function genRandomNumber(string calldata _seed, uint _dexRandomSeed) internal view returns (uint8) {
    return genRandomNumberInRange(_seed, _dexRandomSeed, 0, 99);
  }

  function genRandomNumberInRange(string calldata _seed, uint _dexRandomSeed, uint _from, uint _to) internal view returns (uint8) {
    require(_to > _from, 'Math: Invalid range');
    uint randomNumber = uint(
      keccak256(
        abi.encodePacked(
          keccak256(
            abi.encodePacked(
              block.number,
              block.difficulty,
              block.timestamp,
              msg.sender,
              _seed,
              _dexRandomSeed
            )
          )
        )
      )
    ) % (_to - _from + 1);
    return uint8(randomNumber + _from);
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

library ArrayUtil {
  function removeElementFromArray(uint[] storage _array, uint _element) internal returns (uint[] memory) {
    uint index = _getElementIndex(_array, _element);
    if (index >= 0 && index < _array.length) {
      _array[index] = _array[_array.length - 1];
      _array.pop();
    }
    return _array;
  }

  function _getElementIndex(uint[] memory _array, uint _element) private pure returns (uint) {
    for(uint i = 0; i < _array.length; i++) {
      if (_array[i] == _element) return i;
    }
    return type(uint).max;
  }
}

// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

import "./IGameNFT.sol";

interface IMarketPlace {
  enum OrderType {
    trading,
    renting
  }
  enum OrderKind {
    hero,
    item,
    land
  }
  enum PaymentType {
    fota,
    usd,
    all
  }
  enum PaymentCurrency {
    fota,
    busd,
    usdt
  }
  function fotaToken() external view returns (address);
  function busdToken() external view returns (address);
  function usdtToken() external view returns (address);
  function citizen() external view returns (address);
  function takeOrder(OrderKind _kind, uint _tokenId, PaymentCurrency _paymentCurrency) external;
  function paymentType() external view returns (PaymentType);
  function currentRentedHeroCounter(address _user) external view returns (uint);
  function currentRentingHero(uint _heroId) external view returns (address);
  function currentRentingItem(uint _itemId) external view returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import '@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol';

interface ILandNFT is IERC721Upgradeable {
  function mintLand(uint _id, address _owner) external;
  function creators(uint _id) external view returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import '@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol';

interface IGameNFT is IERC721Upgradeable {
  function mintHero(address _owner, uint16 _classId, uint _price, uint _index) external returns (uint);
  function mintHeroes(address _owner, uint16 _classId, uint _price, uint _quantity) external;
  function heroes(uint _tokenId) external returns (uint16, uint, uint8, uint32, uint, uint, uint);
  function getHero(uint _tokenId) external view returns (string memory, string memory, string memory, uint16, uint, uint8, uint32);
  function getHeroStrength(uint _tokenId) external view returns (uint, uint, uint, uint, uint);
  function getOwnerHeroes(address _owner) external view returns(uint[] memory);
  function getOwnerTotalLevelThatNotReachMaxProfit(address _owner) external view returns(uint);
  function increaseTotalProfited(uint _tokenId, uint _totalProfited) external;
  function reachMaxProfit(uint _tokenId) external view returns (bool);
  function mintItem(address _owner, uint8 _gene, uint16 _class, uint _price, uint _index) external returns (uint);
  function getItem(uint _tokenId) external view returns (uint8, uint16, uint, uint, uint);
  function getClassId(uint _tokenId) external view returns (uint16);
  function burn(uint _tokenId) external;
  function getCreator(uint _tokenId) external view returns (address);
  function countId() external view returns (uint16);
  function updateOwnPrice(uint _tokenId, uint _ownPrice) external;
  function updateFailedUpgradingAmount(uint _tokenId, uint _amount) external;
  function skillUp(uint _tokenId, uint8 _index) external;
  function experienceUp(uint _tokenId, uint32 _experience) external;
  function experienceCheckpoint(uint8 _level) external view returns (uint32);
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

// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

interface IFOTAPricer {
  function fotaPrice() external view returns (uint);
}

// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

interface IFOTAGame {
  function validateInviter(address _inviter) external view returns (bool);
  function getTotalWinInDay(address _user) external view returns (uint);
  function getTotalPVEWinInDay(address _user) external view returns (uint);
  function getTotalPVPWinInDay(address _user) external view returns (uint);
  function getTotalDUALWinInDay(address _user) external view returns (uint);
  function updateLandLord(uint _mission, address _landLord) external;
}

// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

interface ICitizen {
  function isCitizen(address _address) external view returns (bool);
  function register(address _address, string memory _userName, address _inviter) external returns (uint);
  function getInviter(address _address) external returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
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