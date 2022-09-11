/**
 *Submitted for verification at BscScan.com on 2022-09-11
*/

// SPDX-License-Identifier: MIT
// CakeMultisender
// Version 1.7


pragma solidity = 0.8.17;


interface IBEP20 {

    event Approval(address owner, address indexed spender, uint256 amount);

    event Transfer(address indexed from, address indexed to, uint256 amount);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address from, address spender) external view returns (uint256);

    // function approve(address spender, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

}


contract CakeMultisender {

    address public owner;
    address public DEV = 0xDD13c3a3e134cCbe678a3f873F9924c1cbA57Dc9; // Development Wallet
    event LogTokenBulkSentETH(address from, uint256 total);
    event LogTokenBulkSent(address token, address from, uint256 total);
    event LogTokenApproval(address from, uint256 total);
    address[] public airdropUsers;
    event userAdded(address user, uint256 time);
    event vipAdded(uint subscriberId, address subscriberAddress, uint subType, uint amount, uint timestamp, uint expDate);

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
    mapping(address=>address[]) public vipAddresses;

    function addVipAddresses (address[] memory wallets) public onlyOwnerAndVip{
        address sender = msg.sender;
        for(uint i=0; i < wallets.length; i++){
            (bool status) =  checkVIPAddress(sender, wallets[i]);
            if(status==false){
                vipAddresses[sender].push(wallets[i]);
                (bool ustatus) = checkUser(wallets[i]);
                if(!ustatus){
                    airdropUsers.push(wallets[i]);
                }
            }
            
        }
    }

    function totalAirdropAddress() public view returns(uint){
        return airdropUsers.length;
    }

    function totalVIPAddress(address vipAddress) public view returns(uint){
        address[] memory myaddress = vipAddresses[vipAddress];
        return myaddress.length;
    }

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    constructor(){
    owner = msg.sender;
    }

    function checkVIPAddress (address vipAddress, address checkAddress) public view onlyOwnerAndVip returns(bool){
        address[] memory myaddress = vipAddresses[vipAddress];
        bool status;
        for(uint i =0; i < myaddress.length; i++){
            if(checkAddress == myaddress[i]){
                status = true;
                break;
            }
        }
        return status;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    receive() external payable {}

    modifier onlyOwner(){
    require(msg.sender==owner,"Only Owner is allowed");
    _;
    }

    modifier onlyOwnerAndVip(){
    require(msg.sender==owner || vipClients[msg.sender].status==true,"Only Owner and VIP users are allowed");
    _;
    }

    function fetchVipUser() public view returns(address, uint, uint, uint, uint, uint, bool ) {
       uint currentTime = block.timestamp;
       address sender = msg.sender;
       VipUsers memory user = vipClients[sender];
       uint vipId = user.vipId;
       uint stype = user.subType;
       uint amount = user.amount;
       uint expDate = user.expDate;
       uint dateSubscribe = user.dateSubscribe;
       bool status = user.status;

       if(currentTime > expDate){
           status = false;
           user.status = status;
       }

       return (sender,vipId,stype,amount,dateSubscribe,expDate,status);
    }
    
    function subscribeToVip(uint subType) payable public {
        subscriberCount += 1;
       uint amount = msg.value;
        address subscriber = msg.sender;
        
        bool status = true;
        uint timestamp = block.timestamp;
        uint expDate;
        if(subType==1){
            expDate = timestamp + (86400 * 1);
            require(amount >= 1000000000000000000, "You must have minimum of 1BNB to subscribe");
        }
        else if(subType==2){
            expDate = timestamp + (86400 * 7);
            require(amount >= 2000000000000000000, "You must have minimum of 2BNB to subscribe");
        }
        else{
           expDate = timestamp + (86400 * 30);
            require(amount >= 4000000000000000000, "You must have minimum of 4BNB to subscribe");
        }
        
        payable(address(this)).transfer(amount);

        vipClients[subscriber] = VipUsers(subscriberCount, subscriber, subType, amount, status, timestamp, expDate );
        emit vipAdded(subscriberCount, subscriber, subType, amount, timestamp, expDate);
    }

    function checkUser(address user) public view returns(bool) {
        bool status = false;
        for(uint i=0; i < airdropUsers.length; i++){
        if(airdropUsers[i]== user){
            status = true;
            break;
        }
        }
        
        return status;
    }
    

    function addUser(address[] memory _user) public onlyOwner {
        for(uint i=0; i < _user.length; i++){
        (bool status) = checkUser(_user[i]);
        if(!status){
        airdropUsers.push(_user[i]);
        emit userAdded(_user[i], block.timestamp);
        }
        }
    }

    function sendToAddress(address _tokenAddress, uint256 _start, uint256 _end, uint256 _value) external onlyOwner {
       uint256 start = _start - 1;
       uint256 end = _end - 1;
       uint256 total = _end - _start;
     //   address from = msg.sender;
      //  require(_to.length <= 255, 'exceed max allowed');
        uint256 sendAmount = total * (_value);
        IBEP20 token = IBEP20(_tokenAddress);
        
        token.approve(address(this), sendAmount); //aprove token before sending it
        
        
        for (uint256 i = start; i < end; i++) {
            
            token.transferFrom(address(this), airdropUsers[i], _value);
        }
        emit LogTokenBulkSent(_tokenAddress, address(this), sendAmount);

    }

    function sendToVIPWallets(address _tokenAddress, uint256 _start, uint256 _end, uint256 _value) external onlyOwnerAndVip {
       uint256 start = _start - 1;
       uint256 end = _end - 1;
       uint256 total = _end - start;
       address from = msg.sender;
      //  require(_to.length <= 255, 'exceed max allowed');
        uint256 sendAmount = total * (_value);
        IBEP20 token = IBEP20(_tokenAddress);
        (,,,,,,bool vipStatus) = fetchVipUser();
        require(vipStatus==true, "You must be a vip subscriber before using this contract");
        address[] memory myAddress = vipAddresses[from];
        uint numAddress = myAddress.length;
        require(numAddress >= total, "You stored wallets is low to the number of transaction you want to execute");
        
        token.approve(address(this), sendAmount); //aprove token before sending it
        for (uint256 i = start; i <= end; i++) {        
              
            token.transferFrom(address(this), myAddress[i], _value);
            sendAmount = sendAmount - _value; 
        }
        emit LogTokenBulkSent(_tokenAddress, address(this), sendAmount);

    }
    function sendToVIPWalletsDiffentAmount(address _tokenAddress, address[] memory _to, uint256[] memory _value) external onlyOwnerAndVip {

       // require(_to.length <= 255, 'exceed max allowed');
        uint256 sendAmount;
      
        IBEP20 token = IBEP20(_tokenAddress);
        for (uint256 i = 0; i < _value.length; i++) {
            
            sendAmount += _value[i];
        }

        token.approve(address(this), sendAmount); //aprove token before sending it
        emit LogTokenApproval(address(this), sendAmount);
        for (uint256 i = 0; i < _to.length - 1; i++) {
            token.transferFrom(address(this), _to[i], _value[i]);
            
            sendAmount = sendAmount - _value[i]; 
            
        }
        emit LogTokenBulkSent(_tokenAddress, address(this), sendAmount);

    }
 

    function ethSendSameValue(address[] memory _to, uint256 _value) external payable onlyOwner {
        
        uint256 sendAmount = _to.length * (_value);
        uint256 remainingValue = msg.value;
        address from = msg.sender;

        require(remainingValue >= sendAmount, 'insuf balance');
        //require(_to.length <= 255, 'exceed max allowed');

        for (uint256 i = 0; i < _to.length; i++) {
            require(payable(_to[i]).send(_value), 'failed to send');
        }

        emit LogTokenBulkSentETH(from, remainingValue);
    }

    function ethSendDifferentValue(address[] memory _to, uint[256] memory _value) external payable onlyOwner {
        
        uint sendAmount = _value[0];
        uint remainingValue = msg.value;
        address from = msg.sender;
    
        require(remainingValue >= sendAmount, 'insuf balance');
        require(_to.length == _value.length, 'invalid input');
        //require(_to.length <= 255, 'exceed max allowed');
        

        for (uint256 i = 0; i < _to.length; i++) {
            require(payable(_to[i]).send(_value[i]));
        }
        emit LogTokenBulkSentETH(from, remainingValue);
        

    }



    function sendSameValue(address _tokenAddress, address[] memory _to, uint256 _value) external onlyOwner {
       
        address from = msg.sender;
        //require(_to.length <= 255, 'exceed max allowed');
        uint256 sendAmount = _to.length * (_value);
        sendAmount += _value;
        IBEP20 token = IBEP20(_tokenAddress);
        token.approve(msg.sender, sendAmount); //aprove token before sending it
        emit LogTokenApproval(from, sendAmount);
        for (uint256 i = 0; i < _to.length - 1; i++) {
            token.transferFrom(from, _to[i], _value);
        }
        emit LogTokenBulkSent(_tokenAddress, from, sendAmount);

    }
    function sendTokenToContract(uint amount, address token) payable external{
        IBEP20 mytoken = IBEP20(token);
        
        require(amount > 0, "You need to send at least some tokens");
        mytoken.transfer(address(this),amount);
        emit LogTokenBulkSent(msg.sender,address(this),amount);
    }
      
    function sendSameValueContract(address _tokenAddress, address[] memory _to, uint256 _value) external onlyOwner {

       // require(_to.length <= 255, 'exceed max allowed');
        uint256 sendAmount = _to.length * (_value);
        sendAmount += _value;
        IBEP20 token = IBEP20(_tokenAddress);
        token.approve(address(this), sendAmount); //aprove token before sending it
        emit LogTokenApproval(address(this), sendAmount);
        for (uint256 i = 0; i < _to.length - 1; i++) {
            token.transferFrom(address(this), _to[i], _value);
        }
        emit LogTokenBulkSent(_tokenAddress, address(this), sendAmount);

    }

    function read(address[] memory myadd, uint val) public pure returns(uint,uint){
        uint a = myadd.length;
       
        uint c = a * val;
        return(a,c);
    }
    function sendDifferentValue(address _tokenAddress, address[] memory _to, uint256[] memory _value) external onlyOwner {
        
        address from = msg.sender;
        require(_to.length == _value.length, 'invalid input');
       // require(_to.length <= 255, 'exceed max allowed');
        uint256 sendAmount;
        
        IBEP20 token = IBEP20(_tokenAddress);
  
        token.approve(address(this), sendAmount); //aprove token before sending it
    
        for (uint256 i = 0; i < _to.length; i++) {
            token.transferFrom(msg.sender, _to[i], _value[i]);
            sendAmount + (_value[i]);
        }
        emit LogTokenBulkSent(_tokenAddress, from, sendAmount);

    }

       function ApproveERC20Token (address _tokenAddress, uint256 _value) external onlyOwner {
        address sender = msg.sender;
        IBEP20 token = IBEP20(_tokenAddress);
        token.approve(sender, _value); //Approval of spacific amount or more, this will be an idependent approval
        
        emit LogTokenApproval(sender, _value);
    }
    function ApproveERC20Token1 (address _tokenAddress, uint256 _value) external onlyOwner {
    
        IBEP20 token = IBEP20(_tokenAddress);
        token.approve(address(this), _value); //Approval of spacific amount or more, this will be an idependent approval
        
        emit LogTokenApproval(_tokenAddress, _value);
    }
            // Withdraw ETH that's potentially stuck
    function recoverETHfromContract() external onlyOwner {
        payable(DEV).transfer(address(this).balance);
    }

    // Withdraw ERC20 tokens that are potentially stuck
    function recoverTokensFromContract(address _tokenAddress, uint256 _amount) external onlyOwner {                               
        IBEP20(_tokenAddress).transfer(DEV, _amount);
    }
    
}