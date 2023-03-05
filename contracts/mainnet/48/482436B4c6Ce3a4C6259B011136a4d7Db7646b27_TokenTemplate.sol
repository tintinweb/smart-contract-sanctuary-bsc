pragma solidity ^0.5.4;

import './IPancakeRouter.sol';
import './SafeMath.sol';
import './IERC20.sol';
import './IPancakeFactory.sol';


contract ERC20 is IERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) public _balances;
    mapping (address => mapping (address => uint256)) public _allowed;
    uint256 public _totalSupply;

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    function allowance(address owner,address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function increaseAllowance(address spender,uint256 addedValue) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].add(addedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender,uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].sub(subtractedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));
        require(value <= _balances[from]);
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }
}

contract Context {
    constructor () internal { }

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
contract Ownable is Context {
    address private _owner;

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
    function owner() public view  returns (address) {
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
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    
}


contract TokenTemplate is ERC20,Ownable {
    string  private _name = "Mas pro";
    string  private _symbol = "Mas pro";
    uint8   private _decimals = 18;
    address public pancakeToken = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public usdtToken = 0x55d398326f99059fF775485246999027B3197955;
    address public pancakePair;

    uint public fee1 = 7; //1%（买入销毁）
    uint public fee11 = 7; //1%（卖出销毁）
    uint public fee2 = 23; //2%（买入余额变动分红）
    uint public fee22 = 23; //2%（卖出余额变动分红）
    uint public fee10 = 100; //10%（转账销毁）

    address public feetoken;  //接收2% token
    mapping (address => bool) private contracts;//合约 token



    constructor (uint256 _initialAmount,address _feetoken) public {
        _totalSupply = _initialAmount.mul(10 ** uint256(_decimals));
        feetoken = _feetoken;
        _balances[msg.sender] = _initialAmount.mul(10 ** uint256(_decimals));
        IPancakeRouter router =  IPancakeRouter(pancakeToken);
        pancakePair =  IPancakeFactory(router.factory()).createPair(address(this), usdtToken);
    }
    function setcontracts(address account, bool state) public onlyOwner returns (bool) {
        contracts[account] = state;
        return true;
    }
    function setfee(uint256 mairuXH, uint256 maichuXH, uint256 mairuFH, uint256 maichuFH) public onlyOwner returns (bool) {
        fee1 = mairuXH;
        fee11 = maichuXH;
        fee2 = mairuFH;
        fee22 = maichuFH;
        return true;
    }
    function setfeetoken(address account) public onlyOwner returns (bool) {
        feetoken = account;
        return true;
    }
    
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(value <= _allowed[from][msg.sender]);
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }

     function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));
        require(value <= _balances[from]);

        uint256 feeAmount1 = value.mul(fee1).div(1000);//买入交易销毁
        uint256 feeAmount11 = value.mul(fee11).div(1000);//卖出交易销毁
        uint256 feeAmount2 = value.mul(fee2).div(1000);//买入分红
        uint256 feeAmount22 = value.mul(fee22).div(1000);//卖出分红
        uint256 feeAmount10 = value.mul(fee10).div(1000);//转账销毁
        if(contracts[from]==true || contracts[to]==true){
            //白名单
            _kein(from, to, value);
        }else{
            if (from == pancakePair) {
                _balances[from] = _balances[from].sub(value);
                _balances[to] = _balances[to].add(value.sub(feeAmount1 + feeAmount2));
                _balances[feetoken] = _balances[feetoken].add(feeAmount2);
                _burn(from, feeAmount1);

                emit Transfer(from, feetoken, feeAmount2);
                emit Transfer(from, to, value.sub(feeAmount1 + feeAmount2));
            } else if(to == pancakePair) {
                _balances[from] = _balances[from].sub(value + feeAmount11 + feeAmount22);
                _balances[to] = _balances[to].add(value.sub(feeAmount11 + feeAmount22));
                _balances[feetoken] = _balances[feetoken].add(feeAmount22);
                _burn(from, feeAmount11);

                emit Transfer(from, feetoken, feeAmount22);
                emit Transfer(from, to, value.sub(feeAmount11 + feeAmount22));
            }else {
                _balances[from] = _balances[from].sub(value);
                _balances[to] = _balances[to].add(value.sub(feeAmount10));
                _burn(from, feeAmount10);
                emit Transfer(from, to, value.sub(feeAmount10));
            }
        }
        
    }
    function _kein(address from, address to, uint256 value) internal {
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }
    function _burn(address account, uint256 amount) internal {
        require(account != address(0));
        // _balances[account] = _balances[account].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
        require(account != address(0));
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

}