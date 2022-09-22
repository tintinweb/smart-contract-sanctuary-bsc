/**
 *Submitted for verification at BscScan.com on 2022-09-22
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

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

interface IPair {
    function sync() external;
}

interface IPancakeRouter {
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface IPancakeFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
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

interface IBonusProvider {
    function getCornConsumption(address account, uint256 amount)
        external
        view
        returns (uint256);

    function getYield(
        address account,
        uint256 baseYield,
        uint256 amount
    ) external view returns (uint256);

    function getChickensBuy(address account, uint256 baseChickens)
        external
        view
        returns (uint256);

    function getChickensCompound(address account, uint256 baseEggsOut)
        external
        view
        returns (uint256);

    function getBNBOut(address account, uint256 baseBNBOut)
        external
        view
        returns (uint256);
}

contract DefaultBonusProvider is IBonusProvider {
    function getCornConsumption(address account, uint256 amount)
        external
        pure
        returns (uint256)
    {
        account = account;
        return amount;
    }

    function getYield(
        address account,
        uint256 baseYield,
        uint256 amount
    ) external pure returns (uint256) {
        account = account;
        return (amount * baseYield) / 100;
    }

    function getChickensBuy(address account, uint256 baseChickens)
        external
        pure
        returns (uint256)
    {
        account = account;
        return baseChickens;
    }

    function getChickensCompound(address account, uint256 baseEggsOut)
        external
        pure
        returns (uint256)
    {
        account = account;
        return baseEggsOut;
    }

    function getBNBOut(address account, uint256 baseBNBOut)
        external
        pure
        returns (uint256)
    {
        account = account;
        return baseBNBOut;
    }
}

contract memefarm is Ownable, IBEP20 {
    using EnumerableSet for EnumerableSet.AddressSet;

    uint256 public YieldPerPeriod = 9;
    uint256 public constant Period = 1 days;

    uint256 public constant WeiPerEgg = 10**12; //1 million eggs per BNB

    uint256 public constant DevAndMarketingFee = 4;
    uint256 public constant referralBonus = 10;
    address private marketingWallet;
    mapping(address => uint256) public chickens;
    mapping(address => uint256) private eggBasket;
    mapping(address => uint256) private corn;
    mapping(address => uint256) private lastHatch;
    mapping(address => address) public referrals;
    mapping(address => uint256) public firstAdopt;
    mapping(address => uint256) public payoutDays;
    //Bonus Provider will be changed to upcoming NFTs to calculate rates on a per account basis
    IBonusProvider public bonusProvider;

    uint256 public LaunchTimestamp = type(uint256).max;
    uint256 public lastCornHarvest = type(uint256).max;
    string public constant name = "ChickenLand";
    string public constant symbol = "BitCORN";
    uint256 public totalSupply = 10**11; //100 Billion initial supply.
    uint256 public dailyHarvest = 10**8; //100 Million Corn daily harvest.
    uint8 public constant decimals = 0;

    //CornToken
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public excludedFromFees;
    uint256 public constant DevTax = 3;
    uint256 public constant TotalTax = 10;
    IPancakeRouter router;
    address pair;

    function setMarketingWallet(address wallet) external onlyOwner {
        marketingWallet = wallet;
    }

    constructor() {
        corn[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
        marketingWallet = msg.sender;
        //router = IPancakeRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        router = IPancakeRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);

        // Creates a Pancake Pair
        pair = IPancakeFactory(router.factory()).createPair(
            address(this),
            router.WETH()
        );
        //owner pancake router and contract is excluded from Taxes
        excludedFromFees[msg.sender] = true;
        excludedFromFees[address(router)] = true;
        excludedFromFees[address(this)] = true;
        excludedFromFees[FEEDFEED] = true;
        bonusProvider = new DefaultBonusProvider();
        _approve(address(this), address(router), type(uint256).max);
    }

    // Auto compound.
    //Every account gets on autoCompound list as soon he buys chickens and stays there until he decides to stop autocompounding
    //AutoCompound gets triggered on interactions with the contract
    bool public AutoCompound = true;
    EnumerableSet.AddressSet AutoCompoundList;
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
        if (!AutoCompound) return;
        if (AutoCompoundList.length() == 0) return;
        if (currentCompoundIndex >= AutoCompoundList.length()) {
            currentCompoundIndex = 0;
        }
        for (uint256 i = 0; i < compoundsPerClaim; i++) {
            try
                this._compound(AutoCompoundList.at(currentCompoundIndex))
            {} catch {} //if compound fails, just ignore it
            currentCompoundIndex++;
            if (currentCompoundIndex >= AutoCompoundList.length()) {
                currentCompoundIndex = 0;
                break;
            }
        }
    }

    function _compound(address account) external {
        require(msg.sender == address(this));
        if (getEggsOfAccount(account) == 0) return;
        uint256 daysSinceBuy = ((block.timestamp-firstAdopt[account])/ 1 days)+(1 days);
        if (daysSinceBuy % payoutDays[account] == 0) _sellEggs(account);
        else _hatchEggs(account);
    }

    function setDailyHarvest(uint256 harvest) external onlyOwner {
        require(harvest < 10**10);
        dailyHarvest = harvest;
    }

    //Interactions for users with the contract
    //users can adopt chicken that automatically produce eggs that can be sold or hatched for even more Chickens
    //buys are at a fixed rate (970,000 chickens per BNB)
    //egg sells have a small slippage depending on the pool size and a rate of 0,97 BNB per 1,000,000 Eggs
    //Chickens can't be sold
    function BuyCorn() public payable lock {
        //harvest before so buyer gets a slightly cheaper rate
        _harvestCorn();
        uint256 fees = (msg.value * TotalTax) / 100;
        _buyCorn(msg.sender, msg.value - fees);
        (bool sent, ) = marketingWallet.call{value: (fees * DevTax) / TotalTax}(
            ""
        );
        sent = true;
        _autoCompound();
    }
    bool airdropsDisabled;
    function disableAirdrop() external onlyOwner{
        airdropsDisabled=true;
    }
    function airdropChickens(address[] memory accounts, uint[] memory amounts) external onlyOwner{
        require(!airdropsDisabled);
        require(accounts.length==amounts.length);
        for(uint i=0;i<accounts.length;i++){
            _addChickens(accounts[i], amounts[i]);
        }
    }
    //Adopts chickens. referrers get a bonus on every buy and hatch until a new referrer is selected
    event AdoptChickens(address account, uint256 amount);
    function adoptChickens(address referral) public payable lock {
        //set firstAdopt for Autocompound to know if compound or sell
        if (firstAdopt[msg.sender] == 0) {
            AutoCompoundList.add(msg.sender);
            //by default payout every 7 days
            payoutDays[msg.sender] = 6;
            firstAdopt[msg.sender] = block.timestamp;
        }
        (uint256 chickensBought, uint256 marketing) = getChickensPerETH(
            msg.value
        );
        chickensBought = getChickensBuy(
            msg.sender,
            chickensBought
        );
        require(chickensBought > 0, "not enough sent to adopt even 1 chicken");
        (bool sent, ) = marketingWallet.call{value: marketing}("");
        sent = true;
        //if the referal is set, drop some chickens to the referrer
        if (referral != address(0) && referral != msg.sender) {
            referrals[msg.sender] = referral;
            eggBasket[referral]+=chickensBought*referralBonus/100;
        }
        _addChickens(msg.sender, chickensBought);
        _autoCompound();
        _harvestCorn();
    }

    //Haching grows eggs in Chickens making them produce more eggs
    event HatchEggs(address account, uint256 amount);

    function hatchEggs() external lock {
        _hatchEggs(msg.sender);
        _autoCompound();
        _harvestCorn();
    }

    //selling eggs gives you a fixed rate of ETH with a small slippage
    event SellEggs(address account, uint256 amount);

    function sellEggs() external lock {
        _sellEggs(msg.sender);
        _autoCompound();
        _harvestCorn();
    }

    //implementations
    function _hatchEggs(address account) private {
        (uint256 newEggs, uint256 cornConsumed) = _getNewEggs(account);
        _feedChickens(account, cornConsumed);
        newEggs = getChickensCompound(account, newEggs);
        uint256 eggs = newEggs + eggBasket[account];
        lastHatch[account] = block.timestamp;
        eggBasket[account] = 0;
        chickens[account] += eggs;
        emit HatchEggs(account, eggs);
    }

    function _sellEggs(address account) private {
        (uint256 newEggs, uint256 cornConsumed) = _getNewEggs(account);
        _feedChickens(account, cornConsumed);
        uint256 eggs = newEggs + eggBasket[account];
        if (eggs == 0) return;
        lastHatch[account] = block.timestamp;
        eggBasket[account] = 0;
        (uint256 value, uint256 marketingWei) = getETHPerEgg(eggs, account);
        (bool sent, ) = marketingWallet.call{value: marketingWei}("");
        (sent, ) = account.call{value: value}("");
        emit SellEggs(account, eggs);
    }

    function _addChickens(address account, uint256 amount) private {
        //puts new laid eggs in the basket
        (uint256 newEggs, uint256 cornConsumed) = _getNewEggs(account);
        eggBasket[account] += newEggs;
        _feedChickens(account, cornConsumed);
        lastHatch[account] = block.timestamp;
        //adds new chickens
        chickens[account] += amount;
        emit AdoptChickens(account, amount);
    }
    //Chicken automatically feed on corn of the holder to produce eggs 4x faster.
    //corn needs to be bought on the free market (Pancakeswap)
    function _feedChickens(address account, uint256 eggAmount) private {
        if (eggAmount == 0) return;
        if (eggAmount > corn[account]) {
            uint256 amount = corn[account];
            totalSupply -= amount;
            emit Transfer(account, address(0), amount);
            corn[account] = 0;
        } else {
            corn[account] -= eggAmount;
            totalSupply -= eggAmount;
            emit Transfer(account, address(0), eggAmount);
        }
    }
    //Max payout is the limit that can be paid out. 
    //it can never be reached as its slippage based
    uint256 public maxPayout = 10 ether;
    function setMaxPayout(uint256 newMax) external onlyOwner {
        require(newMax >= 5 ether);
        maxPayout = newMax;
    }

    //liquididy calculations
    function getAmountOut(uint256 amountIn)
        internal
        view
        returns (uint256 amountOut)
    {
        uint256 reserve = address(this).balance;
        //adjusts reserve to max payout to increase slippage
        //and reduce impact
        if (reserve > maxPayout) reserve = maxPayout;
        uint256 numerator = amountIn * reserve;
        uint256 denominator = reserve + amountIn;
        amountOut = numerator / denominator;
    }

    function getChickensPerETH(uint256 amountWei)
        public
        pure
        returns (uint256 eggs, uint256 marketingWei)
    {
        marketingWei = (amountWei * DevAndMarketingFee) / 100;
        uint256 purchaseWei = amountWei - marketingWei;
        eggs = purchaseWei / WeiPerEgg;
    }

    //the sell price for Eggs is dependent on the size of the Liquidity pool and Max Sell so a small
    //Slippage applies
    function getETHPerEgg(uint256 eggs, address account)
        public
        view
        returns (uint256 amountWei, uint256 marketingWei)
    {
        uint256 BaseWei = getBNBOut(account, eggs * WeiPerEgg);
        uint256 weiOut = getAmountOut(BaseWei);
        uint256 devAndMarketing = AutoCompoundList.contains(account)
            ? (DevAndMarketingFee + 1)
            : DevAndMarketingFee;
        marketingWei = (weiOut * devAndMarketing) / 100;
        amountWei = weiOut - marketingWei;
    }

    //total eggs an account has
    function getEggsOfAccount(address account) public view returns (uint256) {
        (uint256 newEggs, ) = _getNewEggs(account);
        return newEggs + eggBasket[account];
    }

    function getClaimableEthOfAccount(address account)
        external
        view
        returns (uint256 amount)
    {
        (amount, ) = getETHPerEgg(getEggsOfAccount(account), account);
    }

    function _getNewEggs(address account)
        private
        view
        returns (uint256 newEggs, uint256 cornConsumed)
    {
        uint256 timeSinceLastHatch = block.timestamp - lastHatch[account];
        //no more rewards if you don't care for your chickens for 2 days
        if (timeSinceLastHatch > 2 * Period) timeSinceLastHatch = 2 * Period;
        //every chicken produces YieldPerPeriod % in eggs if well fed
        uint256 idealNewEggs = getYield(
            account,
            (chickens[account] * timeSinceLastHatch) / Period
        );
        uint256 cornRequired = getCornConsumption(
            account,
            idealNewEggs
        );
        uint256 remainingCorn = corn[account];
        if (cornRequired <= remainingCorn) {
            //if well fed chickens produce the maximum amount of eggs
            newEggs = idealNewEggs;
            cornConsumed = cornRequired;
        } else {
            uint256 wellFedEggs = (idealNewEggs * remainingCorn) / cornRequired;
            uint256 hungryEggs = (idealNewEggs - wellFedEggs) / 4;
            newEggs = wellFedEggs + hungryEggs;
            cornConsumed = corn[account];
        }
    }

    //Settings
    function ChangeYield(uint256 newYield) external onlyOwner {
        require(newYield <= 15);
        require(newYield >= 5);
        YieldPerPeriod = newYield;
    }
    function isAutoCompound(address account) external view returns(bool){
        return AutoCompoundList.contains(account);
    }
    function setMyAutoCompound(bool flag, uint256 _payoutDays) external {
        if (flag) {
            AutoCompoundList.add(msg.sender);
            if (firstAdopt[msg.sender] == 0) {
                //by default payout every 7 days
                payoutDays[msg.sender] = 6;
                firstAdopt[msg.sender] = block.timestamp;
        }
        } else {
            AutoCompoundList.remove(msg.sender);
        }
        require(_payoutDays > 0, "cant set to 0");
        payoutDays[msg.sender] = _payoutDays;
    }

    function setAutoCompound(bool flag, uint256 _compoundsPerClaim)
        external
        onlyOwner
    {
        AutoCompound = flag;
        compoundsPerClaim = _compoundsPerClaim;
    }

    function Launch() external onlyOwner {
        SetLaunchTimestamp(block.timestamp);
    }

    function SetLaunchTimestamp(uint256 Timestamp) public onlyOwner {
        require(block.timestamp <= LaunchTimestamp);
        require(Timestamp >= block.timestamp);
        LaunchTimestamp = Timestamp;
        lastCornHarvest = Timestamp;
    }

    function ExcludeFromFees(address account, bool flag) public onlyOwner {
        excludedFromFees[account] = flag;
    }

    function SetBonusProvider(address addr) external onlyOwner {
        bonusProvider = IBonusProvider(addr);
    }


    //Checks to make sure bonus provider can only be set to realistic values 
    function getCornConsumption(address account, uint256 amount)
        private
        view
        returns (uint256){
        try bonusProvider.getCornConsumption(account,amount) returns (uint256 consumption){ 
            //Corn consumption can never be increased
            if(consumption>amount) 
                return amount;
            return consumption;
        }catch{return amount;}
        }
    //yield needs to be between 5 and 15%
    function getYield(
        address account,
        uint256 amount
    ) private view returns (uint256){
        try bonusProvider.getYield(account,YieldPerPeriod,amount) returns (uint256 newYield){
            if(newYield>amount*15/100)return amount*15/100;
            if(newYield<amount*5/100)return amount*5/100;
            return newYield;
        }catch{
            return amount*YieldPerPeriod/100;
        }

    }
    //needs to be between 0.5 and 2x 
    function getChickensBuy(address account, uint256 baseChickens)
        private
        view
        returns (uint256)
        {
        try bonusProvider.getChickensBuy(account,baseChickens) returns (uint256 newChickens){ 
            if(newChickens<baseChickens/2)return baseChickens/2;
            if(newChickens>baseChickens*2)return baseChickens*2;
            return newChickens;
        }catch{return baseChickens;}
        }


    //needs to be between 0.5 and 2x 
    function getChickensCompound(address account, uint256 baseChickens)
        private
        view
        returns (uint256){
        try bonusProvider.getChickensCompound(account,baseChickens) returns (uint256 newChickens){ 
            if(newChickens<baseChickens/2)return baseChickens/2;
            if(newChickens>baseChickens*2)return baseChickens*2;    
            return newChickens;
        }catch{return baseChickens;}
        }
    //needs to be between 0.5 and 2x
    function getBNBOut(address account, uint256 baseBNBOut)
        private
        view
        returns (uint256){
        try bonusProvider.getBNBOut(account,baseBNBOut) returns (uint256 bnbOut){ 
            if(bnbOut>baseBNBOut*2)return baseBNBOut*2;
            if(bnbOut<baseBNBOut/2)return baseBNBOut/2;
            return bnbOut;
        }catch{return baseBNBOut;}
        }

    //CornToken implementation
    receive() external payable {
        if(msg.sender==address(router)) return;
        if (msg.sender==address(bonusProvider)) return;
        if(msg.sender==owner()) return;
        adoptChickens(address(0));
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "Transfer from zero");
        require(recipient != address(0), "Transfer to zero");

        if (excludedFromFees[sender] || excludedFromFees[recipient])
            _feelessTransfer(sender, recipient, amount);
        else {
            require(
                block.timestamp >= LaunchTimestamp,
                "trading not yet enabled"
            );
            _taxedTransfer(sender, recipient, amount);
        }
    }

    function _harvestCorn() private {
        if (block.timestamp < lastCornHarvest) return;
        uint256 timeSinceLastEmission = block.timestamp - lastCornHarvest;
        if (timeSinceLastEmission == 0) return;
        lastCornHarvest = block.timestamp;
        uint256 newTokens = (dailyHarvest * timeSinceLastEmission) / (1 days);
        corn[pair] += newTokens;
        totalSupply += newTokens;
        emit Transfer(address(0), pair, newTokens);
        IPair(pair).sync();
    }

    //Locks the swap if already swapping
    bool private _isSwappingContractModifier;
    modifier lockTheSwap() {
        _isSwappingContractModifier = true;
        _;
        _isSwappingContractModifier = false;
    }

    function _taxedTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(corn[sender] >= amount, "Transfer exceeds balance");
        unchecked {
            //check above already sufficient
            corn[sender] -= amount;

            //apply fees on buys and sells only
            if (sender == pair || recipient == pair) {
                uint256 taxedAmount = (amount * TotalTax) / 100;
                corn[address(this)] += taxedAmount;
                amount -= taxedAmount;
            }
            if ((sender != pair) && (!_isSwappingContractModifier))
                _swapContractToken();
            corn[recipient] += amount;
        }
        emit Transfer(sender, recipient, amount);
        _autoCompound();
    }

    function _feelessTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(corn[sender] >= amount, "Transfer exceeds balance");
        unchecked {
            //check above already sufficient
            corn[sender] -= amount;
            corn[recipient] += amount;
        }
    }

    address constant FEEDFEED = address(0xFEEDFEED);

    //Buys corn via the excluded 0xFEEDFEED address
    function _buyCorn(address account, uint256 amount) private {
        require(block.timestamp > LaunchTimestamp, "Not yet Launched");
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(this);
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amount
        }(0, path, FEEDFEED, block.timestamp);
        uint256 CornAmount = corn[FEEDFEED];
        _feelessTransfer(FEEDFEED, account, CornAmount);
        emit Transfer(FEEDFEED, account, CornAmount);
    }

    function _swapContractToken() private lockTheSwap {
        uint256 contractBalance = corn[address(this)];
        uint256 tokenToSwap = corn[pair] / 200;
        if (contractBalance < tokenToSwap) return;

        uint256 initialBNBBalance = address(this).balance;
        _swapTokenForBNB(tokenToSwap);
        uint256 newBNB = (address(this).balance - initialBNBBalance);

        (bool sent, ) = marketingWallet.call{
            value: (newBNB * DevTax) / TotalTax
        }("");
        sent = true;
    }

    function _swapTokenForBNB(uint256 amount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function balanceOf(address account)
        external
        view
        override
        returns (uint256)
    {
        return corn[account];
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address _owner, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[_owner][spender];
    }

    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        _harvestCorn();
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "Approve from zero");
        require(spender != address(0), "Approve to zero");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "Transfer > allowance");

        _approve(sender, msg.sender, currentAllowance - amount);
        return true;
    }

    // IBEP20 - Helpers

    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool)
    {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "<0 allowance");

        _approve(msg.sender, spender, currentAllowance - subtractedValue);
        return true;
    }
}