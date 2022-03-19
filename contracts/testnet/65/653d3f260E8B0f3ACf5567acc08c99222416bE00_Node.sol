/**
 *Submitted for verification at BscScan.com on 2022-03-19
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^ 0.8.3;

abstract contract ERC20{
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
}

abstract contract NodePool{
    function addPower(uint nodeId,uint amountToWei) external virtual;
    function removePower(uint nodeId,uint amountToWei) external virtual;
    function setNodeScale(uint nodeId,uint scale) external virtual returns (bool);
    function mining(uint nodeId,address outAddress,address _address,uint tokens) external virtual returns (bool success);
    function miningCreator(uint nodeId,address _tokenAddress,uint tokens) external virtual returns(bool);
    function setNodeOutPut(uint nodeId,uint totalOutPut) external virtual;
    function getNodeScale(uint nodeId) external virtual view returns (uint _scale);
    function getNodeCount() external virtual view returns (uint nodeCount);
    function getNodeUpdataNeed(uint nodeId) external virtual view returns (uint _totalLp,uint _totalLpEffective,uint _scale,address _creator,uint isEffective);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
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
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function divFloat(uint256 a, uint256 b,uint decimals) internal pure returns (uint256){
        require(b > 0, "SafeMath: division by zero");
        uint256 aPlus = a * (10 ** uint256(decimals));
        uint256 c = aPlus/b;
        return c;
    }
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

    mapping(uint256 => uint256) public nodeLastRateTokenOne;          
    mapping(uint256 => uint256) public nodeProfitMapping;             //节点池提成总收益
    mapping(uint256 => uint256) public nodeRateTokenOneNot;           //点池单币无效总产量
    
    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event UpdateWithdrawStatus(bool oldStatus, bool newStatus);
    

    modifier checkStart() {
        require(block.timestamp >= startTime, "Node : not start");
        _;
    }

    /*
     * @dev 结算之前的收益
     * @param nodeId 节点ID
     */
    function endBefore(uint nodeId) private {
        require(nodeId != 0, 'Node : node cannot be 0');
        uint nodeTotalLP;      //节点总质押LP
        uint totalEffective;   //全网有效LP
        uint scale;            //节点池获利率
        address creator;       //节点池主人
        uint isEffective;      //是否有效节点 (0:无效,1:有效)
        (nodeTotalLP,totalEffective,scale,creator,isEffective)=NodePool(poolAddress).getNodeUpdataNeed(nodeId);
        require(creator != address(0), 'Node : node cannot be 0');
        uint lastBlockOutPut = getLastBlockProfit();                                                      //最后一块总产出
        if(lastBlockOutPut > 0 && totalEffective > 0){
            uint lastBlockOutPutTokenOne = lastBlockOutPut.divFloat(totalEffective,18);                   //最后一块产出的单币产量
            rateTokenOne = rateTokenOne.add(lastBlockOutPutTokenOne);                                     //更新 | 全网单币总产量
            if(isEffective == 0){
                nodeRateTokenOneNot[nodeId] = nodeRateTokenOneNot[nodeId].add(lastBlockOutPutTokenOne);   //更新 | 节点池单币无效总产量
            }
        }
        //节点池单币有效总产量
        uint nodeRateTokenOne = rateTokenOne.sub(nodeRateTokenOneNot[nodeId]);
        //最后一个区间用户指定节点总收益
        uint lastBlockUserOutPut = userNodeTotalLp[msg.sender][nodeId].mul(nodeRateTokenOne.sub(userNodeRateTokenOne[msg.sender][nodeId])).div(1e18);
        if(lastBlockUserOutPut > 0){
            userNodeProfitMapping[msg.sender][nodeId] = userNodeProfitMapping[msg.sender][nodeId].add(lastBlockUserOutPut.mul(1000-scale).div(1000));
        }
        userNodeRateTokenOne[msg.sender][nodeId] = nodeRateTokenOne;                                       //更新 | 用户在当前节点池中单币的总产量
        
        //最后一个区间指定节点总收益
        uint lastBlockNodeOutPut = nodeTotalLP.mul(nodeRateTokenOne.sub(nodeLastRateTokenOne[nodeId])).div(1e18);
        if(lastBlockNodeOutPut > 0){
            nodeProfitMapping[nodeId] = nodeProfitMapping[nodeId].add(lastBlockNodeOutPut.mul(scale).div(1000));
            NodePool(poolAddress).setNodeOutPut(nodeId,lastBlockNodeOutPut);
        }
        nodeLastRateTokenOne[nodeId] = nodeRateTokenOne;

        testEndBefore(nodeId,lastBlockOutPut,totalEffective,isEffective);//测试埋点
        
        //更新最后一次操作截止时间
        updateTime = getNowTime();
    }
    
    function updNodeRateTokenOneNot(uint nodeId,uint totalEffective,uint isEffective) external{
        uint timeNumber = getLastBlockProfit();
        if(timeNumber > 0 && isEffective == 0 && totalEffective > 0){
            nodeRateTokenOneNot[nodeId] = nodeRateTokenOneNot[nodeId].add(timeNumber.divFloat(totalEffective,18));
            testNodeRateTokenOneNot[nodeId] = testNodeRateTokenOneNot[nodeId].add(getNowTime().sub(updateTime));//测试埋点
        }
    }

    /*
     * @dev 质押LP
     * @param nodeId 节点ID
     * @param amountToWei 金额
     */
    function pledgeLP(uint nodeId,uint256 amountToWei) public checkStart {
        endBefore(nodeId);
        require(amountToWei > 0, 'Node : Cannot stake 0');
        totalLP = totalLP.add(amountToWei);
        userNodeTotalLp[msg.sender][nodeId] = userNodeTotalLp[msg.sender][nodeId].add(amountToWei);
        // ERC20(inAddress).transferFrom(msg.sender, address(this), amountToWei);
        NodePool(poolAddress).addPower(nodeId,amountToWei);
        emit Staked(msg.sender, amountToWei);
    }

    /*
     * @dev 赎回LP
     * @param nodeId 节点ID
     * @param amountToWei 金额
     */
    function redeemLP(uint nodeId,uint256 amountToWei) public checkStart {
        endBefore(nodeId);
        require(canWithdraw, "Node : inactive");
        require(amountToWei > 0, 'Node : Cannot stake 0');
        require(userNodeTotalLp[msg.sender][nodeId] >= amountToWei, 'Node : Insufficient node balance');
        totalLP = totalLP.sub(amountToWei);
        userNodeTotalLp[msg.sender][nodeId] = userNodeTotalLp[msg.sender][nodeId].sub(amountToWei);
        // ERC20(inAddress).transfer(msg.sender, amountToWei);
        NodePool(poolAddress).removePower(nodeId,amountToWei);
        emit Withdrawn(msg.sender, amountToWei);
    }

    /*
     * @dev 提取用户节点收益
     * @param nodeId 节点ID
     */
    function collectProfit(uint nodeId) public checkStart {
        endBefore(nodeId);
        uint256 sumProfit = userNodeProfitMapping[msg.sender][nodeId];//用户总收益
        if (sumProfit > 0) {
            userNodeProfitMapping[msg.sender][nodeId] = 0;
            // NodePool(poolAddress).mining(nodeId,outAddress,msg.sender,sumProfit);
            emit RewardPaid(msg.sender, sumProfit);
        }
    }

    /*
     * @dev 提取用户总收益
     */
    function collectProfitAll() public checkStart {
        uint nodeCount = NodePool(poolAddress).getNodeCount();
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
                NodePool(poolAddress).mining(nodeId,outAddress,msg.sender,nodeProfit);
            }
        }
    }

    /*
     * @dev 赎回LP并提取收益
     * @param nodeId 节点ID
     * @param amountToWei 金额
     */
    function collectAndRedeem(uint nodeId,uint amountToWei) external {
        redeemLP(nodeId,amountToWei);
        uint256 sumProfit = userNodeProfitMapping[msg.sender][nodeId];//用户总收益
        if (sumProfit > 0) {
            userNodeProfitMapping[msg.sender][nodeId] = 0;
            NodePool(poolAddress).mining(nodeId,outAddress,msg.sender,sumProfit);
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

    //一个币在该节点池的总无效收益
    function getNotRateTokenOne(uint totalEffective,uint nodeId,uint nodeIsEffective) public view returns (uint256) {
        if (totalEffective == 0) {
            return nodeRateTokenOneNot[nodeId];
        }
        if(nodeIsEffective == 0){ // 无效节点 | 统计无效收益
            return nodeRateTokenOneNot[nodeId].add(getLastBlockProfit().divFloat(totalEffective,18));
        } else 
        if(nodeIsEffective == 1){
            return nodeRateTokenOneNot[nodeId];
        } else {
            return nodeRateTokenOneNot[nodeId];
        }
    }

    /*
     * @dev 获取指定节点收益
     * @param nodeId 节点ID
     * @param querist 询问者
     */
    function getNodeSumProfit(uint nodeId,address querist) public view returns (uint256) {
        uint totalEffective; //全网有效LP
        uint scale;            //节点池获利率
        uint isEffective;      //是否有效节点 (0:无效,1:有效)
        (,totalEffective,scale,,isEffective)=NodePool(poolAddress).getNodeUpdataNeed(nodeId);
        uint _rateTokenOne = getRateTokenOne(totalEffective);                          //单币总产量
        uint nodeRateTokenOne = getNotRateTokenOne(totalEffective,nodeId,isEffective);//节点单币总无效
        //用户最后一个区间的总收益 = 用户的余额 * 用户最后一个区间一个币的总产量
        uint lastSectionNodeSumProfit = userNodeTotalLp[querist][nodeId].mul(_rateTokenOne.sub(nodeRateTokenOne).sub(userNodeRateTokenOne[querist][nodeId])).div(1e18);
        //用户总收益 = 用户之前的总收益 + 用户最后一个区间的实际收益
        return userNodeProfitMapping[querist][nodeId].add(lastSectionNodeSumProfit.mul(1000-scale).div(1000));
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
        uint _rateTokenOne = getRateTokenOne(totalEffective);                          //单币总产量
        uint nodeRateTokenOne = getNotRateTokenOne(totalEffective,nodeId,isEffective);//节点单币总无效
        return nodeTotalLP.mul(_rateTokenOne.sub(nodeRateTokenOne).sub(nodeLastRateTokenOne[nodeId])).div(1e18);
    }

    //获取指定矿主待提取收益
    function getCreatorProfit(uint nodeId) public view returns (uint256) {
        uint nodeTotalLP;      //节点总质押LP
        uint totalEffective;   //全网有效LP
        uint scale;            //节点池获利率
        address creator;       //节点池主人
        uint isEffective;      //是否有效节点 (0:无效,1:有效)
        (nodeTotalLP,totalEffective,scale,creator,isEffective)=NodePool(poolAddress).getNodeUpdataNeed(nodeId);
        if (totalEffective == 0) {
            return nodeProfitMapping[nodeId];
        }
        uint lastBlockNodeProfit = getCreatorWaitCollectionProfit(nodeId,totalEffective,isEffective,nodeTotalLP);
        return nodeProfitMapping[nodeId].add(lastBlockNodeProfit.mul(scale).div(1000));
    }

    //提取指定矿主收益
    function collectCreatorProfit(uint nodeId) public checkStart {
        endBefore(nodeId);
        uint sumProfit = nodeProfitMapping[nodeId];
        if (sumProfit > 0) {
            nodeProfitMapping[nodeId] = 0;                                           //清0用户待提取额
            NodePool(poolAddress).miningCreator(nodeId,outAddress,sumProfit);
        }
    }

    /*---------------------------------------------------管理运营-----------------------------------------------------------*/
    bool public canWithdraw = true;                             //[设置]  关闭/打开 提取
    address public inAddress;                                   //[设置]  质押代币地址
    address public outAddress;                                  //[设置]  产出代币地址
    address public poolAddress;                                 //[设置]  配置节点池地址
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
    function setConfig(address _inAddress,address _outAddress,address _nodePool,uint _miningStartTime,uint _miningRateSecond,uint _miningTimeLength) public onlyOwner {
        inAddress = _inAddress;                        //质押代币
        outAddress = _outAddress;                      //产出代币
        startTime =  _miningStartTime;
        updateTime = startTime;
        poolAddress = _nodePool;
        miningRateSecond = _miningRateSecond;
        miningEndTime = _miningStartTime + _miningTimeLength;
    }
    

    function setNodePool(address _address) public onlyOwner returns (bool){
        poolAddress = _address;
        return true;
    }

    function setCanWithdraw(bool _enable) external onlyOwner {
        emit UpdateWithdrawStatus(canWithdraw, _enable);
        canWithdraw = _enable;
    }

    /*---------------------------------------------------测试方法-----------------------------------------------------------*/
    uint256 public testRateTokenOne;
    mapping(address => mapping(uint256 => uint256)) public testUserNodeRateTokenOne;
    mapping(uint256 => uint256) public testNodeRateTokenOneNot;
    mapping(uint256 => uint256) public testNodeLastRateTokenOne;

    //结算之前的收益
    function testEndBefore(uint nodeId,uint timeNumber,uint totalEffective,uint isEffective) private{
        uint testTimeDifference = getNowTime().sub(updateTime); //测试 | 埋点
        if(timeNumber > 0 && totalEffective > 0){                                   //更新 | 全网单币总产量
            testRateTokenOne = testRateTokenOne.add(testTimeDifference);                                  //测试 | 埋点
            if(isEffective == 0){
                testNodeRateTokenOneNot[nodeId] = testNodeRateTokenOneNot[nodeId].add(testTimeDifference);//测试 | 埋点
            }
        }
        //节点池单币有效总产量
        uint testNodeRateTokenOne = testRateTokenOne.sub(testNodeRateTokenOneNot[nodeId]);//测试 | 埋点
        testUserNodeRateTokenOne[msg.sender][nodeId] = testNodeRateTokenOne;//测试 | 埋点
        testNodeLastRateTokenOne[nodeId] = testNodeRateTokenOne;            //测试 | 埋点
    }

    //一个币在该节点池的总无效收益
    function testGetNotRateTokenOne(uint totalEffective,uint nodeId,uint nodeIsEffective) private view returns (uint256) {
        if (totalEffective == 0) {
            return testNodeRateTokenOneNot[nodeId];
        }
        if(nodeIsEffective == 0){ // 无效节点 | 统计无效收益
            return testNodeRateTokenOneNot[nodeId].add(getNowTime().sub(updateTime));
        } else
            if(nodeIsEffective == 1){
                return testNodeRateTokenOneNot[nodeId];
            } else {
                return testNodeRateTokenOneNot[nodeId];
            }
    }

        //获取指定节点收益时间
    function testGetNodeSumProfit(uint nodeId,address querist,uint isEffective,uint totalEffective,uint scale) private view returns (uint256 sumProfit) {
        uint _rateTokenOne = getRateTokenOne(totalEffective);                          //单币总产量
        uint nodeRateTokenOne = getNotRateTokenOne(totalEffective,nodeId,isEffective);//节点单币总无效
        //用户最后一个区间的总收益 = 用户的余额 * 用户最后一个区间一个币的总产量
        uint lastSectionNodeSumProfit = userNodeTotalLp[querist][nodeId].mul(_rateTokenOne.sub(nodeRateTokenOne).sub(userNodeRateTokenOne[querist][nodeId])).div(1e18);
        //用户总收益 = 用户之前的总收益 + 用户最后一个区间的实际收益
        sumProfit = userNodeProfitMapping[querist][nodeId].add(lastSectionNodeSumProfit.mul(1000-scale).div(1000));
    }

    //获取指定节点收益时间
    function testGetNodeSumTime(uint nodeId,address querist,uint isEffective,uint totalEffective) private view returns (uint256 sumTime,uint lastSumTime) {
        //测试
        uint _testRateTokenOne = testRateTokenOne.add(getNowTime().sub(updateTime));
        uint testNodeRateTokenOne = testGetNotRateTokenOne(totalEffective,nodeId,isEffective);
        lastSumTime = _testRateTokenOne.sub(testNodeRateTokenOne).sub(testUserNodeRateTokenOne[querist][nodeId]);
        sumTime = testUserNodeRateTokenOne[querist][nodeId].add(lastSumTime);
    }

    //获取指定节点收益
    function testGetNodeSumProfitTime(uint nodeId,address querist) public view returns (uint _totalLP,uint256 sumProfit,uint256 sumTime,uint lastSumTime) {
        uint nodeTotalLP;      //节点总质押LP
        uint totalEffective;   //全网有效LP
        uint scale;            //节点池获利率
        uint isEffective;      //是否有效节点 (0:无效,1:有效)
        (nodeTotalLP,totalEffective,scale,,isEffective)=NodePool(poolAddress).getNodeUpdataNeed(nodeId);
        _totalLP = nodeTotalLP;
        sumProfit = testGetNodeSumProfit(nodeId,querist,isEffective,totalEffective,scale);
        (sumTime,lastSumTime) = testGetNodeSumTime(nodeId,querist,isEffective,totalEffective);
    }

    //获取所有节点总收益
    function testGetAllSumProfit(address querist) public view returns (uint nodeTotalLP,uint sumProfit,uint sumTime,uint nodeNumber,uint lastSumTime) {
        uint nodeCount = NodePool(poolAddress).getNodeCount();
        for(uint nodeId = 1;nodeId <= nodeCount; nodeId++){
            if(userNodeTotalLp[querist][nodeId] != 0){      //累加有质押的节点
                uint _totalLP;
                uint _sumProfit;
                uint _sumTime;
                uint _lastSumTime;
                (_totalLP,_sumProfit,_sumTime,_lastSumTime)=testGetNodeSumProfitTime(nodeId,querist);
                nodeTotalLP += _totalLP;
                sumProfit += _sumProfit;
                sumTime += _sumTime;
                lastSumTime += _lastSumTime;
                nodeNumber++;
            } else
                if(userNodeProfitMapping[querist][nodeId] != 0){ //累加没质押有收益的节点
                    (uint _totalLP,,,,)=NodePool(poolAddress).getNodeUpdataNeed(nodeId);
                    nodeTotalLP += _totalLP;
                    sumProfit += userNodeProfitMapping[querist][nodeId];
                    sumTime += testUserNodeRateTokenOne[querist][nodeId];
                    nodeNumber++;
                }
        }
    }

    //获取指定矿主待采集收益
    function testGetCreatorWaitCollectionProfit(uint nodeId,uint totalEffective,uint isEffective,uint nodeTotalLP) private view returns (uint sumProfit,uint sumTime) {
        uint _rateTokenOne = getRateTokenOne(totalEffective);                          //单币总产量
        uint nodeRateTokenOne = getNotRateTokenOne(totalEffective,nodeId,isEffective);//节点单币总无效
        sumProfit = nodeTotalLP.mul(_rateTokenOne.sub(nodeRateTokenOne).sub(nodeLastRateTokenOne[nodeId])).div(1e18);

        uint _testRateTokenOne = testRateTokenOne.add(getNowTime().sub(updateTime));
        uint testNodeRateTokenOne = testGetNotRateTokenOne(totalEffective,nodeId,isEffective);
        sumTime = _testRateTokenOne.sub(testNodeRateTokenOne).sub(testNodeLastRateTokenOne[nodeId]);
    }

    //获取指定矿主待提取收益
    function testGetCreatorProfit(uint nodeId) public view returns (uint totalLp,uint sumProfit,uint sumTime,uint lastSumTime) {
        uint nodeTotalLP;      //节点总质押LP
        uint totalEffective;   //全网有效LP
        uint scale;            //节点池获利率
        address creator;       //节点池主人
        uint isEffective;      //是否有效节点 (0:无效,1:有效)
        (nodeTotalLP,totalEffective,scale,creator,isEffective)=NodePool(poolAddress).getNodeUpdataNeed(nodeId);
        if (totalEffective == 0) {
            sumProfit = nodeProfitMapping[nodeId];
        }
        uint lastBlockNodeProfit;
        uint lastBlockNodeTime;
        (lastBlockNodeProfit,lastBlockNodeTime) = testGetCreatorWaitCollectionProfit(nodeId,totalEffective,isEffective,nodeTotalLP);

        totalLp = nodeTotalLP;

        lastSumTime = lastBlockNodeTime;
        sumProfit = nodeProfitMapping[nodeId].add(lastBlockNodeProfit);
        sumTime = testNodeLastRateTokenOne[nodeId].add(lastBlockNodeTime);
    }

}