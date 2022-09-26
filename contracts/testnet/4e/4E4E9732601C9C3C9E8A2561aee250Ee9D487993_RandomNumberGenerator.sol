// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import 'VRFCoordinatorV2Interface.sol';
import 'VRFConsumerBaseV2.sol';
import 'Ownable.sol';
import 'SafeERC20.sol';
import 'IERC20.sol';
import 'ILottery.sol';
import 'IRandomNumberGenerator.sol';

contract RandomNumberGenerator is VRFConsumerBaseV2, Ownable, IRandomNumberGenerator {
    using SafeERC20 for IERC20;
    uint32 private constant RANDOM_IN_PROGRESS = 1;

    address public operatorAddress;
    address public lottery;

    VRFCoordinatorV2Interface COORDINATOR;
    uint64 s_subscriptionId;
    address vrfCoordinator = 0x6A2AAd07396B36Fe02a22b33cf443582f682c82f;
    bytes32 public s_keyHash = 0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314;
    uint32 callbackGasLimit = 300000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 1;

    uint256 public latestRequestId;
    uint256 public latestLotteryId;
    uint32 public randomResult;
    uint256[] public lastRandomWords;

    constructor(uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_subscriptionId = subscriptionId;
    }

    modifier onlyOwnerOrOperator() {
        require((msg.sender == owner()) || (msg.sender == operatorAddress), "Not owner or operator");
        _;
    }

    function getRandomNumber() external override {
        require(msg.sender == lottery, "Only Lottery");
        require(s_keyHash != bytes32(0), "Must have valid key hash");
        uint256 requestId = COORDINATOR.requestRandomWords(
            s_keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );

        latestRequestId = requestId;
        randomResult = RANDOM_IN_PROGRESS;
    }

    /**
     * @notice Callback function used by VRF Coordinator to return the random number to this contract.
     *
     * @dev Some action on the contract state should be taken here, like storing the result.
     * @dev WARNING: take care to avoid having multiple VRF requests in flight if their order of arrival would result
     * in contract states with different outcomes. Otherwise miners or the VRF operator would could take advantage
     * by controlling the order.
     * @dev The VRF Coordinator will only send this function verified responses, and the parent VRFConsumerBaseV2
     * contract ensures that this method only receives randomness from the designated VRFCoordinator.
     *
     * @param requestId uint256
     * @param randomWords  uint256[] The random result returned by the oracle.
     */
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        require(latestRequestId == requestId, "Wrong requestId");
        randomResult = uint32(1000000 + (randomWords[0] % 1000000));
        lastRandomWords =  randomWords;
        latestLotteryId = ILottery(lottery).viewCurrentLotteryId();
    }

    function setOperatorAddress(address _operatorAddress) external onlyOwner {
        require(_operatorAddress != address(0), "Cannot be zero address");
        operatorAddress = _operatorAddress;
    }

    function retrieveToken(address tokenAddress, uint256 amount, address userAddress) external onlyOwnerOrOperator {
        IERC20(tokenAddress).safeTransfer(userAddress, amount);
    }

    function retrieveBalance(uint256 amount, address userAddress) external onlyOwnerOrOperator {
        payable(userAddress).transfer(amount);
    }

    /**
     * @notice Change the keyHash
     * @param _keyHash: new keyHash
     */
    function setKeyHash(bytes32 _keyHash) external onlyOwner {
        s_keyHash = _keyHash;
    }

    /**
     * @notice Set the address for the Lottery
     * @param _lottery: address of the lottery
     */
    function setLotteryAddress(address _lottery) external onlyOwner {
        lottery = _lottery;
    }

    /**
     * @notice View latestLotteryId
     */
    function viewLatestLotteryId() external view override returns (uint256) {
        return latestLotteryId;
    }

    /**
     * @notice View random result
     */
    function viewRandomResult() external view override returns (uint32) {
        require(randomResult != RANDOM_IN_PROGRESS, 'Random in progress');
        return randomResult;
    }

    function setRandomResult(uint32 _randomResult) external onlyOwnerOrOperator {
        randomResult = _randomResult;
    }

}