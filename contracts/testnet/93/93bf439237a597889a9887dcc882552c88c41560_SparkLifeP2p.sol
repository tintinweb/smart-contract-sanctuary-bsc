pragma solidity 0.4.24;

import './ERC20.sol';
import './Ownable.sol';

contract SparkLifeP2p is Ownable {

     /**
        _
        Event's
    */
    event EnewOffertSell(address sellerAddress); // cuando un seller agrega una nueva oferta de venta de tokens SPS
    event EBought(address buyerAddress); // Cuando el seller libera los fondos
    event EoffertEscrow(address buyerAddress); // Cuando un buyer acepta oferta de seller (queda a la espera de consignar (el comprador o el vendedor segun el caso))
    event Ewithdraw(address withdrawToAddress, uint256 amount); // cuando un address realiza un retiro

    /**
        _
        Struct's
    */

    // Estructura del deposito
    struct SEscrow {    
        uint type_escrow;           // 0 => buy, 1 => sell
        uint256 spsCopPrice;        // Precio en cop de la oferta (Ejm. 1 SPS = 100 COP)
        uint256 weiAmmount;         // wei value
        address buyer;              // Persona quien realiza el pago
        address seller;             // Persona quien recibe los fondos
        address escrow_agent;       // Agente de transaccion quien resuelve si existe alguna disputa
                                    
        uint256 escrow_fee;            // Fee de la transaccion
        uint256 amount;                // Cantidad de SPS (en Wei) que recibe el vendedor despues de los fees

        bool escrow_intervention;   // El comprador o vendedor pueden llamar la intervencion del agente en la transaccion
        bool release_approval;      // El comprador o Agente (Si escrow_intervention es true) puede aprobar la liberacion de los fondos al vendedor
        bool refund_approval;       // El vendedor o Agente (Si escrow_intervention es true) puede aprobar devolver los fondos al comprador

        bytes32 notes;              //Notas para el vendedor
    }

    // Enlace a la transaccion del comprador
    struct STransaction {                        
        address buyer;     // Persona quien esta realizando el pago
        uint buyer_nounce; // nounce del comprador de la transaccion                 
    }

    struct SEscrower {                        
        uint active;     // esta activo
        uint256 fee;        // fee             
    }

    /**
        _
        Variables
    */

    // owner del contrato
    address public owner;

    // Base de datos de Compradores. Cada comprador tiene su propia tabla de registro de transacciones
    // Solo usamos este array para obtener la informacion del escrow cuando es llamado desde el buyer
    mapping(address => SEscrow[]) public buyerEscrowDatabase;
    // Registro de transacciones de venta
    mapping(address => SEscrow[]) public sellerEscrowDatabase; 

    // Base de datos del vendedor y del agente escrow
    mapping(address => STransaction[]) public sellerDatabase;        
    mapping(address => STransaction[]) public escrowDatabase;

    // Mapeo de vendedores
    address[] public sellers;

    //listado de agentes escrow y su respectivo fee
    mapping(address => SEscrower) public escrowers;
            
    /**
        Cada dirección tiene un banco de Fondos.
        Todos los reembolsos, ventas y comisiones de depósito en garantía se envían a este banco.
        El propietario de la dirección puede retirarlos en cualquier momento.
    */
    mapping(address => uint) public Funds;

    /**
        Token SPS
    */
    ERC20 spsToken;

    /**
        _
        Body
    */
    constructor(ERC20 _spsToken) public {
        spsToken = _spsToken;
        owner = msg.sender;
    }

    function() payable public {
    }

    /**
        Agregar un Agente
    */
    function addAgentEscrower(address escrowerAddress, uint256 fee, uint active) public onlyOwner {
        require (escrowerAddress != address(0));
        escrowers[escrowerAddress] = SEscrower(active, fee);
    }

    /**
        Excecuted by: Agent
        Asignar un % de fee para el agente escrow sobre la transaccion
    */
    function setEscrowFee(address escrowerAddress, uint256 fee) public onlyOwner {
        // Rango permitido: 0.1% al 10%, en incrementos de 0.1%
        require (fee >= 1 && fee <= 100);
        escrowers[escrowerAddress].fee = fee;
    }

    /**
        Obtener el fee actual del Escrow agent
    */
    function getEscrowFee(address escrowAddress) constant public returns (uint256) {
        return (escrowers[escrowAddress].fee);
    }

    /**
        Agregar un Seller (Vende SPS por COP - Vende COP por SPS)
    */
    function addSeller(address seller) public onlyOwner {
        // Rango permitido: 0.1% al 10%, en incrementos de 0.1%
        require (seller != address(0));
        sellers.push(seller);
    }
    
    /**
        Excecuted by: Seller
        Funcion encargada de agregar un nuevo deposito para comprar o vender sps

        sellOrBuy: 1 => Sell, 0 => Buy
    */
    function newEscrowSellOrBuy(uint256 weiAmmount, address escrowAddress, bytes32 notes, uint sellOrBuy, uint256 spsCopPrice) public returns (bool) {

        // Validar cantidad SPS a vender
        require(weiAmmount > 0 && msg.sender != escrowAddress);

        // 1 = Venta de token SPS (Deposito)
        if (sellOrBuy == 1) {
            require(spsToken.balanceOf(msg.sender) >= weiAmmount, "You don't have SPS Balance");
            // Validar permiso en el contrato SPS coin sobre el contrato actual
            uint256 allowance = spsToken.allowance(msg.sender, address(this));
            require(allowance >= weiAmmount, "Check the token SPS allowance");

            // Depositar el token sps al contrato p2p
            spsToken.transferFrom(msg.sender, address(this), weiAmmount);
        }

        // Guardar los detalles del deposito en memoria
        SEscrow memory currentEscrow;
        currentEscrow.type_escrow = sellOrBuy;
        currentEscrow.seller = msg.sender;
        currentEscrow.escrow_agent = escrowAddress;
        currentEscrow.spsCopPrice = spsCopPrice;
        currentEscrow.weiAmmount = weiAmmount;

        // Calcular y guardar el fee del deposito
        currentEscrow.escrow_fee = getEscrowFee(escrowAddress)*weiAmmount/1000;        
        //0.25% owner fee (CAMBIAR)
        uint owner_fee = weiAmmount/400;
        Funds[owner] += owner_fee;   

        // Cantidad que el comprador recibe = Total amount - 0.25% owner fee - Escrow Fee
        currentEscrow.amount = weiAmmount - owner_fee - currentEscrow.escrow_fee;
        // Notas del comprador al vendedor
        currentEscrow.notes = notes;
        sellerEscrowDatabase[msg.sender].push(currentEscrow);

        emit EnewOffertSell(msg.sender);
        return true;
    }

    /**
        Excecuted by: COMPRADOR (BUYER)
        Aplicar a una oferta de compra a la oferta un vendedor (SPS to COP - COP to SPS)
        En este caso, el comprador (buyer) debe de enviar el fiat o SPS al vendedor
    */
    function offertEscrow(address sellerAddress, uint ID) public returns (bool) {

        require(ID < sellerEscrowDatabase[sellerAddress].length && 
        sellerEscrowDatabase[sellerAddress][ID].release_approval == false &&
        sellerEscrowDatabase[sellerAddress][ID].refund_approval == false);

        STransaction memory currentTransaction;
        sellerEscrowDatabase[sellerAddress][ID].buyer = msg.sender;

        // si es una venta (seller vende sps)
        // el comprador debe depositar sps
        if (sellerEscrowDatabase[sellerAddress][ID].type_escrow == 0) {
            require(spsToken.balanceOf(msg.sender) >= sellerEscrowDatabase[sellerAddress][ID].weiAmmount, "You don't have SPS Balance");
            // Validar permiso en el contrato SPS coin sobre el contrato actual
            uint256 allowance = spsToken.allowance(msg.sender, address(this));
            require(allowance >= sellerEscrowDatabase[sellerAddress][ID].weiAmmount, "Check the token SPS allowance");

            // Depositar el token sps al contrato p2p
            spsToken.transferFrom(msg.sender, address(this), sellerEscrowDatabase[sellerAddress][ID].weiAmmount);
        }

        // Vincula esta transacción a la lista de transacciones del vendedor y Agente Escrow
        currentTransaction.buyer = msg.sender;
        currentTransaction.buyer_nounce = sellerEscrowDatabase[sellerAddress].length;

        sellerDatabase[sellerAddress].push(currentTransaction);
        escrowDatabase[sellerEscrowDatabase[sellerAddress][ID].escrow_agent].push(currentTransaction);
        // copy escrow al buyer (Obtener SellerEscrow by Buyer)
        buyerEscrowDatabase[msg.sender][ID] = sellerEscrowDatabase[sellerAddress][ID];

        emit EoffertEscrow(msg.sender);
        return true;
    }

    /**
        Excecuted by: Seller & buyer
        Cuando se haya completado la transaccion (es decir, que el buyer haya consignado)
        el seller liberará los fondos al buyer
        Aun si EscrowEscalation esta activo, el seller podra aprobar la liberacion de los fondos en cualquier momento
    */
    function fundRelease(address sellerAddress, uint ID) public {

        require(ID < sellerEscrowDatabase[sellerAddress].length && 
        sellerEscrowDatabase[sellerAddress][ID].release_approval == false &&
        sellerEscrowDatabase[sellerAddress][ID].refund_approval == false);
        
        // Asignar release_approval en true. 
        // esto asegura que la aprobacion de la transaccion solo se puede hacer 1 vez.
        sellerEscrowDatabase[sellerAddress][ID].release_approval = true;

        address buyer = sellerEscrowDatabase[sellerAddress][ID].buyer;
        address escrow_agent = sellerEscrowDatabase[sellerAddress][ID].escrow_agent;

        uint amount = sellerEscrowDatabase[sellerAddress][ID].amount;
        uint escrow_fee = sellerEscrowDatabase[sellerAddress][ID].escrow_fee;

        // Si el vendedor esta comprando SPS
        if (sellerEscrowDatabase[sellerAddress][ID].type_escrow == 0) {
            // El seller no puede liberar los fondos
            require(buyer == msg.sender, "Waiting buyer found release");
            Funds[sellerAddress] += amount;
        }
        else {
            // la liberacion se hace al buyer
            require(sellerAddress == msg.sender, "Only Seller can release founds");
            Funds[buyer] += amount;
        }

        Funds[escrow_agent] += escrow_fee;
        emit EBought(buyer);
    }

    /**
        Historial de ventas
    */
    function sellerEscrowHistory(address sellerAddress, uint startID, uint numToLoad) constant public returns (address[], address[],uint[], bytes32[]){

        uint length;
        if (sellerEscrowDatabase[sellerAddress].length < numToLoad)
            length = sellerEscrowDatabase[sellerAddress].length;
        
        else 
            length = numToLoad;
        
        address[] memory buyers = new address[](length);
        address[] memory escrow_agents = new address[](length);
        uint[] memory amounts = new uint[](length);
        bytes32[] memory statuses = new bytes32[](length);
        
        for (uint i = 0; i < length; i++)
        {

            buyers[i] = (sellerEscrowDatabase[sellerAddress][startID + i].buyer);
            escrow_agents[i] = (sellerEscrowDatabase[sellerAddress][startID + i].escrow_agent);
            amounts[i] = (sellerEscrowDatabase[sellerAddress][startID + i].amount);
            statuses[i] = checkStatus(sellerAddress, startID + i);
        }
        
        return (buyers, escrow_agents, amounts, statuses);
    }

    /**
        Obtener el listado de ofertas (Compra y venta) que aun no tienen un comprador
    */
    function activeEscrowList(uint numToLoad) constant public returns (address[], address[], uint[], bytes32[], uint[]){

        uint length;
        if (sellers.length < numToLoad)
            length = sellers.length;        
        else 
            length = numToLoad;
        
        address[] memory buyers = new address[](length);
        address[] memory escrow_agents = new address[](length);
        uint[] memory amounts = new uint[](length);
        bytes32[] memory statuses = new bytes32[](length);
        uint[] memory ids = new uint[](length);
        
        for (uint i = 0; i < length; i++) {
            for (uint j = 0; j < sellerEscrowDatabase[sellers[i]].length; j++) {
                // Solo se listan las odenes que no tengan comprador
                if (sellerEscrowDatabase[sellers[i]][j].buyer == address(0)) {
                    buyers[i] = (sellerEscrowDatabase[sellers[i]][j].buyer);
                    escrow_agents[i] = (sellerEscrowDatabase[sellers[i]][j].escrow_agent);
                    amounts[i] = (sellerEscrowDatabase[sellers[i]][j].amount);
                    statuses[i] = checkStatus(sellers[i], j);
                    ids[i] = j;
                }
            }
        }
        return (buyers, escrow_agents, amounts, statuses, ids);
    }

    /**
        _
        Agent functions
    */

    /**
        Tanto el comprador como el vendedor pueden escalar la transaccion a un Agente Escrow 
        Una vez se activa la escalada, el agente puede liberar los fondos al comprador o reembolsar saldo al vendedor 
        Switcher = 0 for Buyer, Switcher = 1 for Seller
    */
    function EscrowEscalation(uint switcher, uint ID) public {
        // Para activar EscrowEscalation
        //1) El vendedor no ha aprobado la liberacion de los fondos.
        //2) El comprador no ha enviado o consignado el valor de la compra.
        //3) EscrowEscalation es activo por primera vez

        // No importa si es el vendedor o comprador quien activa la escalacion
        address sellerAddress;
        if (switcher == 1) // Seller
        {
            sellerAddress = msg.sender;
        } else if (switcher == 0) // Buyer
        {
            // Buscamos el Seller en la transaccion del buyer (en tal caso)
            sellerAddress = buyerEscrowDatabase[msg.sender][ID].seller;
        }

        require(sellerEscrowDatabase[sellerAddress][ID].escrow_intervention == false  &&
            sellerEscrowDatabase[sellerAddress][ID].release_approval == false &&
            sellerEscrowDatabase[sellerAddress][ID].refund_approval == false);

        //Activate the ability for Escrow Agent to intervent in this transaction
        sellerEscrowDatabase[sellerAddress][ID].escrow_intervention = true;
        
    }

    /**
        El Agente toma una desicion
        Decision = 0 devolver fondos
        Decision = 1 Liberar fondos
        ID El id de la transaccion del Escrow history
    */
    function escrowDecision(uint ID, uint Decision) public {
        // El Agente escrow solo puede tomar la desicion si:
        //1) Seller no ha aprobado la liberacion de los fondos al buyer
        //2) El buyer no ha reembolsado al seller
        //3) El agente no ha aprovado la liberacion de los fondos al buyer y no se a aprobado un reembolso al seller
        //4) Escalation Escalation es activated

        address buyerAddress = escrowDatabase[msg.sender][ID].buyer;
        address sellerAddress = buyerEscrowDatabase[buyerAddress][ID].seller;
        
        require(
            buyerAddress != address(0) &&
            sellerEscrowDatabase[sellerAddress][ID].release_approval == false &&
            sellerEscrowDatabase[sellerAddress][ID].escrow_intervention == true &&
            sellerEscrowDatabase[sellerAddress][ID].refund_approval == false);
        
        uint escrow_fee = sellerEscrowDatabase[sellerAddress][ID].escrow_fee;
        uint amount = sellerEscrowDatabase[sellerAddress][ID].amount;

        if (Decision == 0) { // Reembolsar SPS al seller o buyer
            // si el seller esta vendiendo SPS
            if (sellerEscrowDatabase[sellerAddress][ID].type_escrow == 1) {
                sellerEscrowDatabase[sellerAddress][ID].refund_approval = true;
                Funds[sellerAddress] += amount;
            }
            else { // en este caso se devuelve lo que depositó (SPS) el comprador
                sellerEscrowDatabase[sellerAddress][ID].refund_approval = true;
                Funds[buyerAddress] += amount;
            }
        } else if (Decision == 1) { // Liberar fondos al Buyer o Seller
            if (sellerEscrowDatabase[sellerAddress][ID].type_escrow == 1) {
                sellerEscrowDatabase[sellerAddress][ID].release_approval = true;
                Funds[buyerAddress] += amount;
            }
            else { // Liberar fondos al seller (comprando SPS)
                sellerEscrowDatabase[sellerAddress][ID].release_approval = true;
                Funds[sellerAddress] += amount;
            }
        }
        Funds[msg.sender] += escrow_fee;
    }

    /**
        Retiros SPS
    */
    function WithdrawFunds() public {
        // Validar saldo
        require(spsToken.balanceOf(address(this)) > 0, "P2P Contract don't have founds");

        uint amount = Funds[msg.sender];
        Funds[msg.sender] = 0;
        if (!spsToken.transfer(msg.sender, amount))
            Funds[msg.sender] = amount;
    }

    /**
        Estado de cada transaccion
    */
    function checkStatus(address sellerAddress, uint nounce) constant public returns (bytes32){

        bytes32 status = "";

        if (sellerEscrowDatabase[sellerAddress][nounce].release_approval){
            status = "Complete";
        } else if (sellerEscrowDatabase[sellerAddress][nounce].refund_approval){
            status = "Refunded";
        } else if (sellerEscrowDatabase[sellerAddress][nounce].escrow_intervention){
            status = "Pending Escrow Decision";
        } else
        {
            status = "In Progress";
        }

        return (status);
    }

}