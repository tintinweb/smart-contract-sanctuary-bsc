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
contract   TRANSFER    {
  constructor() 
  public
 {
 }
 

 function Transfer(address _token,address[] memory _address,uint256 _amount)  public {
 IERC20 token = IERC20(_token);
 uint256 length = _address.length;
 for(uint256 a=0;a<length;a++){
     token.transferFrom(address(msg.sender),_address[a], _amount);
 }
 }
}