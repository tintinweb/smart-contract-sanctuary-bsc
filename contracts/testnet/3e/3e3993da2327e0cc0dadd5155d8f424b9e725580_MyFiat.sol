/**
 *Submitted for verification at BscScan.com on 2022-06-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

library SafeMath {
    /**
     * @dev Multiplies two numbers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two numbers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

//
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
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    // The description of the aggregator that the proxy points to.
    function description() external view returns (string memory);

    //The version representing the type of aggregator the proxy points to.
    function version() external view returns (uint256);

    //Get data from a specific round.
    // getRoundData and latestRoundData should both raise "No data present"
    // if they do not have data to report, instead of returning unset values
    // which could be misinterpreted as actual reported values.
    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    //Get data from the latest round.
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

// - getTokenPrice(address token)
// Tính năng (onlyOwner):
// - Có 1 hàm set (token và priceFeed) để lấy giá những token nổi tiếng mà chainlink có support
// - Có 1 hàm set (token và price) để lấy giá những token của mình
// => set hay get? -> chac la get

// tim trong tokens[] neu ko co thi tra ve 0

contract MyFiat is Ownable {
    event SetPrice(address[] _addresses, string[] _symbols, uint8[] _decimals, uint256[] _token2JPYs, address _from);
    event SetAsset(address[] _addresses, string[] _symbols, AggregatorV3Interface[] _priceFeeds, address _from);

    using SafeMath for uint256;
    AggregatorV3Interface internal priceFeed;

    address[] public tokenAddresses;
    address[] public assetAddresses;

    // Se kho khan khi setPrice
    // struct Token {
    //     address token; //address token 0x2170Ed0880ac9A755fd29B2688956BD959F933F8
    //     string symbol; // "ETH"
    //     uint8 decimals;
    //     uint256 tokenToJPY; // price (token to JPY)
    //     AggregatorV3Interface priceFeed; // token ko co tren chainlink thi mac dinh la gi?
    //     bool existed; // co can exist ko ?
    // }

    struct Token {
        address token;
        string symbol;
        uint8 decimals;
        uint256 tokenToJPY;
        bool existed;
    }

    struct Asset {
        address token;
        string symbol;
        AggregatorV3Interface priceFeed;
        bool existed;
    }

    mapping(address => Token) public tokens;
    mapping(address => Asset) public assets;

    //priceFeeds: BNB Chain Testnet  (USD)
    // BNB Chain Testnet price feed: 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
    // BAKE Chain Testnet price feed: 0xbe75E0725922D78769e3abF0bcb560d1E2675d5d
    constructor() {
        tokens[0x095418A82BC2439703b69fbE1210824F2247D77c] = Token(0x095418A82BC2439703b69fbE1210824F2247D77c, "BNB", 18, 29949, true);
        // tokens[0xE02dF9e3e622DeBdD69fb838bB799E3F168902c5] = Token(0x095418A82BC2439703b69fbE1210824F2247D77c, "BAKE", 18, 32, true);
        tokens[0x7a983559e130723B70e45bd637773DbDfD3F71Db] = Token(0x7a983559e130723B70e45bd637773DbDfD3F71Db, "DBZ", 18, 123, true);
        
        tokenAddresses.push(0x095418A82BC2439703b69fbE1210824F2247D77c);
        tokenAddresses.push(0x7a983559e130723B70e45bd637773DbDfD3F71Db);

        assets[0x095418A82BC2439703b69fbE1210824F2247D77c] = Asset(0x095418A82BC2439703b69fbE1210824F2247D77c, "BNB", AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526), true);
        // assets[0xE02dF9e3e622DeBdD69fb838bB799E3F168902c5] = Asset(0xE02dF9e3e622DeBdD69fb838bB799E3F168902c5, "BAKE", AggregatorV3Interface(0xbe75E0725922D78769e3abF0bcb560d1E2675d5d), true);
        assetAddresses.push(0x095418A82BC2439703b69fbE1210824F2247D77c);
        // assetAddresses.push(0xE02dF9e3e622DeBdD69fb838bB799E3F168902c5);

    }

// nho push vao
    function setPrice(
        address[] memory _tokens,
        string[] memory _symbols,
        uint8[] memory _decimals,
        uint256[] memory _tokenToJPYs
    ) public onlyOwner {
        require(_tokens.length == _decimals.length && _decimals.length == _symbols.length && _symbols.length == _tokenToJPYs.length, "MyFiat: Invalid array length !");
        uint256 length = _tokens.length;

        for (uint256 i = 0; i < length; i++) {
            _setPrice(_tokens[i], _symbols[i], _decimals[i], _tokenToJPYs[i]);
        }
        emit SetPrice(_tokens, _symbols, _decimals, _tokenToJPYs, msg.sender);
    }

    function _setPrice(
        address _token,
        string memory _symbol,
        uint8 _decimals,
        uint256 _tokenToJPY
    ) public {
        tokens[_token].tokenToJPY = _tokenToJPY;

        if (!tokens[_token].existed) {
            tokenAddresses.push(_token);

            tokens[_token].token = _token;
            tokens[_token].symbol = _symbol;
            tokens[_token].decimals = _decimals;
            tokens[_token].existed = true;
        }
        tokenAddresses.push(_token);

    }

    function setAsset(
        address[] memory _tokens,
        string[] memory _symbols,
        AggregatorV3Interface[] memory _priceFeeds
    ) public onlyOwner {
        require(_tokens.length == _symbols.length && _symbols.length == _priceFeeds.length, "MyFiat: Invalid array length !");
        uint256 length = _tokens.length;

        for (uint256 i = 0; i < length; i++) {
            _setAsset(_tokens[i], _symbols[i], _priceFeeds[i]);
        }
        emit SetAsset(_tokens, _symbols, _priceFeeds, msg.sender);
    }

    function _setAsset(
        address _token,
        string memory _symbol,
        AggregatorV3Interface _priceFeed
    ) public {
        assets[_token].priceFeed = _priceFeed;

        if (!assets[_token].existed) {
            assets[_token].token = _token;
            assets[_token].symbol = _symbol;
            assets[_token].existed = true;
        }
        assetAddresses.push(_token);
    }

    // Kiem tra asset truoc (lay data tu chainlink), neu khong co moi lay data trong token
    function getTokenPrice(address tokenAddress) public view returns (uint256) {
        uint256 tokenPrice = 0;
        uint8 tokenDecimals;

        if (assets[tokenAddress].existed) {
            (, int256 _price, , , ) = assets[tokenAddress].priceFeed.latestRoundData();
            tokenPrice = uint256(_price);
            tokenDecimals = assets[tokenAddress].priceFeed.decimals();
        } else if (tokens[tokenAddress].existed) {
            tokenPrice = tokens[tokenAddress].tokenToJPY;
            tokenDecimals = tokens[tokenAddress].decimals;
        }

        return tokenPrice * (10**tokenDecimals);
    }
}