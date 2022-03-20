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
    function timelock(address) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function ownerOf(uint _tokenid) external view returns (address);
    function tokenOfOwnerByIndex(address,uint) external view returns (uint);
    function transferlock(address,uint,uint) external;
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
interface LpFarm {
    function depositAll() external;
    function harvest() external returns (uint);
    function withdrawAll() external;
    function withdraw(uint256) external;
    function userInfo(address) external view returns(uint256,int256,uint256);
    }
contract  AddLp{

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
    mapping (address => UserInfo)                     public  userInfo;
    address                                           public  cdao;
    address                                           public  wbnb = 0x19b79b21c9178280Eb91BAF8Cfd5302a39f8E3f8;
    address                                           public  usdt = 0x5A79a689288d880Ed6bB78DAf3AC9EB537190A2F;
    address[]                                         public  path = [wbnb,usdt];
    address                                           public  v2Router = 0x296924fBA0c76821b00022f80658531e40b89cbc;
    address                                           public  pair;
    address                                           public  lpfarm = 0x39C0270f3f3a594ae726D8290da4C9B902560246;
    address                                           public  exchequer = 0xa2AcEfCC085852f2eF47275D106EF0e285e37460;

    struct UserInfo {
        uint256    usdtamount;   
        uint256    cdaoamount;
        uint256    liquidity;
    }
    function init() public{
        TokenLike(cdao).approve(v2Router,~uint(1));
        TokenLike(usdt).approve(v2Router,~uint(1));
        TokenLike(pair).approve(lpfarm,~uint(1));
    }
    function setAddress(address _cdao,address _pair) external {
        //if (token == TokenLike(address(0))) {
            cdao = _cdao;
            pair = _pair; 
        //}
    }
    receive() external payable {
        require(TokenLike(cdao).balanceOflock(msg.sender)>0,"AddLp/You can't participate without a locked balance");
        uint256[] memory amounts = Routerv2(v2Router).swapExactETHForTokens{value: msg.value}(0,path,address(this),block.timestamp);
        uint256 usdtamount = amounts[1];
        addLiquidity(usdtamount); 
    }
    function usdtadd(uint256 _usdtamount) public returns (bool){
        require(TokenLike(cdao).balanceOflock(msg.sender)>0,"AddLp/You can't participate without a locked balance");
        TokenLike(usdt).transferFrom(msg.sender,address(this),_usdtamount);
        addLiquidity(_usdtamount); 
        return true;
    }
    function addLiquidity(uint256 _usdtamount) internal {
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pair).getReserves();
        address _token0 = IUniswapV2Pair(pair).token0();
        (uint cdaoreserve, uint usdtreserve)= _token0 == cdao ? (reserve0,reserve1) : (reserve1,reserve0);
        uint256 _cdaoamount = mul(_usdtamount,cdaoreserve)/usdtreserve;        
        TokenLike(cdao).transferFrom(msg.sender,address(this),_cdaoamount);
        (uint Aamount,uint Bamount, uint _liquidity)=Routerv2(v2Router).addLiquidity(usdt,cdao,_usdtamount,_cdaoamount,0,0,address(this),block.timestamp);
        if (_usdtamount>Aamount) TokenLike(usdt).transfer(msg.sender,sub(_usdtamount,Aamount));
        if (_cdaoamount>Bamount) TokenLike(cdao).transfer(msg.sender,sub(_cdaoamount,Bamount));
        UserInfo storage user = userInfo[msg.sender]; 
        user.usdtamount = add(user.usdtamount,Aamount); 
        user.cdaoamount = add(user.cdaoamount,Bamount); 
        user.liquidity = add(user.liquidity,_liquidity);
        LpFarm(lpfarm).depositAll();
    }
    function withdrawlp() public returns (bool) {
        require(block.timestamp > TokenLike(cdao).timelock(msg.sender),"AddLp/The unlock time is not reached");
        UserInfo storage user = userInfo[msg.sender];
        require(user.liquidity > 0,"AddLp/Lp has extracted");
        uint wad = user.liquidity;
        user.liquidity = 0;
        LpFarm(lpfarm).withdraw(wad);
        uint256 _cdaoamount = LpFarm(lpfarm).harvest();
        TokenLike(pair).transfer(msg.sender,wad);
        if (_cdaoamount > 0) TokenLike(cdao).transfer(exchequer,_cdaoamount);
        return true;
    }
}