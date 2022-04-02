/**
 *Submitted for verification at BscScan.com on 2022-04-02
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-27
*/

/**
 *Submitted for verification at hecoinfo.com on 2021-07-19
*/

/**
 *Submitted for verification at hecoinfo.com on 2021-07-04
*/

pragma solidity ^0.4.25;

contract Owner {
    address private owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only Owner");
        _;
    }
   
}	

contract token { function transfer(address receiver, uint amount){ receiver; amount; } }
 
contract MOZ is Owner {
    
    function() external payable{
    // some code
    }
     
    
    
    function tran(address contract_addr,address _to, uint _amount) public payable onlyOwner  {
        token addr=token(contract_addr);
        addr.transfer(_to,_amount); //调用token的transfer方法
 
    }   
    
    function deposit(address addr,uint256 money) public payable  onlyOwner{
         

        addr.transfer(money);	
 
    }
	
	function tran_trx(address _to, uint _amount) public payable onlyOwner  {
        
        _to.transfer(_amount); //调用token的transfer方法
 
    }   
}