//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./Cloneable.sol";
import "./Ownable.sol";

interface IWhitelabel {
    function __init__(
        string calldata name_,
        string calldata symbol_,
        address underlying_,
        address router_,
        uint256 mintFee_,
        uint256 sellFee_,
        uint256 transferFee_,
        address owner_
    ) external;
}

contract SurgeFactory is Ownable {

    // Underlying Structure
    struct Underlying {
        address[] whitelabels;
        bool hasBeenUsed;
    }

    /** Underlying Asset => White Label Underlying */
    mapping ( address => Underlying ) public whiteLabels;

    // Current Implementation
    address private implementation;

    // List of underlying assets
    address[] public allUnderlyingAssets;

    // List of all Surge Tokens Created
    address[] public allSurgeTokens;

    // Creation Event
    event SurgeTokenCreated(address newToken, address backingAsset);

    constructor(address implementation_) {
        implementation = implementation_;
    }

    // Set Implementation Address
    function setImplementation(address newImp) external onlyOwner {
        implementation = newImp;
    }

    // Create New Whitelabel
    function create(
        string calldata name_,
        string calldata symbol_,
        address underlying_,
        address router_,
        uint256 mintFee_,
        uint256 sellFee_,
        uint256 transferFee_
    ) external returns (address) {

        // clone implementation
        address newCopy = Cloneable(implementation).clone();

        // initialize clone
        IWhitelabel(newCopy).__init__(name_, symbol_, underlying_, router_, mintFee_, sellFee_, transferFee_, msg.sender);

        // push to backing list
        whiteLabels[underlying_].whitelabels.push(newCopy);

        // add to list of underlyings
        if (!whiteLabels[underlying_].hasBeenUsed) {
            whiteLabels[underlying_].hasBeenUsed = true;
            allUnderlyingAssets.push(underlying_);
        }

        // add to list of all surge tokens
        allSurgeTokens.push(newCopy);

        // emit event
        emit SurgeTokenCreated(newCopy, underlying_);

        // return new copy
        return newCopy;
    }

    function fetchAllSurgeTokensForUnderlying(address underlying) external view returns (address[] memory) {
        return whiteLabels[underlying].whitelabels;
    }

    function fetchAllSurgeTokens() external view returns (address[] memory) {
        return allSurgeTokens;
    }

    function fetchAllUnderlyingAssets() external view returns (address[] memory) {
        return allUnderlyingAssets;
    }
}