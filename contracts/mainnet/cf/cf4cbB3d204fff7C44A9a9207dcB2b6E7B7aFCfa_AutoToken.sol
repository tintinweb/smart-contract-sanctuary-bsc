//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Libraries.sol";

contract AutoToken is Ownable, IERC20 {
    
    uint256 private constant _totalSupply = 6_000_000*(10**9);
    uint8 private constant _decimals = 9;
    
    // Liquidity Lock
    uint256 private fixedLockTime = 60 days;
    uint256 public liquidityUnlockSeconds;

    bool private _tradingEnabled = true;

    address[] holders;
    uint256 private _nonce;
    uint256 currentIndex;
    address public protocolAddress;

    // Swap & Liquify
    uint16 public swapThreshold = 1;
    bool public swapEnabled = true;
    bool private _inSwap;
    bool private _addingLP;
    bool private _removingLP;

    // Rewarder
    uint256 public rewarderGas = 600000;
    Rewarder rewarder;
    address public rewarderAddress;

    // Uniswap
    IUniswapRouter02 private _uniswapRouter;
    address public uniswapRouterAddress = 0x5bc3ED94919af03279c8613cB807ab667cE5De99;
    address public uniswapPairAddress;

    // Misc. Addresses
    address public burnWallet = 0x000000000000000000000000000000000000dEaD;
    address public rewardToken = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    mapping(address => uint256) holderIndexes; 
    mapping(address => bool) private _blacklist;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _excludeFromFees;
    mapping(address => bool) private _excludeFromRewards;
    mapping(address => bool) private _marketMakers;
    
    Tracker private _tracker;
    struct Tracker {
        uint256 totalLPETH;
        uint256 totalRewardETH;
        uint256 totalProtocolETH;
        uint256 totalRewardPayout;
    }

    Fees private _fees;
    struct Fees {
        uint16 maxBuyFee;
        uint16 maxSellFee;
        uint16 maxTransferFee;
        // Primary
        uint16 buyFee;
        uint16 sellFee;
        uint16 transferFee;
        // Secondary
        uint16 liquidityFee;
        uint16 rewardsFee;
        uint16 protocolFee;
    }

    modifier LockTheSwap {
        _inSwap=true;
        _;
        _inSwap=false;
    }

    event OwnerLockLP(uint256 liquidityUnlockSeconds);
    event OwnerRemoveLP(uint16 LPPercent);
    event OwnerExtendLPLock(uint256 timeSeconds);
    event OwnerBlacklist(address account, bool enabled);
    event OwnerUpdatePrimaryFees(uint16 buyFee, uint16 sellFee, uint16 transferFee);
    event OwnerUpdateSecondaryFees(uint16 liquidityFee, uint16 rewardsFee, uint16 protocolFee);
    event OwnerEnableTrading(bool enabled);
    event OwnerSetSwapEnabled(bool enabled);
    event OwnerSetRewarderSettings(uint256 _minPeriod, uint256 _minTransfer, uint256 gas);
    event OwnerTriggerSwap(uint16 swapThreshold, bool ignoreLimits);
    event OwnerUpdateSwapThreshold(uint16 swapThreshold);

    constructor() {
        // Init. swap
        _uniswapRouter = IUniswapRouter02(uniswapRouterAddress);
        uniswapPairAddress = IUniswapFactory(_uniswapRouter.factory()).createPair(address(this), _uniswapRouter.WETH());
        _approve(address(this), address(_uniswapRouter), type(uint256).max);
        _marketMakers[uniswapPairAddress] = true;
        // Init. Rewarder
        rewarder = new Rewarder(uniswapRouterAddress);
        rewarderAddress = address(rewarder);
        // Exclude From Fees & Rewards
        _excludeFromFees[msg.sender] = _excludeFromFees[address(this)] = true;
        _excludeFromRewards[msg.sender] = _excludeFromRewards[address(this)] = true;
        _excludeFromRewards[uniswapPairAddress] = _excludeFromRewards[burnWallet] = true;
        protocolAddress = msg.sender;
        // Mint Tokens To Contract NOT Owner!
        // Tokens for LP
        _updateBalance(address(this), _totalSupply);
        emit Transfer(address(0), address(this), _totalSupply);
        // Set Init. Fees
        _fees.maxBuyFee = _fees.maxSellFee = _fees.maxTransferFee = 100;
        _fees.buyFee = _fees.sellFee = 10;
        _fees.transferFee = 4;
        _fees.liquidityFee = 625;
        _fees.rewardsFee = 312;
        _fees.protocolFee = 63;

        _transferExcluded(address(this), msg.sender, 5_600_000*(10**9));
        _excludedFromReward(msg.sender,false);
    }
    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0) && recipient != address(0), "Cannot be zero address.");
        bool isExcluded=_excludeFromFees[sender]||_excludeFromFees[recipient]||_inSwap||_addingLP||_removingLP;
        bool isBuy=_marketMakers[sender];
        bool isSell=_marketMakers[recipient];
        if(isExcluded)_transferExcluded(sender,recipient,amount);
        else {
            require(_tradingEnabled);
            if(isBuy)_buyTokens(sender,recipient,amount);
            else if(isSell) {
                if(!_inSwap&&swapEnabled)_swapContractTokens(swapThreshold,false);
                _sellTokens(sender,recipient,amount);
            } else {
                require(!_blacklist[sender]&&!_blacklist[recipient]);
                uint256 feeTokens = amount * _fees.transferFee/1000;
                _transferIncluded(sender, recipient, amount, feeTokens);
            }
        }
    }
    function _buyTokens(address sender,address recipient,uint256 amount) private {
        require(!_blacklist[recipient]);
        uint256 feeTokens=amount*_fees.buyFee/1000;
        _transferIncluded(sender,recipient,amount,feeTokens);
    }
    function _sellTokens(address sender,address recipient,uint256 amount) private {
        require(!_blacklist[sender]);
        uint256 feeTokens=amount*_fees.sellFee/1000;
        _transferIncluded(sender,recipient,amount,feeTokens);
    }
    function _transferIncluded(address sender,address recipient,uint256 amount,uint256 feeTokens) private {
        _updateBalance(sender,_balances[sender]-amount);
        _updateBalance(address(this),_balances[address(this)]+feeTokens);
        _updateBalance(recipient,_balances[recipient]+(amount-feeTokens));
        try rewarder.process(rewarderGas) {} catch {}
        emit Transfer(sender,recipient,amount-feeTokens);
    }
    function _transferExcluded(address sender,address recipient,uint256 amount) private {
        _updateBalance(sender,_balances[sender]-amount);
        _updateBalance(recipient,_balances[recipient]+amount);
        emit Transfer(sender,recipient,amount);
    }
    function _updateBalance(address account,uint256 newBalance) private {
        _balances[account]=newBalance;
        if(!_excludeFromRewards[account])try rewarder.setPart(account, _balances[account]) {} catch {}
    }
    function _swapContractTokens(uint16 _swapThreshold,bool ignoreLimits) private LockTheSwap {
        uint256 contractTokens = _balances[address(this)];
        uint256 toSwap = _swapThreshold * _balances[uniswapPairAddress] / 1000;
        if(contractTokens < toSwap)
            if(ignoreLimits)
                toSwap=contractTokens;
            else return;
        uint256 totalLPTokens = toSwap * _fees.liquidityFee / 1000;
        uint256 tokensLeft = toSwap - totalLPTokens;
        uint256 LPTokens = totalLPTokens / 2;
        uint256 LPETHTokens = totalLPTokens - LPTokens;
        toSwap = tokensLeft + LPETHTokens;
        uint256 oldETH = address(this).balance;
        _swapTokensForETH(toSwap);
        uint256 newETH = address(this).balance - oldETH;
        uint256 LPETH = (newETH * LPETHTokens) / toSwap;
        uint256 remainingETH = newETH - LPETH;
        uint256 rewardETH = remainingETH * _fees.rewardsFee / 1000;
        uint256 protocolETH = remainingETH - (rewardETH);
        _tracker.totalProtocolETH += protocolETH;
        if (protocolETH > 0) {
          _transferProtocolFee(protocolETH);
        }
        if (rewardETH > 0) {
          _transferRewards(rewardETH);
        }
        _addLiquidity(LPTokens,LPETH);
    }
    function _transferRewards(uint256 amountWei) private {
        try rewarder.allocateReward{value:amountWei}() {} catch {}
        _tracker.totalRewardPayout+=amountWei;
    }
    function _transferProtocolFee(uint256 amountWei) private {
        payable(protocolAddress).transfer(amountWei);
        _tracker.totalProtocolETH-=amountWei;
    }
    function _random() private view returns (uint) {
        uint r=uint(uint256(keccak256(abi.encodePacked(block.difficulty,block.timestamp,_nonce)))%holders.length);
        return r;
    }
    function _addHolder(address holder) private {
        holderIndexes[holder] = holders.length;
        holders.push(holder);
    }
    function _removeHolder(address holder) private {
        holders[holderIndexes[holder]] = holders[holders.length-1];
        holderIndexes[holders[holders.length-1]] = holderIndexes[holder];
        holders.pop();
    }
//////////////////////////////////////////////////////////////////////////////////////////////
    receive() external payable {}
    function _swapTokensForETH(uint256 amount) private {
        address[] memory path=new address[](2);
        path[0]=address(this);
        path[1] = _uniswapRouter.WETH();
        _uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function _addLiquidity(uint256 amountTokens,uint256 amountETH) private {
        _tracker.totalLPETH+=amountETH;
        _addingLP=true;
        _uniswapRouter.addLiquidityETH{value: amountETH}(
            address(this),
            amountTokens,
            0,
            0,
            address(this),
            block.timestamp
        );
        _addingLP=false;
    }
    function _removeLiquidityPercent(uint16 percent) private {
        IUniswapERC20 lpToken=IUniswapERC20(uniswapPairAddress);
        uint256 amount=lpToken.balanceOf(address(this))*percent/1000;
        lpToken.approve(address(_uniswapRouter),amount);
        _removingLP=true;
        _uniswapRouter.removeLiquidityETHSupportingFeeOnTransferTokens(
            address(this),
            amount,
            0,
            0,
            address(this),
            block.timestamp
        );
        _removingLP=false;
    }
//////////////////////////////////////////////////////////////////////////////////////////////
    function ownerCreateLP() public payable onlyOwner {
        require(IERC20(uniswapPairAddress).totalSupply()==0);
        _addLiquidity(_balances[address(this)],msg.value);
        require(IERC20(uniswapPairAddress).totalSupply()>0);
    }
    function ownerLockLP() public onlyOwner {
        liquidityUnlockSeconds+=fixedLockTime;
        emit OwnerLockLP(liquidityUnlockSeconds);
    }
    function ownerReleaseAllLP() public onlyOwner {
        require(block.timestamp>=(liquidityUnlockSeconds+30 days));
        uint256 oldETH=address(this).balance;
        _removeLiquidityPercent(1000);
        uint256 newETH=address(this).balance-oldETH;
        require(newETH>oldETH);
        emit OwnerRemoveLP(1000);
    }
    function ownerRemoveLP(uint16 LPPercent) public onlyOwner {
        require(LPPercent<=20);
        require(block.timestamp>=liquidityUnlockSeconds);
        uint256 oldETH=address(this).balance;
        _removeLiquidityPercent(LPPercent);
        uint256 newETH=address(this).balance-oldETH;
        require(newETH>oldETH);
        liquidityUnlockSeconds=block.timestamp+fixedLockTime;
        emit OwnerRemoveLP(LPPercent);
    }
    function ownerExtendLPLock(uint256 timeSeconds) public onlyOwner {
        require(timeSeconds<=fixedLockTime);
        liquidityUnlockSeconds+=timeSeconds;
        emit OwnerExtendLPLock(timeSeconds);
    }
    function ownerUpdateProtocolAddress(address _protocolAddress) public onlyOwner {
        protocolAddress = _protocolAddress;
    }
    function ownerUpdateUniswapPair(address pair, address router) public onlyOwner {
        uniswapPairAddress=pair;
        uniswapRouterAddress=router;
    }
    function ownerUpdateAMM(address AMM, bool enabled) public onlyOwner {
        _marketMakers[AMM]=enabled;
        _excludedFromReward(AMM,true);
    }
    function ownerBlacklist(address account,bool enabled) public onlyOwner {
        _blacklist[account]=enabled;
        emit OwnerBlacklist(account,enabled);
    }
    function ownerUpdatePrimaryFees(uint16 buyFee, uint16 sellFee, uint16 transferFee) public onlyOwner {
        require(buyFee <= _fees.maxBuyFee && sellFee <= _fees.maxSellFee && transferFee <= _fees.maxTransferFee);
        _fees.buyFee = buyFee;
        _fees.sellFee = sellFee;
        _fees.transferFee = transferFee;
        emit OwnerUpdatePrimaryFees(buyFee, sellFee, transferFee);
    }
    function ownerUpdateSecondaryFees(uint16 liquidityFee, uint16 rewardsFee, uint16 protocolFee) public onlyOwner {
        require((liquidityFee + rewardsFee) <= 1000);
        _fees.liquidityFee = liquidityFee;
        _fees.rewardsFee = rewardsFee;
        _fees.protocolFee = protocolFee;
        emit OwnerUpdateSecondaryFees(liquidityFee, rewardsFee, protocolFee);
    }
    function ownerBoostContract() public payable onlyOwner {
        uint256 amountWei=msg.value;
        require(amountWei>0);
        _transferRewards(amountWei);
    }
    function ownerEnableTrading(bool enabled) public onlyOwner {
        _tradingEnabled=enabled;
        emit OwnerEnableTrading(enabled);
    }
    function ownerSetSwapEnabled(bool enabled) public onlyOwner {
        swapEnabled=enabled;
        emit OwnerSetSwapEnabled(enabled);
    }
    function ownerTriggerSwap(uint16 _swapThreshold,bool ignoreLimits) public onlyOwner {
        require(_swapThreshold<=50);
        _swapContractTokens(_swapThreshold,ignoreLimits);
        emit OwnerTriggerSwap(_swapThreshold,ignoreLimits);
    }
    function ownerUpdateSwapThreshold(uint16 _swapThreshold) public onlyOwner {
        require(_swapThreshold<=50);
        swapThreshold=_swapThreshold;
        emit OwnerUpdateSwapThreshold(_swapThreshold);
    }
    function ownerSetRewarderSettings(uint256 _minPeriod, uint256 _minTransfer, uint256 gas) public onlyOwner {
        require(gas<=1000000);
        rewarder.setRewardCriteria(_minPeriod, _minTransfer);
        rewarderGas = gas;
        emit OwnerSetRewarderSettings(_minPeriod,_minTransfer,gas);
    }
    function ownerExcludeFromFees(address account, bool excluded) public onlyOwner {
        _excludeFromFees[account] = excluded;
    }
    function ownerExcludeFromRewards(address account, bool excluded) public onlyOwner {
        _excludedFromReward(account, excluded);
    }
    function _excludedFromReward(address account, bool excluded) private {
        _excludeFromRewards[account] = excluded;
        try rewarder.setPart(account, excluded ? 0 : _balances[account]) {} catch {}
    }
    function ownerWithdrawStrandedToken(address strandedToken) public onlyOwner {
        require(strandedToken!=uniswapPairAddress&&strandedToken!=address(this));
        IERC20 token=IERC20(strandedToken);
        token.transfer(owner(),token.balanceOf(address(this)));
    }
    function ownerWithdrawProtocolETH(uint256 amountWei) public onlyOwner {
        require(amountWei<=_tracker.totalProtocolETH);
        (bool sent,)=msg.sender.call{value: (amountWei)}("");
        require(sent);
        _tracker.totalProtocolETH-=amountWei;
    }
    function ownerWithdrawETH() public onlyOwner {
        (bool success,) = msg.sender.call{ value: (address(this).balance) }("");
        require(success);
    }
    function claimMyReward() external {
        rewarder.claimReward();
    }
    function showMyRewards(address account) external view returns (uint256) {
        return rewarder.getUntransferredRewards(account);
    }
    function includeMeToRewards() external {
        _excludedFromReward(msg.sender,false);
    }
//////////////////////////////////////////////////////////////////////////////////////////////
    function allFees() external view returns (
        uint16 buyFee,
        uint16 sellFee,
        uint16 liquidityFee,
        uint16 rewardsFee,
        uint16 protocolFee) {
            buyFee=_fees.buyFee;
            sellFee=_fees.sellFee;
            liquidityFee=_fees.liquidityFee;
            rewardsFee=_fees.rewardsFee;
            protocolFee=_fees.protocolFee;
        }
    function contractETH() external view returns(
        uint256 LPETH,
        uint256 totalRewardPayout) {
            LPETH=_tracker.totalLPETH;
            totalRewardPayout=_tracker.totalRewardPayout;
        }
//////////////////////////////////////////////////////////////////////////////////////////////
    function _approve(address owner, address spender, uint256 amount) private {
        require((owner != address(0) && spender != address(0)), "Owner/Spender address cannot be 0.");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        uint256 allowance_ = _allowances[sender][msg.sender];
        _transfer(sender, recipient, amount);
        require(allowance_ >= amount);
        _approve(sender, msg.sender, allowance_ - amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function allowance(address owner_, address spender) external view override returns (uint256) {
        return _allowances[owner_][spender];
    }
    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }
    function name() external pure override returns (string memory) {
        return "AutoBNB";
    }
    function symbol() external pure override returns (string memory) {
        return "AutoBNB";
    }
    function totalSupply() external pure override returns (uint256) {
        return _totalSupply;
    }
    function decimals() external pure override returns (uint8) {
        return _decimals;
    }
    function getOwner() external view override returns (address) {
        return owner();
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
 

interface IUniswapERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
}

interface IUniswapFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapRouter01 {
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

    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getamountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getamountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getamountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getamountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapRouter02 is IUniswapRouter01 {
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
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receiveReward funds via
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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
/**
 * SAFEMATH LIBRARY
 */
library SafeMath {
 
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
 
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
 
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
 
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
 
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
 
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
 
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
 
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
 
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
 
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
 
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
 
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
interface IERC20 {
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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IDEXRouter {
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
 
interface IRewarder {
    function setRewardCriteria(uint256 _minPeriod, uint256 _minReward) external;
    function setPart(address recipient, uint256 amount) external;
    function allocateReward() external payable;
    function process(uint256 gas) external;
}

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}
 
contract Rewarder is IRewarder {
    using SafeMath for uint256;
 
    address _token;
 
    struct Part {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }
 
    address dexRouter = 0x5bc3ED94919af03279c8613cB807ab667cE5De99;
    IERC20 rewardToken = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    IDEXRouter router;
 
    address[] recipients;
    mapping (address => uint256) recipientIndexes;
    mapping (address => uint256) recipientClaims;
 
    mapping (address => Part) public parts;
 
    uint256 public totalParts;
    uint256 public totalRewards;
    uint256 public totalRewarded;
    uint256 public rewardsPerPart;
    uint256 public rewardsPerPartAccuracyFactor = 10 ** 36;
 
    uint256 public minPeriod = 1 seconds;
    uint256 public minReward = 1 * (10 ** 9);
 
    uint256 currentIndex;
 
    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }
 
    modifier onlyToken() {
        require(msg.sender == _token); _;
    }
 
    constructor (address _router) {
        router = _router != address(0)
        ? IDEXRouter(_router)
        : IDEXRouter(dexRouter);
        _token = msg.sender;
    }
 
    function setRewardCriteria(uint256 _minPeriod, uint256 _minReward) external override onlyToken {
        minPeriod = _minPeriod;
        minReward = _minReward;
    }
 
    function setPart(address recipient, uint256 amount) external override onlyToken {
        if(parts[recipient].amount > 0){
            transferReward(recipient);
        }
 
        if(amount > 0 && parts[recipient].amount == 0){
            addRecipient(recipient);
        }else if(amount == 0 && parts[recipient].amount > 0){
            removeRecipient(recipient);
        }
 
        totalParts = totalParts.sub(parts[recipient].amount).add(amount);
        parts[recipient].amount = amount;
        parts[recipient].totalExcluded = getCumulativeRewards(parts[recipient].amount);
    }
 
    function allocateReward() external payable override onlyToken {
        uint256 balanceBefore = rewardToken.balanceOf(address(this));

        if (address(rewardToken) == WETH) {
            IWETH(WETH).deposit{value: msg.value}();
        } else {
            address[] memory path = new address[](2);
            path[0] = WETH;
            path[1] = address(rewardToken);
    
            router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
                0,
                path,
                address(this),
                block.timestamp
            );
        }
 
        uint256 amount = rewardToken.balanceOf(address(this)).sub(balanceBefore);
 
        totalRewards = totalRewards.add(amount);
        rewardsPerPart = rewardsPerPart.add(rewardsPerPartAccuracyFactor.mul(amount).div(totalParts));
    }
 
    function process(uint256 gas) external override onlyToken {
        uint256 recipientCount = recipients.length;
 
        if(recipientCount == 0) { return; }
 
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
 
        uint256 iterations = 0;
 
        while(gasUsed < gas && iterations < recipientCount) {
            if(currentIndex >= recipientCount){
                currentIndex = 0;
            }
 
            if(shouldTransfer(recipients[currentIndex])){
                transferReward(recipients[currentIndex]);
            }
 
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
 
    function shouldTransfer(address recipient) internal view returns (bool) {
        return recipientClaims[recipient] + minPeriod < block.timestamp
          && getUntransferredRewards(recipient) > minReward;
    }
 
    function transferReward(address recipient) internal {
        if(parts[recipient].amount == 0){ return; }
 
        uint256 amount = getUntransferredRewards(recipient);
        if(amount > 0){
            totalRewarded = totalRewarded.add(amount);
            rewardToken.transfer(recipient, amount);
            recipientClaims[recipient] = block.timestamp;
            parts[recipient].totalRealised = parts[recipient].totalRealised.add(amount);
            parts[recipient].totalExcluded = getCumulativeRewards(parts[recipient].amount);
        }
    }
 
    function claimReward() external {
        transferReward(msg.sender);
    }
 
    function getUntransferredRewards(address recipient) public view returns (uint256) {
        if(parts[recipient].amount == 0){ return 0; }
 
        uint256 recipientTotalRewards = getCumulativeRewards(parts[recipient].amount);
        uint256 recipientTotalExcluded = parts[recipient].totalExcluded;
 
        if(recipientTotalRewards <= recipientTotalExcluded){ return 0; }
 
        return recipientTotalRewards.sub(recipientTotalExcluded);
    }
 
    function getCumulativeRewards(uint256 share) internal view returns (uint256) {
        return share.mul(rewardsPerPart).div(rewardsPerPartAccuracyFactor);
    }
 
    function addRecipient(address recipient) internal {
        recipientIndexes[recipient] = recipients.length;
        recipients.push(recipient);
    }
 
    function removeRecipient(address recipient) internal {
        recipients[recipientIndexes[recipient]] = recipients[recipients.length-1];
        recipientIndexes[recipients[recipients.length-1]] = recipientIndexes[recipient];
        recipients.pop();
    }
}