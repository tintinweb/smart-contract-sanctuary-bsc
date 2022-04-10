/**
 *Submitted for verification at BscScan.com on 2022-04-10
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;
interface TokenLike {
    function transferFrom(address,address,uint) external;
    function transfer(address,uint) external;
    function balanceOf(address) external view  returns (uint);
    function decimals() external view  returns (uint);
    function inviter(address) external view  returns (address);
    function balancePrice(address) external view  returns (bool);
}
library Address {
  function isContract(address account) internal view returns (bool) {
    uint256 size;
    assembly { size := extcodesize(account) }
    return size > 0;
  }
}
contract UeFarm {
    using Address for address; 
        // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "UeFarm/not-authorized");
        _;
    } 
    struct UserInfo {
        uint256    amount;   
         int256    rewardDebt;
         int256    rewardDebt2;
        mapping (address => uint256)   harved;
    }

    uint256   public lastRewardBlock;
    uint256   public valuePerBlock;
    uint256   public acclpPerShare;
    uint256   public acclpPerShare2;
    address   public found;
    TokenLike public lp;
    address[] public tokens;
    TokenLike public token;
    TokenLike public ue;
    address   public lppool;

    mapping (address => UserInfo) public userInfo;
    mapping (address => uint256) public rate;
    mapping (address => bool) public id;


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
        require((b >= 0 && c <= a) || (b < 0 && c > a), "UeFarm: subtraction overflow");

        return c;
    }
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "UeFarm: addition overflow");

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

    constructor() {
        wards[msg.sender] = 1;
        lastRewardBlock = block.number;
        // ue = TokenLike(_ue);
        // lp = TokenLike(_lp);
    }

    //The pledge LP  
    function deposit(uint _amount) public {
        updateReward();
        lp.transferFrom(msg.sender, address(this), _amount);
        UserInfo storage user = userInfo[msg.sender]; 
        user.amount = add(user.amount,_amount); 
        user.rewardDebt = add(user.rewardDebt,int256(mul(_amount,acclpPerShare)/1e18));
        user.rewardDebt2 = add(user.rewardDebt2,int256(mul(_amount,acclpPerShare2)/1e18));
        emit Deposit(msg.sender,_amount);     
    }
    function depositAll() public {
        uint _amount = lp.balanceOf(msg.sender);
        if (_amount == 0) return;
        deposit(_amount);
    }

    function setfound(uint256 what,address _ust) public auth{
       if (what == 1) found = _ust;
       if (what == 2) token = TokenLike(_ust);
       if (what == 3) ue = TokenLike(_ust);
       if (what == 4) lp = TokenLike(_ust);
       if (what == 5) lppool = _ust;
    }
    function setvaluePerBlock(uint256 _valuePerBlock) public auth{
        updateReward();
        valuePerBlock = _valuePerBlock;
    }
     function setrate(address _aesses,uint256 _rate) public auth{
         if (!id[_aesses]) {
            id[_aesses] = true;
            tokens.push(_aesses);
         }
        rate[_aesses] = _rate;
    }
    //Update mining data
    function updateReward() internal {
        if (block.number <= lastRewardBlock) {
            return;
        }
        uint lpSupply = lp.balanceOf(address(this));
        if (lpSupply == 0) {
            lastRewardBlock = block.number;
            return;
        }
        
        uint256 yield = token.balanceOf(lppool);
        if (yield>0) {
            token.transferFrom(lppool,address(this),yield);
            uint256 lotReward2 = div(mul(yield,uint(1e18)),lpSupply);
            acclpPerShare2 = add(acclpPerShare2,lotReward2);
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
        user.rewardDebt = int(accumulatedlot);

        uint256  accumulatedlot2 = mul(user.amount,acclpPerShare2)/1e18;
        uint256 _pendinglot2 = toUInt256(sub(int256(accumulatedlot2),user.rewardDebt2));
        user.rewardDebt2 = int(accumulatedlot2);

        if (_pendinglot2 != 0 && token.balanceOf(address(this)) >= _pendinglot2) {
            token.transfer(msg.sender, _pendinglot2);
            user.harved[address(token)] = add(user.harved[address(token)] ,_pendinglot2);
        }
        // Interactions
        if (_pendinglot != 0) {
            if (token.balanceOf(found) >= _pendinglot) {
                token.transferFrom(found,msg.sender, _pendinglot*67/100);
                user.harved[address(token)] = add(user.harved[address(token)] ,_pendinglot*67/100);
        
                address _dst = msg.sender;
                for (uint i=0;i<9;++i) {
                    address _inviter = ue.inviter(_dst);
                    if (_inviter == address(0)) i = 9;
                    else if (i==0 && !_inviter.isContract() && ue.balancePrice(_inviter)) token.transferFrom(found,_inviter, _pendinglot/10);
                    else if (i==1 && !_inviter.isContract() && ue.balancePrice(_inviter)) token.transferFrom(found,_inviter, _pendinglot*8/100);
                    else if (i==2 && !_inviter.isContract() && ue.balancePrice(_inviter)) token.transferFrom(found,_inviter, _pendinglot*5/100);
                    else if (i==3 && !_inviter.isContract() && ue.balancePrice(_inviter)) token.transferFrom(found,_inviter, _pendinglot*3/100);
                    else if ((i==4 || i == 5) && !_inviter.isContract() && ue.balancePrice(_inviter)) token.transferFrom(found,_inviter, _pendinglot*2/100);
                    else if ((i==6 || i == 7 || i == 8) && !_inviter.isContract() && ue.balancePrice(_inviter)) token.transferFrom(found,_inviter, _pendinglot*1/100);
                    _dst = _inviter; 
                } 
            }

            uint n = tokens.length;
            for (uint i = 0;i < n;++i) {
                address asserts = tokens[i];
                uint256 _decimals = TokenLike(asserts).decimals();
                uint256 wad = mul(_pendinglot,rate[asserts]*10**_decimals)/(10000*10**18);
                if (TokenLike(asserts).balanceOf(found) >= wad) TokenLike(asserts).transferFrom(found,msg.sender, wad);
                user.harved[asserts] = add(user.harved[asserts],wad);
            }
        } 
        emit Harvest(msg.sender,_pendinglot);
        return  _pendinglot;    
    }
    function withdraw(uint256 _amount) public {
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= _amount,"UeFarm/not sufficient funds"); 
        updateReward();
        user.rewardDebt = sub(user.rewardDebt,int(mul(_amount,acclpPerShare)/1e18));
        user.rewardDebt2 = sub(user.rewardDebt2,int(mul(_amount,acclpPerShare2)/1e18));
        user.amount = sub(user.amount,_amount);
        lp.transfer(msg.sender, _amount);
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
        uint lpSupply = lp.balanceOf(address(this));
        uint256 blocks = sub(block.number,lastRewardBlock);
        uint256 yield = token.balanceOf(lppool);
        uint256 lotReward = div(mul(add(mul(valuePerBlock,blocks),yield),uint(1e18)),lpSupply);
        uint256 _acclotPerShare = add(acclpPerShare,lotReward);
        UserInfo storage user = userInfo[usr];
        uint256 accumulatedlot = mul(user.amount,_acclotPerShare)/1e18;
        uint256 _pendinglot = toUInt256(sub(int256(accumulatedlot),user.rewardDebt));
        return _pendinglot;
    }
    function getharved(address usr) public view returns (uint256[] memory) {
        uint n = tokens.length;
        uint256[] memory _harved = new uint256[](n+1);
        UserInfo storage user = userInfo[usr];
        _harved[0] = user.harved[address(token)];
        for (uint i = 1;i <= n;++i) {
            address asserts = tokens[i-1];
            uint256 wad = user.harved[asserts];
            _harved[i] = wad;
        }
        return _harved;
    }
 }