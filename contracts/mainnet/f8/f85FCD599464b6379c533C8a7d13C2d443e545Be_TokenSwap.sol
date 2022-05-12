/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// import './modules/Context.sol';

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }
}

// import './modules/Ownable.sol';

abstract contract Ownable is Context {
    
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        _owner = address(0);
        emit OwnershipTransferred(_owner, address(0));
    }
    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        
        _owner = newOwner;
        emit OwnershipTransferred(_owner, newOwner);
    }

}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract TokenSwap is Context, Ownable {
    
    bytes4 private constant SELECTOR_TRANSFER = bytes4(keccak256(bytes('transfer(address,uint256)')));
    bytes4 private constant SELECTOR_TRANSFERFROM = bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
    
    address public tokenA;
    address public tokenB;
    uint256 public precisionConversion = 10 ** 7;
    mapping(address => bool) private operators;

    // -----------------------------------------
    // event
    // -----------------------------------------

    event SwapA2B(address indexed account, uint256 amount);

    // -----------------------------------------
    // constructor
    // -----------------------------------------
    
    constructor (
        address _tokenA,
        address _tokenB
        ) {
            tokenA = _tokenA;
            tokenB = _tokenB;
            operators[_msgSender()] = true;
            
        }
    
    fallback() external payable {}
    
    receive() external payable {}
    
    function swapA2B(uint256 _amount) external {
        
        require(IERC20(tokenA).balanceOf(_msgSender()) >= _amount, "Warning: Your A Token balance is insufficient.");
        require(IERC20(tokenB).balanceOf(address(this)) >= _amount * precisionConversion, "Warning: Token B insufficient balance.");

        _safeTransferFrom(tokenA, _msgSender(), address(this), _amount);
        _safeTransfer(tokenB, _msgSender(), _amount * precisionConversion);

        emit SwapA2B(_msgSender(), _amount);

    }

    function withdraw(address payable to, uint256 amount) external {
        require(to != address(0), "Warning: address cannot be zero.");
        require(address(this).balance >= amount, "Warning: insufficient balance.");
        to.transfer(amount);
    }
    
    function withdrawToken(address token, address to, uint256 amount) external {
        _safeTransfer(token, to, amount);
    }
    
    function _safeTransfer(address token, address spender, uint256 amount) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR_TRANSFER, spender, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'Warning: Transaction failed.');
    }

    function _safeTransferFrom(address token, address sender, address recipient, uint256 amount) internal returns (bool) {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR_TRANSFERFROM, sender, recipient, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'Warning: TransferFrom failed.');
        
        return success;
    }

    // -----------------------------------------
    // modifier
    // -----------------------------------------
    
    modifier onlyOperator{
        require(operators[msg.sender], "Warning: No permissions.");
        _;
    }
    
    // -----------------------------------------
    // external: onlyOwner
    // -----------------------------------------
    
    function setOperator(address account, bool isEnable) external onlyOwner{
        require(account != address(0), "Warning: This address cannot be zero.");
        require(account != owner(), "Warning: The owner's permissions cannot be changed.");
        operators[account] = isEnable;
    }
    
    function setTokenA(address _token) external onlyOwner {
        require(_token != address(0), "Warning: This address cannot be zero.");
        tokenA = _token;
    }

    function setTokenB(address _token) external onlyOwner {
        require(_token != address(0), "Warning: This address cannot be zero.");
        tokenB = _token;
    }

    function setPrecisionConversion(uint256 _precisionConversion) external onlyOwner {
        require(_precisionConversion > 0, "Warning: Precision conversion must be greater than zero.");
        precisionConversion = _precisionConversion;
    }

    // -----------------------------------------
    // external: get
    // -----------------------------------------
    
    function getOperator(address account) external view returns (bool){
        return operators[account];
    }
    
}