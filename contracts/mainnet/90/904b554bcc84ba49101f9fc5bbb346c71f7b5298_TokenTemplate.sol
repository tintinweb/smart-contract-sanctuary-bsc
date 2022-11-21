pragma solidity ^0.5.4;

import './IPancakePair.sol';
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
    string  private _name = "MAS ONE";
    string  private _symbol = "MAS ONE";
    uint8   private _decimals = 18;
    address public pancakeToken = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public usdtToken = 0x55d398326f99059fF775485246999027B3197955;
    // address public usdtToken = 0xAE8c3E15e89f58ABF20C7EEf5baF690078D06530;
    address public burnToken = 0x000000000000000000000000000000000000dEaD;
    address public pancakePair;

    uint public buy = 2; //2% 交易费买进2% 50%销毁 50%回到cale-lp产矿
    uint public sell = 2; //2% 交易费卖出2% 50%销毁 50%回到cale-lp产矿
    uint public burnXH = 9069 * 10 ** uint256(_decimals); //销毁至9999

    address public buyToken; // 交易费买进2% 50%销毁 50%接收Token
    address public sellsToken; // 交易费卖出2% 50%销毁 50%接收Token



    constructor (uint256 _initialAmount, address _buyToken, address _sellsToken) public {
        _totalSupply = _initialAmount.mul(10 ** uint256(_decimals));
        buyToken = _buyToken;
        sellsToken = _sellsToken;
        _balances[msg.sender] = _initialAmount.mul(10 ** uint256(_decimals));
        IPancakeRouter router =  IPancakeRouter(pancakeToken);
        pancakePair =  IPancakeFactory(router.factory()).createPair(address(this), usdtToken);
    }
    function setbuyToken(address account) public onlyOwner returns (bool) {
        buyToken = account;
        return true;
    }
    function setsellsToken(address account) public onlyOwner returns (bool) {
        sellsToken = account;
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
        if (from == pancakePair) {
            uint256 buyAmount = value.mul(buy).div(100);
            uint256 buyAmount2;
            if(_totalSupply>=burnXH){
                buyAmount2 = buyAmount / 2;
                _burn(from, buyAmount2);
            }else{
                buyAmount2 = buyAmount;
            }
            _balances[from] = _balances[from].sub(value);
            _balances[to] = _balances[to].add(value.sub(buyAmount));
            _balances[buyToken] = _balances[buyToken].add(buyAmount2);
            emit Transfer(from, buyToken, buyAmount2);
            emit Transfer(from, to, value.sub(buyAmount));
            
        }else if(to == pancakePair) {
            uint sellAmount2;
            uint256 sellAmount = value.mul(sell).div(100);
            if(_totalSupply>=burnXH){
                sellAmount2 = sellAmount / 2;
                _burn(from, sellAmount2);
            }else{
                sellAmount2 = sellAmount;
            }
            
            _balances[from] = _balances[from].sub(value);
            _balances[to] = _balances[to].add(value.sub(sellAmount));
            _balances[sellsToken] = _balances[sellsToken].add(sellAmount2);
            emit Transfer(from, sellsToken, sellAmount2);
            emit Transfer(from, to, value.sub(sellAmount));
            
        }else {
            _balances[from] = _balances[from].sub(value);
            _balances[to] = _balances[to].add(value);
            emit Transfer(from, to, value);
        } 
    }
    
    function _burn(address account, uint256 amount) internal {
        require(account != burnToken);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, burnToken, amount);
        require(account != burnToken);
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