/**
 *Submitted for verification at BscScan.com on 2022-03-17
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
    function getNodeScale(uint nodeId) external virtual returns (uint _scale);
    function getNodeCount() external virtual view returns (uint nodeCount);
    function mining(uint nodeId,address outAddress,address _address,uint tokens) external virtual returns (bool success);
    function getNodeUpdataNeed(uint nodeId) external virtual view returns (uint _totalLp,uint _totalLpEffective,uint _scale,address _creator,uint isEffective);
    function setNodeUpdataNeed(uint nodeId,uint totalOutPut,uint creatorProfit) external virtual;
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
    uint256 public miningRateTokenOne;                            //全网一个币的总产量
    uint256 public updateTime;                                    //最近一次更新时间
    mapping(address => mapping(uint256 => uint256)) public userNodeRateTokenOne;          
    mapping(address => mapping(uint256 => uint256)) public userNodeProfitMapping;         
    mapping(address => mapping(uint256 => uint256)) private userNodeTotalLp;//用户质押详情

    mapping(address => uint256) public nodeProfitMapping;         //截至用户最后一次质押、赎回操作之前,矿主的总产量

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
        if(isEffective == 1){//有效节点
            //更新矿主收益
            updateCreatorProfit(nodeId,nodeTotalLP,totalEffective,scale,creator);
            //更新全网单币的总产量
            miningRateTokenOne = getRateTokenOne(totalEffective);

            //最后一个区间用户节点总收益
            uint lastBlockProfit = userNodeTotalLp[msg.sender][nodeId].mul(miningRateTokenOne.sub(userNodeRateTokenOne[msg.sender][nodeId])).div(1e18);
            uint lastBlockUserNodeProfit = lastBlockProfit.mul(1000-scale).div(1000);
            userNodeProfitMapping[msg.sender][nodeId] = userNodeProfitMapping[msg.sender][nodeId].add(lastBlockUserNodeProfit);
            //更新用户单币的总产量
            userNodeRateTokenOne[msg.sender][nodeId] = miningRateTokenOne;
        }
        //更新最后一次操作截止时间
        updateTime = getNowTime();
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
        ERC20(inAddress).transferFrom(msg.sender, address(this), amountToWei);
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
        ERC20(inAddress).transfer(msg.sender, amountToWei);
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
            NodePool(poolAddress).mining(nodeId,outAddress,msg.sender,sumProfit);
            emit RewardPaid(msg.sender, sumProfit);
        }
    }

    /*
     * @dev 提取用户总收益
     */
    function collectProfit() public checkStart {
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
            return miningRateTokenOne;//挖矿速率,一个币的总产量
        }
        //最后一个区间的总产量 = (最新时间 - 最后一次更新时间) * 每秒总产量 
        uint tmp = (getNowTime().sub(updateTime)).mul(miningRateSecond);
        //截止最后一个区间之前的一个币的总产量 + 最后一个区间一个币的总产量(注:最后一个区间的总产量 / 全网总质押LP)
        return miningRateTokenOne.add(tmp.divFloat(totalEffective,18));//挖矿速率,一个币的总产量
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
        if(isEffective == 1){//有效节点
            //用户最后一个区间的总收益 = 用户的余额 * 用户最后一个区间一个币的总产量
            uint lastSectionNodeSumProfit = userNodeTotalLp[querist][nodeId].mul(getRateTokenOne(totalEffective).sub(userNodeRateTokenOne[querist][nodeId])).div(1e18);
            //用户总收益 = 用户之前的总收益 + 用户最后一个区间的实际收益
            return userNodeProfitMapping[querist][nodeId].add(lastSectionNodeSumProfit.mul(1000-scale).div(1000));
        } else {
            return userNodeProfitMapping[querist][nodeId];
        }
    }

    /*
     * @dev 获取所有节点总收益
     * @param querist 询问者
     */
    function getAllSumProfit(address querist) public view returns (uint sumProfit,uint nodeNumber) {
        uint nodeCount = NodePool(poolAddress).getNodeCount();
        for(uint nodeId = 1;nodeId <= nodeCount; nodeId++){
            if(userNodeTotalLp[querist][nodeId] != 0){      //累加有质押的节点
                uint totalEffective; //全网有效LP
                uint scale;            //节点池获利率
                uint isEffective;      //是否有效节点 (0:无效,1:有效)
                (,totalEffective,scale,,isEffective)=NodePool(poolAddress).getNodeUpdataNeed(nodeId);
                if(isEffective == 1){//有效节点
                    //用户最后一个区间的总收益 = 用户的余额 * 用户最后一个区间一个币的总产量
                    uint lastSectionNodeSumProfit = userNodeTotalLp[querist][nodeId].mul(getRateTokenOne(totalEffective).sub(userNodeRateTokenOne[querist][nodeId])).div(1e18);
                    //用户总收益 = 用户之前的总收益 + 用户最后一个区间的实际收益
                    sumProfit += userNodeProfitMapping[querist][nodeId].add(lastSectionNodeSumProfit.mul(1000-scale).div(1000));
                } else {
                    sumProfit += userNodeProfitMapping[querist][nodeId];
                }
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
            if(userNodeTotalLp[querist][nodeId] != 0){
                nodeLength++;
            }
        }
        nodeIds = new uint[](nodeLength);
        totalProfits = new uint[](nodeLength);
        totalLPs = new uint[](nodeLength);
        uint index = 0;
        for(uint nodeId = 1;nodeId <= nodeCount;nodeId++){
            if(userNodeTotalLp[querist][nodeId] != 0){
                nodeIds[index] = nodeId;
                totalProfits[index] = getNodeSumProfit(nodeId,querist);
                totalLPs[index] = userNodeTotalLp[querist][nodeId];
                index++;
            }
        }
    }
    
    function getNowTime() public view returns (uint256) {
        if (miningEndTime > block.timestamp) {
            return block.timestamp;
        }
        return miningEndTime;
    }

    /*---------------------------------------------------矿主-----------------------------------------------------------*/
    //更新矿主收益
    function updateCreatorProfit(uint nodeId,uint nodeTotalLp,uint totalEffective,uint scale,address creator) public {
        //最后一个区间的节点总收益
        if (totalEffective != 0) {
            uint lastBlockNodeProfit = (getNowTime().sub(updateTime)).mul(miningRateSecond).mul(nodeTotalLp).div(totalEffective);
            NodePool(poolAddress).setNodeUpdataNeed(nodeId,lastBlockNodeProfit,lastBlockNodeProfit.mul(scale).div(1000));
            nodeProfitMapping[creator] = nodeProfitMapping[creator].add(lastBlockNodeProfit.mul(scale).div(1000));
        }
    }
    
    //统计节点池的待提取收益
    function getCreatorProfit(uint nodeId) public view returns (uint256) {
        uint nodeTotalLP;      //节点总质押LP
        uint totalEffective;   //全网有效LP
        uint scale;            //节点池获利率
        address creator;       //节点池主人
        uint isEffective;      //是否有效节点 (0:无效,1:有效)
        (nodeTotalLP,totalEffective,scale,creator,isEffective)=NodePool(poolAddress).getNodeUpdataNeed(nodeId);
        if (totalEffective == 0) {
            return nodeProfitMapping[creator];
        }
        if(isEffective == 1){//有效节点
            //最后一个区间的节点总收益
            uint lastBlockNodeProfit = (getNowTime().sub(updateTime)).mul(miningRateSecond).mul(nodeTotalLP).div(totalEffective);
            //总收益 = 用户之前的总收益 + 最后一个区间的实际收益
            return nodeProfitMapping[creator].add(lastBlockNodeProfit.mul(scale).div(1000));
        } else {
            return nodeProfitMapping[creator];
        }

    }

    //提取节点池收益
    function collectCreatorProfit(uint nodeId) public checkStart {
        uint nodeTotalLP;      //节点总质押LP
        uint totalEffective;   //全网有效LP
        uint scale;            //节点池获利率
        address creator;       //节点池主人
        uint isEffective;      //是否有效节点 (0:无效,1:有效)
        (nodeTotalLP,totalEffective,scale,creator,isEffective)=NodePool(poolAddress).getNodeUpdataNeed(nodeId);
        //最后一个区间的节点总收益
        uint lastBlockNodeProfit = 0;
        uint sumProfit = nodeProfitMapping[creator];
        if (totalEffective != 0 && isEffective == 1) { // 有效节点
            lastBlockNodeProfit = (getNowTime().sub(updateTime)).mul(miningRateSecond).mul(nodeTotalLP).div(totalEffective);
            NodePool(poolAddress).setNodeUpdataNeed(nodeId,lastBlockNodeProfit,lastBlockNodeProfit.mul(scale).div(1000)); //更新节点总产量
            sumProfit = nodeProfitMapping[creator].add(lastBlockNodeProfit.mul(scale).div(1000)); //节点池的待提取总收益
            miningRateTokenOne = getRateTokenOne(totalEffective);                         //更新截至当前全网一个币的总产量
        }
        if (sumProfit > 0) {
            nodeProfitMapping[creator] = 0;                                           //清0用户待提取额
            NodePool(poolAddress).mining(nodeId,outAddress,creator,sumProfit);
            emit RewardPaid(creator, sumProfit);
        }
        updateTime = getNowTime();                                                    //更新最后一次操作截止时间
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
    

    /* 矿池 | 配置矿池获利率 */
    function setScale(uint nodeId,uint scale) public onlyOwner returns (bool){
        require(scale >= 50 && scale <= 300,"Node : Within 50 - 300");
        require(nodeId != 0, 'Node : node cannot be 0');
        uint nodeTotalLP;      //节点总质押LP
        uint totalEffective;   //全网有效LP
        address creator;       //节点池主人
        uint isEffective;      //是否有效节点 (0:无效,1:有效)
        (nodeTotalLP,totalEffective,,creator,isEffective)=NodePool(poolAddress).getNodeUpdataNeed(nodeId);
        require(creator != address(0), 'Node : node cannot be 0');
        if(isEffective == 1){ //有效节点
            //更新矿主收益
            updateCreatorProfit(nodeId,nodeTotalLP,totalEffective,scale,creator);
            //更新全网单币的总产量
            miningRateTokenOne = getRateTokenOne(totalEffective);
        }
        //更新最后一次操作截止时间
        updateTime = getNowTime();
        NodePool(poolAddress).setNodeScale(nodeId,scale);
        return true;
    }

    function setNodePool(address _address) public onlyOwner returns (bool){
        poolAddress = _address;
        return true;
    }

    function setCanWithdraw(bool _enable) external onlyOwner {
        emit UpdateWithdrawStatus(canWithdraw, _enable);
        canWithdraw = _enable;
    }

}