/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

pragma solidity ^0.8.17;
interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }


    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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


    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

 
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }


    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Dakaochang{
    using SafeMath for uint;


    mapping(address => bool) public whitelist;
    mapping(address => uint) public expirationInfo;

    mapping(address => uint) public leaderInfo;
    address public owner = 0xD814e22f89e3B67B465af2795b7cdfC24dEB5d52;
    address public USDT = 0x55d398326f99059fF775485246999027B3197955;
    uint256 public Amount = 1500000000000000000;
    uint256 public WhitelistAmount = 300000000000000000000;

    modifier onlyowner{
        require(msg.sender == owner);
        _;
    }

    function setLeader(address _address,uint percent) external onlyowner{
        leaderInfo[_address] = percent;
    }
    function setwhiletlist(address _address) external onlyowner{
        whitelist[_address] = true;
    }
    function multiwhitelist(address[] calldata _addlist) external onlyowner{
        uint len = _addlist.length;
        for(uint i = 0; i< len; ++i){
            whitelist[_addlist[i]] = true;
        }
    }
    function changeAmount(uint256 amount) external onlyowner{
        Amount = amount;
    }
    function changeWhiteListAmount(uint256 amount) external onlyowner{
        WhitelistAmount = amount;
    }

    function removewhitelist(address _add) external onlyowner{
        whitelist[_add] = false;
    }
    function withdraw(address _coin) external payable onlyowner{
        IERC20(_coin).transfer(owner,IERC20(_coin).balanceOf(address(this)));
    }

    function toWhiteList(address _invitor) external payable{
        require(!whitelist[msg.sender]);
        require(msg.sender != _invitor,"cant yourself");
        IERC20(USDT).transferFrom(msg.sender,owner,WhitelistAmount.mul(100-leaderInfo[_invitor]).div(100));
        IERC20(USDT).transferFrom(msg.sender,_invitor,WhitelistAmount.mul(leaderInfo[_invitor]).div(100));
        whitelist[msg.sender] = true;
    }

    function Deposit(address _invitor,uint256 dayTimes) public payable{
        require(dayTimes>0,"dayTimes need > 0 ");
        require(_invitor!=address(0));
        require(msg.sender != _invitor,"cant yourself");
        uint transferAmount = dayTimes*Amount;
        if(dayTimes==7){
            transferAmount = transferAmount.mul(9).div(10);
        }
        if(dayTimes==30){
            transferAmount = transferAmount.mul(8).div(10);
        }

        IERC20(USDT).transferFrom(msg.sender,owner,transferAmount.mul(100-leaderInfo[_invitor]).div(100));
        IERC20(USDT).transferFrom(msg.sender,_invitor,transferAmount.mul(leaderInfo[_invitor]).div(100));
        expirationInfo[msg.sender]=block.timestamp+60*60*24*dayTimes;

    }
    function getUserExpired(address user) public view returns (bool expired)
    {
        if(expirationInfo[user]>block.timestamp){
            return true;
        }else{
            return false;
        }
        
    }

}