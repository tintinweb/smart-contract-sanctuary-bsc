// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/draft-EIP712Upgradeable.sol";
import "./libs/dgg/Auth.sol";
import "./libs/zeppelin/token/BEP20/IBEP20.sol";
import "./libs/dgg/Math.sol";

contract IDO is Auth, EIP712Upgradeable {

  using Math for uint;

  struct Event {
    string name;
    address tokenAddress;
    uint tge; // decimal 3
    uint vestingTime; // seconds
    uint startVestingTime; // seconds
    uint endVestingTime; // seconds
    EventForFreeUser freeUser;
    EventForWhitelistUser whitelistUser;
  }

  struct EventForFreeUser {
    uint allocation;
    uint minBuy;
    uint maxBuy;
    uint price; // decimal 3
    uint totalAmountBought;
    uint totalAmountClaimed;
  }

  struct EventForWhitelistUser {
    uint allocation;
    uint totalAmountBought;
    uint totalAmountClaimed;
  }

  struct Buyer {
    uint allocated;
    FreeBuyer freeBuyer;
    WhitelistBuyer whitelistBuyer;
    uint lastClaimedTime;
    uint totalClaimed;
    uint claimAmountPerSeconds;
  }

  struct FreeBuyer {
    uint allocated;
    uint price;
    uint boughtAtBlock;
  }

  struct WhitelistBuyer {
    uint allocated;
    uint price;
    uint boughtAtBlock;
  }

  uint public eventIndex;
  uint constant public oneHundredPercentInDecimal3 = 100000;
  uint constant public priceDecimal3 = 1000;

  address public fundAdmin;

  IBEP20 public busdToken;
  IBEP20 public usdtToken;

  mapping(uint => Event) public events;
  mapping(address => mapping(uint => Buyer)) public buyers;

  enum USDCurrency {
    busd,
    usdt
  }

  event EventCreated(string name, uint indexed eventId, address indexed tokenAddress, uint tgePercentage, uint vestingTime, uint whitelistAllocation, uint timestamp);
  event EventNameUpdated(uint indexed eventId, string name, uint timestamp);
  event EventTokenAddressUpdated(uint indexed eventId, address indexed tokenAddress, uint timestamp);
  event EventTGEPercentageUpdated(uint indexed eventId, uint tgePercentage, uint timestamp);
  event EventVestingTimeUpdated(uint indexed eventId, uint vestingTime, uint timestamp);
  event EventWhitelistUserAllocationUpdated(uint indexed eventId, uint allocaion, uint timestamp);
  event EventForFreeUserUpdated(uint indexed eventId, uint allocation, uint minBuy, uint maxBuy, uint price, uint timestamp);
  event EventFreeUserAllocationUpdated(uint indexed eventId, uint allocation, uint timestamp);
  event EventFreeUserMinBuyAndMaxBuyUpdated(uint indexed eventId, uint minBuy, uint maxBuy, uint timestamp);
  event EventFreeUserPriceUpdated(uint indexed eventId, uint price, uint timestamp);
  event VestingStarted(uint indexed eventId, uint timestamp);
  event FreeBought(uint indexed eventId, uint amount, uint price, USDCurrency usdCurrency, uint timestamp);
  event WhitelistBought(uint indexed eventId, uint amount, uint price, USDCurrency usdCurrency, uint timestamp);
  event Claimed(uint indexed eventId, address indexed user, uint amount, uint timestamp);

  modifier eventExist(uint _eventId) {
    require(events[_eventId].tokenAddress != address(0), "IDO: invalid eventId.");
    _;
  }

  modifier notStartVesting(uint _eventId) {
    require(events[_eventId].tokenAddress != address(0), "IDO: invalid eventId.");
    require(events[_eventId].startVestingTime == 0, "IDO: can't update data.");
    _;
  }

  // ------------------------

  function initializeAtIDO(
    address _mainAdmin,
    address _fundAdmin,
    address _busdTokenAddress,
    address _usdtTokenAddress,
    string memory _name,
    string memory _version
  ) virtual public initializer {
    __EIP712_init(_name, _version);
    Auth.initialize(_mainAdmin);
    eventIndex = 1;
    fundAdmin = _fundAdmin;
    busdToken = IBEP20(_busdTokenAddress);
    usdtToken = IBEP20(_usdtTokenAddress);
  }

  // Admin functions

  function createEvent(string calldata _name, address _tokenAddress, uint _tgePercentage, uint _vestingTime, uint _whitelistAllocation) external onlyMainAdmin {
    require(_tokenAddress != address(0), "IDO: invalid address.");
    require(_tgePercentage > 0 && _tgePercentage <= oneHundredPercentInDecimal3, "IDO: tge percentage must be great than 0 and less than or equal 100000.");
    require(_vestingTime > 0, "IDO: vesting time must be great than 0.");

    Event storage eventDetail = events[eventIndex];
    eventDetail.name = _name;
    eventDetail.tokenAddress = _tokenAddress;
    eventDetail.tge = _tgePercentage;
    eventDetail.vestingTime = _vestingTime;
    eventDetail.whitelistUser.allocation = _whitelistAllocation;

    emit EventCreated(_name, eventIndex, _tokenAddress, _tgePercentage, _vestingTime, _whitelistAllocation, block.timestamp);
    eventIndex++;
  }

  function updateEventForFreeUser(uint _eventId, uint _allocation, uint _minBuy, uint _maxBuy, uint _price) external onlyMainAdmin eventExist(_eventId) {
    Event storage eventDetail = events[_eventId];

    require(_allocation > 0, "IDO: allocation must be great than 0.");
    require(_minBuy > 0 && _minBuy <= _maxBuy, "IDO: min buy must be great than 0 and less than or equal max buy.");
    require(_price > 0, "IDO: price must be great than 0.");

    eventDetail.freeUser = EventForFreeUser(_allocation, _minBuy, _maxBuy, _price, 0, 0);
    emit EventForFreeUserUpdated(_eventId, _allocation, _minBuy, _maxBuy, _price, block.timestamp);
  }

  function updateEventName(uint _eventId, string calldata _name) external onlyMainAdmin notStartVesting(_eventId) {
    events[_eventId].name = _name;

    emit EventNameUpdated(_eventId, _name, block.timestamp);
  }

  function updateEventTokenAddress(uint _eventId, address _tokenAddress) external onlyMainAdmin notStartVesting(_eventId) {
    require(_tokenAddress != address(0), "IDO: invalid address.");
    events[_eventId].tokenAddress = _tokenAddress;

    emit EventTokenAddressUpdated(_eventId, _tokenAddress, block.timestamp);
  }

  function updateEventTGEPercentage(uint _eventId, uint _percentage) external onlyMainAdmin notStartVesting(_eventId) {
    require(_percentage > 0 && _percentage <= oneHundredPercentInDecimal3, "IDO: percentage must be great than 0 and less than or equal 100000.");
    events[_eventId].tge = _percentage;

    emit EventTGEPercentageUpdated(_eventId, _percentage, block.timestamp);
  }

  function updateEventVestingTime(uint _eventId, uint _vestingTime) external onlyMainAdmin notStartVesting(_eventId) {
    require(_vestingTime > 0, "IDO: vesting time must be great than 0.");
    events[_eventId].vestingTime = _vestingTime;

    emit EventVestingTimeUpdated(_eventId, _vestingTime, block.timestamp);
  }

  function updateEventWhitelistUserAllocation(uint _eventId, uint _allocation) external onlyMainAdmin notStartVesting(_eventId) {
    require(_allocation > 0, "IDO: allocation must be great than 0.");
    events[_eventId].whitelistUser.allocation = _allocation;

    emit EventWhitelistUserAllocationUpdated(_eventId, _allocation, block.timestamp);
  }

  function updateEventFreeUserAllocation(uint _eventId, uint _allocation) external onlyMainAdmin notStartVesting(_eventId) {
    require(_allocation > 0, "IDO: allocation must be great than 0.");

    events[_eventId].freeUser.allocation = _allocation;

    emit EventFreeUserAllocationUpdated(_eventId, _allocation, block.timestamp);
  }

  function updateEventFreeUserMinBuyAndMaxBuy(uint _eventId, uint _minBuy, uint _maxBuy) external onlyMainAdmin notStartVesting(_eventId) {
    require(_minBuy > 0 && _minBuy <= _maxBuy, "IDO: min buy must be great than 0 and less than or equal max buy.");

    events[_eventId].freeUser.minBuy = _minBuy;
    events[_eventId].freeUser.maxBuy = _maxBuy;

    emit EventFreeUserMinBuyAndMaxBuyUpdated(_eventId, _minBuy, _maxBuy, block.timestamp);
  }

  function updateEventFreeUserPrice(uint _eventId, uint _price) external onlyMainAdmin notStartVesting(_eventId) {
    require(_price > 0, "IDO: price must be great than 0.");

    events[_eventId].freeUser.price = _price;

    emit EventFreeUserPriceUpdated(_eventId, _price, block.timestamp);
  }

  function startVesting(uint _eventId) external onlyMainAdmin eventExist(_eventId) {
    Event storage eventDetail = events[_eventId];
    IBEP20 token = IBEP20(eventDetail.tokenAddress);
    require(eventDetail.startVestingTime == 0, "IDO: vesting had started.");
    uint totalAmountNeedToStartVesting = eventDetail.whitelistUser.allocation + eventDetail.freeUser.allocation - eventDetail.freeUser.totalAmountClaimed - eventDetail.whitelistUser.totalAmountClaimed;
    require(
      token.balanceOf(address(this)) >= totalAmountNeedToStartVesting,
      "IDO: Insufficient balance."
    );

    eventDetail.startVestingTime = block.timestamp;
    eventDetail.endVestingTime = block.timestamp + eventDetail.vestingTime;

    emit VestingStarted(_eventId, block.timestamp);
  }

  function setUsdToken(address _busd, address _usdt) external onlyMainAdmin {
    busdToken = IBEP20(_busd);
    usdtToken = IBEP20(_usdt);
  }

  // User functions

  function freeBuy(uint _eventId, uint _amount, USDCurrency _usdCurrency) external eventExist(_eventId) {
    Event storage eventDetail = events[_eventId];

    require(eventDetail.startVestingTime > 0, "IDO: please wait more time.");
    require(_amount >= eventDetail.freeUser.minBuy, "IDO: amount must be great than or equal min buy.");
    require(_amount <= eventDetail.freeUser.maxBuy, "IDO: amount must be less than or equal max buy.");
    require(eventDetail.freeUser.totalAmountBought + _amount <= eventDetail.freeUser.allocation, "IDO: invalid amount.");
    uint usdAmount = eventDetail.freeUser.price * _amount / 1000;

    _takeFund(_usdCurrency, usdAmount);

    Buyer storage buyer = buyers[msg.sender][_eventId];
    buyer.freeBuyer.boughtAtBlock = block.number;
    buyer.freeBuyer.price = eventDetail.freeUser.price;
    buyer.freeBuyer.allocated += _amount;
    buyer.allocated += _amount;
    buyer.claimAmountPerSeconds = _calculateClaimAmountPerSeconds(eventDetail, buyer);

    eventDetail.freeUser.totalAmountBought += _amount;

    emit FreeBought(_eventId, _amount, eventDetail.freeUser.price, _usdCurrency, block.timestamp);
  }

  function whitelistBuy(bytes calldata _signature, uint _eventId, uint _totalToken, uint _price, USDCurrency _usdCurrency) external eventExist(_eventId) {
    Event storage eventDetail = events[_eventId];
    Buyer storage buyer = buyers[msg.sender][_eventId];

    require(eventDetail.startVestingTime > 0, "IDO: please wait more time.");
    require(buyer.whitelistBuyer.boughtAtBlock == 0, "IDO: you bought.");
    _validateWhitelistBuy(_signature, _eventId, _totalToken, _price);
    require(eventDetail.whitelistUser.totalAmountBought + _totalToken <= eventDetail.whitelistUser.allocation, "IDO: invalid allocation.");
    uint usdAmount = _price * _totalToken / 1000;

    _takeFund(_usdCurrency, usdAmount);

    buyer.whitelistBuyer.boughtAtBlock = block.number;
    buyer.whitelistBuyer.price = _price;
    buyer.whitelistBuyer.allocated = _totalToken;
    buyer.allocated += _totalToken;
    buyer.claimAmountPerSeconds = _calculateClaimAmountPerSeconds(eventDetail, buyer);

    eventDetail.whitelistUser.totalAmountBought += _totalToken;

    emit WhitelistBought(_eventId, _totalToken, _price, _usdCurrency, block.timestamp);
  }

  function claim(uint _eventId) external eventExist(_eventId) {
    Event storage eventDetail = events[_eventId];
    Buyer storage buyer = buyers[msg.sender][_eventId];
    require(eventDetail.startVestingTime > 0, "IDO: please wait more time.");
    require(buyer.lastClaimedTime < eventDetail.endVestingTime, "IDO: you had complete claimed.");

    (uint amount, uint lastClaimedTime) = _calculateAmountClaim(eventDetail, buyer);

    buyer.lastClaimedTime = lastClaimedTime;

    require(amount > 0, "IDO: you not have reward.");

    buyer.totalClaimed += amount;

    _takeClaim(IBEP20(eventDetail.tokenAddress), amount);

    emit Claimed(_eventId, msg.sender, amount, block.timestamp);
  }

  // Private function

  function _takeFund(USDCurrency _usdCurrency, uint _amount) private {
    IBEP20 usdToken = _usdCurrency == USDCurrency.busd ? busdToken : usdtToken;

    require(usdToken.allowance(msg.sender, address(this)) >= _amount, "IDO: please approve usd token first.");
    require(usdToken.balanceOf(msg.sender) >= _amount, "IDO: please fund your account.");
    require(usdToken.transferFrom(msg.sender, address(this), _amount), "IDO: transfer usd token failed.");
    require(usdToken.transfer(fundAdmin, _amount), "IDO: transfer usd token failed.");
  }

  function _validateWhitelistBuy(
    bytes memory _signature,
    uint256 eventId,
    uint256 _totalToken,
    uint256 _price
  ) private view returns (address) {
    bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
      keccak256("WhitelistBuy(address user,uint256 eventId,uint256 totalToken,uint256 price)"),
      msg.sender,
      eventId,
      _totalToken,
      _price
    )));

    address signer = ECDSAUpgradeable.recover(digest, _signature);
    require(signer == mainAdmin, "MessageVerifier: invalid signature.");
    require(signer != address(0), "ECDSAUpgradeable: invalid signature.");
    return signer;
  }

  function _calculateClaimAmountPerSeconds(Event memory _event, Buyer memory _buyer) private pure returns (uint) {
    uint amount = _buyer.allocated * (oneHundredPercentInDecimal3 - _event.tge) / oneHundredPercentInDecimal3 / _event.vestingTime;

    return amount;
  }

  function _calculateAmountClaim(Event memory _event, Buyer memory _buyer) private view returns (uint, uint) {
    uint amount = 0;
    uint lastClaimedTime = 0;

    if (_buyer.lastClaimedTime == 0) {
      amount = _buyer.allocated * _event.tge / oneHundredPercentInDecimal3;
      lastClaimedTime = _event.startVestingTime;
    } else {
      uint claimableSeconds = block.timestamp <= _event.endVestingTime
      ? block.timestamp - _buyer.lastClaimedTime
      : _event.endVestingTime - _buyer.lastClaimedTime;

      amount = claimableSeconds * _buyer.claimAmountPerSeconds;
      lastClaimedTime = block.timestamp;
    }

    return (amount, lastClaimedTime);
  }

  function _takeClaim(IBEP20 _usdToken, uint _amount) private {
    require(_usdToken.balanceOf(address(this)) >= _amount, "IDO: insufficient balance.");
    require(_usdToken.transfer(msg.sender, _amount), "IDO: transfer usd token failed.");
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSAUpgradeable {
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
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
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
            return recover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return recover(hash, r, vs);
        } else {
            revert("ECDSA: invalid signature length");
        }
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return recover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`, `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        require(
            uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
            "ECDSA: invalid signature 's' value"
        );
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ECDSAUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

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
abstract contract EIP712Upgradeable is Initializable {
    /* solhint-disable var-name-mixedcase */
    bytes32 private _HASHED_NAME;
    bytes32 private _HASHED_VERSION;
    bytes32 private constant _TYPE_HASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

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
    function __EIP712_init(string memory name, string memory version) internal initializer {
        __EIP712_init_unchained(name, version);
    }

    function __EIP712_init_unchained(string memory name, string memory version) internal initializer {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        return _buildDomainSeparator(_TYPE_HASH, _EIP712NameHash(), _EIP712VersionHash());
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
        return ECDSAUpgradeable.toTypedDataHash(_domainSeparatorV4(), structHash);
    }

    /**
     * @dev The hash of the name parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712NameHash() internal virtual view returns (bytes32) {
        return _HASHED_NAME;
    }

    /**
     * @dev The hash of the version parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712VersionHash() internal virtual view returns (bytes32) {
        return _HASHED_VERSION;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

abstract contract Auth is Initializable {

  address public mainAdmin;
  address public contractAdmin;

  event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);
  event ContractAdminUpdated(address indexed _newOwner);

  function initialize(address _mainAdmin) virtual public initializer {
    mainAdmin = _mainAdmin;
    contractAdmin = _mainAdmin;
  }

  modifier onlyMainAdmin() {
    require(_isMainAdmin(), "onlyMainAdmin");
    _;
  }

  modifier onlyContractAdmin() {
    require(_isContractAdmin() || _isMainAdmin(), "onlyContractAdmin");
    _;
  }

  function transferOwnership(address _newOwner) onlyMainAdmin external {
    require(_newOwner != address(0x0));
    mainAdmin = _newOwner;
    emit OwnershipTransferred(msg.sender, _newOwner);
  }

  function updateContractAdmin(address _newAdmin) onlyMainAdmin external {
    require(_newAdmin != address(0x0));
    contractAdmin = _newAdmin;
    emit ContractAdminUpdated(_newAdmin);
  }

  function _isMainAdmin() public view returns (bool) {
    return msg.sender == mainAdmin;
  }

  function _isContractAdmin() public view returns (bool) {
    return msg.sender == contractAdmin;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
interface IBEP20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

library Math {

  function add(uint a, uint b) internal pure returns (uint) {
    unchecked {
      uint256 c = a + b;
      require(c >= a, "SafeMath: addition overflow");

      return c;
    }
  }

  function sub(uint a, uint b) internal pure returns (uint) {
    unchecked {
      require(b <= a, "Math: sub underflow");
      uint256 c = a - b;

      return c;
    }
  }

  function mul(uint a, uint b) internal pure returns (uint) {
    unchecked {
      if (a == 0) {
        return 0;
      }

      uint256 c = a * b;
      require(c / a == b, "SafeMath: multiplication overflow");

      return c;
    }
  }

  function div(uint a, uint b) internal pure returns (uint) {
    unchecked {
      require(b > 0, "SafeMath: division by zero");
      uint256 c = a / b;

      return c;
    }
  }

  function genRandomNumber(string calldata _seed, uint _dexRandomSeed) internal view returns (uint8) {
    return genRandomNumberInRange(_seed, _dexRandomSeed, 0, 99);
  }

  function genRandomNumberInRange(string calldata _seed, uint _dexRandomSeed, uint _from, uint _to) internal view returns (uint8) {
    require(_to > _from, 'Math: Invalid range');
    uint randomNumber = uint(
      keccak256(
        abi.encodePacked(
          keccak256(
            abi.encodePacked(
              block.number,
              block.difficulty,
              block.timestamp,
              msg.sender,
              _seed,
              _dexRandomSeed
            )
          )
        )
      )
    ) % (_to - _from + 1);
    return uint8(randomNumber + _from);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}