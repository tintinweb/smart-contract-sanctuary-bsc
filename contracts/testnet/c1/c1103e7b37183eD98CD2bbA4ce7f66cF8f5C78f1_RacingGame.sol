/**
 *Submitted for verification at BscScan.com on 2022-02-09
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

library SafeMath 
{

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract RacingGame
{
    using SafeMath for uint256;
    struct userinfo
    {
       uint256 totalpoint;
       uint256 totalclaim;
       string email;
    }

    mapping(address => userinfo) userdetails;
    mapping(string => address) useraddress;
    uint256 tokenValue;
    address token;
    address owner;

    modifier onlyOwner {
      require(msg.sender == owner);
      _;
   }

    constructor(address _address,address _owner)
    {
       token = _address;
       owner = _owner;
       tokenValue = 30;
    }

    function fundAccount(uint256 amount,string memory email) external 
    {
       IERC20(token).transferFrom(msg.sender,address(this),amount);
       userdetails[msg.sender].totalpoint += amount.mul(tokenValue);
       userdetails[msg.sender].email=email; 
       useraddress[email] = msg.sender;
    }

    function claminToken(uint256 amount) external
    {
       require((userdetails[msg.sender].totalpoint.div(tokenValue))>=amount,"you don't have balance"); 
       userdetails[msg.sender].totalclaim=amount;
       IERC20(token).transfer(msg.sender,amount);
    } 

    function settokenvalue(uint256 value) external onlyOwner
    {
        tokenValue = value;
    }

    function getuserinformation(address _address) external view returns(userinfo memory)
    {
        return userdetails[_address];
    }

    function getuserbalance(address _address) external view returns(uint256)
    {
        return userdetails[_address].totalpoint;
    }

    function getaddressfromemail(string memory email) external view returns(address)
    {
        return useraddress[email];
    }
}