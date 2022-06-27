/**
 *Submitted for verification at BscScan.com on 2022-06-26
*/

pragma solidity ^0.8.15;
interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
    function balanceOf(address owner) external view returns (uint);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract WethEthConverter {
    uint256 public ETHAnt;
    address public WETH = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;  

    function deposit() public payable{
        IWETH(WETH).deposit{value: msg.value}();
    }

    function getContractBalance(address _to) public view returns(uint) {
       uint256 Balance = IERC20(WETH).balanceOf(_to);
       return Balance;
    }

    function withdraw(uint256 _value) external { 

        IWETH(WETH).approve(address(this), type(uint256).max);

        IWETH(WETH).withdraw(_value);
    }


    receive() external payable {}

    fallback() external payable {}
}