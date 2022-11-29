/**
 *Submitted for verification at BscScan.com on 2022-11-28
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;
// pragma experimental ABIEncoderV2;

abstract contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        transferOwnership(msg.sender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _owner, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

}

contract ERC20 {

    string  public  name;
    string  public  symbol;
    uint8   public  decimals;
    uint256 public  totalSupply;
    address public  owner = address(0x0);
    address public  factory;


    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner,address indexed spender,uint256 value);

    constructor(){
        factory = msg.sender;
    }
    function initialize(address _owner,string memory _name,string memory _symbol,uint256 _totalSupply,uint8 _decimals)public  {
        
        require(msg.sender == factory);
        owner = _owner;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply * 10 ** decimals;
        balances[msg.sender] = totalSupply;

        emit Transfer(address(0x0),_owner,totalSupply);
    }
    function balanceOf(address tokenOwner) public view returns (uint256)
    {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens) public returns (bool)
    {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender] - numTokens;
        balances[receiver] = balances[receiver] + numTokens;
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens)
        public
        returns (bool)
    {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address _owner, address _delegate) public view returns (uint256)
    {
        return allowed[_owner][_delegate];
    }

    function transferFrom(
        address _owner,
        address _buyer,
        uint256 _numTokens
    ) public returns (bool) {
        require(_numTokens <= balances[_owner]);
        require(_numTokens <= allowed[_owner][msg.sender]);

        balances[_owner] = balances[_owner] - _numTokens;
        allowed[_owner][msg.sender] = allowed[_owner][msg.sender] - _numTokens;
        balances[_buyer] = balances[_buyer] + _numTokens;
        emit Transfer(_owner, _buyer, _numTokens);
        return true;
    }
}

contract MutilSig{

    uint constant   public      MAX_OWNER_COUNT = 20;
    uint            private     MIN_RQUIRED_COUNT;
    uint256         public      NONCE = 0;
    address[]       private     owners;
    address         public      factory;


    struct transaction{
        uint                    id;
        address                 from;
        address                 to;
        address                 token;
        uint256                 value;
        address[]               confirmUser;
        uint                    confirm;
        uint                    status; // 0 pending 1 resolve  2 reject
    }

    mapping(uint=>mapping(address=>uint))   allConfirmUser;
    mapping(uint=>transaction)              allTransaction;

    constructor()payable{
        factory = msg.sender;
    }
    event Transfer_Create (address from, address to, address contractAddr, uint value);
    event Transfer_Confirm(uint id, address from, address to, address contractAddr, uint value);
    function initialize(address[] memory _owners, uint _required)public {
        require(msg.sender == factory);
        owners = _owners;
        MIN_RQUIRED_COUNT = _required;
    }
    modifier onlyOwners() {
        bool _isOwner = false;
        for(uint i = 0;i < owners.length; i++){
            if(owners[i] == msg.sender){
                _isOwner = true;
                break;
            }
        }
        require(_isOwner);
        _;
    }
    function getOwners() public view onlyOwners returns(address[] memory _owners){
        _owners = owners;
    } 
    function getUnconfirmationCount()public view onlyOwners returns(uint _count){
        uint _nonce = 1;
        while(_nonce < NONCE){
            transaction memory _tx = allTransaction[_nonce];
            if(0 == _tx.status && allConfirmUser[_nonce][msg.sender] == 0){
                ++_count;
            }
            _nonce++;
        }
    }
     function getTransaction(uint _nonce)public view returns(transaction memory _tx){
        _tx = allTransaction[_nonce];
    }
    // function getTransaction(uint _nonce)public view onlyOwners returns(transaction memory _tx){
    //     _tx = allTransaction[_nonce];
    // }
    function transfer(ERC20 token,address to,uint value)public onlyOwners {
        
        require(value > 0);

        if(address(token) == address(0x0)){
            require(address(this).balance >= value);
        }
        else{
            require(token.balanceOf(address(this)) >= value);
        }
        
        transaction memory _tx = transaction({
            id:     ++NONCE,
            from:   msg.sender,
            token:  address(token),
            confirmUser:new address[](MIN_RQUIRED_COUNT),
            confirm:1,
            to:     to,
            value:  value,
            status: 0
        });
        _tx.confirmUser[_tx.confirm - 1]= msg.sender;
        for(uint i = 0;i < owners.length; i++){
            allConfirmUser[NONCE][owners[i]] = 0;
        }
        allConfirmUser[NONCE][msg.sender] = 1;

        allTransaction[NONCE] = _tx;

        emit Transfer_Create(msg.sender,to,address(token),value);

    }

    function confirmation(uint _nonce,uint _status)public onlyOwners returns(bool) {
        
        transaction storage _tx = allTransaction[_nonce];

        require(_status == 2 || _status == 1);
        require(_tx.from != address(0x0) && _tx.status == 0);
        require(allConfirmUser[_nonce][msg.sender] == 0);
    
        if(_status == 2){
            allConfirmUser[NONCE][msg.sender] = 2;
            allTransaction[_nonce].status = 2;
            return true;
        }

        allConfirmUser[NONCE][msg.sender] = 1;
        _tx.confirm = _tx.confirm + 1;
        _tx.confirmUser[_tx.confirm - 1] = msg.sender;
        if(_tx.confirm < MIN_RQUIRED_COUNT){
            return true;
        }

        if(_tx.token == address(0x0)){
            require(address(this).balance >= _tx.value);
            payable(_tx.to).transfer(_tx.value);
        }
        else{
            require(ERC20(_tx.token).transfer(_tx.to,_tx.value));
        }

        allTransaction[_nonce].status = 1;

        emit Transfer_Confirm(_nonce,_tx.from,_tx.to,_tx.token,_tx.value);
        
        return true;
    } 
    

}
contract wallet is Ownable {

    uint256 public  fee     = 0.0002 * 10 ** 18;
    struct multSigUser{
        string      name;
        address     contractAddr;
        address[]   ownersAddr;
        uint        required;
    }
    // mapping(address=>address[]) private allMultiSig;
    mapping(address=>multSigUser[]) private allMultiSig;

    event Created_MutilSig  (address contractAddr,address   ownerAddr);
    event Created_ERC20TOKEN(address contractAddr,address   ownerAddr);
    function getMultiSig()public view returns(multSigUser[] memory){
        return allMultiSig[msg.sender];
    }
    function Create_MutilSig(address[] memory _owners,uint _required,string memory _name)public payable returns (address addr){
        require(msg.value >= fee);
        require(_required <= _owners.length && _required > 0,"Required Error");
        payable(owner()).transfer(fee);
        bytes memory bytecode= type(MutilSig).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(msg.sender,block.timestamp));
        assembly {
             addr := create2(
             0,
             add(bytecode,0x20),
             mload(bytecode),
             salt
          )
        }

        MutilSig(addr).initialize(_owners,_required);

        for(uint i = 0;i < _owners.length;i++){
            allMultiSig[_owners[i]].push(multSigUser(
                _name,addr,_owners,_required
            ));
        }

        emit Created_MutilSig(addr,msg.sender);
    }

    function Create_ERC20TOKEN(string memory _name,string memory _symbol,uint256 _totalSupply,uint8 _decimals)public payable returns(address addr){
        
        require(msg.value >= fee);
        payable(owner()).transfer(fee);
        bytes memory bytecode= type(ERC20).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(msg.sender,block.timestamp));
        assembly {
             addr := create2(
             0,
             add(bytecode,0x20),
             mload(bytecode),
             salt
          )
        }

        ERC20(addr).initialize(msg.sender,_name,_symbol,_totalSupply,_decimals);

        emit Created_ERC20TOKEN(addr,msg.sender);
    }

    function MutilTransfer(ERC20 token, address payable[] memory to, uint256[] memory amount) public payable {
        
        uint256 length = to.length;
        require(to.length == amount.length, "Transfer length error");
        uint allAmount;
        for (uint256 i = 0; i < length; i++) {
            allAmount += amount[i];
        }
        if(address(token) == address(0x0)){
            require(msg.value >= allAmount + fee, "Transfer amount error");
            payable(owner()).transfer(fee);
            for (uint256 i = 0; i < length; i++) {
                to[i].transfer(amount[i]);
            }
        }
        else{
            require(msg.value >= fee, "Transfer amount error");
            require(token.allowance(msg.sender, address(this)) >= allAmount,"Allowance amount error");
            payable(owner()).transfer(fee);
            for (uint256 i = 0; i < length; i++) {
                token.transferFrom(msg.sender, to[i], amount[i]);
            }
        }
    }

    function withdraw(ERC20 token) public onlyOwner{

        if(address(token) == address(0x0)){
            require(address(this).balance > 0);
            payable(owner()).transfer(address(this).balance);
        }
        else{
            require(token.balanceOf(address(this)) > 0);
            token.transfer(owner(), token.balanceOf(address(this)));
        }
    }

    function setFee(uint256 _fee) public onlyOwner {
        require(_fee > 0);
        fee = _fee;
    }
}