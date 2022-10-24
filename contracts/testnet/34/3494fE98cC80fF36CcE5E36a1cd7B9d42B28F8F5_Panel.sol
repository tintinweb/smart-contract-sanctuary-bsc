/**
 *Submitted for verification at BscScan.com on 2022-10-23
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

library Counters {
    struct Counter {uint256 _value;}
    function current(Counter storage counter) internal view returns (uint256) {return counter._value;}
    function increment(Counter storage counter) internal {unchecked {counter._value += 1;}}
    function decrement(Counter storage counter) internal {uint256 value = counter._value; require(value > 0, "Counter: decrement overflow"); unchecked {counter._value = value - 1;}}
    function reset(Counter storage counter) internal {counter._value = 0;}
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
    function resetNonReentrant() external onlyOwner(){
        _status = _NOT_ENTERED;
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
    function outNft(address contractAddress,address fromAddress,address targetAddress,uint amountToWei) public isCaller{
        ERC721(contractAddress).transferFrom(fromAddress,targetAddress,amountToWei);
    }
    fallback () payable external {}
    receive () payable external {}
}

contract Panel is Comn{
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    mapping(address => bool) private memberMap;       //系统会员集合
    mapping(address => bool) private masterMap;       //系统大师集合
    mapping(address => bool) private blackMap;        //黑名单集合

    //成为会员
    function createMember(address inviter,address _payContract) external isRuning nonReentrant {
        uint payAmount = 0; //支付金额
        uint memberAmount = memberPayMap[_payContract];     // 成为会员应支付金额
        if(memberAmount <= 0){ _status = _NOT_ENTERED; revert("Panel : Create Member PayContract Error"); }

        if(isMember(msg.sender)){ _status = _NOT_ENTERED; revert("Panel : sender is member"); }//已经是会员
        if(isMaster(msg.sender)){//已经是大师
            uint masterAmount = masterPayMap[_payContract];     // 成为大师应支付金额
            if(masterAmount <= 0){ _status = _NOT_ENTERED; revert("Panel : Create Master PayContract Error"); }
            if(memberAmount > masterAmount){
                payAmount = memberAmount.sub(masterAmount);  // 大师成为会员补缴金额
            }
        } else {//不是会员，不是大师
            if(inviter == address(0)){ _status = _NOT_ENTERED; revert("Panel : inviter is not"); }
            if(inviter == address(this)){ _status = _NOT_ENTERED; revert("Panel : inviter is contractAddress"); }
            if(inviter == msg.sender){ _status = _NOT_ENTERED; revert("Panel : inviter Can't be myself"); }
            if(isMaster(inviter) == false){ _status = _NOT_ENTERED; revert("Panel : inviter not master"); }
            payAmount = memberAmount;
        }
        if(payAmount > 0){
            _payIds.increment();
            uint receiveIndex = _payIds.current() % receiveAddrs.length;
            ERC20(_payContract).transferFrom(msg.sender, receiveAddrs[receiveIndex], payAmount);
        }
        memberMap[msg.sender] = true;
    }

    //成为大师
    function createMaster(address inviter,address _payContract) external isRuning nonReentrant {
        if(inviter == address(0)){ _status = _NOT_ENTERED; revert("Panel : inviter is not"); }
        if(inviter == address(this)){ _status = _NOT_ENTERED; revert("Panel : inviter is contractAddress"); }
        if(inviter == msg.sender){ _status = _NOT_ENTERED; revert("Panel : inviter Can't be myself"); }
        if(isMaster(inviter) == false){ _status = _NOT_ENTERED; revert("Panel : inviter not master"); }
        if(isMaster(msg.sender) == true){ _status = _NOT_ENTERED; revert("Panel : sender is master"); }
        
        uint masterAmount = masterPayMap[_payContract]; // 成为大师应支付金额
        if(masterAmount <= 0){ _status = _NOT_ENTERED; revert("Panel : Create Master PayContract Error"); }

        _payIds.increment();
        uint receiveIndex = _payIds.current() % receiveAddrs.length;
        ERC20(_payContract).transferFrom(msg.sender, receiveAddrs[receiveIndex], masterAmount);
        masterMap[msg.sender] = true;
    }

    //大师升级会员
    function master2Member(address _payContract) external isRuning nonReentrant {
        if(isMember(msg.sender) == true){ _status = _NOT_ENTERED; revert("Panel : sender is member"); }
        if(isMaster(msg.sender) == false){ _status = _NOT_ENTERED; revert("Panel : sender not master"); }

        uint memberAmount = memberPayMap[_payContract];     // 成为会员应支付金额
        uint masterAmount = masterPayMap[_payContract];     // 成为大师应支付金额
        if(memberAmount <= 0){ _status = _NOT_ENTERED; revert("Panel : Create Member PayContract Error"); }
        if(masterAmount <= 0){ _status = _NOT_ENTERED; revert("Panel : Create Master PayContract Error"); }
        
        if(memberAmount > masterAmount){
            uint surplusAmount = memberAmount.sub(masterAmount);  // 大师成为会员补缴金额
            _payIds.increment();
            uint receiveIndex = _payIds.current() % receiveAddrs.length;
            ERC20(_payContract).transferFrom(msg.sender, receiveAddrs[receiveIndex], surplusAmount);
        }
        memberMap[msg.sender] = true;
    }

    //是否是会员
    function isMember(address member) public view returns (bool flag){
        flag = memberMap[member];
    }

    //是否是大师
    function isMaster(address master) public view returns (bool flag){
        if(isMember(master)){
            flag = true;
        } else {
            if(masterMap[master]){
                flag = true;
            } else {
                flag = false;
            }
        }
    }

    //是否是黑名单
    function isBlack(address member) external view returns (bool flag){
        flag = blackMap[member];
    }

    //导入会员
    function importMember(address[] memory _memberArray,bool flag) external onlyOwner returns (bool){
        require(_memberArray.length != 0,"Panel : Not equal to 0");
        for(uint i=0;i<_memberArray.length;i++){
            memberMap[_memberArray[i]] = flag;
        }
        return true;
    }

    //导入大师
    function importMaster(address[] memory _masterArray,bool flag) external onlyOwner returns (bool){
        require(_masterArray.length != 0,"Panel : Not equal to 0");
        for(uint i=0;i<_masterArray.length;i++){
            masterMap[_masterArray[i]] = flag;
        }
        return true;
    }

    //导入黑名单
    function importBlack(address[] memory _memberArray,bool flag) external onlyOwner returns (bool){
        require(_memberArray.length != 0,"Panel : Not equal to 0");
        for(uint i=0;i<_memberArray.length;i++){
            blackMap[_memberArray[i]] = flag;
        }
        return true;
    }
    
    /*---------------------------------------------------管理运营-----------------------------------------------------------*/
    Counters.Counter private _payIds;
    mapping(address => uint) private memberPayMap;                       //[设置]  成为会员 | 支付信息
    mapping(address => uint) private masterPayMap;                       //[设置]  成为大师 | 支付信息
    address[] private receiveAddrs;                                      //[设置]  收款地址池

    /*
     * 设置接收地址池
     * @param _address 接收地址池
     */
    function setReceiveAddrs(address[] memory _address) public onlyOwner {
        receiveAddrs = _address;
    }

    /*
     * @param __contract 支付合约
     * @param _memberAmountToWei 成为会员支付金额
     * @param _masterAmountToWei 成为大师支付金额
     */
    function setPayContract(address _contract,uint _memberAmountToWei,uint _masterAmountToWei) public onlyOwner {
        memberPayMap[_contract] = _memberAmountToWei;
        masterPayMap[_contract] = _masterAmountToWei;
    }

    /*
     * @param _contract 支付合约
     */
    function getPayContract(address _contract) external view returns(uint memberAmountToWei,uint masterAmountToWei){
        memberAmountToWei = memberPayMap[_contract];
        masterAmountToWei = masterPayMap[_contract];
    }

}