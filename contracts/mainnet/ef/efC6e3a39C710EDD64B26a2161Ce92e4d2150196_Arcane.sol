/**
 * Develop by CPTRedHawk
 * @ Esse contrato Foi desenvolvido por https://t.me/redhawknfts
 * Caso queira ter uma plataforma similar, gentileza chamar no Telegram!
 * SPDX-License-Identifier: MIT
 * Entrega teu caminho ao senhor, e tudo ele o fará! Salmos 37
 */
pragma solidity ^0.8.15;

import "./Context.sol";
import "./ERC20.sol";
import "./SafeERC20.sol";
import "./SafeMath.sol";
import "./Address.sol";
import "./Ownable.sol";
import "./interfaceIUniswapV2Factory.sol";
import "./interfaceIUniswapV2Pair.sol";
import "./interfaceIUniswapV2Router01.sol";
import "./interfaceIUniswapV2Router02.sol";

contract Arcane is ERC20, Ownable {
    using SafeERC20 for ERC20;
    using SafeMath for uint256;
    using Address for address;
    /*
    ---------------------------------
    -       Mapeamento              -
    ---------------------------------
    */
    mapping (address => bool) public isExcludedFromFee; // Armazena Endereços livre de Taxas
    mapping (address => bool) public automatedMarketMakerPairs; // Armazena o Pair
    mapping (address => bool) public _isBlackListAddress; // Adiciona na Lista Negra
    mapping (address => uint) public cooldownTimerBuy;
    mapping (address => uint) public cooldownTimerSell;
    mapping (address => bool) public isTimelockExempt;
    /*
    ---------------------------------
    -       Booleano                -
    ---------------------------------
    */
    bool private inSwapAndLiquify;
    bool private coolDownUser;
    bool private blackUser;
    bool public tradingOpen;
    bool public launchPhase = true;
    bool private swapAndLiquifyEnabled = true;
    bool private blackEnabled = true;
    bool public buyCooldownEnabled = true;
    bool public sellCooldownEnabled = true;
    /*
    ---------------------------------
    -         Endereços             -
    ---------------------------------
    */
    IUniswapV2Router02 public  uniswapV2Router; // Endereço Router
    address public  uniswapV2Pair; // Par ARC/BNB
    address public developmentAddress; // Endereço de Taxa
    address public burnAddress; // Endereço de Queima
    /*
    ---------------------------------
    -          Numeros              -
    ---------------------------------
    */
    uint256 public buyTax = 12; // Taxa de Compra
    uint256 public sellTax = 12; // Taxa de Venda
    uint256 private _previousBuyTax = buyTax; // Aramazena as Taxas de Compra
    uint256 private _previousSellTax = sellTax; // Aramazena as Taxas de Venda
    uint256 private tTotal; // Tokens Mintados até o momento
    uint256 private maxTotalSupplyToken = 30000000 * 10 ** 18; // Armazena Maximo Supply Maximo
    uint256 public maxSellLimit = 15000000 * 10 ** 18; // Controle a Quantidade de Tokens que podem ser Vendidos
    uint256 public maxBuyLimit = 15000000 * 10 ** 18; // Controle a Quantidade de Tokens que podem ser Vendidos
    uint256 public tokenLiquidityPercent = 10; // 10% Dos Tokens do Contrato vai para Liquidez
    uint256 public maxWalletBalance = 15000000 * 10 ** 18; // Limite de Wallet
    uint256 private numberOfTokensToSwapToLiquidity = 5400 * 10 ** 18; // Vende Tokens do ContratO
    uint256 public launchBlock;
    uint8 public cooldownTimerInterval = 25; // Tempo de espera entre compra e venda
    uint8 public tBlockEnd = 40;
    /*
    ---------------------------------
    -         Modifier              -
    ---------------------------------
    */
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    modifier blackList {
        blackUser = true;
        _;
        blackUser = false;
    }
    modifier lockCoolDown {
        coolDownUser = true;
        _;
        coolDownUser = false;
    }
    /*
    ---------------------------------
    -         Eventos               -
    ---------------------------------
    */
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiquidity);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event LiquidityAdded(uint256 tokenAmountSent, uint256 ethAmountSent, uint256 liquidity);
    event UpdatedBlackList(address indexed account, bool isExcluded);
    /*
    ---------------------------------
    -         Construtor            -
    ---------------------------------
    */
    constructor(uint256 mintToken, address _developmentAddress) ERC20("Arcane Cards", "ARC") {
        developmentAddress = _developmentAddress; // Define Endereço de Desenvolvimento e Recompra
        // IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // PancakeSwap Router Testnet
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); // PancakeSwap Router Mainnet
        address pairCreated = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH()); // Gera o Par ARC/BNB
        uniswapV2Router = _uniswapV2Router; // Armazena Rota
        uniswapV2Pair = pairCreated; // Armazena Par
        _setAutomatedMarketMakerPair(pairCreated, true);
        isExcludedFromFee[address(this)] = true;
        isExcludedFromFee[developmentAddress] = true; // Retira DevelopmentAddress de Taxas
        tTotal = mintToken * 10 ** 18; // Mint Inicial
        _mint(owner(), mintToken * 10 ** 18); // TOkens Mintados
        burnAddress = address(0); // Endereço de Queima
        isTimelockExempt[owner()] = true; // Nao tem tempo de espera para compra e venda
        isTimelockExempt[address(this)] = true; // Nao tem tempo de espera para compra e venda
        isTimelockExempt[developmentAddress] = true; // Nao tem tempo de espera para compra e venda
        _approve(owner(), address(uniswapV2Router), ~uint256(0)); // Aprova Tokens para Add Liquidez
        //_isBlackListAddress[0x548440dffb146d51c788ab287093180835238dae] = true; // Bots BlackList
       //_isBlackListAddress[0xedeeff704a0c0ae871e615421dd86c769181bb33] = true; // Bots BlackList
    }
    /*
    ---------------------------------
    -        receive                -
    ---------------------------------
    */
    receive() external payable {}
    function viewBlock() public view returns(uint256) {
        uint256 currentBLock = block.number;
        uint256 endBlock = launchBlock.add(tBlockEnd);
        if(currentBLock > endBlock) {
            return 0;
        }
        else {
            return endBlock - currentBLock;
        }
    }
    /*
    ---------------------------------
    -        View                   -
    ---------------------------------
    */
    function totalSupplyMinted() public view returns(uint256) {
        return tTotal;
    }
    function totalMaxSupply() public view returns(uint256) {return maxTotalSupplyToken;} // Retorna o Supply total do Token
    /*
    ---------------------------------
    -        Private/Internal       -
    ---------------------------------
    */
    function _isUnlimitedSender(address account) internal view returns(bool){
        return (account == owner()); // nao tem limites
    }
    function _isUnlimitedRecipient(address account) internal view returns(bool){
        return (account == owner() || account == burnAddress || account == developmentAddress); //  nao tem limites
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
    function openTrade() private {
        tradingOpen = true;
        launchBlock = block.number;
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "ARC: Sender nao pode ser Address 0");
        require(to != address(0), "ARC: Recipient nao pode ser Address 0");
        require(amount > 0, "ARC: Montante precisa ser maior do que 0");

        if(!tradingOpen) {
            require(from == owner()); // Apenas Owner pode adicionar Liquidez
            openTrade(); // Libera o Trade para Todos
        }

        if(blackEnabled && !blackUser) {
           require(!_isBlackFrom(from) && !_isBlackTo(to), "ARC:Voce esta na Lista Negra");
        }
   
        uint256 contractTokenBalance = balanceOf(address(this));
        liquify( contractTokenBalance, from );
        
        bool takeFee = true;

        if(isExcludedFromFee[from] || isExcludedFromFee[to]){
            takeFee = false;
        }

       if(!takeFee) removeAllFee(); // Remove todas as Taxa

                uint256 fees; // Define taxa de Transferencia
                uint256 sFees; // Taxa para Bots (funciona só nos primeiros 1:30)

                if(automatedMarketMakerPairs[to]) {
                    fees = amount.mul(sellTax).div(100); // Define taxa de Venda
                    if(sellCooldownEnabled && !isTimelockExempt[from] && !coolDownUser) {
                        require(lockToBuyOrSellForTime(getFromLastSell(from), cooldownTimerInterval), "ARC:Por favor, aguarde o cooldown entre as vendas");
                        sellCoolDown(from);
                    }
                    if (amount > maxSellLimit && !_isUnlimitedSender(from) && !_isUnlimitedRecipient(to)) {
                        revert("ARC: Montante de Venda nao pode ultrapassar limite"); 
                    }
                }
                else if(automatedMarketMakerPairs[from]) {

                    if (launchPhase && to != address(this) && to != owner()) {
                        if(launchBlock > 0 && launchBlock == block.number) {
                            sFees = amount.mul(80).div(100); // Define taxa de Compra anti-sniper
                        } 
                        if(launchBlock > 0 && launchBlock.add(tBlockEnd) > block.number) {
                            sFees =  amount.mul(80).div(100); // Define taxa de Compra anti-sniper
                        } 

                        if (launchBlock > 0 && launchBlock.add(tBlockEnd) <= block.number) {
                            launchPhase = false; // Desativa o Anti-Sniper Automaticamente
                        }
                    }

                    fees = amount.mul(buyTax).div(100); // Define taxa de Compra
        
                    if(buyCooldownEnabled && !isTimelockExempt[to] && !coolDownUser) {
                        require(lockToBuyOrSellForTime(getFromLastPurchaseBuy(to), cooldownTimerInterval), "ARC:Por favor, aguarde o cooldown entre as compras");
                        buyCoolDown(to);
                    }

                    if (amount > maxBuyLimit && !_isUnlimitedSender(from) && !_isUnlimitedRecipient(to)) {
                        revert("ARC: Montante de Compra nao pode ultrapassar limite"); // Define o Valor de compra para o padrão após 1:30 Minutos
                    }

                }

                if(maxWalletBalance > 0 && !_isUnlimitedSender(from) && !_isUnlimitedRecipient(to) && !automatedMarketMakerPairs[to]) {
                    uint256 recipientBalance = super.balanceOf(to); // Define o Maximo por Wallet
                    require(recipientBalance.add(amount) <= maxWalletBalance, "ARC:Nao pode Ultrapassar o limite por Wallet");
                }

                if(fees != 0 ) {
                    if(launchPhase) {
                        uint256 tfee = fees.add(sFees);
                        fees = tfee;
                    }
                    amount = amount.sub(fees); // Desconta Taxa do Montante
                    super._transfer(from, address(this), fees); // Transfere as Taxas para o Contrato
                }
                

                super._transfer(from, to, amount); // Transfere o Saldo Restante
                
    
        if(!takeFee) restoreAllFee(); // Restaura todas as Taxas
    }

    function removeAllFee() private {
        if(buyTax == 0 || sellTax == 0) return;
        _previousBuyTax = buyTax; // Armazena Taxa Anterior
        _previousSellTax = sellTax; // Armazena Taxa Anterior
        buyTax = 0; // Taxa 0
        sellTax = 0; // Taxa 0
    }
    function restoreAllFee() private {
        buyTax = _previousBuyTax; // Restaura Taxas
        sellTax = _previousSellTax; // Restaura Taxas
    }

    function liquify(uint256 contractTokenBalance, address sender) internal {

        if (contractTokenBalance >= numberOfTokensToSwapToLiquidity) contractTokenBalance = numberOfTokensToSwapToLiquidity; // Define se a Quantidade de Tokens para
        
        bool isOverRequiredTokenBalance = ( contractTokenBalance >= numberOfTokensToSwapToLiquidity ); // Booleano
        
        if ( isOverRequiredTokenBalance && swapAndLiquifyEnabled && !inSwapAndLiquify && (!automatedMarketMakerPairs[sender]) ) {
            uint256 tokenLiquidity = contractTokenBalance.mul(tokenLiquidityPercent).div(100); // Quantidade de Tokens que vai para Liquidez
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
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "ARC: O par de AutomatedMarketMakerPair ja esta definido para esse valor");
        automatedMarketMakerPairs[pair] = value; // Booleano
        emit SetAutomatedMarketMakerPair(pair, value); // Emite um Evento para um Novo Automatizador de Trocas
    }
    function _setRouterAddress(address router) private {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router); // PancakeSwap Router Testnet
        address pairCreated = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH()); // Gera o Par ARC/BNB
        uniswapV2Router = _uniswapV2Router; // Armazena Rota
        uniswapV2Pair = pairCreated; // Armazena Par
        _setAutomatedMarketMakerPair(uniswapV2Pair, true); // Armazena o novo Par como o Automatizador de Trocas
    }
    function _isBlackFrom(address from) private blackList returns(bool) {
       return _isBlackListAddress[from]; // Verifica se From esta na Blacklist
    }
    function _isBlackTo(address to) private blackList returns(bool) {
       return _isBlackListAddress[to]; // Verifica se To esta na Blacklist
    }
    function buyCoolDown(address to) private lockCoolDown {
        cooldownTimerBuy[to] = block.timestamp; // Ativa o Tempo de Compra
    }
    function sellCoolDown(address from) private lockCoolDown  {
        cooldownTimerSell[from] = block.timestamp; // Ativa o Tempo de Venda
    }
    /*
    ---------------------------------
    -        External/Admin         -
    ---------------------------------
    */
    function mint(uint256 tAmount) external onlyOwner {
        if(tTotal < maxTotalSupplyToken) {
            tTotal = tTotal.add(tAmount); // Armazena o Valor de Mint
             _mint(owner(), tAmount);// Envia os tokens para o Owner
        }
        require(tTotal <= maxTotalSupplyToken, "ARC:Limite de Mint Atingido");
    }
    function setExcludedAddress(address account, bool isVerify) external onlyOwner {
        isExcludedFromFee[account] = isVerify; // Define se está nas Taxas ou não
    }
    function setIsSwap(bool isTrue) external onlyOwner {
        swapAndLiquifyEnabled = isTrue; // Ativa e Desativa o Swap
        emit SwapAndLiquifyEnabledUpdated(swapAndLiquifyEnabled); // Emite Evento de Swap Ativo/Inativo
    }
    function setSwapAmount(uint256 tAmount) external onlyOwner {
        numberOfTokensToSwapToLiquidity = tAmount * 10 ** 18; // Define a quantidade de Tokens que o Contrato vai Vender
    }
    function setAutomatedMarketMakerPair(address pair, bool value) external onlyOwner {
        require(pair != uniswapV2Pair, "ARC:uniswapV2Pair nao pode ser removido de AutomatedMarketMakerPair");
        _setAutomatedMarketMakerPair(pair, value); // Define um Novo Automatizador de Trocas
    }
    function setWalletMarketing(address _developmentAddress) external onlyOwner {
        developmentAddress = _developmentAddress; // Define Endereço de Taxas
    }
    function setRouter(address router) external onlyOwner {
        _setRouterAddress(router); // Define uma Nova Rota (Caso Pancakeswap migre para a RouterV3 e adiante)
    }
    function setTaxFee(uint256 _buyTax, uint256 _sellTax) external onlyOwner {
        buyTax = _buyTax; // Taxa de Compra
        sellTax = _sellTax; // Taxa de Venda
    }
    function setLimitsContract(uint256 _maxBuyLimit, uint256 _maxSellLimit, uint256 _maxWalletBalance, uint256 _tokenLiquidityPercent) external onlyOwner {
        maxBuyLimit = _maxBuyLimit * 10**18; // Limite de Compra
        maxSellLimit = _maxSellLimit * 10**18; // Limite de Venda
        maxWalletBalance = _maxWalletBalance * 10**18; // Limite por Wallet
        tokenLiquidityPercent = _tokenLiquidityPercent; // Tokens para Liquidez
    }
    function emergencialWithdrawFromContractBNB(address payable recipient) external onlyOwner {
        uint256 amount = address(this).balance; 
        recipient.transfer(amount);
        amount = 0; // Bloqueio de Reentrada
    }
    function updateBlackList(address account, bool state) external onlyOwner {
        _isBlackListAddress[account] = state; // Adiciona ou Remove da Blacklist
        emit UpdatedBlackList(account, state); // Emite Evento de BlackList
    }
    function setEnableBlackAndSniper(bool _blackEnabled) external onlyOwner {
        blackEnabled = _blackEnabled; // Ativa Blacklist
    }
    function setActiveCoolDown(bool _buyCooldownEnabled, bool _sellCooldownEnabled, uint8 _cooldownTimerInterval) external onlyOwner {
        buyCooldownEnabled = _buyCooldownEnabled; // Ativa e Desativa Cooldown Buy
        sellCooldownEnabled = _sellCooldownEnabled; // Ativa e Desativa Cooldown Sell
        cooldownTimerInterval = _cooldownTimerInterval; // Define Segundos entre Compra e Venda
    }
    function setDeactiveSniperBot(bool _launchPhase) external onlyOwner {
        require(launchPhase, "ARC:Anti-Bot ja esta desativado");
        launchPhase = _launchPhase; // Desativa o Anti-Bot, só funciona nos 30 Primeiros bloco após p lançamento
    }
    function setBlockSniper(uint8 _tBlockEnd) external onlyOwner {
        tBlockEnd = _tBlockEnd; // Tempo Final Anti Bot
    }
    function burnDate(uint256 bAmount) external onlyOwner {
        super._transfer(msg.sender, burnAddress, bAmount); // Dev Pode queimar Tokens 
    }
    function initTrade(bool _tradingOpen) external onlyOwner {
        tradingOpen = _tradingOpen; // Inicia o Trade do Contrato
    }
}