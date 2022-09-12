//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./Ownable.sol";
import "./IVRF.sol";
import "./IUniswapV2Router02.sol";

interface IXUSD {
    function burn(uint256 amount) external;
    function sell(uint256 tokenAmount) external returns (address, uint256);
}

contract XUSDWIN is Ownable, VRFConsumerBaseV2 {

    // XUSD Contract
    address public constant XUSD = 0x324E8E649A6A3dF817F97CdDBED2b746b62553dD;

    // PCS Router For Buying Link To Sustain System
    IUniswapV2Router02 public router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    // Lotto History
    struct History {
        address winner;
        uint256 amountWon;
    }

    // Lotto ID => Lotto History
    mapping ( uint256 => History ) public lottoHistory;

    // Current Lotto ID
    uint256 public currentLottoID;

    // Lotto Details
    uint256 public startingCostPerTicket = 1 * 10**18;
    uint256 public costIncreasePerTimePeriod = 5 * 10**17;
    uint256 public timePeriodForCostIncrease = 1 days;
    uint256 public lottoDuration = 7 days;

    // When Last Lotto Began
    uint256 public lastLottoStartTime;

    // current ticket ID
    uint256 public currentTicketID;
    mapping ( uint256 => address ) public ticketToUser;

    // Nobody Wins Edge
    uint256 public nobodyWinsEdge = 10;

    // Roll Over Percentage
    uint256 public rollOverPercentage = 10;

    // burn percentage
    uint256 public burnPercentage = 50;

    // address to receive LINK to keep lotto continuously going
    address public linkBuyer;

    // flat amount of XUSD to liquidate for link each lotto
    uint256 public amountToLiquidateEachLotto = 2 * 10**18;

    // VRF Coordinator
    VRFCoordinatorV2Interface COORDINATOR;

    // Your subscription ID.
    uint64 private s_subscriptionId;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    bytes32 private keyHash;

    // chainlink request IDs
    uint256 private newLottoRequestID;

    // gas limit to call function
    uint32 public gasToCallRandom = 1_000_000;

    // Events
    event WinnerChosen(address winner, uint256 pot);
    event NobodyWins();

    constructor() VRFConsumerBaseV2(0xc587d9053cd1118f25F645F9E08BB98c9712A4EE) {
        // setup chainlink
        keyHash = 0xba6e730de88d94a5510ae6613898bfb0c3de5d16e609c5b7da808747125506f7;
        COORDINATOR = VRFCoordinatorV2Interface(0xc587d9053cd1118f25F645F9E08BB98c9712A4EE);
        s_subscriptionId = 471;
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

    function setStartingTicketCost(uint256 newCost) external onlyOwner {
        startingCostPerTicket = newCost;
    }

    function setLottoDuration(uint256 newDuration) external onlyOwner {
        lottoDuration = newDuration;
    }

    function setCostIncreasePerTimePeriod(uint256 increasePerPeriod) external onlyOwner {
        costIncreasePerTimePeriod = increasePerPeriod;
    }

    function setTimePeriodForCostIncrease(uint256 newTimePeriod) external onlyOwner {
        timePeriodForCostIncrease = newTimePeriod;
    }

    function setNobodyWinsEdge(uint256 nobodyWinsEdge_) external onlyOwner {
        require(
            nobodyWinsEdge_ <= 25,
            'Nobody Wins Edge Too Large'
        );
        nobodyWinsEdge = nobodyWinsEdge_;
    }

    function setRollOverPercent(uint256 rollOverPercentage_) external onlyOwner {
        require(
            rollOverPercentage_ <= 50,
            'Roll Over Percentage Too Large'
        );
        rollOverPercentage = rollOverPercentage_;
    }

    function setBurnPercentage(uint256 burnPercentage_) external onlyOwner {
        require(
            burnPercentage_ <= 90,
            'Burn Percentage Too Large'
        );
        burnPercentage = burnPercentage_;
    }

    function setAmountToLiquidateEachLotto(uint256 newAmountForLink) external onlyOwner {
        require(
            newAmountForLink <= 10 * 10**18,
            'Too Many To Liquidate'
        );
        amountToLiquidateEachLotto = newAmountForLink;
    }

    function upgradeRouter(address newRouter) external onlyOwner {
        router = IUniswapV2Router02(newRouter);
    }

    function setLinkBuyer(address newBuyer) external onlyOwner {
        linkBuyer = newBuyer;
    }

    function getTickets(uint256 numTickets) external {

        // get cost
        uint cost = numTickets * currentTicketCost();
        address user = msg.sender;

        // amount received
        uint256 received = _transferIn(cost);
        require(
            received >= ( cost * 99 ) / 100,
            'Too Few Received'
        );

        // burn portion of received amount
        uint toBurn = ( received * burnPercentage ) / 100;
        if (toBurn > 0) {
            _burn(toBurn);
        }
        
        // Assign Ticket IDs To User
        for (uint i = 0; i < numTickets;) {
            ticketToUser[currentTicketID] = user;
            currentTicketID++;
            unchecked { ++i; }
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

        // liquidate amount of XUSD in contract for link
        _liquidateForLink();

        // start a new lotto, request random words
        _newLotto();        
    }


    /**
        Registers A New Lotto
        Changes The Day Timer
        Distributes Winnings
     */
    function _newLotto() internal {

        // reset day timer
        lastLottoStartTime = block.timestamp;

        // get random number and send rewards when callback is executed
        // the callback is called "fulfillRandomWords"
        // this will revert if VRF subscription is not set and funded.
        newLottoRequestID = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            3, // number of block confirmations before returning random value
            gasToCallRandom, // callback gas limit is dependent num of random values & gas used in callback
            2 // the number of random results to return
        );
    }

    function _transferIn(uint256 amount) internal returns (uint256) {
        require(
            IERC20(XUSD).allowance(msg.sender, address(this)) >= amount,
            'Insufficient Allowance'
        );
        uint256 before = balanceOf();
        require(
            IERC20(XUSD).transferFrom(
                msg.sender,
                address(this),
                amount
            ),
            'FAIL TRANSFER FROM'
        );
        uint256 After = balanceOf();
        require(
            After > before,
            'Zero Received'
        );
        return After - before;
    }

    function _burn(uint256 amount) internal {
        IXUSD(XUSD).burn(amount);
    }

    function _liquidateForLink() internal {

        // if link receiver is not specified, return out
        if (address(linkBuyer) == address(0)) {
            return;
        }

        // determine amount of XUSD to liquidate
        uint bal = balanceOf();
        uint toLiquidate = amountToLiquidateEachLotto > bal ? bal : amountToLiquidateEachLotto;

        // return out if insufficient balance
        if (toLiquidate <= 10**9) {
            return;
        }

        // send amount to link buyer contract
        IERC20(XUSD).transfer(linkBuyer, toLiquidate);
    }

    /**
        Chainlink's callback to provide us with randomness
     */
    function fulfillRandomWords(
        uint256 requestId, /* requestId */
        uint256[] memory randomWords
    ) internal override {

        if (requestId == newLottoRequestID) {

            // determine if house wins or no one wins
            uint winIndex = randomWords[1] % 100;
            bool noOneWins = winIndex < nobodyWinsEdge;

            // select the winner based on edge, or the random number generated
            address winner;
            if (noOneWins) {
                winner = address(0);
            } else {
                winner = currentTicketID > 0 ? ticketToUser[randomWords[0] % currentTicketID] : address(0);
            }

            // handle no-one wins (burn XUSD)
            uint256 pot = amountToWin();

            // save history
            lottoHistory[currentLottoID].winner = winner;
            lottoHistory[currentLottoID].amountWon = pot;

            // reset lotto time again
            lastLottoStartTime = block.timestamp;
            
            // increment the current lotto ID
            currentLottoID++;

            if (pot == 0) {
                return;
            }
            
            // give winner
            if (winner != address(0)) {

                // Send winner the pot
                require(
                    IERC20(XUSD).transfer(winner, pot),
                    'Failure On XUSD Transfer'
                );

                // Emit Winning Event
                emit WinnerChosen(winner, pot);

            } else {

                // burn XUSD
                _burn(pot);

                // emit event
                emit NobodyWins();
            }
            
            // reset ticket IDs back to 0
            delete currentTicketID;
        }
    }

    function amountToWin() public view returns (uint256) {
        return ( balanceOf() * ( 100 - rollOverPercentage ) ) / 100;
    }

    function currentTicketCost() public view returns (uint256) {
        uint256 epochsSinceLastLotto = block.timestamp > lastLottoStartTime ? ( block.timestamp - lastLottoStartTime ) / timePeriodForCostIncrease : 0;
        return startingCostPerTicket + ( epochsSinceLastLotto * costIncreasePerTimePeriod );
    }

    function timeUntilNewLotto() public view returns (uint256) {
        uint endTime = lastLottoStartTime + lottoDuration;
        return block.timestamp >= endTime ? 0 : endTime - block.timestamp;
    }

    function getOdds(address user) public view returns (uint256, uint256, uint256) {

        uint nTickets;
        for (uint i = 0; i < currentTicketID;) {

            if (ticketToUser[i] == user) {
                nTickets++;
            }

            unchecked {
                ++i;
            }
        }
        return (nTickets, currentTicketID, nobodyWinsEdge);
    }

    function getPastWinners(uint256 numWinners) external view returns (address[] memory) {
        address[] memory winners = new address[](numWinners);
        if (currentLottoID < numWinners || numWinners == 0) {
            return winners;
        }
        for (uint i = currentLottoID - 1; i > currentLottoID - ( 1 + numWinners);) {
            winners[i] = lottoHistory[i].winner;
            unchecked { --i; }
        }
        return winners;
    }

    function balanceOf() public view returns (uint256) {
        return IERC20(XUSD).balanceOf(address(this));
    }

    receive() external payable{
        (bool s,) = payable(XUSD).call{value: address(this).balance}("");
        require(s, 'XUSD Purchase Failure');
    }
}