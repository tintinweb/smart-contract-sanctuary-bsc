//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./IUniswapV2Router02.sol";

interface IDaylight is IERC20 {
    function burn(uint256 amount) external;
}

interface IApollo is IERC20 {
    function sell(uint256 tokenAmount) external returns (uint256);
}

contract FeeReceiver {

    // LP address
    address public constant WETHLP = 0xB4F7DE1D7511A48323f34Af2Bb114E2cb34cBFe4;
    address public constant DAYLLP = 0xA5d078Ac7ddf5aDa811af4F72c7534BBA00351D9;

    // constants
    address public constant router = 0xb34DA672837aFe372eceF419b25a357A36f59F6f;
    IDaylight public constant daylight = IDaylight(0x62529D7dE8293217C8F74d60c8C0F6481DE47f0E);
    IApollo public constant apollo = IApollo(0x32a05625d2A25054479d0c5d661857147c34483D);
    address public constant treasury = 0x4A3Be597418a12411F31C94cc7bCAD136Af2E242;
    address public constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;


    function trigger() external {

        // fetch LP Balance
        uint bal = IERC20(WETHLP).balanceOf(address(this));
        if (bal > 0) {

            // approve LP for router
            IERC20(WETHLP).approve(router, bal);

            // remove LP
            IUniswapV2Router02(router).removeLiquidityETHSupportingFeeOnTransferTokens(
                address(apollo), bal, 1, 1, address(this), block.timestamp + 100
            );

            // send BNB to treasury
            (bool s,) = payable(treasury).call{value: address(this).balance}("");
            require(s);

            // sell Apollo received
            apollo.sell(apollo.balanceOf(address(this)));

            // buy back and burn DAYL with BUSD balance
            uint busdBal = IERC20(BUSD).balanceOf(address(this));

            // approve router to take BUSD Balance
            IERC20(BUSD).approve(router, busdBal);

            // define swap path
            address[] memory path = new address[](2);
            path[0] = BUSD;
            path[1] = address(daylight);

            // swap BUSD for daylight
            IUniswapV2Router02(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
                busdBal,
                1,
                path,
                address(this),
                block.timestamp + 10
            );

            // burn daylight
            daylight.burn(daylight.balanceOf(address(this)));

            // save memory
            delete path;


        }

        // fetch LP Balance
        uint bal2 = IERC20(DAYLLP).balanceOf(address(this));
        if (bal2 > 0) {

            // approve LP for router
            IERC20(DAYLLP).approve(router, bal2);

            // remove LP
            IUniswapV2Router02(router).removeLiquidity(
                address(apollo),
                address(daylight),
                bal2,
                1,
                1,
                address(this),
                block.timestamp + 100
            );

            // send DAYL to treasury
            daylight.transfer(treasury, daylight.balanceOf(address(this)));

            // sell Apollo received
            apollo.sell(apollo.balanceOf(address(this)));

            // buy back and burn DAYL with BUSD balance
            uint busdBal = IERC20(BUSD).balanceOf(address(this));

            // approve router to take BUSD Balance
            IERC20(BUSD).approve(router, busdBal);

            // define swap path
            address[] memory path = new address[](2);
            path[0] = BUSD;
            path[1] = address(daylight);

            // swap BUSD for daylight
            IUniswapV2Router02(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
                busdBal,
                1,
                path,
                address(this),
                block.timestamp + 10
            );

            // burn daylight
            daylight.burn(daylight.balanceOf(address(this)));

            // save memory
            delete path;

        }
    }

    receive() external payable {}

}