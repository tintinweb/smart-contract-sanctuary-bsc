/**
 *Submitted for verification at BscScan.com on 2023-01-01
*/

// Dependency file: @openzeppelin/contracts/utils/Context.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

// pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


// Dependency file: @openzeppelin/contracts/access/Ownable.sol

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/utils/Context.sol";

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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// Dependency file: contracts/orand/OrandManagement.sol

// pragma solidity ^0.8.0;
// import '/Users/chiro/GitHub/orochimaru/contracts/node_modules/@openzeppelin/contracts/access/Ownable.sol';

contract OrandManagement is Ownable {
  // Public key that will be use to
  uint256[2] internal publicKey;

  // Event Set New Public Key
  event SetNewPublicKey(address indexed actor, uint256 indexed pkx, uint256 indexed pky);

  // Set public key of Orand at the constructing time
  constructor(uint256[2] memory pk) {
    _setPublicKey(pk);
  }

  //=======================[  Owner  ]====================

  // Set new public key to verify proof
  function setPublicKey(uint256[2] memory pk) external onlyOwner returns (bool) {
    return _setPublicKey(pk);
  }

  //=======================[  Internal  ]====================

  // Set new public key to verify proof
  function _setPublicKey(uint256[2] memory pk) internal returns (bool) {
    publicKey = pk;
    emit SetNewPublicKey(msg.sender, pk[0], pk[1]);
    return true;
  }

  //=======================[  External view  ]====================

  // Get public key
  function getPublicKey() external view returns (uint256[2] memory) {
    return publicKey;
  }
}


// Dependency file: contracts/interfaces/IOrandStorage.sol

// pragma solidity ^0.8.0;

interface IOrandStorage {
  // Storage form of proof
  struct Epoch {
    uint128 epoch;
    uint64 timestamp;
    uint64 sued;
    uint256 y;
    uint256[2] gamma;
    uint256 c;
    uint256 s;
    address uWitness;
    uint256[2] cGammaWitness;
    uint256[2] sHashWitness;
    uint256 zInv;
  }

  // Tranmission form of proof
  struct EpochProof {
    uint256 y;
    uint256[2] gamma;
    uint256 c;
    uint256 s;
    address uWitness;
    uint256[2] cGammaWitness;
    uint256[2] sHashWitness;
    uint256 zInv;
  }
}


// Dependency file: contracts/orand/OrandStorage.sol

// pragma solidity ^0.8.0;
// import 'contracts/interfaces/IOrandStorage.sol';

error InvalidEpochId();
error SuedEpoch();

contract OrandStorage is IOrandStorage {
  // Event: New Epoch
  event NewEpoch(address indexed receiverAddress, uint256 indexed epoch, uint256 indexed randomness);

  // Storage of epoch
  mapping(address => mapping(uint256 => Epoch)) internal storageEpoch;

  // Total number of epoch
  mapping(address => uint256) internal totalEpoch;

  // Check if epoch is valid
  modifier onlyValidEpoch(address receiverAddress, uint256 epoch) {
    if (epoch >= totalEpoch[receiverAddress] || epoch < 1) {
      revert InvalidEpochId();
    }
    if (storageEpoch[receiverAddress][epoch].sued != 0) {
      revert SuedEpoch();
    }
    _;
  }

  //=======================[  Internal  ]====================

  function _addEpoch(address receiverAddress, EpochProof memory newEpoch) internal returns (bool) {
    uint256 receiverEpoch = totalEpoch[receiverAddress];
    storageEpoch[receiverAddress][receiverEpoch] = Epoch({
      epoch: uint128(receiverEpoch),
      timestamp: uint64(block.timestamp),
      sued: 0,
      y: newEpoch.y,
      // Alpha of this epoch is the result of previous epoch
      // Alpha_i = Y_{i-1}
      gamma: newEpoch.gamma,
      c: newEpoch.c,
      s: newEpoch.s,
      uWitness: newEpoch.uWitness,
      cGammaWitness: newEpoch.cGammaWitness,
      sHashWitness: newEpoch.cGammaWitness,
      zInv: newEpoch.zInv
    });
    emit NewEpoch(receiverAddress, receiverEpoch, newEpoch.y);
    totalEpoch[receiverAddress] += 1;
    return true;
  }

  //=======================[  External View  ]====================

  // Get total number of epoch
  function getTotalEpoch(address receiverAddress) external view returns (uint256) {
    return totalEpoch[receiverAddress];
  }

  // Get arbitrary epoch
  function getEpoch(
    address receiverAddress,
    uint epoch
  ) external view onlyValidEpoch(receiverAddress, epoch) returns (Epoch memory) {
    return storageEpoch[receiverAddress][epoch];
  }

  // Get current epoch
  function getCurrentEpoch(address receiverAddress) external view returns (Epoch memory) {
    return storageEpoch[receiverAddress][totalEpoch[receiverAddress] - 1];
  }
}


// Dependency file: contracts/libraries/Bytes.sol

// pragma solidity >=0.8.4 <0.9.0;

error InvalidInputLength();
error OutOfRange();

library Bytes {
  // Convert bytes to bytes32[]
  function toBytes32Array(bytes memory input) internal pure returns (bytes32[] memory) {
    if (input.length % 32 != 0) {
      revert InvalidInputLength();
    }
    bytes32[] memory result = new bytes32[](input.length / 32);
    assembly {
      // Read length of data from offset
      let length := mload(input)

      // Seek offset to the beginning
      let offset := add(input, 0x20)

      // Next is size of chunk
      let resultOffset := add(result, 0x20)

      for {
        let i := 0
      } lt(i, length) {
        i := add(i, 0x20)
      } {
        mstore(resultOffset, mload(add(offset, i)))
        resultOffset := add(resultOffset, 0x20)
      }
    }
    return result;
  }

  // Read address from input bytes buffer
  function readAddress(bytes memory input, uint256 offset) internal pure returns (address result) {
    if (offset + 20 > input.length) {
      revert OutOfRange();
    }
    assembly {
      result := shr(96, mload(add(add(input, 0x20), offset)))
    }
  }

  // Read uint256 from input bytes buffer
  function readUint256(bytes memory input, uint256 offset) internal pure returns (uint256 result) {
    if (offset + 32 > input.length) {
      revert OutOfRange();
    }
    assembly {
      result := mload(add(add(input, 0x20), offset))
    }
  }

  // Read bytes from input bytes buffer
  function readBytes(bytes memory input, uint256 offset, uint256 length) internal pure returns (bytes memory) {
    if (offset + length > input.length) {
      revert OutOfRange();
    }
    bytes memory result = new bytes(length);
    assembly {
      // Seek offset to the beginning
      let seek := add(add(input, 0x20), offset)

      // Next is size of data
      let resultOffset := add(result, 0x20)

      for {
        let i := 0
      } lt(i, length) {
        i := add(i, 0x20)
      } {
        mstore(add(resultOffset, i), mload(add(seek, i)))
      }
    }
    return result;
  }
}


// Dependency file: contracts/libraries/Verifier.sol

// pragma solidity >=0.8.4 <0.9.0;

error InvalidV(uint8 v);

library Verifier {
  function verifySerialized(bytes memory message, bytes memory signature) internal pure returns (address) {
    bytes32 r;
    bytes32 s;
    uint8 v;
    assembly {
      // Singature need to be 65 in length
      // if (signature.length !== 65) revert();
      if iszero(eq(mload(signature), 65)) {
        revert(0, 0)
      }
      // r = signature[:32]
      // s = signature[32:64]
      // v = signature[64]
      r := mload(add(signature, 0x20))
      s := mload(add(signature, 0x40))
      v := byte(0, mload(add(signature, 0x60)))
    }
    return verify(message, r, s, v);
  }

  function verify(bytes memory message, bytes32 r, bytes32 s, uint8 v) internal pure returns (address) {
    if (v < 27) {
      v += 27;
    }
    // V must be 27 or 28
    if (v != 27 && v != 28) {
      revert InvalidV(v);
    }
    // Get hashes of message with Ethereum proof prefix
    bytes32 hashes = keccak256(abi.encodePacked('\x19Ethereum Signed Message:\n', uintToStr(message.length), message));

    return ecrecover(hashes, v, r, s);
  }

  function uintToStr(uint256 value) internal pure returns (string memory result) {
    // Inspired by OraclizeAPI's implementation - MIT licence
    // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

    if (value == 0) {
      return '0';
    }
    uint256 temp = value;
    uint256 digits;
    while (temp != 0) {
      digits++;
      temp /= 10;
    }
    bytes memory buffer = new bytes(digits);
    while (value != 0) {
      digits -= 1;
      buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
      value /= 10;
    }
    return string(buffer);
  }
}


// Dependency file: contracts/orand/OrandSignatureVerifier.sol

// pragma solidity ^0.8.0;
// import '/Users/chiro/GitHub/orochimaru/contracts/node_modules/@openzeppelin/contracts/access/Ownable.sol';
// import 'contracts/libraries/Bytes.sol';
// import 'contracts/libraries/Verifier.sol';

error InvalidProofLength(bytes proof);
error InvalidProofNonce(uint256 proofNonce);
error InvalidProofSigner(address proofSigner);

contract OrandSignatureVerifier is Ownable {
  // Allowed orand operator
  address internal operator;

  // Nonce value
  mapping(address => uint256) internal nonce;

  // Byte manipulation
  using Bytes for bytes;

  // Verifiy digital signature
  using Verifier for bytes;

  // Event: Set New Operator
  event SetNewOperator(address indexed oldOperator, address indexed newOperator);

  // Set operator at constructing time
  constructor(address operatorAddress) {
    _setOperator(operatorAddress);
  }

  //=======================[  Owner  ]====================

  // Set new operator to submit proof
  function setOperator(address operatorAddress) external onlyOwner returns (bool) {
    return _setOperator(operatorAddress);
  }

  //=======================[  Internal  ]====================

  // Increasing nonce of receiver address
  function _increaseNonce(address receiverAddress) internal returns (bool) {
    nonce[receiverAddress] += 1;
    return true;
  }

  // Set proof operator
  function _setOperator(address operatorAddress) internal returns (bool) {
    emit SetNewOperator(operator, operatorAddress);
    operator = operatorAddress;
    return true;
  }

  //=======================[  Internal View ]====================

  // Decompose nonce and receiver address in signed proof
  function _decomposeProof(
    bytes memory proof
  ) internal pure returns (uint256 receiverNonce, address receiverAddress, uint256 y) {
    uint256 proofUint = proof.readUint256(65);
    receiverNonce = proofUint >> 160;
    receiverAddress = address(uint160(proofUint));
    y = proof.readUint256(97);
  }

  // Verify proof of operator
  function _vefifyProof(bytes memory proof) internal view returns (bool verified, address receiverAddress, uint256 y) {
    if (proof.length != 129) {
      revert InvalidProofLength(proof);
    }
    bytes memory signature = proof.readBytes(0, 65);
    bytes memory message = proof.readBytes(65, proof.length);
    uint256 receiverNonce;
    // Receiver Nonce || Receiver Address || y
    (receiverNonce, receiverAddress, y) = _decomposeProof(proof);
    if (nonce[receiverAddress] != receiverNonce) {
      revert InvalidProofNonce(receiverNonce);
    }
    address proofSigner = message.verifySerialized(signature);
    if (proofSigner != operator) {
      revert InvalidProofSigner(proofSigner);
    }
    verified = true;
  }

  //=======================[  External View  ]====================
  // Get signer address from a valid proof
  function checkProofSigner(
    bytes memory proof
  ) external pure returns (address signer, address receiverAddress, uint256 receiverNonce, uint256 y) {
    bytes memory signature = proof.readBytes(0, 65);
    bytes memory message = proof.readBytes(65, proof.length);
    (receiverNonce, receiverAddress, y) = _decomposeProof(proof);
    signer = message.verifySerialized(signature);
  }

  // Get operator
  function getOperator() external view returns (address) {
    return operator;
  }

  // Get nonce
  function getNonce(address receiverAddress) external view returns (uint256) {
    return nonce[receiverAddress];
  }
}


// Dependency file: @openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

// pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}


// Dependency file: contracts/orand/OrandPenalty.sol

// pragma solidity ^0.8.0;
// import '/Users/chiro/GitHub/orochimaru/contracts/node_modules/@openzeppelin/contracts/access/Ownable.sol';
// import '/Users/chiro/GitHub/orochimaru/contracts/node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol';

error UnableToApplyPenalty(address receiver, uint256 penaltyAmount);
error NoCollateralFromVault(address vaultAddress);

contract OrandPenalty is Ownable {
  // Token vault address
  address internal vault;

  // Amount of penalty
  uint256 internal penaltyAmount;

  // Token that will be used to pay for penalty
  IERC20 internal token;

  // Event: Set new penalty and payment token
  event SetNewPenalty(address indexed vaultAddress, address indexed tokenAddress, uint256 indexed newPenalty);

  // Event: Applied penalty to Orand
  event AppliedPenalty(address receiverAddress, uint256 epoch, uint256 penaltyAmount);

  // Check if the given vault contain enough collateral
  modifier onlyReadyForPenalty() {
    if (token.allowance(vault, address(this)) < penaltyAmount) {
      revert NoCollateralFromVault(vault);
    }
    _;
  }

  constructor(address vaultAddress, address tokenAddress, uint256 tokenPenaltyAmount) {
    _setPenalty(vaultAddress, tokenAddress, tokenPenaltyAmount);
  }

  //=======================[  Owner  ]====================
  // Set the penalty
  function setPenalty(
    address vaultAddress,
    address tokenAddress,
    uint256 newPenalty
  ) external onlyOwner returns (bool) {
    _setPenalty(vaultAddress, tokenAddress, newPenalty);
    return true;
  }

  //=======================[  Internal  ]====================
  // Penaltiy participants in Orand
  function _penaltyOrand(address receiver) internal returns (bool) {
    if (!_safeTransfer(receiver, penaltyAmount)) {
      revert UnableToApplyPenalty(receiver, penaltyAmount);
    }
    return true;
  }

  // Penaltiy participants in Orand
  function _setPenalty(address vaultAddress, address tokenAddress, uint256 newPenalty) internal returns (bool) {
    emit SetNewPenalty(vaultAddress, tokenAddress, newPenalty);
    penaltyAmount = newPenalty;
    token = IERC20(tokenAddress);
    return true;
  }

  // Perform safe transfer to a given address
  function _safeTransfer(address to, uint256 value) internal returns (bool) {
    uint256 beforeBalance = token.balanceOf(to);
    token.transferFrom(vault, to, value);
    return beforeBalance + value == token.balanceOf(to);
  }

  //=======================[  External View  ]====================
  // Read the penalty information
  function getPenalty() external view returns (address vaultAddress, address tokenAddress, uint256 amount) {
    vaultAddress = vault;
    tokenAddress = address(token);
    amount = penaltyAmount;
  }
}


// Dependency file: contracts/interfaces/IOrandECVRF.sol

// pragma solidity ^0.8.0;

interface IOrandECVRF {
  function verifyProof(
    uint256[2] memory pk,
    uint256[2] memory gamma,
    uint256 c,
    uint256 s,
    uint256 alpha,
    address uWitness,
    uint256[2] memory cGammaWitness,
    uint256[2] memory sHashWitness,
    uint256 zInv
  ) external view returns (uint256 output);
}


// Dependency file: contracts/interfaces/IOrandProviderV1.sol

// pragma solidity ^0.8.0;
// import 'contracts/interfaces/IOrandStorage.sol';

interface IOrandProviderV1 is IOrandStorage {
  error InvalidProof(bytes proof);
  error InvalidECVRFOutput(uint256 linkY, uint256 inputY);
  error UnableToAddNewEpoch(address receiver, EpochProof epoch);
  error UnableToForwardRandomness(address receiver, uint256 y);
  error UnableToIncreaseNonce();
  error UnableToApplyPenalty(address sender, address receiver, uint256 epoch);
}


// Dependency file: contracts/interfaces/IOrandConsumerV1.sol

// pragma solidity ^0.8.0;

interface IOrandConsumerV1 {
  function consumeRandomness(uint256 randomness) external returns (bool);
}


// Root file: contracts/orand/OrandProviderV1.sol

pragma solidity ^0.8.0;
// import 'contracts/orand/OrandManagement.sol';
// import 'contracts/orand/OrandStorage.sol';
// import 'contracts/orand/OrandSignatureVerifier.sol';
// import 'contracts/orand/OrandPenalty.sol';
// import 'contracts/interfaces/IOrandECVRF.sol';
// import 'contracts/interfaces/IOrandProviderV1.sol';
// import 'contracts/interfaces/IOrandConsumerV1.sol';

contract OrandProviderV1 is IOrandProviderV1, OrandStorage, OrandManagement, OrandSignatureVerifier, OrandPenalty {
  // ECVRF verifier smart contract
  IOrandECVRF ecvrf;

  // Event: Set New ECVRF Verifier
  event SetNewECVRFVerifier(address indexed actor, address indexed ecvrfAddress);

  // Provider V1 will support many consumers at once
  constructor(
    uint256[2] memory pk,
    address operator,
    address ecvrfAddress,
    address vaultAddress,
    address tokenAddress,
    uint256 penaltyAmmount
  ) OrandManagement(pk) OrandSignatureVerifier(operator) OrandPenalty(vaultAddress, tokenAddress, penaltyAmmount) {
    ecvrf = IOrandECVRF(ecvrfAddress);
  }

  //=======================[  Owner  ]====================
  function setNewECVRFVerifier(address ecvrfAddress) external onlyOwner {
    ecvrf = IOrandECVRF(ecvrfAddress);
    emit SetNewECVRFVerifier(msg.sender, ecvrfAddress);
  }

  //=======================[  External  ]====================
  // Publish new epoch
  function publish(bytes memory proof, EpochProof memory newEpoch) external onlyReadyForPenalty returns (bool) {
    (bool verified, address receiverAddress, uint256 y) = _vefifyProof(proof);
    // Verifier is false, signature proof is incorrect
    if (!verified) {
      revert InvalidProof(proof);
    }
    // Linked y is different from submitted value
    if (y != newEpoch.y) {
      revert InvalidECVRFOutput(y, newEpoch.y);
    }
    // Unable to add epoch to storage
    if (!_addEpoch(receiverAddress, newEpoch)) {
      revert UnableToAddNewEpoch(receiverAddress, newEpoch);
    }
    // Unable to forward randomness to receiver contract
    if (!IOrandConsumerV1(receiverAddress).consumeRandomness(newEpoch.y)) {
      revert UnableToForwardRandomness(receiverAddress, y);
    }
    // Increasing nonce of receiver to prevent replay attack
    if (!_increaseNonce(receiverAddress)) {
      revert UnableToIncreaseNonce();
    }
    return true;
  }

  // @dev allow any account to sue Orochi Network and its alliance
  function sue(address receiverAddress, uint256 epoch) external onlyValidEpoch(receiverAddress, epoch) returns (bool) {
    Epoch memory previousEpoch = storageEpoch[receiverAddress][epoch - 1];
    Epoch memory currentEpoch = storageEpoch[receiverAddress][epoch];
    // Alpha_i = Y_{i-1}
    try
      ecvrf.verifyProof(
        publicKey,
        currentEpoch.gamma,
        currentEpoch.c,
        currentEpoch.s,
        previousEpoch.y,
        currentEpoch.uWitness,
        currentEpoch.cGammaWitness,
        currentEpoch.sHashWitness,
        currentEpoch.zInv
      )
    returns (uint256 y) {
      if (currentEpoch.y == y) {
        // Everything is good
        return false;
      }
    } catch {
      // Handle revert case, if reverted that meant signature is corrupted
    }
    // Apply penalty for the rest
    if (!_penaltyOrand(msg.sender)) {
      revert UnableToApplyPenalty(msg.sender, receiverAddress, epoch);
    }
    currentEpoch.sued = 1;
    storageEpoch[receiverAddress][epoch] = currentEpoch;
    emit AppliedPenalty(receiverAddress, epoch, penaltyAmount);
    return true;
  }

  //=======================[  External View  ]====================
  // Get address of ECVRF verifier
  function getECVRFVerifier() external view returns (address) {
    return address(ecvrf);
  }

  // Check a proof is valid or not
  function check(
    uint256[2] memory gamma,
    uint256 c,
    uint256 s,
    uint256 alpha,
    address uWitness,
    uint256[2] memory cGammaWitness,
    uint256[2] memory sHashWitness,
    uint256 zInv
  ) external view returns (uint256) {
    return ecvrf.verifyProof(publicKey, gamma, c, s, alpha, uWitness, cGammaWitness, sHashWitness, zInv);
  }
}