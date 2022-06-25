/**
 *Submitted for verification at BscScan.com on 2022-06-25
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

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
        return c;
    }
}

contract LiquidityRecaiver is Auth {
  using SafeMath for uint256;

  address public LPToken;
  address public LPRecaiver;

  constructor() Auth(msg.sender) {
    LPToken = address(this);
    LPRecaiver = address(this);
  }

  function withdrawpercen(uint256 _percen) external authorized() returns (bool) {
    IBEP20 a = IBEP20(LPToken);
    uint256 amount = a.balanceOf(address(this));
    a.transfer(msg.sender,amount.mul(_percen).div(100));
    return true;
  }

  function withdrawamount(uint256 _amount) external authorized() returns (bool) {
    IBEP20 a = IBEP20(LPToken);
    a.transfer(msg.sender,_amount);
    return true;
  }

  function withdrawMax() external authorized() returns (bool) {
    IBEP20 a = IBEP20(LPToken);
    uint256 amount = a.balanceOf(address(this));
    a.transfer(msg.sender,amount);
    return true;
  }

  function updateAddress(address _lptokenadr,address _lprecaiveradr) external authorized() returns (bool) {
    LPToken = _lptokenadr;
    LPRecaiver = _lprecaiveradr;
    return true;
  }

  function rescue() external authorized() {
    payable(owner).transfer(address(this).balance);
  }

  receive() external payable { }
}