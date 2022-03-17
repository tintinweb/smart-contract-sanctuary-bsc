/**
 *Submitted for verification at BscScan.com on 2022-03-17
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

abstract contract ERC20 {
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
    function mint(address _address,uint tokens) external virtual returns (bool success);
}

contract Modifier {
    address internal owner;//合约创建者
    address internal approveAddress;//授权地址
    bool public running = true;
    uint256 internal constant _NOT_ENTERED = 1;
    uint256 internal constant _ENTERED = 2;
    uint256 internal _status;

    modifier onlyOwner(){
        require(msg.sender == owner,"Modifier: The caller is not the creator");
        _;
    }

    modifier onlyApprove(){
        require(msg.sender == approveAddress || msg.sender == owner,"Modifier: The caller is not the approveAddress");
        _;
    }

    modifier nonReentrant() {//防重入攻击
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    modifier isRunning {
        require(running,"Modifier: No Running");
        _;
    }

    constructor() {
        owner = msg.sender;
        _status = _NOT_ENTERED;
    }

    function setApproveAddress(address externalAddress) public onlyOwner(){
        approveAddress = externalAddress;
    }

    function startStop() public onlyOwner returns (bool success) {
        if (running) { running = false; } else { running = true; }
        return true;
    }

    /*
     * @dev 获取授权的地址
     */
    function getApproveAddress() internal view returns(address){
        return approveAddress;
    }

    //当一个合约需要进行以太交易时，需要加两个函数
    fallback () payable external {}
    receive () payable external {}
}

library Counters {
    struct Counter {uint256 _value;}

    function current(Counter storage counter) internal view returns (uint256) {return counter._value;}

    function increment(Counter storage counter) internal {unchecked {counter._value += 1;}}

    function decrement(Counter storage counter) internal {uint256 value = counter._value; require(value > 0, "Counter: decrement overflow"); unchecked {counter._value = value - 1;}}

    function reset(Counter storage counter) internal {counter._value = 0;}
}

library SafeMath {
    /* 加 : a + b */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    /* 减 : a - b */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == a) {
            return 0;
        }
        require(b < a, "SafeMath: subtraction overflow");
        return a - b;
    }
}

contract NodePool is Modifier {
    using Counters for Counters.Counter;
    using SafeMath for uint;
    Counters.Counter _nodeIds;
    
    uint totalLpEffective;                                       //[统计]  全网有效LP(初始不能为0)
    uint totalCollect;                                           //[统计]  总提取数量
    mapping(address => uint) public nodeMasterMapping;           //<节点池主人,节点池地址>
    mapping(uint => Node) public nodePoolMapping;                //<节点池地址,节点池信息>

    uint public firstNodeId;                                     //第一个节点的ID
    uint public lastNodeId;                                      //最后一个节点的ID

    struct Node {
        uint nodeId;                //节点ID
        bool isOpen;                //挖矿状态 (管理员可以开启,关闭节点池挖矿状态)
        bool isFlag;                //挖矿状态 (自己可以开启,关闭节点池挖矿状态)
        uint totalLp;               //总算力
        uint totalCollect;          //总提取数量
        uint totalOutPut;           //总产量
        uint totalCreator;          //矿主总收益
        uint leftId;                //上一个节点ID
        uint rightId;               //下一个节点ID
        uint scale;                 //配置矿池获利率 (管理员或自己可以调整,范围[50,300],默认 200千分之)
        uint isEffective;           //是否有效节点 (0:无效,1:有效)
        uint createTime;            //创建时间
        address creator;            //创建者
    }

    /*
     * @dev 创建 | 所有人调用 | 创建节点
     * @param _scale 矿池创建者获利率 (范围[50,300],默认 200千分之)
     */
    function createNode(uint _scale) public returns (uint nodeId){
        require(nodeMasterMapping[msg.sender] == 0,"NodePool : Node already exists");
        require(_scale >= 50 && _scale <= 300,"NodePool : Within 50 - 300");
        _nodeIds.increment();
        nodeId = _nodeIds.current();
        nodeMasterMapping[msg.sender] = nodeId;
        if(firstNodeId == 0){
            nodePoolMapping[nodeId] = Node(nodeId,true,true,0,0,0,0,nodeId,nodeId,_scale,0,block.timestamp,msg.sender);
            firstNodeId = nodeId;
            lastNodeId = nodeId;
        } else {
            nodePoolMapping[lastNodeId].rightId = nodeId;
            nodePoolMapping[nodeId] = Node(nodeId,true,true,0,0,0,0,lastNodeId,nodeId,_scale,0,block.timestamp,msg.sender);
            lastNodeId = nodeId;
        }
    }

    /*
     * @dev 修改 | 所有人调用 | 增加算力
     * @param nodeId  节点ID
     * @param amountToWei  金额
     */
    function addPower(uint nodeId,uint amountToWei) external{
        if(nodePoolMapping[nodeId].createTime == 0){ _status = _NOT_ENTERED; revert("NodePool : Node does not exist"); }
        if(nodePoolMapping[nodeId].isOpen == false){ _status = _NOT_ENTERED; revert("NodePool : Node Pool Stopped"); }
        if(nodePoolMapping[nodeId].isFlag == false){ _status = _NOT_ENTERED; revert("NodePool : Node Pool Closed"); }
        nodePoolMapping[nodeId].totalLp = nodePoolMapping[nodeId].totalLp.add(amountToWei);//增加算力
        updSort(nodeId,nodePoolMapping[nodeId].totalLp);//更新排序
        handleEffective();//处理有效
    }

    /*
     * @dev 修改 | 所有人调用 | 减少算力
     * @param nodeId  节点ID
     * @param amountToWei  金额
     */
    function removePower(uint nodeId,uint amountToWei) external{
        if(nodePoolMapping[nodeId].createTime == 0){ _status = _NOT_ENTERED; revert("NodePool : Node does not exist"); }
        if(nodePoolMapping[nodeId].totalLp < amountToWei){ _status = _NOT_ENTERED; revert("NodePool : Node pool power Insufficient"); }
        nodePoolMapping[nodeId].totalLp = nodePoolMapping[nodeId].totalLp.sub(amountToWei);//减少算力
        updSort(nodeId,nodePoolMapping[nodeId].totalLp);//更新排序
        handleEffective();//处理有效
    }

    /*
     * @dev 修改 | 内部调用 | 更新排序
     * @param nodeId  节点ID
     * @param nodeAmount  金额
     */
    function updSort(uint nodeId,uint nodeAmount) public returns (bool){
        uint firstNodeLp = nodePoolMapping[firstNodeId].totalLp;
        if(nodeAmount > firstNodeLp){// 1.插入到第一个位置
            handleOldIndex(nodeId);//处理原位置
            nodePoolMapping[firstNodeId].leftId = nodeId;
            nodePoolMapping[nodeId].leftId = nodeId;
            nodePoolMapping[nodeId].rightId = firstNodeId;
            firstNodeId = nodeId;
            return true;
        }
        uint startId = firstNodeId;
        while(startId != lastNodeId){// 2.插入到中间位置
            uint nextId = nodePoolMapping[startId].rightId;
            uint startLP = nodePoolMapping[startId].totalLp;
            uint nextLP = nodePoolMapping[nextId].totalLp;
            if(startLP >= nodeAmount && nodeAmount > nextLP){
                if(startId != nodeId && nodeId != nextId){
                    handleOldIndex(nodeId);//处理原位置
                    nodePoolMapping[startId].rightId = nodeId;
                    nodePoolMapping[nextId].leftId = nodeId;

                    nodePoolMapping[nodeId].leftId = startId;
                    nodePoolMapping[nodeId].rightId = nextId;
                }
                break;
            }
            startId = nextId;
        }
        if(startId == lastNodeId){   // 3.插入到最后一个位置
            handleOldIndex(nodeId);//处理原位置
            nodePoolMapping[lastNodeId].rightId = nodeId;
            nodePoolMapping[nodeId].leftId = lastNodeId;
            nodePoolMapping[nodeId].rightId = nodeId;
            lastNodeId = nodeId;
        }
        return true;
    }
    
    //处理原位置
    function handleOldIndex(uint nodeId) public{
        uint leftId = nodePoolMapping[nodeId].leftId;
        uint rightId = nodePoolMapping[nodeId].rightId;
        // 原位置就在链表中 && 有2个及以上节点
        if(leftId != 0 && rightId != 0 && firstNodeId != lastNodeId){
            if(nodeId == firstNodeId){           // 原位置是左边第一个
                nodePoolMapping[rightId].leftId = rightId;
                firstNodeId = rightId;
            }
            if(nodeId == lastNodeId){           // 原位置是右边最后一个
                nodePoolMapping[leftId].rightId = leftId;
                lastNodeId = leftId;
            }
            if(nodeId != firstNodeId && nodeId != lastNodeId){ //原位置在中间
                nodePoolMapping[leftId].rightId = rightId;
                nodePoolMapping[rightId].leftId = leftId;
            }
        }
    }

    /*
     * @dev 查询 | 所有人调用 | 处理有效节点
     */
    function handleEffective() public{
        uint startId = firstNodeId; //起始节点ID
        uint effectiveCount = 0;    //有效数量
        uint sumEffectivePower = 0; //全网有效LP
        while(startId != lastNodeId){
            if(nodePoolMapping[startId].totalLp >= producePowerMin && effectiveCount < produceRankingMin){
                //有效节点
                if(nodePoolMapping[startId].isEffective == 0){
                    nodePoolMapping[startId].isEffective == 1;
                }
                sumEffectivePower = sumEffectivePower.add(nodePoolMapping[startId].totalLp);
                effectiveCount++;
            } else {
                //无效节点
                if(nodePoolMapping[startId].isEffective == 1){
                    nodePoolMapping[startId].isEffective == 0;
                }
            }
            startId = nodePoolMapping[startId].rightId;
        }
        totalLpEffective = sumEffectivePower;
    }

    /*
     * @dev 查询 | 所有人调用 | 查询排名TOP
     * @param totalOutPut 排名TOP总产出
     * @param rankingArray 节点列表
     */
    function queryRankingTop() public view returns (uint totalOutPut,Node[] memory rankingArray){
        if(firstNodeId != 0){
            uint nodeLength = 0;
            uint startId = firstNodeId;
            do{
                nodeLength++;
                startId = nodePoolMapping[startId].rightId;
            } while(startId != lastNodeId && nodeLength <= produceRankingMin);
            if(firstNodeId != lastNodeId){
                nodeLength++;
            }
            
            rankingArray = new Node[](nodeLength);
            nodeLength = 0;
            startId = firstNodeId;
            do{
                rankingArray[nodeLength++] = nodePoolMapping[startId];
                totalOutPut = totalOutPut.add(nodePoolMapping[startId].totalOutPut);
                startId = nodePoolMapping[startId].rightId;
            } while(startId != lastNodeId && nodeLength <= produceRankingMin);
            if(firstNodeId != lastNodeId){
                rankingArray[nodeLength] = nodePoolMapping[startId];
                totalOutPut = totalOutPut.add(nodePoolMapping[startId].totalOutPut);
            }
        }
    }
    
    /*
     * @dev 查询 | 所有人调用 | 查询排名所有
     * @param totalOutPut 排名TOP总产出
     * @param rankingArray 节点列表
     */
    function queryRankingAll() public view returns (uint totalOutPut,Node[] memory rankingArray){
        if(firstNodeId != 0){
            uint nodeLength = 0;
            uint startId = firstNodeId;
            do{
                nodeLength++;
                startId = nodePoolMapping[startId].rightId;
            } while(startId != lastNodeId);
            if(firstNodeId != lastNodeId){
                nodeLength++;
            }

            rankingArray = new Node[](nodeLength);
            nodeLength = 0;
            startId = firstNodeId;
            do{
                rankingArray[nodeLength++] = nodePoolMapping[startId];
                totalOutPut = totalOutPut.add(nodePoolMapping[startId].totalOutPut);
                startId = nodePoolMapping[startId].rightId;
            } while(startId != lastNodeId);
            if(firstNodeId != lastNodeId){
                rankingArray[nodeLength] = nodePoolMapping[startId];
                totalOutPut = totalOutPut.add(nodePoolMapping[startId].totalOutPut);
            }
        }
    }


    /*
     * @dev 修改 | 子节点调用 | 出矿
     * @param nodeId 节点ID
     * @param _tokenAddress 出矿代币合约
     * @param _address 出矿地址
     * @param _tokens 出矿数量
     */
    function mining(uint nodeId,address _tokenAddress,address _address,uint tokens) external returns(bool){
        require(nodePoolMapping[nodeId].createTime != 0,"NodePool : No node");
        nodePoolMapping[nodeId].totalCollect = nodePoolMapping[nodeId].totalCollect.add(tokens);
        totalCollect = totalCollect.add(tokens);
        return ERC20(_tokenAddress).mint(_address,tokens);
    }


    /*---------------------------------------------------管理运营-----------------------------------------------------------*/
    uint private producePowerMin = 10000000000000000000000;         //节点池产矿最低总算力条件
    uint private produceRankingMin = 49;                            //节点池产矿最低排名条件


    /*
     * @dev 设置 | 管理员调用 | 产矿排名条件
     * @param _producePowerMin 节点池产矿最低总算力条件
     * @param _produceRankingMin 节点池产矿最低排名条件
     */
    function setRankingConfig(uint _producePowerMin,uint _produceRankingMin) public onlyOwner {
        producePowerMin = _producePowerMin;
        produceRankingMin = _produceRankingMin;
    }

    /*
     * @dev 设置 | 节点合约调用 | 配置节点获利率
     * @param _scale 配置矿池获利率 (范围[50,300],默认 200千分之)
     */
    function setNodeScale(uint nodeId,uint _scale) external returns (bool){
        require(_scale >= 50 && _scale <= 300,"NodePool : Within 50 - 300");
        require(nodePoolMapping[nodeId].createTime != 0,"NodePool : No node");
        nodePoolMapping[nodeId].scale = _scale;
        return true;
    }

    /*
     * @dev 获取 | 节点合约调用 | 获取节点获利率
     * @param nodeId 节点ID
     */
    function getNodeScale(uint nodeId) external view returns (uint scale){
        require(nodePoolMapping[nodeId].createTime != 0,"NodePool : No node");
        scale = nodePoolMapping[nodeId].scale;
    }

    /*
     * @dev 获取 | 节点ID | 获取节点数量
     */
    function getNodeCount() external view returns (uint nodeCount){
        return _nodeIds.current();
    }

    /*
     * @dev 获取 | 节点合约调用 | 获取节点更新需要的数据
     * @param nodeId 节点ID
     * @return _totalLp 节点总质押LP
     * @return _totalLpEffective 全网有效LP
     * @return _scale 节点池获利率
     * @return _creator 节点池主人
     * @return _isEffective 是否有效节点 (0:无效,1:有效)
     */
    function getNodeUpdataNeed(uint nodeId) external view returns (uint _totalLp,uint _totalLpEffective,uint _scale,address _creator,uint _isEffective){
        require(nodePoolMapping[nodeId].createTime != 0,"NodePool : No node");
        _totalLp = nodePoolMapping[nodeId].totalLp;
        _totalLpEffective = totalLpEffective;
        _scale = nodePoolMapping[nodeId].scale;
        _creator = nodePoolMapping[nodeId].creator;
        _isEffective = nodePoolMapping[nodeId].isEffective;
    }

    /*
     * @dev 修改 | 节点合约调用 | 更新节点数据
     * @param nodeId 节点ID
     * @return totalOutPut 节点总产量
     * @return creatorProfit 矿主收益
     */
    function setNodeUpdataNeed(uint nodeId,uint totalOutPut,uint creatorProfit) external {
        require(nodePoolMapping[nodeId].createTime != 0,"NodePool : No node");
        nodePoolMapping[nodeId].totalOutPut = nodePoolMapping[nodeId].totalOutPut.add(totalOutPut);
        nodePoolMapping[nodeId].totalCreator = nodePoolMapping[nodeId].totalCreator.add(creatorProfit);
    }
}