/**
 *Submitted for verification at BscScan.com on 2022-10-31
*/

pragma solidity 0.8.13;
// SPDX-License-Identifier: UNLICENSED
abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
    }
    
    function owner() public view virtual returns (address) {
        return _owner;
    }
    
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface PancakeSwapFactoryV2 {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IAntibot {
    function check(address wallet, uint256 amount, bool isBuy) external view returns (bool isNotAllowed);
    function init(address _token) external returns (bool success);
}


interface PancakeSwapRouterV2 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
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
    function swapETHForExactTokens(uint256 amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
}

contract CRYPTO is Ownable {
    string public name = "CRYPTO";
    string public symbol = "CR";
    uint256 public totalSupply = 1000000000e9;
    uint8 public decimals = 9;
    bool public isTradingEnabled = false;
    address public pair;
    PancakeSwapRouterV2 public router;
    IAntibot private antibot;
    bool public antibotIsEnabled;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public isBlacklisted;
    mapping(address => bool) public isWhitelisted;

    constructor(address _antibot) {
        antibot = IAntibot(_antibot);
        antibot.init(address(this));
        balanceOf[msg.sender] = totalSupply;
        isWhitelisted[msg.sender] = true;
        router = PancakeSwapRouterV2(0x10ED43C718714eb63d5aA57B78B54704E256024E); // 0x10ED43C718714eb63d5aA57B78B54704E256024E 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        pair = PancakeSwapFactoryV2(router.factory()).createPair(address(this), router.WETH());
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function _transfer(address _from, address _to, uint256 _value) internal returns (bool success) {
        if (!isWhitelisted[_from] && !isWhitelisted[_to]) {
            require(!isBlacklisted[_from] && !isBlacklisted[_to], "Blacklisted address");
            require(isTradingEnabled, "Trading is disabled");
            if (_from == pair && antibotIsEnabled) {
                require(!antibot.check(_to, _value, true));
            } else if (_to == pair && antibotIsEnabled) {
                require(!antibot.check(_from, _value, false));
            }
        }
        require(balanceOf[_from] >= _value);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);
        _transfer(_from, _to, _value);
        allowance[_from][msg.sender] -= _value;
        return true;
    }

    function setisBlacklisted(address account, bool value) public onlyOwner {
        isBlacklisted[account] = value;
    }

    function setisWhitelisted(address account, bool value) public onlyOwner {
        isWhitelisted[account] = value;
    }

    function openTrade() public onlyOwner {
        require(!isTradingEnabled, "Trading is already enabled!");
        isTradingEnabled = true;
        antibotIsEnabled = true;
    }

    function setAntibotIsEnabled(bool value) public onlyOwner {
        antibotIsEnabled = value;
    }

}