/**
 *Submitted for verification at BscScan.com on 2022-06-29
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-26
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.6;
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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
        return c;
    }
}

abstract contract Ownable {
    using SafeMath for uint256;

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function Convert18(uint256 value) internal pure returns(uint256) {
        return value.mul(1000000000000000000);
    }

    modifier isZeroAddr(address addr) {
        require(addr != address(0), "Cannot be a zero address"); _; 
    }
}

contract ThreeDGO is IERC20, Ownable {
    using SafeMath for uint256;

    string private _name = "3D Travel 3D Shopping";
    string private _symbol = "3DGO";
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 9999999 * 10**18;
    mapping (address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    struct AirDropInfo {
        address account;
        string telPhone;
        uint256 value;
    }
    uint256 private _airDropRemain = 3000000 * 10**18; /// 空投
    AirDropInfo[] public _airDropHiostory;

    uint256 private _lpRemain = 1500000 * 10**18; /// LP
    mapping(address => uint256) public _lpHistory;

    constructor(address addr) {        
        _balances[addr] = 5499999 * 10**18;
        _balances[address(0)] = 4500000 *10**18;
    }

    function airDropRemain() public view returns (uint256) {
        return _airDropRemain;
    }

     function lpRemain() public view returns (uint256) {
        return _lpRemain;
    }

    function name() public view returns (string memory) {
        return _name;
    }
    
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() override public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        uint256 balance = _balances[account];
        return balance;
    }
    
    function airDropInfo(address account) public view  returns (
        string memory telPhone, uint256 value) {
        require(account != address(0), "TRC20: transfer from the zero address");

        uint len = _airDropHiostory.length;
        for (uint i = 0; i < len; ++i) {
            if (_airDropHiostory[i].account == account) {
                telPhone = _airDropHiostory[i].telPhone;
                value = _airDropHiostory[i].value;
                return(telPhone, value);
            }
        }

       return("", 0);
    }

    function lpAcquire(address account) public view returns (uint256){
        uint256 value = _lpHistory[account];
        return value;
    }

    function transfer(address recipient, uint256 amount)
     public override returns (bool)  {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function approve(address spender, uint256 amount)
        public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public virtual returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function airDrop(string memory telePhone, string memory code) public returns(bool) {
        require(_verifyTelephone(telePhone) && _verifyCode(code), "Telephone or code error!");

        uint len = _airDropHiostory.length;
        for (uint i = 0; i < len; ++i) {
            AirDropInfo storage info = _airDropHiostory[i];
            require (info.account != msg.sender, "This address have air dropped!");
            require (!_compairString(telePhone, info.telPhone), "TelePhone Used!");
        }
      
        uint256 value = 2 * 10**18;
        require(_airDropRemain > value, "Air drop finished!");

        AirDropInfo memory temp;
        temp.account = msg.sender;
        temp.telPhone = telePhone;
        temp.value.add(value);
         _airDropHiostory.push(temp);

        _airDropRemain.sub(value);
        _transfer(address(0), msg.sender, value);

        return true;
    }

    function lpPresent(address account, uint256 value) public onlyOwner returns(bool) {
        require(_lpRemain > 0, "Air drop finished!");
       
        if (_lpRemain > value) {
            _lpHistory[account].add(value);
            _lpRemain.sub(value);

            _transfer(address(0), account, value);         
        } else {
             _lpHistory[account].add(_lpRemain);
             _lpRemain.sub(_lpRemain);

            _transfer(address(0), account, _lpRemain);      
       }

        return true;
    }

    receive() external payable {}

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(to != address(0), "TRC20: transfer to the zero address");

        _balances[from] = _balances[from].sub(amount, "TRC20: transfer amount exceeds balance");
        _balances[to] = _balances[to].add(amount);
        
        emit Transfer(from, to, amount);
    }

    function _verifyTelephone(string memory telePhone) private pure returns(bool) {      
        bytes memory temp = bytes(telePhone);
        require(temp.length == 11, "Invalid TelePhone!");
        require(temp[0] == '1', "Invalid TelePhone!");
        require(temp[1] != '1' && temp[1] != '2' && temp[0] != '0', "Invalid TelePhone!");

        for(uint i = 1; i < 11; ++i)
        {
            if (temp[i] < '0' || temp[i] > '9') {
                return false;
            }
        }
        return true;
    }

    function _verifyCode(string memory code) private pure returns(bool) {
        bytes memory temp = bytes(code);
        require(temp.length == 6, "Invalid Verify Code!");

        for(uint i = 0; i < 6; ++i)
        {
            if (temp[i] < '0' || temp[i] > '9') {
                return false;
            }
        }
        
        if (temp[0] == temp[1] && temp[0] == temp[2] && temp[0] == temp[3]
            && temp[0] == temp[4] && temp[0] == temp[5]) {
            return false;
        }

        return true;
    }

    function _compairString(string memory str1, string memory str2) private pure returns(bool) {
        bytes memory byte1 = bytes(str1);
        bytes memory byte2 = bytes(str2);

        if (byte1.length != byte2.length) return false;

        for(uint i = 0; i < byte1.length; i ++) {
            if(byte1[i] != byte2[i]) return false;
        }

        return true;
    }
}