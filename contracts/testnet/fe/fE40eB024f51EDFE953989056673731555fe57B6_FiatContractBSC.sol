pragma solidity ^0.4.26;
pragma experimental ABIEncoderV2;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(((c = a * b) / a) == b);
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x);
    }

    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x);
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface AggregatorV3Interface {
    function latestRoundData() external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );
}

interface IERC20Metadata {
    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract FiatContractBSC is Ownable {
    using SafeMath for uint256;

    constructor() public {
        assets["BNB"] = asset("BNB", address(0), 0, AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526));
        assets["BUSD"] = asset("BUSD", 0x10297304eEA4223E870069325A2EEA7ca4Cd58b4, 0, AggregatorV3Interface(0x9331b55D9830EF609A2aBCfAc0FBCE050A52fdEa));
        assets["BTCB"] = asset("BTCB", 0xf6f3F4f5d68Ddb61135fbbde56f404Ebd4b984Ee, 0, AggregatorV3Interface(0x5741306c21795FdCBb9b265Ea0255F499DFe515C));
        assets["USDT"] = asset("USDT", 0x013345B20fe7Cf68184005464FBF204D9aB88227, 0, AggregatorV3Interface(0xEca2605f0BCF2BA5966372C99837b1F182d3D620));
        assets["ETH"] = asset("ETH", 0x979Db64D8cD5Fed9f1B62558547316aFEdcf4dBA, 0, AggregatorV3Interface(0x143db3CEEfbdfe5631aDD3E50f7614B6ba708BA7));
        assets["USDC"] = asset("USDC", 0xF53E2228ff7F680D4677878eeA2c7814a5233C85, 0, AggregatorV3Interface(0x90c069C4538adAc136E051052E14c1cD799C41B7));
        assets["XRP"] = asset("XRP", 0xd2926D1f868Ba1E81325f0206A4449Da3fD8FB62, 0, AggregatorV3Interface(0x4046332373C24Aed1dC8bAd489A04E187833B28d));
        assets["TokenW"] = asset("TokenW", 0x9338c973f69c996194355046F84775c890BdC74a, 400000000000000000, AggregatorV3Interface(0));
    }

    address public manager = address(0x64470E5F5DD38e497194BbcAF8Daa7CA578926F6);

    struct Token {
        string symbol;
        uint256 Token2USD;
        bool existed;
    }
    
    struct asset {
        string symbol;
        address asset;
        uint256 price;
        AggregatorV3Interface priceFeed;
    }

    mapping(string => Token) tokens;
    mapping(string => asset) assets;

    string[] public TokenArr;
    uint256 public mulNum = 2;
    uint256 public lastCode = 3;
    uint256 public callTime = 1;
    uint256 public baseTime = 3;
    uint256 public plusNum = 1;

    event SetPrice(string[] _symbols, uint256[] _token2USD, address _from);
    
    modifier onlyManager() {
        require(msg.sender == manager || isOwner());
        _;
    }

    function setInput(
        uint256 _mulNum,
        uint256 _lastCode,
        uint256 _callTime,
        uint256 _baseTime,
        uint256 _plusNum
    ) public onlyOwner {
        mulNum = _mulNum;
        lastCode = _lastCode;
        callTime = _callTime;
        baseTime = _baseTime;
        plusNum = _plusNum;
    }

    function setManager(address _newManager) public onlyOwner {
        manager = _newManager;
    }

    function setPrice(
        string[] _symbols,
        uint256[] _token2USD,
        uint256 _code
    ) public onlyManager {
        require(_code == findNumber(lastCode));
        for (uint256 i = 0; i < _symbols.length; i++) {
            tokens[_symbols[i]].Token2USD = _token2USD[i];
            if (!tokens[_symbols[i]].existed) {
                TokenArr.push(_symbols[i]);
                tokens[_symbols[i]].existed = true;
                tokens[_symbols[i]].symbol = _symbols[i];
            }
        }
        emit SetPrice(_symbols, _token2USD, msg.sender);
    }

    function setTokenPrice(string[] memory _symbols, address[] memory _assets, uint256[] memory _prices, AggregatorV3Interface[] memory _priceFeeds, uint256 _code) public onlyManager {
        require(_code == findNumber(lastCode));
        for (uint256 i = 0; i < _symbols.length; i++) {
            assets[_symbols[i]] = asset(_symbols[i], _assets[i], _prices[i], _priceFeeds[i]);
        }
    }

    function getLatestPrice(address token) public view returns (uint256) {
        string memory symbol = "BNB";
        if (token != address(0)) {
            symbol = IERC20Metadata(token).symbol();
        }

        if (assets[symbol].priceFeed != AggregatorV3Interface(address(0))) {
            (, int256 _price, , , ) = assets[symbol].priceFeed.latestRoundData();
            return uint256(_price * 10**10);
        }
        return assets[symbol].price;
    }

    function _getLatestPrice(string _symbol) internal view returns (int) {
        (, int256 _price, , , ) = assets[_symbol].priceFeed.latestRoundData();
        return _price * 10**10;
    }

    function USD2Asset(string memory _symbol, uint _amountUSD) public view returns(uint _amountAsset) {
        return _amountUSD.mul(1 ether).div(uint(_getLatestPrice(_symbol)));
    }

    function getToken2USD(string __symbol) public view returns (string _symbolToken, uint256 _token2USD) {
        uint256 token2USD;
        if(assets[__symbol].asset != address(0) || keccak256(abi.encodePacked(__symbol)) == keccak256(abi.encodePacked("BNB"))) token2USD = USD2Asset(__symbol, 1 ether);
        else token2USD = tokens[__symbol].Token2USD;
        return (tokens[__symbol].symbol, token2USD);
    }

    function getTokenArr() public view returns (string[]) {
        return TokenArr;
    }

    function findNumber(uint256 a) internal returns (uint256) {
        uint256 b = a.mul(mulNum) - plusNum;
        if (callTime % 3 == 0) {
            for (uint256 i = 0; i < baseTime; i++) {
                b += (a + plusNum) / mulNum;
            }
            b = b / baseTime + plusNum;
        }
        if (b > 9293410619286421) {
            mulNum = callTime % 9 == 1 ? 2 : callTime % 9;
            b = 3;
        }
        ++callTime;
        lastCode = b;
        return b;
    }
}