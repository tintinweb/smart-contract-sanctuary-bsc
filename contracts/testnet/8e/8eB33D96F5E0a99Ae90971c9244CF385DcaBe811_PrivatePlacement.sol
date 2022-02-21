/**
 *Submitted for verification at BscScan.com on 2022-02-20
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

    /*
     * @dev 回退位
     * @param price 价格
     * @param decimals 代币的精度
     */
    function backWei(uint256 price, uint decimals) public pure returns (uint256){
        uint256 amount = price / (10 ** uint256(decimals));
        return amount;
    }

    /*
     * @dev 浮点类型除法 a/b
     * @param a 被除数
     * @param b 除数
     * @param decimals 精度
     */
    function mathDivisionToFloat(uint256 a, uint256 b,uint decimals) public pure returns (uint256){
        uint256 aPlus = a * (10 ** uint256(decimals));
        uint256 amount = aPlus/b;
        return amount;
    }
}

contract PrivatePlacement is Modifier,Util {
    using SafeMath for uint;
    mapping(address => address) private invitationMapping;    //邀请关系Mapping
    mapping(address => bool) private nodeMapping;             //节点身份Mapping
    mapping(address => uint) private nodeWaitTokenMapping;    //节点待释放token信息Mapping
    mapping(address => uint) private nodeSuccessTokenMapping; //节点已释放token信息Mapping
    mapping(address => uint) private nodeExtractMapping;      //节点释放已提取金额Mapping
    mapping(address => uint) private shareMaxMapping;         //单笔奖励限额Mapping
    ERC20 private buyToken;                                   //购买代币信息
    ERC20 private sellToken;                                  //出售代币信息
    /* 每期私募信息:
     * 00 = 单价;    01 = 计划交易总量;  02 = 已成交量; 03 = 已经成交笔数;  04 = 是否开启(1:开启,2:关闭);
     */
    uint[5][3] private privatePlacementInfo;
    uint private privatePlacementIndex;                    //当前私募期号
    uint private privatePlacementQuota;                    //私募最低限额
    uint private nodePrice;                                //节点人价格
    uint private nodeTokenNumber;                          //节点获得的锁仓代币数量


    constructor() {
         invitationMapping[0xd044694D74dE6353043f3414F5fbeBC604F1fd91] = address(this);
         shareMaxMapping[0xd044694D74dE6353043f3414F5fbeBC604F1fd91] = 115792089237316195423570985008687907853269984665640564039457584007913129639935;
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
     * @dev 设置 | 创建者调用 | 设置私募信息
     * @param index 需要设置的私募期号
     * @param price 单价
     * @param total 计划总量
     * @param turnover 已成交量
     * @param number 已经成交笔数
     * @param isSell 是否开始 (0关闭,1开始)
     */
    function setPrivatePlacementInfo(uint index,uint price,uint total,uint turnover,uint number,uint isSell) public onlyOwner{
        uint[5] memory info = [price,total,turnover,number,isSell];
        privatePlacementInfo[index] = info;
    }

    /*
     * @dev 设置 | 创建者调用 | 设置配置信息
     * @param _privatePlacementIndex  当前私募期号
     * @param _nodePrice              节点人价格
     * @param _nodeTokenNumber        节点获得的锁仓代币数量
     * @param _privatePlacementQuota  私募最低限额
     */
    function setConfigure(uint _privatePlacementIndex,uint _nodePrice,uint _nodeTokenNumber,uint _privatePlacementQuota) public onlyOwner {
        privatePlacementIndex = _privatePlacementIndex;
        nodePrice = _nodePrice;
        nodeTokenNumber = _nodeTokenNumber;
        privatePlacementQuota = _privatePlacementQuota;
    }

    /*
     * @dev  修改 | 授权者调用 | 取出平台的ABS
     * @param outAddress 取出地址
     * @param amount 交易金额
     */
    function outTokenBuy(address outAddress,uint amountToWei) public onlyOwner{
        buyToken.transfer(outAddress,amountToWei);
    }

    /*
     * @dev  修改 | 授权者调用 | 取出平台的USDT
     * @param outAddress 取出地址
     * @param amount 交易金额
     */
    function outTokenSell(address outAddress,uint amountToWei) public onlyOwner{
        sellToken.transfer(outAddress,amountToWei);
    }

    /*
     * @dev 增加 | 所有人 | 绑定推荐关系
     * @param _address 需要绑定的合约地址
     */
    function bindInvitation(address _address) public isRunning nonReentrant returns (bool){
        //1.判断自己是否已经绑定过推荐人 | 兼容防重入
        if(invitationMapping[msg.sender] != address(0)){ _status = _NOT_ENTERED;revert("PrivatePlacement: The recommender has been bound. There is no need to bind again");}
        //2.判断邀请人是否为空 | 兼容防重入
        if(_address == address(0)){ _status = _NOT_ENTERED;revert("PrivatePlacement: Recommender cannot be 0 address");}
        //3.判断邀请人是否为本合约地址 | 兼容防重入
        if(_address == address(this)){ _status = _NOT_ENTERED;revert("PrivatePlacement: The invitation address cannot be the address of this contract");}
        //4.判断邀请人是否为本系统地址 | 兼容防重入
        if(invitationMapping[_address] == address(0)){ _status = _NOT_ENTERED;revert("PrivatePlacement: The invitee does not exist in this system");}
        invitationMapping[msg.sender] = _address;
        return true;
    }

    /*
     * @dev 修改 | 所有人 | 购买代币
     * @param amountToWei 购买金额
     */
    function buyCoin(uint256 amountToWei) public isRunning nonReentrant returns (bool){
        //1.判断交易金额是否是0 | 兼容防重入
        if(amountToWei == 0){ _status = _NOT_ENTERED;revert("PrivatePlacement: Transaction amountToWei must be greater than 0");}
        //1.判断限额是否达标 | 兼容防重入
        if(amountToWei < privatePlacementQuota){ _status = _NOT_ENTERED;revert("PrivatePlacement: The purchase amount is lower than the minimum");}
        //2.判断当前购买人是否填写邀请人 | 兼容防重入
        if(invitationMapping[msg.sender] == address(0)){ _status = _NOT_ENTERED; revert("PrivatePlacement: Please fill in the invitation form first"); }

        //获取当期私募信息
        uint[5] memory info = privatePlacementInfo[privatePlacementIndex];
        //3.判断当期私募信息是否存在 | 兼容防重入
        if(info[4] == 0){ _status = _NOT_ENTERED; revert("PrivatePlacement: Private placement information does not exist"); }
        //4.判断当期私募是否开启 | 兼容防重入
        if(info[4] >= 2){ _status = _NOT_ENTERED; revert("PrivatePlacement: Current private placement has not been opened yet, please wait"); }
        //根据当期私募单价,计算当前价格可购买的数量
        uint sellAmount = Util.toWei(amountToWei,18).div(info[0]);
        //5.判断当期私募数量是否超出 | 兼容防重入
        if(info[1]-info[2] < sellAmount){ _status = _NOT_ENTERED; revert("PrivatePlacement: Private placement is insufficient, and the purchase amount exceeds the remaining amount"); }
        
        buyToken.transferFrom(msg.sender, address(this), amountToWei);
        sellToken.transfer(msg.sender,sellAmount);
        
        if(shareMaxMapping[msg.sender] < amountToWei){
            shareMaxMapping[msg.sender] = amountToWei;//重置单笔奖励限额
        }
        privatePlacementInfo[privatePlacementIndex][2] = privatePlacementInfo[privatePlacementIndex][2].add(sellAmount);//成交数量增加
        privatePlacementInfo[privatePlacementIndex][3] = privatePlacementInfo[privatePlacementIndex][3] + 1;            //成交笔数增加
        
        //触发奖励机制
        buyInvitationShare(amountToWei,5,50);
        buyNodeShare(amountToWei,100);
        return true;
    }

    /*
     * @dev 修改 | 所有人 | 购买节点人
     */
    function buyNode() public isRunning nonReentrant returns (bool){
        //1.判断当前购买人是否填写邀请人 | 兼容防重入
        if(invitationMapping[msg.sender] == address(0)){ _status = _NOT_ENTERED; revert("PrivatePlacement: Please fill in the invitation form first"); }
        //2.判断当前购买人是否已经是节点人 | 兼容防重入
        if(nodeMapping[msg.sender] == true){ _status = _NOT_ENTERED; revert("PrivatePlacement: You are already a node person, so you don't need to buy again"); }
        
        buyToken.transferFrom(msg.sender, address(this), nodePrice);
        nodeMapping[msg.sender] = true;
        nodeWaitTokenMapping[msg.sender] = nodeTokenNumber;  //初始化锁仓待释放总额
        nodeSuccessTokenMapping[msg.sender] = 0;             //初始化锁仓已释放总额
        if(shareMaxMapping[msg.sender] < nodePrice){
            shareMaxMapping[msg.sender] = nodePrice;         //重置单笔奖励限额
        }

        //触发奖励机制
        buyInvitationShare(nodePrice,5,50);
        buyNodeShare(nodePrice,100);
        return true;
    }

    /*
     * @dev 修改 | 本地调用 | 推荐奖励分润
     * @param amountToWei 购买金额
     * @param limit 分润代数
     * @param scale 分润比例 (必须是千分数格式整数:例:10,则代表千分之10)
     */
    function buyInvitationShare(uint256 amountToWei,uint limit,uint scale) private returns (bool){
        if(scale == 0){ _status = _NOT_ENTERED;revert("PrivatePlacement: Transaction proportion must be greater than 0%");}
        if(scale > 1000){ _status = _NOT_ENTERED;revert("PrivatePlacement: Transaction proportion must be less than 1000");}
        uint temporaryAmount = amountToWei.mul(scale);
        uint shareAmount = temporaryAmount.div(1000);
        address thisAddress = msg.sender;
        for(uint i=0;i<limit;i++){
            address invitationAddress = invitationMapping[thisAddress];
            if(invitationAddress != address(0)){
                uint maxNumber = shareMaxMapping[invitationAddress];
                if(maxNumber >= shareAmount){//判断用户的单笔交易奖励限额
                    buyToken.transfer(invitationAddress, shareAmount);
                } else 
                if(maxNumber != 0){
                    buyToken.transfer(invitationAddress, maxNumber);
                }
                thisAddress = invitationAddress;
            } else {
                break;
            }
        }
        return true;
    }

    /*
     * @dev 修改 | 本地调用 | 节点奖励分润(无限代10%,截止到 < 1U)
     * @param amountToWei 购买金额
     * @param scale 分润比例 (必须是千分数格式整数:例:10,则代表千分之10)
     */
    function buyNodeShare(uint256 amountToWei,uint scale) private returns (bool){
        if(scale == 0){ _status = _NOT_ENTERED;revert("PrivatePlacement: Transaction proportion must be greater than 0%");}
        if(scale > 1000){ _status = _NOT_ENTERED;revert("PrivatePlacement: Transaction proportion must be less than 1000");}
        uint temporaryAmount = amountToWei.mul(scale);
        uint shareAmount = temporaryAmount.div(1000);            //初始收益金额
        address thisAddress = msg.sender;                        //初始收益人
        for(uint i=0;i<10000000;i++){                            // 给一个伪极大值,这里足够了
            address invitationAddress = invitationMapping[thisAddress];
            if(invitationAddress != address(0) && shareAmount >= 1000000000000000000){
                if(nodeMapping[invitationAddress] == true){      //当前地址是不是节点
                    uint maxNumber = shareMaxMapping[invitationAddress];
                    if(maxNumber >= shareAmount){                //判断用户的单笔交易奖励限额
                        buyToken.transfer(invitationAddress, shareAmount);
                    } else 
                    if(maxNumber != 0){
                        buyToken.transfer(invitationAddress, maxNumber);
                    }
                }
                thisAddress = invitationAddress;                 //重置收益人
                temporaryAmount = shareAmount.mul(scale);
                shareAmount = temporaryAmount.div(1000);        //重置收益金额
            } else {
                break;
            }
        }
        return true;
    }


    /*
     * @dev 修改 | 本地调用 | 查看节点释放Token数量
     * @param scale 释放比例 (必须是千分数格式整数:例:10,则代表千分之10)
     */
    function queryNodeReleaseToken(uint scale) public nonReentrant returns (uint sumReleaseAmount,uint balanceAmount){
        uint sumNumber = 0;                                                              //总私募次数
        for(uint i=0;i<privatePlacementInfo.length;i++){
            sumNumber += privatePlacementInfo[i][3];
        }
        uint releaseNumber = sumNumber.div(1000);                                        //应释放次数
        sumReleaseAmount = nodeTokenNumber.mul(scale).div(1000).mul(releaseNumber);      //总释放金额
        balanceAmount = sumReleaseAmount.sub(nodeExtractMapping[msg.sender]);            //待提取余额
        return (sumReleaseAmount,balanceAmount);
    }

    
    /*
     * @dev 查询 | 所有人调用 | 指定活动信息
     */
    function getPrivatePlacementInfo(uint index) public view returns(uint[5] memory privatePlacement){
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


}