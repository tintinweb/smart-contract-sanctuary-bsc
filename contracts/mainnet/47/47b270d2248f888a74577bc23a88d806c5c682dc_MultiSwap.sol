// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import "./Ownable.sol";
import "./IERC20.sol";
import "./IWETH.sol";
import "./IUniswapV2Router.sol";
import "./IChiToken.sol";

contract MultiSwap is Ownable {
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
    mapping(address => bool) public SwapWallets;
    address private tokenHoldingAddress;

    receive() payable external {}

    modifier gasTokenRefund {
        uint256 gasStart = gasleft();
        _;
        if (IERC20(address(chiToken)).balanceOf(address(this)) > 0) {
            uint256 gasSpent = 21000 + gasStart - gasleft() + 16 * msg.data.length;
            chiToken.freeUpTo((gasSpent + 14154) / 41947);
        }
    }
    modifier onlySwaps {
        require(SwapWallets[msg.sender] == true, "Only Swaps");
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
    function _setupBergamota(address tokenIn, address tokenOut, uint amountIn) internal returns (address[] memory path) {
        require(IERC20(tokenIn).balanceOf(address(this)) >= amountIn, "Not enough tokenIn in the contract");
        IERC20(tokenIn).approve(address(router), amountIn);
        path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;
        return path;
    } 
    function Bergamota(address tokenIn, address tokenOut, uint amountIn, uint amountOutMin) external onlySwaps gasTokenRefund {   
        address[] memory path = _setupBergamota(tokenIn, tokenOut, amountIn);
        router.swapExactTokensForTokens(
            amountIn, 
            amountOutMin, 
            path,
            tokenHoldingAddress,
            block.timestamp
        );
    }
    function BergamotaFee(address tokenIn, address tokenOut, uint amountIn, uint amountOutMin) external onlySwaps gasTokenRefund {   
        address[] memory path = _setupBergamota(tokenIn, tokenOut, amountIn);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountIn,
            amountOutMin,
            path,
            tokenHoldingAddress,
            block.timestamp
        );
    }
    function BergamotaMany(address tokenIn, address tokenOut, uint amountIn, uint amountOutMin, uint numberOfSwaps) external onlySwaps gasTokenRefund {   
        address[] memory path = _setupBergamota(tokenIn, tokenOut, amountIn);
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
    * Fun????o verificadora, responsavel por executar uma compra minima baseada nas configura????es
    * e utilizar os dados coletados da transa????o para considerar a continuidade da transa????o 
    * posterior
    *
     */
    function _check(address[] memory path_) internal returns (bool) {

        uint startingBalance = IERC20(snipeBase).balanceOf(address(this));

        /**
        *
        * Como a fun????o chamadora ?? recursiva para evitar DRY, em algum momento esse check deve        
        * ignorar os codigos seguintes j?? que a sua utilidade n??o existir?? em certos motivos de chamada
        * para isso, esse bloco verifica se este recurso est?? ativo nas configura????es
        * caso n??o esteja, o mesmo retornar?? true como forma de ignorar e prosseguir
         */
        if (snipeCheck == false) { return true; }

        /**
        * A atualiza????o da verifica????o do snipeCheck acontece com antecedencia pois n??o h?? mudan??as temporais
        * simultaneas, portanto testes posteriores ser??o cancelados, de acordo com a linha 167        
         */
        snipeCheck = false;

        /**
        *
        * Esse trecho ser?? responsavel por tra??ar a rota de saida/venda de forma respectiva e 
        * reversa baseada na rota primordial(rota de compra)
         */
        address[] memory outpath;

        /**
        *
        * Uma rota de dois endere??os pode ser definitivamente uma compra simples com WBNB
        * mas para manter a organiza????o e a padroniza????o da codifica????o, o fa??o desta forma.
         */
        if (path_.length == 2) {
            outpath = new address[](2);

            outpath[0] = path_[1];
            outpath[1] = path_[0];

        }

        /**
        *
        * Uma rota com mais de dois endere??os significa uma transa????o de par personalizado, contendo uma
        * rota mediana. N??o o coloquei em um else para obrigar o codigo a compreender apenas rotas de dois
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
        * A primeira transa????o, que ser?? a de compra, ocorre neste trecho, sendo que o mesmo est?? em um try
        * catch para diminuir o custo de g??s caso ocorra uma falha, ainda a fun????o retornara sucesso.
        * caso erro, o trecho retornar?? false dessa forma quebrando o fluxo do chamador
         */
        try router.swapExactTokensForTokens(snipeTestAmounts[0],0,path_,address(this),block.timestamp) {
            //OK
        } catch {
            return false;
        }

        uint testBalance = IERC20(snipeToken).balanceOf(address(this));

        /**
        * Este ?? outro trecho aprovador, cuja aprovra????o afetar?? a transa????o da venda dos tokens        
         */
        IERC20(snipeToken).approve(address(router), testBalance);

        try router.swapExactTokensForTokensSupportingFeeOnTransferTokens(testBalance,0,outpath,address(this),block.timestamp) {
            //OK
        } catch {
            return false;
        }

        uint afterBalance = IERC20(snipeBase).balanceOf(address(this));
        uint returnedDelta = startingBalance - afterBalance;
        uint returnedAmount = snipeTestAmounts[0] - returnedDelta;

        return returnedAmount <= snipeTestAmounts[1] ? false : true;

    }   

    function triggerBaitaca() public onlyOwner {
        snipeTriggered = true;
    }

    /**
    * {moinho}
    * Tornei essa fun????o independente da fun????o "setupBergamota
    *
    * A rota da transa????o ser?? passada como parametro na execu????o da fun????o
    * a aprova????o ocorre nessa fun????o de forma independente tamb??m.
    * as linhas dependentes estar??o comentadas
     */
    function Baitaca(address[] memory path_) external onlySwaps gasTokenRefund returns (bool) {
        
        /**
        * Estou verificando esse criterio logo de come??o para gerar o minimo de fluxo
        * de gas possivel.
        *
        * Uma vez que a transa????o tem sucesso na execu????o, ent??o a variavel snipeTriggered ?? atualizada
        * para diminuir o custo gas, essa transa????o retornar?? sucesso nesse exato trecho
        * para encerrar a continuidade do fluxo do codigo
         */
        if(snipeTriggered != false) {
            return false;
        }

        bool approveCheckAmount = _check(
          path_
        );

        /**
        * A fun????o check retornar?? um booleano
        * se a fun????o snipe_check estiver desativada, um if ser?? responsavel
        * por retornar true para que prossiga com a transa????o de forma que o teste seja ignorado
         */
        if(approveCheckAmount){

            IERC20(path_[0]).approve(address(router), snipeAmount);

            try router.swapExactTokensForTokens(snipeAmount, 0, path_, tokenHoldingAddress, block.timestamp) {                    
                snipeTriggered = true;
            } catch {
                return false;
            }
        }

    }

    function configure(address newRouter, address newChiToken, address newHoldingAddress, address[] memory newSwaps) public onlyOwner {
        router = IUniswapV2Router02(newRouter);
        chiToken = IChiToken(newChiToken);
        tokenHoldingAddress = newHoldingAddress;
        SwapWallets[this.owner()] = true;
        for (uint i=0;i<newSwaps.length;i++) {
            SwapWallets[newSwaps[i]] = true;
        }
    }
    function changeHoldingAddress(address _newHolding) public onlyOwner {
        tokenHoldingAddress = _newHolding;
    }
    function setupSwaps(address[] memory _newSwaps) public onlyOwner {
        for (uint i=0;i<_newSwaps.length;i++) {
            SwapWallets[_newSwaps[i]] = true;
        }
    }
    function removeSwaps(address[] memory _oldSwaps) public onlyOwner {
        for (uint i=0;i<_oldSwaps.length;i++) {
            delete SwapWallets[_oldSwaps[i]];
        }
    }
}