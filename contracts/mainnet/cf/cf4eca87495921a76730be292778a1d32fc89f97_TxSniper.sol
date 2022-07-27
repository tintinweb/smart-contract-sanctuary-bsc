// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import "./Ownable.sol";
import "./IERC20.sol";
import "./IWETH.sol";
import "./IUniswapV2Router.sol";
import "./IChiToken.sol";

contract TxSniper is Ownable {
    IUniswapV2Router02 public router;
    IChiToken public chiToken;
    uint private snipeAmount;
    uint private snipeCount;
    uint private snipeAmountOutMin;
    uint[] private snipeTestAmounts;
    address private snipeBase;
    address private snipeToken;
    bool private snipeTriggered = true;
    bool private snipeCheck = false;
    bool private sprayAndPray = false;
    bool private ceaseFire = false;
    mapping(address => bool) public swapWallets;
    address private tokenHoldingAddress;

    receive() payable external { }
 
    modifier gasTokenRefund {
        uint256 gasStart = gasleft();
        _;
        if (IERC20(address(chiToken)).balanceOf(address(this)) > 0) {
            uint256 gasSpent = 21000 + gasStart - gasleft() + 16 * msg.data.length;
            chiToken.freeUpTo((gasSpent + 14154) / 41947);
        }
    }
    modifier onlySwaps {
        require(swapWallets[msg.sender] == true, "Only Swaps");
        _;
    }
    function mintGasToken(uint amount) public {
        chiToken.mint(amount);
    }
    function wrap(uint toWrap) public onlyOwner {
        address self = address(this);
        require(self.balance >= toWrap, "Not enough ETH in the contract to wrap");
        address WETH = router.WETH();
        IWETH(WETH).deposit{value: toWrap}();
    }
    function unrwap() public onlyOwner {
        address self = address(this);
        address WETH = router.WETH();
        uint256 balance = IERC20(WETH).balanceOf(self);
        IWETH(WETH).withdraw(balance);
    }
    function approve(address token, uint amount) public onlyOwner {
        IERC20(token).approve(address(router), amount);
    }
    function withdrawToken(address token) public onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        address to = this.owner();
        IERC20(token).transfer(to, balance);
    }
    function withdrawTokens(address[] memory tokens) public onlyOwner {
        for (uint i=0;i<tokens.length;i++) {
            uint256 balance = IERC20(tokens[i]).balanceOf(address(this));
            address to = this.owner();
            IERC20(tokens[i]).transfer(to, balance);
        }
    }
    function migrateTokens(address[] memory tokens, address newContract) public onlyOwner {
        for (uint i=0;i<tokens.length;i++) {
            uint256 balance = IERC20(tokens[i]).balanceOf(address(this));
            IERC20(tokens[i]).transfer(newContract, balance);
        }
    }
    function withdrawEth(uint amount) public onlyOwner {
       address self = address(this); // workaround for a possible solidity bug
       require(self.balance >= amount, "Not enough Ether value");
       msg.sender.transfer(amount);
    }
    function migrateEth(uint amount, address payable newContract) public onlyOwner {
       address self = address(this);
       require(self.balance >= amount, "Not enough Ether value");
       newContract.transfer(amount);
    }
    function emergencyWithdraw() public onlyOwner { // Probably not needed but leaving it anyways
        address self = address(this); 
        payable(this.owner()).transfer(self.balance);
    }
    function _setupHand(address tokenIn, address tokenOut, uint amountIn) internal returns (address[] memory path) {
        require(IERC20(tokenIn).balanceOf(address(this)) >= amountIn, "Not enough tokenIn in the contract");
        IERC20(tokenIn).approve(address(router), amountIn);
        path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;
        return path;
    } 
    function Hand(address[] memory path_, uint amountIn) external onlySwaps gasTokenRefund {   
        require(IERC20(path_[0]).balanceOf(address(this)) >= amountIn, "Not enough tokenIn in the contract");
        IERC20(path_[0]).approve(address(router), amountIn);        
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountIn, 
            0, 
            path_,
            tokenHoldingAddress, 
            block.timestamp
        );
    }
    function HandFee(address tokenIn, address tokenOut, uint amountIn, uint amountOutMin) external onlySwaps gasTokenRefund {   
        address[] memory path = _setupHand(tokenIn, tokenOut, amountIn);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountIn,
            amountOutMin,
            path,
            tokenHoldingAddress,
            block.timestamp
        );
    }
    function HandMany(address tokenIn, address tokenOut, uint amountIn, uint amountOutMin, uint numberOfSwaps) external onlySwaps gasTokenRefund {   
        address[] memory path = _setupHand(tokenIn, tokenOut, amountIn);
        uint dividedValue = amountIn/numberOfSwaps;
        for (uint i=0;i<numberOfSwaps;i++) {
            router.swapExactTokensForTokens(
                dividedValue,
                amountOutMin,
                path, 
                tokenHoldingAddress,
                block.timestamp
            );
        }
    }
    function configureSwap(address tokenBase, address tokenToBuy, uint amountToBuy, uint numOfSwaps, bool checkTax, bool machineGunner, uint amountOutMin, uint[] memory testAmounts) external onlyOwner {
        snipeBase = tokenBase;
        snipeAmount = amountToBuy;
        snipeCount = numOfSwaps;
        snipeToken = tokenToBuy;
        snipeAmountOutMin = amountOutMin;
        snipeCheck = checkTax;
        sprayAndPray = machineGunner;
        snipeTestAmounts = testAmounts;
        snipeTriggered = false;
        ceaseFire = false;
    }
    function getConfiguration() external view onlyOwner returns(address, address, uint, uint, uint, bool, bool, bool) {
        return (snipeBase, snipeToken, snipeAmount, snipeCount, snipeAmountOutMin, snipeCheck, snipeTriggered, sprayAndPray);
    }

    /**
    * {moinho}
    *
    * Função verificadora, responsavel por executar uma compra minima baseada nas configurações
    * e utilizar os dados coletados da transação para considerar a continuidade da transação 
    * posterior
    *
     */
    function _check(address[] memory path_) internal returns (bool) {

        uint startingBalance = IERC20(snipeBase).balanceOf(address(this));

        /**
        *
        * Como a função chamadora é recursiva para evitar DRY, em algum momento esse check deve        
        * ignorar os codigos seguintes já que a sua utilidade não existirá em certos motivos de chamada
        * para isso, esse bloco verifica se este recurso está ativo nas configurações
        * caso não esteja, o mesmo retornará true como forma de ignorar e prosseguir
         */
        if (snipeCheck == false) { return true; }

        /**
        * A atualização da verificação do snipeCheck acontece com antecedencia pois não há mudanças temporais
        * simultaneas, portanto testes posteriores serão cancelados, de acordo com a linha 167        
         */
        //snipeCheck = false;

        /**
        *
        * Esse trecho será responsavel por traçar a rota de saida/venda de forma respectiva e 
        * reversa baseada na rota primordial(rota de compra)
         */
        address[] memory outpath;

        /**
        *
        * Uma rota de dois endereços pode ser definitivamente uma compra simples com WBNB
        * mas para manter a organização e a padronização da codificação, o faço desta forma.
         */
        if (path_.length == 2) {
            outpath = new address[](2);

            outpath[0] = path_[1];
            outpath[1] = path_[0];

        }

        /**
        *
        * Uma rota com mais de dois endereços significa uma transação de par personalizado, contendo uma
        * rota mediana. Não o coloquei em um else para obrigar o codigo a compreender apenas rotas de dois
        * e no maximo tres caminhos de saida
         */
        if (path_.length == 3) {
            outpath = new address[](3);

            outpath[0] = path_[2];
            outpath[1] = path_[1];
            outpath[2] = path_[0];

        }

        IERC20(path_[0]).approve(address(router), snipeTestAmounts[0]);

        /**
        * A primeira transação, que será a de compra, ocorre neste trecho, sendo que o mesmo está em um try
        * catch para diminuir o custo de gás caso ocorra uma falha, ainda a função retornara sucesso.
        * caso erro, o trecho retornará false dessa forma quebrando o fluxo do chamador
         */
        router.swapExactTokensForTokens(snipeTestAmounts[0],0,path_,address(this),block.timestamp);
        uint testBalance = IERC20(snipeToken).balanceOf(address(this));

        // /**
        // * Este é outro trecho aprovador, cuja aprovração afetará a transação da venda dos tokens        
        //  */
        IERC20(snipeToken).approve(address(router), testBalance);

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(testBalance,0,outpath,address(this),block.timestamp);
 
        uint afterBalance = IERC20(snipeBase).balanceOf(address(this));
        uint returnedDelta = startingBalance - afterBalance;
        uint returnedAmount = snipeTestAmounts[0] - returnedDelta;

        require(returnedAmount >= snipeTestAmounts[1],"O limite de taxa foi estrapolado");

        return true;

    }   

    /**
    * {moinho}
    * Tornei essa função independente da função "setupCastle
    *
    * A rota da transação será passada como parametro na execução da função
    * a aprovação ocorre nessa função de forma independente também.
    * as linhas dependentes estarão comentadas
     */
    function Heresy(address[] memory path_) external onlySwaps gasTokenRefund {
        
        /**
        * Estou verificando esse criterio logo de começo para gerar o minimo de fluxo
        * de gas possivel.
        *
        * Uma vez que a transação tem sucesso na execução, então a variavel snipeTriggered é atualizada        
         */
        require(snipeTriggered == false);

        /**
        * A função check retornará um booleano
        * se a função snipe_check estiver desativada, um if será responsavel
        * por retornar true para que prossiga com a transação de forma que o teste seja ignorado
         */
        if(_check(path_)){
            IERC20(path_[0]).approve(address(router), snipeAmount);
            router.swapExactTokensForTokens(snipeAmount, 0, path_, tokenHoldingAddress, block.timestamp);
            snipeTriggered = true;
        }

    }

    function configure(address newRouter, address newChiToken, address newHoldingAddress, address[] memory newSwaps) public onlyOwner {
        router = IUniswapV2Router02(newRouter);
        chiToken = IChiToken(newChiToken);
        tokenHoldingAddress = newHoldingAddress;
        swapWallets[this.owner()] = true;
        for (uint i=0;i<newSwaps.length;i++) {
            swapWallets[newSwaps[i]] = true;
        }
    }
    function changeHoldingAddress(address _newHolding) public onlyOwner {
        tokenHoldingAddress = _newHolding;
    }
    function setupSwaps(address[] memory _newSwaps) public onlyOwner {
        for (uint i=0;i<_newSwaps.length;i++) {
            swapWallets[_newSwaps[i]] = true;
        }
    }
    function removeSwaps(address[] memory _oldSwaps) public onlyOwner {
        for (uint i=0;i<_oldSwaps.length;i++) {
            delete swapWallets[_oldSwaps[i]];
        }
    }
}