/**
 *Submitted for verification at BscScan.com on 2022-03-19
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;
interface TokenLike {
    function transferFrom(address,address,uint) external;
    function transfer(address,uint) external;
    function balanceOf(address) external view  returns (uint);
}
interface ExchequerLike {
    function recommendPool(address) external returns (uint);
    function getrecommendPool() external view returns (uint);
}
contract ChildFarm {

    struct UserInfo {
        uint256    amount;   
        int256    rewardDebt;
        uint256    harved;
    }

    uint256   public acclotPerShare;
    uint256   public lpSupply;
    TokenLike public token;
    TokenLike public child = TokenLike(0xBEE8Ce01e7EB2F4d081aBa993025fc89B0eC5258);
    ExchequerLike public exchequer;

    mapping (address => UserInfo) public userInfo;


    event Deposit( address  indexed  owner,
                   uint256           wad
                  );
    event Harvest( address  indexed  owner,
                   uint256           wad
                  );

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
        require((b >= 0 && c <= a) || (b < 0 && c > a), "ChildFarm/SignedSafeMath: subtraction overflow");

        return c;
    }
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "ChildFarm/SignedSafeMath: addition overflow");

        return c;
    }
    function toUInt256(int256 a) internal pure returns (uint256) {
        require(a >= 0, "Integer < 0");
        return uint256(a);
    }
 
    function setAddress(address _token, address _exchequer) external {
        //if (token == TokenLike(address(0))) {
            token = TokenLike(_token);
            exchequer = ExchequerLike(_exchequer);
       // }
    }
 
    //The pledge of integral
    function deposit() public {
        updateReward();
        uint256 _balance = child.balanceOf(msg.sender);
        UserInfo storage user = userInfo[msg.sender]; 
        uint256 _amount = sub(_balance,user.amount);
        user.amount = add(user.amount,_amount); 
        lpSupply = add(lpSupply,_amount);
        user.rewardDebt = add(user.rewardDebt,int256(mul(_amount,acclotPerShare) / 1e18));
        emit Deposit(msg.sender,_amount);     
    }
    //Update mining data
    function updateReward() internal {
        if (lpSupply == 0) return;
        uint256 yield = exchequer.recommendPool(address(this));
        uint256 lotReward = div(mul(yield,uint(1e18)),lpSupply);
        acclotPerShare = add(acclotPerShare,lotReward);
    }
    //The harvest from mining
    function harvest() public returns (uint256) {
        updateReward();
        UserInfo storage user = userInfo[msg.sender];
        int256 accumulatedlot = int(mul(user.amount,acclotPerShare) /1e18);
        uint256 _pendinglot = toUInt256(sub(accumulatedlot,user.rewardDebt));

        // Effects
        user.rewardDebt = accumulatedlot;

        // Interactions
        if (_pendinglot != 0) {
            token.transfer(msg.sender, _pendinglot);
            user.harved = add(user.harved,_pendinglot);
        }    
        emit Harvest(msg.sender,_pendinglot);
        return  _pendinglot; 
    }
    //Estimate the harvest
    function beharvest(address usr) public view returns (uint256) {
        uint256 yield = exchequer.getrecommendPool();
        uint256 lotReward = div(mul(yield,uint(1e18)),lpSupply);
        uint256 _acclotPerShare = add(acclotPerShare,lotReward);
        UserInfo storage user = userInfo[usr];
        int256 accumulatedlot = int(mul(user.amount,_acclotPerShare) /1e18);
        uint256 _pendinglot = toUInt256(sub(accumulatedlot,user.rewardDebt));
        return _pendinglot;
    }
 }