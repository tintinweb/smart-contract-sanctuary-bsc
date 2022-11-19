// SPDX-License-Identifier: GPLv3

pragma solidity ^0.6.12;
import "./SafeMath.sol";
import "./IERC20.sol";

contract Orion {
    using SafeMath for uint256; 
    IERC20 public usdt;
    uint256 public totalUser;
    uint256 public startTime;
    uint256 public lastDistribute;
    uint256 public lastWeekDistribute;
    uint256 public fastrack_club;
    uint256 public insurance_club;
    uint256 public core_club;
    
     

    uint256 private constant baseDivider = 10000; 
    uint256 private constant timeStep = 1 days;
    uint256 private constant referDepth = 14;
    uint256 private constant fastrackPercent = 300;
    uint256 private constant insurancePercent = 1000;
    uint256 private constant corePercent = 700;
    

    uint256[13] public packages = [0,10,30,60,100,200,400,800,1500,3000,6000,12000,24000];
    uint256[14] private levelPercents = [2500, 1000, 1000, 500, 100, 200, 300, 400, 500, 100, 200, 300, 400, 500];

    struct UserInfo {
        address referrer; // sponsor
        uint256 start; // join time
        uint256 level; // 0, 1, 2, 3, 4, 5 (package id)
        uint256 maxDeposit; // user max deposit
        uint256 totalDeposit; // user total deposit 
        uint256 teamNum; // user total team          
        uint256 teamTotalDeposit; 
        uint256 totalRevenue; // total income
        uint256 totalWithdraw;
    }

    mapping(address=>UserInfo) public userInfo;
    mapping(address => mapping(uint256 => address[])) public teamUsers;     
    
    address public defaultRefer;
    address public feeReceivers;
    
    mapping(uint256=>address[]) public Working;
    mapping(uint256=>address[]) public nonWorking;
    mapping(uint256=>address[]) public fastrackUsers; 
    mapping(uint256=>address[]) public coreUsers; 
    mapping(uint256=>address[]) public insuranceUsers; 

    struct RewardInfo{
        bool WorkingStatus;
        bool nonWorkingStatus;
        bool fastrackStatus;
        bool coreStatus;
        uint256 WeekDistributeOn;
        uint256 workingBusiness;
        uint256 coreBusiness;
        uint256 fastrackBusiness;
        uint256 clDay;  
        uint256 coreDay;  
        uint256 fastrackDay;  
        uint256 level;  
 
    }

    mapping(address=>RewardInfo) public rewardInfo;

    struct OrderInfo {
        uint256 amount; 
        uint256 start;
        bool isUnfreezed;
    }

    mapping(address => OrderInfo[]) public orderInfos;

    function getCurDay() public view returns(uint256) {
        return (block.timestamp.sub(startTime)).div(timeStep);
    }

    function getOrderLength(address _user) external view returns(uint256) {
        return orderInfos[_user].length;
    }

    function getTeamUsersLength(address _user, uint256 _layer) external view returns(uint256) {
        return teamUsers[_user][_layer].length;
    }

    function getFastrackLength(uint256 _day) external view returns(uint256) {
        return fastrackUsers[_day].length;
    }

    function getCoreLength(uint256 _day) external view returns(uint256) {
        return coreUsers[_day].length;
    }

    event Register(address user, address referral);
    event Deposit(address user, uint256 amount);
    event Withdraw(address user, uint256 withdrawable);

    constructor(address _usdtAddr, address _defaultRefer, address  _feeReceivers) public {
        usdt = IERC20(_usdtAddr);
        feeReceivers = _feeReceivers;
        startTime = block.timestamp;
        lastWeekDistribute = block.timestamp;
        defaultRefer = _defaultRefer;
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

    function _updateTeamNum(address _user) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){
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
  
    function deposit(uint256 _ID) external {
        uint256 pkg = packages[_ID].mul(uint256(1e18));
        
        require(usdt.balanceOf(msg.sender) >= pkg, "insufficient fund");
        usdt.transferFrom(msg.sender, address(this), pkg);
        
        deposit(msg.sender, pkg);
        userInfo[msg.sender].level = _ID;
       
        if(_ID >= 6){
             RewardInfo storage upRewards = rewardInfo[msg.sender];
            if(upRewards.fastrackStatus == false){
                uint256 dayNow = getCurDay();
                upRewards.fastrackDay = dayNow.add(30);
                fastrackUsers[upRewards.fastrackDay].push(msg.sender); 
                upRewards.fastrackStatus = true;
                
            }
            

        }
       
        emit Deposit(msg.sender, pkg);
    }

    function deposit(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        require(user.referrer != address(0), "register first");
        require(user.maxDeposit == 0 || _amount >= user.maxDeposit, "less before");
        
        if(user.maxDeposit == 0){
            _updateTeamNum(msg.sender);
            user.maxDeposit = _amount;
            
        }else if(user.maxDeposit < _amount){
            user.maxDeposit = _amount;
        }

        _distributeDeposit(_amount);

        if(user.totalDeposit == 0){
            uint256 dayNow = getCurDay();

            nonWorking[dayNow.add(7)].push(_user);
            rewardInfo[_user].nonWorkingStatus = true;
            rewardInfo[_user].clDay = dayNow.add(7);
            

        }

        
        user.totalDeposit = user.totalDeposit.add(_amount);

        orderInfos[_user].push(OrderInfo(
            _amount, 
            block.timestamp, 
            false
        ));

        distributePoolRewards();
        updateReferInfo(msg.sender, _amount);

        releaseUpRewards(msg.sender, _amount);
    }

    function _distributeDeposit(uint256 _amount) private {
        //uint256 fee = _amount.mul(feePercents).div(baseDivider);
       // usdt.transfer(feeReceivers[0], fee.div(2));
        //usdt.transfer(feeReceivers[1], fee.div(2));
        uint256 luck = _amount.mul(fastrackPercent).div(baseDivider);
        fastrack_club = fastrack_club.add(luck);
        uint256 star = _amount.mul(insurancePercent).div(baseDivider);
        insurance_club = insurance_club.add(star);
        uint256 top = _amount.mul(corePercent).div(baseDivider);
        core_club = core_club.add(top);
    }
   
    function updateReferInfo(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){
                userInfo[upline].teamTotalDeposit = userInfo[upline].teamTotalDeposit.add(_amount);
                _updateLevel(upline);
                if(upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }

    function releaseUpRewards(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        uint256 levelIncome ;
        uint256 totalCheck;
        for(uint256 i = 0; i < referDepth;){
             levelIncome = _amount.mul(levelPercents[i]).div(baseDivider);
            if(upline != address(0)){
                if(user.maxDeposit >= _amount){
                    totalCheck = userInfo[upline].totalRevenue.add(levelIncome);
                    if(totalCheck < (userInfo[upline].totalDeposit.mul(3))){
                        RewardInfo storage upRewards = rewardInfo[upline];
                        upRewards.level = upRewards.level.add(levelIncome);
                        
                        if(upRewards.WorkingStatus == false){
                            upRewards.nonWorkingStatus = false;
                            Working[upRewards.clDay].push(upline);
                        }
                        upRewards.WorkingStatus = true;
                        upRewards.workingBusiness = upRewards.workingBusiness.add(_amount);
                        upRewards.fastrackBusiness = upRewards.fastrackBusiness.add(_amount);
                        upRewards.coreBusiness = upRewards.coreBusiness.add(_amount);
                        
                        usdt.transfer(upline, levelIncome);
                        userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(levelIncome);
                
                        i++;
                    }
                    
                }
               upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }

    function _updateLevel(address _user) private {
        UserInfo storage user = userInfo[_user];
         if(rewardInfo[_user].coreStatus == false){
            (uint256 maxTeam, uint256 otherTeam, ) = getTeamDeposit(_user);
            if( user.teamNum >= 600 && maxTeam >= 150 && otherTeam >= 450){
               uint256 dayNow = getCurDay();
                rewardInfo[_user].coreDay = dayNow.add(30);
                coreUsers[rewardInfo[_user].coreDay].push(_user);
                rewardInfo[_user].coreStatus = true;
            }

         }
        
    }

 

    function getTeamDeposit(address _user) public view returns(uint256, uint256, uint256){
        uint256 totalTeam;
        uint256 maxTeam;
        uint256 otherTeam;
        for(uint256 i = 0; i < teamUsers[_user][0].length; i++){
            uint256 userTotalTeam = userInfo[teamUsers[_user][0][i]].teamNum;
            totalTeam = totalTeam.add(userTotalTeam);
            if(userTotalTeam > maxTeam){
                maxTeam = userTotalTeam;
            }
        }
        otherTeam = totalTeam.sub(maxTeam);
        return(maxTeam, otherTeam, totalTeam);
    }

    function distributePoolRewards() public {
        if(block.timestamp > lastDistribute.add(timeStep)){
            uint256 dayNow = getCurDay();
            _distributeNonWorkingPool(dayNow);

            fastrackDistribution(dayNow);
            coreDistribution(dayNow);
            lastDistribute = block.timestamp;
        }
    }

    function _distributeNonWorkingPool(uint256 dayNow) public {
        uint256 countNonWorkig = nonWorking[dayNow].length;
        uint256 totalCheck;
        uint256 perUserIncome = insurance_club.div(countNonWorkig);
        for(uint256 i = 0; i<countNonWorkig;i++){
            address userAddr = nonWorking[dayNow][i];
            totalCheck = userInfo[userAddr].totalRevenue.add(perUserIncome);
            if(totalCheck < (userInfo[userAddr].totalDeposit.mul(2)) && rewardInfo[userAddr].workingBusiness == 0){
                userInfo[userAddr].totalRevenue = userInfo[userAddr].totalRevenue.add(perUserIncome);

            }
            rewardInfo[userAddr].workingBusiness = 0;
            rewardInfo[userAddr].clDay = rewardInfo[userAddr].clDay.add(7);
            nonWorking[rewardInfo[userAddr].clDay].push(userAddr);

        }
    }

    function fastrackDistribution(uint256 dayNow) public {
        uint256 countNonWorkig = fastrackUsers[dayNow].length;
        uint256 totalCheck;
        uint256 perUserIncome = fastrack_club.div(countNonWorkig);
        for(uint256 i = 0; i<countNonWorkig;i++){
            address userAddr = fastrackUsers[dayNow][i];
            if(rewardInfo[userAddr].fastrackStatus == true && rewardInfo[userAddr].fastrackBusiness >= 500e18){
                totalCheck = userInfo[userAddr].totalRevenue.add(perUserIncome);
                if(totalCheck < (userInfo[userAddr].totalDeposit.mul(3))){
                    userInfo[userAddr].totalRevenue = userInfo[userAddr].totalRevenue.add(perUserIncome);

                }
            }
            rewardInfo[userAddr].fastrackBusiness = 0;
            rewardInfo[userAddr].fastrackDay = rewardInfo[userAddr].fastrackDay.add(30);
            fastrackUsers[rewardInfo[userAddr].fastrackDay].push(userAddr);

        }
    }

    function coreDistribution(uint256 dayNow) public {
        uint256 countNonWorkig = coreUsers[dayNow].length;
        uint256 totalCheck;
        uint256 perUserIncome = core_club.div(countNonWorkig);
        for(uint256 i = 0; i<countNonWorkig;i++){
            address userAddr = coreUsers[dayNow][i];
            if(rewardInfo[userAddr].coreStatus == true && rewardInfo[userAddr].coreBusiness >= 1500e18){
                totalCheck = userInfo[userAddr].totalRevenue.add(perUserIncome);
                if(totalCheck < (userInfo[userAddr].totalDeposit.mul(3))){
                    userInfo[userAddr].totalRevenue = userInfo[userAddr].totalRevenue.add(perUserIncome);

                }
            }
            rewardInfo[userAddr].coreBusiness = 0;
            rewardInfo[userAddr].coreDay = rewardInfo[userAddr].coreDay.add(30);
            coreUsers[rewardInfo[userAddr].coreDay].push(userAddr);

        }
    }

    function withdraw() external {
        distributePoolRewards();
        UserInfo storage user = userInfo[msg.sender];
        require(user.totalRevenue > 0,"insufficient fund");
        RewardInfo storage upRewards = rewardInfo[msg.sender];
        uint256 withdrawable = user.totalRevenue.sub(upRewards.level).sub(user.totalWithdraw);
       
        usdt.transfer(msg.sender, withdrawable);
        emit Withdraw(msg.sender, withdrawable);
    }

   


}