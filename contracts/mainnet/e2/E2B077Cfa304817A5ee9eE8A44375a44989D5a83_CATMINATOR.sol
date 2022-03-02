// SPDX-License-Identifier: MIT

pragma solidity ^0.6.2;

import "./SafeMath.sol";
import "./IterableMapping.sol";
import "./Ownable.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router.sol";
import "./ERC20.sol";

contract CATMINATOR is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;

    bool private swapping;

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;

    uint256 public swapTokensAtAmount = 2000000 * (10**18);

    bool public tradingActive = false;

    uint256 public liquidityActiveBlock = 0;        // 0 means liquidity is not active yet
    uint256 public tradingActiveBlock = 0;          // 0 means trading is not active
    mapping(address => bool) public boughtEarly;    // mapping to track addresses that buy within the first 2 blocks pay a 5x tax for 24 hours to sell
    uint256 public earlyBuyPenaltyEnd;              // determines when snipers/bots can sell without extra penalty

    // set penalty for bots who frontrun buyback
    mapping(address => uint256) public holderLastBoughtBlock;
    uint256 public lastBuyBackBlock;

    uint256 public buybackFee = 7;
    uint256 public liquidityFee = 3;
    uint256 public marketingFee = 5;
    uint256 public totalFees = buybackFee.add(liquidityFee).add(marketingFee);

    address public _marketingWalletAddress = 0xEe251Ac84199688F219e9D0536f93960015ab762;
    address public _buybackWalletAddress = 0xF28E5De621d5b35702cBE2db7ef19fa428eC4c71;

    // exclude from fee
    mapping (address => bool) private _isExcludedFromFees;

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping (address => bool) public automatedMarketMakerPairs;

    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event LiquidityWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    constructor() public ERC20("CATMINATOR", "CMR") {

        uint256 totalSupply = 100000000000 * (10**18);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        // Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        // exclude from paying fees
        excludeFromFees(owner(), true);
        excludeFromFees(_marketingWalletAddress, true);
        excludeFromFees(_buybackWalletAddress, true);
        excludeFromFees(address(this), true);

        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(address(owner()), totalSupply);
    }

    receive() external payable {

    }

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(uniswapV2Router), "The router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
        .createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Pair = _uniswapV2Pair;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    // once enabled, can never be turned off
    function enableTrading() external onlyOwner {
        tradingActive = true;
        tradingActiveBlock = block.number;
        earlyBuyPenaltyEnd = block.timestamp + 24 hours;
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

        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        /*
        start
        */

        if(!tradingActive && block.number == liquidityActiveBlock && from != owner()){
            super._transfer(from, to, 1); // give bots 1 wei of tokens if they snipe in the same block that liquidity is added.
            super._transfer(from, address(0xdead), amount-1); // Burn the remaining tokens
            return;
        }

        if(!tradingActive){
            require(from == owner(), "Trading is not active.");
            if(liquidityActiveBlock == 0 && to == uniswapV2Pair){
                liquidityActiveBlock = block.number;
            }
        }

        if(from != owner() && automatedMarketMakerPairs[from] && !automatedMarketMakerPairs[to] && block.number == tradingActiveBlock){
            boughtEarly[to] = true;
        }

        if(automatedMarketMakerPairs[from] && !_isExcludedFromFees[to]){
            holderLastBoughtBlock[to] = block.number;
        }

        /*
        end
        */

        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if(canSwap &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            from != owner() &&
            to != owner()
        ) {
            swapping = true;

            uint256 marketingTokens = contractTokenBalance.mul(marketingFee).div(totalFees);
            swapAndSendToFee(marketingTokens);

            uint256 buybackTokens = contractTokenBalance.mul(buybackFee).div(totalFees);
            swapAndSendToBuybackFee(buybackTokens);

            uint256 swapTokens = contractTokenBalance.mul(liquidityFee).div(totalFees);
            swapAndLiquify(swapTokens);

            swapping = false;
        }

        bool takeFee = !swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if(takeFee) {
            uint256 fees = amount.mul(totalFees).div(100);

            // snipers / bots pay 5x fees to exit for 24 hours OR if the wallet bought in the same block that a buyback occurred to discourage bots from stealing liquidity.
            if((boughtEarly[from] && automatedMarketMakerPairs[to] && earlyBuyPenaltyEnd > block.timestamp) || (holderLastBoughtBlock[from] == lastBuyBackBlock && lastBuyBackBlock == block.number && automatedMarketMakerPairs[to])) {
                super._transfer(from, address(0xdead), fees * 4); // burn 4/5 of the tokens to prevent price dump.
                super._transfer(from, address(this), fees); // take standard fees
                fees = fees * 5;
            } else {
                if(automatedMarketMakerPairs[to]){
                    fees += amount.mul(1).div(100);
                }
                amount = amount.sub(fees);
            }
            super._transfer(from, address(this), fees);
        }

        super._transfer(from, to, amount);
    }

    function swapAndSendToFee(uint256 tokens) private  {

        uint256 initialBNBBalance = address(this).balance;

        swapTokensForEth(tokens);
        uint256 newBalance = (address(this).balance).sub(initialBNBBalance);
        payable(_marketingWalletAddress).transfer(newBalance);
    }

    function swapAndSendToBuybackFee(uint256 tokens) private  {

        uint256 initialBNBBalance = address(this).balance;

        swapTokensForEth(tokens);
        uint256 newBalance = (address(this).balance).sub(initialBNBBalance);
        payable(_buybackWalletAddress).transfer(newBalance);
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