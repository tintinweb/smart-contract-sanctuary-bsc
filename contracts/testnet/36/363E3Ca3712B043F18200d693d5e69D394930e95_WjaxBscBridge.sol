// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract WjaxBscBridge {

  uint chainId;
  
  uint public fee_percent = 5e5; // 0.5 %
  uint public minimum_fee_amount = 50; // 50 wjax

  address public admin;

  uint public penalty_amount = 0;

  address public penalty_wallet;

  IERC20 public wjax = IERC20(0x643aC3E0cd806B1EC3e2c45f9A5429921422Cd74);

  struct Request {
    uint srcChainId;
    uint destChainId;
    uint amount;
    uint fee_amount;
    address to;
    uint deposit_timestamp;
    bytes32 depositHash;
  }

  Request[] public requests;

  mapping(address => uint[]) public user_requests;

  address[] public bridge_operators;
  mapping(address => uint) operating_limits;

  mapping(bytes32 => bool) proccessed_deposit_hashes;
  mapping(bytes32 => bool) proccessed_tx_hashes;

  event Deposit(uint indexed request_id, bytes32 indexed depositHash, address indexed to, uint amount, uint fee_amount, uint64 srcChainId, uint64 destChainId, uint128 deposit_timestamp);
  event Release(
    uint indexed request_id, 
    bytes32 indexed depositHash, 
    address indexed to, 
    uint deposited_amount, 
    uint fee_amount,
    uint released_amount, 
    uint64 srcChainId, 
    uint64 destChainId, 
    uint128 deposit_timestamp, 
    string txHash
  );
  event Reject_Request(uint request_id);
  event Set_Fee(uint fee_percent, uint minimum_fee_amount);
  event Set_Operating_Limit(address operator, uint operating_limit);
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

  function withdraw(uint amount) external onlyAdmin {
    wjax.transfer(admin, amount);
  }

  function deposit(uint destChainId, uint amount) external {
    require(amount >= minimum_fee_amount, "Minimum amount");
    require(chainId != destChainId, "Invalid Destnation network");
    uint request_id = requests.length;
    uint fee_amount = amount * fee_percent / 1e8;
    if(fee_amount < minimum_fee_amount) fee_amount = minimum_fee_amount;
    bytes32 depositHash = keccak256(abi.encodePacked(request_id, msg.sender, chainId, destChainId, amount, fee_amount, block.timestamp));
    Request memory request = Request({
      srcChainId: chainId,
      destChainId: destChainId,
      amount: amount,
      fee_amount: fee_amount,
      to: msg.sender,
      deposit_timestamp: block.timestamp,
      depositHash: depositHash
    });
    requests.push(request);
    wjax.transferFrom(msg.sender, address(this), amount);
    emit Deposit(request_id, depositHash, msg.sender, amount, fee_amount, uint64(chainId), uint64(destChainId), uint128(block.timestamp));
  }

  function release(
    uint request_id,
    address to,
    uint srcChainId,
    uint destChainId,
    uint amount,
    uint fee_amount,
    uint deposit_timestamp,
    bytes32 depositHash,
    string calldata txHash
  ) external onlyOperator {
    require( destChainId == chainId, "Incorrect destination network" );
    require( depositHash == keccak256(abi.encodePacked(request_id, to, srcChainId, chainId, amount, fee_amount, deposit_timestamp)), "Incorrect deposit hash");
    bytes32 _txHash = keccak256(abi.encodePacked(txHash));
    require( proccessed_deposit_hashes[depositHash] == false && proccessed_tx_hashes[_txHash] == false, "Already processed" );
    wjax.transfer(to, amount - fee_amount);
    if(penalty_amount > 0) {
      if(penalty_amount > fee_amount) {
        wjax.transfer(penalty_wallet, fee_amount);
        penalty_amount -= fee_amount;
      }
      else {
        wjax.transfer(penalty_wallet, penalty_amount);
        wjax.transfer(msg.sender, fee_amount - penalty_amount);
        penalty_amount -= penalty_amount;
      }
    }
    else {
      wjax.transfer(msg.sender, fee_amount);
    }
    operating_limits[msg.sender] -= amount;
    proccessed_deposit_hashes[depositHash] = true;
    proccessed_tx_hashes[_txHash] = true;
    emit Release(request_id, depositHash, to, amount, fee_amount, amount - fee_amount, uint64(srcChainId), uint64(destChainId), uint128(deposit_timestamp), txHash);
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

  function set_penalty_wallet(address _penalty_wallet) external onlyAdmin {
    penalty_wallet = _penalty_wallet;
    emit Set_Penalty_Wallet(_penalty_wallet);
  }

  function set_admin(address _admin) external onlyAdmin {
    admin = _admin;
    emit Set_Admin(_admin);
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