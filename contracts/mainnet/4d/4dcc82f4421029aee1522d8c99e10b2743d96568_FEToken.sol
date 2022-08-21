/**
 *Submitted for verification at BscScan.com on 2022-08-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-17
*/

// File: contracts\Owner.sol

pragma solidity ^0.8.0;


contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }
}

// File: contracts\testHB.sol

pragma solidity >0.6.6;
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

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function decimals()  view external returns (uint8);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IPool{

    function getUser(address a) external view returns(bool partake,uint256 levelNumber);
    function getMonthInviter(address a) external view   returns (uint256 number,uint256 pow,uint256 finalPow);
    function getFeeAddress () external view returns (address);
}

abstract contract Context {

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract FEToken is Context, IERC20,Ownable {
    using SafeMath for uint256;

    address pool=0x26F629cabB2Ae4986152A2E561069c5F9224dB13;

    struct UserInfo {
        uint256 dtAmount;
        uint256 lastTime;
    }
    address public uniswapV2Pair;
    uint256 public DayTnumber =300;
    mapping(address => bool) private _isFee;
    mapping(address => bool) private _isFeen;
    mapping(address => UserInfo) user;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;



    constructor () public {
        _name = "Fetest1 token";
        _symbol = "Fetest1";
        _decimals = 3;
        _mint(msg.sender, 2600000 * 10 ** uint(decimals()));
        _isFee[msg.sender] = true;
    }

    function setPool(address pool_) public onlyOwner {
        pool = pool_;
    }


    function name() public view returns (string memory) {
        return _name;
    }


    function symbol() public view returns (string memory) {
        return _symbol;
    }


    function decimals() public override view returns (uint8) {
        return _decimals;
    }


    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }


    function balanceOf(address account) public view override returns (uint256) {
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


    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
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

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_isFeen[sender] !=true, "ERC20:  address lock");
        _beforeTokenTransfer(sender, recipient, amount);

        if (_isFee[sender]) {
            _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
            return;
        }
        if(recipient == uniswapV2Pair)
        {
            UserInfo storage user = user[msg.sender];
            if(user.lastTime > block.timestamp)
            {
                uint256 damount = user.dtAmount+amount;
                require(damount<=DayTnumber, "ERC20:  24 hours max limit");
                user.dtAmount = user.dtAmount.add(amount);
            }
            else
            {
                require(amount<=DayTnumber, "ERC20:  24 hours max limit");
                uint256 dayTimestamp = 24* 60 * 60;
                uint256 nextTimestamp = user.lastTime + dayTimestamp;
                user.dtAmount = amount;
                user.lastTime=nextTimestamp;
            }
        }
        if(sender == uniswapV2Pair||recipient == uniswapV2Pair){
                uint256 fee = amount.mul(10).div(100);
                _balances[sender] = _balances[sender].sub(fee, "ERC20: transfer amount exceeds balance");
                _balances[uniswapV2Pair] = _balances[uniswapV2Pair].add(fee);
                amount = amount.sub(fee);
                emit Transfer(sender, uniswapV2Pair, fee);

                _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
                _balances[recipient] = _balances[recipient].add(amount);
                emit Transfer(sender, recipient, amount);
                return;
        }

        address feeAddress = IPool(pool).getFeeAddress();
        (bool partake,uint256 levelNumber) = IPool(pool).getUser(sender);
        if(partake && levelNumber > 0 && feeAddress !=address(0) && recipient != address(1)){
            if(levelNumber == 0){
                uint256 feeRate = 6;
                uint256 fee = amount.mul(feeRate).div(100);
                _balances[sender] = _balances[sender].sub(fee, "ERC20: transfer amount exceeds balance");
                _balances[feeAddress] = _balances[feeAddress].add(fee);
                amount = amount.sub(fee);
                emit Transfer(sender, feeAddress, fee);

                _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
                _balances[recipient] = _balances[recipient].add(amount);
                emit Transfer(sender, recipient, amount);
            }
            else if(levelNumber == 1){
                uint256 fee = amount;
                _balances[sender] = _balances[sender].sub(fee, "ERC20: transfer amount exceeds balance");
                _balances[feeAddress] = _balances[feeAddress].add(fee);
                emit Transfer(sender, feeAddress, fee);
            }else {
                (,,uint256 pow) = IPool(pool).getMonthInviter(sender);
                uint256 feeRate = 15;
                uint256 fee = amount.mul(feeRate).div(100);
                _balances[sender] = _balances[sender].sub(fee, "ERC20: transfer amount exceeds balance");
                _balances[feeAddress] = _balances[feeAddress].add(fee);
                amount = amount.sub(fee);
                emit Transfer(sender, feeAddress, fee);

                _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
                _balances[recipient] = _balances[recipient].add(amount);
                emit Transfer(sender, recipient, amount);
            }
        }
        

        
    }


    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }


    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

    function mint(address dst, uint256 amt) public returns (bool) {
        require(msg.sender == pool);
        _mint(dst, amt);
        return true;

    }

    function changeRouter(address router) public onlyOwner {
        uniswapV2Pair = router;
    }
    function changeDayTnumber(uint256 amount) public onlyOwner {
        DayTnumber = amount;
    }
    function includeFee(address account) public onlyOwner {
        _isFee[account] = true;
    }
    function excludeFee(address account) public onlyOwner {
        _isFee[account] = false;
    }
    function includeFeen(address account) public onlyOwner {
        _isFeen[account] = true;
    }
    function excludeFeen(address account) public onlyOwner {
        _isFeen[account] = false;
    }
}