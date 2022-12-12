/**
 *Submitted for verification at BscScan.com on 2022-12-12
*/

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


    string public name;
    mapping(address => mapping(string => Order)) booking;

    constructor(
        string memory _name,
        address _owner
    ) {
        name = _name;
        changeOwner(_owner);
    }

    function pay(uint256 amount, string memory orderId, string memory merchantId) public payable {
      address user = msg.sender;
      Order storage order = booking[user][orderId];

      if(order.status == Status.PAIDED) {
        revert("Order already paid");
      }

      uint256 received = msg.value;
      require(received >= amount, "Amount not enough");

      booking[user][orderId] = Order(
        orderId,
        user,
        amount,
        merchantId,
        Status.PAIDED,
        block.timestamp
      );
    }
}