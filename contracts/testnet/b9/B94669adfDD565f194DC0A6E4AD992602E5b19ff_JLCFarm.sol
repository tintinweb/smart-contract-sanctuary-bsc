/**
 *Submitted for verification at BscScan.com on 2023-02-15
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;
interface TokenLike {
    function transferFrom(address,address,uint) external;
    function transfer(address,uint) external;
    function balanceOf(address) external view  returns (uint);
}

contract JLCFarm {

    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "JLCFarm/not-authorized");
        _;
    }

    struct UserInfo {
        bool    id1;   
        bool    id2;  
        bool    id3;  
         int256    rewardDebt1;
         int256    rewardDebt2;
         int256    rewardDebt3;
        uint256    harved;
    }

    uint256   public acclpPerShare1;
    uint256   public acclpPerShare2;
    uint256   public acclpPerShare3;
    uint256   public lpSupply1;
    uint256   public lpSupply2; 
    uint256   public lpSupply3;
    bool      public start;
    TokenLike public usdt = TokenLike(0xE85131c9530A2Fc55D3587F914Ba6c1415f7EF86);
    address   public exchequer = 0x96Ab5580E8e345fAb2611Ee6315f296d13BBE1C0;

    mapping (address => UserInfo) public userInfo;

        // --- Math ---
    function add(uint x, int y) internal pure returns (uint z) {
        z = x + uint(y);
        require(y >= 0 || z <= x);
        require(y <= 0 || z >= x);
    }
    function sub(uint x, int y) internal pure returns (uint z) {
        z = x - uint(y);
        require(y <= 0 || z <= x);
        require(y >= 0 || z >= x);
    }
    function mul(uint x, int y) internal pure returns (int z) {
        z = int(x) * y;
        require(int(x) >= 0);
        require(y == 0 || z / y == int(x));
    }
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    
        return c;
      }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "JLC/SignedSafeMath: subtraction overflow");

        return c;
    }
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "JLC/SignedSafeMath: addition overflow");

        return c;
    }
    function toUInt256(int256 a) internal pure returns (uint256) {
        require(a >= 0, "Integer < 0");
        return uint256(a);
    }
    constructor() {
        wards[msg.sender] = 1;
    }
    function setStart() public auth{
        start = true;
    }
    function setExchequer(address ust) public auth{
        exchequer = ust;
    }
    function setidentity(address usr,uint level) public auth{
        updateReward();
        UserInfo storage user = userInfo[usr];
        if(level ==1 ) {
            require(!user.id1,"1");
            deposit1(usr);
        }
        if(level ==2) {
            require(!user.id2,"2");
            if(!user.id1) deposit1(usr);
            deposit2(usr);
        }
        if(level ==3) {
            require(!user.id3,"3");
            deposit3(usr);  
        } 
    }
    function deposit1(address usr) internal {
        lpSupply1 +=1;
        UserInfo storage user = userInfo[usr]; 
        user.id1 =true;
        user.rewardDebt1 = int256(acclpPerShare1);    
    }
    function deposit2(address usr) internal {
        lpSupply2 +=1;
        UserInfo storage user = userInfo[usr]; 
        user.id2 =true;
        user.rewardDebt2 = int256(acclpPerShare2);    
    }
    function deposit3(address usr) internal {
        lpSupply3 +=1;
        UserInfo storage user = userInfo[usr]; 
        user.id3 =true;
        user.rewardDebt3 = int256(acclpPerShare3);    
    }

    function updateReward() internal {
        if (!start) return;
        uint256 yield = usdt.balanceOf(exchequer);
        usdt.transferFrom(exchequer,address(this),yield);
        uint256 lpReward1 = div(yield/3,lpSupply1);
        uint256 lpReward2 = div(yield/3,lpSupply2);
        uint256 lpReward3 = div(yield/3,lpSupply3);
        acclpPerShare1 = add(acclpPerShare1,lpReward1);
        acclpPerShare2 = add(acclpPerShare2,lpReward2);
        acclpPerShare3 = add(acclpPerShare3,lpReward3);
    }

    //The harvest from mining
    function harvest() public returns (uint256) {
        updateReward();
        UserInfo storage user = userInfo[msg.sender];
        uint256 pendinglp1;
        uint256 pendinglp2;
        uint256 pendinglp3;
        if(user.id1){
            pendinglp1 = toUInt256(sub(int256(acclpPerShare1),user.rewardDebt1));
            user.rewardDebt1 = int(acclpPerShare1);
        }
        if(user.id2){
            pendinglp2 = toUInt256(sub(int256(acclpPerShare2),user.rewardDebt2));
            user.rewardDebt2 = int(acclpPerShare2);
        } 
        if(user.id3){
          pendinglp3 = toUInt256(sub(int256(acclpPerShare3),user.rewardDebt3));
          user.rewardDebt3 = int(acclpPerShare3); 
        } 

        uint256 pendinglp = pendinglp1+pendinglp2+pendinglp3;
        if (pendinglp != 0) {
            usdt.transfer(msg.sender, pendinglp);
            user.harved = add(user.harved,pendinglp);
        }    
       return  pendinglp;    
    }

    //Estimate the harvest
    function beharvest(address usr) public view returns (uint256) {
        if (!start) return 0;
        uint256 yield = usdt.balanceOf(exchequer)/3;
        uint256 lpReward1 = div(yield,lpSupply1);
        uint256 lpReward2 = div(yield,lpSupply2);
        uint256 lpReward3 = div(yield,lpSupply3);
        uint256 _acclpPerShare1 = add(acclpPerShare1,lpReward1);
        uint256 _acclpPerShare2 = add(acclpPerShare2,lpReward2);
        uint256 _acclpPerShare3 = add(acclpPerShare3,lpReward3);

        UserInfo storage user = userInfo[usr];

        uint256 pendinglp1;
        uint256 pendinglp2;
        uint256 pendinglp3;
        if(user.id1){
            pendinglp1 = toUInt256(sub(int256(_acclpPerShare1),user.rewardDebt1));
        }
        if(user.id2){
            pendinglp2 = toUInt256(sub(int256(_acclpPerShare2),user.rewardDebt2));
        } 
        if(user.id3){
          pendinglp3 = toUInt256(sub(int256(_acclpPerShare3),user.rewardDebt3));
        } 

        uint256 pendinglp = pendinglp1+pendinglp2+pendinglp3;
        return pendinglp;
    }
    function getUserInfo(address usr) public view returns (bool isBoss,uint256 harved, uint256 withdrawable){
        isBoss = userInfo[usr].id1;
        harved = userInfo[usr].harved;
        withdrawable = beharvest(usr);
    }
 }