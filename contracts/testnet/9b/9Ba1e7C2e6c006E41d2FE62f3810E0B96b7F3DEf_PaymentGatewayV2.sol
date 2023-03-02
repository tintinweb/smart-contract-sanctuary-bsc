/**
 *Submitted for verification at BscScan.com on 2023-03-02
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

// File: contracts/ERC20.sol



pragma solidity >=0.8.14;

interface ERC20 {
  function totalSupply() external returns (uint256);

  function balanceOf(address tokenOwner) external returns (uint256 balance);

  function allowance(address tokenOwner, address spender)
    external
    returns (uint256 remaining);

  function transfer(address to, uint256 tokens) external returns (bool success);

  function approve(address spender, uint256 tokens)
    external
    returns (bool success);

  function transferFrom(
    address from,
    address to,
    uint256 tokens
  ) external returns (bool success);

  event Transfer(address indexed from, address indexed to, uint256 tokens);
  event Approval(
    address indexed tokenOwner,
    address indexed spender,
    uint256 tokens
  );
}

// File: contracts/IERC20PermitUpgradeable.sol


pragma solidity >=0.8.14;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20PermitUpgradeable {
  /**
   * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
   * given ``owner``'s signed approval.
   *
   * IMPORTANT: The same issues {IERC20-approve} has related to transaction
   * ordering also apply here.
   *
   * Emits an {Approval} event.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   * - `deadline` must be a timestamp in the future.
   * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
   * over the EIP712-formatted function arguments.
   * - the signature must use ``owner``'s current nonce (see {nonces}).
   *
   * For more information on the signature format, see the
   * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
   * section].
   */
  function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;

  /**
   * @dev Returns the current nonce for `owner`. This value must be
   * included whenever a signature is generated for {permit}.
   *
   * Every successful call to {permit} increases ``owner``'s nonce by one. This
   * prevents a signature from being used multiple times.
   */
  function nonces(address owner) external view returns (uint256);

  /**
   * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
   */
  // solhint-disable-next-line func-name-mixedcase
  function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// File: contracts/PaymentGatewayV2.sol


pragma solidity >=0.8.14;



contract PaymentGatewayV2 is Owner {
  event ChangeTokenEvent(address oldAddress, address newAddress);
  event PayEvent(uint256 amount, string merchantId, string sessionId);
  event SendEvent(uint256 amount, string merchantId, string sessionId);
  event BatchSendEvent(
    uint256[] amounts,
    address[] recipients,
    string merchantId,
    string sessionId
  );

  address private vndtToken;

  constructor(address _vndtToken, address _owner) {
    vndtToken = _vndtToken;
    changeOwner(_owner);
  }

  function pay(
    uint256 amount,
    address merchantAddress,
    string calldata sessionId,
    string calldata merchantId
  ) public {
    ERC20(vndtToken).transferFrom(msg.sender, merchantAddress, amount);
    emit PayEvent(amount, merchantId, sessionId);
  }

  function payWithPermit(
    uint256 amount,
    address merchantAddress,
    string calldata sessionId,
    string calldata merchantId,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public {
    // Use permit
    IERC20PermitUpgradeable(vndtToken).permit(
      msg.sender,
      address(this),
      amount,
      deadline,
      v,
      r,
      s
    );

    // Process pay
    pay(amount, merchantAddress, sessionId, merchantId);
  }

  function send(
    uint256 amount,
    address recipient,
    string calldata sessionId,
    string calldata merchantId
  ) public {
    ERC20(vndtToken).transferFrom(msg.sender, recipient, amount);
    emit SendEvent(amount, merchantId, sessionId);
  }

  function sendWithPermit(
    uint256 amount,
    address recipient,
    string calldata sessionId,
    string calldata merchantId,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public {
    // Use permit
    IERC20PermitUpgradeable(vndtToken).permit(
      msg.sender,
      address(this),
      amount,
      deadline,
      v,
      r,
      s
    );

    // Process send
    send(amount, recipient, sessionId, merchantId);
  }

  function batchSend(
    uint256[] calldata amounts,
    address[] calldata recipients,
    string calldata sessionId,
    string calldata merchantId
  ) public {
    uint256 total = 0;
    ERC20 token = ERC20(vndtToken);

    for (uint16 i = 0; i < recipients.length; ) {
      total += amounts[i];
      unchecked {
        ++i;
      }
    }

    require(token.transferFrom(msg.sender, address(this), total));

    for (uint16 i = 0; i < recipients.length; ) {
      require(token.transfer(recipients[i], amounts[i]));
      unchecked {
        ++i;
      }
    }

    emit BatchSendEvent(amounts, recipients, merchantId, sessionId);
  }

  function setVndtToken(address newAddress) public isOwner {
    emit ChangeTokenEvent(vndtToken, newAddress);
    vndtToken = newAddress;
  }

  function getVndtToken() public view returns (address) {
    return vndtToken;
  }
}