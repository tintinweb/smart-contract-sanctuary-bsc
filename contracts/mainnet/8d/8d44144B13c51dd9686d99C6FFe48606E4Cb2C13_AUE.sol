/**
 *Submitted for verification at BscScan.com on 2022-04-10
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
    function balanceOf(address) external view returns(uint256);
    function inviter(address) external view returns(address);
    function count(address) external view returns(uint256);
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
contract AUE {
    using SafeMath for uint256;
    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "AUE/not-authorized");
        _;
    }
    uint256                                           public  totalSupply = 10 ** 24;
    mapping (address => uint256)                      public  balanceOf;
    mapping (address => mapping (address => uint))    public  allowance;
    string                                            public  symbol = "AUE";
    string                                            public  name = "AUE";  
    uint256                                           public  decimals = 18; 

    mapping (address => bool)                         public  freeoftax;
    mapping (address => bool)                         public  blacklist;
    bool                                              public  tradinglock;
    address                                           public  factory = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address                                           public  v2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address                                           public  usdt = 0x55d398326f99059fF775485246999027B3197955;
    address                                           public  usdtPair;
    address                                           public  council;
    address                                           public  market;
    address                                           public  lppool;
    mapping (address => uint256)                      public  count;
    mapping (address => uint256)                      public  bnbtotal;
    mapping (address => address)                      public  inviter;

	constructor() {    
       balanceOf[msg.sender] = totalSupply;
       usdtPair = IUniswapV2Factory(factory).createPair(address(this), usdt);
       freeoftax[msg.sender] = true;
       wards[msg.sender] = 1;
    }
    function setinviter(address usr,address _inviter) external auth {
        address oldinviter = inviter[usr];
        inviter[usr] = _inviter;
        count[_inviter] +=1;
        count[oldinviter] -=1;
    }
    function setfreeAddress(address _usr) external auth {
        if (freeoftax[_usr] == false) freeoftax[_usr] = true;
        else freeoftax[_usr] = false;
    }
    function setblacklist(address _usr) external auth {
        if (blacklist[_usr] == false) blacklist[_usr] = true;
        else blacklist[_usr] = false;
    }    
    function settradinglock() external auth {
        if (tradinglock == false ) tradinglock = true;
        else  tradinglock = false;
    }
    function setmarket(address _market) external auth returns(bool) {
        market = _market;
        return true;
    }
    function setcouncil(address _council) external auth returns(bool) {
        council = _council;
        return true;
    }
    function setlppool(address _lppool) external auth returns(bool) {
        lppool = _lppool;
        return true;
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
        require(!blacklist[src] && !blacklist[dst],"AUE/blacklist");
        require(!tradinglock || freeoftax[src] || freeoftax[dst] ,"AUE/Trading is still open");
        if (src != msg.sender && allowance[src][msg.sender] != ~uint(1)) {
            require(allowance[src][msg.sender] >= wad, "AUE/insufficient-approval");
            allowance[src][msg.sender] = allowance[src][msg.sender].sub(wad);
        }
        require(balanceOf[src] >= wad, "AUE/insuff-balance");
        balanceOf[src] = balanceOf[src].sub(wad);

        if (wad >= 10**16 && inviter[dst] == address(0) && !isV2Pair(src)) {
            inviter[dst] = src;
            count[src] +=1;
        }
        if (isV2Pair(src)) {
            address _asset = getAsset(src);
            if (_asset != usdt ) {
                address[] memory path = new address[](3);
                path[0] = usdt;
                path[1] = _asset;
                path[2] = address(this);
                uint[] memory amounts = IPancakeRouter(v2Router).getAmountsIn(wad,path);
                address up = inviter[dst];
                bnbtotal[up] += amounts[0];
            }
            else {
                address[] memory path = new address[](2);
                path[0] = usdt;
                path[1] = address(this);
                uint[] memory amounts = IPancakeRouter(v2Router).getAmountsIn(wad,path);
                address up = inviter[dst];
                bnbtotal[up] += amounts[0];
            }
        }
        if (isV2Pair(src) && isBuy(src,wad) && !freeoftax[dst]) {
            referralbonuses(src,dst,wad);
            uint256 tax10 = wad/10;
            wad = wad.sub(tax10);  
        }     
        if (isV2Pair(dst) && !isAddLiquidity(dst,wad) && !freeoftax[src]) {
            referralbonuses(src,src,wad);
            uint256 tax10 = wad/10;  
            wad = wad.sub(tax10);    
        }    
        
        balanceOf[dst] = balanceOf[dst].add(wad);
        emit Transfer(src, dst, wad);
        return true;
    }

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
    function referralbonuses(address _src,address _referrer, uint256 wad) internal{
        uint256 tax1 = wad.mul(1)/100; 
        uint256 tax3 = wad.mul(3)/100;
        address direct = inviter[_referrer];
        if (direct == address(0) || !balancePrice(direct)) direct = council;
        balanceOf[direct] = balanceOf[direct].add(tax3);
        emit Transfer(_src, direct, tax3);
        balanceOf[lppool] = balanceOf[lppool].add(tax3); 
         emit Transfer(_src, lppool, tax3);
        balanceOf[council] = balanceOf[council].add(tax1); 
         emit Transfer(_src, council, tax1);
        balanceOf[market] = balanceOf[market].add(tax3);
         emit Transfer(_src, market, tax3);
    }
    function balancePrice(address usr) public view returns (bool) {
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(usdtPair).getReserves();
        address _token0 = IUniswapV2Pair(usdtPair).token0();
        (uint uereserve,uint usdtreserve)= _token0 == address(this) ? (reserve0,reserve1) : (reserve1,reserve0);
        uint256 usdtbalance = usdtreserve.mul(balanceOf[usr])/uereserve;
        if (usdtbalance >= 10**19) return true;
        else return false;
    }
    function getscore(address usr) public view returns (uint,uint) {
        return (count[usr],bnbtotal[usr]);
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