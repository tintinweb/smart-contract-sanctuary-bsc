// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import {IERC20} from './IERC20.sol';
import {SafeMath} from './SafeMath.sol';
import {Address} from './Address.sol';
import {IUserCowsBoy} from './IUserCowsBoy.sol';
import {IVerifySignature} from './IVerifySignature.sol';
import {IUtilityStringCBS} from './IUtilityStringCBS.sol';
import './ReentrancyGuard.sol';


contract AFFILIATEPOOL is ReentrancyGuard {
    using SafeMath for uint256;
    using Address for address;
    address public operator;
    address public owner;
    bool public _paused = false;

    address public VERIFY_SIGNATURE;
    address public USER_COWSBOY;
    address public UTILITY_CBS;


    address[] public supportedPaymentTokenList;
    mapping(address => bool) public supportedPaymentMapping;
    //user => sign => status
    mapping(address => mapping(bytes => bool)) userSigned;
     //events
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ChangeOperator(address indexed previousOperator, address indexed newOperator);
    event BonusWithdraw(
        address token,
        address withdrawer,
        uint256 amount,
        string  message
    );

    
    modifier onlyOwner() {
        require(msg.sender == owner, 'INVALID owner');
        _;
    }

    modifier onlyOperator() {
        require(msg.sender == operator, 'INVALID operator');
        _;
    }

    modifier onlySupportedPaymentToken(address _token) {
        require(supportedPaymentMapping[_token], "unsupported payment token");
        _;
    }

    constructor() public {
        /*
        owner  = tx.origin;
        operator = 0xb5A65c363A534bc2eF7675D95078b2d13baDD22d;
        USER_COWSBOY = 0x08fAb69f022c5F686Ea3CA0C58Dd08d5ab32D967;
        VERIFY_SIGNATURE = 0x79c546888ECa74e82c84Db29eeBE6dd816aAE2a4;
        UTILITY_CBS = 0xddB4A9ED528bC8538e0543508512CbfBDF08f11a;
        address[] memory _ercs = new address[](2);
        _ercs[0] = 0x33b48893B8f119Fb45F431b36F830a9584804201;
        _ercs[1] = 0x9FE70801C3B26f466d7e7B884659e88c7492A126;
        _changePaymentList(_ercs);
        */
    
        owner  = tx.origin;
        operator = 0x54E3F8074C151eda6ab0378BAd2862B019721041;
        USER_COWSBOY = 0x009fbfe571f29c3b994a0cd84B2f47b7e7D73CDC;
        VERIFY_SIGNATURE = 0x4f0736236903E5042abCc5F957fD0ae32f142405;
        UTILITY_CBS = 0x2353B33D02b44D1786a4553f07Da650608f1DA00;
        address[] memory _ercs = new address[](2);
        _ercs[0] = 0xB084b320Da2a9AC57E06e143109cD69d495275e8;
        _ercs[1] = 0x9FE70801C3B26f466d7e7B884659e88c7492A126;
        _changePaymentList(_ercs);
       
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
    function changePaymentList(address[] memory _supportedPaymentTokens)
        external
        onlyOwner
    {
        _changePaymentList(_supportedPaymentTokens);
    }

    function _changePaymentList(address[] memory _supportedPaymentTokens)
        private
    {
        //reset current list
        for (uint256 i = 0; i < supportedPaymentTokenList.length; i++) {
            supportedPaymentMapping[supportedPaymentTokenList[i]] = false;
        }
        supportedPaymentTokenList = _supportedPaymentTokens;
        for (uint256 i = 0; i < supportedPaymentTokenList.length; i++) {
            supportedPaymentMapping[supportedPaymentTokenList[i]] = true;
        }
    }
    
    function _isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function isContract(address account) external view returns (bool)
    {
        return _isContract(account);
    }

    function claimBonusRewards(
        address _ercToken,
        uint256 _amount,
        string memory _message,
        uint256 _expiredTime,
        bytes memory signature
    ) external onlySupportedPaymentToken(_ercToken) ifNotPaused returns (bool)
    {
        require(_isContract(msg.sender) == false, "claimBonusRewards: anti bot");
        require(userSigned[msg.sender][signature] == false, "claimBonusRewards: invalid signature");
        require(block.timestamp < _expiredTime, "claimBonusRewards: !expired");
        require(_amount > 0, "claimBonusRewards: invalid amount");
        require(IUtilityStringCBS(UTILITY_CBS).verifyMessageNFT(_message,_ercToken) == true ,"claimBonusRewards: Invalid token sign");   
        require(
            IVerifySignature(VERIFY_SIGNATURE).verify(operator, msg.sender, _amount , _message, _expiredTime, signature) == true,
            "claimBonusRewards: invalid operator"
        );
        IERC20(_ercToken).transfer(msg.sender, _amount);
        emit BonusWithdraw(
            _ercToken,
            msg.sender,
            _amount,
            _message
        );
        userSigned[msg.sender][signature] = true;
        return true;
    }


    

    function test(string memory _message, address _nft) public view returns (bool){
        return IUtilityStringCBS(UTILITY_CBS).verifyMessageNFT(_message,_nft) ;
    }
    
}