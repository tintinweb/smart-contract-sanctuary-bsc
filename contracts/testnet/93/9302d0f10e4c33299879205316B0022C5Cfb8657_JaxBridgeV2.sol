// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract JaxBridgeV2 {

  uint chainId;
  
  uint public fee_percent = 5e5; // 0.5 %
  uint public minimum_fee_amount = 50; // 50 WJXN

  address public admin;

  uint public penalty_amount = 0;

  address public penalty_wallet;

  IERC20 public wjxn = IERC20(0xA25946ec9D37dD826BbE0cbDbb2d79E69834e41e);


  enum RequestStatus {Init, Proved, Rejected, Expired, Released}

  struct Request {
    uint deposit_address_id;
    uint amount;
    bytes32 amount_hash;
    bytes32 txdHash;
    uint valid_until;
    uint prove_timestamp;
    address to;
    RequestStatus status;
    string from;
    string txHash;
  }

  string[] public deposit_addresses;
  uint[] public deposit_address_locktimes;
  mapping(uint => bool) public deposit_address_deleted;
  mapping(uint => uint) public deposit_address_requests;

  Request[] public requests;

  mapping(address => uint[]) public user_requests;

  address[] public bridge_operators;
  mapping(address => uint) operating_limits;

  mapping(bytes32 => bool) proccessed_txd_hashes;

  event Create_Request(uint request_id, uint amount, string from, uint depoist_address_id, uint valid_until);
  event Prove_Request(uint request_id);
  event Expire_Request(uint request_id);
  event Reject_Request(uint request_id);
  event Release(uint request_id, address from, uint amount);
  event Set_Fee(uint fee_percent, uint minimum_fee_amount);
  event Set_Operating_Limit(address operator, uint operating_limit);
  event Free_Deposit_Address(uint deposit_address_id);
  event Set_Penalty_Wallet(address wallet);
  event Set_Admin(address admin);
  event Delete_Deposit_Addresses(uint[] ids);
  event Add_Penalty_Amount(uint amount, bytes32 info_hash);
  event Subtract_Penalty_Amount(uint amount, bytes32 info_hash);

  constructor() {
    admin = msg.sender;
    uint _chainId;
    assembly {
        _chainId := chainid()
    }
    chainId = _chainId;
    penalty_wallet = msg.sender;
  }

  modifier onlyAdmin() {
    require(admin == msg.sender, "Only Admin can perform this operation.");
    _;
  }


  modifier onlyOperator() {
    require(isBridgeOperator(msg.sender), "Not a bridge operator");
    _;
  }

  modifier isValidDepositAddress(uint deposit_address_id) {
    require(deposit_address_deleted[deposit_address_id] == false, "Deposit address deleted");
    _;
  }

  function deposit(uint amount) external onlyAdmin {
    wjxn.transferFrom(admin, address(this), amount);
  }

  function withdraw(uint amount) external onlyAdmin {
    wjxn.transfer(admin, amount);
  }

  function add_deposit_addresses(string[] calldata new_addresses) external onlyAdmin {
    for(uint i = 0; i < new_addresses.length; i += 1) {
      deposit_addresses.push(new_addresses[i]);
      deposit_address_locktimes.push(0);
    }
  }

  function get_free_deposit_address_id() external view returns(uint) {
    for(uint i = 0; i < deposit_address_locktimes.length; i += 1) {
      if(deposit_address_deleted[i] == false && deposit_address_locktimes[i] == 0) return i;
    }
    revert("All deposit addresses are in use");
  }

  function create_request(uint request_id, uint amount, uint deposit_address_id, address to, string calldata from) external 
    isValidDepositAddress(deposit_address_id)
  {
    require(to == msg.sender, "destination address should be sender");
    require(request_id == requests.length, "Invalid request id");
    require(amount > minimum_fee_amount, "Below minimum amount");
    Request memory request;
    request.amount = amount;
    request.amount_hash = keccak256(abi.encodePacked(request_id, amount));
    request.to = to;
    request.from = from;
    require(deposit_address_locktimes.length > deposit_address_id, "deposit_address_id out of index");
    require(deposit_address_locktimes[deposit_address_id] == 0, "Deposit address is in use");
    request.deposit_address_id = deposit_address_id;
    deposit_address_requests[deposit_address_id] = request_id;
    uint valid_until = block.timestamp + 48 hours;
    request.valid_until = valid_until;
    deposit_address_locktimes[deposit_address_id] = valid_until;
    requests.push(request);
    user_requests[to].push(request_id);
    emit Create_Request(request_id, amount, from, deposit_address_id, valid_until);
  }

  function prove_request(uint request_id, bytes32 txdHash) external {
    Request storage request = requests[request_id];
    require(request.to == msg.sender, "Invalid account");
    require(request.status == RequestStatus.Init, "Invalid status");
    if(request.valid_until >= block.timestamp) {
      request.status = RequestStatus.Expired;
      request.prove_timestamp = block.timestamp;
      emit Expire_Request(request_id);
      return;
    }
    require(request.valid_until >= block.timestamp, "Expired");
    require(proccessed_txd_hashes[txdHash] == false, "Invalid txd hash");
    request.txdHash = txdHash;
    request.status = RequestStatus.Proved;
    request.prove_timestamp = block.timestamp;
    request.amount = 0;
    emit Prove_Request(request_id);
  }

  function reject_request(uint request_id) external onlyOperator {
    Request storage request = requests[request_id];
    require(request.status == RequestStatus.Init || request.status == RequestStatus.Proved, "Invalid status");
    request.status = RequestStatus.Rejected;
    emit Reject_Request(request_id);
  }

  function release(
    uint request_id,
    uint amount,
    string calldata from,
    address to,
    string calldata txHash
  ) external onlyOperator {
    Request storage request = requests[request_id];
    require(operating_limits[msg.sender] >= amount, "Amount exceeds operating limit");
    require(request.status == RequestStatus.Proved, "Invalid status");
    require(request.txdHash == keccak256(abi.encodePacked(txHash)), "Invalid txHash");
    require(proccessed_txd_hashes[request.txdHash] == false, "Txd hash already processed");
    require(request.amount_hash == keccak256(abi.encodePacked(request_id, amount)), "Incorrect amount");
    require(keccak256(abi.encodePacked(request.from)) == keccak256(abi.encodePacked(from)), "Sender's address mismatch");
    require(request.to == to, "destination address mismatch");
    request.txHash = txHash;
    deposit_address_locktimes[request.deposit_address_id] = 0;
    request.amount = amount;
    request.status = RequestStatus.Released;
    proccessed_txd_hashes[request.txdHash] = true;
    uint fee_amount = request.amount * fee_percent / 1e8;
    if(fee_amount < minimum_fee_amount) fee_amount = minimum_fee_amount;
    wjxn.transfer(request.to, request.amount - fee_amount);
    if(penalty_amount > 0) {
      if(penalty_amount > fee_amount) {
        wjxn.transfer(penalty_wallet, fee_amount);
        penalty_amount -= fee_amount;
      }
      else {
        wjxn.transfer(penalty_wallet, penalty_amount);
        wjxn.transfer(msg.sender, fee_amount - penalty_amount);
        penalty_amount -= penalty_amount;
      }
    }
    else {
      wjxn.transfer(msg.sender, fee_amount);
    }
    operating_limits[msg.sender] -= amount;
    emit Release(request_id, request.to, request.amount - fee_amount);
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
    require(isBridgeOperator(operator), "Not a bridge operator");
    operating_limits[operator] = operating_limit;
    emit Set_Operating_Limit(operator, operating_limit);
  }

  function set_fee(uint _fee_percent, uint _minimum_fee_amount) external onlyAdmin {
    fee_percent = _fee_percent;
    minimum_fee_amount = _minimum_fee_amount;
    emit Set_Fee(_fee_percent, _minimum_fee_amount);
  }

  function free_deposit_addresses(uint from, uint to) external onlyAdmin  {
    uint request_id;
    for(uint i = from; i < deposit_address_locktimes.length && i <= to ; i += 1) {
      if(deposit_address_locktimes[i] < block.timestamp) {
        request_id = deposit_address_requests[i];
        if(requests[request_id].status == RequestStatus.Init){
          requests[request_id].status = RequestStatus.Expired;
          deposit_address_locktimes[i] = 0;
          emit Free_Deposit_Address(i);
        }
      }
    }
  }

  function delete_deposit_addresses(uint[] calldata ids) external onlyAdmin {
    uint id;
    for(uint i = 0; i < ids.length; i += 1) {
      id = ids[i];
      require(deposit_address_locktimes[i] == 0, "Active deposit address");
      deposit_address_deleted[id] = true;
    }
    emit Delete_Deposit_Addresses(ids);
  }

  function set_penalty_wallet(address _penalty_wallet) external onlyAdmin {
    penalty_wallet = _penalty_wallet;
    emit Set_Penalty_Wallet(_penalty_wallet);
  }

  function set_admin(address _admin) external onlyAdmin {
    admin = _admin;
    emit Set_Admin(_admin);
  }

  function get_new_request_id() external view returns(uint) {
    return requests.length;
  }

  function get_deposit_addresses() external view returns(string[] memory) {
    return deposit_addresses;
  }
  
  function add_penalty_amount(uint amount, bytes32 info_hash) external onlyAdmin {
    penalty_amount += amount;
    emit Add_Penalty_Amount(amount, info_hash);
  }

  function subtract_penalty_amount(uint amount, bytes32 info_hash) external onlyAdmin {
    require(penalty_amount >= amount, "over penalty amount");
    emit Subtract_Penalty_Amount(amount, info_hash);
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