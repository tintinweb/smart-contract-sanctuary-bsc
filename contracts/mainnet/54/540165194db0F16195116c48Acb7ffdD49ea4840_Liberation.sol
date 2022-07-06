pragma solidity ^0.8.0;

import "./IPancakeRouter02.sol";
import "./IPancakeFactory.sol";
import "./TokensRecoverable.sol";
import "./SafeMath.sol";
import "./IWBNB.sol";

contract Liberation is TokensRecoverable {

    using SafeMath for uint256;

    address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    IPancakeRouter02 public router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    IPancakeFactory public factory;
    address sideKickToken = 0x5755E18D86c8a6d7a6E25296782cb84661E6c106;

    constructor(){
        factory = IPancakeFactory(router.factory());
    }
    

    function depositLiquidity() public payable{
        address sender = msg.sender;

        require (msg.value > 0, "Must deposit some amount");

        IWBNB(address(WBNB)).deposit{ value: address(this).balance}();

        uint256 amountToSpend = msg.value.div(2);

        uint256 sidekickAmount = buySidekick(amountToSpend);

        router.addLiquidity(WBNB, sideKickToken, amountToSpend, sidekickAmount, 0, 0, sender, block.timestamp);
        



    }

    function buySidekick(uint amount) private returns (uint256) {
        uint256[] memory amounts = router.swapExactTokensForTokens(amount, 0, buyPath(), address(this), block.timestamp);
        uint256 spend = amounts[1];
        return spend;
    }


    function buyPath() private view returns(address[] memory){
        address[] memory path = new address[](2);
        path[0] = address(WBNB);
        path[1] = address(sideKickToken);
        return path;
    }
}