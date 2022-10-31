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

    address public operatorAddress;
    address public lottery;

    VRFCoordinatorV2Interface COORDINATOR;
    uint64 s_subscriptionId;
    address vrfCoordinator = 0xc587d9053cd1118f25F645F9E08BB98c9712A4EE;
    bytes32 public s_keyHash = 0xba6e730de88d94a5510ae6613898bfb0c3de5d16e609c5b7da808747125506f7;
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
        uint256 requestId = COORDINATOR.requestRandomWords(
            s_keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );

        latestRequestId = requestId;
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
        return randomResult;
    }

}