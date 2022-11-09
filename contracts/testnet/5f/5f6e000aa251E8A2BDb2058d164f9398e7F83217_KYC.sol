// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./IKYC.sol";
import "./ISubscription.sol";
import "./IKYCTreasury.sol";

/**
 * @title Contract for storing and managing users kyc state
 */
contract KYC is IKYC {
    error InvalidSubscription();
    error NotAllowed();
    error WrongArraySize();
    error InsufficientFunds(uint256 sent, uint256 required);
    error AlreadyInitialized();

    /// Owner of the contract
    address public owner;
    /// System admin for the contract
    address public systemAdmin;
    /// Address that can change users kyc state
    address public kycManager;
    /// Subscription contract
    ISubscription public subscription;
    /// KYCFactory contract
    IKYCTreasury public kycTreasury;

    // Contract initialized state
    bool private _initialized;

    /// Mapping for storing kyc completed addresses
    mapping(address => bool) private _kycList;
    /// Mapping for storing addresses which can query specific functions in the contract
    mapping(address => bool) private _queryWhitelist;

    /**
     * @dev Emitted when kyc manager updated
     * @param kycManager The address of new kyc manager
     */
    event KYCManagerSet(address indexed kycManager);

    function init(
        address _owner,
        address _subscription,
        address _systemAdmin,
        address _kycTreasury
    ) external {
        if (_initialized) revert AlreadyInitialized();
        _initialized = true;

        owner = _owner;
        systemAdmin = _systemAdmin;
        subscription = ISubscription(_subscription);
        kycTreasury = IKYCTreasury(_kycTreasury);

        _queryWhitelist[owner] = true;
    }

    /**
     * @dev Updates {kycManager} variable
     * @param _kycManager New kyc manager address
     */
    function setKYCManager(address _kycManager) external {
        if (msg.sender != systemAdmin) revert NotAllowed();

        kycManager = _kycManager;

        emit KYCManagerSet(_kycManager);
    }

    /**
     * @dev Update the whitelist state of `queryAddress` (updates {_queryWhitelist} mapping)
     * @param queryAddress Address to update query allow state
     * @param allowed State of the query address
     */
    function whitelist(address queryAddress, bool allowed) external {
        if (msg.sender != owner) revert NotAllowed();

        _queryWhitelist[queryAddress] = allowed;
    }

    /**
     * @dev Stores user's kyc information to the contract
     * @notice Regardless of `verified` state of the user price for user storage should be paid
     * @param user User to store kyc state information
     * @param verified Verified state for user to store
     */
    function addKYCUser(address user, bool verified) external payable {
        if (msg.sender != kycManager) revert NotAllowed();
        uint256 transferAmount = kycTreasury.getPriceForUserStorage();
        if (msg.value != transferAmount) revert InsufficientFunds({ sent: msg.value, required: transferAmount });

        _kycList[user] = verified;

        payable(kycTreasury.getTreasuryAddress()).transfer(transferAmount);
    }

    /**
     * @dev Stores users kyc information to the contract
     * @notice Total price for users storage should be paid
     * @param users List of users to store kyc state information
     * @param usersVerified Verified state for list of users to store
     */
    function addKYCUsers(address[] calldata users, bool[] calldata usersVerified) external payable {
        if (msg.sender != kycManager) revert NotAllowed();
        if (users.length != usersVerified.length) revert WrongArraySize();
        uint256 transferAmount = kycTreasury.getPriceForUserStorage() * users.length;
        if (msg.value != transferAmount) revert InsufficientFunds({ sent: msg.value, required: transferAmount });

        for (uint256 i = 0; i < users.length; i++) {
            address user = users[i];
            _kycList[user] = usersVerified[i];
        }

        payable(kycTreasury.getTreasuryAddress()).transfer(transferAmount);
    }

    /**
     * @dev Returns `user` kyc state
     * @param user User to check kyc state
     * @return result Kyc state of the user
     */
    function isKYCPassed(address user) external view returns (bool result) {
        if (!subscription.isSubscriptionValid(address(this))) revert InvalidSubscription();
        if (!_queryWhitelist[msg.sender]) revert NotAllowed();

        result = _kycList[user];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IKYC {
    function init(
        address _owner,
        address _subscription,
        address _systemAdmin,
        address _kycTreasury
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface ISubscription {
    /**
     * @dev Returns subscription deadline for the given `clone`
     * @param clone Clone address to check deadline
     * @return deadline Deadline of the clone subscription
     */
    function getSubscriptionDeadline(address clone) external view returns (uint256 deadline);

    /**
     * @dev Returns subscription valid state for the given clone
     * @param clone Clone address to check valid state
     * @return result Valid state
     */
    function isSubscriptionValid(address clone) external view returns (bool result);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IKYCTreasury {
    /**
     * @dev Returns the {_treasuryAddress} variable
     * @return treasury {_treasuryAddress} variable
     */
    function getTreasuryAddress() external view returns (address treasury);

    /**
     * @dev Returns the {_priceForUserStorage} variable
     * @return price {_priceForUserStorage} variable
     */
    function getPriceForUserStorage() external view returns (uint256 price);
}