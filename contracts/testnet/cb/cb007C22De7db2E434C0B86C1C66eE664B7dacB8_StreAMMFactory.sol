// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import './interfaces/IStreAMMFactory.sol';
import './interfaces/IStreAMMProtocolFee.sol';
import './interfaces/IStreAMMPairFee.sol';
import './interfaces/ICountryList.sol';
import './interfaces/IStreAMMDiscountedTrading.sol';
import './interfaces/IStreAMMTokenWhitelist.sol';
import './StreAMMPair.sol';

contract StreAMMFactory is IStreAMMFactory, Ownable {
    bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(StreAMMPair).creationCode));
    bool public activated = false; // bool to indicate if anyone can create new pools

    address public streAMMProtocolFee; // holding all protocol fees sent to the streAMM address
    address private countryList; // list to check if a given country code is valid
    address private liquidityTopLocker; // holding top liquidity lockers for tokens - passed to the pair
    address private streAMMDiscountedTrading; // holds balances for discounted trades to check if a trader has discounted trades
    address private streAMMTokenWhitelist; // holds whitelisted tokens for liquidity locker fee transfer
    address public override router; // current router address - needed for access control of pair's setCountryCode function

    mapping(address => mapping(address => address)) public override getPair; // holding pair address for two tokens (token0 and token1)
    address[] public override allPairs; // array of all created pairs
    mapping(address => bool) private isPairContract;

    /**
     * @dev initially sets addresses of related contracts
     * @param _streAMMProtocolFee the address of the StreAMMProtocolFee contract accessed by pair
     * @param _countryList the address of the CountryList contract
     * @param _router the address of the Router contract accessed by pair
     * @param _liquidityTopLocker the address of the LiquidityTopLocker contract accessed by pair
     * @param _streAMMDiscountedTrading the address of the StreAMMDiscountedTrading contract
     * @param _streAMMTokenWhitelist the address of the StreAMMTokenWhitelist contract
     */
    function initialize(
        address _streAMMProtocolFee,
        address _countryList,
        address _router,
        address _liquidityTopLocker,
        address _streAMMDiscountedTrading,
        address _streAMMTokenWhitelist
    ) external onlyOwner {
        require(
            _streAMMProtocolFee != address(0) &&
                _countryList != address(0) &&
                _router != address(0) &&
                _liquidityTopLocker != address(0) &&
                _streAMMDiscountedTrading != address(0) &&
                _streAMMTokenWhitelist != address(0),
            'StreAMMFactory: Zero address'
        );
        streAMMProtocolFee = _streAMMProtocolFee;
        countryList = _countryList;
        router = _router;
        liquidityTopLocker = _liquidityTopLocker;
        streAMMDiscountedTrading = _streAMMDiscountedTrading;
        streAMMTokenWhitelist = _streAMMTokenWhitelist;
    }

    /**
     * @dev Returns number of all created pairs (length of allPairs array)
     */
    function allPairsLength() external view override returns (uint256) {
        return allPairs.length;
    }

    /**
     * @dev Creates a new pair for two given tokens. The exact amount of the pair creation fee
     * defined in StreAMMProtocolFee contract has to be sent by function call. The pair is created
     * for the two tokens, the fee is transferred to the fee receiving address and the pair
     * is initialized with the needed contract dependencies.
     * @param tokenA the address of the one desired token contract
     * @param tokenB the address of the other desired token contract
     * @return pair the address of the created pair contract
     */
    function createPair(
        address tokenA,
        address tokenB,
        address[] memory poolOwners
    ) external payable override returns (address pair) {
        require(activated || (!activated && msg.sender == owner()), 'StreAMM: Not activated');
        require(tokenA != tokenB, 'StreAMM: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'StreAMM: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'StreAMM: PAIR_EXISTS'); // single check is sufficient

        // charge fee on pair creation
        IStreAMMProtocolFee protocolFee = IStreAMMProtocolFee(streAMMProtocolFee);
        uint256 creationFee = getPairCreationFee();
        require(msg.value == creationFee, 'StreAMM: Sent value is not equal to fee.');
        address payable feeReceiver = protocolFee.feeTo();
        (bool sent, ) = feeReceiver.call{value: creationFee}('');
        require(sent, 'Failed to send creation fee');

        // create pair
        bytes memory bytecode = type(StreAMMPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        //initialize pair with given tokens and owners
        IStreAMMPair(pair).initialize(token0, token1, poolOwners, liquidityTopLocker, streAMMProtocolFee);

        // store pair references
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        isPairContract[pair] = true;
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    /**
     * @dev Returns the absolute value of the pair creation fee
     */
    function getPairCreationFee() public view override returns (uint256 creationFee) {
        creationFee = IStreAMMProtocolFee(streAMMProtocolFee).pairCreationFee();
    }

    /**
     * @dev Returns if a given country code is valid. The CountryList contract is used for checking
     * if a country code is valid.
     */
    function isCountryCodeValid(uint16 _countryCode) external view override returns (bool isValid) {
        isValid = ICountryList(countryList).countryIsValid(_countryCode);
    }

    /**
     * @dev Returns if a given address has discounted trades balance. The StreAMMDiscountedTrading contract
     * is used for checking if a trader has discounted trades left.
     */
    function hasDiscountedTrades(address _trader) external view override returns (bool hasDisTrades) {
        hasDisTrades = IStreAMMDiscountedTrading(streAMMDiscountedTrading).hasDiscountedTrades(_trader);
    }

    /**
     * @dev Returns if a given token address is whitelisted. The StreAMMTokenWhitelist contract is used
     * for checking if a token is whitelisted.
     */
    function isTokenWhitelisted(address _token) external view override returns (bool isWhitelisted) {
        isWhitelisted = IStreAMMTokenWhitelist(streAMMTokenWhitelist).whiteListedTokens(_token);
    }

    /**
     * @dev Decreases the discounted trades balance of a given trader. The StreAMMDiscountedTrading contract is
     * used to decrease the balance of discounted trades.
     */
    function decreaseDiscountedTrades(address _trader) external override {
        require(isPairContract[msg.sender], 'StreAMMFactory: FORBIDDEN');
        IStreAMMDiscountedTrading(streAMMDiscountedTrading).decreaseTrades(_trader);
    }

    /* -----------------------------------------------------------------------------------------------------------
     * --------------------------------------- ONLY OWNER SETTER FUNCTIONS ---------------------------------------
     * -----------------------------------------------------------------------------------------------------------
     */
    /**
     * @dev activates the factory and allows anybody to create new pairs
     */
    function activate() external onlyOwner {
        activated = true;
    }

    /**
     * @dev set address of StreAMMProtocolFee contract
     */
    function setProtocolFee(address _protocolFee) external onlyOwner {
        require(_protocolFee != address(0), 'StreAMMFactory: Zero address');
        streAMMProtocolFee = _protocolFee;
    }

    /**
     * @dev set address of StreAMMDiscountedTrading contract
     */
    function setDiscountedTrading(address _discountedTrading) external onlyOwner {
        require(_discountedTrading != address(0), 'StreAMMFactory: Zero address');
        streAMMDiscountedTrading = _discountedTrading;
    }

    /**
     * @dev set address of StreAMMTokenWhitelist contract
     */
    function setTokenWhitelist(address _tokenWhitelist) external onlyOwner {
        require(_tokenWhitelist != address(0), 'StreAMMFactory: Zero address');
        streAMMTokenWhitelist = _tokenWhitelist;
    }

    /**
     * @dev set address of StreAMMRouter contract (periphery)
     */
    function setRouter(address _router) external onlyOwner {
        require(_router != address(0), 'StreAMMFactory: Zero address');
        router = _router;
    }

    /**
     * @dev set address of CountryList contract
     */
    function setCountryList(address _countryList) external onlyOwner {
        require(_countryList != address(0), 'StreAMMFactory: Zero address');
        countryList = _countryList;
    }

    /**
     * @dev set address of LiquidityTopLockers contract
     */
    function setTopLockers(address _topLockers) external onlyOwner {
        require(_topLockers != address(0), 'StreAMMFactory: Zero address');
        liquidityTopLocker = _topLockers;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))

// range: [0, 2**112 - 1]
// resolution: 1 / 2**112

library UQ112x112 {
    uint224 constant Q112 = 2**112;

    // encode a uint112 as a UQ112x112
    function encode(uint112 y) internal pure returns (uint224 z) {
        z = uint224(y) * Q112; // never overflows
    }

    // divide a UQ112x112 by a uint112, returning a UQ112x112
    function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {
        z = x / uint224(y);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

// a library for performing various math operations

library Math {
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

/**
 * @dev Interface of the StreAMMTokenWhitelist contract
 */
interface IStreAMMTokenWhitelist {
    /**
     * @dev Returns if a given token is whitelisted. This function is used by the
     * StreAMMPair to check if the stream fee should be collected for a specific token.
     * Whitelisted tokens should bring back a stream of value to the project owners (TopLockers).
     */
    function whiteListedTokens(address token) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

/**
 * @dev Interface of the StreAMMProtocolFee contract
 */
interface IStreAMMProtocolFee {
    /**
     * @dev get the default stream fee applied to a new created pair
     */
    function defaultLiquidityLockerFee() external view returns (uint256);

    /**
     * @dev get the default LP fee applied to a new created pair
     */
    function defaultLPFee() external view returns (uint256);

    /**
     * @dev get the StreAMM fee applied all pairs
     */
    function streAMMFee() external view returns (uint256);

    /**
     * @dev get the address of the StreAMM and creation fee receiving account
     */
    function feeTo() external view returns (address payable);

    /**
     * @dev get the absolute pair creation fee in native token charged on every new pair
     * creation
     */
    function pairCreationFee() external view returns (uint256);

    /**
     * @dev get the relative fee for discounted trades
     */
    function discountedFee() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import './IStreAMMProtocolFee.sol';

/**
 * @dev Interface of the StreAMMPairFee contract
 */
interface IStreAMMPairFee {
    /**
     * @dev Returns the address of the StreAMMFactory.
     */
    function factory() external view returns (address);

    /**
     * @dev Returns the stream protocol fee interface
     */
    function streAMMProtocolFee() external view returns (IStreAMMProtocolFee);

    /**
     * @dev Returns the relative value for the liquidity provider fee in parts per 10,000.
     * The liquidity provider fee is kept in the pool to let the shares of the liquidity
     * providers grow.
     */
    function liquidityProviderFee() external view returns (uint256);

    /**
     * @dev Returns the relative value for the stream fee in parts per 10,000. The stream fee
     * is calculated for whitelisted tokens (USDT, USDC, DAI, ...) and will be sent to the
     * liquidity top lockers of the swapped token registered in LiquidityTopLockers contract.
     * If the paired tokens are not whitelisted, the stream fee will be burned.
     */
    function liquidityLockerFee() external view returns (uint256);

    /**
     * @dev Returns the relative value for the total swapping fee in parts per 10,000.
     * The total fee is equal to the liquidity locker fee plus StreAMM fee plus liquidity
     * provider fee. For a discounted trade, the total fee is equal to the discounted fee.
     */
    function getTotalFee(bool discounted) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import './IStreAMMERC20.sol';
import './IStreAMMPairFee.sol';

/**
 * @dev Interface of StreAMMPair contract
 */
interface IStreAMMPair is IStreAMMERC20, IStreAMMPairFee {
    // define events
    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    /**
     * @dev Returns the minimum liquidity of a pair. The minimum liquidity is burned on initial token minting.
     */
    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    /**
     * @dev Returns the address of the pair's token0
     */
    function token0() external view returns (address);

    /**
     * @dev Returns the address of the pair's token1
     */
    function token1() external view returns (address);

    /**
     * @dev Returns the pair's country code. The country code is set by the router on the initial
     * liquidity adding.
     */
    function countryCode() external view returns (uint16);

    /**
     * @dev Returns the current reserves of the pair's two tokens and the timestamp of the last update.
     * The reserves are the total value of each token hold by the pair. They define the proportion of
     * tokens in this pool.
     */
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    /**
     * @dev Mints new StreAMMPair tokens to the given address and returns the minted liquidity.
     */
    function mint(address to) external returns (uint256 liquidity);

    /**
     * @dev Burns the sent pair tokens amount and sends back the equivalent amount of token0
     * and token1 to the given address. It returns the received amounts of each token.
     */
    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    /**
     * @dev Swaps token0 for token1 or reverse. Swap funds of a token(token0 or token1) has to be sent to
     * the pair contract and the desired output amount is transferred to the given address. This function
     * optimistcally transfers the output amount, calculates the input amount and checks, if the balances
     * are matching with the swapping fees set in StreAMMPairFee contract. It collects all fees defined in StreAMMPairFee
     * contract. A trader can swap with discounted fees, if he has discounted trading balance in
     * StreAMMDiscountedTrading contract.
     */
    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bool discounted,
        address sender
    ) external;

    /**
     * @dev Force balances to match reserves. Remaining tokens are sent to the given address.
     */
    function skim(address to) external;

    /**
     * @dev Forces reserves to match balances.
     */
    function sync() external;

    /**
     * @dev Initializes the pair contract with all needed contract addresses. This function is called by
     * the factory on pair creation.
     */
    function initialize(
        address tokenA,
        address tokenB,
        address[] memory owners,
        address liquidityTopLockerContract,
        address protocolFeeContract
    ) external;

    /**
     * @dev Set the country code of a pair. This function can only be called by the router. It is called
     * on initial adding liquidity to the pair.
     */
    function setCountryCode(uint16 _countryCode) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

/**
 * @dev Interface of the StreAMMFactory contract
 */
interface IStreAMMFactory {
    /**
     * @dev Emitted when a new pair is created.
     */
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    /**
     * @dev Returns if a given country code is valid. The CountryList contract is used for checking
     * if a country code is valid.
     */
    function isCountryCodeValid(uint16) external view returns (bool);

    /**
     * @dev Returns if a given token address is whitelisted. The StreAMMTokenWhitelist contract is used
     * for checking if a token is whitelisted.
     */
    function isTokenWhitelisted(address _token) external view returns (bool isWhitelisted);

    /**
     * @dev Returns if a given address has discounted trades balance. The StreAMMDiscountedTrading contract
     * is used for checking if a trader has discounted trades left.
     */
    function hasDiscountedTrades(address _trader) external view returns (bool);

    /**
     * @dev Returns the address of the router. It is used to check if the router called the
     * setCountryCode function of the StreAMMPair.
     */
    function router() external view returns (address);

    /**
     * @dev Returns the address of the StreAMMPair for two given tokens.
     */
    function getPair(address tokenA, address tokenB) external view returns (address pair);

    /**
     * @dev Returns the address of the StreAMMPair for the given index of the array with all pairs.
     */
    function allPairs(uint256) external view returns (address pair);

    /**
     * @dev Returns the number of all created StreAMMPairs.
     */
    function allPairsLength() external view returns (uint256);

    /**
     * @dev Creates a new StreAMMPair for the given two tokens and returns its address. The exact pair
     * creation fee has to be sent with the transaction call. Otherwise the creation will fail.
     */
    function createPair(
        address tokenA,
        address tokenB,
        address[] memory owners
    ) external payable returns (address pair);

    /**
     * @dev Returns the absolute value of the pair creation fee
     */
    function getPairCreationFee() external view returns (uint256 creationFee);

    /**
     * @dev Decreases the discounted trades balance of a given trader. The StreAMMDiscountedTrading contract is
     * used to decrease the balance of discounted trades.
     */
    function decreaseDiscountedTrades(address _trader) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

/**
 * @dev Interface of the StreAMMERC20 contract
 */
interface IStreAMMERC20 is IERC20 {
    /**
     * @dev Returns the name of the ERC20 token
     */
    function name() external pure returns (string memory);

    /**
     * @dev Returns the symbol of the ERC20 token
     */
    function symbol() external pure returns (string memory);

    /**
     * @dev Returns the decimals of the ERC20 token
     */
    function decimals() external pure returns (uint8);

    /**
     * @dev Returns the domain separator of the ERC20 token
     */
    function DOMAIN_SEPARATOR() external view returns (bytes32);

    /**
     * @dev Returns the domain separator of the ERC20 token
     */
    function PERMIT_TYPEHASH() external pure returns (bytes32);

    /**
     * @dev Returns the users nonces of the ERC20 token
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Permits a token to be transfered. It uses a signature for verification and calls the approve function.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

/**
 * @dev Interface of the StreAMMDiscountedTrading contract
 */
interface IStreAMMDiscountedTrading {
    /**
     * @dev returns if a given trader has discounted trades balance
     */
    function hasDiscountedTrades(address trader) external view returns (bool);

    /**
     * @dev decreases the discounted trades balance by one
     */
    function decreaseTrades(address trader) external;
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

/**
 * @dev Interface of the OwnableMultiple contract
 */
interface IOwnableMultiple {
    /**
     * @dev Returns owner addrass for given index
     */
    function owners(uint256) external view returns (address);

    /**
     * @dev Returns if an address is an Owner
     */
    function isOwner(address _caller) external view returns (bool);

    /**
     * @dev Returns the total number of owners
     */
    function ownersLength() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

/**
 * @dev Struct of a single liquidity locker
 */
struct LiquidityLocker {
    address feeTo; //address to send fee to
    address lockingAccount; //address of account locking tokens
    uint256 proportion; // proportion of total stake in parts per 10 000
}

/**
 * @dev Interface of the LiquidityTopLockers contract
 */
interface ILiquidityTopLockers {
    /**
     * @dev Registers a given locking address as top liquidity locker if there
     * are no other top 5 liquidity lockers with a higher locking amount.
     * @param _tokenAddress address of locked token
     * @param _feeReceiver address of stream fee receiver
     */
    function registerLiquidityLocker(address _tokenAddress, address _feeReceiver) external;

    /**
     * @dev Updates the proportions of lockers locked value for a specific token.
     * This function should be called by locking contract if a locker unlocks tokens.
     * @param token the locked token address
     */
    function updateProportions(address token) external;

    /**
     * @dev Checks if a specific token has at least on registered top locker.
     * @param token the locked token address
     * @return if the token has registered lockers
     */
    function hasLiquidityLockers(address token) external view returns (bool);

    /**
     * @dev Returns the smallest balance of all lockers for a specific token. This function
     * should be called before calling register to check the minimum required locked amount.
     * @param _token the locked token address
     * @return smallestBalance the smallest locked balance for the token
     */
    function getSmallestBalance(address _token) external view returns (uint256 smallestBalance);

    /**
     * @dev Returns the top liquidity lockers for a specific token
     * @param _token the locked token address
     * @return liqLockers the top liquidity lockers struct for the token
     */
    function getLiquidityLockers(address _token) external view returns (LiquidityLocker[5] memory liqLockers);
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

/**
 * @dev Interface of the CountryList contract
 */
interface ICountryList {
    /**
     * @dev Returns if a country code is valid.
     */
    function countryIsValid(uint16 _countryCode) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import './interfaces/IStreAMMPairFee.sol';
import './OwnableMultiple.sol';

/**
 * @title StreAMMPairFee
 * @dev Implements fees for swapping tokens.
 * All fees are used as parts per 10,000.
 * i.e. 200 is 2% and 10 is 0.1%
 */
abstract contract StreAMMPairFee is IStreAMMPairFee, OwnableMultiple {
    uint256 public constant FEE_PRECISION = 10000;
    uint256 public constant MAX_SWAPPING_FEE = 2500; // maximum fee per swap
    uint256 public override liquidityProviderFee; //relative fee for liquidity provider
    uint256 public override liquidityLockerFee; //relative fee for top lockers
    IStreAMMProtocolFee public override streAMMProtocolFee;
    address public override factory;

    /**
     * @dev admins are pool admins (pool creators: most likely project owners) and streAMM admins.
     * StreAMM admins are defined in factory contract and pool admins are stored here.
     */
    modifier onlyAdmin() {
        require(
            IOwnableMultiple(address(streAMMProtocolFee)).isOwner(msg.sender) || isOwner(msg.sender),
            'StreAMMPairFee: FORBIDDEN'
        );
        _;
    }

    /**
     * @dev set initial relative fees by pair creation
     * @param _protocolFees address of StreAMMProtocolFee contract
     * @param _owners array of addresses to grand owner rights for
     */
    function initializeFees(address _protocolFees, address[] memory _owners) internal {
        require(_protocolFees != address(0), 'StreAMMPairFee: Zero address');
        streAMMProtocolFee = IStreAMMProtocolFee(_protocolFees);
        liquidityProviderFee = streAMMProtocolFee.defaultLPFee();
        liquidityLockerFee = streAMMProtocolFee.defaultLiquidityLockerFee();
        _addOwners(_owners);
    }

    /**
     * @dev set fees for the pair by stream admin
     * @param _lpFee the relative liquidity provider fee in parts per 10,000
     * @param _llFee the relative liquidity locker fee in parts per 10,000
     */
    function setPairFees(uint256 _lpFee, uint256 _llFee) external onlyAdmin {
        require(_lpFee + _llFee + streAMMProtocolFee.streAMMFee() < MAX_SWAPPING_FEE, 'StreAMMPairFee: Fee too high');
        require(_llFee % 2 == 0, 'StreAMMPairFee: Liquidity locker fee should be even');
        liquidityProviderFee = _lpFee;
        liquidityLockerFee = _llFee;
    }

    /**
     * @dev get total relative fee for a trade
     * @param _discounted if the fee should be discounted
     */
    function getTotalFee(bool _discounted) public view override returns (uint256) {
        if (_discounted) return streAMMProtocolFee.discountedFee();
        return liquidityProviderFee + liquidityLockerFee + streAMMProtocolFee.streAMMFee();
    }

    /**
     * @dev a security function for StreAMM to reset pool owners and set new owners
     * @param _newOwners an array of new owner addresses for the pool
     */
    function streammSetPoolOwners(address[] memory _newOwners) external {
        require(IOwnableMultiple(address(streAMMProtocolFee)).isOwner(msg.sender), 'StreAMMPairFee: Not StreAMM admin');
        _removeOwners(owners);
        _addOwners(_newOwners);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import './StreAMMERC20.sol';
import './StreAMMPairFee.sol';
import './libraries/Math.sol';
import './libraries/UQ112x112.sol';
import './interfaces/IStreAMMPair.sol';
import './interfaces/IStreAMMFactory.sol';
import './interfaces/ILiquidityTopLockers.sol';

/**
 * @title StreAMMPair
 * @dev This contract represents a Pair of two tokens as an ERC20 token. LP tokens can be minted by providing
 * liquidity for the two tokens. Traders can swap one token of the pair for the other. A swaping fee is applied,
 * which is defined in a StreAMMPairFee contract. Top liquidity lockers (normally token project developers) are able to
 * receive a streaming fee as a continous income.
 */

contract StreAMMPair is IStreAMMPair, StreAMMERC20, StreAMMPairFee {
    using UQ112x112 for uint224;

    uint256 public constant override MINIMUM_LIQUIDITY = 10**3;
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));

    address public override token0;
    address public override token1;
    address public liquidityTopLocker; // contract with top liquidity lockers for tokens

    uint112 private reserve0; // uses single storage slot, accessible via getReserves
    uint112 private reserve1; // uses single storage slot, accessible via getReserves
    uint32 private blockTimestampLast; // uses single storage slot, accessible via getReserves

    uint256 public override price0CumulativeLast;
    uint256 public override price1CumulativeLast;
    uint256 public override kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event

    uint16 public override countryCode; // identifier of the country where the project is based

    // a liquidity locker fee is transferred to the top liquidity lockers on every 50th swap
    uint8[2] public swapCounter; // counts swaps for collected liquidity locker balance of both tokens
    uint112[2] public liqLockerFeeBalance; // tracks liquidity locker balance for both tokens which are transferred to top lockers
    address private constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    // reentrancy guard modifier
    uint256 private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'StreAMM: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    /**
     * @dev Get current reserves of token0 and token1
     * @return _reserve0 the current reserves of token0
     * @return _reserve1 the current reserves of token1
     * @return _blockTimestampLast the timstamp of the last update
     */
    function getReserves()
        public
        view
        override
        returns (
            uint112 _reserve0,
            uint112 _reserve1,
            uint32 _blockTimestampLast
        )
    {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

    /**
     * @dev Safely call the transfer function of an ERC20 token
     * @param token the address of the ERC20 token
     * @param to the address to send ERC20 tokens to
     * @param value the value to send safely
     */
    function _safeTransfer(
        address token,
        address to,
        uint256 value
    ) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'StreAMM: TRANSFER_FAILED');
    }

    constructor() {
        factory = msg.sender;
    }

    /**
     * @dev Initialize the pool with needed contract addresses.
     * It is called once by the factory at time of deployment.
     * @param _token0 the address of token0 (ERC20)
     * @param _token1 the address of token1 (ERC20)
     * @param _liquidityTopLocker the address of LiquidityTopLockers contract
     */
    function initialize(
        address _token0,
        address _token1,
        address[] memory _owners,
        address _liquidityTopLocker,
        address _streAMMProtocolFee
    ) external override {
        require(msg.sender == factory, 'StreAMM: FORBIDDEN'); // sufficient check
        token0 = _token0;
        token1 = _token1;
        countryCode = type(uint16).max; // initialize with invalid country code (is set on initial liq adding)
        liquidityTopLocker = _liquidityTopLocker;
        initializeFees(_streAMMProtocolFee, _owners);
    }

    /**
     * @dev Called once by the router to set the country code initially.
     * It is set by initially adding liquidity to the pair (normally done by project owner).
     * @param _countryCode the code of the project based country
     */
    function setCountryCode(uint16 _countryCode) external override {
        require(msg.sender == IStreAMMFactory(factory).router(), 'StreAMM: FORBIDDEN');
        countryCode = _countryCode;
    }

    /**
     * @dev update reserves and, on the first call per block, price accumulators
     */
    function _update(
        uint256 balance0,
        uint256 balance1,
        uint112 _reserve0,
        uint112 _reserve1
    ) private {
        require(balance0 <= type(uint112).max && balance1 <= type(uint112).max, 'StreAMM: OVERFLOW');
        uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast;
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            // * never overflows
            price0CumulativeLast += uint256(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed;
            price1CumulativeLast += uint256(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) * timeElapsed;
        }
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
        blockTimestampLast = blockTimestamp;
        emit Sync(reserve0, reserve1);
    }

    /**
     * @dev Minting lp tokens based on the total supply and sent tokens (token0 and token1)
     * This low-level function should be called from a contract which performs important safety checks
     * @param to the address to mint lp tokens to
     * @return liquidity the minted lp liquidity
     */
    function mint(address to) external override lock returns (uint256 liquidity) {
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves(); // gas savings
        uint256 balance0 = IERC20(token0).balanceOf(address(this)) - liqLockerFeeBalance[0]; // liquidityLockerFee has to be excluded
        uint256 balance1 = IERC20(token1).balanceOf(address(this)) - liqLockerFeeBalance[1]; // liquidityLockerFee has to be excluded
        uint256 amount0 = balance0 - _reserve0;
        uint256 amount1 = balance1 - _reserve1;

        uint256 _currentTotalSupply = totalSupply(); // gas savings
        if (_currentTotalSupply == 0) {
            liquidity = Math.sqrt(amount0 * amount1) - MINIMUM_LIQUIDITY;
            _mint(address(0), MINIMUM_LIQUIDITY); // permanently lock the first MINIMUM_LIQUIDITY tokens
        } else {
            liquidity = Math.min(
                (amount0 * _currentTotalSupply) / _reserve0,
                (amount1 * _currentTotalSupply) / _reserve1
            );
        }
        require(liquidity > 0, 'StreAMM: INSUFFICIENT_LIQUIDITY_MINTED');
        _mint(to, liquidity);

        _update(balance0, balance1, _reserve0, _reserve1);
        emit Mint(msg.sender, amount0, amount1);
    }

    /**
     * @dev Burns lp tokens and sends corresponding amounts of token0 and token1.
     * This low-level function should be called from a contract which performs important safety checks
     * @param to the address to send token0 and token1 to in return
     * @return amount0 the amount of token0 sent to receiver
     * @return amount1 the amount of token1 sent to receiver
     */
    function burn(address to) external override lock returns (uint256 amount0, uint256 amount1) {
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves(); // gas savings
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings
        uint256 balance0 = IERC20(_token0).balanceOf(address(this)) - liqLockerFeeBalance[0]; // liquidityLockerFee has to be excluded
        uint256 balance1 = IERC20(_token1).balanceOf(address(this)) - liqLockerFeeBalance[1]; // liquidityLockerFee has to be excluded
        uint256 liquidity = balanceOf(address(this));

        uint256 _currentTotalSupply = totalSupply(); // gas savings
        amount0 = (liquidity * balance0) / _currentTotalSupply; // using balances ensures pro-rata distribution
        amount1 = (liquidity * balance1) / _currentTotalSupply; // using balances ensures pro-rata distribution
        require(amount0 > 0 && amount1 > 0, 'StreAMM: INSUFFICIENT_LIQUIDITY_BURNED');
        _burn(address(this), liquidity);
        _safeTransfer(_token0, to, amount0);
        _safeTransfer(_token1, to, amount1);
        balance0 = IERC20(_token0).balanceOf(address(this)) - liqLockerFeeBalance[0]; // liquidityLockerFee has to be excluded
        balance1 = IERC20(_token1).balanceOf(address(this)) - liqLockerFeeBalance[1]; // liquidityLockerFee has to be excluded

        _update(balance0, balance1, _reserve0, _reserve1);
        emit Burn(msg.sender, amount0, amount1, to);
    }

    /**
     * @dev Swapping token0 for token1 or reverse. A swapping fee will be charged on every swap. The swapping
     * fee is defined in StreAMMPairFee and StreAMMProtocolFee contracts. Tokens are transferred optimistically
     * before checking for balances and fees. Traders are able to swap with reduced trading fees checked by the factory.
     * This low-level function should be called from a contract which performs important safety checks
     * @param amount0Out the desired output amount of token0
     * @param amount1Out the desired output amount of token1
     * @param to the address to send the output amount to
     * @param discountedDesired if the trader wants to swap with reduced trading fees
     * @param sender the address of the swap caller only used if router is calling this function
     */
    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bool discountedDesired,
        address sender
    ) external override lock {
        // check who initiated the swap when calling function from router
        // the address of the function caller is needed to check for discounted trades
        address caller = msg.sender;
        if (msg.sender == IStreAMMFactory(factory).router()) caller = sender;
        // security checks
        require(amount0Out > 0 || amount1Out > 0, 'StreAMM: INSUFFICIENT_OUTPUT_AMOUNT');
        require(amount0Out < reserve0 && amount1Out < reserve1, 'StreAMM: INSUFFICIENT_LIQUIDITY');

        uint256 balance0;
        uint256 balance1;
        {
            // scope for _token{0,1}, avoids stack too deep errors
            address _token0 = token0;
            address _token1 = token1;
            require(to != _token0 && to != _token1, 'StreAMM: INVALID_TO');
            if (amount0Out > 0) _safeTransfer(_token0, to, amount0Out); // optimistically transfer tokens
            if (amount1Out > 0) _safeTransfer(_token1, to, amount1Out); // optimistically transfer tokens
            balance0 = IERC20(_token0).balanceOf(address(this)) - liqLockerFeeBalance[0]; // liquidityLockerFee has to be excluded
            balance1 = IERC20(_token1).balanceOf(address(this)) - liqLockerFeeBalance[1]; // liquidityLockerFee has to be excluded
        }
        // check for sufficient input amount
        uint256 amount0In = balance0 > reserve0 - amount0Out ? balance0 - (reserve0 - amount0Out) : 0;
        uint256 amount1In = balance1 > reserve1 - amount1Out ? balance1 - (reserve1 - amount1Out) : 0;
        require(amount0In > 0 || amount1In > 0, 'StreAMM: INSUFFICIENT_INPUT_AMOUNT');

        {
            // scope for reserve{0,1}Adjusted, avoids stack too deep errors
            uint256[2] memory transferredFee;
            bool discountedTrade;

            // check if the caller has discounted trades if requested
            if (discountedDesired) discountedTrade = IStreAMMFactory(factory).hasDiscountedTrades(caller);

            if (!discountedTrade) {
                // transfer normal defined fees (streAMMFee and liquidityLockerFee) for a swap - keep lp fee in contract
                transferredFee = _transferFees(amount0In, amount1In);
            } else {
                // swap discounted - no fees transferred. Discounted fee kept in contract
                IStreAMMFactory(factory).decreaseDiscountedTrades(caller);
            }

            // check balances against transferred amounts and fees
            uint256 totalFee = getTotalFee(discountedTrade);
            uint256 balance0Adjusted = balance0 * FEE_PRECISION - amount0In * totalFee;
            uint256 balance1Adjusted = balance1 * FEE_PRECISION - amount1In * totalFee;
            require(
                balance0Adjusted * balance1Adjusted >= uint256(reserve0) * reserve1 * (FEE_PRECISION**2),
                'StreAMM: INVALID BALANCES'
            );
            _update(balance0 - transferredFee[0], balance1 - transferredFee[1], reserve0, reserve1);
        }

        emit Swap(caller, amount0In, amount1In, amount0Out, amount1Out, to);
    }

    /**
     * @dev This function uses _transferStreAMMFees and _transferLiqLockerFees to collect defined
     * fees for a token swap.
     * This function is only called by the swap function.
     * @param amount0In the input amount of token0
     * @param amount1In the input amount of token1
     * @return transferredFee the total amount of transferred fees
     */
    function _transferFees(uint256 amount0In, uint256 amount1In) private returns (uint256[2] memory transferredFee) {
        // check if tokens are whitelisted
        bool token0Whitelisted = IStreAMMFactory(factory).isTokenWhitelisted(token0);
        bool token1Whitelisted = IStreAMMFactory(factory).isTokenWhitelisted(token1);

        (uint256 streammFeeAmount0, uint256 streammFeeAmount1) = _transferStreAMMFees(
            amount0In,
            amount1In,
            token0Whitelisted,
            token1Whitelisted
        );
        (uint256 liqLockerFeeAmount0, uint256 liqLockerFeeAmount1) = _transferLiqLockerFees(
            amount0In,
            amount1In,
            token0Whitelisted,
            token1Whitelisted
        );
        transferredFee[0] = liqLockerFeeAmount0 + streammFeeAmount0;
        transferredFee[1] = liqLockerFeeAmount1 + streammFeeAmount1;
    }

    /**
     * @dev Uses StreAMMProtocolFee contract to calculate the StreAAM fees for both tokens and sends them
     * to the StreAAM fee receiver. The amount of the tokens are proportional to the input amount.
     * This function is only called by the _transferFees function.
     * @param amount0In the input amount of token0
     * @param amount1In the input amount of token1
     * @return streammFeeAmount0 the total amount of transferred StreAAM fee for token0
     * @return streammFeeAmount1 the total amount of transferred StreAAM fee for token1
     */
    function _transferStreAMMFees(
        uint256 amount0In,
        uint256 amount1In,
        bool token0Whitelisted,
        bool token1Whitelisted
    ) private returns (uint256 streammFeeAmount0, uint256 streammFeeAmount1) {
        // get StreAMM fee and its receiver from StreAMMProtocolFee
        IStreAMMProtocolFee protocolFee = IStreAMMProtocolFee(streAMMProtocolFee);
        uint256 streAMMFeeHalf = protocolFee.streAMMFee() / 2; // in parts per 10 000
        uint112 reservesProportion = (reserve1 * 1000000) / reserve0; // precision multiplier 1,000,000

        // calculate fees for token0In - values for precisions: 10,000(fee), 1,000,000(reserves)
        if (amount0In > 0) {
            streammFeeAmount0 = (amount0In * streAMMFeeHalf) / FEE_PRECISION;
            streammFeeAmount1 = (amount0In * reservesProportion * streAMMFeeHalf) / FEE_PRECISION / 1000000;
        }

        // calculate fees for token1In - values for precisions: FEE_PRECISION(fee), 1000000(reserves)
        if (amount1In > 0) {
            streammFeeAmount0 = (amount1In * streAMMFeeHalf * 1000000) / reservesProportion / FEE_PRECISION;
            streammFeeAmount1 = (amount1In * streAMMFeeHalf) / FEE_PRECISION;
        }
        // transfer StreAMM fee for both tokens to StreAMM fee receiver
        if (token0Whitelisted) {
            _safeTransfer(token0, protocolFee.feeTo(), streammFeeAmount0);
        } else {
            _safeTransfer(token0, BURN_ADDRESS, streammFeeAmount0);
        }
        if (token1Whitelisted) {
            _safeTransfer(token1, protocolFee.feeTo(), streammFeeAmount1);
        } else {
            _safeTransfer(token1, BURN_ADDRESS, streammFeeAmount1);
        }
    }

    /**
     * @dev Transfers the liquidity locker fees for both tokens.
     * The liquidity locker fee is calculated for whitelisted tokens. If one token is whitelisted,
     * this token will be charged for the liquidity locker fee. If both tokens are whitelisted,
     * the fee is split up on both tokens (50/50). If no token is whitelisted, the liquidity locker
     * fee is burned (50/50). This function is only called by the _transferFees function.
     * @param amount0In the input amount of token0
     * @param amount1In the input amount of token1
     * @return liqLockerFeeAmount0 the total amount of transferred liquidity locker fee for token0
     * @return liqLockerFeeAmount1 the total amount of transferred liquidity locker fee for token1
     */
    function _transferLiqLockerFees(
        uint256 amount0In,
        uint256 amount1In,
        bool token0Whitelisted,
        bool token1Whitelisted
    ) private returns (uint256 liqLockerFeeAmount0, uint256 liqLockerFeeAmount1) {
        uint112 reservesProportion = (reserve1 * 1000000) / reserve0; // precision multiplier 1,000,000

        address lockedToken; // address of the token with for top lockers

        // calculate liquidity locker fee for token0In - values for precisions: 10,000(fee), 1,000,000(reserves)
        if (amount0In > 0) {
            if ((token0Whitelisted && token1Whitelisted) || (!token0Whitelisted && !token1Whitelisted)) {
                // split liquidity locker fee up to both tokens - divide by 2
                lockedToken = token0;
                liqLockerFeeAmount0 = (amount0In * liquidityLockerFee) / 2 / FEE_PRECISION;
                liqLockerFeeAmount1 =
                    (amount0In * liquidityLockerFee * reservesProportion) /
                    2 /
                    FEE_PRECISION /
                    1000000;
            } else if (token0Whitelisted) {
                lockedToken = token1;
                liqLockerFeeAmount0 = (amount0In * liquidityLockerFee) / FEE_PRECISION;
            } else if (token1Whitelisted) {
                lockedToken = token0;
                liqLockerFeeAmount1 = (amount0In * liquidityLockerFee * reservesProportion) / FEE_PRECISION / 1000000;
            }
        }

        // calculate fees for token1In - values for precisions: 10,000(fee), 1,000,000(reserves)
        if (amount1In > 0) {
            if ((token0Whitelisted && token1Whitelisted) || (!token0Whitelisted && !token1Whitelisted)) {
                // split liquidity locker fee up to both tokens - devide by 2
                lockedToken = token1;
                liqLockerFeeAmount0 =
                    (amount1In * liquidityLockerFee * 1000000) /
                    reservesProportion /
                    2 /
                    FEE_PRECISION;
                liqLockerFeeAmount1 = (amount1In * liquidityLockerFee) / 2 / FEE_PRECISION;
            } else if (token0Whitelisted) {
                lockedToken = token1;
                liqLockerFeeAmount0 = (amount1In * liquidityLockerFee * 1000000) / reservesProportion / FEE_PRECISION;
            } else if (token1Whitelisted) {
                lockedToken = token0;
                liqLockerFeeAmount1 = (amount1In * liquidityLockerFee) / FEE_PRECISION;
            }
        }

        //collect liquidity locker fee
        if (liqLockerFeeAmount0 > 0)
            _collectLiqLockerFee(token0, lockedToken, liqLockerFeeAmount0, 0, !token0Whitelisted && !token1Whitelisted);
        if (liqLockerFeeAmount1 > 0)
            _collectLiqLockerFee(token1, lockedToken, liqLockerFeeAmount1, 1, !token0Whitelisted && !token1Whitelisted);
    }

    /**
     * @dev Uses LiquidityTopLocker contract to check if the token has top lockers and collect the
     * liquidity locker fee by storing it in the liqLockerBalance variable. On every 50th trade of
     * a token, the liquidity locker fee will be send to the top liquidity providers pending on
     * their locked proportion. If there are no top liquidity lockers, the tokens are sent to the
     * StreAMM address. This function is only called by the _transferFees function which is called
     * by the swap function.
     * @param whitelistedToken the address of the fee token (token0 or token1)
     * @param lockedToken the address of the token used for top lockers
     * @param liqLockerFeeAmount the amount of the liquidity locker fee for this swap
     * @param index the index of the fee token (0 or 1) for token0 or token1
     */
    function _collectLiqLockerFee(
        address whitelistedToken,
        address lockedToken,
        uint256 liqLockerFeeAmount,
        uint8 index,
        bool burnTokens
    ) private {
        if (burnTokens) {
            _safeTransfer(whitelistedToken, BURN_ADDRESS, liqLockerFeeAmount);
        } else {
            // collect liquidity locker fee for top lockers
            ILiquidityTopLockers topLockers = ILiquidityTopLockers(liquidityTopLocker);

            // increment swap counter and accumulate collected liquidity locker fees
            if (topLockers.hasLiquidityLockers(lockedToken)) {
                liqLockerFeeBalance[index] += uint112(liqLockerFeeAmount);

                // transfer liquidity locker fees to top liquidity provider on every 50th trade
                if (swapCounter[index] == 50) {
                    LiquidityLocker[5] memory topLiqLockers = topLockers.getLiquidityLockers(lockedToken);
                    for (uint8 i; i < topLiqLockers.length; i++) {
                        // proportion in parts per 10,000
                        if (topLiqLockers[i].proportion > 0) {
                            _safeTransfer(
                                whitelistedToken,
                                topLiqLockers[i].feeTo,
                                (liqLockerFeeBalance[index] * topLiqLockers[i].proportion) / FEE_PRECISION
                            );
                        }
                    }
                    // reset liquidity locker fee values
                    swapCounter[index] = 0;
                    liqLockerFeeBalance[index] = 0;
                } else {
                    swapCounter[index]++;
                }
            } else {
                // send liquidity locker fee to StreAMM address if there are no liquidity lockers
                address streAMMFeeReceiver = IStreAMMProtocolFee(streAMMProtocolFee).feeTo();
                _safeTransfer(whitelistedToken, streAMMFeeReceiver, liqLockerFeeAmount);
            }
        }
    }

    /**
     * @dev Force balances to match reserves
     * @param to the address to send remaining tokens to
     */
    function skim(address to) external override lock {
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings
        _safeTransfer(_token0, to, IERC20(_token0).balanceOf(address(this)) - reserve0 - liqLockerFeeBalance[0]);
        _safeTransfer(_token1, to, IERC20(_token1).balanceOf(address(this)) - reserve1 - liqLockerFeeBalance[1]);
    }

    /**
     * @dev Force reserves to match balances
     */
    function sync() external override lock {
        _update(
            IERC20(token0).balanceOf(address(this)) - liqLockerFeeBalance[0],
            IERC20(token1).balanceOf(address(this)) - liqLockerFeeBalance[1],
            reserve0,
            reserve1
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import './interfaces/IStreAMMERC20.sol';

contract StreAMMERC20 is IStreAMMERC20 {
    string private constant _name = 'StreAMM LPs';
    string private constant _symbol = 'StreAMM-LP';
    uint8 private constant _decimals = 18;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balanceOf;
    mapping(address => mapping(address => uint256)) private _allowance;

    bytes32 private _DOMAIN_SEPARATOR;
    bytes32 private constant _PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    mapping(address => uint256) private _nonces;

    constructor() {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        _DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
                keccak256(bytes(_name)),
                keccak256(bytes('1')),
                chainId,
                address(this)
            )
        );
    }

    function _mint(address to, uint256 value) internal {
        _totalSupply = _totalSupply + value;
        _balanceOf[to] = _balanceOf[to] + value;
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint256 value) internal {
        _balanceOf[from] = _balanceOf[from] - value;
        _totalSupply = _totalSupply - value;
        emit Transfer(from, address(0), value);
    }

    function _approve(
        address owner,
        address spender,
        uint256 value
    ) private {
        _allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    ) private returns (bool) {
        _balanceOf[from] = _balanceOf[from] - value;
        _balanceOf[to] = _balanceOf[to] + value;
        emit Transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint256 value) external override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external override returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external override returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, 'ERC20: decreased allowance below zero');
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function transfer(address to, uint256 value) external override returns (bool) {
        return _transfer(msg.sender, to, value);
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override returns (bool) {
        if (_allowance[from][msg.sender] != type(uint256).max) {
            _allowance[from][msg.sender] = _allowance[from][msg.sender] - value;
        }
        return _transfer(from, to, value);
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override {
        require(deadline >= block.timestamp, 'StreAMM: EXPIRED');
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                _DOMAIN_SEPARATOR,
                keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, _nonces[owner]++, deadline))
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner, 'StreAMM: INVALID_SIGNATURE');
        _approve(owner, spender, value);
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner) public view override returns (uint256) {
        return _balanceOf[owner];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowance[owner][spender];
    }

    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _DOMAIN_SEPARATOR;
    }

    function PERMIT_TYPEHASH() external pure override returns (bytes32) {
        return _PERMIT_TYPEHASH;
    }

    function nonces(address owner) external view override returns (uint256) {
        return _nonces[owner];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import './interfaces/IOwnableMultiple.sol';

abstract contract OwnableMultiple is IOwnableMultiple {
    address[] public override owners; // streAMM owners array. Owners are allowed to change pool owners and fees

    event OwnerAdded(address indexed newOwner);
    event OwnerRemoved(address indexed oldOwner);

    modifier onlyOwner() {
        require(isOwner(msg.sender), 'Ownable: caller is not the owner');
        _;
    }

    /**
     * @dev adds an address to Owner list
     */
    function addOwner(address _newOwner) public onlyOwner {
        _addOwner(_newOwner);
    }

    /**
     * @dev adds an address to Owner list
     */
    function addOwners(address[] memory _newOwners) public onlyOwner {
        _addOwners(_newOwners);
    }

    /**
     * @dev removes an array of addresses from Owner list
     */
    function removeOwners(address[] memory _oldOwners) external onlyOwner {
        require(_oldOwners.length < ownersLength(), 'Ownable: Can not remove all owners');
        _removeOwners(_oldOwners);
    }

    /**
     * @dev Returns if an address is an Owner
     */
    function isOwner(address _caller) public view override returns (bool) {
        for (uint256 i; i < owners.length; i++) {
            if (owners[i] == _caller) return true;
        }
        return false;
    }

    /**
     * @dev Returns the total number of owners
     */
    function ownersLength() public view override returns (uint256) {
        return owners.length;
    }

    /**
     * @dev internal function for adding an array of address to Owner list
     */
    function _addOwners(address[] memory _newOwners) internal {
        for (uint256 i; i < _newOwners.length; i++) {
            _addOwner(_newOwners[i]);
        }
    }

    /**
     * @dev internal function for adding an address to Owner list
     */
    function _addOwner(address _newOwner) internal {
        bool exists;
        for (uint256 j; j < owners.length; j++) {
            if (owners[j] == _newOwner) {
                exists = true;
                break;
            }
        }
        if (!exists) {
            owners.push(_newOwner);
            emit OwnerAdded(_newOwner);
        }
    }

    /**
     * @dev internal function for removing an array of addresses from Owner list
     */
    function _removeOwners(address[] memory _oldOwners) internal {
        for (uint256 i; i < _oldOwners.length; i++) {
            _removeOwner(_oldOwners[i]);
        }
    }

    /**
     * @dev internal function for deleting an address from Owner list
     */
    function _removeOwner(address _oldOwner) internal {
        for (uint256 i; i < owners.length; i++) {
            if (owners[i] == _oldOwner) {
                owners[i] = owners[owners.length - 1];
                owners.pop();
                emit OwnerRemoved(_oldOwner);
                break;
            }
        }
    }
}

// SPDX-License-Identifier: MIT
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
    function allowance(address owner, address spender) external view returns (uint256);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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