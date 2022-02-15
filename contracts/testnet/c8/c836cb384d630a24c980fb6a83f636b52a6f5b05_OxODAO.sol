/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/

/*
 ██████╗ ██╗  ██╗ ██████╗     ███╗   ███╗ █████╗ ███████╗██╗ █████╗ 
██╔═████╗╚██╗██╔╝██╔═████╗    ████╗ ████║██╔══██╗██╔════╝██║██╔══██╗
██║██╔██║ ╚███╔╝ ██║██╔██║    ██╔████╔██║███████║█████╗  ██║███████║
████╔╝██║ ██╔██╗ ████╔╝██║    ██║╚██╔╝██║██╔══██║██╔══╝  ██║██╔══██║
╚██████╔╝██╔╝ ██╗╚██████╔╝    ██║ ╚═╝ ██║██║  ██║██║     ██║██║  ██║
 ╚═════╝ ╚═╝  ╚═╝ ╚═════╝     ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    require((c = a + b) >= b, "SafeMath: Add Overflow");
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
    require((c = a - b) <= a, "SafeMath: Underflow");
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    require(b == 0 || (c = a * b) / b == a, "SafeMath: Mul Overflow");
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
    require(b > 0, "SafeMath: Div 0");
    c = a / b;
  }
}

contract OxO {
  string public name = "OxO Token";
  string public symbol = "OxO";
  uint256 public decimals = 0;

  address public minter;
  OxODAO dao;

  event Transfer(address indexed from, address indexed to, uint256 value);

  mapping (address => uint256) public yeaVotes;
  mapping (address => uint256) public neyVotes;
  mapping (address => mapping (address => uint256)) private yea;
  mapping (address => mapping (address => uint256)) private ney;


  modifier onlyMinter() {
    require(msg.sender == minter, "EmethToken: no minter role");
    _;
  }

  constructor(address _minter) {
    minter = _minter;
    dao = OxODAO(payable(_minter));
  }

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(dao.shareholders(msg.sender), 'OxO: you are not a shareholder');

    // Yea
    if(_value > 0) {
      require(yea[msg.sender][_to] == 0, 'OxO: you already voted yea');
      yeaVotes[_to] = yeaVotes[_to] + 1;
      if(ney[msg.sender][_to] > 0) {
        ney[msg.sender][_to] = 0;
        neyVotes[_to] = neyVotes[_to] - 1;
      } 
      if(yeaVotes[_to] > dao.numShareholders() / 2) dao.addShareholder(_to);
    } else {
      require(ney[msg.sender][_to] == 0, 'OxO: you already voted ney');
      neyVotes[_to] = neyVotes[_to] + 1;
      if(yea[msg.sender][_to] > 0) {
        yea[msg.sender][_to] = 0;
        yeaVotes[_to] = yeaVotes[_to] - 1;
      }
      if(neyVotes[_to] > dao.numShareholders() / 2) dao.removeShareholder(_to);
    }

    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256 balance) {
    return dao.shareholders(_owner) ? 1 : 0;
  }

  function totalSupply() public view returns (uint256) {
    return dao.numShareholders();
  }
  
  function mint(address _to, uint256 _amount) external onlyMinter returns (bool) {
    emit Transfer(address(0), _to, _amount);
    return true;
  }
}

// (0x0).oO Mafia!
contract OxODAO {
  using SafeMath for uint256;

  OxO public token;
  uint256 public numShareholders = 0;
  mapping(address => bool) public shareholders;
  address[] public shareholderIndex;

  uint256 public totalShare = 0;
  uint256 public totalPendingShare = 0;
  mapping(address => uint256) public accumulated;
  mapping(address => uint256) public withdrawn;

  event Shareholder(address indexed shareholder, uint256 action);
  event Withdraw(address indexed shareholder, uint256 amount);

  modifier onlyToken() {
    require(msg.sender == address(token), '0x0DAO: insufficient privilege');
    _;
  }

  constructor() {
    token = new OxO(address(this));
    token.mint(msg.sender, 1);
    numShareholders = 1;
    shareholders[msg.sender] = true;
    shareholderIndex.push(msg.sender);
  }

  receive() external payable {
    totalShare = totalShare.add(msg.value);
    totalPendingShare = totalPendingShare.add(msg.value);
  }

  function pendingShare(address _shareholder) public view returns (uint256) {
    return accumulatedShare(_shareholder)
           .sub(withdrawn[_shareholder]);
  }

  function accumulatedShare(address _shareholder) public view returns (uint256) {
    return totalPendingShare
           .div(numShareholders)
           .add(accumulated[_shareholder]);
  }

  function payout(address _to, uint256 _amount) public returns (bool) {
    require(pendingShare(_to) >= _amount, "0x0DAO: insufficient pending shares");
    withdrawn[_to] = withdrawn[_to].add(_amount);
    payable(_to).transfer(_amount);
    emit Withdraw(_to, _amount);
    return true;
  }

  function payout() external returns (bool) {
    for(uint256 i; i < shareholderIndex.length; i++) {
      uint256 share = pendingShare(shareholderIndex[i]);
      if(share > 0) {
        payout(shareholderIndex[i], share);
      }
    }
    return true;
  }

  function updateShare() private returns (bool) {
    if(totalPendingShare > 0) {
      uint256 share = totalPendingShare.div(numShareholders);
      for(uint256 i; i < shareholderIndex.length; i++) {
        if(shareholders[shareholderIndex[i]]) {
          accumulated[shareholderIndex[i]] = accumulated[shareholderIndex[i]].add(share);
        }
      }
      totalPendingShare = 0;
    }
    return true;
  }

  function addShareholder(address _shareholder) external onlyToken returns (bool) {
    if(!shareholders[_shareholder]) {
      updateShare();
      shareholders[_shareholder] = true;
      shareholderIndex.push(_shareholder);
      numShareholders = numShareholders.add(1);
      emit Shareholder(_shareholder, 1);
    }
    return true;
  }

  function removeShareholder(address _shareholder) external onlyToken returns (bool) {
    if(shareholders[_shareholder]) {
      updateShare();
      shareholders[_shareholder] = false;
      numShareholders = numShareholders.sub(1);
      emit Shareholder(_shareholder, 0);
    }
    return true;
  }
}