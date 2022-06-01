// SPDX-License-Identifier: MIT
/*

~𝕃𝕠𝕔𝕜𝕖𝕕 𝕄𝕠𝕟𝕤𝕥𝕖𝕣 v2~ 

 https://locked.monster

 507,333.0% APY Yield without The Big Dumps
 New anti-dump system v2.0. The Balancer strategy

*/

pragma solidity 0.8.14;
import "./ERC20.sol";
import "./IPancakeRouter02.sol";
import "./IUniswapV2Factory.sol";

contract LockedMonsterV2 is ERC20 {

  IPancakeRouter02 router;
  address public owner;
  address public pair;

  uint public rewardYield = 507334000;
  uint public token_rebase_block = block.number;
  uint public rebase_interval = 10;

  uint private rewardYieldDenominator = 10000000000;

  uint256 private constant MAX_UINT256 = ~uint256(0);
  uint256 private INITIAL_FRAGMENTS_SUPPLY;
  uint256 private TOTAL_GONS;
  uint256 private constant MAX_SUPPLY = ~uint128(0);  // (2^128) - 1


  constructor(
      address _router,
      string memory name_,
      string memory symbol_,
      uint count_,
      uint tax_,
      address tax_recipient_,
      uint burn_fee_
  ) ERC20(name_, symbol_, tax_, tax_recipient_, burn_fee_) payable {
      owner = msg.sender;
      _mint(msg.sender, count_ * 10 ** 18);
      
      router = IPancakeRouter02(_router);
      pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());

      INITIAL_FRAGMENTS_SUPPLY = _totalSupply;
      TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);
      _balances[owner] = TOTAL_GONS;
      _gonsPerFragment = TOTAL_GONS /_totalSupply;
  }


  function setTransferTax (uint tax) public {
      require(msg.sender == owner, "You are not an owner");
      require(tax <= 10, "Tax is too high");
      _tax = tax;

      emit TransferTax(tax);
  }

  function setBurnFee (uint burn_fee_) public {
      require(msg.sender == owner, "You are not an owner");
      require(burn_fee_ <= 10, "Burn is too high");
      _burn_fee = burn_fee_;

      emit BurnFee(burn_fee_);
  }
  
  function setTaxRecipient (address recipient) public {
      require(msg.sender == owner, "You are not an owner");

      _tax_recipient = recipient;
      emit TaxRecipient(recipient);
  }

  function setRebaseInterval (uint _interval) public {
      require(msg.sender == owner, "You are not an owner");
      rebase_interval = _interval;
      emit SetRebaseInterval(_interval);
  }

  function setRewardYield (uint _reward) public {
      require(msg.sender == owner, "You are not an owner");
      rewardYield = _reward;
      emit SetRewardYield(_reward);
  }

  function rebase() public returns(uint) {
       uint reward = (_totalSupply * rewardYield) / rewardYieldDenominator;
       
       require((block.number - token_rebase_block) >= rebase_interval, "Rebase is not ready");
       require((_totalSupply + reward) <= MAX_SUPPLY, "Rebase limit");

       _totalSupply += reward;
       token_rebase_block = block.number;

       _gonsPerFragment = TOTAL_GONS / _totalSupply;

       emit LogRebase(token_rebase_block, _totalSupply);
       return _totalSupply;
  }

  event SetRewardYield(uint _reward);
  event SetRebaseInterval(uint _interval);
  event TransferTax(uint tax);
  event BurnFee(uint burn_fee_);
  event TaxRecipient(address _tax_recipient);
  event LogRebase(uint token_rebase_block, uint _totalSupply);

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;
import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./Context.sol";

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 public _totalSupply;
    uint256 internal _gonsPerFragment;
    string private _name;
    string private _symbol;
    uint public _tax;
    uint public _burn_fee;
    address public _tax_recipient;

    constructor(string memory name_, string memory symbol_, uint tax_, address tax_recipient_, uint burn_fee_) {
        _name = name_;
        _symbol = symbol_;
        _tax = tax_;
        _tax_recipient = tax_recipient_;
        _burn_fee = burn_fee_;
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

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account] / _gonsPerFragment;
    }
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

     
        uint256 __amount = amount * _gonsPerFragment;
        uint256 tax = __amount * _tax / 100;
        uint _burn_amount = __amount * _burn_fee / 100;

        _beforeTokenTransfer(from, to, amount);

        require(_balances[from] >= __amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] -= __amount;
        }

        _balances[to] += (__amount - tax - _burn_amount);
  

        emit Transfer(from, to, amount);
        
        _afterTokenTransfer(from, to, amount);


        if(tax > 0) {
          _balances[_tax_recipient] += tax;
           emit Transfer(from, _tax_recipient, tax / _gonsPerFragment);
        }

        if(_burn_amount > 0) {
          _burn(from, _burn_amount);
        }
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }


    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount / _gonsPerFragment);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount / _gonsPerFragment;

        emit Transfer(account, address(0), amount / _gonsPerFragment);
        emit Burn(account, address(0), amount / _gonsPerFragment);
        
        
        _afterTokenTransfer(account, address(0), amount * _gonsPerFragment);
    }


    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    event Burn(address account, address _address, uint amount);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

import "./IPancakeRouter01.sol";

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./IERC20.sol";

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)
pragma solidity ^0.8.14;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}