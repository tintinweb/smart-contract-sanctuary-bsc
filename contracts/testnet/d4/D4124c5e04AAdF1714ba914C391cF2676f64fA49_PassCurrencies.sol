// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

interface IERC20 {
    function decimals() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function mint(address to, uint256 value) external returns (bool success);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function burn(uint256 amount) external;

    function name() external view returns (string memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "../libraries/PassLibrary.sol";

// PassBet Interface
interface IPassBet {
    /* ============== FUNCTION SECTION ============== */

    // Function returns total bet in a currency
    function totalBetInCurrency(address currencyAddress)
        external
        view
        returns (uint256);

    /* ============== EVENT SECTION ============== */

    // Emits when a new bet is created
    event BetInfo(
        address indexed userAddress,
        address indexed currencyAddress,
        uint256 betAmount,
        uint256 percentageChangeExpected,
        uint256 priceChangeExpected,
        // uint256 startRound,
        // uint256 finalRound,
        uint32 timePeriod,
        bool upwardTrend,
        bool isBetOver
    );

    // Emits when a bet is completed
    event ClaimInfo(
        address indexed userAddress,
        address indexed currencyAddress,
        uint256 betAmount,
        uint256 rewards,
        bool isBetOver
    );

    // Emits when rewards are added
    event RewardsInfo(
        uint256 percentageChange,
        uint32 timePeriod,
        uint256 rewardsPercentage
    );

    // Emits when a user stakes in the contract
    event TokensStaked(address indexed userAddress, uint256 amount);

    // Emits when Stake rewards are withdrawan
    event StakeRewardsWithdraw(address indexed userAddress, uint256 rewards);

    // Emits when stake tokens are unstaked
    event TokensUnstaked(address indexed userAddress, uint256 amount);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import "../libraries/PassLibrary.sol";

// PassCurrencies Interface
interface IPassCurrencies {
    /* ================ FUNCTION SECTION ================ */

    // Retuns the rounds the price has been updated upto
    function roundId() external view returns (uint256);

    // Returns the slotTime needed to update the time
    function slotTime() external view returns (uint32);

    // Function returns the currency price at a particular round
    function currencyPrice(address currencyAddress, uint256 roundId)
        external
        view
        returns (uint256);

    // Returns the currency info
    function currencyInfo(address currencyAddress)
        external
        view
        returns (PassLibrary.Currency memory);

    // Function gives price from an oracle
    function getPriceFromOracle(address oracleAddress)
        external
        view
        returns (uint256);

    // Function gives price from an exchange
    function getPriceFromExchange(address tokenAddress)
        external
        view
        returns (uint256);

    /* ================ EVENT SECTION ================ */
    // Emits when a currency is added
    event CurrencyAdded(
        address indexed currencyAddress,
        address oracleAddress,
        uint8 oracleType,
        bool isActive
    );

    // Emits when a currency is updated
    event CurrencyUpdated(address indexed currencyAddress, bool isActive);

    // Emits when a currency is deleted
    event CurrencyDeleted(address indexed currencyAddress);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

interface IUniswapV2Router {
    function getAmountsOut(uint256 amountIn, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);

    function WETH() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

interface OracleWrapper {
    function latestAnswer() external view returns (uint128);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

library PassLibrary {
    // Struct contains the currency information
    struct Currency {
        address currencyAddress;
        address oracleAddress;
        uint8 oracleType;
        bool isActive;
    }
    // Struct contains the user's info who bet on a currency
    struct UserBet {
        address currencyAddress;
        uint256 initialPrice;
        uint256 betAmount;
        uint32 timePeriod;
        uint256 startRound;
        uint256 finalRound;
        uint32 percentageChange;
        uint256 priceChange;
        bool upwardTrend;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./libraries/PassLibrary.sol";
import "./interfaces/IUniswapV2Router.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/OracleWrapper.sol";
import "./interfaces/IPassCurrencies.sol";
import "./interfaces/IPassBet.sol";
import "./utils/Ownable.sol";

// import "hardhat/console.sol";

contract PassCurrencies is Ownable, IPassCurrencies {
    // Variables
    uint256 public roundId; // How many rounds the price has been updated
    uint32 public lastActiveSlot; // Last actve slot time
    uint32 public override slotTime; // Slot time needed to update
    uint16 public currencyCount; // Total number of currencies

    // Currencies
    mapping(address => PassLibrary.Currency) internal _currencyInfo; // Handles the currency info
    mapping(address => mapping(uint256 => uint256)) public currencyPrice; // Stores the last updated price of the currency

    // Instances
    IUniswapV2Router public immutable uniswap; // Router Address
    IERC20 public immutable BUSD; // BUSD address
    IPassBet public passBet; // Pass Bet contract address

    /* ================ CONSTRUCTOR SECTION ================ */

    constructor(IERC20 _busdAddress, IUniswapV2Router _uniswapV2Router) {
        BUSD = _busdAddress;
        uniswap = _uniswapV2Router;

        lastActiveSlot = uint32(block.timestamp);
        slotTime = 5 minutes; // 12 hours
    }

    /* ================ CURRENCY SECTION ================ */

    // Function adds a new currency to the contract
    function addCurrency(
        uint8 _oracleType,
        address _currencyAddress,
        address _oracleAddress
    ) external onlyOwner {
        require(
            currencyInfo(_currencyAddress).currencyAddress == address(0),
            "Currency already exists."
        );

        // require(
        //     IERC20(_currencyAddress).decimals() > 0,
        //     "Currency address might not be correct. Please check."
        // );

        require(
            keccak256(bytes(IERC20(_currencyAddress).name())) != keccak256(""),
            "Currency address is incorrect"
        );

        if (_oracleType == 1) {
            require(
                OracleWrapper(_oracleAddress).latestAnswer() > 0,
                "Oracle Address might not be right. Please check."
            );
        }

        // Instance creation
        PassLibrary.Currency memory currency = PassLibrary.Currency({
            currencyAddress: _currencyAddress,
            oracleAddress: _oracleAddress,
            oracleType: _oracleType,
            isActive: true
        });
        _currencyInfo[_currencyAddress] = currency;
        ++currencyCount;

        // Emits an event
        emit CurrencyAdded(_currencyAddress, _oracleAddress, _oracleType, true);
    }

    // Function lets the admin enable or disable a currency
    function enableOrDisableCurrency(address _currencyAddress)
        external
        onlyOwner
    {
        PassLibrary.Currency storage currency = _currencyInfo[_currencyAddress];

        // Currency needs to be existing
        require(
            currency.currencyAddress == _currencyAddress,
            "Currency doesn't exist."
        );

        currency.isActive = !currency.isActive;

        // Events emits
        emit CurrencyUpdated(_currencyAddress, currency.isActive);
    }

    // Function deletes cuurrency from the contract
    function deleteCurrency(address _currencyAddress) external onlyOwner {
        require(
            currencyInfo(_currencyAddress).currencyAddress == _currencyAddress,
            "Currency doesn't exist."
        );

        // Cannot delete if there is still a bet on the currency
        require(
            passBet.totalBetInCurrency(_currencyAddress) == 0,
            "Cannot delete. Some bets are still there."
        );

        --currencyCount;

        // Deleted the currency
        delete _currencyInfo[_currencyAddress];

        // Event emits
        emit CurrencyDeleted(_currencyAddress);
    }

    /* ================ PRICE SECTION ================ */

    // Function updated the current price of a currency. Currency address to be added in an array
    function updateCurrencyPrice(address[] memory _currencies)
        external
        onlyOwner
    {
        roundId++;

        uint32 _oldTimeSlot = lastActiveSlot;
        uint32 _newTimeSlot = updateLastActiveSlotTime();

        require(_oldTimeSlot < _newTimeSlot, "Not time to update yet.");

        // Loop runs for only array length
        for (uint16 i; i < _currencies.length; i++) {
            PassLibrary.Currency memory currency = _currencyInfo[
                _currencies[i]
            ];

            // Updates only if the currency exists
            require(
                currency.currencyAddress != address(0),
                "Currency doesn't exist."
            );

            // Updates only if there is a bet in the currency
            require(
                passBet.totalBetInCurrency(currency.currencyAddress) > 0,
                "Cannot update price since there is no bet in the currency."
            );

            if (currency.oracleType == 1) {
                currencyPrice[currency.currencyAddress][
                    roundId
                ] = getPriceFromOracle(currency.oracleAddress);
            } else {
                currencyPrice[currency.currencyAddress][
                    roundId
                ] = getPriceFromExchange(currency.currencyAddress);
            }
        }
    }

    // function updateCurrencyPrice(
    //     address[] memory _currencies,
    //     uint256[] memory _prices
    // ) external onlyOwner {
    //     roundId++;

    //     uint32 _oldTimeSlot = lastActiveSlot;
    //     uint32 _newTimeSlot = updateLastActiveSlotTime();

    //     require(_oldTimeSlot < _newTimeSlot, "Not time to update yet.");

    //     // Loop runs for only array length
    //     for (uint16 i; i < _currencies.length; i++) {
    //         PassLibrary.Currency memory currency = _currencyInfo[
    //             _currencies[i]
    //         ];

    //         // Updates only if the currency exists
    //         require(
    //             currency.currencyAddress != address(0),
    //             "Currency doesn't exist."
    //         );

    //         // Updates only if there is a bet in the currency
    //         require(
    //             passBet.totalBetInCurrency(currency.currencyAddress) > 0,
    //             "Cannot update price since there is no bet in the currency."
    //         );

    //         currencyPrice[currency.currencyAddress][roundId] = _prices[i];
    //     }
    // }

    // Function gets price from the oracle
    function getPriceFromOracle(address _oracleAddress)
        public
        view
        returns (uint256)
    {
        require(_oracleAddress != address(0), "Oracle address cannot be zero");

        return OracleWrapper(_oracleAddress).latestAnswer();
    }

    // Function gets the price from an exchange
    function getPriceFromExchange(address _tokenAddress)
        public
        view
        returns (uint256)
    {
        if (_tokenAddress == address(BUSD)) {
            return 10**BUSD.decimals();
        } else {
            // Creates a path of the token with BUSD
            address[] memory path = new address[](2);
            path[0] = _tokenAddress;
            path[1] = address(BUSD);

            uint256[] memory values = uniswap.getAmountsOut(
                10**IERC20(_tokenAddress).decimals(),
                path
            );

            return uint256(values[1]);
        }
    }

    /* ================ TIME SLOT SECTION ================ */

    // Updates last active time slot
    function updateLastActiveSlotTime() internal returns (uint32) {
        uint32 _lastActiveTimeSlot = getLastSlotTime();

        if (lastActiveSlot != _lastActiveTimeSlot) {
            lastActiveSlot = _lastActiveTimeSlot;
        }

        return _lastActiveTimeSlot;
    }

    // Function returning last slot timestamp
    function getLastSlotTime() internal view returns (uint32) {
        uint32 _slotsToAdd = uint32(
            ((uint32(block.timestamp) - lastActiveSlot) / slotTime) * slotTime
        );

        return uint32(lastActiveSlot + _slotsToAdd);
    }

    /* ================ OTHER FUNCTION SECTION ================ */

    // Function returns the currency Info
    function currencyInfo(address _currencyAddress)
        public
        view
        returns (PassLibrary.Currency memory)
    {
        return _currencyInfo[_currencyAddress];
    }

    // Function updates the pass bet address
    function updatePassBetAddress(IPassBet _newAddress) external onlyOwner {
        passBet = _newAddress;
    }

    // Function updates slot time
    function updateSlotTime(uint32 _slotTime) external onlyOwner {
        slotTime = _slotTime;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

abstract contract Ownable {
    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() {
        _setOwner(msg.sender);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner Access");
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function _setOwner(address newOwner) internal {
        owner = newOwner;
    }
}