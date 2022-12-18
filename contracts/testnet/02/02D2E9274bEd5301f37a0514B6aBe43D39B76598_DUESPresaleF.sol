// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IERC20 {
  function balanceOf(address account) external view returns (uint256);

  function transfer(address to, uint256 amount) external returns (bool);

  function transferFrom(
    address from,
    address to,
    uint256 amount
  ) external returns (bool);
}

contract DUESPresaleF {
  IERC20 public constant BUSD =
    IERC20(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee); // 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee
  //0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56

  IERC20 public constant DAI =
    IERC20(0xEC5dCb5Dbf4B114C9d0F65BcCAb49EC54F6A0867); //0xEC5dCb5Dbf4B114C9d0F65BcCAb49EC54F6A0867
  //0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3

  IERC20 public constant USDT =
    IERC20(0x337610d27c682E347C9cD60BD4b3b107C9d34dDd); //0x337610d27c682E347C9cD60BD4b3b107C9d34dDd
  //0x55d398326f99059fF775485246999027B3197955

  IERC20 public constant USDC =
    IERC20(0x64544969ed7EBf5f083679233325356EbE738930); //0x64544969ed7EBf5f083679233325356EbE738930
  // 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d

  // IERC20(); // localhost

  IERC20 public DUES = IERC20(0x65DEf77Ec221132021a5D89Ce9c695A9b73A7eA7); // mainnet    to be adjusted
  // IERC20(); // localhost

  address public owner;

  mapping(address => uint256) public user_deposits;
  mapping(address => uint256) public snowOwned;

  mapping(address => uint256) public totalUserDeposits; // How much each user has deposited in to the presale contract
  mapping(address => bool) public vest;
  uint256 public total_deposited;
  uint256 public minDepositPerPerson = 0 ether; //to be adjusted
  uint256 public maxDepositPerPerson = 5000 ether; //to be adjusted
  uint256 public maxDepositGlobalRound1 = 9000 ether;
  uint256 public maxDepositGlobalRound2 = 36000 ether;
  uint256 public maxDepositGlobalRound3 = 223049 ether; //to be adjusted
  uint256 public round = 1;
  uint256 public round1Value = 3;
  uint256 public round2Value = 6;
  uint256 public round3Value = 9;

  bool public enabled = false;
  bool public sale_finalized = false;

  // CUSTOM ERRORS

  error SaleIsNotActive();
  error MinimumNotReached();
  error IndividualMaximumExceeded();
  error GlobalMaximumExceeded();
  error ZeroAddress();
  error SaleIsNotFinalizedYet();
  error DidNotParticipate();
  error TokenNotAccepted();

  constructor() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "Caller is not the Owner!");
    _;
  }

  function getUserDeposits(address user) public view returns (uint256) {
    return user_deposits[user];
  }

  function getSnowOwned(address user) public view returns (uint256) {
    return snowOwned[user];
  }

  function getTotalRaised() external view returns (uint256) {
    return total_deposited;
  }

  function depositBUSD(uint256 _amount, IERC20 token, bool _vest) public {
    if (!enabled || sale_finalized) revert SaleIsNotActive();
    if (token != BUSD && token != DAI && token != USDT && token != USDC) {
      revert TokenNotAccepted();
    }

    if (_amount + getUserDeposits(msg.sender) > maxDepositPerPerson)
      revert IndividualMaximumExceeded();

    if (round == 1) {
      if (_amount + total_deposited > maxDepositGlobalRound1)
        revert GlobalMaximumExceeded();
      user_deposits[msg.sender] += _amount;
      snowOwned[msg.sender] += (((_amount * 100) / round1Value));
    } else if (round == 2) {
      if (
        _amount + total_deposited >
        (maxDepositGlobalRound1 + maxDepositGlobalRound2)
      ) revert GlobalMaximumExceeded();
      user_deposits[msg.sender] += _amount;
      snowOwned[msg.sender] += (_amount / round2Value) * 100;
    } else if (round == 3) {
      if (
        _amount + total_deposited >
        (maxDepositGlobalRound1 +
          maxDepositGlobalRound2 +
          maxDepositGlobalRound3)
      ) revert GlobalMaximumExceeded();
      user_deposits[msg.sender] += _amount;
      snowOwned[msg.sender] += (_amount / round3Value) * 100;
    }
    vest[msg.sender] = _vest;
    total_deposited += _amount;

    token.transferFrom(msg.sender, address(this), _amount);
  }

  function withdrawDUES() external {
    if (!sale_finalized) revert SaleIsNotFinalizedYet();

    uint256 total_to_send = snowOwned[msg.sender];

    if (total_to_send == 0) {
      revert DidNotParticipate();
    }

    user_deposits[msg.sender] = 0;

    DUES.transfer(msg.sender, total_to_send);
  }

  function setEnabled(bool _enabled) external onlyOwner {
    enabled = _enabled;
  }

  function finalizeSale() external onlyOwner {
    sale_finalized = true;
  }

  function withdrawPresaleFunds(address _address) external onlyOwner {
    if (_address == address(0)) revert ZeroAddress();

    BUSD.transfer(_address, BUSD.balanceOf(address(this)));
    DAI.transfer(_address, DAI.balanceOf(address(this)));
    USDC.transfer(_address, USDC.balanceOf(address(this)));
    USDT.transfer(_address, USDT.balanceOf(address(this)));
  }

  function changeOwner(address _address) external onlyOwner {
    if (_address == address(0)) revert ZeroAddress();
    owner = _address;
  }

  function setDuesAddress(IERC20 _dues) public onlyOwner {
    DUES = _dues;
  }

  function getDuesAddress() public view returns (address) {
    return address(DUES);
  }

  function changeRound(uint256 _round) public onlyOwner {
    if (_round != 2 && _round != 3) {
      revert("BadRound");
    }
    round = _round;
  }
}