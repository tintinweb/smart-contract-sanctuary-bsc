// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./interfaces/IMinerPublicBuildingInterface.sol";
import "./interfaces/ISignatureValidator.sol";
import "./interfaces/IPancakeRouter02.sol";
import "./interfaces/IParcelInterface.sol";
import "./interfaces/INetGymStreet.sol";
import "./interfaces/IERC721Base.sol";
import "./interfaces/IBuyAndBurn.sol";
import "./interfaces/IMinerNFT.sol";
import "./interfaces/IMining.sol";
import "./interfaces/IAmountsDistributor.sol";

contract Municipality is OwnableUpgradeable, ReentrancyGuardUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    struct AttachedMiner {
        uint256 parcelId;
        uint256 minerId;
    }

    struct Parcel {
        uint16 x;
        uint16 y;
        uint8 parcelType;
        uint8 parcelLandType;
    }

    // Used to keep Parcel information
    struct ParcelInfo {
        bool isUpgraded;
        uint8 parcelType;
        uint8 parcelLandType;
        bool isValid;
    }

    struct BundleInfo {
        uint256 parcelsAmount;
        uint256 minersAmount;
        uint256 bundlePrice;
        uint256 discountPct;
    }

    struct ParcelsMintSignature {
        Parcel[] parcels;
        bytes[] signatures;
    }

    struct MintedNFT {
        uint256 firstNFTId;
        uint256 count;
    }

    uint8 private constant OPERATION_TYPE_MINT_OR_UPGRADE_PARCELS = 10;
    uint8 private constant OPERATION_TYPE_MINT_MINERS = 20;
    uint8 private constant OPERATION_TYPE_PURCHASE_ELECTRICITY = 30;
    uint8 private constant OPERATION_TYPE_PURCHASE_REPAIR = 40;

    uint8 private constant MINER_STATUS_DETACHED = 10;
    uint8 private constant MINER_STATUS_ATTACHED = 20;

    uint8 private constant PARCEL_TYPE_STANDARD = 10;
    uint8 private constant PARCEL_TYPE_BUSINESS = 20;

    uint8 private constant PARCEL_LAND_TYPE_NEXT_TO_OCEAN = 10;
    uint8 private constant PARCEL_LAND_TYPE_NEAR_OCEAN = 20;
    uint8 private constant PARCEL_LAND_TYPE_INLAND = 30;

    uint8 private constant BUNDLE_TYPE_PARCELS_MINERS_1 = 0;
    uint8 private constant BUNDLE_TYPE_PARCELS_1 = 1;
    uint8 private constant BUNDLE_TYPE_PARCELS_2 = 2;
    uint8 private constant BUNDLE_TYPE_PARCELS_3 = 3;
    uint8 private constant BUNDLE_TYPE_PARCELS_4 = 4;
    uint8 private constant BUNDLE_TYPE_PARCELS_5 = 5;
    uint8 private constant BUNDLE_TYPE_PARCELS_6 = 6;
    uint8 private constant BUNDLE_TYPE_MINERS_1 = 7;
    uint8 private constant BUNDLE_TYPE_MINERS_2 = 8;
    uint8 private constant BUNDLE_TYPE_MINERS_3 = 9;
    uint8 private constant BUNDLE_TYPE_MINERS_4 = 10;
    uint8 private constant BUNDLE_TYPE_MINERS_5 = 11;
    uint8 private constant BUNDLE_TYPE_MINERS_6 = 12;
    
    /// @notice Pricing information (in BUSD)
    uint256 public upgradePrice;
    uint256 public minerPrice;
    uint256 public minerRepairPrice;
    uint256 public electricityVoucherPrice;

    /// @notice Addresses of Gymstreet smart contracts
    address public standardParcelNFTAddress;
    address public businessParcelNFTAddress;
    address public minerV1NFTAddress;
    address public miningAddress;
    address public busdAddress;
    address public netGymStreetAddress;
    address public signatureValidatorAddress;

    mapping(address => uint256) public userToPurchasedAmountMapping;

    /// @notice Parcels pricing changes per percentage
    mapping(uint256 => uint256) public soldCountToStandardParcelPriceMapping;
    mapping(uint256 => uint256) public soldCountToBusinessParcelPriceMapping;
    uint256 public currentlySoldStandardParcelsCount;
    uint256 public currentlySoldBusinessParcelsCount;
    uint256 public currentStandardParcelPrice;
    uint256 public currentBusinessParcelPrice;

    /// @notice Parcel <=> Miner attachments and Parcel/Miner properties
    mapping(uint256 => uint256[]) public parcelMinersMapping;
    mapping(uint256 => uint256) public minerParcelMapping;
    uint8 public standardParcelSlotsCount;
    uint8 public upgradedParcelSlotsCount;

    /// @notice Electricity voucher mapping to user who owns them
    mapping(address => uint256) public userToElectricityVoucherAmountMapping;

    /// @notice Timestamps the user requested repair
    mapping(address => uint256[]) public userToRepairDatesMapping;

    /// @notice Signatures when minting a parcel
    mapping(bytes => bool) public mintParcelsUsedSignaturesMapping;

    /// @notice Array of all available bundles OLD VERSION DEPRICATED
    BundleInfo[6] public bundles;

    /// @notice Indicator if the sales can happen
    bool public isSaleActive;

    address public minerPublicBuildingAddress;
    address public amountsDistributorAddress;

    /// @notice Array of all available bundles
    BundleInfo[13] public newBundles;

        //TODO: DEPRICATED: REMOVE BEFORE MAINNET DEPLOYMENT
    struct LastPurchaseInfo {
        uint256 lastPurchaseDate;
        uint256 dollarValue;
    }
    //TODO: DEPRICATED: REMOVE BEFORE MAINNET DEPLOYMENT
    mapping(address => LastPurchaseInfo) public lastPurchaseInfo;
         
    struct LastPurchaseData {
        uint256 lastPurchaseDate;
        uint256 expirationDate;
        uint256 dollarValue;
    }
    mapping(address => LastPurchaseData) public lastPurchaseData;

    // ------------------------------------ EVENTS ------------------------------------ //

    event ParcelsSoldCountPricingSet(
        uint256[] indexed standardParcelPrices, 
        uint256[] indexed businessParcelPrices
    );
    event BundlesSet(BundleInfo[13] indexed bundles);
    event ParcelsSlotsCountSet(
        uint8 indexed standardParcelSlotsCount,
        uint8 indexed upgradedParcelSlotsCount
    );
    event PurchasePricesSet(
        uint256 upgradePrice,
        uint256 minerPrice,
        uint256 minerRepairPrice,
        uint256 electricityVoucherPrice
    );
    event SaleActivationSet(bool indexed saleActivation);
    event BundlePurchased(address indexed user, uint256 indexed bundleType);
    event MinerAttached(address user, uint256 indexed parcelId, uint256 indexed minerId);
    event MinerDetached(address indexed user, uint256 indexed parcelId, uint256 indexed minerId);
    event VouchersPurchased(address indexed user, uint256 vouchersCount);
    event MinersRepaired(address indexed user, uint256 minersCount);
    event VouchersApplied(address indexed user, uint256[] minerIds);
    event StandardParcelUpgraded(address indexed user, uint256 indexed parcelId);
    event NFTContractAddressesSet(address[9] indexed _nftContractAddresses);

    /// @notice Modifier for 0 address check
    modifier notZeroAddress() {
        require(address(0) != msg.sender, "Municipality: Caller can not be address 0");
        _;
    }

    /// @notice Modifier not to allow sales when it is made inactive
    modifier onlySaleActive() {
        require(isSaleActive, "Municipality: Sale is deactivated now");
        _;
    }

    /// @notice Access to only the miner public building
    modifier onlyMinerPublicBuilding() {
        require(msg.sender == minerPublicBuildingAddress, "Municipality: This function is available only to a miner public building");
        _;
    }

    // @notice Proxy SC support - initialize internal state
    function initialize(
    ) external initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
    }

    receive() external payable {}

    fallback() external payable {}

    /// @notice Public interface

    /// @notice Array of the prices is given in the following way [sold_count1, price1, sold_count2, price2, ...]
    function setParcelsSoldCountPricing(
        uint256[] calldata _standardParcelPrices,
        uint256[] calldata _businessParcelPrices
    ) external onlyOwner notZeroAddress {
        require(_standardParcelPrices[0] == 0, "Municipality: The given standard parcel array must start from 0");
        require(_businessParcelPrices[0] == 0, "Municipality: The given business parcel array must start from 0");
        for (uint8 i = 0; i < _standardParcelPrices.length; i += 2) {
            uint256 standardParcelSoldCount = _standardParcelPrices[i];
            uint256 standardParcelPrice = _standardParcelPrices[i + 1];
            soldCountToStandardParcelPriceMapping[standardParcelSoldCount] = standardParcelPrice;
        }
        for (uint8 i = 0; i < _businessParcelPrices.length; i += 2) {
            uint256 businessParcelSoldCount = _businessParcelPrices[i];
            uint256 businessParcelPrice = _businessParcelPrices[i + 1];
            soldCountToBusinessParcelPriceMapping[businessParcelSoldCount] = businessParcelPrice;
        }
        emit ParcelsSoldCountPricingSet(_standardParcelPrices, _businessParcelPrices);
    }

    /// @notice Update bundles
    function setBundles(BundleInfo[13] calldata _bundles) external onlyOwner notZeroAddress {
        newBundles = _bundles;
        emit BundlesSet(_bundles);
    }

    /// @notice Set contract addresses for all NFTs we currently have
    function setNFTContractAddresses(address[9] calldata _nftContractAddresses) external onlyOwner {
        standardParcelNFTAddress = _nftContractAddresses[0];
        businessParcelNFTAddress = _nftContractAddresses[1];
        minerV1NFTAddress = _nftContractAddresses[2];
        miningAddress = _nftContractAddresses[3];
        busdAddress = _nftContractAddresses[4];
        netGymStreetAddress = _nftContractAddresses[5];
        minerPublicBuildingAddress = _nftContractAddresses[6];
        signatureValidatorAddress = _nftContractAddresses[7];
        amountsDistributorAddress = _nftContractAddresses[8];
        emit NFTContractAddressesSet(_nftContractAddresses);
    }
    
    /// @notice Set the number of slots available for the miners for standard and upgraded parcels
    function setParcelsSlotsCount(uint8[2] calldata _parcelsSlotsCount) external onlyOwner {
        standardParcelSlotsCount = _parcelsSlotsCount[0];
        upgradedParcelSlotsCount = _parcelsSlotsCount[1];

        emit ParcelsSlotsCountSet(_parcelsSlotsCount[0], _parcelsSlotsCount[1]);
    }

    /// @notice Set the prices for all different entities we currently sell
    function setPurchasePrices(uint256[4] calldata _purchasePrices) external onlyOwner {
        upgradePrice = _purchasePrices[0];
        minerPrice = _purchasePrices[1];
        minerRepairPrice = _purchasePrices[2];
        electricityVoucherPrice = _purchasePrices[3];

        emit PurchasePricesSet(
            _purchasePrices[0],
            _purchasePrices[1],
            _purchasePrices[2],
            _purchasePrices[3]
        );
    }

    /// @notice Activate/Deactivate sales
    function setSaleActivation(bool _saleActivation) external onlyOwner {
        isSaleActive = _saleActivation;
        emit SaleActivationSet(_saleActivation);
    }

    // @notice (Purchase) Generic minting functionality for parcels, regardless the currency
    function mintParcels(ParcelsMintSignature calldata _mintingSignature, uint256 _referrerId)
        external
        onlySaleActive
        notZeroAddress
    {
        require(ISignatureValidator(signatureValidatorAddress).verifySigner(_mintingSignature), "Municipality: Not authorized signer");
        INetGymStreet(netGymStreetAddress).addGymMlm(msg.sender, _referrerId);
        (uint256 purchasePrice,) = _getPriceForParcels(_mintingSignature.parcels);
        uint256 percentage;
        LastPurchaseData storage lastPurchase = lastPurchaseData[msg.sender];
        if(_mintingSignature.parcels.length >= 240) {
            percentage = 18;
        } else if(_mintingSignature.parcels.length >= 140) {
            percentage = 16;
        } else if(_mintingSignature.parcels.length >= 80) {
            percentage = 12;
        } else if(_mintingSignature.parcels.length >= 40) {
            percentage = 10;
        } else if(_mintingSignature.parcels.length >= 10) {
            percentage = 8;
        } else if(_mintingSignature.parcels.length >= 4) {
            percentage = 5;
        }
        uint256 discountedPrice = _discountPrice(purchasePrice, percentage);
        _transferToContract(discountedPrice);
        IAmountsDistributor(amountsDistributorAddress).distributeAmounts(discountedPrice, OPERATION_TYPE_MINT_OR_UPGRADE_PARCELS, msg.sender);
        userToPurchasedAmountMapping[msg.sender] += discountedPrice;
        _updateAdditionLevel(msg.sender);
        lastPurchase.dollarValue += discountedPrice;
        _lastPurchaseDateUpdate(msg.sender);
        IParcelInterface(standardParcelNFTAddress).mintParcels(msg.sender, _mintingSignature.parcels);
        currentlySoldStandardParcelsCount += _mintingSignature.parcels.length;
    }

    // @notice (Purchase) Mint the given amount of miners
    function mintMiners(uint256 _count, uint256 _referrerId) external onlySaleActive notZeroAddress returns(uint256, uint256)
    {
        INetGymStreet(netGymStreetAddress).addGymMlm(msg.sender, _referrerId);
        uint256 purchasePrice = _count * minerPrice;
        LastPurchaseData storage lastPurchase = lastPurchaseData[msg.sender];
        _transferToContract(purchasePrice);
        userToPurchasedAmountMapping[msg.sender] += purchasePrice;
        _updateAdditionLevel(msg.sender);
        lastPurchase.dollarValue += purchasePrice;
        _lastPurchaseDateUpdate(msg.sender);
        IAmountsDistributor(amountsDistributorAddress).distributeAmounts(purchasePrice, OPERATION_TYPE_MINT_MINERS, msg.sender);
        return IMinerNFT(minerV1NFTAddress).mintMiners(msg.sender, _count);
    }

    function purchaseBasicBundle(uint8 _bundleType, ParcelsMintSignature calldata _mintingSignature,
        uint256 _referrerId) external onlySaleActive notZeroAddress
    {
        _validateBasicBundleType(_bundleType);
        _requireOnlyStandardParcels(_mintingSignature.parcels);
        require(ISignatureValidator(signatureValidatorAddress).verifySigner(_mintingSignature), "Municipality: Not authorized signer");
        BundleInfo memory bundle = newBundles[_bundleType];
        require(_mintingSignature.parcels.length == bundle.parcelsAmount, "Municipality: Invalid parcels amount");
        LastPurchaseData storage lastPurchase = lastPurchaseData[msg.sender];
        INetGymStreet(netGymStreetAddress).addGymMlm(msg.sender, _referrerId);
        uint256 bundlePurchasePrice = _discountPrice(bundle.bundlePrice, bundle.discountPct);
        _transferToContract(bundlePurchasePrice);
        userToPurchasedAmountMapping[msg.sender] += bundlePurchasePrice;
        _updateAdditionLevel(msg.sender);
        lastPurchase.dollarValue += bundlePurchasePrice;
        _lastPurchaseDateUpdate(msg.sender);
        IAmountsDistributor(amountsDistributorAddress).distributeAmounts(
            bundlePurchasePrice,
            OPERATION_TYPE_MINT_OR_UPGRADE_PARCELS,
            msg.sender
        );
        uint256[] memory parcelIds = IMinerPublicBuildingInterface(minerPublicBuildingAddress).mintParcelsBundle(msg.sender, _mintingSignature.parcels);
        (uint256 minerIdPair0, uint256 minerIdPair1) = IMinerPublicBuildingInterface(minerPublicBuildingAddress).mintMinersBundle(msg.sender, bundle.minersAmount);
        uint256[] memory minerIds = new uint256[](minerIdPair1);
        uint256 index = 0;
        for(uint256 minerId = minerIdPair0; minerId < minerIdPair0 + minerIdPair1; minerId++) {
            minerIds[index] = minerId;
            index++;
        }
        _automaticallyAttachMinersToParcels(parcelIds, minerIds, minerIds.length);
        currentlySoldStandardParcelsCount += bundle.parcelsAmount;
        emit BundlePurchased(msg.sender, _bundleType);
    }

    function purchaseParcelsBundle(uint8 _bundleType, ParcelsMintSignature calldata _mintingSignature,
        uint256 _referrerId) external onlySaleActive notZeroAddress
    {
        _validateParcelsBundleType(_bundleType);
        _requireOnlyStandardParcels(_mintingSignature.parcels);
        require(ISignatureValidator(signatureValidatorAddress).verifySigner(_mintingSignature), "Municipality: Not authorized signer");
        BundleInfo memory bundle = newBundles[_bundleType];
        require(_mintingSignature.parcels.length == bundle.parcelsAmount, "Municipality: Invalid parcels amount");
        LastPurchaseData storage lastPurchase = lastPurchaseData[msg.sender];
        INetGymStreet(netGymStreetAddress).addGymMlm(msg.sender, _referrerId);
        uint256 bundlePurchasePrice = _discountPrice(bundle.bundlePrice, bundle.discountPct);
        _transferToContract(bundlePurchasePrice);
        userToPurchasedAmountMapping[msg.sender] += bundlePurchasePrice;
        _updateAdditionLevel(msg.sender);
        lastPurchase.dollarValue += bundlePurchasePrice;
        _lastPurchaseDateUpdate(msg.sender);
        IAmountsDistributor(amountsDistributorAddress).distributeAmounts(
            bundlePurchasePrice,
            OPERATION_TYPE_MINT_OR_UPGRADE_PARCELS,
            msg.sender
        );
        IMinerPublicBuildingInterface(minerPublicBuildingAddress).mintParcelsBundle(msg.sender, _mintingSignature.parcels);
        currentlySoldStandardParcelsCount += bundle.parcelsAmount;
        emit BundlePurchased(msg.sender, _bundleType);
    }

    function purchaseMinersBundle(uint8 _bundleType, uint256 _referrerId) external onlySaleActive notZeroAddress returns(uint256, uint256) {
        _validateMinersBundleType(_bundleType);
        INetGymStreet(netGymStreetAddress).addGymMlm(msg.sender, _referrerId);
        BundleInfo memory bundle = newBundles[_bundleType];
        uint256 bundlePurchasePrice = _discountPrice(bundle.bundlePrice, bundle.discountPct);
        _transferToContract(bundlePurchasePrice);
        LastPurchaseData storage lastPurchase = lastPurchaseData[msg.sender];
        userToPurchasedAmountMapping[msg.sender] += bundlePurchasePrice;
        _updateAdditionLevel(msg.sender);
        lastPurchase.dollarValue += bundlePurchasePrice;
        _lastPurchaseDateUpdate(msg.sender);
        uint256 minersAmount = bundle.minersAmount;
        uint256 minersPurchasePrice = _discountPrice(minersAmount * minerPrice, bundle.discountPct);
        IAmountsDistributor(amountsDistributorAddress).distributeAmounts(minersPurchasePrice, OPERATION_TYPE_MINT_MINERS, msg.sender);
        (uint256 firstMinerId, uint256 count) = IMinerPublicBuildingInterface(minerPublicBuildingAddress).mintMinersBundle(msg.sender, minersAmount);
        emit BundlePurchased(msg.sender, _bundleType);
        return (firstMinerId, count);
    }

    function grantParcels(uint8 _bundleType, ParcelsMintSignature calldata _mintingSignature,
        uint256 _referrerId, address _user) external onlyOwner
    {
        _validateParcelsBundleType(_bundleType);
        _requireOnlyStandardParcels(_mintingSignature.parcels);
        require(ISignatureValidator(signatureValidatorAddress).verifySigner(_mintingSignature), "Municipality: Not authorized signer");
        BundleInfo memory bundle = newBundles[_bundleType];
        require(_mintingSignature.parcels.length == bundle.parcelsAmount, "Municipality: Invalid parcels amount");
        INetGymStreet(netGymStreetAddress).addGymMlm(_user, _referrerId);
        IMinerPublicBuildingInterface(minerPublicBuildingAddress).mintParcelsBundle(_user, _mintingSignature.parcels);
        currentlySoldStandardParcelsCount += bundle.parcelsAmount;
        emit BundlePurchased(_user, _bundleType);
    }

    function grantMiners(uint8 _bundleType, uint256 _referrerId, address _user) external onlyOwner returns(uint256, uint256) {
        _validateMinersBundleType(_bundleType);
        INetGymStreet(netGymStreetAddress).addGymMlm(_user, _referrerId);
        BundleInfo memory bundle = newBundles[_bundleType];
        uint256 minersAmount = bundle.minersAmount;
        (uint256 firstMinerId, uint256 count) = IMinerPublicBuildingInterface(minerPublicBuildingAddress).mintMinersBundle(_user, minersAmount);
        emit BundlePurchased(_user, _bundleType);
        return (firstMinerId, count);
    }

    // @notice (Purchase) Purchase a given amount of el. vouchers
    function purchaseVouchers(uint16 count) external onlySaleActive notZeroAddress {
        uint256 _amount = count * electricityVoucherPrice;
        _transferToContract(_amount);
        IAmountsDistributor(amountsDistributorAddress).distributeAmounts(_amount, OPERATION_TYPE_PURCHASE_ELECTRICITY, msg.sender);
        LastPurchaseData storage lastPurchase = lastPurchaseData[msg.sender];
        userToElectricityVoucherAmountMapping[msg.sender] += count;
        userToPurchasedAmountMapping[msg.sender] += _amount;
        _updateAdditionLevel(msg.sender);
        lastPurchase.dollarValue += _amount;
        _lastPurchaseDateUpdate(msg.sender);
        emit VouchersPurchased(msg.sender, count);
    }

    // @notice (Purchase) Repair ALL miners - reset the amortization points in the mining SC.
    function repairAllMiners() external onlySaleActive notZeroAddress {
        uint256 minersCount = IMining(miningAddress).getMinersCount(msg.sender);
        uint256 _amount = minersCount * minerRepairPrice;
        _transferToContract(_amount);
        IAmountsDistributor(amountsDistributorAddress).distributeAmounts(_amount, OPERATION_TYPE_PURCHASE_REPAIR, msg.sender);
        LastPurchaseData storage lastPurchase = lastPurchaseData[msg.sender];
        userToRepairDatesMapping[msg.sender].push(block.timestamp);
        userToPurchasedAmountMapping[msg.sender] += _amount;
        _updateAdditionLevel(msg.sender);
        lastPurchase.dollarValue += _amount;
        _lastPurchaseDateUpdate(msg.sender);
        IMining(miningAddress).repairMiners(msg.sender);
        emit MinersRepaired(msg.sender, minersCount);
    }

    // @notice Apply a voucher from the user's balance to a selected miner
    // We won't use the amount of vouchers to be used in this function.  
    // But just to keep things consistent with the Back/Front ends we will keep the arguments the same
    function applyVoucher(uint256, uint256[] memory minerIds) external notZeroAddress {
        uint256 numAvailableVouchers = userToElectricityVoucherAmountMapping[msg.sender];
        require(
            numAvailableVouchers >= minerIds.length,
            "Municipality: Not enough vouchers on balance"
        );
        userToElectricityVoucherAmountMapping[msg.sender] = numAvailableVouchers - minerIds.length;
        IMining(miningAddress).applyVouchers(msg.sender, minerIds);
        emit VouchersApplied(msg.sender, minerIds);
    }

    // @notice Attach/Detach the miners
    function attachDetachMinersToParcel(uint256[] calldata minersToAttach, uint256 parcelId) external notZeroAddress {
        require(IERC721Base(standardParcelNFTAddress).exists(parcelId), "Municipality: Parcel doesnt exist");
        _requireMinersCountMatchingWithParcelSlots(parcelId, minersToAttach.length);
        require(
            IERC721Base(standardParcelNFTAddress).ownerOf(parcelId) == msg.sender,
            "Municipality: Invalid parcel owner"
        );
        IMinerNFT(minerV1NFTAddress).requireNFTsBelongToUser(minersToAttach, msg.sender);
        _attachDetachMinersToParcel(minersToAttach, parcelId);
    }

    /// @notice Used by MinerPublicBuilding to attach miner to a parcel
    function attachMinerToParcel(address user, uint256 firstMinerId, uint256[] calldata parcelIds) external onlyMinerPublicBuilding {
        uint32 minerCounter = 0;
        for (uint16 i = 0; i < parcelIds.length; i++) {
            for (uint16 j = 0; j < 4; j++) {
                minerParcelMapping[firstMinerId + minerCounter] = parcelIds[i];
                parcelMinersMapping[parcelIds[i]].push(firstMinerId + minerCounter);
                minerCounter++;
                emit MinerAttached(user, parcelIds[i], firstMinerId + minerCounter);
            }
        }
    }

    /// @notice Upgrade the standard parcel
    function upgradeStandardParcel(uint256 _parcelId) external onlySaleActive {
        require(
            IERC721Base(standardParcelNFTAddress).ownerOf(_parcelId) == msg.sender,
            "Municipality: Invalid NFT owner"
        );
        bool isParcelUpgraded = IParcelInterface(standardParcelNFTAddress).isParcelUpgraded(_parcelId);
        require(!isParcelUpgraded, "Municipality: Parcel is already upgraded");
        _transferToContract(upgradePrice);
        IAmountsDistributor(amountsDistributorAddress).distributeAmounts(upgradePrice, OPERATION_TYPE_MINT_OR_UPGRADE_PARCELS, msg.sender);
        LastPurchaseData storage lastPurchase = lastPurchaseData[msg.sender];
        userToPurchasedAmountMapping[msg.sender] += upgradePrice;
        _updateAdditionLevel(msg.sender);
        lastPurchase.dollarValue += upgradePrice;
        _lastPurchaseDateUpdate(msg.sender);
        IParcelInterface(standardParcelNFTAddress).upgradeParcel(_parcelId);
        emit StandardParcelUpgraded(msg.sender, _parcelId);
    }

    // @notice App will use this function to get the price for the selected parcels
    function getPriceForParcels(Parcel[] calldata parcels) external view returns (uint256) {
        (uint256 price,) = _getPriceForParcels(parcels);
        return price;
    }
    
    function getUserMiners(address _user) external view returns (AttachedMiner[] memory) {
        uint256[] memory userMiners = IERC721Base(minerV1NFTAddress).tokensOf(_user);
        AttachedMiner[] memory result = new AttachedMiner[](userMiners.length);
        for (uint256 i = 0; i < userMiners.length; ++i) {
            uint256 minerId = userMiners[i];
            uint256 parcelId = minerParcelMapping[minerId];
            result[i] = AttachedMiner(parcelId, minerId);
        }
        return result;
    }
    // TODO: This function should be removed after 30 days from upgrade as the expiration date is in mapping lastPurchaseData
    function getNFTPurchaseExpirationDate(address _user) external view returns(uint256) {
        if(lastPurchaseData[_user].expirationDate > (INetGymStreet(netGymStreetAddress).lastPurchaseDateERC(_user) + 30 days)) {
            return lastPurchaseData[_user].expirationDate;
        } else {
            return INetGymStreet(netGymStreetAddress).lastPurchaseDateERC(_user) + 30 days;
        } 
    }

    function isTokenLocked(address _tokenAddress, uint256 _tokenId) external view returns(bool) { 
        if(_tokenAddress == minerV1NFTAddress) {
            return minerParcelMapping[_tokenId] > 0;
        } else if(_tokenAddress == standardParcelNFTAddress) {
            return parcelMinersMapping[_tokenId].length > 0;
        } else {
            revert("Municipality: Unsupported NFT token address");
        }
    }

    /// @notice automatically attach free miners to parcels
    function automaticallyAttachMinersToParcels(uint256 numMiners) external {
        _automaticallyAttachMinersToParcels(
            IERC721Base(standardParcelNFTAddress).tokensOf(msg.sender),
            IERC721Base(minerV1NFTAddress).tokensOf(msg.sender),
            numMiners);
    }

    

    // @notice Private interface

    function _automaticallyAttachMinersToParcels(uint256[] memory parcelIds, uint256[] memory userMiners, uint256 numMiners) private {
        // uint256 minerHashrate = IMinerNFT(minerV1NFTAddress).hashrate();
        uint256 lastAvailableMinerIndex = 0;
        for(uint256 i = 0; i < parcelIds.length && lastAvailableMinerIndex < userMiners.length && numMiners > 0; ++i) {
            uint256 availableSize = standardParcelSlotsCount - parcelMinersMapping[parcelIds[i]].length;
            if(availableSize > 0) {
                for(uint256 j = 0; j < availableSize; ++j) {
                    if(numMiners != 0) {
                        for(uint256 k = lastAvailableMinerIndex; k < userMiners.length; ++k) {
                            lastAvailableMinerIndex = k + 1;
                            if(minerParcelMapping[userMiners[k]] == 0) {
                                parcelMinersMapping[parcelIds[i]].push(userMiners[k]);
                                minerParcelMapping[userMiners[k]] = parcelIds[i];
                                IMining(miningAddress).deposit(msg.sender, userMiners[k], 1000);
                                emit MinerAttached(msg.sender, parcelIds[i], userMiners[k]);
                                --numMiners;
                                break;
                            }
                        }

                    }
                }
            }
        }
    }

    /// @notice Transfers the given BUSD amount to distributor contract
    function _transferToContract(uint256 _amount) private {
        IERC20Upgradeable(busdAddress).safeTransferFrom(
            address(msg.sender),
            address(amountsDistributorAddress),
            _amount
        );
    }

    /// @notice Checks if the miner is in the given list
    function _isMinerInList(uint256 _tokenId, uint256[] memory _minersList) private pure returns (bool) {
        for (uint256 index; index < _minersList.length; index++) {
            if (_tokenId == _minersList[index]) {
                return true;
            }
        }
        return false;
    }

    /// @notice Validates if the bundle corresponds to a type from this smart contract
    function _validateBasicBundleType(uint8 _bundleType) private pure {
        require
        (
            _bundleType == BUNDLE_TYPE_PARCELS_MINERS_1,
            "Municipality: Invalid bundle type"
        );
    }

    function _validateParcelsBundleType(uint8 _bundleType) private pure {
        require
        (
            _bundleType == BUNDLE_TYPE_PARCELS_1 ||
            _bundleType == BUNDLE_TYPE_PARCELS_2 ||
            _bundleType == BUNDLE_TYPE_PARCELS_3 ||
            _bundleType == BUNDLE_TYPE_PARCELS_4 ||
            _bundleType == BUNDLE_TYPE_PARCELS_5 ||
            _bundleType == BUNDLE_TYPE_PARCELS_6,
            "Municipality: Invalid bundle type"
        );
    }

    /// @notice Validates if the bundle corresponds to a type from this smart contract
    function _validateMinersBundleType(uint8 _bundleType) private pure {
        require
        (
            _bundleType == BUNDLE_TYPE_MINERS_1 ||
            _bundleType == BUNDLE_TYPE_MINERS_2 ||
            _bundleType == BUNDLE_TYPE_MINERS_3 ||
            _bundleType == BUNDLE_TYPE_MINERS_4 ||
            _bundleType == BUNDLE_TYPE_MINERS_5 ||
            _bundleType == BUNDLE_TYPE_MINERS_6,
            "Municipality: Invalid bundle type"
        );
    }

    /// @notice Requires that only a standard parcel can perform the operation
    function _requireOnlyStandardParcels(Parcel[] memory parcels) private pure {
        for(uint256 index; index < parcels.length; index++) {
            require(
                parcels[index].parcelType == PARCEL_TYPE_STANDARD,
                "Municipality: Parcel does not have standard type"
            );
        }
    }

    /// @notice Requires the miner status to match with the given by a function argument status
    function _requireMinerStatus(uint256 miner, uint8 status, uint256 attachedParcelId) private view {
        if (status == MINER_STATUS_ATTACHED) {
            require(minerParcelMapping[miner] == attachedParcelId, "Municipality: Miner not attached to this parcel");
        } else if (status == MINER_STATUS_DETACHED) {
            uint256 attachedParcel = minerParcelMapping[miner];
            require(attachedParcel == 0, "Municipality: Miner is not detached");
        }
    }

    /// @notice Attach or detach the miners from/to parcel
    function _attachDetachMinersToParcel(uint256[] memory newMiners, uint256 parcelId) private {
        uint256[] memory oldMiners = parcelMinersMapping[parcelId];
        for (uint256 index; index < oldMiners.length; index++) {
            uint256 tokenId = oldMiners[index];
            if (!_isMinerInList(tokenId, newMiners)) {
                _requireMinerStatus(tokenId, MINER_STATUS_ATTACHED, parcelId);
                minerParcelMapping[tokenId] = 0;
                IMining(miningAddress).withdraw(msg.sender,tokenId);
                emit MinerDetached(msg.sender, parcelId, tokenId);
            }
        }
        uint256 minerHashrate = IMinerNFT(minerV1NFTAddress).hashrate();
        for (uint256 index; index < newMiners.length; index++) {
            uint256 tokenId = newMiners[index];
            if (!_isMinerInList(tokenId, oldMiners)) {
                _requireMinerStatus(tokenId, MINER_STATUS_DETACHED, parcelId);
                minerParcelMapping[tokenId] = parcelId;
                IMining(miningAddress).deposit(msg.sender, tokenId, minerHashrate);
                emit MinerAttached(msg.sender, parcelId, tokenId);
            }
        }
        parcelMinersMapping[parcelId] = newMiners;
    }

    /// @notice Require that the count of the miners match with the slots that are on a parcel (4 or 10)
    function _requireMinersCountMatchingWithParcelSlots(uint256 _parcelId, uint256 _count)
        private
        view
    {
        bool isParcelUpgraded = IParcelInterface(standardParcelNFTAddress).isParcelUpgraded(_parcelId);
        require(
            isParcelUpgraded
                ? _count <= upgradedParcelSlotsCount
                : _count <= standardParcelSlotsCount,
            "Municipality: Miners count exceeds parcel's slot count"
        );
    }

    /// @notice Returns the price of a given parcels
    function _getPriceForParcels(Parcel[] memory parcels) private view returns (uint256, uint256) {
        uint256 price = parcels.length * 100000000000000000000;
        uint256 unitPrice = 100000000000000000000;
        uint256 priceBefore = 0;
        uint256 totalParcelsToBuy = currentlySoldStandardParcelsCount + parcels.length;
        if(totalParcelsToBuy > 157500) {
            price = (parcels.length + currentlySoldStandardParcelsCount - 157500) * 301000000000000000000;
            unitPrice = 301000000000000000000;
            if(currentlySoldStandardParcelsCount < 157500) {
                priceBefore = (157500 - currentlySoldStandardParcelsCount) * 209000000000000000000;
            }
        } else if(totalParcelsToBuy > 100500) {
            price = (parcels.length + currentlySoldStandardParcelsCount - 100500) * 209000000000000000000;
            unitPrice = 209000000000000000000;
            if(currentlySoldStandardParcelsCount < 100500) {
                priceBefore = (100500 - currentlySoldStandardParcelsCount) * 144000000000000000000;
            }
        } else if(totalParcelsToBuy > 52500) {
            price = (parcels.length + currentlySoldStandardParcelsCount - 52500) * 144000000000000000000;
            unitPrice = 144000000000000000000;
            if(currentlySoldStandardParcelsCount < 52500) {
                priceBefore = (52500 - currentlySoldStandardParcelsCount) * 116000000000000000000;
            }
        } else if(totalParcelsToBuy > 21000) {
            price = (parcels.length + currentlySoldStandardParcelsCount - 21000) * 116000000000000000000;
            unitPrice = 116000000000000000000;
            if(currentlySoldStandardParcelsCount < 21000) {
                priceBefore = (21000 - currentlySoldStandardParcelsCount) * 100000000000000000000;
            }
        }
        return (priceBefore + price, unitPrice);
    }

    /// @notice Returns the discounted price of the bundle
    function _discountPrice(uint256 _price, uint256 _percentage) private pure returns (uint256) {
        return _price - (_price * _percentage) / 100;
    }

     /**
     * @notice Private function to update additional level in GymStreet
     * @param _user: user address
     */
    function _updateAdditionLevel(address _user) private {
        uint256 _additionalLevel;
        (uint256 termTimestamp, uint256 _gymLevel) = INetGymStreet(netGymStreetAddress).getInfoForAdditionalLevel(_user);
        if (termTimestamp + 1209600 > block.timestamp){ // 14 days
            if (userToPurchasedAmountMapping[_user] >= 20000 * 1e18) {
                _additionalLevel = 14;
            } else if (userToPurchasedAmountMapping[_user] >= 5000 * 1e18) {
                _additionalLevel = 7;
            } else if (userToPurchasedAmountMapping[_user] >= 1000 * 1e18) {
                _additionalLevel = 5;
            }

            if (_additionalLevel > _gymLevel) {
            INetGymStreet(netGymStreetAddress).updateAdditionalLevel(_user, _additionalLevel);
            }
        }
    }

    /**
     * @notice Private function to update last purchase date
     * @param _user: user address
     */
    // TODO: need to remove the above if checks after 30 days of upgrade and deprication of updating ERC721base userPurchaseDate mapping
    function _lastPurchaseDateUpdate(address _user) private {
        LastPurchaseData storage lastPurchase = lastPurchaseData[_user];
        uint256 _lastDate = INetGymStreet(netGymStreetAddress).lastPurchaseDateERC(_user);
        lastPurchase.lastPurchaseDate = block.timestamp;
        lastPurchase.expirationDate = _lastDate + 30 days;
        if(lastPurchase.expirationDate < block.timestamp) {
            lastPurchase.expirationDate = lastPurchase.lastPurchaseDate;
        }
        if (lastPurchase.dollarValue >= (100 * 1e18)) {
            lastPurchase.expirationDate = lastPurchase.lastPurchaseDate + 30 days;
            lastPurchase.dollarValue = 0;     
        }
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../extensions/draft-IERC20PermitUpgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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

    function safePermit(
        IERC20PermitUpgradeable token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
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
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import '../Municipality.sol';

interface IMinerPublicBuildingInterface {
    function mintParcelsBundle(address user, Municipality.Parcel [] memory) external returns (uint256[] memory);
    function mintMinersBundle(address user, uint256 minersAmount) external returns (uint256, uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "../Municipality.sol";

interface ISignatureValidator {
    function verifySigner(Municipality.ParcelsMintSignature memory mintParcelSignature) external view returns(bool);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "./IPancakeRouter01.sol";

interface IPancakeRouter02 is IPancakeRouter01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../Municipality.sol";

interface IParcelInterface {
    function mint(address user, uint256 x, uint256 y, uint256 landType) external returns (uint256);
    function parcelExists(uint256 x, uint256 y, uint256 landType) external view returns(bool);
    function getParcelId(uint256 x, uint256 y, uint256 landType) external pure returns (uint256);
    function isParcelUpgraded(uint256 tokenId) external view returns (bool);
    function upgradeParcel(uint256 tokenId) external;
    function mintParcels(address _user, Municipality.Parcel[] calldata parcels) external returns(uint256[] memory);
    function requireNFTsBelongToUser(uint256[] memory nftIds, address userWalletAddress) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface INetGymStreet {
    function addGymMlm(address _user, uint256 _referrerId) external;

    function distributeRewards(
        uint256 _wantAmt,
        address _wantAddr,
        address _user
    ) external;

    function getUserCurrentLevel(address _user) external view returns (uint256);

    function updateAdditionalLevel(address _user, uint256 _level) external;

    function getInfoForAdditionalLevel(address _user) external view returns (uint256 _termsTimestamp, uint256 _level);

    function lastPurchaseDateERC(address _user) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

import "./IERC165.sol";
import "./IERC721Lockable.sol";
import "./IERC721Metadata.sol";

pragma solidity ^0.8.15;

interface IERC721Base is IERC165, IERC721Lockable, IERC721Metadata {
    /**
     * @dev This event is emitted when token is transfered
     * @param _from address of the user from whom token is transfered
     * @param _to address of the user who will recive the token
     * @param _tokenId id of the token which will be transfered
     */
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    /**
     * @dev This event is emitted when user is approved for token
     * @param _owner address of the owner of the token
     * @param _approval address of the user who gets approved
     * @param _tokenId id of the token that gets approved
     */
    event Approval(address indexed _owner, address indexed _approval, uint256 indexed _tokenId);

    /**
     * @dev This event is emitted when an address is approved/disapproved for another user's tokens
     * @param _owner address of the user whos tokens are being approved/disapproved to be used
     * @param _operator address of the user who gets approved/disapproved
     * @param _approved true - approves, false - disapproves
     */
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /// @notice Total amount of nft tokens in circulation
    function totalSupply() external view returns (uint256);

    /**
     * @notice Gives the number of nft tokens that a given user owns
     * @param _owner address of the user who's token's count will be returned
     * @return amount of tokens given user owns
     */
    function balanceOf(address _owner) external view returns (uint256);

    /**
     * @notice Tells weather a token exists
     * @param _tokenId id of the token who's existence is returned
     * @return true - exists, false - does not exist
     */
    function exists(uint256 _tokenId) external view returns (bool);

    /**
     * @notice Gives owner address of a given token
     * @param _tokenId id of the token who's owner address is returned
     * @return address of the given token owner
     */
    function ownerOf(uint256 _tokenId) external view returns (address);

    /**
     * @notice Transfers token and checkes weather it was recieved if reciver is ERC721Reciver contract
     *         Only authorized users can call this function
     *         Only unlocked tokens can be used to transfer
     * @dev When calling "onERC721Received" function passes "_data" from this function arguments
     * @param _from address of the user from whom token is transfered
     * @param _to address of the user who will recive the token
     * @param _tokenId id of the token which will be transfered
     * @param _data argument which will be passed to "onERC721Received" function
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) external;

    /**
     * @notice Transfers token and checkes weather it was recieved if reciver is ERC721Reciver contract
     *         Only authorized users can call this function
     *         Only unlocked tokens can be used to transfer
     * @dev When calling "onERC721Received" function passes an empty string for "data" parameter
     * @param _from address of the user from whom token is transfered
     * @param _to address of the user who will recive the token
     * @param _tokenId id of the token which will be transfered
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external;

    /**
     * @notice Transfers token without checking weather it was recieved
     *         Only authorized users can call this function
     *         Only unlocked tokens can be used to transfer
     * @dev Does not call "onERC721Received" function even if the reciver is ERC721TokenReceiver
     * @param _from address of the user from whom token is transfered
     * @param _to address of the user who will recive the token
     * @param _tokenId id of the token which will be transfered
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external;

    /**
     * @notice Approves an address to use given token
     *         Only authorized users can call this function
     * @dev Only one user can be approved at any given moment
     * @param _approved address of the user who gets approved
     * @param _tokenId id of the token the given user get aproval on
     */
    function approve(address _approved, uint256 _tokenId) external;

    /**
     * @notice Approves or disapproves an address to use all tokens of the caller
     * @param _operator address of the user who gets approved/disapproved
     * @param _approved true - approves, false - disapproves
     */
    function setApprovalForAll(address _operator, bool _approved) external;

    /**
     * @notice Gives the approved address of the given token
     * @param _tokenId id of the token who's approved user is returned
     * @return address of the user who is approved for the given token
     */
    function getApproved(uint256 _tokenId) external view returns (address);

    /**
     * @notice Tells weather given user (_operator) is approved to use tokens of another given user (_owner)
     * @param _owner address of the user who's tokens are checked to be aproved to another user
     * @param _operator address of the user who's checked to be approved by owner of the tokens
     * @return true - approved, false - disapproved
     */
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

    /**
     * @notice Tells weather given user (_operator) is approved to use given token (_tokenId)
     * @param _operator address of the user who's checked to be approved for given token
     * @param _tokenId id of the token for which approval will be checked
     * @return true - approved, false - disapproved
     */
    function isAuthorized(address _operator, uint256 _tokenId) external view returns (bool);

    /// @notice Returns the purchase date for this NFT
    function getUserPurchaseTime(address _user) external view returns (uint256[2] memory);

    /// @notice Returns all the token IDs belonging to this user
    function tokensOf(address _owner) external view returns (uint256[] memory);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IBuyAndBurn {
    function buyAndBurnGymWithBNB(
        uint256,
        uint256,
        uint256
    ) external returns (uint256);

    function buyAndBurnGymWithBUSD(
        uint256,
        uint256,
        uint256
    ) external returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IMinerNFT {
    function mint(address) external returns (uint256);
    function hashrate() external pure returns (uint256);
    function lastMinerId() external returns(uint256);
    function mintMiners(address _user, uint256 _count) external returns(uint256, uint256);
    function requireNFTsBelongToUser(uint256[] memory nftIds, address userWalletAddress) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IMining {
    function deposit(address _user, uint256 _miner, uint256 _hashRate) external;
    function depositMiners(address _user, uint256 _firstMinerId, uint256 _minersCount, uint256 _hashRate) external;
    function withdraw(address _user,uint256 _miner) external;
    function applyVouchers(address _user, uint256[] calldata _minerIds) external;
    function getMinersCount(address _user) external view returns (uint256);
    function repairMiners(address _user) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IAmountsDistributor {
    function distributeAmounts(uint256 _amount, uint8 _operationType, address _user) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20PermitUpgradeable {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IERC165 {
    /**
     * @notice Returns weather contract supports fiven interface
     * @dev This contract supports ERC165 and ERC721 interfaces
     * @param _interfaceId id of the interface which is checked to be supported
     * @return true - given interface is supported, false - given interface is not supported
     */
    function supportsInterface(bytes4 _interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IERC721Lockable {
    /**
     * @dev Event that is emitted when token lock status is set
     * @param _tokenId id of the token who's lock status is set
     * @param _lock true - is locked, false - is not locked
     */
    event LockStatusSet(uint256 _tokenId, bool _lock);

    /**
     * @notice Tells weather a token is locked
     * @param _tokenId id of the token who's lock status is returned
     * @return true - is locked, false - is not locked
     */
    function isLocked(uint256 _tokenId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IERC721Metadata {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function baseURI() external view returns (string memory);
}