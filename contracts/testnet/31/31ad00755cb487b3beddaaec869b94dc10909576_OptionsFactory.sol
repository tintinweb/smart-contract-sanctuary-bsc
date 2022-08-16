// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.16;

import {ClonesWithImmutableArgs} from "@rolla-finance/clones-with-immutable-args/ClonesWithImmutableArgs.sol";
import {QToken} from "./QToken.sol";
import "../libraries/OptionsUtils.sol";
import "../interfaces/IOptionsFactory.sol";
import "../interfaces/ICollateralToken.sol";

/// @title Factory contract for Quant options
/// @author Rolla
/// @notice Creates tokens for long (QToken) and short (CollateralToken) positions
/// @dev This contract follows the factory design pattern
contract OptionsFactory is IOptionsFactory {
    using ClonesWithImmutableArgs for address;

    /// @inheritdoc IOptionsFactory
    address public immutable override strikeAsset;

    /// @inheritdoc IOptionsFactory
    address public immutable override collateralToken;

    /// @inheritdoc IOptionsFactory
    address public immutable override controller;

    /// @inheritdoc IOptionsFactory
    address public immutable override oracleRegistry;

    /// @inheritdoc IOptionsFactory
    address public immutable override assetsRegistry;

    /// @inheritdoc IOptionsFactory
    QToken public immutable implementation;

    /// @inheritdoc IOptionsFactory
    uint8 public immutable override optionsDecimals = 18;

    /// @inheritdoc IOptionsFactory
    mapping(address => bool) public override isQToken;

    /// @notice Initializes a new options factory
    /// @param _strikeAsset address of the asset used to denominate strike prices
    /// for options created through this factory
    /// @param _collateralToken address of the CollateralToken contract
    /// @param _controller address of the Quant Controller contract
    /// @param _oracleRegistry address of the OracleRegistry contract
    /// @param _assetsRegistry address of the AssetsRegistry contract
    /// @param _implementation a QToken implementation contract, to be used when creating QToken clones
    /// for the options created through this factory
    constructor(
        address _strikeAsset,
        address _collateralToken,
        address _controller,
        address _oracleRegistry,
        address _assetsRegistry,
        QToken _implementation
    ) {
        require(_strikeAsset != address(0), "OptionsFactory: invalid strike asset address");
        require(_collateralToken != address(0), "OptionsFactory: invalid CollateralToken address");
        require(_controller != address(0), "OptionsFactory: invalid controller address");
        require(_oracleRegistry != address(0), "OptionsFactory: invalid oracle registry address");
        require(_assetsRegistry != address(0), "OptionsFactory: invalid assets registry address");
        require(address(_implementation) != address(0), "OptionsFactory: invalid QToken implementation address");

        strikeAsset = _strikeAsset;
        collateralToken = _collateralToken;
        controller = _controller;
        oracleRegistry = _oracleRegistry;
        assetsRegistry = _assetsRegistry;
        implementation = _implementation;
    }

    /// @inheritdoc IOptionsFactory
    function createOption(
        address _underlyingAsset,
        address _oracle,
        uint88 _expiryTime,
        bool _isCall,
        uint256 _strikePrice
    )
        external
        override
        returns (address newQToken, uint256 newCollateralTokenId)
    {
        OptionsUtils.validateOptionParameters(
            oracleRegistry, _underlyingAsset, assetsRegistry, _oracle, _expiryTime, _strikePrice
        );

        bytes memory data = OptionsUtils.getQTokenImmutableArgs(
            optionsDecimals,
            _underlyingAsset,
            strikeAsset,
            assetsRegistry,
            _oracle,
            _expiryTime,
            _isCall,
            _strikePrice,
            controller
        );

        newQToken = address(implementation).cloneDeterministic(OptionsUtils.SALT, data);

        newCollateralTokenId = ICollateralToken(collateralToken).createOptionCollateralToken(newQToken);

        isQToken[newQToken] = true;

        emit OptionCreated(
            newQToken, msg.sender, _underlyingAsset, _oracle, _expiryTime, _isCall, _strikePrice, newCollateralTokenId
            );
    }

    /// @inheritdoc IOptionsFactory
    function getCollateralToken(
        address _underlyingAsset,
        address _qTokenAsCollateral,
        address _oracle,
        uint88 _expiryTime,
        bool _isCall,
        uint256 _strikePrice
    )
        external
        view
        override
        returns (uint256 id, bool exists)
    {
        (address qToken,) = getQToken(_underlyingAsset, _oracle, _expiryTime, _isCall, _strikePrice);

        id = ICollateralToken(collateralToken).getCollateralTokenId(qToken, _qTokenAsCollateral);

        (qToken,) = ICollateralToken(collateralToken).idToInfo(id);

        exists = qToken != address(0);
    }

    /// @inheritdoc IOptionsFactory
    function getQToken(
        address _underlyingAsset,
        address _oracle,
        uint88 _expiryTime,
        bool _isCall,
        uint256 _strikePrice
    )
        public
        view
        override
        returns (address qToken, bool exists)
    {
        bytes memory data = OptionsUtils.getQTokenImmutableArgs(
            optionsDecimals,
            _underlyingAsset,
            strikeAsset,
            assetsRegistry,
            _oracle,
            _expiryTime,
            _isCall,
            _strikePrice,
            controller
        );

        (qToken, exists) =
            ClonesWithImmutableArgs.predictDeterministicAddress(address(implementation), OptionsUtils.SALT, data);
    }
}

// SPDX-License-Identifier: BSD

pragma solidity ^0.8.4;

/// @title ClonesWithImmutableArgs
/// @author wighawag, zefram.eth
/// @notice Enables creating clone contracts with immutable args
/// @dev extended by [email protected] to add create2 support
/// (h/t WyseNynja https://github.com/wighawag/clones-with-immutable-args/issues/4)
library ClonesWithImmutableArgs {
    // abi.encodeWithSignature("CreateFail()")
    uint256 constant CreateFail_error_signature = 0xebfef18800000000000000000000000000000000000000000000000000000000;

    // abi.encodeWithSignature("IdentityPrecompileFailure()")
    uint256 constant IdentityPrecompileFailure_error_signature =
        0x3a008ffa00000000000000000000000000000000000000000000000000000000;

    uint256 constant custom_error_sig_ptr = 0x0;

    uint256 constant custom_error_length = 0x4;

    /// @notice Creates a clone proxy of the implementation contract with immutable args
    /// @dev data cannot exceed 65535 bytes, since 2 bytes are used to store the data length
    /// @param implementation The implementation contract to clone
    /// @param data Encoded immutable args
    /// @return ptr The ptr to the clone's bytecode
    /// @return creationSize The size of the clone to be created
    function cloneCreationCode(address implementation, bytes memory data)
        internal
        view
        returns (uint256 ptr, uint256 creationSize)
    {
        // unrealistic for memory ptr or data length to exceed 256 bits
        unchecked {
            uint256 extraLength = data.length + 2; // +2 bytes for telling how much data there is appended to the call
            creationSize = 0x41 + extraLength;
            uint256 runSize = creationSize - 10;
            // solhint-disable-next-line no-inline-assembly
            assembly ("memory-safe") {
                ptr := mload(0x40)

                // -------------------------------------------------------------------------------------------------------------
                // CREATION (10 bytes)
                // -------------------------------------------------------------------------------------------------------------

                // 61 runtime  | PUSH2 runtime (r)     | r                       | –
                mstore(ptr, 0x6100000000000000000000000000000000000000000000000000000000000000)
                mstore(add(ptr, 0x01), shl(240, runSize)) // size of the contract running bytecode (16 bits)

                // creation size = 0a
                // 3d          | RETURNDATASIZE        | 0 r                     | –
                // 81          | DUP2                  | r 0 r                   | –
                // 60 creation | PUSH1 creation (c)    | c r 0 r                 | –
                // 3d          | RETURNDATASIZE        | 0 c r 0 r               | –
                // 39          | CODECOPY              | 0 r                     | [0-runSize): runtime code
                // f3          | RETURN                |                         | [0-runSize): runtime code

                // -------------------------------------------------------------------------------------------------------------
                // RUNTIME (55 bytes + extraLength)
                // -------------------------------------------------------------------------------------------------------------

                // 3d          | RETURNDATASIZE        | 0                       | –
                // 3d          | RETURNDATASIZE        | 0 0                     | –
                // 3d          | RETURNDATASIZE        | 0 0 0                   | –
                // 3d          | RETURNDATASIZE        | 0 0 0 0                 | –
                // 36          | CALLDATASIZE          | cds 0 0 0 0             | –
                // 3d          | RETURNDATASIZE        | 0 cds 0 0 0 0           | –
                // 3d          | RETURNDATASIZE        | 0 0 cds 0 0 0 0         | –
                // 37          | CALLDATACOPY          | 0 0 0 0                 | [0, cds) = calldata
                // 61          | PUSH2 extra           | extra 0 0 0 0           | [0, cds) = calldata
                mstore(add(ptr, 0x03), 0x3d81600a3d39f33d3d3d3d363d3d376100000000000000000000000000000000)
                mstore(add(ptr, 0x13), shl(240, extraLength))

                // 60 0x37     | PUSH1 0x37            | 0x37 extra 0 0 0 0      | [0, cds) = calldata // 0x37 (55) is runtime size - data
                // 36          | CALLDATASIZE          | cds 0x37 extra 0 0 0 0  | [0, cds) = calldata
                // 39          | CODECOPY              | 0 0 0 0                 | [0, cds) = calldata, [cds, cds+0x37) = extraData
                // 36          | CALLDATASIZE          | cds 0 0 0 0             | [0, cds) = calldata, [cds, cds+0x37) = extraData
                // 61 extra    | PUSH2 extra           | extra cds 0 0 0 0       | [0, cds) = calldata, [cds, cds+0x37) = extraData
                mstore(add(ptr, 0x15), 0x6037363936610000000000000000000000000000000000000000000000000000)
                mstore(add(ptr, 0x1b), shl(240, extraLength))

                // 01          | ADD                   | cds+extra 0 0 0 0       | [0, cds) = calldata, [cds, cds+0x37) = extraData
                // 3d          | RETURNDATASIZE        | 0 cds 0 0 0 0           | [0, cds) = calldata, [cds, cds+0x37) = extraData
                // 73 addr     | PUSH20 0x123…         | addr 0 cds 0 0 0 0      | [0, cds) = calldata, [cds, cds+0x37) = extraData
                mstore(add(ptr, 0x1d), 0x013d730000000000000000000000000000000000000000000000000000000000)
                mstore(add(ptr, 0x20), shl(0x60, implementation))

                // 5a          | GAS                   | gas addr 0 cds 0 0 0 0  | [0, cds) = calldata, [cds, cds+0x37) = extraData
                // f4          | DELEGATECALL          | success 0 0             | [0, cds) = calldata, [cds, cds+0x37) = extraData
                // 3d          | RETURNDATASIZE        | rds success 0 0         | [0, cds) = calldata, [cds, cds+0x37) = extraData
                // 3d          | RETURNDATASIZE        | rds rds success 0 0     | [0, cds) = calldata, [cds, cds+0x37) = extraData
                // 93          | SWAP4                 | 0 rds success 0 rds     | [0, cds) = calldata, [cds, cds+0x37) = extraData
                // 80          | DUP1                  | 0 0 rds success 0 rds   | [0, cds) = calldata, [cds, cds+0x37) = extraData
                // 3e          | RETURNDATACOPY        | success 0 rds           | [0, rds) = return data (there might be some irrelevant leftovers in memory [rds, cds+0x37) when rds < cds+0x37)
                // 60 0x35     | PUSH1 0x35            | 0x35 sucess 0 rds       | [0, rds) = return data
                // 57          | JUMPI                 | 0 rds                   | [0, rds) = return data
                // fd          | REVERT                | –                       | [0, rds) = return data
                // 5b          | JUMPDEST              | 0 rds                   | [0, rds) = return data
                // f3          | RETURN                | –                       | [0, rds) = return data
                mstore(add(ptr, 0x34), 0x5af43d3d93803e603557fd5bf300000000000000000000000000000000000000)
            }

            // -------------------------------------------------------------------------------------------------------------
            // APPENDED DATA (Accessible from extcodecopy)
            // (but also send as appended data to the delegatecall)
            // -------------------------------------------------------------------------------------------------------------

            extraLength -= 2;
            assembly ("memory-safe") {
                if iszero(staticcall(gas(), 0x04, add(data, 0x20), extraLength, add(ptr, 0x41), extraLength)) {
                    mstore(custom_error_sig_ptr, IdentityPrecompileFailure_error_signature)
                    revert(custom_error_sig_ptr, custom_error_length)
                }

                mstore(add(add(ptr, 0x41), extraLength), shl(240, extraLength))
            }
        }
    }

    /// @notice Creates a clone proxy of the implementation contract with immutable args
    /// @dev data cannot exceed 65535 bytes, since 2 bytes are used to store the data length
    /// @param implementation The implementation contract to clone
    /// @param data Encoded immutable args
    /// @return instance The address of the created clone
    function clone(address implementation, bytes memory data) internal returns (address payable instance) {
        (uint256 creationPtr, uint256 creationSize) = cloneCreationCode(implementation, data);

        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            instance := create(0, creationPtr, creationSize)

            // if the create failed, the instance address won't be set
            if iszero(instance) {
                mstore(custom_error_sig_ptr, CreateFail_error_signature)
                revert(custom_error_sig_ptr, custom_error_length)
            }
        }
    }

    /// @notice Creates a clone proxy of the implementation contract with immutable args
    /// @dev data cannot exceed 65535 bytes, since 2 bytes are used to store the data length
    /// @param implementation The implementation contract to clone
    /// @param salt The salt for create2
    /// @param data Encoded immutable args
    /// @return instance The address of the created clone
    function cloneDeterministic(address implementation, bytes32 salt, bytes memory data)
        internal
        returns (address payable instance)
    {
        (uint256 creationPtr, uint256 creationSize) = cloneCreationCode(implementation, data);

        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            instance := create2(0, creationPtr, creationSize, salt)

            // if the create failed, the instance address won't be set
            if iszero(instance) {
                mstore(custom_error_sig_ptr, CreateFail_error_signature)
                revert(custom_error_sig_ptr, custom_error_length)
            }
        }
    }

    /// @notice Predicts the address where a deterministic clone of implementation will be deployed
    /// @dev data cannot exceed 65535 bytes, since 2 bytes are used to store the data length
    /// @param implementation The implementation contract to clone
    /// @param salt The salt for create2
    /// @param data Encoded immutable args
    /// @return predicted The predicted address of the created clone
    /// @return exists Whether the clone already exists
    function predictDeterministicAddress(address implementation, bytes32 salt, bytes memory data)
        internal
        view
        returns (address predicted, bool exists)
    {
        (uint256 creationPtr, uint256 creationSize) = cloneCreationCode(implementation, data);

        bytes32 creationHash;
        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            creationHash := keccak256(creationPtr, creationSize)
        }

        predicted = computeAddress(salt, creationHash, address(this));
        exists = predicted.code.length > 0;
    }

    /// @dev Returns the address where a contract will be stored if deployed via CREATE2 from a contract located at `deployer`.
    function computeAddress(bytes32 salt, bytes32 bytecodeHash, address deployer) internal pure returns (address) {
        bytes32 _data = keccak256(abi.encodePacked(bytes1(0xff), deployer, salt, bytecodeHash));
        return address(uint160(uint256(_data)));
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.16;

import "../external/ERC20.sol";
import "../interfaces/IQToken.sol";

/// @title Token that represents a user's long position
/// @author Rolla
/// @notice Can be used by owners to exercise their options
/// @dev Every option long position is an ERC20 token: https://eips.ethereum.org/EIPS/eip-20
contract QToken is ERC20, IQToken {
    /// -----------------------------------------------------------------------
    /// Immutable parameters
    /// -----------------------------------------------------------------------

    /// @inheritdoc IQToken
    function underlyingAsset() public pure override returns (address _underlyingAsset) {
        return _getArgAddress(0x101);
    }

    /// @inheritdoc IQToken
    function strikeAsset() external pure override returns (address _strikeAsset) {
        return _getArgAddress(0x115);
    }

    /// @inheritdoc IQToken
    function oracle() public pure override returns (address _oracle) {
        return _getArgAddress(0x129);
    }

    /// @inheritdoc IQToken
    function expiryTime() public pure override returns (uint88 _expiryTime) {
        return _getArgUint88(0x13d);
    }

    /// @inheritdoc IQToken
    function isCall() external pure override returns (bool _isCall) {
        return _getArgBool(0x148);
    }

    /// @inheritdoc IQToken
    function strikePrice() external pure override returns (uint256 _strikePrice) {
        return _getArgUint256(0x149);
    }

    /// @inheritdoc IQToken
    function controller() public pure override returns (address _controller) {
        return _getArgAddress(0x169);
    }

    /// -----------------------------------------------------------------------
    /// ERC20 minting and burning logic
    /// -----------------------------------------------------------------------

    /// @notice Checks if the caller is the configured Quant Controller contract
    modifier onlyController() {
        require(msg.sender == controller(), "QToken: caller != controller");
        _;
    }

    /// @inheritdoc IQToken
    function mint(address account, uint256 amount) external override onlyController {
        _mint(account, amount);
    }

    /// @inheritdoc IQToken
    function burn(address account, uint256 amount) external override onlyController {
        _burn(account, amount);
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.16;

import "solady/src/utils/LibString.sol";
import "@quant-finance/solidity-datetime/contracts/DateTime.sol";
import "../options/QToken.sol";
import "../interfaces/IOracleRegistry.sol";
import "../interfaces/IProviderOracleManager.sol";
import "../interfaces/IQToken.sol";
import "../interfaces/IAssetsRegistry.sol";

/// @title Options utilities for Quant's QToken and CollateralToken
/// @author Rolla
library OptionsUtils {
    /// @notice salt to be used with CREATE2 when creating new options
    /// @dev constant salt because options will only be deployed with the same parameters once
    bytes32 internal constant SALT = bytes32("ROLLA.FINANCE");

    uint8 internal constant STRIKE_PRICE_DECIMALS = 18;

    // abi.encodeWithSignature("DataSizeLimitExceeded(uint256)");
    uint256 internal constant DataSizeLimitExceeded_error_signature =
        0x5307a82000000000000000000000000000000000000000000000000000000000;

    uint256 internal constant DataSizeLimitExceeded_error_sig_ptr = 0x0;

    uint256 internal constant DataSizeLimitExceeded_error_datasize_ptr = 0x4;

    uint256 internal constant DataSizeLimitExceeded_error_length = 0x24; // 4 + 32 == 36

    /// @notice Checks if the given option parameters are valid for creation in the Quant Protocol
    /// @param _oracleRegistry oracle registry to validate the passed _oracle against
    /// @param _underlyingAsset asset that the option is for
    /// @param _assetsRegistry address of the AssetsRegistry contract
    /// @param _oracle price oracle for the option underlying
    /// @param _expiryTime expiration timestamp as a unix timestamp
    /// @param _strikePrice strike price with as many decimals in the strike asset
    function validateOptionParameters(
        address _oracleRegistry,
        address _underlyingAsset,
        address _assetsRegistry,
        address _oracle,
        uint88 _expiryTime,
        uint256 _strikePrice
    )
        internal
        view
    {
        require(_expiryTime > block.timestamp, "OptionsFactory: given expiry time is in the past");

        require(
            IProviderOracleManager(_oracle).isValidOption(_underlyingAsset, _expiryTime, _strikePrice),
            "OptionsFactory: Oracle doesn't support the given option"
        );

        require(
            IOracleRegistry(_oracleRegistry).isOracleActive(_oracle),
            "OptionsFactory: Oracle is not active in the OracleRegistry"
        );

        require(_strikePrice > 0, "strike can't be 0");

        require(isInAssetsRegistry(_underlyingAsset, _assetsRegistry), "underlying not in the registry");
    }

    /// @notice Checks if a given asset is in the AssetsRegistry
    /// @param _asset address of the asset to check
    /// @param _assetsRegistry address of the AssetsRegistry contract
    /// @return isRegistered whether the asset is in the configured registry
    function isInAssetsRegistry(address _asset, address _assetsRegistry) internal view returns (bool isRegistered) {
        (,,, isRegistered) = IAssetsRegistry(_assetsRegistry).assetProperties(_asset);
    }

    /// @notice Gets the amount of decimals for an option exercise payout
    /// @param _qToken address of the option's QToken contract
    /// @param _assetsRegistry address of the AssetsRegistry contract
    /// @return payoutDecimals amount of decimals for the option exercise payout
    function getPayoutDecimals(IQToken _qToken, address _assetsRegistry) internal view returns (uint8 payoutDecimals) {
        if (_qToken.isCall()) {
            (,, payoutDecimals,) = IAssetsRegistry(_assetsRegistry).assetProperties(_qToken.underlyingAsset());
        } else {
            payoutDecimals = STRIKE_PRICE_DECIMALS;
        }
    }

    /// @notice get the ERC20 token symbol from the AssetsRegistry
    /// @dev the asset is assumed to be in the AssetsRegistry since QTokens
    /// must be created through the OptionsFactory, which performs that check
    /// @param _asset address of the asset in the AssetsRegistry
    /// @param _assetsRegistry address of the AssetsRegistry contract
    /// @return assetSymbol_ string stored as the ERC20 token symbol
    function assetSymbol(address _asset, address _assetsRegistry) internal view returns (string memory assetSymbol_) {
        (, assetSymbol_,,) = IAssetsRegistry(_assetsRegistry).assetProperties(_asset);
    }

    /// @notice generates the name and symbol for an option
    /// @param _underlyingAsset asset that the option references
    /// @param _assetsRegistry address of the AssetsRegistry
    /// @param _expiryTime expiration timestamp as a unix timestamp
    /// @param _isCall true if it's a call option, false if it's a put option
    /// @param _strikePrice strike price with as many decimals in the strike asset
    /// @return name and symbol for the QToken
    function getQTokenMetadata(
        address _underlyingAsset,
        address _assetsRegistry,
        uint88 _expiryTime,
        bool _isCall,
        uint256 _strikePrice
    )
        internal
        view
        returns (string memory name, string memory symbol)
    {
        string memory underlying = assetSymbol(_underlyingAsset, _assetsRegistry);

        string memory displayStrikePrice = displayedStrikePrice(_strikePrice);

        // convert the expiry to a readable string
        (uint256 year, uint256 month, uint256 day) = DateTime.timestampToDate(_expiryTime);

        // get option type string
        (string memory typeSymbol, string memory typeFull) = getOptionType(_isCall);

        // get option month string
        (string memory monthSymbol, string memory monthFull) = getMonth(month);

        // get the day and year strings
        string memory dayStr = getDayStr(day);
        string memory yearStr = LibString.toString(year);

        // concatenated name and symbol strings
        name = string.concat(
            "ROLLA", " ", underlying, " ", dayStr, "-", monthFull, "-", yearStr, " ", displayStrikePrice, " ", typeFull
        );

        normalizeStringImmutableArg(name);

        symbol = string.concat(
            "ROLLA", "-", underlying, "-", dayStr, monthSymbol, yearStr, "-", displayStrikePrice, "-", typeSymbol
        );

        normalizeStringImmutableArg(symbol);
    }

    /// @notice Gets the encoded immutable arguments for creating a QToken clone
    /// using the ClonesWithImmutableArgs library
    /// @param _optionsDecimals the amount of decimals in QToken amounts
    /// @param _underlyingAsset address of the option underlying asset
    /// @param _strikeAsset asset that the option is settled on
    /// @param _assetsRegistry address of the AssetsRegistry contract
    /// @param _oracle price oracle for the option's underlying asset
    /// @param _expiryTime option expiration timestamp as a unix timestamp
    /// @param _isCall true if it's a call option, false if it's a put option
    /// @param _strikePrice strike price with as many decimals in the strike asset
    /// @param _controller address of the Quant Controller contract
    /// @return data encoded data for creating a QToken clone
    function getQTokenImmutableArgs(
        uint8 _optionsDecimals,
        address _underlyingAsset,
        address _strikeAsset,
        address _assetsRegistry,
        address _oracle,
        uint88 _expiryTime,
        bool _isCall,
        uint256 _strikePrice,
        address _controller
    )
        internal
        view
        returns (bytes memory data)
    {
        (string memory name, string memory symbol) =
            getQTokenMetadata(_underlyingAsset, _assetsRegistry, _expiryTime, _isCall, _strikePrice);

        data = abi.encodePacked(
            name,
            symbol,
            _optionsDecimals,
            _underlyingAsset,
            _strikeAsset,
            _oracle,
            _expiryTime,
            _isCall,
            _strikePrice,
            _controller
        );
    }

    /// @notice Normalize a string in memory so that it occupies 128 bytes to be
    /// used with the ClonesWithImmutableArgs library. The last (128th) byte stores
    /// the length of the string, and the first 127 bytes store the actual string content.
    function normalizeStringImmutableArg(string memory s) internal pure {
        assembly ("memory-safe") {
            // get the original length of the string
            let len := mload(s)

            // end execution with a custom DataSizeLimitExceeded error if the input data
            // is larger than 127 bytes
            if gt(len, 0x7f) {
                mstore(DataSizeLimitExceeded_error_sig_ptr, DataSizeLimitExceeded_error_signature)
                mstore(DataSizeLimitExceeded_error_datasize_ptr, len)
                revert(DataSizeLimitExceeded_error_sig_ptr, DataSizeLimitExceeded_error_length)
            }

            // store the new length of the string as 128 bytes
            mstore(s, 0x80)

            // update the free memory pointer, padding the new string length to 32 bytes
            mstore(0x40, add(s, and(add(add(0x80, 0x20), 0x1f), not(0x1f))))

            // store the original length of the string in the last byte of the output
            // location in memory, i.e. the 128th byte
            mstore(add(s, 0x80), xor(mload(add(s, 0x80)), shl(0xf8, len)))
        }
    }

    /// @dev convert the option strike price scaled to a human readable value
    /// @param _strikePrice the option strike price scaled by the strike asset decimals
    /// @return strike price string
    function displayedStrikePrice(uint256 _strikePrice) internal pure returns (string memory) {
        unchecked {
            uint256 strikePriceScale = 10 ** STRIKE_PRICE_DECIMALS;
            uint256 remainder = _strikePrice % strikePriceScale;
            uint256 quotient = _strikePrice / strikePriceScale;
            string memory quotientStr = LibString.toString(quotient);

            if (remainder == 0) {
                return quotientStr;
            }

            uint256 trailingZeroes;
            while (remainder % 10 == 0) {
                remainder /= 10;
                trailingZeroes++;
            }

            // pad the number with "1 + starting zeroes"
            remainder += 10 ** (STRIKE_PRICE_DECIMALS - trailingZeroes);

            string memory tmp = LibString.toString(remainder);
            tmp = slice(tmp, 1, 1 + STRIKE_PRICE_DECIMALS - trailingZeroes);

            return string(abi.encodePacked(quotientStr, ".", tmp));
        }
    }

    /// @dev get the string representation of the option type
    /// @return a 1 character representation of the option type
    /// @return a full length string of the option type
    function getOptionType(bool _isCall) internal pure returns (string memory, string memory) {
        return _isCall ? ("C", "Call") : ("P", "Put");
    }

    /// @dev get the representation of a day's number using 2 characters,
    /// adding a leading 0 if it's a one digit number
    /// @return dayStr 2 characters that correspond to a day's number
    function getDayStr(uint256 day) internal pure returns (string memory dayStr) {
        assembly ("memory-safe") {
            dayStr := mload(0x40)
            mstore(0x40, add(dayStr, 0x22))
            mstore(dayStr, 0x2)

            switch lt(day, 10)
            case 0 {
                mstore8(add(dayStr, 0x20), add(0x30, mod(div(day, 10), 10)))
                mstore8(add(dayStr, 0x21), add(0x30, mod(day, 10)))
            }
            default {
                mstore8(add(dayStr, 0x20), 0x30)
                mstore8(add(dayStr, 0x21), add(0x30, day))
            }
        }
    }

    /// @dev cut a string into string[start:end]
    /// @param _s string to cut
    /// @param _start the starting index
    /// @param _end the ending index (not inclusive)
    /// @return slice_ the indexed string
    function slice(string memory _s, uint256 _start, uint256 _end) internal pure returns (string memory slice_) {
        assembly ("memory-safe") {
            slice_ := add(_s, _start)
            mstore(slice_, sub(_end, _start))
        }
    }

    /// @dev get the string representations of a month
    /// @return a 3 character representation
    /// @return a full length string representation
    function getMonth(uint256 _month) internal pure returns (string memory, string memory) {
        if (_month == 1) {
            return ("JAN", "January");
        } else if (_month == 2) {
            return ("FEB", "February");
        } else if (_month == 3) {
            return ("MAR", "March");
        } else if (_month == 4) {
            return ("APR", "April");
        } else if (_month == 5) {
            return ("MAY", "May");
        } else if (_month == 6) {
            return ("JUN", "June");
        } else if (_month == 7) {
            return ("JUL", "July");
        } else if (_month == 8) {
            return ("AUG", "August");
        } else if (_month == 9) {
            return ("SEP", "September");
        } else if (_month == 10) {
            return ("OCT", "October");
        } else if (_month == 11) {
            return ("NOV", "November");
        } else if (_month == 12) {
            return ("DEC", "December");
        } else {
            revert("OptionsUtils: invalid month");
        }
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "../options/QToken.sol";

interface IOptionsFactory {
    /// @notice emitted when the factory creates a new option
    event OptionCreated(
        address qTokenAddress,
        address creator,
        address indexed underlying,
        address oracle,
        uint88 expiry,
        bool isCall,
        uint256 strikePrice,
        uint256 collateralTokenId
    );

    /// @notice Creates new options (QToken + CollateralToken)
    /// @dev Uses clones-with-immutable-args to create new QTokens from a single
    /// implementation contract
    /// @dev The CREATE2 opcode is used to deterministically deploy new QToken clones
    /// @param _underlyingAsset asset that the option references
    /// @param _oracle price oracle for the option underlying
    /// @param _expiryTime expiration timestamp as a unix timestamp
    /// @param _isCall true if it's a call option, false if it's a put option
    /// @param _strikePrice strike price with as many decimals in the strike asset
    function createOption(
        address _underlyingAsset,
        address _oracle,
        uint88 _expiryTime,
        bool _isCall,
        uint256 _strikePrice
    )
        external
        returns (address, uint256);

    /// @notice get the CollateralToken id for a given option, and whether it has
    /// already been created
    /// @param _underlyingAsset asset that the option references
    /// @param _qTokenAsCollateral initial spread collateral
    /// @param _oracle price oracle for the option underlying
    /// @param _expiryTime expiration timestamp as a unix timestamp
    /// @param _isCall true if it's a call option, false if it's a put option
    /// @param _strikePrice strike price with as many decimals in the strike asset
    /// @return id of the requested CollateralToken
    /// @return true if the CollateralToken has already been created, false otherwise
    function getCollateralToken(
        address _underlyingAsset,
        address _qTokenAsCollateral,
        address _oracle,
        uint88 _expiryTime,
        bool _isCall,
        uint256 _strikePrice
    )
        external
        view
        returns (uint256, bool);

    /// @notice get the QToken address for a given option, and whether it has
    /// already been created
    /// @param _underlyingAsset asset that the option references
    /// @param _oracle price oracle for the option underlying
    /// @param _expiryTime expiration timestamp as a unix timestamp
    /// @param _isCall true if it's a call option, false if it's a put option
    /// @param _strikePrice strike price with as many decimals in the strike asset
    /// @return address of the requested QToken
    /// @return true if the QToken has already been created, false otherwise
    function getQToken(
        address _underlyingAsset,
        address _oracle,
        uint88 _expiryTime,
        bool _isCall,
        uint256 _strikePrice
    )
        external
        view
        returns (address, bool);

    /// @notice get the strike asset used for options created by the factory
    /// @return the strike asset address
    function strikeAsset() external view returns (address);

    /// @notice get the collateral token used for options created by the factory
    /// @return the collateral token address
    function collateralToken() external view returns (address);

    /// @notice get the Quant Controller that mints and burns options created by the factory
    /// @return the Quant Controller address
    function controller() external view returns (address);

    /// @notice get the OracleRegistry that stores and manages oracles used with options created by the factory
    function oracleRegistry() external view returns (address);

    /// @notice get the AssetsRegistry that stores data about the underlying assets for options created by the factory
    /// @return the AssetsRegistry address
    function assetsRegistry() external view returns (address);

    /// @notice get the QToken implementation that is used to create options through the factory
    /// @return the QToken implementation address
    function implementation() external view returns (QToken);

    /// @notice get the amount of decimals used for options created by the factory
    /// @return the amount of decimals
    function optionsDecimals() external view returns (uint8);

    /// @notice checks if an address is a QToken
    /// @return true if the given address represents a registered QToken.
    /// false otherwise
    function isQToken(address) external view returns (bool);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/// @title Tokens representing a Quant user's short positions
/// @author Rolla
/// @notice Can be used by owners to claim their collateral
interface ICollateralToken {
    struct QTokensDetails {
        address underlyingAsset;
        address strikeAsset;
        address oracle;
        uint88 expiryTime;
        bool isCall;
        uint256 shortStrikePrice;
        uint256 longStrikePrice;
    }

    /// @notice event emitted when a new CollateralToken is created
    /// @param qTokenAddress address of the corresponding QToken
    /// @param qTokenAsCollateral QToken address of an option used as collateral in a spread
    /// @param id unique id of the created CollateralToken
    event CollateralTokenCreated(address indexed qTokenAddress, address qTokenAsCollateral, uint256 id);

    /// @notice Sets the the address for the OptionsFactory
    /// @param optionsFactory_ address of the OptionsFactory
    /// @dev This function will only be called once, in the Controller constructor, right after
    /// the CollateralToken contract is deployed with the Controller being its owner
    function setOptionsFactory(address optionsFactory_) external;

    /// @notice Create a new CollateralToken for a given QToken
    /// @param _qTokenAddress address of the corresponding QToken
    /// @return id the id for the CollateralToken created with the given arguments
    function createOptionCollateralToken(address _qTokenAddress) external returns (uint256 id);

    /// @notice Create a new CollateralToken for a given spread
    /// @param _qTokenAddress QToken address of an option being minted in a spread
    /// @param _qTokenAsCollateral QToken address of an option used as collateral in a spread
    /// @return id the id for the CollateralToken created with the given arguments
    function createSpreadCollateralToken(address _qTokenAddress, address _qTokenAsCollateral)
        external
        returns (uint256 id);

    /// @notice Mint CollateralTokens for a given account
    /// @param recipient address to receive the minted tokens
    /// @param amount amount of tokens to mint
    /// @param collateralTokenId id of the token to be minted
    function mintCollateralToken(address recipient, uint256 collateralTokenId, uint256 amount) external;

    /// @notice Mint CollateralTokens for a given account
    /// @param owner address to burn tokens from
    /// @param amount amount of tokens to burn
    /// @param collateralTokenId id of the token to be burned
    function burnCollateralToken(address owner, uint256 collateralTokenId, uint256 amount) external;

    /// @notice Set approval for all IDs by providing parameters to setApprovalForAll
    /// alongside a valid signature (r, s, v)
    /// @dev This method is implemented by following EIP-712: https://eips.ethereum.org/EIPS/eip-712
    /// @param owner     Address that wants to set operator status
    /// @param operator  Address to add to the set of authorized operators
    /// @param approved  True if the operator is approved, false to revoke approval
    /// @param nonce     Nonce valid for the owner at the time of the meta-tx execution
    /// @param deadline  Maximum unix timestamp at which the signature is still valid
    /// @param v         Last byte of the signed data
    /// @param r         The first 64 bytes of the signed data
    /// @param s         Bytes 64…128 of the signed data
    function metaSetApprovalForAll(
        address owner,
        address operator,
        bool approved,
        uint256 nonce,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external;

    /// @notice mapping of CollateralToken ids to their respective info struct
    function idToInfo(uint256) external view returns (address, address);

    /// @notice Returns a unique CollateralToken id based on its parameters
    /// @param _qToken the address of the corresponding QToken
    /// @param _qTokenAsCollateral QToken address of an option used as collateral in a spread
    /// @return id the id for the CollateralToken with the given arguments
    function getCollateralTokenId(address _qToken, address _qTokenAsCollateral) external pure returns (uint256 id);
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.16;

import {Clone} from "@rolla-finance/clones-with-immutable-args/Clone.sol";

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author zefram.eth (https://github.com/ZeframLou/vested-erc20/blob/main/src/lib/ERC20.sol)
/// @author Modified from Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
/// @dev Modified by Rolla to include name and symbol as 128 bytes strings, where the first 127 bytes are used to store
/// the string contents and the last 128th byte stores the original length of the string, which is limited to 127 bytes.
/// @dev The original ERC20 implementation with Clone from clones-with-immutable-args written by zefram.eth included
/// name and symbol with 32 bytes each, which would not be enough for Quant's QToken possibly long names and symbols.
abstract contract ERC20 is Clone {
    /*///////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*///////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*//////////////////////////////////////////////////////////////
                            EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(address => uint256) public nonces;

    /*///////////////////////////////////////////////////////////////
                               METADATA
    //////////////////////////////////////////////////////////////*/

    function name() external pure returns (string calldata nameStr) {
        nameStr = _get128BytesStringArg(0);
    }

    function symbol() external pure returns (string calldata symbolStr) {
        symbolStr = _get128BytesStringArg(0x80);
    }

    function decimals() external pure returns (uint8) {
        return _getArgUint8(0x100);
    }

    /*///////////////////////////////////////////////////////////////
                              ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) {
            allowance[from][msg.sender] = allowed - amount;
        }

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    /*//////////////////////////////////////////////////////////////
                             EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        public
        virtual
    {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        bytes32 nameHash = keccak256(bytes(_get128BytesStringArg(0)));

        return keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                nameHash,
                keccak256("1"),
                block.chainid,
                address(this)
            )
        );
    }

    /*///////////////////////////////////////////////////////////////
                       INTERNAL LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }

    /// @notice Read a 128 bytes string stored in the immutable args (calldata),
    /// in which the last byte is the length of the string.
    /// @param stringArgOffset The offset of the string immutable arg in the packed data
    /// @return stringArg The string immutable arg
    function _get128BytesStringArg(uint256 stringArgOffset) private pure returns (string calldata stringArg) {
        assembly ("memory-safe") {
            // get the offset of the packed immutable args in calldata
            let immutableArgsOffset := sub(calldatasize(), add(shr(240, calldataload(sub(calldatasize(), 2))), 2))

            // get the offset of the start of the string in the calldata
            let strStart := add(immutableArgsOffset, stringArgOffset)

            // read the length of the string, which should be stored as its 128th byte
            let strLength := shr(0xf8, calldataload(add(strStart, 0x60)))

            // set the returned calldata string offset and length
            stringArg.offset := strStart
            stringArg.length := strLength
        }
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/// @title Token that represents a user's long position
/// @author Rolla
/// @notice Can be used by owners to exercise their options
/// @dev Every option long position is an ERC20 token: https://eips.ethereum.org/EIPS/eip-20
interface IQToken {
    /// @notice mint option token for an account
    /// @param account account to mint token to
    /// @param amount amount to mint
    function mint(address account, uint256 amount) external;

    /// @notice burn option token from an account.
    /// @param account account to burn token from
    /// @param amount amount to burn
    function burn(address account, uint256 amount) external;

    /// @dev Address of the underlying asset. WETH for ethereum options.
    function underlyingAsset() external pure returns (address);

    /// @dev Address of the strike asset. Quant Web options always use USDC.
    function strikeAsset() external pure returns (address);

    /// @dev Address of the oracle to be used with this option
    function oracle() external pure returns (address);

    /// @dev The strike price for the token with the strike asset precision.
    function strikePrice() external pure returns (uint256);

    /// @dev UNIX time for the expiry of the option
    function expiryTime() external pure returns (uint88);

    /// @dev True if the option is a CALL. False if the option is a PUT.
    function isCall() external pure returns (bool);

    /// @dev Address of the Controller contract, which can mint and burn QTokens.
    function controller() external pure returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Library for converting numbers into strings and other string operations.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/LibString.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/LibString.sol)
library LibString {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                        CUSTOM ERRORS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    error HexLengthInsufficient();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     DECIMAL OPERATIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function toString(uint256 value) internal pure returns (string memory str) {
        assembly {
            // The maximum value of a uint256 contains 78 digits (1 byte per digit),
            // but we allocate 0x80 bytes to keep the free memory pointer 32-byte word aliged.
            // We will need 1 32-byte word to store the length,
            // and 3 32-byte words to store a maximum of 78 digits. Total: 0x20 + 3 * 0x20 = 0x80.
            str := add(mload(0x40), 0x80)
            // Update the free memory pointer to allocate.
            mstore(0x40, str)

            // Cache the end of the memory to calculate the length later.
            let end := str

            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            // prettier-ignore
            for { let temp := value } 1 {} {
                str := sub(str, 1)
                // Write the character to the pointer.
                // The ASCII index of the '0' character is 48.
                mstore8(str, add(48, mod(temp, 10)))
                // Keep dividing `temp` until zero.
                temp := div(temp, 10)
                // prettier-ignore
                if iszero(temp) { break }
            }

            let length := sub(end, str)
            // Move the pointer 32 bytes leftwards to make room for the length.
            str := sub(str, 0x20)
            // Store the length.
            mstore(str, length)
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   HEXADECIMAL OPERATIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory str) {
        assembly {
            let start := mload(0x40)
            // We need length * 2 bytes for the digits, 2 bytes for the prefix,
            // and 32 bytes for the length. We add 32 to the total and round down
            // to a multiple of 32. (32 + 2 + 32) = 66.
            str := add(start, and(add(shl(1, length), 66), not(31)))

            // Cache the end to calculate the length later.
            let end := str

            // Allocate the memory.
            mstore(0x40, str)
            // Store "0123456789abcdef" in scratch space.
            mstore(0x0f, 0x30313233343536373839616263646566)

            let temp := value
            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            // prettier-ignore
            for {} 1 {} {
                str := sub(str, 2)
                mstore8(add(str, 1), mload(and(temp, 15)))
                mstore8(str, mload(and(shr(4, temp), 15)))
                temp := shr(8, temp)
                length := sub(length, 1)
                // prettier-ignore
                if iszero(length) { break }
            }

            if temp {
                // Store the function selector of `HexLengthInsufficient()`.
                mstore(0x00, 0x2194895a)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            // Compute the string's length.
            let strLength := add(sub(end, str), 2)
            // Move the pointer and write the "0x" prefix.
            str := sub(str, 0x20)
            mstore(str, 0x3078)
            // Move the pointer and write the length.
            str := sub(str, 2)
            mstore(str, strLength)
        }
    }

    function toHexString(uint256 value) internal pure returns (string memory str) {
        assembly {
            let start := mload(0x40)
            // We need 0x20 bytes for the length, 0x02 bytes for the prefix,
            // and 0x40 bytes for the digits.
            // The next multiple of 0x20 above (0x20 + 2 + 0x40) is 0x80.
            str := add(start, 0x80)

            // Cache the end to calculate the length later.
            let end := str

            // Allocate the memory.
            mstore(0x40, str)
            // Store "0123456789abcdef" in scratch space.
            mstore(0x0f, 0x30313233343536373839616263646566)

            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            // prettier-ignore
            for { let temp := value } 1 {} {
                str := sub(str, 2)
                mstore8(add(str, 1), mload(and(temp, 15)))
                mstore8(str, mload(and(shr(4, temp), 15)))
                temp := shr(8, temp)
                // prettier-ignore
                if iszero(temp) { break }
            }

            // Compute the string's length.
            let strLength := add(sub(end, str), 2)
            // Move the pointer and write the "0x" prefix.
            str := sub(str, 0x20)
            mstore(str, 0x3078)
            // Move the pointer and write the length.
            str := sub(str, 2)
            mstore(str, strLength)
        }
    }

    function toHexString(address value) internal pure returns (string memory str) {
        assembly {
            let start := mload(0x40)
            // We need 32 bytes for the length, 2 bytes for the prefix,
            // and 40 bytes for the digits.
            // The next multiple of 32 above (32 + 2 + 40) is 96.
            str := add(start, 96)

            // Allocate the memory.
            mstore(0x40, str)
            // Store "0123456789abcdef" in scratch space.
            mstore(0x0f, 0x30313233343536373839616263646566)

            let length := 20
            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            // prettier-ignore
            for { let temp := value } 1 {} {
                str := sub(str, 2)
                mstore8(add(str, 1), mload(and(temp, 15)))
                mstore8(str, mload(and(shr(4, temp), 15)))
                temp := shr(8, temp)
                length := sub(length, 1)
                // prettier-ignore
                if iszero(length) { break }
            }

            // Move the pointer and write the "0x" prefix.
            str := sub(str, 32)
            mstore(str, 0x3078)
            // Move the pointer and write the length.
            str := sub(str, 2)
            mstore(str, 42)
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   OTHER STRING OPERATIONS                  */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function replace(
        string memory subject,
        string memory search,
        string memory replacement
    ) internal pure returns (string memory result) {
        assembly {
            let subjectLength := mload(subject)
            let searchLength := mload(search)
            let replacementLength := mload(replacement)

            subject := add(subject, 0x20)
            search := add(search, 0x20)
            replacement := add(replacement, 0x20)
            result := add(mload(0x40), 0x20)

            let subjectEnd := add(subject, subjectLength)
            if iszero(gt(searchLength, subjectLength)) {
                let subjectSearchEnd := add(sub(subjectEnd, searchLength), 1)
                let h := 0
                if iszero(lt(searchLength, 32)) {
                    h := keccak256(search, searchLength)
                }
                let m := shl(3, sub(32, and(searchLength, 31)))
                let s := mload(search)
                // prettier-ignore
                for {} 1 {} {
                    let t := mload(subject)
                    // Whether the first `searchLength % 32` bytes of 
                    // `subject` and `search` matches.
                    if iszero(shr(m, xor(t, s))) {
                        if h {
                            if iszero(eq(keccak256(subject, searchLength), h)) {
                                mstore(result, t)
                                result := add(result, 1)
                                subject := add(subject, 1)
                                // prettier-ignore
                                if iszero(lt(subject, subjectSearchEnd)) { break }
                                continue
                            }
                        }
                        // Copy the `replacement` one word at a time.
                        // prettier-ignore
                        for { let o := 0 } 1 {} {
                            mstore(add(result, o), mload(add(replacement, o)))
                            o := add(o, 0x20)
                            // prettier-ignore
                            if iszero(lt(o, replacementLength)) { break }
                        }
                        result := add(result, replacementLength)
                        subject := add(subject, searchLength)    
                        if iszero(searchLength) {
                            mstore(result, t)
                            result := add(result, 1)
                            subject := add(subject, 1)
                        }
                        // prettier-ignore
                        if iszero(lt(subject, subjectSearchEnd)) { break }
                        continue
                    }
                    mstore(result, t)
                    result := add(result, 1)
                    subject := add(subject, 1)
                    // prettier-ignore
                    if iszero(lt(subject, subjectSearchEnd)) { break }
                }
            }

            let resultRemainder := result
            result := add(mload(0x40), 0x20)
            let k := add(sub(resultRemainder, result), sub(subjectEnd, subject))
            // Copy the rest of the string one word at a time.
            // prettier-ignore
            for {} lt(subject, subjectEnd) {} {
                mstore(resultRemainder, mload(subject))
                resultRemainder := add(resultRemainder, 0x20)
                subject := add(subject, 0x20)
            }
            // Allocate memory for the length and the bytes,
            // rounded up to a multiple of 32.
            mstore(0x40, add(result, and(add(k, 0x40), not(0x1f))))
            result := sub(result, 0x20)
            mstore(result, k)
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ----------------------------------------------------------------------------
// DateTime Library v2.0
//
// A gas-efficient Solidity date and time library
//
// https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
//
// Tested date range 1970/01/01 to 2345/12/31
//
// Conventions:
// Unit      | Range         | Notes
// :-------- |:-------------:|:-----
// timestamp | >= 0          | Unix timestamp, number of seconds since 1970/01/01 00:00:00 UTC
// year      | 1970 ... 2345 |
// month     | 1 ... 12      |
// day       | 1 ... 31      |
// hour      | 0 ... 23      |
// minute    | 0 ... 59      |
// second    | 0 ... 59      |
// dayOfWeek | 1 ... 7       | 1 = Monday, ..., 7 = Sunday
//
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2018-2019. The MIT Licence.
// ----------------------------------------------------------------------------

library DateTime {
    uint256 constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint256 constant SECONDS_PER_HOUR = 60 * 60;
    uint256 constant SECONDS_PER_MINUTE = 60;
    int256 constant OFFSET19700101 = 2440588;

    uint256 constant DOW_MON = 1;
    uint256 constant DOW_TUE = 2;
    uint256 constant DOW_WED = 3;
    uint256 constant DOW_THU = 4;
    uint256 constant DOW_FRI = 5;
    uint256 constant DOW_SAT = 6;
    uint256 constant DOW_SUN = 7;

    // ------------------------------------------------------------------------
    // Calculate the number of days from 1970/01/01 to year/month/day using
    // the date conversion algorithm from
    //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
    // and subtracting the offset 2440588 so that 1970/01/01 is day 0
    //
    // days = day
    //      - 32075
    //      + 1461 * (year + 4800 + (month - 14) / 12) / 4
    //      + 367 * (month - 2 - (month - 14) / 12 * 12) / 12
    //      - 3 * ((year + 4900 + (month - 14) / 12) / 100) / 4
    //      - offset
    // ------------------------------------------------------------------------
    function _daysFromDate(
        uint256 year,
        uint256 month,
        uint256 day
    ) internal pure returns (uint256 _days) {
        require(year >= 1970);
        int256 _year = int256(year);
        int256 _month = int256(month);
        int256 _day = int256(day);

        int256 __days =
            _day -
                32075 +
                (1461 * (_year + 4800 + (_month - 14) / 12)) /
                4 +
                (367 * (_month - 2 - ((_month - 14) / 12) * 12)) /
                12 -
                (3 * ((_year + 4900 + (_month - 14) / 12) / 100)) /
                4 -
                OFFSET19700101;

        _days = uint256(__days);
    }

    // ------------------------------------------------------------------------
    // Calculate year/month/day from the number of days since 1970/01/01 using
    // the date conversion algorithm from
    //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
    // and adding the offset 2440588 so that 1970/01/01 is day 0
    //
    // int L = days + 68569 + offset
    // int N = 4 * L / 146097
    // L = L - (146097 * N + 3) / 4
    // year = 4000 * (L + 1) / 1461001
    // L = L - 1461 * year / 4 + 31
    // month = 80 * L / 2447
    // dd = L - 2447 * month / 80
    // L = month / 11
    // month = month + 2 - 12 * L
    // year = 100 * (N - 49) + year + L
    // ------------------------------------------------------------------------
    function _daysToDate(uint256 _days)
        internal
        pure
        returns (
            uint256 year,
            uint256 month,
            uint256 day
        )
    {
        int256 __days = int256(_days);

        int256 L = __days + 68569 + OFFSET19700101;
        int256 N = (4 * L) / 146097;
        L = L - (146097 * N + 3) / 4;
        int256 _year = (4000 * (L + 1)) / 1461001;
        L = L - (1461 * _year) / 4 + 31;
        int256 _month = (80 * L) / 2447;
        int256 _day = L - (2447 * _month) / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint256(_year);
        month = uint256(_month);
        day = uint256(_day);
    }

    function timestampFromDate(
        uint256 year,
        uint256 month,
        uint256 day
    ) internal pure returns (uint256 timestamp) {
        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY;
    }

    function timestampFromDateTime(
        uint256 year,
        uint256 month,
        uint256 day,
        uint256 hour,
        uint256 minute,
        uint256 second
    ) internal pure returns (uint256 timestamp) {
        timestamp =
            _daysFromDate(year, month, day) *
            SECONDS_PER_DAY +
            hour *
            SECONDS_PER_HOUR +
            minute *
            SECONDS_PER_MINUTE +
            second;
    }

    function timestampToDate(uint256 timestamp)
        internal
        pure
        returns (
            uint256 year,
            uint256 month,
            uint256 day
        )
    {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function timestampToDateTime(uint256 timestamp)
        internal
        pure
        returns (
            uint256 year,
            uint256 month,
            uint256 day,
            uint256 hour,
            uint256 minute,
            uint256 second
        )
    {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint256 secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
        secs = secs % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
        second = secs % SECONDS_PER_MINUTE;
    }

    function isValidDate(
        uint256 year,
        uint256 month,
        uint256 day
    ) internal pure returns (bool valid) {
        if (year >= 1970 && month > 0 && month <= 12) {
            uint256 daysInMonth = _getDaysInMonth(year, month);
            if (day > 0 && day <= daysInMonth) {
                valid = true;
            }
        }
    }

    function isValidDateTime(
        uint256 year,
        uint256 month,
        uint256 day,
        uint256 hour,
        uint256 minute,
        uint256 second
    ) internal pure returns (bool valid) {
        if (isValidDate(year, month, day)) {
            if (hour < 24 && minute < 60 && second < 60) {
                valid = true;
            }
        }
    }

    function isLeapYear(uint256 timestamp)
        internal
        pure
        returns (bool leapYear)
    {
        (uint256 year, , ) = _daysToDate(timestamp / SECONDS_PER_DAY);
        leapYear = _isLeapYear(year);
    }

    function _isLeapYear(uint256 year) internal pure returns (bool leapYear) {
        leapYear = ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);
    }

    function isWeekDay(uint256 timestamp) internal pure returns (bool weekDay) {
        weekDay = getDayOfWeek(timestamp) <= DOW_FRI;
    }

    function isWeekEnd(uint256 timestamp) internal pure returns (bool weekEnd) {
        weekEnd = getDayOfWeek(timestamp) >= DOW_SAT;
    }

    function getDaysInMonth(uint256 timestamp)
        internal
        pure
        returns (uint256 daysInMonth)
    {
        (uint256 year, uint256 month, ) =
            _daysToDate(timestamp / SECONDS_PER_DAY);
        daysInMonth = _getDaysInMonth(year, month);
    }

    function _getDaysInMonth(uint256 year, uint256 month)
        internal
        pure
        returns (uint256 daysInMonth)
    {
        if (
            month == 1 ||
            month == 3 ||
            month == 5 ||
            month == 7 ||
            month == 8 ||
            month == 10 ||
            month == 12
        ) {
            daysInMonth = 31;
        } else if (month != 2) {
            daysInMonth = 30;
        } else {
            daysInMonth = _isLeapYear(year) ? 29 : 28;
        }
    }

    // 1 = Monday, 7 = Sunday
    function getDayOfWeek(uint256 timestamp)
        internal
        pure
        returns (uint256 dayOfWeek)
    {
        uint256 _days = timestamp / SECONDS_PER_DAY;
        dayOfWeek = ((_days + 3) % 7) + 1;
    }

    function getYear(uint256 timestamp) internal pure returns (uint256 year) {
        (year, , ) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function getMonth(uint256 timestamp) internal pure returns (uint256 month) {
        (, month, ) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function getDay(uint256 timestamp) internal pure returns (uint256 day) {
        (, , day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function getHour(uint256 timestamp) internal pure returns (uint256 hour) {
        uint256 secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
    }

    function getMinute(uint256 timestamp)
        internal
        pure
        returns (uint256 minute)
    {
        uint256 secs = timestamp % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
    }

    function getSecond(uint256 timestamp)
        internal
        pure
        returns (uint256 second)
    {
        second = timestamp % SECONDS_PER_MINUTE;
    }

    function addYears(uint256 timestamp, uint256 _years)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        (uint256 year, uint256 month, uint256 day) =
            _daysToDate(timestamp / SECONDS_PER_DAY);
        year += _years;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp =
            _daysFromDate(year, month, day) *
            SECONDS_PER_DAY +
            (timestamp % SECONDS_PER_DAY);
        require(newTimestamp >= timestamp);
    }

    function addMonths(uint256 timestamp, uint256 _months)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        (uint256 year, uint256 month, uint256 day) =
            _daysToDate(timestamp / SECONDS_PER_DAY);
        month += _months;
        year += (month - 1) / 12;
        month = ((month - 1) % 12) + 1;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp =
            _daysFromDate(year, month, day) *
            SECONDS_PER_DAY +
            (timestamp % SECONDS_PER_DAY);
        require(newTimestamp >= timestamp);
    }

    function addDays(uint256 timestamp, uint256 _days)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp + _days * SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }

    function addHours(uint256 timestamp, uint256 _hours)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp + _hours * SECONDS_PER_HOUR;
        require(newTimestamp >= timestamp);
    }

    function addMinutes(uint256 timestamp, uint256 _minutes)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp + _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp >= timestamp);
    }

    function addSeconds(uint256 timestamp, uint256 _seconds)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp + _seconds;
        require(newTimestamp >= timestamp);
    }

    function subYears(uint256 timestamp, uint256 _years)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        (uint256 year, uint256 month, uint256 day) =
            _daysToDate(timestamp / SECONDS_PER_DAY);
        year -= _years;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp =
            _daysFromDate(year, month, day) *
            SECONDS_PER_DAY +
            (timestamp % SECONDS_PER_DAY);
        require(newTimestamp <= timestamp);
    }

    function subMonths(uint256 timestamp, uint256 _months)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        (uint256 year, uint256 month, uint256 day) =
            _daysToDate(timestamp / SECONDS_PER_DAY);
        uint256 yearMonth = year * 12 + (month - 1) - _months;
        year = yearMonth / 12;
        month = (yearMonth % 12) + 1;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp =
            _daysFromDate(year, month, day) *
            SECONDS_PER_DAY +
            (timestamp % SECONDS_PER_DAY);
        require(newTimestamp <= timestamp);
    }

    function subDays(uint256 timestamp, uint256 _days)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp - _days * SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }

    function subHours(uint256 timestamp, uint256 _hours)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp - _hours * SECONDS_PER_HOUR;
        require(newTimestamp <= timestamp);
    }

    function subMinutes(uint256 timestamp, uint256 _minutes)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp - _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp <= timestamp);
    }

    function subSeconds(uint256 timestamp, uint256 _seconds)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp - _seconds;
        require(newTimestamp <= timestamp);
    }

    function diffYears(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _years)
    {
        require(fromTimestamp <= toTimestamp);
        (uint256 fromYear, , ) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint256 toYear, , ) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _years = toYear - fromYear;
    }

    function diffMonths(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _months)
    {
        require(fromTimestamp <= toTimestamp);
        (uint256 fromYear, uint256 fromMonth, ) =
            _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint256 toYear, uint256 toMonth, ) =
            _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _months = toYear * 12 + toMonth - fromYear * 12 - fromMonth;
    }

    function diffDays(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _days)
    {
        require(fromTimestamp <= toTimestamp);
        _days = (toTimestamp - fromTimestamp) / SECONDS_PER_DAY;
    }

    function diffHours(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _hours)
    {
        require(fromTimestamp <= toTimestamp);
        _hours = (toTimestamp - fromTimestamp) / SECONDS_PER_HOUR;
    }

    function diffMinutes(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _minutes)
    {
        require(fromTimestamp <= toTimestamp);
        _minutes = (toTimestamp - fromTimestamp) / SECONDS_PER_MINUTE;
    }

    function diffSeconds(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _seconds)
    {
        require(fromTimestamp <= toTimestamp);
        _seconds = toTimestamp - fromTimestamp;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/// @title For centrally managing a list of oracle providers
/// @author Rolla
/// @notice oracle provider registry for holding a list of oracle providers and their id
interface IOracleRegistry {
    event AddedOracle(address oracle, uint248 oracleId);

    event ActivatedOracle(address oracle);

    event DeactivatedOracle(address oracle);

    /// @notice Add an oracle to the oracle registry which will generate an id. By default oracles are deactivated
    /// @param _oracle the address of the oracle
    /// @return the id of the oracle
    function addOracle(address _oracle) external returns (uint248);

    /// @notice Deactivate an oracle so no new options can be created with this oracle address.
    /// @param _oracle the oracle to deactivate
    function deactivateOracle(address _oracle) external returns (bool);

    /// @notice Activate an oracle so options can be created with this oracle address.
    /// @param _oracle the oracle to activate
    function activateOracle(address _oracle) external returns (bool);

    /// @notice oracle address => OracleInfo
    function oracleInfo(address) external view returns (bool, uint248);

    /// @notice exhaustive list of oracles in map
    function oracles(uint256) external view returns (address);

    /// @notice Check if an oracle is registered in the registry
    /// @param _oracle the oracle to check
    function isOracleRegistered(address _oracle) external view returns (bool);

    /// @notice Check if an oracle is active i.e. are we allowed to create options with this oracle
    /// @param _oracle the oracle to check
    function isOracleActive(address _oracle) external view returns (bool);

    /// @notice Get the numeric id of an oracle
    /// @param _oracle the oracle to get the id of
    function getOracleId(address _oracle) external view returns (uint248);

    /// @notice Get total number of oracles in registry
    /// @return the number of oracles in the registry
    function getOraclesLength() external view returns (uint248);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/// @title Oracle manager for holding asset addresses and their oracle addresses for a single provider
/// @author Rolla
/// @notice Once an oracle is added for an asset it can't be changed!
interface IProviderOracleManager {
    event OracleAdded(address asset, address oracle);

    /// @notice Add an asset to the oracle manager with its corresponding oracle address
    /// @dev Once this is set for an asset, it can't be changed or removed
    /// @param _asset the address of the asset token we are adding the oracle for
    /// @param _oracle the address of the oracle
    function addAssetOracle(address _asset, address _oracle) external;

    /// @notice Get the expiry price from oracle and store it in the price registry so we have a copy
    /// @param _asset asset to set price of
    /// @param _expiryTimestamp timestamp of price
    /// @param _calldata additional parameter that the method may need to execute
    function setExpiryPriceInRegistry(address _asset, uint88 _expiryTimestamp, bytes memory _calldata) external;

    /// @notice asset address => oracle address
    function assetOracles(address) external view returns (address);

    /// @notice exhaustive list of asset addresses in map
    function assets(uint256) external view returns (address);

    /// @notice Get the oracle address associated with an asset
    /// @param _asset asset to get price of
    function getAssetOracle(address _asset) external view returns (address);

    /// @notice Get the total number of assets managed by the oracle manager
    /// @return total number of assets managed by the oracle manager
    function getAssetsLength() external view returns (uint256);

    /// @notice Function that should be overridden which should return the current price of an asset from the provider
    /// @param _asset the address of the asset token we want the price for
    /// @return the current price of the asset
    function getCurrentPrice(address _asset) external view returns (uint256);

    /// @notice Checks if the option is valid for the oracle manager with the given parameters
    /// @param _underlyingAsset the address of the underlying asset
    /// @param _expiryTime the expiry timestamp of the option
    /// @param _strikePrice the strike price of the option
    function isValidOption(address _underlyingAsset, uint88 _expiryTime, uint256 _strikePrice)
        external
        view
        returns (bool);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

interface IAssetsRegistry {
    /// @notice emitted when a new asset is added to the registry
    /// @param underlying address of the asset
    /// @param name name of the asset
    /// @param symbol symbol of the asset
    /// @param decimals the amount of decimals the asset has
    event AssetAdded(address indexed underlying, string name, string symbol, uint8 decimals);

    /// @notice Add a new asset to the registry
    /// @dev It will revert when trying to add an asset with the same address twice
    /// @dev Can only be called by addresses with the ASSETS_REGISTRY_MANAGER_ROLE role
    /// @param _underlying address of the asset
    /// @param _name name of the asset
    /// @param _symbol symbol of the asset
    /// @param _decimals the amount of decimals the asset has
    function addAsset(address _underlying, string calldata _name, string calldata _symbol, uint8 _decimals) external;

    /// @notice Add a new asset to the registry, calling the optional ERC20 methods
    /// to get its name, symbol and decimals
    /// @param _underlying address of the asset
    function addAssetWithOptionalERC20Methods(address _underlying) external;

    /// @notice Returns the name, symbol and decimals of an asset that's already in the registry
    /// @dev Will return empty strings and zero for non-existent assets
    /// @return name asset's name
    /// @return symbol asset's symbol
    /// @return decimals asset's decimals
    /// @return isRegistered true if the asset is in the registry, false otherwise
    function assetProperties(address asset)
        external
        view
        returns (string memory name, string memory symbol, uint8 decimals, bool isRegistered);

    /// @notice Returns the address of the asset at the given index
    /// @param index index of the asset in the registry
    /// @return asset address of the asset at the given index
    function registeredAssets(uint256 index) external view returns (address asset);

    /// @notice Returns the number of assets in the registry
    /// @return length number of assets in the registry
    function getAssetsLength() external view returns (uint256 length);
}

// SPDX-License-Identifier: BSD
pragma solidity ^0.8.4;

/// @title Clone
/// @author zefram.eth
/// @notice Provides helper functions for reading immutable args from calldata
contract Clone {
    /// @notice Reads an immutable arg with type address
    /// @param argOffset The offset of the arg in the packed data
    /// @return arg The arg value
    function _getArgAddress(uint256 argOffset) internal pure returns (address arg) {
        uint256 offset = _getImmutableArgsOffset();
        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            arg := shr(0x60, calldataload(add(offset, argOffset)))
        }
    }

    /// @notice Reads an immutable arg with type uint256
    /// @param argOffset The offset of the arg in the packed data
    /// @return arg The arg value
    function _getArgUint256(uint256 argOffset) internal pure returns (uint256 arg) {
        uint256 offset = _getImmutableArgsOffset();
        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            arg := calldataload(add(offset, argOffset))
        }
    }

    /// @notice Reads a uint256 array stored in the immutable args.
    /// @param argOffset The offset of the arg in the packed data
    /// @param arrLen Number of elements in the array
    /// @return arr The array
    function _getArgUint256Array(uint256 argOffset, uint64 arrLen) internal pure returns (uint256[] memory arr) {
        uint256 offset = _getImmutableArgsOffset();
        uint256 el;
        arr = new uint256[](arrLen);
        for (uint64 i = 0; i < arrLen; i++) {
            // solhint-disable-next-line no-inline-assembly
            assembly ("memory-safe") {
                el := calldataload(add(add(offset, argOffset), mul(i, 32)))
            }
            arr[i] = el;
        }
        return arr;
    }

    /// @notice Reads an immutable arg with type uint88
    /// @param argOffset The offset of the arg in the packed data
    /// @return arg The arg value
    function _getArgUint88(uint256 argOffset) internal pure returns (uint88 arg) {
        uint256 offset = _getImmutableArgsOffset();
        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            arg := shr(0xa8, calldataload(add(offset, argOffset)))
        }
    }

    /// @notice Reads an immutable arg with type uint8
    /// @param argOffset The offset of the arg in the packed data
    /// @return arg The arg value
    function _getArgUint8(uint256 argOffset) internal pure returns (uint8 arg) {
        uint256 offset = _getImmutableArgsOffset();
        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            arg := shr(0xf8, calldataload(add(offset, argOffset)))
        }
    }

    /// @notice Reads an immutable arg with type bool
    /// @param argOffset The offset of the arg in the packed data
    /// @return arg The arg value
    function _getArgBool(uint256 argOffset) internal pure returns (bool arg) {
        uint256 offset = _getImmutableArgsOffset();
        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            arg := shr(0xf8, calldataload(add(offset, argOffset)))
        }
    }

    /// @return offset The offset of the packed immutable args in calldata
    function _getImmutableArgsOffset() internal pure returns (uint256 offset) {
        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            offset := sub(calldatasize(), add(shr(240, calldataload(sub(calldatasize(), 2))), 2))
        }
    }
}