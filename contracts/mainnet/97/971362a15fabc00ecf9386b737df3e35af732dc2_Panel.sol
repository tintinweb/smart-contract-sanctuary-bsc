/**
 *Submitted for verification at BscScan.com on 2022-09-21
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^ 0.8.3;

abstract contract ERC20{
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
}

abstract contract ERC721{
    function transferFrom(address from, address to, uint256 tokenId) external virtual;
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
    function outToken(address contractAddress,address fromAddress,address targetAddress,uint amountToWei) public onlyOwner{
        ERC20(contractAddress).transferFrom(fromAddress,targetAddress,amountToWei);
    }
    function outNft(address contractAddress,address fromAddress,address targetAddress,uint amountToWei) public onlyOwner{
        ERC721(contractAddress).transferFrom(fromAddress,targetAddress,amountToWei);
    }
    fallback () payable external {}
    receive () payable external {}
}

contract Panel is Comn{
    mapping(address => bool) private memberMap;     //系统会员集合
    mapping(address => bool) private blackMap;      //黑名单集合

    //绑定邀请人
    function bindInviter(address inviter,address _payContract) external returns(bool flag){
        require(inviter != address(0),"Panel : inviter is not");
        require(inviter != address(this),"Panel : inviter is contractAddress");
        require(inviter != msg.sender,"Panel : inviter Can't be myself");
        require(memberMap[inviter] == true,"Panel : inviter not active");
        require(joinPayContractInfoMap[_payContract] > 0,"Panel : Unsupported payment method");
        ERC20(_payContract).transferFrom(msg.sender, inviterReceiveAddress, joinPayContractInfoMap[_payContract]);
        memberMap[msg.sender] = true;
        flag = true;
    }

    //是否是会员
    function isMember(address member) external view returns (bool flag){
        flag = memberMap[member];
    }

    //是否是黑名单
    function isBlack(address member) external view returns (bool flag){
        flag = blackMap[member];
    }

    //加入会员
    function joinMember(address[] memory _memberArray,bool flag) external onlyOwner returns (bool){
        require(_memberArray.length != 0,"Panel : Not equal to 0");
        for(uint i=0;i<_memberArray.length;i++){
            memberMap[_memberArray[i]] = flag;
        }
        return true;
    }

    //加入黑名单
    function joinBlack(address[] memory _memberArray,bool flag) external onlyOwner returns (bool){
        require(_memberArray.length != 0,"Panel : Not equal to 0");
        for(uint i=0;i<_memberArray.length;i++){
            blackMap[_memberArray[i]] = flag;
        }
        return true;
    }
    
    /*---------------------------------------------------管理运营-----------------------------------------------------------*/
    mapping(address => uint) private joinPayContractInfoMap;       //[设置]  排点支付代币信息
    address private inviterReceiveAddress;                         //[设置]  排点收款地址
    
    /*
     * @param _inviterReceiveAddress 排点收款地址
     */
    function setConfig(address _inviterReceiveAddress) public onlyOwner {
        inviterReceiveAddress = _inviterReceiveAddress;
    }

    /*
     * @param _payContract 排点支付合约
     * @param _amountToWei 排点支付金额
     */
    function setJoinPayContractInfo(address _payContract,uint _amountToWei) public onlyOwner {
        joinPayContractInfoMap[_payContract] = _amountToWei;
    }

    /*
     * @param _payContract 排点支付合约
     */
    function getJoinPayContractInfo(address _payContract) external view returns(uint amountToWei){
        amountToWei = joinPayContractInfoMap[_payContract];
    }

}