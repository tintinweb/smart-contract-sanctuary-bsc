// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import {IUserCowsBoy} from './IUserCowsBoy.sol';
import {IERC20} from './IERC20.sol';
import {SafeMath} from './SafeMath.sol';
import {IERC1155} from './IERC1155.sol';
import {IUserCowsBoy} from './IUserCowsBoy.sol';
import {IVerifySignature} from './IVerifySignature.sol';
import './ReentrancyGuard.sol';

contract COWS_GAME_1155 is ReentrancyGuard {
    using SafeMath for uint256;
    address public operator;
    address public owner;
    bool public _paused = false;

    address public POOL_GAME;
    address public VERIFY_SIGNATURE;
    address public USER_COWSBOY;

    uint256 public constant DECIMAL_18 = 10**18;
    uint256 public constant PERCENTS_DIVIDER = 1000000000;

    struct UserInfo {
        mapping(address => uint256) nftDeposit;
        uint256 lastUpdatedAt;
        mapping(address => uint256) nftRewardClaimed;
        uint8 status;  // 0 : not active ; 1 active ; 2 is lock ; 2 is ban
    }

    struct DepositedNFT {
        uint256[] depositedTokenIds;
        mapping(uint256 => uint256) tokenIdToAmount;
        mapping(uint256 => uint256) tokenIdToIndex;
    }

    mapping(address => UserInfo) public userInfo;
    //nft => user => DepositedNFT
    mapping(address => mapping(address => DepositedNFT)) nftUserInfo;
    //NFT support
    address[] public supportedNFTList;
    mapping(address => bool) public supportedNFTMapping;
    //user => sign => status
    mapping(address => mapping(bytes => bool)) userSigned;
    //events
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ChangeOperator(address indexed previousOperator, address indexed newOperator);


    event NFTDeposit(address nft, address depositor, bytes tokenIds, uint256 amount);
    event NFTWithdraw(address nft, address withdrawer, bytes tokenIds, uint256 amount);
    event NFTClaim(address nft, address withdrawer, bytes tokenIds, uint256 amount);
    event NFTSupported(address nft, bool val);

    modifier onlyOwner() {
        require(msg.sender == owner, 'INVALID owner');
        _;
    }

    modifier onlyOperator() {
        require(msg.sender == operator, 'INVALID operator');
        _;
    }

    constructor(address _user, address _sign) public {
        owner  = tx.origin;
        operator = tx.origin;
        POOL_GAME = tx.origin;
        USER_COWSBOY = _user;
        VERIFY_SIGNATURE = _sign;
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

    modifier onlySupportedNFT(address _nft) {
        require(supportedNFTMapping[_nft], "not supported nft");
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
        IERC20(token).transfer(recipient, amount);
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
    * @dev Update update_POOL_WALLET
    */
    function updatePool(address _pool) public onlyOwner {
        POOL_GAME = _pool;
    }

    function setSupportedNFTs(address[] memory _nfts) external onlyOwner {
        _setSupportedNFTs(_nfts);
    }

    function _setSupportedNFTs(address[] memory _nfts) private {
        //diminish the current list
        for (uint256 i = 0; i < supportedNFTList.length; i++) {
            supportedNFTMapping[supportedNFTList[i]] = false;
            emit NFTSupported(supportedNFTList[i], false);
        }
        supportedNFTList = _nfts;
        for (uint256 i = 0; i < supportedNFTList.length; i++) {
            supportedNFTMapping[supportedNFTList[i]] = true;
            emit NFTSupported(_nfts[i], true);
        }
    }





    function depositNFTsToGame(address _nft, uint256 _tokenId,
        uint256 _amount)
    external onlySupportedNFT(_nft) ifNotPaused returns (bool)
    {
        require(IERC1155(_nft).isApprovedForAll(msg.sender,address(this))  == true, "depositNFTsToGame: Check the nft approve ");

        DepositedNFT storage _userNFT = nftUserInfo[_nft][msg.sender];

        IERC1155(_nft).safeTransferFrom(
            msg.sender,
            POOL_GAME,
            _tokenId,
            _amount,
            ""
        );

        _userNFT.depositedTokenIds.push(_tokenId);
        _userNFT.tokenIdToIndex[_tokenId] = _userNFT.depositedTokenIds.length;
        _userNFT.tokenIdToAmount[_tokenId] +=  _amount;

        userInfo[msg.sender].nftDeposit[_nft] += _amount;
        userInfo[msg.sender].lastUpdatedAt = block.timestamp;
        emit NFTDeposit(_nft, msg.sender, abi.encodePacked(_tokenId), _amount);
        return true;
    }

    function withdrawNFTs(
        address _nft,
        uint256 _tokenId,
        uint256 _amount,
        string memory _message,
        uint256 _expiredTime,
        bytes memory signature
    ) external onlySupportedNFT(_nft) ifNotPaused returns (bool) {
        require(userSigned[msg.sender][signature] == true, "withdrawNFTs: invalid signature");
        require(block.timestamp < _expiredTime, "withdrawNFTs: !expired");

        require(
            IVerifySignature(VERIFY_SIGNATURE).verify(operator, msg.sender, _tokenId , _message, _expiredTime, signature) == true ,
            "withdrawNFTs: invalid operator"
        );

        DepositedNFT storage _user = nftUserInfo[_nft][msg.sender];

        require(_user.tokenIdToIndex[_tokenId] > 0, "withdrawNFTs: invalid tokenId");
        require(_amount > 0, "withdrawNFTs: invalid amount");
        require(_user.tokenIdToAmount[_tokenId] >= _amount, "withdrawNFTs: invalid amount");

        IERC1155(_nft).safeTransferFrom(
            POOL_GAME,
            msg.sender,
            _tokenId,
            _amount,
            ""
        );

        _user.tokenIdToAmount[_tokenId] -=  _amount;

        if(_user.tokenIdToAmount[_tokenId]<=0){
            uint256 _index = _user.tokenIdToIndex[_tokenId] - 1;
            _user.depositedTokenIds[_index] = _user.depositedTokenIds[
            _user.depositedTokenIds.length - 1
            ];
            _user.tokenIdToIndex[_user.depositedTokenIds[_index]] = _index + 1;
            _user.depositedTokenIds.pop();
            delete _user.tokenIdToIndex[_tokenId];
        }

        userInfo[msg.sender].nftDeposit[_nft] -= _amount;
        userInfo[msg.sender].lastUpdatedAt = block.timestamp;
        emit NFTWithdraw(_nft, msg.sender, abi.encodePacked(_tokenId), _amount);
        userSigned[msg.sender][signature] = true;
        return true;
    }

    function withdrawNFTsTest(
        address _nft,
        uint256 _tokenId,
        uint256 _amount,
        string memory _message,
        uint256 _expiredTime,
        bytes memory signature
    ) external ifNotPaused returns (bool) {
        return IVerifySignature(VERIFY_SIGNATURE).verify(operator, msg.sender, _tokenId , _message, _expiredTime, signature);
    }

    function testSign(
        address _nft,
        uint256 _tokenId,
        uint256 _amount,
        string memory _message,
        uint256 _expiredTime,
        bytes memory signature)
    external
    view
    returns (bool)
    {
        return IVerifySignature(VERIFY_SIGNATURE).verify(operator, msg.sender, _tokenId , _message, _expiredTime, signature);
    }

    function claimNFTRewards(
        address _nft,
        uint256 _tokenId,
        uint256 _amount,
        string memory _message,
        uint256 _expiredTime,
        bytes memory signature
    ) external onlySupportedNFT(_nft) ifNotPaused returns (uint256)
    {
        require(userSigned[msg.sender][signature] == true, "claimNFTRewards: invalid signature");
        require(block.timestamp < _expiredTime, "claimNFTRewards: !expired");
        require(_amount > 0, "claimNFTRewards: invalid amount");
        require(
            IVerifySignature(VERIFY_SIGNATURE).verify(operator, msg.sender, _tokenId , _message, _expiredTime, signature) == true ,
            "claimNFTRewards: invalid operator"
        );

        IERC1155(_nft).safeTransferFrom(
            msg.sender,
            POOL_GAME,
            _tokenId,
            _amount,
            ""
        );

        emit NFTClaim(_nft, msg.sender, abi.encodePacked(_tokenId),_amount);
        userSigned[msg.sender][signature] = true;
        return _tokenId;
    }


    function getDepositedNFTs(address _nft, address _user)
    external
    view
    returns (uint256[] memory depositeNFTs)
    {
        return nftUserInfo[_nft][_user].depositedTokenIds;
    }

}