// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import './Context.sol';
import './Ownable.sol';
import './IERC20.sol';
import './SafeMath.sol';
import './Address.sol';
import './IUniswapV2Factory.sol';
import './IUniswapV2Pair.sol';
import './IUniswapV2Router02.sol';

/**
 * @author ~ 🅧🅘🅟🅩🅔🅡 ~
 *
 * ░██████╗░█████╗░██╗░░░░░░█████╗░██████╗░███████╗░█████╗░██████╗░███╗░░░███╗████████╗░█████╗░██╗░░██╗███████╗███╗░░██╗
 * ██╔════╝██╔══██╗██║░░░░░██╔══██╗██╔══██╗██╔════╝██╔══██╗██╔══██╗████╗░████║╚══██╔══╝██╔══██╗██║░██╔╝██╔════╝████╗░██║
 * ╚█████╗░██║░░██║██║░░░░░███████║██████╔╝█████╗░░███████║██████╔╝██╔████╔██║░░░██║░░░██║░░██║█████═╝░█████╗░░██╔██╗██║
 * ░╚═══██╗██║░░██║██║░░░░░██╔══██║██╔══██╗██╔══╝░░██╔══██║██╔══██╗██║╚██╔╝██║░░░██║░░░██║░░██║██╔═██╗░██╔══╝░░██║╚████║
 * ██████╔╝╚█████╔╝███████╗██║░░██║██║░░██║██║░░░░░██║░░██║██║░░██║██║░╚═╝░██║░░░██║░░░╚█████╔╝██║░╚██╗███████╗██║░╚███║
 * ╚═════╝░░╚════╝░╚══════╝╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░░░░╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░░░░╚═╝░░░╚═╝░░░░╚════╝░╚═╝░░╚═╝╚══════╝╚═╝░░╚══╝
 *
 * Solar Farm Token - BSC BNB Miner-Supporting Token
 *
 * Discord: https://discord.gg/5pMPMpybzM
 * Telegram: https://t.me/SolarFarmMinerOfficial
 * Twitter: https://twitter.com/SolarFarmMiner
 * dApp: https://app.solarfarm.finance/
 */

contract SolarFarmToken is Context, IERC20, Ownable
{
    using SafeMath for uint;
    using Address for address;

    string public name = "Solar Farm Token";
    string public symbol = "SOLAR";

    uint public decimals = 18;
    uint public totalSupply = 1000000000 * 10 ** decimals;

    uint private maxTx = (totalSupply * 5) / 1000;
    uint private maxWallet = (totalSupply * 15) / 1000;
    uint private swapThreshold = totalSupply / 10000000;

    address payable public minerAddress;
    address payable public treasuryAddress;
    address payable public marketingAddress;

    address public uniswapPair;
    IUniswapV2Router02 public uniswapV2Router;

    mapping (address => uint) private balances;
    mapping (address => mapping (address => uint)) private allowances;

    mapping (address => bool) public isFeeExempt;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isWalletLimitExempt;
    mapping (address => bool) public isMarketPair;
    mapping (address => bool) public isBot;

    struct BuyFee
    {
        uint miner;
        uint treasury;
        uint marketing;
    }

    struct SellFee
    {
        uint miner;
        uint treasury;
        uint marketing;
    }

    BuyFee public inFee;
    SellFee public outFee;

    bool public inSwapAndLiquify;
    bool public swapAndLiquifyEnabled;
    bool public swapAndLiquifyByLimitOnly;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(uint tokensSwapped, uint ethReceived, uint tokensIntoLiqudity);
    event SwapETHForTokens(uint amountIn, address[] path);
    event SwapTokensForETH(uint amountIn, address[] path);

    modifier lockTheSwap
    {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor (address _miner, address _treasury, address _marketing)
    {
        uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapPair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());

        allowances[address(this)][address(uniswapV2Router)] = totalSupply;

        minerAddress = payable(_miner);
        treasuryAddress = payable(_treasury);
        marketingAddress = payable(_marketing);

        inFee.miner = 30;
        inFee.treasury = 20;
        inFee.marketing = 30;

        outFee.miner = 30;
        outFee.treasury = 20;
        outFee.marketing = 30;

        swapAndLiquifyEnabled = true;
        swapAndLiquifyByLimitOnly = false;

        isFeeExempt[owner()] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[minerAddress] = true;
        isFeeExempt[treasuryAddress] = true;
        isFeeExempt[marketingAddress] = true;

        isTxLimitExempt[owner()] = true;
        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[minerAddress] = true;
        isTxLimitExempt[treasuryAddress] = true;
        isTxLimitExempt[marketingAddress] = true;

        isWalletLimitExempt[owner()] = true;
        isWalletLimitExempt[address(this)] = true;
        isWalletLimitExempt[minerAddress] = true;
        isWalletLimitExempt[treasuryAddress] = true;
        isWalletLimitExempt[marketingAddress] = true;

        isWalletLimitExempt[address(uniswapPair)] = true;
        isMarketPair[address(uniswapPair)] = true;

        balances[_msgSender()] = totalSupply;
        emit Transfer(address(0), _msgSender(), totalSupply);
    }

    function balanceOf(address wallet) public view override returns (uint256) 
    {
        return balances[wallet];
    }

    function allowance(address owner, address spender) public view override returns (uint256) 
    {
        return allowances[owner][spender];
    }

    function getCirculatingSupply() public view returns (uint256) 
    {
        return totalSupply.sub(balanceOf(address(0)));
    }

    function setMaxTx(uint256 value) external onlyOwner() 
    {
        require(value >= totalSupply / 10000, "SolarGuard: Minimum tx must be greater than 0.01% of total supply!");

        maxTx = value;
    }

    function setMaxWallet(uint256 value) external onlyOwner 
    {
        require(value >= totalSupply / 10000, "SolarGuard: Minimum wallet size must be greater than 0.01% of total supply!");

        maxWallet = value;
    }

    function setMinerAddress(address wallet) external onlyOwner() 
    {
        require(wallet != address(0), "SolarGuard: Wallet must not be null address!");

        minerAddress = payable(wallet);
    }

    function setTreasuryAddress(address wallet) external onlyOwner() 
    {
        require(wallet != address(0), "SolarGuard: Wallet must not be null address!");

        treasuryAddress = payable(wallet);
    }

    function setMarketingAddress(address wallet) external onlyOwner() 
    {
        require(wallet != address(0), "SolarGuard: Wallet must not be null address!");

        marketingAddress = payable(wallet);
    }

    function setWalletFeeStatus(address wallet, bool status) public onlyOwner 
    {
        isFeeExempt[wallet] = status;
    }

    function setWalletTxStatus(address wallet, bool status) external onlyOwner 
    {
        isTxLimitExempt[wallet] = status;
    }

    function setWalletLimitStatus(address wallet, bool status) external onlyOwner 
    {
        isWalletLimitExempt[wallet] = status;
    }

    function setMarketPairStatus(address wallet, bool status) public onlyOwner 
    {
        isMarketPair[wallet] = status;
    }

    function setBotStatus(address[] memory wallets, bool status) public onlyOwner 
    {
        require(wallets.length <= 200, "SolarGuard: Maximum wallets at once is 200!");

        for (uint i = 0; i < wallets.length; i++)
            isBot[wallets[i]] = status;
    }

    function setBuyTaxes(uint miner, uint treasury, uint marketing) external onlyOwner() 
    {
        require(miner + treasury + marketing <= 300, "SolarGuard: Maximum total fee is 30%!");
        
        inFee.miner = miner;
        inFee.treasury = treasury;
        inFee.marketing = marketing;
    }

    function setSellTaxes(uint miner, uint treasury, uint marketing) external onlyOwner() 
    {
        require(miner + treasury + marketing <= 300, "SolarGuard: Maximum total fee is 30%!");

        outFee.miner = miner;
        outFee.treasury = treasury;
        outFee.marketing = marketing;
    }

    function setSwapThreshold(uint value) external onlyOwner() 
    {
        swapThreshold = value;
    }

    function setSwapAndLiquifyStatus(bool status) public onlyOwner 
    {
        swapAndLiquifyEnabled = status;
        emit SwapAndLiquifyEnabledUpdated(status);
    }

    function setSwapAndLiquifyByLimitStatus(bool status) public onlyOwner 
    {
        swapAndLiquifyByLimitOnly = status;
    }

    function increaseAllowance(address spender, uint addedValue) public virtual returns (bool) 
    {
        _approve(_msgSender(), spender, allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedValue) public virtual returns (bool) 
    {
        _approve(_msgSender(), spender, allowances[_msgSender()][spender].sub(subtractedValue, "SolarGuard: Decreased allowance below zero!"));
        return true;
    }

    function approve(address spender, uint amount) public override returns (bool) 
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint amount) private 
    {
        require(owner != address(0), "SolarGuard: Approve from the zero address!");
        require(spender != address(0), "SolarGuard: Approve to the zero address!");

        allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transferToAddressBNB(address payable recipient, uint amount) private 
    {
        require(recipient != address(0), "SolarGuard: Cannot send to the 0 address!");

        recipient.transfer(amount);
    }

    function transfer(address recipient, uint amount) public override returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint amount) public override returns (bool)
    {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), allowances[sender][_msgSender()].sub(amount, "SolarGuard: Transfer amount exceeds allowance!"));
        return true;
    }

    function _transfer(address sender, address recipient, uint amount) private returns (bool)
    {
        require(sender != address(0), "SolarGuard: Transfer from the zero address!");
        require(recipient != address(0), "SolarGuard: Transfer to the zero address!");
        require(!isBot[recipient] && !isBot[sender], "SolarGuard: No bots allowed!");

        if (inSwapAndLiquify)
        {
            balances[sender] = balances[sender].sub(amount, "SolarGuard: Insufficient balance!");
            balances[recipient] = balances[recipient].add(amount);

            emit Transfer(sender, recipient, amount);
            return true;
        }
        else
        {
            if (!isTxLimitExempt[sender] && !isTxLimitExempt[recipient])
                require(amount <= maxTx, "SolarGuard: Transfer amount exceeds the maxTx!");

            uint contractTokenBalance = balanceOf(address(this));
            if (contractTokenBalance >= swapThreshold && !inSwapAndLiquify && !isMarketPair[sender] && swapAndLiquifyEnabled)
            {
                if (swapAndLiquifyByLimitOnly)
                    contractTokenBalance = swapThreshold;

                swapAndLiquify(contractTokenBalance);
            }

            balances[sender] = balances[sender].sub(amount, "SolarGuard: Insufficient balance!");

            uint finalAmount = (isFeeExempt[sender] || isFeeExempt[recipient]) ? amount : takeFee(sender, recipient, amount);
            if (!isWalletLimitExempt[recipient])
                require(balanceOf(recipient).add(finalAmount) <= maxWallet, "SolarGuard: Transfer amount must not exceed max wallet conditions!");

            balances[recipient] = balances[recipient].add(finalAmount);

            emit Transfer(sender, recipient, finalAmount);
            return true;
        }
    }

    function swapAndLiquify(uint amount) private lockTheSwap 
    {
        swapTokensForEth(amount);
        uint amountReceived = address(this).balance;

        uint totalFee = inFee.miner + inFee.treasury + inFee.marketing + outFee.miner + outFee.treasury + outFee.marketing;

        uint minerAmount = amountReceived.mul((inFee.miner + outFee.miner)).div(totalFee);
        uint treasuryAmount = amountReceived.mul((inFee.treasury + outFee.treasury)).div(totalFee);
        uint marketingAmount = amountReceived.mul((inFee.marketing + outFee.marketing)).div(totalFee);

        if (minerAmount > 0)
            transferToAddressBNB(minerAddress, minerAmount);
        if (treasuryAmount > 0)
            transferToAddressBNB(treasuryAddress, treasuryAmount);
        if (marketingAmount > 0)
            transferToAddressBNB(marketingAddress, marketingAmount);
    }

    function swapTokensForEth(uint tokenAmount) private
    {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

        emit SwapTokensForETH(tokenAmount, path);
    }

    function takeFee(address sender, address recipient, uint amount) internal returns (uint256)
    {
        uint feeAmount = 0;

        if (isMarketPair[sender])
            feeAmount = amount.mul(inFee.miner + inFee.treasury + inFee.marketing).div(1000);
        else if (isMarketPair[recipient])
            feeAmount = amount.mul(outFee.miner + outFee.treasury + outFee.marketing).div(1000);

        if (feeAmount > 0)
        {
            balances[address(this)] = balances[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
        }

        return amount.sub(feeAmount);
    }

    function withdrawStuckBNB(address recipient, uint amount) public onlyOwner
    {
        require(recipient != address(0), "SolarGuard: Cannot send to the 0 address!");

        payable(recipient).transfer(amount);
    }

    function withdrawForeignToken(address tokenAddress, address recipient, uint amount) public onlyOwner
    {
        require(recipient != address(0), "SolarGuard: Cannot send to the 0 address!");

        IERC20(tokenAddress).transfer(recipient, amount);
    }

    receive() external payable {}
}