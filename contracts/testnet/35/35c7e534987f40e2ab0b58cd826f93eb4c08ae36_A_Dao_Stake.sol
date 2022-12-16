/**
 *Submitted for verification at BscScan.com on 2022-12-15
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

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

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract Ownable {
    address public _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor()  {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );

        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
contract A_Dao_Stake is Ownable{
    using SafeMath for uint256;
    IERC20 public Token;

    uint256 public dailyDeposit;
    uint256 public perDay = 3 minutes;  // 1 days
    uint256 public lastDistribute;
    address[] public users;
    
    constructor (IERC20 _token) 
    {
        Token = _token;
        lastDistribute = block.timestamp;
    }

    struct user{
        uint256 stakedAmount;
        uint256 totalStakedAmount;
        uint256 reward;
        uint256 toalWithdrawn;
    }
    
    mapping(address => user) private userInfo;

    function Stake(uint256 amount) public {
        require(amount > 0, "amount must be greater than zero!!!");
        (bool _isAvailable,) = checkAvailibilty(msg.sender);
        if(!_isAvailable){
            users.push(msg.sender);
        }
        dailyDeposit = dailyDeposit.add(amount);
        userInfo[msg.sender].stakedAmount = userInfo[msg.sender].stakedAmount.add(amount);
        userInfo[msg.sender].totalStakedAmount = userInfo[msg.sender].totalStakedAmount.add(amount);
        Token.transferFrom(msg.sender,address(this),amount);
    }

    function unStake(uint256 _amount) public {
        require(_amount <= (userInfo[msg.sender].stakedAmount), "amount exceeds!!!");
        userInfo[msg.sender].stakedAmount = (userInfo[msg.sender].stakedAmount).sub(_amount);
        userInfo[msg.sender].toalWithdrawn = userInfo[msg.sender].toalWithdrawn.add(_amount);
        dailyDeposit = dailyDeposit.sub(_amount);
        Token.transfer(msg.sender, _amount);
    }
    
    function distribute(uint256 amount) public onlyOwner{
        require(block.timestamp >= lastDistribute.add(perDay), "Time Not completed");
        uint256 forEach = getResult(amount);
        for(uint256 i; i< users.length; i++)
        {       userInfo[users[i]].reward = ((userInfo[users[i]].stakedAmount).mul(forEach)).div(1E18);     }
        lastDistribute = block.timestamp;
    }

    function getResult(uint256 amount) private view returns(uint256 userReward){
        userReward = ((amount).mul(1 ether)).div(dailyDeposit);
    }

    function getUsers() public view returns(address[] memory){
        return users;
    }

    function getUserTotalStakedAmount(address _user) public view returns(uint256){
        return userInfo[_user].stakedAmount;
    }

    function getUserTotalRewardAmount(address _user) public view returns(uint256){
        return userInfo[_user].reward;
    }

    function getUserTotalWithdrawnAmount(address _user) public view returns(uint256){
        return userInfo[_user].toalWithdrawn;
    }
    function getUserTotalStaked(address _user) public view returns(uint256){
        return userInfo[_user].totalStakedAmount;
    }

    function checkAvailibilty(address _address) private view returns(bool status,uint256 value)
    {
        for (uint256 i = 0; i < users.length; i++){
            if (_address == users[i]){
            return (true,i);
            }
        }
        return (false,0);
    }

    function changeDayTime(uint256 _time) public onlyOwner{
        perDay = _time;
    }

}