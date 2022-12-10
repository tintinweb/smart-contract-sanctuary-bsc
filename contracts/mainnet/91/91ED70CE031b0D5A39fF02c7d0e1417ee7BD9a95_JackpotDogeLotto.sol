//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./Ownable.sol";
import "./IVRF.sol";


library Address {

    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
}

contract JackpotDogeLotto is Ownable, VRFConsumerBaseV2 {

    using Address for address;

    // Lotto History
    struct History {
        address winner;
        uint256 amountWon;
        uint256 winningTicket;
        uint256 timestamp;
    }

    // Lotto ID => Lotto History
    mapping ( uint256 => History ) public lottoHistory;

    // User Info
    struct UserInfo {
        uint256 amountWon;
        uint256 amountSpent;
        uint256 numberOfWinningTickets;
    }

    // User => UserInfo
    mapping ( address => UserInfo ) public userInfo;

    // User => Lotto ID => Number of tickets purchased
    mapping ( address => mapping ( uint256 => uint256 )) public userTickets;

    // Current Lotto ID
    uint256 public currentLottoID;

    // Tracked Values
    uint256 public totalRewarded;
    uint256 public totalBNB;

    // Lotto Details
    uint256 public costPerTicket = 4 * 10**16;
    uint256 public lottoDuration = 5 days;

    // When Last Lotto Began
    uint256 public lastLottoStartTime;

    // current ticket ID
    uint256 public currentTicketID;
    mapping ( uint256 => address ) public ticketToUser;

    // Roll Over Percentage
    uint256 public rollOverPercentage = 10;

    // VRF Coordinator
    VRFCoordinatorV2Interface COORDINATOR;

    // Your subscription ID.
    uint64 private s_subscriptionId;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    bytes32 private keyHash;

    // gas limit to call function
    uint32 public gasToCallRandom = 500_000;

    // dev fee
    address private dev;

    // Important Wallets
    address public marketingWallet;
    address public communityWallet;

    // Fees
    uint256 public marketingFee = 20;
    uint256 public communityFee = 20;

    // Events
    event WinnerChosen(address winner, uint256 pot, uint256 winningTicket);

    constructor(address dev_) VRFConsumerBaseV2(0xc587d9053cd1118f25F645F9E08BB98c9712A4EE) {
        // setup chainlink
        keyHash = 0x114f3da0a805b6a67d6e9cd2ec746f7028f1b7376365af575cfea3550dd1aa04;
        COORDINATOR = VRFCoordinatorV2Interface(0xc587d9053cd1118f25F645F9E08BB98c9712A4EE);
        s_subscriptionId = 589;
        dev = dev_;
    }

    /**
        Sets Gas Limits for VRF Callback
     */
    function setGasLimits(uint32 gasToCallRandom_) external onlyOwner {
        gasToCallRandom = gasToCallRandom_;
    }

    /**
        Sets The Key Hash
     */
    function setKeyHash(bytes32 newHash) external onlyOwner {
        keyHash = newHash;
    }

    /**
        Sets Subscription ID for VRF Callback
     */
    function setSubscriptionId(uint64 subscriptionId_) external onlyOwner {
       s_subscriptionId = subscriptionId_;
    }

    function init() external onlyOwner {
        require(
            lastLottoStartTime == 0,
            'Already initialized'
        );
        lastLottoStartTime = block.timestamp;
    }

    function resetLottoTime(uint256 decrement) external onlyOwner {
        lastLottoStartTime = block.timestamp - decrement;
    }

    function setCostPerTicket(uint256 newCost) external onlyOwner {
        costPerTicket = newCost;
    }

    function setLottoDuration(uint256 newDuration) external onlyOwner {
        lottoDuration = newDuration;
    }

    function setRollOverPercent(uint256 rollOverPercentage_) external onlyOwner {
        require(
            rollOverPercentage_ <= 80,
            'Roll Over Percentage Too Large'
        );
        rollOverPercentage = rollOverPercentage_;
    }

    function setMarketingWallet(address newMarketingWallet) external onlyOwner {
        marketingWallet = newMarketingWallet;
    }

    function setCommunityWallet(address newCommunityWallet) external onlyOwner {
        communityWallet = newCommunityWallet;
    }

    function setFees(uint256 marketingFee_, uint256 communityFee_) external onlyOwner {
        marketingFee = marketingFee_;
        communityFee = communityFee_;
        require(marketingFee + communityFee <= 75, 'Fees Too High');
    }

    function setDev(address newDev) external {
        require(msg.sender == dev, 'Only Dev');
        dev = newDev;
    }

    function getTickets() external payable {

        // gas savings
        address user = msg.sender;

        // ensure sender is not a contract
        require(
            user.isContract() == false,
            'Buyer Is Contract'
        );

        // get cost
        uint numTickets = msg.value / costPerTicket;
        require(
            numTickets > 0,
            'Zero Tickets'
        );

        // increment amount spent and total BNB raised
        unchecked {
            userInfo[user].amountSpent += msg.value;
            totalBNB += msg.value;
        }

        // increment the number of tickets purchased for the user at the current lotto ID
        unchecked {
            userTickets[user][currentLottoID] += numTickets;
        }
        
        // Assign Ticket IDs To User
        for (uint i = 0; i < numTickets;) {
            ticketToUser[currentTicketID] = user;
            unchecked { currentTicketID++; ++i; }
        }
    }

    function newLotto() external {
        require(
            lastLottoStartTime > 0,
            'Lotto Has Not Been Initialized'
        );
        require(
            timeUntilNewLotto() == 0,
            'Not Time For New Lotto'
        );

        // start a new lotto, request random words
        _newGame();        
    }


    /**
        Registers A New Game
        Changes The Day Timer
        Distributes Pot
     */
    function _newGame() internal {

        // reset day timer
        lastLottoStartTime = block.timestamp;

        // get random number and send rewards when callback is executed
        // the callback is called "fulfillRandomWords"
        // this will revert if VRF subscription is not set and funded.
        COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            3, // number of block confirmations before returning random value
            gasToCallRandom, // callback gas limit is dependent num of random values & gas used in callback
            1 // the number of random results to return
        );
    }


    /**
        Chainlink's callback to provide us with randomness
     */
    function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory randomWords
    ) internal override {

        // reset current lotto timer if no tickets have been purchased
        if (currentTicketID == 0) {
            lastLottoStartTime = block.timestamp;
            return;
        }

        // select the winner based on the random number generated
        uint256 winningTicket = randomWords[0] % currentTicketID;
        address winner = ticketToUser[winningTicket];

        // size of the pot
        uint256 pot = currentPot();

        // split the pot
        (
            uint forDev,
            uint forCommunity,
            uint forMarketing,
            uint forWinner
        ) = splitPot(pot);

        // save history
        lottoHistory[currentLottoID].winner = winner;
        lottoHistory[currentLottoID].amountWon = forWinner;
        lottoHistory[currentLottoID].winningTicket = winningTicket;
        lottoHistory[currentLottoID].timestamp = block.timestamp;

        // reset lotto time again
        lastLottoStartTime = block.timestamp;
        
        // increment the current lotto ID
        unchecked {
            currentLottoID++;
        }

        // reset ticket IDs back to 0
        delete currentTicketID;

        if (dev != address(0) && forDev > 0) {
            (bool s,) = payable(dev).call{value: forDev}("");
            require(s);
        }

        if (communityWallet != address(0) && forCommunity > 0) {
            (bool s,) = payable(communityWallet).call{value: forCommunity}("");
            require(s);
        }

        if (marketingWallet != address(0) && forMarketing > 0) {
            (bool s,) = payable(marketingWallet).call{value: forMarketing}("");
            require(s);
        }
        
        // give winner
        if (winner != address(0) && forWinner > 0) {

            // increment total rewarded
            unchecked {
                totalRewarded += forWinner;
                userInfo[winner].amountWon += forWinner;
                userInfo[winner].numberOfWinningTickets++;
            }

            // Emit Winning Event
            emit WinnerChosen(winner, pot, winningTicket);

            (bool s,) = payable(winner).call{value: forWinner}("");
            require(s);
        }
    }

    function amountToWin() external view returns (uint256 amount) {
        (,,,amount) = splitPot(currentPot());
    }

    function currentPot() public view returns (uint256) {
        return ( balanceOf() * ( 100 - rollOverPercentage ) ) / 100;
    }

    function splitPot(uint256 pot) public view returns (uint256 forDev, uint256 community, uint256 marketing, uint256 winner) {
        forDev = pot / 10;
        marketing = ( pot * marketingFee ) / 100;
        if (communityWallet == address(0)) {
            marketing += ( pot * communityFee ) / 100;
        } else {
            community = ( pot * communityFee ) / 100;
        }
        winner = pot - ( forDev + community + marketing );
    }

    function currentTicketCost() public view returns (uint256) {
        return costPerTicket;
    }

    function timeUntilNewLotto() public view returns (uint256) {
        uint endTime = lastLottoStartTime + lottoDuration;
        return block.timestamp >= endTime ? 0 : endTime - block.timestamp;
    }

    function getOdds(address user) public view returns (uint256, uint256) {
        return (userTickets[user][currentLottoID], currentTicketID);
    }

    function balanceOf() public view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable{}
}