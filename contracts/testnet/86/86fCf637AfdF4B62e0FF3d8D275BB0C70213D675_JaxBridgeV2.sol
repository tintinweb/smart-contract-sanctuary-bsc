// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract JaxBridgeV2 {

  uint chainId;
  
  uint fee = 50;

  address public admin;

  IERC20 public wjxn = IERC20(0xA25946ec9D37dD826BbE0cbDbb2d79E69834e41e);

  enum RequestStatus {Init, Proved, Rejected, Expired, Released}

  struct Request {
    uint amount;
    uint deposit_address_id;
    uint valid_until;
    address to;
    RequestStatus status;
    string from;
    string txHash;
  }

  string[] public deposit_addresses;
  uint[] public deposit_address_locktimes;

  Request[] public requests;

  mapping(address => uint[]) public user_requests;

  address[] public bridge_operators;
  mapping(address => uint) operating_limits;

  event Create_Request(
    uint request_id,
    uint amount,
    string from,
    uint depoist_address_id,
    uint valid_until
  );

  event Prove_Request(
    uint request_id
  );

  event Reject_Request(
    uint request_id
  );

  event Release(
    uint request_id,
    address from,
    uint amount
  );


  event Set_Fee(
    uint fee
  );


  event Set_Operating_Limit(
    address operator,
    uint operating_limit
  );

  event Free_Deposit_Address(
    uint deposit_address_id
  );

  constructor() {
    admin = msg.sender;
    uint _chainId;
    assembly {
        _chainId := chainid()
    }
    chainId = _chainId;
  }

  modifier onlyAdmin() {
    require(admin == msg.sender, "Only Admin can perform this operation.");
    _;
  }


  modifier bridgeOperator(uint amount) {
    require(isBridgeOperator(msg.sender), "Not a bridge operator");
    require(operating_limits[msg.sender] >= amount, "Amount exceeds operating limit");
    _;
    operating_limits[msg.sender] -= amount;
  }


  function deposit(uint amount) external onlyAdmin {
    wjxn.transferFrom(admin, address(this), amount);
  }

  function withdraw(uint amount) external onlyAdmin {
    wjxn.transfer(admin, amount);
  }

  function add_deposit_addresses(string[] calldata new_addresses) external {
    for(uint i = 0; i < new_addresses.length; i += 1) {
      deposit_addresses.push(new_addresses[i]);
      deposit_address_locktimes.push(0);
    }
  }

  function create_request(uint amount, address to, string calldata from) external {
    require(amount >= 100, "Min amount 100");
    Request memory request;
    request.amount = amount;
    request.to = to;
    request.from = from;
    uint request_id = requests.length;

    uint i = 0;
    for(; i <= deposit_addresses.length; i += 1) {
      if(deposit_address_locktimes[i] == 0)
        break;
    }
    require(i < deposit_addresses.length, "All deposit addresses are active");
    request.deposit_address_id = i;
    uint valid_until = block.timestamp + 48 hours;
    request.valid_until = valid_until;
    deposit_address_locktimes[i] = valid_until;
    requests.push(request);
    user_requests[to].push(request_id);
    emit Create_Request(request_id, amount, from, i, valid_until);
  }

  function prove_request(uint request_id, string calldata txHash) external {
    Request storage request = requests[request_id];
    require(request.to == msg.sender, "Invalid account");
    require(request.status == RequestStatus.Init, "Invalid status");
    require(request.valid_until >= block.timestamp, "Expired");
    request.txHash = txHash;
    request.status = RequestStatus.Proved;
    emit Prove_Request(request_id);
  }

  function reject_request(uint request_id) external onlyAdmin {
    Request storage request = requests[request_id];
    // require(request.status == RequestStatus.Init, "Invalid status");
    request.status = RequestStatus.Rejected;
    emit Reject_Request(request_id);
  }

  function release(
    uint request_id,
    uint amount,
    string calldata from,
    address to,
    string calldata txHash
  ) external bridgeOperator(amount) {
    Request storage request = requests[request_id];
    require(request.status == RequestStatus.Proved, "Invalid status");
    require(request.amount == amount, "amount mismatch");
    require(keccak256(abi.encodePacked(request.from)) == keccak256(abi.encodePacked(from)), "Sender's address mismatch");
    require(request.to == to, "destination address mismatch");
    require(keccak256(abi.encodePacked(request.txHash)) == keccak256(abi.encodePacked(txHash)), "Tx Hash mismatch");
    request.txHash = txHash;
    deposit_address_locktimes[request.deposit_address_id] = 0;
    request.status = RequestStatus.Released;
    wjxn.transfer(request.to, request.amount - fee);
    emit Release(request_id, request.to, request.amount - fee);
  }

  function get_user_requests(address user) external view returns(uint[] memory) {
    return user_requests[user];
  }

  function withdrawByAdmin(address token, uint amount) external onlyAdmin {
      IERC20(token).transfer(msg.sender, amount);
  }

  function add_bridge_operator(address operator, uint operating_limit) external onlyAdmin {
    for(uint i = 0; i < bridge_operators.length; i += 1) {
      if(bridge_operators[i] == operator)
        revert("Already exists");
    }
    bridge_operators.push(operator);
    operating_limits[operator] = operating_limit;
  }

  function isBridgeOperator(address operator) public view returns(bool) {
    uint i = 0;
    for(; i < bridge_operators.length; i += 1) {
      if(bridge_operators[i] == operator)
        return true;
    } 
    return false;
  }

  function set_operating_limit(address operator, uint operating_limit) external onlyAdmin {
    require(isBridgeOperator(msg.sender), "Not a bridge operator");
    operating_limits[operator] = operating_limit;
    emit Set_Operating_Limit(operator, operating_limit);
  }

  function set_fee(uint _fee) external onlyAdmin {
    fee = _fee;
    emit Set_Fee(fee);
  }

  function free_deposit_addresses() external onlyAdmin  {
    for(uint i = 0; i < deposit_address_locktimes.length; i += 1) {
      if(deposit_address_locktimes[i] < block.timestamp) {
        deposit_address_locktimes[i] = 0;
        emit Free_Deposit_Address(i);
      }
    }
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}