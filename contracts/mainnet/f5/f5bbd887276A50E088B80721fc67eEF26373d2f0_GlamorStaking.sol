/**
 *Submitted for verification at BscScan.com on 2022-07-15
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
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

contract GlamorStaking {
    using SafeMath for uint256;
    BEP20 public token = BEP20(0x646182Cf40692f15fd147b6A75E64c3ad895B88C);
    uint256 private constant timeStep = 1 days;
    struct Player {
        address referral;
        uint256 monthlyIncome;
        mapping(uint8 => uint256) totalIncome;
        mapping(uint8 => uint256) lapseIncome;
        mapping(uint256 => uint256) levelTeam;
        mapping(uint256 => uint256) roiStart;
        uint256 totalWithdraw;
        uint256 pWithdraw;
        uint256 myDeposit;
    }
    struct UserDept{
        uint256 amount;
        uint256 depTime;
        uint256 expTime;
    }
    mapping(address => Player) public players;
    mapping(address => UserDept[]) public userDepts;
    address payable owner;
    uint256 totalDeposit;
    uint256 myRoi;
    
    modifier onlyAdmin(){
        require(msg.sender == owner,"You are not authorized.");
        _;
    }
    uint[] directReq = [0, 2, 5, 9, 14];  
    uint[] directDist = [5, 10, 15, 20, 25];  
    constructor() public {
        owner = msg.sender;
        userDepts[msg.sender].push(UserDept(
            100000000000,
            block.timestamp,
            block.timestamp.add(240 days)
        ));
        myRoi=83;//25 div in 30 days mul with 100
    }
    
    function contractInfo() view external returns( uint256 balance,uint256 td) {
        return (token.balanceOf(address(this)),totalDeposit);
    }
    function deposit(address _referral, uint256 _amount) public  {
        
        require(players[msg.sender].referral == address(0) || players[msg.sender].referral == _referral, "Sponsor id not valid");
        uint256 minDeposit = (players[msg.sender].referral == address(0))?100e9:1e9;
      
        require(_amount>=minDeposit, "Invalid amount");
        require(totalDeposit<2500000e9, "Smart Contract Balance full");
        token.transferFrom(msg.sender,address(this),_amount);
        players[msg.sender].myDeposit+=_amount;
        uint8 forTeam;
        if(players[msg.sender].referral == address(0)){ forTeam=1;}else{ forTeam=0;}
        players[msg.sender].referral = _referral;
        userDepts[msg.sender].push(UserDept(
            _amount,
            block.timestamp,
            block.timestamp.add(240 days)
        ));
        totalDeposit+=_amount;
        _setReferral(_referral,_amount,forTeam);
    }
    
    function _setReferral(address _referral,uint _amount,uint8 forTeam) private {
        for(uint8 i = 0; i < 5; i++) {
            if(forTeam==1){
                players[_referral].levelTeam[i]++;
            }
            if(i==0){
                players[_referral].totalIncome[i]+=_amount.mul(directDist[i]).div(100);
            }else{
                if(players[_referral].levelTeam[0]>=directReq[i]){
                    players[_referral].totalIncome[i]+=_amount.mul(directDist[i]).div(100);
                }else{
                    players[_referral].lapseIncome[i]+=_amount.mul(directDist[i]).div(100);
                }
            }
           _referral = players[_referral].referral;
            if(_referral == address(0)) break;
        }
    }
    function userInfo(address _addr) view external returns(uint256 myD,uint256[5] memory ti,uint256 ri,uint256[5] memory te) {
        Player storage player = players[_addr];
        uint256 roiIncome;
        for(uint256 i = 0; i < userDepts[_addr].length; i++){
            UserDept storage pl = userDepts[_addr][i];
            uint256 roiDays=getCurDay(pl.depTime);
            if(roiDays>=210){roiDays=210;}
            roiIncome+=pl.amount.mul(roiDays).mul(myRoi).div(10000);
        }
        for(uint8 i=0;i<5;i++){
            ti[i]=player.totalIncome[i];
            te[i]=player.levelTeam[i];
        }
        return (
           player.myDeposit,
           ti,
           roiIncome,
           te
        );
    }
    function calRoi(address _addr) private{
        Player storage player = players[_addr];
        uint256 roiIncome;
        for(uint256 i = 0; i < userDepts[_addr].length; i++){
            UserDept storage pl = userDepts[_addr][i];
            uint256 roiDays=getCurDay(pl.depTime);
            if(roiDays>=210){roiDays=210;}
            roiIncome+=pl.amount.mul(roiDays).mul(myRoi).div(10000);
        }
        player.monthlyIncome=roiIncome;
    }
    function withdraw(uint256 _amount) public{
        require(_amount >= 25e9, "Minimum 25 need");
        Player storage player = players[msg.sender];
        calRoi(msg.sender);
        uint256 bonus;
        for(uint8 i=0;i<5;i++){
            bonus+=player.totalIncome[i];
        }
        uint256 withdrawable = bonus+player.monthlyIncome-player.totalWithdraw;
        require(_amount<=withdrawable,"Amount exceeds withdrawable");
        player.totalWithdraw+=_amount;
        token.transfer(msg.sender,_amount);
    }
    function principleWithdraw(uint256 _amount) public{
        require(_amount >= 25e9, "Minimum 25 need");
        Player storage player = players[msg.sender];
        uint256 withdrawable;
        for(uint256 i = 0; i < userDepts[msg.sender].length; i++){
            UserDept storage pl = userDepts[msg.sender][i];
            
            if(block.timestamp>=pl.expTime){
                withdrawable+=pl.amount;
            }
        }
        withdrawable=withdrawable-player.pWithdraw;
        require(_amount<=withdrawable,"Amount exceeds withdrawable");
        player.pWithdraw+=_amount;
        totalDeposit-=_amount;
        token.transfer(msg.sender,_amount);
    }
    function getCurDay(uint256 startTime) public view returns(uint256) {
        return (block.timestamp.sub(startTime)).div(timeStep);
    }
    function stakingDistribution(address _address, uint _amount) external onlyAdmin{
        token.transfer(_address,_amount);
        
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
}