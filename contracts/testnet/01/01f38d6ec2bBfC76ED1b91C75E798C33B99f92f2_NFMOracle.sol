/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

//SPDX-License-Identifier:MIT

pragma solidity ^0.8.13;

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// LIBRARIES
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// SAFEMATH its a Openzeppelin Lib. Check out for more info @ https://docs.openzeppelin.com/contracts/2.x/api/math
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// INTERFACES
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// INFMCONTROLLER
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
interface INfmController {
    function _checkWLSC(address Controller, address Client)
        external
        pure
        returns (bool);

    function _getController() external pure returns (address);

    function _getExchange() external pure returns (address);
}

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// INFMEXCHANGE
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
interface INfmExchange {
    function setPriceOracle(address Coin, uint256[] memory Price)
        external
        returns (bool);
}

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// IAGGREGATORV3INTERFACE Chainlink DataFeeds https://docs.chain.link/docs/using-chainlink-reference-contracts/
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    // getRoundData and latestRoundData should both raise "No data present"
    // if they do not have data to report, instead of returning unset values
    // which could be misinterpreted as actual reported values.
    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            uint256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            uint256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/// @title NFMOracle.sol
/// @author Fernando Viktor Seidl E-mail: [email protected]
/// @notice This contract includes Chainlink's AggregatorV3 interface. This enables the contract to query the current
///                prices for currencies.
/// @dev In order for the contract to cover all the necessary currencies that NFTISM requires, functions have been reworked
///            to extend the currencies infinitely.
///
///         INTERACTING CONTRACTS OF NFTISMUS:
///         -   NFMLiquidity.sol
///         -   NFMExchange.sol
///             Polygon Pricefeeds of Chainlink https://docs.chain.link/docs/matic-addresses/
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
contract NFMOracle {
    //include SafeMath
    using SafeMath for uint256;
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    CONTROLLER
    OWNER = MSG.SENDER ownership will be handed over to dao
    */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    address private _Owner;
    INfmController private _Controller;
    address private _SController;

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    MAPPINGS
    _Oracle (ERC20 address, AggregatorV3Interface);                 //Records when payments have been made
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    mapping(address => AggregatorV3Interface) public _Oracle;
    mapping(address => uint256) public _OracleSet;
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    MODIFIER
    onlyOwner       => Only Controller listed Contracts and Owner can interact with this contract.
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    modifier onlyOwner() {
        require(
            _Controller._checkWLSC(_SController, msg.sender) == true ||
                _Owner == msg.sender,
            "oO"
        );
        require(msg.sender != address(0), "0A");
        _;
    }

    constructor(
        address MkrAddress,
        address BtcAddress,
        address DaiAddress,
        address WethAddress,
        address WmaticAddress,
        address Controller
    ) {
        _Owner = msg.sender;
        INfmController Cont = INfmController(address(Controller));
        _Controller = Cont;
        _SController = Controller;
        _Oracle[MkrAddress] = AggregatorV3Interface(
            0xa070427bF5bA5709f70e98b94Cb2F435a242C46C
        );
        _OracleSet[MkrAddress] = 1;
        _Oracle[BtcAddress] = AggregatorV3Interface(
            0xc907E116054Ad103354f2D350FD2514433D57F6f
        );
        _OracleSet[BtcAddress] = 1;
        _Oracle[DaiAddress] = AggregatorV3Interface(
            0x4746DeC9e833A82EC7C2C1356372CcF2cfcD2F3D
        );
        _OracleSet[DaiAddress] = 1;
        _Oracle[WethAddress] = AggregatorV3Interface(
            0xF9680D99D6C9589e2a93a78A04A279e509205945
        );
        _OracleSet[WethAddress] = 1;
        _Oracle[WmaticAddress] = AggregatorV3Interface(
            0xAB594600376Ec9fD91F8e885dADF0CE036862dE0
        );
        _OracleSet[WmaticAddress] = 1;
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @_addCurrencies(address Coin, address Aggregators) returns (bool);
    This feature further adds PriceFeed currencies for queries.
     */
    //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _addCurrencies(address Coin, address Aggregators)
        public
        onlyOwner
        returns (bool)
    {
        _Oracle[Coin] = AggregatorV3Interface(address(Aggregators));
        _OracleSet[Coin] = 1;
        return true;
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @_getLatestPrice(address coin) returns (uint256);
    This function returns the current dollar price of a currency in 6 digit format.
     */
    //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _getLatestPrice(address coin) public view returns (uint256) {
        if (_OracleSet[coin] > 0) {
            (
                ,
                /*uint80 roundID*/
                uint256 price, /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/
                ,
                ,

            ) = _Oracle[coin].latestRoundData();
            price = SafeMath.div(price, 10**2);
            return price;
        } else {
            return 0;
        }
    }
}