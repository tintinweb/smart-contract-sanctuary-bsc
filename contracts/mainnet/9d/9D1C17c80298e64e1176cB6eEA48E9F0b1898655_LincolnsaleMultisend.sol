/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-17
*/

// SPDX-License-Identifier: MIT
// BladeMultiSender
// Version 1.0
// testing on bsc testnet.

pragma solidity >=0.8.0 <0.9.0;


interface IERC20 {

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    event Transfer(address indexed from, address indexed to, uint256 amount);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    // function approve(address spender, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

}



library SafeMath {
    function mul(uint a, uint b) internal pure returns(uint) {
        uint c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }
    function div(uint a, uint b) internal pure returns(uint) {
        require(b > 0);
        uint c = a / b;
        require(a == b * c + a % b);
        return c;
    }
    function sub(uint a, uint b) internal pure returns(uint) {
        require(b <= a);
        return a - b;
    }
    function add(uint a, uint b) internal pure returns(uint) {
        uint c = a + b;
        require(c >= a);
        return c;
    }
    function max64(uint64 a, uint64 b) internal pure returns(uint64) {
        return a >= b ? a: b;
    }
    function min64(uint64 a, uint64 b) internal pure returns(uint64) {
        return a < b ? a: b;
    }
    function max256(uint256 a, uint256 b) internal pure returns(uint256) {
        return a >= b ? a: b;
    }
    function min256(uint256 a, uint256 b) internal pure returns(uint256) {
        return a < b ? a: b;
    }
}

contract LincolnsaleMultisend {
    using SafeMath for uint;

    event LogTokenBulkSentETH(address from, uint256 total);
    event LogTokenBulkSent(address token, address from, uint256 total);
    event LogTokenApproval(address token, uint256 total);
    address public _owner;
    uint public _fee = 0.0003 ether;
    address[] public airdropUsers;
    mapping (address => bool) isAdded; // default `false`
    uint totalAirdroppedSent;

    uint starter = 1000000000000000000;
    uint premium = 3000000000000000000;
    uint business = 7000000000000000000;

    event vipAdded(uint subscriberId, address subs, uint sType, uint _amount, uint _currentTime, uint _duration );

    struct VipUsers{
        uint vipId;
        address vipAddress;
        uint subType;
        uint amount;
        bool status;
        uint dateSubscribe;
        uint expDate;
    }

    VipUsers public vipUsers;
    uint public subscriberCount;
    mapping(address => VipUsers) public vipClients;
    

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    constructor() payable{
        _owner = msg.sender;
    }
    receive() external payable { }
    function recoverETHfromContract() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    // Withdraw ERC20 tokens that are potentially stuck
    function recoverTokensFromContract(address _tokenAddress, uint256 _amount) external onlyOwner {                               
        IERC20(_tokenAddress).transfer(msg.sender, _amount);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function getFee() public view returns (uint) {
        return _fee;
    }

    function getSubscriptionFee() public view returns (uint, uint, uint) {
        return (starter, premium, business);
    }

    function totalAirdropAddress() public view returns(uint, uint){
        return (airdropUsers.length, totalAirdroppedSent);
    }

    function getAirdropAddresses() public view returns(address[] memory){
        return airdropUsers;
    }

    function fetchAllVipUser() public view returns(VipUsers memory) {
        return vipUsers;
    }
    
    function checkVipStatus() public view returns(bool){
        if(vipClients[msg.sender].expDate > block.timestamp){
            return true;
        }
        else{
            return false;
        }
    }

    function ethSendSameValue(address[] memory _to, uint256 _value) external payable {
        
        uint256 sendAmount = _to.length.mul(_value);
        uint256 remainingValue = msg.value;
        address from = msg.sender;
        require(msg.sender==owner() || checkVipStatus()==true, "You can't use this servuce");
        require(remainingValue >= sendAmount, 'insuf balance');
        require(_to.length <= 255, 'exceed max allowed');

        for (uint256 i = 0; i < _to.length; i++) {
            require(payable(_to[i]).send(_value), 'failed to send');
            if(!isAdded[_to[i]]){
            airdropUsers.push(_to[i]);
            isAdded[_to[i]] = true;
            }
            totalAirdroppedSent++;
        }

        emit LogTokenBulkSentETH(from, remainingValue);
    }

    function ethSendDifferentValue(address[] memory _to, uint[] memory _value) external payable {
        
        uint sendAmount = _value[0];
        uint remainingValue = msg.value;
        address from = msg.sender;
        require(msg.sender==owner() || checkVipStatus()==true, "You can't use this servuce");
        require(remainingValue >= sendAmount, 'insuf balance');
        require(_to.length == _value.length, 'invalid input');
        require(_to.length <= 255, 'exceed max allowed');    

        for (uint256 i = 0; i < _to.length; i++) {
            require(payable(_to[i]).send(_value[i]));
            if(!isAdded[_to[i]]){
            airdropUsers.push(_to[i]);
            isAdded[_to[i]] = true;
            }
            totalAirdroppedSent++;
        }
        emit LogTokenBulkSentETH(from, remainingValue);
        

    }


    function sendSameValue(address _tokenAddress, address[] memory _to, uint256 _value) external payable{
       
        address from = msg.sender;
        require(_to.length <= 255, 'exceed max allowed');
        uint256 sendAmount = _to.length.mul(_value);

        uint charges = _fee * _to.length;
        require(msg.sender==owner() || charges <= msg.value || checkVipStatus()==true, "You can't use this servuce");
        IERC20 token = IERC20(_tokenAddress);
       // token.approve(address(this), sendAmount);
        
        for (uint256 i = 0; i < _to.length; i++) {
            token.transferFrom(from, _to[i], _value);
            if(!isAdded[_to[i]]){
            airdropUsers.push(_to[i]);
            isAdded[_to[i]] = true;
            }
            totalAirdroppedSent++;
        }
        emit LogTokenBulkSent(_tokenAddress, from, sendAmount);

    }

    function sendDifferentValue(address _tokenAddress, address[] memory _to, uint256[] memory _value) external payable {
        
        address from = msg.sender;
        require(_to.length == _value.length, 'invalid input');
        require(_to.length <= 255, 'exceed max allowed');
        uint charges = _fee * _to.length;
        require(msg.sender==owner() || charges <= msg.value || checkVipStatus()==true, "You can't use this servuce");

        uint256 sendAmount = 0;
        
        IERC20 token = IERC20(_tokenAddress);
      //  token.approve(address(this), sendAmount); //aprove token before sending it

        for (uint256 i = 0; i < _to.length; i++) {
            token.transferFrom(msg.sender, _to[i], _value[i]);
            
            if(!isAdded[_to[i]]){
            airdropUsers.push(_to[i]);
            isAdded[_to[i]] = true;
            }
            totalAirdroppedSent++;
            sendAmount.add(_value[i]);
        }
        emit LogTokenBulkSent(_tokenAddress, from, sendAmount);
    }

    function changeFee(uint _amount) public onlyOwner{
        _fee = _amount;
    }

    //subscribe to vip
    function subscribeToVip(uint subType, address client) payable public {
        subscriberCount += 1;
       uint amount = msg.value;
        address subscriber = client;
        
        bool status = true;
        uint timestamp = block.timestamp;
        uint expDate;

        if(msg.sender != owner()){
        if(subType==1){
            expDate = timestamp + (86400 * 1);
            require(amount >= starter, "You must have minimum of 1BNB to subscribe");
        }
        else if(subType==2){
            expDate = timestamp + (86400 * 7);
            require(amount >= premium, "You must have minimum of 2BNB to subscribe");
        }
        else{
           expDate = timestamp + (86400 * 30);
            require(amount >= business, "You must have minimum of 5BNB to subscribe");
        }
        }
       // payable(address(this)).transfer(amount);

        vipClients[subscriber] = VipUsers(subscriberCount, subscriber, subType, amount, status, timestamp, expDate );
        emit vipAdded(subscriberCount, subscriber, subType, amount, timestamp, expDate);
    }

    function ApproveERC20Token (address _tokenAddress, uint256 _value) external  {
        IERC20 token = IERC20(_tokenAddress);
        token.approve(address(this), _value); //Approval of spacific amount or more, this will be an idependent approval
        emit LogTokenApproval(_tokenAddress, _value);
    }
    
}