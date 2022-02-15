/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/

pragma solidity >=0.7.0 <0.9.0;

// SPDX-License-Identifier: Unlicensed
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

interface IERC721 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

contract Trustable {
    address private _owner;
    mapping (address => bool) private _isTrusted;
    address[] private delegates;

    constructor () {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner {
        require(_owner == msg.sender, "Caller is not the owner");
        _;
    }

    modifier onlyTrusted {
        require(_isTrusted[msg.sender] == true || _owner == msg.sender, "Caller is not trusted");
        _;
    }
    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        _owner = newOwner;
    }
    
    function addTrusted(address user) public onlyOwner {
        _isTrusted[user] = true;
        delegates.push(user);
    }

    function removeTrusted(address user) public onlyOwner {
        _isTrusted[user] = false;
    }
    
    function isTrusted(address user) public view returns (bool) {
        return _isTrusted[user];
    }
    
    function getDelegates() public view returns (address[] memory) {
        return delegates;
    }
}

contract FUD is IERC20, Trustable {

    string private constant _name = "Binamon FUD";
    string private constant _symbol = "FUD";
    uint8 private constant _decimals = 18;  
    uint256 private _totalSupply = 0;
    
    mapping(address => uint256) private balances;
    mapping(address => mapping (address => uint256)) private allowed;
    
    // Anti-scalper
    uint256 private profitMultiplier;
    address private stakeAddress;
    mapping (address => bool) private swapPairs;
    mapping (address => uint256) private profits;
    mapping (address => bool) private whitelist;
    
    using SafeMath for uint256;
    
    constructor() { 
        profitMultiplier = 100;
        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    
    // These are emergency withdrawal methods
    function withdrawBnb(uint256 amount) external onlyOwner {
        payable(msg.sender).transfer(amount);
    }
    
    function withdrawBEP20(address bep20, uint256 amount) external onlyOwner {
        IERC20 token = IERC20(bep20);
        token.transfer(msg.sender, amount);
    }
    ///////
    
    function whitelistAddress(address user, bool enable) public onlyTrusted {
        whitelist[user] = enable;
    }

    function setProfitMultiplier(uint256 multiplier) public onlyTrusted {
        profitMultiplier = multiplier;
    }

    function getProfitMultiplier() public view returns (uint256) {
        return profitMultiplier;
    }

    function setStakeAddress(address stake) public onlyTrusted {
        stakeAddress = stake;
    }

    function getStakeAddress() public view returns (address) {
        return stakeAddress;
    }

    function setSwapPairAddress(address pair, bool enabled) public onlyTrusted {
        swapPairs[pair] = enabled;
    }

    function isSwapPairAddress(address pair) public view returns (bool) {
        return swapPairs[pair];
    }
    
    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
    
    function totalSupply() public override view returns (uint256) {
	    return _totalSupply;
    }
    
    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }

    function getProfit(address user) public view returns (uint256) {
        return profits[user];
    }

    function antiScalper(address sender, address receiver, uint256 numTokens) internal {
        if (swapPairs[receiver] == true) {
            require(profits[sender] >= (numTokens * 100) / profitMultiplier);
            profits[sender] = profits[sender].sub((numTokens * 100) / profitMultiplier);
        }

        if (stakeAddress == sender) {
            profits[receiver] = profits[receiver].add(numTokens);
        }
    }

    function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        require(numTokens > 0, "Transfer amount must be greater than zero");
        require(numTokens <= balances[msg.sender]);

        balances[receiver] = balances[receiver].add(numTokens);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        
        if (!whitelist[msg.sender]) antiScalper(msg.sender, receiver, numTokens);

        return true;
    }

    function approve(address delegate, uint256 numTokens) public override returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public override view returns (uint256) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address receiver, uint256 numTokens) public override returns (bool) {
        require(numTokens > 0, "Transfer amount must be greater than zero");
        require(numTokens <= balances[owner]);    
        require(numTokens <= allowed[owner][msg.sender]);

        balances[receiver] = balances[receiver].add(numTokens);
        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        emit Transfer(owner, receiver, numTokens);
        
        if (!whitelist[owner]) antiScalper(owner, receiver, numTokens);

        return true;
    }
    
    function mint(uint256 numTokens, address receiver) public onlyTrusted returns(bool) {
        balances[receiver] = balances[receiver].add(numTokens);
        _totalSupply = _totalSupply.add(numTokens);
        emit Transfer(address(0), receiver, numTokens);
        return true;
    }
    
    function burn(uint256 numTokens) public returns(bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        _totalSupply = _totalSupply.sub(numTokens);
        emit Transfer(msg.sender, address(0), numTokens);
        return true;
    }
}

library SafeMath { 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}