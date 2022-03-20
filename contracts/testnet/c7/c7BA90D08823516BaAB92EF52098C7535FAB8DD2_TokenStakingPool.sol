/**
 *Submitted for verification at BscScan.com on 2022-03-20
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^ 0.8.3;

abstract contract ERC20{
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
    function mint(address _address,uint tokens) external virtual returns (bool success);
}

contract Comn {
    address internal owner;
    uint256 internal constant _NOT_ENTERED = 1;
    uint256 internal constant _ENTERED = 2;
    uint256 internal _status = 1;
    modifier onlyOwner(){
        require(msg.sender == owner,"Modifier: The caller is not the creator");
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
    fallback () payable external {}
    receive () payable external {}
}

contract AKWrapper is Comn{
    address public inAddress;                                   //[设置]  质押代币地址
    address public outAddress;                                  //[设置]  产出代币地址
    
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;


    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    //质押代币
    function stake(uint256 amountToWei) public virtual {
        _totalSupply = _totalSupply + amountToWei;
        _balances[msg.sender] += amountToWei;
        ERC20(inAddress).transferFrom(msg.sender, address(this), amountToWei);
    }

    //提取质押代币
    function withdraw(uint256 amountToWei) public virtual {
        _totalSupply = _totalSupply - amountToWei;
        _balances[msg.sender] -= amountToWei;
        ERC20(inAddress).transfer(msg.sender, amountToWei);
    }
}

contract TokenStakingPool is AKWrapper {
    
    uint256 public updateTime;        //最近一次更新时间
    uint256 public rewardPerTokenStored;  //每单位 token 奖励数量
    mapping(address => uint256) public userRewardPerTokenPaid;  //已采集量
    mapping(address => uint256) public rewards;                 //余额

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event UpdateWithdrawStatus(bool oldStatus, bool newStatus);


    modifier checkStart() {
        require(block.timestamp >= miningStartTime, "not start");
        _;
    }

    //更新挖矿奖励
    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();     //每个币的时时收益率
        updateTime = lastTimeRewardApplicable(); //最新时间
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;//每单位 token 奖励数量
        }
        _;
    }


    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        //最后一个区间的总产币量
        uint tmp = (lastTimeRewardApplicable() - updateTime) * miningRateSecond;
        //一个币在这个区间的总产币量
        return rewardPerTokenStored + tmp / totalSupply();
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        if (miningEndTime > block.timestamp) {
            return block.timestamp;
        }
        return miningEndTime;
    }

    function earned(address account) public view returns (uint256) {
        return rewards[account] + balanceOf(account) * (rewardPerToken() - userRewardPerTokenPaid[account]) / 1e18;
    }

    //质押代币
    function stake(uint256 amount) public override updateReward(msg.sender) checkStart {
        require(amount > 0, ' Cannot stake 0');
        super.stake(amount);
        emit Staked(msg.sender, amount);
    }

    //提取质押代币
    function withdraw(uint256 amount) public override updateReward(msg.sender) checkStart {
        require(canWithdraw, "inactive");
        require(amount > 0, ' Cannot withdraw 0');
        super.withdraw(amount);
        emit Withdrawn(msg.sender, amount);
    }

    function exit() external {
        withdraw(balanceOf(msg.sender));
        getReward();
    }

    //领取挖矿奖励
    function getReward() public updateReward(msg.sender) checkStart {
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            ERC20(outAddress).mint(msg.sender,reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    /*---------------------------------------------------管理运营-----------------------------------------------------------*/
    bool public canWithdraw = true;                             //[设置]  关闭/打开 提取
    uint public miningStartTime;                                //[设置]  开始时间 (单位:秒)
    uint public miningEndTime;                                  //[设置]  截止时间 (单位:秒)
    uint public miningRateSecond;                               //[设置]  挖矿速率 (单位:秒)

    /*
     * @param _inAddress 质押代币合约
     * @param _outAddress 产出代币合约
     * @param _nodePool 节点池合约
     * @param _miningStartTime 挖矿开始时间 (单位:秒)
     * @param _miningRateSecond 挖矿速率 (单位:秒)
     * @param _miningTimeLength 挖矿时长 (单位:秒)
     */
    function setConfig(address _inAddress,address _outAddress,uint _miningStartTime,uint _miningRateSecond,uint _miningTimeLength) public onlyOwner {
        inAddress = _inAddress;                        //质押代币
        outAddress = _outAddress;                      //产出代币
        miningStartTime =  _miningStartTime;
        updateTime = miningStartTime;
        miningRateSecond = _miningRateSecond;
        miningEndTime = _miningStartTime + _miningTimeLength;
    }

    function setCanWithdraw(bool _enable) external onlyOwner {
        emit UpdateWithdrawStatus(canWithdraw, _enable);
        canWithdraw = _enable;
    }
}