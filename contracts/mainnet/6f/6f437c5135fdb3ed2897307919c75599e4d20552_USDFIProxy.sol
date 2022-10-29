/**
 * @title USDFI Proxy
 * @dev USDFIProxy contract
 *
 * @author - <USDFI TRUST>
 * for the USDFI Trust
 *
 * SPDX-License-Identifier: Business Source License 1.1
 *
 **/

import "./Ownable.sol";
import "./IStrategy.sol";
import "./ERC20.sol";
import "./SafeERC20.sol";
import "./IFeeVault.sol";
import "./IWBNB.sol";
import "./IOps.sol";

pragma solidity 0.6.12;


contract USDFIProxy is Ownable {

    uint256 public i;

    address public immutable ops;
    address payable public immutable gelato;


    constructor() public {
        ops = 0x527a819db1eb0e34426297b03bae11F2f8B3A19E; // 0x527a819db1eb0e34426297b03bae11F2f8B3A19E
        gelato = IOps(0x527a819db1eb0e34426297b03bae11F2f8B3A19E).gelato();
    }

    /**
     * @dev Outputs the receiver contracts which are to be triggered.
     */
    address[] public receiver;

    /**
     * @dev Outputs the external contracts.
     */
    IStrategy internal strategy;

    /**
     * @dev Activate the external contract trigger.
     */
    function triggerProxy() public {
            strategy = IStrategy(receiver[i]);
            strategy.harvest();
            i++;
        
        if (i == receiver.length) {
            i = 0;
    }
    }

        /**
     * @dev Activate the external contract trigger.
     */
    function createTokenLiquidityGelatoBNB() public {
            IStrategy(0x49Cff0Ad3223262a945f4Fc3E19cF07C3696183a).harvest() ;
            IStrategy(0xfDf8693AE4C791265312BD4c1597A2067105067e).harvest() ;
            IStrategy(0xa8ae20bD4a93DB8bc16e3647542348A86726ab3b).harvest() ;
            IStrategy(0x264f4aa6aD4b927BD0c5BFbC67e8554cBc19320F).harvest() ;
            IStrategy(0x0D3e03785D8140Fd64D5541fFe0A78D0d8a38e27).harvest() ;
            IStrategy(0xd5a5bB4E57CC6A67418f45E65A53827A84cc0165).harvest() ;
            IStrategy(0x51b01Aadad9dA785ECA2045B824DaBc6eD4525f6).harvest() ;
            IStrategy(0x613aA1767fC8B2E7ba2Bcea93C2c4fd236532F4e).harvest() ;
            IStrategy(0x4Fd2ac0c1A60D5717b4cFDE5f071ed0F8b41A88f).harvest() ;
            IStrategy(0x067d968B593c7E7f89449A53472a3B0d1E6c3282).harvest() ;
            IStrategy(0xD292C50e08d0968BB8AEAD725812f468600adB35).harvest() ;
            IStrategy(0x617064151e6F49d5477Be4E48431487Ab92E1526).harvest() ;
            IStrategy(0xA71a7b1EE7c7CC9a9bCbFE25A1D340b033B21fc7).harvest() ;
            IStrategy(0xa418CD6363f9cbDf01c0BEB617A365e93341F59F).harvest() ;
            IStrategy(0xBA10064fDD98Aa76340413424EE47F4c216300B7).harvest() ;
            IFeeVault(0x5F440AcE025e6039d3677aE7e5D301Cf52fD04E7).createLiquidity(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
            uint256 _amount = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c).balanceOf(address(this));
            IWBNB(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c).withdraw(_amount);
            uint256 fee;
            address feeToken;
            (fee, feeToken) = IOps(ops).getFeeDetails();
            _transfer(fee);
    }

    /**
     * @dev Set the external contracts.
     */
    function setReceiver(address[] memory _receiver) external onlyOwner {
        receiver = _receiver;
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