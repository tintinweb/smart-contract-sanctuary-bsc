// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Royalties is Ownable {

    uint256 constant DEFAULT_TOKEN_ID = type(uint256).max;

    ///beneficiary -> contract -> tokenId (actual tokenId or DEFAULT_TOKEN_ID for contract wide setting) -> bps
    mapping(address => mapping(address => mapping(uint256 => uint256))) public userTokenRoyalties;
    ///contract -> list of beneficiaries
    mapping(address => address[]) public royaltyBeneficiaries;

    /// @notice Calculates royalty payment for all beneficiaries based on token address and id
    /// @param _tokenContract token address to calculate the royalties for
    /// @param _tokenId token id
    /// @param _amount the cost base of the NFT
    /// @return recipients list of recipients of the royalties
    /// @return amounts list of amounts to be distributed
    function getRoyalty(
        address _tokenContract,
        uint256 _tokenId,
        uint256 _amount
    ) external view returns (
        address[] memory recipients,
        uint256[] memory amounts
    ) {
        recipients = royaltyBeneficiaries[_tokenContract];
        uint256 length = recipients.length;
        amounts = new uint256[](length);
        for(uint256 i = 0; i < length;) {
            uint256 royalty = userTokenRoyalties[recipients[i]][_tokenContract][_tokenId];

            /// If the royalty is not set for particular token, check the default for contract
            if (royalty == 0) {
                royalty = userTokenRoyalties[recipients[i]][_tokenContract][DEFAULT_TOKEN_ID];
            }
            amounts[i] = _amount * royalty / 10000;
            unchecked {
                 ++i;
            }
        }
    }

    /// @notice Sets royalty for beneficiary
    /// @param _beneficiary Beneficiary address
    /// @param _tokenContract Token contract to be configured
    /// @param _tokenId Token ID to be configured (use type(uint256).max for global contract configuration)
    /// @param _royalty Royalty value in basis points (BPS)
    function setBeneficiary(
        address _beneficiary,
        address _tokenContract,
        uint256 _tokenId,
        uint256 _royalty
    ) external onlyOwner {
        require(_royalty <= 10000, "Royalty too high");

        if (!beneficiarySet(_tokenContract, _beneficiary)) {
            royaltyBeneficiaries[_tokenContract].push(_beneficiary);
        } else if (_royalty == 0) {
            removeBeneficiary(_tokenContract, _beneficiary);
            delete userTokenRoyalties[_beneficiary][_tokenContract][_tokenId];
            return;
        }
        
        userTokenRoyalties[_beneficiary][_tokenContract][_tokenId] = _royalty;

    }

    /// @notice Checks whether the beneficiary has been configured before
    /// @param _tokenContract token contract to check
    /// @param _beneficiary beneficiary to be checked
    function beneficiarySet(address _tokenContract, address _beneficiary) internal returns (bool) {
        address[] memory beneficiaries = royaltyBeneficiaries[_tokenContract];
        uint256 length = beneficiaries.length;
        for(uint256 i = 0; i < length;) {
            if (beneficiaries[i] == _beneficiary) {
                return true;
            }
            unchecked {
                 ++i;
            }
        }

        return false;
    }

    /// @notice Removes beneficiary from tracking list
    /// @param _tokenContract token contract to configure
    /// @param _beneficiary beneficiary to be removed
    function removeBeneficiary(address _tokenContract, address _beneficiary) internal {
        address[] memory beneficiaries = royaltyBeneficiaries[_tokenContract];
        uint256 length = beneficiaries.length;
        for(uint256 i = 0; i < length;) {
            if (beneficiaries[i] == _beneficiary) {
                royaltyBeneficiaries[_tokenContract][i] = beneficiaries[beneficiaries.length - 1];
                royaltyBeneficiaries[_tokenContract].pop();
                break;
            }
            unchecked {
                 ++i;
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}