/**
 * @title Usdfi Create Token Liquidity
 * @dev UsdfiCreateTokenLiquidity contract
 *
 * @author - <USDFI TRUST>
 * for the USDFI Trust
 *
 * SPDX-License-Identifier: Business Source License 1.1
 *
 **/

import "./ERC20.sol";
import "./SafeERC20.sol";
import "./IFeeVault.sol";
import "./IWBNB.sol";

pragma solidity 0.6.12;

contract UsdfiCreateTokenLiquidity {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public token;
    uint256 public feePaid;

    address public constant wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public constant feeVault = 0x5F440AcE025e6039d3677aE7e5D301Cf52fD04E7;

    constructor(address _token) public {
        token = _token;
    }

    /**
     * @dev Activate the external contract trigger.
     */
    function createTokenLiquidityWBNB() public {
        IFeeVault(feeVault).createLiquidity(token);
        uint256 _amount = IERC20(wbnb).balanceOf(address(this));
        feePaid = feePaid.add(_amount);
        IERC20(wbnb).safeTransfer(address(msg.sender), _amount);
    }

    function createTokenLiquidityBNB() public {
        IFeeVault(feeVault).createLiquidity(token);
        uint256 _amount = IERC20(wbnb).balanceOf(address(this));
        feePaid = feePaid.add(_amount);
        IWBNB(wbnb).withdraw(_amount);
        safeTransferBNB(address(msg.sender), _amount);
    }

    function safeTransferBNB(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: BNB_TRANSFER_FAILED");
    }

    receive() external payable {}
}