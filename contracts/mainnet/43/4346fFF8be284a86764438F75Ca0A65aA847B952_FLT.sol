/*
BEANMINE Games official links:

FLIPPY: https://flippy.beanmine.app - Web3 Games #

--------------------------------------
Web3 Games: https://games.beanmine.app
--------------------------------------

BUSD Rewards: https://beanmine.app
Telegram: https://t.me/beanmine
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./LinkTokenInterface.sol";
import "./VRFCoordinatorV2Interface.sol";
import "./VRFConsumerBaseV2.sol";

library Math {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function pow(uint256 a, uint256 b) internal pure returns (uint256) {
        return a**b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

contract FLT is Ownable, VRFConsumerBaseV2, ReentrancyGuard {
    VRFCoordinatorV2Interface COORDINATOR;
    LinkTokenInterface LINKTOKEN;

    /* Contract Information:
     ***********/

    address constant vrfCoordinator =
        0xc587d9053cd1118f25F645F9E08BB98c9712A4EE;
    address constant link_token_contract =
        0x404460C6A5EdE2D891e8297795264fDe62ADBB75;

    bytes32 private keyHash =
        0xba6e730de88d94a5510ae6613898bfb0c3de5d16e609c5b7da808747125506f7;
    uint16 constant requestConfirmations = 3;
    uint32 constant callbackGasLimit = 1e6;
    uint32 constant numWords = 1;
    uint64 subscriptionId;
    uint256 private contractBalance;
    uint256 private betCondTwoNumber = 4;
    uint256 private betCondFourNumber = 6;
    uint256 public totalAmountWon;
    mapping(address => uint256) private wonCount;
    mapping(address => uint256) private loseCount;

    struct Temp {
        uint256 id;
        uint256 result;
        address playerAddress;
        uint256 gameModeTemp;
    }

    struct PlayerByAddress {
        uint256 balance;
        uint256 betAmount;
        uint256 betChoice;
        address playerAddress;
        bool betOngoing;
    }

    mapping(address => PlayerByAddress) public playersByAddress;
    mapping(uint256 => Temp) public temps;

    /* Events:
     *********/

    event DepositToContract(
        address user,
        uint256 depositAmount,
        uint256 newBalance
    );
    event Withdrawal(address player, uint256 amount);
    event NewIdRequest(address indexed player, uint256 requestId);
    event GeneratedRandomNumberTwo(
        uint256 requestId,
        uint256 randomNumber,
        uint256 randomWordsGot
    );
    event GeneratedRandomNumberFour(
        uint256 requestId,
        uint256 randomNumber,
        uint256 randomWordsGot
    );
    event BetResult(address indexed player, bool victory, uint256 amount);

    /* Constructor:
     **************/

    constructor(uint64 _subscriptionId)
        payable
        initCosts(0.001 ether)
        VRFConsumerBaseV2(vrfCoordinator)
    {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        LINKTOKEN = LinkTokenInterface(link_token_contract);
        subscriptionId = _subscriptionId;
        contractBalance += msg.value;
    }

    /* Modifiers:
     ************/

    modifier initCosts(uint256 initCost) {
        require(msg.value >= initCost, "FLIPPY: Contract needs BNB");
        _;
    }

    modifier betConditionsTwo() {
        require(msg.value >= 0.001 ether, "FLIPPY: Minimum Bet is 0.001 BNB");
        require(
            msg.value <= getContractBalance() / betCondTwoNumber,
            "FLIPPY: Lower your Bet"
        );
        require(
            !playersByAddress[_msgSender()].betOngoing,
            "FLIPPY: Bet Already Ongoing..."
        );
        _;
    }

    modifier betConditionsFour() {
        require(msg.value >= 0.001 ether, "FLIPPY: Minimum Bet is 0.001 BNB");
        require(
            msg.value <= getContractBalance() / betCondFourNumber,
            "FLIPPY: Lower your Bet"
        );
        require(
            !playersByAddress[_msgSender()].betOngoing,
            "FLIPPY: Bet Already Ongoing..."
        );
        _;
    }

    /* Functions:
     *************/

    function betTwo(uint256 _betChoice)
        public
        payable
        betConditionsTwo
        nonReentrant
    {
        require(_betChoice == 0 || _betChoice == 1, "FLIPPY: Must be 0||1");

        address player = _msgSender();

        playersByAddress[player].playerAddress = player;
        playersByAddress[player].betChoice = _betChoice;
        playersByAddress[player].betOngoing = true;
        playersByAddress[player].betAmount = msg.value;
        contractBalance += playersByAddress[player].betAmount;

        uint256 requestId = requestRandomWords();
        temps[requestId].playerAddress = player;
        temps[requestId].id = requestId;
        temps[requestId].gameModeTemp = 0;

        emit NewIdRequest(player, requestId);
    }

    function betFour(uint256 _betChoice)
        public
        payable
        betConditionsFour
        nonReentrant
    {
        require(
            _betChoice == 0 ||
                _betChoice == 1 ||
                _betChoice == 2 ||
                _betChoice == 3,
            "FLIPPY: Must be 0||1||2||3"
        );

        address player = _msgSender();

        playersByAddress[player].playerAddress = player;
        playersByAddress[player].betChoice = _betChoice;
        playersByAddress[player].betOngoing = true;
        playersByAddress[player].betAmount = msg.value;
        contractBalance += playersByAddress[player].betAmount;

        uint256 requestId = requestRandomWords();
        temps[requestId].playerAddress = player;
        temps[requestId].id = requestId;
        temps[requestId].gameModeTemp = 1;

        emit NewIdRequest(player, requestId);
    }

    function requestRandomWords() public returns (uint256) {
        return
            COORDINATOR.requestRandomWords(
                keyHash,
                subscriptionId,
                requestConfirmations,
                callbackGasLimit,
                numWords
            );
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        if (temps[_requestId].gameModeTemp == 0) {
            uint256 randomResult = _randomWords[0] % 2;
            temps[_requestId].result = randomResult;
            emit GeneratedRandomNumberTwo(
                _requestId,
                randomResult,
                _randomWords[0]
            );

            checkResult(randomResult, _requestId);
        } else {
            uint256 randomResult = _randomWords[0] % 4;
            temps[_requestId].result = randomResult;
            emit GeneratedRandomNumberFour(
                _requestId,
                randomResult,
                _randomWords[0]
            );

            checkResult(randomResult, _requestId);
        }
    }

    function checkResult(uint256 _randomResult, uint256 _requestId)
        private
        returns (bool)
    {
        address player = temps[_requestId].playerAddress;
        bool win = false;
        uint256 amountWon = 0;

        if (temps[_requestId].gameModeTemp == 0) {
            if (playersByAddress[player].betChoice == _randomResult) {
                win = true;
                amountWon = playersByAddress[player].betAmount * 2;
                totalAmountWon = playersByAddress[player].betAmount * 2;
                wonCount[player] = Math.add(wonCount[player], 1);
                playersByAddress[player].balance =
                    playersByAddress[player].balance +
                    amountWon;
                contractBalance -= amountWon;
            } else {
                amountWon = playersByAddress[player].betAmount;
                loseCount[player] = Math.add(loseCount[player], 1);
            }
        } else {
            if (playersByAddress[player].betChoice == _randomResult) {
                win = true;
                amountWon = playersByAddress[player].betAmount * 4;
                totalAmountWon = playersByAddress[player].betAmount * 4;
                wonCount[player] = Math.add(wonCount[player], 1);
                playersByAddress[player].balance =
                    playersByAddress[player].balance +
                    amountWon;
                contractBalance -= amountWon;
            } else {
                amountWon = playersByAddress[player].betAmount;
                loseCount[player] = Math.add(loseCount[player], 1);
            }
        }

        emit BetResult(player, win, amountWon);

        playersByAddress[player].betAmount = 0;
        playersByAddress[player].betOngoing = false;

        delete (temps[_requestId]);
        return win;
    }

    function deposit() external payable {
        require(msg.value > 0);
        contractBalance += msg.value;
        emit DepositToContract(_msgSender(), msg.value, contractBalance);
    }

    function withdrawPlayerBalance() external nonReentrant {
        address player = _msgSender();
        require(player != address(0), "FLIPPY: This address doesn't exist");
        require(
            playersByAddress[player].balance > 0,
            "FLIPPY: No funds to withdraw"
        );
        require(!playersByAddress[player].betOngoing, "FLIPPY: Bet Ongoing...");

        uint256 amount = playersByAddress[player].balance;
        payable(player).transfer(amount);
        delete (playersByAddress[player]);

        emit Withdrawal(player, amount);
    }

    /* View functions:
     *******************/

    function getPlayerBalance() external view returns (uint256) {
        return playersByAddress[_msgSender()].balance;
    }

    function getContractBalance() public view returns (uint256) {
        return contractBalance;
    }

    function getMaxBetTwo() public view returns (uint256) {
        return contractBalance / betCondTwoNumber;
    }

    function getMaxBetFour() public view returns (uint256) {
        return contractBalance / betCondFourNumber;
    }

    function getCondBetTwo() public view returns (uint256) {
        return betCondTwoNumber;
    }

    function getCondBetFour() public view returns (uint256) {
        return betCondFourNumber;
    }

    function getWonCount(address adr) public view returns (uint256) {
        return wonCount[adr];
    }

    function getLoseCount(address adr) public view returns (uint256) {
        return loseCount[adr];
    }

    /* Restricted :
     **************/

    function withdrawContractBalance() external onlyOwner {
        _payout();
        if (LINKTOKEN.balanceOf(address(this)) > 0) {
            bool isSuccess = LINKTOKEN.transfer(
                owner(),
                LINKTOKEN.balanceOf(address(this))
            );
            require(isSuccess, "FLIPPY: Link withdraw failed");
        }
    }

    function addConsumer(address consumerAddress) external onlyOwner {
        COORDINATOR.addConsumer(subscriptionId, consumerAddress);
    }

    function removeConsumer(address consumerAddress) external onlyOwner {
        // Remove a consumer contract from the subscription.
        COORDINATOR.removeConsumer(subscriptionId, consumerAddress);
    }

    function cancelSubscription(address receivingWallet)
        external
        onlyOwner
        nonReentrant
    {
        // Cancel the subscription and send the remaining LINK to a wallet address.
        uint64 temp = subscriptionId;
        subscriptionId = 0;
        COORDINATOR.cancelSubscription(temp, receivingWallet);
    }

    function setNumberTwo(uint256 number) external onlyOwner {
        betCondTwoNumber = number;
    }

    function setNumberFour(uint256 number) external onlyOwner {
        betCondFourNumber = number;
    }

    function setPrivateHex(bytes32 number) external onlyOwner {
        keyHash = number;
    }

    /* Private :
     ***********/

    function _payout() private returns (uint256) {
        require(contractBalance != 0, "FLIPPY: No funds to withdraw");

        uint256 toTransfer = address(this).balance;
        contractBalance = 0;
        payable(owner()).transfer(toTransfer);
        return toTransfer;
    }
}