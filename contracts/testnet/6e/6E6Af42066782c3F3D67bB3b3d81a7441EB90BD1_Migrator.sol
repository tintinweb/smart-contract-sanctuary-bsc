// SPDX-License-Identifier: NONE
pragma solidity 0.8.17;

contract Migrator {
    IERC20 public immutable HBCT;
    IERC20 public immutable BUSD;

    IRouterV2 public immutable Router;
    IFactoryV2 public immutable Factory;
    ISystem_Core public immutable System;

    constructor(address _System, IRouterV2 _router, address _HBCT, address _BUSD) {
        require(isContract(_System), "Sys not Cntr");
        System = ISystem_Core(_System);
        require(System.IS_ADMIN(msg.sender), "Not Sys Admin");

        HBCT = IERC20(_HBCT);
        BUSD = IERC20(_BUSD);
        Router = _router;
        Factory = IFactoryV2(Router.factory());
    }

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function migrateLiquidity() external {
        require(System.IS_ADMIN(msg.sender), "Not Sys Admin");

        IERC20 Pair = IERC20(Factory.getPair(address(HBCT), address(BUSD)));
        require(address(Pair) != address(0), "!Pair");

        uint256 liquidity = Pair.balanceOf(msg.sender);
        Pair.approve(address(Router), liquidity);
        require(Pair.allowance(address(this), address(Router)) >= liquidity, "!Router Alw");
        require(Pair.allowance(msg.sender, address(this)) >= liquidity, "!Migrator Alw");

        bool transfer = Pair.transferFrom(msg.sender, address(this), liquidity);
        require(transfer, "!Transfer LP");

        Router.removeLiquidity(address(HBCT), address(BUSD), liquidity, 0, 0, address(this), block.timestamp);

        uint256 balHBCT = HBCT.balanceOf(address(this));
        bool trHBCT = HBCT.transfer(msg.sender, balHBCT);
        require(trHBCT, "!Transfer HBCT");

        uint256 balBUSD = BUSD.balanceOf(address(this));
        bool trBUSD = BUSD.transfer(address(System), balBUSD);
        require(trBUSD, "!Transfer BUSD");
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

interface IERC20 {
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

interface ISystem_Core {
    function IS_ADMIN(address wallet) external view returns (bool);
}