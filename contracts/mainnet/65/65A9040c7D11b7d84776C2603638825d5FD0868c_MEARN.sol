/**
 *Submitted for verification at BscScan.com on 2022-07-09
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-22
*/

// File: Libraries.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

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

interface IPancakeFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IDEXRouter {
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

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library EnumerableSet {
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
}

// File: Metaearn.sol

pragma solidity ^0.8.4;

////////////////////////////////////////////////////////////////////////////////////////////////////////
//MEARN Contract /////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
contract MEARN is IBEP20, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _excluded;
    mapping(address => bool) private _excludedFromStaking;
    mapping(address => bool) private _automatedMarketMakers;

    //Token Info
    string private constant _name = "MetaEarn";
    string private constant _symbol = "MEARN";
    uint8 private constant _decimals = 9;
    uint256 public constant InitialSupply = 10**9 * 10**_decimals/2; //equals 500,000,000 token

    //variables that track balanceLimit and sellLimit,
    //can be updated based on circulating supply and Sell- and BalanceLimitDividers
    uint256 private _circulatingSupply;

    //Limits max tax, only gets applied for tax changes, doesn't affect inital Tax
    uint256 public constant MaxTax = 250;
    //Tracks the current Taxes, different Taxes can be applied for buy/sell/transfer
    //Taxes can never exceed MaxTax
    uint256 private _buyTax = 110;
    uint256 private _sellTax = 150;
    uint256 private _transferTax = 0;
    //The shares of the specific Taxes, always needs to equal 100%
    uint256 private _liquidityTax = 100;
    uint256 private _stakingTax = 400;
    uint256 private _buybackTax = 400;
    uint256 private _marketingTax = 100;
    uint256 private constant TaxDenominator = 1000;
    //determines the permille of the pancake pair needed to trigger Liquify
    uint8 public LiquifyTreshold = 2;
    uint256 public LaunchTimestamp = type(uint256).max;
    //_pancakePairAddress is also equal to the liquidity token address
    //LP token are locked in the contract
    address private _pancakePairAddress;
    IDEXRouter private _pancakeRouter;
    address public buyback;
    //TestNet
    //address private constant PancakeRouter =
    //  0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    //IBEP20 public RewardsToken =
    //    IBEP20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
    //MainNet
    address private constant PancakeRouter =
        0x10ED43C718714eb63d5aA57B78B54704E256024E;
    IBEP20 public RewardsToken =
        IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    address public MarketingWallet;
    //modifier for functions only the team can call
    modifier onlyTeam() {
        require(_isTeam(msg.sender), "Caller not in Team");
        _;
    }
    bool _isInFunction;
    modifier isInFunction() {
        require(!_isInFunction);
        _isInFunction = true;
        _;
        _isInFunction = false;
    }

    function _isTeam(address addr) private view returns (bool) {
        return addr == owner() || addr == MarketingWallet;
    }

    constructor() {
        //Creates a Pancake Pair
        _pancakeRouter = IDEXRouter(PancakeRouter);
        _pancakePairAddress = IPancakeFactory(_pancakeRouter.factory())
            .createPair(address(this), _pancakeRouter.WETH());
        buyback = msg.sender;
        _excluded[address(buyback)] = true;
        _excluded[address(0xdead)] = true;
        _automatedMarketMakers[_pancakePairAddress] = true;
        //excludes Pancake Pair and contract from staking
        _excludedFromStaking[_pancakePairAddress] = true;
        _excludedFromStaking[address(this)] = true;
        _excludedFromStaking[address(0xdead)] = true;
        //deployer gets 100% of the supply to create LP
        _addToken(msg.sender, InitialSupply);
        emit Transfer(address(0), msg.sender, InitialSupply);
        //Team wallet deployer and contract are excluded from Taxes
        //contract can't be included to taxes
        MarketingWallet = msg.sender;
        _excluded[MarketingWallet] = true;
        _excluded[msg.sender] = true;
        _excluded[address(this)] = true;
        _approve(address(this), address(_pancakeRouter), type(uint256).max);
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Transfer functionality////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////

    //picks the transfer function
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "from zero");
        require(recipient != address(0), "to zero");

        //excluded adresses are transfering tax and lock free
        if (_excluded[sender] || _excluded[recipient]) {
            _feelessTransfer(sender, recipient, amount);
            return;
        }
        //once trading is enabled, it can't be turned off again
        require(block.timestamp >= LaunchTimestamp, "trading not yet enabled");
        _regularTransfer(sender, recipient, amount);
    }

    //applies taxes, checks for limits, locks generates autoLP and stakingBNB, and autostakes
    function _regularTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(_balances[sender] >= amount, "exceeds balance");
        //checks all registered AMM if it's a buy or sell.
        bool isBuy = _automatedMarketMakers[sender];
        bool isSell = _automatedMarketMakers[recipient];
        uint256 tax;
        if (isSell) {
            tax = _sellTax;
        } else if (isBuy) {
            tax = _buyTax;
        } else {
            tax = _transferTax;
        }
        //Swapping AutoLP and MarketingBNB is only possible if sender is not pancake pair,
        //if its not manually disabled, if its not already swapping
        if (
            (sender != _pancakePairAddress) &&
            (!swapAndLiquifyDisabled) &&
            (!_isSwappingContractModifier)
        ) {
            _swapContractToken(LiquifyTreshold, false);
        }
        _transferTaxed(sender, recipient, amount, tax);
    }

    function _transferTaxed(
        address sender,
        address recipient,
        uint256 amount,
        uint256 tax
    ) private {
        uint256 totalTaxedToken = _calculateFee(amount, tax, TaxDenominator);
        uint256 taxedAmount = amount - totalTaxedToken;
        //Removes token and handles staking
        _removeToken(sender, amount);
        //Adds the taxed tokens -burnedToken to the contract
        _addToken(address(this), totalTaxedToken);
        //Adds token and handles staking
        _addToken(recipient, taxedAmount);
        emit Transfer(sender, recipient, taxedAmount);
        if (!autoPayoutDisabled) _autoPayout();
    }

    //Feeless transfer only transfers and autostakes
    function _feelessTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(_balances[sender] >= amount, ">balance");
        //Removes token and handles staking
        _removeToken(sender, amount);
        //Adds token and handles staking
        _addToken(recipient, amount);

        emit Transfer(sender, recipient, amount);
    }

    //Calculates the token that should be taxed
    function _calculateFee(
        uint256 amount,
        uint256 tax,
        uint256 taxPercent
    ) private pure returns (uint256) {
        return (amount * tax * taxPercent) / (TaxDenominator * TaxDenominator);
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //BNB Autostake/////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Autostake uses the balances of each holder to redistribute auto generated BNB.
    //Each transaction _addToken and _removeToken gets called for the transaction amount
    EnumerableSet.AddressSet private _autoPayoutList;

    function isAutoPayout(address account) public view returns (bool) {
        return _autoPayoutList.contains(account);
    }

    function setMyAutoPayout(bool flag) external {
        if (flag) _autoPayoutList.add(msg.sender);
        else _autoPayoutList.remove(msg.sender);
    }

    uint256 AutoPayoutCount = 5;
    uint256 currentPayoutIndex;

    bool public autoPayoutDisabled;

    event OnDisableAutoPayout(bool disabled);

    function DisableAutoPayout(bool disabled) external onlyTeam {
        autoPayoutDisabled = disabled;
        emit OnDisableAutoPayout(disabled);
    }

    event OnChangeAutoPayoutCount(uint256 count);
    uint256 constant MAX_PAYOUTS = 10;


    function ChangeAutoPayoutCount(uint256 count) external onlyTeam {
        require(count <= MAX_PAYOUTS);
        AutoPayoutCount = count;
        emit OnChangeAutoPayoutCount(count);
    }
    event OnChangeAutoPayoutAccount(address account, bool enable);
    function SetAutoPayoutAccount(address account, bool enable)
        external
        onlyTeam
    {
        require(!_excludedFromStaking[account]);
        if (enable) _autoPayoutList.add(account);
        else _autoPayoutList.remove(account);
        emit OnChangeAutoPayoutAccount(account, enable);
    }
    event OnSetRewardsToken(address token);
    function setRewardsToken(address newToken) external onlyTeam {
        RewardsToken = IBEP20(newToken);
        emit OnSetRewardsToken(newToken);
    }
        event OnSetBuybackAddress(address buyback);

    function setBuybackAddress(address newAddress) external onlyTeam{
        buyback=newAddress;
        emit OnSetRewardsToken(newAddress);
    }

    function _autoPayout() private isInFunction {
        //resets payout counter and moves to next payout token if last holder is reached
        if (currentPayoutIndex >= _autoPayoutList.length())
            currentPayoutIndex = 0;

        uint256 currentTotalPayout;
        uint256[MAX_PAYOUTS] memory payouts;
        for (uint256 i = 0; i < AutoPayoutCount; i++) {
            uint256 currentIndex = currentPayoutIndex + i;
            if (currentIndex >= _autoPayoutList.length()) break;
            address current = _autoPayoutList.at(currentIndex);
            uint256 payout = getDividents(current);
            currentTotalPayout += payout;
            payouts[i] = payout;
        }

        if (currentTotalPayout == 0) return;
        uint256 tokens = swapForToken(currentTotalPayout);

        for (uint256 i = 0; i < AutoPayoutCount; i++) {
            address current = _autoPayoutList.at(currentPayoutIndex);
            currentPayoutIndex++;
            uint256 payoutShare = (payouts[i] * tokens) / currentTotalPayout;
            if (payoutShare > 0) {
                try RewardsToken.transfer(current, payoutShare) {
                    alreadyPaidShares[current] =
                        profitPerShare *
                        getShares(current);
                    toBePaid[current] = 0;
                } catch {}
            }

            if (currentPayoutIndex >= _autoPayoutList.length()) {
                currentPayoutIndex = 0;
                return;
            }
        }
    }

    function swapForToken(uint256 amount) private returns (uint256 newAmount) {
        address[] memory path = new address[](2);
        path[0] = _pancakeRouter.WETH(); //BNB
        path[1] = address(RewardsToken);

        //purchases token and sends them to the target address
        _pancakeRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amount
        }(0, path, address(this), block.timestamp);
        newAmount = RewardsToken.balanceOf(address(this));
    }

    function swapForAnyToken(uint256 amount, address _token, address recipient)
        private
    {
        address[] memory path = new address[](2);
        path[0] = _pancakeRouter.WETH(); //BNB
        path[1] = address(_token);
        //purchases token and sends them to the target address
        _pancakeRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amount
        }(0, path, recipient, block.timestamp);
    }

    function claim() external isInFunction {
        uint256 dividents = getDividents(msg.sender);
        require(dividents > 0, "Nothing to claim");
        toBePaid[msg.sender] = 0;
        alreadyPaidShares[msg.sender] = profitPerShare * getShares(msg.sender);
        RewardsToken.transfer(msg.sender, swapForToken(dividents));
    }

    function claimAnyToken(address token) external isInFunction {
        uint256 dividents = getDividents(msg.sender);
        require(dividents > 0, "Nothing to claim");
        toBePaid[msg.sender] = 0;
        alreadyPaidShares[msg.sender] = profitPerShare * getShares(msg.sender);
        swapForAnyToken(dividents, token, msg.sender);
    }

    bool public defaultAutoPayout = false;
    event OnSetDefaultAutoPayout(bool flag);

    function setDefaultAutoPayout(bool flag) external onlyOwner {
        defaultAutoPayout = flag;
    }

    //Multiplier to add some accuracy to profitPerShare
    uint256 private constant DistributionMultiplier = 2**64;
    //profit for each share a holder holds, a share equals a decimal.
    uint256 public profitPerShare;
    //totalShares in circulation +InitialSupply to avoid underflow
    //getTotalShares returns the correct amount
    uint256 private _totalShares = InitialSupply;
    //the total reward distributed through staking, for tracking purposes
    uint256 public totalStakingReward;
    //the total payout through staking, for tracking purposes
    uint256 public totalPayouts;
    //Mapping of the already paid out(or missed) shares of each staker
    mapping(address => uint256) private alreadyPaidShares;
    //Mapping of shares that are reserved for payout
    mapping(address => uint256) private toBePaid;
    mapping(address => uint256) public totalPayout;

    //adds Token to balances, adds new BNB to the toBePaid mapping and resets staking
    function _addToken(address addr, uint256 amount) private {
        //the amount of token after transfer
        uint256 newAmount = _balances[addr] + amount;
        _circulatingSupply += amount;
        //if excluded, don't change staking amount
        if (_excludedFromStaking[addr]) {
            _balances[addr] = newAmount;
            return;
        }
        _totalShares += amount;
        //gets the payout before the change
        uint256 payment = _newDividentsOf(addr);
        //resets dividents to 0 for newAmount
        alreadyPaidShares[addr] = profitPerShare * newAmount;
        //adds dividents to the toBePaid mapping
        toBePaid[addr] += payment;
        //sets newBalance
        _balances[addr] = newAmount;
        if (defaultAutoPayout) _autoPayoutList.add(addr);
    }

    //removes Token, adds BNB to the toBePaid mapping and resets staking
    function _removeToken(address addr, uint256 amount) private {
        //the amount of token after transfer
        uint256 newAmount = _balances[addr] - amount;
        _circulatingSupply -= amount;
        if (_excludedFromStaking[addr]) {
            _balances[addr] = newAmount;
            return;
        }

        //gets the payout before the change
        uint256 payment = _newDividentsOf(addr);
        //sets newBalance
        _balances[addr] = newAmount;
        //resets dividents to 0 for newAmount
        alreadyPaidShares[addr] = profitPerShare * getShares(addr);
        //adds dividents to the toBePaid mapping
        toBePaid[addr] += payment;
        _totalShares -= amount;
        if (newAmount == 0) _autoPayoutList.remove(addr);
    }

    //gets the dividents of a staker that aren't in the toBePaid mapping
    function _newDividentsOf(address staker) private view returns (uint256) {
        uint256 fullPayout = profitPerShare * getShares(staker);
        //if excluded from staking or some error return 0
        if (fullPayout <= alreadyPaidShares[staker]) return 0;
        return
            (fullPayout - alreadyPaidShares[staker]) / DistributionMultiplier;
    }

    //distributes bnb between marketing share and dividents
    function _distributeStake(uint256 AmountWei) private {
        if (AmountWei == 0) return;
        uint256 totalShares = getTotalShares();
        //when there are 0 shares, add everything to marketing budget
        if (totalShares == 0) {
            (bool sent, ) = MarketingWallet.call{value: AmountWei}("");
            sent = true;
        } else {
            totalStakingReward += AmountWei;
            //Increases profit per share based on current total shares
            profitPerShare += ((AmountWei * DistributionMultiplier) /
                totalShares);
        }
    }

    function AddFunds() external payable isInFunction {
        _distributeStake(msg.value);
    }

    function AddFundsTo(address Account) external payable isInFunction {
        toBePaid[Account] += msg.value;
        totalStakingReward += msg.value;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Swap Contract Tokens//////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////

    //tracks auto generated BNB, useful for ticker etc
    uint256 public totalLPBNB;
    //Locks the swap if already swapping
    bool private _isSwappingContractModifier;
    modifier lockTheSwap() {
        _isSwappingContractModifier = true;
        _;
        _isSwappingContractModifier = false;
    }
    uint256 public overLiquifyTreshold = 100;

    function isOverLiquified() public view returns (bool) {
        return
            _balances[_pancakePairAddress] >
            (_circulatingSupply * overLiquifyTreshold) / TaxDenominator;
    }

    function _swapContractToken(uint16 PancakeTreshold, bool ignoreLimits)
        private
        lockTheSwap
    {
        uint256 contractBalance = _balances[address(this)];

        uint256 tokenToSwap = (_balances[_pancakePairAddress] *
            PancakeTreshold) / TaxDenominator;

        //only swap if contractBalance is larger than tokenToSwap or ignore limits
        bool NotEnoughToken = contractBalance < tokenToSwap;
        if (NotEnoughToken) {
            if (ignoreLimits) tokenToSwap = contractBalance;
            else return;
        }
        uint256 tokenForLiquidity;
        //if over Liquified, then use 100% of the token for LP
        if (isOverLiquified()) tokenForLiquidity = 0;
        else tokenForLiquidity = (tokenToSwap * _liquidityTax) / TaxDenominator;

        uint256 tokenForBNB = tokenToSwap - tokenForLiquidity;

        //splits tokenForLiquidity in 2 halves
        uint256 liqToken = tokenForLiquidity / 2;
        uint256 liqBNBToken = tokenForLiquidity - liqToken;

        //swaps marktetingToken and the liquidity token half for BNB
        uint256 swapToken = liqBNBToken + tokenForBNB;
        //Gets the initial BNB balance, so swap won't touch any staked BNB
        uint256 initialBNBBalance = address(this).balance;
        _swapTokenForBNB(swapToken);
        uint256 newBNB = (address(this).balance - initialBNBBalance);
        //calculates the amount of BNB belonging to the LP-Pair and converts them to LP
        uint256 liqBNB = (newBNB * liqBNBToken) / swapToken;
        if (liqBNB > 0) _addLiquidity(liqToken, liqBNB);
        //Get the BNB balance after LP generation to get the
        //exact amount of token left for Staking, as LP generation leaves some BNB untouched
        uint256 distributeBNB = (address(this).balance - initialBNBBalance);
        uint256 totalBNBTax = TaxDenominator - _liquidityTax;
        uint256 marketingBNB = (distributeBNB * _marketingTax) / totalBNBTax;
        uint256 buybackBNB = (distributeBNB * _buybackTax) / totalBNBTax;
        uint256 stakingBNB = distributeBNB -marketingBNB - buybackBNB;

        //distributes BNB between stakers
        _distributeStake(stakingBNB);
        (bool sent, ) = MarketingWallet.call{value: marketingBNB}("");
        (sent, ) = address(buyback).call{value: buybackBNB}("");
    }

    //swaps tokens on the contract for BNB
    function _swapTokenForBNB(uint256 amount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _pancakeRouter.WETH();

        _pancakeRouter.swapExactTokensForETH(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    //Adds Liquidity directly to the contract where LP are locked(unlike safemoon forks, that transfer it to the owner)
    function _addLiquidity(uint256 tokenamount, uint256 bnbamount) private {
        totalLPBNB += bnbamount;
        try
            _pancakeRouter.addLiquidityETH{value: bnbamount}(
                address(this),
                tokenamount,
                0,
                0,
                owner(),
                block.timestamp
            )
        {} catch {}
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //public functions /////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //gets shares of an address, returns 0 if excluded
    function getShares(address addr) public view returns (uint256) {
        if (_excludedFromStaking[addr]) return 0;
        return _balances[addr];
    }

    //Total shares equals circulating supply minus excluded Balances
    function getTotalShares() public view returns (uint256) {
        return _totalShares - InitialSupply;
    }

    function getTaxes()
        public
        view
        returns (
            uint256 buyTax,
            uint256 sellTax,
            uint256 transferTax,
            uint256 liquidityTax,
            uint256 stakingTax,
            uint256 marketingTax,
            uint256 buybackTax
        )
    {
        buyTax = _buyTax;
        sellTax = _sellTax;
        transferTax = _transferTax;
        liquidityTax = _liquidityTax;
        stakingTax = _stakingTax;
        marketingTax = _marketingTax;
        buybackTax = _buybackTax;
    }

    function getStatus(address account)
        external
        view
        returns (bool Excluded, bool ExcludedFromStaking)
    {
        return (_excluded[account], _excludedFromStaking[account]);
    }

    //Returns the not paid out dividents of an address in wei
    function getDividents(address addr) public view returns (uint256) {
        return _newDividentsOf(addr) + toBePaid[addr];
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Settings//////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////

    bool public swapAndLiquifyDisabled;
    event OnAddAMM(address AMM, bool Add);

    function AddOrRemoveAMM(address AMMPairAddress, bool Add) external onlyTeam {
        require(AMMPairAddress != _pancakePairAddress, "can't change Pancake");
        if (Add) {
            if (!_excludedFromStaking[AMMPairAddress])
                SetStakingExcluded(AMMPairAddress, true);
            _automatedMarketMakers[AMMPairAddress] = true;
        } else {
            _automatedMarketMakers[AMMPairAddress] = false;
        }
        emit OnAddAMM(AMMPairAddress, Add);
    }
    event OnChangeMarketingWallet(address newWallet);
    function ChangeMarketingWallet(address newMarketingWallet) external onlyTeam{
        MarketingWallet = newMarketingWallet;
        emit OnChangeMarketingWallet(newMarketingWallet);
    }

    event OnChangeLiquifyTreshold(uint8 TresholdPermille);

    function SetLiquifyTreshold(uint8 TresholdPermille) external onlyTeam {
        require(TresholdPermille <= 50);
        require(TresholdPermille > 0);
        LiquifyTreshold = TresholdPermille;
        emit OnChangeLiquifyTreshold(TresholdPermille);
    }

    event OnChangeOverLiquifyTreshold(uint8 TresholdPermille);

    function SetOverLiquifyTreshold(uint8 TresholdPermille) external onlyTeam {
        require(TresholdPermille <= TaxDenominator);
        overLiquifyTreshold = TresholdPermille;
        emit OnChangeOverLiquifyTreshold(TresholdPermille);
    }

    event OnSwitchSwapAndLiquify(bool Disabled);

    //switches autoLiquidity and marketing BNB generation during transfers
    function SwitchSwapAndLiquify(bool disabled) external onlyTeam {
        swapAndLiquifyDisabled = disabled;
        emit OnSwitchSwapAndLiquify(disabled);
    }

    event OnChangeTaxes(
        uint256 liquidityTaxes,
        uint256 stakingTaxes,
        uint256 marketingTaxes,
        uint256 buybackTax,
        uint256 buyTaxes,
        uint256 sellTaxes,
        uint256 transferTaxes
    );

    //Sets Taxes, is limited by MaxTax(25%)
    function SetTaxes(
        uint256 liquidityTaxes,
        uint256 stakingTaxes,
        uint256 marketingTax,
        uint256 buybackTax,
        uint256 buyTax,
        uint256 sellTax,
        uint256 transferTax
    ) external onlyTeam {
        uint256 totalTax = liquidityTaxes +
            stakingTaxes +
            marketingTax +
            buybackTax;
        require(totalTax == TaxDenominator);
        require(buyTax <= MaxTax && sellTax <= MaxTax && transferTax <= MaxTax);

        _marketingTax = marketingTax;
        _buybackTax = buybackTax;
        _liquidityTax = liquidityTaxes;
        _stakingTax = stakingTaxes;

        _buyTax = buyTax;
        _sellTax = sellTax;
        _transferTax = transferTax;
        emit OnChangeTaxes(
            liquidityTaxes,
            stakingTaxes,
            marketingTax,
            buybackTax,
            buyTax,
            sellTax,
            transferTax
        );
    }

    //manually converts contract token to LP and staking BNB
    function TriggerLiquify(uint16 pancakePermille, bool ignoreLimits)
        external
        onlyTeam
    {
        _swapContractToken(pancakePermille, ignoreLimits);
    }

    event OnExcludeFromStaking(address addr, bool exclude);

    //Excludes account from Staking
    function SetStakingExcluded(address addr, bool exclude)public onlyTeam {
        uint256 shares;
        if (exclude) {
            require(!_excludedFromStaking[addr]);
            uint256 newDividents = _newDividentsOf(addr);
            shares = getShares(addr);
            _excludedFromStaking[addr] = true;
            _totalShares -= shares;
            alreadyPaidShares[addr] = shares * profitPerShare;
            toBePaid[addr] += newDividents;
            _autoPayoutList.remove(addr);
        } else _includeToStaking(addr);
        emit OnExcludeFromStaking(addr, exclude);
    }

    //function to Include own account to staking, should it be excluded
    function IncludeMeToStaking() external {
        _includeToStaking(msg.sender);
    }

    function _includeToStaking(address addr) private {
        require(_excludedFromStaking[addr]);
        _excludedFromStaking[addr] = false;
        uint256 shares = getShares(addr);
        _totalShares += shares;
        //sets alreadyPaidShares to the current amount
        alreadyPaidShares[addr] = shares * profitPerShare;
        if (defaultAutoPayout) _autoPayoutList.add(addr);
    }

    event OnExclude(address addr, bool exclude);

    //Exclude/Include account from fees and locks (eg. CEX)
    function SetExcludedStatus(address account, bool excluded)external onlyTeam {
        require(
            account != address(this) &&
                account != address(buyback) &&
                account != address(0xdead),
            "can't Include"
        );
        _excluded[account] = excluded;
        emit OnExclude(account, excluded);
    }

    event ContractBurn(uint256 amount);

    //Burns token on the contract, like when there is a very large backlog of token
    //or for scheudled BurnEvents
    function BurnContractToken(uint8 percent) external onlyTeam {
        require(percent <= 100);
        uint256 burnAmount = (_balances[address(this)] * percent) / 100;
        _removeToken(address(this), burnAmount);
        emit Transfer(address(this), address(0), burnAmount);
        emit ContractBurn(burnAmount);
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Setup Functions///////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////

    event OnSetLaunchTimestamp(uint256 timestamp);

    function Launch() external {
        SetupLaunchTimestamp(block.timestamp);
    }

    function SetupLaunchTimestamp(uint256 timestamp) public onlyTeam {
        require(block.timestamp < LaunchTimestamp);

        LaunchTimestamp = timestamp;
        emit OnSetLaunchTimestamp(timestamp);
    }

    //Allows the team to withdraw token that get's accidentally sent to the contract(happens way too often)
    function WithdrawStrandedToken(address strandedToken) external onlyTeam {
        require(
            (strandedToken != _pancakePairAddress) &&
                strandedToken != address(this)
        );
        IBEP20 token = IBEP20(strandedToken);
        token.transfer(MarketingWallet, token.balanceOf(address(this)));
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //external//////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////

    receive() external payable {
        //only allow pancakeRouter to send BNB
        require(msg.sender == address(PancakeRouter));
    }

    // IBEP20

    function getOwner() external view override returns (address) {
        return owner();
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

    function totalSupply() external view override returns (uint256) {
        return _circulatingSupply;
    }

    function balanceOf(address account)
        external
        view
        override
        returns (uint256)
    {
        return _balances[account];
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
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0));
        require(spender != address(0));

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
        require(currentAllowance >= amount);

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
        require(currentAllowance >= subtractedValue);

        _approve(msg.sender, spender, currentAllowance - subtractedValue);
        return true;
    }
}