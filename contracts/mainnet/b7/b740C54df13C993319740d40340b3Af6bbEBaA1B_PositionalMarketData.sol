// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Inheritance
import "./Position.sol";
import "./PositionalMarket.sol";
import "./PositionalMarketManager.sol";
import "../RangedMarkets/RangedMarket.sol";
import "../RangedMarkets/RangedMarketsAMM.sol";
import "../interfaces/IThalesAMM.sol";
import "../utils/proxy/solidity-0.8.0/ProxyOwned.sol";
import "../utils/proxy/solidity-0.8.0/ProxyPausable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract PositionalMarketData is Initializable, ProxyOwned, ProxyPausable {
    struct OptionValues {
        uint up;
        uint down;
    }

    struct Deposits {
        uint deposited;
    }

    struct Resolution {
        bool resolved;
        bool canResolve;
    }

    struct OraclePriceAndTimestamp {
        uint price;
        uint updatedAt;
    }

    // used for things that don't change over the lifetime of the contract
    struct MarketParameters {
        address creator;
        PositionalMarket.Options options;
        PositionalMarket.Times times;
        PositionalMarket.OracleDetails oracleDetails;
        PositionalMarketManager.Fees fees;
    }

    struct MarketData {
        OraclePriceAndTimestamp oraclePriceAndTimestamp;
        Deposits deposits;
        Resolution resolution;
        PositionalMarket.Phase phase;
        PositionalMarket.Side result;
        OptionValues totalSupplies;
    }

    struct AccountData {
        OptionValues balances;
    }

    struct ActiveMarketsPriceImpact {
        address market;
        int upPriceImpact;
        int downPriceImpact;
    }

    struct ActiveMarketsLiquidity {
        address market;
        uint upLiquidity;
        uint downLiquidity;
    }

    struct ActiveMarketsPrices {
        address market;
        uint upPrice;
        uint downPrice;
    }

    struct RangedMarketPricesAndLiqudity {
        uint inPrice;
        uint outPrice;
        uint inLiquidity;
        uint outLiquidity;
    }

    uint private constant ONE = 1e18;

    address public manager;
    address public thalesAMM;
    address public rangedMarketsAMM;

    function initialize(address _owner) external initializer {
        setOwner(_owner);
    }

    /// @notice getMarketParameters returns market details
    /// @param market PositionalMarket
    /// @return MarketParameters
    function getMarketParameters(PositionalMarket market) external view returns (MarketParameters memory) {
        (Position up, Position down) = market.options();
        (uint maturityDate, uint expiryDate) = market.times();
        (bytes32 key, uint strikePrice, uint finalPrice, bool customMarket, address iOracleInstanceAddress) = market
            .oracleDetails();
        (uint poolFee, uint creatorFee) = market.fees();

        MarketParameters memory data = MarketParameters(
            market.creator(),
            PositionalMarket.Options(up, down),
            PositionalMarket.Times(maturityDate, expiryDate),
            PositionalMarket.OracleDetails(key, strikePrice, finalPrice, customMarket, iOracleInstanceAddress),
            PositionalMarketManager.Fees(poolFee, creatorFee)
        );

        return data;
    }

    /// @notice getMarketData returns market details
    /// @param market PositionalMarket
    /// @return MarketData
    function getMarketData(PositionalMarket market) external view returns (MarketData memory) {
        (uint price, uint updatedAt) = market.oraclePriceAndTimestamp();
        (uint upSupply, uint downSupply) = market.totalSupplies();

        return
            MarketData(
                OraclePriceAndTimestamp(price, updatedAt),
                Deposits(market.deposited()),
                Resolution(market.resolved(), market.canResolve()),
                market.phase(),
                market.result(),
                OptionValues(upSupply, downSupply)
            );
    }

    /// @notice getAccountMarketData returns account balances
    /// @param market PositionalMarket
    /// @param account address of an account
    /// @return AccountData
    function getAccountMarketData(PositionalMarket market, address account) external view returns (AccountData memory) {
        (uint upBalance, uint downBalance) = market.balancesOf(account);

        return AccountData(OptionValues(upBalance, downBalance));
    }

    /// @notice getPriceImpactForAllActiveMarkets returns price impact for all active markets
    /// @return ActiveMarketsPriceImpact
    function getPriceImpactForAllActiveMarkets() external view returns (ActiveMarketsPriceImpact[] memory) {
        address[] memory activeMarkets = PositionalMarketManager(manager).activeMarkets(
            0,
            PositionalMarketManager(manager).numActiveMarkets()
        );
        ActiveMarketsPriceImpact[] memory marketPriceImpact = new ActiveMarketsPriceImpact[](activeMarkets.length);
        for (uint i = 0; i < activeMarkets.length; i++) {
            marketPriceImpact[i].market = activeMarkets[i];

            if (IThalesAMM(thalesAMM).isMarketInAMMTrading(activeMarkets[i])) {
                marketPriceImpact[i].upPriceImpact = IThalesAMM(thalesAMM).buyPriceImpact(
                    activeMarkets[i],
                    IThalesAMM.Position.Up,
                    ONE
                );
                marketPriceImpact[i].downPriceImpact = IThalesAMM(thalesAMM).buyPriceImpact(
                    activeMarkets[i],
                    IThalesAMM.Position.Down,
                    ONE
                );
            }
        }
        return marketPriceImpact;
    }

    /// @notice getLiquidityForAllActiveMarkets returns liquidity for all active markets
    /// @return ActiveMarketsLiquidity
    function getLiquidityForAllActiveMarkets() external view returns (ActiveMarketsLiquidity[] memory) {
        address[] memory activeMarkets = PositionalMarketManager(manager).activeMarkets(
            0,
            PositionalMarketManager(manager).numActiveMarkets()
        );
        ActiveMarketsLiquidity[] memory marketLiquidity = new ActiveMarketsLiquidity[](activeMarkets.length);
        for (uint i = 0; i < activeMarkets.length; i++) {
            marketLiquidity[i].market = activeMarkets[i];

            if (IThalesAMM(thalesAMM).isMarketInAMMTrading(activeMarkets[i])) {
                marketLiquidity[i].upLiquidity = IThalesAMM(thalesAMM).availableToBuyFromAMM(
                    activeMarkets[i],
                    IThalesAMM.Position.Up
                );
                marketLiquidity[i].downLiquidity = IThalesAMM(thalesAMM).availableToBuyFromAMM(
                    activeMarkets[i],
                    IThalesAMM.Position.Down
                );
            }
        }
        return marketLiquidity;
    }

    /// @notice getPricesForAllActiveMarkets returns prices for all active markets
    /// @return ActiveMarketsPrices
    function getPricesForAllActiveMarkets() external view returns (ActiveMarketsPrices[] memory) {
        address[] memory activeMarkets = PositionalMarketManager(manager).activeMarkets(
            0,
            PositionalMarketManager(manager).numActiveMarkets()
        );
        ActiveMarketsPrices[] memory marketPrices = new ActiveMarketsPrices[](activeMarkets.length);
        for (uint i = 0; i < activeMarkets.length; i++) {
            marketPrices[i].market = activeMarkets[i];

            if (IThalesAMM(thalesAMM).isMarketInAMMTrading(activeMarkets[i])) {
                marketPrices[i].upPrice = IThalesAMM(thalesAMM).buyFromAmmQuote(
                    activeMarkets[i],
                    IThalesAMM.Position.Up,
                    ONE
                );
                marketPrices[i].downPrice = IThalesAMM(thalesAMM).buyFromAmmQuote(
                    activeMarkets[i],
                    IThalesAMM.Position.Down,
                    ONE
                );
            }
        }
        return marketPrices;
    }

    /// @notice getRangedMarketPricesAndLiquidity returns prices and liquidity for ranged market
    /// @param market RangedMarket
    /// @return RangedMarketPricesAndLiqudity
    function getRangedMarketPricesAndLiquidity(RangedMarket market)
        external
        view
        returns (RangedMarketPricesAndLiqudity memory)
    {
        uint inPrice = RangedMarketsAMM(rangedMarketsAMM).buyFromAmmQuote(market, RangedMarket.Position.In, ONE);
        uint outPrice = RangedMarketsAMM(rangedMarketsAMM).buyFromAmmQuote(market, RangedMarket.Position.Out, ONE);
        uint inLiquidity = RangedMarketsAMM(rangedMarketsAMM).availableToBuyFromAMM(market, RangedMarket.Position.In);
        uint outLiquidity = RangedMarketsAMM(rangedMarketsAMM).availableToBuyFromAMM(market, RangedMarket.Position.Out);

        return RangedMarketPricesAndLiqudity(inPrice, outPrice, inLiquidity, outLiquidity);
    }

    function setPositionalMarketManager(address _manager) external onlyOwner {
        manager = _manager;
        emit PositionalMarketManagerChanged(_manager);
    }

    function setThalesAMM(address _thalesAMM) external onlyOwner {
        thalesAMM = _thalesAMM;
        emit SetThalesAMM(_thalesAMM);
    }

    function setRangedMarketsAMM(address _rangedMarketsAMM) external onlyOwner {
        rangedMarketsAMM = _rangedMarketsAMM;
        emit SetRangedMarketsAMM(_rangedMarketsAMM);
    }

    event PositionalMarketManagerChanged(address _manager);
    event SetThalesAMM(address _thalesAMM);
    event SetRangedMarketsAMM(address _rangedMarketsAMM);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Inheritance
import "@openzeppelin/contracts-4.4.1/token/ERC20/IERC20.sol";
import "../interfaces/IPosition.sol";

// Libraries
import "@openzeppelin/contracts-4.4.1/utils/math/SafeMath.sol";

// Internal references
import "./PositionalMarket.sol";

contract Position is IERC20, IPosition {
    using SafeMath for uint;

    string public name;
    string public symbol;
    uint8 public constant decimals = 18;

    PositionalMarket public market;

    mapping(address => uint) public override balanceOf;
    uint public override totalSupply;

    // The argument order is allowance[owner][spender]
    mapping(address => mapping(address => uint)) private allowances;

    // Enforce a 1 cent minimum amount
    uint internal constant _MINIMUM_AMOUNT = 1e16;

    address public thalesAMM;

    bool public initialized = false;

    function initialize(
        string calldata _name,
        string calldata _symbol,
        address _thalesAMM
    ) external {
        require(!initialized, "Positional Market already initialized");
        initialized = true;
        name = _name;
        symbol = _symbol;
        market = PositionalMarket(msg.sender);
        thalesAMM = _thalesAMM;
    }

    /// @notice allowance inherited IERC20 function
    /// @param owner address of the owner
    /// @param spender address of the spender
    /// @return uint256 number of tokens
    function allowance(address owner, address spender) external view override returns (uint256) {
        if (spender == thalesAMM) {
            return type(uint256).max;
        } else {
            return allowances[owner][spender];
        }
    }

    /// @notice mint function mints Position token
    /// @param minter address of the minter
    /// @param amount value to mint token for
    function mint(address minter, uint amount) external onlyMarket {
        _requireMinimumAmount(amount);
        totalSupply = totalSupply.add(amount);
        balanceOf[minter] = balanceOf[minter].add(amount); // Increment rather than assigning since a transfer may have occurred.

        emit Transfer(address(0), minter, amount);
        emit Issued(minter, amount);
    }

    /// @notice exercise function exercises Position token
    /// @dev This must only be invoked after maturity.
    /// @param claimant address of the claiming address
    function exercise(address claimant) external onlyMarket {
        uint balance = balanceOf[claimant];

        if (balance == 0) {
            return;
        }

        balanceOf[claimant] = 0;
        totalSupply = totalSupply.sub(balance);

        emit Transfer(claimant, address(0), balance);
        emit Burned(claimant, balance);
    }

    /// @notice exerciseWithAmount function exercises Position token
    /// @dev This must only be invoked after maturity.
    /// @param claimant address of the claiming address
    /// @param amount amount of tokens for exercising
    function exerciseWithAmount(address claimant, uint amount) external override onlyMarket {
        require(amount > 0, "Can not exercise zero amount!");

        require(balanceOf[claimant] >= amount, "Balance must be greather or equal amount that is burned");

        balanceOf[claimant] = balanceOf[claimant] - amount;
        totalSupply = totalSupply.sub(amount);

        emit Transfer(claimant, address(0), amount);
        emit Burned(claimant, amount);
    }

    /// @notice expire function is used for Position selfdestruct
    /// @dev This must only be invoked after the exercise window is complete.
    /// Any options which have not been exercised will linger.
    /// @param beneficiary address of the Position token
    function expire(address payable beneficiary) external onlyMarket {
        selfdestruct(beneficiary);
    }

    /// @notice transfer is ERC20 function for transfer tokens
    /// @param _to address of the receiver
    /// @param _value value to be transferred
    /// @return success
    function transfer(address _to, uint _value) external override returns (bool success) {
        return _transfer(msg.sender, _to, _value);
    }

    /// @notice transferFrom is ERC20 function for transfer tokens
    /// @param _from address of the sender
    /// @param _to address of the receiver
    /// @param _value value to be transferred
    /// @return success
    function transferFrom(
        address _from,
        address _to,
        uint _value
    ) external override returns (bool success) {
        if (msg.sender != thalesAMM) {
            uint fromAllowance = allowances[_from][msg.sender];
            require(_value <= fromAllowance, "Insufficient allowance");
            allowances[_from][msg.sender] = fromAllowance.sub(_value);
        }
        return _transfer(_from, _to, _value);
    }

    /// @notice approve is ERC20 function for token approval
    /// @param _spender address of the spender
    /// @param _value value to be approved
    /// @return success
    function approve(address _spender, uint _value) external override returns (bool success) {
        require(_spender != address(0));
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /// @notice getBalanceOf ERC20 function gets token balance of an account
    /// @param account address of the account
    /// @return uint
    function getBalanceOf(address account) external view override returns (uint) {
        return balanceOf[account];
    }

    /// @notice getTotalSupply ERC20 function gets token total supply
    /// @return uint
    function getTotalSupply() external view override returns (uint) {
        return totalSupply;
    }

    /// @notice transfer is internal function for transfer tokens
    /// @param _from address of the sender
    /// @param _to address of the receiver
    /// @param _value value to be transferred
    /// @return success
    function _transfer(
        address _from,
        address _to,
        uint _value
    ) internal returns (bool success) {
        market.requireUnpaused();
        require(_to != address(0) && _to != address(this), "Invalid address");

        uint fromBalance = balanceOf[_from];
        require(_value <= fromBalance, "Insufficient balance");

        balanceOf[_from] = fromBalance.sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);

        emit Transfer(_from, _to, _value);
        return true;
    }

    /// @notice _requireMinimumAmount checks that amount is greater than minimum amount
    /// @param amount value to be checked
    /// @return uint amount
    function _requireMinimumAmount(uint amount) internal pure returns (uint) {
        require(amount >= _MINIMUM_AMOUNT || amount == 0, "Balance < $0.01");
        return amount;
    }

    modifier onlyMarket() {
        require(msg.sender == address(market), "Only market allowed");
        _;
    }

    event Issued(address indexed account, uint value);
    event Burned(address indexed account, uint value);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Inheritance
import "../OwnedWithInit.sol";
import "../interfaces/IPositionalMarket.sol";
import "../interfaces/IOracleInstance.sol";

// Libraries
import "@openzeppelin/contracts-4.4.1/utils/math/SafeMath.sol";

// Internal references
import "./PositionalMarketManager.sol";
import "./Position.sol";
import "@openzeppelin/contracts-4.4.1/token/ERC20/IERC20.sol";

contract PositionalMarket is OwnedWithInit, IPositionalMarket {
    /* ========== LIBRARIES ========== */

    using SafeMath for uint;

    /* ========== TYPES ========== */

    struct Options {
        Position up;
        Position down;
    }

    struct Times {
        uint maturity;
        uint expiry;
    }

    struct OracleDetails {
        bytes32 key;
        uint strikePrice;
        uint finalPrice;
        bool customMarket;
        address iOracleInstanceAddress;
    }

    struct PositionalMarketParameters {
        address owner;
        IERC20 sUSD;
        IPriceFeed priceFeed;
        address creator;
        bytes32 oracleKey;
        uint strikePrice;
        uint[2] times; // [maturity, expiry]
        uint deposit; // sUSD deposit
        address up;
        address down;
        address thalesAMM;
    }

    /* ========== STATE VARIABLES ========== */

    Options public options;
    Times public override times;
    OracleDetails public oracleDetails;
    PositionalMarketManager.Fees public override fees;
    IPriceFeed public priceFeed;
    IERC20 public sUSD;

    // `deposited` tracks the sum of all deposits.
    // This must explicitly be kept, in case tokens are transferred to the contract directly.
    uint public override deposited;
    uint public initialMint;
    address public override creator;
    bool public override resolved;

    /* ========== CONSTRUCTOR ========== */

    bool public initialized = false;

    function initialize(PositionalMarketParameters calldata _parameters) external {
        require(!initialized, "Positional Market already initialized");
        initialized = true;
        initOwner(_parameters.owner);
        sUSD = _parameters.sUSD;
        priceFeed = _parameters.priceFeed;
        creator = _parameters.creator;

        oracleDetails = OracleDetails(_parameters.oracleKey, _parameters.strikePrice, 0, false, address(0));

        times = Times(_parameters.times[0], _parameters.times[1]);

        deposited = _parameters.deposit;
        initialMint = _parameters.deposit;

        // Instantiate the options themselves
        options.up = Position(_parameters.up);
        options.down = Position(_parameters.down);

        options.up.initialize("Position Up", "UP", _parameters.thalesAMM);
        options.down.initialize("Position Down", "DOWN", _parameters.thalesAMM);
        if (initialMint > 0) {
            require(
                !_manager().onlyAMMMintingAndBurning() || msg.sender == _manager().getThalesAMM(),
                "Only allowed from ThalesAMM"
            );
            _mint(creator, initialMint);
        }

        // Note: the ERC20 base contract does not have a constructor, so we do not have to worry
        // about initializing its state separately
    }

    /// @notice phase returns market phase
    /// @return Phase
    function phase() external view override returns (Phase) {
        if (!_matured()) {
            return Phase.Trading;
        }
        if (!_expired()) {
            return Phase.Maturity;
        }
        return Phase.Expiry;
    }

    /// @notice oraclePriceAndTimestamp returns oracle key price and last updated timestamp
    /// @return price updatedAt
    function oraclePriceAndTimestamp() external view override returns (uint price, uint updatedAt) {
        return _oraclePriceAndTimestamp();
    }

    /// @notice oraclePrice returns oracle key price
    /// @return price
    function oraclePrice() external view override returns (uint price) {
        return _oraclePrice();
    }

    /// @notice canResolve checks if market can be resolved
    /// @return bool
    function canResolve() public view override returns (bool) {
        return !resolved && _matured();
    }

    /// @notice result calculates market result based on market strike price
    /// @return Side
    function result() external view override returns (Side) {
        return _result();
    }

    /// @notice balancesOf returns balances of an account
    /// @return up down
    function balancesOf(address account) external view override returns (uint up, uint down) {
        return _balancesOf(account);
    }

    /// @notice totalSupplies returns total supplies of op and down options
    /// @return up down
    function totalSupplies() external view override returns (uint up, uint down) {
        return (options.up.totalSupply(), options.down.totalSupply());
    }

    /// @notice getMaximumBurnable returns maximum burnable amount of an account
    /// @param account address of the account
    /// @return amount
    function getMaximumBurnable(address account) external view override returns (uint amount) {
        return _getMaximumBurnable(account);
    }

    /// @notice getOptions returns up and down positions
    /// @return up down
    function getOptions() external view override returns (IPosition up, IPosition down) {
        up = options.up;
        down = options.down;
    }

    /// @notice getOracleDetails returns data from oracle source
    /// @return key strikePrice finalPrice
    function getOracleDetails()
        external
        view
        override
        returns (
            bytes32 key,
            uint strikePrice,
            uint finalPrice
        )
    {
        key = oracleDetails.key;
        strikePrice = oracleDetails.strikePrice;
        finalPrice = oracleDetails.finalPrice;
    }

    /// @notice requireUnpaused ensures that manager is not paused
    function requireUnpaused() external view {
        _requireManagerNotPaused();
    }

    /// @notice mint mints up and down tokens
    /// @param value to mint options for
    function mint(uint value) external override duringMinting {
        require(
            !_manager().onlyAMMMintingAndBurning() || msg.sender == _manager().getThalesAMM(),
            "Only allowed from ThalesAMM"
        );
        if (value == 0) {
            return;
        }

        _mint(msg.sender, value);

        _incrementDeposited(value);
        _manager().transferSusdTo(msg.sender, address(this), _manager().transformCollateral(value));
    }

    /// @notice burnOptionsMaximum burns option tokens based on maximum burnable account amount
    function burnOptionsMaximum() external override {
        require(
            !_manager().onlyAMMMintingAndBurning() || msg.sender == _manager().getThalesAMM(),
            "Only allowed from ThalesAMM"
        );
        _burnOptions(msg.sender, _getMaximumBurnable(msg.sender));
    }

    /// @notice burnOptions burns option tokens based on amount
    function burnOptions(uint amount) external override {
        require(
            !_manager().onlyAMMMintingAndBurning() || msg.sender == _manager().getThalesAMM(),
            "Only allowed from ThalesAMM"
        );
        _burnOptions(msg.sender, amount);
    }

    /// @notice resolve function for resolving market if possible
    function resolve() external onlyOwner afterMaturity managerNotPaused {
        require(canResolve(), "Can not resolve market");
        uint price;
        uint updatedAt;

        (price, updatedAt) = _oraclePriceAndTimestamp();
        oracleDetails.finalPrice = price;

        resolved = true;

        emit MarketResolved(_result(), price, updatedAt, deposited, 0, 0);
    }

    /// @notice exerciseOptions is used for exercising options from resolved market
    function exerciseOptions() external override afterMaturity returns (uint) {
        // The market must be resolved if it has not been.
        if (!resolved) {
            _manager().resolveMarket(address(this));
        }

        // If the account holds no options, revert.
        (uint upBalance, uint downBalance) = _balancesOf(msg.sender);
        require(upBalance != 0 || downBalance != 0, "Nothing to exercise");

        // Each option only needs to be exercised if the account holds any of it.
        if (upBalance != 0) {
            options.up.exercise(msg.sender);
        }
        if (downBalance != 0) {
            options.down.exercise(msg.sender);
        }

        // Only pay out the side that won.
        uint payout = (_result() == Side.Up) ? upBalance : downBalance;
        emit OptionsExercised(msg.sender, payout);
        if (payout != 0) {
            _decrementDeposited(payout);
            sUSD.transfer(msg.sender, _manager().transformCollateral(payout));
        }
        return payout;
    }

    /// @notice expire is used for exercising options from resolved market
    function expire(address payable beneficiary) external onlyOwner {
        require(_expired(), "Unexpired options remaining");
        emit Expired(beneficiary);
        _selfDestruct(beneficiary);
    }

    /// @notice _priceFeed internal function returns PriceFeed contract address
    /// @return IPriceFeed
    function _priceFeed() internal view returns (IPriceFeed) {
        return priceFeed;
    }

    /// @notice _manager internal function returns PositionalMarketManager contract address
    /// @return PositionalMarketManager
    function _manager() internal view returns (PositionalMarketManager) {
        return PositionalMarketManager(owner);
    }

    /// @notice _matured internal function checks if market is matured
    /// @return bool
    function _matured() internal view returns (bool) {
        return times.maturity < block.timestamp;
    }

    /// @notice _expired internal function checks if market is expired
    /// @return bool
    function _expired() internal view returns (bool) {
        return resolved && (times.expiry < block.timestamp || deposited == 0);
    }

    /// @notice _oraclePrice internal function returns oracle key price from source
    /// @return price
    function _oraclePrice() internal view returns (uint price) {
        return _priceFeed().rateForCurrency(oracleDetails.key);
    }

    /// @notice _oraclePriceAndTimestamp internal function returns oracle key price and last updated timestamp from source
    /// @return price updatedAt
    function _oraclePriceAndTimestamp() internal view returns (uint price, uint updatedAt) {
        return _priceFeed().rateAndUpdatedTime(oracleDetails.key);
    }

    /// @notice _result internal function calculates market result based on market strike price
    /// @return Side
    function _result() internal view returns (Side) {
        uint price;
        if (resolved) {
            price = oracleDetails.finalPrice;
        } else {
            price = _oraclePrice();
        }

        return oracleDetails.strikePrice <= price ? Side.Up : Side.Down;
    }

    /// @notice _balancesOf internal function gets account balances of up and down tokens
    /// @param account address of an account
    /// @return up down
    function _balancesOf(address account) internal view returns (uint up, uint down) {
        return (options.up.getBalanceOf(account), options.down.getBalanceOf(account));
    }

    /// @notice _getMaximumBurnable internal function gets account maximum burnable amount
    /// @param account address of an account
    /// @return amount
    function _getMaximumBurnable(address account) internal view returns (uint amount) {
        (uint upBalance, uint downBalance) = _balancesOf(account);
        return (upBalance > downBalance) ? downBalance : upBalance;
    }

    /// @notice _incrementDeposited internal function increments deposited value
    /// @param value increment value
    /// @return _deposited
    function _incrementDeposited(uint value) internal returns (uint _deposited) {
        _deposited = deposited.add(value);
        deposited = _deposited;
        _manager().incrementTotalDeposited(value);
    }

    /// @notice _decrementDeposited internal function decrements deposited value
    /// @param value decrement value
    /// @return _deposited
    function _decrementDeposited(uint value) internal returns (uint _deposited) {
        _deposited = deposited.sub(value);
        deposited = _deposited;
        _manager().decrementTotalDeposited(value);
    }

    /// @notice _requireManagerNotPaused internal function ensures that manager is not paused
    function _requireManagerNotPaused() internal view {
        require(!_manager().paused(), "This action cannot be performed while the contract is paused");
    }

    /// @notice _mint internal function mints up and down tokens
    /// @param amount value to mint options for
    function _mint(address minter, uint amount) internal {
        options.up.mint(minter, amount);
        options.down.mint(minter, amount);

        emit Mint(Side.Up, minter, amount);
        emit Mint(Side.Down, minter, amount);
    }

    /// @notice _burnOptions internal function for burning up and down tokens
    /// @param account address of an account
    /// @param amount burning amount
    function _burnOptions(address account, uint amount) internal {
        require(amount > 0, "Can not burn zero amount!");
        require(_getMaximumBurnable(account) >= amount, "There is not enough options!");

        // decrease deposit
        _decrementDeposited(amount);

        // decrease up and down options
        options.up.exerciseWithAmount(account, amount);
        options.down.exerciseWithAmount(account, amount);

        // transfer balance
        sUSD.transfer(account, _manager().transformCollateral(amount));

        // emit events
        emit OptionsBurned(account, amount);
    }

    /// @notice _selfDestruct internal function for market self desctruct
    /// @param beneficiary address of a market
    function _selfDestruct(address payable beneficiary) internal {
        uint _deposited = deposited;
        if (_deposited != 0) {
            _decrementDeposited(_deposited);
        }

        // Transfer the balance rather than the deposit value in case there are any synths left over
        // from direct transfers.
        uint balance = sUSD.balanceOf(address(this));
        if (balance != 0) {
            sUSD.transfer(beneficiary, balance);
        }

        // Destroy the option tokens before destroying the market itself.
        options.up.expire(beneficiary);
        options.down.expire(beneficiary);
        selfdestruct(beneficiary);
    }

    modifier duringMinting() {
        require(!_matured(), "Minting inactive");
        _;
    }

    modifier afterMaturity() {
        require(_matured(), "Not yet mature");
        _;
    }

    modifier managerNotPaused() {
        _requireManagerNotPaused();
        _;
    }

    /* ========== EVENTS ========== */

    event Mint(Side side, address indexed account, uint value);
    event MarketResolved(
        Side result,
        uint oraclePrice,
        uint oracleTimestamp,
        uint deposited,
        uint poolFees,
        uint creatorFees
    );

    event OptionsExercised(address indexed account, uint value);
    event OptionsBurned(address indexed account, uint value);
    event Expired(address beneficiary);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Inheritance
import "../interfaces/IPositionalMarketManager.sol";
import "../utils/proxy/solidity-0.8.0/ProxyOwned.sol";
import "../utils/proxy/solidity-0.8.0/ProxyPausable.sol";

// Libraries
import "../utils/libraries/AddressSetLib.sol";
import "../utils/libraries/DateTime.sol";
import "@openzeppelin/contracts-4.4.1/utils/math/SafeMath.sol";

// Internal references
import "./PositionalMarketFactory.sol";
import "./PositionalMarket.sol";
import "./Position.sol";
import "../interfaces/IPositionalMarket.sol";
import "../interfaces/IPriceFeed.sol";
import "../interfaces/IThalesAMM.sol";
import "@openzeppelin/contracts-4.4.1/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract PositionalMarketManager is Initializable, ProxyOwned, ProxyPausable, IPositionalMarketManager {
    /* ========== LIBRARIES ========== */

    using SafeMath for uint;
    using AddressSetLib for AddressSetLib.AddressSet;

    /* ========== TYPES ========== */

    struct Fees {
        uint poolFee;
        uint creatorFee;
    }

    struct Durations {
        uint expiryDuration;
        uint maxTimeToMaturity;
    }

    /* ========== STATE VARIABLES ========== */

    Durations public override durations;
    uint public override capitalRequirement;

    bool public override marketCreationEnabled;
    bool public customMarketCreationEnabled;

    bool public onlyWhitelistedAddressesCanCreateMarkets;
    mapping(address => bool) public whitelistedAddresses;

    uint public override totalDeposited;

    AddressSetLib.AddressSet internal _activeMarkets;
    AddressSetLib.AddressSet internal _maturedMarkets;

    PositionalMarketManager internal _migratingManager;

    IPriceFeed public priceFeed;
    IERC20 public sUSD;

    address public positionalMarketFactory;

    bool public needsTransformingCollateral;

    uint public timeframeBuffer;
    uint256 public priceBuffer;

    mapping(bytes32 => mapping(uint => address[])) public marketsPerOracleKey;
    mapping(address => uint) public marketsStrikePrice;

    bool public override onlyAMMMintingAndBurning;

    function initialize(
        address _owner,
        IERC20 _sUSD,
        IPriceFeed _priceFeed,
        uint _expiryDuration,
        uint _maxTimeToMaturity
    ) external initializer {
        setOwner(_owner);
        priceFeed = _priceFeed;
        sUSD = _sUSD;

        // Temporarily change the owner so that the setters don't revert.
        owner = msg.sender;

        marketCreationEnabled = true;
        customMarketCreationEnabled = false;
        onlyWhitelistedAddressesCanCreateMarkets = false;

        setExpiryDuration(_expiryDuration);
        setMaxTimeToMaturity(_maxTimeToMaturity);
    }

    /// @notice isKnownMarket checks if market is among matured or active markets
    /// @param candidate Address of the market.
    /// @return bool
    function isKnownMarket(address candidate) public view override returns (bool) {
        return _activeMarkets.contains(candidate) || _maturedMarkets.contains(candidate);
    }

    /// @notice isActiveMarket checks if market is active market
    /// @param candidate Address of the market.
    /// @return bool
    function isActiveMarket(address candidate) public view override returns (bool) {
        return _activeMarkets.contains(candidate);
    }

    /// @notice numActiveMarkets returns number of active markets
    /// @return uint
    function numActiveMarkets() external view override returns (uint) {
        return _activeMarkets.elements.length;
    }

    /// @notice activeMarkets returns list of active markets
    /// @param index index of the page
    /// @param pageSize number of addresses per page
    /// @return address[] active market list
    function activeMarkets(uint index, uint pageSize) external view override returns (address[] memory) {
        return _activeMarkets.getPage(index, pageSize);
    }

    /// @notice numMaturedMarkets returns number of mature markets
    /// @return uint
    function numMaturedMarkets() external view override returns (uint) {
        return _maturedMarkets.elements.length;
    }

    /// @notice maturedMarkets returns list of matured markets
    /// @param index index of the page
    /// @param pageSize number of addresses per page
    /// @return address[] matured market list
    function maturedMarkets(uint index, uint pageSize) external view override returns (address[] memory) {
        return _maturedMarkets.getPage(index, pageSize);
    }

    /// @notice incrementTotalDeposited increments totalDeposited value
    /// @param delta increment amount
    function incrementTotalDeposited(uint delta) external onlyActiveMarkets notPaused {
        totalDeposited = totalDeposited.add(delta);
    }

    /// @notice decrementTotalDeposited decrements totalDeposited value
    /// @dev As individual market debt is not tracked here, the underlying markets
    /// need to be careful never to subtract more debt than they added.
    /// This can't be enforced without additional state/communication overhead.
    /// @param delta decrement amount
    function decrementTotalDeposited(uint delta) external onlyKnownMarkets notPaused {
        totalDeposited = totalDeposited.sub(delta);
    }

    /// @notice createMarket create market function
    /// @param oracleKey market oracle key
    /// @param strikePrice market strike price
    /// @param maturity  market maturity date
    /// @param initialMint initial sUSD to mint options for
    /// @return IPositionalMarket created market
    function createMarket(
        bytes32 oracleKey,
        uint strikePrice,
        uint maturity,
        uint initialMint
    )
        external
        override
        notPaused
        returns (
            IPositionalMarket // no support for returning PositionalMarket polymorphically given the interface
        )
    {
        if (onlyWhitelistedAddressesCanCreateMarkets) {
            require(whitelistedAddresses[msg.sender], "Only whitelisted addresses can create markets");
        }

        (bool canCreate, string memory message) = canCreateMarket(oracleKey, maturity, strikePrice);
        require(canCreate, message);

        uint expiry = maturity.add(durations.expiryDuration);

        PositionalMarket market = PositionalMarketFactory(positionalMarketFactory).createMarket(
            PositionalMarketFactory.PositionCreationMarketParameters(
                msg.sender,
                sUSD,
                priceFeed,
                oracleKey,
                strikePrice,
                [maturity, expiry],
                initialMint
            )
        );

        _activeMarkets.add(address(market));

        // The debt can't be incremented in the new market's constructor because until construction is complete,
        // the manager doesn't know its address in order to grant it permission.
        totalDeposited = totalDeposited.add(initialMint);
        sUSD.transferFrom(msg.sender, address(market), _transformCollateral(initialMint));

        (IPosition up, IPosition down) = market.getOptions();

        marketsStrikePrice[address(market)] = strikePrice;
        marketsPerOracleKey[oracleKey][_getDateFromTimestamp(maturity)].push(address(market));

        emit MarketCreated(
            address(market),
            msg.sender,
            oracleKey,
            strikePrice,
            maturity,
            expiry,
            address(up),
            address(down),
            false,
            address(0)
        );
        return market;
    }

    /// @notice transferSusdTo transfers sUSD from market to receiver
    /// @dev Only to be called by markets themselves
    /// @param sender address of sender
    /// @param receiver address of receiver
    /// @param amount amount to be transferred
    function transferSusdTo(
        address sender,
        address receiver,
        uint amount
    ) external override {
        //only to be called by markets themselves
        require(isKnownMarket(address(msg.sender)), "Market unknown.");
        bool success = sUSD.transferFrom(sender, receiver, amount);
        if (!success) {
            revert("TransferFrom function failed");
        }
    }

    /// @notice resolveMarket resolves an active market
    /// @param market address of the market
    function resolveMarket(address market) external override {
        require(_activeMarkets.contains(market), "Not an active market");
        PositionalMarket(market).resolve();
        _activeMarkets.remove(market);
        _maturedMarkets.add(market);
    }

    /// @notice expireMarkets removes expired markets from matured markets
    /// @param markets array of market addresses
    function expireMarkets(address[] calldata markets) external override notPaused onlyOwner {
        for (uint i = 0; i < markets.length; i++) {
            address market = markets[i];

            require(isKnownMarket(address(market)), "Market unknown.");

            // The market itself handles decrementing the total deposits.
            PositionalMarket(market).expire(payable(msg.sender));

            // Note that we required that the market is known, which guarantees
            // its index is defined and that the list of markets is not empty.
            _maturedMarkets.remove(market);

            emit MarketExpired(market);
        }
    }

    /// @notice transformCollateral transforms collateral
    /// @param value value to be transformed
    /// @return uint
    function transformCollateral(uint value) external view override returns (uint) {
        return _transformCollateral(value);
    }

    /// @notice reverseTransformCollateral reverse collateral if needed
    /// @param value value to be reversed
    /// @return uint
    function reverseTransformCollateral(uint value) external view override returns (uint) {
        if (needsTransformingCollateral) {
            return value * 1e12;
        } else {
            return value;
        }
    }

    /// @notice canCreateMarket checks if market can be created
    /// @param oracleKey market oracle key
    /// @param maturity market maturity timestamp
    /// @param strikePrice market strike price
    /// @return bool
    function canCreateMarket(
        bytes32 oracleKey,
        uint maturity,
        uint strikePrice
    ) public view returns (bool, string memory) {
        if (!marketCreationEnabled) {
            return (false, "Market creation is disabled");
        }

        if (!_isValidKey(oracleKey)) {
            return (false, "Invalid key");
        }

        if (maturity > block.timestamp + durations.maxTimeToMaturity) {
            return (false, "Maturity too far in the future");
        }

        if (block.timestamp >= maturity) {
            return (false, "Maturity too far in the future");
        }

        if (!_checkMarkets(oracleKey, strikePrice, maturity)) {
            return (false, "A market already exists within that timeframe and price buffer");
        }

        return (true, "");
    }

    /// @notice enableWhitelistedAddresses enables option that only whitelisted addresses
    /// can create markets
    function enableWhitelistedAddresses() external onlyOwner {
        onlyWhitelistedAddressesCanCreateMarkets = true;
    }

    /// @notice disableWhitelistedAddresses disables option that only whitelisted addresses
    /// can create markets
    function disableWhitelistedAddresses() external onlyOwner {
        onlyWhitelistedAddressesCanCreateMarkets = false;
    }

    /// @notice addWhitelistedAddress adds given address to whitelisted addresses list
    /// @param _address address to be added to the list
    function addWhitelistedAddress(address _address) external onlyOwner {
        whitelistedAddresses[_address] = true;
    }

    /// @notice removeWhitelistedAddress removes given address from whitelisted addresses list
    /// @param _address address to be removed from the list
    function removeWhitelistedAddress(address _address) external onlyOwner {
        delete whitelistedAddresses[_address];
    }

    /// @notice setWhitelistedAddresses enables whitelist addresses option and creates list
    /// @param _whitelistedAddresses array of whitelisted addresses
    function setWhitelistedAddresses(address[] calldata _whitelistedAddresses) external onlyOwner {
        require(_whitelistedAddresses.length > 0, "Whitelisted addresses cannot be empty");
        onlyWhitelistedAddressesCanCreateMarkets = true;
        for (uint256 index = 0; index < _whitelistedAddresses.length; index++) {
            whitelistedAddresses[_whitelistedAddresses[index]] = true;
        }
    }

    /// @notice setPositionalMarketFactory sets PositionalMarketFactory address
    /// @param _positionalMarketFactory address of PositionalMarketFactory
    function setPositionalMarketFactory(address _positionalMarketFactory) external onlyOwner {
        positionalMarketFactory = _positionalMarketFactory;
        emit SetPositionalMarketFactory(_positionalMarketFactory);
    }

    /// @notice setNeedsTransformingCollateral sets needsTransformingCollateral value
    /// @param _needsTransformingCollateral boolen value to be set
    function setNeedsTransformingCollateral(bool _needsTransformingCollateral) external onlyOwner {
        needsTransformingCollateral = _needsTransformingCollateral;
    }

    /// @notice setExpiryDuration sets expiryDuration value
    /// @param _expiryDuration value in seconds needed for market expiry check
    function setExpiryDuration(uint _expiryDuration) public onlyOwner {
        durations.expiryDuration = _expiryDuration;
        emit ExpiryDurationUpdated(_expiryDuration);
    }

    /// @notice setMaxTimeToMaturity sets maxTimeToMaturity value
    /// @param _maxTimeToMaturity value in seconds for market max time to maturity check
    function setMaxTimeToMaturity(uint _maxTimeToMaturity) public onlyOwner {
        durations.maxTimeToMaturity = _maxTimeToMaturity;
        emit MaxTimeToMaturityUpdated(_maxTimeToMaturity);
    }

    /// @notice setPriceFeed sets address of PriceFeed contract
    /// @param _address PriceFeed address
    function setPriceFeed(address _address) external onlyOwner {
        priceFeed = IPriceFeed(_address);
        emit SetPriceFeed(_address);
    }

    /// @notice setOnlyAMMMintingAndBurning whether minting and burning is only allowed for AMM
    /// @param _onlyAMMMintingAndBurning the value
    function setOnlyAMMMintingAndBurning(bool _onlyAMMMintingAndBurning) external onlyOwner {
        onlyAMMMintingAndBurning = _onlyAMMMintingAndBurning;
        emit SetOnlyAMMMintingAndBurning(_onlyAMMMintingAndBurning);
    }

    /// @notice setsUSD sets address of sUSD contract
    /// @param _address sUSD address
    function setsUSD(address _address) external onlyOwner {
        sUSD = IERC20(_address);
        emit SetsUSD(_address);
    }

    /// @notice setPriceBuffer sets priceBuffer value
    /// @param _priceBuffer value in percents needed for market creaton check
    function setPriceBuffer(uint _priceBuffer) external onlyOwner {
        priceBuffer = _priceBuffer;
        emit PriceBufferChanged(_priceBuffer);
    }

    /// @notice setTimeframeBuffer sets timeframeBuffer value
    /// @param _timeframeBuffer value in days needed for market creaton check
    function setTimeframeBuffer(uint _timeframeBuffer) external onlyOwner {
        timeframeBuffer = _timeframeBuffer;
        emit TimeframeBufferChanged(_timeframeBuffer);
    }

    /// @notice setMarketCreationEnabled sets marketCreationEnabled value
    /// @param enabled boolean value to enable/disable market creation
    function setMarketCreationEnabled(bool enabled) external onlyOwner {
        if (enabled != marketCreationEnabled) {
            marketCreationEnabled = enabled;
            emit MarketCreationEnabledUpdated(enabled);
        }
    }

    /// @notice _isValidKey checks if oracle key is supported by PriceFeed contract
    /// @param oracleKey oracle key
    /// @return bool
    function _isValidKey(bytes32 oracleKey) internal view returns (bool) {
        // If it has a rate, then it's possibly a valid key
        if (priceFeed.rateForCurrency(oracleKey) != 0) {
            return true;
        }

        return false;
    }

    /// @notice _checkStrikePrice checks if markets strike prices are between given price values
    /// @param markets list of markets to be checked
    /// @param strikePrice market strike price
    /// @param oracleKey market oracle key
    /// @return bool - true if there are no markets between given price values, otherwise false
    function _checkStrikePrice(
        address[] memory markets,
        uint strikePrice,
        bytes32 oracleKey
    ) internal view returns (bool) {
        uint buffer = (priceBuffer * _getImpliedVolatility(oracleKey)) / 1e18;
        for (uint i = 0; i < markets.length; i++) {
            uint upperPriceLimit = marketsStrikePrice[markets[i]] + (marketsStrikePrice[markets[i]] * buffer) / 1e20;
            uint lowerPriceLimit = marketsStrikePrice[markets[i]] - (marketsStrikePrice[markets[i]] * buffer) / 1e20;
            if (strikePrice <= upperPriceLimit && strikePrice >= lowerPriceLimit) {
                return false;
            }
        }
        return true;
    }

    /// @notice _checkMarkets checks if there exists similar market with same oracleKey
    /// @dev price limits are calculated from given strike price using priceBuffer percentage and
    /// we're checking lists of markets using timeframeBuffer
    /// @param oracleKey oracle key of the market to be created
    /// @param strikePrice strike price
    /// @param maturity market date maturity
    /// @return bool
    function _checkMarkets(
        bytes32 oracleKey,
        uint strikePrice,
        uint maturity
    ) internal view returns (bool) {
        uint date = _getDateFromTimestamp(maturity);

        for (uint day = 1; day <= timeframeBuffer; day++) {
            uint upperDateLimit = DateTime.addDays(date, day);
            uint lowerDateLimit = DateTime.subDays(date, day);

            address[] memory marketsDateAfter = _getMarketsPerOracleKey(oracleKey, upperDateLimit);
            address[] memory marketsDateBefore = _getMarketsPerOracleKey(oracleKey, lowerDateLimit);

            if (
                !(_checkStrikePrice(marketsDateAfter, strikePrice, oracleKey) &&
                    _checkStrikePrice(marketsDateBefore, strikePrice, oracleKey))
            ) {
                return false;
            }
        }

        address[] memory marketsOnDate = _getMarketsPerOracleKey(oracleKey, date);

        return _checkStrikePrice(marketsOnDate, strikePrice, oracleKey);
    }

    /// @notice _getMarketsPerOracleKey returns list of markets with same oracle key and maturity date
    /// @param oracleKey oracle key
    /// @param date maturity date
    /// @return address[] list of markets
    function _getMarketsPerOracleKey(bytes32 oracleKey, uint date) internal view returns (address[] memory) {
        return marketsPerOracleKey[oracleKey][date];
    }

    /// @notice _getDateFromTimestamp calculates midnight timestamp
    /// @param timestamp timestamp to strip seconds, minutes and hours
    /// @return date midnigth timestamp
    function _getDateFromTimestamp(uint timestamp) internal pure returns (uint date) {
        uint second = DateTime.getSecond(timestamp);
        uint minute = DateTime.getMinute(timestamp);
        uint hour = DateTime.getHour(timestamp);

        date = DateTime.subHours(timestamp, hour);
        date = DateTime.subMinutes(date, minute);
        date = DateTime.subSeconds(date, second);
    }

    /// @notice _getImpliedVolatility gets implied volatility per asset from ThalesAMM contract
    /// @param oracleKey asset to fetch value for
    /// @return impliedVolatility
    function _getImpliedVolatility(bytes32 oracleKey) internal view returns (uint impliedVolatility) {
        address thalesAMM = PositionalMarketFactory(positionalMarketFactory).thalesAMM();
        impliedVolatility = IThalesAMM(thalesAMM).impliedVolatilityPerAsset(oracleKey);
    }

    /// @notice get the thales amm address from the factory
    /// @return thales amm address
    function getThalesAMM() external view override returns (address) {
        return PositionalMarketFactory(positionalMarketFactory).thalesAMM();
    }

    /// @notice _transformCollateral transforms collateral if needed
    /// @param value value to be transformed
    /// @return uint
    function _transformCollateral(uint value) internal view returns (uint) {
        if (needsTransformingCollateral) {
            return value / 1e12;
        } else {
            return value;
        }
    }

    modifier onlyActiveMarkets() {
        require(_activeMarkets.contains(msg.sender), "Permitted only for active markets.");
        _;
    }

    modifier onlyKnownMarkets() {
        require(isKnownMarket(msg.sender), "Permitted only for known markets.");
        _;
    }

    event MarketCreated(
        address market,
        address indexed creator,
        bytes32 indexed oracleKey,
        uint strikePrice,
        uint maturityDate,
        uint expiryDate,
        address up,
        address down,
        bool customMarket,
        address customOracle
    );
    event MarketExpired(address market);
    event MarketsMigrated(PositionalMarketManager receivingManager, PositionalMarket[] markets);
    event MarketsReceived(PositionalMarketManager migratingManager, PositionalMarket[] markets);
    event MarketCreationEnabledUpdated(bool enabled);
    event ExpiryDurationUpdated(uint duration);
    event MaxTimeToMaturityUpdated(uint duration);
    event SetPositionalMarketFactory(address _positionalMarketFactory);
    event SetZeroExAddress(address _zeroExAddress);
    event SetPriceFeed(address _address);
    event SetsUSD(address _address);
    event SetMigratingManager(address manager);
    event PriceBufferChanged(uint priceBuffer);
    event TimeframeBufferChanged(uint timeframeBuffer);
    event SetOnlyAMMMintingAndBurning(bool _SetOnlyAMMMintingAndBurning);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-4.4.1/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-4.4.1/token/ERC20/utils/SafeERC20.sol";

// Internal references
import "./RangedPosition.sol";
import "./RangedMarketsAMM.sol";
import "../interfaces/IPositionalMarket.sol";
import "../interfaces/IPositionalMarketManager.sol";

contract RangedMarket {
    using SafeERC20 for IERC20;

    enum Position {In, Out}

    IPositionalMarket public leftMarket;
    IPositionalMarket public rightMarket;

    struct Positions {
        RangedPosition inp;
        RangedPosition outp;
    }

    Positions public positions;

    RangedMarketsAMM public rangedMarketsAMM;

    bool public resolved = false;

    uint finalPrice;

    /* ========== CONSTRUCTOR ========== */

    bool public initialized = false;

    function initialize(
        address _leftMarket,
        address _rightMarket,
        address _in,
        address _out,
        address _rangedMarketsAMM
    ) external {
        require(!initialized, "Ranged Market already initialized");
        initialized = true;
        leftMarket = IPositionalMarket(_leftMarket);
        rightMarket = IPositionalMarket(_rightMarket);
        positions.inp = RangedPosition(_in);
        positions.outp = RangedPosition(_out);
        rangedMarketsAMM = RangedMarketsAMM(_rangedMarketsAMM);
    }

    function mint(
        uint value,
        Position _position,
        address minter
    ) external onlyAMM {
        if (value == 0) {
            return;
        }
        _mint(minter, value, _position);
    }

    function _mint(
        address minter,
        uint amount,
        Position _position
    ) internal {
        if (_position == Position.In) {
            positions.inp.mint(minter, amount);
        } else {
            positions.outp.mint(minter, amount);
        }
        emit Mint(minter, amount, _position);
    }

    function burnIn(uint value, address claimant) external onlyAMM {
        if (value == 0) {
            return;
        }
        (IPosition up, ) = IPositionalMarket(leftMarket).getOptions();
        IERC20(address(up)).safeTransfer(msg.sender, value / 2);

        (, IPosition down1) = IPositionalMarket(rightMarket).getOptions();
        IERC20(address(down1)).safeTransfer(msg.sender, value / 2);

        positions.inp.burn(claimant, value);
        emit Burn(claimant, value, Position.In);
    }

    function burnOut(uint value, address claimant) external onlyAMM {
        if (value == 0) {
            return;
        }
        (, IPosition down) = IPositionalMarket(leftMarket).getOptions();
        IERC20(address(down)).safeTransfer(msg.sender, value);

        (IPosition up1, ) = IPositionalMarket(rightMarket).getOptions();
        IERC20(address(up1)).safeTransfer(msg.sender, value);

        positions.outp.burn(claimant, value);

        emit Burn(claimant, value, Position.Out);
    }

    function canExercisePositions() external view returns (bool) {
        if (!leftMarket.resolved() && !leftMarket.canResolve()) {
            return false;
        }
        if (!rightMarket.resolved() && !rightMarket.canResolve()) {
            return false;
        }

        uint inBalance = positions.inp.balanceOf(msg.sender);
        uint outBalance = positions.outp.balanceOf(msg.sender);

        if (inBalance == 0 && outBalance == 0) {
            return false;
        }

        return true;
    }

    function exercisePositions() external {
        if (leftMarket.canResolve()) {
            IPositionalMarketManager(rangedMarketsAMM.thalesAmm().manager()).resolveMarket(address(leftMarket));
        }
        if (rightMarket.canResolve()) {
            IPositionalMarketManager(rangedMarketsAMM.thalesAmm().manager()).resolveMarket(address(rightMarket));
        }
        require(leftMarket.resolved() && rightMarket.resolved(), "Left or Right market not resolved yet!");

        uint inBalance = positions.inp.balanceOf(msg.sender);
        uint outBalance = positions.outp.balanceOf(msg.sender);

        require(inBalance != 0 || outBalance != 0, "Nothing to exercise");

        if (!resolved) {
            resolveMarket();
        }

        // Each option only needs to be exercised if the account holds any of it.
        if (inBalance != 0) {
            positions.inp.burn(msg.sender, inBalance);
        }
        if (outBalance != 0) {
            positions.outp.burn(msg.sender, outBalance);
        }

        Position curResult = Position.Out;
        if ((leftMarket.result() == IPositionalMarket.Side.Up) && (rightMarket.result() == IPositionalMarket.Side.Down)) {
            curResult = Position.In;
        }

        // Only pay out the side that won.
        uint payout = (curResult == Position.In) ? inBalance : outBalance;
        if (payout != 0) {
            rangedMarketsAMM.transferSusdTo(
                msg.sender,
                IPositionalMarketManager(rangedMarketsAMM.thalesAmm().manager()).transformCollateral(payout)
            );
        }
        emit Exercised(msg.sender, payout, curResult);
    }

    function canResolve() external view returns (bool) {
        // The markets must be resolved
        if (!leftMarket.resolved() && !leftMarket.canResolve()) {
            return false;
        }
        if (!rightMarket.resolved() && !rightMarket.canResolve()) {
            return false;
        }

        return !resolved;
    }

    function resolveMarket() public {
        // The markets must be resolved
        if (leftMarket.canResolve()) {
            IPositionalMarketManager(rangedMarketsAMM.thalesAmm().manager()).resolveMarket(address(leftMarket));
        }
        if (rightMarket.canResolve()) {
            IPositionalMarketManager(rangedMarketsAMM.thalesAmm().manager()).resolveMarket(address(rightMarket));
        }
        require(leftMarket.resolved() && rightMarket.resolved(), "Left or Right market not resolved yet!");
        require(!resolved, "Already resolved!");

        if (positions.inp.totalSupply() > 0 || positions.outp.totalSupply() > 0) {
            leftMarket.exerciseOptions();
            rightMarket.exerciseOptions();
        }
        resolved = true;

        if (rangedMarketsAMM.sUSD().balanceOf(address(this)) > 0) {
            rangedMarketsAMM.sUSD().transfer(address(rangedMarketsAMM), rangedMarketsAMM.sUSD().balanceOf(address(this)));
        }

        (, , uint _finalPrice) = leftMarket.getOracleDetails();
        finalPrice = _finalPrice;
        emit Resolved(result(), finalPrice);
    }

    function result() public view returns (Position resultToReturn) {
        resultToReturn = Position.Out;
        if ((leftMarket.result() == IPositionalMarket.Side.Up) && (rightMarket.result() == IPositionalMarket.Side.Down)) {
            resultToReturn = Position.In;
        }
    }

    function withdrawCollateral(address recipient) external onlyAMM {
        rangedMarketsAMM.sUSD().transfer(recipient, rangedMarketsAMM.sUSD().balanceOf(address(this)));
    }

    modifier onlyAMM {
        require(msg.sender == address(rangedMarketsAMM), "only the AMM may perform these methods");
        _;
    }

    event Mint(address minter, uint amount, Position _position);
    event Burn(address burner, uint amount, Position _position);
    event Exercised(address exerciser, uint amount, Position _position);
    event Resolved(Position winningPosition, uint finalPrice);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// external
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-4.4.1/proxy/Clones.sol";

// interfaces
import "../interfaces/IPriceFeed.sol";
import "../interfaces/IThalesAMM.sol";

// internal
import "../utils/proxy/solidity-0.8.0/ProxyReentrancyGuard.sol";
import "../utils/proxy/solidity-0.8.0/ProxyOwned.sol";
import "../utils/proxy/solidity-0.8.0/ProxyPausable.sol";
import "../utils/libraries/AddressSetLib.sol";

import "./RangedPosition.sol";
import "./RangedPosition.sol";
import "./RangedMarket.sol";
import "../interfaces/IPositionalMarket.sol";
import "../interfaces/IStakingThales.sol";
import "../interfaces/IReferrals.sol";
import "../interfaces/ICurveSUSD.sol";

contract RangedMarketsAMM is Initializable, ProxyOwned, ProxyPausable, ProxyReentrancyGuard {
    using AddressSetLib for AddressSetLib.AddressSet;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    uint private constant ONE = 1e18;
    uint private constant ONE_PERCENT = 1e16;

    IThalesAMM public thalesAmm;

    uint public rangedAmmFee;

    mapping(address => mapping(address => address)) public createdRangedMarkets;
    AddressSetLib.AddressSet internal _knownMarkets;

    address public rangedMarketMastercopy;
    address public rangedPositionMastercopy;

    IERC20Upgradeable public sUSD;

    mapping(address => uint) public spentOnMarket;

    // IMPORTANT: AMM risks only half or the payout effectively, but it risks the whole amount on price movements
    uint public capPerMarket;

    uint public minSupportedPrice;
    uint public maxSupportedPrice;

    address public safeBox;
    uint public safeBoxImpact;

    uint public minimalDifBetweenStrikes;

    IStakingThales public stakingThales;

    uint public maximalDifBetweenStrikes;

    address public referrals;
    uint public referrerFee;

    ICurveSUSD public curveSUSD;

    address public usdc;
    address public usdt;
    address public dai;

    bool public curveOnrampEnabled;
    uint public maxAllowedPegSlippagePercentage;

    function initialize(
        address _owner,
        IThalesAMM _thalesAmm,
        uint _rangedAmmFee,
        uint _capPerMarket,
        IERC20Upgradeable _sUSD,
        address _safeBox,
        uint _safeBoxImpact
    ) public initializer {
        setOwner(_owner);
        initNonReentrant();
        thalesAmm = _thalesAmm;
        capPerMarket = _capPerMarket;
        rangedAmmFee = _rangedAmmFee;
        sUSD = _sUSD;
        safeBox = _safeBox;
        safeBoxImpact = _safeBoxImpact;

        sUSD.approve(address(thalesAmm), type(uint256).max);
    }

    function createRangedMarket(address leftMarket, address rightMarket) external nonReentrant notPaused {
        require(canCreateRangedMarket(leftMarket, rightMarket), "Can't create such a ranged market!");

        RangedMarket rm = RangedMarket(Clones.clone(rangedMarketMastercopy));
        createdRangedMarkets[leftMarket][rightMarket] = address(rm);

        RangedPosition inp = RangedPosition(Clones.clone(rangedPositionMastercopy));
        inp.initialize(address(rm), "Position IN", "IN", address(this));

        RangedPosition outp = RangedPosition(Clones.clone(rangedPositionMastercopy));
        outp.initialize(address(rm), "Position OUT", "OUT", address(this));

        rm.initialize(leftMarket, rightMarket, address(inp), address(outp), address(this));

        _knownMarkets.add(address(rm));

        emit RangedMarketCreated(address(rm), leftMarket, rightMarket);
    }

    function canCreateRangedMarket(address leftMarket, address rightMarket) public view returns (bool) {
        if (!thalesAmm.isMarketInAMMTrading(leftMarket) || !thalesAmm.isMarketInAMMTrading(rightMarket)) {
            return false;
        }
        (uint maturityLeft, ) = IPositionalMarket(leftMarket).times();
        (uint maturityRight, ) = IPositionalMarket(rightMarket).times();
        if (maturityLeft != maturityRight) {
            return false;
        }

        (bytes32 leftkey, uint leftstrikePrice, ) = IPositionalMarket(leftMarket).getOracleDetails();
        (bytes32 rightkey, uint rightstrikePrice, ) = IPositionalMarket(rightMarket).getOracleDetails();
        if (leftkey != rightkey) {
            return false;
        }
        if (leftstrikePrice >= rightstrikePrice) {
            return false;
        }

        if (!(((ONE + minimalDifBetweenStrikes * ONE_PERCENT) * leftstrikePrice) / ONE < rightstrikePrice)) {
            return false;
        }

        if (!(((ONE + maximalDifBetweenStrikes * ONE_PERCENT) * leftstrikePrice) / ONE > rightstrikePrice)) {
            return false;
        }

        return createdRangedMarkets[leftMarket][rightMarket] == address(0);
    }

    function availableToBuyFromAMM(RangedMarket rangedMarket, RangedMarket.Position position)
        public
        view
        knownRangedMarket(address(rangedMarket))
        returns (uint)
    {
        uint availableLeft = thalesAmm.availableToBuyFromAMM(
            address(rangedMarket.leftMarket()),
            position == RangedMarket.Position.Out ? IThalesAMM.Position.Down : IThalesAMM.Position.Up
        );
        uint availableRight = thalesAmm.availableToBuyFromAMM(
            address(rangedMarket.rightMarket()),
            position == RangedMarket.Position.Out ? IThalesAMM.Position.Up : IThalesAMM.Position.Down
        );
        return availableLeft < availableRight ? availableLeft : availableRight;
    }

    function buyFromAmmQuote(
        RangedMarket rangedMarket,
        RangedMarket.Position position,
        uint amount
    ) public view knownRangedMarket(address(rangedMarket)) returns (uint sUSDPaid) {
        (sUSDPaid, , ) = buyFromAmmQuoteDetailed(rangedMarket, position, amount);
        uint basePrice = _transformCollateral((sUSDPaid * ONE) / amount, true);
        if (basePrice < minSupportedPrice || basePrice >= ONE) {
            sUSDPaid = 0;
        }
    }

    function buyFromAmmQuoteDetailed(
        RangedMarket rangedMarket,
        RangedMarket.Position position,
        uint amount
    )
        public
        view
        knownRangedMarket(address(rangedMarket))
        returns (
            uint quoteWithFees,
            uint leftQuote,
            uint rightQuote
        )
    {
        amount = position == RangedMarket.Position.Out ? amount : amount / 2;
        leftQuote = thalesAmm.buyFromAmmQuote(
            address(rangedMarket.leftMarket()),
            position == RangedMarket.Position.Out ? IThalesAMM.Position.Down : IThalesAMM.Position.Up,
            amount
        );
        rightQuote = thalesAmm.buyFromAmmQuote(
            address(rangedMarket.rightMarket()),
            position == RangedMarket.Position.Out ? IThalesAMM.Position.Up : IThalesAMM.Position.Down,
            amount
        );
        quoteWithFees = _buyFromAmmQuoteWithLeftAndRightQuote(position, amount, leftQuote, rightQuote);
    }

    function buyFromAmmQuoteWithDifferentCollateral(
        RangedMarket rangedMarket,
        RangedMarket.Position position,
        uint amount,
        address collateral
    ) public view returns (uint collateralQuote, uint sUSDToPay) {
        int128 curveIndex = _mapCollateralToCurveIndex(collateral);
        if (curveIndex > 0 && curveOnrampEnabled) {
            sUSDToPay = buyFromAmmQuote(rangedMarket, position, amount);
            //cant get a quote on how much collateral is needed from curve for sUSD,
            //so rather get how much of collateral you get for the sUSD quote and add 0.2% to that
            collateralQuote = (curveSUSD.get_dy_underlying(0, curveIndex, sUSDToPay) * (ONE + (ONE_PERCENT / 5))) / ONE;
        }
    }

    function buyFromAMMWithReferrer(
        RangedMarket rangedMarket,
        RangedMarket.Position position,
        uint amount,
        uint expectedPayout,
        uint additionalSlippage,
        address referrer
    ) public knownRangedMarket(address(rangedMarket)) nonReentrant notPaused {
        if (referrer != address(0)) {
            IReferrals(referrals).setReferrer(referrer, msg.sender);
        }
        _buyFromAMM(rangedMarket, position, amount, expectedPayout, additionalSlippage, true);
    }

    function buyFromAMMWithDifferentCollateralAndReferrer(
        RangedMarket rangedMarket,
        RangedMarket.Position position,
        uint amount,
        uint expectedPayout,
        uint additionalSlippage,
        address collateral,
        address _referrer
    ) public nonReentrant notPaused {
        if (_referrer != address(0)) {
            IReferrals(referrals).setReferrer(_referrer, msg.sender);
        }

        int128 curveIndex = _mapCollateralToCurveIndex(collateral);
        require(curveIndex > 0 && curveOnrampEnabled, "unsupported collateral");

        (uint collateralQuote, uint susdQuote) = buyFromAmmQuoteWithDifferentCollateral(
            rangedMarket,
            position,
            amount,
            collateral
        );

        uint transformedCollateralForPegCheck = collateral == usdc || collateral == usdt
            ? collateralQuote * 1e12
            : collateralQuote;
        require(
            maxAllowedPegSlippagePercentage > 0 &&
                transformedCollateralForPegCheck >= (susdQuote * (ONE - maxAllowedPegSlippagePercentage)) / ONE,
            "Amount below max allowed peg slippage"
        );

        require((collateralQuote * ONE) / expectedPayout <= (ONE + additionalSlippage), "Slippage too high");

        IERC20Upgradeable collateralToken = IERC20Upgradeable(collateral);
        collateralToken.safeTransferFrom(msg.sender, address(this), collateralQuote);
        curveSUSD.exchange_underlying(curveIndex, 0, collateralQuote, susdQuote);

        _buyFromAMM(rangedMarket, position, amount, susdQuote, additionalSlippage, false);
    }

    function buyFromAMM(
        RangedMarket rangedMarket,
        RangedMarket.Position position,
        uint amount,
        uint expectedPayout,
        uint additionalSlippage
    ) public knownRangedMarket(address(rangedMarket)) nonReentrant notPaused {
        _buyFromAMM(rangedMarket, position, amount, expectedPayout, additionalSlippage, true);
    }

    function _buyFromAmmQuoteWithLeftAndRightQuote(
        RangedMarket.Position position,
        uint amount,
        uint leftQuote,
        uint rightQuote
    ) internal view returns (uint quoteWithFees) {
        if (leftQuote > 0 && rightQuote > 0) {
            uint summedQuotes = leftQuote + rightQuote;
            if (position == RangedMarket.Position.Out) {
                quoteWithFees = (summedQuotes * (rangedAmmFee + ONE)) / ONE;
            } else {
                if (
                    summedQuotes >
                    ((_transformCollateral(amount, false) - leftQuote) + (_transformCollateral(amount, false) - rightQuote))
                ) {
                    uint quoteWithoutFees = summedQuotes -
                        (_transformCollateral(amount, false) - leftQuote) -
                        (_transformCollateral(amount, false) - rightQuote);
                    quoteWithFees = (quoteWithoutFees * (rangedAmmFee + safeBoxImpact + ONE)) / ONE;
                }
            }
        }
    }

    function _buyFromAMM(
        RangedMarket rangedMarket,
        RangedMarket.Position position,
        uint amount,
        uint expectedPayout,
        uint additionalSlippage,
        bool sendSUSD
    ) internal {
        require(availableToBuyFromAMM(rangedMarket, position) >= amount, "Insufficient liquidity");

        uint sUSDPaid;
        address target;
        (RangedPosition inp, RangedPosition outp) = rangedMarket.positions();

        if (position == RangedMarket.Position.Out) {
            target = address(outp);
            sUSDPaid = _buyOUT(rangedMarket, amount);
        } else {
            target = address(inp);
            sUSDPaid = _buyIN(rangedMarket, amount);
            _handleSafeBoxFeeOnBuy(address(rangedMarket), amount, sUSDPaid);
        }

        uint basePrice = _transformCollateral((sUSDPaid * ONE) / amount, true);
        require(basePrice > minSupportedPrice && basePrice < ONE, "Invalid price");
        require(sUSDPaid > 0 && ((sUSDPaid * ONE) / expectedPayout <= (ONE + additionalSlippage)), "Slippage too high");

        if (sendSUSD) {
            sUSD.safeTransferFrom(msg.sender, address(this), sUSDPaid);
        }

        rangedMarket.mint(amount, position, msg.sender);

        _handleReferrer(msg.sender, sUSDPaid);

        if (address(stakingThales) != address(0)) {
            stakingThales.updateVolume(msg.sender, sUSDPaid);
        }

        emit BoughtFromAmm(msg.sender, address(rangedMarket), position, amount, sUSDPaid, address(sUSD), target);

        (bytes32 leftkey, uint leftstrikePrice, ) = IPositionalMarket(rangedMarket.leftMarket()).getOracleDetails();
        (, uint rightstrikePrice, ) = IPositionalMarket(rangedMarket.rightMarket()).getOracleDetails();
        uint currentAssetPrice = thalesAmm.priceFeed().rateForCurrency(leftkey);
        bool inTheMoney = position == RangedMarket.Position.In
            ? currentAssetPrice >= leftstrikePrice && currentAssetPrice < rightstrikePrice
            : currentAssetPrice < leftstrikePrice || currentAssetPrice >= rightstrikePrice;
        emit BoughtOptionType(msg.sender, sUSDPaid, inTheMoney);
    }

    function _buyOUT(RangedMarket rangedMarket, uint amount) internal returns (uint) {
        uint paidLeft = thalesAmm.buyFromAMM(
            address(rangedMarket.leftMarket()),
            IThalesAMM.Position.Down,
            amount,
            type(uint256).max,
            0
        );

        uint paidRight = thalesAmm.buyFromAMM(
            address(rangedMarket.rightMarket()),
            IThalesAMM.Position.Up,
            amount,
            type(uint256).max,
            0
        );
        (, IPosition down) = IPositionalMarket(rangedMarket.leftMarket()).getOptions();
        IERC20Upgradeable(address(down)).safeTransfer(address(rangedMarket), amount);

        (IPosition up1, ) = IPositionalMarket(rangedMarket.rightMarket()).getOptions();
        IERC20Upgradeable(address(up1)).safeTransfer(address(rangedMarket), amount);
        return _buyFromAmmQuoteWithLeftAndRightQuote(RangedMarket.Position.Out, amount, paidLeft, paidRight);
    }

    function _buyIN(RangedMarket rangedMarket, uint amount) internal returns (uint) {
        uint paidLeft = thalesAmm.buyFromAMM(
            address(rangedMarket.leftMarket()),
            IThalesAMM.Position.Up,
            amount / 2,
            type(uint256).max,
            0
        );

        uint paidRight = thalesAmm.buyFromAMM(
            address(rangedMarket.rightMarket()),
            IThalesAMM.Position.Down,
            amount / 2,
            type(uint256).max,
            0
        );
        (IPosition up, ) = IPositionalMarket(rangedMarket.leftMarket()).getOptions();
        IERC20Upgradeable(address(up)).safeTransfer(address(rangedMarket), amount / 2);

        (, IPosition down1) = IPositionalMarket(rangedMarket.rightMarket()).getOptions();
        IERC20Upgradeable(address(down1)).safeTransfer(address(rangedMarket), amount / 2);

        return _buyFromAmmQuoteWithLeftAndRightQuote(RangedMarket.Position.In, amount / 2, paidLeft, paidRight);
    }

    function availableToSellToAMM(RangedMarket rangedMarket, RangedMarket.Position position)
        public
        view
        knownRangedMarket(address(rangedMarket))
        returns (uint _available)
    {
        uint availableLeft = thalesAmm.availableToSellToAMM(
            address(rangedMarket.leftMarket()),
            position == RangedMarket.Position.Out ? IThalesAMM.Position.Down : IThalesAMM.Position.Up
        );
        uint availableRight = thalesAmm.availableToSellToAMM(
            address(rangedMarket.rightMarket()),
            position == RangedMarket.Position.Out ? IThalesAMM.Position.Up : IThalesAMM.Position.Down
        );

        _available = availableLeft < availableRight ? availableLeft : availableRight;
        if (position == RangedMarket.Position.In) {
            _available = _available * 2;
        }
    }

    function sellToAmmQuote(
        RangedMarket rangedMarket,
        RangedMarket.Position position,
        uint amount
    ) public view knownRangedMarket(address(rangedMarket)) returns (uint pricePaid) {
        (pricePaid, , ) = sellToAmmQuoteDetailed(rangedMarket, position, amount);
    }

    function sellToAmmQuoteDetailed(
        RangedMarket rangedMarket,
        RangedMarket.Position position,
        uint amount
    )
        public
        view
        knownRangedMarket(address(rangedMarket))
        returns (
            uint quoteWithFees,
            uint leftQuote,
            uint rightQuote
        )
    {
        amount = position == RangedMarket.Position.Out ? amount : amount / 2;
        leftQuote = thalesAmm.sellToAmmQuote(
            address(rangedMarket.leftMarket()),
            position == RangedMarket.Position.Out ? IThalesAMM.Position.Down : IThalesAMM.Position.Up,
            amount
        );
        rightQuote = thalesAmm.sellToAmmQuote(
            address(rangedMarket.rightMarket()),
            position == RangedMarket.Position.Out ? IThalesAMM.Position.Up : IThalesAMM.Position.Down,
            amount
        );
        quoteWithFees = _sellToAmmQuoteDetailedWithLeftAndRightQuotes(position, amount, leftQuote, rightQuote);
    }

    function sellToAMM(
        RangedMarket rangedMarket,
        RangedMarket.Position position,
        uint amount,
        uint expectedPayout,
        uint additionalSlippage
    ) public knownRangedMarket(address(rangedMarket)) nonReentrant notPaused {
        uint pricePaid;

        _handleApprovals(rangedMarket);

        if (position == RangedMarket.Position.Out) {
            rangedMarket.burnOut(amount, msg.sender);
        } else {
            rangedMarket.burnIn(amount, msg.sender);
        }

        pricePaid = _handleSellToAmm(rangedMarket, position, amount);
        require(pricePaid > 0 && (expectedPayout * ONE) / pricePaid <= (ONE + additionalSlippage), "Slippage too high");

        if (position == RangedMarket.Position.In) {
            _handleSafeBoxFeeOnSell(amount, rangedMarket, pricePaid);
        }

        sUSD.safeTransfer(msg.sender, pricePaid);

        _handleReferrer(msg.sender, pricePaid);

        if (address(stakingThales) != address(0)) {
            stakingThales.updateVolume(msg.sender, pricePaid);
        }

        (RangedPosition inp, RangedPosition outp) = rangedMarket.positions();
        address target = position == RangedMarket.Position.Out ? address(outp) : address(inp);
        emit SoldToAMM(msg.sender, address(rangedMarket), position, amount, pricePaid, address(sUSD), target);
    }

    function _sellToAmmQuoteDetailedWithLeftAndRightQuotes(
        RangedMarket.Position position,
        uint amount,
        uint leftQuote,
        uint rightQuote
    ) internal view returns (uint quoteWithFees) {
        if (leftQuote > 0 && rightQuote > 0) {
            uint summedQuotes = leftQuote + rightQuote;
            if (position == RangedMarket.Position.Out) {
                quoteWithFees = (summedQuotes * (ONE - rangedAmmFee)) / ONE;
            } else {
                uint amountTransformed = _transformCollateral(amount, false);
                if (
                    amountTransformed > leftQuote &&
                    amountTransformed > rightQuote &&
                    summedQuotes > ((amountTransformed - leftQuote) + (amountTransformed - rightQuote))
                ) {
                    uint quoteWithoutFees = summedQuotes -
                        ((amountTransformed - leftQuote) + (amountTransformed - rightQuote));
                    quoteWithFees = (quoteWithoutFees * (ONE - rangedAmmFee - safeBoxImpact)) / ONE;
                }
            }
        }
    }

    function _handleSellToAmm(
        RangedMarket rangedMarket,
        RangedMarket.Position position,
        uint amount
    ) internal returns (uint) {
        uint baseAMMAmount = position == RangedMarket.Position.Out ? amount : amount / 2;
        uint sellLeft = thalesAmm.sellToAMM(
            address(rangedMarket.leftMarket()),
            position == RangedMarket.Position.Out ? IThalesAMM.Position.Down : IThalesAMM.Position.Up,
            baseAMMAmount,
            0,
            0
        );

        uint sellRight = thalesAmm.sellToAMM(
            address(rangedMarket.rightMarket()),
            position == RangedMarket.Position.Out ? IThalesAMM.Position.Up : IThalesAMM.Position.Down,
            baseAMMAmount,
            0,
            0
        );

        return _sellToAmmQuoteDetailedWithLeftAndRightQuotes(position, baseAMMAmount, sellLeft, sellRight);
    }

    function _handleApprovals(RangedMarket rangedMarket) internal {
        (IPosition up, IPosition down) = IPositionalMarket(rangedMarket.leftMarket()).getOptions();
        (IPosition up1, IPosition down1) = IPositionalMarket(rangedMarket.rightMarket()).getOptions();
        IERC20Upgradeable(address(up)).approve(address(thalesAmm), type(uint256).max);
        IERC20Upgradeable(address(down)).approve(address(thalesAmm), type(uint256).max);
        IERC20Upgradeable(address(up1)).approve(address(thalesAmm), type(uint256).max);
        IERC20Upgradeable(address(down1)).approve(address(thalesAmm), type(uint256).max);
    }

    function _handleReferrer(address buyer, uint sUSDPaid) internal {
        if (referrerFee > 0 && referrals != address(0)) {
            address referrer = IReferrals(referrals).referrals(buyer);
            if (referrer != address(0)) {
                uint referrerShare = (sUSDPaid * (ONE + referrerFee)) / ONE - sUSDPaid;
                sUSD.transfer(referrer, referrerShare);
                emit ReferrerPaid(referrer, buyer, referrerShare, sUSDPaid);
            }
        }
    }

    function _mapCollateralToCurveIndex(address collateral) internal view returns (int128) {
        if (collateral == dai) {
            return 1;
        }
        if (collateral == usdc) {
            return 2;
        }
        if (collateral == usdt) {
            return 3;
        }
        return 0;
    }

    function _handleSafeBoxFeeOnBuy(
        address rangedMarket,
        uint amount,
        uint sUSDPaid
    ) internal {
        uint safeBoxShare = 0;
        if (safeBoxImpact > 0) {
            safeBoxShare = sUSDPaid - ((sUSDPaid * ONE) / (ONE + safeBoxImpact));
            sUSD.transfer(safeBox, safeBoxShare);
        }
    }

    function _handleSafeBoxFeeOnSell(
        uint amount,
        RangedMarket rangedMarket,
        uint sUSDPaid
    ) internal {
        uint safeBoxShare = 0;

        if (safeBoxImpact > 0) {
            safeBoxShare = ((sUSDPaid * ONE) / (ONE - safeBoxImpact)) - sUSDPaid;
            sUSD.transfer(safeBox, safeBoxShare);
        }
    }

    function _transformCollateral(uint collateral, bool reverse) internal view returns (uint transformed) {
        transformed = reverse
            ? IPositionalMarketManager(thalesAmm.manager()).reverseTransformCollateral(collateral)
            : IPositionalMarketManager(thalesAmm.manager()).transformCollateral(collateral);
    }

    function transferSusdTo(address receiver, uint amount) external {
        require(_knownMarkets.contains(msg.sender), "Not a known ranged market");
        sUSD.safeTransfer(receiver, amount);
    }

    function retrieveSUSDAmount(address payable account, uint amount) external onlyOwner {
        sUSD.safeTransfer(account, amount);
    }

    function setRangedMarketMastercopies(address _rangedMarketMastercopy, address _rangedPositionMastercopy)
        external
        onlyOwner
    {
        rangedMarketMastercopy = _rangedMarketMastercopy;
        rangedPositionMastercopy = _rangedPositionMastercopy;
    }

    function setMinMaxSupportedPrice(
        uint _minSupportedPrice,
        uint _maxSupportedPrice,
        uint _minDiffBetweenStrikes,
        uint _maxDiffBetweenStrikes
    ) public onlyOwner {
        minSupportedPrice = _minSupportedPrice;
        maxSupportedPrice = _maxSupportedPrice;
        minimalDifBetweenStrikes = _minDiffBetweenStrikes;
        maximalDifBetweenStrikes = _maxDiffBetweenStrikes;
        emit SetMinMaxSupportedPrice(minSupportedPrice, maxSupportedPrice);
        emit SetMinimalMaximalDifBetweenStrikes(minimalDifBetweenStrikes, maximalDifBetweenStrikes);
    }

    function setSafeBoxData(address _safeBox, uint _safeBoxImpact) external onlyOwner {
        safeBoxImpact = _safeBoxImpact;
        safeBox = _safeBox;
        emit SafeBoxChanged(_safeBoxImpact, _safeBox);
    }

    function setCapPerMarketAndRangedAMMFee(uint _capPerMarket, uint _rangedAMMFee) external onlyOwner {
        capPerMarket = _capPerMarket;
        rangedAmmFee = _rangedAMMFee;
        emit SetCapPerMarketAndRangedFee(capPerMarket, rangedAmmFee);
    }

    function setThalesAMMStakingThalesAndReferrals(
        address _thalesAMM,
        IStakingThales _stakingThales,
        address _referrals,
        uint _referrerFee
    ) external onlyOwner {
        thalesAmm = IThalesAMM(_thalesAMM);
        sUSD.approve(address(thalesAmm), type(uint256).max);
        stakingThales = _stakingThales;
        referrals = _referrals;
        referrerFee = _referrerFee;
    }

    function setCurveSUSD(
        address _curveSUSD,
        address _dai,
        address _usdc,
        address _usdt,
        bool _curveOnrampEnabled,
        uint _maxAllowedPegSlippagePercentage
    ) external onlyOwner {
        curveSUSD = ICurveSUSD(_curveSUSD);
        dai = _dai;
        usdc = _usdc;
        usdt = _usdt;
        IERC20(dai).approve(_curveSUSD, type(uint256).max);
        IERC20(usdc).approve(_curveSUSD, type(uint256).max);
        IERC20(usdt).approve(_curveSUSD, type(uint256).max);
        // not needed unless selling into different collateral is enabled
        //sUSD.approve(_curveSUSD, type(uint256).max);
        curveOnrampEnabled = _curveOnrampEnabled;
        maxAllowedPegSlippagePercentage = _maxAllowedPegSlippagePercentage;
    }

    modifier knownRangedMarket(address market) {
        require(_knownMarkets.contains(market), "Not a known ranged market");
        _;
    }

    event SoldToAMM(
        address seller,
        address market,
        RangedMarket.Position position,
        uint amount,
        uint sUSDPaid,
        address susd,
        address asset
    );
    event BoughtFromAmm(
        address buyer,
        address market,
        RangedMarket.Position position,
        uint amount,
        uint sUSDPaid,
        address susd,
        address asset
    );
    event BoughtOptionType(address buyer, uint sUSDPaid, bool inTheMoney);

    event RangedMarketCreated(address market, address leftMarket, address rightMarket);
    event SafeBoxChanged(uint _safeBoxImpact, address _safeBox);
    event SetMinMaxSupportedPrice(uint minSupportedPrice, uint maxSupportedPrice);
    event SetMinimalMaximalDifBetweenStrikes(uint minSupportedPrice, uint maxSupportedPrice);
    event SetCapPerMarketAndRangedFee(uint capPerMarket, uint rangedAmmFee);
    event ReferrerPaid(address refferer, address trader, uint amount, uint volume);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16;

import "./IPriceFeed.sol";

interface IThalesAMM {
    enum Position {
        Up,
        Down
    }

    function manager() external view returns (address);

    function availableToBuyFromAMM(address market, Position position) external view returns (uint);

    function impliedVolatilityPerAsset(bytes32 oracleKey) external view returns (uint);

    function buyFromAmmQuote(
        address market,
        Position position,
        uint amount
    ) external view returns (uint);

    function buyFromAMM(
        address market,
        Position position,
        uint amount,
        uint expectedPayout,
        uint additionalSlippage
    ) external returns (uint);

    function availableToSellToAMM(address market, Position position) external view returns (uint);

    function sellToAmmQuote(
        address market,
        Position position,
        uint amount
    ) external view returns (uint);

    function sellToAMM(
        address market,
        Position position,
        uint amount,
        uint expectedPayout,
        uint additionalSlippage
    ) external returns (uint);

    function isMarketInAMMTrading(address market) external view returns (bool);

    function price(address market, Position position) external view returns (uint);

    function buyPriceImpact(
        address market,
        Position position,
        uint amount
    ) external view returns (int);

    function priceFeed() external view returns (IPriceFeed);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Clone of syntetix contract without constructor
contract ProxyOwned {
    address public owner;
    address public nominatedOwner;
    bool private _initialized;
    bool private _transferredAtInit;

    function setOwner(address _owner) public {
        require(_owner != address(0), "Owner address cannot be 0");
        require(!_initialized, "Already initialized, use nominateNewOwner");
        _initialized = true;
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    function nominateNewOwner(address _owner) external onlyOwner {
        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    function acceptOwnership() external {
        require(msg.sender == nominatedOwner, "You must be nominated before you can accept ownership");
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    function transferOwnershipAtInit(address proxyAddress) external onlyOwner {
        require(proxyAddress != address(0), "Invalid address");
        require(!_transferredAtInit, "Already transferred");
        owner = proxyAddress;
        _transferredAtInit = true;
        emit OwnerChanged(owner, proxyAddress);
    }

    modifier onlyOwner {
        _onlyOwner();
        _;
    }

    function _onlyOwner() private view {
        require(msg.sender == owner, "Only the contract owner may perform this action");
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Inheritance
import "./ProxyOwned.sol";

// Clone of syntetix contract without constructor

contract ProxyPausable is ProxyOwned {
    uint public lastPauseTime;
    bool public paused;

    

    /**
     * @notice Change the paused state of the contract
     * @dev Only the contract owner may call this.
     */
    function setPaused(bool _paused) external onlyOwner {
        // Ensure we're actually changing the state before we do anything
        if (_paused == paused) {
            return;
        }

        // Set our paused state.
        paused = _paused;

        // If applicable, set the last pause time.
        if (paused) {
            lastPauseTime = block.timestamp;
        }

        // Let everyone know that our pause state has changed.
        emit PauseChanged(paused);
    }

    event PauseChanged(bool isPaused);

    modifier notPaused {
        require(!paused, "This action cannot be performed while the contract is paused");
        _;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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

pragma solidity >=0.5.16;

import "./IPositionalMarket.sol";

interface IPosition {
    /* ========== VIEWS / VARIABLES ========== */

    function getBalanceOf(address account) external view returns (uint);

    function getTotalSupply() external view returns (uint);

    function exerciseWithAmount(address claimant, uint amount) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.16;

import "../interfaces/IPositionalMarketManager.sol";
import "../interfaces/IPosition.sol";
import "../interfaces/IPriceFeed.sol";

interface IPositionalMarket {
    /* ========== TYPES ========== */

    enum Phase {
        Trading,
        Maturity,
        Expiry
    }
    enum Side {
        Up,
        Down
    }

    /* ========== VIEWS / VARIABLES ========== */

    function getOptions() external view returns (IPosition up, IPosition down);

    function times() external view returns (uint maturity, uint destructino);

    function getOracleDetails()
        external
        view
        returns (
            bytes32 key,
            uint strikePrice,
            uint finalPrice
        );

    function fees() external view returns (uint poolFee, uint creatorFee);

    function deposited() external view returns (uint);

    function creator() external view returns (address);

    function resolved() external view returns (bool);

    function phase() external view returns (Phase);

    function oraclePrice() external view returns (uint);

    function oraclePriceAndTimestamp() external view returns (uint price, uint updatedAt);

    function canResolve() external view returns (bool);

    function result() external view returns (Side);

    function balancesOf(address account) external view returns (uint up, uint down);

    function totalSupplies() external view returns (uint up, uint down);

    function getMaximumBurnable(address account) external view returns (uint amount);

    /* ========== MUTATIVE FUNCTIONS ========== */

    function mint(uint value) external;

    function exerciseOptions() external returns (uint);

    function burnOptions(uint amount) external;

    function burnOptionsMaximum() external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.16;

import "../interfaces/IPositionalMarket.sol";

interface IPositionalMarketManager {
    /* ========== VIEWS / VARIABLES ========== */

    function durations() external view returns (uint expiryDuration, uint maxTimeToMaturity);

    function capitalRequirement() external view returns (uint);

    function marketCreationEnabled() external view returns (bool);

    function onlyAMMMintingAndBurning() external view returns (bool);

    function transformCollateral(uint value) external view returns (uint);

    function reverseTransformCollateral(uint value) external view returns (uint);

    function totalDeposited() external view returns (uint);

    function numActiveMarkets() external view returns (uint);

    function activeMarkets(uint index, uint pageSize) external view returns (address[] memory);

    function numMaturedMarkets() external view returns (uint);

    function maturedMarkets(uint index, uint pageSize) external view returns (address[] memory);

    function isActiveMarket(address candidate) external view returns (bool);

    function isKnownMarket(address candidate) external view returns (bool);

    function getThalesAMM() external view returns (address);

    /* ========== MUTATIVE FUNCTIONS ========== */

    function createMarket(
        bytes32 oracleKey,
        uint strikePrice,
        uint maturity,
        uint initialMint // initial sUSD to mint options for,
    ) external returns (IPositionalMarket);

    function resolveMarket(address market) external;

    function expireMarkets(address[] calldata market) external;

    function transferSusdTo(
        address sender,
        address receiver,
        uint amount
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.16;

interface IPriceFeed {
    // Structs
    struct RateAndUpdatedTime {
        uint216 rate;
        uint40 time;
    }

    // Mutative functions
    function addAggregator(bytes32 currencyKey, address aggregatorAddress) external;

    function removeAggregator(bytes32 currencyKey) external;

    // Views

    function rateForCurrency(bytes32 currencyKey) external view returns (uint);

    function rateAndUpdatedTime(bytes32 currencyKey) external view returns (uint rate, uint time);

    function getRates() external view returns (uint[] memory);

    function getCurrencies() external view returns (bytes32[] memory);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract OwnedWithInit {
    address public owner;
    address public nominatedOwner;

    constructor() {}

    function initOwner(address _owner) internal {
        require(owner == address(0), "Init can only be called when owner is 0");
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    function nominateNewOwner(address _owner) external onlyOwner {
        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    function acceptOwnership() external {
        require(msg.sender == nominatedOwner, "You must be nominated before you can accept ownership");
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner {
        _onlyOwner();
        _;
    }

    function _onlyOwner() private view {
        require(msg.sender == owner, "Only the contract owner may perform this action");
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../interfaces/IPositionalMarket.sol";

interface IOracleInstance {
    /* ========== VIEWS / VARIABLES ========== */

    function getOutcome() external view returns (bool);

    function resolvable() external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library AddressSetLib {
    struct AddressSet {
        address[] elements;
        mapping(address => uint) indices;
    }

    function contains(AddressSet storage set, address candidate) internal view returns (bool) {
        if (set.elements.length == 0) {
            return false;
        }
        uint index = set.indices[candidate];
        return index != 0 || set.elements[0] == candidate;
    }

    function getPage(
        AddressSet storage set,
        uint index,
        uint pageSize
    ) internal view returns (address[] memory) {
        // NOTE: This implementation should be converted to slice operators if the compiler is updated to v0.6.0+
        uint endIndex = index + pageSize; // The check below that endIndex <= index handles overflow.

        // If the page extends past the end of the list, truncate it.
        if (endIndex > set.elements.length) {
            endIndex = set.elements.length;
        }
        if (endIndex <= index) {
            return new address[](0);
        }

        uint n = endIndex - index; // We already checked for negative overflow.
        address[] memory page = new address[](n);
        for (uint i; i < n; i++) {
            page[i] = set.elements[i + index];
        }
        return page;
    }

    function add(AddressSet storage set, address element) internal {
        // Adding to a set is an idempotent operation.
        if (!contains(set, element)) {
            set.indices[element] = set.elements.length;
            set.elements.push(element);
        }
    }

    function remove(AddressSet storage set, address element) internal {
        require(contains(set, element), "Element not in set.");
        // Replace the removed element with the last element of the list.
        uint index = set.indices[element];
        uint lastIndex = set.elements.length - 1; // We required that element is in the list, so it is not empty.
        if (index != lastIndex) {
            // No need to shift the last element if it is the one we want to delete.
            address shiftedElement = set.elements[lastIndex];
            set.elements[index] = shiftedElement;
            set.indices[shiftedElement] = index;
        }
        set.elements.pop();
        delete set.indices[element];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ----------------------------------------------------------------------------
// DateTime Library v2.0
//
// A gas-efficient Solidity date and time library
//
// https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
//
// Tested date range 1970/01/01 to 2345/12/31
//
// Conventions:
// Unit      | Range         | Notes
// :-------- |:-------------:|:-----
// timestamp | >= 0          | Unix timestamp, number of seconds since 1970/01/01 00:00:00 UTC
// year      | 1970 ... 2345 |
// month     | 1 ... 12      |
// day       | 1 ... 31      |
// hour      | 0 ... 23      |
// minute    | 0 ... 59      |
// second    | 0 ... 59      |
// dayOfWeek | 1 ... 7       | 1 = Monday, ..., 7 = Sunday
//
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2018-2019. The MIT Licence.
// ----------------------------------------------------------------------------

library DateTime {
    uint256 constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint256 constant SECONDS_PER_HOUR = 60 * 60;
    uint256 constant SECONDS_PER_MINUTE = 60;
    int256 constant OFFSET19700101 = 2440588;

    uint256 constant DOW_MON = 1;
    uint256 constant DOW_TUE = 2;
    uint256 constant DOW_WED = 3;
    uint256 constant DOW_THU = 4;
    uint256 constant DOW_FRI = 5;
    uint256 constant DOW_SAT = 6;
    uint256 constant DOW_SUN = 7;

    // ------------------------------------------------------------------------
    // Calculate the number of days from 1970/01/01 to year/month/day using
    // the date conversion algorithm from
    //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
    // and subtracting the offset 2440588 so that 1970/01/01 is day 0
    //
    // days = day
    //      - 32075
    //      + 1461 * (year + 4800 + (month - 14) / 12) / 4
    //      + 367 * (month - 2 - (month - 14) / 12 * 12) / 12
    //      - 3 * ((year + 4900 + (month - 14) / 12) / 100) / 4
    //      - offset
    // ------------------------------------------------------------------------
    function _daysFromDate(
        uint256 year,
        uint256 month,
        uint256 day
    ) internal pure returns (uint256 _days) {
        require(year >= 1970);
        int256 _year = int256(year);
        int256 _month = int256(month);
        int256 _day = int256(day);

        int256 __days =
            _day -
                32075 +
                (1461 * (_year + 4800 + (_month - 14) / 12)) /
                4 +
                (367 * (_month - 2 - ((_month - 14) / 12) * 12)) /
                12 -
                (3 * ((_year + 4900 + (_month - 14) / 12) / 100)) /
                4 -
                OFFSET19700101;

        _days = uint256(__days);
    }

    // ------------------------------------------------------------------------
    // Calculate year/month/day from the number of days since 1970/01/01 using
    // the date conversion algorithm from
    //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
    // and adding the offset 2440588 so that 1970/01/01 is day 0
    //
    // int L = days + 68569 + offset
    // int N = 4 * L / 146097
    // L = L - (146097 * N + 3) / 4
    // year = 4000 * (L + 1) / 1461001
    // L = L - 1461 * year / 4 + 31
    // month = 80 * L / 2447
    // dd = L - 2447 * month / 80
    // L = month / 11
    // month = month + 2 - 12 * L
    // year = 100 * (N - 49) + year + L
    // ------------------------------------------------------------------------
    function _daysToDate(uint256 _days)
        internal
        pure
        returns (
            uint256 year,
            uint256 month,
            uint256 day
        )
    {
        int256 __days = int256(_days);

        int256 L = __days + 68569 + OFFSET19700101;
        int256 N = (4 * L) / 146097;
        L = L - (146097 * N + 3) / 4;
        int256 _year = (4000 * (L + 1)) / 1461001;
        L = L - (1461 * _year) / 4 + 31;
        int256 _month = (80 * L) / 2447;
        int256 _day = L - (2447 * _month) / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint256(_year);
        month = uint256(_month);
        day = uint256(_day);
    }

    function timestampFromDate(
        uint256 year,
        uint256 month,
        uint256 day
    ) internal pure returns (uint256 timestamp) {
        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY;
    }

    function timestampFromDateTime(
        uint256 year,
        uint256 month,
        uint256 day,
        uint256 hour,
        uint256 minute,
        uint256 second
    ) internal pure returns (uint256 timestamp) {
        timestamp =
            _daysFromDate(year, month, day) *
            SECONDS_PER_DAY +
            hour *
            SECONDS_PER_HOUR +
            minute *
            SECONDS_PER_MINUTE +
            second;
    }

    function timestampToDate(uint256 timestamp)
        internal
        pure
        returns (
            uint256 year,
            uint256 month,
            uint256 day
        )
    {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function timestampToDateTime(uint256 timestamp)
        internal
        pure
        returns (
            uint256 year,
            uint256 month,
            uint256 day,
            uint256 hour,
            uint256 minute,
            uint256 second
        )
    {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint256 secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
        secs = secs % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
        second = secs % SECONDS_PER_MINUTE;
    }

    function isValidDate(
        uint256 year,
        uint256 month,
        uint256 day
    ) internal pure returns (bool valid) {
        if (year >= 1970 && month > 0 && month <= 12) {
            uint256 daysInMonth = _getDaysInMonth(year, month);
            if (day > 0 && day <= daysInMonth) {
                valid = true;
            }
        }
    }

    function isValidDateTime(
        uint256 year,
        uint256 month,
        uint256 day,
        uint256 hour,
        uint256 minute,
        uint256 second
    ) internal pure returns (bool valid) {
        if (isValidDate(year, month, day)) {
            if (hour < 24 && minute < 60 && second < 60) {
                valid = true;
            }
        }
    }

    function isLeapYear(uint256 timestamp)
        internal
        pure
        returns (bool leapYear)
    {
        (uint256 year, , ) = _daysToDate(timestamp / SECONDS_PER_DAY);
        leapYear = _isLeapYear(year);
    }

    function _isLeapYear(uint256 year) internal pure returns (bool leapYear) {
        leapYear = ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);
    }

    function isWeekDay(uint256 timestamp) internal pure returns (bool weekDay) {
        weekDay = getDayOfWeek(timestamp) <= DOW_FRI;
    }

    function isWeekEnd(uint256 timestamp) internal pure returns (bool weekEnd) {
        weekEnd = getDayOfWeek(timestamp) >= DOW_SAT;
    }

    function getDaysInMonth(uint256 timestamp)
        internal
        pure
        returns (uint256 daysInMonth)
    {
        (uint256 year, uint256 month, ) =
            _daysToDate(timestamp / SECONDS_PER_DAY);
        daysInMonth = _getDaysInMonth(year, month);
    }

    function _getDaysInMonth(uint256 year, uint256 month)
        internal
        pure
        returns (uint256 daysInMonth)
    {
        if (
            month == 1 ||
            month == 3 ||
            month == 5 ||
            month == 7 ||
            month == 8 ||
            month == 10 ||
            month == 12
        ) {
            daysInMonth = 31;
        } else if (month != 2) {
            daysInMonth = 30;
        } else {
            daysInMonth = _isLeapYear(year) ? 29 : 28;
        }
    }

    // 1 = Monday, 7 = Sunday
    function getDayOfWeek(uint256 timestamp)
        internal
        pure
        returns (uint256 dayOfWeek)
    {
        uint256 _days = timestamp / SECONDS_PER_DAY;
        dayOfWeek = ((_days + 3) % 7) + 1;
    }

    function getYear(uint256 timestamp) internal pure returns (uint256 year) {
        (year, , ) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function getMonth(uint256 timestamp) internal pure returns (uint256 month) {
        (, month, ) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function getDay(uint256 timestamp) internal pure returns (uint256 day) {
        (, , day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function getHour(uint256 timestamp) internal pure returns (uint256 hour) {
        uint256 secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
    }

    function getMinute(uint256 timestamp)
        internal
        pure
        returns (uint256 minute)
    {
        uint256 secs = timestamp % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
    }

    function getSecond(uint256 timestamp)
        internal
        pure
        returns (uint256 second)
    {
        second = timestamp % SECONDS_PER_MINUTE;
    }

    function addYears(uint256 timestamp, uint256 _years)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        (uint256 year, uint256 month, uint256 day) =
            _daysToDate(timestamp / SECONDS_PER_DAY);
        year += _years;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp =
            _daysFromDate(year, month, day) *
            SECONDS_PER_DAY +
            (timestamp % SECONDS_PER_DAY);
        require(newTimestamp >= timestamp);
    }

    function addMonths(uint256 timestamp, uint256 _months)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        (uint256 year, uint256 month, uint256 day) =
            _daysToDate(timestamp / SECONDS_PER_DAY);
        month += _months;
        year += (month - 1) / 12;
        month = ((month - 1) % 12) + 1;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp =
            _daysFromDate(year, month, day) *
            SECONDS_PER_DAY +
            (timestamp % SECONDS_PER_DAY);
        require(newTimestamp >= timestamp);
    }

    function addDays(uint256 timestamp, uint256 _days)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp + _days * SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }

    function addHours(uint256 timestamp, uint256 _hours)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp + _hours * SECONDS_PER_HOUR;
        require(newTimestamp >= timestamp);
    }

    function addMinutes(uint256 timestamp, uint256 _minutes)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp + _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp >= timestamp);
    }

    function addSeconds(uint256 timestamp, uint256 _seconds)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp + _seconds;
        require(newTimestamp >= timestamp);
    }

    function subYears(uint256 timestamp, uint256 _years)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        (uint256 year, uint256 month, uint256 day) =
            _daysToDate(timestamp / SECONDS_PER_DAY);
        year -= _years;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp =
            _daysFromDate(year, month, day) *
            SECONDS_PER_DAY +
            (timestamp % SECONDS_PER_DAY);
        require(newTimestamp <= timestamp);
    }

    function subMonths(uint256 timestamp, uint256 _months)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        (uint256 year, uint256 month, uint256 day) =
            _daysToDate(timestamp / SECONDS_PER_DAY);
        uint256 yearMonth = year * 12 + (month - 1) - _months;
        year = yearMonth / 12;
        month = (yearMonth % 12) + 1;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp =
            _daysFromDate(year, month, day) *
            SECONDS_PER_DAY +
            (timestamp % SECONDS_PER_DAY);
        require(newTimestamp <= timestamp);
    }

    function subDays(uint256 timestamp, uint256 _days)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp - _days * SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }

    function subHours(uint256 timestamp, uint256 _hours)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp - _hours * SECONDS_PER_HOUR;
        require(newTimestamp <= timestamp);
    }

    function subMinutes(uint256 timestamp, uint256 _minutes)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp - _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp <= timestamp);
    }

    function subSeconds(uint256 timestamp, uint256 _seconds)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp - _seconds;
        require(newTimestamp <= timestamp);
    }

    function diffYears(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _years)
    {
        require(fromTimestamp <= toTimestamp);
        (uint256 fromYear, , ) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint256 toYear, , ) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _years = toYear - fromYear;
    }

    function diffMonths(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _months)
    {
        require(fromTimestamp <= toTimestamp);
        (uint256 fromYear, uint256 fromMonth, ) =
            _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint256 toYear, uint256 toMonth, ) =
            _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _months = toYear * 12 + toMonth - fromYear * 12 - fromMonth;
    }

    function diffDays(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _days)
    {
        require(fromTimestamp <= toTimestamp);
        _days = (toTimestamp - fromTimestamp) / SECONDS_PER_DAY;
    }

    function diffHours(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _hours)
    {
        require(fromTimestamp <= toTimestamp);
        _hours = (toTimestamp - fromTimestamp) / SECONDS_PER_HOUR;
    }

    function diffMinutes(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _minutes)
    {
        require(fromTimestamp <= toTimestamp);
        _minutes = (toTimestamp - fromTimestamp) / SECONDS_PER_MINUTE;
    }

    function diffSeconds(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _seconds)
    {
        require(fromTimestamp <= toTimestamp);
        _seconds = toTimestamp - fromTimestamp;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Inheritance
import "../utils/proxy/solidity-0.8.0/ProxyOwned.sol";

// Internal references
import "./Position.sol";
import "./PositionalMarket.sol";
import "./PositionalMarketFactory.sol";
import "../interfaces/IPriceFeed.sol";
import "../interfaces/IPositionalMarket.sol";
import "@openzeppelin/contracts-4.4.1/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-4.4.1/proxy/Clones.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract PositionalMarketFactory is Initializable, ProxyOwned {
    /* ========== STATE VARIABLES ========== */
    address public positionalMarketManager;

    address public positionalMarketMastercopy;
    address public positionMastercopy;

    address public limitOrderProvider;
    address public thalesAMM;

    struct PositionCreationMarketParameters {
        address creator;
        IERC20 _sUSD;
        IPriceFeed _priceFeed;
        bytes32 oracleKey;
        uint strikePrice;
        uint[2] times; // [maturity, expiry]
        uint initialMint;
    }

    function initialize(address _owner) external initializer {
        setOwner(_owner);
    }

    /// @notice createMarket create market function
    /// @param _parameters PositionCreationMarketParameters needed for market creation
    /// @return PositionalMarket created market
    function createMarket(PositionCreationMarketParameters calldata _parameters) external returns (PositionalMarket) {
        require(positionalMarketManager == msg.sender, "Only permitted by the manager.");

        PositionalMarket pom = PositionalMarket(Clones.clone(positionalMarketMastercopy));
        Position up = Position(Clones.clone(positionMastercopy));
        Position down = Position(Clones.clone(positionMastercopy));
        pom.initialize(
            PositionalMarket.PositionalMarketParameters(
                positionalMarketManager,
                _parameters._sUSD,
                _parameters._priceFeed,
                _parameters.creator,
                _parameters.oracleKey,
                _parameters.strikePrice,
                _parameters.times,
                _parameters.initialMint,
                address(up),
                address(down),
                thalesAMM
            )
        );
        emit MarketCreated(
            address(pom),
            _parameters.oracleKey,
            _parameters.strikePrice,
            _parameters.times[0],
            _parameters.times[1],
            _parameters.initialMint
        );
        return pom;
    }

    /// @notice setPositionalMarketManager sets positionalMarketManager value
    /// @param _positionalMarketManager address of the PositionalMarketManager contract
    function setPositionalMarketManager(address _positionalMarketManager) external onlyOwner {
        positionalMarketManager = _positionalMarketManager;
        emit PositionalMarketManagerChanged(_positionalMarketManager);
    }

    /// @notice setPositionalMarketMastercopy sets positionalMarketMastercopy value
    /// @param _positionalMarketMastercopy address of the PositionalMarketMastercopy contract
    function setPositionalMarketMastercopy(address _positionalMarketMastercopy) external onlyOwner {
        positionalMarketMastercopy = _positionalMarketMastercopy;
        emit PositionalMarketMastercopyChanged(_positionalMarketMastercopy);
    }

    /// @notice setPositionMastercopy sets positionMastercopy value
    /// @param _positionMastercopy address of the PositionMastercopy contract
    function setPositionMastercopy(address _positionMastercopy) external onlyOwner {
        positionMastercopy = _positionMastercopy;
        emit PositionMastercopyChanged(_positionMastercopy);
    }

    /// @notice setThalesAMM sets thalesAMM value
    /// @param _thalesAMM address of ThalesAMM contract
    function setThalesAMM(address _thalesAMM) external onlyOwner {
        thalesAMM = _thalesAMM;
        emit SetThalesAMM(_thalesAMM);
    }

    event PositionalMarketManagerChanged(address _positionalMarketManager);
    event PositionalMarketMastercopyChanged(address _positionalMarketMastercopy);
    event PositionMastercopyChanged(address _positionMastercopy);
    event SetThalesAMM(address _thalesAMM);
    event MarketCreated(
        address market,
        bytes32 indexed oracleKey,
        uint strikePrice,
        uint maturityDate,
        uint expiryDate,
        uint initialMint
    );
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/Clones.sol)

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// in position collaterized by 0.5 UP on the left leg and 0.5 DOWN on the right leg

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Inheritance
import "@openzeppelin/contracts-4.4.1/token/ERC20/IERC20.sol";
import "../interfaces/IPosition.sol";

// Internal references
import "./RangedMarket.sol";

contract RangedPosition is IERC20 {
    /* ========== STATE VARIABLES ========== */

    string public name;
    string public symbol;
    uint8 public constant decimals = 18;

    RangedMarket public rangedMarket;

    mapping(address => uint) public override balanceOf;
    uint public override totalSupply;

    // The argument order is allowance[owner][spender]
    mapping(address => mapping(address => uint)) private allowances;

    // Enforce a 1 cent minimum amount
    uint internal constant _MINIMUM_AMOUNT = 1e16;

    address public thalesRangedAMM;
    /* ========== CONSTRUCTOR ========== */

    bool public initialized = false;

    function initialize(
        address market,
        string calldata _name,
        string calldata _symbol,
        address _thalesRangedAMM
    ) external {
        require(!initialized, "Ranged Market already initialized");
        initialized = true;
        rangedMarket = RangedMarket(market);
        name = _name;
        symbol = _symbol;
        thalesRangedAMM = _thalesRangedAMM;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        if (spender == thalesRangedAMM) {
            return type(uint256).max;
        } else {
            return allowances[owner][spender];
        }
    }

    function burn(address claimant, uint amount) external onlyRangedMarket {
        balanceOf[claimant] = balanceOf[claimant] - amount;
        totalSupply = totalSupply - amount;
        emit Burned(claimant, amount);
        emit Transfer(claimant, address(0), amount);
    }

    function mint(address minter, uint amount) external onlyRangedMarket {
        _requireMinimumAmount(amount);
        totalSupply = totalSupply + amount;
        balanceOf[minter] = balanceOf[minter] + amount; // Increment rather than assigning since a transfer may have occurred.
        emit Mint(minter, amount);
        emit Transfer(address(0), minter, amount);
    }

    /* ---------- ERC20 Functions ---------- */

    function _transfer(
        address _from,
        address _to,
        uint _value
    ) internal returns (bool success) {
        require(_to != address(0) && _to != address(this), "Invalid address");

        uint fromBalance = balanceOf[_from];
        require(_value <= fromBalance, "Insufficient balance");

        balanceOf[_from] = fromBalance - _value;
        balanceOf[_to] = balanceOf[_to] + _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    function transfer(address _to, uint _value) external override returns (bool success) {
        return _transfer(msg.sender, _to, _value);
    }

    function transferFrom(
        address _from,
        address _to,
        uint _value
    ) external override returns (bool success) {
        if (msg.sender != thalesRangedAMM) {
            uint fromAllowance = allowances[_from][msg.sender];
            require(_value <= fromAllowance, "Insufficient allowance");
            allowances[_from][msg.sender] = fromAllowance - _value;
        }
        return _transfer(_from, _to, _value);
    }

    function approve(address _spender, uint _value) external override returns (bool success) {
        require(_spender != address(0));
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function getBalanceOf(address account) external view returns (uint) {
        return balanceOf[account];
    }

    function getTotalSupply() external view returns (uint) {
        return totalSupply;
    }

    modifier onlyRangedMarket {
        require(msg.sender == address(rangedMarket), "only the Ranged Market may perform these methods");
        _;
    }

    function _requireMinimumAmount(uint amount) internal pure returns (uint) {
        require(amount >= _MINIMUM_AMOUNT || amount == 0, "Balance < $0.01");
        return amount;
    }

    event Mint(address minter, uint amount);
    event Burned(address burner, uint amount);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library MathUpgradeable {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
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
    function __Pausable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the `nonReentrant` modifier
 * available, which can be aplied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 */
contract ProxyReentrancyGuard {
    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;
    bool private _initialized;

    function initNonReentrant() public {
        require(!_initialized, "Already initialized");
        _initialized = true;
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.16;

interface IStakingThales {
    function updateVolume(address account, uint amount) external;

    /* ========== VIEWS / VARIABLES ========== */
    function totalStakedAmount() external view returns (uint);

    function stakedBalanceOf(address account) external view returns (uint);

    function currentPeriodRewards() external view returns (uint);

    function currentPeriodFees() external view returns (uint);

    function getLastPeriodOfClaimedRewards(address account) external view returns (uint);

    function getRewardsAvailable(address account) external view returns (uint);

    function getRewardFeesAvailable(address account) external view returns (uint);

    function getAlreadyClaimedRewards(address account) external view returns (uint);

    function getContractRewardFunds() external view returns (uint);

    function getContractFeeFunds() external view returns (uint);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16;

interface IReferrals {
    function referrals(address) external view returns (address);

    function sportReferrals(address) external view returns (address);

    function setReferrer(address, address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16;

interface ICurveSUSD {
    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 _dx,
        uint256 _min_dy
    ) external returns (uint256);

    function get_dy_underlying(
        int128 i,
        int128 j,
        uint256 _dx
    ) external view returns (uint256);

    //    @notice Perform an exchange between two underlying coins
    //    @param i Index value for the underlying coin to send
    //    @param j Index valie of the underlying coin to receive
    //    @param _dx Amount of `i` being exchanged
    //    @param _min_dy Minimum amount of `j` to receive
    //    @param _receiver Address that receives `j`
    //    @return Actual amount of `j` received

    // indexes:
    // 0 = sUSD 18 dec 0x8c6f28f2F1A3C87F0f938b96d27520d9751ec8d9
    // 1= DAI 18 dec 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1
    // 2= USDC 6 dec 0x7F5c764cBc14f9669B88837ca1490cCa17c31607
    // 3= USDT 6 dec 0x94b008aA00579c1307B0EF2c499aD98a8ce58e58
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}