/**
 *Submitted for verification at BscScan.com on 2022-04-19
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

interface AggregatorV3Interface {
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
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
}

contract LotteryV2 is Ownable {
    event OpenSeri(uint256 seri);
    event CloseSeri(uint256 seri, uint256 endTime);
    event OpenResult(uint256 seri, bool isWin);
    event BuyTicket(uint256 seri, address user, string numberInfo);
    event SetWinners(uint256 seri, uint256 turn);
    using SafeMath for uint256;

    uint256 public currentSignTime;
    string[] public priceFeeds;

    uint256 public currentCarryOverSeri;
    address public signer = 0x7a7f38737BFCD8a1301Dd262a226780350980eA3;
    address payable public postAddress;
    address payable public stake;
    address payable public purchase;
    address payable public affiliateAddress;
    address payable public operator;
    address payable public carryOver;

    IBEP20 public initCarryOverAsset = IBEP20(0x013345B20fe7Cf68184005464FBF204D9aB88227);
    NFT public nft = NFT(0x1CadF5af6d52Aa4397F8E6b94Da933cFF9Fdc284);

    uint256 public share2Stake;
    uint256 public share2Purchase;
    uint256 public share2Affiliate;
    uint256 public share2Operator;
    uint256 public share2AffiliateCO;
    uint256 public share2OperatorCO;
    uint256 public expiredPeriod = 259200; // 30 days

    struct asset {
        string symbol;
        address asset;
        AggregatorV3Interface priceFeed;
    }

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
        uint256 initPrize;
        uint256 initPrizeTaken;
        uint256 winInitPrize;
        mapping(address => string[]) userTickets;
        // mapping(uint => mapping(address => ticket)) userTickets; // seri => timestamp => user => ticket
        mapping(uint256 => uint256) seriAssetRemain; // seri => asset index => remain
        mapping(uint256 => uint256) winAmount;
    }

    mapping(uint256 => seri) public series;
    mapping(string => asset) assets;
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
        return keccak256(abi.encodePacked(timestamp, abi.encode(_seri, _winners, _buyTickets, _totalTicket, _assets, _turn)));
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
        bytes32 _messageHash = getbytesDataSetWinners(timestamp, _seri, _winners, _buyTickets, _totalTicket, _assets, _turn);
        return ecrecover(getEthSignedMessageHash(_messageHash), v, r, s) == signer;
    }

    function getPriceFeeds() public view returns (string[] memory _symbols) {
        return priceFeeds;
    }

    function getAsset(string memory _symbol) public view returns (asset memory _asset) {
        return assets[_symbol];
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

    function getUserTickets(uint256 _seri, address _user) public view returns (string[] memory) {
        return series[_seri].userTickets[_user];
    }

    function seriAssetRemain(uint256 _seri, uint256 _asset) public view returns (uint256) {
        return series[_seri].seriAssetRemain[_asset];
    }

    function getLatestPrice(string memory _symbol) public view returns (int256) {
        (, int256 _price, , , ) = assets[_symbol].priceFeed.latestRoundData();
        return _price * 10**10;
    }

    function asset2USD(string memory _symbol) public view returns (uint256 _amountUsd) {
        return uint256(getLatestPrice(_symbol));
    }

    function asset2USD(string memory _symbol, uint256 _amount) public view returns (uint256 _amountUsd) {
        return _amount.mul(uint256(getLatestPrice(_symbol))).div(1 ether);
    }

    function ticket2Asset(uint256 _seri, string memory _symbol) public view returns (uint256 _amountUsd) {
        uint256 expectedRate = asset2USD(_symbol);
        return series[_seri].price.mul(1 ether).div(expectedRate);
    }

    function openSeri(
        uint256 _seri,
        uint256 _price,
        uint256 _postPrice,
        uint256 _max2sale,
        uint256 _initPrize
    ) public onlyOwner {
        require(series[_seri].price == 0, "Seri existed");
        require(_postPrice <= _price, "Invalid post price");
        series[_seri].seriType = 1;
        if (_initPrize > 0) {
            require(currentCarryOverSeri == 0 || series[currentCarryOverSeri].status != 0, "Carry-over seri opening");
            require(initCarryOverAsset.transferFrom(msg.sender, address(this), _initPrize), "Insufficient-allowance");
            series[_seri].seriType = 2;
            series[_seri].initPrize = _initPrize;
            currentCarryOverSeri = _seri;
        }
        series[_seri].price = _price;
        series[_seri].max2sale = _max2sale;
        seriExpiredPeriod[_seri] = expiredPeriod;
        postPrices[_seri] = _postPrice;
        emit OpenSeri(_seri);
    }

    function takeAsset2CarryOver(uint256 _seri) internal {
        for (uint256 i = 0; i < series[_seri].assetIndex.length; i++) {
            if (series[_seri].seriAssetRemain[series[_seri].assetIndex[i]] > 0) {
                uint256 takeAmount = series[_seri].seriAssetRemain[series[_seri].assetIndex[i]];
                if (series[_seri].assetIndex[i] == 0) carryOver.transfer(takeAmount);
                else {
                    string memory _symbol = priceFeeds[series[_seri].assetIndex[i]];
                    IBEP20 _asset = IBEP20(assets[_symbol].asset);
                    require(_asset.transfer(carryOver, takeAmount), "Insufficient-balance");
                }
                series[_seri].seriAssetRemain[series[_seri].assetIndex[i]] = 0;
            }
        }
        if (series[_seri].seriType == 2) initCarryOverAsset.transfer(carryOver, series[_seri].initPrize);
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
                uint256 tokenID = nft.mint(_winners[i], _seri, startTime, now, sr.result, 2, sr.totalWin, _winners[i], 1, _assets[i]);
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
        require(permitSetWinners(timestamp, _seri, _winners, _buyTickets, _totalTicket, _assets, _turn, v, r, s), "Invalid signal");
        require(series[_seri].winners.length.add(_totalTicket) <= series[_seri].totalWin, "Invalid winners");
        sendNFT(_seri, startTime, _winners, _buyTickets, _assets);
        currentSignTime = timestamp;
        currentTurn[_seri] = _turn;
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
                    takeAmount = series[_seri].seriAssetRemain[series[_seri].assetIndex[i]].mul(_buyTickets).div(_winTickets);
                    series[_seri].winAmount[series[_seri].assetIndex[i]] = takeAmount;
                }
                series[_seri].seriAssetRemain[series[_seri].assetIndex[i]] = series[_seri].seriAssetRemain[series[_seri].assetIndex[i]].sub(takeAmount);
                if (series[_seri].assetIndex[i] == 0) msg.sender.transfer(takeAmount);
                else {
                    string memory _symbol = priceFeeds[series[_seri].assetIndex[i]];
                    IBEP20 _asset = IBEP20(assets[_symbol].asset);
                    require(_asset.transfer(msg.sender, takeAmount), "insufficient-allowance");
                }
            }
        }
        if (series[_seri].seriType == 2) {
            uint256 takeAssetInitAmount = series[_seri].winInitPrize;
            if (takeAssetInitAmount == 0) {
                takeAssetInitAmount = series[_seri].initPrize.mul(_buyTickets).div(_winTickets);
                series[_seri].winInitPrize = takeAssetInitAmount;
            }
            initCarryOverAsset.transfer(msg.sender, takeAssetInitAmount);
            series[_seri].initPrizeTaken += takeAssetInitAmount;
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
        series[_seri].prizetaked.push(_nftId);
        takeAsset(_seri, _winTickets, _buyTickets);
        nft.burn(_nftId);
    }

    function totalPrize(uint256 _seri) public view returns (uint256 _prize) {
        for (uint256 i = 0; i < series[_seri].assetIndex.length; i++) {
            if (series[_seri].seriAssetRemain[series[_seri].assetIndex[i]] > 0) {
                string memory symbol = priceFeeds[series[_seri].assetIndex[i]];
                _prize += asset2USD(symbol, series[_seri].seriAssetRemain[series[_seri].assetIndex[i]]);
            }
        }
    }

    function _takePrizeExpired(uint256 _seri) internal {
        for (uint256 i = 0; i < series[_seri].assetIndex.length; i++) {
            if (series[_seri].seriAssetRemain[series[_seri].assetIndex[i]] > 0) {
                uint256 takeAmount = series[_seri].seriAssetRemain[series[_seri].assetIndex[i]];
                if (series[_seri].assetIndex[i] == 0) carryOver.transfer(takeAmount);
                else {
                    string memory _symbol = priceFeeds[series[_seri].assetIndex[i]];
                    IBEP20 _asset = IBEP20(assets[_symbol].asset);
                    require(_asset.transfer(carryOver, takeAmount), "insufficient-allowance");
                }
                series[_seri].seriAssetRemain[series[_seri].assetIndex[i]] = 0;
            }
        }
        if (series[_seri].seriType == 2) {
            uint256 takeAssetInitRemain = series[_seri].initPrize.sub(series[_seri].initPrizeTaken);
            initCarryOverAsset.transfer(carryOver, takeAssetInitRemain);
            series[_seri].initPrizeTaken = series[_seri].initPrizeTaken;
        }
    }

    function takePrizeExpired(uint256 _seri) public onlyOwner {
        require(!series[_seri].takeAssetExpired, "Taked");
        require(series[_seri].endTime.add(seriExpiredPeriod[_seri]) < now, "Ticket not expired");

        _takePrizeExpired(_seri);
        series[_seri].takeAssetExpired = true;
    }

    function _buyAmount(uint256 _seriType, uint256 postAmount) internal view returns(uint256 shareStakeAmount, uint256 sharePurchaseAmount, uint256 shareAffiliateAmount, uint256 takeTokenAmount) {
        if (_seriType == 1) {
            shareStakeAmount = postAmount.mul(share2Stake).div(1000000);
            sharePurchaseAmount = postAmount.mul(share2Purchase).div(1000000);
            shareAffiliateAmount = postAmount.mul(share2Affiliate).div(1000000);
            takeTokenAmount = postAmount.mul(share2Operator).div(1000000);
        } else {
            shareAffiliateAmount = postAmount.mul(share2AffiliateCO).div(1000000);
            takeTokenAmount = postAmount.mul(share2OperatorCO).div(1000000);
        }
    }

    function _buyTransfer(uint256 _seriType, uint256 _assetIndex, uint256 assetAmount, uint256 postRemain, uint256 shareStakeAmount, uint256 sharePurchaseAmount, uint256 shareAffiliateAmount, uint256 takeTokenAmount) internal {
        if (_assetIndex == 0) {
            require(msg.value >= assetAmount, "Insufficient-balance");
            postAddress.transfer(postRemain);
            if (_seriType == 1) {
                stake.transfer(shareStakeAmount);
                purchase.transfer(sharePurchaseAmount);
            }
            affiliateAddress.transfer(shareAffiliateAmount);
            operator.transfer(takeTokenAmount);
        } else {
            string memory _symbol = priceFeeds[_assetIndex];
            IBEP20 _asset = IBEP20(assets[_symbol].asset);
            require(_asset.transferFrom(msg.sender, address(this), assetAmount), "Insufficient-allowance");
            if (_seriType == 1) {
                stake.transfer(shareStakeAmount);
                purchase.transfer(sharePurchaseAmount);
            }
            require(_asset.transfer(postAddress, postRemain), "Insufficient-allowance");
            require(_asset.transfer(affiliateAddress, shareAffiliateAmount), "Insufficient-allowance");
            require(_asset.transfer(operator, takeTokenAmount), "Insufficient-allowance");
        }
    }

    function _updateRemain(uint256 _seri, uint256 _assetIndex, uint256 assetRemain, uint256 _totalTicket) internal {
        series[_seri].seriAssetRemain[_assetIndex] += assetRemain;
        series[_seri].soldTicket += _totalTicket;
    }

    function buy(
        uint256 _seri,
        string memory _numberInfo,
        uint256 _assetIndex,
        uint256 _totalTicket
    ) public payable {
        uint256 assetPerTicket = ticket2Asset(_seri, priceFeeds[_assetIndex]);
        series[_seri].userTickets[msg.sender].push(_numberInfo);
        require(series[_seri].soldTicket + _totalTicket <= series[_seri].max2sale, "Over max2sale");
        uint256 assetAmount = assetPerTicket.mul(_totalTicket);
        uint256 postAmount = assetAmount.mul(postPrices[_seri]).div(series[_seri].price);
        uint256 postRemain = assetAmount.sub(postAmount);

        (uint256 shareStakeAmount, uint256 sharePurchaseAmount, uint256 shareAffiliateAmount, uint256 takeTokenAmount) = _buyAmount(_seri, postAmount);
        _buyTransfer(series[_seri].seriType, _assetIndex, assetAmount, postRemain, shareStakeAmount, sharePurchaseAmount, shareAffiliateAmount, takeTokenAmount);

        if (series[_seri].seriAssetRemain[_assetIndex] == 0) series[_seri].assetIndex.push(_assetIndex);
        uint256 assetRemain = assetAmount.sub(postRemain).sub(shareAffiliateAmount).sub(takeTokenAmount);
        if (series[_seri].seriType == 1) assetRemain = assetRemain.sub(shareStakeAmount).sub(sharePurchaseAmount);
        _updateRemain(_seri, _assetIndex, assetRemain, _totalTicket);
        emit BuyTicket(_seri, msg.sender, _numberInfo);
    }

    function setAssets(
        string[] memory _symbols,
        address[] memory _bep20s,
        AggregatorV3Interface[] memory _priceFeeds
    ) public onlyOwner {
        require(_symbols.length == _bep20s.length && _symbols.length == _priceFeeds.length, "Length mismatch");
        for (uint256 i = 0; i < _symbols.length; i++) {
            assets[_symbols[i]] = asset(_symbols[i], _bep20s[i], _priceFeeds[i]);
        }
        priceFeeds = _symbols;
    }

    function configSigner(address _signer) external onlySigner {
        signer = _signer;
    }

    function configAddress(
        address payable _stake,
        address payable _purchase,
        address payable _affiliateAddress,
        address payable _operator,
        address payable _postAddress,
        address payable _carryOver,
        address _initCarryOverAsset,
        address _nft
    ) external onlyOwner {
        stake = _stake;
        purchase = _purchase;
        affiliateAddress = _affiliateAddress;
        operator = _operator;
        postAddress = _postAddress;
        carryOver = _carryOver;
        initCarryOverAsset = IBEP20(_initCarryOverAsset);
        nft = NFT(_nft);
    }

    function config(
        uint256 _expiredPeriod,
        uint256 _share2Stake,
        uint256 _share2Purchase,
        uint256 _share2Affiliate,
        uint256 _share2Operator,
        uint256 _share2AffiliateCO,
        uint256 _share2OperatorCO
    ) external onlyOwner {
        require(_share2Stake + _share2Purchase + _share2Affiliate + _share2Operator < 1000000, "N: Invalid percent");
        require(_share2AffiliateCO + _share2OperatorCO < 1000000, "C: Invalid percent");
        expiredPeriod = _expiredPeriod;
        share2Stake = _share2Stake;
        share2Purchase = _share2Purchase;
        share2Affiliate = _share2Affiliate;
        share2Operator = _share2Operator;
        share2AffiliateCO = _share2AffiliateCO;
        share2OperatorCO = _share2OperatorCO;
    }
}