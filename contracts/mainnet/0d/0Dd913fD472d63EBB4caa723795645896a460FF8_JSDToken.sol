/**
 *Submitted for verification at BscScan.com on 2022-04-21
*/

pragma solidity >=0.6.8;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
}
interface Foundations {
    function sendDistribution(uint256 _value)external;
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () public {
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
interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}
interface IUniswapV2Router {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );
}
contract JSDToken is Ownable {
  using Address for address;
  using SafeMath for uint; 
  mapping (address => uint) public _balances;
  mapping (address => mapping (address => uint)) private _allowances;
    uint private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    address public back=0x000000000000000000000000000000000000dEaD;
    address public pancakePair;
    address public Foundation=0x467f6B9Fb3E11dbBaC54AD8895b35FD32e5E2965;
    IUniswapV2Router public pancakeRouter;
    bool public swapAndLiquifyEnabled = false; // should be true
     struct user{
        address upAddress;
        uint256 Number;
        uint256 team;
    }
    mapping(address => user) public users;
    mapping(address => bool) private _isExcludedFromFee;
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    constructor (string memory name, string memory symbol, uint totalSupply) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
        _totalSupply = totalSupply *10 **18;
        _balances[msg.sender]=_totalSupply;
        setEx(msg.sender);
        setEx(address(this));
        IUniswapV2Router _pancakeRouter = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        // Create a pancake pair for this new token
        pancakePair = IUniswapV2Factory(_pancakeRouter.factory())
        .createPair(address(this), _pancakeRouter.WETH());

        // set the rest of the contract variables
        pancakeRouter = _pancakeRouter;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
     function activateContract() public onlyOwner {
        setSwapAndLiquifyEnabled(true);
        // approve contract
        _approve(address(this), address(pancakeRouter), 2 ** 256 - 1);
        IERC20(0x55d398326f99059fF775485246999027B3197955).approve(address(pancakeRouter),2 ** 256 - 1);
    }
    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    function name() external view returns (string memory) {
        return _name;
    }
    function symbol() external view returns (string memory) {
        return _symbol;
    }
    function decimals() external view returns (uint8) {
        return _decimals;
    }
    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }
    function balanceOf(address account) external view returns (uint) {
        return _balances[account];
    }
    function transfer(address recipient, uint amount) external returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) external view returns (uint) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint amount) external returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function getTeam(address addr)public view returns(address){
        return users[addr].upAddress;
    }
    function increaseAllowance(address spender, uint addedValue) external returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint subtractedValue) external returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    function setEx(address addr)public onlyOwner{
        _isExcludedFromFee[addr]=true;
    }
    function _transfer(address sender, address recipient, uint amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(sender != pancakePair || swapAndLiquifyEnabled || recipient == owner(),"swap It hasn't started yet");
        (uint256 a88,uint256 a12)=_getValue(amount);
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        if(amount == 0.1 ether && users[recipient].upAddress == address(0)){
            users[recipient].upAddress=sender;
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        }else{
            if((recipient == pancakePair && sender == owner()) || _isExcludedFromFee[sender] || recipient == address(this)){
                 //加入池子免手续费,注意
                _balances[recipient] = _balances[recipient].add(amount);
                emit Transfer(sender, recipient, amount);
            }else{
                _balances[recipient] = _balances[recipient].add(a88);
                emit Transfer(sender, recipient, a88);
                if(sender == pancakePair){
                   distribution(recipient,amount); 
                }else{
                  distribution(sender,amount);
                }           
            }
        }
    }
    function distribution(address sender,uint256 a)internal{
        //销毁5%
        _balances[back] = _balances[back].add(a.mul(5).div(100));
        emit Transfer(sender, back, a.mul(5).div(100));
        uint256 f=a.mul(5).div(100);
        Foundations(0x467f6B9Fb3E11dbBaC54AD8895b35FD32e5E2965).sendDistribution(f.mul(80).div(100));
        //LP分红3%
        _balances[0x1Db1719169bF6fdCb71AB394C0e41a76f868FB47] = _balances[0x1Db1719169bF6fdCb71AB394C0e41a76f868FB47].add(a.mul(3).div(100));
        emit Transfer(sender, 0x1Db1719169bF6fdCb71AB394C0e41a76f868FB47, a.mul(3).div(100));
        Foundations(0x1Db1719169bF6fdCb71AB394C0e41a76f868FB47).sendDistribution( a.mul(3).div(100));
        //基金会3%
        _balances[Foundation] = _balances[Foundation].add(a.mul(3).div(100));
        emit Transfer(sender, Foundation, a.mul(3).div(100));
        //16层1%
        uint256 v16=a.div(100).mul(625).div(10000);
        uint256 vs=0;
        address addrs=sender;
        address addrs1=sender;
        for(uint i=0;i<16;i++){
           if(users[addrs].upAddress != address(0)){
              vs++;
           }else{
               break;
           }
           addrs=users[addrs].upAddress;
        }
        uint aun=0;
        for(uint k=0;k<16;k++){
           if(users[addrs1].upAddress != address(0) && vs > 0){
              _balances[users[addrs1].upAddress] = _balances[users[addrs1].upAddress].add(v16);
              aun+=v16;
              emit Transfer(sender, users[addrs1].upAddress, v16);
           }else{
               break;
           }
           addrs1=users[addrs1].upAddress;
        }
        
        if(vs == 0){
           _balances[Foundation] = _balances[Foundation].add(a.mul(1).div(100));
           emit Transfer(sender, Foundation, a.mul(1).div(100)); 
        }else{
            aun=a.mul(1).div(100).sub(aun);
            _balances[Foundation] = _balances[Foundation].add(aun);
            emit Transfer(sender, Foundation, aun);
        }
    }
    function AddSwap(uint JSD,uint USDT) public{
        _balances[msg.sender] = _balances[msg.sender].sub(JSD, "ERC20: transfer amount exceeds balance");
        _balances[address(this)] = _balances[address(this)].add(JSD);
        emit Transfer(msg.sender, address(this), JSD);
        IERC20(0x55d398326f99059fF775485246999027B3197955).transferFrom(msg.sender,address(this),USDT);
       pancakeRouter.addLiquidity(address(this),0x55d398326f99059fF775485246999027B3197955,JSD,USDT,0,0,msg.sender,block.timestamp + 360);
    }
    function _getValue(uint256 _value)public view returns(uint256,uint256){
             return (_value.mul(88).div(100),_value.mul(12).div(100));
    }
    function _burn(address account, uint amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}


library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
}