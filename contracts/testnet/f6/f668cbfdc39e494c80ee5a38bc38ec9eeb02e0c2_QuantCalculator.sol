// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.16;

import "./options/CollateralToken.sol";
import "./interfaces/IQuantCalculator.sol";
import "./interfaces/IOptionsFactory.sol";
import "./interfaces/IQToken.sol";
import "./interfaces/IPriceRegistry.sol";
import "./libraries/FundsCalculator.sol";
import "./libraries/OptionsUtils.sol";
import "./libraries/QuantMath.sol";

/// @title For calculating collateral requirements and payouts for options and spreads
/// @author Rolla
/// @dev Uses fixed point arithmetic from the QuantMath library.
contract QuantCalculator is IQuantCalculator {
    using QuantMath for uint256;
    using QuantMath for int256;
    using QuantMath for QuantMath.FixedPointInt;

    /// @inheritdoc IQuantCalculator
    uint8 public immutable override optionsDecimals;

    /// @inheritdoc IQuantCalculator
    uint8 public immutable override strikeAssetDecimals;

    /// @inheritdoc IQuantCalculator
    address public immutable override optionsFactory;

    /// @inheritdoc IQuantCalculator
    address public immutable override assetsRegistry;

    /// @inheritdoc IQuantCalculator
    address public immutable override priceRegistry;

    /// @notice Checks that the QToken was created through the configured OptionsFactory
    modifier validQToken(address _qToken) {
        require(IOptionsFactory(optionsFactory).isQToken(_qToken), "QuantCalculator: Invalid QToken address");

        _;
    }

    /// @notice Checks that the QToken used as collateral for a spread is either the zero address
    /// or a QToken created through the configured OptionsFactory
    modifier validQTokenAsCollateral(address _qTokenAsCollateral) {
        if (_qTokenAsCollateral != address(0)) {
            // it could be the zero address for the qTokenAsCollateral for non-spreads
            require(
                IOptionsFactory(optionsFactory).isQToken(_qTokenAsCollateral), "QuantCalculator: Invalid QToken address"
            );
        }

        _;
    }

    /// @param _optionsFactory the address of the OptionsFactory contract
    /// @param _assetsRegistry the address of the AssetsRegistry contract
    /// @param _priceRegistry the address of the PriceRegistry contract
    constructor(address _optionsFactory, address _assetsRegistry, address _priceRegistry) {
        require(_optionsFactory != address(0), "QuantCalculator: invalid OptionsFactory address");
        require(_assetsRegistry != address(0), "QuantCalculator: invalid AssetsRegistry address");
        require(_priceRegistry != address(0), "QuantCalculator: invalid PriceRegistry address");

        optionsDecimals = IOptionsFactory(_optionsFactory).optionsDecimals();
        strikeAssetDecimals = OptionsUtils.STRIKE_PRICE_DECIMALS;
        optionsFactory = _optionsFactory;
        assetsRegistry = _assetsRegistry;
        priceRegistry = _priceRegistry;
    }

    /// @inheritdoc IQuantCalculator
    function calculateClaimableCollateral(uint256 _collateralTokenId, uint256 _amount, address _user)
        external
        view
        override
        returns (uint256 returnableCollateral, address collateralAsset, uint256 amountToClaim)
    {
        CollateralToken collateralToken = CollateralToken(IOptionsFactory(optionsFactory).collateralToken());

        (address _qTokenShort, address qTokenAsCollateral) = collateralToken.idToInfo(_collateralTokenId);

        IQToken qTokenShort = IQToken(_qTokenShort);
        address oracle = qTokenShort.oracle();
        uint88 expiryTime = qTokenShort.expiryTime();
        address underlyingAsset = qTokenShort.underlyingAsset();

        require(block.timestamp > qTokenShort.expiryTime(), "Can not claim collateral from options before their expiry");
        require(
            IPriceRegistry(priceRegistry).getOptionPriceStatus(oracle, expiryTime, underlyingAsset) == PriceStatus.SETTLED,
            "Can not claim collateral before option is settled"
        );

        amountToClaim = _amount == 0 ? collateralToken.balanceOf(_user, _collateralTokenId) : _amount;

        PriceWithDecimals memory expiryPrice =
            IPriceRegistry(priceRegistry).getSettlementPriceWithDecimals(oracle, expiryTime, underlyingAsset);

        address qTokenLong;
        QuantMath.FixedPointInt memory payoutFromLong;

        if (qTokenAsCollateral != address(0)) {
            qTokenLong = qTokenAsCollateral;

            (, payoutFromLong) =
                FundsCalculator.getPayout(qTokenLong, amountToClaim, optionsDecimals, strikeAssetDecimals, expiryPrice);
        } else {
            qTokenLong = address(0);
            payoutFromLong = int256(0).fromUnscaledInt();
        }

        uint8 payoutDecimals = OptionsUtils.getPayoutDecimals(qTokenShort, assetsRegistry);

        QuantMath.FixedPointInt memory collateralRequirement;
        (collateralAsset, collateralRequirement) = FundsCalculator.getCollateralRequirement(
            _qTokenShort, qTokenLong, amountToClaim, optionsDecimals, payoutDecimals, strikeAssetDecimals
        );

        (, QuantMath.FixedPointInt memory payoutFromShort) =
            FundsCalculator.getPayout(_qTokenShort, amountToClaim, optionsDecimals, strikeAssetDecimals, expiryPrice);

        returnableCollateral =
            payoutFromLong.add(collateralRequirement).sub(payoutFromShort).toScaledUint(payoutDecimals, true);
    }

    /// @inheritdoc IQuantCalculator
    function getNeutralizationPayout(address _qTokenShort, address _qTokenLong, uint256 _amountToNeutralize)
        external
        view
        override
        returns (address collateralType, uint256 collateralOwed)
    {
        uint8 payoutDecimals = OptionsUtils.getPayoutDecimals(IQToken(_qTokenShort), assetsRegistry);

        QuantMath.FixedPointInt memory collateralOwedFP;
        (collateralType, collateralOwedFP) = FundsCalculator.getCollateralRequirement(
            _qTokenShort, _qTokenLong, _amountToNeutralize, optionsDecimals, payoutDecimals, strikeAssetDecimals
        );

        collateralOwed = collateralOwedFP.toScaledUint(payoutDecimals, true);
    }

    /// @inheritdoc IQuantCalculator
    function getCollateralRequirement(address _qTokenToMint, address _qTokenForCollateral, uint256 _amount)
        external
        view
        override
        validQToken(_qTokenToMint)
        validQTokenAsCollateral(_qTokenForCollateral)
        returns (address collateral, uint256 collateralAmount)
    {
        QuantMath.FixedPointInt memory collateralAmountFP;
        uint8 payoutDecimals = OptionsUtils.getPayoutDecimals(IQToken(_qTokenToMint), assetsRegistry);

        (collateral, collateralAmountFP) = FundsCalculator.getCollateralRequirement(
            _qTokenToMint, _qTokenForCollateral, _amount, optionsDecimals, payoutDecimals, strikeAssetDecimals
        );

        collateralAmount = collateralAmountFP.toScaledUint(payoutDecimals, false);
    }

    /// @inheritdoc IQuantCalculator
    function getExercisePayout(address _qToken, uint256 _amount)
        external
        view
        override
        validQToken(_qToken)
        returns (bool isSettled, address payoutToken, uint256 payoutAmount)
    {
        IQToken qToken = IQToken(_qToken);
        address oracle = qToken.oracle();
        uint88 expiryTime = qToken.expiryTime();
        address underlyingAsset = qToken.underlyingAsset();

        isSettled =
            IPriceRegistry(priceRegistry).getOptionPriceStatus(oracle, expiryTime, underlyingAsset) == PriceStatus.SETTLED;
        if (!isSettled) {
            return (isSettled, payoutToken, payoutAmount);
        }

        QuantMath.FixedPointInt memory payout;

        uint8 payoutDecimals = OptionsUtils.getPayoutDecimals(qToken, assetsRegistry);

        PriceWithDecimals memory expiryPrice =
            IPriceRegistry(priceRegistry).getSettlementPriceWithDecimals(oracle, expiryTime, underlyingAsset);

        (payoutToken, payout) =
            FundsCalculator.getPayout(_qToken, _amount, optionsDecimals, strikeAssetDecimals, expiryPrice);

        payoutAmount = payout.toScaledUint(payoutDecimals, true);
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.16;

import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@rari-capital/solmate/src/tokens/ERC1155.sol";
import "../interfaces/ICollateralToken.sol";

/// @title Tokens representing a Quant user's short positions
/// @author Rolla
/// @notice Can be used by holders to claim their collateral
/// @dev This is a multi-token contract that implements the ERC1155 token standard:
/// https://eips.ethereum.org/EIPS/eip-1155
contract CollateralToken is ERC1155, ICollateralToken, EIP712, Ownable {
    using ECDSA for bytes32;

    /// @dev stores metadata for a CollateralToken with an specific id
    /// @param qTokenAddress address of the corresponding QToken
    /// @param qTokenAsCollateral QToken address of an option used as collateral in a spread
    struct CollateralTokenInfo {
        address qTokenAddress;
        address qTokenAsCollateral;
    }

    /// @inheritdoc ICollateralToken
    mapping(uint256 => CollateralTokenInfo) public override idToInfo;

    // Signature nonce per address
    mapping(address => uint256) public nonces;

    // base URI for ERC1155 token metadata
    string private _uri;

    // keccak256(
    //     "metaSetApprovalForAll(address cTokenOwner,address operator,bool approved,uint256 nonce,uint256 deadline)"
    // );
    bytes32 private constant _META_APPROVAL_TYPEHASH =
        0x8733d126a676f1e83270eccfbe576f65af55d3ff784c4dc4884be48932f47c81;

    // address of the OptionsFactory that will be able to create new CollateralTokens
    address private _optionsFactory;

    modifier onlyFactory() {
        require(msg.sender == _optionsFactory, "CollateralToken: caller is not OptionsFactory");

        _;
    }

    /// @notice Initializes a new ERC1155 multi-token contract for representing
    /// users' short positions
    /// @param _name name for the domain typehash in EIP712 meta transactions
    /// @param _version version for the domain typehash in EIP712 meta transactions
    /// @param uri_ URI for ERC1155 tokens metadata
    constructor(string memory _name, string memory _version, string memory uri_) EIP712(_name, _version) {
        _uri = uri_;
    }

    /// @inheritdoc ICollateralToken
    function setOptionsFactory(address optionsFactory_) external onlyOwner {
        _optionsFactory = optionsFactory_;
    }

    /// @inheritdoc ICollateralToken
    function createOptionCollateralToken(address _qTokenAddress) external override onlyFactory returns (uint256 id) {
        id = getCollateralTokenId(_qTokenAddress, address(0));

        idToInfo[id] = CollateralTokenInfo({qTokenAddress: _qTokenAddress, qTokenAsCollateral: address(0)});

        emit CollateralTokenCreated(_qTokenAddress, address(0), id);
    }

    /// @inheritdoc ICollateralToken
    function createSpreadCollateralToken(address _qTokenAddress, address _qTokenAsCollateral)
        external
        override
        onlyOwner
        returns (uint256 id)
    {
        id = getCollateralTokenId(_qTokenAddress, _qTokenAsCollateral);

        require(
            _qTokenAddress != _qTokenAsCollateral,
            "CollateralToken: Can only create a collateral token with different tokens"
        );

        idToInfo[id] = CollateralTokenInfo({qTokenAddress: _qTokenAddress, qTokenAsCollateral: _qTokenAsCollateral});

        emit CollateralTokenCreated(_qTokenAddress, _qTokenAsCollateral, id);
    }

    /// @inheritdoc ICollateralToken
    function mintCollateralToken(address recipient, uint256 collateralTokenId, uint256 amount)
        external
        override
        onlyOwner
    {
        _mint(recipient, collateralTokenId, amount, "");
    }

    /// @inheritdoc ICollateralToken
    function burnCollateralToken(address cTokenOwner, uint256 collateralTokenId, uint256 amount)
        external
        override
        onlyOwner
    {
        _burn(cTokenOwner, collateralTokenId, amount);
    }

    /// @inheritdoc ICollateralToken
    function metaSetApprovalForAll(
        address cTokenOwner,
        address operator,
        bool approved,
        uint256 nonce,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
        override
    {
        require(nonce == nonces[cTokenOwner], "CollateralToken: invalid nonce");

        // solhint-disable-next-line not-rely-on-time
        require(deadline >= block.timestamp, "CollateralToken: expired deadline");

        bytes32 structHash =
            keccak256(abi.encode(_META_APPROVAL_TYPEHASH, cTokenOwner, operator, approved, nonce, deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = hash.recover(v, r, s);

        require(signer == cTokenOwner, "CollateralToken: invalid signature");

        unchecked {
            nonces[cTokenOwner]++;
        }

        isApprovedForAll[cTokenOwner][operator] = approved;

        emit ApprovalForAll(cTokenOwner, operator, approved);
    }

    /// @notice Gets the URI for the CollateralToken metadata
    /// @return uri_ URI for the CollateralToken metadata
    function uri(uint256) public view override returns (string memory uri_) {
        uri_ = _uri;
    }

    /// @inheritdoc ICollateralToken
    function getCollateralTokenId(address _qToken, address _qTokenAsCollateral)
        public
        pure
        override
        returns (uint256 id)
    {
        id = uint256(keccak256(abi.encodePacked(_qToken, _qTokenAsCollateral)));
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/// @title For calculating collateral requirements and payouts for options and spreads
/// @author Rolla
interface IQuantCalculator {
    /// @notice Calculates the amount of collateral that can be claimed back post-settlement
    /// from a CollateralToken
    /// @param _collateralTokenId the id of the collateral token that is being claimed
    /// @param _amount the amount of the collateral token being claimed. passing 0 claims the
    /// users whole collateral token balance (does a balance lookup)
    /// @param _user the address of the claiming account
    /// @return returnableCollateral the amount of collateral that will be returned from the claim
    /// @return collateralAsset the address of the asset that will be returned from the claim
    /// @return amountToClaim the amount of collateral tokens claimed. can only different to _amount
    /// when the _amount passed was 0 and the user had a collateral token balance > 0
    function calculateClaimableCollateral(uint256 _collateralTokenId, uint256 _amount, address _user)
        external
        view
        returns (uint256 returnableCollateral, address collateralAsset, uint256 amountToClaim);

    /// @notice Calculates the collateral required to mint an option or a spread
    /// @param _qTokenToMint the desired qToken
    /// @param _qTokenForCollateral for spreads, this is the address of the qtoken to be used as collateral.
    /// for options, no collateral is provided so the zero address should be passed.
    /// @param _amount the amount of options/spread to mint
    /// @return collateral the address of the collateral token required
    /// @return collateralAmount the amount of collateral that is required to mint the option/spread
    function getCollateralRequirement(address _qTokenToMint, address _qTokenForCollateral, uint256 _amount)
        external
        view
        returns (address collateral, uint256 collateralAmount);

    /// @notice Calculates exercisable amount of an option post-expiry
    /// @param _qToken address of the qToken being exercised
    /// @param _amount the amount of the qToken being exercised
    /// @return isSettled true if there is a settlement price for this option
    /// and it can be exercised. false if there is no settlement price for this
    /// option meaning it can't be exercised. if this value is false, payoutToken
    /// will return the zero address and payout amount will be 0.
    /// @return payoutToken the token that will be received from exercise. this will
    /// return the zero address if the option is unsettled (can't exercise unsettled option)
    /// @return payoutAmount the amount of payoutToken that will be received from exercising.
    /// zero if the option is unsettled (can't exercise unsettled option)
    function getExercisePayout(address _qToken, uint256 _amount)
        external
        view
        returns (bool isSettled, address payoutToken, uint256 payoutAmount);

    /// @notice Calculates the amount that will be received from neutralizing an option or spread.
    /// Neutralizing is the opposite action to mint - you give collateral token and qToken and receive
    /// back collateral required to mint. Thus, the calculation is the same as getting the collateral
    /// requirement with the only difference being rounding.
    /// For neutralizing a spread, not only will the collateral provided be returned (if any), but also
    /// the qToken that was provided as collateral when minting the spread will also be returned.
    /// @param _qTokenShort the desired qToken
    /// @param _qTokenLong for spreads, this is the address of the qtoken to be used as collateral.
    /// for options, no collateral is provided so the zero address should be passed.
    /// @param _amountToNeutralize the amount of options/spread being neutralized
    /// @return collateralType the token that will be returned from neutralizing. this is the same
    /// as the token that was provided when minting since this method is returning that collateral
    /// back.
    /// @return collateralOwed the amount of collateral that will be returned from neutralizing.
    /// given the same parameters used for minting this will return the same amount of collateral
    /// in all cases except when there is rounding involved. in those cases, the difference will be
    /// 1 unit of collateral less for the neutralize than the mint.
    function getNeutralizationPayout(address _qTokenShort, address _qTokenLong, uint256 _amountToNeutralize)
        external
        view
        returns (address collateralType, uint256 collateralOwed);

    /// @notice The amount of decimals for Quant options
    function optionsDecimals() external view returns (uint8);

    /// @notice The amount of decimals for the strike asset used in the Quant Protocol
    function strikeAssetDecimals() external view returns (uint8);

    /// @notice The address of the factory contract that creates Quant options
    function optionsFactory() external view returns (address);

    /// @notice The address of the AssetsRegistry contract
    function assetsRegistry() external view returns (address);

    /// @notice The address of the PriceRegistry contract
    function priceRegistry() external view returns (address);
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

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/// @dev Current pricing status of option. Only SETTLED options can be exercised
enum PriceStatus {
    ACTIVE,
    AWAITING_SETTLEMENT_PRICE,
    SETTLED
}

struct PriceWithDecimals {
    uint256 price;
    uint8 decimals;
}

/// @title For centrally managing a log of settlement prices, for each option.
/// @author Rolla
interface IPriceRegistry {
    event PriceStored(
        address indexed _oracle,
        address indexed _asset,
        uint88 indexed _expiryTime,
        uint8 _settlementPriceDecimals,
        uint256 _settlementPrice
    );

    /// @notice Set the price at settlement for a particular asset, expiry
    /// @param _asset asset to set price for
    /// @param _expiryTime timestamp of price to set
    /// @param _settlementPriceDecimals number of decimals in settlement price
    /// @param _settlementPrice price at settlement
    function setSettlementPrice(
        address _asset,
        uint88 _expiryTime,
        uint8 _settlementPriceDecimals,
        uint256 _settlementPrice
    )
        external;

    /// @notice Fetch the settlement price with decimals from an oracle for an asset at a particular timestamp.
    /// @param _oracle oracle which price should come from
    /// @param _expiryTime timestamp we want the price for
    /// @param _asset asset to fetch price for
    /// @return the price (with decimals) which has been submitted for the asset at the timestamp by that oracle
    function getSettlementPriceWithDecimals(address _oracle, uint88 _expiryTime, address _asset)
        external
        view
        returns (PriceWithDecimals memory);

    /// @notice Fetch the settlement price from an oracle for an asset at a particular timestamp.
    /// @notice Rounds down if there's extra precision from the oracle
    /// @param _oracle oracle which price should come from
    /// @param _expiryTime timestamp we want the price for
    /// @param _asset asset to fetch price for
    /// @return the price which has been submitted for the asset at the timestamp by that oracle
    function getSettlementPrice(address _oracle, uint88 _expiryTime, address _asset) external view returns (uint256);

    /// @notice Get the price status of the option.
    /// @return the price status of the option. option is either active, awaiting settlement price or settled
    function getOptionPriceStatus(address _oracle, uint88 _expiryTime, address _asset)
        external
        view
        returns (PriceStatus);

    /// @notice Check if the settlement price for an asset exists from an oracle at a particular timestamp
    /// @param _oracle oracle from which price comes from
    /// @param _expiryTime timestamp of price
    /// @param _asset asset to check price for
    /// @return whether or not a price has been submitted for the asset at the timestamp by that oracle
    function hasSettlementPrice(address _oracle, uint88 _expiryTime, address _asset) external view returns (bool);

    // @notice The address of the OracleRegistry contract
    function oracleRegistry() external view returns (address);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.16;

import "./QuantMath.sol";
import "../interfaces/IQToken.sol";
import {PriceWithDecimals} from "../interfaces/IPriceRegistry.sol";

/// @title For calculating collateral requirements and payouts for options and spreads
/// in a fixed point format
/// @author Rolla
library FundsCalculator {
    using QuantMath for uint256;
    using QuantMath for int256;
    using QuantMath for QuantMath.FixedPointInt;

    struct OptionPayoutInput {
        QuantMath.FixedPointInt strikePrice;
        QuantMath.FixedPointInt expiryPrice;
        QuantMath.FixedPointInt amount;
    }

    /// @notice Calculates payout of an option post-expiry from a qToken address
    /// @param _qToken the address of the qToken (option) which is being exercised
    /// @param _amount the amount of the qToken which is being exercised
    /// @param _optionsDecimals option decimals constant. qTokens have 18 decimals
    /// @param _strikeAssetDecimals the amount of decimals the strike asset has
    /// @param _expiryPrice the expiry price of the option with the amount of decimals
    /// @return payoutToken the address of the payout token
    /// @return payoutAmount the amount to be payed out as a fixed point type
    function getPayout(
        address _qToken,
        uint256 _amount,
        uint8 _optionsDecimals,
        uint8 _strikeAssetDecimals,
        PriceWithDecimals memory _expiryPrice
    )
        internal
        pure
        returns (address payoutToken, QuantMath.FixedPointInt memory payoutAmount)
    {
        IQToken qToken = IQToken(_qToken);
        bool isCall = qToken.isCall();

        payoutToken = isCall ? qToken.underlyingAsset() : qToken.strikeAsset();

        payoutAmount =
            getPayoutAmount(isCall, qToken.strikePrice(), _amount, _optionsDecimals, _strikeAssetDecimals, _expiryPrice);
    }

    /// @notice Calculates the collateral required to mint an option or a spread
    /// @param _qTokenToMint the desired qToken
    /// @param _qTokenForCollateral for spreads, this is the address of the qtoken to be used as collateral.
    /// for options, no collateral is provided so the zero address should be passed.
    /// @param _optionsAmount the amount of options/spread to mint
    /// @param _optionsDecimals option decimals constant. qTokens have 18 decimals
    /// @param _underlyingDecimals the amount of decimals the underlying asset has
    /// @param _strikeAssetDecimals the amount of decimals the strike asset has
    /// @return collateral the address of the collateral token required
    /// @return collateralAmount the collateral amount required as a fixed point type
    function getCollateralRequirement(
        address _qTokenToMint,
        address _qTokenForCollateral,
        uint256 _optionsAmount,
        uint8 _optionsDecimals,
        uint8 _underlyingDecimals,
        uint8 _strikeAssetDecimals
    )
        internal
        pure
        returns (address collateral, QuantMath.FixedPointInt memory collateralAmount)
    {
        IQToken qTokenToMint = IQToken(_qTokenToMint);
        uint256 qTokenToMintStrikePrice = qTokenToMint.strikePrice();

        uint256 qTokenForCollateralStrikePrice;

        // check if we're getting the collateral requirement for a spread
        if (_qTokenForCollateral != address(0)) {
            IQToken qTokenForCollateral = IQToken(_qTokenForCollateral);
            qTokenForCollateralStrikePrice = qTokenForCollateral.strikePrice();

            // Check that expiries match
            require(
                qTokenToMint.expiryTime() == qTokenForCollateral.expiryTime(),
                "Controller: Can't create spreads from options with different expiries"
            );

            // Check that the underlyings match
            require(
                qTokenToMint.underlyingAsset() == qTokenForCollateral.underlyingAsset(),
                "Controller: Can't create spreads from options with different underlying assets"
            );

            // Check that the option types match
            require(
                qTokenToMint.isCall() == qTokenForCollateral.isCall(),
                "Controller: Can't create spreads from options with different types"
            );

            // Check that the options have a matching oracle
            require(
                qTokenToMint.oracle() == qTokenForCollateral.oracle(),
                "Controller: Can't create spreads from options with different oracles"
            );
        } else {
            // we're not getting the collateral requirement for a spread
            qTokenForCollateralStrikePrice = 0;
        }

        collateralAmount = getOptionCollateralRequirement(
            qTokenToMintStrikePrice,
            qTokenForCollateralStrikePrice,
            _optionsAmount,
            qTokenToMint.isCall(),
            _optionsDecimals,
            _underlyingDecimals,
            _strikeAssetDecimals
        );

        collateral = qTokenToMint.isCall() ? qTokenToMint.underlyingAsset() : qTokenToMint.strikeAsset();
    }

    /// @notice Calculates payout of an option post-expiry from qToken attributes
    /// @param _isCall true if the option is a call, false for a put
    /// @param _strikePrice the strike price of the option
    /// @param _amount the amount of options being exercised
    /// @param _optionsDecimals option decimals constant. qTokens have 18 decimals
    /// @param _strikeAssetDecimals the amount of decimals the strike asset has
    /// @param _expiryPrice the expiry price of the option with the amount of decimals
    /// @return payoutAmount the amount to be payed out as a fixed point type
    function getPayoutAmount(
        bool _isCall,
        uint256 _strikePrice,
        uint256 _amount,
        uint8 _optionsDecimals,
        uint8 _strikeAssetDecimals,
        PriceWithDecimals memory _expiryPrice
    )
        internal
        pure
        returns (QuantMath.FixedPointInt memory payoutAmount)
    {
        FundsCalculator.OptionPayoutInput memory payoutInput = FundsCalculator.OptionPayoutInput(
            _strikePrice.fromScaledUint(_strikeAssetDecimals),
            _expiryPrice.price.fromScaledUint(_expiryPrice.decimals),
            _amount.fromScaledUint(_optionsDecimals)
        );

        if (_isCall) {
            payoutAmount = getPayoutForCall(payoutInput);
        } else {
            payoutAmount = getPayoutForPut(payoutInput);
        }
    }

    /// @notice Calculates payout of a call given option payout inputs of strike, expiry and amount
    /// @param payoutInput strike, expiry and amount as fixed points
    /// @return payoutAmount the amount to be payed out as a fixed point type
    function getPayoutForCall(FundsCalculator.OptionPayoutInput memory payoutInput)
        internal
        pure
        returns (QuantMath.FixedPointInt memory payoutAmount)
    {
        payoutAmount =
            payoutInput.expiryPrice.isGreaterThan(payoutInput.strikePrice)
            ? payoutInput.expiryPrice.sub(payoutInput.strikePrice).mul(payoutInput.amount, true).div(
                payoutInput.expiryPrice, true
            )
            : int256(0).fromUnscaledInt();
    }

    /// @notice Calculates payout of a put given option payout inputs of strike, expiry and amount
    /// @param payoutInput strike, expiry and amount as fixed points
    /// @return payoutAmount the amount to be payed out as a fixed point type
    function getPayoutForPut(FundsCalculator.OptionPayoutInput memory payoutInput)
        internal
        pure
        returns (QuantMath.FixedPointInt memory payoutAmount)
    {
        payoutAmount =
            payoutInput.strikePrice.isGreaterThan(payoutInput.expiryPrice)
            ? payoutInput.strikePrice.sub(payoutInput.expiryPrice).mul(payoutInput.amount, true)
            : int256(0).fromUnscaledInt();
    }

    /// @notice Calculates the collateral required to mint an option or spread
    /// @param _qTokenToMintStrikePrice the strike price of the qToken being minted
    /// @param _qTokenForCollateralStrikePrice the strike price of the qToken being used as
    /// collateral in the case of a spread
    /// @param _optionsAmount the amount of options/spread being minted
    /// @param _qTokenToMintIsCall whether or not the token to mint is a call. if a spread,
    /// the qToken as collateral is implicitly also a call. and for minting a put, the
    /// qToken as collateral is implicitly also a put
    /// @param _optionsDecimals option decimals constant. qTokens have 18 decimals
    /// @param _underlyingDecimals the amount of decimals the underlying asset has
    /// @param _strikeAssetDecimals the amount of decimals the strike asset has
    /// @return collateralAmount the collateral amount required as a fixed point type
    function getOptionCollateralRequirement(
        uint256 _qTokenToMintStrikePrice,
        uint256 _qTokenForCollateralStrikePrice,
        uint256 _optionsAmount,
        bool _qTokenToMintIsCall,
        uint8 _optionsDecimals,
        uint8 _underlyingDecimals,
        uint8 _strikeAssetDecimals
    )
        internal
        pure
        returns (QuantMath.FixedPointInt memory collateralAmount)
    {
        QuantMath.FixedPointInt memory collateralPerOption;
        if (_qTokenToMintIsCall) {
            collateralPerOption = getCallCollateralRequirement(
                _qTokenToMintStrikePrice, _qTokenForCollateralStrikePrice, _underlyingDecimals, _strikeAssetDecimals
            );
        } else {
            collateralPerOption =
                getPutCollateralRequirement(_qTokenToMintStrikePrice, _qTokenForCollateralStrikePrice, _strikeAssetDecimals);
        }

        collateralAmount = _optionsAmount.fromScaledUint(_optionsDecimals).mul(collateralPerOption, false);
    }

    /// @notice Calculates the collateral required to mint a single PUT option or PUT spread
    /// @param _qTokenToMintStrikePrice the strike price of the PUT qToken being minted
    /// @param _qTokenForCollateralStrikePrice the strike price of the PUT qToken being used as
    /// collateral in the case of a spread
    /// @param _strikeAssetDecimals the amount of decimals the strike asset has
    /// @return collateralPerOption the collateral amount required per option as a fixed point type
    function getPutCollateralRequirement(
        uint256 _qTokenToMintStrikePrice,
        uint256 _qTokenForCollateralStrikePrice,
        uint8 _strikeAssetDecimals
    )
        internal
        pure
        returns (QuantMath.FixedPointInt memory collateralPerOption)
    {
        QuantMath.FixedPointInt memory mintStrikePrice = _qTokenToMintStrikePrice.fromScaledUint(_strikeAssetDecimals);
        QuantMath.FixedPointInt memory collateralStrikePrice =
            _qTokenForCollateralStrikePrice.fromScaledUint(_strikeAssetDecimals);

        // Initially (non-spread) required collateral is the long strike price
        collateralPerOption = mintStrikePrice;

        if (_qTokenForCollateralStrikePrice > 0) {
            collateralPerOption =
                mintStrikePrice.isGreaterThan(collateralStrikePrice)
                ? mintStrikePrice.sub(collateralStrikePrice) // Put Credit Spread
                : int256(0).fromUnscaledInt(); // Put Debit Spread
        }
    }

    /// @notice Calculates the collateral required to mint a single CALL option or CALL spread
    /// @param _qTokenToMintStrikePrice the strike price of the CALL qToken being minted
    /// @param _qTokenForCollateralStrikePrice the strike price of the CALL qToken being
    /// used as collateral in the case of a spread
    /// @param _underlyingDecimals the amount of decimals the underlying asset has
    /// @param _strikeAssetDecimals the amount of decimals the strike asset has
    /// @return collateralPerOption the collateral amount required per option as a fixed point type
    function getCallCollateralRequirement(
        uint256 _qTokenToMintStrikePrice,
        uint256 _qTokenForCollateralStrikePrice,
        uint8 _underlyingDecimals,
        uint8 _strikeAssetDecimals
    )
        internal
        pure
        returns (QuantMath.FixedPointInt memory collateralPerOption)
    {
        QuantMath.FixedPointInt memory mintStrikePrice = _qTokenToMintStrikePrice.fromScaledUint(_strikeAssetDecimals);
        QuantMath.FixedPointInt memory collateralStrikePrice =
            _qTokenForCollateralStrikePrice.fromScaledUint(_strikeAssetDecimals);

        // Initially (non-spread) required collateral is the long strike price
        collateralPerOption = uint256(10 ** _underlyingDecimals).fromScaledUint(_underlyingDecimals);

        if (_qTokenForCollateralStrikePrice > 0) {
            collateralPerOption =
                mintStrikePrice.isGreaterThanOrEqual(collateralStrikePrice)
                ? int256(0).fromUnscaledInt() // Call Debit Spread
                : collateralStrikePrice.sub(mintStrikePrice).div(collateralStrikePrice, false); // Call Credit Spread
        }
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
pragma solidity 0.8.16;

import "./SignedConverter.sol";

/**
 * @title QuantMath
 * @author Rolla
 * @notice FixedPoint library
 */
library QuantMath {
    using SignedConverter for int256;
    using SignedConverter for uint256;

    struct FixedPointInt {
        int256 value;
    }

    int256 private constant _SCALING_FACTOR = 1e27;
    uint256 private constant _BASE_DECIMALS = 27;

    /**
     * @notice constructs an `FixedPointInt` from an unscaled int, e.g., `b=5` gets stored internally as `5**27`.
     * @param a int to convert into a FixedPoint.
     * @return the converted FixedPoint.
     */
    function fromUnscaledInt(int256 a) internal pure returns (FixedPointInt memory) {
        return FixedPointInt(a * _SCALING_FACTOR);
    }

    /**
     * @notice constructs an FixedPointInt from an scaled uint with {_decimals} decimals
     * Examples:
     * (1)  USDC    decimals = 6
     * Input:  5 * 1e6 USDC  =>    Output: 5 * 1e27 (FixedPoint 5.0 USDC)
     * (2)  cUSDC   decimals = 8
     * Input:  5 * 1e6 cUSDC =>    Output: 5 * 1e25 (FixedPoint 0.05 cUSDC)
     * @param _a uint256 to convert into a FixedPoint.
     * @param _decimals  original decimals _a has
     * @return the converted FixedPoint, with 27 decimals.
     */
    function fromScaledUint(uint256 _a, uint256 _decimals) internal pure returns (FixedPointInt memory) {
        FixedPointInt memory fixedPoint;

        if (_decimals == _BASE_DECIMALS) {
            fixedPoint = FixedPointInt(_a.uintToInt());
        } else if (_decimals > _BASE_DECIMALS) {
            uint256 exp = _decimals - _BASE_DECIMALS;
            fixedPoint = FixedPointInt(uint256(_a / 10 ** exp).uintToInt());
        } else {
            uint256 exp = _BASE_DECIMALS - _decimals;
            fixedPoint = FixedPointInt(uint256(_a * 10 ** exp).uintToInt());
        }

        return fixedPoint;
    }

    /**
     * @notice convert a FixedPointInt number to an uint256 with a specific number of decimals
     * @param _a FixedPointInt to convert
     * @param _decimals number of decimals that the uint256 should be scaled to
     * @param _roundDown True to round down the result, False to round up
     * @return the converted uint256
     */
    function toScaledUint(FixedPointInt memory _a, uint256 _decimals, bool _roundDown)
        internal
        pure
        returns (uint256)
    {
        uint256 scaledUint;

        if (_decimals == _BASE_DECIMALS) {
            scaledUint = _a.value.intToUint();
        } else if (_decimals > _BASE_DECIMALS) {
            uint256 exp = _decimals - _BASE_DECIMALS;
            scaledUint = _a.value.intToUint() * 10 ** exp;
        } else {
            uint256 exp = _BASE_DECIMALS - _decimals;
            uint256 tailing;
            if (!_roundDown) {
                uint256 remainder = _a.value.intToUint() % 10 ** exp;
                if (remainder > 0) {
                    tailing = 1;
                }
            }
            scaledUint = _a.value.intToUint() / 10 ** exp + tailing;
        }

        return scaledUint;
    }

    /**
     * @notice add two signed integers, a + b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return sum of the two signed integers
     */
    function add(FixedPointInt memory a, FixedPointInt memory b) internal pure returns (FixedPointInt memory) {
        return FixedPointInt(a.value + b.value);
    }

    /**
     * @notice subtract two signed integers, a-b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return difference of two signed integers
     */
    function sub(FixedPointInt memory a, FixedPointInt memory b) internal pure returns (FixedPointInt memory) {
        return FixedPointInt(a.value - b.value);
    }

    /**
     * @notice multiply two signed integers, a by b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return mul of two signed integers
     */
    function mul(FixedPointInt memory a, FixedPointInt memory b, bool roundDown)
        internal
        pure
        returns (FixedPointInt memory)
    {
        int256 remainder = a.value * b.value % _SCALING_FACTOR;
        int8 tailing = !roundDown && remainder > 0 ? int8(1) : int8(0);

        return FixedPointInt(a.value * b.value / _SCALING_FACTOR + tailing);
    }

    /**
     * @notice divide two signed integers, a by b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return div of two signed integers
     */
    function div(FixedPointInt memory a, FixedPointInt memory b, bool roundDown)
        internal
        pure
        returns (FixedPointInt memory)
    {
        int256 remainder = a.value * _SCALING_FACTOR % b.value;
        int8 tailing = !roundDown && remainder > 0 ? int8(1) : int8(0);

        return FixedPointInt(a.value * _SCALING_FACTOR / b.value + tailing);
    }

    /**
     * @notice minimum between two signed integers, a and b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return min of two signed integers
     */
    function min(FixedPointInt memory a, FixedPointInt memory b) internal pure returns (FixedPointInt memory) {
        return a.value < b.value ? a : b;
    }

    /**
     * @notice maximum between two signed integers, a and b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return max of two signed integers
     */
    function max(FixedPointInt memory a, FixedPointInt memory b) internal pure returns (FixedPointInt memory) {
        return a.value > b.value ? a : b;
    }

    /**
     * @notice is a is equal to b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return True if equal, False if not
     */
    function isEqual(FixedPointInt memory a, FixedPointInt memory b) internal pure returns (bool) {
        return a.value == b.value;
    }

    /**
     * @notice is a greater than b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return True if a > b, False if not
     */
    function isGreaterThan(FixedPointInt memory a, FixedPointInt memory b) internal pure returns (bool) {
        return a.value > b.value;
    }

    /**
     * @notice is a greater than or equal to b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return True if a >= b, False if not
     */
    function isGreaterThanOrEqual(FixedPointInt memory a, FixedPointInt memory b) internal pure returns (bool) {
        return a.value >= b.value;
    }

    /**
     * @notice is a is less than b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return True if a < b, False if not
     */
    function isLessThan(FixedPointInt memory a, FixedPointInt memory b) internal pure returns (bool) {
        return a.value < b.value;
    }

    /**
     * @notice is a less than or equal to b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return True if a <= b, False if not
     */
    function isLessThanOrEqual(FixedPointInt memory a, FixedPointInt memory b) internal pure returns (bool) {
        return a.value <= b.value;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/draft-EIP712.sol)

pragma solidity ^0.8.0;

import "./ECDSA.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Minimalist and gas efficient standard ERC1155 implementation.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC1155.sol)
abstract contract ERC1155 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 amount
    );

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] amounts
    );

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    /*//////////////////////////////////////////////////////////////
                             ERC1155 STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(address => mapping(uint256 => uint256)) public balanceOf;

    mapping(address => mapping(address => bool)) public isApprovedForAll;

    /*//////////////////////////////////////////////////////////////
                             METADATA LOGIC
    //////////////////////////////////////////////////////////////*/

    function uri(uint256 id) public view virtual returns (string memory);

    /*//////////////////////////////////////////////////////////////
                              ERC1155 LOGIC
    //////////////////////////////////////////////////////////////*/

    function setApprovalForAll(address operator, bool approved) public virtual {
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) public virtual {
        require(msg.sender == from || isApprovedForAll[from][msg.sender], "NOT_AUTHORIZED");

        balanceOf[from][id] -= amount;
        balanceOf[to][id] += amount;

        emit TransferSingle(msg.sender, from, to, id, amount);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155Received(msg.sender, from, id, amount, data) ==
                    ERC1155TokenReceiver.onERC1155Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) public virtual {
        require(ids.length == amounts.length, "LENGTH_MISMATCH");

        require(msg.sender == from || isApprovedForAll[from][msg.sender], "NOT_AUTHORIZED");

        // Storing these outside the loop saves ~15 gas per iteration.
        uint256 id;
        uint256 amount;

        for (uint256 i = 0; i < ids.length; ) {
            id = ids[i];
            amount = amounts[i];

            balanceOf[from][id] -= amount;
            balanceOf[to][id] += amount;

            // An array can't have a total length
            // larger than the max uint256 value.
            unchecked {
                ++i;
            }
        }

        emit TransferBatch(msg.sender, from, to, ids, amounts);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155BatchReceived(msg.sender, from, ids, amounts, data) ==
                    ERC1155TokenReceiver.onERC1155BatchReceived.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function balanceOfBatch(address[] calldata owners, uint256[] calldata ids)
        public
        view
        virtual
        returns (uint256[] memory balances)
    {
        require(owners.length == ids.length, "LENGTH_MISMATCH");

        balances = new uint256[](owners.length);

        // Unchecked because the only math done is incrementing
        // the array index counter which cannot possibly overflow.
        unchecked {
            for (uint256 i = 0; i < owners.length; ++i) {
                balances[i] = balanceOf[owners[i]][ids[i]];
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                              ERC165 LOGIC
    //////////////////////////////////////////////////////////////*/

    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0xd9b67a26 || // ERC165 Interface ID for ERC1155
            interfaceId == 0x0e89341c; // ERC165 Interface ID for ERC1155MetadataURI
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        balanceOf[to][id] += amount;

        emit TransferSingle(msg.sender, address(0), to, id, amount);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155Received(msg.sender, address(0), id, amount, data) ==
                    ERC1155TokenReceiver.onERC1155Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _batchMint(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        uint256 idsLength = ids.length; // Saves MLOADs.

        require(idsLength == amounts.length, "LENGTH_MISMATCH");

        for (uint256 i = 0; i < idsLength; ) {
            balanceOf[to][ids[i]] += amounts[i];

            // An array can't have a total length
            // larger than the max uint256 value.
            unchecked {
                ++i;
            }
        }

        emit TransferBatch(msg.sender, address(0), to, ids, amounts);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155BatchReceived(msg.sender, address(0), ids, amounts, data) ==
                    ERC1155TokenReceiver.onERC1155BatchReceived.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _batchBurn(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        uint256 idsLength = ids.length; // Saves MLOADs.

        require(idsLength == amounts.length, "LENGTH_MISMATCH");

        for (uint256 i = 0; i < idsLength; ) {
            balanceOf[from][ids[i]] -= amounts[i];

            // An array can't have a total length
            // larger than the max uint256 value.
            unchecked {
                ++i;
            }
        }

        emit TransferBatch(msg.sender, from, address(0), ids, amounts);
    }

    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        balanceOf[from][id] -= amount;

        emit TransferSingle(msg.sender, from, address(0), id, amount);
    }
}

/// @notice A generic interface for a contract which properly accepts ERC1155 tokens.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC1155.sol)
abstract contract ERC1155TokenReceiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external virtual returns (bytes4) {
        return ERC1155TokenReceiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external virtual returns (bytes4) {
        return ERC1155TokenReceiver.onERC1155BatchReceived.selector;
    }
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

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.16;

/**
 * @title SignedConverter
 * @author Rolla
 * @notice A library to convert an unsigned integer to signed integer or signed integer to unsigned integer.
 */
library SignedConverter {
    /**
     * @notice convert an unsigned integer to a signed integer
     * @param a uint to convert into a signed integer
     * @return converted signed integer
     */
    function uintToInt(uint256 a) internal pure returns (int256) {
        require(a < 2 ** 255, "QuantMath: out of int range");

        return int256(a);
    }

    /**
     * @notice convert a signed integer to an unsigned integer
     * @param a int to convert into an unsigned integer
     * @return converted unsigned integer
     */
    function intToUint(int256 a) internal pure returns (uint256) {
        require(a >= 0, "QuantMath: negative int");

        return uint256(a);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

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