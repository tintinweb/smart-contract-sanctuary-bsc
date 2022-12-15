/**
 *Submitted for verification at BscScan.com on 2022-12-15
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract EscrowV1{

    using SafeMath for uint256;
    IERC20 public txToken;
    uint256 public _minimumEscrow;
    address payable public owner;
    uint256 public percentDivider;
    uint256 public currentVersion =1;

    uint256 public totalAgent;


    mapping(address=>bool) Admin;
    mapping(address=>bool) blackListedUser;

    mapping(uint256 => uint256) public adminCut;

    mapping(uint256 => IERC20) public versionedTxToken;

    uint256 public _escrowIds;
    mapping(uint256 => Escrow) public idToEscrow;
    mapping(address => uint256) public addressToEscrowCount;
    mapping(address => mapping(uint256 => uint256)) public addressToEscrowIndexes;

    mapping(address => broker) public Agent;
    mapping(uint256 => address) public AgentID;

    mapping(address => mapping(uint256 => brokenVersionComission)) public versionComissionInfo;

    uint256 brokerCutfromTotalCut;



    uint256[4] public escrowAmountCap = [1000000000000000000, 2000000000000000000, 3000000000000000000, 4000000000000000000]; 
    uint256[4] public fees = [40,30,20,10];

    constructor(address payable _owner,uint256 _minEscrowAmount,address tokenAddress, uint256 brokerCutVal) {
        owner = _owner; // Address of contract owner
        _minimumEscrow = _minEscrowAmount;
        txToken = IERC20(tokenAddress);
        percentDivider = 1000;
        brokerCutfromTotalCut = brokerCutVal;
    }

    enum EscrowState {
        PENDING,
        AWAITING_DELIVERY,
        DISPUTED,
        COMPLETED,
        REFUNDED
    }

    struct Escrow {
        uint256 id;
        address payable buyer;
        address payable seller;
        address payable broker;
        uint256 amount;
        uint256 fee;
        uint256 createdAt;
        uint256 expireAt;
        uint256 clearAt;
        uint256 version;
        EscrowState state;
    }

    struct broker{
        uint256 no_escrow_created;
        bool status;
        bool alreadyExist;
    }

    struct brokenVersionComission{
        uint256 commisionEarned;
        uint256 commisionClaimed;
    }


    event EscrowCreated(
        uint256 indexed escrowId,
        address buyer,
        address seller,
        address broker,
        uint256 indexed amount,
        uint256 indexed fee,
        EscrowState state
    );

    event EscrowUpdated(
        uint256 indexed escrowId,
        address buyer,
        address seller,
        address broker,
        uint256 amount,
        uint256 fee,
        EscrowState indexed state
    );

    modifier onlyowner() {
        require(owner == msg.sender, "only owner");
        _;
    }

    // Custom Code Area Begins
    modifier onlyBuyer(uint256 escrowId) {
        require(
            idToEscrow[escrowId].buyer == msg.sender,
            "Only Buyer Can Access"
        );
        _;
    }

    modifier onlySeller(uint256 escrowId) {
        require(
            idToEscrow[escrowId].seller == msg.sender,
            "Only Seller Can Access"
        );
        _;
    }

    modifier onlyOwnerOrAdmin(){
        require(owner == msg.sender || Admin[msg.sender],"Only Owner and Admin can perform this action");
        _;
    }

    modifier notBuyer(uint256 escrowId) {
        require(
            idToEscrow[escrowId].seller == msg.sender || owner == msg.sender,
            "Only seller or Owner can perform this action"
        );
        _;
    }

    function getFeeIndex(uint256 escrowAmount) public view returns (uint256) {
        uint256 index = 10;
        if(escrowAmount >= escrowAmountCap[0] && escrowAmount < escrowAmountCap[1]){
            index = 0;
        }
        if(escrowAmount >= escrowAmountCap[1] && escrowAmount < escrowAmountCap[2]){
            index = 1;
        }
        if(escrowAmount >= escrowAmountCap[2] && escrowAmount < escrowAmountCap[3]){
            index = 2;
        }
        if(escrowAmount >= escrowAmountCap[3]){
            index = 3;
        }
        return index;
    }

    function newEscrow(
        address _seller,
        uint256 expireIn,
        uint256 amount
    ) public payable {
        require(blackListedUser[_seller] == false && blackListedUser[msg.sender] == false,"Buyer or seller is blacklisted");
        _escrowIds++;
        uint256 curId = _escrowIds;
        require(
            amount >= _minimumEscrow,
            "Escrow must be larger then minimum amount"
        );
        uint256 feeIndex = getFeeIndex(amount);

        if(txToken == IERC20(0x0000000000000000000000000000000000000000)){
            require(msg.value >= _minimumEscrow, "Not less than Minimum");
            (bool success,)  = address(this).call{ value: msg.value}("");
            require(success== true);
        }
        else{
            txToken.transferFrom(msg.sender, address(this), amount);
        }
        
        uint256 fee = (amount * fees[feeIndex]) / percentDivider;
        uint256 _amount = amount - fee;
        idToEscrow[curId] = Escrow(
            curId,
            payable(msg.sender),
            payable(_seller),
            payable(address(0)),
            _amount,
            fee,
            block.timestamp,
            expireIn,
            0,
            currentVersion,
            EscrowState.AWAITING_DELIVERY
        );

        addressToEscrowCount[msg.sender] = addressToEscrowCount[msg.sender] + 1;
        addressToEscrowIndexes[msg.sender][
            addressToEscrowCount[msg.sender]
        ] = curId;
        addressToEscrowCount[_seller] = addressToEscrowCount[_seller] + 1;
        addressToEscrowIndexes[_seller][addressToEscrowCount[_seller]] = curId;

        emit EscrowCreated(
            curId,
            msg.sender,
            _seller,
            address(0),
            _amount,
            fee,
            EscrowState.PENDING
        );
    }


    function newEscrowByAgent(
        address _seller,
        address _buyer,
        uint256 expireIn,
        uint256 amount
    ) public payable {
        require(Agent[msg.sender].status== true,"Agent if block or not approved yet");
        require(blackListedUser[_seller] == false && blackListedUser[_buyer] == false,"Buyer or seller is blacklisted");
        _escrowIds++;
        uint256 curId = _escrowIds;
        require(
            amount >= _minimumEscrow,
            "Escrow must be larger then minimum amount"
        );
        uint256 feeIndex = getFeeIndex(amount);
        uint256 fee = (amount * fees[feeIndex]) / percentDivider;
        uint256 _amount = amount - fee;
        idToEscrow[curId] = Escrow(
            curId,
            payable(_buyer),
            payable(_seller),
            payable(msg.sender),
            _amount,
            fee,
            block.timestamp,
            expireIn,
            0,
            currentVersion,
            EscrowState.PENDING
        );

        addressToEscrowCount[msg.sender] = addressToEscrowCount[msg.sender] + 1;
        addressToEscrowIndexes[msg.sender][
            addressToEscrowCount[msg.sender]
        ] = curId;
        addressToEscrowCount[_seller] = addressToEscrowCount[_seller] + 1;
        addressToEscrowIndexes[_seller][addressToEscrowCount[_seller]] = curId;
        addressToEscrowCount[_buyer] = addressToEscrowCount[_buyer] + 1;
        addressToEscrowIndexes[_buyer][addressToEscrowCount[_buyer]] = curId;

        emit EscrowCreated(
            curId,
            _buyer,
            _seller,
            msg.sender,
            amount,
            fee,
            EscrowState.PENDING
        );
    }

    function escrowFunded(uint256 _escrowId)
        public
        payable
        onlyBuyer(_escrowId){
            require(idToEscrow[_escrowId].version == currentVersion," obsolute method");
            require(
            idToEscrow[_escrowId].state == EscrowState.PENDING,
            "Already Procesed Escrow");

            if(txToken == IERC20(0x0000000000000000000000000000000000000000)){
                require(msg.value >= idToEscrow[_escrowId].amount + idToEscrow[_escrowId].fee, "Minimum Required");
                (bool success,)  = address(this).call{ value: msg.value}("");
                require(success== true);
            }
            else{
                txToken.transferFrom(msg.sender, address(this), idToEscrow[_escrowId].amount + idToEscrow[_escrowId].fee);
            }
            
            idToEscrow[_escrowId].state = EscrowState.AWAITING_DELIVERY;

            emit EscrowUpdated(
                _escrowId,
                idToEscrow[_escrowId].buyer,
                idToEscrow[_escrowId].seller,
                idToEscrow[_escrowId].broker,
                idToEscrow[_escrowId].amount,
                idToEscrow[_escrowId].fee,
                EscrowState.AWAITING_DELIVERY
            );
        }

    function deliver(uint256 _escrowId)
        public
        onlyBuyer(_escrowId)
    {
        require(idToEscrow[_escrowId].version == currentVersion," obsolute method");
        require(
            idToEscrow[_escrowId].state == EscrowState.AWAITING_DELIVERY,
            "You can't deliver this escrow. Already updated before"
        );
        localTransfer(txToken,idToEscrow[_escrowId].seller,idToEscrow[_escrowId].amount);
        //txToken.transfer(idToEscrow[_escrowId].seller,idToEscrow[_escrowId].amount);
        if(idToEscrow[_escrowId].broker != address(0)){
            uint256 tempBrokerCut = idToEscrow[_escrowId].fee * brokerCutfromTotalCut / percentDivider;
            uint256 tempAdminCut = idToEscrow[_escrowId].fee - tempBrokerCut;
            adminCut[currentVersion] = adminCut[currentVersion]+tempAdminCut;
            versionComissionInfo[idToEscrow[_escrowId].broker][currentVersion].commisionEarned = versionComissionInfo[idToEscrow[_escrowId].broker][currentVersion].commisionEarned + tempBrokerCut;
        }
        else{
            adminCut[currentVersion] = idToEscrow[_escrowId].fee;
        }
        idToEscrow[_escrowId].clearAt = block.timestamp;
        idToEscrow[_escrowId].state = EscrowState.COMPLETED;

        emit EscrowUpdated(
            _escrowId,
            idToEscrow[_escrowId].buyer,
            idToEscrow[_escrowId].seller,
            idToEscrow[_escrowId].broker,
            idToEscrow[_escrowId].amount,
            idToEscrow[_escrowId].fee,
            EscrowState.COMPLETED
        );
    }

    function makeDisputedEscrow(uint256 _escrowId) public payable{
        require(idToEscrow[_escrowId].buyer == msg.sender || 
                idToEscrow[_escrowId].seller == msg.sender ||
                idToEscrow[_escrowId].broker == msg.sender,"Not Authorized");

        idToEscrow[_escrowId].state = EscrowState.DISPUTED;

        emit EscrowUpdated(
            _escrowId,
            idToEscrow[_escrowId].buyer,
            idToEscrow[_escrowId].seller,
            idToEscrow[_escrowId].broker,
            idToEscrow[_escrowId].amount,
            idToEscrow[_escrowId].fee,
            EscrowState.DISPUTED
        );
    }

    function solveDisputebyRefund(uint256 _escrowId) public onlyOwnerOrAdmin{
        require(
            idToEscrow[_escrowId].state == EscrowState.DISPUTED,
            "Not Disputed"
        );
        if(idToEscrow[_escrowId].version == currentVersion){
            localTransfer(txToken,idToEscrow[_escrowId].buyer,idToEscrow[_escrowId].amount);
            //txToken.transfer(idToEscrow[_escrowId].buyer,idToEscrow[_escrowId].amount);

            if(idToEscrow[_escrowId].broker != address(0)){
                uint256 tempBrokerCut = idToEscrow[_escrowId].fee * brokerCutfromTotalCut / percentDivider;
                uint256 tempAdminCut = idToEscrow[_escrowId].fee - tempBrokerCut;
                adminCut[currentVersion] = adminCut[currentVersion]+tempAdminCut;
                versionComissionInfo[idToEscrow[_escrowId].broker][currentVersion].commisionEarned = versionComissionInfo[idToEscrow[_escrowId].broker][currentVersion].commisionEarned + tempBrokerCut;
            }
            else{
                adminCut[currentVersion] = idToEscrow[_escrowId].fee;
            }
            
        }
        else{
            localTransfer(versionedTxToken[idToEscrow[_escrowId].version],idToEscrow[_escrowId].buyer,idToEscrow[_escrowId].amount);
            //versionedTxToken[idToEscrow[_escrowId].version].transfer(idToEscrow[_escrowId].buyer,idToEscrow[_escrowId].amount);
            if(idToEscrow[_escrowId].broker != address(0)){
                uint256 tempBrokerCut = idToEscrow[_escrowId].fee * brokerCutfromTotalCut / percentDivider;
                uint256 tempAdminCut = idToEscrow[_escrowId].fee - tempBrokerCut;
                adminCut[idToEscrow[_escrowId].version] = adminCut[idToEscrow[_escrowId].version]+tempAdminCut;
                versionComissionInfo[idToEscrow[_escrowId].broker][idToEscrow[_escrowId].version].commisionEarned = versionComissionInfo[idToEscrow[_escrowId].broker][currentVersion].commisionEarned + tempBrokerCut;
            }
            else{
                adminCut[idToEscrow[_escrowId].version] = idToEscrow[_escrowId].fee;
            }
        }
        
        idToEscrow[_escrowId].clearAt = block.timestamp;
        idToEscrow[_escrowId].state = EscrowState.REFUNDED;

        emit EscrowUpdated(
            _escrowId,
            idToEscrow[_escrowId].buyer,
            idToEscrow[_escrowId].seller,
            idToEscrow[_escrowId].broker,
            idToEscrow[_escrowId].amount,
            idToEscrow[_escrowId].fee,
            EscrowState.REFUNDED
        );
    }

    function solveDisputebyPayingSeller(uint256 _escrowId ) public onlyOwnerOrAdmin{
        require(
            idToEscrow[_escrowId].state == EscrowState.DISPUTED,
            "Not Disputed"
        );
        if(idToEscrow[_escrowId].version == currentVersion){
            localTransfer(txToken,idToEscrow[_escrowId].seller,idToEscrow[_escrowId].amount);
           // txToken.transfer(idToEscrow[_escrowId].seller,idToEscrow[_escrowId].amount);

            if(idToEscrow[_escrowId].broker != address(0)){
                uint256 tempBrokerCut = idToEscrow[_escrowId].fee * brokerCutfromTotalCut / percentDivider;
                uint256 tempAdminCut = idToEscrow[_escrowId].fee - tempBrokerCut;
                adminCut[currentVersion] = adminCut[currentVersion]+tempAdminCut;
                versionComissionInfo[idToEscrow[_escrowId].broker][currentVersion].commisionEarned = versionComissionInfo[idToEscrow[_escrowId].broker][currentVersion].commisionEarned + tempBrokerCut;
            }
            else{
                adminCut[currentVersion] = idToEscrow[_escrowId].fee;
            }
            
        }
        else{
            localTransfer(versionedTxToken[idToEscrow[_escrowId].version],idToEscrow[_escrowId].seller,idToEscrow[_escrowId].amount);
            //versionedTxToken[idToEscrow[_escrowId].version].transfer(idToEscrow[_escrowId].seller,idToEscrow[_escrowId].amount);
            if(idToEscrow[_escrowId].broker != address(0)){
                uint256 tempBrokerCut = idToEscrow[_escrowId].fee * brokerCutfromTotalCut / percentDivider;
                uint256 tempAdminCut = idToEscrow[_escrowId].fee - tempBrokerCut;
                adminCut[idToEscrow[_escrowId].version] = adminCut[idToEscrow[_escrowId].version]+tempAdminCut;
                versionComissionInfo[idToEscrow[_escrowId].broker][idToEscrow[_escrowId].version].commisionEarned =versionComissionInfo[idToEscrow[_escrowId].broker][currentVersion].commisionEarned + tempBrokerCut;
            }
            else{
                adminCut[idToEscrow[_escrowId].version] = idToEscrow[_escrowId].fee;
            }
        }
        
        idToEscrow[_escrowId].clearAt = block.timestamp;
        idToEscrow[_escrowId].state = EscrowState.COMPLETED;

        emit EscrowUpdated(
            _escrowId,
            idToEscrow[_escrowId].buyer,
            idToEscrow[_escrowId].seller,
            idToEscrow[_escrowId].broker,
            idToEscrow[_escrowId].amount,
            idToEscrow[_escrowId].fee,
            EscrowState.COMPLETED
        );
    }

    function refund(uint256 _escrowId) public onlySeller(_escrowId) {
        require(idToEscrow[_escrowId].version == currentVersion," obsolute method");
        require(
            idToEscrow[_escrowId].state == EscrowState.AWAITING_DELIVERY,
            "Can't refund this escrow. Already updated before"
        );
        localTransfer(versionedTxToken[idToEscrow[_escrowId].version],idToEscrow[_escrowId].buyer,idToEscrow[_escrowId].amount + idToEscrow[_escrowId].fee);
        //txToken.transfer(idToEscrow[_escrowId].buyer,idToEscrow[_escrowId].amount + idToEscrow[_escrowId].fee);
        idToEscrow[_escrowId].clearAt = block.timestamp;
        idToEscrow[_escrowId].state = EscrowState.REFUNDED;

        emit EscrowUpdated(
            _escrowId,
            idToEscrow[_escrowId].buyer,
            idToEscrow[_escrowId].seller,
            idToEscrow[_escrowId].broker,
            idToEscrow[_escrowId].amount,
            idToEscrow[_escrowId].fee,
            EscrowState.REFUNDED
        );
    }



    function withdrawObsoluteEscrowDeliver(uint256 _escrowId) public onlyBuyer(_escrowId){
        require(idToEscrow[_escrowId].version != currentVersion,"Not obsolute escrow");
        require(idToEscrow[_escrowId].state == EscrowState.AWAITING_DELIVERY,"Can't deliver this");
            require(idToEscrow[_escrowId].buyer == msg.sender, "only buyer can perform this action");
            localTransfer(versionedTxToken[idToEscrow[_escrowId].version],idToEscrow[_escrowId].seller,idToEscrow[_escrowId].amount);
            //versionedTxToken[idToEscrow[_escrowId].version].transfer(idToEscrow[_escrowId].seller,idToEscrow[_escrowId].amount);
            if(idToEscrow[_escrowId].broker != address(0)){
                uint256 tempBrokerCut = idToEscrow[_escrowId].fee * brokerCutfromTotalCut / percentDivider;
                uint256 tempAdminCut = idToEscrow[_escrowId].fee - tempBrokerCut;
                adminCut[idToEscrow[_escrowId].version] = adminCut[idToEscrow[_escrowId].version]+tempAdminCut;
                versionComissionInfo[idToEscrow[_escrowId].broker][idToEscrow[_escrowId].version].commisionEarned =versionComissionInfo[idToEscrow[_escrowId].broker][idToEscrow[_escrowId].version].commisionEarned + tempBrokerCut;
            }
            else{
                adminCut[idToEscrow[_escrowId].version] = idToEscrow[_escrowId].fee;
            }
            idToEscrow[_escrowId].clearAt = block.timestamp;
            idToEscrow[_escrowId].state = EscrowState.COMPLETED;
            emit EscrowUpdated(
                _escrowId,
                idToEscrow[_escrowId].buyer,
                idToEscrow[_escrowId].seller,
                idToEscrow[_escrowId].broker,
                idToEscrow[_escrowId].amount,
                idToEscrow[_escrowId].fee,
                EscrowState.COMPLETED
            );
        }

    function withdrawObsoluteEscrowRefund(uint256 _escrowId) public onlySeller(_escrowId){
        require(idToEscrow[_escrowId].version != currentVersion,"Not obsolute escrow");
        require(idToEscrow[_escrowId].state == EscrowState.AWAITING_DELIVERY,"Can't deliver this");
            localTransfer(versionedTxToken[idToEscrow[_escrowId].version],idToEscrow[_escrowId].buyer,idToEscrow[_escrowId].amount+ idToEscrow[_escrowId].fee);
            //versionedTxToken[idToEscrow[_escrowId].version].transfer(idToEscrow[_escrowId].buyer,idToEscrow[_escrowId].amount + idToEscrow[_escrowId].fee);
            idToEscrow[_escrowId].clearAt = block.timestamp;
            idToEscrow[_escrowId].state = EscrowState.REFUNDED;

            emit EscrowUpdated(
                _escrowId,
                idToEscrow[_escrowId].buyer,
                idToEscrow[_escrowId].seller,
                idToEscrow[_escrowId].buyer,
                idToEscrow[_escrowId].amount,
                idToEscrow[_escrowId].fee,
                EscrowState.REFUNDED
            );
        }
    /* Returns escrows based on roles */
    function fetchMyEscrows() public view returns (Escrow[] memory) {
        if (owner == msg.sender) {
            uint256 totalItemCount = _escrowIds;
            Escrow[] memory items = new Escrow[](totalItemCount);
            for (uint256 i = 0; i < totalItemCount; i++) {
                items[i] = idToEscrow[i + 1];
            }
            return items;
        } else {
            // if signer is not owner
            Escrow[] memory items = new Escrow[](
                addressToEscrowCount[msg.sender]
            );
            for (uint256 i = 0; i < addressToEscrowCount[msg.sender]; i++) {
                items[i] = idToEscrow[
                    addressToEscrowIndexes[msg.sender][i + 1]
                ];
            }
            return items;
        }
    }

    function fetchEscrowsPaginated(uint256 cursor, uint256 perPageCount)
        public
        view
        returns (
            Escrow[] memory data,
            uint256 totalItemCount,
            bool hasNextPage,
            uint256 nextCursor
        )
    {
        uint256 length = perPageCount;
        if (owner == msg.sender) {
            uint256 totalCount = _escrowIds;
            bool nextPage = true;
            if (length > totalCount - cursor) {
                length = totalCount - cursor;
                nextPage = false;
            } else if (length == (totalCount - cursor)) {
                nextPage = false;
            }
            Escrow[] memory items = new Escrow[](length);
            for (uint256 i = 0; i < length; i++) {
                items[i] = idToEscrow[cursor + i + 1];
            }
            return (items, totalCount, nextPage, (cursor + length));
        } else {
            bool nextPage = true;
            if (length > addressToEscrowCount[msg.sender] - cursor) {
                length = addressToEscrowCount[msg.sender] - cursor;
                nextPage = false;
            } else if (length == (addressToEscrowCount[msg.sender] - cursor)) {
                nextPage = false;
            }
            Escrow[] memory items = new Escrow[](length);
            for (uint256 i = 0; i < length; i++) {
                items[i] = idToEscrow[
                    addressToEscrowIndexes[msg.sender][cursor + i + 1]
                ];
            }
            return (
                items,
                addressToEscrowCount[msg.sender],
                nextPage,
                (cursor + length)
            );
        }
    }



    function claimAdminFee(uint256 _version) public onlyOwnerOrAdmin {
        if(_version == currentVersion){
            //txToken.transfer(msg.sender,adminCut[_version]);
            localTransfer(txToken,msg.sender,adminCut[_version]);
        }
        else{
            //versionedTxToken[_version].transfer(msg.sender,adminCut[_version]);
            localTransfer(versionedTxToken[_version],msg.sender,adminCut[_version]);
        }
        adminCut[_version]= 0;
    }

    function claimBrokerCut(uint256 _version) public onlyowner {
        if(_version == currentVersion){
            localTransfer(txToken,msg.sender,versionComissionInfo[msg.sender][_version].commisionEarned);
            //txToken.transfer(msg.sender,versionComissionInfo[msg.sender][_version].commisionEarned);
            versionComissionInfo[msg.sender][_version].commisionClaimed = versionComissionInfo[msg.sender][_version].commisionClaimed + versionComissionInfo[msg.sender][_version].commisionEarned;
            versionComissionInfo[msg.sender][_version].commisionEarned = 0;
        }
        else{
            localTransfer(versionedTxToken[_version],msg.sender,versionComissionInfo[msg.sender][_version].commisionEarned);
            //versionedTxToken[_version].transfer(msg.sender,versionComissionInfo[msg.sender][_version].commisionEarned);
            versionComissionInfo[msg.sender][_version].commisionClaimed = versionComissionInfo[msg.sender][_version].commisionClaimed + versionComissionInfo[msg.sender][_version].commisionEarned;
            versionComissionInfo[msg.sender][_version].commisionEarned = 0;
        }
    }

    function changeTxToken(address tokenAddress) public onlyowner{
        versionedTxToken[currentVersion] =  txToken;
        currentVersion++;
        txToken = IERC20(tokenAddress);
    }

    function fetchEscrow(uint256 escrowId) public view returns (Escrow memory) {
        return idToEscrow[escrowId];
    }

    function transferOwnership(address _newOwner) public onlyowner {
        owner = payable(_newOwner);
    }

    function changeMinEscrowAmount(uint256 _minAmount) public onlyOwnerOrAdmin{
        _minimumEscrow = _minAmount;
    }

    function setFeesOnCaping(
        uint256 first,
        uint256 second,
        uint256 third,
        uint256 fourth
    ) public onlyowner {
        require(first <= percentDivider,"Can't set more then 100");
        require(second <= percentDivider,"Can't set more then 100");
        require(third <= percentDivider,"Can't set more then 100");
        require(fourth <= percentDivider,"Can't set more then 100");
        fees[0] = first;
        fees[1] = second;
        fees[2] = third;
        fees[3] = fourth;
    }

    function setEscrowAmountCap(
        uint256 first,
        uint256 second,
        uint256 third,
        uint256 fourth
    ) public onlyOwnerOrAdmin {
        escrowAmountCap[0] = first;
        escrowAmountCap[1] = second;
        escrowAmountCap[2] = third;
        escrowAmountCap[3] = fourth;
    }

    function updateAdmin(address _address) public onlyowner
    {
        Admin[_address] = true;
    }
    
    function removeAdmin(address _address)public onlyowner
    {
        Admin[_address] = false;
    }

    function addBlacklistAddress(address _address) 
      public onlyOwnerOrAdmin
    {
        require(msg.sender == owner || Admin[_address], "not owner and admin");
        if(Agent[_address].alreadyExist == true){
            Agent[_address].status == false;
        }
        blackListedUser[_address] = true;
    }
    
    function removeBlacklistAddress(address _address)public onlyOwnerOrAdmin
    {
        blackListedUser[_address] = false;
    }


    function withdrawBNB() public onlyowner {
        uint256 balance = address(this).balance;
        require(balance > 0, "does not have any balance");
        payable(msg.sender).transfer(balance);
    }

    function withdrawToken(address addr,uint256 amount) public onlyowner {
        IERC20(addr).transfer(msg.sender
        , amount);
    }

    function newBrokerAddRequest() public payable{
        require(Agent[msg.sender].alreadyExist == false, "Agent Alredy Exist");
        AgentID[totalAgent] = msg.sender;
        totalAgent++;

        Agent[msg.sender] = broker(
            0,
            false,
            true
        );
    }

    function approveOrUnblockBroker(address addr) public onlyOwnerOrAdmin{
        Agent[addr].status = true;
    }

    function blockBroker(address addr) public onlyOwnerOrAdmin{
        Agent[addr].status = false;
    }

    function directBrokerAddByAdmin(address addr) public onlyOwnerOrAdmin{
        require(Agent[addr].alreadyExist == false, "Agent Alredy Exist");
        AgentID[totalAgent] = msg.sender;
        totalAgent++;

        Agent[addr] = broker(
            0,
            true,
            true
        );
    }
    function localTransfer(IERC20 tokenAddr, address to, uint256 amount) public payable{
        if(tokenAddr == IERC20(0x0000000000000000000000000000000000000000)){
            payable(to).transfer(amount);
        }
        else{
            tokenAddr.transfer(to,amount);
        }
    }


    // important to receive native    
    receive() payable external {}
}