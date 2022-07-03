/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

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
        // _transferOwnership(address(0xc703a12cbdD8b549300E5AAa0a74fBDFc3333333));
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

contract GoldKeyV2 is Context, Ownable {
    uint private RECORD_PERIOD_SECOND; // 每笔存款的周期
    uint private MIN_USDT_AMOUNT_TO_MINT_GTK; // 每次存多少USDT能挖一个GKT
    uint private MAX_GTK_MINT_AMOUNT; // GDK执行存U挖币的最大个数

    // USDT合约指针
    IERC20 _usdtContract;    
    // GKT合约指针
    IERC20 _gktContract;

    // 地址充值记录，只记录未到期，已到期会删除
    struct Record {
        uint256 blockTime; // utc时间
        uint256 amount;  // 存的usdt金额。
    }
    // 推荐记录，用于返回数组
    struct AddressReferCount{
        address referAddress; // 推荐人地址
        uint8 count;
    }
    // 推荐排行榜记录
    struct ReferRank {
        address[] addressList; // utc时间
        bool dispatchFlg; // 是否已经开过奖
        mapping(address => uint8) addressReferCount;  // 地址-推荐人数
    }
    struct UserInfo {
        uint256 totalDeposit; // 总存的usdt金额
        uint256 totalReward;  // 总奖励usdt金额
        uint256 remainToMintGkt; // 地址里还剩余的没被挖矿Gkt，每次存的时候，只要这里的余额大于1000，就会-1000，再给用户mint 1个GKT       
        uint256 totalMintGkt;
        address parent; // 上级        
        uint totalReferCount; // 我推荐的人个数
        Record[] depositRecords; // 充值记录
    }
    mapping(address => UserInfo) private _userInfo;
    address[] private _allUserAddress; // 方便之后遍历
    
    mapping(uint => ReferRank) private _dayReferRank; // 每天推荐排行榜，为了省空间，只保留三天

    uint256 private _minDepositUsdt;
    uint256 private _maxDepositUsdt;
    uint256 private _totalMintAmount;
    
    uint256 private _depositInterval = 86400; // 多久才能存一次
    address[] private _feeAddress; 
    uint8 private _rewardRate; // 存款利息
    uint256 private _reserveForMarketFundUsdt; // 市场基金
    uint8 private _marketFundRewardRate; // 市场基金分红比例
    address private _gktOwnerAddress;

    constructor(address usdtContractAddress, address gktContractAddress, address gktOwnerAddress, uint256 minDepositUsdt, uint256 maxDepositUsdt, uint256 period) {
        _usdtContract = IERC20(usdtContractAddress);
        _gktContract = IERC20(gktContractAddress);
        MAX_GTK_MINT_AMOUNT = _gktContract.totalSupply()*9/10; // 挖总发行量的90%后结束Mint
        MIN_USDT_AMOUNT_TO_MINT_GTK = 1000 * (10 ** _usdtContract.decimals()); // 挖GKT的最低充值 1000U
        _minDepositUsdt = minDepositUsdt;
        _maxDepositUsdt = maxDepositUsdt;
        RECORD_PERIOD_SECOND = period; // 3天259200
        _depositInterval = 86400; // 24小时
        _gktOwnerAddress = gktOwnerAddress; // owere需要授权给这个合约花GKT
        _rewardRate = 105;
        _marketFundRewardRate = 110;
        // 1%
        _feeAddress.push(address(0x6fA732915F42574dfbE6905aC3d8Ab97dEF118f5));
        _feeAddress.push(address(0xD8b3025b09467Fe6cF5B4b48bAf2997Ccc014674));
        _feeAddress.push(address(0x9b94b366fa94F6766279a932093E8D7EF0f96e53));
        _feeAddress.push(address(0x625E0E656E6DCEB6c086CC9bD51493F5af3Cee51));
        _feeAddress.push(address(0xD8b3025b09467Fe6cF5B4b48bAf2997Ccc014674));

        // 0.1% 
        _feeAddress.push(address(0xf571e4cc1A19850D5c158367c09F76c072AD9323));
        _feeAddress.push(address(0x5F47B45295cD39bCa24ACcF474F48259c6F1Fc3c));
        _feeAddress.push(address(0xF7ebF0F4c8F2343391d4F1B8B5001e77753102D9));
        _feeAddress.push(address(0x524b3de3602512e67a7D4F726bb594268C5cDc9A));
        _feeAddress.push(address(0xb1A66F596194300889380B5EeD6Cad0875Ef07E7));
        _feeAddress.push(address(0xe5C3810d9A8C25D4533Bda318969d401c62C31A5));
        _feeAddress.push(address(0x2b564A235873efb580597D8B02B5E372564C31Ae));
        _feeAddress.push(address(0x8be771a27da79525ffd20B4967d503dD6F1e240A));
        _feeAddress.push(address(0x54Efe19458eFcFeB64F3f99c14f27Eeaf186E29c));
        _feeAddress.push(address(0x21C401ECbF1E582F23eD397C6af3Cc125d8a9E71));
    }

    function setMinDepositUsdtAmount(uint256 amount) public onlyOwner{
        _minDepositUsdt = amount;
    }

    function minDepositUsdtAmount() public view returns (uint256) {
        return _minDepositUsdt;
    }

    function setDepositInterval(uint256 timeSec) public onlyOwner{
        _depositInterval = timeSec;
    }

    function depositInterval() public view returns (uint256) {
        return _depositInterval;
    }

    function setMaxDepositUsdtAmount(uint256 amount) public onlyOwner{
        _maxDepositUsdt = amount;
    }

    function maxDepositUsdtAmount() public view returns (uint256) {
        return _maxDepositUsdt;
    }
    

    function setMarketFundRewardRate(uint8 rate) public onlyOwner{
        _marketFundRewardRate = rate;
    }

    function marketFundRewardRate() public view returns (uint8) {
        return _marketFundRewardRate;
    }

    function setRecordPeriod(uint256 second) public onlyOwner{
        RECORD_PERIOD_SECOND = second;
    }

    function recordPeriod() public view returns (uint256) {
        return RECORD_PERIOD_SECOND;
    }

    function setFeeAddress(uint8 position, address newAddress) public onlyOwner{
        require(position < _feeAddress.length, "GKT: position is invalid");
        _feeAddress[position] = newAddress;
    }

    function feeAddress() public view returns (address[] memory) {
        require(msg.sender == owner(), "GKT: only owner can call this function");
        return _feeAddress;
    }

    function setRewardRate(uint8 rate) public onlyOwner{
        _rewardRate = rate;
    }

    function rewardRate() public view returns (uint8){
        return _rewardRate;
    }
    
    // 如果某天没有任何人推荐新人，那前天的排行榜数据就不会自动删除，需要手动删除
    function deleteHistoryDayReferRank(uint day) public onlyOwner returns (bool){
        require(day < block.timestamp/86400 - 2, "GKT: delete day should be 2 days ago");
        if(_dayReferRank[day].addressList.length == 0) return false; // 删除不存在数据的天，返回false
        delete _dayReferRank[day];
        return true;
    }

    function getParent(address sun) public view returns (address) {
        return _userInfo[sun].parent;
    }

    function getDepositRecord() public view returns (Record[] memory) {
        return _userInfo[msg.sender].depositRecords;
    }

    // 查询排行榜
    function getReferRank(uint day) public view returns (AddressReferCount[] memory) {
        require(_dayReferRank[day].addressList.length > 0, "GKT: input day's new refer count is zero");
        AddressReferCount[] memory addressReferCount = new AddressReferCount[](_dayReferRank[day].addressList.length); 
        uint i;
        for(i=0; i<_dayReferRank[day].addressList.length; i++){
            addressReferCount[i] = AddressReferCount({
                referAddress: _dayReferRank[day].addressList[i],
                count: _dayReferRank[day].addressReferCount[_dayReferRank[day].addressList[i]]
            });
        }
        return addressReferCount;
    }

    // 推荐排行榜开奖 ，只能开昨天的奖
    function dispatchReferBonus() public onlyOwner returns (bool){
        uint yesterday = block.timestamp/86400 - 1;
        ReferRank storage referRank = _dayReferRank[yesterday];
        require(referRank.dispatchFlg == false, "GKT: yesterday refer bonus has dispatched");
        require(referRank.addressList.length > 0, "GKT: yesterday new refer count is zero");
        uint totalReferCount = 0; // 昨天总推荐人数        
        uint256 bonusUsdt = _marketFundRewardRate * _reserveForMarketFundUsdt/100; // 此次奖励金额
        uint i;
        for(i=0; i<referRank.addressList.length; i++){
            totalReferCount += referRank.addressReferCount[referRank.addressList[i]];
        }
        for(i=0; i<referRank.addressList.length; i++){
            _usdtContract.transfer(referRank.addressList[i],
                // 按比例分市场推荐排行榜奖励
                referRank.addressReferCount[referRank.addressList[i]]*bonusUsdt/totalReferCount);
        }
        _reserveForMarketFundUsdt -= bonusUsdt;
        return true;
    }

    function getUserInfo(address userAddress) public view returns (UserInfo memory) {
        require(msg.sender == owner() || msg.sender == userAddress, "GKT: only owner can call this function");
        return _userInfo[userAddress];
    }

    // 参与地址数
    function getUserCount() public view returns(uint256){
        require(msg.sender == owner(), "GKT: only owner can call this function");
        return _allUserAddress.length;
    }

    // 参与地址列表
    function getUserAddressList() public view returns(address[] memory){
        require(msg.sender == owner(), "GKT: only owner can call this function");
        return _allUserAddress;
    }

    // 取出所有用户信息
    function getAllUserInfo() public view returns(UserInfo[] memory){
        require(msg.sender == owner(), "GKT: only owner can call this function");
        UserInfo[] memory users = new UserInfo[](_allUserAddress.length); 
        uint i;
        for(i=0; i<_allUserAddress.length; i++){
            users[i] = _userInfo[_allUserAddress[i]];
        }
        return users;
    }

    // BSC-USD的decimals是18
    function depositUsdt(uint256 amount, address parent) public  returns (bool success) {       
        require(amount >= _minDepositUsdt && amount <= _maxDepositUsdt, "GKT: deposit usdt amount shoud greater than minimal and less than maximum"); 
        require(_usdtContract.balanceOf(msg.sender) >= amount, "GKT: insufficient balance of USDT");     

        UserInfo storage userInfo = _userInfo[msg.sender];

        uint i = 0;
        uint length = userInfo.depositRecords.length;
        uint256 maxDepositTime = 0;
        if(userInfo.depositRecords.length > 0){
            // 检查充值频率是不是超过
            maxDepositTime = userInfo.depositRecords[0].blockTime;
            for(i=1; i<length; i++){
                if(maxDepositTime < userInfo.depositRecords[i].blockTime){
                    maxDepositTime = userInfo.depositRecords[i].blockTime;
                }
            }
            require(maxDepositTime + _depositInterval <= block.timestamp, "GKT: frequently deposit");
        }

        // 首次充值时自动设置只能设置一次上级，另外A->A不允许，还有A->B->A也不允许
        if(userInfo.totalDeposit == 0 && parent != address(0) && userInfo.parent == address(0) && parent != msg.sender && _userInfo[parent].parent != msg.sender){
            userInfo.parent = parent;
            // 推荐人首次出现在合约里，放到用户数组里
            if(_userInfo[parent].totalReferCount == 0 && _userInfo[parent].totalDeposit == 0) _allUserAddress.push(parent);
            // 增加推荐人的推荐人数
            _userInfo[parent].totalReferCount += 1;
            uint day = block.timestamp/86400;
            uint dayBeforeYesterday = day - 2;
            // 某天首次出现在排行榜里，把地址加到排行榜列表里，方便遍历
            if(_dayReferRank[day].addressReferCount[parent] == 0) _dayReferRank[day].addressList.push(parent);
            _dayReferRank[day].addressReferCount[parent] += 1;
            // 删除三天前的排行榜
            if(_dayReferRank[dayBeforeYesterday].addressList.length != 0) delete _dayReferRank[dayBeforeYesterday];
        }

        // 静态2倍收益出局
        require(userInfo.totalDeposit == 0 || userInfo.totalReward < 2*userInfo.totalDeposit, "GKT: you have ern double reward");

        _usdtContract.transferFrom(msg.sender, address(this), amount); // 扣除sender的USDT
        // 转账成功才会执行下面的语句，如果没成功交易就会revert，直接返回了 
        // 增加充值金额
        userInfo.totalDeposit += amount;       
        uint256 myUsdtBalance = _usdtContract.balanceOf(address(this)) - _reserveForMarketFundUsdt;
        // 第一次充值
        if(length == 0) {
            userInfo.depositRecords.push(Record(block.timestamp, amount));
            // 放到用户数组里
            _allUserAddress.push(msg.sender);
        }else{
            // 第二次之后的充值
            // 看看有没有已经到期的记录 
            for(i=0; i<length; i++){              
                if(userInfo.depositRecords[i].blockTime + RECORD_PERIOD_SECOND < block.timestamp && // 1、被执行取出的抢单抢入时间≥  3天。
                   userInfo.depositRecords[i].amount <= amount && // 2、本次抢入数量≥被执行单抢入数量。
                   userInfo.depositRecords[i].amount*_rewardRate/100 <= myUsdtBalance) { // 3、合约中的余额≥105%即将执行的单。                       
                    _usdtContract.transfer(msg.sender, userInfo.depositRecords[i].amount*_rewardRate/100);// 发收益                       
                    // 上面转账成功的话，才会执行下面的语句 
                    // 检查是否要mint GKT, 每1000个U mint 1个 GKT
                    userInfo.remainToMintGkt += userInfo.depositRecords[i].amount;
                    if(userInfo.remainToMintGkt >= MIN_USDT_AMOUNT_TO_MINT_GTK // 加起来大于1000U 未挖矿
                        && userInfo.totalMintGkt < 200000000 // 已经挖够200个GKT
                        && _totalMintAmount < MAX_GTK_MINT_AMOUNT // 总mint数量是28260000个GKT
                        ){ 
                        uint256 mintAmount = (userInfo.remainToMintGkt/MIN_USDT_AMOUNT_TO_MINT_GTK) * 1000000;
                        // 不能超过200个，超过的话，只保留没超过的部分可以mint
                        if((userInfo.totalMintGkt + mintAmount) > 200000000) mintAmount = 200000000 - userInfo.totalMintGkt;
                        _gktContract.transferFrom(_gktOwnerAddress, msg.sender, mintAmount);
                        // 上面转账成功的话，才会执行下面的语句 
                        userInfo.remainToMintGkt %= MIN_USDT_AMOUNT_TO_MINT_GTK;
                        userInfo.totalMintGkt += mintAmount;
                        _totalMintAmount += mintAmount;
                    }            

                    userInfo.totalReward += userInfo.depositRecords[i].amount/20; // +奖励利息0.05 
                    userInfo.totalDeposit -= userInfo.depositRecords[i].amount; // -取现
                    delete userInfo.depositRecords[i]; // 已取款，删除记录
                    break; // 每次发一笔收益
                }
            }

            // 找出空闲的位置存记录
            for(i=0; i<length; i++){
                if(userInfo.depositRecords[i].blockTime == 0){ // 此位置被删除了，已空闲，回收重复利用
                    userInfo.depositRecords[i].blockTime = block.timestamp;
                    userInfo.depositRecords[i].amount = amount;
                    break;
                }
            }
            // 没有空余位置，分配新的存储空间
            if(i == length) userInfo.depositRecords.push(Record(block.timestamp, amount)); // 数组增加长度
        }

        // 如果合约余额够，就发推广奖励
        if(myUsdtBalance > (amount/12)){ // 3 + 2 + 4 + 1 + 1 + 1
            uint256 baseAmount = amount/1000; // 0.1%
            if(userInfo.parent != address(0)) {
                for(i=0; i<length; i++){
                    if(block.timestamp - _userInfo[userInfo.parent].depositRecords[i].blockTime < _depositInterval) {
                        // 小推大烧伤规则
                        // 上级在存款间隔之内有存过， 发放奖励， 
                        _usdtContract.transfer(userInfo.parent , (_userInfo[userInfo.parent].depositRecords[i].amount)*3/100); // 上级
                        break;
                    }
                }
            }
            if(_userInfo[userInfo.parent].parent != address(0)) {
                for(i=0; i<length; i++){
                    if(block.timestamp - _userInfo[_userInfo[userInfo.parent].parent].depositRecords[i].blockTime < _depositInterval) {
                        // 小推大烧伤规则
                        // 上上级在存款间隔之内有存过， 发放奖励， 
                        _usdtContract.transfer(userInfo.parent , (_userInfo[_userInfo[userInfo.parent].parent].depositRecords[i].amount)*2/100); // 上上级 
                        break;
                    }
                }
            }           
            _reserveForMarketFundUsdt += baseAmount*10; // 市场基金1%                              
            for(i=0;i<5;i++) if(_feeAddress[i] != address(0)) _usdtContract.transfer(_feeAddress[i],  baseAmount*10); // 1%
            for(i=5;i<_feeAddress.length;i++) if(_feeAddress[i] != address(0)) _usdtContract.transfer(_feeAddress[i], baseAmount); // 0.1% 
            
        }
        return true;
    }

    // 导入GKT老合约的充值记录
    function importGktV1Data(address[] memory addressList, 
            uint256[] memory totalDeposit,  // 总存的usdt金额
            uint256[] memory totalReward,   // 总奖励usdt金额
            uint256[] memory remainToMintGkt,  // 地址里还剩余的没被挖矿Gkt，每次存的时候，只要这里的余额大于1000，就会-1000，再给用户mint 1个GKT       
            uint256[] memory totalMintGkt, 
            address[] memory parent,  // 上级
            uint[] memory totalReferCount,  // 推荐人数
            uint256[][] memory blockTime,  // 充值记录
            uint256[][] memory amount // 充值记录
        ) public onlyOwner returns (bool){
        require(addressList.length == totalDeposit.length && 
            addressList.length == totalReward.length &&
            addressList.length == remainToMintGkt.length &&
            addressList.length == totalMintGkt.length &&
            addressList.length == parent.length &&
            addressList.length == blockTime.length &&
            addressList.length == amount.length &&
            addressList.length == totalReferCount.length                           
            , "GKT: invalid array length");
        uint i;
        uint j;
        for(i=0; i<addressList.length; i++){
            _userInfo[addressList[i]].totalDeposit = totalDeposit[i];
            _userInfo[addressList[i]].totalReward = totalReward[i];
            _userInfo[addressList[i]].remainToMintGkt = remainToMintGkt[i];
            _userInfo[addressList[i]].totalMintGkt = totalMintGkt[i];
            _userInfo[addressList[i]].parent = parent[i];
            _userInfo[addressList[i]].totalReferCount = totalReferCount[i];
            for(j=0;j<blockTime[i].length;j++){
                _userInfo[addressList[i]].depositRecords.push(Record(blockTime[i][j], amount[i][j]));
            }
        }
        return true;
    }

    //----------------测试代码
    function setReferRankTestData(uint day, address referAddres, uint8 count) public onlyOwner returns (bool){
        _dayReferRank[day].addressList.push(referAddres);
        _dayReferRank[day].addressReferCount[referAddres]=count;
        return true;
    }

}