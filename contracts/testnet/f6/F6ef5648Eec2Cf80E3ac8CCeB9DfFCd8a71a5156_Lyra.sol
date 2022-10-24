/**
 *Submitted for verification at BscScan.com on 2022-10-23
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^ 0.8.3;

abstract contract ERC20{
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
}

abstract contract Box{
    function openBox(address creator) external virtual;
    function composeTwo(address creator,uint toKenId1,uint toKenId2) external virtual;
    function composeThree1(address creator,uint toKenIdOne,uint toKenIdTwo) external virtual;
    function composeThree2(address creator,uint toKenId1,uint toKenId2,uint toKenId3) external virtual;
    function composeFour1(address creator,uint toKenId1,uint toKenId2) external virtual;
    function composeFour2(address creator,uint toKenId1,uint toKenId2,uint toKenId3,uint toKenId4) external virtual;
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
    function backWei(uint256 a, uint decimals) internal pure returns (uint256){
        if (a == 0) {
            return 0;
        }
        uint256 amount = a / (10 ** uint256(decimals));
        return amount;
    }
}

contract Comn {
    address internal owner;
    bool _isRuning;
    uint256 internal constant _NOT_ENTERED = 1;
    uint256 internal constant _ENTERED = 2;
    uint256 internal _status = 1;
    modifier onlyOwner(){
        require(msg.sender == owner,"Modifier: The caller is not the creator");
        _;
    }
    modifier isRuning(){
        require(_isRuning,"Modifier: Closed");
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
        _isRuning = true;
    }
    function setIsRuning(bool _runing) public onlyOwner {
        _isRuning = _runing;
    }
    function outToken(address contractAddress,address targetAddress,uint amountToWei) public onlyOwner{
        ERC20(contractAddress).transfer(targetAddress,amountToWei);
    }
    fallback () payable external {}
    receive () payable external {}
}

contract Lyra is Comn{
    using SafeMath for uint256;
    mapping(address => address) private inviterMap;      //推荐关系map

    modifier isBoxMember(){
        require(!openBoxMember || inviterMap[msg.sender] != address(0),"Modifier : not active");
        _;
    }
    modifier isComposeMember(){
        require(!composeMember || inviterMap[msg.sender] != address(0),"Modifier : not active");
        _;
    }

    //绑定邀请人
    function bindInviter(address inviter) external returns(bool flag){
        require(inviter != address(0),"Lyra : inviter is not");
        require(inviter != address(this),"Lyra : inviter is contractAddress");
        require(inviter != msg.sender,"Lyra : inviter Can't be myself");
        require(inviterMap[inviter] != address(0),"Lyra : inviter not active");
        require(inviterMap[msg.sender] == address(0),"Lyra : Already a member");
        inviterMap[msg.sender] = inviter;
        return true;
    }

    //开盲盒
    function openBox(address _payContract) external isRuning isBoxMember{
        require(payContractMap[_payContract] > 0,"Lyra : Unsupported payment method");
        require(inviterMap[msg.sender] != address(0),"Lyra : inviter is not");
        
        uint totalAmountToWei = payContractMap[_payContract];
        uint directAmount = openBoxDirectReward(_payContract,totalAmountToWei);
        uint balanceAmount = totalAmountToWei.sub(directAmount);
        
        ERC20(_payContract).transferFrom(msg.sender, receiveAddress,balanceAmount);
        Box(boxContract).openBox(msg.sender);
    }

    //开盲盒 | 直推奖励
    function openBoxDirectReward(address _payContract,uint totalAmountToWei) private returns (uint amount){
        uint molecule = directSaclePairMap[_payContract][0];//分子
        uint denominator = directSaclePairMap[_payContract][1];//分母
        if(molecule > 0 && denominator > 0){
          amount = totalAmountToWei.div(denominator).mul(molecule);
          ERC20(_payContract).transferFrom(msg.sender, inviterMap[msg.sender], amount);
        }
    }
    
    //合成
    function composeTwo(uint toKenId1,uint toKenId2) external isRuning isComposeMember{
        Box(boxContract).composeTwo(msg.sender,toKenId1,toKenId2);
    }
    function composeThree1(uint toKenIdOne,uint toKenIdTwo) external isRuning isComposeMember{
        Box(boxContract).composeThree1(msg.sender,toKenIdOne,toKenIdTwo);
    }
    function composeThree2(uint toKenId1,uint toKenId2,uint toKenId3) external isRuning isComposeMember{
        Box(boxContract).composeThree2(msg.sender,toKenId1,toKenId2,toKenId3);
    }
    function composeFour1(uint toKenId1,uint toKenId2) external isRuning isComposeMember{
        Box(boxContract).composeFour1(msg.sender,toKenId1,toKenId2);
    }
    function composeFour2(uint toKenId1,uint toKenId2,uint toKenId3,uint toKenId4) external isRuning isComposeMember{
        Box(boxContract).composeFour2(msg.sender,toKenId1,toKenId2,toKenId3,toKenId4);
    }

    //是否是会员
    function isMember() external view returns (bool flag){
        if(inviterMap[msg.sender] == address(0)){
            flag = false;
        } else {
            flag = true;
        }
    }

    //导入会员
    function importMember(address[] memory _memberArray,address[] memory _inviterArray) external onlyOwner returns (bool){
        require(_memberArray.length != 0,"Lyra : Not equal to 0");
        require(_inviterArray.length != 0,"Lyra : Not equal to 0");
        require(_memberArray.length == _inviterArray.length,"Lyra : Inconsistent length");
        for(uint i=0;i<_memberArray.length;i++){
            inviterMap[_memberArray[i]] = _inviterArray[i];
        }
        return true;
    }
    
    /*---------------------------------------------------管理运营-----------------------------------------------------------*/
    mapping(address => uint) private payContractMap;               //[设置]  支付代币信息
    mapping(address => uint[]) private directSaclePairMap;         //[设置]  支付代币奖励比例信息 [分子:directSaclePair[0],分母:directSaclePair[1]]
    address private receiveAddress;                                //[设置]  收款地址
    address private boxContract;                                   //[设置]  盲盒合约地址
    bool private openBoxMember;                                    //[设置]  是否开启盲盒会员认证
    bool private composeMember;                                    //[设置]  是否NFT合成会员认证

    /*
     * @param _receiveAddress 收款地址
     * @param _boxContract 盲盒合约
     * @param _openBoxMember 是否开启盲盒会员认证
     * @param _composeMember 是否开启盲盒会员认证
     */
    function setConfig(address _receiveAddress,address _boxContract,bool _openBoxMember,bool _composeMember) public onlyOwner {
        receiveAddress = _receiveAddress;
        boxContract = _boxContract;
        openBoxMember = _openBoxMember;
        composeMember = _composeMember;
    }

    /*
     * @param _payContract 支付合约
     * @param _amountToWei 支付金额
     * @param _directSaclePair 直推奖励率
     */
    function setPayContract(address _payContract,uint _amountToWei,uint[] memory _directSaclePair) public onlyOwner {
        payContractMap[_payContract] = _amountToWei;
        directSaclePairMap[_payContract] = _directSaclePair;
    }


    /*
     * @param _address 查询邀请地址
     */
    function getInviter(address _address) external view returns(address inviter){
        inviter = inviterMap[_address];
    }
}