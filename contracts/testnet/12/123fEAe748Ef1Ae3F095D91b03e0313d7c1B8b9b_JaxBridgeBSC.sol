// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "./JaxBridge2.sol";

contract JaxBridgeBSC is JaxBridge2 {

  constructor() JaxBridge2() {
    transaction_fee = 0.25 ether;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract JaxBridge2 {

  uint chainId;
  uint transaction_fee;
  address public admin;
  IERC20 public wjxn = IERC20(0xcA1262e77Fb25c0a4112CFc9bad3ff54F617f2e6);
   mapping(address => mapping(uint => bool)) public processedNonces;
  mapping(address => uint) public nonces;

  enum Step { Deposit, Withdraw }
  event Transfer(
    address from,
    address to,
    uint destChainId,
    uint amount,
    uint date,
    uint nonce,
    bytes32 txId,
    Step indexed step
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

  function setToken(address _wjxn) external onlyAdmin {
    wjxn = IERC20(_wjxn);
  }

  function deposit(uint amount) external onlyAdmin {
    wjxn.transferFrom(admin, address(this), amount);
  }

  function withdraw(uint amount) external onlyAdmin {
    wjxn.transfer(admin, amount);
  }

  function deposit(address to, uint destChainId, uint amount, uint nonce) external {
    require(nonces[msg.sender] == nonce, 'transfer already processed');
    nonces[msg.sender] += 1;
    wjxn.transferFrom(msg.sender, address(this), amount);
    bytes32 txId = keccak256(abi.encodePacked(msg.sender, to, chainId, destChainId, amount, nonce));
    emit Transfer(
      msg.sender,
      to,
      destChainId,
      amount,
      block.timestamp,
      nonce,
      txId,
      Step.Deposit
    );
  }

  function withdraw(
    address from, 
    address to, 
    uint srcChainId,
    uint amount, 
    uint nonce,
    bytes32 txId
  ) external onlyAdmin {
    bytes32 _txId = keccak256(abi.encodePacked(
      from, 
      to, 
      srcChainId,
      chainId,
      amount,
      nonce
    ));
    require(_txId == txId , 'wrong txId');
    require(processedNonces[from][nonce] == false, 'transfer already processed');
    processedNonces[from][nonce] = true;
    require(wjxn.balanceOf(address(this)) >= amount, 'insufficient pool');
    wjxn.transfer(to, amount);
    emit Transfer(
      from,
      to,
      chainId,
      amount,
      block.timestamp,
      nonce,
      txId,
      Step.Withdraw
    );
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