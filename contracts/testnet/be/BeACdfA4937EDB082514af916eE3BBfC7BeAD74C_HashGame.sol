// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import "./IERC20.sol";

interface VICO {
    function count() external view returns (uint256);

    function increment() external;

    function transferFrom() external;
}

contract HashGame {
    constructor(IERC20 token) {
        _token = token;
    }

    struct Insurance {
        uint256 purchasedDateTime;
        uint256 expiryDateTime;
    }

    struct GameRound {
        uint256 round;
        bool hasPlayed;
        bool isWon;
        uint256 stakeValue;
    }

    event NewGameRound(
        uint256 roundCount,
        bool hasPlayed,
        bool isWon,
        uint256 stakeValue
    );

    IERC20 private _token;
    uint256 constant insuredDuration = 1 days;
    uint256 constant insurancePrice = 0.01 ether;
    uint256 constant maxGameRound = 9;
    uint256 constant nextGameMultiplier = 2;

    mapping(address => Insurance) public userToInsuranceMap;
    mapping(address => GameRound[]) public userToGameMap;

    function buyInsurance() external {
        //require(msg.value == insurancePrice, "Insufficient ether");
        require(
            isEligibleToBuyNewInsurance(msg.sender),
            "You are not eligible to buy insurance"
        );
        require(_token.transferFrom(msg.sender, address(this), insurancePrice));

        delete userToInsuranceMap[msg.sender];
        userToInsuranceMap[msg.sender] = Insurance(
            block.timestamp,
            block.timestamp + insuredDuration
        );
    }

    function hasValidInsurance(address addr)
        public
        view
        returns (
            bool isInsured,
            uint256 purchasedTime,
            uint256 expiryTime
        )
    {
        bool isEligible = isEligibleToBuyNewInsurance(addr);

        // console.log('bool: %o', isEligible);

        if (isEligible == true) {
            return (false, 0, 0);
        }

        Insurance storage userInsurance = userToInsuranceMap[addr];
        return (
            !isEligible,
            userInsurance.purchasedDateTime,
            userInsurance.expiryDateTime
        );
    }

    function isEligibleToBuyNewInsurance(address addr)
        public
        view
        returns (bool)
    {
        Insurance storage userInsurance = userToInsuranceMap[addr];
        // console.log('expiryDateTime: %o', userInsurance.expiryDateTime);
        // console.log('purchasedDateTime: %o', userInsurance.purchasedDateTime);
        // console.log('block.timestamp: %o', block.timestamp);
        return
            (userInsurance.expiryDateTime == 0 &&
                userInsurance.purchasedDateTime == 0) ||
            (block.timestamp >= userInsurance.expiryDateTime);
    }

    function playGame() public {
        (bool isUserInsured, , ) = hasValidInsurance(msg.sender);
        require(isUserInsured, "User does not have valid insurance");
        require(
            !hasPlayedMaxGameRound(),
            "User has played maximum rounds of game"
        );

        // console.logBytes1(getCharAt("123456789", 8));

        uint256 playedRound = userToGameMap[msg.sender].length;
        uint256 lastStakedValue = 0;

        if (
            playedRound > 0 &&
            userToGameMap[msg.sender][playedRound - 1].hasPlayed == false
        ) {
            GameRound memory lastCreatedRound = userToGameMap[msg.sender][
                playedRound - 1
            ];
            emit NewGameRound(
                lastCreatedRound.round,
                lastCreatedRound.hasPlayed,
                lastCreatedRound.isWon,
                lastCreatedRound.stakeValue
            );
            return;
        }

        if (playedRound > 0) {
            lastStakedValue = userToGameMap[msg.sender][playedRound - 1]
                .stakeValue;
        }

        uint256 currentStakeValue = lastStakedValue > 0
            ? lastStakedValue * nextGameMultiplier
            : 1;
        GameRound memory newRound = GameRound(
            playedRound + 1,
            false,
            false,
            currentStakeValue
        );

        userToGameMap[msg.sender].push(newRound);
        emit NewGameRound(
            newRound.round,
            newRound.hasPlayed,
            newRound.isWon,
            newRound.stakeValue
        );
    }

    function currentGameRound()
        public
        view
        returns (uint256 round, uint256 stakeValue)
    {
        (bool isUserInsured, , ) = hasValidInsurance(msg.sender);
        require(isUserInsured, "User does not have valid insurance");
        require(
            !hasPlayedMaxGameRound(),
            "User has played maximum rounds of game"
        );

        uint256 playedRound = userToGameMap[msg.sender].length;
        uint256 lastStakedValue = 0;

        if (
            playedRound > 0 &&
            userToGameMap[msg.sender][playedRound - 1].hasPlayed == false
        ) {
            GameRound memory lastCreatedRound = userToGameMap[msg.sender][
                playedRound - 1
            ];
            return (lastCreatedRound.round, 0);
        }

        if (
            playedRound > 0 &&
            userToGameMap[msg.sender][playedRound - 1].hasPlayed == true
        ) {
            GameRound memory lastCreatedRound = userToGameMap[msg.sender][
                playedRound - 1
            ];
            lastStakedValue = userToGameMap[msg.sender][playedRound - 1]
                .stakeValue;
            uint256 currentStakeValue = lastStakedValue > 0
                ? lastStakedValue * nextGameMultiplier
                : 1;

            return (lastCreatedRound.round + 1, currentStakeValue);
        }

        if (playedRound == 0) {
            return (1, 1);
        }
    }

    function submitGameResult(string memory hash) public {
        require(bytes(hash).length > 0, "Hash cannot be empty");
        require(
            userToGameMap[msg.sender].length > 0,
            "User has not started any game"
        );

        uint256 playedRound = userToGameMap[msg.sender].length;
        bool isHashWinnable = isWinningHash(hash);

        userToGameMap[msg.sender][playedRound - 1].hasPlayed = true;
        userToGameMap[msg.sender][playedRound - 1].isWon = isHashWinnable;
    }

    function isWinningHash(string memory hash) public pure returns (bool) {
        require(bytes(hash).length > 0, "Hash cannot be empty");

        uint256 strLength = bytes(hash).length;
        bytes1 lastChar = getCharAt(hash, strLength);
        bytes1 lastSecondChar = getCharAt(hash, strLength - 1);

        return
            (isNumber(lastChar) && isAlphabet(lastSecondChar)) ||
            (isNumber(lastSecondChar) && isAlphabet(lastChar));
    }

    function isNumber(bytes1 char) private pure returns (bool) {
        return char >= 0x30 && char <= 0x39;
    }

    function isAlphabet(bytes1 char) private pure returns (bool) {
        return (char >= 0x41 && char <= 0x5A) || (char >= 0x61 && char <= 0x7A);
    }

    function substring(
        string memory str,
        uint256 startIndex,
        uint256 endIndex
    ) private pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex - startIndex);
        for (uint256 i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }
        return string(result);
    }

    function getCharAt(string memory str, uint256 position)
        private
        pure
        returns (bytes1)
    {
        return bytes(substring(str, position - 1, position))[0];
    }

    function hasPlayedMaxGameRound() public view returns (bool hasPlayedMax) {
        (bool userHasValidInsurance, , ) = hasValidInsurance(msg.sender);
        bool userHasPlayedMaxRound = userToGameMap[msg.sender].length ==
            maxGameRound;

        return userHasValidInsurance && userHasPlayedMaxRound;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}