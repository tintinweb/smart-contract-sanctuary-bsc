/**
 *Submitted for verification at BscScan.com on 2022-05-11
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^ 0.8.3;

abstract contract ERC20{
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
    function mining(address _address,uint tokens) external virtual returns (bool success);
}

contract Comn {
    address internal owner;
    uint256 internal constant _NOT_ENTERED = 1;
    uint256 internal constant _ENTERED = 2;
    uint256 internal _status = 1;
    mapping(address => bool) private approveMapping; //授权地址mapping
    mapping(address => bool) private updateMapping; //授权更新地址mapping
    modifier onlyOwner(){
        require(msg.sender == owner,"Modifier: The caller is not the creator");
        _;
    }
    modifier onlyApprove(){
        require(approveMapping[msg.sender] || msg.sender == owner,"Modifier : The caller is not the approve");
        _;
    }
    modifier onlyUpdate(){
        require(updateMapping[msg.sender] || msg.sender == owner,"Modifier : The caller is not the update");
        _;
    }
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    constructor() {
        owner = msg.sender;
        _status = _NOT_ENTERED;
    }
    function setApproveAddress(address _address,bool _bool) public onlyOwner(){
        approveMapping[_address] = _bool;
    }
    function setUpdateAddress(address _address,bool _bool) public onlyOwner(){
        updateMapping[_address] = _bool;
    }

    function outToken(address contractAddress,address targetAddress,uint amountToWei) public onlyOwner{
        ERC20(contractAddress).transfer(targetAddress,amountToWei);
    }
    fallback () payable external {}
    receive () payable external {}
}

contract Wrapper is Comn{
    mapping(uint => mapping(uint => uint)) public _typeColumnId;//[分类][栏目] | ID
    uint256 public _totalSupply;//全网总质押量
    mapping(address => uint256) public _balances;//地址总质押量

    mapping(uint => uint256) public typeTotal;//[分类] | 总量
    mapping(uint => mapping(address => uint)) public typeAddressTotal;//[分类][地址] | 总量
    mapping(uint => mapping(uint => uint)) public typeColumnTotal;//[分类][栏目][ | 总量
    mapping(uint => mapping(address => mapping(uint => uint))) public typeAddressColumnTotal;//[分类][地址][栏目][ | 总量
    mapping(uint => mapping(uint => mapping(uint => LpInfo))) public typeColumnIdInfo;//[分类][栏目][ID] | 记录
    mapping(uint => mapping(uint => mapping(address => uint))) public addressPower;//[分类][区块号][地址] | 记录

    struct LpInfo {
        uint amount;                    //交易量
        uint coinAmount;                //coin交易量
        uint tokenAmount;               //token交易量
        uint createTime;                //创建时间
    }

    //质押代币
    function stake(address account,uint amountToWei,uint columnType,uint columnId,uint coinAmount,uint tokenAmount) public virtual onlyApprove{
        _totalSupply = _totalSupply + amountToWei;
        _balances[account] += amountToWei;

        typeTotal[columnType] += amountToWei;
        typeAddressTotal[columnType][account] += amountToWei;
        typeColumnTotal[columnType][columnId] += amountToWei;
        typeAddressColumnTotal[columnType][account][columnId] += amountToWei;
        
        if(_typeColumnId[columnType][columnId] == 0){
            _typeColumnId[columnType][columnId] = 1;
        } else {
            _typeColumnId[columnType][columnId] = _typeColumnId[columnType][columnId] + 1;
        }
        typeColumnIdInfo[columnType][columnId][_typeColumnId[columnType][columnId]] = LpInfo(amountToWei,coinAmount,tokenAmount,block.timestamp);
        addressPower[columnType][block.number][account] += amountToWei;
    }

    //提取质押代币
    function withdraw(address account,uint256 amountToWei,uint columnType,uint columnId) public virtual onlyOwner{
        _totalSupply -= amountToWei;
        _balances[account] -= amountToWei;

        typeTotal[columnType] -= amountToWei;
        typeAddressTotal[columnType][account] -= amountToWei;
        typeColumnTotal[columnType][columnId] -= amountToWei;
        typeAddressColumnTotal[columnType][account][columnId] -= amountToWei;
    }

    function getAddressPower(uint _type,uint256 _number, address _address) public view returns(uint256 power) {
        return addressPower[_type][_number][_address];
    }

    function getTypeColumnInfo(uint _type,uint _columnId,uint _length) public view returns(LpInfo[] memory infoArray) {
        if(_typeColumnId[_type][_columnId] < _length){
            _length = _typeColumnId[_type][_columnId];
        }
        infoArray = new LpInfo[](_length);
        for(uint i=0; i<_length; i++){
            infoArray[i] = typeColumnIdInfo[_type][_columnId][_length-i];
        }
    }
}

contract BottomMining is Wrapper {
    
    uint256 public updateTime;                                  //最近一次更新时间
    uint256 public rewardPerTokenStored;                        //每单位 token 奖励数量
    mapping(address => uint256) public userRewardPerTokenPaid;  //已采集量
    mapping(address => uint256) public rewards;                 //余额


    modifier checkStart() {
        require(block.timestamp >= miningStartTime, "not start");
        _;
    }

    //更新挖矿奖励
    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();     //每个币的时时收益率
        updateTime = getNowTime(); //最新时间
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;//每单位 token 奖励数量
        }
        _;
    }


    function rewardPerToken() public view returns (uint256) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        //最后一个区间的总产币量
        uint tmp = (getNowTime() - updateTime) * miningRateSecond;
        //一个币在这个区间的总产币量
        return rewardPerTokenStored + tmp * 1e18 / _totalSupply;
    }

    function getNowTime() public view returns (uint256) {
        if (miningEndTime > block.timestamp) {
            return block.timestamp;
        }
        return miningEndTime;
    }

    //个人收益查询
    function earned(address account) public view returns (uint256) {
        return rewards[account] + _balances[account] * (rewardPerToken() - userRewardPerTokenPaid[account]) / 1e18;
    }

    //质押代币
    function stake(address account,uint256 amountToWei,uint columnType,uint columnId,uint coinAmount,uint tokenAmount) public override onlyApprove updateReward(account) checkStart {
        require(amountToWei > 0, ' Cannot stake 0');
        super.stake(account, amountToWei,columnType,columnId,coinAmount,tokenAmount);
    }

    //提取质押代币
    function withdraw(address account,uint256 amountToWei,uint columnType,uint columnId) public override onlyOwner updateReward(account) checkStart {
        require(canWithdraw, "inactive");
        require(amountToWei > 0, ' Cannot withdraw 0');
        super.withdraw(account, amountToWei,columnType,columnId);
    }

    function exit(uint columnType,uint columnId) external {
        withdraw(msg.sender,_balances[msg.sender],columnType,columnId);
        getReward();
    }

    //领取挖矿奖励
    function getReward() public updateReward(msg.sender) checkStart {
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            ERC20(poolFactory).mining(msg.sender,reward);
        }
    }

    /*---------------------------------------------------管理运营-----------------------------------------------------------*/
    bool public canWithdraw = true;                             //[设置]  关闭/打开 提取
    uint public miningStartTime;                                //[设置]  开始时间 (单位:秒)
    uint public miningEndTime;                                  //[设置]  截止时间 (单位:秒)
    uint public miningRateSecond;                               //[设置]  挖矿速率 (单位:秒)
    address public poolFactory;                                 //[设置]  产出代币地址

    /*
     * @param _poolFactory 挖矿工厂合约
     * @param _miningStartTime 挖矿开始时间 (单位:秒)
     * @param _miningRateSecond 挖矿速率 (单位:秒)
     * @param _miningTimeLength 挖矿时长 (单位:秒)
     */
    function setConfig(address _poolFactory,uint _miningStartTime,uint _miningRateSecond,uint _miningTimeLength) public onlyOwner {
        poolFactory = _poolFactory;                      //产出代币
        miningStartTime =  _miningStartTime;
        updateTime = miningStartTime;
        miningRateSecond = _miningRateSecond;
        miningEndTime = _miningStartTime + _miningTimeLength;
    }

    function updateOutput(uint outputToWei) public onlyUpdate {
        rewardPerTokenStored = rewardPerToken();     //每个币的时时收益率
        updateTime = block.timestamp; //最新时间
        miningRateSecond = outputToWei;
    }

    function setCanWithdraw(bool _enable) external onlyOwner {
        canWithdraw = _enable;
    }
}