/**
 *Submitted for verification at BscScan.com on 2022-03-19
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.7;

interface TokenLike {
    function transfer(address,uint) external;
    function transferFrom(address,address,uint) external;
    function approve(address guy, uint wad) external;
    function balanceOf(address) external view returns (uint256);
    function balanceOflock(address) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function ownerOf(uint _tokenid) external view returns (address);
    function tokenOfOwnerByIndex(address,uint) external view returns (uint);
    function transferlock(address,uint,uint) external;
}
interface Locklike {
  function lock(
    address owner,
    address token,
    bool isLpToken,
    uint256 amount,
    uint256 unlockDate
  ) external returns (uint256 id);
  function unlock(uint256 lockId) external; 
}
interface IUniswapV2Pair {
    function getReserves() external view returns (uint,uint,uint);
    function token0() external view returns (address);
    function token1() external view returns (address);
}
interface Routerv2 {
    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata _path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
}
contract  Donate{
        // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "Donate/not-authorized");
        _;
    }
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
    mapping (uint =>mapping (uint => bool))           public  voted;
    mapping (uint256 => SchemeInfo)                   public  schemeInfo;
    address                                           public  cdao;
    address                                           public  wbnb = 0x19b79b21c9178280Eb91BAF8Cfd5302a39f8E3f8;
    address                                           public  usdt = 0x5A79a689288d880Ed6bB78DAf3AC9EB537190A2F;
    uint256                                           public  max = 10*21;
    uint256                                           public  order;
    uint256                                           public  totalsupply;
    address[]                                         public  path = [wbnb,usdt];
    address                                           public  v2Router = 0x296924fBA0c76821b00022f80658531e40b89cbc;
    address                                           public  pair;
    address                                           public  Charitynft = 0xC91CD722B2728384D0C23b40CE84b768B11B0b64;
    address                                           public  lock = 0xf8A9494F95A0A0C9dD3187c25B4D1132BdF445cA;
    uint256  public a; //正式版不要
    uint256  public b; //正式版不要
    struct SchemeInfo {
        address    targetaddress;
        uint256    liquidity;   
        uint256    poll;
        uint256    endtime;
    }
    constructor() {
        wards[msg.sender] = 1;
    }
    function setAddress(address _cdao,address _pair) external {
        //if (token == TokenLike(address(0))) {
            cdao = _cdao;
            pair = _pair; 
        //}
    }
    //正式版不要
    function settime(uint _a,uint _b) external {
        //if (token == TokenLike(address(0))) {
            a = _a;
            b = _b; 
        //}
    }
    function init() public{
        TokenLike(cdao).approve(v2Router,~uint(1));
        TokenLike(usdt).approve(v2Router,~uint(1));
        TokenLike(pair).approve(lock,~uint(1));
    }
    receive() external payable {
        require(TokenLike(cdao).balanceOflock(msg.sender)==0,"Donate/The number of USDT cannot exceed the maximum value");
        uint256[] memory amounts = Routerv2(v2Router).swapExactETHForTokens{value: msg.value}(0,path,address(this),block.timestamp);
        uint256 usdtamount = amounts[1];
        if (usdtamount > max) {
            TokenLike(usdt).transfer(msg.sender,sub(usdtamount,max)); 
            usdtamount = max;
        }
        donate(usdtamount); 
    }
    function usdtdonate(uint256 _usdtamount) public returns (bool){
        require(TokenLike(cdao).balanceOflock(msg.sender)==0,"Donate/The number of USDT cannot exceed the maximum value");
        require(_usdtamount <= max,"Donate/The number of USDT cannot exceed the maximum value");
        TokenLike(usdt).transferFrom(msg.sender,address(this),_usdtamount);
        donate(_usdtamount); 
        return true;
    }
    function donate(uint256 _usdtamount) internal returns (bool){
        TokenLike(cdao).transfer(msg.sender,_usdtamount);
        TokenLike(cdao).transferlock(msg.sender,_usdtamount,block.timestamp+a);//正式版锁仓时间7776000
        uint256 usdtin =_usdtamount*7/10;
        uint256 cdaoin;
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pair).getReserves();
        if (reserve0 ==0 || reserve1 ==0 ) cdaoin = usdtin;
        else {
            address _token0 = IUniswapV2Pair(pair).token0();
            (uint cdaoreserve, uint usdtreserve)= _token0 == cdao ? (reserve0,reserve1) : (reserve1,reserve0);
            cdaoin = mul(usdtin,cdaoreserve)/usdtreserve;
        }
        (, , uint liquidity)=Routerv2(v2Router).addLiquidity(usdt,cdao,usdtin,cdaoin,0,0,address(this),block.timestamp);
        totalsupply = add(totalsupply,liquidity);
        Locklike(lock).lock(address(this),pair,true,liquidity,block.timestamp+b);//正式版锁仓时间31536000
        return true;
    }
    function unlock(uint256 id) public returns (bool){
        require(TokenLike(Charitynft).balanceOf(msg.sender) >=1,"Donate/unlock don't have NFT");
        Locklike(lock).unlock(id);
        return true;
    }
    function allocation(address urt, uint256  _liquidity) public {  
        require(TokenLike(Charitynft).totalSupply() == 10,"Donate/NFT quantity does not meet legal standard");//正式版10--210
        require(TokenLike(Charitynft).balanceOf(msg.sender) >=1,"Donate/allocation don't have NFT"); 
        order +=1; 
        SchemeInfo storage scheme = schemeInfo[order];
        scheme.targetaddress  = urt;
        scheme.liquidity  = _liquidity;
        scheme.endtime  = block.timestamp + 3600; //正式版2592000
    }

    function vote(uint256 _order,uint256  _tokenid) public {      
        require(msg.sender == TokenLike(Charitynft).ownerOf(_tokenid),"Donate/The voters are not the owners of NFT"); 
        require(!voted[order][_tokenid],"Donate/An NFT can only vote once");
        SchemeInfo storage scheme = schemeInfo[_order];
        require(block.timestamp < scheme.endtime,"Donate/Voting hours have closed");
        voted[_order][_tokenid] =true;    
        scheme.poll += 1;
        if (scheme.poll>=7) { //正式版140
            scheme.endtime = block.timestamp;
            totalsupply = sub(totalsupply,scheme.liquidity);
            TokenLike(pair).transfer(scheme.targetaddress,scheme.liquidity);
        }
     }
    function voteAuto(uint256 _order) public {      
        require(TokenLike(Charitynft).balanceOf(msg.sender) >=1,"Donate/Voters don't have NFT"); 
        uint256  _tokenid = TokenLike(Charitynft).tokenOfOwnerByIndex(msg.sender,0);
        vote(_order,_tokenid);
     }
    function withdraw() public auth returns (bool) {
        uint wad = TokenLike(usdt).balanceOf(address(this));
        TokenLike(usdt).transfer(msg.sender,wad);
        return true;
    }
}