// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;
import "./IUniswapV2Pair.sol";
import "./IERC20.sol";

contract BackLp{

    address eatPair = 0x560e23D93a45C96Afa3aF403d4b88408B8c0BD1f;
    address eat = 0xbC2Cf7500a4c44E5e67020069418584971F5Ce0D;
    address opertion = 0x4A6342268D5955834ED191158f0195f0CcC4E30a;

    function sync() public {
        uint256 LPTokens = IERC20(eat).balanceOf(address(this));
        try IUniswapV2Pair(eatPair).sync() {
            IERC20(eat).transfer(eatPair,LPTokens);
            IUniswapV2Pair(eatPair).sync();
        } catch {
            IERC20(eat).transfer(opertion,LPTokens);
        }
    }
}