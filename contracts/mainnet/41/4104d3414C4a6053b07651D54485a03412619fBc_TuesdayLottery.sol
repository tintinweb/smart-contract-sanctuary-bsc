/**
 *Submitted for verification at BscScan.com on 2022-10-05
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}
pragma solidity ^0.8.0;

interface VRFCoordinatorV2Interface {
    /**
     * @notice Get configuration relevant for making requests
     * @return minimumRequestConfirmations global min for request confirmations
     * @return maxGasLimit global max for request gas limit
     * @return s_provingKeyHashes list of registered key hashes
     */
    function getRequestConfig()
        external
        view
        returns (
            uint16,
            uint32,
            bytes32[] memory
        );

    /**
     * @notice Request a set of random words.
     * @param keyHash - Corresponds to a particular oracle job which uses
     * that key for generating the VRF proof. Different keyHash's have different gas price
     * ceilings, so you can select a specific one to bound your maximum per request cost.
     * @param subId  - The ID of the VRF subscription. Must be funded
     * with the minimum subscription balance required for the selected keyHash.
     * @param minimumRequestConfirmations - How many blocks you'd like the
     * oracle to wait before responding to the request. See SECURITY CONSIDERATIONS
     * for why you may want to request more. The acceptable range is
     * [minimumRequestBlockConfirmations, 200].
     * @param callbackGasLimit - How much gas you'd like to receive in your
     * fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords
     * may be slightly less than this amount because of gas used calling the function
     * (argument decoding etc.), so you may need to request slightly more than you expect
     * to have inside fulfillRandomWords. The acceptable range is
     * [0, maxGasLimit]
     * @param numWords - The number of uint256 random values you'd like to receive
     * in your fulfillRandomWords callback. Note these numbers are expanded in a
     * secure way by the VRFCoordinator from a single random value supplied by the oracle.
     * @return requestId - A unique identifier of the request. Can be used to match
     * a request to a response in fulfillRandomWords.
     */
    function requestRandomWords(
        bytes32 keyHash,
        uint64 subId,
        uint16 minimumRequestConfirmations,
        uint32 callbackGasLimit,
        uint32 numWords
    ) external returns (uint256 requestId);

    /**
     * @notice Create a VRF subscription.
     * @return subId - A unique subscription id.
     * @dev You can manage the consumer set dynamically with addConsumer/removeConsumer.
     * @dev Note to fund the subscription, use transferAndCall. For example
     * @dev  LINKTOKEN.transferAndCall(
     * @dev    address(COORDINATOR),
     * @dev    amount,
     * @dev    abi.encode(subId));
     */
    function createSubscription() external returns (uint64 subId);

    /**
     * @notice Get a VRF subscription.
     * @param subId - ID of the subscription
     * @return balance - LINK balance of the subscription in juels.
     * @return reqCount - number of requests for this subscription, determines fee tier.
     * @return owner - owner of the subscription.
     * @return consumers - list of consumer address which are able to use this subscription.
     */
    function getSubscription(uint64 subId)
        external
        view
        returns (
            uint96 balance,
            uint64 reqCount,
            address owner,
            address[] memory consumers
        );

    /**
     * @notice Request subscription owner transfer.
     * @param subId - ID of the subscription
     * @param newOwner - proposed new owner of the subscription
     */
    function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner)
        external;

    /**
     * @notice Request subscription owner transfer.
     * @param subId - ID of the subscription
     * @dev will revert if original owner of subId has
     * not requested that msg.sender become the new owner.
     */
    function acceptSubscriptionOwnerTransfer(uint64 subId) external;

    /**
     * @notice Add a consumer to a VRF subscription.
     * @param subId - ID of the subscription
     * @param consumer - New consumer which can use the subscription
     */
    function addConsumer(uint64 subId, address consumer) external;

    /**
     * @notice Remove a consumer from a VRF subscription.
     * @param subId - ID of the subscription
     * @param consumer - Consumer to remove from the subscription
     */
    function removeConsumer(uint64 subId, address consumer) external;

    /**
     * @notice Cancel a subscription
     * @param subId - ID of the subscription
     * @param to - Where to send the remaining LINK to
     */
    function cancelSubscription(uint64 subId, address to) external;

    /*
     * @notice Check to see if there exists a request commitment consumers
     * for all consumers and keyhashes for a given sub.
     * @param subId - ID of the subscription
     * @return true if there exists at least one unfulfilled request for the subscription, false
     * otherwise.
     */
    function pendingRequestExists(uint64 subId) external view returns (bool);
}

pragma solidity ^0.8.4;

/** ****************************************************************************
 * @notice Interface for contracts using VRF randomness
 * *****************************************************************************
 * @dev PURPOSE
 *
 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness
 * @dev to Vera the verifier in such a way that Vera can be sure he's not
 * @dev making his output up to suit himself. Reggie provides Vera a public key
 * @dev to which he knows the secret key. Each time Vera provides a seed to
 * @dev Reggie, he gives back a value which is computed completely
 * @dev deterministically from the seed and the secret key.
 *
 * @dev Reggie provides a proof by which Vera can verify that the output was
 * @dev correctly computed once Reggie tells it to her, but without that proof,
 * @dev the output is indistinguishable to her from a uniform random sample
 * @dev from the output space.
 *
 * @dev The purpose of this contract is to make it easy for unrelated contracts
 * @dev to talk to Vera the verifier about the work Reggie is doing, to provide
 * @dev simple access to a verifiable source of randomness. It ensures 2 things:
 * @dev 1. The fulfillment came from the VRFCoordinator
 * @dev 2. The consumer contract implements fulfillRandomWords.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constructor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash). Create subscription, fund it
 * @dev and your consumer contract as a consumer of it (see VRFCoordinatorInterface
 * @dev subscription management functions).
 * @dev Call requestRandomWords(keyHash, subId, minimumRequestConfirmations,
 * @dev callbackGasLimit, numWords),
 * @dev see (VRFCoordinatorInterface for a description of the arguments).
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomWords method.
 *
 * @dev The randomness argument to fulfillRandomWords is a set of random words
 * @dev generated from your requestId and the blockHash of the request.
 *
 * @dev If your contract could have concurrent requests open, you can use the
 * @dev requestId returned from requestRandomWords to track which response is associated
 * @dev with which randomness request.
 * @dev See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ.
 *
 * *****************************************************************************
 * @dev SECURITY CONSIDERATIONS
 *
 * @dev A method with the ability to call your fulfillRandomness method directly
 * @dev could spoof a VRF response with any random value, so it's critical that
 * @dev it cannot be directly called by anything other than this base contract
 * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).
 *
 * @dev For your users to trust that your contract's random behavior is free
 * @dev from malicious interference, it's best if you can write it so that all
 * @dev behaviors implied by a VRF response are executed *during* your
 * @dev fulfillRandomness method. If your contract must store the response (or
 * @dev anything derived from it) and use it later, you must ensure that any
 * @dev user-significant behavior which depends on that stored value cannot be
 * @dev manipulated by a subsequent VRF request.
 *
 * @dev Similarly, both miners and the VRF oracle itself have some influence
 * @dev over the order in which VRF responses appear on the blockchain, so if
 * @dev your contract could have multiple VRF requests in flight simultaneously,
 * @dev you must ensure that the order in which the VRF responses arrive cannot
 * @dev be used to manipulate your contract's user-significant behavior.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request. It is for this reason that
 * @dev that you can signal to an oracle you'd like them to wait longer before
 * @dev responding to the request (however this is not enforced in the contract
 * @dev and so remains effective only in the case of unmodified oracle software).
 */
abstract contract VRFConsumerBaseV2 {
    error OnlyCoordinatorCanFulfill(address have, address want);
    address private immutable vrfCoordinator;

    /**
     * @param _vrfCoordinator address of VRFCoordinator contract
     */
    constructor(address _vrfCoordinator) {
        vrfCoordinator = _vrfCoordinator;
    }

    /**
     * @notice fulfillRandomness handles the VRF response. Your contract must
     * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
     * @notice principles to keep in mind when implementing your fulfillRandomness
     * @notice method.
     *
     * @dev VRFConsumerBaseV2 expects its subcontracts to have a method with this
     * @dev signature, and will call it once it has verified the proof
     * @dev associated with the randomness. (It is triggered via a call to
     * @dev rawFulfillRandomness, below.)
     *
     * @param requestId The Id initially returned by requestRandomness
     * @param randomWords the VRF output expanded to the requested number of words
     */
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        virtual;

    // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
    // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
    // the origin of the call
    function rawFulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) external {
        if (msg.sender != vrfCoordinator) {
            revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
        }
        fulfillRandomWords(requestId, randomWords);
    }
}
pragma solidity ^0.8.7;

contract TuesdayLottery is ReentrancyGuard,VRFConsumerBaseV2 {
    struct guessRandomNumberAndStars {
        uint256 number1;
        uint256 number2;
        uint256 number3;
        uint256 number4;
        uint256 number5;
        uint256 star1;
        uint256 star2;
    }
    struct guessInfo {
        guessRandomNumberAndStars guess;
        address user;
    }
    struct distributionPercentage {
        uint16 prize1;
        uint16 prize2;
        uint16 prize3;
        uint16 prize4;
        uint16 prize5;
        uint16 prize6;
    }

    struct totalPrize {
        uint256 totalPrize1Winner;
        uint256 totalPrize2Winner;
        uint256 totalPrize3Winner;
        uint256 totalPrize4Winner;
        uint256 totalPrize5Winner;
        uint256 totalPrize6Winner;
    }
    struct prizes {
        uint256 prize1;
        uint256 prize2;
        uint256 prize3;
        uint256 prize4;
        uint256 prize5;
        uint256 prize6;
    }
    struct historyOfPrizeWinners {
        uint256 prize1Winners;
        uint256 prize2Winners;
        uint256 prize3Winners;
        uint256 prize4Winners;
        uint256 prize5Winners;
        uint256 prize6Winners;
    }
    struct historyOfPrizePerPersonAmount {
        uint256 prize1PerPersonAmount;
        uint256 prize2PerPersonAmount;
        uint256 prize3PerPersonAmount;
        uint256 prize4PerPersonAmount;
        uint256 prize5PerPersonAmount;
        uint256 prize6PerPersonAmount;
    }

    struct historyOfPrizeTotalAmount {
        uint256 totalPoolPrize;
        uint256 drawnDate;
        uint256 totalPlayers;
        uint256 prize1TotalAmount;
        uint256 prize2TotalAmount;
        uint256 prize3TotalAmount;
        uint256 prize4TotalAmount;
        uint256 prize5TotalAmount;
        uint256 prize6TotalAmount;
        uint256 maintenanceStakeAndGoodCausesAmount;
    }
    struct historyOfWinnigNumber {
        uint256 number1;
        uint256 number2;
        uint256 number3;
        uint256 number4;
        uint256 number5;
        uint256 star1;
        uint256 star2;
    }
    struct roundInfoPerPerson {
        guessRandomNumberAndStars guessNumbersAndStars;
        uint256 ticketNumber;
        uint8 lotteryType;
    }

    struct Distribute {
        uint256 winningIndex;
        uint256 wininnigCategory;
        uint256 winningPrice;
        bool status;
        uint8 lotteryType;
    }
    struct Ticketwinner {
        uint256 winningIndex;
        uint256 wininnigCategory;
        bool status;
        uint8 lotteryType;
        uint256 ticketNumber;
    }

    struct roundHistory {
        historyOfWinnigNumber historyOfWinningNumbers;
        historyOfPrizeTotalAmount historyOfPrizeTotalAmount;
        historyOfPrizePerPersonAmount historyOfPrizePerPersonAmount;
        historyOfPrizeWinners historyOfPrizeWinners;
    }
    
    address public owner;
    uint256 public ticketPrice;
    IERC20 public usdt;

    mapping(uint256 => guessInfo) public guessInfos; //random guess numbers and stars by players
    uint256 public guessCount; //number of tickets

    uint16 public constant maintenanceStakeAndGoodCausesFee=2000;
    address public maintenanceStakeAndGoodCauses;

     distributionPercentage public distributionFee = //distribution fee for each prize winner
        distributionPercentage(
            4000, //distributionFee1
            2000, //distributionFee2
            1000, //distributionFee3
            500, //distributionFee4
            300, //distributionFee5
            200 //distributionFee6
        ); 
    guessRandomNumberAndStars private winningNumbersAndStars;

    uint256 public roundNumber=1;
    uint256 public lotteryStartTime;
    uint256 public lotteryEndTime;
    uint256 public cooldownTime;
    bool public isLotteryStarted=true;
    bool public isTicketCanBeSold=true;
    bool public isFridayLotteryActive=true;
    mapping(address => uint256) public buyTickets;
    address public fridayLotteryAddress;
    VRFCoordinatorV2Interface public constant i_vrfCoordinator=VRFCoordinatorV2Interface(0xc587d9053cd1118f25F645F9E08BB98c9712A4EE);
    bytes32 public constant i_gasLane=bytes32(0x17cd473250a9a479dc7f234c64332ed4bc8af9e8ded7556aa6e66d83da49f470);
    uint64 public immutable s_subscriptionId;
    uint32 public constant i_callbackGasLimit=500000;
    uint16 public constant requestConfirmations = 3;
    uint32 public constant numWords =  7;

    modifier checkTicketSold(address buyer, uint256 guesses) {
        require(buyTickets[buyer] >= 1, "Please Buy Ticket First");
        require(
            buyTickets[buyer] >= guesses,
            "You have not enough tickets to add these lucky numbers"
        );
        _;
    }
    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner Allowed");
        _;
    }

    modifier checkLotteryStarted() {
        require(isLotteryStarted != false, "The Lottery Is Not Started Yet!");
        _;
    }
    event TicketBought(address indexed buyer, uint256 tickets);
    event TicketGuessed(
        uint256 indexed roundNumber,
        address indexed buyer,
        roundInfoPerPerson info
    );
    event DistributePrize(
        uint256 indexed roundNumber,
        address indexed winner,
        Distribute info
    );
    event TicketWinner(
        uint256 indexed roundNumber,
        address indexed winner,
        Ticketwinner info
    );

    event RoundHistory(
        uint256 roundNumber,
        roundHistory info,
        uint8 lotteryType
    );
    event RequestId(uint256 _id);
    constructor(
        address _owner,
        address _usdt,
        address _maintenanceStakeAndGoodCauses,
        uint256 _ticketPrice,
        uint256 _cooldownTime,
        uint256 _lotteryStartTime,
        uint64 _subscriptionId
    ) VRFConsumerBaseV2(0xc587d9053cd1118f25F645F9E08BB98c9712A4EE) ReentrancyGuard()  {
        owner = _owner;
        usdt = IERC20(_usdt);
        maintenanceStakeAndGoodCauses = _maintenanceStakeAndGoodCauses;
        ticketPrice = _ticketPrice;
        cooldownTime = _cooldownTime;
        lotteryStartTime = _lotteryStartTime;
        lotteryEndTime = _lotteryStartTime + 7 days;
        s_subscriptionId = _subscriptionId;
    }

    function buyTicket() external checkLotteryStarted {
        require(
            block.timestamp > (lotteryStartTime + cooldownTime),
            "The Lottery Is Not Started Yet!"
        );

        require(block.timestamp <= lotteryEndTime, "The Lottery has ended!");

        require(
            isTicketCanBeSold != false,
            "Tickets sale is closed for this draw"
        );

        uint256 _ticketPrice = ticketPrice;
        uint256 allowance = usdt.allowance(msg.sender, address(this));
        require(allowance >= _ticketPrice, "You do not have enough allowance");
        uint256 totalTickets = allowance / _ticketPrice;
        bool success = usdt.transferFrom(
            msg.sender,
            address(this),
            (totalTickets * _ticketPrice)
        );
        require(success, "Usdt Transfer Failed");
        buyTickets[msg.sender] += totalTickets;
        emit TicketBought(msg.sender, totalTickets);
    }

    function addGuessNumber(
        guessRandomNumberAndStars[] calldata _guessNumberAndStars
    )
        external
        checkLotteryStarted
        checkTicketSold(msg.sender, _guessNumberAndStars.length)
    {
        require(
            block.timestamp > (lotteryStartTime + cooldownTime),
            "The Lottery Is Not Started Yet!"
        );

        require(block.timestamp <= lotteryEndTime, "The Lottery has ended!");
        require(
            isTicketCanBeSold != false,
            "Add Lucky Number is closed for this draw"
        );

        uint256 len = _guessNumberAndStars.length;
        uint256 _buyTickets = buyTickets[msg.sender];
        uint256 _guessCount = guessCount;

        for (uint256 i = 0; i < len; ) {
            guessRandomNumberAndStars
                calldata _numbersAndStars = _guessNumberAndStars[i];
            require(
                (_numbersAndStars.number1 != 0 &&
                    _numbersAndStars.number2 != 0 &&
                    _numbersAndStars.number3 != 0 &&
                    _numbersAndStars.number4 != 0 &&
                    _numbersAndStars.number5 != 0 &&
                    _numbersAndStars.star1 != 0 &&
                    _numbersAndStars.star2 != 0),
                "Lucky Numbers And Stars Cannot Be Zero"
            );
            require(
                ((_numbersAndStars.number1 != _numbersAndStars.number2 &&
                    _numbersAndStars.number1 != _numbersAndStars.number3 &&
                    _numbersAndStars.number1 != _numbersAndStars.number4 &&
                    _numbersAndStars.number1 != _numbersAndStars.number5) &&
                    (
                        (_numbersAndStars.number2 != _numbersAndStars.number3 &&
                            _numbersAndStars.number2 !=
                            _numbersAndStars.number4 &&
                            _numbersAndStars.number2 !=
                            _numbersAndStars.number5)
                    ) &&
                    (
                        (_numbersAndStars.number3 != _numbersAndStars.number4 &&
                            _numbersAndStars.number3 !=
                            _numbersAndStars.number5)
                    ) &&
                    ((_numbersAndStars.number4 != _numbersAndStars.number5)) &&
                    (_numbersAndStars.star1 != _numbersAndStars.star2)),
                "Lucky Numbers And Stars Must Be Unique Numbers"
            );

            guessInfos[_guessCount] = guessInfo(
                guessRandomNumberAndStars(
                    _numbersAndStars.number1,
                    _numbersAndStars.number2,
                    _numbersAndStars.number3,
                    _numbersAndStars.number4,
                    _numbersAndStars.number5,
                    _numbersAndStars.star1,
                    _numbersAndStars.star2
                ),
                msg.sender
            );
            emit TicketGuessed(
                roundNumber,
                msg.sender,
                roundInfoPerPerson(
                    guessRandomNumberAndStars(
                        _numbersAndStars.number1,
                        _numbersAndStars.number2,
                        _numbersAndStars.number3,
                        _numbersAndStars.number4,
                        _numbersAndStars.number5,
                        _numbersAndStars.star1,
                        _numbersAndStars.star2
                    ),
                    _guessCount,
                    0
                )
            );
            --_buyTickets;
            ++_guessCount;
            unchecked {
                ++i;
            }
        }
        buyTickets[msg.sender] = _buyTickets;
        guessCount = _guessCount;
    }

    function generateWinningNumber()external checkLotteryStarted onlyOwner{

        require(
            block.timestamp >= lotteryEndTime,
            "Lottery Is Not Ended Yet!"
        );
        require(
            winningNumbersAndStars.number1 == 0,
            "Winning Numbers Already Added"
        );

        uint256 requestId=i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            s_subscriptionId,
            requestConfirmations,
            i_callbackGasLimit,
            numWords
        );
        emit RequestId(requestId);
    }

    function fulfillRandomWords(
            uint256, /* requestId */
            uint256[] memory randomWords
        ) internal override {
        guessRandomNumberAndStars memory _winningNumbersAndStars = guessRandomNumberAndStars(
            (randomWords[0]%50)+1,
            (randomWords[1]%50)+1,
            (randomWords[2]%50)+1,
            (randomWords[3]%50)+1,
            (randomWords[4]%50)+1,
            (randomWords[5]%12)+1,
            (randomWords[6]%12)+1
        );
            require(
            (_winningNumbersAndStars.number1 != 0 &&
                _winningNumbersAndStars.number2 != 0 &&
                _winningNumbersAndStars.number3 != 0 &&
                _winningNumbersAndStars.number4 != 0 &&
                _winningNumbersAndStars.number5 != 0 &&
                _winningNumbersAndStars.star1 != 0 &&
                _winningNumbersAndStars.star2 != 0),
            "Winning Numbers And Stars Cannot Be Zero"
        );

        require(
            ((_winningNumbersAndStars.number1 != _winningNumbersAndStars.number2 &&
                _winningNumbersAndStars.number1 != _winningNumbersAndStars.number3 &&
                _winningNumbersAndStars.number1 != _winningNumbersAndStars.number4 &&
                _winningNumbersAndStars.number1 != _winningNumbersAndStars.number5) &&
                (
                    (_winningNumbersAndStars.number2 != _winningNumbersAndStars.number3 &&
                        _winningNumbersAndStars.number2 != _winningNumbersAndStars.number4 &&
                        _winningNumbersAndStars.number2 != _winningNumbersAndStars.number5)
                ) &&
                ((_winningNumbersAndStars.number3 != _winningNumbersAndStars.number4 && _winningNumbersAndStars.number3 != _winningNumbersAndStars.number5)) &&
                ((_winningNumbersAndStars.number4 != _winningNumbersAndStars.number5)) &&
                (_winningNumbersAndStars.star1 != _winningNumbersAndStars.star2)),
            "Winning Numbers And Stars Must Be Unique Numbers"
        );
        winningNumbersAndStars = _winningNumbersAndStars;
        }
    function annouceWinner() external checkLotteryStarted nonReentrant onlyOwner {
        uint256 _lotteryEndTime = lotteryEndTime;
        require(
            block.timestamp >= _lotteryEndTime,
            "Lottery Is Not Ended Yet!"
        );
        require(
            (winningNumbersAndStars.number1 != 0 &&
                winningNumbersAndStars.number2 != 0 &&
                winningNumbersAndStars.number3 != 0 &&
                winningNumbersAndStars.number4 != 0 &&
                winningNumbersAndStars.number5 != 0 &&
                winningNumbersAndStars.star1 != 0 &&
                winningNumbersAndStars.star2 != 0),
            "Please Generate Winning Numbers Before Annoucing The Winners"
        );
        (
            totalPrize memory winners,
            address[] memory prize1Winner,
            address[] memory prize2Winner,
            address[] memory prize3Winner,
            address[] memory prize4Winner,
            address[] memory prize5Winner,
            address[] memory prize6Winner
        ) = getWinners();

        uint256 poolPrize = usdt.balanceOf(address(this));
        distributionPercentage memory distributionFees = distributionFee;

        prizes memory prize = prizes(0, 0, 0, 0, 0, 0);

        prize.prize1 = (poolPrize * distributionFees.prize1) / 10000;
        prize.prize2 = (poolPrize * distributionFees.prize2) / 10000;
        prize.prize3 = (poolPrize * distributionFees.prize3) / 10000;
        prize.prize4 = (poolPrize * distributionFees.prize4) / 10000;
        prize.prize5 = (poolPrize * distributionFees.prize5) / 10000;
        prize.prize6 = (poolPrize * distributionFees.prize6) / 10000;
        uint256 maintenanceStakeAndGoodCausesAmount = (poolPrize *
            maintenanceStakeAndGoodCausesFee) / 10000;

        if (winners.totalPrize1Winner > 0) {
            distributePrize(
                winners.totalPrize1Winner,
                prize1Winner,
                prize.prize1,
                1
            );
        }
        if (winners.totalPrize2Winner > 0) {
            distributePrize(
                winners.totalPrize2Winner,
                prize2Winner,
                prize.prize2,
                2
            );
        }
        if (winners.totalPrize3Winner > 0) {
            distributePrize(
                winners.totalPrize3Winner,
                prize3Winner,
                prize.prize3,
                3
            );
        }
        if (winners.totalPrize4Winner > 0) {
            distributePrize(
                winners.totalPrize4Winner,
                prize4Winner,
                prize.prize4,
                4
            );
        }
        if (winners.totalPrize5Winner > 0) {
            distributePrize(
                winners.totalPrize5Winner,
                prize5Winner,
                prize.prize5,
                5
            );
        }
        if (winners.totalPrize6Winner > 0) {
            distributePrize(
                winners.totalPrize6Winner,
                prize6Winner,
                prize.prize6,
                6
            );
        }

        sendMaintenanceStakeAndGoodCausesAmount(
            maintenanceStakeAndGoodCausesAmount
        );
        totalPrize memory _totalPrizeWinner = totalPrize(
            winners.totalPrize1Winner,
            winners.totalPrize2Winner,
            winners.totalPrize3Winner,
            winners.totalPrize4Winner,
            winners.totalPrize5Winner,
            winners.totalPrize6Winner
        );
        historyOfPrizeWinners memory historyOfLotteryPrizeWinnerss = historyOfPrizeWinners(
            _totalPrizeWinner.totalPrize1Winner, //prize1Winners,
            _totalPrizeWinner.totalPrize2Winner, //prize2Winners,
            _totalPrizeWinner.totalPrize3Winner, //prize3Winners,
            _totalPrizeWinner.totalPrize4Winner, //prize4Winners,
            _totalPrizeWinner.totalPrize5Winner, //prize5Winners,
            _totalPrizeWinner.totalPrize6Winner //prize6Winners,
        );
        historyOfPrizePerPersonAmount memory historyOfPrizePerPersonAmountss = historyOfPrizePerPersonAmount(
            calculatePrize(prize.prize1, _totalPrizeWinner.totalPrize1Winner), //prize1PerPersonAmount,
            calculatePrize(prize.prize2, _totalPrizeWinner.totalPrize2Winner), //prize2PerPersonAmount,
            calculatePrize(prize.prize3, _totalPrizeWinner.totalPrize3Winner), //prize3PerPersonAmount,
            calculatePrize(prize.prize4, _totalPrizeWinner.totalPrize4Winner), //prize4PerPersonAmount,
            calculatePrize(prize.prize5, _totalPrizeWinner.totalPrize5Winner), //prize5PerPersonAmount,
            calculatePrize(prize.prize6, _totalPrizeWinner.totalPrize6Winner) //prize6PerPersonAmount
        );

        historyOfPrizeTotalAmount memory historyOfPrizeTotalAmountss = historyOfPrizeTotalAmount(
            poolPrize, //totalPrize,
            block.timestamp,
            guessCount,
            prize.prize1, //prize1PerPersonAmount,
            prize.prize2, //prize2PerPersonAmount,
            prize.prize3, //prize3PerPersonAmount,
            prize.prize4, //prize4PerPersonAmount,
            prize.prize5, //prize5PerPersonAmount,
            prize.prize6, //prize6PerPersonAmount,
            maintenanceStakeAndGoodCausesAmount //maintenanceStakeAndGoodCausesAmount
        );

        historyOfWinnigNumber memory historyOfWinningNumberss = historyOfWinnigNumber(
            winningNumbersAndStars.number1, //number1,
            winningNumbersAndStars.number2, //number2,
            winningNumbersAndStars.number3, //number3,
            winningNumbersAndStars.number4, //number4,
            winningNumbersAndStars.number5, //number5,
            winningNumbersAndStars.star1, //star1,
            winningNumbersAndStars.star2 //star2,
        );

        emit RoundHistory(
            roundNumber,
            roundHistory(
                historyOfWinningNumberss,
                historyOfPrizeTotalAmountss,
                historyOfPrizePerPersonAmountss,
                historyOfLotteryPrizeWinnerss
            ),
            0
        );
        
        // reset lottery for new round
        guessCount = 0;
        lotteryStartTime = lotteryEndTime;
        lotteryEndTime = (lotteryEndTime + 7 days);
        winningNumbersAndStars = guessRandomNumberAndStars(0, 0, 0, 0, 0, 0, 0);
        ++roundNumber;

        //Roll Over Amount To next draw if friday lottery is activated or not
        if (isFridayLotteryActive) {
            bool success = usdt.transfer( fridayLotteryAddress, usdt.balanceOf(address(this)));
            require(success, "Roll Over Failed!");
        }    
    }

    function calculatePrize(uint256 prize, uint256 total)
        private
        pure
        returns (uint256)
    {
        if (total > 0) {
            return prize / total;
        } else {
            return prize;
        }
    }

    function distributePrize(
        uint256 _totalWinner,
        address[] memory winners,
        uint256 prize,
        uint256 _wininnigCategory
    ) private {
        uint256 amountPerWinner = prize / _totalWinner;
        for (uint256 i = 0; i < _totalWinner; ) {
            emit DistributePrize(
                roundNumber,
                winners[i],
                Distribute(i, _wininnigCategory, amountPerWinner, true, 0)
            );
            bool success = usdt.transfer(winners[i], amountPerWinner);
            require(success, "Usdt Transfer Failed!");
            unchecked {
                ++i;
            }
        }
    }

    function sendMaintenanceStakeAndGoodCausesAmount(uint256 _amount) private {
        bool success = usdt.transfer(maintenanceStakeAndGoodCauses, _amount);
        require(success, "Usdt Transfer Failed!");
    }

    function getWinners()
        private
        returns (
            totalPrize memory prizeWinner,
            address[] memory prize1Winner,
            address[] memory prize2Winner,
            address[] memory prize3Winner,
            address[] memory prize4Winner,
            address[] memory prize5Winner,
            address[] memory prize6Winner
        )
    {
        uint256 totalTickets = guessCount;

        prize1Winner = new address[](totalTickets);
        prize2Winner = new address[](totalTickets);
        prize3Winner = new address[](totalTickets);
        prize4Winner = new address[](totalTickets);
        prize5Winner = new address[](totalTickets);
        prize6Winner = new address[](totalTickets);

        {
            for (uint256 i = 0; i < totalTickets; ) {
                uint8 matchedNumber = 0;
                uint8 matchedStar = 0;
                guessInfo memory guess = guessInfos[i];
                if (
                    guess.guess.number1 == winningNumbersAndStars.number1 ||
                    guess.guess.number1 == winningNumbersAndStars.number2 ||
                    guess.guess.number1 == winningNumbersAndStars.number3 ||
                    guess.guess.number1 == winningNumbersAndStars.number4 ||
                    guess.guess.number1 == winningNumbersAndStars.number5
                ) {
                    ++matchedNumber;
                }
                if (
                    guess.guess.number2 == winningNumbersAndStars.number1 ||
                    guess.guess.number2 == winningNumbersAndStars.number2 ||
                    guess.guess.number2 == winningNumbersAndStars.number3 ||
                    guess.guess.number2 == winningNumbersAndStars.number4 ||
                    guess.guess.number2 == winningNumbersAndStars.number5
                ) {
                    ++matchedNumber;
                }
                if (
                    guess.guess.number3 == winningNumbersAndStars.number1 ||
                    guess.guess.number3 == winningNumbersAndStars.number3 ||
                    guess.guess.number3 == winningNumbersAndStars.number3 ||
                    guess.guess.number3 == winningNumbersAndStars.number4 ||
                    guess.guess.number3 == winningNumbersAndStars.number5
                ) {
                    ++matchedNumber;
                }
                if (
                    guess.guess.number4 == winningNumbersAndStars.number1 ||
                    guess.guess.number4 == winningNumbersAndStars.number4 ||
                    guess.guess.number4 == winningNumbersAndStars.number3 ||
                    guess.guess.number4 == winningNumbersAndStars.number4 ||
                    guess.guess.number4 == winningNumbersAndStars.number5
                ) {
                    ++matchedNumber;
                }
                if (
                    guess.guess.number5 == winningNumbersAndStars.number1 ||
                    guess.guess.number5 == winningNumbersAndStars.number5 ||
                    guess.guess.number5 == winningNumbersAndStars.number3 ||
                    guess.guess.number5 == winningNumbersAndStars.number4 ||
                    guess.guess.number5 == winningNumbersAndStars.number5
                ) {
                    ++matchedNumber;
                }
                if (matchedNumber == 5) {
                    if (
                        guess.guess.star1 == winningNumbersAndStars.star1 ||
                        guess.guess.star1 == winningNumbersAndStars.star2
                    ) {
                        ++matchedStar;
                    }
                    if (
                        guess.guess.star2 == winningNumbersAndStars.star1 ||
                        guess.guess.star2 == winningNumbersAndStars.star2
                    ) {
                        ++matchedStar;
                    }
                }
                if (matchedNumber == 5 && matchedStar == 2) {
                    uint256 winningIndex = prizeWinner.totalPrize1Winner;
                    emit TicketWinner(
                        roundNumber,
                        guess.user,
                        Ticketwinner(winningIndex, 1, true, 0, i)
                    );
                    prize1Winner[prizeWinner.totalPrize1Winner] = guess.user;
                    ++prizeWinner.totalPrize1Winner;
                } else if (matchedNumber == 5 && matchedStar == 1) {
                    uint256 winningIndex = prizeWinner.totalPrize2Winner;
                    emit TicketWinner(
                        roundNumber,
                        guess.user,
                        Ticketwinner(winningIndex, 2, true, 0, i)
                    );
                    prize2Winner[prizeWinner.totalPrize2Winner] = guess.user;
                    ++prizeWinner.totalPrize2Winner;
                } else if (matchedNumber == 5) {
                    uint256 winningIndex = prizeWinner.totalPrize3Winner;
                    emit TicketWinner(
                        roundNumber,
                        guess.user,
                        Ticketwinner(winningIndex, 3, true, 0, i)
                    );

                    prize3Winner[prizeWinner.totalPrize3Winner] = guess.user;
                    ++prizeWinner.totalPrize3Winner;
                } else if (matchedNumber == 4) {
                    uint256 winningIndex = prizeWinner.totalPrize4Winner;
                    emit TicketWinner(
                        roundNumber,
                        guess.user,
                        Ticketwinner(winningIndex, 4, true, 0, i)
                    );

                    prize4Winner[prizeWinner.totalPrize4Winner] = guess.user;
                    ++prizeWinner.totalPrize4Winner;
                } else if (matchedNumber == 3) {
                    uint256 winningIndex = prizeWinner.totalPrize5Winner;
                    emit TicketWinner(
                        roundNumber,
                        guess.user,
                        Ticketwinner(winningIndex, 5, true, 0, i)
                    );

                    prize5Winner[prizeWinner.totalPrize5Winner] = guess.user;
                    ++prizeWinner.totalPrize5Winner;
                } else if (matchedNumber == 2) {
                    uint256 winningIndex = prizeWinner.totalPrize6Winner;
                    emit TicketWinner(
                        roundNumber,
                        guess.user,
                        Ticketwinner(winningIndex, 6, true, 0, i)
                    );
                    prize6Winner[prizeWinner.totalPrize6Winner] = guess.user;
                    ++prizeWinner.totalPrize6Winner;
                }
                unchecked {
                    ++i;
                }
            }
        }
    }

    function changeTicketPrice(uint256 _price) external onlyOwner {
        require(_price > 0, "Ticket price must be greater than 0");

        ticketPrice = _price;
    }

    function getMaintenanceStakeAndGoodCausesFee()
        external
        pure
        returns (uint16)
    {
        return maintenanceStakeAndGoodCausesFee;
    }

    function changeMaintenanceStakeAndGoodCausesAddress(
        address _maintenanceStakeAndGoodCausesAddress
    ) external onlyOwner {
        maintenanceStakeAndGoodCauses = _maintenanceStakeAndGoodCausesAddress;
    }

    function getDistributionFee()
        external
        view
        returns (distributionPercentage memory)
    {
        return distributionFee;
    }

    function getBalance() external view returns (uint256) {
        return usdt.balanceOf(address(this));
    }

    function setIsTicketCanBeSold(bool _isTicketCanBeSold)
        external
        onlyOwner
        checkLotteryStarted
    {
        isTicketCanBeSold = _isTicketCanBeSold;
    }

    function setLotteryStartTime(uint256 _lotteryStartTime)
        external
        onlyOwner
        checkLotteryStarted
    {
        require(
            block.timestamp < _lotteryStartTime,
            "Lottery Start Time Cannot Be In The Past!"
        );

        lotteryStartTime = _lotteryStartTime;
        lotteryEndTime = lotteryStartTime + 7 days;
    }

    function setLotteryEndTime(uint256 _lotteryEndTime)
        external
        onlyOwner
        checkLotteryStarted
    {
        require(
            block.timestamp < _lotteryEndTime,
            "Lottery End Time Cannot Be In The Past!"
        );

        lotteryEndTime = _lotteryEndTime;
    }

    function setCooldownTime(uint256 _cooldownTime) external onlyOwner {
        cooldownTime = _cooldownTime;
    }

    function stopLottery() external onlyOwner checkLotteryStarted {
        require(
            guessCount == 0,
            "Please Annouce Winner Before Stopping The Lottery"
        );

        require(
            block.timestamp >= lotteryEndTime,
            "Lottery Cannot Be Stopped Before The Lottery End Time"
        );

        isLotteryStarted = false;
    }

    function startLottery(uint256 _lotteryStartTime) external onlyOwner {
        require(isLotteryStarted == false, "Lottery Has Already Started");

        require(
            block.timestamp < _lotteryStartTime,
            "Lottery Start Time Cannot Be In The Past!"
        );

        lotteryStartTime = _lotteryStartTime;
        lotteryEndTime = _lotteryStartTime + 7 days;
        isTicketCanBeSold = true;
        isLotteryStarted = true;
    }

    function getCurrentTotalPlayers() external view returns (uint256) {
        return guessCount;
    }

    function transferOwnerShip(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    function getTotalBuyTickets() external view returns (uint256) {
        return buyTickets[msg.sender];
    }

    function setFridayLotteryAddress(address _fridayLotteryAddress)
        external
        onlyOwner
    {
        fridayLotteryAddress = _fridayLotteryAddress;
    }

    function setFridayLotteryActive(bool _isActive) external onlyOwner {
        isFridayLotteryActive = _isActive;
    }
}