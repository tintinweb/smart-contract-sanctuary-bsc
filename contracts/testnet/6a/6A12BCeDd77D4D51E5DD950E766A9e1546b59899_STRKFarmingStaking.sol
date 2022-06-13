/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

pragma solidity ^0.8.0;

//SPDX-License-Identifier: UNLICENSED

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


contract STRKFarmingStaking {

    using SafeMath for uint256;

    address payable public owner;
    uint256 public MIN_STAKING_AMOUNT;

    mapping(address => User) public users;

    uint256 public lastUserId;

    mapping(uint8=>Plan) public plans;
    bool public     isStakingEnable;
    uint256 public totalStaked;
    uint256 public totalRewardClaimed;
    uint256 public totalHarvest;
    IERC20 public STRK; 

    uint256 public PERCENTS_DIVIDER = 1000;
    // uint256 public TIME_STEP = 30 days;
    uint256 public TIME_STEP = 60;
    mapping(uint8=>uint256) public locking_period;

    struct User {
      uint256 total_staking;
      uint256 checkpoint;
      ROI[] roi;
      uint256 total_withdraw;
    }
    
    struct ROI {
      uint8 planid;
      uint256 amount;
      uint256 timestamp;
      bool isPricipleWithdraw;
      uint256 unstaketime;
    }
    
    struct Plan {
      uint8 planid;
      uint8 monthly_roi;
      uint256 total_days;
    }
  
    modifier onlyOwner {
      require(msg.sender==owner," Ownable function call!");
      _;
    }

   event Staked(address indexed user , uint256 amount,uint8 planid);
   event Harvest(address indexed user, uint256 amount);
   event Claimed(address indexed user, uint256 amount);

   constructor (address payable ownerAddress,IERC20 _STRK,uint256 _minstaking){
       plans[1]=Plan(1,58,720);
       plans[2]=Plan(2,104,720);
       plans[3]=Plan(3,166,720);
    //    plans[1]=Plan(1,58,365 days);
    //    plans[2]=Plan(2,104,365 days);
    //    plans[3] =Plan(3,166,365 days);
       locking_period[1]=300;
       locking_period[2]=600;
       locking_period[3]=720;
    //    locking_period[1]=30 days;
    //    locking_period[2]=180 days;
    //    locking_period[3]=365 days;
       STRK = _STRK;
       MIN_STAKING_AMOUNT = _minstaking;
       owner = ownerAddress; 
   }

  function stake(uint256 amount,uint8 planid) external payable {
    require(STRK.allowance(msg.sender,address(this))>=amount,"Exceed :: allowance");
    require(STRK.balanceOf(msg.sender)>=amount,"Exceed :: Low Balance !");
    require(planid<4 && planid>=1, "Invalid plan id");
    STRK.transferFrom(msg.sender,address(this),amount);
    users[msg.sender].total_staking+=amount;
    totalStaked+=amount;
    users[msg.sender].roi.push(ROI(planid,amount,block.timestamp,false,0));
    emit Staked(msg.sender,amount,planid);
  }

  function getAvilableForHarvest(address user) public view returns (uint256 amount) {
      for(uint256 i = 0; i<users[user].roi.length; i++) {
          ROI memory _roi = users[user].roi[i];
          if(_roi.timestamp.add(locking_period[_roi.planid])<block.timestamp && _roi.isPricipleWithdraw!=true){
          amount=amount.add(_roi.amount);
        }
    }
  }

  function getStakedTokens(address user) public view returns (uint256 amount) {
      for(uint256 i = 0; i<users[user].roi.length; i++) {
          ROI memory _roi = users[user].roi[i];
          if(_roi.isPricipleWithdraw!=true){
          amount=amount.add(_roi.amount);
        }
    }
  }

  function getUserTotalTimesStake (address user) external view returns (uint256)   {
      return users[user].roi.length;
  }
    
  function getUserRoiDetails (address user ,uint256 roi_index) external view returns (uint8,uint256 ,uint256 ,bool,uint256) {
    return (users[user].roi[roi_index].planid,users[user].roi[roi_index].amount,users[user].roi[roi_index].timestamp, users[user].roi[roi_index].isPricipleWithdraw,users[user].roi[roi_index].unstaketime);
  }

  function harvest () external payable {
    uint256 total = 0;

    for(uint256 i = 0; i<users[msg.sender].roi.length; i++) {
      ROI memory _roi = users[msg.sender].roi[i];
      if(_roi.timestamp.add(locking_period[_roi.planid])<block.timestamp && _roi.isPricipleWithdraw!=true){
        total=total.add(_roi.amount);
        users[msg.sender].roi[i].isPricipleWithdraw = true;
        users[msg.sender].roi[i].unstaketime = block.timestamp;
      }
    }
    STRK.transfer(msg.sender , total);
    totalHarvest += total;
      uint256 roi = getUserDividends(msg.sender);
      STRK.transfer(msg.sender,roi);
      users[msg.sender].checkpoint = block.timestamp;
      users[msg.sender].total_withdraw = users[msg.sender].total_withdraw.add(roi);
      totalRewardClaimed+=roi;
      emit Claimed(msg.sender , roi);
    emit Harvest (msg.sender, total);
  }

   function getUserDividends(address user) public view returns (uint256) {
		User memory _user = users[user];

		uint256 totalAmount;

		for (uint256 i = 0 ; i < _user.roi.length; i++) {
         ROI memory _roi = _user.roi[i];
			uint256 finish = _roi.timestamp.add(plans[_roi.planid].total_days);
			if (_user.checkpoint < finish) {
				uint256 share = _roi.amount.mul(plans[_roi.planid].monthly_roi).div(PERCENTS_DIVIDER);
				uint256 from = _roi.timestamp > _user.checkpoint ? _roi.timestamp : _user.checkpoint;
				uint256 to = finish < block.timestamp ? finish : block.timestamp;
				if (from < to) {
					totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
				}
			}
		}

		return totalAmount;
	}

  function claimTokens() external payable{
      require(users[msg.sender].total_staking>0, "User not Exist !");
      uint256 roi = getUserDividends(msg.sender);
      STRK.transfer(msg.sender,roi);
      users[msg.sender].checkpoint = block.timestamp;
      users[msg.sender].total_withdraw = users[msg.sender].total_withdraw.add(roi);
      totalRewardClaimed+=roi;
      emit Claimed(msg.sender , roi);
  }

  function withdrawToken (IERC20 _token,uint256 amount) onlyOwner external {
      _token.transfer(owner , amount);
  }  

  function withdrawBNB (uint256 amount ) onlyOwner external {
    owner.transfer(amount);
  }
    
  function transferOwnership(address payable _newOwner) external onlyOwner {
    owner =_newOwner;
  }

    receive () external payable {}
 
 }