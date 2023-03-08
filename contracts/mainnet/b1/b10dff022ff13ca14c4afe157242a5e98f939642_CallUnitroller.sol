/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

pragma solidity ^0.8.0;

interface VToken {
    function isVToken() external view returns (bool);
    // Define any other functions that the VToken interface might have here
}

interface Unitroller {
    function _supportMarket(address vToken) external returns (uint);

    function markets(address) external view returns (bool isListed, uint256 collateralFactorMantissa);
    
    // Add any other functions that the Unitroller interface might have here
}

contract CallUnitroller {
    Unitroller public unitroller;
    address public delegate;



    constructor(address unitrollerAddress, address _delegate) {

        unitroller = Unitroller(unitrollerAddress);

        delegate = _delegate;

    }

    function supportMarket(VToken vToken) external returns (uint) {
        Unitroller unitroller = Unitroller(delegate);
        
        (bool isListed, ) = unitroller.markets(address(vToken));
        require(!isListed, "Market already listed");

        vToken.isVToken(); // Sanity check to make sure it's really a VToken

        uint256 result = unitroller._supportMarket(address(vToken));
        return result;
    }

    function setDelegate(address _delegate) external {
        delegate = _delegate;
    }

    function getDelegate() external view returns (address) {
        return delegate;
    }

    // Fallback function to receive Ether
    fallback() external payable {
        revert("Fallback function called");
    }
}