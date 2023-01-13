//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./IUniswapV2Router02.sol";

interface IDaylight {
    function burn(uint256 amount) external returns (bool);
}

interface IStable {
    function sell(uint256 tokenAmount) external returns (uint256);
}

contract FeeRecipient {

    address public dev0 = 0xb7EE8cb807eF7ef493B902b93E60f22D268355c1;
    address public dev1 = 0x49f529D76Ffe1e439E48524136e0e52C0cDB48b0;
    address public dev2 = 0xFF96f3Be084178F1E2b27dbaA8F849326b6F6C4E;

    address public constant daylight = 0x62529D7dE8293217C8F74d60c8C0F6481DE47f0E;
    IERC20 public constant BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    IUniswapV2Router02 public constant router = IUniswapV2Router02(0xb34DA672837aFe372eceF419b25a357A36f59F6f);
    IERC20 public constant apollo = IERC20(0x32a05625d2A25054479d0c5d661857147c34483D);
    address[] private path;

    constructor() {
        path = [address(BUSD), daylight];
    }

    function trigger() external {

        uint256 balance = apollo.balanceOf(address(this));
        if (balance <= 100) {
            return;
        }

        // split into fourths
        uint dev = balance / 5;
        apollo.transfer(dev0, dev * 2);
        apollo.transfer(dev1, dev);
        apollo.transfer(dev2, dev);

        // sell apollo
        IStable(address(apollo)).sell(apollo.balanceOf(address(this)));

        // sell balance of BUSD
        uint toBuyBack = BUSD.balanceOf(address(this));
        if (toBuyBack > 0) {
            BUSD.approve(address(router), toBuyBack);
            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                toBuyBack, 1, path, address(this), block.timestamp + 100
            );
        }

        uint dBal = IERC20(daylight).balanceOf(address(this));
        if (dBal > 0) {
            IDaylight(daylight).burn(dBal);
        }
    }

    function withdraw(address token) external {
        require(
            msg.sender == dev0, 'Only Dev'
        );
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

    function setDev0(address newDev0) external {
        require(msg.sender == dev0, 'Only Dev');
        dev0 = newDev0;
    }

    function setDev1(address newDev1) external {
        require(msg.sender == dev1, 'Only Dev');
        dev1 = newDev1;
    }

    function setDev2(address newDev2) external {
        require(msg.sender == dev2, 'Only Dev');
        dev2 = newDev2;
    }

}