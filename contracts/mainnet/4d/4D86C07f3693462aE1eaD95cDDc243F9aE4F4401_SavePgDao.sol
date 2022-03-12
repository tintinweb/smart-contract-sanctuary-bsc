/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

// SPDX-License-Identifier: MIT
pragma solidity >0.5.7;

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
    function getPair(address,address) external view returns (address);    
}
interface IUniswapV2Pair {
    function getReserves() external view returns (uint,uint,uint);
    function token0() external view returns (address);
    function token1() external view returns (address);
}
interface IPancakeRouter {
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountsIn(uint amountOut, address[] calldata path)
        external
        view
        returns (uint[] memory amounts);
}
interface TokenLike {
    function award(address buyer, uint256 wad) external;
    function balanceOf(address) external view returns(uint256);
}
library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

 
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }


    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function sqrt(uint x) internal pure returns (uint) {
        uint z = (x+1)/2;
        uint y = x;
        while (z<y) {
            y =z;
            z = (x/z + z)/2;
        }
        return y;
    }
}
contract SavePgDao {
    using SafeMath for uint256;

    uint256                                           public  totalSupply = 1000 * 10 ** 22;
    mapping (address => uint256)                      public  balanceOf;
    mapping (address => mapping (address => uint))    public  allowance;
    string                                            public  symbol = "SPD";
    string                                            public  name = "savepgdao.com";  
    uint256                                           public  decimals = 18; 

    mapping (address => address)                      public  inviter;
    mapping (address => bool)                         public  freeoftax;
    mapping (address => bool)                         public  referral;
    mapping (address => uint256)                      public  openingPrice;
    address                                           public  factory = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address                                           public  v2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address                                           public  usdt = 0x55d398326f99059fF775485246999027B3197955;
    address                                           public  wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address                                           public  fist = 0xC9882dEF23bc42D53895b8361D0b1EDC7570Bc6A;
    address                                           public  usdtPair;
    address                                           public  wbnbPair;
    address                                           public  fistPair;
    address                                           public  exchequer = 0x76f215Dc27A1E843592F58059551b4CA5c663AA6;
    address                                           public  child = 0xCFF3124F9Ed6b0C826b19139F5aCbaAF5c29F7cF;
    address                                           public  fundpool = 0xdFc3Ad5622c4B389B3A9B8CAb02A6f2037F761e3;
    uint256                                           public  taxrate = 9;
    uint256                                           public  openingTime;


	constructor() {
       openingTime =  1647014400;
       balanceOf[msg.sender] = totalSupply;
       usdtPair = IUniswapV2Factory(factory).createPair(address(this), usdt);
       referral[usdtPair] = true;
       wbnbPair = IUniswapV2Factory(factory).createPair(address(this), wbnb);
       referral[wbnbPair] = true;
       fistPair = IUniswapV2Factory(factory).createPair(address(this), fist);
       referral[fistPair] = true;
       freeoftax[msg.sender] = true;
       freeoftax[fundpool] = true;
    }

	function approve(address guy) external returns (bool) {
        return approve(guy, ~uint(1));
    }

    function approve(address guy, uint wad) public  returns (bool){
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint wad) external  returns (bool){
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public  returns (bool)
    {
        uint wadin = wad;
        uint wadout = wad;
        //Bind the recommendation relationship with the first transfer
        if (balanceOf[dst] == 0 && inviter[dst] == address(0)) inviter[dst] = src;

        //The first trading price of the day is set to the opening price
        if (isV2Pair(src)) {
            if (block.timestamp > openingTime + 86400) setOpen(src);
            //Only certain pool buys are rewarded
            if (isBuy(src,wad) && referral[src]) TokenLike(child).award(dst,wad);
            //removeLiquidity are subject to tax unless addressed tax-free
            if (!isBuy(src,wad) && !freeoftax[dst]) {
                uint256 tax = wad.mul(taxrate)/100; 
                balanceOf[exchequer] = balanceOf[exchequer].add(tax);      
                wadout = wad.sub(tax);   
            }
        }     
        if (isV2Pair(dst)) {
            if (block.timestamp > openingTime + 86400) setOpen(dst); 
            //Judge whether to drop limit
            if (!isAddLiquidity(dst,wad)) require(!limitdown(dst,wad), "SavePgDao/Can't trade after the limit"); 
            //Sales are subject to tax unless addressed tax-free
            if (!isAddLiquidity(dst,wad) && !freeoftax[src]){
                uint256 tax = wad.mul(taxrate)/100; 
                balanceOf[exchequer] = balanceOf[exchequer].add(tax);      
                wadin = wad.add(tax);    
            }  
        } 

        if (src != msg.sender && allowance[src][msg.sender] != ~uint(1)) {
            require(allowance[src][msg.sender] >= wadin, "SavePgDao/insufficient-approval");
            allowance[src][msg.sender] = allowance[src][msg.sender].sub(wadin);
        }
        require(balanceOf[src] >= wad, "SavePgDao/insuff-balance");
        balanceOf[src] = balanceOf[src].sub(wadin);
        balanceOf[dst] = balanceOf[dst].add(wadout);
        emit Transfer(src, dst, wad);
        return true;
    }
    //Set the opening price
    function setOpen(address _pair) internal {
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(_pair).getReserves();
        if (reserve0 ==0 || reserve1 ==0 ) return;
        address _token0 = IUniswapV2Pair(_pair).token0();
        (uint spdamount, uint assetamount)= _token0 == address(this) ? (reserve0,reserve1) : (reserve1,reserve0);
        openingPrice[_pair] = assetamount*10**24/spdamount;
        openingTime = openingTime + 86400;
    }
    //Determine whether the Pair pool will be sold below the upper limit
    function limitdown(address _pair,uint _wad) public view returns (bool){
        address _asset = getAsset(_pair);
        uint balance0 = balanceOf[_pair];
        uint balance1 = TokenLike(_asset).balanceOf(_pair);
        uint balance1Later = balance0.mul(balance1)/balance0.add(_wad);
        uint256 afterPrice = balance1Later*10**24/balance0.add(_wad);
        if (afterPrice < openingPrice[_pair]*7/10) return true;
        else return false;
    }
    //Find the maximum amount of a pair pool that does not exceed the upper limit
    function maxsale(address _pair) public view returns (uint){
        address _asset = getAsset(_pair);
        uint balance0 = balanceOf[_pair];
        uint balance1 = TokenLike(_asset).balanceOf(_pair);
        uint klast = balance0.mul(balance1);
        uint _sqrt = klast/(openingPrice[_pair]*7/10);
        uint _sqrtlast = (_sqrt/10**8).sqrt();
        uint wad = _sqrtlast*10**16 - balance0;
        return wad;
    }
    //Find a pair address in addition to the SPD token
    function getAsset(address _pair) public view returns (address){
        address _token0 = IUniswapV2Pair(_pair).token0();
        address _token1 = IUniswapV2Pair(_pair).token1();
        address asset = _token0 == address(this) ? _token1 : _token0;
        return asset;
    }
    //Check whether an address is PancakePair 
    function isV2Pair(address _pair) public view returns (bool) {
        bytes32 accountHash;
        bytes32 codeHash;  
        address pair = usdtPair;  
        assembly { accountHash := extcodehash(pair)}
        assembly { codeHash := extcodehash(_pair) }
        return (codeHash == accountHash);
    }
    //Decide whether to add liquidity or sell,
    function isAddLiquidity(address _pair,uint256 wad) internal view returns (bool) {
        address _asset = getAsset(_pair);
        uint balance1 = TokenLike(_asset).balanceOf(_pair);
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(_pair).getReserves();
        if (reserve0 ==0 || reserve1 ==0 ) return true;
        address _token0 = IUniswapV2Pair(_pair).token0();
        (uint spdreserve, uint assetreserve)= _token0 == address(this) ? (reserve0,reserve1) : (reserve1,reserve0);
        uint assetamount = IPancakeRouter(v2Router).quote(wad, spdreserve, assetreserve);
        return (balance1 > assetreserve + assetamount/2 );
     }
    //Determine whether you are buying or remove liquidity
    function isBuy(address _pair,uint256 wad) internal view returns (bool) {
        if (!isV2Pair(_pair)) return false;
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(_pair).getReserves();
        address _token0 = IUniswapV2Pair(_pair).token0();
        (,uint assetreserve)= _token0 == address(this) ? (reserve0,reserve1) : (reserve1,reserve0);
        address _asset = getAsset(_pair);
        address[] memory path = new address[](2);
        path[0] = _asset;
        path[1] = address(this);
        uint[] memory amounts = IPancakeRouter(v2Router).getAmountsIn(wad,path);
        uint balance1 = TokenLike(_asset).balanceOf(_pair);
        return (balance1 > assetreserve + amounts[0]/2);
    }
	event Transfer(
		address indexed _from,
		address indexed _to,
		uint _value
		);
	event Approval(
		address indexed _owner,
		address indexed _spender,
		uint _value
		);
}