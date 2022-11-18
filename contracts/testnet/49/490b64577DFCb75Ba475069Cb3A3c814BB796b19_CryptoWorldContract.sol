// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./Ownable.sol";
import "./ReentrancyGuard.sol";

contract CryptoWorldContract is Ownable, ReentrancyGuard {
    uint256 totalBalanceInAliados;
    uint256 picoFlutuanteDoContrato;
    uint256 picoMaximoDoContrato;
    uint256 countTotalParticipantes;
    bool contractSecurityLock;
    uint256 minBonusFidelidade;
    uint16 setNewJPMaxStopVal;
    uint16 setOldJPMaxStopVal;
    bool liberty;

    uint256 minValue;
    uint256 countEntradaCapital;
    uint256 levelMaximo;
    uint16[] bonusLevel = new uint16[](12);

    address carteiraA;
    address carteiraB;
    address carteiraC;
    address carteiraE;

    struct Account {
        uint256 entryDate;
        uint256 ultimoSaque;
        address accountAddress;
        uint256 valorDepositado;
        address referrerAccount;
        uint256 totalAcumuladoAReceber;
        uint256 totalSacado;
        uint256 bonusFidelidade;
        uint256 valueReservedForGames;
        uint16 numeroDeIndicados;
        bool estaParticipando;
        uint8[] level;
        uint256[] accumulatedValuePerLevel;
        uint256 valorControleHistorico;
        uint256 valorControleAtual;
        uint256 valorDisponivelSaquePacoteAnterior;
    }

    mapping(address => Account) accMapping;
    mapping(address => bool) accMappingExist;

    uint256 entradaJackPot;
    uint256 fundosJackPot;
    uint256 qtdEntradaJP;
    bool blockVegas;

    constructor() ReentrancyGuard() {
        bonusLevel[0] = 7;
        bonusLevel[1] = 4;
        bonusLevel[2] = 3;
        bonusLevel[3] = 3;
        bonusLevel[4] = 3;
        bonusLevel[5] = 2;
        bonusLevel[6] = 2;
        bonusLevel[7] = 2;
        bonusLevel[8] = 1;
        bonusLevel[9] = 1;
        bonusLevel[10] = 1;
        bonusLevel[11] = 1;

        _addStartSystem();
        minValue = 0.05 ether;
        minBonusFidelidade = 0.5 ether;
        levelMaximo = 12;
        contractSecurityLock = false;
        entradaJackPot = 0.001 ether;
        blockVegas = false;
        picoFlutuanteDoContrato = 0;
        picoMaximoDoContrato = 0;
        liberty = true;
    }
    function renounceOwnership() public virtual override onlyOwner {
        revert("RenounceOwnership: property cannot be surrendered");
    }
    function GetMinValue() public view returns (uint256) {
        return minValue;
    }
    function setMinValue(uint256 newMinValue) public onlyOwner {
        minValue = newMinValue;
    }
    function getMinBonusFidelidade() public view returns (uint256) {
        return minBonusFidelidade;
    }
    function setMinBonusFidelidade(uint256 NewMinBonusFidelidade)
        public
        onlyOwner
    {
        minBonusFidelidade = NewMinBonusFidelidade;
    }

    function joinTheGame(address _indicator) external payable {
        require(msg.value >= minValue, "Abaixo do minimo");
        require(
            accMappingExist[_indicator] && _indicator != address(0),
            "Esta carteira de indicador nao existe"
        );

        if (!accMappingExist[_msgSender()]) {
            _addAccount(_indicator);
            _controlEnter();
        } else {
            revert("Esta carteira ja existe no sistema");
        }
        _setLevelIndicador(_indicator);
        _distribuiComissoes(_indicator);
        _adicionaLevelAosNiveis(_indicator);
        countTotalParticipantes++;
    }

    function donation() public payable nonReentrant {
        require(msg.value > 0, "Valor invalido");
        picoFlutuanteDoContrato += msg.value;
    }

    function adicionarSaldoJogos() public payable nonReentrant {
        require(msg.value > 0, "Valor precisa ser maior que zero");
        accMapping[_msgSender()].valueReservedForGames += msg.value;
    }

    function _controlEnter() private {
        countEntradaCapital++;
        picoFlutuanteDoContrato += msg.value;
        totalBalanceInAliados += (msg.value / 100) * 4;

        if (countEntradaCapital == 10) {
            _sendMoney(carteiraA, (totalBalanceInAliados / 4));
            _sendMoney(carteiraB, (totalBalanceInAliados / 4));
            _sendMoney(carteiraC, (totalBalanceInAliados / 4) * 2);

            totalBalanceInAliados = 0;
            countEntradaCapital = 0;
        }
        _contractSecurityLockFunction();
    }

    function setCarteiraA(address _address) external onlyOwner {
        carteiraA = payable(_address);
    }

    function setCarteiraB(address _address) external onlyOwner {
        carteiraB = payable(_address);
    }

    function setCarteiraC(address _address) external onlyOwner {
        carteiraC = payable(_address);
    }

    function setCarteiraE(address _address) external onlyOwner {
        carteiraE = payable(_address);
    }

    function _sendMoney(address to, uint256 value) private {
        address payable receiver = payable(to);
        receiver.transfer(value);
    }

    function withdraw() external nonReentrant {
        _withdraw(0);
    }

    function partialWithdraw(uint256 withdrawValue) external nonReentrant {
        _withdraw(withdrawValue);
    }

    function valueDefault () public onlyOwner {
        liberty = true;
    }

    function valueAntiPattern () public onlyOwner {
        liberty = false;
    }

    function _withdraw(uint256 withdrawValue) private {
        address msgSender = _msgSender();
        require(
            accMappingExist[msgSender],
            "Conta nao registrada, portanto impossibilitade de fazer retiradas"
        );

        _gerarBonusDiario();

        uint256 valorDisponivelSaquePacoteAnterior = accMapping[msgSender].valorDisponivelSaquePacoteAnterior;
        uint256 valorDepositado = accMapping[msgSender].valorDepositado;
        uint256 bonusFidelidade = accMapping[msgSender].bonusFidelidade;
        uint256 totalSacado = accMapping[msgSender].totalSacado;
        uint256 totalAcumuladoAReceber = accMapping[msgSender].totalAcumuladoAReceber;

        uint256 valorTotalRecebivelSemTaxas = _valorTotalRecebivelSemTaxas(valorDepositado, bonusFidelidade);

        uint256 valorDepositadoCom110 = valorDepositado + ((valorDepositado / 100) * 10);
        if(liberty)
        {
            if (contractSecurityLock)
            {
                require(totalSacado < valorDepositadoCom110 && bonusFidelidade == 0, "Saques temporariamente limitados");
            }
        }

        uint256 valorATransferir;
        uint256 fee;

        uint256 valorTotalRecebivelLiquido = (valorTotalRecebivelSemTaxas - ((valorTotalRecebivelSemTaxas / 100) * 2));
        valorTotalRecebivelLiquido += valorDisponivelSaquePacoteAnterior;
        fee = (valorTotalRecebivelLiquido / 100) * 6;

        valorTotalRecebivelLiquido = valorTotalRecebivelLiquido - fee;

        if (withdrawValue == 0) {
            if ((totalAcumuladoAReceber + totalSacado) < valorTotalRecebivelLiquido) {
                fee = (totalAcumuladoAReceber / 100) * 6;
                valorATransferir = totalAcumuladoAReceber - fee;
            } else {
                uint256 totalAReceberBruto = totalAReceber(msgSender);
                fee = (totalAReceberBruto / 100) * 6;
                valorATransferir = totalAReceberBruto - fee;
            }
        } else {
            fee = (withdrawValue / 100) * 6;
            valorATransferir = withdrawValue - fee;
        }


        require(
            valorATransferir > 0,
            "Esta conta nao possui o valor disponivel para saque"
        );
        require(
            (valorATransferir + totalSacado - (totalSacado / 100 * 6)) <= valorTotalRecebivelLiquido + valorDisponivelSaquePacoteAnterior,
            "Valor nao liberado, consulte o regulamento"
        );
        require(
            valorATransferir <= valorTotalRecebivelLiquido + valorDisponivelSaquePacoteAnterior,
            "Esta conta nao possui o valor disponivel para saque"
        );
        taxaParaFinanciamentoDeExpansao(fee);
        accMapping[msgSender].totalAcumuladoAReceber -= valorATransferir + fee;
        accMapping[msgSender].totalSacado += valorATransferir + fee;

        payable(msgSender).transfer(valorATransferir);

        picoFlutuanteDoContrato -= (valorATransferir + fee);
        _contractSecurityLockFunction();
    }

    function _gerarBonusDiario() private {
        address msgSender = _msgSender();
        uint256 valorDepositado = accMapping[msgSender].valorDepositado;
        uint256 totalAcumuladoAReceber = accMapping[msgSender].totalAcumuladoAReceber;
        uint256 valorTotalRecebivelSemTaxas = (valorDepositado / 100) * 200;
        
        uint256 diaInicio = accMapping[msgSender].ultimoSaque;
        uint256 diaFinal = block.timestamp;
        uint256 dias = _diferencaEntreDias(diaFinal, diaInicio);

        for (uint16 i = 0; i < dias; i++) 
        {
            if(totalAcumuladoAReceber <= (valorTotalRecebivelSemTaxas - ((valorTotalRecebivelSemTaxas / 100) * 2)))
            {
                uint256 ganhoDiario = (valorTotalRecebivelSemTaxas / 200);
                accMapping[msgSender].ultimoSaque = block.timestamp;
                accMapping[msgSender].totalAcumuladoAReceber += ganhoDiario - ((ganhoDiario / 100) * 2);
                accMapping[msgSender].valueReservedForGames += ((ganhoDiario / 100) * 2);
                accMapping[msgSender].valorControleAtual += ganhoDiario;
            }
        }
    }

    function _valorLiquidoAReceber() private returns (uint256) {
        address msgSender = _msgSender();
        uint256 valorDepositado = accMapping[msgSender].valorDepositado;
        uint256 bonusFidelidade = accMapping[msgSender].bonusFidelidade;

        uint256 valorTotalRecebivelReturn = _valorTotalRecebivelSemTaxas(
            valorDepositado,
            bonusFidelidade
        );

        uint256 valorAReceber;
        uint256 totalAcumulado = accMapping[_msgSender()]
            .totalAcumuladoAReceber;

        if (totalAcumulado < valorTotalRecebivelReturn) {
            accMapping[_msgSender()].totalAcumuladoAReceber -= totalAcumulado;
            accMapping[_msgSender()].totalSacado += totalAcumulado;
            valorAReceber = totalAcumulado;
        } else {
            accMapping[_msgSender()]
                .totalAcumuladoAReceber -= valorTotalRecebivelReturn;
            accMapping[_msgSender()].totalSacado += valorTotalRecebivelReturn;
            valorAReceber = valorTotalRecebivelReturn;
        }
        uint256 valorReservadoParaJogos = (valorAReceber / 100) * 2;

        return valorAReceber - valorReservadoParaJogos;
    }

    function _valorTotalRecebivelSemTaxas(uint256 valorDepositado, uint256 bonusFidelidade) private pure returns (uint256) {
        return (valorDepositado / 100) * (200 + bonusFidelidade);
    }

    function _valorTotalLiquidoRecebivel(
        uint256 valorDepositado,
        uint256 bonusFidelidade
    ) private pure returns (uint256) {
        uint256 valorBruto = (valorDepositado / 100) * (200 + bonusFidelidade);
        uint256 valorBrutoDescontadoJogos = valorBruto -
            ((valorBruto / 100) * 2);

        return valorBrutoDescontadoJogos;
    }

    function taxaParaFinanciamentoDeExpansao(uint256 value) private {
        _sendMoney(carteiraE, value);
    }

    function _setLevelIndicador(address _indicator) private {
        if (accMapping[_indicator].numeroDeIndicados < bonusLevel.length) {
            accMapping[_indicator].numeroDeIndicados =
                accMapping[_indicator].numeroDeIndicados +
                1;
        }
    }

    function setRenewAccount() external payable nonReentrant {
        address msgSender = _msgSender();
        require(
            accMappingExist[msgSender],
            "Renovacao apenas para carteiras integrantes"
        );
        require(msg.value >= minValue, "Abaixo do minimo");

        uint256 valorDepositado = accMapping[msgSender].valorDepositado;
        uint256 bonusFidelidade = accMapping[msgSender].bonusFidelidade;
        uint256 valorTotalRecebivelSemTaxas = _valorTotalRecebivelSemTaxas(
            valorDepositado,
            bonusFidelidade
        );

        accMapping[msgSender].ultimoSaque = block.timestamp;
        _gerarBonusDiario();

        uint256 valueReservedForGames = accMapping[msgSender].valueReservedForGames;
        uint256 totalAcumuladoAReceber = accMapping[msgSender].totalAcumuladoAReceber;
        uint256 totalSacado = accMapping[msgSender].totalSacado;

        uint256 tetoTotal = totalAcumuladoAReceber + valueReservedForGames + totalSacado;

        require(tetoTotal >= valorTotalRecebivelSemTaxas 
                    && accMapping[msgSender].valorControleAtual >= (accMapping[msgSender].valorControleHistorico * 2), 
                        "Possibilidade de renovacao a partir do teto atingido");

        accMapping[msgSender].valorControleHistorico += msg.value;

        accMapping[msgSender].valorDisponivelSaquePacoteAnterior = totalAReceber(msgSender);
        
        if (accMapping[msgSender].bonusFidelidade < 100 && msg.value >= minBonusFidelidade) {
            accMapping[msgSender].bonusFidelidade += 10;
        }

        accMapping[msgSender].entryDate = block.timestamp;
        accMapping[msgSender].valorDepositado = msg.value;
        accMapping[msgSender].totalSacado = 0;
        _controlEnter();
    }

    function _distribuiComissoes(address _indicator) private {
        for (uint16 i = 0; i < bonusLevel.length; i++) {
            if (accMapping[_indicator].numeroDeIndicados >= i + 1) {
                uint256 valorBonusComissao = (msg.value / 100) * bonusLevel[i];

                uint256 valorReservadoParaJogos = (valorBonusComissao / 100) * 2;

                accMapping[_indicator].totalAcumuladoAReceber += (valorBonusComissao - valorReservadoParaJogos);

                accMapping[_indicator].valueReservedForGames += valorReservadoParaJogos;

                accMapping[_indicator].accumulatedValuePerLevel[i] = accMapping[_indicator].accumulatedValuePerLevel[i] + (valorBonusComissao - valorReservadoParaJogos);
                accMapping[_indicator].valorControleAtual += valorBonusComissao;
            }
            if (!accMappingExist[accMapping[_indicator].referrerAccount]) break;

            _indicator = accMapping[_indicator].referrerAccount;
        }
    }

    function _adicionaLevelAosNiveis(address _indicator) private {
        for (uint16 i = 0; i < bonusLevel.length; i++) {
            accMapping[_indicator].level[i] += 1;

            if (accMapping[_indicator].referrerAccount == address(0)) break;

            _indicator = accMapping[_indicator].referrerAccount;
        }
    }

    function qdtAccontInGame()
        external
        view
        returns (uint256 totalParticipantes)
    {
        totalParticipantes = countTotalParticipantes;
    }

    function _addAccount(address _indicator) private {
        Account memory acc = Account({
            entryDate: block.timestamp,
            ultimoSaque: block.timestamp,
            accountAddress: _msgSender(),
            valorDepositado: msg.value,
            referrerAccount: _indicator,
            totalAcumuladoAReceber: 0,
            totalSacado: 0,
            bonusFidelidade: 0,
            valueReservedForGames: 0,
            numeroDeIndicados: 0,
            estaParticipando: true,
            level: new uint8[](12),
            accumulatedValuePerLevel: new uint256[](12),
            valorControleHistorico: msg.value,
            valorControleAtual: 0,
            valorDisponivelSaquePacoteAnterior: 0
        });

        accMapping[_msgSender()] = acc;
        accMappingExist[_msgSender()] = true;
    }

    function _addStartSystem() private {
        Account memory acc = Account({
            entryDate: block.timestamp,
            ultimoSaque: block.timestamp,
            accountAddress: 0x132Fb2b17c033be10993F67e2BF5eB3DF5a482e8,
            valorDepositado: 10 ether,
            referrerAccount: address(0),
            totalAcumuladoAReceber: 0,
            totalSacado: 0,
            bonusFidelidade: 100,
            valueReservedForGames: 0,
            numeroDeIndicados: 12,
            estaParticipando: true,
            level: new uint8[](12),
            accumulatedValuePerLevel: new uint256[](12),
            valorControleHistorico: msg.value,
            valorControleAtual: 0,
            valorDisponivelSaquePacoteAnterior: 0
        });
        acc.level[0] = 12;
        accMapping[0x132Fb2b17c033be10993F67e2BF5eB3DF5a482e8] = acc;
        accMappingExist[0x132Fb2b17c033be10993F67e2BF5eB3DF5a482e8] = true;
    }

    function setEntradaJackPot(uint256 _entradaJackPot) external onlyOwner {
        entradaJackPot = _entradaJackPot;
    }

    function getEntradaJackPot() public view returns (uint256 _entradaJackPot) {
        _entradaJackPot = entradaJackPot;
    }

    function lockVegas() external onlyOwner {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        blockVegas = true;
    }

    function unlockVegas() external onlyOwner {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        blockVegas = false;
    }

    function goVegas() external payable nonReentrant returns (bool win) {
        address msgSender = _msgSender();

        require(blockVegas != true, "Entrada nao permitida");
        require(msg.value == entradaJackPot, "Valor incorreto para entrada");
        require(accMappingExist[msgSender], "Apenas para carteiras integrantes");


        if (accMapping[msgSender].valueReservedForGames >= entradaJackPot) {
            accMapping[msgSender].valueReservedForGames = accMapping[msgSender].valueReservedForGames - entradaJackPot;
        } else if (accMapping[msgSender].totalAcumuladoAReceber >= entradaJackPot) {
            accMapping[msgSender].totalAcumuladoAReceber = accMapping[msgSender].totalAcumuladoAReceber - entradaJackPot;
        } else revert("Saldo insuficiente");

        qtdEntradaJP++;
        fundosJackPot += entradaJackPot;

        if (qtdEntradaJP == setOldJPMaxStopVal) {
            accMapping[msgSender].totalAcumuladoAReceber += ((fundosJackPot / 100) * 30);
            fundosJackPot = 0;
            win = true;
            qtdEntradaJP = 0;
            setOldJPMaxStopVal = setNewJPMaxStopVal;
            return win;
        } else win = false;

        return win;
    }

    function setJPMaxStop(uint16 val) external onlyOwner {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        setNewJPMaxStopVal = val;
    }

    function setInitialJPMaxStop(uint16 val) external onlyOwner {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        setOldJPMaxStopVal = val;
    }

    function _diferencaEntreDias(uint256 diaFinal, uint256 diaInicio)
        private
        pure
        returns (uint256)
    {
        uint256 diff = ((diaFinal - diaInicio) / 60 / 60 / 24);
        if (diff > 200) {
            return 200;
        }
        return diff;
    }

    function _contractSecurityLockFunction() private {
        if(picoFlutuanteDoContrato > picoMaximoDoContrato)
        {
            picoMaximoDoContrato = picoFlutuanteDoContrato;
        }

        if (address(this).balance <= picoMaximoDoContrato / 2)
        {
            contractSecurityLock = true;
        }
        else
        {
            contractSecurityLock = false;
        }
    }

    function getAccount(address _address)
        external
        view
        returns (
            uint256 entryDate,
            uint256 lastWithdrawal,
            uint256 depositedValue,
            address referrerAccount,
            uint256 totalAccumulatedReceive,
            uint256 totalDrawee,
            uint256 bonusLoyalty,
            uint256 valueReservedForGames,
            bool isParticipating,
            uint8[] memory level,
            uint256[] memory accumulatedValuePerLevel,
            uint256 diferencaDias
        )
    {
        Account memory acc = accMapping[_address];
        uint8[] memory lvl = new uint8[](12);
        uint256[] memory lvlAccumulated = new uint256[](12);

        for (uint8 i = 0; i < 12; i++) {
            lvl[i] = acc.level[i];
        }

        for (uint8 i = 0; i < 12; i++) {
            lvlAccumulated[i] = acc.accumulatedValuePerLevel[i];
        }

        entryDate = acc.entryDate;
        lastWithdrawal = acc.ultimoSaque;
        depositedValue = acc.valorDepositado;
        referrerAccount = acc.referrerAccount;
        totalAccumulatedReceive = acc.totalAcumuladoAReceber;
        totalDrawee = acc.totalSacado;
        bonusLoyalty = acc.bonusFidelidade;
        valueReservedForGames = acc.valueReservedForGames;
        isParticipating = acc.estaParticipando;
        level = lvl;
        accumulatedValuePerLevel = lvlAccumulated;
        diferencaDias = _diferencaEntreDias(block.timestamp, acc.ultimoSaque);
    }

    function contrato() external view returns (uint256) {
        return address(this).balance;
    }

    function totalAReceber(address _address) public view returns(uint256 totalAReceberLiquido)
    {
        uint256 bonusFidelidade = accMapping[_address].bonusFidelidade;
        uint256 valorDepositado = accMapping[_address].valorDepositado;
        uint256 totalSacado = accMapping[_address].totalSacado;
        uint256 totalAcumuladoAReceber = accMapping[_address].totalAcumuladoAReceber;
        uint256 valorDisponivelSaquePacoteAnterior = accMapping[_address].valorDisponivelSaquePacoteAnterior;

        uint256 valorDepositadoMenosJogos = valorDepositado - ((valorDepositado / 100) * 2);
        uint256 valorTotalLiquidoRecebivel = (valorDepositadoMenosJogos / 100) * 200;
        uint256 valorTotalLiquidoRecebivelIndicacoes = _valorTotalLiquidoRecebivel(valorDepositado, bonusFidelidade);

        uint256 diaInicio = accMapping[_address].ultimoSaque;
        uint256 diaFinal = block.timestamp;
        uint256 dias = _diferencaEntreDias(diaFinal, diaInicio);
        uint256 bonusDiarioRecebido = 0;
        for (uint16 i = 0; i < dias; i++) 
        {
            if(totalAcumuladoAReceber <= valorTotalLiquidoRecebivel)
            {
                bonusDiarioRecebido += (valorTotalLiquidoRecebivel / 200);
            } else break;
        }

        totalAReceberLiquido = bonusDiarioRecebido + totalAcumuladoAReceber + totalSacado <= valorTotalLiquidoRecebivelIndicacoes + valorDisponivelSaquePacoteAnterior
                                    ? bonusDiarioRecebido + totalAcumuladoAReceber
                                    : (valorTotalLiquidoRecebivelIndicacoes + valorDisponivelSaquePacoteAnterior - totalSacado) <= valorTotalLiquidoRecebivelIndicacoes 
                                            ? valorTotalLiquidoRecebivelIndicacoes + valorDisponivelSaquePacoteAnterior - totalSacado
                                            : valorTotalLiquidoRecebivelIndicacoes + valorDisponivelSaquePacoteAnterior;
        
    }
}