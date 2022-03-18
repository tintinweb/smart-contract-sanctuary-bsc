// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import {IUserCowsBoy} from './IUserCowsBoy.sol';
import {IERC20} from './IERC20.sol';
import {SafeMath} from './SafeMath.sol';
import {IERC721} from './IERC721.sol';
import {IERC721Enumerable} from './IERC721Enumerable.sol';
import {IERC721Metadata} from './IERC721Metadata.sol';
import {IUserCowsBoy} from './IUserCowsBoy.sol';
import {IVerifySignature} from './IVerifySignature.sol';
import './ReentrancyGuard.sol';


contract COWS_GAME_721 is ReentrancyGuard {
    using SafeMath for uint256;
    address public operator;
    address public owner;
    bool public _paused = false;

    address public POOL_GAME;
    address public POOL_RIM;
    address public COWS_TOKEN;
    address public RIM_TOKEN;   
    address public NSC_NFT_TOKEN;
    address public VERIFY_SIGNATURE;
    address public USER_COWSBOY;

    uint256 public constant DECIMAL_18 = 10**18;
    uint256 public constant PERCENTS_DIVIDER = 1000000000;

    struct UserInfo {
            uint256 cowsDeposit;
            uint256 rimDeposit;
            uint256 nscDeposit;
            uint256 lastUpdatedAt;
            uint256 cowsRewardClaimed;
            uint256 rimRewardClaimed;
            uint256 nscRewardClaimed;
            uint8 status;  // 0 : not active ; 1 active ; 2 is lock ; 2 is ban
    }

    struct DepositedNFT {
        uint256[] depositedTokenIds;
        mapping(uint256 => uint256) tokenIdToIndex; //index + 1
    }
    
    mapping(address => UserInfo) public userInfo;
    //nft => user => DepositedNFT
    mapping(address => mapping(address => DepositedNFT)) nftUserInfo;
    //user => sign => status
    mapping(address => mapping(bytes => bool)) userSigned;
    //events
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ChangeOperator(address indexed previousOperator, address indexed newOperator);
    event TokenDeposit(address token, address depositor, uint256 amount);
    event TokenWithdraw(
        address token,
        address withdrawer,
        uint256 amount,
        uint256 balance,
        uint256 spent,
        uint256 win
    );

    event NFTDeposit(address nft, address depositor, bytes tokenIds);
    event NFTWithdraw(address nft, address withdrawer, bytes tokenIds);
    event NFTClaim(address nft, address withdrawer, bytes tokenIds);

    
    modifier onlyOwner() {
        require(msg.sender == owner, 'INVALID owner');
        _;
    }

    modifier onlyOperator() {
        require(msg.sender == operator, 'INVALID operator');
        _;
    }

    constructor(address _cows, address _rim,address _nsc, address _user, address _sign, address _poolRIM) public {
        owner  = tx.origin;
        operator = tx.origin;
        POOL_GAME = tx.origin;
        COWS_TOKEN = _cows;
        RIM_TOKEN = _rim;   
        NSC_NFT_TOKEN = _nsc;
        USER_COWSBOY = _user;
        VERIFY_SIGNATURE = _sign;
        POOL_RIM = _poolRIM;
    }

    fallback() external {

    }

    receive() payable external { 

    }

    function pause() public onlyOwner {
        _paused=true;
    }

    function unpause() public onlyOwner {
        _paused=false;
    }

    
    modifier ifPaused(){
        require(_paused,"");
        _;
    }

    modifier ifNotPaused(){
        require(!_paused,"");
        _;
    }  


    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal onlyOwner {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Transfers operator of the contract to a new account (`operator`).
     * Can only be called by the current owner.
     */
    function transferOperator(address _operator) public onlyOwner {
        emit ChangeOperator(operator , _operator);
        operator = _operator;
    }

    /**
    * @dev Withdraw Token to an address, revert if it fails.
    * @param recipient recipient of the transfer
    */
    function clearToken(address recipient, address token, uint256 amount ) public onlyOwner {
        require(IERC20(token).balanceOf(address(this)) >= amount , "INVALID balance");
        require(RIM_TOKEN != token  , "Can not withdraw RIM");
        IERC20(token).transfer(recipient, amount);
    }


    function withdrawRIMToPool(uint256 amount ) public onlyOwner {
        require(IERC20(RIM_TOKEN).balanceOf(address(this)) >= amount , "INVALID balance");
        IERC20(RIM_TOKEN).transfer(POOL_RIM, amount);
    }


    /**
    * @dev Withdraw  BNB to an address, revert if it fails.
    * @param recipient recipient of the transfer
    */
    function clearBNB(address payable recipient) public onlyOwner {
        _safeTransferBNB(recipient, address(this).balance);
    }

    /**
    * @dev transfer BNB to an address, revert if it fails.
    * @param to recipient of the transfer
    * @param value the amount to send
    */
    function _safeTransferBNB(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'BNB_TRANSFER_FAILED');
    }
    /**
    * @dev Update sendFTLNFTList
    */
    function sendFTLNFTList( address _nft, address[] calldata recipients,uint256[] calldata idTokens) public onlyOwner {
        for (uint256 i = 0; i < recipients.length; i++) {
        IERC721(_nft).transferFrom(address(this),recipients[i], idTokens[i]);     
        }
    }

    function sendNFT(
        address _account,
        address _receive,
        address _nft,
        uint256 _tokenId)
     public onlyOwner    
    {
        IERC721(_nft).transferFrom(
            _account,
            _receive,
            _tokenId
        );
        
    }

    
    /**
    * @dev Update update_POOL_GAME
    */
    function updatePool(address _pool) public onlyOwner {
        POOL_GAME = _pool;
    }


    function getUserInfo (address account) public view returns(
            uint256 cowsDeposit,
            uint256 rimDeposit,
            uint256 lastUpdatedAt,
            uint256 cowsRewardClaimed,
            uint256 rimRewardClaimed
            ) {

            UserInfo storage _user = userInfo[account];      
            return (
                _user.cowsDeposit,
                _user.rimDeposit,
                _user.lastUpdatedAt,
                _user.cowsRewardClaimed,
                _user.rimRewardClaimed);
    }

    function getUserInfoNFT (address account) public view returns(
            uint256 nscDeposit,
            uint256 lastUpdatedAt,
            uint256 nscRewardClaimed 
            ) {

            UserInfo storage _user = userInfo[account];      
            return (
                _user.nscDeposit,
                _user.lastUpdatedAt,
                _user.nscRewardClaimed
                );
    }
    //public number token nft in the address 
    function getBalanceMyNFTWallet (address account, address _nft) public view returns(uint256){
        uint256 balance = IERC721(_nft).balanceOf(account);
        return  balance;
    }
   
    //public token id of nft in the address by seed index
    function getTokenidMyNFTWalletByIndex (address account, address _nft, uint256 seedIndex) public view returns(uint256 ,uint256){
     
        uint256 tokenId;     
        if(IERC721(_nft).balanceOf(account) == 0) return (0,0); 
         if(IERC721(_nft).balanceOf(account) <= seedIndex) return (0,0);
        tokenId = IERC721Enumerable(_nft).tokenOfOwnerByIndex(account,seedIndex);
        return (IERC721(_nft).balanceOf(account),tokenId); 
    }

    function depositCOWSToGame(uint256 amount) public ifNotPaused returns (bool)
    {
        require(IUserCowsBoy(USER_COWSBOY).isRegister(msg.sender) == true , "Address not whitelist registed system");
        uint256 allowance = IERC20(COWS_TOKEN).allowance(msg.sender, address(this));
        require(allowance >= amount, "Check the token allowance");
        uint256 balance = IERC20(COWS_TOKEN).balanceOf(msg.sender);
        require(balance >= amount, "Sorry : not enough balance to buy ");
        _depositTokenToGame(msg.sender,COWS_TOKEN,amount);
        return true;
    }

    function depositRIMToGame(uint256 amount) public ifNotPaused returns (bool)
    {
        require(IUserCowsBoy(USER_COWSBOY).isRegister(msg.sender) == true , "Address not whitelist registed system");
        uint256 allowance = IERC20(RIM_TOKEN).allowance(msg.sender, address(this));
        require(allowance >= amount, "Check the token allowance");
        uint256 balance = IERC20(RIM_TOKEN).balanceOf(msg.sender);
        require(balance >= amount, "Sorry : not enough balance to buy ");
        _depositTokenToGame(msg.sender,RIM_TOKEN,amount);
        return true;
    }

    function _depositTokenToGame(address depositor , address token, uint256 _amount) internal {
        require(token == COWS_TOKEN || token == RIM_TOKEN," Invalid token deposit");
        IERC20(token).transferFrom(depositor, address(this), _amount);
        if(token == COWS_TOKEN){
            userInfo[depositor].cowsDeposit += _amount;
        }
        if(token == RIM_TOKEN){
            userInfo[depositor].rimDeposit += _amount;
        }
        userInfo[depositor].lastUpdatedAt = block.timestamp;
        emit TokenDeposit(token,depositor,_amount);
    }


    function isSignOperator(uint256 _amount, string memory _message, uint256 _expiredTime, bytes memory _signature) public view returns (bool) 
    {
        return IVerifySignature(VERIFY_SIGNATURE).verify(operator, msg.sender, _amount, _message, _expiredTime, _signature);    
    }
        
    function withdrawCOWSTokens(
        uint256 _amount,
        uint256 _amountSpent, // Spent in game 
        uint256 _amountWin, // Profit in game 
        string memory _message,
        uint256 _expiredTime,
        bytes memory signature
    ) public ifNotPaused returns (bool) {
        require(userSigned[msg.sender][signature] == false, "withdrawCOWSTokens: invalid signature"); 
        require(block.timestamp < _expiredTime, "withdrawCOWSTokens: !expired");
        require(
            IVerifySignature(VERIFY_SIGNATURE).verify(operator, msg.sender, _amount, _message, _expiredTime, signature) == true ,
            "withdrawCOWSTokens: invalid operator"
        );
        
        uint256 amount = _amount * DECIMAL_18;
        UserInfo storage _user = userInfo[msg.sender];

        require(_user.cowsDeposit - _amountSpent + _amountWin > 0 , "withdrawCOWSTokens: invalid balance ");
        require(_user.cowsDeposit - _amountSpent + _amountWin >= amount, "withdrawCOWSTokens: invalid amount");
        
        //return token 
        IERC20(COWS_TOKEN).transfer(msg.sender, amount);

       emit TokenWithdraw(
        COWS_TOKEN,
        msg.sender,
        amount,
        _user.cowsDeposit,
        _amountSpent,
        _amountWin);
        
        _user.cowsDeposit = _user.cowsDeposit - _amountSpent + _amountWin -  amount;
        _user.cowsRewardClaimed += amount;
        _user.lastUpdatedAt = block.timestamp;
        userSigned[msg.sender][signature] = true;
        return true;
    }
    
    function withdrawRIMTokens(
        uint256 _amount,
        uint256 _amountSpent, // Spent in game 
        uint256 _amountWin, // Profit in game 
        string memory _message,
        uint256 _expiredTime,
        bytes memory signature
    ) public ifNotPaused returns (bool) {
        require(userSigned[msg.sender][signature] == false, "withdrawRIMTokens: invalid signature"); 
        require(block.timestamp < _expiredTime, "withdrawRIMTokens: !expired");
        require(
            IVerifySignature(VERIFY_SIGNATURE).verify(operator, msg.sender, _amount, _message, _expiredTime, signature) == true ,
            "withdrawRIMTokens: invalid operator"
        );
        
        uint256 amount = _amount * DECIMAL_18;
        UserInfo storage _user = userInfo[msg.sender];

        require(_user.rimDeposit - _amountSpent + _amountWin > 0 , "withdrawRIMTokens: invalid balance ");
        require(_user.rimDeposit - _amountSpent + _amountWin >= amount, "withdrawRIMTokens: invalid amount");
        
        //return token 
        IERC20(RIM_TOKEN).transfer(msg.sender, amount);

       emit TokenWithdraw(
        RIM_TOKEN,
        msg.sender,
        amount,
        _user.rimDeposit,
        _amountSpent,
        _amountWin);
        
        _user.rimDeposit = _user.rimDeposit - _amountSpent + _amountWin -  amount;
        _user.rimRewardClaimed += amount;
        _user.lastUpdatedAt = block.timestamp;
        userSigned[msg.sender][signature] = true;
        return true;
    }


    function depositNFTsToGame(address _nft, uint256 _tokenId)
        public ifNotPaused returns (bool)
    {
        require(_nft == NSC_NFT_TOKEN ,"depositNFTsToGame: Invalid token deposit");   
        DepositedNFT storage _userNFT = nftUserInfo[_nft][msg.sender];
        IERC721(_nft).transferFrom(
                msg.sender,
                address(this),
                _tokenId
            );
        _userNFT.depositedTokenIds.push(_tokenId);
        _userNFT.tokenIdToIndex[_tokenId] = _userNFT.depositedTokenIds.length;

        if(_nft == NSC_NFT_TOKEN){
            userInfo[msg.sender].nscDeposit += 1;
        }
        
        userInfo[msg.sender].lastUpdatedAt = block.timestamp;
        emit NFTDeposit(_nft, msg.sender, abi.encodePacked(_tokenId));
        return true;
    }

    function withdrawNFTs(
        address _nft,
        uint256 _tokenId,
        string memory _message,
        uint256 _expiredTime,
        bytes memory signature
    ) public ifNotPaused returns (bool) {
        require(userSigned[msg.sender][signature] == false, "withdrawNFTs: invalid signature"); 
        require(block.timestamp < _expiredTime, "withdrawNFTs: !expired");

        require(
            IVerifySignature(VERIFY_SIGNATURE).verify(operator, msg.sender, _tokenId , _message, _expiredTime, signature) == true ,
            "withdrawNFTs: invalid operator"
        );
        
        DepositedNFT storage _user = nftUserInfo[_nft][msg.sender];
        require(_user.tokenIdToIndex[_tokenId] > 0, "withdrawNFTs: invalid tokenId");
        IERC721(_nft).transferFrom(
            address(this),
            msg.sender,
            _tokenId
        );
        //swap
        uint256 _index = _user.tokenIdToIndex[_tokenId] - 1;
        _user.depositedTokenIds[_index] = _user.depositedTokenIds[
            _user.depositedTokenIds.length - 1
        ];
        _user.tokenIdToIndex[_user.depositedTokenIds[_index]] = _index + 1;
        _user.depositedTokenIds.pop();

        delete _user.tokenIdToIndex[_tokenId];
       
        if(_nft == NSC_NFT_TOKEN){
            userInfo[msg.sender].nscDeposit -= 1;
        }
 
        userInfo[msg.sender].lastUpdatedAt = block.timestamp;
        emit NFTWithdraw(_nft, msg.sender, abi.encodePacked(_tokenId));
        userSigned[msg.sender][signature] = true;
        return true;
    }

    function claimNFTRewards(
        address _nft,
        uint256 amount, // default 1
        string memory _message,
        uint256 _expiredTime,
        bytes memory signature
    ) public ifNotPaused returns (uint256) 
    {
        require(userSigned[msg.sender][signature] == false, "claimNFTRewards: invalid signature"); 
        require(block.timestamp < _expiredTime, "claimNFTRewards: !expired");
        require(_nft == NSC_NFT_TOKEN ,"claimNFTRewards: Invalid token deposit");   
        require(
            IVerifySignature(VERIFY_SIGNATURE).verify(operator, msg.sender, amount , _message, _expiredTime, signature) == true ,
            "invalid operator"
        );
        require(amount == 1, "claimNFTRewards: amount 1 ");
        uint256 _tokenId;
        for (uint256 i = 0; i < amount; i++) {
            _tokenId = IERC721Enumerable(_nft).tokenOfOwnerByIndex(POOL_GAME,0);
            if(ownerOfNFT(_nft,_tokenId) != POOL_GAME)
            {
                revert("claimNFTRewards: Please try again !");
            }
            IERC721(_nft).transferFrom(
                POOL_GAME,
                msg.sender,
                _tokenId
            );
        }
        emit NFTClaim(_nft, msg.sender, abi.encodePacked(_tokenId));
        userSigned[msg.sender][signature] = true;
        return _tokenId;
    }

    function ownerOfNFT(address _nft,uint256 tokenId) public view returns (address){
        return IERC721(_nft).ownerOf(tokenId);
    }

    function getDepositedNFTs(address _nft, address _user)
        external
        view
        returns (uint256[] memory depositeNFTs)
    {
        return nftUserInfo[_nft][_user].depositedTokenIds;
    }
}