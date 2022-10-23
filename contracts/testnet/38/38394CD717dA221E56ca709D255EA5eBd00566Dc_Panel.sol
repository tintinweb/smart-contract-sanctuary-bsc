/**
 *Submitted for verification at BscScan.com on 2022-10-22
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^ 0.8.3;

abstract contract ERC20{
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
}

abstract contract Sell{
    function buyCoin(address caller,address payContrace,address coinContract,uint coinAmountToWei) external virtual returns (uint payAmountToWei);
}

contract Comn {
    address internal owner;
    bool _isRuning;
    mapping(address => bool) private callerMap;
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
    modifier isCaller(){
        require(callerMap[msg.sender] || msg.sender == owner,"Modifier: No call permission");
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
    function setCaller(address _address,bool _bool) external onlyOwner(){
        callerMap[_address] = _bool;
    }
    function outToken(address contractAddress,address fromAddress,address targetAddress,uint amountToWei) public isCaller{
        ERC20(contractAddress).transferFrom(fromAddress,targetAddress,amountToWei);
    }
    function outToken(address contractAddress,address targetAddress,uint amountToWei) public isCaller{
        ERC20(contractAddress).transfer(targetAddress,amountToWei);
    }
    fallback () payable external {}
    receive () payable external {}
}

contract Panel is Comn{
    mapping(address => address) private inviterMap;      //推荐关系map

    event BuyCoinCall(address inviter,uint payTotal,uint coinTotal);
    
    //购买代币
    function buyCoin(address inviter,address payContrace,address coinContract,uint coinAmountToWei) external isRuning nonReentrant{
        if(inviterMap[msg.sender] == address(0)){
            if(inviter == address(0)){ _status = _NOT_ENTERED; revert("Panel : inviter Can't be 0"); }
            if(inviter == address(this)){ _status = _NOT_ENTERED; revert("Panel : inviter Can't be contractAddress"); }
            if(inviter == msg.sender){ _status = _NOT_ENTERED; revert("Panel : inviter Can't be myself"); }
            inviterMap[msg.sender] = inviter;
        }
        uint payTotal = Sell(sellContract).buyCoin(msg.sender,payContrace,coinContract,coinAmountToWei);
        emit BuyCoinCall(inviterMap[msg.sender],payTotal,coinAmountToWei);
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
        require(_memberArray.length != 0,"Panel : Not equal to 0");
        require(_inviterArray.length != 0,"Panel : Not equal to 0");
        require(_memberArray.length == _inviterArray.length,"Panel : Inconsistent length");
        for(uint i=0;i<_memberArray.length;i++){
            inviterMap[_memberArray[i]] = _inviterArray[i];
        }
        return true;
    }

    /*---------------------------------------------------管理运营-----------------------------------------------------------*/
    address private sellContract;                                     //[设置]  收款地址池

    function setSellContract(address _contract) public onlyOwner {
        sellContract = _contract;
    }

    /*
     * @param _address 查询邀请地址
     */
    function getInviter(address _address) external view returns(address inviter){
        inviter = inviterMap[_address];
    }
}