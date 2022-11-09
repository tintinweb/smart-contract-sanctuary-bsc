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
    address private addrA;
    address private addrB;
    address private addrToken;

    struct Permit {
        bool addrAYes;
        bool addrBYes;
    }
    
    mapping (address => mapping (uint => Permit)) private permits;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    uint public totalSupply = 10*10**26;
    uint8 constant public decimals = 18;
    string constant public name = "MutiSigPTN";
    string constant public symbol = "MPTN";

    function totalSupply() external view returns (uint256){
          IERC20 token = IERC20(addrToken);
          return token.totalSupply();
    }

    constructor(address tokenAddress) public{
      
        addrToken = tokenAddress;
    }

    function  transfer(address to,  uint amount)  public returns (bool){
        IERC20 token = IERC20(addrToken);
        require(token.balanceOf(this) >= amount);
        token.transfer(to, amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }
    function balanceOf(address _owner) public view returns (uint) {
        IERC20 token = IERC20(addrToken);
        return token.balanceOf(this);
    }
}