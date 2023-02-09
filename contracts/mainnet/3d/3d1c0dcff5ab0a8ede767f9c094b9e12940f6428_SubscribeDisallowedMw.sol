// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.14;

interface ISubscribeMiddleware {
    /**
     * @notice Sets subscribe related data for middleware.
     *
     * @param profileId The profile id that owns this middleware.
     * @param data Extra data to set.
     */
    function setSubscribeMwData(uint256 profileId, bytes calldata data)
        external
        returns (bytes memory);

    /**
     * @notice Process that runs before the subscribeNFT mint happens.
     *
     * @param profileId The profile Id.
     * @param subscriber The subscriber address.
     * @param subscribeNFT The subscribe nft address.
     * @param data Extra data to process.
     */
    function preProcess(
        uint256 profileId,
        address subscriber,
        address subscribeNFT,
        bytes calldata data
    ) external;

    /**
     * @notice Process that runs after the subscribeNFT mint happens.
     *
     * @param profileId The profile Id.
     * @param subscriber The subscriber address.
     * @param subscribeNFT The subscribe nft address.
     * @param data Extra data to process.
     */
    function postProcess(
        uint256 profileId,
        address subscriber,
        address subscribeNFT,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.14;

import { ISubscribeMiddleware } from "../../interfaces/ISubscribeMiddleware.sol";

/**
 * @title Subscribe Disallowed Middleware
 * @author CyberConnect
 * @notice This contract is a middleware to disallow any subscriptions to the user.
 */
contract SubscribeDisallowedMw is ISubscribeMiddleware {
    /*//////////////////////////////////////////////////////////////
                         EXTERNAL VIEW
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISubscribeMiddleware
    function setSubscribeMwData(uint256, bytes calldata)
        external
        pure
        override
        returns (bytes memory)
    {
        // do nothing
        return new bytes(0);
    }

    /**
     * @inheritdoc ISubscribeMiddleware
     * @notice Process that disallows a subscription
     */
    function preProcess(
        uint256,
        address,
        address,
        bytes calldata
    ) external pure override {
        revert("SUBSCRIBE_DISALLOWED");
    }

    /// @inheritdoc ISubscribeMiddleware
    function postProcess(
        uint256 profileId,
        address subscriber,
        address subscribeNFT,
        bytes calldata data
    ) external override {
        // do nothing
    }
}