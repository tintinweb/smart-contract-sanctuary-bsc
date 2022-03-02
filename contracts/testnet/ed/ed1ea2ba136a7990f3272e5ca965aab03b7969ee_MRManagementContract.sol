/**
 *Submitted for verification at BscScan.com on 2022-03-02
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^ 0.8.7;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Interface of the Meta Ruffy token
 */
interface MRTOKEN is IERC20 {

    receive() external payable;

    function transferOwnership(address newOwner) external;

    function renounceOwnership() external;

    function clearStuckBalance(uint256 amountPercentage) external;
    
    function changeSwapToken(address token) external;

    function updateBuyFees(uint256 reward, uint256 marketing, uint256 liquidity, uint256 dev, uint256 burn) external;

    function updateSellFees(uint256 reward, uint256 marketing, uint256 liquidity, uint256 dev, uint256 burn) external;

    function switchToken(address rewardToken, bool isIncludeHolders) external;

    function setIsDividendExempt(address holder, bool exempt) external;

    function setIsFeeExempt(address holder, bool exempt) external;

    function setFeeReceivers(address _marketingFeeReceiver, address _devFeeReceiver) external;
    

    function setSwapBackSettings(bool _enabled, uint256 _amount) external;

    function setDistributionCriteria( uint256 _minPeriod, uint256 _minDistribution ) external; 
    
    function setDistributorSettings(uint256 gas) external;

    function purgeBeforeSwitch() external;
}

abstract contract Signable is Context {
    mapping(address => bool) public isSigner;
    mapping(address => bool ) public hasSigned;
    address[] public signers;
    uint public signCounts;

    modifier onlySigned(){
        require(signCounts >= signers.length, "Sinable: not fully signed.");
        _;
        signCounts = 0;
        for(uint i; i < signers.length; i++){
            hasSigned[signers[i]] = false;
        }
    }

    event SignerRemoved(address indexed signer);
    event SignerAdded(address indexed signer);

    constructor(address[] memory newSigners) {
        for(uint i; i < newSigners.length; i++) {
            require(newSigners[i] != address(0), "Sinable: zero address found.");
            isSigner[newSigners[i]] = true;
            signers.push(newSigners[i]);
        }

        isSigner[_msgSender()] = true;
        signers.push(_msgSender());
    }

    function sign() external {
        require(isSigner[_msgSender()], "Sinable: caller is not a signer.");
        require(!hasSigned[_msgSender()], "Sinable: caller has already signed.");
        hasSigned[_msgSender()] = true;
        signCounts += 1;
    }

    function addSigner(address newSigner) external onlySigned {
        require(newSigner != address(0), "Signable: new signer address is zero");
        isSigner[newSigner] = true;
        signers.push(newSigner);
        emit SignerAdded(newSigner);
    }

    function removeSigner(address signer) external onlySigned {
        require(signer != address(0), "Signable: signer address is zero");
        require(isSigner[signer], "Signable: address is not a signer.");
        isSigner[signer] = false;
        for(uint i; i < signers.length; i++) {
            if(signer == signers[i]){
                signers[i] = signers[signers.length - 1];
                signers.pop();
            }
        }

        emit SignerRemoved(signer);
    }

    function listSigners() external view returns(address[] memory){
        return signers;
    }
}

contract MRManagementContract is Context, Signable {

    MRTOKEN public token;
    IERC20 public rewardToken;


    event MRTokenUpdated(address indexed newTokenAddress);
    
    constructor(
        address token_,
        address rewardToken_,
        address[] memory signers
    ) 
        Signable(signers)
    {
        require(token_ != address(0) && rewardToken_ != address(0), "Contract: address is zero.");
        token = MRTOKEN(payable(token_));
        rewardToken = IERC20(rewardToken_);
    }

    function updateMRToken(address newTokenAddress) public onlySigned {
        require(newTokenAddress != address(0), "Contract: address is zero");
        token = MRTOKEN(payable(newTokenAddress));
        emit MRTokenUpdated(newTokenAddress);
    }

    function updateRewardToken(address newRewardToken) public onlySigned {
        require(newRewardToken != address(0), "Contract: reward token is zero address");
        rewardToken = IERC20(newRewardToken);
    }

    function transferOwnership(address newOwner) external onlySigned {
        require(newOwner != address(0), "Contract: new owner is zero address");
        token.transferOwnership(newOwner);
    }

    function renounceOwnership() external onlySigned {
        token.renounceOwnership();
    }

    function clearStuckBalance(uint256 amountPercentage) external onlySigned {
        token.clearStuckBalance(amountPercentage);
        payable(_msgSender()).transfer(address(this).balance);
    }
    
    function changeSwapToken(address newToken) external onlySigned {
        require(newToken != address(0), "Contract: token is a zero address");
        token.changeSwapToken(newToken);
    }

    function updateBuyFees(uint256 reward, uint256 marketing, uint256 liquidity, uint256 dev, uint256 burn) external onlySigned {
        token.updateBuyFees(reward, marketing, liquidity, dev, burn);
    }

    function updateSellFees(uint256 reward, uint256 marketing, uint256 liquidity, uint256 dev, uint256 burn) external onlySigned {
        token.updateSellFees(reward, marketing, liquidity, dev, burn);
    }

    function switchToken(address rewardToken_, bool isIncludeHolders) external onlySigned {
        require(rewardToken_ != address(0), "Contract: reward token is a zero address");
        token.switchToken(rewardToken_, isIncludeHolders);
    }

    function setIsDividendExempt(address holder, bool exempt) external onlySigned {
        token.setIsDividendExempt(holder, exempt);
    }

    function setIsFeeExempt(address holder, bool exempt) external onlySigned {
        token.setIsFeeExempt(holder, exempt);
    }

    function setFeeReceivers(address _marketingFeeReceiver, address _devFeeReceiver) external onlySigned {
        require(_marketingFeeReceiver != address(0) && _devFeeReceiver != address(0), "Contract: a zero address found");
        token.setFeeReceivers(_marketingFeeReceiver, _devFeeReceiver);
    }
    

    function setSwapBackSettings(bool _enabled, uint256 _amount) external onlySigned {
        token.setSwapBackSettings(_enabled, _amount);
    }

    function setDistributionCriteria( uint256 _minPeriod, uint256 _minDistribution ) external onlySigned {
        token.setDistributionCriteria(_minPeriod, _minDistribution);
    } 
    
    function setDistributorSettings(uint256 gas) external onlySigned {
        token.setDistributorSettings(gas);
    }

    function purgeBeforeSwitch() public onlySigned {
        token.purgeBeforeSwitch();
    }

    function claimBNB() external onlySigned {
        payable(msg.sender).transfer(address(this).balance);
    }

    function claimRewardTokens() external onlySigned {
        rewardToken.transfer(_msgSender(), rewardToken.balanceOf(address(this)));
    }
}