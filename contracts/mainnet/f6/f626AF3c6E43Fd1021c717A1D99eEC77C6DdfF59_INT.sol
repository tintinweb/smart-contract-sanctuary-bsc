// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFactory {
  function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IPair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns ( uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast );
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}

contract ERC20 {

    uint public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function _mint(address to, uint value) internal {
        totalSupply += value;
        balanceOf[to] += value;
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint value) internal {
        balanceOf[from] -= value;
        totalSupply -= value;
        emit Transfer(from, address(0), value);
    }

    function _approve(
        address owner,
        address spender,
        uint value
    ) internal virtual {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(
        address from,
        address to,
        uint value
    ) internal virtual {
        balanceOf[from] -= value;
        balanceOf[to] += value;
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(
        address from,
        address to,
        uint value
    ) external returns (bool) {
        if (allowance[from][msg.sender] != type(uint256).max) {
            allowance[from][msg.sender] -= value;
        }
        _transfer(from, to, value);
        return true;
    }
}

contract INT is ERC20 {

    address private _owner;

    uint8 public decimals = 18;

    address public sellTo;
    address public lp;
    address public constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    address public constant FACTORY = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;

    mapping(address => bool) public free;

    modifier onlyOwner() {
        require(msg.sender == _owner, "Permission denied");
        _;
    }

    constructor(address _sellTo) {
        _owner = msg.sender;
        sellTo = _sellTo;
        lp = IFactory(FACTORY).createPair(USDT, address(this));
        free[sellTo] = true;
        _mint(sellTo, 300000 ether);
    }

    function name() external pure returns(string memory) {
        return "Integral";
    }

    function symbol() external pure returns(string memory) {
        return "INT";
    }

    function burn(uint _amount) external {
        _burn(msg.sender, _amount);
    }

    function setFree(bool _status, address[] calldata _freeList) external onlyOwner {
        for(uint i = 0 ; i < _freeList.length; i++) {
            free[_freeList[i]] = _status;
        }
    }

    function setAdmin(address _newOwner) external onlyOwner {
        _owner = _newOwner;
    }

    function setSellTo(address _newSellTo) external onlyOwner {
        sellTo = _newSellTo;
    }

    function _transfer(
        address from,
        address to,
        uint value
    ) internal override {

        uint _fee = 0;
        
        if ( !free[to] && !free[from] ) {
            if ( from == lp ) {
                _fee = value / 50;
                balanceOf[sellTo] += _fee;
                emit Transfer(from, sellTo, _fee);
            }
            else if ( to == lp ) {
                _fee = value / 25;
                _sell(_fee, from);
            }
        }

        balanceOf[from] -= value;

        value -= _fee;

        balanceOf[to] += value;

        emit Transfer(from, to, value);
    }

    function _sell(uint _sellAmount, address _from) internal {
        
        bool token1IsUsdt = address(this) < USDT;

        IPair _Ilp = IPair(lp);
        
        (uint112 reserve0, uint112 reserve1,) = _Ilp.getReserves();
        
        uint _amountOut0 = 0;
        uint _amountOut1 = 0;

        uint feeEPX4 = 9975;

        if ( token1IsUsdt ) {
            _amountOut1 = getAmountOut(_sellAmount, reserve0, reserve1, feeEPX4);
        } else {
            (reserve0, reserve1) = (reserve1, reserve0);
            _amountOut0 = getAmountOut(_sellAmount, reserve0, reserve1, feeEPX4);
        }
        
        balanceOf[lp] += _sellAmount;
        emit Transfer(_from, lp, _sellAmount);

        _Ilp.swap(_amountOut0, _amountOut1, sellTo, bytes(""));

    }

     function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut,
        uint feeEPX4
    ) internal pure returns (uint amountOut) {
        uint amountInWithFee = amountIn * feeEPX4;
        uint numerator = amountInWithFee * reserveOut;
        uint denominator = reserveIn * 10000 + amountInWithFee;
        amountOut = numerator / denominator;
    }

}