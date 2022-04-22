/**
 *Submitted for verification at BscScan.com on 2022-04-22
*/

// File: @openzeppelin/contracts/utils/Counters.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// File: @openzeppelin/contracts/utils/Context.sol

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

// File: @openzeppelin/contracts/access/Ownable.sol

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

// File: contracts/interface/IMetaNFT.sol

pragma solidity >=0.4.22 <0.9.0;

interface IMetaNFT {
    function safeMintMetaStone(address to) external returns (uint256);

    function safeMintRuby(address to) external returns (uint256);

    function safeMintCrown(address to) external returns (uint256);
}

// File: contracts/interface/IMelter.sol

pragma solidity >=0.4.22 <0.9.0;

interface IMelter {
    function minterMint(address to) external returns (uint256);

    function levelUp(uint256 _tokenId) external;
}

// File: contracts/blindBox/BlindBoxPreSale.sol

pragma solidity >=0.4.22 <0.9.0;

contract BlindBoxPreSale is Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _orderId;

    address payable public feeTo;
    address public signer;
    struct Order {
        uint256 id;
        address buyer;
        uint256 solt;
        bool withdraw;
    }
    struct Open {
        uint256 id;
        address nftAddress;
        uint256 typeId;
        address owner;
        uint256 endTime;
        uint256 solt;
    }

    struct RSV {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }
    uint256 public blindBoxPrice;

    mapping(address => Order[]) public ordersByBuyer;
    mapping(uint256 => address) public ordersBySolt;

    event OrderCreated(uint256 id, address buyer, uint256 solt);
    event OpenBox(
        uint256 id,
        address nftAddress,
        uint256 typeId,
        address owner,
        uint256 endTime,
        uint256 solt
    );

    constructor(uint256 _price, address _signer) {
        feeTo = payable(msg.sender);
        _orderId.increment();
        blindBoxPrice = _price;
        signer = _signer;
    }

    receive() external payable {}

    function buy() public payable {
        require(_orderId.current() < 2001, "Sold Out");
        require(msg.value >= blindBoxPrice, "Insufficient funds");
        feeTo.transfer(msg.value);
        uint256 id = _orderId.current();
        uint256 solt = uint256(keccak256(abi.encodePacked(msg.sender, id)));
        ordersByBuyer[msg.sender].push(Order(id, msg.sender, solt, false));
        ordersBySolt[solt] = msg.sender;
        _orderId.increment();
        emit OrderCreated(id, msg.sender, solt);
    }

    function getUserOrderNum(address user) public view returns (uint256) {
        return ordersByBuyer[user].length;
    }

    function getUserOrderHash(address user, uint256 index)
        public
        view
        returns (uint256)
    {
        return ordersByBuyer[user][index].solt;
    }

    function getSoltUser(uint256 solt) public view returns (address) {
        return ordersBySolt[solt];
    }

    function open(Open calldata info, RSV calldata sig)
        external
        returns (uint256)
    {
        require(info.owner == msg.sender, "You are not the owner");
        require(info.owner == getSoltUser(info.solt), "You are not the owner");
        require(check(info, sig), "Invalid signature");
        require(checkOrder(_msgSender(), info.id), "Invalid order");
        uint256 tokenId = giveToUser(info);
        changeState(_msgSender(), info.id);
        emit OpenBox(
            tokenId,
            info.nftAddress,
            info.typeId,
            info.owner,
            info.endTime,
            info.solt
        );
        return tokenId;
    }

    function check(Open calldata info, RSV calldata sig)
        internal
        view
        returns (bool)
    {
        require(info.endTime < block.timestamp, "Expired");
        bytes memory cat = abi.encode(
            info.id,
            info.nftAddress,
            info.typeId,
            info.owner,
            info.endTime,
            info.solt
        );
        bytes32 hash = keccak256(cat);
        bytes32 data = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
        );
        address recovered = ecrecover(data, sig.v, sig.r, sig.s);

        return recovered == signer;
    }

    function giveToUser(Open calldata info) internal returns (uint256) {
        address nft = info.nftAddress;
        if (info.typeId == 0) {
            return IMelter(nft).minterMint(info.owner);
        }
        if (info.typeId == 1) {
            return IMetaNFT(nft).safeMintMetaStone(info.owner);
        }
        if (info.typeId == 2) {
            return IMetaNFT(nft).safeMintRuby(info.owner);
        }
        if (info.typeId == 3) {
            return IMetaNFT(nft).safeMintCrown(info.owner);
        }
        return 0;
    }

    function changeState(address user, uint256 id) internal {
        for (uint256 i = 0; i < ordersByBuyer[user].length; i++) {
            if (ordersByBuyer[user][i].id == id) {
                ordersByBuyer[user][i].withdraw = true;
                return;
            }
        }
    }

    function checkOrder(address user, uint256 id) internal view returns (bool) {
        for (uint256 i = 0; i < ordersByBuyer[user].length; i++) {
            if (
                ordersByBuyer[user][i].id == id &&
                ordersByBuyer[user][i].withdraw == false
            ) {
                return true;
            }
        }
        return false;
    }

    function setSigner(address _signer) external onlyOwner {
        signer = _signer;
    }
}