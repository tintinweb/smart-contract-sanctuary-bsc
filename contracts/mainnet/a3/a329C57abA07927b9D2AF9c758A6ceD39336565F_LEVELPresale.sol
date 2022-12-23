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

contract LEVELPresale {
  IERC20 public constant BUSD =
    IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); // 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee
  //0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56

  IERC20 public constant DAI =
    IERC20(0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3); //0xEC5dCb5Dbf4B114C9d0F65BcCAb49EC54F6A0867
  //0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3

  IERC20 public constant USDT =
    IERC20(0x55d398326f99059fF775485246999027B3197955); //0x337610d27c682E347C9cD60BD4b3b107C9d34dDd
  //0x55d398326f99059fF775485246999027B3197955

  IERC20 public constant USDC =
    IERC20(0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d); //0x64544969ed7EBf5f083679233325356EbE738930
  // 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d

  // IERC20(); // localhost

  IERC20 public DUES = IERC20(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82); // mainnet    to be adjusted
  // IERC20(); // localhost

  address public owner;
  address public treasury = 0x81E0cCB4cB547b9551835Be01340508138695999;
  mapping(address => uint256) public user_deposits;
  mapping(address => uint256) public levelOwned;

  mapping(address => uint256) public totalUserDeposits; // How much each user has deposited in to the presale contract
  mapping(address => bool) public vest;
  uint256 public total_deposited;
  uint256 public minDepositPerPerson = 0 ether; //to be adjusted
  uint256 public maxDepositPerPerson = 5000 ether; //to be adjusted
  uint256 public maxDepositGlobalRound1 = 11000 ether;
  uint256 public maxDepositGlobalRound2 = 34000 ether;
  uint256 public maxDepositGlobalRound3 = 223049 ether; //to be adjusted
  uint256 public round = 1;
  uint256 public round1Value = 33;
  uint256 public round2Value = 33;
  uint256 public round3Value = 33;

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

  function getLevelOwned(address user) public view returns (uint256) {
    return levelOwned[user];
  }

  function getTotalRaised() external view returns (uint256) {
    return total_deposited;
  }

  function depositBUSD(uint256 _amount, IERC20 token) public {
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
      levelOwned[msg.sender] += (((_amount * 100) / round1Value));
    } else if (round == 2) {
      if (
        _amount + total_deposited >
        (maxDepositGlobalRound1 + maxDepositGlobalRound2)
      ) revert GlobalMaximumExceeded();
      user_deposits[msg.sender] += _amount;
      levelOwned[msg.sender] += (_amount / round2Value) * 100;
    } else if (round == 3) {
      if (
        _amount + total_deposited >
        (maxDepositGlobalRound1 +
          maxDepositGlobalRound2 +
          maxDepositGlobalRound3)
      ) revert GlobalMaximumExceeded();
      user_deposits[msg.sender] += _amount;
      levelOwned[msg.sender] += (_amount / round3Value) * 100;
    }
    total_deposited += _amount;
    token.transferFrom(msg.sender, address(this), _amount);
  }

  function withdrawDUES() external {
    if (!sale_finalized) revert SaleIsNotFinalizedYet();

    uint256 total_to_send = levelOwned[msg.sender];

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

  function withdrawPresaleFunds() external onlyOwner {
    if (treasury == address(0)) revert ZeroAddress();

    BUSD.transfer(treasury, BUSD.balanceOf(address(this)));
    DAI.transfer(treasury, DAI.balanceOf(address(this)));
    USDC.transfer(treasury, USDC.balanceOf(address(this)));
    USDT.transfer(treasury, USDT.balanceOf(address(this)));
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

  function setRound2(uint256 value, uint256 cap) public onlyOwner {
    maxDepositGlobalRound2 = cap;
    round2Value = value;
  }

  function setRound3(uint256 value, uint256 cap) public onlyOwner {
    maxDepositGlobalRound3 = cap;
    round3Value = value;
  }

  function getRoundDeposits() public view returns (uint256) {
    if (round == 1) {
      return total_deposited;
    } else if (round == 2) {
      return (total_deposited - maxDepositGlobalRound1);
    } else if (round == 3) {
      return (total_deposited -
        maxDepositGlobalRound1 -
        maxDepositGlobalRound2);
    } else {
      return 0;
    }
  }

  function getRoundMax() public view returns (uint256) {
    if (round == 1) {
      return maxDepositGlobalRound1;
    } else if (round == 2) {
      return maxDepositGlobalRound2;
    } else if (round == 3) {
      return maxDepositGlobalRound3;
    } else {
      return 0;
    }
  }
}