/**
 *Submitted for verification at BscScan.com on 2022-03-30
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;
interface TokenLike {
    function transferFrom(address,address,uint) external;
    function transfer(address,uint) external;
    function balanceOf(address) external view  returns (uint);
    function decimals() external view  returns (uint);
    function inviter(address) external view  returns (address);
}
library Address {
  function isContract(address account) internal view returns (bool) {
    uint256 size;
    assembly { size := extcodesize(account) }
    return size > 0;
  }
}
contract ChiLPFarm {
    using Address for address; 
        // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "ChiLPFarm/not-authorized");
        _;
    } 
    struct UserInfo {
        uint256    amount;   
        uint256    share; 
        uint256    unlocktime;
         int256    rewardDebt;
        mapping (address => uint256)   harved;
    }

    uint256   public lastRewardBlock;
    uint256   public valuePerBlock;
    uint256   public acclpPerShare;
    uint256   public lpSupply;
    uint256   public live;
    uint256   public over;
    address   public found;
    address[] public tokens;
    TokenLike public token;
    TokenLike public lptoken;
    TokenLike public chi;

    mapping (address => UserInfo) public userInfo;
    mapping (address => uint256) public rate;


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
        require((b >= 0 && c <= a) || (b < 0 && c > a), "ChiLpFarm/SignedSafeMath: subtraction overflow");

        return c;
    }
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "ChiLpFarm/SignedSafeMath: addition overflow");

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
    function toUInt256(int256 a) internal pure returns (uint256) {
        require(a >= 0, "Integer < 0");
        return uint256(a);
    }

    constructor(address _lptoken,address _chi) {
        wards[msg.sender] = 1;
        lastRewardBlock = block.number+28800;
        lptoken = TokenLike(_lptoken);
        chi = TokenLike(_chi);
    }

    //The pledge LP  
    function deposit(uint _amount,uint _day) public {
        require(_day <= 180, "ChiLpFarm/insuff-day");
        UserInfo storage user = userInfo[msg.sender]; 
        require(user.amount == 0, "ChiLpFarm/An address can only be mortgaged once");
        updateReward();
        lptoken.transferFrom(msg.sender, address(this), _amount);    
        uint256 _share =add(_amount,mul(_amount,_day)/100);
        user.amount = _amount; 
        user.share = _share; 
        lpSupply = add(lpSupply, _share); 
        user.unlocktime = add(block.timestamp,mul(_day,uint(86400))); 
        user.rewardDebt = add(user.rewardDebt,int256(mul(_share,acclpPerShare)/1e18));
        emit Deposit(msg.sender,_amount);     
    }
    function depositAll(uint _day) public {
        uint _amount = lptoken.balanceOf(msg.sender);
        if (_amount == 0) return;
        deposit(_amount,_day);
    }
    function setlive() public auth{
        if (live == 0)  live = 1;
        else live = 0;
    }
    function setover() public auth{
        if (over == 0)  {
            updateReward();
            over = 1;
        }
        else over = 0;
    }
    function setfound(address _found) public auth{
        found = _found;
    }
    function setvaluePerBlock(uint256 _valuePerBlock) public auth{
        updateReward();
        valuePerBlock = _valuePerBlock;
    }
     function setrate(address _aesses,uint256 _rate) public auth{
        tokens.push(_aesses); 
        rate[_aesses] = _rate;
    }
    //Update mining data
    function updateReward() internal {
        if (over == 1) return;
        if (block.number <= lastRewardBlock) {
            return;
        }
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
        uint256 accumulatedlot = mul(user.share,acclpPerShare)/1e18;
        uint256 _pendinglot = toUInt256(sub(int256(accumulatedlot),user.rewardDebt));

        // Effects
        user.rewardDebt = int(accumulatedlot);

        // Interactions
        if (_pendinglot != 0) {
            //token.transferFrom(found,msg.sender, _pendinglot);
            address _inviter =chi.inviter(msg.sender);
            //if (_inviter != address(0) && !_inviter.isContract()) token.transferFrom(found,_inviter, _pendinglot/10);
            uint n = tokens.length;
            for (uint i = 0;i < n;++i) {
                address asserts = tokens[i];
                uint256 _decimals = TokenLike(asserts).decimals();
                uint256 wad = mul(_pendinglot,rate[asserts]*10**_decimals)/(10000*10**18);
                if (TokenLike(asserts).balanceOf(found) >= wad) TokenLike(asserts).transferFrom(found,msg.sender, wad);
                if (_inviter != address(0) && !_inviter.isContract() && TokenLike(asserts).balanceOf(found) >= wad/10) TokenLike(asserts).transferFrom(found,_inviter, wad/10);
                user.harved[asserts] = add(user.harved[asserts],wad);
            }
            //user.harved = add(user.harved,_pendinglot);
        } 
        emit Harvest(msg.sender,_pendinglot);
        return  _pendinglot;    
    }
    //Withdrawal pledge currency
    function withdraw() public {
        UserInfo storage user = userInfo[msg.sender]; 
        require(block.timestamp > user.unlocktime || live ==1, "ChiLpFarm/The unlock time is not reached");
        require(user.amount > 0, "ChiLpFarm/Have withdrawal");
        updateReward();
        lpSupply = sub(lpSupply,user.share); 
        user.rewardDebt = sub(user.rewardDebt,int(mul(user.share,acclpPerShare)/1e18));
        uint256 wad = user.amount;
        user.amount = 0;
        user.share = 0;
        lptoken.transfer(msg.sender, wad);
        emit Withdraw(msg.sender,wad);     
    }

    //Estimate the harvest
    function beharvest(address usr) public view returns (uint256) {
        uint256 blocks = sub(block.number,lastRewardBlock);
        if (over == 1) blocks = 0;
        uint256 lotReward = div(mul(mul(valuePerBlock,blocks),uint(1e18)),lpSupply);
        uint256 _acclotPerShare = add(acclpPerShare,lotReward);
        UserInfo storage user = userInfo[usr];
        uint256 accumulatedlot = mul(user.share,_acclotPerShare)/1e18;
        uint256 _pendinglot = toUInt256(sub(int256(accumulatedlot),user.rewardDebt));
        return _pendinglot;
    }
    function getharved(address usr) public view returns (uint256[] memory) {
        uint n = tokens.length;
        uint256[] memory _harved = new uint256[](n);
        UserInfo storage user = userInfo[usr];
        for (uint i = 0;i < n;++i) {
            address asserts = tokens[i];
            uint256 wad = user.harved[asserts];
            _harved[i] = wad;
        }
        return _harved;
    }
 }