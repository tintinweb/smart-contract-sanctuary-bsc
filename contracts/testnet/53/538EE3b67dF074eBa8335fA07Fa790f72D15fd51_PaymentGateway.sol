/**
 *Submitted for verification at BscScan.com on 2022-12-20
*/

// File: contracts/Owner.sol

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.14;

/**
 * @title Owner
 * @dev Set & change owner
 */
contract Owner {
  address private owner;

  // event for EVM logging
  event OwnerSet(address indexed oldOwner, address indexed newOwner);

  // modifier to check if caller is owner
  modifier isOwner() {
    // If the first argument of 'require' evaluates to 'false', execution terminates and all
    // changes to the state and to Ether balances are reverted.
    // This used to consume all gas in old EVM versions, but not anymore.
    // It is often a good idea to use 'require' to check if functions are called correctly.
    // As a second argument, you can also provide an explanation about what went wrong.
    require(msg.sender == owner, "Caller is not owner");
    _;
  }

  /**
   * @dev Set contract deployer as owner
   */
  constructor() {
    owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
    emit OwnerSet(address(0), owner);
  }

  /**
   * @dev Change owner
   * @param newOwner address of new owner
   */
  function changeOwner(address newOwner) public isOwner {
    emit OwnerSet(owner, newOwner);
    owner = newOwner;
  }

  /**
   * @dev Return owner address
   * @return address of owner
   */
  function getOwner() external view returns (address) {
    return owner;
  }
}

// File: contracts/PaymentGateway.sol


pragma solidity >=0.8.14;

contract PaymentGateway is Owner {
  enum Status {
    UN_PAIDED,
    PAIDED
  }

  struct Order {
    string orderId;
    address user;
    uint256 amount;
    string merchantId;
    Status status;
    uint256 createdAt;
  }

  struct Withdraw {
    bytes32 wHash;
    address callBy;
    uint256 amount;
    address recipient;
    uint256 createdAt;
  }

  event OrderEvent(
    string orderId,
    address user,
    uint256 amount,
    string merchantId,
    Status status,
    uint256 createdAt
  );

  event WithdrawEvent(
    bytes32 wHash,
    address callBy,
    uint256 amount,
    address recipient,
    uint256 createdAt
  );

  string public name;
  uint256 public totalAmount;
  uint256 public totalWithdrawAmount;

  string[] orderIds;
  bytes32[] withdrawHashs;

  mapping(string => Order) public orders;
  mapping(bytes32 => Withdraw) public withdraws;

  constructor(string memory _name, address _owner) {
    name = _name;
    changeOwner(_owner);
  }

  function pay(
    uint256 amount,
    string memory orderId,
    string memory merchantId
  ) public payable {
    // Validate
    address user = msg.sender;

    Order storage order = orders[orderId];
    require(order.status != Status.PAIDED, "Order already paid");

    uint256 received = msg.value;
    require(received >= amount, "Received not enough");

    // Process
    totalAmount = totalAmount + received;

    Order memory record = Order(
      orderId,
      user,
      amount,
      merchantId,
      Status.PAIDED,
      block.timestamp
    );

    orders[orderId] = record;
    orderIds.push(orderId);

    // Event
    emit OrderEvent(
      record.orderId,
      record.user,
      record.amount,
      record.merchantId,
      record.status,
      record.createdAt
    );
  }

  function withdraw(uint256 amount, address payable recipient) public isOwner {
    // Validate
    require(address(this).balance >= amount, "Balance not enough");

    // Process
    bytes32 wHash = keccak256(
      abi.encodePacked(msg.sender, amount, recipient, block.timestamp)
    );

    Withdraw memory record = Withdraw(
      wHash,
      msg.sender,
      amount,
      recipient,
      block.timestamp
    );

    withdraws[wHash] = record;
    withdrawHashs.push(wHash);
    recipient.transfer(amount);
    totalWithdrawAmount = totalWithdrawAmount + amount;

    // Event
    emit WithdrawEvent(
      record.wHash,
      record.callBy,
      record.amount,
      record.recipient,
      record.createdAt
    );
  }

  function getOrders() public view returns (Order[] memory) {
    Order[] memory records = new Order[](orderIds.length);
    for (uint256 i = 0; i < orderIds.length; i++) {
      records[i] = orders[orderIds[i]];
    }
    return records;
  }

  function getWithdraws() public view returns (Withdraw[] memory) {
    Withdraw[] memory records = new Withdraw[](withdrawHashs.length);
    for (uint256 i = 0; i < withdrawHashs.length; i++) {
      records[i] = withdraws[withdrawHashs[i]];
    }
    return records;
  }

  function totalOrders() public view returns (uint256) {
    return orderIds.length;
  }

  function totalWithdraws() public view returns (uint256) {
    return withdrawHashs.length;
  }
}