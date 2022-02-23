/**
 *Submitted for verification at BscScan.com on 2022-02-23
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.11;



//获取交易对的LP地址
interface IBaseV1Factory {
    function allPairsLength() external view returns (uint);
    function isPair(address pair) external view returns (bool);
    function pairCodeHash() external pure returns (bytes32);
    function getPair(address tokenA, address token, bool stable) external view returns (address);  
}

//获取存储量
interface IBaseV1Pair {      
    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
    function getAmountOut(uint, address) external view returns (uint);
}

//erc余额查询
interface erc20 {
    function totalSupply() external view returns (uint256);
   // function transfer(address recipient, uint amount) external returns (bool);
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);
    function balanceOf(address) external view returns (uint);
   // function transferFrom(address sender, address recipient, uint amount) external returns (bool);
   // function approve(address spender, uint value) external returns (bool);
}
// address _pair = IBaseV1Factory(factory).getPair(tokenA, tokenB, stable);
//  (uint reserve0, uint reserve1,) = IBaseV1Pair(pairFor(tokenA, tokenB, stable)).getReserves();
contract LiquidityAmount{
//交易对
 struct PairRoute {
        address from;
        address to;
        bool stable;
        address  addrBalance;     
    }

   //返回某地址下对应lp的余额
   struct PairAmount {
       //某地址添加tokenA的数量
        uint256 amountFrom;
        //某地址添加tokenB的数量
        uint256 amountTo;
        //LP地址下tokenA的总量
        uint256 totalFrom;
        //Lp地址下tokenB的总量
        uint256 totalTo;       
    } 

//  IBaseV1Factory地址
 address public immutable baseV1Factory;
//  address public immutable baseV1Rout;

    constructor(address _factory) {
        baseV1Factory = _factory;  
        // baseV1Rout = _rout;          
    }

    function getLpTokensAmount(PairRoute[] memory routes) public pure returns (PairAmount[] memory amounts)
    {
         require(routes.length >= 1, 'BaseV1Router: INVALID_PATH');
         amounts = new PairAmount[](routes.length);
         amounts[0].amountFrom=0;
         amounts[0].amountTo=0;
         amounts[0].totalFrom=0;
         amounts[0].totalTo=0;
         return amounts;
      /*
         uint256  _liquidity = 0;
         address _pair=address(0);
         for (uint i = 0; i < routes.length; i++) {
              _pair = IBaseV1Factory(baseV1Factory).getPair(routes[i].from,routes[i].to,routes[i].stable);
              if (_pair == address(0) || routes[i].from == address(0)|| routes[i].to == address(0)||routes[i].addrBalance == address(0)|| routes[i].from == routes[i].to ) {
                 amounts[i].amountFrom=0;
                 amounts[i].amountTo=0;
                 amounts[i].totalFrom=0;
                 amounts[i].totalTo=0;
              }else
              {
                 _liquidity =erc20(_pair).balanceOf(routes[i].addrBalance);
                 (uint256 reserveA, uint256 reserveB) = getReserves(routes[i].from, routes[i].to, routes[i].stable);
                 uint256 _totalSupply = erc20(_pair).totalSupply();
                 amounts[i].amountFrom=_liquidity * reserveA / _totalSupply;
                 amounts[i].amountTo=_liquidity * reserveB / _totalSupply;
                 amounts[i].totalFrom=reserveA;
                 amounts[i].totalTo=reserveB;

              }
         } */

       

        
    }

    function sortTokens(address tokenA, address tokenB) public pure returns (address token0, address token1) {      
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
      
    }

    function getReserves(address tokenA, address tokenB, bool stable) public view returns (uint256 reserveA, uint256 reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        address pair =IBaseV1Factory(baseV1Factory).getPair(tokenA,tokenB,stable);
        (uint256 reserve0, uint256 reserve1,) = IBaseV1Pair(pair).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

}