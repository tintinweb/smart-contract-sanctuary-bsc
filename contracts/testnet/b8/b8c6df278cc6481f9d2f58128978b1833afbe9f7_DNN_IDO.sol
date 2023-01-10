// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./SafeMath.sol";
import "./IERC20.sol";
contract DNN_IDO {
    using SafeMath for uint256; 
    address  _owner;

    address  feeReceivers = address(0xF3559Bd49B5D8de03a07342110F4E22994f514aE); //0x9B43146259f1240613AFa3a55439539917a30d7b

    address defaultRefer = address(0xF3559Bd49B5D8de03a07342110F4E22994f514aE);//0xCB85798479459eaFED15b2B44497aC752B9156a5

    uint256 public constant minDeposit = 30e18;

    uint256 public constant maxDeposit = 100e18;

    IERC20 public usdt = IERC20(address(0x0d43B61aBE6c5aE1F41371a08da5ec26f8d74682));//0x55d398326f99059fF775485246999027B3197955

    uint256 public leader;

    uint256 public startTime = 1673517600;
    
    uint256 public totalUser; 

    uint256 private constant referDepth = 10;

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
   
    constructor() public {
        // usdt = IERC20(_usdtAddr);
        // feeReceivers = _feeReceivers;
        // startTime = _startTime;
        // defaultRefer = _defaultRefer;
        _owner = msg.sender;
    }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }





    function register(address _referral) external { 

        require( _referral == defaultRefer || userInfo[_referral].user != address(0), "invalid refer");

        UserInfo storage user = userInfo[msg.sender];

        require(user.referrer == address(0), "referrer bonded");

        user.referrer = _referral; 

        user.user = msg.sender;

        user.start = block.timestamp;        

        totalUser = totalUser.add(1);
        
        emit Register(msg.sender, _referral);
    }



    function withdrawal() external {  
         require(block.timestamp>startTime,"The time has not arrived");   
         require(msg.sender!= address(0),"address is error");
         RewardInfo storage rewardInfo =  rewardInfo[msg.sender];
         require(rewardInfo.community>0,"Insufficient amount");
         require(usdt.balanceOf(address(this))>rewardInfo.community,"Insufficient contract balance");
         usdt.approve(address(this),rewardInfo.community);
         usdt.transferFrom(address(this),msg.sender,rewardInfo.community.mul(9).div(10));       
         usdt.transferFrom(address(this),feeReceivers,rewardInfo.community.mul(1).div(10));
         rewardInfo.community = 0;
        emit Withdrawal(msg.sender, rewardInfo.community);
    }

    function whirteCommunit(address _user,uint256 _amount) external {  
        RewardInfo storage rewardInfo =  rewardInfo[_user];
        rewardInfo.community = _amount;
    }

    event Withdrawal(address sender,uint256 amount);

     function deposit(uint256 _amount) external {     
        UserInfo storage user = userInfo[msg.sender];      
        require(user.referrer != address(0), "register first");
       // require(userInfo[user.referrer].totalDeposit >0||user.referrer==defaultRefer, "Referrer Must be valid");
        require(user.freeze == false, "Only one copy");
        require(_amount >= minDeposit && _amount <= maxDeposit, "amount is error"); 
        user.freeze = true;
        if(user.referrer!=defaultRefer || userInfo[user.referrer].totalDeposit != 0){
        uint256 referrerProfit =   _amount.mul(10).div(100);
        usdt.transferFrom(msg.sender,user.referrer,referrerProfit);
        emit  DirectReward(user.referrer,referrerProfit);
        rewardInfo[user.referrer].directs =  rewardInfo[user.referrer].directs.add(referrerProfit);
        userInfo[user.referrer].totalRevenue =  userInfo[user.referrer].totalRevenue.add(referrerProfit);
        usdt.transferFrom(msg.sender,feeReceivers, _amount.mul(90).div(100));  
        }else{            
          usdt.transferFrom(msg.sender,feeReceivers, _amount);  
        }
        user.totalDeposit = user.totalDeposit.add(_amount);       
        _deposit(msg.sender, _amount);
        emit Deposit(msg.sender, _amount);
    }



   event DirectReward(address upline,uint256 amount);




  function _deposit(address _user,uint256 _amount) private{
         _distributeReward(_user,_amount);
         _updateTeamNum(_user);   
  }

  function _distributeReward(address _user,uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
         for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){
                if(i>0&&userInfo[upline].level==1){
                   rewardInfo[upline].community = rewardInfo[upline].community.add(_amount.mul(3).div(100));
                   userInfo[user.referrer].totalRevenue =  userInfo[user.referrer].totalRevenue.add(_amount.mul(5).div(100));
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
         if(user.teamNum>=10){//30
         levelNow = 1;
         }   
        return levelNow;
    }
    }


    function getTeamUsersLength(address _user, uint256 _layer) external view returns(uint256) {
        return teamUsers[_user][_layer].length;
    }

 
}