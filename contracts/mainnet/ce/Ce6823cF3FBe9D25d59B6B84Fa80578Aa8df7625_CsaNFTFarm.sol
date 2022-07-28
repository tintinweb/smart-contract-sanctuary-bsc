/**
 *Submitted for verification at BscScan.com on 2022-07-28
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;
interface TokenLike {
    function transferFrom(address,address,uint) external;
    function transfer(address,uint) external;
    function balanceOf(address) external view  returns (uint);
}
interface ExchequerLike {
    function NftPool(address) external returns (uint);
    function getNftPool(address) external view returns (uint);
}

contract CsaNFTFarm {
 
        // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "CsaNFTFarm/not-authorized");
        _;
    } 
    struct UserInfo {
        uint256    amount;   
         int256    rewardDebt;
        uint256    harved;
    }

    uint256   public ccoinPerShare;

    TokenLike public token = TokenLike(0x55d398326f99059fF775485246999027B3197955);
    TokenLike public csaNFT = TokenLike(0x29168359aBd76ad34238b84133808f5dFCe5aC6e);
    ExchequerLike  public exchequerCsa;
    ExchequerLike  public exchequerCcoin;

    mapping (address => UserInfo) public userInfo;
    mapping (uint => address) public ownerOf;


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
        require((b >= 0 && c <= a) || (b < 0 && c > a), "CsaNFTFarm: subtraction overflow");

        return c;
    }
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "CsaNFTFarm: addition overflow");

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
    }
   function setAddress(uint256 what, address _ust) public auth {
        if (what == 1) csaNFT = TokenLike(_ust);
        if (what == 2) token = TokenLike(_ust);
        if (what == 3) exchequerCsa = ExchequerLike(_ust);
        if (what == 4) exchequerCcoin = ExchequerLike(_ust);
    }
    //The pledge LP  
    function deposit(uint tokenId) public {
        UserInfo storage user = userInfo[msg.sender]; 
        updateReward();
        csaNFT.transferFrom(msg.sender, address(this), tokenId);
        ownerOf[tokenId] = msg.sender;
        user.amount = add(user.amount,uint(1));  
        user.rewardDebt = add(user.rewardDebt,int256(mul(1,ccoinPerShare)));
        emit Deposit(msg.sender,tokenId);     
    }

    //Update mining data
    function updateReward() internal {
        uint lpSupply = csaNFT.balanceOf(address(this));
        uint256 yield = exchequerCsa.NftPool(address(this));
        if (address(exchequerCcoin) != address(0))  yield += exchequerCcoin.NftPool(address(this));
        uint256 Reward = div(mul(yield,uint(1e18)),lpSupply);
        ccoinPerShare = add(ccoinPerShare,Reward);
    }
    //The harvest from mining
    function harvest() public returns (uint256) {
        updateReward();
        UserInfo storage user = userInfo[msg.sender];
        uint256 accumulatedlot = mul(user.amount,ccoinPerShare)/1e18;
        uint256 _pendinglot = toUInt256(sub(int256(accumulatedlot),user.rewardDebt));

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
    function withdraw(uint256 tokenId) public {
        require(ownerOf[tokenId] == msg.sender, "CsaNFTFarm/Have withdrawal");
        UserInfo storage user = userInfo[msg.sender];
        updateReward();
        user.rewardDebt = sub(user.rewardDebt,int(mul(1,ccoinPerShare)));
        user.amount -= 1;
        csaNFT.transferFrom(address(this), msg.sender, tokenId);
        emit Withdraw(msg.sender,tokenId);     
    }

    //Estimate the harvest
    function beharvest(address usr) public view returns (uint256) {
        uint lpSupply = csaNFT.balanceOf(address(this));
        uint256 yield = exchequerCsa.getNftPool(address(this));
        if (address(exchequerCcoin) != address(0))  yield += exchequerCcoin.getNftPool(address(this));
        uint256 Reward = div(mul(yield,uint(1e18)),lpSupply);
        uint256 _ccoinPerShare = add(ccoinPerShare,Reward);
        UserInfo storage user = userInfo[usr];
        int256 accumulated = int(mul(user.amount,_ccoinPerShare) / 1e18);
        uint256 _pending = toUInt256(sub(accumulated,user.rewardDebt));
        return _pending;
    }
 }