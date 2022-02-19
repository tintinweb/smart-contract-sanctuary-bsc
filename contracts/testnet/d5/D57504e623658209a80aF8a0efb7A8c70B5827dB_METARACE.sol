/**
 *Submitted for verification at BscScan.com on 2022-02-19
*/

// File: @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol


pragma solidity ^0.8.0;

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
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

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

// File: contracts/META_Race.sol

//SPDX-License-Identifier: MIT

// ~The Race~
// Every round will feature 10 racers which will represent BEP-20 tokens.
// These tokens will be randomly selected from a pre-defined list of top tokens on BSC.
// There will be a lobby where users will have 57 minutes to purchase bid tickets, followed by a three minute race.  Thus,  a race will be run every hour. 
// People will buy bids tickets for racers which they believe will show the most upward price movement over a 3 minute interval.
// A wallet connected to the dApp may purchase a bid "ticket" on up to 5 racers.  Only one ticket may be purchased per racer.  Thus, the max bid is a 50/50 split.
// Tickets may be purchased in META or BNB.
// The ticket value is set to a fixed rate of META, which can be adjusted per race.
// All bids will be converted to META (ie. BNB can be used to play, but ultimately it turns into a META purchase!).
// This META will be stored in a bid pool.
// 5% of this bid pool will go to the Marketing Wallet.
// 5% of this bid pool will roll-over to the bid pool for the next race.

// ~Winning~
// After the race,  whoever has tickets on the winning racer will receive a split of the META bid pool (minus the fees above).
// This META will need to be claimed through the race dApp.

// Should NO ONE select the correct winner, the entire META bid-pool (minus the fees above) will roll-over to the next race.

pragma solidity >=0.8.3 <0.9.0;


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
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IPancakeRouter01 {
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getamountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getamountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getamountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getamountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}


contract METARACE is Auth {
    IBEP20 private METAToken;
    address _metaTokenAddress = 0xBd92fBC599d838f0eAF1F2a00b8073312f392273;
    uint256 _metaBidAmount = 1000000 * 10 ** 9;
    IPancakeRouter02 private _pancakeRouter;
    address public _pancakeRouterAddress = 0xCc7aDc94F3D80127849D2b41b6439b7CF1eB4Ae0;
    address public _marketingWallet = 0x5cFc8ccA3e8B6b44E8607A5D401A2375E03390aC;
    //make a mapping of priceFeeds keyed to their token symbol
    mapping (string => AggregatorV3Interface) priceFeeds;
    //create an array of common token pair symbols keyed to their contract address
    mapping (string => address) public tokenPairs;
    mapping(uint256 => Race) public _races;
    mapping(bytes32 => Racer) public _racers;
    mapping(uint256 => mapping(address => WalletBid[])) public _walletBids;
    mapping(address => uint256) public walletWinnings;
    uint256 public _currentRace;
    uint256 public _totalRacersPerRace;
    uint256 public _totalBidsPerRace;
    uint256 public _baseBidPoolRollOverPercentage = 500;
    uint256 public _marketingTax = 500;
    uint256 public _maxBidStackSize = 5;

    function setMaxBidStackSize(uint256 maxBidStackSize) public {
        _maxBidStackSize = maxBidStackSize;
    }

    function setBaseBidPoolRollOverPercentage(uint256 percentage) public {
        _baseBidPoolRollOverPercentage = percentage;
    }

    function setMarketingTax(uint256 percentage) public {
        _marketingTax = percentage;
    }

    function setTotalBidsPerRace(uint256 totalBidsPerRace) public {
        _totalBidsPerRace = totalBidsPerRace;
    }

    function setTotalRacersPerRace(uint256 racersPerRace) public {
        _totalRacersPerRace = racersPerRace;
    }

    //create an array of token pairs
    struct TokenPair {
        string pairName;
        string tokenA;
        string tokenB;
        uint256 price;
        uint256 volume;
        uint256 timestamp;
    }

    struct Race {
        uint256 id; 
        string[] tokenPairNames;
        bytes32[] racers;
        //start time
        uint256 startQueueTimestamp;
        uint256 endQueueTimestamp;
        uint256 startRaceTimestamp;
        uint256 endRaceTimestamp;
        bytes32 raceWinner;
        uint256 totalPot;
        bool isPaidOut;
    }

    struct WalletBid {
        uint256 amount;
        address wallet;
        string tokenPairName;
        uint256 timestamp;
        uint256 racerId;
    }

    struct Racer {
        string tokenPairName;
        uint256 id;
        int256 startingPrice;
        int256 endingPrice;
        uint256 startingVolume;
        uint256 endingVolume;
        address[] biddingWallets;
    }
    //create an array of token pairs
    TokenPair[] public tokenPairData;
    //create an array of token pairNames
    string[] public tokenPairNames = [
        "ATOM-USD",
        "BTC-BNB",
        "CAKE-BNB",
        "DODO-BNB",
        "LINK-BNB",
        "MATIC-USD",
        "SUSHI-USD",
        "XRP-BNB",
        "YFI-BNB",
        "ZIL-USD"
    ];
    
    function setMetaBidAmount(uint256 metaBidAmount) public onlyOwner {
        require(metaBidAmount > 0 && metaBidAmount <= 100000000);
        _metaBidAmount = metaBidAmount * 10 ** 9;
    }

    //populate tokenPairs with the common token pair symbols
    function populateTokenPairs() private {
        tokenPairs["ATOM-USD"] = 0xb056B7C804297279A9a673289264c17E6Dc6055d;
        tokenPairs["BTC-BNB"] = 0x116EeB23384451C78ed366D4f67D5AD44eE771A0;
        tokenPairs["CAKE-BNB"] = 0xcB23da9EA243f53194CBc2380A6d4d9bC046161f;
        tokenPairs["DODO-BNB"] = 0x120ae15CB86060527BFD431Abd3FF51890D2032C;
        tokenPairs["LINK-BNB"] = 0xB38722F6A608646a538E882Ee9972D15c86Fc597;
        tokenPairs["MATIC-USD"] = 0x7CA57b0cA6367191c94C8914d7Df09A57655905f;
        tokenPairs["SUSHI-USD"] = 0xa679C72a97B654CFfF58aB704de3BA15Cde89B07;
        tokenPairs["XRP-BNB"] = 0x798A65D349B2B5E6645695912880b54dfFd79074;
        tokenPairs["YFI-BNB"] = 0xF841761481DF19831cCC851A54D8350aE6022583;
        tokenPairs["ZIL-USD"] = 0x3e3aA4FC329529C8Ab921c810850626021dbA7e6;
    } 
    
    /**
     * Network: Binance Smart Chain
     * Aggregator: BNB/USD
     * Address: 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
     */
    constructor() Auth(msg.sender) {
        _pancakeRouter = IPancakeRouter02(_pancakeRouterAddress);
        METAToken = IBEP20(_metaTokenAddress);
        //iterate through all tokenPairNames
        for (uint i = 0; i < tokenPairNames.length; i++) {
            //get the token pair name
            priceFeeds[tokenPairNames[i]] = AggregatorV3Interface(tokenPairs[tokenPairNames[i]]);
        }
    }

    /**
     * Returns the latest price
     */
    function getLatestPrice(string memory tokenPairName) public view returns (int256) {
        (
            uint80 roundID,
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeeds[tokenPairName].latestRoundData();
        return price;
    }

    //get 10 random tokenPairNames
    function getRandomTokenPairNames() public view returns (string[10] memory) {
        //create an array of strings with 10 elements called randomTokenPairNames
        string[10] memory randomTokenPairNames;
        for (uint i = 0; i < _totalRacersPerRace; i++) {
            randomTokenPairNames[i] = tokenPairNames[i];
        }
        return randomTokenPairNames;
    }

    //on an interval, start a race queue
    function startRaceQueue() public onlyOwner {
        _races[_currentRace].startQueueTimestamp = block.timestamp;
        string[10] memory _tokenPairNames = getRandomTokenPairNames();
        //iterate through tokenPairNames
        for(uint i=0; i<_tokenPairNames.length; i++) {
            //construct a race
            bytes32 racerHash = getRacerHash(tokenPairNames[i], _currentRace);
            _races[_currentRace].racers.push(racerHash);
            _racers[racerHash] = createRacer(_tokenPairNames[i]);
            _races[_currentRace].tokenPairNames[i] = _tokenPairNames[i];
        }
    }
    
    function createRacer(string memory tokenPairName) private pure returns (Racer memory) {
        Racer memory racer;
        racer.tokenPairName = tokenPairName;
        return racer;
    }

    function getRacerHash(string memory tokenPairName, uint256 raceWeek) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(tokenPairName, raceWeek));
    }

    function placeBidMETA(string memory tokenPairName, uint256 ticketCount) public {
        require(METAToken.balanceOf(msg.sender) >= _metaBidAmount * ticketCount, "You do not have enough META to place a bid.");
        verifyBid(tokenPairName, ticketCount);
        placeBid(tokenPairName, ticketCount);
    }

    function placeBidBNB(string memory tokenPairName, uint256 ticketCount) public {
        address[] memory path = new address[](2);
        path[0] = _pancakeRouter.WETH();
        path[1] = address(METAToken);
        uint amountInBNB = getBidAmountInBNB(ticketCount);
        require(msg.sender.balance >= amountInBNB, "You do not have enough BNB to place a bid.");
        verifyBid(tokenPairName, ticketCount);
        
        _pancakeRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amountInBNB}(
            0, //must be equivalent to metaBidAmount
            path,
            address(this),
            block.timestamp
        );

        placeBid(tokenPairName, ticketCount);
    }

    function verifyBid(string memory tokenPairName, uint256 ticketCount) private view {
        uint256 bidStack = 0;
        //iterate through walletBids
        for (uint i = 0; i < _walletBids[_currentRace][msg.sender].length; i++) {
            //if the tokenPairName is the same as the tokenPairName
            if (keccak256(abi.encode(_walletBids[_currentRace][msg.sender][i].tokenPairName)) == keccak256(abi.encode(tokenPairName))) {
                //increase bid stack for tokenPairName
                bidStack += 1;
            }
        }
        require(bidStack + ticketCount < _maxBidStackSize, "You have excceded the bid stack for this token.");
    
        
        require((_walletBids[_currentRace][msg.sender].length + ticketCount) <= _totalBidsPerRace, "You have exceeded the total bid allowance for this race.");
    }
    
    function placeBid(string memory tokenPairName, uint256 ticketCount) private {
        //send the bid to the contract
        METAToken.transfer(address(this), _metaBidAmount * ticketCount);
        //iterate through ticketcount
        for (uint i = 0; i < ticketCount; i++) {
            //create new WalletBid
            WalletBid memory walletBid;
            walletBid.tokenPairName = tokenPairName;
            walletBid.amount = _metaBidAmount;
            walletBid.timestamp = block.timestamp;
            walletBid.racerId = _currentRace;
            walletBid.wallet = msg.sender;
        }
        //add walletBid to walletBids
        _races[_currentRace].totalPot += _metaBidAmount * ticketCount; 
        emit SetTotalPot(_races[_currentRace].totalPot);
    }

    function getBidAmountInBNB(uint256 ticketCount) public view returns (uint256) {
        //get the amount of BNB needed to buy the tickets
        uint amount = _metaBidAmount * ticketCount;
        address[] memory path = new address[](2);
        path[0] = _pancakeRouter.WETH();
        path[1] = address(METAToken);
        uint[] memory amountInBNB = _pancakeRouter.getamountsIn(amount, path);
        return amountInBNB[0];
    }

    function startRace() public onlyOwner {
        //get the current
        _races[_currentRace].startRaceTimestamp = block.timestamp;
        //get starting prices
        for(uint i=0; i<_races[_currentRace].racers.length; i++) {
            _racers[_races[_currentRace].racers[i]].startingPrice = getLatestPrice(_racers[_races[_currentRace].racers[i]].tokenPairName);
        }
    }
    
    function endRace() public onlyOwner {
        //get the current
        _races[_currentRace].startRaceTimestamp = block.timestamp;
        //get starting prices
        for(uint i=0; i<_races[_currentRace].racers.length; i++) {
            _racers[_races[_currentRace].racers[i]].endingPrice = getLatestPrice(_racers[_races[_currentRace].racers[i]].tokenPairName);
        }
        determineWinner();
        payoutWinners();
    }

    struct LastHighestDifferential {
        uint256 id;
        bytes32 racerHash;
        int256 lastHighestDifferential;
    }

    function determineWinner() private {
        //create an array of price differentials
        int256[] memory priceDifferentials = new int256[](_totalRacersPerRace); //?? is this correct
        LastHighestDifferential memory lastHighestDifferential = LastHighestDifferential({id: 0, lastHighestDifferential: 0, racerHash: 0});
        for(uint i=0; i<_totalRacersPerRace; i++) {
            //find the difference between the ending price and the starting price
            priceDifferentials[i] = _racers[_races[_currentRace].racers[i]].endingPrice - _racers[_races[_currentRace].racers[i]].startingPrice;
            //if this price is greater than the last highest price, declare it the winner
            if(priceDifferentials[i] > lastHighestDifferential.lastHighestDifferential) {
                lastHighestDifferential.id = i;
                lastHighestDifferential.racerHash = _races[_currentRace].racers[i];
                lastHighestDifferential.lastHighestDifferential = priceDifferentials[i];
            }   
        }
        _races[_currentRace].raceWinner = lastHighestDifferential.racerHash; 
    }

    function payoutWinners() private {
        Racer memory winningRacer = _racers[_races[_currentRace].raceWinner];
        takeMarketingCut();
        if(winningRacer.biddingWallets.length == 0) {
            rollPayoutToNextRace();
        } else {
            rollBidPoolToNextRace();
            for(uint i=0; i<winningRacer.biddingWallets.length; i++) {
                walletWinnings[winningRacer.biddingWallets[i]] += calculatePayout(_races[_currentRace].totalPot, winningRacer.biddingWallets.length);
            }
        }
    }

    function takeMarketingCut() private {
        uint256 percentageForMarketing = _races[_currentRace].totalPot * _marketingTax / 10000;
        walletWinnings[_marketingWallet] += percentageForMarketing;
    }

    function rollBidPoolToNextRace() private {
        //take 5% of the bid pool and roll it over to the next race
        uint256 percentageToRollOver = _races[_currentRace].totalPot * _baseBidPoolRollOverPercentage / 10000;
        _races[_currentRace + 1].totalPot += percentageToRollOver;
        _races[_currentRace].totalPot = _races[_currentRace].totalPot - percentageToRollOver;
        emit SetTotalPot(_races[_currentRace].totalPot);
    }

    function calculatePayout(uint256 totalPot, uint256 amountOfBids) private pure returns (uint256) {
        return totalPot / amountOfBids;
    }

    function rollPayoutToNextRace() private {
        //move the total pot to the next race
        _races[_currentRace + 1].totalPot += _races[_currentRace].totalPot;
        _races[_currentRace].totalPot = 0;
        emit SetTotalPot(_races[_currentRace].totalPot);
        emit RollPayoutToNextRace(_races[_currentRace].totalPot);
    }

    //events
    event RollPayoutToNextRace(uint256 amountMETA);
    event SetTotalPot(uint256 totalPot);
}