/**
 *Submitted for verification at BscScan.com on 2022-09-03
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
    mapping(address => bool) private memberMap;          //系统会员map

    modifier isBoxMember(){
        require(!openBoxMember || memberMap[msg.sender],"Modifier : not active");
        _;
    }
    modifier isComposeMember(){
        require(!composeMember || memberMap[msg.sender],"Modifier : not active");
        _;
    }

    //绑定邀请人
    function bindInviter(address inviter) external returns(bool flag){
        require(inviter != address(0),"Box : inviter is not");
        require(inviter != address(this),"Box : inviter is contractAddress");
        require(inviter != msg.sender,"Box : inviter Can't be myself");
        require(memberMap[inviter] == true,"Box : inviter not active");
        memberMap[msg.sender] = true;
        return true;
    }

    //开盲盒
    function openBox(address _payContract) external isRuning isBoxMember{
        require(payContractInfoMap[_payContract] > 0,"Box : Unsupported payment method");
        ERC20(_payContract).transferFrom(msg.sender, receiveAddress, payContractInfoMap[_payContract]);
        Box(boxContract).openBox(msg.sender);
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
    function isMember(address member) external view returns (bool flag){
        flag = memberMap[member];
    }

    //激活会员
    function activationMember(address[] memory _memberArray) external onlyOwner returns (bool){
        require(_memberArray.length != 0,"Box : Not equal to 0");
        for(uint i=0;i<_memberArray.length;i++){
            memberMap[_memberArray[i]] = true;
        }
        return true;
    }
    /*---------------------------------------------------管理运营-----------------------------------------------------------*/
    mapping(address => uint) private payContractInfoMap;           //[设置]  支付代币信息
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
     */
    function setPayContractInfo(address _payContract,uint _amountToWei) public onlyOwner {
        payContractInfoMap[_payContract] = _amountToWei;
    }

    /*
     * @param _payContract 支付合约
     */
    function getPayContractInfo(address _payContract) external view returns(uint amountToWei){
        amountToWei = payContractInfoMap[_payContract];
    }
}