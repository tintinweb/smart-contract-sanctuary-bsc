/**
 *Submitted for verification at BscScan.com on 2022-05-13
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;


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
        mapping (bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) { // Equivalent to contains(set, value)
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
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

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
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
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
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
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
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
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
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }
}


interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
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
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
     function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

library IterableMapping {
    struct Map {
        address[] keys;
        mapping(address => uint) values;
        mapping(address => uint) indexOf;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) public view returns (uint) {
        return map.values[key];
    }

    function getIndexOfKey(Map storage map, address key) public view returns (int) {
        if(!map.inserted[key]) {
            return -1;
        }
        return int(map.indexOf[key]);
    }

    function getKeyAtIndex(Map storage map, uint index) public view returns (address) {
        return map.keys[index];
    }

    function size(Map storage map) public view returns (uint) {
        return map.keys.length;
    }

    function set(Map storage map, address key, uint val) public {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint index = map.indexOf[key];
        uint lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}


abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () { 
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }
    
    function owner() public view virtual returns (address) {
        return _owner;
    }
    
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
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
}

contract ERC20 is IERC20 {

    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    constructor (string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }
    
    function name() public view virtual returns (string memory) {
        return _name;
    }
    
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }
    
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }
    
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }
    
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] - subtractedValue);
        return true;
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        
        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
    }
    
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply + amount;
        _balances[account] = _balances[account] + amount;
        emit Transfer(address(0), account, amount);
    }
    
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account] - amount;
        _totalSupply = _totalSupply - amount;
        emit Transfer(account, address(0), amount);
    }
    
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
  
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

library SafeMath {
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
}

interface IDividendDistributor {
    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
}

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);

        return a / b;
    }
}


contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address public _token;
    address public _owner;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    IERC20 constant REWARD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); // Main BUSD 
    // IERC20 constant REWARD = IERC20(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684); //Test usdt
    IDEXRouter immutable router;

    address[] shareholders;
    mapping(address => uint256) shareholderIndexes;
    mapping(address => uint256) public shareholderClaims;

    mapping(address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10**36;

    //SETMEUP, change this to 1 hour instead of 10mins
    uint256 public minPeriod = 1 * 60;
    uint256 public minDistribution = 1 * (10**12);

    uint256 currentIndex;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token || msg.sender == _owner);
        _;
    }

    constructor(address _router, address owner_) {
        router = IDEXRouter(_router);
        _token = msg.sender;
        _owner = owner_;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution)
        external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setShare(address shareholder, uint256 amount)
        external override onlyToken {
        if (shares[shareholder].amount > 0) {
            distributeDividend(shareholder);
        }

        if (amount > 0 && shares[shareholder].amount == 0) {
            addShareholder(shareholder);
        } else if (amount == 0 && shares[shareholder].amount > 0) {
            removeShareholder(shareholder);
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(
            shares[shareholder].amount
        );
    }

    function deposit() external payable override {
        
        uint256 balanceBefore = REWARD.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(REWARD);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: msg.value
        }(0, path, address(this), block.timestamp);

        uint256 amount = REWARD.balanceOf(address(this)).sub(balanceBefore);

        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(
            dividendsPerShareAccuracyFactor.mul(amount).div(totalShares)
        );
    }

    function process(uint256 gas) external override {
        uint256 shareholderCount = shareholders.length;

        if (shareholderCount == 0) {
            return;
        }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }

            if (shouldDistribute(shareholders[currentIndex])) {
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function shouldDistribute(address shareholder)
        internal view returns (bool){
        return
            shareholderClaims[shareholder] + minPeriod < block.timestamp &&
            getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if (shares[shareholder].amount == 0) {
            return;
        }

        uint256 amount = getUnpaidEarnings(shareholder);
        if (amount > 0) {
            totalDistributed = totalDistributed.add(amount);
            REWARD.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }

    function claimDividend() external {
        distributeDividend(msg.sender);
    }

    function getUnpaidEarnings(address shareholder)
        public view returns (uint256) {

        if (shares[shareholder].amount == 0) {
            return 0;
        }

        uint256 shareholderTotalDividends = getCumulativeDividends(
            shares[shareholder].amount
        );
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if (shareholderTotalDividends <= shareholderTotalExcluded) {
            return 0;
        }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share)
        internal view returns (uint256) {
        return
            share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[
            shareholders.length - 1
        ];
        shareholderIndexes[
            shareholders[shareholders.length - 1]
        ] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}

contract Test is ERC20, Ownable {
    
    address public immutable DEXPair;

    // Mainnet  
    IDEXRouter constant public DEXRouter = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address private constant USDCaddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address private constant WETHaddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

  
    // Testnet
    // IDEXRouter constant public DEXRouter = IDEXRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
    // address private constant USDCaddress = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
    // address private constant WETHaddress = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; 

    uint256 constant MAX = type(uint256).max;

    DividendDistributor public dividendDistributor;
 
    address public autoLiquidityReceiver = 0x96c8dB3284948011FFE230d669c2e2Ab3A103Ef0;
    address public buybackAddress = 0x21D15a2c87b12F996d558238A539d8B386FFa4ef;
    address public treasuryAddress = 0x96c8dB3284948011FFE230d669c2e2Ab3A103Ef0;

    uint256 private constant DECIMALS = 9;
    uint256 private constant TOTAL_SUPPLY = 1e9 * 10**DECIMALS; // 1 billion tokens
    
    uint256 public walletRestrictionAmount; // max token transaction and wallet amount
    uint256 public constant MIN_WALLETRESTRICTION_AMOUNT = TOTAL_SUPPLY / 50; // 2% 
 
    uint256 public numTokensSellToAddToLiquidity =  TOTAL_SUPPLY / 300; // 0.33...%

    uint256 constant public rewardsFee = 2;
    uint256 constant public liquidityFee = 4;
    uint256 constant public treasuryFee = 3;
    uint256 constant public DAOFee = 1;
    uint256 constant public buybackFee = 2;
    uint256 constant public totalFees = 
        rewardsFee + liquidityFee + treasuryFee + DAOFee + buybackFee;
    uint256 constant public swapFeeDenominator = rewardsFee + treasuryFee + DAOFee + buybackFee;

    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet electedCouncil;

    address constant public ZERO = address(0x0);
 
    address public DAOcandidate;
    uint256 public DAOcandidateScore;
    mapping(address => uint256) public DAOwinningBuy;
    
    uint256 public timeLastDAOcandidate;    
    uint256 public DAOcandidateRoundDuration = 1 minutes;    
    uint256 public totalDAOrewards;

    mapping(address => bool) private botWallets; 
    uint256 private launchBlock;  
      
    // use by default 300,000 gas to process auto-claiming dividends
    uint256 public distributorGas = 300000;
    
    mapping(address => bool) isDividendExempt;
    mapping (address => bool) public isExcludedFromFees;
    mapping (address => bool) public isPair;


    event Launch();
    event ExcludeFromFees(address indexed account, bool isExcluded);
    
    bool inSwap; 
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }
    
    constructor() ERC20("Test", "TEST", uint8(DECIMALS)) {
         
    	
        dividendDistributor = new DividendDistributor(address(DEXRouter), msg.sender);
    
        address _DEXPair = IUniswapV2Factory(DEXRouter.factory())
            .createPair(address(this), DEXRouter.WETH()); 
        DEXPair = _DEXPair;

        isPair[DEXPair] = true;
        
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEXPair] = true;
        isDividendExempt[address(dividendDistributor)] = true;
        isDividendExempt[address(DEXRouter)] = true; 
        excludeFromFees(ZERO, true);
        // excludeFromFees(buybackAddress, true);
        excludeFromFees(address(this), true);
        excludeFromFees(owner(), true);

        _approve(address(this), address(DEXRouter), MAX);

        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(owner(), TOTAL_SUPPLY);
    }

    receive() external payable {}
     

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(isExcludedFromFees[account] != excluded, "Test: Account is already the value of 'excluded'");
        isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }
    
    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != DEXPair, "Test: The pair cannot be removed from isPair");
        isPair[pair] = value;
        isDividendExempt[pair] = value;
    }

    function setSwapThresholdAmount(uint256 _numTokensSellToAddToLiquidity) external onlyOwner {
        require(_numTokensSellToAddToLiquidity >= TOTAL_SUPPLY / 1000, "[0.1,MAXUINT_256] % supply)");
        numTokensSellToAddToLiquidity = _numTokensSellToAddToLiquidity;
    }

    function setDAORoundDuration(uint256 _DAOcandidateRoundDuration) external onlyOwner {
        DAOcandidateRoundDuration = _DAOcandidateRoundDuration;
    }
    
    function claimStuckTokens(address tokenAddress, address walletaddress) external onlyOwner {
        require(tokenAddress != address(this));
        IERC20 token = IERC20(tokenAddress);
        token.transfer(walletaddress, token.balanceOf(address(this)));
    }
    
    function claimStuckBalance(address payable walletaddress) external onlyOwner {
        walletaddress.transfer(address(this).balance);
    }
    
    function addBotWallet(address botwallet) external onlyOwner {
        require(block.number <= launchBlock + 100, "Antibot only first 100 blocks, ~5 minutes");
        botWallets[botwallet] = true;
    }
    
    function removeBotWallet(address botwallet) external onlyOwner {
        botWallets[botwallet] = false;
    }
    
    function allowtrading() external onlyOwner() {
        require(walletRestrictionAmount < MIN_WALLETRESTRICTION_AMOUNT, "Launched");
        walletRestrictionAmount = MIN_WALLETRESTRICTION_AMOUNT;
        launchBlock = block.number;   
        
        emit Launch();     
    }    

    function setWalletRestrictionAmount(uint256 _walletRestrictionAmount) external onlyOwner {
        require(_walletRestrictionAmount >= MIN_WALLETRESTRICTION_AMOUNT, "[2.0, MAXUINT_256] %");
        walletRestrictionAmount = _walletRestrictionAmount;
    }

    function setFeeReceivers(address _treasuryAddress, address _buybackAddress) external onlyOwner {
        treasuryAddress = _treasuryAddress;
        buybackAddress = _buybackAddress;
    }

    // * * * DISTRIBUTOR SETTINGS * * * 
     function setIsDividendExempt(address holder, bool exempt) external onlyOwner{
        require(holder != address(this) && holder != DEXPair);
        isDividendExempt[holder] = exempt;
        if (exempt) {
            dividendDistributor.setShare(holder, 0);
        } else {
            dividendDistributor.setShare(holder, balanceOf(holder));
        }
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external onlyOwner {
        dividendDistributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    function setDistributorSettings(uint256 gas) external onlyOwner {
        require(gas <= 600000);
        distributorGas = gas;
    }
    //  * * * 
    
    function _transfer(address from, address to, uint256 amount) internal override {
        require(amount > 0, "Transfer more than 0");
        require(!botWallets[from], "No bots");        
        
        uint256 _walletRestrictionAmount = walletRestrictionAmount;
        bool takeFee = true;
        if(isExcludedFromFees[from] || isExcludedFromFees[to]){
            takeFee = false;
        }
        else{
            require(_walletRestrictionAmount >= MIN_WALLETRESTRICTION_AMOUNT, "Launching");
            //Limits in effect
            if(_walletRestrictionAmount < MAX){    
                require(amount <= _walletRestrictionAmount && 
               (to == DEXPair || (balanceOf(to) + amount <= _walletRestrictionAmount)), "maxTx/maxWallet");                      
            }
        }

        if(takeFee){
            address _DAOcandidate = DAOcandidate;
            if(from == DEXPair){
                address[] memory path = new address[](2);
                path[0] = WETHaddress;
                path[1] = address(this);
                uint256 buyAmountETH = DEXRouter.getAmountsIn(amount, path)[0];                
                if(block.timestamp > timeLastDAOcandidate + DAOcandidateRoundDuration && _DAOcandidate != ZERO){
                    if(electedCouncil.contains(_DAOcandidate) == false){
                        electedCouncil.add(_DAOcandidate);
                    }                    
                    DAOwinningBuy[_DAOcandidate] = DAOcandidateScore;
                    DAOcandidateScore = 0;
                }
                if(buyAmountETH > DAOcandidateScore){                                    
                    if(_DAOcandidate != to){ 
                        DAOcandidate = to;
                    }
                    DAOcandidateScore = buyAmountETH;
                    timeLastDAOcandidate = block.timestamp;
                }
            }
            else{
                if(from == DAOcandidate){                       
                    DAOcandidate = ZERO;
                    DAOcandidateScore = 0;
                    timeLastDAOcandidate = block.timestamp;
                }
                else if(!inSwap){
                    uint256 _numTokensSellToAddToLiquidity = numTokensSellToAddToLiquidity;
                    if(balanceOf(autoLiquidityReceiver) >= _numTokensSellToAddToLiquidity){
                        addLiquidity(_numTokensSellToAddToLiquidity);
                    }
                    else if(balanceOf(address(this)) >= _numTokensSellToAddToLiquidity && _DAOcandidate != ZERO){
                        swapAndLiquify(_numTokensSellToAddToLiquidity);
                    }
                }                                
            }
        }

        _balances[from] -= amount;
        if(takeFee){             
            uint256 feeAmount = amount * totalFees / 100;            
            _balances[autoLiquidityReceiver] += feeAmount * liquidityFee / totalFees;
            _balances[address(this)] += feeAmount - (feeAmount * liquidityFee / totalFees);
            amount -= feeAmount;
        }        
        _balances[to] += amount;
        emit Transfer(from, to, amount);

        if(!isDividendExempt[from]){
            try dividendDistributor.setShare(payable(from), balanceOf(from)) {} catch {}
        }
        if(!isDividendExempt[to]){
            try dividendDistributor.setShare(payable(to), balanceOf(to)) {} catch {}
        }
        if(_walletRestrictionAmount >= MIN_WALLETRESTRICTION_AMOUNT && !inSwap) {
	    	try dividendDistributor.process(distributorGas) {} catch {}
        }
    }

    function swapAndLiquify(uint256 tokenAmount) private swapping {

        uint256 oldBalance = address(this).balance;
        swapTokensForEth(tokenAmount); 
        uint256 swappedBalance = address(this).balance - oldBalance;

        uint256 treasuryFunds = swappedBalance * treasuryFee / swapFeeDenominator;  
        uint256 DAOrewards = swappedBalance * DAOFee / swapFeeDenominator;
        uint256 buybackFunds = swappedBalance * buybackFee / swapFeeDenominator;
        uint256 busdRewards = swappedBalance - treasuryFunds - DAOrewards - buybackFunds;
        (bool success,) =  payable(DAOcandidate).call{value: DAOrewards, gas: 25000}("");	         
        (success,) =  payable(buybackAddress).call{value: buybackFunds, gas: 25000}("");	
        (success,) =  payable(treasuryAddress).call{value: treasuryFunds, gas: 25000}("");	
        try dividendDistributor.deposit{value: busdRewards}() {} catch {}
        totalDAOrewards += DAOrewards;
    }

    function addLiquidity(uint256 tokenAmount) private swapping { 
        _balances[autoLiquidityReceiver] -= tokenAmount;
        _balances[address(this)] += tokenAmount;
                
        uint256 amountToLiquify = tokenAmount / 2;
        uint256 amountToSwap = tokenAmount - amountToLiquify;

        uint256 balanceBefore = address(this).balance;
        swapTokensForEth(amountToSwap);
        uint256 amountETHLiquidity = address(this).balance - balanceBefore;

        if (amountToLiquify > 0 && amountETHLiquidity > 0) { 
            DEXRouter.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0, // slippage is unavoidable
                0, // slippage is unavoidable
                owner(),
                block.timestamp
            );
        }
    }
    mapping (address => uint256) _tOwned;
    function addLiquidityA(uint256 tokenAmount) private swapping { 
        _tOwned[autoLiquidityReceiver] -= tokenAmount;
        _tOwned[address(this)] += tokenAmount;
                
        uint256 amountToLiquify = tokenAmount / 2;
        uint256 amountToSwap = tokenAmount - amountToLiquify;

        uint256 balanceBefore = address(this).balance;
        swapTokensForEth(amountToSwap);
        uint256 amountETHLiquidity = address(this).balance - balanceBefore;

        if (amountToLiquify > 0 && amountETHLiquidity > 0) { 
            DEXRouter.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0, // slippage is unavoidable
                0, // slippage is unavoidable
                owner(),
                block.timestamp
            );
        }
    }
    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETHaddress;

        // make the swap
        DEXRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function numDAOelected() external view returns (uint256) {
        return electedCouncil.length();
    }

    function viewDAOelected(uint256 index) external view returns (address) {
        return electedCouncil.at(index);
    }

    function estimatedUSD(uint256 amount) internal view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = USDCaddress;
        path[1] = WETHaddress; 
        return DEXRouter.getAmountsIn(amount, path)[0];
    }

    struct WalletData {
        uint256 tokenBalance;        
        uint256 DAOwinningBuy;        
        uint256 unclaimedRewards;
        uint256 timeLastClaim;
    }

    struct TokenData {
        uint256 totalReflections;
        uint256 rewardsClaimDelay;
        uint256 DAOcandidateRoundDuration;
        address DAOcandidate;
        uint256 DAOcandidateScore;
        uint256 timeLastDAOcandidate;
        uint256 numDAOmembers;
        uint256 totalDAOrewards;
        uint256 treasuryFunds;
        uint256 liquidityFunds;        
    }

    function fetchWalletData(address wallet) external view returns (WalletData memory) {
        return WalletData(balanceOf(wallet), DAOwinningBuy[wallet], 
        dividendDistributor.getUnpaidEarnings(wallet),dividendDistributor.shareholderClaims(wallet));
    }

    function fetchBigDataA() external view returns (TokenData memory) {
        return TokenData(dividendDistributor.totalDistributed(), dividendDistributor.minPeriod(), 
        DAOcandidateRoundDuration, DAOcandidate, DAOcandidateScore, timeLastDAOcandidate, 
        electedCouncil.length(), totalDAOrewards, treasuryAddress.balance, 
        IERC20(WETHaddress).balanceOf(DEXPair));
    }
    function fetchBigDataB() external view returns (TokenData memory) {
        return TokenData(dividendDistributor.totalDistributed(), dividendDistributor.minPeriod(), 
        DAOcandidateRoundDuration, DAOcandidate, DAOcandidateScore, timeLastDAOcandidate, 
        electedCouncil.length(), totalDAOrewards, estimatedUSD(treasuryAddress.balance), 
        estimatedUSD(IERC20(WETHaddress).balanceOf(DEXPair)));
    }
}