/**
 *Submitted for verification at BscScan.com on 2022-08-21
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;
interface TokenLike {
    function transferFrom(address,address,uint) external;
    function transfer(address,uint) external;
    function balanceOf(address) external view  returns (uint);
    function totalSupply() external view  returns (uint);
    function mint(address,uint) external;
}
interface ExchequerLike {
    function lpPool(address) external returns (uint);
    function getlpPool() external view returns (uint);
}

contract CsaLPFarm {

    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "CsaLPFarm/not-authorized");
        _;
    }
    struct UserInfo {
        uint256    amount; 
         int256    rewardDebtCsa;  
         int256    rewardDebtCcoin; 
        uint256    latetime;
        uint256    harvedCsa;
        uint256    harvedCcoin;
        uint256    harvedKey;
    }

    uint256        public lastRewardBlock;
    uint256        public valuePerBlock;
    uint256        public csaPerShare;
    uint256        public ccoinPerShare;
    uint256        public waittime = 86400;
    uint256        public unit = 100 * 1E18;
    TokenLike      public lptoken;
    TokenLike      public csa;
    address        public usdt = 0x55d398326f99059fF775485246999027B3197955;
    TokenLike      public ccoin;
    TokenLike      public goldKey= TokenLike(0xe4710aD575D9eEFB9A5f64346c5Ad9B735483D98);
    ExchequerLike  public exchequer;
    
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

    constructor(){
        wards[msg.sender] = 1;
    }
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
        require((b >= 0 && c <= a) || (b < 0 && c > a), "CsaLPFarm/SignedSafeMath: subtraction overflow");

        return c;
    }
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "CsaLPFarm/SignedSafeMath: addition overflow");

        return c;
    }
    function toUInt256(int256 a) internal pure returns (uint256) {
        require(a >= 0, "Integer < 0");
        return uint256(a);
    }

    function file(uint what, uint256 data) external auth {
        if (what == 1) waittime = data;
        else if (what == 2) unit = data;
        else if (what == 3) valuePerBlock = data;
        else revert("CsaLPFarm/file-unrecognized-param");
    }  
    function setToken(uint what, address ust) external auth {
        if (what == 1) lptoken = TokenLike(ust);
        else if (what == 2) ccoin = TokenLike(ust);
        else if (what == 3) goldKey = TokenLike(ust);
        else if (what == 4) csa = TokenLike(ust);
        else if (what == 5) exchequer = ExchequerLike(ust);
        else revert("CsaLPFarm/file-unrecognized-param");
    } 
    function deposit(uint _amount) public {
        updateReward(); 
        lptoken.transferFrom(msg.sender, address(this), _amount);
        UserInfo storage user = userInfo[msg.sender]; 
        user.amount = add(user.amount,_amount); 
        user.rewardDebtCsa = add(user.rewardDebtCsa,int256(mul(_amount,csaPerShare)/1e18));
        user.rewardDebtCcoin = add(user.rewardDebtCcoin,int256(mul(_amount,ccoinPerShare)/1e18));
        user.latetime = block.timestamp;
        emit Deposit(msg.sender,_amount);     
    }
    function updateReward() internal {
        if (block.number <= lastRewardBlock) {
            return;
        }
        uint256 lpSupply = lptoken.balanceOf(address(this));
        if (lpSupply == 0) {
            lastRewardBlock = block.number;
            return;
        }

        uint256 yield = exchequer.lpPool(address(this));
        uint256 csaReward = div(mul(yield,uint(1e18)),lpSupply);
        csaPerShare = add(csaPerShare,csaReward);

        uint256 blocks = sub(block.number,lastRewardBlock);
        uint256 ccoinReward = div(mul(mul(valuePerBlock,blocks),uint(1e18)),lpSupply);
        ccoinPerShare = add(ccoinPerShare,ccoinReward);
        lastRewardBlock = block.number; 
    }
    function harvest() public returns (uint256,uint256) {
        updateReward();
        UserInfo storage user = userInfo[msg.sender];

        uint256 accumulatedcsa = mul(user.amount,csaPerShare)/1e18;
        uint256 _pendingcsa = toUInt256(sub(int256(accumulatedcsa),user.rewardDebtCsa));
        user.rewardDebtCsa = int(accumulatedcsa);
        if (_pendingcsa != 0) {
            csa.transfer(msg.sender, _pendingcsa);
            user.harvedCsa = add(user.harvedCsa,_pendingcsa);
        } 

        uint256 accumulatedccoin = mul(user.amount,ccoinPerShare)/1e18;
        uint256 _pendingccoin = toUInt256(sub(int256(accumulatedccoin),user.rewardDebtCcoin));
        user.rewardDebtCcoin = int(accumulatedccoin);
        if (_pendingccoin != 0) {
            ccoin.transfer(msg.sender, _pendingccoin);
            user.harvedCcoin = add(user.harvedCcoin,_pendingccoin);
        } 
        emit Harvest(msg.sender,_pendingcsa);
        return  (_pendingcsa,_pendingccoin);    
    }
    function harvestGk() public {
        uint256 wad = beharvestGk(msg.sender);
        UserInfo storage user = userInfo[msg.sender];
        require(block.timestamp >= add(user.latetime,waittime), "CsaLPFarm/timenot");
        user.latetime = block.timestamp;
        goldKey.mint(msg.sender,wad);
        user.harvedKey += wad;
        emit Harvest(msg.sender,wad); 
    }
    function withdraw(uint256 _amount) public {
        UserInfo storage user = userInfo[msg.sender]; 
        require(user.amount >= _amount, "CsaLpFarm/Have withdrawal");
        updateReward();
        user.amount = sub(user.amount,_amount);
        user.rewardDebtCsa = sub(user.rewardDebtCsa,int256(mul(_amount,csaPerShare)/1e18));
        user.rewardDebtCcoin = sub(user.rewardDebtCcoin,int256(mul(_amount,ccoinPerShare)/1e18));
        lptoken.transfer(msg.sender, _amount);
        emit Withdraw(msg.sender,_amount);     
    }
    function beharvestGk(address usr) public view returns (uint256) {
        uint256 _lpPrice = lpPrice();
        UserInfo storage user = userInfo[usr];
        uint256 amountMultiplier = div(mul(_lpPrice,user.amount), unit*1e18);
        return amountMultiplier;
    }
    function beharvestCsa(address usr) public view returns (uint256) {
        uint lpSupply = lptoken.balanceOf(address(this));
        uint256 yield = exchequer.getlpPool();
        uint256 csaReward = div(mul(yield,uint(1e18)),lpSupply);
        uint256 _csaPerShare = add(csaPerShare,csaReward);
        UserInfo storage user = userInfo[usr];
        int256 accumulatedcsa = int(mul(user.amount,_csaPerShare) / 1e18);
        uint256 _pendingcsa = toUInt256(sub(accumulatedcsa,user.rewardDebtCsa));
        return _pendingcsa;
    }
    function beharvestCcoin(address usr) public view returns (uint256) {
        uint lpSupply = lptoken.balanceOf(address(this));
        uint256 blocks = sub(block.number,lastRewardBlock);
        uint256 ccoinReward = div(mul(mul(valuePerBlock,blocks),uint(1e18)),lpSupply);
        uint256 _ccoinPerShare = add(ccoinPerShare,ccoinReward);
        UserInfo storage user = userInfo[usr];
        uint256 accumulatedccoin = mul(user.amount,_ccoinPerShare)/1e18;
        uint256 _pendingccoin = toUInt256(sub(int256(accumulatedccoin),user.rewardDebtCcoin));
        return _pendingccoin;
    }
    function lpPrice() public view returns (uint256) {
        uint256 total = TokenLike(address(lptoken)).totalSupply();
        uint256 balance = TokenLike(usdt).balanceOf(address(lptoken));
        return 2*balance*1e18/total;
    }
 }