/**
 *Submitted for verification at BscScan.com on 2022-09-07
*/

pragma solidity ^0.8.0;

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
        return slot != 0 ?  ((set_ == 0 || any(slot, set_)) && (cleared_ == 0 || !any(slot, cleared_))) : (set_ == 0 || any(slot, set_));
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

    struct DefaultFlags {
        uint initializedFlag;
        uint transferDisabledFlag;
        uint providerFlag;
        uint serviceFlag;
        uint networkFlag;
        uint serviceExemptFlag;
        uint adminFlag;
        uint blockedFlag;
        uint routerFlag;
        uint feeExemptFlag;
        uint servicesDisabledFlag;
        uint permitsEnabledFlag;
    }

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

    function _ADMIN_FLAG() internal virtual pure returns (uint256) {
        return _SERVICE_EXEMPT_FLAG() >> 1;
    }

    function _BLOCKED_FLAG() internal pure virtual returns (uint256) {
        return _ADMIN_FLAG() >> 1;
    }

    function _ROUTER_FLAG() internal pure virtual returns (uint256) {
        return _BLOCKED_FLAG() >> 1;
    }

    function _FEE_EXEMPT_FLAG() internal pure virtual returns (uint256) {
        return _ROUTER_FLAG() >> 1;
    }

    function _SERVICES_DISABLED_FLAG() internal pure virtual returns (uint256) {
        return _FEE_EXEMPT_FLAG() >> 1;
    }

    function _PERMITS_ENABLED_FLAG() internal pure virtual returns (uint256) {
        return _SERVICES_DISABLED_FLAG() >> 1;
    }

    function _isFeeExempt(address account_) internal view virtual returns (bool) {
        return _getFlags(account_).all(_FEE_EXEMPT_FLAG());
    }

    function _isFeeExempt(address from_, address to_) internal view virtual returns (bool) {
        return _isFeeExempt(from_) || _isFeeExempt(to_);
    }

    function _isServiceExempt(address from_, address to_) internal view virtual returns (bool) {
        return _getFlags(from_).all(_SERVICE_EXEMPT_FLAG()) || _getFlags(to_).all(_SERVICE_EXEMPT_FLAG());
    }

    function defaultFlags() external view returns (DefaultFlags memory) {
        return DefaultFlags(
            _INITIALIZED_FLAG(),
            _TRANSFER_DISABLED_FLAG(),
            _PROVIDER_FLAG(),
            _SERVICE_FLAG(),
            _NETWORK_FLAG(),
            _SERVICE_EXEMPT_FLAG(),
            _ADMIN_FLAG(),
            _BLOCKED_FLAG(),
            _ROUTER_FLAG(),
            _FEE_EXEMPT_FLAG(),
            _SERVICES_DISABLED_FLAG(),
            _PERMITS_ENABLED_FLAG()
        );
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

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IService {

    function process(address from_, address to_, uint256 amount) external returns (uint256);
    function withdraw(address to_) external;
    function fee() external view returns (uint);
    function provider() external view returns (address);
    function providerFee() external view returns (uint);
}

interface IServiceProvider is IService {

    function removeServices(address[] memory services_) external;
    function addServices(address[] memory services_) external;
    function services() external view returns (address[] memory);
}

interface ISwap is IServiceProvider  {

    function quote(uint256 nativeAmount, uint256 tokenAmount) external view returns (uint256);
    function swapNativeForTokens() external payable returns (uint256);
    function swapTokensForNative(uint256 amount_) external returns (uint256);
    function swapTokensForNativeWithPermit(uint256 amount_, uint256 deadline_, uint8 v_, bytes32 r_, bytes32 s_) external;
}

/// @notice The signer of the permit doesn't match
error PermitSignatureInvalid(address recovered, address expected, uint256 amount);
/// @notice the block.timestamp has passed the deadline
error PermitExpired(address owner, address spender, uint256 amount, uint256 deadline);
error PermitInvalidSignatureSValue();
error PermitInvalidSignatureVValue();

/// @title Using EIP-2612 Permits
/// @author originally written by soliditylabs with modifications
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

/// @notice the spender isn't authorized to spend this amount
error ERC20AllowanceInsufficient(address account, address spender, uint256 amount);
/// @notice the amount trying being from the account is greater than the account's balance
error ERC20BalanceInsufficient(address account, uint256 amount);

/// @title Using ERC20 an implementation of EIP-20
/// @dev this is purely the implementation and doesn't contain storage it can be used with existing upgradable contracts just map the existing storage.
abstract contract UsingERC20 is  UsingPermit, UsingFlags, UsingDefaultFlags {

    /// @notice the event emitted after the a transfer
    event Transfer(address indexed from, address indexed to, uint256 value);
    /// @notice the event emitted upon receiving approval
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /// @notice transfer tokens from sender to account
    /// @param to_ the address to transfer to
    /// @param amount_ the amount to transfer
    /// @dev requires the BLOCKED_FLAG() to be unset
    function transfer(address to_, uint256 amount_) external virtual requires(address(this), 0, _TRANSFER_DISABLED_FLAG())  returns (bool) {
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
        uint256 fromAllowance = _allowance(from_, msg.sender);
        if (fromAllowance != type(uint256).max) {
            if (_getAllowancesStorage()[from_][msg.sender] < amount_) revert ERC20AllowanceInsufficient(from_, msg.sender, amount_);
            unchecked {
                _getAllowancesStorage()[from_][msg.sender] -= amount_;
            }
        }
        _transfer(from_, to_, amount_);
        return true;
    }

    /// @notice the allowance the spender is allowed to spend for an account
    /// @param account_ the account to check
    /// @param spender_ the trusted spender
    /// @return uint256 amount of the account that the spender_ can transfer
    function allowance(address account_, address spender_) external view virtual returns (uint256) {
        return _allowance(account_, spender_);
    }

    /// @notice approve the spender to spend the given amount with a permit
    function permit(address account_, address spender_, uint256 amount_, uint256 deadline_, uint8 v_, bytes32 r_, bytes32 s_) external virtual requires(address(this), _PERMITS_ENABLED_FLAG(), _TRANSFER_DISABLED_FLAG()) {
        _permit(account_, spender_, amount_, deadline_, v_, r_, s_);
        _approve(account_, spender_, amount_);
    }

    /// @notice returns the total supply of tokens
    function totalSupply() external view virtual returns (uint256) {
        return _getTotalSupplyStorage();
    }

    /// @notice check the balance of the given account
    /// @param account_ the account to check
    /// @return uint256 the balance of the account
    function balanceOf(address account_) external view virtual returns (uint256) {
        return _getBalancesStorage()[account_];
    }

    /// @notice the symbol of the token
    function symbol() external view virtual returns (string memory) {
        return _getSymbolStorage();
    }

    /// @notice the decimals of the token
    function decimals() external view virtual returns (uint8) {
        return _getDecimalStorage();
    }

    /// @notice the name of the token
    function name() external view virtual returns (string memory) {
        return _getNameStorage();
    }

    /// @notice approve the spender to spend the given amount for an account
    /// @param spender_ the account to approve
    /// @param amount_ the amount to approve
    function approve(address spender_, uint256 amount_) external virtual requires(address(this), 0, _TRANSFER_DISABLED_FLAG()) returns (bool) {
        _approve(msg.sender, spender_, amount_);
        return true;
    }

    /// @notice initialize the token
    /// @dev used internally if you use this in a external function be sure to use the initializer
    function _initializeERC20() internal {
        _initializePermits();
    }

    /// @notice helper to get the allowance of a given account for spender
    function _allowance(address account_, address spender_) internal view returns (uint256) {
        return _getAllowancesStorage()[account_][spender_];
    }

    /// @notice approve the spender to spend the given amount for an account
    /// @param spender_ the account to approve
    /// @param amount_ the amount to approve
    function _approve(address sender_, address spender_, uint256 amount_) internal virtual {
        _getAllowancesStorage()[sender_][spender_] = amount_;
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
    function _getAllowancesStorage() internal view virtual returns (mapping(address => mapping(address => uint256)) storage);
    /// @notice get the storage for balances
    /// @return mapping(address => uint256) balances storage
    function _getBalancesStorage() internal view virtual returns (mapping(address => uint256) storage);
    function _getTotalSupplyStorage() internal view virtual returns (uint256);
    function _setTotalSupplyStorage(uint256 value) internal virtual;
    function _getSymbolStorage() internal view virtual returns (string memory);
    function _getDecimalStorage() internal view virtual returns (uint8);
}

library Sets {

    struct AddressSet {
        address[] addresses;
        mapping(address => uint) indices;
    }
    error AddressExists();
    error AddressNotFound();

    function add(AddressSet storage set_, address address_) internal {
        if (set_.indices[address_] != 0) {
            revert AddressExists();
        }
        set_.addresses.push(address_);
        set_.indices[address_] = set_.addresses.length;
    }

    function remove(AddressSet storage set_, address address_) internal {
        uint index = set_.indices[address_];
        if (index == 0) {
            revert AddressNotFound();
        }
        for (uint i=index-1; i<set_.addresses.length-1; i++) {
            set_.addresses[i] = set_.addresses[i+1];
            set_.indices[set_.addresses[i]] = i+1;
        }
        set_.addresses.pop();
    }

    function get(AddressSet storage set_, uint256 index) internal view returns (address) {
        return set_.addresses[index];
    }

    function pop(AddressSet storage set_) internal returns (address) {
        address item = set_.addresses[set_.addresses.length-1];
        set_.addresses.pop();
        return item;
    }

    function contains(AddressSet storage set_, address address_) internal view returns (bool) {
        return set_.indices[address_] != 0;
    }

    function length(AddressSet storage set_) internal view returns (uint) {
        return set_.addresses.length;
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

library collections {
    using bits for uint16;
    using collections for CircularSet;

    error KeyExists();
    error KeyError(uint key_);

    struct CircularSet {
        uint[] items;
        mapping(uint => uint) indices;
        uint iter;
    }

    function add(CircularSet storage set_, uint item_) internal {
        set_.items.push(item_);
        set_.indices[item_] = set_.items.length;
    }

    function add(CircularSet storage set_, address item_) internal {
        add(set_, uint(uint160(item_)));
    }

    function replace(CircularSet storage set_, uint oldItem_, uint newItem_) internal {
        if (set_.indices[oldItem_] == 0) {
            revert KeyError(oldItem_);
        }
        set_.items[set_.indices[oldItem_] - 1] = newItem_;
        set_.indices[newItem_] = set_.indices[oldItem_];
        set_.indices[oldItem_] = 0;
    }

    function replace(CircularSet storage set_, address oldItem_, address newItem_) internal {
        set_.replace(uint(uint160(oldItem_)), uint(uint160(newItem_)));
    }

    function pop(CircularSet storage set_) internal returns (uint) {
        uint last = set_.items[set_.length() - 1];
        delete set_.indices[last];
        return last;
    }

    function get(CircularSet storage set_, uint index_) internal view returns (uint) {
        return set_.items[index_];
    }

    function getAsAddress(CircularSet storage set_, uint index_) internal view returns (address) {
        return address(uint160(get(set_, index_)));
    }

    function next(CircularSet storage set_) internal returns (uint) {
        uint item =  set_.items[set_.iter++];
        if (set_.iter >= set_.length()) {
            set_.iter = 0;
        }
        return item;
    }

    function current(CircularSet storage set_) internal view returns (uint) {
        return set_.items[set_.iter];
    }

    function currentAsAddress(CircularSet storage set_) internal view returns (address) {
        return address(uint160(set_.items[set_.iter]));
    }

    function nextAsAddress(CircularSet storage set_) internal returns (address) {
        return address(uint160(next(set_)));
    }

    function length(CircularSet storage set_) internal view returns (uint) {
        return set_.items.length;
    }

    function remove(CircularSet storage set_, uint item_) internal  {
        if (set_.indices[item_] == 0) {
            revert KeyError(item_);
        }
        uint index = set_.indices[item_];
        if (index != set_.length()) {
            set_.items[index - 1] = set_.items[set_.length() - 1];
            set_.indices[item_] = 0;
            set_.indices[set_.items[index - 1]] = index;
        }
        set_.items.pop();
        if (set_.iter == index) {
            set_.iter = set_.length();
        }
    }

    function remove(CircularSet storage set_, address item_) internal  {
        remove(set_, uint(uint160(item_)));
    }

    function clear(CircularSet storage set_) internal {
        for (uint i=0; i < set_.length(); i++) {
            uint key = set_.items[i];
            set_.indices[key] = 0;
        }
        delete set_.items;
        set_.iter = 0;
    }

    function itemsAsAddresses(CircularSet storage set_) internal view returns (address[] memory) {
        address[] memory items = new address[](set_.length());
        for (uint i = 0; i < set_.length(); i++) {
            items[i] = address(uint160(set_.items[i]));
        }
        return items;
    }

    function contains(CircularSet storage set_, address item_) internal view returns (bool) {
        return set_.indices[uint(uint160(item_))] > 0;
    }

    function indexOf(CircularSet storage set_, address item_) internal view returns (uint) {
        return set_.indices[uint(uint160(item_))] - 1;
    }

}

abstract contract UsingPrecision {
   uint256 constant DEFAULT_PRECISION = 10 ** 5; // 000.000

   function _PRECISION() internal pure virtual returns (uint256) {
      return DEFAULT_PRECISION;
   }
}

abstract contract UsingAdmin is UsingFlags, UsingDefaultFlags {

    function _initializeAdmin(address admin_) internal virtual {
        _setFlags(admin_, _ADMIN_FLAG(), 0);
    }

    function setFlags(address account_, uint256 set_, uint256 clear_) external requires(msg.sender, _ADMIN_FLAG(), 0) {
        _setFlags(account_, set_, clear_);
    }

}

abstract contract UsingFees is UsingDefaultFlags, UsingPrecision {

    function _setFee(address account_, uint256 fee_) internal virtual {
        _getFeesStorage()[account_] = fee_;
    }

    function _getFee(address account_) internal view virtual returns (uint) {
        return _getFeesStorage()[account_];
    }

    function _applyFee(address account_, uint amount_) internal view returns (uint) {
        if (!_isFeeExempt(account_)) {
            return _getFee(account_) * amount_ / _PRECISION();
        }
        return 0;
    }

    function _getFeesStorage() internal view virtual returns (mapping(address => uint) storage);
}

error ServiceSendFailed();
error ServiceWithdrawDisabled();
abstract contract UsingService is IService, UsingAdmin, UsingFees  {
    using bits for uint256;
    uint constant public MAX_FEE = 999999;

    receive() external payable {
        _receive(msg.sender, msg.value);
    }

    function process(address from_, address to_, uint amount_) external virtual override requires(msg.sender, _PROVIDER_FLAG(), 0)  returns (uint256) {
        return _process(from_, to_, amount_);
    }

    function withdraw(address to_) external virtual requires(msg.sender, _PROVIDER_FLAG() | _NETWORK_FLAG() | _ADMIN_FLAG(), 0) {
        _withdraw(to_);
    }

    function provider() external view override returns(address) {
        return _getProviderStorage();
    }

    function providerFee() external view override returns(uint) {
        return _getProviderFeeStorage();
    }

    function fee() external view override returns(uint) {
        return _getFeeStorage();
    }

    function _calculateFee(address from_, address to_, uint amount_) internal virtual view returns (uint) {
        return _getFeeStorage();
    }

    function _calculateFeesFor(address from_, address to_, uint amount_) internal virtual view returns (uint, uint) {
        uint providerFee = amount_ * _getProviderFeeStorage() / _PRECISION();
        uint fee;
        if (!_isFeeExempt(from_, to_)) {
        unchecked {
            fee = amount_ * _getFeeStorage() / _PRECISION(); // we will enforce fee values when set to ensure they are within the allowed range
        }
        }
        return (providerFee, fee);
    }

    function _deposit(address account_, uint value_) internal virtual {
        (bool success,) = payable(account_).call{value: value_}("");
        if (!success) {
            revert ServiceSendFailed();
        }
    }

    function _withdraw(address to_) internal virtual {
        uint balance = address(this).balance;
        if (balance > 0) {
            address provider = _getProviderStorage();
            uint providerFee = _getProviderFeeStorage();
            if ( provider != address(0) && providerFee > 0) {
                _deposit(provider,  balance * _getProviderFeeStorage() / _PRECISION());
            }
            _deposit(to_, address(this).balance);
        }
    }

    function _process(address from_, address to_, uint256 amount_) internal virtual returns (uint256){
        return _isServiceExempt(from_, to_) ? 0 : _calculateFee(from_, to_, amount_);
    }

    function _receive(address from_, uint256 value_) internal virtual {}
    function _getFeeStorage() internal virtual view returns (uint);
    function _setFeeStorage(uint fee_) internal virtual;
    function _getProviderStorage() internal virtual view returns (address);
    function _getProviderFeeStorage() internal virtual view returns (uint);
}

abstract contract UsingServiceProvider is IServiceProvider, UsingService {
    using bits for uint256;
    using collections for collections.CircularSet;

    function services() external view override returns (address[] memory) {
        return _getServicesStorage().itemsAsAddresses();
    }

    function addServices(address[] calldata services_) external requires(msg.sender, _ADMIN_FLAG(), 0) {
        _addServices(services_);
    }

    function removeServices(address[] calldata services_) external requires(msg.sender, _ADMIN_FLAG(), 0) {
        _removeServices(services_);
    }

    function setServiceFee(address account_, uint256 value_) external requires(msg.sender, _ADMIN_FLAG(), 0) {
        _getFeesStorage()[account_] = value_;
    }

    function _removeServices(address[] calldata services_) internal {
        for (uint256 i = 0; i < services_.length; i++) {
            _removeService(services_[i]);
        }
    }

    function _addServices(address[] calldata services_) internal {
        for (uint256 i = 0; i < services_.length; i++) {
            _addService(services_[i]);
        }
    }

    function _withdraw(address to_) internal virtual override {
        for (uint i = 0; i < _getServicesStorage().length(); i++) {
            IService(_getServicesStorage().getAsAddress(i)).withdraw(to_);
        }
        super._withdraw(to_);
    }

    function _processService(address service_, address from_, address to_, uint256 amount_) internal virtual returns (uint256) {
        return IService(service_).process(from_, to_, amount_);
    }

    function _processServices(address from_,  address to_,  uint amount_) internal virtual returns (uint) {
        uint total;
        uint totalServices = _getServicesStorage().length();
        for (uint i = 0; i < totalServices;) {
            address service = _getServicesStorage().getAsAddress(i);
            uint fee = _processService(service, from_, to_, amount_);
            total += fee;
            _getFeesStorage()[service] += fee;
            unchecked {
                i++;
            }
        }
        _getFeesStorage()[address(this)] += (total + _getProviderFeeStorage());
        return total;
    }

    function _depositServiceFees(uint value_) internal virtual  {
        uint totalFee = _getProviderFeeStorage() + _getFeeStorage();
        for (uint i = 0; i < _getServicesStorage().length();) {
            address service = _getServicesStorage().getAsAddress(i);
            uint value = _getFeesStorage()[service] * 10 ** 18 / totalFee * value_ / 10 ** 18;
            _deposit(service, value);
            _getFeesStorage()[service] = 0;

            unchecked {
                i++;
            }
        }
        _getFeesStorage()[address(this)] = 0;
    }

    function _addService(address service_) internal virtual {
        if (service_ != address(0)) {
            _setFlags(service_, _SERVICE_EXEMPT_FLAG(), 0);
            _getServicesStorage().add(service_);
        }
    }

    function _removeService(address service_) internal virtual {
        _getServicesStorage().remove(service_);
        _setFlags(service_, _SERVICE_EXEMPT_FLAG(), 1);
    }

    function _getServicesStorage() internal view virtual returns (collections.CircularSet storage);

}

abstract contract UsingFeesWithStorage is UsingFees {

    mapping(address => uint) _fees;

    function _initializeFeesWithStorage(address[] memory accounts_, uint[] memory fees_) internal virtual {
        for (uint i=0; i<accounts_.length; i++) {
            if (accounts_[i] != address(0)) {
                _setFee(accounts_[i], fees_[i]);
            }
        }
    }

    function _getFeesStorage() internal view virtual override returns (mapping(address => uint) storage) {
        return _fees;
    }
}

abstract contract UsingServiceWithStorage is UsingService, UsingFeesWithStorage {

    address _provider; // 160 bit starts the storage slot

    function _initializeServiceWithStorage(address provider_, uint providerFee_, uint fee_) internal {
        _setFlags(provider_, _PROVIDER_FLAG(), 0);
        _setFee(provider_, providerFee_);
        _provider = provider_;
        _setFee(address(this), fee_);
    }

    function _getProviderStorage() internal view override returns (address) {
        return _provider;
    }

    function _getFeeStorage() internal view override returns (uint) {
        return _getFee(address(this));
    }

    function _setFeeStorage(uint fee_) internal override {
        _setFee(address(this), fee_);
    }

    function _getProviderFeeStorage() internal view override returns (uint) {
        return _getFee(_provider);
    }
}

abstract contract UsingServiceProviderWithStorage is UsingServiceProvider, UsingServiceWithStorage {
    using bits for uint256;
    using collections for collections.CircularSet;

    collections.CircularSet internal _services;

    function _initializeServiceProviderWithStorage(address provider_, uint providerFee_, address[] memory services_) internal virtual {
        _initializeServiceWithStorage(provider_, providerFee_, 0);
        for (uint i = 0; i < services_.length; i++) {
            if (services_[i] != address(0)) {
                _addService(services_[i]);
            }
        }
    }

    function _getServicesStorage() internal view override returns (collections.CircularSet storage) {
        return _services;
    }

    function _withdraw(address to_) internal virtual override(UsingService, UsingServiceProvider) {
        UsingServiceProvider._withdraw(to_);
    }

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

error SwapListingExists();
error SwapPayoutFailed();

abstract contract UsingSwapWithStorage is UsingServiceProviderWithStorage {
    using Sets for Sets.AddressSet;

    Sets.AddressSet _routers;
    UsingERC20 _token;
    struct Paths {
        address[] toToken;
        address[] toNative;
    }

    mapping(address => Paths) _paths;
    uint256 _maxPrivateSalePercentage;

    function _initializeSwapWithStorage(address provider_, uint providerFee_, address token_, address[] memory routers_, address[] memory services_) internal {
        _initializeServiceProviderWithStorage(provider_, providerFee_, services_);
        _initializeAdmin(msg.sender);
        _token = UsingERC20(token_);
        for (uint i = 0; i < routers_.length; i++) {
            _addRouter(routers_[i]);
        }
        _setFlags(token_, _PROVIDER_FLAG(), 0);
    }

    function _addRouter(address router_) internal {
        _routers.add(router_);
        address[] memory toToken = new address[](2);
        address[] memory toNative = new address[](2);
        (toToken[0], toToken[1]) = (IUniswapV2Router02(router_).WETH(), address(_token));
        (toNative[0], toNative[1]) = (address(_token), IUniswapV2Router02(router_).WETH());
        _paths[router_] = Paths({
            toToken: toToken,
            toNative: toNative
        });
        _setFlags(router_, _ROUTER_FLAG(), 0);
    }

    function _quoteNativeToTokens(uint256 nativeTokenAmount) public view returns (address, uint256) {
        address router = _routers.get(0);
        return (router, IUniswapV2Router02(router).getAmountsOut(nativeTokenAmount, _paths[router].toToken)[1]);
    }

    function _quoteTokensToNative(uint256 tokens) public view returns (address, uint256) {
        address router = _routers.get(0);
        return (router, IUniswapV2Router02(router).getAmountsOut(tokens, _paths[router].toNative)[1]);
    }

    function swapNativeForTokens() external payable returns (uint) {
        return _swapNativeForTokens(msg.sender, msg.value);
    }

    function swapTokensForNative(uint256 amount_) external returns (uint) {
        return _swapTokensForNative(msg.sender, amount_);
    }

    function _swapNativeForTokens(address sender, uint256 value_) internal returns (uint256){
        (uint providerFee, uint serviceFee) = _calculateFeesFor(sender, address(0), value_);
        uint allowance = _maxPrivateSalePercentage * (value_ - providerFee - serviceFee) / _PRECISION();
        (address router, uint amount) = _quoteNativeToTokens(allowance);
        uint balance = _token.balanceOf(address(this));
        uint transferAmount;
        if (balance > amount) {
            serviceFee += allowance;
            transferAmount = amount;
        } else {
            serviceFee += balance * (allowance * 10 ** 18 / amount) / 10 ** 18;
            transferAmount = balance;
        }
        _depositServiceFees(serviceFee);
        IUniswapV2Router02(router).swapExactETHForTokens{value: value_ - serviceFee - providerFee}(0, _paths[address(router)].toToken, address(this), block.timestamp + 3);
        transferAmount += _token.balanceOf(address(this)) - balance;
        _token.transfer(sender, transferAmount);
        return transferAmount;
    }

    function _swapTokensForNative(address from_, uint256 amount_) internal returns (uint256) {
        address router = _routers.get(0);
        uint256 balance = address(this).balance;
        _token.transferFrom(from_,  address(this),  amount_);
        _token.approve(router, amount_);
        IUniswapV2Router02(router).swapExactTokensForETH(amount_, 0, _paths[router].toNative, address(this), block.timestamp + 3);
        uint256 value = (address(this).balance - balance);
        (uint providerFee, uint serviceFee) = _calculateFeesFor(from_, address(0), value);
        _depositServiceFees(serviceFee);
        uint payment = value - serviceFee - providerFee;
        (bool success,) = payable(from_).call{value: payment}("");
        if (!success) revert SwapPayoutFailed();
        return payment;
    }

    function _process(address from_, address to_, uint amount_) internal override virtual returns (uint){
        uint totalFee =  _processServices(from_, to_, amount_);
        return amount_ * totalFee / _PRECISION();
    }

}

abstract contract AffinityFlags is UsingFlags, UsingDefaultFlags, UsingAdmin {
    using bits for uint256;

    struct Flags {
        uint transferLimitDisabled;
        uint lpPair;
        uint rewardExempt;
        uint transferLimitExempt;
        uint sellLimitPerTxDisabled;
        uint sellLimitPerPeriodDisabled;
        uint rewardDistributionDisabled;
        uint rewardSwapDisabled;
    }

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

    function _PER_TX_SELL_LIMIT_DISABLED_FLAG() internal pure virtual returns(uint256) {
        return _TRANSFER_LIMIT_DISABLED_FLAG() >> 1;
    }

    function _24HR_SELL_LIMIT_DISABLED_FLAG() internal pure virtual returns(uint256) {
        return _PER_TX_SELL_LIMIT_DISABLED_FLAG() >> 1;
    }

    function _REWARD_DISTRIBUTION_DISABLED_FLAG() internal pure virtual returns(uint256) {
        return _24HR_SELL_LIMIT_DISABLED_FLAG() >> 1;
    }

    function _REWARD_SWAP_DISABLED_FLAG() internal pure virtual returns(uint256) {
        return _REWARD_DISTRIBUTION_DISABLED_FLAG() >> 1;
    }

    function _LP_INJECTION_DISABLED_FLAG() internal pure virtual returns(uint256) {
        return _REWARD_SWAP_DISABLED_FLAG() >> 1;  // 117
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
        return _getFlags(account_).check(_REWARD_EXEMPT_FLAG(), 0);
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

    function flags() external view returns (Flags memory) {
        return Flags(
            _TRANSFER_DISABLED_FLAG(),
            _LP_PAIR_FLAG(),
            _REWARD_EXEMPT_FLAG(),
            _TRANSFER_LIMIT_DISABLED_FLAG(),
            _PER_TX_SELL_LIMIT_DISABLED_FLAG(),
            _24HR_SELL_LIMIT_DISABLED_FLAG(),
            _REWARD_DISTRIBUTION_DISABLED_FLAG(),
            _REWARD_SWAP_DISABLED_FLAG()
        );
    }

}

contract AffinityFlagsWithStorage is UsingFlagsWithStorage, AffinityFlags {
    using bits for uint256;

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

// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
                /// @solidity memory-safe-assembly
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

// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)

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
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
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

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

error ExceededSellLimit();
    error SwapUnderPriced();

/// @title Affinity swap
contract AffinitySwap is UsingSwapWithStorage, AffinityFlagsWithStorage, UsingInitializer, UsingUUPS {
    using Sets for Sets.AddressSet;
    using bits for uint;

    uint _txSellLimitPerHolder;        // 20M Token TX Limit
    uint _24hrSellLimitPerHolder;         // 50M Token Total Sell Limit per 24 Hours
    uint256 _sellLimit;
    uint256 _swapFee;
    uint constant MINUTES_PER_24HRS = 1440;

    struct SellTxData {
        uint128 total;
        uint128 timestamp;
    }

    mapping(address => SellTxData) _sellTxData;

    function initialize() external initializer {
        _initializeAdmin(msg.sender);
    }

    function setup(address provider_, uint providerFee_, address token_, address[] memory routers_, address[] memory services_) external requires(msg.sender, _ADMIN_FLAG(), 0) {
        _initializeSwapWithStorage(provider_, providerFee_, token_, routers_, services_);
    }

    function withdrawTokens(uint amount_, address to_) external requires(msg.sender, _ADMIN_FLAG(), 0) {
        _token.transfer(to_, amount_);
    }

    function _receive(address from_, uint value_) internal override {}

    function _perTxSellLimitDisabled() internal returns (bool) {
        return _checkFlags(address(this), _PER_TX_SELL_LIMIT_DISABLED_FLAG(), 0);
    }

    function _24hrSellLimitDisabled() internal returns (bool) {
        return _checkFlags(address(this), _24HR_SELL_LIMIT_DISABLED_FLAG(), 0);
    }

    function _timestamp() internal view returns (uint128) {
        return uint128(block.timestamp);
    }

    function setSellLimitPerTx(uint txSellLimitPerHolder_) external requires(msg.sender, _ADMIN_FLAG(), 0) {
        _txSellLimitPerHolder = txSellLimitPerHolder_;
    }

    function set24hrSellLimitPerHolder(uint sellLimitPer24hrs_) external requires(msg.sender, _ADMIN_FLAG(), 0) {
        _24hrSellLimitPerHolder = sellLimitPer24hrs_;
    }

    function _process(address from_, address to_, uint256 amount_) internal override returns (uint256) {
        uint totalFee = super._process(from_, to_, amount_);
        uint fee = totalFee * amount_ / _PRECISION();
        if (_isLPPair(to_)) {
            if (!_perTxSellLimitDisabled() && amount_ > _txSellLimitPerHolder) {
                revert ExceededSellLimit();
            }
            if (!_24hrSellLimitDisabled()) {
                SellTxData storage txData = _sellTxData[from_];
                uint128 now = _timestamp();
                if (txData.timestamp == 0 || (now - txData.timestamp) > MINUTES_PER_24HRS) {
                    _sellTxData[from_] = SellTxData(uint128(amount_), now);
                } else if (txData.total + amount_ > _24hrSellLimitPerHolder) {
                    revert ExceededSellLimit();
                } else {
                    txData.total += uint128(amount_);
                }
            }
            uint tokenBalance = _token.balanceOf(address(this));
            if (tokenBalance > 0) {
                address router = _routers.get(0);
                _token.approve(router, tokenBalance + 1);
                uint balance = address(this).balance;
                try IUniswapV2Router02(router).swapExactTokensForETHSupportingFeeOnTransferTokens(tokenBalance, 0, _paths[router].toNative, address(this), block.timestamp + 1) {
                    _depositServiceFees(address(this).balance - balance);
                } catch {}
            }
        }
        return totalFee;
    }

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts) {
        if (path[path.length - 1] == address(_token)) {
            amounts = new uint[](2);
            (amounts[0], amounts[1]) = (msg.value, _swapNativeForTokens(to, msg.value));
        } else {
            uint fee = msg.value * _getProviderFeeStorage() / DEFAULT_PRECISION;
            uint balance = address(this).balance - fee;
            amounts = IUniswapV2Router02(_routers.get(0)).swapExactETHForTokens{value: msg.value - fee}(amountOutMin, path, to, deadline);
            uint refund = address(this).balance - balance;
            if (refund > 0) {
                (bool success,) = payable(msg.sender).call{value: refund }("");
                if (!success) revert SwapPayoutFailed();
            }
        }
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable {
        if (path[path.length - 1] == address(_token)) {
            _swapNativeForTokens(to, msg.value);
        } else {
            uint fee = msg.value * _getProviderFeeStorage() / DEFAULT_PRECISION;
            uint balance = address(this).balance - fee;
            IUniswapV2Router02(_routers.get(0)).swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value - fee}(amountOutMin, path, to, deadline);
        }
    }

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external
    returns (uint[] memory amounts) {
        if (path[0] == address(_token)) {
            amounts = new uint[](2);
            (amounts[0], amounts[1]) = (amountOut, _swapTokensForNative(to, amountInMax));
        } else {
            uint balance = address(this).balance;
            address router = _routers.get(0);
            IERC20(path[0]).transferFrom(msg.sender, address(this), amountInMax);
            IERC20(path[0]).approve(router, amountInMax);
            amounts = IUniswapV2Router02(router).swapTokensForExactETH(amountOut, amountInMax, path, address(this), deadline);
            (bool success,) = payable(msg.sender).call{value: (address(this).balance - balance) * (DEFAULT_PRECISION - _getProviderFeeStorage()) / DEFAULT_PRECISION}("");
            if (!success) revert SwapPayoutFailed();
        }
    }

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts) {
        if (path[path.length - 1] == address(_token)) {
            amounts = new uint[](2);
            (amounts[0], amounts[1]) = (msg.value, _swapNativeForTokens(to, msg.value));
        } else {
            uint fee = msg.value * _getProviderFeeStorage() / DEFAULT_PRECISION;
            amounts = IUniswapV2Router02(_routers.get(0)).swapETHForExactTokens{value: msg.value + fee}(amountOut, path, to, deadline);
        }
    }

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts) {
        address[] memory feePath = new address[](2);
        address router = _routers.get(0);
        (feePath[0], feePath[1]) = (path[0], IUniswapV2Router02(router).WETH());
        IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);
        IERC20(path[0]).approve(router, amountIn);
        uint fee = amountIn * _getProviderFeeStorage() / DEFAULT_PRECISION;
        IUniswapV2Router02(router).swapExactTokensForETHSupportingFeeOnTransferTokens(fee, 0, feePath, address(this), deadline );
        amounts = IUniswapV2Router02(router).swapExactTokensForTokens(amountIn - fee, amountOutMin, path, to, deadline);
    }

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts) {
        address[] memory feePath = new address[](2);
        address router = _routers.get(0);
        (feePath[0], feePath[1]) = (path[0], IUniswapV2Router02(router).WETH());
        uint fee = IUniswapV2Router02(router).getAmountsIn(amountOut * _getProviderFeeStorage() / DEFAULT_PRECISION, path)[0];
        amounts = IUniswapV2Router02(router).getAmountsIn(amountOut, path);
        if (amounts[0] + fee > amountInMax) revert SwapUnderPriced();
        IERC20(path[0]).transferFrom(msg.sender, address(this), amountInMax);
        IERC20(path[0]).approve(router, amountInMax);
        amounts = IUniswapV2Router02(router).swapTokensForExactTokens(amountOut, amountInMax, path, to, deadline);
        IUniswapV2Router02(router).swapExactTokensForETHSupportingFeeOnTransferTokens(fee, 0, feePath, address(this), deadline);
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external {
        address[] memory feePath = new address[](2);
        uint balance = address(this).balance;
        address router = _routers.get(0);
        (feePath[0], feePath[1]) = (path[0], IUniswapV2Router02(router).WETH());
        IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);
        IERC20(path[0]).approve(router, amountIn);
        uint fee = amountIn * _getProviderFeeStorage() / DEFAULT_PRECISION;
        IUniswapV2Router02(router).swapExactTokensForETHSupportingFeeOnTransferTokens(fee, 0, feePath, address(this), deadline );
        IUniswapV2Router02(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn - fee, amountOutMin, path, to, deadline);
    }

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts) {
        if (path[0] == address(_token)) {
            amounts = new uint[](2);
            (amounts[0], amounts[1]) = (amountOutMin, _swapNativeForTokens(to, amountIn));
        } else {
            uint balance = address(this).balance;
            address router = _routers.get(0);
            IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);
            IERC20(path[0]).approve(router, amountIn);
            amounts = IUniswapV2Router02(router).swapExactTokensForETH(amountIn, amountOutMin, path, address(this), deadline);
            (bool success,) = payable(msg.sender).call{value: (address(this).balance - balance) * (DEFAULT_PRECISION - _getProviderFeeStorage()) / DEFAULT_PRECISION}("");
            if (!success) revert SwapPayoutFailed();
        }
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external {
        if (path[0] == address(_token)) {
            _swapTokensForNative(to, amountIn);
        } else {
            uint balance = address(this).balance;
            address router = _routers.get(0);
            IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);
            IERC20(path[0]).approve(router, amountIn);
            IUniswapV2Router02(router).swapExactTokensForETHSupportingFeeOnTransferTokens(amountIn, amountOutMin, path, address(this), deadline);
            (bool success,) = payable(msg.sender).call{value: (address(this).balance - balance) * (DEFAULT_PRECISION - _getProviderFeeStorage()) / DEFAULT_PRECISION}("");
            if (!success) revert SwapPayoutFailed();
        }
    }

    function addLiquidity() external payable {
        uint received = _swapNativeForTokens(msg.sender, msg.value / 2);
        address router = _routers.get(0);
        _token.approve(router, received);
        IUniswapV2Router02(router).addLiquidityETH{value: msg.value / 2}(address(_token), received, 0, 0, address(this), block.timestamp + 1);
    }

    /// @notice forward receive calls
    fallback() external payable virtual  {
        if(!_getFlags(msg.sender).all(_ROUTER_FLAG())) _forward(msg.value);
    }

    /// @notice forward any call that doesn't exist in this contract to the router
    function _forward(uint value_) internal {
        address router = _routers.get(0);
        assembly("memory-safe") {
            calldatacopy(0, 0, calldatasize())
            let result := call(gas(), router, value_, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    function _authorizeUpgrade(address newImplementation) internal virtual override requires(msg.sender, _ADMIN_FLAG(), 0) {}

}