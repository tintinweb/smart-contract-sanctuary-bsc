/**
 *Submitted for verification at BscScan.com on 2022-09-28
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
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
        require(!_paused,"already Paused");
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        require(_paused,"already Paused");
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

contract rechargeBUSD is Ownable, ReentrancyGuard, Pausable {

    IBEP20 public SCKStoken;
    IBEP20 public BUSDtoken;
    address public casinoWallet;
    address public wallet1;
    address public wallet2;
    uint32 public offerPercentage = 50; // 10 => 1%
    uint32[3] public sharePercentage = [980,10,10];

    event DepositBUSD(address indexed User, uint256 TokenAmount, uint256 SCKSReward, uint256 Time);
    event RecoverTokens(address indexed Receiver, address indexed tokenAddress, uint256 TokenAmount);

    constructor(address[5] memory _tokens_wallets) {
        SCKStoken = IBEP20(_tokens_wallets[0]);
        BUSDtoken = IBEP20(_tokens_wallets[1]);

        casinoWallet = _tokens_wallets[2];
        wallet1 =_tokens_wallets[3];
        wallet2 =_tokens_wallets[4];
    }

    function pause() external onlyOwner{
        _pause();
    }

    function unPause() external onlyOwner{
        _unpause();
    }

    function deposit(uint256 _tokenAmount) external whenNotPaused nonReentrant {

        uint256 rewardAmount = _tokenAmount * offerPercentage / 1e3;

        BUSDtoken.transferFrom(_msgSender(), address(this), _tokenAmount);
        BUSDtoken.transfer( casinoWallet, _tokenAmount * sharePercentage[0] / 1e3);
        BUSDtoken.transfer( wallet1, _tokenAmount * sharePercentage[1] / 1e3);
        BUSDtoken.transfer( wallet2, _tokenAmount * sharePercentage[2] / 1e3);
        SCKStoken.transfer(_msgSender(), rewardAmount);

        emit DepositBUSD(_msgSender(), _tokenAmount, rewardAmount, block.timestamp);

    }

    function updateShares(uint32[3] memory _shares) external onlyOwner {
        require((_shares[0] + _shares[1] + _shares[2]) == 1000, "invalid shares");
        sharePercentage = _shares;
    }

    function updateOfferPercentage(uint32 _percentage) external onlyOwner {
        offerPercentage = _percentage;
    }

    function updateWallet(address[3] memory _wallets) external onlyOwner{
        require(_wallets[0] != address(0) && _wallets[1] != address(0) && _wallets[2] != address(0), "Invalid wallet.");
        casinoWallet = _wallets[0];
        wallet1 = _wallets[1];
        wallet1 = _wallets[2];
    }

    function updateBUSDToken(address _BUSD) external onlyOwner {
        require(_BUSD != address(0) && IBEP20(_BUSD) != BUSDtoken, "Invalid BUSD address");
        BUSDtoken = IBEP20(_BUSD);
    }

    function updateSCKSToken(address _SCKS) external onlyOwner {
        require(_SCKS != address(0) && IBEP20(_SCKS) != SCKStoken, "Invalid BUSD address");
        SCKStoken = IBEP20(_SCKS);
    }

    function recoverTokens(address _to,address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        require(IBEP20(_tokenAddress).balanceOf(address(this)) >= _tokenAmount , "invalid amount to recover tokens");
        IBEP20(_tokenAddress).transfer(_to, _tokenAmount);

        emit RecoverTokens(_to, _tokenAddress, _tokenAmount);
    }

}