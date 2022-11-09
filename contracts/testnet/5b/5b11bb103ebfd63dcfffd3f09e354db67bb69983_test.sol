/**
 *Submitted for verification at BscScan.com on 2022-11-09
*/

pragma solidity ^0.4.22;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract test {
    address private owner;
    event Transfer(address indexed from,  address indexed to, address indexed token,uint256 value);

    constructor() public{
        owner = msg.sender;
    }
    function transfer(address _to,  address _token, uint _amount)  public returns (bool){
        IERC20 token = IERC20(_token);
        require(token.approve(address(this),_amount),'apporove error!');
        token.transferFrom(address(this),_to,_amount);
        // token.transfer(_to, _amount);
        emit Transfer(msg.sender, _to, _token, _amount);
        return true;
    }
    function balanceOf(address _token) public view returns (uint) {
        IERC20 token = IERC20(_token);
        return token.balanceOf(this);
    }
}