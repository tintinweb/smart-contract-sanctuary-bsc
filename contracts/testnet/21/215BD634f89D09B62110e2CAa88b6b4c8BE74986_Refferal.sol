/**
 *Submitted for verification at BscScan.com on 2022-06-01
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.9;
 
interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
   function _msgSender() internal view virtual returns (address) {
       return msg.sender;
   }

   function _msgData() internal view virtual returns (bytes calldata) {
       this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
       return msg.data;
   }
}

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

   event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
   
   /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
   constructor () {
       address msgSender = _msgSender();
       _owner = msgSender;
       emit OwnershipTransferred(address(0), msgSender);
   }

   /**
    * @dev Returns the address of the current owner.
    */
   function owner() public view returns (address) {
       return _owner;
   }

   /**
    * @dev Throws if called by any account other than the owner.
    */
   modifier onlyOwner() {
       require(_owner == _msgSender(), "Ownable: caller is not the owner");
       _;
   }

   /**
    * @dev Leaves the contract without owner. It will not be possible to call
    * `onlyOwner` functions anymore. Can only be called by the current owner.
    *
    * NOTE: Renouncing ownership will leave the contract without an owner,
    * thereby removing any functionality that is only available to the owner.
    */
   function renounceOwnership() public virtual onlyOwner {
       emit OwnershipTransferred(_owner, address(0));
       _owner = address(0);
   }

   /**
    * @dev Transfers ownership of the contract to a new account (`newOwner`).
    * Can only be called by the current owner.
    */
   function transferOwnership(address newOwner) public virtual onlyOwner {
       require(newOwner != address(0), "Ownable: new owner is the zero address");
       emit OwnershipTransferred(_owner, newOwner);
       _owner = newOwner;
   }
}

contract Refferal is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    string private _name = "Refferal";
    string private _symbol = "RF";
    uint8 private _decimals = 18;
    uint256 private _tTotal = 10 ** 5 * 275 * 10 ** _decimals; //27,500,000

    uint public _founderFee = 6;
    uint public _marketingFee = 6;
    uint public _devFee = 6;
    uint public _advisorFee = 2; //advisors/partners    
    uint256 private constant MAX = ~uint256(0);

    address public _ownerAddress = 0x113EDED148717B21140ed7E1A92D2A677B241D34;
    address public _founderAddress = 0x113EDED148717B21140ed7E1A92D2A677B241D34;
    address public _marketingAddress = 0x113EDED148717B21140ed7E1A92D2A677B241D34;
    address[] public _devAddress;
    address[] public _advisorAddress;

    IERC20 public WETH;
    address public constant _deadAdderess = address(0xdead);

    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances; 
    mapping (address => uint256) public transactionTime;
    mapping (address => bool) public blacklist;
    mapping (address => bool) private _isExcludedFromFee;


    event ExcludeFromFee(address account);
    event IncludeInFee(address account);
    event Fee(uint founderFee, uint marketingFee, uint devFee, uint advisorFee);
    event FounderAddressUpdate(address founderAddress);
    event MarketingAddressUpdate(address marketingAddress);
    event DevAddressUpdate(address devAddress, bool flag);
    event AdvisorAddressUpdate(address advisorAddress, bool flag);

    constructor() {
        _tOwned[_ownerAddress] = _tTotal;

        _isExcludedFromFee[_ownerAddress] = true;
        _isExcludedFromFee[address(this)] = true;

        _devAddress.push(0x113EDED148717B21140ed7E1A92D2A677B241D34);
        _advisorAddress.push(0x113EDED148717B21140ed7E1A92D2A677B241D34);
        
        emit Transfer(address(0), _ownerAddress, _tTotal);
    }

    // ERC-20 standard functions

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
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
       return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
       require(owner != address(0), "ERC20: approve from the zero address");
       require(spender != address(0), "ERC20: approve to the zero address");

       _allowances[owner][spender] = amount;
       emit Approval(owner, spender, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function burn(uint256 tBurn) external {

       address sender = _msgSender();
       require(sender != address(0), "ERC20: burn from the zero address");
       require(sender != address(_deadAdderess), "ERC20: burn from the burn address");

       uint256 balance = balanceOf(sender);
       require(balance >= tBurn, "ERC20: burn amount exceeds balance");

       _tOwned[sender] = _tOwned[sender].sub(tBurn);

       _burnTokens( sender, tBurn);
    }

    function _burnTokens(address sender, uint256 tBurn) internal {

       _tOwned[_deadAdderess] = _tOwned[_deadAdderess].add(tBurn);

       emit Transfer(sender, _deadAdderess, tBurn);
    }

    function _transfer(
       address from,
       address to,
       uint256 amount
    ) internal {
       require(from != address(0), "ERC20: transfer from the zero address");
       require(to != address(0), "ERC20: transfer to the zero address");
       require(amount > 0, "Transfer amount must be greater than zero");
       
       bool takeFee = true;
       
       if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
           takeFee = false;
       }
       _tokenTransfer(from,to,amount,takeFee);
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) internal {
       uint _totalFee = 0;
       _tOwned[sender] = _tOwned[sender].sub(amount);       
       if(takeFee) {
           if(_founderFee > 0)
               _tOwned[_founderAddress] += amount.mul(_founderFee).div(100);    
           if(_marketingFee > 0)
               _tOwned[_marketingAddress] += amount.mul(_marketingFee).div(100);
           if(_devFee > 0) {
               uint _devFeeAmount = amount.mul(_devFee).div(100);
               for(uint i = 0; i < _devAddress.length; i ++) {
                   _tOwned[_devAddress[i]] += _devFeeAmount.div(_devAddress.length);
               }
           }      
           if(_advisorFee > 0) {
               uint _advisorFeeAmount = amount.mul(_advisorFee).div(100);
               for(uint i = 0; i < _advisorAddress.length; i ++) {
                   _tOwned[_advisorAddress[i]] += _advisorFeeAmount.div(_advisorAddress.length);
               }
           }
           _totalFee = _founderFee.add(_marketingFee).add(_devFee).add(_advisorFee);
       }

       uint256 tTransferAmount = amount.mul(100 - _totalFee).div(100);
       _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        emit Transfer(sender, recipient, tTransferAmount);   
    }

    function airdrop(address recipient, uint256 amount) external onlyOwner() {
       _transfer(_msgSender(), recipient, amount * 10**18);
    }
   
    function airdropInternal(address recipient, uint256 amount) internal {
       _transfer(_msgSender(), recipient, amount);
    }
   
    function airdropArray(address[] calldata newholders, uint256[] calldata amounts) external onlyOwner(){
       uint256 iterator = 0;
       require(newholders.length == amounts.length, "must be the same length");
       while(iterator < newholders.length){
           airdropInternal(newholders[iterator], amounts[iterator] * 10**18);
           iterator += 1;
       }
    }

    function isExcludedFromFee(address account) public view returns(bool) {
       return _isExcludedFromFee[account];
    }

    // Write functions
    
    function excludeFromFee(address account) public onlyOwner() {
        _isExcludedFromFee[account] = true;

        emit ExcludeFromFee(account);
    }
    
    function includeInFee(address account) public onlyOwner() {
        _isExcludedFromFee[account] = false;

        emit IncludeInFee(account);
    }
    
    function setFee(uint founderFee, uint marketingFee, uint devFee, uint advisorFee) external onlyOwner() {
        uint256 totalFee = founderFee.add(marketingFee).add(devFee).add(advisorFee);
        require(totalFee <= 50, "Total fee should not be bigger than 50");
        _founderFee = founderFee;
        _marketingFee = marketingFee;
        _devFee = devFee;
        _advisorFee = advisorFee;

        emit Fee(founderFee, marketingFee, devFee, advisorFee);
    }

    function setFounderAddress(address founderAddress) external onlyOwner() {
       _founderAddress = founderAddress;

       emit FounderAddressUpdate(founderAddress);
    }

    function setMarketingAddress(address marketingAddress) external onlyOwner() {
       _marketingAddress = marketingAddress;

       emit MarketingAddressUpdate(marketingAddress);
    }

    function pushDevAddress(address devAddress) external onlyOwner() {
        require(getIndexFromArray(_devAddress, devAddress) == MAX, "Address already exist.");
        _devAddress.push(devAddress);

        emit DevAddressUpdate(devAddress, true);
    }

    function popDevAddress(address devAddress) external onlyOwner() {
        uint index = getIndexFromArray(_devAddress, devAddress);
        require(index != MAX, "Address doesn't exist.");
        _devAddress[index] = _devAddress[_devAddress.length - 1];
        _devAddress.pop();

        emit DevAddressUpdate(devAddress, false);
    }

    function pushAdvisorAddress(address advisorAddress) external onlyOwner() {
        require(getIndexFromArray(_advisorAddress, advisorAddress) == MAX, "Address already exist.");
        _advisorAddress.push(advisorAddress);

        emit AdvisorAddressUpdate(advisorAddress, true);
    }

    function popAdvisorAddress(address advisorAddress) external onlyOwner() {
        uint index = getIndexFromArray(_advisorAddress, advisorAddress);
        require(index != MAX, "Address doesn't exist.");
        _advisorAddress[index] = _advisorAddress[_advisorAddress.length - 1];
        _advisorAddress.pop();

        emit AdvisorAddressUpdate(advisorAddress, false);
    }

    function getIndexFromArray(address[] storage data, address findAddress) internal view returns (uint) {
        uint index = MAX;
        for(uint8 i = 0; i < data.length; i ++) {
            if(data[i] == findAddress)
                index = i;
        }
        return index;
    }

    receive() external payable {}
}