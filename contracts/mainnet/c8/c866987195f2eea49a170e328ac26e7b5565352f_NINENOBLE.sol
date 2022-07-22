/**
 *Submitted for verification at BscScan.com on 2022-07-22
*/

/**
   # NINENOBLE
   #  features:
   0.1% - 3% Max fee send to farm pool
   0.1% - 1% Max fee send to marketing wallet
   0.1% - 1% Max fee send to Burn Address
   
 */

pragma solidity ^0.6.2;
// SPDX-License-Identifier: Unlicensed
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


/**
 * @dev Collection of functions related to the address type
 */
library Address {
    
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
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

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
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



contract NINENOBLE is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balance;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public exluded;

   
    uint256 private _rTotal = 10**16 ;
    string private _name = "Ninenoble";
    string private _symbol = "NNN";
    uint8 private  _decimals = 0;
    
    //Maximum tax 3% to farming pool reward
    uint256 public MaxTaxPerM = 30;
    uint256 public TaxPerM = 30;
    address public poolAddress = address(0);

    //Maximum tax 1% to marketing / dev address
    uint256 public MaxMarketingPerM = 10;
    uint256 public MarketingPerM = 10;
    address public marketingAddress = address(0);

    //Maximum tax 1% to Burn Address
    uint256 public MaxBurnPerM = 10;
    uint256 public BurnPerM = 10;
    address public burnAddress = address(0);

     

 
    
    constructor () public {
        _balance[address(msg.sender)] = _rTotal;
        emit Transfer(address(0), address(msg.sender), _rTotal);
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
        return _rTotal.sub(_balance[address(0)]);
    }

    function balanceOf(address account) public view override returns (uint256) {
     
        return _balance[account];
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

    
    // Update tax with maximum limit no more than 5% TAX in total
    function SetTax(uint256 pool,uint256 marketing,uint256 burn) external onlyOwner() {
        if(pool<=MaxTaxPerM &&pool>0) TaxPerM = pool;
        if(marketing<=MaxMarketingPerM &&marketing>0) MarketingPerM = marketing;
        if(burn<=MaxBurnPerM && burn>0) BurnPerM = burn;
    }

     // Update TAX address 
    function SetTaxAddress(address pool,address marketing ) external onlyOwner() {
        if(pool != address(0)) poolAddress = pool;
        if(marketing != address(0)) marketingAddress = marketing;
       
    }

     // Exlude from fee for CEX wallet
    function exludewallet(address addr) external onlyOwner() {
         exluded[addr] = true;
    }

      // Include for fee  
    function includewallet(address addr) external onlyOwner() {
         exluded[addr] = false;
    }
    
     //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

   

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
       
        
         _transferStandard(from, to, amount);

         
    }

    
    //clear token inside contract from unknow sender  
    function clear(address token) external onlyOwner{
        IERC20(token).transfer(msg.sender,IERC20(token).balanceOf(address(this)));
    }

     //clear BNB inside contract from unknow sender
     function clearBNB() external onlyOwner{
        uint256 ib = address(this).balance;
         payable(msg.sender).transfer(ib);
    }

    function _transferStandard(address sender, address recipient, uint256 _amount) private {
        _balance[sender] = _balance[sender].sub(_amount);
        uint256 netRecived = _amount;

        if(exluded[sender]||exluded[recipient]) {// No Tax for ( from or to ) exluded wallet
            _balance[recipient] = _balance[recipient].add(_amount);
        }
        else
         if(_amount<10000) { // No Tax for Send small amount
            _balance[recipient] = _balance[recipient].add(_amount);
        }
        else { // Disributed Tax to 3 wallet
         
        uint256 pool      = _amount.mul(TaxPerM).div(1000);
        uint256 marketing = _amount.mul(MarketingPerM).div(1000);
        uint256 burn      = _amount.mul(BurnPerM).div(1000);

        netRecived = _amount.sub(pool).sub(marketing).sub(burn);
        _balance[poolAddress] = _balance[poolAddress].add(pool);
        _balance[marketingAddress] = _balance[marketingAddress].add(marketing);
        _balance[burnAddress] = _balance[burnAddress].add(burn);
        _balance[recipient] = _balance[recipient].add(netRecived);
        }

        emit Transfer(sender, recipient, netRecived);
    }
 


    

}