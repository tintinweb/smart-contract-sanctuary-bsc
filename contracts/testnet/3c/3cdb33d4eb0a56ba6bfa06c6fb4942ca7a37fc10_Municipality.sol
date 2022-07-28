// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts-upgradeable/utils/cryptography/draft-EIP712Upgradeable.sol";
import "./interfaces/IMunicipality.sol";

contract Municipality is IMunicipality, OwnableUpgradeable, EIP712Upgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    IStandardParcel public standardParcelContract;

    uint256[4] public parcelMintingPricesInBUSD;

    uint256 public upgradePriceInBUSD;
    uint256 public brokerBrunchPrice;
    uint256[5] public minerPrices;

    uint256 public scarcityFactorMul1000000;

    uint256 public buyAndBurnAmountVBTC;
    uint256 public nftRankRewards;
    uint256 public buyAndBurnAmountGYM;
    uint256 public commissionWallet;

    address public buyAndBurn;
    address public vbtcAddress;
    address public gymAddress;
    IERC20Upgradeable public busdAddress;
    IMinerPublicBuilding public minerPublicBuilding;
    IBrokerPublicBuilding public brokerPublicBuilding;
    Bundle[6] public bundles;

    address payable public ambassadorAddress; // 5% , 5%, 5%
    address payable public reserveWalletAddress; // 0.7%, 0.7%, 0.7%
    address payable public companyWallet; // 20%, 20%, 20%, 20%
    address public backendAddress;

    string private constant SIGNING_DOMAIN = "Municipality";
    string private constant SIGNATURE_VERSION = "1";

    mapping(bytes => bool) private signatureUsed;

    modifier onlyBackend() {
        require(
            msg.sender == backendAddress,
            "Municipality: Can call only Backend"
        );
        _;
    }

    modifier initialized() {
        require(
            address(minerPublicBuilding) != address(0) &&
            address(standardParcelContract) != address(0) &&
            address(brokerPublicBuilding) != address(0),
            "Municipality: Contract isn't initialized"
        );
        _;
    }

    function initialize (address _buyAndBurn, address _backendAddress) external initializer {
        buyAndBurn = _buyAndBurn;
        backendAddress = _backendAddress;
        __EIP712_init(SIGNING_DOMAIN, SIGNATURE_VERSION);
        __Ownable_init();
    }

    receive() external payable {}

    fallback() external payable {}

    function mintParcel(
        MintParcelSignature calldata mintParcelSignature,
        bool testing
    ) external {
        if(!testing){
            require(
                !signatureUsed[mintParcelSignature.signature],
                "Municipality: Signature already used"
            );

            address messageSigner = _verify(mintParcelSignature);

            require(
                messageSigner == backendAddress,
                "Municipality: Invalid signer"           
            );
            signatureUsed[mintParcelSignature.signature] = true;
        }


        require(
            mintParcelSignature.value >= parcelMintingPricesInBUSD[uint256(mintParcelSignature.parcel._type)],
            "Municipality: Incorrect amount"
        );
        require(
            busdAddress.allowance(msg.sender, address(this)) >= mintParcelSignature.value,
            "Municipality: Municipality does not havea allowance"
        );

        busdAddress.safeTransferFrom(msg.sender, address(this), mintParcelSignature.value);
        brokerPublicBuilding.mintParcel(mintParcelSignature.parcel, msg.sender);
        updateParcelPrice(1);
    }

    function upgradeStandardParcel(
        uint256 _value,
        IBrokerPublicBuilding.Parcel memory _parcel
    ) external {
        require(_value >= upgradePriceInBUSD, "Municipality: Incorrect Amount");
        require(
            busdAddress.allowance(msg.sender, address(this)) >= _value,
            "Municipality: Municipality havn't allowance"
        );

        busdAddress.safeTransferFrom(msg.sender, address(this), _value);
        brokerPublicBuilding.upgradeStandardParcel(_parcel, msg.sender);
    }

    function mintMultipleParcelsFor(
        uint256 _value,
        IBrokerPublicBuilding.Parcel[] memory _parcels
    ) external {
        require(
            _value >= _calculateParcelsPrice(_parcels),
            "Municipality: Incorrect amount"
        );
        require(
            busdAddress.allowance(msg.sender, address(this)) >= _value,
            "Municipality: Municipality havn't allowance"
        );

        busdAddress.safeTransferFrom(msg.sender, address(this), _value);
        brokerPublicBuilding.mintMultipleParcelsFor(_parcels, msg.sender);
        updateParcelPrice(_parcels.length);
    }

    function buyBrokerBranchNFT(uint256 _value) external {
        require(_value >= brokerBrunchPrice, "Municipality: Incorrect amount");
        require(
            busdAddress.allowance(msg.sender, address(this)) >= _value,
            "Municipality: Municipality havn't allowance"
        );

        busdAddress.safeTransferFrom(msg.sender, address(this), _value);
        uint256 _tokenId = brokerPublicBuilding.buyBrokerBranch(msg.sender);
        emit BuyBrokerBranch(_tokenId);
    }

    function mintMiner(MinerTypes _minerType, uint256 _value) external {
        require(
            _value >= minerPrices[uint256(_minerType)],
            "Municipality: Incorrect Amount"
        );
        require(
            busdAddress.allowance(msg.sender, address(this)) >= _value,
            "Municipality: Municipality havn't allowance"
        );

        busdAddress.safeTransferFrom(msg.sender, address(this), _value);
        uint256 tokenId = minerPublicBuilding.mintMiner(msg.sender);
        emit MintMiner(tokenId);
    }

    function setMinerPrices(uint256[5] memory _prices) external onlyOwner {
        minerPrices = _prices;
    }

    function setBackendAddress(address _backendAddress) external onlyOwner {
        backendAddress = _backendAddress;
    }

    function setMinerPublicBuilding(address _minerPublicBuilding) external onlyOwner {
        minerPublicBuilding = IMinerPublicBuilding(_minerPublicBuilding);
    }

    function setStandardParcelContract(address _standardParcelContract) external onlyOwner {
        standardParcelContract = IStandardParcel(_standardParcelContract);
    }

    function setVBTCContractAddress(address _vbtc) external onlyOwner {
        vbtcAddress = _vbtc;
    }

    function setGymContractAddress(address _gym) external onlyOwner {
        gymAddress = _gym;
    }

    function setBundles(Bundle[6] memory _bundles) external onlyOwner {
        for (uint256 i; i < 6; i++) {
            bundles[i] = _bundles[i];
        }
    }

    function vbtcBuyAndBurn(
        uint256 _amount,
        uint256 _minBurnAmt,
        uint256 _deadline
    ) external onlyBackend {
        require(
            buyAndBurnAmountVBTC >= _amount,
            "Municipality: Not Enough Resources"
        );
        buyAndBurnAmountVBTC -= _amount;
        busdAddress.safeTransfer(buyAndBurn, _amount);
        IBuyAndBurn(buyAndBurn).buyAndBurnToken(
            address(busdAddress),
            _amount,
            vbtcAddress,
            _minBurnAmt,
            _deadline
        );
    }

    function gymNetBuyAndBurn(
        uint256 _amount,
        uint256 _minBurnAmt,
        uint256 _deadline
    ) external onlyBackend {
        require(
            buyAndBurnAmountGYM >= _amount,
            "Municipality: Not Enough Resources"
        );
        buyAndBurnAmountGYM -= _amount;
        busdAddress.safeTransfer(buyAndBurn, _amount);
        IBuyAndBurn(buyAndBurn).buyAndBurnToken(
            address(busdAddress),
            _amount,
            gymAddress,
            _minBurnAmt,
            _deadline
        );
    }

    function callNftRankRewards(uint256 _amount) external onlyBackend {
        require(
            nftRankRewards >= _amount,
            "Municipality: Not Enough Resources"
        );
        nftRankRewards -= _amount;
        ///
    }

    function commissioWalletDistribute(uint256 _amount) external onlyBackend {
        require(
            commissionWallet >= _amount,
            "Municipality: Not Enough Resources"
        );
        commissionWallet -= _amount;
    }

    function withdrawToken(IERC20Upgradeable _tokenAddress, uint256 _amount)
        external
        onlyOwner
    {
        _tokenAddress.safeTransfer(msg.sender, _amount);
    }

    function buyBundle(
            IBrokerPublicBuilding.Parcel memory _parcel,
            BundleTypes _bundleType,
            uint256 _value
        ) external initialized {
        uint bundlePrice = _calculateBundlePrice(_bundleType, _parcel._type);
        require(
            _value >= bundlePrice,
            "Municipality: incorrect money amount"
        );
        busdAddress.safeTransferFrom(msg.sender, address(this), bundlePrice);

        Bundle memory bundle = bundles[uint8(_bundleType)];

        uint currentX = _parcel._x;
        uint currentY = _parcel._y;
        for(
            uint i;
            i < bundle.parcelSize ** 2;
            i++
        ) {
            // Mint Parcel
            IBrokerPublicBuilding.Parcel memory newParcel;
            newParcel._x = currentX;
            newParcel._y = currentY;
            brokerPublicBuilding.mintParcel(newParcel, msg.sender); 

            // Mint Miner
            uint256 minerTokenId = minerPublicBuilding.mintMiners(msg.sender, uint256(standardParcelContract.standardParcelSlotsLimit()));

            // Assigne Miner to Parcel
            brokerPublicBuilding.assignOnStandardParcelByMunicipality(newParcel, minerTokenId, uint256(standardParcelContract.standardParcelSlotsLimit()));
            currentX++; 
            if(i % bundle.parcelSize == 1 && i != 0) {
                currentY++;
                currentX = _parcel._x;
            }
        }
        updateParcelPrice(bundle.parcelSize ** 2);
    }

    function getBuyAndBurnAmountVBTC()
        external
        view
        onlyBackend
        returns (uint256)
    {
        return buyAndBurnAmountVBTC;
    }

    function getBuyAndBurnAmountGYM()
        external
        view
        onlyBackend
        returns (uint256)
    {
        return buyAndBurnAmountGYM;
    }

    function getNftRankRewards() external view onlyBackend returns (uint256) {
        return nftRankRewards;
    }

    function setBrokerBrunchPrice(uint256 _price) external onlyOwner {
        brokerBrunchPrice = _price;
    }

    function setBUSDAddress(IERC20Upgradeable _token) external onlyOwner {
        busdAddress = _token;
    }

    function setScarcityFactor(uint256 _value) external onlyOwner {
        scarcityFactorMul1000000 = _value;
    }

    function setBrokerPublicBuilding(address _brokerPublicBuilding) external onlyOwner {
        brokerPublicBuilding = IBrokerPublicBuilding(_brokerPublicBuilding);
    }

    function setParcelMintingPrice(uint256 _price, ParcelTypes _parcelType)
        external
        onlyOwner
    {
        parcelMintingPricesInBUSD[uint256(_parcelType)] = _price;
    }

    function setUpgradePrice(uint256 _price) external onlyOwner {
        upgradePriceInBUSD = _price;
    }

    function calculateParcelsPrice(
        IBrokerPublicBuilding.Parcel[] memory _parcels
    ) external view returns (uint256 finalPrice) {
        return _calculateParcelsPrice(_parcels);
    }

    function calculateBundlePrice(
        BundleTypes _bundleType,
        IBrokerPublicBuilding.ParcelTypes _parcelType
    ) external view returns (uint256 finalPrice) {
        return _calculateBundlePrice(_bundleType, _parcelType);
    }

    // function checkParcelIsFree(
    //     IBrokerPublicBuilding.Parcel memory _parcel,
    //     uint256 _size
    // ) external view returns (bool) {
    //     return _checkParcelIsFree(_parcel, _size);
    // }

    // function _checkParcelIsFree(
    //     IBrokerPublicBuilding.Parcel memory _parcel,
    //     uint256 _size
    // ) internal view returns (bool) {
    //     IParcel.Parcel memory parcel = IParcel.Parcel(_parcel._x, _parcel._y);
    //     _size = sqrt(_size);
    //     for (int256 i = 0; i <= int256(_size); i++) {
    //         if (!standardParcelContract.parcelExists(parcel)) {
    //             return false;
    //         }
    //         parcel._x++;
    //         parcel._y++;
    //     }
    //     return true;
    // }

    function _calculateParcelsPrice(
        IBrokerPublicBuilding.Parcel[] memory _parcels
    ) internal view returns (uint256 finalPrice) {
        for (
            uint256 i = 1;
            i <= _parcels.length;
            i++
        ) {
            finalPrice += parcelMintingPricesInBUSD[uint8(_parcels[i]._type)] 
                * (1 + (scarcityFactorMul1000000 / 1000000))
                ** i;
        }
    }

    function _calculateBundlePrice(
        BundleTypes _bundleType,
        IBrokerPublicBuilding.ParcelTypes _parcelType
    ) internal view returns (uint256 finalPrice) {
        finalPrice =
            bundles[uint256(_bundleType)].minerCount *
            minerPrices[uint8(MinerTypes.Miner1x)];
        uint parcelTypePrice = parcelMintingPricesInBUSD[uint8(_parcelType)];
        for (
            uint256 i = 1;
            i <= bundles[uint256(_bundleType)].parcelSize ** 2;
            i++
        ) {
            finalPrice += parcelTypePrice 
                * (1 + (scarcityFactorMul1000000 / 1000000))
                ** i;
        }
        finalPrice -= finalPrice * bundles[uint256(_bundleType)].discount / 100;
    }

    function _verify(MintParcelSignature calldata mintParcelSignature) private view returns (address) {
        bytes32 _digest = _hash(mintParcelSignature);
        return ECDSAUpgradeable.recover(_digest, mintParcelSignature.signature);
    }

    function _hash(MintParcelSignature calldata mintParcelSignature) private view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        keccak256("SignatureMessage(uint256 value,uint256 x,uint256 y,uint256 type)"),
                        mintParcelSignature.value,
                        mintParcelSignature.parcel._x,
                        mintParcelSignature.parcel._y,
                        mintParcelSignature.parcel._type
                    )
                )
            );
    }

    function minerSales(uint256 msgValue) internal {
        busdAddress.safeTransfer(ambassadorAddress, (5 * msgValue) / 100);
        busdAddress.safeTransfer(reserveWalletAddress, (7 * msgValue) / 1000);
        commissionWallet += ((39 * msgValue) / 100);

        busdAddress.safeTransfer(companyWallet, (20 * msgValue) / 100);
        buyAndBurnAmountVBTC += ((7 * msgValue) / 100);
        buyAndBurnAmountGYM += ((10 * msgValue) / 100);
        nftRankRewards += ((23 * msgValue) / 1000);
        emit TransferAfterMinerSales(msgValue);
    }

    function brokerSalesInitialMintingLandUpgrade(uint256 msgValue) internal {
        busdAddress.safeTransfer(ambassadorAddress, (5 * msgValue) / 100);
        busdAddress.safeTransfer(reserveWalletAddress, (7 * msgValue) / 1000);

        commissionWallet += ((39 * msgValue) / 100);
        busdAddress.safeTransfer(companyWallet, (20 * msgValue) / 100);
        buyAndBurnAmountVBTC += ((6 * msgValue) / 100);
        buyAndBurnAmountGYM += ((15 * msgValue) / 100);
        nftRankRewards += ((23 * msgValue) / 1000);
        emit TransferAfterBrokerSalesInitialMintingLandUpgrade(msgValue);
    }

    function minerRepair(uint256 msgValue) internal {
        busdAddress.safeTransfer(ambassadorAddress, (5 * msgValue) / 100);
        busdAddress.safeTransfer(reserveWalletAddress, (7 * msgValue) / 1000);
        commissionWallet += ((39 * msgValue) / 100);

        busdAddress.safeTransfer(companyWallet, (20 * msgValue) / 100);
        buyAndBurnAmountVBTC += ((7 * msgValue) / 100);
        buyAndBurnAmountGYM += ((10 * msgValue) / 100);
        nftRankRewards += ((23 * msgValue) / 1000);
        emit TransferAfterMinerRepair(msgValue);
    }

    function electricityPayment(uint256 msgValue) internal {
        busdAddress.safeTransfer(companyWallet, (20 * msgValue) / 100);
        buyAndBurnAmountVBTC += ((40 * msgValue) / 100);
        buyAndBurnAmountGYM += ((40 * msgValue) / 100);
        emit TransferAfterElectricityPayment(msgValue);
    }

    function updateParcelPrice(uint256 _count) internal {
        parcelMintingPricesInBUSD[uint8(ParcelTypes.standard)] =
            (parcelMintingPricesInBUSD[uint8(ParcelTypes.standard)] / 1000000) *
            (scarcityFactorMul1000000**_count);
        emit UpdateStandardParcelPrice(
            parcelMintingPricesInBUSD[uint8(ParcelTypes.standard)]
        );
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/draft-EIP712.sol)

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
 *
 * @custom:storage-size 52
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
    function __EIP712_init(string memory name, string memory version) internal onlyInitializing {
        __EIP712_init_unchained(name, version);
    }

    function __EIP712_init_unchained(string memory name, string memory version) internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "./IBrokerPublicBuilding.sol";
import "./IBuyAndBurn.sol";
import "./IActivatableNFT.sol";
import "./IStandardParcel.sol";
import "./IParcel.sol";
import "./IVBTC.sol";
import "./IMinerPublicBuilding.sol";
import "./IBrokerPublicBuilding.sol";

interface IMunicipality {
    enum ParcelTypes {
        standardNextOcean,
        standardNearOcean,
        standard,
        Business
    }
    enum BundleTypes {
        Bundle1,
        Bundle4,
        Bundle16,
        Bundle64,
        Bundle128,
        Bundle256
    }
    enum MinerTypes {
        Miner1x,
        Miner4x,
        Miner9x,
        Miner12x,
        Miner18x
    }

    struct MintParcelSignature {
        uint256 value;
        IBrokerPublicBuilding.Parcel parcel;
        bytes signature;
    }

    struct Bundle {
        uint256 parcelSize;
        uint256 minerCount;
        // 100% == 100
        uint8 discount;
    }
    event TransferAfterMinerSales(uint256 indexed msgValue);
    event TransferAfterBrokerSalesInitialMintingLandUpgrade(
        uint256 indexed msgValue
    );
    event TransferAfterMinerRepair(uint256 indexed msgValue);
    event TransferAfterElectricityPayment(uint256 indexed msgValue);
    event UpdateStandardParcelPrice(uint256 indexed _amount);
    event BuyBrokerBranch(uint256 indexed _tokenId);
    event MintMiner(uint256 indexed _tokenId);

    function mintParcel(
        MintParcelSignature calldata mintParcelSignature,
        bool testing
    ) external;

    function upgradeStandardParcel(
        uint256 _value,
        IBrokerPublicBuilding.Parcel memory _parcel
    ) external;

    function mintMultipleParcelsFor(
        uint256 _value,
        IBrokerPublicBuilding.Parcel[] memory _parcels
    ) external;

    function buyBrokerBranchNFT(uint256 _value) external;

    function mintMiner(MinerTypes _minerType, uint256 _value) external;

    function setMinerPrices(uint256[5] memory _prices) external;

    function setVBTCContractAddress(address _vbtc) external;

    function setGymContractAddress(address _gym) external;

    function commissioWalletDistribute(uint256 _amount) external;

    function vbtcBuyAndBurn(
        uint256 _amount,
        uint256 _minBurnAmt,
        uint256 _deadline
    ) external;

    function gymNetBuyAndBurn(
        uint256 _amount,
        uint256 _minBurnAmt,
        uint256 _deadline
    ) external;

    function callNftRankRewards(uint256 _amount) external;

    function withdrawToken(IERC20Upgradeable _tokenAddress, uint256 _amount) external;

    function getBuyAndBurnAmountVBTC() external view returns (uint256);

    function getBuyAndBurnAmountGYM() external view returns (uint256);

    function getNftRankRewards() external view returns (uint256);

    function setBackendAddress(address _backendAddress) external;

    function setMinerPublicBuilding(address _minerPublicBuilding) external;

    function setStandardParcelContract(address _standardParcelContract) external;

    function setBrokerBrunchPrice(uint256 _price) external;

    function setBUSDAddress(IERC20Upgradeable _token) external;

    function setScarcityFactor(uint256 _value) external;

    function setBundles(Bundle[6] memory _bundles) external;

    function setBrokerPublicBuilding(address _brokerPublicBuilding) external;

    function setParcelMintingPrice(uint256 _price, ParcelTypes _parcelType)
        external;

    function setUpgradePrice(uint256 _price) external;

    function calculateParcelsPrice(
        IBrokerPublicBuilding.Parcel[] memory _parcels
    ) external view returns (uint256 finalPrice);

    // function checkParcelIsFree(
    //     IBrokerPublicBuilding.Parcel memory _parcel,
    //     uint256 _size
    // ) external view returns (bool);

    function buyBundle(
        IBrokerPublicBuilding.Parcel memory _parcel,
        BundleTypes _bundleType,
        uint256 _value
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../StringsUpgradeable.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSAUpgradeable {
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
            /// @solidity memory-safe-assembly
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
            /// @solidity memory-safe-assembly
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
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", StringsUpgradeable.toString(s.length), s));
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

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

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
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

pragma solidity ^0.8.14;

import "./IActivatableNFT.sol";
import "./IStandardParcel.sol";
import "./IBusinessParcel.sol";

interface IBrokerPublicBuilding {
    enum ParcelTypes {
        StandartNextOcean,
        StandartNearOcean,
        Standart,
        Business
    }
    struct Parcel {
        uint256 _x;
        uint256 _y;
        ParcelTypes _type;
    }
    enum ParcelNFTTypes {
        Miner,
        Aesthetic,
        Broker,
        Factory,
        Bank,
        NFTMarketplace
    }
    event AssignNFT(
        Parcel _parcel,
        ParcelNFTTypes _nftType,
        uint256 _nftTokenId
    );
    event UnAssignNFT(
        Parcel _parcel,
        ParcelNFTTypes _nftType,
        uint256 _nftTokenId
    );

    function mintParcel(Parcel memory _parcel, address _owner) external;

    function mintMultipleParcelsFor(Parcel[] memory _parcels, address _owner)
        external;

    function mintAdjacentQuadraticParcels(
        address _beneficiary,
        IParcel.Parcel memory _parcel,
        uint256 _size
    ) external;

    function assignOnStandardParcelByMunicipality(
        Parcel memory _parcelCordinates,
        uint256 _nftTokenId,
        uint minersAmount
    ) external;

    function upgradeStandardParcel(Parcel memory _parcel, address _owner)
        external;

    function assignNFT(
        Parcel memory _parcel,
        ParcelNFTTypes _nftType,
        uint256 _nftTokenId
    ) external;

    function unassignNFT(
        Parcel memory _parcel,
        ParcelNFTTypes _nftType,
        uint256 _nftTokenId
    ) external;

    function buyBrokerBranch(address _owner)
        external
        returns (uint256 _tokenId);

    function getParcelIdFromNFTId(
        ParcelNFTTypes _nftTokenType,
        ParcelTypes _parcelType,
        uint256 _nftTokenId
    ) external returns (uint256);

    function setMunicipality(address _municipality) external;

    function setNFTContract(
        IActivatableNFT _ActivatableNFTContract,
        ParcelNFTTypes _nftType
    ) external;

    function setParcelsCount(uint256[2] memory _counts) external;

    function setBusinessParcelContract(IBusinessParcel _contract) external;

    function setStandardParcelContract(IStandardParcel _contract) external;

    function isStandardParcelUpgraded(Parcel memory _parcel)
        external
        view
        returns (bool);

    function withdrawAll() external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

interface IBuyAndBurn {
    function buyAndBurnToken(
        address,
        uint256,
        address,
        uint256,
        uint256
    ) external returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;
import "./IERC721Base.sol";

interface IActivatableNFT is IERC721Base {
    function changeTokenLocking(uint256 _tokenID, bool _lockStatus) external;
    function setBranchPublicBuildingContractAddress(address _brokerPBContractAddress) external;
    function getBranchPublicBuildingContractAddress() external view returns (address);
    function mintNFTTo(address _to) external returns(uint tokenId);
    function setBaseURI(string memory _uRI) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./IParcel.sol";

interface IStandardParcel is IParcel {
    enum ActivatableNFTs {
        Aesthetic,
        Miner
    }
    struct ParcelInfo {
        bool upgradeStatus;
        uint256[] minerNFTTokenIds;
        uint256[] aestheticNFTTokenIds;
    }

    /// @notice Event that is emitted when parcel is upgraded
    event ParcelUpgraded(uint256 _tokenId);

    /// @notice Event that is emitted when some token is assigned on parcel
    event Assigned(uint256 _parcelId, uint256 _tokenId);

    /// @notice Event that is emitted when some token is unassigned on parcel
    event Unassigned(uint256 _parcelId, uint256 _tokenId);

    function setStandardParcelSlotsLimit(uint8 _standardParcelSlotsLimit)
        external;

    function setUpgradedParcelSlots(uint8 _upgradedParcelSlotsLimit) external;

    function standardParcelSlotsLimit() external returns(uint8);

    function upgradeParcel(Parcel memory _parcel) external;

    function assignNFT(
        ActivatableNFTs _activatableNFTType,
        Parcel memory _parcel,
        uint256 _tokenId
    ) external;

    function unassignNFT(
        ActivatableNFTs _activatableNFTType,
        Parcel memory _parcel,
        uint256 _tokenId
    ) external;

    function isUpgraded(uint256 _parcelId) external view returns (bool);

    function getParcelNFTs(
        ActivatableNFTs _activatableNFTType,
        Parcel memory _parcel
    ) external view returns (uint256[] memory);

    function getNFTParcel(ActivatableNFTs _activatableNFTType, uint256 _tokenId)
        external
        view
        returns (uint256);

    function isParcelUpgraded(Parcel memory _parcel)
        external
        view
        returns (bool);

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./IERC721Base.sol";

interface IParcel is IERC721Base {
    struct Parcel {
        uint256 _x;
        uint256 _y;
    }
    enum ParcelType {
        Standart,
        Business
    }
    event BrokerChanged(address brokerPBContractAddress);
    event ParcelMinted(uint256 _tokenId, address _owner);
    event TransferParcelFrom(address _from, address _to, uint256 _tokenId);

    function setBrokerPBContractAddress(address _brokerPBContractAddress)
        external;

    function getTokenId(Parcel memory _parcel)
        external
        view
        returns (uint256 tokenId);

    function getCordinatesFromId(uint256 _tokenId)
        external
        view
        returns (uint256 x, uint256 y);

    function mintParcelFor(address _beneficiary, Parcel memory _parcel)
        external;

    function mintAdjacentQuadraticParcels(
        address _beneficiary,
        Parcel memory _parcel,
        uint256 _size
    ) external;

    function transferParcelFrom(
        address _from,
        address _to,
        Parcel memory _parcel
    ) external;

    function transferMultipleParcels(address _to, Parcel[] memory _parcels)
        external;

    function transferAdjacentQuadraticParcels(
        address _to,
        Parcel memory _parcel,
        uint256 _size
    ) external;

    function parcelExists(Parcel memory _parcel) external view returns (bool);

    function ownerOfParcel(Parcel memory _parcel)
        external
        view
        returns (address);

    function ownersOfMultipleParcels(Parcel[] memory _parcel)
        external
        view
        returns (address[] memory ownerAddresses);

    function allParcelsOf(address _owner)
        external
        view
        returns (Parcel[] memory cordinates);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface IVBTC {

    function transfer(address _to, uint256 _value) external returns (bool);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function approve(address _spender, uint256 _value) external returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

    function allowance(address _owner, address _spender) external view returns (uint256);

    function increaseApproval(address _spender, uint256 _addedValue) external returns (bool);

    function decreaseApproval(address _spender, uint256 _subtractedValue) external returns (bool);

    function mintTo(address _to,uint256 _amount) external returns (bool);

    function burn(uint256 _amount) external returns (bool);

    function burnFrom(address _from,uint256 _amount) external returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./IActivatableNFT.sol";
import "./IStandardParcel.sol";

interface IMinerPublicBuilding {
    function mintMiner(address _owner) external returns (uint256 tokenId);
    
    function mintMiners(address _owner, uint _amount) external returns (uint256 tokenId);

    function setMinerMintingPrice(uint256 _minerMintingPriceInBNB) external;

    function setMinerNFTContract(IActivatableNFT _minerNFTContract) external;

    function setMunicipalityAddress(address _municipality) external;

    function addNFTStaking(address _userAddress) external;

    function removeNFTStaking(address _userAddress) external;

    function setBrokerContract(address _brokerAddress) external;

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

pragma solidity ^0.8.14;

import "./IParcel.sol";

interface IBusinessParcel is IParcel {
    enum PublicBuildings {
        Aesthetic,
        Broker,
        Factory,
        Bank,
        NFTMarketplace
    }
    /// @notice Event that is emitted when some token is assigned on parcel
    event Assigned(
        uint256 _parcelId,
        uint256 _tokenId,
        PublicBuildings _publicBuildingType
    );

    /// @notice Event that is emitted when some token is unassigned on parcel
    event Unassigned(
        uint256 _parcelId,
        uint256 _tokenId,
        PublicBuildings _publicBuildingType
    );

    /// @notice Event that is emitted when addresses contracts is changed
    event BuildingAddressChanged(address[] _contracts);
    struct PublicBuildingsBranches {
        uint256 branch;
        PublicBuildings _type;
        uint256[] aestheticNFTTokenIds;
        bool occupied;
    }

    function assignNFT(
        PublicBuildings _publicBuildingType,
        Parcel memory _parcel,
        uint256 _tokenId
    ) external;

    function unassignNFT(
        PublicBuildings _publicBuildingType,
        Parcel memory _parcel,
        uint256 _tokenId
    ) external;

    function getParcelBuildings(Parcel memory _parcel)
        external
        view
        returns (PublicBuildingsBranches memory);

    function getNFTParcel(PublicBuildings _publicBuildingType, uint256 _tokenId)
        external
        view
        returns (uint256);
}

// SPDX-License-Identifier: MIT

import "./IERC165.sol";
import "./IERC721Lockable.sol";
import "./IERC721Metadata.sol";

pragma solidity ^0.8.14;

interface IERC721Base is IERC165, IERC721Lockable, IERC721Metadata{
    /**
     * @dev This event is emitted when token is transfered
     * @param _from address of the user from whom token is transfered
     * @param _to address of the user who will recive the token
     * @param _tokenId id of the token which will be transfered
     */
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );

    /**
     * @dev This event is emitted when user is approved for token
     * @param _owner address of the owner of the token
     * @param _approval address of the user who gets approved
     * @param _tokenId id of the token that gets approved
     */
    event Approval(
        address indexed _owner,
        address indexed _approval,
        uint256 indexed _tokenId
    );

    /**
     * @dev This event is emitted when an address is approved/disapproved for another user's tokens
     * @param _owner address of the user whos tokens are being approved/disapproved to be used
     * @param _operator address of the user who gets approved/disapproved
     * @param _approved true - approves, false - disapproves
     */
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    /// @notice Total amount of NFT tokens in circulation
    function totalSupply() external view returns (uint256);

    /**
     * @notice Gives the number of NFT tokens that a given user owns
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
    function isApprovedForAll(address _owner, address _operator)
        external
        view
        returns (bool);

    /**
     * @notice Tells weather given user (_operator) is approved to use given token (_tokenId)
     * @param _operator address of the user who's checked to be approved for given token
     * @param _tokenId id of the token for which approval will be checked
     * @return true - approved, false - disapproved
     */
    function isAuthorized(address _operator, uint256 _tokenId)
        external
        view
        returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

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

pragma solidity ^0.8.14;

interface IERC721Lockable {

     /**
     * @dev Event that is emitted when token lock status is set
     * @param _tokenId id of the token who's lock status is set
     * @param _lock true - is locked, false - is not locked
     */
    event LockStatusSet(uint _tokenId, bool _lock);

     /**
     * @notice Tells weather a token is locked
     * @param _tokenId id of the token who's lock status is returned
     * @return true - is locked, false - is not locked
     */
    function isLocked(uint _tokenId) external view returns (bool);

}

// SPDX-License-Identifier: MIT 

pragma solidity 0.8.14;

interface IERC721Metadata {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function baseURI() external view returns (string memory);
}