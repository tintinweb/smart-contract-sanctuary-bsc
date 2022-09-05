pragma solidity ^0.8.4;

import "../includes/access/Ownable.sol";
import "../includes/interfaces/IERC721Receiver.sol";

interface IEternalZombies {
    function name() external view returns(string memory);
    function symbol() external view returns(string memory);
    function totalSupply() external view returns(uint);
    function balanceOf(address) external view returns(uint);
    function baseURI() external view returns(string memory);
    function tokenURI(uint) external view returns(string memory);
    function nftPrice() external view returns(uint);
    function TOKEN_ID() external view returns(uint);
    function ownerOf(uint) external view returns(address);
    function mint(uint) external payable;
    function transferFrom(address, address, uint) external;
}

contract EternalZombiesMintingProxy is Ownable, IERC721Receiver {
    IEternalZombies public eternalZombies;

    constructor(IEternalZombies _eternalZombies) {
        eternalZombies = _eternalZombies;
    }

    fallback() external payable{}

    function onERC721Received(address, address, uint256, bytes calldata) public override pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    function mint(address to) public {
        uint nftPrice = eternalZombies.nftPrice();
        require(address(this).balance >= nftPrice, "Proxy: Insufficient Balance");
        eternalZombies.mint{ value: nftPrice }(1);
        eternalZombies.transferFrom(address(this), to, eternalZombies.TOKEN_ID());
    }

    function name() public view returns(string memory) {
        return eternalZombies.name();
    }

    function symbol() public view returns(string memory) {
        return eternalZombies.symbol();
    }

    function totalSupply() public view returns(uint) {
        return eternalZombies.totalSupply();
    }

    function balanceOf(address _holder) public view returns(uint) {
        return eternalZombies.balanceOf(_holder);
    }

    function ownerOf(uint _tokenId) public view returns(address) {
        return eternalZombies.ownerOf(_tokenId);
    }

    function baseURI() public view returns(string memory) {
        return eternalZombies.baseURI();
    }

    function tokenURI(uint _tokenId) view public returns(string memory) {
        return eternalZombies.tokenURI(_tokenId);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

/*
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

    function _msgData() internal view virtual returns ( bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

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
    constructor()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}