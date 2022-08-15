/**
 *Submitted for verification at BscScan.com on 2022-08-14
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-14
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-29
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

contract TTT is Ownable {
    string public name = "test2";
    string public symbol = "test222";
    uint256 public totalSupply = 100000000e18;
    uint8 public decimals = 18;
    bool public isTradingEnabled = false;

    bool public antibot = true;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public isWhitelisted;



    constructor() {
        isWhitelisted[msg.sender] = true;
        balanceOf[msg.sender] = totalSupply;
        isWhitelisted[msg.sender] = true;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function _transfer(address _from, address _to, uint256 _value) internal returns (bool success) {
        if (!isWhitelisted[_from] && !isWhitelisted[_to]) {
            require(isTradingEnabled, "Trading is disabled");
        }
        require(balanceOf[_from] >= _value);

        uint256 taxAmount = (_value * tax)/(1e4);
        if (taxAmount > 0) {
          balanceOf[marketingAddress] += taxAmount;
          accumulatedTax = accumulatedTax + taxAmount;
        }else{
            taxAmount = 0;
        }


        balanceOf[_from] -= _value;
        balanceOf[_to] += _value - taxAmount;
        emit Transfer(_from, _to, _value - taxAmount);
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

    function multisetisWhitelisted(address[] calldata accounts, bool value) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            isWhitelisted[accounts[i]] = value;
        }
    }

    function setisWhitelisted(address account, bool value) public onlyOwner {
        isWhitelisted[account] = value;
    }

    function openTrade() public onlyOwner {
        require(!isTradingEnabled, "Trading is already enabled!");
        isTradingEnabled = true;
    }

    function setAntibot(bool value) public onlyOwner {
        antibot = value;
    }
    /////////////////////////tax ////////////////////////////////////////

    address public marketingAddress;
    uint256 public accumulatedTax = 0;
    // Numbers to two decimal places
    // ex: 0.5% => 50, 1% => 100 
    uint256 public tax = 0;



    function changeTax(uint256 _tax) public onlyOwner {
        require(_tax < 10000);
        tax = _tax;
    }

    event ChangedMarket(address marketingAddress);
    function setMarket(address _marketingAddress) public onlyOwner {
        require(_marketingAddress != address(0), "Error: zero address is not allowed.");
        marketingAddress = _marketingAddress;
        emit ChangedMarket(marketingAddress);
    }

    // function collectTax() public onlyOwner {
    //     require(accumulatedTax > 0, "$ARC: No tax");
    //     accumulatedTax = 0;
    //     balanceOf[address(this)] -= accumulatedTax;
    //     balanceOf[marketingAddress] += accumulatedTax;
    // }
}