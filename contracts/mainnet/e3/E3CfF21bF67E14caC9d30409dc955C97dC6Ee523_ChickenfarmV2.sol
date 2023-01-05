/**
 *Submitted for verification at BscScan.com on 2023-01-05
*/

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// File: Libraries.sol


pragma solidity ^0.8.9;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value)
        private
        view
        returns (bool)
    {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index)
        private
        view
        returns (bytes32)
    {
        require(
            set._values.length > index,
            "EnumerableSet: index out of bounds"
        );
        return set._values[index];
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value)
        internal
        view
        returns (bool)
    {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index)
        internal
        view
        returns (bytes32)
    {
        return _at(set._inner, index);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value)
        internal
        view
        returns (bool)
    {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index)
        internal
        view
        returns (address)
    {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value)
        internal
        returns (bool)
    {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value)
        internal
        view
        returns (bool)
    {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index)
        internal
        view
        returns (uint256)
    {
        return uint256(_at(set._inner, index));
    }
}

interface IDEXFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IDEXRouter {
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    )
        external
        returns (
            uint amountA,
            uint amountB,
            uint liquidity
        );

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (
            uint amountToken,
            uint amountETH,
            uint liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapTokensForExactETH(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapETHForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function quote(
        uint amountA,
        uint reserveA,
        uint reserveB
    ) external pure returns (uint amountB);

    function getamountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountOut);

    function getamountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountIn);

    function getamountsOut(uint amountIn, address[] calldata path)
        external
        view
        returns (uint[] memory amounts);

    function getamountsIn(uint amountOut, address[] calldata path)
        external
        view
        returns (uint[] memory amounts);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IDEXPair {
    function sync() external;
}

// File: Chickenland.sol


pragma solidity ^0.8.9;



interface IBonusProvider {
    function getCornBonus(
        address account
    ) external view returns (uint cornBonus);

    function getCornConsumption(
        address account
    ) external view returns (uint cornConsumption);

    function getRetireeRate(
        address account
    ) external view returns (uint retireeRate);

    function getBaseRate(address account) external view returns (uint baseRate);

    function getChickenBuyRate(
        address account
    ) external view returns (uint buyRate);

    function getChickenCompoundRate(
        address account
    ) external view returns (uint compoundRate);

    function getEggSellRate(
        address account
    ) external view returns (uint sellRate);
}

contract ChickenfarmV2 is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    IBonusProvider bonusProvider;

    //4%
    uint constant Fee = 40_000;
    uint constant DENOMINATOR = 1_000_000;
    address public FeeWallet;
    //5000 Chickens per Dollar
    uint constant RatePerDollar = 5000;
    //100 chickens produce 9 eggs per day without corn
    uint public constant BaseRate = 90_000; //Base Rate without corn

    //100 Chickens produce 10 Eggs per day with corn(1% bonus)
    uint public constant CornBonus = 10_000; //Bonus with corn
    // 8% of all chickens retire each day to KFC-Retirement INC.
    uint public RetireeRate = 10_000; //Reduction from base Rate that chickens retire with
    //3000 BUSD default max payout
    uint public maxPayout = 3000 * 10 ** 18;

    IDEXRouter router=IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    //Time when last sell/compound happened
    mapping(address => uint) public lastHatch;
    //Time when first hatch happened, payout days are based on it
    mapping(address => uint) public lastStrategyChange;
    //Strategy. with corn each strategy>6 is sustainable, without Corn each strategy >10 is sustainable
    //Sweet spot for a year is around 20-40, the higher the strategy, the higher the risk, but the higher the potential long term reward
    mapping(address => uint) public strategy;
    //amount of chickens
    mapping(address => uint) public chickens;
    //chickens that are possible to unlock either by referring or by buying new chickens
    mapping(address => uint) public lockedChickens;
    //Corn unlocks when first time sending BNB to the contract to buy chickens
    mapping(address => uint) public lockedCorn;
    mapping(address => uint) public totalReferralBonus;
    mapping(address => uint) public totalPayout;
    mapping(address => uint) public totalInvestment;
    EnumerableSet.AddressSet holders;
    IBEP20 BUSD=IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    

    uint public defaultStrategy = 14;
    uint public minStrategy = 7;
    mapping(address => bool) public excluded;
    event OnSetBonusProvider(address provider);
    event OnSetStrategy(address account, uint strategy_);
    event OnBuyChickens(uint amount, address account);
    event OnUnlockChickens(uint amount, address account);
    event OnSetDefaultStrategy(uint strategy_);
    event OnSetMinStrategy(uint minStrategy_);
    event OnHatchChickens(uint hatched, uint retired, address account);
    event OnSellEggs(uint value, uint retiredChickens, address account);
    event OnSetCornHarvest(uint harvestToConsumptionRate);
    event OnExcludeFromCornFees(bool exclude);
    event OnCompound(uint BUSD, int Chickens, address account);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);
    event OnSetLaunch(uint LaunchTimestamp);


    constructor() {
        _name = "Chickenland";
        _symbol = "BitCorn";
        FeeWallet = msg.sender;
        pair = IDEXFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );
        _mint(msg.sender, 100 * 10 ** 9 * 10 ** decimals);
        excluded[msg.sender] = true;
        excluded[address(this)] = true;
        excluded[address(0xF00D)] = true;
        excluded[address(0xc)] = true;
    }

    function exclude(address account, bool flag) external onlyOwner {
        excluded[account] = flag;
        emit OnExcludeFromCornFees(flag);
    }

    function setCornHarvest(
        uint newHarvestToConsumptionRate
    ) external onlyOwner {
        harvestToConsumptionRate = newHarvestToConsumptionRate;
        emit OnSetCornHarvest(harvestToConsumptionRate);
    }

    address pair;
    uint public harvestToConsumptionRate = 1_000_000;

    function consumeCorn(address account, uint amount) private {
        uint balance = _balances[account];
        if (balance == 0) return;
        if (amount > balance) amount = balance;

        _burn(account, amount);
        _mint(pair, (amount * harvestToConsumptionRate) / DENOMINATOR);
        IDEXPair(pair).sync();
    }

    //BonusProvider functions
    function setBonusProvider(address provider) external onlyOwner {
        bonusProvider = IBonusProvider(provider);
        emit OnSetBonusProvider(provider);
    }

    function getBaseRate(address account) public view returns (uint) {
        if (address(bonusProvider) == address(0)) return BaseRate;
        else return bonusProvider.getBaseRate(account);
    }

    function getCornBonus(address account) public view returns (uint) {
        if (address(bonusProvider) == address(0)) return CornBonus;
        else return bonusProvider.getCornBonus(account);
    }

    function getCornConsumption(address account) public view returns (uint) {
        if (address(bonusProvider) == address(0)) return DENOMINATOR * 10 ** 18;
        else return bonusProvider.getCornConsumption(account);
    }

    function getChickenCompoundRate(
        address account
    ) public view returns (uint) {
        if (address(bonusProvider) == address(0)) return DENOMINATOR;
        else return bonusProvider.getChickenCompoundRate(account);
    }

    function getChickenBuyRate(address account) public view returns (uint) {
        if (address(bonusProvider) == address(0)) return DENOMINATOR;
        else return bonusProvider.getChickenBuyRate(account);
    }

    function getEggSellRate(address account) public view returns (uint) {
        if (address(bonusProvider) == address(0)) return DENOMINATOR;
        else return bonusProvider.getEggSellRate(account);
    }

    function getRetireeRate(address account) public view returns (uint) {
        if (address(bonusProvider) == address(0)) return BaseRate - RetireeRate;
        else return bonusProvider.getRetireeRate(account);
    }

    //Farmer Interactions with contract

    //Buys chickens using BUSD, generally not recomended because it requires approving BUSD to a DAPP
    function BuyChickens(uint BUSDAmount, address referer) external {
        BUSD.transferFrom(msg.sender, address(this), BUSDAmount);
        _buyChickens(BUSDAmount, msg.sender, referer);
    }

    //Buys chickens with ETH, swaps the ETH for BUSD, doesn't require approving so recomended
    function BuyChickensWithETH(address referer) public payable {
        uint BUSDAmount = _swapETHForBUSD();
        _buyChickens(BUSDAmount, msg.sender, referer);
    }

    function Compound() public {
        address msgSender = msg.sender;
        uint chickenBefore = chickens[msgSender];
        uint BUSDBefore = BUSD.balanceOf(msgSender);
        if (lastStrategyChange[msgSender] > 0) this._compound(msgSender);
        int chickenResult = int(chickens[msgSender]) - int(chickenBefore);
        uint BUSDResult = BUSD.balanceOf(msgSender) - BUSDBefore;
        emit OnCompound(BUSDResult, chickenResult, msgSender);
        _autoCompound();
    }

    //Buys corn and deducts 10% fee
    function BuyCorn() external payable {
        address[] memory path = new address[](2);
        path[0] = router.WETH(); //BNB
        path[1] = address(this);

        router.swapExactETHForTokens{value: (address(this).balance * 9) / 10}(
            0,
            path,
            address(0xF00D),
            block.timestamp
        );
        uint amount = _balances[address(0xF00D)];
        _burn(address(0xF00D), amount);
        _mint(msg.sender, amount);
        uint busd = _swapETHForBUSD();
        BUSD.transfer(FeeWallet, (busd * 3) / 10);
    }

    function ChangeStrategy(uint strategy_) external {
        require(lastStrategyChange[msg.sender] > 0);
        if (strategy_ <= minStrategy) strategy_ = defaultStrategy;
        strategy[msg.sender] = strategy_;
        lastStrategyChange[msg.sender] = block.timestamp;
        emit OnSetStrategy(msg.sender, strategy_);
    }

    //Functions to lock chickens for OG farmers to be earned

    function lockChickens(
        address[] memory accounts,
        uint[] memory amounts
    ) external onlyOwner {
        require(accounts.length == amounts.length);
        for (uint i = 0; i < amounts.length; i++) {
            lockedChickens[accounts[i]] += amounts[i];
        }
    }

    function lockCorn(
        address[] memory accounts,
        uint[] memory amounts
    ) external onlyOwner {
        uint totalAmount = 0;
        require(accounts.length == amounts.length);
        for (uint i = 0; i < amounts.length; i++) {
            uint amount = amounts[i];
            lockedCorn[accounts[i]] += amount;
            totalAmount += amount;
        }
        _balances[address(0xc)] += totalAmount;
        _totalSupply += totalAmount;
    }

    //Allows the owner to unlock locked Chickens, rewarding active OG community members
    function UnlockChickens(address account, uint amount) external onlyOwner {
        _unlockChickens(amount, account);
    }

    function _unlockCorn() private {
        address acc = msg.sender;
        uint _lockedCorn = lockedCorn[acc];
        if (_lockedCorn > 0) {
            lockedCorn[acc] = 0;
            _transfer(address(0xc), acc, _lockedCorn);
        }
    }

    function _unlockChickens(uint amount, address account) private {
        uint unlockAmount = lockedChickens[account];
        if (unlockAmount == 0) return;
        if (amount < unlockAmount) unlockAmount = amount;
        lockedChickens[account] -= unlockAmount;
        chickens[account] += unlockAmount;
        emit OnUnlockChickens(unlockAmount, account);
    }

    //Default strategy when someone buys, 10 by default as the minimum sustainable without corn
    function setDefaultStrategy(uint strategy_) external onlyOwner {
        require(strategy_ > 0);
        defaultStrategy = strategy_;
        emit OnSetDefaultStrategy(strategy_);
    }

    function setMinStrategy(uint strategy_) external onlyOwner {
        require(strategy_ > 0);
        minStrategy = strategy_;
        emit OnSetMinStrategy(strategy_);
    }

    function setMaxPayout(uint newMaxPayout) external onlyOwner {
        require(newMaxPayout > 1000 * 10 ** 18);
        maxPayout = newMaxPayout;
    }

    function _buyChickens(
        uint BUSDAmount,
        address buyer,
        address referer
    ) private {
        totalInvestment[buyer] += BUSDAmount;
        //deduct Fee
        BUSD.transfer(FeeWallet, (BUSDAmount * Fee) / DENOMINATOR);

        //get timestamps
        if (lastStrategyChange[buyer] == 0) {
            lastHatch[buyer] = block.timestamp;
            lastStrategyChange[buyer] = block.timestamp;
            strategy[buyer] = defaultStrategy;
            holders.add(buyer);
            _autoCompound();
        } else Compound();

        uint chickenAmount = (BUSDAmount * RatePerDollar) / 10 ** 18;
        require(chickenAmount > 0, "No chickens bought");
        chickens[buyer] += chickenAmount;
        if (referer == address(0) || referer == msg.sender) referer = FeeWallet;
        else {
            _unlockChickens(chickenAmount / 4, referer);
        }
        uint referralAmount = BUSDAmount / 10;
        //10% go to referer
        BUSD.transfer(referer, referralAmount);
        totalReferralBonus[referer] += referralAmount;
        _unlockChickens(chickenAmount / 4, buyer);
        emit OnBuyChickens(chickenAmount, buyer);
    }

    uint256 currentCompoundIndex = 0;
    uint256 compoundsPerClaim = 5;
    bool locked;
    modifier lock() {
        require(!locked);
        locked = true;
        _;
        locked = false;
    }

    function _autoCompound() private {
        if (holders.length() == 0) return;
        if (currentCompoundIndex >= holders.length()) {
            currentCompoundIndex = 0;
        }
        for (uint256 i = 0; i < compoundsPerClaim; i++) {
            try this._compound(holders.at(currentCompoundIndex)) {} catch {} //if compound fails, just ignore it
            currentCompoundIndex++;
            if (currentCompoundIndex >= holders.length()) {
                currentCompoundIndex = 0;
                break;
            }
        }
    }

    function isPayoutDay(address account) public view returns (bool) {
        uint daysSinceBuy = (block.timestamp - lastStrategyChange[account]) /
            (1 days) +
            1;
        return daysSinceBuy % strategy[account] == 0;
    }

    function _compound(address account) external {
        require(msg.sender == address(this));
        if (isPayoutDay(account)) _sellEggs(account);
        else _hatchEggs(account);
    }

    function _hatchEggs(address account) private {
        (uint baseAmount_, uint cornBonus_, uint retirees_) = _getValues(
            account
        );
        lastHatch[account] = block.timestamp;
        if (baseAmount_ == 0) return;

        consumeCorn(
            account,
            (baseAmount_ * getCornConsumption(account)) / DENOMINATOR
        );
        uint hatchedChickens = ((baseAmount_ + cornBonus_) *
            getChickenCompoundRate(account)) / DENOMINATOR;
        chickens[account] += hatchedChickens - retirees_;
        emit OnHatchChickens(hatchedChickens, retirees_, account);
    }

    function _sellEggs(address account) private {
        (uint baseAmount_, uint cornBonus_, uint retirees_) = _getValues(
            account
        );
        lastHatch[account] = block.timestamp;
        if (baseAmount_ == 0) return;
        consumeCorn(
            account,
            (baseAmount_ * getCornConsumption(account)) / DENOMINATOR
        );
        uint amount = ((baseAmount_ + cornBonus_) * getEggSellRate(account)) /
            DENOMINATOR;

        (uint value, uint marketing) = getEggValue(amount);
        chickens[account] -= retirees_;






        BUSD.transfer(account, value);
        totalPayout[account] += value;
        BUSD.transfer(FeeWallet, marketing);
        emit OnSellEggs(value, retirees_, account);
    }

    function getEggs(address account) external view returns (uint) {
        (uint BaseAmount, uint cornBonus_, ) = _getValues(account);
        return BaseAmount + cornBonus_;
    }

    uint public constant Period = 1 days;

    function _getValues(
        address account
    )
        public
        view
        returns (uint BaseAmount, uint cornBonus, uint RetireeAmount)
    {
        uint TimeSinceLastHatch = block.timestamp - lastHatch[account];
        if (TimeSinceLastHatch == 0) return (0, 0, 0);
        uint amount = chickens[account];
        uint baseRate = getBaseRate(account);
        BaseAmount =
            (((amount * baseRate) / DENOMINATOR) * TimeSinceLastHatch) /
            Period;
        cornBonus =
            (((amount * getCornBonus(account)) / DENOMINATOR) *
                TimeSinceLastHatch) /
            Period;
        RetireeAmount =
            (((amount * getRetireeRate(account)) / DENOMINATOR) *
                TimeSinceLastHatch) /
            Period;
        uint AvailableCorn = _balances[account];
        uint reqiuredCorn = (BaseAmount * getCornConsumption(account)) /
            DENOMINATOR;
        if (reqiuredCorn != 0) {
            if (AvailableCorn > reqiuredCorn) AvailableCorn = reqiuredCorn;
            cornBonus = (cornBonus * AvailableCorn) / reqiuredCorn;
        }

    }

    function getEggValue(
        uint value
    ) public view returns (uint eggValue, uint marketingValue) {
        uint BUSDAmount = (value * 10 ** 18) / RatePerDollar;
        uint amountOut = getAmountOut(BUSDAmount);
        marketingValue = (amountOut * Fee) / DENOMINATOR;
        eggValue = amountOut - marketingValue;
    }

    //liquididy calculations
    function getAmountOut(
        uint256 amountIn
    ) internal view returns (uint256 amountOut) {
        uint256 reserve = BUSD.balanceOf(address(this));
        //adjusts reserve to max payout to increase slippage
        //and reduce impact
        if (reserve > maxPayout) reserve = maxPayout;
        uint256 numerator = amountIn * reserve;
        uint256 denominator = reserve + amountIn;
        amountOut = numerator / denominator;
    }

    receive() external payable {
        _unlockCorn();
        BuyChickensWithETH(address(0));
    }

    function _swapETHForBUSD() private returns (uint) {
        address[] memory path = new address[](2);
        path[0] = router.WETH(); //BNB
        path[1] = address(BUSD);
        uint initialBalance = BUSD.balanceOf(address(this));
        router.swapExactETHForTokens{value: address(this).balance}(
            0,
            path,
            address(this),
            block.timestamp
        );
        return BUSD.balanceOf(address(this)) - initialBalance;
    }

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    uint constant decimals = 18;

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(
        address owner_,
        address spender
    ) public view returns (uint256) {
        return _allowances[owner_][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        address sender = _msgSender();
        _approve(sender, spender, allowance(sender, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        address sender = _msgSender();
        uint256 currentAllowance = allowance(sender, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(sender, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function SetLaunchInSeconds(uint secondsToLaunch) external onlyOwner {
        SetLaunchTimestamp(block.timestamp + secondsToLaunch);
    }

    function SetLaunchTimestamp(uint Timestamp) public onlyOwner {
        require(block.timestamp < LaunchTimestamp);
        LaunchTimestamp = Timestamp;
        emit OnSetLaunch(LaunchTimestamp);
    }

    uint LaunchTimestamp = type(uint).max;

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        bool isExcluded = excluded[from] || excluded[to];
        uint TaxAmount;
        if (!isExcluded) {
            TaxAmount = amount / 10;
            require(block.timestamp >= LaunchTimestamp, "not Launched yet");
            if ((from != pair)) _swapContractToken();
        }

        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount - TaxAmount;
            if (TaxAmount > 0) _balances[address(this)] += TaxAmount;
        }

        emit Transfer(from, to, amount);
    }

    //Locks the swap if already swapping
    bool private _isSwappingContractModifier;
    modifier lockTheSwap() {
        _isSwappingContractModifier = true;
        _;
        _isSwappingContractModifier = false;
    }

    function _swapContractToken() private lockTheSwap {
        if (_isSwappingContractModifier) return;
        uint contractBalance = _balances[address(this)];
        //swaps each time it reaches swapTreshold of pancake pair to avoid large prize impact
        uint tokenToSwap = (_balances[pair] * 5) / 1000;
        if (contractBalance < tokenToSwap) return;
        _swapTokenForBNB(tokenToSwap);
        //Sends all the marketing BNB to the marketingWallet
        (bool sent, ) = FeeWallet.call{value: (address(this).balance * 4) / 10}(
            ""
        );
        sent = true;
        _swapETHForBUSD();
    }

    //swaps tokens on the contract for BNB
    function _swapTokenForBNB(uint amount) private {
        _approve(address(this), address(router), amount);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        try
            router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                amount,
                0,
                path,
                address(this),
                block.timestamp
            )
        {} catch {}
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner_,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner_ != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner_,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner_, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner_, spender, currentAllowance - amount);
            }
        }
    }
}