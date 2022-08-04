// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import './interfaces/IUniswapV2Factory.sol';
import './interfaces/IUniswapV2Pair.sol';
import './interfaces/IUniswapV2Router01.sol';
import './interfaces/IUniswapV2Router02.sol';
import './interfaces/IFifaSportDao.sol';
import './interfaces/IDividendTracker.sol';

contract FifaSport is ERC20, Ownable {
    mapping(address => uint256) _rBalance;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFees;

    uint256 public liquidityBuyFee;
    uint256 public daoRewardBuyFee;
    uint256 public totalBuyFee;

    uint256 public liquiditySellFee;
    uint256 public treasurySellFee;
    uint256 public sustainabilitySellFee;
    uint256 public rewardSellFee;
    uint256 public firePitSellFee;
    uint256 public totalSellFee;

    uint256 public WtoWtransferFee;
    uint256 public treasuryTransferFee;
    uint256 public liquidityTransferFee;

    bool public walletToWalletTransferWithoutFee;

    IDividendTracker public dividendTracker;
    IFifaSportDao public fifaSportDao;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    address public sustainabilityWallet;
    address public treasuryWallet;
    address public firePitWallet;
    address public usdToken;

    address private DEAD = 0x000000000000000000000000000000000000dEaD;

    uint256 public gasForProcessing = 300000;
    mapping(address => bool) public automatedMarketMakerPairs;

    uint256 private immutable initialSupply;
    uint256 private immutable rSupply;
    uint256 private constant MAX = type(uint256).max;
    uint256 private _totalSupply;

    bool public swapEnabled = true;
    bool private inSwap = false;
    uint256 private swapThreshold;
    uint256 public lastSwapTime;
    uint256 public swapInterval;

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    bool public autoRebase;
    uint256 public rebaseRate;
    uint256 public lastRebasedTime;
    uint256 public rebase_count;
    uint256 private rate;

    event AutoRebaseStatusUptaded(bool enabled);
    event ExcludeFromFees(address indexed account, bool isExcluded);

    event SellFeesUpdated(
        uint256 liquiditySellFee,
        uint256 treasurySellFee,
        uint256 ecosystemSellFee,
        uint256 rewardPoolSellFee,
        uint256 rewardSellFee,
        uint256 burnSellFee,
        uint256 totalSellFee
    );
    event BuyFeesUpdated(
        uint256 liquidityBuyFee,
        uint256 treasuryBuyFee,
        uint256 ecosystemBuyFee,
        uint256 rewardPoolBuyFee,
        uint256 rewardBuyFee,
        uint256 totalBuyFee
    );

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 bnbReceived, uint256 tokensIntoLiqudity);
    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);
    event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress);
    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event SendDividends(uint256 amount);
    event DistributionDaoReward(address _from, address _to, uint256 _amount, uint256 _level);

    event ProcessedDividendTracker(
        uint256 iterations,
        uint256 claims,
        uint256 lastProcessedIndex,
        bool indexed automatic,
        uint256 gas,
        address indexed processor
    );

    constructor(
        address newOwner,
        address _dao,
        address _usdToken,
        address _dividendTracker
    ) ERC20('Fifa Sport', 'FFS') {
        liquidityBuyFee = 2;
        daoRewardBuyFee = 10;
        totalBuyFee = liquidityBuyFee + daoRewardBuyFee;

        treasuryTransferFee = 5;
        liquidityTransferFee = 5;
        WtoWtransferFee = treasuryTransferFee + liquidityTransferFee; // tranfer fee from wallet to wallet

        liquiditySellFee = 4;
        treasurySellFee = 4;
        sustainabilitySellFee = 3;
        rewardSellFee = 2;
        firePitSellFee = 2;
        totalSellFee = liquiditySellFee + treasurySellFee + sustainabilitySellFee + rewardSellFee + firePitSellFee;

        treasuryWallet = 0x11548954808a57B8c87bc86f34b98cBfA45f2968;
        sustainabilityWallet = 0x364BE58bfAE4d8B66858c725c2F69b5F831df9c2;
        firePitWallet = 0x116c1D1767d0fFeeAF28f16acc6b6b5128ad1a6E;

        walletToWalletTransferWithoutFee = true;
        usdToken = _usdToken;
        dividendTracker = IDividendTracker(_dividendTracker);
        dividendTracker.init();

        fifaSportDao = IFifaSportDao(_dao);

        // mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E
        // testnet:  0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(
            address(this),
            _uniswapV2Router.WETH()
        );

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        _allowances[address(this)][address(uniswapV2Router)] = MAX;

        _mint(newOwner, 4_000_000_000 * (10**18));

        initialSupply = 4_000_000_000 * (10**18);
        _totalSupply = initialSupply;

        rSupply = MAX - (MAX % initialSupply);
        rate = rSupply / _totalSupply;

        rebaseRate = 4339;
        autoRebase = false;
        lastRebasedTime = block.timestamp;

        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(_dao);
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(DEAD);
        dividendTracker.excludeFromDividends(address(_uniswapV2Router));
        dividendTracker.excludeFromDividends(newOwner);

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[_dao] = true;
        _isExcludedFromFees[newOwner] = true;
        _isExcludedFromFees[DEAD] = true;
        _isExcludedFromFees[address(this)] = true;

        swapThreshold = rSupply / 5000;
        swapInterval = 30 minutes;

        _rBalance[newOwner] = rSupply;
        _transferOwnership(newOwner);
    }

    receive() external payable {}

    function claimStuckTokens(address token) external onlyOwner {
        require(token != address(this), 'Owner cannot claim native tokens');
        if (token == address(0x0)) {
            payable(msg.sender).transfer(address(this).balance);
            return;
        }
        IERC20 ERC20token = IERC20(token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(msg.sender, balance);
    }

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendBNB(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, 'Address: insufficient balance');

        (bool success, ) = recipient.call{ value: amount }('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

    //=======APY=======//
    function startAPY() external onlyOwner {
        autoRebase = true;
        lastRebasedTime = block.timestamp;
        emit AutoRebaseStatusUptaded(true);
    }

    function setAutoRebase(bool _flag) external onlyOwner {
        if (_flag) {
            autoRebase = _flag;
            lastRebasedTime = block.timestamp;
        } else {
            autoRebase = _flag;
        }
        emit AutoRebaseStatusUptaded(_flag);
    }

    function manualSync() external {
        IUniswapV2Pair(uniswapV2Pair).sync();
    }

    function updateUniswapV2Router(address newAddress) external onlyOwner {
        require(newAddress != address(uniswapV2Router), 'The router already has that address');
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);

        address newPair = IUniswapV2Factory(uniswapV2Router.factory()).getPair(address(this), uniswapV2Router.WETH());
        if (newPair != address(0x0)) {
            address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                uniswapV2Router.WETH()
            );
            uniswapV2Pair = _uniswapV2Pair;
        } else {
            uniswapV2Pair = newPair;
        }
        _allowances[address(this)][address(uniswapV2Router)] = MAX;
    }

    function setAutomatedMarketMakerPair(address pair, bool value) external onlyOwner {
        require(pair != uniswapV2Pair, 'The PancakeSwap pair cannot be removed from automatedMarketMakerPairs');

        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, 'Automated market maker pair is already set to that value');
        automatedMarketMakerPairs[pair] = value;

        if (value) {
            dividendTracker.excludeFromDividends(pair);
        }

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function shouldRebase() internal view returns (bool) {
        return
            autoRebase && msg.sender != uniswapV2Pair && !inSwap && block.timestamp >= (lastRebasedTime + 30 minutes);
    }

    function rebase() internal {
        if (inSwap) return;
        uint256 times = (block.timestamp - lastRebasedTime) / 30 minutes;

        for (uint256 i = 0; i < times; i++) {
            _totalSupply = (_totalSupply * (10_000_000 + rebaseRate)) / 10_000_000;
            rebase_count++;
        }

        rate = rSupply / _totalSupply;
        lastRebasedTime = lastRebasedTime + (times * 30 minutes);

        IUniswapV2Pair(uniswapV2Pair).sync();

        emit LogRebase(rebase_count, _totalSupply);
    }

    //=======BEP20=======//
    function approve(address spender, uint256 value) public override returns (bool) {
        _allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner_, address spender) public view override returns (uint256) {
        return _allowances[owner_][spender];
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public override returns (bool) {
        uint256 oldValue = _allowances[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowances[msg.sender][spender] = 0;
        } else {
            _allowances[msg.sender][spender] = oldValue - subtractedValue;
        }
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public override returns (bool) {
        _allowances[msg.sender][spender] = _allowances[msg.sender][spender] + addedValue;
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _rBalance[account] / rate;
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public override returns (bool) {
        if (_allowances[from][msg.sender] != MAX) {
            _allowances[from][msg.sender] = _allowances[from][msg.sender] - value;
        }
        _transferFrom(from, to, value);
        return true;
    }

    function _basicTransfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        uint256 rAmount = amount * rate;
        _rBalance[from] = _rBalance[from] - rAmount;
        _rBalance[to] = _rBalance[to] + rAmount;
        emit Transfer(from, to, amount);
        return true;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        require(recipient != address(0), 'ERC20: transfer to the zero address');
        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        uint256 rAmount = amount * rate;

        if (shouldRebase()) {
            rebase();
        }

        if (shouldSwapBack()) {
            swapBack();
        }

        _rBalance[sender] = _rBalance[sender] - rAmount;

        bool wtwWoFee = walletToWalletTransferWithoutFee && sender != uniswapV2Pair && recipient != uniswapV2Pair;
        uint256 amountReceived = (_isExcludedFromFees[sender] || _isExcludedFromFees[recipient] || wtwWoFee)
            ? rAmount
            : takeFee(sender, rAmount, recipient);
        _rBalance[recipient] = _rBalance[recipient] + amountReceived;

        try dividendTracker.setBalance(payable(sender), balanceOf(sender)) {} catch {}
        try dividendTracker.setBalance(payable(recipient), balanceOf(recipient)) {} catch {}

        if (!inSwap) {
            uint256 gas = gasForProcessing;

            try dividendTracker.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
                emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin);
            } catch {}
        }
        emit Transfer(sender, recipient, amountReceived / rate);
        return true;
    }

    function takeFee(
        address sender,
        uint256 rAmount,
        address recipient
    ) internal returns (uint256) {
        uint256 _finalFee;
        uint256 _amountDaoReward;

        if (uniswapV2Pair == recipient) {
            _finalFee = totalSellFee;
        } else if (uniswapV2Pair == sender) {
            _finalFee = totalBuyFee;
            _amountDaoReward = (rAmount * daoRewardBuyFee) / 100;
        } else {
            _finalFee = WtoWtransferFee;
        }

        uint256 feeAmount = (rAmount * _finalFee) / 100;

        // distribute DAO reward - 10%
        if (_amountDaoReward > 0) {
            address[10] memory _parents = fifaSportDao.getParents(recipient);

            for (uint8 i = 0; i < _parents.length; i++) {
                uint256 _parentFee = (_amountDaoReward / 100) * 5; // 0.5 %
                if (i == 0) {
                    _parentFee = (_amountDaoReward / 10) * 4; // 4%
                }
                if (i == 1) {
                    _parentFee = (_amountDaoReward / 10) * 2; // 2%
                }
                _rBalance[_parents[i]] = _rBalance[_parents[i]] + _parentFee;

                emit DistributionDaoReward(recipient, _parents[i], _parentFee / rate, i);
                emit Transfer(recipient, _parents[i], _parentFee / rate);
            }
        }

        _rBalance[address(this)] = _rBalance[address(this)] + (feeAmount - _amountDaoReward);
        emit Transfer(sender, address(this), (feeAmount - _amountDaoReward) / rate);

        return rAmount - feeAmount;
    }

    //=======FeeManagement=======//
    function excludeFromFees(address account) external onlyOwner {
        require(!_isExcludedFromFees[account], 'Account is already the value of true');
        _isExcludedFromFees[account] = true;
        emit ExcludeFromFees(account, true);
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function updateSellFees(
        uint256 _liquiditySellFee,
        uint256 _treasurySellFee,
        uint256 _sustainabilitySellFee,
        uint256 _rewardSellFee,
        uint256 _firePitSellFee
    ) external onlyOwner {
        liquiditySellFee = _liquiditySellFee;
        treasurySellFee = _treasurySellFee;
        sustainabilitySellFee = _sustainabilitySellFee;
        rewardSellFee = _rewardSellFee;
        firePitSellFee = _firePitSellFee;
        totalSellFee = liquiditySellFee + treasurySellFee + sustainabilitySellFee + rewardSellFee + firePitSellFee;
        require(totalSellFee <= 25, 'Fees must be less than 25%');
    }

    function updateBuyFees(uint256 _liquidityBuyFee, uint256 _daoRewardBuyFee) external onlyOwner {
        liquidityBuyFee = _liquidityBuyFee;
        daoRewardBuyFee = _daoRewardBuyFee;
        totalBuyFee = liquidityBuyFee + daoRewardBuyFee;

        require(totalBuyFee <= 25, 'Fees must be less than 25%');
    }

    function updateWtoWFees(uint256 _treasuryTransferFee, uint256 _liquidityTransferFee) external onlyOwner {
        treasuryTransferFee = _treasuryTransferFee;
        liquidityTransferFee = _liquidityTransferFee;
        WtoWtransferFee = treasuryTransferFee + liquidityTransferFee;
        require(WtoWtransferFee <= 25, 'Fees must be less than 25%');
    }

    function enableWalletToWalletTransferWithoutFee(bool enable) external onlyOwner {
        require(
            walletToWalletTransferWithoutFee != enable,
            'Wallet to wallet transfer without fee is already set to that value'
        );
        walletToWalletTransferWithoutFee = enable;
    }

    function updateDao(address _address) public onlyOwner {
        require(address(fifaSportDao) != _address, 'DAO is already set to that value');
        fifaSportDao = IFifaSportDao(_address);
    }

    function changeTreasuryWallet(address _treasuryWallet) external onlyOwner {
        require(_treasuryWallet != treasuryWallet, 'Marketing wallet is already that address');
        require(!isContract(_treasuryWallet), 'Marketing wallet cannot be a contract');
        treasuryWallet = _treasuryWallet;
    }

    function changeSustainabilityWallet(address _sustainabilityWallet) external onlyOwner {
        require(_sustainabilityWallet != sustainabilityWallet, 'Ecosystem wallet is already that address');
        require(!isContract(_sustainabilityWallet), 'Sustainability wallet cannot be a contract');
        sustainabilityWallet = _sustainabilityWallet;
    }

    //=======Swap=======//
    function shouldSwapBack() internal view returns (bool) {
        return (msg.sender != uniswapV2Pair &&
            !inSwap &&
            swapEnabled &&
            _rBalance[address(this)] >= swapThreshold &&
            lastSwapTime + swapInterval < block.timestamp);
    }

    function swapBack() internal swapping {
        uint256 contractTokenBalance = balanceOf(address(this));

        uint256 totalFee = totalBuyFee - daoRewardBuyFee + totalSellFee + WtoWtransferFee;
        uint256 liquidityShare = liquidityBuyFee + liquiditySellFee + liquidityTransferFee;
        uint256 treasuryShare = treasurySellFee + treasuryTransferFee;
        uint256 sustainabilityShare = sustainabilitySellFee;
        uint256 firePitShare = firePitSellFee;
        uint256 rewardShare = rewardSellFee;

        uint256 liquidityTokens;

        if (liquidityShare > 0) {
            liquidityTokens = (contractTokenBalance * liquidityShare) / totalFee;
            swapAndLiquify(liquidityTokens);
        }

        contractTokenBalance -= liquidityTokens;
        uint256 bnbShare = treasuryShare + sustainabilityShare + rewardShare + firePitShare;

        if (contractTokenBalance > 0 && bnbShare > 0) {
            uint256 initialBalance = address(this).balance;

            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = uniswapV2Router.WETH();

            uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                contractTokenBalance,
                0,
                path,
                address(this),
                block.timestamp
            );

            uint256 newBalance = address(this).balance - initialBalance;

            if (treasuryShare > 0) {
                uint256 marketingBNB = (newBalance * treasuryShare) / bnbShare;
                sendBNB(payable(treasuryWallet), marketingBNB);
            }

            if (sustainabilityShare > 0) {
                uint256 sustainabilityAmount = (newBalance * sustainabilityShare) / bnbShare;
                sendBNB(payable(sustainabilityWallet), sustainabilityAmount);
            }

            if (firePitShare > 0) {
                uint256 firePitShareAmount = (newBalance * firePitShare) / bnbShare;
                sendBNB(payable(firePitWallet), firePitShareAmount);
            }

            if (rewardShare > 0) {
                uint256 rewardBNB = (newBalance * rewardShare) / bnbShare;
                swapAndSendDividends(rewardBNB);
            }
        }

        lastSwapTime = block.timestamp;
    }

    function swapAndLiquify(uint256 tokens) private {
        uint256 half = tokens / 2;
        uint256 otherHalf = tokens - half;

        uint256 initialBalance = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            half,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );

        uint256 newBalance = address(this).balance - initialBalance;

        uniswapV2Router.addLiquidityETH{ value: newBalance }(
            address(this),
            otherHalf,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            DEAD,
            block.timestamp
        );

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapAndSendDividends(uint256 amount) private {
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = usdToken;

        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: amount }(
            0,
            path,
            address(dividendTracker),
            block.timestamp
        );

        uint256 balanceRewardToken = IERC20(usdToken).balanceOf(address(dividendTracker));

        dividendTracker.distributeDividends(balanceRewardToken);
        emit SendDividends(balanceRewardToken);
    }

    function setSwapBackSettings(
        bool _enabled,
        uint256 _percentage_base100000,
        uint256 _swapInterVal
    ) external onlyOwner {
        require(_percentage_base100000 >= 1, 'Swap back percentage must be more than 0.001%');
        _swapInterVal = _swapInterVal;
        swapEnabled = _enabled;
        swapThreshold = (rSupply / 100000) * _percentage_base100000;
    }

    function checkSwapThreshold() external view returns (uint256) {
        return swapThreshold / rate;
    }

    //=======Divivdend Tracker=======//

    function updateDividendTracker(address newAddress) public onlyOwner {
        require(newAddress != address(dividendTracker), 'The dividend tracker already has that address');

        dividendTracker = IDividendTracker(payable(newAddress));
        dividendTracker.init();
        require(
            dividendTracker.owner() == address(this),
            'The new dividend tracker must be owned by the token contract'
        );

        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(DEAD);
        dividendTracker.excludeFromDividends(address(uniswapV2Router));
        dividendTracker.excludeFromDividends(address(uniswapV2Pair));
        dividendTracker.excludeFromDividends(address(fifaSportDao));

        emit UpdateDividendTracker(newAddress, address(dividendTracker));
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, 'gasForProcessing must be between 200,000 and 500,000');
        require(newValue != gasForProcessing, 'Cannot update gasForProcessing to same value');
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }

    function updateMinimumBalanceForDividends(uint256 newMinimumBalance) external onlyOwner {
        dividendTracker.updateMinimumTokenBalanceForDividends(newMinimumBalance);
    }

    function updateClaimWait(uint256 claimWait) external onlyOwner {
        dividendTracker.updateClaimWait(claimWait);
    }

    function getClaimWait() external view returns (uint256) {
        return dividendTracker.claimWait();
    }

    function getTotalDividendsDistributed() external view returns (uint256) {
        return dividendTracker.totalDividendsDistributed();
    }

    function withdrawableDividendOf(address account) public view returns (uint256) {
        return dividendTracker.withdrawableDividendOf(account);
    }

    function dividendTokenBalanceOf(address account) public view returns (uint256) {
        return dividendTracker.balanceOf(account);
    }

    function totalRewardsEarned(address account) public view returns (uint256) {
        return dividendTracker.accumulativeDividendOf(account);
    }

    function excludeFromDividends(address account) external onlyOwner {
        dividendTracker.excludeFromDividends(account);
    }

    function getAccountDividendsInfo(address account)
        external
        view
        returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return dividendTracker.getAccount(account);
    }

    function getAccountDividendsInfoAtIndex(uint256 index)
        external
        view
        returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return dividendTracker.getAccountAtIndex(index);
    }

    function processDividendTracker(uint256 gas) external {
        (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) = dividendTracker.process(gas);
        emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, false, gas, tx.origin);
    }

    function claim() external {
        dividendTracker.processAccount(payable(msg.sender), false);
    }

    function claimAddress(address claimee) external onlyOwner {
        dividendTracker.processAccount(payable(claimee), false);
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return dividendTracker.getLastProcessedIndex();
    }

    function setLastProcessedIndex(uint256 index) external onlyOwner {
        dividendTracker.setLastProcessedIndex(index);
    }

    function getNumberOfDividendTokenHolders() external view returns (uint256) {
        return dividendTracker.getNumberOfTokenHolders();
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
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
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
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
    function balanceOf(address account) public view virtual override returns (uint256) {
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
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
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
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
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
    ) public virtual override returns (bool) {
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
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
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

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
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

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.3;
interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.3;
interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.3;
interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

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

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.3;

import './IUniswapV2Router01.sol';
interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.3;
interface IFifaSportDao {
    function distribution(address _to, uint256 _totalAmount) external;

    function getParents(address _wallet) external view returns (address[10] memory);

    function referral(address _from, address _to) external;

    function relations(address, uint256) external view returns (address);

    function setIsRecevicedAddress(address _to) external;
    
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.3;
interface IDividendTracker {
  function accumulativeDividendOf ( address _owner ) external view returns ( uint256 );
  function allowance ( address owner, address spender ) external view returns ( uint256 );
  function approve ( address spender, uint256 amount ) external returns ( bool );
  function balanceOf ( address account ) external view returns ( uint256 );
  function claimWait (  ) external view returns ( uint256 );
  function decimals (  ) external view returns ( uint8 );
  function decreaseAllowance ( address spender, uint256 subtractedValue ) external returns ( bool );
  function distributeDividends ( uint256 amount ) external;
  function dividendOf ( address _owner ) external view returns ( uint256 );
  function excludeFromDividends ( address account ) external;
  function excludedFromDividends ( address ) external view returns ( bool );
  function getAccount ( address _account ) external view returns ( address account, int256 index, int256 iterationsUntilProcessed, uint256 withdrawableDividends, uint256 totalDividends, uint256 lastClaimTime, uint256 nextClaimTime, uint256 secondsUntilAutoClaimAvailable );
  function getAccountAtIndex ( uint256 index ) external view returns ( address, int256, int256, uint256, uint256, uint256, uint256, uint256 );
  function getLastProcessedIndex (  ) external view returns ( uint256 );
  function getNumberOfTokenHolders (  ) external view returns ( uint256 );
  function increaseAllowance ( address spender, uint256 addedValue ) external returns ( bool );
  function init (  ) external;
  function initialized (  ) external view returns ( bool );
  function lastClaimTimes ( address ) external view returns ( uint256 );
  function lastProcessedIndex (  ) external view returns ( uint256 );
  function minimumTokenBalanceForDividends (  ) external view returns ( uint256 );
  function name (  ) external view returns ( string memory );
  function owner (  ) external view returns ( address );
  function process ( uint256 gas ) external returns ( uint256, uint256, uint256 );
  function processAccount ( address account, bool automatic ) external returns ( bool );
  function renounceOwnership (  ) external;
  function rewardToken (  ) external view returns ( address );
  function setBalance ( address account, uint256 newBalance ) external;
  function setLastProcessedIndex ( uint256 index ) external;
  function symbol (  ) external view returns ( string memory );
  function totalDividendsDistributed (  ) external view returns ( uint256 );
  function totalSupply (  ) external view returns ( uint256 );
  function transfer ( address to, uint256 amount ) external returns ( bool );
  function transferFrom ( address from, address to, uint256 amount ) external returns ( bool );
  function transferOwnership ( address newOwner ) external;
  function updateClaimWait ( uint256 newClaimWait ) external;
  function updateMinimumTokenBalanceForDividends ( uint256 _newMinimumBalance ) external;
  function withdrawDividend (  ) external pure;
  function withdrawableDividendOf ( address _owner ) external view returns ( uint256 );
  function withdrawnDividendOf ( address _owner ) external view returns ( uint256 );
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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