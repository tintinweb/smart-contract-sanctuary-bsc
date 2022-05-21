// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

interface IERC20 {
  function transfer(address, uint) external;
  function transferFrom(address, address, uint) external;
}

contract WjxnBscBridge {

  uint chainId;
  
  uint public fee_percent = 5e5; // 0.5 %
  uint public minimum_fee_amount = 50; // 50 wjxn

  address public admin;

  uint public penalty_amount = 0;

  address public penalty_wallet;

  IERC20 public wjxn = IERC20(0x643aC3E0cd806B1EC3e2c45f9A5429921422Cd74);

  struct Request {
    uint src_chain_id;
    uint dest_chain_id;
    uint amount;
    uint fee_amount;
    address to;
    uint deposit_timestamp;
    bytes32 deposit_hash;
    string deposit_tx_link;
    string release_tx_link;
  }

  Request[] public requests;

  mapping(address => uint[]) public user_requests;

  address[] public auditors;
  address[] public verifiers;
  address[] public bridge_operators;
  mapping(address => uint) operating_limits;
  mapping(address => address) fee_wallets;

  mapping(bytes32 => bool) valid_deposit_hashes;
  mapping(bytes32 => bool) proccessed_deposit_hashes;
  mapping(bytes32 => bool) proccessed_tx_hashes;

  event Deposit(uint indexed request_id, bytes32 indexed deposit_hash, address indexed to, uint amount, uint fee_amount, uint64 src_chain_id, uint64 dest_chain_id, uint128 deposit_timestamp);
  event Release(
    uint indexed request_id, 
    bytes32 indexed deposit_hash, 
    address indexed to, 
    uint deposited_amount, 
    uint fee_amount,
    uint released_amount, 
    uint64 src_chain_id, 
    uint64 dest_chain_id, 
    uint128 deposit_timestamp, 
    string txHash
  );
  event Add_Deposit_Hash(uint request_id, string deposit_tx_link);
  event Complete_Release_Tx_Link(uint request_id, string deposit_tx_link, string release_tx_link);
  event Update_Release_Tx_Link(uint request_id, string deposit_tx_link, string release_tx_link);
  event Reject_Request(uint request_id);
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

  modifier onlyOperator() {
    require(isBridgeOperator(msg.sender), "Not a bridge operator");
    _;
  }

  function deposit(uint dest_chain_id, uint amount) external {
    require(amount >= minimum_fee_amount, "Minimum amount");
    require(chainId != dest_chain_id, "Invalid Destnation network");
    uint request_id = requests.length;
    uint fee_amount = amount * fee_percent / 1e8;
    if(fee_amount < minimum_fee_amount) fee_amount = minimum_fee_amount;
    bytes32 deposit_hash = keccak256(abi.encodePacked(request_id, msg.sender, chainId, dest_chain_id, amount, fee_amount, block.timestamp));
    Request memory request = Request({
      src_chain_id: chainId,
      dest_chain_id: dest_chain_id,
      amount: amount,
      fee_amount: fee_amount,
      to: msg.sender,
      deposit_timestamp: block.timestamp,
      deposit_hash: deposit_hash,
      deposit_tx_link: "",
      release_tx_link: ""
    });
    requests.push(request);
    wjxn.transferFrom(msg.sender, address(this), amount);
    emit Deposit(request_id, deposit_hash, msg.sender, amount, fee_amount, uint64(chainId), uint64(dest_chain_id), uint128(block.timestamp));
  }


  function add_deposit_hash(
    uint request_id,
    address to,
    uint src_chain_id,
    uint dest_chain_id,
    uint amount,
    uint fee_amount,
    uint deposit_timestamp,
    bytes32 deposit_hash,
    string calldata txHash
  ) external onlyVerifier {
    require( dest_chain_id == chainId, "Incorrect destination network" );
    require( deposit_hash == keccak256(abi.encodePacked(request_id, to, src_chain_id, chainId, amount, fee_amount, deposit_timestamp)), "Incorrect deposit hash");
    bytes32 _txHash = keccak256(abi.encodePacked(txHash));
    require( proccessed_deposit_hashes[deposit_hash] == false && proccessed_tx_hashes[_txHash] == false, "Already processed" );
    valid_deposit_hashes[deposit_hash] = true;
    emit Add_Deposit_Hash(request_id, txHash);
  }

  function release(
    uint request_id,
    address to,
    uint src_chain_id,
    uint dest_chain_id,
    uint amount,
    uint fee_amount,
    uint deposit_timestamp,
    bytes32 deposit_hash,
    string calldata txHash
  ) external onlyOperator {
    require( dest_chain_id == chainId, "Incorrect destination network" );
    require( deposit_hash == keccak256(abi.encodePacked(request_id, to, src_chain_id, chainId, amount, fee_amount, deposit_timestamp)), "Incorrect deposit hash");
    bytes32 _txHash = keccak256(abi.encodePacked(txHash));
    require( proccessed_deposit_hashes[deposit_hash] == false && proccessed_tx_hashes[_txHash] == false, "Already processed" );
    require(valid_deposit_hashes[deposit_hash], "Deposit is not valid");
    require(operating_limits[msg.sender] >= amount, "Out of operating limit");
    operating_limits[msg.sender] -= amount;
    wjxn.transfer(to, amount - fee_amount);
    if(penalty_amount > 0) {
      if(penalty_amount > fee_amount) {
        wjxn.transfer(penalty_wallet, fee_amount);
        penalty_amount -= fee_amount;
      }
      else {
        wjxn.transfer(penalty_wallet, penalty_amount);
        wjxn.transfer(fee_wallets[msg.sender], fee_amount - penalty_amount);
        penalty_amount -= penalty_amount;
      }
    }
    else {
      wjxn.transfer(fee_wallets[msg.sender], fee_amount);
    }
    proccessed_deposit_hashes[deposit_hash] = true;
    proccessed_tx_hashes[_txHash] = true;
    emit Release(request_id, deposit_hash, to, amount, fee_amount, amount - fee_amount, uint64(src_chain_id), uint64(dest_chain_id), uint128(deposit_timestamp), txHash);
  }

  function complete_release_tx_link(uint request_id, string calldata deposit_tx_link, string calldata release_tx_link) external onlyAuditor {
    Request storage request = requests[request_id];
    require(bytes(request.deposit_tx_link).length == 0, "");
    require(bytes(request.release_tx_link).length == 0, "");
    request.deposit_tx_link = deposit_tx_link;
    request.release_tx_link = release_tx_link;
    emit Complete_Release_Tx_Link(request_id, deposit_tx_link, release_tx_link);
  }

  function update_release_tx_link(uint request_id, string calldata deposit_tx_link, string calldata release_tx_link) external onlyAdmin {
    Request storage request = requests[request_id];
    request.deposit_tx_link = deposit_tx_link;
    request.release_tx_link = release_tx_link;
    emit Update_Release_Tx_Link(request_id, deposit_tx_link, release_tx_link);
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

  function add_bridge_operator(address operator, uint operating_limit, address fee_wallet) external onlyAdmin {
    for(uint i = 0; i < bridge_operators.length; i += 1) {
      if(bridge_operators[i] == operator)
        revert("Already exists");
    }
    bridge_operators.push(operator);
    operating_limits[operator] = operating_limit;
    fee_wallets[operator] = fee_wallet;
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