/**
 *Submitted for verification at BscScan.com on 2022-09-19
*/

//SPDX-License-Identifier: MIT 
// o/
pragma solidity 0.8.15;
//interfaces ok
interface IPancakeV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IPancakeV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

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
// contracts
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}
contract Ownable is Context {
    address private _owner;
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
    function getTime() public view returns (uint256) {
        return block.timestamp;
    }
}
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 9;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(sender, recipient, amount);
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;
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
contract BLACK is ERC20, Ownable {
//custom
    IPancakeV2Router02 public pancakeV2Router;
//bool
    bool public swapAndLiquifyEnabled = true;
    bool public marketActive;
    bool public limitSells = true;
    bool public limitBuys = true;
    bool public feeStatus = true;
    bool public buyFeeStatus = true;
    bool public sellFeeStatus = true;
    bool public blockMultiBuys = true;
    bool public addLiquidityEnabled = true;
    bool public maxWallet = true;
    bool private isInternalTransaction;
//address
    address public pancakeV2Pair;
    address public marketingAddress = 0x869dae1B02B0Ca06735E9dE42176cfEAfD382bf8;
    address public devAddress = 0x9206B873cD49f3B3495529D10f54C0e6706464Df;
    address public teamAddress = 0x4C3B98C7638B5d9EF37d590C153463E8767Ee4c8;
    address public liquidityAddress = 0x869dae1B02B0Ca06735E9dE42176cfEAfD382bf8;
//uint
    uint public buyMarketingFee = 60;
    uint public sellMarketingFee = 60;
    uint public buyLiquidityFee = 10;
    uint public sellLiquidityFee = 10;
    uint public buyDevFee = 10;
    uint public sellDevFee = 10;
    uint public buyTeamFee = 10;
    uint public sellTeamFee = 10;
    uint public totalBuyFee = buyMarketingFee + buyLiquidityFee + buyDevFee + buyTeamFee;
    uint public totalSellFee = sellMarketingFee + sellLiquidityFee + sellDevFee + sellTeamFee;
    uint public maxBuyTxAmount;
    uint public maxSellTxAmount;
    uint256 public maxWalletAmount;
    uint public minimumTokensBeforeSwap = 50_000 * 10 ** decimals();
    uint public tokensToSwap = 50_000 * 10 ** decimals();
    uint public intervalSecondsForSwap = 30;
    uint public minimumWeiForTokenomics = 1 * 10**17; // 0.1 BNB.
    uint private startTimeForSwap;
    uint private marketActiveAt;
//struct
    struct userData {uint lastBuyTime;}
//mapping
    mapping (address => bool) public premarketUser;
    mapping (address => bool) public excludedFromFees;
    mapping (address => bool) public automatedMarketMakerPairs;
    mapping (address => bool) public excludedFromMaxWallet;
    mapping (address => userData) public userLastTradeData;
//events
    event MarketingFeeCollected(uint amount);
    event DevFeeCollected(uint amount);
    event TeamFeeCollected(uint amount);
    event LiquidityFeeCollected(uint amount);
    event PancakeRouterUpdated(address indexed newAddress, address indexed newPair);
    event PancakePairUpdated(address indexed newAddress, address indexed newPair);
    event TokenRemovedFromContract(address indexed tokenAddress, uint256 amount);
    event BnbRemovedFromContract(uint256 amount);
    event MarketStatusChanged(bool status, uint256 date);
    event LimitSellChanged(bool status);
    event LimitBuyChanged(bool status);
    event MinimumWeiChanged(uint256 amount);
    event MaxSellChanged(uint256 amount);
    event MaxBuyChanged(uint256 amount);
    event FeesChanged(uint256 buyMarketingFee, uint256 buyLiquidityFee, uint256 buyDevFee,uint256 buyTeamFee,
                      uint256 sellMarketingFee, uint256 sellLiquidityFee,uint256 sellDevFee,uint256 sellTeamFee);
    event FeesAddressesChanged(address marketing, address liquidity, address team, address dev);
    event FeesStatusChanged(bool feesActive, bool buy, bool sell);
    event SwapSystemChanged(bool status, uint256 intervalSecondsToWait, uint256 minimumToSwap, uint256 tokensToSwap);
    event PremarketUserChanged(bool status, address indexed user);
    event ExcludeFromFeesChanged(bool status, address indexed user);
    event AutomatedMarketMakerPairsChanged(bool status, address indexed target);
    event ContractSwap(uint256 date, uint256 amount);
    event BlockMultiBuysChange(bool status);
    event AddLiquidityEnabled(bool state);
    event ExcludedFromMaxWalletChanged(address indexed user, bool state);
// constructor
    constructor() ERC20("Squid Black", "BLACK") {
        uint total_supply = 100_000_000_000 * 10 ** decimals();
        // set gvars
        IPancakeV2Router02 _pancakeV2Router = IPancakeV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pancakeV2Router = _pancakeV2Router;
        maxSellTxAmount = total_supply / 50; // 2% supply
        maxBuyTxAmount = total_supply / 50; // 2% supply
        maxWalletAmount =  total_supply / 50; // 2% supply
        //spawn pair
        pancakeV2Pair = IPancakeV2Factory(_pancakeV2Router.factory())
        .createPair(address(this), _pancakeV2Router.WETH());
        // mappings
        excludedFromFees[address(this)] = true;
        excludedFromFees[owner()] = true;
        excludedFromFees[liquidityAddress] = true;
        excludedFromFees[marketingAddress] = true;
        excludedFromFees[teamAddress] = true;
        excludedFromFees[devAddress] = true;

        excludedFromMaxWallet[address(this)] = true;
        excludedFromMaxWallet[owner()] = true;
        excludedFromMaxWallet[liquidityAddress] = true;
        excludedFromMaxWallet[marketingAddress] = true;
        excludedFromMaxWallet[teamAddress] = true;
        excludedFromMaxWallet[devAddress] = true;
        
        premarketUser[owner()] = true;
        automatedMarketMakerPairs[pancakeV2Pair] = true;
        _mint(owner(), total_supply); // mint is used only here
    }
    // accept bnb for autoswap
    receive() external payable {}

    modifier sameSize(uint list1,uint list2) {
        require(list1 == list2,"lists must have same size");
        _;
    }
// utility functions
    function updatePancakeV2Router(address newAddress, bool _createPair, address _pair) external onlyOwner {
        pancakeV2Router = IPancakeV2Router02(newAddress);
        if(_createPair) {
            address _pancakeV2Pair = IPancakeV2Factory(pancakeV2Router.factory())
                .createPair(address(this), pancakeV2Router.WETH());
            pancakeV2Pair = _pancakeV2Pair;
            emit PancakePairUpdated(newAddress,pancakeV2Pair);
        } else {
            pancakeV2Pair = _pair;
        }
        emit PancakeRouterUpdated(newAddress,pancakeV2Pair);
    }
    // to take leftover(tokens) from contract
    function transferToken(address _token, address _to, uint _value) external onlyOwner returns(bool _sent){
        if(_value == 0) {
            _value = IERC20(_token).balanceOf(address(this));
        } 
        _sent = IERC20(_token).transfer(_to, _value);
        emit TokenRemovedFromContract(_token, _value);
    }
    // to take leftover(bnb) from contract
    function transferBNB() external onlyOwner {
        uint balance = address(this).balance;
        payable(owner()).transfer(balance);
        emit BnbRemovedFromContract(balance);
    }
//switch functions
    function switchMarketActive(bool _state) external onlyOwner {
        marketActive = _state;
        if(_state) {
            marketActiveAt = block.timestamp;
        }
        emit MarketStatusChanged(_state, block.timestamp);
    }
    function switchLimitSells(bool _state) external onlyOwner {
        limitSells = _state;
        emit LimitSellChanged(_state);
    }
    function switchLimitBuys(bool _state) external onlyOwner {
        limitBuys = _state;
        emit LimitBuyChanged(_state);
    }
//set functions
    function setBlockMultiBuys(bool _status) external onlyOwner {
        blockMultiBuys = _status;
        emit BlockMultiBuysChange(_status);
    }
    function setminimumWeiForTokenomics(uint _value) external onlyOwner {
        minimumWeiForTokenomics = _value;
        emit MinimumWeiChanged(_value);
    }
    function setFeesAddress(address marketing, address liquidity, address team, address dev) external onlyOwner {
        marketingAddress = marketing;
        liquidityAddress = liquidity;
        teamAddress = team;
        devAddress = dev;
        emit FeesAddressesChanged(marketing,liquidity,team,dev);
    }
    function setMaxSellTxAmount(uint _value) external onlyOwner {
        maxSellTxAmount = _value*10**decimals();
        require(maxSellTxAmount >= totalSupply() / 1000,"maxSellTxAmount should be at least 0.5% of total supply");
        emit MaxSellChanged(_value);
    }
    function setMaxBuyTxAmount(uint _value) external onlyOwner {
        maxBuyTxAmount = _value*10**decimals();
        require(maxBuyTxAmount >= totalSupply() / 1000,"maxBuyTxAmount should be at least 0.5% of total supply");
        emit MaxBuyChanged(maxBuyTxAmount);
    }
    function setMaxWallet(bool state, uint max) public onlyOwner {
        maxWallet = state;
        maxWalletAmount = max * 10** decimals();
        require(maxWalletAmount >= totalSupply() / 1000,"max wallet min amount 2%");
    }
    function setFee(uint Buymarketing, uint Buyliquidity,uint Sellmarketing, uint Sellliquidity,
    uint Buydev, uint Buyteam,uint Selldev, uint Sellteam) external onlyOwner {
        //buy
        buyMarketingFee = Buymarketing;
        buyLiquidityFee = Buyliquidity;
        buyDevFee = Buydev;
        buyTeamFee = Buyteam;
        totalBuyFee = buyMarketingFee + buyLiquidityFee + buyDevFee + buyTeamFee;
        //sell
        sellMarketingFee = Sellmarketing;
        sellLiquidityFee = Sellliquidity;
        sellDevFee = Selldev;
        sellTeamFee = Sellteam;
        totalSellFee = sellMarketingFee + sellLiquidityFee + sellDevFee + sellTeamFee;
        //checks
        require(totalBuyFee + totalSellFee <= 200,"Total fees cannot be over 20%");
        emit FeesChanged(buyMarketingFee,buyLiquidityFee,buyDevFee,Buyteam,sellMarketingFee,sellLiquidityFee,sellDevFee,sellTeamFee);
    }
    function setAddLiquidityEnabled(bool state) external onlyOwner {
        addLiquidityEnabled = state;
        emit AddLiquidityEnabled(state);
    }
    function setFeeStatus(bool buy, bool sell, bool _state) external onlyOwner {
        feeStatus = _state;
        buyFeeStatus = buy;
        sellFeeStatus = sell;
        emit FeesStatusChanged(_state,buy,sell);
    }
    function setSwapAndLiquify(bool _state, uint _intervalSecondsForSwap, uint _minimumTokensBeforeSwap, uint _tokensToSwap) external onlyOwner {
        swapAndLiquifyEnabled = _state;
        intervalSecondsForSwap = _intervalSecondsForSwap;
        minimumTokensBeforeSwap = _minimumTokensBeforeSwap*10**decimals();
        tokensToSwap = _tokensToSwap*10**decimals();
        require(tokensToSwap <= minimumTokensBeforeSwap,"You cannot swap more then the minimum amount");
        require(tokensToSwap <= totalSupply() / 1,"token to swap limited to 0.1% supply");
        emit SwapSystemChanged(_state,_intervalSecondsForSwap,_minimumTokensBeforeSwap,_tokensToSwap);
    }
// mappings functions
    function editPremarketUser(address _target, bool _status) external onlyOwner {
        premarketUser[_target] = _status;
        emit PremarketUserChanged(_status,_target);
    }
    function editExcludedFromFees(address _target, bool _status) external onlyOwner {
        excludedFromFees[_target] = _status;
        emit ExcludeFromFeesChanged(_status,_target);
    }
    function editAutomatedMarketMakerPairs(address _target, bool _status) external onlyOwner {
        automatedMarketMakerPairs[_target] = _status;
        emit AutomatedMarketMakerPairsChanged(_status,_target);
    }
    function editExcludedFromMaxWallet(address user, bool state) external onlyOwner {
        excludedFromMaxWallet[user] = state;
        emit ExcludedFromMaxWalletChanged(user,state);
    }
    function editMultiExcludedFromMaxWallet(address[] memory _address, bool[] memory _states) external onlyOwner sameSize(_address.length,_states.length) {
        for(uint i=0; i< _states.length; i++){
            excludedFromMaxWallet[_address[i]] = _states[i];
            emit ExcludedFromMaxWalletChanged(_address[i],_states[i]);
        }
    }
// operational functions
    function KKAirdrop(address[] memory _address, uint256[] memory _amount) external onlyOwner {
        for(uint i=0; i< _amount.length; i++){
            address adr = _address[i];
            uint amnt = _amount[i] *10**decimals();
            super._transfer(owner(), adr, amnt);
        }
        // events from ERC20
    }
    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeV2Router.WETH();
        _approve(address(this), address(pancakeV2Router), tokenAmount);
        pancakeV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
        emit ContractSwap(block.timestamp, tokenAmount);
    }
    
    modifier FastTx() {
        isInternalTransaction = true;
        _;
        isInternalTransaction = false;
    }
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(pancakeV2Router), tokenAmount);
        pancakeV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            liquidityAddress,
            block.timestamp
        );
    }
    function swapTokens(uint256 contractTokenBalance) private FastTx {
        uint256 liq_part = contractTokenBalance * sellLiquidityFee / 100;
        uint256 initialBalance = address(this).balance;
        uint256 swaptokensamount = contractTokenBalance - liq_part;
        swapTokensForEth(swaptokensamount);
        uint256 newBalance = address(this).balance - initialBalance;
        uint liq_part_percent = newBalance * sellLiquidityFee / 100;
        if(addLiquidityEnabled) {
            addLiquidity(liq_part, liq_part_percent);
        }
    }
    function _transfer(address from, address to, uint256 amount) internal override {
        uint trade_type = 0;
    // market status flag
        if(!marketActive) {
            require(premarketUser[from],"cannot trade before the market opening");
        }
    // normal transaction
        if(!isInternalTransaction) {
        // tx limits
            //buy
            if(automatedMarketMakerPairs[from]) {
                trade_type = 1;
                // limits
                if(!excludedFromFees[to]) {
                    // tx limit
                    if(limitBuys) {
                        require(amount <= maxBuyTxAmount, "maxBuyTxAmount Limit Exceeded");
                        // multi-buy limit
                        if(marketActiveAt + 0 < block.timestamp) {
                            require(marketActiveAt + 0 < block.timestamp,"You cannot buy at launch.");
                            require(userLastTradeData[to].lastBuyTime + 10 <= block.timestamp,"You cannot do multi-buy orders.");
                            userLastTradeData[to].lastBuyTime = block.timestamp;
                        }
                    }
                }
            }
            //sell
            else if(automatedMarketMakerPairs[to]) {
                trade_type = 2;
                bool overMinimumTokenBalance = balanceOf(address(this)) >= minimumTokensBeforeSwap;
                // marketing auto-bnb
                if (swapAndLiquifyEnabled && balanceOf(pancakeV2Pair) > 0) {
                    // if contract has X tokens, not sold since Y time, sell Z tokens
                    if (overMinimumTokenBalance && startTimeForSwap + intervalSecondsForSwap <= block.timestamp) {
                        startTimeForSwap = block.timestamp;
                        // sell to bnb
                        swapTokens(tokensToSwap);
                    }
                }
                // limits
                if(!excludedFromFees[from]) {
                    // tx limit
                    if(limitSells) {
                    require(amount <= maxSellTxAmount, "maxSellTxAmount Limit Exceeded");
                    }
                }
            }
            // max wallet
            if(maxWallet) {
                require(balanceOf(to) + amount <= maxWalletAmount || excludedFromMaxWallet[to],"maxWallet limit");
            }
            // fees redistribution
            if(address(this).balance > minimumWeiForTokenomics) {
                //marketing
                uint256 caBalance = address(this).balance;
                uint256 marketingTokens = caBalance * sellMarketingFee / totalSellFee;
                (bool success,) = address(marketingAddress).call{value: marketingTokens}("");
                if(success) {
                    emit MarketingFeeCollected(marketingTokens);
                }
                uint256 devTokens = caBalance * sellDevFee / totalSellFee;
                (bool success1,) = address(devAddress).call{value: devTokens}("");
                if(success1) {
                    emit DevFeeCollected(devTokens);
                }
                uint256 teamTokens = caBalance * sellTeamFee / totalSellFee;
                (bool success2,) = address(teamAddress).call{value: teamTokens}("");
                if(success2) {
                    emit TeamFeeCollected(marketingTokens);
                }
            }
        // fees management
            if(feeStatus) {
                // buy
                if(trade_type == 1 && buyFeeStatus && !excludedFromFees[to]) {
                	uint txFees = amount * totalBuyFee / 1000;
                	amount -= txFees;
                    super._transfer(from, address(this), txFees);
                }
                //sell
                if(trade_type == 2 && sellFeeStatus && !excludedFromFees[from]) {
                	uint txFees = amount * totalSellFee / 1000;
                	amount -= txFees;
                    super._transfer(from, address(this), txFees);
                }
                // no wallet to wallet tax.
            }
        }
        // transfer tokens
        super._transfer(from, to, amount);
    }
}