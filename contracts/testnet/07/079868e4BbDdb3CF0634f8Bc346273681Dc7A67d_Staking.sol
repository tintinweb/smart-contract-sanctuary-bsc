// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./common.sol";
interface IBEP20Treasury{
    function claim(address recipient,uint256 amount) external;
}

//质押
contract Staking is Common{
    using SafeMath for uint256;
    //质押详情
    struct stakeInfo{
        bool status;//质押状态
        uint256 stakeTime;//质押时间
        uint256 stakeTotal;//质押数量
        uint256 stakeInterestTotal;//累计收益
        uint256 stakeInterest;//本次收益
    }
    //质押列表
    mapping(uint256 => stakeInfo) public _stakeInfo;
    //获取用户质押列表
    mapping(address => uint256[]) public _userStakeList;
    //包质押总数
    uint256 public _stakeTimes;

    //该用户质押总额
    mapping(address => uint256) public _userStakeTotal;
    //用户累计收益
    mapping(address => uint256) public _userInterestTotal;
    //质押用户列表(索引)
    mapping(uint256 => address) public _users;
    //质押用户列表
    mapping(address => uint256) public _userIds;
    //质押用户总数
    uint256 public _userNum;
    //执行利息分红时间
    mapping(uint256 => uint256) public _interestTime;
    //执行分红次数
    uint256 public _interestTimes=1;
    //日息（万分比）
    uint256 public _dayInterest = 120;
    //每天拆分执行三次
    uint256 public _interestOneDayTimes = 3;

    //全网总质押
    uint256 public _stakingTotal=0;
    //全网累计收益
    uint256 public _interestTotal;

    constructor () {
        stake(100000000000000000000);
    }
    //初始化参数
    function _init_params(uint256 dayInterest) external onlyOwner{
        _dayInterest=dayInterest;
    }
    function getStakes(address account,uint256 index,uint256 offset) external view returns(stakeInfo [] memory infos){
        for(index;index<offset;index++){
            stakeInfo memory info=_stakeInfo[_userStakeList[account][index]];
            infos[index]=info;
        }
    }
    function getStakes2(address account,uint256 index) external view returns(stakeInfo[] memory){
        stakeInfo [] memory infos;
        stakeInfo storage info=_stakeInfo[_userStakeList[account][index]];
        infos[0]=info;
        return infos;
    }
    //获取用户质押数量
    function userStakeNum(address account) external view returns (uint256){
        return _userStakeList[account].length;
    }
    //质押
    function stake(uint256 amount) public{
        require(amount>0,"error1");
        // address _dol=Super(_super)._contract("dol");
        // require(_dol!=address(0),"error2");
        // require(IBEP20(_dol).balanceOf(_msgSender())>=amount,"error3");
        // IBEP20(_dol).transferFrom(_msgSender(),address(this),amount);

        //写入质押列表
        _stakeInfo[++_stakeTimes]=stakeInfo(true,block.timestamp,amount,0,0);//设置质押详情
        _userStakeList[_msgSender()].push(_stakeTimes);

        _stakingTotal+=amount;
        _userStakeTotal[_msgSender()]+=amount;
        if(_userIds[_msgSender()]==0){
            _users[++_userNum]=_msgSender();
            _userIds[_msgSender()]=_userNum;
        }
    }
    //取出
    function unStake(uint256 id) external{
        address _dol=Super(_super)._contract("dol");

        stakeInfo storage info=_stakeInfo[id];
        uint amount = info.stakeTotal;
        IBEP20(_dol).transfer(_msgSender(),amount);
        if(info.stakeInterest>0){
            amount+=info.stakeInterest;
            _userInterestTotal[_msgSender()]+=info.stakeInterest;
            _interestTotal+=info.stakeInterest;
            info.stakeInterestTotal+=info.stakeInterest;
            info.stakeInterest=0;
        }
        info.status=false;
        _stakingTotal-=amount;
        _userStakeTotal[_msgSender()]-=amount;
        // delete info;//删除质押数据
        IBEP20(_dol).transfer(_msgSender(),amount);
    }
    //提取利息
    function claim(uint256 id) external{
        address _dol=Super(_super)._contract("dol");
        address _treasury=Super(_super)._contract("treasury");
        stakeInfo storage info=_stakeInfo[id];
        require(info.stakeInterest>0,"error2");
        require(IBEP20(_dol).balanceOf(address(this))>=info.stakeInterest,"error3");
        uint amount=info.stakeInterest;
        info.stakeInterest=0;//删除当前获取利息
        info.stakeInterestTotal+=amount;//添加到当前累计收益
        _interestTotal+=amount;//添加到质押总利息
        //从国库提取收益
        IBEP20Treasury(_treasury).claim(_msgSender(),amount);
    }
    //发放利息 status为false 限制次数
    function interest(bool status) external onlyOwner{
        //当天发放利息限制次数（防止超发）
        if(status==false&&_interestTimes+1>=_interestOneDayTimes){
            //3次分红前是否超过1天
            require(block.timestamp-_interestTime[_interestTimes+1-_interestOneDayTimes]<=1 days,"error1");
        }
        for(uint i=1;i<=_stakeTimes;i++){
            stakeInfo storage info=_stakeInfo[i];
            if(info.status==true){
                info.stakeInterest+=info.stakeTotal.mul(_dayInterest).div(_interestOneDayTimes*10**4); //利息=质押总量*日息/3/10000
            }
        }
        _interestTime[_interestTimes++]=block.timestamp;
    }
}