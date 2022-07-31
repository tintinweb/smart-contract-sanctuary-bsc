/**
 *Submitted for verification at BscScan.com on 2022-07-31
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-26
*/

pragma solidity 0.8.13;
// SPDX-License-Identifier: MIT

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        // 空字符串hash值
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;  
        //内联编译（inline assembly）语言，是用一种非常底层的方式来访问EVM
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
}

library SafeERC20 {
    using Address for address;
 
    function safeTransfer(ERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
 
    function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
 
    function safeApprove(ERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),"SafeERC20: approve from non-zero to non-zero allowance");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
 
    function callOptionalReturn(ERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
 
interface ERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
 
interface PriceTool{
    function getPrice(address _outToken, address _inToken, uint256 _amount) external view returns(uint256 amount);
}

contract Pledge {
    using SafeERC20 for ERC20;

    uint public constant SECONDS_PER_DAY = 24 * 60 * 60;
 
    //管理员
    address private owner;
    //超级管理员
    address private ownerAdmin;
    
    mapping(address => PledgeOrder) public _orders;
    mapping(address => SwapOrder) public _swapOrders;

    PriceTool public priceTool = PriceTool(0x981763e3C4f883dE5E4a09249Ed8aB37d7d6FAD6);

    ERC20 public _FAF = ERC20(0xf0Afa59B51125405c33F5c417DF8Be8Cd4d45Ae6);
    address public _faf = 0xf0Afa59B51125405c33F5c417DF8Be8Cd4d45Ae6;

    ERC20 public _TKF = ERC20(0x724E740766B0ECc806ea1D7eEc63e563E9407925);
    address public _tkf = 0x724E740766B0ECc806ea1D7eEc63e563E9407925;

    ERC20 public _USDT = ERC20(0x55d398326f99059fF775485246999027B3197955);
    address public _usdt = 0x55d398326f99059fF775485246999027B3197955;

    //swap两个faf
    ERC20 public _FAF1 = ERC20(0xad7bc8E6d8d60C42EC7e5e02811E5Edbea833Ade);
    ERC20 public _FAF2 = ERC20(0xf0Afa59B51125405c33F5c417DF8Be8Cd4d45Ae6);

    address public fafZero = 0x0000000000000000000000000000000000000001;
    address public tkfZero = 0x0000000000000000000000000000000000000001;
    address public marketAddress = 0xB6b2212c69240B50339c41211936584C80169404;
    address public uBackAddress = 0xB6b2212c69240B50339c41211936584C80169404;
    address public defaultAddress = 0x6C19f96Ebf96AFda8d774a8E6Ea998859464718b;

    //千分之三收益
    uint256 public _rewardFee = 20;
    //质押数量2倍进奖池
    uint256 public _powerFee = 2;
    //swap日费率
    uint256 public _swapRewardFee = 1;
    //swap总量
    uint256 public _swapTotolAmount = 1000000 * 10 ** 18;
    //swap当前数量
    uint256 public _swapCurrentAmount = 0;

    mapping(address => address) recommend;
    //直推人数
    mapping(address => uint256) public recommendAmount;
    //团队金额
    mapping(address => uint256) teamTotal;
    //团队等级
    mapping(address => uint256) teamLevel;
    //团队等级奖励
    mapping(uint256 => uint256) teamReward;
    //直推等级数量
    mapping(address => mapping(uint256 => uint256)) public recommendLevelAmount;
    //下级直推数组
    mapping(address => address[]) teamList;
    //管理员列表
    mapping(address => bool) adminList;

    //是否存在质押记录 最后一次领取时间 分销可领取余金额 奖池总额 当前奖池剩余额度
    struct PledgeOrder {
        bool isExist;
        uint256 lastTime;
        uint256 receiveAmount;
        uint256 totalAmount;
        uint256 rewardAmount;
        uint256 uAmount;
    }

    //是否存在质押记录 最后一次领取时间 奖池总额 当前奖池剩余额度
    struct SwapOrder {
        bool isExist;
        uint256 lastTime;
        uint256 totalAmount;
        uint256 rewardAmount;
    }
 
    constructor () {
        owner = msg.sender;
        ownerAdmin = msg.sender;
        teamReward[0] = 0;
        teamReward[1] = 5;
        teamReward[2] = 10;
        teamReward[3] = 15;
        teamReward[4] = 20;
        adminList[msg.sender] = true;
    }
	
	//质押代币 FAF 
	//质押之前需要先调用其合约的approve方法 获取授权
    function pledgeFAF(uint256 _fafAmount, uint256 _usdtAmount) public returns(bool){
        require(address(msg.sender) == address(tx.origin), "no contract");
//        require(priceTool.getPrice(_faf, _usdt, _fafAmount) >= 100, "price too little");
		_USDT.transferFrom(msg.sender, address(this), _usdtAmount);
		_FAF.transferFrom(msg.sender, address(this), _fafAmount);
        uint256 total = priceTool.getPrice(_usdt, _faf, _usdtAmount) * 4;
        address top1 = recommend[msg.sender];
        if(_orders[msg.sender].isExist == false){
            createOrder(total, _usdtAmount);
            addTeamList(top1);
        }else{
            PledgeOrder storage order=_orders[msg.sender];
            order.totalAmount += total;
            order.rewardAmount += total;
            order.uAmount += _usdtAmount * 2;
        }
        _FAF.safeTransfer(fafZero, _fafAmount);
        if(top1 == address(0)){
            recommend[msg.sender] = defaultAddress;
        }
        //usdt分红 记录团队金额
        bonus(_usdtAmount);
        setTeamPerformance(_usdtAmount * 2);
        return true;
    }

    //质押代币 TKF
	//质押之前需要先调用其合约的approve方法 获取授权
    function pledgeTKF(uint256 _tkfAmount, uint256 _usdtAmount) public returns(bool){
        require(address(msg.sender) == address(tx.origin), "no contract");
//        require(priceTool.getPrice(_faf, _usdt, _fafAmount) >= 100, "price too little");
		_USDT.transferFrom(msg.sender, address(this), _usdtAmount);
		_TKF.transferFrom(msg.sender, address(this), _tkfAmount);
        uint256 total = priceTool.getPrice(_usdt, _faf, _usdtAmount) * 4;
        address top1 = recommend[msg.sender];
        if(_orders[msg.sender].isExist == false){
            createOrder(total, _usdtAmount);
            addTeamList(top1);
        }else{
            PledgeOrder storage order=_orders[msg.sender];
            order.totalAmount += total;
            order.rewardAmount += total;
            order.uAmount += _usdtAmount * 2;
        }
        _TKF.safeTransfer(tkfZero, _tkfAmount);
        
        if(top1 == address(0)){
            recommend[msg.sender] = defaultAddress;
        }
        //usdt分红 记录团队金额
        bonus(_usdtAmount);
        setTeamPerformance(_usdtAmount * 2);
        return true;
    }

    function addTeamList(address top1) internal{
        address[] storage ads = teamList[top1];
        bool isExis = false;
        for(uint i = 0; i < ads.length; i++) {
            if(ads[i] == msg.sender){
                isExis = true;
            }
        }
        if(!isExis){
            ads.push(msg.sender);
            teamList[top1] = ads;
        }
    }
 
    function createOrder(uint256 trcAmount, uint256 uAmount) private {
        _orders[msg.sender] = PledgeOrder(
            true,
            block.timestamp,
            0,
            trcAmount,
            trcAmount,
            uAmount * 2
        );
    }

    function setTeamPerformance(uint256 _amount) internal{
        address top1 = recommend[msg.sender];
        for(uint256 i = 0; i < 30; i ++){
            if(address(0) != top1){
                teamTotal[top1] += _amount;
                top1 = recommend[top1];
            }else{
                return;
            }
        }
    }

    function bonus(uint256 _amount) internal{
        address top1 = recommend[msg.sender];
        _USDT.transfer(marketAddress, _amount / 5);
        _USDT.transfer(uBackAddress, _amount / 2);
        if(top1 != address(0)){
            
            _USDT.transfer(top1, _amount * 15 / 100);
            top1 = recommend[top1];
            if(top1 != address(0)){
                _USDT.transfer(top1, _amount / 10);
                top1 = recommend[top1];
                if(top1 != address(0)){
                    _USDT.transfer(top1, _amount / 20);
                }
            }
        }
    }

	//提取静态收益
    function takeProfit() public {
        require(address(msg.sender) == address(tx.origin), "no contract");
        PledgeOrder storage order = _orders[msg.sender];
        uint256 day = (block.timestamp - order.lastTime) / SECONDS_PER_DAY;
        require(day > 0 || order.receiveAmount > 0, "no reward");
        uint256 pledgeBalance = _FAF.balanceOf(address(this));

                // 奖池总量 * 收益倍率 * 天数 + 分销收益
        uint256 uA = order.uAmount * _rewardFee / 1000 * day;
        uint256 profits = priceTool.getPrice(_usdt, _faf, uA);
        
        address rec1 = recommend[msg.sender];
        uint256 rate = 0;
        profits += order.receiveAmount;
        order.rewardAmount = order.rewardAmount - profits;
        require(pledgeBalance >= profits, "no balance");
        _FAF.safeTransfer(address(msg.sender), profits);
        //提取收益后刷新时间
        order.lastTime = block.timestamp;
        order.receiveAmount = 0;
        uint256 _count = 0;
        PledgeOrder storage order1;
        for(uint256 i = 0; i < 30; i ++){
            if(rec1 != address(0)){
                if(_count == 0){
                    order1 = _orders[rec1];
                    if(order1.isExist){
                        rate = teamReward[teamLevel[rec1]];
                        if(teamLevel[msg.sender] >= teamLevel[rec1] && teamLevel[rec1] != 0){
                            if(teamLevel[msg.sender] >= 3){
                                rate = rate * 8 / 10;
                            }else{
                                _count ++;
                            }
                        }
                        order1.receiveAmount += profits * rate / 100;
                    }
                }else if(_count > 0){
                    address top1 = recommend[rec1];
                    for(uint256 j = 0; j < 6; j++){
                        if(top1 != address(0) && teamLevel[top1] > teamLevel[msg.sender]){
                            rate = teamReward[teamLevel[top1]] - teamReward[teamLevel[msg.sender]];
                            order1 = _orders[top1];
                            order1.receiveAmount += profits * rate / 100;
                        }
                        top1 = recommend[top1];
                    }
                    return;
                }
                rec1 = recommend[rec1];
            }else{
                return;
            }
        }
    }

	//查询收益
    function getParentProfitToken(address _target) public view returns(uint256) {
        require(address(msg.sender) == address(tx.origin), "no contract");
        PledgeOrder memory order = _orders[_target];
        uint256 day = (block.timestamp - order.lastTime) / SECONDS_PER_DAY;
        uint256 uA = order.uAmount * _rewardFee / 1000 * day;
        if(uA == 0){
            return 0;
        }
        uint256 profits = priceTool.getPrice(_usdt, _faf, uA);
        return profits;
    }

    //修改管理员
    function changeOwner(address paramOwner) public onlyOwnerAdmin {
		owner = paramOwner;
    }

    //修改超级管理员
    function changeOwnerAdmin(address paramOwner) public onlyOwnerAdmin {
		ownerAdmin = paramOwner;
    }

    //设置加速收益率
    function setRewardFee(uint256 _fee) public onlyOwnerAdmin {
		_rewardFee = _fee;
    }

    //修改扩容总量
    function setSwapTotolAmount(uint256 _target) external onlyOwnerAdmin{
        _swapTotolAmount = _target;
    }

    //修改质押u的数量
    function setSwapRewardFee(uint256 _target) public onlyOwnerAdmin {
		_swapRewardFee = _target;
    }

    function withdraw(address _token, address _target, uint256 _amount) public onlyOwnerAdmin {
        require(ERC20(_token).balanceOf(address(this)) >= _amount, "no balance");
		ERC20(_token).safeTransfer(_target, _amount);
    }

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    modifier onlyOwnerAdmin(){
        require(msg.sender == ownerAdmin);
        _;
    }
 
    function getOwner() public view returns (address) {
        return owner;
    }

    function getOwnerAdmin() public view returns (address) {
        return ownerAdmin;
    }

    function bind(address _target) external {
        if(recommend[msg.sender] == address(0)){
            recommendAmount[_target] ++;
        }
        recommend[msg.sender] = _target;
    }

    function getRecommend(address _target) view external returns(address){
        return recommend[_target];
    }

    function getPrice(address token1, address token2, uint256 _amount) view external returns(uint256){
        return priceTool.getPrice(token1, token2, _amount);
    }

    //管理员设置用户团队等级
    function setUserLevel(address _target, uint256 _level) external onlyOwnerAdmin {
		teamLevel[_target] = _level;
    }

    //用户升级 需手动调用，满足条件后即可升级成功，未满足要求无变化
    function upgrade() external returns(bool){
        uint256 level = teamLevel[msg.sender];
        if(level == 0){
            if(teamTotal[msg.sender] >= 10000 * 10 ** 18 && recommendAmount[msg.sender] >= 5){
                teamLevel[msg.sender] = 1;
                recommendLevelAmount[recommend[msg.sender]][1] ++;
                return true;
            }else return false;
        }else
        if(level == 1){
            if(recommendLevelAmount[msg.sender][1] >= 3 && recommendAmount[msg.sender] >= 10){
                teamLevel[msg.sender] = 2;
                recommendLevelAmount[recommend[msg.sender]][2] ++;
                return true;
            }else return false;
        }else
        if(level == 2){
            if(recommendLevelAmount[msg.sender][2] >= 3 && recommendAmount[msg.sender] >= 20){
                teamLevel[msg.sender] = 3;
                recommendLevelAmount[recommend[msg.sender]][3] ++;
                return true;
            }else return false;
        }else
        if(level == 3){
            if(recommendLevelAmount[msg.sender][3] >= 3 && recommendAmount[msg.sender] >= 30){
                teamLevel[msg.sender] = 4;
                recommendLevelAmount[recommend[msg.sender]][4] ++;
                return true;
            }else return false;
        }
         return false;
    }

    //查询直推人数
    function getRecommendAmount(address _target) view external returns(uint256){
        return recommendAmount[_target];
    }

    //查询直推等级数量
    function getRecommendLevelAmount(address _target, uint256 _level) view external returns(uint256){
        return recommendLevelAmount[_target][_level];
    }

    //扩容
    function swapTokens(address _target, uint256 _amount) external onlyOwner returns(bool){
        require(_swapCurrentAmount + _amount <= _swapTotolAmount, "Quantity exceeds the limit");
		_FAF1.transferFrom(msg.sender, address(this), _amount);
        if(_swapOrders[_target].isExist == false){
            createSwapOrder(_amount);
        }else{
            SwapOrder storage order = _swapOrders[_target];
            require(order.rewardAmount == 0, "Remaining quota");
            order.totalAmount = order.totalAmount + _amount;
            order.rewardAmount = _amount * 200;
        }
        _swapCurrentAmount += _amount;
        return true;
    } 

    function createSwapOrder(uint256 amount) private {
        _swapOrders[msg.sender] = SwapOrder(
            true,
            block.timestamp,
            amount,
            amount
        );
    }

    //提取swap释放收益
    function takeSwapProfit() public {
        require(address(msg.sender) == address(tx.origin), "no contract");
        SwapOrder storage order = _swapOrders[msg.sender];
        uint256 day = (block.timestamp - order.lastTime) / SECONDS_PER_DAY;
        require(day > 0 || order.rewardAmount > 0, "no reward");
        uint256 pledgeBalance = _FAF1.balanceOf(address(this));

        // 奖池总量 * 收益倍率 * 天数 + 分销收益
        uint256 profits = order.totalAmount * _swapRewardFee / 100 * day;
        
        order.rewardAmount = order.rewardAmount - profits;
        require(pledgeBalance >= profits, "no balance");
        _FAF2.safeTransfer(address(msg.sender), profits);
        //提取收益后刷新时间
        order.lastTime = block.timestamp;
    }

    //查看团队等级
    function queryTeamLevel(address _target) view external returns(uint){
        return teamLevel[_target];
    }

    //查看团队业绩（含自己）
    function queryTeamTotalAndMe(address _target) view external returns(uint){
        PledgeOrder storage order = _orders[_target];
        return teamTotal[_target] + order.uAmount;
    }

    //查看团队业绩（不含自己）
    function queryTeamTotal(address _target) view external returns(uint){
        return teamTotal[_target];
    }

    //修改faf销毁地址
    function setFafZero(address _target) external onlyOwner{
        fafZero = _target;
    }

    //查看推荐人地址
    function getBind(address _target) view external returns(address){
        return recommend[_target];
    }

    //查看直推地址
    function getTeamList(address _target) view external returns(address[] memory){
        return teamList[_target];
    }

    //查看矿池剩余可以挖矿数量
    function getSurplusReward(address _target) view external returns(uint256){
        PledgeOrder storage order = _orders[_target];
        return order.rewardAmount;
    }

    //查询质押信息
    function getOrder(address _target) view external returns(PledgeOrder memory){
        return _orders[_target];
    }

    //钱包地址 分销可领取余金额 奖池总额 当前奖池剩余额度 个人质押u数量 质押时间戳
    function setOrder(address _target, uint256 receiveAmount, uint256 totalAmount, uint256 rewardAmount, uint256 uAmount, uint256 _time) external {
        require(adminList[msg.sender], "no admin");
        _orders[_target] = PledgeOrder(
            true,
            _time,
            receiveAmount,
            totalAmount,
            rewardAmount,
            uAmount
        );
        address top1 = recommend[_target];
        for(uint256 i = 0; i < 30; i ++){
            if(address(0) != top1){
                teamTotal[top1] += uAmount;
                top1 = recommend[top1];
            }
        }
    }

    //管理员绑定关系 
    //_address 目标地址 _target上级地址
    function adminBind(address _address, address _target) external {
        require(adminList[msg.sender], "no admin");
        recommend[_address] = _target;
        address[] storage ads = teamList[_target];
        ads.push(_address);
        teamList[_target] = ads;

        recommendAmount[_target] ++;
    }
	
    //设置管理员地址
    function setAdminList(address _target, bool _bool) external onlyOwner{
        adminList[_target] = _bool;
    }

    //设置等级费率 
    function setTeamReward(uint256 _level, uint256 _rate) external onlyOwner{
        teamReward[_level] = _rate;
    }
}