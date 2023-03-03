/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-22
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

contract BusdEmpire {
    using SafeMath for uint256;
    BEP20 public busd = BEP20(0xDc6cc6d847DF088C3eEDA72404864B59c0cD53B2); 
    uint256 initializeTime;
    uint256 timeStep = 10 minutes;// 1 days
    mapping(uint256 => uint256) royalty1;
    mapping(uint256 => uint256) royalty2;
    mapping(uint256 => uint256) royalty3;
    mapping(uint256 => uint256) royalty4;
    mapping(uint256 => uint256) royalty5;
    address[] royalty1_array;
    address[] royalty2_array;
    address[] royalty3_array;
    address[] royalty4_array;
    address[] royalty5_array;

    struct Player {
        address referrer;
        uint256 myActDirect;
        uint256 withdraw;
        uint256 levelCount;
        bool isReg;
        mapping(uint256 => uint256) levelIncome;
        mapping(uint256 => uint256) levelTeam;
        mapping(uint256 => uint256) b5Entry;
        mapping(uint256 => uint256) isRoyalty;
        mapping(uint256 => mapping(uint256 => uint256)) b5_level;
        mapping(uint256 => address) b5_upline;
        mapping(uint256 => mapping(uint256 => uint256)) clubIncome;
        mapping(uint256 => uint256) incomeArray;
        mapping(uint256 => uint256) b6Entry;
        mapping(uint256 => uint256) b6reEntry;
        mapping(uint256 => mapping(uint256 => uint256)) b6_level;
        mapping(uint256 => address) b6_upline;
        mapping(uint256 => uint256) b6Income;
    }
    mapping(address => Player) public players;
    mapping( uint256 =>  address []) public b5;
    mapping( uint256 =>  address []) public b6;
    
    address owner;
    uint[20] level_bonuses = [10e18, 2e18, 1e18, 1e18, 1e18, 5e17, 5e17, 5e17, 5e17, 5e17, 5e17, 5e17, 5e17, 5e17, 5e17];
    uint[5] club_level1 = [10e18, 120e18, 1440e18, 17280e18, 27360e18];
    uint[5] club_level2 = [20e18, 240e18, 2880e18, 34560e18, 414720e18];
    modifier onlyAdmin(){
        require(msg.sender == owner,"You are not authorized.");
        _;
    }
    modifier security{
        uint size;
        address sandbox = msg.sender;
        assembly  { size := extcodesize(sandbox) }
        require(size == 0,"Smart Contract detected.");
        _;
    }
    constructor() public {
        owner = msg.sender;
        players[msg.sender].isReg = true;
        players[msg.sender].b5Entry[0]=1;
        for(uint8 i=0;i<6;i++){
            b5[i].push(msg.sender);
            players[msg.sender].isRoyalty[i]=1;
            b6[i].push(msg.sender);
        }
        initializeTime = block.timestamp;
    }
    
    function deposit(address _referral,uint256 _amount) public security{
        require(players[_referral].isReg==true,"Sponsor is not registered.");
        require(players[msg.sender].isReg==false,"You are already registered.");
        require(_amount == 40e18, "Invalid Amount");
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
        //Royalty
        uint256 totalDays = getCurDay();
        royalty1[totalDays]+=5e17;
        royalty2[totalDays]+=1e18;
        royalty3[totalDays]+=2e18;
        royalty4[totalDays]+=25e17;
        royalty5[totalDays]+=4e18;
        
        updateRoyalty(totalDays);
        if(players[_referral].myActDirect>=2){
            _setRank(_referral,players[_referral].myActDirect,players[_referral].levelCount);
        }
    }
    function _setRank(address _myAds,uint256 myDirect,uint256 lCount) internal {
        if(myDirect>=2 && lCount>=10 && players[_myAds].isRoyalty[0]==0){
            players[_myAds].isRoyalty[0]++;
            royalty1_array.push(_myAds);
        }else if(myDirect>=5 && lCount>=50 && players[_myAds].isRoyalty[1]==0){
            players[_myAds].isRoyalty[1]++;
            royalty2_array.push(_myAds);
        }else if(myDirect>=10 && lCount>=100 && players[_myAds].isRoyalty[2]==0){
            players[_myAds].isRoyalty[2]++;
            royalty3_array.push(_myAds);
        }else if(myDirect>=20 && lCount>=200 && players[_myAds].isRoyalty[3]==0){
            players[_myAds].isRoyalty[3]++;
            royalty4_array.push(_myAds);
        }else if(myDirect>=30 && lCount>=500 && players[_myAds].isRoyalty[4]==0){
            players[_myAds].isRoyalty[4]++;
            royalty5_array.push(_myAds);
        }
    }
    function _setReferral(address _referral) private {
        for(uint8 i = 0; i < level_bonuses.length; i++) {
            players[_referral].levelIncome[i]+=level_bonuses[i];
            players[_referral].levelTeam[i]++;
            players[_referral].levelCount++;
            busd.transfer(_referral,level_bonuses[i]);
            
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
            _ref = uint256(pool)/3; // formula (x-2)/3
        }
        if(players[b5[poolNo][_ref]].b5_level[poolNo][0]<3){
            _parent = _ref;
        }
        else{
            for(uint256 i=0;i<poollength;i++){
                if(players[b5[poolNo][i]].b5_level[poolNo][0]<3){
                   _parent = i;
                   break;
                }
            }
        }
        players[_addr].b5_upline[poolNo]=b5[poolNo][_parent];
        players[b5[poolNo][_parent]].b5_level[poolNo][0]++;
        address up=b5[poolNo][_parent];
        
        if(players[up].b5_level[poolNo][0]==1 && players[up].clubIncome[poolNo][0]==0){
            if(players[up].myActDirect>=1){
                players[up].clubIncome[poolNo][0]+=club_level1[poolNo];
                busd.transfer(up,club_level1[poolNo]);
            }else{
                players[owner].clubIncome[poolNo][2]+=club_level1[poolNo];
                busd.transfer(owner,club_level1[poolNo]);
            } 
        }
        address up1 = players[up].b5_upline[poolNo];
        if(up1 != address(0)){
            players[up1].b5_level[poolNo][1]++;
            
            address up2 = players[up1].b5_upline[poolNo];
            if(up2 != address(0)){
                players[up2].b5_level[poolNo][2]++;
                if(players[up2].b5_level[poolNo][2]==3 || players[up2].b5_level[poolNo][2]==6 || players[up2].b5_level[poolNo][2]==9){
                    if(players[up2].myActDirect>=(poolNo+1)){
                        players[up2].clubIncome[poolNo][1]+=club_level2[poolNo];
                        busd.transfer(up2,club_level2[poolNo]);
                    }else{
                        players[owner].clubIncome[poolNo][2]+=club_level2[poolNo];
                        busd.transfer(owner,club_level2[poolNo]);
                    } 
                }
                if(players[up2].b5_level[poolNo][2]>=27 && poolNo<4 && up2!=owner){
                    uint256 nextPool=poolNo+1;
                    players[up2].b5Entry[nextPool]++;
                    b5[nextPool].push(up2);
                    _setClub(nextPool,up2);
                }
            }
        }
    }
    function updateRoyalty(uint256 totalDays) private {
        for(uint256 j = totalDays; j > 0; j--){
            if(royalty1[j-1]>0 && royalty1_array.length>0){
                uint256 distLAmount=royalty1[j-1].div(royalty1_array.length);
                for(uint8 i = 0; i < royalty1_array.length; i++) {
                    players[royalty1_array[i]].incomeArray[0]+=distLAmount;
                }
                royalty1[j-1]=0;
            }
            if(royalty2[j-1]>0 && royalty2_array.length>0){
                uint256 distLAmount=royalty2[j-1].div(royalty2_array.length);
                for(uint8 i = 0; i < royalty2_array.length; i++) {
                    players[royalty2_array[i]].incomeArray[1]+=distLAmount;
                }
                royalty2[j-1]=0;
            }
            if(royalty3[j-1]>0 && royalty3_array.length>0){
                uint256 distLAmount=royalty3[j-1].div(royalty3_array.length);
                for(uint8 i = 0; i < royalty3_array.length; i++) {
                    players[royalty3_array[i]].incomeArray[2]+=distLAmount;
                }
                royalty3[j-1]=0;
            }
            if(royalty4[j-1]>0 && royalty4_array.length>0){
                uint256 distLAmount=royalty4[j-1].div(royalty4_array.length);
                for(uint8 i = 0; i < royalty4_array.length; i++) {
                    players[royalty4_array[i]].incomeArray[3]+=distLAmount;
                }
                royalty4[j-1]=0;
            }
            if(royalty5[j-1]>0 && royalty5_array.length>0){
                uint256 distLAmount=royalty5[j-1].div(royalty5_array.length);
                for(uint8 i = 0; i < royalty5_array.length; i++) {
                    players[royalty5_array[i]].incomeArray[4]+=distLAmount;
                }
                royalty5[j-1]=0;
            }
        }
    }
    function b6deposit(uint256 _amount) public {
        require(_amount >= 10e18, "Invalid Amount");
        require(players[msg.sender].isReg==true, "please register first.");
        uint8 poolNo=x4Info(_amount);
        busd.transferFrom(msg.sender,address(this),_amount);
        if(players[msg.sender].b6Entry[poolNo] == 0){
            players[msg.sender].b6Entry[poolNo]++;
        }else{
            players[msg.sender].b6reEntry[poolNo]++;
        }
        b6[poolNo].push(msg.sender);
        _setb6(poolNo,msg.sender,_amount);
    }
    function x4Info(uint256 _pkg) pure public returns(uint8 p) {
        if(_pkg == 25e18){
            p=1;
        }else if(_pkg == 50e18){
            p=2;
        }else if(_pkg == 100e18){
            p=3;
        }else if(_pkg == 200e18){
            p=4;
        }else if(_pkg == 500e18){
            p=5;
        }else{
            p=0;
        }
        return p;
    }
    function _setb6(uint256 poolNo,address _addr,uint256 _amount) private{
        uint256 poollength=b6[poolNo].length;
        uint256 pool = poollength-2; 
        uint256 _ref;
        uint256 _parent;
        if(pool<1){
            _ref = 0; 
        }else{
            _ref = uint256(pool)/2; // formula (x-2)/2
        }
        if(players[b6[poolNo][_ref]].b6_level[poolNo][0]<2){
            _parent = _ref;
        }
        else{
            for(uint256 i=0;i<poollength;i++){
                if(players[b6[poolNo][i]].b6_level[poolNo][0]<2){
                   _parent = i;
                   break;
                }
            }
        }
        players[_addr].b6_upline[poolNo]=b6[poolNo][_parent];
        players[b6[poolNo][_parent]].b6_level[poolNo][0]++;
        
        //2nd upline
        address up2 = players[b6[poolNo][_parent]].b6_upline[poolNo];
        if(up2 != address(0)){
            players[up2].b6_level[poolNo][1]++;
            if(players[up2].b6_level[poolNo][1]==4){
                players[up2].b6Income[poolNo]+=_amount.mul(4);
                players[up2].b6_level[poolNo][0]=0;
                players[up2].b6_level[poolNo][1]=0;
            }
        }
    }
    
    function unstake(address buyer,uint _amount) public security returns(uint){
        require(msg.sender == owner,"You are not purchase any club.");
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

    function poolDetails(address _addr) view external returns(uint256[5] memory clubTeam,uint256[5] memory clubTeam1,uint256[5] memory clubTeam2) {
        for(uint8 i=0;i<5;i++){
            clubTeam[i]=players[_addr].b5_level[i][0];
            clubTeam1[i]=players[_addr].b5_level[i][1];
            clubTeam2[i]=players[_addr].b5_level[i][2];
        }
        return (
           clubTeam,
           clubTeam1,
           clubTeam2
        );
    }
    function incomeDetails(address _addr) view external returns(uint256 totalInc,uint256 wdl,uint256[20] memory lvinc,uint256[5] memory clubinc1,uint256[5] memory clubinc2,uint256[5] memory clubinc3,uint256[5] memory royalInc,uint256[6] memory b6Inc) {
        for(uint8 i=0;i<20;i++){
            totalInc+=players[_addr].levelIncome[i];
            lvinc[i]=players[_addr].levelIncome[i];
            if(i<5){
                clubinc1[i]=players[_addr].clubIncome[i][0];
                clubinc2[i]=players[_addr].clubIncome[i][1];
                clubinc3[i]=players[_addr].clubIncome[i][2];
                totalInc+=players[_addr].clubIncome[i][0]+players[_addr].clubIncome[i][1];
                royalInc[i]=players[_addr].incomeArray[i];
            }
            if(i<6){
                b6Inc[i]=players[_addr].b6Income[i];
            }
        }
        return (
           totalInc,
           players[_addr].withdraw,
           lvinc,
           clubinc1,
           clubinc2,
           clubinc3,
           royalInc,
           b6Inc
        );
    }
    function getCurDay() public view returns(uint256) {
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