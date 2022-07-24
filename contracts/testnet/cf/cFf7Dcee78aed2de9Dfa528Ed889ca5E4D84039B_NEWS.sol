// SPDX-License-Identifier: MIT
/*
La'eeb has been named the official mascot for this year's Fifa World Cup Qatar 2022. 
BetLaeed is the active earning project for you from now until World Cup 2022 and later. This project brings you the chance of earning from NFT collection, spin to earn, lottery to earn, advertise to earn and more income.
There are many BIG partners in the discussion about the cooperation with project team and all things will be announced soon.
*/
pragma solidity 0.8.15;
import "./Core/TokenSpecifications.sol";
import "./Core/Bep20Standard.sol";
import "./ThirdParty/IPancakeSwapRouter.sol";
import "./Core/SafeMathInt.sol";
interface IFactory{
        function createPair(address tokenA, address tokenB) external returns (address pair);
}
contract NEWS is TokenSpecifications, Bep20Standard {
  using SafeMath for uint256;
  using SafeMathInt for int256;

  mapping(address => bool) public whitelistTax;

  uint8 public buyTax;
  uint8 public sellTax; 
  uint8 public transferTax;

  uint256 private taxAmount;

  address public marketingPool;
  address public LiquidityPool2;
  address public DevPool;
  address public RewardsPool;
  bool public tradingOpen;

  uint8 public mktTaxPercent;
  uint8 public LiquidityTaxPercent;
  uint8 public DevTaxPercent;
  uint8 public RewardsPoolTaxPercent;

  //swap 
  IPancakeSwapRouter public uniswapV2Router;
  bool public enableTax;
  address public _lpAddress;
  uint256 public launchedAt;
  event changeTax(bool _enableTax, uint8 _sellTax, uint8 _buyTax, uint8 _transferTax);
  event changeTaxPercent(uint8 _mktTaxPercent,uint8 _LiquidityTaxPercent,uint8 _DevTaxPercent,uint8 _RewardsPoolTaxPercent);
  event changeWhitelistTax(address _address, bool status);  
  
  event changeMarketingPool(address marketingPool);
  event changeLiquidityPool2(address LiquidityPool2);
  event changeDevPool(address DevPool);
  event changeRewardsPool(address RewardsPool);
  event UpdateUniswapV2Router(address indexed newAddress,address indexed oldAddress);

  constructor() payable TokenSpecifications("NEWS", "NWS", 18) {
    uint256 totalTokens = 100000000 * 10**uint256(decimals());
    _mint(msg.sender, totalTokens);
    sellTax = 6;
    buyTax = 6;
    transferTax = 0;
    enableTax = true;
    tradingOpen = false;
    marketingPool   =      0x18C08F134ACe12f9378833f20aE88665752b78eb;
    LiquidityPool2  =      0x9a9B1fD2E10743E40fE5Def372bE69d5E0710aD6;
    DevPool         =      0xF5f17EFbb7BdCE5ad6593ed733E1863185F01eE5;
    RewardsPool     =      0xB2109DBb74C6962b3F75807DF9BE83dCca9C5d66;
    
    mktTaxPercent = 35;
    LiquidityTaxPercent = 15;
    DevTaxPercent = 35;
    RewardsPoolTaxPercent = 15;
    
    whitelistTax[address(this)] = true;
    whitelistTax[marketingPool] = true;
    whitelistTax[LiquidityPool2] = true;
    whitelistTax[DevPool] = true;
    whitelistTax[RewardsPool] = true;
    whitelistTax[owner()] = true;
    whitelistTax[address(0)] = true;
    

    uniswapV2Router = IPancakeSwapRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);//pancakerouter v2
    _approve(address(this), address(uniswapV2Router), ~uint256(0));

    _lpAddress = IFactory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
  }

  function setMarketingPool(address _marketingPool) external onlyOwner {
    marketingPool = _marketingPool;
    whitelistTax[marketingPool] = true;
    emit changeMarketingPool(_marketingPool);
  }  
  function setLiquidityPool2(address _LiquidityPool2) external onlyOwner {
    LiquidityPool2 = _LiquidityPool2;
    whitelistTax[LiquidityPool2] = true;
    emit changeLiquidityPool2(_LiquidityPool2);
  }  
  function setDevPool(address _DevPool) external onlyOwner {
    DevPool = _DevPool;
    whitelistTax[DevPool] = true;
    emit changeDevPool(_DevPool);
  }  
  function setRewardsPool(address _RewardsPool) external onlyOwner {
    RewardsPool = _RewardsPool;
    whitelistTax[RewardsPool] = true;
    emit changeRewardsPool(_RewardsPool);
  } 
  function updateUniswapV2Router(address newAddress) public onlyOwner {
    require(
        newAddress != address(uniswapV2Router),
        "The router already has that address"
    );
    uniswapV2Router = IPancakeSwapRouter(newAddress);
    _approve(address(this), address(uniswapV2Router), ~uint256(0));
    _lpAddress = IFactory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
    emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
  }


  function setTaxes(bool _enableTax, uint8 _sellTax, uint8 _buyTax, uint8 _transferTax) external onlyOwner {
    require(_sellTax < 9);
    require(_buyTax < 9);
    require(_transferTax < 9);
    enableTax = _enableTax;
    sellTax = _sellTax;
    buyTax = _buyTax;
    transferTax = _transferTax;
    emit changeTax(_enableTax,_sellTax,_buyTax,_transferTax);
  }

  function setTaxPercent(uint8 _mktTaxPercent, uint8 _LiquidityTaxPercent, uint8 _DevTaxPercent, uint8 _RewardsPoolTaxPercent) external onlyOwner {
    require(_mktTaxPercent +  _LiquidityTaxPercent + _DevTaxPercent + _RewardsPoolTaxPercent == 100);
    mktTaxPercent = _mktTaxPercent;
    LiquidityTaxPercent = _LiquidityTaxPercent;
    DevTaxPercent = _DevTaxPercent;
    RewardsPoolTaxPercent = _RewardsPoolTaxPercent;
    emit changeTaxPercent(_mktTaxPercent,_LiquidityTaxPercent,_DevTaxPercent,_RewardsPoolTaxPercent);
  }

  function setWhitelist(address _address, bool _status) external onlyOwner {
    whitelistTax[_address] = _status;
    emit changeWhitelistTax(_address, _status);
  }
  function getTaxes() external view returns (uint8 _sellTax, uint8 _buyTax, uint8 _transferTax) {
    return (sellTax, buyTax, transferTax);
  } 
 

  //Tranfer and tax
  function _transfer(address sender, address receiver, uint256 amount) internal virtual override {
    taxAmount = 0;
    if (amount == 0) {
        super._transfer(sender, receiver, 0);
        return;
    }
    if(enableTax && !whitelistTax[sender] && !whitelistTax[receiver]){
      require(tradingOpen, "Trading not open yet");
      if(block.number - launchedAt <= 3 ){
        //is bot
        taxAmount = (amount * 80) / 100;
      }else{
      //swap
      if(sender == _lpAddress) {
        //It's an LP Pair and it's a buy
        taxAmount = (amount * buyTax) / 100;
      } else if(receiver == _lpAddress) {      
        //It's an LP Pair and it's a sell
        taxAmount = (amount * sellTax) / 100;
      } else {
        taxAmount = (amount * transferTax) / 100;
      }
      }

      
      if(taxAmount > 0) {
        uint256 mktTax = taxAmount.div(100).mul(mktTaxPercent);
        uint256 RewardsTax = taxAmount.div(100).mul(RewardsPoolTaxPercent);
        uint256 DevTax = taxAmount.div(100).mul(DevTaxPercent);
        uint256 Pool2Tax = taxAmount - mktTax - RewardsTax - DevTax;
        if(mktTax>0){
          super._transfer(sender, marketingPool, mktTax);
        }
        if(RewardsTax>0){
          super._transfer(sender, RewardsPool, RewardsTax);
        }
        if(DevTax>0){
          super._transfer(sender, DevPool, DevTax);
        }
        if(Pool2Tax>0){
          super._transfer(sender, LiquidityPool2 , Pool2Tax);
        }
      }    
      super._transfer(sender, receiver, amount - taxAmount);
    }else{
      super._transfer(sender, receiver, amount);
    }
  }
  function launch() external onlyOwner {
    require(tradingOpen == false, "Already open ");
    launchedAt = block.number;
    tradingOpen = true;

    }

  //common
  function burn(uint256 amount) external {
    amount = amount * 10**uint256(decimals());
    _burn(msg.sender, amount);
  }


  receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity >= 0.6.2;
interface IPancakeSwapRouter {
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

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

abstract contract TokenSpecifications {
  string private _name;
  string private _symbol;
  uint8 private _decimals;
  
  constructor(
    string memory name_,
    string memory symbol_,
    uint8 decimals_
  ) {
    _name = name_;
    _symbol = symbol_;
    _decimals = decimals_;
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 * not same
 */
 library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
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

    // More check
    // int256 private constant MIN_INT256 = int256(1) << 255;
    // int256 private constant MAX_INT256 = ~(int256(1) << 255);

    // function mul(int256 a, int256 b) internal pure returns (int256) {
    //     int256 c = a * b;

    //     require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
    //     require((b == 0) || (c / b == a));
    //     return c;
    // }

    // function div(int256 a, int256 b) internal pure returns (int256) {
    //     require(b != -1 || a != MIN_INT256);

    //     return a / b;
    // }

    // function sub(int256 a, int256 b) internal pure returns (int256) {
    //     int256 c = a - b;
    //     require((b >= 0 && c <= a) || (b < 0 && c > a));
    //     return c;
    // }

    // function add(int256 a, int256 b) internal pure returns (int256) {
    //     int256 c = a + b;
    //     require((b >= 0 && c >= a) || (b < 0 && c < a));
    //     return c;
    // }

    // function abs(int256 a) internal pure returns (int256) {
    //     require(a != MIN_INT256);
    //     return a < 0 ? -a : a;
    // }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import "./Context.sol";
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 */
abstract contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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
    require(isOwner(), "Ownable: caller is not the owner");
    _;
  }

  /**
   * @dev Returns true if the caller is the current owner.
   */
  function isOwner() public view returns (bool) {
    return _msgSender() == _owner;
  }

  /**
   * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
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
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

abstract contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.

  constructor() {}

  function _msgSender() internal view returns (address payable) {
    return payable(msg.sender);
  }

  function _msgData() internal view returns (bytes memory) {
    this;
    return msg.data;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
import "./Context.sol";
import "./Bep20Interface.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract Bep20Standard is Context, Bep20Interface, Ownable {
  using SafeMath for uint256;

  mapping(address => uint256) private _balances;

  mapping(address => mapping(address => uint256)) private _allowances;

  uint256 private _totalSupply;

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

  function allowance(address owner, address spender) public view override returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) public override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) public virtual override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(
      sender,
      _msgSender(),
      _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance")
    );
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(
      _msgSender(),
      spender,
      _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero")
    );
    return true;
  }

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal virtual {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
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

  function _burnFrom(address account, uint256 amount) internal {
    _burn(account, amount);
    _approve(
      account,
      _msgSender(),
      _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance")
    );
  }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface Bep20Interface {
 
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