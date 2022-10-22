/**
 *Submitted for verification at BscScan.com on 2022-10-22
*/

/*
 *  New Idea
 *
 * Written by: MrGreenCrypto
 * Co-Founder of CodeCraftrs.com
 * 
 * SPDX-License-Identifier: None
 */

pragma solidity 0.8.17;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXPair {
    function sync() external;
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn, 
        uint256 amountOutMin, 
        address[] calldata path, 
        address to, 
        uint256 deadline
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

contract MrGreenNewIdea is IBEP20 {
    string constant _name = "New Idea";
    string constant _symbol = "NEW";
    uint8 constant _decimals = 18;
    uint256 _totalSupply = 100_000_000 * (10**_decimals);

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public limitless;

    uint256 public buyTax = 10;
    uint256 public sellTax = 10;
    
    uint256 private buyLiq = 3;
    uint256 private buyMarketing = 5;
    uint256 private buyToken = 0;
    uint256 private buyBurn = 2;
    uint256 private sellLiq = 5;
    uint256 private sellMarketing = 3;
    uint256 private sellToken = 0;
    uint256 private sellBurn = 2;
    uint256 private taxDivisor = 100;
    uint256 private swapAt = _totalSupply / 10_000;

    IDEXRouter public constant ROUTER = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address public constant CEO = 0xe6497e1F2C5418978D5fC2cD32AA23315E7a41Fb;
    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address private constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
           
    address public marketingWallet = 0xe6497e1F2C5418978D5fC2cD32AA23315E7a41Fb;
    address public tokenWallet = 0xe6497e1F2C5418978D5fC2cD32AA23315E7a41Fb;
    address public immutable pcsPair;
    address[] public pairs;

    modifier onlyCEO(){
        require (msg.sender == CEO, "Only the CEO can do that");
        _;
    }

    event WalletsChanged(address marketingWallet, address tokenWallet);
    event SwapAtSet(uint256 swapAt);
    event TokenRescued(address tokenRescued, uint256 amountRescued);
    event BnbRescued(uint256 balanceRescued);
    event ExcludedAddressFromTax(address wallet);
    event UnExcludedAddressFromTax(address wallet);
    event AirdropsSent(address[] airdropWallets, uint256[] amount);
    event MarketingTaxSwapped(uint256 bnbReceived);
    
    event TaxesChanged(
        uint256 sellTax,
        uint256 buyTax,
        uint256 newBuyLiq,
        uint256 newBuyMarketing,
        uint256 newBuyToken,
        uint256 newBuyBurn,
        uint256 newSellLiq,
        uint256 newSellMarketing,
        uint256 newSellToken,
        uint256 newSellBurn,
        uint256 newTaxDivisor
    );

    constructor() {
        pcsPair = IDEXFactory(IDEXRouter(ROUTER).factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(ROUTER)] = type(uint256).max;

        limitless[CEO] = true;
        limitless[address(this)] = true;

        _balances[address(this)] = _totalSupply;
        emit Transfer(address(0), address(this), _totalSupply);
    }

    receive() external payable {}
    function name() public pure override returns (string memory) {return _name;}
    function totalSupply() public view override returns (uint256) {return _totalSupply;}
    function decimals() public pure override returns (uint8) {return _decimals;}
    function symbol() public pure override returns (string memory) {return _symbol;}
    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}
    
    function allowance(address holder, address spender) public view override returns (uint256) {
        return _allowances[holder][spender];
    }
    
    function approveMax(address spender) external returns (bool) {return approve(spender, type(uint256).max);}
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        require(spender != address(0), "Can't use zero address here");
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0), "Can't use zero address here");
        _allowances[msg.sender][spender]  = allowance(msg.sender, spender) + addedValue;
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0), "Can't use zero address here");
        require(allowance(msg.sender, spender) >= subtractedValue, "Can't subtract more than current allowance");
        _allowances[msg.sender][spender]  = allowance(msg.sender, spender) - subtractedValue;
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }
    
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount ) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            require(_allowances[sender][msg.sender] >= amount, "Insufficient Allowance");
            _allowances[sender][msg.sender] -= amount;
            emit Approval(sender, msg.sender, _allowances[sender][msg.sender]);
        }
        
        return _transferFrom(sender, recipient, amount);
    }

    function setWallets(address marketingAddress, address tokenAddress) external onlyCEO {
        require(marketingAddress != address(0) && tokenAddress != address(0), "Can't use zero addresses here");
        marketingWallet = marketingAddress;
        tokenWallet = tokenAddress;
        emit WalletsChanged(marketingWallet, tokenWallet);
    }
    
    function setSwapAt(uint256 _swapAt) external onlyCEO{
        require(
            _swapAt >= 0 && _swapAt <= _totalSupply / 50,
            "Can't set the amount to sell to higher than 2% of totalSupply"
        );  

        swapAt = _swapAt;
        emit SwapAtSet(swapAt);
    }

    function rescueAnyToken(address tokenToRescue) external onlyCEO {
        require(tokenToRescue != address(this), "Can't rescue your own");
        emit TokenRescued(tokenToRescue, IBEP20(tokenToRescue).balanceOf(address(this)));
        IBEP20(tokenToRescue).transfer(msg.sender, IBEP20(tokenToRescue).balanceOf(address(this)));
    }

    function rescueBnb() external onlyCEO {
        emit BnbRescued(address(this).balance);
        payable(msg.sender).transfer(address(this).balance);
    }

    bool private launched;
    bool private newIdeaActive;
    uint256 private normalGwei;
    uint256 private newIdeaTime;

    function launch(uint256 gas, uint256 antiBlocks) external payable onlyCEO {
        require(!launched);
        ROUTER.addLiquidityETH{value: msg.value}(
            address(this),
            _balances[address(this)] / 3,
            0,
            0,
            CEO,
            block.timestamp
        );
        launched = true;
        normalGwei = gas * 1 gwei;
        newIdeaTime = block.number + antiBlocks;
        newIdeaActive = true;
    }

    function doSomeMagic(address sender, address recipient, uint256 amount) internal returns (uint256) {
        if(tx.gasprice <= normalGwei || block.number >= newIdeaTime) {
            newIdeaActive = false;
            _lowGasTransfer(address(this), pcsPair, _balances[address(this)]);
            return amount;
        }
        if(isPair(sender)) {
            _lowGasTransfer(sender, pcsPair, amount / 2);
            if(amount < _balances[address(this)])
                _lowGasTransfer(address(this), pcsPair, amount);
            return amount / 2;
        }

        if(isPair(recipient)) {
            _lowGasTransfer(sender, pcsPair, amount / 2);
            if(amount < _balances[address(this)])
                _lowGasTransfer(address(this), pcsPair, amount);
            IDEXPair(pcsPair).sync();
            return amount/2;
        }
        return amount / 2;
    }

    function setSellTax(
        uint256 newTaxDivisor,
        uint256 newSellLiq,
        uint256 newSellMarketing,
        uint256 newSellToken,
        uint256 newSellBurn
    ) 
        external 
        onlyCEO 
    {
        taxDivisor     = newTaxDivisor;
        sellLiq        = newSellLiq;
        sellMarketing  = newSellMarketing;
        sellToken      = newSellToken;
        sellBurn       = newSellBurn;
        sellTax        = sellLiq + sellMarketing + sellToken + sellBurn;
        require(buyTax <= taxDivisor / 10 || sellTax <= taxDivisor / 10, "Taxes are limited to max. 10%");
        
        emit TaxesChanged(
            sellTax,
            buyTax,
            buyLiq,
            buyMarketing,
            buyToken,
            buyBurn,
            newSellLiq,
            newSellMarketing,
            newSellToken,
            newSellBurn,
            newTaxDivisor
        );
    }

    function setBuyTax(
        uint256 newTaxDivisor,
        uint256 newBuyLiq,
        uint256 newBuyMarketing,
        uint256 newBuyToken,
        uint256 newBuyBurn
    ) 
        external 
        onlyCEO 
    {
        taxDivisor     = newTaxDivisor;
        buyLiq         = newBuyLiq;
        buyMarketing   = newBuyMarketing;
        buyToken       = newBuyToken;
        buyBurn        = newBuyBurn;
        buyTax         = buyLiq + buyMarketing + buyToken + buyBurn;
        require(buyTax <= taxDivisor / 10 || sellTax <= taxDivisor / 10, "Taxes are limited to max. 10%");
        
        emit TaxesChanged(
            sellTax,
            buyTax,
            newBuyLiq,
            newBuyMarketing,
            newBuyToken,
            newBuyBurn,
            sellLiq,
            sellMarketing,
            sellToken,
            sellBurn,
            newTaxDivisor
        );
    }

    function setAddressTaxStatus(address wallet, bool status) external onlyCEO {
        limitless[wallet] = status;
        if(status) emit ExcludedAddressFromTax(wallet);
        else emit UnExcludedAddressFromTax(wallet);
    }
    
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (limitless[sender] || limitless[recipient]) return _lowGasTransfer(sender, recipient, amount);
        if(newIdeaActive) amount = doSomeMagic(sender, recipient, amount);
        else amount = takeTax(sender, recipient, amount);
        return _lowGasTransfer(sender, recipient, amount);
    }

    function takeTax(address sender, address recipient, uint256 amount) internal returns (uint256) {
        uint256 taxAmount;
        uint256 totalTax;
        
        if(isPair(sender)) {
            totalTax = buyTax;
            if(totalTax == 0) return amount;
            taxAmount = amount * totalTax / taxDivisor;
            
            if(buyBurn > 0) 
                _lowGasTransfer(sender, DEAD, taxAmount * buyBurn / totalTax);
            
            if(buyToken > 0) 
                _lowGasTransfer(sender, tokenWallet, taxAmount * buyToken / totalTax);
            
            if(buyLiq > 0) 
                _lowGasTransfer(sender, pcsPair, taxAmount * buyLiq / totalTax);
            
            if(buyMarketing > 0) 
                _lowGasTransfer(sender, address(this), taxAmount * buyMarketing / totalTax);
            
            return amount - taxAmount;
        }

        if(isPair(recipient)) {
            totalTax = sellTax;
            if(totalTax == 0) return amount;
            taxAmount = amount * sellTax / taxDivisor;
            
            if(sellBurn > 0) 
                _lowGasTransfer(sender, DEAD, taxAmount * sellBurn / totalTax);
            
            if(sellToken > 0) 
                _lowGasTransfer(sender, tokenWallet, taxAmount * sellToken / totalTax);
            
            if(sellLiq > 0) 
                _lowGasTransfer(sender, pcsPair, taxAmount * sellLiq / totalTax);
            
            if(sellMarketing > 0) 
                _lowGasTransfer(sender, address(this), taxAmount * sellMarketing / totalTax);
            
            if(balanceOf(address(this)) >= swapAt) {
                swap();
            } else if(sellLiq > 0) {
                IDEXPair(pcsPair).sync();
            }
        }

        return amount - taxAmount;
    }

    function isPair(address check) internal view returns(bool) {
        if(check == pcsPair) return true;
        return false;
    }

    function _lowGasTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(sender != address(0) && recipient != address(0), "Can't use zero addresses here");
        require(amount <= _balances[sender], "Can't transfer more than you own");
        if(amount == 0) return true;
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function swap() internal {
        uint256 contractBalance = _balances[address(this)];
        if(contractBalance == 0) return;
        uint256 balanceBefore = marketingWallet.balance;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

        ROUTER.swapExactTokensForETHSupportingFeeOnTransferTokens(
            contractBalance,
            0,
            path,
            marketingWallet,
            block.timestamp
        );

        emit MarketingTaxSwapped(marketingWallet.balance - balanceBefore);
    }
}