/**
 *Submitted for verification at BscScan.com on 2022-07-28
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

interface TokenLike {
    function transfer(address,uint256) external;
    function transferFrom(address,address,uint256) external;
    function approve(address sender, uint256 amount) external;
    function balanceOf(address) external view returns (uint256);
    function mint(address,uint256) external;
}

interface LockLike {
    function vestingLock(address owner, 
        address token, 
        bool isLpToken, 
        uint256 amount, 
        uint256 tgeDate, 
        uint256 tgeBps, 
        uint256 cycle, 
        uint256 cycleBps, 
        string  memory description
        )external returns (uint256 id);
}

interface InviterLike {
    function inviter(address) external view returns (address);
    function setLevel(address, address) external;
}
interface RouterV2 {
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);
}
library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}
contract Donate {
    using Address for address;
    // --- Auth ---
    mapping (address => uint256) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "Donate/not-authorized");
        _;
    }

    // --- Math ---
    function add(uint256 x, int y) internal pure returns (uint256 z) {
        z = x + uint256(y);
        require(y >= 0 || z <= x);
        require(y <= 0 || z >= x);
    }
    function sub(uint256 x, int y) internal pure returns (uint256 z) {
        z = x - uint256(y);
        require(y <= 0 || z <= x);
        require(y >= 0 || z >= x);
    }
    function mul(uint256 x, int y) internal pure returns (int z) {
        z = int(x) * y;
        require(int(x) >= 0);
        require(y == 0 || z / y == int(x));
    }
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x);
    }
    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x);
    }
    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    address                                           public  usdt = 0x55d398326f99059fF775485246999027B3197955;
    address                                           public  v2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address                                           public  lockAddr2 = 0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE;
    InviterLike                                       public  csaInviter = InviterLike(0xC6107Bf3a0d7645B5c1ed4f04Feb7b1B1A898058);
    address                                           public  csa;
    address                                           public  ccoin;
    address                                           public  goldKey = 0xd4ee1e59Af6CA30f578aB05d371db290696aaAE4;
    address                                           public  csaNFT = 0x29168359aBd76ad34238b84133808f5dFCe5aC6e;
    uint256                                           public  donateTotal;
    uint256                                           public  max = 200000*1e18;
    uint256                                           public  min = 20;
    uint256                                           public  usdtAmount = 200*1e18;
    uint256                                           public  csaAmount = 10000*1e18;
    uint256                                           public  lockAmount = 10000*1e18;
    uint256                                           public  ccoinAmount = 1000*1e18;
    uint256                                           public  tgeDate = block.timestamp + 2592000;
    uint256                                           public  tgeBps = 1000;
    uint256                                           public  cycle = 2592000;
    uint256                                           public  cycleBps = 1000;
    mapping (address => bool)                         public  donated;
    mapping (address => uint256)                      public  count;

    constructor() {
        wards[msg.sender] = 1;
    }

    function setAddress(uint256 what, address _ust, uint256 _data) public auth {
        if (what == 1) csaInviter = InviterLike(_ust);
        if (what == 2) lockAddr2 = _ust;
        if (what == 3) v2Router = _ust;
        if (what == 4) csa = _ust;
        if (what == 5) ccoin = _ust;
        if (what == 6) goldKey = _ust;
        if (what == 7) csaNFT = _ust;
        if (what == 8) max = _data;
        if (what == 9) usdtAmount = _data;
        if (what == 10) csaAmount = _data;
        if (what == 11) lockAmount = _data;
        if (what == 12) tgeDate = _data;
        if (what == 13) tgeBps = _data;
        if (what == 14) cycle = _data;
        if (what == 15) cycleBps = _data;
        if (what == 16) min = _data;
        if (what == 17) ccoinAmount = _data;
    }

    function init() public {
        TokenLike(csa).approve(v2Router, ~uint256(0));
        TokenLike(usdt).approve(v2Router, ~uint256(0));
        TokenLike(csa).approve(lockAddr2, ~uint256(0));
    }

    function usdtDonate(address referrer) public returns (bool){
        if (csaInviter.inviter(msg.sender) == address(0) && referrer != address(0))
            csaInviter.setLevel(msg.sender,referrer);
        require(!donated[msg.sender] ,"Donate/Quota is full");
        require(donateTotal< max,"Donate/Quota is full");
        TokenLike(usdt).transferFrom(msg.sender, address(this), usdtAmount);
        TokenLike(csa).transfer(msg.sender,  csaAmount);
        LockLike(lockAddr2).vestingLock(msg.sender, csa, false, lockAmount, tgeDate, tgeBps, cycle, cycleBps, "");
        donateTotal += usdtAmount;
        address _referrer = csaInviter.inviter(msg.sender);
        if (_referrer != address(0) && !_referrer.isContract()) {
            count[_referrer] +=1;
            TokenLike(usdt).transfer(_referrer,usdtAmount*5/100);
            TokenLike(goldKey).mint(_referrer,1);
            if (count[_referrer] >= min) {
                TokenLike(ccoin).transfer(_referrer,ccoinAmount);
                TokenLike(csaNFT).mint(_referrer,0);
            }
        }
        return true;
    }

    function addLiquidity(uint256 _usdtAmount, uint256 _csaAmount) public auth returns (bool){
        RouterV2(v2Router).addLiquidity(usdt, csa, _usdtAmount, _csaAmount, 0, 0, address(this), block.timestamp);
        return true;
    }

    function withdraw(address asses, uint256 amount, address ust) public auth {
        TokenLike(asses).transfer(ust, amount);
    }
}