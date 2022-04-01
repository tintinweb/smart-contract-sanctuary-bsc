// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IDexFactory.sol";
import "./interfaces/IDexRouter.sol";
import "./DividendDistributor.sol";

interface IReflexStaking {
    function stakedTokens(address user) external returns (uint256);
}

contract Reflex is IERC20, Pausable, Ownable {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    string private constant _name = "Reflex Finance V2";
    string private constant _symbol = "REFLEX V2";
    uint8 private constant _decimals = 18;
    uint256 private constant _totalSupply = 100000000 * 10**_decimals;

    address public rewardToken = 0x177Aa3e37ef7c2F087d5C078735519A84609F437;

    uint256 public liquidityFee = 200;
    uint256 public buybackFee = 100;
    uint256 public reflectionFee = 800;
    uint256 public marketingFee = 300;
    uint256 public stakingFee = 100;
    uint256 public totalFee = 1500;
    uint256 public feeDenominator = 10000;

    IDexRouter public router;
    address public uniswapV2Pair;
    address public pair;

    address public marketingFeeReceiver;
    address public stakingFeeReceiver;

    bool public stakingEnabled;
    IReflexStaking public stake;

    bool public swapEnabled = true;
    uint256 public swapThreshold = 1000 * 10**_decimals;

    bool public autoBuybackEnabled = true;
    uint256 public autoBuybackThreshold = 1 * 10**12;
    uint256 public autoBuybackBlockPeriod = 100;
    uint256 public autoBuybackBlockLast = block.number;

    DividendDistributor public distributor;
    uint256 public distributorGas = 500000;

    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isDividendExempt;
    mapping(address => bool) public isBlacklisted;

    constructor(address router_, address _marketingFeeReceiver, address _stakingFeeReceiver) {

      router = IDexRouter(router_);

      // Create a pair for this new token
      pair = IDexFactory(router.factory())
        .createPair(address(address(this)), router.WETH());

      distributor = new DividendDistributor(router_);

      marketingFeeReceiver = _marketingFeeReceiver;
      stakingFeeReceiver = _stakingFeeReceiver;

      isFeeExempt[msg.sender] = true;
      isDividendExempt[pair] = true;
      isDividendExempt[address(this)] = true;
      isDividendExempt[address(0)] = true;

      _allowances[address(this)][address(router)] = _totalSupply;
      _allowances[address(this)][address(pair)] = _totalSupply;

      _balances[msg.sender] = _totalSupply;
      emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() external view virtual returns (string memory) {
      return _name;
    }

    function symbol() external view virtual returns (string memory) {
      return _symbol;
    }

    function decimals() external view virtual returns (uint8) {
      return _decimals;
    }

    function totalSupply() external view virtual override returns (uint256) {
      return _totalSupply;
    }

    function balanceOf(address account) external view virtual override returns (uint256) {
      return _balances[account];
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
      return _allowances[owner][spender];
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
      return !isFeeExempt[sender];
    }

    function transfer(address to, uint256 amount) external virtual override whenNotPaused returns (bool) {
      address owner = _msgSender();
      _transfer(owner, to, amount);
      return true;
    }

    function approve(address spender, uint256 amount) public virtual override whenNotPaused returns (bool) {
      address owner = _msgSender();
      _approve(owner, spender, amount);
      return true;
    }

    function approveMax(address spender) external whenNotPaused returns (bool) {
        return approve(spender, _totalSupply);
    }

    function transferFrom(
      address from,
      address to,
      uint256 amount
    ) external virtual override whenNotPaused returns (bool) {
      address spender = _msgSender();
      _spendAllowance(from, spender, amount);
      _transfer(from, to, amount);
      return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external virtual whenNotPaused returns (bool) {
      address owner = _msgSender();
      _approve(owner, spender, allowance(owner, spender) + addedValue);
      return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual whenNotPaused returns (bool) {
      address owner = _msgSender();
      uint256 currentAllowance = allowance(owner, spender);
      require(currentAllowance >= subtractedValue, "ReflexV2: decreased allowance below zero");
      unchecked {
          _approve(owner, spender, currentAllowance - subtractedValue);
      }

      return true;
    }

    function pauseContract() external virtual onlyOwner {
      _pause();
    }

    function unPauseContract() external virtual onlyOwner {
      _unpause();
    }

    function setFees(
        uint256 _liquidityFee,
        uint256 _buybackFee,
        uint256 _reflectionFee,
        uint256 _marketingFee,
        uint256 _stakingFee,
        uint256 _feeDenominator
    ) public onlyOwner whenNotPaused {
        liquidityFee = _liquidityFee;
        buybackFee = _buybackFee;
        reflectionFee = _reflectionFee;
        marketingFee = _marketingFee;
        stakingFee = _stakingFee;
        totalFee = _liquidityFee + _buybackFee + _reflectionFee + _marketingFee + _stakingFee;
        feeDenominator = _feeDenominator;
        require(
            totalFee < feeDenominator / 4,
            "ReflexV2: Total fee should not be greater than 1/4 of fee denominator"
        );
    }

    function setStakeAddress(address _staking) external onlyOwner whenNotPaused {
      require(_staking != address(0), "ReflexV2: Address cant be zero address");
      stake = IReflexStaking(_staking);
    }

    function setRewardToken(address _reward) external onlyOwner whenNotPaused {
      require(_reward != address(0), "ReflexV2: Address cant be zero address");
      rewardToken = _reward;
    }

    function setMarketingFeeReceiver(address _marketingFeeReceiver) external onlyOwner whenNotPaused {
      require(_marketingFeeReceiver != address(0), "ReflexV2: Address cant be zero address");
      marketingFeeReceiver = _marketingFeeReceiver;
    }

    function setStakingFeeReceiver(address _stakingFeeReceiver) external onlyOwner whenNotPaused {
      require(_stakingFeeReceiver != address(0), "ReflexV2: Address cant be zero address");
      stakingFeeReceiver = _stakingFeeReceiver;
    }

    function setStakingStatus(bool enable) external onlyOwner whenNotPaused {
      stakingEnabled = enable;
    }

    function setAutoBuyBackStatus(bool enable) external onlyOwner whenNotPaused {
      autoBuybackEnabled = enable;
    }

    function setSwapStatus(bool enable) external onlyOwner whenNotPaused {
      swapEnabled = enable;
    }

    function setSwapThreshold(uint256 thresholdInWei) external onlyOwner whenNotPaused {
      require(thresholdInWei > 0, "ReflexV2: Amount must be greater than 0");
      swapThreshold = thresholdInWei;
    }

    function setBuyBackThreshold(uint256 thresholdInWei) external onlyOwner whenNotPaused {
      require(thresholdInWei > 0, "ReflexV2: Amount must be greater than 0");
      autoBuybackThreshold = thresholdInWei;
    }

    function setBuyBackBlockPeriod(uint256 blocks) external onlyOwner whenNotPaused {
      require(blocks > 0, "ReflexV2: Blocks must be greater than 0");
      autoBuybackBlockPeriod = blocks;
    }

    function setDistributorGas(uint256 gas) external onlyOwner whenNotPaused {
      require(gas > 0, "ReflexV2: Gas must be greater than 0");
      distributorGas = gas;
    }

    function includeInFee(address account) external onlyOwner whenNotPaused {
      require(account != address(0), "ReflexV2: Address cant be zero address");
      require(isFeeExempt[account] != false, "ReflexV2: Account is already included in fee");
      isFeeExempt[account] = false;
    }

    function excludeFromFee(address account) external onlyOwner whenNotPaused {
      require(account != address(0), "ReflexV2: Address cant be zero address");
      require(isFeeExempt[account] != true, "ReflexV2: Account is already excluded from fee");
      isFeeExempt[account] = true;
    }

    function includeInBlacklist(address account) external onlyOwner whenNotPaused {
      require(account != address(0), "ReflexV2: Address cant be zero address");
      require(isBlacklisted[account] != true, "ReflexV2: Account is already blacklisted");
      isBlacklisted[account] = true;
    }

    function excludeFromBlacklist(address account) external onlyOwner whenNotPaused {
      require(account != address(0), "ReflexV2: Address cant be zero address");
      require(isBlacklisted[account] != false, "ReflexV2: Account is not blacklisted");
      isBlacklisted[account] = false;
    }

    function includeInDividend(address account) external onlyOwner whenNotPaused {
      require(account != address(0), "ReflexV2: Address cant be zero address");
      require(isDividendExempt[account] != false, "ReflexV2: Account is already included in dividend");
      isDividendExempt[account] = false;
    }

    function excludeFromDividend(address account) external onlyOwner whenNotPaused {
      require(account != address(0), "ReflexV2: Address cant be zero address");
      require(isDividendExempt[account] != true, "ReflexV2: Account is already excluded from dividend");
      isDividendExempt[account] = true;
    }

    function claimDividend() external {
      distributor.claimDividend(msg.sender);
    }

    function getPaidDividend(address shareholder)
      public
      view
      returns (uint256)
    {
      return distributor.getPaidEarnings(shareholder);
    }

    function getUnpaidDividend(address shareholder)
      external
      view
      returns (uint256)
    {
      return distributor.getUnpaidEarnings(shareholder);
    }

    function getTotalDistributedDividend() external view returns (uint256) {
      return distributor.totalDistributed();
    }

    function _transfer(
      address sender,
      address recipient,
      uint256 amount
    ) internal virtual {
      _beforeTokenTransfer(sender, recipient, amount);

      // if staking is enabled, validate the sender balance
      if (stakingEnabled) {
        require(_balances[sender] - amount >= stake.stakedTokens(sender), "ReflexV2: Cannot send staked token");
      }

      if (inSwap) {
        _basicTransfer(sender, recipient, amount);
      } else {
        if (shouldSwapBack()) {
          swapBack();
        }

        if (shouldAutoBuyback()) {
          autoBuyback();
        }

        // transfer amount from sender to recipient
        uint256 fromBalance = _balances[sender];
        require(fromBalance >= amount, "ReflexV2: transfer amount exceeds balance");
        unchecked {
          _balances[sender] = fromBalance - amount;
        }

        // calculate fee, if sender is included in fee
        uint256 amountReceived = shouldTakeFee(sender) && (sender == pair || recipient == pair)
          ? takeFee(sender, amount)
          : amount;
        _balances[recipient] += amountReceived;

        if (!isDividendExempt[sender]) {
          try distributor.setShare(sender, _balances[sender]) {} catch {}
        }
        if (!isDividendExempt[recipient]) {
          try
              distributor.setShare(recipient, _balances[recipient])
          {} catch {}
        }

        try distributor.process(distributorGas) {} catch {}

        emit Transfer(sender, recipient, amountReceived);
      }
    }

    function shouldSwapBack() internal view returns (bool) {
      return
        msg.sender != pair &&
        !inSwap &&
        swapEnabled &&
        _balances[address(this)] >= swapThreshold;
    }

    function shouldAutoBuyback() internal view returns (bool) {
      return
        msg.sender != pair &&
        !inSwap &&
        autoBuybackEnabled &&
        autoBuybackBlockLast + autoBuybackBlockPeriod <= block.number && // After N blocks from last buyback
        address(this).balance >= autoBuybackThreshold;
    }

    function takeFee(
      address sender,
      uint256 amount
    ) internal returns (uint256) {
      uint256 feeAmount = (amount * totalFee) / feeDenominator;

      _balances[address(this)] = _balances[address(this)] + feeAmount;
      emit Transfer(sender, address(this), feeAmount);

      return amount - feeAmount;
    }

    function _basicTransfer(
      address sender,
      address recipient,
      uint256 amount
    ) internal {
      _balances[sender] -= amount;
      _balances[recipient] += amount;
      emit Transfer(sender, recipient, amount);
    }

    function swapBack() internal swapping {
      uint256 stakingTokenAmount = (swapThreshold * stakingFee) / totalFee;
      uint256 liquidityTokenAmount = ((swapThreshold * liquidityFee) / totalFee) / 2;

      uint256 amountToSwap = swapThreshold - stakingTokenAmount - liquidityTokenAmount;

      uint256 balanceBefore = address(this).balance;
      swapTokensForEth(amountToSwap, address(this));
      uint256 amountBNB = address(this).balance - balanceBefore;

      uint256 totalBNBFee = totalFee - (liquidityFee / 2) - stakingFee;

      uint256 liquidityBnbAmount = (amountBNB * (liquidityFee / 2)) / totalBNBFee;
      uint256 reflectionBnbAmount = (amountBNB * reflectionFee) / totalBNBFee;
      uint256 marketingBnbAmount = (amountBNB * marketingFee) / totalBNBFee;

      try distributor.deposit{value: reflectionBnbAmount}() {} catch {}
      payable(marketingFeeReceiver).transfer(marketingBnbAmount);
      _balances[stakingFeeReceiver] = _balances[stakingFeeReceiver] + stakingTokenAmount;
      
      if (liquidityTokenAmount > 0) {
        router.addLiquidityETH{value: liquidityBnbAmount}(
            address(this),
            liquidityTokenAmount,
            0,
            0,
            owner(),
            block.timestamp
        );
      }
    }

    function autoBuyback() internal {
      swapEthForTokens(autoBuybackThreshold, address(0));
      autoBuybackBlockLast = block.number;
    }

    function swapEthForTokens(uint256 amount, address to) internal swapping {
      address[] memory path = new address[](2);
      path[0] = router.WETH();
      path[1] = address(this);

      router.swapExactETHForTokensSupportingFeeOnTransferTokens{
          value: amount
      }(0, path, to, block.timestamp);
    }

    function swapTokensForEth(uint256 tokenAmount, address swapAddress) internal swapping {
      // generate the uniswap pair path of token -> weth
      address[] memory path = new address[](2);
      path[0] = address(this);
      path[1] = router.WETH();

      // make the swap
      router.swapExactTokensForETHSupportingFeeOnTransferTokens(
          tokenAmount,
          0, // accept any amount of ETH
          path,
          swapAddress,
          block.timestamp
      );
    }

    function _approve(
      address owner,
      address spender,
      uint256 amount
    ) internal virtual {
      require(owner != address(0), "ReflexV2: approve from the zero address");
      require(spender != address(0), "ReflexV2: approve to the zero address");

      _allowances[owner][spender] = amount;
      emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
      address owner,
      address spender,
      uint256 amount
    ) internal virtual {
      uint256 currentAllowance = allowance(owner, spender);
      if (currentAllowance != type(uint256).max) {
          require(currentAllowance >= amount, "ReflexV2: insufficient allowance");
          unchecked {
              _approve(owner, spender, currentAllowance - amount);
          }
      }
    }

    function _beforeTokenTransfer(
      address from,
      address to,
      uint256 amount
    ) internal virtual {
      require(from != address(0), "ReflexV2: transfer from the zero address");
      require(to != address(0), "ReflexV2: transfer to the zero address");
      require(amount > 0, "ReflexV2: amount must be greater than 0");

      require(!isBlacklisted[from], "ReflexV2: Sender account is blacklisted");
      require(!isBlacklisted[to], "ReflexV2: Recipient account is blacklisted");
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

interface IDividendDistributor {
    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external;

    function setShare(address shareholder, uint256 amount) external;

    function deposit() external payable;

    function process(uint256 gas) external;

    function claimDividend(address _user) external;

    function getPaidEarnings(address shareholder)
        external
        view
        returns (uint256);

    function getUnpaidEarnings(address shareholder)
        external
        view
        returns (uint256);

    function totalDistributed() external view returns (uint256);
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

interface IDexRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

interface IDexFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "./interfaces/IDividendDistributor.sol";
import "./interfaces/IDexRouter.sol";

contract DividendDistributor is IDividendDistributor {

    address public _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    IERC20Metadata public rewardToken =
        IERC20Metadata(0x177Aa3e37ef7c2F087d5C078735519A84609F437);
    IDexRouter public router;

    address[] public shareholders;
    mapping(address => uint256) public shareholderIndexes;
    mapping(address => uint256) public shareholderClaims;

    mapping(address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10**36;

    uint256 public minPeriod = 1 hours;
    uint256 public minDistribution = 1 * (10**rewardToken.decimals());

    uint256 currentIndex;

    bool initialized;
    modifier initializer() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token);
        _;
    }

    constructor(address router_) {
        _token = msg.sender;
        router = IDexRouter(router_);
    }

    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setShare(address shareholder, uint256 amount)
        external
        override
        onlyToken
    {
        if (shares[shareholder].amount > 0) {
            distributeDividend(shareholder);
        }

        if (amount > 0 && shares[shareholder].amount == 0) {
            addShareholder(shareholder);
        } else if (amount == 0 && shares[shareholder].amount > 0) {
            removeShareholder(shareholder);
        }

        totalShares = totalShares - (shares[shareholder].amount) + (amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(
            shares[shareholder].amount
        );
    }

    function deposit() external payable override onlyToken {
        uint256 balanceBefore = rewardToken.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(rewardToken);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: msg.value
        }(0, path, address(this), block.timestamp);

        uint256 amount = rewardToken.balanceOf(address(this)) - balanceBefore;

        totalDividends = totalDividends + amount;
        dividendsPerShare = (dividendsPerShare + dividendsPerShareAccuracyFactor * amount) / totalShares;
    }

    function process(uint256 gas) external override onlyToken {
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

            gasUsed = gasUsed + (gasLeft - (gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function shouldDistribute(address shareholder)
        internal
        view
        returns (bool)
    {
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
            totalDistributed = totalDistributed + (amount);
            rewardToken.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder]
                .totalRealised + (amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(
                shares[shareholder].amount
            );
        }
    }

    function claimDividend(address _user) external {
        distributeDividend(_user);
    }

    function getPaidEarnings(address shareholder)
        public
        view
        returns (uint256)
    {
        return shares[shareholder].totalRealised;
    }

    function getUnpaidEarnings(address shareholder)
        public
        view
        returns (uint256)
    {
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

        return shareholderTotalDividends - (shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share)
        internal
        view
        returns (uint256)
    {
        return
            (share * dividendsPerShare) / (dividendsPerShareAccuracyFactor);
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
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
    constructor() {
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