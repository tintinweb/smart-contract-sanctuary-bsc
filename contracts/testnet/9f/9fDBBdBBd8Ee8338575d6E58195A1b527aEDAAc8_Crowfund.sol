/**
 *Submitted for verification at BscScan.com on 2022-04-07
*/

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/utils/introspection/ERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;


/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File: contracts/Crowfund.sol

pragma solidity >=0.8.0 <0.9.1;

//import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";


// interface del contrato externo
abstract  contract ExternoETH  {
    function balanceOf(address account) external virtual view returns (uint256);
    function approve(address spender, uint256 amount) public virtual returns (bool);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external virtual returns (bool);
    function allowance(address owner, address spender) external virtual view returns (uint256);
}


//ejemplo de un crowdfund (juntar plata para algo)
contract Crowfund  {
    // variables (q uso en el contructor)
    string public id;
    string public name;
    string public description;
    address payable public author;

    struct RespuestaLinkExterno {
        bool respuesta;
        string destalle;
        address sender;
        address recipient; 
        uint256 amount;
    }
    
    RespuestaLinkExterno public respuestaLinkExterno;


    //variables ....q no uso en el costructor
    //string public state = "Opened"; 0 open 1 close
    mapping(address => uint) public balanceUsdtClientes; // los balances de los clientes 

    string private message; // mensaje q uso para el momento de fondear el contrato
    //bool public contactoLinkedUSDT; // vinculo con el contrato de usdt
    address private addressContratoExterno; // direccion del contrato de usdt

    uint256 public state = 0; // 0 open 1 close
    uint256 public funds; // ingreso de dinero
    uint256 public fundraisingGoal; // valor objetivo del fondo
    uint256 public fundRestante; // valor que falta para llegar al objetivo

    // evento para saber quien aporto y cuanto queda para llegar al objetivo
    // event ChangeFound(address editor, uint256 fundRestante);
    event ChangeFound(uint256 fundRestante);

    // evento para saber quien aporto y cuanto queda para llegar al objetivo
    // event ChangeFound(address editor, uint256 fundRestante);
    event ChangeState(uint256 state);

    //evento para cuando llamo a un contrato externo
    //event ResponseExterno(bool success, bytes data);
    event ResponseExterno(
        bool respuesta,
        string destalle,
        address sender,
        address recipient, 
        uint256 amount);

    // constructor (solo se ejecutal al momento del despliegue)
    constructor(
        
        string memory _id,
        string memory _name,
        string memory _description,
        uint256 _fundraisingGoal

        
    ) {
        
        id = _id;
        name = _name;
        description = _description;
        fundraisingGoal = _fundraisingGoal;
        fundRestante = _fundraisingGoal;
        author = payable(msg.sender);
        // contactoLinkedUSDT = false;
        addressContratoExterno = 0x337610d27c682E347C9cD60BD4b3b107C9d34dDd;
        /*
        id = "1";
        name = "guilleo";
        description = "description";
        fundraisingGoal = 1000000000;
        fundRestante = fundraisingGoal;
        author = payable(msg.sender);
*/
    }

    
    // controlo q solo el dueño pueda cambiar el estado
    modifier onlyOwner() {
        require(
            msg.sender == author,
            "Only owner can change the project state."
        );
        //require(msg.sender == author , "Only owner can change the project state.");
        //la función es insertada en donde aparece este símbolo
        _;
    }


    // controlo q el dueño no pueda aportar
    modifier notOwner() {
        require(msg.sender != author, "Owner cannot add to the proyect.");
        //la función es insertada en donde aparece este símbolo
        _;
    }

    // funcion para contactarme con el contrato de USDT para aprobar cuanto USDT puedo gastar en nombre del cliente
    function linkAproveUSDT (uint montoAprobar) public returns (bool) {
        
        // controlar que el cliente tenga saldo suficiente en su wallet. ?????????? ver si hace falta
        ExternoETH externo = ExternoETH(addressContratoExterno);
        
        bool respuesta;
        respuesta = externo.approve(msg.sender, montoAprobar);
       
        return respuesta;
    }

    // funcion para contactarme con el contrato de USDT para que el cliente nos transfiera USDT a nuestro contato
    function linkDepositUSDT (uint amountWithdraw) public  returns (RespuestaLinkExterno memory) {
        //  function transferFrom(address sender, address recipient, uint256 amount) external virtual returns (bool);

        // controlar que el cliente tenga saldo suficiente en su cuenta de nuestro contrato.
        // controlar que este aprobado el cliente   

        ExternoETH externo = ExternoETH(addressContratoExterno);
        
        bool respuesta;
        address ourAddress = address(this); //contract address  

/*
    //probar esta opcion:
        bool success;
            success = _Token.call(bytes4(sha3 ("allowance(uint256,address)") ), someInteger, someAddress)
            if (!success) { throw; // or something else}
*/
        respuesta = externo.transferFrom(msg.sender, ourAddress , amountWithdraw);
        
        respuestaLinkExterno.respuesta = respuesta;
        respuestaLinkExterno.destalle = "detalle hardcodeado";


        return respuestaLinkExterno;
    }


    // funcion para contactarme con el contrato de USDT para que el cliente nos transfiera USDT a nuestro contato
    function linkDepositUSDT2 (uint amountWithdraw) public  returns (RespuestaLinkExterno memory) {
        //  function transferFrom(address sender, address recipient, uint256 amount) external virtual returns (bool);
        // function allowance(address owner, address spender) external view returns (uint256)
        
        
        ExternoETH externo = ExternoETH(addressContratoExterno);
        address ourContractAddress = address(this); //contract address  

        // controlar que el cliente tenga aprobado ese monto en el contrato de USDT.
        uint256 resAllowance;
        resAllowance =  externo.allowance(ourContractAddress, msg.sender);
        require(resAllowance >= amountWithdraw, "Amount not approve!" );
        
        //bool respuesta;
        //respuesta = externo.transferFrom(msg.sender, ourContractAddress , amountWithdraw);
        
        respuestaLinkExterno.respuesta = true;
        respuestaLinkExterno.destalle = "detalle hardcodeado";
        respuestaLinkExterno.sender = msg.sender;
        respuestaLinkExterno.recipient  =ourContractAddress;
        respuestaLinkExterno.amount = amountWithdraw;

        emit ResponseExterno(
        respuestaLinkExterno.respuesta,
        respuestaLinkExterno.destalle,
        respuestaLinkExterno.sender,
        respuestaLinkExterno.recipient,
        respuestaLinkExterno.amount
        );

        return respuestaLinkExterno;
    }



    // funcion para contactarme con el contrato de USDT para tranferirle al cliente un monto de USDT
    function linkWithdrawUSDT (uint amountWithdraw) public returns (bool) {
        //     function transfer(address recipient, uint256 amount) external virtual returns (bool);
        // function balanceOf(address account) external view returns (uint256);

        ExternoETH externo = ExternoETH(addressContratoExterno);
        address ourContractAddress = address(this); //contract address  

        // controlar que el cliente tenga aprobado ese monto en el contrato de USDT.
        uint256 resAllowance;
        resAllowance =  externo.allowance(ourContractAddress, msg.sender);
        require(resAllowance >= amountWithdraw, "Amount not approve!" );

        // controlar que nuestro contato tenga suficiente saldo        
        uint balanceUsdtContrato = externo.balanceOf(ourContractAddress) ;
        require(balanceUsdtContrato >= amountWithdraw, "Nuestro contato no tiene saldo suficiente para la extraccion solictada por el cliente!" );

    
        // controlar que el cliente tenga saldo suficiente en nuestro mapping
        require(balanceUsdtClientes[msg.sender] >= amountWithdraw, "El cliente no tiene saldo suficiente para la extraccion depositado en nuestro contrato!" );
        


        balanceUsdtClientes[msg.sender] -= amountWithdraw;    //le disminuyo el saldo 
        bool respuestaTransfer;
        respuestaTransfer = externo.transfer(msg.sender, amountWithdraw);

        if (respuestaTransfer != true) {
            balanceUsdtClientes[msg.sender] += amountWithdraw;    //le aumento el saldo si algo salio mal
        }

        return respuestaTransfer;
    }



    // funcion para Cambiar el valor a juntar    
    function changefundraisingGoalProjectx2() public payable onlyOwner {
        require(state == 0, "Proyect is closed.");
        
        fundraisingGoal = fundraisingGoal * 2;
        fundRestante = fundraisingGoal - funds;
        emit ChangeFound(fundraisingGoal);
    }

    // funcion para Cambiar el valor a juntar    
    function changefundraisingGoalProjectx3() public payable onlyOwner {
        require(state == 0, "Proyect is closed.");
        
        fundraisingGoal = fundraisingGoal * 3;
        fundRestante = fundraisingGoal - funds;
        emit ChangeFound(fundraisingGoal);

    }    

    // funcion para setear un mensaje....y recaudar en el SC
    function setMessage(string memory newMessage) public payable {
        require(msg.value != 0);
        message = newMessage;
    }    

    // funcion para aportar
    //function fundProject() public payable notOwner {
    function fundProject() public payable notOwner {
        require(state == 0, "Proyect is closed.");
        require(msg.value > 0, "Not mouse acepted.");
        require((funds + msg.value) <= fundraisingGoal, "Overfound! ");
        author.transfer(msg.value); // usar el call en su lugar
        funds += msg.value;
        fundRestante -= msg.value;
        emit ChangeFound(fundraisingGoal);
    }

    // funcion para cambiar el estado del proyecto
    //function changeProjectState(string calldata newState) public onlyOwner {
    function changeProjectState(uint256 newState) public onlyOwner {
        require(newState == 0 || newState == 1, "Value not defined");
        require(newState != state, "State must be different");
        state = newState;
        emit ChangeState(state);
    }


}