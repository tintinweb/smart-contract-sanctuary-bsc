/**
 * Develop by CPTRedHawk
 * @ Esse contrato Foi desenvolvido por https://t.me/redhawknfts
 * Caso queira ter uma plataforma similar, gentileza chamar no Telegram!
 * SPDX-License-Identifier: MIT
 * Entrega teu caminho ao senhor, e tudo ele o fará! Salmos 37
 */

pragma solidity ^0.8.17;

import "./interfaceIBEP20.sol";
import "./SafeMath.sol";
import "./Ownable.sol";
import "./Address.sol";
import "./interfaceIUniswapV2Factory.sol";
import "./interfaceIUniswapV2Pair.sol";
import "./interfaceIUniswapV2Router01.sol";
import "./interfaceIUniswapV2Router02.sol";
import "./DividendsPaying.sol";


contract Legitimik is IBEP20, Ownable {
    /*=== SafeMath ===*/
    using SafeMath for uint256;
    using Address for address;
    /*=== Endereços ===*/
    address private burnAddress = address(0); // Endereço de Queima
    address private internalOperationAddress; // Distribui as Recompensas para os Holders
    DividendsPaying public dividends; // Endeço de Dividendos
    IUniswapV2Router02 public  uniswapV2Router; // Endereço Router
    address public  uniswapV2Pair; // Par LGK/BNB
    /*=== Mapeamento ===*/
    mapping (address => uint256) private _balance; // Saldo dos Holders
    mapping (address => bool) public _excludeFromFee; // Nao paga Taxas
    mapping (address => bool) private automatedMarketMakerPairs; // Automatizado de Trocas
    mapping (address => mapping(address => uint256)) private _allowances; // Subsidio
    mapping (address => bool) public isTimelockExempt; // Nao tem Tempo de Espera
    mapping (address => uint) public cooldownTimerBuy; // Tempo de Compra
    mapping (address => uint) public cooldownTimerSell; // Tempo de Venda
    mapping (address => bool) public _isBlackListAddress; // Adiciona na Lista Negra
    /*=== Unitarios ===*/
    uint8 private _decimals = 18;
    uint8 public cooldownTimerInterval = 20; // Tempo de espera entre compra e venda
    uint256 private _decimalFactor = 10**_decimals; // Fator Decimal
    uint256 private _tSupply = 20000000 * _decimalFactor; // Supply Legitimik
    uint256 public buyFee = 10; // Taxa de Compra
    uint256 private previousBuyFee; // Armazena Taxa de Compra
    uint256 public sellFee = 10; // Taxa de Venda
    uint256 private previousSellFee; // Armazena Taxa de Venda
    uint256 public transferFee = 10; // Taxa de Transferencia
    uint256 private previousTransferFee; // Armazena Taxa de Transferencia
    uint256 public feeUsers = 2; 
    uint256 public liquidityPercent = 20; // Taxa de Liquidez 20%
    uint256 public totalFeeLGK; // Mostra o Total de Taxas Arrecadadas em LGK
    uint256 public totalFeeBNB; // Mostra o Total de Taxas Arrecadadas em BNB
    uint256 private gasForProcessing = 300000; // Gás para iterar
    uint256 public maxWalletBalance = 5000 * _decimalFactor; // 1% do Supply
    uint256 public maxBuyAmount = 3000 * _decimalFactor; // 1% do Supply
    uint256 public maxSellAmount = 3000 * _decimalFactor; // 1% do Supply
    uint256 public maxTxAmount = 5000 * _decimalFactor; // 1% do Supply
    uint256 public numberOfTokensToSwapToLiquidity = 500 * _decimalFactor; // 0,05% do Supply
    /*=== Boolean ===*/
    bool private inSwapAndLiquify; 
    bool private coolDownUser;
    bool private blackUser;
    bool private swapping;
    bool private activeDividends = true;
    bool public buyCooldownEnabled = true;
    bool public sellCooldownEnabled = true;
    bool private isSendToken = true;
    bool private blackEnabled = true;
    bool private swapAndLiquifyEnabled = true;
    /*=== Strings ===*/
    string private _name = "Legitimik";
    string private _symbol =  "LGK";
    /*=== Modifiers ===*/
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    modifier lockCoolDown {
        coolDownUser = true;
        _;
        coolDownUser = false;
    }
    modifier blackList {
        blackUser = true;
        _;
        blackUser = false;
    }
    /*=== Construtor ===*/
    constructor() {
        //  IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); // PancakeSwap Router Testnet
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); // PancakeSwap Router Mainnet
        address pairCreated = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH()); // Gera o Par ARC/BNB
        uniswapV2Router = _uniswapV2Router; // Armazena Rota
        uniswapV2Pair = pairCreated; // Armazena Par
        _balance[owner()] = _tSupply; // Define Owner como Detentor dos _Tokens
        dividends = new DividendsPaying(); // Define Endereço de Dividendos
        dividends.excludeFromDividends(address(this), true); // Define Contrato como True para nao Receber Dividendos
        dividends.excludeFromDividends(owner(), true); // Define Owner como True para nao Receber Dividendos
        dividends.excludeFromDividends(uniswapV2Pair, true); // Define Owner como True para nao Receber Dividendoss
        internalOperationAddress = owner(); // Define Endereço de Operações
        _excludeFromFee[owner()] = true; // Define Owner como True para não pagar Taxas
        _excludeFromFee[address(this)] = true; // Define Contrato como True para não pagar Taxas
        _excludeFromFee[internalOperationAddress] = true; // Define internalOperationAddress como True para não pagar Taxas
        isTimelockExempt[owner()] = true; // Owner Nao tem tempo de espera para compra e venda
        isTimelockExempt[address(this)] = true; // Contrato Nao tem tempo de espera para compra e venda
       _setAutomatedMarketMakerPair(pairCreated, true); // Pair é o Automatizador de Transações
       _approve(owner(), address(uniswapV2Router), ~uint256(0)); // Aprova Tokens para Add Liquidez
        emit Transfer(address(0), owner(), _tSupply); // Emite um Evento de Cunhagem
    }
    /*=== Receive ===*/
    receive() external payable {}
    /*=== Eventos ===*/
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiquidity);
    event SwapAndLiquifyEnabledUpdated(bool indexed enabled);
    event LiquidityAdded(uint256 tokenAmountSent, uint256 ethAmountSent, uint256 liquidity);
    event UpdatedBlackList(address indexed account, bool isExcluded);
    event SentBNBInternalOperation(address usr, uint256 amount);
    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event ProcessedDividendTracker(
    	uint256 iterations,
    	uint256 claims,
        uint256 lastProcessedIndex,
    	bool indexed automatic,
    	uint256 gas,
    	address indexed processor
    );
    /*=== Public View ===*/
    function name() public view override returns(string memory) { return _name; } // Nome do Token
    function symbol() public view override returns(string memory) { return _symbol; } // Simbolo do Token
    function decimals() public view override returns(uint8) { return _decimals; } // Decimais
    function totalSupply() public view override returns(uint256) { return _tSupply; } // Supply Total
    function balanceOf(address account) public view override returns(uint256) { return _balance[account]; } // Retorna o Saldo em Carteira
    function allowance(address owner, address spender) public view override returns(uint256) { return _allowances[owner][spender]; } // Subsidio Restante
    function accumulativeDividendOf(address account) public view returns(uint256) {
        return dividends.accumulativeDividendOf(account);
    }
    function withdrawableDividendOf(address account) public view returns(uint256) {
        return dividends.withdrawableDividendOf(account);
    }
    function balanceDividends(address account) public view returns(uint256) {
        return dividends.balanceOf(account);
    }
    /*=== Private/Internal ===*/
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "O par de AutomatedMarketMakerPair ja esta definido para esse valor");
        automatedMarketMakerPairs[pair] = value; // Booleano
        emit SetAutomatedMarketMakerPair(pair, value); // Emite um Evento para um Novo Automatizador de Trocas
    }
    function _setRouterAddress(address router) private {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router); // Router
        address pairCreated = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH()); // Gera o Par LGK/BNB
        uniswapV2Router = _uniswapV2Router; // Armazena Rota
        uniswapV2Pair = pairCreated; // Armazena Par
        _setAutomatedMarketMakerPair(uniswapV2Pair, true); // Armazena o novo Par como o Automatizador de Trocas
    }
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ARC:Owner nao pode ser Address 0");
        require(spender != address(0), "ARC:Owner nao pode ser Address 0");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _spendAllowance(address owner, address spender, uint256 amount) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if(currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ARC: subsidio insuficiente");
            _approve(owner, spender, currentAllowance - amount);
        }
    }
    function _unlimitedAddress(address account) internal view returns(bool) {
        if(_excludeFromFee[account]) {
            return true;
        }
        else {return false;}
    }
    function buyCoolDown(address to) private lockCoolDown {
        cooldownTimerBuy[to] = block.timestamp; // Ativa o Tempo de Compra
    }
    function sellCoolDown(address from) private lockCoolDown  {
        cooldownTimerSell[from] = block.timestamp; // Ativa o Tempo de Venda
    }
    function lockToBuyOrSellForTime(uint256 lastBuyOrSellTime, uint256 lockTime) private lockCoolDown returns (bool) {
        uint256 crashTime = lastBuyOrSellTime + lockTime;
        uint256 currentTime = block.timestamp;
        if(currentTime >= crashTime) {
            return true;
        }

        return false;
    }
    function getFromLastPurchaseBuy(address walletBuy) private view returns (uint) {
        return cooldownTimerBuy[walletBuy];
    }
    function getFromLastSell(address walletSell) private view returns (uint) {
        return cooldownTimerSell[walletSell];
    }
    function _beforeTokenTransfer( address from, address to, uint256 amount ) internal virtual{}
    function _afterTokenTransfer( address from, address to, uint256 amount ) internal virtual{}
    function _transferTokens(address from, address to, uint256 amount) internal {
        require(to != from, "Nao pode enviar para o mesmo Endereco");
        require(amount > 0, "Saldo precisa ser maior do que Zero");
        _beforeTokenTransfer(from, to, amount);

        if(blackEnabled && !blackUser) {
           require(!_isBlacklist(from) && !_isBlacklist(to), "Voce esta na Lista Negra");
        }
        
        uint256 fromBalance = _balance[from];
        require(fromBalance >= amount, "Voce nao tem Limite de Saldo");
        _balance[from] = fromBalance - amount;

        uint256 contractTokenBalance = balanceOf(address(this));
        if (!automatedMarketMakerPairs[from] && automatedMarketMakerPairs[to]) {
            swapping = true;
            liquify( contractTokenBalance, from );
            swapping = false;
        }

        bool takeFee = true;

        if(_excludeFromFee[from] || _excludeFromFee[to]){
            takeFee = false;
        }

        if(!takeFee) removeAllFee(); // Remove todas as Taxa

            uint256 fees; // Taxas de Compra, Vendas e Transferencias!

            if(!automatedMarketMakerPairs[from] && !automatedMarketMakerPairs[to] ) {
                fees = amount.mul(transferFee).div(100); // Define taxa de Transferencia
                if (amount > maxTxAmount && !_unlimitedAddress(from) && !_unlimitedAddress(to)) {
                    revert("Montante de Venda nao pode ultrapassar limite"); 
                }
            }

            if(automatedMarketMakerPairs[from]) {
                fees = amount.mul(buyFee).div(100); // Define taxa de Compra
                if (amount > maxBuyAmount && !_unlimitedAddress(from) && !_unlimitedAddress(to)) {
                    revert("Montante de Venda nao pode ultrapassar limite"); 
                }

                if(buyCooldownEnabled && !isTimelockExempt[to] && !coolDownUser) {
                    require(lockToBuyOrSellForTime(getFromLastPurchaseBuy(to), cooldownTimerInterval), "Por favor, aguarde o cooldown entre as compras");
                    buyCoolDown(to);
                }
            }
            else if(automatedMarketMakerPairs[to]) {
                fees = amount.mul(sellFee).div(100); // Define taxa de Venda
                if (amount > maxSellAmount && !_unlimitedAddress(from) && !_unlimitedAddress(to)) {
                    revert("Montante de Venda nao pode ultrapassar limite"); 
                }

                if(sellCooldownEnabled && !isTimelockExempt[from] && !coolDownUser) {
                    require(lockToBuyOrSellForTime(getFromLastSell(from), cooldownTimerInterval), "Por favor, aguarde o cooldown entre as vendas");
                    sellCoolDown(from);
                }
            }

            if(maxWalletBalance > 0 && !_unlimitedAddress(from) && !_unlimitedAddress(to) && !automatedMarketMakerPairs[to]) {
                uint256 recipientBalance = balanceOf(to); // Define o Maximo por Wallet
                require(recipientBalance.add(amount) <= maxWalletBalance, "Nao pode Ultrapassar o limite por Wallet");
            }

            if(fees > 0) {
                amount = amount.sub(fees);
                _balance[address(this)] += fees;
                emit Transfer(from, address(this), fees); // Emite um Evento de Envio de Taxas
            }

            _balance[to] += amount;




            if (activeDividends) {

                try dividends.setBalance(payable(from), balanceOf(from)) {} catch {}
                try dividends.setBalance(payable(to), balanceOf(to)) {} catch {}

                if(!swapping) {
                    uint256 gas = gasForProcessing;

                    try dividends.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
                        emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin);
                    } 
                    catch {

                    }
                }

                
            }


            
            emit Transfer(from, to, amount); // Emite um Evento de Transferencia
            _afterTokenTransfer(from, to, amount);
        if(!takeFee) restoreAllFee(); // Retorna todas as Taxa
    }
    function removeAllFee() private {
        if(buyFee == 0 || sellFee == 0 || transferFee == 0) return;
        previousBuyFee = buyFee; // Armazena Taxa Anterior
        previousSellFee = sellFee; // Armazena Taxa Anterior
        previousTransferFee = transferFee; // Armazena Taxa Anterior
        buyFee = 0; // Taxa 0
        sellFee = 0; // Taxa 0
        transferFee = 0; // Taxa 0
    }
    function restoreAllFee() private {
        buyFee = previousBuyFee; // Restaura Taxas
        sellFee = previousSellFee; // Restaura Taxas
        transferFee = previousTransferFee; // Restaura Taxas
    }  
    function liquify(uint256 contractTokenBalance, address sender) internal {
        
        if (contractTokenBalance >= numberOfTokensToSwapToLiquidity) contractTokenBalance = numberOfTokensToSwapToLiquidity; // Define se a Quantidade de Tokens para
        
        bool isOverRequiredTokenBalance = ( contractTokenBalance >= numberOfTokensToSwapToLiquidity ); // Booleano
        
        if ( isOverRequiredTokenBalance && swapAndLiquifyEnabled && !inSwapAndLiquify && (!automatedMarketMakerPairs[sender]) ) {
            uint256 tokenLiquidity = contractTokenBalance.mul(liquidityPercent).div(100); // Quantidade de Tokens que vai para Liquidez
            uint256 toSwapBNB = contractTokenBalance.sub(tokenLiquidity); // Quantidade de Tokens para Venda
            _swapAndLiquify(tokenLiquidity); // Adiciona Liquidez
            _sendBNBToContract(toSwapBNB); // Troca Tokens por BNB
        }

    }
    function _swapAndLiquify(uint256 amount) private lockTheSwap {
        uint256 half = amount.div(2); // Divide para Adicionar Liquidez
        uint256 otherHalf = amount.sub(half); // Divide para Adicionar Liquidez
        uint256 initialBalance = address(this).balance; // Armazena o Saldo Inicial em BNB
        _swapTokensForEth(half); // Efetua a troca de Token por BNB
        uint256 newBalance = address(this).balance.sub(initialBalance); // Saldo atual em BNB - Saldo Antigo
        _addLiquidity(otherHalf, newBalance); // Adiciona Liquidez
        emit SwapAndLiquify(half, newBalance, otherHalf); // Emite Evento de Swap
    }
    function _sendBNBToContract(uint256 tAmount) private lockTheSwap {
         _swapTokensForEth(tAmount); // Vende os Tokens por BNB e envia para o Contrato
        if(isSendToken) {
            uint256 initialBalance = address(this).balance;
            if(initialBalance > 0) {
    
                (bool sent, ) = internalOperationAddress.call{value: address(this).balance}("");
                if(sent) {
                    emit SentBNBInternalOperation(internalOperationAddress, initialBalance);
                }
            } 
        }
    }

    function _swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2); // Path Memory para inicia a venda dos Tokens
        path[0] = address(this); // Endereço do Contrato
        path[1] = uniswapV2Router.WETH(); // Par de Troca (BNB)
        _approve(address(this), address(uniswapV2Router), tokenAmount); // Aprova os Tokens para Troca
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount, // Saldo para Swap
            0, // Amount BNB
            path, // Path [address(this), uniswapV2Router.WETH()]
            address(this), // Endereço de Taxa
            block.timestamp // Timestamp
        );
    }
    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        (uint256 tokenAmountSent, uint256 ethAmountSent, uint256 liquidity) = uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount, // Saldo para Liquidez
            0, // Slippage 0
            0, // Slippage 0
            owner(), // Owner Adiciona Liquidez
            block.timestamp // Timestamp
        );
        emit LiquidityAdded(tokenAmountSent, ethAmountSent, liquidity); // Emite Evento de Liquidez
    }
    function _isBlacklist(address user) private blackList returns(bool) {
       return _isBlackListAddress[user]; // Verifica se From esta na Blacklist
    }
    /*=== Public/External ===*/
    function approve(address spender, uint256 amount) public override returns(bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transfer(address to, uint256 amount) public override returns(bool){
        _transferTokens(_msgSender(), to, amount);
        return true;
    }
    function transferFrom(address from, address to, uint256 amount) public override returns(bool) {
        _spendAllowance(from, _msgSender(), amount);
         _transferTokens(from, to, amount);
        return true;
    }

    /*=== Funções Administrativas ===*/

    function changeAutomatedMarketMakerPair(address pair, bool value) external onlyOwner {
        require(pair != uniswapV2Pair, "uniswapV2Pair nao pode ser removido de AutomatedMarketMakerPair");
        _setAutomatedMarketMakerPair(pair, value); // Define um Novo Automatizador de Trocas
    }
    function changeFees(uint256 _buyFee, uint256 _sellFee, uint256 _transferFee, uint256 _liquidityPercent) external onlyOwner {
        buyFee = _buyFee;
        sellFee = _sellFee;
        transferFee = _transferFee;
        liquidityPercent = _liquidityPercent;
    }
    function changeAddress(address _internalOperationAddress) external onlyOwner {
        internalOperationAddress = _internalOperationAddress; // Define Endereço de Operações
    }
    function getLostBNB() external payable onlyOwner {
        dividends.getLostBNB(_msgSender()); // Pega os BNB Perdidos do Dividendos
    }
    function removeBNBLGK() external payable onlyOwner {
        uint256 balance = address(this).balance;
        if(balance > 0) {
            (bool success, ) = _msgSender().call{ value: balance }("");
            require(success, "Address: unable to send value, recipient may have reverted");
        }
    }
    function getTokenContract(address account, uint256 amount) external  onlyOwner {
        _transferTokens(address(this), account, amount);
    }
    function processDividendTracker(uint256 gas) external {
		(uint256 iterations, uint256 claims, uint256 lastProcessedIndex) = dividends.process(gas);
		emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, false, gas, tx.origin);
    }
    function setLimitContract(uint256 _maxWalletBalance, uint256 _maxBuyAmount, uint256 _maxSellAmount, uint256 _maxTxAmount) external onlyOwner {
        maxWalletBalance = _maxWalletBalance * _decimalFactor; 
        maxBuyAmount = _maxBuyAmount * _decimalFactor; 
        maxSellAmount = _maxSellAmount * _decimalFactor; 
        maxTxAmount = _maxTxAmount * _decimalFactor; 
    }
    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "gasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "Cannot update gasForProcessing to same value");
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }
    function defineExcluded(address account, bool isTrue) external onlyOwner {
        _excludeFromFee[account] = isTrue; // Exclui das Taxas e dos Limites
    }
    function setRouter(address router) external onlyOwner {
        _setRouterAddress(router); // Define uma Nova Rota (Caso Pancakeswap migre para a RouterV3 e adiante)
    }
    function setIsSwap(bool isTrue) external onlyOwner {
        swapAndLiquifyEnabled = isTrue; // Ativa e Desativa o Swap
        emit SwapAndLiquifyEnabledUpdated(swapAndLiquifyEnabled); // Emite Evento de Swap Ativo/Inativo
    }
    function setActiveCoolDown(bool _buyCooldownEnabled, bool _sellCooldownEnabled, uint8 _cooldownTimerInterval) external onlyOwner {
        buyCooldownEnabled = _buyCooldownEnabled; // Ativa e Desativa Cooldown Buy
        sellCooldownEnabled = _sellCooldownEnabled; // Ativa e Desativa Cooldown Sell
        cooldownTimerInterval = _cooldownTimerInterval; // Define Segundos entre Compra e Venda
    }
    function activeSendDividends(bool _isSendToken) external onlyOwner {
        isSendToken = _isSendToken;
    }
    function burnToken(uint256 _burnAmount) external onlyOwner {
        _transferTokens(_msgSender(), burnAddress, _burnAmount); // Apenas o Owner pode realizar Queimas
    }
    function setSwapAmount(uint256 tAmount) external onlyOwner {
        numberOfTokensToSwapToLiquidity = tAmount * _decimalFactor; // Define a quantidade de Tokens que o Contrato vai Vender
    }
    function updateDividends(address newAddress) external onlyOwner {
      DividendsPaying newDividends = DividendsPaying(payable(newAddress));
      dividends = newDividends;
    }
    function setBlacklist(bool _blackEnabled) external onlyOwner {
        blackEnabled = _blackEnabled; // Ativa Blacklist
    }
    function changeBlacklistUser(address user, bool isTrue) external onlyOwner {
        _isBlackListAddress[user] = isTrue;
        emit UpdatedBlackList(user, isTrue);
    }
    function defineActiveDividends(bool isTrue) external onlyOwner {
        activeDividends = isTrue;
    }
    function updateClaimWait(uint256 claimWait) external onlyOwner {
        dividends.updateClaimWait(claimWait);
    }
    function claim() external {
		dividends.processAccount(payable(msg.sender), false);
    }
    function excludeFromDividends(address user, bool isTrue) external onlyOwner {
        dividends.excludeFromDividends(user, isTrue);
    }
    function setminimumTokenBalanceForDividends(uint256 amount) external onlyOwner {
        dividends.setminimumTokenBalanceForDividends(amount);
    }

}