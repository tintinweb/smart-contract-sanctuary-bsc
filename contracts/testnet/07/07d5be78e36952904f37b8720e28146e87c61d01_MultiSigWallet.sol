/**
 *Submitted for verification at BscScan.com on 2022-08-02
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

interface SignWallet{
    event Deposit(address indexed sender , uint amount , uint balance );
    event SubmitTransaction(address indexed owner ,uint indexed txIndex , address indexed to , uint256 value , bytes data );
    event RevokeConfirmation(address indexed owner , uint indexed txIndex);
    event ExcuteTransaction(address indexed owner , uint indexed txIndex);
    event ConfirmTransaction(address indexed owner , uint indexed txIndex);

    function submitTransaction(address to,uint value , bytes memory data) external   ;
    function confirmTransaction(uint transactionId) external  ;
    function executeTransaction(uint transactionId) external ;
    function revokeConfirmation(uint transactionId) external; 
}

contract MultiSigWallet is SignWallet{
    uint public _numConfirmationRequired ; 
    mapping (uint => address) public  owners ; 
    mapping(uint => Transaction) public transactions;
    mapping (address => bool) public isOwner;
    uint public _transactionCount ;
    struct Transaction {
        address to ;
        uint value ;
        bytes data ; 
        bool status;
        mapping(address => bool) isConfirmed ; 
        uint numConfirmations;
    }


    modifier onlyOwner (){
        require(isOwner[msg.sender],"only Owner");
        _;
    }

    modifier notNull() {
        require(msg.sender != address(0),"address error");
        _;
    }

    modifier transactionExists(uint transactionId)
    {
        require(transactions[transactionId].to != address(0) , "Not exists");
        _;
    }

    modifier notExecuted (uint transactionId)
    {
        require(!transactions[transactionId].status,"transaction already excecuted");
        _;
    }

    modifier notConfirmed(uint transactionId)
    {
        require(!transactions[transactionId].isConfirmed[msg.sender],"transaction already confirmed");
        _;
    }
    
    constructor(address [] memory owners_ , uint numConfirmationsRequired_) public 
    {
        require(owners_.length > 0, "Error owner > 2" );
        require(numConfirmationsRequired_ > 0 &&  numConfirmationsRequired_ < owners_.length," Erro numberConfirm");
        for(uint i = 0 ; i <  owners_.length ;i++)
        {
            address owner = owners_[i];
            require(owner != address(0),"NOt address 0x0000000...." );
            require(!isOwner[owner],"owner not unique" );
             owners[i] =  owner;
             isOwner[owner] = true;
        }        

    }
    
    
    function submitTransaction(address _to,uint _value , bytes memory _data) public  onlyOwner notNull override 
    {
              _addTransaction( _to, _value , _data);
    }

    function confirmTransaction(uint transactionId )
     public  onlyOwner  transactionExists(transactionId) notExecuted(transactionId) notConfirmed(transactionId) override 
    {
        transactions[transactionId].isConfirmed[msg.sender] = true;
        transactions[transactionId].numConfirmations += 1;
        emit ConfirmTransaction(msg.sender,transactionId);
    }
    function executeTransaction(uint transactionId) 
      public  onlyOwner  transactionExists(transactionId) notExecuted(transactionId) override
    {
        require(transactions[transactionId].numConfirmations > _numConfirmationRequired,"cannot execute tx");
        transactions[transactionId].status = true;
        (bool success,) = transactions[transactionId].to.call{value : transactions[transactionId].value  , gas : 5000}
                                                              (   abi.encodeWithSignature("foo(string,uint256)", "call foo", 123));

        require(success,"transaction failed");
        emit ExcuteTransaction(msg.sender,transactionId);
    }
    function revokeConfirmation(uint transactionId) 
      public  onlyOwner  transactionExists(transactionId) notExecuted(transactionId) notConfirmed(transactionId) override

    {
        Transaction storage trans = transactions[transactionId];
        require(trans.isConfirmed[msg.sender], "tx not confirmed");
        trans.isConfirmed[msg.sender] = false;
        trans.numConfirmations -= 1;
         emit RevokeConfirmation(msg.sender,transactionId);

    }


    //intenval
    function _addTransaction (address _to,uint _value , bytes memory _data) internal onlyOwner notNull   
     {
            uint transactionId = _transactionCount; 
            Transaction  storage trans = transactions[transactionId];
            trans.to = _to ;
            trans.value =_value;
            trans.data = _data;
            _transactionCount += 1 ;

          emit SubmitTransaction(
              msg.sender ,
              transactionId , 
              _to, 
              _value , 
              _data 
              );
    }

    receive() external payable {
            // React to receiving ether
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    function stakingPool() public view returns(uint256)
    {
        return address(this).balance;
    }

}