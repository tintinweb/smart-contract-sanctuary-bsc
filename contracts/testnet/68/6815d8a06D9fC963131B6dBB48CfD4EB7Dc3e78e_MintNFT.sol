// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title A Mint NFT contract
contract MintNFT is Ownable {
    uint256 constant MAX_X = 50;
    uint256 constant MAX_Y = 50;
    uint256 constant MAX_Z = 50;

    uint256 public counter = 0; //tokenId

    // Mapping from token ID to owner
    mapping(uint256 => address) internal tokenOwner;

    // Mapping from owner to number of owned token
    mapping(address => uint256) internal ownedTokensCount;

    // Metadata of NFT
    mapping(uint256 => string) internal metaDataNFT;

    // Mapping from encodedTokenId to owner address
    mapping(uint256 => address) internal holderOf;

    event CreateNFT(
        address indexed user,
        uint256 nftId,
        string metaData,
        uint256 x,
        uint256 y,
        uint256 z,
        uint256 encodeTokenID
    );

    /**
     * @dev Only called by Owner else throw error
     * @param to address of user that will own the minted NFT
     * @param metaData string that contains metaData
     * @param x uint256 x coordinates
     * @param y uint256 y coordiantes
     * @param z uint256 z coordinates
     */
    function mint(
        address to,
        string calldata metaData,
        uint256[] calldata x,
        uint256[] calldata y,
        uint256[] calldata z
    ) external onlyOwner {
        require(to != address(0), "Mint to zero address");
        require(x.length > 0, "Give at least one coordinate");
        require(
            x.length == y.length &&
                x.length == z.length &&
                y.length == z.length,
            "The coordinates should have same length"
        );
        for (uint256 i = 0; i < x.length; i++) {
            uint256 encodedTokenId = _encodeTokenId(x[i], y[i], z[i]);
            require(
                !_exists(encodedTokenId),
                "The coordinate x,y,z already minted"
            );
            holderOf[encodedTokenId] = to;

            counter++;
            tokenOwner[counter] = to;
            ownedTokensCount[to] += 1;
            _updateMetaData(counter, metaData);
            emit CreateNFT(
                to,
                counter,
                metaData,
                x[i],
                y[i],
                z[i],
                encodedTokenId
            );
        }
    }

    /**
     * @param x uint256 x coordinates
     * @param y uint256 y coordiantes
     * @param z uint256 z coordinates
     * @return uint256 encoded Id of the x,y,z coordinates
     */
    function encodeTokenId(
        uint256 x,
        uint256 y,
        uint256 z
    ) external pure returns (uint256) {
        return _encodeTokenId(x, y, z);
    }

    /**
     * @param result uint256 result is the encoded id of x,y,z coordinates
     */
    function decodeTokenId(uint256 result)
        external
        pure
        returns (
            uint256 x,
            uint256 y,
            uint256 z
        )
    {
        return _decodeTokenId(result);
    }

    /**
     * @param x uint256 x coordinate
     * @param y uint256 y coordinate
     * @param z uint256 z coordinate
     * @return bool whether the token exists
     */
    function exists(
        uint256 x,
        uint256 y,
        uint256 z
    ) external view returns (bool) {
        uint256 _encodeId = _encodeTokenId(x, y, z);
        return (_exists(_encodeId));
    }

    function _encodeTokenId(
        uint256 x,
        uint256 y,
        uint256 z
    ) internal pure returns (uint256) {
        require(
            0 < x && x <= MAX_X && 0 < y && y <= MAX_Y && 0 < z && z <= MAX_Z,
            "(x,y,z) should be inside bounds"
        );
        uint256 a = 1;
        uint256 b = MAX_X + 1;
        uint256 c = (MAX_X + 1) * (MAX_Y + 1);
        uint256 d = 0;
        return a * x + b * y + c * z + d;
    }

    function _decodeTokenId(uint256 result)
        internal
        pure
        returns (
            uint256 x,
            uint256 y,
            uint256 z
        )
    {
        x = result % (MAX_X + 1);
        result /= (MAX_X + 1);
        y = result % (MAX_Y + 1);
        result /= (MAX_Y + 1);
        z = result;

        require(
            0 < x && x <= MAX_X && 0 < y && y <= MAX_Y && 0 < z && z <= MAX_Z,
            "(x,y,z) should be inside bounds"
        );
        return (x, y, z);
    }

    function _exists(uint256 _encodeId) internal view returns (bool) {
        return (holderOf[_encodeId] != address(0));
    }

    function _updateMetaData(uint256 _tokenId, string memory _metaData)
        internal
    {
        metaDataNFT[_tokenId] = _metaData;
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