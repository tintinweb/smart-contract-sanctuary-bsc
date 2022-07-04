//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "./GErc20.sol";


/**
 * @title Planet's GErc20Delegate Contract
 * @notice GTokens which wrap an EIP-20 underlying and are delegated to
 * @author Planet
 * @dev contracts to be included GErc20, GToken, GammatrollerInterface, GTokenInterface, ErrorReporter, EIP20Interface, InterestRateModel,
 * ExponentialNoError, PlanetDiscountInterface, PriceOracleInterface, EIP20NonStandardInterface
 **/
contract GErc20Delegate is GErc20, GDelegateInterface {
    /**
     * @notice Construct an empty delegate
     */
    constructor() {}

    /**
     * @notice Called by the delegator on a delegate to initialize it for duty
     * @param data The encoded bytes data for any initialization
     */
    function _becomeImplementation(bytes memory data) virtual override public {
        // Shh -- currently unused
        data;

        // Shh -- we don't ever want this hook to be marked pure
        if (false) {
            implementation = address(0);
        }

        require(msg.sender == admin, "only the admin may call _becomeImplementation");
    }

    /**
     * @notice Called by the delegator on a delegate to forfeit its responsibility
     */
    function _resignImplementation() virtual override public {
        // Shh -- we don't ever want this hook to be marked pure
        if (false) {
            implementation = address(0);
        }

        require(msg.sender == admin, "only the admin may call _resignImplementation");
    }
}