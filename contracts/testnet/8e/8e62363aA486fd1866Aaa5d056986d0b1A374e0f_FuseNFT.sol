// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

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

/**
 * @title ERC721 Burnable Token
 * @dev ERC721 Token that can be irreversibly burned (destroyed).
 */
interface IERC721Burnable {
    function burn(uint256 tokenId) external;
}

interface IERC20Burnable {
    function burn(address account, uint256 amount) external;
}

interface IERC721Metadata{
    function species(uint256) external view returns(uint8, uint8);
    function batchFusion(uint8 ranking, uint8 level, uint256 numbs) external;
}

contract MintingFee is Ownable {
    event SetMintingFee(address indexed token, uint256 amount);

    IERC20Burnable public feeToken;
    uint256 public feeAmount;

    function seeMintingFee(address token, uint256 amount) public onlyOwner {
        feeToken = IERC20Burnable(token);
        feeAmount = amount;
        emit SetMintingFee(token, amount);
    }
}

contract FuseNFT is MintingFee {
    event FuseNFTs(address indexed account, uint256[] tokenIds);

    address public rawContract;
    uint8 public threshold = 8;

    modifier validLength(uint256[] memory tokenIds) {
        require(tokenIds.length > 0 && tokenIds.length % threshold == 0, "FuseNFT: Invalid number of NFTs");
        _;
    }

    modifier sameSpecies(uint256[] memory tokenIds) {
        (uint8 rawRanking, uint8 rawLevel) = IERC721Metadata(rawContract).species(tokenIds[0]);
        for (uint256 i = 1; i < tokenIds.length; i++) {
            (uint8 ranking, uint8 level) = IERC721Metadata(rawContract).species(tokenIds[i]);
            require(rawRanking == ranking, "FusionNFT: NFTs do not have the same ranking");    
            require(rawLevel == level, "FusionNFT: NFTs do not have the same level");
        }
        _;
    }

    function fuseNfts(uint256[] memory tokenIds) public validLength(tokenIds) sameSpecies(tokenIds) {
        (uint8 rawRanking, uint8 rawLevel) = IERC721Metadata(rawContract).species(tokenIds[0]);
        uint8 newRanking = upgradeRanking(rawRanking);
        uint256 numbs = tokenIds.length / threshold;

        for (uint256 i = 0; i < tokenIds.length; i++) {
            IERC721Burnable(rawContract).burn(tokenIds[i]);
        }

        feeToken.burn(msg.sender, feeAmount * numbs);
        IERC721Metadata(rawContract).batchFusion(newRanking, rawLevel, numbs);
        emit FuseNFTs(msg.sender, tokenIds);
    }

    function upgradeRanking(uint8 currentRanking) internal pure returns(uint8) {
        return currentRanking + 1;
    }

    function setRawContract(address _rawContract) public onlyOwner {
        rawContract = _rawContract;
    }

    function setThreshHold(uint8 _threshold) public onlyOwner {
        threshold = _threshold;
    }
}