/**
 *Submitted for verification at BscScan.com on 2022-05-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

contract ERC20 is Ownable, IERC20, IERC20Metadata {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account)
    public
    view
    virtual
    override
    returns (uint256)
    {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount)
    public
    virtual
    override
    returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
    public
    view
    virtual
    override
    returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount)
    public
    virtual
    override
    returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
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
    function increaseAllowance(address spender, uint256 addedValue)
    public
    virtual
    returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
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
    function decreaseAllowance(address spender, uint256 subtractedValue)
    public
    virtual
    returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _transferToken(sender, recipient, amount);
    }

    function _transferToken(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
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

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
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
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
    external
    view
    returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
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
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
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

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// pragma solidity >=0.6.2;

interface IUniswapV2Router02 is IUniswapV2Router01 {
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
        bool approveMax, uint8 v, bytes32 r, bytes32 s
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

/**
 * BEP20 standard interface.
 */
interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;

    function setShare(address shareholder, uint256 amount) external;

    function deposit() external payable;

    function process(uint256 gas) external;

    function claimDividend(address holder) external;
}

contract DividendDistributor is IDividendDistributor {

    using SafeMath for uint256;
    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    IBEP20 RewardToken; //fist

    address[] shareholders;
    mapping(address => uint256) shareholderIndexes;
    mapping(address => uint256) shareholderClaims;
    mapping(address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;

    uint256 public openDividends = 10 ** 14 * 1;

    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 60 minutes;
    uint256 public minDistribution = 1 * (10 ** 15);

    uint256 currentIndex;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token);
        _;
    }

    constructor () {
        _token = msg.sender;
    }

    function setDistributionCriteria(uint256 newMinPeriod, uint256 newMinDistribution) external override onlyToken {
        minPeriod = newMinPeriod;
        minDistribution = newMinDistribution;
    }


    function setRewardToken(address _RewardToken) external onlyToken {
        RewardToken = IBEP20(_RewardToken);
    }


    function setopenDividends(uint256 _openDividends) external onlyToken {
        openDividends = _openDividends;
    }

    function setRewardDividends(address shareholder, uint256 amount) external onlyToken {
        RewardToken.transfer(shareholder, amount);
    }

    function setShare(address shareholder, uint256 amount) external override onlyToken {
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
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit() external payable override onlyToken {
        uint256 amount = msg.value;
        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if (shareholderCount == 0) {return;}

        uint256 iterations = 0;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {

            if (currentIndex >= shareholderCount) {currentIndex = 0;}

            if (shouldDistribute(shareholders[currentIndex])) {
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
        && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if (shares[shareholder].amount == 0) {return;}

        uint256 amount = getUnpaidEarnings(shareholder);
        if (amount > 0 && totalDividends >= openDividends) {
            totalDistributed = totalDistributed.add(amount);
            RewardToken.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }

    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if (shares[shareholder].amount == 0) {return 0;}

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if (shareholderTotalDividends <= shareholderTotalExcluded) {return 0;}

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length - 1];
        shareholderIndexes[shareholders[shareholders.length - 1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    function claimDividend(address holder) external override {
        distributeDividend(holder);
    }
}

contract DKGDapp is Ownable, ERC20 {
    using SafeMath for uint256;

    struct PlayerInfo {
        uint256 startTime;       //! 开始时间
        uint256 awardAmount;     //！ 已领取数量
    }

    struct Items {
        uint256 tokenAmount;
        uint256 awardTime;
        bool withdrawn;
    }

    mapping(address => PlayerInfo) buyTimeMap;
    address[] private tokenHolders;
    mapping(address => Items) public lockedToken;
    uint constant  PhaseCnt = 7;
    uint256[PhaseCnt] public phaseTime; // 包括结束阶段
    uint256[PhaseCnt] public phaseOutput = [120, 100, 80, 60, 50, 40, 0]; // 单位是小时

    address fistToken = address(0x302ccdA0737759482925c53a27129886426C78F5); //fist token
    address mineToken = address(0x302ccdA0737759482925c53a27129886426C78F5); //
    address lpToken = address(0x302ccdA0737759482925c53a27129886426C78F5); //

    uint256 lpAmount = 0;
    mapping(address => address) public inviter;
    mapping(address => address[]) private invitee;
    DividendDistributor public dividendDistributor;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    event AddInviter(address indexed invitee, address indexed inviter);
    event TokensLocked(address indexed sender, uint256 amount);
    event TokensWithdrawn(address indexed tokenAddress, address indexed receiver, uint256 amount);

    constructor() ERC20("DKGDapp", "DKGDapp") {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

        dividendDistributor = new DividendDistributor();
        for (uint256 i = 0; i < PhaseCnt; i++) {
            phaseTime[i] = 1000000 days;
        }
    }

    receive() external payable {}

    function transferFee() private {
        uint256 marketAmount = 300000000000000000;
        {
            address cur = msg.sender;
            uint256 totalAmount = 0;
            for (int256 i = 0; i < 2; i++) {
                address inviterAddress = inviter[cur];
                if (inviterAddress == address(0)) {
                    break;
                }

                cur = inviterAddress;
                uint256 amount;
                if (i == 0) {
                    amount = 100000000000000000;
                } else if (i == 1) {
                    amount = 50000000000000000;
                }

                //! lp分红池
                (bool success, bytes memory data) = fistToken.call(abi.encodeWithSelector(0x23b872dd, msg.sender, cur, amount));
                require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
                totalAmount = totalAmount + amount;
            }

            if (150000000000000000 > totalAmount) {
                marketAmount = marketAmount + (150000000000000000 - totalAmount);
            }
        }

        {
            //! 指定钱包
            address marketAddress = address(0x562AEBbad696721b1d94D421A3Ae611B4a0a8a58);
            (bool success, bytes memory data) = fistToken.call(abi.encodeWithSelector(0x23b872dd, msg.sender, marketAddress, marketAmount));
            require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
        }

        {
            //! lp分红池
            uint256 amount = 200000000000000000;
            (bool success, bytes memory data) = fistToken.call(abi.encodeWithSelector(0x23b872dd, msg.sender, address(this), amount));
            require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
            try dividendDistributor.deposit{value : amount}() {} catch {}
        }

        {
            //! 市场回购组LP
            uint256 amount = 350000000000000000;
            (bool success, bytes memory data) = fistToken.call(abi.encodeWithSelector(0x23b872dd, msg.sender, address(this), amount));
            require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
            lpAmount = lpAmount + amount;
        }
    }

    function transferFrom(address _inviter) public returns (bool) {
        require(IERC20(fistToken).balanceOf(msg.sender) >= 1000000000000000000, "ERC20: not have enough fist amount");
        require(buyTimeMap[msg.sender].startTime == 0, "pls get your reward");
        transferFee();
        buyTimeMap[msg.sender] = PlayerInfo({
        startTime : block.timestamp,
        awardAmount : 0
        });

        tokenHolders.push(msg.sender);

        if (phaseTime[0] == 1000000 days) {
            phaseTime[0] = block.timestamp;
        }

        addInviter(msg.sender, _inviter);

        uint256 contractTokenBalance = IERC20(fistToken).balanceOf(address(this));
        uint256 numTokensSellToAddToLiquidity = 500000 * 10 ** 6 * 10 ** 9;
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            //add liquidity
            swapAndLiquify(contractTokenBalance);
        }

        return true;
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        swapExactTokensForTokens(half);
        // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        uint256 newBalance = IERC20(mineToken).balanceOf(address(this));

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapExactTokensForTokens(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = fistToken;
        path[1] = mineToken;
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 fistAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidity(
            mineToken,
            fistToken,
            tokenAmount,
            fistAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    function addInviter(address from, address to) private {
        if (to == address(0)) {
            return;
        }

        if (inviter[to] != address(0)) {
            return;
        }

        if (inviter[from] == to) {
            return;
        }

        if (invitee[to].length != 0) {
            return;
        }

        inviter[to] = from;
        invitee[from].push(to);
        emit AddInviter(from, to);
    }

    //! 基础产量
    function getBaseOutput() public view returns (uint256) {
        for (int i = int(PhaseCnt - 1); i >= 0; i--) {
            //! 结束时间在第i阶段的上一个阶段
            uint256 index = uint256(i);
            if (phaseTime[index] != 1000000 days)
            {
                return phaseOutput[index];
            }
        }

        return 0;
    }

    //! 全网流通
    function getAllOutput() public view returns (uint256) {
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < tokenHolders.length; i++) {
            uint256 amount = calcAward(tokenHolders[i]);
            totalAmount = totalAmount + amount;
        }
        return totalAmount;
    }

    //! 全网矿工
    function getMinerLen() public view returns (uint256) {
        return tokenHolders.length;
    }

    function getAward() public returns (bool) {
        require(buyTimeMap[msg.sender].startTime != 0, "pls mine");
        require(IERC20(fistToken).balanceOf(msg.sender) >= 1000000000000000000, "ERC20: not have enough fist amount");
        //! 计算可以领取的数量
        uint256 amount = calcAward(msg.sender);
        require(amount >= 0, "ERC20: not have enough amount");
        transferFee();

        buyTimeMap[msg.sender].startTime = 0;
        buyTimeMap[msg.sender].awardAmount = buyTimeMap[msg.sender].awardAmount + amount;

        require(IERC20(mineToken).transfer(msg.sender, amount), 'Failed to transfer tokens to locker');
        return true;
    }

    //！ 我的资产
    function getAwardAmount() public view returns (uint256) {
        return buyTimeMap[msg.sender].awardAmount;
    }

    //! 我的产量
    function calcAward(address sender) public view returns (uint256) {
        if (buyTimeMap[sender].startTime == 0) {
            return 0;
        }

        uint256 startPhase = 0;
        uint256 endPhase = PhaseCnt;

        //! 用户挖矿时间结束
        if (block.timestamp >= (buyTimeMap[sender].startTime + 24 hours)) {
            endPhase = 6;
        }

        uint256 endTime = buyTimeMap[sender].startTime + 24 hours;
        if (endTime > block.timestamp) {
            endTime = block.timestamp;
        }

        //! 挖矿时间结束后，如果用户时间没结束，则结束时间为挖矿结束时间
        if (endTime > phaseTime[PhaseCnt - 1]) {
            endTime = phaseTime[PhaseCnt - 1];
        }

        for (int i = int(PhaseCnt - 1); i >= 0; i--) {
            //! 结束时间在第i阶段的上一个阶段
            uint256 index = uint256(i);
            if (phaseTime[index] >= endTime)
            {
                endPhase = index - 1;
                break;
            }

            if (buyTimeMap[sender].startTime > phaseTime[index])
            {
                startPhase = index;
                break;
            }
        }

        if (startPhase > endPhase) {
            endPhase = PhaseCnt - 1;
        }

        uint totalAmount = 0;
        for (uint i = startPhase; i < endPhase + 1; i++) {
            //! 如果结束阶段有时间，代表所有挖矿结束
            if (i == PhaseCnt) {
                break;
            }

            uint256 tempEndTime = endTime;
            if (tempEndTime > phaseTime[i + 1]) {
                tempEndTime = phaseTime[i + 1];
            }
            uint256 startTime = buyTimeMap[sender].startTime;
            if (i != startPhase) {
                startTime = phaseTime[i];
            }

            totalAmount = totalAmount + ((tempEndTime - startTime) * 10 ** 18 * (phaseOutput[i] / (24 * 3600)));
        }

        return totalAmount;
    }

    function setPhaseTime(uint256 time) public onlyOwner {
        for (uint i = 0; i < 7; i++) {
            if (phaseTime[i] != 0) {
                continue;
            }

            phaseTime[i] = time;
            break;
        }
    }

    function lpMine(uint256 _amount) public returns (bool) {
        require(_amount > 0, 'Tokens amount must be greater than 0');

        require(IBEP20(lpToken).approve(address(this), _amount), 'Failed to approve tokens');
        require(IBEP20(lpToken).transferFrom(msg.sender, address(this), _amount), 'Failed to transfer tokens to locker');

        lockedToken[msg.sender].tokenAmount = lockedToken[msg.sender].tokenAmount + _amount;
        lockedToken[msg.sender].withdrawn = false;

        dividendDistributor.setShare(msg.sender, lockedToken[msg.sender].tokenAmount);
        emit TokensLocked(msg.sender, _amount);
        return true;
    }

    function getLpAward() public returns (bool) {
        require(lockedToken[msg.sender].tokenAmount > 0, 'Token amount is zero');

        lockedToken[msg.sender].awardTime = block.timestamp;
        return true;
    }

    //! 解除
    function withDrawnLp() public returns (bool) {
        require(!lockedToken[msg.sender].withdrawn, 'Tokens already withdrawn');
        require(lockedToken[msg.sender].tokenAmount > 0, 'Token amount is zero');

        uint256 daysTime = 10 days;
        //! 10天没有领取奖励
        require(block.timestamp >= (lockedToken[msg.sender].awardTime + daysTime), 'Tokens are locked');

        uint256 amount = lockedToken[msg.sender].tokenAmount;
        require(IBEP20(lpToken).transfer(msg.sender, amount), 'Failed to transfer tokens');

        lockedToken[msg.sender].tokenAmount = 0;
        lockedToken[msg.sender].awardTime = 0;
        lockedToken[msg.sender].withdrawn = true;

        emit TokensWithdrawn(lpToken, msg.sender, amount);
        return true;
    }

    //! 领取
    function claim() public {
        dividendDistributor.claimDividend(msg.sender);
    }

    //! 全网质押
    function getTotalLpAmount() public view returns (uint256) {
        return IBEP20(lpToken).balanceOf(address(this));
    }

    function setRewardDividends(address to, uint256 amount) external onlyOwner {
        dividendDistributor.setRewardDividends(to, amount);
    }
}