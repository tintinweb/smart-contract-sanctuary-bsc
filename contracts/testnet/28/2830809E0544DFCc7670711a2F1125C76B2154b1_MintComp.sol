// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import "../Lib/Ownable.sol";
import "../Lib/IERC721Mint.sol";
import "../Lib/IERC1155Mint.sol";
import "./IMintComp.sol";

contract MintComp is Ownable,IMintComp{

    IERC721Mint public erc721;
    IERC1155Mint public erc1155;

    mapping(address => mapping(uint256 => Royalty)) private _royalties;

    constructor(address erc721_, address  erc1155_, address metaTx) ERC2771Context(metaTx) {
        erc721 = IERC721Mint(erc721_);
        erc1155 = IERC1155Mint(erc1155_);
    }

    function setERC721(address token) public onlyOwner{
        erc721 = IERC721Mint(token);
    }

    function setERC1155(address token) public onlyOwner{
        erc1155 = IERC1155Mint(token);
    }

    function mintERC721(address to, string memory uri, uint256 rate) override public{
        address token;
        uint256 id;
        (token,id) = _mintERC721(to,uri);

        _addRoyalty(token, id, Royalty(msg.sender,rate));
        emit MintERC721(token, id);
    }

    function mintERC1155(address to, uint256 value, string memory uri, uint256 rate) override public{
        address token;
        uint256 id;
        (token,id) = _mintERC1155(to,value,"mint by numiscoin",uri);

        _addRoyalty(token, id, Royalty(msg.sender,rate));
        emit MintERC1155(token, id);
    }

    function getRoyalty(address token, uint256 id) override public view returns(address maker,uint256 rate){
        maker = _royalties[token][id].maker;
        rate = _royalties[token][id].rate;
    }

    function _addRoyalty(address token, uint256 id,Royalty memory royalty) internal{
        _royalties[token][id] = royalty;
    }

    function _mintERC721(address to, string memory uri) internal returns(address token,uint256 id){
        id = erc721.mint(to,uri);

        return (address(erc721),id);
    }

    function _mintERC1155(address to, uint256 value, bytes memory data, string memory uri) internal returns(address token,uint256 id){
        id = erc1155.mint(to, value, data, uri);

        return (address(erc1155), id);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (metatx/ERC2771Context.sol)

pragma solidity ^0.8.0;

import "../Lib/Context.sol";

/**
 * @dev Context variant with ERC2771 support.
 */
abstract contract ERC2771Context is Context {
    address private _trustedForwarder;

    constructor(address trustedForwarder) {
        _trustedForwarder = trustedForwarder;
    }

    function isTrustedForwarder(address forwarder) public view virtual returns (bool) {
        return forwarder == _trustedForwarder;
    }

    function _msgSender() internal view virtual override returns (address sender) {
        if (isTrustedForwarder(msg.sender)) {
            // The assembly code is more direct than the Solidity version using `abi.decode`.
            assembly {
                sender := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            return super._msgSender();
        }
    }

    function _msgData() internal view virtual override returns (bytes calldata) {
        if (isTrustedForwarder(msg.sender)) {
            return msg.data[:msg.data.length - 20];
        } else {
            return super._msgData();
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

abstract contract IMintComp {
    event MintERC721(address indexed token,uint256 indexed tokenId);
    event MintERC1155(address indexed token,uint256 indexed tokenId);

    struct Royalty{
        address maker;
        uint256 rate;
    }

    function mintERC721(address to, string memory uri, uint256 rate) virtual external;
    function mintERC1155(address to, uint256 value, string memory uri, uint256 rate) virtual public;

    function getRoyalty(address token, uint256 id) virtual public view returns(address maker,uint256 rate);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../meta-tx/ERC2771Context.sol";

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
abstract contract Ownable is ERC2771Context {
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Mint {
    function mint(address to, string memory uri) external returns(uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155Mint {
    function mint(address account, uint256 amount, bytes memory data, string memory uri)external returns(uint256);

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data, string[] memory uris) external;
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