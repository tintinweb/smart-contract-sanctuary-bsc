/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-25
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IBEP20 {
    
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom( address sender, address recipient, uint256 amount) external returns (bool);
   
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {
    
    constructor()  {}

    function _msgSender() internal view returns (address ) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Pausable is Context {
    
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () {
        _paused = false;
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

contract AnationPresale is Ownable, Pausable {

    IBEP20 public AnationToken;
    address public tresuryAddress;
    uint256 public tokenPerBNB;
    uint256 public startingTime;
    uint256 public endingTime;
    uint256 public minBNBAllowToBuy = 500000000000000000;
    uint256 public maxBNBAllowToBuy = 10000000000000000000;

    event BuyToken(address indexed caller, uint256 BNBValue, uint256 TokenValue);    
    event Emergency(address indexed tokenAddres, address receiver, uint256 tokenAmount);

    constructor( address _AnationToken, address _tresuryAddress, uint256 _startingTime, uint256 _endingTime, uint256 _tokenPerBNB ) {
        AnationToken = IBEP20(_AnationToken); 
        tresuryAddress = _tresuryAddress;
        startingTime= _startingTime;
        endingTime = _endingTime;
        tokenPerBNB = _tokenPerBNB;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unPause() external onlyOwner {
        _unpause();
    }

    function buyTokens() external payable whenNotPaused {

        require(minBNBAllowToBuy <= msg.value && maxBNBAllowToBuy >= msg.value,"Invalid Buying Amount");
        require(startingTime <= block.timestamp && endingTime >= block.timestamp,"Not Time to buy");

        uint256 tokens = getTokenAmount(msg.value);
        AnationToken.transfer(msg.sender, tokens);
        require(payable(tresuryAddress).send(msg.value),"Transaction failed");

        emit BuyToken(msg.sender, msg.value, tokens);
    }

    function getTokenAmount(uint256 _BNBamount) public view returns(uint256 TokenAmount) {
        TokenAmount = tokenPerBNB * _BNBamount / 1e18;
    }

    function updateTresuryAddress(address _newWallet) external onlyOwner {
        tresuryAddress = _newWallet;
    }

    function balanceSaleToken() external view returns(uint256 saleTokens){
        return AnationToken.balanceOf(address(this));
    }

    function updateAnation(address _newToken) external onlyOwner {
        AnationToken = IBEP20(_newToken);
    }

    function updateBuyingAmount(uint256 _minAmount, uint256 _maxAmount) external onlyOwner {
        minBNBAllowToBuy = _minAmount;
        maxBNBAllowToBuy = _maxAmount;
    }

    function updateTime(uint256 _startTime, uint256 _endTime) external onlyOwner {
        startingTime = _startTime;
        endingTime = _endTime;
    }

    function updateTokenAmount(uint256 newTokenAmount) external onlyOwner {
        tokenPerBNB = newTokenAmount;
    }
    
    function emergency(address _tokenAddress, address _to, uint256 _tokenAmount) external onlyOwner {
        if(_tokenAddress == address(0x0)){
            require(payable(_to).send(_tokenAmount),"transaction failed");
        } else {
            IBEP20(_tokenAddress).transfer(_to, _tokenAmount);
        }

        emit Emergency(_tokenAddress, _to, _tokenAmount);
    }

}