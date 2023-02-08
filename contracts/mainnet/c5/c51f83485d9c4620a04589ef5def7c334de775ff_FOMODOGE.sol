// SPDX-License-Identifier: MIT

pragma solidity ^0.6.2;

import "./DividendPayingToken.sol";
import "./SafeMath.sol";
import "./IterableMapping.sol";
import "./Ownable.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router.sol";

interface COIN {
    function uniswapV2Pair() external view returns(address);
}

contract FOMODOGE is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool private swapping;

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    
    address public immutable WBNB = address(0x55d398326f99059fF775485246999027B3197955); //USDT

    uint256 public swapTokensAtAmount = 10000000 * (10**18);
    
    mapping(address => bool) public _isBlacklisted;
    uint256 public Autosale = 0;
    uint256 public JackpotFee = 4;
    uint256 public liquidityFee = 1;
    uint256 public marketingFee = 1;
    uint256 public burnFee = 0;
    uint256 pool_legth = 5;
    uint256 auto_stop = 0;
    uint256 bonus_pool_min = 0;
    uint256 buy_pool_min = 0;
    uint256 public totalFees = JackpotFee.add(liquidityFee).add(marketingFee).add(burnFee);
    address[] public pool_address;
    address public _marketingWalletAddress = 0x43f650149459Fc13BCf33DE07f44a05Ea82b8120;
    address public _devWalletAddress = 0x734Cf5384CA9bfd8311f3F215Dbc33BA47D470aC;
    
    // use by default 300,000 gas to process auto-claiming dividends
    uint256 public gasForProcessing = 300000;

    // exlcude from fees and max transaction amount
    mapping (address => bool) private _isExcludedFromFees;

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping (address => bool) public automatedMarketMakerPairs;

    event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress);

    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);

    event ExcludeFromFees(address indexed account, bool isExcluded);

    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event LiquidityWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);

    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event SwapAndLiquify (
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event SendDividends (
    	uint256 tokensSwapped,
    	uint256 amount
    );

    event ProcessedDividendTracker (
    	uint256 iterations,
    	uint256 claims,
        uint256 lastProcessedIndex,
    	bool indexed automatic,
    	uint256 gas,
    	address indexed processor
    );

    modifier onlyDev {	
        require(_devWalletAddress == _msgSender(), "Only the dev can call this function");	
        _;	
    }

    constructor() public ERC20("FOMODOGE", "FOMODOGE") {

    	IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        // Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);
       
        // exclude from paying fees or having max transaction amount
        excludeFromFees(owner(), true);
        excludeFromFees(_marketingWalletAddress, true);
        excludeFromFees(_devWalletAddress, true);
        excludeFromFees(address(this), true);
   
        /*
        _mint is an internal function in ERC20.sol that is only called here,and CANNOT be called ever again
        */
        _mint(owner(), 100 * (10**10) * (10**18));
    }

    receive() external payable {

  	}

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(uniswapV2Router), "FDOGE: The router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Pair = _uniswapV2Pair;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "FDOGE: Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }
        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    function setMarketingWallet(address payable wallet) external onlyOwner {
        _marketingWalletAddress = wallet;
    }

    function setDevWallet(address payable devWallet) external onlyDev {
         _devWalletAddress = devWallet;
    }

    function setbonus_pool_min(uint256 value) external onlyDev {
        bonus_pool_min = value; 
    }

    function setbuy_pool_min(uint256 value) external onlyDev {
        buy_pool_min = value;  
    }

    function setJackpotFee(uint256 value) external onlyDev {
        JackpotFee = value;
        totalFees = JackpotFee.add(liquidityFee).add(marketingFee);
    }

    function setAutosale(uint256 value) external onlyOwner {
        Autosale = value;
    }

    function setLiquiditFee(uint256 value) external onlyOwner {
        liquidityFee = value;
        totalFees = JackpotFee.add(liquidityFee).add(marketingFee);
    }

    function setMarketingFee(uint256 value) external onlyOwner {
        marketingFee = value;
        totalFees = JackpotFee.add(liquidityFee).add(marketingFee);
    }

     function setburnFee(uint256 value) external onlyOwner {
         burnFee = value;
        totalFees = JackpotFee.add(liquidityFee).add(burnFee);
    }

    function setautostop(uint256 _autostop) external onlyOwner {
         auto_stop = _autostop;
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "FDOGE: The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");
        _setAutomatedMarketMakerPair(pair, value);
    }
    
    function blacklistAddress(address account, bool value) external onlyOwner {
        _isBlacklisted[account] = value;
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "FDOGE: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "FDOGE: gasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "FDOGE: Cannot update gasForProcessing to same value");
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }
  
    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!_isBlacklisted[from] && !_isBlacklisted[to], 'Blacklisted address');

        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

		uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if( canSwap &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            from != owner() &&
            to != owner() 
        ) 

        {
            swapping = true;
            uint256 marketingTokens = contractTokenBalance.mul(marketingFee).div(totalFees);
            uint256 JackpotTokens = contractTokenBalance.mul(JackpotFee).div(totalFees);
            uint256 burnTokens = contractTokenBalance.mul(burnFee).div(totalFees);
            swapAndSendToFee(marketingTokens);
            swapJackpotToFee(JackpotTokens);
            super._transfer(address(this),deadWallet, burnTokens);
            uint256 swapTokens = contractTokenBalance.mul(liquidityFee).div(totalFees);
            swapAndLiquify(swapTokens);
            swapping = false;
        }
        
        if(from == uniswapV2Pair){

            if(auto_stop == 0){
            require(amount <= 1 * (10**10) * (10**18)); 
            require(balanceOf(to) <= 5 * (10**10) * (10**18));
            }
            uint256 contractWBNBBalance =  IERC20(WBNB).balanceOf(address(this));
            if(contractWBNBBalance >= bonus_pool_min && getFDOGEPrice(amount) >= buy_pool_min){
            pool_address.push(to);
            if(pool_address.length >= pool_legth){
            IERC20(WBNB).transfer(pool_address[pool_legth-2], bonus_pool_min);
            pool_legth = pool_legth+5;
                }
            }
        }
        
        bool takeFee = !swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if(takeFee) {
            require(Autosale == 1,"transaction stop"); 
        	uint256 fees = amount.mul(totalFees).div(100);       
        	amount = amount.sub(fees);
            super._transfer(from, address(this), fees);
        }
        super._transfer(from, to, amount);      
    }

    function swapAndSendToFee(uint256 tokens) private  {

        uint256 initialUSDTBalance = IERC20(WBNB).balanceOf(address(this));
        swapTokensForWBNB(tokens);
        uint256 newBalance = (IERC20(WBNB).balanceOf(address(this))).sub(initialUSDTBalance);
        IERC20(WBNB).transfer(_marketingWalletAddress, newBalance);
    }

    function swapJackpotToFee(uint256 tokens) private  {

        uint256 initialUSDTBalance = IERC20(WBNB).balanceOf(address(this));
        swapTokensForWBNB(tokens);
        uint256 newBalance = (IERC20(WBNB).balanceOf(address(this))).sub(initialUSDTBalance);
        IERC20(WBNB).transfer(address(this), newBalance);
    }

    function getFDOGEPrice(uint256 amount) public view returns(uint256) {
            (,uint256 bnb) = getLiqBalance(address(this),amount);
            return bnb;       
    }
    
    function getLiqBalance(address _addr,uint256 tMarketAmount) public view returns(uint256 _weth,uint256 _liqbalance) {
     
        address[] memory path = new address[](2);
        path[0] = _addr;
        path[1] = uniswapV2Router.WETH();
        uint256[] memory amounts = uniswapV2Router.getAmountsOut( tMarketAmount, path);
        return (balanceOf(COIN(_addr).uniswapV2Pair()),amounts[amounts.length - 1]);
    }
    function swapAndLiquify(uint256 tokens) private {
        // split the contract balance into halves
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {

        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function swapTokensForWBNB(uint256 tokenAmount) private {

        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = WBNB;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {

        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(0),
            block.timestamp
        );
    }
}