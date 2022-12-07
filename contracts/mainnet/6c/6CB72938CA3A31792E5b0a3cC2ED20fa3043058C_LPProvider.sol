//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./IUniswapV2Router02.sol";

interface IDaylight {
    function burn(uint256 amount) external returns (bool);
}

contract LPProvider {

    address public constant daylight = 0x62529D7dE8293217C8F74d60c8C0F6481DE47f0E;
    IUniswapV2Router02 public constant router = IUniswapV2Router02(0xb34DA672837aFe372eceF419b25a357A36f59F6f);

    function pair(uint256 amountDaylight, address token1, uint256 amountToken1) external {

        _transferIn(daylight, amountDaylight);
        _transferIn(token1, amountToken1);

        IDaylight(daylight).burn(IERC20(daylight).balanceOf(address(this)) / 20);

        uint256 daylightBalance = IERC20(daylight).balanceOf(address(this));
        uint256 tokenBalance = IERC20(token1).balanceOf(address(this));

        IERC20(daylight).approve(address(router), daylightBalance);
        IERC20(token1).approve(address(router), tokenBalance);

        router.addLiquidity(daylight, token1, daylightBalance, tokenBalance, 1, 1, msg.sender, block.timestamp + 100);

        daylightBalance = IERC20(daylight).balanceOf(address(this));
        tokenBalance = IERC20(token1).balanceOf(address(this));

        if (daylightBalance > 0) {
            IERC20(daylight).transfer(msg.sender, daylightBalance);
        }

        if (tokenBalance > 0) {
            IERC20(token1).transfer(msg.sender, tokenBalance);
        }
    }

    function withdraw(address token) external {
        IERC20(token).transfer(daylight, IERC20(token).balanceOf(address(this)));
    }

    function withdrawBNB() external {
        (bool s,) = payable(daylight).call{value: address(this).balance}("");
        require(s);
    }

    function _transferIn(address token, uint amount) internal {
        require(
            IERC20(token).allowance(msg.sender, address(this)) >= amount,
            'Insufficient Allowance'
        );
        require(
            IERC20(token).transferFrom(msg.sender, address(this), amount),
            'Transfer From Fail'
        );
    }
}