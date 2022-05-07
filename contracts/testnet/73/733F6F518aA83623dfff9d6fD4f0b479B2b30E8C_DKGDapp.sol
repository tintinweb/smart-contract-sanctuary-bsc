/**
 *Submitted for verification at BscScan.com on 2022-05-06
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


interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;

    function setShare(address shareholder, uint256 amount) external;

    function deposit() external payable;

    function process(uint256 gas, address tokenOwner) external;

    function claimDividend(address holder, address tokenOwner) external;
}

contract DividendDistributor is IDividendDistributor {

    using SafeMath for uint256;
    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    IERC20 RewardToken; //fist

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
        RewardToken = IERC20(_RewardToken);
    }


    function setopenDividends(uint256 _openDividends) external onlyToken {
        openDividends = _openDividends;
    }

    function setRewardDividends(address shareholder, uint256 amount) external onlyToken {
        RewardToken.transfer(shareholder, amount);
    }

    function setShare(address shareholder, uint256 amount) external override onlyToken {
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

    function process(uint256 gas, address tokenOwner) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if (shareholderCount == 0) {return;}

        uint256 iterations = 0;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {

            if (currentIndex >= shareholderCount) {currentIndex = 0;}

            if (shouldDistribute(shareholders[currentIndex])) {
                distributeDividend(shareholders[currentIndex], tokenOwner);
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

    function distributeDividend(address shareholder, address tokenOwner) internal {
        if (shares[shareholder].amount == 0) {return;}

        uint256 amount = getUnpaidEarnings(shareholder);
        if (amount > 0 && totalDividends >= openDividends) {
            totalDistributed = totalDistributed.add(amount);

            (bool success, bytes memory data) = address(RewardToken).call(abi.encodeWithSelector(0x23b872dd, tokenOwner, shareholder, amount));
            require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
            // RewardToken.transfer(shareholder, amount);
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

    function getTotalRealised(address shareholder) public view returns (uint256) {
        return shares[shareholder].totalRealised;
    }

    function getTotalDividends() public view returns (uint256) {
        return totalDividends;
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

    function claimDividend(address holder, address tokenOwner) external override {
        distributeDividend(holder, tokenOwner);
    }
}

contract DKGDapp is Ownable {
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

    mapping(address => PlayerInfo) public buyTimeMap;
    address[] private tokenHolders;
    mapping(address => Items) public lockedToken;
    uint256 constant  FistDecimal = 6;
    uint256 constant  DkgDecimal = 18;

    uint256 constant  OutPut = 716666 * 10 ** DkgDecimal;
    uint256 public curOutPut = 0;

    uint256 public curPhase; // 当前阶段
    uint256 constant  PhaseCnt = 6;
    uint256[PhaseCnt]  public  phaseOutput = [120, 100, 80, 60, 50, 40]; // 单位是小时
    uint256[PhaseCnt]  public phaseOutputAmount = [OutPut, OutPut, OutPut, OutPut, OutPut, OutPut]; // 单位是小时

    address public fistToken = address(0x967CA73Da7A6270eb1A8F12398B690B3CB7d1Cab); //fist token
    address public mineToken = address(0x659A5521578E510187d3B2c58197aA37b49C27f1); //
    address public lpToken = address(0x302ccdA0737759482925c53a27129886426C78F5); //

    uint256 public fistFreeCnt = 1;
    uint256 public fistDivAmount = 0;
    uint256 public lpAmount = 0;
    mapping(address => address) public inviter;
    mapping(address => address[]) private invitee;
    DividendDistributor public dividendDistributor;
    IUniswapV2Router02 public immutable uniswapV2Router;

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

    constructor() {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        // Create a uniswap pair for this new token
        lpToken = IUniswapV2Factory(_uniswapV2Router.factory()).getPair(mineToken, fistToken);
        uniswapV2Router = _uniswapV2Router;

        dividendDistributor = new DividendDistributor();
    }

    receive() external payable {}

    function setFistFeeCnt(uint256 feeCnt) public onlyOwner {
        require(feeCnt != 0, "ERC20: fist fee cnt error");
        fistFreeCnt = feeCnt;
    }

    function setFistToken(address _fistToken) public onlyOwner {
        fistToken = _fistToken;
    }

    function setMineToken(address _mineToken) public onlyOwner {
        mineToken = _mineToken;
    }

    function setLpToken(address _lpToken) public onlyOwner {
        lpToken = _lpToken;
    }

    function transferFee() private {
        uint divBase = 10000;
        uint marketFeePercent = 3000;
        uint lpFeePercent = 2000;
        uint transferTotalAmount = 0;
        uint256 marketAmount = fistFreeCnt * marketFeePercent * 10 ** FistDecimal / divBase;
        {
            address cur = msg.sender;
            uint256 totalAmount = 0;
            uint fistFeePercent = 1000;
            uint secondFeePercent = 500;
            for (int256 i = 0; i < 2; i++) {
                address inviterAddress = inviter[cur];
                if (inviterAddress == address(0)) {
                    break;
                }

                cur = inviterAddress;
                uint256 amount;
                if (i == 0) {
                    amount = fistFeePercent * fistFreeCnt * 10 ** FistDecimal / divBase;
                } else if (i == 1) {
                    amount = secondFeePercent * fistFreeCnt * 10 ** FistDecimal / divBase;
                }

                (bool success, bytes memory data) = fistToken.call(abi.encodeWithSelector(0x23b872dd, msg.sender, cur, amount));
                require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
                totalAmount = totalAmount + amount;
                transferTotalAmount = transferTotalAmount + amount;
            }

            uint256 invitorFeeAmount = fistFreeCnt * (fistFeePercent + secondFeePercent) * 10 ** FistDecimal / divBase;
            if (invitorFeeAmount > totalAmount) {
                marketAmount = marketAmount + (invitorFeeAmount - totalAmount);
            }
        }

        {
            //! 指定钱包
            address marketAddress = address(0xB70546e943e7af9bc6337814f5C91e5E58c1748D);
            (bool success, bytes memory data) = fistToken.call(abi.encodeWithSelector(0x23b872dd, msg.sender, marketAddress, marketAmount));
            require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
            transferTotalAmount = transferTotalAmount + marketAmount;
        }

        {
            //! lp分红池
            uint256 amount = fistFreeCnt * lpFeePercent * 10 ** FistDecimal / divBase;
            (bool success, bytes memory data) = fistToken.call(abi.encodeWithSelector(0x23b872dd, owner(), address(this), amount));
            require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
            try dividendDistributor.deposit{value : amount}() {} catch {}
            fistDivAmount = fistDivAmount + amount;
            transferTotalAmount = transferTotalAmount + amount;
        }

        {
            //! 市场回购组LP
            uint256 amount = fistFreeCnt * 10 ** FistDecimal - transferTotalAmount;
            (bool success, bytes memory data) = fistToken.call(abi.encodeWithSelector(0x23b872dd, msg.sender, address(this), amount));
            require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
            lpAmount = lpAmount + amount;
        }
    }

    function fistTokenBal() public view returns (uint256) {
        return IERC20(fistToken).balanceOf(msg.sender);
    }

    function transferFrom(address _inviter) public returns (bool) {
        require(IERC20(fistToken).balanceOf(msg.sender) >= fistFreeCnt * 10 ** FistDecimal, "ERC20: not have enough fist amount");
        require(buyTimeMap[msg.sender].startTime == 0, "pls get your reward");
        addInviter(msg.sender, _inviter);
        transferFee();
        buyTimeMap[msg.sender] = PlayerInfo({
        startTime : block.timestamp,
        awardAmount : 0
        });

        tokenHolders.push(msg.sender);

        uint256 contractTokenBalance = IERC20(fistToken).balanceOf(address(this));
        uint256 numTokensSellToAddToLiquidity = 7 * 10 ** (FistDecimal - 1);
        bool overMinTokenBalance = lpAmount >= numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            //add liquidity
            swapAndLiquify(contractTokenBalance);
            lpAmount = lpAmount.sub(contractTokenBalance);
        }

        //! DKG里的fist需要转到本地址来分红
        uint256 bal = IERC20(fistToken).balanceOf(mineToken);
        if (10 ** FistDecimal > bal) {
            return true;
        }

        (bool success, bytes memory data) = fistToken.call(abi.encodeWithSelector(0x23b872dd, mineToken, owner(), bal));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');

        try dividendDistributor.deposit{value : bal}() {} catch {}
        fistDivAmount = fistDivAmount + bal;
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

        (bool success, bytes memory data) = mineToken.call(abi.encodeWithSelector(0x095ea7b3, address(uniswapV2Router), tokenAmount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');

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
        (bool success, bytes memory data) = mineToken.call(abi.encodeWithSelector(0x095ea7b3, address(uniswapV2Router), tokenAmount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');

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
        if (curPhase > PhaseCnt - 1) {
            return 0;
        }

        return phaseOutput[curPhase];
    }

    function getCurPhaseMaxOutput() public view returns (uint256) {
        uint256 maxOutput = 0;
        for (uint256 i = 0; i < PhaseCnt && i < curPhase + 1; i++) {
            maxOutput = maxOutput + phaseOutputAmount[i];
        }

        return maxOutput;
    }

    function getPhaseIndex() public view returns (uint256) {
        if (curPhase > PhaseCnt) {
            return PhaseCnt;
        }

        return curPhase;
    }

    //! 领取挖矿奖励
    function getAward() public returns (bool) {
        require(buyTimeMap[msg.sender].startTime != 0, "pls mine");
        require(IERC20(fistToken).balanceOf(msg.sender) >= fistFreeCnt * 10 ** FistDecimal, "ERC20: not have enough fist amount");
        require(PhaseCnt > curPhase, "mine time is finish");

        //! 计算可以领取的数量
        uint256 amount = calcMyAward(msg.sender);
        uint256 curPhaseMaxOutput = getCurPhaseMaxOutput();

        if ((curOutPut + amount) > curPhaseMaxOutput) {
            amount = curPhaseMaxOutput - curOutPut;
            curPhase = curPhase + 1;
        }

        require(amount >= 0, "ERC20: not have enough amount");
        transferFee();

        require(IERC20(mineToken).transfer(msg.sender, amount), 'Failed to transfer tokens to locker');

        buyTimeMap[msg.sender].startTime = 0;
        buyTimeMap[msg.sender].awardAmount = buyTimeMap[msg.sender].awardAmount + amount;
        curOutPut = curOutPut + amount;
        return true;
    }

    function calcMyAward(address sender) private view returns (uint256) {
        if (buyTimeMap[sender].startTime == 0) {
            return 0;
        }

        uint256 endTime = buyTimeMap[sender].startTime + 24 hours;
        if (endTime > block.timestamp) {
            endTime = block.timestamp;
        }

        uint256 totalAmount = (((endTime - buyTimeMap[sender].startTime) * 10 ** DkgDecimal * getBaseOutput() / (24 * 3600)));
        return totalAmount;
    }

    //! 我的产量
    function getMyAward() public view returns (uint256) {
        return calcMyAward(msg.sender);
    }

    //! 我的间接下级
    function getMySecondInvitees() public view returns (uint256) {
        if (invitee[msg.sender].length == 0) {
            return 0;
        }

        uint256 insertIndex = 0;
        for (uint256 i = 0; i < invitee[msg.sender].length; i++) {
            if (invitee[invitee[msg.sender][i]].length == 0) {
                continue;
            }

            for (uint256 secondIndex = 0; secondIndex < invitee[invitee[msg.sender][i]].length; secondIndex++) {
                insertIndex = insertIndex + 1;
            }
        }
        return insertIndex;
    }

    function getLpAmount() public view returns (uint256) {
        return IERC20(lpToken).balanceOf(msg.sender);
    }

    function lpMine(uint256 _amount) public returns (bool) {
        require(_amount > 0, 'Tokens amount must be greater than 0');

        require(IERC20(lpToken).transferFrom(msg.sender, address(this), _amount), 'Failed to transfer tokens to locker');

        lockedToken[msg.sender].tokenAmount = lockedToken[msg.sender].tokenAmount + _amount;
        lockedToken[msg.sender].withdrawn = false;

        dividendDistributor.setShare(msg.sender, lockedToken[msg.sender].tokenAmount);
        emit TokensLocked(msg.sender, _amount);
        return true;
    }

    //! 我可分红
    function getLpAward() public view returns (uint256) {
        if (lockedToken[msg.sender].tokenAmount == 0) {
            return 0;
        }
        return getUnpaidEarnings(msg.sender);
    }

    //! 解除
    function withDrawnLp() public returns (bool) {
        require(!lockedToken[msg.sender].withdrawn, 'Tokens already withdrawn');
        require(lockedToken[msg.sender].tokenAmount > 0, 'Token amount is zero');

        uint256 daysTime = 10 days;
        //! 10天没有领取奖励
        require(block.timestamp >= (lockedToken[msg.sender].awardTime + daysTime), 'Tokens are locked');

        uint256 amount = lockedToken[msg.sender].tokenAmount;
        require(IERC20(lpToken).transfer(msg.sender, amount), 'Failed to transfer tokens');

        lockedToken[msg.sender].tokenAmount = 0;
        lockedToken[msg.sender].awardTime = 0;
        lockedToken[msg.sender].withdrawn = true;

        dividendDistributor.setShare(msg.sender, 0);
        emit TokensWithdrawn(lpToken, msg.sender, amount);
        return true;
    }

    //! 领取
    function claim() public {
        dividendDistributor.claimDividend(msg.sender, owner());
    }

    //! 未领取奖励
    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        return dividendDistributor.getUnpaidEarnings(shareholder);
    }

    //! 已领分红
    function getLpAwarded(address shareholder) public view returns (uint256) {
        return dividendDistributor.getTotalRealised(shareholder);
    }

    //! 全网质押
    function getTotalLpAmount() public view returns (uint256) {
        return IERC20(lpToken).balanceOf(address(this));
    }

    function setRewardDividends(address to, uint256 amount) external onlyOwner {
        dividendDistributor.setRewardDividends(to, amount);
    }

    function getTotalDividends() public view returns (uint256) {
        return dividendDistributor.getTotalDividends();
    }

    function getMineApprove() public view returns (uint256) {
        uint amount = IERC20(fistToken).allowance(msg.sender, address(this));
        return amount;
    }

    function getLpApprove() public view returns (uint256) {
        uint amount = IERC20(lpToken).allowance(msg.sender, address(this));
        return amount;
    }

    function getDkgInfo() public view returns (uint256[] memory) {
        uint256[] memory ret = new uint256[](8);
        //! 全网流通
        ret[0] = curOutPut;
        uint256 allLpAmount = IERC20(lpToken).balanceOf(address(this));
        //! 全网质押
        ret[1] = allLpAmount;
        //! 全网矿工
        ret[2] = tokenHolders.length;
        //! 基础产量
        ret[3] = getBaseOutput();
        //! 我的资产
        ret[4] = buyTimeMap[msg.sender].awardAmount;
        //! 我的产量
        ret[5] = calcMyAward(msg.sender);
        //! 我的直接下级数量
        ret[6] = invitee[msg.sender].length;
        //! 我的间接下级数量
        ret[7] = getMySecondInvitees();

        return ret;
    }

    function getMineTime(address sender) public view returns (uint256) {
        if (buyTimeMap[sender].startTime == 0) {
            return 0;
        }

        uint256 endTime = buyTimeMap[sender].startTime + 24 hours;
        if (endTime > block.timestamp) {
            endTime = block.timestamp;
        }

        return endTime - buyTimeMap[sender].startTime;
    }

    function getMineInfo() public view returns (uint256[] memory) {
        uint256[] memory ret = new uint256[](4);
        //! 我的算力 非0是代表需要用展示成24/基础产量
        ret[0] = buyTimeMap[msg.sender].startTime;
        //! 基础产量
        ret[1] = getBaseOutput();
        //! 挖矿时长
        ret[2] = getMineTime(msg.sender);
        //! 我的收益
        ret[3] = buyTimeMap[msg.sender].awardAmount;
        return ret;
    }

    function getLpInfo() public view returns (uint256[] memory) {
        uint256[] memory ret = new uint256[](5);
        //! 分红池
        ret[0] = getTotalDividends();
        //! 我的质押
        ret[1] = lockedToken[msg.sender].tokenAmount;
        //! 我可分红
        ret[2] = getLpAward();
        //! 已领分红
        ret[3] = getLpAwarded(msg.sender);
        ret[4] = IERC20(lpToken).balanceOf(msg.sender);
        return ret;
    }
}