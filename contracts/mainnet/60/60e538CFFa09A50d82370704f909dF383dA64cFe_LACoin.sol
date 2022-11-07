/**
 *Submitted for verification at BscScan.com on 2022-11-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;


interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}
interface IERC20Metadata is IERC20 { 
  
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
interface ILACoinController 
{

    /// ERC20 
    function transfer(address owner, address recipient, uint amount) external returns (bool);
    function approve(address owner,address spender, uint amount) external returns (bool);

    //// USER
    function register(uint referlaId) external;

    //// Deposite
    function deposite (uint amount)external returns(bool);
    function withdrawProfit() external;
    function withdrawAll() external;

    //// API
    function destroyToken(address acc, uint amount) external ;
    function addTokenforCoin(address acc, uint amount) external;
    function updateStatus(address acc)  external;

    //// Presale
    function buyPresaleToken(address acc, uint amount) external returns(bool, uint,uint);
}
interface IView 
{
    function isUserExist(address acc) external view returns(bool);
    function isUserExistById(uint id) external view returns(bool);
    function getReferalIdById(uint id) external view returns(uint);
    function getAddressById(uint id) external view returns (address);
    function getIdByAddress(address acc)external view returns(uint);
    function getUser(uint id)external view returns(address,uint,uint,uint8,uint);
    function getRefCount(uint id, uint8 lvl) external view returns (uint);
    function getStatsCount(uint id) external view returns (uint);
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function getEmission() external view returns(uint);
    function getFrozenToken(address acc) external view returns(uint);
    function getFrozenDate(address acc) external view returns(uint);
    function balanceWithFrozen(address acc) external view returns(uint);
    function getDeposite(address acc) external view returns(uint);
    function getDepositeDate(address acc) external view returns(uint);
    function getDepositeProfit(address acc) external view returns(uint);
    function getPresaleCount() external view returns(uint);
    function getPrice() external view returns(uint);
    function getPresaleStart() external view returns (bool);
    function getPresaleStartDate() external view returns(uint);
    function getPresaleEndDate() external view returns(uint);
    function getPresaleLimit(address acc)external view returns(uint);
    function getMaxToken() external view returns(uint);
    function checkUpdate(uint id) external view returns(bool);
}
abstract contract Context 
{
    function _msgSender() internal view virtual returns (address) 
    {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) 
    {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context
{
    address _owner;

    constructor()  
    {
        _owner = payable(msg.sender);
    }

    modifier onlyOwner() 
    {
        require(_msgSender() == msg.sender, "Only owner");
        _;
    }
}

contract LACoin is IERC20Metadata, Ownable
{
    ILACoinController controller;
    IView View;
    string public _name = "EVOLUTION MULTY GAME";  
    string public _symbol = "EVO"; 
    address private _proxy;
    modifier isProxy() 
    {
        require(msg.sender == _proxy);
        _;
    }
    constructor (address proxyAdr, address controllerAdr, address viewAdr)
    {
       _proxy = proxyAdr;
       controller = ILACoinController(controllerAdr);
       View = IView(viewAdr);
    }



/// Metadata
    function name() public override view returns (string memory)
    {
        return _name;
    }
    function symbol() public override view returns (string memory)
    {
        return _symbol;
    }
    function decimals() public override pure returns (uint8)
    {
        return 18;
    }
///

/// ERC20
    function totalSupply() public override view returns (uint)
    {
        return View.totalSupply();
    }
    function balanceOf(address account) public override view returns (uint)
    {
        return View.balanceOf(account);
    }
    function transfer(address recipient, uint amount) public override returns (bool)
    {
        require(View.balanceOf(msg.sender)>=amount,"Not enougtht tokens");
        require(recipient != address(0), "pecipient is 0" );
        bool answer = controller.transfer(msg.sender,recipient, amount);
        if (answer)
        {
            emit Transfer(msg.sender, recipient, amount);
        }
        return answer;
    }
    function allowance(address owner, address spender) public override view returns (uint)
    {
        return View.allowance(owner, spender);
    }
    function approve(address spender, uint amount) external returns (bool)
    {
        bool answer = controller.approve(msg.sender, spender, amount);
        if (answer)
        {
            emit Approval( msg.sender, spender, amount);
        }
        return answer;
    }
    function transferFrom(address from, address to, uint amount) external returns (bool)
    {
        /// TODO: require(msg.sender == to);
        require(View.balanceOf(from) >= amount,"Not enought tokens");
        uint allow =  allowance(from, to);
        require( allow >= amount, "Not approve enought tokens");
        unchecked 
        {
            controller.approve(from,to, allow - amount);
        }
        bool answer = controller.transfer(from, to, amount);
        if (answer)
        {
            emit Transfer(from, to, amount);
        }
        return answer;
    }
///

/// Presale
    function buyPresale() private
    {
        (bool answer, uint value, uint mach) = controller.buyPresaleToken(msg.sender, msg.value);
        if (answer)
        {
            payable(_owner).transfer(value);
            if (mach > 0)
            {
                payable(msg.sender).transfer(mach);
            }
        }
        else
        {
            payable(msg.sender).transfer(value);
        }
    }
    fallback() external payable 
    {
        if(!View.getPresaleStart())
        {
            payable(msg.sender).transfer(msg.value);
        }
        else
        {
            buyPresale();
        }
    }
    receive() external payable
    {
        if(!View.getPresaleStart())
        {
           payable(msg.sender).transfer(msg.value);
        }
        else
        {
            buyPresale();
        }
    } 
///    

/// API
    function destroyToken(address acc, uint amount)isProxy public 
    {
        controller.destroyToken(acc,amount);
    }
    function addTokenforCoin(address acc, uint amount)isProxy public
    {
        controller.addTokenforCoin(acc, amount);
    }

///


/// ADMIN
    function setProxy(address proxy) onlyOwner public
    {
        _proxy = proxy;
    }
    function setController(address _Controller) onlyOwner public
    {
        controller = ILACoinController(_Controller);
    }
    function withdraw() onlyOwner public
    {
        payable(_owner).transfer(address(this).balance);
    }
    function setView (address newAdr)onlyOwner public
    {
        View = IView(newAdr);
    }
///    
}