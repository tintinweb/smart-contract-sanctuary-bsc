/**
 *Submitted for verification at BscScan.com on 2023-01-08
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.17;


contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


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

abstract contract ReentrancyGuard {
    bool private _notEntered;

    constructor ()  {
        _notEntered = true;
    }
    
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _notEntered = false;

        _;

        _notEntered = true;
    }
}


contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() external view returns (address) {
        return _owner;
    }   
    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    function renounceOwnership() external virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}

contract CustodiyV2Airdrop is ReentrancyGuard, Context, Ownable{

    uint256 public total_V1_Tokens_Collected;
    uint256 public total_V2_Tokens_Distributed;
    uint256 public total_Depositors;
    uint256 public total_Migrators;
    
    mapping(address => bool) public _claimed;
    mapping(address => bool) public _isWhitelisted;
    mapping(address => uint256) public _cty_V2_Claimable_Amount;
    
    IERC20 public _ctyV1Token;
    IERC20 public _ctyV2Token;
    bool public airdropLive;
    
    event AirdropClaimed(address receiver, uint256 amount);
    event CTYV1TokensDeposited(address holder, uint256 amount);
    event WhitelistSetted(address[] recipient, uint256[] amount);
    event WhitelistRemoved(address[] recipient);

    constructor(IERC20 ctyV1Token_, IERC20 ctyV2Token_) {
        _ctyV1Token = ctyV1Token_;
        _ctyV2Token = ctyV2Token_;
    }
    
     
     //Start Airdrop and depost V2 tokens to the contract
    function _startAirdrop(bool status) external onlyOwner{
        airdropLive = status;
        _ctyV2Token.transferFrom(msg.sender, address(this), total_V1_Tokens_Collected);
    }

    //@dev can update token
    function _updateToken(IERC20 v1TokenAddress, IERC20 v2TokenAddress) external onlyOwner {
        _ctyV1Token = v1TokenAddress;
        _ctyV2Token = v2TokenAddress;
    }

    // User can deposit tokens
    function _deposit_V1_CTY() external nonReentrant {
        uint256 depositAmnt = _ctyV1Token.balanceOf(msg.sender);
        require(depositAmnt > 0, "No use sending 0 amount");

        _ctyV1Token.transferFrom(msg.sender, address(this), depositAmnt);

        if(_cty_V2_Claimable_Amount[msg.sender] == 0) {
            total_Depositors++;
        }
        
        total_V1_Tokens_Collected += depositAmnt;
        _cty_V2_Claimable_Amount[msg.sender] += depositAmnt;
        _isWhitelisted[msg.sender] = true;

        emit CTYV1TokensDeposited(msg.sender, depositAmnt);
    }

    function _claim_V2_Tokens() external nonReentrant {
        require(airdropLive, "Airdrop has not started yet");
        require(!_claimed[msg.sender], "Airdrop already claimed!");
        require(_isWhitelisted[msg.sender], "You have not deposited your V1 tokens yet!");
        require(_ctyV2Token.balanceOf(address(this)) >= _cty_V2_Claimable_Amount[msg.sender], "Not enough V2 token balance to claim from.");

        uint256 airdropAmnt = _cty_V2_Claimable_Amount[msg.sender];

        _claimed[msg.sender] = true;
        _cty_V2_Claimable_Amount[msg.sender] = 0;
        total_V2_Tokens_Distributed += airdropAmnt;
        total_Migrators++;

        _ctyV2Token.transfer(msg.sender, airdropAmnt);

        emit AirdropClaimed(msg.sender, airdropAmnt);
    }
    
    function _withdrawETH() external onlyOwner {
         require(address(this).balance > 0, 'Contract has no money');
         address payable wallet = payable(msg.sender);
        wallet.transfer(address(this).balance);    
    }
    
    function _withdrawTokens(IERC20 tokenAddress) external onlyOwner{
        IERC20 tokenERC = tokenAddress;
        uint256 tokenAmt = tokenERC.balanceOf(address(this));
        require(tokenAmt > 0, "Token balance is 0");
        address payable wallet = payable(msg.sender);
        tokenERC.transfer(wallet, tokenAmt);
    }

}