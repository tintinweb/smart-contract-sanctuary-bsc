// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

/*
 * Legacy version for reference and backward compatibility, similar to OwnableDocumentStore
 */
contract OrderStore is Ownable {

  bytes32 public constant NVKD_ROLE = keccak256("NVKD_ROLE"); // Nhan vien kinh doanh
  bytes32 public constant NVDP_ROLE = keccak256("NVDP_ROLE"); // Nhan vien dieu phoi
  bytes32 public constant NVGH_ROLE = keccak256("NVGH_ROLE"); // Nhan vien giao hang
  bytes32 public constant QL_ROLE = keccak256("QL_ROLE"); // Quan ly
  bytes32 public constant SHOP_ROLE = keccak256("SHOP_ROLE"); // Shop
  bytes32 public constant NCC_ROLE = keccak256("NCC_ROLE"); // Nha cung cap

  string name;
  // accepted = Xác nhận
  // call_ship = Giao ship lấy hàng
  // taked = Ship đã lấy hàng
  // warehouse = Giao kho
  // delivering = Đang giao hàng
  // delivery_success = Giao hàng thành công
  // rejected = Trả lại hàng
  // return_warehouse = Nhập lại kho
  // return_shop = Trả shop thành công
  // cancel = Hủy vận đơn
  // checking = Đang đối soát
  // checked = Đã đối soát
  // wait_deposit = Chờ cọc
  // deposited = Đã đặt cọc
  enum OrderStatus {
    accepted, 
    call_ship,
    taked,
    warehouse,
    delivering,
    delivery_success,
    rejected,
    return_warehouse,
    return_shop,
    cancel,
    checking,
    checked,
    wait_deposit, 
    deposited 
  }

  struct StatusHistory {
    OrderStatus status;
    uint256 atBlock;
  }

  struct Consensus {
    bool verified;
    uint256 timestamp;
  }

  /// A mapping of the order id to the hash that was issued
  mapping(string => bytes32) public orders;

  /// A mapping of the order id to order status throught time
  mapping(string => StatusHistory[]) public statusHistory;

  /// A mapping of the address to role
  mapping(address => bytes32) public roles;

  /// A mapping of role to status can accept
  mapping(bytes32 => OrderStatus[]) public rules;

  /// A mapping of consensus hash to signed
  mapping(bytes32 => mapping(address => bool)) public signatures;

  /// A mapping of consensus hash to signed
  mapping(string => mapping(bytes32 => Consensus)) public consensusTx;

  address[] public signers;

  uint256 public constant requires = 2; // Nha cung cap

  event OrderUpload(string orderId, bytes32 orderHash, address sender );
  event UpdateStatus(string orderId, OrderStatus status, address sender);
  event Sign(string id, bytes32 data, address signers);
  event Verify(string id, bytes32 data);

  constructor() public {
    roles[msg.sender] = NVKD_ROLE;
    signers.push(msg.sender);
    initRules();
  }

  function initRules() internal {
    rules[NVKD_ROLE].push(OrderStatus.accepted);
    rules[NVKD_ROLE].push(OrderStatus.cancel);
    rules[NVKD_ROLE].push(OrderStatus.return_shop);
    rules[NVKD_ROLE].push(OrderStatus.checked);
    rules[NVKD_ROLE].push(OrderStatus.checking);
    rules[NVDP_ROLE].push(OrderStatus.call_ship);
    rules[NVGH_ROLE].push(OrderStatus.taked);
    rules[NVGH_ROLE].push(OrderStatus.warehouse);
    rules[NVGH_ROLE].push(OrderStatus.delivering);
    rules[NVGH_ROLE].push(OrderStatus.rejected);
    rules[NVGH_ROLE].push(OrderStatus.return_warehouse);
    rules[NVGH_ROLE].push(OrderStatus.deposited);
  }

  function issue(string memory orderId, bytes32 orderHash) public onlyOwner {
    require(statusHistory[orderId].length == 0, "Order exist");

    statusHistory[orderId].push(StatusHistory({
      status: OrderStatus.accepted,
      atBlock: block.number
    }));
    orders[orderId] = orderHash;
    emit OrderUpload(orderId, orderHash, msg.sender);
  }

  function updateOrderStatus(string memory orderId, OrderStatus status) public onlyOwner {
    require(statusHistory[orderId].length != 0, "Order not exist");
    bytes32 role = roles[msg.sender];
    OrderStatus[] memory remainStatus = rules[role];
    bool isExist = false;
    for(uint256 i=0; i < remainStatus.length; i++) {
      if(status == remainStatus[i]) {
        isExist = true;
        break;
      }
    }
    require(isExist, "No permission");
    statusHistory[orderId].push(StatusHistory({
          status: status,
          atBlock: block.number
    }));
    emit UpdateStatus(orderId, status, msg.sender);
  }

  function getOrder(string memory orderId) public view returns (bytes32, StatusHistory[] memory) {
    return (orders[orderId], statusHistory[orderId]);
  }

  function submitTransaction(string calldata id, bytes32 data)
        public
        returns (uint transactionId)
  {
    require(roles[msg.sender] == QL_ROLE || roles[msg.sender] == SHOP_ROLE || roles[msg.sender] == NCC_ROLE, "Not permission");
    addTransaction(id, data);
    signatures[data][msg.sender] = true;
    emit Sign(id, data, msg.sender);
    confirmTransaction(id,data);
  }

  function addTransaction(string calldata id, bytes32 data)
        public
    {
        if(consensusTx[id][data].timestamp != 0) {
          return;
        } else {
          consensusTx[id][data] = Consensus({
            verified: false,
            timestamp: block.timestamp
          });
        }
    }

  function confirmTransaction(string calldata id, bytes32 data)
        public
    {
        uint256 count = 0;
        for(uint256 i = 0 ; i < signers.length; i++) {
          if(signatures[data][signers[i]] == true) {
            count++;
          }
        }
        if(count == requires) {
          consensusTx[id][data].verified = true;
          emit Verify(id, data);
        }
    }
  
  function setSigner(address signer) onlyOwner public {
    signers.push(signer);
  }

  function setRole(address user, bytes32 role) public {
    roles[user] = role;
  }

}

// SPDX-License-Identifier: MIT

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

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