/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/// @notice The signer of the permit doesn't match
error PermitSignatureInvalid(address recovered, address expected, uint256 amount);
/// @notice the block.timestamp has passed the deadline
error PermitExpired(address owner, address spender, uint256 amount, uint256 deadline);
error PermitInvalidSignatureSValue();
error PermitInvalidSignatureVValue();

/// @title Using EIP-2612 Permits
/// @author originally written by soliditylabs with modifications made by [email protected]
/// @dev reference implementation can be found here https://github.com/soliditylabs/ERC20-Permit/blob/main/contracts/ERC20Permit.sol.
///      This contract contains the implementation and lacks storage. Use this with existing upgradeable contracts.
abstract contract UsingPermit  {

    /// @notice initialize the permit function internally
    function _initializePermits() internal {
        _updateDomainSeparator();
    }

    /// @notice get the nonce for the given account
    /// @param account_ the account to get the nonce for
    /// @return the nonce
    function nonces(address account_) public view returns (uint256) {
        return _getNoncesStorage()[account_];
    }

    /// @notice the domain separator for a chain
    /// @param chainId_ the chain id to get the domain separator for
    function domainSeparators(uint256 chainId_) public view returns (bytes32) {
        return _getDomainSeparatorsStorage()[chainId_];
    }

    /// @notice check if the permit is valid
    function _permit(address owner_, address spender_, uint256 amount_, uint256 deadline_, uint8 v_, bytes32 r_, bytes32 s_) internal virtual {
        if(block.timestamp > deadline_) revert PermitExpired(owner_, spender_, amount_, deadline_);
        bytes32 hashStruct;
        uint256 nonce = _getNoncesStorage()[owner_]++;
        assembly {
            let memPtr := mload(64)
            mstore(memPtr, 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9)
            mstore(add(memPtr, 32), owner_)
            mstore(add(memPtr, 64), spender_)
            mstore(add(memPtr, 96), amount_)
            mstore(add(memPtr, 128),nonce)
            mstore(add(memPtr, 160), deadline_)
            hashStruct := keccak256(memPtr, 192)
        }
        bytes32 eip712DomainHash = _domainSeparator();
        bytes32 hash;
        assembly {
            let memPtr := mload(64)

            mstore(memPtr, 0x1901000000000000000000000000000000000000000000000000000000000000)
            mstore(add(memPtr, 2), eip712DomainHash)
            mstore(add(memPtr, 34), hashStruct)

            hash := keccak256(memPtr, 66)
        }
        address signer = _recover(hash, v_, r_, s_);
        if (signer != owner_) revert PermitSignatureInvalid(signer, owner_, amount_);
    }

    /// @notice add a new domain separator to the mapping
    /// @return the domain separator hash
    function _updateDomainSeparator() internal returns (bytes32) {
        uint256 chainID = block.chainid;
        bytes32 newDomainSeparator = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes(_getNameStorage())), // ERC-20 Name
                keccak256(bytes("1")),    // Version
                chainID,
                address(this)
            )
        );
        _getDomainSeparatorsStorage()[chainID] = newDomainSeparator;
        return newDomainSeparator;
    }

    /// @notice get the domain separator and add it to the mapping if it doesn't exist
    /// @return the new or cached domain separator
    function _domainSeparator() private returns (bytes32) {
        bytes32 domainSeparator = _getDomainSeparatorsStorage()[block.chainid];

        if (domainSeparator != 0x00) {
            return domainSeparator;
        }

        return _updateDomainSeparator();
    }

    /// @notice recover the signer address from the signature
    function _recover(
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
        if (
            uint256(s) >
            0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0
        ) {
            revert PermitInvalidSignatureSValue();
        }

        if (v != 27 && v != 28) {
            revert PermitInvalidSignatureVValue();
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) revert PermitSignatureInvalid(signer, address(0), 0);
        return signer;
    }

    /// @notice the name used to compute the domain separator
    function _getNameStorage() internal view virtual returns (string memory);
    /// @notice get the nonce storage
    function _getNoncesStorage() internal view virtual returns (mapping(address => uint256) storage);
    /// @notice get the domain separator storage
    function _getDomainSeparatorsStorage() internal view virtual returns (mapping(uint256 => bytes32) storage);

}

/// @title bit library
/// @notice old school bit bits
library bits {

    /// @notice check if only a specific bit is set
    /// @param slot the bit storage slot
    /// @param bit the bit to be checked
    /// @return return true if the bit is set
    function only(uint slot, uint bit) internal pure returns (bool) {
        return slot == bit;
    }

    /// @notice checks if all bits ares set and cleared
    function all(uint slot, uint set_, uint cleared_) internal pure returns (bool) {
        return all(slot, set_) && !all(slot, cleared_);
    }

    /// @notice checks if any of the bits_ are set
    /// @param slot the bit storage to slot
    /// @param bits_ the or list of bits_ to slot
    /// @return true of any of the bits_ are set otherwise false
    function any(uint slot, uint bits_) internal pure returns(bool) {
        return (slot & bits_) != 0;
    }

    /// @notice checks if any of the bits are set and all of the bits are cleared
    function check(uint slot, uint set_, uint cleared_) internal pure returns(bool) {
        return slot != 0 ?  ((set_ == 0 || any(slot, set_)) && (cleared_ == 0 || !all(slot, cleared_))) : (set_ == 0 || any(slot, set_));
    }

    /// @notice checks if all of the bits_ are set
    /// @param slot the bit storage
    /// @param bits_ the list of bits_ required
    /// @return true if all of the bits_ are set in the sloted variable
    function all(uint slot, uint bits_) internal pure returns(bool) {
        return (slot & bits_) == bits_;
    }

    /// @notice set bits_ in this storage slot
    /// @param slot the storage slot to set
    /// @param bits_ the list of bits_ to be set
    /// @return a new uint with bits_ set
    /// @dev bits_ that are already set are not cleared
    function set(uint slot, uint bits_) internal pure returns(uint) {
        return slot | bits_;
    }

    function toggle(uint slot, uint bits_) internal pure returns (uint) {
        return slot ^ bits_;
    }

    function isClear(uint slot, uint bits_) internal pure returns(bool) {
        return !all(slot, bits_);
    }

    /// @notice clear bits_ in the storage slot
    /// @param slot the bit storage variable
    /// @param bits_ the list of bits_ to clear
    /// @return a new uint with bits_ cleared
    function clear(uint slot, uint bits_) internal pure returns(uint) {
        return slot & ~(bits_);
    }

    /// @notice clear & set bits_ in the storage slot
    /// @param slot the bit storage variable
    /// @param bits_ the list of bits_ to clear
    /// @return a new uint with bits_ cleared and set
    function reset(uint slot, uint bits_) internal pure returns(uint) {
        slot = clear(slot, type(uint).max);
        return set(slot, bits_);
    }

}

/// @notice Emitted when a check for
error FlagsInvalid(address account, uint256 set, uint256 cleared);

/// @title UsingFlags contract
/// @notice Use this contract to implement unique permissions or attributes
/// @dev you have up to 255 flags you can use. Be careful not to use the same flag more than once. Generally a preferred approach is using
///      pure virtual functions to implement the flags in the derived contract.
abstract contract UsingFlags {
    /// @notice a helper library to check if a flag is set
    using bits for uint256;
    event FlagsChanged(address indexed, uint256, uint256);

    /// @notice checks of the required flags are set or cleared
    /// @param account_ the account to check
    /// @param set_ the flags that must be set
    /// @param cleared_ the flags that must be cleared
    modifier requires(address account_, uint256 set_, uint256 cleared_) {
        if (!(_getFlags(account_).check(set_, cleared_))) revert FlagsInvalid(account_, set_, cleared_);
        _;
    }

    /// @notice getFlags returns the currently set flags
    /// @param account_ the account to check
    function getFlags(address account_) public view returns (uint256) {
        return _getFlags(account_);
    }

    function _getFlags(address account_) internal view returns (uint256) {
        return _getFlagStorage()[uint256(uint160(account_))];
    }

    /// @notice set and clear flags for the given account
    /// @param account_ the account to modify flags for
    /// @param set_ the flags to set
    /// @param clear_ the flags to clear
    function _setFlags(address account_, uint256 set_, uint256 clear_) internal virtual {
        uint256 before = _getFlags(account_);
        _getFlagStorage()[uint256(uint160(account_))] = _getFlags(account_).set(set_).clear(clear_);
        emit FlagsChanged(account_, before, _getFlags(account_));
    }

    /// @notice get the storage for flags
    function _getFlagStorage() internal view virtual returns (mapping(uint256 => uint256) storage);

}

abstract contract UsingDefaultFlags is UsingFlags {
    using bits for uint256;

    /// @notice the value of the initializer flag
    function _INITIALIZED_FLAG() internal pure virtual returns (uint256) {
        return 1 << 255;
    }

    function _TRANSFER_DISABLED_FLAG() internal pure virtual returns (uint256) {
        return _INITIALIZED_FLAG() >> 1;
    }

    function _PROVIDER_FLAG() internal pure virtual returns (uint256) {
        return _TRANSFER_DISABLED_FLAG() >> 1;
    }

    function _SERVICE_FLAG() internal pure virtual returns (uint256) {
        return _PROVIDER_FLAG() >> 1;
    }

    function _NETWORK_FLAG() internal pure virtual returns (uint256) {
        return _SERVICE_FLAG() >> 1;
    }

    function _SERVICE_EXEMPT_FLAG() internal pure virtual returns(uint256) {
        return _NETWORK_FLAG() >> 1;
    }

    function _PROCESSING_FLAG() internal pure virtual returns (uint256) {
        return _SERVICE_EXEMPT_FLAG() >> 1;
    }

    function _ADMIN_FLAG() internal virtual pure returns (uint256) {
        return _PROCESSING_FLAG() >> 1;
    }

    function _BLOCKED_FLAG() internal pure virtual returns (uint256) {
        return _ADMIN_FLAG() >> 1;
    }

    function _ROUTER_FLAG() internal pure virtual returns (uint256) {
        return _BLOCKED_FLAG() >> 1;
    }

    function _SERVICE_FEE_EXEMPT_FLAG() internal pure virtual returns (uint256) {
        return _ROUTER_FLAG() >> 1;
    }

    function _SERVICES_DISABLED_FLAG() internal pure virtual returns (uint256) {
        return _SERVICE_FEE_EXEMPT_FLAG() >> 1;
    }

    function _FEE_EXEMPT_FLAG() internal pure virtual returns (uint256) {
        return _SERVICES_DISABLED_FLAG() >> 1;
    }

    function _isFeeExempt(address account_) internal view virtual returns (bool) {
        return _getFlags(account_).all(_FEE_EXEMPT_FLAG());
    }

    function _isServiceFeeExempt(address from_, address to_) internal view virtual returns (bool) {
        return _getFlags(from_).all(_SERVICE_FEE_EXEMPT_FLAG()) || _getFlags(to_).all(_SERVICE_FEE_EXEMPT_FLAG());
    }

    function _isServiceExempt(address from_, address to_) internal view virtual returns (bool) {
        return _getFlags(from_).all(_SERVICE_EXEMPT_FLAG()) || _getFlags(to_).all(_SERVICE_EXEMPT_FLAG());
    }
}

/// @notice the spender isn't authorized to spend this amount
error ERC20AllowanceInsufficient(address account, address spender, uint256 amount);
/// @notice the amount trying being from the account is greater than the account's balance
error ERC20BalanceInsufficient(address account, uint256 amount);

/// @title Using ERC20 an implementation of EIP-20
/// @dev this is purely the implementation and doesn't contain storage it can be used with existing upgradable contracts just map the existing storage.
/// @author [email protected]
abstract contract UsingERC20 is  UsingPermit, UsingFlags, UsingDefaultFlags {

    /// @notice the event emitted after the a transfer
    event Transfer(address indexed from, address indexed to, uint256 value);
    /// @notice the event emitted upon receiving approval
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /// @notice transfer tokens from sender to account
    /// @param to_ the address to transfer to
    /// @param amount_ the amount to transfer
    /// @dev requires the BLOCKED_FLAG() to be unset
    function transfer(address to_, uint256 amount_) public virtual requires(address(this), 0, _TRANSFER_DISABLED_FLAG())  returns (bool) {
        if (amount_ > _getBalancesStorage()[msg.sender]) {
            revert ERC20BalanceInsufficient(msg.sender, amount_);
        }
        _transfer(msg.sender, to_, amount_);
        return true;
    }

    /// @notice checks to see if the spender is approved to spend the given amount and transfer
    /// @param from_ the account to transfer from
    /// @param to_ the account to transfer to
    /// @param amount_ the amount to transfer
    /// @dev requires the _TRANSFER_DISABLED_FLAG to be cleared
    function transferFrom(address from_, address to_, uint256 amount_) external virtual requires(address(this), 0, _TRANSFER_DISABLED_FLAG()) returns (bool) {
        if (amount_ > _getBalancesStorage()[from_]) {
            revert ERC20BalanceInsufficient(from_, amount_);
        }
        uint256 fromAllowance = _getAllowanceStorage()[from_][ msg.sender];
        if (fromAllowance != type(uint256).max) {
            if (_getAllowanceStorage()[from_][msg.sender] < amount_) revert ERC20AllowanceInsufficient(from_, msg.sender, amount_);
            unchecked {
                _getAllowanceStorage()[from_][msg.sender] -= amount_;
            }
        }
        _transfer(from_, to_, amount_);
        return true;
    }

    function transferFromWithPermit(address from_, address to_, uint256 amount_, uint256 deadline_, uint8 v_, bytes32 r_, bytes32 s_) external virtual requires(address(this), 0, _TRANSFER_DISABLED_FLAG()) {
        _permit(from_, msg.sender, amount_, deadline_, v_, r_, s_);
        _transfer(from_, to_, amount_);
    }

    /// @notice the allowance the spender is allowed to spend for an account
    /// @param account_ the account to check
    /// @param spender_ the trusted spender
    /// @return uint256 amount of the account that the spender_ can transfer
    function allowance(address account_, address spender_) public view virtual returns (uint256) {
        return _getAllowanceStorage()[account_][spender_];
    }

    function permit(address account_, address spender_, uint256 amount_, uint256 deadline_, uint8 v_, bytes32 r_, bytes32 s_) public virtual {
        _permit(account_, spender_, amount_, deadline_, v_, r_, s_);
        _getAllowanceStorage()[account_][spender_] = amount_;
    }

    /// @notice returns the total supply of tokens
    function totalSupply() public view virtual returns (uint256) {
        return _getTotalSupplyStorage();
    }

    /// @notice check the balance of the given account
    /// @param account_ the account to check
    /// @return uint256 the balance of the account
    function balanceOf(address account_) external view virtual returns (uint256) {
        return _getBalancesStorage()[account_];
    }

    /// @notice the symbol of the token
    function symbol() public view virtual returns (string memory) {
        return _getSymbolStorage();
    }

    /// @notice the decimals of the token
    function decimals() public view virtual returns (uint8) {
        return _getDecimalStorage();
    }

    /// @notice the name of the token
    function name() public view virtual returns (string memory) {
        return _getNameStorage();
    }

    /// @notice approve the spender to spend the given amount for an account
    /// @param spender_ the account to approve
    /// @param amount_ the amount to approve
    function approve(address spender_, uint256 amount_) public virtual returns (bool) {
        _approve(msg.sender, spender_, amount_);
        return true;
    }

    /// @notice initialize the token
    /// @dev used internally if you use this in a public function be sure to use the initializer
    function _initializeERC20() internal {
        _initializePermits();
    }

    /// @notice approve the spender to spend the given amount for an account
    /// @param spender_ the account to approve
    /// @param amount_ the amount to approve
    function _approve(address sender_, address spender_, uint256 amount_) internal virtual {
        _getAllowanceStorage()[sender_][spender_] = amount_;
        emit Approval(msg.sender, spender_, amount_);
    }

    /// @notice used internally to get the balance of the account
    function _balanceOf(address account_) internal view virtual returns (uint256) {
        return _getBalancesStorage()[account_];
    }

    /// @notice transfer tokens to one account from another
    /// @param from_ the account to transfer from
    /// @param to_ the account to transfer to
    /// @param amount_ the amount to transfer
    /// @dev inherit from this function to implement custom taxation or other logic warning this function does zero checking for underflows and overflows
    function _transfer(address from_, address to_, uint256 amount_) internal virtual returns (bool) {
        unchecked {
            _getBalancesStorage()[from_] -= amount_;
            _getBalancesStorage()[to_] += amount_;
        }
        emit Transfer(from_, to_, amount_);
        return true;
    }

    /// @notice mint tokens and adjust the supply
    /// @param to_ the account to mint to
    /// @param amount_ the amount to mint
    function _mint(address to_, uint256 amount_) internal virtual {
        unchecked {
            _setTotalSupplyStorage(_getTotalSupplyStorage() + amount_);
            _getBalancesStorage()[to_] += amount_;
        }
        emit Transfer(address(0), to_, amount_);
    }

    /// @notice burn tokens and adjust the supply
    /// @param from_ the account to burn from
    /// @param amount_ the amount to burn
    function _burn(address from_, uint amount_) internal virtual {
        if (amount_ > _getBalancesStorage()[from_]) {
            revert ERC20BalanceInsufficient(from_, amount_);
        }
        unchecked {
            _setTotalSupplyStorage(_getTotalSupplyStorage() - amount_);
            _getBalancesStorage()[from_] -= amount_;
        }
        emit Transfer(from_, address(0), amount_);
    }

    /// @notice get the storage for allowance
    /// @return mapping(address => mapping(address => uint256)) allowance storage
    function _getAllowanceStorage() internal view virtual returns (mapping(address => mapping(address => uint256)) storage);
    /// @notice get the storage for balances
    /// @return mapping(address => uint256) balances storage
    function _getBalancesStorage() internal view virtual returns (mapping(address => uint256) storage);
    function _getTotalSupplyStorage() internal view virtual returns (uint256);
    function _setTotalSupplyStorage(uint256 value) internal virtual;
    function _getSymbolStorage() internal view virtual returns (string memory);
    function _getDecimalStorage() internal view virtual returns (uint8);
}

abstract contract UsingPermitWithStorage is UsingPermit {
    /// @notice nonces per account to prevent re-use of permit
    mapping(address => uint256) internal _nonces;
    /// @notice the predefined type hash
    bytes32 public constant TYPE_HASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    /// @notice a mapping of chainId and domain separators
    mapping(uint256 => bytes32) internal _domainSeparators;

    function _initializePermitWithStorage() internal {
        _updateDomainSeparator();
    }

    function _getNoncesStorage() internal view override returns (mapping(address => uint256) storage) {
        return _nonces;
    }

    function _getDomainSeparatorsStorage() internal view override returns (mapping(uint256 => bytes32) storage) {
        return _domainSeparators;
    }

}

/// @title UsingFlagsWithStorage contract
/// @dev use this when creating a new contract
abstract contract UsingFlagsWithStorage is UsingFlags {
    using bits for uint256;

    /// @notice the mapping to store the flags
    mapping(uint256 => uint256) internal _flags;

    function _getFlagStorage() internal view override returns (mapping(uint256 => uint256) storage) {
        return _flags;
    }
}

interface IService {

    function process(address from_, address to_, uint256 amount) external payable returns (uint256);
    function withdraw() external;
    function fee() external view returns (uint24);
    function provider() external view returns (address);
    function providerFee() external view returns (uint24);
}

interface IServiceProvider is IService {

    function removeServices(address[] memory services_) external;
    function addServices(address[] memory services_, uint256[] memory fees_) external;
    function services() external view returns (address[] memory);
}

abstract contract UsingAdmin is UsingFlags, UsingDefaultFlags {

    function _initializeAdmin(address admin_) internal virtual {
        _setFlags(admin_, _ADMIN_FLAG(), 0);
    }

    function setFlags(address account_, uint256 set_, uint256 clear_) external requires(msg.sender, _ADMIN_FLAG(), 0) {
        _setFlags(account_, set_, clear_);
    }

}

abstract contract CPTXFlags is UsingFlags, UsingDefaultFlags, UsingAdmin {
    using bits for uint256;

    function _TRANSFER_LIMIT_DISABLED_FLAG() internal pure virtual returns (uint256) {
        return 1 << 128;
    }

    function _LP_PAIR_FLAG() internal pure virtual returns (uint256) {
        return _TRANSFER_LIMIT_DISABLED_FLAG() >> 1;
    }

    function _REWARD_EXEMPT_FLAG() internal pure virtual returns (uint256) {
        return _LP_PAIR_FLAG() >> 1;
    }

    function _TRANSFER_LIMIT_EXEMPT_FLAG() internal pure virtual returns (uint256) {
        return _REWARD_EXEMPT_FLAG() >> 1;
    }

    function _ACCOUNT_FLAG() internal pure virtual returns (uint256) {
        return _ROUTER_FLAG() >> 1;
    }

    function _isLPPair(address from_, address to_) internal view virtual returns (bool) {
        return _isLPPair(from_) || _isLPPair(to_);
    }

    function _isLPPair(address account_) internal view virtual returns (bool) {
        return _getFlags(account_).check(_LP_PAIR_FLAG(), 0);
    }

    function _isTransferLimitEnabled() internal view virtual returns (bool) {
        return _getFlags(address(this)).check(0, _TRANSFER_LIMIT_DISABLED_FLAG());
    }

    function _isRewardExempt(address account_) internal view virtual returns (bool) {
        return account_ == address(0) ||  _getFlags(account_).check(_REWARD_EXEMPT_FLAG(), 0);
    }

    function _isTransferLimitExempt(address account_) internal view virtual returns (bool) {
        return _isTransferLimitEnabled() && _getFlags(account_).check(_TRANSFER_LIMIT_EXEMPT_FLAG(), 0);
    }

    function _isRouter(address account_) internal view virtual returns (bool) {
        return _getFlags(account_).check(_ROUTER_FLAG(), 0);
    }

    function _checkFlags(address account_, uint set_, uint cleared_) internal view returns (bool) {
        return _getFlags(account_).check(set_, cleared_);
    }

}

contract CPTXFlagsWithStorage is UsingFlagsWithStorage, CPTXFlags {
    using bits for uint256;

}

library dict {
    using dict for Dict;
    using dict for Item;

    struct Item {
        bytes32 key;
        uint value;
    }

    struct Dict {
        Item[] items;
        mapping(bytes32 => uint) indices;
    }

    function set(Item storage keyValue, bytes32 key, uint value) internal {
        (keyValue.key, keyValue.value) = (key, value);
    }

    function set(Item storage keyValue, uint value) internal {
        keyValue.value = value;
    }

    function _set(Dict storage dct, bytes32 key, uint value) private returns (uint index) {
        dct.items.push();
        index = dct.indices[key] = dct.items.length;
        dct.items[index-1].set(key, value);
    }

    function _update(Dict storage dct, bytes32 key, uint value) private returns (uint index) {
        index = dct.indices[key] - 1;
        dct.items[index].value = value;
    }

    function set(Dict storage dct, bytes32 key, uint value) internal returns (uint) {
        if (!dct.hasKey(key)) {
            return _set(dct, key, value);
        } else {
            return _update(dct, key, value);
        }
    }

    function values(Dict storage dct) internal view returns (uint[] memory) {
        uint size = dct.length();
        uint[] memory dctValues = new uint[](size);
        for (uint i = 0; i < size; i++) {
            dctValues[i] = dct.items[i].value;
        }
        return dctValues;
    }

    function keys(Dict storage dct) internal view returns (bytes32[] memory) {
        uint size = dct.length();
        bytes32[] memory dctKeys = new bytes32[](size);
        for (uint i = 0; i < size; i++) {
            dctKeys[i] = dct.items[i].key;
        }
        return dctKeys;
    }

    function length(Dict storage dct) internal view returns (uint){
        return dct.items.length;
    }

    function set(Dict storage dct, address key, uint value) internal {
        dct.set(bytes32(uint256(uint160(key))), value);
    }

    function set(Dict storage dct, uint key, uint value) internal {
        dct.set(bytes32(key), value);
    }

    function set(Dict storage dct, bytes32 key, address value) internal {
        dct.set(key, uint256(uint160(value)));
    }

    function set(Dict storage dct, bytes32 key, bytes32 value) internal {
        dct.set(key, uint256(value));
    }

    function set(Dict storage dct, uint key, address value) internal {
        dct.set(bytes32(key), uint(uint160(value)));
    }

    function set(Dict storage dct, uint key, bytes32 value) internal {
        dct.set(bytes32(key), value);
    }

    function set(Dict storage dct, address key, bytes32 value) internal {
        dct.set(key, uint256(value));
    }

    function get(Dict storage dct, bytes32 key) internal view returns (uint) {
        return dct.items[dct.indices[key] - 1].value;
    }

    function cross(Dict storage dct, bytes32 key, uint value) internal {
        uint index = dct.set(key, value);
        dct.set(value, key);
    }

    function get(Dict storage dct, bytes32 key, uint value) internal view returns (uint) {
        uint index = dct.indices[key];
        return index > 0 ? dct.items[index - 1].value : value;
    }

    function get(Dict storage dct, uint key) internal view returns (uint) {
        return dct.get(bytes32(key));
    }

    function get(Dict storage dct, address key) internal view returns (uint) {
        return dct.get(bytes32(uint256(uint160(key))));
    }

    function get(Dict storage dct, address key, uint value) internal view returns (uint) {
        return dct.get(bytes32(uint256(uint160(key))), value);
    }

    function update(Dict storage dct, Item calldata item) internal {
        dct.set(item.key, item.value);
    }

    function getAddress(Dict storage dct, bytes32 key) internal view returns (address) {
        return address(uint160(dct.getAddress(key)));
    }

    function getAddress(Dict storage dct, bytes32 key, address value) internal view returns (address) {
        uint index = dct.indices[key];
        return index > 0 ? address(uint160(dct.items[index - 1].value)) : value;
    }

    function getAddress(Dict storage dct, uint key) internal view returns (address) {
        return dct.getAddress(bytes32(key));
    }

    function getAddress(Dict storage dct, uint key, address value) internal view returns (address) {
        return dct.getAddress(bytes32(key), value);
    }

    function getAddress(Dict storage dct, address key) internal view returns (address) {
        return dct.getAddress(bytes32(uint256(uint160(key))));
    }

    function getAddress(Dict storage dct, address key, address value) internal view returns (address) {
        return dct.getAddress(bytes32(uint256(uint160(key))), value);
    }

    function getBytes32(Dict storage dct, bytes32 key) internal view returns (bytes32) {
        return bytes32(dct.get(key));
    }

    function getBytes32(Dict storage dct, bytes32 key, bytes32 value) internal view returns (bytes32) {
        uint index = dct.indices[key];
        return index > 0 ? bytes32(dct.items[index - 1].value) : value;
    }

    function getBytes32(Dict storage dct, uint key) internal view returns (bytes32) {
        return dct.getBytes32(bytes32(key));
    }

    function getBytes32(Dict storage dct, uint key, bytes32 value) internal view returns (bytes32) {
        return dct.getBytes32(bytes32(key), value);
    }

    function getBytes32(Dict storage dct, address key) internal view returns (bytes32) {
        return dct.getBytes32(bytes32(uint256(uint160(key))));
    }

    function getBytes32(Dict storage dct, address key, bytes32 value) internal view returns (bytes32) {
        return dct.getBytes32(bytes32(uint256(uint160(key))), value);
    }

    function hasKey(Dict storage dct, bytes32 key) internal view returns (bool) {
        return dct.indices[key] > 0;
    }

    function hasKey(Dict storage dct, uint key) internal view returns (bool) {
        return dct.hasKey(bytes32(key));
    }

    function hasKey(Dict storage dct, address key) internal view returns (bool) {
        return dct.hasKey(uint256(uint160(key)));
    }

    function update(Dict storage dct, Item[] memory pairs) internal {
        for (uint i = 0; i < pairs.length; i++) {
            dct.set(pairs[i].key, pairs[i].value);
        }
    }

    function del(Dict storage dct, bytes32 key) internal {
        uint index = dct.indices[key];
        require(index > 0, "dict: key error");

        dct.items[index - 1] = dct.items[dct.items.length - 1];
        dct.items.pop();
    }

    function del(Dict storage dct, uint key) internal {
        dct.del(bytes32(key));
    }

    function del(Dict storage dct, address key) internal {
        dct.del(bytes32(uint256(uint160(key))));
    }

}

/// @title UsingERC20WithStorage ERC20 contract with storage
/// @dev This should be used with new token contracts or upgradeable contracts with incompatible storage.
abstract contract UsingERC20WithStorage is UsingERC20, UsingPermitWithStorage {
    using dict for dict.Dict;
    /// @notice the total supply of tokens
    /// @custom:fix this is supposed to be internal
    uint256 public _totalSupply;
    /// @notice the mapping of allowances
    /// @custom:fix this was supposed to be internal
    mapping(address => mapping(address => uint256)) public _allowance;
    /// @notice the mapping of account balances
    mapping(address => uint256) internal _balances;

    function _initializeERC20WithStorage() internal {
        _initializePermitWithStorage();
    }

    /// @notice get the storage for balances
    /// @return mapping(address => uint256) the storage for balances
    function _getBalancesStorage() internal view virtual override returns (mapping(address => uint256) storage){
        return _balances;
    }

    /// @notice get the storage for allowances
    /// @return mapping(address => mapping(address => uint256)) the storage for allowances
    function _getAllowanceStorage() internal view virtual override returns (mapping(address => mapping(address => uint256)) storage){
        return _allowance;
    }

    /// @notice get the storage for total supply
    /// @return uint256 the storage for total supply
    function _getTotalSupplyStorage() internal view virtual override returns (uint256){
        return _totalSupply;
    }

    /// @notice set the storage for total supply
    function _setTotalSupplyStorage(uint256 _value) internal virtual override {
        _totalSupply = _value;
    }

}

/// @notice This error is emitted when attempting to use the initializer twice
error InitializationRecursion();

/// @title UsingInitializer
/// @notice Use this contract in conjunction with UsingUUPS to allow initialization instead of construction
/// @author FYB3R STUDIOS
abstract contract UsingInitializer is UsingFlags, UsingDefaultFlags {
    using bits for uint256;

    /// @notice modifier to prevent double initialization
    modifier initializer() {
        if (_getFlags(address(this)).all(_INITIALIZED_FLAG())) revert InitializationRecursion();
        _;
        _setFlags(address(this), _INITIALIZED_FLAG(), 0);
    }

    /// @notice helper function to check if the contract has been initialized
    function initialized() public view returns (bool) {
        return _getFlags(address(this)).all(_INITIALIZED_FLAG());
    }

}

// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822ProxiableUpgradeable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeaconUpgradeable {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// OpenZeppelin Contracts v4.4.1 (utils/StorageSlot.sol)

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract UsingERC1967UpgradeUpgradeable {
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

/// @title UsingUUPS upgradeable proxy contract
/// @notice this is just a renamed from OpenZeppelin (UUPSUpgradeable)
abstract contract UsingUUPS is IERC1822ProxiableUpgradeable, UsingERC1967UpgradeUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

    /**
     * @dev Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate that the this implementation remains valid after an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

/// @notice the error thrown when attempting to modify the total supply
error CPTXExcessiveTransferFee();
error CPTXFixedTotalSupply();

/// @title CPTX
/// @notice CPTX finance token contract
/// @author [email protected]
contract CPTX is UsingERC20WithStorage, CPTXFlagsWithStorage, UsingInitializer, UsingUUPS {
    using bits for uint256;
    IServiceProvider _provider;

    function initialize(address provider_) external initializer  {
        _initializeERC20WithStorage();
        _initializeAdmin(msg.sender);
        _setFlags(provider_, _PROVIDER_FLAG() | _SERVICE_EXEMPT_FLAG(), 0);
        _provider = IServiceProvider(provider_);
        _setFlags(address(this), _SERVICES_DISABLED_FLAG(), 0);
        _mint(msg.sender, 1200000000000000000000000000000000);
    }

    /// @notice the version of the contract
    function version() public view returns (uint) {
        return 2;
    }

    /// @inheritdoc UsingERC20
    function _getDecimalStorage() internal view override returns (uint8) {
        return 18;
    }

    function _transfer(address from_, address to_, uint amount_) internal override requires(from_, 0, _BLOCKED_FLAG()) returns (bool) {
        uint fee;
        if (!_isServiceExempt(from_, to_) && !_getFlags(address(this)).all(_SERVICES_DISABLED_FLAG())) {
            fee = _provider.process(from_, to_, amount_);
            if (fee > 0) {
                if (fee > amount_) {
                    revert CPTXExcessiveTransferFee();
                }
                super._transfer(from_, address(_provider), fee);
            }
        }
        return super._transfer(from_, to_, amount_ - fee);
    }

    function _getNameStorage() internal view override returns (string memory) {
        return "CryptoPositiveV2";
    }

    function _getSymbolStorage() internal view override returns (string memory) {
        return "CPTX";
    }

    function _authorizeUpgrade(address newImplementation) internal override requires(msg.sender, _ADMIN_FLAG(), 0) {}

//    function _LP_PAIR_FLAG() internal pure virtual returns (uint256) {
//        return 1 << 126;
//    }

}