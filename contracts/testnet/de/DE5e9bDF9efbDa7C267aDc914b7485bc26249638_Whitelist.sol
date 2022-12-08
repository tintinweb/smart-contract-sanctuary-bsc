// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts-newone/access/Ownable.sol";

contract Whitelist is Ownable {

    struct TokenList {
        address token;
        uint256 chainId;
    }

    mapping(uint256 => TokenList) public _tokenWithChainID;
    mapping(address => bool) public tokenList;
    mapping(address => mapping(int128 => address)) public poolTokensList;
    mapping(address => bool) public dexList;
    mapping(address => uint256) public dexFee;
    uint256 tokenIndex;
    uint256 public nativeReturnAmount;
    uint256 public stableFee;

    function addTokenToWhitelist(address token) public onlyOwner {
        tokenList[token] = true;
    }

    function removeTokenFromWhitelist(address token) public onlyOwner {
        tokenList[token] = false;
    }

    function addDexBatch(address[] calldata dexAddr, bool[] calldata status, uint256[] calldata fee) public onlyOwner {
        for(uint i=0; i<dexAddr.length; i++){
            dexList[dexAddr[i]] = status[i];
            dexFee[dexAddr[i]]  = fee[i];
        }
    }

    function changeDexStatus(address dexAddr, bool status) public onlyOwner {
        dexList[dexAddr] = status;
    }

    function changeDexFee(address dexAddr, uint256 fee) public onlyOwner {
        dexFee[dexAddr] = fee;
    }

    function setListedStatus(address[] calldata tokens, bool[] calldata status, uint256[] calldata chainId) public onlyOwner{

        TokenList memory list;

        for(uint i=0; i<tokens.length; i++){
            tokenList[tokens[i]] = status[i];
            list.token = tokens[i];
            list.chainId = chainId[i];
            _tokenWithChainID[tokenIndex++] = list;
        }

    }

    function setPoolToWhitelist(address pool, address[] calldata tokens, int128 arrLength) public onlyOwner {
        uint j;
        for(int128 i=0; i<arrLength; i++){
            poolTokensList[pool][i] = tokens[j++];
        }
    }

    function checkDestinationToken(address pool, int128 index) external view returns(bool) {
        address destinationToken = poolTokensList[pool][index];
        return tokenList[destinationToken];
    }

    function returnAppovedTokens(uint256 index) public view returns(TokenList[100] memory _tokenList) {
        require(tokenIndex > 100*index);
        uint256 j;
        for(uint i=100*index; i<tokenIndex; i++){
            if(tokenList[_tokenWithChainID[i].token]){
                _tokenList[j].token = _tokenWithChainID[i].token;
                _tokenList[j++].chainId = _tokenWithChainID[i].chainId;
            }
            if(j == 100) {
                break;
            }
        }

    }

    function setNativePrice(uint256 newAmount) public onlyOwner {
        nativeReturnAmount = newAmount;
    }

    function setStableFee(uint256 newAmount) public onlyOwner {
        stableFee = newAmount;
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}