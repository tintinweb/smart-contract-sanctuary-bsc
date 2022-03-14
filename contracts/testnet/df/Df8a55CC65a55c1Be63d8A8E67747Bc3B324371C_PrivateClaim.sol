pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract PrivateClaim {
  address public admin;
  mapping(address => bool) public processedClaimOne;
  mapping(address => bool) public processedClaimTwo;
  mapping(address => bool) public processedClaimThree;
  mapping(address => bool) public processedClaimFour;
  mapping(address => bool) public processedClaimFive;
  mapping(address => bool) public processedClaimSix;
  mapping(address => bool) public processedClaimSeven;
  mapping(address => bool) public processedClaimEight;
  mapping(address => bool) public processedClaimNine;
  mapping(address => bool) public processedClaimTen;
  mapping(address => bool) public processedClaimEleven;

  IERC20 public token;
  uint public currentClaimAmount;
  uint public maxClaimAmount = 800000 * 10 ** 18;

  event ClaimProcessed(
    address recipient,
    uint amount,
    uint date
  );

  constructor(address _token, address _admin) {
    admin = _admin; 
    token = IERC20(_token);
  }

  function updateAdmin(address newAdmin) external {
    require(msg.sender == admin, 'only admin');
    admin = newAdmin;
  }

  function claimAmount() public view returns (uint) {
    return currentClaimAmount;
  }

  function passBackToRedistribute() external {
    uint remainAmount = maxClaimAmount - currentClaimAmount;
    require(msg.sender == admin, 'Only admin');
    require(remainAmount > 0, 'Empty pool');

    token.transfer(admin, remainAmount);
  }

  function claimTokens(
    address recipient,
    uint amount,
    uint idx,
    bytes calldata signature
  ) external {
    bytes32 message = prefixed(keccak256(abi.encodePacked(
      recipient, 
      amount
    )));

    amount = amount * 10 ** 18;
    require(recoverSigner(message, signature) == admin, 'Wrong signature');
    require(currentClaimAmount + amount <= maxClaimAmount, 'Claimed 100% of the tokens');

    if (idx == 1)
        require(processedClaimOne[recipient] == false, 'Claimed already');
    if (idx == 2)
        require(processedClaimTwo[recipient] == false, 'Claimed already');
    if (idx == 3)
        require(processedClaimThree[recipient] == false, 'Claimed already');
    if (idx == 4)
        require(processedClaimFour[recipient] == false, 'Claimed already');
    if (idx == 5)
        require(processedClaimFive[recipient] == false, 'Claimed already');
    if (idx == 6)
        require(processedClaimSix[recipient] == false, 'Claimed already');
    if (idx == 7)
        require(processedClaimSeven[recipient] == false, 'Claimed already');
    if (idx == 8)
        require(processedClaimEight[recipient] == false, 'Claimed already');
    if (idx == 9)
        require(processedClaimNine[recipient] == false, 'Claimed already');
    if (idx == 10)
        require(processedClaimTen[recipient] == false, 'Claimed already');
    if (idx == 11)
        require(processedClaimEleven[recipient] == false, 'Claimed already');

    if (idx == 1)
        processedClaimOne[recipient] = true;
    if (idx == 2)
        processedClaimTwo[recipient] = true;
    if (idx == 3)
        processedClaimThree[recipient] = true;
    if (idx == 4)
        processedClaimFour[recipient] = true;
    if (idx == 5)
        processedClaimFive[recipient] = true;
    if (idx == 6)
        processedClaimSix[recipient] = true;
    if (idx == 7)
        processedClaimSeven[recipient] = true;
    if (idx == 8)
        processedClaimEight[recipient] = true;
    if (idx == 9)
        processedClaimNine[recipient] = true;
    if (idx == 10)
        processedClaimTen[recipient] = true;
    if (idx == 11)
        processedClaimEleven[recipient] = true;
    
    currentClaimAmount += amount;
    token.transfer(recipient, amount);
    emit ClaimProcessed(
      recipient,
      amount,
      block.timestamp
    );
  }

  function prefixed(bytes32 hash) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(
      '\x19Ethereum Signed Message:\n32', 
      hash
    ));
  }

  function recoverSigner(bytes32 message, bytes memory sig)
    internal
    pure
    returns (address)
  {
    uint8 v;
    bytes32 r;
    bytes32 s;
  
    (v, r, s) = splitSignature(sig);
  
    return ecrecover(message, v, r, s);
  }

  function splitSignature(bytes memory sig)
    internal
    pure
    returns (uint8, bytes32, bytes32)
  {
    require(sig.length == 65);
  
    bytes32 r;
    bytes32 s;
    uint8 v;
  
    assembly {
        // first 32 bytes, after the length prefix
        r := mload(add(sig, 32))
        // second 32 bytes
        s := mload(add(sig, 64))
        // final byte (first byte of the next 32 bytes)
        v := byte(0, mload(add(sig, 96)))
    }
  
    return (v, r, s);
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

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