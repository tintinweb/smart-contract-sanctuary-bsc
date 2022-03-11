// SPDX-License-Identifier: Snake
pragma solidity ^0.8.12;

/* Created by @CRYPTO_BOSS_01.
*/

import '@openzeppelin/contracts/access/Ownable.sol';
import "./ContributorType.sol";

contract Contributor is Ownable {

    struct ContributionInfo {
        uint256 contributionAmount;
        string contributorType;
    }

    mapping (address => ContributionInfo) public contributors;

    ContributorType private contributorType;

    constructor(ContributorType _contributorType) {
        contributorType = _contributorType;
    }

    modifier checkContributionAllowed(address _account, ContributionInfo memory _contributorInfo) {
        require(_contributorInfo.contributionAmount + contributors[_account].contributionAmount <= contributorType.getContributionTypeInfo(_contributorInfo.contributorType).maxAmountAllowed, "CANNOT_EXCEED_MAX_AMOUNT_ALLOWED");
        _;
    }

    function addContributor(address _account, ContributionInfo memory _contributorInfo) checkContributionAllowed(_account, _contributorInfo) public onlyOwner {
        if(contributors[_account].contributionAmount > 0) {
            require(keccak256(abi.encodePacked(contributors[_account].contributorType)) == keccak256(abi.encodePacked(_contributorInfo.contributorType)), "NOT_ALLOWED_TO_CONTRIBUTE_WITH_THIS_ADDRESS");
            contributors[_account].contributionAmount += _contributorInfo.contributionAmount;
        } else {
            contributors[_account] = _contributorInfo;
        }
    }

    function setContributor(address _account, uint256 _contributionAmount, string memory _contributorType) public onlyOwner {
        contributors[_account].contributionAmount = _contributionAmount;
        contributors[_account].contributorType = _contributorType;
    }

    function addContributors(address[] memory _accounts, ContributionInfo[] memory _contributors) public onlyOwner {
        require(_accounts.length == _contributors.length, "ACCOUNT_AND_CONTRIBUTOR_ARRAYS_DOES_NOT_HAVE_THE_SAME_SIZE");
        for(uint256 i = 0; i < _accounts.length; i++) {
            addContributor(_accounts[i], _contributors[i]);
        }
    }

    function getContributor(address _account) public view returns (ContributionInfo memory) {
        return contributors[_account];
    }

    function deleteContributor(address _account) public onlyOwner {
        delete contributors[_account];
    }

    function deleteContributors(address[] memory _accounts) public onlyOwner {
        for(uint256 i = 0; i < _accounts.length; i++) {
            delete contributors[_accounts[i]];
        }
    }


}

// SPDX-License-Identifier: Snake
pragma solidity ^0.8.12;

/* Created by @CRYPTO_BOSS_01.
*/

import '@openzeppelin/contracts/access/Ownable.sol';

contract ContributorType is Ownable {

    struct ContributorTypeInfo {
        uint256 maxAmountAllowed;
        bool isAllowedToContributeInPresale;
        bool isVested;
    }
    mapping(string => ContributorTypeInfo) public contributorTypeInfos;
    string[] contributorTypes;

    function setContributionType(string memory _name, ContributorTypeInfo memory _contributorTypeInfo) public onlyOwner {
        contributorTypeInfos[_name] = _contributorTypeInfo;
        contributorTypes.push(_name);
    }

    function removeContributionType(string memory _name) public onlyOwner {
        delete contributorTypeInfos[_name];
        for(uint i = 0; i < contributorTypes.length; i++) {
            if (keccak256(abi.encodePacked(contributorTypes[i])) == keccak256(abi.encodePacked(_name))) {
                delete contributorTypes[i];
            }
        }
    }

    function getContributionTypeInfo(string memory _name) public onlyOwner view returns (ContributorTypeInfo memory) {
        return contributorTypeInfos[_name];
    }

    function getContributionTypes() public onlyOwner view returns (string[] memory) {
        return contributorTypes;
    }

    function getContributionTypeCount() public onlyOwner view returns (uint256) {
        return contributorTypes.length;
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