// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

contract SEED is ERC20 {

    address private _owner;
    address public feeTo;

    uint public minBalance;

    mapping(address => bool) public blacklist;
    /// fee
    mapping(address => bool) public noBalance;

    bool public canBuy;
    mapping(address => bool) public whitelist;

    mapping(address => uint) public fromFeeE4;
    mapping(address => uint) public toFeeE4;
    
    modifier onlyOwner() {
        require(msg.sender == _owner, "Permission denied");
        _;
    }

    constructor(address _owner_, address _feeTo) {
        _owner = _owner_;
        minBalance = 1 ether;
        feeTo = _feeTo;
        _mint(feeTo, 1000000000 ether);
    }

    function name() public pure returns(string memory) {
        return "Seed Coin";
    }

    function symbol() public pure returns(string memory) {
        return "SEED";
    }

    function decimals() public pure returns(uint8) {
        return 18;
    }

    function burn(uint _amount) external {
        _burn(msg.sender, _amount);
    }

    function setOwner(address _newOwner) external onlyOwner {
        _owner = _newOwner;
    }

    function setWhitelist(address[] calldata white, bool stauts) external onlyOwner {
        for(uint i = 0; i < white.length; i++) {
            whitelist[white[i]] = stauts;
        }
    }

    function setBlacklist(address[] calldata black, bool stauts) external onlyOwner {
        for(uint i = 0; i < black.length; i++) {
            blacklist[black[i]] = stauts;
        }
    }

    function setNoBalance(address[] calldata black, bool stauts) external onlyOwner {
        for(uint i = 0; i < black.length; i++) {
            noBalance[black[i]] = stauts;
        }
    }

    function setMinBalance(uint _minBalance) external onlyOwner {
        minBalance = _minBalance;
    }

    function setFee(address _addr, uint _feeFromE4, uint _feeToE4) external onlyOwner {
        fromFeeE4[_addr] = _feeFromE4;
        toFeeE4[_addr] = _feeToE4;
    }

    function _transfer(
        address from,
        address to,
        uint value
    ) internal override {
        require(!blacklist[from] && !blacklist[to], "Prohibited transactions");

        if ( !canBuy ) {
            require( !isContract(to) || whitelist[to] ,"can not swap");
            require( !isContract(from) || whitelist[from] ,"can not swap");
        }
        
        uint _feeAmount = 0;

        _feeAmount += fromFeeE4[from] * value / 1e4;
        _feeAmount += toFeeE4[to] * value / 1e4;

        balanceOf[from] -= value;

        uint _toValue = value - _feeAmount;
        balanceOf[to] += _toValue;
        emit Transfer(from, to, _toValue);

        if ( _feeAmount > 0 ) {
            balanceOf[feeTo] += _feeAmount;
            emit Transfer(from, feeTo, _feeAmount);
        }
        require(noBalance[from] || balanceOf[from] >= minBalance, "min balance insufficient");
        
    }

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}