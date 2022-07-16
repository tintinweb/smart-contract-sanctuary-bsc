/**
 *Submitted for verification at BscScan.com on 2022-07-16
*/

pragma solidity ^0.4.16;
    contract ForoBeta  {
        
        address public owner;

        struct FB_Intermediario
        {    
            address buyer;          // Quien ofrece el dinero
            address seller;         // Quien recibe el dinero
            address forobeta_owner;   // Wallet forobeta en caso de intermediar
                                       
            uint forobeta_fee;        // Fee
            uint amount;            // Cantidad de BNB (wei) que el vendedor recibirá despues de fees

            bool forobeta_interviene; //Buyer or Seller can call for Escrow intervention
            bool aprobar_fondos;   // true o false
            bool aprobar_reembolso;    // true o false

            bytes32 notes;             // Notas para el vendedor
            
        }

        struct TransactionStruct
        {                        
            address buyer;          // Quien hace el pago
            uint buyer_nounce;         // Nounce del comprador
        }


        
        // Base de datos de compradores
        mapping(address => FB_Intermediario[]) public buyerDatabase;

        // Base de datos de vendedores
        mapping(address => TransactionStruct[]) public sellerDatabase;        
        mapping(address => TransactionStruct[]) public escrowDatabase;
               
        mapping(address => uint) public Funds;

        mapping(address => uint) public forobetaFee;



        //Run once the moment contract is created. Set contract creator
        function ForoBetaIntermediario() {
            owner = msg.sender;
        }

        function() payable
        {
            //LogFundsReceived(msg.sender, msg.value);
        }

        function setforobetaFee(uint fee) {

            //Mover de 0.1% al 10%, en incrementos de 0.1%
            require (fee >= 1 && fee <= 100);
            forobetaFee[msg.sender] = fee;
        }

        function getforobetaFee(address walletForobeta) constant returns (uint) {
            return (forobetaFee[walletForobeta]);
        }

        
        function nuevoIntermediario(address walletVendedor, address walletForobeta, bytes32 notes) payable returns (bool) {

            require(msg.value > 0 && msg.sender != walletForobeta);
        
            //Store escrow details in memory
            FB_Intermediario memory currentEscrow;
            TransactionStruct memory currentTransaction;
            
            currentEscrow.buyer = msg.sender;
            currentEscrow.seller = walletVendedor;
            currentEscrow.forobeta_owner = walletForobeta;

            currentEscrow.forobeta_fee = getforobetaFee(walletForobeta)*msg.value/1000;
            
            //0.25% dev fee
            uint dev_fee = msg.value/400;
            Funds[owner] += dev_fee;   

            //Amount seller receives = Total amount - 0.25% dev fee - Escrow Fee
            currentEscrow.amount = msg.value - dev_fee - currentEscrow.forobeta_fee;
            
            currentEscrow.notes = notes;
 
            //Links this transaction to Seller and Escrow's list of transactions.
            currentTransaction.buyer = msg.sender;
            currentTransaction.buyer_nounce = buyerDatabase[msg.sender].length;

            sellerDatabase[walletVendedor].push(currentTransaction);
            escrowDatabase[walletForobeta].push(currentTransaction);
            buyerDatabase[msg.sender].push(currentEscrow);
            
            return true;

        }

        //switcher 0 for Buyer, 1 for Seller, 2 for Escrow
        function getNumTransactions(address inputAddress, uint switcher) constant returns (uint)
        {

            if (switcher == 0) return (buyerDatabase[inputAddress].length);

            else if (switcher == 1) return (sellerDatabase[inputAddress].length);

            else return (escrowDatabase[inputAddress].length);
        }

        //switcher 0 for Buyer, 1 for Seller, 2 for Escrow
        function getSpecificTransaction(address inputAddress, uint switcher, uint ID) constant returns (address, address, address, uint, bytes32, uint, bytes32)

        {
            bytes32 status;
            FB_Intermediario memory currentEscrow;
            if (switcher == 0)
            {
                currentEscrow = buyerDatabase[inputAddress][ID];
                status = checkStatus(inputAddress, ID);
            } 
            
            else if (switcher == 1)

            {  
                currentEscrow = buyerDatabase[sellerDatabase[inputAddress][ID].buyer][sellerDatabase[inputAddress][ID].buyer_nounce];
                status = checkStatus(currentEscrow.buyer, sellerDatabase[inputAddress][ID].buyer_nounce);
            }

                        
            else if (switcher == 2)
            
            {        
                currentEscrow = buyerDatabase[escrowDatabase[inputAddress][ID].buyer][escrowDatabase[inputAddress][ID].buyer_nounce];
                status = checkStatus(currentEscrow.buyer, escrowDatabase[inputAddress][ID].buyer_nounce);
            }

            return (currentEscrow.buyer, currentEscrow.seller, currentEscrow.forobeta_owner, currentEscrow.amount, status, currentEscrow.forobeta_fee, currentEscrow.notes);
        }   


        function checkStatus(address buyerAddress, uint nounce) constant returns (bytes32){

            bytes32 status = "";

            if (buyerDatabase[buyerAddress][nounce].aprobar_fondos){
                status = "Completado";
            } else if (buyerDatabase[buyerAddress][nounce].aprobar_reembolso){
                status = "Reembolsado";
            } else if (buyerDatabase[buyerAddress][nounce].forobeta_interviene){
                status = "Pendiente de Decision";
            } else
            {
                status = "En Progreso";
            }
       
            return (status);
        }

        
        //When transaction is complete, buyer will release funds to seller
        //Even if EscrowEscalation is raised, buyer can still approve fund release at any time
        function buyerFundRelease(uint ID)
        {
            require(ID < buyerDatabase[msg.sender].length && 
            buyerDatabase[msg.sender][ID].aprobar_fondos == false &&
            buyerDatabase[msg.sender][ID].aprobar_reembolso == false);
            
            //Set release approval to true. Ensure approval for each transaction can only be called once.
            buyerDatabase[msg.sender][ID].aprobar_fondos = true;

            address seller = buyerDatabase[msg.sender][ID].seller;
            address forobeta_owner = buyerDatabase[msg.sender][ID].forobeta_owner;

            uint amount = buyerDatabase[msg.sender][ID].amount;
            uint forobeta_fee = buyerDatabase[msg.sender][ID].forobeta_fee;

            //Move funds under seller's owership
            Funds[seller] += amount;
            Funds[forobeta_owner] += forobeta_fee;


        }

        //Seller can refund the buyer at any time
        function sellerRefund(uint ID)
        {
            address buyerAddress = sellerDatabase[msg.sender][ID].buyer;
            uint buyerID = sellerDatabase[msg.sender][ID].buyer_nounce;

            require(
            buyerDatabase[buyerAddress][buyerID].aprobar_fondos == false &&
            buyerDatabase[buyerAddress][buyerID].aprobar_reembolso == false); 

            address forobeta_owner = buyerDatabase[buyerAddress][buyerID].forobeta_owner;
            uint forobeta_fee = buyerDatabase[buyerAddress][buyerID].forobeta_fee;
            uint amount = buyerDatabase[buyerAddress][buyerID].amount;
        
            //Once approved, buyer can invoke WithdrawFunds to claim his refund
            buyerDatabase[buyerAddress][buyerID].aprobar_reembolso = true;

            Funds[buyerAddress] += amount;
            Funds[forobeta_owner] += forobeta_fee;
            
        }
        
        

        //Either buyer or seller can raise escalation with escrow agent. 
        //Once escalation is activated, escrow agent can release funds to seller OR make a full refund to buyer

        //Switcher = 0 for Buyer, Switcher = 1 for Seller
        function EscrowEscalation(uint switcher, uint ID)
        {
            //To activate EscrowEscalation
            //1) Buyer must not have approved fund release.
            //2) Seller must not have approved a refund.
            //3) EscrowEscalation is being activated for the first time

            //There is no difference whether the buyer or seller activates EscrowEscalation.
            address buyerAddress;
            uint buyerID; //transaction ID of in buyer's history
            if (switcher == 0) // Buyer
            {
                buyerAddress = msg.sender;
                buyerID = ID;
            } else if (switcher == 1) //Seller
            {
                buyerAddress = sellerDatabase[msg.sender][ID].buyer;
                buyerID = sellerDatabase[msg.sender][ID].buyer_nounce;
            }

            require(buyerDatabase[buyerAddress][buyerID].forobeta_interviene == false  &&
            buyerDatabase[buyerAddress][buyerID].aprobar_fondos == false &&
            buyerDatabase[buyerAddress][buyerID].aprobar_reembolso == false);

            //Activate the ability for Escrow Agent to intervent in this transaction
            buyerDatabase[buyerAddress][buyerID].forobeta_interviene = true;

            
        }
        
        //ID is the transaction ID from Escrow's history. 
        //Decision = 0 is for refunding Buyer. Decision = 1 is for releasing funds to Seller
        function escrowDecision(uint ID, uint Decision)
        {
            //Escrow can only make the decision IF
            //1) Buyer has not yet approved fund release to seller
            //2) Seller has not yet approved a refund to buyer
            //3) Escrow Agent has not yet approved fund release to seller AND not approved refund to buyer
            //4) Escalation Escalation is activated

            address buyerAddress = escrowDatabase[msg.sender][ID].buyer;
            uint buyerID = escrowDatabase[msg.sender][ID].buyer_nounce;
            

            require(
            buyerDatabase[buyerAddress][buyerID].aprobar_fondos == false &&
            buyerDatabase[buyerAddress][buyerID].forobeta_interviene == true &&
            buyerDatabase[buyerAddress][buyerID].aprobar_reembolso == false);
            
            uint forobeta_fee = buyerDatabase[buyerAddress][buyerID].forobeta_fee;
            uint amount = buyerDatabase[buyerAddress][buyerID].amount;

            if (Decision == 0) //Refund Buyer
            {
                buyerDatabase[buyerAddress][buyerID].aprobar_reembolso = true;    
                Funds[buyerAddress] += amount;
                Funds[msg.sender] += forobeta_fee;
                
            } else if (Decision == 1) //Release funds to Seller
            {                
                buyerDatabase[buyerAddress][buyerID].aprobar_fondos = true;
                Funds[buyerDatabase[buyerAddress][buyerID].seller] += amount;
                Funds[msg.sender] += forobeta_fee;
            }  
        }
        
        function WithdrawFunds()
        {
            uint amount = Funds[msg.sender];
            Funds[msg.sender] = 0;
            if (!msg.sender.send(amount))
                Funds[msg.sender] = amount;
        }


        function CheckBalance(address fromAddress) constant returns (uint){
            return (Funds[fromAddress]);
        }
     
    }