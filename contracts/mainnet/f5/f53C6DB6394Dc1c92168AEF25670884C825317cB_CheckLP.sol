/**
 *Submitted for verification at BscScan.com on 2022-09-27
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

contract CheckLP {

  constructor() {}


  function isContract(address account) internal view returns (bool) {
    uint256 size;
    assembly {
      size := extcodesize(account)
    }
    return size > 0;
  }

  // 验证地址是否是LP
  function checkLP(address factory, address lp) external view returns (bool check, address token0, address token1) {
    check = false;
    token0 = address(0);
    token1 = address(0);

    // 0地址验证
    if(factory == address(0)) return (check, token0, token1);
    if(lp == address(0)) return (check, token0, token1);
    
    // 合约验证
    if(!isContract(factory)) return (check, token0, token1);
    if(!isContract(lp)) return (check, token0, token1);

    // LP验证
    try IUniswapV2Pair(lp).token0() {} catch { return (check, token0, token1); }
    try IUniswapV2Pair(lp).token1() {} catch { return (check, token0, token1); }
    token0 = IUniswapV2Pair(lp).token0();
    token1 = IUniswapV2Pair(lp).token1();
    if(token0 == address(0) || token1 == address(0)) return (check, address(0), address(0));

    // 工厂合约再次验证
    try IUniswapV2Factory(factory).getPair(token0, token1) {} catch { return (check, token0, token1); }
    address lp2 = IUniswapV2Factory(factory).getPair(token0, token1);
    if(lp2 == address(0)) return (check, token0, token1);
    if(lp2 != lp) return (check, token0, token1);

    return (true, token0, token1);
  }


}