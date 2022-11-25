/**
 *Submitted for verification at BscScan.com on 2022-11-24
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract ERC20 is IERC20 {

    string  public  name;
    string  public  symbol;
    uint8   public  decimals;
    uint256 public  totalSupply;
    address public  owner = address(0x0);
    address public  factory;


    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    constructor(){
        factory = msg.sender;
    }
    function initialize(address _owner,string memory _name,string memory _symbol,uint256 _totalSupply,uint8 _decimals)public  {
        require(owner == address(0x0));
        owner = _owner;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply * 10 ** decimals;
        balances[msg.sender] = totalSupply;

        emit Transfer(address(0x0),_owner,totalSupply);
    }
    function balanceOf(address tokenOwner) public view override returns (uint256)
    {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens) public override returns (bool)
    {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender] - numTokens;
        balances[receiver] = balances[receiver] + numTokens;
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens)
        public
        override
        returns (bool)
    {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address _owner, address _delegate) public view override returns (uint256)
    {
        return allowed[_owner][_delegate];
    }

    function transferFrom(
        address _owner,
        address _buyer,
        uint256 _numTokens
    ) public override returns (bool) {
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
        uint                    confirm;
        uint                    status; // 0 pending 1 resolve  2 reject
    }

    mapping(uint=>mapping(address=>uint))   allConfirmUser;
    mapping(uint=>transaction)              allTransaction;

    constructor(){
        factory = msg.sender;
    }
    event Transfer(address from, address to, address contractAddr, uint value);
    receive() external payable {}
    function initialize(address[] memory _owners, uint _required)public {
        require(owners.length == 0);
        require(_owners.length <= _required && _required <= MIN_RQUIRED_COUNT);
        for (uint i = 0; i < _owners.length; i++) {
            if (_owners[i] == address(0x0)) {
                revert();
            }
        }
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
    function getTransaction(uint _nonce)public view onlyOwners returns(uint _id,address _from, address _to,address _token,uint256 _value,uint _confirm,uint _required,uint _status){
        transaction memory _tx = allTransaction[_nonce];
        _id = _tx.id;
        _from = _tx.from;
        _to = _tx.to;
        _token = _tx.token;
        _value = _tx.value;
        _confirm = _tx.confirm;
        _status = _tx.status;
        _required = MIN_RQUIRED_COUNT;
    }
    function transfer(IERC20 token,address to,uint value)internal onlyOwners {
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
            confirm:1,
            to:     to,
            value:  value,
            status: 0
        });

        for(uint i = 0;i < owners.length; i++){
            allConfirmUser[NONCE][owners[i]] = 0;
        }
        allConfirmUser[NONCE][msg.sender] = 1;

        allTransaction[NONCE] = _tx;

    }

    function confirmation(uint _nonce,uint _status)public onlyOwners  {
        
        transaction storage _tx = allTransaction[_nonce];

        require(_status == 2 || _status == 1);
        require(_tx.from != address(0x0) && _tx.status == 0);
        require(allConfirmUser[_nonce][msg.sender] == 0);
    
        if(_status == 2){
            allConfirmUser[NONCE][msg.sender] = 2;
            allTransaction[_nonce].status = 2;
            return;
        }

        allConfirmUser[NONCE][msg.sender] = 1;
        _tx.confirm = _tx.confirm + 1;

        if(_tx.confirm < MIN_RQUIRED_COUNT){
            return;
        }

        if(_tx.token == address(0x0)){
            require(address(this).balance >= _tx.value);
            payable(_tx.to).transfer(_tx.value);
        }
        else{
            require(IERC20(_tx.token).transfer(_tx.to,_tx.value));
        }

        allTransaction[_nonce].status = 1;

        emit Transfer(address(this),_tx.to,_tx.token,_tx.value);

    } 
    

}
contract wallet is Ownable {

    uint256 public  fee     = 0.0002 * 10 ** 18;


    mapping(address=>address[]) private allMultiSig;

    event Created_MutilSig  (address contractAddr,address   ownerAddr);
    event Created_ERC20     (address contractAddr,address   ownerAddr);
    function getMultiSig()public view returns(address[] memory){
        return allMultiSig[msg.sender];
    }
    function Create_MutilSig(address[] memory _owners,uint _required)public payable returns (address addr){
        require(msg.value >= fee);
        require(_required <= _owners.length && _required > 0,"Required Error");
        payable(owner()).transfer(fee);
        bytes memory bytecode= type(MutilSig).creationCode;
        bytes32 salt = keccak256(abi.encodePacked());
        assembly {
             addr := create2(
             0,
             add(bytecode,0x20),
             mload(bytecode),
             salt
          )
        }

        MutilSig(payable(addr)).initialize(_owners,_required);

        for(uint i = 0;i < _owners.length;i++){
            allMultiSig[_owners[i]].push(addr);
        }
        emit Created_MutilSig(addr,msg.sender);
    }
    function Create_ERC20(string memory _name,string memory _symbol,uint256 _totalSupply,uint8 _decimals)public payable returns(address addr){
        require(msg.value >= fee);
        payable(owner()).transfer(fee);
        bytes memory bytecode= type(ERC20).creationCode;
        bytes32 salt = keccak256(abi.encodePacked());
        assembly {
             addr := create2(
             0,
             add(bytecode,0x20),
             mload(bytecode),
             salt
          )
        }

        ERC20(addr).initialize(msg.sender,_name,_symbol,_totalSupply,_decimals);

        emit Created_ERC20(addr,msg.sender);
    }

    function MutilTransfer(IERC20 token, address payable[] memory to, uint256[] memory amount) public payable {
        
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

    function withdraw(IERC20 token) public onlyOwner{

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