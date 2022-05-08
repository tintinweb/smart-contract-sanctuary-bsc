/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^ 0.8.3;

abstract contract ERC20{
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
    function mining(address _address,uint tokens) external virtual returns (bool success);
}

abstract contract NodePool{
    function addPower(uint nodeId,uint amountToWei) external virtual;
    function removePower(uint nodeId,uint amountToWei) external virtual;
    function setNodeOutPut(uint nodeId,uint totalOutPut) external virtual;
    function getNodeScale(uint nodeId) external virtual view returns (uint _scale);
    function getNodeCount() external virtual view returns (uint nodeCount);
    function getNodeUpdataNeedByNodeId(uint nodeId) external virtual view returns (uint _totalLp,uint _totalLpEffective,uint _scale,address _creator,uint isEffective);
    function getNodeIdByCreator(address creator) external virtual view returns (uint nodeId);
    function getTotalLpEffective() external virtual view returns (uint _totalLpEffective);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        if (b == a) {
            return 0;
        }
        require(b < a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a * b;
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a / b;
        return c;
    }
    function divFloat(uint256 a, uint256 b,uint decimals) internal pure returns (uint256){
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 aPlus = a * (10 ** uint256(decimals));
        uint256 c = aPlus/b;
        return c;
    }
}

contract Comn {
    address private _owner;
    uint256 internal _NOT_ENTERED = 1;
    uint256 internal _ENTERED = 2;
    uint256 internal _status = 1;
    mapping(address => bool) private updateMapping; //授权地址mapping

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    modifier onlyUpdate(){
        require(updateMapping[msg.sender] || msg.sender == _owner,"Modifier : The caller is not the update");
        _;
    }
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    function sub(uint256 a, uint256 b) internal returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal returns (uint256) {
        if (b == a) {
            return 0;
        }
        if(b > a){ _status = _NOT_ENTERED; revert(errorMessage); }
        uint256 c = a - b;
        return c;
    }

    constructor() {
         _owner = msg.sender;
        _status = _NOT_ENTERED;
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

//质押LP挖矿
contract Node is Comn{
    using SafeMath for uint256;
    uint256 public startTime;                                     //开始时间
    uint256 public totalLP;                                       //总质押量
    uint256 public rateTokenOne;                                  //全网一个币的总产量
    uint256 public updateTime;                                    //最近一次更新时间
    mapping(address => mapping(uint256 => uint256)) public userNodeRateTokenOne;    //用户节点池单币总产量      
    mapping(address => mapping(uint256 => uint256)) public userNodeProfitMapping;   //用户静态收益
    mapping(address => mapping(uint256 => uint256)) public userNodeTotalLp;         //用户质押详情

    mapping(uint256 => uint256) public nodeProfitMapping;             //节点池提成总收益
    mapping(uint256 => uint256) public nodeRateTokenOne;              //节点池单币总产量
    mapping(uint256 => uint256) public nodeRateTokenOneEffective;     //节点池单币有效总产量
    mapping(uint256 => uint256) public nodeCreatorRateTokenOne;

    mapping(address => uint) public userTotalCollect;                 //用户总提取
    
    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event UpdateWithdrawStatus(bool oldStatus, bool newStatus);

    modifier updateBefore(uint nodeId) { //结算之前的收益
        endBefore(nodeId);
        _;
    }

    /*
     * @dev 结算之前的收益
     * @param nodeId 节点ID
     */
    function endBefore(uint nodeId) private {
        if(nodeId == 0){ _status = _NOT_ENTERED; revert("Node : node cannot be 0"); }
        uint nodeTotalLP;      //节点总质押LP
        uint totalEffective;   //全网有效LP
        uint scale;            //节点池获利率
        uint isEffective;      //是否有效节点 (0:无效,1:有效)
        (nodeTotalLP,totalEffective,scale,,isEffective)=NodePool(poolAddress).getNodeUpdataNeedByNodeId(nodeId);
        rateTokenOne = getRateTokenOne(totalEffective);                                                                            //更新 | 全网单币总产量
        if(isEffective == 1){
            nodeRateTokenOneEffective[nodeId] = nodeRateTokenOneEffective[nodeId].add(sub(rateTokenOne,nodeRateTokenOne[nodeId])); //更新 | 节点池单币有效产量
            updUserProfit(nodeId,scale);                //更新用户收益
            updCreatorProfit(nodeId,nodeTotalLP,scale); //更新矿主收益
        }else{
            if(userNodeRateTokenOne[msg.sender][nodeId] != nodeRateTokenOneEffective[nodeId]){
                userNodeRateTokenOne[msg.sender][nodeId] = nodeRateTokenOneEffective[nodeId];
            }
        }
        nodeRateTokenOne[nodeId] = rateTokenOne;                                                                                   //更新 | 节点池单币总产量
        //更新最后一次操作截止时间
        updateTime = getNowTime();
    }
    
    function endAfterN2Y(uint nodeId) external onlyPool {
        if(rateTokenOne != nodeRateTokenOne[nodeId]){
            //更新 | 用户收益 (不用更新)
            //更新 | 矿主收益 (不用更新)
            //更新 | 节点池单币总产量
            nodeRateTokenOne[nodeId] = rateTokenOne;
        }
    }

    function endAfterY2N(uint nodeId,uint nodeTotalLP,uint scale) external onlyPool{
        endAfterY2N(nodeId,nodeTotalLP,scale,0);
    }

    function endAfterY2N(uint nodeId,uint nodeTotalLP,uint scale,uint totalEffective) public onlyPool{
        if(totalEffective !=0 ){
            rateTokenOne = getRateTokenOne(totalEffective);
            updateTime = getNowTime();
        }
        if(rateTokenOne != nodeRateTokenOne[nodeId]){
            nodeRateTokenOneEffective[nodeId] = nodeRateTokenOneEffective[nodeId].add(sub(rateTokenOne,nodeRateTokenOne[nodeId])); //更新 | 节点池单币有效产量
            //更新 | 用户收益 (不用更新)
            //更新 | 矿主收益
            updCreatorProfit(nodeId,nodeTotalLP,scale);
            //更新 | 节点池单币总产量
            nodeRateTokenOne[nodeId] = rateTokenOne;
        }
    }

    //更新用户收益
    function updUserProfit(uint nodeId,uint scale) private{
        uint lastBlockUserOutPut = userNodeTotalLp[msg.sender][nodeId].mul(sub(nodeRateTokenOneEffective[nodeId],userNodeRateTokenOne[msg.sender][nodeId])).div(1e18);
        if(lastBlockUserOutPut > 0){
            userNodeProfitMapping[msg.sender][nodeId] = userNodeProfitMapping[msg.sender][nodeId].add(lastBlockUserOutPut.mul(1000-scale).div(1000));
        }
        userNodeRateTokenOne[msg.sender][nodeId] = nodeRateTokenOneEffective[nodeId];                                       
    }

    //更新矿主收益
    function updCreatorProfit(uint nodeId,uint nodeTotalLP,uint scale) private{
        uint lastBlockNodeOutPut = nodeTotalLP.mul(sub(nodeRateTokenOneEffective[nodeId],nodeCreatorRateTokenOne[nodeId])).div(1e18);
        if(lastBlockNodeOutPut > 0){
            nodeProfitMapping[nodeId] = nodeProfitMapping[nodeId].add(lastBlockNodeOutPut.mul(scale).div(1000));
            NodePool(poolAddress).setNodeOutPut(nodeId,lastBlockNodeOutPut);
        }
        nodeCreatorRateTokenOne[nodeId] = nodeRateTokenOneEffective[nodeId];
    }

    /*
     * @dev 质押LP
     * @param nodeId 节点ID
     * @param amountToWei 金额
     */
    function pledgeLP(uint nodeId,uint256 amountToWei) public nonReentrant updateBefore(nodeId) checkStart checkPledge{
        if(amountToWei == 0){ _status = _NOT_ENTERED; revert("Node : Cannot stake 0"); }
        totalLP = totalLP.add(amountToWei);
        userNodeTotalLp[msg.sender][nodeId] = userNodeTotalLp[msg.sender][nodeId].add(amountToWei);
        ERC20(inAddress).transferFrom(msg.sender, address(this), amountToWei);
        NodePool(poolAddress).addPower(nodeId,amountToWei);
        emit Staked(msg.sender, amountToWei);
    }

    /*
     * @dev 赎回LP
     * @param nodeId 节点ID
     * @param amountToWei 金额
     */
    function redeemLP(uint nodeId,uint256 amountToWei) public nonReentrant updateBefore(nodeId) checkStart checkRedeem{
        if(amountToWei == 0){ _status = _NOT_ENTERED; revert("Node : Cannot stake 0"); }
        if(userNodeTotalLp[msg.sender][nodeId] < amountToWei){ _status = _NOT_ENTERED; revert("Node : Insufficient node balance"); }
        totalLP = sub(totalLP,amountToWei);
        userNodeTotalLp[msg.sender][nodeId] = sub(userNodeTotalLp[msg.sender][nodeId],amountToWei);
        ERC20(inAddress).transfer(msg.sender, amountToWei);
        NodePool(poolAddress).removePower(nodeId,amountToWei);
        emit Withdrawn(msg.sender, amountToWei);
    }

    /*
     * @dev 提取用户节点收益
     * @param nodeId 节点ID
     */
    function collectProfit(uint nodeId) public nonReentrant updateBefore(nodeId) checkStart checkCollect {
        uint256 sumProfit = userNodeProfitMapping[msg.sender][nodeId];//用户总收益
        if (sumProfit > 0) {
            userNodeProfitMapping[msg.sender][nodeId] = 0;
            userTotalCollect[msg.sender] = userTotalCollect[msg.sender].add(sumProfit);
            ERC20(poolFactory).mining(msg.sender,sumProfit);
            emit RewardPaid(msg.sender, sumProfit);
        }
    }

    /*
     * @dev 提取用户总收益
     */
    function collectProfitAll() public nonReentrant checkStart checkCollect {
        uint nodeCount = NodePool(poolAddress).getNodeCount();
        uint sumProfit;
        for(uint nodeId = 1;nodeId <= nodeCount; nodeId++){
            uint nodeProfit; //单节点收益
            if(userNodeTotalLp[msg.sender][nodeId] != 0){      //累加有质押的节点
                endBefore(nodeId);//结算之前的收益
                nodeProfit = userNodeProfitMapping[msg.sender][nodeId];
            } else 
            if(userNodeProfitMapping[msg.sender][nodeId] != 0){ //累加没质押有余额的节点
                nodeProfit = userNodeProfitMapping[msg.sender][nodeId];
            }
            if(nodeProfit > 0){ // 有收益
                userNodeProfitMapping[msg.sender][nodeId] = 0;
                sumProfit = sumProfit.add(nodeProfit);
            }
        }
        if(sumProfit > 0){
            userTotalCollect[msg.sender] = userTotalCollect[msg.sender].add(sumProfit);
            ERC20(poolFactory).mining(msg.sender,sumProfit);
        }
    }

    /*
     * @dev 赎回LP并提取收益
     * @param nodeId 节点ID
     * @param amountToWei 金额
     */
    function collectAndRedeem(uint nodeId,uint amountToWei) external nonReentrant checkStart updateBefore(nodeId) checkRedeem checkCollect {
        if(amountToWei == 0){ _status = _NOT_ENTERED; revert("Node : Cannot stake 0"); }
        if(userNodeTotalLp[msg.sender][nodeId] < amountToWei){ _status = _NOT_ENTERED; revert("Node : Insufficient node balance"); }
        totalLP = sub(totalLP,amountToWei);
        userNodeTotalLp[msg.sender][nodeId] = sub(userNodeTotalLp[msg.sender][nodeId],amountToWei);
        ERC20(inAddress).transfer(msg.sender, amountToWei);
        NodePool(poolAddress).removePower(nodeId,amountToWei);
        emit Withdrawn(msg.sender, amountToWei);
        
        uint256 sumProfit = userNodeProfitMapping[msg.sender][nodeId];//用户总收益
        if (sumProfit > 0) {
            userNodeProfitMapping[msg.sender][nodeId] = 0;
            userTotalCollect[msg.sender] = userTotalCollect[msg.sender].add(sumProfit);
            ERC20(poolFactory).mining(msg.sender,sumProfit);
            emit RewardPaid(msg.sender, sumProfit);
        }
    }

    /*---------------------------------------------------功能区-----------------------------------------------------------*/
    
    //获取最新挖矿速率,一个币的总产量
    function getRateTokenOne(uint totalEffective) public view returns (uint256) {
        if (totalEffective == 0) {
            return rateTokenOne;//挖矿速率,一个币的总产量
        }
        //截止最后一个区间之前的一个币的总产量 + 最后一个区间一个币的总产量(注:最后一个区间的总产量 / 全网总质押LP)
        return rateTokenOne.add(getLastBlockProfit().divFloat(totalEffective,18));//挖矿速率,一个币的总产量
    }

    //节点单币有效总收益
    function getNodeRateTokenOneEffective(uint totalEffective,uint nodeId,uint isEffective) public view returns (uint256 effectiveRateTokenOne) {
        uint _rateTokenOne = getRateTokenOne(totalEffective); // 最新全网单币总产量
        if(isEffective == 1){
            effectiveRateTokenOne = nodeRateTokenOneEffective[nodeId].add(_rateTokenOne.sub(nodeRateTokenOne[nodeId]));
        } else {
            effectiveRateTokenOne = nodeRateTokenOneEffective[nodeId];
        }
    }

    /*
     * @dev 获取指定节点收益
     * @param nodeId 节点ID
     * @param querist 询问者
     */
    function getNodeSumProfit(uint nodeId,address querist) public view returns (uint256) {
        uint totalEffective;   //全网有效LP
        uint scale;            //节点池获利率
        uint isEffective;      //是否有效节点 (0:无效,1:有效)
        (,totalEffective,scale,,isEffective)=NodePool(poolAddress).getNodeUpdataNeedByNodeId(nodeId);
        uint _nodeRateTokenOneEffective = getNodeRateTokenOneEffective(totalEffective,nodeId,isEffective);//节点单币总有效
        //用户最后一个区间的总收益
        uint lastBlockNodeSumProfit = userNodeTotalLp[querist][nodeId].mul(_nodeRateTokenOneEffective.sub(userNodeRateTokenOne[querist][nodeId])).div(1e18);
        //用户总收益 = 用户之前的总收益 + 用户最后一个区间的实际收益
        return userNodeProfitMapping[querist][nodeId].add(lastBlockNodeSumProfit.mul(1000-scale).div(1000));
    }
    
    /*
     * @dev 获取所有节点总收益
     * @param querist 询问者
     */
    function getAllSumProfit(address querist) public view returns (uint sumProfit,uint nodeNumber) {
        uint nodeCount = NodePool(poolAddress).getNodeCount();
        for(uint nodeId = 1;nodeId <= nodeCount; nodeId++){
            if(userNodeTotalLp[querist][nodeId] != 0){      //累加有质押的节点
                sumProfit += getNodeSumProfit(nodeId,querist);
                nodeNumber++;
            } else 
            if(userNodeProfitMapping[querist][nodeId] != 0){ //累加没质押有收益的节点
                sumProfit += userNodeProfitMapping[querist][nodeId];
                nodeNumber++;
            }
        }
    }

    //获取用户累计产出
    function getUserTotalOutPut(address querist) public view returns (uint256 totalOutPut) {
        (uint userWaitSumProfit,) = getAllSumProfit(querist);         // 用户待提取收益
        uint nodeId = NodePool(poolAddress).getNodeIdByCreator(querist);
        if(nodeId != 0){
            uint creatorWaitSumProfit = getNodeProfitByNodeId(nodeId);    // 节点待提取收益
            totalOutPut = userTotalCollect[msg.sender].add(userWaitSumProfit).add(creatorWaitSumProfit);
        } else {
            totalOutPut = userTotalCollect[msg.sender].add(userWaitSumProfit);
        }
    }

    //获取用户总质押
    function getUserTotalLp(address querist) public view returns (uint256 userTotalLP) {
        uint256 nodeCount = NodePool(poolAddress).getNodeCount();
        for(uint nodeId = 1;nodeId <= nodeCount;nodeId++){
            if(userNodeTotalLp[querist][nodeId] != 0){
                userTotalLP += userNodeTotalLp[querist][nodeId];
            }
        }
    }

    /*
     * @dev 获取用户参与的所有的节点信息
     * @param nodeIds 节点ID
     * @param totalProfits 总收益
     * @param totalLPs 质押总量
     */
    function queryUserNode(address querist) public view returns (uint[] memory nodeIds,uint[] memory totalProfits,uint[] memory totalLPs) {
        uint nodeCount = NodePool(poolAddress).getNodeCount();
        uint nodeLength = 0;
        for(uint nodeId = 1;nodeId <= nodeCount;nodeId++){
            if(userNodeTotalLp[querist][nodeId] > 0 || userNodeProfitMapping[querist][nodeId] > 0){
                nodeLength++;
            }
        }
        nodeIds = new uint[](nodeLength);
        totalProfits = new uint[](nodeLength);
        totalLPs = new uint[](nodeLength);
        nodeLength = 0;
        for(uint nodeId = 1;nodeId <= nodeCount;nodeId++){
            if(userNodeTotalLp[querist][nodeId] > 0 || userNodeProfitMapping[querist][nodeId] > 0){
                nodeIds[nodeLength] = nodeId;
                totalProfits[nodeLength] = getNodeSumProfit(nodeId,querist);
                totalLPs[nodeLength] = userNodeTotalLp[querist][nodeId];
                nodeLength++;
            }
        }
    }

    /*
     * @dev 获取动态总产出
     * @return lastBlockProfit 动态总产出
     */
    function getLastBlockProfit() public view returns (uint lastBlockProfit) {
        lastBlockProfit = (getNowTime().sub(updateTime)).mul(miningRateSecond);
    }
    
    function getNowTime() public view returns (uint256) {
        if (miningEndTime > block.timestamp) {
            return block.timestamp;
        }
        return miningEndTime;
    }

    /*---------------------------------------------------矿主-----------------------------------------------------------*/
    //获取指定矿主待采集收益
    function getCreatorWaitCollectionProfit(uint nodeId,uint totalEffective,uint isEffective,uint nodeTotalLP) public view returns (uint256) {
        uint _nodeRateTokenOneEffective = getNodeRateTokenOneEffective(totalEffective,nodeId,isEffective);//节点单币总有效
        return nodeTotalLP.mul(_nodeRateTokenOneEffective.sub(nodeCreatorRateTokenOne[nodeId])).div(1e18);
    }

    //根据节点ID获取指定节点池创建者待提取收益
    function getNodeProfitByNodeId(uint nodeId) public view returns (uint256) {
        uint nodeTotalLP;      //节点总质押LP
        uint totalEffective;   //全网有效LP
        uint scale;            //节点池获利率
        address creator;       //节点池主人
        uint isEffective;      //是否有效节点 (0:无效,1:有效)
        (nodeTotalLP,totalEffective,scale,creator,isEffective)=NodePool(poolAddress).getNodeUpdataNeedByNodeId(nodeId);
        if (totalEffective == 0) {
            return nodeProfitMapping[nodeId];
        }
        uint lastBlockNodeProfit = getCreatorWaitCollectionProfit(nodeId,totalEffective,isEffective,nodeTotalLP);
        return nodeProfitMapping[nodeId].add(lastBlockNodeProfit.mul(scale).div(1000));
    }

    //根据创建者获取指定节点池创建者待提取收益
    function getNodeProfitByCreator(address querist) public view returns (uint256) {
        uint nodeId = NodePool(poolAddress).getNodeIdByCreator(querist);
        if(nodeId != 0){
           return getNodeProfitByNodeId(nodeId);
        } else {
            return 0;
        }
    }

    //提取指定矿主收益
    function collectCreatorProfit(uint nodeId) public nonReentrant updateBefore(nodeId) checkStart checkCollect {
        uint sumProfit = nodeProfitMapping[nodeId];
        if (sumProfit > 0) {
            nodeProfitMapping[nodeId] = 0;                                           //清0用户待提取额
            userTotalCollect[msg.sender] = userTotalCollect[msg.sender].add(sumProfit);
            (,,,address creator,)=NodePool(poolAddress).getNodeUpdataNeedByNodeId(nodeId);
            ERC20(poolFactory).mining(creator,sumProfit);
        }
    }

    /*---------------------------------------------------管理运营-----------------------------------------------------------*/
    bool public canCollect = true;                              //[设置]  开/关 提取
    bool public canProduce = true;                              //[设置]  开/关 产出
    bool public canPledge = true;                               //[设置]  开/关 质押
    bool public canRedeem = true;                               //[设置]  开/关 赎回
    address public inAddress;                                   //[设置]  质押代币地址
    address public poolFactory;                                  //[设置]  产出代币地址
    address public poolAddress;                                 //[设置]  配置节点池地址
    uint public miningStartTime;                                //[设置]  开始时间 (单位:秒)
    uint public miningEndTime;                                  //[设置]  截止时间 (单位:秒)
    uint public miningRateSecond;                               //[设置]  挖矿速率 (单位:秒)
    uint public stopSurplusTime;                                //暂停剩余时间

    modifier onlyPool(){
        if(msg.sender != poolAddress){ _status = _NOT_ENTERED; revert("Modifier: The caller is not the pool"); }
        _;
    }
    modifier checkStart() { //验证开启
        if(block.timestamp < startTime){ _status = _NOT_ENTERED; revert("Node : Not Start"); }
        _;
    }
    modifier checkPledge() { //验证质押
        if(canPledge == false){ _status = _NOT_ENTERED; revert("Node : Not Pledge"); }
        _;
    }
    modifier checkRedeem() { //验证赎回
        if(canRedeem == false){ _status = _NOT_ENTERED; revert("Node : Not Redeem"); }
        _;
    }
    modifier checkCollect() { //验证提取
        if(canCollect == false){ _status = _NOT_ENTERED; revert("Node : Not Collect"); }
        _;
    }
    
    /*
     * @param _inAddress 质押代币合约
     * @param _poolFactory 产出代币地址
     * @param _nodePool 节点池合约
     * @param _miningStartTime 挖矿开始时间 (单位:秒)
     * @param _miningRateSecond 挖矿速率 (单位:秒)
     * @param _miningTimeLength 挖矿时长 (单位:秒)
     */
    function setConfig(address _inAddress,address _poolFactory,address _nodePool,uint _miningStartTime,uint _miningRateSecond,uint _miningTimeLength) public onlyOwner {
        inAddress = _inAddress;                        //质押代币
        poolFactory = _poolFactory;                      //产出代币地址
        startTime =  _miningStartTime;
        updateTime = startTime;
        poolAddress = _nodePool;
        miningRateSecond = _miningRateSecond;
        miningEndTime = _miningStartTime + _miningTimeLength;
    }

    function updateOutput(uint outputToWei) public onlyUpdate {
        uint totalEffective = NodePool(poolAddress).getTotalLpEffective();
        rateTokenOne = getRateTokenOne(totalEffective);
        updateTime = getNowTime();
        miningRateSecond = outputToWei;
    }

    function setNodePool(address _address) public onlyOwner {
        poolAddress = _address;
    }

    function setProduce(bool _canProduce) public onlyOwner {
        if(canProduce != _canProduce){
            uint nowTime = block.timestamp;
            if(_canProduce){ //开启
                if(stopSurplusTime > 0){
                   miningEndTime = nowTime.add(stopSurplusTime);
                   updateTime = nowTime; 
                   stopSurplusTime = 0;
                }
            } else { //暂停
                if(miningEndTime > nowTime){
                    uint totalEffective = NodePool(poolAddress).getTotalLpEffective();
                    rateTokenOne = getRateTokenOne(totalEffective);
                    updateTime = nowTime;
                    stopSurplusTime = miningEndTime.sub(nowTime);
                    miningEndTime = nowTime;
                }
            }
            canProduce = _canProduce;
        }
    }

    function setPledge(bool _canPledge) public onlyOwner {
        canPledge = _canPledge;
    }

    function setRedeem(bool _canRedeem) public onlyOwner {
        canRedeem = _canRedeem;
    }

    function setCollect(bool _canCollect) public onlyOwner {
        canCollect = _canCollect;
    }

}