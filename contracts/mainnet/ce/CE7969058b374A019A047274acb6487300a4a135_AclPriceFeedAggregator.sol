// c3846aa7a64bc9aa8537f676ac312ba46c068b28
// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.17;

import "Ownable.sol";

interface AggregatorV3Interface {
    function latestRoundData() external view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function decimals() external view returns (uint8);
}

interface IERC20 {
    function decimals() external view returns (uint8);
}


contract AclPriceFeedAggregator is TransferOwnable{
    
    uint256 public constant DECIMALS_BASE = 18;
    mapping(address => address) public priceFeedAggregator;
    mapping(address => address) public tokenMap;

    address public constant BNB = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    struct PriceFeedAggregator {
        address token; 
        address priceFeed; 
    }

    event PriceFeedUpdated(address indexed token, address indexed priceFeed);
    event TokenMap(address indexed nativeToken, address indexed wrappedToken);

    constructor() {
        tokenMap[BNB] = WBNB;//
        priceFeedAggregator[BNB] = 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE;// BNB
        priceFeedAggregator[WBNB] = 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE;// WBNB
        priceFeedAggregator[0x2170Ed0880ac9A755fd29B2688956BD959F933F8] = 0x9ef1B8c0E4F7dc8bF5719Ea496883DC6401d5b2e;// ETH
        priceFeedAggregator[0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c] = 0x58afEb74C77C1d410fbcbb4858582D2669d5a6c0;// BBTC & WBTC / USD
        priceFeedAggregator[0xBf5140A22578168FD562DCcF235E5D43A02ce9B1] = 0xb57f259E7C24e56a1dA00F66b55A5640d9f9E7e4;// UNI
        priceFeedAggregator[0xF8A0BF9cF54Bb92F17374d9e9A321E6a111a51bD] = 0xca236E327F629f9Fc2c30A4E95775EbF0B89fac8;// LINK
        priceFeedAggregator[0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d] = 0x51597f405303C4377E36123cBc172b13269EA163;// USDC
        priceFeedAggregator[0x55d398326f99059fF775485246999027B3197955] = 0xB97Ad0E74fa7d920791E90258A6E2085088b4320;// USDT
        priceFeedAggregator[0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3] = 0x132d3C0B1D2cEa0BC552588063bdBb210FDeecfA;// DAI
        priceFeedAggregator[0x90C97F71E18723b0Cf0dfa30ee176Ab653E89F40] = 0x13A9c98b07F098c5319f4FF786eB16E22DC738e1;// FRAX
        priceFeedAggregator[0xB0D502E938ed5f4df2E681fE6E419ff29631d62b] = address(0);// STG  no chainlink price feed
        priceFeedAggregator[0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82] = 0xB6064eD41d4f67e353768aA239cA86f4F73665a1;// CAKE
        priceFeedAggregator[0xcF6BB5389c92Bdda8a3747Ddb454cB7a64626C63] = 0xBF63F430A79D4036A5900C19818aFf1fa710f206;// XVS
        priceFeedAggregator[0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56] = 0xcBb98864Ef56E9042e7d2efef76141f15731B82f;// BUSD

    }

    function getUSDPrice(address _token) public view returns (uint256,uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(priceFeedAggregator[_token]);
        require(address(priceFeed) != address(0), "priceFeed not found");
        (uint80 roundId, int256 price, , uint256 updatedAt, uint80 answeredInRound) = priceFeed.latestRoundData();
        require(price > 0, "Chainlink: price <= 0");
        require(answeredInRound >= roundId, "Chainlink: answeredInRound <= roundId");
        require(updatedAt > 0, "Chainlink: updatedAt <= 0");
        return (uint256(price) , uint256(priceFeed.decimals()));
    }

    function getUSDValue(address _token , uint256 _amount) public view returns (uint256) {
        if (tokenMap[_token] != address(0)) {
            _token = tokenMap[_token];
        } 
        (uint256 price, uint256 priceFeedDecimals) = getUSDPrice(_token);
        uint256 usdValue = (_amount * uint256(price) * (10 ** DECIMALS_BASE)) / ((10 ** IERC20(_token).decimals()) * (10 ** priceFeedDecimals));
        return usdValue;
    }

    function setPriceFeed(address _token, address _priceFeed) public onlyOwner {    
        require(_priceFeed != address(0), "_priceFeed not allowed");
        require(priceFeedAggregator[_token] != _priceFeed, "_token _priceFeed existed");
        priceFeedAggregator[_token] = _priceFeed;
        emit PriceFeedUpdated(_token,_priceFeed);
    }

    function setPriceFeeds(PriceFeedAggregator[] calldata _priceFeedAggregator) public onlyOwner {    
        for (uint i=0; i < _priceFeedAggregator.length; i++) { 
            priceFeedAggregator[_priceFeedAggregator[i].token] = _priceFeedAggregator[i].priceFeed;
        }
    }

    function setTokenMap(address _nativeToken, address _wrappedToken) public onlyOwner {    
        require(_wrappedToken != address(0), "_wrappedToken not allowed");
        require(tokenMap[_nativeToken] != _wrappedToken, "_nativeToken _wrappedToken existed");
        tokenMap[_nativeToken] = _wrappedToken;
        emit TokenMap(_nativeToken,_wrappedToken);
    }


    fallback() external {
        revert("Unauthorized access");
    }

}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "Context.sol";

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function _transferOwnership(address newOwner) internal virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract TransferOwnable is Ownable {
    function transferOwnership(address newOwner) public virtual onlyOwner {
        _transferOwnership(newOwner);
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