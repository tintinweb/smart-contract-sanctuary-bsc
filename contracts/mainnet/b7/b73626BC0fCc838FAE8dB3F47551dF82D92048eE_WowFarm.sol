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
contract WowFarm {
    using Address for address; 
        // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "WowFarm/not-authorized");
        _;
    } 
    struct UserInfo {
        uint256    amount;   
         int256    rewardDebt;
        mapping (address => uint256)   harved;
    }

    uint256   public lastRewardBlock;
    uint256   public valuePerBlock;
    uint256   public acclpPerShare;
    address   public found;
    address[] public tokens;
    TokenLike public wow;
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
        require((b >= 0 && c <= a) || (b < 0 && c > a), "WowFarm/SignedSafeMath: subtraction overflow");

        return c;
    }
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "WowFarm/SignedSafeMath: addition overflow");

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

    constructor(address _wow,address _chi) {
        wards[msg.sender] = 1;
        lastRewardBlock = block.number;
        wow = TokenLike(_wow);
        chi = TokenLike(_chi);
    }

    //The pledge LP  
    function deposit(uint _amount) public {
        updateReward();
        wow.transferFrom(msg.sender, address(this), _amount);
        UserInfo storage user = userInfo[msg.sender]; 
        user.amount = add(user.amount,_amount); 
        user.rewardDebt = add(user.rewardDebt,int256(mul(_amount,acclpPerShare)/1e18));
        emit Deposit(msg.sender,_amount);     
    }
    function depositAll() public {
        uint _amount = wow.balanceOf(msg.sender);
        if (_amount == 0) return;
        deposit(_amount);
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
        if (block.number <= lastRewardBlock) {
            return;
        }
        uint lpSupply = wow.balanceOf(address(this));
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
    function withdraw(uint256 _amount) public {
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= _amount,"WowFarm/not sufficient funds"); 
        updateReward();
        user.rewardDebt = sub(user.rewardDebt,int(mul(_amount,acclpPerShare)/1e18));
        user.amount = sub(user.amount,_amount);
        wow.transfer(msg.sender, _amount);
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
        uint lpSupply = wow.balanceOf(address(this));
        uint256 blocks = sub(block.number,lastRewardBlock);
        uint256 lotReward = div(mul(mul(valuePerBlock,blocks),uint(1e18)),lpSupply);
        uint256 _acclotPerShare = add(acclpPerShare,lotReward);
        UserInfo storage user = userInfo[usr];
        uint256 accumulatedlot = mul(user.amount,_acclotPerShare)/1e18;
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