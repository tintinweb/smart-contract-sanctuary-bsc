/**
 *Submitted for verification at BscScan.com on 2022-06-11
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)


/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
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

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}




/** 
 *  SourceUnit: /home/pelumi/Desktop/WorkFolder2/bridge-int/src/Registry.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)



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




/** 
 *  SourceUnit: /home/pelumi/Desktop/WorkFolder2/bridge-int/src/Registry.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT


interface IController {

    function isAdmin(address account) external view returns (bool);


    function isRegistrar(address account) external view returns (bool);


    function isOracle(address account) external view returns (bool);


    function isValidator(address account) external view returns (bool);


    function owner() external view returns (address);

    
    function validatorsCount() external view returns (uint256);

    function settings() external view returns (address);


    function deployer() external view returns (address);


    function feeController() external view returns (address);

    
}



/** 
 *  SourceUnit: /home/pelumi/Desktop/WorkFolder2/bridge-int/src/Registry.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: GPL-3.0



interface Ibridge{
    struct asset {
        address tokenAddress; 
        uint256 minAmount;
        uint256 maxAmount;
        uint256 feeBalance;
        uint256 collectedFees;
        bool ownedRail;
        address manager;
        address feeRemitance;
        uint256 balance;
        bool isSet;
     }


    function isAssetSupportedChain(address assetAddress , uint256 chainID) external view returns (bool);


    function controller() external view returns (address);


    function claim(bytes32 transaction_id) external;


    function mint(bytes32 transaction_id) external ;


    function settings() external view returns (address); 


    function chainId() external view returns (uint256);


    function foriegnAssetChainID(address _asset) external view returns (uint256);


    function assetLimits(address _asset, bool native) external view returns (uint256 , uint256);


    function foriegnAssets(address assetAddress) external view returns (asset memory);


    function wrappedForiegnPair(address assetAddress , uint256 chainID) external view returns (address);

    function udpadateBridgePool(address _bridgePool) external;

    function isDirectSwap(address assetAddress ,uint256 chainID) external view returns (bool);
}



/** 
 *  SourceUnit: /home/pelumi/Desktop/WorkFolder2/bridge-int/src/Registry.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT

interface Isettings {

    function networkFee(uint256 chainId) external view returns (uint256);

    function minValidations() external view returns (uint256);
    
    function isNetworkSupportedChain(uint256 chainID) external view returns (bool);

    function feeRemitance() external view returns (address);

    function railRegistrationFee() external view returns (uint256);

    function railOwnerFeeShare() external view returns (uint256);

    function onlyOwnableRail() external view returns (bool);

    function updatableAssetState() external view returns (bool);

    function minWithdrawableFee() external view returns (uint256);

    function brgToken() external view returns (address);

    function getNetworkSupportedChains() external view returns(uint256[] memory);
    
    function baseFeePercentage() external view returns(uint256);

    function baseFeeEnable() external view returns(bool);

    function approvedToAdd(address token , address user) external view returns(bool);
}





/** 
 *  SourceUnit: /home/pelumi/Desktop/WorkFolder2/bridge-int/src/Registry.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT


interface IRegistery {
    struct Transaction{
            uint256 chainId;
            address assetAddress;
            uint256 amount;
            address receiver;
            uint256 nounce;
            bool  isCompleted;
        }

    function getUserNonce(address user) external returns (uint256);
    function isSendTransaction(bytes32 transactionID) external returns (bool);
    function isClaimTransaction(bytes32 transactionID) external returns (bool);
    function isMintTransaction(bytes32 transactionID) external returns (bool);
    function isburnTransactio(bytes32 transactionID) external returns (bool);
    function transactionValidated(bytes32 transactionID) external returns (bool);
    function assetChainBalance(address asset, uint256 chainid) external returns (uint256);

    function sendTransactions(bytes32 transactionID) external returns (Transaction memory);
    function claimTransactions(bytes32 transactionID) external returns (Transaction memory);
    function burnTransactions(bytes32 transactionID) external returns (Transaction memory);
    function mintTransactions(bytes32 transactionID) external returns (Transaction memory);
    
    function completeSendTransaction(bytes32 transactionID) external;
    function completeBurnTransaction(bytes32 transactionID) external;
    function completeMintTransaction(bytes32 transactionID) external;
    function completeClaimTransaction(bytes32 transactionID) external;
    function transferOwnership(address newOwner) external;
    
  
    function registerTransaction(
       bytes32 transactionID,
       uint256 chainId,
       address assetAddress,
       uint256 amount,
       address receiver,
       uint256 nounce,
       uint8 _transactionType
     ) external;
}



/** 
 *  SourceUnit: /home/pelumi/Desktop/WorkFolder2/bridge-int/src/Registry.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/cryptography/ECDSA.sol)



////import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * ////IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * ////IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}




/** 
 *  SourceUnit: /home/pelumi/Desktop/WorkFolder2/bridge-int/src/Registry.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)



////import "../utils/Context.sol";

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


/** 
 *  SourceUnit: /home/pelumi/Desktop/WorkFolder2/bridge-int/src/Registry.sol
*/

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: GPL-3.0
pragma solidity 0.8.13;

////import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
////import "../lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
////import "./interface/Iregistry.sol";
////import "./interface/Isettings.sol";
////import "./interface/Ibridge.sol";
////import "./interface/Icontroller.sol";



contract  Registry is Ownable{
    using ECDSA for bytes32;

    struct Transaction{
       uint256 chainId;
       address assetAddress;
       uint256 amount;
       address receiver;
       uint256 nounce;
       bool  isCompleted;
   }
   struct validation {
       uint256 validationCount;
       bool validated;
   }
   enum transactionType {send , burn , mint ,claim}

   mapping (address => uint256) public assetTotalTransactionCount;
   mapping (address => mapping( uint256 => uint256 )) public assetTransactionTypeCount;
   mapping(address => mapping( uint256 => uint256 )) public assetChainBalance;
   mapping(address => uint256) public getUserNonce; 
   mapping (bytes32 => bool)  public isSendTransaction;
   mapping (bytes32 => Transaction)  public sendTransactions;
   mapping (bytes32 => bool)  public isClaimTransaction;
   mapping (bytes32 => Transaction)  public claimTransactions;
   mapping(bytes32 => Transaction) public mintTransactions;
   mapping(bytes32 => bool) public isMintTransaction;
   mapping(bytes32 => Transaction) public burnTransactions;
   mapping(bytes32 => bool) public isburnTransaction;
   mapping(bytes32 => validation ) public transactionValidations;
   mapping(bytes32 => address[] ) public TransactionValidators;
   mapping(bytes32 => mapping(address => bool)) public hasValidatedTransaction;
   uint256 public totalTransactions;

   event TransactionValidated(bytes32 indexed transactionID);
   event SendTransactionCompleted(bytes32 indexed transactionID);
   event BurnTransactionCompleted(bytes32 indexed transactionID);
   event MintTransactionCompleted(bytes32 indexed transactionID);
   event ClaimTransactionCompleted(bytes32 indexed transactionID);

   constructor(){}
  

  function completeSendTransaction(bytes32 transactionID) external {
      require(isSendTransaction[transactionID] ,"invalid Transaction");
      emit SendTransactionCompleted(transactionID);
      sendTransactions[transactionID].isCompleted = true;
  }


  function completeBurnTransaction(bytes32 transactionID) external {
       require(isburnTransaction[transactionID] ,"invalid Transaction");
       emit BurnTransactionCompleted(transactionID);
       burnTransactions[transactionID].isCompleted = true ;
  }


  function completeMintTransaction(bytes32 transactionID) external {
       require(isMintTransaction[transactionID] ,"invalid Transaction");
       emit MintTransactionCompleted(transactionID);
       mintTransactions[transactionID].isCompleted = true;
  }


  function completeClaimTransaction(bytes32 transactionID) external {
      require(isClaimTransaction[transactionID] ,"invalid Transaction");
      emit ClaimTransactionCompleted(transactionID);
      assetChainBalance[claimTransactions[transactionID].assetAddress][claimTransactions[transactionID].chainId] -= claimTransactions[transactionID].amount;
       claimTransactions[transactionID].isCompleted = true;
  }

  function registerTransaction(
       bytes32 transactionID,
       uint256 chainId,
       address assetAddress,
       uint256 amount,
       address receiver,
       uint256 nounce,
       transactionType _transactionType
  ) 
        public 
        onlyOwner 
  {
      if (_transactionType  == transactionType.send) {
          sendTransactions[transactionID] = Transaction(chainId , assetAddress ,amount , receiver ,nounce, false);
          isSendTransaction[transactionID] = true;
          getUserNonce[receiver]++;
          assetChainBalance[assetAddress][chainId] += amount;
      } else if (_transactionType  == transactionType.burn) {
          burnTransactions[transactionID] = Transaction(chainId , assetAddress ,amount , receiver ,nounce, false);
          isburnTransaction[transactionID] = true;
          getUserNonce[receiver]++;
      }
      assetTotalTransactionCount[assetAddress]++;
      totalTransactions++;
  }
  
  
  function _registerTransaction(
       bytes32 transactionID,
       uint256 chainId,
       address assetAddress,
       uint256 amount,
       address receiver,
       uint256 nounce,
       transactionType _transactionType
  ) 
      internal
  {
      if (_transactionType  == transactionType.mint) {
          mintTransactions[transactionID] = Transaction(chainId , assetAddress ,amount , receiver ,nounce, false);
          isMintTransaction[transactionID] = true;
      } else if (_transactionType  == transactionType.claim) {
          claimTransactions[transactionID] = Transaction(chainId , assetAddress ,amount , receiver ,nounce, false);
          isClaimTransaction[transactionID] = true;
      }
  }
  
  
  function registerClaimTransaction(
      bytes32 claimID,
      uint256 chainFrom,
      address assetAddress,
      uint256 amount,
      address receiver,
      uint256 nounce
    ) 
      external 
    {
        require(IController(Ibridge(owner()).controller()).isOracle(msg.sender),"U_A");
        require(!isClaimTransaction[claimID], "registerred");
        require(Ibridge(owner()).isAssetSupportedChain(assetAddress ,chainFrom), "chain_err");
        bytes32 requiredClaimID = keccak256(abi.encodePacked(
            chainFrom,
            Ibridge(owner()).chainId(),
            assetAddress,
            amount,
            receiver,
            nounce
            ));

        require(claimID  == requiredClaimID , "claimid_err");
        _registerTransaction(claimID ,chainFrom , assetAddress, amount , receiver ,nounce, transactionType.claim );
   }


   function registerMintTransaction(
       bytes32 mintID,
       uint256 chainFrom,
       address assetAddress,
       uint256 amount,
       address receiver,
       uint256 nounce
    ) 
       external 
    {
        require(IController(Ibridge(owner()).controller()).isOracle(msg.sender),"U_A");
        require(!isMintTransaction[mintID], "registerred");
        Ibridge  bridge = Ibridge(owner());
        address wrappedAddress = bridge.wrappedForiegnPair(assetAddress ,chainFrom);
        require(wrappedAddress != address(0), "I_A");
        if(!bridge.isDirectSwap(assetAddress , chainFrom)){
            Ibridge.asset memory  foriegnAsset = bridge.foriegnAssets(wrappedAddress);
            require(foriegnAsset.isSet , "asset_err");
            require(bridge.foriegnAssetChainID(wrappedAddress) == chainFrom , "chain_err");
        }
        
        bytes32 requiredmintID = keccak256(abi.encodePacked(
            chainFrom,
            bridge.chainId(),
            assetAddress,
            amount,
            receiver,
            nounce
            ));
        require(mintID  == requiredmintID, "mint: error validation mint ID");
        _registerTransaction(mintID ,chainFrom , wrappedAddress, amount , receiver ,nounce, transactionType.mint);
   }



   function validateTransaction(bytes32 transactionId , bytes[] memory signatures ,bool mintable) external  {
       require(IController(Ibridge(owner()).controller()).isValidator(msg.sender) , "U_A");
       require(Isettings(Ibridge(owner()).settings()).minValidations() != 0 , "minvalidator_err");
       uint interfacingChainId;
        address assetAddress;
        uint amount;
        address receiver;
        uint nounce;
       Transaction memory transaction;
       if (mintable) {
           require(isMintTransaction[transactionId] , "mintID_err"); 
           transaction =  mintTransactions[transactionId];
            interfacingChainId = transaction.chainId;
            assetAddress = transaction.assetAddress;
            amount = transaction.amount;
            receiver = transaction.receiver;
            nounce = transaction.nounce;
           if(!Ibridge(owner()).isDirectSwap(transaction.assetAddress , transaction.chainId)){
               (,uint256 max) =  Ibridge(owner()).assetLimits(transaction.assetAddress, false);
               require(transaction.amount <= max , "Amount_limit_Err");
           }
        } else {
            require(isClaimTransaction[transactionId] , "caimID_err"); 
            transaction =  claimTransactions[transactionId]; 
            interfacingChainId = transaction.chainId;
            assetAddress = transaction.assetAddress;
            amount = transaction.amount;
            receiver = transaction.receiver;
            nounce = transaction.nounce;
            (,uint256 max) =  Ibridge(owner()).assetLimits(transaction.assetAddress , true);
            require(transaction.amount <= max && transaction.amount <= assetChainBalance[transaction.assetAddress][transaction.chainId]   , "Amount_limit_Err");
        }
       require(!transaction.isCompleted, "completed");
        uint256 validSignatures;
        

       
       // this part of the code was remove to access if you can recreate it to verify the signatures for a transaction

       // the message that was signed by the validators is a hash of derived as shown bellow

            bytes32 messageHash = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            keccak256(abi.encodePacked(
                Ibridge(owner()).chainId(),   // this is goten from Ibridge(owner()).chainId()
                interfacingChainId,
                assetAddress,
                amount,
                receiver,
                nounce
            ))));

            for(uint i = 0; i < signatures.length; i++){
               address signer = messageHash.recover(signatures[i]); // returns the address of the signature
               // checks if the address is a valid validator;
               if(IController(Ibridge(owner()).controller()).isValidator(signer)){
                   validSignatures++;
               }
            }

    // to all you need to do here is verify each of this signatures to accertain if the are from a valid signer


       //
       require(validSignatures >= Isettings(Ibridge(owner()).settings()).minValidations() ,"insuficient_signers");
       transactionValidations[transactionId].validationCount = validSignatures; 
       transactionValidations[transactionId].validated  = true;
        emit TransactionValidated(transactionId);
       if (mintable) {
           Ibridge(owner()).mint(transactionId);
       } else {
           Ibridge(owner()).claim(transactionId);
       }
      
   }


   

    function transactionValidated(bytes32 transactionID) external  view returns (bool) {
      return transactionValidations[transactionID].validated;
  }

}