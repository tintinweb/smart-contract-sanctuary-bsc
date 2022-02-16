/**
 *Submitted for verification at BscScan.com on 2022-02-16
*/

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
  /**
   * @dev Returns the addition of two unsigned integers, with an overflow flag.
   *
   * _Available since v3.4._
   */
  function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
      uint256 c = a + b;
      if (c < a) return (false, 0);
      return (true, c);
    }
  }

  /**
   * @dev Returns the substraction of two unsigned integers, with an overflow flag.
   *
   * _Available since v3.4._
   */
  function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
      if (b > a) return (false, 0);
      return (true, a - b);
    }
  }

  /**
   * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
   *
   * _Available since v3.4._
   */
  function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
      // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
      // benefit is lost if 'b' is also tested.
      // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
      if (a == 0) return (true, 0);
      uint256 c = a * b;
      if (c / a != b) return (false, 0);
      return (true, c);
    }
  }

  /**
   * @dev Returns the division of two unsigned integers, with a division by zero flag.
   *
   * _Available since v3.4._
   */
  function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
      if (b == 0) return (false, 0);
      return (true, a / b);
    }
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
   *
   * _Available since v3.4._
   */
  function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
      if (b == 0) return (false, 0);
      return (true, a % b);
    }
  }

  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   *
   * - Addition cannot overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    return a + b;
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   *
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return a - b;
  }

  /**
   * @dev Returns the multiplication of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `*` operator.
   *
   * Requirements:
   *
   * - Multiplication cannot overflow.
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    return a * b;
  }

  /**
   * @dev Returns the integer division of two unsigned integers, reverting on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator.
   *
   * Requirements:
   *
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * reverting when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   *
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return a % b;
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * CAUTION: This function is deprecated because it requires allocating memory for the error
   * message unnecessarily. For custom revert reasons use {trySub}.
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   *
   * - Subtraction cannot overflow.
   */
  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    unchecked {
      require(b <= a, errorMessage);
      return a - b;
    }
  }

  /**
   * @dev Returns the integer division of two unsigned integers, reverting with custom message on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   *
   * - The divisor cannot be zero.
   */
  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    unchecked {
      require(b > 0, errorMessage);
      return a / b;
    }
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * reverting with custom message when dividing by zero.
   *
   * CAUTION: This function is deprecated because it requires allocating memory for the error
   * message unnecessarily. For custom revert reasons use {tryMod}.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   *
   * - The divisor cannot be zero.
   */
  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    unchecked {
      require(b > 0, errorMessage);
      return a % b;
    }
  }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {

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
    * @dev Moves `amount` tokens from `sender` to `recipient` using the
    * allowance mechanism. `amount` is then deducted from the caller's
    * allowance.
    *
    * Returns a boolean value indicating whether the operation succeeded.
    *
    * Emits a {Transfer} event.
    */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 {

  /**
    * @dev Transfers `tokenId` token from `from` to `to`.
    *
    * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
    *
    * Requirements:
    *
    * - `from` cannot be the zero address.
    * - `to` cannot be the zero address.
    * - `tokenId` token must be owned by `from`.
    * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
    *
    * Emits a {Transfer} event.
    */
  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  ) external;
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
  function _msgSender() internal view returns (address) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }

  function _msgValue() internal view returns (uint256) {
    return msg.value;
  }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
  address private _owner;
  address private _newOwner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor (address owner_) {
    _owner = owner_;
    emit OwnershipTransferred(address(0), owner_);
  }

  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view returns (address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(owner() == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  /**
   * @dev Accept the ownership transfer. This is to make sure that the contract is
   * transferred to a working address
   *
   * Can only be called by the newly transfered owner.
   */
  function acceptOwnership() public {
    require(_msgSender() == _newOwner, "Ownable: only new owner can accept ownership");
    address oldOwner = _owner;
    _owner = _newOwner;
    _newOwner = address(0);
    emit OwnershipTransferred(oldOwner, _owner);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   *
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    _newOwner = newOwner;
  }
}

/**
 * @dev Enable contract to receive gas token
 */
abstract contract Payable {

  event Deposited(address indexed sender, uint256 value);

  fallback() external payable {
    if(msg.value > 0) {
      emit Deposited(msg.sender, msg.value);
    }
  }

  /// @dev enable wallet to receive ETH
  receive() external payable {
    if(msg.value > 0) {
      emit Deposited(msg.sender, msg.value);
    }
  }
}

/**
 * @dev These functions deal with verification of Merkle trees (hash trees),
 */
library MerkleProof {
  /**
    * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
    * defined by `root`. For this, a `proof` must be provided, containing
    * sibling hashes on the branch from the leaf to the root of the tree. Each
    * pair of leaves and each pair of pre-images are assumed to be sorted.
    */
  function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
    bytes32 computedHash = leaf;

    for (uint256 i = 0; i < proof.length; i++) {
      bytes32 proofElement = proof[i];

      if (computedHash <= proofElement) {
        // Hash(current computed hash + current element of the proof)
        computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
      } else {
        // Hash(current element of the proof + current computed hash)
        computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
      }
    }

    // Check if the computed hash (root) is equal to the provided root
    return computedHash == root;
  }
}

/**
 * @dev BaryonPad allows user to create raising fund campaign in a FIFO manner
 */
contract BaryonPad is Ownable, Payable {

  mapping(uint256 => mapping(address => uint256)) private _allowances;
  mapping(uint256 => LaunchpadData) private _launchpadDatas;
  mapping(uint256 => mapping(address => bool)) private _registrations;

  using SafeMath for uint256;

  /// @dev Initialize a new vault
  /// @param owner_ Owner of this pad
  constructor(address owner_) Ownable(owner_) {
  }

  struct LaunchpadData {
    address token0;
    address token1;
    uint256 priceInEthN;
    uint256 priceInEthD;
    uint256 priceInToken0N;
    uint256 priceInToken0D;
    bytes32 privateSaleSignature;
    uint256 minPerTx;
    uint256 maxPerUser;
    uint256 registerStartTimestamp;
    uint256 registerEndTimestamp;
    uint256 redeemStartTimestamp;
    uint256 redeemEndTimestamp;
    bool isPrivateSale;
    bool isActive;
  }

  event LaunchpadUpdated(uint256 launchpadId);
  event Registered(uint256 launchpadId, address indexed recipient);
  event Redeemed(uint256 launchpadId, address indexed recipient, uint256 amount);
  event Withdrawn(address indexed owner, address indexed recipient, address indexed token, uint256 value);

  /// @dev User enroll to a particular launchpad. User must be registered in order to participate token sale
  /// @param launchpadId_ Launchpad ID
  /// @param index_ Ordinal of registration
  /// @param proofs_ Optional metadata of merkle tree to verify user is eligible to register
  function register(uint256 launchpadId_, uint256 index_, bytes32[] calldata proofs_) external {
    LaunchpadData storage launchpad = _launchpadDatas[launchpadId_];

    require(launchpad.isActive, "BaryonPad: Invalid launchpad");
    require(launchpad.registerStartTimestamp <= block.timestamp && launchpad.registerEndTimestamp >= block.timestamp, "BaryonPad: Not registration time");
    if(launchpad.isPrivateSale) {
      bytes32 node = keccak256(abi.encodePacked(index_, _msgSender()));
      require(MerkleProof.verify(proofs_, launchpad.privateSaleSignature, node), "BaryonPad: Invalid proof");
    }

    _registrations[launchpadId_][_msgSender()] = true;

    emit Registered(launchpadId_, _msgSender());
  }

  /// @dev Buy token in the launchpad during redemption time
  /// @param launchpadId_ Launchpad ID
  /// @param amount_ Amount of token user want to buy
  function redeem(uint256 launchpadId_, uint256 amount_) external payable {
    LaunchpadData storage launchpad = _launchpadDatas[launchpadId_];
    require(launchpad.isActive, "BaryonPad: Invalid launchpad");
    require(launchpad.redeemStartTimestamp <= block.timestamp && launchpad.redeemEndTimestamp >= block.timestamp, "BaryonPad: Not redemption time");
    require(_registrations[launchpadId_][_msgSender()], "BaryonPad: Not registered");

    require(launchpad.minPerTx == 0 || amount_ >= launchpad.minPerTx, "BaryonPad: Not meet minimum amount");
    uint256 allowance = _allowances[launchpadId_][_msgSender()];
    uint256 newAllowance = allowance.add(amount_);
    require(launchpad.maxPerUser == 0 || newAllowance <= launchpad.maxPerUser, "BaryonPad: Allowance reached");

    if(_msgValue() > 0) {
      require(launchpad.priceInEthN > 0, "BaryonPad: Native token not supported");
      uint256 sendingAmount = amount_.mul(launchpad.priceInEthN);
      sendingAmount = sendingAmount.div(launchpad.priceInEthD);
      require(_msgValue() == sendingAmount, "BaryonPad: Insuffient fund");
    }
    else {
      require(launchpad.priceInToken0N > 0, "BaryonPad: Token 0 not supported");
      uint256 sendingAmount = amount_.mul(launchpad.priceInToken0N);
      sendingAmount = sendingAmount.div(launchpad.priceInToken0D);
      IERC20(launchpad.token0).transferFrom(_msgSender(), address(this), sendingAmount);
    }

    _allowances[launchpadId_][_msgSender()] = newAllowance;
    IERC20(launchpad.token1).transfer(_msgSender(), amount_);

    emit Redeemed(launchpadId_, _msgSender(), amount_);
  }

  /// @dev Create/Update a launchpad. Those parameters can't be changed if the launch passed registration phase
  /// @param launchpadId_ Launchpad ID
  /// @param token0_ Address of token user need to send to contract to exchange for *token1_*
  /// @param token1_ Address of token that will be sold
  /// @param priceInEths_ How much gas token per 1 *token1_*
  ///   0: Numerator
  ///   1: Denominator
  /// @param priceInToken0s_ How much *token0_* per 1 *token1_*
  ///   0: Numerator
  ///   1: Denominator
  /// @param isPrivateSale_ Is this a private sale that need whitelist
  /// @param privateSaleSignature_ Root of merkle tree to prove a user to eligible to register
  /// @param minPerTx_ Minimum amount of *token1_* must be executed in one transaction. 0 for unlimited
  /// @param maxPerUser_ Maximum amount of *token1_* a user is allowed to buy during the sale. 0 for unlimited
  /// @param timestamps_ Array of timestamps of milestones of the sale
  ///   0: Registration time start
  ///   1: Registration time end
  ///   2: Redemption time start
  ///   3: Redemption time end
  /// NOTE: This is a workaround for stack too deep error
  function setLaunchpad(uint256 launchpadId_, address token0_, address token1_, uint256[] memory priceInEths_, uint256[] memory priceInToken0s_,
    bool isPrivateSale_, bytes32 privateSaleSignature_, uint256 minPerTx_, uint256 maxPerUser_,
    uint256[] memory timestamps_
  ) external onlyOwner {

    require(timestamps_.length == 4, "BaryonPad: Invalid arguments");
    require(priceInEths_.length == 2, "BaryonPad: Invalid arguments");
    require(priceInToken0s_.length == 2, "BaryonPad: Invalid arguments");

    require(block.timestamp <= timestamps_[0], "BaryonPad: Time must be set in the future");
    require(timestamps_[0] < timestamps_[1], "BaryonPad: Invalid registration time");
    require(timestamps_[1] <= timestamps_[2], "BaryonPad: Registration and sale time overlap");
    require(timestamps_[2] < timestamps_[3], "BaryonPad: Invalid sale time");

    LaunchpadData storage launchpad = _launchpadDatas[launchpadId_];

    if (launchpad.registerStartTimestamp != 0) {
      require(launchpad.registerStartTimestamp >= block.timestamp, "BaryonPad: Launchpad finalized");
    }

    launchpad.token0 = token0_;
    launchpad.token1 = token1_;
    launchpad.priceInEthN = priceInEths_[0];
    launchpad.priceInEthD = priceInEths_[1];
    launchpad.priceInToken0N = priceInToken0s_[0];
    launchpad.priceInToken0D = priceInToken0s_[1];
    launchpad.isPrivateSale = isPrivateSale_;
    launchpad.privateSaleSignature = privateSaleSignature_;
    launchpad.minPerTx = minPerTx_;
    launchpad.maxPerUser = maxPerUser_;
    launchpad.registerStartTimestamp = timestamps_[0];
    launchpad.registerEndTimestamp = timestamps_[1];
    launchpad.redeemStartTimestamp = timestamps_[2];
    launchpad.redeemEndTimestamp = timestamps_[3];
    launchpad.isActive = true;

    emit LaunchpadUpdated(launchpadId_);
  }

  /// @dev Get launchpad data
  /// @param launchpadId_ Launchpad ID
  function getLaunchpad(uint256 launchpadId_) external view returns (LaunchpadData memory) {
    return _launchpadDatas[launchpadId_];
  }

  /// @dev Change launchpad's status
  /// @param launchpadId_ Launchpad ID
  /// @param isActive_ Inactive/Active
  function setLaunchpadStatus(uint256 launchpadId_, bool isActive_) external onlyOwner {

    LaunchpadData storage launchpad = _launchpadDatas[launchpadId_];
    launchpad.isActive = isActive_;

    emit LaunchpadUpdated(launchpadId_);
  }

  /// @dev withdraw the token in the vault, no limit
  /// @param token_ address of the token, use address(0) to withdraw gas token
  /// @param destination_ recipient address to receive the fund
  /// @param amount_ amount of fund to withdaw
  function withdraw(address token_, address destination_, uint256 amount_) external onlyOwner {
    require(destination_ != address(0), "BaryonPad: Destination is zero address");

    uint256 availableAmount;
    if(token_ == address(0)) {
      availableAmount = address(this).balance;
    } else {
      availableAmount = IERC20(token_).balanceOf(address(this));
    }

    require(amount_ <= availableAmount, "BaryonPad: Not enough balance");
    if(token_ == address(0)) {
      destination_.call{value:amount_}("");
    } else {
      IERC20(token_).transfer(destination_, amount_);
    }

    emit Withdrawn(_msgSender(), destination_, token_, amount_);
  }

  /// @dev withdraw NFT from contract
  /// @param token_ address of the token, use address(0) to withdraw gas token
  /// @param destination_ recipient address to receive the fund
  /// @param tokenId_ ID of NFT to withdraw
  function withdrawNft(address token_, address destination_, uint256 tokenId_) external onlyOwner {
    require(destination_ != address(0), "BaryonPad: destination is zero address");

    IERC721(token_).transferFrom(address(this), destination_, tokenId_);

    emit Withdrawn(_msgSender(), destination_, token_, 1);
  }
}

contract BaryonPadFactory is Ownable, Payable {

  constructor () Ownable(_msgSender()) {
  }

  /// @dev Emit `Created` when a new vault is created
  event Created(address indexed vault);
  /// @dev Emit `Withdrawn` when owner withdraw fund from the factory
  event Withdrawn(address indexed owner, address indexed recipient, address indexed token, uint256 value);

  /// @dev get contract address
  /// @param owner_ Owner of newly created pad
  /// @param salt_ an arbitrary value
  function getAddress(address owner_, uint salt_) public view returns (address) {
    bytes memory bytecode = _getBytecode(owner_);

    bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), address(this), salt_, keccak256(bytecode)));

    return address(uint160(uint(hash)));
  }


  /// @dev get byte code of launchpad Contract
  /// @param owner_ Owner of newly created pad
  function _getBytecode(address owner_) private pure returns (bytes memory) {
    bytes memory bytecode = type(BaryonPad).creationCode;

    return abi.encodePacked(bytecode, abi.encode(owner_));
  }


  /// @dev deploy new contract with CREATE2 opcode
  /// @param code_ code of contract
  /// @param salt_ an arbitrary value
  function _deploy(bytes memory code_, uint256 salt_) private returns (address){
    address addr;
    assembly {
      addr := create2(0, add(code_, 0x20), mload(code_), salt_)
      if iszero(extcodesize(addr)) {
      revert(0, 0)
      }
    }
    return addr;
  }
  
  /// @dev create a new pad with CREATE2 opcode
  /// @param owner_ Owner of newly created pad
  /// @param salt_ an arbitrary value 
  function createPad(address owner_, uint256 salt_) external returns (address pad) {
    bytes memory bytecode = _getBytecode(owner_);

    pad = _deploy(bytecode, salt_);

    emit Created(pad);
  }

  /// @dev withdraw token from contract
  /// @param token_ address of the token, use address(0) to withdraw gas token
  /// @param destination_ recipient address to receive the fund
  /// @param amount_ amount of fund to withdaw
  function withdraw(address token_, address destination_, uint256 amount_) external onlyOwner {
    require(destination_ != address(0), "BaryonPad: Destination is zero address");

    uint256 availableAmount;
    if(token_ == address(0)) {
      availableAmount = address(this).balance;
    } else {
      availableAmount = IERC20(token_).balanceOf(address(this));
    }

    require(amount_ <= availableAmount, "BaryonPad: Not enough balance");

    if(token_ == address(0)) {
      destination_.call{value:amount_}("");
    } else {
      IERC20(token_).transfer(destination_, amount_);
    }

    emit Withdrawn(_msgSender(), destination_, token_, amount_);
  }

  /// @dev withdraw NFT from contract
  /// @param token_ address of the token, use address(0) to withdraw gas token
  /// @param destination_ recipient address to receive the fund
  /// @param tokenId_ ID of NFT to withdraw
  function withdrawNft(address token_, address destination_, uint256 tokenId_) external onlyOwner {
    require(destination_ != address(0), "BaryonPad: destination is zero address");

    IERC721(token_).transferFrom(address(this), destination_, tokenId_);

    emit Withdrawn(_msgSender(), destination_, token_, 1);
  }
}