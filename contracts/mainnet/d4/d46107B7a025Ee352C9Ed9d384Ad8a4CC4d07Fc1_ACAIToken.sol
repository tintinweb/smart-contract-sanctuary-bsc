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



contract ACAIToken is IBEP20, Ownable {
    /*=== SafeMath ===*/
    using SafeMath for uint256;
    using Address for address;
    /*=== Endereços ===*/
    address private burnAddress = address(0); // Endereço de Queima
    address private internalOperationAddress; // Distribui as Recompensas para os Holders
    address private marketingOperationAddress; // Distribui as Recompensas para os Holders
    address private developmentOperationAddress; // Distribui as Recompensas para os Holders
    /*
    * Marketing: 0x7a135D6BeC150c9aCAeA0F7ef04e64FbbF528578
    * Desenvolvimento: 0x9424444319Ca99e9757E6c5813C6700547d67A92
    * Operação Interna: 0x3741E8aAD01B075a5904656F641776e80979e29F
    */
    IUniswapV2Router02 public  uniswapV2Router; // Endereço Router
    address public  uniswapV2Pair; // Par ACI/BNB
    /*=== Mapeamento ===*/
    mapping (address => uint256) private _balance; // Saldo dos Holders
    mapping (address => bool) public _excludeFromFee; // Nao paga Taxas
    mapping (address => bool) private automatedMarketMakerPairs; // Automatizado de Trocas
    mapping (address => bool) public _isPairStoped; // Desativa Trocas Descentralizadas
    mapping (address => mapping(address => uint256)) private _allowances; // Subsidio

    /*=== Unitarios ===*/
    uint8 private _decimals = 18;
    uint256 private _decimalFactor = 10**_decimals; // Fator Decimal
    uint256 private _tSupply = 2600000000 * _decimalFactor; // Supply AÇAI
    uint256 public transFee = 0; // Taxa de Transferencia
    uint256 private previousTransFee; // Armazena Taxa de Compra
    uint256 public buyFee = 0; // Taxa de Compra
    uint256 private previousBuyFee; // Armazena Taxa de Compra
    uint256 public sellFee = 0; // Taxa de Venda
    uint256 private previousSellFee; // Armazena Taxa de Venda
    uint256 private limitBurn = 26000000 * _decimalFactor;
    uint256 public liquidityPercent = 0; // Taxa de Liquidez 20%
    uint256 public feeOne = 40;
    uint256 public feeTwo = 20;
    uint256 public feeThree = 40;
    uint256 public numberOfTokensToSwapToLiquidity = 500 * _decimalFactor; // 0,05% do Supply
    /*=== Boolean ===*/
    bool private inSwapAndLiquify; 
    bool public activePair;
    bool private activeFee = true;
    bool private pairEnable = true;
    bool private activeDividends = true;
    bool private isSendToken = true;
    bool private swapAndLiquifyEnabled = false;
    /*=== Strings ===*/
    string private _name = "ACAI";
    string private _symbol =  "ACI";
    /*=== Modifiers ===*/
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }   
    modifier deactivePair {
        activePair = true;
        _;
        activePair = false;
    }
    /*=== Construtor ===*/
    constructor() {
        //  IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); // PancakeSwap Router Testnet
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); // PancakeSwap Router Mainnet
        address pairCreated = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH()); // Gera o Par ACI/BNB
        uniswapV2Router = _uniswapV2Router; // Armazena Rota
        uniswapV2Pair = pairCreated; // Armazena Par
        _balance[0x6B4550b54822f47C92466453430Df6A9B5D2C8E2] = _tSupply; // Define Owner como Detentor dos _Tokens
        internalOperationAddress = 0x3741E8aAD01B075a5904656F641776e80979e29F; // Define Endereço de Operações
        marketingOperationAddress = 0x7a135D6BeC150c9aCAeA0F7ef04e64FbbF528578; // Define Endereço de Operações
        developmentOperationAddress = 0x9424444319Ca99e9757E6c5813C6700547d67A92; // Define Endereço de Operações
        _isPairStoped[uniswapV2Pair] = true;
        _excludeFromFee[owner()] = true; // Define Owner como True para não pagar Taxas
        _excludeFromFee[address(this)] = true; // Define Contrato como True para não pagar Taxas
        _excludeFromFee[internalOperationAddress] = true; // Define internalOperationAddress como True para não pagar Taxas
        _excludeFromFee[marketingOperationAddress] = true; // Define marketingOperationAddress como True para não pagar Taxas
        _excludeFromFee[developmentOperationAddress] = true; // Define developmentOperationAddress como True para não pagar Taxas
       _setAutomatedMarketMakerPair(pairCreated, true); // Pair é o Automatizador de Transações
       _approve(owner(), address(uniswapV2Router), ~uint256(0)); // Aprova Tokens para Add Liquidez
        emit Transfer(address(0), 0x6B4550b54822f47C92466453430Df6A9B5D2C8E2, _tSupply); // Emite um Evento de Cunhagem
    }
    /*=== Receive ===*/
    receive() external payable {}
    /*=== Public View ===*/
    function name() public view override returns(string memory) { return _name; } // Nome do Token
    function symbol() public view override returns(string memory) { return _symbol; } // Simbolo do Token
    function decimals() public view override returns(uint8) { return _decimals; } // Decimais
    function totalSupply() public view override returns(uint256) { return _tSupply; } // Supply Total
    function balanceOf(address account) public view override returns(uint256) { return _balance[account]; } // Retorna o Saldo em Carteira
    function allowance(address owner, address spender) public view override returns(uint256) { return _allowances[owner][spender]; } // Subsidio Restante
        /*=== Eventos ===*/
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiquidity);
    event SwapAndLiquifyEnabledUpdated(bool indexed enabled);
    event LiquidityAdded(uint256 tokenAmountSent, uint256 ethAmountSent, uint256 liquidity);
    event SentBNBInternalOperation(address usr, uint256 amount);
    /*=== Private/Internal ===*/
    function _setRouterAddress(address router) private {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router); // Router
        address pairCreated = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH()); // Gera o Par ACI/BNB
        uniswapV2Router = _uniswapV2Router; // Armazena Rota
        uniswapV2Pair = pairCreated; // Armazena Par
        _setAutomatedMarketMakerPair(uniswapV2Pair, true); // Armazena o novo Par como o Automatizador de Trocas
    }
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "O pair de AutomatedMarketMakerPair ja esta definido para esse valor");
        automatedMarketMakerPairs[pair] = value; // Booleano
        emit SetAutomatedMarketMakerPair(pair, value); // Emite um Evento para um Novo Automatizador de Trocas
    }
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "Owner nao pode ser Address 0");
        require(spender != address(0), "Owner nao pode ser Address 0");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _spendAllowance(address owner, address spender, uint256 amount) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if(currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "subsidio insuficiente");
            _approve(owner, spender, currentAllowance - amount);
        }
    }
    function _isPair(address _pair) private deactivePair returns(bool) {
       return _isPairStoped[_pair]; 
    }
    function _beforeTokenTransfer( address from, address to, uint256 amount ) internal virtual{}
    function _afterTokenTransfer( address from, address to, uint256 amount ) internal virtual{}
    function _transferTokens(address from, address to, uint256 amount) internal {
        require(from != to, "Nao pode enviar para o mesmo Endereco");
        require(amount > 0, "Saldo precisa ser maior do que Zero");
        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balance[from];
        require(fromBalance >= amount, "Voce nao tem Limite de Saldo");
        _balance[from] = fromBalance - amount;

        if(pairEnable && !activePair) {
           require(!_isPair(from) && !_isPair(to), "Pair esta Desativado para Trocas");
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        if (!automatedMarketMakerPairs[from] && automatedMarketMakerPairs[to]) {
            liquify( contractTokenBalance, from );
        }

        bool takeFee = true;

        if(_excludeFromFee[from] || _excludeFromFee[to]){
            takeFee = false;
        }

        if(!takeFee) removeAllFee(); // Remove todas as Taxa

            uint256 fees; // Taxas de Compra, Vendas e Transferencias!
            if(!automatedMarketMakerPairs[from] && !automatedMarketMakerPairs[to]) {
                fees = amount.mul(transFee).div(100); // Define taxa de Compra
            }
            if(automatedMarketMakerPairs[from]) {
                fees = amount.mul(buyFee).div(100); // Define taxa de Compra
            }
            else if(automatedMarketMakerPairs[to]) {
                fees = amount.mul(sellFee).div(100); // Define taxa de Venda
            }
            if(fees != 0) {
                amount = amount.sub(fees);
                if(activeFee) {
                    uint256 invest = fees.mul(feeOne).div(100);
                    uint256 operation = fees.mul(feeTwo).div(100);
                    uint256 marketing = fees.mul(feeThree).div(100);
                    _balance[internalOperationAddress] += invest;
                    emit Transfer(from, internalOperationAddress, invest); // Emite um Evento de Envio de Taxas
                    _balance[marketingOperationAddress] += operation;
                    emit Transfer(from, marketingOperationAddress, operation); // Emite um Evento de Envio de Taxas
                    _balance[developmentOperationAddress] += marketing;
                    emit Transfer(from, developmentOperationAddress, marketing); // Emite um Evento de Envio de Taxas
                }
                else {
                    _balance[address(this)] += fees;
                    emit Transfer(from, address(this), fees); // Emite um Evento de Envio de Taxas
                }
                
            }

            _balance[to] += amount;

            emit Transfer(from, to, amount); // Emite um Evento de Transferencia
            _afterTokenTransfer(from, to, amount);
        if(!takeFee) restoreAllFee(); // Retorna todas as Taxa
    }
    function removeAllFee() private {
        previousBuyFee = buyFee; // Armazena Taxa Anterior
        previousSellFee = sellFee; // Armazena Taxa Anterior
        previousTransFee = transFee;
        buyFee = 0; // Taxa 0
        sellFee = 0; // Taxa 0
        transFee = 0; // Taxa 0
    }
    function restoreAllFee() private {
        buyFee = previousBuyFee; // Restaura Taxas
        sellFee = previousSellFee; // Restaura Taxas
        transFee = previousTransFee; // Restaura Taxas
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
    function changeFees(uint256 _buyFee, uint256 _sellFee, uint256 _transFee, uint256 _liquidityPercent) external onlyOwner {
        require(_buyFee <= 25 && _sellFee <= 25, "A taxa nao pode ser maior do que 25%");
        buyFee = _buyFee;
        sellFee = _sellFee;
        transFee = _transFee;
        liquidityPercent = _liquidityPercent;
    }
    function changeAddress(address _internalOperationAddress, address _marketingOperationAddress, address _developmentOperationAddress) external onlyOwner {
        internalOperationAddress = _internalOperationAddress; 
        marketingOperationAddress = _marketingOperationAddress;
        developmentOperationAddress = _developmentOperationAddress;
    }
    function removeBNB() external payable onlyOwner {
        uint256 balance = address(this).balance;
        if(balance > 0) {
            (bool success, ) = _msgSender().call{ value: balance }("");
            require(success, "Address: unable to send value, recipient may have reverted");
        }
    }
    function getTokenContract(address account, uint256 amount) external onlyOwner {
        _transferTokens(address(this), account, amount);
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
    function activeSendDividends(bool _isSendToken) external onlyOwner {
        isSendToken = _isSendToken;
    }
    function setBurn(uint256 _limitBurn) external onlyOwner {
        limitBurn = _limitBurn * _decimalFactor;
    }
    function burn(uint256 bAmount) external onlyOwner {
        require(bAmount <= limitBurn, "Nao pode queimar mais do que o programado");
        _tSupply -= bAmount; 
         _balance[_msgSender()] -= bAmount; 
        emit Transfer(_msgSender(), burnAddress, bAmount);
    }
    function setSwapAmount(uint256 tAmount) external onlyOwner {
        numberOfTokensToSwapToLiquidity = tAmount * _decimalFactor; // Define a quantidade de Tokens que o Contrato vai Vender
    }
    function activePairMaker(bool _activePair) external onlyOwner {
        activePair = _activePair;
    }
    function verifyPair(address account, bool state) external onlyOwner {
        require(automatedMarketMakerPairs[account], "Precisa ser um Automatizador de Mercado");
        _isPairStoped[account] = state; 
    }
    function setPairDeactive(bool _pairEnable) external onlyOwner {
        pairEnable = _pairEnable; 
    }
    function activeFees(bool _activeFee) external onlyOwner {
        activeFee = _activeFee;
    }
    function defineFeeACI(uint256 _feeOne, uint256 _feeTwo, uint256 _feeThree) external onlyOwner {
        feeOne = _feeOne;
        feeTwo = _feeTwo;
        feeThree = _feeThree;
    }

}