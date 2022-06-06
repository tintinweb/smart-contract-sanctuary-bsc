/**
 *Submitted for verification at BscScan.com on 2022-06-06
*/

//SPDX-License-Identifier: UNLICENSED

  pragma solidity ^0.8.0;

  interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function burn(uint256 value) external returns (bool);
    event Transfer(address indexed from,address indexed to,uint256 value);
    event Approval(address indexed owner,address indexed spender,uint256 value);
  }

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
      // assert(b > 0); // Solidity automatically throws when dividing by 0
      uint256 c = a / b;
      // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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
  }

  contract STRKPresale{
  struct User {
    uint256 id;
    address user;
    uint256 total_token;
    uint256 checkpoint;
    ROI[]  roi;
    uint256 total_claimed;
  }
  
  struct ROI {
    uint256 amount;
    uint256 timestamp;
  }
  
  struct Plan {
    uint8 monthly_roi;
    uint256 total_days;
  }

  using SafeMath for uint256;
  
  address payable public owner;
  uint256 public token_price;    
  uint256 public MINIMUM_BUY;
  uint256 public MAXIMUM_BUY;
  mapping(address => User) public users;
  mapping(uint256 => address) public idToAddress;
  uint256 public lastUserId;
  uint256 public totaltokenbuy;
  uint256 public totalclaimedToken;
  Plan public plan;
  bool public isBuyEnable;
  IERC20 public STRK; 
  IERC20 public BUSD;

  uint256 public PERCENTS_DIVIDER = 100;
  uint256 public TIME_STEP = 60;  //30 days
  uint256 public locking_period = 300; // 70 days
  
  event Registration(uint256 userid, address user);
  event TokenBuy(address indexed user,uint256 amount);
  event ClaimToken (address indexed user ,uint256 amount);
  event TokenWithdraw (address indexed user, uint256 amount);

  modifier onlyOwner {
      require(msg.sender==owner," Ownable function call!");
      _;
  }

  constructor(address payable ownerAddress,IERC20 _STRK,IERC20 _BUSD,uint256 _tokenprice ,uint256 _minbuy,uint256 _maxbuy)  {
          owner = ownerAddress;  
          STRK  = _STRK;
          BUSD = _BUSD;
          token_price = _tokenprice;
          MINIMUM_BUY = _minbuy;
          MAXIMUM_BUY = _maxbuy;
          lastUserId = 10000;
          isBuyEnable= true;
          users[owner].id = lastUserId;
          users[owner].user = owner;
          idToAddress[lastUserId] = owner;
          plan = Plan(8, 750);
          ++lastUserId;
  }
      
  function BuyToken(uint256  tokenQty) public payable {
      require(tokenQty >= MINIMUM_BUY,"Invalid minimum quatity");
      require(tokenQty <= MAXIMUM_BUY,"Invalid maximum quatity");
      require(isBuyEnable,"Buy Token not active !");
      uint256 usd_amt = (tokenQty*token_price)/1e18; 
      require(BUSD.allowance(msg.sender,address(this)) >= usd_amt,"exceed allowance !");
      require(BUSD.balanceOf(msg.sender) >= usd_amt,"Low Balance!");

      if(!isUserExists(msg.sender)){
        users[msg.sender].id = lastUserId;
        idToAddress[lastUserId] = msg.sender;
        users[msg.sender].user = msg.sender;  
        emit Registration(lastUserId,msg.sender); 
         ++lastUserId; 
      }

      users[msg.sender].total_token = users[msg.sender].total_token.add(tokenQty);
      totaltokenbuy = totaltokenbuy.add(tokenQty);
      users[msg.sender].roi.push(ROI(tokenQty,block.timestamp.add(locking_period)));
      BUSD.transferFrom(msg.sender,address(this),usd_amt);
      emit TokenBuy(msg.sender,tokenQty);
  }

  function getUserDividends(address userAddress) public view returns (uint256) {
    User memory user = users[userAddress];

    uint256 totalAmount;

    for (uint256 i = 0 ; i < user.roi.length; i++) {
      uint256 finish = user.roi[i].timestamp.add(plan.total_days);
      if (user.checkpoint < finish) {
        uint256 share = user.roi[i].amount.mul(plan.monthly_roi).div(PERCENTS_DIVIDER);
        uint256 from = user.roi[i].timestamp > user.checkpoint ? user.roi[i].timestamp : user.checkpoint;
        uint256 to = finish < block.timestamp ? finish : block.timestamp;
        if (from < to) {
          totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
        }
      }
    }

    return totalAmount;
  }

  function claimBuyTokens() external {
      require(isUserExists(msg.sender), "User not Exist !");
      uint256 roi = getUserDividends(msg.sender);
      STRK.transfer(msg.sender,roi);
      users[msg.sender].checkpoint = block.timestamp;
      users[msg.sender].total_claimed = users[msg.sender].total_claimed.add(roi);
      totalclaimedToken+=roi;
      emit ClaimToken(msg.sender , roi);
  }

  function isUserExists(address user) public view returns (bool) {
      if(users[user].id!=0)
        return true;
      else 
        return false;
  } 
    
  function getUserTotalTimesBuy (address user) external view returns (uint256)   {
      return users[user].roi.length;
  }


  function getUserRoiDetails (address user ,uint256 roi_index) external view returns (uint256 ,uint256) {
    return (users[user].roi[roi_index].amount,users[user].roi[roi_index].timestamp);
  }

  function withdrawToken (IERC20 _token,uint256 amount) onlyOwner external {
      _token.transfer(owner , amount);
  }  

  function withdrawBNB (uint256 amount ) onlyOwner external {
    owner.transfer(amount);
  }
    
  function settings (uint256 _value, uint8 _type) onlyOwner external {
      if(_type == 1)
      token_price = _value;
      else if(_type == 2)
      MINIMUM_BUY = _value;
      else 
      MAXIMUM_BUY = _value;
  }

  function transferOwnership(address payable _newOwner) external onlyOwner {
    owner =_newOwner;
  }


  function AdminTokenBuy(uint256  tokenQty ,address _userAddress) public onlyOwner  {
      require(tokenQty >= MINIMUM_BUY,"Invalid minimum quatity");
      require(tokenQty <= MAXIMUM_BUY,"Invalid maximum quatity");
      require(isBuyEnable,"Buy Token not active !");
      // require(BUSD.allowance(msg.sender,address(this)) >= usd_amt,"exceed allowance !");
      // require(BUSD.balanceOf(msg.sender) >= usd_amt,"Low Balance!");

      if(!isUserExists( _userAddress )){
        users[_userAddress].id = lastUserId;
        idToAddress[lastUserId] = _userAddress;
        users[_userAddress].user = _userAddress;  
        emit Registration(lastUserId,_userAddress); 
         ++lastUserId; 
      }

      users[_userAddress].total_token = users[_userAddress].total_token.add(tokenQty);
      totaltokenbuy = totaltokenbuy.add(tokenQty);
      users[_userAddress].roi.push(ROI(tokenQty,block.timestamp.add(locking_period)));
      // BUSD.transferFrom(_userAddress,address(this),usd_amt);
      emit TokenBuy(_userAddress,tokenQty);
  }

  receive () external payable {}
}