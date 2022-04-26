/**
 *Submitted for verification at BscScan.com on 2022-04-26
*/

//SPDX-License-Identifier: UNLICENSED

  pragma solidity >= 0.5.0;

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
      uint256 total_withdraw;
    }
    
    struct ROI {
      uint256 amount;
      uint256 timestamp;
      bool isPricipleWithdraw;
    }
    
    struct Plan {
      uint8 monthly_roi;
      uint256 locking_period;
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
    Plan public plan;

    IERC20 public STRK; 

    uint256 public PERCENTS_DIVIDER = 100;
    uint256 public TIME_STEP = 30 days;

    event TokenBuy(address indexed user,uint256 amount);
    event ClaimToken (address indexed user ,uint256 amount);
    event TokenWithdraw (address indexed user, uint256 amount);

    modifier onlyOwner {
        require(msg.sender==owner," Ownable function call!");
        _;
    }

    constructor(address payable ownerAddress,IERC20 _STRK,uint256 _tokenprice ,uint256 _minbuy,uint256 _maxbuy) public {
          owner = ownerAddress;  
          STRK  = _STRK;
          token_price = _tokenprice;
          MINIMUM_BUY = _minbuy;
          MAXIMUM_BUY = _maxbuy;
          lastUserId = 1;
          users[owner].id = lastUserId;
          users[owner].user = owner;
          idToAddress[lastUserId] = owner;
          plan = Plan(8,600);
          ++lastUserId;
    }
      
    function BuyToken(uint256  tokenQty) public payable {
      require(tokenQty >= MINIMUM_BUY,"Invalid minimum quatity");
      require(tokenQty <= MAXIMUM_BUY,"Invalid maximum quatity");
      uint256 bnb_amt= (tokenQty*token_price)/1e18;   
      require(msg.value >= bnb_amt,"Invalid buy amount");
      if(!isUserExists(msg.sender)){
        users[msg.sender].id = lastUserId;
        idToAddress[lastUserId] = msg.sender;
        ++lastUserId;
        users[msg.sender].user = msg.sender;
      }

      users[msg.sender].total_token = users[msg.sender].total_token.add(tokenQty);
      totaltokenbuy = totaltokenbuy.add(tokenQty);  
      users[msg.sender].roi.push(ROI(tokenQty,block.timestamp,false));

      emit TokenBuy(msg.sender,tokenQty);
    }

	function getUserDividends(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount;

		for (uint256 i = 0; i < user.roi.length; i++) {
			uint256 finish = user.roi[i].timestamp.add(plan.locking_period);
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

    function claimRoi() external payable{
      require(isUserExists(msg.sender), "User not Exist !");
      uint256 roi = getUserDividends(msg.sender);
      STRK.transfer(msg.sender,roi);
      users[msg.sender].checkpoint = block.timestamp;
      users[msg.sender].total_withdraw = users[msg.sender].total_withdraw.add(roi);
      emit ClaimToken(msg.sender , roi);
    }

    function WithdrawBuyedToken () external payable {
      require(isUserExists(msg.sender),"User not Exist!");
      uint256 total = 0;

      for(uint256 i = 0; i<users[msg.sender].roi.length; i++) {
        if(users[msg.sender].roi[i].timestamp.add(plan.locking_period)<block.timestamp){
          total=total.add(users[msg.sender].roi[i].amount);
          users[msg.sender].roi[i].isPricipleWithdraw =true;
        }
      }
      STRK.transfer(msg.sender , total);
      emit TokenWithdraw (msg.sender,total);
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
    
    function getUserRoiDetails (address user ,uint256 roi_index) external view returns (uint256 ,uint256 ,bool) {
         return (users[user].roi[roi_index].amount,users[user].roi[roi_index].timestamp, users[user].roi[roi_index].isPricipleWithdraw);
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

    receive () external payable {}
  }