// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

interface IERC20 {
  function mint(address account, uint amount) external;
  function transfer(address, uint) external;
}

contract JxnWjxn2Bridge {

  uint chainId;
  
  uint public fee_percent = 5e5; // 0.5 %
  uint public minimum_fee_amount = 50; // 50 wjxn2

  address public admin;

  uint public penalty_amount = 0;

  address public penalty_wallet;  
  
  uint public max_pending_audit_records = 10;
  uint public pending_audit_records;  
    
  IERC20 public wjxn2 = IERC20(0xe3345c59ECd8B9C157Dd182BA9500aace899AD31);

  enum RequestStatus {Init, Proved, Rejected, Expired, Verified, Released, Completed}

  struct Request {
    uint deposit_address_id;
    uint amount;
    bytes32 txdHash;
    bytes32 data_hash;
    uint valid_until;
    uint prove_timestamp;
    address to;
    RequestStatus status;
    string from;
    string deposit_tx_hash;
    string deposit_tx_link;
    string release_tx_link;
  }

  string[] public deposit_addresses;
  mapping(uint => uint) public deposit_address_requests;
  mapping(string => bool) public added_deposit_addresses;
  mapping(string => uint) public deposit_address_locktimes;
  mapping(string => bool) public deposit_address_deleted;

  Request[] public requests;

  mapping(address => uint[]) public user_requests;

  address[] public auditors;
  address[] public verifiers;
  address[] public bridge_executors;
  mapping(address => uint) public operating_limits;
  mapping(address => address) public fee_wallets;

  mapping(bytes32 => bool) proccessed_txd_hashes;

  event Create_Request(uint request_id, string from, uint depoist_address_id, uint valid_until);
  event Prove_Request(uint request_id, string tx_hash);
  event Expire_Request(uint request_id);
  event Reject_Request(uint request_id);
  event Release(uint request_id, address from, uint amount);
  event Verify_Data_Hash(uint request_id, string deposit_tx_hash);
  event Complete_Release_Tx_Link(uint request_id, string deposit_tx_hash, string release_tx_hash, bytes32 info_hash);
  event Update_Release_Tx_Link(uint request_id, string deposit_tx_hash, string release_tx_hash);
  event Set_Fee(uint fee_percent, uint minimum_fee_amount);
  event Add_Penalty_Amount(uint amount, bytes32 info_hash);
  event Subtract_Penalty_Amount(uint amount, bytes32 info_hash);
  event Withdraw_By_Admin(address token, uint amount);

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

  modifier onlyAuditor() {
    require(isAuditor(msg.sender), "Only Auditor can perform this operation.");
    _;
  }

  modifier onlyVerifier() {
    require(isVerifier(msg.sender), "Only Verifier can perform this operation.");
    _;
  }

  modifier onlyExecutor() {
    require(isBridgeExecutor(msg.sender), "Not a bridge executor");
    _;
  }

  function add_deposit_addresses(string[] calldata new_addresses) external onlyAdmin {
    for(uint i = 0; i < new_addresses.length; i += 1) {
      require(!added_deposit_addresses[new_addresses[i]], "Already added");
      deposit_addresses.push(new_addresses[i]);
      deposit_address_locktimes[new_addresses[i]] = 0;
      added_deposit_addresses[new_addresses[i]] = true;
    }
  }

  function get_free_deposit_address_id() public view returns(uint) {
    for(uint i = 0; i < deposit_addresses.length; i += 1) {
      if(deposit_address_deleted[deposit_addresses[i]] == false && deposit_address_locktimes[deposit_addresses[i]] == 0) 
        return i;
    }
    revert("All deposit addresses are in use");
  }

  function isValidDepositAddress(uint deposit_address_id) internal view returns(bool) {
    return deposit_addresses.length > deposit_address_id &&
      !deposit_address_deleted[deposit_addresses[deposit_address_id]] &&
      deposit_address_locktimes[deposit_addresses[deposit_address_id]] == 0;
  }

  function create_request(uint deposit_address_id, uint amount, string memory from) external 
  {
    require(isValidDepositAddress(deposit_address_id), "Invalid deposit address");
    require(amount > minimum_fee_amount, "Below minimum amount");
    uint request_id = requests.length;
    Request memory request;
    request.amount = amount;
    request.to = msg.sender;
    request.from = from;
    request.deposit_address_id = deposit_address_id;
    deposit_address_requests[request.deposit_address_id] = request_id;
    uint valid_until = block.timestamp + 48 hours;
    request.valid_until = valid_until;
    deposit_address_locktimes[deposit_addresses[request.deposit_address_id]] = valid_until;
    requests.push(request);
    user_requests[msg.sender].push(request_id);
    emit Create_Request(request_id, from, request.deposit_address_id, valid_until);
  }

  function prove_request(uint request_id, string memory tx_hash) external {
    Request storage request = requests[request_id];
    require(request.to == msg.sender, "Invalid account");
    require(request.status == RequestStatus.Init, "Invalid status");
    if(request.valid_until < block.timestamp) {
      request.status = RequestStatus.Expired;
      request.prove_timestamp = block.timestamp;
      emit Expire_Request(request_id);
      return;
    }
    bytes32 txdHash = keccak256(abi.encodePacked(tx_hash));
    require(proccessed_txd_hashes[txdHash] == false, "Invalid tx hash");
    request.txdHash = txdHash;
    request.status = RequestStatus.Proved;
    request.prove_timestamp = block.timestamp;
    request.data_hash = _get_data_hash(
      request_id, 
      request.deposit_address_id, 
      request.amount, 
      request.to, 
      request.from, 
      tx_hash);
    request.amount = 0;
    emit Prove_Request(request_id, tx_hash);
  }

  function _get_data_hash(
    uint request_id, 
    uint deposit_address_id,
    uint amount,
    address to,
    string memory from,
    string memory deposit_tx_hash
  ) pure public returns (bytes32) {
    return keccak256(abi.encodePacked(
      request_id, 
      deposit_address_id,
      amount,
      to,
      from,
      deposit_tx_hash
    ));
  }

  function verify_data_hash(
    uint request_id,
    
    uint amount, 
    uint deposit_address_id, 
    address to, 
    string memory from, 
    string memory deposit_tx_hash,
    bytes32 data_hash
  ) external onlyVerifier {
    Request storage request = requests[request_id];
    require(request.status == RequestStatus.Proved, "Invalid status");
    require(data_hash == request.data_hash && request.data_hash == _get_data_hash(
      request_id, 
      deposit_address_id, 
      amount, 
      to, 
      from, 
      deposit_tx_hash), "Incorrect data");
    request.deposit_tx_hash = deposit_tx_hash;
    request.status = RequestStatus.Verified;
    emit Verify_Data_Hash(request_id, deposit_tx_hash);
  }

  function reject_request(uint request_id) external onlyVerifier {
    Request storage request = requests[request_id];
    require(request.status == RequestStatus.Init || 
      request.status == RequestStatus.Proved ||
      request.status == RequestStatus.Verified, "Invalid status");
    request.status = RequestStatus.Rejected;
    emit Reject_Request(request_id);
  }

  function release(
    uint request_id,
    uint amount, 
    uint deposit_address_id, 
    address to, 
    string memory from, 
    string memory deposit_tx_hash
  ) external onlyExecutor {
    Request storage request = requests[request_id];
    require(operating_limits[msg.sender] >= amount, "Amount exceeds operating limit");
    require(request.status == RequestStatus.Verified, "Invalid status");
    require(request.data_hash == _get_data_hash(
      request_id, 
      deposit_address_id, 
      amount, 
      to, 
      from, 
      deposit_tx_hash), "Incorrect data");
    require(proccessed_txd_hashes[request.txdHash] == false, "Txd hash already processed");
    require(max_pending_audit_records > pending_audit_records, "Exceed maximum pending audit records");
    pending_audit_records += 1;
    deposit_address_locktimes[deposit_addresses[request.deposit_address_id]] = 0;
    request.amount = amount;
    request.status = RequestStatus.Released;
    proccessed_txd_hashes[request.txdHash] = true;
    uint fee_amount = request.amount * fee_percent / 1e8;
    if(fee_amount < minimum_fee_amount) fee_amount = minimum_fee_amount;
    wjxn2.mint(address(this), request.amount);
    wjxn2.transfer(request.to, request.amount - fee_amount);
    if(penalty_amount > 0) {
      if(penalty_amount > fee_amount) {
        wjxn2.transfer(penalty_wallet, fee_amount);
        penalty_amount -= fee_amount;
      }
      else {
        wjxn2.transfer(penalty_wallet, penalty_amount);
        wjxn2.transfer(fee_wallets[msg.sender], fee_amount - penalty_amount);
        penalty_amount -= penalty_amount;
      }
    }
    else {
      wjxn2.transfer(fee_wallets[msg.sender], fee_amount);
    }
    operating_limits[msg.sender] -= amount;
    emit Release(request_id, request.to, request.amount - fee_amount);
  }

  function complete_release_tx_link(
    uint request_id,
    uint amount, 
    uint deposit_address_id, 
    address to, 
    string memory from, 
    string memory deposit_tx_hash,
    string memory deposit_tx_link, 
    string memory release_tx_link,
    bytes32 info_hash
    ) external onlyAuditor {
    Request storage request = requests[request_id];
    require(request.status == RequestStatus.Released, "Invalid status");
    require(request.data_hash == _get_data_hash(
      request_id, 
      deposit_address_id, 
      amount, 
      to, 
      from, 
      deposit_tx_hash), "Incorrect data");
    request.status = RequestStatus.Completed;
    request.deposit_tx_link = deposit_tx_link;
    request.release_tx_link = release_tx_link;
    pending_audit_records -= 1;
    emit Complete_Release_Tx_Link(request_id, deposit_tx_link, release_tx_link, info_hash);
  }

  function update_release_tx_link(uint request_id, string memory deposit_tx_link, string memory release_tx_link) external onlyAdmin {
    Request storage request = requests[request_id];
    request.deposit_tx_link = deposit_tx_link;
    request.release_tx_link = release_tx_link;
    emit Update_Release_Tx_Link(request_id, deposit_tx_link, release_tx_link);
  }

  function get_user_requests(address user) external view returns(uint[] memory) {
    return user_requests[user];
  }

  function add_auditor(address auditor) external onlyAdmin {
    for(uint i = 0; i < auditors.length; i += 1) {
      if(auditors[i] == auditor)
        revert("Already exists");
    }
    auditors.push(auditor);
  }

  function delete_auditor(address auditor) external onlyAdmin {
    uint i = 0;
    for(; i < auditors.length; i += 1) {
      if(auditors[i] == auditor)
        break;
    }
    require(i < auditors.length, "Not an auditor");
    auditors[i] = auditors[auditors.length - 1];
    auditors.pop();
  }

  function isAuditor(address auditor) public view returns(bool) {
    uint i = 0;
    for(; i < auditors.length; i += 1) {
      if(auditors[i] == auditor)
        return true;
    } 
    return false;
  }


  function add_verifier(address verifier) external onlyAdmin {
    for(uint i = 0; i < verifiers.length; i += 1) {
      if(verifiers[i] == verifier)
        revert("Already exists");
    }
    verifiers.push(verifier);
  }

  function delete_verifier(address verifier) external onlyAdmin {
    uint i = 0;
    for(; i < verifiers.length; i += 1) {
      if(verifiers[i] == verifier)
        break;
    }
    require(i < verifiers.length, "Not an verifier");
    verifiers[i] = verifiers[verifiers.length - 1];
    verifiers.pop();
  }

  function isVerifier(address verifier) public view returns(bool) {
    uint i = 0;
    for(; i < verifiers.length; i += 1) {
      if(verifiers[i] == verifier)
        return true;
    } 
    return false;
  }

  function add_bridge_executor(address executor, uint operating_limit, address fee_wallet) external onlyAdmin {
    for(uint i = 0; i < bridge_executors.length; i += 1) {
      if(bridge_executors[i] == executor)
        revert("Already exists");
    }
    bridge_executors.push(executor);
    operating_limits[executor] = operating_limit;
    fee_wallets[executor] = fee_wallet;
  }

  function isBridgeExecutor(address executor) public view returns(bool) {
    uint i = 0;
    for(; i < bridge_executors.length; i += 1) {
      if(bridge_executors[i] == executor)
        return true;
    } 
    return false;
  }

  function set_operating_limit(address executor, uint operating_limit) external onlyAdmin {
    require(isBridgeExecutor(executor), "Not a bridge executor");
    operating_limits[executor] = operating_limit;
  }

  function set_fee(uint _fee_percent, uint _minimum_fee_amount) external onlyAdmin {
    fee_percent = _fee_percent;
    minimum_fee_amount = _minimum_fee_amount;
    emit Set_Fee(_fee_percent, _minimum_fee_amount);
  }

  function free_deposit_addresses(uint from, uint to) external onlyAdmin  {
    uint request_id;
    for(uint i = from; i < deposit_addresses.length && i <= to ; i += 1) {
      if(deposit_address_locktimes[deposit_addresses[i]] < block.timestamp) {
        request_id = deposit_address_requests[i];
        if(requests[request_id].status == RequestStatus.Init){
          requests[request_id].status = RequestStatus.Expired;
          deposit_address_locktimes[deposit_addresses[i]] = 0;
        }
      }
    }
  }

  function delete_deposit_addresses(uint[] calldata ids) external onlyAdmin {
    uint id;
    for(uint i = 0; i < ids.length; i += 1) {
      id = ids[i];
      require(deposit_address_locktimes[deposit_addresses[id]] == 0, "Active deposit address");
      deposit_address_deleted[deposit_addresses[id]] = true;
    }
  }

  function set_penalty_wallet(address _penalty_wallet) external onlyAdmin {
    penalty_wallet = _penalty_wallet;
  }

  function set_admin(address _admin) external onlyAdmin {
    admin = _admin;
  }

  function get_new_request_id() external view returns(uint) {
    return requests.length;
  }

  function get_deposit_addresses() external view returns(string[] memory) {
    return deposit_addresses;
  }
  
  function add_penalty_amount(uint amount, bytes32 info_hash) external onlyAuditor {
    penalty_amount += amount;
    emit Add_Penalty_Amount(amount, info_hash);
  }

  function subtract_penalty_amount(uint amount, bytes32 info_hash) external onlyAuditor {
    require(penalty_amount >= amount, "over penalty amount");
    penalty_amount -= amount;
    emit Subtract_Penalty_Amount(amount, info_hash);
  }
  
  function withdrawByAdmin(address token, uint amount) external onlyAdmin {
      IERC20(token).transfer(msg.sender, amount);
      emit Withdraw_By_Admin(token, amount);
  }

}