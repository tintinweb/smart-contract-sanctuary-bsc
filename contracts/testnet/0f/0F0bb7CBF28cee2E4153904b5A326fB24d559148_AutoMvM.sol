/**
 *Submitted for verification at BscScan.com on 2022-05-21
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
    address public edao = 0x5aF94eC482b9A533b602cC378eB886Da3F568648;
    mapping (address => bool) public runner;
    address public lp = 0xc6DedB029e10A1A6AbF61CAA3F80Ef56B5A92AF4;
    address public usdt = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
    address public routerV2 = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    uint256 public usdtamount;
    uint256 public edaoamount;
    int256 public A;
    int256 public B;
    int256 public C;
    int256 public D;

    constructor(){
        Token(usdt).approve(address(routerV2), ~uint256(0));
        Token(edao).approve(address(routerV2), ~uint256(0));
        wards[msg.sender] = 1;
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
        else edaoamount = _limit;
    }
    function withdraw(uint256 _usdtamount,uint256 _edaoamount) public auth {
        Token(usdt).transfer(msg.sender, _usdtamount);
        Token(edao).transfer(msg.sender, _edaoamount);   
    }
    function setAutoDeal(address usr) public auth {
        runner[usr] = true;  
    }
    function autoDeal()public returns (uint256[] memory){
        require(runner[msg.sender] == true, "AutoMvM/insufficient-sender");
        uint256 _getDeal = getDeal();
        uint256[] memory amounts;
        address[] memory path = new address[](2);
        if (_getDeal == 1) {
            path[0] = usdt;
            path[1] = edao;
            amounts = RouterV2(routerV2).swapExactTokensForTokens(usdtamount, 0,path,address(this),block.timestamp);
        }
        else if (_getDeal == 2) {
            path[0] = edao;
            path[1] = usdt;
            amounts = RouterV2(routerV2).swapExactTokensForTokens(edaoamount, 0,path,address(this),block.timestamp);
        }
        return amounts;
    }
    function setAisle(int256 p1, int256 p2, int256 p3, int256 p4, uint256 t1, uint256 t2) public auth returns (int256,int256,int256,int256){
        require(p1 < p3 && p2 < p4 && t1 < t2, "AutoMvM/insufficient-parameter");
        int256 below = sub(p2, p1);
        int256 upper = sub(p4, p3);
        uint256 time = sub(t2, t1);
        A = div(below, time);
        B = sub(mul(t1, A), p1);
        C = div(upper, time);
        D = sub(mul(t1, C), p3);
        return (A, B, C, D);
    }
    function getDeal() public view returns (uint256){
        uint256 underAisle = toUInt256(A * int(block.timestamp) - B);
        uint256 upAisle = toUInt256(C * int(block.timestamp) - D);
        (uint256 _usdtamount, uint256 _edaoamount,) = IUniswapV2Pair(lp).getReserves();
        uint256 price = _usdtamount*1e18/_edaoamount;
        if (price < underAisle) return 1;
        else if (price > upAisle) return 2;
        else  return 0;
    }
}