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
import "./IOps.sol";

pragma solidity 0.6.12;

contract UsdfiCreateTokenLiquidity {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public token;
    uint256 public feePaid;

    address public immutable ops;
    address payable public immutable gelato;

    address public constant wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public constant feeVault = 0x5F440AcE025e6039d3677aE7e5D301Cf52fD04E7;

    constructor(address _token, address _ops) public {
        token = _token;
        ops = _ops; // 0x527a819db1eb0e34426297b03bae11F2f8B3A19E
        gelato = IOps(_ops).gelato();
    }

    /**
     * @dev Activate the external contract trigger.
     */
    function createTokenLiquidityWBNB() public {
        IFeeVault(feeVault).createLiquidity(token);
        uint256 _amount = IERC20(wbnb).balanceOf(address(this));
        feePaid = feePaid.add(_amount);
        IERC20(wbnb).safeTransfer(address(tx.origin), _amount);
    }

    function createTokenLiquidityBNB() public {
        IFeeVault(feeVault).createLiquidity(token);
        uint256 _amount = IERC20(wbnb).balanceOf(address(this));
        feePaid = feePaid.add(_amount);
        IWBNB(wbnb).withdraw(_amount);
        safeTransferBNB(address(tx.origin), _amount);
    }

    function createTokenLiquidityGelatoBNB() public {
        IFeeVault(feeVault).createLiquidity(token);
        uint256 _amount = IERC20(wbnb).balanceOf(address(this));
        IWBNB(wbnb).withdraw(_amount);
        feePaid = feePaid.add(_amount);
        uint256 fee;
        address feeToken;
        (fee, feeToken) = IOps(ops).getFeeDetails();
        _transfer(fee);
    }

    function _transfer(uint256 _amount) internal {
        (bool success, ) = gelato.call{value: _amount}("");
        require(success, "_transfer: BNB_TRANSFER_FAILED");
    }

    function safeTransferBNB(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: BNB_TRANSFER_FAILED");
    }

    receive() external payable {}
}