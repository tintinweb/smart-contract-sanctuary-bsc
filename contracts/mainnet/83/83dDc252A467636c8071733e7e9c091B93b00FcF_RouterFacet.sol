// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

import {LibDiamond} from "../../diamond/LibDiamond.sol";
import {Amm, AppStorage} from "../../libraries/LibMagpieAggregator.sol";
import {IRouter} from "../interfaces/IRouter.sol";
import {LibCurve} from "../LibCurve.sol";
import {LibRouter} from "../LibRouter.sol";

contract RouterFacet is IRouter {
    AppStorage internal s;

    function addAmm(uint16 ammId, Amm calldata amm) external override {
        LibDiamond.enforceIsContractOwner();
        LibRouter.addAmm(ammId, amm);
    }

    function removeAmm(uint16 ammId) external override {
        LibDiamond.enforceIsContractOwner();
        LibRouter.removeAmm(ammId);
    }

    function addAmms(uint16[] calldata ammIds, Amm[] calldata amms) external override {
        LibDiamond.enforceIsContractOwner();
        LibRouter.addAmms(ammIds, amms);
    }

    function updateCurveSettings(address addressProvider) external override {
        LibDiamond.enforceIsContractOwner();
        LibCurve.updateSettings(addressProvider);
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

import {IDiamondCut} from "./interfaces/IDiamondCut.sol";
import "../libraries/LibError.sol";

library LibDiamond {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    struct FacetAddressAndPosition {
        address facetAddress;
        uint96 functionSelectorPosition; // position in facetFunctionSelectors.functionSelectors array
    }

    struct FacetFunctionSelectors {
        bytes4[] functionSelectors;
        uint256 facetAddressPosition; // position of facetAddress in facetAddresses array
    }

    struct DiamondStorage {
        // maps function selector to the facet address and
        // the position of the selector in the facetFunctionSelectors.selectors array
        mapping(bytes4 => FacetAddressAndPosition) selectorToFacetAndPosition;
        // maps facet addresses to function selectors
        mapping(address => FacetFunctionSelectors) facetFunctionSelectors;
        // facet addresses
        address[] facetAddresses;
        // Used to query if a contract implements an interface.
        // Used to implement ERC-165.
        mapping(bytes4 => bool) supportedInterfaces;
        // owner of the contract
        address contractOwner;
    }

    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function setContractOwner(address _newOwner) internal {
        DiamondStorage storage ds = diamondStorage();
        address previousOwner = ds.contractOwner;
        ds.contractOwner = _newOwner;
        emit OwnershipTransferred(previousOwner, _newOwner);
    }

    function contractOwner() internal view returns (address contractOwner_) {
        contractOwner_ = diamondStorage().contractOwner;
    }

    function enforceIsContractOwner() internal view {
        if (msg.sender != diamondStorage().contractOwner) {
            revert InvalidSender();
        }
    }

    event DiamondCut(IDiamondCut.FacetCut[] _diamondCut, address _init, bytes _calldata);

    // Internal function version of diamondCut
    function diamondCut(
        IDiamondCut.FacetCut[] memory _diamondCut,
        address _init,
        bytes memory _calldata
    ) internal {
        for (uint256 facetIndex; facetIndex < _diamondCut.length; facetIndex++) {
            IDiamondCut.FacetCutAction action = _diamondCut[facetIndex].action;
            if (action == IDiamondCut.FacetCutAction.Add) {
                addFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].functionSelectors);
            } else if (action == IDiamondCut.FacetCutAction.Replace) {
                replaceFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].functionSelectors);
            } else if (action == IDiamondCut.FacetCutAction.Remove) {
                removeFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].functionSelectors);
            } else {
                revert("LibDiamondCut: Incorrect FacetCutAction");
            }
        }
        emit DiamondCut(_diamondCut, _init, _calldata);
        initializeDiamondCut(_init, _calldata);
    }

    function addFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
        if (_functionSelectors.length == 0) {
            revert NoSelectorsToCut();
        }
        DiamondStorage storage ds = diamondStorage();
        if (_facetAddress == address(0)) {
            revert InvalidFacetAddress();
        }
        uint96 selectorPosition = uint96(ds.facetFunctionSelectors[_facetAddress].functionSelectors.length);
        // add new facet address if it does not exist
        if (selectorPosition == 0) {
            addFacet(ds, _facetAddress);
        }
        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds.selectorToFacetAndPosition[selector].facetAddress;
            if (oldFacetAddress != address(0)) {
                revert FunctionAlreadyExists();
            }
            addFunction(ds, selector, selectorPosition, _facetAddress);
            selectorPosition++;
        }
    }

    function replaceFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
        if (_functionSelectors.length == 0) {
            revert InvalidSelectors();
        }
        DiamondStorage storage ds = diamondStorage();
        if (_facetAddress == address(0)) {
            revert InvalidFacetAddress();
        }
        uint96 selectorPosition = uint96(ds.facetFunctionSelectors[_facetAddress].functionSelectors.length);
        // add new facet address if it does not exist
        if (selectorPosition == 0) {
            addFacet(ds, _facetAddress);
        }
        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds.selectorToFacetAndPosition[selector].facetAddress;
            if (oldFacetAddress == _facetAddress) {
                revert FunctionAlreadyExists();
            }
            removeFunction(ds, oldFacetAddress, selector);
            addFunction(ds, selector, selectorPosition, _facetAddress);
            selectorPosition++;
        }
    }

    function removeFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
        if (_functionSelectors.length == 0) {
            revert InvalidSelectors();
        }
        DiamondStorage storage ds = diamondStorage();
        // if function does not exist then do nothing and return
        if (_facetAddress != address(0)) {
            revert InvalidFacetAddress();
        }
        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds.selectorToFacetAndPosition[selector].facetAddress;
            removeFunction(ds, oldFacetAddress, selector);
        }
    }

    function addFacet(DiamondStorage storage ds, address _facetAddress) internal {
        enforceHasContractCode(_facetAddress, "LibDiamondCut: New facet has no code");
        ds.facetFunctionSelectors[_facetAddress].facetAddressPosition = ds.facetAddresses.length;
        ds.facetAddresses.push(_facetAddress);
    }

    function addFunction(
        DiamondStorage storage ds,
        bytes4 _selector,
        uint96 _selectorPosition,
        address _facetAddress
    ) internal {
        ds.selectorToFacetAndPosition[_selector].functionSelectorPosition = _selectorPosition;
        ds.facetFunctionSelectors[_facetAddress].functionSelectors.push(_selector);
        ds.selectorToFacetAndPosition[_selector].facetAddress = _facetAddress;
    }

    function removeFunction(
        DiamondStorage storage ds,
        address _facetAddress,
        bytes4 _selector
    ) internal {
        if (_facetAddress == address(0)) {
            revert FunctionAlreadyExists();
        }
        // an immutable function is a function defined directly in a diamond
        if (_facetAddress == address(this)) {
            revert FunctionIsImmutable();
        }
        // replace selector with last selector, then delete last selector
        uint256 selectorPosition = ds.selectorToFacetAndPosition[_selector].functionSelectorPosition;
        uint256 lastSelectorPosition = ds.facetFunctionSelectors[_facetAddress].functionSelectors.length - 1;
        // if not the same then replace _selector with lastSelector
        if (selectorPosition != lastSelectorPosition) {
            bytes4 lastSelector = ds.facetFunctionSelectors[_facetAddress].functionSelectors[lastSelectorPosition];
            ds.facetFunctionSelectors[_facetAddress].functionSelectors[selectorPosition] = lastSelector;
            ds.selectorToFacetAndPosition[lastSelector].functionSelectorPosition = uint96(selectorPosition);
        }
        // delete the last selector
        ds.facetFunctionSelectors[_facetAddress].functionSelectors.pop();
        delete ds.selectorToFacetAndPosition[_selector];

        // if no more selectors for facet address then delete the facet address
        if (lastSelectorPosition == 0) {
            // replace facet address with last facet address and delete last facet address
            uint256 lastFacetAddressPosition = ds.facetAddresses.length - 1;
            uint256 facetAddressPosition = ds.facetFunctionSelectors[_facetAddress].facetAddressPosition;
            if (facetAddressPosition != lastFacetAddressPosition) {
                address lastFacetAddress = ds.facetAddresses[lastFacetAddressPosition];
                ds.facetAddresses[facetAddressPosition] = lastFacetAddress;
                ds.facetFunctionSelectors[lastFacetAddress].facetAddressPosition = facetAddressPosition;
            }
            ds.facetAddresses.pop();
            delete ds.facetFunctionSelectors[_facetAddress].facetAddressPosition;
        }
    }

    function initializeDiamondCut(address _init, bytes memory _calldata) internal {
        if (_init == address(0)) {
            return;
        }
        enforceHasContractCode(_init, "LibDiamondCut: _init address has no code");
        (bool success, bytes memory error) = _init.delegatecall(_calldata);
        if (!success) {
            if (error.length > 0) {
                // bubble up error
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(error)
                    revert(add(32, error), returndata_size)
                }
            } else {
                revert InitializationFunctionReverted(_init, _calldata);
            }
        }
    }

    function enforceHasContractCode(address _contract, string memory _errorMessage) internal view {
        uint256 contractSize;
        assembly {
            contractSize := extcodesize(_contract)
        }
        require(contractSize > 0, _errorMessage);
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

import {AppStorage, CurveSettings, LibMagpieAggregator} from "../libraries/LibMagpieAggregator.sol";
import {LibAsset} from "../libraries/LibAsset.sol";
import {IAddressProvider} from "../interfaces/curve/IAddressProvider.sol";
import {ICryptoFactory} from "../interfaces/curve/ICryptoFactory.sol";
import {ICryptoPool} from "../interfaces/curve/ICryptoPool.sol";
import {ICryptoRegistry} from "../interfaces/curve/ICryptoRegistry.sol";
import {ICurvePool} from "../interfaces/curve/ICurvePool.sol";
import {IRegistry} from "../interfaces/curve/IRegistry.sol";
import {LibRouter, Hop} from "./LibRouter.sol";

struct ExchangeArgs {
    address pool;
    address from;
    address to;
    uint256 amount;
}

library LibCurve {
    using LibAsset for address;

    function mainExchange(ExchangeArgs memory exchangeArgs, address registry) private {
        int128 i = 0;
        int128 j = 0;
        bool isUnderlying = false;
        (i, j, isUnderlying) = IRegistry(registry).get_coin_indices(
            exchangeArgs.pool,
            exchangeArgs.from,
            exchangeArgs.to
        );

        if (isUnderlying) {
            ICurvePool(exchangeArgs.pool).exchange_underlying(i, j, exchangeArgs.amount, 0);
        } else {
            ICurvePool(exchangeArgs.pool).exchange(i, j, exchangeArgs.amount, 0);
        }
    }

    function cryptoExchange(ExchangeArgs memory exchangeArgs, address registry) private {
        uint256 i = 0;
        uint256 j = 0;
        address initial = exchangeArgs.from;
        address target = exchangeArgs.to;

        (i, j) = ICryptoRegistry(registry).get_coin_indices(exchangeArgs.pool, initial, target);

        ICryptoPool(exchangeArgs.pool).exchange(i, j, exchangeArgs.amount, 0);
    }

    function swapCurve(Hop memory h) internal {
        AppStorage storage s = LibMagpieAggregator.getStorage();

        address pool = address(uint160(uint256(h.poolData[0])));

        ExchangeArgs memory exchangeArgs = ExchangeArgs({
            pool: pool,
            from: h.path[0],
            to: h.path[1],
            amount: h.amountIn
        });

        h.path[0].approve(exchangeArgs.pool, h.amountIn);

        if (ICryptoRegistry(s.curveSettings.cryptoRegistry).get_decimals(exchangeArgs.pool)[0] > 0) {
            cryptoExchange(exchangeArgs, s.curveSettings.cryptoRegistry);
            // Some networks dont have cryptoFactory
        } else if (ICryptoFactory(s.curveSettings.cryptoFactory).get_decimals(exchangeArgs.pool)[0] > 0) {
            cryptoExchange(exchangeArgs, s.curveSettings.cryptoFactory);
        } else {
            mainExchange(exchangeArgs, s.curveSettings.mainRegistry);
        }
    }

    event UpdateCurveSettings(address indexed sender, CurveSettings curveSettings);

    function updateSettings(address addressProvider) internal {
        AppStorage storage s = LibMagpieAggregator.getStorage();

        s.curveSettings = CurveSettings({
            mainRegistry: IAddressProvider(addressProvider).get_address(0),
            cryptoRegistry: IAddressProvider(addressProvider).get_address(5),
            cryptoFactory: IAddressProvider(addressProvider).get_address(6)
        });

        emit UpdateCurveSettings(msg.sender, s.curveSettings);
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

import {BridgeType} from "../bridge/LibBridge.sol";
import {DataTransferType} from "../data-transfer/LibDataTransfer.sol";

struct CurveSettings {
    address mainRegistry;
    address cryptoRegistry;
    address cryptoFactory;
}

struct Amm {
    uint8 protocolId;
    address addr;
}

struct WormholeBridgeSettings {
    address bridgeAddress;
}

struct StargateSettings {
    address routerAddress;
}

struct WormholeSettings {
    address bridgeAddress;
    uint8 consistencyLevel;
}

struct LayerZeroSettings {
    address routerAddress;
}

struct AppStorage {
    address weth;
    uint16 networkId;
    mapping(uint16 => bytes32) magpieAggregatorAddresses;
    mapping(address => uint256) deposits;
    mapping(address => mapping(address => uint256)) depositsByAsset;
    mapping(uint16 => mapping(bytes32 => mapping(uint64 => bool))) usedTransferKeys;
    // Pausable
    bool paused;
    // Reentrancy Guard
    bool guarded;
    // Amm
    mapping(uint16 => Amm) amms;
    // Curve Amm
    CurveSettings curveSettings;
    // Data Transfer
    uint64 coreSequence;
    mapping(uint16 => mapping(uint16 => mapping(bytes32 => mapping(uint64 => bytes)))) payloads;
    // Bridge
    uint64 tokenSequence;
    // Stargate Bridge
    StargateSettings stargateSettings;
    mapping(uint16 => mapping(bytes32 => mapping(uint64 => mapping(address => uint256)))) stargateDeposits;
    // Wormhole Bridge
    WormholeBridgeSettings wormholeBridgeSettings;
    mapping(uint64 => uint64) wormholeTokenSequences;
    // Wormhole Data Transfer
    WormholeSettings wormholeSettings;
    mapping(uint16 => uint16) wormholeNetworkIds;
    mapping(uint64 => uint64) wormholeCoreSequences;
    // LayerZero Data Transfer
    LayerZeroSettings layerZeroSettings;
    mapping(uint16 => uint16) layerZeroChainIds;
    mapping(uint16 => uint16) layerZeroNetworkIds;
}

library LibMagpieAggregator {
    function getStorage() internal pure returns (AppStorage storage s) {
        assembly {
            s.slot := 0
        }
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

import {Amm, AppStorage, LibMagpieAggregator} from "../libraries/LibMagpieAggregator.sol";
import {LibAsset} from "../libraries/LibAsset.sol";
import {LibBytes} from "../libraries/LibBytes.sol";
import {LibUint256Array} from "../libraries/LibUint256Array.sol";
import {LibAggregator} from "../aggregator/LibAggregator.sol";
import {LibBalancerV2} from "./LibBalancerV2.sol";
import {LibCurve} from "./LibCurve.sol";
import {LibDodoV2} from "./LibDodoV2.sol";
import {LibUniswapV2} from "./LibUniswapV2.sol";
import {LibUniswapV3} from "./LibUniswapV3.sol";
import "../libraries/LibError.sol";

struct Hop {
    address addr;
    uint256 amountIn;
    bytes32[] poolData;
    address[] path;
}

struct SwapArgs {
    bytes addresses;
    uint256 amountOutMin;
    uint256[] amountIns;
    bytes32[] poolDataList;
    bytes32[] hops;
    uint256 deadline;
}

struct SwapState {
    uint256 i;
    uint256 lastAmountOut;
    uint256 hopsLength;
    uint256 amountIn;
    uint256 amountInAcc;
    address fromAssetAddress;
    address toAssetAddress;
    address currentFromAssetAddress;
}

library LibRouter {
    using LibAsset for address;
    using LibBytes for bytes;
    using LibUint256Array for uint256[];

    function getHopParams(
        bytes32 data,
        bytes memory addresses,
        bytes32[] memory poolDataList,
        uint256[] memory amountIns
    )
        public
        pure
        returns (
            uint16 ammId,
            uint256 amountIn,
            address[] memory path,
            bytes32[] memory poolData
        )
    {
        uint256 l;

        assembly {
            amountIn := mload(add(amountIns, add(32, mul(shr(248, data), 32))))
            ammId := shr(240, shl(8, data))
            l := shr(248, shl(24, data))
        }

        path = new address[](l);
        poolData = new bytes32[](l);

        assembly {
            let i := 0
            let pathPosition := add(path, 32)
            let poolDataPosition := add(poolData, 32)

            for {

            } lt(i, l) {
                i := add(i, 1)
                pathPosition := add(pathPosition, 32)
                poolDataPosition := add(poolDataPosition, 32)
            } {
                mstore(
                    pathPosition,
                    shr(
                        96,
                        mload(
                            add(
                                add(addresses, 32),
                                mul(
                                    shr(248, shl(mul(add(4, i), 8), data)), /* pathIndex */
                                    20
                                )
                            )
                        )
                    )
                )
                mstore(
                    poolDataPosition,
                    mload(
                        add(
                            add(poolDataList, 32),
                            mul(
                                shr(248, shl(mul(add(8, i), 8), data)), /* poolDataIndex */
                                32
                            )
                        )
                    )
                )
            }
        }
    }

    function swap(SwapArgs memory swapArgs) internal returns (uint256 amountOut) {
        AppStorage storage s = LibMagpieAggregator.getStorage();

        address fromAssetAddress = swapArgs.addresses.toAddress(20);
        address toAssetAddress = swapArgs.addresses.toAddress(40);

        SwapState memory ss = SwapState({
            i: 0,
            lastAmountOut: 0,
            hopsLength: swapArgs.hops.length,
            amountIn: swapArgs.amountIns.sum(),
            amountInAcc: 0,
            fromAssetAddress: fromAssetAddress,
            toAssetAddress: toAssetAddress,
            currentFromAssetAddress: fromAssetAddress
        });

        if (fromAssetAddress.isNative()) {
            ss.fromAssetAddress = s.weth;
            ss.currentFromAssetAddress = s.weth;
        } else if (toAssetAddress.isNative()) {
            ss.toAssetAddress = s.weth;
        } else if (ss.fromAssetAddress == ss.toAssetAddress) {
            revert InvalidFromToAddress();
        }

        Hop memory hop = Hop({addr: address(0), amountIn: 0, poolData: new bytes32[](0), path: new address[](0)});

        if (ss.hopsLength == 0) {
            ss.amountInAcc = ss.amountIn;
            amountOut = ss.amountIn;
        }

        for (ss.i; ss.i < ss.hopsLength; ) {
            uint16 ammId;
            uint256 amountIn;
            (ammId, amountIn, hop.path, hop.poolData) = getHopParams(
                swapArgs.hops[ss.i],
                swapArgs.addresses,
                swapArgs.poolDataList,
                swapArgs.amountIns
            );
            hop.addr = s.amms[ammId].addr;
            hop.amountIn = (ss.currentFromAssetAddress == ss.fromAssetAddress ? amountIn : ss.lastAmountOut);

            if (hop.path[0].isNative()) {
                hop.path[0] = s.weth;
            } else if (hop.path[hop.path.length - 1].isNative()) {
                hop.path[hop.path.length - 1] = s.weth;
            }

            if (ss.currentFromAssetAddress != hop.path[0]) {
                revert InvalidPath();
            }

            address hopToAssetAddress = hop.path[hop.path.length - 1];

            if (ss.currentFromAssetAddress == ss.fromAssetAddress) {
                ss.amountInAcc += hop.amountIn;
            }

            if (s.amms[ammId].protocolId == 1) {
                LibUniswapV2.swapUniswapV2(hop);
            } else if (s.amms[ammId].protocolId == 2 || s.amms[ammId].protocolId == 3) {
                LibBalancerV2.swapBalancerV2(hop);
            } else if (s.amms[ammId].protocolId == 6) {
                LibUniswapV3.swapUniswapV3(hop);
            } else if (
                s.amms[ammId].protocolId == 4 || s.amms[ammId].protocolId == 5 || s.amms[ammId].protocolId == 7
            ) {
                LibCurve.swapCurve(hop);
            } else if (s.amms[ammId].protocolId == 8) {
                LibDodoV2.swapDodoV2(hop);
            } else {
                revert InvalidProtocol();
            }

            ss.lastAmountOut = hopToAssetAddress.getBalance() - s.deposits[hopToAssetAddress];

            if (hopToAssetAddress == ss.toAssetAddress) {
                amountOut += ss.lastAmountOut;
                ss.currentFromAssetAddress = ss.fromAssetAddress;
            } else {
                ss.currentFromAssetAddress = hopToAssetAddress;
            }

            unchecked {
                ss.i++;
            }
        }

        if (amountOut < swapArgs.amountOutMin || amountOut == 0) {
            revert InsufficientOutputAmount();
        }

        if (ss.amountIn != ss.amountInAcc) {
            revert InvalidAmountIn();
        }
    }

    event AddAmm(address indexed sender, uint16 ammId, Amm amm);

    function addAmm(uint16 ammId, Amm memory amm) internal {
        AppStorage storage s = LibMagpieAggregator.getStorage();

        s.amms[ammId] = amm;

        emit AddAmm(msg.sender, ammId, amm);
    }

    event AddAmms(address indexed sender, uint16[] ammIds, Amm[] amms);

    function addAmms(uint16[] memory ammIds, Amm[] memory amms) internal {
        AppStorage storage s = LibMagpieAggregator.getStorage();

        uint256 i;
        uint256 l = amms.length;
        for (i = 0; i < l; ) {
            s.amms[ammIds[i]] = amms[i];

            unchecked {
                i++;
            }
        }

        emit AddAmms(msg.sender, ammIds, amms);
    }

    event RemoveAmm(address indexed sender, uint16 ammId);

    function removeAmm(uint16 ammId) internal {
        AppStorage storage s = LibMagpieAggregator.getStorage();

        delete s.amms[ammId];

        emit RemoveAmm(msg.sender, ammId);
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

import {Amm, CurveSettings} from "../../libraries/LibMagpieAggregator.sol";
import {LibRouter} from "../LibRouter.sol";

interface IRouter {
    event AddAmm(address indexed sender, uint16 ammId, Amm amm);

    function addAmm(uint16 ammId, Amm calldata amm) external;

    event AddAmms(address indexed sender, uint16[] ammIds, Amm[] amms);

    function addAmms(uint16[] calldata ammIds, Amm[] calldata amms) external;

    event RemoveAmm(address indexed sender, uint16 ammId);

    function removeAmm(uint16 ammId) external;

    event UpdateCurveSettings(address indexed sender, CurveSettings curveSettings);

    function updateCurveSettings(address addressProvider) external;
}

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

error AssetNotReceived();
error ApprovalFailed();
error ContractIsPaused();
error DepositIsZero();
error ExpiredTransaction();
error FunctionAlreadyExists();
error FunctionIsImmutable();
error InitializationFunctionReverted(address _initializationContractAddress, bytes _calldata);
error InsufficientOutputAmount();
error InvalidAmm();
error InvalidAmountIn();
error InvalidBridgeType();
error InvalidDataTransferType();
error InvalidFacetAddress();
error InvalidSelectors();
error InvalidAmountOutMin();
error InvalidFromAssetAddress();
error InvalidFromToAddress();
error InvalidMagpieAggregatorAddress();
error InvalidPayload();
error InvalidPath();
error InvalidProtocol();
error InvalidProtocolList();
error InvalidTransfer();
error InvalidSender();
error InvalidToAddress();
error InvalidToAssetAddress();
error InvalidTokenSequence();
error InvalidTransferKey();
error NoSelectorsToCut();
error ReentrantCall();
error SequenceHasPayload();
error SequenceIsUsed();
error SwapFailed();
error TransferFailed();
error TransferFromFailed();

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

interface IDiamondCut {
    enum FacetCutAction {
        Add,
        Replace,
        Remove
    }

    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }

    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external;

    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);
}

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IWETH.sol";
import "./LibError.sol";

library LibAsset {
    using LibAsset for address;

    address constant NATIVE_ASSETID = address(0);

    function isNative(address self) internal pure returns (bool) {
        return self == NATIVE_ASSETID;
    }

    function getBalance(address self) internal view returns (uint256) {
        return self.isNative() ? address(this).balance : IERC20(self).balanceOf(address(this));
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
                    isSuccessful := and(gt(returndatasize(), 31), eq(mload(0), 1))
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
                        isSuccessful := and(gt(returndatasize(), 31), eq(mload(0), 1))
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

    function deposit(
        address self,
        address weth,
        uint256 amount
    ) internal {
        if (self.isNative()) {
            if (msg.value < amount) {
                revert AssetNotReceived();
            }
            IWETH(weth).deposit{value: amount}();
        } else {
            self.transferFrom(msg.sender, address(this), amount);
        }
    }

    function withdraw(
        address self,
        address weth,
        address to,
        uint256 amount
    ) internal {
        if (self.isNative()) {
            IWETH(weth).withdraw(amount);
        }
        self.transfer(payable(to), amount);
    }

    function getDecimals(address self) internal view returns (uint8 tokenDecimals) {
        tokenDecimals = 18;

        if (!self.isNative()) {
            (, bytes memory queriedDecimals) = self.staticcall(abi.encodeWithSignature("decimals()"));
            tokenDecimals = abi.decode(queriedDecimals, (uint8));
        }
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

interface IAddressProvider {
    function admin() external view returns (address);

    function get_registry() external view returns (address);

    function get_address(uint256 idx) external view returns (address);
}

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

interface ICryptoFactory {
    function get_coin_indices(
        address _pool,
        address _from,
        address _to
    ) external view returns (uint256, uint256);

    function get_decimals(address _pool) external view returns (uint256[2] memory);
}

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

interface ICryptoRegistry {
    function get_coin_indices(
        address _pool,
        address _from,
        address _to
    ) external view returns (uint256, uint256);

    function get_decimals(address _pool) external view returns (uint256[8] memory);
}

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

interface ICurvePool {
    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external payable;

    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external payable;

    function get_dy(
        int128 i,
        int128 j,
        uint256 amount
    ) external view returns (uint256);

    function get_dy_underlying(
        int128 i,
        int128 j,
        uint256 amount
    ) external view returns (uint256);

    function coins(uint256 i) external view returns (address);
}

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

interface IRegistry {
    function address_provider() external view returns (address);

    function get_A(address _pool) external view returns (uint256);

    function get_fees(address _pool) external view returns (uint256[2] memory);

    function get_coin_indices(
        address _pool,
        address _from,
        address _to
    )
        external
        view
        returns (
            int128,
            int128,
            bool
        );

    function get_n_coins(address _pool) external view returns (uint256[2] memory);

    function get_balances(address _pool) external view returns (uint256[] memory);

    function get_underlying_balances(address _pool) external view returns (uint256[] memory);

    function get_rates(address _pool) external view returns (uint256[] memory);

    function get_decimals(address _pool) external view returns (uint256[] memory);

    function get_underlying_decimals(address _pool) external view returns (uint256[] memory);

    function find_pool_for_coins(
        address _from,
        address _to,
        uint256 i
    ) external view returns (address);

    function get_lp_token(address _pool) external view returns (address);

    function is_meta(address _pool) external view returns (bool);
}

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

interface ICryptoPool {
    function exchange(
        uint256 i,
        uint256 j,
        uint256 dx,
        uint256 min_dy
    ) external payable;

    function exchange_underlying(
        uint256 i,
        uint256 j,
        uint256 dx,
        uint256 min_dy
    ) external payable;

    function get_dy(
        uint256 i,
        uint256 j,
        uint256 amount
    ) external view returns (uint256);

    function get_dy_underlying(
        uint256 i,
        uint256 j,
        uint256 amount
    ) external view returns (uint256);
}

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

import {TransferKey} from "../data-transfer/LibDataTransfer.sol";
import {LibWormhole} from "./LibWormhole.sol";
import {LibStargate} from "./LibStargate.sol";
import {LibAsset} from "../libraries/LibAsset.sol";
import {LibBytes} from "../libraries/LibBytes.sol";
import {LibTransaction, Transaction, TransactionValidation} from "./LibTransaction.sol";
import "../libraries/LibError.sol";

enum BridgeType {
    Wormhole,
    Stargate
}

struct BridgeArgs {
    BridgeType bridgeType;
    bytes payload;
}

library LibBridge {
    using LibAsset for address;
    using LibBytes for bytes;

    function bridgeIn(
        BridgeArgs memory bridgeArgs,
        TransactionValidation memory transactionValidation,
        uint256 amount,
        address toAssetAddress
    ) internal returns (uint64 tokenSequence) {
        if (bridgeArgs.bridgeType == BridgeType.Wormhole) {
            tokenSequence = LibWormhole.bridgeIn(transactionValidation, bridgeArgs, amount, toAssetAddress);
        } else if (bridgeArgs.bridgeType == BridgeType.Stargate) {
            tokenSequence = LibStargate.bridgeIn(transactionValidation, bridgeArgs, amount, toAssetAddress);
        } else {
            revert InvalidBridgeType();
        }
    }

    function bridgeOut(
        BridgeArgs memory bridgeArgs,
        Transaction memory transaction,
        TransferKey memory transferKey
    ) internal returns (uint256 amount) {
        if (bridgeArgs.bridgeType == BridgeType.Wormhole) {
            amount = LibWormhole.bridgeOut(bridgeArgs.payload, transaction);
        } else if (bridgeArgs.bridgeType == BridgeType.Stargate) {
            amount = LibStargate.bridgeOut(bridgeArgs.payload, transaction, transferKey);
        } else {
            revert InvalidBridgeType();
        }
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

import {LibLayerZero} from "./LibLayerZero.sol";
import {LibWormhole} from "./LibWormhole.sol";
import {BridgeType} from "../bridge/LibBridge.sol";
import {LibBytes} from "../libraries/LibBytes.sol";
import {AppStorage, LibMagpieAggregator} from "../libraries/LibMagpieAggregator.sol";
import {LibTransaction, Transaction} from "../bridge/LibTransaction.sol";
import "../libraries/LibError.sol";

enum DataTransferType {
    Wormhole,
    LayerZero
}

struct DataTransferInProtocol {
    uint16 networkId;
    DataTransferType dataTransferType;
    bytes payload;
}

struct DataTransferInArgs {
    DataTransferInProtocol[] protocols;
    bytes payload;
}

struct DataTransferOutArgs {
    DataTransferType dataTransferType;
    bytes payload;
}

struct TransferKey {
    uint16 networkId;
    bytes32 senderAddress;
    uint64 coreSequence;
}

library LibDataTransfer {
    using LibBytes for bytes;

    function getExtendedPayload(bytes memory payload, TransferKey memory transferKey)
        private
        pure
        returns (bytes memory)
    {
        bytes memory transferKeyPayload = new bytes(42);

        assembly {
            mstore(add(transferKeyPayload, 32), shl(240, mload(transferKey)))
            mstore(add(transferKeyPayload, 34), mload(add(transferKey, 32)))
            mstore(add(transferKeyPayload, 66), shl(192, mload(add(transferKey, 64))))
        }

        return transferKeyPayload.concat(payload);
    }

    function getTransferKey(bytes memory extendedPayload) internal pure returns (TransferKey memory transferKey) {
        assembly {
            mstore(transferKey, shr(240, mload(add(extendedPayload, 32))))
            mstore(add(transferKey, 32), mload(add(extendedPayload, 34)))
            mstore(add(transferKey, 64), shr(192, mload(add(extendedPayload, 66))))
        }
    }

    function validateTransfer(
        uint16 networkId,
        bytes32 senderAddress,
        TransferKey memory transferKey
    ) internal view {
        AppStorage storage s = LibMagpieAggregator.getStorage();

        if (
            networkId == 0 ||
            senderAddress != s.magpieAggregatorAddresses[networkId] ||
            senderAddress != transferKey.senderAddress ||
            networkId != transferKey.networkId
        ) {
            revert InvalidTransfer();
        }
    }

    function getOriginalPayload(bytes memory extendedPayload) private pure returns (bytes memory) {
        return extendedPayload.slice(42, extendedPayload.length - 42);
    }

    function dataTransfer(DataTransferInArgs memory dataTransferInArgs)
        internal
        returns (TransferKey memory transferKey)
    {
        AppStorage storage s = LibMagpieAggregator.getStorage();

        s.coreSequence += 1;
        transferKey = TransferKey({
            networkId: s.networkId,
            senderAddress: bytes32(uint256(uint160(address(this)))),
            coreSequence: s.coreSequence
        });
        bytes memory extendedPayload = getExtendedPayload(dataTransferInArgs.payload, transferKey);

        bool wormholeUsed = false;
        uint256 pl = dataTransferInArgs.protocols.length;
        uint16 lastNetworkId = 0;
        for (uint256 p; p < pl; ) {
            if (p == 0 || uint16(dataTransferInArgs.protocols[p].networkId) > lastNetworkId) {
                lastNetworkId = uint16(dataTransferInArgs.protocols[p].networkId);
            } else {
                revert InvalidProtocolList();
            }

            if (dataTransferInArgs.protocols[p].dataTransferType == DataTransferType.Wormhole && !wormholeUsed) {
                wormholeUsed = true;
                LibWormhole.dataTransfer(extendedPayload);
            } else if (dataTransferInArgs.protocols[p].dataTransferType == DataTransferType.LayerZero) {
                LibLayerZero.dataTransfer(extendedPayload, dataTransferInArgs.protocols[p]);
            } else {
                revert InvalidDataTransferType();
            }

            unchecked {
                p++;
            }
        }
    }

    function getPayload(DataTransferOutArgs memory dataTransferOutArgs)
        internal
        view
        returns (TransferKey memory transferKey, bytes memory payload)
    {
        if (dataTransferOutArgs.dataTransferType == DataTransferType.Wormhole) {
            payload = LibWormhole.getPayload(dataTransferOutArgs.payload);
        } else if (dataTransferOutArgs.dataTransferType == DataTransferType.LayerZero) {
            payload = LibLayerZero.getPayload(dataTransferOutArgs.payload);
        } else {
            revert InvalidDataTransferType();
        }

        transferKey = getTransferKey(payload);
        payload = getOriginalPayload(payload);
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

import {AppStorage, LibMagpieAggregator, WormholeBridgeSettings} from "../libraries/LibMagpieAggregator.sol";
import {LibAsset} from "../libraries/LibAsset.sol";
import {IWormhole} from "../interfaces/wormhole/IWormhole.sol";
import {IWormholeCore} from "../interfaces/wormhole/IWormholeCore.sol";
import {DataTransferType, LibDataTransfer} from "../data-transfer/LibDataTransfer.sol";
import {Transaction, TransactionValidation} from "./LibTransaction.sol";
import {BridgeArgs} from "./LibBridge.sol";
import "../libraries/LibError.sol";

struct WormholeBridgeInData {
    uint16 recipientBridgeChainId;
}

library LibWormhole {
    using LibAsset for address;

    event UpdateWormholeBridgeSettings(address indexed sender, WormholeBridgeSettings wormholeBridgeSettings);

    function updateSettings(WormholeBridgeSettings memory wormholeBridgeSettings) internal {
        AppStorage storage s = LibMagpieAggregator.getStorage();

        s.wormholeBridgeSettings = wormholeBridgeSettings;

        emit UpdateWormholeBridgeSettings(msg.sender, wormholeBridgeSettings);
    }

    function normalize(
        uint8 fromDecimals,
        uint8 toDecimals,
        uint256 amount
    ) private pure returns (uint256) {
        amount /= 10**(fromDecimals - toDecimals);
        return amount;
    }

    function denormalize(
        uint8 fromDecimals,
        uint8 toDecimals,
        uint256 amount
    ) private pure returns (uint256) {
        amount *= 10**(toDecimals - fromDecimals);
        return amount;
    }

    function getRecipientBridgeChainId(bytes memory bridgeInPayload)
        private
        pure
        returns (uint16 recipientBridgeChainId)
    {
        assembly {
            recipientBridgeChainId := shr(240, mload(add(bridgeInPayload, 32)))
        }
    }

    function bridgeIn(
        TransactionValidation memory transactionValidation,
        BridgeArgs memory bridgeArgs,
        uint256 amount,
        address toAssetAddress
    ) internal returns (uint64 tokenSequence) {
        AppStorage storage s = LibMagpieAggregator.getStorage();

        // Dust management
        uint8 toAssetDecimals = toAssetAddress.getDecimals();
        if (toAssetDecimals > 8) {
            amount = normalize(toAssetDecimals, 8, amount);
            amount = denormalize(8, toAssetDecimals, amount);
        }

        toAssetAddress.approve(s.wormholeBridgeSettings.bridgeAddress, amount);
        tokenSequence = IWormhole(s.wormholeBridgeSettings.bridgeAddress).transferTokens(
            toAssetAddress,
            amount,
            getRecipientBridgeChainId(bridgeArgs.payload),
            transactionValidation.recipientAggregatorAddress,
            0,
            uint32(block.timestamp % 2**32)
        );
    }

    function bridgeOut(bytes memory bridgeOutPayload, Transaction memory transaction)
        internal
        returns (uint256 amount)
    {
        AppStorage storage s = LibMagpieAggregator.getStorage();

        (IWormholeCore.VM memory vm, bool valid, string memory reason) = IWormholeCore(
            s.wormholeBridgeSettings.bridgeAddress
        ).parseAndVerifyVM(bridgeOutPayload);
        require(valid, reason);

        if (transaction.tokenSequence != vm.sequence) {
            revert InvalidTokenSequence();
        }

        bytes memory vmPayload = vm.payload;

        assembly {
            amount := mload(add(vmPayload, 33))
        }

        uint8 fromAssetDecimals = address(uint160(uint256(transaction.fromAssetAddress))).getDecimals();
        if (fromAssetDecimals > 8) {
            amount = denormalize(8, fromAssetDecimals, amount);
        }

        IWormhole(s.wormholeBridgeSettings.bridgeAddress).completeTransfer(bridgeOutPayload);
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

error AddressOutOfBounds();

library LibBytes {
    using LibBytes for bytes;

    function toAddress(bytes memory self, uint256 start) internal pure returns (address) {
        if (self.length < start + 20) {
            revert AddressOutOfBounds();
        }
        address tempAddress;

        assembly {
            tempAddress := mload(add(add(self, 20), start))
        }

        return tempAddress;
    }

    function slice(
        bytes memory self,
        uint256 start,
        uint256 length
    ) internal pure returns (bytes memory) {
        require(length + 31 >= length, "slice_overflow");
        require(self.length >= start + length, "slice_outOfBounds");

        bytes memory tempBytes;

        assembly {
            switch iszero(length)
            case 0 {
                tempBytes := mload(0x40)
                let lengthmod := and(length, 31)
                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, length)

                for {
                    let cc := add(add(add(self, lengthmod), mul(0x20, iszero(lengthmod))), start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, length)

                mstore(0x40, and(add(mc, 31), not(31)))
            }
            default {
                tempBytes := mload(0x40)
                mstore(tempBytes, 0)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    function concat(bytes memory self, bytes memory postBytes) internal pure returns (bytes memory) {
        bytes memory tempBytes;

        assembly {
            tempBytes := mload(0x40)

            let length := mload(self)
            mstore(tempBytes, length)

            let mc := add(tempBytes, 0x20)
            let end := add(mc, length)

            for {
                let cc := add(self, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            length := mload(postBytes)
            mstore(tempBytes, add(length, mload(tempBytes)))

            mc := end
            end := add(mc, length)

            for {
                let cc := add(postBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            mstore(0x40, and(add(add(end, iszero(add(length, mload(self)))), 31), not(31)))
        }

        return tempBytes;
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

import {DataTransferType} from "../data-transfer/LibDataTransfer.sol";
import {BridgeType} from "./LibBridge.sol";

struct TransactionValidation {
    bytes32 fromAssetAddress;
    bytes32 toAssetAddress;
    bytes32 toAddress;
    bytes32 recipientAggregatorAddress;
    uint256 amountOutMin;
    uint256 swapOutGasFee;
}

struct Transaction {
    BridgeType bridgeType;
    bytes32 fromAssetAddress;
    bytes32 toAssetAddress;
    bytes32 toAddress;
    bytes32 recipientAggregatorAddress;
    uint256 amountOutMin;
    uint256 swapOutGasFee;
    uint64 tokenSequence;
}

library LibTransaction {
    function encode(Transaction memory transaction) internal pure returns (bytes memory transactionPayload) {
        transactionPayload = new bytes(201);

        assembly {
            mstore(add(transactionPayload, 32), shl(248, mload(transaction))) // bridgeType
            mstore(add(transactionPayload, 33), mload(add(transaction, 32))) // fromAssetAddress
            mstore(add(transactionPayload, 65), mload(add(transaction, 64))) // toAssetAddress
            mstore(add(transactionPayload, 97), mload(add(transaction, 96))) // to
            mstore(add(transactionPayload, 129), mload(add(transaction, 128))) // recipientAggregatorAddress
            mstore(add(transactionPayload, 161), mload(add(transaction, 160))) // amountOutMin
            mstore(add(transactionPayload, 193), mload(add(transaction, 192))) // swapOutGasFee
            mstore(add(transactionPayload, 225), shl(192, mload(add(transaction, 224)))) // tokenSequence
        }
    }

    function decode(bytes memory transactionPayload) internal pure returns (Transaction memory transaction) {
        assembly {
            mstore(transaction, shr(248, mload(add(transactionPayload, 32)))) // bridgeType
            mstore(add(transaction, 32), mload(add(transactionPayload, 33))) // fromAssetAddress
            mstore(add(transaction, 64), mload(add(transactionPayload, 65))) // toAssetAddress
            mstore(add(transaction, 96), mload(add(transactionPayload, 97))) // to
            mstore(add(transaction, 128), mload(add(transactionPayload, 129))) // recipientAggregatorAddress
            mstore(add(transaction, 160), mload(add(transactionPayload, 161))) // amountOutMin
            mstore(add(transaction, 192), mload(add(transactionPayload, 193))) // swapOutGasFee
            mstore(add(transaction, 224), shr(192, mload(add(transactionPayload, 225)))) // tokenSequence
        }
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

import {TransferKey} from "../data-transfer/LibDataTransfer.sol";
import {AppStorage, LibMagpieAggregator, StargateSettings} from "../libraries/LibMagpieAggregator.sol";
import {LibAsset} from "../libraries/LibAsset.sol";
import {IStargateRouter} from "../interfaces/stargate/IStargateRouter.sol";
import {IStargatePool} from "../interfaces/stargate/IStargatePool.sol";
import {IStargateFactory} from "../interfaces/stargate/IStargateFactory.sol";
import {IStargateFeeLibrary} from "../interfaces/stargate/IStargateFeeLibrary.sol";
import {Transaction, TransactionValidation} from "./LibTransaction.sol";
import {BridgeArgs, BridgeType} from "./LibBridge.sol";
import "../libraries/LibError.sol";

struct StargateBridgeInData {
    uint16 layerZeroRecipientChainId;
    uint256 sourcePoolId;
    uint256 destPoolId;
    uint256 fee;
}

struct StargateBridgeOutData {
    bytes32 senderStargateBridgeAddress;
    uint256 nonce;
    uint16 senderStargateChainId;
}

struct ExecuteBridgeInArgs {
    uint16 networkId;
    uint64 tokenSequence;
    address routerAddress;
    uint256 amount;
    bytes recipientAggregatorAddress;
    StargateBridgeInData bridgeInData;
    IStargateRouter.lzTxObj lzTxObj;
}

library LibStargate {
    using LibAsset for address;

    event UpdateStargateSettings(address indexed sender, StargateSettings stargateSettings);

    function updateSettings(StargateSettings memory stargateSettings) internal {
        AppStorage storage s = LibMagpieAggregator.getStorage();

        s.stargateSettings = stargateSettings;

        emit UpdateStargateSettings(msg.sender, stargateSettings);
    }

    function createPayload(
        uint16 networkId,
        bytes32 senderAddress,
        uint64 tokenSequence
    ) internal pure returns (bytes memory payload) {
        payload = new bytes(42);
        assembly {
            mstore(add(payload, 32), shl(240, networkId))
            mstore(add(payload, 34), senderAddress)
            mstore(add(payload, 66), shl(192, tokenSequence))
        }
    }

    function decodePayload(bytes memory payload)
        internal
        pure
        returns (
            uint16 networkId,
            bytes32 senderAddress,
            uint64 tokenSequence
        )
    {
        assembly {
            networkId := shr(240, mload(add(payload, 32)))
            senderAddress := mload(add(payload, 34))
            tokenSequence := shr(192, mload(add(payload, 66)))
        }
    }

    function decodeBridgeInPayload(bytes memory bridgeInPayload)
        internal
        pure
        returns (StargateBridgeInData memory bridgeInData)
    {
        assembly {
            mstore(bridgeInData, shr(240, mload(add(bridgeInPayload, 32))))
            mstore(add(bridgeInData, 32), mload(add(bridgeInPayload, 34)))
            mstore(add(bridgeInData, 64), mload(add(bridgeInPayload, 66)))
            mstore(add(bridgeInData, 96), mload(add(bridgeInPayload, 98)))
        }
    }

    function decodeBridgeOutPayload(bytes memory bridgeOutPayload)
        internal
        pure
        returns (StargateBridgeOutData memory bridgeOutData)
    {
        assembly {
            mstore(bridgeOutData, mload(add(bridgeOutPayload, 32)))
            mstore(add(bridgeOutData, 32), mload(add(bridgeOutPayload, 64)))
            mstore(add(bridgeOutData, 64), shr(240, mload(add(bridgeOutPayload, 96))))
        }
    }

    function getMinAmountLD(uint256 amount, StargateBridgeInData memory bridgeInData) private view returns (uint256) {
        AppStorage storage s = LibMagpieAggregator.getStorage();

        address stargateFactoryAddress = IStargateRouter(s.stargateSettings.routerAddress).factory();
        address poolAddress = IStargateFactory(stargateFactoryAddress).getPool(bridgeInData.sourcePoolId);
        address feeLibraryAddress = IStargatePool(poolAddress).feeLibrary();
        uint256 convertRate = IStargatePool(poolAddress).convertRate();
        IStargatePool.SwapObj memory swapObj = IStargateFeeLibrary(feeLibraryAddress).getFees(
            bridgeInData.sourcePoolId,
            bridgeInData.destPoolId,
            bridgeInData.layerZeroRecipientChainId,
            address(this),
            amount / convertRate
        );
        swapObj.amount =
            (amount / convertRate - (swapObj.eqFee + swapObj.protocolFee + swapObj.lpFee) + swapObj.eqReward) *
            convertRate;
        return swapObj.amount;
    }

    function bridgeIn(
        TransactionValidation memory transactionValidation,
        BridgeArgs memory bridgeArgs,
        uint256 amount,
        address toAssetAddress
    ) internal returns (uint64 tokenSequence) {
        AppStorage storage s = LibMagpieAggregator.getStorage();

        toAssetAddress.approve(s.stargateSettings.routerAddress, amount);

        s.tokenSequence += 1;
        tokenSequence = s.tokenSequence;

        executeBridgeIn(
            ExecuteBridgeInArgs({
                recipientAggregatorAddress: abi.encodePacked(
                    address(uint160(uint256(transactionValidation.recipientAggregatorAddress)))
                ),
                bridgeInData: decodeBridgeInPayload(bridgeArgs.payload),
                lzTxObj: IStargateRouter.lzTxObj(0, 0, abi.encodePacked(msg.sender)),
                tokenSequence: tokenSequence,
                amount: amount,
                networkId: s.networkId,
                routerAddress: s.stargateSettings.routerAddress
            })
        );
    }

    function executeBridgeIn(ExecuteBridgeInArgs memory executeBridgeInArgs) internal {
        IStargateRouter(executeBridgeInArgs.routerAddress).swap{value: executeBridgeInArgs.bridgeInData.fee}(
            executeBridgeInArgs.bridgeInData.layerZeroRecipientChainId,
            executeBridgeInArgs.bridgeInData.sourcePoolId,
            executeBridgeInArgs.bridgeInData.destPoolId,
            payable(msg.sender),
            executeBridgeInArgs.amount,
            getMinAmountLD(executeBridgeInArgs.amount, executeBridgeInArgs.bridgeInData),
            executeBridgeInArgs.lzTxObj,
            executeBridgeInArgs.recipientAggregatorAddress,
            createPayload(
                executeBridgeInArgs.networkId,
                bytes32(uint256(uint160(address(this)))),
                executeBridgeInArgs.tokenSequence
            )
        );
    }

    function bridgeOut(
        bytes memory bridgeOutPayload,
        Transaction memory transaction,
        TransferKey memory transferKey
    ) internal returns (uint256 amount) {
        AppStorage storage s = LibMagpieAggregator.getStorage();
        StargateBridgeOutData memory bridgeOutData = decodeBridgeOutPayload(bridgeOutPayload);

        address fromAssetAddress = address(uint160(uint256(transaction.fromAssetAddress)));

        amount = s.stargateDeposits[transferKey.networkId][transferKey.senderAddress][transaction.tokenSequence][
            fromAssetAddress
        ];
        s.stargateDeposits[transferKey.networkId][transferKey.senderAddress][transaction.tokenSequence][
            fromAssetAddress
        ] = 0;
        s.deposits[fromAssetAddress] -= amount;

        // If somebody called it manually we just skip it
        if (
            IStargateRouter(s.stargateSettings.routerAddress)
                .cachedSwapLookup(
                    bridgeOutData.senderStargateChainId,
                    abi.encode(bridgeOutData.senderStargateBridgeAddress),
                    bridgeOutData.nonce
                )
                .to != address(0x0)
        ) {
            IStargateRouter(s.stargateSettings.routerAddress).clearCachedSwap(
                bridgeOutData.senderStargateChainId,
                abi.encode(bridgeOutData.senderStargateBridgeAddress),
                bridgeOutData.nonce
            );
        }
    }

    function sgReceive(
        address assetAddress,
        uint256 amount,
        bytes memory payload
    ) internal {
        AppStorage storage s = LibMagpieAggregator.getStorage();
        (uint16 networkId, bytes32 senderAddress, uint64 tokenSequence) = decodePayload(payload);
        s.stargateDeposits[networkId][senderAddress][tokenSequence][assetAddress] += amount;
        s.deposits[assetAddress] += amount;
    }

    function enforce() internal view {
        AppStorage storage s = LibMagpieAggregator.getStorage();
        if (msg.sender != s.stargateSettings.routerAddress) {
            revert InvalidSender();
        }
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
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

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

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
pragma solidity 0.8.17;

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
pragma solidity 0.8.17;

import {DataTransferType} from "./LibDataTransfer.sol";
import {ILayerZero} from "../interfaces/layer-zero/ILayerZero.sol";
import {AppStorage, LayerZeroSettings, LibMagpieAggregator} from "../libraries/LibMagpieAggregator.sol";
import {DataTransferInProtocol, LibDataTransfer, TransferKey} from "./LibDataTransfer.sol";
import "../libraries/LibError.sol";

struct LayerZeroDataTransferInData {
    uint256 fee;
}

struct LayerZeroDataTransferOutData {
    uint16 senderNetworkId;
    bytes32 senderAddress;
    uint64 coreSequence;
}

library LibLayerZero {
    event UpdateLayerZeroSettings(address indexed sender, LayerZeroSettings layerZeroSettings);

    function updateSettings(LayerZeroSettings memory layerZeroSettings) internal {
        AppStorage storage s = LibMagpieAggregator.getStorage();

        s.layerZeroSettings = layerZeroSettings;

        emit UpdateLayerZeroSettings(msg.sender, layerZeroSettings);
    }

    event AddLayerZeroChainIds(address indexed sender, uint16[] networkIds, uint16[] chainIds);

    function addLayerZeroChainIds(uint16[] memory networkIds, uint16[] memory chainIds) internal {
        AppStorage storage s = LibMagpieAggregator.getStorage();

        uint256 i;
        uint256 l = networkIds.length;
        for (i = 0; i < l; ) {
            s.layerZeroChainIds[networkIds[i]] = chainIds[i];

            unchecked {
                i++;
            }
        }

        emit AddLayerZeroChainIds(msg.sender, networkIds, chainIds);
    }

    event AddLayerZeroNetworkIds(address indexed sender, uint16[] chainIds, uint16[] networkIds);

    function addLayerZeroNetworkIds(uint16[] memory chainIds, uint16[] memory networkIds) internal {
        AppStorage storage s = LibMagpieAggregator.getStorage();

        uint256 i;
        uint256 l = chainIds.length;
        for (i = 0; i < l; ) {
            s.layerZeroNetworkIds[chainIds[i]] = networkIds[i];

            unchecked {
                i++;
            }
        }

        emit AddLayerZeroNetworkIds(msg.sender, chainIds, networkIds);
    }

    function decodeDataTransferOutPayload(bytes memory dataTransferOutPayload)
        private
        pure
        returns (LayerZeroDataTransferOutData memory dataTransferOutData)
    {
        assembly {
            mstore(dataTransferOutData, shr(240, mload(add(dataTransferOutPayload, 32))))
            mstore(add(dataTransferOutData, 32), mload(add(dataTransferOutPayload, 34)))
            mstore(add(dataTransferOutData, 64), shr(192, mload(add(dataTransferOutPayload, 66))))
        }
    }

    function decodeDataTransferInPayload(bytes memory dataTransferInPayload)
        internal
        pure
        returns (LayerZeroDataTransferInData memory dataTransferInData)
    {
        assembly {
            mstore(dataTransferInData, mload(add(dataTransferInPayload, 32)))
        }
    }

    function dataTransfer(bytes memory payload, DataTransferInProtocol memory protocol) internal {
        AppStorage storage s = LibMagpieAggregator.getStorage();

        LayerZeroDataTransferInData memory dataTransferInData = decodeDataTransferInPayload(protocol.payload);

        ILayerZero(s.layerZeroSettings.routerAddress).send{value: dataTransferInData.fee}(
            s.layerZeroChainIds[protocol.networkId],
            abi.encodePacked(address(uint160(uint256(s.magpieAggregatorAddresses[protocol.networkId]))), address(this)),
            payload,
            payable(msg.sender),
            address(0x0),
            hex"00010000000000000000000000000000000000000000000000000000000000030d40"
        );
    }

    function getPayload(bytes memory dataTransferOutPayload) internal view returns (bytes memory extendedPayload) {
        AppStorage storage s = LibMagpieAggregator.getStorage();

        LayerZeroDataTransferOutData memory dataTransferOutData = decodeDataTransferOutPayload(dataTransferOutPayload);

        extendedPayload = s.payloads[uint16(DataTransferType.LayerZero)][dataTransferOutData.senderNetworkId][
            dataTransferOutData.senderAddress
        ][dataTransferOutData.coreSequence];

        if (extendedPayload.length == 0) {
            revert InvalidPayload();
        }
    }

    function registerPayload(TransferKey memory transferKey, bytes memory extendedPayload) private {
        AppStorage storage s = LibMagpieAggregator.getStorage();

        if (
            s
            .payloads[uint16(DataTransferType.LayerZero)][transferKey.networkId][transferKey.senderAddress][
                transferKey.coreSequence
            ].length > 0
        ) {
            revert SequenceHasPayload();
        }

        s.payloads[uint16(DataTransferType.LayerZero)][transferKey.networkId][transferKey.senderAddress][
                transferKey.coreSequence
            ] = extendedPayload;
    }

    function lzReceive(
        uint16 senderChainId,
        bytes32 senderAddress,
        bytes memory extendedPayload
    ) internal {
        AppStorage storage s = LibMagpieAggregator.getStorage();
        TransferKey memory transferKey = LibDataTransfer.getTransferKey(extendedPayload);

        LibDataTransfer.validateTransfer(s.layerZeroNetworkIds[senderChainId], senderAddress, transferKey);

        registerPayload(transferKey, extendedPayload);
    }

    function enforce() internal view {
        AppStorage storage s = LibMagpieAggregator.getStorage();
        if (msg.sender != s.layerZeroSettings.routerAddress) {
            revert InvalidSender();
        }
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

import {LibDataTransfer} from "./LibDataTransfer.sol";
import {AppStorage, LibMagpieAggregator, WormholeSettings} from "../libraries/LibMagpieAggregator.sol";
import {IWormholeCore} from "../interfaces/wormhole/IWormholeCore.sol";
import {LibDataTransfer, TransferKey} from "./LibDataTransfer.sol";

library LibWormhole {
    event UpdateWormholeSettings(address indexed sender, WormholeSettings wormholeSettings);

    function updateSettings(WormholeSettings memory wormholeSettings) internal {
        AppStorage storage s = LibMagpieAggregator.getStorage();

        s.wormholeSettings = wormholeSettings;

        emit UpdateWormholeSettings(msg.sender, wormholeSettings);
    }

    event AddWormholeNetworkIds(address indexed sender, uint16[] chainIds, uint16[] networkIds);

    function addWormholeNetworkIds(uint16[] memory chainIds, uint16[] memory networkIds) internal {
        AppStorage storage s = LibMagpieAggregator.getStorage();

        uint256 i;
        uint256 l = chainIds.length;
        for (i = 0; i < l; ) {
            s.wormholeNetworkIds[chainIds[i]] = networkIds[i];

            unchecked {
                i++;
            }
        }

        emit AddWormholeNetworkIds(msg.sender, chainIds, networkIds);
    }

    function dataTransfer(bytes memory payload) internal {
        AppStorage storage s = LibMagpieAggregator.getStorage();

        uint64 wormholeCoreSequence = IWormholeCore(s.wormholeSettings.bridgeAddress).publishMessage(
            uint32(block.timestamp % 2**32),
            payload,
            s.wormholeSettings.consistencyLevel
        );

        s.wormholeCoreSequences[s.coreSequence] = wormholeCoreSequence;
    }

    function getPayload(bytes memory dataTransferOutPayload) internal view returns (bytes memory extendedPayload) {
        AppStorage storage s = LibMagpieAggregator.getStorage();
        (IWormholeCore.VM memory vm, bool valid, string memory reason) = IWormholeCore(s.wormholeSettings.bridgeAddress)
            .parseAndVerifyVM(dataTransferOutPayload);
        require(valid, reason);

        TransferKey memory transferKey = LibDataTransfer.getTransferKey(extendedPayload);

        LibDataTransfer.validateTransfer(s.wormholeNetworkIds[vm.emitterChainId], vm.emitterAddress, transferKey);

        extendedPayload = vm.payload;
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

interface ILayerZero {
    function send(
        uint16 _dstChainId,
        bytes calldata _remoteAndLocalAddresses,
        bytes calldata _payload,
        address payable _refundAddress,
        address _zroPaymentAddress,
        bytes calldata _adapterParams
    ) external payable;

    function estimateFees(
        uint16 _dstChainId, //destination layerZero ChainId
        address _userApplication,
        bytes calldata _payload,
        bool _payInZRO,
        bytes calldata _adapterParams
    ) external view returns (uint256 nativeFee, uint256 zroFee);
}

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

interface IStargateFactory {
    function getPool(uint256) external view returns (address);
}

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

interface IStargateRouter {
    struct lzTxObj {
        uint256 dstGasForCall;
        uint256 dstNativeAmount;
        bytes dstNativeAddr;
    }

    function addLiquidity(
        uint256 _poolId,
        uint256 _amountLD,
        address _to
    ) external;

    function swap(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress,
        uint256 _amountLD,
        uint256 _minAmountLD,
        lzTxObj memory _lzTxParams,
        bytes calldata _to,
        bytes calldata _payload
    ) external payable;

    function redeemRemote(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress,
        uint256 _amountLP,
        uint256 _minAmountLD,
        bytes calldata _to,
        lzTxObj memory _lzTxParams
    ) external payable;

    function instantRedeemLocal(
        uint16 _srcPoolId,
        uint256 _amountLP,
        address _to
    ) external returns (uint256);

    function redeemLocal(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress,
        uint256 _amountLP,
        bytes calldata _to,
        lzTxObj memory _lzTxParams
    ) external payable;

    function sendCredits(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress
    ) external payable;

    function quoteLayerZeroFee(
        uint16 _dstChainId,
        uint8 _functionType,
        bytes calldata _toAddress,
        bytes calldata _transferAndCallPayload,
        lzTxObj memory _lzTxParams
    ) external view returns (uint256, uint256);

    function clearCachedSwap(
        uint16 _srcChainId,
        bytes calldata _srcAddress,
        uint256 _nonce
    ) external;

    struct CachedSwap {
        address token;
        uint256 amountLD;
        address to;
        bytes payload;
    }

    function cachedSwapLookup(
        uint16,
        bytes calldata,
        uint256
    ) external view returns (CachedSwap memory);

    function factory() external view returns (address);
}

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

interface IStargatePool {
    struct SwapObj {
        uint256 amount;
        uint256 eqFee;
        uint256 eqReward;
        uint256 lpFee;
        uint256 protocolFee;
        uint256 lkbRemove;
    }

    function convertRate() external view returns (uint256);

    function feeLibrary() external view returns (address);
}

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

import "./IStargatePool.sol";

interface IStargateFeeLibrary {
    function getFees(
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        uint16 _dstChainId,
        address _from,
        uint256 _amountSD
    ) external view returns (IStargatePool.SwapObj memory s);
}

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

import {AppStorage, LibMagpieAggregator} from "../libraries/LibMagpieAggregator.sol";
import {LibAsset} from "../libraries/LibAsset.sol";
import {LibBytes} from "../libraries/LibBytes.sol";
import {InvalidAmountIn, LibRouter, SwapArgs} from "../router/LibRouter.sol";
import {LibUint256Array} from "../libraries/LibUint256Array.sol";
import {LibBridge, BridgeArgs} from "../bridge/LibBridge.sol";
import {LibTransaction, Transaction, TransactionValidation} from "../bridge/LibTransaction.sol";
import {DataTransferInArgs, DataTransferInProtocol, DataTransferOutArgs, LibDataTransfer, TransferKey} from "../data-transfer/LibDataTransfer.sol";
import "../libraries/LibError.sol";

struct SwapInArgs {
    SwapArgs swapArgs;
    BridgeArgs bridgeArgs;
    DataTransferInProtocol dataTransferInProtocol;
    TransactionValidation transactionValidation;
}

struct SwapOutArgs {
    SwapArgs swapArgs;
    BridgeArgs bridgeArgs;
    DataTransferOutArgs dataTransferOutArgs;
}

struct SwapOutVariables {
    address fromAssetAddress;
    address toAssetAddress;
    address toAddress;
    address transactionToAddress;
    uint256 bridgeAmount;
    uint256 amountIn;
}

library LibAggregator {
    using LibAsset for address;
    using LibBytes for bytes;
    using LibUint256Array for uint256[];

    event UpdateWeth(address indexed sender, address weth);

    function updateWeth(address weth) internal {
        AppStorage storage s = LibMagpieAggregator.getStorage();

        s.weth = weth;

        emit UpdateWeth(msg.sender, weth);
    }

    event UpdateNetworkId(address indexed sender, uint16 networkId);

    function updateNetworkId(uint16 networkId) internal {
        AppStorage storage s = LibMagpieAggregator.getStorage();

        s.networkId = networkId;

        emit UpdateNetworkId(msg.sender, networkId);
    }

    event AddMagpieAggregatorAddresses(
        address indexed sender,
        uint16[] networkIds,
        bytes32[] magpieAggregatorAddresses
    );

    function addMagpieAggregatorAddresses(uint16[] memory networkIds, bytes32[] memory magpieAggregatorAddresses)
        internal
    {
        AppStorage storage s = LibMagpieAggregator.getStorage();

        uint256 i;
        uint256 l = magpieAggregatorAddresses.length;
        for (i = 0; i < l; ) {
            s.magpieAggregatorAddresses[networkIds[i]] = magpieAggregatorAddresses[i];

            unchecked {
                i++;
            }
        }

        emit AddMagpieAggregatorAddresses(msg.sender, networkIds, magpieAggregatorAddresses);
    }

    event Swap(
        address indexed fromAddress,
        address indexed toAddress,
        address fromAssetAddress,
        address toAssetAddress,
        uint256 amountIn,
        uint256 amountOut
    );

    function swap(SwapArgs memory swapArgs) internal returns (uint256 amountOut) {
        AppStorage storage s = LibMagpieAggregator.getStorage();

        address toAddress = swapArgs.addresses.toAddress(0);
        address fromAssetAddress = swapArgs.addresses.toAddress(20);
        address toAssetAddress = swapArgs.addresses.toAddress(40);
        uint256 amountIn = swapArgs.amountIns.sum();

        fromAssetAddress.deposit(s.weth, amountIn);

        amountOut = LibRouter.swap(swapArgs);

        toAssetAddress.withdraw(s.weth, swapArgs.addresses.toAddress(0), amountOut);

        emit Swap(msg.sender, toAddress, fromAssetAddress, toAssetAddress, amountIn, amountOut);
    }

    event SwapIn(
        address indexed fromAddress,
        bytes32 indexed toAddress,
        address fromAssetAddress,
        address toAssetAddress,
        uint256 amountIn,
        uint256 amountOut,
        TransferKey transferKey,
        Transaction transaction
    );

    function swapIn(SwapInArgs memory swapInArgs) internal returns (uint256 amountOut) {
        AppStorage storage s = LibMagpieAggregator.getStorage();

        if (swapInArgs.swapArgs.addresses.toAddress(0) != address(this)) {
            revert InvalidToAddress();
        }

        uint256 amountIn = swapInArgs.swapArgs.amountIns.sum();
        address fromAssetAddress = swapInArgs.swapArgs.addresses.toAddress(20);
        address toAssetAddress = swapInArgs.swapArgs.addresses.toAddress(40);

        fromAssetAddress.deposit(s.weth, amountIn);

        amountOut = LibRouter.swap(swapInArgs.swapArgs);

        uint64 tokenSequence = LibBridge.bridgeIn(
            swapInArgs.bridgeArgs,
            swapInArgs.transactionValidation,
            amountOut,
            toAssetAddress
        );

        Transaction memory transaction = Transaction({
            bridgeType: swapInArgs.bridgeArgs.bridgeType,
            fromAssetAddress: swapInArgs.transactionValidation.fromAssetAddress,
            toAssetAddress: swapInArgs.transactionValidation.toAssetAddress,
            toAddress: swapInArgs.transactionValidation.toAddress,
            recipientAggregatorAddress: swapInArgs.transactionValidation.recipientAggregatorAddress,
            amountOutMin: swapInArgs.transactionValidation.amountOutMin,
            swapOutGasFee: swapInArgs.transactionValidation.swapOutGasFee,
            tokenSequence: tokenSequence
        });

        DataTransferInProtocol[] memory protocols = new DataTransferInProtocol[](1);
        protocols[0] = swapInArgs.dataTransferInProtocol;

        TransferKey memory transferKey = LibDataTransfer.dataTransfer(
            DataTransferInArgs({protocols: protocols, payload: LibTransaction.encode(transaction)})
        );

        emit SwapIn(
            msg.sender,
            transaction.toAddress,
            fromAssetAddress,
            toAssetAddress,
            amountIn,
            amountOut,
            transferKey,
            transaction
        );
    }

    event SwapOut(
        address indexed fromAddress,
        address indexed toAddress,
        address fromAssetAddress,
        address toAssetAddress,
        uint256 amountIn,
        uint256 amountOut,
        TransferKey transferKey,
        Transaction transaction
    );

    function swapOut(SwapOutArgs memory swapOutArgs) internal returns (uint256 amountOut) {
        AppStorage storage s = LibMagpieAggregator.getStorage();

        (TransferKey memory transferKey, bytes memory payload) = LibDataTransfer.getPayload(
            swapOutArgs.dataTransferOutArgs
        );

        if (s.usedTransferKeys[transferKey.networkId][transferKey.senderAddress][transferKey.coreSequence]) {
            revert InvalidTransferKey();
        }

        s.usedTransferKeys[transferKey.networkId][transferKey.senderAddress][transferKey.coreSequence] = true;

        Transaction memory transaction = LibTransaction.decode(payload);

        SwapOutVariables memory v = SwapOutVariables({
            bridgeAmount: LibBridge.bridgeOut(swapOutArgs.bridgeArgs, transaction, transferKey),
            amountIn: swapOutArgs.swapArgs.amountIns.sum(),
            toAddress: swapOutArgs.swapArgs.addresses.toAddress(0),
            transactionToAddress: address(uint160(uint256(transaction.toAddress))),
            fromAssetAddress: swapOutArgs.swapArgs.addresses.toAddress(20),
            toAssetAddress: swapOutArgs.swapArgs.addresses.toAddress(40)
        });

        if (v.transactionToAddress == msg.sender) {
            transaction.swapOutGasFee = 0;
            transaction.amountOutMin = swapOutArgs.swapArgs.amountOutMin;
        } else {
            swapOutArgs.swapArgs.amountOutMin = transaction.amountOutMin;
        }

        if (address(uint160(uint256(transaction.fromAssetAddress))) != v.fromAssetAddress) {
            revert InvalidFromAssetAddress();
        }

        if (msg.sender != v.transactionToAddress) {
            if (address(uint160(uint256(transaction.toAssetAddress))) != v.toAssetAddress) {
                revert InvalidToAssetAddress();
            }
        }

        if (v.transactionToAddress != v.toAddress || v.transactionToAddress == address(this)) {
            revert InvalidToAddress();
        }

        if (address(uint160(uint256(transaction.recipientAggregatorAddress))) != address(this)) {
            revert InvalidMagpieAggregatorAddress();
        }

        if (swapOutArgs.swapArgs.amountOutMin < transaction.amountOutMin) {
            revert InvalidAmountOutMin();
        }

        if (swapOutArgs.swapArgs.amountIns[0] <= transaction.swapOutGasFee) {
            revert InvalidAmountIn();
        }

        if (v.amountIn > v.bridgeAmount) {
            revert InvalidAmountIn();
        }

        swapOutArgs.swapArgs.amountIns[0] =
            swapOutArgs.swapArgs.amountIns[0] +
            (v.bridgeAmount > v.amountIn ? v.bridgeAmount - v.amountIn : 0) -
            transaction.swapOutGasFee;
        v.amountIn = swapOutArgs.swapArgs.amountIns.sum();

        amountOut = LibRouter.swap(swapOutArgs.swapArgs);

        if (transaction.swapOutGasFee > 0) {
            s.deposits[v.fromAssetAddress] += transaction.swapOutGasFee;
            s.depositsByAsset[v.fromAssetAddress][msg.sender] += transaction.swapOutGasFee;
        }

        v.toAssetAddress.withdraw(s.weth, v.toAddress, amountOut);

        emit SwapOut(
            msg.sender,
            v.toAddress,
            v.fromAssetAddress,
            v.toAssetAddress,
            v.amountIn,
            amountOut,
            transferKey,
            transaction
        );
    }

    event Withdraw(address indexed sender, address indexed assetAddress, uint256 amount);

    function withdraw(address assetAddress) internal {
        AppStorage storage s = LibMagpieAggregator.getStorage();

        uint256 deposit = s.depositsByAsset[assetAddress][msg.sender];

        if (deposit == 0) {
            revert DepositIsZero();
        }

        s.deposits[assetAddress] -= deposit;
        s.depositsByAsset[assetAddress][msg.sender] = 0;

        assetAddress.transfer(payable(msg.sender), deposit);

        emit Withdraw(msg.sender, assetAddress, deposit);
    }

    function simulateSwap(SwapArgs memory swapArgs) internal returns (uint256 amountOut) {
        AppStorage storage s = LibMagpieAggregator.getStorage();

        uint256 amountIn = swapArgs.amountIns.sum();
        address fromAssetAddress = swapArgs.addresses.toAddress(20);
        address toAssetAddress = swapArgs.addresses.toAddress(40);

        fromAssetAddress.deposit(s.weth, amountIn);

        if (fromAssetAddress == toAssetAddress) {
            amountOut = amountIn;
        } else {
            amountOut = LibRouter.swap(swapArgs);
        }

        s.deposits[toAssetAddress] += amountOut;
        s.depositsByAsset[toAssetAddress][msg.sender] += amountOut;

        emit Swap(msg.sender, msg.sender, fromAssetAddress, toAssetAddress, amountIn, amountOut);
    }

    function simulateTransfer(
        SwapArgs calldata swapArgs,
        bool shouldTransfer,
        bool useTransferFrom
    ) internal returns (uint256 amountOut) {
        AppStorage storage s = LibMagpieAggregator.getStorage();

        uint256 amountIn = swapArgs.amountIns.sum();
        address fromAssetAddress = swapArgs.addresses.toAddress(20);
        address toAssetAddress = swapArgs.addresses.toAddress(40);

        fromAssetAddress.deposit(s.weth, amountIn);

        amountOut = LibRouter.swap(swapArgs);

        if (shouldTransfer) {
            if (useTransferFrom) {
                s.deposits[toAssetAddress] += amountOut;
                s.depositsByAsset[toAssetAddress][msg.sender] += amountOut;
                toAssetAddress.transferFrom(address(this), address(this), amountOut);
            } else {
                toAssetAddress.withdraw(s.weth, msg.sender, amountOut);
            }
        }

        emit Swap(msg.sender, msg.sender, fromAssetAddress, toAssetAddress, amountIn, amountOut);
    }

    event Paused(address sender);

    function pause() internal {
        AppStorage storage s = LibMagpieAggregator.getStorage();

        s.paused = true;
        emit Paused(msg.sender);
    }

    event Unpaused(address sender);

    function unpause() internal {
        AppStorage storage s = LibMagpieAggregator.getStorage();

        s.paused = false;
        emit Paused(msg.sender);
    }

    function enforceIsNotPaused() internal view {
        AppStorage storage s = LibMagpieAggregator.getStorage();

        if (s.paused) {
            revert ContractIsPaused();
        }
    }

    function enforcePreGuard() internal {
        AppStorage storage s = LibMagpieAggregator.getStorage();

        if (s.guarded) {
            revert ReentrantCall();
        }

        s.guarded = true;
    }

    function enforcePostGuard() internal {
        AppStorage storage s = LibMagpieAggregator.getStorage();

        s.guarded = false;
    }

    function enforceDeadline(uint256 deadline) internal view {
        if (deadline < block.timestamp) {
            revert ExpiredTransaction();
        }
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

library LibUint256Array {
    function sum(uint256[] memory self) internal pure returns (uint256 amountOut) {
        uint256 selfLength = self.length * 32;

        assembly {
            let selfPosition := add(self, 32)
            let endPosition := add(selfPosition, selfLength)

            for {

            } lt(selfPosition, endPosition) {
                selfPosition := add(selfPosition, 32)
            } {
                amountOut := add(amountOut, mload(selfPosition))
            }
        }
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

import {IAsset} from "../interfaces/balancer-v2/IAsset.sol";
import {IVault} from "../interfaces/balancer-v2/IVault.sol";
import {LibAsset} from "../libraries/LibAsset.sol";
import {LibRouter, Hop} from "./LibRouter.sol";

library LibBalancerV2 {
    using LibAsset for address;

    function swapBalancerV2(Hop memory h) internal {
        h.path[0].approve(h.addr, h.amountIn);
        IVault.FundManagement memory funds = IVault.FundManagement({
            sender: address(this),
            fromInternalBalance: false,
            recipient: payable(address(this)),
            toInternalBalance: false
        });
        if (h.path.length == 2) {
            IVault(h.addr).swap(
                IVault.SingleSwap({
                    poolId: h.poolData[0],
                    kind: IVault.SwapKind.GIVEN_IN,
                    assetIn: IAsset(h.path[0]),
                    assetOut: IAsset(h.path[1]),
                    amount: h.amountIn,
                    userData: "0x"
                }),
                funds,
                0,
                block.timestamp
            );
        } else {
            uint256 i;
            uint256 l = h.path.length;
            IVault.BatchSwapStep[] memory swaps = new IVault.BatchSwapStep[](h.path.length - 1);
            IAsset[] memory balancerAssets = new IAsset[](h.path.length);
            int256[] memory limits = new int256[](h.path.length);

            for (i = 0; i < l - 1; ) {
                swaps[i] = IVault.BatchSwapStep({
                    poolId: h.poolData[i],
                    assetInIndex: i,
                    assetOutIndex: i + 1,
                    amount: i == 0 ? h.amountIn : 0,
                    userData: "0x"
                });
                balancerAssets[i] = IAsset(h.path[i]);
                limits[i] = i == 0 ? int256(h.amountIn) : int256(0);

                if (i == h.path.length - 2) {
                    balancerAssets[i + 1] = IAsset(h.path[i + 1]);
                    limits[i + 1] = 0;
                }

                unchecked {
                    i++;
                }
            }

            IVault(h.addr).batchSwap(IVault.SwapKind.GIVEN_IN, swaps, balancerAssets, funds, limits, block.timestamp);
        }
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

import {IUniswapV2Router} from "../interfaces/uniswap-v2/IUniswapV2Router.sol";
import {LibAsset} from "../libraries/LibAsset.sol";
import {LibRouter, Hop} from "./LibRouter.sol";

library LibUniswapV2 {
    using LibAsset for address;

    function swapUniswapV2(Hop memory h) internal {
        h.path[0].approve(h.addr, h.amountIn);
        IUniswapV2Router(h.addr).swapExactTokensForTokens(h.amountIn, 0, h.path, address(this), block.timestamp);
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

import {IDodoV2Pool} from "../interfaces/dodo-v2/IDodoV2Pool.sol";
import {LibAsset} from "../libraries/LibAsset.sol";
import {LibRouter, Hop} from "./LibRouter.sol";

library LibDodoV2 {
    using LibAsset for address;

    function getDodoV2Data(bytes32[] memory poolData)
        private
        pure
        returns (address[] memory poolAddresses, uint256[] memory directions)
    {
        uint256 l = poolData.length;
        poolAddresses = new address[](l);
        directions = new uint256[](l);

        assembly {
            let i := 0
            let poolAddressesPosition := add(poolAddresses, 32)
            let directionsPosition := add(directions, 32)

            for {

            } lt(i, l) {
                i := add(i, 1)
                poolAddressesPosition := add(poolAddressesPosition, 32)
                directionsPosition := add(directionsPosition, 32)
            } {
                let poolDataPosition := add(add(poolData, 32), mul(i, 32))

                mstore(poolAddressesPosition, shr(96, mload(poolDataPosition)))
                mstore(directionsPosition, shr(248, shl(160, mload(poolDataPosition))))
            }
        }
    }

    function swapDodoV2(Hop memory h) internal {
        uint256 i;
        uint256 l = h.poolData.length;
        (address[] memory poolAddresses, uint256[] memory directions) = getDodoV2Data(h.poolData);
        h.path[0].transfer(payable(poolAddresses[0]), h.amountIn);

        for (i = 0; i < l; ) {
            if (directions[i] == 1) {
                IDodoV2Pool(poolAddresses[i]).sellBase((i == l - 1) ? address(this) : poolAddresses[i + 1]);
            } else {
                IDodoV2Pool(poolAddresses[i]).sellQuote((i == l - 1) ? address(this) : poolAddresses[i + 1]);
            }

            unchecked {
                i++;
            }
        }
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

import {IUniswapV3Router} from "../interfaces/uniswap-v3/IUniswapV3Router.sol";
import {LibAsset} from "../libraries/LibAsset.sol";
import {LibRouter, Hop} from "./LibRouter.sol";

library LibUniswapV3 {
    using LibAsset for address;

    function getUniswapV3Path(address[] memory path, bytes32[] memory poolData) private pure returns (bytes memory) {
        bytes memory payload;
        uint256 pathSize = path.length;

        assembly {
            payload := mload(0x40)
            let i := 0
            let payloadPosition := add(payload, 32)
            let pathPosition := add(path, 32)
            let poolDataPosition := add(poolData, 32)

            for {

            } lt(i, pathSize) {
                i := add(i, 1)
                pathPosition := add(pathPosition, 32)
            } {
                mstore(payloadPosition, shl(96, mload(pathPosition)))
                payloadPosition := add(payloadPosition, 20)
                mstore(payloadPosition, mload(poolDataPosition))
                payloadPosition := add(payloadPosition, 3)
                poolDataPosition := add(poolDataPosition, 32)
            }

            mstore(payload, sub(sub(payloadPosition, payload), 32))
            mstore(0x40, and(add(payloadPosition, 31), not(31)))
        }

        return payload;
    }

    function swapUniswapV3(Hop memory h) internal {
        h.path[0].approve(h.addr, h.amountIn);
        if (h.path.length == 2) {
            bytes32 poolData = h.poolData[0];
            uint24 fee;

            assembly {
                fee := shr(232, poolData)
            }

            IUniswapV3Router(h.addr).exactInputSingle(
                IUniswapV3Router.ExactInputSingleParams({
                    tokenIn: h.path[0],
                    tokenOut: h.path[1],
                    fee: fee,
                    recipient: address(this),
                    deadline: block.timestamp,
                    amountIn: h.amountIn,
                    amountOutMinimum: 0,
                    sqrtPriceLimitX96: 0
                })
            );
        } else {
            IUniswapV3Router(h.addr).exactInput(
                IUniswapV3Router.ExactInputParams({
                    path: getUniswapV3Path(h.path, h.poolData),
                    recipient: address(this),
                    deadline: block.timestamp,
                    amountIn: h.amountIn,
                    amountOutMinimum: 0
                })
            );
        }
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

/**
 * @dev This is an empty interface used to represent either ERC20-conforming token contracts or ETH (using the zero
 * address sentinel value). We're just relying on the fact that `interface` can be used to declare new address-like
 * types.
 *
 * This concept is unrelated to a Pool's Asset Managers.
 */
interface IAsset {

}

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./IAsset.sol";

interface IVault {
    enum SwapKind {
        GIVEN_IN,
        GIVEN_OUT
    }

    function swap(
        SingleSwap memory singleSwap,
        FundManagement memory funds,
        uint256 limit,
        uint256 deadline
    ) external payable returns (uint256);

    struct SingleSwap {
        bytes32 poolId;
        SwapKind kind;
        IAsset assetIn;
        IAsset assetOut;
        uint256 amount;
        bytes userData;
    }

    function batchSwap(
        SwapKind kind,
        BatchSwapStep[] memory swaps,
        IAsset[] memory assets,
        FundManagement memory funds,
        int256[] memory limits,
        uint256 deadline
    ) external payable returns (int256[] memory);

    struct BatchSwapStep {
        bytes32 poolId;
        uint256 assetInIndex;
        uint256 assetOutIndex;
        uint256 amount;
        bytes userData;
    }

    struct FundManagement {
        address sender;
        bool fromInternalBalance;
        address payable recipient;
        bool toInternalBalance;
    }

    function queryBatchSwap(
        SwapKind kind,
        BatchSwapStep[] memory swaps,
        IAsset[] memory assets,
        FundManagement memory funds
    ) external returns (int256[] memory assetDeltas);
}

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

interface IUniswapV2Router {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

interface IDodoV2Pool {
    function sellBase(address to) external payable returns (uint256);

    function sellQuote(address to) external payable returns (uint256);
}

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

interface IUniswapV3Router {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another along the specified path
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactInputParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactOutputSingleParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another along the specified path (reversed)
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactOutputParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
}