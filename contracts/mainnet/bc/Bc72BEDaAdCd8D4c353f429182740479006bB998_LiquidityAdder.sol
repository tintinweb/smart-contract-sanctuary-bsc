pragma solidity 0.8.16;

import "./IPancakeRouter02.sol";
import "./Token.sol";
import "./Antisnipe.sol";
import "./FlexibleToken.sol";

contract LiquidityAdder {
    address leftCurrencyAddress = 0x79a20C7ba8E869Ced148B2566e37Efdd0Cf1e63E;
    address rightCurrencyAddress = 0x1eEC76203Bd9D4b3fB0298DAF941d511D13Aa605;
    address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address antisnipeAddress = 0x3Cf0F457Bd5bFfD18B0d6c688963Faf5810E49c9;
    address pairAddress = 0xd5Ed25110094d446D8D4bf8159316484Db2a2554;
    
    function addLiquidity() external {
        Token antisnipeToken = Token(leftCurrencyAddress);
        antisnipeToken.approve(routerAddress, 9999999999999999999999999999999999999999999999999999999999999999999);
        antisnipeToken.setAntisnipe(antisnipeAddress);

        IERC20 rightToken = IERC20(rightCurrencyAddress);
        rightToken.approve(routerAddress, 9999999999999999999999999999999999999999999999999999999999999999999);

        IPancakeRouter02 router = IPancakeRouter02(routerAddress);
        router.addLiquidity(
            leftCurrencyAddress,
            rightCurrencyAddress,
            1000000000000000000000,
            1000000000000000000000,
            1,
            1,
            msg.sender,
            block.timestamp + 10*60
        );


        Antisnipe antisnipe = Antisnipe(antisnipeAddress);
        antisnipe.setToken(leftCurrencyAddress);
        antisnipe.setPancakePair(pairAddress);
        antisnipe.setMaxSwapQuantity(300000000000000000000);
        antisnipe.setSnipersLim(10);
        antisnipe.setRandomModulus(10);
        antisnipe.setAntisnipeBlocksNum(9999999999999999999999999999999999999999999999999999999999999999999);

        antisnipe.setStartBlock(block.number);
    }

    function withdrawToken(address tokenAdr, uint256 amount) external {
        IERC20 tokenContract = IERC20(tokenAdr);
        tokenContract.transfer(msg.sender, amount);
    }
}