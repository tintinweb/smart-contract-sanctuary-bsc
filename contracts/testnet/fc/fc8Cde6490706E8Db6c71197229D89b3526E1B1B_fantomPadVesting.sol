/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

/**
 *Submitted for verification at FtmScan.com on 2022-06-27
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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
}

// File: @openzeppelin/contracts/utils/cryptography/ECDSA.sol


// OpenZeppelin Contracts (last updated v4.5.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;


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
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
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
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
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

// File: @openzeppelin/contracts/utils/cryptography/draft-EIP712.sol


// OpenZeppelin Contracts v4.4.1 (utils/cryptography/draft-EIP712.sol)

pragma solidity ^0.8.0;


/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;
    address private immutable _CACHED_THIS;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _CACHED_THIS = address(this);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}




pragma solidity ^0.8.0;


contract whitelistChecker is EIP712 {

    string private constant SIGNING_DOMAIN = "Fpad-Vesting";
    string private constant SIGNATURE_VERSION = "1";

     struct Vesting{
        address userAddress;
        uint256 amount;
        uint256 timestamp;
        bytes signature;
    }
    constructor() EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION){

    }

    function getSigner(Vesting memory whitelist) public view returns(address){
        return _verify(whitelist);
    }

    /// @notice Returns a hash of the given whitelist, prepared using EIP712 typed data hashing rules.

function _hash(Vesting memory whitelist) internal view returns (bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(
                keccak256("Vesting(address userAddress,uint256 amount,uint256 timestamp)"),
                whitelist.userAddress,
                whitelist.amount,
                whitelist.timestamp
            )));
    }
    function _verify(Vesting memory whitelist) internal view returns (address) {
        bytes32 digest = _hash(whitelist);
        return ECDSA.recover(digest, whitelist.signature);
    }

}

interface IBEP20 {
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


pragma solidity ^0.8.12;


contract fantomPadVesting is whitelistChecker{

    IBEP20 public token;
    address public projectOwner;

    address public adminWallet=0xeBA41eAa32841629B1d4F64852d0dadf70b0c665;
    bool private isStart;
    bool private iscollect;
    bool private ischeck;
    uint256 public activeLockDate;
    uint public totalDepositTokens;
    uint public totalAllocatedamount;

    uint256 public vestingEndTime ;
    
    mapping(address =>mapping(uint=>bool)) private usedNonce;
   

    uint256 day ;

    event TokenWithdraw(address indexed buyer, uint256 value);
      event RecoverToken(address indexed token, uint256 indexed amount);

    mapping(address => InvestorDetails) public Investors;

    modifier onlyAdmin {
        require(msg.sender==adminWallet, "Caller is not Admin");
        _;
    }
   modifier setDate{
        require(isStart == true,"wait for start date");
        _;
    }
    modifier _iscollect{
        require(iscollect == true,"wait");
        _;
    }
    modifier check{
        require(ischeck==true);
        _;
    }

    modifier onlyOwner{
        require(msg.sender==projectOwner,"Not a ProjectOwner");
        _;
    }



    uint256 public TGEStartDate;
    uint256 public lockEndDate;
    uint256 public totalLinearUnits;
    uint256 public initialPercentage;
    uint256 public intermediaryPercentage;
    uint256 public intermediateTime;
    address public signer=adminWallet;

    uint256 private middleTime;
    uint256 private linearTime;
    receive() external payable {
    }
   
       
      constructor(
      uint256 _totalLinearUnits, 
      uint256 timeBetweenUnits, 
      uint256 linearStartDate ,
      uint256 _startDate,
      address _tokenAddress,
      uint256 _initialPercentage,
      uint256 _intermediatePercentage,
      uint256 _intermediateTime
      
       ) {
        require(_tokenAddress != address(0));
        middleTime =_intermediateTime;
        linearTime  = linearStartDate;
        token = IBEP20(_tokenAddress);
        totalLinearUnits= _totalLinearUnits;
        day=timeBetweenUnits * 1 minutes;
        TGEStartDate=_startDate;
        initialPercentage=_initialPercentage;
        intermediaryPercentage=_intermediatePercentage;
        intermediateTime=_startDate  + middleTime * 1 minutes ;
        lockEndDate=intermediateTime + linearTime * 1 minutes;
        isStart=true;
        projectOwner=msg.sender;
        vestingEndTime = lockEndDate + timeBetweenUnits * 1 minutes;
    }
    
    
    /* Withdraw the contract's BNB balance to owner wallet*/
    function extractBNB() public onlyAdmin {
        payable(adminWallet).transfer(address(this).balance);
    }

    function getInvestorDetails(address _addr) public view returns(InvestorDetails memory){
        return Investors[_addr];
    }

    
    function getContractTokenBalance() public view returns(uint256) {
        return token.balanceOf(address(this));
    }

    function setSigner(address _addr) public onlyAdmin{
        signer=_addr;
    }
    function remainningTokens() external view returns(uint){
        return totalDepositTokens-totalAllocatedamount;
    }
    
    struct Investor {
        address account;
        uint256 amount;
    }

    struct InvestorDetails {
        uint256 totalBalance;
        uint256 timeDifference;
        uint256 lastVestedTime;
        uint256 reminingUnitsToVest;
        uint256 tokensPerUnit;
        uint256 vestingBalance;
        uint256 initialAmount;
        uint256 nextAmount;
        bool isInitialAmountClaimed;
    }

  
    function addInvestorDetails(Investor[] memory investorArray,Vesting memory _vesting) public {
        for(uint256 i = 0; i < investorArray.length; i++) {
            require(msg.sender== _vesting.userAddress,"Not a User");  
            require(!usedNonce[msg.sender][_vesting.timestamp],"Nonce : Invalid Nonce");
            require (getSigner(_vesting) == signer,'!Signer');   
            usedNonce[msg.sender][_vesting.timestamp]=true;
            InvestorDetails memory investor;
            investor.totalBalance = (investorArray[i].amount)*(10 ** 18);
            investor.vestingBalance = investor.totalBalance;
                investor.reminingUnitsToVest =totalLinearUnits;
                investor.initialAmount = (investor.totalBalance)*(initialPercentage)/100;
                investor.nextAmount = (investor.totalBalance)*(intermediaryPercentage)/100;
                investor.tokensPerUnit = ((investor.totalBalance) - (investor.initialAmount) -(investor.nextAmount))/totalLinearUnits;
            Investors[investorArray[i].account] = investor; 
            totalAllocatedamount+=investor.totalBalance;
        }
    }

    function withdrawTokens() public  setDate {
        require(isStart= true,"wait for start date");

        if(Investors[msg.sender].isInitialAmountClaimed) {
            require(block.timestamp>=lockEndDate,"wait until lock period com");
            activeLockDate = lockEndDate ;
        
            /* Time difference to calculate the interval between now and last vested time. */
            uint256 timeDifference;
            if(Investors[msg.sender].lastVestedTime == 0) {
                require(activeLockDate > 0, "Active lockdate was zero");
                timeDifference = (block.timestamp) - (activeLockDate);
            } else {
                timeDifference = block.timestamp  - (Investors[msg.sender].lastVestedTime);
            }
              
            uint256 numberOfUnitsCanBeVested = timeDifference /day;
            
            /* Remining units to vest should be greater than 0 */
            require(Investors[msg.sender].reminingUnitsToVest > 0, "All units vested!");
            
            /* Number of units can be vested should be more than 0 */
            require(numberOfUnitsCanBeVested > 0, "Please wait till next vesting period!");

            if(numberOfUnitsCanBeVested >= Investors[msg.sender].reminingUnitsToVest) {
                numberOfUnitsCanBeVested = Investors[msg.sender].reminingUnitsToVest;
            }
            
            /*
                1. Calculate number of tokens to transfer
                2. Update the investor details
                3. Transfer the tokens to the wallet
            */
            uint256 tokenToTransfer = numberOfUnitsCanBeVested * Investors[msg.sender].tokensPerUnit;
            uint256 reminingUnits = Investors[msg.sender].reminingUnitsToVest;
            uint256 balance = Investors[msg.sender].vestingBalance;
            Investors[msg.sender].reminingUnitsToVest -= numberOfUnitsCanBeVested;
            Investors[msg.sender].vestingBalance -= numberOfUnitsCanBeVested * Investors[msg.sender].tokensPerUnit;
            Investors[msg.sender].lastVestedTime = block.timestamp;
            if(numberOfUnitsCanBeVested == reminingUnits) { 
                token.transfer(msg.sender, balance);
                emit TokenWithdraw(msg.sender, balance);
            } else {
                token.transfer(msg.sender, tokenToTransfer);
                emit TokenWithdraw(msg.sender, tokenToTransfer);
            } 
        }
        else {
           if(block.timestamp> intermediateTime){
               if(iscollect==true){
                 Investors[msg.sender].vestingBalance -= Investors[msg.sender].nextAmount;
            Investors[msg.sender].isInitialAmountClaimed = true;
            uint256 amount = Investors[msg.sender].nextAmount;
            token.transfer(msg.sender, amount);
            emit TokenWithdraw(msg.sender, amount);
               }else{
            Investors[msg.sender].vestingBalance -= Investors[msg.sender].nextAmount + Investors[msg.sender].initialAmount ;
            Investors[msg.sender].isInitialAmountClaimed = true;
            uint256 amount = Investors[msg.sender].nextAmount +Investors[msg.sender].initialAmount ;
            token.transfer(msg.sender, amount);
            emit TokenWithdraw(msg.sender, amount); 
          }
           }
                else{
            require(!Investors[msg.sender].isInitialAmountClaimed, "Amount already withdrawn!");
            require(block.timestamp > TGEStartDate," Wait Until the Start Date");
            require(Investors[msg.sender].initialAmount >0,"wait for next vest time ");
            iscollect=true;
            uint256 amount = Investors[msg.sender].initialAmount;
            Investors[msg.sender].vestingBalance -= Investors[msg.sender].initialAmount;
            Investors[msg.sender].initialAmount = 0 ; 
            token.transfer(msg.sender, amount);
            emit TokenWithdraw(msg.sender, amount);
                }
                }
        }
   

        function depositToken(uint256 amount) public  onlyOwner{
            token.transferFrom(msg.sender, address(this), amount);
                      totalDepositTokens+=amount;

        }

        function recoverTokens(address _token,address _userAddress, uint256 amount) public onlyAdmin {
            IBEP20(_token).transfer(_userAddress, amount);
            emit RecoverToken(_token, amount);
        }
        function setAdmin(address _addr) external onlyAdmin{
            adminWallet =_addr;
        }

         function getAvailableBalance(address _addr) public view returns(uint256,uint256 ,uint256){
            if(Investors[_addr].isInitialAmountClaimed){
                uint256 lockDate =lockEndDate;
            uint256 hello= day;
            uint256 timeDifference;
            if(Investors[_addr].lastVestedTime == 0) {
                if(block.timestamp >vestingEndTime)return((Investors[_addr].reminingUnitsToVest) *Investors[_addr].tokensPerUnit,0,0);
                if(block.timestamp<lockDate) return(0,0,0);
            if(lockDate + day> 0)return (((block.timestamp-lockEndDate)/day) *Investors[_addr].tokensPerUnit,0,0);//, "Active lockdate was zero");
            timeDifference = (block.timestamp) -(lockDate);
            }
            else{ 
        timeDifference = (block.timestamp) - (Investors[_addr].lastVestedTime);}
            uint256 numberOfUnitsCanBeVested;
            uint256 tokenToTransfer ;
            numberOfUnitsCanBeVested = (timeDifference)/(hello);
            if(numberOfUnitsCanBeVested >= Investors[_addr].reminingUnitsToVest) {
                numberOfUnitsCanBeVested = Investors[_addr].reminingUnitsToVest;}
            tokenToTransfer = numberOfUnitsCanBeVested * Investors[_addr].tokensPerUnit;
            uint256 reminingUnits = Investors[_addr].reminingUnitsToVest;
            uint256 balance = Investors[_addr].vestingBalance;
                    if(numberOfUnitsCanBeVested == reminingUnits) return(balance,0,0) ;  
                    else return(tokenToTransfer,reminingUnits,balance); }
                else{
                    if(block.timestamp>intermediateTime){
                        if(iscollect) {
                        Investors[_addr].nextAmount==0;
                        return (Investors[_addr].nextAmount,0,0);}
                    else {
                        if(ischeck)return(0,0,0);
                        ischeck==true;
                        return ((Investors[_addr].nextAmount + Investors[_addr].initialAmount),0,0);}
                    } 
                else{  
                    if(block.timestamp <TGEStartDate) {
                        return(0,0,0);}else{
                    iscollect==true;
                    Investors[_addr].initialAmount == 0 ;
            return (Investors[_addr].initialAmount,0,0);}
                }
                
            }
        }

        function setStartDate(uint256 _startDate ) external onlyAdmin{
                TGEStartDate =_startDate;
                intermediateTime=_startDate  + middleTime * 1 minutes ;
                lockEndDate=intermediateTime + linearTime * 1 minutes;
        }

        function setToken(address _token) external onlyAdmin{
            token=IBEP20(_token);
        }

        function setprojectOwner(address _addr) external onlyAdmin{
            require(projectOwner==_addr,"Already this wallet is projectOwner");
            projectOwner=_addr;
        }
    }