// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

interface IWeth {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IWormholeCore {
    function publishMessage(
        uint32 nonce,
        bytes memory payload,
        uint8 consistencyLevel
    ) external payable returns (uint64 sequence);

    function parseAndVerifyVM(bytes calldata encodedVM)
        external
        view
        returns (
            IWormholeCore.VM memory vm,
            bool valid,
            string memory reason
        );

    struct Signature {
        bytes32 r;
        bytes32 s;
        uint8 v;
        uint8 guardianIndex;
    }

    struct VM {
        uint8 version;
        uint32 timestamp;
        uint32 nonce;
        uint16 emitterChainId;
        bytes32 emitterAddress;
        uint64 sequence;
        uint8 consistencyLevel;
        bytes payload;
        uint32 guardianSetIndex;
        Signature[] signatures;
        bytes32 hash;
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IWeth.sol";

error AssetNotReceived();
error TransferFromFailed();
error TransferFailed();
error ApprovalFailed();

library LibAsset {
    using LibAsset for address;

    address constant NATIVE_ASSETID = address(0);

    function isNative(address self) internal pure returns (bool) {
        return self == NATIVE_ASSETID;
    }

    function getBalance(address self) internal view returns (uint256) {
        return
            self.isNative()
                ? address(this).balance
                : IERC20(self).balanceOf(address(this));
    }

    function transferFrom(
        address self,
        address from,
        address to,
        uint256 amount
    ) internal {
        IERC20 token = IERC20(self);
        bytes4 selector = token.transferFrom.selector;
        bool isSuccessful;
        assembly {
            let data := mload(0x40)

            mstore(data, selector)
            mstore(add(data, 0x04), from)
            mstore(add(data, 0x24), to)
            mstore(add(data, 0x44), amount)
            isSuccessful := call(gas(), token, 0, data, 100, 0x0, 0x20)
            if isSuccessful {
                switch returndatasize()
                case 0 {
                    isSuccessful := gt(extcodesize(token), 0)
                }
                default {
                    isSuccessful := and(
                        gt(returndatasize(), 31),
                        eq(mload(0), 1)
                    )
                }
            }
        }
        if (!isSuccessful) {
            revert TransferFromFailed();
        }
    }

    function transfer(
        address self,
        address payable recipient,
        uint256 amount
    ) internal {
        bool isSuccessful;
        if (self.isNative()) {
            (isSuccessful, ) = recipient.call{value: amount}("");
        } else {
            IERC20 token = IERC20(self);
            bytes4 selector = token.transfer.selector;
            assembly {
                let data := mload(0x40)

                mstore(data, selector)
                mstore(add(data, 0x04), recipient)
                mstore(add(data, 0x24), amount)
                isSuccessful := call(gas(), token, 0, data, 0x44, 0x0, 0x20)
                if isSuccessful {
                    switch returndatasize()
                    case 0 {
                        isSuccessful := gt(extcodesize(token), 0)
                    }
                    default {
                        isSuccessful := and(
                            gt(returndatasize(), 31),
                            eq(mload(0), 1)
                        )
                    }
                }
            }
        }

        if (!isSuccessful) {
            revert TransferFailed();
        }
    }

    function approve(
        address self,
        address spender,
        uint256 amount
    ) internal {
        bool isSuccessful = IERC20(self).approve(spender, amount);
        if (!isSuccessful) {
            revert ApprovalFailed();
        }
    }

    function getAllowance(
        address self,
        address owner,
        address spender
    ) internal view returns (uint256) {
        return IERC20(self).allowance(owner, spender);
    }

    function deposit(address self, uint256 amount) internal {
        self.transferFrom(msg.sender, address(this), amount);
    }

    function withdraw(
        address self,
        address to,
        uint256 amount
    ) internal {
        self.transfer(payable(to), amount);
    }

    function getDecimals(address self)
        internal
        view
        returns (uint8 tokenDecimals)
    {
        tokenDecimals = 18;

        if (!self.isNative()) {
            (, bytes memory queriedDecimals) = self.staticcall(
                abi.encodeWithSignature("decimals()")
            );
            tokenDecimals = abi.decode(queriedDecimals, (uint8));
        }
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

library LibBytes {
    using LibBytes for bytes;

    function toAddress(bytes memory self, uint256 start)
        internal
        pure
        returns (address)
    {
        return address(uint160(uint256(self.toBytes32(start))));
    }

    function toBool(bytes memory self, uint256 start)
        internal
        pure
        returns (bool)
    {
        return self.toUint8(start) == 1 ? true : false;
    }

    function toUint8(bytes memory self, uint256 start)
        internal
        pure
        returns (uint8)
    {
        require(self.length >= start + 1, "LibBytes: toUint8 outOfBounds");
        uint8 tempUint;

        assembly {
            tempUint := mload(add(add(self, 0x1), start))
        }

        return tempUint;
    }

    function toUint16(bytes memory self, uint256 start)
        internal
        pure
        returns (uint16)
    {
        require(self.length >= start + 2, "LibBytes: toUint16 outOfBounds");
        uint16 tempUint;

        assembly {
            tempUint := mload(add(add(self, 0x2), start))
        }

        return tempUint;
    }

    function toUint24(bytes memory self, uint256 start)
        internal
        pure
        returns (uint24)
    {
        require(self.length >= start + 3, "LibBytes: toUint24 outOfBounds");
        uint24 tempUint;

        assembly {
            tempUint := mload(add(add(self, 0x3), start))
        }

        return tempUint;
    }

    function toUint64(bytes memory self, uint256 start)
        internal
        pure
        returns (uint64)
    {
        require(self.length >= start + 8, "LibBytes: toUint64 outOfBounds");
        uint64 tempUint;

        assembly {
            tempUint := mload(add(add(self, 0x8), start))
        }

        return tempUint;
    }

    function toUint256(bytes memory self, uint256 start)
        internal
        pure
        returns (uint256)
    {
        require(self.length >= start + 32, "LibBytes: toUint256 outOfBounds");
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(self, 0x20), start))
        }

        return tempUint;
    }

    function toBytes32(bytes memory self, uint256 start)
        internal
        pure
        returns (bytes32)
    {
        require(self.length >= start + 32, "LibBytes: toBytes32 outOfBounds");
        bytes32 tempBytes32;

        assembly {
            tempBytes32 := mload(add(add(self, 0x20), start))
        }

        return tempBytes32;
    }

    function toString(bytes memory self, uint256 start)
        internal
        pure
        returns (string memory)
    {
        return string(abi.encode(self.toBytes32(start)));
    }

    function parseDepositInfo(bytes memory self)
        internal
        pure
        returns (
            address senderAddress,
            uint256 chainId,
            uint256 amount,
            string memory symbol
        )
    {
        uint256 i = 0;

        senderAddress = self.toAddress(i);
        i += 32;
        chainId = self.toUint256(i);
        i += 32;
        amount = self.toUint256(i);
        i += 32;
        symbol = self.toString(i);
        i += 32;
    }

    function parseSwapInfo(bytes memory self)
        internal
        pure
        returns (
            address senderAddress,
            address destinationAssetAddress,
            uint256 swappingChain,
            uint256 amountIn,
            uint256 amountOutMin,
            string memory symbol
        )
    {
        uint256 i = 0;

        senderAddress = self.toAddress(i);
        i += 32;

        destinationAssetAddress = self.toAddress(i);
        i += 32;

        swappingChain = self.toUint256(i);
        i += 32;

        amountIn = self.toUint256(i);
        i += 32;

        amountOutMin = self.toUint256(i);
        i += 32;

        symbol = self.toString(i);
        i += 32;
    }

    function parseSwappedInfo(bytes memory self)
        internal
        pure
        returns (
            address senderAddress,
            uint256 swappingChain,
            uint256 amountIn,
            address destinationAssetAddress,
            uint256 amountOut,
            string memory symbol
        )
    {
        uint256 i = 0;
        senderAddress = self.toAddress(i);
        i += 32;
        swappingChain = self.toUint256(i);
        i += 32;
        amountIn = self.toUint256(i);
        i += 32;
        destinationAssetAddress = self.toAddress(i);
        i += 32;
        amountOut = self.toUint256(i);
        i += 32;
        symbol = self.toString(i);
        i += 32;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IWormholeCore.sol";
import "./lib/LibBytes.sol";
import "./lib/LibAsset.sol";

contract Phoenix is Ownable {
    using LibAsset for address;
    using LibBytes for bytes;

    mapping(uint256 => mapping(address => string)) public mappedList;
    mapping(address => bool) public isTokenListed;
    mapping(address => mapping(bytes32 => uint256)) public internalBalances;
    mapping(uint256 => mapping(bytes32 => uint8)) public retrieveDecimals;
    mapping(uint256 => mapping(bytes32 => address)) public retrieveAddresses;
    mapping(uint256 => mapping(address => uint8)) public unlistedTokensDecimal;

    /*
    convert amount to 18 decimals */

    address public coreAddress;
    uint8 public consistencyLevel;

    constructor(address _coreAddress, uint8 _consistencyLevel) {
        coreAddress = _coreAddress;
        consistencyLevel = _consistencyLevel;
    }

    function listedToken(address tokenAddress) external view returns (bool) {
        if (isTokenListed[tokenAddress]) {
            return true;
        } else {
            return false;
        }
    }

    function listTokens(
        uint256 chainId,
        uint8 decimal,
        address tokenAddress,
        string memory symbolStr
    ) public onlyOwner {
        require(!isTokenListed[tokenAddress], "Phoenix: token already listed");

        mappedList[chainId][tokenAddress] = symbolStr;
        isTokenListed[tokenAddress] = true;

        bytes32 symbol = bytes32(bytes(symbolStr));
        retrieveDecimals[chainId][symbol] = decimal;
        retrieveAddresses[chainId][symbol] = tokenAddress;
    }

    function getVM(bytes memory encodedVm)
        private
        view
        returns (IWormholeCore.VM memory)
    {
        (
            IWormholeCore.VM memory vm,
            bool valid,
            string memory reason
        ) = IWormholeCore(coreAddress).parseAndVerifyVM(encodedVm);
        require(valid, reason);

        return vm;
    }

    function getDepositPayload(bytes memory encodedVm)
        public
        view
        returns (
            address senderAddress,
            uint256 chainId,
            uint256 amount,
            string memory symbol,
            uint64 sequence
        )
    {
        IWormholeCore.VM memory vm = getVM(encodedVm);

        sequence = vm.sequence;
        (senderAddress, chainId, amount, symbol) = vm
            .payload
            .parseDepositInfo();
    }

    function normalize(
        uint8 fromDecimals,
        uint8 toDecimals,
        uint256 amount
    ) private pure returns (uint256 amountOut) {
        uint256 exponent;

        exponent = fromDecimals - toDecimals;
        amountOut = amount / 10**exponent;
    }

    function denormalize(
        uint8 fromDecimals,
        uint8 toDecimals,
        uint256 amount
    ) private pure returns (uint256 amountOut) {
        uint256 exponent;

        exponent = toDecimals - fromDecimals;
        amountOut = amount * 10**exponent;
    }

    function adjustAssetDecimals(
        uint8 fromDecimals,
        uint8 toDecimals,
        uint256 amountIn
    ) public pure returns (uint256 amount) {
        if (fromDecimals > toDecimals) {
            amount = normalize(fromDecimals, toDecimals, amountIn);
        } else {
            amount = denormalize(fromDecimals, toDecimals, amountIn);
        }
    }

    function updateDepositBalance(bytes memory data)
        external
        returns (address, bytes32)
    {
        (
            address senderAddress,
            uint256 chainId,
            uint256 amount,
            string memory symbolStr,
            uint64 sequence
        ) = getDepositPayload(data);

        bytes32 symbol = bytes32(bytes(symbolStr));

        uint256 normalizedAmount = adjustAssetDecimals(
            retrieveDecimals[chainId][symbol],
            18,
            amount
        );
        internalBalances[senderAddress][symbol] += normalizedAmount;

        return (senderAddress, symbol);
    }

    function swapInfo(
        string memory symbolStr,
        address[] memory destinationAssetAddress,
        uint256[] memory swappingChain,
        uint256[] memory amountIn,
        uint256[] memory amountOutMin
    ) external returns (uint64[] memory coreSequence) {
        for (uint256 i = 0; i < amountIn.length; i++) {
            require(
                internalBalances[msg.sender][bytes32(bytes(symbolStr))] <=
                    amountIn[i],
                "Phoenix: insufficient swapping amount"
            );

            bytes memory payload = bytes.concat(
                abi.encodePacked(
                    address(this),
                    bytes32(
                        uint256(uint160(address(destinationAssetAddress[i])))
                    ),
                    swappingChain[i]
                ),
                abi.encodePacked(
                    adjustAssetDecimals(
                        18,
                        retrieveDecimals[swappingChain[i]][
                            bytes32(bytes(symbolStr))
                        ],
                        amountIn[i]
                    ),
                    amountOutMin[i]
                ),
                abi.encodePacked(bytes32(bytes(symbolStr)))
            );
            coreSequence[i] = IWormholeCore(coreAddress).publishMessage(
                uint32(block.timestamp % 2**32),
                payload,
                consistencyLevel
            );
        }
    }

    function parseSwappedInfo(bytes memory data) external {
        (
            address senderAddress,
            uint256 swappingChain,
            uint256 amountIn,
            address destinationAssetAddress,
            uint256 amountOut,
            string memory sourceSymbolStr
        ) = LibBytes.parseSwappedInfo(data);

        string memory destinationSymbolStr = mappedList[swappingChain][
            destinationAssetAddress
        ];
        bytes32 sourceSymbol = bytes32(bytes(sourceSymbolStr));
        bytes32 destinationSymbol = bytes32(bytes(destinationSymbolStr));

        internalBalances[senderAddress][sourceSymbol] -= amountIn;
        internalBalances[senderAddress][destinationSymbol] += amountOut;
    }
}