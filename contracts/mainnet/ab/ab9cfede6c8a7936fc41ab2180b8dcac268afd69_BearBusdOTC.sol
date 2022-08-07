// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "./IERC20.sol";
import "./SafeERC20.sol";
import "./Ownable.sol";

interface IOracle {
    function consult(address _token, uint256 _amountIn) external view returns (uint144 amountOut);
}

contract BearBusdOTC is Ownable {
    using SafeERC20 for IERC20;

    address public constant BEAR = 0xC07C911B6e9126041F41f36728078464740ff222;  // BEAR, first in LP
    address public constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;   // BUSD
    address public constant Oracle = 0x7b34A6fDf504D1Ea73906c38F643C99C6cE51d88;   // BEAR Oracle
    
    bool public swapEnabled;

    /* OWNER LOGIC */

    function setSwapEnabled(bool _swapEnabled) public onlyOwner {
        swapEnabled = _swapEnabled;
    }

    function withdraw(address _token, uint256 _amount) public onlyOwner {
        IERC20(_token).transfer(owner(), _amount);
    }

    /* PUBLIC LOGIC */

    function otcSwapBearForBusd(uint256 _amountIn) public {
        require(swapEnabled, "Swapping is not enabled.");

        IERC20(BEAR).safeTransferFrom(msg.sender, address(this), _amountIn);
        
        uint256 amountOut = IOracle(Oracle).consult(address(BEAR), _amountIn);

        IERC20(BUSD).safeTransfer(msg.sender, amountOut);
    }
}