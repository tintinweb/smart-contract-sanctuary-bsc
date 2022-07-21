/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IERC721 {
	function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

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

contract HyperwalkBridgeNft is Ownable {
	struct Item {
		address Owner;
		address token;
		uint tokenId;
        bool onServer;
	}

	mapping(uint => Item) itemList;
    mapping(address => bool) nftApproveList;
    uint private _bridgeId = 0;
    uint256 total = 0;
    address public ADMIN_ADDRESS;

    event itemToServer(uint256 bridgeId, address token ,uint256 itemId, address owner);
    event itemOffServer(uint256 bridgeId, address token ,uint256 itemId, address owner);

    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(
            '\x19Ethereum Signed Message:\n32', hash ));
    }

    function recoverSigner(bytes32 message, bytes memory sig)
        internal
        pure
        returns (address)
    {
        uint8 v;
        bytes32 r;
        bytes32 s;
        (v, r, s) = splitSignature(sig);
        return ecrecover(message, v, r, s);
    }

    function splitSignature(bytes memory sig)
        internal
        pure
        returns (uint8, bytes32, bytes32)
        {
        require(sig.length == 65);
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
            }
            return (v, r, s);
    }

    function setAdmin(address admin) public onlyOwner {
        ADMIN_ADDRESS = admin;
    }

    function sendItemToServer(address token, uint256 itemId) public {
		IERC721(token).transferFrom(msg.sender, address(this), itemId);
        require(nftApproveList[token] == true);

		Item memory item = Item(
			msg.sender,
			token,
			itemId,
            true
		);

		_bridgeId++;
		total++;

		itemList[_bridgeId] = item;

        emit itemToServer(_bridgeId, token, itemId, msg.sender);
    }

    function takeItemOffServer(uint256 bridgeId, bytes calldata _signature) public {
        Item memory currentItem = itemList[bridgeId];
        require(nftApproveList[currentItem.token] == true);
        require(ADMIN_ADDRESS != address(0));

        bytes32 message = prefixed(keccak256(abi.encodePacked(
            currentItem.token,
            currentItem.tokenId,
            bridgeId
        )));

        require(recoverSigner(message, _signature) == ADMIN_ADDRESS, 'wrong signature'); 

        IERC721(currentItem.token).transferFrom(address(this), msg.sender, currentItem.tokenId);

		Item memory newItem = Item(
			msg.sender,
			currentItem.token,
			currentItem.tokenId,
            false
		);

		itemList[bridgeId] = newItem;

        emit itemOffServer(bridgeId, currentItem.token, currentItem.tokenId, msg.sender);
    } 

    function emergencyWithdraw(uint256 bridgeId) public onlyOwner {
        Item memory currentItem = itemList[bridgeId];

        IERC721(currentItem.token).transferFrom(address(this), msg.sender, currentItem.tokenId);

		Item memory newItem = Item(
			msg.sender,
			currentItem.token,
			currentItem.tokenId,
            false
		);

		itemList[bridgeId] = newItem;

        emit itemOffServer(bridgeId, currentItem.token, currentItem.tokenId, msg.sender);
    } 

    function getItemDetail(uint256 bridgeId) public view returns (address owner, address tokenAddress, uint256 id, bool isOnServer ) {
        owner = itemList[bridgeId].Owner;
        tokenAddress = itemList[bridgeId].token;
        id= itemList[bridgeId].tokenId;
        isOnServer = itemList[bridgeId].onServer;
    }

    function getTotalBridge() public view returns (uint256 totalBridge) {
        totalBridge = total;
    }

    function setNFTApproval(address token ,bool approve) public onlyOwner {
        nftApproveList[token] = approve;
    }
}