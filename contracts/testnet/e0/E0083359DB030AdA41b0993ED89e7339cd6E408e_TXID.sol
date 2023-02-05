// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

interface IGetMintContract {
    struct Cart {
        address spaceContract;
        uint256[] tokenId;
        uint256[] count;
    }

    function CheckCart(Cart memory cart) external view returns (uint256);

    function CheckCarts(Cart[] memory cart) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./interfaces/IGetMintContract.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IPriceFeed {
    function getLatestPrice() external view returns (uint256);
}

contract TXID is Ownable {
    address developer;
    struct TransactionID {
        bytes32 TX;
        uint8 status;
        uint256 id;
        address user;
        uint256 amount;
        uint256 realAmount;
        bool approved;
        mapping(uint256 => IGetMintContract.Cart) cart;
    }
    uint256 count;
    address[] public SpaceSixContracts;
    IPriceFeed PriceFeed;
    IGetMintContract SpaceSixPrice;
    mapping(address => mapping(uint256 => TransactionID)) public TxUser;
    mapping(bytes32 => TransactionID) public TxID;
    mapping(uint256 => TransactionID) public TxIndex;
    mapping(address => uint256) public TXCount;
    mapping(bytes32 => bool) public TX_approved;

    constructor(address _spaceSixPrice, address _developer) {
        developer = _developer;
        SpaceSixPrice = IGetMintContract(_spaceSixPrice);
        PriceFeed = IPriceFeed(0xbc66fE8d432cc5E01D5A688778ba299057526f00);
    }

    modifier onlyDeveloper(address _developer) {
        require(_developer == developer);
        _;
    }

    receive() external payable {
        uint256 id = TXCount[msg.sender];
        TxUser[msg.sender][id].amount = msg.value;
        TxUser[msg.sender][id].status = 1;
        TxUser[msg.sender][id].user = msg.sender;
        TxUser[msg.sender][id].id = count;
        TxUser[msg.sender][id].TX = 0x0;
        TXCount[msg.sender]++;
        TxIndex[count].amount = msg.value;
        TxIndex[count].status = 1;
        TxIndex[count].user = msg.sender;
        TxIndex[count].id = id;
        TxIndex[count].TX = 0x0;
        count++;
    }

    function toBnbPrice(uint256 amount) public view returns (uint256) {
        uint256 bnb = uint256(PriceFeed.getLatestPrice());
        uint256 Price = amount * 10**18;
        bnb = bnb * 10**10;
        Price = Price / bnb;
        Price = Price / 10**15;
        Price = Price * 10**15;
        return Price;
    }

    function approveTX(
        address _from,
        address to,
        uint256 value,
        bytes32 _tx,
        IGetMintContract.Cart[] memory _cart
    ) public onlyDeveloper(msg.sender) returns (uint8) {
        address from = _from;
        uint8 _status = 3;
        if (to == address(this)) {
            for (uint256 i = 0; i < TXCount[from]; i++) {
                if (TxUser[from][i].status == 1) {
                    uint256 _value = TxUser[from][i].amount;
                    if (value == _value) {
                        TxUser[from][i].TX = _tx;
                        for (uint256 j = 0; j < _cart.length; j++) {
                            TxUser[from][j].cart[j] = _cart[j];
                            TxID[_tx].cart[j] = _cart[j];
                            TxIndex[TxUser[from][i].id].cart[j] = _cart[j];
                        }
                        uint256 amount = SpaceSixPrice.CheckCarts(_cart);
                        uint256 bnbValue = toBnbPrice(amount);
                        uint256 min = (bnbValue / 100) * 95;
                        if (value >= min) {
                            _status = 2;
                            TxUser[from][i].status = 2;
                            TX_approved[_tx] = true;
                        } else {
                            TxUser[from][i].status = 3;
                            TX_approved[_tx] = false;
                        }
                        TxID[_tx].TX = _tx;
                        TxID[_tx].status = TxUser[from][i].status;
                        TxID[_tx].id = TxUser[from][i].id;
                        TxID[_tx].user = TxUser[from][i].user;
                        TxID[_tx].amount = TxUser[from][i].amount;
                        TxID[_tx].realAmount = TxUser[from][i].realAmount;
                        TxID[_tx].approved = TxUser[from][i].approved;
                        uint256 index = TxUser[from][i].id;
                        TxIndex[index].TX = _tx;
                        TxIndex[index].status = TxUser[from][i].status;
                        TxIndex[index].id = TxUser[from][i].id;
                        TxIndex[index].user = TxUser[from][i].user;
                        TxIndex[index].amount = TxUser[from][i].amount;
                        TxIndex[index].realAmount = TxUser[from][i].realAmount;
                        TxIndex[index].approved = TxUser[from][i].approved;
                        break;
                    }
                }
            }
        }
        return _status;
    }

    function witdraw(uint256 amount) external onlyOwner {
        payable(owner()).transfer(amount);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}