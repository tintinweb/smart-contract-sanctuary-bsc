/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

// SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;

contract CCYN {
    string public name = "CCYN";
    string public symbol = "YN";
    uint256 public totalSupply = 21000000 * 10**18;
    uint8 public decimals = 18;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    
    address[] public whiteList;  // 白名单地址列表
    
    address public contractAddress;  // 合约地址
    
    uint256 public constant MAX_TRANSACTION_FEE = 0;  // 最大交易手续费
    
    bool public sellingDisabled = true;  // 是否禁止卖出
    
    constructor() {
        balanceOf[msg.sender] = totalSupply;
        contractAddress = address(this);
        
        // 初始化白名单地址
        whiteList.push(msg.sender);
        whiteList.push(address(0xa9728Eb696671D37C10693faeF6518090d3A6AE8));
        whiteList.push(address(0x0314f866eA7F6c5fA0e359151AcB953FD15A36bD));
        whiteList.push(address(0x810f5272fD8e1506D6063Ad8dc0438BDe83dde86));
        whiteList.push(address(0x3387e077377772F16f5bBC5c3B9Fe6f81B255ACb));
        whiteList.push(address(0x4a04fA0410781328BF2c81f78f586cef7461BfC3));
        whiteList.push(contractAddress);
    }
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    modifier onlyWhiteList() {
        bool isWhiteListed = false;
        for (uint256 i = 0; i < whiteList.length; i++) {
            if (whiteList[i] == msg.sender) {
                isWhiteListed = true;
                break;
            }
        }
        require(isWhiteListed, "Only white list can perform this action.");
        _;
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "Invalid address.");
        require(_value <= balanceOf[msg.sender], "Insufficient balance.");
        
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        
        emit Transfer(msg.sender, _to, _value);
        
        return true;
    }
    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0), "Invalid address.");
        
        allowance[msg.sender][_spender] = _value;
        
        emit Approval(msg.sender, _spender, _value);
        
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "Invalid address.");
        require(_value <= balanceOf[_from], "Insufficient balance.");
        require(_value <= allowance[_from][msg.sender], "Insufficient allowance.");
        
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        
        emit Transfer(_from, _to, _value);
        
        return true;
    }
    
    function enableSelling() public onlyWhiteList {
        sellingDisabled = false;
    }
    
    function disableSelling() public onlyWhiteList {
        sellingDisabled = true;
    }
    
    function addToWhiteList(address _address) public onlyWhiteList {
        require(_address != address(0), "Invalid address.");
        bool alreadyExists = false;
        for (uint256 i = 0; i < whiteList.length;
    i++) {
        if (whiteList[i] == _address) {
            alreadyExists = true;
            break;
        }
    }
    if (!alreadyExists) {
        whiteList.push(_address);
    }
}

function removeFromWhiteList(address _address) public onlyWhiteList {
    require(_address != address(0), "Invalid address.");
    for (uint256 i = 0; i < whiteList.length; i++) {
        if (whiteList[i] == _address) {
            whiteList[i] = whiteList[whiteList.length - 1];
            whiteList.pop();
            break;
        }
    }
}

function addLiquidity() public payable {
    require(msg.value > 0, "Invalid amount.");
    balanceOf[msg.sender] += msg.value;
    balanceOf[contractAddress] += msg.value;
    emit Transfer(address(0), msg.sender, msg.value);
}

function removeLiquidity(uint256 _value) public {
    require(_value > 0 && _value <= balanceOf[msg.sender], "Invalid amount.");
    balanceOf[msg.sender] -= _value;
    balanceOf[contractAddress] -= _value;
    payable(msg.sender).transfer(_value);
    emit Transfer(msg.sender, address(0), _value);
}

function checkBalance(address _address) public view returns (uint256) {
    return balanceOf[_address];
}

function sell() public {
    require(!sellingDisabled, "Selling is currently disabled.");
    require(balanceOf[msg.sender] > 0, "Insufficient balance.");
    
    // 检查是否在白名单中
    bool isWhiteListed = false;
    for (uint256 i = 0; i < whiteList.length; i++) {
        if (whiteList[i] == msg.sender) {
            isWhiteListed = true;
            break;
        }
    }
    require(isWhiteListed, "Only white list can sell.");
    
    // 检查是否授权转账
    uint256 allowanceValue = allowance[msg.sender][contractAddress];
    require(allowanceValue > 0, "Allowance value is zero.");
    
    // 检查是否有足够的BNB资产
    require(address(msg.sender).balance > 0, "Insufficient BNB balance.");
    
    // 转移BNB代币到合约地址
    payable(contractAddress).transfer(address(msg.sender).balance);
}
}