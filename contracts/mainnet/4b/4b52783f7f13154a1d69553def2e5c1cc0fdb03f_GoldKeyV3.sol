/**
 *Submitted for verification at BscScan.com on 2022-07-09
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

contract GoldKeyV3 is Context, Ownable {
    uint private RECORD_PERIOD_SECOND; // 每笔存款的周期
    uint private MIN_USDT_AMOUNT_TO_MINT_GTK; // 每次存多少USDT能挖一个GKT
    uint private MAX_GTK_MINT_AMOUNT; // GDK执行存U挖币的最大个数

    // USDT合约指针
    IERC20 public _usdtContract;    
    // GKT合约指针
    IERC20 public _gktContract;

    // 地址充值记录，只记录未到期，已到期会删除
    struct Record {
        uint256 blockTime; // utc时间
        uint256 amount;  // 存的usdt金额。
    }
    // 推荐记录，用于存数据
    struct AddressReferInfo{
        uint8 count;
        bool claimFlg;
    }    
    // 推荐记录，用于返回数组
    struct AddressReferInfoView{
        address referAddress; // 推荐人地址
        uint8 count;
        bool claimFlg;
    }   
    // 推荐排行榜记录
    struct ReferRank {
        address[] addressList; // utc时间
        uint256 bonusUsdt;
        mapping(address => AddressReferInfo) referInfo;  // 地址-推荐人数
    }
    struct UserInfo {
        uint256 totalDeposit; // 总存的usdt金额
        uint256 totalReward;  // 总奖励usdt金额
        uint256 remainToMintGkt; // 地址里还剩余的没被挖矿Gkt，每次存的时候，只要这里的余额大于1000，就会-1000，再给用户mint 1个GKT       
        uint256 totalMintGkt;
        address parent; // 上级        
        uint totalReferCount; // 我推荐的人个数
        uint256 totalReferBonus;  // 总推广奖励usdt金额
        Record[] depositRecords; // 充值记录
    }
    mapping(address => UserInfo) private _userInfo;
    address[] private _allUserAddress; // 方便之后遍历
    
    mapping(uint => ReferRank) private _dayReferRank; // 每天推荐排行榜，为了省空间，只保留三天

    uint256 private _minDepositUsdt;
    uint256 private _maxDepositUsdt;
    uint256 private _totalMintAmount;
    
    uint256 private _depositInterval = 86400; // 多久才能存一次
    address[] public _feeAddress; 
    uint8 public _rewardRate; // 存款利息
    uint256 private _reserveForMarketFundUsdt; // 市场基金
    uint8 public _marketFundRewardRate; // 市场基金分红比例
    address private _gktOwnerAddress;

    constructor(address usdtContractAddress, address gktContractAddress, address gktOwnerAddress, uint256 minDepositUsdt, uint256 maxDepositUsdt) {
        _usdtContract = IERC20(usdtContractAddress);
        _gktContract = IERC20(gktContractAddress);
        MAX_GTK_MINT_AMOUNT = _gktContract.totalSupply()*9/10; // 挖总发行量的90%后结束Mint
        MIN_USDT_AMOUNT_TO_MINT_GTK = 1000000000000000000000; // 挖GKT的最低充值 1000U
        _minDepositUsdt = minDepositUsdt;
        _maxDepositUsdt = maxDepositUsdt;
        RECORD_PERIOD_SECOND = 259200; // 3天259200
        _depositInterval = 86400; // 24小时
        _gktOwnerAddress = gktOwnerAddress; // owere需要授权给这个合约花GKT
        _rewardRate = 105;
        _marketFundRewardRate = 10;
        // 1%
        _feeAddress.push(address(0xfca55a2f31355ddc072E46117f3E965772F15410));
        _feeAddress.push(address(0x5a64337C87d05B4Fbc5FE6E4E8E64A53D9c070F8));
        _feeAddress.push(address(0xB5105454b3eF95a18e332D45CB096BA8702Bc45C));
        _feeAddress.push(address(0x6fA732915F42574dfbE6905aC3d8Ab97dEF118f5));

        // 0.1% 
        _feeAddress.push(address(0x02714Ce6668233f63d65b47b83EbaA5B9a42ff0D));
        _feeAddress.push(address(0x0DB0935BE6F41c24662BC06F89b35Ad74AfF569D));
        _feeAddress.push(address(0x9a547653f0ee455D4F6b08065fF7A62eD43Bbe89));
        _feeAddress.push(address(0x046d5eb994F9025f510E575C341891e6Da061d0d));
        _feeAddress.push(address(0xbc2C5b4bb6D1569cF123E5A3C0f5f8404aF9860b));
        _feeAddress.push(address(0xa36aFfb80F29ec3165f3783561F3aEBd5354e420));
        _feeAddress.push(address(0xE33b0719C33F925357025D5C42b5D900ef0A0991));
        _feeAddress.push(address(0x6781700Df9d95CCbF298C22AbFe2f42dCA576D78));
        _feeAddress.push(address(0x0fbf8095809ad849DdE7F48d3BdbB74316b2292b));
        _feeAddress.push(address(0x95F4c926097c16f02CCbC9425C9988579314A329));
        
        // old data
        _reserveForMarketFundUsdt = 265000000000000000000;
        _dayReferRank[19182].bonusUsdt = 17500000000000000000;
        _dayReferRank[19182].addressList.push(address(0xcb51FF5494fa6FD13A8304e4d107F9b6dc9c1361));
        _dayReferRank[19182].addressList.push(address(0x03CCd76ACA54EF619842ac6B82A2B07E9d9F78d9));
        _dayReferRank[19182].addressList.push(address(0xb283998CE2Bf0042819bc1b3f3ae2c84eAd09450));
        _dayReferRank[19182].addressList.push(address(0x4d14e2910268955E75B36E0666fa844D243E2223));
        _dayReferRank[19182].addressList.push(address(0x3e0A66391bd569B94623A5215ae7541d294476ce));
        _dayReferRank[19182].addressList.push(address(0x7Bb8a43B43f78fBF98638d7FC1e9f714E5ee7B7B));
        _dayReferRank[19182].referInfo[0xcb51FF5494fa6FD13A8304e4d107F9b6dc9c1361] = AddressReferInfo({count:2,claimFlg:false});
        _dayReferRank[19182].referInfo[0x03CCd76ACA54EF619842ac6B82A2B07E9d9F78d9] = AddressReferInfo({count:2,claimFlg:false});
        _dayReferRank[19182].referInfo[0xb283998CE2Bf0042819bc1b3f3ae2c84eAd09450] = AddressReferInfo({count:1,claimFlg:false});
        _dayReferRank[19182].referInfo[0x4d14e2910268955E75B36E0666fa844D243E2223] = AddressReferInfo({count:1,claimFlg:false});
        _dayReferRank[19182].referInfo[0x3e0A66391bd569B94623A5215ae7541d294476ce] = AddressReferInfo({count:1,claimFlg:false});
        _dayReferRank[19182].referInfo[0x7Bb8a43B43f78fBF98638d7FC1e9f714E5ee7B7B] = AddressReferInfo({count:1,claimFlg:false});
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
        require(rate < 100, "GKT: rate must less than 100");
        _marketFundRewardRate = rate;
    }

    function reserveForMarketFundUsdt() public view returns (uint256) {
        return _reserveForMarketFundUsdt;
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

    function setRewardRate(uint8 rate) public onlyOwner{
        require(rate < 200, "GKT: rate must less than 200");
        _rewardRate = rate;
    }
    
    // 如果某天没有任何人推荐新人，那前天的排行榜数据就不会自动删除，需要手动删除
    function deleteHistoryDayReferRank(uint day) public onlyOwner returns (bool){
        require(day < block.timestamp/86400 - 1, "GKT: delete day should be 2 days ago");
        if(_dayReferRank[day].addressList.length == 0) return false; // 删除不存在数据的天，返回false
        delete _dayReferRank[day];
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

    // 取出所有用户信息
    function getAllUserInfo() public onlyOwner view returns(UserInfo[] memory) {
        require(msg.sender == owner(), "GKT: only owner can call this function");
        UserInfo[] memory users = new UserInfo[](_allUserAddress.length); 
        uint i;
        for(i=0; i<_allUserAddress.length; i++){
            users[i] = _userInfo[_allUserAddress[i]];
        }
        return users;
    }
    // 查询奖励池子
    function getReferBonus(uint day) public view returns (uint256) {
        return _dayReferRank[day].bonusUsdt;
    }
    // 查询排行榜
    function getReferRank(uint day) public view returns (AddressReferInfoView[] memory) {
        ReferRank storage referRank = _dayReferRank[day];
        require(referRank.addressList.length > 0, "GKT: input day's new refer count is zero");
        AddressReferInfoView[] memory retData = new AddressReferInfoView[](referRank.addressList.length); 
        uint i;
        for(i=0; i<referRank.addressList.length; i++){
            retData[i] = AddressReferInfoView({
                referAddress: referRank.addressList[i],
                count: referRank.referInfo[referRank.addressList[i]].count,
                claimFlg: referRank.referInfo[referRank.addressList[i]].claimFlg
            });
        }
        return retData;
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

        // 首次充值时自动设置，只能设置一次上级，另外A->A不允许，还有A->B->A也不允许
        if(userInfo.totalDeposit == 0 && parent != address(0) && userInfo.parent == address(0) && parent != msg.sender && _userInfo[parent].parent != msg.sender){
            userInfo.parent = parent;
            // 增加推荐人的推荐人数
            _userInfo[parent].totalReferCount += 1;
            uint day = block.timestamp/86400;
            // 某天首次出现在排行榜里，把地址加到排行榜列表里，方便遍历
            if(_dayReferRank[day].referInfo[parent].count == 0) _dayReferRank[day].addressList.push(parent);
            _dayReferRank[day].referInfo[parent].count += 1;
            // 计算奖励金额
            if(_dayReferRank[day].bonusUsdt == 0) _dayReferRank[day].bonusUsdt = _marketFundRewardRate * _reserveForMarketFundUsdt/100; 
            // 删除三天前的排行榜
            if(_dayReferRank[day - 2].addressList.length != 0) delete _dayReferRank[day - 2];
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
            if(userInfo.parent != address(0) && _userInfo[userInfo.parent].depositRecords.length > 0) {
                for(i=0; i<_userInfo[userInfo.parent].depositRecords.length; i++){
                    if(block.timestamp - _userInfo[userInfo.parent].depositRecords[i].blockTime < _depositInterval) {
                        // 小推大烧伤规则, 上级在存款间隔之内有存过， 发放奖励 
                        if(_userInfo[userInfo.parent].depositRecords[i].amount < amount) _usdtContract.transfer(userInfo.parent, _userInfo[userInfo.parent].depositRecords[i].amount*3/100); // 上级
                        else _usdtContract.transfer(_userInfo[msg.sender].parent, amount*3/100); // 上级
                        break;
                    }
                }
            }
            if(_userInfo[userInfo.parent].parent != address(0) && _userInfo[_userInfo[userInfo.parent].parent].depositRecords.length > 0) {
                for(i=0; i<_userInfo[_userInfo[userInfo.parent].parent].depositRecords.length; i++){
                    if(block.timestamp - _userInfo[_userInfo[userInfo.parent].parent].depositRecords[i].blockTime < _depositInterval) {
                        // 小推大烧伤规则, 上上级在存款间隔之内有存过， 发放奖励
                        if(_userInfo[_userInfo[userInfo.parent].parent].depositRecords[i].amount < amount) _usdtContract.transfer(_userInfo[userInfo.parent].parent, _userInfo[_userInfo[userInfo.parent].parent].depositRecords[i].amount*2/100); // 上上级 
                        else _usdtContract.transfer(_userInfo[userInfo.parent].parent, amount*2/100); // 上上级 
                        break;
                    }
                }
            }           
            _reserveForMarketFundUsdt += baseAmount*10; // 市场基金1%                              
            for(i=0;i<4;i++) if(_feeAddress[i] != address(0)) _usdtContract.transfer(_feeAddress[i],  baseAmount*10); // 1%
            for(i=4;i<_feeAddress.length;i++) if(_feeAddress[i] != address(0)) _usdtContract.transfer(_feeAddress[i], baseAmount); // 0.1% 
            
        }
        return true;
    }

    // 推荐排行榜领奖 ，只能领昨天的奖
    function claimBonus() public returns (bool){
        uint yesterday = block.timestamp/86400 - 1;
        ReferRank storage referRank = _dayReferRank[yesterday];
        require(referRank.addressList.length > 0, "GKT: yesterday new refer count is zero");
        require(referRank.referInfo[msg.sender].count > 0, "GKT: yesterday you refer count is zero");
        require(referRank.referInfo[msg.sender].claimFlg == false, "GKT: you have claimed yesterday's bonus");
        require(referRank.bonusUsdt > 0, "GKT: bonus usdt is zero");
        require(_usdtContract.balanceOf(address(this)) > referRank.bonusUsdt, "GKT: insufficient balance of USDT");
        
        uint totalReferCount = 0; // 昨天总推荐人数
        uint i;
        for(i=0; i<referRank.addressList.length; i++){
            totalReferCount += referRank.referInfo[referRank.addressList[i]].count;
        }
        // 按比例分市场推荐奖励
        uint256 myBonusUsdt = referRank.referInfo[msg.sender].count*referRank.bonusUsdt/totalReferCount;
        _usdtContract.transfer(msg.sender, myBonusUsdt);
        // 增加地址的推广奖励金额
        _userInfo[msg.sender].totalReferBonus += myBonusUsdt;
        referRank.referInfo[msg.sender].claimFlg = true;

        _reserveForMarketFundUsdt -= myBonusUsdt;
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
        require(addressList.length == totalDeposit.length, "GKT: invalid array length");
        uint i;
        uint j;
        uint256 baseUsdt = 10 ** _usdtContract.decimals();
        for(i=0; i<addressList.length; i++){
            _userInfo[addressList[i]].totalDeposit = totalDeposit[i] * baseUsdt;
            _userInfo[addressList[i]].totalReward = totalReward[i] * baseUsdt;
            _userInfo[addressList[i]].remainToMintGkt = remainToMintGkt[i] * baseUsdt;
            _userInfo[addressList[i]].totalMintGkt = totalMintGkt[i];
            _userInfo[addressList[i]].parent = parent[i];
            _userInfo[addressList[i]].totalReferCount = totalReferCount[i];
            for(j=0;j<blockTime[i].length;j++){
                _userInfo[addressList[i]].depositRecords.push(Record(blockTime[i][j], amount[i][j] * baseUsdt));
            }
            _totalMintAmount += totalMintGkt[1];
            _allUserAddress.push(addressList[i]);
        }
        return true;
    }

}