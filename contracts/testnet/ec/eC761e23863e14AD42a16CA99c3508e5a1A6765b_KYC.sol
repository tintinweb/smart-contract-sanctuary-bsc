// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./IKYC.sol";
import "./ISubscription.sol";
import "./IKYCTreasury.sol";

contract KYC is IKYC {
    error InvalidSubscription();
    error NotAllowed();
    error WrongArraySize();
    error InsufficientFunds(uint256 sent, uint256 required);

    /// Mapping for storing kyc completed addresses
    mapping(address => bool) private _kycList;
    /// Mapping for storing addresses which can call `isKYCPassed`
    mapping(address => bool) private _queryWhitelist;

    address public owner;
    address public systemAdmin;
    address public kycManager;

    ISubscription public subscription;
    IKYCTreasury public kycTreasury;

    event KYCManagerSet(address indexed kycManager);

    function init(
        address _owner,
        address _subscription,
        address _systemAdmin,
        address _kycTreasury
    ) external {
        owner = _owner;
        systemAdmin = _systemAdmin;
        subscription = ISubscription(_subscription);
        kycTreasury = IKYCTreasury(_kycTreasury);

        _queryWhitelist[owner] = true;
    }

    function setKYCManager(address _kycManager) external {
        if (msg.sender != systemAdmin) revert NotAllowed();

        kycManager = _kycManager;

        emit KYCManagerSet(_kycManager);
    }

    function whitelist(address queryAddress, bool allowed) external {
        if (msg.sender != owner) revert NotAllowed();

        _queryWhitelist[queryAddress] = allowed;
    }

    function addKYCUser(address user, bool verified) external payable {
        if (msg.sender != kycManager) revert NotAllowed();
        uint256 transferAmount = kycTreasury.getPriceForUserStorage();
        if (msg.value != transferAmount) revert InsufficientFunds({ sent: msg.value, required: transferAmount });

        _kycList[user] = verified;

        payable(kycTreasury.getTreasuryAddress()).transfer(transferAmount);
    }

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

    function isKYCPassed(address user) external view returns (bool result) {
        if (!subscription.isSubscriptionValid(owner)) revert InvalidSubscription();
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
    function getSubscriptionDeadline(address subscriber) external view returns (uint256 deadline);

    function isSubscriptionValid(address subscriber) external view returns (bool result);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IKYCTreasury {
    function getTreasuryAddress() external view returns (address treasury);

    function getPriceForUserStorage() external view returns (uint256 price);
}