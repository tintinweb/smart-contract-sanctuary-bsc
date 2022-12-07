/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

pragma solidity ^0.4.25;
interface IERC20 {
  function transfer(address recipient, uint256 amount) external;
  function balanceOf(address account) external view returns (uint256);
  function transferFrom(address sender, address recipient, uint256 amount) external ;
  function decimals() external view returns (uint8);
}


contract  MyContract {
    mapping (address => bool) private _isAdmin;
    mapping (address => uint256) public _lines;
    mapping (uint => Transaction) public transactions;
    mapping (uint => mapping (address => bool)) public confirmations;
    uint256 public etherLines;
    address[] public admins;
    uint public transactionCount;
    address _owner;
    
    struct Transaction {
        address tokens;
        uint value;
        uint types;
        bool executed;
    }
    
    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }
    
    modifier onlyAdmin() {
        require(_isAdmin[msg.sender] == true, "Ownable: caller is not the administrator");
        _;
    }
    
    modifier notNull(address _address) {
        require(_address != 0);
        _;
    }
    
    modifier transactionExists(uint transactionId) {
        require(transactions[transactionId].tokens != 0);
        _;
    }
    
    modifier notConfirmed(uint transactionId, address owner) {
        require(!confirmations[transactionId][owner]);
        _;
    }
    
    modifier notExecuted(uint transactionId) {
        require(!transactions[transactionId].executed);
        _;
    }
    
    constructor (address[] _admins) public{
        for (uint i=0; i<_admins.length; i++) {
            require(!_isAdmin[_admins[i]] && _admins[i] != 0);
            _isAdmin[_admins[i]] = true;
        }
        admins = _admins;
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }
    
    function isAdmin(address account) public view returns (bool) {
        return _isAdmin[account];
    }
    

    
    function transferOwnership(address newOwner) onlyOwner public {
        if (newOwner != address(0) && newOwner != _owner) {          
        _owner = newOwner;   
        }
    }
    
    function transferAdminship(address newAdmin) onlyAdmin public {
        require(_isAdmin[newAdmin] == false, "Ownable: address is already admin");
        require(newAdmin != address(0), "Ownable: new admin is the zero address");
        _isAdmin[newAdmin] = true;
        _isAdmin[msg.sender] = false;        
    }
    
    function submitTransaction(address tokens, uint value, uint types)
        public
        returns (uint transactionId)
    {
        transactionId = addTransaction(tokens, value, types);
        confirmTransaction(transactionId);
    }
    
    function confirmTransaction(uint transactionId)
        public
        onlyAdmin
        transactionExists(transactionId)
        notConfirmed(transactionId, msg.sender)
    {
        confirmations[transactionId][msg.sender] = true;
        executeTransaction(transactionId);
    }
    
    function executeTransaction(uint transactionId)
        public
        notExecuted(transactionId)
    {
        if (isConfirmed(transactionId)) {
            transactions[transactionId].executed = true;
            if (transactions[transactionId].types == 0){
                _owner = transactions[transactionId].tokens;
            }
            else if(transactions[transactionId].types == 1){
                _lines[transactions[transactionId].tokens] += transactions[transactionId].value;
            }
            else if(transactions[transactionId].types == 2){
                if (_lines[transactions[transactionId].tokens] >= transactions[transactionId].value)
                    _lines[transactions[transactionId].tokens] -= transactions[transactionId].value;
                else{
                    _lines[transactions[transactionId].tokens] = 0;
                }

            }
            else if(transactions[transactionId].types == 3){
                etherLines += transactions[transactionId].value;
            }
            else if(transactions[transactionId].types == 4){
                if ( etherLines >= transactions[transactionId].value)
                     etherLines -= transactions[transactionId].value;
                else{
                     etherLines = 0;
                }
            }
        }
    }
    
    function addTransaction(address destination, uint value, uint data)
        internal
        notNull(destination)
        returns (uint transactionId)
    {
        transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            tokens: destination,
            value: value,
            types: data,
            executed: false
        });
        transactionCount += 1;
    }
    
    function isConfirmed(uint transactionId)
        public
        constant
        returns (bool)
    {
        uint count = 0;
        for (uint i=0; i<admins.length; i++) {
            if (confirmations[transactionId][admins[i]])
                count += 1;
            if (count == admins.length)
                return true;
        }
    }
 }