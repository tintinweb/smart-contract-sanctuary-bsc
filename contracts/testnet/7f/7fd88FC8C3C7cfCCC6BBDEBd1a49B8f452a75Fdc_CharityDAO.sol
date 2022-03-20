/**
 *Submitted for verification at BscScan.com on 2022-03-19
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
contract CharityDAO {
    using SafeMath for uint256;

    uint256                                           public  totalSupply = 210 * 10 ** 22;
    mapping (address => uint256)                      public  balanceOf;
    mapping (address => mapping (address => uint))    public  allowance;
    string                                            public  symbol = "CDAO";
    string                                            public  name = "charitydao.cc";  
    uint256                                           public  decimals = 18; 

    mapping (address => uint256)                      public  balanceOflock;
    mapping (address => uint256)                      public  timelock;
    mapping (address => address)                      public  inviter;
    mapping (address => bool)                         public  freeoftax;
    mapping (address => bool)                         public  referral;
    mapping (address => uint256)                      public  openingPrice;
    mapping (address => uint256)                      public  openingTime;
    address                                           public  factory = 0xcdb191812abC0304e28d271dE49AFc72422F220a;
    address                                           public  v2Router = 0x296924fBA0c76821b00022f80658531e40b89cbc;
    address                                           public  usdt = 0x5A79a689288d880Ed6bB78DAf3AC9EB537190A2F;
    address                                           public  wbnb = 0x19b79b21c9178280Eb91BAF8Cfd5302a39f8E3f8;
    address                                           public  usdtPair;
    address                                           public  wbnbPair;
    address                                           public  exchequer = 0xa2AcEfCC085852f2eF47275D106EF0e285e37460;
    address                                           public  child = 0xBEE8Ce01e7EB2F4d081aBa993025fc89B0eC5258;
    address                                           public  fundpool = 0x1a6B59B959049Fc731bBa2da4a005B1A78Af0D12;
    address                                           public  donate = 0xc01e69C7C2A76fEE634eB1D56c18eF757cdeb03e;
    address                                           public  addlp = 0x61F8d9428538FB355fd6c7D3aD6F800F521c2D06;
    uint256                                           public  taxrate = 9;


	constructor() {    
       balanceOf[msg.sender] = totalSupply;
       usdtPair = IUniswapV2Factory(factory).createPair(address(this), usdt);
       referral[usdtPair] = true;
       openingTime[usdtPair] = block.timestamp - 86400;//正式版改成具体时间
       wbnbPair = IUniswapV2Factory(factory).createPair(address(this), wbnb);
       referral[wbnbPair] = true;
       freeoftax[msg.sender] = true;
       freeoftax[donate] = true;
       freeoftax[addlp] = true;
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
            if (block.timestamp > openingTime[src] + 86400) setOpen(src);
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
            if (block.timestamp > openingTime[dst] + 86400) setOpen(dst); 
            //Judge whether to drop limit
            if (!isAddLiquidity(dst,wad)) require(!limitdown(dst,wad), "CDAO/Can't trade after the limit"); 
            //Sales are subject to tax unless addressed tax-free
            if (!isAddLiquidity(dst,wad) && !freeoftax[src]){
                uint256 tax = wad.mul(taxrate)/100; 
                balanceOf[exchequer] = balanceOf[exchequer].add(tax);      
                wadin = wad.add(tax);    
            }  
        } 
        //Income tax is deducted from the account participating in the donation when due
        if (block.timestamp > timelock[src] && balanceOflock[src] > 0) {
            uint cdaoamount;
            uint usdtamount;
            {
            (uint reserve0, uint reserve1,) = IUniswapV2Pair(usdtPair).getReserves();
            address _token0 = IUniswapV2Pair(usdtPair).token0();
            (cdaoamount,usdtamount)= _token0 == address(this) ? (reserve0,reserve1) : (reserve1,reserve0);
            }
            uint256 _wadlock = balanceOflock[src];
            balanceOflock[src] = 0;
            uint256 _usdtamount = _wadlock.mul(usdtamount).div(cdaoamount);
            uint256 _tax;
            if (_usdtamount > _wadlock) _tax = (_usdtamount.sub(_wadlock).mul(2))/10;
            balanceOf[src] = balanceOf[src].sub(_tax);
            balanceOf[exchequer] = balanceOf[exchequer].add(_tax);
        }
        //The target address is a special address, and the number of transfers is subtracted from the number of lockers  
        if (addlp == dst) {
            if (balanceOflock[src] <= wad) balanceOflock[src] =0;
            else balanceOflock[src] = balanceOflock[src].sub(wad);
        }

        uint256 amountlock = balanceOflock[src];
 
        if (src != msg.sender && allowance[src][msg.sender] != ~uint(1)) {
            require(allowance[src][msg.sender] >= wadin, "CDAO/insufficient-approval");
            allowance[src][msg.sender] = allowance[src][msg.sender].sub(wadin);
        }
        require(balanceOf[src].sub(amountlock) >= wadin, "CDAO/insuff-balance");
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
        if (openingTime[_pair] != 0) openingTime[_pair] = openingTime[_pair] + 86400;
        else openingTime[_pair] = openingTime[usdtPair];
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
    //The donation contract sets the number and duration of lock-in
    function transferlock(address _src,uint256 _wad,uint256 _locktime) public {
        require(msg.sender == donate, "CDAO/not is donate contract");
        balanceOflock[_src] = _wad;
        timelock[_src] = _locktime; 
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