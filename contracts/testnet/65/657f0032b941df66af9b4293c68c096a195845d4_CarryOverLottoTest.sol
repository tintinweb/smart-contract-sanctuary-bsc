/**
 *Submitted for verification at BscScan.com on 2022-08-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-17
 */

// SPDX-License-Identifier: MIT

pragma solidity =0.5.16;
pragma experimental ABIEncoderV2;

contract Context {
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

interface NFT {
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

interface INormalLotto {
    function getPriceFeeds() external view returns (string[] memory);

    function asset2USD(string calldata symbol) external view returns (uint256);

    function asset2USD(string calldata symbol, uint256 amount) external view returns (uint256);

    function expiredPeriod() external view returns (uint256);
}

interface IAsset {
    struct asset {
        string symbol;
        address asset;
        address priceFeed;
    }

    function getAsset(string calldata symbol) external view returns (asset memory);
}

contract CarryOverLottoTest is Ownable, IAsset {
    event OpenSeri(uint256 seri, uint256 seriType);
    event CloseSeri(uint256 seri, uint256 endTime);
    event OpenResult(uint256 seri, bool isWin);
    event BuyTicket(uint256 cryptoRate, uint256 totalAmount);
    event SetWinners(uint256 seri, uint256 turn);
    using SafeMath for uint256;

    uint256 public constant MAX_PERCENT = 1_000_000;
    address public normalLotto = 0x90e2c4b2b107277FaDAebf651450b567be2bA7F7;
    uint256 public currentSignTime;
    uint256 public currentCarryOverSeri;
    address public signer = 0x7a7f38737BFCD8a1301Dd262a226780350980eA3;
    address payable public postAddress = 0x64470E5F5DD38e497194BbcAF8Daa7CA578926F6;
    address payable public carryOver;
    NFT public nft = NFT(0xc09FE6286B39dbfaa1D21B4cb6563Aac3eFb5cB0);
    uint256[] public sharePercents;
    address payable[] public shareAddress;

    struct seri {
        uint256 price;
        uint256 soldTicket;
        uint256[] assetIndex;
        string result;
        uint256 status; // status - index 0 open; 1 close; 2 win; 3 lose
        uint256[] winners; // NFT token Id
        uint256 endTime;
        uint256[] prizetaked;
        bool takeAssetExpired;
        uint256 max2sale;
        uint256 totalWin;
        uint256 seriType; // 1 normal; 2 carryOver;
        address[] initAssets;
        uint256[] initPrizes;
        uint256[] initPrizeTaken;
        mapping(address => string[]) userTickets;
        // mapping(uint => mapping(address => ticket)) userTickets; // seri => timestamp => user => ticket
        mapping(uint256 => uint256) seriAssetRemain; // seri => asset index => remain
        mapping(uint256 => uint256) winAmount;
    }

    mapping(uint256 => seri) public series;
    mapping(uint256 => uint256) public seriExpiredPeriod;
    mapping(uint256 => uint256) public postPrices;
    mapping(uint256 => uint256) public currentTurn;
    mapping(uint256 => mapping(address => mapping(uint256 => uint256))) public userTicketsWon; // seri => user => ticket id => token id
    mapping(uint256 => mapping(address => mapping(uint256 => uint256))) public userTicketsWonb; // seri => user => token id => ticket id

    modifier onlySigner() {
        require(signer == _msgSender(), "Signer: caller is not the signer");
        _;
    }

    constructor() public {}

    function getMessageHash(uint256 timestamp, string memory result) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(timestamp, result));
    }

    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    function permit(
        uint256 timestamp,
        string memory result,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public view returns (bool) {
        return ecrecover(getEthSignedMessageHash(getMessageHash(timestamp, result)), v, r, s) == signer;
    }

    function getbytesDataSetWinners(
        uint256 timestamp,
        uint256 _seri,
        address[] memory _winners,
        uint256[][] memory _buyTickets,
        uint256 _totalTicket,
        string[] memory _assets,
        uint256 _turn
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(timestamp, abi.encode(_seri, _winners, _buyTickets, _totalTicket, _assets, _turn))
            );
    }

    function permitSetWinners(
        uint256 timestamp,
        uint256 _seri,
        address[] memory _winners,
        uint256[][] memory _buyTickets,
        uint256 _totalTicket,
        string[] memory _assets,
        uint256 _turn,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public view returns (bool) {
        bytes32 _messageHash = getbytesDataSetWinners(
            timestamp,
            _seri,
            _winners,
            _buyTickets,
            _totalTicket,
            _assets,
            _turn
        );
        return ecrecover(getEthSignedMessageHash(_messageHash), v, r, s) == signer;
    }

    function getSeriesAssets(uint256 _seri) public view returns (uint256[] memory) {
        return series[_seri].assetIndex;
    }

    function metadatas(uint256 _tokenId)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            string memory,
            uint256,
            uint256,
            address,
            uint256,
            string memory
        )
    {
        return nft.metadatas(_tokenId);
    }

    function getSeriWinners(uint256 _seri) public view returns (uint256[] memory) {
        return series[_seri].winners;
    }

    function getUserTickets(uint256 _seri, address _user) public view returns (string[] memory) {
        return series[_seri].userTickets[_user];
    }

    function seriAssetRemain(uint256 _seri, uint256 _asset) public view returns (uint256) {
        return series[_seri].seriAssetRemain[_asset];
    }

    function getAsset(string memory _symbol) public view returns (asset memory _asset) {
        _asset = IAsset(normalLotto).getAsset(_symbol);
    }

    function ticket2Asset(uint256 _seri, string memory _symbol) public view returns (uint256 _amountUsd) {
        uint256 expectedRate = INormalLotto(normalLotto).asset2USD(_symbol);
        return series[_seri].price.mul(1 ether).div(expectedRate);
    }

    function openSeri(
        uint256 _seri,
        uint256 _price,
        uint256 _postPrice,
        uint256 _max2sale,
        address[] calldata _initAssets,
        uint256[] calldata _initPrizes
    ) external payable onlyOwner {
        require(series[_seri].price == 0, "Seri existed");
        require(_postPrice <= _price, "Invalid post price");
        require(currentCarryOverSeri == 0 || series[currentCarryOverSeri].status != 0, "Carry-over seri opening");
        uint256 length = _initAssets.length;
        for (uint256 i = 0; i < length; i++) {
            if (_initAssets[i] == address(0)) {
                require(msg.value >= _initPrizes[i], "Insufficient-balance");
            } else {
                require(
                    IBEP20(_initAssets[i]).transferFrom(msg.sender, address(this), _initPrizes[i]),
                    "Insufficient-allowance"
                );
            }
        }
        series[_seri].seriType = 2;
        series[_seri].initAssets = _initAssets;
        series[_seri].initPrizes = _initPrizes;
        series[_seri].price = _price;
        series[_seri].max2sale = _max2sale;
        seriExpiredPeriod[_seri] = INormalLotto(normalLotto).expiredPeriod();
        postPrices[_seri] = _postPrice;
        currentCarryOverSeri = _seri;
        emit OpenSeri(_seri, series[_seri].seriType);
    }

    function takeAsset2CarryOver(uint256 _seri) internal {
        for (uint256 i = 0; i < series[_seri].assetIndex.length; i++) {
            if (series[_seri].seriAssetRemain[series[_seri].assetIndex[i]] > 0) {
                uint256 takeAmount = series[_seri].seriAssetRemain[series[_seri].assetIndex[i]];
                series[_seri].seriAssetRemain[series[_seri].assetIndex[i]] = 0;
                if (series[_seri].assetIndex[i] == 0) carryOver.transfer(takeAmount);
                else {
                    string[] memory priceFeeds = INormalLotto(normalLotto).getPriceFeeds();
                    string memory _symbol = priceFeeds[series[_seri].assetIndex[i]];
                    address _asset = getAsset(_symbol).asset;
                    require(IBEP20(_asset).transfer(carryOver, takeAmount), "Insufficient-balance");
                }
            }
        }

        for (uint256 j = 0; j < series[_seri].initAssets.length; j++) {
            if (series[_seri].initAssets[j] == address(0)) {
                carryOver.transfer(series[_seri].initPrizes[j]);
            } else {
                require(
                    IBEP20(series[_seri].initAssets[j]).transfer(carryOver, series[_seri].initPrizes[j]),
                    "Insufficient-balance"
                );
            }
        }
    }

    function closeSeri(uint256 _seri) public onlyOwner {
        require(series[_seri].status == 0, "Seri not open");
        require(series[_seri].soldTicket == series[_seri].max2sale, "Tickets are not sold out yet");
        series[_seri].status = 1;
        emit CloseSeri(_seri, now);
    }

    function openResult(
        uint256 _seri,
        bool _isWin,
        uint256 _totalWin,
        uint256 timestamp,
        string memory _result,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public onlyOwner {
        require(series[_seri].status == 1, "Seri not close");
        require(currentSignTime < timestamp, "Invalid timestamp");
        require(permit(timestamp, _result, v, r, s), "Invalid signature");
        series[_seri].result = _result;
        if (_isWin) {
            series[_seri].status = 2;
            series[_seri].totalWin = _totalWin;
        } else {
            series[_seri].status = 3;
            takeAsset2CarryOver(_seri);
        }
        series[_seri].endTime = now;
        currentSignTime = timestamp;
        emit OpenResult(_seri, _isWin);
    }

    function sendNFT(
        uint256 _seri,
        uint256 startTime,
        address[] memory _winners,
        uint256[][] memory _buyTickets,
        string[] memory _assets
    ) internal {
        seri storage sr = series[_seri];
        require(sr.status == 2, "Seri not winner");
        for (uint256 i = 0; i < _winners.length; i++) {
            for (uint256 j = 0; j < _buyTickets[i].length; j++) {
                uint256 tokenID = nft.mint(
                    _winners[i],
                    _seri,
                    startTime,
                    now,
                    sr.result,
                    2,
                    sr.totalWin,
                    _winners[i],
                    1,
                    _assets[i]
                );
                series[_seri].winners.push(tokenID);
                userTicketsWon[_seri][_winners[i]][_buyTickets[i][j]] = tokenID;
                userTicketsWonb[_seri][_winners[i]][tokenID] = _buyTickets[i][j];
            }
        }
    }

    function setWinners(
        uint256 _seri,
        uint256 startTime,
        address[] memory _winners,
        uint256[][] memory _buyTickets,
        uint256 _totalTicket,
        string[] memory _assets,
        uint256 _turn,
        uint256 timestamp,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public onlyOwner {
        require(_winners.length <= 100, "Over max loop");
        require(currentSignTime < timestamp, "Invalid timestamp");
        require(currentTurn[_seri] != _turn, "Already paid!");
        require(
            permitSetWinners(timestamp, _seri, _winners, _buyTickets, _totalTicket, _assets, _turn, v, r, s),
            "Invalid signal"
        );
        require(series[_seri].winners.length.add(_totalTicket) <= series[_seri].totalWin, "Invalid winners");
        currentSignTime = timestamp;
        currentTurn[_seri] = _turn;
        sendNFT(_seri, startTime, _winners, _buyTickets, _assets);
        emit SetWinners(_seri, _turn);
    }

    function takeAsset(
        uint256 _seri,
        uint256 _winTickets,
        uint256 _buyTickets
    ) internal {
        for (uint256 i = 0; i < series[_seri].assetIndex.length; i++) {
            if (series[_seri].seriAssetRemain[series[_seri].assetIndex[i]] > 0) {
                uint256 takeAmount = series[_seri].winAmount[series[_seri].assetIndex[i]];
                if (takeAmount == 0) {
                    takeAmount = series[_seri].seriAssetRemain[series[_seri].assetIndex[i]].mul(_buyTickets).div(
                        _winTickets
                    );
                    series[_seri].winAmount[series[_seri].assetIndex[i]] = takeAmount;
                }
                series[_seri].seriAssetRemain[series[_seri].assetIndex[i]] = series[_seri]
                    .seriAssetRemain[series[_seri].assetIndex[i]]
                    .sub(takeAmount);
                if (series[_seri].assetIndex[i] == 0) {
                    msg.sender.transfer(takeAmount);
                } else {
                    string[] memory priceFeeds = INormalLotto(normalLotto).getPriceFeeds();
                    string memory _symbol = priceFeeds[series[_seri].assetIndex[i]];
                    address _asset = getAsset(_symbol).asset;
                    require(IBEP20(_asset).transfer(msg.sender, takeAmount), "insufficient-allowance");
                }
            }
        }
        for (uint256 j = 0; j < series[_seri].initAssets.length; j++) {
            uint256 takeAssetInitAmount = series[_seri].initPrizes[j].mul(_buyTickets).div(_winTickets);
            series[_seri].initPrizeTaken[j] = series[_seri].initPrizeTaken[j].add(takeAssetInitAmount);
            if (series[_seri].initAssets[j] == address(0)) {
                msg.sender.transfer(takeAssetInitAmount);
            } else {
                IBEP20(series[_seri].initAssets[j]).transfer(msg.sender, takeAssetInitAmount);
            }
        }
    }

    function takePrize(uint256 _nftId) external {
        uint256 _seri;
        uint256 _winTickets;
        uint256 _buyTickets;
        address buyer;
        (_seri, , , , , _winTickets, buyer, _buyTickets, ) = nft.metadatas(_nftId);
        require(series[_seri].status == 2, "seri not winner");
        require(series[_seri].endTime.add(seriExpiredPeriod[_seri]) > now, "Ticket Expired");
        nft.transferFrom(_msgSender(), address(this), _nftId);
        nft.burn(_nftId);
        series[_seri].prizetaked.push(_nftId);
        takeAsset(_seri, _winTickets, _buyTickets);
    }

    function totalPrize(uint256 _seri) public view returns (uint256 _prize) {
        for (uint256 i = 0; i < series[_seri].assetIndex.length; i++) {
            if (series[_seri].seriAssetRemain[series[_seri].assetIndex[i]] > 0) {
                string[] memory priceFeeds = INormalLotto(normalLotto).getPriceFeeds();
                string memory symbol = priceFeeds[series[_seri].assetIndex[i]];
                _prize += INormalLotto(normalLotto).asset2USD(
                    symbol,
                    series[_seri].seriAssetRemain[series[_seri].assetIndex[i]]
                );
            }
        }
    }

    function _takePrizeExpired(uint256 _seri) internal {
        for (uint256 i = 0; i < series[_seri].assetIndex.length; i++) {
            if (series[_seri].seriAssetRemain[series[_seri].assetIndex[i]] > 0) {
                uint256 takeAmount = series[_seri].seriAssetRemain[series[_seri].assetIndex[i]];
                series[_seri].seriAssetRemain[series[_seri].assetIndex[i]] = 0;
                if (series[_seri].assetIndex[i] == 0) carryOver.transfer(takeAmount);
                else {
                    string[] memory priceFeeds = INormalLotto(normalLotto).getPriceFeeds();
                    string memory _symbol = priceFeeds[series[_seri].assetIndex[i]];
                    address _asset = getAsset(_symbol).asset;
                    require(IBEP20(_asset).transfer(carryOver, takeAmount), "insufficient-allowance");
                }
            }
        }

        for (uint256 j = 0; j < series[_seri].initAssets.length; j++) {
            uint256 takeAssetInitRemain = series[_seri].initPrizes[j].sub(series[_seri].initPrizeTaken[j]);
            series[_seri].initPrizeTaken[j] = series[_seri].initPrizes[j];
            if (series[_seri].initAssets[j] == address(0)) {
                carryOver.transfer(takeAssetInitRemain);
            } else {
                require(
                    IBEP20(series[_seri].initAssets[j]).transfer(carryOver, takeAssetInitRemain),
                    "Insufficient-balance"
                );
            }
        }
    }

    function takePrizeExpired(uint256 _seri) external onlyOwner {
        require(!series[_seri].takeAssetExpired, "Taked");
        require(series[_seri].endTime.add(seriExpiredPeriod[_seri]) < now, "Ticket not expired");
        _takePrizeExpired(_seri);
        series[_seri].takeAssetExpired = true;
    }

    function _buyTransfer(
        uint256 assetIndex,
        uint256 assetAmount,
        uint256 postAmount
    ) internal returns (uint256 assetRemain) {
        uint256 postRemain = assetAmount.sub(postAmount);
        uint256 length = sharePercents.length;
        assetRemain = postAmount;
        if (assetIndex == 0) {
            require(msg.value >= assetAmount, "Insufficient-balance");
            postAddress.transfer(postRemain);
            for (uint256 i = 0; i < length; i++) {
                uint256 shareAmount = postAmount.mul(sharePercents[i]).div(MAX_PERCENT);
                if (shareAmount > 0) {
                    shareAddress[i].transfer(shareAmount);
                    assetRemain -= shareAmount;
                }
            }
        } else {
            string[] memory priceFeeds = INormalLotto(normalLotto).getPriceFeeds();
            string memory _symbol = priceFeeds[assetIndex];
            address _asset = getAsset(_symbol).asset;
            require(IBEP20(_asset).transferFrom(msg.sender, address(this), assetAmount), "Insufficient-allowance");
            require(IBEP20(_asset).transfer(postAddress, postRemain), "Insufficient-allowance");
            for (uint256 i = 0; i < length; i++) {
                uint256 shareAmount = postAmount.mul(sharePercents[i]).div(MAX_PERCENT);
                if (shareAmount > 0) {
                    shareAddress[i].transfer(shareAmount);
                    assetRemain -= shareAmount;
                }
            }
        }
    }

    function _updateRemain(
        uint256 _seri,
        uint256 _assetIndex,
        uint256 assetRemain,
        uint256 _totalTicket
    ) internal {
        series[_seri].seriAssetRemain[_assetIndex] += assetRemain;
        series[_seri].soldTicket += _totalTicket;
    }

    function buy(
        uint256 _seri,
        string calldata _numberInfo,
        uint256 _assetIndex,
        uint256 _totalTicket
    ) external payable {
        string[] memory priceFeeds = INormalLotto(normalLotto).getPriceFeeds();
        uint256 assetPerTicket = ticket2Asset(_seri, priceFeeds[_assetIndex]);
        series[_seri].userTickets[msg.sender].push(_numberInfo);
        require(series[_seri].soldTicket + _totalTicket <= series[_seri].max2sale, "Over max2sale");
        uint256 assetAmount = assetPerTicket.mul(_totalTicket);
        uint256 postAmount = assetAmount.mul(postPrices[_seri]).div(series[_seri].price);
        uint256 assetRemain = _buyTransfer(_assetIndex, assetAmount, postAmount);
        uint256 rate = INormalLotto(normalLotto).asset2USD(priceFeeds[_assetIndex]);
        if (series[_seri].seriAssetRemain[_assetIndex] == 0) series[_seri].assetIndex.push(_assetIndex);
        _updateRemain(_seri, _assetIndex, assetRemain, _totalTicket);
        emit BuyTicket(rate, assetAmount);
    }

    function configSigner(address _signer) external onlySigner {
        signer = _signer;
    }

    function configAddress(
        address payable postAddress_,
        address payable carryOver_,
        address nft_,
        address normalLotto_
    ) external onlyOwner {
        postAddress = postAddress_;
        carryOver = carryOver_;
        nft = NFT(nft_);
        normalLotto = normalLotto_;
    }

    function configAffiliate(address payable[] calldata shareAddress_, uint256[] calldata sharePercents_)
        external
        onlyOwner
    {
        require(shareAddress_.length == sharePercents_.length, "Affiliate length mismatch");
        uint256 sumPercents = 0;
        for (uint256 i = 0; i < sharePercents_.length; i++) {
            sumPercents = sumPercents.add(sharePercents_[i]);
        }
        require(sumPercents < MAX_PERCENT, "Invalid percent");
        shareAddress = shareAddress_;
        sharePercents = sharePercents_;
    }

    function getAffilicateConfig() external view returns (address[] memory, uint256[] memory) {
        uint256 length = shareAddress.length;
        address[] memory addresses = new address[](length);
        uint256[] memory percents = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            addresses[i] = shareAddress[i];
            percents[i] = sharePercents[i];
        }

        return (addresses, percents);
    }
}