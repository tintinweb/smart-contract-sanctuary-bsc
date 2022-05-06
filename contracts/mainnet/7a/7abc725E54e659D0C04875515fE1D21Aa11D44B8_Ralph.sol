// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./IERC20.sol";
import "./Ownable.sol";
import "./IPancakeV2Factory.sol";
import "./IPancakeV2Pair.sol";
import "./IPancakeRouter02.sol";

contract Ralph is Context, IERC20, Ownable {
    // Fee variables
    uint16 public marketingBuyFee = 7;
    uint16 public marketingSellFee = 5;
    uint16 public lotteryBuyFee = 1;
    uint16 public lotterySellFee = 1;
    uint16 public burnBuyFee = 2;
    uint16 public burnSellFee = 2;
    uint16 public ralphCapitalFee = 10;
    uint16 public whaleRalphCapitalFee = 15;
    uint16 public autoLiquidityFee = 2;

    // Taxes accumulated in the contract
    uint256 private _totalMarketingTax = 0;

    // Lottery variables
    uint256 public lotteryPool = 0;
    uint256 public lotteryThreshold = 50 * 10**9 * 10**18; // 50 billion accumulated to activate lottery
    uint256 public lotteryBuyThreshold = 3 * 10**9 * 10**18; // 3 billion buy to participate in lottery
    uint256[] private _lotteryWinNumbers = [42, 69];

    // Anti-whale tax variables
    uint256 public whaleSellThreshold = 300 * 10**9 * 10**18;
    uint256 public whaleSellTimer = 24 hours;
    mapping (address => uint256) private _amountSold;
    mapping (address => uint256) private _timeSinceFirstSell;

    uint256 public maxWalletAmount = 3 * 10**12 * 10**18;

    mapping(address => bool) private _isWhiteListed; // Exclude from fees and max wallet ammout. Needed to enable some essential features (e.g. Add/Remove liquiity, create a launchpad, buybacks)

    uint256 private _nonce = uint(uint256(keccak256(abi.encodePacked(block.difficulty, "420"))));

    bool private _liquifying;
    
    // Variables for token to work
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    // Sandwich prevention variables
    mapping (address => uint256) private _lastBuyTransactionBlock;
    mapping (address => uint256) private _lastSellTransactionBlock;

    uint256 private constant _totalSupply = 1 * 10**15 * 10**18; // Quadrillion tokens total supply

    // Token info
    string private constant _name = "Ralph Token";
    string private constant _symbol = "RALPH";
    uint8 private constant _decimals = 18;

    // Wallet addresses
    address payable public marketingWallet = payable(0x1D14FF9CFBf89941632Cc00e7C555106450aC6e9);
    address payable public ralphCapitalWallet = payable(0xbAbB888d8ec29c3C52C9764ab63De4A256d73450);
    address private _pancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // Address for Pancake Router v2
    address private _pairAd = address(0); // Pair address
    address public constant deadAddress = 0x000000000000000000000000000000000000dEaD;

    IPancakeRouter02 private PancakeRouter;

    constructor() {
        // Requred data to create a pool
        _balances[owner()] = _totalSupply;
        PancakeRouter = IPancakeRouter02(_pancakeRouter);
        _pairAd = IPancakeV2Factory(PancakeRouter.factory()).createPair(
            address(this),
            PancakeRouter.WETH()
        );

        _isWhiteListed[owner()] = true;
        _isWhiteListed[address(this)] = true;
        _isWhiteListed[marketingWallet] = true;
        _isWhiteListed[ralphCapitalWallet] = true;
        _isWhiteListed[_pancakeRouter] = true;
        _isWhiteListed[_pairAd] = true;
        _isWhiteListed[deadAddress] = true; // to allow buybacks and burn from outside the contract
    }

    modifier noRecursion {
        _liquifying = true;
        _;
        _liquifying = false;
    }

    function setMarketingBuyFee(uint16 fee) external onlyOwner() {
        marketingBuyFee = fee;
    }

    function setMarketingSellFee(uint16 fee) external onlyOwner() {
        require(fee + lotterySellFee + burnSellFee + ralphCapitalFee + autoLiquidityFee <= 20, "Total sell tax should not exceed 20 percent");
        require(fee + lotterySellFee + burnSellFee + whaleRalphCapitalFee + autoLiquidityFee <= 25, "Total sell tax for whales should not exceed 25 percent");
        marketingSellFee = fee;
    }

    function setLotteryBuyFee(uint16 fee) external onlyOwner() {
        lotteryBuyFee = fee;
    }

    function setLotterySellFee(uint16 fee) external onlyOwner() {
        require(fee + marketingSellFee + burnSellFee + ralphCapitalFee + autoLiquidityFee <= 20, "Total sell tax should not exceed 20 percent");
        require(fee + marketingSellFee + burnSellFee + whaleRalphCapitalFee + autoLiquidityFee <= 25, "Total sell tax for whales should not exceed 25 percent");
        lotterySellFee = fee;
    }

    function setBurnBuyFee(uint16 fee) external onlyOwner() {
        burnBuyFee = fee;
    }

    function setBurnSellFee(uint16 fee) external onlyOwner() {
        require(fee + marketingSellFee + lotterySellFee + ralphCapitalFee + autoLiquidityFee <= 20, "Total sell tax should not exceed 20 percent");
        require(fee + marketingSellFee + lotterySellFee + whaleRalphCapitalFee + autoLiquidityFee <= 25, "Total sell tax for whales should not exceed 25 percent");
        burnSellFee = fee;
    }

    function setRalphCapitalFee(uint16 fee) external onlyOwner() {
        require(fee + marketingSellFee + lotterySellFee + burnSellFee + autoLiquidityFee <= 20, "Total sell tax should not exceed 20 percent");
        ralphCapitalFee = fee;
    }
    
    function setWhaleRalphCapitalFee(uint16 fee) external onlyOwner() {
        require(fee + marketingSellFee + lotterySellFee + burnSellFee + autoLiquidityFee <= 25, "Total sell tax for whales should not exceed 25 percent");
        whaleRalphCapitalFee = fee;
    }

    function setAutoliquidityFee(uint16 fee) external onlyOwner() {
        require(fee + marketingSellFee + lotterySellFee + burnSellFee + ralphCapitalFee <= 20, "Total sell tax should not exceed 20 percent");
        require(fee + marketingSellFee + lotterySellFee + burnSellFee + whaleRalphCapitalFee <= 25, "Total sell tax for whales should not exceed 25 percent");
        autoLiquidityFee = fee;
    }

    function setLotteryWinNumbers(uint16[] calldata numbers) external onlyOwner() {
        _lotteryWinNumbers = numbers;
    }

    function setLotteryThreshold(uint256 threshold) external onlyOwner() {
        lotteryThreshold = threshold;
    }

    function setLotteryBuyThreshold(uint256 threshold) external onlyOwner() {
        lotteryBuyThreshold = threshold;
    }

    function addToWhiteList(address addr) external onlyOwner() {
        _isWhiteListed[addr] = true;
    }

   function removeFromWhiteList(address addr) external onlyOwner() {
        require(addr != _pancakeRouter && addr != _pairAd && addr != owner() && addr != address(this) && addr != address(0) && addr != deadAddress, "Can not remove this address from whitelist");
        _isWhiteListed[addr] = false;
    }

    function setWhaleThreshold(uint256 amount) external onlyOwner() {
        whaleSellThreshold = amount;
    }

    function setWhaleTimer(uint256 time) external onlyOwner() {
        whaleSellTimer = time;
    }

    function setMaxWalletAmount(uint256 amount) external onlyOwner() {
        maxWalletAmount = amount;
    }

    // View functions

    function getLotteryWinNumbers() external view returns(uint256[] memory) {
        return _lotteryWinNumbers;
    }

    /**
     * @dev Generates a random number between 1 and 100
     */
    function random() private returns (uint) {
        uint r = uint(uint256(keccak256(abi.encodePacked(block.difficulty, _nonce))) % 100);
        r = r + 1;
        unchecked {
            _nonce = _nonce + r + 1;
        }
        return r;
    }

    function name() external pure returns (string memory) {
        return _name;
    }

    function symbol() external pure returns (string memory) {
        return _symbol;
    }

    function decimals() external pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() external pure override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        require (_allowances[sender][_msgSender()] >= amount, "ERC20: transfer amount exceeds allowance");
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    /** 
     *  @dev Prevents transaction from being sandwiched
     *  Does not allow both buy and sell from one address during the same block 
     */
    function _isSandwich(address sender, address recipient, address pair) private returns (bool) {
        // Buy logic
        if (sender == pair) {
            if (block.number == _lastSellTransactionBlock[recipient])
                return true;
            _lastBuyTransactionBlock[recipient] = block.number;
        // Sell logic
        } else if (recipient == pair) {
            if (block.number == _lastBuyTransactionBlock[sender])
                return true;
            _lastSellTransactionBlock[sender] = block.number;
        }
        return false;
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        // Make sure that the transaction is not a sandwich pair,
        require(!_isSandwich(sender, recipient, _pairAd));

        // The usual ERC20 checks
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_balances[sender] >= amount, "ERC20: transfer exceeds balance");
        require(amount > 0, "Transfer = 0");
        
        // Set defaults for fallback
        uint256 amountRemaining = amount;
        uint256 marketingTax = 0;
        uint256 lotteryTax = 0;
        uint256 burnTax = 0;
        uint256 ralphCapitalTax = 0;
        uint256 autoLiquidityTax = 0;

        // Logic for buys
        if (sender == _pairAd && recipient != _pancakeRouter && !_isWhiteListed[recipient])
        {
            marketingTax = amount * marketingBuyFee / 100;
            lotteryTax = amount * lotteryBuyFee / 100;
            burnTax = amount * burnBuyFee / 100;
            uint256 taxes = marketingTax + lotteryTax + burnTax;
            amountRemaining = amount - taxes;
        }

        // Check for max balance
        if (!_isWhiteListed[recipient]) {
            require(_balances[recipient] + amountRemaining <= maxWalletAmount, "Token balance will exceed a maximum token amount after this operation");
        }
        
        // Logic for sells
        if (recipient == _pairAd && !_isWhiteListed[sender])
        {
            // Check if seller is a whale
            bool isWhale = false;
            uint256 delta = block.timestamp - _timeSinceFirstSell[sender];
            uint256 newTotal = _amountSold[sender] + amount;
            if (delta > 0 && delta < whaleSellTimer && _timeSinceFirstSell[sender] != 0) {
                if (newTotal > whaleSellThreshold) {
                    isWhale = true;
                }
                _amountSold[sender] = newTotal;
            } else if (_timeSinceFirstSell[sender] == 0 && newTotal > whaleSellThreshold) {
                isWhale = true;
                _amountSold[sender] = newTotal;
            } else {
                _timeSinceFirstSell[sender] = block.timestamp;
                _amountSold[sender] = amount;
            }

            marketingTax = amount * marketingSellFee / 100;
            lotteryTax = amount * lotterySellFee / 100;
            burnTax = amount * burnSellFee / 100;
            ralphCapitalTax = amount * (isWhale ? whaleRalphCapitalFee : ralphCapitalFee) / 100;
            autoLiquidityTax = amount * autoLiquidityFee / 100;
            uint256 taxes = marketingTax + lotteryTax + burnTax + ralphCapitalTax + autoLiquidityTax;
            amountRemaining = amount - taxes;
        }
        
        // Calculate, swap and transfer marketing and development tax
        _balances[address(this)] = _balances[address(this)] + marketingTax;
        _totalMarketingTax = _totalMarketingTax + marketingTax;      
        if (!_liquifying && recipient == _pairAd){
            uint256 marketingAmount = _totalMarketingTax;
            if (marketingAmount > marketingTax * 2) {
                marketingAmount = marketingTax * 2;
            }
            if (_balances[address(this)] >= marketingAmount && marketingAmount > 0) {
                liquidateTokens(marketingAmount, marketingWallet);
                _totalMarketingTax = _totalMarketingTax - marketingAmount;
            }
        }

        // Calculate, swap and transfer Ralph Capital tax
        _balances[address(this)] = _balances[address(this)] + ralphCapitalTax;
        if (!_liquifying && recipient == _pairAd){
            if (_balances[address(this)] >= ralphCapitalTax && ralphCapitalTax > 0) {
                liquidateTokens(ralphCapitalTax, ralphCapitalWallet);
            }
        }

        // Calculate, swap and add autoLiquidity
        _balances[address(this)] = _balances[address(this)] + autoLiquidityTax;
        if (!_liquifying && recipient == _pairAd) {
            if (_balances[address(this)] >= autoLiquidityTax && autoLiquidityTax > 0) {
                addLiquidity(autoLiquidityTax);
            }
        }

        // Add to lottery pool
        _balances[address(this)] = _balances[address(this)] + lotteryTax;
        lotteryPool = lotteryPool + lotteryTax;

        // Lottery mechanism
        if (sender == _pairAd && lotteryPool >= lotteryThreshold && amount >= lotteryBuyThreshold && _balances[address(this)] >= lotteryPool && !_isWhiteListed[recipient]) {
            uint256 rand = random();
            bool isWinner = false;
            for (uint256 i = 0; i < _lotteryWinNumbers.length; i++) {
                if (_lotteryWinNumbers[i] == rand) {
                    isWinner = true;
                }
            }
            if (isWinner) {
                _balances[recipient] = _balances[recipient] + lotteryPool;
                _balances[address(this)] = _balances[address(this)] - lotteryPool;
                lotteryPool = 0;
            }
        }

        // Burn
        _balances[deadAddress] = _balances[deadAddress] + burnTax;

        _balances[recipient] = _balances[recipient] + amountRemaining;
        _balances[sender] = _balances[sender] - amount;

        emit Transfer(sender, recipient, amount);
    }

    function pairAddr() external view returns (address){
        return _pairAd;
    }

    function sendETH(uint256 amount, address payable _to) private {
        (bool sent,) = _to.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    function swapTokensForBNB(uint256 amount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = PancakeRouter.WETH();

        PancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(amount, 0, path, address(this), block.timestamp);
    }

    // Liquidate for a single address
    function liquidateTokens(uint256 amount, address payable recipient) private noRecursion {
        _approve(address(this), address(_pancakeRouter), amount);

        uint256 initialBalance = address(this).balance;

        swapTokensForBNB(amount);

        uint256 receivedBNB = address(this).balance - initialBalance;

        if (address(this).balance >= receivedBNB && recipient != payable(address(this))) sendETH(receivedBNB, recipient);
    }

    function addLiquidity(uint256 amount) private noRecursion {
        // Use half of the amount to swap for BNB and pair together with RALPH to add autoLiquidity
        uint256 half = amount / 2;
        _approve(address(this), address(_pancakeRouter), amount);

        uint256 initialBalance = address(this).balance;

        swapTokensForBNB(half);

        uint256 receivedBNB = address(this).balance - initialBalance;

        PancakeRouter.addLiquidityETH{value: receivedBNB}(
            address(this),
            half,
            0, // Take any amount of tokens
            0, // Take any amount of BNB
            owner(),
            block.timestamp
        );
    }

    function emergencyWithdrawETH() external onlyOwner() {
        (bool sent,) = _msgSender().call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }
    
    // Withdrawal of the marketing and development tax left in the contract
    function withdrawMarketingTax(uint256 amount) external onlyOwner() {
        require(amount <= _totalMarketingTax, "Can not withdraw more than acccumulated");
        if (_balances[address(this)] >= amount) {
            liquidateTokens(amount, marketingWallet);
            _totalMarketingTax = _totalMarketingTax - amount;
        }
    }

    // Burn the remaining tokens stuck in the contract
    function burnRemainingTokens() external onlyOwner() {
        uint256 amount = _balances[address(this)] - _totalMarketingTax - lotteryPool;
        if (amount > 0) {
            _balances[deadAddress] = _balances[deadAddress] + amount;
            _balances[address(this)] = _balances[address(this)] - amount;
        }
    }

    receive() external payable {}

    fallback() external payable {}
}