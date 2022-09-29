/**
 *Submitted for verification at BscScan.com on 2022-09-28
*/

// Sources flattened with hardhat v2.9.9 https://hardhat.org

// SPDX-License-Identifier: MIT

// File @openzeppelin/contracts/utils/[email protected]

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


// File @openzeppelin/contracts/access/[email protected]

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

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


// File contracts/NFT11/ForTest/NFT11RedPacket.sol

pragma solidity ^0.8.4;

contract NFT11RedPacket is Ownable {
    address public openContract;

    mapping(address => uint8[]) private holdersOwnList;

    function userRedPacketAmount(address _userAddress)
        external
        view
        returns (uint256)
    {
        return holdersOwnList[_userAddress].length;
    }

    function userRedPacketByIndex(address _userAddress, uint256 _index)
        external
        view
        returns (uint8)
    {
        return holdersOwnList[_userAddress][_index];
    }

    function userOwnedRedPacketByTier(address _userAddress, uint8 _tier)
        external
        view
        returns (bool _owned, int8 _index)
    {
        _index = -1;
        for (uint256 i = 0; i < holdersOwnList[_userAddress].length; i++) {
            if (holdersOwnList[_userAddress][i] == _tier) {
                _index = int8(int256(i));
                _owned = true;
                break;
            }
        }
    }

    function updateOpenContract(address _contract) external onlyOwner {
        openContract = _contract;
    }

    function burnPacket(address _userAddress, uint256 _index) external {
        address senderAddress = _msgSender();
        require(senderAddress == openContract, "Not Allowed");
        uint256 ownListLength = holdersOwnList[_userAddress].length;
        require(_index < ownListLength, "Invalid `_index`");
        holdersOwnList[_userAddress][_index] = holdersOwnList[_userAddress][
            ownListLength - 1
        ];
        holdersOwnList[_userAddress].pop();
    }

    function setPackets(address _user) external onlyOwner {
        for (uint256 i = 0; i < 3; i++) {
            holdersOwnList[_user].push(1);
        }
        for (uint256 i = 0; i < 3; i++) {
            holdersOwnList[_user].push(2);
        }
        for (uint256 i = 0; i < 3; i++) {
            holdersOwnList[_user].push(3);
        }
    }
}