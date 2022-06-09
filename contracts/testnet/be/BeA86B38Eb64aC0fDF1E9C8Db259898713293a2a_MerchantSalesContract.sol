/**
 *Submitted for verification at BscScan.com on 2022-06-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFile {
    function queryStrAddr(string memory _str) external view returns (address);
}

interface Router {
     function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (
        uint256[] memory amounts
    );
}

interface IERC20 {
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address _spender, uint256 _value) external returns (bool);
    function burn(uint256 amount) external returns (bool);
}

interface IFundManagement {
    function updateComputingPower(address _addr, uint256 _amount) external returns(bool);
}

abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

contract Ownable is Initializable{
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the management contract as the initial owner.
     */
    function __Ownable_init_unchained() internal initializer {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract MerchantSalesContract  is Initializable,Ownable {
    using SafeMath for uint256;
    IERC20 public cmmToken;
    IERC20 public usdtToken;
    Router public routerContract;
    IFundManagement public fundManagement;
    IFile public file;
    //总挖矿奖励数量
    uint256 public totalReward;
    //会员等级价格
    uint256 public memberPrice;
    //当前挖出数量
    uint256 public currentMintReward;
    //挖矿结束时间
    uint256 public miningEndTime;
    //当前每分钟奖励代币数量
    uint256 public currentRewardPerMin;
    //每分钟奖励代币数量最大数量
    uint256 public rewardPerMinMax;
     //阶梯份额
    uint256 public ladderShares;
    //阶梯挖状态
    bool public ladderStatus;
    //某地址的质押份额
    mapping(address => uint256) public shares;
    //累计份额
    uint256 public totalShares;
    //累计份额
    uint256 public staticTotalShares;
    //奖励段数
    uint256 public rewardMsgNum;
    //分段奖励数据
    mapping(uint256 => RewardMsg) public rewardMsg;
    //用户奖励数据
    mapping(address => UserRewardMsg) public userRewardMsg;
    //用户数据
    mapping(address => UserBasicMsg) public userBasicMsg;
    uint256 recommendIndex;
    mapping(uint256 => address) public recommendUser;
    mapping(address => uint256) public userRecommendID;
    //用户推荐数据
    mapping(address => UserRecommenderMsg) public userRecommenderMsg;
    //会员数量
    uint256 public memberNum;
    mapping(address => uint256) public memberIndex;
    mapping(uint256 => address) public indexMember;  
    uint256 public calcMemberAwardNum;

    struct UserRecommenderMsg {
        //用户数量
        uint256 recommendNum;
        mapping(uint256 => uint256) recommendAmount;
        mapping(uint256 => address) indexRecommend;
        mapping(uint256 => uint256) recommendType;
    }

    struct UserBasicMsg {
        //静态算力
        uint256 staticComputingPower;
        //动态算力
        uint256 dynamicComputingPower;
        //团队动态算力
        uint256 teamDynamicComputingPower;
        //会员等级
        uint256 memberLevel;
        //会员过期时间
        uint256 expiration;
        //用户推荐人
        address recommender;
    }

    struct UserRewardMsg {
        //地址已经提现的奖励
        uint256 withdrawdReward;
        //某地址最近一次关联的累计已产出总奖励
        uint256 lastAddUpReward;
        //地址当前领取第几段奖励
        uint256 rewardMsgIndex;
        //某地址上一次关联的每份额累计已产出奖励
        uint256 lastAddUpRewardPerShare;
    }

    struct RewardMsg {
        //每分钟产出奖励数量
        uint256 rewardPerMin;
        //最近一次（如果没有最近一次则是首次）挖矿区块时间，秒
        uint256 lastBlockT;
        //最近一次（如果没有最近一次则是首次）每份额累计奖励
        uint256 lastAddUpRewardPerShareAll;
        //初始每份额累计奖励
        uint256 initAddUpRewardPerShareAll;
        //结束时每份额累计奖励
        uint256 endAddUpRewardPerShareAll;
    }

    function init(address _file)  external initializer{
        __Ownable_init_unchained();
        __MerchantSalesContract_init_unchained(_file);
    }

    function __MerchantSalesContract_init_unchained(address _file) internal initializer{
        require( _file != address(0),"cmmToken address cannot be 0");
        file = IFile(_file);
        address _FundManagement = file.queryStrAddr("FundManagement");
        address _CMMToken = file.queryStrAddr("CMMToken");
        address _USDTToken = file.queryStrAddr("USDTToken");
        address _RouterContract = file.queryStrAddr("RouterContract");
        require(
            _FundManagement != address(0x0) && 
            _CMMToken != address(0x0) && 
            _USDTToken != address(0x0) && 
            _RouterContract != address(0x0), 
            "Contract address cannot be empty");
        cmmToken = IERC20(_CMMToken);
        usdtToken = IERC20(_USDTToken);
        routerContract = Router(_RouterContract);
        fundManagement = IFundManagement(_FundManagement);
        usdtToken.approve(_RouterContract, type(uint256).max);
        totalReward = 797 * 10**(8+18);
        memberPrice = 100 * 10**18;
        miningEndTime = type(uint256).max;
        currentRewardPerMin = 10 * 10**(4+18) / uint256(24 * 60);
        rewardPerMinMax = totalReward.div(100 * 365 * 24 * 60);
        ladderShares = 100000;
        recommendIndex = 515306821;
        calcMemberAwardNum =1;
    }
 function updateDatas() internal { 
        totalReward = 797 * 10**(8+18);
        memberPrice = 100 * 10**18;
        miningEndTime = type(uint256).max;
        currentRewardPerMin = 10 * 10**(4+18) / uint256(24 * 60);
        rewardPerMinMax = totalReward.div(100 * 365 * 24 * 60);
        ladderShares = 100000;
        recommendIndex = 515306821;
        calcMemberAwardNum =1;
 }

    function buyGoods(address _merchant, uint256 _amount, uint256 _recommenderId) external { 
        address _sender = msg.sender;
        uint256 timestamp = block.timestamp;
        uint256 _selfRecommenderId = _generateRecommenderId(_sender);
        require( _selfRecommenderId != _recommenderId,"The recommender cannot be yourself");
        uint256 fee = _amount.div(10);
        uint256 offsetAmount = _amount.sub(fee);
        require( usdtToken.transferFrom(msg.sender, _merchant, offsetAmount),"Token transfer failed");
        require( _burnToken(fee),"Token burn failed");
        userBasicMsg[_sender].staticComputingPower += _amount;
        userBasicMsg[_merchant].staticComputingPower += fee;
        staticTotalShares = staticTotalShares.add(_amount).add(fee);
        addComputingPower(_sender, _amount, timestamp);
        addComputingPower(_merchant, fee, timestamp);
        address _recommender = userBasicMsg[_sender].recommender;
        if(_recommender == address(0x0)){
            _recommender = recommendUser[_recommenderId];
            if(_recommender != address(0x0)){
                userBasicMsg[_sender].recommender = _recommender;
                
            }
        }
        calcRecommenderComputingPower(_sender,_amount, timestamp);
    }

    function buyMember(uint256 _grade) external { 
        require( _grade>0 && _grade < 6,"wrong grade");
        uint256 _amount;
        address _sender = msg.sender;
        UserBasicMsg storage _userBasicMsg = userBasicMsg[_sender];
        if(_userBasicMsg.memberLevel == 0){
            _amount = memberPrice.mul(_grade);
            _generateRecommenderId(_sender);
        }else {
            _amount = memberPrice.mul(_grade.sub(_userBasicMsg.memberLevel));
        }
        require( usdtToken.transferFrom(msg.sender, address(this), _amount),"Token transfer failed");
        require( _burnToken(_amount),"Token burn failed");
        _userBasicMsg.memberLevel = _grade;
        _userBasicMsg.expiration = block.timestamp.add(31536000);
        updateMember(_sender);
    }

    function _generateRecommenderId(address _sender) internal returns (uint256){
        uint256 _selfRecommenderId = userRecommendID[_sender];
        if(_selfRecommenderId == 0){
            uint256 _recommendIndex = recommendIndex++;
            userRecommendID[_sender] = _recommendIndex;
            recommendUser[_recommendIndex] = _sender;
        }
        return _selfRecommenderId;
    }
    
    function _burnToken(uint256 _amount) internal returns (bool){
        address[] memory _addrs = new address[](2);
        _addrs[0] = address(usdtToken);
        _addrs[1] = address(cmmToken);
        uint[] memory amounts = routerContract.swapExactTokensForTokens(
                                    _amount, 
                                    0, 
                                    _addrs,
                                    address(this),
                                    block.timestamp+ 3600
                                );
        bool result = cmmToken.burn(amounts[1]);
        return result;
    }

    //更新全员，添加，升级全员
    function updateMember(address _member) public{ 
        uint256 _memberIndex = memberIndex[_member];
        if( _memberIndex != 0){
            indexMember[_memberIndex] = address(0x0);
        }
            _memberIndex = ++memberNum;
            memberIndex[_member] = _memberIndex;
            indexMember[_memberIndex] = _member;

        // if( _memberIndex == 0){
        //     _memberIndex = ++memberNum;
        //     memberIndex[_member] = _memberIndex;
        //     indexMember[_memberIndex] = _member;
        // }else {
        //     address _nextMember;
        //     uint256 _nextMemberIndex;
        //     while(_memberIndex < memberNum){
        //         _nextMemberIndex = _memberIndex+1;
        //         _nextMember = indexMember[_nextMemberIndex];
        //         if(userBasicMsg[_member].expiration > userBasicMsg[_nextMember].expiration){
        //             memberIndex[_member] = _nextMemberIndex;
        //             indexMember[_nextMemberIndex] = _member;
        //             memberIndex[_nextMember] = _memberIndex;
        //             indexMember[_memberIndex] = _nextMember;
        //         }else{
        //             break;
        //         }
        //         _memberIndex++;
        //     }
        // }
    }

    //计算过期会员奖励
    function handleMemberAward(uint256 _memberNum) internal{
        uint256 _calcMemberAwardNum = calcMemberAwardNum + _memberNum; 
        if(_calcMemberAwardNum > memberNum){
            _calcMemberAwardNum = memberNum;
        }
        calcMemberAward(_calcMemberAwardNum);
    }

    //计算过期会员奖励
    function calcMemberAward(uint256 _memberNum) public{
        uint256 _calcMemberAwardNum = calcMemberAwardNum; 
        address _member;
        UserBasicMsg memory _userBasicMsg;
        while(_calcMemberAwardNum <= _memberNum){
            _member = indexMember[_calcMemberAwardNum];
            if(_member != address(0x0) && _userBasicMsg.expiration <= block.timestamp){
                _userBasicMsg = userBasicMsg[_member];
                subsideComputingPower(_member, _userBasicMsg.teamDynamicComputingPower, _userBasicMsg.expiration);
                _calcMemberAwardNum++;
            }else{
                calcMemberAwardNum = _calcMemberAwardNum;
                break;
            }
        }
    }

    function recordUserRecommenderMsg(address _recommender, uint256 _amount, uint256 _recommendType) public{
        UserRecommenderMsg storage _userRecommenderMsg = userRecommenderMsg[_recommender];
        uint256 _recommendNum = ++_userRecommenderMsg.recommendNum;
        _userRecommenderMsg.recommendAmount[_recommendNum] = _amount;
        _userRecommenderMsg.indexRecommend[_recommendNum] = _recommender;
        _userRecommenderMsg.recommendType[_recommendNum] = _recommendType;
    }

    function calcRecommenderComputingPower(address _sender, uint256 _amount, uint256 timestamp) public { 
        uint256 percent = _amount/100;
        uint256 percentAmount;
        address recommender = userBasicMsg[_sender].recommender;
        uint256 i =1;
        while (recommender!= address(0x0)) {
            if(i == 1){
                percentAmount = percent*10;
                addComputingPower(recommender, percentAmount, timestamp);
                userBasicMsg[recommender].dynamicComputingPower += percentAmount;
                recordUserRecommenderMsg(recommender, percentAmount, 1);
                recommender = calcTeamComputingPower(recommender, 1, percentAmount, timestamp);
            }else if(i == 2){
                percentAmount = percent*8;
                addComputingPower(recommender, percentAmount, timestamp);
                userBasicMsg[recommender].dynamicComputingPower += percentAmount;
                recordUserRecommenderMsg(recommender, percentAmount, 2);
                recommender = calcTeamComputingPower(recommender, 1, percentAmount, timestamp);
            }else if(i == 3){
                percentAmount = percent*5;
                recommender = calcTeamComputingPower(recommender, 1, percentAmount, timestamp);
            }else if(i == 4){
                percentAmount = percent*2;
                recommender = calcTeamComputingPower(recommender, 2, percentAmount, timestamp);
            }else if(i == 5){
                percentAmount = percent*3;
                recommender = calcTeamComputingPower(recommender, 2, percentAmount, timestamp);
            }else if(i == 6){
                recommender = calcTeamComputingPower(recommender, 3, percent, timestamp);
            }else if(i == 7){
                percentAmount = percent*2;
                recommender = calcTeamComputingPower(recommender, 3, percentAmount, timestamp);
            }else if(i == 8 || i == 9){
                recommender = calcTeamComputingPower(recommender, 4, percent, timestamp);
            }else if(i == 10 || i == 11){
                recommender = calcTeamComputingPower(recommender, 5, percent, timestamp);
            }
            i++;
            if(i == 12){
                break;   // break 语句跳出循环
            }
        }
    }

    function calcTeamComputingPower(address _recommender, uint256 _memberLevel, uint256 _percent, uint256 timestamp) internal returns(address){ 
        address recommender = userBasicMsg[_recommender].recommender;
        if(userBasicMsg[recommender].memberLevel >= _memberLevel && userBasicMsg[recommender].expiration > block.timestamp){
            addComputingPower(recommender, _percent, timestamp);
            userBasicMsg[recommender].teamDynamicComputingPower += _percent;
        }
        return recommender;
    }

    function addComputingPower(address _sender, uint256 _amount,uint256 timestamp) public {   
        if(!ladderStatus && staticTotalShares > ladderShares){
            ladderShares = ladderShares.mul(3).div(2);
            uint256 _rewardMsgNum = rewardMsgNum++;
            RewardMsg storage lastRewardMsg = rewardMsg[_rewardMsgNum];
            RewardMsg storage currentRewardMsg = rewardMsg[rewardMsgNum];
            currentRewardPerMin = currentRewardPerMin.mul(6).div(5);
            if(currentRewardPerMin >= rewardPerMinMax){
                ladderStatus = true;
                currentRewardPerMin = rewardPerMinMax;
            }
            currentRewardMsg.rewardPerMin = currentRewardPerMin;
            uint256 currenTotalRewardPerShare = getRewardPerShare(timestamp,lastRewardMsg);
            lastRewardMsg.endAddUpRewardPerShareAll = currenTotalRewardPerShare;
            currentMintReward = currentMintReward.add(timestamp.sub(lastRewardMsg.lastBlockT).mul(lastRewardMsg.rewardPerMin).div(60));
            if(ladderStatus){
                uint256 surplusReward = totalReward.sub(currentMintReward);
                miningEndTime = surplusReward.div(currentRewardMsg.rewardPerMin).div(60).add(timestamp);
            }
            currentRewardMsg.lastBlockT = timestamp;
            currentRewardMsg.initAddUpRewardPerShareAll = currenTotalRewardPerShare;
            currentRewardMsg.lastAddUpRewardPerShareAll = currenTotalRewardPerShare;
        }
        calcAwardData(_sender, timestamp);
        require(fundManagement.updateComputingPower(_sender, _amount), "LianchuangAccount update ComputingPower failed");
        updateShare(_sender, true, _amount);
    } 

    function subsideComputingPower(address _sender, uint256 _amount,uint256 timestamp) internal {   
        require(_amount <= shares[_sender], "UNSTAKE_AMOUNT_MUST_LESS_SHARES");
        //stakeToken.transferFrom(this.address, _sender, _amount); 
        calcAwardData(_sender, timestamp);
        updateShare(_sender, false, _amount);
    }

    function calcAwardData(address _sender, uint256 timestamp) internal {   
        uint256 _rewardMsgNum = rewardMsgNum;
        if(_rewardMsgNum > 0){
            if(timestamp > miningEndTime){
                timestamp = miningEndTime;
            }
            (uint256 _reward, uint256 _currenTotalRewardPerShare) = getaddupReword(_sender, timestamp);
            UserRewardMsg storage _userRewardMsg = userRewardMsg[_sender];
            _userRewardMsg.lastAddUpReward += _reward;
            _userRewardMsg.rewardMsgIndex = _rewardMsgNum;
            _userRewardMsg.lastAddUpRewardPerShare = _currenTotalRewardPerShare;
            RewardMsg storage _rewardMsg = rewardMsg[_rewardMsgNum];
            if(_rewardMsg.lastBlockT != timestamp){
                currentMintReward = currentMintReward.add(timestamp.sub(_rewardMsg.lastBlockT).mul(_rewardMsg.rewardPerMin).div(60));
                _rewardMsg.lastBlockT = timestamp;
                _rewardMsg.lastAddUpRewardPerShareAll = _currenTotalRewardPerShare;
            }
        }
    }

    function updateShare(address _sender, bool _type, uint256 _amount) internal {  
        if(_type){
            shares[_sender] = shares[_sender].add(_amount);
            totalShares = totalShares.add(_amount);
        }else {
            shares[_sender] = shares[_sender].sub(_amount);
            totalShares = totalShares.sub(_amount);
        }
    }

    //计算累计奖励,【内部调用/合约创建者/不需要支付/只读】
    /// @notice 仅供内部调用，统一计算规则
    function getaddupReword(address _address, uint256 timestamp) 
        public 
        view 
        returns(uint256, uint256)
    {   
        uint256 _shares = shares[_address];
        uint256 _reward = 0;
        uint256 _rewardMsgNum = rewardMsgNum;
        uint256 currenTotalRewardPerShare;
        RewardMsg memory _rewardMsg;
        if(_shares ==0){
            if(_rewardMsgNum > 0){
                _rewardMsg =  rewardMsg[_rewardMsgNum];
                currenTotalRewardPerShare = getRewardPerShare(timestamp, _rewardMsg);
            }
            return (_reward, currenTotalRewardPerShare);
        }else{
            UserRewardMsg storage _userRewardMsg = userRewardMsg[_address];
            uint256 i = _userRewardMsg.rewardMsgIndex;
            if(i ==0){
                i = 1;
            }else if(i < _rewardMsgNum){
                _rewardMsg =  rewardMsg[i];
                _reward = _reward.add(_rewardMsg.endAddUpRewardPerShareAll.sub(_userRewardMsg.lastAddUpRewardPerShare));
                i++;
            }
            for(i; i < _rewardMsgNum; i++){
                _rewardMsg =  rewardMsg[i];
                _reward = _reward.add(_rewardMsg.endAddUpRewardPerShareAll.sub(_rewardMsg.initAddUpRewardPerShareAll));
            }
            _rewardMsg =  rewardMsg[_rewardMsgNum];
            currenTotalRewardPerShare = getRewardPerShare(timestamp, _rewardMsg);
            if (_rewardMsgNum ==  _userRewardMsg.rewardMsgIndex) {
                _reward = _reward.add(currenTotalRewardPerShare.sub(_userRewardMsg.lastAddUpRewardPerShare));
            } else {
                _reward = _reward.add(currenTotalRewardPerShare.sub(_rewardMsg.initAddUpRewardPerShareAll));
            }
            _reward = _reward.mul(_shares).div(10**8);
            return (_reward, currenTotalRewardPerShare);
        }
    }

    //获取截至当前每份额累计产出,【内部调用/合约创建者/不需要支付/只读】
    /// @notice 1.（当前区块时间戳-具体当前最近一次计算的时间戳） * 每分钟产出奖励 / 60秒 / 总份额  + 
    ///                                距离当前最近一次计算的时候的每份额累计奖励 = 当前每份额累计奖励 
    /// @notice 2. 更新最近一次计算每份额累计奖励的时间和数量 
    function getRewardPerShare(uint256 timestamp, RewardMsg memory _rewardMsg) 
        public 
        view  
        returns(uint256)
    {   
        return timestamp.sub(_rewardMsg.lastBlockT).mul(_rewardMsg.rewardPerMin * 10**8).div(60).div(totalShares).add(_rewardMsg.lastAddUpRewardPerShareAll);
    }

    
    //计算可提现奖励,【内部调用/合约创建者/不需要支付/只读】
    /// @notice 仅供内部调用，统一计算规则
    function getWithdrawdReword(address _address) 
        public 
        view 
        returns(uint256, uint256)
    {   
        uint256 timestamp = block.timestamp;
        if(timestamp > miningEndTime){
            timestamp = miningEndTime;
        }
        UserRewardMsg storage _userRewardMsg = userRewardMsg[_address];
        (uint256 _reward, ) = getaddupReword(_address, timestamp);
        uint256 _WithdrawdReward = _userRewardMsg.lastAddUpReward.add(_reward).sub(_userRewardMsg.withdrawdReward);
        return (_WithdrawdReward, _userRewardMsg.withdrawdReward);
    }

    //提现收益,【外部调用/所有人/不需要支付/读写】
    /// @notice 1. 计算截至到当前的累计获得奖励
    /// @notice 2. _amount必须<=(累计获得奖励-已提现奖励)
    /// @notice 3. 提现，提现需要先增加数据，再进行提现操作
     function withdraw(uint256 _amount) 
        external 
    {   
        uint256 timestamp = block.timestamp;
        address _sender = msg.sender;
        calcAwardData(_sender, timestamp);
        (uint256 _WithdrawdReward, ) = getWithdrawdReword(_sender);
        require(_amount <= _WithdrawdReward, "WITHDRAW_AMOUNT_LESS_ADDUPREWARD");
        UserRewardMsg storage _userRewardMsg = userRewardMsg[_sender];
        _userRewardMsg.withdrawdReward = _userRewardMsg.withdrawdReward.add(_amount);
    }

    function queryRecommenderMsg(
        address _recommender,
        uint256 _page,
        uint256 _limit
    )
        external
        view
        returns(
            address[] memory,
            uint256[] memory,
            uint256[] memory,
            uint256 
        )
    {   
        UserRecommenderMsg storage _userRecommenderMsg = userRecommenderMsg[_recommender];
        uint256 _num = _userRecommenderMsg.recommendNum;
        if (_limit > _num){
            _limit = _num;
        }
        if (_page<2){
            _page = 1;
        }
        _page--;
        uint256 start = _page.mul(_limit);
        uint256 end = start.add(_limit);
        if (end > _num){
            end = _num;
            _limit = end.sub(start);
        }
        start = _num - start;
        end = _num - end; 
        address[] memory recommenders = new address[](_limit);
        uint256[] memory amounts = new uint256[](_limit);
        uint256[] memory types = new uint256[](_limit);
        if (_num > 0){
            uint256 j;
            for (uint256 i = start; i > end; i--) {
                recommenders[j] = _userRecommenderMsg.indexRecommend[i];
                amounts[j] = _userRecommenderMsg.recommendAmount[i];
                types[j] = _userRecommenderMsg.recommendType[i];
                j++;
            }
        }
        return (recommenders, amounts, types, _num);
    }

    


}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}