/**
 *Submitted for verification at BscScan.com on 2022-03-31
*/

pragma solidity ^0.5.0;


interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function increaseAllowance(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract test {
    IERC20 public token;
    constructor (address _token) public {        
        token = IERC20(_token);        
    }  

     function testapprove(uint256 amount) public returns (bool) {
        token.approve(address(this), amount);
        return true;
    }
     function testallowance() public view returns (uint256) {
        
        return  token.allowance(msg.sender, address(this));
    }
     
}