/**
 *Submitted for verification at BscScan.com on 2022-04-18
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

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
     * by making the `nonReentrant` function external, and making it call a
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

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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

contract SamuraiLocker is ReentrancyGuard, Ownable {
    
    address samurai = 0xbC832492afc102F36f7752F0D325e1f68648614F;
    address BUSD    = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    uint256 unlockTime = 1652904000;

    mapping (address => uint256) public samuraiBalanceOf;
    mapping (address => uint256) public lastHarvest;
    mapping (address => uint256) public withdrawnBUSD;
    
    uint256 public amountSamurai = 79999999975 * 10**15;
    uint256 public totalBUSD;
    uint256 private balanceBeforeHarvesting;
    uint256 private balanceAfterHarvesting;

    constructor() {
        _setShares();
    }

    function harvestBUSD() external nonReentrant {
        require(block.timestamp - lastHarvest[msg.sender] > 22 hours, "Cannot harvest twice in less than 22 hours");

        balanceBeforeHarvesting = IERC20(BUSD).balanceOf(address(this));
        totalBUSD += (balanceBeforeHarvesting - balanceAfterHarvesting);
        
        uint256 busdShare = totalBUSD * samuraiBalanceOf[msg.sender] / amountSamurai;
        uint256 busdToHarvest = busdShare - withdrawnBUSD[msg.sender];
    
        IERC20(BUSD).transfer(msg.sender, busdToHarvest);
        
        withdrawnBUSD[msg.sender] += busdToHarvest;

        balanceAfterHarvesting = totalBUSD - busdToHarvest;

        lastHarvest[msg.sender] = block.timestamp;
    }

    function claimLockedTokens() external nonReentrant {
        require(block.timestamp > unlockTime, "Wait for the unlock date and time");
        
        IERC20(samurai).transfer(msg.sender, samuraiBalanceOf[msg.sender]);
        samuraiBalanceOf[msg.sender] = 0;
    }

    function withdrawnableBUSD(address account) public view returns (uint256) {
        uint256 busdShare = totalBUSD * samuraiBalanceOf[account] / amountSamurai;
        uint256 busdToHarvest = busdShare - withdrawnBUSD[account];
        return busdToHarvest;
    }

    function claimStuckTokens(address token) external onlyOwner {
        if (token == address(0x0)) {
            payable(msg.sender).transfer(address(this).balance);
            return;
        }
        IERC20 ERC20token = IERC20(token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(msg.sender, balance);
    }

    function _setShares() internal {
        samuraiBalanceOf[	0x6426d7Dc1283AE6336810f456B531413e3FD7ABf	] =	1562500	* (10**18);
        samuraiBalanceOf[	0x70bB1631cfc6C3789795dC928E99D215239ec585	] =	1562500	* (10**18);
        samuraiBalanceOf[	0xEe4841F7BdF8820389e8f9E66FbB735AA30A91BC	] =	1562500	* (10**18);
        samuraiBalanceOf[	0x972B1A16e0C96b7830eF1819d140420979F1E233	] =	1562500	* (10**18);
        samuraiBalanceOf[	0x243a5020075934825DE8d67A4C8ceCE2bbC8be75	] =	1562500	* (10**18);
        samuraiBalanceOf[	0xACc6C64C0188Fb12C93754280710D54c4C501b31	] =	1562500	* (10**18);
        samuraiBalanceOf[	0xD962Cfadf555E001e6873Aed7F03E0E481483ce6	] =	1562500	* (10**18);
        samuraiBalanceOf[	0xA0ceADdef14B66d260845905f98a8Ed31a88850f	] =	1562500	* (10**18);
        samuraiBalanceOf[	0xA2166E2444a5448D4AFb5F3115472c3BAD103DC4	] =	1562500	* (10**18);
        samuraiBalanceOf[	0x9Bfd44cFE421222A709FC4F169dA16C9d47495cF	] =	625000	* (10**18);
        samuraiBalanceOf[	0xDcc1cF65f9189eBe2C0312E958e7260f2d804410	] =	1250000	* (10**18);
        samuraiBalanceOf[	0xC7980AA777FFFa9fb5895DB570A8fbAce0307279	] =	1562500	* (10**18);
        samuraiBalanceOf[	0xA24547a209DBE0Ab4BC41712662b234D253A6736	] =	1562500	* (10**18);
        samuraiBalanceOf[	0xD2304b77CDB7e467975D0c90de03dce63eC5ECc4	] =	1562500	* (10**18);
        samuraiBalanceOf[	0x1B2f3efaBCF1af4dBE24f3E713F5dDd89B9A2782	] =	1562500	* (10**18);
        samuraiBalanceOf[	0xc37A629d1FdF7fa3321C9aDe48F5f2fE4A7A7859	] =	1562500	* (10**18);
        samuraiBalanceOf[	0x153D290A39188BF228ae4a7d3E1249E6598665EC	] =	1562500	* (10**18);
        samuraiBalanceOf[	0x81339b6deB96c67c10E04BB90528716d7450898D	] =	1562500	* (10**18);
        samuraiBalanceOf[	0xB95072833b90c39a9aB5938a374062aB5fAC3b2E	] =	1562500	* (10**18);
        samuraiBalanceOf[	0xaEc8a78A5b524a85A73356F5E433F8df5920A7B8	] =	1562500	* (10**18);
        samuraiBalanceOf[	0xF064E112d6b5A16e158ec0b55c31FBA67010b072	] =	1562500	* (10**18);
        samuraiBalanceOf[	0xEA040fa811eB0539cDcCa4c17e44056921bda6BD	] =	1562500	* (10**18);
        samuraiBalanceOf[	0x860DFcE6Ee0A86903A4d1c06f0cFbCfDd59624cC	] =	1562500	* (10**18);
        samuraiBalanceOf[	0x054b0cAF44569bBdaDa92B2a61e8Fa47901e473e	] =	1562500	* (10**18);
        samuraiBalanceOf[	0x6F7D7cE1Cf4bd99B76E8af66a05b3A342539C84C	] =	937500	* (10**18);
        samuraiBalanceOf[	0xf203fD9CB069B90158a393e2e7CE739a38a9b71D	] =	625000	* (10**18);
        samuraiBalanceOf[	0xB19da47B8A246d748ECD3707B19fC8AA3450b534	] =	1562500	* (10**18);
        samuraiBalanceOf[	0xd419A1e52556cEd6e7f7B21ca297E62dD6d6410B	] =	1562500	* (10**18);
        samuraiBalanceOf[	0xb0eFA5BC047F4cc553CE87c8b8cFFa6f868a728B	] =	1562500	* (10**18);
        samuraiBalanceOf[	0x4057BD082B4217891569D503563f17C4D428DEeC	] =	1562500	* (10**18);
        samuraiBalanceOf[	0xd415D5F599B40b638D6d4b6Bbb9836b86aa960FE	] =	1562500	* (10**18);
        samuraiBalanceOf[	0xF732Cd666EA1321f5a673570bc09fd2E087fA2Eb	] =	1562500	* (10**18);
        samuraiBalanceOf[	0xc03fFa6e861F639a9f49fAceCD99e64e393D222D	] =	1562500	* (10**18);
        samuraiBalanceOf[	0x24eA3fA67881d57B60338bEA2229295fAa5967A7	] =	1562500	* (10**18);
        samuraiBalanceOf[	0xB4640Eb0772B6A6831895c319a981587277Aa5F1	] =	1562500	* (10**18);
        samuraiBalanceOf[	0x96230465Ca6A98F31123714B9277CAbBd777a2c8	] =	925000	* (10**18);
        samuraiBalanceOf[	0xdFf9D17cDc0f2C11E07D91EA19513e8976915a6B	] =	1562500	* (10**18);
        samuraiBalanceOf[	0x1238f44300d0b98199366EDcC5E6c2fF66807579	] =	1562500	* (10**18);
        samuraiBalanceOf[	0xf2b2f584FF10097a8291E2848e1405F8080DC113	] =	1250000	* (10**18);
        samuraiBalanceOf[	0x6514d1e18582E361E8B65Fb83fAD40D7A3E244B5	] =	1250000	* (10**18);
        samuraiBalanceOf[	0x90d4B6BBf0276532c98AEc9a22D5928B3DdE7F15	] =	1250000	* (10**18);
        samuraiBalanceOf[	0x80A1bB305BA9316847248FeD50f2D562319E1489	] =	1250000	* (10**18);
        samuraiBalanceOf[	0x2e2df006fE3e2e4f5d25cEED0F4F5DA29ec99010	] =	1250000	* (10**18);
        samuraiBalanceOf[	0x09844FF1F9959D0493a6C82a68D0076148B69099	] =	1562500	* (10**18);
        samuraiBalanceOf[	0xfB5cD5256Cbc6f4FC9f18CC95F40fAB8DE6D74EC	] =	1250000	* (10**18);
        samuraiBalanceOf[	0xcB07c39964632cc69303CadfF0f5E44B5664F802	] =	1250000	* (10**18);
        samuraiBalanceOf[	0x99BfABF1AD72A866B28Aa3d3930C35185f05fC00	] =	1250000	* (10**18);
        samuraiBalanceOf[	0x783ba63D64c37afE583E15355697362a5abB345F	] =	625000	* (10**18);
        samuraiBalanceOf[	0x96612d963f1053798C44a32d3F95219c686abaC8	] =	1250000	* (10**18);
        samuraiBalanceOf[	0x5Bd29e190b4c508aeFE64A1265bA3Beb3ffe4Cd2	] =	1562500	* (10**18);
        samuraiBalanceOf[	0xcEEBF88b28bFFc0F5DaE6A0f81D7a8CB9061b6a3	] =	625000	* (10**18);
        samuraiBalanceOf[	0xF327e9519167f5aCe32EA97B45995148bA0dD0c9	] =	1250000	* (10**18);
        samuraiBalanceOf[	0x44ACeACDA6a4d6ea664333563c9286c224A4F60f	] =	1250000	* (10**18);
        samuraiBalanceOf[	0xbA6642B3643F9bd56e84BBCC8f3D2929D5245c69	] =	13969554125	* (10**14);
        samuraiBalanceOf[	0x61Ff83C4B9f9eEE5Fea440D3a3F4cC6d7aD60611	] =	14281758125	* (10**14);
        samuraiBalanceOf[	0x332EDCF2ae453B927049Ef26A5944118DB606366	] =	1562434375	* (10**15);
        samuraiBalanceOf[	0xe0EDe69D087c6C8765663F0E05d3862f24183972	] =	1562434375	* (10**15);
    }
}