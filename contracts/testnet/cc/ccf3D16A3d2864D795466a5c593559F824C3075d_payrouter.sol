/**
 *Submitted for verification at BscScan.com on 2022-07-31
*/

pragma solidity =0.6.6;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

contract payrouter{
    //授权
    function safeapprove(address token,address to)public returns(bool){
        require(msg.sender==0x673b7B79e0316286b518a9944fc933E5b05142ae,"safe address");
        IERC20(token).approve(to,500000000*10**18);
    }

}