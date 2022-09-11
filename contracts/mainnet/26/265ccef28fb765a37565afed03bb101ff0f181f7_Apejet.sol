/**
 *Submitted for verification at BscScan.com on 2022-09-11
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-11
*/

pragma solidity 0.5.16;

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
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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
    // Solidity only automatically asserts when dividing by 0
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

contract Apejet is Context, IBEP20, Ownable {
	using SafeMath for uint256;

	mapping (address => uint256) private _balances;
	mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;

	uint256 private _totalSupply;
	uint8 private _decimals;
	string private _symbol;
	string private _name;

	uint256 public liquidityFee = 10;
	uint256 public nftRewardFee = 0;
	uint256 public marketingFee = 20;
    uint256 private TotalFeePaid = 0;
	uint256 public totalFee = liquidityFee.add(nftRewardFee).add(marketingFee);

	address public constant DEAD = 0x000000000000000000000000000000000000dEaD;
	address public constant ZERO = 0x0000000000000000000000000000000000000000;

	address public MCFI_LiquidityFundWalletAddress;
	address public MCFI_NFTRewardFundWalletAddress;
	address public MCFI_MarketingFundWalletAddress; 
	event FeesChanged();
	
  constructor() public 
   {
        _name = 'Spicejet';
        _symbol = 'SJET';
		_decimals = 9;
        _totalSupply = 30000 * 10 ** 9;        
        _balances[msg.sender] = _totalSupply;
		MCFI_LiquidityFundWalletAddress = 0x4DB8302E51C9EE1BA3c25802360Ddd18fAcEa99F; // Account 4 mozilla
        MCFI_NFTRewardFundWalletAddress = 0x2707C91Fd67DeDed6Be623e7b68b682106670b8F; // Account 3 mozilla
        MCFI_MarketingFundWalletAddress = 0xAf207724D5068f586431Af54a56ceaF6e9F855c3; // Account 2 mozilla
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[MCFI_LiquidityFundWalletAddress]=true;
        _isExcludedFromFee[MCFI_NFTRewardFundWalletAddress] = true;
        _isExcludedFromFee[MCFI_MarketingFundWalletAddress] = true;
        emit Transfer(address(0), msg.sender, _totalSupply);
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

  function mint(uint256 amount) public onlyOwner returns (bool) {
    _mint(_msgSender(), amount);
    return true;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    require(amount > 0, "Transfer amount must be greater than zero");
    require(amount <= _balances[sender],"You are trying to transfer more than your balance");

    if (_isExcluded[sender] ) {  //from excluded
           // _balances[sender] = _balances[sender] - amount;
    }
    
    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    if (_isExcluded[recipient]) 
    { //to excluded            
            
            uint256 lfee = amount * liquidityFee / 1000;
            uint256 nftfee = amount * nftRewardFee / 1000;
            uint256 mfee = amount * marketingFee / 1000;
            uint256 tFee = amount - (lfee + nftfee + mfee);
            _balances[recipient] = _balances[recipient] + tFee;

            TotalFeePaid = TotalFeePaid + lfee + nftfee + mfee;
            _balances[MCFI_LiquidityFundWalletAddress] = _balances[MCFI_LiquidityFundWalletAddress] + lfee;
            _balances[MCFI_NFTRewardFundWalletAddress] = _balances[MCFI_NFTRewardFundWalletAddress] + nftfee;
            _balances[MCFI_MarketingFundWalletAddress] = _balances[MCFI_MarketingFundWalletAddress] + mfee;

            if(liquidityFee > 0)
            {
                emit Transfer(sender, MCFI_LiquidityFundWalletAddress, lfee);
            }

            if(nftRewardFee > 0)
            {
                emit Transfer(sender, MCFI_NFTRewardFundWalletAddress, nftfee);
            }

            if(marketingFee > 0)
            {
                emit Transfer(sender, MCFI_MarketingFundWalletAddress, mfee);
            }
    }
    else {
            _balances[recipient] = _balances[recipient].add(amount);     
    }
    
    
    emit Transfer(sender, recipient, amount);
  }

  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: mint to the zero address");

    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
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
  
  function setFeeRates(uint256 _liquidityFee, uint256 _nftRewardFee, uint256 _marketingFee) external onlyOwner {
        nftRewardFee = _nftRewardFee;
        marketingFee = _marketingFee;
        liquidityFee = _liquidityFee;
        emit FeesChanged();
    }


    function setFeeReceiversAddress(
        address _MCFI_LiquidityFundWalletAddress,
        address _MCFI_NFTRewardFundWalletAddress,
        address _MCFI_MarketingFundWalletAddress       
    ) external onlyOwner {
        MCFI_LiquidityFundWalletAddress = _MCFI_LiquidityFundWalletAddress;
        MCFI_NFTRewardFundWalletAddress = _MCFI_NFTRewardFundWalletAddress;
        MCFI_MarketingFundWalletAddress = _MCFI_MarketingFundWalletAddress;        
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }


    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }
}