// SPDX-License-Identifier: NONE
pragma solidity 0.8.17;

contract Migrator {
    IRouterV2 immutable Router;
    IFactoryV2 immutable Factory;

    constructor(IRouterV2 _router) {
        Router = _router;
        Factory = IFactoryV2(Router.factory());
    }

    function removeAllLiquidity(address _tokenA, address _tokenB, address reciever) external {
        IPairV2 Pair = IPairV2(Factory.getPair(_tokenA, _tokenB));
        require(address(Pair) != address(0), "!Pair");

        uint256 liquidity = Pair.balanceOf(msg.sender);
        require(Pair.allowance(msg.sender, address(Router)) >= liquidity, "!Router Alw");

        Router.removeLiquidity(Pair.token0(), Pair.token1(), liquidity, 0, 0, reciever, block.timestamp);
    }
}

interface IRouterV2 {
    function factory() external pure returns (address);
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

interface IFactoryV2 {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IPairV2 {
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function token0() external view returns (address);
    function token1() external view returns (address);
}