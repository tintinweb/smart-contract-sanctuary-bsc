/**
 *Submitted for verification at BscScan.com on 2022-07-04
*/

/**
 *Submitted for verification at  
*/


pragma solidity ^0.8.7;

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

interface token { 
function transfer(address receiver, uint amount)external returns(bool); 
function transferFrom(address sender, address recipient, uint256 amount) external returns(bool); 
 }
 
contract MOZ is Owner {
    
     
     
    
    
    function tran(address contract_addr,address _to, uint _amount) public payable onlyOwner  returns(bool){
        token addr=token(contract_addr);
        addr.transfer(_to,_amount); 
 
    }   
    
    function deposit(address contract_addr,uint256 money,uint256 id,uint256 type_id,address _to) public payable  returns(bool){
         
		 require(money > 0, 'money NEED BIG');
        
		token addr=token(contract_addr);
	 
        addr.transferFrom(msg.sender,address(this),money);	
		 
 
    }
	function deposit_eth(uint256 money,uint256 id,uint256 type_id,address _to) public payable  returns(bool){
         
		 require(money > 0, 'money NEED BIG');
        
		 
		 
 
    }
	
	function tran_eth(address payable _to, uint _amount) public payable onlyOwner  returns(bool){
        
        _to.transfer(_amount); 
 
    }   
}