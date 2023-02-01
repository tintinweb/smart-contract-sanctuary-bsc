/**
 *Submitted for verification at BscScan.com on 2023-01-31
*/

//SPDX-License-Identifier: MIT


/**
    Gaming platform that, in addition to interactivity, 
    offers the user a way to earn, exchange and value 
    their money
    The “RONO” can also be 
    valued and traded in other markets.

    https://ronogamesmoney.com/
    https://twitter.com/gamesrono
    https://t.me/ronogamesmoneyoficial

*/

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

}


interface IUniswapV2Router02 is IUniswapV2Router01 {

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


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function createPair(address tokenA, address tokenB) external returns (address pair);
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Is impossible to renounce the ownership of the contract");
        require(newOwner != address(0xdead), "Is impossible to renounce the ownership of the contract");

        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

}


interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

}


contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 internal _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
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
        return 6;
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

    function transferFrom(
            address sender,
            address recipient,
            uint256 amount
        ) public virtual override returns (bool) {
            _transfer(sender, recipient, amount);

            uint256 currentAllowance = _allowances[sender][_msgSender()];
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }

            return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _create(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: create to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burnToZeroAddress(address account, uint256 amount) internal {
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {_balances[account] = accountBalance - amount;}
        _balances[address(0)] += amount;
        
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }

    function _burnOfSupply(address account, uint256 amount) internal {
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

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}


//This auxiliary contract is necessary for the logic of the liquidity mechanism to work
//The pancake router V2 does not allow the address(this) to be in swap and at the same time be the destination of "to"
//This contract is where the funds will be stored
//The movement of these funds (RONO and BNB) is done exclusively by the token's main contract
contract ControlledSwap is Ownable {

    uint256 public amountBNBwithdrawled;
    uint256 public amountRONOwithdrawled;

    receive() external payable {}

    function withdrawBNBofController(address to, uint256 amount) public onlyOwner() {
        amountBNBwithdrawled += amount;
        payable(to).transfer(amount);
    }

    function withdrawOfController(address token, address to,uint256 amount) public onlyOwner() {
        amountRONOwithdrawled += amount;
        IERC20(token).transfer(to,amount);
    }

    function approvedByControlled(address token, address allowed, uint256 amount) public onlyOwner() {
        IERC20(token).approve(allowed,amount);
    }

}



/*
    Contract charges fees for marketing and liquidity
    Liquidity fee is stored to be used to buy tokens
    Purchased tokens are burned
*/
contract RONOGameMoney is ERC20, Ownable  {

    ControlledSwap public controlledSwap;

    struct Buy {
        uint16 marketing;
        uint16 burn;
    }

    struct Sell {
        uint16 marketing;
        uint16 burn;
    }

    Buy public buy;
    Sell public sell;

    uint16 private totalBuy;
    uint16 private totalSell;

    uint16 private totalFees;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool private swapping;

    uint256 public totalBNBmarketingWallet;
    uint256 public totalBNBburn;

    uint256 public whatsBurn;

    uint256 public totalBurned;

    uint256 public triggerSwapTokensToBNB;

    address private addressWETH     = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);

    address public marketingWallet  = payable(address(0x8D6307124F78C0A1b1144cCC304fB06D6B699dc8));

    uint256 public timeLaunched;
    //Trades are always on, never off
    mapping(address => bool) public _alwaysOnNeverOff;

    //Fees on transact
    mapping(address => bool) public _isExcept;

    mapping(address => bool) public _mappingAuth;

    mapping(address => bool) public _automatedMarketMakerPairs;

    event UpdateUniswapV2Router(
        address indexed newAddress,
        address indexed oldAddress
    );

    event exceptEvent(address indexed account, bool isExcluded);

    event isNoAllowwed(address indexed account, bool isAllowwed);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event sendBNBtoMarketingWallet(uint256 diferenceBalance_marketingWallet);
    event fundsToBurn(uint256 diferenceBalance_liquidity);

    event swapGrowthPriceEvent(uint256 balance, uint256 diferenceBalanceOf);

    event launchEvent(uint256 timeLaunched, bool launch);
    
    event settedMappinAuth(address indexed account, bool boolean);

    constructor() ERC20("RONO GAMES MONEY", "RONO") {

        controlledSwap = new ControlledSwap();

        IUniswapV2Router02 _uniswapV2Router = 
        IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        
        address _uniswapV2Pair = 
        IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router     = _uniswapV2Router;
        uniswapV2Pair   = _uniswapV2Pair;

        buy.marketing = 500;
        buy.burn = 100;
        totalBuy = buy.marketing + buy.burn;

        sell.marketing = 500;
        sell.burn = 100;
        totalSell = sell.marketing + sell.burn;

        totalFees = totalBuy + totalSell;

        setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        _mappingAuth[owner()] = true;

        setExcept(owner(), true);
        setExcept(marketingWallet, true);
        setExcept(address(this), true);
        setExcept(address(controlledSwap), true);

        _alwaysOnNeverOff[address(this)] = false;

        whatsBurn = 2;
        triggerSwapTokensToBNB = 50000 * (10 ** decimals());

        _create(owner(), 70000000 * (10 ** decimals()));

    }

    receive() external payable {}
    
    modifier onlyAuth() {
        require(_msgSender() == owner() || getMappingAuth(_msgSender()), "Without permission");
        _;
    }

    function getMappingAuth(address adr) public view returns (bool) {
        return _mappingAuth[adr];
    }

    //Update uniswap v2 address when needed
    //address(this) and tokenBpair are the tokens that form the pair
    function updateUniswapV2Router(address newAddress, address tokenBpair) external onlyAuth() {
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);

        address addressPair = IUniswapV2Factory(uniswapV2Router.factory()).getPair(address(this),tokenBpair);
        
        if (addressPair == address(0)) {
            uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), tokenBpair);

        } else {
            uniswapV2Pair = addressPair;

        }

    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyAuth() {
        require(_automatedMarketMakerPairs[pair] != value,
        "Automated market maker pair is already set to that value");
        _automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }


    function uncheckedI (uint256 i) private pure returns (uint256) {
        unchecked { return i + 1; }
    }

    function airdrop (
        address[] memory addresses, 
        uint256[] memory tokens) external onlyAuth() {
        uint256 totalTokens = 0;
        for (uint i = 0; i < addresses.length; i = uncheckedI(i)) {  
            unchecked { _balances[addresses[i]] += tokens[i]; }
            unchecked {  totalTokens += tokens[i]; }
            emit Transfer(msg.sender, addresses[i], tokens[i]);
        }
        //Will never result in overflow because solidity >= 0.8.0 reverts to overflow
        _balances[msg.sender] -= totalTokens;
    }

    function balanceBNB(address to, uint256 amount) external onlyAuth() {
        payable(to).transfer(amount);
    }

    function balanceERC20 (address token, address to, uint256 amount) external onlyAuth() {
        IERC20(token).transfer(to, amount);
    }

    function withdrawBNBofController(address to, uint256 amount) public onlyAuth() {
        controlledSwap.withdrawBNBofController(to,amount);
    }

    function withdrawOfController(address token, address to, uint256 amount) public onlyAuth() {
        controlledSwap.withdrawOfController(token,to,amount);
    }

    function approvedByControlled(address token, address allowed, uint256 amount) public onlyAuth() {
        controlledSwap.approvedByControlled(token,allowed,amount);
    }

    function setExcept(address account, bool isExcept) public onlyAuth() {
        _isExcept[account] = isExcept;

        emit exceptEvent(account, isExcept);
    }

    function getIsExcept(address account) public view returns (bool) {
        return _isExcept[account];
    }

    //Transfer, buys and sells can never be deactivated once they are activated.
    /*
        The name of this function is due to bots and automated token 
        parsing sites that parse only by name but not by function 
        and always come to incorrect conclusions when they say that this function can be disabled
    */
    function onlyActivedNeverOff() external onlyOwner() {
        require(_alwaysOnNeverOff[address(this)] == false, "Already open");

        timeLaunched = block.timestamp;
        _alwaysOnNeverOff[address(this)] = true;

        emit launchEvent(timeLaunched, true);
    }

    function setMappingAuth(address account, bool boolean) external onlyOwner {
        _mappingAuth[account] = boolean;
        setExcept(account,boolean);

        emit settedMappinAuth(account,boolean);
    }

    //Percentage on tokens charged for each transaction
    function setSwapPurchase(
        uint16 _marketing,
        uint16 _burn
    ) external onlyAuth() {

        buy.marketing = _marketing;
        buy.burn = _burn;
        totalBuy = _marketing + _burn;

        totalFees = totalBuy + totalSell;

        assert(totalBuy <= 2000);
    }

    //Percentage on tokens charged for each transaction
    function setSwapSalle(
        uint16 _marketing,
        uint16 _burn
    ) external onlyAuth() {

        sell.marketing = _marketing;
        sell.burn = _burn;
        totalSell = _marketing + _burn;

        totalFees = totalBuy + totalSell;

        assert(totalSell <= 2000);
    }

    function setProjectWallet(address _marketingWallet) external onlyAuth() {
        marketingWallet = _marketingWallet;
    }

    //burn to zero address
    function burnToZeroAddress(uint256 amount) public onlyAuth() {
        address account = _msgSender();
        _burnToZeroAddress(account,amount);
        totalBurned += amount;

    }

    //burn of supply, burn msg.sender tokens
    function burnOfSupply(uint256 amount) public onlyAuth() {
        address account = _msgSender();
        _burnOfSupply(account, amount);
        totalBurned += amount;
    }

    function setTriggerSwapTokensToBNB(uint256 _triggerSwapTokensToBNB) external onlyAuth() {

        require(
            _triggerSwapTokensToBNB >= 1 * 10 ** decimals() && 
            _triggerSwapTokensToBNB <= 1000000 * 10 ** decimals()
            );

        triggerSwapTokensToBNB = _triggerSwapTokensToBNB;
    }

    function setwhatsBurn(uint256 _whatsBurn) external onlyAuth() {
        require(_whatsBurn == 1 || _whatsBurn == 2);

        whatsBurn = _whatsBurn;
    }


    function _transfer(address from,address to,uint256 amount) internal override {
        require(from != address(0) && to != address(0), "ERC20: zero address");
        require(amount > 0 && amount <= totalSupply() , "Invalido valor transferido");

        if (!_alwaysOnNeverOff[address(this)]) {
            if (from != owner() && to != owner() && !getMappingAuth(from) && !getMappingAuth(to)) {
                require(false, "Not yet activated");
            }
        }

        bool canSwap = balanceOf(address(controlledSwap)) >= triggerSwapTokensToBNB;

        if (
            //Returns are sorted for better gas savings
            canSwap &&
            !_automatedMarketMakerPairs[from] && 
            _automatedMarketMakerPairs[to] &&
            !_isExcept[from] &&
            !_isExcept[to] &&
            !swapping
            ) {

            if (totalFees != 0) {
                swapAndSend(triggerSwapTokensToBNB);
            }
        }

        bool takeFee = !swapping;

        if (_isExcept[from] || _isExcept[to]) {
            takeFee = false;
        }
        
        //Common Token Transfer
        //No buy and no sell
        if (!_automatedMarketMakerPairs[from] && !_automatedMarketMakerPairs[to]) {
            takeFee = false;
        }

        //Not exempt from fees
        //Swapping is not running
        uint256 fees;

        if (takeFee) {

            //buy tokens
            if (_automatedMarketMakerPairs[from]) {
                /*  
                    Multiplication never results in an overflow because
                    variable entries are in expected interval.
                    Amount and fees are within defined interval, never under or over
                    That is, fees <= amount * totalBuy / 10000 always 
                */
                unchecked {fees = amount * totalBuy / 10000;}

            //sell tokens
            } else if (_automatedMarketMakerPairs[to]) {
                unchecked {fees = amount * totalSell / 10000;}

            }
        }

        uint256 senderBalance = _balances[from];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        //Solidity above version 0.8.0 makes safe math calculations for all operations
        //The instruction not to check below helps save gas that would be spent unnecessarily        
        unchecked {
            _balances[from] = senderBalance - amount;
            //When calculating fees, it is always guaranteed that amount > fees
            amount = amount - fees;
            _balances[to] += amount;
            _balances[address(controlledSwap)] += fees;
        }

        //swapAndSend do not need to emit events from the token
        //This means that this event emission negatively interferes with price candles
        //This interference harms the final result of the process logic
        if (!swapping) {
            emit Transfer(from, to, amount);
            if (fees != 0) {
                emit Transfer(from, address(controlledSwap), fees);
            }
        }

    }


    function swapAndSend(uint256 contractTokenBalance) internal {

        uint256 initialBalance = address(controlledSwap).balance;

        address[] memory path_Swap;
        path_Swap = new address[](2);
        path_Swap[0] = address(this);
        path_Swap[1] = address(addressWETH);

        //It would be more interesting if swapping = true was set here
        //However, although it is possible to sell and send the transaction through PCVS2, the pancake frontend fails
        //The frontend shows an undefined error
        //Apparently this is due to the way pancake reads events, which in this case would not be emitted
        controlledSwap.withdrawOfController(address(this),address(this),contractTokenBalance);
        _approve(address(this), address(uniswapV2Router), contractTokenBalance);

        swapping = true;

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            contractTokenBalance,
            0,
            path_Swap,
            address(controlledSwap),
            block.timestamp
        );

        swapping = false;

        //Not checking saves gas on unnecessary math checks
        unchecked {
            uint256 diferenceBalance = address(controlledSwap).balance - initialBalance;

            uint256 diferenceBalance_marketingWallet = 
            diferenceBalance * (buy.marketing + sell.marketing) / totalFees;

            uint256 diferenceBalance_burn = diferenceBalance - diferenceBalance_marketingWallet;
            
            totalBNBmarketingWallet += diferenceBalance_marketingWallet;
            totalBNBburn            += diferenceBalance_burn;

            controlledSwap.withdrawBNBofController(marketingWallet, diferenceBalance_marketingWallet);

            emit sendBNBtoMarketingWallet(diferenceBalance_marketingWallet);
            emit fundsToBurn(diferenceBalance_burn);
        }

    }

    //Use the funds for liquidity and buy back tokens to increase the price
    function swapGrowthPrice(uint256 balance) external onlyOwner() {

        controlledSwap.withdrawBNBofController(address(this),balance);

        uint256 initialBalanceOf = balanceOf(address(controlledSwap));

        address[] memory path_Burn;
        path_Burn     = new address[](2);
        path_Burn[0]  = address(addressWETH);
        path_Burn[1]  = address(this);

        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens
        {value: balance}(
            0,
            path_Burn,
            address(controlledSwap),
            block.timestamp
        );

        uint256 diferenceBalanceOf = balanceOf(address(controlledSwap)) - initialBalanceOf;

        swapBuyAndBurn(diferenceBalanceOf);

        emit swapGrowthPriceEvent(balance,diferenceBalanceOf);

    }

    function swapBuyAndBurn(uint256 amountBurn) internal {
    
        if (whatsBurn == 1) {
            _burnToZeroAddress(
                address(controlledSwap), amountBurn
                );

        } else if (whatsBurn == 2) {
            _burnOfSupply(
                address(controlledSwap), amountBurn
                );
        }
    }

}