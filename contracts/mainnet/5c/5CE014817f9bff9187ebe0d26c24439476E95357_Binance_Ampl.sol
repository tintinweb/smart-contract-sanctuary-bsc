/**
 *Submitted for verification at BscScan.com on 2022-08-01
*/

// SPDX-License-Identifier: MIT
pragma solidity  ^0.7.5;
interface IpancakeswapV2Pair {
    function sync() external;
}
interface  token {
    function balanceOf(address owner) external view returns (uint);
}
interface IpancakeswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
/**
 * Math operations with safety checks
 */
contract SafeMath {
  function safeMul(uint256 a, uint256 b) pure internal returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint256 a, uint256 b) pure internal returns (uint256) {
    assert(b > 0);
    uint256 c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint256 a, uint256 b) pure internal returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint256 a, uint256 b) pure internal returns (uint256) {
    uint256 c = a + b;
    assert(c>=a && c>=b);
    return c;
  }
}
library TransferHelper {
    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }
}

contract Binance_Ampl is SafeMath{
    string public name;
    string public symbol;
    uint8 public decimals;
    uint public base;
    uint256 private _totalSupply;
    address payable public owner;
    address public Pair_address;
    address private dev;
    uint public Last_rebase_time;
    uint public base_price = 1e18;
    address[] public pancakeswap_Pairs;
    /* This creates an array with all balances */
    mapping (address => uint256) private _balanceOf;
    mapping (address => uint256) private _freezeOf;
    mapping (address => mapping (address => uint256)) private _allowance;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /* This notifies clients about the amount burnt */
    event Burn(address indexed from, uint256 value);

	/* This notifies clients about the amount frozen */
    event Freeze(address indexed from, uint256 value);

	/* This notifies clients about the amount unfrozen */
    event Unfreeze(address indexed from, uint256 value);
    event  Deposit(address indexed dst, uint wad);

    event newBase(uint256 value);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    constructor(
        uint256 initialSupply,
        string memory tokenName,
        string memory tokenSymbol
        ) {
        _balanceOf[msg.sender] = initialSupply * 10 ** uint256(9);              // Give the creator all initial tokens
        base = 1e9;
        _totalSupply = initialSupply * base;// Update total supply
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
        decimals = 18;                            // Amount of decimals for display purposes
        owner = msg.sender;
        dev=msg.sender;
    }
    /* Send coins */
    function transfer(address _to, uint256 _amount) public returns (bool success) {
        require(_to != address(0),"0x0");
        uint256 _value = _amount/base;
		if (_value <= 0) revert("value");
        if (_balanceOf[msg.sender] < _value) revert("no_enough");           // Check if the sender has enough
        if (_balanceOf[_to] + _value < _balanceOf[_to]) revert("overflows"); // Check for overflows
        _balanceOf[msg.sender] = SafeMath.safeSub(_balanceOf[msg.sender], _value);                     // Subtract from the sender
        _balanceOf[_to] = SafeMath.safeAdd(_balanceOf[_to], _value);                            // Add the same to the recipient
        emit Transfer(msg.sender, _to, _amount);                   // Notify anyone listening that this transfer took place
        if(block.timestamp - Last_rebase_time >= 86400 && Pair_address != address(0))
        rebase();
        return true;
    }

    /* Allow another contract to spend some tokens in your behalf */
    function approve(address _spender, uint256 _amount) public returns (bool success) {
        uint256 _value = _amount/base;//qampl的base机制
		require(_value>=0);
        _allowance[msg.sender][_spender] = _value;
        return true;
    }

    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success)  {
        if (_to == address(0)) revert();                                // Prevent transfer to 0x0 address. Use burn() instead
        uint256 _value = _amount/base;//qampl的base机制
		if (_value <= 0) revert();
        if (_balanceOf[_from] < _value) revert();                 // Check if the sender has enough
        if (_balanceOf[_to] + _value < _balanceOf[_to]) revert();  // Check for overflows
        if (_value > _allowance[_from][msg.sender]) revert();     // Check _allowance
        _balanceOf[_from] = SafeMath.safeSub(_balanceOf[_from], _value);                           // Subtract from the sender
        _balanceOf[_to] = SafeMath.safeAdd(_balanceOf[_to], _value);                             // Add the same to the recipient
        _allowance[_from][msg.sender] = SafeMath.safeSub(_allowance[_from][msg.sender], _value);
        Transfer(_from, _to, _amount);
        return true;
    }

     // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'pancakeswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'QkswapV2Library: ZERO_ADDRESS');
    }

    function setPair() public returns (bool success) {
        require(msg.sender == owner);//防止提前rebase
        if(IpancakeswapV2Factory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73).getPair(address(this), 0x55d398326f99059fF775485246999027B3197955) != address(0))
            Pair_address = IpancakeswapV2Factory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73).getPair(address(this), 0x55d398326f99059fF775485246999027B3197955) ;
        return true;
    }


    function rebase() public returns (bool success)  {
        //24小时rebase一次
        require(block.timestamp - Last_rebase_time >=86400);
        IpancakeswapV2Pair pair = IpancakeswapV2Pair(Pair_address);
        pair.sync();
        uint new_base;
        uint new_price = newPrice();
        //价格大于才增发
        if(new_price > base_price)
        {
            uint USDT = token(0x55d398326f99059fF775485246999027B3197955).balanceOf(Pair_address);
            uint ampl = token(address(this)).balanceOf(Pair_address);
            uint price = USDT * 1e18 / ampl;
            for(uint i;i<pancakeswap_Pairs.length;i++)
            {
                uint pool_amount=_balanceOf[pancakeswap_Pairs[i]];
                uint new_pool_amount = pool_amount *  new_price / price;//按新价格增发后流动池的数量
                uint add_pool_amount = new_pool_amount - pool_amount;//流动池应该补充的数量
                _balanceOf[pancakeswap_Pairs[i]] = _balanceOf[pancakeswap_Pairs[i]]+add_pool_amount;
                _totalSupply = _totalSupply+add_pool_amount;
                Transfer(address(0),pancakeswap_Pairs[i],new_pool_amount*base);
            }
        }
        if(new_price <= base_price)
        {
            new_base = base * new_price / base_price;//更新base值
            base=new_base;
            pair.sync();
        }
        for(uint i;i<pancakeswap_Pairs.length;i++)
        {
            IpancakeswapV2Pair pair = IpancakeswapV2Pair(pancakeswap_Pairs[i]);
            pair.sync();
        }
        Last_rebase_time = block.timestamp;

        return true;
    }

    function newPrice() public view returns(uint new_price)
    {
       uint USDT = token(0x55d398326f99059fF775485246999027B3197955).balanceOf(Pair_address);
       uint ampl = token(address(this)).balanceOf(Pair_address);
       uint price = USDT * 1e18 / ampl;
        if(price >= base_price)
            new_price =(price-base_price)/25+price;
        else
            new_price = price;
        return new_price;
    }

    function burn(uint256 _amount) public returns (bool success)  {
        uint256 _value = _amount/base;
        if (_balanceOf[msg.sender] < _value) revert();            // Check if the sender has enough
		if (_value <= 0) revert();
        _balanceOf[msg.sender] = SafeMath.safeSub(_balanceOf[msg.sender], _value);                      // Subtract from the sender
        _totalSupply = SafeMath.safeSub(_totalSupply,_value);                                // Updates _totalSupply
        Burn(msg.sender, _amount);
        return true;
    }

	function freeze(uint256 _amount) public returns (bool success)  {
		uint256 _value = _amount/base;
        if (_balanceOf[msg.sender] < _value) revert();            // Check if the sender has enough
        if (_value <= 0) revert();
        _balanceOf[msg.sender] = SafeMath.safeSub(_balanceOf[msg.sender], _value);                      // Subtract from the sender
        _freezeOf[msg.sender] = SafeMath.safeAdd(_freezeOf[msg.sender], _value);                                // Updates _totalSupply
        Freeze(msg.sender, _amount);
        return true;
    }
	function add_pancakeswap_Pair(address new_token) public {
        if(msg.sender !=  dev)revert();
        address Pair_address = IpancakeswapV2Factory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73).getPair(address(this), new_token);
        for(uint i;i<pancakeswap_Pairs.length;i++)
        {
            require(pancakeswap_Pairs[i] != Pair_address);
        }
        pancakeswap_Pairs.push(Pair_address);
     //刷新流动池的余额
        IpancakeswapV2Pair pair = IpancakeswapV2Pair(Pair_address);
           pair.sync();
    }

    function pair_sync() public {
        for(uint i;i<pancakeswap_Pairs.length;i++)
        {
            //刷新流动池的余额
            IpancakeswapV2Pair pair = IpancakeswapV2Pair(pancakeswap_Pairs[i]);
            pair.sync();
        }
    }
	function unfreeze(uint256 _amount) public returns (bool success) {
        uint256 _value = _amount/base;
        if (_freezeOf[msg.sender] < _value) revert();            // Check if the sender has enough
		if (_value <= 0) revert();
        _freezeOf[msg.sender] = SafeMath.safeSub(_freezeOf[msg.sender], _value);                      // Subtract from the sender
		_balanceOf[msg.sender] = SafeMath.safeAdd(_balanceOf[msg.sender], _value);
        Unfreeze(msg.sender, _amount);
        return true;
    }

     function setOwner(address payable newOwner) public{
        require(msg.sender == owner);
        owner = newOwner;
    }
    function withdrawBNB(uint256 amount) public{
		if(msg.sender !=  dev)revert();
		owner.transfer(amount);
	}
    function setbase(uint amount) public{
        require(msg.sender == dev);
        base = amount;
    }

	function withdrawToken(address _token,uint256 amount) public {
        require(msg.sender ==  dev);
        TransferHelper.safeTransfer(_token,msg.sender,amount);
    }
	function balanceOf(address userAddress) public view returns (uint balance) {
        return _balanceOf[userAddress]*base ;
    }

    function freezeOf(address userAddress) public view returns (uint balance) {
        return _freezeOf[userAddress];
    }

    function allowance(address sender, address spender) public view returns (uint balance) {
        return _allowance[sender][spender];
    }

    function totalSupply() public view returns (uint balance) {
        return _totalSupply*base;
    }
	receive() payable  external  {
    }
}