//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ILaunchpadNFT.sol";

contract Launchpad is Ownable {

    event Mint(address indexed contractAddress, address payeeAddress, uint256 size, uint256 price);

    struct Campaign {
        address contractAddress;
        address payeeAddress;
        uint256 price; // wei
        uint256 maxSupply;
        uint256 listingTime;
        uint256 expirationTime;
        uint256 maxBatch;
    }

    mapping(address => Campaign) public campaigns;

    function mint(address contractAddress, uint256 batchSize) payable external {
        // basic check
        require(contractAddress != address(0), "contract address can not be empty");
        require(batchSize > 0, "batchSize must greater than 0");
        require(campaigns[contractAddress].contractAddress != address(0), "contract not register");

        // activity check
        Campaign memory campaign = campaigns[contractAddress];
        require(batchSize <= campaign.maxBatch, "reach max batch size");
        require(block.timestamp >= campaign.listingTime, "activity not start");
        require(block.timestamp < campaign.expirationTime, "activity ended");
        // NFT contract must impl ERC721Enumerable to have this totalSupply method
        uint256 currentSupply = ILaunchpadNFT(contractAddress).getLaunchpadSupply();
        require(currentSupply + batchSize <= campaign.maxSupply, "reach campaign max supply");
        uint256 totalPrice = campaign.price * batchSize;
        require(msg.value >= totalPrice, "value not enough");

        // transfer token and mint
        payable(campaign.payeeAddress).transfer(totalPrice);
        ILaunchpadNFT(contractAddress).mintTo(msg.sender, batchSize);

        emit Mint(campaign.contractAddress, campaign.payeeAddress, batchSize, campaign.price);
        // return
        payable(_msgSender()).transfer(msg.value - totalPrice);
    }

    function addCampaign(address contractAddress_, address payeeAddress_, uint256 price_, uint256 maxSupply_, uint256 listingTime_, uint256 expirationTime_, uint256 maxBatch_) external onlyOwner {
        require(contractAddress_ != address(0), "contract address can not be empty");
        require(campaigns[contractAddress_].contractAddress == address(0), "contract address already exist");
        require(payeeAddress_ != address(0), "payee address can not be empty");
        require(maxSupply_ > 0, "max supply can not be 0");
        require(maxBatch_ > 0, "max batch invalid");
        campaigns[contractAddress_] = Campaign(contractAddress_, payeeAddress_, price_, maxSupply_, listingTime_, expirationTime_, maxBatch_);
    }

    function updateCampaign(address contractAddress_, address payeeAddress_, uint256 price_, uint256 maxSupply_, uint256 listingTime_, uint256 expirationTime_, uint256 maxBatch_) external onlyOwner {
        require(contractAddress_ != address(0), "contract address can not be empty");
        require(campaigns[contractAddress_].contractAddress != address(0), "contract address not exist");
        require(payeeAddress_ != address(0), "payee address can not be empty");
        require(maxSupply_ > 0, "max supply can not be 0");
        require(maxBatch_ > 0, "max batch invalid");
        campaigns[contractAddress_] = Campaign(contractAddress_, payeeAddress_, price_, maxSupply_, listingTime_, expirationTime_, maxBatch_);
    }

    function getCampaign(address contractAddress) view external returns (address, address, uint256, uint256, uint256, uint256, uint256) {
        Campaign memory a = campaigns[contractAddress];
        return (a.contractAddress, a.payeeAddress, a.price, a.maxSupply, a.listingTime, a.expirationTime, a.maxBatch);
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

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface ILaunchpadNFT {
    // return max supply config for launchpad, if no reserved will be collection's max supply
    function getMaxLaunchpadSupply() external view returns (uint256);
    // return current launchpad supply
    function getLaunchpadSupply() external view returns (uint256);
    // this function need to restrict mint permission to launchpad contract
    function mintTo(address to, uint256 size) external;
}