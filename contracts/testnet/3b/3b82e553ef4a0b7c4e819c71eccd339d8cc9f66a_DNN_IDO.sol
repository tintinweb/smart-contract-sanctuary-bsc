// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./SafeMath.sol";
import "./IERC20.sol";
contract DNN_IDO {
    using SafeMath for uint256; 
    address  _owner;

    address  feeReceivers;

    address defaultRefer;

    uint256 public constant minDeposit = 30e18;

    uint256 public constant maxDeposit = 100e18;

    IERC20 public usdt;

    uint256 public leader;

    uint256 public startTime;
    
    uint256 public totalUser; 

    uint256 private constant referDepth = 11;

   struct Profit {
       address user;
       uint256 profit;
   }





    struct UserInfo {

        address user;

        address referrer;

        uint256 level;

        uint256 totalDeposit;

        uint256 teamNum;

        uint256 start;

        bool freeze;
          
        uint256 totalRevenue;
    }



    mapping(address=>UserInfo) public userInfo;

    mapping(address => mapping(uint256 => address[])) public teamUsers;

    struct RewardInfo{
            
       uint256 directs;

       uint256 community;
    }

    mapping(address=>RewardInfo) public rewardInfo;
    
    modifier onlyOwner() {
        require(msg.sender == _owner, "Permission denied"); _;
    }

    event Register(address user, address referral);
    event Deposit(address user, uint256 amount);
   
    constructor(address _usdtAddr, address _defaultRefer, address  _feeReceivers,uint256 _startTime) public {
        usdt = IERC20(_usdtAddr);
        feeReceivers = _feeReceivers;
        startTime = _startTime;
        defaultRefer = _defaultRefer;
        _owner = msg.sender;
    }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }





    function register(address _referral) external {  

        require(userInfo[_referral].totalDeposit > 0 || _referral == defaultRefer, "invalid refer");
        UserInfo storage user = userInfo[msg.sender];

        require(user.referrer == address(0), "referrer bonded");

        user.referrer = _referral; 

        user.start = block.timestamp;        

        totalUser = totalUser.add(1);
        
        emit Register(msg.sender, _referral);
    }



    function withdrawal(address _user) external {  
         require(block.timestamp>startTime,"The time has not arrived");   
         require(_user!= address(0),"address is error");
         require(rewardInfo[_user].community>0,"Insufficient amount");
         usdt.transferFrom(address(this),_user,rewardInfo[_user].community.mul(9).div(10));
         rewardInfo[_user].community = 0;
         usdt.transferFrom(address(this),feeReceivers,rewardInfo[_user].community.mul(1).div(10));
        emit Withdrawal(msg.sender, rewardInfo[_user].community);
    }

    event Withdrawal(address sender,uint256 amount);

    function deposit(uint256 _amount) external {     
        UserInfo storage user = userInfo[msg.sender];      
        require(user.referrer != address(0), "register first");
        require(userInfo[user.referrer].totalDeposit >0||user.referrer==defaultRefer, "Referrer Must be valid");
       
        require(_amount >= minDeposit && _amount <= maxDeposit, "amount is error"); 
        usdt.transferFrom(msg.sender,feeReceivers, _amount);
        if(user.referrer!=defaultRefer){
        uint256 referrerProfit =   _amount.mul(10).div(100);
        usdt.transferFrom(msg.sender,user.referrer,referrerProfit);
        emit  DirectReward(user.referrer,referrerProfit);
        user.totalDeposit =  user.totalDeposit.add(_amount);
        rewardInfo[msg.sender].directs =  rewardInfo[msg.sender].directs.add(referrerProfit);  
        }       
        _deposit(msg.sender, _amount);
        emit Deposit(msg.sender, _amount);
    }

   event DirectReward(address upline,uint256 amount);




  function _deposit(address _user,uint256 _amount) private{
         _distributeReward(_user,_amount);
        // _updateTeamNum(_user);   
  }

  function _distributeReward(address _user,uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
         for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){
                if(i>0&&userInfo[upline].level==1){
                   rewardInfo[upline].community = rewardInfo[upline].community.add(_amount.mul(5).div(100));
                }
                if(upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            }

            else{
                break;
            }
        }

  }

 function _updateTeamNum(address _user) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)&&i<3){
                userInfo[upline].teamNum = userInfo[upline].teamNum.add(1);
                teamUsers[upline][i].push(_user);
                _updateLevel(upline);
                if(upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }

    function _updateLevel(address _user) private {
        UserInfo storage user = userInfo[_user];
        uint256 levelNow = _calLevelNow(_user);
        if(levelNow > user.level){ 
            user.level = levelNow;
        }
    }

    function _calLevelNow(address _user) private view returns(uint256 levelNow) { 
        UserInfo storage user = userInfo[_user];
        uint256 total = user.totalDeposit;
        uint256 levelNow;
        if(total >= 30*1e18){
         if(user.teamNum>=30){
         levelNow = 1;
         }   
        return levelNow;
    }
    }


    function getTeamUsersLength(address _user, uint256 _layer) external view returns(uint256) {
        return teamUsers[_user][_layer].length;
    }

 
}