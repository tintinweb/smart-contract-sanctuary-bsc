/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;
interface TokenLike {
    function transfer(address,uint) external;
    function balanceOf(address) external view returns (uint256);
}

interface RouterLike {
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
}

interface PairLike {
    function token0() external view returns (address);
    function token1() external view returns (address);
}

contract Exchequer {

    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "Exchequer/not-authorized");
        _;
    }
    RouterLike router = RouterLike(0x9a5d0fB31Fb21198F3c9043f65DF761510831Fc9);
    mapping (address =>mapping (address => uint)) public harved;
    mapping (address =>mapping (address => uint)) public rate;
    mapping (address =>address[]) public reaper;

    constructor() {
        wards[msg.sender] = 1;
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }

    function setReaper(address lp, address usr) external auth {
        reaper[lp].push(usr);
    }

    function setRate(address lp, address usr, uint256 _rate) external auth {
        rate[lp][usr] = _rate;
    }
    
    function withdraw(address asses, uint256 amount, address ust) public auth {
        TokenLike(asses).transfer(ust, amount);
    }

    function harveToken(address lp, address usr) public returns (uint256,uint256){
        uint256 wad = getBeharved(lp,msg.sender);
        uint256 token0;
        uint256 token1;
        if (wad >0) {
            harved[lp][msg.sender] += wad;
            address tokenA = PairLike(lp).token0();
            address tokenB = PairLike(lp).token1();
            (token0,token1) = router.removeLiquidity(tokenA, tokenB, wad, 0, 0, address(this), block.timestamp);
            TokenLike(tokenA).transfer(usr,token0); 
            TokenLike(tokenB).transfer(usr,token1);
        }
        return (token0,token1);      
    }
    function harveLp(address lp, address usr) public returns (uint256){
        uint256 wad = getBeharved(lp,msg.sender);
        TokenLike(lp).transfer(usr,wad); 
        return wad;      
    }

   //Enquire the Treasury's accumulated total revenue
    function getTotal(address lp) public  view returns (uint256){
        uint256 total = TokenLike(lp).balanceOf(address(this));
        uint256 n = reaper[lp].length;
        for(uint i=0;i < n; ++i) {
            address usr = reaper[lp][i];
            uint256 _harved = harved[lp][usr];
            total += _harved;
        }
        return total;
    }

    //Query the residual revenue of the LP pool
    function getBeharved(address lp, address usr) public view returns (uint256){
        uint256 total = getTotal(lp);
        uint256 _rate = rate[lp][usr];
        uint256 _harved = harved[lp][usr];
        return sub(total*_rate/10000,_harved);
    }

    function getRate(address lp) public  view returns (uint256,address[] memory,uint256[] memory){
        uint256 total;
        uint256 n = reaper[lp].length;
        address[] memory reapers = new address[](n);
        uint256[] memory rates = new uint256[](n);
        for(uint i=0;i < n; ++i) {
            address usr = reaper[lp][i];
            uint256 _rate = rate[lp][usr];
            reapers[i] = usr;
            rates[i] = _rate;
            total += _rate;
        }
        return (total,reapers,rates);
    }

 }