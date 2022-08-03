/**
 *Submitted for verification at BscScan.com on 2022-08-02
*/

// Sources flattened with hardhat v2.9.6 https://hardhat.org

// File contracts/interfaces/IBetSlips.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface IBetSlips {
    enum Status {
        PLACED,
        COMPLETED,
        REVOKED
    }

    struct BetSlip {
        uint256 betId;
        address player;
        address token;
        string gameCode;
        string playerGameChoice;
        string gameResult;
        uint256 wagerAmount;
        uint256 returnAmount;
        uint256 odds;
        string seedHash;
        string seed;
        Status status;
        uint256 placedAt;
        uint256 completedAt;
    }

    event betSlipPlaced(
        uint256 betId,
        address player,
        address tokenAddress,
        string gameCode,
        string playerGameChoice,
        uint256 wagerAmount,
        string seedHash,
        uint256 odds,
        Status status
    );

    event betSlipCompleted(
        uint256 betId,
        address player,
        address tokenAddress,
        string gameCode,
        string playerGameChoice,
        uint256 wagerAmount,
        string seedHash,
        string gameResult,
        uint256 returnAmount,
        string seed,
        uint256 odds,
        Status status
    );

    event betSlipRevoked(
        string seedHashes,
        string reason
    );

    function getBetSlip(string memory seedHash)
        external
        returns (BetSlip memory);

    function placeBetSlip(
        address player,
        address token,
        uint256 wagerAmount,
        string memory gameCode,
        string memory playerGameChoice,
        string memory seedHash,
        uint256 odds,
        uint256 deadLine,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function completeBet(
        string memory seedHash,
        string memory seed,
        string memory playerGameChoice,
        string memory gameResult,
        uint256 returnAmount,
        uint256 odds
    ) external;

    function revokeBetSlips(
        string [] memory seedHashes,
        string memory reason
    ) external;
}


// File @openzeppelin/contracts/utils/[email protected]


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


// File @openzeppelin/contracts/access/[email protected]


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File @openzeppelin/contracts/security/[email protected]


// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}


// File contracts/libraries/SeedUtility.sol



pragma solidity ^0.8.2;

library SeedUtility {
    //Fraction is literally the number expressed as a quotient, in which the numerator is divided by the denominator. 
    //Because solidity doesn't support decimal data, fraction is needed for dealing with deciaml data operation.
    //Thus, decimal data is converted into fraction data.
    struct Fraction {
        uint256 numerator;
        uint256 denominator;
    }

    function bytes32ToString(bytes32 _bytes32)
        public
        pure
        returns (string memory)
    {
        bytes memory s = new bytes(64);

        for (uint8 i = 0; i < 32; i++) {
            bytes1 b = bytes1(_bytes32[i]);
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));

            if (hi < 0x0A) {
                s[i * 2] = bytes1(uint8(hi) + 0x30);
            } else {
                s[i * 2] = bytes1(uint8(hi) + 0x57);
            }

            if (lo < 0x0A) {
                s[i * 2 + 1] = bytes1(uint8(lo) + 0x30);
            } else {
                s[i * 2 + 1] = bytes1(uint8(lo) + 0x57);
            }
        }

        return string(s);
    }

    function strToUint(string memory _str) public pure returns (uint256 res) {
        for (uint256 i = 0; i < bytes(_str).length; i++) {
            if (
                (uint8(bytes(_str)[i]) - 48) < 0 ||
                (uint8(bytes(_str)[i]) - 48) > 9
            ) {
                return 0;
            }
            res +=
                (uint8(bytes(_str)[i]) - 48) *
                10**(bytes(_str).length - i - 1);
        }

        return res;
    }

    function uintToStr(uint256 _i)
        public
        pure
        returns (string memory _uintAsString)
    {
        uint256 number = _i;
        if (number == 0) {
            return "0";
        }
        uint256 j = number;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }

        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;
        while (number >= 10) {
            bstr[k--] = bytes1(uint8(48 + (number % 10)));
            number /= 10;
        }
        bstr[k] = bytes1(uint8(48 + (number % 10)));
        return string(bstr);
    }

    function addressToStr(address _address)
        public
        pure
        returns (string memory)
    {
        bytes32 _bytes = bytes32((uint256(uint160(_address))));
        bytes memory HEX = "0123456789abcdef";
        bytes memory _string = new bytes(42);

        _string[0] = "0";
        _string[1] = "x";

        for (uint256 i = 0; i < 20; i++) {
            _string[2 + i * 2] = HEX[uint8(_bytes[i + 12] >> 4)];
            _string[3 + i * 2] = HEX[uint8(_bytes[i + 12] & 0x0f)];
        }

        return string(_string);
    }

    function compareSeed(string memory seedHash, string memory seed)
        public
        pure
        returns (bool)
    {
        string memory hash = bytes32ToString(sha256(abi.encodePacked(seed)));

        if (
            keccak256(abi.encodePacked(hash)) ==
            keccak256(abi.encodePacked(seedHash))
        ) {
            return true;
        } else {
            return false;
        }
    }

    function getHashNumberUsingAsciiNumber(string memory asciiNumbers)
        public
        pure
        returns (uint256)
    {
        bytes memory b = bytes(asciiNumbers);
        uint256 sum = 0;

        for (uint256 i = 0; i < b.length; i++) {
            bytes1 char = b[i];

            sum += uint256(uint8(char));
        }

        return sum;
    }

    function abs(int256 x) 
        public 
        pure 
        returns (int256) 
    {
       return x >= 0 ? x : -x;
    }

    function getHashNumber(string memory seed)
        public
        pure
        returns (uint256)
    {
        int256 p = 31;
        int256 m = 10 ** 9 + 9;
        int256 powerOfP = 1;
        int256 hashVal = 0;
        bytes memory b = bytes(seed);
        bytes1 ascciNumberOfA = 'a';

        for (uint256 i = 0; i < b.length; i++) {
            bytes1 char = b[i];
            hashVal = (hashVal + int256(int8(uint8(char)) - int8(uint8(ascciNumberOfA)) + 1) * powerOfP) % m;
            powerOfP = (powerOfP * p) % m;
        }

        return uint256(abs(hashVal));
    }

    function getResultByProbabilities(string memory seed, uint256[] memory probabilities, uint256 amountOfDigits)
        public
        pure
        returns (uint256 index)
    {
        uint256 totalProbabilities = 0;
        uint256 amountOfResultItems = probabilities.length;

        // The value generated by getHashNumber is one that has 9 digits integer.
        // hitNumber is integer that amount of digits of aboved integer from the lowest digit.
        uint256 hitNumber = getHashNumber(seed) % (10**amountOfDigits);

        for(index = 0; index < amountOfResultItems; index++)
        {
            totalProbabilities += probabilities[index];
            
            if (totalProbabilities > hitNumber)
            {
                return index;
            }
        }
    }

    function getResultByFractionProbabilities(string memory seed, Fraction[] memory probabilities, uint256 amountOfDigits)
        public
        pure
        returns (uint256 index)
    {
        uint256 amountOfResultItems = probabilities.length;

        Fraction memory totalProbabilities;
        totalProbabilities.numerator = 0;
        totalProbabilities.denominator = 1;

        // The value generated by getHashNumber is one that has 9 digits integer.
        // hitNumber is integer that has amount of digits(amountOfDigits) from the lowest digit.
        uint256 hitNumber = getHashNumber(seed) % (10**amountOfDigits);

        for(index = 0; index < amountOfResultItems; index++)
        {
            totalProbabilities = fractionAddFraction(totalProbabilities, probabilities[index]);
            
            if ((totalProbabilities.numerator / totalProbabilities.denominator) > hitNumber)
            {
                return index;
            }
        }
    }

    function fractionMultInteger(Fraction memory fraction, uint256 integer)
        public
        pure
        returns (Fraction memory result)
    {
        result.numerator = fraction.numerator * integer;
        result.denominator = fraction.denominator;
    }

    function fractionDivInteger(Fraction memory fraction, uint256 integer)
        public
        pure
        returns (Fraction memory result)
    {
        result.numerator = fraction.numerator;
        result.denominator = fraction.denominator * integer;
    }

    function fractionAddFraction(Fraction memory fraction1, Fraction memory fraction2)
        public
        pure
        returns (Fraction memory result)
    {
        result.numerator = fraction1.numerator*fraction2.denominator + fraction2.numerator*fraction1.denominator;
        result.denominator = fraction1.denominator * fraction2.denominator;
    }

    function fractionDivFraction(Fraction memory fraction1, Fraction memory fraction2)
        public
        pure
        returns (Fraction memory result)
    {
        result.numerator = fraction1.numerator*fraction2.denominator;
        result.denominator = fraction1.denominator * fraction2.numerator;
    }

    function toJsonStrArray(string [] memory arr)
        public 
        pure
        returns (string memory)
    {
        string memory jsonStrArray;
        for (uint8 i = 0; i < arr.length; i++) {
            if (i == 0)
                jsonStrArray = string(abi.encodePacked('["', arr[i], '"'));
            else
                jsonStrArray = string(abi.encodePacked(jsonStrArray, ', "', arr[i], '"'));
        }
        jsonStrArray = string(abi.encodePacked(jsonStrArray, ']'));

        return jsonStrArray;
    }

    function toStrArray(string [] memory arr)
        public 
        pure
        returns (string memory)
    {
        string memory strArray;
        for (uint8 i = 0; i < arr.length; i++) {
            if (i == 0)
                strArray = string(abi.encodePacked("[", arr[i]));
            else
                strArray = string(abi.encodePacked(strArray, ", ", arr[i]));
        }
        strArray = string(abi.encodePacked(strArray, "]"));

        return strArray;
    }
}


// File contracts/games/BaseGame.sol



pragma solidity ^0.8.2;



contract BaseGame is Ownable, Pausable {
  struct BetLimit {
        uint256 min;
        uint256 max;
        uint256 defaultValue;
    }

    mapping(address => BetLimit) _betLimits;

    address payable internal _betSlipsAddr;
    uint256 internal _rtp;

    event betLimitSet(
        address token,
        uint256 min,
        uint256 max,
        uint256 defaultValue
    );

    function setRtp(uint256 rtp) public onlyOwner {
        _rtp = rtp;
    }

    function getRtp() public view returns (uint256) {
        return _rtp;
    }

    function setBetSlipsAddress(address betSlipsAddr) public onlyOwner {
        _betSlipsAddr = payable(betSlipsAddr);
    }

    function getBetSlipsAddress() public view returns (address) {
        return _betSlipsAddr;
    }

    function setBetLimit(
        address token,
        uint256 min,
        uint256 max,
        uint256 defaultValue
    ) public onlyOwner {
        BetLimit memory betLimit = BetLimit(min, max, defaultValue);
        _betLimits[token] = betLimit;

        emit betLimitSet(token, min, max, defaultValue);
    }

    function getGameConfig(address token) public view returns (string memory) {
        string memory rtp = string(
            abi.encodePacked('{"rtp":', SeedUtility.uintToStr(_rtp), ",")
        );

        string memory betLimitsStr = string(abi.encodePacked('"betLimits": {'));

        BetLimit memory betLimit = _betLimits[token];

        string memory tokenStr = string(
            abi.encodePacked('"', SeedUtility.addressToStr(token), '": {')
        );

        string memory minStr = string(
            abi.encodePacked(
                '"min": ',
                SeedUtility.uintToStr(betLimit.min),
                ","
            )
        );

        string memory maxStr = string(
            abi.encodePacked(
                '"max": ',
                SeedUtility.uintToStr(betLimit.max),
                ","
            )
        );

        string memory defaultStr = string(
            abi.encodePacked(
                '"default": ',
                SeedUtility.uintToStr(betLimit.defaultValue),
                "}"
            )
        );

        betLimitsStr = string(
            abi.encodePacked(
                betLimitsStr,
                tokenStr,
                minStr,
                maxStr,
                defaultStr
            )
        );

        return string(abi.encodePacked(rtp, betLimitsStr, "}}"));
    }

    function pauseGame() public onlyOwner whenNotPaused {
        _pause();
    }

    function unpauseGame() public onlyOwner whenPaused {
       _unpause();
    }
}


// File contracts/games/HiloGame.sol



pragma solidity ^0.8.2;


contract HiloGame is BaseGame {

    struct CARD {
        uint8 rank;
        uint8 suit;
        string friendlyName;
    }

    uint256 constant RANK_AMOUNT = 13;
    uint256 constant SUIT_AMOUNT = 4;
    uint256 constant CARD_AMOUNT = RANK_AMOUNT * SUIT_AMOUNT;

    mapping(string => string[]) _playerChoices;
    CARD[] allCards;

    constructor(address betSlipsAddr, uint256 rtp) {
        string[RANK_AMOUNT] memory rankName = ["ACE", "TWO", "THREE", "FOUR", "FIVE", "SIX", "SEVEN", "EIGHT", "NINE", "TEN", "JACK", "QUEEN", "KING"];
        string[SUIT_AMOUNT] memory suitName = ["SPADE", "HEART", "DIAMOND", "CLUB"];
        CARD memory card;

        for (uint8 i = 0; i < SUIT_AMOUNT; i++)
            for (uint8 j = 0; j < RANK_AMOUNT; j++)
            {
                card = CARD(j, i, string(abi.encodePacked(rankName[j], "_OF_", suitName[i])));
                allCards.push(card);
            }

        _betSlipsAddr = payable(betSlipsAddr);
        _rtp = rtp;
    }

    function revealSeed(string memory seedHash, string memory seed, string[] memory playerChoices) public {
        require(SeedUtility.compareSeed(seedHash, seed) == true, "Invalid seed");

        IBetSlips.BetSlip memory betSlip = IBetSlips(_betSlipsAddr).getBetSlip(
            seedHash
        );

        _playerChoices[seedHash] = playerChoices;
        betSlip.playerGameChoice = getHiloGameChoice(playerChoices);

        CARD[] memory generatedCards = generateCardArray(uint8(playerChoices.length+1), seed);
        uint256 odds = getOdds(playerChoices, generatedCards);
        uint256 returnAmount = betSlip.wagerAmount * odds / 100;

        string memory friendlyCardNameArray;

        for(uint8 i = 0; i < generatedCards.length; i++)
        {
            if (i == 0)
                friendlyCardNameArray = string(abi.encodePacked("[", generatedCards[i].friendlyName));
            else
                friendlyCardNameArray = string(abi.encodePacked(friendlyCardNameArray, ", ", generatedCards[i].friendlyName));
        }
        friendlyCardNameArray = string(abi.encodePacked(friendlyCardNameArray, "]"));

        IBetSlips(_betSlipsAddr).completeBet(
            seedHash,
            seed,
            betSlip.playerGameChoice,
            friendlyCardNameArray,
            returnAmount,
            odds
        );
    }

    function placeBet(
        uint256 wagerAmount,
        string memory seedHash,
        address token
    ) public whenNotPaused{
        placeBetSlip(wagerAmount, seedHash, token, 0, 0, 0, 0);
    }

    function placeBetWithPermit(
        uint256 wagerAmount,
        string memory seedHash,
        address token,
        uint256 deadLine,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public whenNotPaused{
        placeBetSlip(wagerAmount, seedHash, token, deadLine, v, r, s);
    }

    function placeBetSlip(
        uint256 wagerAmount,
        string memory seedHash,
        address token,
        uint256 deadLine,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) private {

        require(
            wagerAmount >= _betLimits[token].min && wagerAmount <= _betLimits[token].max,
            "The WagerAmount is invalid"
        );

        IBetSlips(_betSlipsAddr).placeBetSlip(
            msg.sender,
            token,
            wagerAmount,
            "hilo",
            "",
            seedHash,
            0,
            deadLine,
            v,
            r,
            s
        );
    }

    function getOdds(string [] memory playerChoices, CARD[] memory generatedCards)
        private
        view
        returns (uint256)
    {
        uint256 odds = 1;
        uint256 oldCardNumber;
        uint256 newCardNumber;
        uint256 amountOfLuckyCard = 1;
        uint8 countOfMultiply = 0;

        for(uint8 i = 0; i < playerChoices.length; i++)
        {
            oldCardNumber = generatedCards[i].rank;
            newCardNumber = generatedCards[i+1].rank;
          
            if (
                keccak256(abi.encodePacked((playerChoices[i]))) ==
                keccak256(abi.encodePacked(("OVER")))
            ) {
                if (newCardNumber > oldCardNumber){
                    amountOfLuckyCard = RANK_AMOUNT - oldCardNumber - 1;
                    if (amountOfLuckyCard == 0)
                        amountOfLuckyCard = 1;  
                } else {
                    odds = 0;
                    break;
                }
            } else if (
                keccak256(abi.encodePacked((playerChoices[i]))) ==
                keccak256(abi.encodePacked(("UNDER")))
            ) {
                if (newCardNumber < oldCardNumber){
                    amountOfLuckyCard = oldCardNumber;
                    if (amountOfLuckyCard == 0)
                        amountOfLuckyCard = 1;  
                } else {
                    odds = 0;
                    break;
                }
            } else if (
                keccak256(abi.encodePacked((playerChoices[i]))) ==
                keccak256(abi.encodePacked(("SKIP")))
            ) {
                continue;
            }

            // If hiloChoice = "OVER" and cardNumber = 4, then amountOfLuckyCard = 8, 
            // (cardNumber ranged 0~12, so the amount of numbers greater than 4 equals 8).
            // Therefore, odds = ((97*13*10)/8+5)/10 = 158.
            // Here, 97*13*10/8 = 1576 (not 1576.25), 1576+5=1581, 1581/10 = 158.
            // If there's no operations as above, 97*13/8=157.625, thus odds=157.
            // Eventually, these operations (*10, +5, then /10) are needed for rounding up for the lowest digit of odds value.
            
            odds *= (_rtp * RANK_AMOUNT / amountOfLuckyCard);
            countOfMultiply++;
        }
        //_rtp = 97, not 0.97, so odds should be divided by 100 by the number of times multiplied the _rtp.
        // But odds should be divided countOfMultiply-1 times because it should be multiplied 100 so that 
        // it becomes integer greater than 100.
        if (odds > 0) {
            for(uint8 i = 0 ; i < countOfMultiply-1; i++)
                odds /= 100;
        }

        return odds;
    }

    function getReturnAmount(uint256 wagerAmount, uint256 odds) 
        private 
        pure 
        returns (uint256 returnAmount) 
    {
        returnAmount = wagerAmount * odds / 100;
    }

    function generateCardArray (uint8 amountOfCards, string memory seed)
        private
        view 
        returns (CARD[] memory) 
    {
        CARD[] memory generatedCards = new CARD[](amountOfCards);
        string memory currentSeed = seed;

        for(uint8 i = 0; i < amountOfCards; i++)
        {
            uint8 indexOfCard = uint8(SeedUtility.getHashNumberUsingAsciiNumber(currentSeed) % CARD_AMOUNT);
            generatedCards[i] = allCards[indexOfCard];
            currentSeed = SeedUtility.bytes32ToString(sha256(abi.encodePacked(currentSeed)));
        }

        return generatedCards;
    }

    function getHiloGameChoice(string [] memory playerChoices)
        private
        pure
        returns (string memory)
    {
        string memory hiloGameChoice;

        for(uint8 i = 0; i < playerChoices.length; i++) {
            if (i == 0)
                hiloGameChoice = string(abi.encodePacked("[", playerChoices[i]));
            else
                hiloGameChoice = string(abi.encodePacked(hiloGameChoice, ", ", playerChoices[i]));
        }
        hiloGameChoice = string(abi.encodePacked(hiloGameChoice, "]"));

        return hiloGameChoice;
    }
}