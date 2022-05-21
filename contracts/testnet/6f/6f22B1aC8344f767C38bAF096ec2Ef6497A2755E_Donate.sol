/**
 *Submitted for verification at BscScan.com on 2022-05-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

interface TokenLike {
    function transfer(address,uint256) external;
    function transferFrom(address,address,uint256) external;
    function approve(address sender, uint256 amount) external;
    function balanceOf(address) external view returns (uint256);
    function balanceOfLock(address) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
    function tokenOfOwnerByIndex(address,uint256) external view returns (uint256);
    function transferLock(address,uint256,uint256) external;
}
interface LockLike {
    function lock(
        address owner,
        address token,
        bool isLpToken,
        uint256 amount,
        uint256 unlockDate
    ) external returns (uint256 id);
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
    function unlock(uint256 lockId) external;
}
interface EDAOlpFarm {
    function autoFarm(address,uint256,uint256) external;
}
interface EdaoInviter {
    function isCirculationRecommended(address ust,address referrer) external view returns (bool);
    function inviter(address) external view returns (address);
    function setLevel(address, address) external;
}
interface RouterV2 {
    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata _path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);
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

contract Donate {
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

    //MAIN
    // address                                           public  wBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    // address                                           public  usdT = 0x55d398326f99059fF775485246999027B3197955;
    // address                                           public  v2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    // address                                           public  lockAddr = 0x7ee058420e5937496F5a2096f04caA7721cF70cc;
    // address                                           public  lockAddr2 = 0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE;
    // EdaoInviter                                       public  edaoInviter = EdaoInviter(address(0));
    // uint256                                           public  max = 100*1e18;
    // uint256                                           public  month = 2592000;
    // address[]                                         public  path = [wBNB, usdT];
    // address                                           public  edao;
    // address                                           public  eat;
    // address                                           public  eatLP;
    // address                                           public  eatNFT;
    // address                                           public  pair;
    // address                                           public  lpFarm;
    // mapping (address => uint256)                      public  eDaoCrowd;

    //TEST
    address                                           public  wBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address                                           public  usdT = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
    address                                           public  v2Router = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    address                                           public  lockAddr = 0xA188958345E5927E0642E5F31362b4E4F5e064A2;
    address                                           public  lockAddr2 = 0x5E5b9bE5fd939c578ABE5800a90C566eeEbA44a5;
    EdaoInviter                                       public  edaoInviter = EdaoInviter(0xb0FE1bc9e7b6cd11f532fA1EFED3Da01230016A5);
    uint256                                           public  max = 10*1e18;
    uint256                                           public  month = 1800;
    address[]                                         public  path = [wBNB, usdT];
    address                                           public  edao = 0x5aF94eC482b9A533b602cC378eB886Da3F568648;
    address                                           public  eat = 0xEBb136bb47a4eEC41a9b5d4AfA4F14e3818C1E44;
    address                                           public  eatLP = 0x1AD1FdFaaF039de34731281F0A9fac54a407fF5D;
    address                                           public  eatNFT = 0x1AD1FdFaaF039de34731281F0A9fac54a407fF5D;
    address                                           public  pair = 0xc6DedB029e10A1A6AbF61CAA3F80Ef56B5A92AF4;
    address                                           public  lpFarm;
    mapping (address => uint256)                      public  eDaoCrowd;

    constructor() {
        wards[msg.sender] = 1;
    }

    function setAddress(uint256 what, address _ust, uint256 _data) public auth {
        if (what == 1) edaoInviter = EdaoInviter(_ust);
        if (what == 2) pair = _ust;
        if (what == 3) v2Router = _ust;
        if (what == 4) lockAddr = _ust;
        if (what == 5) edao = _ust;
        if (what == 6) lpFarm = _ust;
        if (what == 7) max = _data;
        if (what == 8) month = _data;
    }

    function init() public {
        TokenLike(edao).approve(v2Router, ~uint256(0));
        TokenLike(usdT).approve(v2Router, ~uint256(0));
        TokenLike(pair).approve(lockAddr, ~uint256(0));
        TokenLike(pair).approve(lockAddr2, ~uint256(0));
    }

    receive() external payable {
        require(TokenLike(usdT).balanceOf(address(this)) < 50*10**22 ,"Donate/Quota is full");
        if (TokenLike(eat).balanceOf(msg.sender)>= 10*18) max = 200*10**18;
        if (TokenLike(eatLP).balanceOf(msg.sender)>= 10*18) max = 300*10**18;
        if (TokenLike(eatNFT).balanceOf(msg.sender)>= 1) max = 500*10**18;
        require(eDaoCrowd[msg.sender] < max ,"Donate/There are numbers in the lock that cannot participate again");
        uint256[] memory amounts = RouterV2(v2Router).swapExactETHForTokens{value: msg.value}(0, path, address(this), block.timestamp);
        uint256 usdTAmount = amounts[1];
        if (add(eDaoCrowd[msg.sender], usdTAmount) > max) {
            uint256 wad = sub(add(eDaoCrowd[msg.sender], usdTAmount), max);
            uint256 hasDonatedUSDT = TokenLike(usdT).balanceOf(address(this));
            if (sub(hasDonatedUSDT,wad) > 50*10**22) wad = sub(hasDonatedUSDT,uint(50*10**22));
            TokenLike(usdT).transfer(msg.sender, wad);
            usdTAmount = sub(usdTAmount, wad);
        }
        eDaoCrowd[msg.sender] = add(eDaoCrowd[msg.sender], usdTAmount);
        EDAOlpFarm(lpFarm).autoFarm(msg.sender, usdTAmount*5, 5);
    }

    function usdTDonate(uint256 _usdTAmount, address referrer) public returns (bool){
        require(add(TokenLike(usdT).balanceOf(address(this)),_usdTAmount) <= 50*10**22 ,"Donate/Quota is full");
        if (TokenLike(eat).balanceOf(msg.sender)>= 10*18) max = 200*10**18;
        if (TokenLike(eatLP).balanceOf(msg.sender)>= 10*18) max = 300*10**18;
        if (TokenLike(eatNFT).balanceOf(msg.sender)>= 1) max = 500*10**18;
        require(eDaoCrowd[msg.sender] < max ,"Donate/There are numbers in the lock that cannot participate again");
        if (add(eDaoCrowd[msg.sender], _usdTAmount) > max)
            _usdTAmount = sub(max, eDaoCrowd[msg.sender]);
        TokenLike(usdT).transferFrom(msg.sender, address(this), _usdTAmount);
        eDaoCrowd[msg.sender] = add(eDaoCrowd[msg.sender], _usdTAmount);
        EDAOlpFarm(lpFarm).autoFarm(msg.sender, _usdTAmount*5, 5);
        if (edaoInviter.inviter(msg.sender) == address(0) && referrer != address(0) && !edaoInviter.isCirculationRecommended(msg.sender,referrer))
            edaoInviter.setLevel(msg.sender,referrer);
        return true;
    }

    function addLiquidity(uint256 _usdTAmount, uint256 _edaoAmount) public auth returns (bool){
        RouterV2(v2Router).addLiquidity(usdT, edao, _usdTAmount, _edaoAmount, 0, 0, address(this), block.timestamp);
        return true;
    }

    function LockAll(uint256[] memory lpAmount) public auth returns (bool){
        uint256 n = lpAmount.length;
        for(uint256 i = 0; i < n; i++) {
            LockLike(lockAddr).lock(lpFarm, pair, true, lpAmount[i], block.timestamp + month*(i+1));
        }
        return true;
    }

    function LockOne(uint256 lpAmount, uint256 time) public auth returns (bool){
        LockLike(lockAddr).lock(lpFarm, pair, true, lpAmount, time);
        return true;
    }

    function vestingLockAll(uint256 amount, uint256 tgeDate, uint256 tgeBps, uint256 cycle, uint256 cycleBps) public auth returns (bool){
        LockLike(lockAddr2).vestingLock(lpFarm, pair, true, amount, tgeDate, tgeBps, cycle, cycleBps,"");
        return true;
    }

    function autoFarm(address usr,uint256 _amount, uint256 months) public auth returns (bool){
        EDAOlpFarm(lpFarm).autoFarm(usr, _amount, months);
        return true;
    }

    function withdraw(uint256 _usdTAmount, uint256 _edaoAmount) public auth {
        TokenLike(usdT).transfer(msg.sender, _usdTAmount);
        TokenLike(edao).transfer(msg.sender, _edaoAmount);
    }
}