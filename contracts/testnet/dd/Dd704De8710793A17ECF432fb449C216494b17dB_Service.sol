// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.4 <0.9.0;

import "./IERC20.sol";
import "./IERC721.sol";
import "./Ownable.sol";
import "./IService.sol";
import "./IERC20Metadata.sol";

contract Service is Ownable, IService {
    // ----- STRUCTS ----- //
    struct RoyaltyInfo {
        address owner;
        uint96 rate;
    }

    struct KotHInfo {
        address owner;
        uint256 price;
    }

    // ----- STATE VARIABLES ----- //
    mapping(address => RoyaltyInfo) _royalties;
    mapping(address => mapping(uint256 => KotHInfo)) _koths;
    mapping(address => mapping(uint256 => uint256)) _gammaLocks;
    mapping(address => bool) _isKotH;
    mapping(address => uint96) _kothRates;

    IERC20 _gammaToken;
    IMintMachine _mintMachine;
    uint8 _gammaDecimals;
    uint96 constant _denominator = 10000;
    address _platformAddress;
    uint96 _platformFeeRate = 250;
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;

    // ----- CONSTRUCTOR ----- //
    constructor(address token, address mintMachine) {
        _gammaToken = IERC20(token);
        _platformAddress = _msgSender();
        _gammaDecimals = IERC20Metadata(token).decimals();
        _mintMachine = IMintMachine(mintMachine);
    }

    // ----- VIEW FUNCTIONS ----- //
    function gammaLockOf(address collection, uint256 tokenId) external view override returns (uint256) {
        return _gammaLocks[collection][tokenId];
    }

    function royaltyOf(address collection, uint256 salePrice) external view override returns (address, uint256) {
        address owner = _royalties[collection].owner;
        uint256 royalty = salePrice * _royalties[collection].rate / _denominator;

        return (owner, royalty);
    }

    function kothOf(address collection, uint256 tokenId, uint256 salePrice) external view override returns (address, uint256) {
        address owner = _koths[collection][tokenId].owner;
        uint256 koth = salePrice * _kothRates[collection] / _denominator;
        if(owner == address(0))
            owner = _royalties[collection].owner;

        return (owner, koth);
    }

    function platformAddress() external view override returns (address) {
        return _platformAddress;
    }

    function platformFeeRate() external view override returns (uint96) {
        return _platformFeeRate;
    }

    // ----- MUTATION FUNCTIONS ----- //
    function lockGamma(address collection, uint256 tokenId, uint256 amount) external {
        require(amount > 0, "Service: amount is zero");
        require(_gammaToken.transferFrom(_msgSender(), address(this), amount), "Service: failed to transfer tokens for lock");

        _gammaLocks[collection][tokenId] += amount;
        emit Lock(collection, tokenId, amount, _msgSender());
    }

    function unlockGamma(address collection, uint256 tokenId) external {
        require(_gammaToken.transfer(_msgSender(), _gammaLocks[collection][tokenId]), "Service: failed to transfer tokens for unlock");
        require(IERC721(collection).ownerOf(tokenId) == _msgSender(), "Service: caller is not the token owner");

        IERC721(collection).safeTransferFrom(_msgSender(), DEAD, tokenId);
        _gammaLocks[collection][tokenId] = 0;
        emit Unlock(collection, tokenId, _msgSender());
    }

    function setRoyalty(address collection, address royaltyOwner, uint96 feeNumerator) external {
        require(_mintMachine.ownerOf(collection) == _msgSender(), "Service: caller is not the collection owner");
        require(feeNumerator + _kothRates[collection] <= 1000, "Service: royalty and koth is above max");

        RoyaltyInfo memory royalty;
        royalty.owner = royaltyOwner;
        royalty.rate = feeNumerator;

        _royalties[collection] = royalty;
    }

    function enableKotH(address collection, uint96 feeNumerator) external {
        require(!_isKotH[collection], "Service: KotH is already enabled");
        require(_mintMachine.ownerOf(collection) == _msgSender(), "Service: caller is not the collection owner");
        require(feeNumerator + _royalties[collection].rate >= 100 && feeNumerator + _royalties[collection].rate <= 1000, "Service: invalid fee value");

        _isKotH[collection] = true;
        _kothRates[collection] = feeNumerator;
    }

    function setKotH(address collection, uint96 feeNumerator) external {
        require(_isKotH[collection], "Service: KotH is disabled");
        require(_mintMachine.ownerOf(collection) == _msgSender(), "Service: caller is not the collection owner");
        require(feeNumerator + _royalties[collection].rate >= 100 && feeNumerator + _royalties[collection].rate <= 1000, "Service: invalid fee value");

        _kothRates[collection] = feeNumerator;
    }

    function takeKotH(address collection, uint256 tokenId, uint256 price) external {
        require(_isKotH[collection], "Service: KotH is disabled");
        require(price >= _koths[collection][tokenId].price * 110 / 100 && price >= _gammaDecimals, "Service: price is below the min requirement");

        KotHInfo memory koth = _koths[collection][tokenId];
        address collectionOwner = _mintMachine.ownerOf(collection);
        address oldOwner = koth.owner;
        uint256 oldPrice = koth.price;
        uint256 payment = oldPrice * 105 / 100;
        uint256 fee = (price - payment) / 2;

        if(oldOwner != address(0))
            require(_gammaToken.transferFrom(_msgSender(), oldOwner, payment), "Service: failed to transfer tokens for KotH");
        require(_gammaToken.transferFrom(_msgSender(), _platformAddress, fee), "Service: failed to transfer tokens for service fee");
        require(_gammaToken.transferFrom(_msgSender(), collectionOwner, fee), "Service: failed to transfer tokens for owner fee");

        koth.owner = _msgSender();
        koth.price = price;
        _koths[collection][tokenId] = koth;
    }
}

interface IMintMachine {
    /**
     * @dev Returns the address of the current owner.
     */
    function ownerOf(address collection) external view returns (address);
}