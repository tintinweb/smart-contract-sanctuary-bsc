/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

abstract contract Ownable {
    address internal owner;
    constructor(address _owner) { owner = _owner; }
    modifier onlyOwner() { require(isOwner(msg.sender), "!OWNER"); _; }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
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

contract Hoksage is Ownable {
  using SafeMath for uint256;

  struct User {
    bool registered;
    address referral;
    mapping(uint8 => bool) activeLevels;
  }

  struct Pair {
    address currentreferral;
    address[] refferee;
  }

  mapping(address => User) public users;
  mapping(address => mapping (uint256 => Pair)) private pairs;
  
  uint256 public registered;
  address public defaultAddress;

  mapping(address => uint256) public getidfromaddress;
  mapping(uint256 => address) public getaddressfromid;

  uint256 public refdirect;
  mapping(uint256 => uint256) public refdividend;
  mapping(uint256 => uint256) public levelprice;

  bool reentrantcy;

  modifier noReentrant() {
    require(!reentrantcy);
    reentrantcy = true;
    _;
    reentrantcy = false;
  }

  constructor() Ownable(msg.sender) {
    defaultAddress = msg.sender;
    levelprice[1] = 200;
    levelprice[2] = 400;
    levelprice[3] = 800;
    levelprice[4] = 1600;
    levelprice[5] = 3200;
    refdirect = 400;
    refdividend[1] = 50;
    refdividend[2] = 100;
    refdividend[3] = 200;
    refdividend[4] = 250;
    //initial
    registeration(defaultAddress,address(0));
  }

  function isRegistered(address account) external view returns (bool) {
    return users[account].registered;
  }

  function registerationExt(address ref) external payable noReentrant() returns (bool) {
    require(ref!=address(0),"registeration fail : referral address cannot be zero");
    require(!users[msg.sender].registered,"registeration fail : already registered");
    require(msg.value>=levelprice[1],"registeration fail : ext not enought fund");

    registeration(msg.sender,ref);

    return true;
  }

  function getPairTree(address account,uint256 level) public view returns(address, address[] memory) {
    return (
      pairs[account][level].currentreferral,
      pairs[account][level].refferee
    );
  }

  function registeration(address register,address ref) internal {

    registered = registered.add(1);

    getidfromaddress[register] = registered;
    getaddressfromid[registered] = register;

    users[register].registered = true;
    users[register].referral = ref;
    users[register].activeLevels[1] = true;

    if(pairs[ref][1].refferee.length<2){
      pairs[ref][1].refferee.push(register);
      pairs[register][1].currentreferral = ref;
    }else{
      address checkleft = pairs[ref][1].refferee[0];
      address checkright = pairs[ref][1].refferee[1];
      if(pairs[checkleft][1].refferee.length<2){
        pairs[checkleft][1].refferee.push(register);
        pairs[register][1].currentreferral = checkleft;
      }else if(pairs[checkright][1].refferee.length<2){
        pairs[checkright][1].refferee.push(register);
        pairs[register][1].currentreferral = checkright;
      }
    }
    
    safeTransfer(getETHrecaiver(ref),msg.value.mul(refdirect).div(1000));

    address currentref = pairs[register][1].currentreferral;

    safeTransfer(getETHrecaiver(currentref),msg.value.mul(refdividend[1]).div(1000));
    safeTransfer(getETHrecaiver(users[currentref].referral),msg.value.mul(refdividend[2]).div(1000));
    safeTransfer(getETHrecaiver(users[users[currentref].referral].referral),msg.value.mul(refdividend[3]).div(1000));
    safeTransfer(getETHrecaiver(users[users[users[currentref].referral].referral].referral),msg.value.mul(refdividend[4]).div(1000));

  }

  function getETHrecaiver(address account) internal view returns (address) {
    if(account==address(0)){
      return defaultAddress;
    }else{
      return account;
    }
  }

  function safeTransfer(address recipient,uint256 amount) internal returns (bool) {
    (bool success, ) = recipient.call{ value : amount }("");
    require(success,"safe transfer fail!");
    return true;
  }

  function recaive() public payable {}

}