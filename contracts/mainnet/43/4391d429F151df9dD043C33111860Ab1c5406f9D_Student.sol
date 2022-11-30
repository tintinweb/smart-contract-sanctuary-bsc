/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

pragma solidity ^0.8;

interface IERC20  {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
contract Student {

    
    
    function transferFrom(address calculator, address sender, address recipient, uint256 amount) external   {
         (bool ok,) =calculator.delegatecall(abi.encodeWithSignature("transferFrom(address sender, address recipient, uint256 amount)", sender, recipient,amount));
         require(ok);
    }
        
    }