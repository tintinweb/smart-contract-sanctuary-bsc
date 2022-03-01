// SPDX-License-Identifier: MIT
pragma solidity ^0.4.26;

import "./interfaces/Ownable.sol";

import {IRoyaltyFeeRegistry} from "./interfaces/IRoyaltyFeeRegistry.sol";

/**
 * @title RoyaltyFeeRegistry
 * @notice It is a royalty fee registry for the LooksRare exchange.
 */
contract OKRoyaltyFeeRegistry is IRoyaltyFeeRegistry, Ownable {
    struct FeeInfo {
        address setter;
        address receiver;
        uint256 fee;
    }

    // Limit (if enforced for fee royalty in percentage (10,000 = 100%)
    uint256 public royaltyFeeLimit;

    mapping(address => FeeInfo) private _royaltyFeeInfoCollection;

    event NewRoyaltyFeeLimit(uint256 royaltyFeeLimit);
    event RoyaltyFeeUpdate(address indexed collection, address indexed setter, address indexed receiver, uint256 fee);

    /**
     * @notice Constructor
     * @param _royaltyFeeLimit new royalty fee limit (500 = 5%, 1,000 = 10%)
     */
    constructor(uint256 _royaltyFeeLimit) {
        require(_royaltyFeeLimit <= 9500, "Owner: Royalty fee limit too high");
        royaltyFeeLimit = _royaltyFeeLimit;
    }

    /**
     * @notice Update royalty info for collection
     * @param _royaltyFeeLimit new royalty fee limit (500 = 5%, 1,000 = 10%)
     */
    function updateRoyaltyFeeLimit(uint256 _royaltyFeeLimit) external  onlyOwner {
        require(_royaltyFeeLimit <= 9500, "Owner: Royalty fee limit too high");
        royaltyFeeLimit = _royaltyFeeLimit;

        emit NewRoyaltyFeeLimit(_royaltyFeeLimit);
    }

    /**
     * @notice Update royalty info for collection
     * @param collection address of the NFT contract
     * @param setter address that sets the receiver
     * @param receiver receiver for the royalty fee
     * @param fee fee (500 = 5%, 1,000 = 10%)
     */
    function updateRoyaltyInfoForCollection(
        address collection,
        address setter,
        address receiver,
        uint256 fee
    ) external  onlyOwner {
        require(fee <= royaltyFeeLimit, "Registry: Royalty fee too high");
        _royaltyFeeInfoCollection[collection] = FeeInfo({setter: setter, receiver: receiver, fee: fee});

        emit RoyaltyFeeUpdate(collection, setter, receiver, fee);
    }

    /**
     * @notice Calculate royalty info for a collection address and a sale gross amount
     * @param collection collection address
     * @param amount amount
     * @return receiver address and amount received by royalty recipient
     */
    function royaltyInfo(address collection, uint256 amount) external view  returns (address, uint256) {
        return (
        _royaltyFeeInfoCollection[collection].receiver,
        (amount * _royaltyFeeInfoCollection[collection].fee) / 10000
        );
    }

    /**
     * @notice View royalty info for a collection address
     * @param collection collection address
     */
    function royaltyFeeInfoCollection(address collection)
    external
    view

    returns (
        address,
        address,
        uint256
    )
    {
        return (
        _royaltyFeeInfoCollection[collection].setter,
        _royaltyFeeInfoCollection[collection].receiver,
        _royaltyFeeInfoCollection[collection].fee
        );
    }
}

pragma solidity ^0.4.26;

contract Ownable {
    address public owner;


    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.4.26;

interface IRoyaltyFeeRegistry {
    function updateRoyaltyInfoForCollection(
        address collection,
        address setter,
        address receiver,
        uint256 fee
    ) external;

    function updateRoyaltyFeeLimit(uint256 _royaltyFeeLimit) external;

    function royaltyInfo(address collection, uint256 amount) external view returns (address, uint256);

    function royaltyFeeInfoCollection(address collection)
    external
    view
    returns (
        address,
        address,
        uint256
    );
}