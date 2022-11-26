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
    address public constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    function pair(uint256 amountDaylight, uint256 amountBUSD) external {

        _transferIn(BUSD, amountBUSD);
        _transferIn(daylight, amountDaylight);

        IDaylight(daylight).burn(IERC20(daylight).balanceOf(address(this)) / 20);

        uint256 daylightBalance = IERC20(daylight).balanceOf(address(this));
        uint256 busdBalance = IERC20(BUSD).balanceOf(address(this));

        IERC20(daylight).approve(address(router), daylightBalance);
        IERC20(BUSD).approve(address(router), busdBalance);

        router.addLiquidity(daylight, BUSD, daylightBalance, busdBalance, 1, 1, msg.sender, block.timestamp + 100);

        daylightBalance = IERC20(daylight).balanceOf(address(this));
        busdBalance = IERC20(BUSD).balanceOf(address(this));

        if (daylightBalance > 0) {
            IERC20(daylight).transfer(msg.sender, daylightBalance);
        }

        if (busdBalance > 0) {
            IERC20(BUSD).transfer(msg.sender, busdBalance);
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