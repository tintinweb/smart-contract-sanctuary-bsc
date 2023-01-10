/**
 *Submitted for verification at BscScan.com on 2023-01-10
*/

pragma solidity 0.8.17;


contract HG {


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
        mapping (address => uint256) private AGX;
    mapping (address => mapping (address => uint256)) private DGX;

    string private NME = "HCG";
    string private SMB = "HCG";
 address Owner = msg.sender;


    constructor () 
{} 


    
    function name() public view returns (string memory) {
        return NME;
    }

    function symbol() public view returns (string memory) {
        return SMB;
    }



    function balanceOf(address account) public view  returns (uint256) {
        return AGX[account];
    }
	 function allowance(address owner, address spender) public view  returns (uint256) { }
	

function approve(address spender, uint256 amount) public returns (bool success) {    
    
        emit Approval(msg.sender, spender, amount);
        return true; }

			   
  		
    function transfer(address recipient, uint256 amount) public returns (bool) {
}
 
	   
	   
    function transferFrom(address sender, address recipient, uint256 amount) public returns
     (bool) {}
}