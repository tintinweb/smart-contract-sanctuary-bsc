/**
 *Submitted for verification at BscScan.com on 2022-10-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}          



contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }   
    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}


abstract contract ReentrancyGuard {
   
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

   
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

interface IERC20 {

    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}



contract PaymentGateway is ReentrancyGuard, Context, Ownable {
 
    IERC20 public _token;
    address public _wallet;

    mapping (address => bool) public hasRole;

    event TokensPurchased(address  purchaser, uint256 value);
    event BnbPurchased(address  purchaser, uint256 value);
    event TokenWithdrawed(address  reciever, uint256 value);
    event BnbWithdrawed(address  reciever, uint256 value);

    constructor (address wallet,IERC20 token)  {
        require(address(token) != address(0), "token: token is the zero address");
        _token = token;
        _wallet = wallet;
    }

    function buyTokens(uint256 amount) external nonReentrant{
        uint256 weiAmount = amount;
        require(_token.balanceOf(msg.sender)>=amount,"Balance is Low");
        require(_token.allowance(msg.sender,address(this))>=amount,"Allowance not given for Buying Token");
        require(_token.transferFrom(msg.sender,address(this),amount),"Couldnt Transfer Amount");
        require(_token.transfer(_wallet,amount),"Couldnt Transfer Amount");

        emit TokensPurchased(msg.sender, weiAmount);
    }

    function buyBnb() external payable nonReentrant{
        uint256 amount = msg.value;
        uint256 weiAmount = amount; 
        payable(_wallet).transfer(amount);
        
        emit BnbPurchased(msg.sender, weiAmount);
    }

    function _forwardFunds() external nonReentrant onlyOwner {
        payable(_wallet).transfer(address(this).balance);
    }
    
    function takeTokens(IERC20 tokenAddress) external nonReentrant onlyOwner{
        IERC20 tokenBEP = tokenAddress;
        uint256 tokenAmt = tokenBEP.balanceOf(address(this));
        require(tokenAmt > 0, 'BEP-20 balance is 0');
        tokenBEP.transfer(_wallet, tokenAmt);
    }

    function withdrawToken(address _userAddress, uint256 _amount) external nonReentrant{
        require(hasRole[msg.sender] || msg.sender == owner());
        uint256 tokenAmt = _token.balanceOf(address(this));
        require(tokenAmt > 0, 'BEP-20 balance is 0');
        _token.transfer(_userAddress, _amount);
        emit TokenWithdrawed(_userAddress,_amount);
    }

    function withdrawBnb(address _userAddress, uint256 _amount) external nonReentrant{
        require(hasRole[msg.sender] || msg.sender == owner());
        payable(_userAddress).transfer(_amount);
        emit BnbWithdrawed(_userAddress,_amount);
    }

    function withdrawMultipleToken(address[] memory _receivers, uint256[] memory _amounts) external  nonReentrant returns (bool withdrawBool){
        require(hasRole[msg.sender] || msg.sender == owner());
        require(_receivers.length == _amounts.length, "Amount and Address not of equal length");
        for(uint256 i=0; i<_receivers.length; i++){
            _token.transfer(_receivers[i],_amounts[i]);
            emit TokenWithdrawed(_receivers[i],_amounts[i]);
        }
        return true;
    }
    
     function withdrawMultipleBnb(address payable[] memory _receivers, uint256[] memory _amounts) external payable nonReentrant returns (bool withdrawBool){
        require(hasRole[msg.sender] || msg.sender == owner());
        require(_receivers.length == _amounts.length, "Amount and Address not of equal length");
        for(uint256 i=0; i<_receivers.length; i++){
            _receivers[i].transfer(_amounts[i]);
            emit BnbWithdrawed(_receivers[i],_amounts[i]);
        }
        return true;
    }

    function giveRole(address _addAdmin) external onlyOwner nonReentrant returns (bool roleGiven) {
        hasRole[_addAdmin] = true;
        return true;
    }
    function removeRole(address _removeAdmin) external onlyOwner nonReentrant returns (bool roleGiven) {
        hasRole[_removeAdmin] = false;
        return true;
    }

    function checkRole(address _checkAdd) public view returns (bool isAdmin) {
        return hasRole[_checkAdd];
    }

    function setWalletReceiver(address newWallet) external onlyOwner(){
        _wallet = newWallet;
    }
}