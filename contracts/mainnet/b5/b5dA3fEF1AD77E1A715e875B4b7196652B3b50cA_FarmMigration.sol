//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./IERC20.sol";
import "./IUniswapV2Router02.sol";

interface IXUSD {
    function sell(uint256 amount) external;
}

interface IXUSDV2 {
    function mintWithBacking(address backingToken, uint256 numTokens, address recipient) external returns (uint256);
}

contract FarmMigration {

    address public constant LP = 0x6789432a7494DCC5061129e369fb3FF801121123;
    address public constant XUSD = 0x254246331cacbC0b2ea12bEF6632E4C6075f60e2;
    address public constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public XUSDV2 = 0xC1Dd7A10983AF2a010cE7A4EE1b52F5A1d0b5903;

    IUniswapV2Router02 router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    address v2Pair;

    address creator;

    event Migration(uint256 Num_V2_LP_Tokens, uint256 V2_Dust_Returned, uint256 BNB_Dust_Returned);

    constructor() {
        creator = msg.sender;
        v2Pair = IUniswapV2Factory(router.factory()).createPair(XUSDV2, router.WETH());
    }

    function setXUSDV2(address XUSDV2_) external {
        require(msg.sender == creator);
        XUSDV2 = XUSDV2_;
    }

    function migrate() external {
        require(
            IERC20(LP).balanceOf(msg.sender) > 0,
            'Zero LP Balance'
        );

        IERC20(LP).transferFrom(
            msg.sender,
            address(this),
            IERC20(LP).balanceOf(msg.sender)
        );

        IERC20(LP).approve(address(router), IERC20(LP).balanceOf(address(this)));
        router.removeLiquidityETHSupportingFeeOnTransferTokens(
            LP,
            IERC20(LP).balanceOf(address(this)),
            0,
            0,
            address(this),
            block.timestamp + 300
        );

        // sell XUSD V1
        IXUSD(XUSD).sell(IERC20(XUSD).balanceOf(address(this)));

        // Approve And Mint V2
        IERC20(BUSD).approve(XUSDV2, IERC20(BUSD).balanceOf(address(this)));
        IXUSDV2(XUSDV2).mintWithBacking(BUSD, IERC20(BUSD).balanceOf(address(this)), address(this));

        // Approve router
        IERC20(XUSDV2).approve(address(router), IERC20(XUSDV2).balanceOf(address(this)));
        router.addLiquidityETH{value: address(this).balance}(
            XUSDV2,
            0,
            0,
            0,
            address(this),
            block.timestamp + 300
        );

        uint pairBal = IERC20(v2Pair).balanceOf(address(this));
        uint v2Bal = IERC20(XUSDV2).balanceOf(address(this));
        uint bal = address(this).balance;

        IERC20(v2Pair).transfer(msg.sender, pairBal);

        if (v2Bal > 0) {
            IERC20(XUSDV2).transfer(msg.sender, v2Bal);
        }
        if (bal > 0) {
            (bool s,) = payable(msg.sender).call{value: bal}("");
            require(s);
        }
        emit Migration(
            pairBal,
            v2Bal,
            bal
        );
    }

    receive() external payable{}

}