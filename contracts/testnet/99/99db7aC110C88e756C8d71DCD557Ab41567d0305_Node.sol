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
    mapping(address => bool) private updateMapping; //????????????mapping

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

//??????LP??????
contract Node is Comn{
    using SafeMath for uint256;
    uint256 public startTime;                                     //????????????
    uint256 public totalLP;                                       //????????????
    uint256 public rateTokenOne;                                  //???????????????????????????
    uint256 public updateTime;                                    //????????????????????????
    mapping(address => mapping(uint256 => uint256)) public userNodeRateTokenOne;    //??????????????????????????????      
    mapping(address => mapping(uint256 => uint256)) public userNodeProfitMapping;   //??????????????????
    mapping(address => mapping(uint256 => uint256)) public userNodeTotalLp;         //??????????????????

    mapping(uint256 => uint256) public nodeProfitMapping;             //????????????????????????
    mapping(uint256 => uint256) public nodeRateTokenOne;              //????????????????????????
    mapping(uint256 => uint256) public nodeRateTokenOneEffective;     //??????????????????????????????
    mapping(uint256 => uint256) public nodeCreatorRateTokenOne;

    mapping(address => uint) public userTotalCollect;                 //???????????????
    
    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event UpdateWithdrawStatus(bool oldStatus, bool newStatus);

    modifier updateBefore(uint nodeId) { //?????????????????????
        endBefore(nodeId);
        _;
    }

    /*
     * @dev ?????????????????????
     * @param nodeId ??????ID
     */
    function endBefore(uint nodeId) private {
        if(nodeId == 0){ _status = _NOT_ENTERED; revert("Node : node cannot be 0"); }
        uint nodeTotalLP;      //???????????????LP
        uint totalEffective;   //????????????LP
        uint scale;            //??????????????????
        uint isEffective;      //?????????????????? (0:??????,1:??????)
        (nodeTotalLP,totalEffective,scale,,isEffective)=NodePool(poolAddress).getNodeUpdataNeedByNodeId(nodeId);
        rateTokenOne = getRateTokenOne(totalEffective);                                                                            //?????? | ?????????????????????
        if(isEffective == 1){
            nodeRateTokenOneEffective[nodeId] = nodeRateTokenOneEffective[nodeId].add(sub(rateTokenOne,nodeRateTokenOne[nodeId])); //?????? | ???????????????????????????
            updUserProfit(nodeId,scale);                //??????????????????
            updCreatorProfit(nodeId,nodeTotalLP,scale); //??????????????????
        }else{
            if(userNodeRateTokenOne[msg.sender][nodeId] != nodeRateTokenOneEffective[nodeId]){
                userNodeRateTokenOne[msg.sender][nodeId] = nodeRateTokenOneEffective[nodeId];
            }
        }
        nodeRateTokenOne[nodeId] = rateTokenOne;                                                                                   //?????? | ????????????????????????
        //????????????????????????????????????
        updateTime = getNowTime();
    }
    
    function endAfterN2Y(uint nodeId) external onlyPool {
        if(rateTokenOne != nodeRateTokenOne[nodeId]){
            //?????? | ???????????? (????????????)
            //?????? | ???????????? (????????????)
            //?????? | ????????????????????????
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
            nodeRateTokenOneEffective[nodeId] = nodeRateTokenOneEffective[nodeId].add(sub(rateTokenOne,nodeRateTokenOne[nodeId])); //?????? | ???????????????????????????
            //?????? | ???????????? (????????????)
            //?????? | ????????????
            updCreatorProfit(nodeId,nodeTotalLP,scale);
            //?????? | ????????????????????????
            nodeRateTokenOne[nodeId] = rateTokenOne;
        }
    }

    //??????????????????
    function updUserProfit(uint nodeId,uint scale) private{
        uint lastBlockUserOutPut = userNodeTotalLp[msg.sender][nodeId].mul(sub(nodeRateTokenOneEffective[nodeId],userNodeRateTokenOne[msg.sender][nodeId])).div(1e18);
        if(lastBlockUserOutPut > 0){
            userNodeProfitMapping[msg.sender][nodeId] = userNodeProfitMapping[msg.sender][nodeId].add(lastBlockUserOutPut.mul(1000-scale).div(1000));
        }
        userNodeRateTokenOne[msg.sender][nodeId] = nodeRateTokenOneEffective[nodeId];                                       
    }

    //??????????????????
    function updCreatorProfit(uint nodeId,uint nodeTotalLP,uint scale) private{
        uint lastBlockNodeOutPut = nodeTotalLP.mul(sub(nodeRateTokenOneEffective[nodeId],nodeCreatorRateTokenOne[nodeId])).div(1e18);
        if(lastBlockNodeOutPut > 0){
            nodeProfitMapping[nodeId] = nodeProfitMapping[nodeId].add(lastBlockNodeOutPut.mul(scale).div(1000));
            NodePool(poolAddress).setNodeOutPut(nodeId,lastBlockNodeOutPut);
        }
        nodeCreatorRateTokenOne[nodeId] = nodeRateTokenOneEffective[nodeId];
    }

    /*
     * @dev ??????LP
     * @param nodeId ??????ID
     * @param amountToWei ??????
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
     * @dev ??????LP
     * @param nodeId ??????ID
     * @param amountToWei ??????
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
     * @dev ????????????????????????
     * @param nodeId ??????ID
     */
    function collectProfit(uint nodeId) public nonReentrant updateBefore(nodeId) checkStart checkCollect {
        uint256 sumProfit = userNodeProfitMapping[msg.sender][nodeId];//???????????????
        if (sumProfit > 0) {
            userNodeProfitMapping[msg.sender][nodeId] = 0;
            userTotalCollect[msg.sender] = userTotalCollect[msg.sender].add(sumProfit);
            ERC20(poolFactory).mining(msg.sender,sumProfit);
            emit RewardPaid(msg.sender, sumProfit);
        }
    }

    /*
     * @dev ?????????????????????
     */
    function collectProfitAll() public nonReentrant checkStart checkCollect {
        uint nodeCount = NodePool(poolAddress).getNodeCount();
        uint sumProfit;
        for(uint nodeId = 1;nodeId <= nodeCount; nodeId++){
            uint nodeProfit; //???????????????
            if(userNodeTotalLp[msg.sender][nodeId] != 0){      //????????????????????????
                endBefore(nodeId);//?????????????????????
                nodeProfit = userNodeProfitMapping[msg.sender][nodeId];
            } else 
            if(userNodeProfitMapping[msg.sender][nodeId] != 0){ //?????????????????????????????????
                nodeProfit = userNodeProfitMapping[msg.sender][nodeId];
            }
            if(nodeProfit > 0){ // ?????????
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
     * @dev ??????LP???????????????
     * @param nodeId ??????ID
     * @param amountToWei ??????
     */
    function collectAndRedeem(uint nodeId,uint amountToWei) external nonReentrant checkStart updateBefore(nodeId) checkRedeem checkCollect {
        if(amountToWei == 0){ _status = _NOT_ENTERED; revert("Node : Cannot stake 0"); }
        if(userNodeTotalLp[msg.sender][nodeId] < amountToWei){ _status = _NOT_ENTERED; revert("Node : Insufficient node balance"); }
        totalLP = sub(totalLP,amountToWei);
        userNodeTotalLp[msg.sender][nodeId] = sub(userNodeTotalLp[msg.sender][nodeId],amountToWei);
        ERC20(inAddress).transfer(msg.sender, amountToWei);
        NodePool(poolAddress).removePower(nodeId,amountToWei);
        emit Withdrawn(msg.sender, amountToWei);
        
        uint256 sumProfit = userNodeProfitMapping[msg.sender][nodeId];//???????????????
        if (sumProfit > 0) {
            userNodeProfitMapping[msg.sender][nodeId] = 0;
            userTotalCollect[msg.sender] = userTotalCollect[msg.sender].add(sumProfit);
            ERC20(poolFactory).mining(msg.sender,sumProfit);
            emit RewardPaid(msg.sender, sumProfit);
        }
    }

    /*---------------------------------------------------?????????-----------------------------------------------------------*/
    
    //????????????????????????,?????????????????????
    function getRateTokenOne(uint totalEffective) public view returns (uint256) {
        if (totalEffective == 0) {
            return rateTokenOne;//????????????,?????????????????????
        }
        //?????????????????????????????????????????????????????? + ???????????????????????????????????????(???:?????????????????????????????? / ???????????????LP)
        return rateTokenOne.add(getLastBlockProfit().divFloat(totalEffective,18));//????????????,?????????????????????
    }

    //???????????????????????????
    function getNodeRateTokenOneEffective(uint totalEffective,uint nodeId,uint isEffective) public view returns (uint256 effectiveRateTokenOne) {
        uint _rateTokenOne = getRateTokenOne(totalEffective); // ???????????????????????????
        if(isEffective == 1){
            effectiveRateTokenOne = nodeRateTokenOneEffective[nodeId].add(_rateTokenOne.sub(nodeRateTokenOne[nodeId]));
        } else {
            effectiveRateTokenOne = nodeRateTokenOneEffective[nodeId];
        }
    }

    /*
     * @dev ????????????????????????
     * @param nodeId ??????ID
     * @param querist ?????????
     */
    function getNodeSumProfit(uint nodeId,address querist) public view returns (uint256) {
        uint totalEffective;   //????????????LP
        uint scale;            //??????????????????
        uint isEffective;      //?????????????????? (0:??????,1:??????)
        (,totalEffective,scale,,isEffective)=NodePool(poolAddress).getNodeUpdataNeedByNodeId(nodeId);
        uint _nodeRateTokenOneEffective = getNodeRateTokenOneEffective(totalEffective,nodeId,isEffective);//?????????????????????
        //????????????????????????????????????
        uint lastBlockNodeSumProfit = userNodeTotalLp[querist][nodeId].mul(_nodeRateTokenOneEffective.sub(userNodeRateTokenOne[querist][nodeId])).div(1e18);
        //??????????????? = ???????????????????????? + ???????????????????????????????????????
        return userNodeProfitMapping[querist][nodeId].add(lastBlockNodeSumProfit.mul(1000-scale).div(1000));
    }
    
    /*
     * @dev ???????????????????????????
     * @param querist ?????????
     */
    function getAllSumProfit(address querist) public view returns (uint sumProfit,uint nodeNumber) {
        uint nodeCount = NodePool(poolAddress).getNodeCount();
        for(uint nodeId = 1;nodeId <= nodeCount; nodeId++){
            if(userNodeTotalLp[querist][nodeId] != 0){      //????????????????????????
                sumProfit += getNodeSumProfit(nodeId,querist);
                nodeNumber++;
            } else 
            if(userNodeProfitMapping[querist][nodeId] != 0){ //?????????????????????????????????
                sumProfit += userNodeProfitMapping[querist][nodeId];
                nodeNumber++;
            }
        }
    }

    //????????????????????????
    function getUserTotalOutPut(address querist) public view returns (uint256 totalOutPut) {
        (uint userWaitSumProfit,) = getAllSumProfit(querist);         // ?????????????????????
        uint nodeId = NodePool(poolAddress).getNodeIdByCreator(querist);
        if(nodeId != 0){
            uint creatorWaitSumProfit = getNodeProfitByNodeId(nodeId);    // ?????????????????????
            totalOutPut = userTotalCollect[msg.sender].add(userWaitSumProfit).add(creatorWaitSumProfit);
        } else {
            totalOutPut = userTotalCollect[msg.sender].add(userWaitSumProfit);
        }
    }

    //?????????????????????
    function getUserTotalLp(address querist) public view returns (uint256 userTotalLP) {
        uint256 nodeCount = NodePool(poolAddress).getNodeCount();
        for(uint nodeId = 1;nodeId <= nodeCount;nodeId++){
            if(userNodeTotalLp[querist][nodeId] != 0){
                userTotalLP += userNodeTotalLp[querist][nodeId];
            }
        }
    }

    /*
     * @dev ??????????????????????????????????????????
     * @param nodeIds ??????ID
     * @param totalProfits ?????????
     * @param totalLPs ????????????
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
     * @dev ?????????????????????
     * @return lastBlockProfit ???????????????
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

    /*---------------------------------------------------??????-----------------------------------------------------------*/
    //?????????????????????????????????
    function getCreatorWaitCollectionProfit(uint nodeId,uint totalEffective,uint isEffective,uint nodeTotalLP) public view returns (uint256) {
        uint _nodeRateTokenOneEffective = getNodeRateTokenOneEffective(totalEffective,nodeId,isEffective);//?????????????????????
        return nodeTotalLP.mul(_nodeRateTokenOneEffective.sub(nodeCreatorRateTokenOne[nodeId])).div(1e18);
    }

    //????????????ID?????????????????????????????????????????????
    function getNodeProfitByNodeId(uint nodeId) public view returns (uint256) {
        uint nodeTotalLP;      //???????????????LP
        uint totalEffective;   //????????????LP
        uint scale;            //??????????????????
        address creator;       //???????????????
        uint isEffective;      //?????????????????? (0:??????,1:??????)
        (nodeTotalLP,totalEffective,scale,creator,isEffective)=NodePool(poolAddress).getNodeUpdataNeedByNodeId(nodeId);
        if (totalEffective == 0) {
            return nodeProfitMapping[nodeId];
        }
        uint lastBlockNodeProfit = getCreatorWaitCollectionProfit(nodeId,totalEffective,isEffective,nodeTotalLP);
        return nodeProfitMapping[nodeId].add(lastBlockNodeProfit.mul(scale).div(1000));
    }

    //????????????????????????????????????????????????????????????
    function getNodeProfitByCreator(address querist) public view returns (uint256) {
        uint nodeId = NodePool(poolAddress).getNodeIdByCreator(querist);
        if(nodeId != 0){
           return getNodeProfitByNodeId(nodeId);
        } else {
            return 0;
        }
    }

    //????????????????????????
    function collectCreatorProfit(uint nodeId) public nonReentrant updateBefore(nodeId) checkStart checkCollect {
        uint sumProfit = nodeProfitMapping[nodeId];
        if (sumProfit > 0) {
            nodeProfitMapping[nodeId] = 0;                                           //???0??????????????????
            userTotalCollect[msg.sender] = userTotalCollect[msg.sender].add(sumProfit);
            (,,,address creator,)=NodePool(poolAddress).getNodeUpdataNeedByNodeId(nodeId);
            ERC20(poolFactory).mining(creator,sumProfit);
        }
    }

    /*---------------------------------------------------????????????-----------------------------------------------------------*/
    bool public canCollect = true;                              //[??????]  ???/??? ??????
    bool public canProduce = true;                              //[??????]  ???/??? ??????
    bool public canPledge = true;                               //[??????]  ???/??? ??????
    bool public canRedeem = true;                               //[??????]  ???/??? ??????
    address public inAddress;                                   //[??????]  ??????????????????
    address public poolFactory;                                  //[??????]  ??????????????????
    address public poolAddress;                                 //[??????]  ?????????????????????
    uint public miningStartTime;                                //[??????]  ???????????? (??????:???)
    uint public miningEndTime;                                  //[??????]  ???????????? (??????:???)
    uint public miningRateSecond;                               //[??????]  ???????????? (??????:???)
    uint public stopSurplusTime;                                //??????????????????

    modifier onlyPool(){
        if(msg.sender != poolAddress){ _status = _NOT_ENTERED; revert("Modifier: The caller is not the pool"); }
        _;
    }
    modifier checkStart() { //????????????
        if(block.timestamp < startTime){ _status = _NOT_ENTERED; revert("Node : Not Start"); }
        _;
    }
    modifier checkPledge() { //????????????
        if(canPledge == false){ _status = _NOT_ENTERED; revert("Node : Not Pledge"); }
        _;
    }
    modifier checkRedeem() { //????????????
        if(canRedeem == false){ _status = _NOT_ENTERED; revert("Node : Not Redeem"); }
        _;
    }
    modifier checkCollect() { //????????????
        if(canCollect == false){ _status = _NOT_ENTERED; revert("Node : Not Collect"); }
        _;
    }
    
    /*
     * @param _inAddress ??????????????????
     * @param _poolFactory ??????????????????
     * @param _nodePool ???????????????
     * @param _miningStartTime ?????????????????? (??????:???)
     * @param _miningRateSecond ???????????? (??????:???)
     * @param _miningTimeLength ???????????? (??????:???)
     */
    function setConfig(address _inAddress,address _poolFactory,address _nodePool,uint _miningStartTime,uint _miningRateSecond,uint _miningTimeLength) public onlyOwner {
        inAddress = _inAddress;                        //????????????
        poolFactory = _poolFactory;                      //??????????????????
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
            if(_canProduce){ //??????
                if(stopSurplusTime > 0){
                   miningEndTime = nowTime.add(stopSurplusTime);
                   updateTime = nowTime; 
                   stopSurplusTime = 0;
                }
            } else { //??????
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