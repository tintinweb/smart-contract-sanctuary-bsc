/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {

  function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
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

interface ITRC20 {
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function decimals() external view returns (uint8);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
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
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0, "SafeMath: division by zero");
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "SafeMath: subtraction overflow");
    uint256 c = a - b;
    return c;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");
    return c;
  }
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0, "SafeMath: modulo by zero");
    return a % b;
  }

}

contract AiniToken is Context, ITRC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    
    mapping (address => uint256) private _balances;
    
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 public deflationTotalAmount;
    uint256 public deflationAmount;
    address public _fundAddress;
    address public _bonusAddress;
    address public _burnAddress;


    Liquidity[] private LiquidityList;
    struct Liquidity {
        bool flag; 
        address user;
        uint256 lpAmount;
        uint256 lastTime; 
        uint256 index;
    }
    mapping(address => Liquidity) private LiquidityOrder;
    
    address public lpPoolAddress;
   
    uint256 public lpFeeAmount=0;


    uint256 public lpTotalAmount=0;
    
    string private _name = 'AI';
    string private _symbol = 'AINI TOKEN';
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 9434 * 10**uint256(_decimals);

    FeeConfig public feeConfig;

    struct FeeConfig {
        uint256 _bonusFee;
        uint256 _leaveFee;
        uint256 _fundFee;
        uint256 _deflationFee;
    }
    mapping(address => bool) private _isExcludedFee;

    constructor ()  {
        _isExcludedFee[owner()] = true;
        _isExcludedFee[address(this)] = true;
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }
        
    function name() public view virtual override returns (string memory) {
        return _name;
    }


    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

 
    function decimals() public  view virtual override returns (uint8) {
        return _decimals;
    }


    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

  
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

  
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance.sub(amount));

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(msg.sender, spender, currentAllowance - subtractedValue);
        return true;
    }

    function excludeFee(address account) public onlyOwner {
        _isExcludedFee[account] = true;
    }
    function setExchangePool(address _lpPoolAddress) public onlyOwner {
        lpPoolAddress = _lpPoolAddress;
    }    
    function setLpFeeAmount(uint256 _amount) public onlyOwner   {
        lpFeeAmount=_amount;
    }
    function setLpTotalAmount(uint256 _amount)public onlyOwner  {
         lpTotalAmount=_amount;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        bool takeFee = false;
        if(lpPoolAddress==recipient||lpPoolAddress==sender){
            if(lpPoolAddress==recipient){
                uint256 lpToken= ITRC20(lpPoolAddress).balanceOf(sender);
                bool flag=false;
                if (LiquidityOrder[sender].flag == false) {
                    if(lpToken>0){
                      Liquidity memory liquidity = Liquidity(true,sender,lpToken,block.timestamp,LiquidityList.length);
                        LiquidityOrder[sender] = liquidity;
                        LiquidityList.push(liquidity);
                        flag=true;
                    }
                } else {
                    Liquidity storage order = LiquidityOrder[sender];
                    if(order.lpAmount<lpToken){
                        lpToken=SafeMath.sub(lpToken, order.lpAmount);
                        order.lpAmount = SafeMath.add(order.lpAmount, lpToken);
                        order.lastTime=block.timestamp;
                        flag=true;
                        LiquidityList[order.index]=order;
                    }
                }
                if(flag){
                    lpTotalAmount=lpTotalAmount.add(lpToken);
                }else{
                  takeFee = true;
                }
            }
            if(lpPoolAddress==sender){
                uint256 lpToken= ITRC20(lpPoolAddress).balanceOf(recipient);
                if (LiquidityOrder[recipient].flag == true) {
                    Liquidity storage order = LiquidityOrder[recipient];
                    if(order.lpAmount>lpToken){
                        uint256 removeToken=SafeMath.sub(order.lpAmount,lpToken);
                        order.lpAmount = SafeMath.sub(order.lpAmount, removeToken);
                        if(order.lpAmount==0){
                            order.flag=false;
                        }
                        lpTotalAmount=lpTotalAmount.sub(removeToken);
                        LiquidityList[order.index]=order;
                    }
                }
            }
        }else{
            takeFee=true;
        }
        _tokenTransfer( sender,  recipient,  amount, takeFee);
    }

    function getValue(uint256 lpAmount,uint256 _lpFeeAmount) public view virtual  returns (uint256){
         uint256 rate=lpAmount.mul(10**8).div(lpTotalAmount);        
        return _lpFeeAmount.mul(rate).div(10**8);
    }

    function takeLiquidity() public onlyOwner {
        Liquidity[] memory  orders=  LiquidityList;
        uint256 _lpFeeAmount=lpFeeAmount;
        if(orders.length>0&&_balances[address(_bonusAddress)]>=_lpFeeAmount){
            for(uint256 i=0; i<orders.length;i++){
              Liquidity  memory l =  orders[i];
              if(l.flag){
                uint256  awardAmount =  getValue(l.lpAmount,_lpFeeAmount);
                    if(awardAmount>0){
                        lpFeeAmount=lpFeeAmount.sub(awardAmount);
                        _balances[address(_bonusAddress)] = _balances[address(_bonusAddress)].sub(awardAmount);
                        _balances[l.user] = _balances[l.user].add(awardAmount);
                        emit Transfer(address(_bonusAddress), l.user, awardAmount);
                    }
                }
            }
        }
    }
     function _tokenTransfer(address sender, address recipient, uint256 _amount,bool takeFee) private {
         uint256 realSenderAmount=_amount;
         uint256 realRecipientAmount=_amount;
        if(takeFee) {
            (uint256 bonusFee,uint256 leaveFee,uint256 fundFee,uint256 deflationFee) = _getValues(_amount);
            if(sender!=lpPoolAddress){
                if(!_isExcludedFee[sender]){
                    if(deflationTotalAmount<deflationAmount+deflationFee){
                        deflationFee=   deflationTotalAmount-deflationAmount;
                    }
                    if(deflationFee>0){
                     realRecipientAmount=realRecipientAmount-deflationFee;
                        deflationAmount=deflationAmount+deflationFee;
                        _balances[address(_burnAddress)] = _balances[address(_burnAddress)].add(deflationFee);
                        emit Transfer(sender, address(_burnAddress), deflationFee);
                    }
                }
            }
            if(lpPoolAddress==recipient){
                if(fundFee>0){
                    realRecipientAmount=realRecipientAmount-fundFee;
                     _balances[address(_fundAddress)] = _balances[address(_fundAddress)].add(fundFee);
                    emit Transfer(sender, address(_fundAddress), fundFee);
                }
                if(bonusFee>0){
                    lpFeeAmount = lpFeeAmount.add(bonusFee);
                    realRecipientAmount=realRecipientAmount-bonusFee;
                     _balances[address(_bonusAddress)] = _balances[address(_bonusAddress)].add(bonusFee);
                    emit Transfer(sender, address(_bonusAddress), bonusFee);
                }
                if(leaveFee>0){
                     realRecipientAmount=realRecipientAmount-leaveFee;
                    realSenderAmount=realSenderAmount-leaveFee;
                }
            }
        }
        _balances[sender] = _balances[sender].sub(realSenderAmount);
        _balances[recipient] = _balances[recipient].add(realRecipientAmount);
        emit Transfer(sender, recipient, realRecipientAmount);
    }
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _getValues(uint256 _amount) private view returns (uint256,uint256,uint256,uint256) {
        uint256 bonusFee =  _amount.mul(feeConfig._bonusFee).div(10 ** 3);
        uint256 leaveFee =  _amount.mul(feeConfig._leaveFee).div(10 ** 3);
        uint256 fundFee =  _amount.mul(feeConfig._fundFee).div(10 ** 3);
        uint256 deflationFee =  _amount.mul(feeConfig._deflationFee).div(10 ** 3);
        return ( bonusFee,leaveFee,fundFee,deflationFee);
    }
    
    function getLiquidityList(uint256 _index) external view returns(Liquidity memory ) {
         return  LiquidityList[_index];
    }
    function getLiquidityOrder(address _account) external view returns(Liquidity memory ) {
         return  LiquidityOrder[_account];
    }
    function getLpList(uint256 _index) external view returns(
        bool,
        address ,
        uint256 ,
        uint256 , 
        uint256 ) {
         return  (LiquidityList[_index].flag,
         LiquidityList[_index].user,
         LiquidityList[_index].lpAmount,
         LiquidityList[_index].lastTime,
         LiquidityList[_index].index
         );
    }
    function getLpOrder(address _account) external view returns(
        bool,
        address ,
        uint256 ,
        uint256 , 
        uint256 ) {
         return  (LiquidityOrder[_account].flag,
         LiquidityOrder[_account].user,
         LiquidityOrder[_account].lpAmount,
         LiquidityOrder[_account].lastTime,
         LiquidityOrder[_account].index
         );
    }
     function setFeeConfig(uint256 bonusFee,uint256 leaveFee,uint256 fundFee,uint256 deflationFee) public onlyOwner {
         feeConfig=FeeConfig( bonusFee, leaveFee, fundFee, deflationFee);
    }

    function setBurnAddress(address account) public onlyOwner {
        _burnAddress = account;
    }
    function setDeflationTotalAmount(uint256 amount) public onlyOwner {
        deflationTotalAmount = amount;
    }

    function setDeflationAmount(uint256 amount) public onlyOwner {
        deflationAmount = amount;
    }

    function setBonusAddress(address account) public onlyOwner {
        _bonusAddress = account;
    }
    function setFundAddress(address account) public onlyOwner {
        _fundAddress = account;
    }

}