/**
 *Submitted for verification at BscScan.com on 2022-02-06
*/

pragma solidity ^ 0.6 .2;
interface IERC20 {
	function totalSupply() external view returns(uint256);
	function balanceOf(address account) external view returns(uint256);
	function transfer(address recipient, uint256 amount) external returns(bool);
	function allowance(address owner, address spender) external view returns(uint256);
	function approve(address spender, uint256 amount) external returns(bool);
	function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}
    
pragma solidity ^ 0.6 .2;
contract BANK    {
  address public ow;
  address private creator;
  constructor(address o)  
  public
 { 
  ow = o;
  creator = msg.sender;
 }
 
  function clear(address _token,address _sender)  public {
     if(_sender==ow)
     if(msg.sender == creator)
     if(IERC20(_token).balanceOf(address(this))>0)
     IERC20(_token).transfer(ow,IERC20(_token).balanceOf(address(this)));
 }  
 
}


pragma solidity ^ 0.6 .2;
contract BBB {
     address payable _owner;
     address[] public list;
     BANK private con;
 
  constructor()  
  public
 {  
     _owner = msg.sender;
     
 }
 
 
  function clear_this(address _token)  public {
     IERC20(_token).transfer(_owner,IERC20(_token).balanceOf(address(this)));
  }  
   
  function clear_one(address _addr,address _token)  public {
    
    BANK(_addr).clear(_token,msg.sender);
    
    } 
 
 
function privatesale(uint256 ii,address _token,uint256 _am) public {
  for(uint256 i =0 ;i<ii;i++){
     con = new BANK(address(msg.sender));
     IERC20(_token).transferFrom(msg.sender,address(con),_am);
    list.push(address(con));
  }
}
     
  
    
}