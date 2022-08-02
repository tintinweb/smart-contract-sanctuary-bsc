// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/IMagpieCore.sol";
import "./interfaces/IMagpieRouter.sol";
import "./lib/LibUint256Array.sol";
import "./lib/LibAddressArray.sol";
import "./MagpieBridge.sol";
import "./security/Pausable.sol";

contract MagpieCore is
    ReentrancyGuard,
    Ownable,
    Pausable,
    MagpieBridge,
    IMagpieCore
{
    using LibAsset for address;
    using LibBytes for bytes;
    using LibSwap for IMagpieRouter.SwapArgs;
    using LibUint256Array for uint256[];
    using LibAddressArray for address[];

    mapping(address => uint256) public gasFeeAccumulatedByToken;
    mapping(address => mapping(address => uint256)) public gasFeeAccumulated;
    mapping(uint8 => mapping(uint64 => uint256)) public hyphenAmountIns;
    mapping(uint8 => mapping(uint64 => bool)) public sequences;
    Config public config;

    constructor(Config memory _config)
        Pausable(_config.pauserAddress)
        MagpieBridge(
            _config.hyphenLiquidityPoolAddress,
            _config.tokenBridgeAddress,
            _config.coreBridgeAddress,
            _config.relayerAddress,
            _config.hyphenBaseDivisor,
            _config.consistencyLevel,
            _config.networkId
        )
    {
        config = _config;
    }

    modifier ensure(uint256 deadline) {
        require(deadline >= block.timestamp, "MagpieCore: expired transaction");
        _;
    }

    function updateConfig(Config calldata _config) external override onlyOwner {
        require(_config.weth != address(0), "MagpieCore: invalid weth");
        require(
            _config.hyphenLiquidityPoolAddress != address(0),
            "MagpieCore: invalid hyphenLiquidityPoolAddress"
        );
        require(
            _config.coreBridgeAddress != address(0),
            "MagpieCore: invalid coreBridgeAddress"
        );
        require(
            _config.consistencyLevel > 1,
            "MagpieCore: invalid consistencyLevel"
        );

        config = _config;

        emit ConfigUpdated(config, msg.sender);
    }

    function _prepareAsset(
        IMagpieRouter.SwapArgs memory swapArgs,
        address assetAddress,
        bool wrap
    ) private returns (IMagpieRouter.SwapArgs memory newSwapArgs) {
        uint256 amountIn = swapArgs.getAmountIn();

        if (wrap) {
            IWETH(config.weth).deposit{value: amountIn}();
        }

        for (uint256 i = 0; i < swapArgs.assets.length; i++) {
            if (assetAddress == swapArgs.assets[i]) {
                swapArgs.assets[i] = config.weth;
            }
        }

        newSwapArgs = swapArgs;
    }

    function _getWrapSwapConfig(
        IMagpieRouter.SwapArgs memory swapArgs,
        bool transferFromSender
    ) private view returns (WrapSwapConfig memory wrapSwapConfig) {
        address fromAssetAddress = swapArgs.getFromAssetAddress();
        address toAssetAddress = swapArgs.getToAssetAddress();
        if (fromAssetAddress.isNative() && toAssetAddress == config.weth) {
            wrapSwapConfig.prepareFromAsset = true;
            wrapSwapConfig.prepareToAsset = false;
            wrapSwapConfig.swap = false;
            wrapSwapConfig.unwrapToAsset = false;
        } else if (
            fromAssetAddress == config.weth && toAssetAddress.isNative()
        ) {
            wrapSwapConfig.prepareFromAsset = false;
            wrapSwapConfig.prepareToAsset = false;
            wrapSwapConfig.swap = false;
            wrapSwapConfig.unwrapToAsset = true;
        } else if (fromAssetAddress == toAssetAddress) {
            wrapSwapConfig.prepareFromAsset = false;
            wrapSwapConfig.prepareToAsset = false;
            wrapSwapConfig.swap = false;
            wrapSwapConfig.unwrapToAsset = false;
        } else {
            wrapSwapConfig.prepareFromAsset = fromAssetAddress.isNative();
            wrapSwapConfig.prepareToAsset = toAssetAddress.isNative();
            wrapSwapConfig.swap = true;
            wrapSwapConfig.unwrapToAsset = toAssetAddress.isNative();
        }
        wrapSwapConfig.transferFromSender =
            !fromAssetAddress.isNative() &&
            transferFromSender;
    }

    function _wrapSwap(
        IMagpieRouter.SwapArgs memory swapArgs,
        WrapSwapConfig memory wrapSwapConfig
    ) private returns (uint256[] memory amountOuts) {
        require(swapArgs.routes.length > 0, "MagpieCore: invalid route size");
        address fromAssetAddress = swapArgs.getFromAssetAddress();
        address toAssetAddress = swapArgs.getToAssetAddress();
        address payable to = swapArgs.to;
        uint256 amountIn = swapArgs.getAmountIn();
        uint256 amountOut = amountIn;

        if (wrapSwapConfig.prepareFromAsset) {
            swapArgs = _prepareAsset(swapArgs, fromAssetAddress, true);
        }

        if (wrapSwapConfig.prepareToAsset) {
            swapArgs = _prepareAsset(swapArgs, toAssetAddress, false);
        }

        if (wrapSwapConfig.transferFromSender) {
            fromAssetAddress.transferFrom(msg.sender, address(this), amountIn);
        }

        if (wrapSwapConfig.swap) {
            fromAssetAddress.transfer(
                payable(config.magpieRouterAddress),
                amountIn
            );
            try
                IMagpieRouter(config.magpieRouterAddress).swap(swapArgs)
            returns (uint256[] memory swapAmountOuts) {
                amountOuts = swapAmountOuts;
                amountOut = amountOuts.sum();
            } catch {
                amountOuts = new uint256[](1);
                amountOut = 0;
                amountOuts[0] = 0;
            }
        } else {
            amountOuts = new uint256[](1);
            amountOuts[0] = amountIn;
        }

        if (wrapSwapConfig.unwrapToAsset && amountOut > 0) {
            IWETH(config.weth).withdraw(amountOut);
        }

        if (to != address(this) && amountOut > 0) {
            toAssetAddress.transfer(to, amountOut);
        }
    }

    receive() external payable {
        require(config.weth == msg.sender, "MagpieCore: invalid sender");
    }

    function swap(IMagpieRouter.SwapArgs calldata swapArgs)
        external
        payable
        ensure(swapArgs.deadline)
        whenNotPaused
        nonReentrant
        returns (uint256[] memory amountOuts)
    {
        WrapSwapConfig memory wrapSwapConfig = _getWrapSwapConfig(
            swapArgs,
            true
        );
        amountOuts = _wrapSwap(swapArgs, wrapSwapConfig);

        emit Swapped(amountOuts);
    }

    function swapIn(SwapInArgs calldata args)
        external
        payable
        override
        ensure(args.swapArgs.deadline)
        whenNotPaused
        nonReentrant
        returns (
            uint256[] memory amountOuts,
            uint64 coreSequence,
            uint64 tokenSequence
        )
    {
        require(
            args.swapArgs.to == address(this),
            "MagpieCore: invalid swapArgs to"
        );

        address toAssetAddress = args.swapArgs.getToAssetAddress();

        require(
            config.senderIntermediaries.includes(toAssetAddress),
            "MagpieCore: invalid toAssetAddress"
        );

        WrapSwapConfig memory wrapSwapConfig = _getWrapSwapConfig(
            args.swapArgs,
            true
        );
        amountOuts = _wrapSwap(args.swapArgs, wrapSwapConfig);

        uint256 amountOut = amountOuts.sum();

        require(
            amountOut > args.payload.swapOutGasFee,
            "MagpieCore: invalid swapOutGasFee"
        );

        (coreSequence, tokenSequence) = bridgeIn(
            args.bridgeType,
            args.payload,
            amountOut,
            toAssetAddress
        );

        emit SwappedIn(
            args,
            amountOuts,
            args.payload.recipientNetworkId,
            coreSequence,
            tokenSequence,
            msg.sender
        );

        return (amountOuts, coreSequence, tokenSequence);
    }

    function swapOut(SwapOutArgs calldata args)
        external
        override
        ensure(args.swapArgs.deadline)
        whenNotPaused
        nonReentrant
        returns (uint256[] memory amountOuts)
    {
        (
            IMagpieBridge.ValidationOutPayload memory payload,
            uint64 coreSequence
        ) = getPayload(args.encodedVmCore);

        require(
            !sequences[payload.senderNetworkId][coreSequence],
            "MagpieCore: already used sequence"
        );

        sequences[payload.senderNetworkId][coreSequence] = true;

        IMagpieRouter.SwapArgs memory swapArgs = args.swapArgs;

        address fromAssetAddress = swapArgs.getFromAssetAddress();
        address toAssetAddress = swapArgs.getToAssetAddress();

        uint256 amountIn = bridgeOut(
            payload,
            coreSequence,
            payload.tokenSequence,
            fromAssetAddress,
            args.encodedVmBridge,
            args.depositHash
        );

        if (
            msg.sender != config.relayerAddress &&
            payload.bridgeType == BridgeType.Hyphen
        ) {
            require(
                hyphenAmountIns[payload.senderNetworkId][coreSequence] > 0,
                "MagpieCore: unable to proceed with the current amount"
            );
            amountIn = hyphenAmountIns[payload.senderNetworkId][coreSequence];
        }

        if (payload.to == msg.sender) {
            payload.swapOutGasFee = 0;
        } else {
            swapArgs.amountOutMin = payload.amountOutMin;
        }

        require(
            swapArgs.getAmountIn() <= amountIn,
            "MagpieCore: invalid amountIn"
        );

        require(
            config.receiverIntermediaries.includes(payload.fromAssetAddress),
            "MagpieCore: fromAssetAddress not supported"
        );

        require(
            payload.fromAssetAddress == fromAssetAddress,
            "MagpieCore: invalid fromAssetAddress"
        );
        require(
            payload.toAssetAddress == toAssetAddress,
            "MagpieCore: invalid toAssetAddress"
        );
        require(
            payload.to == swapArgs.to && payload.to != address(this),
            "MagpieCore: invalid to"
        );
        require(
            payload.recipientCoreAddress == address(this),
            "MagpieCore: invalid recipientCoreAddress"
        );
        require(
            uint256(payload.recipientNetworkId) == config.networkId,
            "MagpieCore: invalid recipientChainId"
        );
        require(
            swapArgs.amountOutMin >= payload.amountOutMin,
            "MagpieCore: invalid amountOutMin"
        );
        require(
            swapArgs.routes[0].amountIn >
                payload.destGasTokenAmount + payload.swapOutGasFee,
            "MagpieCore: invalid amountIn"
        );

        swapArgs.routes[0].amountIn =
            swapArgs.routes[0].amountIn -
            (payload.destGasTokenAmount + payload.swapOutGasFee);

        WrapSwapConfig memory wrapSwapConfig = _getWrapSwapConfig(
            swapArgs,
            false
        );

        amountOuts = _wrapSwap(swapArgs, wrapSwapConfig);

        bool isSwapSuccessful = amountOuts.sum() > 0;

        if (
            msg.sender == config.relayerAddress &&
            payload.bridgeType == BridgeType.Hyphen
        ) {
            uint256 thresholdAmountIn = payload.amountIn -
                (payload.amountIn * 15) /
                100;
            amountIn = swapArgs.getAmountIn();
            require(
                amountIn >= thresholdAmountIn,
                "MagpieCore: unable to proceed with the current amount"
            );
            hyphenAmountIns[payload.senderNetworkId][coreSequence] = amountIn;
        } else {
            require(isSwapSuccessful, "MagpieCore: invalid amountOuts");
        }

        if (payload.swapOutGasFee > 0 && isSwapSuccessful) {
            gasFeeAccumulatedByToken[fromAssetAddress] += payload.swapOutGasFee;
            gasFeeAccumulated[fromAssetAddress][msg.sender] += payload
                .swapOutGasFee;
        }

        if (payload.destGasTokenAmount > 0 && isSwapSuccessful) {
            require(
                args.gasTokenSwapArgs.getAmountIn() ==
                    payload.destGasTokenAmount,
                "MagpieCore: invalid amountIn"
            );
            require(
                args.gasTokenSwapArgs.getFromAssetAddress() ==
                    payload.fromAssetAddress,
                "MagpieCore: invalid fromAssetAddress"
            );
            require(
                args.gasTokenSwapArgs.getToAssetAddress().isNative(),
                "MagpieCore: invalid toAssetAddress"
            );
            require(
                args.gasTokenSwapArgs.to == payable(payload.to),
                "MagpieCore: invalid to"
            );
            require(
                args.gasTokenSwapArgs.amountOutMin >=
                    payload.destGasTokenAmountOutMin,
                "MagpieCore: invalid amountOutMin"
            );
            WrapSwapConfig memory gasWrapSwapConfig = _getWrapSwapConfig(
                args.gasTokenSwapArgs,
                false
            );
            uint256[] memory destGasTokenAmountOuts = _wrapSwap(
                args.gasTokenSwapArgs,
                gasWrapSwapConfig
            );

            require(
                destGasTokenAmountOuts.sum() > 0,
                "MagpieCore: invalid destGasTokenAmountOuts"
            );
        }

        emit SwappedOut(
            args,
            amountOuts,
            payload.senderNetworkId,
            coreSequence,
            msg.sender
        );
    }

    function withdrawGasFee(address tokenAddress)
        external
        whenNotPaused
        nonReentrant
    {
        uint256 _gasFeeAccumulated = gasFeeAccumulated[tokenAddress][
            msg.sender
        ];
        require(_gasFeeAccumulated != 0, "MagpieCore: gas fee earned is 0");
        gasFeeAccumulatedByToken[tokenAddress] =
            gasFeeAccumulatedByToken[tokenAddress] -
            _gasFeeAccumulated;
        gasFeeAccumulated[tokenAddress][msg.sender] = 0;
        tokenAddress.transfer(payable(msg.sender), _gasFeeAccumulated);

        emit GasFeeWithdraw(tokenAddress, msg.sender, _gasFeeAccumulated);
    }
}

// SPDX-License-Identifier: MIT

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
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
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
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0 <0.9.0;

import "./IMagpieRouter.sol";
import "./IMagpieBridge.sol";

interface IMagpieCore {
    struct Config {
        address weth;
        address pauserAddress;
        address relayerAddress;
        address magpieRouterAddress;
        address hyphenLiquidityPoolAddress;
        address tokenBridgeAddress;
        address coreBridgeAddress;
        address[] senderIntermediaries;
        address[] receiverIntermediaries;
        uint256 hyphenBaseDivisor;
        uint8 consistencyLevel;
        uint8 networkId;
    }

    struct SwapInArgs {
        IMagpieRouter.SwapArgs swapArgs;
        IMagpieBridge.ValidationInPayload payload;
        IMagpieBridge.BridgeType bridgeType;
    }

    struct SwapOutArgs {
        IMagpieRouter.SwapArgs swapArgs;
        IMagpieRouter.SwapArgs gasTokenSwapArgs;
        bytes encodedVmBridge;
        bytes encodedVmCore;
        bytes depositHash;
    }

    struct WrapSwapConfig {
        bool transferFromSender;
        bool prepareFromAsset;
        bool prepareToAsset;
        bool unwrapToAsset;
        bool swap;
    }

    function updateConfig(Config calldata config) external;

    function swap(IMagpieRouter.SwapArgs calldata args)
        external
        payable
        returns (uint256[] memory amountOuts);

    function swapIn(SwapInArgs calldata swapArgs)
        external
        payable
        returns (
            uint256[] memory amountOuts,
            uint64,
            uint64
        );

    function swapOut(SwapOutArgs calldata args)
        external
        returns (uint256[] memory amountOuts);

    event ConfigUpdated(Config config, address caller);

    event Swapped(uint256[] amountOuts);

    event SwappedIn(
        SwapInArgs args,
        uint256[] amountOuts,
        uint8 receipientNetworkId,
        uint64 coreSequence,
        uint64 tokenSequence,
        address caller
    );

    event SwappedOut(
        SwapOutArgs args,
        uint256[] amountOuts,
        uint8 senderNetworkId,
        uint64 coreSequence,
        address caller
    );

    event GasFeeWithdraw(
        address indexed tokenAddress,
        address indexed owner,
        uint256 indexed amount
    );
}

// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0 <0.9.0;

interface IMagpieRouter {
    struct Amm {
        address id;
        uint16 index;
        uint8 protocolIndex;
    }

    struct Hop {
        uint16 ammIndex;
        uint8[] path;
        bytes poolData;
    }

    struct Route {
        uint256 amountIn;
        Hop[] hops;
    }

    struct SwapArgs {
        Route[] routes;
        address[] assets;
        address payable to;
        uint256 amountOutMin;
        uint256 deadline;
    }

    function updateAmms(Amm[] calldata amms) external;

    function swap(SwapArgs memory swapArgs) external returns (uint256[] memory amountOuts);

    event AmmsUpdated(Amm[] amms, address caller);
}

// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0 <0.9.0;

library LibUint256Array {
    function sum(uint256[] memory self) internal pure returns (uint256) {
        uint256 amountOut = 0;

        for (uint256 i = 0; i < self.length; i++) {
            amountOut += self[i];
        }

        return amountOut;
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0 <0.9.0;

library LibAddressArray {
    function includes(address[] memory self, address value)
        internal
        pure
        returns (bool)
    {
        for (uint256 i = 0; i < self.length; i++) {
            if (self[i] == value) {
                return true;
            }
        }

        return false;
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0 <0.9.0;

import "./interfaces/IHyphenLiquidityPool.sol";
import "./interfaces/IWormhole.sol";
import "./interfaces/IWormholeCore.sol";
import "./interfaces/IMagpieBridge.sol";
import "./lib/LibAsset.sol";
import "./lib/LibBytes.sol";
import "./lib/LibSwap.sol";

contract MagpieBridge is IMagpieBridge {
    using LibAsset for address;
    using LibBytes for bytes;

    mapping(uint8 => mapping(uint64 => mapping(bytes => DepositHashStatus)))
        private depositHashes;
    address private hyphenLiquidityPoolAddress;
    address private tokenBridgeAddress;
    address private coreBridgeAddress;
    address private relayerAddress;
    uint256 private hyphenBaseDivisor;
    uint8 private consistencyLevel;
    uint8 private networkId;

    constructor(
        address _hyphenLiquidityPoolAddress,
        address _tokenBridgeAddress,
        address _coreBridgeAddress,
        address _relayerAddress,
        uint256 _hyphenBaseDivisor,
        uint8 _consistencyLevel,
        uint8 _networkId
    ) {
        hyphenLiquidityPoolAddress = _hyphenLiquidityPoolAddress;
        tokenBridgeAddress = _tokenBridgeAddress;
        coreBridgeAddress = _coreBridgeAddress;
        relayerAddress = _relayerAddress;
        hyphenBaseDivisor = _hyphenBaseDivisor;
        consistencyLevel = _consistencyLevel;
        networkId = _networkId;
    }

    function deposit(
        BridgeType bridgeType,
        ValidationInPayload memory payload,
        uint256 amount,
        address toAssetAddress
    ) private returns (uint64) {
        if (bridgeType == BridgeType.Wormhole) {
            toAssetAddress.increaseAllowance(tokenBridgeAddress, amount);
            return
                IWormhole(tokenBridgeAddress).transferTokens(
                    toAssetAddress,
                    amount,
                    payload.recipientBridgeChainId,
                    payload.recipientCoreAddress,
                    0,
                    uint32(block.timestamp % 2**32)
                );
        } else {
            if (toAssetAddress.isNative()) {
                IHyphenLiquidityPool(hyphenLiquidityPoolAddress).depositNative{
                    value: amount
                }(
                    address(uint160(uint256(payload.recipientCoreAddress))),
                    payload.recipientChainId,
                    "Magpie"
                );
            } else {
                toAssetAddress.increaseAllowance(
                    hyphenLiquidityPoolAddress,
                    amount
                );
                IHyphenLiquidityPool(hyphenLiquidityPoolAddress).depositErc20(
                    payload.recipientChainId,
                    toAssetAddress,
                    address(uint160(uint256(payload.recipientCoreAddress))),
                    amount,
                    "Magpie"
                );
            }
        }
        return 0;
    }

    function bridgeIn(
        BridgeType bridgeType,
        ValidationInPayload memory payload,
        uint256 amount,
        address toAssetAddress
    ) internal returns (uint64 coreSequence, uint64 tokenSequence) {
        tokenSequence = deposit(bridgeType, payload, amount, toAssetAddress);
        uint8 senderIntermediaryDecimals = 18;

        if (!toAssetAddress.isNative()) {
            (, bytes memory queriedDecimals) = toAssetAddress.staticcall(
                abi.encodeWithSignature("decimals()")
            );
            senderIntermediaryDecimals = abi.decode(queriedDecimals, (uint8));
        }

        bytes memory payloadOut = bytes.concat(
            abi.encodePacked(
                payload.fromAssetAddress,
                payload.toAssetAddress,
                payload.to,
                payload.recipientCoreAddress,
                payload.amountOutMin
            ),
            abi.encodePacked(
                payload.swapOutGasFee,
                payload.destGasTokenAmount,
                payload.destGasTokenAmountOutMin,
                amount,
                tokenSequence,
                senderIntermediaryDecimals
            ),
            abi.encodePacked(networkId, payload.recipientNetworkId, bridgeType)
        );

        coreSequence = IWormholeCore(coreBridgeAddress).publishMessage(
            uint32(block.timestamp % 2**32),
            payloadOut,
            consistencyLevel
        );
    }

    function getPayload(bytes memory encodedVm)
        public
        view
        returns (ValidationOutPayload memory payload, uint64 sequence)
    {
        IWormholeCore.VM memory vm = getVM(encodedVm);

        sequence = vm.sequence;
        payload = vm.payload.parse();
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
        ) = IWormholeCore(coreBridgeAddress).parseAndVerifyVM(encodedVm);
        require(valid, reason);

        return vm;
    }

    function bridgeOut(
        ValidationOutPayload memory payload,
        uint64 coreSequence,
        uint64 tokenSequence,
        address assetAddress,
        bytes memory encodedVmBridge,
        bytes memory depositHash
    ) internal returns (uint256 amount) {
        uint8 receiverIntermediaryDecimals = 18;

        if (!assetAddress.isNative()) {
            (, bytes memory queriedDecimals) = assetAddress.staticcall(
                abi.encodeWithSignature("decimals()")
            );
            receiverIntermediaryDecimals = abi.decode(queriedDecimals, (uint8));
        }

        amount = normalize(
            payload.senderIntermediaryDecimals,
            receiverIntermediaryDecimals,
            payload.amountIn
        );

        if (payload.bridgeType == BridgeType.Wormhole) {
            IWormholeCore.VM memory vm = getVM(encodedVmBridge);
            require(
                tokenSequence == vm.sequence,
                "MagpieBridge: invalid tokenSequence"
            );
            IWormhole(tokenBridgeAddress).completeTransfer(encodedVmBridge);
        } else {
            if (msg.sender == relayerAddress) {
                require(
                    depositHashes[payload.senderNetworkId][coreSequence][
                        depositHash
                    ] == DepositHashStatus.Pending,
                    "MagpieBridge: invalid depositHash"
                );
                (, bool status) = IHyphenLiquidityPool(
                    hyphenLiquidityPoolAddress
                ).checkHashStatus(
                        payload.fromAssetAddress,
                        amount,
                        payload.recipientCoreAddress,
                        depositHash
                    );
                require(status, "MagpieBridge: depositHash not processed");

                depositHashes[payload.senderNetworkId][coreSequence][
                    depositHash
                ] = DepositHashStatus.Approved;
            } else {
                require(
                    depositHashes[payload.senderNetworkId][coreSequence][
                        depositHash
                    ] == DepositHashStatus.Approved,
                    "MagpieBridge: invalid depositHash"
                );
                depositHashes[payload.senderNetworkId][coreSequence][
                    depositHash
                ] = DepositHashStatus.Successful;
            }
        }
    }

    function normalize(
        uint8 senderDecimals,
        uint8 receiverDecimals,
        uint256 amount
    ) private pure returns (uint256 amountOut) {
        uint256 exponent;
        if (senderDecimals > receiverDecimals) {
            exponent = senderDecimals - receiverDecimals;
            amountOut = amount / 10**exponent;
        } else {
            exponent = receiverDecimals - senderDecimals;
            amountOut = amount * 10**exponent;
        }
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0 <0.9.0;

import {Pausable as OpenZeppelinPausable} from '@openzeppelin/contracts/security/Pausable.sol';

contract Pausable is OpenZeppelinPausable {
  address private _pauser;

  event PauserChanged(address indexed previousPauser, address indexed newPauser);

  constructor (address pauser) {
    require(pauser != address(0), 'Pauser Address cannot be 0');
    _pauser = pauser;
  }

  function isPauser(address pauser) public view returns (bool) {
    return pauser == _pauser;
  }

  modifier onlyPauser() {
    require(isPauser(msg.sender), 'Only pauser is allowed to perform this operation');
    _;
  }

  function changePauser(address newPauser) public onlyPauser {
    _changePauser(newPauser);
  }

  function _changePauser(address newPauser) internal {
    require(newPauser != address(0));
    emit PauserChanged(_pauser, newPauser);
    _pauser = newPauser;
  }

  function renouncePauser() external virtual onlyPauser {
    emit PauserChanged(_pauser, address(0));
    _pauser = address(0);
  }

  function pause() public onlyPauser {
    _pause();
  }

  function unpause() public onlyPauser {
    _unpause();
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
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
pragma solidity >=0.8.0 <0.9.0;

interface IMagpieBridge {
    enum BridgeType {
        Wormhole,
        Hyphen
    }

    enum DepositHashStatus {
      Pending,
      Approved,
      Successful
    }

    struct ValidationInPayload {
        bytes32 fromAssetAddress;
        bytes32 toAssetAddress;
        bytes32 to;
        uint256 amountOutMin;
        bytes32 recipientCoreAddress;
        uint256 recipientChainId;
        uint16 recipientBridgeChainId;
        uint256 swapOutGasFee;
        uint256 destGasTokenAmount;
        uint256 destGasTokenAmountOutMin;
        uint8 recipientNetworkId;
    }

    struct ValidationOutPayload {
        address fromAssetAddress;
        address toAssetAddress;
        address to;
        address recipientCoreAddress;
        uint256 amountOutMin;
        uint256 swapOutGasFee;
        uint256 destGasTokenAmount;
        uint256 destGasTokenAmountOutMin;
        uint256 amountIn;
        uint64 tokenSequence;
        uint8 senderIntermediaryDecimals;
        uint8 senderNetworkId;
        uint8 recipientNetworkId;
        BridgeType bridgeType;
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0 <0.9.0;

interface IHyphenLiquidityPool {
    function checkHashStatus(
        address tokenAddress,
        uint256 amount,
        address receiver,
        bytes memory depositHash
    ) external view returns (bytes32 hashSendTransaction, bool status);

    function depositErc20(
        uint256 toChainId,
        address tokenAddress,
        address receiver,
        uint256 amount,
        string memory tag
    ) external;

    function depositNative(
        address receiver,
        uint256 toChainId,
        string memory tag
    ) external payable;

    function getRewardAmount(uint256 amount, address tokenAddress)
        external
        view
        returns (uint256 rewardAmount);

    function getTransferFee(address tokenAddress, uint256 amount)
        external
        view
        returns (uint256 fee);

    function incentivePool(address) external view returns (uint256);
}

// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0 <0.9.0;

interface IWormhole {
    function transferTokens(
        address token,
        uint256 amount,
        uint16 recipientChain,
        bytes32 recipient,
        uint256 arbiterFee,
        uint32 nonce
    ) external payable returns (uint64 sequence);

    function wrapAndTransferETH(
        uint16 recipientChain,
        bytes32 recipient,
        uint256 arbiterFee,
        uint32 nonce
    ) external payable returns (uint64 sequence);

    function completeTransfer(bytes memory encodedVm) external;
}

// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0 <0.9.0;

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
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

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
        SafeERC20.safeTransferFrom(IERC20(self), from, to, amount);
    }

    function increaseAllowance(
        address self,
        address spender,
        uint256 amount
    ) internal {
        require(
            !self.isNative(),
            "LibAsset: Allowance can't be increased for native asset"
        );
        SafeERC20.safeIncreaseAllowance(IERC20(self), spender, amount);
    }

    function decreaseAllowance(
        address self,
        address spender,
        uint256 amount
    ) internal {
        require(
            !self.isNative(),
            "LibAsset: Allowance can't be decreased for native asset"
        );
        SafeERC20.safeDecreaseAllowance(IERC20(self), spender, amount);
    }

    function transfer(
        address self,
        address payable recipient,
        uint256 amount
    ) internal {
        self.isNative()
            ? Address.sendValue(recipient, amount)
            : SafeERC20.safeTransfer(IERC20(self), recipient, amount);
    }

    function approve(
        address self,
        address spender,
        uint256 amount
    ) internal {
        require(
            !self.isNative(),
            "LibAsset: Allowance can't be increased for native asset"
        );
        SafeERC20.safeApprove(IERC20(self), spender, amount);
    }

    function getAllowance(
        address self,
        address owner,
        address spender
    ) internal view returns (uint256) {
        return IERC20(self).allowance(owner, spender);
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0 <0.9.0;
import "../interfaces/IMagpieBridge.sol";

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

    function toBridgeType(bytes memory self, uint256 start)
        internal
        pure
        returns (IMagpieBridge.BridgeType)
    {
        return self.toUint8(start) == 0 ? IMagpieBridge.BridgeType.Wormhole : IMagpieBridge.BridgeType.Hyphen;
    }

    function parse(bytes memory self)
        internal
        pure
        returns (IMagpieBridge.ValidationOutPayload memory payload)
    {
        uint256 i = 0;

        payload.fromAssetAddress = self.toAddress(i);
        i += 32;

        payload.toAssetAddress = self.toAddress(i);
        i += 32;

        payload.to = self.toAddress(i);
        i += 32;

        payload.recipientCoreAddress = self.toAddress(i);
        i += 32;

        payload.amountOutMin = self.toUint256(i);
        i += 32;

        payload.swapOutGasFee = self.toUint256(i);
        i += 32;

        payload.destGasTokenAmount = self.toUint256(i);
        i += 32;

        payload.destGasTokenAmountOutMin = self.toUint256(i);
        i += 32;

        payload.amountIn = self.toUint256(i);
        i += 32;

        payload.tokenSequence = self.toUint64(i);
        i += 8;

        payload.senderIntermediaryDecimals = self.toUint8(i);
        i += 1;

        payload.senderNetworkId = self.toUint8(i);
        i += 1;

        payload.recipientNetworkId = self.toUint8(i);
        i += 1;

        payload.bridgeType = self.toBridgeType(i);
        i += 1;

        
        require(self.length == i, "LibBytes: payload is invalid");
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0 <0.9.0;

import "../interfaces/IMagpieCore.sol";
import "../interfaces/IMagpieRouter.sol";
import "../interfaces/IWETH.sol";
import "./LibAsset.sol";

library LibSwap {
    using LibAsset for address;
    using LibSwap for IMagpieRouter.SwapArgs;

    function getFromAssetAddress(IMagpieRouter.SwapArgs memory self)
        internal
        pure
        returns (address)
    {
        return self.assets[self.routes[0].hops[0].path[0]];
    }

    function getToAssetAddress(IMagpieRouter.SwapArgs memory self)
        internal
        pure
        returns (address)
    {
        IMagpieRouter.Hop memory hop = self.routes[0].hops[
            self.routes[0].hops.length - 1
        ];
        return self.assets[hop.path[hop.path.length - 1]];
    }

    function getAmountIn(IMagpieRouter.SwapArgs memory self)
        internal
        pure
        returns (uint256)
    {
        uint256 amountIn = 0;

        for (uint256 i = 0; i < self.routes.length; i++) {
            amountIn += self.routes[i].amountIn;
        }

        return amountIn;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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

// SPDX-License-Identifier: MIT

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

// SPDX-License-Identifier: Unlicense
pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}