/**
 *Submitted for verification at BscScan.com on 2022-09-05
*/

/**
 * SPDX-License-Identifier: MIT
 */
pragma solidity ^0.8.6;



  library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }


    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }


    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }


    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {return msg.sender;}
    function _msgData() internal view virtual returns (bytes calldata) {this; return msg.data;}
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size; assembly { size := extcodesize(account) } return size > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");(bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");

    }
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);

    }
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");

    }
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) { return returndata; } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {revert(errorMessage);}
        }
    }
}

abstract contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

interface IPancakeV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IPancakeV2Router {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

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


abstract contract DepreciatingFees {
    using SafeMath for uint256;

    struct FeeStruct {
        uint256 FleetRewardsFee;
        uint256 WarChestFee;
        uint256 MarketingChestFee;
        uint256 MutinyFee;
        uint256 amount;
        bool exist;
        uint256 lastUpdated;
        uint256 nextReductionTime;

    }

    mapping(address => FeeStruct) internal fees;
    address[] feeholders;
    mapping (address => uint256) feeholdersIndexes;

    event LogNewFeeHolder(address indexed _userAddress, uint256 _FleetRewardsFee, uint256 _WarChestFee,
    uint256 _MarketingChestFee, uint256 _MutinyFee, uint256 _amount);

    event LogUpdateFeeHolder(address indexed _userAddress, uint256 _FleetRewardsFee, uint256 _WarChestFee,
    uint256 _MarketingChestFee, uint256 _MutinyFee, uint256 _amount, uint256 _lastUpdated, uint256 _nextReductionTime);


    uint256 internal FleetRewardsReductionPerSec = 771; // 0.000000771 per second
    uint256 internal WarChestReductionPerSec = 4629; // 0.000004629 per second
    uint256 internal MarketingChestReductionPerSec = 771; // 0.000000771per second
    uint256 internal MutinyreductionPerSec = 5401; // 0.000005401 per second

    uint256 internal reductionDivisor = 10**9; // reduction multiplier
    uint256 internal updateFeeTime = 1; // every second
    uint256 internal FEES_DIVISOR = 10**11; // gives you the true percentage

    uint256 public FleetRewardsFee = 2;
    uint256 public WarChestFee = 12;
    uint256 public MarketingChestFee = 2;
    uint256 public MutinyFee = 14;

    uint256 internal FleetRewardsFee_ = FleetRewardsFee * reductionDivisor;
    uint256 internal WarChestFee_ = WarChestFee * reductionDivisor;
    uint256 internal MarketingChestFee_ = MarketingChestFee * reductionDivisor;
    uint256 internal MutinyFee_ = MutinyFee * reductionDivisor;

    uint256 internal baseTotalFees = WarChestFee_.add(FleetRewardsFee_).add(MarketingChestFee_);
    uint256 internal baseSellerTotalFees = baseTotalFees.add(MutinyFee_);


    function _getHolderFees (address _userAddress, bool feeReduction) internal view returns
    (uint256, uint256, uint256, uint256) {

        (uint256 _estimatedFleetRewardsFee, uint256 _estimatedWarChestFee, uint256 _estimatedMarketingChestFee,
            uint256 _estimatedMutinyFee,) = getLiquidFee(_userAddress);

        // if it's user's first time use the default fee else use the estimate
        uint256 getFleetRewardsFee = !feeReduction ? FleetRewardsFee_ : _estimatedFleetRewardsFee;
        uint256 getWarChestFee = !feeReduction ? WarChestFee_ : _estimatedWarChestFee;
        uint256 getMarketingChestFee = !feeReduction ? MarketingChestFee_ : _estimatedMarketingChestFee;

        uint256 getMutinyFee = !feeReduction ? MutinyFee_ :  _estimatedMutinyFee;

        return (
           getFleetRewardsFee,
           getWarChestFee,
           getMarketingChestFee,
           getMutinyFee
            );
    }


    function getLiquidFee (address _userAddress) public view returns(uint256 reduceFleetRewardsFee, uint256 reduceWarChestFee,
    uint256 reduceMarketingChestFee, uint256 reduceMutinyFee, uint256 _accruedTime) {

         // grab the fees that has accrued since last transaction
        uint256 accruedTime = block.timestamp - fees[_userAddress].lastUpdated;
        uint256 __FleetRewards = fees[_userAddress].FleetRewardsFee;
        uint256 __WarChestFee = fees[_userAddress].WarChestFee;
        uint256 __MarketingChestFee = fees[_userAddress].MarketingChestFee;
        uint256 __MutinyFee = fees[_userAddress].MutinyFee;

        return (
            __FleetRewards <= accruedTime.mul(FleetRewardsReductionPerSec) ? 0 : __FleetRewards.sub(accruedTime.mul(FleetRewardsReductionPerSec)),
            __WarChestFee <= accruedTime.mul(WarChestReductionPerSec) ? 0 : __WarChestFee.sub(accruedTime.mul(WarChestReductionPerSec)),
            __MarketingChestFee <= accruedTime.mul(MarketingChestReductionPerSec) ? 0 : __MarketingChestFee.sub(accruedTime.mul(MarketingChestReductionPerSec)),
            __MutinyFee <= accruedTime.mul(MutinyreductionPerSec) ? 0 : __MutinyFee.sub(accruedTime.mul(MutinyreductionPerSec)),
            accruedTime
            );
        }

    function calculateBuyingReadjustment(address _userAddress, uint256 _amount, uint256 _FleetRewardsFee, uint256 _WarChestFee,
    uint256 _MarketingChestFee, uint256 _MutinyFee) internal view returns (uint256, uint256, uint256, uint256) {

        uint256 currentBalance = fees[_userAddress].amount;
        uint256 __amount = _amount;

        (uint256 getFleetRewardsFee) = formula(_FleetRewardsFee, currentBalance, _amount, FleetRewardsFee_ );
        (uint256 getWarChestFee) = formula( _WarChestFee, currentBalance, _amount, WarChestFee_ );
        (uint256 getMarketingChestFee) = formula(_MarketingChestFee, currentBalance, __amount, MarketingChestFee_ );
        (uint256 getMutinyFee) = formula(_MutinyFee, currentBalance, __amount, MutinyFee_ );

        return (
            getFleetRewardsFee,
            getWarChestFee,
            getMarketingChestFee,
            getMutinyFee
            );

    }

    function formula(uint256 currentFee, uint256 currentBalance, uint256 tokensPurchased, uint256 feeMultiplier) private pure returns(uint256) {
        return  ((currentFee * currentBalance) + (feeMultiplier * tokensPurchased) )/ (currentBalance + tokensPurchased);
    }


    function reAdjustFees(address userAddress, uint256 _amount, uint256 _FleetRewardsFee, uint256 _WarChestFee,  uint256 _MarketingChestFee,
         uint256 _MutinyFee) internal {

        (uint256 _newFleetRewardsFee, uint256 _newWarChestFee, uint256 _newMarketingChestFee, uint256 _newMutinyFee) =
            calculateBuyingReadjustment (userAddress, _amount, _FleetRewardsFee, _WarChestFee, _MarketingChestFee, _MutinyFee);

        address _userAddress = userAddress;
        (uint256 __amount) = returnAmount(_amount);

        updateFeeHolder(
            _userAddress,
            _newFleetRewardsFee,
            _newWarChestFee,
            _newMarketingChestFee,
            _newMutinyFee,
            fees[_userAddress].amount.add(__amount)
            );
    }

    function updateAmountOnSell(uint256 _amount, address _userAddress) internal {
       uint256 subTractAmt = fees[_userAddress].amount >= _amount ? fees[_userAddress].amount.sub(_amount) : _amount;
       fees[_userAddress].amount = subTractAmt;
    }


    function returnAmount(uint256 _amount) private pure returns(uint256) {
        return _amount;
    }

    function setFeeHolder(address _userAddress, uint256 _amount) internal {
        addFeeHolder(
            _userAddress,
            FleetRewardsFee_,
            WarChestFee_,
            MarketingChestFee_,
            MutinyFee_,
            _amount
            );
    }

    function addFeeHolder(address _userAddress, uint256 _FleetRewardsFee, uint256 _WarChestFee, uint256 _MarketingChestFee, uint256 _MutinyFee,
    uint256 _amount) internal {
        require(!isFeeHolder(_userAddress), "Fee Holder already exist!");
        feeholdersIndexes[_userAddress] = feeholders.length;
        feeholders.push(_userAddress);

        fees[_userAddress].FleetRewardsFee = _FleetRewardsFee;
        fees[_userAddress].WarChestFee = _WarChestFee;
        fees[_userAddress].MarketingChestFee = _MarketingChestFee;
        fees[_userAddress].MutinyFee = _MutinyFee;
        fees[_userAddress].amount = _amount;
        fees[_userAddress].exist = true;
        fees[_userAddress].lastUpdated = block.timestamp;
        fees[_userAddress].nextReductionTime = block.timestamp + updateFeeTime;

        emit LogNewFeeHolder(
            _userAddress,
            _FleetRewardsFee,
            _WarChestFee,
            _MarketingChestFee,
            _MutinyFee,
            _amount
            );
      }

    function updateFeeHolder(address _userAddress, uint256 _FleetRewardsFee, uint256 _WarChestFee, uint256 _MarketingChestFee, uint256 _MutinyFee,
    uint256 _amount) internal {

        require(isFeeHolder(_userAddress), "Fee Holder does not exist!");
        fees[_userAddress].FleetRewardsFee = _FleetRewardsFee;
        fees[_userAddress].WarChestFee = _WarChestFee;
        fees[_userAddress].MarketingChestFee = _MarketingChestFee;
        fees[_userAddress].MutinyFee = _MutinyFee;
        fees[_userAddress].amount = _amount;
        fees[_userAddress].lastUpdated = block.timestamp;
        fees[_userAddress].nextReductionTime = block.timestamp + updateFeeTime;

        emit LogUpdateFeeHolder(
            _userAddress,
            _FleetRewardsFee,
            _WarChestFee,
            _MarketingChestFee,
            _MutinyFee,
            _amount,
            block.timestamp,
            block.timestamp + updateFeeTime
          );
      }

    function isFeeHolder(address userAddress) public view returns(bool isIndeed) {
        if(feeholders.length == 0) return false;
        return (fees[userAddress].exist);
    }

    function getFeeholder(address _userAddress) public view returns(uint256 _FleetRewardsFee, uint256 _WarChestFee,
        uint256 _MarketingChestFee, uint256 _MutinyFee, uint256 _amount, uint256 _lastUpdated, uint256 _nextReductionTime)
      {
        return(
          fees[_userAddress].FleetRewardsFee,
          fees[_userAddress].WarChestFee,
          fees[_userAddress].MarketingChestFee,
          fees[_userAddress].MutinyFee,
          fees[_userAddress].amount,
          fees[_userAddress].lastUpdated,
          fees[_userAddress].nextReductionTime
          );
    }

    function getFeeHoldersCount() public view returns(uint256 count) {
        return feeholders.length;
    }


}

contract TEST16 is IERC20Metadata, DepreciatingFees, Ownable {
    using SafeMath for uint256;
    using Address for address;

    address public MarketingChestAddress =0x9d55dE8cFaba48ef7a5d1DA6dE2170b9C79050fC ; // MarketingChest Address
    address internal deadAddress = 0x000000000000000000000000000000000000dEaD;
    address public presaleAddress = address(0);

    string constant _name = "TEST16";
    string constant _symbol = "ARMD";
    uint8 constant _decimals = 18;

    uint256 private constant MAX = ~uint256(0);
    uint256 internal constant _totalSupply = 1000000000000 * 10**18;
    uint256 internal _reflectedSupply = (MAX - (MAX % _totalSupply));

    uint256 public collectedFeeTotal;

    uint256 public maxTxAmount = _totalSupply / 1000; // 0.5% of the total supply
    uint256 public maxWalletBalance = _totalSupply / 50; // 2% of the total supply

    bool public autoWarChestEnabled = true;
    uint256 public autoWarChestAmount = 1 * 10**18;
    bool public takeFeeEnabled = true;

    bool public isInPresale = false;

    uint256 public MarketingChestDivisor = MarketingChestFee;

    bool private swapping;
    bool public swapEnabled = true;
    uint256 public swapTokensAtAmount = 100000000 * (10**18);

    IPancakeV2Router public router;
    address public pair;

    mapping (address => uint256) internal _reflectedBalances;
    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) internal _allowances;

    mapping (address => bool) internal _isExcludedFromFee;
    mapping (address => bool) internal _isExcludedFromRewards;
    address[] private _excluded;

    event UpdatePancakeswapRouter(address indexed newAddress, address indexed oldAddress);
    event WarChestEnabledUpdated(bool enabled);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);
    event MarketingChestWalletUpdated(address indexed newMarketingChestWallet, address indexed oldMarketingChestWallet);

    event SwapETHForTokens(
        uint256 amountIn,
        address[] path
    );

    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );

    constructor () {
        _reflectedBalances[owner()] = _reflectedSupply;

        IPancakeV2Router _newPancakeRouter = IPancakeV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IPancakeV2Factory(_newPancakeRouter.factory()).createPair(address(this), _newPancakeRouter.WETH());
        router = _newPancakeRouter;

        // exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        // exclude the pair and burn addresses from rewards
        _exclude(pair);
        _exclude(deadAddress);

        _approve(owner(), address(router), ~uint256(0));

        emit Transfer(address(0), owner(), _totalSupply);
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

    function totalSupply() external pure override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256){
        if (_isExcludedFromRewards[account]) return _balances[account];
        return tokenFromReflection(_reflectedBalances[account]);
        }

    function transfer(address recipient, uint256 amount) public override returns (bool){
        _transfer(_msgSender(), recipient, amount);
        return true;
        }

    function allowance(address owner, address spender) public view override returns (uint256){
        return _allowances[owner][spender];
        }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
        }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool){
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
        }

    function burn(uint256 amount) external {

        address sender = _msgSender();
        require(sender != address(0), "ERC20: burn from the zero address");
        require(sender != address(deadAddress), "ERC20: burn from the burn address");

        uint256 balance = balanceOf(sender);
        require(balance >= amount, "ERC20: burn amount exceeds balance");

        uint256 reflectedAmount = amount.mul(_getCurrentRate());

        // remove the amount from the sender's balance first
        _reflectedBalances[sender] = _reflectedBalances[sender].sub(reflectedAmount);
        if (_isExcludedFromRewards[sender])
            _balances[sender] = _balances[sender].sub(amount);

        _burnTokens( sender, amount, reflectedAmount );
    }

    /**
     * @dev "Soft" burns the specified amount of tokens by sending them
     * to the burn address
     */
    function _burnTokens(address sender, uint256 tBurn, uint256 rBurn) internal {

        /**
         * @dev Do not reduce _totalSupply and/or _reflectedSupply. (soft) burning by sending
         * tokens to the burn address (which should be excluded from rewards) is sufficient
         * in FleetRewards
         */
        _reflectedBalances[deadAddress] = _reflectedBalances[deadAddress].add(rBurn);
        if (_isExcludedFromRewards[deadAddress])
            _balances[deadAddress] = _balances[deadAddress].add(tBurn);

        /**
         * @dev Emit the event so that the burn address balance is updated (on bscscan)
         */
        emit Transfer(sender, deadAddress, tBurn);
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BaseFleetRewardsToken: approve from the zero address");
        require(spender != address(0), "BaseFleetRewardsToken: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


     /**
     * @dev Calculates and returns the reflected amount for the given amount with or without
     * the transfer fees (deductTransferFee true/false)
     */
    function reflectionFromToken(uint256 tAmount, bool deductTransferFee, bool isBuying) external view returns(uint256) {
        require(tAmount <= _totalSupply, "Amount must be less than supply");
        uint256 feesSum;
        if (!deductTransferFee) {
            (uint256 rAmount,,,,) = _getValues(tAmount,0);
            return rAmount;
        } else {
            feesSum = isBuying ? baseTotalFees : baseSellerTotalFees;
            (,uint256 rTransferAmount,,,) = _getValues(tAmount, feesSum);
            return rTransferAmount;
        }
    }

    /**
     * @dev Calculates and returns the amount of tokens corresponding to the given reflected amount.
     */
    function tokenFromReflection(uint256 rAmount) internal view returns(uint256) {
        require(rAmount <= _reflectedSupply, "Amount must be less than total reflections");
        uint256 currentRate = _getCurrentRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) external onlyOwner() {
        require(!_isExcludedFromRewards[account], "Account is not included");
        _exclude(account);
    }

    function _exclude(address account) internal {
        if(_reflectedBalances[account] > 0) {
            _balances[account] = tokenFromReflection(_reflectedBalances[account]);
        }
        _isExcludedFromRewards[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcludedFromRewards[account], "Account is not excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _balances[account] = 0;
                _isExcludedFromRewards[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function setExcludedFromFee(address account, bool value) external onlyOwner {
        _isExcludedFromFee[account] = value;

    }

    function _getValues(uint256 tAmount, uint256 feesSum) internal view returns (uint256, uint256, uint256, uint256, uint256) {

        uint256 tTotalFees = tAmount.mul(feesSum).div(FEES_DIVISOR);
        uint256 tTransferAmount = tAmount.sub(tTotalFees);
        uint256 currentRate = _getCurrentRate();
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rTotalFees = tTotalFees.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rTotalFees);

        return (rAmount, rTransferAmount, tAmount, tTransferAmount, currentRate);
    }

    function _getCurrentRate() internal view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() internal view returns(uint256, uint256) {
        uint256 rSupply = _reflectedSupply;
        uint256 tSupply = _totalSupply;

        /**
         * The code below removes balances of addresses excluded from rewards from
         * rSupply and tSupply, which effectively increases the % of transaction fees
         * delivered to non-excluded holders
         */
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_reflectedBalances[_excluded[i]] > rSupply || _balances[_excluded[i]] > tSupply)
            return (_reflectedSupply, _totalSupply);
            rSupply = rSupply.sub(_reflectedBalances[_excluded[i]]);
            tSupply = tSupply.sub(_balances[_excluded[i]]);
        }
        if (tSupply == 0 || rSupply < _reflectedSupply.div(_totalSupply)) return (_reflectedSupply, _totalSupply);
        return (rSupply, tSupply);
    }


    /**
     * @dev Redistributes the specified amount among the current holders via the reflect.finance
     * algorithm, i.e. by updating the _reflectedSupply (_rSupply) which ultimately adjusts the
     * current rate used by `tokenFromReflection` and, in turn, the value returns from `balanceOf`.
     *
     */
    function _redistribute(uint256 amount, uint256 currentRate, uint256 fee) internal {
        uint256 tFee = amount.mul(fee).div(FEES_DIVISOR);
        uint256 rFee = tFee.mul(currentRate);

        _reflectedSupply = _reflectedSupply.sub(rFee);

        collectedFeeTotal = collectedFeeTotal.add(tFee);
    }
    // views
    function minimumTokensBeforeSwapAmount() external view returns (uint256) {
        return swapTokensAtAmount;
    }

    function getAutoWarChestAmount() external view returns (uint256) {
        return autoWarChestAmount;
    }


    function isExcludedFromReward(address account) external view returns (bool) {
        return _isExcludedFromRewards[account];
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

     function totalCollectedFees() external view returns (uint256) {
        return collectedFeeTotal;
    }

    function beAFeeHolder(address userAddress) external {
        uint256 userBalance = balanceOf(address(userAddress));
        require(userBalance > 0, "You are not an Armada Token Holder");

         // create a new fee holder
        if(!isFeeHolder(userAddress)) {
          setFeeHolder(userAddress, userBalance);
        }

    }

    function updateFeeHolderFees(address _userAddress, uint256 _FleetRewardsFee, uint256 _WarChestFee, uint256 _MarketingChestFee, uint256 _MutinyFee,
    uint256 _amount) external onlyOwner {

        updateFeeHolder(
            _userAddress,
            _FleetRewardsFee.mul(reductionDivisor),
            _WarChestFee.mul(reductionDivisor),
            _MarketingChestFee.mul(reductionDivisor),
            _MutinyFee.mul(reductionDivisor),
            _amount
            );
      }

    function whitelistDxSale(address _presaleAddress, address _routerAddress) external onlyOwner {
  	    presaleAddress = _presaleAddress;

        _exclude(_presaleAddress);
        _isExcludedFromFee[_presaleAddress] = true;

        _exclude(_routerAddress);
        _isExcludedFromFee[_routerAddress] = true;
  	}

    function prepareForPreSale() external onlyOwner {
        takeFeeEnabled = false;
        swapEnabled = false;
        isInPresale = true;
        WarChestFee = 0;
        MarketingChestFee = 0;
        FleetRewardsFee = 0;
        MutinyFee = 0;
        maxTxAmount = 1000000000000 * (10**18);
        maxWalletBalance = 1000000000000 * (10**18);
    }

    function afterPreSale() external onlyOwner {
        takeFeeEnabled = true;
        swapEnabled = true;
        isInPresale = false;
        WarChestFee = 12;
        MarketingChestFee = 2;
        FleetRewardsFee = 2;
        MutinyFee = 14;
        maxTxAmount = 2000000 * (10**18);
        maxWalletBalance = 4014201 * (10**18);
    }

    function setWarChestEnabled(bool _enabled) external onlyOwner {
        autoWarChestEnabled = _enabled;
        emit WarChestEnabledUpdated(_enabled);
    }

    function setSwapEnabled(bool _enabled) external onlyOwner {
        swapEnabled  = _enabled;
    }

    function triggerWarChest(uint256 amount) public onlyOwner {
        uint256 contractBalance = address(this).balance;
        require(!swapping, "ARMADA: A swapping process is currently running, wait till that is complete");
        require(contractBalance >= amount, "ARMADA: Insufficient Funds");

        WarChestTokens(amount);
    }

    function updateAutoWarChestAmount(uint256 amount) external onlyOwner () {
        autoWarChestAmount = amount;
    }

    function updateSwapTokensAt(uint256 _swaptokens) external onlyOwner {
        swapTokensAtAmount = _swaptokens * (10**18);
    }

    function updateWalletMax(uint256 _walletMax) external onlyOwner {
        maxWalletBalance = _walletMax * (10**18);
    }

    function updateTransactionMax(uint256 _txMax) external onlyOwner {
        maxTxAmount = _txMax * (10**18);
    }

    function updateMarketingChestFee(uint256 newFee) external onlyOwner {
        MarketingChestFee = newFee;
    }

    function updateWarChestFee(uint256 newFee) external onlyOwner {
        WarChestFee = newFee;
    }

    function updateFleetRewardsFee(uint256 newFee) external onlyOwner {
        FleetRewardsFee = newFee;
    }

    function updateMutinyFee(uint256 newFee) external onlyOwner {
        MutinyFee = newFee;
    }

    function updateMarketingChestWallet(address newMarketingChestWallet) external onlyOwner {
        require(newMarketingChestWallet != MarketingChestAddress, "The MarketingChest wallet is already this address");
        emit MarketingChestWalletUpdated(newMarketingChestWallet, MarketingChestAddress);
        MarketingChestAddress = newMarketingChestWallet;
    }

    function setTakeFeeEnabled(bool __takeFee) external onlyOwner {
        takeFeeEnabled = __takeFee;
    }

    function setMarketingChestDivisor(uint256 divisor) external onlyOwner() {
        MarketingChestDivisor = divisor;
    }


    function setReductionDivisor(uint256 divisor) external onlyOwner() {
        reductionDivisor = divisor;
    }

    function setUpdateFeeTime(uint256 feeTime) external onlyOwner() {
        updateFeeTime = feeTime;
    }

    function setFeesDivisor(uint256 divisor) external onlyOwner() {
        FEES_DIVISOR = divisor;
    }

    function updateRouterAddress(address newAddress) external onlyOwner {
        require(newAddress != address(router), "The router already has that address");
        router = IPancakeV2Router(newAddress);
        emit UpdatePancakeswapRouter(newAddress, address(router));
    }


    function _transferTokens(address sender, address recipient, uint256 amount, bool takeFee, bool feeReduction, address userAddress) private {

        // grab the estimated reduced fees
            (uint256 reduceFleetRewardsFee, uint256 reduceWarChestFee, uint256 reduceMarketingChestFee,
        uint256 reduceMutinyFee) = _getHolderFees(userAddress, feeReduction);


         uint256 sumOfFees = isInPresale ? 0 : reduceFleetRewardsFee.add(reduceMarketingChestFee).add(reduceWarChestFee);

         bool isBuying = true;

        if(recipient == pair) {
            sumOfFees = isInPresale ? 0 : sumOfFees.add(reduceMutinyFee);
            isBuying  = false;
        }

        if(sender != pair && recipient != pair) {
            isBuying = false;
        }

        if(feeReduction) {
            if(isBuying) {
               // Adjust the Fee struct to reflect the new transaction
                reAdjustFees(userAddress, amount, reduceFleetRewardsFee, reduceWarChestFee, reduceMarketingChestFee, reduceMutinyFee);
            }
            else{
                updateAmountOnSell(amount, userAddress);
            }

        }


        if ( !takeFee ){ sumOfFees = 0; }

        processReflectedBal(sender, recipient, amount, sumOfFees, isBuying, reduceFleetRewardsFee, reduceWarChestFee, reduceMarketingChestFee, reduceMutinyFee);

    }

    function processReflectedBal (address sender, address recipient, uint256 amount, uint256 sumOfFees, bool isBuying,
    uint256 reduceFleetRewardsFee, uint256 reduceWarChestFee, uint256 reduceMarketingChestFee, uint256 reduceMutinyFee) internal {

        (uint256 rAmount, uint256 rTransferAmount, uint256 tAmount,
        uint256 tTransferAmount, uint256 currentRate ) = _getValues(amount, sumOfFees);
        bool _isBuying = isBuying;

        theReflection(sender, recipient, rAmount, rTransferAmount, tAmount, tTransferAmount);

        _takeFees(amount, currentRate, sumOfFees, reduceFleetRewardsFee, reduceWarChestFee, reduceMarketingChestFee, reduceMutinyFee, _isBuying);

        emit Transfer(sender, recipient, tTransferAmount);

    }

    function theReflection(address sender, address recipient, uint256 rAmount, uint256 rTransferAmount, uint256 tAmount,
        uint256 tTransferAmount) private {

        _reflectedBalances[sender] = _reflectedBalances[sender].sub(rAmount);
        _reflectedBalances[recipient] = _reflectedBalances[recipient].add(rTransferAmount);

        /**
         * Update the true/nominal balances for excluded accounts
         */
        if (_isExcludedFromRewards[sender]) { _balances[sender] = _balances[sender].sub(tAmount); }
        if (_isExcludedFromRewards[recipient] ) { _balances[recipient] = _balances[recipient].add(tTransferAmount); }
    }


    function _takeFees(uint256 amount, uint256 currentRate, uint256 sumOfFees, uint256 reduceFleetRewardsFee, uint256 reduceWarChestFee,
    uint256 reduceMarketingChestFee,  uint256 reduceMutinyFee, bool isBuying) private {
        if ( sumOfFees > 0 && !isInPresale ){
            _redistribute( amount, currentRate, reduceFleetRewardsFee);  // redistribute to holders
            _takeFee( amount, currentRate, reduceWarChestFee, address(this)); // buy back fee
            _takeFee( amount, currentRate, reduceMarketingChestFee, address(this)); // MarketingChest fee

            if(!isBuying) {
                _takeFee( amount, currentRate, reduceMutinyFee, address(this));
                }
        }
    }

    function _takeFee(uint256 amount, uint256 currentRate, uint256 fee, address recipient) private {
        uint256 tAmount = amount.mul(fee).div(FEES_DIVISOR);
        uint256 rAmount = tAmount.mul(currentRate);

        _reflectedBalances[recipient] = _reflectedBalances[recipient].add(rAmount);
        if(_isExcludedFromRewards[recipient])
            _balances[recipient] = _balances[recipient].add(tAmount);

        collectedFeeTotal = collectedFeeTotal.add(tAmount);
    }

    function _beforeTokenTransfer(address recipient) private {
        // also adjust fees - add later

        if ( !isInPresale ){

            uint256 contractTokenBalance = balanceOf(address(this));
            // swap
            bool canSwap = contractTokenBalance >= swapTokensAtAmount;

            if (!swapping && canSwap && swapEnabled  && recipient == pair) {
                swapping = true;
                contractTokenBalance = swapTokensAtAmount;
                swapTokens(contractTokenBalance);
                swapping = false;
            }

            uint256 WarChestBalance = address(this).balance;
            // auto buy back
            if(autoWarChestEnabled && WarChestBalance >= autoWarChestAmount && !swapping) {
                WarChestBalance = autoWarChestAmount;

                WarChestTokens(WarChestBalance.div(100));
            }
        }
    }


    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "Token: transfer from the zero address");
        require(recipient != address(0), "Token: transfer to the zero address");
        require(sender != address(deadAddress), "Token: transfer from the burn address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (
            sender != address(router) && //router -> pair is removing liquidity which shouldn't have max
            !_isExcludedFromFee[recipient] && //no max for those excluded from fees
            !_isExcludedFromFee[sender]
        ) {
            require(amount <= maxTxAmount, "Transfer amount exceeds the Max Transaction Amount.");

        }

        if ( maxWalletBalance > 0 && !_isExcludedFromFee[recipient] && !_isExcludedFromFee[sender] && recipient != address(pair) ) {
                uint256 recipientBalance = balanceOf(recipient);
                require(recipientBalance + amount <= maxWalletBalance, "New balance would exceed the maxWalletBalance");
            }

         // indicates whether or not feee should be deducted from the transfer
        bool _isTakeFee = takeFeeEnabled;
        if ( isInPresale ){ _isTakeFee = false; }

         // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            _isTakeFee = false;
        }

         bool feeReduction = true;
         address userAddress;

         if(sender != pair && recipient == pair) {
             userAddress = sender;
         }
         else if(sender == pair && recipient != pair) {
             userAddress = recipient;
         }
         else {
             userAddress = msg.sender;
         }

         if(!isInPresale) {
           // create a new fee holder
            if(!isFeeHolder(userAddress)) {
               setFeeHolder(userAddress, recipient != pair ? amount : 0); // create a new fee holder
               feeReduction = false;
            }
         }
         // if contract is in presale, then there should be no fee reduction
        if(isInPresale){ feeReduction = false; }

        _beforeTokenTransfer(recipient);
        _transferTokens(sender, recipient, amount, _isTakeFee, feeReduction, userAddress );

    }


    function swapTokens(uint256 contractTokenBalance) private {

        uint256 initialBalance = address(this).balance;
        swapTokensForBNB(contractTokenBalance);
        uint256 transferredBalance = address(this).balance.sub(initialBalance);

        //Send to MarketingChest address
       transferToAddressBNB(payable(MarketingChestAddress), transferredBalance.mul(MarketingChestDivisor).div(100));
    }

    function WarChestTokens(uint256 amount) private {
    	if (amount > 0) {
    	    swapBNBForTokens(amount);
	    }
    }

    function swapTokensForBNB(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), address(router), tokenAmount);

        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );

        emit SwapTokensForETH(tokenAmount, path);
    }

    function swapBNBForTokens(uint256 amount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(this);

      // make the swap
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0, // accept any amount of Tokens
            path,
            deadAddress, // Burn address
            block.timestamp
        );

        emit SwapETHForTokens(amount, path);
    }

    function transferToAddressBNB(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }

    receive() external payable {}

}

//       d8888 8888888b.  888b     d888        d8888 8888888b.        d8888
//      d88888 888   Y88b 8888b   d8888       d88888 888  "Y88b      d88888
//     d88P888 888    888 88888b.d88888      d88P888 888    888     d88P888
//    d88P 888 888   d88P 888Y88888P888     d88P 888 888    888    d88P 888
//   d88P  888 8888888P"  888 Y888P 888    d88P  888 888    888   d88P  888
//  d88P   888 888 T88b   888  Y8P  888   d88P   888 888    888  d88P   888
// d8888888888 888  T88b  888   "   888  d8888888888 888  .d88P d8888888888
//d88P     888 888   T88b 888       888 d88P     888 8888888P" d88P     888