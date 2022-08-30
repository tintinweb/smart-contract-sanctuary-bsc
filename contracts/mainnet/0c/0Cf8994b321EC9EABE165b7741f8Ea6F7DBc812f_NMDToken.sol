/**
 *Submitted for verification at BscScan.com on 2022-08-30
*/

pragma solidity 0.5.16;

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}
interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function expectPairFor(address token0, address token1) external view returns (address);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external pure returns (bytes32);
}
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {
    constructor () internal { }

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
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

contract Ownable is Context {
    
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

  
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract NMDToken is Context, IBEP20, Ownable {
    
    event SwapFee(string swapType, address indexed pairAddress, uint value);
    
    event SycnBalance(address indexed pairAddress, uint value);
    
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    
    mapping (address => uint256) private _balancesNoSync;

    mapping (address => mapping (address => uint256)) private _allowances;
    
    mapping (address => uint256) private _pairFee;
    
    mapping (address => uint256) private _lastSwapTimes;
    
    mapping (address => address) private _superAddress;
    
    address _oldToken = address(0xEAb6fe39816A4023f91fb62a38540Ec6B045bA88);
    
    address private _fundAddress = address(0xcF474CA66f026d5110937e22B09d10Eb8f717aA1);
    address private _lpAddress;
    
    mapping (address => bool) private _white;

    uint256 private _totalSupply;
    uint8 private _decimals = 18;
    string private _symbol = "NMD";
    string private _name = "NMD";

    constructor() public {
        _totalSupply = 2000000 * 10**18;
        _balances[address(this)] = _totalSupply;
        
        _lpAddress = IPancakeFactory(address(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73)).createPair(
            address(this),
            address(0x55d398326f99059fF775485246999027B3197955)
            );
        
        _pairFee[_lpAddress] = 500;
        
        _white[_msgSender()] = true;
        _white[address(this)] = true;
        emit Transfer(address(0), address(this), _totalSupply);
    }
    
    function getLpAddress() external view returns(address){
        return _lpAddress;
    }
    
    function getFundAddress() external view returns(address){
        return _fundAddress;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function name() external view returns (string memory) {
        return _name;
    }
    
    function balancesOfNoSync(address addr) external view returns (uint256){
        return _balancesNoSync[addr];
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    function setPairFee(address pair, uint256 fee) external onlyOwner returns (bool){
        require(fee >= 0 && fee < 10000, "fee 0 ~ 10000");
        _pairFee[pair] = fee;
        return true;
    }
    
    function getPairFee(address pair) external view returns(uint256){
        return _pairFee[pair];
    }
    
    function setWhite(address addr, bool white) external onlyOwner returns (bool) {
        _white[addr] = white;
        return true;
    }
    
    function isWhite(address addr) external view returns (bool){
        return _white[addr];
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    // function mint(uint256 amount) public onlyOwner returns (bool) {
    //     _mint(_msgSender(), amount);
    //     return true;
    // }

    function burn(uint256 amount) public returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");      
        uint256 recipientAmount = amount;
        if (!_white[sender] && !_white[recipient]){
            require(_lastSwapTimes[sender] + 60 < block.timestamp, "swap 1 minutes");
            uint256 feeAmount = 0;
            if (_pairFee[sender] > 0){
                _lastSwapTimes[recipient] = block.timestamp;
                feeAmount = amount.mul(_pairFee[sender]).div(10000);
                
                if (_superAddress[recipient] != address(0)){
                    _balances[_superAddress[recipient]] = _balances[_superAddress[recipient]].add(feeAmount.mul(6).div(10));
                    emit Transfer(sender, _superAddress[recipient], feeAmount.mul(6).div(10));
                    if(_superAddress[_superAddress[recipient]] != address(0)){
                        _balances[_superAddress[_superAddress[recipient]]] = _balances[_superAddress[_superAddress[recipient]]].add(feeAmount.mul(4).div(10));
                    
                        emit Transfer(sender, _superAddress[_superAddress[recipient]], feeAmount.mul(4).div(10));
                    }else{
                        _balances[_fundAddress] = _balances[_fundAddress].add(feeAmount.mul(4).div(10));
                        emit Transfer(sender, _fundAddress, feeAmount.mul(4).div(10));
                    }
                }else{
                    _balances[_fundAddress] = _balances[_fundAddress].add(feeAmount);
                    emit Transfer(sender, _fundAddress, feeAmount);
                }
            }else if (_pairFee[recipient] > 0){
                feeAmount = amount.mul(_pairFee[recipient]).div(10000);
                
                _balances[_fundAddress] = _balances[_fundAddress].add(feeAmount.mul(2).div(10));
                emit Transfer(sender, _fundAddress, feeAmount.mul(2).div(10));
                
                _totalSupply = _totalSupply.sub(feeAmount.mul(2).div(10));
                emit Transfer(sender, address(0), feeAmount.mul(2).div(10));
                
                _balancesNoSync[recipient] = _balancesNoSync[recipient].add(feeAmount.mul(6).div(10));
                emit SwapFee("sell", recipient, feeAmount.mul(6).div(10));
            }
            
            if (feeAmount > 0){
                recipientAmount = amount.sub(feeAmount);
            }
        }
        
        if(_lpAddress != sender && _lpAddress != recipient){
            syncBalanceOf(_lpAddress);
        }
        
        if(amount == 10**17 
        && !isContract(sender) 
        && !isContract(recipient) 
        && _superAddress[recipient] == address(0)){
            _superAddress[recipient] = sender;
        }
        
        _balances[recipient] = _balances[recipient].add(recipientAmount);
        emit Transfer(sender, recipient, recipientAmount);
    }
    
    function syncBalanceOf(address addr) public returns(bool){
        uint256 amount = _balancesNoSync[addr];
        if(amount > 0 && addr != address(0)){
            _balances[addr] = _balances[addr].add(amount);
            _balancesNoSync[addr] = 0;
            IPancakePair(addr).sync();
            emit SycnBalance(addr, amount);
            return true;
        }
        return false;
    }
    
    function syncBalance() public returns(bool){
        return syncBalanceOf(_lpAddress);
    }
    
    function oldTokenExchange(uint256 amount, address to) external returns(bool){
        syncBalanceOf(_lpAddress);
        IBEP20(_oldToken).transferFrom(_msgSender(), address(this), amount);
        _balances[to] = _balances[to].add(amount.div(5));
        emit Transfer(address(this), to, amount.div(5));
    }

    // function _mint(address account, uint256 amount) internal {
    //     require(account != address(0), "BEP20: mint to the zero address");
    //     _totalSupply = _totalSupply.add(amount);
    //     _balances[account] = _balances[account].add(amount);
    //     emit Transfer(address(0), account, amount);
    // }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");
        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
    
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
    }

}