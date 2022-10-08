// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICryptoWorldContract.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract CryptoMania is Ownable, ReentrancyGuard {
    address cryptoWorldContract;
    uint256 ultimaCartelaVendida;
    uint256 valorCartela;
    bool jogoIniciado;
    uint256 rodada;
    mapping(address => uint256) valoresPremios;
    mapping(address => uint256) valoresDistribuicao;
    uint256 totalDoContratoParaPremio;
    uint256 totalDoContratoParaDistribuicao;
    uint256 totalDoContratoParaDoacao;
    uint256 totalDistribuido;
    uint256 totalPremio;
    uint256 totalDoado;
    uint256 private taxaDistribuicao = 20;
    uint256 private taxaPremio = 30;

    event comprouCartela(address owner, uint256 id, uint256 rodada);

    constructor(address cryptoWorldContract_, uint256 valorCartela_)
        ReentrancyGuard()
    {
        cryptoWorldContract = cryptoWorldContract_;
        ultimaCartelaVendida = 0;
        valorCartela = valorCartela_;
        jogoIniciado = false;
        rodada = 0;
    }

    function renounceOwnership() public virtual override onlyOwner {
        revert("RenounceOwnership: property cannot be surrendered");
    }

    function comprarCartela() public payable {
        require(msg.value == valorCartela, "Valor insuficiente");
        require(jogoIniciado, "O jogo nao esta iniciado");

        uint256 valorPosDistribuicao = distribuirValorDistribuicao(msg.value);

        uint256 valorPosPremio = distribuirValorPremio(msg.value);

        uint256 valorDoacao = msg.value -
            (valorPosDistribuicao + valorPosPremio);

        totalDoContratoParaDoacao += valorDoacao;

        ultimaCartelaVendida++;

        emit comprouCartela(msg.sender, ultimaCartelaVendida, rodada);
    }

    function distribuirValorPremio(uint256 valor) internal returns (uint256) {
        uint256 taxFull = 100 + taxaPremio;

        uint256 taxValue = taxFull * valor;

        uint256 finalValue = valor - (valor - ((taxValue / 100) - valor));

        totalDoContratoParaPremio += finalValue;
        totalPremio += finalValue;

        return finalValue;
    }

    function distribuirValorDistribuicao(uint256 valor)
        internal
        returns (uint256)
    {
        uint256 taxFull = 100 + taxaDistribuicao;

        uint256 taxValue = taxFull * valor;

        uint256 finalValue = valor - (valor - ((taxValue / 100) - valor));

        totalDoContratoParaDistribuicao += finalValue;
        totalPremio += finalValue;

        return finalValue;
    }

    function alterarValorCartela(uint256 valorCartela_)
        public
        onlyOwner
        nonReentrant
    {
        valorCartela = valorCartela_;
    }

    function alterarTaxaDistribuicao(uint256 taxaDistribuicao_)
        public
        onlyOwner
        nonReentrant
    {
        taxaDistribuicao = taxaDistribuicao_;
    }

    function alterarTaxaPremio(uint256 taxaPremio_)
        public
        onlyOwner
        nonReentrant
    {
        taxaPremio = taxaPremio_;
    }

    function obtemValorCartela() public view returns (uint256) {
        return valorCartela;
    }

    function obtemUltimaCartela() public view returns (uint256) {
        return ultimaCartelaVendida;
    }

    function iniciaRodada() public onlyOwner nonReentrant {
        require(!jogoIniciado, "O jogo ja esta iniciado");
        jogoIniciado = true;
        ultimaCartelaVendida = 0;
        rodada++;
    }

    function obtemRodadaAtual() public view returns (uint256) {
        return rodada;
    }

    function finalizaRodada() public onlyOwner nonReentrant {
        require(jogoIniciado, "O jogo nao esta iniciado");
        jogoIniciado = false;
    }

    function enviaValor(address to, uint256 value) private {
        payable(to).transfer(value);
    }

    function sacarValorPremio() public nonReentrant {
        require(valoresPremios[msg.sender] > 0, "Nenhum valor disponivel");
        enviaValor(msg.sender, valoresPremios[msg.sender]);

        valoresPremios[msg.sender] = 0;
    }

    function obtemValorDisponivelUsuarioPremio() public view returns (uint256) {
        return valoresPremios[msg.sender];
    }

    function sacarValorDistribuicao() public nonReentrant {
        require(valoresDistribuicao[msg.sender] > 0, "Nenhum valor disponivel");
        enviaValor(msg.sender, valoresDistribuicao[msg.sender]);
        totalDistribuido += valoresDistribuicao[msg.sender];

        valoresDistribuicao[msg.sender] = 0;
    }

    function obtemValorDisponivelUsuarioDistribuicao()
        public
        view
        returns (uint256)
    {
        return valoresDistribuicao[msg.sender];
    }

    function obtemValorDisponivelContratoPremio()
        public
        view
        returns (uint256)
    {
        return totalDoContratoParaPremio;
    }

    function obtemValorDisponivelContratoDistribuicao()
        public
        view
        returns (uint256)
    {
        return totalDoContratoParaDistribuicao;
    }

    function adicionarTotalDoContratoParaDistribuicao() public payable {
        require(msg.value > 0, "Valor insuficiente");

        totalDoContratoParaDistribuicao += msg.value;
    }

    function obtemValorDisponivelContratoDoacao()
        public
        view
        returns (uint256)
    {
        return totalDoContratoParaDoacao;
    }

    function obtemJogoIniciado() public view returns (bool) {
        return jogoIniciado;
    }

    function enviaDoacaoParaContratoPrincipal()
        public
        payable
        onlyOwner
        nonReentrant
    {
        require(totalDoContratoParaDoacao > 0);
        ICryptoWorldContract(cryptoWorldContract).donation{
            value: totalDoContratoParaDoacao
        }();
        totalDoado += totalDoContratoParaDoacao;
        totalDoContratoParaDoacao = 0;
    }

    function enviaParaGanhador(address ganhador, uint256 valor)
        public
        onlyOwner
        nonReentrant
    {
        require(totalDoContratoParaPremio >= valor);
        valoresPremios[ganhador] += valor;
        totalDoContratoParaPremio -= valor;
    }

    function enviaParaDistribuidor(address distribuidor, uint256 valor)
        public
        onlyOwner
        nonReentrant
    {
        require(
            totalDoContratoParaDistribuicao >= valor,
            "valor de distribuicao insuficiente"
        );
        valoresDistribuicao[distribuidor] += valor;

        totalDoContratoParaDistribuicao -= valor;
    }

    function fullWithdraw() public onlyOwner nonReentrant {
        enviaValor(msg.sender, address(this).balance);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface ICryptoWorldContract {
    function getAccount(address _address)
        external
        view
        returns (
            uint256 entryDate,
            uint256 lastWithdrawal,
            uint256 depositedValue,
            address referrerAccount
        );

    function donation() external payable;
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