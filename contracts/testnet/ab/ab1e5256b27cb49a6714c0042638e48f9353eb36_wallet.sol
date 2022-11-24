/**
 *Submitted for verification at BscScan.com on 2022-11-24
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
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
}

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
contract ERC20{
    string  public name;
    string  public symbol;
    uint256 public totalSupply;
    uint8   public decimals;
    address public owner = address(0x0);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner,address indexed spender,uint256 value);

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(address _owner,string memory _name, string memory _symbol, uint256 _totalSupply, uint8 _decimals) {
        owner = _owner;
        name = _name;
        symbol = _symbol;
        totalSupply = _totalSupply * 10 ** _decimals;
        decimals = _decimals;
        balances[_owner] = totalSupply;
        emit Transfer(address(this), _owner, totalSupply);
    }

    function balanceOf(address addr) public view returns (uint256) {
        return balances[addr];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(balanceOf(msg.sender) >= value);
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool) {
        require(balanceOf(from) >= value);
        require(allowance[from][msg.sender] >= value);
        balances[to] += value;
        balances[from] -= value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }
}
contract MutilSig{
    uint constant   public      MAX_OWNER_COUNT = 10;
    uint            private     MIN_RQUIRED_COUNT;
    uint256         public      NONCE = 0;
    address[]       private     owners;

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
    
    event Transfer(address from, address to, address contractAddr, uint value);
    
    constructor(address[] memory _owners, uint _required) payable {
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
        bool _ok = false;
        for(uint i = 0;i < owners.length; i++){
            if(owners[i] == msg.sender){
                _ok = true;
                break;
            }
        }
        require(_ok);
        _;
    }
    function getUnconfirmationTransaction()public view onlyOwners returns(uint _id){
        uint _nonce = 1;
        while(_nonce < NONCE){
            transaction memory _tx = allTransaction[_nonce];
            if(0 == _tx.status){
                _id = _tx.id;
            }
            _nonce++;
        }
    }
    function getTransaction(uint _nonce)public view onlyOwners returns(uint _id,address _from, address _to,address _token,uint256 _value,uint _confirm,uint _status){
        transaction memory _tx = allTransaction[_nonce];
        _id = _tx.id;
        _from = _tx.from;
        _to = _tx.to;
        _token = _tx.token;
        _value = _tx.value;
        _confirm = _tx.confirm;
        _status = _tx.status;
    }
    function transfer(ERC20 token,address to,uint value)internal onlyOwners {
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
    function getTransaction()public view{
        
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


    mapping(address=>address[]) public allMultiSig;

    event Created_MutilSig  (address contractAddr,address[] ownersAddr);
    event Created_ERC20     (address contractAddr,address   ownerAddr);
    function getMultiSig()public view returns(address[] memory){
        return allMultiSig[msg.sender];
    }
    function Create_MutilSig(address[] memory _owners,uint _required)public payable returns (address addr){
        require(msg.value >= fee);
        require(_owners.length >= 2 && _required <= _owners.length && _required > 0);
        payable(owner()).transfer(fee);
        bytes memory bytecode= type(MutilSig).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(_owners,_required));
        assembly {
             addr := create2(
             0,
             add(bytecode,0x20),
             mload(bytecode),
             salt
          )
        }
        for(uint i = 0;i < _owners.length;i++){
            allMultiSig[address(_owners[i])].push(addr);
        }
        emit Created_MutilSig(addr,_owners);
    }
    function Create_ERC20(string memory _name,string memory _symbol,uint256 _totalSupply,uint _decimals)public payable returns(address addr){
        require(msg.value >= fee);
        payable(owner()).transfer(fee);
        bytes memory bytecode= type(ERC20).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(msg.sender,_name,_symbol,_totalSupply,_decimals));
        assembly {
             addr := create2(
             0,
             add(bytecode,0x20),
             mload(bytecode),
             salt
          )
        }
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