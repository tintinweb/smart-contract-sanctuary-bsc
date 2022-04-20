/**
 *Submitted for verification at BscScan.com on 2022-04-20
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
        //uint256    share; 
        uint256    share2;         
         int256    rewardDebt;
         int256    rewardDebt1;
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
    mapping (address => uint256) public referrerNum;
    mapping (address => mapping (address => uint256)) public referrered;
    mapping (address => mapping (uint256 => address)) public referrer;


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
        user.rewardDebt = add(user.rewardDebt,int256(mul(_amount*67/100,acclpPerShare)/1e18));
        user.rewardDebt2 = add(user.rewardDebt2,int256(mul(_amount,acclpPerShare2)/1e18));
        address _dst = msg.sender;
        for (uint i=0;i<9;++i) {
            address _inviter = ue.inviter(_dst);
            if (referrered[_inviter][_dst] == 0) {
                referrerNum[_inviter] +=1;
                referrered[_inviter][_dst] = referrerNum[_inviter];
                referrer[_inviter][referrerNum[_inviter]] = _dst;
            }

            UserInfo storage user1 = userInfo[_inviter]; 
            if (_inviter == address(0)) i = 9;
            else if (i==0 && !_inviter.isContract()) {
                user1.rewardDebt = add(user1.rewardDebt1,int256(mul(_amount*10/100,acclpPerShare)/1e18));
                user1.share2 = add(user1.share2,_amount*10/100);
            }
            else if (i==1 && !_inviter.isContract()) {
                user1.rewardDebt = add(user1.rewardDebt1,int256(mul(_amount*8/100,acclpPerShare)/1e18));
                user1.share2 = add(user1.share2,_amount*8/100);
            }
            else if (i==2 && !_inviter.isContract()) {
                user1.rewardDebt = add(user1.rewardDebt1,int256(mul(_amount*5/100,acclpPerShare)/1e18));
                user1.share2 = add(user1.share2,_amount*5/100);
            }
            else if (i==3 && !_inviter.isContract()) {
                user1.rewardDebt = add(user1.rewardDebt1,int256(mul(_amount*3/100,acclpPerShare)/1e18));
                user1.share2 = add(user1.share2,_amount*3/100);
            }
            else if ((i==4 || i == 5) && !_inviter.isContract()) {
                user1.rewardDebt = add(user1.rewardDebt1,int256(mul(_amount*2/100,acclpPerShare)/1e18));
                user1.share2 = add(user1.share2,_amount*2/100);
            }
            else if ((i==6 || i == 7 || i == 8) && !_inviter.isContract()) {
                user1.rewardDebt = add(user1.rewardDebt1,int256(mul(_amount*1/100,acclpPerShare)/1e18));
                user1.share2 = add(user1.share2,_amount*1/100);
            }
            _dst = _inviter;
        } 
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
        uint256 accumulatedlot = mul((user.amount*67/100),acclpPerShare)/1e18;
        uint256 _pendinglot = toUInt256(sub(int256(accumulatedlot),user.rewardDebt));
        user.rewardDebt = int(accumulatedlot);
        uint256 _pendinglotsum =_pendinglot;
        if (ue.balancePrice(msg.sender)) {
            uint256 accumulatedlot1 = mul((user.share2),acclpPerShare)/1e18;
            uint256 _pendinglot1 = toUInt256(sub(int256(accumulatedlot),user.rewardDebt1));
            user.rewardDebt1 = int(accumulatedlot1);
            _pendinglotsum =add(_pendinglotsum,_pendinglot1);
        }

        uint256  accumulatedlot2 = mul(user.amount,acclpPerShare2)/1e18;
        uint256 _pendinglot2 = toUInt256(sub(int256(accumulatedlot2),user.rewardDebt2));
  
        if (_pendinglot2 != 0 && token.balanceOf(address(this)) >= _pendinglot2) {
            token.transfer(msg.sender, _pendinglot2);
            user.harved[address(token)] = add(user.harved[address(token)] ,_pendinglot2);
            user.rewardDebt2 = int(accumulatedlot2); 
        }
        
        // Interactions
        if (_pendinglotsum != 0 && token.balanceOf(found) >= _pendinglotsum) {
                token.transferFrom(found,msg.sender, _pendinglotsum);
                user.harved[address(token)] = add(user.harved[address(token)] ,_pendinglotsum);
            }
        if (_pendinglot != 0 ) {
            uint n = tokens.length;
            for (uint i = 0;i < n;++i) {
                address asserts = tokens[i];
                uint256 _decimals = TokenLike(asserts).decimals();
                uint256 wad = mul(_pendinglot*100/67,rate[asserts]*10**_decimals)/(10000*10**18);
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
        user.rewardDebt = sub(user.rewardDebt,int(mul(_amount*67/100,acclpPerShare)/1e18));
        user.rewardDebt2 = sub(user.rewardDebt2,int(mul(_amount,acclpPerShare2)/1e18));
        address _dst = msg.sender;
        for (uint i=0;i<9;++i) {
            address _inviter = ue.inviter(_dst);
            UserInfo storage user1 = userInfo[_inviter]; 
            if (_inviter == address(0)) i = 9;
            else if (i==0 && !_inviter.isContract()) {
                user1.rewardDebt1 = sub(user1.rewardDebt1,int256(mul(_amount*10/100,acclpPerShare)/1e18));
                if (user1.share2 > _amount*10/100)  user1.share2 = sub(user1.share2,_amount*10/100);
                else user1.share2 = 0;
            }
            else if (i==1 && !_inviter.isContract()) {
                user1.rewardDebt1 = sub(user1.rewardDebt1,int256(mul(_amount*8/100,acclpPerShare)/1e18));
                if (user1.share2 > _amount*8/100)  user1.share2 = sub(user1.share2,_amount*8/100);
                else user1.share2 = 0;
            }
            else if (i==2 && !_inviter.isContract()) {
                user1.rewardDebt1 = sub(user1.rewardDebt1,int256(mul(_amount*5/100,acclpPerShare)/1e18));
                if (user1.share2 > _amount*5/100)  user1.share2 = sub(user1.share2,_amount*5/100);
                else user1.share2 = 0;
            }
            else if (i==3 && !_inviter.isContract()) {
                user1.rewardDebt1 = sub(user1.rewardDebt1,int256(mul(_amount*3/100,acclpPerShare)/1e18));
                if (user1.share2 > _amount*3/100)  user1.share2 = sub(user1.share2,_amount*3/100);
                else user1.share2 = 0;
            }
            else if ((i==4 || i == 5) && !_inviter.isContract()) {
                user1.rewardDebt1 = sub(user1.rewardDebt1,int256(mul(_amount*2/100,acclpPerShare)/1e18));
                if (user1.share2 > _amount*2/100)  user1.share2 = sub(user1.share2,_amount*2/100);
                else user1.share2 = 0;
            }
            else if ((i==6 || i == 7 || i == 8) && !_inviter.isContract()) {
                user1.rewardDebt1 = sub(user1.rewardDebt1,int256(mul(_amount*1/100,acclpPerShare)/1e18));
                if (user1.share2 > _amount*1/100) user1.share2 = sub(user1.share2,_amount*1/100);
                else user1.share2 = 0;
            }
            _dst = _inviter;
        }
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
        uint _pendinglot1 = beharvest1(usr);
        uint _pendinglot2 = beharvest2(usr);
        return _pendinglot1+_pendinglot2;
    }
    function beharvest1(address usr) public view returns (uint256) {
        uint lpSupply = lp.balanceOf(address(this));
        uint256 blocks = sub(block.number,lastRewardBlock);
        uint256 lotReward = div(mul(mul(valuePerBlock,blocks),uint(1e18)),lpSupply);
        uint256 _acclotPerShare = add(acclpPerShare,lotReward);
        UserInfo storage user = userInfo[usr];
        uint256 accumulatedlot = mul(user.amount*67/100,_acclotPerShare)/1e18;
        uint256 accumulatedlot1 = mul(user.share2,_acclotPerShare)/1e18;
        uint256 _pendinglot = toUInt256(sub(int256(accumulatedlot),user.rewardDebt));
        uint256 _pendinglot1 = toUInt256(sub(int256(accumulatedlot1),user.rewardDebt1));
        return _pendinglot + _pendinglot1;
    }
    function beharvest2(address usr) public view returns (uint256) {
        uint lpSupply = lp.balanceOf(address(this));
        uint256 yield = token.balanceOf(lppool);
        uint256 lotReward2 = div(mul(yield,uint(1e18)),lpSupply);
        uint256 _acclotPerShare2 = add(acclpPerShare2,lotReward2);
        UserInfo storage user = userInfo[usr];
        uint256 accumulatedlot2 = mul(user.amount,_acclotPerShare2)/1e18;
        uint256 _pendinglot = toUInt256(sub(int256(accumulatedlot2),user.rewardDebt2));
        return _pendinglot;
    }
    function beharvest3(address usr) public view returns (uint256[] memory) {
        uint lpSupply = lp.balanceOf(address(this));
        uint256 blocks = sub(block.number,lastRewardBlock);
        uint256 lotReward = div(mul(mul(valuePerBlock,blocks),uint(1e18)),lpSupply);
        uint256 _acclotPerShare = add(acclpPerShare,lotReward);
        UserInfo storage user = userInfo[usr];
        uint256 accumulatedlot = mul(user.amount,_acclotPerShare)/1e18;
        uint256 _pendinglot = toUInt256(sub(int256(accumulatedlot),user.rewardDebt));
        uint n = tokens.length;
        uint256[] memory pending = new uint256[](n);
        for (uint i = 0;i < n;++i) {
                address asserts = tokens[i];
                uint256 _decimals = TokenLike(asserts).decimals();
                uint256 wad = mul(_pendinglot,rate[asserts]*10**_decimals)/(10000*10**18);
                if (TokenLike(asserts).balanceOf(found) >= wad) pending[i] = wad;
            }
        return pending;
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
    function levelone(address ust) public view returns (uint256, uint256, address[] memory) {
        uint256 n = referrerNum[ust];
        address[] memory uline = new address[](n); 
        if (n==0) return (0,0,uline);
        uint total;
        for (uint i = 1; i <=n ; ++i) {
            address underline = referrer[ust][i];
            uint256 wad = userInfo[underline].amount;
            total += wad;
            uline[i-1] = underline;
           }
        return (n,total,uline);
    }
    function leveltwo(address[] memory ust) public view returns (uint256, uint256) {
        uint256 n = ust.length;
        uint totalm;
        uint totalnum;
        for (uint i = 0; i <n ; ++i) {
            address underline = ust[i];
            (uint256 m,uint256 total, address[] memory uline) = levelone(underline);
            if (m !=0) {
                totalm += m;
                totalnum += total;
                (uint256 mm,uint256 tt) = leveltwo(uline);
                totalm += mm;
                totalnum += tt;
            }
           }
        return (totalm,totalnum);
    }
    function levelsan(address[] memory ust) public view returns (uint256, uint256) {
        uint256 n = ust.length;
        uint totalm;
        uint totalnum;
        for (uint i = 0; i <n ; ++i) {
            address underline = ust[i];
            (uint256 m,uint256 total,) = levelone(underline);
            if (m != 0) {
               totalm += m;
               totalnum += total; 
            }           
        }
        return (totalm,totalnum);
    }
 }