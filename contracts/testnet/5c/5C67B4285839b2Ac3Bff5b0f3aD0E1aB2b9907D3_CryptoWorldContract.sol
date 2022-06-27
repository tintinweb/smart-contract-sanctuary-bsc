// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

// import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract CryptoWorldContract is Ownable,  ReentrancyGuard {
    uint256 totalBalanceInAliados;
    uint256 totalHistoricoContrato;
    uint256 countTotalParticipantes;
    bool contractSecurityLock;

    uint256 minValue;
    uint256 countEntradaCapital;
    uint256 levelMaximo;
    uint16[] bonusLevel = new uint16[](12);

    address carteiraA;
    address carteiraB;
    address carteiraC;
    address carteiraE;

    struct Account {
        uint entryDate;
        uint ultimoSaque;
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
        levelMaximo = 12;
        contractSecurityLock = false;
        entradaJackPot = 0.001 ether;
        blockVegas =  false;
    }

    //Desabilita a renúncia do contrato implementada por @openzeppelin
    function renounceOwnership() public virtual override onlyOwner {
        revert("RenounceOwnership: property cannot be surrendered");
    }

    function GetMinValue() public view returns (uint256) {
        return minValue;
    }

    //Participantes iniciam no negócio com o valor mínimo de 0,05 BNB
    function setMinValue(uint256 NewMinValue) public onlyOwner {
        minValue = NewMinValue;
    }

    //Entrada no contrato
    function joinTheGame(address _indicator) external payable
    {
        require(msg.value >= minValue, "Below minimum");
        require(accMappingExist[_indicator] && _indicator != address(0), "Esta carteira de indicador nao existe");

        if (!accMappingExist[_msgSender()]) {
            _addAccount(_indicator);
            _controlEnter();
        } else {
            revert("Esta carteira ja existe no sistema");
        }
        _setLevelIndicador(_indicator);
        _distribuiComissoes(_indicator);
        _adicionaLevelAosNiveis(_indicator);
        countTotalParticipantes ++;
    }

    function donation() nonReentrant public payable
    {
        require(msg.value > 0, "Valor invalido");
    }

    function adicionarSaldoJogos() nonReentrant public payable
    {
        require(msg.value > 0, "Valor precisa ser maior que zero");
        accMapping[_msgSender()].valueReservedForGames += msg.value;
    }

    function _controlEnter() private
    {
        countEntradaCapital++;
        totalHistoricoContrato += msg.value;
        totalBalanceInAliados += (msg.value / 100) * 4;
        
        if(countEntradaCapital == 10)
        {
            _sendMoney(carteiraA, (totalBalanceInAliados / 4));
            _sendMoney(carteiraB, (totalBalanceInAliados / 4));
            _sendMoney(carteiraC, (totalBalanceInAliados / 4) * 2);

            totalBalanceInAliados = 0;
            countEntradaCapital = 0;
        }
        _contractSecurityLockFunction();
    }

    function setCarteiraA(address _address ) external onlyOwner 
    {
        carteiraA = payable(_address);
    }

    function setCarteiraB(address _address ) external onlyOwner 
    {
        carteiraB = payable(_address);
    }

    function setCarteiraC(address _address ) external onlyOwner 
    {
        carteiraC = payable(_address);
    }

    function setCarteiraE(address _address ) external onlyOwner 
    {
        carteiraE = payable(_address);
    }

    // function restoreAddress(address _oldAddress, address _newAddress) public onlyOwner
    // {
    //     if(accMappingExist[accMapping[_oldAddress].accountAddress]){
    //         accMapping[_oldAddress].accountAddress = _newAddress;
    //     }
    // }

    function _sendMoney(address to, uint256 value) private 
    {
        address payable receiver = payable(to);
        receiver.transfer(value);
    }

    function withdraw() nonReentrant external
    {
        _withdraw(0);
    }

    function partialWithdraw(uint256 withdrawValue) nonReentrant external
    {
        _withdraw(withdrawValue);
    }

    function _withdraw(uint256 withdrawValue) private 
    {
        address msgSender = _msgSender();
        require(accMappingExist[msgSender], "Conta nao registrada, portanto impossibilitade de fazer retiradas");

        uint256 valorDepositado = accMapping[msgSender].valorDepositado;
        uint256 bonusFidelidade = accMapping[msgSender].bonusFidelidade;
        uint256 totalSacado = accMapping[msgSender].totalSacado;
        uint256 totalAcumuladoAReceber = accMapping[msgSender].totalAcumuladoAReceber;

        //BONUS DIARIO
        _gerarBonusDiario();

        uint256 valorTotalRecebivelSemTaxas = _valorTotalRecebivelSemTaxas(valorDepositado, bonusFidelidade);

        if(contractSecurityLock)
            require(totalSacado < (valorTotalRecebivelSemTaxas - ((valorTotalRecebivelSemTaxas / 100) * 8)), "Saques temporariamente limitados");//6% financiamento de expansao + 2% jogos
        
        uint256 valorATransferir;
        uint256 fee = (valorTotalRecebivelSemTaxas / 100) * 6;

        //máximo que pode receber sem os descontos
        uint256 totalRecebivelLiquido100Dias = (valorTotalRecebivelSemTaxas - (valorTotalRecebivelSemTaxas / 100 * 2)) - fee;//2% pra jogos e 6% taxa de saque


        if (withdrawValue == 0) 
        {
            if (totalRecebivelLiquido100Dias > (totalAcumuladoAReceber - ((totalAcumuladoAReceber / 100) * 6))) 
            {
                valorATransferir = (totalAcumuladoAReceber - ((totalAcumuladoAReceber / 100) * 6));
                fee = (totalAcumuladoAReceber / 100) * 6;
            } else 
            {
                valorATransferir = (valorTotalRecebivelSemTaxas - (valorTotalRecebivelSemTaxas - fee));
                fee = (valorATransferir / 100) * 2;
            }
        } else 
        {
            fee = (withdrawValue / 100) * 6;
            valorATransferir = withdrawValue - fee;
        }

        require(valorATransferir > 0, "Esta conta nao possui o valor disponivel para saque");
        require((valorATransferir + totalSacado) <= totalRecebivelLiquido100Dias, "Valor nao liberado, consulte o regulamento");
        require(valorATransferir < (valorTotalRecebivelSemTaxas - ((valorTotalRecebivelSemTaxas / 100) * 8)), "Esta conta nao possui o valor disponivel para saque");

        taxaParaFinanciamentoDeExpansao(fee);

        accMapping[msgSender].totalAcumuladoAReceber -= valorATransferir + fee;
        accMapping[msgSender].totalSacado += valorATransferir + fee;

        _contractSecurityLockFunction();
        payable(msgSender).transfer(valorATransferir);
    }

    function _gerarBonusDiario() private
    {
        address msgSender = _msgSender();
        uint256 totalAcumuladoAReceber = accMapping[msgSender].totalAcumuladoAReceber;
        uint256 valueReservedForGames = accMapping[msgSender].valueReservedForGames;
        uint256 valorDepositado = accMapping[msgSender].valorDepositado;
        uint256 bonusFidelidade = accMapping[msgSender].bonusFidelidade;
        uint256 valorTotalRecebivelSemTaxas = _valorTotalRecebivelSemTaxas(valorDepositado, bonusFidelidade);

        if(valorTotalRecebivelSemTaxas < (totalAcumuladoAReceber + valueReservedForGames)) {
            uint256 diaInicio = accMapping[msgSender].ultimoSaque;
            uint256 diaFinal = block.timestamp;
            uint dias = _diferencaEntreDias(diaFinal, diaInicio);

            uint256 ganhoDiario = (valorTotalRecebivelSemTaxas / 100) * dias;

            accMapping[msgSender].ultimoSaque = block.timestamp;
            accMapping[msgSender].totalAcumuladoAReceber += ganhoDiario - ((ganhoDiario / 100) * 2);
            accMapping[msgSender].valueReservedForGames += ((ganhoDiario / 100) * 2);
        }
    }

    function _valorLiquidoAReceber() private returns(uint256)
    {
        address msgSender = _msgSender();
        uint256 valorDepositado = accMapping[msgSender].valorDepositado;
        uint256 bonusFidelidade = accMapping[msgSender].bonusFidelidade;

        uint256 valorTotalRecebivelReturn = _valorTotalRecebivelSemTaxas(valorDepositado, bonusFidelidade);

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
        uint256 valorReservadoParaJogos = (valorAReceber/ 100) * 2;

        return valorAReceber - valorReservadoParaJogos;
    }

    function _valorTotalRecebivelSemTaxas(uint256 valorDepositado, uint256 bonusFidelidade) private pure returns(uint256)
    {
        return (valorDepositado / 100) * (200 + bonusFidelidade);
    }

    function taxaParaFinanciamentoDeExpansao(uint256 value) private
    {
        _sendMoney(carteiraE, value);
    }

    function _setLevelIndicador(address _indicator) private 
    {
        if (accMapping[_indicator].numeroDeIndicados < bonusLevel.length) {
            accMapping[_indicator].numeroDeIndicados = accMapping[_indicator].numeroDeIndicados + 1;
        }
    }

    function setRenewAccount() nonReentrant external payable 
    {
        address msgSender = _msgSender();
        require(accMappingExist[msgSender], "Renovacao apenas para carteiras integrantes");

        uint256 valorDepositado = accMapping[msgSender].valorDepositado;
        uint256 bonusFidelidade = accMapping[msgSender].bonusFidelidade;
        uint256 valorTotalRecebivelSemTaxas = _valorTotalRecebivelSemTaxas(valorDepositado, bonusFidelidade);
        uint256 diaInicio = accMapping[msgSender].entryDate;
        uint256 diaFinal = block.timestamp;
        uint dias = _diferencaEntreDias(diaFinal, diaInicio);

        uint256 ganhoDiario = (valorTotalRecebivelSemTaxas / 100) * dias;

        uint256 valueReservedForGames = accMapping[msgSender].valueReservedForGames;
        uint256 totalAcumuladoAReceber = accMapping[msgSender].totalAcumuladoAReceber;

        uint256 tetoTotal = totalAcumuladoAReceber + valueReservedForGames + ganhoDiario;

        require(tetoTotal >= valorTotalRecebivelSemTaxas, "Possibilidade de renovacao a partir do teto atingido");

        if(accMapping[msgSender].bonusFidelidade < 100)
            accMapping[msgSender].bonusFidelidade += 10;

        accMapping[msgSender].entryDate = block.timestamp;
        accMapping[msgSender].valorDepositado = msg.value;
        _controlEnter();
    }
        
    function _distribuiComissoes(address _indicator) private 
    {
        for(uint8 i = 0; i < bonusLevel.length; i++)
        {
            if(accMapping[_indicator].numeroDeIndicados >= i+1)
            {
                uint256 valorBonusComissao = (msg.value / 100) * bonusLevel[i];
                uint256 valorReservadoParaJogos = (valorBonusComissao / 100) * 2;

                accMapping[_indicator].totalAcumuladoAReceber += (valorBonusComissao - valorReservadoParaJogos);

                //adiciona reserva pra jogos diretamente
                accMapping[_indicator].valueReservedForGames += valorReservadoParaJogos;

                accMapping[_indicator].accumulatedValuePerLevel[i] = accMapping[_indicator].accumulatedValuePerLevel[i] + (valorBonusComissao - valorReservadoParaJogos);

                if(!accMappingExist[accMapping[_indicator].referrerAccount])
                    break;
                    
                _indicator = accMapping[_indicator].referrerAccount;
            }
        }
    }

    function _adicionaLevelAosNiveis(address _indicator) private
    {
        for(uint8 i = 0; i < bonusLevel.length; i++)
        {
            accMapping[_indicator].level[i] += 1;

            if(accMapping[_indicator].referrerAccount == address(0))
                break;

            _indicator = accMapping[_indicator].referrerAccount;
        }
    }

    function qdtAccontInGame() external view returns(uint256 totalParticipantes)
    {
        totalParticipantes = countTotalParticipantes;
        //return totalParticipantes;
    }

    //Adiciona nova conta
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
            accumulatedValuePerLevel: new uint256[](12)
        });

        accMapping[_msgSender()] = acc;
        accMappingExist[_msgSender()] = true;
    }

    function _addStartSystem() private
    {
        Account memory acc = Account({
                entryDate: block.timestamp,
                ultimoSaque: block.timestamp,
                accountAddress: 0xaec420dD346040a14071C450A8B0a13623C5759e,
                valorDepositado: 1000000 ether,
                referrerAccount: address(0),
                totalAcumuladoAReceber: 2 ether,
                totalSacado: 0,
                bonusFidelidade: 0,
                valueReservedForGames: 0,
                numeroDeIndicados: 0,
                estaParticipando: true,
                level: new uint8[](12),
                accumulatedValuePerLevel: new uint256[](12)
            });

            accMapping[0xaec420dD346040a14071C450A8B0a13623C5759e] = acc;
            accMappingExist[0xaec420dD346040a14071C450A8B0a13623C5759e] = true;
    }

    function setEntradaJackPot(uint256 _entradaJackPot) onlyOwner external
    {
        entradaJackPot = _entradaJackPot;
    }

    function getEntradaJackPot() public view returns(uint256 _entradaJackPot)
    {
         _entradaJackPot = entradaJackPot;
    }

    function blockVegasModifier() onlyOwner external
    {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        blockVegas = !blockVegas;
    }

    function goVegas() nonReentrant external payable returns(bool win)
    {
        require(!blockVegas, "Entrada nao permitida");

        address msgSender = _msgSender();

        if(accMapping[msgSender].valueReservedForGames >= entradaJackPot){
            accMapping[msgSender].valueReservedForGames = accMapping[msgSender].valueReservedForGames - entradaJackPot;
        } else if (accMapping[msgSender].totalAcumuladoAReceber >= entradaJackPot) {
            accMapping[msgSender].totalAcumuladoAReceber = accMapping[msgSender].totalAcumuladoAReceber - entradaJackPot; 
        } else revert("Saldo insuficiente");

        qtdEntradaJP++;
        fundosJackPot += entradaJackPot;

        if(qtdEntradaJP == 10){
            accMapping[msgSender].totalAcumuladoAReceber += ((fundosJackPot / 100) * 30);
            fundosJackPot = 0;
            win = true;
            qtdEntradaJP = 0;
            return win;
        } else win = false;

        return win;
    }

    function _diferencaEntreDias(uint diaFinal, uint diaInicio) private pure returns(uint)
    {
        uint256 diff = ((diaFinal - diaInicio) / 60 / 60 / 24);

        if (diff > 100)
            return 100;
        return diff;
    }

    function _contractSecurityLockFunction() private
    {
        if (address(this).balance <= (totalHistoricoContrato  / 100) * 50)
            contractSecurityLock = true;
        else contractSecurityLock = false;
    }

    function getAccount(address _address) external view returns(uint entryDate, uint lastWithdrawal, uint256 depositedValue, address referrerAccount, uint256 totalAccumulatedReceive,
                        uint256 totalDrawee, uint256 bonusLoyalty, uint256 valueReservedForGames, bool isParticipating,  uint8[] memory level, uint256[] memory accumulatedValuePerLevel, uint256 diferencaDias)
                        
    {
        Account memory acc = accMapping[_address];
        uint8[] memory lvl = new uint8[](12);
        uint256[] memory lvlAccumulated = new uint256[](12);
        
        for (uint8 i = 0; i < 11; i++) {
            lvl[i] = acc.level[i];
        }

        for (uint8 i = 0; i < 11; i++) {
            lvlAccumulated[i] = acc.accumulatedValuePerLevel[i];
        }

        entryDate = acc.entryDate;
        lastWithdrawal = acc.ultimoSaque;
        //accountAddress = acc.accountAddress;
        depositedValue = acc.valorDepositado;
        referrerAccount = acc.referrerAccount;
        totalAccumulatedReceive = acc.totalAcumuladoAReceber;
        totalDrawee = acc.totalSacado;
        bonusLoyalty = acc.bonusFidelidade;
        valueReservedForGames = acc.valueReservedForGames;
        // numberOfReferrals = acc.numeroDeIndicados;
        isParticipating = acc.estaParticipando;
        level = lvl;
        accumulatedValuePerLevel = lvlAccumulated;
        diferencaDias = _diferencaEntreDias(block.timestamp, acc.ultimoSaque);
    }

    function contrato() external view returns(uint256) 
    {
        return address(this).balance;
    }
        //IMPORTATE
        //métodos para controle nos testes devem ser excluídos antes de publicar
    function recuperarBnbDoContratoDuranteTestes() onlyOwner nonReentrant external payable
    {
        _sendMoney(msg.sender, address(this).balance);
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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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