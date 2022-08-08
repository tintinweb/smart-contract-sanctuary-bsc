// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;

import "./SafeMath.sol";
import "./IUniswapV2Pair.sol";
import "./IERC20.sol";
import "./IUniswapV2Router.sol";

contract BackLp{
    using SafeMath for uint256;

    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "BackLp/not-authorized");
        _;
    }

    address eatPair = 0x560e23D93a45C96Afa3aF403d4b88408B8c0BD1f;
    address eat = 0xbC2Cf7500a4c44E5e67020069418584971F5Ce0D;
    address usdt = 0x55d398326f99059fF775485246999027B3197955;
    address eatswapRount = 0x9a5d0fB31Fb21198F3c9043f65DF761510831Fc9;

    constructor() public {
        wards[msg.sender] = 1;
    }

    function sync() public {
        try IUniswapV2Pair(eatPair).sync() {
            swapAndLiquify();
        } catch { }
    }

    function init() public {
        IERC20(eat).approve(eatswapRount, ~uint256(0));
        IERC20(usdt).approve(eatswapRount, ~uint256(0));
    }

    function swapAndLiquify() public {
        uint256 tokens = IERC20(eat).balanceOf(address(this));
        uint256 half = tokens.div(2);
        swapTokensForUsdt(half); 
        IUniswapV2Router(eatswapRount).addLiquidity(
            eat,
            usdt,
            IERC20(eat).balanceOf(address(this)),
            IERC20(usdt).balanceOf(address(this)),
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }

    function swapTokensForUsdt(uint256 tokenAmount) public {
        address[] memory path = new address[](2);
        path[0] = eat;
        path[1] = usdt;
        IUniswapV2Router(eatswapRount).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(this),
            block.timestamp
        );
    }

    function withdraw(address asses, uint256 amount, address ust) public auth {
        IERC20(asses).transfer(ust, amount);
    }
}