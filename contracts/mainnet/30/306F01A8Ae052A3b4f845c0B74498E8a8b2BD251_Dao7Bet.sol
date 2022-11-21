/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}


interface IDao7Topic{

    function getInvitationAmount(address token,address userAddress) external view returns(uint256);

    function getWinAmount(address token,address userAddress) external view returns(uint256);

    function getCancelAmount(address token,address userAddress) external view returns(uint256);

    function getBetAmount(address token) external view returns (uint256);

    function getBetAmountOfUser(address token,address userAddress) external view returns (uint256);

    function betFrom(address token,address userAddress,uint256 amount,uint256 optionId,uint256 inviteCode) external;

    function withdrawFrom(address token,address userAddress) external;

    function withdrawCancelFrom(address token,address userAddress) external;

    function withdrawFeeFrom(address token) external;

    function openBet(uint256 _trueOption) external;

    function openBetOfToken(address token,uint256 _trueOption) external;
    
    function approveMainContract(address token) external;

    function getWithdrawFlag(address token,address userAddress) external view returns(bool);

    function getWithdrawCancelFlag(address token,address userAddress) external view returns(bool);

    function getFeeAmount(address token) external view returns(uint256);

    function getWithdrawFeeFlag(address token) external  view returns(bool);
}

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

contract Ownable {
    address public owner;
    mapping(address => bool) public admins;

    event owneresshipTransferred(address indexed previousowneres, address indexed newowneres);
    event adminshipTransferred(address indexed previousowneres, address indexed newowneres);

    modifier onlyowneres() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyadmin() {
        require(admins[msg.sender]);
        _;
    }

    function transferowneresship(address newowneres) public onlyowneres {
        require(newowneres != address(0));
        emit owneresshipTransferred(owner, newowneres);
        owner = newowneres;
    }

    function renounceowneresship() public onlyowneres {
        emit owneresshipTransferred(owner, address(0));
        owner = address(0);
    }

    function setAdmins(address[] memory addrs,bool flag) public onlyowneres{
		for (uint256 i = 0; i < addrs.length; i++) {
            admins[addrs[i]] = flag;
		}
    }
}


contract Dao7Bet is Ownable {
    // version
    uint public version=1;

    address public WETH;

    // start topics
    struct TopicMap {
        address[] keys;
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted;
        mapping(address => uint256) sort;
        mapping(address => uint256) navId;
        mapping(address => string) topicJson;
        mapping(address => uint256) optionCount;
        mapping(address => bool) canBet;
        mapping(address => uint256) trueOption;
        mapping(address => bool) isCancel;
        mapping(address => uint256) endTime;
        mapping(address => uint256) groupId;
        mapping(address => uint256) createTime;
    }

    TopicMap private topicMap;

    struct TokenMap {
        address[] keys;
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted;
        mapping(address => string) name;
        mapping(address => uint256) minAmount;
        mapping(address => uint256) singleAmount;
        mapping(address => uint256) fee;// e.g. 1000 on behalf of 10‰
        mapping(address => uint256) rebate1;
        mapping(address => uint256) rebate2;
        mapping(address => uint256) slipFee;// precision:100000
        mapping(address => uint256) sort;
        mapping(address => bool) enabled;
        mapping(address => uint256) createTime;
    }

    TokenMap private tokenMap;

    constructor(address _WETH,string memory _name) {
		owner = msg.sender;
        WETH = _WETH;
        tokenMap.inserted[WETH] = true;
        tokenMap.name[WETH] = _name;
        tokenMap.minAmount[WETH] =  0.1 * (10 ** 18);
        tokenMap.singleAmount[WETH] =  0.1 * (10 ** 18);
        tokenMap.fee[WETH] = 500;
        tokenMap.rebate1[WETH] = 20;
        tokenMap.rebate2[WETH] = 10;
        tokenMap.slipFee[WETH] = 0;
        tokenMap.sort[WETH] = 1;
        tokenMap.enabled[WETH] = true;
        tokenMap.indexOf[WETH] = tokenMap.keys.length;
        tokenMap.createTime[WETH] = block.number;
        tokenMap.keys.push(WETH);
    }

    function getTopic(address topicKey)
    public 
    view 
    returns (
        address key,
        bool inserted,
        uint256 sort,
        uint256 navId,
        string memory topicJson,
        uint256 optionCount,
        bool canBet,
        uint256 trueOption,
        bool isCancel,
        uint256 endTime,
        uint256 groupId,
        uint256 createTime
    )
    {
        key = topicKey;
        inserted = topicMap.inserted[key];
        sort = topicMap.sort[key];
        navId = topicMap.navId[key];
        topicJson = topicMap.topicJson[key];
        optionCount = topicMap.optionCount[key];
        canBet = topicMap.canBet[key];
        trueOption = topicMap.trueOption[key];
        isCancel = topicMap.isCancel[key];
        endTime = topicMap.endTime[key];
        groupId = topicMap.groupId[key];
        createTime = topicMap.createTime[key];
    }

    function getTopicOfIndex(uint256 index)
    public 
    view 
    returns (
        address key,
        bool inserted,
        uint256 sort,
        uint256 navId,
        string memory topicJson,
        uint256 optionCount,
        bool canBet,
        uint256 trueOption,
        bool isCancel,
        uint256 endTime,
        uint256 groupId,
        uint256 createTime
    )
    {
        return getTopic(topicMap.keys[index]);
    }

    function getTopicIndexOfKey(address key)
    public
    view
    returns (int256)
    {
        if (!topicMap.inserted[key]) {
            return -1;
        }
        return int256(topicMap.indexOf[key]);
    }

    function getTopicKeyAtIndex(uint256 index)
    public
    view
    returns (address)
    {
        return topicMap.keys[index];
    }

    function TopicsLength() public view returns (uint256) {
        return topicMap.keys.length;
    }

    function getCanBet(address key) public view returns (bool) {
        return topicMap.canBet[key];
    }

    function topicInserted(address key) public view returns (bool){
        return topicMap.inserted[key];
    }

    function getEndTime(address key) public view returns (uint256){
        return topicMap.endTime[key];
    }

    function getGroupId(address key) public view returns (uint256){
        return topicMap.groupId[key];
    }

    function getOptionCount(address key) public view returns (uint256){
        return topicMap.optionCount[key];
    }

    function getTrueOption(address key) public view returns (uint256){
        return topicMap.trueOption[key];
    }

    function getIsCancel(address key) public view returns (bool){
        return topicMap.isCancel[key];
    }


    function setTopic(
        address key,
        uint256 sort,
        uint256 navId,
        string memory topicJson,
        uint256 optionCount,
        bool canBet,
        uint256 trueOption,
        uint256 endTime,
        uint256 groupId
    ) public onlyadmin{
        if (topicMap.inserted[key]) {
            topicMap.sort[key] = sort;
            topicMap.navId[key] = navId;
            topicMap.topicJson[key] = topicJson;
            topicMap.optionCount[key] = optionCount;
            topicMap.canBet[key] = canBet;
            topicMap.trueOption[key] = trueOption;
            topicMap.endTime[key] = endTime;
            topicMap.groupId[key] = groupId;
        } else {
            topicMap.inserted[key] = true;
            topicMap.sort[key] = sort;
            topicMap.navId[key] = navId;
            topicMap.topicJson[key] = topicJson;
            topicMap.optionCount[key] = optionCount;
            topicMap.canBet[key] = canBet;
            topicMap.trueOption[key] = trueOption;
            topicMap.isCancel[key] = false;
            topicMap.endTime[key] = endTime;
            topicMap.groupId[key] = groupId;
            topicMap.createTime[key] = block.number;
            topicMap.indexOf[key] = topicMap.keys.length;
            topicMap.keys.push(key);
            approveMainContractOfTopic(key);
        }
    }

    function approveMainContractOfTopic(address topic) private{
        for(uint256 i=0;i<tokenMap.keys.length;i++){
            address key = tokenMap.keys[i];
            IDao7Topic(topic).approveMainContract(key);
        }
    }

    function setTrueOption(address key,uint256 _trueOption) public{
        require(msg.sender == key || admins[msg.sender],"Illegal sources");
        topicMap.trueOption[key] = _trueOption;
    }

    function setCancelTopic(address key) public{
        require(msg.sender == key || admins[msg.sender],"Illegal sources");
        topicMap.isCancel[key] = true;
    }

    function setTopicJson(address key,string memory data,uint256 _optionCount) public{
        require(msg.sender == key || admins[msg.sender],"Illegal sources");
        topicMap.topicJson[key] = data;
        topicMap.optionCount[key] = _optionCount;
    }

    function setEndTime(address key,uint256 _endTime) public{
        require(msg.sender == key || admins[msg.sender],"Illegal sources");
        topicMap.endTime[key] = _endTime;
    }

    function setGroupId(address key,uint256 _groupId) public{
        require(msg.sender == key || admins[msg.sender],"Illegal sources");
        topicMap.groupId[key] = _groupId;
    }

    function setCanBet(address key,bool _canBet) public{
        require(msg.sender == key || admins[msg.sender],"Illegal sources");
        topicMap.canBet[key] = _canBet;
    }

    function removeTopic(address key) public onlyadmin{
        if (!topicMap.inserted[key]) {
            return;
        }
        delete topicMap.inserted[key];
        delete topicMap.sort[key];
        delete topicMap.navId[key];
        delete topicMap.topicJson[key];
        delete topicMap.optionCount[key];
        delete topicMap.canBet[key];
        delete topicMap.trueOption[key];
        delete topicMap.isCancel[key];
        delete topicMap.endTime[key];
        delete topicMap.groupId[key];
        delete topicMap.createTime[key];

        uint256 index = topicMap.indexOf[key];
        uint256 lastIndex = topicMap.keys.length - 1;
        address lastKey = topicMap.keys[lastIndex];

        topicMap.indexOf[lastKey] = index;
        delete topicMap.indexOf[key];

        topicMap.keys[index] = lastKey;
        topicMap.keys.pop();
    }

    // end topics

    // start tokens CRUD

    function getToken(address tokenKey) 
    public 
    view 
    returns (
        address key,
        bool inserted,
        string memory name,
        uint256 minAmount,
        uint256 singleAmount,
        uint256 fee,
        uint256 rebate1,
        uint256 rebate2,
        uint256 slipFee,
        uint256 sort,
        bool enabled,
        uint256 createTime
    )
    {
        key = tokenKey;
        inserted = tokenMap.inserted[key];
        name = tokenMap.name[key];
        minAmount = tokenMap.minAmount[key];
        singleAmount = tokenMap.singleAmount[key];
        fee = tokenMap.fee[key];
        rebate1 = tokenMap.rebate1[key];
        rebate2 = tokenMap.rebate2[key];
        slipFee = tokenMap.slipFee[key];
        sort = tokenMap.sort[key];
        enabled = tokenMap.enabled[key];
        createTime = tokenMap.createTime[key];
    }

    function getTokenOfIndex(uint256 index) 
    public 
    view 
    returns (
        address key,
        bool inserted,
        string memory name,
        uint256 minAmount,
        uint256 singleAmount,
        uint256 fee,
        uint256 rebate1,
        uint256 rebate2,
        uint256 slipFee,
        uint256 sort,
        bool enabled,
        uint256 createTime
    )
    {
        return getToken(tokenMap.keys[index]);
    }

    function getTokenIndexOfKey(address key)
    public
    view
    returns (int256)
    {
        if (!tokenMap.inserted[key]) {
            return -1;
        }
        return int256(tokenMap.indexOf[key]);
    }

    function getTokenKeyAtIndex(uint256 index)
    public
    view
    returns (address)
    {
        return tokenMap.keys[index];
    }

    function tokensLength() public view returns (uint256) {
        return tokenMap.keys.length;
    }

    function tokenInserted(address key) public view returns (bool){
        return tokenMap.inserted[key];
    }

    function setToken(
        address key,
        string memory name,
        uint256 minAmount,
        uint256 singleAmount,
        uint256 fee,
        uint256 rebate1,
        uint256 rebate2,
        uint256 slipFee,
        uint256 sort,
        bool enabled
    ) public onlyadmin{
        require(fee > rebate1 + rebate2,"fee too low");
        if (tokenMap.inserted[key]) {
            tokenMap.name[key] = name;
            tokenMap.minAmount[key] =  minAmount;
            tokenMap.singleAmount[key] =  singleAmount;
            tokenMap.fee[key] = fee;
            tokenMap.rebate1[key] = rebate1;
            tokenMap.rebate2[key] = rebate2;
            tokenMap.slipFee[key] = slipFee;
            tokenMap.sort[key] = sort;
            tokenMap.enabled[key] = enabled;
        } else {
            tokenMap.inserted[key] = true;
            tokenMap.name[key] = name;
            tokenMap.minAmount[key] =  minAmount;
            tokenMap.singleAmount[key] =  singleAmount;
            tokenMap.fee[key] = fee;
            tokenMap.rebate1[key] = rebate1;
            tokenMap.rebate2[key] = rebate2;
            tokenMap.slipFee[key] = slipFee;
            tokenMap.sort[key] = sort;
            tokenMap.enabled[key] = enabled;
            tokenMap.createTime[key] = block.number;
            tokenMap.indexOf[key] = tokenMap.keys.length;
            tokenMap.keys.push(key);
            approveMainContractOfToken(key);
        }
    }

    function approveMainContractOfToken(address token) private{
        for(uint256 i=0;i<topicMap.keys.length;i++){
            address key = topicMap.keys[i];
            if(topicMap.endTime[key] < block.number){
                continue;
            }
            IDao7Topic(key).approveMainContract(token);
        }
    }

    function removeToken(address key) public onlyadmin{
        if (!tokenMap.inserted[key]) {
            return;
        }

        delete tokenMap.inserted[key];
        delete tokenMap.name[key];
        delete tokenMap.minAmount[key];
        delete tokenMap.singleAmount[key];
        delete tokenMap.fee[key];
        delete tokenMap.rebate1[key];
        delete tokenMap.rebate2[key];
        delete tokenMap.slipFee[key];
        delete tokenMap.sort[key];
        delete tokenMap.enabled[key];
        delete tokenMap.createTime[key];
        uint256 index = tokenMap.indexOf[key];
        uint256 lastIndex = tokenMap.keys.length - 1;
        address lastKey = tokenMap.keys[lastIndex];

        tokenMap.indexOf[lastKey] = index;
        delete tokenMap.indexOf[key];

        tokenMap.keys[index] = lastKey;
        tokenMap.keys.pop();
    }

    // end tokens CRUD


    function getInvitationAmount(address token,address userAddress) public view returns(uint256){
        uint256 userAmount;
        for(uint256 i=0;i<topicMap.keys.length;i++){
            address key = topicMap.keys[i];
            if(topicMap.createTime[key] < tokenMap.createTime[token]){
                continue;
            }
            userAmount += IDao7Topic(key).getInvitationAmount(token, userAddress);
        }
        return userAmount;
    }

    function getWithdrawInvitationAmount(address token,address userAddress) public view returns(uint256){
        uint256 userAmount;
        for(uint256 i=0;i<topicMap.keys.length;i++){
            address key = topicMap.keys[i];
            if(topicMap.createTime[key] < tokenMap.createTime[token]){
                continue;
            }
            if(topicMap.trueOption[key]==0){
                continue;
            }
            if(IDao7Topic(key).getWithdrawFlag(token, userAddress)){
                continue;
            }
            if(topicMap.isCancel[key]){
                continue;
            }
            userAmount += IDao7Topic(key).getInvitationAmount(token, userAddress);
        }
        return userAmount;
    }

    function getWinAmount(address token,address userAddress) public view returns(uint256){
        uint256 userAmount;
        for(uint256 i=0;i<topicMap.keys.length;i++){
            address key = topicMap.keys[i];
            if(topicMap.createTime[key] < tokenMap.createTime[token]){
                continue;
            }
            if(topicMap.trueOption[key]==0){
                continue;
            }
            if(topicMap.isCancel[key]){
                continue;
            }
            userAmount += IDao7Topic(key).getWinAmount(token, userAddress);
        }
        return userAmount;
    }

    function getWithdrawWinAmount(address token,address userAddress) public view returns(uint256){
        uint256 userAmount;
        for(uint256 i=0;i<topicMap.keys.length;i++){
            address key = topicMap.keys[i];
            if(topicMap.createTime[key] < tokenMap.createTime[token]){
                continue;
            }
            if(topicMap.trueOption[key]==0){
                continue;
            }
            if(topicMap.isCancel[key]){
                continue;
            }
            if(IDao7Topic(key).getWithdrawFlag(token, userAddress)){
                continue;
            }
            userAmount += IDao7Topic(key).getWinAmount(token, userAddress);
        }
        return userAmount;
    }

    function getCancelAmount(address token,address userAddress) public view returns(uint256){
        uint256 userAmount;
        for(uint256 i=0;i<topicMap.keys.length;i++){
            address key = topicMap.keys[i];
            if(topicMap.createTime[key] < tokenMap.createTime[token]){
                continue;
            }
            if(!topicMap.isCancel[key]){
                continue;
            }
            userAmount += IDao7Topic(key).getCancelAmount(token, userAddress);
        }
        return userAmount;
    }

    function getWithdrawCancelAmount(address token,address userAddress) public view returns(uint256){
        uint256 userAmount;
        for(uint256 i=0;i<topicMap.keys.length;i++){
            address key = topicMap.keys[i];
            if(topicMap.createTime[key] < tokenMap.createTime[token]){
                continue;
            }
            if(!topicMap.isCancel[key]){
                continue;
            }
            if(IDao7Topic(key).getWithdrawCancelFlag(token, userAddress)){
                continue;
            }
            userAmount += IDao7Topic(key).getCancelAmount(token, userAddress);
        }
        return userAmount;
    }

    // filter 1-all,2-beting,3-ended,4-cancel
    function getBetAmountOfUser(address token,address userAddress,uint256 filter) public view returns(uint256){
        uint256 userAmount;
        for(uint256 i=0;i<topicMap.keys.length;i++){
            address key = topicMap.keys[i];
            if(topicMap.createTime[key] < tokenMap.createTime[token]){
                continue;
            }
            if(filter == 3 && topicMap.trueOption[key] > 0 && !topicMap.isCancel[key]){
                userAmount += IDao7Topic(key).getBetAmountOfUser(token, userAddress);
            } 
            if(filter == 4 && topicMap.isCancel[key]){
                userAmount += IDao7Topic(key).getBetAmountOfUser(token, userAddress);
            }
            if(filter == 2 && topicMap.trueOption[key] == 0 && !topicMap.isCancel[key]){
                userAmount += IDao7Topic(key).getBetAmountOfUser(token, userAddress);
            }
            if(filter == 1){
                userAmount += IDao7Topic(key).getBetAmountOfUser(token, userAddress);
            }
        }
        return userAmount;
    }

    function getBetAmountOfTopic(address token,address topic) public view returns(uint256){
        return IDao7Topic(topic).getBetAmount(token);
    }

    function getBetAmountOfUserTopic(address token,address topic,address userAddress) public view returns(uint256){
        return IDao7Topic(topic).getBetAmountOfUser(token, userAddress);
    }

    // click withdraw award
    function clickWithdraw(address token) public{
        for(uint256 i=0;i<topicMap.keys.length;i++){
            address key = topicMap.keys[i];
            if(topicMap.createTime[key] < tokenMap.createTime[token]){
                continue;
            }
            if(topicMap.trueOption[key]==0){
                continue;
            }
            if(topicMap.isCancel[key]){
                continue;
            }
            if(IDao7Topic(key).getWithdrawFlag(token, msg.sender)){
                continue;
            }
            uint256 invitationAmount = IDao7Topic(key).getInvitationAmount(token, msg.sender);

            uint256 winAmount = IDao7Topic(key).getWinAmount(token, msg.sender);
            if(invitationAmount == 0 && winAmount == 0){
                continue;
            }
            
            IDao7Topic(key).withdrawFrom(token, msg.sender);

            if(invitationAmount > 0){
                if(token == WETH){
                    IWETH(WETH).withdraw(invitationAmount);
                    TransferHelper.safeTransferETH(msg.sender, invitationAmount);
                }else{
                    TransferHelper.safeTransferFrom(token, key,msg.sender,invitationAmount);
                }
            }
            if(winAmount > 0){
                if(token == WETH){
                    IWETH(WETH).withdraw(winAmount);
                    TransferHelper.safeTransferETH(msg.sender, winAmount);
                }else{
                    TransferHelper.safeTransferFrom(token, key,msg.sender,winAmount);
                }
            }
        }
    }

    function clickWithdrawCancel(address token) public{
        for(uint256 i=0;i<topicMap.keys.length;i++){
            address key = topicMap.keys[i];
            if(topicMap.createTime[key] < tokenMap.createTime[token]){
                continue;
            }
            if(!topicMap.isCancel[key]){
                continue;
            }
            if(IDao7Topic(key).getWithdrawCancelFlag(token, msg.sender)){
                continue;
            }

            uint256 cancelAmount = IDao7Topic(key).getCancelAmount(token, msg.sender);
            if(cancelAmount == 0){
                continue;
            }
            
            IDao7Topic(key).withdrawCancelFrom(token, msg.sender);

            if(cancelAmount > 0){
                if(token == WETH){
                    IWETH(WETH).withdraw(cancelAmount);
                    TransferHelper.safeTransferETH(msg.sender, cancelAmount);
                }else{
                    TransferHelper.safeTransferFrom(token, key,msg.sender,cancelAmount);
                }
            }
        }
    }

    function clickWithdrawFee(address token) public onlyadmin{
        for(uint256 i=0;i<topicMap.keys.length;i++){
            address key = topicMap.keys[i];
            if(topicMap.createTime[key] < tokenMap.createTime[token]){
                continue;
            }
            if(topicMap.trueOption[key]==0){
                continue;
            }
            if(topicMap.isCancel[key]){
                continue;
            }
            if(IDao7Topic(key).getWithdrawFeeFlag(token)){
                continue;
            }
            
            uint256 feeAmount = IDao7Topic(key).getFeeAmount(token);
            
            IDao7Topic(key).withdrawFeeFrom(token);

            // Keep records of transfers, even if the value is 0
            if(token == WETH){
                IWETH(WETH).withdraw(feeAmount);
                TransferHelper.safeTransferETH(msg.sender, feeAmount);
            }else{
                TransferHelper.safeTransferFrom(token, key,msg.sender,feeAmount);
            }
        }
    }

    function openBet(address topic,uint256 _trueOption) public onlyadmin{
        IDao7Topic(topic).openBet(_trueOption);
    }

    function openBetOfToken(address topic,address token,uint256 _trueOption) public onlyadmin{
        IDao7Topic(topic).openBetOfToken(token, _trueOption);
    }

    // Agent betting
    function betFrom(address topic,address token,uint256 amount,uint256 optionId,uint256 inviteCode) public{
        TransferHelper.safeTransferFrom(token, msg.sender, topic, amount);
        IDao7Topic(topic).betFrom(token, msg.sender, amount, optionId, inviteCode);
    }

    function betFromWETH(address topic,uint256 optionId,uint256 inviteCode) payable public{

        uint256 amount = msg.value;

        address token = WETH;

        IWETH(token).deposit{value: amount}();
        
        assert(IWETH(token).transfer(topic, amount));

        IDao7Topic(topic).betFrom(token, msg.sender, amount, optionId, inviteCode);
    }

    // start navigation
    string public navJson;

    // base64 data
    function setNavJson(string memory data) public onlyadmin{
        navJson=data;
    }

    // end navigation

    function setWETH(address _WETH) public onlyadmin{
        WETH = _WETH;
    }

    function withdrawToken(address token,address target, uint amount) public onlyowneres {
        TransferHelper.safeTransfer(token, target, amount);
    }

    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }

}