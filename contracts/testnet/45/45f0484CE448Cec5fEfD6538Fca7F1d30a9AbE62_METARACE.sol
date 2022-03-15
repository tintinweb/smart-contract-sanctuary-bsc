/**
 *Submitted for verification at BscScan.com on 2022-03-15
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

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IPancakeFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IPancakeRouter01 {
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getamountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getamountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getamountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getamountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

abstract contract Auth {
    address internal owner;
    mapping(address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED");
        _;
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
    address public _metaTokenAddress = 0xBd92fBC599d838f0eAF1F2a00b8073312f392273;
    uint256 public _metaBidAmount = 1000000 * 10**9;
    IPancakeRouter02 private _pancakeRouter;
    address public _pancakeRouterAddress =
        0xCc7aDc94F3D80127849D2b41b6439b7CF1eB4Ae0;
    address public _marketingWallet =
        0x5cFc8ccA3e8B6b44E8607A5D401A2375E03390aC;
    //make a mapping of priceFeeds keyed to their token symbol
    mapping(string => AggregatorV3Interface) priceFeeds;
    //create an array of common token pair symbols keyed to their contract address
    mapping(string => address) public tokenPairs;
    mapping(uint256 => Race) public _races;
    mapping(bytes32 => Racer) public _racers;
    //current race - address - reference to _walletBidsHash
    mapping(uint256 => mapping(address => bytes32)) public _walletBids;
    //hashmap of wallet bids based on current race - sender address - token pair - bid id
    mapping(bytes32 => WalletBid[]) public _walletBidsHash;
    mapping(address => uint256) public walletWinnings;
    uint256 public _currentRace;
    uint256 public _totalRacersPerRace = 10;
    uint256 public _totalBidsPerRace = 5;
    uint256 public _baseBidPoolRollOverPercentage = 500;
    uint256 public _marketingTax = 500;
    uint256 public _maxBidStackSize = 5;
    //create a timestamp for raceQueue prevRaceQueueTime
    uint256 public _prevRaceQueueTime = 0;
    //create a timestamp for raceStart prevRaceStartTime
    uint256 public _prevRaceStartTime = 0;
    //create a timestamp for raceEnd prevRaceEndTime
    uint256 public _prevRaceEndTime = 0;
    //race interval in hours
    uint256 public _raceIntervalInHours = 4;

    //set a timestamp for race length in seconds
    uint256 public raceLength = 72000;

    uint256 public starterTax = 1000;

    uint256 public enderTax = 1000;

    uint256 public baseRaceSpeed = 100;
    uint256 public raceTimeWindow = 3 minutes;

    function setRaceTimeWindow(uint256 _raceTimeWindow) public {
        raceTimeWindow = _raceTimeWindow;
    }

    function setBaseRaceSpeed(uint256 _baseRaceSpeed) public {
        baseRaceSpeed = _baseRaceSpeed;
    }

    function setRaceStarterTax(uint256 amount) public onlyOwner 
    {
        starterTax = amount;
    }

    function setRaceEnderTax(uint256 amount) public onlyOwner 
    {
        enderTax = amount;
    }

    bool public biddingOpen = false;

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
        bytes32 racerId;
    }

    struct Racer {
        string tokenPairName;
        int256 startingPrice;
        int256 endingPrice;
        uint80 startingRoundId;
        uint80 endingRoundId;
        uint256 startingVolume;
        uint256 endingVolume;
        uint256 totalBids;
        //hashmap of bidding wallets correlated to walletBids
        bytes32[] biddingWallets;
    }
    //create an array of token pairs
    TokenPair[] public tokenPairData;
    //create an array of token pairNames
    //mainnet
    // string[] public tokenPairNames = [
    //     "ATOM-USD",
    //     "BTC-BNB",
    //     "CAKE-BNB",
    //     "DODO-BNB",
    //     "LINK-BNB",
    //     "MATIC-USD",
    //     "SUSHI-USD",
    //     "XRP-BNB",
    //     "YFI-BNB",
    //     "ZIL-USD"
    // ];
    //testnet
    string[] public tokenPairNames = [
        "ADA-USD",
        "BAKE-USD",
        "CAKE-USD",
        "CREAM-USD",
        "DOGE-USD",
        "DOT-USD",
        "FIL-USD",
        "REEF-USD",
        "SFP-USD",
        "XRP-USD"
    ];

    function setMetaBidAmount(uint256 metaBidAmount) public onlyOwner {
        require(metaBidAmount > 0 && metaBidAmount <= 100000000);
        _metaBidAmount = metaBidAmount * 10**9;
    }

    //populate tokenPairs with the common token pair symbols
    function populateTokenPairs() private {
        //mainnet
        // tokenPairs["ATOM-USD"] = 0xb056B7C804297279A9a673289264c17E6Dc6055d;
        // tokenPairs["BTC-BNB"] = 0x116EeB23384451C78ed366D4f67D5AD44eE771A0;
        // tokenPairs["CAKE-BNB"] = 0xcB23da9EA243f53194CBc2380A6d4d9bC046161f;
        // tokenPairs["DODO-BNB"] = 0x120ae15CB86060527BFD431Abd3FF51890D2032C;
        // tokenPairs["LINK-BNB"] = 0xB38722F6A608646a538E882Ee9972D15c86Fc597;
        // tokenPairs["MATIC-USD"] = 0x7CA57b0cA6367191c94C8914d7Df09A57655905f;
        // tokenPairs["SUSHI-USD"] = 0xa679C72a97B654CFfF58aB704de3BA15Cde89B07;
        // tokenPairs["XRP-BNB"] = 0x798A65D349B2B5E6645695912880b54dfFd79074;
        // tokenPairs["YFI-BNB"] = 0xF841761481DF19831cCC851A54D8350aE6022583;
        // tokenPairs["ZIL-USD"] = 0x3e3aA4FC329529C8Ab921c810850626021dbA7e6;
        //testnet
        tokenPairs["ADA-USD"] = 0x5e66a1775BbC249b5D51C13d29245522582E671C;
        tokenPairs["BAKE-USD"] = 0xbe75E0725922D78769e3abF0bcb560d1E2675d5d;
        tokenPairs["CAKE-USD"] = 0x81faeDDfeBc2F8Ac524327d70Cf913001732224C;
        tokenPairs["CREAM-USD"] = 0xB8eADfD8B78aDA4F85680eD96e0f50e1B5762b0a;
        tokenPairs["DOGE-USD"] = 0x963D5e7f285Cc84ed566C486c3c1bC911291be38;
        tokenPairs["DOT-USD"] = 0xEA8731FD0685DB8AeAde9EcAE90C4fdf1d8164ed;
        tokenPairs["FIL-USD"] = 0x17308A18d4a50377A4E1C37baaD424360025C74D;
        tokenPairs["REEF-USD"] = 0x902fA2495a8c5E89F7496F91678b8CBb53226D06;
        tokenPairs["SFP-USD"] = 0x4b531A318B0e44B549F3b2f824721b3D0d51930A;
        tokenPairs["XRP-USD"] = 0x4046332373C24Aed1dC8bAd489A04E187833B28d;
    }

    /**
     * Network: Binance Smart Chain
     * Aggregator: BNB/USD
     * Address: 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
     */
    constructor() Auth(msg.sender) {
        _pancakeRouter = IPancakeRouter02(_pancakeRouterAddress);
        METAToken = IBEP20(_metaTokenAddress);
        populateTokenPairs();
        //iterate through all tokenPairNames
        for (uint256 i = 0; i < tokenPairNames.length; i++) {
            //get the token pair name
            priceFeeds[tokenPairNames[i]] = AggregatorV3Interface(
                tokenPairs[tokenPairNames[i]]
            );
        }
    }

    function addTokenPairName(string memory pairName, address contractAddress) public  {
        tokenPairs[pairName] = contractAddress;
        //add to tokenPairNames
        tokenPairNames.push(pairName);
    }

    function removeTokenPairName(string memory pairName) public {
        delete tokenPairs[pairName];
        //remove from tokenPairNames
        for (uint i = 0; i < tokenPairNames.length; i++) {
            if (keccak256(bytes(tokenPairNames[i])) == keccak256(bytes(pairName))) {
                delete tokenPairNames[i];
            }
        }
    }

    /**
     * Returns the latest price
     */
    function getLatestPriceAndRound(string memory tokenPairName)
        public
        view
        returns (uint80, int256)
    {
        (
            uint80 roundID,
            int256 price,
            uint256 startedAt,
            uint256 timeStamp,
            uint80 answeredInRound
        ) = priceFeeds[tokenPairName].latestRoundData();
        return (roundID, price);
    }

    function getRandomTokenPairNames() public view returns (string[10] memory) {
        //create an array of strings with 10 elements called randomTokenPairNames
        string[10] memory randomTokenPairNames;
        for (uint256 i = 0; i < _totalRacersPerRace; i++) {
            randomTokenPairNames[i] = tokenPairNames[i];
        }
        return randomTokenPairNames;
    }

    //on an interval, start a race queue
    function startRaceQueue() public onlyOwner {
        biddingOpen = true;
        //advance _currentRace by 1
        _currentRace = _currentRace + 1;
        //racequeue timestamp is actually considered "started" with 25% of the time remaining in the race interval 
        //_races[_currentRace].startQueueTimestamp = _races[_currentRace - 1].endRaceTimestamp + (getRaceIntervalInHours() / 4);
        _races[_currentRace].startQueueTimestamp = block.timestamp;
        //string[10] memory _tokenPairNames = tokenPairNames;
        //iterate through tokenPairNames
        for (uint256 i = 0; i < tokenPairNames.length; i++) {
            //construct a race
            bytes32 racerHash = getRacerHash(tokenPairNames[i], _currentRace);
            _races[_currentRace].racers.push(racerHash);
            //create Racer
            _racers[racerHash] = createRacer(tokenPairNames[i]);
            _races[_currentRace].tokenPairNames.push(tokenPairNames[i]);
        }
        emit RaceQueueStarted(_races[_currentRace]);
    }

    function getRaceRacers(uint256 raceId) external view returns (bytes32[] memory) {
        return _races[raceId].racers;
    }

    function getRaceTokenPairNames(uint256 raceId) external view returns (string[] memory) {
        return _races[raceId].tokenPairNames;
    }

    function getRacerBiddingWallets(bytes32 racer) external view returns(bytes32[] memory) {
        return _racers[racer].biddingWallets;
    }

    function createRacer(string memory tokenPairName)
        private
        pure
        returns (Racer memory)
    {
        Racer memory racer;
        racer.tokenPairName = tokenPairName;
        return racer;
    }

    function getRacerHash(string memory tokenPairName, uint256 raceWeek)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(tokenPairName, raceWeek));
    }

    function placeBidMETA(string memory tokenPairName, uint256 ticketCount)
        public
    {
        require(
            biddingOpen == true, "Bidding is not open"
        );
        require(
            METAToken.balanceOf(msg.sender) >= _metaBidAmount * ticketCount,
            "You do not have enough META to place a bid."
        );
        verifyBid(tokenPairName, ticketCount);
        placeBid(tokenPairName, ticketCount);
    }

    function placeBidBNB(string memory tokenPairName, uint256 ticketCount)
        public
    {
        require(
            biddingOpen == true, "Bidding is not open"
        );
        address[] memory path = new address[](2);
        path[0] = _pancakeRouter.WETH();
        path[1] = address(METAToken);
        uint256 amountInBNB = getBidAmountInBNB(ticketCount);
        require(
            msg.sender.balance >= amountInBNB,
            "You do not have enough BNB to place a bid."
        );
        verifyBid(tokenPairName, ticketCount);

        _pancakeRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amountInBNB
        }(
            0, //must be equivalent to metaBidAmount
            path,
            address(this),
            block.timestamp
        );

        placeBid(tokenPairName, ticketCount);
    }

    function verifyBid(string memory tokenPairName, uint256 ticketCount)
        private
        view
    {
        uint256 bidStack = 0;
        bytes32 walletBidHash = getWalletBidHash(msg.sender, tokenPairName, _currentRace);
        //iterate through walletBids
        for (
            uint256 i = 0;
            i < _walletBidsHash[walletBidHash].length;
            i++
        ) {
            //if the tokenPairName is the same as the tokenPairName
            if (
                keccak256(
                    abi.encode(
                        _walletBidsHash[walletBidHash][i].tokenPairName
                    )
                ) == keccak256(abi.encode(tokenPairName))
            ) {
                //increase bid stack for tokenPairName
                bidStack += 1;
            }
        }
        require(
            bidStack + ticketCount < _maxBidStackSize,
            "You have excceded the bid stack for this token."
        );

        require(
            (_walletBidsHash[walletBidHash].length + ticketCount) <=
                _totalBidsPerRace,
            "You have exceeded the total bid allowance for this race."
        );
    }

    function getWalletBidHash(
        address biddingAddress,
        string memory tokenPairName,
        uint256 raceId
    ) public pure returns (bytes32) {
        return
            keccak256(abi.encodePacked(tokenPairName, raceId, biddingAddress));
    }

    function placeBid(string memory tokenPairName, uint256 ticketCount)
        private
    {
        //send the bid to the contract
        METAToken.transferFrom(msg.sender, address(this), _metaBidAmount * ticketCount);
        bytes32 racerHash = getRacerHash(tokenPairName, _currentRace);
        bytes32 walletBidHash = getWalletBidHash(
            msg.sender,
            tokenPairName,
            _currentRace
        );
        //iterate through ticketcount
        for (uint256 i = 0; i < ticketCount; i++) {
            //create new WalletBid
            WalletBid memory walletBid;
            walletBid.tokenPairName = tokenPairName;
            walletBid.amount = _metaBidAmount;
            walletBid.timestamp = block.timestamp;
            walletBid.racerId = racerHash;
            walletBid.wallet = msg.sender;
            //add walletBid to walletBids
            _walletBidsHash[walletBidHash].push(walletBid);
            _racers[racerHash].totalBids++;
        }
        _walletBids[_currentRace][msg.sender] = walletBidHash;
        bool walletAdded = false;
        //iterate through biddingwallets
        for (uint256 i = 0; i < _racers[racerHash].biddingWallets.length; i++) {
            //if the wallet is not the sender
            if (_racers[racerHash].biddingWallets[i] == walletBidHash) {
                walletAdded =  true;
            }
        }
        if (!walletAdded) {
            _racers[racerHash].biddingWallets.push(walletBidHash);
        }
        _races[_currentRace].totalPot += _metaBidAmount * ticketCount;
        emit SetTotalPot(_races[_currentRace].totalPot);
        emit BidPlaced(tokenPairName, ticketCount, _racers[racerHash].totalBids);
    }

    function getTotalBidsForTokenPair(string memory tokenPair, uint256 raceId) external view returns (uint256) {
        bytes32 racerHash = getRacerHash(tokenPair, raceId);
        return _racers[racerHash].totalBids;
    }

    function concatenateArrays(
        WalletBid[] memory walletBid1,
        WalletBid[] memory walletBid2
    ) private pure returns (WalletBid[] memory) {
        WalletBid[] memory returnArr;

        uint256 i = 0;
        for (; i < walletBid1.length; i++) {
            returnArr[i] = walletBid1[i];
        }

        uint256 j = 0;
        while (j < walletBid2.length) {
            returnArr[i++] = walletBid2[j++];
        }

        return returnArr;
    }

    function getWalletBid(bytes32 walletBidHash)
        public
        view
        returns (WalletBid[] memory)
    {
        return _walletBidsHash[walletBidHash];
    }

    function getBidAmountInBNB(uint256 ticketCount)
        public
        view
        returns (uint256)
    {
        //get the amount of BNB needed to buy the tickets
        uint256 amount = _metaBidAmount * ticketCount;
        address[] memory path = new address[](2);
        path[0] = _pancakeRouter.WETH();
        path[1] = address(METAToken);
        uint256[] memory amountInBNB = _pancakeRouter.getamountsIn(
            amount,
            path
        );
        return amountInBNB[0];
    }

    function getRaceIntervalInHours() private view returns (uint256) {
        uint256 timestamp = _raceIntervalInHours * 1 hours;
        return timestamp;
    }

    /**
    Anyone is free to invoke this function, they will be rewarded a small portion of the total pot.
     */
    function startRace() public {
        //disable bidding
        biddingOpen = false;
        require(block.timestamp >= _races[_currentRace - 1].endRaceTimestamp + getRaceIntervalInHours(), "The race cannot be started yet"); 
        if(block.timestamp >= _races[_currentRace - 1].endRaceTimestamp + getRaceIntervalInHours() + raceTimeWindow) {
            endRacePrematurely();
        } else {
            //award race starter with some percentage of the race pot
            takeRaceStarterCut();
        }
        _races[_currentRace].startRaceTimestamp = block.timestamp;//_races[_currentRace - 1].startRaceTimestamp + getRaceIntervalInHours();
    
        //get starting prices
        for (uint256 i = 0; i < _races[_currentRace].racers.length; i++) {
            (uint80 roundId, int256 price) = getLatestPriceAndRound(
                _racers[_races[_currentRace].racers[i]].tokenPairName
            );
            _racers[_races[_currentRace].racers[i]]
                .startingPrice = price;
            _racers[_races[_currentRace].racers[i]].startingRoundId = roundId;
        }
        emit RaceStarted(_races[_currentRace]);
    }

    /**
    Anyone is free to invoke this function, they will be rewarded a small portion of the total pot.
    TODO: How do we effect gaming this system??
     */
    function endRace() public {
        require(block.timestamp >= _races[_currentRace].startRaceTimestamp + raceLength, "The race cannot be ended yet"); 
        
        if(block.timestamp >= _races[_currentRace - 1].startRaceTimestamp + raceLength + raceTimeWindow) {
            //race end window has expired, end the race prematurely and payoutwinners (this will roll the pot to the next race)
            payoutWinners();
        } else {
            //award race ender with some percentage of the race pot
            takeRaceEnderCut();
        }
        //set the end race timestamp
        _races[_currentRace].endRaceTimestamp = block.timestamp;
        //set ending round id
        for (uint256 i = 0; i < _races[_currentRace].racers.length; i++) {
            (uint80 roundId, int256 price) = getLatestPriceAndRound(
                _racers[_races[_currentRace].racers[i]].tokenPairName
            );
            _racers[_races[_currentRace].racers[i]]
                .endingPrice = price;
            _racers[_races[_currentRace].racers[i]].endingRoundId = roundId;
        }
        determineWinner();
        payoutWinners();
        emit RaceEnded(_races[_currentRace]);
        startRaceQueue();
    }

    //No race payouts rewarded, roll everything forward
    function endRacePrematurely() private {
        //stamp start time and end time as though a race were run
        _races[_currentRace].startRaceTimestamp = block.timestamp;
        _races[_currentRace].endRaceTimestamp = block.timestamp + raceLength;    
        //race start window has expired, end the race prematurely and payoutwinners (this will roll the pot to the next race)
        payoutWinners();
        emit RaceEnded(_races[_currentRace]);
        startRaceQueue();
    }

    struct LastHighestPercentage {
        uint256 id;
        bytes32 racerHash;
        int256 lastHighestPercentage;
    }

    function determineWinner() private {
        //create an array of price differentials
        int256[] memory percentageChange = new int256[](_totalRacersPerRace);
        bool[] memory percentageChangeIsIncrease = new bool[](_totalRacersPerRace); //?? is this correct
        LastHighestPercentage
            memory lastHighestPercentage = LastHighestPercentage({
                id: 0,
                lastHighestPercentage: 0,
                racerHash: 0
            });
        for (uint256 i = 0; i < _totalRacersPerRace; i++) {
            //find the difference between the ending price and the starting price
            percentageChange[i] =
                _racers[_races[_currentRace].racers[i]].endingPrice /
                _racers[_races[_currentRace].racers[i]].startingPrice * 10000;
                
            //if this price is greater than the last highest price, declare it the winner
            if (
                percentageChange[i] >
                lastHighestPercentage.lastHighestPercentage
            ) {
                lastHighestPercentage.id = i;
                lastHighestPercentage.racerHash = _races[_currentRace].racers[
                    i
                ];
                lastHighestPercentage
                    .lastHighestPercentage = percentageChange[i];
            }
        }
        _races[_currentRace].raceWinner = lastHighestPercentage.racerHash;
    }

    function payoutWinners() private {
        Racer memory winningRacer = _racers[_races[_currentRace].raceWinner];
        takeMarketingCut();
        if (winningRacer.biddingWallets.length == 0) {
            rollPayoutToNextRace();
        } else {
            rollBidPoolToNextRace();
            for (uint256 i = 0; i < winningRacer.biddingWallets.length; i++) {
                for(uint256 j = 0; j < _walletBidsHash[winningRacer.biddingWallets[i]].length; j++) {
                    //this keeps track of wallet winnings until claimed
                    walletWinnings[_walletBidsHash[winningRacer.biddingWallets[i]][j].wallet] += calculatePayout(
                        _races[_currentRace].totalPot,
                        winningRacer.biddingWallets.length
                    );
                }
            }
        }
    }

    function takeMarketingCut() private {
        uint256 cutForMarketing = (_races[_currentRace].totalPot *
            _marketingTax) / 10000;
        walletWinnings[_marketingWallet] += cutForMarketing;
        _races[_currentRace].totalPot -= cutForMarketing;
    }

    function takeRaceStarterCut() private {
        uint256 cutForStarter = (_races[_currentRace].totalPot *
            starterTax) / 10000;
        walletWinnings[msg.sender] += cutForStarter;
        _races[_currentRace].totalPot -= cutForStarter;
    }

    function takeRaceEnderCut() private {
        uint256 cutForEnder = (_races[_currentRace].totalPot *
            enderTax) / 10000;
        walletWinnings[msg.sender] += cutForEnder;
        _races[_currentRace].totalPot -= cutForEnder;
        emit SetTotalPot(_races[_currentRace].totalPot);
    }

    function rollBidPoolToNextRace() private {
        //take 5% of the bid pool and roll it over to the next race
        uint256 percentageToRollOver = (_races[_currentRace].totalPot *
            _baseBidPoolRollOverPercentage) / 10000;
        _races[_currentRace + 1].totalPot += percentageToRollOver;
        _races[_currentRace].totalPot =
            _races[_currentRace].totalPot -
            percentageToRollOver;
        emit SetTotalPot(_races[_currentRace].totalPot);
    }

    function calculatePayout(uint256 totalPot, uint256 amountOfBids)
        private
        pure
        returns (uint256)
    {
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
    event RaceStarted(Race race);
    event RaceEnded(Race race);
    event RaceQueueStarted(Race race);
    event BidPlaced(string tokenPair, uint256 ticketCount, uint256 bidAmount);
}