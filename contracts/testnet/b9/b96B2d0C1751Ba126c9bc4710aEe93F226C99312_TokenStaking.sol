/**
 *Submitted for verification at BscScan.com on 2022-07-03
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-28
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-31
*/

pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

library SafeMath {
   
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

 
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }


    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

   
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }


    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }


    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }


    function owner() public view virtual returns (address) {
        return _owner;
    }


    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }


    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }


    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract TokenStaking is Ownable {
    using SafeMath for uint256;

    struct User {
        uint256 id;
        address user;
        address referral;
        uint256 ttlStaked;
        uint256 ttlUnstaked;
        uint256 referralIncome;
        uint256 ttlClaimed;
        uint256 lastClaimTime;
        uint256 patnerCount;
        Roi[] roi;
    }

    struct Roi {
        uint8 planId;
        uint256 amount;
        uint8 monthlyShare;
        uint8 _lockId;
        bool isUnstake;
        uint256 unstaketime;
        uint256 timestamp;
        uint256 expiry;
    }

    struct Plan {
        uint8 planId;
        uint256 minAmount;
        uint256 maxAmount;
        uint8 monthlyShare;
    }

    IERC20 public _token;
    uint256 public referShare;
    mapping(uint256=>address) public idToAddress;
    mapping(address=>User) public users;
    mapping(uint8=>uint256) private _lockperiod;
    mapping(uint8=>Plan) private plans;
    uint8 public PERCENT_DIVIDER = 100;
    // uint256 private TIME_STEP=30 days;
    uint256 private TIME_STEP= 600;
    uint256 private ONE_YEAR= 600;
    uint256 public MINIMUM_AMOUNT;
    uint256 public MAXIMUM_AMOUNT; 
    uint256 public lastUserId;
    uint256 public ttlStaked;
    uint256 public ttlUnstaked;
    uint256 public ttlRoiClaimed;

    event Stake(address user, uint256 amount,uint8 planid );
    event UnStake(address user, uint256 amount);
    event ClaimROI(address user, uint256 amount);
    event ReferralIncome(address sender, address recipient, uint256 amount);
    event Registration(address user,address referral,uint256 userId, uint256 RefferalId);

    constructor(IERC20 __token) {
        _token = __token;
        referShare = 10;
        plans[1]=Plan(1,100*1e18,600*1e18,5);
        plans[2]=Plan(2,650*1e18,5000*1e18,6);
        plans[3]=Plan(3,5100*1e18,20000*1e18,7);
        plans[4]=Plan(4,21000*1e18,35000*1e18,8);
        plans[5]=Plan(5,40000*1e18,60000*1e18,9);
        plans[6]=Plan(6,60000*1e18,1000000*1e18,10);
        // _lockperiod[1]=180 days;
        // _lockperiod[2]=365 days;
        _lockperiod[1]=300;
        _lockperiod[2]=600;
        MAXIMUM_AMOUNT = 1000000*1e18;
        MINIMUM_AMOUNT = 100*1e18;
        lastUserId = 999;
        users[owner()].id = lastUserId;
        users[owner()].user = owner();
        users[owner()].referral = address(0);
        idToAddress[lastUserId]=owner();
        ++lastUserId;
    }

    function stake(uint256 _amount, address _refrral,uint8 _lockId) external {
        require(MINIMUM_AMOUNT<= _amount,"Staking:: staking amount low.");
        require(MAXIMUM_AMOUNT>= _amount,"Staking:: staking amount high.");
        require(_token.balanceOf(_msgSender())>= _amount,"Staking:: user has low balance!");
        require(_lockId==1||_lockId==2,"Staking :: Invalid Locking Id!");
        require(_token.allowance(_msgSender(),address(this))>= _amount,"Staking:: allowance exceed!");
        address user = _msgSender();
        if(!isUserExists(user)){
            registration(user,_refrral);
        }
        address reff = users[user].referral;
        _token.transferFrom(_msgSender(),address(this),_amount);
        users[user].ttlStaked = users[user].ttlStaked.add(_amount);
        if(reff!=address(0)){
            users[reff].referralIncome = users[reff].referralIncome.add(_amount.mul(referShare).div(PERCENT_DIVIDER));
            _token.transfer(reff,_amount.mul(referShare).div(PERCENT_DIVIDER));  
            emit ReferralIncome(user ,reff,_amount.mul(referShare).div(PERCENT_DIVIDER));
        }
        uint8 planid = getPlanIdByAmount(_amount);
        require(planid!=0,"Invalid Amount");
        users[user].roi.push(Roi(planid,_amount,plans[planid].monthlyShare,_lockId,false,0,block.timestamp,block.timestamp.add(ONE_YEAR)));
        ttlStaked+=_amount;
        emit Stake( user,  _amount, planid );
    }


    function getPlanIdByAmount(uint256 amount) public view returns(uint8 planid){
        for(uint8 i=1;i<7;i++) {
            if(plans[i].minAmount<=amount && plans[i].maxAmount>=amount) {
                planid = plans[i].planId;
            }
        }
        return planid;
    }

  function registration (address user,address referral) private {
        require(isUserExists(referral),"Staking:: Refferal not exist!");
        require(!isUserExists(user),"Staking:: User already exist!");
        users[user].id = lastUserId;
        users[user].user = user;
        users[user].referral = referral;
        users[referral].patnerCount=users[referral].patnerCount.add(1);
        idToAddress[lastUserId]=user;
        ++lastUserId;
        emit Registration(user,referral,lastUserId, users[referral].id);
  }

  function getAvilableForHarvest(address user) public view returns (uint256 amount) {
        for(uint256 i = 0; i<users[user].roi.length; i++) {
          Roi memory _roi = users[user].roi[i];
           if(_roi.timestamp.add(_lockperiod[_roi._lockId])<block.timestamp && _roi.isUnstake!=true){
                amount=amount.add(_roi.amount);
            }
        }
  }

  function getStakedTokens(address user) public view returns (uint256 amount) {
      for(uint256 i = 0; i<users[user].roi.length; i++) {
          Roi memory _roi = users[user].roi[i];
          if(_roi.isUnstake!=true){
          amount=amount.add(_roi.amount);
        }
    }
  }

  function getUserTotalTimesStake (address user) external view returns (uint256)   {
      return users[user].roi.length;
  }
    
  function getUserRoiDetails (address user ,uint256 roi_index) external view returns (uint8,uint256 ,uint256 ,bool,uint256) {
    return (users[user].roi[roi_index].planId,users[user].roi[roi_index].amount,users[user].roi[roi_index].timestamp, users[user].roi[roi_index].isUnstake,users[user].roi[roi_index].monthlyShare);
  }

  function harvest () external payable {
    uint256 total = 0;

    for(uint256 i = 0; i<users[msg.sender].roi.length; i++) {
      Roi memory _roi = users[msg.sender].roi[i];
      if(_roi.timestamp.add(_lockperiod[_roi._lockId])<block.timestamp && _roi.isUnstake!=true){
        total=total.add(_roi.amount);
        users[msg.sender].roi[i].isUnstake = true;
        users[msg.sender].roi[i].unstaketime = block.timestamp;
        users[msg.sender].roi[i].expiry=block.timestamp;
      }
    }
    _token.transfer(msg.sender , total);
    ttlUnstaked += total;
    emit UnStake(msg.sender, total);
  }

   function getUserDividends(address user) public view returns (uint256) {
		User memory _user = users[user];
		uint256 totalAmount;
		for (uint256 i = 0 ; i < _user.roi.length; i++) {
            Roi memory _roi = _user.roi[i];
			uint256 finish = _roi.timestamp.add(_roi.expiry);
			if (_user.lastClaimTime < finish) {
				uint256 share = _roi.amount.mul(plans[_roi.planId].monthlyShare).div(PERCENT_DIVIDER);
				uint256 from = _roi.timestamp > _user.lastClaimTime ? _roi.timestamp : _user.lastClaimTime;
				uint256 to = finish < block.timestamp ? finish : block.timestamp;
				if (from < to) {
					totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
				}
			}
		}

		return totalAmount;
   }

  function claimTokens() external payable{
      require(users[msg.sender].ttlStaked>0, "User not Exist !");
      uint256 roi = getUserDividends(msg.sender);
      _token.transfer(msg.sender,roi);
      users[msg.sender].lastClaimTime = block.timestamp;
      users[msg.sender].ttlClaimed = users[msg.sender].ttlClaimed.add(roi);
      ttlRoiClaimed+=roi;
      emit ClaimROI(msg.sender , roi);
  }

    function withdrawToken (IERC20 token,uint256 amount) onlyOwner external {
        token.transfer(owner() , amount);
    }  

    function withdrawBNB (uint256 amount ) onlyOwner external {
        payable(owner()).transfer(amount);
    }
        

    receive () external payable {}
    function isUserExists(address _address) public view  returns(bool isExist){
        if(users[_address].id!=0) return true;
        return false;
    }
}