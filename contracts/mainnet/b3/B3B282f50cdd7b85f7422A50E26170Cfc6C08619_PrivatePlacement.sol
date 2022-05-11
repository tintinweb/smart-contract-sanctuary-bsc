/**
 *Submitted for verification at BscScan.com on 2022-05-11
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

abstract contract ERC20 {
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
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
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
    /* 乘 : a * b */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    /* 除 : a / b */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    /* 除 : a / b */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    /* 末 : a % b */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    /* 末 : a % b */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Util {

    /*
     * @dev 转换位
     * @param price 价格
     * @param decimals 代币的精度
     */
    function toWei(uint256 price, uint decimals) public pure returns (uint256){
        uint256 amount = price * (10 ** uint256(decimals));
        return amount;
    }

}

contract PrivatePlacement is Modifier,Util {
    using Counters for Counters.Counter;
    using SafeMath for uint;
    Counters.Counter private _coinIds;
    Counters.Counter private _nodeIds;
    mapping(address => address) private invitationMapping;          //邀请关系Mapping
    mapping(address => bool) private nodeMapping;                   //节点身份Mapping
    mapping(address => uint) private shareMaxMapping;               //单笔奖励限额Mapping
    ERC20 private buyToken;                                         //购买代币信息
    ERC20 private sellToken;                                        //出售代币信息
    // [单价,计划交易总量,已成交量,已成交额,已经成交笔数,上浮条件,上浮数,上浮额,是否开启(1:开启,2:关闭)]
    uint[9][3] private privatePlacementInfo;
    uint private privatePlacementIndex;                             //当前私募期号          1
    uint private privatePlacementQuota;                             //私募最低限额          100000000000000000000
    uint private nodeReleaseScale;                                  //节点提成比例          100
    mapping(uint => address) private coinCollectPool;
    mapping(uint => address) private nodeCollectPool;
    mapping(address => bool) private coinCollectPoolState;
    mapping(address => bool) private nodeCollectPoolState;
    uint coinCollectPoolIndex = 1;
    uint nodeCollectPoolIndex = 1;

    constructor() {
         invitationMapping[0xcb9E693456eC7817e7a2814Ef373BCf472B9612b] = address(this);
    }

    /*
     * @dev 设置 | 创建者调用 | 设置代币合约地址
     * @param _buyToken  配置购买代币合约地址
     * @param _sellToken 配置出售代币合约地址
     */
    function setTokenContract(address _buyToken,address _sellToken) public onlyOwner {
        buyToken = ERC20(_buyToken);
        sellToken = ERC20(_sellToken);
    }

    /*
     * @dev 设置 | 创建者调用 | 初始化私募信息
     * @param index 需要设置的私募期号
     * @param privatePlacementItem 私募信息
     */
    function setPrivatePlacementInfo(uint index,uint[9] memory privatePlacementItem) public onlyOwner{
        require(privatePlacementItem.length == 9,"PrivatePlacement : Inconsistent length");
        privatePlacementInfo[index] = privatePlacementItem;
    }

    function setPrivatePlacementPrice(uint index,uint amountToWei) public onlyOwner{
        require(amountToWei > 0,"PrivatePlacement : Unit amount must be greater than 0");
        privatePlacementInfo[index][0] = amountToWei;
    }

    function setPrivatePlacementUpAmount(uint index,uint amountToWei) public onlyOwner{
        require(amountToWei > 0,"PrivatePlacement : Unit amount must be greater than 0");
        privatePlacementInfo[index][6] = amountToWei;
    }

    function setPrivatePlacementState(uint index,bool flag) public onlyOwner{
        require(privatePlacementInfo[index][8] != 0,"PrivatePlacement : Private placement information does not exist");
        if(flag){
            privatePlacementInfo[index][8] = 1;
        } else {
            privatePlacementInfo[index][8] = 2;
        }
    }

    /*
     * @dev 设置 | 创建者调用 | 设置配置信息
     * @param _privatePlacementIndex  当前私募期号
     * @param _privatePlacementQuota  私募最低限额
     * @param _nodeReleaseScale       节点提成比例
     */
    function setConfigure(uint _privatePlacementIndex,uint _privatePlacementQuota,uint _nodeReleaseScale) public onlyOwner {
        if(_nodeReleaseScale == 0){ _status = _NOT_ENTERED;revert("PrivatePlacement : Transaction proportion must be greater than 0%");}
        if(_nodeReleaseScale > 1000){ _status = _NOT_ENTERED;revert("PrivatePlacement : Transaction proportion must be less than 1000");}
        privatePlacementIndex = _privatePlacementIndex;
        privatePlacementQuota = _privatePlacementQuota;
        nodeReleaseScale = _nodeReleaseScale;
    }

    function setCoinCollectPool(address _address) external onlyOwner {
        require(_address != address(0) && _address != address(this),"PrivatePlacement : address error");
        _coinIds.increment();
        uint currentId = _coinIds.current();
        coinCollectPool[currentId] = _address;
        coinCollectPoolState[_address] = true;
    }

    function setNodeCollectPool(address _address) external onlyOwner {
        require(_address != address(0) && _address != address(this),"PrivatePlacement : address error");
        _nodeIds.increment();
        uint currentId = _nodeIds.current();
        nodeCollectPool[currentId] = _address;
        nodeCollectPoolState[_address] = true;
    }

    function updCoinCollectPoolState(uint index,bool state) external onlyOwner {
        require(index > 0 && index <= _coinIds.current(),"PrivatePlacement : index error");
        address _address = coinCollectPool[index];
        require(_address == address(0),"PrivatePlacement : address error");
        coinCollectPoolState[_address] = state;
    }

    function updNodeCollectPoolState(uint index,bool state) external onlyOwner {
        require(index > 0 && index <= _nodeIds.current(),"PrivatePlacement : index error");
        address _address = nodeCollectPool[index];
        require(_address == address(0),"PrivatePlacement : address error");
        nodeCollectPoolState[_address] = state;
    }

    function dataImport(address[] memory _addressArray,address[] memory _inviteeArray,uint[] memory _maxAmountArray) external onlyOwner {
        require(_addressArray.length == _inviteeArray.length,"PrivatePlacement : Inconsistent length");
        require(_addressArray.length == _maxAmountArray.length,"PrivatePlacement : Inconsistent length");
        for(uint i=0;i<_addressArray.length;i++){
            address _address = _addressArray[i];
            invitationMapping[_address] = _inviteeArray[i];                                //绑定邀请人
            shareMaxMapping[_address] += _maxAmountArray[i];                               //消费限额
        }
    }

    function setNode(address[] memory _addressArray,bool[] memory _isObtainTokenArray) external onlyOwner {
        require(_addressArray.length == _isObtainTokenArray.length,"PrivatePlacement : Inconsistent length");
        for(uint i=0;i<_addressArray.length;i++){
            address _address = _addressArray[i];
            if(_isObtainTokenArray[i] == true){
              nodeMapping[_address] = true;                                                //成为节点人
            } else {
              nodeMapping[_address] = false;                                               //撤销节点人
            }
        }
    }

    function outTokenBuy(address outAddress,uint amountToWei) public onlyOwner{
        buyToken.transfer(outAddress,amountToWei);
    }

    function outTokenSell(address outAddress,uint amountToWei) public onlyOwner{
        sellToken.transfer(outAddress,amountToWei);
    }

    /*
     * @dev 增加 | 所有人 | 绑定推荐关系
     * @param _address 需要绑定的合约地址
     */
    function bindInvitation(address _address) public nonReentrant returns (bool){
        //1.判断自己是否已经绑定过推荐人 | 兼容防重入
        if(invitationMapping[msg.sender] != address(0)){ _status = _NOT_ENTERED;revert("PrivatePlacement : The recommender has been bound. There is no need to bind again");}
        //2.判断邀请人是否为空 | 兼容防重入
        if(_address == address(0)){ _status = _NOT_ENTERED;revert("PrivatePlacement : Recommender cannot be 0 address");}
        //3.判断邀请人是否为本合约地址 | 兼容防重入
        if(_address == address(this)){ _status = _NOT_ENTERED;revert("PrivatePlacement : The invitation address cannot be the address of this contract");}
        //4.判断邀请人是否为本系统地址 | 兼容防重入
        if(invitationMapping[_address] == address(0)){ _status = _NOT_ENTERED;revert("PrivatePlacement : The invitee does not exist in this system");}
        invitationMapping[msg.sender] = _address;
        return true;
    }

    /*
     * @dev 修改 | 所有人 | 购买代币
     * @param amountToWei 购买金额
     */
    function buyCoin(uint256 amountToWei) public isRunning nonReentrant returns (bool){
        //1.判断交易金额是否是0 | 兼容防重入
        if(amountToWei == 0){ _status = _NOT_ENTERED;revert("PrivatePlacement : Transaction amountToWei must be greater than 0");}
        //2.判断限额是否达标 | 兼容防重入
        if(amountToWei < privatePlacementQuota){ _status = _NOT_ENTERED;revert("PrivatePlacement : The purchase amount is lower than the minimum");}
        //3.判断当前购买人是否填写邀请人 | 兼容防重入
        if(invitationMapping[msg.sender] == address(0)){ _status = _NOT_ENTERED; revert("PrivatePlacement : Please fill in the invitation form first"); }

        //获取当期私募信息
        uint[9] memory info = privatePlacementInfo[privatePlacementIndex];
        //4.判断当期私募信息是否存在 | 兼容防重入
        if(info[8] == 0){ _status = _NOT_ENTERED; revert("PrivatePlacement : Private placement information does not exist"); }
        //5.判断当期私募是否开启 | 兼容防重入
        if(info[8] >= 2){ _status = _NOT_ENTERED; revert("PrivatePlacement : Current private placement has not been opened yet, please wait"); }
        //根据当期私募单价,计算当前价格可购买的数量
        uint sellAmount = Util.toWei(amountToWei,18).div(info[0]);
        //6.判断当期私募数量是否超出 | 兼容防重入
        if(info[1]-info[2] < sellAmount){ _status = _NOT_ENTERED; revert("PrivatePlacement : Private placement is insufficient, and the purchase amount exceeds the remaining amount"); }
        
        buyToken.transferFrom(msg.sender, address(this), amountToWei);
        sellToken.transfer(msg.sender,sellAmount);
        
        shareMaxMapping[msg.sender] += amountToWei;//累计交易总额
        privatePlacementInfo[privatePlacementIndex][2] = privatePlacementInfo[privatePlacementIndex][2].add(sellAmount); //成交量增加
        privatePlacementInfo[privatePlacementIndex][3] = privatePlacementInfo[privatePlacementIndex][3].add(amountToWei);//成交额增加
        privatePlacementInfo[privatePlacementIndex][4] = privatePlacementInfo[privatePlacementIndex][4].add(1);          //成交笔增加
        
        //触发奖励机制
        uint nodeShareSumAmount = buyNodeShare(amountToWei);
        pushAmount(amountToWei,nodeShareSumAmount,1);
        isUpPrice();
        return true;
    }

    /*
     * @dev 修改 | 本地调用 | 节点奖励分润(无限代10%,截止到 < 1U)
     * @param amountToWei 购买金额
     */
    function buyNodeShare(uint256 amountToWei) private returns (uint sumAmount){
        uint shareAmount = amountToWei.mul(nodeReleaseScale).div(1000);            // 初始收益金额
        address thisAddress = msg.sender;                        // 初始收益人
        for(uint i=0;i<10000000;i++){                            // 给一个伪极大值,这里足够了
            address invitationAddress = invitationMapping[thisAddress];
            if(invitationAddress != address(0) && shareAmount >= 1000000000000000000){
                if(nodeMapping[invitationAddress] == true){      //当前地址是不是节点
                    uint maxNumber = shareMaxMapping[invitationAddress];
                    if(maxNumber >= shareAmount){                //判断用户的单笔交易奖励限额
                        buyToken.transfer(invitationAddress, shareAmount);
                        sumAmount += shareAmount;
                    } else 
                    if(maxNumber != 0){
                        buyToken.transfer(invitationAddress, maxNumber);
                        sumAmount += maxNumber;
                    }
                    shareAmount = shareAmount.mul(nodeReleaseScale).div(1000);    //重置收益金额
                }
                thisAddress = invitationAddress;                                  //重置收益人
            } else {
                break;
            }
        }
        return sumAmount;
    }

    /*
     * @dev 修改 | 本地调用 | 价格上浮
     * @param amountToWei 购买金额
     */
    function isUpPrice() private returns(bool) {
        uint buyAmount = privatePlacementInfo[privatePlacementIndex][3];    //已经购买额
        uint upCondition = privatePlacementInfo[privatePlacementIndex][5];  //上浮条件
        uint upAmount = privatePlacementInfo[privatePlacementIndex][6];     //上浮金额
        uint upEndAmount = privatePlacementInfo[privatePlacementIndex][7];  //上浮截止到额度
        uint upAmountDifference = buyAmount.sub(upEndAmount);               //上浮额差值
        if(upAmountDifference >= upCondition){ //上浮差大于上浮条件
            uint upNumber = upAmountDifference.div(upCondition); //上浮多少个单位
            privatePlacementInfo[privatePlacementIndex][0] = privatePlacementInfo[privatePlacementIndex][0].add(upAmount.mul(upNumber));    //价格上浮
            privatePlacementInfo[privatePlacementIndex][7] = privatePlacementInfo[privatePlacementIndex][7].add(upCondition.mul(upNumber)); //更新上浮截止额度
        }
        return true;
    }

    function pushAmount(uint sumAmount,uint nodeAmount,uint pushType) private returns (bool){
        uint amount7 = sumAmount.mul(70).div(1000);
        uint balanceAmount = sumAmount.sub(nodeAmount).sub(amount7);
        if(pushType == 1){
            address address7 = coinCollectPool[1];
            if(address7 != address(0) && coinCollectPoolState[address7] == true){
                buyToken.transfer(address7, amount7);
            }
            coinCollectPoolIndex++;
            if(coinCollectPoolIndex > _coinIds.current()){
                coinCollectPoolIndex = 2;
            }
            address addressBalance = coinCollectPool[coinCollectPoolIndex];
            if(addressBalance != address(0) && coinCollectPoolState[addressBalance] == true){
                buyToken.transfer(addressBalance, balanceAmount);
            }
        } else {
            address address7 = nodeCollectPool[1];
            if(address7 != address(0) && nodeCollectPoolState[address7] == true){
                buyToken.transfer(address7, amount7);
            }
            nodeCollectPoolIndex++;
            if(nodeCollectPoolIndex > _nodeIds.current()){
                nodeCollectPoolIndex = 2;
            }
            address addressBalance = nodeCollectPool[nodeCollectPoolIndex];
            if(addressBalance != address(0) && nodeCollectPoolState[addressBalance] == true){
                buyToken.transfer(addressBalance, balanceAmount);
            }
        }
        return true;
    }

    
    /*
     * @dev 查询 | 所有人调用 | 指定活动信息
     */
    function getPrivatePlacementInfo(uint index) public view returns(uint[9] memory privatePlacement){
        privatePlacement = privatePlacementInfo[index];
        return privatePlacement;
    }

    
    /*
     * @dev 查询 | 所有人调用 | 查看邀请关系
     */
    function getInvitationInfo(address _address) public view returns(address invitee){
        invitee = invitationMapping[_address];
        return invitee;
    }

    /*
     * @dev 查询 | 所有人调用 | 查看节点身份
     */
    function getNodeInfo(address _address) public view returns(bool isNode){
        isNode = nodeMapping[_address];
        return isNode;
    }

    /*
     * @dev 查询 | 所有人调用 | 查看累计交易总额(即单笔交易限额)
     */
    function getShareMaxQuota(address _address) public view returns(uint amount){
        amount = shareMaxMapping[_address];
        return amount;
    }

}