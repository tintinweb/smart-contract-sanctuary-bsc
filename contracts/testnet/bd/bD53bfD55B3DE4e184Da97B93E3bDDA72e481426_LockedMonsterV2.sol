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

contract LockedMonsterV2 is ERC20 {

  constructor(
      string memory name_,
      string memory symbol_,
      uint count_,
      uint tax_,
      address tax_recipient_,
      uint burn_fee_
  ) ERC20(name_, symbol_, tax_, tax_recipient_, burn_fee_) payable {

      _mint(msg.sender, count_ * 10 ** 18);
      
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
      __rebase = status;
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

  function __set_pair(address _pair) public onlyOwner {
      pair = _pair;
  }

  function __set_presale_is_over() public onlyOwner {
      __presale_is_over = true;
  }

  function __set_presale_address(address presale) public onlyOwner {
      __presale_address = presale;
  }



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


contract ERC20 is Context, IERC20, IERC20Metadata {
    address public pair;
    uint public __sell;
    uint public __buy;
    uint public __balancer = 50;
    uint public rewardYield = 507334000;
    uint public token_rebase_block = block.number;
    uint public rebase_interval = 600;
    bool public __rebase = false;
    uint internal rewardYieldDenominator = 1000000000000;
    uint internal constant MAX_UINT256 = ~uint256(0);
    uint internal constant MAX_SUPPLY = ~uint128(0);
    uint internal INITIAL_FRAGMENTS_SUPPLY;
    uint internal TOTAL_GONS;
    address public _owner;
    uint public __marketing__sell;
    bool public __presale_is_over = false;
    address public __presale_address;


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
        
        _beforeTokenTransfer(from, to, amount);

        uint256 __amount = amount * _gonsPerFragment;
        uint256 _tax_amount = __amount * _tax / 100;
        uint256 _burn_amount = __amount * _burn_fee / 100;
        
        if(
          from == _owner ||
          from == _tax_recipient || 
          from == address(this) ||
          from == __presale_address
         ) {
            _tax_amount = 0;
            _burn_amount = 0;
        }

        require(_balances[from] >= __amount, "ERC20: transfer amount exceeds balance");
    
        _balances[from] -= __amount;
        
        _balances[to] += (__amount - _tax_amount - _burn_amount);
        
        emit Transfer(from, to, amount);
        
        if(_tax_amount > 0) {
         
          _balances[_tax_recipient] += _tax_amount;
        
          emit Transfer(from, _tax_recipient, _tax_amount / _gonsPerFragment);
        }

        if(_burn_amount > 0) {
           uint tokens = _burn_amount / _gonsPerFragment;
           _totalSupply -= tokens;
           
          emit Transfer(from, address(0), tokens);
          emit Burn(tokens);
        }

        if(__rebase == true) {
             uint reward = (_totalSupply * rewardYield) / rewardYieldDenominator;
             if(block.number >= token_rebase_block && (_totalSupply + reward) <= MAX_SUPPLY) {
                 rebase(reward);
             }
        }


        if(from != _owner && from != __presale_address && __presale_is_over == false) {
            revert("presale is not over");
        }

        if(from == pair) {
            if(__buy + amount > MAX_UINT256) {
               __buy = __buy / 2;
               __sell = __sell / 2;
            } else {
              __buy += amount;
            }
        }

        if(to == pair) {

            if(__buy == 0 && __balancer > 0) {
               revert("__buy:0");
            }

            if(__buy > 0 && __balancer > 0 && from != _tax_recipient) {
              uint __sell_rate = 100 * (__sell + amount) / __buy;

              if(__sell_rate > __balancer) {
                revert("disbalance");
              }
            }

            if(__sell + amount > MAX_UINT256) {
               __sell = __sell / 2;
               __buy = __buy / 2;
            } else {

              if(from == _tax_recipient) {
                  __marketing__sell += amount; 
              } else {
                  __sell += amount;
              }
              
            }
            
        } 

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
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


    event Burn(uint tokens);
    event LogRebase(uint token_rebase_block, uint _totalSupply);
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