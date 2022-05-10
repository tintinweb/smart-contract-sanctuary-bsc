// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
import "./AggregatorV3Interface.sol";
import "./Token.sol";

contract MidasTokenGenerator {
    IUniswapV2Router02 public immutable pcsV2Router;
    AggregatorV3Interface internal priceFeed;

    mapping(string => bool) private availableChainlinkNetworks;
    mapping(address => bool) public _managers;

    address public _aw;
    address public _bw;
    address public _cw;
    address public _dw;
    address public owner;
    address busdAddress;

    uint256 _ap = 1000;
    uint256 _bp = 2000;
    uint256 _cp = 3000;
    uint256 _dp = 4000;
    uint256 divisor = 10000;

    uint256 public creationPrice = 50000000000000000000; // 50$
    address private aggregatorAddress;

    constructor(address[] memory addresses) {
        owner = msg.sender;
        _managers[owner] = true;

        pcsV2Router = IUniswapV2Router02(addresses[0]);
        priceFeed = AggregatorV3Interface(addresses[1]);

        _aw = addresses[2];
        _bw = addresses[3];
        _cw = addresses[4];
        _dw = addresses[5];

        availableChainlinkNetworks["bsc"] = true;
        availableChainlinkNetworks["polygon"] = true;
        availableChainlinkNetworks["avalanche"] = true;
    }

    fallback() external payable {}
    receive() external payable {}

    modifier onlyOwner() {
        require(owner == msg.sender, "onlyOwner");
        _;
    }

    modifier onlyManager() {
        require(_managers[msg.sender] == true, "onlyManager");
        _;
    }

    function updateBusdAddress(address _busdAddress) external onlyOwner {
        busdAddress = _busdAddress;
    }

    function updateManagers(address manager, bool newVal) external onlyOwner {
        _managers[manager] = newVal;
    }

    function enableDisableChainlinkNetwork(string memory name, bool status)
        public
        onlyOwner
    {
        availableChainlinkNetworks[name] = status;
    }

    /*
  function updateCreationPrice(uint256 amount) public onlyOwner {
    creationPrice = uint((amount**uint(priceFeed.decimals())) / uint(getLatestPrice())*1e18);
  }
  */

    function updateCreationPrice(uint256 amount) public onlyOwner {
        creationPrice = amount;
    }

    function updatePriceDataFeed(address newValue) public onlyOwner {
        priceFeed = AggregatorV3Interface(address(newValue));
    }

    function createNewToken(
        address paymentTokenAddress,
        address tokenOwner,
        address payable _feeWallet,
        string memory tokenName,
        string memory tokenSymbol,
        uint256 amountOfTokenWei,
        uint8 decimal,
        uint8[] memory fees,
        address routerAddress,
        string memory network
    ) public payable {
        // manager can create tokens for free
        if (!_managers[msg.sender]) {
            // if user pay using other token
            // the contract need how much tokens the user
            // should spend for swap for native network cryptocurrency for pay service
            if (paymentTokenAddress != pcsV2Router.WETH()) {
                // get required token amount for pay service
                uint256 requiredTokenAmount = getMinimunTokenAmout(
                    paymentTokenAddress,
                    network
                );

                // transfer from customer to contract
                require(
                    IERC20(address(paymentTokenAddress)).transferFrom(
                        msg.sender,
                        address(this),
                        requiredTokenAmount
                    )
                );

                // swap to native cryprocurrency | BNB, AVAX, MATIC, ETH ....
                swap(paymentTokenAddress, requiredTokenAmount);
            } else {
                require(
                    msg.value >= getRequiredEthAmount(network),
                    "low value"
                );
            }

            // send to team
            uint256 contractBalance = address(this).balance;
            payable(_aw).transfer(calcPercent(_ap, contractBalance));
            payable(_bw).transfer(calcPercent(_bp, contractBalance));
            payable(_cw).transfer(calcPercent(_cp, contractBalance));
            payable(_dw).transfer(calcPercent(_dp, contractBalance));
        }

        // create token and set user as owner
        Token newToken = new Token(
            tokenOwner,
            tokenName,
            tokenSymbol,
            decimal,
            amountOfTokenWei,
            fees[5],
            fees[6],
            _feeWallet,
            routerAddress
        );
        newToken.setAllFeePercent(fees[0], fees[1], fees[2], fees[3], fees[4]);
    }

    function calcPercent(uint256 percent, uint256 amount)
        public
        view
        returns (uint256)
    {
        return ((percent * amount) / divisor);
    }

    function getRequiredEthAmount(string memory network)
        public
        view
        returns (uint256)
    {
        uint256 nativeTokenPrice;

        // contract need know if user are using network available on chainlink
        // for get native crypto price from chainlink or from router pool
        if (availableChainlinkNetworks[network]) {
            nativeTokenPrice = uint256(getLatestPrice()) * 1e8;
        } else {
            // get price from router pool
            nativeTokenPrice = estimatedTokensForTokens(
                pcsV2Router.WETH(),
                busdAddress,
                creationPrice
            );
        }

        return creationPrice / nativeTokenPrice;
    }

    function getMinimunTokenAmout(address tokenAddress, string memory network)
        public
        view
        returns (uint256)
    {
        return
            estimatedTokensForTokens(
                tokenAddress,
                pcsV2Router.WETH(),
                getRequiredEthAmount(network)
            );
    }

    // return amount of tokenA needed to buy 1 tokenB
    function estimatedTokensForTokens(
        address add1,
        address add2,
        uint256 amount
    ) public view returns (uint256) {
        return
            pcsV2Router.getAmountsOut(amount, pathTokensForTokens(add1, add2))[
                1
            ];
    }

    // return the route given the busd addresses and the token
    function pathTokensForTokens(address add1, address add2)
        private
        pure
        returns (address[] memory)
    {
        address[] memory path = new address[](2);
        path[0] = add1;
        path[1] = add2;
        return path;
    }

    /**
     * Returns the latest price
     */
    function getLatestPrice() public view returns (int256) {
        (
            ,
            /*uint80 roundID*/
            int256 price, /*uint startedAt*/
            ,
            ,

        ) = /*uint timeStamp*/
            /*uint80 answeredInRound*/
            priceFeed.latestRoundData();
        return price;
    }

    function swap(address tokenAddress, uint256 tokenAmount) private {
        IERC20(tokenAddress).approve(address(pcsV2Router), tokenAmount);
        pcsV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            pathTokensForTokens(tokenAddress, pcsV2Router.WETH()),
            address(this),
            block.timestamp
        );
    }
}