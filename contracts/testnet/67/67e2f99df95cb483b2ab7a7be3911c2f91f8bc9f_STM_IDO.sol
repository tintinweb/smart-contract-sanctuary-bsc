// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./SafeMath.sol";
import "./IERC20.sol";
contract STM_IDO {
    using SafeMath for uint256; 

    address  _owner;

    address  feeReceivers = address(0x9B43146259f1240613AFa3a55439539917a30d7b); //

    address defaultRefer = address(0xF3559Bd49B5D8de03a07342110F4E22994f514aE);//

    uint256 public constant idoShare = 100e18;

    uint256 public constant idoNode = 1000e18;

    IERC20 public usdt = IERC20(address(0x0d43B61aBE6c5aE1F41371a08da5ec26f8d74682));//usdt  0x55d398326f99059fF775485246999027B3197955

    uint256 public leader;

    address[] public holders;
    
    uint256 public totalUser; 

    uint256 private constant referDepth = 3;

    mapping(address => uint256) public holderIndex;


    struct UserInfo {

        address user;

        address referrer;

        uint256 share;

        uint256 shareTime;

        uint256 node;

        uint256 nodeTime;

        uint256 shareCount;

        uint256 nodeCount;

        uint256 teamNum;

        uint256 totalRevenue;
    }




    mapping(address=>UserInfo) public userInfo;

    mapping(address => mapping(uint256 => address[])) public teamUsers;

    struct RewardInfo{
            
       uint256 directs; //直推奖励

       uint256 interval; //间推奖励

       uint256 node;
    }

    mapping(address=>RewardInfo) public rewardInfo;
    
    modifier onlyOwner() {
        require(msg.sender == _owner, "Permission denied"); _;
    }

    event Register(address user, address referral);
    event Deposit(address user, uint256 amount);
   

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

        totalUser = totalUser.add(1);
        
        emit Register(msg.sender, _referral);
    }

   event BuyShare(address _user,uint256 _amount);

   event BuyNode(address _user,uint256 _amount);


  function buyShare(address _user,uint256 _amount) external{
       
        UserInfo storage user = userInfo[msg.sender];

        require(user.referrer != address(0), "register first");

        require(_amount == idoShare, "amout is err");

        require( user.shareCount  == 0, "Limited to one copy");

        user.shareCount +=1;
        user.share = _amount;
        user.shareTime = block.timestamp; 
        (uint256 supAmount) =  _distributeReward(_user,_amount,1);
        usdt.transferFrom(msg.sender,address(this),_amount.sub(supAmount));
        emit BuyShare(_user,_amount);

         _updateTeamNum(_user);   
  }

  function buyNode(address _user,uint256 _amount) external{

        usdt.transferFrom(msg.sender,address(this),_amount);

        UserInfo storage user = userInfo[msg.sender];

        require(user.referrer != address(0), "register first");

        require(_amount == idoNode, "amout is err");

        require(  user.nodeCount == 0, "Limited to one copy");
        addHolder(_user);
        user.nodeCount += 1;
        user.node = _amount;
        user.nodeTime = block.timestamp; 
         (uint256 supAmount) =    _distributeReward(_user,_amount,2);
          usdt.transferFrom(msg.sender,address(this),_amount.sub(supAmount));
          emit BuyNode(_user,_amount);

         _updateTeamNum(_user);   
  }


  function _distributeReward(address _user,uint256 _amount, uint256 _referDepth) private returns(uint256 ) {
        uint256 supAmount = 0;
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        UserInfo storage upUser = userInfo[upline];
        RewardInfo storage upReward = rewardInfo[upline];
         for(uint256 i = 0; i < _referDepth; i++){
            if(upline != address(0) && upline != defaultRefer){
              uint256 profit =   _amount.mul(5).div(100);
                usdt.transferFrom(address(this),upline,profit);
                supAmount += profit;
                if(_referDepth==1 && i==0){ //直推
                   upUser.totalRevenue += profit;
                   upReward.directs += profit; 
                }else if(_referDepth==1 && i==1){//间推
                   upUser.totalRevenue += profit;
                   upReward.directs += profit; 
                }else{//节点
                    upUser.totalRevenue += profit;
                    upReward.node += profit; 
                }        
                if(upline == defaultRefer) break;
                   upline = userInfo[upline].referrer;
            }         
            else{
                break;
            }

        }

        return supAmount;

  }

 function _updateTeamNum(address _user) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)&&i<3){
                userInfo[upline].teamNum = userInfo[upline].teamNum.add(1);
                teamUsers[upline][i].push(_user);
                if(userInfo[upline].teamNum==10){
                    addHolder(upline);
                } 
                if(upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }


    function getTeamUsersLength(address _user, uint256 _layer) external view returns(uint256) {
        return teamUsers[_user][_layer].length;
    }

    function addHolder(address adr) private {
        if(adr == defaultRefer){
             return;
        }
        uint256 size;
        assembly {size := extcodesize(adr)}
        if (size > 0) {
            return;
        }
        if (0 == holderIndex[adr]) {
            if (0 == holders.length || holders[0] != adr) {
                holderIndex[adr] = holders.length;
                holders.push(adr);
            }
        }
    }

 
}