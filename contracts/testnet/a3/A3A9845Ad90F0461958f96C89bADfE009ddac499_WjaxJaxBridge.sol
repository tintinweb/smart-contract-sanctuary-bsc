// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

interface IERC20 {
  function mint(address, uint) external;
  function burn(uint) external;
  function transfer(address, uint) external;
  function transferFrom(address, address, uint) external;
}

contract WjaxJaxBridge {

  uint chainId;
  
  uint public fee_percent = 5e5; // 0.5 %
  uint public minimum_fee_amount = 50; // 50 wjax

  address public admin;

  uint public penalty_amount = 0;

  address public penalty_wallet;  
  
  uint public max_pending_audit_records = 10;
  uint public pending_audit_records;

  IERC20 public wjax = IERC20(0x643aC3E0cd806B1EC3e2c45f9A5429921422Cd74); 

  enum RequestStatus {Init, Verified, Released, Completed}

  struct Request {
    uint shard_id;
    uint amount;
    uint fee_amount;
    uint created_at;
    uint released_at;
    bytes32 data_hash;
    address from;
    RequestStatus status;
    string to;
    string deposit_tx_hash;
    string deposit_tx_link;
    string release_tx_link;
    string jaxnet_tx_hash;
  }

  Request[] public requests;

  mapping(address => uint[]) public user_requests;

  address[] public auditors;
  address[] public verifiers;
  address[] public bridge_executors;
  mapping(address => uint) public operating_limits;
  mapping(address => address) public fee_wallets;

  mapping(bytes32 => bool) proccessed_txd_hashes;

  event Deposit(uint request_id, uint shard_id, uint amount, uint fee_amount, address from, string to);
  event Release(uint request_id, string to, uint amount, string txHash);
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

  function deposit(uint shard_id, uint amount, string memory to) external 
  {
    require(shard_id >= 1 && shard_id <= 3, "Invalid shard id");
    require(amount > minimum_fee_amount, "Below minimum amount");
    uint request_id = requests.length;
    Request memory request;
    request.shard_id = shard_id;
    uint fee_amount = amount * fee_percent / 1e8;
    if(fee_amount < minimum_fee_amount) fee_amount = minimum_fee_amount;
    request.amount = amount - fee_amount;
    request.fee_amount = fee_amount;
    request.to = to;
    request.from = msg.sender;
    request.created_at = block.timestamp;
    requests.push(request);
    user_requests[msg.sender].push(request_id);
    wjax.transferFrom(msg.sender, address(this), amount);
    wjax.burn(amount - fee_amount);
    emit Deposit(request_id, shard_id, amount, fee_amount, msg.sender, to);
  }

  function _get_data_hash(
    uint request_id,
    uint shard_id,
    uint amount,
    address from,
    string memory to,
    string memory deposit_tx_hash
  ) pure public returns (bytes32) {
    return keccak256(abi.encodePacked(
      request_id, 
      shard_id,
      amount,
      from,
      to,
      deposit_tx_hash
    ));
  }

  function verify_data_hash(
    uint request_id,
    uint shard_id,
    uint amount,
    address from,
    string memory to,
    string memory deposit_tx_hash
  ) external onlyVerifier {
    Request storage request = requests[request_id];
    require( request.status == RequestStatus.Init, "Invalid status");
    bytes32 data_hash = _get_data_hash(request_id, shard_id, amount, from, to, deposit_tx_hash);
    request.data_hash = _get_data_hash(request_id, request.shard_id, request.amount, request.from, request.to, deposit_tx_hash);
    require( data_hash == request.data_hash, "Invalid data hash");
    bytes32 txDHash = keccak256(abi.encodePacked(deposit_tx_hash));
    require( !proccessed_txd_hashes[txDHash], "Invalid deposit tx hash");
    request.deposit_tx_hash = deposit_tx_hash;
    request.status = RequestStatus.Verified;
    emit Verify_Data_Hash(request_id, deposit_tx_hash);
  }

  function release(
    uint request_id,
    uint shard_id,
    uint amount,
    address from,
    string memory to,
    string memory deposit_tx_hash,
    string memory jaxnet_tx_hash
  ) external onlyExecutor {
    Request storage request = requests[request_id];
    bytes32 jaxnet_txd_hash = keccak256(abi.encodePacked(jaxnet_tx_hash));
    bytes32 local_txd_hash = keccak256(abi.encodePacked(deposit_tx_hash));
    require(operating_limits[msg.sender] >= amount, "Amount exceeds operating limit");
    require(request.status == RequestStatus.Verified, "Invalid status");
    require(request.data_hash == _get_data_hash(request_id, shard_id, amount, from, to, deposit_tx_hash), "Incorrect deposit hash");
    require(proccessed_txd_hashes[jaxnet_txd_hash] == false, "Jaxnet TxHash already used");
    require(proccessed_txd_hashes[local_txd_hash] == false, "Local TxHash already used");
    require(keccak256(abi.encodePacked(request.deposit_tx_hash)) == keccak256(abi.encodePacked(deposit_tx_hash)), "Deposit tx hash mismatch");
    require(max_pending_audit_records > pending_audit_records, "Exceed maximum pending audit records");
    pending_audit_records += 1;
    request.jaxnet_tx_hash = jaxnet_tx_hash;
    request.released_at = block.timestamp;
    request.status = RequestStatus.Released;
    proccessed_txd_hashes[jaxnet_txd_hash] = true;
    proccessed_txd_hashes[local_txd_hash] = true;
    uint fee_amount = request.fee_amount;
    if(penalty_amount > 0) {
      if(penalty_amount > fee_amount) {
        wjax.transfer(penalty_wallet, fee_amount);
        penalty_amount -= fee_amount;
      }
      else {
        wjax.transfer(penalty_wallet, penalty_amount);
        wjax.transfer(fee_wallets[msg.sender], fee_amount - penalty_amount);
        penalty_amount -= penalty_amount;
      }
    }
    else {
      wjax.transfer(fee_wallets[msg.sender], fee_amount);
    }
    operating_limits[msg.sender] -= amount;
    emit Release(request_id, request.to, request.amount, jaxnet_tx_hash);
  }

  function complete_release_tx_link(
    uint request_id,
    uint shard_id,
    uint amount,
    address from,
    string memory to,
    string memory deposit_tx_hash,
    string memory deposit_tx_link, 
    string memory release_tx_link,
    bytes32 info_hash
  ) external onlyAuditor {
    Request storage request = requests[request_id];
    
    require(request.status == RequestStatus.Released, "Invalid status");
    require(request.data_hash == _get_data_hash(request_id, shard_id, amount, from, to, deposit_tx_hash), "Incorrect deposit hash");
    
    request.deposit_tx_link = deposit_tx_link;
    request.release_tx_link = release_tx_link;
    request.status = RequestStatus.Completed;
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

  function add_bridge_executor(address executor, uint operating_limit, address fee_wallet) external onlyAdmin {
    for(uint i = 0; i < bridge_executors.length; i += 1) {
      if(bridge_executors[i] == executor)
        revert("Already exists");
    }
    bridge_executors.push(executor);
    operating_limits[executor] = operating_limit;
    fee_wallets[executor] = fee_wallet;
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

  function set_penalty_wallet(address _penalty_wallet) external onlyAdmin {
    penalty_wallet = _penalty_wallet;
  }

  function set_admin(address _admin) external onlyAdmin {
    admin = _admin;
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