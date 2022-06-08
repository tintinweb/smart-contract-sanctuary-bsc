// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "Ownable.sol";
import "ILaunchPad.sol";
import "LaunchPad.sol";

contract LaunchPadFactory is Ownable{

    mapping(address => mapping(address => address)) public _launchPadPair;
    address[] public _launchPadArray;
 
    event createEvent(address fundToken_,address idoToken_,address pair_,uint256 arraryLengh) ;
    
    function createLaunchPadContract(ILaunchPad.LaunchPadInfo memory launchPadInfo_,address addr_) 
        external 
        virtual  
        onlyOwner
        returns(address pair)
    {
        require(launchPadInfo_.idoToken != launchPadInfo_.fundToken,
            "address has been identical"
        );
        require(_launchPadPair[launchPadInfo_.idoToken][launchPadInfo_.fundToken] == address(0),
            "the pair has been exists"
        );
        bytes memory bytecode = type(LaunchPad).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(launchPadInfo_.idoToken, launchPadInfo_.fundToken, address(this)));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        ILaunchPad(pair).setLaunchPadInfo(launchPadInfo_,addr_);
        _launchPadArray.push(pair);
        _launchPadPair[launchPadInfo_.idoToken][launchPadInfo_.fundToken] = pair;
        emit createEvent(launchPadInfo_.fundToken,launchPadInfo_.idoToken,pair,_launchPadArray.length);
        return pair;
    }

    function getLaunchPadArrayLength() external view returns(uint256){
        return _launchPadArray.length;
    }

    function getLaunchPadPairAddress(address idoToken,address fundToken) external view returns(address){
        require(fundToken != address(0),"address cannot be address(0)");
        require(idoToken != fundToken,"address cannot be equal");
        return _launchPadPair[idoToken][fundToken];
    }

    function setMerkleRoot(address pair, bytes32 _root) external onlyOwner {
        ILaunchPad(pair).setRoot(_root);
    }

    function withDrawToAccount(address pair) external onlyOwner {
        ILaunchPad(pair).withdrawToAccount();
    }

    function setLaunchFinished(address pair,bool finished_) external onlyOwner{
        ILaunchPad(pair).setFinished(finished_);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "Context.sol";

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
    constructor() {
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
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
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "IERC20.sol";

interface ILaunchPad {
    struct LaunchPadInfo {
        address  fundToken;
        address  idoToken;
        uint256  preSale;
        uint256  startTime;
        uint256  endTime;
        uint256  softTop;
        uint256  hardTop;
        uint256  minAmout;
        uint256  maxAmout;
        uint256  ratio;
    }

    event setLaunchPadInfoEvent(LaunchPadInfo info);
    event joinLaunchPad(address sender,uint256 amount);
    event withdrawEvent(IERC20 token,address sender,uint256 amount);

    function setLaunchPadInfo(LaunchPadInfo memory info,address addr_) external returns(bool);
    function withdrawToCustomer() external;
    function doTransfer(uint256 value,bytes32[] memory proof) external payable;
    function doTransfer(uint256 value) external payable;
    function withdrawToAccount() external returns(uint256);
    function getBalanceOf() external view returns(uint256);
    function getLaunchPadInfo() external view returns(LaunchPadInfo memory );
    function getAddressCount() external view returns(uint256);  
    function finished() external view returns(bool);
    function setFinished( bool finished_) external;
    function checkAddress(address addr) external view returns(bool);
    function accountIsValid(bytes32[] memory proof, bytes32 leaf) external view returns (bool);
    function setRoot(bytes32 root_) external ;  
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "IERC20.sol";
import "MerkleProof.sol";
import "Ownable.sol";
import "ILaunchPad.sol";


contract LaunchPad is Ownable, ILaunchPad {
    
    IERC20 _fundToken;
    IERC20 _idoToken;
    bool public _finished = false;
    bool public _successed = false;
    bool public _paramset =false;
    uint256 constant  COEFFICENT = 1000;
    uint256 public _length=0;

    bytes32 public root;
    address public _fundOwner;

    LaunchPadInfo public _launchPadInfo;

    mapping(address => uint256) public _balance;

    modifier Addressable(address addr){
        require(addr != address(0), "address cannot be address(0)");
        _;
    }   

    modifier SafeAddress(bytes32[] memory proof){
        require(accountIsValid(proof, keccak256(abi.encodePacked(msg.sender))), 
            "Not a part of Allowlist"
        );
        _;
    }

    function setLaunchPadInfo(LaunchPadInfo memory info,address addr_) external virtual override onlyOwner returns(bool){
        require(info.fundToken != address(0),"myToken address cannot be address(0)");
        require(
            info.startTime >= block.timestamp && info.endTime >info.startTime,
            "launchpad time error"
        );
        require(info.hardTop >= info.softTop ,"launchpad hardtop cannot less than softtop"); 
        require(info.maxAmout >= info.minAmout ,"launchpad max cannot less than min");
        require(info.preSale >= (info.hardTop*info.ratio/COEFFICENT),
            "Insufficient pre-sale quantity"
        );
        _launchPadInfo = info;

        _fundToken = IERC20(_launchPadInfo.fundToken);

        if(info.idoToken != address(0)){
            _idoToken = IERC20(_launchPadInfo.idoToken);
        }

        emit setLaunchPadInfoEvent(_launchPadInfo);

        _fundOwner = addr_;
        _paramset = true;       
        return true;
    }

    function doTransfer(uint256 value,bytes32[] memory proof) 
        external 
        payable
        virtual
        override
        SafeAddress(proof)
    {
        require(bytes32(0) != root,"IDO is public sale");
        onTransfer(value);
    }

    function doTransfer(uint256 value) external payable virtual override
    {      
        require(bytes32(0) == root,"IDO is not public sale");
        onTransfer(value);
    }

    function withdrawToCustomer() 
        external 
        virtual
        override  
    {
        require(checkAddress(msg.sender),"The account has not token");
        require(finished(),"the launchpad is not over");

        uint256 balance = _balance[msg.sender];
        if(_successed){    
            require(_fundToken.allowance(_fundOwner,address(this)) >= (balance*_launchPadInfo.ratio/COEFFICENT),
            "_fundToken allowance too low");     
            _fundToken.transferFrom(_fundOwner,msg.sender,balance*_launchPadInfo.ratio/COEFFICENT);
            emit withdrawEvent(_fundToken,msg.sender,balance*_launchPadInfo.ratio/COEFFICENT);
        }else {
            if(_launchPadInfo.idoToken != address(0)){
                require(_idoToken.balanceOf(address(this)) >= balance,
                    "this contract has not enough balace"
                );
                _idoToken.transfer(msg.sender,balance);
            }else {
                require(address(this).balance >= balance,
                    "this contract has not enough balace"
                );
                payable(msg.sender).transfer(balance);
            }
            
            _balance[msg.sender] = 0;
            emit withdrawEvent(_idoToken,msg.sender,balance);
       }
    }

    function withdrawToAccount() external virtual override onlyOwner returns(uint256){
        require(_finished,"the launchpad is not over");
        uint256 balance = getBalanceOf();
        if(_successed){
            if(_launchPadInfo.idoToken != address(0)){
                _idoToken.transfer(_fundOwner,balance);
            }else{
                payable(_fundOwner).transfer(balance);
            }
            return balance;
        }
        return 0;
    }   

    function getBalanceOf() public view virtual override returns(uint256){
        uint256 balance;
        if(_launchPadInfo.idoToken != address(0)){
            balance= _idoToken.balanceOf(address(this));
        }else {
            balance= address(this).balance;
        }
        return balance;
    }

    function getLaunchPadInfo() public view virtual override returns(LaunchPadInfo memory ){
        return _launchPadInfo;
    }

    function setFinished( bool finished_) public virtual override onlyOwner  {
        _finished = finished_;
    }

    function finished() public view virtual override returns(bool){
        return _finished||
            (block.timestamp > _launchPadInfo.endTime)||
            (_launchPadInfo.hardTop - getBalanceOf() < _launchPadInfo.minAmout);
    }

    function checkAddress(address addr) public view virtual override Addressable(addr) returns(bool e){
        if(_balance[addr] != 0){
            e = true;
        }else {
            e = false;
        }
        return e;
    }

    function accountIsValid(bytes32[] memory proof, bytes32 leaf) public view virtual override returns (bool) {
        return MerkleProof.verify(proof, root, leaf);
    }

    function setRoot(bytes32 root_) public virtual override onlyOwner {
        root = root_;
    }

    function getAddressCount() public view virtual override returns(uint256){
        return _length;
    }
    
    function addAddressCount(address addr) private  Addressable(addr) {
        if(!checkAddress(addr)){
            _length = _length + 1;
        }
    }

    function addDataToMapping(address from_,uint256 value) private  Addressable(from_) {
        require(value > 0,"value cannot be less than zero");
        _balance[from_] += value;
    }

    function onTransfer(uint256 value) private {
        require(msg.sender != address(0),"msg.sender address cannot be address(0)");
        require(_paramset,"Please set parameters first");
        require(value >= _launchPadInfo.minAmout &&
                _balance[msg.sender] + value <= _launchPadInfo.maxAmout,
                "quantity out of range.");
        require(!finished() , "IDO has already over.");
        uint256 balance = getBalanceOf();
        require(value <= (_launchPadInfo.hardTop - balance),
                "msg.value cannot be more than remaining quantity");
        require(block.timestamp > _launchPadInfo.startTime, "activity not started");
               
        if(!_successed){
            if((balance + value) >= _launchPadInfo.softTop){
                _successed = true;
            }
        }

        if(_launchPadInfo.idoToken != address(0)){
            require(_idoToken.balanceOf(msg.sender) >= value,"Insufficient ownership");    
            require(_idoToken.allowance(msg.sender,address(this)) >= value,
                "_idoToken allowance too low"
            );
            _idoToken.transferFrom(msg.sender,address(this),value);
        }else {
            require(msg.value == value,"The entered quantity is inconsistent with the quantity carried by MSG");
        }
           
        addAddressCount(msg.sender);
        addDataToMapping(msg.sender,value);

        emit joinLaunchPad(msg.sender,value);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Trees proofs.
 *
 * The proofs can be generated using the JavaScript library
 * https://github.com/miguelmota/merkletreejs[merkletreejs].
 * Note: the hashing algorithm should be keccak256 and pair sorting should be enabled.
 *
 * See `test/utils/cryptography/MerkleProof.test.js` for some examples.
 *
 * WARNING: You should avoid using leaf values that are 64 bytes long prior to
 * hashing, or use a hash function other than keccak256 for hashing leaves.
 * This is because the concatenation of a sorted pair of internal nodes in
 * the merkle tree could be reinterpreted as a leaf value.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = _efficientHash(computedHash, proofElement);
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = _efficientHash(proofElement, computedHash);
            }
        }
        return computedHash;
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}