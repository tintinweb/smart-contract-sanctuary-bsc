/**
 *Submitted for verification at BscScan.com on 2022-07-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-01
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

interface Token {
    function balanceOf(address) external view returns (uint256);
    function approve(address,uint256) external;
    function transfer(address,uint256) external;
    function totalSupply() external view returns (uint256);
}
interface RouterV2 {
    function swapExactTokensForTokens(uint256,uint256,address[] memory,address,uint256) external returns(uint256[] memory);
}
interface IUniswapV2Pair {
    function getReserves() external view returns (uint256,uint256,uint256);
    function token0() external view returns (address);
}
contract AutoMvM {
    // --- Auth ---
    mapping (address => uint256) public wards;
    function rely(address usr) external  auth {wards[usr] = 1; }
    function deny(address usr) external  auth {wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "AutoMvM/not-authorized");
        _;
    }

    address public lp = 0xC4BfD36d6058f195dd34703c973F94afE8F5aEbd;
    address public edao = 0x99EEc9a942Dd7cFfe324f52F615c37db3696d4Ba;
    mapping (address => bool) public runner;
    address public usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public routerV2 = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    uint256 public usdtamount;
    uint256 public edaoamount;
    uint256 public ratio = 101*1E16;
    uint256 public A;
    uint256 public P1;
    uint256 public P3;
    uint256 public T1;

    constructor(){
        wards[msg.sender] = 1;
        Token(usdt).approve(address(edao), ~uint256(0));
        Token(edao).approve(address(routerV2), ~uint256(0));
        Token(usdt).approve(address(routerV2), ~uint256(0));
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
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "AutoMvM/subtraction overflow");
        return c;
    }
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "AutoMvM/addition overflow");
        return c;
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
    function div(int256 a, uint256 b) internal pure returns (int256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        int256 c = a / int256(b);
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

    function setLimit(uint256 what, uint256 _limit) public auth{
        if (what == 1) usdtamount = _limit;
        if (what == 2) edaoamount = _limit;
        if (what == 3) ratio = _limit;
    }
    function setAddress(uint256 what, address _ust) public auth {
        if (what == 1) edao = _ust;
        if (what == 2) lp = _ust;
    }
    function withdraw(address asses,uint256 wad, address usr) public auth {
        Token(asses).transfer(usr, wad);
    }
    function setAutoDeal(address usr) public auth {
        runner[usr] = true;  
    }
    function autoDeal() public returns (uint256[] memory){
        require(runner[msg.sender] == true, "AutoMvM/insufficient-sender");
        uint256 _getDeal = getDeal();
        uint256[] memory amounts;
        address[] memory path = new address[](2);
        if (_getDeal == 1) {
            path[0] = usdt;
            path[1] = edao;
            amounts = RouterV2(routerV2).swapExactTokensForTokens(usdtamount, 0,path,address(this),block.timestamp);
        } else if (_getDeal == 2) {
            path[0] = edao;
            path[1] = usdt;
            amounts = RouterV2(routerV2).swapExactTokensForTokens(edaoamount, 0,path,address(this),block.timestamp);
        }
        return amounts;
    }
    function swapUsdtForTokens(uint256 _usdtAmount) public auth {
        if (_usdtAmount == 0) return;
        uint256 usdtAmount = mul(_usdtAmount,ratio)/1E18;
        if (usdtAmount > Token(usdt).balanceOf(address(this))) usdtAmount = Token(usdt).balanceOf(address(this));
        address[] memory path = new address[](2);
        path[0] = usdt;
        path[1] = edao;
        RouterV2(routerV2).swapExactTokensForTokens(usdtAmount, 0, path, address(this), block.timestamp);
    }

    function setAisle(uint256 p1,uint256 p3, uint256 t1, uint256 rateOfincrease) public auth {
        require(p1 < p3, "AutoMvM/insufficient-parameter");
        A = rateOfincrease;
        P1 = p1;
        P3 = p3;
        T1 = t1;
    }
    function getDeal() public view returns (uint256){
        uint256 deltaT = sub(block.timestamp,T1);
        uint256 day = deltaT/86400;
        uint256 underAisle = (P1*A**day/100**day)*1e12;
        uint256 upAisle = (P3*A**day/100**day)*1e12;
        (uint256 reserve0, uint256 reserve1,) = IUniswapV2Pair(lp).getReserves();
        if (reserve0 ==0 || reserve1 ==0 ) return 0;
        address _token0 = IUniswapV2Pair(lp).token0();
        (uint256 _usdtamount, uint256 _edaoamount) = _token0 == usdt ? (reserve0,reserve1) : (reserve1,reserve0);
        uint256 price = _usdtamount*1e18/_edaoamount;
        if (price < underAisle) return 1;
        else if (price > upAisle) return 2;
        else  return 0;
    }
}