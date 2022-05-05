// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IGovernance.sol";

/**
   @title Archive contract
   @dev This contract archives used signatures
*/
contract Archive {
    IGovernance public gov;

    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant MARKETPLACE = keccak256("MARKETPLACE");

    //  Hash(signature) will be recorded in the list
    mapping(bytes32 => bool) public usedSigs;

    modifier onlyAuthorize() {
        require(gov.hasRole(MARKETPLACE, msg.sender), "Unauthorized ");
        _;
    }

    modifier onlyManager() {
        require(gov.hasRole(MANAGER_ROLE, msg.sender), "Caller is not Manager");
        _;
    }

    constructor(address _gov) {
        gov = IGovernance(_gov);
    }

    /**
        @notice Change a new Manager contract
        @dev Caller must be Owner
        @param _newGov       Address of new Governance Contract
    */
    function setGov(address _newGov) external onlyManager {
        require(_newGov != address(0), "Set zero address");
        gov = IGovernance(_newGov);
    }

    /**
        @notice Save hash of a signature
        @dev Caller must be Marketplace conctract
        @param _sigHash             Hash of signature
    */
    function record(bytes32 _sigHash) external onlyAuthorize {
        require(!usedSigs[_sigHash], "Signature recorded");
        usedSigs[_sigHash] = true;
    }
}

// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

/**
   @title IGovernance interface
   @dev This provides interfaces that other contracts can interact with Governance contract
*/
interface IGovernance {
    function locked() external view returns (bool);
    function treasury() external view returns (address);
    function listOfNFTs(address _nftContr) external view returns (bool);
    function blacklist(address _account) external view returns (bool);
    function hasRole(bytes32 role, address account) external view returns (bool);
    function paymentTokens(address _token) external view returns (bool);
    function FEE_DENOMINATOR() external view returns (uint256);
    function commissionFee() external view returns (uint256);
}