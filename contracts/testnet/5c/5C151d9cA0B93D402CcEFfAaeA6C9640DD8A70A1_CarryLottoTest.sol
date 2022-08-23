// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import "./interfaces/ICarryOver.sol";
import "./interfaces/INormalLotto.sol";
import "./libraries/SeriLib.sol";

contract CarryLottoTest is ICarryOver, Ownable, ReentrancyGuard {
    using SeriLib for uint256;
    using SafeERC20 for IERC20;

    string private constant _SERI_NOT_WINNER = "NOT_WINNER";
    string private constant _INVALID_SIGNATURE = "INVALID_SIG";
    string private constant _INVALID_PERCENT = "INVALID_PERCENT";
    string private constant _INVALID_TIMESTAMP = "INVALID_TIMESTAMP";

    Config private _config;
    address[] private _shareAddresses;
    uint256[] private _sharePercents;

    mapping(uint256 => uint256[]) private _winners;
    mapping(uint256 => uint256[]) private _prizeTaked;
    mapping(uint256 => uint256[]) private _assetIndices;
    mapping(uint256 => address[]) private _initialAssets;
    mapping(uint256 => uint256[]) private _initialPrizes;
    mapping(uint256 => uint256[]) private _takenPrizes;

    mapping(uint256 => Seri) private _series;
    // seriId => userAddr => Ticket
    mapping(uint256 => mapping(address => string[])) private _userTickets;
    // seriId => assetIdx => AssetBalance
    mapping(uint256 => mapping(uint256 => AssetBalance)) private _balances;
    // seriId => user => ticketId => tokenId
    mapping(uint256 => mapping(address => mapping(uint256 => uint256))) public userTicketsWon;
    // seriId => user => tokenId => ticketId
    mapping(uint256 => mapping(address => mapping(uint256 => uint256))) public userTicketsWonb;

    constructor() {
        Config memory cfg;
        cfg.postAddr = 0x64470E5F5DD38e497194BbcAF8Daa7CA578926F6;
        cfg.verifier = 0xaF94Cfc93cf22a5d92c828A659299777540b9505;
        cfg.nft = INFT(0x3E5b39625eE9934Db40Bb601f95EEf841687BF21);
        cfg.normalLotto = INormalLotto(0x90e2c4b2b107277FaDAebf651450b567be2bA7F7);
        cfg.expiredPeriod = 1 days;

        _config = cfg;
    }

    function openSeri(
        uint256 seri_,
        uint256 price_,
        uint256 postPrice_,
        uint256 max2sale_,
        address[] calldata initialAssets_,
        uint256[] calldata initialPrizes_
    ) external payable override onlyOwner {
        require(price_ >= postPrice_, "INVALID_PARAMS");

        Seri memory seri = _series[seri_];
        require(seri.embededInfo == 0, "EXISTED");

        Config memory cfg = _config;
        uint256 currentCOSeri = cfg.currentCOSeriId;
        require(currentCOSeri == 0 || _series[currentCOSeri].status != 0, "CO_OPENING");

        _config.currentCOSeriId = uint96(seri_);
        seri.seriType = true;
        seri.embededInfo = SeriLib.encode(price_, max2sale_, postPrice_, cfg.expiredPeriod);

        _series[seri_] = seri;
        __transferCarryOverAssetTo(seri_, initialAssets_, initialPrizes_);
        emit OpenSeri(seri_, seri.seriType ? 2 : 1);
    }

    function buy(
        uint256 seri_,
        string calldata numberInfo_,
        uint256 assetIdx_,
        uint256 totalTicket_
    ) external payable override {
        INormalLotto _normalLotto = _config.normalLotto;
        string[] memory priceFeeds = _normalLotto.getPriceFeeds();
        address asset = IAssets(address(_normalLotto)).getAsset(priceFeeds[assetIdx_]).asset;

        uint256 assetAmt;
        uint256 postAmt;
        {
            Seri memory seri = _series[seri_];
            uint256 embededInfo = seri.embededInfo;
            unchecked {
                require(seri.soldTicket + totalTicket_ <= embededInfo.max2Sale(), "EXCEED_MAX_TO_SALE");
            }
            uint256 assetPerTicket = ticket2Asset(seri_, priceFeeds[assetIdx_]);
            assetAmt = assetPerTicket * totalTicket_;
            postAmt = (assetAmt * embededInfo.postPrice()) / embededInfo.price();
            _series[seri_].soldTicket += uint32(totalTicket_);
        }

        uint256 assetRemain = _buyTransfer(asset, assetAmt, postAmt);
        _userTickets[seri_][_msgSender()].push(numberInfo_);
        if (_balances[seri_][assetIdx_].remain == 0) _assetIndices[seri_].push(assetIdx_);
        _balances[seri_][assetIdx_].remain += assetRemain;
        uint256 rate = _normalLotto.asset2USD(priceFeeds[assetIdx_]);
        emit BuyTicket(rate, assetAmt);
    }

    function _permit(
        uint256 timestamp_,
        string memory result_,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) private view returns (bool) {
        return
            ECDSA.recover(
                keccak256(
                    abi.encodePacked(
                        "\x19Ethereum Signed Message:\n32",
                        keccak256(abi.encodePacked(timestamp_, result_))
                    )
                ),
                v,
                r,
                s
            ) == _config.verifier;
    }

    function openResult(
        uint256 seri_,
        bool isWin_,
        uint256 _totalWin,
        uint256 timestamp_,
        string calldata result_,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override onlyOwner {
        Seri memory seri = _series[seri_];
        require(seri.status == 1, "NOT_CLOSE");
        require(timestamp_ > _config.currentSignTime, _INVALID_TIMESTAMP);
        require(_permit(timestamp_, result_, v, r, s), _INVALID_SIGNATURE);

        if (isWin_) {
            seri.status = 2;
            seri.totalWin = uint32(_totalWin);
        } else {
            seri.status = 3;
            __transferRemainAsset(seri_, _assetIndices[seri_]);
            __transferCarryOverRemainAsset(seri_);
        }
        seri.endTime = block.timestamp;
        seri.result = result_;

        _series[seri_] = seri;
        _config.currentSignTime = uint96(timestamp_);

        emit OpenResult(seri_, isWin_);
    }

    function closeSeri(uint256 seri_) external override onlyOwner {
        Seri memory seri = _series[seri_];
        require(seri.status == 0, "NOT_OPEN");
        require(seri.soldTicket == seri.embededInfo.max2Sale(), "NOT_SOLD_OUT");
        _series[seri_].status = 1;
        emit CloseSeri(seri_, block.timestamp);
    }

    function setWinners(
        uint256 seri_,
        uint256 startTime_,
        address[] memory winners_,
        uint256[][] memory buyTickets_,
        uint256 totalTicket_,
        string[] memory assets_,
        uint256 turn_,
        uint256 timestamp_,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override onlyOwner {
        {
            Seri memory seri = _series[seri_];
            require(seri.nonce != turn_, "ALREADY_PAID");
            require(seri.status == 2, _SERI_NOT_WINNER);
            unchecked {
                require(seri.totalWin >= _winners[seri_].length + totalTicket_, "INVALID_WINNERS");
            }
        }

        {
            Config memory cfg = _config;
            require(timestamp_ > cfg.currentSignTime, _INVALID_TIMESTAMP);

            require(
                ECDSA.recover(
                    keccak256(
                        abi.encodePacked(
                            "\x19Ethereum Signed Message:\n32",
                            getbytesDataSetWinners(
                                timestamp_,
                                seri_,
                                winners_,
                                buyTickets_,
                                totalTicket_,
                                assets_,
                                turn_
                            )
                        )
                    ),
                    v,
                    r,
                    s
                ) == cfg.verifier,
                _INVALID_SIGNATURE
            );
            _sendNFT(cfg.nft, seri_, startTime_, winners_, assets_, buyTickets_);
        }

        _config.currentSignTime = uint96(timestamp_);
        _series[seri_].nonce = uint40(turn_);

        emit SetWinners(seri_, turn_);
    }

    function takePrize(uint256 nftId_) external override nonReentrant {
        address sender = _msgSender();
        Seri memory seri;
        uint256 _seri;
        uint256 _winTickets;
        uint256 _buyTickets;
        {
            INFT _nft = _config.nft;
            (_seri, , , , , _winTickets, , _buyTickets, ) = _nft.metadatas(nftId_);

            seri = _series[_seri];
            require(seri.status == 2, _SERI_NOT_WINNER);
            unchecked {
                require(seri.endTime + seri.embededInfo.expiredPeriod() > block.timestamp, "EXPIRED");
            }
            _nft.transferFrom(sender, address(this), nftId_);
            _nft.burn(nftId_);
            _prizeTaked[_seri].push(nftId_);
            __takePrize(_seri, _winTickets, _buyTickets);
        }
    }

    function takePrizeExpired(uint256 seri_) external override onlyOwner {
        Seri memory seri = _series[seri_];

        require(!seri.takeAssetExpired, "TAKED");
        unchecked {
            require(block.timestamp > seri.endTime + seri.embededInfo.expiredPeriod(), "NOT_EXPIRED");
        }

        _series[seri_].takeAssetExpired = true;

        Config memory cfg = _config;
        __transferRemainAsset(seri_, _assetIndices[seri_]);
        uint256 length = _initialAssets[seri_].length;

        for (uint256 i; i < length; ) {
            __transfer(
                _initialAssets[seri_][i],
                cfg.normalLotto.carryOver(),
                _initialPrizes[seri_][i] - _takenPrizes[seri_][i]
            );
            unchecked {
                ++i;
            }
        }
    }

    function configSigner(address _signer) external override {
        require(_msgSender() == _config.verifier, "UNAUTHORIZED");
        _config.verifier = _signer;
    }

    function configAddress(
        address post_,
        address nft_,
        address normalLotto_
    ) external override onlyOwner {
        Config memory cfg = _config;
        cfg.postAddr = post_;
        cfg.nft = INFT(nft_);
        cfg.normalLotto = INormalLotto(normalLotto_);

        _config = cfg;
    }

    function configAffiliate(address[] calldata shareAddresses_, uint256[] calldata sharePercents_) external onlyOwner {
        uint256 length = shareAddresses_.length;
        require(length == sharePercents_.length, "LENGTH_MISMATCH");
        uint256 sumPercents;
        for (uint256 i; i < length; ) {
            sumPercents += sharePercents_[i];
            unchecked {
                ++i;
            }
        }
        require(sumPercents < 1e6, "INVALID_PARAMS");
        _shareAddresses = shareAddresses_;
        _sharePercents = sharePercents_;
    }

    function getAffilicateConfig() external view returns (address[] memory, uint256[] memory) {
        uint256 length = _shareAddresses.length;
        address[] memory addresses = new address[](length);
        uint256[] memory percents = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            addresses[i] = _shareAddresses[i];
            percents[i] = _sharePercents[i];
        }

        return (addresses, percents);
    }

    function seriAssetRemain(uint256 _seri, uint256 _asset) external view override returns (uint256) {
        return _balances[_seri][_asset].remain;
    }

    function getUserTickets(uint256 _seri, address _user) external view override returns (string[] memory) {
        return _userTickets[_seri][_user];
    }

    function getSeriWinners(uint256 _seri) external view override returns (uint256[] memory) {
        return _winners[_seri];
    }

    function getSeriesAssets(uint256 _seri) external view override returns (uint256[] memory) {
        return _assetIndices[_seri];
    }

    function getAsset(string memory _symbol) external view override returns (Asset memory _asset) {
        _asset = IAssets(address(_config.normalLotto)).getAsset(_symbol);
    }

    function currentSignTime() external view override returns (uint256) {
        return _config.currentSignTime;
    }

    function currentCarryOverSeri() external view override returns (uint256) {
        return _config.currentCOSeriId;
    }

    function signer() external view override returns (address) {
        return _config.verifier;
    }

    function postAddress() external view override returns (address payable) {
        return payable(_config.postAddr);
    }

    function normalLotto() external view returns (INormalLotto) {
        return _config.normalLotto;
    }

    function nft() external view override returns (INFT) {
        return _config.nft;
    }

    function expiredPeriod() external view override returns (uint256) {
        return _config.expiredPeriod;
    }

    function seriExpiredPeriod(uint256 seri_) external view override returns (uint256) {
        return _series[seri_].embededInfo.expiredPeriod();
    }

    function postPrices(uint256 seri_) external view override returns (uint256) {
        return _series[seri_].embededInfo.postPrice();
    }

    function currentTurn(uint256 seri_) external view override returns (uint256) {
        return _series[seri_].nonce;
    }

    function series(uint256 seri_)
        external
        view
        override
        returns (
            uint256 price,
            uint256 soldTicket,
            string memory result,
            uint256 status,
            uint256 endTime,
            bool takeAssetExpired,
            uint256 max2sale,
            uint256 totalWin,
            uint256 seriType,
            uint256 initPrizeTaken,
            uint256 winInitPrize
        )
    {
        Seri memory seri = _series[seri_];
        price = seri.embededInfo.price();
        soldTicket = seri.soldTicket;
        result = seri.result;
        status = seri.status;
        endTime = seri.endTime;
        takeAssetExpired = seri.takeAssetExpired;
        max2sale = seri.embededInfo.max2Sale();
        totalWin = seri.totalWin;
        seriType = seri.seriType ? 2 : 1;
        initPrizeTaken = seri.initPrizeTaken;
        winInitPrize = seri.winInitPrice;
    }

    function totalPrize(uint256 seri_) external view override returns (uint256 _prize) {
        uint256[] memory assetIndices = _assetIndices[seri_];
        uint256 length = assetIndices.length;
        uint256 assetIdx;
        string[] memory priceFeeds = _config.normalLotto.getPriceFeeds();
        AssetBalance memory assetBalance;
        for (uint256 i = 0; i < length; ) {
            assetIdx = assetIndices[i];
            assetBalance = _balances[seri_][assetIdx];
            if (assetBalance.remain > 0) {
                _prize += _config.normalLotto.asset2USD(priceFeeds[assetIdx], assetBalance.remain);
            }
            unchecked {
                ++i;
            }
        }
    }

    function getbytesDataSetWinners(
        uint256 timestamp_,
        uint256 seri_,
        address[] memory winners_,
        uint256[][] memory buyTickets_,
        uint256 totalTicket_,
        string[] memory assets_,
        uint256 turn_
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(timestamp_, abi.encode(seri_, winners_, buyTickets_, totalTicket_, assets_, turn_))
            );
    }

    function ticket2Asset(uint256 seri_, string memory symbol_) public view returns (uint256) {
        uint256 expectedRate = _config.normalLotto.asset2USD(symbol_);
        return (_series[seri_].embededInfo.price() * 1 ether) / expectedRate;
    }

    function _buyTransfer(
        address asset_,
        uint256 assetAmt_,
        uint256 postAmt_
    ) private returns (uint256 assetRemain) {
        address sender = _msgSender();
        uint256 length = _shareAddresses.length;
        Config memory cfg = _config;
        assetRemain = postAmt_;

        __transferFrom(asset_, sender, address(this), assetAmt_);
        __transfer(asset_, cfg.postAddr, assetAmt_ - postAmt_);
        for (uint256 i; i < length; ) {
            uint256 shareAmount = (postAmt_ * _sharePercents[i]) / 1e6;
            __transfer(asset_, _shareAddresses[i], shareAmount);
            assetRemain -= shareAmount;
            unchecked {
                ++i;
            }
        }
    }

    function _sendNFT(
        INFT nft_,
        uint256 seri_,
        uint256 startTime_,
        address[] memory winners_,
        string[] memory assets_,
        uint256[][] memory buyTickets_
    ) private {
        uint256 winnerLength = winners_.length;
        require(100 >= winnerLength, "MAX_LOOP");

        uint256 tokenID;
        uint256 totalWin = _series[seri_].totalWin;
        string memory result = _series[seri_].result;
        address winner;
        for (uint256 i; i < winnerLength; ) {
            winner = winners_[i];
            for (uint256 j; j < buyTickets_[i].length; ) {
                tokenID = __mintNFT(nft_, winner, seri_, startTime_, totalWin, result, assets_[i]);
                _winners[seri_].push(tokenID);

                userTicketsWon[seri_][winner][buyTickets_[i][j]] = tokenID;
                userTicketsWonb[seri_][winner][tokenID] = buyTickets_[i][j];
                unchecked {
                    ++j;
                }
            }
            unchecked {
                ++i;
            }
        }
    }

    function __mintNFT(
        INFT nft_,
        address to_,
        uint256 seri_,
        uint256 startTime_,
        uint256 winTickets_,
        string memory result_,
        string memory asset_
    ) private returns (uint256) {
        return nft_.mint(to_, seri_, startTime_, block.timestamp, result_, 2, winTickets_, to_, 1, asset_);
    }

    function __takePrize(
        uint256 seri_,
        uint256 winTickets_,
        uint256 buyTickets_
    ) private {
        address sender = _msgSender();
        {
            uint256 takeAmt;
            uint256 remain;
            uint256[] memory assetIndices = _assetIndices[seri_];
            uint256 length = assetIndices.length;
            uint256 assetIdx;
            INormalLotto _normalLotto = _config.normalLotto;
            AssetBalance memory assetBalance;
            string[] memory priceFeeds = _normalLotto.getPriceFeeds();
            for (uint256 i; i < length; ) {
                assetIdx = assetIndices[i];
                assetBalance = _balances[seri_][assetIdx];
                remain = assetBalance.remain;
                if (remain > 0) {
                    takeAmt = assetBalance.winAmt;

                    if (takeAmt == 0) {
                        takeAmt = (remain * buyTickets_) / winTickets_;
                        assetBalance.winAmt = takeAmt;
                    }
                    _balances[seri_][assetIdx].remain -= takeAmt;
                    address asset = IAssets(address(_normalLotto)).getAsset(priceFeeds[assetIdx]).asset;
                    __transfer(asset, sender, takeAmt);
                }
                unchecked {
                    ++i;
                }
            }
        }

        uint256 coLength = _initialAssets[seri_].length;
        for (uint256 j; j < coLength; ) {
            uint256 takeAssetInitialAmt = (_initialPrizes[seri_][j] * buyTickets_) / winTickets_;
            _takenPrizes[seri_][j] += takeAssetInitialAmt;
            __transfer(_initialAssets[seri_][j], sender, takeAssetInitialAmt);
            unchecked {
                ++j;
            }
        }
    }

    function __transferCarryOverAssetTo(
        uint256 seri_,
        address[] calldata initialAssets_,
        uint256[] calldata initialPrizes_
    ) private {
        uint256 length = initialAssets_.length;
        require(length == initialPrizes_.length, "LENGTH_MISMATCH");

        address sender = _msgSender();
        for (uint256 i; i < length; ) {
            __transferFrom(initialAssets_[i], sender, address(this), initialPrizes_[i]);
            unchecked {
                ++i;
            }
        }
        uint256[] memory takenPrizes_ = new uint256[](length);
        _initialAssets[seri_] = initialAssets_;
        _initialPrizes[seri_] = initialPrizes_;
        _takenPrizes[seri_] = takenPrizes_;
    }

    function __transferCarryOverRemainAsset(uint256 seri_) private {
        INormalLotto _normalLotto = _config.normalLotto;
        uint256 length = _initialAssets[seri_].length;
        for (uint256 i; i < length; ) {
            __transfer(_initialAssets[seri_][i], _normalLotto.carryOver(), _initialPrizes[seri_][i]);
            unchecked {
                ++i;
            }
        }
    }

    function __transferRemainAsset(uint256 seri_, uint256[] memory assetIndices_) private {
        uint256 length = assetIndices_.length;
        uint256 assetIdx;
        uint256 remain;
        address asset;
        INormalLotto _normalLotto = _config.normalLotto;
        string[] memory priceFeeds = _normalLotto.getPriceFeeds();

        for (uint256 i; i < length; ) {
            assetIdx = assetIndices_[i];
            asset = IAssets(address(_normalLotto)).getAsset(priceFeeds[assetIdx]).asset;
            remain = _balances[seri_][assetIdx].remain;
            delete _balances[seri_][assetIdx].remain;
            __transfer(asset, _normalLotto.carryOver(), remain);

            unchecked {
                ++i;
            }
        }
    }

    function __transferFrom(
        address asset_,
        address from_,
        address to_,
        uint256 amount_
    ) private {
        if (amount_ == 0) return;
        if (asset_ == address(0)) {
            require(msg.value >= amount_, "INSUFICIENT_BALANCE");
        } else IERC20(asset_).safeTransferFrom(from_, to_, amount_);
    }

    function __transfer(
        address asset_,
        address to_,
        uint256 amount_
    ) private {
        if (amount_ == 0) return;
        if (asset_ == address(0)) {
            (bool ok, ) = payable(to_).call{ value: amount_ }("");
            require(ok, "INSUFICIENT_BALANCE");
        } else IERC20(asset_).safeTransfer(to_, amount_);
    }
}

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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

    function safePermit(
        IERC20Permit token,
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
// OpenZeppelin Contracts (last updated v4.7.3) (utils/cryptography/ECDSA.sol)

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

pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./IAssets.sol";
import "./INFT.sol";
import "./INormalLotto.sol";

interface ICarryOver is IAssets {
    event OpenSeri(uint256 indexed seriId, uint256 indexed seriType);
    event CloseSeri(uint256 indexed seriId, uint256 endTime);
    event OpenResult(uint256 indexed seriId, bool won);
    event BuyTicket(uint256 cryptoRate, uint256 totalAmount);
    event SetWinners(uint256 seri, uint256 turn);

    // 4 slot
    struct Config {
        // slot #0
        INFT nft;
        uint96 expiredPeriod;
        // slot #1
        address postAddr;
        uint96 currentSignTime;
        // slot #2
        address verifier;
        uint96 currentCOSeriId;
        // slot #3
        INormalLotto normalLotto;
    }

    struct AssetBalance {
        uint256 remain;
        uint256 winAmt;
    }

    struct Seri {
        // slot #0
        uint8 status;
        bool seriType;
        bool takeAssetExpired;
        uint32 soldTicket;
        uint32 totalWin;
        uint40 nonce;
        uint64 winInitPrice;
        uint64 initPrizeTaken;
        // slot #1
        uint256 endTime;
        // slot #2
        uint256 embededInfo;
        // slot #3
        string result;
    }

    function openSeri(
        uint256 seri_,
        uint256 price_,
        uint256 postPrice_,
        uint256 max2sale_,
        address[] calldata initialAssets_,
        uint256[] calldata initialPrizes_
    ) external payable;

    function buy(
        uint256 seri_,
        string calldata numberInfo_,
        uint256 assetIdx_,
        uint256 totalTicket_
    ) external payable;

    function openResult(
        uint256 seri_,
        bool isWin_,
        uint256 _totalWin,
        uint256 timestamp_,
        string calldata result_,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function closeSeri(uint256 seri_) external;

    function setWinners(
        uint256 seri_,
        uint256 startTime_,
        address[] memory winners_,
        uint256[][] memory buyTickets_,
        uint256 totalTicket_,
        string[] memory assets_,
        uint256 turn_,
        uint256 timestamp_,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function takePrize(uint256 nftId_) external;

    function takePrizeExpired(uint256 seri_) external;

    function configSigner(address _signer) external;

    function configAddress(
        address post_,
        address nft_,
        address normalLotto_
    ) external;

    function configAffiliate(address[] calldata shareAddress_, uint256[] calldata sharePercents_) external;

    // VIEW
    function getAffilicateConfig() external view returns (address[] memory, uint256[] memory);

    function seriAssetRemain(uint256 _seri, uint256 _asset) external view returns (uint256);

    function getUserTickets(uint256 _seri, address _user) external view returns (string[] memory);

    function getSeriWinners(uint256 _seri) external view returns (uint256[] memory);

    function getSeriesAssets(uint256 _seri) external view returns (uint256[] memory);

    function getAsset(string memory _symbol) external view returns (Asset memory _asset);

    function currentSignTime() external view returns (uint256);

    function currentCarryOverSeri() external view returns (uint256);

    function signer() external view returns (address);

    function postAddress() external view returns (address payable);

    function normalLotto() external view returns (INormalLotto);

    function nft() external view returns (INFT);

    function expiredPeriod() external view returns (uint256);

    function seriExpiredPeriod(uint256 seri_) external view returns (uint256);

    function postPrices(uint256 seri_) external view returns (uint256);

    function currentTurn(uint256 seri_) external view returns (uint256);

    function series(uint256 seri_)
        external
        view
        returns (
            uint256 price,
            uint256 soldTicket,
            string memory result,
            uint256 status,
            uint256 endTime,
            bool takeAssetExpired,
            uint256 max2sale,
            uint256 totalWin,
            uint256 seriType,
            uint256 initPrizeTaken,
            uint256 winInitPrize
        );

    function totalPrize(uint256 seri_) external view returns (uint256 _prize);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

interface INormalLotto {
    function getPriceFeeds() external view returns (string[] memory);

    function asset2USD(string calldata symbol) external view returns (uint256);

    function asset2USD(string calldata symbol, uint256 amount) external view returns (uint256);

    function expiredPeriod() external view returns (uint256);

    function carryOver() external view returns (address payable);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

library SeriLib {
    // EMBEDED_INFO = EXPIRED_PERIOD + POST_PRIZE + MAX_2_SALE + PRICE
    uint256 private constant _N_BIT = 64;
    uint256 private constant _MAX = 18446744073709551615;

    uint256 private constant _POST_PRICE_SHIFT = 128;
    uint256 private constant _EXPIRED_PERIOD_SHIFT = 192;

    // (1 << _POST_PRICE_SHIFT) - 1
    uint256 private constant _MAX_2_SALE_MASK = 340282366920938463463374607431768211455;
    // (1 << _EXPIRED_PERIOD_SHIFT) - 1
    uint256 private constant _POST_PRICE_MASK = 6277101735386680763835789423207666416102355444464034512895;

    function encode(
        uint256 price_,
        uint256 max2Sale_,
        uint256 postPrice_,
        uint256 expiredPeriod_
    ) internal pure returns (uint256) {
        require(_MAX >= price_ && _MAX >= max2Sale_ && _MAX >= postPrice_ && _MAX >= expiredPeriod_, "OVERFLOW");
        unchecked {
            return
                price_ |
                (max2Sale_ << _N_BIT) |
                (postPrice_ << _POST_PRICE_SHIFT) |
                (expiredPeriod_ << _EXPIRED_PERIOD_SHIFT);
        }
    }

    function price(uint256 embededInfo_) internal pure returns (uint256) {
        return embededInfo_ & _MAX;
    }

    function postPrice(uint256 embededInfo_) internal pure returns (uint256) {
        unchecked {
            return ((embededInfo_ & _POST_PRICE_MASK) >> _POST_PRICE_SHIFT) & _MAX;
        }
    }

    function max2Sale(uint256 embededInfo_) internal pure returns (uint256) {
        unchecked {
            return ((embededInfo_ & _MAX_2_SALE_MASK) >> _N_BIT) & _MAX;
        }
    }

    function expiredPeriod(uint256 embededInfo_) internal pure returns (uint256) {
        unchecked {
            return embededInfo_ >> _EXPIRED_PERIOD_SHIFT;
        }
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
interface IERC20Permit {
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
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

pragma solidity 0.8.16;

interface IAssets {
    struct Asset {
        string symbol;
        address asset;
        address priceFeed;
    }

    function getAsset(string calldata symbol) external view returns (Asset memory);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

interface INFT {
    function mint(
        address to,
        uint256 seri,
        uint256 startTime,
        uint256 endTime,
        string calldata result,
        uint256 status,
        uint256 winTickets,
        address buyer,
        uint256 buyTickets,
        string calldata asset
    ) external returns (uint256);

    function metadatas(uint256 _tokenId)
        external
        view
        returns (
            uint256 seri,
            uint256 startTime,
            uint256 endTime,
            string memory result,
            uint256 status,
            uint256 winTickets,
            address buyer,
            uint256 buyTickets,
            string memory asset
        );

    function burn(uint256 tokenId) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}