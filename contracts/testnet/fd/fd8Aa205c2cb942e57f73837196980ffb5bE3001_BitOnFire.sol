/**
 *Submitted for verification at BscScan.com on 2022-05-24
*/

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;
// SPDX-License-Identifier: MIT

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function ceil(uint a, uint m) internal pure returns (uint r) {
    return (a + m - 1) / m * m;
  }
}

contract Owned {
        address payable public owner;
    
        event OwnershipTransferred(address indexed _from, address indexed _to);
    
        constructor() public {
            owner = msg.sender;
        }
    
        modifier onlyOwner {
            require(msg.sender == owner);
            _;
        }
        
        function getOwner() public view returns(address){
        return owner;
        }
    
        function transferOwnership(address payable _newOwner) public onlyOwner {
            owner = _newOwner;
            emit OwnershipTransferred(msg.sender, _newOwner);
        }
    }


interface IBEP20 {
     function approve(address to, uint256 tokens) external returns (bool success);
     function decimals() external view returns (uint256);
    function transfer(address to, uint256 tokens) external returns (bool success);
    function burnTokens(uint256 _amount) external;
    function balanceOf(address tokenOwner) external view returns (uint256 balance);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function mint(address _to,uint256 amount) external returns (bool success);
    function transferOwnership(address _newOwner) external returns (bool success);
}

contract BitOnFire is Owned {

    using SafeMath for uint256;
        
    IBEP20 public renBTC;
    IBEP20 public FIRE;

    struct UserStruct{
        bool isExist;
        address referrer;
        address[] referral;
        uint256 amount;
        uint256 earned;
        uint256 lastSignedTime;
        uint256 validity;
        uint256 reserve;
        bool isBlocked;
        bool isautoSubscriped;
    }

    mapping (address => UserStruct) public users;
    mapping (address => address) public _parent;

    uint256[] public rewardLevel;
    address[] public userCount;

    uint256 public SUBSCRIPTION_FEE;
    uint256 public VALIDITY_PEROID = 365 days;   // one year

    event Rewards(address indexed _from, address indexed _referrer, uint256 amount);
    event Claim(address indexed _from,address indexed _to,uint256 amount);

    constructor(IBEP20 _renBTC,IBEP20 _fire) public{
      rewardLevel.push(5000); // 50%
      rewardLevel.push(3000); // 30%
      rewardLevel.push(1000); // 10%  
      renBTC = _renBTC;
      FIRE = _fire;

    }

    function register(address _referrer,uint256 _amount) public returns (UserStruct memory) {
         require(!users[msg.sender].isExist,"User already Exists !");
         _referrer = users[_referrer].isExist ? _referrer : getOwner();
         FIRE.transferFrom(msg.sender,address(this),_amount);
           users[msg.sender] = UserStruct({
            isExist : true,
            referrer : _referrer,
            referral: new address[](0),
            amount: 0,
            earned: 0,
            lastSignedTime: block.timestamp,
            validity: block.timestamp.add(VALIDITY_PEROID),
            reserve: 0,
            isBlocked: false,
            isautoSubscriped: false
          });
        _parent[msg.sender] = _referrer;
        users[_referrer].referral.push(msg.sender);
        userCount.push(msg.sender);
        rewardDistribution(msg.sender,_amount);
        return users[msg.sender];
    }

    function getUserInfo(address _user) public view returns (UserStruct memory){
      return users[_user];
    }
  
    function rewardDistribution(address _user,uint256 _amount)internal{
      for(uint256 i=0; i < rewardLevel.length;i++){
        _user = users[_parent[_user]].isExist && !users[_parent[_user]].isBlocked ? _parent[_user] : getOwner();
        uint256 toTransfer = block.timestamp > users[_user].validity ? 0 :  _amount.mul(rewardLevel[i]).div(10000);
        uint256 toReserve = block.timestamp > users[_user].validity ? _amount.mul(rewardLevel[i]).div(10000) : 0;
        users[_user].amount = users[_user].amount.add(toTransfer);
        users[_user].reserve = users[_user].reserve.add(toReserve);
        emit Rewards(address(this),_user,toTransfer);
    }
    }

    function paySubscription(address _from, uint256 _amount) internal {
      require(!users[_from].isBlocked, "Your Account is Blocked");
      users[_from].validity = block.timestamp.add(VALIDITY_PEROID);
      users[_from].amount = users[_from].amount.add(users[_from].reserve);
      users[_from].reserve = 0;
      FIRE.transferFrom(msg.sender,address(this),_amount);
      rewardDistribution(_from,_amount);
    }

    function checkAutoSubscription(address _from) internal {
      require(!users[_from].isautoSubscriped, "Your Account is not Auto Subscribed");
      if(block.timestamp > users[_from].validity && users[_from].amount >= SUBSCRIPTION_FEE){
          paySubscription(_from,SUBSCRIPTION_FEE);
          users[_from].amount =  users[_from].amount.sub(SUBSCRIPTION_FEE);
      }
    }

    function paySubscriptionFee(uint256 _amount) public {
      require(_amount >= SUBSCRIPTION_FEE , "Insufficient token Fee !");
      require(block.timestamp > (users[msg.sender].validity.sub(2 days)),"Your Validity is still on !");
      paySubscription(msg.sender,_amount);
    }

    function claim(uint256 _amount) public {
      require(users[msg.sender].validity > block.timestamp, "Your Subscription Validity is ended !");
      require(!users[msg.sender].isBlocked, "Your Account is Blocked");
      require(users[msg.sender].amount >= _amount, "Value Exceeds Balance !");
      FIRE.transfer(msg.sender,_amount);
      users[msg.sender].amount =users[msg.sender].amount.sub(_amount);
      emit Claim(address(this),msg.sender,_amount);
    }

    

}