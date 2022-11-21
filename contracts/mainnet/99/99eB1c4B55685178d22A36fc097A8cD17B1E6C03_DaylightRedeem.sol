//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";

interface IDaylight {
    function burnFrom(address account, uint256 amount) external returns (bool);
    function getOwner() external view returns (address);
}

contract DaylightRedeem {

    // daylight token
    address public immutable daylight;

    // redeem fee
    uint256 public redeemFee = 20;
    uint256 public constant feeDenominator = 1000;

    modifier onlyOwner() {
        require(
            msg.sender == IDaylight(daylight).getOwner(),
            'Only Daylight Owner'
        );
        _;
    }

    constructor(
        address daylight_
    ) {
        daylight = daylight_;
    }

    function setRedeemFee(uint256 newFee) external onlyOwner {
        require(
            newFee <= feeDenominator / 2,
            'Fee Too High'
        );
        redeemFee = newFee;
    }

    function redeem(address[] calldata tokens, uint256 amount) external {
        require(
            IERC20(daylight).allowance(msg.sender, address(this)) >= amount,
            'Insufficient Allowance'
        );

        // length of token array
        uint len = tokens.length;

        // amounts array
        uint256[] memory amounts = new uint256[](len);

        // loop through tokens, calculating amounts to redeem
        for (uint i = 0; i < len;) {
            amounts[i] = amountToRedeemWithFee(tokens[i], amount);
            unchecked { ++i; }
        }

        // burn tokens from sender
        uint totalBefore = IERC20(daylight).totalSupply();
        require(
            IDaylight(daylight).burnFrom(msg.sender, amount),
            'Error Burn From'
        );
        uint totalAfter = IERC20(daylight).totalSupply();
        require(
            ( totalBefore - totalAfter ) == amount,
            'Error Burn Calculation'
        );

        // iterate through token list, sending user their amount
        for (uint i = 0; i < len;) {
            IERC20(tokens[i]).transfer(msg.sender, amounts[i]);
            unchecked { ++i; }
        }

        // clear memory
        delete amounts;
    }

    function getFloorPrice(address token) external view returns (uint256) {
        return ( IERC20(token).balanceOf(address(this)) * 10**18 ) / IERC20(daylight).totalSupply();
    }

    function amountToRedeem(address token, uint256 amount) public view returns (uint256) {
        return ( IERC20(token).balanceOf(address(this)) * amount ) / IERC20(daylight).totalSupply();
    }

    function amountToRedeemWithFee(address token, uint256 amount) public view returns (uint256) {
        uint rAmount = amountToRedeem(token, amount);
        return rAmount - ( ( rAmount * redeemFee ) / feeDenominator );
    }
}