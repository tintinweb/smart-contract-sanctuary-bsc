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

import "./IFeeVault.sol";
import "./ERC20.sol";
import "./SafeERC20.sol";

pragma solidity 0.6.12;

contract UsdfiCreateTokenLiquidity {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public token;
    uint256 public feePaid;

    /**
     * @dev Outputs the external contracts.
     */
    IFeeVault internal feeVault;

    constructor(address _token) public {
        token = _token;
        feeVault = IFeeVault(0x5F440AcE025e6039d3677aE7e5D301Cf52fD04E7);
    }

    /**
     * @dev Activate the external contract trigger.
     */
    function createTokenLiquidity() public {
        feeVault.createLiquidity(token);
        uint256 _amount = IERC20(token).balanceOf(address(this));
        feePaid = feePaid.add(_amount);
        IERC20(token).safeTransfer(address(msg.sender), _amount);
    }
}