// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

//CONTRATO DE PREVENTA

//poder vender nuestro token a inversores
contract SecoalbaTokenSale {

    //dueño
    address public owner;
    //precio de compra
    uint private buyPrice;
    //cantidad de tokens vendidos
    uint private sold;
    //cantidad de tokens a vender
    uint private toSold;
    //address
    address private nOne= address(0);
    //Interfaz
    IERC20 private token;
    //en que fase de venta estamos
    uint private currentPhaseIndex;

    //estructura de las fase actual en la que estamos
    struct Phase {
        uint total;
        uint price;
        uint phase;
    }

    //lista de fases (se guarda en el struct)
    Phase [] private phases;

    //evento que se genera cuando se realiza una venta
    event Sell(address _buyer, uint _amount);

    constructor(address _token) {
        owner = msg.sender;
        //instancia del token
        token = IERC20(_token);
        //precio inicial
        buyPrice = 0.000005 * 10**18;
        //indice de la 1ª fase
        currentPhaseIndex = 0;
        //cantidad de tokens vendidos
        sold = 0;
        //cantidad de tokens que se van a vender
        toSold = __amount(500000);

        //subir de fases (en cada fase el token se multiplica)
        for(uint i=1; i<10; i++) {
            phases.push(Phase(50000, i * buyPrice, i));
        }
    }

    //función de comprar el token
    function buy(uint tokens) public payable {
        //cantidad de $ que envia el usuario para comprar tokens == precio del token
        require(msg.value / phase(currentPhaseIndex).price == tokens, 'No tienes suficiente $'); 
        //comprobar que hay suficientes tokens para comprar
        require(phase(currentPhaseIndex).total <= __amount(tokens), 'En esta fase no hay tantos tokens disponibles para comprar');
        //comprabamos el balance de nuestro token
        require(token.balanceOf(address(this)) >= __amount(tokens), 'No hay tantos tokens dispobiles para comprar');
        //enviamos los tokens a la persona que los compra (destinatario, cantidad)
        require(token.transfer(msg.sender, __amount(tokens)));

        //actualizamos la cantidad de tokens vendidos
        sold += tokens;
        //actualizamos el nº de tokens disponibles en la fase
        phases[currentPhaseIndex].total -= tokens;

        //comprobamos si tenemos que pasar a una nueva fase (currentPhasePrice)
        if(phase(currentPhaseIndex).total <= 0)
            currentPhaseIndex++;

        //cambiamos el buyPrice (precio de los tokens) (i * buyPrice)
        buyPrice = phase(currentPhaseIndex).price;

        //evento indicando que se ha vendido un token (quien lo ha comprado, cantidad)
        emit Sell(msg.sender, tokens);
    }



    //función para saber cuantos tokens tiene el usuario
    function __tokens() public view returns(uint) {
        return __unAmount(token.balanceOf(msg.sender), 18);
    }

    //Función que devuelve el precio actual del token
    function __tokenPrice() public view returns(uint) {
        return buyPrice;
    }

    //función para terminar la venta pública (phase) o porqué queremos dejar de vender
    function endSale() public isOwner {
        //se hayan transferido todos los tokens (NO NATIVO) a la dirección del dueño
        require(token.transfer(owner, token.balanceOf(address(this))));
        //se haya transferido todos BNB($ NATIVO) a la dirección del dueño(lo convertimos el payable)
        payable(owner).transfer(address(this).balance);

    }

    //cantidad de tokens vendidos hasta este momento
    function tokensSold() public view returns(uint) {
        return sold;
    }

    //cantidad total de tokens que tenemos
    function totalTokens() public view returns(uint) {
        return __unAmount(token.totalSupply(), 18);
    }

    //Lista de las fases actuales de nuestro contrato de preventa
    function __phases() public view returns(Phase [] memory) {
        return phases;
    }
    
    //Devuelve la fase actual
    function currentPhase() public view returns(Phase memory) {
        return phase(currentPhaseIndex);
    }

    //función para comprobar que la persona que llama a la función es el DUEÑO del contrato
    function __isOwner() public view returns(bool) {
        return msg.sender == owner;
    }


    //función para devolvernos la fase en la que estamos mediante el id de la fase
    function phase(uint phase_id) public view returns(Phase memory) {
        return phases[phase_id];
    }

//===============================================================================
    //función que te da el nº real sin los 18 ceros
    function __unAmount(uint256 _amount, uint decimals) private pure returns(uint) {
        return _amount / (10 ** decimals);
    }

    //devuelve el valor en weis. Se adapta a los decimales del contrato
    function __amount(uint _amount) private pure returns(uint) {
        return _amount * (10**18);
    }
//===============================================================================


    //modificador / función restrictiva
    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}