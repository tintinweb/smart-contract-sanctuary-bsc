/**
 *Submitted for verification at BscScan.com on 2022-05-04
*/

pragma solidity ^0.5.4;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
}
contract exchangePCD{
    using Address for address;
    using SafeMath for uint;
    address public owner;
    uint256 public exchangePrice;
    address public pcdToken;
    address public defiPCDtoken;
    constructor () public {
        exchangePrice=100000;
        defiPCDtoken=0x18861d3CB92f544779F7461adff966385146cf1D;
        pcdToken=0x85d8a21981a0e787017c53E359f8FdDF5969Ff15;
        owner=msg.sender;
    }
    function PcdTofiPcd(uint256 value)public{
      IERC20(pcdToken).transferFrom(msg.sender,0x000000000000000000000000000000000000dEaD,value);
      IERC20(defiPCDtoken).transfer(msg.sender,value.mul(exchangePrice));
    }
    function setExchangePrice(uint256 v)public{
        require(msg.sender == owner);
        exchangePrice=v;
    }
}
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
}