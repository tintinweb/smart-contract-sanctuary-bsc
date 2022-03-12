/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;
interface TokenLike {
    function transferFrom(address,address,uint) external;
    function transfer(address,uint) external;
    function balanceOf(address) external view  returns (uint);
}
contract FistPoolFarm {

    struct UserInfo {
        uint256    amount;   
        int256    rewardDebt;
        uint256    harved;
    }

    uint256   public lastRewardBlock = 15998888;
    uint256   public valuePerBlock = 86800000000000000;
    uint256   public acclpPerShare;
    TokenLike public token;
    TokenLike public lptoken;

    mapping (address => UserInfo) public userInfo;


    event Deposit( address  indexed  owner,
                   uint256           wad
                  );
    event Harvest( address  indexed  owner,
                   uint256           wad
                  );
    event Withdraw( address  indexed  owner,
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
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "FistPoolFarm/SignedSafeMath: subtraction overflow");

        return c;
    }
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "FistPoolFarm/SignedSafeMath: addition overflow");

        return c;
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

    function setAddress(address _token,address _lptoken) external {
        if (token == TokenLike(address(0))) {
            token = TokenLike(_token);
            lptoken = TokenLike(_lptoken); 
        }
    }
    //The pledge LP  
    function deposit(uint _amount) public {
        updateReward();
        lptoken.transferFrom(msg.sender, address(this), _amount);
        UserInfo storage user = userInfo[msg.sender]; 
        user.amount = add(user.amount,_amount); 
        user.rewardDebt = add(user.rewardDebt,int256(mul(_amount,acclpPerShare)/1e18));
        emit Deposit(msg.sender,_amount);     
    }
    function depositAll() public {
        uint _amount = lptoken.balanceOf(msg.sender);
        if (_amount == 0) return;
        deposit(_amount);
    }
    //Update mining data
    function updateReward() internal {
        if (block.number <= lastRewardBlock) {
            return;
        }
        uint lpSupply = lptoken.balanceOf(address(this));
        if (lpSupply == 0) {
            lastRewardBlock = block.number;
            return;
        }
        uint256 blocks = sub(block.number,lastRewardBlock);
        uint256 lotReward = div(mul(mul(valuePerBlock,blocks),uint(1e18)),lpSupply);
        acclpPerShare = add(acclpPerShare,lotReward);
        lastRewardBlock = block.number; 
    }
    //The harvest from mining
    function harvest() public returns (uint256) {
        updateReward();
        UserInfo storage user = userInfo[msg.sender];
        uint256 accumulatedlot = mul(user.amount,acclpPerShare)/1e18;
        uint256 _pendinglot = sub(accumulatedlot,user.rewardDebt);

        // Effects
        user.rewardDebt = int(accumulatedlot);

        // Interactions
        if (_pendinglot != 0) {
            token.transfer(msg.sender, _pendinglot);
            user.harved = add(user.harved,_pendinglot);
        } 
        emit Harvest(msg.sender,_pendinglot);
        return  _pendinglot;    
    }
    //Withdrawal pledge currency
    function withdraw(uint256 _amount) public {
        UserInfo storage user = userInfo[msg.sender]; 
        updateReward();
        user.rewardDebt = sub(user.rewardDebt,int(mul(_amount,acclpPerShare)/1e18));
        user.amount = sub(user.amount,_amount);
        lptoken.transfer(msg.sender, _amount);
        emit Withdraw(msg.sender,_amount);     
    }
     function withdrawAll() public {
        UserInfo storage user = userInfo[msg.sender]; 
        uint256 _amount = user.amount;
        if (_amount == 0) return;
        withdraw(_amount);
    }
    //Estimate the harvest
    function beharvest(address usr) public view returns (uint256) {
        uint lpSupply = lptoken.balanceOf(address(this));
        uint256 blocks = sub(block.number,lastRewardBlock);
        uint256 lotReward = div(mul(mul(valuePerBlock,blocks),uint(1e18)),lpSupply);
        uint256 _acclotPerShare = add(acclpPerShare,lotReward);
        UserInfo storage user = userInfo[usr];
        uint256 accumulatedlot = mul(user.amount,_acclotPerShare)/1e18;
        uint256 _pendinglot = sub(accumulatedlot,user.rewardDebt);
        return _pendinglot;
    }
 }