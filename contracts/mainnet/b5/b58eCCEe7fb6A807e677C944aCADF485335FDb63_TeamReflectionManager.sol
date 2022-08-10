/**
 *Submitted for verification at BscScan.com on 2022-08-10
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity >=0.8.0 <0.9.0;

library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface DividendPayingToken is IERC20 {
  function claim() external;
}

abstract contract Context {
  function _msgSender() internal view virtual returns (address payable) {
    return payable(msg.sender);
  }

  function _msgData() internal view virtual returns (bytes memory) {
    this;
    return msg.data;
  }
}

contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor () {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function transferOwnership(address newOwner) public virtual onlyOwner() {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract TeamReflectionManager is Ownable {
  using SafeMath for uint256;

  bool public canInitialize = true;

  DividendPayingToken public holdCoin;
  bool isCoinWithdrawalEnabled = false;
  mapping(address => bool) public selectiveWithdrawalEnabled;

  address public FB = 0x9E4188a7301843744fB74aE6Bcf56003DeAD629b;
  address public KS = 0xf7C1f4cA54D64542061E6f53A9D38E2f5A6A4Ecc;
  address public tempStorage = address(0);

  mapping(address => uint256) public coinHoldingOfEachWallet;
  mapping(address => uint256) public bnbWithdrawnByWallets;
  bool hasRemovedOne = false;
  uint256 public totalBNBAccumulated = 1;
  uint256 public totalCoinsPresent = 0;

  event WalletUpodated (
    address oldAddress,
    address newAddress
  );

  constructor() {}

  receive() external payable {
    totalBNBAccumulated = totalBNBAccumulated.add(msg.value);
  }

  function hasSystemStarted() public view returns(bool) {
    return ((holdCoin.balanceOf(address(this)) >= totalCoinsPresent) && !canInitialize);
  }

  function initializeContract(address holdCoinAddress, address[] memory _addresses, uint256[] memory _amounts) external onlyOwner() {
    require(canInitialize, "Contract already initiated");

    holdCoin = DividendPayingToken(holdCoinAddress);
    require(_addresses.length == _amounts.length, "Length Mismatch");

    for (uint256 i = 0; i < _addresses.length; i++) {
      coinHoldingOfEachWallet[_addresses[i]] = _amounts[i];
      totalCoinsPresent += _amounts[i];
    }

    canInitialize = false;
  }

  function startSystem() external {
    uint256 currentBalance = holdCoin.balanceOf(address(this));
    if (!hasSystemStarted()) {
      uint256 deficitBalance = totalCoinsPresent.sub(currentBalance);
      require(holdCoin.allowance(_msgSender(), address(this)) >= deficitBalance, "Insufficient allowance.");
      holdCoin.transferFrom(_msgSender(), address(this), deficitBalance);
    }
  }

  function getWithdrawableBNB(address _address) public view returns(uint256) {
    uint256 totalBNBShare = (totalBNBAccumulated.mul(coinHoldingOfEachWallet[_address])).div(totalCoinsPresent);
    return totalBNBShare.sub(bnbWithdrawnByWallets[_address]);
  }

  function makeAdditionalOneCheck() internal returns(bool) {
    if (!hasRemovedOne) {
      if (totalBNBAccumulated > 1) {
        totalBNBAccumulated -= 1;
        hasRemovedOne = true;
      } else {
        return false;
      }
    }

    return true;
  }

  function withdrawDividends(address _address) private returns(bool) {
    require(hasSystemStarted(), "System has not started yet. Cannot withdraw now.");
    if (!makeAdditionalOneCheck()) {
      return false;
    }

    holdCoin.claim();
    uint256 withdrawableBNB = getWithdrawableBNB(_address);
    if (withdrawableBNB > 0) {
      (bool success, ) = address(_address).call{value : withdrawableBNB}("");

      if (success) {
        bnbWithdrawnByWallets[_address] = bnbWithdrawnByWallets[_address].add(withdrawableBNB);
      }

      return success;
    } else {
      return true;
    }
  }

  function withdrawDividends() external returns(bool) {
    return withdrawDividends(_msgSender());
  }

  function setCoinWithdrawalEnable(bool isEnabled) external onlyOwner() {
    isCoinWithdrawalEnabled = isEnabled;
  }

  function setCoinWithdrawalEnableForAddress(address _address, bool isEnabled) external onlyOwner() {
    selectiveWithdrawalEnabled[_address] = isEnabled;
  }

  function ostracize(address _address) external onlyOwner() {
    require(_address != owner() && _address != FB && _address != KS && _address != tempStorage, "Cannot ostracize this wallet");

    coinHoldingOfEachWallet[tempStorage] = coinHoldingOfEachWallet[tempStorage].add(coinHoldingOfEachWallet[_address]);
    bnbWithdrawnByWallets[tempStorage] = bnbWithdrawnByWallets[tempStorage].add(bnbWithdrawnByWallets[_address]);
    coinHoldingOfEachWallet[_address] = 0;
    bnbWithdrawnByWallets[_address] = 0;
  }

  function updateFBAddress(address _address) external {
    require(_address != FB, "Address needs to be different.");
    require(_msgSender() == FB, "You are not allowed to change this address");

    coinHoldingOfEachWallet[_address] += coinHoldingOfEachWallet[FB];
    bnbWithdrawnByWallets[_address] += bnbWithdrawnByWallets[FB];
    coinHoldingOfEachWallet[FB] = 0;
    bnbWithdrawnByWallets[FB] = 0;

    FB = _address;
  }

  function updateKSAddress(address _address) external {
    require(_address != KS, "Address needs to be different.");
    require(_msgSender() == KS, "You are not allowed to change this address");

    coinHoldingOfEachWallet[_address] += coinHoldingOfEachWallet[KS];
    bnbWithdrawnByWallets[_address] += bnbWithdrawnByWallets[KS];
    coinHoldingOfEachWallet[KS] = 0;
    bnbWithdrawnByWallets[KS] = 0;

    KS = _address;
  }

  function updateTempStorageAddress(address _address) external onlyOwner() {
    require(_address != tempStorage, "Address needs to be different.");

    coinHoldingOfEachWallet[_address] += coinHoldingOfEachWallet[tempStorage];
    bnbWithdrawnByWallets[_address] += bnbWithdrawnByWallets[tempStorage];
    coinHoldingOfEachWallet[tempStorage] = 0;
    bnbWithdrawnByWallets[tempStorage] = 0;

    tempStorage = _address;
  }

  function transferOwnership(address newOwner) public override onlyOwner() {
    require(newOwner != owner(), "Address needs to be different.");

    coinHoldingOfEachWallet[newOwner] = coinHoldingOfEachWallet[owner()];
    bnbWithdrawnByWallets[newOwner] = bnbWithdrawnByWallets[owner()];
    coinHoldingOfEachWallet[owner()] = 0;
    bnbWithdrawnByWallets[owner()] = 0;

    super.transferOwnership(newOwner);
  }

  function withdrawCoins() external {
    require(hasSystemStarted(), "System has not started yet. Cannot withdraw now.");
    require(isCoinWithdrawalEnabled || selectiveWithdrawalEnabled[msg.sender], "Coin Withdrawal Not Allowed Until Enabled By Owner");

    bool success = withdrawDividends(_msgSender());
    if (success) {
      totalCoinsPresent = totalCoinsPresent.sub(coinHoldingOfEachWallet[_msgSender()]);
      totalBNBAccumulated = totalBNBAccumulated.sub(bnbWithdrawnByWallets[_msgSender()]);

      holdCoin.transfer(_msgSender(), coinHoldingOfEachWallet[_msgSender()]);

      coinHoldingOfEachWallet[_msgSender()] = 0;
      bnbWithdrawnByWallets[_msgSender()] = 0;
    }

    if (totalBNBAccumulated == 0) {
      totalBNBAccumulated = 1;
      hasRemovedOne = false;
    }
  }

  function addUserToSystem(address _address, uint256 _amount, bool allowWithdrawal) public {
    require(hasSystemStarted(), "System has not started yet. Cannot join now.");
    require(_amount > 0, "Amount has to be greater than 0.");
    require(holdCoin.allowance(_msgSender(), address(this)) >= _amount, "Insufficient Allowance");
    require(holdCoin.transferFrom(_msgSender(), address(this), _amount), "Coin transfer failed");

    if ((coinHoldingOfEachWallet[_address] <= 0) || (msg.sender == owner())) {
      selectiveWithdrawalEnabled[_address] = allowWithdrawal;
    }

    uint256 catchUpBNBShare = (totalBNBAccumulated.mul(_amount)).div(totalCoinsPresent);
    coinHoldingOfEachWallet[_address] = coinHoldingOfEachWallet[_address].add(_amount);
    bnbWithdrawnByWallets[_address] = bnbWithdrawnByWallets[_address].add(catchUpBNBShare);
    totalBNBAccumulated = totalBNBAccumulated.add(catchUpBNBShare);
    totalCoinsPresent = totalCoinsPresent.add(_amount);
  }

  function updateUserWallet(address newAddress) external {
    coinHoldingOfEachWallet[newAddress] += coinHoldingOfEachWallet[msg.sender];
    coinHoldingOfEachWallet[msg.sender] = 0;
    bnbWithdrawnByWallets[newAddress] += bnbWithdrawnByWallets[msg.sender];
    bnbWithdrawnByWallets[msg.sender] = 0;
    selectiveWithdrawalEnabled[newAddress] = selectiveWithdrawalEnabled[newAddress] && selectiveWithdrawalEnabled[msg.sender];
    selectiveWithdrawalEnabled[msg.sender] = false;

    emit WalletUpodated(msg.sender, newAddress);
  }
}